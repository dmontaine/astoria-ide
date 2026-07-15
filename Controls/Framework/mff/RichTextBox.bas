'################################################################################
'#  RichTextBox.bi                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                          #
'################################################################################

#include once "RichTextBox.bi"
	#include once "win/richole.bi"

Namespace My.Sys.Forms
		Private Function RichTextBox.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "editstyle": Return @FEditStyle
			Case "selalignment": FSelIntVal = SelAlignment: Return @FSelIntVal
			Case "selbackcolor": FSelIntVal = SelBackColor: Return @FSelIntVal
			Case "selbold": FSelBoolVal = SelBold: Return @FSelBoolVal
			Case "selbullet": FSelBoolVal = SelBullet: Return @FSelBoolVal
			Case "selcharoffset": FSelIntVal = SelCharOffset: Return @FSelIntVal
			Case "selcharset": FSelIntVal = SelCharSet: Return @FSelIntVal
			Case "selcolor": FSelIntVal = SelColor: Return @FSelIntVal
			Case "selfontname": WLet(FSelWStrVal, SelFontName): Return FSelWStrVal
			Case "selfontsize": FSelIntVal = SelFontSize: Return @FSelIntVal
			Case "selindent": FSelIntVal = SelIndent: Return @FSelIntVal
			Case "selitalic": FSelBoolVal = SelItalic: Return @FSelBoolVal
			Case "selprotected": FSelBoolVal = SelProtected: Return @FSelBoolVal
			Case "selrightindent": FSelIntVal = SelRightIndent: Return @FSelIntVal
			Case "selhangingindent": FSelIntVal = SelHangingIndent: Return @FSelIntVal
			Case "seltabcount": FSelIntVal = SelTabCount: Return @FSelIntVal
			Case "selunderline": FSelBoolVal = SelUnderline: Return @FSelBoolVal
			Case "selstrikeout": FSelBoolVal = SelStrikeout: Return @FSelBoolVal
			Case "tabindex": Return @FTabIndex
			Case "textrtf": TextRTF: Return FTextRTF.vptr
			Case "zoom": Return @FZoom
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function RichTextBox.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "editstyle": EditStyle = QBoolean(Value)
				Case "selalignment": SelAlignment = *Cast(AlignmentConstants Ptr, Value)
				Case "selbackcolor": SelBackColor = QInteger(Value)
				Case "selbold": SelBold = QBoolean(Value)
				Case "selbullet": SelBullet = QBoolean(Value)
				Case "selcharoffset": SelCharOffset = QInteger(Value)
				Case "selcharset": SelCharSet = QInteger(Value)
				Case "selcolor": SelColor = QInteger(Value)
				Case "selfontname": SelFontName = QWString(Value)
				Case "selfontsize": SelFontSize = QInteger(Value)
				Case "selindent": SelIndent = QInteger(Value)
				Case "selitalic": SelItalic = QBoolean(Value)
				Case "selprotected": SelProtected = QBoolean(Value)
				Case "selrightindent": SelRightIndent = QInteger(Value)
				Case "selhangingindent": SelHangingIndent = QInteger(Value)
				Case "seltabcount": SelTabCount = QInteger(Value)
				Case "selunderline": SelUnderline = QBoolean(Value)
				Case "selstrikeout": SelStrikeout = QBoolean(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "textrtf": TextRTF = QWString(Value)
				Case "zoom": Zoom = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property RichTextBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property RichTextBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property RichTextBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property RichTextBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Function RichTextBox.GetTextRange(cpMin As Integer, cpMax As Integer) ByRef As WString
		Dim cpMax2 As Integer = cpMax
			Dim txtrange As TEXTRANGE
			If cpMax2 = -1 Then cpMax2 = This.GetTextLength
			FTextRange = _Reallocate(FTextRange, (cpMax - cpMin + 2) * SizeOf(WString))
			txtrange.chrg.cpMin = cpMin
			txtrange.chrg.cpMax = cpMax
			txtrange.lpstrText = FTextRange
			SendMessage(FHandle, EM_GETTEXTRANGE, 0, CInt(@txtrange))
		If FTextRange> 0 Then Return *FTextRange Else Return WStr("")
	End Function
	
	Private Property RichTextBox.SelAlignment As AlignmentConstants
			If FHandle Then
				Pf.dwMask = PFM_ALIGNMENT
				Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
				Return Pf.wAlignment - 1
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelAlignment(Value As AlignmentConstants)
			If FHandle Then
				Pf.dwMask = PFM_ALIGNMENT
				Select Case Value
				Case AlignmentConstants.taLeft
					Pf.wAlignment = PFA_LEFT
				Case AlignmentConstants.taCenter
					Pf.wAlignment = PFA_CENTER
				Case AlignmentConstants.taRight
					Pf.wAlignment = PFA_RIGHT
				End Select
				Perform(EM_SETPARAFORMAT, 0, Cast(LPARAM, @Pf))
			End If
	End Property
	
	Private Property RichTextBox.SelBullet As Boolean
			If FHandle Then
				Pf.dwMask = PFM_NUMBERING
				Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
				Return Pf.wNumbering = PFN_BULLET
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelBullet(Value As Boolean)
			If FHandle Then
				Pf.dwMask = PFM_NUMBERING
				Pf.wNumbering = IIf(Value, PFN_BULLET, 0)
				Perform(EM_SETPARAFORMAT, 0, Cast(LPARAM, @Pf))
			End If
	End Property
	
	Private Property RichTextBox.SelIndent As Integer
			If FHandle Then
				Pf.dwMask = PFM_STARTINDENT
				Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
				Return Pf.dxStartIndent
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelIndent(Value As Integer)
			If FHandle Then
				Pf.dwMask = PFM_STARTINDENT
				Pf.dxStartIndent = Value
				Perform(EM_SETPARAFORMAT, 0, Cast(LPARAM, @Pf))
			End If
	End Property
	
	Private Property RichTextBox.SelRightIndent As Integer
			If FHandle Then
				Pf.dwMask = PFM_RIGHTINDENT
				Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
				Return Pf.dxRightIndent
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelRightIndent(Value As Integer)
			If FHandle Then
				Pf.dwMask = PFM_RIGHTINDENT
				Pf.dxRightIndent = Value
				Perform(EM_SETPARAFORMAT, 0, Cast(LPARAM, @Pf))
			End If
	End Property
	
	Private Property RichTextBox.SelHangingIndent As Integer
			If FHandle Then
				Pf.dwMask = PFM_OFFSET
				Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
				Return Pf.dxOffset
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelHangingIndent(Value As Integer)
			If FHandle Then
				Pf.dwMask = PFM_OFFSET
				Pf.dxOffset = Value
				Perform(EM_SETPARAFORMAT, 0, Cast(LPARAM, @Pf))
			End If
	End Property
	
	Private Property RichTextBox.SelTabCount As Integer
			If FHandle Then
				Pf.dwMask = PFM_TABSTOPS
				Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
				Return Pf.cTabCount
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelTabCount(Value As Integer)
			If FHandle Then
				Pf.dwMask = PFM_TABSTOPS
				Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
				Pf.cTabCount = Value
				Perform(EM_SETPARAFORMAT, 0, Cast(LPARAM, @Pf))
			End If
	End Property
	
	Private Property RichTextBox.SelTabs(sElement As Integer) As Integer
			If FHandle Then
				If sElement >= 0 AndAlso sElement <= 31 Then
					Pf.dwMask = PFM_TABSTOPS
					Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
					Return Pf.rgxTabs(sElement)
				End If
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelTabs(sElement As Integer, Value As Integer)
			If FHandle Then
				If sElement >= 0 AndAlso sElement <= 31 Then
					Pf.dwMask = PFM_TABSTOPS
					Perform(EM_GETPARAFORMAT, 0, Cast(LPARAM, @Pf))
					Pf.rgxTabs(sElement) = Value
					Perform(EM_SETPARAFORMAT, 0, Cast(LPARAM, @Pf))
				End If
			End If
	End Property
	
	Private Property RichTextBox.SelBackColor As Integer
			If FHandle Then
				Cf2.dwMask = CFM_BACKCOLOR
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf2))
				Return BGRToRGBA(Cf2.crBackColor)
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelBackColor(Value As Integer)
			If FHandle Then
				Cf2.dwMask = CFM_BACKCOLOR
				Cf2.dwEffects = 0
				'Cf2.crBackColor = RGBAToBGR(Value)
				Cf2.crBackColor = Value
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf2))
			End If
	End Property
	
	Private Property RichTextBox.SelColor As Integer
			If FHandle Then
				Cf.dwMask = CFM_COLOR
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return BGRToRGBA(Cf.crTextColor)
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelColor(Value As Integer)
			If FHandle Then
				'Dim As CHARFORMAT2 Cf
				'Cf.cbSize = SizeOf(Cf)
				'Cf.dwMask = CFM_COLOR
				'Cf.crTextColor = RGBAToBGR(Value)
				'SendMessage(FHandle, EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				'Cf.cbSize = SizeOf(Cf)
				Cf.dwMask = CFM_COLOR
				Cf.dwEffects = 0
				'Cf.crTextColor = RGBAToBGR(Value)
				Cf.crTextColor = Value
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Property RichTextBox.SelFontName ByRef As WString
			If FHandle Then
				Cf.dwMask = CFM_FACE
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.szFaceName
			End If
		Return Font.Name
	End Property
	
	Private Property RichTextBox.SelFontName(ByRef Value As WString)
			If FHandle Then
				Cf.dwMask = CFM_FACE
				Cf.szFaceName = Value
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Property RichTextBox.SelFontSize As Integer
			If FHandle Then
				Cf.dwMask = CFM_SIZE
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.yHeight
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelFontSize(Value As Integer)
			If FHandle Then
				Cf.dwMask = CFM_SIZE
				Cf.yHeight = Value
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	
	Private Property RichTextBox.SelBold As Boolean
			If FHandle Then
				Cf.dwMask = CFM_BOLD
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.dwEffects And CFE_BOLD
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelBold(Value As Boolean)
			If FHandle Then
				Cf.dwMask = CFM_BOLD
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				If Value Then
					Cf.dwEffects = Cf.dwEffects Or CFE_BOLD
				Else
					Cf.dwEffects = Cf.dwEffects And Not CFE_BOLD
				End If
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Property RichTextBox.SelItalic As Boolean
			If FHandle Then
				Cf.dwMask = CFM_ITALIC
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.dwEffects And CFE_ITALIC
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelItalic(Value As Boolean)
			If FHandle Then
				Cf.dwMask = CFM_ITALIC
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				If Value Then
					Cf.dwEffects = Cf.dwEffects Or CFE_ITALIC
				Else
					Cf.dwEffects = Cf.dwEffects And Not CFE_ITALIC
				End If
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Property RichTextBox.SelUnderline As Boolean
			If FHandle Then
				Cf.dwMask = CFM_UNDERLINE
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.dwEffects And CFE_UNDERLINE
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelUnderline(Value As Boolean)
			If FHandle Then
				Cf.dwMask = CFM_UNDERLINE
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				If Value Then
					Cf.dwEffects = Cf.dwEffects Or CFE_UNDERLINE
				Else
					Cf.dwEffects = Cf.dwEffects And Not CFE_UNDERLINE
				End If
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Property RichTextBox.SelStrikeout As Boolean
			If FHandle Then
				Cf.dwMask = CFM_STRIKEOUT
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.dwEffects And CFE_STRIKEOUT
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelStrikeout(Value As Boolean)
			If FHandle Then
				Cf.dwMask = CFM_STRIKEOUT
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				If Value Then
					Cf.dwEffects = Cf.dwEffects Or CFE_STRIKEOUT
				Else
					Cf.dwEffects = Cf.dwEffects And Not CFE_STRIKEOUT
				End If
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Property RichTextBox.SelProtected As Boolean
			If FHandle Then
				Cf.dwMask = CFM_PROTECTED
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.dwEffects And CFE_PROTECTED
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelProtected(Value As Boolean)
			If FHandle Then
				Cf.dwMask = CFM_PROTECTED
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				If Value Then
					Cf.dwEffects = Cf.dwEffects Or CFE_PROTECTED
				Else
					Cf.dwEffects = Cf.dwEffects And Not CFE_PROTECTED
				End If
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Property RichTextBox.SelCharOffset As Integer
			If FHandle Then
				Cf.dwMask = CFM_OFFSET
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.yOffset
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelCharOffset(Value As Integer)
			If FHandle Then
				Cf.dwMask = CFM_OFFSET
				Cf.yOffset = Value
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Property RichTextBox.SelCharSet As Integer
			If FHandle Then
				Cf.dwMask = CFM_CHARSET
				Perform(EM_GETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
				Return Cf.bCharSet
			End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelCharSet(Value As Integer)
			If FHandle Then
				Cf.dwMask = CFM_CHARSET
				Cf.bCharSet = Value
				Perform(EM_SETCHARFORMAT, SCF_SELECTION, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Function RichTextBox.GetCharIndexFromPos(p As My.Sys.Drawing.Point) As Integer
			Return Perform(EM_CHARFROMPOS, 0, CInt(@p))
	End Function
	
	Private Property RichTextBox.Zoom As Integer
			If Handle Then
				FZoom = 100
				Perform(EM_GETZOOM, CInt(@FZoomwp), CInt(@FZoomLP))
				If (FZoomLP > 0) Then FZoom = MulDiv(100, FZoomwp, FZoomLP)
			End If
		Return FZoom
	End Property
	
	Private Property RichTextBox.Zoom(Value As Integer)
		FZoom = Value
			If Value = 0 Then
				Perform(EM_SETZOOM, 0, 0)
			Else
				Perform(EM_SETZOOM, Value, 100)
			End If
	End Property
	
	Private Function RichTextBox.BottomLine As Integer
			Dim r As ..Rect, i As Integer
			Perform(EM_GETRECT, 0, CInt(@r))
			r.Left = r.Left + 1
			r.Top  = r.Bottom - 2
			i = Perform(EM_CHARFROMPOS, 0, CInt(@r))
			Return Perform(EM_EXLINEFROMCHAR, 0, i)
	End Function
	
	Private Function RichTextBox.CanRedo As Boolean
			If FHandle Then
				Return (Perform(EM_CANREDO, 0, 0) <> 0)
			Else
				Return 0
			End If
	End Function
	
	Private Sub RichTextBox.Undo
			If FHandle Then Perform(EM_UNDO, 0, 0)
	End Sub
	
	Private Sub RichTextBox.Redo
			If FHandle Then Perform(EM_REDO, 0, 0)
	End Sub
	
	Private Function RichTextBox.Find(ByRef Value As WString) As Boolean
			If FHandle = 0 Then Return False
			Dim ft As FINDTEXTEX, Result As Integer
			FFindText = _Reallocate(FFindText, (Len(Value) + 1) * SizeOf(FFindText))
			*FFindText = Value
			ft.lpstrText = FFindText
			ft.chrg.cpMin = 0
			ft.chrg.cpMax = -1
			Result = Perform(EM_FINDTEXTEX, FR_DOWN, Cast(LPARAM, @ft))
			If Result = -1 Then
				Return False
			Else
				Perform(EM_EXSETSEL, 0, Cast(LPARAM, @ft.chrgText))
				Return True
			End If
	End Function
	
	Private Function RichTextBox.FindNext(ByRef Value As WString = "") As Boolean
			If FHandle = 0 Then Return False
			Dim ft As FINDTEXTEX, Result As Integer
			If Value <> "" Then
				FFindText = _Reallocate(FFindText, (Len(Value) + 1) * SizeOf(FFindText))
				*FFindText = Value
			End If
			If FFindText = 0 Then Return False
			Perform(EM_EXGETSEL, 0, Cast(LPARAM, @ft.chrg))
			ft.lpstrText = FFindText
			If ft.chrg.cpMin <> ft.chrg.cpMax Then
				ft.chrg.cpMin = ft.chrg.cpMax
			End If
			ft.chrg.cpMax = -1
			Result = Perform(EM_FINDTEXTEX, FR_DOWN, Cast(LPARAM, @ft))
			If Result = -1 Then
				Return False
			Else
				Perform(EM_EXSETSEL, 0, Cast(LPARAM, @ft.chrgText))
				Return True
			End If
	End Function
	
	Private Function RichTextBox.FindPrev(ByRef Value As WString = "") As Boolean
			If FHandle = 0 Then Return False
			Dim ft As FINDTEXTEX, Result As Integer
			If Value <> "" Then
				FFindText = _Reallocate(FFindText, (Len(Value) + 1) * SizeOf(FFindText))
				*FFindText = Value
			End If
			If FFindText = 0 Then Return False
			Perform(EM_EXGETSEL, 0, Cast(LPARAM, @ft.chrg))
			ft.lpstrText = FFindText
			ft.chrg.cpMax = 0
			Result = Perform(EM_FINDTEXTEX, 0, Cast(LPARAM, @ft))
			If Result = -1 Then
				Return False
			Else
				Perform(EM_EXSETSEL, 0, Cast(LPARAM, @ft.chrgText))
				Return True
			End If
	End Function
	
		Private Sub RichTextBox.WndProc(ByRef message As Message)
		End Sub
	
	Private Sub RichTextBox.ProcessMessage(ByRef message As Message)
			Select Case message.Msg
			Case CM_COMMAND
				Select Case message.wParamHi
				Case EN_SELCHANGE
					If OnSelChange Then OnSelChange(*Designer, This)
					message.Result = 0
				Case EN_REQUESTRESIZE
					With Cast(REQRESIZE Ptr, message.lParam)->rc
						If OnResize Then OnResize(*Designer, This, UnScaleX(.Right - .Left), UnScaleY(.Bottom - .Top))
					End With
				Case EN_PROTECTED
					Static As Boolean AllowChange  = 1
					With Cast(ENPROTECTED Ptr, message.lParam)->chrg
						If OnProtectChange Then
							OnProtectChange(*Designer, This, .cpMin, .cpMax, AllowChange)
							If Not AllowChange Then message.Result = 1
						End If
					End With
				End Select
			Case WM_PASTE
				Dim Action As Integer = 1
				If OnPaste Then OnPaste(*Designer, This, Action)
				Select Case Action
				Case 0: message.Result = -1
				Case 1: message.Result = 0
				Case 2: message.Result = -2
					Dim As REPASTESPECIAL reps
					reps.dwAspect = 0
					reps.dwParam = 0
					message.Msg = EM_PASTESPECIAL
					message.wParam = CF_TEXT
					message.lParam = Cast(LPARAM, @reps)
				End Select
			Case WM_DPICHANGED
				Base.ProcessMessage message
				If ReadOnly Then TextRTF = FTextRTF
				Return
			Case WM_SETCURSOR
				If m_bMenuOpen Then
					message.Result = Cast(LRESULT, SetCursor(LoadCursor(NULL, IDC_ARROW)))
				End If
			Case WM_RBUTTONUP
				If ContextMenu Then
					If ContextMenu->Handle Then
						DownButton = -1
						Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(message.lParam))
						Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(message.lParam))
						If OnMouseUp AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then OnMouseUp(*Designer, This, 1, MouseX, MouseY, message.wParam And &HFFFF)
						Dim As ..Point P
						P.X = GET_X_LPARAM(message.lParam)
						P.Y = GET_Y_LPARAM(message.lParam)
						.ClientToScreen(FHandle, @P)
						m_bMenuOpen = True
						ContextMenu->Popup(P.X, P.Y)
						m_bMenuOpen = False
						Return
					End If
				End If
			Case WM_THEMECHANGED
				' Follow live light/dark switches even on hidden tabs. RichTextBox
				' only self-flips on WM_PAINT, which never fires while the control
				' sits on an unselected tab page - so a description pane toggled
				' while hidden kept its old colours (the Events pane staying white
				' after switching to dark from the Properties tab).
				' window, visible or not; mirror the WM_PAINT self-flip here so
				' SetDark re-colours background and text right away.
			Case WM_PAINT
				Dim As Any Ptr cp = GetClassProc(message.hWnd)
				If cp <> 0 Then
					message.Result = CallWindowProc(cp, message.hWnd, message.Msg, message.wParam, message.lParam)
				End If
				Dim As HDC Dc
				Dc = GetWindowDC(Handle)
				Dim As Rect r = Type( 0 )
				GetWindowRect(message.hWnd, @r)
				r.Right -= r.Left
				r.Bottom -= r.Top
				r.Left = 0
				r.Top = 0
				Dim As HPEN NewPen
				Dim As HPEN PrevPen
				Dim As HBRUSH PrevBrush
				NewPen = CreatePen(PS_SOLID, 1, BGR(130, 135, 144))
				PrevPen = SelectObject(Dc, NewPen)
				PrevBrush = SelectObject(Dc, GetStockObject(NULL_BRUSH))
				Rectangle Dc, r.Left, r.Top, r.Right, r.Bottom
				DeleteObject NewPen
				r.Right -= 1
				r.Bottom -= 1
				r.Left = 1
				r.Top = 1
				NewPen = CreatePen(PS_SOLID, 1, FBackColor)
				SelectObject(Dc, NewPen)
				Rectangle Dc, r.Left, r.Top, r.Right, r.Bottom
				SelectObject(Dc, PrevPen)
				SelectObject(Dc, PrevBrush)
				ReleaseDC(FHandle, Dc)
				DeleteObject NewPen
				message.Result = 0
				Return
			End Select
		Base.ProcessMessage(message)
	End Sub
	
	Private Property RichTextBox.EditStyle As Boolean
		Return FEditStyle
	End Property
	
	Private Property RichTextBox.EditStyle(Value As Boolean)
		FEditStyle = Value
			If FHandle Then
				If FEditStyle Then Perform(EM_SETEDITSTYLE, 1, 1)
			End If
	End Property
	
	Private Property RichTextBox.SelText ByRef As WString
		Dim As Integer LStart, LEnd
			If FHandle Then
				Dim charArr As CHARRANGE
				SendMessage(FHandle, EM_GETSEL, CInt(@LStart), CInt(@LEnd))
				If LEnd - LStart <= 0 Then
					FSelText = _Reallocate(FSelText, SizeOf(WString))
					*FSelText = ""
				Else
					FSelText = _Reallocate(FSelText, (LEnd - LStart + 1 + 1) * SizeOf(WString))
					*FSelText = String(LEnd - LStart + 1, 0)
					SendMessage(FHandle, EM_GETSELTEXT, 0, Cast(LPARAM, FSelText))
				End If
			End If
		If FSelText > 0 Then Return *FSelText Else Return WStr("")
	End Property
	
	Private Property RichTextBox.SelText(ByRef Value As WString)
		FSelText = _Reallocate(FSelText, (Len(Value) + 1) * SizeOf(WString))
		*FSelText = Value
			Dim stSetText As SETTEXTEX
			stSetText.flags = ST_KEEPUNDO
			stSetText.codepage = 1200
			SendMessage(FHandle, EM_REPLACESEL, Cast(WPARAM, @stSetText), Cast(LPARAM, FSelText))
	End Property
	
		Private Function RichTextBox.StreamInProc(hFile As ..HANDLE, pBuffer As PVOID, NumBytes As Integer, pBytesRead As Integer Ptr) As BOOL
			Dim As Integer length
			ReadFile(hFile, pBuffer, NumBytes, Cast(LPDWORD, @length), 0)
			*pBytesRead = length
			If length = 0 Then
				Return 1
			End If
		End Function
		
		Private Function RichTextBox.StreamOutProc (hFile As ..HANDLE, pBuffer As PVOID, NumBytes As Integer, pBytesWritten As Integer Ptr) As BOOL
			Dim As Integer length
			WriteFile(hFile, pBuffer, NumBytes, Cast(LPDWORD, @length), 0)
			*pBytesWritten = length
			If length = 0 Then
				Return 1
			End If
		End Function
		
		Private Function RichTextBox.GetTextCallback(dwCookie As DWORD_PTR, pbBuff As Byte Ptr, cb As Long, pcb As Long Ptr) As DWORD
			Dim ptxt As UString Ptr = Cast(UString Ptr, dwCookie)
			If ptxt Then
				*ptxt = *ptxt & *Cast(ZString Ptr, pbBuff)
				*pcb = cb
			End If
			Return 0
		End Function
	
	Private Property RichTextBox.TextRTF As UString
			If FHandle Then
				FTextRTF = ""
				Dim editstream As EDITSTREAM
				editstream.dwCookie = Cast(DWORD_PTR, @FTextRTF)
				editstream.pfnCallback = Cast(EDITSTREAMCALLBACK, @GetTextCallback)
				SendMessage(FHandle, EM_STREAMOUT, SF_RTF, Cast(LPARAM, @editstream))
			End If
		Return FTextRTF
	End Property
	
	Private Property RichTextBox.TextRTF(Value As UString)
		FTextRTF = Value
			If FHandle Then
				Dim As String Buffer
				If StartsWith(Value, "{\rtf") Then
					Buffer = Value
				ElseIf StartsWith(Value, "{\urtf") Then
					Buffer = ToUtf8(Value)
				Else
					Buffer = "{\urtf1" & ToUtf8(Value) & "}"
				End If
				Dim bb As SETTEXTEX
				bb.flags = ST_DEFAULT
				bb.codepage = CP_ACP
				Perform(EM_GETZOOM, CInt(@FZoomWP), CInt(@FZoomLP))
				Perform(EM_SETTEXTEX, Cast(WPARAM, @bb), Cast(LPARAM, StrPtr(Buffer)))
				Perform(EM_SETZOOM, FZoomWP, FZoomLP)
				' Replacing the text (EM_SETTEXTEX) can reset the RichEdit's
				' background and character colours to the system default, discarding
				' any custom ForeColor/BackColor. Re-assert them here.
				Dim As CHARFORMAT2 Cf
				Cf.cbSize = SizeOf(Cf)
				Cf.dwMask = CFM_COLOR Or CFM_BACKCOLOR
				SendMessage(FHandle, EM_SETBKGNDCOLOR, 0, FBackColor)
				Cf.crTextColor = FForeColor
				Cf.crBackColor = FBackColor
				SendMessage(FHandle, EM_SETCHARFORMAT, SCF_ALL, Cast(LPARAM, @Cf))
			End If
	End Property
	
	Private Function RichTextBox.AddImageFromFile(ByRef File As WString) As Boolean
		Dim As My.Sys.Drawing.BitmapType Bitm
		Bitm.LoadFromFile(File)
		Return AddImage(Bitm)
	End Function
	
	Private Function RichTextBox.AddImage(ByRef ResName As WString) As Boolean
		Dim As My.Sys.Drawing.BitmapType Bitm
		Bitm.LoadFromResourceName(ResName)
		Return AddImage(Bitm)
	End Function
	
	Private Function RichTextBox.AddImage(ByRef Ico As My.Sys.Drawing.Icon) As Boolean
		Dim As My.Sys.Drawing.BitmapType Bitm
			Bitm.Handle = Ico.ToBitmap
		Return AddImage(Bitm)
	End Function
	
	Private Function RichTextBox.AddImage(ByRef Cur As My.Sys.Drawing.Cursor) As Boolean
		Dim As My.Sys.Drawing.BitmapType Bitm
			Bitm.Handle = Cur.ToBitmap
		Return AddImage(Bitm)
	End Function
	
	Private Function RichTextBox.AddImage(ByRef Bitm As My.Sys.Drawing.BitmapType) As Boolean
			Dim As HRESULT hr
			
			Dim As LPRICHEDITOLE pRichEditOle
			SendMessage(FHandle, EM_GETOLEINTERFACE, 0, Cast(LPARAM, @pRichEditOle))
			
			If (pRichEditOle = NULL) Then
				Return False
			End If
			
			Dim As IDataObject Ptr pDataObject
			
			CoInitialize(NULL)
			If (OpenClipboard(NULL)) Then
				EmptyClipboard()
				SetClipboardData(CF_BITMAP, Bitm.Handle)
				CloseClipboard()
			Else
				Return False
			End If
			OleGetClipboard(@pDataObject)
			If (pDataObject = NULL) Then
				Return 0
			End If
			
			Dim As LPLOCKBYTES pLockBytes = NULL
			hr = CreateILockBytesOnHGlobal(NULL, True, @pLockBytes)
			
			If (FAILED(hr)) Then
				Return False
			End If
			
			Dim As LPSTORAGE pStorage
			hr = StgCreateDocfileOnILockBytes(pLockBytes, _
			STGM_SHARE_EXCLUSIVE Or STGM_CREATE Or STGM_READWRITE, _
			0, @pStorage)
			
			If (FAILED(hr)) Then
				Return False
			End If
			
			Dim As FORMATETC formatEtc
			formatEtc.cfFormat = 0
			formatEtc.ptd = NULL
			formatEtc.dwAspect = DVASPECT_CONTENT
			formatEtc.lindex = -1
			formatEtc.tymed = TYMED_NULL
			
			Dim As LPOLECLIENTSITE pClientSite
			hr = pRichEditOle->lpVtbl->GetClientSite(pRichEditOle, @pClientSite)
			
			If (FAILED(hr)) Then
				Return False
			End If
			
			Dim As LPUNKNOWN pUnk
			Dim As CLSID clsid_ = CLSID_NULL
			
			'hr = OleCreateFromFile(@clsid_, Cast(LPCOLESTR, @File), @IID_IUnknown, OLERENDER_DRAW, _
			'@formatEtc, pClientSite, pStorage, Cast(LPVOID Ptr, @pUnk))
			hr = OleCreateStaticFromData(pDataObject, @IID_IUnknown, OLERENDER_DRAW, _
			@formatEtc, pClientSite, pStorage, Cast(LPVOID Ptr, @pUnk))
			
			pClientSite->lpVtbl->Release(pClientSite)
			
			If (FAILED(hr)) Then
				Return False
			End If
			
			Dim As LPOLEOBJECT pObject
			hr = pUnk->lpVtbl->QueryInterface(pUnk, @IID_IOleObject, Cast(LPVOID Ptr, @pObject))
			pUnk->lpVtbl->Release(pUnk)
			
			If (FAILED(hr)) Then
				Return False
			End If
			
			OleSetContainedObject(Cast(LPUNKNOWN, pObject), True)
			Dim As REOBJECT reobject
			reobject.cbStruct = SizeOf(reobject)
			hr = pObject->lpVtbl->GetUserClassID(pObject, @clsid_)
			
			If (FAILED(hr)) Then
				pObject->lpVtbl->Release(pObject)
				Return False
			End If
			
			reobject.clsid = clsid_
			reobject.cp = REO_CP_SELECTION
			reobject.dvaspect = DVASPECT_CONTENT 'DVASPECT_THUMBNAIL, DVASPECT_ICON, DVASPECT_DOCPRINT
			'reobject.dvaspect = DVASPECT_DOCPRINT
			reobject.dwFlags = REO_BELOWBASELINE 'Or REO_RESIZABLE 'Or REO_USEASBACKGROUND
			reobject.dwUser = 0
			reobject.poleobj = pObject
			reobject.polesite = pClientSite
			reobject.pstg = pStorage
			Dim As SIZEL sizel
			sizel.cx = 0
			reobject.sizel = sizel
			
			'			SendMessage(FHandle, EM_SETSEL, 0, -1)
			'			Dim As DWORD dwStart, dwEnd
			'			SendMessage(FHandle, EM_GETSEL, Cast(WPARAM, @dwStart), Cast(LPARAM, @dwEnd))
			'			SendMessage(FHandle, EM_SETSEL, dwEnd + 1, dwEnd + 1)
			SendMessage(FHandle, EM_REPLACESEL, True, Cast(WPARAM, @""))
			
			hr = pRichEditOle->lpVtbl->InsertObject(pRichEditOle, @reobject)
			pObject->lpVtbl->Release(pObject)
			pRichEditOle->lpVtbl->Release(pRichEditOle)
			CoUninitialize()
			
			If (FAILED(hr)) Then
				Return False
			End If
			
		Return True
	End Function
	
	Private Sub RichTextBox.LoadFromFile(ByRef Value As WString, bRTF As Boolean)
			If FHandle Then
				Dim hFile As ..HANDLE
				hFile = CreateFile(@Value, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
				If hFile <> INVALID_HANDLE_VALUE Then
					Dim editstream As EDITSTREAM
					editstream.dwCookie = Cast(DWORD_PTR, hFile)
					editstream.pfnCallback = Cast(EDITSTREAMCALLBACK, @StreamInProc)
					SendMessage(FHandle, EM_STREAMIN, IIf(bRTF, SF_RTF, SF_TEXT), Cast(LPARAM, @editstream))
					SendMessage(FHandle, EM_SETMODIFY, False, 0)
					CloseHandle(hFile)
				End If
			End If
	End Sub
	
	Private Sub RichTextBox.SaveToFile(ByRef Value As WString, bRTF As Boolean)
			If Not bRTF Then
				Base.SaveToFile(Value)
			ElseIf FHandle Then
				Dim hFile As ..HANDLE
				hFile = CreateFile(@Value, GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
				If hFile <> INVALID_HANDLE_VALUE Then
					Dim editstream As EDITSTREAM
					editstream.dwCookie = Cast(DWORD_PTR,hFile)
					editstream.pfnCallback= Cast(EDITSTREAMCALLBACK,@StreamOutProc)
					SendMessage(FHandle, EM_STREAMOUT, IIf(bRTF, SF_RTF, SF_TEXT), Cast(LPARAM, @editstream))
					SendMessage(FHandle, EM_SETMODIFY, False, 0)
					CloseHandle(hFile)
				End If
			End If
	End Sub
	
	Private Function RichTextBox.SelPrint(ByRef Canvas As My.Sys.Drawing.Canvas) As Boolean
			Dim di As DOCINFO, sz As WString * 64 = This.Name
			di.cbSize = SizeOf(DOCINFO)
			di.lpszDocName = VarPtr(sz)
			Dim hdc As HDC = Canvas.Handle
			If StartDoc(hdc, @di) <= 0 Then
				Return False
			End If
			
			Dim As Integer cxPhysOffset = GetDeviceCaps(hdc, PHYSICALOFFSETX)
			Dim As Integer cyPhysOffset = GetDeviceCaps(hdc, PHYSICALOFFSETY)
			
			Dim As Integer cxPhys = GetDeviceCaps(hdc, PHYSICALWIDTH)
			Dim As Integer cyPhys = GetDeviceCaps(hdc, PHYSICALHEIGHT)
			
			' Create "print preview".
			SendMessage(FHandle, EM_SETTARGETDEVICE, Cast(WPARAM, hdc), cxPhys / 2)
			
			Dim As FORMATRANGE fr
			
			fr.hdc       = hdc
			fr.hdcTarget = hdc
			
			' Set page rect To physical page size in twips.
			fr.rcPage.Top    = 0
			fr.rcPage.Left   = 0
			fr.rcPage.Right  = MulDiv(cxPhys, 1440, GetDeviceCaps(hdc, LOGPIXELSX))
			fr.rcPage.Bottom = MulDiv(cyPhys, 1440, GetDeviceCaps(hdc, LOGPIXELSY))
			
			' Set the rendering rectangle To the pintable area of the page.
			fr.rc.Left   = cxPhysOffset
			fr.rc.Right  = cxPhysOffset + cxPhys
			fr.rc.Top    = cyPhysOffset
			fr.rc.Bottom = cyPhysOffset + cyPhys
			
			'SendMessage(FHandle, EM_SETSEL, 0, Cast(LPARAM, -1))          ' Select the entire contents.
			SendMessage(FHandle, EM_EXGETSEL, 0, Cast(LPARAM, @fr.chrg))  ' Get the selection into a CHARRANGE.
			
			Dim As Boolean fSuccess = True
			
			' Use GDI To Print successive pages.
			While (fr.chrg.cpMin < fr.chrg.cpMax AndAlso fSuccess)
				fSuccess = StartPage(hdc) > 0
				
				If (Not fSuccess) Then Exit While
				
				Dim As Integer cpMin = SendMessage(FHandle, EM_FORMATRANGE, True, Cast(LPARAM, @fr))
				
				If (cpMin <= fr.chrg.cpMin) Then
					fSuccess = False
					Exit While
				End If
				
				fr.chrg.cpMin = cpMin
				fSuccess = EndPage(hdc) > 0
			Wend
			
			SendMessage(FHandle, EM_FORMATRANGE, False, 0)
			
			If (fSuccess) Then
				EndDoc(hdc)
			Else
				AbortDoc(hdc)
			End If
			
			Return fSuccess
	End Function
	
		Private Sub RichTextBox.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QRichTextBox(Sender.Child)
					If .MaxLength <> 0 Then
						.MaxLength = .MaxLength
					Else
						.Perform(EM_EXLIMITTEXT, 0, -1)
					End If
					
					If .EditStyle Then
						.EditStyle = .EditStyle
					End If
					If .FZoom Then
						.Zoom = .FZoom
					End If
					If .ReadOnly Then .Perform(EM_SETREADONLY, True, 0)
					.Perform(EM_SETEVENTMASK, 0, .Perform(EM_GETEVENTMASK, 0, 0) Or ENM_CHANGE Or ENM_SCROLL Or ENM_SELCHANGE Or ENM_CLIPFORMAT Or ENM_MOUSEEVENTS)
				End With
			End If
		End Sub
		
	
	Private Operator RichTextBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor RichTextBox
		With This
				Dim hRichEditCls As String
				hRichTextBox = LoadLibrary("msftedit.dll")
				If hRichTextBox = NULL Then
					hRichTextBox = LoadLibrary("riched20.dll")
					If hRichTextBox = NULL Then
					Else
						hRichEditCls = "RichEdit20W"
					End If
				Else
					hRichEditCls = "RICHEDIT50W"
				End If
				
				Pf.cbSize = SizeOf(Pf)
				Pf2.cbSize = SizeOf(Pf2)
				Cf.cbSize = SizeOf(Cf)
				Cf2.cbSize = SizeOf(Cf2)
				.RegisterClass "RichTextBox", hRichEditCls
				.OnHandleIsAllocated = @HandleIsAllocated
				.ChildProc		= @WndProc
				WLet(.FClassAncestor, hRichEditCls)
			.FHideSelection    = False
			FTabIndex          = -1
			FTabStop           = True
			WLet(.FClassName, "RichTextBox")
			.Child       = @This
			.DoubleBuffered = True
			.Width       = 121
			.Height      = 121
		End With
	End Constructor
	
	Private Destructor RichTextBox
		If FFindText Then _Deallocate(FFindText)
		If FTextRange Then _Deallocate(FTextRange)
		If FSelWStrVal Then _Deallocate(FSelWStrVal)
			DestroyWindow FHandle
			FreeLibrary(hRichTextBox)
	End Destructor
End Namespace