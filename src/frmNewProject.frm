	'#Compile -exx "Form1.rc"
'#Region "Form"
	#include once "frmNewProject.bi"
	
	Constructor frmNewProject
		With This
			.Name = "frmNewProject"
			.Text = ("New Project")
				.Icon.LoadFromResourceID(1)
			.Designer = @This
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.OnCreate = @Form_Create_
			.SetBounds 0, 0, 480, 418
			.StartPosition = FormStartPosition.CenterParent
		End With
		' pnlBottom — footer: Project Name / Primary Form Name / Primary Module Name /
		' Author / License / Use Git+URL / AI Friendly rows, stacked above the OK/Cancel/
		' Open Existing button row. Everything the old two-dialog flow asked for across
		' separate popups now lives in this one dialog.
		With pnlBottom
			.Name = "pnlBottom"
			.Text = ""
			.Align = DockStyle.alBottom
			.TabIndex = 22
			.SetBounds 0, 0, 464, 260
			.Parent = @This
		End With
		' pnlProjectName — row 1
		With pnlProjectName
			.Name = "pnlProjectName"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 2
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 0, 464, 32
			.Parent = @pnlBottom
		End With
		' lblProjectName
		With lblProjectName
			.Name = "lblProjectName"
			.Text = ("Project Name") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 3
			.ExtraMargins.Top = 8
			.ExtraMargins.Bottom = 8
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlProjectName
		End With
		' txtProjectName
		With txtProjectName
			.Name = "txtProjectName"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 4
			.SetBounds 150, 0, 314, 32
			.Parent = @pnlProjectName
		End With
		' pnlFormName — row 2, enabled only for the Windows Application template
		With pnlFormName
			.Name = "pnlFormName"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 5
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 0, 464, 32
			.Parent = @pnlBottom
		End With
		' lblFormName
		With lblFormName
			.Name = "lblFormName"
			.Text = ("Primary Form Name") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 6
			.ExtraMargins.Top = 8
			.ExtraMargins.Bottom = 8
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlFormName
		End With
		' txtFormName
		With txtFormName
			.Name = "txtFormName"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 7
			.SetBounds 150, 0, 314, 32
			.Parent = @pnlFormName
		End With
		' pnlModuleName — row 3, enabled for every other template
		With pnlModuleName
			.Name = "pnlModuleName"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 8
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 0, 464, 32
			.Parent = @pnlBottom
		End With
		' lblModuleName
		With lblModuleName
			.Name = "lblModuleName"
			.Text = ("Primary Module Name") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 9
			.ExtraMargins.Top = 8
			.ExtraMargins.Bottom = 8
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlModuleName
		End With
		' txtModuleName
		With txtModuleName
			.Name = "txtModuleName"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 10
			.SetBounds 150, 0, 314, 32
			.Parent = @pnlModuleName
		End With
		' pnlAuthor — row 4, Author (defaults from Options > Personal Information > Name)
		With pnlAuthor
			.Name = "pnlAuthor"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 11
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 32, 464, 32
			.Parent = @pnlBottom
		End With
		' lblAuthor
		With lblAuthor
			.Name = "lblAuthor"
			.Text = ("Author") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 12
			.ExtraMargins.Top = 8
			.ExtraMargins.Bottom = 8
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlAuthor
		End With
		' txtAuthor
		With txtAuthor
			.Name = "txtAuthor"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 13
			.SetBounds 150, 0, 314, 32
			.Parent = @pnlAuthor
		End With
		' pnlLicense — row 5
		With pnlLicense
			.Name = "pnlLicense"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 14
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 64, 464, 32
			.Parent = @pnlBottom
		End With
		' lblLicense
		With lblLicense
			.Name = "lblLicense"
			.Text = ("License") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 15
			.ExtraMargins.Top = 8
			.ExtraMargins.Bottom = 8
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlLicense
		End With
		' cboLicense — fixed option list, populated in Form_Create
		With cboLicense
			.Name = "cboLicense"
			.Text = ""
			.Style = ComboBoxEditStyle.cbDropDownList
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 16
			.SetBounds 150, 0, 314, 32
			.Designer = @This
			.Parent = @pnlLicense
		End With
		' pnlGit — row 6, Use Git checkbox gates the Git URL field on the same line
		' (matching the existing chkLicenseOther/txtPersonalLicenseOther pattern in Options)
		With pnlGit
			.Name = "pnlGit"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 17
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 96, 464, 32
			.Parent = @pnlBottom
		End With
		' chkUseGit
		With chkUseGit
			.Name = "chkUseGit"
			.Text = ("Use Git") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 18
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 6, 90, 21
			.Designer = @This
			.OnClick = @chkUseGit_Click_
			.Parent = @pnlGit
		End With
		' txtGitURL — enabled only while Use Git is checked
		With txtGitURL
			.Name = "txtGitURL"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 19
			.SetBounds 100, 0, 364, 32
			.Enabled = False
			.Parent = @pnlGit
		End With
		' pnlAIFriendly — row 7
		With pnlAIFriendly
			.Name = "pnlAIFriendly"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 20
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 128, 464, 32
			.Parent = @pnlBottom
		End With
		' chkAIFriendly
		With chkAIFriendly
			.Name = "chkAIFriendly"
			.Text = ("Make project AI friendly")
			.Align = DockStyle.alLeft
			.TabIndex = 21
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 6, 220, 21
			.Designer = @This
			.Parent = @pnlAIFriendly
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 8
			.ExtraMargins.Top = 4
			.ExtraMargins.Right = 10
			.TabIndex = 25
			.SetBounds 527, 228, 88, 20
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @pnlBottom
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ("OK")
			.Align = DockStyle.alRight
			.ExtraMargins.Top = 4
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 8
			.TabIndex = 24
			.SetBounds 430, 228, 88, 20
			.Default = True
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlBottom
		End With
		' cmdOpenExisting  (lower-left, aligned with OK; opens the Open Project window instead)
		With cmdOpenExisting
			.Name = "cmdOpenExisting"
			.Text = ("Open Existing Project")
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 4
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 8
			.TabIndex = 23
			.SetBounds 10, 228, 160, 20
			.Designer = @This
			.OnClick = @cmdOpenExisting_Click_
			.Parent = @pnlBottom
		End With
		' lvTemplates
		With lvTemplates
			.Name = "lvTemplates"
			.Text = "ListView1"
			.View = ViewStyle.vsIcon
			.Images = @imgList32
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 32
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.TabIndex = 1
			.SetBounds 10, 32, 460, 120
			.Designer = @This
			.Columns.Add ("Template"), , 500, cfLeft
			.OnItemActivate = @lvTemplates_ItemActivate_
			.OnSelectedItemChanged = @lvTemplates_SelectedItemChanged_
			.Parent = @This
		End With
		' lblProjectTemplates
		With lblProjectTemplates
			.Name = "lblProjectTemplates"
			.Text = ("Project Templates")
			.TabIndex = 0
			.SetBounds 10, 10, 300, 18
			.Parent = @This
		End With
	End Constructor

'#End Region

Private Sub frmNewProject.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmNewProject.cmdOK_Click(ByRef Sender As Control)
	SelectedTemplate = ""
	SelectedFolder = ""
	SelectedProjectFile = ""
	If lvTemplates.SelectedItemIndex = -1 Then
		MsgBox ("Select template!")
		Me.BringToFront
		Exit Sub
	End If
	Dim As String ProjectName = Trim(txtProjectName.Text)
	If ProjectName = "" Then
		MsgBox ("Enter a project name!")
		Me.BringToFront
		Exit Sub
	End If
	If Not IsValidProjectItemName(ProjectName) Then
		MsgBox ("Enter a valid project name without paths or file extensions."), , mtWarning
		Me.BringToFront
		Exit Sub
	End If
	Dim As String TemplateName = TemplateNames.Item(lvTemplates.SelectedItemIndex)
	Dim As UString projectsPathInput = Trim(*ProjectsPath, Any !" \t" + Chr(10) + Chr(13))
	Dim As UString localTemplate = WinOsPath(ExePath & "/Templates/Projects/" & TemplateName & ".vfp")
	Dim As UString localFolder = WinOsPath(GetFullPathU(projectsPathInput & "/" & ProjectName))
	Dim As UString localProjectFile = localFolder & WindowsSlash & GetFileNameU(localFolder) & ".vfp"
	If Not FolderExistsU(GetFullPathU(projectsPathInput)) Then
		MsgBox ("Parent folder not exists, change the parent folder!")
		Me.BringToFront
		Exit Sub
	ElseIf FolderExistsU(localFolder) Then
		MsgBox ("Selected folder exists, change the project name!")
		Me.BringToFront
		Exit Sub
	End If
	If Not FileExistsU(localTemplate) Then
		MsgBox ("Template not found!")
		Me.BringToFront
		Exit Sub
	End If
	'' Find the template's own default file (every shipped project template has exactly
	'' one) so its real name can be validated/renamed from the inline Form/Module Name
	'' field, instead of silently copying the template's own file name straight in.
	Dim As UString TemplateFolder = WinOsPath(ExePath & "/Templates/Projects/" & TemplateName)
	Dim As UString TemplateMainFile = GetTemplateMainFile(TemplateName)
	If TemplateMainFile = "" Then
		'' No default file shipped with this template -- just create the folder and
		'' copy the .vfp as-is (shouldn't happen for any of the current templates).
		If Not EnsureDirectoryExists(localFolder) Then
			MsgBox ("Could not create project folder!")
			Me.BringToFront
			Exit Sub
		End If
		If Not CopyFileU(localTemplate, localProjectFile) Then
			MsgBox ("Could not create project file!")
			Me.BringToFront
			Exit Sub
		End If
	Else
		Dim As UString mainFileExt = ""
		Dim As Integer extPos = InStrRev(TemplateMainFile, ".")
		If extPos > 0 Then mainFileExt = Mid(TemplateMainFile, extPos)
		'' Windows Application ships a default Form and can *also* get a fresh Module (from
		'' the generic Templates\Files\Module.bas, not part of the Windows Application
		'' template itself); every other template only offers a Module/UserControl (routed
		'' through the same "Module Name" field rather than adding a third contextual
		'' label). Both name fields are optional -- left blank, that file just isn't created.
		Dim As Boolean bIsWinApp = (TemplateName = "Windows Application")
		Dim As UString chosenFormName = ""
		If bIsWinApp Then chosenFormName = Trim(txtFormName.Text)
		If chosenFormName <> "" AndAlso Not IsValidProjectItemName(chosenFormName) Then
			MsgBox ("Enter a valid form name without paths or file extensions."), , mtWarning
			Me.BringToFront
			Exit Sub
		End If
		Dim As UString chosenModuleName = Trim(txtModuleName.Text)
		If chosenModuleName <> "" AndAlso Not IsValidProjectItemName(chosenModuleName) Then
			MsgBox ("Enter a valid module name without paths or file extensions."), , mtWarning
			Me.BringToFront
			Exit Sub
		End If
		If Not EnsureDirectoryExists(localFolder) Then
			MsgBox ("Could not create project folder!")
			Me.BringToFront
			Exit Sub
		End If
		'' The template's own shipped default file: the Form, for Windows Application;
		'' the Module/UserControl, for every other template.
		Dim As UString mainFileDest
		If bIsWinApp Then
			If chosenFormName <> "" Then
				mainFileDest = localFolder & WindowsSlash & chosenFormName & mainFileExt
				If Not CopyFileU(TemplateFolder & WindowsSlash & TemplateMainFile, mainFileDest) Then
					MsgBox ("Could not create the form file") & ":" & WChr(13,10) & WChr(13,10) & mainFileDest & WChr(13,10) & WChr(13,10) & ("Windows error") & " " & Str(GetLastError())
					Me.BringToFront
					Exit Sub
				End If
			End If
		ElseIf chosenModuleName <> "" Then
			mainFileDest = localFolder & WindowsSlash & chosenModuleName & mainFileExt
			If Not CopyFileU(TemplateFolder & WindowsSlash & TemplateMainFile, mainFileDest) Then
				MsgBox ("Could not create the module file") & ":" & WChr(13,10) & WChr(13,10) & mainFileDest & WChr(13,10) & WChr(13,10) & ("Windows error") & " " & Str(GetLastError())
				Me.BringToFront
				Exit Sub
			End If
		End If
		'' Windows Application's extra Module (both fields filled): a genuinely separate
		'' file, sourced from the generic per-file template, not the project template.
		Dim As UString extraModuleExt = ".bas"
		If bIsWinApp AndAlso chosenModuleName <> "" Then
			Dim As UString genericModuleTemplate = WinOsPath(ExePath & "/Templates/Files/Module.bas")
			Dim As UString extraModuleDest = localFolder & WindowsSlash & chosenModuleName & extraModuleExt
			If Not CopyFileU(genericModuleTemplate, extraModuleDest) Then
				MsgBox ("Could not create the module file") & ":" & WChr(13,10) & WChr(13,10) & extraModuleDest & WChr(13,10) & WChr(13,10) & ("Windows error") & " " & Str(GetLastError())
				Me.BringToFront
				Exit Sub
			End If
		End If
		'' Rewrite the template's own File=/*File= line -- it points at
		'' "<TemplateName>/<original name>" (the template's own on-disk layout). The Form
		'' stays the project's starred/main file when both exist; if the Form was skipped
		'' but a Module was still requested, the Module takes over the starred position.
		'' If both were left blank, the line is dropped entirely (nothing was created).
		'' Read the whole template into memory and close it BEFORE opening the destination
		'' for writing -- this app runs background worker threads that also do file I/O
		'' (IntelliSense parsing etc.), so two simultaneously-open handles from this
		'' thread's own read+write loop is avoided as a precaution, not just tidiness.
		Dim As WString Ptr localTemplatePtr, localProjectFilePtr
		WLet(localTemplatePtr, localTemplate)
		WLet(localProjectFilePtr, localProjectFile)
		Dim As WStringList vfpLines
		Dim As Integer FnIn = FreeFile_
		'' Open(... Encoding "utf-8") fails with "path not found" on a file that has no
		'' UTF-8 BOM (every shipped .vfp template is plain ASCII/no-BOM) -- confirmed by
		'' direct reproduction, not a path-construction bug. Every other file-read in this
		'' codebase already falls back through encodings ending in a plain Open for exactly
		'' this reason (see AddProject's own .vfp parsing) -- this call was missing it.
		Dim As Integer OpenInResult = Open(*localTemplatePtr For Input Encoding "utf-8" As #FnIn)
		If OpenInResult <> 0 Then OpenInResult = Open(*localTemplatePtr For Input Encoding "utf-16" As #FnIn)
		If OpenInResult <> 0 Then OpenInResult = Open(*localTemplatePtr For Input Encoding "utf-32" As #FnIn)
		If OpenInResult <> 0 Then OpenInResult = Open(*localTemplatePtr For Input As #FnIn)
		If OpenInResult <> 0 Then
			MsgBox ("Could not open the template project file for reading") & ":" & WChr(13,10) & WChr(13,10) & localTemplate & WChr(13,10) & WChr(13,10) & ("Open error code") & " " & Str(OpenInResult)
			Me.BringToFront
			WDeAllocate(localTemplatePtr)
			WDeAllocate(localProjectFilePtr)
			Exit Sub
		End If
		Dim As WString * 1024 vfpLine
		Do Until EOF(FnIn)
			Line Input #FnIn, vfpLine
			If StartsWith(vfpLine, "*File=") OrElse StartsWith(vfpLine, "File=") Then
				Dim As UString linePrefix = IIf(StartsWith(vfpLine, "*File="), "*File=", "File=")
				If bIsWinApp Then
					If chosenFormName <> "" Then
						vfpLines.Add linePrefix & chosenFormName & mainFileExt
					ElseIf chosenModuleName <> "" Then
						vfpLines.Add linePrefix & chosenModuleName & extraModuleExt
					End If
				Else
					If chosenModuleName <> "" Then vfpLines.Add linePrefix & chosenModuleName & mainFileExt
				End If
			Else
				vfpLines.Add vfpLine
			End If
		Loop
		'' Windows Application with BOTH Form and Module chosen: the Module has no
		'' original line to replace above (it isn't part of the template), so it's
		'' appended as a plain (non-starred) member file -- the Form stays starred.
		If bIsWinApp AndAlso chosenFormName <> "" AndAlso chosenModuleName <> "" Then
			vfpLines.Add "File=" & chosenModuleName & extraModuleExt
		End If
		CloseFile_(FnIn)
		Dim As Integer FnOut = FreeFile_
		Dim As Integer OpenOutResult = Open(*localProjectFilePtr For Output Encoding "utf-8" As #FnOut)
		If OpenOutResult <> 0 Then
			MsgBox ("Could not create the project file for writing") & ":" & WChr(13,10) & WChr(13,10) & localProjectFile & WChr(13,10) & WChr(13,10) & ("Open error code") & " " & Str(OpenOutResult)
			Me.BringToFront
			WDeAllocate(localTemplatePtr)
			WDeAllocate(localProjectFilePtr)
			Exit Sub
		End If
		For i As Integer = 0 To vfpLines.Count - 1
			Print #FnOut, vfpLines.Item(i)
		Next i
		CloseFile_(FnOut)
		WDeAllocate(localTemplatePtr)
		WDeAllocate(localProjectFilePtr)
	End If
	'' New-project metadata (Author/License/Git). Appended as plain key=value lines in
	'' the same flat format already used by every other .vfp key (CompanyName, LegalCopyright,
	'' etc.) -- AddProject's key parser (Main.bas) is an If/ElseIf chain with no matching
	'' branch for these new keys, so they're safely ignored by today's project loader,
	'' the same as any other key it doesn't recognize. Git URL is stored for reference only
	'' -- no git commands are run. "Make project AI friendly" is captured as a flag only for
	'' now; what it should actually generate is an open decision for a later session.
	Dim As String chosenAuthor = Trim(txtAuthor.Text)
	Dim As String chosenLicense = cboLicense.Text
	Dim As Boolean useGit = chkUseGit.Checked
	Dim As String gitURL = Trim(txtGitURL.Text)
	Dim As String useGitText = "false"
	If useGit Then useGitText = "true"
	Dim As String aiFriendlyText = "false"
	If chkAIFriendly.Checked Then aiFriendlyText = "true"
	Dim As Integer FnMeta = FreeFile_
	If Open(localProjectFile For Append Encoding "utf-8" As #FnMeta) = 0 Then
		Print #FnMeta, "Author=" & Chr(34) & chosenAuthor & Chr(34)
		Print #FnMeta, "License=" & Chr(34) & chosenLicense & Chr(34)
		Print #FnMeta, "UseGit=" & useGitText
		Print #FnMeta, "GitURL=" & Chr(34) & gitURL & Chr(34)
		Print #FnMeta, "AIFriendly=" & aiFriendlyText
		CloseFile_(FnMeta)
	End If
	WriteLicenseFile(localFolder, chosenLicense, chosenAuthor)
	SelectedTemplate = localTemplate
	SelectedFolder = localFolder
	SelectedProjectFile = localProjectFile
	ModalResult = ModalResults.OK
	Me.CloseForm
End Sub

Private Sub frmNewProject.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmNewProject.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmNewProject.cmdOpenExisting_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).cmdOpenExisting_Click(Sender)
End Sub
Private Sub frmNewProject.cmdOpenExisting_Click(ByRef Sender As Control)
	' Close New Project and signal NewProject() to open the Open Project window instead.
	OpenExistingRequested = True
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmNewProject.lvTemplates_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmNewProject Ptr, Sender.Designer)).lvTemplates_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmNewProject.lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmNewProject.lvTemplates_SelectedItemChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmNewProject Ptr, Sender.Designer)).lvTemplates_SelectedItemChanged(Sender, ItemIndex)
End Sub
Private Sub frmNewProject.lvTemplates_SelectedItemChanged(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If lvTemplates.SelectedItemIndex = -1 Then
		txtFormName.Enabled = False
		txtFormName.Text = ""
		txtModuleName.Enabled = False
		txtModuleName.Text = ""
		Exit Sub
	End If
	'' No auto-filled suggestion in either field, matching the Project Name field (all
	'' three are optional except Project Name: left blank, cmdOK_Click just skips
	'' creating that file). Windows Application ships a Form and can optionally also get
	'' a fresh Module (from the generic Templates\Files\Module.bas, not part of the
	'' Windows Application template itself); every other template only offers a Module.
	Dim As String TemplateName = TemplateNames.Item(lvTemplates.SelectedItemIndex)
	If TemplateName = "Windows Application" Then
		txtFormName.Enabled = True
		txtModuleName.Enabled = True
	Else
		txtFormName.Enabled = False
		txtFormName.Text = ""
		txtModuleName.Enabled = True
	End If
End Sub

Private Sub frmNewProject.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmNewProject.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	lvTemplates.ListItems.Clear
	TemplateNames.Clear
	Dim As String PreferredTemplates(4)
	PreferredTemplates(0) = "Windows Application"
	PreferredTemplates(1) = "Console Application"
	PreferredTemplates(2) = "Dynamic Library"
	PreferredTemplates(3) = "Static Library"
	PreferredTemplates(4) = "Control Library"
	For i As Integer = 0 To UBound(PreferredTemplates)
		If FileExistsU(ExePath & "/Templates/Projects/" & PreferredTemplates(i) & ".vfp") Then
			AddProjectTemplateItem(PreferredTemplates(i))
		End If
	Next
	lvTemplates.View = ViewStyle.vsIcon
	'' No auto-generated name in any of the three fields -- project name is required and
	'' the owner types their own; the form/module name fields are optional (left blank,
	'' cmdOK_Click skips creating that file).
	txtProjectName.Text = ""
	txtFormName.Enabled = False
	txtFormName.Text = ""
	txtModuleName.Enabled = False
	txtModuleName.Text = ""
	'' Author defaults from Options > Personal Information > Name, but stays editable so
	'' a one-off project can credit someone else without touching the global setting.
	txtAuthor.Text = *PersonalName
	cboLicense.Clear
	cboLicense.AddItem ("GPL")
	cboLicense.AddItem ("LGPL")
	cboLicense.AddItem ("Apache")
	cboLicense.AddItem ("MIT")
	cboLicense.AddItem ("Mozilla")
	cboLicense.AddItem ("BSD")
	cboLicense.AddItem ("Freeware")
	cboLicense.AddItem ("Proprietary")
	cboLicense.AddItem ("Other")
	cboLicense.ItemIndex = 0
	chkUseGit.Checked = False
	txtGitURL.Enabled = False
	txtGitURL.Text = ""
	chkAIFriendly.Checked = False
End Sub

Private Sub frmNewProject.chkUseGit_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).chkUseGit_Click(Sender)
End Sub
Private Sub frmNewProject.chkUseGit_Click(ByRef Sender As Control)
	txtGitURL.Enabled = chkUseGit.Checked
End Sub

Private Sub frmNewProject.AddProjectTemplateItem(ByRef TemplateName As String)
	Dim As String ImageName = "App" & ..Left(TemplateName, IfNegative(InStr(TemplateName, " ") - 1, Len(TemplateName)))
	If imgList32.IndexOf(ImageName) < 0 Then ImageName = "AppGUI"
	lvTemplates.ListItems.Add (TemplateName), ImageName
	TemplateNames.Add TemplateName
End Sub

'' Every shipped project template has exactly one non-.vfp file in its own Templates\
'' Projects\<TemplateName>\ folder -- that's the default Form/Module/UserControl the new
'' project starts with. Returns its filename (with extension), or "" if the template ships
'' no default file. Shared by the selection-changed preview and the actual OK/create step.
Private Function frmNewProject.GetTemplateMainFile(ByRef TemplateName As String) As UString
	Dim As UString TemplateFolder = WinOsPath(ExePath & "/Templates/Projects/" & TemplateName)
	Dim As UString TemplateMainFile = ""
	If FolderExistsU(TemplateFolder) Then
		Dim As UInteger Attr
		Dim As String f = Dir(TemplateFolder & WindowsSlash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
		Do While f <> ""
			If (Attr And fbDirectory) = 0 AndAlso f <> "." AndAlso f <> ".." Then
				TemplateMainFile = f
				Exit Do
			End If
			f = Dir(Attr)
		Loop
	End If
	Return TemplateMainFile
End Function

'' Writes a LICENSE file into the new project's folder for the chosen dropdown option.
'' GPL/LGPL/Apache/Mozilla get the license's own standard short-form notice plus a link to
'' the canonical full text (the usual convention for those -- the full legal text runs to
'' tens of KB and is meant to be fetched from the official source, not vendored per-project).
'' MIT and BSD get their full text written out since both are short, standard, and safe to
'' embed verbatim. Freeware/Proprietary get a short plain-language notice. "Other" writes
'' nothing -- same "no generated boilerplate" convention already used by the free-text
'' "Other" license field in Options (chkLicenseOther/txtPersonalLicenseOther).
Private Sub frmNewProject.WriteLicenseFile(ByRef DestFolder As UString, ByRef LicenseName As String, ByRef AuthorName As String)
	Dim As String CopyrightYear = Format(Now, "yyyy")
	Dim As String HolderName = Trim(AuthorName)
	If HolderName = "" Then HolderName = "the author"
	Dim As String Body
	Select Case LicenseName
	Case "GPL"
		Body = "GNU General Public License v3.0" & WChr(13,10) & WChr(13,10) & _
			"Copyright (C) " & CopyrightYear & " " & HolderName & WChr(13,10) & WChr(13,10) & _
			"This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version." & WChr(13,10) & WChr(13,10) & _
			"This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details." & WChr(13,10) & WChr(13,10) & _
			"You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>."
	Case "LGPL"
		Body = "GNU Lesser General Public License v3.0" & WChr(13,10) & WChr(13,10) & _
			"Copyright (C) " & CopyrightYear & " " & HolderName & WChr(13,10) & WChr(13,10) & _
			"This library is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version." & WChr(13,10) & WChr(13,10) & _
			"This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details." & WChr(13,10) & WChr(13,10) & _
			"You should have received a copy of the GNU Lesser General Public License along with this library. If not, see <https://www.gnu.org/licenses/>."
	Case "Apache"
		Body = "Apache License, Version 2.0" & WChr(13,10) & WChr(13,10) & _
			"Copyright " & CopyrightYear & " " & HolderName & WChr(13,10) & WChr(13,10) & _
			!"Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at" & WChr(13,10) & WChr(13,10) & _
			"    http://www.apache.org/licenses/LICENSE-2.0" & WChr(13,10) & WChr(13,10) & _
			!"Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License."
	Case "MIT"
		Body = "MIT License" & WChr(13,10) & WChr(13,10) & _
			"Copyright (c) " & CopyrightYear & " " & HolderName & WChr(13,10) & WChr(13,10) & _
			!"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:" & WChr(13,10) & WChr(13,10) & _
			"The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software." & WChr(13,10) & WChr(13,10) & _
			!"THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
	Case "Mozilla"
		Body = "Mozilla Public License, v. 2.0" & WChr(13,10) & WChr(13,10) & _
			"Copyright " & CopyrightYear & " " & HolderName & WChr(13,10) & WChr(13,10) & _
			"This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/."
	Case "BSD"
		Body = "BSD 3-Clause License" & WChr(13,10) & WChr(13,10) & _
			"Copyright (c) " & CopyrightYear & ", " & HolderName & WChr(13,10) & _
			"All rights reserved." & WChr(13,10) & WChr(13,10) & _
			"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:" & WChr(13,10) & WChr(13,10) & _
			"1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer." & WChr(13,10) & WChr(13,10) & _
			"2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution." & WChr(13,10) & WChr(13,10) & _
			"3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission." & WChr(13,10) & WChr(13,10) & _
			!"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
	Case "Freeware"
		Body = "Freeware" & WChr(13,10) & WChr(13,10) & _
			"Copyright (c) " & CopyrightYear & " " & HolderName & WChr(13,10) & WChr(13,10) & _
			!"This software is provided free of charge for personal and commercial use. Redistribution is permitted provided this notice is preserved. The software is provided \"AS IS\", without warranty of any kind, express or implied."
	Case "Proprietary"
		Body = "Proprietary" & WChr(13,10) & WChr(13,10) & _
			"Copyright (c) " & CopyrightYear & " " & HolderName & WChr(13,10) & _
			"All rights reserved." & WChr(13,10) & WChr(13,10) & _
			"This software and associated documentation are proprietary and confidential. Unauthorized copying, modification, distribution, or use of this software, via any medium, is strictly prohibited without the express written permission of the copyright holder."
	Case Else
		'' "Other" -- no generated boilerplate; the owner supplies their own terms.
		Exit Sub
	End Select
	Dim As Integer Fn = FreeFile_
	If Open(DestFolder & WindowsSlash & "LICENSE" For Output Encoding "utf-8" As #Fn) = 0 Then
		Print #Fn, Body
		CloseFile_(Fn)
	End If
End Sub
