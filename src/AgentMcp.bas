'###############################################################################
'#  AgentMcp.bas -- astoria-mcp.exe                                            #
'#                                                                             #
'#  The MCP sidecar (Layer A of MCP_SERVER_PLAN.md). A FreeBASIC console app   #
'#  that speaks MCP / JSON-RPC 2.0 over stdio to an MCP client (Claude Code,   #
'#  Claude Desktop, ...) and forwards each tools/call to the running Astoria   #
'#  IDE over the local named pipe \\.\pipe\AstoriaAgent.                        #
'#                                                                             #
'#  This is the ONLY component that tracks the MCP spec; the IDE pipe stays a  #
'#  dumb command channel. Build: see the sidecar step in Compile.bat.          #
'#                                                                             #
'#  stdio transport (MCP spec): newline-delimited JSON-RPC, one object per line #
'#  No embedded newlines. We use the raw Win32 std handles (not the CRT) #
'#  so no text-mode CR/LF translation can corrupt the byte stream.             #
'###############################################################################

#include once "windows.bi"
#include once "JsonLite.bi"

Const AGENT_PIPE_NAME = "\\.\pipe\AstoriaAgent"
Const MCP_SERVER_NAME = "astoria-ide"
Const MCP_SERVER_VERSION = "0.1.0"
Const MCP_DEFAULT_PROTOCOL = "2024-11-05"

Dim Shared hStdIn As HANDLE
Dim Shared hStdOut As HANDLE
Dim Shared gStdinAcc As String       '' leftover bytes between ReadStdinLine calls
Dim Shared gPipeReqId As LongInt     '' monotonic id for pipe requests

'' ---------------------------------------------------------------- stdio

'' Reads one newline-delimited line from stdin (raw bytes, UTF-8). Returns
'' False at end of stream. Trailing CR is stripped for CRLF-writing clients.
Function ReadStdinLine(ByRef outLine As String) As Boolean
	Do
		Dim As Integer nl = InStr(gStdinAcc, Chr(10))
		If nl > 0 Then
			outLine = Left(gStdinAcc, nl - 1)
			If Len(outLine) > 0 AndAlso outLine[Len(outLine) - 1] = 13 Then outLine = Left(outLine, Len(outLine) - 1)
			gStdinAcc = Mid(gStdinAcc, nl + 1)
			Return True
		End If
		Dim As UByte buf(0 To 8191)
		Dim As DWORD got
		If ReadFile(hStdIn, @buf(0), 8192, @got, NULL) = 0 OrElse got = 0 Then
			'' EOF: hand back any final unterminated line once, then stop.
			If Len(gStdinAcc) > 0 Then
				outLine = gStdinAcc : gStdinAcc = "" : Return True
			End If
			Return False
		End If
		Dim As String chunk = String(got, 0)
		For i As Integer = 0 To got - 1
			chunk[i] = buf(i)
		Next i
		gStdinAcc &= chunk
	Loop
End Function

Sub WriteStdoutLine(ByRef s As String)
	Dim As String wbuf = s & Chr(10)
	Dim As DWORD written
	WriteFile(hStdOut, StrPtr(wbuf), Len(wbuf), @written, NULL)
End Sub

'' Diagnostics go to stderr, which MCP clients ignore or log -- never stdout,
'' which carries the protocol.
Sub LogErr(ByRef s As String)
	Dim As String wbuf = "[astoria-mcp] " & s & Chr(10)
	Dim As DWORD written
	WriteFile(GetStdHandle(STD_ERROR_HANDLE), StrPtr(wbuf), Len(wbuf), @written, NULL)
End Sub

'' ---------------------------------------------------------------- pipe client

'' One request/response round-trip to the IDE. Returns False if the pipe can't
'' be reached (IDE not running, or AI agent control disabled).
Function PipeCall(ByRef reqJson As String, ByRef respJson As String) As Boolean
	Dim As HANDLE h = CreateFileW(AGENT_PIPE_NAME, GENERIC_READ Or GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL)
	If h = INVALID_HANDLE_VALUE Then Return False
	Dim As String wbuf = reqJson & Chr(10)
	Dim As DWORD written
	WriteFile(h, StrPtr(wbuf), Len(wbuf), @written, NULL)
	respJson = ""
	Dim As UByte buf(0 To 8191)
	Do
		Dim As DWORD got
		If ReadFile(h, @buf(0), 8192, @got, NULL) = 0 OrElse got = 0 Then Exit Do
		Dim As String chunk = String(got, 0)
		For i As Integer = 0 To got - 1
			chunk[i] = buf(i)
		Next i
		respJson &= chunk
		If InStr(respJson, Chr(10)) > 0 Then Exit Do
	Loop
	CloseHandle(h)
	Dim As Integer nl = InStr(respJson, Chr(10))
	If nl > 0 Then respJson = Left(respJson, nl - 1)
	Return True
End Function

'' ---------------------------------------------------------------- tool table

'' v1 read-only surface (MCP_SERVER_PLAN.md section 3). MCP tool name == pipe
'' cmd name 1:1 for now; the sidecar owns the mapping so either side can evolve.
'' Adding a tool = one row here + its handler on the IDE side.
Type McpTool
	name As String
	description As String
	schema As String     '' inputSchema (JSON Schema), embedded verbatim
End Type

Dim Shared gTools(0 To 14) As McpTool

Sub InitTools()
	Dim As String noArgs = "{""type"":""object"",""properties"":{}}"
	Dim As String pathReq = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Project-relative or absolute path inside the project folder.""}},""required"":[""path""]}"
	gTools(0).name = "get_status"
	gTools(0).description = "Health check and current IDE context: open project, main file, open editor tabs, and whether a build or program is running."
	gTools(0).schema = noArgs
	gTools(1).name = "list_files"
	gTools(1).description = "List the files in the open Astoria project (read from its .vfp manifest), with the main file identified."
	gTools(1).schema = noArgs
	gTools(2).name = "read_file"
	gTools(2).description = "Read a file from the open project. The path is project-relative or an absolute path inside the project folder; paths outside the project are rejected."
	gTools(2).schema = pathReq
	gTools(3).name = "get_active_file"
	gTools(3).description = "Get the path and full text of the currently focused editor tab."
	gTools(3).schema = noArgs
	gTools(4).name = "get_build_output"
	gTools(4).description = "Get the raw text of the IDE Output/messages pane from the last build or run."
	gTools(4).schema = noArgs
	gTools(5).name = "write_file"
	gTools(5).description = "Create or overwrite a file in the open project. Optionally register it in the project (.vfp) and open it in an editor tab. Paths outside the project are rejected."
	gTools(5).schema = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Project-relative or absolute path inside the project folder.""},""content"":{""type"":""string""},""register"":{""type"":""boolean"",""description"":""Add the file to the project manifest (default false).""},""open"":{""type"":""boolean"",""description"":""Open the file in an editor tab (default false).""}},""required"":[""path"",""content""]}"
	gTools(6).name = "add_file"
	gTools(6).description = "Add a new source file to the open project from the matching template. Registered in the project and opened by default."
	gTools(6).schema = "{""type"":""object"",""properties"":{""name"":{""type"":""string"",""description"":""File name, with or without extension.""},""kind"":{""type"":""string"",""enum"":[""module"",""header"",""form""],""description"":""module (.bas), header (.bi), or form (.frm). Default module.""},""register"":{""type"":""boolean""},""open"":{""type"":""boolean""}},""required"":[""name""]}"
	gTools(7).name = "set_active_file_content"
	gTools(7).description = "Replace the full text of the currently focused editor tab."
	gTools(7).schema = "{""type"":""object"",""properties"":{""content"":{""type"":""string""}},""required"":[""content""]}"
	gTools(8).name = "open_in_editor"
	gTools(8).description = "Open (or focus) an editor tab for a project file."
	gTools(8).schema = pathReq
	gTools(9).name = "build"
	gTools(9).description = "Compile the open project. Blocks until the build finishes; returns success, an exit code, the raw build output, and structured errors[]."
	gTools(9).schema = "{""type"":""object"",""properties"":{""all"":{""type"":""boolean"",""description"":""Build all projects (default false).""}}}"
	gTools(10).name = "syntax_check"
	gTools(10).description = "Parse-only syntax check of the open project (no executable produced). Returns success and structured errors[]."
	gTools(10).schema = noArgs
	gTools(11).name = "run"
	gTools(11).description = "Build the open project and run it. Blocks until the program exits; for a console program returns its captured output and exit code. Returns build errors[] if the build fails."
	gTools(11).schema = noArgs
	gTools(12).name = "get_errors"
	gTools(12).description = "Structured errors[] (file, line, severity, message) parsed from the last build."
	gTools(12).schema = noArgs
	gTools(13).name = "create_project"
	gTools(13).description = "Create a new project from a template under the configured Projects folder and open it."
	gTools(13).schema = "{""type"":""object"",""properties"":{""name"":{""type"":""string"",""description"":""Project name (also the folder name); no path or extension.""},""template"":{""type"":""string"",""enum"":[""Console Application"",""Windows Application"",""Dynamic Library"",""Static Library"",""Control Library""],""description"":""Default Console Application.""}},""required"":[""name""]}"
	gTools(14).name = "open_project"
	gTools(14).description = "Open an existing Astoria project by its .vfp path (switches the IDE to that project)."
	gTools(14).schema = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Path to a .vfp project file.""}},""required"":[""path""]}"
End Sub

Function ToolsListJson() As String
	Dim As String s = "["
	For i As Integer = 0 To UBound(gTools)
		If i > 0 Then s &= ","
		s &= "{""name"":""" & JsonEscape(gTools(i).name) & """,""description"":""" & _
			JsonEscape(gTools(i).description) & """,""inputSchema"":" & gTools(i).schema & "}"
	Next i
	Return s & "]"
End Function

Function IsKnownTool(ByRef nm As String) As Boolean
	For i As Integer = 0 To UBound(gTools)
		If gTools(i).name = nm Then Return True
	Next i
	Return False
End Function

'' ---------------------------------------------------------------- JSON-RPC

'' Echo the request id verbatim (number/string/null) into a response.
Function RpcIdJson(req As JsonValue Ptr) As String
	If req = 0 Then Return "null"
	Dim As JsonValue Ptr idv = req->Find("id")
	If idv = 0 Then Return "null"
	Return JsonSerialize(idv)
End Function

Sub SendResult(ByRef idJson As String, ByRef resultJson As String)
	WriteStdoutLine("{""jsonrpc"":""2.0"",""id"":" & idJson & ",""result"":" & resultJson & "}")
End Sub

Sub SendError(ByRef idJson As String, code As Integer, ByRef message As String)
	WriteStdoutLine("{""jsonrpc"":""2.0"",""id"":" & idJson & ",""error"":{""code"":" & Str(code) & _
		",""message"":""" & JsonEscape(message) & """}}")
End Sub

'' A tools/call result carrying text content (isError distinguishes a tool-level
'' failure from a protocol error, per the MCP spec).
Sub SendToolText(ByRef idJson As String, ByRef text As String, isError As Boolean)
	Dim As String r = "{""content"":[{""type"":""text"",""text"":""" & JsonEscape(text) & """}]"
	If isError Then r &= ",""isError"":true"
	r &= "}"
	SendResult(idJson, r)
End Sub

Sub HandleInitialize(req As JsonValue Ptr, ByRef idJson As String)
	'' Echo the client's requested protocol version when present (maximizes
	'' compatibility); otherwise advertise our default.
	Dim As String ver = MCP_DEFAULT_PROTOCOL
	Dim As JsonValue Ptr params = req->Find("params")
	If params Then
		Dim As String rv = params->GetStr("protocolVersion")
		If rv <> "" Then ver = rv
	End If
	Dim As String r = "{""protocolVersion"":""" & JsonEscape(ver) & """,""capabilities"":{""tools"":{}}," & _
		"""serverInfo"":{""name"":""" & MCP_SERVER_NAME & """,""version"":""" & MCP_SERVER_VERSION & """}}"
	SendResult(idJson, r)
End Sub

Sub HandleToolsCall(req As JsonValue Ptr, ByRef idJson As String)
	Dim As JsonValue Ptr params = req->Find("params")
	If params = 0 Then
		SendError(idJson, -32602, "tools/call requires params.")
		Exit Sub
	End If
	Dim As String toolName = params->GetStr("name")
	If toolName = "" Then
		SendError(idJson, -32602, "tools/call requires a tool name.")
		Exit Sub
	End If

	'' Serialize the arguments object (default {}) straight through to the pipe.
	Dim As String argsJson = "{}"
	Dim As JsonValue Ptr argsV = params->Find("arguments")
	If argsV Then argsJson = JsonSerialize(argsV)

	gPipeReqId += 1
	Dim As String pipeReq = "{""id"":" & Str(gPipeReqId) & ",""cmd"":""" & JsonEscape(toolName) & """,""args"":" & argsJson & "}"

	Dim As String pipeResp
	If Not PipeCall(pipeReq, pipeResp) Then
		SendToolText(idJson, "Astoria IDE is not reachable. Start the IDE and enable Tools > Options > Allow AI agent control, then retry.", True)
		Exit Sub
	End If

	'' Translate the IDE's {ok,result|error} into an MCP tool result. The
	'' structured pipe result is returned as JSON text (the agent parses it).
	Dim As JsonValue Ptr resp = JsonParse(pipeResp)
	If resp = 0 Then
		SendToolText(idJson, "Malformed response from Astoria IDE.", True)
		Exit Sub
	End If
	If resp->GetBool("ok") Then
		Dim As JsonValue Ptr r = resp->Find("result")
		Dim As String text = "{}"
		If r Then text = JsonSerialize(r)
		SendToolText(idJson, text, False)
	Else
		Dim As JsonValue Ptr e = resp->Find("error")
		Dim As String code, message
		If e Then
			code = e->GetStr("code")
			message = e->GetStr("message")
		End If
		If message = "" Then message = "Command failed."
		SendToolText(idJson, "[" & code & "] " & message, True)
	End If
	Delete resp
End Sub

Sub HandleMessage(ByRef reqLn As String)
	'' Tolerate a leading UTF-8 BOM some stream writers prepend to the first line.
	If Len(reqLn) >= 3 AndAlso reqLn[0] = &HEF AndAlso reqLn[1] = &HBB AndAlso reqLn[2] = &HBF Then reqLn = Mid(reqLn, 4)
	Dim As JsonValue Ptr req = JsonParse(reqLn)
	If req = 0 OrElse req->Kind <> jkObject Then
		If req Then Delete req
		'' Parse error has no id to echo (JSON-RPC uses null).
		SendError("null", -32700, "Parse error.")
		Exit Sub
	End If

	Dim As String method = req->GetStr("method")
	Dim As Boolean hasId = (req->Find("id") <> 0)
	Dim As String idJson = RpcIdJson(req)

	'' Notifications (no id) never get a response -- includes
	'' notifications/initialized and any notifications/*.
	If Not hasId Then
		Delete req
		Exit Sub
	End If

	Select Case method
	Case "initialize"
		HandleInitialize(req, idJson)
	Case "tools/list"
		SendResult(idJson, "{""tools"":" & ToolsListJson() & "}")
	Case "tools/call"
		HandleToolsCall(req, idJson)
	Case "ping"
		SendResult(idJson, "{}")
	Case Else
		SendError(idJson, -32601, "Method not found: " & method)
	End Select
	Delete req
End Sub

'' ---------------------------------------------------------------- entry

hStdIn = GetStdHandle(STD_INPUT_HANDLE)
hStdOut = GetStdHandle(STD_OUTPUT_HANDLE)
InitTools()
LogErr("astoria-mcp " & MCP_SERVER_VERSION & " started; pipe " & AGENT_PIPE_NAME)

Dim As String reqLn
Do While ReadStdinLine(reqLn)
	If Len(Trim(reqLn)) = 0 Then Continue Do
	HandleMessage(reqLn)
Loop
LogErr("stdin closed; exiting")
