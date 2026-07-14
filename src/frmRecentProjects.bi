'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	
	Using My.Sys.Forms
	
	Type frmRecentProjects Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub lvRecent_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvRecent_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ListView lvRecent
		Dim As CommandButton cmdOK, cmdCancel
		Dim As Panel pnlBottom
		Dim As UString SelectedFile
	End Type
	
	Common Shared pfRecentProjects As frmRecentProjects Ptr
'#End Region

	#include once "frmRecentProjects.frm"
