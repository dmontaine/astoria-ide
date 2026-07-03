'################################################################################
'#  TimerComponent.bi                                                           #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
'################################################################################

#include once "Component.bi"
#include once "IntegerList.bi"

Using My.Sys.ComponentModel

Dim Shared TimersList As IntegerList

Namespace My.Sys.Forms
	
	'A control which can execute code at regular intervals by causing a Timer event (Windows, Linux).
	Private Type TimerComponent Extends Component
	Private:
		FEnabled As Boolean
		FInterval As Integer
			Declare Static Sub TimerProc(hwnd As HWND, uMsg As UINT, idEvent As Integer, dwTime As DWORD)
	Public:
		ID            As Integer
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
			Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property Enabled As Boolean
		Declare Property Enabled(Value As Boolean)
		Declare Property Interval As Integer
		Declare Property Interval(Value As Integer)
		Declare Operator Cast As Any Ptr
		Declare Constructor
		Declare Destructor
		OnTimer As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	End Type
End Namespace

	#include once "TimerComponent.bas"

