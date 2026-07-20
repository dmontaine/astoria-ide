'#########################################################
'#  frmTheme.bi                                          #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmTheme.bi"

'#Region "Form"
	Constructor frmTheme
		' frmTheme
		This.Name = "frmTheme"
		This.Text = ("New Theme")
			This.Icon.LoadFromResourceID(1)
		This.StartPosition = FormStartPosition.CenterParent
		This.SetBounds 0, 0, 310, 156
		' lblThemeName
		lblThemeName.Name = "lblThemeName"
		lblThemeName.Text = ("Theme name") & ":"
		lblThemeName.SetBounds 16, 16, 104, 16
		lblThemeName.Parent = @This
		' txtThemeName
		txtThemeName.Name = "txtThemeName"
		txtThemeName.Text = ""
		txtThemeName.SetBounds 16, 40, 264, 18
		txtThemeName.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ("OK")
		cmdOK.SetBounds 16, 80, 80, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ("Cancel")
		cmdCancel.SetBounds 200, 80, 80, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
	End Constructor
	
	Dim Shared fTheme As frmTheme
	pfTheme = @fTheme
'#End Region


Private Sub frmTheme.cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If fTheme.txtThemeName.Text = "" Then
		MsgBox "Theme name is empty"
		Exit Sub
	End If
	fTheme.ModalResult = ModalResults.OK
	fTheme.CloseForm
End Sub

Private Sub frmTheme.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fTheme.ModalResult = ModalResults.Cancel
	fTheme.CloseForm
End Sub

