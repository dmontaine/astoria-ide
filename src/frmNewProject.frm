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
			.SetBounds 0, 0, 480, 290
			.StartPosition = FormStartPosition.CenterParent
		End With
		' pnlBottom — footer: Project Name / Primary Form Name / Primary Module Name rows,
		' stacked above the OK/Cancel/Open Existing button row. Everything the old two-dialog
		' flow asked for across separate popups now lives in this one dialog.
		With pnlBottom
			.Name = "pnlBottom"
			.Text = ""
			.Align = DockStyle.alBottom
			.TabIndex = 11
			.SetBounds 0, 0, 464, 132
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
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 8
			.ExtraMargins.Top = 4
			.ExtraMargins.Right = 10
			.TabIndex = 14
			.SetBounds 527, 100, 88, 20
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
			.TabIndex = 13
			.SetBounds 430, 100, 88, 20
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
			.TabIndex = 12
			.SetBounds 10, 100, 160, 20
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
