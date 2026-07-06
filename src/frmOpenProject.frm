	'#Compile -exx "Form1.rc"
'#Region "Form"
	#include once "frmOpenProject.bi"
	
	Constructor frmOpenProject
		With This
			.Name = "frmOpenProject"
			.Text = ML("Open Project")
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
			.TabIndex = 2
			.SetBounds 0, 371, 641, 30
			.Parent = @This
		End With
		' cmdBrowse
		With cmdBrowse
			.Name = "cmdBrowse"
			.Text = ML("Browse") & "..."
			.Align = DockStyle.alLeft
			.ExtraMargins.Left = 10
			.ExtraMargins.Top = 0
			.ExtraMargins.Bottom = 10
			.TabIndex = 5
			.SetBounds 10, 0, 88, 20
			.Designer = @This
			.OnClick = @cmdBrowse_Click_
			.Parent = @pnlBottom
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 10
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 10
			.TabIndex = 4
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
			.TabIndex = 3
			.SetBounds 430, 0, 88, 20
			.Default = True
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlBottom
		End With
		' lvProjects
		With lvProjects
			.Name = "lvProjects"
			.Text = "ListView1"
			.View = ViewStyle.vsDetails
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.Images = @imgList
			.SmallImages = @imgList
			.TabIndex = 1
			.SetBounds 10, 10, 621, 361
			.Designer = @This
			.Columns.Add ML("File"), , 150
			.Columns.Add ML("Path"), , 450
			.OnItemActivate = @lvProjects_ItemActivate_
			.Parent = @This
		End With
	End Constructor

'#End Region

Private Sub frmOpenProject.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmOpenProject.cmdOK_Click(ByRef Sender As Control)
	SelectedFile = ""
	If lvProjects.SelectedItemIndex > -1 Then
		SelectedFile = WinOsPath(ProjectFiles.Item(lvProjects.SelectedItemIndex))
		ModalResult = ModalResults.OK
		Me.CloseForm
	Else
		MsgBox ML("Select project!")
		Me.BringToFront
	End If
End Sub

Private Sub frmOpenProject.cmdBrowse_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdBrowse_Click(Sender)
End Sub
Private Sub frmOpenProject.cmdBrowse_Click(ByRef Sender As Control)
	Dim As FolderBrowserDialog BrowseD
	BrowseD.InitialDir = GetFullPath(*ProjectsPath)
	If BrowseD.Execute Then
		SelectedFile = FindProjectVfpInFolder(WinOsPath(BrowseD.Directory))
		If SelectedFile = "" Then
			MsgBox ML("No project file (.vfp) found in the selected folder."), , mtWarning
			Me.BringToFront
			Exit Sub
		End If
		ModalResult = ModalResults.OK
		Me.CloseForm
	End If
End Sub

Private Sub frmOpenProject.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmOpenProject.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmOpenProject.lvProjects_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).lvProjects_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOpenProject.lvProjects_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmOpenProject.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmOpenProject.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	SelectedFile = ""
	lvProjects.ListItems.Clear
	ProjectFiles.Clear
	PruneMissingMRUProjects()
	Dim sTmp As WString * 1024
	Dim As WString * MAX_PATH fullPath
	For i As Integer = 0 To MRUProjects.Count - 1
		sTmp = MRUProjects.Item(i)
		If Not EndsWith(LCase(sTmp), ".vfp") Then Continue For
		fullPath = GetFullPath(sTmp)
		If Not FileExistsU(fullPath) Then Continue For
		ProjectFiles.Add fullPath
		lvProjects.ListItems.Add GetFileName(fullPath), GetIconName(fullPath)
		lvProjects.ListItems.Item(lvProjects.ListItems.Count - 1)->Text(1) = fullPath
	Next
End Sub
