'################################################################################
'#  CheckBox.bas                                                                #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TCheckBox.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Updated and added cross-platform                                            #
'#  by Xusinboy Bekchanov (2018-2019), Liu XiaLin                               #
'################################################################################

#include once "CheckBox.bi"
	#include once "win\tmschema.bi"

Namespace My.Sys.Forms
		Private Function CheckBox.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "autosize": Return @FAutoSize
			Case "caption": Return FText.vptr
			Case "text": Return FText.vptr
			Case "checked": Return @FChecked
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function CheckBox.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "alignment": Alignment = *Cast(CheckAlignmentConstants Ptr, Value)
			Case "autosize": AutoSize = QBoolean(Value)
			Case "caption": This.Caption = QWString(Value)
			Case "text": This.Text = QWString(Value)
			Case "checked": Checked = QBoolean(Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property CheckBox.Alignment As CheckAlignmentConstants
		Return FAlignment
	End Property
	
	Private Property CheckBox.Alignment(Value As CheckAlignmentConstants)
		If Value <> FAlignment Then
			FAlignment = Value
				ChangeStyle BS_LEFT, False
				ChangeStyle BS_RIGHTBUTTON, False
				Select Case Value
				Case chLeft: ChangeStyle BS_LEFT, True
				Case chRight: ChangeStyle BS_RIGHTBUTTON, True
				End Select
				RecreateWnd
		End If
	End Property
	
	Private Property CheckBox.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property CheckBox.AutoSize(Value As Boolean)
		FAutoSize = Value
			If FHandle Then
				Width = 1
			End If
	End Property
	
	Private Property CheckBox.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property CheckBox.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property CheckBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property CheckBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property CheckBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property CheckBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property CheckBox.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property CheckBox.Text(ByRef Value As WString)
		Base.Text = Value
			If FAutoSize Then AutoSize = True
	End Property
	
	Private Property CheckBox.Checked As Boolean
		If FHandle Then
				FChecked = Perform(BM_GETCHECK, 0, 0)
		End If
		Return FChecked
	End Property
	
	Private Property CheckBox.Checked(Value As Boolean)
		FChecked = Value
		If FHandle Then
				Perform(BM_SETCHECK, FChecked, 0)
		End If
	End Property
	
	Private Sub CheckBox.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QCheckBox(Sender.Child)
					.Perform(BM_SETCHECK, .FChecked, 0)
				End With
			End If
	End Sub
	
		Private Sub CheckBox.WndProc(ByRef Message As Message)
			'        If Message.Sender Then
			'            If Cast(TControl Ptr,Message.Sender)->Child Then
			'               Cast(CheckBox Ptr,Cast(TControl Ptr,Message.Sender)->Child)->ProcessMessage(Message)
			'            End If
			'        End If
		End Sub
	
	
	Private Sub CheckBox.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC, Message.wParam)
				SetBkMode Dc, TRANSPARENT
				SetTextColor Dc, Font.Color
				SetBkColor Dc, This.BackColor
				SetBkMode Dc, OPAQUE
			Case CM_COMMAND
				If Message.wParamHi = BN_CLICKED Then
					If Checked = 0 Then
						Checked = 1
					Else
						Checked = 0
					End If
					If OnClick Then OnClick(*Designer, This)
				End If
			Case WM_WINDOWPOSCHANGING
				If FAutoSize Then
					Dim As ..Size Size_
					SendMessage(FHandle, BCM_GETIDEALSIZE, 0, Cast(LPARAM, @Size_))
					With *Cast(WINDOWPOS Ptr, Message.lParam)
						.cx = Size_.cx
						.cy = Size_.cy
					End With
				End If
			Case CM_NOTIFY
				If (g_darkModeSupported AndAlso g_darkModeEnabled OrElse FForeColor <> 0) AndAlso Cast(LPNMHDR, Message.lParam)->code = NM_CUSTOMDRAW Then
					Dim As NMCUSTOMDRAW Ptr pnm = Cast(LPNMCUSTOMDRAW, Message.lParam)
					Select Case pnm->dwDrawStage
					Case CDDS_PREERASE
						Dim As HRESULT hr = DrawThemeParentBackground(pnm->hdr.hwndFrom, pnm->hdc, @pnm->rc)
						If FAILED(hr) Then ' If failed draw without theme
							SetWindowLongPtr(Message.hWnd, DWLP_MSGRESULT, Cast(LONG_PTR, CDRF_DODEFAULT))
							Message.Result = True
							Return
						End If
						
						Dim As HTHEME hTheme = OpenThemeData(pnm->hdr.hwndFrom, "BUTTON")
						
						If hTheme = 0 Then ' If failed draw without theme
							CloseThemeData(hTheme)
							SetWindowLongPtr(Message.hWnd, DWLP_MSGRESULT, Cast(LONG_PTR, CDRF_DODEFAULT))
							Message.Result = True
							Return
						End If
						
						Dim As LRESULT state = SendMessage(pnm->hdr.hwndFrom, BM_GETSTATE, 0, 0)
						
						Dim As Integer stateID ' parameter for DrawThemeBackground
						
						Dim As UINT uiItemState = pnm->uItemState
						Dim As BOOL bChecked = This.Checked
						
						If (uiItemState And CDIS_DISABLED) Then
							stateID = IIf(bChecked, CBS_CHECKEDDISABLED, CBS_UNCHECKEDDISABLED)
						ElseIf (uiItemState And CDIS_SELECTED) Then
							stateID = IIf(bChecked, CBS_CHECKEDPRESSED, CBS_UNCHECKEDPRESSED)
						Else
							If (uiItemState And CDIS_HOT) Then
								stateID = IIf(bChecked, CBS_CHECKEDHOT, CBS_UNCHECKEDHOT)
							Else
								stateID = IIf(bChecked, CBS_CHECKEDNORMAL, CBS_UNCHECKEDNORMAL)
							End If
						End If
						
						Dim As ..Rect r
						Dim As ..Size s
						
						' Get check box dimensions so we can calculate
						' rectangle dimensions For text
						GetThemePartSize(hTheme, pnm->hdc, BP_CHECKBOX, stateID, NULL, TS_TRUE, @s)
						
						r.Left = pnm->rc.Left
						r.Top = pnm->rc.Top ' + 2
						r.Right = pnm->rc.Left + s.cx
						r.Bottom = pnm->rc.Bottom ' r.top + s.cy
						
						DrawThemeBackground(hTheme, pnm->hdc, BP_CHECKBOX, stateID, @r, NULL)
						
						' adjust rectangle for text drawing
						'pnm->rc.top += r.top - 2
						pnm->rc.Left += 3 + s.cx
						If (uiItemState And CDIS_DISABLED) Then
							SetTextColor(pnm->hdc, darkHlBkColor)
						End If
						Dim As HFONT OldFontHandle, NewFontHandle
						OldFontHandle = SelectObject(pnm->hdc, This.Font.Handle)
						DrawText(pnm->hdc, This.Text, -1, @pnm->rc, DT_SINGLELINE Or DT_VCENTER)
						If (uiItemState And CDIS_FOCUS) Then
							Dim Sz As ..Size
							GetTextExtentPoint32(pnm->hdc, @This.Text, Len(This.Text), @Sz)
							pnm->rc.Left -= 1
							pnm->rc.Top = (pnm->rc.Bottom - r.Top - (s.cy + 2)) / 2
							pnm->rc.Right = pnm->rc.Left + Sz.cx + 2
							pnm->rc.Bottom = pnm->rc.Top + s.cy + 2
							DrawFocusRect(pnm->hdc, @pnm->rc)
						End If
						NewFontHandle = SelectObject(pnm->hdc, OldFontHandle)
						CloseThemeData(hTheme)
						Message.Result = Cast(LONG_PTR, CDRF_SKIPDEFAULT)
						Return
					End Select
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator CheckBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	
	Private Constructor CheckBox
		With This
			.Child                  = @This
				.RegisterClass "CheckBox", "Button"
				WLet(FClassAncestor, "Button")
				.ChildProc              = @WndProc
			WLet(FClassName, "CheckBox")
			FTabIndex = -1
			FTabStop = True
				.ExStyle                = 0
				.Style                  = WS_CHILD Or BS_CHECKBOX
				.BackColor                  = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
			.OnHandleIsAllocated    = @HandleIsAllocated
			.Width                  = 90
			.Height                 = 17
			.FTabIndex              = -1
			.FTabStop               = True
		End With
	End Constructor
	
	Private Destructor CheckBox
	End Destructor
End Namespace

