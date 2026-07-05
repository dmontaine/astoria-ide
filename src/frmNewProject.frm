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
			.SetBounds 0, 0, 520, 390
			.StartPosition = FormStartPosition.CenterParent
		End With
		' lblPrompt
		With lblPrompt
			.Name = "lblPrompt"
			.Text = ML("Select a project template below:")
			.TabIndex = 0
			.SetBounds 10, 10, 300, 18
			.Parent = @This
		End With
		' lvTemplates
		With lvTemplates
			.Name = "lvTemplates"
			.Text = "ListView1"
			.View = ViewStyle.vsIcon
			.Images = @imgList32
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 35
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.TabIndex = 1
			.SetBounds 10, 35, 484, 260
			.Designer = @This
			.OnItemActivate = @lvTemplates_ItemActivate_
			.OnSelectedItemChanged = @lvTemplates_SelectedItemChanged_
			.Parent = @This
		End With
		' pnlSaveLocation
		With pnlSaveLocation
			.Name = "pnlSaveLocation"
			.Text = ""
			.Align = DockStyle.alBottom
			.AutoSize = True
			.TabIndex = 2
			.SetBounds 10, 300, 484, 48
			.Visible = False
			.Parent = @This
		End With
		' lblSaveLocation
		With lblSaveLocation
			.Name = "lblSaveLocation"
			.Text = ML("Project name") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 3
			.SetBounds 0, 0, 100, 21
			.Parent = @pnlSaveLocation
		End With
		' txtSaveLocation
		With txtSaveLocation
			.Name = "txtSaveLocation"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 4
			.TabIndex = 4
			.SetBounds 100, 0, 352, 21
			.Parent = @pnlSaveLocation
		End With
		' cmdSaveLocation
		With cmdSaveLocation
			.Name = "cmdSaveLocation"
			.Text = "..."
			.Align = DockStyle.alRight
			.TabIndex = 5
			.SetBounds 456, 0, 24, 22
			.OnClick = @cmdSaveLocation_Click_
			.Parent = @pnlSaveLocation
		End With
		' pnlBottom
		With pnlBottom
			.Name = "pnlBottom"
			.Text = ""
			.Align = DockStyle.alBottom
			.AutoSize = True
			.TabIndex = 6
			.SetBounds 10, 350, 484, 30
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.Align = DockStyle.alRight
			.ExtraMargins.Right = 10
			.TabIndex = 7
			.SetBounds 300, 0, 80, 24
			.Default = True
			.OnClick = @cmdOK_Click_
			.Parent = @pnlBottom
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Right = 5
			.TabIndex = 8
			.SetBounds 390, 0, 80, 24
			.OnClick = @cmdCancel_Click_
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
	If lvTemplates.SelectedItemIndex > -1 Then
		Dim As String TemplateName = TemplateNames.Item(lvTemplates.SelectedItemIndex)
		SelectedTemplate = ExePath & "/Templates/Projects/" & TemplateName & "/" & TemplateName & ".vfp"
		SelectedFolder = GetFullPath(txtSaveLocation.Text)
		If FolderExists(SelectedFolder) Then
			MsgBox ML("Selected folder exists, change the project name!")
			Me.BringToFront
			Exit Sub
		End If
		Dim As UString TemplateFolder = ExePath & "/Templates/Projects/" & TemplateName
		FolderCopy TemplateFolder, SelectedFolder
		Dim As WString * MAX_PATH SrcPath, DestPath
		SrcPath = SelectedFolder & "/" & TemplateName & ".vfp"
		DestPath = SelectedFolder & "/" & GetFileName(SelectedFolder) & ".vfp"
		MoveFile @SrcPath, @DestPath
		ModalResult = ModalResults.OK
		Me.CloseForm
	End If
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
	pnlSaveLocation.Visible = True
	Var n = 0
	Dim As String ProjectName = "Project"
	Do
		n = n + 1
		NewName = ProjectName & Str(n)
	Loop While FolderExists(GetFullPath(*ProjectsPath & "/" & NewName))
	txtSaveLocation.Text = Replace(*ProjectsPath, BackSlash, "/") & "/" & NewName
End Sub

Private Sub frmNewProject.cmdSaveLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).cmdSaveLocation_Click(Sender)
End Sub
Private Sub frmNewProject.cmdSaveLocation_Click(ByRef Sender As Control)
	Dim BrowseD As FolderBrowserDialog
	BrowseD.InitialDir = GetFullPath(Replace(GetFolderName(txtSaveLocation.Text), BackSlash, "/"))
	If BrowseD.Execute Then
		txtSaveLocation.Text = BrowseD.Directory & "/" & Mid(txtSaveLocation.Text, InStrRev(Replace(txtSaveLocation.Text, BackSlash, "/"), "/") + 1)
	End If
End Sub

Private Sub frmNewProject.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmNewProject.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	lvTemplates.ListItems.Clear
	TemplateNames.Clear
	Dim As String ProjectsFolder = ExePath & "/Templates/Projects/"
	Dim As String f = Dir(ProjectsFolder & "*", fbDirectory)
	While f <> ""
		If f <> "." AndAlso f <> ".." Then
			Dim As String vfpFile = Dir(ProjectsFolder & f & "/*.vfp")
			If vfpFile <> "" Then
				Dim As String ImageName = "App" & ..Left(f, IfNegative(InStr(f, " ") - 1, Len(f)))
				If imgList32.IndexOf(ImageName) < 0 Then ImageName = "AppGUI"
				lvTemplates.ListItems.Add ML(f), ImageName
				TemplateNames.Add f
			End If
		End If
		f = Dir()
	Wend
End Sub
