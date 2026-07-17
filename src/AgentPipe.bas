'###############################################################################
'#  AgentPipe.bas -- see AgentPipe.bi for the contract and MCP_SERVER_PLAN.md #
'#  for the architecture. Protocol (plan section 4): newline-delimited JSON,  #
'#  one in-flight request per connection, UTF-8.                               #
'#     request:  { "id": 42, "cmd": "ping", "args": { ... } }                  #
'#     success:  { "id": 42, "ok": true, "result": { ... } }                   #
'#     failure:  { "id": 42, "ok": false,                                      #
'#                 "error": { "code": "unknown_cmd", "message": "..." } }      #
'###############################################################################

Const AGENT_PIPE_NAME = "\\.\pipe\AstoriaAgent"

Dim Shared gAgentHwnd As HWND                   '' main window (WM_APP_AGENTCMD target)
Dim Shared gAgentThread As Any Ptr              '' worker thread handle (ThreadCreate)
Dim Shared gAgentStop As Boolean                '' worker shutdown flag
Dim Shared gAgentActive As Boolean              '' listener up (StartAgentPipe..StopAgentPipe)
Dim Shared gAgentStopEvent As HANDLE            '' signalled once at StopAgentPipe
Dim Shared gAgentPipeHandle As HANDLE = INVALID_HANDLE_VALUE

'' The single in-flight command slot (plan section 5). Owned by the worker
'' between publish and completion; the UI thread only touches it inside
'' AgentPipe_ExecutePendingOnUi after WM_APP_AGENTCMD.
Dim Shared gCmdPending As Boolean
Dim Shared gCmdName As String                   '' UTF-8
Dim Shared gCmdArgs As JsonValue Ptr            '' borrowed view into the request tree (may be 0)
Dim Shared gCmdOk As Boolean
Dim Shared gCmdResult As JsonValue Ptr          '' owned; set by the UI thread on success
Dim Shared gCmdErrCode As String
Dim Shared gCmdErrMsg As String
Dim Shared gCmdDone As HANDLE                   '' auto-reset completion event

'' Build-in-progress flag reported by get_status; wired up by MCP Task 4's async
'' build path. False until then.
Dim Shared gAgentBuilding As Boolean

'' ---------------------------------------------------------------- utf-8

'' The IDE stores text as WString (UTF-16 on Win64); the pipe and JSON speak
'' UTF-8. These convert at that boundary via the Win32 codepage APIs (a plain
'' WString<->String assignment would go through CP_ACP and mangle non-ASCII).

Function WStrToUtf8(ByRef w As WString) As String
	If Len(w) = 0 Then Return ""
	Dim As Integer n = WideCharToMultiByte(CP_UTF8, 0, @w, -1, NULL, 0, NULL, NULL)
	If n <= 1 Then Return ""
	Dim As String s = String(n - 1, 0)   '' n includes the NUL terminator
	WideCharToMultiByte(CP_UTF8, 0, @w, -1, StrPtr(s), n - 1, NULL, NULL)
	Return s
End Function

'' Returns a heap WString the caller must WDeAllocate (mirrors the codebase's
'' WLet/WGet idiom for owned wide strings).
Function Utf8ToWStr(ByRef s As String) As WString Ptr
	Dim As WString Ptr w
	If Len(s) = 0 Then
		WLet(w, "")
		Return w
	End If
	Dim As Integer n = MultiByteToWideChar(CP_UTF8, 0, StrPtr(s), Len(s), NULL, 0)
	Dim As WString Ptr buf = CAllocate((n + 1) * SizeOf(WString))
	MultiByteToWideChar(CP_UTF8, 0, StrPtr(s), Len(s), buf, n)
	buf[n] = 0
	Return buf
End Function

'' ---------------------------------------------------------------- read-only helpers (UI thread)

'' The open project's ProjectElement, or 0 if none is open.
Private Function AgentProject() As ProjectElement Ptr
	Dim As TreeNode Ptr tn = GetOpenProjectNode()
	If tn = 0 OrElse tn->Tag = 0 Then Return 0
	Return Cast(ProjectElement Ptr, tn->Tag)
End Function

'' Resolve a client-supplied path (project-relative or absolute) and reject
'' anything that escapes the open project's root. Returns "" and sets err* on
'' rejection. Read-only here; the same guard protects the Task-3 mutators.
Private Function AgentResolveProjectPath(ByRef rawUtf8 As String, ByRef errCode As String, ByRef errMsg As String) As UString
	errCode = "" : errMsg = ""
	Dim As ProjectElement Ptr ppe = AgentProject()
	If ppe = 0 Then errCode = "no_project" : errMsg = "No project is open." : Return ""
	Dim As UString root = GetFolderNameU(WGet(ppe->FileName))   '' project folder, trailing slash
	If root = "" Then errCode = "no_project" : errMsg = "Project folder not found." : Return ""
	Dim As WString Ptr rawW = Utf8ToWStr(rawUtf8)
	Dim As UString resolved = GetFullPathU(*rawW)               '' absolutize + collapse .. against CWD/root
	'' A relative path resolves against the project folder, not the process CWD.
	If Len(*rawW) > 0 AndAlso Mid(*rawW, 2, 1) <> ":" AndAlso Left(*rawW, 1) <> "\" AndAlso Left(*rawW, 1) <> "/" Then
		resolved = GetFullPathU(root & *rawW)
	End If
	WDeAllocate(rawW)
	'' Containment check: resolved must sit inside root (case-insensitive on Windows).
	Dim As UString rootCmp = LCase(root)
	Dim As UString resCmp = LCase(resolved)
	If Left(resCmp, Len(rootCmp)) <> rootCmp Then
		errCode = "bad_path" : errMsg = "Path escapes the project folder: " & rawUtf8
		Return ""
	End If
	Return resolved
End Function

'' Read a whole file as raw bytes (returns "" if unreadable). Used by read_file;
'' bytes are passed straight into JSON as a UTF-8 string (source files are UTF-8).
Private Function AgentReadFileBytes(ByRef path As UString) As String
	Dim As Integer fn = FreeFile
	If Open(path For Binary Access Read As #fn) <> 0 Then Return ""
	Dim As LongInt sz = LOF(fn)
	Dim As String buf
	If sz > 0 Then
		buf = String(sz, 0)
		Get #fn, 1, buf
	End If
	Close #fn
	'' Strip a UTF-8 BOM if present -- callers want the text, not the marker.
	If Len(buf) >= 3 AndAlso buf[0] = &HEF AndAlso buf[1] = &HBB AndAlso buf[2] = &HBF Then buf = Mid(buf, 4)
	Return buf
End Function

'' ---------------------------------------------------------------- UI thread

'' Command dispatch, run on the UI thread. MCP Task 1+ grows this Select Case;
'' every command fills either (gCmdOk=True, gCmdResult) or (gCmdErrCode/Msg).
Sub AgentPipe_ExecutePendingOnUi()
	If Not gCmdPending Then Exit Sub
	gCmdPending = False
	gCmdOk = False
	gCmdResult = 0
	gCmdErrCode = ""
	gCmdErrMsg = ""
	Select Case gCmdName
	Case "ping"
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("pong", JsonNewBool(True))
		res->SetMember("app", JsonNewString("Astoria IDE"))
		gCmdOk = True
		gCmdResult = res

	Case "get_status"
		'' Read-only health check + current context (plan section 3).
		Dim As JsonValue Ptr res = JsonNewObject()
		Dim As ProjectElement Ptr ppe = AgentProject()
		If ppe Then
			res->SetMember("project", JsonNewString(WStrToUtf8(WGet(ppe->FileName))))
			res->SetMember("main_file", JsonNewString(WStrToUtf8(WGet(ppe->MainFileName))))
		Else
			res->SetMember("project", JsonNewNull())
			res->SetMember("main_file", JsonNewNull())
		End If
		Dim As JsonValue Ptr openArr = JsonNewArray()
		For j As Integer = 0 To ptabCode->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->Tabs[j])
			If tb Then openArr->Append(JsonNewString(WStrToUtf8(tb->FileName)))
		Next j
		res->SetMember("open_files", openArr)
		'' building: set by the async build path in MCP Task 4; always False until
		'' then (Task 1 is read-only, no build state to observe yet).
		res->SetMember("building", JsonNewBool(gAgentBuilding))
		res->SetMember("running", JsonNewBool(Running))
		gCmdOk = True
		gCmdResult = res

	Case "list_files"
		'' Files in the open project, read from the .vfp so it reflects what the
		'' project actually contains (plan section 3). *File= marks the main file.
		Dim As ProjectElement Ptr ppe = AgentProject()
		If ppe = 0 Then
			gCmdErrCode = "no_project" : gCmdErrMsg = "No project is open." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As String vfpText = AgentReadFileBytes(WGet(ppe->FileName))
		Dim As JsonValue Ptr filesArr = JsonNewArray()
		Dim As String mainFile
		Dim As Integer p = 1
		While p <= Len(vfpText)
			Dim As Integer nl = InStr(p, vfpText, Chr(10))
			Dim As String ln
			If nl = 0 Then ln = Mid(vfpText, p) : p = Len(vfpText) + 1 Else ln = Mid(vfpText, p, nl - p) : p = nl + 1
			If Right(ln, 1) = Chr(13) Then ln = Left(ln, Len(ln) - 1)
			If Left(ln, 6) = "*File=" Then
				mainFile = Mid(ln, 7)
				filesArr->Append(JsonNewString(mainFile))
			ElseIf Left(ln, 5) = "File=" Then
				filesArr->Append(JsonNewString(Mid(ln, 6)))
			End If
		Wend
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("files", filesArr)
		If mainFile <> "" Then res->SetMember("main_file", JsonNewString(mainFile)) Else res->SetMember("main_file", JsonNewNull())
		gCmdOk = True
		gCmdResult = res

	Case "read_file"
		Dim As String rawPath
		If gCmdArgs Then rawPath = gCmdArgs->GetStr("path")
		If rawPath = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "read_file requires a 'path'." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As String ec, em
		Dim As UString full = AgentResolveProjectPath(rawPath, ec, em)
		If ec <> "" Then
			gCmdErrCode = ec : gCmdErrMsg = em : SetEvent(gCmdDone) : Exit Sub
		End If
		If Not FileExistsU(full) Then
			gCmdErrCode = "not_found" : gCmdErrMsg = "File not found: " & rawPath : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("content", JsonNewString(AgentReadFileBytes(full)))
		gCmdOk = True
		gCmdResult = res

	Case "get_active_file"
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then
			gCmdErrCode = "no_active_file" : gCmdErrMsg = "No editor tab is active." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(tb->FileName)))
		res->SetMember("content", JsonNewString(WStrToUtf8(tb->txtCode.Text)))
		gCmdOk = True
		gCmdResult = res

	Case "get_build_output"
		'' Raw text of the Output/messages pane from the last build/run.
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("text", JsonNewString(WStrToUtf8(txtOutput.Text)))
		gCmdOk = True
		gCmdResult = res

	Case Else
		gCmdErrCode = "unknown_cmd"
		gCmdErrMsg = "Unknown command: " & gCmdName
	End Select
	SetEvent(gCmdDone)
End Sub

'' ---------------------------------------------------------------- worker

'' Serialize the "id" member of the request for echoing back (number, string,
'' or null -- whatever the client sent).
Private Function AgentIdJson(req As JsonValue Ptr) As String
	If req = 0 Then Return "null"
	Dim As JsonValue Ptr idv = req->Find("id")
	If idv = 0 Then Return "null"
	Return JsonSerialize(idv)
End Function

Private Sub AgentWriteLine(hPipe As HANDLE, ByRef reqLine As String)
	Dim As String outBuf = reqLine & Chr(10)
	Dim As DWORD written
	WriteFile(hPipe, StrPtr(outBuf), Len(outBuf), @written, NULL)
End Sub

'' Handle one complete request reqLine: parse, marshal to the UI thread, wait,
'' respond. Runs on the worker thread.
Private Sub AgentHandleLine(hPipe As HANDLE, ByRef reqLine As String)
	'' Tolerate CRLF clients.
	If Len(reqLine) > 0 AndAlso reqLine[Len(reqLine) - 1] = 13 Then reqLine = Left(reqLine, Len(reqLine) - 1)
	If Len(Trim(reqLine)) = 0 Then Exit Sub

	Dim As JsonValue Ptr req = JsonParse(reqLine)
	Dim As String idJson = AgentIdJson(req)
	Dim As String resp

	If req = 0 OrElse req->Kind <> jkObject Then
		If req Then Delete req
		resp = "{""id"":null,""ok"":false,""error"":{""code"":""bad_json"",""message"":""Request is not a valid JSON object.""}}"
		AgentWriteLine(hPipe, resp)
		Exit Sub
	End If

	'' Publish into the slot and marshal to the UI thread.
	gCmdName = req->GetStr("cmd")
	gCmdArgs = req->Find("args")
	ResetEvent(gCmdDone)
	gCmdPending = True
	PostMessageW(gAgentHwnd, WM_APP_AGENTCMD, 0, 0)

	'' Wait for the UI thread -- or shutdown, so a stuck/exiting UI can't
	'' strand the worker forever.
	Dim As HANDLE waits(0 To 1)
	waits(0) = gCmdDone
	waits(1) = gAgentStopEvent
	Dim As DWORD w = WaitForMultipleObjects(2, @waits(0), FALSE, INFINITE)
	If w <> WAIT_OBJECT_0 Then
		Delete req
		Exit Sub   '' shutting down; no response
	End If

	If gCmdOk Then
		Dim As String resultJson = "{}"
		If gCmdResult Then resultJson = JsonSerialize(gCmdResult)
		resp = "{""id"":" & idJson & ",""ok"":true,""result"":" & resultJson & "}"
	Else
		resp = "{""id"":" & idJson & ",""ok"":false,""error"":{""code"":""" & JsonEscape(gCmdErrCode) & _
			""",""message"":""" & JsonEscape(gCmdErrMsg) & """}}"
	End If
	If gCmdResult Then Delete gCmdResult : gCmdResult = 0
	gCmdArgs = 0
	Delete req
	AgentWriteLine(hPipe, resp)
End Sub

'' Worker thread: accept one client at a time; newline-delimited read loop.
Private Sub AgentPipeThread(param As Any Ptr)
	While Not gAgentStop
		Dim As HANDLE hPipe = CreateNamedPipeW( _
			AGENT_PIPE_NAME, PIPE_ACCESS_DUPLEX, _
			PIPE_TYPE_BYTE Or PIPE_READMODE_BYTE Or PIPE_WAIT, _
			1, 65536, 65536, 0, NULL)
		If hPipe = INVALID_HANDLE_VALUE Then Exit While
		gAgentPipeHandle = hPipe

		'' Blocks until a client connects; StopAgentPipe unblocks this with a
		'' dummy client connection, after which gAgentStop is observed True.
		Dim As Integer connected = ConnectNamedPipe(hPipe, NULL)
		If connected = 0 AndAlso GetLastError() = ERROR_PIPE_CONNECTED Then connected = 1
		If gAgentStop OrElse connected = 0 Then
			CloseHandle(hPipe)
			gAgentPipeHandle = INVALID_HANDLE_VALUE
			If gAgentStop Then Exit While
			Continue While
		End If

		Dim As String acc
		Dim As UByte buf(0 To 4095)
		Do While Not gAgentStop
			Dim As DWORD got
			If ReadFile(hPipe, @buf(0), 4096, @got, NULL) = 0 OrElse got = 0 Then Exit Do
			Dim As String chunk = String(got, 0)
			For i As Integer = 0 To got - 1
				chunk[i] = buf(i)
			Next i
			acc &= chunk
			Do
				Dim As Integer nl = InStr(acc, Chr(10))
				If nl = 0 Then Exit Do
				Dim As String reqLine = Left(acc, nl - 1)
				acc = Mid(acc, nl + 1)
				AgentHandleLine(hPipe, reqLine)
			Loop
		Loop

		FlushFileBuffers(hPipe)
		DisconnectNamedPipe(hPipe)
		CloseHandle(hPipe)
		gAgentPipeHandle = INVALID_HANDLE_VALUE
	Wend
	gAgentActive = False
End Sub

'' ---------------------------------------------------------------- lifecycle

Sub StartAgentPipe(hMainWnd As HWND)
	If gAgentActive Then Exit Sub
	gAgentHwnd = hMainWnd
	gAgentStop = False
	If gCmdDone = 0 Then gCmdDone = CreateEventW(NULL, FALSE, FALSE, NULL)
	If gAgentStopEvent = 0 Then gAgentStopEvent = CreateEventW(NULL, TRUE, FALSE, NULL)
	ResetEvent(gAgentStopEvent)
	gAgentActive = True
	gAgentThread = ThreadCreate_(@AgentPipeThread, 0)
End Sub

Sub StopAgentPipe()
	If Not gAgentActive Then Exit Sub
	gAgentStop = True
	SetEvent(gAgentStopEvent)
	'' Unblock a worker parked in a blocking ReadFile on an idle connected
	'' client, or in ConnectNamedPipe: CancelIoEx on the PIPE handle cancels
	'' synchronous I/O issued by any thread. (CancelSynchronousIo was tried
	'' first and deadlocked here -- FB's ThreadCreate handle is the runtime's
	'' own struct, not the Win32 thread handle, so it silently failed.)
	Dim As HANDLE hp = gAgentPipeHandle
	If hp <> INVALID_HANDLE_VALUE Then CancelIoEx(hp, NULL)
	'' Belt-and-braces for the ConnectNamedPipe phase: a throwaway client
	'' connection also unblocks it (standard named-pipe shutdown idiom).
	Dim As HANDLE hDummy = CreateFileW(AGENT_PIPE_NAME, GENERIC_READ Or GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL)
	If hDummy <> INVALID_HANDLE_VALUE Then CloseHandle(hDummy)
	If gAgentThread Then
		ThreadWait(gAgentThread)
		gAgentThread = 0
	End If
	gAgentActive = False
End Sub

Function AgentPipeActive() As Boolean
	Return gAgentActive
End Function
