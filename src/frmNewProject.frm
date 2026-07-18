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
			.SetBounds 0, 0, 480, 539
			.StartPosition = FormStartPosition.CenterParent
		End With
		' pnlBottom — footer: Project Template / Project Name / Primary Form Name / Primary
		' Module Name / Author / License / Use Git+URL / AI Friendly rows, stacked above the
		' OK/Cancel/Open Existing button row. Everything the old two-dialog flow asked for
		' across separate popups now lives in this one dialog.
		With pnlBottom
			.Name = "pnlBottom"
			.Text = ""
			.Align = DockStyle.alBottom
			.TabIndex = 35
			.SetBounds 0, 0, 464, 500
			.Parent = @This
		End With
		' pnlMode — the very top row: choose how the project is created. The two radios
		' auto-group (same parent). Create Local = purely local from a template; Use
		' Existing Git = clone an existing remote repo. UpdateModeFields enables the
		' fields each mode needs.
		With pnlMode
			.Name = "pnlMode"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 1
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 0, 464, 32
			.Parent = @pnlBottom
		End With
		' optCreateLocal
		With optCreateLocal
			.Name = "optCreateLocal"
			.Caption = ("Create Local Project")
			.Align = DockStyle.alLeft
			.TabIndex = 1
			.SetBounds 0, 6, 170, 21
			.Checked = True
			.Designer = @This
			.OnClick = @optMode_Click_
			.Parent = @pnlMode
		End With
		' optUseExistingGit
		With optUseExistingGit
			.Name = "optUseExistingGit"
			.Caption = ("Use Existing Git Project")
			.Align = DockStyle.alLeft
			.TabIndex = 2
			.SetBounds 170, 6, 200, 21
			.Designer = @This
			.OnClick = @optMode_Click_
			.Parent = @pnlMode
		End With
		' pnlProjectTemplate — row 0: project template (label-left + dropdown, matching
		' the other field rows). Added before pnlProjectName so it docks as the top row.
		With pnlProjectTemplate
			.Name = "pnlProjectTemplate"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 1
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 0, 464, 32
			.Parent = @pnlBottom
		End With
		' lblProjectTemplates
		With lblProjectTemplates
			.Name = "lblProjectTemplates"
			.Text = ("Project Template") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 0
			.CenterImage = True
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlProjectTemplate
		End With
		' cboTemplate — pick-only dropdown; populated in Form_Create, defaults to
		' Windows Application. Same label-left/combo-alClient layout as Git Provider.
		With cboTemplate
			.Name = "cboTemplate"
			.Text = ""
			.Style = ComboBoxEditStyle.cbDropDownList
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 1
			.SetBounds 150, 0, 314, 32
			.Designer = @This
			.OnChange = @cboTemplate_Change_
			.Parent = @pnlProjectTemplate
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
			.CenterImage = True
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
			.CenterImage = True
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
			.CenterImage = True
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
			.CenterImage = True
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
			.CenterImage = True
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
		' pnlGitProvider — row 6b, Git host (GitHub/GitLab/Bitbucket/Codeberg); combined
		' with Git Username + Project Name to build the remote URL (see BuildGitURL)
		With pnlGitProvider
			.Name = "pnlGitProvider"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 19
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 128, 464, 32
			.Parent = @pnlBottom
		End With
		' lblGitProvider
		With lblGitProvider
			.Name = "lblGitProvider"
			.Text = ("Git Provider") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 20
			.CenterImage = True
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlGitProvider
		End With
		' cboGitProvider -- fixed option list, populated in Form_Create; enabled only
		' while Use Git is checked
		With cboGitProvider
			.Name = "cboGitProvider"
			.Text = ""
			.Style = ComboBoxEditStyle.cbDropDownList
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 21
			.SetBounds 150, 0, 314, 32
			.Enabled = False
			.Designer = @This
			.Parent = @pnlGitProvider
		End With
		' pnlGitUserName — row 6c
		With pnlGitUserName
			.Name = "pnlGitUserName"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 22
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 160, 464, 32
			.Parent = @pnlBottom
		End With
		' lblGitUserName
		With lblGitUserName
			.Name = "lblGitUserName"
			.Text = ("Git Username") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 23
			.CenterImage = True
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlGitUserName
		End With
		' txtGitUserName — enabled only while Use Git is checked
		With txtGitUserName
			.Name = "txtGitUserName"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 24
			.SetBounds 150, 0, 314, 32
			.Enabled = False
			.Parent = @pnlGitUserName
		End With
		' pnlGitEmail — row 6d
		With pnlGitEmail
			.Name = "pnlGitEmail"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 25
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 192, 464, 32
			.Parent = @pnlBottom
		End With
		' lblGitEmail
		With lblGitEmail
			.Name = "lblGitEmail"
			.Text = ("Git Email") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 26
			.CenterImage = True
			.SetBounds 0, 0, 150, 32
			.Parent = @pnlGitEmail
		End With
		' txtGitEmail — enabled only while Use Git is checked; defaults from
		' Options > Personal Information > E-mail (Form_Create), stays editable
		With txtGitEmail
			.Name = "txtGitEmail"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 27
			.SetBounds 150, 0, 314, 32
			.Enabled = False
			.Parent = @pnlGitEmail
		End With
		' pnlAIFriendly — row 7
		With pnlAIFriendly
			.Name = "pnlAIFriendly"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 28
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 224, 464, 32
			.Parent = @pnlBottom
		End With
		' chkAIFriendly
		With chkAIFriendly
			.Name = "chkAIFriendly"
			.Text = ("Make project AI friendly")
			.Align = DockStyle.alLeft
			.TabIndex = 29
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 6, 220, 21
			.Designer = @This
			.OnClick = @chkAIFriendly_Click_
			.Parent = @pnlAIFriendly
		End With
		' lblAITool -- "AI Agent:" label on the AI-friendly row
		With lblAITool
			.Name = "lblAITool"
			.Text = ("AI Agent") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 30
			.ExtraMargins.Left = 20
			.CenterImage = True
			.SetBounds 0, 0, 70, 32
			.Parent = @pnlAIFriendly
		End With
		' cboAITool -- AI agent choice; enabled only while "AI friendly" is checked
		With cboAITool
			.Name = "cboAITool"
			.Text = ""
			.Style = ComboBoxEditStyle.cbDropDownList
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 31
			.Enabled = False
			.Designer = @This
			.Parent = @pnlAIFriendly
		End With
		' pnlDescription -- Project Description; label ABOVE a full-width multiline box
		With pnlDescription
			.Name = "pnlDescription"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 32
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.SetBounds 0, 0, 464, 112
			.Parent = @pnlBottom
		End With
		' lblDescription -- above the box, full width
		With lblDescription
			.Name = "lblDescription"
			.Text = ("Description") & ":"
			.Align = DockStyle.alTop
			.TabIndex = 33
			.ExtraMargins.Top = 6
			.SetBounds 0, 0, 464, 22
			.Parent = @pnlDescription
		End With
		' txtDescription -- full-width multiline with a vertical scrollbar
		With txtDescription
			.Name = "txtDescription"
			.Text = ""
			.Align = DockStyle.alClient
			.ScrollBars = ScrollBarsType.Vertical
			.WantReturn = True
			.Multiline = True
			.ExtraMargins.Top = 3
			.ExtraMargins.Bottom = 5
			.TabIndex = 34
			.SetBounds 0, 22, 464, 90
			.Parent = @pnlDescription
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 8
			.ExtraMargins.Top = 4
			.ExtraMargins.Right = 10
			.TabIndex = 38
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
			.TabIndex = 37
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
			.TabIndex = 36
			.SetBounds 10, 228, 160, 20
			.Designer = @This
			.OnClick = @cmdOpenExisting_Click_
			.Parent = @pnlBottom
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
	If cboTemplate.ItemIndex = -1 Then
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
	Dim As String TemplateName = cboTemplate.Text
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
	'' Mode: Create Local Project vs Use Existing Git Project. In git mode we clone the
	'' remote first and classify what came down; only an empty clone falls through to the
	'' template-populate block below (Astoria fills the empty repo like a new project).
	Dim As Boolean bModeGit = optUseExistingGit.Checked
	Dim As String gitProvider = cboGitProvider.Text
	Dim As String gitUserName = Trim(txtGitUserName.Text)
	Dim As String gitURL = ""
	If bModeGit Then
		If gitUserName = "" Then
			MsgBox ("Enter a Git username."), , mtWarning
			Me.BringToFront
			Exit Sub
		End If
		If Not SshKeyExists() Then
			MsgBox ("Cloning an existing Git project needs an SSH key.") & Chr(13,10) & Chr(13,10) & _
				("See") & " Templates\Git\sshkeys.md " & ("for setup steps."), , mtWarning
			Me.BringToFront
			Exit Sub
		End If
		gitURL = BuildGitURL(gitProvider, gitUserName, ProjectName)
		If Not CloneGitRepository(gitURL, localFolder) Then
			MsgBox ("The repository could not be cloned") & ":" & Chr(13,10) & Chr(13,10) & gitURL & Chr(13,10) & Chr(13,10) & _
				("Check that it exists on") & " " & gitProvider & " " & ("and that you have access."), , mtWarning
			Me.BringToFront
			Exit Sub
		End If
		If IsAstoriaProject(localFolder) Then
			'' A complete Astoria project cloned down -- load it as-is; the creation
			'' fields don't apply. Stamp the AI template if asked (harmless if present).
			If chkAIFriendly.Checked Then
				Dim As UString aiFolderC = AIToolFolderName(cboAITool.Text)
				If aiFolderC <> "" Then StampAITemplate(localFolder, aiFolderC, ProjectName, Trim(txtAuthor.Text), cboLicense.Text, txtDescription.Text)
			End If
			Dim As UString foundVfp = FindProjectVfp(localFolder)
			If foundVfp <> "" Then
				SelectedProjectFile = foundVfp
			Else
				SelectedFolder = localFolder
			End If
			SelectedTemplate = localFolder
			ModalResult = ModalResults.OK
			Me.CloseForm
			Exit Sub
		ElseIf Not FolderIsEffectivelyEmpty(localFolder) Then
			'' Non-empty repo that is NOT an Astoria project: we don't try to interpret
			'' foreign projects. Remove the clone and refuse.
			DeleteFolderRecursive(localFolder)
			MsgBox ("This Git repository is not an Astoria project and is not empty.") & Chr(13,10) & Chr(13,10) & _
				("Astoria only loads its own projects or empty repositories.") & Chr(13,10) & Chr(13,10) & _
				("To use an existing repository, it must contain a project.astoria file that includes the line:") & Chr(13,10) & _
				("    AstoriaProject=1"), , mtWarning
			Me.BringToFront
			Exit Sub
		End If
		'' Empty repo -- fall through and populate it from the chosen template, exactly
		'' like a new local project (localFolder already exists as the empty clone).
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
	Dim As String chosenDescription = txtDescription.Text
	chosenDescription = Replace(chosenDescription, Chr(13) & Chr(10), "\n")
	chosenDescription = Replace(chosenDescription, Chr(10), "\n")
	chosenDescription = Replace(chosenDescription, Chr(13), "\n")
	Dim As String chosenAITool = cboAITool.Text
	Dim As String chosenGitEmail = Trim(txtGitEmail.Text)
	Dim As String useGitText = "false"
	If bModeGit Then useGitText = "true"
	Dim As String aiFriendlyText = "false"
	If chkAIFriendly.Checked Then aiFriendlyText = "true"
	Dim As Integer FnMeta = FreeFile_
	If Open(localProjectFile For Append Encoding "utf-8" As #FnMeta) = 0 Then
		Print #FnMeta, "Author=" & Chr(34) & chosenAuthor & Chr(34)
		Print #FnMeta, "License=" & Chr(34) & chosenLicense & Chr(34)
		Print #FnMeta, "Description=" & Chr(34) & chosenDescription & Chr(34)
		Print #FnMeta, "UseGit=" & useGitText
		Print #FnMeta, "GitProvider=" & Chr(34) & gitProvider & Chr(34)
		Print #FnMeta, "GitUserName=" & Chr(34) & gitUserName & Chr(34)
		Print #FnMeta, "GitEmail=" & Chr(34) & chosenGitEmail & Chr(34)
		Print #FnMeta, "GitURL=" & Chr(34) & gitURL & Chr(34)
		Print #FnMeta, "AIFriendly=" & aiFriendlyText
		Print #FnMeta, "AITool=" & Chr(34) & chosenAITool & Chr(34)
		CloseFile_(FnMeta)
	End If
	'' project.astoria -- the canonical Astoria description file (the marker that lets the
	'' clone flow recognise this as an Astoria project). Written for every created project.
	Dim As ProjectDescriptionData descData
	descData.Mode        = IIf(bModeGit, ProjectCreateMode.pcmExistingGit, ProjectCreateMode.pcmLocalProject)
	descData.ProjectName = ProjectName
	descData.Template    = TemplateName
	descData.Author      = chosenAuthor
	descData.License     = chosenLicense
	descData.Description  = txtDescription.Text
	If bModeGit Then
		descData.GitProvider = gitProvider
		descData.GitUserName = gitUserName
		descData.GitEmail    = chosenGitEmail
	End If
	descData.GitURL      = gitURL
	descData.AIFriendly  = chkAIFriendly.Checked
	descData.AITool      = chosenAITool
	descData.Created     = Format(Now, "yyyy-mm-dd")
	WriteProjectDescription(localFolder, descData)
	WriteLicenseFile(localFolder, chosenLicense, chosenAuthor)
	If chkAIFriendly.Checked Then
		Dim As UString aiFolder = AIToolFolderName(chosenAITool)
		If aiFolder <> "" Then StampAITemplate(localFolder, aiFolder, ProjectName, chosenAuthor, chosenLicense, txtDescription.Text)
	End If
	'' Existing-git empty clone: seed .gitignore/.gitattributes so the eventual commit
	'' (Project menu > Git Commit/Push) governs line endings and ignores build output.
	'' No git init/commit/push here -- the clone already set up git, and commit/push are
	'' the user's explicit Project-menu actions.
	If bModeGit Then
		WriteGitSupportFiles(localFolder, ProjectName, chosenAuthor, chosenLicense, txtDescription.Text)
	End If
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

Private Sub frmNewProject.cboTemplate_Change_(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit)
	(*Cast(frmNewProject Ptr, Sender.Designer)).cboTemplate_Change(Sender)
End Sub
Private Sub frmNewProject.cboTemplate_Change(ByRef Sender As ComboBoxEdit)
	If cboTemplate.ItemIndex = -1 Then
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
	If cboTemplate.Text = "Windows Application" Then
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
	cboTemplate.Clear
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
	'' Default to Windows Application (first in the preferred order, so index 0 when it
	'' ships). cboTemplate_Change enables the Form/Module fields to match.
	Dim As Integer defaultIdx = TemplateNames.IndexOf("Windows Application")
	If defaultIdx = -1 AndAlso cboTemplate.ItemCount > 0 Then defaultIdx = 0
	If defaultIdx <> -1 Then cboTemplate.ItemIndex = defaultIdx
	cboTemplate_Change(cboTemplate)
	'' No auto-generated name in any of the three fields -- project name is required and
	'' the owner types their own; the form/module name fields are optional (left blank,
	'' cmdOK_Click skips creating that file).
	txtProjectName.Text = ""
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
	'' Default to Create Local Project.
	optCreateLocal.Checked = True
	optUseExistingGit.Checked = False
	cboGitProvider.Clear
	cboGitProvider.AddItem ("GitHub")
	cboGitProvider.AddItem ("GitLab")
	cboGitProvider.AddItem ("Bitbucket")
	cboGitProvider.AddItem ("Codeberg")
	cboGitProvider.ItemIndex = 0
	cboGitProvider.Enabled = False
	txtGitUserName.Enabled = False
	txtGitUserName.Text = ""
	'' Git Email defaults from Options > Personal Information > E-mail, but stays
	'' editable -- a GitHub/GitLab/etc. account's commit email is often different
	'' from the general contact address on file.
	txtGitEmail.Text = *PersonalEmail
	txtGitEmail.Enabled = False
	chkAIFriendly.Checked = False
	cboAITool.Clear
	cboAITool.AddItem ("Claude Code")
	cboAITool.AddItem ("Cursor")
	cboAITool.AddItem ("ChatGPT (Codex)")
	cboAITool.AddItem ("OpenCode")
	cboAITool.AddItem ("Kun (Deepseek)")
	cboAITool.ItemIndex = 0
	cboAITool.Enabled = False
	'' Apply the default mode's field enabling (git fields off for Create Local).
	UpdateModeFields()
End Sub

Private Sub frmNewProject.optMode_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	(*Cast(frmNewProject Ptr, Sender.Designer)).optMode_Click(Sender)
End Sub
Private Sub frmNewProject.optMode_Click(ByRef Sender As RadioButton)
	UpdateModeFields()
End Sub

'' Enable the fields each creation mode needs.
''  - Create Local Project: template + names + author/license/description/AI; git fields off.
''  - Use Existing Git Project: git Provider/Username/Email on. Template + Form/Module stay
''    enabled too -- they're used only if the cloned repo turns out to be empty (Astoria
''    then populates the empty repo like a new local project); ignored for a repo that
''    already contains an Astoria project.
Private Sub frmNewProject.UpdateModeFields()
	Dim As Boolean bGit = optUseExistingGit.Checked
	cboGitProvider.Enabled = bGit
	txtGitUserName.Enabled = bGit
	txtGitEmail.Enabled = bGit
	'' Template/Form/Module: enabled in both modes. In existing-git mode the Windows
	'' Application template still gates the Form field via cboTemplate_Change.
	cboTemplate.Enabled = True
	cboTemplate_Change(cboTemplate)
End Sub

Private Sub frmNewProject.chkAIFriendly_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).chkAIFriendly_Click(Sender)
End Sub
Private Sub frmNewProject.chkAIFriendly_Click(ByRef Sender As Control)
	cboAITool.Enabled = chkAIFriendly.Checked
End Sub

Private Sub frmNewProject.AddProjectTemplateItem(ByRef TemplateName As String)
	'' The dropdown holds the template names directly; TemplateNames stays in sync so
	'' cboTemplate.ItemIndex maps back to a name (and drives the default selection).
	cboTemplate.AddItem (TemplateName)
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

'' Maps the AI Agent dropdown's display label to its Templates/AI/<Tool> folder
'' name. Returns "" for an unrecognized label (defensive only -- the dropdown is
'' cbDropDownList, so this can't happen via normal use).
Private Function frmNewProject.AIToolFolderName(ByRef ToolLabel As String) As UString
	Select Case ToolLabel
	Case "Claude Code": Return "ClaudeCode"
	Case "Cursor": Return "Cursor"
	Case "ChatGPT (Codex)": Return "ChatGPT"
	Case "OpenCode": Return "OpenCode"
	Case "Kun (Deepseek)": Return "Kun"
	Case Else: Return ""
	End Select
End Function

'' Stamps Templates/AI/<ToolFolder>/ into the new project's folder, substituting
'' {{PROJECT}}/{{AUTHOR}}/{{YEAR}}/{{DATE}}/{{LICENSE}}/{{DESCRIPTION}} tokens in
'' every file along the way (see Templates/AI/README.md for the token contract).
Private Sub frmNewProject.StampAITemplate(ByRef DestFolder As UString, ByRef ToolFolder As UString, ByRef ProjectName As String, ByRef AuthorName As String, ByRef LicenseName As String, ByRef DescriptionText As String)
	Dim As UString SrcFolder = WinOsPath(ExePath & "/Templates/AI/" & ToolFolder)
	If Not FolderExistsU(SrcFolder) Then Exit Sub
	CopyTemplateTree(SrcFolder, DestFolder, ProjectName, AuthorName, LicenseName, DescriptionText)
End Sub

'' Recursively copies SrcFolder's contents into DestFolder, stamping each file.
'' ".gitkeep" placeholders (used only to keep an empty resources/ folder tracked
'' in this repo) are skipped -- an empty destination folder is still created.
'' Fully drains each directory's Dir() listing into a list before recursing,
'' since Dir() keeps only one search handle at a time; interleaving a nested
'' Dir() call while an outer one is still in progress would corrupt it.
Private Sub frmNewProject.CopyTemplateTree(ByRef SrcFolder As UString, ByRef DestFolder As UString, ByRef ProjectName As String, ByRef AuthorName As String, ByRef LicenseName As String, ByRef DescriptionText As String)
	If Not EnsureDirectoryExists(DestFolder) Then Exit Sub
	Dim As WStringList names
	Dim As UInteger Attr
	Dim As String f = Dir(SrcFolder & WindowsSlash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	Do While f <> ""
		If f <> "." AndAlso f <> ".." AndAlso f <> ".gitkeep" Then names.Add f
		f = Dir(Attr)
	Loop
	For i As Integer = 0 To names.Count - 1
		Dim As UString itemName = names.Item(i)
		Dim As UString srcItem = SrcFolder & WindowsSlash & itemName
		Dim As UString destItem = DestFolder & WindowsSlash & itemName
		If FolderExistsU(srcItem) Then
			CopyTemplateTree(srcItem, destItem, ProjectName, AuthorName, LicenseName, DescriptionText)
		Else
			StampTemplateFile(srcItem, destItem, ProjectName, AuthorName, LicenseName, DescriptionText)
		End If
	Next i
End Sub

'' Reads SrcFile as raw bytes, substitutes the six tokens, and writes the result
'' to DestFile. Byte-based (not encoding-aware) since every shipped template file
'' is plain ASCII/UTF-8 and the token markers themselves are pure ASCII.
Private Sub frmNewProject.StampTemplateFile(ByRef SrcFile As UString, ByRef DestFile As UString, ByRef ProjectName As String, ByRef AuthorName As String, ByRef LicenseName As String, ByRef DescriptionText As String)
	Dim As Integer FnIn = FreeFile_
	If Open(SrcFile For Binary Access Read As #FnIn) <> 0 Then Exit Sub
	Dim As Integer FileSize = LOF(FnIn)
	Dim As String Contents = String(FileSize, 0)
	If FileSize > 0 Then Get #FnIn, 1, Contents
	CloseFile_(FnIn)
	Dim As String authorForToken = Trim(AuthorName)
	If authorForToken = "" Then authorForToken = "the author"
	Contents = Replace(Contents, "{{PROJECT}}", ProjectName)
	Contents = Replace(Contents, "{{AUTHOR}}", authorForToken)
	Contents = Replace(Contents, "{{YEAR}}", Format(Now, "yyyy"))
	Contents = Replace(Contents, "{{DATE}}", Format(Now, "yyyy-mm-dd"))
	Contents = Replace(Contents, "{{LICENSE}}", LicenseName)
	Contents = Replace(Contents, "{{DESCRIPTION}}", DescriptionText)
	Dim As Integer FnOut = FreeFile_
	If Open(DestFile For Binary Access Write As #FnOut) = 0 Then
		If Len(Contents) > 0 Then Put #FnOut, 1, Contents
		CloseFile_(FnOut)
	End If
End Sub

'' Stamps Templates/Git/gitignore.txt and gitattributes.txt into the new project
'' as .gitignore / .gitattributes (token-substituted -- gitattributes.txt uses
'' {{PROJECT}}). Written whenever Use Git is checked, before SetupGitRepository's
'' "git add ." so they land in -- and govern -- the initial commit. Missing
'' template files are skipped silently (StampTemplateFile's own behavior).
Private Sub frmNewProject.WriteGitSupportFiles(ByRef DestFolder As UString, ByRef ProjectName As String, ByRef AuthorName As String, ByRef LicenseName As String, ByRef DescriptionText As String)
	Dim As UString gitTplFolder = WinOsPath(ExePath & "/Templates/Git")
	StampTemplateFile(gitTplFolder & WindowsSlash & "gitignore.txt", DestFolder & WindowsSlash & ".gitignore", ProjectName, AuthorName, LicenseName, DescriptionText)
	StampTemplateFile(gitTplFolder & WindowsSlash & "gitattributes.txt", DestFolder & WindowsSlash & ".gitattributes", ProjectName, AuthorName, LicenseName, DescriptionText)
End Sub

'' Whether a usable SSH key already exists for the current Windows user --
'' checked at %USERPROFILE%\.ssh\ for the three common key types. Mirrors the
'' check Templates/Git/sshkeys.md walks the user through by hand.
Private Function frmNewProject.SshKeyExists() As Boolean
	Dim As UString sshFolder = Environ("USERPROFILE") & "\.ssh\"
	If FileExistsU(sshFolder & "id_ed25519.pub") Then Return True
	If FileExistsU(sshFolder & "id_rsa.pub") Then Return True
	If FileExistsU(sshFolder & "id_ecdsa.pub") Then Return True
	Return False
End Function

'' git clone GitURL into DestFolder (which must not already exist -- git creates it).
'' Runs from a temp .bat so the exit code can be captured (PipeCmd returns nothing),
'' batch-mode SSH so it can't block on a credential/host-key prompt. Returns True only
'' when clone exits 0 and the folder actually materialised. Mirrors RemoteRepoExists.
Private Function frmNewProject.CloneGitRepository(ByRef GitURL As String, ByRef DestFolder As UString) As Boolean
	EnsureDirectoryExists(ExePath & WindowsSlash & "Temp")
	Dim As UString batPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_clone.bat"
	Dim As UString resultPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_clone.result"
	If FileExistsU(resultPath) Then Kill resultPath
	Dim As Integer Fn = FreeFile_
	If Open(batPath For Output As #Fn) <> 0 Then Return False
	Print #Fn, "@echo off"
	Print #Fn, "set GIT_TERMINAL_PROMPT=0"
	Print #Fn, "set GIT_SSH_COMMAND=ssh -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
	Print #Fn, "git clone " & Chr(34) & Trim(GitURL) & Chr(34) & " " & Chr(34) & DestFolder & Chr(34) & " >NUL 2>&1"
	Print #Fn, "echo %errorlevel% > " & Chr(34) & resultPath & Chr(34)
	CloseFile_(Fn)
	PipeCmd batPath, True
	Dim As Boolean ok = False
	If FileExistsU(resultPath) Then
		Dim As Integer FnR = FreeFile_
		If Open(resultPath For Input As #FnR) = 0 Then
			Dim As String resultLine
			Line Input #FnR, resultLine
			CloseFile_(FnR)
			ok = (Trim(resultLine) = "0")
		End If
		Kill resultPath
	End If
	If FileExistsU(batPath) Then Kill batPath
	If ok AndAlso Not FolderExistsU(DestFolder) Then ok = False
	Return ok
End Function

'' Find a project (.vfp) file in Folder, preferring one named after the folder.
'' "" if none. Used to pick the project file of a cloned complete Astoria project.
Private Function frmNewProject.FindProjectVfp(ByRef Folder As UString) As UString
	Dim As UString wantName = LCase(GetFileNameU(Folder)) & ".vfp"
	Dim As UString firstVfp = ""
	Dim As UInteger attr
	Dim As String f = Dir(WinOsPath(Folder & "/*.vfp"), fbNormal Or fbArchive Or fbReadOnly, attr)
	Do While f <> ""
		Dim As UString full = WinOsPath(Folder & "/" & f)
		If firstVfp = "" Then firstVfp = full
		If LCase(f) = wantName Then Return full
		f = Dir(attr)
	Loop
	Return firstVfp
End Function

'' Delete a folder and everything under it (used to remove a refused clone). Shells
'' `rmdir /s /q` via a temp .bat -- robust against a cloned .git tree's many files,
'' and attrib -r first so read-only git objects don't block the removal.
Private Sub frmNewProject.DeleteFolderRecursive(ByRef Folder As UString)
	If Trim(Folder) = "" OrElse Not FolderExistsU(Folder) Then Exit Sub
	EnsureDirectoryExists(ExePath & WindowsSlash & "Temp")
	Dim As UString batPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_rmdir.bat"
	Dim As Integer Fn = FreeFile_
	If Open(batPath For Output As #Fn) <> 0 Then Exit Sub
	Print #Fn, "@echo off"
	Print #Fn, "attrib -r -h -s " & Chr(34) & Folder & "\*.*" & Chr(34) & " /s /d >NUL 2>&1"
	Print #Fn, "rmdir /s /q " & Chr(34) & Folder & Chr(34) & " >NUL 2>&1"
	CloseFile_(Fn)
	PipeCmd batPath, True
	If FileExistsU(batPath) Then Kill batPath
End Sub

'' Whether GitURL already exists and is reachable, via a preflight "git ls-remote"
'' (works against a bare remote URL -- no local repo needed yet). Runs from a temp
'' .bat (Temp\, same convention as SetupGitRepository) so the exit code can be
'' captured through a small result file, since PipeCmd itself returns nothing.
'' GIT_TERMINAL_PROMPT=0 and a batch-mode/timeout-bounded SSH command guarantee
'' this can't block waiting on a credential or host-key prompt that never comes --
'' the exact class of hang SetupGitRepository already hit once from a different
'' cause (see its own comments).
Private Function frmNewProject.RemoteRepoExists(ByRef GitURL As String) As Boolean
	EnsureDirectoryExists(ExePath & WindowsSlash & "Temp")
	Dim As UString batPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_check.bat"
	Dim As UString resultPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_check.result"
	If FileExistsU(resultPath) Then Kill resultPath
	Dim As Integer Fn = FreeFile_
	If Open(batPath For Output As #Fn) <> 0 Then Return False
	Print #Fn, "@echo off"
	Print #Fn, "set GIT_TERMINAL_PROMPT=0"
	Print #Fn, "set GIT_SSH_COMMAND=ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new"
	Print #Fn, "git ls-remote " & Chr(34) & Trim(GitURL) & Chr(34) & " >NUL 2>&1"
	Print #Fn, "echo %errorlevel% > " & Chr(34) & resultPath & Chr(34)
	CloseFile_(Fn)
	PipeCmd batPath, True
	Dim As Boolean Exists = False
	If FileExistsU(resultPath) Then
		Dim As Integer FnR = FreeFile_
		If Open(resultPath For Input As #FnR) = 0 Then
			Dim As String resultLine
			Line Input #FnR, resultLine
			CloseFile_(FnR)
			Exists = (Trim(resultLine) = "0")
		End If
		Kill resultPath
	End If
	If FileExistsU(batPath) Then Kill batPath
	Return Exists
End Function

'' Maps the Git Provider dropdown's label to its fixed public SSH host. All four
'' providers offered here (GitHub/GitLab/Bitbucket/Codeberg) use one canonical
'' hosted domain and the standard git@host:user/repo.git shape -- unlike
'' self-hostable Gitea/Forgejo (no single domain) or SourceHut/SourceForge
'' (different URL shape entirely), which is why the dropdown stops at these four.
Private Function frmNewProject.GitProviderHost(ByRef ProviderLabel As String) As UString
	Select Case ProviderLabel
	Case "GitHub": Return "github.com"
	Case "GitLab": Return "gitlab.com"
	Case "Bitbucket": Return "bitbucket.org"
	Case "Codeberg": Return "codeberg.org"
	Case Else: Return ""
	End Select
End Function

'' Matching Templates/Git/*.md guide for a provider label. No bitbucket.md exists
'' yet, so Bitbucket falls back to the generic other.md until one is written.
Private Function frmNewProject.GitProviderGuideName(ByRef ProviderLabel As String) As String
	Select Case ProviderLabel
	Case "GitHub": Return "github.md"
	Case "GitLab": Return "gitlab.md"
	Case "Codeberg": Return "codeberg.md"
	Case Else: Return "other.md"
	End Select
End Function

'' Builds the SSH remote URL from Provider + Git Username + the project's own
'' name -- the whole reason those three fields replaced the old free-typed Git
'' URL field.
Private Function frmNewProject.BuildGitURL(ByRef ProviderLabel As String, ByRef GitUserName As String, ByRef ProjName As String) As UString
	Dim As UString host = GitProviderHost(ProviderLabel)
	If host = "" OrElse Trim(GitUserName) = "" Then Return ""
	Return "git@" & host & ":" & Trim(GitUserName) & "/" & ProjName & ".git"
End Function

'' Scope decision (owner, 2026-07-15, extended to all four providers same day):
'' automatic git init/remote setup runs for GitHub/GitLab/Bitbucket/Codeberg alike,
'' gated only on an existing SSH key -- that's the one precondition Astoria can
'' safely wire up without typed credentials, and the repo-existence preflight in
'' cmdOK_Click already covers the "create the empty repo first" step generically
'' for any of the four. No SSH key falls back to pointing at the matching
'' Templates/Git/*.md guide instead of doing nothing silently (no bitbucket.md
'' exists yet -- falls back to other.md until one is written, a later task).
'' Deliberately stops at `git remote add origin` -- `git push` is a separate,
'' explicit action the user takes themselves (it's the first action that
'' actually reaches a remote server / creates public history), not part of
'' project creation.
Private Sub frmNewProject.SetupGitRepository(ByRef ProjectFolder As UString, ByRef GitURL As String, ByRef GitUserName As String, ByRef GitEmail As String)
	Dim As String urlLower = LCase(GitURL)
	If SshKeyExists() Then
		'' Written to ExePath\Temp, not the new project folder itself -- if the
		'' script lived inside the project folder, "git add ." would stage (and
		'' "git commit" would then include) the setup script itself in the very
		'' first commit, since Kill only runs after PipeCmd returns.
		EnsureDirectoryExists(ExePath & WindowsSlash & "Temp")
		Dim As UString batPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_setup.bat"
		'' A machine with no global git user.name/user.email configured makes
		'' "git commit" fail silently (non-zero exit, no commit, script keeps
		'' going) -- found by direct reproduction: init/add/remote-add all
		'' succeeded but the repo was left with zero commits. Set the identity
		'' local to this one repo (never --global) from the dialog's own Git
		'' Username/Email fields, so the commit can't be skipped for that reason.
		Dim As String gitCfgName = Trim(GitUserName)
		If gitCfgName = "" Then gitCfgName = "Astoria IDE User"
		Dim As String gitCfgEmail = Trim(GitEmail)
		If gitCfgEmail = "" Then gitCfgEmail = "astoria-user@localhost"
		Dim As Integer Fn = FreeFile_
		If Open(batPath For Output As #Fn) <> 0 Then Exit Sub
		Print #Fn, "@echo off"
		Print #Fn, "cd /d " & Chr(34) & ProjectFolder & Chr(34)
		Print #Fn, "git init"
		Print #Fn, "git config user.name " & Chr(34) & gitCfgName & Chr(34)
		Print #Fn, "git config user.email " & Chr(34) & gitCfgEmail & Chr(34)
		Print #Fn, "git add ."
		Print #Fn, "git commit -m " & Chr(34) & "Initial commit" & Chr(34)
		Print #Fn, "git branch -M main"
		If Trim(GitURL) <> "" Then Print #Fn, "git remote add origin " & Trim(GitURL)
		CloseFile_(Fn)
		'' PipeCmd's UseShell:=True path already wraps this in cmd /c "...";
		'' quoting batPath ourselves here as well would double the outer quotes
		'' into cmd /c ""<path>"", which cmd.exe can misparse into a stray
		'' interactive shell that never exits -- and since PipeCmd waits
		'' INFINITE on the process, that hangs the whole UI thread. Pass the
		'' raw path, matching every other UseShell:=True call site.
		PipeCmd batPath, True
		If FileExistsU(batPath) Then Kill batPath
	Else
		Dim As String guideName = "other.md"
		If InStr(urlLower, "gitlab.com") > 0 Then guideName = "gitlab.md"
		If InStr(urlLower, "codeberg.org") > 0 Then guideName = "codeberg.md"
		If InStr(urlLower, "github.com") > 0 Then guideName = "github.md"
		MsgBox ("Automatic Git setup needs an existing SSH key.") & Chr(13,10) & Chr(13,10) & _
			("See") & " Templates\Git\" & guideName & " " & ("and") & " Templates\Git\sshkeys.md" & " " & ("for manual setup steps.")
		Me.BringToFront
	End If
End Sub
