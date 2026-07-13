'###############################################################################
'#  HorizontalBox.bi                                                                   #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "ContainerControl.bi"

Namespace My.Sys.Forms
	#define QHorizontalBox(__Ptr__) (*Cast(HorizontalBox Ptr,__Ptr__))
	
	'The Horizontal Box lays out its child controls horizontally and will not wrap onto a new line in any circumstances (Windows, Linux, Android)
	Private Type HorizontalBox Extends ContainerControl
	Private:
			Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
			Declare Static Sub WNDPROC(ByRef Message As Message)
	Protected:
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property Spacing As Integer
		Declare Property Spacing(Value As Integer)
		Declare Property TabIndex As Integer
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		Declare Property TabStop(Value As Boolean)
		Declare Virtual Property Text ByRef As WString
		Declare Virtual Property Text(ByRef Value As WString)
		Declare Virtual Property Visible As Boolean
		Declare Virtual Property Visible(Value As Boolean)
		Declare Operator Cast As Control Ptr
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

	#include once "HorizontalBox.bas"

