'###############################################################################
'#  ContainerControl.bi                                                        #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'###############################################################################

#include once "Control.bi"

Namespace My.Sys.Forms
	#define QContainerControl(__Ptr__) (*Cast(ContainerControl Ptr,__Ptr__))
	
	'Provides the base class for the containers (Windows, Linux, Android, Web).
	Private Type ContainerControl Extends Control
	Private:
	Protected:
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
			'Reads value from the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			'Writes value to the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		'Determines whether a control is automatically resized to display its entire contents (Windows, Linux).
		Declare Virtual Property AutoSize As Boolean
		Declare Virtual Property AutoSize(Value As Boolean)
		'Returns/sets a value that determines whether an object is visible or hidden (Windows, Linux, Web).
		Declare Virtual Property Visible As Boolean
		Declare Virtual Property Visible(Value As Boolean)
		Declare Operator Cast As Control Ptr
		Declare Operator Cast As Any Ptr
		Declare Constructor
		Declare Destructor
	End Type
End Namespace


	#include once "ContainerControl.bas"

