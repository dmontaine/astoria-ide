'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/TabControl.bi"
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
		Declare Static Sub lvExamples_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvExamples_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub tabOpenProject_SelChange_(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, NewIndex As Integer)
		Declare Sub tabOpenProject_SelChange(ByRef Sender As TabControl, NewIndex As Integer)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub FillListView(ByRef lv As ListView, ByRef files As WStringList)
		Declare Sub ScanFolderSubdirsForVfp(ByVal root As UString, ByRef files As WStringList)
		Declare Sub PopulateProjectsList()
		Declare Sub PopulateExamplesList()
		Declare Constructor
		
		Dim As TabControl tabOpenProject
		Dim As TabPage tpProjects, tpExamples
		Dim As ListView lvProjects, lvExamples
		Dim As CommandButton cmdOK, cmdCancel, cmdBrowse
		Dim As Panel pnlBottom
		Dim As WStringList ProjectFiles, ExampleFiles
		Dim As UString SelectedFile
		Dim As Boolean ExamplesLoaded
	End Type
	
	Common Shared pfOpenProject As frmOpenProject Ptr
'#End Region

	#include once "frmOpenProject.frm"
