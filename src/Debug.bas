'#########################################################
'#  Debug.bas                                            #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Laurent GRAS                                #
'#           Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "Debug.bi"

'mutex for blocking second thread before continue
Dim Shared As Any Ptr blocker
blocker = MutexCreate

''state of cc on each line can be KCC_ALL / KCC_NONE
''could be partially true but should be the main state
Dim Shared As KCC_STATE ccstate

Dim Shared As Integer debugevent
Dim Shared As Integer debugdata ''index of bp or address of BP (case BP on mem)
Dim Shared As String  libelexception
Dim Shared As Integer ssadr ''address of line for restoring breakcpu when singlestepping
Dim Shared As Integer firsttime
Dim Shared As Integer srcstart

''codes when debuggee stopped and corresponding texts
Dim Shared stopcode As Integer
Dim Shared stoplibel(20) As String*17 =>{"","BP On line","BP perm/tempo","BP cond","BP var","BP mem"_
,"BP count","Halt by user","Access violation","thread created","Exception"}

''source files
Dim Shared As String  source(SRCMAX)        ''source names with path
Dim Shared As String  srcname(SRCMAX)       ''source names without path
Dim Shared As tlist   srclist(SRCMAX)       ''to sort
Dim Shared As Integer srclistfirst          ''first sorted element
Dim Shared As Integer srccombocur           ''current combo choice
Dim Shared As Any Ptr sourceptr(SRCMAX)     ''pointer doc scintilla
Dim Shared As Any Ptr oldscintilla          ''last pointer for scintilla
Dim Shared As UByte   sourcebuf(SRCSIZEMAX) ''buffer for loading source file
Dim Shared As Integer sourcenb =-1          ''number of src, 0 based
Dim Shared As Integer sourceix              ''source index when loading data
Dim Shared As Any Ptr currentdoc            ''current doc pointer

Dim Shared As Integer srcdisplayed			''index displayed source

''lines
Dim Shared As Integer linenb, rlineprev ''numbers of lines, index of previous executed line (rline)
Dim Shared As Integer linenbprev ''used for dll
Dim Shared As Integer lastline
Dim Shared As tline rline(LINEMAX) ''1 based

''current tab:line
Dim Shared As Integer srccur   ''index source line to be executed
Dim Shared As Integer linecur  ''line to be executed (inside source)
Dim Shared As Integer rlinecur ''line to be executed

''procedures
Dim Shared As tproc proc(PROCMAX) ''list of procs in code
Dim Shared As Integer procnb
Dim Shared As Integer procnew ''used for finding address of first fbc line
Dim Shared As Integer procmain
Dim Shared As tlist   proclist(PROCMAX)
Dim Shared As Integer proclistfirst ''first sorted element

Dim Shared As Integer procsv,procsk,proccurad,procfn,procsort
Dim Shared As tprocr procr(PROCRMAX) ''list of running proc
Dim Shared As Integer procrnb
Dim Shared As Integer prolog ''it's in the prologue (if 1)

''arrays
Dim Shared  As tarr arr(ARRMAX)
Dim Shared As Integer arrnb

''variables
Dim Shared vrbloc      As Integer ''pointer of loc variables or components (init VGBLMAX+1)
Dim Shared vrbgbl      As Integer ''pointer of globals or components
Dim Shared vrbgblprev  As Integer ''for dll, previous value of vrbgbl, initial 1
Dim Shared vrbptr      As Integer Ptr ''equal @vrbloc or @vrbgbl
Dim Shared vrb(VARMAX) As tvrb ''1 based

''running variables
Dim Shared vrr(VRRMAX) As tvrr
Dim Shared vrrnb As Integer

''tracking arrays
Dim Shared As ttrckarr trckarr(TRCKARRMAX)

''udt/structures
Dim Shared udt(TYPEMAX) As tudt,udtidx As Integer
Dim Shared cudt(CTYPEMAX) As tcudt,cudtnb As Integer,cudtnbsav As Integer
'in case of module or DLL the udt number is initialized each time
Dim Shared As Integer udtcpt,udtmax 'current, max cpt

''excluded lines
Dim Shared As Integer excldnb
Dim Shared As texcld excldlines(EXCLDMAX)

''log
Dim Shared As Any Ptr hlogbx
Dim Shared As String vlog
Dim Shared As Integer logtyp

Dim Shared As Any Ptr heditorbx
Dim Shared As Integer afterkilled ''what doing after debuggee killed
''attach running exe
Dim Shared As Any Ptr hattachbx

Dim Shared As Integer threadlistidx ''used with multi action
Dim Shared As Integer multiaction

	''Threads
	Dim Shared thread(THREADMAX) As tthread  ''zero based
	Dim Shared threadlist(THREADMAX) As Integer
	Dim Shared threadnb As Integer
	Dim Shared threadcur As Integer
	Dim Shared threadprv As Integer     'previous thread used when mutexunlock released thread or after thread create
	Dim Shared threadcontext As HANDLE
	Dim Shared threadhs As HANDLE       'handle thread to resume
	Dim Shared dbgprocid As Integer     'pinfo.dwProcessId : debugged process id
	Dim Shared dbgthreadID As Integer   'pinfo.dwThreadId : debugged thread id
	Dim Shared dbghand As HANDLE  		'debugged proc handle
	Dim Shared dbghthread As HANDLE     'debuggee thread handle
	Dim Shared dbghfile  As HANDLE   	'debugged file handle
	Dim Shared pinfo As PROCESS_INFORMATION
	
	''DLL
	Dim Shared As tdll dlldata(DLLMAX) ''base 1
	Dim Shared As Integer dllnb
	
	'dbg_prt2 "MutexLock00"
	MutexLock blocker

''miscellanous data
Dim Shared As Boolean prun=False    ''debuggee running
Dim Shared As Integer runtype = RTOFF ''running type
Dim Shared As Integer breakcpu=&hCC ''asm code for breakpoint
Dim Shared As Integer breakadr ''address of last ABP kept in case of exception (RTCRASH)
Dim Shared As Integer dsptyp=0      ''type of display : 0 normal/ 1 source/ 2 var/ 3 memory

''put in a ctx with type ??
Dim Shared As Boolean procnodll
Dim Shared As Boolean skipline = False
Dim Shared As Boolean flagmain
Dim Shared As Boolean flagkill =False 'flag if killing process to avoid freeze in thread_del
Dim Shared As Integer flagrestart=-1  'flag to indicate restart in fact number of bas files to avoid to reload those files
Dim Shared As Integer flagwtch  =0     'flag =0 clean watched / 1 no cleaning in case of restart
Dim Shared As Byte flaglog =0         ' flag for dbg_prt 0 --> no output / 1--> only screen / 2-->only file / 3 --> both
Dim Shared As Byte flagtrace          ' flag for trace mode : 1 proc / +2 line
Dim Shared As Byte flagverbose        ' flag for verbose mode
Dim Shared As Byte flagascii          ' flag for dump displays only code ascii <128 by default just >32
Dim Shared As Boolean flagupdate = True ''if true proc/var, dump and watched displayed
Dim Shared As Boolean flagattach      ' flag for attach

Dim Shared As Any Ptr hmain

''for autostepping
Dim Shared As Integer autostep = 50
Dim Shared As Integer flaghalt

''watched
Dim Shared wtch(WTCHMAX) As twtch  ''zero based
Dim Shared wtchcpt As Integer 'counter of watched value, used for the menu
Dim Shared hwtchbx As Any Ptr    'handle
Dim Shared wtchidx As Integer 'index for delete
Const SAVED_FIELD_COUNT As Integer = 9
Dim Shared wtchexe(SAVED_FIELD_COUNT, WTCHMAX) As String 'watched var (no memory for next execution)
Dim Shared wtchnew As Integer 'to keep index after creating new watched

''breakpoint on line
Dim Shared As tbrkol brkol(BRKMAX)
Dim Shared As Integer brknb
Dim Shared As String brkexe(SAVED_FIELD_COUNT, BRKMAX) 'to save breakpoints by session
Dim Shared As Any Ptr hbrkbx ''window for managing breakpoints
Dim Shared As Boolean bpbox
Dim Shared As Integer brkidx1 ''index for BP mem or cond
Dim Shared As Integer brkidx2
Dim Shared As Integer brkadr1 ''address for BP mem or cond
Dim Shared As Integer brkadr2
Dim Shared As Integer brkdatatype
Dim Shared As Integer brkttb
Dim Shared As valeurs brkdata2
Dim Shared As Integer brktyp  ''type of BP mem/const or mem/mem
Dim Shared As Any Ptr hbpcondbx ''dialog box for managing var/const cond BP
Dim Shared As tbrclist listitem(VRRMAX)
Dim Shared As Integer listcpt ''used when filling array for cond BP
Dim Shared As Integer brkline(BRKMAX) ''used when deleting the BP one by one

''breakpoint on variable/memory (when there is a change)
Dim Shared As tbrkv brkv
Dim Shared As Any Ptr hbrkvbx ''handle

''call chain
Dim Shared As Any Ptr hcchainbx
Dim Shared As Any Ptr hlviewcchain
Dim Shared As Integer procrsav(PROCRMAX) ''index of procr
Dim Shared As Integer cchainthid

''edit box
Dim Shared As Any Ptr heditbx
Dim Shared As tedit edit ''data when editing var or mem

''find text box
Dim Shared As Any Ptr hfindtextbx
Dim Shared As tftext ftext

''dump memory
Dim Shared As Any Ptr hdumpbx ''window for handling dump
Dim Shared dumplines As Integer =20 'nb lines(default 20)
Dim Shared dumpadr   As Integer    'address for dump
Dim Shared dumpbase  As Integer =0 'value dump dec=0 or hexa=50
Dim Shared dumpadrbase   As Integer =1 'address display in dec (1) or hex (0)
Dim Shared dumpnbcol As Integer
Dim Shared dumptyp   As Integer =2

Dim Shared htviewvar As Any Ptr 'running proc/var
Dim Shared htviewprc As Any Ptr 'all proc
Dim Shared htviewthd As Any Ptr 'all threads
Dim Shared htviewwch As Any Ptr 'watched variables
Dim Shared hlviewdmp As Any Ptr 'dump

''variable find
Dim Shared As tvarfind varfind

''show/expand
Dim Shared As tshwexp shwexp
Dim Shared As Any Ptr hshwexpbx
Dim Shared As Any Ptr htviewshw
Dim Shared As tvrp vrp(VRPMAX)

'' index selection
#define KCOLMAX 30
#define KLINEMAX 50

Dim Shared As Any Ptr hindexbx
Dim Shared As tindexdata indexdata

udt(0).nm="Unknown"

	udt(1).nm="long":udt(1).lg=Len(Long)
udt(2).nm="Byte":udt(2).lg=Len(Byte)
udt(3).nm="Ubyte":udt(3).lg=Len(UByte)
udt(4).nm="Zstring":udt(4).lg=Len(Integer)
udt(5).nm="Short":udt(5).lg=Len(Short)
udt(6).nm="Ushort":udt(6).lg=Len(UShort)
udt(7).nm="Void":udt(7).lg=Len(Integer)

	udt(8).nm="Ulong":udt(8).lg=Len(ULong)

	udt(9).nm="Integer":udt(9).lg=Len(Integer)

	udt(10).nm="Uinteger":udt(10).lg=Len(UInteger)

udt(11).nm="Single":udt(11).lg=Len(Single)
udt(12).nm="Double":udt(12).lg=Len(Double)
udt(13).nm="String":udt(13).lg=Len(String)
udt(14).nm="Fstring":udt(14).lg=Len(Integer)
udt(15).nm="fb_Object":udt(15).lg=Len(UInteger)
udt(16).nm = "Boolean": udt(16).lg = Len(Boolean)
udt(18).nm = "Wstring": udt(18).lg = Len(Integer)

Dim Shared exename As WString * 300
Dim Shared mainfolder As WString * 300 'debuggee main folder
Dim Shared exedate As Double 'serial date
Dim Shared As String compilerversion ''compiler version retrieved stabs code = 255
Dim Shared As String cmdlimmediat

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
	
	Declare Function timer_data() As Integer
	
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
					ShowMessages sBuffer, False
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
		
		'TimerID = settimer(0, 0, 20, Cast(Any Ptr, @timer_data))
		
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
				
				If s <> "(gdb)" AndAlso s <> "Continuing." _
					AndAlso InStr(s , "[Inferior 1") = 0 _
					AndAlso InStr(s , "Using the running image of child") = 0  Then
					
					'				Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
					'
					paste_updatevar(0 , 0)
					'
					'				Linescrolleditor(E_EDITOR,10000000)
					
					Return 1
					
				Else
					
					If InStr(s , "[Inferior 1") Then
						
						'					Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
						'
						paste_updatevar(iFlagStepParam , 0)
						'
						'					Linescrolleditor(E_EDITOR,10000000)
						'
						ThreadsEnter
						
						deinit
						
						'ShowMessages(Time & ": " & ML("Application finished. Returned code") & ": 0 - " & Err2Description(0))
						
						ThreadsLeave()
						
						Return 1
						
					End If
					
				End If
				
			End If
			
		End If
		
	End Function
	
	Dim Shared As ZString * 3 sEndOfLine
	
		sEndOfLine = Chr(13) & Chr(10)
	
	Declare Sub kill_debug()
	Declare Sub kill_inferior_process()
	Declare Sub get_read_data(iFlag As Long , iFlagAutoUpdate As Long = 0, WithoutShowing As Boolean = False)
	
	Function timer_data() As Integer
		
		Static As Long iReset , iReset2
		
		'?iFlagThreadSignal
		
		'If szDataForPipe <> "" Then ?szDataForPipe
		
		If iFlagThreadSignal = 10 Then
			
			iFlagThreadSignal = 4
			
			Dim As Long iFind = InStr(szDataForPipe , "[Inferior 1")
			
			Dim As Long iFind2 = InStr(szDataForPipe , "The program being debugged is not being run.")
			
			If iFind Then
				
				Dim As Long iFind10 = InStr(iFind , szDataForPipe , sEndOfLine)
				
				Dim As String s
				
				If iFind10 Then
					
					s = Mid(szDataForPipe , iFind , iFind10-iFind)
					
				Else
					
					s = Mid(szDataForPipe , iFind)
					
				End If
				
				kill_debug()
				
				'killtimer(0, TimerID)
				
				'			Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
				'
				'			Pasteeditor(E_EDITOR, s)
				ShowMessages s
				'
				'			Linescrolleditor(E_EDITOR,10000000)
				
			ElseIf iFind2 Then
				
				kill_debug()
				
				'killtimer(0, TimerID)
				
			Else
				
				line_highlight()
				
				If Len(szDataForPipe) AndAlso InStr(szDataForPipe , "Using the running image of child") = 0 Then
					
					'				Setselecttexteditorgadget(E_EDITOR, -1 ,-1)
					'
					'				Pasteeditor(E_EDITOR, szDataForPipe)
					ShowMessages szDataForPipe
					'
					'				Linescrolleditor(E_EDITOR, 10000000)
					
				End If
				
			End If
			
			iReset = 0
			
		ElseIf iFlagThreadSignal = 11 Then
			
			iFlagThreadSignal = 0
			
			If Len(szDataForPipe) Then
				
				Dim As Long iFind2 = InStr(szDataForPipe , "The program being debugged is not being run.")
				
				If iFind2 Then
					
					kill_debug()
					
					'killtimer(0, TimerID)
					
				Else
					
					If line_highlight() = 0 Then
						
						'Setselecttexteditorgadget(E_EDITOR, -1 , -1)
						
						'Pasteeditor(E_EDITOR, szDataForPipe)
						ShowMessages szDataForPipe
						
						'Linescrolleditor(E_EDITOR,10000000)
						
					End If
					
				End If
				
			End If
			
		ElseIf iFlagThreadSignal = 13 Then
			
			If iReset2 >= 10 Then
				
				memset(@szDataForPipe , 0 , 200000)
				
				get_read_data(11)
				
				iReset2 = 0
				
			Else
				
				iReset2+=1
				
			End If
			
		Else
			
			If iFlagThreadSignal Then Return True
			
			If iReset >= 20 Then
				
				iFlagThreadSignal = 0
				
				memset(@szDataForPipe , 0 , 200000)
				
				run_pipe_write(!"info program\n")
				
				get_read_data(10)
				
				iReset = 0
				
			Else
				
				iFlagThreadSignal = 0
				
				memset(@szDataForPipe , 0 , 200000)
				
				get_read_data(11)
				
				iReset+=1
				
			End If
			
		End If
		
		Select Case iFlagThreadSignal
			
		Case 4
			
			iFlagThreadSignal = 0
			
		End Select
		
		'Return True
		
	End Function
	
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
		
			If FileExists(sPathGDB) = 0 Then
			
			ThreadsEnter
			
			MsgBox(("The debugger could not be found. Try reinstalling the IDE."), "Astoria IDE", mtError)
			
			ThreadsLeave
			
			Return -1
			
		End If
		
		If FileExists(sCurentFileExe) = 0 Then
			
			ThreadsEnter
			
			MsgBox(("The program to debug could not be found. Build the project first."), "Astoria IDE", mtError)
			
			ThreadsLeave
			
			Return -1
			
		End If
		
		ThreadsEnter
		
		ShowMessages(("Wait, process loading..."))
		
		lvLocals.Nodes.Clear
		
		lvGlobals.Nodes.Clear
		
		ThreadsLeave
		
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
	
	Sub set_bp(Temporary As Boolean = False)
		
		Dim As Long iFlagSetup
		
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		'	Dim As Long iCursel = Panelgadgetgetcursel(E_PANEL)
		
		If tb = 0 Then Exit Sub
		'	If iCursel > UBound(pd.sci) OrElse iCursel < 0 OrElse  iCursel > UBound(sfiles_array) Then Exit Sub
		
		Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
		'	Dim As Integer iPos = sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_GETCURRENTPOS , 0 , 0)
		'
		'	Dim As Integer iLine = sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_LINEFROMPOSITION , iPos , 0)
		'
		Dim As String sTemp = """" & Replace(tb->FileName, "\", "/") & """:" & iSelEndLine + 1

		'	For i As Long = 0 To UBound(sBP)
		'
		'		If iFlagSetup = 0 AndAlso sBP(i) = sTemp Then
		'
		'			iFlagSetup = 1
		'
		'		EndIf
		'
		'		If iFlagSetup Then
		'
		'			If i <> UBound(sBP) Then sBP(i) = sBP(i+1)
		'
		'		EndIf
		'
		'	Next
		
		Dim As EditControlLine Ptr ecLine = Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[iSelEndLine])

		' T6 (F-R1): skip blank/comment lines *before* touching GDB -- mirrors EditControl.Breakpoint's
		' own refusal, so F9 on a comment line no longer plants a phantom GDB breakpoint while the
		' editor (correctly) declines the local toggle. This is the "move the comment check ahead of
		' set_bp" fix from the attempt-#1 post-mortem.
		DbgTrace("set_bp.enter", "line=" & iSelEndLine & " ecBP=" & ecLine->Breakpoint & " Running=" & Running) : Dim As String sLineTrim = LTrim(*ecLine->Text, Any !"\t ")
		If CInt(sLineTrim = "") OrElse CInt(StartsWith(sLineTrim, "'")) OrElse CInt(StartsWith(LCase(sLineTrim) & " ", "rem ")) Then Exit Sub

		' T6 (F-R1): the debug worker thread (run_debug) and this UI-thread call share the same pair of
		' pipe handles. Serialize on tlockGDB and never inject a break/tbreak/clear while the inferior is
		' running -- attempt #1 hard-locked doing a blocking read off-prompt while holding the lock. When
		' the inferior is stopped GDB is at the prompt, so the readpipe() calls below return promptly, and
		' Running is only ever flipped by the worker under this same lock (so this test is race-free once
		' we hold it). If Running, the local breakpoint icon still toggles (in EditControl.Breakpoint) and
		' run_debug re-sends every editor breakpoint on the next run.
		MutexLock tlockGDB
		If Running Then DbgTrace("set_bp.bail", "Running") : MutexUnlock tlockGDB : Exit Sub

		If ecLine->Breakpoint Then

			If Not Temporary Then

				DbgTrace("set_bp.clear", DbgTraceEsc(sTemp)) : run_pipe_write(!"clear " & sTemp & !"\n")

				readpipe()

			End If

			'sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_MARKERDELETE , iLine , 0)

		ElseIf Temporary Then
			
			DbgTrace("set_bp.tbreak", DbgTraceEsc(sTemp)) : run_pipe_write(!"tbreak " & sTemp & !"\n")
			
			readpipe()
			
		Else
			
			DbgTrace("set_bp.break", DbgTraceEsc(sTemp)) : run_pipe_write(!"break " & sTemp & !"\n")
			
			readpipe()
			
			'sendmessage ( Cast(Any Ptr , pd.sci(iCursel)) ,  SCI_MARKERADD , iLine , 0)
			
			'		For i As Long = 0 To UBound(sBP)
			'
			'			If Len(sBP(i)) = 0 Then
			'
			'				sBP(i) = sTemp
			'
			'				Exit For
			'
			'			EndIf
			'
			'		Next
			'
		End If

		MutexUnlock tlockGDB

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
			
			Dim As TabWindow Ptr tb
			For jj As Integer = 0 To TabPanels.Count - 1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
				For i As Integer = 0 To ptabCode->TabCount - 1
					tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
					For j As Integer = 0 To tb->txtCode.Content.Lines.Count - 1
						If Not Cast(EditControlLine Ptr, tb->txtCode.Content.Lines.Items[j])->Breakpoint Then Continue For
						
						writepipe(!"break """ & Replace(tb->FileName, "\", "/") & """:" & WStr(j + 1) & !"\n")
						readpipe()
					Next
				Next i
			Next jj
			'TimerID = settimer(0, 0, 20, Cast(Any Ptr, @timer_data))

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
						ThreadsEnter
						ShowMessages ("Debugging finished.")
						If bGDBLocked Then MutexUnlock tlockGDB: bGDBLocked = False
						deinit
						ThreadsLeave
						Exit Do
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
						If runtype <> RTSTEP Then
							writepipe(!"c\n")
							Running = True
							Continue Do
							'					Else
							'						Result = readpipe
						End If
					End If
					If ShowResult Then
						ShowMessages Result
						ShowResult = False
					End If
					szDataForPipe = Result
					Running = False
					If (InStr(Result, "[Inferior ") > 0) OrElse (InStr(Result, "not being run") > 0) Then
						'' 2B (DR-6) + DR-14: the inferior has exited or been terminated -- either it
						'' ran to completion / crashed on its own (DR-14), or Stop-while-running just
						'' killed it (kill_inferior_process). Do NOT fall through to the panel refresh:
						'' RefreshDebugPanelsAfterStop would send _l_/thread-apply-all-bt to a dead
						'' program and block forever reading a reply that never comes (the DR-14 hang).
						'' Shut the session down cleanly right here on the worker thread (which owns the
						'' pipe): deinit closes the handles + quits GDB, then leave the loop.
						DbgTrace("LOOP.inferiorGone", DbgTraceEsc(Left(Result, 80)))
						ShowMessages Result
						deinit
						bGDBLocked = False   '' deinit released tlockGDB
						Exit Do
					End If
					If WatchIndex <> -1 Then
						ThreadsEnter
						UpdateWatch WatchIndex, Result
						ThreadsLeave
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
	
	Sub kill_debug()
		
		iFlagThreadSignal = 0
		
		iFlagUpdateVariables = 0
		
		iCounterUpdateVariables = 0
		
		iFlagStartDebug = 0
		
		'	Setimagegadget(E_BUT_RUN , bmp(0))
		'
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
		
			
			If iGlPid Then
				
				'killtimer(0, TimerID)
				
				readpipe()
				
				DbgTrace("kill_debug.terminate", "iGlPid=" & iGlPid) : Var h = OpenProcess(PROCESS_ALL_ACCESS , 0 , iGlPid)
				
				TerminateProcess(h , 1)
				
				CloseHandle(h)
				
			End If
			
			'Updateinfoxserver(300)
			
		
		'	Setselecttexteditorgadget(E_EDITOR, -1 , -1)
		'
		'	Pasteeditor(E_EDITOR, "Kill Program.")
		ShowMessages "Kill Program."
		'
		'	Linescrolleditor(E_EDITOR,10000000)
		
		deinit
		
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
		
		DeleteDebugCursor
		
		ChangeEnabledDebug True, False, False
		
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

Private Sub hard_closing(errormsg As String)
	ThreadsEnter
	MsgBox(("The debugger ran into a problem and had to stop.") & Chr(13) & Chr(13) & errormsg, "Astoria IDE", mtError)
	ThreadsLeave
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

Sub RunProgramWithDebug(Param As Any Ptr)
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As UString CompileLine, MainFile = GetMainFile(, Project, ProjectNode)
	Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project, CompileLine)
	If Project <> 0 Then
		RunWithDebug , *Project->FileName, *Project->CommandLineArguments, MainFile, CompileLine, FirstLine
	Else
		RunWithDebug , "", "", MainFile, CompileLine, FirstLine
	End If
End Sub


