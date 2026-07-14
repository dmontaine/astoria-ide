'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	
	Using My.Sys.Forms
	
	Type frmOpenProjectFile Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub lvFiles_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvFiles_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ListView lvFiles
		Dim As CommandButton cmdOK, cmdCancel
		Dim As Panel pnlBottom
		Dim As UString SelectedFile
	End Type
	
	Common Shared pfOpenProjectFile As frmOpenProjectFile Ptr
'#End Region

	#include once "frmOpenProjectFile.frm"
