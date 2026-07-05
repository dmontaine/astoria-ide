'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/Panel.bi"
	
	Using My.Sys.Forms
	
	Type frmNewFile Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub lvTemplates_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ListView lvTemplates
		Dim As CommandButton cmdOK, cmdCancel
		Dim As Label lblFileTemplates
		Dim As Panel pnlBottom
		Dim As WStringList TemplateFiles
		Dim As UString SelectedTemplate
	End Type
	
	Common Shared pfNewFile As frmNewFile Ptr
'#End Region

	#include once "frmNewFile.frm"
