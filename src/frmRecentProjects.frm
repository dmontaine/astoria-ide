	'#Compile -exx "Form1.rc"
'#Region "Form"
	#include once "frmRecentProjects.bi"
	
	Constructor frmRecentProjects
		With This
			.Name = "frmRecentProjects"
			.Text = ("Recent Projects")
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
			.Text = ("Cancel")
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
			.Text = ("OK")
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
		' lvRecent
		With lvRecent
			.Name = "lvRecent"
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
			.Columns.Add ("File"), , 150
			.Columns.Add ("Path"), , 450
			.OnItemActivate = @lvRecent_ItemActivate_
			.Parent = @This
		End With
	End Constructor

'#End Region

Private Sub frmRecentProjects.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmRecentProjects Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmRecentProjects.cmdOK_Click(ByRef Sender As Control)
	SelectedFile = ""
	If lvRecent.SelectedItemIndex > -1 Then
		SelectedFile = GetFullPath(lvRecent.ListItems.Item(lvRecent.SelectedItemIndex)->Text(1))
		ModalResult = ModalResults.OK
		Me.CloseForm
	Else
		MsgBox ("Select recent file!")
		Me.BringToFront
	End If
End Sub

Private Sub frmRecentProjects.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmRecentProjects Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmRecentProjects.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmRecentProjects.lvRecent_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmRecentProjects Ptr, Sender.Designer)).lvRecent_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmRecentProjects.lvRecent_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmRecentProjects.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmRecentProjects Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmRecentProjects.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	SelectedFile = ""
	lvRecent.ListItems.Clear
	PruneMissingMRUProjects()
	Dim sTmp As WString * 1024
	Dim As WString * MAX_PATH fullPath
	For i As Integer = 0 To MRUProjects.Count - 1
		sTmp = MRUProjects.Item(i)
		If Not EndsWith(LCase(sTmp), ".vfp") Then Continue For
		fullPath = GetFullPath(sTmp)
		If Not FileExistsU(fullPath) Then Continue For
		lvRecent.ListItems.Add GetFileName(fullPath), GetIconName(fullPath)
		lvRecent.ListItems.Item(lvRecent.ListItems.Count - 1)->Text(1) = fullPath
	Next
End Sub
