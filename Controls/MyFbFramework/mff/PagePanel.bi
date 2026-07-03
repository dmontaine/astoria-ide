'###############################################################################
'#  PagePanel.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "ContainerControl.bi"
#include once "Graphic.bi"
#include once "NumericUpDown.bi"
#include once "Panel.bi"
#include once "CommandButton.bi"

Namespace My.Sys.Forms
	#define QPagePanel(__Ptr__) (*Cast(PagePanel Ptr, __Ptr__))
	
	'Used to group collections of controls (Windows, Linux, Android, Web).
	Private Type PagePanel Extends ContainerControl
	Private:
			Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
			Declare Static Sub WNDPROC(ByRef Message As Message)
		FSelectedPanelIndex As Integer
		FTransparent As Boolean
		Declare Static Sub GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
	Protected:
		NumericUpDownControl As NumericUpDown
			UpDownControl As UpDown
			UpDownPanel As Panel
			NeedBringToFront As Boolean
			Declare Sub UpDownControl_Changing(ByRef Sender As UpDown, Value As Integer, Direction As Integer)
		mnuContext As PopupMenu
		mnuShowPanel As MenuItem
		Declare Sub NumericUpDownControl_Change(ByRef Sender As NumericUpDown)
		Declare Sub MenuItem_Click(ByRef Sender As MenuItem)
		Declare Sub MoveNumericUpDownControl
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		'Returns/sets a graphic to be displayed in a control (Windows, Linux).
		Graphic As My.Sys.Drawing.GraphicType
		Declare Property SelectedPanel As Control Ptr
		Declare Property SelectedPanel(Value As Control Ptr)
		Declare Property SelectedPanelIndex As Integer
		Declare Property SelectedPanelIndex(Value As Integer)
		Declare Property TabIndex As Integer
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		Declare Property TabStop(Value As Boolean)
		Declare Property Transparent As Boolean
		Declare Property Transparent(Value As Boolean)
		Declare Sub Add(Ctrl As Control Ptr, Index As Integer = -1)
		Declare Sub CreateWnd
		Declare Operator Cast As Control Ptr
		Declare Constructor
		Declare Destructor
		OnSelChange    As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As PagePanel, NewIndex As Integer)
		OnSelChanging  As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As PagePanel, NewIndex As Integer)
	End Type
End Namespace

	#include once "PagePanel.bas"

