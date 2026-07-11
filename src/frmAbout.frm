'#########################################################
'#  frmAbout.bi                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmAbout.bi"

'#Region "Form"
	Constructor frmAbout

		This.Name = "frmAbout"
		This.Text = ("About")
		This.SetBounds 0, -45, 496, 575
		This.BorderStyle = FormBorderStyle.FixedDialog
		This.MaximizeBox = False
		This.MinimizeBox = False
		This.Designer = @This
		This.OnClick = @Form_Click
		This.StartPosition = FormStartPosition.CenterParent
		' Label1
		With Label1
			.Name = "Label1"
			.Text = "Astoria IDE"
			.TabIndex = 0
			.Caption = "Astoria IDE"
			.Font.Name = "Century Gothic"
			.Font.Size = 24
			.Font.Bold = True
			.Font.Italic = True
			.CenterImage = False
			.ID = 1017
			.Alignment = AlignmentConstants.taCenter
			.Transparent = False
			.SetBounds 7, 13, 475, 35
			.Designer = @This
			.Parent = @This
		End With
		' Label2
		With Label2
			.Name = "Label2"
			.Text = "For Free Basic on 64 bit Windows"
			.TabIndex = 1
			.Caption = "For Free Basic on 64 bit Windows"
			.Font.Name = "Tahoma"
			.Font.Size = 16
			.Align = DockStyle.alNone
			.Alignment = AlignmentConstants.taCenter
			.ID = 1016
			.SetBounds 5, 50, 481, 32
			.Designer = @This
			.Parent = @This
		End With
		' Label3
		With Label3
			.Name = "Label3"
			.Text = "Version 1.0"
			.TabIndex = 2
			.Caption = "Version 1.0"
			.Font.Size = 14
			.Alignment = AlignmentConstants.taCenter
			.ID = 1015
			.Transparent = False
			.SetBounds 5, 80, 485, 25
			.Designer = @This
			.Parent = @This
		End With
		' Label31
		With Label31
			.Name = "Label31"
			.Text = "Human Project Manager:  Donald Montaine"
			.TabIndex = 3
			.ControlIndex = 2
			.Caption = "Human Project Manager:  Donald Montaine"
			.Font.Size = 12
			.Alignment = AlignmentConstants.taCenter
			.ID = 1014
			.SetBounds 5, 355, 485, 25
			.Designer = @This
			.Parent = @This
		End With
		' Label311
		With Label311
			.Name = "Label311"
			.Text = "AI Lead Programmer: Claude Sonnet 5"
			.TabIndex = 4
			.ControlIndex = 2
			.Caption = "AI Lead Programmer: Claude Sonnet 5"
			.Font.Size = 12
			.Alignment = AlignmentConstants.taCenter
			.ID = 1013
			.SetBounds 5, 380, 485, 25
			.Designer = @This
			.Parent = @This
		End With
		' Label3111
		With Label3111
			.Name = "Label3111"
			.Text = "AI Lead Analyst and QC: Claude Opus 4.8"
			.TabIndex = 5
			.ControlIndex = 2
			.Caption = "AI Lead Analyst and QC: Claude Opus 4.8"
			.Font.Size = 12
			.Alignment = AlignmentConstants.taCenter
			.ID = 1012
			.SetBounds 5, 405, 485, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label31111
		With Label31111
			.Name = "Label31111"
			.Text = "Other Contributors: Cursor AI Agent, Kun Ai Aigent, Deepseek 4.5 Pro AI"
			.TabIndex = 6
			.ControlIndex = 2
			.Font.Size = 10
			.Caption = "Other Contributors: Cursor AI Agent, Kun Ai Aigent, Deepseek 4.5 Pro AI"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1011
			.SetBounds 5, 440, 485, 20
			.Designer = @This
			.Parent = @This
		End With
		' Label311111
		With Label311111
			.Name = "Label311111"
			.Text = "Based on:  VisualFBEditor (https://github.com/XusinboyBekchanov/VisualFBEditor)"
			.TabIndex = 7
			.ControlIndex = 2
			.Caption = "Based on:  VisualFBEditor (https://github.com/XusinboyBekchanov/VisualFBEditor)"
			.Alignment = AlignmentConstants.taCenter
			.ID = 1010
			.Font.Size = 9
			.SetBounds 5, 465, 485, 15
			.Designer = @This
			.Parent = @This
		End With
		' Label3111111
		With Label3111111
			.Name = "Label3111111"
			.Text = "License: GPL version 3.0 or later"
			.TabIndex = 8
			.Alignment = AlignmentConstants.taCenter
			.ControlIndex = 2
			.Caption = "License: GPL version 3.0 or later"
			.SetBounds 5, 490, 485, 15
			.Designer = @This
			.Parent = @This
		End With
		' lblImage
		With lblImage
			.Name = "lblImage"
			.Text = "lblImage"
			.BackColor = 0
			.ControlIndex = 0
			.Graphic = "Logo"
			.SetBounds 111, 116, 278, 220
			.Designer = @This
			.Parent = @This
		End With
		' BtnClose
		With BtnClose
			.Name = "BtnClose"
			.Text = "CommandButton1"
			.TabIndex = 9
			.SetBounds 205, 515, 85, 25
			.Designer = @This
			.OnClick = @BtnClose_Click_
			.Parent = @This
		End With
	End Constructor

	Dim Shared As frmAbout fAbout
	pfAbout = @fAbout
'#End Region




Private Sub frmAbout.Form_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fAbout.CloseForm
End Sub

Private Sub frmAbout.BtnClose_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmAbout Ptr, Sender.Designer)).BtnClose_Click(Sender)
End Sub

Private Sub frmAbout.BtnClose_Click(ByRef Sender As Control)
	Me.CloseForm
End Sub