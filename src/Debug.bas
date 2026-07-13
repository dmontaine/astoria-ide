'#########################################################
'#  Debug.bas                                            #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Laurent GRAS                                #
'#           Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "Debug.bi"

'' Phase 4 dead-code sweep (2026-07-12): removed ~230 lines of Dim Shared globals,
'' custom types (tline/tproc/tprocr/tarr/tvrb/tvrr/ttrckarr/tudt/tcudt/texcld/tthread/
'' tdll/twtch/tbrkol/tbrkv/tedit/tftext/tvarfind/tshwexp/tvrp/tindexdata/tbrclist/
'' udtstab/valeurs), and the 5MB `sourcebuf` -- all state for the removed integrated
'' (stabs) debugger, confirmed dead via a full src/ cross-reference (each symbol
'' checked case-insensitively; no live reader/writer found outside its own
'' declaration). The `blocker` mutex (created + locked once at startup, never
'' unlocked or contended) was equally inert and removed with it.
'' KEPT -- still live, used by the non-debug "Run" path (kill_process/RunWithDebug):
Dim Shared dbghand As HANDLE  		'debugged proc handle
Dim Shared As Boolean prun=False    ''debuggee running
Dim Shared As Integer runtype = RTOFF ''running type
Dim Shared As Boolean flagkill =False 'flag if killing process to avoid freeze in thread_del
Dim Shared exename As WString * 300
Dim Shared mainfolder As WString * 300 'debuggee main folder

'===================================================
'' set/unset breakpoint markers
'===================================================
Function String_to_ZString_Ptr(ByRef s_ZString_Ptr As ZString Ptr) As ZString Ptr
	Return s_ZString_Ptr
End Function

Private Function cutup_names(strg As String) As String
	'"__ZN9TESTNAMES2XXE:S1
	Dim As Integer Pos1 = InStr(strg, ":")
	Dim As String s, strg1 = strg
	Dim As ZString Ptr pz
	If Pos1 > 0 Then strg1 = Left(strg, Pos1 - 2)
	pz = String_to_ZString_Ptr(strg1)
	Do
		Do While (*pz)[0] > Asc("9") OrElse (*pz)[0] < Asc("0")
			If (*pz)[0] = 0 Then Return s
			pz += 1
		Loop
		Dim As Integer N = Val(*pz)
		Do
			pz += 1
		Loop Until (*pz)[0] > Asc("9") OrElse (*pz)[0] < Asc("0")
		If s <> "" Then s &= "."
		s &= Left(*pz, N)
		pz += N
	Loop
	Return s
	'		Dim As Integer p,d
	'		Dim As String nm,strg2,nm2
	'		p=InStr(strg,"_ZN")
	'		strg2=Mid(strg,p+3,999)
	'		p=Val(strg2)
	'		If p>9 Then d=3 Else d=2
	'		nm=Mid(strg2,d,p)
	'		strg2=Mid(strg2,d+p)
	'		p=Val(strg2)
	'		If p>9 Then d=3 Else d=2
	'		nm2=Mid(strg2,d,p)
	'		'Return "NS : "+nm+"."+nm2
	'		Return nm+"."+nm2 '17/01/2015
End Function

Sub DeleteDebugCursor
	If CurEC <> 0 Then
		Var curEC2 = CurEC
		fcurlig = -1
		CurEC->CurExecutedLine = -1
		CurEC = 0
		curEC2->Repaint
	End If
End Sub

Const DEBUG_CMD_QUEUE_SIZE = 32
Dim Shared As String DebugCommandQueue(0 To DEBUG_CMD_QUEUE_SIZE - 1)
Dim Shared As Integer DebugCommandQueueHead = 0
Dim Shared As Integer DebugCommandQueueCount = 0

Sub EnqueueDebugCommand(cmd As String)
	MutexLock tlockGDB
	If DebugCommandQueueCount < DEBUG_CMD_QUEUE_SIZE Then
		Dim As Integer tail = (DebugCommandQueueHead + DebugCommandQueueCount) Mod DEBUG_CMD_QUEUE_SIZE
		DebugCommandQueue(tail) = cmd
		DebugCommandQueueCount += 1
		DbgTrace("ENQ", "cmd=" & DbgTraceEsc(cmd) & " count=" & DebugCommandQueueCount)
	Else
		DbgTrace("ENQ.DROP", "cmd=" & DbgTraceEsc(cmd) & " FULL count=" & DebugCommandQueueCount)
	End If
	MutexUnlock tlockGDB
End Sub

Sub ClearDebugCommandQueue()
	MutexLock tlockGDB
	DebugCommandQueueHead = 0
	DebugCommandQueueCount = 0
	MutexUnlock tlockGDB
End Sub

' Caller must already hold tlockGDB.
Function DequeueDebugCommandLocked() As String
	Dim As String cmd = ""
	If DebugCommandQueueCount > 0 Then
		cmd = DebugCommandQueue(DebugCommandQueueHead)
		DebugCommandQueueHead = (DebugCommandQueueHead + 1) Mod DEBUG_CMD_QUEUE_SIZE
		DebugCommandQueueCount -= 1
	End If
	Return cmd
End Function

' ==== DR Phase 1 debugger trace (instrumentation only; strip after Phase 1) ====
' Uses its own mutex (tlockDbgTrace, created in Main.bas) so it never perturbs
' tlockGDB. bDbgTrace gates it at runtime. Appends one line per event, prefixed
' with GetTickCount + the calling thread id, to Settings\debug_trace.log so the
' worker/UI interleaving (DR-1/3/6/7) and the fcurlig/paint handoff (DR-2/4) are
' visible. DbgTrace only writes -- no behaviour change.
Dim Shared As Boolean bDbgTrace = True

Function DbgTraceEsc(ByRef s As String, ByVal iMax As Integer = 200) As String
	Dim As String r = s
	If Len(r) > iMax Then r = Left(r, iMax) & ".." & "(" & Len(s) & ")"
	r = Replace(r, Chr(13), "\r")
	r = Replace(r, Chr(10), "\n")
	r = Replace(r, Chr(9), "\t")
	r = Replace(r, Chr(26), "<1A>")
	Return r
End Function

Sub DbgTrace(ByRef tag As String, ByRef info As String = "")
	If Not bDbgTrace Then Exit Sub
	If tlockDbgTrace = 0 Then Exit Sub
	MutexLock tlockDbgTrace
	Dim As Integer f = FreeFile
	If Open(ExePath & "\Settings\debug_trace.log" For Append As #f) = 0 Then
		Print #f, GetTickCount() & " tid=" & GetCurrentThreadId() & " [" & tag & "] " & info
		Close #f
	End If
	MutexUnlock tlockDbgTrace
End Sub
' ==== end DR Phase 1 trace ====

	Dim Shared As Long pIn, pOut
	
	Declare Function readpipe(WithoutAnswer As Boolean = False, WithoutShowing As Boolean = False) As String
	Declare Function CreatePipeD(szCmd As WString Ptr , szCmdParam As WString Ptr = 0 , szCmdParam2 As WString Ptr = 0) As Long

	' ==== DR-7 marshal (2026-07-12): worker-thread staging for txtOutput/lvWatches/lvLocals/
	' lvGlobals. See the FlushDebugOutputOnUI comment (near run_debug) for the full rationale;
	' declared here (ahead of readpipe/load_file, both of which queue into this) rather than
	' alongside FlushDebugOutputOnUI since FreeBASIC needs Dim Shared/Sub visible before use.
	Dim Shared As String gPendingOutputText
	Dim Shared As Boolean bOutputPending, bOutputChangeTab
	Dim Shared As Boolean bClearVarPanelsPending
	Dim Shared As Integer gPendingWatchIndex = -1
	Dim Shared As String gPendingWatchResult
	' DR-16: deinit() runs on the worker thread; stage its UI cleanup (toolbar/menu .Enabled
	' writes + the execution-cursor clear/repaint) instead of calling ChangeEnabledDebug/
	' DeleteDebugCursor directly from there. Applied on the UI thread by FlushDebugOutputOnUI.
	Dim Shared As Boolean bDeinitCleanupPending

	' Worker thread. Queue text for the Output pane instead of writing txtOutput directly.
	Sub QueueShowMessages(ByRef msg As String, ChangeTab As Boolean = True)
		gPendingOutputText &= msg & Chr(13, 10)
		If ChangeTab Then bOutputChangeTab = True
		bOutputPending = True
	End Sub

		Declare Sub writepipe(ByRef szBuf As ZString, iTime As Long = 30)
		#define writepipefast writepipe
	Declare Function fill_locals_variables(sBuf As String , iFlagAutoUpdate As Long = 0) As Long
	Declare Sub fill_all_variables(sBuf As String , iFlagUpdate As Long = 0)
	Declare Sub info_all_variables_debug(iFlagUpdate As Long = 0)
	Declare Sub info_loc_variables_debug(iFlagAutoUpdate As Long = 0)
	Declare Sub info_threads_debug(iFlagAutoUpdate As Long = 0)
	Declare Sub deinit()
	
	Dim Shared As Boolean Running, ShowResult
	
	Dim Shared As ZString * 200000 szDataForPipe
	
	Dim Shared As Long iVersionGdb
	
	Dim Shared As String CurrentFile
	
	Dim Shared As Integer iPosStartLast, iPosEndLast, iCurselLast, TimerID, WatchIndex

	Declare Sub continue_debug()
	Declare Sub break_debug()
	
		Dim Shared As HANDLE hReadPipe, hWritePipe
		
			#define pid_t Long
	
		Dim Shared As Integer iGlPid
	
	Dim Shared As Long iFlagThreadSignal, iFlagUpdateVariables
	
	Dim Shared As Long iCounterUpdateVariables, iStateMenu = 1
	Dim Shared As Boolean bPendingDebugPanelRefresh
	
	
	Function GetPartPath(sPath As String) As String
		
		Dim As Long iPos = InStrRev(sPath , "/")
		
		Return Left(sPath , iPos - 1)
		
	End Function
	
	Function CreatePipeD(szCmd As WString Ptr, szCmdParam As WString Ptr = 0 , szCmdParam2 As WString Ptr = 0) As pid_t
		
			
			Dim As STARTUPINFO si
			Dim As PROCESS_INFORMATION pi
			Dim As SECURITY_ATTRIBUTES sa
			Dim As HANDLE hReadChildPipe,hWriteChildPipe
			sa.nLength = Len(sa)
			sa.lpSecurityDescriptor = NULL
			sa.bInheritHandle = True
			
			If CreatePipe(@hReadChildPipe, @hWritePipe, @sa, 0) = 0 Then
				MessageBox(0, "Error creation pipe 1", "", MB_ICONERROR)
			End If
			
			If SetHandleInformation(hWritePipe,HANDLE_FLAG_INHERIT,0) = 0 Then
				MessageBox(0, "Error installing the right not inheritance descriptors for 1 PIPE", "", MB_ICONERROR)
			End If
			
			If CreatePipe(@hReadPipe,@hWriteChildPipe,@sa,0) = 0 Then
				MessageBox(0, "Error creation pipe 2", "", MB_ICONERROR)
			End If
			
			If SetHandleInformation(hReadPipe,HANDLE_FLAG_INHERIT,0) = 0 Then
				MessageBox(0, "Error installing the right not inheritance descriptors for 2 PIPE", "", MB_ICONERROR)
			End If
			
			GetStartupInfo(@si)
			si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
			si.wShowWindow = SW_SHOW
			si.hStdOutput  = hWriteChildPipe
			si.hStdError   = hWriteChildPipe
			si.hStdInput   = hReadChildPipe
			
			' T5 (2026-07-11): quote the program path (szCmd) so a bundled-GDB path that contains a
			' space -- e.g. a portable install unzipped under "C:\My Tools\" -- resolves the intended
			' gdb.exe instead of CreateProcess splitting on the first space and launching the wrong (or
			' no) binary. szCmdParam2 (the exe to debug) is already quoted by the caller; szCmdParam
			' ("-f") has no spaces, so only szCmd needed wrapping.
			If CreateProcess(0, Chr(34) & *szCmd & Chr(34) & " " & *szCmdParam & " " & *szCmdParam2, 0, 0, True, DETACHED_PROCESS, 0, 0, @si, @pi) = 0 Then
				MessageBox(0,"Error creating a child process","",MB_ICONERROR)
			End If
			CloseHandle(hWriteChildPipe)
			CloseHandle(hReadChildPipe)
			'Sleep(300)
			Return pi.dwProcessId
			
		
	End Function
	
	Function readpipe(WithoutAnswer As Boolean = False, WithoutShowing As Boolean = False) As String

		Dim As String sRet
		DbgTrace("READ.enter", "wa=" & WithoutAnswer & " ws=" & WithoutShowing)

			#define BufferSize 2048
			Dim As Integer Count
			Dim sBuffer As ZString * BufferSize
			Dim sOutput As UString
			Dim bytesRead As DWORD
			Dim As DWORD dwAvail
			Dim result_ As Integer
			Dim s As String = ""
			Dim As Integer iNumberOfBytesWritten
			Do
				' R5 (2026-07-08): don't block ReadFile forever on an unresponsive GDB. Poll with
				' PeekNamedPipe first so the debug worker thread bails on app close (FormClosing) or a
				' broken pipe (GDB terminated/crashed) instead of stalling -- the broken-pipe case also
				' fixes a tight infinite loop the old blocking read hit (ReadFile returns 0 bytes
				' repeatedly). Behaviour is unchanged whenever data is actually available.
				Do
					If FormClosing Then DbgTrace("READ.bail", "FormClosing") : Return sOutput
					dwAvail = 0
					If PeekNamedPipe(hReadPipe, NULL, 0, NULL, @dwAvail, NULL) = 0 Then DbgTrace("READ.bail", "peek=0 broken-pipe") : Return sOutput
					If dwAvail > 0 Then Exit Do
					Sleep 5, 1
				Loop
				result_ = ReadFile(hReadPipe, @sBuffer, BufferSize, @bytesRead, ByVal 0)
				sBuffer = Left(sBuffer, bytesRead)
				sOutput += sBuffer
				Count = Count + 1
				'' 2B (DR-6): capture the inferior pid from GDB's "[New Thread PID.TID]" startup line
				'' as soon as it appears. The normal capture (bGetPid via `info inferiors`) only runs
				'' after the first stop -- but a program with no breakpoint runs freely and never stops,
				'' so iGlPid stayed 0 and Stop-while-running had no pid to TerminateProcess. Grab it here
				'' mid-read so kill_inferior_process() works even for a never-stopping inferior.
				If iGlPid = 0 Then
					Dim As Integer iNewThread = InStr(sOutput, "[New Thread ")
					If iNewThread > 0 Then
						Dim As Integer iPidDot = InStr(iNewThread + 12, sOutput, ".")
						If iPidDot > 0 Then iGlPid = Val(Mid(sOutput, iNewThread + 12, iPidDot - (iNewThread + 12)))
					End If
				End If
				If sBuffer = "--Type <RET> for more, q to quit, c to continue without paging--" Then
					writepipe !"\n"
				End If
				If Not WithoutShowing Then
					DbgTrace("SHOWMSG.readpipe", DbgTraceEsc(sBuffer))
					QueueShowMessages(sBuffer, False)
				End If
				'?sBuffer
			Loop While Not (CBool(InStr(sOutput, Chr(10) & "(gdb) ")) OrElse CBool(InStr(sOutput, "~*~(gdb) ")) OrElse IIf(WithoutAnswer, CBool(sOutput = "(gdb) "), StartsWith(sOutput, "(gdb) ") AndAlso CBool(Len(sOutput) > 6 OrElse Count > 1)))
			'WriteFile(hWritePipe, @s, Len(s), Cast(Any Ptr, @iNumberOfBytesWritten), NULL) =  '
			sRet = sOutput
			DbgTrace("READ.ret", "cnt=" & Count & " " & DbgTraceEsc(sRet))

			'		Dim As Integer iTotalBytesAvail,iNumberOfBytesWritten
			'		Dim As String sRet
			'		Static As ZString * 50000 sBuf
			'		For i As Long = 0 To 10000
			'			PeekNamedPipe(hReadPipe, NULL, NULL, NULL, Cast(Any Ptr, @iTotalBytesAvail), NULL)
			'			If iTotalBytesAvail > 0 Then
			'				While iTotalBytesAvail > 0
			'					iTotalBytesAvail = IIf(iTotalBytesAvail > 49999, 49999, iTotalBytesAvail)
			'					memset(@sBuf, 0, 50000)
			'					ReadFile(hReadPipe, @sBuf, iTotalBytesAvail, Cast(Any Ptr, @iNumberOfBytesWritten), NULL)
			'					sRet &= Left(sBuf, iNumberOfBytesWritten)
			'					For i As Long = 0 To 10000
			'						PeekNamedPipe(hReadPipe, NULL, NULL, NULL, Cast(Any Ptr, @iTotalBytesAvail), NULL)
			'						If iTotalBytesAvail Then Exit For
			'					Next
			'				Wend
			'				Return Trim(sRet)
			'			End If
			'		Next
			
		
		Return sRet
		
	End Function
	
		
		Sub writepipe(ByRef s As ZString, iTime As Long = 30)
			Dim As Integer iNumberOfBytesWritten
			Dim As BOOL wok = WriteFile(hWritePipe, @s, Len(s), Cast(Any Ptr, @iNumberOfBytesWritten), NULL)
			DbgTrace("WRITE", "ok=" & wok & " n=" & iNumberOfBytesWritten & " " & DbgTraceEsc(s))
			'Sleep (iTime)
		End Sub
		
	
		
		#undef Updateinfoxserver
		Declare Sub Updateinfoxserver(ic As Long=100)
		Sub Updateinfoxserver(ic As Long=100)
			DbgTrace("Updateinfox", "ic=" & ic & " (DoEvents x" & (ic + 1) & ")")
			For i As Long = 0 To ic
				
				pApp->DoEvents
				
				If ic <= 100 Then
					
					Sleep 1
					
				End If
				
			Next
			
		End Sub
		
	
	Sub run_pipe_write(ByRef s As WString , iTime As Long = 1)
		
		'killtimer(0, TimerID)
		
		writepipe(s, iTime)

	End Sub
	
	Sub paste_updatevar(iFlagStepParam As Long , iFupd As Long)
		
		If iFlagStepParam = 1 Then
			
			Dim As Long iF1 = InStr(szDataForPipe , "~*~")
			
			If iF1 Then
				
				'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF1-1))
				
				ThreadsEnter
				
				ShowMessages Replace(Mid(szDataForPipe, 1, iF1 - 1), Chr(26), "->"), False
				
				fill_locals_variables(Mid(szDataForPipe, iF1 + 3), 1)
				
				ThreadsLeave
				
			Else
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, szDataForPipe)
				If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
				
				ThreadsLeave
				
			End If
			
		ElseIf iFlagStepParam = 2 Then
			
			Dim As Long iF1 = InStr(szDataForPipe , "~*~")
			
			Dim As Long iF2 = InStr(szDataForPipe , "~^~")
			
			If iF1 Then
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF1-1))
				ShowMessages Mid(szDataForPipe , 1 , iF1 - 1), False
				
				fill_all_variables(Mid(szDataForPipe, iF1))
				
				ThreadsLeave
				
			ElseIf iF2 Then
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF2-1))
				ShowMessages Mid(szDataForPipe , 1 , iF2 - 1), False
				
				fill_all_variables(Mid(szDataForPipe , iF2 + 3))
				
				ThreadsLeave
				
			Else
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, szDataForPipe)
				If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
				
				ThreadsLeave
				
			End If
			
		Else
			
			If iStateMenu = 1 Then
				
				Dim As Long iF1 = InStr(szDataForPipe , "~*~")
				
				If iF1 Then
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF1-1))
					ShowMessages Replace(Mid(szDataForPipe, 1, iF1 - 1), Chr(26), "->"), False
					
					fill_locals_variables(Mid(szDataForPipe, iF1 + 3), 1)
					
					ThreadsLeave
					
				Else
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, szDataForPipe)
					If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
					
					ThreadsLeave
					
					If iFupd Then
						
						iFlagUpdateVariables = 1
						
						iCounterUpdateVariables = 0
						
					End If
					
				End If
				
			ElseIf iStateMenu = 2 Then
				
				Dim As Long iF1 = InStr(szDataForPipe , "~*~")
				
				Dim As Long iF2 = InStr(szDataForPipe , "~^~")
				
				If iF1 Then
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF1 - 1))
					ShowMessages Mid(szDataForPipe , 1 , iF1 - 1), False
					
					fill_all_variables(Mid(szDataForPipe , iF1))
					
					ThreadsLeave
					
				ElseIf iF2 Then
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, Mid(szDataForPipe , 1 , iF2-1))
					ShowMessages Mid(szDataForPipe , 1 , iF2 - 1), False
					
					fill_all_variables(Mid(szDataForPipe , iF2 + 3))
					
					ThreadsLeave
					
				Else
					
					ThreadsEnter
					'Pasteeditor(E_EDITOR, szDataForPipe)
					If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
					
					ThreadsLeave
					
					If iFupd Then
						
						iFlagUpdateVariables = 1
						
						iCounterUpdateVariables = 0
						
					End If
					
				End If
				
			Else
				
				ThreadsEnter
				'Pasteeditor(E_EDITOR, szDataForPipe)
				If Len(Trim(szDataForPipe)) Then ShowMessages szDataForPipe, False
				
				ThreadsLeave
				
				If iFupd Then
					
					iFlagUpdateVariables = 1
					
					iCounterUpdateVariables = 0
					
				End If
				
			End If
			
		End If
		
	End Sub
	
	Function line_highlight(iFlagStepParam As Long = 0) As Long

		Dim As Long iFind = InStr(szDataForPipe, Chr(26, 26))
		DbgTrace("line_hl.enter", "annot=" & iFind & " raw=" & DbgTraceEsc(Left(szDataForPipe, 160)))

		If iFind Then
			
				
				Dim As Long iFindColon = InStr(iFind , szDataForPipe , ":\")
				
				If iFindColon Then
					iFindColon = InStr(iFindColon+1 , szDataForPipe , ":")
					
				Else
					iFindColon = InStr(iFind , szDataForPipe , ":")
					
				End If
				
			
			If iFindColon Then
				
				Dim As String sFile = Mid(szDataForPipe , iFind+2 , iFindColon - (iFind+2))
				
				Dim As String sPos , sLine
				
				Dim As Long iFindColon2 = InStr(iFindColon+1 , szDataForPipe , ":")
				
				If iFindColon2 Then
					
					sLine = Mid(szDataForPipe , iFindColon+1 , iFindColon2 - (iFindColon+1))
					
					Dim As Long iFindColon3 = InStr(iFindColon2+1 , szDataForPipe , ":")
					
					If iFindColon3 Then
						
						sPos = Mid(szDataForPipe , iFindColon2 + 1 , iFindColon3 - (iFindColon2 + 1))
						
					End If
					
				End If
				
				If Len(sFile) AndAlso Len(sPos) AndAlso Len(sLine) Then
					'				If LimitDebug Then
					'					?sFile
					'				End If
					CurrentFile = sFile
					fcurlig = Val(sLine)
					DbgTrace("line_hl.parsed", "fcurlig=" & fcurlig & " sFile=" & DbgTraceEsc(sFile) & " sLine=" & DbgTraceEsc(sLine) & " sPos=" & DbgTraceEsc(sPos))
					'				Dim As TabWindow Ptr tb = AddTab(sFile)
					'				If tb Then
					'					ChangeEnabledDebug True, False, True
					'					CurEC = @tb->txtCode
					'					tb->txtCode.CurExecutedLine = Val(sLine) - 1
					'					tb->txtCode.SetSelection Val(sLine) - 1, Val(sLine) - 1, 0, 0
					'					tb->txtCode.PaintControl
					'					info_all_variables_debug()
					'					SetForegroundWindow pApp->MainForm->Handle
					'				End If
					
					'				For i As Long = 0 To UBound(sfiles_array)
					'
					'					If sfiles_array(i) = sFile Then
					'
					'						Panelgadgetsetcursel(E_PANEL , i)
					'
					'						selection_line(i , Val(sPos) , Val(sLine))
					'
					'						Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
					
					paste_updatevar(iFlagStepParam , 1)
					'
					'						Linescrolleditor(E_EDITOR,10000000)
					'
					Return 1
					'
					'					EndIf
					'
					'				Next
					
				End If
				
			End If
			
		Else
			
			Dim As String s = Trim(szDataForPipe)
			
			If Len(s) Then
				
				'' Phase 4 (2026-07-12): removed the dead "[Inferior 1" Else branch here (called
				'' paste_updatevar+deinit) -- unreachable. line_highlight has exactly one live
				'' caller (run_debug's loop; get_read_data's Case 1 that also calls it is itself
				'' dead, never invoked with iFlag=1 by any of its 3 live call sites) and that
				'' caller's own upstream check (InStr(Result, "[Inferior ") > 0 -> deinit+Exit Do)
				'' already intercepts and handles any "[Inferior " text before line_highlight is
				'' ever called with it -- so the AndAlso InStr(s, "[Inferior 1") = 0 term below is
				'' always vacuously true in practice (left as-is; harmless, not worth the extra
				'' risk of rewriting the boolean for a cosmetic simplification).
				If s <> "(gdb)" AndAlso s <> "Continuing." _
					AndAlso InStr(s , "[Inferior 1") = 0 _
					AndAlso InStr(s , "Using the running image of child") = 0  Then

					'				Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
					'
					paste_updatevar(0 , 0)
					'
					'				Linescrolleditor(E_EDITOR,10000000)

					Return 1

				End If
				
			End If
			
		End If
		
	End Function
	
	Dim Shared As ZString * 3 sEndOfLine
	
		sEndOfLine = Chr(13) & Chr(10)
	
	Declare Sub kill_inferior_process()
	Declare Sub get_read_data(iFlag As Long , iFlagAutoUpdate As Long = 0, WithoutShowing As Boolean = False)
	
	Type TGLOBALSVAR
		
		As ZString*1024 szPath
		
		As ZString*256 szVar
		
	End Type
	ReDim Shared As TGLOBALSVAR tgl_var_array(2000)
	
	Sub set_macroses()
		
		Dim As String sMacroGLB
		
		For i As Long = 0 To UBound(tgl_var_array)
			
			If Len(tgl_var_array(i).szVar) Then
				
				iFlagThreadSignal = 0
				
				Dim As Long iF1 = InStrRev(tgl_var_array(i).szVar , " ")
				
				Dim As Long iF2 = InStr(iF1 , tgl_var_array(i).szVar , "[")
				
				If iF2 = 0 Then
					
					iF2 = InStr(iF1 , tgl_var_array(i).szVar , ";")
					
				End If
				
				If iF1 AndAlso iF2 Then
					
					Dim As String sVarTemp = Mid(tgl_var_array(i).szVar , iF1+1 , iF2 - (iF1+1))
					
					sVarTemp = Trim(sVarTemp , Any "* ")
					
					If Len(sVarTemp) Then
						
						sMacroGLB &= !"printf ""~*~""\np " & sVarTemp & !"\n"
						
					End If
					
				End If
				
			Else
				
				Exit For
				
			End If
			
		Next
		
		If Len(sMacroGLB) Then
			
			sMacroGLB &= !"printf ""~*~globalends~*~""\ninfo args\ninfo locals\n"
			
		Else
			
			sMacroGLB = !"printf ""~^~""\ninfo args\ninfo locals\n"
			
		End If
		
		Dim As String s = !"define _g_\n" & sMacroGLB & !"end\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _l_\ninfo args\ninfo locals\nend\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _sg_\ns\n_g_\nend\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _sl_\ns\nprintf ""~*~""\n_l_\nend\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _ng_\nn\n_g_\nend\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
		s = !"define _nl_\nn\nprintf ""~*~""\n_l_\nend\n"
		
		writepipe(s, 100)
		
		'readpipe()
		
		'Updateinfoxserver(10)
		
	End Sub
	
	Function get_global_variables_from_exe(sBuf As String) As Long
		
		Dim As Long iBegin = 1 , iVarFlag , iIndex
		
		Dim As String sFile
		
		Do
			
			Dim As String sLine
			
			Dim As Long iFind = InStr(iBegin , sBuf , Chr(10))
			
			If iFind Then
				
				sLine = Mid(sBuf , iBegin , iFind - iBegin)
				
				If Left(sLine , 5) = "File " Then
					
					sFile = Trim(Mid(sBuf , iBegin+5 , iFind - (iBegin+5)) , Any sEndOfLine & " :")
					
					If LCase(Right(sFile , 4)) = ".bas" OrElse LCase(Right(sFile , 3)) = ".bi" Then
					Else
						sFile = ""
					End If
					
					iVarFlag = 1
					
				ElseIf InStr(sLine , "Non-debugging symbols:") Then
					
					Exit Do
					
				ElseIf iVarFlag = 1 AndAlso Len(sLine) AndAlso Len(sFile) AndAlso sLine <> Chr(13) AndAlso sLine <> Chr(10) Then
					
					If iIndex > UBound(tgl_var_array) Then
						
						ReDim Preserve As TGLOBALSVAR tgl_var_array(iIndex+1000)
						
					End If
					
					If iVersionGdb >= 10 Then
						
						Dim As Long iF1 = InStr(sLine , ":" & Chr(9))
						
						If iF1 Then
							
							sLine = Mid(sLine , iF1+2)
							
						End If
						
					End If
					
					tgl_var_array(iIndex).szPath = sFile
					
					tgl_var_array(iIndex).szVar = sLine
					
					If StartsWith(sLine, "static ") Then sLine = Mid(sLine, 8)
					Var Pos0 = InStr(sLine, ";")
					If Pos0 > 0 Then sLine = Left(sLine, Pos0 - 1)
					Var Pos1 = InStr(sLine, " ")
					Var Pos2 = InStr(sLine, " *")
					If Pos2 > 0 Then Pos1 = Pos2 + 1
					Dim As String VarName = Mid(sLine, Pos1 + 1)
					If StartsWith(VarName, "__Z") Then
						Var Pos3 = InStr(VarName, "[")
						If Pos3 > 0 Then
							VarName = cutup_names(Left(VarName, Pos3 - 1)) & Mid(VarName, Pos3)
						Else
							VarName = cutup_names(VarName)
						End If
					End If
					Var tn = lvGlobals.Nodes.Add(VarName)
					If Pos2 = 0 Then
						tn->Text(2) = Trim(Left(sLine, Pos1 - 1))
					Else
						tn->Text(2) = Trim(Left(sLine, Pos1 - 1)) & " Ptr"
					End If
					
					iIndex+=1
					
				End If
				
				iBegin = iFind+1
				
			Else
				
				Exit Do
				
			End If
			
		Loop
		
		tpGlobals->Caption = ("Globals") & " (" & lvGlobals.Nodes.Count & " " & ("Pos") & ")"
		
		Return iIndex
		
	End Function
	
	Function get_str(sBuf As String , ByRef iBegin As Long) As String
		
		Dim As Long iFind = InStr(iBegin , sBuf , sEndOfLine)
		
		If iFind Then
			
			Function = Mid(sBuf , iBegin , iFind - iBegin)
			
			iBegin = iFind + Len(sEndOfLine)
			
		Else
			
			iBegin = iFind
			
		End If
		
	End Function
	
	Function get_type_str(sLine As String) As Long
		
			
			Dim As Long iFindSpace = InStr(sLine , " ")
			
			If InStr(Mid(sLine , 1 , iFindSpace) , "$") Then
				
				Return 1
				
			ElseIf InStr(sLine , "(gdb)") OrElse InStr(sLine , "No locals.") Then
				
				Return 0
				
			Else
				
				Return 2
				
			End If
			
	End Function
	
	Function fill_threads(sBuf As String, iFlagAutoUpdate As Long = 0) As Long
		
		lvThreads.Nodes.Clear
		
		Dim As UString res()
		
			Split(sBuf, Chr(13, 10), res())
		
		For i As Integer = 0 To UBound(res)
			
			If StartsWith(res(i), "Thread") Then
				lvThreads.Nodes.Insert 0, res(i)
			ElseIf StartsWith(res(i), "#") Then
				Var Pos0 = InStr(res(i), " ")
				Var Pos1 = InStr(res(i), " at ")
				If Pos1 > 0 Then
					Var Pos2 = InStrRev(res(i), ":")
					Var tn = lvThreads.Nodes.Item(0)->Nodes.Add(Mid(Left(res(i), Pos1 - 1), Pos0 + 1))
					tn->Text(1) = Mid(res(i), Pos2 + 1)
					tn->Text(2) = GetFullPath(Mid(res(i), Pos1 + 4, Pos2 - Pos1 - 4))
				Else
					lvThreads.Nodes.Item(0)->Nodes.Add Mid(res(i), Pos0 + 1)
				End If
			End If
			
		Next
		
		If lvThreads.Nodes.Count > 0 Then
			lvThreads.Nodes.Item(0)->Expand
		End If
		tpThreads->Caption = ("Threads") & " (" & lvThreads.Nodes.Count & " " & ("Pos") & ")"
		
		Return 1
		
	End Function
	
	Function fill_locals_variables(sBuf As String , iFlagAutoUpdate As Long = 0) As Long
		
		Dim As Long iBegin = 1 , iBegLast , iType , iFlagStart
		
		Dim As String sNameVar , sValueVar , sBackup , sBufTemp
		
		Static As String sPrevBuf
		
		If iFlagAutoUpdate Then
			
			Dim As Long iLen1 = Len(sBuf) , iLen2 = Len(sPrevBuf)
			
			If iLen1 = iLen2 Then
				
				If memcmp(StrPtr(sBuf) , StrPtr(sPrevBuf) , iLen1) = 0 Then
					
					Return 0
					
				End If
				
			End If
			
			'Deletelistviewitemsall(E_LISTVIEW)
			
			sPrevBuf = sBuf
			
		End If
		
		lvLocals.Nodes.Clear
		
		Dim As Long iCountItems = lvLocals.Nodes.Count, iItem 'Getitemcountlistview(E_LISTVIEW)
		
		If Len(sBuf) = 0 Then Return 0
		
		If Left(sBuf , 13) = "No arguments." Then
			
			sBufTemp = LTrim(Mid(sBuf , 14) , Any Chr(13) & Chr(10) & Chr(9) & " ")
			
		Else
			
			sBufTemp = sBuf
			
		End If
		
		If iCountItems Then
			
			iItem = iCountItems
			
		End If
		
		Do
			
			Dim As String sLine , sNextLine
			
			Do
				
				If iFlagStart Then
					
					If Len(sLine) AndAlso Len(sNextLine) AndAlso iType = 2 Then
						
						sLine &= (sEndOfLine & sNextLine)
						
					ElseIf Len(sLine) = 0 AndAlso Len(sBackup) AndAlso iType = 1 Then
						
						sLine = sBackup
						
					ElseIf iType = 1 Then
						
						sBackup = sNextLine
						
						Exit Do
						
					Else
						
						Exit Do
						
					End If
					
				Else
					
					iFlagStart = 1
					
				End If
				
				sNextLine = get_str(sBufTemp , iBegin)
				
				If Len(sNextLine) Then
					
					iType = get_type_str(sNextLine)
					
				End If
				
				If iBegin = 0 Then
					
					Exit Do
					
				End If
				
			Loop
			
			If iBegLast <> iBegin Then
				
				If Len(sLine) Then
					
					Dim As Long iFindEQ = InStr(sLine , " = ")
					
					sNameVar = Mid(sLine , 1 , iFindEQ - 1)
					
					sValueVar = Mid(sLine , iFindEQ+3)
					
					If iFindEQ Then
						
						Dim As TreeListViewItem Ptr tn
						
						Var Idx = lvLocals.Nodes.IndexOf(sNameVar)
						
						If Idx = -1 Then
							
							tn = lvLocals.Nodes.Add(sNameVar)
							
						Else
							
							tn = lvLocals.Nodes.Item(Idx)
							
						End If
						
						tn->Text(1) = sValueVar
						
						Var Pos1 = InStr(sValueVar, "<vtable for ")
						
						Var Pos2 = InStr(sValueVar, "+")
						
						If Pos1 > 0 AndAlso Pos2 > 0 Then
							
							tn->Text(2) = Replace(Mid(sValueVar, Pos1 + 12, Pos2 - Pos1 - 12), "::", ".")
							
						End If
						
						If StartsWith(sValueVar, "{") AndAlso tn->Nodes.Count = 0 Then
							
							tn->Nodes.Add ""
							
						End If
						
						'					Addlistviewitem(E_LISTVIEW , sNameVar , 0 , iItem , 0)
						'
						'					Addlistviewitem(E_LISTVIEW , sValueVar , 0 , iItem , 1)
						
						iItem+=1
						
					End If
					
				End If
				
				If iBegin Then
					
					iBegLast = iBegin
					
					If iType = 0 Then
						
						Exit Do
						
					End If
					
				Else
					
					Exit Do
					
				End If
				
			Else
				
				Exit Do
				
			End If
			
		Loop
		
		tpLocals->Caption = ("Locals") & " (" & lvLocals.Nodes.Count & " " & ("Pos") & ")"
		
		Return 1
		
	End Function
	
	Sub fill_all_variables(sBuf As String , iFlagUpdate As Long = 0)
		
		Static As String sPrevBuf
		
		If iFlagUpdate Then
			
			'lvVar.Nodes.Clear
			
		Else
			
			If lvGlobals.Nodes.Count Then
				'If Getitemcountlistview(E_LISTVIEW) Then
				
				Dim As Long iLen1 = Len(sBuf) , iLen2 = Len(sPrevBuf)
				
				If iLen1 = iLen2 Then
					
					If memcmp(StrPtr(sBuf) , StrPtr(sPrevBuf) , iLen1) = 0 Then
						
						Exit Sub
						
					End If
					
				End If
				
				'lvVar.Nodes.Clear
				
			End If
			
		End If
		
		Dim As Long iF0 = InStr(sBuf , "~*~globalends~*~")
		
		Dim iItem As Long
		
		'If iF0 Then
		
		Dim As Long iF1 = 4 , iF2
		
		Do
			
			iF2 = InStr(iF1 , sBuf , "~*~")
			
			If iF2 Then
				
				Dim As String sTemp = Mid(sBuf , iF1 , iF2-iF1)
				
				iF1 = iF2+3
				
				Dim As Long iFindEQ = InStr(sTemp , " = ")
				
				If iFindEQ Then
					
					Dim As String sValueVar = Trim(Mid(sTemp , iFindEQ + 3) , Any Chr(13) & Chr(10) & " ")
					
					If iItem <= UBound(tgl_var_array) Then
						
						'						Addlistviewitem(E_LISTVIEW , tgl_var_array(iItem).szVar , 0 , iItem , 0)
						
						'Var Idx = lvGlobals.Nodes.IndexOf(tgl_var_array(iItem).szVar)
						
						'If Idx = -1 Then
						
						'	tn = lvGlobals.Nodes.Add(tgl_var_array(iItem).szVar)
						
						'Else
						
						'	tn = lvGlobals.Nodes.Item(Idx)
						
						'End If
						'
						'						Addlistviewitem(E_LISTVIEW , sValueVar , 0 , iItem , 1)
						
						If iItem < lvGlobals.Nodes.Count Then
							
							Var tn = lvGlobals.Nodes.Item(iItem)
							
							tn->Text(1) = sValueVar
							
							If StartsWith(sValueVar, "{") AndAlso tn->Nodes.Count = 0 Then
								
								tn->Nodes.Add ""
								
							End If
							
						Else
							
							Exit Do
							
						End If
						
						iItem +=1
						
					Else
						
						Exit Do
						
					End If
					
				Else
					
					Exit Do
					
				End If
				
			Else
				
				Exit Do
				
			End If
			
		Loop
		
		'		Dim As String s = Mid(sBuf , iF0+16)
		'
		'		ThreadsEnter
		'
		'		fill_locals_variables(s)
		'
		'		ThreadsLeave
		
		'	Else
		'
		'		If Left(sBuf , 3) = "~^~" Then
		'
		'			Dim As String s = Mid(sBuf , 4)
		'
		'			ThreadsEnter
		'
		'			fill_locals_variables(s)
		'
		'			ThreadsLeave
		'
		'		Else
		'
		'			ThreadsEnter
		'
		'			fill_locals_variables(sBuf)
		'
		'			ThreadsLeave
		'
		'		EndIf
		'
		'	EndIf
		
		sPrevBuf = sBuf
		
	End Sub
	
	
	
	Function get_version_gdb(s As String) As Long
		
		Dim As Long iF1 = InStr(s , "Copyright (C)")
		
		If iF1 Then
			
			Dim As Long iF2 = InStrRev(s , " " , iF1)
			
			If iF2 Then
				
				Dim As Long iF3 = InStr(iF2 , s , ".")
				
				If iF3 Then
					
					Dim As Long iVer = Val(Mid(s , iF2+1 , iF3 - (iF2+1)))
					
					Return iVer
					
				End If
				
			End If
			
		End If
		
	End Function
	
	Function load_file(ByRef sCurentFileExe As WString, ByRef sPathGDB As WString) As Long
		
			'' DR-16(a) (2026-07-12): these two checks are now also run pre-flight on the UI thread by
		'' PrepareDebugSession (AstoriaIDE.bas gates every ThreadCreate_(@StartDebugging) on it), so
		'' in the normal flow this is unreachable. Kept as a defensive fallback in case load_file is
		'' ever reached another way; downgraded from a blocking worker-thread MsgBox (the original
		'' hazard) to the same safe non-blocking QueueShowMessages path DR-7 established -- a modal
		'' dialog from a background thread with no message pump is wrong regardless of how rare the
		'' path is.
		If FileExists(sPathGDB) = 0 Then
			QueueShowMessages(("The debugger could not be found. Try reinstalling the IDE."))
			Return -1
		End If

		If FileExists(sCurentFileExe) = 0 Then
			QueueShowMessages(("The program to debug could not be found. Build the project first."))
			Return -1
		End If
		
		'' DR-7 (2026-07-12): was a direct worker-thread ShowMessages + lvLocals/lvGlobals.Nodes.Clear
		'' (ThreadsEnter/ThreadsLeave are no-ops -- the same unmarshaled-race hazard as the DR-3
		'' freeze). Stage instead; the UI-thread FlushDebugOutputOnUI applies both.
		QueueShowMessages(("Wait, process loading..."))

		bClearVarPanelsPending = True
		
		'Updateinfoxserver(10)
		
		iGlPid = CreatePipeD(sPathGDB,  "-f" , Chr(34) & sCurentFileExe & Chr(34))
		
		'Updateinfoxserver(150)
		
		Dim As String sTemp = readpipe()
		
		If Len(sTemp) Then
			
			iVersionGdb = get_version_gdb(sTemp)
			
		End If
		
		'Updateinfoxserver(30)
		
		writepipe(!"set confirm off\n" , 100)
		
		'Updateinfoxserver(10)
		
		readpipe(True, True)
		
		'Updateinfoxserver(30)
		
		writepipe(!"set lang c\n" , 100)
		
		'Updateinfoxserver(10)
		
		readpipe(True, True)
		
		writepipe(!"set width 0\n" , 100)
		
		readpipe(True, True)
		
		writepipe(!"set height 0\n" , 100)
		
		readpipe(True, True)
		
		'Updateinfoxserver(10)
		
		'writepipe(!"info sources\n" , 100)
		
		'Updateinfoxserver(30)
		
		'sTemp = readpipe()
		
		'If Len(sTemp) Then
		
		'get_name_files_from_exe(sTemp)
		
		'EndIf
		
		'Updateinfoxserver(10)
		
		writepipe(!"info variables\n" , 100)
		
		'Updateinfoxserver(30)
		
		sTemp = readpipe(, True)
		
		If Len(sTemp) Then
			
			get_global_variables_from_exe(sTemp)
			
		End If
		
		set_macroses()
		
		'Updateinfoxserver(60)
		
		'	writepipe(!"info functions\n" , 100)
		'
		'	Updateinfoxserver(10)
		'
		'	sTemp = readpipe()
		'
		'	If Len(sTemp) Then
		'
		'		get_main_file_from_exe(sTemp)
		'
		'		If iIndexMainFile <> 0 Then
		'
		'			Dim As String sTemp = sfiles_array(iIndexMainFile)
		'
		'			Dim As String sTemp2 = sfiles_array(0)
		'
		'			sfiles_array(0) = sTemp
		'
		'			sfiles_array(iIndexMainFile) = sTemp2
		'
		'			iIndexMainFile = 0
		'
		'		EndIf
		'
		'	EndIf
		
		'Setwindowtext(pd.mDLG , sFileTemp)
		
		'	Updateinfoxserver(5)
		
	End Function
	
	'' ==== 2C (DR-10) breakpoint-number map ==================================================
	'' GDB's "clear LINESPEC" does NOT match a breakpoint set via break "<fullpath>":<line> on this
	'' toolchain -- verified with gdb 11.2 on Module1.exe: clear by full path, by lowercase basename,
	'' and even by the exact uppercased "MODULE1.BAS:20" that `info breakpoints` prints all return
	'' "No breakpoint at ..." (FB emits an uppercased DWARF source name that clear won't resolve).
	'' Only "delete <N>" reliably removes it. So we record the GDB breakpoint number parsed from each
	'' "Breakpoint N at ..." reply, keyed by the linespec, and delete by number on clear.
	'' Worker-thread-only (run_debug arming loop + the loop's armbp branch) -> no lock needed.
	Const BP_MAP_MAX = 256
	Dim Shared As String gBpKey(0 To BP_MAP_MAX - 1)
	Dim Shared As Integer gBpNum(0 To BP_MAP_MAX - 1)
	Dim Shared As Integer gBpMapCount

	Sub BpMapReset()
		gBpMapCount = 0
	End Sub

	Function NormBpKey(ByRef linespec As String) As String
		Return UCase(Trim(linespec, Any Chr(10, 13, 32)))
	End Function

	'' Parse the GDB number from a "Breakpoint N at ..." / "Temporary breakpoint N at ..." reply.
	'' Skips a leading "Note: breakpoint M also set at ..." line (matches the real one, not the Note).
	Function ParseBpNumber(ByRef s As String) As Integer
		Dim As Long p = InStr(s, "Temporary breakpoint ")
		If p > 0 Then Return Val(Mid(s, p + Len("Temporary breakpoint ")))
		p = InStr(s, "Breakpoint ")
		If p > 0 Then Return Val(Mid(s, p + Len("Breakpoint ")))
		Return 0
	End Function

	Sub BpMapPut(ByRef linespec As String, ByVal num As Integer)
		If num <= 0 Then Exit Sub
		Dim As String k = NormBpKey(linespec)
		For i As Integer = 0 To gBpMapCount - 1
			If gBpKey(i) = k Then gBpNum(i) = num : Exit Sub
		Next
		If gBpMapCount < BP_MAP_MAX Then
			gBpKey(gBpMapCount) = k
			gBpNum(gBpMapCount) = num
			gBpMapCount += 1
		End If
	End Sub

	'' Return the recorded GDB number for a linespec and remove the entry (0 if not tracked).
	Function BpMapTake(ByRef linespec As String) As Integer
		Dim As String k = NormBpKey(linespec)
		For i As Integer = 0 To gBpMapCount - 1
			If gBpKey(i) = k Then
				Dim As Integer n = gBpNum(i)
				For j As Integer = i To gBpMapCount - 2
					gBpKey(j) = gBpKey(j + 1) : gBpNum(j) = gBpNum(j + 1)
				Next
				gBpMapCount -= 1
				Return n
			End If
		Next
		Return 0
	End Function

	'' The linespec portion of an enqueued "break <spec>\n" / "clear <spec>\n" command.
	Function BpLinespec(ByRef cmd As String) As String
		Dim As Long p = InStr(cmd, " ")
		If p = 0 Then Return ""
		Return Trim(Mid(cmd, p + 1), Any Chr(10, 13, 32))
	End Function

	'' 2C (DR-1/DR-10, 2026-07-12): the single arm-during-debug path for ALL breakpoint toggles
	'' (menu, F9, gutter-click). Called from EditControl.Breakpoint AFTER the marker is toggled,
	'' with bpOn = the marker's NEW state (True = a breakpoint now exists on this line -> arm it in
	'' GDB; False = it was just removed -> clear it). Replaces set_bp's direct UI-thread pipe write
	'' (the DR-1 race): we ENQUEUE the break/clear so the debug worker -- the single owner of the
	'' pipe -- applies it at a safe point (its lockstep loop only dequeues while the inferior is
	'' stopped at the prompt, and run_debug handles break/clear without running the inferior). When
	'' not debugging this is a no-op: the editor marker alone is enough and run_debug re-sends every
	'' editor breakpoint on the next launch. File/line are derived exactly as set_bp did.
	Sub arm_breakpoint(bpOn As Boolean, Temporary As Boolean = False)

		If iFlagStartDebug <> 1 Then Exit Sub

		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub

		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar

		Dim As String sTemp = """" & Replace(tb->FileName, "\", "/") & """:" & iSelEndLine + 1

		If Temporary Then
			'' Run-to-cursor: a one-shot breakpoint at the caret, followed by continue_debug's 'c'.
			'' Enqueued (not direct-written) so it stays in FIFO order ahead of the 'c' and the worker
			'' -- not the UI thread -- owns the pipe.
			DbgTrace("arm_breakpoint.enqueue", "tbreak " & DbgTraceEsc(sTemp))
			EnqueueDebugCommand !"tbreak " & sTemp & !"\n"
		ElseIf bpOn Then
			DbgTrace("arm_breakpoint.enqueue", "break " & DbgTraceEsc(sTemp))
			EnqueueDebugCommand !"break " & sTemp & !"\n"
		Else
			DbgTrace("arm_breakpoint.enqueue", "clear " & DbgTraceEsc(sTemp))
			EnqueueDebugCommand !"clear " & sTemp & !"\n"
		End If

	End Sub

	'Sub selection_line(iCursel As Integer , iPos As Integer , iLine As Integer)
	'
	'	If iCursel > UBound(pd.sci) OrElse iCursel < 0 Then Exit Sub
	'
	'	sendmessage ( Cast(Any Ptr , pd.sci(iCurselLast)) ,  SCI_INDICATORCLEARRANGE , iPosStartLast , iPosEndLast - iPosStartLast)
	'
	'	Dim As Integer iEndPos = sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_GETLINEENDPOSITION , iLine-1 , 0)
	'
	'	iPosEndLast = iEndPos
	'
	'	iPosStartLast = iPos
	'
	'	iCurselLast = iCursel
	'
	'	sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_INDICATORFILLRANGE , iPos , iEndPos - iPos)
	'
	'	SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_SETFIRSTVISIBLELINE, iLine, 0)
	'
	'	If (iLine - Cast(Integer , SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_GETFIRSTVISIBLELINE, 0, 0)) + 5) >= (SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_LINESONSCREEN, 0, 0)) Then
	'
	'		SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_LINESCROLL, 0, Cast(Integer , 5))
	'
	'	Else
	'
	'		SendMessage(Cast(Any Ptr , pd.sci(iCursel)), SCI_LINESCROLL, 0, Cast(Integer ,-5))
	'
	'	End If
	'
	'End Sub
	
	Sub get_read_data(iFlag As Long , iFlagAutoUpdate As Long = 0, WithoutShowing As Boolean = False)
		
		szDataForPipe = readpipe(, WithoutShowing)
		
		If Len(szDataForPipe) Then
			
			Select Case iFlag
				
			Case 1
				
				line_highlight(iFlagAutoUpdate)
				
			Case 2
				
				ThreadsEnter
				
				fill_all_variables(szDataForPipe , iFlagAutoUpdate)
				
				ThreadsLeave
				
			Case 3
				
				ThreadsEnter
				
				fill_locals_variables(szDataForPipe , iFlagAutoUpdate)
				
				ThreadsLeave
				
			Case 4
				
				ThreadsEnter
				
				fill_threads(szDataForPipe , iFlagAutoUpdate)
				
				ThreadsLeave
				
			Case Else
				
				iFlagThreadSignal = iFlag
				
			End Select
			
		Else
			
			iFlagThreadSignal = 13
			
		End If
		
	End Sub
	
	Sub UpdateWatch(WatchIndex As Integer, Text As String)
		Dim As String Result = Text
		Var Pos1 = InStr(Result, "=")
		If Pos1 > 0 Then Result = Trim(Mid(Result, Pos1 + 1))
		If StartsWith(Result, "(gdb)") Then Result = Trim(Mid(Result, 6))
			If StartsWith(Result, Chr(13, 10)) Then Result = Trim(Mid(Result, 3))
		If EndsWith(Result, "(gdb)") Then Result = Trim(Left(Result, Len(Result) - 5))
		If EndsWith(Result, "(gdb) ") Then Result = Trim(Left(Result, Len(Result) - 6))
			If EndsWith(Result, Chr(13, 10)) Then Result = Trim(Left(Result, Len(Result) - 2))
		If Result = "" Then Result = "No symbol """ & UCase(lvWatches.Nodes.Item(WatchIndex)->Text(0)) & """ in current context."
		lvWatches.Nodes.Item(WatchIndex)->Text(1) = Result
		If StartsWith(Result, "{") Then lvWatches.Nodes.Item(WatchIndex)->Nodes.Add Else lvWatches.Nodes.Item(WatchIndex)->Nodes.Clear
	End Sub
	
	' ==== 2D marshal (2026-07-11): worker reads raw GDB panel output; the UI thread fills controls ====
' ThreadsEnter/ThreadsLeave are no-ops (Component.bas:257), so the worker touching lvLocals/lvGlobals/
' lvThreads/lvWatches directly races the UI thread -- that is the DR-3 freeze (fill_locals vs the UI
' thread's AddTab). The worker now only does pipe I/O and stores the raw replies here; the UI-thread
' heartbeat TimerProcGDB calls FillDebugPanelsOnUI to parse+fill on the UI thread.
Const DBG_WATCH_MAX = 64
Dim Shared As String gRawLocals, gRawGlobals, gRawThreads
Dim Shared As Boolean gHasGlobals
Dim Shared As String gWatchNameSnap(DBG_WATCH_MAX - 1), gRawWatch(DBG_WATCH_MAX - 1)
Dim Shared As Integer gWatchSnapCount
Dim Shared As Boolean bPanelFillPending

' UI thread only. Refresh the worker-visible snapshot of watch names so the worker never reads
' lvWatches. Call from every watch-list mutation site (add/remove/rename/clear).
Sub SnapshotWatchNames()
	Dim As Integer n = lvWatches.Nodes.Count
	If n > DBG_WATCH_MAX Then n = DBG_WATCH_MAX
	For i As Integer = 0 To n - 1
		gWatchNameSnap(i) = lvWatches.Nodes.Item(i)->Text(0)
	Next
	gWatchSnapCount = n
End Sub

' UI thread only (called every TimerProcGDB tick; cheap no-op unless the worker staged data).
Sub FillDebugPanelsOnUI()
	If Not bPanelFillPending Then Exit Sub
	bPanelFillPending = False
	fill_locals_variables(gRawLocals, 0)
	If gHasGlobals Then fill_all_variables(gRawGlobals, 0)
	fill_threads(gRawThreads, 0)
	For i As Integer = 0 To gWatchSnapCount - 1
		If Trim(gWatchNameSnap(i)) <> "" Then UpdateWatch i, gRawWatch(i)
	Next
End Sub

' Worker thread. Read-only: send each panel query, store the raw GDB reply, flag the UI thread to
' fill. No UI-control access here (that direct access was the DR-3 freeze).
Sub RefreshDebugPanelsAfterStop()
	run_pipe_write(!"_l_\n")
	gRawLocals = readpipe(, True)
	gHasGlobals = (iStateMenu = 2)
	If gHasGlobals Then
		run_pipe_write(!"_g_\n")
		gRawGlobals = readpipe(, True)
	End If
	run_pipe_write(!"thread apply all bt\n")
	gRawThreads = readpipe(, True)
	For i As Integer = 0 To gWatchSnapCount - 1
		If Trim(gWatchNameSnap(i)) = "" Then
			gRawWatch(i) = ""
		Else
			writepipe "print " & UCase(gWatchNameSnap(i)) & !"\n"
			gRawWatch(i) = readpipe(, True)
		End If
	Next
	bPanelFillPending = True
End Sub

' ==== DR-7 marshal (2026-07-12): worker never touches txtOutput/lvWatches/lvLocals/lvGlobals
' directly. Residual from the 2D audit -- readpipe's own ShowMessages, run_debug's loop-body
' ShowMessages calls, load_file's session-start panel clear, and the watch-edit result all ran
' unmarshaled on the worker (same hazard class as the DR-3 freeze, just never observed hanging
' here since these are lower-collision-probability than the per-step panel refresh 2D fixed).
' The worker now only stages text/flags (gPendingOutputText etc., declared near readpipe() at the
' top of this file since readpipe/load_file call QueueShowMessages before this point in the
' source); the UI-thread heartbeat TimerProcGDB calls FlushDebugOutputOnUI to apply them.
' UI thread only (called every TimerProcGDB tick; cheap no-op unless the worker staged data).
Sub FlushDebugOutputOnUI()
	If bClearVarPanelsPending Then
		bClearVarPanelsPending = False
		lvLocals.Nodes.Clear
		lvGlobals.Nodes.Clear
	End If
	If bDeinitCleanupPending Then
		' DR-16: mirrors deinit()'s original direct calls, just moved to the UI thread. Order
		' preserved (cursor clear before the toolbar/menu state update).
		bDeinitCleanupPending = False
		DeleteDebugCursor
		ChangeEnabledDebug True, False, False
	End If
	If bOutputPending Then
		Dim As String sText = gPendingOutputText
		Dim As Boolean bTab = bOutputChangeTab
		gPendingOutputText = ""
		bOutputPending = False
		bOutputChangeTab = False
		ShowMessages sText, bTab
	End If
	If gPendingWatchIndex <> -1 Then
		UpdateWatch gPendingWatchIndex, gPendingWatchResult
		gPendingWatchIndex = -1
	End If
End Sub

	Sub run_debug(iFlag As Long)
		
		iFlagThreadSignal = 0
		
		If iFlag Then

			iGlPid = 0
			
			'killtimer(0, TimerID)
			
			'If runtype = RTSTEP Then
			
			'' DR-8 (2026-07-11): don't break at the program entry. 'b 1' stopped at the very
			'' first source line, which for a framework app is an #include's module-init
			'' (e.g. Brush.bas) -- not the user's code. Run to the user's breakpoints instead
			'' (or run freely if there are none). Removed: writepipe(!"b 1\n") + readpipe().
			
			'End If
			
			If RunningToCursor Then
				Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
				If tb <> 0 Then
					Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
					tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
					writepipe("tbreak """ & Replace(tb->FileName, "\", "/") & """:" & Str(iSelEndLine + 1) & !"\n")
					readpipe()
				End If
				RunningToCursor = False
			End If
			
			'' 2C (DR-10): fresh GDB session -> breakpoint numbers restart at 1, so reset the map, then
			'' record each pre-run breakpoint's number keyed by its linespec (so a later toggle-off can
			'' delete it by number -- "clear LINESPEC" does not work on this toolchain).
			BpMapReset()
			Dim As TabWindow Ptr tb
			For jj As Integer = 0 To TabPanels.Count - 1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
				For i As Integer = 0 To ptabCode->TabCount - 1
					tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
					For j As Integer = 0 To tb->txtCode.Content.Lines.Count - 1
						If Not Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[j])->Breakpoint Then Continue For

						Dim As String sSpec = """" & Replace(tb->FileName, "\", "/") & """:" & WStr(j + 1)
						writepipe(!"break " & sSpec & !"\n")
						BpMapPut(sSpec, ParseBpNumber(readpipe()))
					Next
				Next i
			Next jj

			'run_pipe_write(!"r\n" , 300)
			writepipe !"r\n"

			MutexLock tlockGDB
			Dim As String Result
			Dim As Boolean bGetPid = True
			Dim As Boolean bGDBLocked = True
			Var Pos1 = 0
			Running = True
			Do
				Dim As String cmd
				' 2A lockstep (DR-3): only pull the next queued command once the previous command's
				' stop has been read (Not Running) and its panel refresh has run (Not pending).
				' Sending a step mid-cycle desyncs the pipe -- RefreshDebugPanelsAfterStop's _l_ read
				' then swallows the new step's stop annotation and the next readpipe blocks forever.
				If (Not Running) AndAlso (Not bPendingDebugPanelRefresh) Then cmd = DequeueDebugCommandLocked()
				If cmd <> "" Then
					DbgTrace("LOOP.send", "cmd=" & DbgTraceEsc(cmd) & " Running(before)=" & Running & " qleft=" & DebugCommandQueueCount)
					If Not bGDBLocked Then MutexLock tlockGDB: bGDBLocked = True
					If cmd = !"q\n" Then
						QueueShowMessages(("Debugging finished."))
						If bGDBLocked Then MutexUnlock tlockGDB: bGDBLocked = False
						deinit
						Exit Do
					ElseIf StartsWith(cmd, "break ") OrElse StartsWith(cmd, "tbreak ") OrElse StartsWith(cmd, "clear ") Then
						'' 2C (DR-1/DR-10): a mid-session breakpoint arm/clear enqueued by arm_breakpoint.
						'' GDB applies it at the prompt WITHOUT running the inferior, so read the prompt
						'' reply and stay stopped -- do NOT set Running, highlight, or refresh panels (those
						'' are for a real stop). The worker (single pipe owner) doing this in lockstep is what
						'' dissolves the DR-1 race: the UI thread never touches the pipe. Only ever dequeued
						'' while Not Running (stopped at the prompt), so the read returns promptly.
						DbgTrace("LOOP.armbp", DbgTraceEsc(cmd))
						If StartsWith(cmd, "clear ") Then
							'' DR-10 clear bug: "clear LINESPEC" never matches on this toolchain; delete the
							'' breakpoint by the GDB number we recorded when it was set (see the BpMap notes).
							Dim As Integer bn = BpMapTake(BpLinespec(cmd))
							If bn > 0 Then
								DbgTrace("LOOP.armbp.delete", "num=" & bn)
								writepipe("delete " & bn & !"\n")
								'' "delete N" is SILENT in -f (fullname) mode: it emits only a bare "(gdb) "
								'' prompt with no leading newline or text. readpipe must be told WithoutAnswer=True
								'' so it terminates on an exact "(gdb) "; the default (False) waits for "\n(gdb) "
								'' or a >6-char prompt and would spin forever on the 6-char bare prompt (freeze).
								readpipe(True, True)
							Else
								'' Not tracked (never armed in GDB) -- the literal clear is a harmless no-op.
								writepipe(cmd)
								readpipe(, True)
							End If
						Else
							writepipe(cmd)
							Dim As String rbp = readpipe(, True)
							'' Record the number only for a real "break" (a "tbreak" run-to-cursor is one-shot
							'' and auto-deletes, so it never needs a later clear).
							If StartsWith(cmd, "break ") Then BpMapPut(BpLinespec(cmd), ParseBpNumber(rbp))
						End If
						'' Release the lock before looping: an arm/clear does NOT set Running, so it never
						'' passes through the read branch that would release it. Leaving it held would keep
						'' tlockGDB locked through the idle-stopped Sleep, and the UI thread's next
						'' EnqueueDebugCommand (e.g. Continue/Step) would block on it forever -- freezing the
						'' IDE. The idle-stopped invariant is: lock free so the UI thread can enqueue.
						If bGDBLocked Then MutexUnlock tlockGDB: bGDBLocked = False
						Continue Do
					Else
						writepipe(cmd)
					End If
					Running = True
				ElseIf bPendingDebugPanelRefresh Then
					DbgTrace("LOOP.refresh", "")
					bPendingDebugPanelRefresh = False
					If Not bGDBLocked Then MutexLock tlockGDB: bGDBLocked = True
					RefreshDebugPanelsAfterStop()
					If bGDBLocked Then MutexUnlock tlockGDB: bGDBLocked = False
				ElseIf Running Then
					DbgTrace("LOOP.read.begin", "")
					If bGDBLocked Then MutexUnlock tlockGDB: bGDBLocked = False
					Result = readpipe(True)
					If Not bGDBLocked Then MutexLock tlockGDB: bGDBLocked = True
					If bGetPid Then
							
							'Updateinfoxserver(10)
							
							'killtimer(0, TimerID)
							
							writepipe(!"info inferiors\n")
							
							'Updateinfoxserver(10)
							
							Dim As String s = readpipe()
							Result = Result & s
							'' DR-14 (2026-07-12): decide whether a live inferior exists BEFORE the pid parse
							'' below mangles s. "info inferiors" shows "process NNNN" for a running inferior
							'' and "<null>" for a dead one. If the program already exited at this first stop
							'' (ran to completion or was terminated with no breakpoint bound), continuing or
							'' refreshing panels against it hangs the worker forever on thread-apply-all-bt --
							'' the DR-14 hang. This is the reliable signal: this GDB's exit line here was
							'' "Program exited...", which the [Inferior/not-being-run string check below misses.
							Dim As Boolean bInferiorDead = (Len(s) > 0) AndAlso (InStr(s, " process ") = 0)

							If Len(s) Then
								
								Dim As Long iF1 = InStr(s, " process ")
								
								If iF1 Then
									
									s = Trim(Mid(s , iF1+9))
									
									Dim As Long iF1 = InStr(s, " ")
									
									If iF1 Then
										
										s = Trim(Mid(s , 1 ,  iF1-1))
										
										iGlPid =  Val(s)
										
									End If
									
								End If
								
							End If
						bGetPid = False
						If bInferiorDead Then
							'' DR-14: program already gone at the first stop -- shut the session down cleanly
							'' on the worker (single pipe owner) instead of 'c'/refresh against a dead inferior.
							DbgTrace("LOOP.inferiorGone", "info inferiors: no live process")
							QueueShowMessages(Result)
							deinit
							bGDBLocked = False   '' deinit released tlockGDB
							Exit Do
						End If
						If runtype <> RTSTEP Then
							writepipe(!"c\n")
							Running = True
							Continue Do
							'					Else
							'						Result = readpipe
						End If
					End If
					If ShowResult Then
						QueueShowMessages(Result)
						ShowResult = False
					End If
					szDataForPipe = Result
					Running = False
					If (InStr(Result, "[Inferior ") > 0) OrElse (InStr(Result, "not being run") > 0) OrElse (InStr(Result, "Program exited") > 0) Then
						'' 2B (DR-6) + DR-14: the inferior has exited or been terminated -- either it
						'' ran to completion / crashed on its own (DR-14), or Stop-while-running just
						'' killed it (kill_inferior_process). Do NOT fall through to the panel refresh:
						'' RefreshDebugPanelsAfterStop would send _l_/thread-apply-all-bt to a dead
						'' program and block forever reading a reply that never comes (the DR-14 hang).
						'' Shut the session down cleanly right here on the worker thread (which owns the
						'' pipe): deinit closes the handles + quits GDB, then leave the loop.
						DbgTrace("LOOP.inferiorGone", DbgTraceEsc(Left(Result, 80)))
						QueueShowMessages(Result)
						deinit
						bGDBLocked = False   '' deinit released tlockGDB
						Exit Do
					End If
					If WatchIndex <> -1 Then
						'' DR-7 (2026-07-12): was a direct worker-thread UpdateWatch call (touches
						'' lvWatches -- the same hazard the 2D marshal fixed for the panel refresh
						'' path). Stage instead; FlushDebugOutputOnUI applies it on the UI thread.
						gPendingWatchIndex = WatchIndex
						gPendingWatchResult = Result
						WatchIndex = -1
					Else
						fcurlig = -2
						line_highlight iStateMenu : DbgTrace("LOOP.afterstop", "fcurlig=" & fcurlig)
						If iFlagStartDebug = 0 Then
							If bGDBLocked Then MutexUnlock tlockGDB: bGDBLocked = False
							Exit Do
						End If
						'Updateinfoxserver(100)  ' DR-13/2D (2026-07-11): removed off-thread DoEvents x101 on the worker. It dispatched the pending F8 WM_KEYDOWN without TranslateAccelerator (step swallowed) and reentered the message loop off-thread (DR-3 deadlock aggravator). Highlight still fires via TimerProcGDB (UI thread); panels via bPendingDebugPanelRefresh next iteration.
						bPendingDebugPanelRefresh = True
					End If
					If bGDBLocked Then MutexUnlock tlockGDB: bGDBLocked = False
				Else
					Sleep(1, 1)
				End If
			Loop
			
			Running = False
			bGetPid = False
			
		Else

		End If
		
	End Sub
	
	Sub continue_debug()
		
		'	iFlagThreadSignal = 0
		'
		'	memset(@szDataForPipe , 0 , 200000)
		
		DeleteDebugCursor
		
		EnqueueDebugCommand !"c\n"
		
	End Sub
	
	Sub break_debug()

		MutexLock tlockGDB
		writepipe(!"interrupt\n")
		MutexUnlock tlockGDB

	End Sub

	'' 2B (DR-6): terminate the running inferior process directly. Used by Stop-while-running
	'' (Case "End"): GDB won't act on "interrupt" in all-stop synchronous mode while the inferior
	'' runs (it isn't reading its stdin), so killing the process is the only way to unblock the
	'' worker's blocked readpipe. This touches ONLY the inferior process handle -- never the GDB
	'' pipe/handles/tlockGDB -- so it's race-free wrt the worker. The worker sees GDB report the
	'' exit and shuts down via the loop's inferior-gone branch.
	Sub kill_inferior_process()
		If iGlPid Then
			Var h = OpenProcess(PROCESS_ALL_ACCESS , 0 , iGlPid)
			If h Then TerminateProcess(h , 1) : CloseHandle(h)
		End If
	End Sub
	
	Sub setvalue_debug(sNewValue As String)
		
		iFlagThreadSignal = 0
		
		memset(@szDataForPipe , 0 , 200000)
		
		run_pipe_write(sNewValue)
		
		readpipe()
		
		iFlagUpdateVariables = 1
		
	End Sub
	
	Sub command_debug(sCom As String)
		
		'iFlagThreadSignal = 0
		
		'run_pipe_write(sCom & !"\n")
		
		EnqueueDebugCommand sCom & !"\n"
		
	End Sub
	
	Sub step_debug(s As String)
		
		'	iFlagThreadSignal = 0
		'
		'	Dim As Long iSleep

		'	iSleep = 1
		
		'	If iStateMenu = 1 Then
		'
		'		NewCommand = "_" & s & !"l_\n"
		'		'run_pipe_write("_" & s & !"l_\n" , iSleep)
		'
		'	ElseIf iStateMenu = 2 Then
		'
		'		NewCommand = "_" & s & !"g_\n"
		'		'run_pipe_write("_" & s & !"g_\n" , iSleep)
		'
		'	Else
		
		EnqueueDebugCommand s & !"\n"
		'writepipefast(s & !"\n" , iSleep)
		
		'EndIf
		
		'	memset(@szDataForPipe , 0 , 200000)
		'
		'	get_read_data(1 , iStateMenu)
		
	End Sub
	
	Sub info_threads_debug(iFlagAutoUpdate As Long = 0)
		
		iFlagThreadSignal = 0
		
		run_pipe_write(!"thread apply all bt\n" , 100)
		
		'memset(@szDataForPipe , 0 , 200000)
		
		get_read_data(4, iFlagAutoUpdate, True)
		
	End Sub
	
	Sub info_loc_variables_debug(iFlagAutoUpdate As Long = 0)
		
		iFlagThreadSignal = 0
		
		run_pipe_write(!"_l_\n" , 100)
		
		'memset(@szDataForPipe , 0 , 200000)
		
		get_read_data(3 , iFlagAutoUpdate, True)
		
	End Sub
	
	Sub info_all_variables_debug(iFlagUpdate As Long = 0)
		
		iFlagThreadSignal = 0
		
		run_pipe_write(!"_g_\n" , 100)
		
		'memset(@szDataForPipe , 0 , 200000)
		
		get_read_data(2 , iFlagUpdate, True)
		
	End Sub
	
	Sub deinit()
		
		'	Disablegadget(E_BUT_STEP_IN , 1)
		'
		'	Disablegadget(E_BUT_STEP_OUT , 1)
		'
		'	Disablegadget(E_BUT_CONTINUE , 1)
		'
		'	Disablegadget(E_BUT_KILL , 1)
		'
		'	Disablegadget(E_BUT_UPDATEL , 1)
		'
		'	Disablegadget(E_BUT_UPDATEGL , 1)
		'
		'	Disablegadget(E_BUT_COMMAND , 1)
		
		'If Len(sfiles_array(0)) Then
		
		DbgTrace("deinit.enter", "") : bCloseDebugTabsPending = True : writepipe(!"q\n")
		
			DbgTrace("deinit.closehandles+unlock", "") : CloseHandle(hReadPipe)
			CloseHandle(hWritePipe)
		
		'EndIf
		MutexUnlock tlockGDB
		
		ClearDebugCommandQueue()
		
		iFlagStartDebug = 0
		bPendingDebugPanelRefresh = False
		
		iFlagUpdateVariables = 0
		
		iCounterUpdateVariables = 0
		
		fcurlig = -1

		' DR-16: deinit() runs on the worker thread (see run_debug's LOOP.inferiorGone and 'q'-
		' dequeue branches). DeleteDebugCursor reads/writes the shared CurEC control pointer and
		' calls .Repaint; ChangeEnabledDebug writes 14+ toolbar/menu .Enabled properties -- both are
		' unmarshaled UI-control touches from the worker (the same ThreadsEnter/ThreadsLeave-are-
		' no-ops hazard class as DR-3/DR-7). Stage instead; FlushDebugOutputOnUI (UI thread, called
		' every TimerProcGDB tick) applies both.
		bDeinitCleanupPending = True
		
		'sCurentFileExe = ""
		
		ReDim As TGLOBALSVAR tgl_var_array(2000)
		
		'ReDim As String sloc_var_array(2000)
		
		'ReDim As String sfiles_array(10)
		
		'	iIndexMainFile = 0
		'
		'	ReDim As HWND hPan()
		'
		'	For i As Long = 500 To 0 Step -1
		'
		'		If pd.sci(i) Then
		'
		'			Deleteitempanelgadget(E_PANEL , i)
		'
		'		EndIf
		'
		'		pd.sci(i) = 0
		'
		'	Next
		
		'	For i As Long = 0 To 200
		'
		'		sBP(i) = ""
		'
		'	Next
		
		'	iFlagThreadSignal = 0
		'
		'	iPosStartLast = 0
		'
		'	iPosEndLast = 0
		'
		'	iCurselLast = 0
		
		memset(@szDataForPipe , 0 , 200000)
		
	End Sub

Private Function kill_process(text As String) As Integer
	Dim As Long retcode,lasterr
	If prun Then ''debuggee waiting or running Then
		If MsgBox(("Stop the running program?") & " " & text + Chr(10) + Chr(10) + _
			("Any unsaved data in the program will be lost.") + Chr(10) + _
			("If possible, try closing the program normally first."), "Astoria IDE", mtWarning, btYesNo) = mrYes Then
			flagkill = True
				retcode=TerminateProcess(dbghand,999)
				lasterr=GetLastError
				While prun:Sleep 500:Wend
			Return True
		Else
			Return False
		End If
	Else
		Return True
	End If
End Function

Sub RunWithDebug(Debugger As String, ByRef ProjectFileName As WString, ByRef ProjectCommandLineArguments As WString, ByRef MainFile As WString, ByRef CompileLine As WString, ByRef FirstLine As WString)
	On Error Goto ErrorHandler
	Dim Result As Integer
	Dim As WString Ptr Workdir
	ThreadsEnter()
	ThreadsLeave()
	If Not Restarting Then
		exename = GetExeFileName(MainFile, CompileLine & " " & FirstLine)
		mainfolder = GetFolderName(MainFile)
	Else
		Restarting = False
	End If
	WatchIndex = -1
	exename = Replace(exename, UnixSlash, WindowsSlash)
	ThreadsEnter()
	tpLocals->SelectTab
	ThreadsLeave()
	Var Pos1 = 0
	While InStr(Pos1 + 1, exename, "\")
		Pos1 = InStr(Pos1 + 1, exename, "\")
	Wend
	If Pos1 = 0 Then Pos1 = Len(exename)
	WLet(Workdir, Left(exename, Pos1))
		ShowMessages(Time & ": " & ("Run") & ": " & exename & " ...")
		tvVar.Visible = False
		lvLocals.Visible = True
		tvThd.Visible = False
		lvThreads.Visible = True
		tvWch.Visible = False
		lvWatches.Visible = True
		If load_file(exename, GetFullPath(ExePath & "\" & BUNDLED_GDB_PATH)) Then
			ShowMessages(Time & ": " & ("Debugging finished."))
			ChangeEnabledDebug True, False, False
			Exit Sub
		End If
		tpLocals->SelectTab
		iFlagStartDebug = 1
		run_debug(1)
		ShowMessages(Time & ": " & ("Application finished. Returned code") & ": " & Result & " - " & Err2Description(Result))
		CheckProfiler GetFolderName(exename), exename
		ChangeEnabledDebug True, False, False
	If Workdir <> 0 Then _Deallocate( Workdir)
	Exit Sub
	ErrorHandler:
	ThreadsEnter()
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
	ThreadsLeave()
End Sub

'' DR-16(a) (2026-07-12): widened scope from the original DR-16(a) finding (load_file's two
'' blocking MsgBox calls on the worker thread). Tracing what a UI-thread pre-check would need
'' turned up a second, previously-unflagged instance of the same hazard: GetMainFile() -- needed
'' to compute the exe path -- has its own side effect (a conditional scratch-save of an unsaved
'' modified tab) AND its own embedded MsgBox ("Project Main File don't set"), and was being
'' called from RunProgramWithDebug on the worker thread. Owner decision: fix both properly.
'' GetMainFile/GetFirstCompileLine/GetExeFileName/GetFolderName were audited -- only GetMainFile
'' has a side effect, so it must be called exactly ONCE; everything else is a pure/read-only
'' string function and safe to (re)compute on either thread. Scope: covers the direct "Start
'' Debugging" entry points (5x ThreadCreate_(@StartDebugging) in AstoriaIDE.bas) where the exe is
'' expected to already exist. Deliberately NOT covering StartDebuggingWithCompile -- that path
'' compiles first (the exe doesn't exist yet at call time, so an exe-exists pre-check doesn't
'' apply the same way) and still has the old worker-thread-MsgBox behavior; flagged, not fixed.
Dim Shared As UString gPreparedMainFile, gPreparedCompileLine, gPreparedFirstLine
Dim Shared As ProjectElement Ptr gPreparedProject

'' UI thread only. Call before ThreadCreate_(@StartDebugging). Runs GetMainFile (the one
'' side-effecting call) and both existence checks that load_file used to run on the worker.
'' Returns False (and shows the same MsgBox load_file used to show, now safely on the UI
'' thread) if debugging can't start; the caller must not spawn the worker thread in that case.
Function PrepareDebugSession() As Boolean
	Dim As TreeNode Ptr ProjectNode
	gPreparedProject = 0
	gPreparedMainFile = GetMainFile(, gPreparedProject, ProjectNode)
	gPreparedCompileLine = ""
	gPreparedFirstLine = GetFirstCompileLine(gPreparedMainFile, gPreparedProject, gPreparedCompileLine)

	Dim As UString sPathGDB = GetFullPath(ExePath & "\" & BUNDLED_GDB_PATH)
	If FileExists(sPathGDB) = 0 Then
		MsgBox(("The debugger could not be found. Try reinstalling the IDE."), "Astoria IDE", mtError)
		Return False
	End If

	Dim As UString sExeName = GetExeFileName(gPreparedMainFile, gPreparedCompileLine & " " & gPreparedFirstLine)
	sExeName = Replace(sExeName, UnixSlash, WindowsSlash)
	If FileExists(sExeName) = 0 Then
		MsgBox(("The program to debug could not be found. Build the project first."), "Astoria IDE", mtError)
		Return False
	End If

	Return True
End Function

Sub RunProgramWithDebug(Param As Any Ptr)
	'' DR-16(a): MainFile/CompileLine/FirstLine/Project were already computed by
	'' PrepareDebugSession() on the UI thread before this worker thread was spawned -- read the
	'' staged values instead of calling GetMainFile a second time (it has a side effect).
	If gPreparedProject <> 0 Then
		RunWithDebug , *gPreparedProject->FileName, *gPreparedProject->CommandLineArguments, gPreparedMainFile, gPreparedCompileLine, gPreparedFirstLine
	Else
		RunWithDebug , "", "", gPreparedMainFile, gPreparedCompileLine, gPreparedFirstLine
	End If
End Sub


