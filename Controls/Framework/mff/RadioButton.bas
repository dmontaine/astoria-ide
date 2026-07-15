'###############################################################################
'#  RadioButton.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TRadioButton.bi                                                           #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "RadioButton.bi"
	#include once "win\tmschema.bi"

Namespace My.Sys.Forms
		Private Function RadioButton.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "caption": Return Cast(Any Ptr, This.FText.vptr)
			Case "checked": Return @FChecked
			Case "tabindex": Return @FTabIndex
			Case "text": Return Cast(Any Ptr, This.FText.vptr)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function RadioButton.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "alignment": Alignment = *Cast(CheckAlignmentConstants Ptr, Value)
			Case "caption": If Value <> 0 Then This.Caption = *Cast(WString Ptr, Value)
			Case "checked": Checked = QBoolean(Value)
			Case "tabindex": If Value <> 0 Then TabIndex = QInteger(Value)
			Case "text": If Value <> 0 Then This.Text = *Cast(WString Ptr, Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property RadioButton.Alignment As CheckAlignmentConstants
		Return FAlignment
	End Property
	
	Private Property RadioButton.Alignment(Value As CheckAlignmentConstants)
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
	
	Private Property RadioButton.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property RadioButton.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property RadioButton.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property RadioButton.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property RadioButton.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property RadioButton.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property RadioButton.Parent As Control Ptr
		Return Base.Parent
	End Property
	
	Private Property RadioButton.Parent(Value As Control Ptr)
		Base.Parent = Value
	End Property
	Private Property RadioButton.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property RadioButton.Text(ByRef Value As WString)
		Base.Text = Value
	End Property
	
	Private Property RadioButton.Checked As Boolean
		If FHandle Then
				FChecked = Perform(BM_GETCHECK, 0, 0)
		End If
		Return FChecked
	End Property
	
	Private Property RadioButton.Checked(Value As Boolean)
		FChecked = Value
		If FHandle Then
				Perform(BM_SETCHECK, FChecked, 0)
				If FChecked Then
					If FParent Then
						For i As Integer = 0 To This.Parent->ControlCount - 1
							If This.Parent->Controls[i]->ClassName = "RadioButton" Then
								If This.Parent->Controls[i] <> @This Then
									This.Parent->Controls[i]->Perform(BM_SETCHECK, 0, 0)
								End If
							End If
						Next
					End If
				End If
		End If
	End Property
	
	Private Sub RadioButton.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QRadioButton(Sender.Child)
					.Perform(BM_SETCHECK, .FChecked, 0)
				End With
			End If
	End Sub
	
		Private Sub RadioButton.WndProc(ByRef Message As Message)
			If Message.Sender Then
				
			End If
		End Sub
	
	
	Private Sub RadioButton.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC,Message.wParam)
				SetBkMode Dc, TRANSPARENT
				SetTextColor Dc,Font.Color
				SetBkColor Dc,This.BackColor
				SetBkMode Dc,OPAQUE
			Case CM_COMMAND
				If Message.wParamHi = BN_CLICKED Then
					Checked = True
					If OnClick Then OnClick(*Designer, This)
				End If
			Case CM_NOTIFY
				If (FForeColor <> 0) AndAlso Message.lParam <> 0 AndAlso Cast(LPNMHDR, Message.lParam)->code = NM_CUSTOMDRAW Then
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
						Dim As bool bChecked = This.Checked
						
						If (uiItemState And CDIS_DISABLED) Then
							stateID = IIf(bChecked, RBS_CHECKEDDISABLED, RBS_UNCHECKEDDISABLED)
						ElseIf (uiItemState And CDIS_SELECTED) Then
							stateID = IIf(bChecked, RBS_CHECKEDPRESSED, RBS_UNCHECKEDPRESSED)
						Else
							If (uiItemState And CDIS_HOT) Then
								stateID = IIf(bChecked, RBS_CHECKEDHOT, RBS_UNCHECKEDHOT)
							Else
								stateID = IIf(bChecked, RBS_CHECKEDNORMAL, RBS_UNCHECKEDNORMAL)
							End If
						End If
						
						Dim As ..RECT r
						Dim As ..SIZE s
						
						' Get check box dimensions so we can calculate
						' rectangle dimensions For text
						GetThemePartSize(hTheme, pnm->hdc, BP_RADIOBUTTON, stateID, NULL, TS_TRUE, @s)
						
						r.left = pnm->rc.left
						r.top = pnm->rc.top ' + 2
						r.right = pnm->rc.Left + s.cx
						r.bottom = pnm->rc.Bottom ' r.top + s.cy
						
						DrawThemeBackground(hTheme, pnm->hdc, BP_RADIOBUTTON, stateID, @r, NULL)
						
						' adjust rectangle for text drawing
						'pnm->rc.top += r.top - 2
						pnm->rc.Left += 3 + s.cx
						
						SelectObject(pnm->hdc, Font.Handle)
						If (uiItemState And CDIS_DISABLED) Then
							SetTextColor(pnm->hdc, &H626262)
						End If
						DrawText(pnm->hdc, This.Text, -1, @pnm->rc, DT_SINGLELINE Or DT_VCENTER)
						If (uiItemState And CDIS_FOCUS) Then
							Dim Sz As ..Size
							GetTextExtentPoint32(pnm->hdc, @This.Text, Len(This.Text), @Sz)
							pnm->rc.Left -= 1
							pnm->rc.Top = (pnm->rc.Bottom - r.top - (s.cy + 2)) / 2
							pnm->rc.Right = pnm->rc.Left + Sz.cx + 2
							pnm->rc.Bottom = pnm->rc.Top + s.cy + 2
							DrawFocusRect(pnm->hdc, @pnm->rc)
						End If
						CloseThemeData(hTheme)
						Message.Result = Cast(LONG_PTR, CDRF_SKIPDEFAULT)
						Return
					End Select
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator RadioButton.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	
	Private Constructor RadioButton
		With This
			.Child       = @This
				.RegisterClass "RadioButton","Button"
				.ChildProc   = @WndProc
				.ExStyle     = 0
				.Style       = WS_CHILD Or BS_AUTORADIOBUTTON
				.BackColor       = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
				.DoubleBuffered = True
				WLet(FClassAncestor, "Button")
			.OnHandleIsAllocated = @HandleIsAllocated
			FTabIndex          = -1
			FTabStop = True
			WLet(FClassName, "RadioButton")
			.Width       = 90
			.Height      = 17
		End With
	End Constructor
	
	Private Destructor RadioButton
	End Destructor
End Namespace

