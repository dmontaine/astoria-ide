'#########################################################
'#  frmProjectProperties.bi                              #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/TabControl.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/TextBox.bi"
#include once "mff/GroupBox.bi"
#include once "mff/Panel.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ImageBox.bi"
#include once "mff/ListControl.bi"
#include once "mff/Picture.bi"
#include once "mff/RadioButton.bi"
#include once "mff/Dictionary.bi"
#include once "mff/TreeView.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmProjectProperties Extends Form
		Declare Static Sub cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub pnlApplication_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub tpCompile_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub lstType_Change(ByRef Designer As My.Sys.Object, ByRef Sender As ListControl)
		Declare Static Sub txtValue_LostFocus(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
		Declare Static Sub Form_Show      (ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Sub RefreshProperties()
		Declare Static Sub cmdAdvancedOptions_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub CommandButton1_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub CommandButton1_Click(ByRef Sender As Control)
		Declare Static Sub chkManifest_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Sub chkManifest_Click(ByRef Sender As CheckBox)
		Declare Static Sub optDevelopment_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Static Sub optFinal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Declare Static Sub _Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Static Sub _cmdAddComponent_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAddComponent_Click(ByRef Sender As Control)
		Declare Static Sub _cmdRemoveComponent_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRemoveComponent_Click(ByRef Sender As Control)
		Declare Static Sub _cmdAddOtherInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAddOtherInclude_Click(ByRef Sender As Control)
		Declare Static Sub _cmdRemoveOtherInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRemoveOtherInclude_Click(ByRef Sender As Control)
		Declare Static Sub _cmdAddLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAddLibrary_Click(ByRef Sender As Control)
		Declare Static Sub _cmdRemoveLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRemoveLibrary_Click(ByRef Sender As Control)
		Declare Constructor
		
		Dim As TabControl tabProperties
		Dim As TabPage tpGeneral, tpMake, tpCompile, tpIncludes
		Dim As CommandButton cmdOK, cmdCancel, cmdAdvancedOptions, CommandButton1, cmdAddComponent, cmdRemoveComponent, cmdAddOtherInclude, cmdRemoveOtherInclude, cmdAddLibrary, cmdRemoveLibrary
		Dim As Label lblProjectType, lblMainFile, lblProjectName, lblProjectDescription, lblIcon, lblTitle, lblMajor, lblMinor, lblRevision, lblBuild, lblResourceFile, lblType, lblValue, lblHelpFileName, lblSubsystem, lblComponents, lblOthers
		Dim As Picture picVersionNumber, picApplication, picVersionInformation, picComponents, picOtherIncludes
		Dim As ComboBoxEdit cboProjectType, cboMainFile, cboResourceFile, cboSubsystem
		Dim As TextBox txtProjectName, txtProjectDescription, txtIcon, txtTitle, txtMajor, txtMinor, txtRevision, txtBuild, txtValue, txtHelpFileName
		Dim As GroupBox grbVersionNumber, grbApplication, grbVersionInformation, grbCompileMode, grbIncludePaths, grbLibraryPaths
		Dim As CheckBox chkAutoIncrementVersion, chkPassAllModuleFilesToCompiler, chkManifest, chkRunAsAdministrator, chkOpenProjectAsFolder
		Dim As ListControl lstType, lstComponents, lstOtherIncludes, lstLibraryPaths
		Dim As RadioButton optDevelopment, optFinal
		Dim As Dictionary Types, MainFiles, ResourceFiles
		Dim As TreeNode Ptr ProjectTreeNode
		Dim As ImageBox imgIcon
		Dim As FolderBrowserDialog BrowseD
		Dim As OpenFileDialog OpenD
	End Type
	
	Common Shared pfProjectProperties As frmProjectProperties Ptr
'#End Region

	#include once "frmProjectProperties.frm"
