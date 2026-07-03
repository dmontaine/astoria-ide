'###############################################################################
'#  TextBox.bi                                                                 #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TEdit.bi                                                                  #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "TextBox.bi"

Namespace My.Sys.Forms
		Private Function TextBox.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "borderstyle": Return @FBorderStyle
				'Case "caretpos": Return @CaretPos
			Case "charcase": Return @FCharCase
			Case "ctl3d": Return @FCtl3D
			Case "hideselection": Return @FHideSelection
			Case "leftmargin": Return @FLeftMargin
			Case "maskchar": Return FMaskChar
			Case "masked": Return @FMasked
			Case "maxlength": Return @FMaxLength
			Case "modified": Return @FModified
			Case "multiline": Return @FMultiline
			Case "numbersonly": Return @FNumbersOnly
			Case "oemconvert": Return @FOEMConvert
			Case "readonly": Return @FReadOnly
			Case "rightmargin": Return @FRightMargin
			Case "scrollbars": Return @FScrollBars
			Case "selstart": Return @FSelStart
			Case "sellength": Return @FSelLength
			Case "selend": Return @FSelEnd
			Case "seltext": Return FSelText
			Case "tabindex": Return @FTabIndex
			Case "topline": Return @FTopLine
			Case "wantreturn": Return @FWantReturn
			Case "wanttab": Return @FWantTab
			Case "wordwraps": Return @FWordWraps
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function TextBox.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "alignment": Alignment = *Cast(AlignmentConstants Ptr, Value)
				Case "borderstyle": BorderStyle = *Cast(BorderStyles Ptr, Value)
				Case "caretpos": CaretPos = *Cast(My.Sys.Drawing.Point Ptr, Value)
				Case "charcase": CharCase = *Cast(CharCases Ptr, Value)
				Case "ctl3d": Ctl3D = QBoolean(Value)
				Case "hideselection": HideSelection = QBoolean(Value)
				Case "leftmargin": LeftMargin = QInteger(Value)
				Case "maskchar": MaskChar = QWString(Value)
				Case "masked": Masked = QBoolean(Value)
				Case "maxlength": MaxLength = QInteger(Value)
				Case "modified": Modified = QBoolean(Value)
				Case "multiline": Multiline = QBoolean(Value)
				Case "numbersonly": NumbersOnly = QBoolean(Value)
				Case "oemconvert": OEMConvert = QBoolean(Value)
				Case "readonly": ReadOnly = QBoolean(Value)
				Case "rightmargin": RightMargin = QInteger(Value)
				Case "scrollbars": ScrollBars = *Cast(ScrollBarsType Ptr, Value)
				Case "selstart": SelStart = QInteger(Value)
				Case "sellength": SelLength = QInteger(Value)
				Case "selend": SelEnd = QInteger(Value)
				Case "seltext": SelText = QWString(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "topline": TopLine = QInteger(Value)
				Case "wantreturn": WantReturn = QBoolean(Value)
				Case "wanttab": WantTab = QBoolean(Value)
				Case "wordwraps": WordWraps = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property TextBox.Alignment As AlignmentConstants
		Return FAlignment
	End Property
	
	Private Property TextBox.Alignment(Value As AlignmentConstants)
		If Value <> FAlignment Then
			FAlignment = Value
				ChangeStyle ES_LEFT, False
				ChangeStyle ES_CENTER, False
				ChangeStyle ES_RIGHT, False
				Select Case Value
				Case taLeft: ChangeStyle ES_LEFT, True
				Case taCenter: ChangeStyle ES_CENTER, True
				Case taRight: ChangeStyle ES_RIGHT, True
				End Select
				RecreateWnd
		End If
	End Property
	
	Private Property TextBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TextBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TextBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TextBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub TextBox.ScrollToCaret()
			Perform EM_SCROLLCARET, 0, 0
	End Sub
	
	Private Sub TextBox.ScrollToEnd()
			Dim totalLines As Integer
			Dim firstVisible As Integer
			Dim visibleLines As Integer
			totalLines = SendMessage(FHandle, EM_GETLINECOUNT, 0, 0)
			firstVisible = SendMessage(FHandle, EM_GETFIRSTVISIBLELINE, 0, 0)
			visibleLines = totalLines - firstVisible
			SendMessage(FHandle, EM_LINESCROLL, 0, totalLines - firstVisible - visibleLines + 1)
	End Sub
	
	Private Sub TextBox.ScrollToLine(LineNumber As Integer)
			Perform EM_LINESCROLL, 0, LineNumber
	End Sub
	
	Private Property TextBox.LeftMargin() As Integer
			If FHandle Then
				Dim As DWORD Result = SendMessage(FHandle, EM_GETMARGINS, 0, 0)
				FLeftMargin = LoWord(Result)
			End If
		Return FLeftMargin
	End Property
	
	Private Property TextBox.LeftMargin(Value As Integer)
		FLeftMargin = Value
			If FHandle Then
				SendMessage(FHandle, EM_SETMARGINS, EC_LEFTMARGIN, MAKELPARAM(ScaleX(FLeftMargin), ScaleX(FRightMargin)))
			End If
	End Property
	
	Private Property TextBox.RightMargin() As Integer
			If FHandle Then
				Dim As DWORD Result = SendMessage(FHandle, EM_GETMARGINS, 0, 0)
				FRightMargin = HiWord(Result)
			End If
		Return FRightMargin
	End Property
	
	Private Property TextBox.RightMargin(Value As Integer)
		FRightMargin = Value
			If FHandle Then
				SendMessage(FHandle, EM_SETMARGINS, EC_RIGHTMARGIN, MAKELPARAM(ScaleX(FLeftMargin), ScaleX(FRightMargin)))
			End If
	End Property
	
	Private Property TextBox.WantReturn() As Boolean
			FWantReturn = StyleExists(ES_WANTRETURN)
		Return FWantReturn
	End Property
	
	Private Property TextBox.WantReturn(Value As Boolean)
		FWantReturn = Value
			ChangeStyle ES_WANTRETURN, Value
	End Property
	
	Private Property TextBox.WantTab() As Boolean
		Return FWantTab
	End Property
	
	Private Property TextBox.WantTab(Value As Boolean)
		FWantTab = Value
	End Property
	
	Private Property TextBox.Multiline() As Boolean
		Return FMultiline
	End Property
	
	Private Property TextBox.Multiline(Value As Boolean)
		FMultiline = Value
			If FMultiline Then
				Base.Style = Base.Style Or ES_MULTILINE Or ES_WANTRETURN
			Else
				Base.Style = Base.Style And Not ES_MULTILINE And Not ES_WANTRETURN
			End If
			RecreateWnd
	End Property
	
	Private Sub TextBox.AddLine(ByRef wsLine As WString)
		InsertLine(LinesCount - 1, wsLine)
	End Sub
	
		Private Sub TextBox.InsertLine(Index As Integer, ByRef wsLine As WString)
			Dim As Integer iStart, LineLen
				Dim As WString Ptr sLine = _CAllocate((Len(wsLine) + 4) * SizeOf(WString))
				If Index >= 0 Then
					iStart = SendMessage(FHandle, EM_LINEINDEX, Index, 0)
					If iStart >= 0 Then
						*sLine = wsLine + WChr(13) & WChr(10)
					Else
						iStart = SendMessage(FHandle, EM_LINEINDEX, Index - 1, 0)
						If iStart < 0 Then Exit Sub
						LineLen = SendMessage(FHandle, EM_LINELENGTH, SelStart,0)
						If LineLen = 0 Then Exit Sub
						iStart += LineLen
						*sLine = WChr(13) & WChr(10) + wsLine
					End If
					SendMessage(FHandle, EM_SETSEL, iStart, iStart)
					SendMessage(FHandle, EM_REPLACESEL, 0, Cast(LPARAM, sLine))
					_Deallocate(sLine)
				End If
		End Sub
	
	Private Sub TextBox.RemoveLine(Index As Integer)
		Const Empty = ""
		Dim As Integer iStart, iEnd
			iStart = SendMessage(FHandle, EM_LINEINDEX, Index, 0)
			If iStart >= 0 Then
				iEnd = SendMessage(FHandle, EM_LINEINDEX, Index + 1, 0)
				If iEnd < 0 Then iEnd = iStart + SendMessage(FHandle, EM_LINELENGTH, iStart, 0)
				SendMessage(FHandle, EM_SETSEL, iStart, iEnd)
				SendMessage(FHandle, EM_REPLACESEL, 0, CInt(StrPtr(Empty)))
			End If
	End Sub
	
	Private Property TextBox.Text ByRef As WString
			Return Base.Text
	End Property
	
	Private Property TextBox.Text(ByRef Value As WString)
		Base.Text = Value
	End Property
	
	Private Property TextBox.Text_ ByRef As UString
			Base.Text
			FText_.Resize FText.m_Length
			*FText_.m_Data = *FText.m_Data
			Return FText_
	End Property
	
	Private Sub TextBox.OnTextChanged(ByRef Sender As UString)
		Dim As Control Ptr Owner = Cast(Control Ptr, Sender.m_Owner)
		Owner->Text = Sender
	End Sub
	
	Private Property TextBox.Text_(ByRef Value As UString)
		FText_ = Value
	End Property
	
	Private Function TextBox.GetTextLength() As Integer
			Return Base.GetTextLength
	End Function
	
	Private Property TextBox.BorderStyle As BorderStyles
		Return FBorderStyle
	End Property
	
	Private Property TextBox.BorderStyle(Value As BorderStyles)
		FBorderStyle = Value
			If FBorderStyle Then
				'Base.Style = Base.Style Or WS_BORDER
				Base.ExStyle = WS_EX_CLIENTEDGE
			Else
				'Base.Style = Base.Style And Not WS_BORDER
				Base.ExStyle = 0
			End If
	End Property
	
	Private Property TextBox.ReadOnly As Boolean
		Return FReadOnly
	End Property
	
	Private Property TextBox.ReadOnly(Value As Boolean)
		FReadOnly = Value
			If Handle Then Perform(EM_SETREADONLY, FReadOnly, 0)
	End Property
	
	Private Property TextBox.Ctl3D As Boolean
		Return FCtl3D
	End Property
	
	Private Property TextBox.Ctl3D(Value As Boolean)
		If Value <> FCtl3D Then
			FCtl3D = Value
			RecreateWnd
		End If
	End Property
	
	Private Property TextBox.HideSelection As Boolean
		Return FHideSelection
	End Property
	
	Private Property TextBox.HideSelection(Value As Boolean)
		FHideSelection = Value
			If Not FHideSelection Then Base.Style = Base.Style Or ES_NOHIDESEL Else Base.Style = Base.Style And Not ES_NOHIDESEL
	End Property
	
	Private Property TextBox.OEMConvert As Boolean
		Return FOEMConvert
	End Property
	
	Private Property TextBox.OEMConvert(Value As Boolean)
		If Value <> FOEMConvert Then
			FOEMConvert = Value
			RecreateWnd
		End If
	End Property
	
	Private Property TextBox.CharCase As CharCases
		Return FCharCase
	End Property
	
	Private Property TextBox.CharCase(Value As CharCases)
		If FCharCase <> Value Then
			FCharCase = Value
				ChangeStyle(ES_LOWERCASE, False)
				ChangeStyle(ES_UPPERCASE, False)
				Select Case FCharCase
				Case ecNone
				Case ecLower: ChangeStyle(ES_LOWERCASE, True)
				Case ecUpper: ChangeStyle(ES_UPPERCASE, True)
				End Select
		End If
	End Property
	
	Private Property TextBox.Masked As Boolean
		Return FMasked
	End Property
	
	Private Property TextBox.Masked(Value As Boolean)
		FMasked = Value
			If Handle Then
				If FMasked Then
					If WGet(FMaskChar) = "" Then
						Perform(EM_SETPASSWORDCHAR, Asc("*"), 0)
					Else
						Perform(EM_SETPASSWORDCHAR, Asc(*FMaskChar), 0)
					End If
				Else
					Perform(EM_SETPASSWORDCHAR, 0, 0)
				End If
			End If
	End Property
	
	Private Property TextBox.MaskChar ByRef As WString
		If FMaskChar > 0 Then Return *FMaskChar Else Return WStr("")
	End Property
	
	Private Property TextBox.MaskChar(ByRef Value As WString)
		WLet(FMaskChar, Value)
			If Handle Then Perform(EM_SETPASSWORDCHAR, Asc(Value), 0)
	End Property
	
	Private Property TextBox.NumbersOnly As Boolean
		Return FNumbersOnly
	End Property
	
	Private Property TextBox.NumbersOnly(Value As Boolean)
		FNumbersOnly = Value
			ChangeStyle ES_NUMBER, Value
	End Property
	
	Private Property TextBox.TopLine As Integer
			If FHandle Then FTopLine = Perform(EM_GETFIRSTVISIBLELINE, 0, 0)
		Return FTopLine
	End Property
	
	Private Property TextBox.TopLine(Value As Integer)
		FTopLine = Value
			If FHandle Then Perform(10012, FTopLine, 0)
	End Property
	
	Private Sub TextBox.InputFilter(ByRef Value As WString)
		FInputFilter = _Reallocate(FInputFilter, (Len(Value) + 1) * SizeOf(WString))
		*FInputFilter = Value
	End Sub
	
	Private Sub TextBox.LoadFromFile(ByRef File As WString)
		Dim Result As Integer
		Dim Fn As Integer = FreeFile_
		Result = Open(File For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(File For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(File For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(File For Input As #Fn)
		If Result = 0 Then
			FText = WInput(LOF(Fn), #Fn)
				If FHandle Then SetWindowText(FHandle, FText.vptr)
		End If
		CloseFile_(Fn)
	End Sub
	
	Private Sub TextBox.SaveToFile(ByRef FILE As WString)
		Dim As Integer Fn = FreeFile_
		If Open(FILE For Output Encoding "utf-8" As #Fn) = 0 Then
			Print #Fn, Text;
		End If
		CloseFile_(Fn)
	End Sub
	
	Private Function TextBox.GetLineLength(Index As Integer = -1) As Integer
			If FHandle Then
				Dim As Integer CharIndex = SendMessage(FHandle, EM_LINEINDEX, Index, 0)
				Return SendMessage(FHandle, EM_LINELENGTH, CharIndex, 0)
			End If
		Return -1
	End Function
	
	Private Function TextBox.GetLineFromCharIndex(Index As Integer = -1) As Integer
			If FHandle Then
				Return SendMessage(FHandle, EM_LINEFROMCHAR, Index, 0)
			End If
		Return -1
	End Function
	
	Private Function TextBox.GetCharIndexFromLine(Index As Integer) As Integer
			If FHandle Then
				Return SendMessage(FHandle, EM_LINEINDEX, Index, 0)
			End If
		Return -1
	End Function
	
	Private Property TextBox.Lines(Index As Integer) ByRef As WString
			If FHandle Then
				Dim As Integer lThisChar = SendMessage(FHandle, EM_LINEINDEX, Index, 0)
				Dim As Integer lChar = SendMessage(FHandle, EM_LINELENGTH, lThisChar, 0)
				WLet(FLine, WSpace(lChar))
				Mid(*FLine, 1, 1) = WChr(lChar And &HFF)
				Mid(*FLine, 2, 1) = WChr(lChar \ &H100)
				SendMessage(FHandle, EM_GETLINE, Index, CInt(FLine))
				Return *FLine
			End If
		Return WStr("")
	End Property
	
	Private Property TextBox.Lines(Index As Integer, ByRef Value As WString)
			If FHandle Then
				Dim As Integer iStart, iEnd
				iStart = SendMessage(FHandle, EM_LINEINDEX, Index, 0)
				If iStart >= 0 Then
					iEnd = SendMessage(FHandle, EM_LINEINDEX, Index + 1, 0)
					If iEnd < 0 Then iEnd = iStart + SendMessage(FHandle, EM_LINELENGTH, iStart, 0)
					SendMessage(FHandle, EM_SETSEL, iStart, iEnd)
					SendMessage(FHandle, EM_REPLACESEL, True, CInt(@Value))
				End If
			End If
	End Property
	
	Private Sub TextBox.GetSel(ByRef iSelStart As Integer, ByRef iSelEnd As Integer)
			If FHandle Then
				SendMessage(FHandle, EM_GETSEL, CInt(@iSelStart), CInt(@iSelEnd))
			End If
	End Sub
	
	Private Sub TextBox.GetSel(ByRef iSelStartRow As Integer, ByRef iSelStartCol As Integer, ByRef iSelEndRow As Integer, ByRef iSelEndCol As Integer)
			If FHandle Then
				Dim As Integer iSelStart, iSelEnd
				SendMessage(FHandle, EM_GETSEL, CInt(@iSelStart), CInt(@iSelEnd))
				iSelStartRow = SendMessage(FHandle, EM_LINEFROMCHAR, iSelStart, 0)
				iSelStartCol = iSelStart - SendMessage(FHandle, EM_LINEINDEX, iSelStartRow, 0)
				iSelEndRow = SendMessage(FHandle, EM_LINEFROMCHAR, iSelEnd, 0)
				iSelEndCol = iSelEnd - SendMessage(FHandle, EM_LINEINDEX, iSelEndRow, 0)
			End If
	End Sub
	
	Private Sub TextBox.SetSel(iSelStart As Integer, iSelEnd As Integer)
			If FHandle Then
				SendMessage(FHandle, EM_SETSEL, iSelStart, iSelEnd)
			Else
				FSelStart = iSelStart
				FSelEnd = iSelEnd
			End If
	End Sub
	
	Private Sub TextBox.SetSel(iSelStartRow As Integer, iSelStartCol As Integer, iSelEndRow As Integer, iSelEndCol As Integer)
			If FHandle Then
				Dim As Integer iSelStart, iSelEnd
				iSelStart = SendMessage(FHandle, EM_LINEINDEX, iSelStartRow, 0) + iSelStartCol
				iSelEnd = SendMessage(FHandle, EM_LINEINDEX, iSelEndRow, 0) + iSelEndCol
				SendMessage(FHandle, EM_SETSEL, iSelStart, iSelEnd)
			End If
	End Sub
	
		Private Function TextBox.LinesCount As Integer
				If FHandle Then
					Return SendMessage(FHandle, EM_GETLINECOUNT, 0, 0)
				End If
			Return 0
		End Function
	
	Private Property TextBox.CaretPos As My.Sys.Drawing.Point
		Dim As Integer x, y
			If FHandle Then
				x = HiWord(SendMessage(FHandle, EM_GETSEL, 0, 0))
				y = SendMessage(FHandle, EM_LINEFROMCHAR, x, 0)
				x = x - SendMessage(FHandle, EM_LINEINDEX, -1, 0)
				Return Type(x, y)
			End If
		Return Type(0, 0)
	End Property
	
	Private Property TextBox.CaretPos(value As My.Sys.Drawing.Point)
	End Property
	
	Private Property TextBox.ScrollBars As ScrollBarsType
		Return FScrollBars
	End Property
	
	Private Property TextBox.ScrollBars(Value As ScrollBarsType)
		FScrollBars = Value
			Select Case FScrollBars
			Case 0
				This.Style = This.Style And Not (WS_HSCROLL Or WS_VSCROLL)
			Case 1
				This.Style = (This.Style And Not WS_HSCROLL) Or WS_VSCROLL
			Case 2
				This.Style = (This.Style And Not WS_VSCROLL) Or WS_HSCROLL
			Case 3
				This.Style = This.Style Or (WS_HSCROLL Or WS_VSCROLL)
			End Select
			RecreateWnd
	End Property
	
	Private Property TextBox.WordWraps As Boolean
		Return FWordWraps
	End Property
	
	
	Private Property TextBox.WordWraps(Value As Boolean)
		Dim As Integer s, e
		GetSel(s, e)
		FWordWraps = Value
			If Value Then
				This.Style = This.Style And Not ES_AUTOHSCROLL
			Else
				This.Style = This.Style Or ES_AUTOHSCROLL
			End If
			RecreateWnd
		ScrollBars = IIf(Value, ScrollBarsType.Vertical, ScrollBarsType.Both)
		SetSel(s, e)
		ScrollToCaret()
	End Property
	
	Private Property TextBox.SelStart As Integer
		Dim As Integer LStart
			SendMessage(Handle, EM_GETSEL, CInt(@FSelStart), 0)
		Return FSelStart
	End Property
	
	Private Property TextBox.SelStart(Value As Integer)
		FSelStart = Value
			SendMessage(Handle, EM_SETSEL, Value, Value)
	End Property
	
	Private Property TextBox.SelLength As Integer
		Dim As Integer LStart, LEnd
			SendMessage(Handle, EM_GETSEL, CInt(@LStart), CInt(@LEnd))
		FSelLength = LEnd - LStart
		Return FSelLength
	End Property
	
	Private Property TextBox.SelLength(Value As Integer)
		Dim As Integer LStart, LEnd, FEnd
		FSelLength = Value
			SendMessage(Handle, EM_GETSEL, CInt(@LStart), CInt(@LEnd))
			FEnd = LStart + Value
			SendMessage(Handle, EM_SETSEL, LStart, FEnd)
			'SendMessage(Handle, EM_SCROLLCARET, 0,0)
	End Property
	
	Private Property TextBox.SelEnd As Integer
		Dim As Integer LStart, LEnd
			SendMessage(Handle, EM_GETSEL, 0, CInt(@LEnd))
		FSelEnd = LEnd
		Return FSelEnd
	End Property
	
	Private Property TextBox.SelEnd(Value As Integer)
		Dim As Integer LStart, LEnd, FEnd
		FSelEnd = Value
			SendMessage(Handle, EM_GETSEL, CInt(@LStart), CInt(@LEnd))
			SendMessage(Handle, EM_SETSEL, LStart, FSelEnd)
			'SendMessage(Handle, EM_SCROLLCARET, 0,0)
	End Property
	
	Private Property TextBox.SelText ByRef As WString
		Dim As Integer LStart, LEnd
			If FHandle Then
				Dim As Integer LStart, LEnd
				SendMessage(FHandle, EM_GETSEL, CInt(@LStart), CInt(@LEnd))
				If LEnd - LStart <= 0 Then
					FSelText = _Reallocate(FSelText, SizeOf(WString))
					*FSelText = ""
				Else
					FSelText = _Reallocate(FSelText, (LEnd - LStart + 1 + 1) * SizeOf(WString))
					*FSelText = Mid(Text, LStart + 1, LEnd - LStart)
				End If
			End If
		Return *FSelText
	End Property
	
	Private Property TextBox.SelText(ByRef Value As WString)
		FSelText = _Reallocate(FSelText, (Len(Value) + 1) * SizeOf(WString))
		*FSelText = Value
			SendMessage(FHandle, EM_REPLACESEL, 0, CInt(FSelText))
	End Property
	
	Private Property TextBox.MaxLength As Integer
		Return FMaxLength
	End Property
	
	Private Property TextBox.MaxLength(Value As Integer)
		FMaxLength = Value
			If Handle Then Perform(EM_LIMITTEXT, Value, 0)
	End Property
	
	Private Property TextBox.Modified As Boolean
			If Handle Then
				FModified = (Perform(EM_GETMODIFY, 0, 0) <> 0)
			End If
		Return FModified
	End Property
	
	Private Property TextBox.Modified(Value As Boolean)
		FModified = Value
			If Handle Then
				Perform(EM_SETMODIFY, Cast(Byte, Value), 0)
			End If
	End Property
	
		Private Sub TextBox.WndProc(ByRef message As Message)
		End Sub
		
		Private Sub TextBox.SetDark(Value As Boolean)
			Base.SetDark Value
		End Sub
	
		Private Sub TextBox.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QTextBox(Sender.Child)
						If .FMaxLength = 0 Then
							.Perform(EM_LIMITTEXT, -1, 0)
						Else
							.Perform(EM_LIMITTEXT, .FMaxLength, 0)
						End If
						If .ReadOnly Then .Perform(EM_SETREADONLY, True, 0)
						If .FMasked Then .Masked = True
						If .FSelStart <> 0 OrElse .FSelEnd <> 0 Then .SetSel .FSelStart, .FSelEnd
						If .FLeftMargin <> 0 Then
							SendMessage(.FHandle, EM_SETMARGINS, EC_LEFTMARGIN, MAKELPARAM(.ScaleX(.FLeftMargin), .ScaleX(.FRightMargin)))
						End If
						If .FRightMargin <> 0 Then
							SendMessage(.FHandle, EM_SETMARGINS, EC_RIGHTMARGIN, MAKELPARAM(.ScaleX(.FLeftMargin), .ScaleX(.FRightMargin)))
						End If
						'.MaxLength = .MaxLength
						'End If
				End With
			End If
		End Sub
	
	Private Sub TextBox.ProcessMessage(ByRef message As Message)
			Select Case message.Msg
			Case WM_PAINT, WM_MOUSELEAVE, WM_MOUSEMOVE
				If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso (CBool(message.Msg <> WM_MOUSEMOVE) OrElse (CBool(message.Msg = WM_MOUSEMOVE) AndAlso FMouseInClient)) Then
					If Not FDarkMode Then
						FDarkMode = True
						Brush.Handle = hbrBkgnd
						SetWindowTheme(FHandle, "DarkMode_Explorer", nullptr)
						SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
						Repaint
					End If
					Dim As Any Ptr cp = GetClassProc(message.hWnd)
					If cp <> 0 Then
						message.Result = CallWindowProc(cp, message.hWnd, message.Msg, message.wParam, message.lParam)
					End If
					Dim As HDC Dc
					Dc = GetWindowDC(Handle)
					Dim As Rect r = Type( 0 )
					GetWindowRect(message.hWnd, @r)
					r.Right -= r.Left + 1
					r.Bottom -= r.Top + 1
					r.Left = 1
					r.Top = 1
					Dim As HPEN NewPen = CreatePen(PS_SOLID, 1, darkBkColor)
					Dim As HPEN PrevPen = SelectObject(Dc, NewPen)
					Dim As HPEN PrevBrush = SelectObject(Dc, GetStockObject(NULL_BRUSH))
					Rectangle Dc, r.Left, r.Top, r.Right, r.Bottom
					SelectObject(Dc, PrevPen)
					SelectObject(Dc, PrevBrush)
					ReleaseDC(Handle, Dc)
					DeleteObject NewPen
					message.Result = 0
					Return
				End If
			Case WM_DPICHANGED
				Base.ProcessMessage message
				If FLeftMargin <> 0 Then
					SendMessage(FHandle, EM_SETMARGINS, EC_LEFTMARGIN, MAKELPARAM(ScaleX(FLeftMargin), ScaleX(FRightMargin)))
				End If
				If FRightMargin <> 0 Then
					SendMessage(FHandle, EM_SETMARGINS, EC_RIGHTMARGIN, MAKELPARAM(ScaleX(FLeftMargin), ScaleX(FRightMargin)))
				End If
				Return
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC, message.wParam)
				SetBkMode Dc, TRANSPARENT
				SetTextColor Dc, Font.Color
				SetBkColor Dc, This.BackColor
				SetBkMode Dc, OPAQUE
			Case CM_COMMAND
				Select Case message.wParamHi
				Case BN_CLICKED
					If OnClick Then OnClick(*Designer, This)
				Case EN_CHANGE
					If OnChange Then OnChange(*Designer, This)
				Case EN_UPDATE
					If OnUpdate Then OnUpdate(*Designer, This, This.Text)
				Case EN_KILLFOCUS
					If OnLostFocus Then OnLostFocus(*Designer, This)
				Case EN_SETFOCUS
					If OnGotFocus Then OnGotFocus(*Designer, This)
				Case EN_VSCROLL
					If OnScroll Then OnScroll(*Designer, This)
				Case EN_HSCROLL
					If OnScroll Then OnScroll(*Designer, This)
				End Select
				message.Result = 0
			Case WM_CHAR
				If Len(*FInputFilter)>0 Then
					If InStr(*FInputFilter,WChr(message.wParam))=0 And message.wParam>31 Then message.Result = -1
				End If
			Case WM_KEYUP
				'David Change
				'bShift = GetKeyState(VK_SHIFT) And 8000
				'bCtrl = GetKeyState(VK_CONTROL) And 8000
				If WantTab Then
					If message.wParam = VK_TAB Then
						SelText = !"\t"
					End If
				End If
				If message.wParam = VK_RETURN Then
					If OnActivate Then OnActivate(*Designer, This)
				End If
				If ParentHandle>0 Then
					Select Case message.wParam
					Case VK_RETURN, VK_ESCAPE, VK_DOWN, VK_UP, VK_LEFT, VK_RIGHT, VK_TAB
						PostMessage(ParentHandle, CM_COMMAND, message.wParam, 9999)
						'case VK_HOME,VK_END,VK_PRIOR,VK_NEXT,VK_INSERT,VK_DELETE,VK_BACK
						'case VK_MENU 'VK_CONTROL VK_SHIFT
						'print "TextBox VK_MENU: ",VK_MENU
						'case else
					End Select
				End If
			Case WM_SETFOCUS
				''David Change
				'If Handle Then
				'	If This.SelText Then
				'		SendMessage Handle, EM_SETSEL, 0, -1
				'	Else
				'		SendMessage Handle, EM_SETSEL, -1, 0
				'	End If
				'End If
			Case WM_CUT
				If OnCut Then OnCut(*Designer, This)
			Case WM_COPY
				If OnCopy Then OnCopy(*Designer, This)
			Case WM_PASTE
				Dim Action As Integer = 1
				If OnPaste Then OnPaste(*Designer, This, Action)
				Select Case Action
				Case 0: message.Result = -1
				Case 1: message.Result = 0
				End Select
			End Select
		Base.ProcessMessage(message)
	End Sub
	
	Private Sub TextBox.Clear
		Text = ""
	End Sub
	
	Private Sub TextBox.ClearUndo
			If FHandle Then Perform(EM_EMPTYUNDOBUFFER, 0, 0)
	End Sub
	
	Private Function TextBox.CanUndo As Boolean
			If FHandle Then
				Return (Perform(EM_CANUNDO, 0, 0) <> 0)
			Else
				Return 0
			End If
	End Function
	
	Private Sub TextBox.Undo
			If FHandle Then Perform(WM_UNDO, 0, 0)
	End Sub
	
	Private Sub TextBox.PasteFromClipboard
			If FHandle Then Perform(WM_PASTE, 0, 0)
	End Sub
	
	Private Sub TextBox.CopyToClipboard
			If FHandle Then Perform(WM_COPY, 0, 0)
	End Sub
	
	Private Sub TextBox.CutToClipboard
			If FHandle Then Perform(WM_CUT, 0, 0)
	End Sub
	
	Private Sub TextBox.SelectAll
			If FHandle Then Perform(EM_SETSEL, 0, -1)
	End Sub
	
	Private Operator TextBox.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	
	Private Constructor TextBox
			ACharCase(0)      = 0
			ACharCase(1)      = ES_UPPERCASE
			ACharCase(2)      = ES_LOWERCASE
			AMaskStyle(0)     = 0
			AMaskStyle(1)     = ES_PASSWORD
			ABorderExStyle(0) = 0
			ABorderExStyle(1) = WS_EX_CLIENTEDGE
			ABorderStyle(0)   = 0
			ABorderStyle(1)   = WS_BORDER
			AOEMConvert(0)    = 0
			AOEMConvert(1)    = ES_OEMCONVERT
			AHideSelection(0) = ES_NOHIDESEL
			AHideSelection(1) = 0
		FBorderStyle      = 1
		FHideSelection    = 1
		FCtl3D            = True
		WLet(FMaskChar, "")
		FText_ = ""
		FText_.m_Owner = @This
		FText_.OnChange = @OnTextChanged
			'FMaxLength          = 64000
		FEnabled = True
		FTabIndex          = -1
		FWantReturn        = True
		FTabStop = True
		With This
				.OnHandleIsAllocated = @HandleIsAllocated
				.ChildProc   = @WndProc
				.ExStyle     = WS_EX_CLIENTEDGE ' OR ES_AUTOHSCROLL OR ES_AUTOVSCROLL
				.Style       = WS_CHILD Or ES_AUTOHSCROLL Or WS_TABSTOP Or ES_WANTRETURN Or ACharCase(abs_(FCharCase)) Or AMaskStyle(abs_(FMasked)) Or AOEMConvert(abs_(FOEMConvert)) Or AHideSelection(abs_(FHideSelection))
				.BackColor        = GetSysColor(COLOR_WINDOW)
				FDefaultBackColor = .BackColor
				.DoubleBuffered = True
				.RegisterClass "TextBox", "Edit"
				WLet(FClassAncestor, "Edit")
			WLet(FClassName, "TextBox")
			.Child       = @This
			.Width       = 121
			.Height      = ScaleY(Font.Size / 72 * 96 + 6) '21
			'.Cursor      = LoadCursor(NULL, IDC_IBEAM)
		End With
	End Constructor
	
	Private Destructor TextBox
		If FSelText <> 0 Then _Deallocate(FSelText)
		If FLine <> 0 Then _Deallocate(FLine)
		If FMaskChar <> 0 Then _Deallocate(FMaskChar)
		FText = ""
	End Destructor
End Namespace



