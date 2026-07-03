'################################################################################
'#  SearchBox.bi                                                                #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2024)                                          #
'################################################################################

#include once "TextBox.bi"
#include once "Panel.bi"

Namespace My.Sys.Forms
	#define QSearchBox(__Ptr__) (*Cast(SearchBox Ptr, __Ptr__))
	
	'`SearchBox` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`SearchBox` - The SearchBar is a control made to have a search entry (Windows, Linux).
	Private Type SearchBox Extends TextBox
	Private:
			Declare Static Sub WndProc(ByRef message As Message)
			Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
			Declare Sub imgSearch_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
			Declare Sub imgClear_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
			Declare Sub imgClear_Click(ByRef Sender As Control)
			As Panel imgSearch
			As Panel imgClear
			Declare Sub MoveIcons
	Protected:
		Declare Virtual Sub ProcessMessage(ByRef message As Message)
	Public:
			'Deserializes from persistence stream
			Declare Virtual Function ReadProperty(PropertyName As String) As Any Ptr
			'Serializes to persistence stream
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property TabIndex As Integer
		'Controls focus order in tab sequence
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		'Determines if control accepts focus via Tab key
		Declare Property TabStop(Value As Boolean)
		Declare Operator Cast As My.Sys.Forms.Control Ptr
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

	#include once "SearchBox.bas"

