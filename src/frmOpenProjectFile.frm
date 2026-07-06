	'#Compile -exx "Form1.rc"
'#Region "Form"
	#include once "frmOpenProjectFile.bi"
	
	Constructor frmOpenProjectFile
		With This
			.Name = "frmOpenProjectFile"
			.Text = ML("Open File")
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
		' lvFiles
		With lvFiles
			.Name = "lvFiles"
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
			.OnItemActivate = @lvFiles_ItemActivate_
			.Parent = @This
		End With
	End Constructor

'#End Region

Private Sub frmOpenProjectFile.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProjectFile Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmOpenProjectFile.cmdOK_Click(ByRef Sender As Control)
	SelectedFile = ""
	If lvFiles.SelectedItemIndex > -1 Then
		SelectedFile = lvFiles.ListItems.Item(lvFiles.SelectedItemIndex)->Text(1)
		ModalResult = ModalResults.OK
		Me.CloseForm
	Else
		MsgBox ML("Select file!")
		Me.BringToFront
	End If
End Sub

Private Sub frmOpenProjectFile.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProjectFile Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmOpenProjectFile.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmOpenProjectFile.lvFiles_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOpenProjectFile Ptr, Sender.Designer)).lvFiles_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOpenProjectFile.lvFiles_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmOpenProjectFile.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProjectFile Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmOpenProjectFile.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	SelectedFile = ""
	lvFiles.ListItems.Clear
	Dim As UString projectDir = GetProjectDirectory()
	If projectDir = "" Then Return
	Dim As WStringList paths
	Dim As UInteger Attr
	Dim As WString * MAX_PATH entry = Dir(projectDir & Slash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbArchive, Attr)
	While entry <> ""
		If (Attr And fbDirectory) = 0 Then
			If IsProjectOpenFileType(entry) AndAlso FileExistsU(WinOsPath(projectDir & Slash & entry)) Then
				paths.Add WinOsPath(projectDir & Slash & entry)
			End If
		End If
		entry = Dir(Attr)
	Wend
	paths.Sort
	For i As Integer = 0 To paths.Count - 1
		Dim As UString fullPath = paths.Item(i)
		lvFiles.ListItems.Add GetFileNameU(fullPath), GetIconName(fullPath)
		lvFiles.ListItems.Item(lvFiles.ListItems.Count - 1)->Text(1) = fullPath
	Next
End Sub
