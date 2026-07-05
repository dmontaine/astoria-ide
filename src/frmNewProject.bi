'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Panel.bi"
	
	Using My.Sys.Forms
	
	Type frmNewProject Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub lvTemplates_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvTemplates_SelectedItemChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvTemplates_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub cmdSaveLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdSaveLocation_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ListView lvTemplates
		Dim As CommandButton cmdOK, cmdCancel, cmdSaveLocation
		Dim As Label lblPrompt, lblSaveLocation
		Dim As TextBox txtSaveLocation
		Dim As Panel pnlSaveLocation, pnlBottom
		Dim As WStringList TemplateNames
		Dim As UString SelectedTemplate, SelectedFolder
		Dim As String NewName
	End Type
	
	Common Shared pfNewProject As frmNewProject Ptr
'#End Region

	#include once "frmNewProject.frm"
