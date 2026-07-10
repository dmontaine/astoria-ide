'#########################################################
'#  frmProjectProperties.bas                             #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmProjectProperties.bi"
#include once "frmAdvancedOptions.bi"
#include once "TabWindow.bi"
#include once "Main.bi"
#include once "frmImageManager.bi"
#include once "mff/Dictionary.bi"

Dim Shared fProjectProperties As frmProjectProperties
pfProjectProperties = @fProjectProperties

'#Region "Form"
	Constructor frmProjectProperties
		' frmProjectProperties
		This.Name = "frmProjectProperties"
		This.Text = ("Project Properties")
		This.BorderStyle = FormBorderStyle.Fixed3D
		This.MaximizeBox = False
		This.MinimizeBox = False
		This.DefaultButton = @cmdOK
		This.CancelButton = @cmdCancel
		This.SetBounds 0, 0, 510, 458
		This.StartPosition = FormStartPosition.CenterParent
			This.Icon.LoadFromResourceID(1)
		This.Designer = @This
		This.OnCreate = @_Form_Create
		' tpGeneral
		tpGeneral.Name = "tpGeneral"
		tpGeneral.Text = ("General")
		tpGeneral.TabIndex = 1
		tpGeneral.SetBounds 2, 22, 487, 356
		tpGeneral.UseVisualStyleBackColor = True
		tpGeneral.Parent = @tabProperties
		' tpMake
		tpMake.Name = "tpMake"
		tpMake.Text = ("Version")
		tpMake.TabIndex = 19
		tpMake.SetBounds 2, 22, 487, 316
		tpMake.Visible = True
		tpMake.UseVisualStyleBackColor = True
		tpMake.Parent = @tabProperties
		' tpCompile
		tpCompile.Name = "tpCompile"
		tpCompile.Text = ("Compile")
		tpCompile.TabIndex = 44
		tpCompile.SetBounds 2, 22, 487, 346
		tpCompile.Visible = True
		tpCompile.UseVisualStyleBackColor = True
		tpCompile.Parent = @tabProperties
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ("OK")
		cmdOK.TabIndex = 84
		cmdOK.SetBounds 161, 389, 106, 34
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Default = True
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ("Cancel")
		cmdCancel.TabIndex = 85
		cmdCancel.SetBounds 269, 389, 120, 34
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This

		' tabProperties
		tabProperties.Name = "tabProperties"
		tabProperties.Text = "TabControl1"
		tabProperties.TabIndex = 0
		tabProperties.SetBounds 6, 6, 493, 381
		tabProperties.Parent = @This
		' lblProjectType
		lblProjectType.Name = "lblProjectType"
		lblProjectType.Text = ("Project Type") & ":"
		lblProjectType.TabIndex = 2
		lblProjectType.SetBounds 10, 8, 144, 18
		lblProjectType.Parent = @tpGeneral
		' cboProjectType
		cboProjectType.Name = "cboProjectType"
		cboProjectType.Text = "ComboBoxEdit1"
		cboProjectType.TabIndex = 3
		cboProjectType.SetBounds 10, 26, 202, 21
		cboProjectType.Parent = @tpGeneral
		' lblMainFile
		lblMainFile.Name = "lblMainFile"
		lblMainFile.Text = ("Main File") & ":"
		lblMainFile.TabIndex = 4
		lblMainFile.SetBounds 224, 8, 252, 18
		lblMainFile.Parent = @tpGeneral
		' cboMainFile
		cboMainFile.Name = "cboMainFile"
		cboMainFile.Text = "ComboBoxEdit11"
		cboMainFile.Sort = False
		cboMainFile.TabIndex = 5
		cboMainFile.SetBounds 224, 26, 252, 21
		cboMainFile.Parent = @tpGeneral
		' lblProjectName
		lblProjectName.Name = "lblProjectName"
		lblProjectName.Text = ("Project Name") & ":"
		lblProjectName.TabIndex = 10
		lblProjectName.SetBounds 10, 182, 204, 18
		lblProjectName.Parent = @tpGeneral
		' txtProjectName
		txtProjectName.Name = "txtProjectName"
		txtProjectName.Text = ""
		txtProjectName.TabIndex = 11
		txtProjectName.SetBounds 10, 200, 202, 21
		txtProjectName.Parent = @tpGeneral
		' lblProjectDescription
		lblProjectDescription.Name = "lblProjectDescription"
		lblProjectDescription.Text = ("Project Description") & ":"
		lblProjectDescription.TabIndex = 17
		lblProjectDescription.SetBounds 10, 298, 220, 18
		lblProjectDescription.Parent = @tpGeneral
		' txtProjectDescription
		txtProjectDescription.Name = "txtProjectDescription"
		txtProjectDescription.Text = ""
		txtProjectDescription.TabIndex = 18
		txtProjectDescription.SetBounds 10, 316, 466, 24
		txtProjectDescription.Parent = @tpGeneral
		' grbVersionNumber
		grbVersionNumber.Name = "grbVersionNumber"
		grbVersionNumber.Text = ("Version Number")
		grbVersionNumber.TabIndex = 20
		grbVersionNumber.SetBounds 10, 8, 228, 122
		grbVersionNumber.Parent = @tpMake
		' grbApplication
		grbApplication.Name = "grbApplication"
		grbApplication.Text = ("Application")
		grbApplication.TabIndex = 30
		grbApplication.SetBounds 253, 8, 225, 122
		grbApplication.Parent = @tpMake
		' grbVersionInformation
		grbVersionInformation.Name = "grbVersionInformation"
		grbVersionInformation.Text = ("Version Information")
		grbVersionInformation.TabIndex = 38
		grbVersionInformation.SetBounds 9, 136, 469, 211
		grbVersionInformation.Parent = @tpMake
		' lblIcon
		lblIcon.Name = "lblIcon"
		lblIcon.Text = ("Icon") & ":"
		lblIcon.TabIndex = 33
		lblIcon.SetBounds 0, 37, 34, 18
		lblIcon.Parent = @picApplication
		' lblTitle
		lblTitle.Name = "lblTitle"
		lblTitle.Text = ("Title") & ":"
		lblTitle.TabIndex = 31
		lblTitle.SetBounds 0, 11, 34, 18
		lblTitle.Parent = @picApplication
		' chkAutoIncrementVersion
		chkAutoIncrementVersion.Name = "chkAutoIncrementVersion"
		chkAutoIncrementVersion.Text = ("Auto Increment Version")
		chkAutoIncrementVersion.TabIndex = 29
		chkAutoIncrementVersion.SetBounds 6, 70, 204, 18
		chkAutoIncrementVersion.Parent = @picVersionNumber
		' lblMajor
		lblMajor.Name = "lblMajor"
		lblMajor.Text = ("Major") & ":"
		lblMajor.TabIndex = 21
		lblMajor.SetBounds 5, 12, 52, 18
		lblMajor.Parent = @picVersionNumber
		' lblMinor
		lblMinor.Name = "lblMinor"
		lblMinor.Text = ("Minor") & ":"
		lblMinor.TabIndex = 23
		lblMinor.SetBounds 58, 12, 52, 18
		lblMinor.Parent = @picVersionNumber
		' lblRevision
		lblRevision.Name = "lblRevision"
		lblRevision.Text = ("Revision") & ":"
		lblRevision.TabIndex = 25
		lblRevision.SetBounds 109, 12, 48, 18
		lblRevision.BorderStyle = BorderStyles.bsNone
		lblRevision.Parent = @picVersionNumber
		' lblBuild
		lblBuild.Name = "lblBuild"
		lblBuild.Text = ("Build") & ":"
		lblBuild.TabIndex = 27
		lblBuild.SetBounds 171, 12, 36, 18
		lblBuild.Parent = @picVersionNumber
		' cboResourceFile
		cboResourceFile.Name = "cboResourceFile"
		cboResourceFile.Text = "cboMainFile1"
		cboResourceFile.Sort = False
		cboResourceFile.TabIndex = 9
		cboResourceFile.SetBounds 224, 84, 252, 21
		cboResourceFile.Parent = @tpGeneral
		' lblResourceFile
		lblResourceFile.Name = "lblResourceFile"
		lblResourceFile.Text = ("Resource File") & " (" & ("For Windows") & "):"
		lblResourceFile.TabIndex = 8
		lblResourceFile.SetBounds 224, 66, 262, 18
		lblResourceFile.Parent = @tpGeneral
		' lblType
		lblType.Name = "lblType"
		lblType.Text = ("Type") & ":"
		lblType.TabIndex = 40
		lblType.SetBounds 7, 0, 82, 18
		lblType.Parent = @picVersionInformation
		' lblValue
		lblValue.Name = "lblValue"
		lblValue.Text = ("Value") & ":"
		lblValue.TabIndex = 42
		lblValue.SetBounds 237, 0, 136, 18
		lblValue.Parent = @picVersionInformation
		' txtHelpFileName
		txtHelpFileName.Name = "txtHelpFileName"
		txtHelpFileName.TabIndex = 15
		txtHelpFileName.SetBounds 10, 258, 202, 21
		txtHelpFileName.Text = ""
		txtHelpFileName.Parent = @tpGeneral
		' lblHelpFileName
		lblHelpFileName.Name = "lblHelpFileName"
		lblHelpFileName.Text = ("Help File") & ":"
		lblHelpFileName.TabIndex = 14
		lblHelpFileName.SetBounds 10, 240, 172, 18
		lblHelpFileName.Parent = @tpGeneral
		' grbCompileMode
		grbCompileMode.Name = "grbCompileMode"
		grbCompileMode.Text = ("Compile Mode")
		grbCompileMode.TabIndex = 87
		grbCompileMode.SetBounds 10, 10, 200, 60
		grbCompileMode.Parent = @tpCompile
		' optDevelopment
		optDevelopment.Name = "optDevelopment"
		optDevelopment.Text = ("Development (-g, no optimization)")
		optDevelopment.TabIndex = 48
		optDevelopment.Checked = True
		optDevelopment.SetBounds 16, 20, 175, 20
		optDevelopment.Parent = @grbCompileMode
		' optFinal
		optFinal.Name = "optFinal"
		optFinal.Text = ("Final (-O2, no debug info)")
		optFinal.TabIndex = 49
		optFinal.SetBounds 16, 42, 175, 20
		optFinal.Parent = @grbCompileMode
		' tpIncludes
		With tpIncludes
			.Name = "tpIncludes"
			.Text = ("Includes")
			.TabIndex = 95
			.Caption = ("Includes")
			.UseVisualStyleBackColor = True
			.SetBounds 65182, 22, 487, 356
			.Designer = @This
			.Parent = @tabProperties
		End With
		' Initialization
		cboProjectType.AddItem ("Executable")
		cboProjectType.AddItem ("Dynamic library")
		cboProjectType.AddItem ("Static library")
		cboSubsystem.AddItem ("(not selected)")
		cboSubsystem.AddItem ("Console")
		cboSubsystem.AddItem ("GUI")
		' cmdAdvancedOptions
		cmdAdvancedOptions.Name = "cmdAdvancedOptions"
		cmdAdvancedOptions.Text = ("Compiler Warnings")
		cmdAdvancedOptions.TabIndex = 55
		cmdAdvancedOptions.SetBounds 220, 42, 224, 24
		cmdAdvancedOptions.OnClick = @cmdAdvancedOptions_Click
		cmdAdvancedOptions.Parent = @tpCompile
		' lstType
		With lstType
			.Name = "lstType"
			.Text = "lstType"
		lstType.TabIndex = 41
			.SetBounds 7, 16, 214, 167
			.OnChange = @lstType_Change
			.Parent = @picVersionInformation
		End With
		' txtValue
		With txtValue
			.Name = "txtValue"
			.TabIndex = 43
			.SetBounds 237, 16, 212, 162
			.OnLostFocus = @txtValue_LostFocus
			.Parent = @picVersionInformation
		End With
		' txtTitle
		With txtTitle
			.Name = "txtTitle"
			.TabIndex = 32
			.SetBounds 40, 11, 159, 18
			.Parent = @picApplication
		End With
		' txtIcon
		With txtIcon
			.Name = "txtIcon"
			.TabIndex = 34
			.SetBounds 40, 37, 74, 18
			.ReadOnly = False
			.Parent = @picApplication
		End With
		' txtBuild
		With txtBuild
			.Name = "txtBuild"
			.TabIndex = 28
			.SetBounds 161, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtRevision
		With txtRevision
			.Name = "txtRevision"
			.TabIndex = 26
			.SetBounds 109, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtMinor
		With txtMinor
			.Name = "txtMinor"
			.TabIndex = 24
			.SetBounds 58, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' txtMajor
		With txtMajor
			.Name = "txtMajor"
			.TabIndex = 22
			.SetBounds 6, 32, 45, 21
			.Parent = @picVersionNumber
		End With
		' Initialization
		lstType.AddItem ("Company Name")
		lstType.AddItem ("File Description")
		lstType.AddItem ("Internal Name")
		lstType.AddItem ("Legal Copyright")
		lstType.AddItem ("Legal Trademarks")
		lstType.AddItem ("Original Filename")
		lstType.AddItem ("Product Name")
		' pnlVersionNumber
		With picVersionNumber
			.Name = "picVersionNumber"
			.TabIndex = 88
			.SetBounds 16, 20, 212, 90
			.Parent = @tpMake
		End With
		' picVersionInformation
		With picApplication
			.Name = "picApplication"
			.TabIndex = 89
			.SetBounds 262, 20, 202, 100
			.Parent = @tpMake
		End With
		' picVersionInformation
		With picVersionInformation
			.Name = "picVersionInformation"
			.TabIndex = 39
			.SetBounds 16, 155, 450, 181
			.Parent = @tpMake
		End With
		' CommandButton1
		With CommandButton1
			.Name = "CommandButton1"
			.Text = "..."
			.TabIndex = 35
			.SetBounds 114, 36, 20, 20

			.Designer = @This
			.OnClick = @CommandButton1_Click_
			.Parent = @picApplication
		End With
		' imgIcon
		With imgIcon
			.Name = "imgIcon"
			.Text = "lblIcon"
			.SetBounds 156, 41, 32, 32
			.Parent = @picApplication
		End With
		' chkPassAllModuleFilesToCompiler
		With chkPassAllModuleFilesToCompiler
			.Name = "chkPassAllModuleFilesToCompiler"
			.Text = ("Pass All Module Files To Compiler")
			.TabIndex = 16
			.SetBounds 11, 120, 192, 22

			.Parent = @tpGeneral
		End With
		' cboSubsystem
		With cboSubsystem
			.Name = "cboSubsystem"
			.Text = "cboSubsystem"
			.TabIndex = 7
			.SetBounds 10, 84, 202, 21
			.Parent = @tpGeneral
		End With
		' lblSubsystem
		With lblSubsystem
			.Name = "lblSubsystem"
			.Text = ("Subsystem") & " (" & ("For Windows") & "):"
			.TabIndex = 6
			.SetBounds 10, 66, 202, 18

			.Parent = @tpGeneral
		End With
		' BrowseD
		With BrowseD
			.Name = "BrowseD"
			.SetBounds 60, 400, 16, 16
			.Parent = @This
		End With
		' OpenD
		With OpenD
			.Name = "OpenD"
			.SetBounds 80, 400, 16, 16
			.Parent = @This
		End With
		' chkManifest
		With chkManifest
			.Name = "chkManifest"
			.Text = ("Manifest")
			.TabIndex = 36

			.SetBounds 4, 59, 130, 20
			.Designer = @This
			.OnClick = @chkManifest_Click_
			.Parent = @picApplication
		End With
		' chkRunAsAdministrator
		With chkRunAsAdministrator
			.Name = "chkRunAsAdministrator"
			.Text = ("Run as administrator")
			.TabIndex = 37

			.SetBounds 30, 80, 170, 20
			.Designer = @This
			.Parent = @picApplication
		End With
		' chkOpenProjectAsFolder
		With chkOpenProjectAsFolder
			.Name = "chkOpenProjectAsFolder"
			.Text = ("Open Project As Folder")
			.TabIndex = 90
			.ControlIndex = 14

			.SetBounds 11, 147, 192, 22
			.Designer = @This
			.Parent = @tpGeneral
		End With
		' grbIncludePaths
		With grbIncludePaths
			.Name = "grbIncludePaths"
			.Text = ("Include Paths")
			.TabIndex = 96
			.Caption = ("Include Paths")
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 8, 467, 225
			.Designer = @This
			.Parent = @tpIncludes
		End With
		' grbLibraryPaths
		With grbLibraryPaths
			.Name = "grbLibraryPaths"
			.Text = ("Library Paths")
			.TabIndex = 97
			.Caption = ("Library Paths")
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.SetBounds 10, 240, 467, 107
			.Designer = @This
			.Parent = @tpIncludes
		End With
		' lblComponents
		With lblComponents
			.Name = "lblComponents"
			.Text = ("Components") & ":"
			.TabIndex = 101
			.Caption = ("Components") & ":"
			.Align = DockStyle.alTop
			.SetBounds 0, 0, 440, 20
			.Designer = @This
			.Parent = @picComponents
		End With
		' lstComponents
		With lstComponents
			.Name = "lstComponents"
			.Text = "ListControl1"
			.TabIndex = 98
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 25
			.SetBounds 0, 20, 425, 56
			.Designer = @This
			.Parent = @picComponents
		End With
		' lblOthers
		With lblOthers
			.Name = "lblOthers"
			.Text = ("Others") & ":"
			.TabIndex = 102
			.Caption = ("Others") & ":"
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 0
			.SetBounds 0, 10, 437, 20
			.Designer = @This
			.Parent = @picOtherIncludes
		End With
		' lstOtherIncludes
		With lstOtherIncludes
			.Name = "lstOtherIncludes"
			.Text = "ListControl2"
			.TabIndex = 99
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 25
			.SetBounds 0, 30, 412, 56
			.Designer = @This
			.Parent = @picOtherIncludes
		End With
		' lstLibraryPaths
		With lstLibraryPaths
			.Name = "lstLibraryPaths"
			.Text = "ListControl3"
			.TabIndex = 100
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 25
			.SetBounds 15, 22, 412, 69
			.Designer = @This
			.Parent = @grbLibraryPaths
		End With
		' cmdAddComponent
		With cmdAddComponent
			.Name = "cmdAddComponent"
			.Text = "+"
			.TabIndex = 103
			.Caption = "+"
			.SetBounds 413, 19, 24, 22
			.Designer = @This
			.OnClick = @_cmdAddComponent_Click
			.Parent = @picComponents
		End With
		' cmdRemoveComponent
		With cmdRemoveComponent
			.Name = "cmdRemoveComponent"
			.Text = "-"
			.TabIndex = 104
			.ControlIndex = 4
			.Caption = "-"
			.SetBounds 413, 41, 24, 22
			.Designer = @This
			.OnClick = @_cmdRemoveComponent_Click
			.Parent = @picComponents
		End With
		' cmdAddOtherInclude
		With cmdAddOtherInclude
			.Name = "cmdAddOtherInclude"
			.Text = "+"
			.TabIndex = 105
			.ControlIndex = 5
			.SetBounds 413, 19, 24, 22
			.Designer = @This
			.OnClick = @_cmdAddOtherInclude_Click
			.Parent = @picOtherIncludes
		End With
		' cmdRemoveOtherInclude
		With cmdRemoveOtherInclude
			.Name = "cmdRemoveOtherInclude"
			.Text = "-"
			.TabIndex = 106
			.ControlIndex = 4
			.SetBounds 413, 41, 24, 22
			.Designer = @This
			.OnClick = @_cmdRemoveOtherInclude_Click
			.Parent = @picOtherIncludes
		End With
		' cmdAddLibrary
		With cmdAddLibrary
			.Name = "cmdAddLibrary"
			.Text = "+"
			.TabIndex = 107
			.ControlIndex = 1
			.SetBounds 428, 21, 24, 22
			.Designer = @This
			.OnClick = @_cmdAddLibrary_Click
			.Parent = @grbLibraryPaths
		End With
		' cmdRemoveLibrary
		With cmdRemoveLibrary
			.Name = "cmdRemoveLibrary"
			.Text = "-"
			.TabIndex = 108
			.ControlIndex = 2
			.SetBounds 428, 43, 24, 22
			.Designer = @This
			.OnClick = @_cmdRemoveLibrary_Click
			.Parent = @grbLibraryPaths
		End With
		' picComponents
		With picComponents
			.Name = "picComponents"
			.Text = ""
			.TabIndex = 109
			.ControlIndex = 2
			.SetBounds 25, 27, 437, 90
			.Designer = @This
			.Parent = @tpIncludes
		End With
		' picOtherIncludes
		With picOtherIncludes
			.Name = "picOtherIncludes"
			.Text = ""
			.TabIndex = 119
			.ControlIndex = 3
			.SetBounds 25, 127, 437, 90
			.Designer = @This
			.Parent = @tpIncludes
		End With
	End Constructor
	
	Private Sub frmProjectProperties._cmdRemoveLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdRemoveLibrary_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdAddLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdAddLibrary_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdRemoveOtherInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdRemoveOtherInclude_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdAddOtherInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdAddOtherInclude_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdRemoveComponent_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdRemoveComponent_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._cmdAddComponent_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).cmdAddComponent_Click(Sender)
	End Sub
	
	Private Sub frmProjectProperties._Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).Form_Create(Sender)
	End Sub
	
	Private Sub frmProjectProperties.chkManifest_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		(*Cast(frmProjectProperties Ptr, Sender.Designer)).chkManifest_Click(Sender)
	End Sub
	

'#End Region


Private Sub frmProjectProperties.cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fProjectProperties
		If .ProjectTreeNode = 0 Then Exit Sub
		Dim As ProjectElement Ptr ppe = .ProjectTreeNode->Tag
		If ppe = 0 Then
			ppe = _New( ProjectElement)
			WLet(ppe->FileName, "")
		End If
		WLet(ppe->MainFileName, .MainFiles.Get(.cboMainFile.Text))
		WLet(ppe->ResourceFileName, .ResourceFiles.Get(.cboResourceFile.Text))
		ppe->ProjectType = .cboProjectType.ItemIndex
		ppe->Subsystem = .cboSubsystem.ItemIndex
		WLet(ppe->ProjectName, .txtProjectName.Text)
		WLet(ppe->HelpFileName, .txtHelpFileName.Text)
		WLet(ppe->ProjectDescription, .txtProjectDescription.Text)
		ppe->PassAllModuleFilesToCompiler = .chkPassAllModuleFilesToCompiler.Checked
		ppe->OpenProjectAsFolder = .chkOpenProjectAsFolder.Checked
		ppe->MajorVersion = Val(.txtMajor.Text)
		ppe->MinorVersion = Val(.txtMinor.Text)
		ppe->RevisionVersion = Val(.txtRevision.Text)
		ppe->BuildVersion = Val(.txtBuild.Text)
		ppe->AutoIncrementVersion = .chkAutoIncrementVersion.Checked
		WLet(ppe->ApplicationTitle, .txtTitle.Text)
		WLet(ppe->ApplicationIcon, .txtIcon.Text)
		ppe->Manifest = .chkManifest.Checked 
		ppe->RunAsAdministrator = .chkRunAsAdministrator.Checked 
		WLet(ppe->CompanyName, .Types.Get(("Company Name")))
		WLet(ppe->FileDescription, .Types.Get(("File Description")))
		WLet(ppe->InternalName, .Types.Get(("Internal Name")))
		WLet(ppe->LegalCopyright, .Types.Get(("Legal Copyright")))
		WLet(ppe->LegalTrademarks, .Types.Get(("Legal Trademarks")))
		WLet(ppe->OriginalFilename, .Types.Get(("Original Filename")))
		WLet(ppe->ProductName, .Types.Get(("Product Name")))
		If .optDevelopment.Checked Then ppe->CompileMode = Development Else ppe->CompileMode = Final
		ppe->Components.Clear
		For i As Integer = 0 To .lstComponents.ItemCount - 1
			Dim As UString ComponentPath = GetControlLibraryVfpPath(.lstComponents.Item(i))
			If ComponentPath <> "" Then ppe->Components.Add ComponentPath
		Next
		ppe->IncludePaths.Clear
		For i As Integer = 0 To .lstOtherIncludes.ItemCount - 1
			ppe->IncludePaths.Add .lstOtherIncludes.Item(i)
		Next
		ppe->LibraryPaths.Clear
		For i As Integer = 0 To .lstLibraryPaths.ItemCount - 1
			ppe->LibraryPaths.Add .lstLibraryPaths.Item(i)
		Next
		WLet(ppe->CommandLineArguments, "")
		If Not EndsWith(.ProjectTreeNode->Text, "*") Then .ProjectTreeNode->Text &= "*"
		.CloseForm
	End With
End Sub

Private Sub frmProjectProperties.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fProjectProperties.CloseForm
End Sub

Sub AddToCombo(ByRef tn As TreeNode Ptr)
	With fProjectProperties
		Dim As ExplorerElement Ptr ee = tn->Tag
		If EndsWith(LCase(tn->Text), ".rc") OrElse EndsWith(LCase(tn->Text), ".res") Then
			.cboResourceFile.AddItem tn->Text
			.ResourceFiles.Add tn->Text, IIf(ee, *ee->FileName, WStr(""))
		ElseIf EndsWith(LCase(tn->Text), ".xpm") Then
		ElseIf LCase(tn->Text) = "makefile" Then
		ElseIf EndsWith(LCase(tn->Text), ".bat") Then
		ElseIf EndsWith(LCase(tn->Text), ".sh") OrElse InStr(tn->Text, ".") = 0 Then
		Else
			.cboMainFile.AddItem tn->Text
			.MainFiles.Add tn->Text, IIf(ee, *ee->FileName, WStr(""))
		End If
	End With
End Sub

Sub AddToComboFileName(ByRef FileName As WString)
	With fProjectProperties
		Dim As UString Text = GetFileName(FileName)
		If EndsWith(LCase(Text), ".rc") OrElse EndsWith(LCase(Text), ".res") Then
			.cboResourceFile.AddItem Text
			.ResourceFiles.Add Text, FileName
		ElseIf EndsWith(LCase(Text), ".xpm") Then
		ElseIf LCase(Text) = "makefile" Then
		ElseIf EndsWith(LCase(Text), ".bat") Then
		ElseIf EndsWith(LCase(Text), ".sh") OrElse InStr(Text, ".") = 0 Then
		Else
			.cboMainFile.AddItem Text
			.MainFiles.Add Text, FileName
		End If
	End With
End Sub

Public Sub frmProjectProperties.RefreshProperties()
	With fProjectProperties
		Dim As TreeNode Ptr ptn = ptvExplorer->SelectedNode
		Dim As TreeNode Ptr tn1, tn2
		If ptn = 0 Then Exit Sub
		ptn = GetParentNode(ptn)
		Dim As ExplorerElement Ptr ee = ptn->Tag
		Dim As ProjectElement Ptr ppe
		.lstComponents.Clear
		.lstOtherIncludes.Clear
		.lstLibraryPaths.Clear
		.cboMainFile.Clear
		.cboResourceFile.Clear
		.MainFiles.Clear
		.ResourceFiles.Clear
		.cboMainFile.AddItem ("(not selected)")
		.cboResourceFile.AddItem ("(not selected)")
		Dim As Boolean bSetted = False
		If ptn->ImageKey = "Project" OrElse ee AndAlso *ee Is ProjectElement Then
			.ProjectTreeNode = ptn
			ppe = Cast(ProjectElement Ptr, ee)
			If ptn->ImageKey = "Project" AndAlso Not ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Then
				For i As Integer = 0 To ptn->Nodes.Count - 1
					tn1 = ptn->Nodes.Item(i)
					If tn1->Tag <> 0 Then
						AddToCombo tn1
					ElseIf tn1->Nodes.Count > 0 Then
						For j As Integer = 0 To tn1->Nodes.Count - 1
							tn2 = tn1->Nodes.Item(j)
							AddToCombo tn2
						Next
					End If
				Next
			Else
				For i As Integer = 0 To ppe->Files.Count - 1
					AddToComboFileName ppe->Files.Item(i)
				Next
			End If
			If ppe Then
				bSetted = True
				.cboProjectType.ItemIndex = ppe->ProjectType
				.cboSubsystem.ItemIndex = ppe->Subsystem
				If .MainFiles.IndexOf(*ppe->MainFileName) > -1 Then .cboMainFile.Text = .MainFiles.Item(.MainFiles.IndexOf(*ppe->MainFileName))->Key Else .cboMainFile.ItemIndex = 0
				If .ResourceFiles.IndexOf(*ppe->ResourceFileName) > -1 Then .cboResourceFile.Text = .ResourceFiles.Item(.ResourceFiles.IndexOf(*ppe->ResourceFileName))->Key Else .cboResourceFile.ItemIndex = 0
				.txtProjectName.Text = *ppe->ProjectName
				.txtHelpFileName.Text = *ppe->HelpFileName
				.txtProjectDescription.Text = *ppe->ProjectDescription
				.chkPassAllModuleFilesToCompiler.Checked = ppe->PassAllModuleFilesToCompiler
				.chkOpenProjectAsFolder.Checked = ppe->OpenProjectAsFolder
				.txtMajor.Text = WStr(ppe->MajorVersion)
				.txtMinor.Text = WStr(ppe->MinorVersion)
				.txtRevision.Text = WStr(ppe->RevisionVersion)
				.txtBuild.Text = WStr(ppe->BuildVersion)
				.chkAutoIncrementVersion.Checked = ppe->AutoIncrementVersion
				.txtTitle.Text = *ppe->ApplicationTitle
				.txtIcon.Text = *ppe->ApplicationIcon
				If Trim(*ppe->ApplicationIcon) <> "" Then
					imgIcon.Graphic.Icon.LoadFromFile(GetResNamePath(*ppe->ApplicationIcon, GetResourceFile(True)), 32, 32)
				End If
				.chkManifest.Checked = ppe->Manifest
				.chkManifest_Click(.chkManifest)
				.chkRunAsAdministrator.Checked = ppe->RunAsAdministrator
				.Types.Set ("Company Name"), *ppe->CompanyName
				.Types.Set ("File Description"), *ppe->FileDescription
				.Types.Set ("Internal Name"), *ppe->InternalName
				.Types.Set ("Legal Copyright"), *ppe->LegalCopyright
				.Types.Set ("Legal Trademarks"), *ppe->LegalTrademarks
				.Types.Set ("Original Filename"), *ppe->OriginalFilename
				.Types.Set ("Product Name"), *ppe->ProductName
				.optDevelopment.Checked = (ppe->CompileMode = Development)
				.optFinal.Checked = (ppe->CompileMode = Final)
				For i As Integer = 0 To ppe->Components.Count - 1
					Dim As UString ComponentPath = GetControlLibraryVfpPath(ppe->Components.Item(i))
					If ComponentPath <> "" Then .lstComponents.AddItem ComponentPath
				Next
				For i As Integer = 0 To ppe->IncludePaths.Count - 1
					.lstOtherIncludes.AddItem ppe->IncludePaths.Item(i)
				Next
				For i As Integer = 0 To ppe->LibraryPaths.Count - 1
					.lstLibraryPaths.AddItem ppe->LibraryPaths.Item(i)
				Next
			End If
		Else
			.ProjectTreeNode = ptn
		End If
		If Not bSetted Then
			.cboProjectType.ItemIndex = -1
			.cboSubsystem.ItemIndex = -1
			.cboMainFile.ItemIndex = -1
			.cboResourceFile.ItemIndex = -1
			.txtProjectName.Text = ""
			.txtHelpFileName.Text = ""
			.txtProjectDescription.Text = ""
			.chkPassAllModuleFilesToCompiler.Checked = False
			.chkOpenProjectAsFolder.Checked = False
			.txtMajor.Text = ""
			.txtMinor.Text = ""
			.txtRevision.Text = ""
			.txtBuild.Text = ""
			.chkAutoIncrementVersion.Checked = False
			.txtTitle.Text = ""
			.txtIcon.Text = ""
			.chkManifest.Checked = True
			.chkRunAsAdministrator.Checked = False
			.chkManifest_Click(.chkManifest)
		End If
	End With
End Sub

Private Sub frmProjectProperties.lstType_Change(ByRef Designer As My.Sys.Object, ByRef Sender As ListControl)
	With fProjectProperties
		.txtValue.Text = .Types.Get(.lstType.Text)
	End With
End Sub

Private Sub frmProjectProperties.txtValue_LostFocus(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
	With fProjectProperties
		.Types.Set .lstType.Text, .txtValue.Text
	End With
End Sub

Private Sub frmProjectProperties.cmdAdvancedOptions_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With *pfAdvancedOptions
		.ProjectTreeNode = fProjectProperties.ProjectTreeNode
		.chkShowUnusedLabelWarnings.Checked = False
		.chkShowUnusedFunctionWarnings.Checked = False
		.chkShowUnusedVariableWarnings.Checked = False
		.chkShowUnusedButSetVariableWarnings.Checked = False
		.chkShowMainWarnings.Checked = False
		If .ProjectTreeNode <> 0 Then
			Dim As ProjectElement Ptr ppe = .ProjectTreeNode->Tag
			If ppe <> 0 Then
				.chkShowUnusedLabelWarnings.Checked = ppe->ShowUnusedLabelWarnings
				.chkShowUnusedFunctionWarnings.Checked = ppe->ShowUnusedFunctionWarnings
				.chkShowUnusedVariableWarnings.Checked = ppe->ShowUnusedVariableWarnings
				.chkShowUnusedButSetVariableWarnings.Checked = ppe->ShowUnusedButSetVariableWarnings
				.chkShowMainWarnings.Checked = ppe->ShowMainWarnings
			End If
		End If
		.ShowModal fProjectProperties
	End With
End Sub

Private Sub frmProjectProperties.optDevelopment_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
End Sub

Private Sub frmProjectProperties.optFinal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
End Sub

Private Sub frmProjectProperties.CommandButton1_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmProjectProperties Ptr, Sender.Designer)).CommandButton1_Click(Sender)
End Sub
Private Sub frmProjectProperties.CommandButton1_Click(ByRef Sender As Control)
	pfImageManager->OnlyIcons = True
	pfImageManager->WithoutMainNode = True
	If pfImageManager->ShowModal(Me) = ModalResults.OK Then
		If pfImageManager->SelectedItem <> 0 Then
			txtIcon.Text = pfImageManager->SelectedItem->Text(0)
				imgIcon.Graphic.Icon.LoadFromFile(GetRelativePath(pfImageManager->SelectedItem->Text(2), pfImageManager->ResourceFile), 32, 32)
		End If
	End If
	pfImageManager->WithoutMainNode = False
End Sub


Private Sub frmProjectProperties.chkManifest_Click(ByRef Sender As CheckBox)
	chkRunAsAdministrator.Enabled = chkManifest.Checked
End Sub

Private Sub frmProjectProperties.Form_Create(ByRef Sender As Control)
	fProjectProperties.RefreshProperties
End Sub

Private Sub frmProjectProperties.cmdAddComponent_Click(ByRef Sender As Control)
	pfPath->txtPath.Text = ExePath & WindowsSlash & "Controls"
	pfPath->ChooseFolder = True
	If pfPath->ShowModal(Me) = ModalResults.OK Then
		Dim As UString controlsRoot = WinOsPath(ExePath & WindowsSlash & "Controls")
		Dim As UString selected = WinOsPath(pfPath->txtPath.Text)
		If Not StartsWith(LCase(selected), LCase(controlsRoot)) Then
			MsgBox ("Control libraries must be in the editor Controls folder.") & ":" & WChr(13, 10) & WChr(13, 10) & FormatMsgPathU(selected), , mtWarning
			Return
		End If
		Dim As UString vfpPath = GetControlLibraryVfpPath(selected)
		If vfpPath = "" Then
			MsgBox ("Control library must be a subfolder of Controls."), , mtWarning
			Return
		End If
		If Not lstComponents.Items.Contains(vfpPath) Then
			lstComponents.AddItem vfpPath
		Else
			MsgBox ("This path is exists!")
		End If
	End If
End Sub

Private Sub frmProjectProperties.cmdRemoveComponent_Click(ByRef Sender As Control)
	Var Index = lstComponents.ItemIndex
	If Index <> -1 Then lstComponents.RemoveItem Index
End Sub

Private Sub frmProjectProperties.cmdAddOtherInclude_Click(ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal(Me) = ModalResults.OK Then
		If Not lstOtherIncludes.Items.Contains(pfPath->txtPath.Text) Then
			lstOtherIncludes.AddItem pfPath->txtPath.Text
		Else
			MsgBox ("This path is exists!")
		End If
	End If
End Sub

Private Sub frmProjectProperties.cmdRemoveOtherInclude_Click(ByRef Sender As Control)
	Var Index = lstOtherIncludes.ItemIndex
	If Index <> -1 Then lstOtherIncludes.RemoveItem Index
End Sub

Private Sub frmProjectProperties.cmdAddLibrary_Click(ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal(Me) = ModalResults.OK Then
		If Not lstLibraryPaths.Items.Contains(pfPath->txtPath.Text) Then
			lstLibraryPaths.AddItem pfPath->txtPath.Text
		Else
			MsgBox ("This path is exists!")
		End If
	End If
End Sub

Private Sub frmProjectProperties.cmdRemoveLibrary_Click(ByRef Sender As Control)
	Var Index = lstLibraryPaths.ItemIndex
	If Index <> -1 Then lstLibraryPaths.RemoveItem Index
End Sub

