'###############################################################################
'#  CheckedListBox.bi                                                          #
'#  This file is part of MyFBFramework                                         #
'#  Based on:                                                                  #
'#   TListBox.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Modified by Xusinboy Bekchanov (2018-2019)                                 #
'###############################################################################

#include once "CheckedListBox.bi"
	#include once "win\tmschema.bi"

Namespace My.Sys.Forms
		Private Function CheckedListBox.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function CheckedListBox.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Sub CheckedListBox.AddItem(ByRef FItem As WString, Obj As Any Ptr = 0)
		Dim i As Integer
		If FSort Then
			For i = 0 To Items.Count - 1
				If Items.Item(i) > FItem Then Exit For
			Next
			Items.Insert i, FItem, Obj
			FNewIndex = i
		Else
			Items.Add(FItem, Obj)
			FNewIndex = Items.Count - 1
		End If
			If Handle Then Perform(LB_ADDSTRING, 0, CInt(@FItem))
	End Sub
	
	Private Sub CheckedListBox.InsertItem(FIndex As Integer, ByRef FItem As WString, Obj As Any Ptr = 0)
		If FSort Then
			AddItem FItem, Obj
			Exit Sub
		End If
		Items.Insert(FIndex, FItem, Obj)
		FNewIndex = FIndex
			If Handle Then Perform(LB_INSERTSTRING, FIndex, CInt(@FItem))
	End Sub
	
	Private Property CheckedListBox.Checked(Index As Integer) As Boolean
			If Handle Then Return Perform(LB_GETITEMDATA, Index, 0)
	End Property
	
	Private Property CheckedListBox.Checked(Index As Integer, Value As Boolean)
			If Handle Then 
				Perform(LB_SETITEMDATA, Index, abs_(Value))
				If Value AndAlso FRadioCheck Then
					For i As Integer = 0 To Items.Count - 1
						If i = Index Then Continue For
						Perform(LB_SETITEMDATA, i, 0)
					Next
				End If
			End If
	End Property
	
	Private Property CheckedListBox.RadioCheck As Boolean
		Return FRadioCheck
	End Property
	
	Private Property CheckedListBox.RadioCheck(Value As Boolean)
		FRadioCheck = Value
	End Property
	
		Private Sub CheckedListBox.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QCheckedListBox(Sender.Child)
					For i As Integer = 0 To .Items.Count -1
						Dim As WString Ptr s = _CAllocate((Len(.Items.Item(i)) + 1) * SizeOf(WString))
						*s = .Items.Item(i)
						.Perform(LB_ADDSTRING, 0, CInt(s))
					Next i
					'.Perform(LB_SETITEMHEIGHT, 0, MAKELPARAM(ScaleY(.ItemHeight), 0))
					.MultiColumn = .MultiColumn
					.ItemIndex = .ItemIndex
					If .SelectionMode = SelectionModes.smMultiSimple Or .SelectionMode = SelectionModes.smMultiExtended Then
						For i As Integer = 0 To .SelCount -1
							.Perform(LB_SETSEL, 1, .SelItems[i])
						Next i
					End If
					.TopIndex = .FTopIndex
				End With
			End If
		End Sub
	
		Private Sub CheckedListBox.WNDPROC(ByRef Message As Message)
		End Sub
		
		Private Sub CheckedListBox.ProcessMessage(ByRef Message As Message)
			Dim pt As ..Point, rc As ..Rect, t As Long, itd As Long
			Select Case Message.Msg
			Case CM_DRAWITEM
				Dim lpdis As DRAWITEMSTRUCT Ptr, zTxt As WString Ptr
				Dim As Integer ItemID, State
				lpdis = Cast(DRAWITEMSTRUCT Ptr, Message.lParam)
				If OnDrawItem Then
					OnDrawItem(*Designer, This, lpdis->itemID, lpdis->itemState, *Cast(My.Sys.Drawing.Rect Ptr, @lpdis->rcItem), lpdis->hDC)
				Else
					If lpdis->itemID = &HFFFFFFFF& Then
						Exit Sub
					EndIf
					Select Case lpdis->itemAction
					Case ODA_DRAWENTIRE, ODA_SELECT
						'DRAW BACKGROUND
						FillRect lpdis->hDC, @lpdis->rcItem, Brush.Handle 'GetSysColorBrush(COLOR_WINDOW)
						If (lpdis->itemState And ODS_SELECTED)   Then                       'if selected Then
							rc.Left   = lpdis->rcItem.Left + ScaleX(16): rc.Right = lpdis->rcItem.Right              '  Set cordinates
							rc.Top    = lpdis->rcItem.Top
							rc.Bottom = lpdis->rcItem.Bottom
							FillRect lpdis->hDC, @rc, GetSysColorBrush(COLOR_HIGHLIGHT)
							SetBkColor lpdis->hDC, GetSysColor(COLOR_HIGHLIGHT)                    'Set text Background
							SetTextColor lpdis->hDC, GetSysColor(COLOR_HIGHLIGHTTEXT)                'Set text color
							'If ItemIndex = lpdis->itemID AndAlso Focused Then
							If Focused AndAlso lpdis->itemAction = ODA_SELECT Then
								'DrawFocusRect lpdis->hDC, @rc  'draw focus rectangle
							End If
						Else
							FillRect lpdis->hDC, @lpdis->rcItem, Brush.Handle ' GetSysColorBrush(COLOR_WINDOW)
							SetBkColor lpdis->hDC, Brush.Color 'GetSysColor(COLOR_WINDOW)                    'Set text Background
							SetTextColor lpdis->hDC, GetSysColor(COLOR_WINDOWTEXT)                'Set text color
							If CInt(ItemIndex = -1) AndAlso CInt(lpdis->itemID = 0) AndAlso CInt(Focused) Then
								rc.Left   = lpdis->rcItem.Left + ScaleX(16) : rc.Right = lpdis->rcItem.Right              '  Set cordinates
								rc.Top    = lpdis->rcItem.Top
								rc.Bottom = lpdis->rcItem.Bottom
								'DrawFocusRect lpdis->hDC, @rc  'draw focus rectangle
							End If
						End If
						'DRAW TEXT
						WLet(zTxt, Item(lpdis->itemID))
						'SendMessage Message.hWnd, LB_GETTEXT, lpdis->itemID, Cast(LPARAM, @zTxt)                  'Get text
						TextOut lpdis->hDC, lpdis->rcItem.Left + ScaleX(18), lpdis->rcItem.Top + ScaleY(2), zTxt, Len(*zTxt)     'Draw text
						WDeAllocate(zTxt)
						'DRAW CHECKBOX
						rc.Left   = lpdis->rcItem.Left + ScaleX(2): rc.Right = lpdis->rcItem.Left + ScaleX(15)               'Set cordinates
						rc.Top    = lpdis->rcItem.Top + ScaleY(2)
						rc.Bottom = lpdis->rcItem.Bottom - ScaleY(1)
						fTheme = OpenThemeData(FHandle, "BUTTON")
						If fTheme Then
							If SendMessage(Message.hWnd, LB_GETITEMDATA, lpdis->itemID, 0) Then 'checked or not? itemdata knows Then
								DrawThemeBackground(fTheme, lpdis->hDC, IIf(FRadioCheck, BP_RADIOBUTTON, BP_CHECKBOX), CBS_CHECKEDNORMAL, @rc, 0)
							Else
								DrawThemeBackground(fTheme, lpdis->hDC, IIf(FRadioCheck, BP_RADIOBUTTON, BP_CHECKBOX), CBS_UNCHECKEDNORMAL, @rc, 0)
							End If
						Else
							If SendMessage(Message.hWnd, LB_GETITEMDATA, lpdis->itemID, 0) Then 'checked or not? itemdata knows Then
								DrawFrameControl lpdis->hDC, @rc, DFC_BUTTON, IIf(FRadioCheck, DFCS_BUTTONRADIO, DFCS_BUTTONCHECK) Or DFCS_CHECKED
							Else
								DrawFrameControl lpdis->hDC, @rc, DFC_BUTTON, IIf(FRadioCheck, DFCS_BUTTONRADIO, DFCS_BUTTONCHECK)
							End If
						End If
						CloseThemeData(fTheme)
						Message.Result = True : Exit Sub
					Case ODA_FOCUS
						'DrawFocusRect lpdis->hDC, @lpdis->rcItem  'draw focus rectangle
						Message.Result = True : Exit Sub
					End Select
				End If
			Case WM_LBUTTONDOWN
				If Message.wParam = MK_LBUTTON  Then                                            'respond to mouse click
					pt.X = LoWord(Message.lParam) : pt.Y = HiWord(Message.lParam)                       'get cursor pos
					t = SendMessage(Message.hWnd, LB_ITEMFROMPOINT, 0, MAKELONG(pt.X, pt.Y))    'get sel. item
					SendMessage Message.hWnd, LB_GETITEMRECT, t, Cast(LPARAM, @rc)                            'get sel. item's rect
					rc.Left   = rc.Left + 2 : rc.Right = rc.Left + ScaleX(15)                                      'checkbox cordinates
					If PtInRect(@rc, pt) Then
						If FRadioCheck Then
							SendMessage Message.hWnd, LB_SETITEMDATA, t, 1                            'set toggled item data
							For i As Integer = 0 To Items.Count - 1
								If i = t Then Continue For
								SendMessage Message.hWnd, LB_SETITEMDATA, i, 0                      'set toggled item data
							Next
						Else
							itd = Not CBool(SendMessage(Message.hWnd, LB_GETITEMDATA, t, 0))                 'get toggled item data
							SendMessage Message.hWnd, LB_SETITEMDATA, t, itd                            'set toggled item data
						End If
						InvalidateRect Message.hWnd, @rc, 0 : UpdateWindow Message.hWnd                     'update sel. item only
					End If
				End If
'			Case WM_PAINT
'				'Message.Result = 0
'			Case CM_CTLCOLOR
'				Static As HDC Dc
'				Dc = Cast(HDC,Message.wParam)
'				SetBKMode Dc, TRANSPARENT
'				SetTextColor Dc, Font.Color
'				SetBKColor Dc, This.BackColor
'				SetBKMode Dc, OPAQUE
'			Case CM_COMMAND
'				Select Case Message.wParamHi
'				Case LBN_SELCHANGE
'					If SelectionMode = SelectionModes.smMultiSimple Or SelectionMode = SelectionModes.smMultiExtended Then
'						FSelCount = Perform(LB_GETSELCOUNT,0,0)
'						If FSelCount Then
'							Dim As Integer AItems(FSelCount)
'							Perform(LB_GETSELITEMS,FSelCount,CInt(@AItems(0)))
'							SelItems = @AItems(0)
'						End If
'					End If
'					If OnChange Then OnChange(This)
'				Case LBN_DBLCLK
'					If OnDblClick Then OnDblClick(This)
'				End Select
'			Case CM_MEASUREITEM
'				Dim As MEASUREITEMSTRUCT Ptr miStruct
'				Dim As Integer ItemID
'				miStruct = Cast(MEASUREITEMSTRUCT Ptr,Message.lParam)
'				ItemID = Cast(Integer,miStruct->itemID)
'				If OnMeasureItem Then
'					OnMeasureItem(This,itemID,miStruct->itemHeight)
'				Else
'					miStruct->itemHeight = ItemHeight
'				End If
'			Case CM_DRAWITEM
'				Dim As DRAWITEMSTRUCT Ptr diStruct
'				Dim As Integer ItemID,State
'				Dim As Rect R
'				Dim As HDC Dc
'				diStruct = Cast(DRAWITEMSTRUCT Ptr,Message.lParam)
'				ItemID = Cast(Integer,diStruct->itemID)
'				State = Cast(Integer,diStruct->itemState)
'				R = Cast(Rect,diStruct->rcItem)
'				Dc = diStruct->hDC
'				If OnDrawItem Then
'					OnDrawItem(This,ItemID,State,R,Dc)
'				Else
'					If (State And ODS_SELECTED) = ODS_SELECTED Then
'						Static As HBRUSH B
'						If B Then DeleteObject B
'						B = CreateSolidBrush(&H800000)
'						FillRect Dc,@R,B
'						R.Left += 2
'						SetTextColor Dc,clHighlightText
'						SetBKColor Dc,&H800000
'						DrawText(Dc,Item(ItemID),Len(Item(ItemID)),@R,DT_SINGLELINE Or DT_VCENTER Or DT_NOPREFIX)
'					Else
'						FillRect Dc, @R, Brush.Handle
'						R.Left += 2
'						SetTextColor Dc, Font.Color
'						SetBKColor Dc, This.BackColor
'						DrawText(Dc,Item(ItemID),Len(Item(ItemID)),@R,DT_SINGLELINE Or DT_VCENTER Or DT_NOPREFIX)
'					End If
'				End If
			Case WM_CHAR
				If Message.wParam = 32 Then Checked(ItemIndex) = FRadioCheck OrElse Not Checked(ItemIndex): This.Repaint
				If OnKeyPress Then OnKeyPress(*Designer, This, LoByte(Message.wParam))
'			Case WM_KEYDOWN
'				If OnKeyDown Then OnKeyDown(This,Message.wParam,Message.wParam And &HFFFF)
'			Case WM_KEYUP
'				If OnKeyUp Then OnKeyUp(This,Message.wParam,Message.wParam And &HFFFF)
			End Select
			Base.ProcessMessage(Message)
		End Sub
	
	
	Private Sub CheckedListBox.SaveToFile(ByRef FileName As WString)
		Dim As Integer F, i, Result
		Dim As WString Ptr s
		F = FreeFile_
		Result = Open(FileName For Output Encoding "utf-8" As #F)
		If Result = 0 Then
			For i = 0 To ItemCount - 1
					Dim TextLen As Integer = Perform(LB_GETTEXTLEN, i, 0)
					s = _CAllocate((Len(TextLen) + 1) * SizeOf(WString))
					*s = Space(TextLen)
					Perform(LB_GETTEXT, i, CInt(s))
					Print #F, *s
			Next i
			CloseFile_(F)
		End If
		_Deallocate(s)
	End Sub

	Private Sub CheckedListBox.LoadFromFile(ByRef FileName As WString)
		Dim As Integer F, i, Result
		Dim As WString * 1024 s
		F = FreeFile_
		This.Clear
		Result = Open(FileName For Input Encoding "utf-8" As #F)
		If Result = 0 Then
		While Not EOF(F)
			Line Input #F, s
				Perform(LB_ADDSTRING, 0, CInt(@s))
		Wend
			CloseFile_(F)
		End If
	End Sub
	
	
	Private Constructor CheckedListBox
		FCtl3D             = False
		Base.FBorderStyle       = 1
		FTabIndex          = -1
		FTabStop           = True
		'Items.Parent       = @This
		With This
			WLet(FClassName, "CheckedListBox")
			WLet(FClassAncestor, "ListBox")
			.Child       = @This
				.RegisterClass "CheckedListBox", "ListBox"
				.ChildProc   = @WNDPROC
				.ExStyle     = WS_EX_CLIENTEDGE
				Base.Base.Style       = WS_CHILD Or WS_VSCROLL Or WS_HSCROLL Or LBS_HASSTRINGS Or LBS_NOTIFY Or LBS_DISABLENOSCROLL Or LBS_OWNERDRAWFIXED
				.BackColor       = GetSysColor(COLOR_WINDOW)
				.OnHandleIsAllocated = @HandleIsAllocated
				.DoubleBuffered = True
			.Width       = 121
			.Height      = 17
		End With
	End Constructor
	
	Private Destructor CheckedListBox
		'If Items Then DeAllocate Items
	End Destructor
End Namespace

