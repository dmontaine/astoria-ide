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
