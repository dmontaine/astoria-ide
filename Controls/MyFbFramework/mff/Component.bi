'###############################################################################
'#  Component.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'###############################################################################

#include once "Object.bi"
#include once "List.bi"

Namespace My.Sys.ComponentModel
	#define QComponent(__Ptr__) (*Cast(Component Ptr, __Ptr__))
	
	Private Type MarginsType Extends My.Sys.Object
		Declare Function ToString ByRef As WString
		Left         As Integer
		Top          As Integer
		Right        As Integer
		Bottom       As Integer
	End Type
	
	'Provides the base class for the components (Windows, Linux, Android, Web).
	Private Type Component Extends My.Sys.Object
	Protected:
		FClassAncestor      As WString Ptr
		FDesignMode         As Boolean
		FCreated            As Boolean
		FID                 As Integer
		FName               As WString Ptr
		FLeft               As Integer
		FTop                As Integer
		FWidth              As Integer
		FHeight             As Integer
		FMinWidth           As Integer
		FMinHeight          As Integer
		FParent             As Component Ptr
		FComponents         As List
		FTempString         As String
			FHandle         As HWND
		Declare Sub FreeWidget()
		Declare Virtual Sub Move(cLeft As Integer, cTop As Integer, cWidth As Integer, cHeight As Integer)
	Public:
		'Stores any extra data needed for your program (Windows, Linux, Android, Web).
		Tag As Any Ptr
		'Returns/sets the space between controls (Windows, Linux, Android, Web).
		Margins             As MarginsType
		'Returns/sets the extra space between controls (Windows, Linux, Android, Web).
		ExtraMargins        As MarginsType
			'Gets the window handle that the control is bound to (Windows, Linux, Android, Web).
			Declare Property Handle As HWND
			Declare Property Handle(Value As HWND)
			Declare Property LayoutHandle As HWND
			Declare Property LayoutHandle(Value As HWND)
			'Reads value from the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			'Writes value to the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		'Returns a string that represents the current object (Windows, Linux, Android, Web).
		Declare Virtual Function ToString ByRef As WString
		'Returns ancestor class of control (Windows, Linux, Android, Web).
		Declare Function ClassAncestor ByRef As WString
		'Determines if the control is a top-level control (Windows, Linux, Android, Web).
		Declare Function GetTopLevel As Component Ptr
		'Returns/sets the distance between the internal left edge of an object and the left edge of its container (Windows, Linux, Android, Web).
		Declare Property Left As Integer
		Declare Property Left(Value As Integer)
		'Returns/sets the distance between the internal top edge of an object and the top edge of its container (Windows, Linux, Android, Web).
		Declare Property Top As Integer
		Declare Property Top(Value As Integer)
		'Returns/sets the width of an object (Windows, Linux, Android, Web).
		Declare Property Width As Integer
		Declare Property Width(Value As Integer)
		'Returns/sets the height of an object (Windows, Linux, Android, Web).
		Declare Property Height As Integer
		Declare Property Height(Value As Integer)
		'Gets the bounds of the control to the specified location and size (Windows, Linux, Android, Web).
		Declare Sub GetBounds(ByRef ALeft As Integer, ByRef ATop As Integer, ByRef AWidth As Integer, ByRef AHeight As Integer)
		'Sets the bounds of the control to the specified location and size (Windows, Linux, Android, Web).
		Declare Sub SetBounds(ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)
		'Gets a value that indicates whether the Component is currently in design mode (Windows, Linux, Android, Web).
		Declare Virtual Property DesignMode As Boolean
		Declare Virtual Property DesignMode(Value As Boolean)
		'Returns the name used in code to identify an object (Windows, Linux, Android, Web).
		Declare Property Name ByRef As WString
		Declare Property Name(ByRef Value As WString)
		'Gets or sets the parent container of the control (Windows, Linux, Android, Web).
		Declare Property Parent As Component Ptr 'ContainerControl
		Declare Property Parent(Value As Component Ptr)
		'Declare Constructor
		Declare Destructor
	End Type
End Namespace

Private Type Message
	Sender   As Any Ptr
		hWnd     As HWND
		Msg      As UINT
		wParam   As WPARAM
		lParam   As LPARAM
		Result   As LRESULT
		wParamLo As Integer
		wParamHi As Integer
		lParamLo As Integer
		lParamHi As Integer
		Captured As Any Ptr
	Handled As Boolean
End Type


Private Enum Keys
		Key_Esc = VK_ESCAPE
		Key_Left = VK_LEFT
		Key_Right = VK_RIGHT
		Key_Up = VK_UP
		Key_Down = VK_DOWN
		Key_Home = VK_HOME
		Key_End = VK_END
		Key_Delete = VK_DELETE
		Key_Enter = VK_RETURN
		ShiftMask = 1 'VK_SHIFT
		LockMask = 2 'VK_SCROLL
		CtrlMask = 4 'VK_CONTROL
		AltMask = 8 'VK_MENU
		Key_1 = VK_1
		Key_2 = VK_2
		Key_3 = VK_3
		Key_4 = VK_4
		Key_5 = VK_5
		Key_6 = VK_6
		Key_7 = VK_7
		Key_8 = VK_8
		Key_9 = VK_9
		Key_0 = VK_0
		Key_A = VK_A
		Key_B = VK_B
		Key_C = VK_C
		Key_D = VK_D
		Key_E = VK_E
		Key_F = VK_F
		Key_G = VK_G
		Key_H = VK_H
		Key_I = VK_I
		Key_J = VK_J
		Key_K = VK_K
		Key_L = VK_L
		Key_M = VK_M
		Key_N = VK_N
		Key_O = VK_O
		Key_P = VK_P
		Key_Q = VK_Q
		Key_R = VK_R
		Key_S = VK_S
		Key_T = VK_T
		Key_U = VK_U
		Key_V = VK_V
		Key_W = VK_W
		Key_X = VK_X
		Key_Y = VK_Y
		Key_Z = VK_Z
		F1 = VK_F1
		F2 = VK_F2
		F3 = VK_F3
		F4 = VK_F4
		F5 = VK_F5
		F6 = VK_F6
		F7 = VK_F7
		F8 = VK_F8
		F9 = VK_F9
		F10 = VK_F10
		F11 = VK_F11
		F12 = VK_F12
		F13 = VK_F13
		F14 = VK_F14
		F15 = VK_F15
		F16 = VK_F16
		F17 = VK_F17
		F18 = VK_F18
		F19 = VK_F19
		F20 = VK_F20
		F21 = VK_F21
		F22 = VK_F22
		F23 = VK_F23
		F24 = VK_F24
End Enum

Declare Sub ThreadsEnter

Declare Sub ThreadsLeave

Declare Function ThreadCreate_(ByVal ProcPtr_ As Sub ( ByVal userdata As Any Ptr ), ByVal param As Any Ptr = 0, ByVal stack_size As Integer = 0) As Any Ptr

Declare Sub ComponentGetBounds Alias "ComponentGetBounds" (Ctrl As My.Sys.ComponentModel.Component Ptr, ByRef ALeft As Integer, ByRef ATop As Integer, ByRef AWidth As Integer, ByRef AHeight As Integer)

Declare Sub ComponentSetBounds Alias "ComponentSetBounds"(Ctrl As My.Sys.ComponentModel.Component Ptr, ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)

	#include once "Component.bas"

