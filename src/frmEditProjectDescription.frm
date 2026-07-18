	#include once "frmEditProjectDescription.bi"

Constructor frmEditProjectDescription
	With This
		.Name = "frmEditProjectDescription"
		.Text = ("Edit Project Description")
		.Icon.LoadFromResourceID(1)
		.Designer = @This
		.BorderStyle = FormBorderStyle.FixedDialog
		.MaximizeBox = False
		.MinimizeBox = False
		.OnCreate = @Form_Create_
		.SetBounds 0, 0, 470, 512
		.StartPosition = FormStartPosition.CenterParent
	End With
	' pnlBottom -- footer with OK/Cancel
	With pnlBottom
		.Name = "pnlBottom"
		.Align = DockStyle.alBottom
		.TabIndex = 9
		.SetBounds 0, 0, 470, 46
		.Parent = @This
	End With
	' lblInfo -- header for the read-only block
	With lblInfo
		.Name = "lblInfo"
		.Text = ("Project details (read-only)") & ":"
		.Align = DockStyle.alTop
		.ExtraMargins.Left = 10
		.ExtraMargins.Top = 8
		.ExtraMargins.Bottom = 2
		.TabIndex = 10
		.SetBounds 0, 0, 470, 24
		.Parent = @This
	End With
	' txtInfo -- read-only summary of the immutable fields
	With txtInfo
		.Name = "txtInfo"
		.Align = DockStyle.alTop
		.Multiline = True
		.ReadOnly = True
		.ScrollBars = ScrollBarsType.Vertical
		.ExtraMargins.Left = 10
		.ExtraMargins.Right = 10
		.ExtraMargins.Bottom = 6
		.TabIndex = 8
		.SetBounds 0, 0, 470, 128
		.Parent = @This
	End With
	' pnlAuthor -- editable Author row
	With pnlAuthor
		.Name = "pnlAuthor"
		.Align = DockStyle.alTop
		.ExtraMargins.Left = 10
		.ExtraMargins.Right = 10
		.TabIndex = 11
		.SetBounds 0, 0, 470, 32
		.Parent = @This
	End With
	With lblAuthor
		.Name = "lblAuthor"
		.Text = ("Author") & ":"
		.Align = DockStyle.alLeft
		.CenterImage = True
		.TabIndex = 12
		.SetBounds 0, 0, 110, 32
		.Parent = @pnlAuthor
	End With
	With txtAuthor
		.Name = "txtAuthor"
		.Align = DockStyle.alClient
		.ExtraMargins.Top = 5
		.ExtraMargins.Bottom = 5
		.TabIndex = 0
		.SetBounds 110, 0, 340, 32
		.Parent = @pnlAuthor
	End With
	' pnlLicense -- editable License row
	With pnlLicense
		.Name = "pnlLicense"
		.Align = DockStyle.alTop
		.ExtraMargins.Left = 10
		.ExtraMargins.Right = 10
		.TabIndex = 13
		.SetBounds 0, 0, 470, 32
		.Parent = @This
	End With
	With lblLicense
		.Name = "lblLicense"
		.Text = ("License") & ":"
		.Align = DockStyle.alLeft
		.CenterImage = True
		.TabIndex = 14
		.SetBounds 0, 0, 110, 32
		.Parent = @pnlLicense
	End With
	With cboLicense
		.Name = "cboLicense"
		.Style = ComboBoxEditStyle.cbDropDownList
		.Align = DockStyle.alClient
		.ExtraMargins.Top = 5
		.ExtraMargins.Bottom = 5
		.TabIndex = 1
		.SetBounds 110, 0, 340, 32
		.Designer = @This
		.Parent = @pnlLicense
	End With
	' pnlAI -- Make project AI friendly + AI tool
	With pnlAI
		.Name = "pnlAI"
		.Align = DockStyle.alTop
		.ExtraMargins.Left = 10
		.ExtraMargins.Right = 10
		.TabIndex = 15
		.SetBounds 0, 0, 470, 32
		.Parent = @This
	End With
	With chkAIFriendly
		.Name = "chkAIFriendly"
		.Caption = ("Make project AI friendly")
		.Align = DockStyle.alLeft
		.TabIndex = 2
		.SetBounds 0, 5, 190, 22
		.Designer = @This
		.OnClick = @chkAI_Click_
		.Parent = @pnlAI
	End With
	With cboAITool
		.Name = "cboAITool"
		.Style = ComboBoxEditStyle.cbDropDownList
		.Align = DockStyle.alClient
		.ExtraMargins.Top = 5
		.ExtraMargins.Bottom = 5
		.TabIndex = 3
		.SetBounds 190, 0, 260, 32
		.Designer = @This
		.Parent = @pnlAI
	End With
	' lblDescription
	With lblDescription
		.Name = "lblDescription"
		.Text = ("Description") & ":"
		.Align = DockStyle.alTop
		.ExtraMargins.Left = 10
		.ExtraMargins.Top = 4
		.ExtraMargins.Bottom = 2
		.TabIndex = 16
		.SetBounds 0, 0, 470, 22
		.Parent = @This
	End With
	' txtDescription -- multiline, fills the rest
	With txtDescription
		.Name = "txtDescription"
		.Align = DockStyle.alClient
		.Multiline = True
		.WantReturn = True
		.ScrollBars = ScrollBarsType.Vertical
		.ExtraMargins.Left = 10
		.ExtraMargins.Right = 10
		.ExtraMargins.Bottom = 6
		.TabIndex = 4
		.SetBounds 0, 0, 470, 100
		.Parent = @This
	End With
	' cmdCancel / cmdOK
	With cmdCancel
		.Name = "cmdCancel"
		.Text = ("Cancel")
		.Align = DockStyle.alRight
		.ExtraMargins.Top = 10
		.ExtraMargins.Bottom = 10
		.ExtraMargins.Right = 10
		.TabIndex = 6
		.SetBounds 348, 10, 88, 26
		.Designer = @This
		.OnClick = @cmdCancel_Click_
		.Parent = @pnlBottom
	End With
	With cmdOK
		.Name = "cmdOK"
		.Text = ("OK")
		.Align = DockStyle.alRight
		.ExtraMargins.Top = 10
		.ExtraMargins.Bottom = 10
		.ExtraMargins.Right = 10
		.TabIndex = 5
		.Default = True
		.SetBounds 252, 10, 88, 26
		.Designer = @This
		.OnClick = @cmdOK_Click_
		.Parent = @pnlBottom
	End With
End Constructor

'#End Region

'' Add value to a cbDropDownList combo only if it isn't already an option.
Private Sub EPD_EnsureItem(ByRef cbo As ComboBoxEdit, ByRef value As UString)
	If Trim(value) <> "" AndAlso cbo.IndexOf(value) < 0 Then cbo.AddItem value
End Sub

Private Sub frmEditProjectDescription.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmEditProjectDescription Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmEditProjectDescription.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Dim As ProjectDescriptionData d
	ReadProjectDescription(ProjectFolder, d)
	'' Read-only info block.
	Dim As UString modeText = ("Local Project")
	If d.Mode = ProjectCreateMode.pcmExistingGit Then modeText = ("Git Project")
	Dim As UString startup = ("(none)")
	If FileExistsU(WinOsPath(ProjectFolder & "/Main.frm")) Then
		startup = "Main.frm " & ("(startup form)")
	ElseIf FileExistsU(WinOsPath(ProjectFolder & "/Main.bas")) Then
		startup = "Main.bas " & ("(startup module)")
	End If
	Dim As UString gitText = ("(local project)")
	If Trim(d.GitURL) <> "" Then
		gitText = d.GitURL
	ElseIf d.Mode = ProjectCreateMode.pcmExistingGit Then
		gitText = d.GitProvider & " / " & d.GitUserName
	End If
	Dim As UString nl = Chr(13) & Chr(10)
	txtInfo.Text = ("Project Name") & ":  " & d.ProjectName & nl & _
		("Template") & ":  " & d.Template & nl & _
		("Mode") & ":  " & modeText & nl & _
		("Startup") & ":  " & startup & nl & _
		("Created") & ":  " & d.Created & nl & _
		("Git remote") & ":  " & gitText
	'' Editable fields.
	txtAuthor.Text = d.Author
	txtDescription.Text = d.Description
	cboLicense.Clear
	cboLicense.AddItem ("GPL") : cboLicense.AddItem ("LGPL") : cboLicense.AddItem ("Apache")
	cboLicense.AddItem ("MIT") : cboLicense.AddItem ("Mozilla") : cboLicense.AddItem ("BSD")
	cboLicense.AddItem ("Freeware") : cboLicense.AddItem ("Proprietary") : cboLicense.AddItem ("Other")
	EPD_EnsureItem(cboLicense, d.License)
	cboLicense.ItemIndex = Max(0, cboLicense.IndexOf(d.License))
	'' AI Tool list from Templates/AI subfolders (same data-driven source as New Project).
	cboAITool.Clear
	Dim As UString aiRoot = WinOsPath(ExePath & "/Templates/AI")
	Dim As UInteger aiAttr
	Dim As String aiEntry = Dir(aiRoot & WindowsSlash & "*", fbDirectory Or fbReadOnly Or fbHidden Or fbSystem Or fbArchive, aiAttr)
	Do While aiEntry <> ""
		If (aiAttr And fbDirectory) <> 0 AndAlso aiEntry <> "." AndAlso aiEntry <> ".." Then cboAITool.AddItem aiEntry
		aiEntry = Dir(aiAttr)
	Loop
	EPD_EnsureItem(cboAITool, d.AITool)
	cboAITool.ItemIndex = Max(0, cboAITool.IndexOf(d.AITool))
	chkAIFriendly.Checked = d.AIFriendly
	cboAITool.Enabled = d.AIFriendly
	oldAIFriendly = d.AIFriendly
	oldAITool = d.AITool
End Sub

Private Sub frmEditProjectDescription.chkAI_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	(*Cast(frmEditProjectDescription Ptr, Sender.Designer)).chkAI_Click(Sender)
End Sub
Private Sub frmEditProjectDescription.chkAI_Click(ByRef Sender As CheckBox)
	cboAITool.Enabled = chkAIFriendly.Checked
End Sub

Private Sub frmEditProjectDescription.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmEditProjectDescription Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmEditProjectDescription.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmEditProjectDescription.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmEditProjectDescription Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmEditProjectDescription.cmdOK_Click(ByRef Sender As Control)
	'' Reload to preserve the read-only fields, then overwrite the editable ones.
	Dim As ProjectDescriptionData d
	ReadProjectDescription(ProjectFolder, d)
	d.Author      = Trim(txtAuthor.Text)
	d.License     = Trim(cboLicense.Text)
	d.Description = txtDescription.Text
	d.AIFriendly  = chkAIFriendly.Checked
	d.AITool      = Trim(cboAITool.Text)
	WriteProjectDescription(ProjectFolder, d)
	If VfpPath <> "" Then UpdateVfpMetadataKeys(VfpPath, d)
	'' Stamp the AI template when AI-friendliness is newly enabled or the tool changed.
	If d.AIFriendly AndAlso Trim(d.AITool) <> "" AndAlso ((Not oldAIFriendly) OrElse d.AITool <> oldAITool) Then
		Dim As String au = d.Author, li = d.License, de = d.Description, pn = d.ProjectName
		StampAiTemplateInto(ProjectFolder, d.AITool, pn, au, li, de)
	End If
	ModalResult = ModalResults.OK
	Me.CloseForm
End Sub
