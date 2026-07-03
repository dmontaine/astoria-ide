'###############################################################################
'#  RadioButton.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TRadioButton.bi                                                           #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.2.2                                                            #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "Control.bi"

Namespace My.Sys.Forms
	#define QRadioButton(__Ptr__) (*Cast(RadioButton Ptr,__Ptr__))
	
	'`RadioButton` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`RadioButton` - Displays an option that can be turned on or off (Windows, Linux, Android, Web).
	Private Type RadioButton Extends Control
	Private:
		FAlignment  As Integer
		FChecked    As Boolean
			Declare Static Sub WndProc(ByRef Message As Message)
		Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
	Protected:
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
			'Loads state from persistence stream
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
			'Saves state to persistence stream
			Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property Alignment As CheckAlignmentConstants
		'Sets text position relative to the radio circle (Left/Right)
		Declare Property Alignment(Value As CheckAlignmentConstants)
		Declare Property Caption ByRef As WString
		'Legacy text display (use Text property instead)
		Declare Property Caption(ByRef Value As WString)
		Declare Property Parent As Control Ptr
		'Reference to containing control
		Declare Property Parent(Value As Control Ptr)
		Declare Property TabIndex As Integer
		'Controls focus order in tab sequence
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		'Enables/disables focus via Tab key
		Declare Property TabStop(Value As Boolean)
		Declare Property Text ByRef As WString
		'Display label adjacent to radio button
		Declare Property Text(ByRef Value As WString)
		Declare Property Checked As Boolean
		'Indicates selection state (true=selected)
		Declare Property Checked(Value As Boolean)
		Declare Property Grouped As Boolean
		'Determines automatic mutual exclusion within parent container
		Declare Property Grouped(Value As Boolean)
		Declare Operator Cast As Control Ptr
		Declare Constructor
		Declare Destructor
		'Triggered when selection state changes
		OnClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	End Type
End Namespace

	#include once "RadioButton.bas"

