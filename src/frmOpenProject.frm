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
		' OpenFileControl1
		With OpenFileControl1
			.Name = "OpenFileControl1"
			.Text = "OpenFileControl1"
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.ExtraMargins.Bottom = 10
			.TabIndex = 1
			.SetBounds 10, 10, 621, 361
			.Designer = @This
			.Filter = ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("All Files") & "|*.*|"
			.OnFileActivate = @OpenFileControl1_FileActivate_
			.Parent = @This
		End With
	End Constructor

'#End Region

Private Sub frmOpenProject.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmOpenProject.cmdOK_Click(ByRef Sender As Control)
	SelectedFile = ""
	If OpenFileControl1.FileName <> "" Then
		SelectedFile = OpenFileControl1.FileName
		ModalResult = ModalResults.OK
		Me.CloseForm
	Else
		MsgBox ML("Select file!")
		Me.BringToFront
	End If
End Sub

Private Sub frmOpenProject.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmOpenProject.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmOpenProject.OpenFileControl1_FileActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As OpenFileControl)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).OpenFileControl1_FileActivate(Sender)
End Sub
Private Sub frmOpenProject.OpenFileControl1_FileActivate(ByRef Sender As OpenFileControl)
	cmdOK_Click cmdOK
End Sub

Private Sub frmOpenProject.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOpenProject Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmOpenProject.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	SelectedFile = ""
	OpenFileControl1.FileName = ""
End Sub

Sub frmOpenProject.ApplyProjectsInitialDir()
	Dim As WString * MAX_PATH projectsDir
	projectsDir = GetFullPath(*ProjectsPath)
	OpenFileControl1.InitialDir = projectsDir
End Sub
