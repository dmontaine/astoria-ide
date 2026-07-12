'#########################################################
'#  Debug.bi                                             #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#           Laurent GRAS                                #
'#########################################################

#define __crt_win32_unistd_bi__

#include once "mff/TextBox.bi"
#include once "EditControl.bi"
#include once "TabWindow.bi"
#include once "Main.bi"

Declare Sub DeleteDebugCursor
Declare Sub EnqueueDebugCommand(cmd As String)

'Enum 'type of running
'	RTRUN
'	RTSTEP
'	RTAUTO
'	RTOFF
'	RTFRUN
'	RTFREE
'	RTEND
'End Enum

'Common Shared As Byte runtype        'running type 07/12/2014

	#define regip rip
	#define regbp rbp
	#define regsp rsp
	#define ver3264 "(64bit) "

'#define fulldbg_prt 'uncomment to get more information
#define dbg_prt2 Rem ' dbg_prt 'used temporary for debugging, change rem by print 

#define fmt(t, l) Left(t, l) + Space(l - Len(t)) + "  "
#define fmt2(t, l) Left(t, l) + Space(l - Len(t))
#define fmt3(t, l) Space(l - Len(t)) + Left(t, l)
	
	#define KAMPERSAND "&"

''to handle new added field in array descriptor structure

	#include once "windows.bi"
	#include once "win\commctrl.bi"
	#include once "win\commdlg.bi"
	#include once "win\wingdi.bi"
	#include once "win\richedit.bi"
	#include once "win\tlhelp32.bi"
	#include once "win\shellapi.bi"
	#include once "win\psapi.bi"
	
	#define EXCEPTION_GUARD_PAGE_VIOLATION      &H80000001
	#define EXCEPTION_NO_MEMORY                 &HC0000017
	#define EXCEPTION_FLOAT_DENORMAL_OPERAND    &HC000008D
	#define EXCEPTION_FLOAT_DIVIDE_BY_ZERO      &HC000008E
	#define EXCEPTION_FLOAT_INEXACT_RESULT      &HC000008F
	#define EXCEPTION_FLOAT_INVALID_OPERATION   &HC0000090
	#define EXCEPTION_FLOAT_OVERFLOW            &HC0000091
	#define EXCEPTION_FLOAT_STACK_CHECK         &HC0000092
	#define EXCEPTION_FLOAT_UNDERFLOW           &HC0000093
	#define EXCEPTION_INTEGER_DIVIDE_BY_ZERO    &HC0000094
	#define EXCEPTION_INTEGER_OVERFLOW          &HC0000095
	#define EXCEPTION_PRIVILEGED_INSTRUCTION    &HC0000096
	#define EXCEPTION_CONTROL_C_EXIT            &HC000013A
	
	Common Shared windmain As HWND
	'Common Shared stopcode As Integer
	'Common Shared dbghand As HANDLE 'debugged proc handle
	'Common Shared As Integer linenb
	Common Shared tviewvar As HWND 'running proc/var
	Common Shared tviewprc As HWND 'all proc
	Common Shared tviewthd As HWND 'all threads
	Common Shared tviewwch As HWND 'watched variables

	Common Shared As HWND htab1, htab2

Common Shared As Integer fcurlig
Common Shared As Long iFlagStartDebug

Enum ''type of running
	RTRUN
	RTSTEP
	RTAUTO
	RTOFF
	RTFRUN
	RTFREE
	RTEND
	RTCRASH
End Enum

''============================= Declares ==============================================
'' Phase 4 dead-code sweep (2026-07-12): removed ~65 orphaned forward Declares (dbg_file,
'' dbg_include, dbg_proc, thread_resume, globals_load, var_sh2, start_pgm, attach_debuggee,
'' etc.) for the removed integrated (stabs) debugger -- none had a definition anywhere in
'' src/ (confirmed by a full cross-reference), so nothing ever called them. Their backing
'' Types/Enums/Consts (tproc/tprocr/tarr/tvrb/tvrr/ttrckarr/tudt/tcudt/texcld/twtch/tbrkol/
'' tbrkv/tbrclist/tthread/tvarfind/tshwexp/tvrp/tindexdata/tedit/tftext and the GDUMP*/GSHW*/
'' GBRKVAR*/GCCHAIN/KDBG*/KEDIT*/GEDT* dialog-box-ID enums) were removed with them.
Declare Function kill_process(text As String) As Integer
Declare Sub RunWithDebug(Debugger As String = "", ByRef ProjectFileName As WString, ByRef ProjectCommandLineArguments As WString, ByRef MainFile As WString, ByRef CompileLine As WString, ByRef FirstLine As WString)
Declare Sub RunProgramWithDebug(Param As Any Ptr)

	#include once "Debug.bas"


