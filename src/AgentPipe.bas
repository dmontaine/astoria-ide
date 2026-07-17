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

'' Write raw bytes to a file, creating/overwriting. Content is written as-is
'' (UTF-8 from JSON, no BOM -- matches the source-file convention). Returns False
'' on open failure. UI thread.
Private Function AgentWriteFileBytes(ByRef path As UString, ByRef content As String) As Boolean
	Dim As Integer fn = FreeFile
	If Open(path For Output As #fn) <> 0 Then Return False   '' truncates/creates
	Close #fn
	If Open(path For Binary Access Write As #fn) <> 0 Then Return False
	If Len(content) > 0 Then Put #fn, 1, content
	Close #fn
	Return True
End Function

'' Register an existing on-disk file into the open project's tree + model, so a
'' project save persists its File= line. Mirrors AddFilesToProject's non-dialog
'' branch (folder routing via GetTreeNodeChild, ExplorerElement + tree node, mark
'' the project dirty). Idempotent: a file already present is left as-is. UI thread.
Private Function AgentRegisterFileInProject(ByRef fullPath As UString) As Boolean
	Dim As TreeNode Ptr tnP = GetOpenProjectNode()
	If tnP = 0 Then Return False
	Dim As WString Ptr fpW
	WLet(fpW, fullPath)
	Dim As TreeNode Ptr tnFolder = GetTreeNodeChild(tnP, *fpW)
	If ContainsFileName(tnFolder, *fpW) Then WDeAllocate(fpW) : Return True
	Dim As String iconName = GetIconName(*fpW)
	Dim As TreeNode Ptr tn3 = tnFolder->Nodes.Add(GetFileName(*fpW), , , iconName, iconName, True)
	Dim As ExplorerElement Ptr ee = _New(ExplorerElement)
	WLet(ee->FileName, *fpW)
	tn3->Tag = ee
	If Not EndsWith(tnP->Text, "*") Then tnP->Text &= "*"
	If Not tnP->IsExpanded Then tnP->Expand
	If Not tnFolder->IsExpanded Then tnFolder->Expand
	WDeAllocate(fpW)
	Return True
End Function

'' ---------------------------------------------------------------- build/run (pipe-worker thread)

'' Convert a wide-char buffer of a KNOWN length (which may contain interior
'' U+0000) to UTF-8. Unlike WStrToUtf8, this passes the explicit length rather
'' than -1, so embedded NULs survive (JsonEscape renders each as a Unicode
'' escape) instead of truncating the string at the first one. Used by the
'' run-output path, where a program can legitimately emit NUL bytes.
Private Function WBufToUtf8(w As WString Ptr, nWide As Integer) As String
	If w = 0 OrElse nWide <= 0 Then Return ""
	Dim As Integer n = WideCharToMultiByte(CP_UTF8, 0, w, nWide, NULL, 0, NULL, NULL)
	If n <= 0 Then Return ""
	Dim As String s = String(n, 0)
	WideCharToMultiByte(CP_UTF8, 0, w, nWide, StrPtr(s), n, NULL, NULL)
	Return s
End Function

'' Convert console-codepage (OEM) bytes to UTF-8. A captured program's stdout is
'' in the console output codepage, not UTF-8; passing raw high-bit bytes into
'' JSON would produce invalid UTF-8. ASCII passes through unchanged either way.
'' NUL-safe: interior NULs are preserved (converted whole via an explicit length)
'' rather than truncating the text.
Private Function OemToUtf8(ByRef s As String) As String
	If Len(s) = 0 Then Return ""
	Dim As Integer n = MultiByteToWideChar(CP_OEMCP, 0, StrPtr(s), Len(s), NULL, 0)
	If n <= 0 Then Return s
	Dim As WString Ptr w = CAllocate((n + 1) * SizeOf(WString))
	MultiByteToWideChar(CP_OEMCP, 0, StrPtr(s), Len(s), w, n)
	w[n] = 0
	Dim As String r = WBufToUtf8(w, n)
	Deallocate(w)
	Return r
End Function

'' Decode a captured program's raw stdout bytes into a UTF-8 string for JSON.
'' Console programs normally emit OEM-codepage text, but a FreeBASIC source with
'' a UTF-8 BOM makes Print emit UTF-16LE (null-interleaved) wide text; running
'' that through the OEM path would emit a stream of interior NULs. Detect
'' UTF-16LE -- by a BOM, or by a strong run of NULs in the high byte of each
'' unit -- and decode it as wide; otherwise fall back to the OEM path (which is
'' itself NUL-safe now, so any stray NULs are preserved rather than truncating).
Private Function AgentDecodeRunOutput(ByRef s As String) As String
	If Len(s) = 0 Then Return ""
	Dim As Integer startByte = 0
	Dim As Boolean isUtf16 = False
	If Len(s) >= 2 AndAlso s[0] = &HFF AndAlso s[1] = &HFE Then
		isUtf16 = True : startByte = 2          '' explicit UTF-16LE BOM
	Else
		'' Heuristic: in UTF-16LE ASCII text the high byte of each unit is 0, so
		'' the odd byte positions are almost all NUL. Plain OEM/ASCII output has
		'' essentially none. Sample up to 1 KB; treat >=50% odd-position NULs as
		'' UTF-16LE.
		Dim As Integer lim = Len(s) : If lim > 1024 Then lim = 1024
		Dim As Integer checked = 0, nul = 0
		For i As Integer = 1 To lim - 1 Step 2
			checked += 1
			If s[i] = 0 Then nul += 1
		Next i
		If checked > 0 AndAlso nul * 2 >= checked Then isUtf16 = True
	End If
	If Not isUtf16 Then Return OemToUtf8(s)
	'' Reinterpret bytes [startByte..] as little-endian UTF-16 code units.
	Dim As Integer nWide = (Len(s) - startByte) \ 2
	If nWide <= 0 Then Return ""
	Dim As WString Ptr w = CAllocate((nWide + 1) * SizeOf(WString))
	For i As Integer = 0 To nWide - 1
		w[i] = s[startByte + i * 2] Or (CUInt(s[startByte + i * 2 + 1]) Shl 8)
	Next i
	w[nWide] = 0
	Dim As String r = WBufToUtf8(w, nWide)
	Deallocate(w)
	Return r
End Function

'' Whether the last build produced any error-severity problems. This -- not
'' Compile's return value -- is the truthful pass/fail signal: Compile("Check")
'' returns success (the check ran) even when it reported errors.
Private Function AgentHasBuildErrors() As Boolean
	For i As Integer = 0 To lvProblems.ListItems.Count - 1
		Dim As ListViewItem Ptr it = lvProblems.ListItems.Item(i)
		If it AndAlso LCase(it->ImageKey) = "error" Then Return True
	Next
	Return False
End Function

'' Structured errors[] from the last build's Problems list (lvProblems), which
'' Compile populated: item caption = message, ImageKey = Warning/Error/Info,
'' Text(1) = line, Text(2) = file.
Private Function AgentBuildErrorsArray() As JsonValue Ptr
	Dim As JsonValue Ptr arr = JsonNewArray()
	For i As Integer = 0 To lvProblems.ListItems.Count - 1
		Dim As ListViewItem Ptr it = lvProblems.ListItems.Item(i)
		If it = 0 Then Continue For
		Dim As JsonValue Ptr e = JsonNewObject()
		e->SetMember("severity", JsonNewString(LCase(WStrToUtf8(it->ImageKey))))
		e->SetMember("message", JsonNewString(WStrToUtf8(it->Text(0))))
		Dim As String lnStr = Trim(WStrToUtf8(it->Text(1)))
		If lnStr <> "" Then e->SetMember("line", JsonNewNumber(Val(lnStr))) Else e->SetMember("line", JsonNewNull())
		e->SetMember("file", JsonNewString(WStrToUtf8(it->Text(2))))
		arr->Append(e)
	Next
	Return arr
End Function

'' Launch the freshly built executable with stdout/stderr captured to a pipe;
'' block until it exits; return its output and exit code. Console targets only
'' produce output; a GUI target still launches but yields no captured text.
'' Runs on the pipe-worker thread (mirrors how the menu Run derives paths).
Private Sub AgentCaptureRun(ByRef outText As String, ByRef exitCode As Integer, ByRef launched As Boolean, ByRef isConsole As Boolean)
	launched = False : outText = "" : exitCode = -1 : isConsole = False
	Dim As ProjectElement Ptr proj
	Dim As TreeNode Ptr node
	Dim As UString mainFile = GetMainFile(False, proj, node)
	If mainFile = "" Then Exit Sub
	Dim As UString compileLine
	Dim As UString firstLine = GetFirstCompileLine(mainFile, proj, compileLine)
	Dim As UString exe = GetExeFileName(mainFile, compileLine & " " & firstLine)
	If Not FileExists(exe) Then Exit Sub
	isConsole = (InStr(LCase(firstLine & " " & compileLine), "-s gui") = 0)

	'' GUI target: no console output to capture, and its window runs until the user
	'' closes it -- blocking the agent (WaitForSingleObject INFINITE) on a
	'' human-closed window is wrong. Launch it detached, report started, and return.
	If Not isConsole Then
		Dim As STARTUPINFOW giSi
		Dim As PROCESS_INFORMATION giPi
		giSi.cb = SizeOf(giSi)
		Dim As WString Ptr gCmdW, gWorkW
		WLet(gCmdW, """" & exe & """")
		WLet(gWorkW, GetFolderName(exe))
		If CreateProcessW(NULL, gCmdW, NULL, NULL, FALSE, CREATE_UNICODE_ENVIRONMENT, NULL, *gWorkW, @giSi, @giPi) Then
			launched = True
			CloseHandle(giPi.hThread) : CloseHandle(giPi.hProcess)
		End If
		WDeAllocate(gCmdW) : WDeAllocate(gWorkW)
		Exit Sub
	End If

	Dim As SECURITY_ATTRIBUTES sa
	sa.nLength = SizeOf(sa) : sa.bInheritHandle = True : sa.lpSecurityDescriptor = NULL
	Dim As HANDLE hRead, hWrite
	If CreatePipe(@hRead, @hWrite, @sa, 0) = 0 Then Exit Sub
	SetHandleInformation(hRead, HANDLE_FLAG_INHERIT, 0)   '' the child must not inherit our read end

	Dim As STARTUPINFOW si
	si.cb = SizeOf(si)
	si.dwFlags = STARTF_USESTDHANDLES
	si.hStdOutput = hWrite
	si.hStdError = hWrite
	si.hStdInput = GetStdHandle(STD_INPUT_HANDLE)
	Dim As PROCESS_INFORMATION pi
	Dim As WString Ptr cmdW, workW
	WLet(cmdW, """" & exe & """")
	WLet(workW, GetFolderName(exe))
	Dim As DWORD flags = CREATE_NO_WINDOW Or CREATE_UNICODE_ENVIRONMENT
	If CreateProcessW(NULL, cmdW, NULL, NULL, TRUE, flags, NULL, *workW, @si, @pi) = 0 Then
		CloseHandle(hRead) : CloseHandle(hWrite) : WDeAllocate(cmdW) : WDeAllocate(workW) : Exit Sub
	End If
	CloseHandle(hWrite)   '' parent closes write end so ReadFile sees EOF at child exit
	launched = True
	Dim As UByte buf(0 To 4095)
	Do
		Dim As DWORD got
		If ReadFile(hRead, @buf(0), 4096, @got, NULL) = 0 OrElse got = 0 Then Exit Do
		Dim As String chunk = String(got, 0)
		For i As Integer = 0 To got - 1
			chunk[i] = buf(i)
		Next i
		outText &= chunk
		If Len(outText) > 1048576 Then   '' cap runaway output at ~1 MB
			outText &= Chr(10) & "[output truncated at 1 MB]"
			Exit Do
		End If
	Loop
	WaitForSingleObject(pi.hProcess, INFINITE)
	Dim As DWORD ec
	GetExitCodeProcess(pi.hProcess, @ec)
	exitCode = ec
	CloseHandle(hRead) : CloseHandle(pi.hProcess) : CloseHandle(pi.hThread)
	WDeAllocate(cmdW) : WDeAllocate(workW)
End Sub

'' Runs build / syntax_check / run synchronously on the pipe-worker thread and
'' returns the full response line. Compile() self-marshals its UI writes (the
'' menu build runs it on a background thread the same way); reading the results
'' back on this same thread afterwards is race-free. One build at a time.
Private Function AgentHandleBuildCmd(ByRef cmd As String, ByRef idJson As String) As String
	If gAgentBuilding Then
		Return "{""id"":" & idJson & ",""ok"":false,""error"":{""code"":""busy"",""message"":""A build or run is already in progress.""}}"
	End If
	gAgentBuilding = True

	Dim As String param
	Dim As Boolean isRun = False
	Select Case cmd
	Case "syntax_check" : param = "Check"
	Case "run"          : param = "" : isRun = True
	Case Else           : param = ""   '' build
	End Select

	Dim As Integer result = Compile(param, False)
	'' Success = the build ran AND no error-severity problems were reported.
	'' (Compile("Check") returns success even with errors -- see AgentHasBuildErrors.)
	Dim As Boolean buildOk = (result <> 0) AndAlso (Not AgentHasBuildErrors())
	Dim As JsonValue Ptr res = JsonNewObject()

	If cmd = "syntax_check" Then
		res->SetMember("ok", JsonNewBool(buildOk))
		res->SetMember("errors", AgentBuildErrorsArray())
	ElseIf cmd = "run" Then
		res->SetMember("build_ok", JsonNewBool(buildOk))
		res->SetMember("errors", AgentBuildErrorsArray())
		If buildOk Then
			Dim As String outText
			Dim As Integer exitCode
			Dim As Boolean launched, isConsole
			AgentCaptureRun(outText, exitCode, launched, isConsole)
			res->SetMember("started", JsonNewBool(launched))
			res->SetMember("console", JsonNewBool(isConsole))
			If launched Then
				If isConsole Then
					'' Console target: ran to completion, output captured.
					res->SetMember("exit_code", JsonNewNumber(exitCode))
					res->SetMember("output", JsonNewString(AgentDecodeRunOutput(outText)))
				Else
					'' GUI target: launched detached (its window runs until closed); no
					'' console output and no exit code to wait for.
					res->SetMember("note", JsonNewString("GUI program launched; its window runs until closed. No console output to capture."))
				End If
			Else
				res->SetMember("note", JsonNewString("Executable not found after build."))
			End If
		Else
			res->SetMember("started", JsonNewBool(False))
			res->SetMember("note", JsonNewString("Build failed; program not run."))
		End If
	Else   '' build
		res->SetMember("ok", JsonNewBool(buildOk))
		res->SetMember("exit_code", JsonNewNumber(IIf(buildOk, 0, 1)))
		res->SetMember("output", JsonNewString(WStrToUtf8(txtOutput.Text)))
		res->SetMember("errors", AgentBuildErrorsArray())
	End If

	gAgentBuilding = False
	Dim As String resp = "{""id"":" & idJson & ",""ok"":true,""result"":" & JsonSerialize(res) & "}"
	Delete res
	Return resp
End Function

'' The single source file shipped inside a project template folder
'' (Templates/Projects/<template>/), e.g. "Module1.bas". "" if none.
Private Function AgentTemplateMainFile(ByRef templateName As String) As UString
	Dim As UString folder = WinOsPath(ExePath & "/Templates/Projects/" & templateName)
	If Not FolderExistsU(folder) Then Return ""
	Dim As UInteger attr
	Dim As String f = Dir(folder & WindowsSlash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, attr)
	Do While f <> ""
		If (attr And fbDirectory) = 0 AndAlso f <> "." AndAlso f <> ".." Then Return f
		f = Dir(attr)
	Loop
	Return ""
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

	Case "get_errors"
		'' Structured errors parsed from the last build (the Problems list).
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("errors", AgentBuildErrorsArray())
		gCmdOk = True
		gCmdResult = res

	Case "open_project"
		'' Open an existing .vfp (switches the IDE to that project).
		Dim As String rawPath
		If gCmdArgs Then rawPath = gCmdArgs->GetStr("path")
		If rawPath = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "open_project requires a 'path'." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As WString Ptr rawW = Utf8ToWStr(rawPath)
		Dim As UString full = GetFullPathU(*rawW)
		WDeAllocate(rawW)
		If Right(LCase(full), 4) <> ".vfp" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "open_project path must be a .vfp file." : SetEvent(gCmdDone) : Exit Sub
		End If
		If Not FileExistsU(full) Then
			gCmdErrCode = "not_found" : gCmdErrMsg = "Project not found: " & rawPath : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As WString Ptr fw
		WLet(fw, full)
		OpenFiles(*fw)
		WDeAllocate(fw)
		Dim As JsonValue Ptr res = JsonNewObject()
		Dim As ProjectElement Ptr ppe = AgentProject()
		If ppe Then res->SetMember("project", JsonNewString(WStrToUtf8(WGet(ppe->FileName)))) Else res->SetMember("project", JsonNewString(WStrToUtf8(full)))
		gCmdOk = True
		gCmdResult = res

	Case "create_project"
		'' Create a new project from a template under the configured Projects path
		'' and open it. Headless equivalent of the New Project dialog's core (git/
		'' AI/license extras are separate tools / a later unification with the dialog).
		Dim As String nm, template
		If gCmdArgs Then
			nm = Trim(gCmdArgs->GetStr("name"))
			template = Trim(gCmdArgs->GetStr("template"))
		End If
		If template = "" Then template = "Console Application"
		If nm = "" OrElse Not IsValidProjectItemName(nm) Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "create_project needs a valid 'name' (no path or extension)." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As UString templateVfp = WinOsPath(ExePath & "/Templates/Projects/" & template & ".vfp")
		Dim As UString mainFile = AgentTemplateMainFile(template)
		If Not FileExistsU(templateVfp) OrElse mainFile = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "Unknown project template: " & template : SetEvent(gCmdDone) : Exit Sub
		End If
		'' <ProjectsPath>/<name>/ -- ProjectsPath is relative to ExePath by default.
		Dim As WString Ptr ppW
		WLet(ppW, *ProjectsPath)
		Dim As UString projectsRoot = GetFullPath(*ppW)
		WDeAllocate(ppW)
		Dim As UString newFolder = WinOsPath(projectsRoot & "/" & nm)
		If FolderExistsU(newFolder) Then
			gCmdErrCode = "exists" : gCmdErrMsg = "A project folder named '" & nm & "' already exists." : SetEvent(gCmdDone) : Exit Sub
		End If
		If Not EnsureDirectoryExists(newFolder) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not create the project folder." : SetEvent(gCmdDone) : Exit Sub
		End If
		'' Copy the template's main file into the new folder.
		Dim As UString srcMain = WinOsPath(ExePath & "/Templates/Projects/" & template & "/" & mainFile)
		Dim As UString destMain = WinOsPath(newFolder & "/" & mainFile)
		If Not CopyFileU(srcMain, destMain) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not copy the template main file." : SetEvent(gCmdDone) : Exit Sub
		End If
		'' Rewrite the template .vfp: bare main-file reference + ProjectName; write as
		'' <name>.vfp in the new folder.
		Dim As String vfpText = AgentReadFileBytes(templateVfp)
		Dim As String outVfp
		Dim As Integer p = 1
		While p <= Len(vfpText)
			Dim As Integer nl = InStr(p, vfpText, Chr(10))
			Dim As String ln
			If nl = 0 Then ln = Mid(vfpText, p) : p = Len(vfpText) + 1 Else ln = Mid(vfpText, p, nl - p) : p = nl + 1
			Dim As String bare = ln
			If Right(bare, 1) = Chr(13) Then bare = Left(bare, Len(bare) - 1)
			If Left(bare, 6) = "*File=" Then
				ln = "*File=" & mainFile & Chr(13)
			ElseIf Left(bare, 12) = "ProjectName=" Then
				ln = "ProjectName=""" & nm & """" & Chr(13)
			End If
			outVfp &= ln
			If nl <> 0 Then outVfp &= Chr(10)
		Wend
		Dim As UString newVfp = WinOsPath(newFolder & "/" & nm & ".vfp")
		If Not AgentWriteFileBytes(newVfp, outVfp) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not write the project file." : SetEvent(gCmdDone) : Exit Sub
		End If
		'' Open it.
		Dim As WString Ptr vfpW
		WLet(vfpW, newVfp)
		OpenFiles(*vfpW)
		WDeAllocate(vfpW)
		'' Also open the main file in an editor tab, so get_active_file /
		'' set_active_file_content work immediately after creation.
		Dim As WString Ptr mfW
		WLet(mfW, destMain)
		Dim As TabWindow Ptr mtb = GetTab(*mfW)
		If mtb = 0 Then mtb = AddTab(*mfW)
		If mtb Then
			'' BOM-less UTF-8: a UTF-8 BOM makes FreeBASIC treat string literals as
			'' wide, so a saved-with-BOM source prints garbled (wide) console output.
			mtb->FileEncoding = FileEncodings.Utf8
			mtb->SelectTab
		End If
		WDeAllocate(mfW)
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("project", JsonNewString(WStrToUtf8(newVfp)))
		res->SetMember("main_file", JsonNewString(WStrToUtf8(destMain)))
		gCmdOk = True
		gCmdResult = res

	Case "set_active_file_content"
		'' Replace the active editor's text (the "type into the code pane" op).
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then
			gCmdErrCode = "no_active_file" : gCmdErrMsg = "No editor tab is active." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As String content
		Dim As Boolean hasContent = False
		If gCmdArgs Then
			Dim As JsonValue Ptr cv = gCmdArgs->Find("content")
			If cv AndAlso cv->Kind = jkString Then content = cv->StrValue : hasContent = True
		End If
		If Not hasContent Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "set_active_file_content requires 'content'." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As WString Ptr wtext = Utf8ToWStr(content)
		tb->txtCode.Text = *wtext
		WDeAllocate(wtext)
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(tb->FileName)))
		gCmdOk = True
		gCmdResult = res

	Case "open_in_editor"
		Dim As String rawPath
		If gCmdArgs Then rawPath = gCmdArgs->GetStr("path")
		If rawPath = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "open_in_editor requires a 'path'." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As String ec, em
		Dim As UString full = AgentResolveProjectPath(rawPath, ec, em)
		If ec <> "" Then
			gCmdErrCode = ec : gCmdErrMsg = em : SetEvent(gCmdDone) : Exit Sub
		End If
		If Not FileExistsU(full) Then
			gCmdErrCode = "not_found" : gCmdErrMsg = "File not found: " & rawPath : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As WString Ptr fw
		WLet(fw, full)
		Dim As TabWindow Ptr tb = GetTab(*fw)
		If tb = 0 Then tb = AddTab(*fw)
		If tb Then tb->SelectTab
		WDeAllocate(fw)
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(full)))
		gCmdOk = True
		gCmdResult = res

	Case "write_file"
		'' Create/overwrite a file; optionally register it in the .vfp and open it.
		Dim As String rawPath, content
		Dim As Boolean doRegister, doOpen
		If gCmdArgs Then
			rawPath = gCmdArgs->GetStr("path")
			content = gCmdArgs->GetStr("content")
			doRegister = gCmdArgs->GetBool("register")
			doOpen = gCmdArgs->GetBool("open")
		End If
		If rawPath = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "write_file requires a 'path'." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As String ec, em
		Dim As UString full = AgentResolveProjectPath(rawPath, ec, em)
		If ec <> "" Then
			gCmdErrCode = ec : gCmdErrMsg = em : SetEvent(gCmdDone) : Exit Sub
		End If
		'' Ensure the parent folder exists (write_file may target a new subfolder).
		EnsureDirectoryExists(GetFolderNameU(full))
		If Not AgentWriteFileBytes(full, content) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not write file: " & rawPath : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As Boolean registered = False, opened = False
		If doRegister Then registered = AgentRegisterFileInProject(full)
		If doOpen Then
			Dim As WString Ptr fw
			WLet(fw, full)
			Dim As TabWindow Ptr tb = GetTab(*fw)
			If tb = 0 Then
				tb = AddTab(*fw)
				'' BOM-less UTF-8 (a BOM makes FreeBASIC emit wide console output).
				If tb Then tb->FileEncoding = FileEncodings.Utf8
			Else
				'' Already open: sync the editor to what we just wrote (we have the
				'' bytes in hand, so no disk re-read is needed).
				Dim As WString Ptr wtext = Utf8ToWStr(content)
				tb->txtCode.Text = *wtext
				WDeAllocate(wtext)
			End If
			If tb Then tb->SelectTab
			opened = (tb <> 0)
			WDeAllocate(fw)
		End If
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(full)))
		res->SetMember("registered", JsonNewBool(registered))
		res->SetMember("opened", JsonNewBool(opened))
		gCmdOk = True
		gCmdResult = res

	Case "add_file"
		'' New source file from the matching template, registered in the project.
		Dim As String nm, kind
		Dim As Boolean doRegister = True, doOpen = True
		If gCmdArgs Then
			nm = gCmdArgs->GetStr("name")
			kind = LCase(gCmdArgs->GetStr("kind"))
			If gCmdArgs->Find("register") Then doRegister = gCmdArgs->GetBool("register")
			If gCmdArgs->Find("open") Then doOpen = gCmdArgs->GetBool("open")
		End If
		If nm = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "add_file requires a 'name'." : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As String tmplFile, ext
		Select Case kind
		Case "module", "" : tmplFile = "Module.bas"      : ext = ".bas"
		Case "header"     : tmplFile = "Include File.bi" : ext = ".bi"
		Case "form"       : tmplFile = "Form.frm"        : ext = ".frm"
		Case Else
			gCmdErrCode = "bad_args" : gCmdErrMsg = "add_file 'kind' must be module, header, or form." : SetEvent(gCmdDone) : Exit Sub
		End Select
		'' name may already carry the extension; don't double it.
		Dim As String fileName = nm
		If Right(LCase(fileName), Len(ext)) <> ext Then fileName &= ext
		Dim As String ec, em
		Dim As UString full = AgentResolveProjectPath(fileName, ec, em)
		If ec <> "" Then
			gCmdErrCode = ec : gCmdErrMsg = em : SetEvent(gCmdDone) : Exit Sub
		End If
		If FileExistsU(full) Then
			gCmdErrCode = "exists" : gCmdErrMsg = "File already exists: " & fileName : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As UString tmplPath = WinOsPath(ExePath & "/Templates/Files/" & tmplFile)
		If Not CopyFileU(tmplPath, full) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not create file from template: " & fileName : SetEvent(gCmdDone) : Exit Sub
		End If
		Dim As Boolean registered = False, opened = False
		If doRegister Then registered = AgentRegisterFileInProject(full)
		If doOpen Then
			Dim As WString Ptr fw
			WLet(fw, full)
			Dim As Boolean bIsForm = (kind = "form")
			Dim As TabWindow Ptr tb = AddTab(*fw, bIsForm)
			If tb Then tb->SelectTab
			opened = (tb <> 0)
			WDeAllocate(fw)
		End If
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(full)))
		res->SetMember("registered", JsonNewBool(registered))
		res->SetMember("opened", JsonNewBool(opened))
		gCmdOk = True
		gCmdResult = res

	Case "__save_dirty"
		'' Internal (not an MCP tool): flush every modified editor buffer to disk so
		'' the build that follows compiles the agent's edits. UI thread only.
		For j As Integer = 0 To ptabCode->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->Tabs[j])
			If tb <> 0 AndAlso tb->Modified Then
				'' FreeBASIC treats a UTF-8 BOM as a signal to make string literals
				'' wide, so a BOM'd source prints garbled (wide) console output. The
				'' IDE tends to open/save source as Utf8BOM; force BOM-less for the
				'' agent build so create -> edit -> build -> run yields clean output.
				If tb->FileEncoding = FileEncodings.Utf8BOM Then tb->FileEncoding = FileEncodings.Utf8
				tb->Save
			End If
		Next j
		gCmdOk = True

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

	'' Long-running build/run/syntax_check run synchronously on THIS worker thread
	'' (Compile self-marshals its UI writes; the menu build uses the same pattern),
	'' so they never block or reenter the UI-thread slot. Everything else goes
	'' through the single UI-thread command slot below.
	Dim As String cmdEarly = req->GetStr("cmd")
	If cmdEarly = "build" OrElse cmdEarly = "syntax_check" OrElse cmdEarly = "run" Then
		'' Flush unsaved editor buffers to disk FIRST, on the UI thread (Compile reads
		'' from disk). The menu build does this via SaveAllBeforeCompile; the agent
		'' build otherwise compiles stale text after set_active_file_content. Marshal
		'' an internal save into the UI-thread slot and wait for it before compiling.
		gCmdName = "__save_dirty"
		gCmdArgs = 0
		ResetEvent(gCmdDone)
		gCmdPending = True
		PostMessageW(gAgentHwnd, WM_APP_AGENTCMD, 0, 0)
		Dim As HANDLE sw(0 To 1)
		sw(0) = gCmdDone : sw(1) = gAgentStopEvent
		If WaitForMultipleObjects(2, @sw(0), FALSE, INFINITE) <> WAIT_OBJECT_0 Then
			Delete req : Exit Sub   '' shutting down
		End If
		resp = AgentHandleBuildCmd(cmdEarly, idJson)
		Delete req
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
