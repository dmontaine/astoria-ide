'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	#include once "mff/Dialogs.bi"
	
	Using My.Sys.Forms
	
	Type frmOpenProject Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdBrowse_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdBrowse_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub lvProjects_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvProjects_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ListView lvProjects
		Dim As CommandButton cmdOK, cmdCancel, cmdBrowse
		Dim As Panel pnlBottom
		Dim As WStringList ProjectFiles
		Dim As UString SelectedFile
	End Type
	
	Common Shared pfOpenProject As frmOpenProject Ptr
'#End Region

	#include once "frmOpenProject.frm"
