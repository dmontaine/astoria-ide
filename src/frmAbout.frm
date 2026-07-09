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
		This.SetBounds 0, 0, 496, 548
		This.BorderStyle = FormBorderStyle.FixedDialog
		This.MaximizeBox = False
		This.MinimizeBox = False
		This.StartPosition = FormStartPosition.CenterParent
			This.DefaultButton = @CommandButton1
			This.Designer = @This
			This.CancelButton = @CommandButton1
		Label1.Name = "Label1"
		Label1.Font.Name = "Times New Roman"
		Label1.Font.Bold = True
		Label1.Font.Size = 18
		Label1.Text = "Visual FB Editor"
		Label1.SetBounds 21, 7, 438, 54
		Label1.Alignment = AlignmentConstants.taCenter
		Label1.Parent = @This
		CommandButton1.Name = "CommandButton1"
		CommandButton1.Text = ("&OK")
		CommandButton1.SetBounds 388, 482, 92, 26
		CommandButton1.OnClick = @CommandButton1_Click
			CommandButton1.Default = True 
		CommandButton1.Parent = @This
		' Label2
		Label2.Name = "Label2"
		Label2.Text = ("Authors") & !":\r" & _
		!"Xusinboy Bekchanov\r" & _
		("e-mail") & !": <a href=""mailto:bxusinboy@mail.ru"">bxusinboy@mail.ru</a>\r" & _
		!"Liu XiaLin\r" & _
		("e-mail") & !": <a href=""mailto:liuziqi.hk@hotmail.com"">liuziqi.hk@hotmail.com</a>\r" & _
		!"Cm Wang\r" & _
		("e-mail") & !": <a href=""mailto:cm.wang@126.com"">cm.wang@126.com</a>\r\r" & _
		("QQ Forums") & !" 1032313876 78458582 \r\r" & _
		("For donation") & !":\r Patreon: <a href=""https://www.patreon.com/xusinboy"">patreon.com/xusinboy</a>,\r WebMoney: <a href=""https://www.webmoney.ru""> WMZ: Z884195021874</a>\r\r\r" & _
		MS("Thanks to $1 for codes of $2 and $3", "Nastase Eodor", "FreeBasic Windows GUI ToolKit", "Simple Designer") & !"\r" & _
		MS("Thanks to $1 for codes of $2 and $3", "Stanislav Budinov", "GUI Library Window9", "FrontEnd GDB for freebasic") & !"\r" & _
		MS("Thanks to $1 for codes of $2", "Aloberoger", "GUITK-S Windows GUI FB Wrapper Library") & !"\r" & _
		MS("Thanks to $1 for codes of $2", "Leandro Ascierto", ("Chart control")) & !"\r" & _
		MS("Thanks to $1 for codes of $2", "Laurent GRAS", "FBDebugger") & !"\r" & _
		MS("Thanks to $1 for codes of $2", "Paul Squires", "WinFormsX") & !"\r" & _
		MS("Thanks to $1 for codes of $2", "José Roca", "Afx") & !"\r\r" & _
		("Language files by") & !":\r" & _
		!"Xusinboy Bekchanov (Russian, Uzbekcyril, Uzbeklatin)\r" & _
		!"Liu XiaLin (Chinese)\r" & _
		!"Thomas Frank Ludewig (Deutsch)\r" & _
		!"Juan Sánchez (Spanish)\r" & _
		!"Dariusz Prochotta (Polish)\r" & _
		!"Xonic (French)\r" & _
		!"Massimiliano Argenti (Italian)"
		Label2.BorderStyle = BorderStyles.bsNone
		Label2.SetBounds 10, 58, 472, 413
		Label2.Parent = @This
		' lblIcon
		lblIcon.Name = "lblIcon"
		lblIcon.Text = "lblIcon"
		'lblIcon.RealSizeImage = false
			lblIcon.Graphic.Icon.LoadFromResourceID(1, , 48, 48)
		lblIcon.SetBounds 28, 0, 48, 48
		lblIcon.Parent = @This
		' lblImage
		With lblImage
			.Name = "lblImage"
			.Text = "lblImage"
			.SetBounds 298, 66, 170, 170
				.Graphic = "weChat"
			.Parent = @This
		End With
		' Label11
		Label11.Name = "Label11"
		Label11.Text = ("Version")
		Label11.SetBounds 80, 40, 200, 18
		Label11.Parent = @This
	End Constructor

	Dim Shared As frmAbout fAbout
	pfAbout = @fAbout
'#End Region

Private Sub frmAbout.CommandButton1_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Cast(frmAbout Ptr, Sender.Parent)->CloseForm
End Sub


