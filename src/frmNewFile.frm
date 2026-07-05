	'#Compile -exx "Form1.rc"
'#Region "Form"
	#include once "frmNewFile.bi"
	
	Constructor frmNewFile
		With This
			.Name = "frmNewFile"
			.Text = ML("New File")
				.Icon.LoadFromResourceID(1)
			.Designer = @This
			.BorderStyle = FormBorderStyle.Sizable
			.OnCreate = @Form_Create_
			.SetBounds 0, 0, 657, 400
			.StartPosition = FormStartPosition.CenterParent
		End With
		' pnlBottom
		With pnlBottom
			.Name = "pnlBottom"
			.Text = ""
			.Align = DockStyle.alBottom
			.TabIndex = 3
			.SetBounds 0, 331, 641, 30
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
			.TabIndex = 2
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
			.TabIndex = 1
			.SetBounds 430, 0, 88, 20
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
			.TabIndex = 0
			.SetBounds 10, 32, 621, 289
			.Designer = @This
			.Columns.Add ML("Template"), , 500, cfLeft
			.OnItemActivate = @lvTemplates_ItemActivate_
			.Parent = @This
		End With
		' lblFileTemplates
		With lblFileTemplates
			.Name = "lblFileTemplates"
			.Text = ML("File Templates")
			.TabIndex = 4
			.SetBounds 10, 10, 300, 18
			.Parent = @This
		End With
	End Constructor

'#End Region

Private Sub frmNewFile.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewFile Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmNewFile.cmdOK_Click(ByRef Sender As Control)
	SelectedTemplate = ""
	If lvTemplates.SelectedItemIndex = -1 Then
		MsgBox ML("Select template!")
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

Private Sub frmNewFile.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewFile Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmNewFile.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	SelectedTemplate = ""
	lvTemplates.ListItems.Clear
	TemplateFiles.Clear
	Dim As String f, TemplateName, IconName
	f = Dir(ExePath & "/Templates/Files/*")
	While f <> ""
		If Not EndsWith(LCase(f), ".vfp") AndAlso LCase(f) <> "temp.bas" Then
			TemplateName = ..Left(f, IfNegative(InStr(f, ".") - 1, Len(f)))
			If EndsWith(LCase(f), ".frm") Then
				IconName = IIf(InStr(TemplateName, "3D") > 0, "Form3D32", "Form32")
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
			lvTemplates.ListItems.Add ML(TemplateName), IconName
			TemplateFiles.Add f
		End If
		f = Dir()
	Wend
End Sub
