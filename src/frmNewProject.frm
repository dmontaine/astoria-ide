	'#Compile -exx "Form1.rc"
'#Region "Form"
	#include once "frmNewProject.bi"
	
	Constructor frmNewProject
		With This
			.Name = "frmNewProject"
			.Text = ML("New Project")
				.Icon.LoadFromResourceID(1)
			.Designer = @This
			.BorderStyle = FormBorderStyle.Sizable
			.OnCreate = @Form_Create_
			.SetBounds 0, 0, 657, 440
			.StartPosition = FormStartPosition.CenterParent
		End With
		' pnlBottom
		With pnlBottom
			.Name = "pnlBottom"
			.Text = ""
			.Align = DockStyle.alBottom
			.TabIndex = 6
			.SetBounds 0, 371, 641, 30
			.Parent = @This
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 10
			.TabIndex = 8
			.SetBounds 527, 0, 88, 20
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @pnlBottom
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.Align = DockStyle.alRight
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 10
			.ExtraMargins.Bottom = 10
			.TabIndex = 7
			.SetBounds 430, 0, 88, 20
			.Default = True
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlBottom
		End With
		' pnlProjectName
		With pnlProjectName
			.Name = "pnlProjectName"
			.Text = ""
			.Align = DockStyle.alBottom
			.TabIndex = 5
			.SetBounds 10, 335, 621, 30
			.Parent = @This
		End With
		' lblProjectName
		With lblProjectName
			.Name = "lblProjectName"
			.Text = ML("Project Name") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 4
			.SetBounds 0, 4, 110, 21
			.Parent = @pnlProjectName
		End With
		' txtProjectName
		With txtProjectName
			.Name = "txtProjectName"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 10
			.TabIndex = 3
			.SetBounds 110, 4, 501, 21
			.Parent = @pnlProjectName
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
			.TabIndex = 2
			.SetBounds 10, 32, 621, 303
			.Designer = @This
			.Columns.Add ML("Template"), , 500, cfLeft
			.OnItemActivate = @lvTemplates_ItemActivate_
			.OnSelectedItemChanged = @lvTemplates_SelectedItemChanged_
			.Parent = @This
		End With
		' lblProjectTemplates
		With lblProjectTemplates
			.Name = "lblProjectTemplates"
			.Text = ML("Project Templates")
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
	If lvTemplates.SelectedItemIndex = -1 Then
		MsgBox ML("Select template!")
		Me.BringToFront
		Exit Sub
	End If
	Dim As String ProjectName = Trim(txtProjectName.Text)
	If ProjectName = "" Then
		MsgBox ML("Enter a project name!")
		Me.BringToFront
		Exit Sub
	End If
	Dim As String TemplateName = TemplateNames.Item(lvTemplates.SelectedItemIndex)
	SelectedTemplate = ExePath & "/Templates/Projects/" & TemplateName & ".vfp"
	SelectedFolder = GetFullPath(*ProjectsPath & "/" & ProjectName)
	If FolderExists(SelectedFolder) Then
		MsgBox ML("Selected folder exists, change the project name!")
		Me.BringToFront
		Exit Sub
	ElseIf Not FolderExists(GetFolderName(SelectedFolder, False)) Then
		MsgBox ML("Parent folder not exists, change the parent folder!")
		Me.BringToFront
		Exit Sub
	End If
	Dim As UString TemplateFolder = ExePath & "/Templates/Projects/" & TemplateName
	If FolderExists(TemplateFolder) Then FolderCopy TemplateFolder, SelectedFolder
	If FileExists(SelectedTemplate) Then
		FileCopy SelectedTemplate, SelectedFolder & "/" & GetFileName(SelectedFolder) & ".vfp"
	End If
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
	If lvTemplates.SelectedItemIndex = -1 Then Exit Sub
End Sub

Private Sub frmNewProject.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmNewProject.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	lvTemplates.ListItems.Clear
	TemplateNames.Clear
	Dim As String f = Dir(ExePath & "/Templates/Projects/*.vfp")
	While f <> ""
		If EndsWith(LCase(f), ".vfp") Then
			Dim As String TemplateName = ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			Dim As String ImageName = "App" & ..Left(TemplateName, IfNegative(InStr(TemplateName, " ") - 1, Len(TemplateName)))
			If imgList32.IndexOf(ImageName) < 0 Then ImageName = "AppGUI"
			lvTemplates.ListItems.Add ML(TemplateName), ImageName
			TemplateNames.Add TemplateName
		End If
		f = Dir()
	Wend
	Var n = 0
	Dim As String ProjectName = "Project"
	Dim NewName As String
	Do
		n = n + 1
		NewName = ProjectName & Str(n)
	Loop While FolderExists(GetFullPath(*ProjectsPath & "/" & NewName))
	txtProjectName.Text = NewName
End Sub
