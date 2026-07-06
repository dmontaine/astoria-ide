'#########################################################
'#  Debug.bi                                             #
'#  This file is part of VisualFBEditor                  #
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
	
	''DLL
	Const DLLMAX=300
	Type tdll
		As HANDLE   hdl 'handle to close
		As UInteger bse 'base address
		As Any Ptr  tv  'item treeview to delete
		As Integer gblb 'index/number in global var table
		As Integer gbln
		As Integer  lnb 'index/number in line
		As Integer  lnn
		As String   fnm 'full name
	End Type
	
	'' Output information
	#define dbg_prt(txt) output_wds(txt)
	Declare Sub output_wds(As String)
	
	#define HCOMBO 500

	#define WSTRSIZE 2 ''size of one charactere in wstring
''==========================================================
''====================== end for linux =========================

Declare Sub string_sh(tv As Any Ptr)
Declare Sub shwexp_new(tview As Any Ptr)
	Declare Sub fastrun()
	Declare Sub thread_rsm()
	Declare Sub exe_mod()
	Declare Sub brk_set(t As Integer)
	Declare Function var_sh1(i As Integer) As String
	
	Common Shared windmain As HWND
	'Common Shared stopcode As Integer
	'Common Shared dbghand As HANDLE 'debugged proc handle
	'Common Shared As Integer linenb
	Common Shared tviewcur As HWND  'TV1 ou TV2 ou TV3
	Common Shared tviewvar As HWND 'running proc/var
	Common Shared tviewprc As HWND 'all proc
	Common Shared tviewthd As HWND 'all threads
	Common Shared tviewwch As HWND 'watched variables

	'Common Shared As Integer linenbprev 'used for dll
	'Common Shared rline() As tline
	'Common Shared source() As String    'source names
	Common Shared As HWND htab1, htab2
Common Shared As Integer rlineold 'numbers of lines, index of previous executed line (rline)
Common Shared As Integer fntab

Type tlist
	As Integer parent
	As Integer child
	As ZString Ptr nm
	'as INTEGER idx
End Type

#define TYPESTD 18 ''upper limit for standard type, now 17 for va_list 2020/02/05
Const STYPESTD = ":t" + Str(TYPESTD)

'' DATA STAB
Type udtstab
	stabs As Long    ''offset for string
	code As UShort   ''stabs type
	nline As UShort  ''line number
	ad As Integer   ''address 64bit for gas64
End Type
#define STAB_SZ_MAX 60000  ''max stabs string

Enum
NODLL
DLL
End Enum

''source code files
#define SRCSIZEMAX 5000000 ''max source size

Const   SRCMAX=1000		   ''max source file

Common Shared As Integer fcurlig
Common Shared As Long iFlagStartDebug

#define KSTYLBREAK      1
#define KSTYLBREAKTEMPO 2
#define KSTYLBREAKCOUNT 3
#define KSTYLBREAKDISAB 4

#define KSTYLENONE 0
#define KSTYLECUR  150

Union valeurs
	vinteger As Integer
	vuinteger As UInteger
	vsingle As Single
	vdouble As Double
	vlongint As LongInt
	vulongint As ULongInt
	vbyte As Byte
	vubyte As UByte
	vshort As Short
	vushort As UShort
	'vstring as string
	'vzstring as zstring
	'vwstring as wstring
End Union

'' for proc_find / thread
Const KFIRST=1
Const KLAST=2

Enum ''type udt/redim/dim
	TYUDT
	TYRDM
	TYDIM
End Enum

Enum ''thread status
	KTHD_RUN '0
	KTHD_STOP
	KTHD_BLKD
	KTHD_INIT
	KTHD_IDLE
End Enum

 ''for ccstate
Enum KCC_STATE
	KCC_NONE
	KCC_ALL
End Enum

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

Enum ''stop code
	CSSTEP=0
	CSCURSOR
	CSBRKTEMPO
	CSBRK
	CSBRKV
	CSBRKM
	CSHALTBU
	CSLINE
	CSBRKPT
	CSCOND
	CSVAR
	CSMEM
	CSCOUNT
	CSUSER
	CSACCVIOL
	CSNEWTHRD
	CSEXCEP
End Enum

''for dissassembly
#define KLINE 1 ''from source code
#define KPROC 2 ''from source code
#define KSPROC 3 ''from proc/var

Union pointeurs
	pxxx As Any Ptr
	   pinteger As Long Ptr
	   puinteger As ULong Ptr
	'pinteger As Integer Ptr
	'puinteger As UInteger Ptr
	psingle As Single Ptr
	pdouble As Double Ptr
	plongint As LongInt Ptr
	pulongint As ULongInt Ptr
	pbyte As Byte Ptr
	pubyte As UByte Ptr
	pshort As Short Ptr
	pushort As UShort Ptr
	pstring As String Ptr
	pzstring As ZString Ptr
	pwstring As WString Ptr
End Union

'================ Lines ==============================================
Const LINEMAX=200000
Type tline
	ad As UInteger ''offset relative to proc address
	nu As Integer  ''number in file
	sv As UByte     ''saved value replaced by breakcpu
	px As UShort   ''proc index
	sx As UShort   ''source index need it now for lines from include and not inside proc
	hp As Integer
	hn As Integer
End Type
'===================== Procedures (sub, function, operator) ============================
Const PROCMAX=20000 'in sources
Enum
 KMODULE=0 'used with IDSORTPRC
 KPROCNM
End Enum

Type tproc
	nm As String   ''name
	db As Integer ''beginning address
	first As Integer ''first address corresponding to a fbc line
	fn As Integer ''last address of fbc line
	ed As Integer ''last address +1 (begin of next proc)
	sr As UShort   'source index
	nu As Long     'line number to quick access
	lastline As Long 'last line of proc (use when dwarf data) ''2016/03/24
	vr As UInteger 'lower index variable upper (next proc) -1
	rv As Integer  'return value type
	pt As Long     'counter pointer for return value (** -> 2)
	rvadr As Integer 'offset for return value adr (for now only dwarf)
    tv As Any Ptr 'in tview2
    st As Byte     'state followed = not checked
    enab As Boolean 'state enable/disable
End Type

Const PROCRMAX=50000 'Running proc
Type tprocr
	sk   As Integer  'stack
	ret  As Integer  'return address
	idx  As Integer  'index for proc
	tv   As Any Ptr  'index for treeview
	'lst as uinteger 'future array in LIST
	cl   As Integer  'calling line
	thid As Integer  'idx thread
	vr   As Integer  'lower index running variable upper (next proc) -1
End Type
''======================== Arrays =========================================
Const ARRMAX = 5500
#define KMAXDIM 5
Type tnlu
	lb As UInteger
	ub As UInteger
End Type
Type tarr 'five dimensions max
	dm As UInteger
	nlu(5) As tnlu
End Type

''====================== Variables gloables/common/locales/parameters ============================
Const VARMAX = 100000 'CAUTION 3000 elements taken for globals
Const VGBLMAX = 8000 'max globals

Type tvrb
	nm As String    'name
	typ As Integer  'type
	adr As Integer  'address or offset
	mem As UByte    'scope
	arr As tarr Ptr 'pointer to array def
	pt As Long      'pointer
	fxlen As Integer 'lenght of fix-len string (string *N)
End Type

''========================== Running variables ============================
Const VRRMAX = 800000
Type tvrr
	ad    As UInteger 'address
	tv    As Any Ptr  'tview handle
	vr    As Integer  'variable if >0 or component if <0
	ini   As UInteger 'dyn array address (structure) or initial address in array
	gofs  As UInteger 'global offset to optimise access
	ix(4) As Integer  '5 index max in case of array
	arrid As Integer  'index in array tracking for automatic tracking ''2016/06/02
End Type

''========================= Tracking an array, displaying value using variables as indexes ================
'' ex array1(i,j) when i or j change the corresponding value of array1 is displayed
Const TRCKARRMAX=4
Type ttrckarr
	typ    As UByte     ''type or lenght ???
	memadr As UInteger  ''adress in memory
	iv     As UInteger  ''vrr index used when deleting proc
	idx    As Integer   ''array variable index in vrr
	''bname as string
End Type

''====================== UDT structures and fields ==============================
Const TYPEMAX=80000,CTYPEMAX=100000
'CAUTION : TYPEMAX is the type for bitfield so the real limit is typemax-1
Type tudt
	nm As String  'name of udt
	lb As Integer 'lower limit for components
	ub As Integer 'upper
	lg As Integer 'lenght
	en As Integer 'flag if enum 1 or 0
	index As Integer 'dwarf
	what As Integer 'dwarf udt/pointer/array
	typ As Integer 'dwarf
	dimnb As Long 'dwarf
	bounds(5) As UInteger 'dwarf
End Type
Type tcudt
	nm As String    'name of components or text for enum
	Union
		typ As Integer  'type
		Val As Integer  'value for enum
	End Union
	ofs As UInteger 'offset
	ofb As UInteger 'rest offset bits
    lg As UInteger  'lenght
	arr As tarr Ptr 'arr ptr
	pt As Long
	fxlen As Integer 'lenght of fix-len string (string *N)
End Type

''========================= Excluded lines for procs added in dll (DllMain and tmp$x) ================
Const EXCLDMAX=10
Type texcld
	db As UInteger
	fn As UInteger
End Type

''========================= Watched variables or memory ==================================
Const WTCHMAX=19 ''zero based
Const WTCHALL=9999999
Type twtch
    hnd As Any Ptr  'handle
    tvl As Any Ptr  'tview handle
    adr As UInteger 'memory address
    typ As Integer  'type for var_sh2
    pnt As Integer  'nb pointer
    ivr As Integer  'index vrr
    psk As Integer  'stk procr or -1 (empty)/-2 (memory)/-3 (non-existent local var)/-4 (session)
    lbl As String   'name & type,etc
    arr As UInteger 'ini for dyn arr
    tad As Integer  'additionnal type
    old As String   'keep previous value for tracing
    idx As Integer  'index proc only for local var
    dlt As Integer  'delta on stack only for local var
    vnb As Integer  'number of level
    vnm(10) As String   'name of var or component
    vty(10) As String   'type
    Var     As Integer  'array=1 / no array=0
    fxlen   As Integer
End Type

''========================= Breakpoint on line ===================================
Const BRKMAX=10 'breakpoint index zero for "run to cursor"
Type tbrkol
	isrc    As UShort  'source index
	nline   As Integer 'num line for display
	index   As Integer 'index for rline
	ad      As Integer 'address
	typ     As Byte	   'type
	ivar1   As Integer
	Union
		adrvar1 As Integer
		counter As UInteger 'counter to control the number of times the line should be executed before stopping
	End Union
	ivar2   As Integer
	Union
		adrvar2 As Integer
		cntrsav As UInteger 'to reset if needed the initial value of the counter
	End Union
	datatype As Byte
	Val As valeurs   ''constant value for BP cond
	ttb As Byte
End Type

''========================= Breakpoint on variable ===================================
Type tbrkv
	typ As Integer   'type of variable
	adr As Integer  'address
	adr1 As Integer  'address
	adr2 As Integer  'address
	arr As Integer  'adr if dyn array
	ivr As Integer   'variable index
	ivr1 As Integer   'variable index
	ivr2 As Integer   'variable index
	psk As Integer   'stack proc
	Val As valeurs   'value
	vst As String    'value as string
	tst As Byte= 1    'type of comparison (1 to 6)
	ttb As Byte      'type of comparison (32 shr tst)
	txt As String	 'name and value for menu
End Type

Type tbrclist ''list of item handle for cond BP
	items As Integer
	itemc As Integer
End Type
''======================== Threads ====================================
Const THREADMAX=500
Type tthread
	hd  As HANDLE    'handle
	id  As UInteger  'ident
 pe  As Integer   'flag if true indicates proc end
 sv  As Integer   'sav line
 od  As Integer   'previous line
 cl  As Integer   'calling line, assigned when begin of proc is reached then -->proc().cl
 nk  As UInteger  'for naked proc, stack and used as flag
 st  As Integer   'to keep starting line
 tv  As Any Ptr 'to keep handle of thread item
 plt As Any Ptr 'to keep handle of last proc of thread in proc/var tview
 ptv As Any Ptr 'to keep handle of last proc of thread in thread tview
 exc As Integer   'to indicate execution in case of auto 1=yes, 0=no
 sts As Integer ''status running /stopped /init /out of scop debugger (library)
 stack As Integer ''stack of last proc
 rtype As Integer ''what was the run type when running as global run type could be different
End Type

''variable find
Type tvarfind
	ty As Integer
	pt As Integer
	nm As String    'var name or description when not a variable
	pr As Integer   'index of running var parent (if no parent same as ivr)
	ad As UInteger
	iv As Integer   'index of running var
	fxlen As Integer
	tv As Any Ptr   'handle treeview
    tl As Any Ptr   'handle line
End Type

''show/expand
''Const SHWEXPMAX=10 'max shwexp boxes
Const VRPMAX=5000  'max elements in each treeview
Type tshwexp
	'bx As HWND     'handle pointed value box
	tv As Any Ptr     'corresponding tree view
	nb As Integer  'number of elements tvrp
	'cu As HWND     'handle of the current index label
	'mn As HWND     'handle of the mini index label
	'mx as HWND     'handle of the max indexlabel
	curidx As Integer  'current index only for array
	minidx As Integer  'min index
	maxidx As Integer  'max index

	procr  As Integer 'index of running proc  (-1 if memory) used to delete the shw/exp when proc is exiting (local var)
	arradr As Integer 'address of pointer in descriptor array (-1 if not a dynamic array)
	mem    As Integer 'if static don't delete the shw/exp when the proc is closed
	parent As Integer 'index of higher parent
	free   As Boolean 'shwexp in use or not
End Type
Type tvrp
	nm As String    'name
	ty As Integer   'type
	pt As Integer   'is pointer
	ad As UInteger  'address
	tl As Any Ptr   'line in treeview
	iv As Integer   'index of variables
	fxlen As Integer
End Type

Type tindexdata
		indexvar As Integer
		sizeline As Integer
		size     As Integer
		nbdim 	 As Integer
		curidx(4)  As Integer
		vlbound(4) As Integer
		vubound(4) As Integer
		adr As  Integer
		typ As  Integer ''type
		typ2 As Integer
		delta2  As Integer
		autoupd As Boolean ''auto update the table
		typvar  As Boolean ''var or cudt
End Type

''index box
Const INDEXBOXMAX=9

''for dump memory
Enum
	GDUMPAPPLY=940
	GDUMPADR
	GDUMPEDIT

	GDUMPTSIZE
	GDUMPSIZE
	GDUMPCLIP
	GDUMPBASEADR
	GDUMPDECHEX
	GDUMPSIGNED

	GDUMPMOVEGRP
	GDUMPCL
	GDUMPCP
	GDUMPLL
	GDUMPLP
	GDUMPPL
	GDUMPPP

	GDUMUSEGRP
	GDUMPNEW
	GDUMPWCH
	GDUMPBRK
	GDUMPSHW

	GDUMPPTRGRP
	GDUMPPTRNO
	GDUMPPTR1
	GDUMPPTR2

	GDUMPTYPE
	GDUMPCTRL
End Enum

''shw/exp
Enum
	GSHWWCH=970
	GSHWDMP
	GSHWEDT
	GSHWSTR
	GSHWNEW
	GSHWCUR
	GSHWMIN
	GSHWMAX
	GSHWSET
	GSHWINC
	GSHWDEC
	GSHWUPD
	GTVIEWSHW
End Enum

''break on var/mem or cond
'#define KBRCMEMCONST 1 ''cond  var/const
#define KBRCMEMMEM   1 ''cond  var/var
#define KBRKMEMCONST 2 ''mem   var-mem/const
#define KBRKMEMMEM   3 ''mem   var-mem/mem

Enum
	GBRKVAR1=990
	GBRKVAR2
	GBRKVALUE
	GBRKVOK
	GBRKVDEL
	GBRKVCOND
End Enum

''miscellaneous
Enum
''procedure tracking
	GCCHAIN=1400
'' timer
	GTIMER001
	
'' attaching
	GATTCHEDIT
	GATTCHTXT
	GATTCHGET
	GATTCHOK
End Enum

'' debug events
Enum
 KDBGNOTHING = 0
 KDBGRKPOINT
 KDBGCREATEPROCESS
 KDBGCREATETHREAD
 KDBGEXITPROCESS
 KDBGEXITTHREAD
 KDBGDLL
 KDBGDLLUNLOAD
 KDBGEXCEPT
 'KDBGSTRING
End Enum
'' multi action
Enum
	KMULTINOTHING
	KMULTISTEP
End Enum

''editing value variable/memory
#define KEDITVAR  0
#define KEDITDMP  1
#define KEDITARR  2
#define KEDITWCH  3
#define KEDITPTD  4
#define KEDITSHW  5
#define KEDITTOP  6

Enum
	GEDTVAR=1500
	GEDTVALUE
	GEDTOK
	GEDTCANCEL
	GEDTPTD
	GEDTPTDEDT
	GEDTPTDVAL

	GFINDTEXT
	GFINDTEXTP
	GFINDTEXTN
End Enum

Type tedit
	adr As Integer
	typ As Integer
	pt  As Integer
	ptdadr	As Integer
	ptdval As String
	src As Integer
End Type

Type tftext
	tpos As Integer
End Type

''============================= Declares ==============================================
Declare Function check_bitness(ByRef fullname As WString) As Integer
Declare Sub dbg_file(strg As String, value As Integer)
Declare Sub dbg_include(strg As String)
Declare Sub dbg_proc(strg As String, linenum As Integer, adr As Integer)
Declare Sub dbg_line(linenum As Integer, ofset As Integer)
Declare Sub dbg_epilog(ofset As Integer)
Declare Sub compinfo_load(basedata As UInteger, sizedata As UInteger)
Declare Sub reinit()
Declare Function thread_index(tid As Long) As Integer
Declare Sub thread_resume(thd As Integer = -1)
Declare Sub globals_load(d As Integer = 0)
Declare Sub watch_check(wname() As String)
Declare Sub process_terminated
Declare Sub thread_del(thid As UInteger)
Declare Function source_name(fullname As String)As String
Declare Function dll_name(FileHandle As Any Ptr, t As Integer = 1 ) As String
Declare Function var_find2(tv As Any Ptr) As Integer
Declare Sub var_fill(i As Integer)
Declare Sub proc_del(j As Integer,t As Integer=1)
Declare Sub dsp_change(index As Integer)
Declare Sub size_change()
Declare Sub hard_closing(errormsg As String)
Declare Function wait_debug() As Integer
Declare Sub dump_sh()
Declare Sub var_sh()
Declare Sub index_update()
Declare Function var_find() As Integer
Declare Function var_sh2(t As Integer, pany As UInteger, p As UByte= 0, sOffset As String = "", fxlen As Integer = 0) As String
Declare Sub shwexp_init()
Declare Sub edit_fill(txt As String,adr As Integer,typ As Integer, pt As Integer, src As Integer)
Declare Function debug_extract(exebase As UInteger,nfile As String,dllflag As Long = NODLL) As Integer
Declare Sub button_action(button As Integer)
Declare Sub ini_write()
Declare Sub singlestep_on(tid As Integer,rln As Integer,running As Integer =1)
Declare Sub brk_del(n As Integer)
Declare Sub brkv_set(a As Integer)
Declare Sub brk_apply()
Declare Sub brk_sav()
Declare Sub process_list()
Declare Sub gest_brk(ad As Integer,ByVal rln As Integer =-1)
Declare Sub list_all()
Declare Sub restart_exe(ByVal idx As Integer)
Declare Sub dll_load()
Declare Sub winmsg()
Declare Sub start_pgm(p As Any Ptr)
Declare Sub resume_exec()
Declare Function proc_find(thid As Integer,t As Byte) As Integer
Declare Function proc_name(ad As UInteger) As String
Declare Sub proc_sh()
Declare Function proc_verif(p As Integer) As Boolean
Declare Function proc_retval(prcnb As Integer) As String
Declare Sub proc_watch(procridx As Integer)
Declare Sub brk_manage(title As String)
Declare Sub var_tip(ope As Integer)
Declare Sub show_regs()
Declare Sub set_cc()
Declare Function kill_process(text As String) As Integer
Declare Sub attach_ok()
Declare Sub str_replace(strg As String, srch As String, repl As String)
Declare Sub attach_debuggee(p As Any Ptr)
Declare Sub brk_marker(brkidx As Integer)
Declare Sub thread_text(th As Integer=-1)
Declare Sub proc_runnew()
Declare Function line_call(regip As UInteger) As Integer 'find the calling line for proc
Declare Sub proc_new()
Declare Sub proc_end()
Declare Sub thread_status()
Declare Function thread_select(id As Integer = 0) As Integer
Declare Function var_search(pproc As Integer, text() As String, vnb As Integer, varr As Integer, vpnt As Integer = 0) As Integer
Declare Sub RunWithDebug(Debugger As String = "", ByRef ProjectFileName As WString, ByRef ProjectCommandLineArguments As WString, ByRef MainFile As WString, ByRef CompileLine As WString, ByRef FirstLine As WString)
Declare Sub RunProgramWithDebug(Param As Any Ptr)

	#include once "Debug.bas"


