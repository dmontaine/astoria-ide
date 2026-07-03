'###############################################################################
'#  GroupBox.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TGroupBox.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "GroupBox.bi"

Namespace My.Sys.Forms
	Property GroupBox.Caption ByRef As WString
		Return Text
	End Property
	
	Property GroupBox.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Property GroupBox.Text ByRef As WString
			Return Base.Text
	End Property
	
	Property GroupBox.Text(ByRef Value As WString)
			Base.Text = Value
	End Property
	
	Property GroupBox.ParentColor As Boolean
		Return FParentColor
	End Property
	
	Property GroupBox.ParentColor(Value As Boolean)
		FParentColor = Value
		If FParentColor Then
			This.BackColor = This.Parent->BackColor
			Invalidate
		End If
	End Property
	
		Sub GroupBox.WndProc(ByRef Message As Message)
			If Message.Sender Then
			End If
		End Sub
	
	Sub GroupBox.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_PAINT
				Dim As Integer W,H
				Dim As HDC Dc,memDC
				Dim As HBITMAP Bmp
				Dim As Rect R
				GetClientRect Handle,@R
				Dc = GetDC(Handle)
				FillRect Dc,@R,This.Brush.Handle
				ReleaseDC Handle, Dc
				Message.Result = 0
			Case WM_COMMAND
				CallWindowProc(@SuperWndProc, GetParent(Handle), Message.Msg, Message.wParam, Message.lParam)
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC, Message.wParam)
				SetBKMode Dc, TRANSPARENT
				SetTextColor Dc, This.Font.Color
				SetBKColor Dc, This.BackColor
				SetBKMode Dc, OPAQUE
			Case CM_COMMAND
				If Message.wParamHi = BN_CLICKED Then
					If OnClick Then OnClick(This)
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Operator GroupBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Constructor GroupBox
		With This
			.Child       = @This
				.RegisterClass "GroupBox", "Button"
				.ChildProc   = @WndProc
			WLet(FClassName, "GroupBox")
			WLet(FClassAncestor, "Button")
			FTabStop           = True
				.ExStyle     = 0 'WS_EX_TRANSPARENT
				.Style       = WS_CHILD Or WS_VISIBLE Or BS_GROUPBOX 'Or SS_NOPREFIX
				.BackColor       = GetSysColor(COLOR_BTNFACE)
			.Width       = 121
			.Height      = 51
		End With
	End Constructor
	
	Destructor GroupBox
	End Destructor
End Namespace

