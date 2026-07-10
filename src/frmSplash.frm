'#########################################################
'#  frmSplash.bas                                        #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (2018-2020)              #
'#########################################################

#include once "frmSplash.bi"
#include once "mff/Application.bi"

Using My.Sys.Forms

'#Region "Form"
	Constructor frmSplash
		This.Text = "Astoria IDE"
		This.Icon = "AstoriaIDE"
		This.Cursor = crWait
		This.BackColor = 0
		This.SetBounds 0, 0, 412, 412
		This.BorderStyle = FormBorderStyle.None
		This.StartPosition = FormStartPosition.CenterParent
		' lblImage
		lblImage.Name = "lblImage"
		'lblImage.Graphic.Bitmap.LoadFromResourceName("Logo")
		lblImage.Graphic = "Logo"
		lblImage.SetBounds 36, 76, 343, 270
		lblImage.CenterImage = True
		lblImage.Designer = @This
		lblImage.OnClick = @lblImage_Click_
		lblImage.BackColor = 0
		lblImage.Parent = @This
		' lblSplash
		lblSplash.SetBounds 8, 14, 398, 33
		lblSplash.Text = "Astoria IDE" & " " & pApp->GetVerInfo("ProductVersion")
			lblSplash.Font.Name = "Times New Roman"
		lblSplash.Font.Size = 20
		lblSplash.Font.Bold = True
		lblSplash.Font.Italic = True
		lblSplash.Alignment = AlignmentConstants.taCenter
		lblSplash.BackColor = 0
		lblSplash.Font.Color = 16777215
		lblSplash.Align = DockStyle.alNone
		lblSplash.ID = 1004
		lblSplash.Parent = @This
		lblSplash.Alignment = AlignmentConstants.taCenter
		
		'lblIcon.Graphic.Icon = 100
		' lblInfo
		lblInfo.Name = "lblInfo"
		lblInfo.Text = "2018-2026"
		lblInfo.SetBounds 18, 348, 52, 17
		lblInfo.BackColor = 0
		lblInfo.Font.Color = 16777215
		lblInfo.Font.Size = 8
		lblInfo.Parent = @This
		' lblProcess
		With lblProcess
			.Name = "lblProcess"
			.Text = ""
			.SetBounds 18, 366, 380, 30
			.BackColor = 0
			.Font.Color = 16777215
			.Font.Size = 8
			.Parent = @This
		End With
		' lblSplash1
		With lblSplash1
			.Name = "lblSplash1"
			.Text = ("64-bit")
			.TabIndex = 3
			.Alignment = AlignmentConstants.taCenter
			.BackColor = 0
			.Font.Size = 12
			.Font.Bold = True
				.Font.Name = "Times New Roman"
			.Font.Color = 16777215
			.SetBounds 16, 54, 382, 17
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared fSplash As frmSplash
	pfSplash = @fSplash
'#End Region

Private Sub frmSplash.lblImage_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmSplash Ptr, Sender.Designer)).lblImage_Click(Sender)
End Sub
Private Sub frmSplash.lblImage_Click(ByRef Sender As Control)
	Me.CloseForm
End Sub
 

