	'#Compile -exx "Form1.rc"
'#Region "Form"
	#include once "frmNewFile.bi"
	
	Constructor frmNewFile
		With This
			.Name = "frmNewFile"
			.Text = ("New File")
				.Icon.LoadFromResourceID(1)
			.Designer = @This
			.BorderStyle = FormBorderStyle.FixedDialog
			.MaximizeBox = False
			.MinimizeBox = False
			.OnCreate = @Form_Create_
			.SetBounds 0, 0, 657, 400
			.StartPosition = FormStartPosition.CenterParent
		End With
		' pnlBottom — footer (file name row + OK/Cancel), same layout as New Project
		With pnlBottom
			.Name = "pnlBottom"
			.Text = ""
			.Align = DockStyle.alBottom
			.TabIndex = 6
			.SetBounds 0, 0, 641, 68
			.Parent = @This
		End With
		' pnlFileName — top row inside footer
		With pnlFileName
			.Name = "pnlFileName"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 5
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
			.TabIndex = 4
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
			.TabIndex = 3
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
			.TabIndex = 8
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
			.TabIndex = 7
			.SetBounds 430, 36, 88, 20
			.Default = True
			.Designer = @This
			.OnClick = @cmdOK_Click_
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
			.TabIndex = 2
			.SetBounds 10, 32, 621, 303
			.Designer = @This
			.Columns.Add ("Template"), , 500, cfLeft
			.OnItemActivate = @lvTemplates_ItemActivate_
			.OnItemClick = @lvTemplates_ItemClick_
			.Parent = @This
		End With
		' lblFileTemplates
		With lblFileTemplates
			.Name = "lblFileTemplates"
			.Text = ("File Templates")
			.TabIndex = 0
			.SetBounds 10, 10, 300, 18
			.Parent = @This
		End With
	End Constructor

'#End Region

Private Sub frmNewFile.UpdateNamePrompt()
	If lvTemplates.SelectedItemIndex = -1 Then
		lblName.Text = ("Name") & ":"
	Else
		Dim As String sTemplateFile = TemplateFiles.Item(lvTemplates.SelectedItemIndex)
		Dim dotPos As Integer = InStr(sTemplateFile, ".")
		Dim As String sTemplateLabel = sTemplateFile
		If dotPos > 0 Then sTemplateLabel = ..Left(sTemplateFile, dotPos - 1)
		lblName.Text = ("New") & " " & (sTemplateLabel) & " " & ("Name") & ":"
	End If
End Sub

Private Sub frmNewFile.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewFile Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmNewFile.cmdOK_Click(ByRef Sender As Control)
	SelectedTemplate = ""
	SelectedName = ""
	If lvTemplates.SelectedItemIndex = -1 Then
		MsgBox ("Select template!")
		Me.BringToFront
		Exit Sub
	End If
	SelectedName = Trim(txtName.Text, Any !" \t" + Chr(10) + Chr(13))
	If SelectedName = "" Then
		MsgBox ("Enter a name.")
		txtName.SetFocus
		Me.BringToFront
		Exit Sub
	End If
	If Not IsValidProjectItemName(SelectedName) Then
		MsgBox ("Enter a valid name without paths or file extensions."), , mtWarning
		txtName.SetFocus
		Me.BringToFront
		Exit Sub
	End If
	SelectedTemplate = ExePath & "/Templates/Files/" & TemplateFiles.Item(lvTemplates.SelectedItemIndex)
	ModalResult = ModalResults.OK
	Me.CloseForm
End Sub

Private Sub frmNewFile.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewFile Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmNewFile.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmNewFile.lvTemplates_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmNewFile Ptr, Sender.Designer)).lvTemplates_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmNewFile.lvTemplates_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdOK_Click cmdOK
End Sub

Private Sub frmNewFile.lvTemplates_ItemClick_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmNewFile Ptr, Sender.Designer)).lvTemplates_ItemClick(Sender, ItemIndex)
End Sub
Private Sub frmNewFile.lvTemplates_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	UpdateNamePrompt()
End Sub

Private Sub frmNewFile.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewFile Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmNewFile.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	SelectedTemplate = ""
	SelectedName = ""
	txtName.Text = ""
	lvTemplates.ListItems.Clear
	TemplateFiles.Clear
	Dim As String f, sTemplateLabel, IconName
	f = Dir(ExePath & "/Templates/Files/*")
	While f <> ""
		If Not EndsWith(LCase(f), ".vfp") AndAlso LCase(f) <> "temp.bas" AndAlso LCase(f) <> "form_3d.frm" Then
			Dim dotPos As Integer = InStr(f, ".")
			sTemplateLabel = f
			If dotPos > 0 Then sTemplateLabel = ..Left(f, dotPos - 1)
			If EndsWith(LCase(f), ".frm") Then
				IconName = "Form32"
			ElseIf f = "User Control.bas" Then
				IconName = "UserControl32"
			ElseIf EndsWith(LCase(f), ".bas") Then
				IconName = "Module32"
			ElseIf EndsWith(LCase(f), ".rc") Then
				IconName = "Resource32"
			ElseIf EndsWith(LCase(f), ".xml") Then
				IconName = "Manifest32"
			Else
				IconName = "File32"
			End If
			If imgList32.IndexOf(IconName) < 0 Then IconName = "File32"
			lvTemplates.ListItems.Add (sTemplateLabel), IconName
			TemplateFiles.Add f
		End If
		f = Dir()
	Wend
	If lvTemplates.ListItems.Count > 0 Then
		lvTemplates.SelectedItemIndex = 0
		UpdateNamePrompt()
	End If
	txtName.SetFocus
End Sub
