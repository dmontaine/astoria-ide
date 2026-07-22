'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/ComboBoxEdit.bi"

	Using My.Sys.Forms

	Type frmNewProject Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdOpenExisting_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOpenExisting_Click(ByRef Sender As Control)
		Declare Static Sub cboTemplate_Change_(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit)
		Declare Sub cboTemplate_Change(ByRef Sender As ComboBoxEdit)
		Declare Static Sub chkAIFriendly_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub chkAIFriendly_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub AddProjectTemplateItem(ByRef TemplateName As String)
		Declare Function GetTemplateMainFile(ByRef TemplateName As String) As UString
		Declare Sub WriteLicenseFile(ByRef DestFolder As UString, ByRef LicenseName As String, ByRef AuthorName As String)
		Declare Function AIToolFolderName(ByRef ToolLabel As String) As UString
		Declare Sub StampAITemplate(ByRef DestFolder As UString, ByRef ToolFolder As UString, ByRef ProjectName As String, ByRef AuthorName As String, ByRef LicenseName As String, ByRef DescriptionText As String)
		Declare Sub CopyTemplateTree(ByRef SrcFolder As UString, ByRef DestFolder As UString, ByRef ProjectName As String, ByRef AuthorName As String, ByRef LicenseName As String, ByRef DescriptionText As String)
		Declare Sub StampTemplateFile(ByRef SrcFile As UString, ByRef DestFile As UString, ByRef ProjectName As String, ByRef AuthorName As String, ByRef LicenseName As String, ByRef DescriptionText As String)
		Declare Constructor

		Dim As ComboBoxEdit cboTemplate
		Dim As CommandButton cmdOK, cmdCancel, cmdOpenExisting
		Dim As Label lblProjectTemplates, lblProjectName, lblAuthor, lblLicense, lblDescription, lblAITool
		Dim As TextBox txtProjectName, txtAuthor, txtDescription
		Dim As CheckBox chkAIFriendly
		Dim As ComboBoxEdit cboLicense, cboAITool
		Dim As Panel pnlBottom, pnlButtons, pnlProjectTemplate, pnlProjectName, pnlAuthor, pnlDescription, pnlLicense, pnlAIFriendly
		Dim As WStringList TemplateNames
		Dim As UString SelectedTemplate, SelectedFolder, SelectedProjectFile
		Dim As Boolean OpenExistingRequested
	End Type

	Common Shared pfNewProject As frmNewProject Ptr
'#End Region

	#include once "frmNewProject.frm"
