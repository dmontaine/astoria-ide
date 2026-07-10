	#include once "frmNewFileName.bi"

Constructor frmNewFileName
	With This
		.Name = "frmNewFileName"
		.Text = ("New File")
			.Icon.LoadFromResourceID(1)
		.Designer = @This
		.BorderStyle = FormBorderStyle.FixedDialog
		.MaximizeBox = False
		.MinimizeBox = False
		.OnCreate = @Form_Create_
		.SetBounds 0, 0, 657, 120
		.StartPosition = FormStartPosition.CenterParent
	End With
	' pnlBottom -- footer (file name row + OK/Cancel), same layout as New File / New Project
	With pnlBottom
		.Name = "pnlBottom"
		.Text = ""
		.Align = DockStyle.alBottom
		.TabIndex = 3
		.SetBounds 0, 0, 641, 68
		.Parent = @This
	End With
	' pnlFileName -- top row inside footer
	With pnlFileName
		.Name = "pnlFileName"
		.Text = ""
		.Align = DockStyle.alTop
		.TabIndex = 2
		.ExtraMargins.Left = 10
		.ExtraMargins.Right = 10
		.SetBounds 0, 0, 641, 32
		.Parent = @pnlBottom
	End With
	' lblName
	With lblName
		.Name = "lblName"
		.Text = ("Name") & ":"
		.Align = DockStyle.alLeft
		.TabIndex = 1
		.ExtraMargins.Top = 8
		.ExtraMargins.Bottom = 8
		.SetBounds 0, 0, 180, 32
		.Parent = @pnlFileName
	End With
	' txtName
	With txtName
		.Name = "txtName"
		.Text = ""
		.Align = DockStyle.alClient
		.ExtraMargins.Top = 5
		.ExtraMargins.Bottom = 5
		.TabIndex = 0
		.SetBounds 180, 0, 431, 32
		.Parent = @pnlFileName
	End With
	' cmdCancel
	With cmdCancel
		.Name = "cmdCancel"
		.Text = ("Cancel")
		.Align = DockStyle.alRight
		.ExtraMargins.Bottom = 8
		.ExtraMargins.Top = 4
		.ExtraMargins.Right = 10
		.TabIndex = 5
		.SetBounds 527, 36, 88, 20
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
		.TabIndex = 4
		.SetBounds 430, 36, 88, 20
		.Default = True
		.Designer = @This
		.OnClick = @cmdOK_Click_
		.Parent = @pnlBottom
	End With
End Constructor

'#End Region

Private Sub frmNewFileName.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewFileName Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmNewFileName.cmdOK_Click(ByRef Sender As Control)
	SelectedName = ""
	Dim As UString typedName = Trim(txtName.Text, Any !" \t" + Chr(10) + Chr(13))
	If typedName = "" Then
		MsgBox ("Enter a name.")
		txtName.SetFocus
		Me.BringToFront
		Exit Sub
	End If
	If Not IsValidProjectItemName(typedName) Then
		MsgBox ("Enter a valid name without paths or file extensions."), , mtWarning
		txtName.SetFocus
		Me.BringToFront
		Exit Sub
	End If
	'' Same dedup convention AddFromTemplate's own numeric-suffix loop already uses --
	'' a plain name or an already-dirty "name*" node both count as a collision. Tree node
	'' text always includes the extension, so compare against typedName & TargetExt, not
	'' the bare typed name.
	If TargetNode <> 0 AndAlso (TargetNode->Nodes.Contains(typedName & TargetExt) OrElse TargetNode->Nodes.Contains(typedName & TargetExt & "*")) Then
		MsgBox ("This name is exists!"), , mtWarning
		txtName.SetFocus
		Me.BringToFront
		Exit Sub
	End If
	SelectedName = typedName
	ModalResult = ModalResults.OK
	Me.CloseForm
End Sub

Private Sub frmNewFileName.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewFileName Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmNewFileName.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmNewFileName.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewFileName Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmNewFileName.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	SelectedName = ""
	If Prompt <> "" Then lblName.Text = Prompt
	txtName.Text = DefaultName
	txtName.SelStart = 0
	txtName.SelLength = Len(DefaultName)
	txtName.SetFocus
End Sub
