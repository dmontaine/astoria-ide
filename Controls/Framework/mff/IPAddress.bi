'###############################################################################
'#  IPAddress.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "Control.bi"

Namespace My.Sys.Forms
	#define QIPAddress(__Ptr__) (*Cast(IPAddress Ptr, __Ptr__))
	
	'`IPAddress` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`IPAddress` - An Internet Protocol (IP) address control allows the user to enter an IP address in an easily understood format (Windows, Linux).
	Private Type IPAddress Extends Control
	Private:
	Protected:
			Declare Static Sub WndProc(ByRef Message As Message)
			Declare Static Sub HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			Declare Static Function IPAddressWndProc(FWindow As HWND, Msg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
			'Loads IP configuration from stream
			Declare Virtual Function ReadProperty(PropertyName As String) As Any Ptr
			'Saves IP configuration to stream
			Declare Virtual Function WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property TabIndex As Integer
		'Controls focus order in tab sequence
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		'Enables/disables focus via Tab key
		Declare Property TabStop(Value As Boolean)
		Declare Property Text ByRef As WString
		'Current IP address in dotted notation (e.g., "192.168.1.1")
		Declare Property Text(ByRef Value As WString)
		Declare Operator Cast As My.Sys.Forms.Control Ptr
		'Resets all fields to zero values
		Declare Sub Clear
		Declare Constructor
		Declare Destructor
		'Triggered when any address field is modified
		OnChange        As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As IPAddress)
		'Raised when specific octet changes
		OnFieldChanged  As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As IPAddress, iField As Integer, iValue As Integer)
	End Type
End Namespace

	#include once "IPAddress.bas"

