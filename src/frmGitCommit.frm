	#include once "frmGitCommit.bi"

Constructor frmGitCommit
	With This
		.Name = "frmGitCommit"
		.Text = ("Git Commit")
		.Icon.LoadFromResourceID(1)
		.Designer = @This
		.BorderStyle = FormBorderStyle.FixedDialog
		.MaximizeBox = False
		.MinimizeBox = False
		.OnCreate = @Form_Create_
		.SetBounds 0, 0, 460, 420
		.StartPosition = FormStartPosition.CenterParent
	End With
	' pnlBottom -- footer with OK/Cancel
	With pnlBottom
		.Name = "pnlBottom"
		.Text = ""
		.Align = DockStyle.alBottom
		.TabIndex = 5
		.SetBounds 0, 0, 460, 46
		.Parent = @This
	End With
	' pnlFiles -- top section: "Files to be committed:" + the read-only file list
	With pnlFiles
		.Name = "pnlFiles"
		.Text = ""
		.Align = DockStyle.alTop
		.TabIndex = 6
		.SetBounds 0, 0, 460, 150
		.Parent = @This
	End With
	' lblFiles -- header for the file list
	With lblFiles
		.Name = "lblFiles"
		.Text = ("Files to be committed") & ":"
		.Align = DockStyle.alTop
		.ExtraMargins.Left = 10
		.ExtraMargins.Top = 8
		.ExtraMargins.Bottom = 2
		.TabIndex = 7
		.SetBounds 0, 0, 460, 26
		.Parent = @pnlFiles
	End With
	' txtFiles -- read-only list of what git add -A will stage
	With txtFiles
		.Name = "txtFiles"
		.Text = ""
		.Align = DockStyle.alClient
		.Multiline = True
		.ReadOnly = True
		.ScrollBars = ScrollBarsType.Vertical
		.ExtraMargins.Left = 10
		.ExtraMargins.Right = 10
		.ExtraMargins.Bottom = 6
		.TabIndex = 3
		.SetBounds 0, 0, 460, 124
		.Parent = @pnlFiles
	End With
	' lblPrompt -- "Commit message:" header
	With lblPrompt
		.Name = "lblPrompt"
		.Text = ("Commit message") & ":"
		.Align = DockStyle.alTop
		.ExtraMargins.Left = 10
		.ExtraMargins.Top = 4
		.ExtraMargins.Bottom = 4
		.TabIndex = 4
		.SetBounds 0, 0, 460, 26
		.Parent = @This
	End With
	' txtMessage -- multiline commit message body (subject on line 1, blank line, body)
	With txtMessage
		.Name = "txtMessage"
		.Text = ""
		.Align = DockStyle.alClient
		.Multiline = True
		.WantReturn = True
		.ScrollBars = ScrollBarsType.Vertical
		.ExtraMargins.Left = 10
		.ExtraMargins.Right = 10
		.ExtraMargins.Bottom = 6
		.TabIndex = 0
		.SetBounds 0, 0, 440, 200
		.Parent = @This
	End With
	' cmdCancel
	With cmdCancel
		.Name = "cmdCancel"
		.Text = ("Cancel")
		.Align = DockStyle.alRight
		.ExtraMargins.Top = 10
		.ExtraMargins.Bottom = 10
		.ExtraMargins.Right = 10
		.TabIndex = 2
		.SetBounds 340, 10, 88, 26
		.Designer = @This
		.OnClick = @cmdCancel_Click_
		.Parent = @pnlBottom
	End With
	' cmdOK
	With cmdOK
		.Name = "cmdOK"
		.Text = ("OK")
		.Align = DockStyle.alRight
		.ExtraMargins.Top = 10
		.ExtraMargins.Bottom = 10
		.ExtraMargins.Right = 10
		.TabIndex = 1
		.Default = True
		.SetBounds 244, 10, 88, 26
		.Designer = @This
		.OnClick = @cmdOK_Click_
		.Parent = @pnlBottom
	End With
End Constructor

'#End Region

Private Sub frmGitCommit.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmGitCommit Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmGitCommit.cmdOK_Click(ByRef Sender As Control)
	CommitMessage = ""
	Dim As UString typed = Trim(txtMessage.Text, Any !" \t" + Chr(10) + Chr(13))
	If typed = "" Then
		MsgBox ("Enter a commit message."), , mtWarning
		txtMessage.SetFocus
		Me.BringToFront
		Exit Sub
	End If
	CommitMessage = typed
	ModalResult = ModalResults.OK
	Me.CloseForm
End Sub

Private Sub frmGitCommit.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmGitCommit Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmGitCommit.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmGitCommit.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmGitCommit Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmGitCommit.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	CommitMessage = ""
	txtMessage.Text = ""
	If Trim(FilesList) = "" Then txtFiles.Text = ("(no changes)") Else txtFiles.Text = FilesList
	txtMessage.SetFocus
End Sub
