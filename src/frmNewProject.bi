'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListView.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CheckBox.bi"
	#include once "mff/RadioButton.bi"
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
		Declare Static Sub optMode_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Sub optMode_Click(ByRef Sender As RadioButton)
		Declare Sub UpdateModeFields()
		Declare Function CloneGitRepository(ByRef GitURL As String, ByRef DestFolder As UString) As Boolean
		Declare Function FindProjectVfp(ByRef Folder As UString) As UString
		Declare Sub DeleteFolderRecursive(ByRef Folder As UString)
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
		Declare Sub WriteGitSupportFiles(ByRef DestFolder As UString, ByRef ProjectName As String, ByRef AuthorName As String, ByRef LicenseName As String, ByRef DescriptionText As String)
		Declare Function SshKeyExists() As Boolean
		Declare Function RemoteRepoExists(ByRef GitURL As String) As Boolean
		Declare Sub SetupGitRepository(ByRef ProjectFolder As UString, ByRef GitURL As String, ByRef GitUserName As String, ByRef GitEmail As String)
		Declare Function GitProviderHost(ByRef ProviderLabel As String) As UString
		Declare Function GitProviderGuideName(ByRef ProviderLabel As String) As String
		Declare Function BuildGitURL(ByRef ProviderLabel As String, ByRef GitUserName As String, ByRef ProjName As String) As UString
		Declare Constructor

		Dim As ComboBoxEdit cboTemplate
		Dim As CommandButton cmdOK, cmdCancel, cmdOpenExisting
		Dim As Label lblProjectTemplates, lblProjectName, lblFormName, lblModuleName, lblAuthor, lblLicense, lblDescription, lblAITool, lblGitProvider, lblGitProviderValue, lblGitUserName, lblGitEmail
		Dim As TextBox txtProjectName, txtFormName, txtModuleName, txtAuthor, txtDescription, txtGitUserName, txtGitEmail
		Dim As CheckBox chkAIFriendly
		Dim As RadioButton optCreateLocal, optUseExistingGit
		Dim As Label lblMode
		Dim As ComboBoxEdit cboLicense, cboAITool, cboGitProvider
		Dim As Panel pnlBottom, pnlMode, pnlProjectTemplate, pnlProjectName, pnlFormName, pnlModuleName, pnlAuthor, pnlDescription, pnlLicense, pnlGitProvider, pnlGitUserName, pnlGitEmail, pnlAIFriendly
		Dim As WStringList TemplateNames
		Dim As UString SelectedTemplate, SelectedFolder, SelectedProjectFile
		Dim As Boolean OpenExistingRequested
	End Type
	
	Common Shared pfNewProject As frmNewProject Ptr
'#End Region

	#include once "frmNewProject.frm"
