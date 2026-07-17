'###############################################################################
'#  TabControl.bi                                                              #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TTabControl.bi                                                            #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "TabControl.bi"

Namespace My.Sys.Forms
		Private Function TabPage.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "parent": Return FParent
			Case "text": Return FCaption
			Case "caption": Return FCaption
			Case "usevisualstylebackcolor": Return @UseVisualStyleBackColor
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function TabPage.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case "parent": This.Parent = Value
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "parent": If *Cast(My.Sys.Object Ptr, Value) Is TabControl Then This.Parent = Cast(TabControl Ptr, Value)
				Case "text": This.Text = QWString(Value)
				Case "caption": This.Caption = QWString(Value)
				Case "usevisualstylebackcolor": This.UseVisualStyleBackColor = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property TabControl.GroupName ByRef As WString
		If FGroupName > 0 Then Return *FGroupName Else Return WStr("")
	End Property
	
	Private Property TabControl.GroupName(ByRef Value As WString)
		WLet(FGroupName, Value)
	End Property
	
		Private Sub TabPage.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QTabPage(Sender.Child)
					If .UseVisualStyleBackColor Then
						SetWindowTheme(.Handle, NULL, "TAB")
					End If
					.FTheme = OpenThemeData(.Handle, "Window")
				End With
			End If
		End Sub
	
	Private Sub TabPage.ProcessMessage(ByRef msg As Message)
			'FTheme = GetWindowTheme(Msg.hWnd)
			Dim As ..Rect rct
			Select Case msg.Msg
			Case WM_DESTROY
				CloseThemeData(FTheme)
			Case WM_CTLCOLORSTATIC ', WM_CTLCOLORBTN
			Case WM_PAINT
			Case WM_ERASEBKGND
			Case WM_PRINTCLIENT
				'Case WM_PAINT, WM_ERASEBKGND
				'	    		Dim As PAINTSTRUCT ps
				'				Dim As HDC hdc = BeginPaint(msg.hwnd, @ps)
				'	    		Dim As RECT rcWin
				'				Dim As RECT rcWnd
				'				Dim As HWND parWnd = GetParent(msg.hwnd)
				'				Dim As HDC parDc = GetDC(parWnd)
				'				GetWindowRect(msg.hwnd, @rcWnd)
				'				ScreenToClient(parWnd, @rcWnd)
				'				GetClipBox(hdc, @rcWin )
				'	    		BitBlt(hdc, rcWin.left, rcWin.top, rcWin.right - rcWin.left, rcWin.bottom - rcWin.top, parDC, rcWnd.left, rcWnd.top, SRC_COPY)
				'				ReleaseDC(parWnd, parDC)
				'				EndPaint(msg.hwnd, @ps)
				'EnableThemeDialogTexture(msg.hwnd, ETDT_ENABLETAB)
			End Select
		Base.ProcessMessage(msg)
	End Sub
	
	Private Property TabPage.Index As Integer
		If This.Parent AndAlso *Base.Parent Is TabControl Then
			Return Cast(TabControl Ptr, This.Parent)->IndexOfTab(@This)
		End If
		Return -1
	End Property
	
	Private Sub TabPage.Update()
		If This.Parent AndAlso *Base.Parent Is TabControl Then
				If This.Parent->Handle Then
					Dim As TCITEM Ti
					Ti.mask = TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
					Ti.pszText = FCaption
					Ti.cchTextMax = Len(*FCaption) + 1
					If FObject Then Ti.lParam = Cast(LPARAM, FObject)
					If Cast(TabControl Ptr, This.Parent)->Images AndAlso FImageKey <> 0 Then
						Ti.iImage = Cast(TabControl Ptr, This.Parent)->Images->IndexOf(*FImageKey)
					Else
						Ti.iImage = FImageIndex
					End If
					This.Parent->Perform(TCM_SETITEM, Index, CInt(@Ti))
					Ti.lParam = 0
				End If
		End If
	End Sub
	
	Private Sub TabPage.SelectTab()
		If This.Parent AndAlso *Base.Parent Is TabControl Then
			Cast(TabControl Ptr, This.Parent)->SelectedTabIndex = Index
		End If
	End Sub
	
	Private Function TabPage.IsSelected() As Boolean
		If This.Parent AndAlso *Base.Parent Is TabControl Then
			Return Cast(TabControl Ptr, This.Parent)->SelectedTabIndex = Index
		End If
		Return False
	End Function
	
	Private Property TabPage.Caption ByRef As WString
		Return This.Text
	End Property
	
	Private Property TabPage.Caption(ByRef Value As WString)
		This.Text = Value
	End Property
	
	Private Property TabPage.Text ByRef As WString
		Return *FCaption
	End Property
	
	Private Property TabPage.Text(ByRef Value As WString)
		WLet(FCaption, Value)
			Update
	End Property
	
		Private Property TabPage.Parent As TabControl Ptr
			Return Cast(TabControl Ptr, FParent)
		End Property
		
		Private Property TabPage.Parent(Value As TabControl Ptr)
			If FParent AndAlso Value AndAlso FParent <> Value Then
				Dim As Boolean bDynamic = FDynamic
				FDynamic = False
				Cast(TabControl Ptr, FParent)->DeleteTab(@This)
				FDynamic = bDynamic
			End If
			FParent = Value
			If Value Then Value->AddTab(@This)
		End Property
	
	Private Property TabPage.Object As Any Ptr
		Return FObject
	End Property
	
	Private Property TabPage.Object(Value As Any Ptr)
		FObject = Value
		Update
	End Property
	
	Private Property TabPage.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property TabPage.ImageIndex(Value As Integer)
		FImageIndex = Value
		Update
	End Property
	
	Private Property TabPage.ImageKey ByRef As WString
		If FImageKey > 0 Then Return *FImageKey Else Return WStr("")
	End Property
	
	Private Property TabPage.ImageKey(ByRef Value As WString)
		WLet(FImageKey, Value)
			Update
	End Property
	
	Property TabPage.Visible As Boolean
		Return Base.Visible
	End Property
	
	Property TabPage.Visible(Value As Boolean)
		If FVisible <> Value Then
			FVisible = Value
			If Value Then
'					Dim As TCITEMW Ti
'					Dim As Integer LenSt = Len(Caption) + 1
'					Dim As WString Ptr St = CAllocate_(LenSt * Len(WString))
'					St = @Caption
'					Ti.mask = TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
'					Ti.pszText    = St
'					Ti.cchTextMax = LenSt
'					If Tabs[FTabCount - 1]->Object Then Ti.lParam = Cast(LPARAM, Tabs[FTabCount - 1]->Object)
'					Ti.iImage = Tabs[FTabCount - 1]->ImageIndex
'					SendMessageW(FHandle, TCM_INSERTITEMW, FTabCount - 1, CInt(@Ti))
			Else
					'Perform(TCM_DELETEITEM, Index, 0)
			End If
		End If
		Base.Visible = Value
	End Property
	
	Private Operator TabPage.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Operator TabPage.Let(ByRef Value As WString)
		Caption = Value
	End Operator
	
	Private Operator TabPage.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor TabPage
		FObject    = 0
		FImageIndex        = 0
		'Anchor.Left = asAnchor
		'Anchor.Top = asAnchor
		'Anchor.Right = asAnchor
		'Anchor.Bottom = asAnchor
		Caption = " "
		Text    = " "
		WLet(FClassName, "TabPage")
		WLet(FClassAncestor, "Panel")
		Child = @This
			Align = DockStyle.alClient
			Base.Style = WS_CHILD Or DS_SETFOREGROUND
			This.OnHandleIsAllocated = @HandleIsAllocated
			This.RegisterClass "TabPage", "Panel"
	End Constructor
	
	Private Destructor TabPage
		'If FParent <> 0 Then Parent->DeleteTab(Parent->IndexOf(@This))
		If FCaption Then _Deallocate(FCaption)
		If FImageKey Then _Deallocate(FImageKey)
	End Destructor
	
		Private Function TabControl.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case "selectedtabindex": Return @FSelectedTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function TabControl.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "selectedtabindex": This.SelectedTabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property TabControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TabControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TabControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TabControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property TabPage.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TabPage.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TabPage.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TabPage.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property TabControl.SelectedTabIndex As Integer
			Return Perform(TCM_GETCURSEL,0,0)
	End Property
	
	Private Property TabControl.SelectedTabIndex(Value As Integer)
		FSelectedTabIndex = Value
			If Handle Then
				Perform(TCM_SETCURSEL,FSelectedTabIndex,0)
				Dim Id As Integer = SelectedTabIndex
				For i As Integer = 0 To TabCount - 1
					Tabs[i]->Visible = i = Id
					If FDesignMode Then
						ShowWindow(Tabs[i]->Handle, abs_(i = Id))
						If i <> Id Then SetWindowPos Tabs[i]->Handle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
					End If
				Next i
				RequestAlign
				If OnSelChange Then OnSelChange(*Designer, This, Id)
			End If
	End Property
	
	Private Sub TabControl.SetMargins()
		Select Case FTabPosition
		Case 0: Base.SetMargins 4 + ItemWidth(0), 2, 4, 3
		Case 1: Base.SetMargins 2, 2, 4 + ItemWidth(0), 3
		Case 2: Base.SetMargins 2, 4 + ItemHeight(0), 4, 3
		Case 3: Base.SetMargins 2, 2, 2, 4 + ItemHeight(0)
		End Select
	End Sub
	
		Private Sub TabControl.RefreshHorizontalTabLabels()
			If FHandle = 0 OrElse FTabPosition <> tpTop Then Return
			Dim bRecoverFromVertical As Boolean = False
			If (Style And TCS_VERTICAL) = TCS_VERTICAL Then bRecoverFromVertical = True
			If (Style And TCS_OWNERDRAWFIXED) = TCS_OWNERDRAWFIXED AndAlso FTabStyle <> tsOwnerDrawFixed Then bRecoverFromVertical = True
			ChangeStyle(TCS_BOTTOM, False)
			ChangeStyle(TCS_RIGHT, False)
			ChangeStyle(TCS_VERTICAL, False)
			If Not FTabStyle = tsOwnerDrawFixed Then ChangeStyle(TCS_OWNERDRAWFIXED, False)
			If Not FMultiline Then ChangeStyle(TCS_MULTILINE, False)
			If bRecoverFromVertical Then Perform(TCM_SETITEMSIZE, 0, 0)
			For i As Integer = 0 To TabCount - 1
				If Tabs[i] Then Tabs[i]->Update()
			Next
			SetWindowPos(FHandle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_FRAMECHANGED)
			InvalidateRect(FHandle, NULL, TRUE)
			SetMargins
		End Sub
	
	Private Property TabControl.TabPosition As My.Sys.Forms.TabPosition
		Return FTabPosition
	End Property
	
	Private Property TabControl.TabPosition(Value As My.Sys.Forms.TabPosition)
			Dim As My.Sys.Forms.TabPosition oldPosition = FTabPosition
		FTabPosition = Value
			Select Case FTabPosition
			Case 0
				ChangeStyle(TCS_BOTTOM, False)
				ChangeStyle(TCS_RIGHT, False)
				ChangeStyle(TCS_MULTILINE, True)
				ChangeStyle(TCS_VERTICAL, True)
				ChangeStyle(TCS_OWNERDRAWFIXED, True)
			Case 1
				ChangeStyle(TCS_BOTTOM, False)
				ChangeStyle(TCS_MULTILINE, True)
				ChangeStyle(TCS_VERTICAL, True)
				ChangeStyle(TCS_RIGHT, True)
				ChangeStyle(TCS_OWNERDRAWFIXED, True)
			Case 2
				ChangeStyle(TCS_BOTTOM, False)
				ChangeStyle(TCS_RIGHT, False)
				ChangeStyle(TCS_VERTICAL, False)
				ChangeStyle(TCS_OWNERDRAWFIXED, False)
				If Not FMultiline Then ChangeStyle(TCS_MULTILINE, False)
			Case 3
				ChangeStyle(TCS_RIGHT, False)
				ChangeStyle(TCS_VERTICAL, False)
				ChangeStyle(TCS_BOTTOM, True)
				If Not FMultiline Then ChangeStyle(TCS_MULTILINE, False)
				If Not FTabStyle = tsOwnerDrawFixed Then ChangeStyle(TCS_OWNERDRAWFIXED, False)
			End Select
			If FHandle Then
				If (oldPosition = tpLeft OrElse oldPosition = tpRight) AndAlso (FTabPosition = tpTop OrElse FTabPosition = tpBottom) Then
					Perform(TCM_SETITEMSIZE, 0, 0)
					For i As Integer = 0 To TabCount - 1
						If Tabs[i] Then Tabs[i]->Update()
					Next
				End If
				SetWindowPos(FHandle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_FRAMECHANGED)
				InvalidateRect(FHandle, NULL, TRUE)
			End If
		SetMargins
	End Property
	
	Private Property TabControl.TabStyle As My.Sys.Forms.TabStyle
		Return FTabStyle
	End Property
	
	Private Property TabControl.TabStyle(Value As My.Sys.Forms.TabStyle)
		FTabStyle = Value
			Select Case FTabStyle
			Case 0
				ChangeStyle TCS_BUTTONS, False
				ChangeStyle TCS_OWNERDRAWFIXED, False
				ChangeStyle TCS_TABS, True
			Case 1
				ChangeStyle TCS_TABS, False
				ChangeStyle TCS_OWNERDRAWFIXED, False
				ChangeStyle TCS_BUTTONS, True
			Case 2
				ChangeStyle TCS_TABS, False
				ChangeStyle TCS_BUTTONS, False
				ChangeStyle TCS_OWNERDRAWFIXED, True
			End Select
	End Property
	
	Private Property TabControl.FlatButtons As Boolean
		Return FFlatButtons
	End Property
	
	Private Property TabControl.FlatButtons(Value As Boolean)
		FFlatButtons = Value
			Select Case FFlatButtons
			Case True
				If (Style And TCS_FLATBUTTONS) <> TCS_FLATBUTTONS Then
					Style = Style Or TCS_FLATBUTTONS
				End If
			Case False
				If (Style And TCS_FLATBUTTONS) = TCS_FLATBUTTONS Then
					Style = Style And Not TCS_FLATBUTTONS
				End If
			End Select
		'RecreateWnd
	End Property
	
	Private Property TabControl.Multiline As Boolean
		Return FMultiline
	End Property
	
	Private Property TabControl.Multiline(Value As Boolean)
		FMultiline = Value
			Select Case FMultiline
			Case False
				If (Style And TCS_MULTILINE) = TCS_MULTILINE Then
					Style = Style And Not TCS_MULTILINE
				End If
				If (Style And TCS_SINGLELINE) <> TCS_SINGLELINE Then
					Style = Style Or TCS_SINGLELINE
				End If
			Case True
				If (Style And TCS_MULTILINE) <> TCS_MULTILINE Then
					Style = Style Or TCS_MULTILINE
				End If
				If (Style And TCS_SINGLELINE) = TCS_SINGLELINE Then
					Style = Style And Not TCS_SINGLELINE
				End If
			End Select
		RecreateWnd
	End Property
	
	Private Property TabControl.Reorderable As Boolean
		Return FReorderable
	End Property
	
	Private Property TabControl.Reorderable(Value As Boolean)
		FReorderable = Value
	End Property
	
	Private Property TabControl.Detachable As Boolean
		Return FDetachable
	End Property
	
	Private Property TabControl.Detachable(Value As Boolean)
		FDetachable = Value
	End Property
	
	Private Property TabControl.TabCount As Integer
			If Handle Then
				FTabCount = Perform(TCM_GETITEMCOUNT,0,0)
			End If
		Return FTabCount
	End Property
	
	Private Property TabControl.TabCount(Value As Integer)
	End Property
	
	Private Property TabControl.Tab(Index As Integer) As TabPage Ptr
		Return Tabs[Index]
	End Property
	
	Private Property TabControl.Tab(Index As Integer, Value As TabPage Ptr)
	End Property
	
	Private Property TabControl.SelectedTab As TabPage Ptr
		Var Idx = SelectedTabIndex
		If Idx >= 0 AndAlso Idx <= TabCount - 1 Then
			Return Tabs[Idx]
		Else
			Return 0
		End If
	End Property
	
	Private Property TabControl.SelectedTab(Value As TabPage Ptr)
		SelectedTabIndex = IndexOfTab(Value)
	End Property
	
	Private Function TabControl.ItemHeight(Index As Integer) As Integer
		If Index >= 0 And Index < TabCount Then
				Dim As ..Rect R
				Perform(TCM_GETITEMRECT, Index, CInt(@R))
				Return UnScaleY(R.Bottom - R.Top)
		End If
		Return 0
	End Function
	
	Private Function TabControl.ItemWidth(Index As Integer) As Integer
		If Index >= 0 And Index < TabCount Then
				Dim As ..Rect R
				Perform(TCM_GETITEMRECT, Index, CInt(@R))
				Return UnScaleX(R.Right - R.Left)
		End If
		Return 0
	End Function
	
	Private Function TabControl.ItemLeft(Index As Integer) As Integer
		If Index >= 0 And Index < TabCount Then
				Dim As ..Rect R
				Perform(TCM_GETITEMRECT, Index, CInt(@R))
				Return UnScaleX(R.Left)
		End If
		Return 0
	End Function
	
	Private Function TabControl.ItemTop(Index As Integer) As Integer
		If Index >= 0 And Index < TabCount Then
				Dim As ..Rect R
				Perform(TCM_GETITEMRECT, Index, CInt(@R))
				Return UnScaleY(R.Top)
		End If
		Return 0
	End Function
	
		Private Sub TabControl.WndProc(ByRef Message As Message)
		End Sub
		
		Private Sub TabControl.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QTabControl(Sender.Child)
					If .Images Then .Images->ParentWindow = @Sender
					If .Images AndAlso .Images->Handle Then .Perform(TCM_SETIMAGELIST, 0, CInt(.Images->Handle))
					For i As Integer = 0 To .FTabCount - 1
						Dim As TCITEMW Ti
						Ti.mask = TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
						Ti.pszText    = @(.Tabs[i]->Caption)
						Ti.cchTextMax = Len(.Tabs[i]->Caption) + 1
						If .Images AndAlso .Tabs[i]->ImageKey <> "" Then
							Ti.iImage = .Images->IndexOf(.Tabs[i]->ImageKey)
						Else
							Ti.iImage = .Tabs[i]->ImageIndex
						End If
						Ti.lParam = 0
						If .Tabs[i]->Object Then Ti.lParam = Cast(LPARAM, .Tabs[i]->Object)
						'Ti.lParam = Cast(LPARAM, .Handle)
						.Perform(TCM_INSERTITEM, i, CInt(@Ti))
						.SetTabPageIndex(.Tabs[i], i)
						Ti.lParam = 0
						'EnableThemeDialogTexture(.Tabs[i]->Handle, ETDT_ENABLETAB)
						.SetMargins
					Next
					.TabPosition = .FTabPosition
					.RequestAlign
					If .TabCount > 0 Then
						If .FSelectedTabIndex >= 0 AndAlso .FSelectedTabIndex < .TabCount Then
							.SelectedTabIndex = .FSelectedTabIndex
						ElseIf .FSelectedTabIndex = -1 Then
							.SelectedTabIndex = -1
						Else
							.SelectedTabIndex = 0
						End If
					End If
				End With
			End If
		End Sub
		
		Private Function TabControl.GetChildTabControl(ParentHwnd As HWND, X As Integer, Y As Integer) As TabControl Ptr
			Dim Result As HWND = ChildWindowFromPoint(ParentHwnd, Type<..Point>(X, Y))
			If Result = 0 OrElse Result = ParentHwnd Then
				Return 0
			ElseIf GetClassNameOf(Result) = "TabControl" Then
				Dim As TabControl Ptr pTabControl = GetProp(Result, "MFFControl")
				If pTabControl->GroupName = GroupName Then Return pTabControl
			End If
			Dim As ..Rect R
			GetWindowRect Result, @R
			MapWindowPoints 0, ParentHwnd, Cast(..Point Ptr, @R), 2
			Return GetChildTabControl(Result, X - R.Left, Y - R.Top)
		End Function
		
		Function TabControl.HookChildProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			Dim As TabControl Ptr tc = GetProp(hDlg, "MFFControl")
			If tc Then
				Dim Message As Message
				Message = Type(tc, hDlg, uMsg, wParam, lParam, 0, LoWord(wParam), HiWord(wParam), LoWord(lParam), HiWord(lParam), Message.Captured)
				tc->UpDownControl.ProcessMessage(Message)
				If Message.Handled Then
					Return Message.Result
				ElseIf Message.Result = -1 Then
					Return Message.Result
				ElseIf Message.Result = -2 Then
					uMsg = Message.Msg
					wParam = Message.wParam
					lParam = Message.lParam
				ElseIf Message.Result <> 0 Then
					Return Message.Result
				End If
			End If
			Return CallWindowProc(GetProp(hDlg, "@@@@Proc"), hDlg, uMsg, wParam, lParam)
		End Function
	
	Private Sub TabControl.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_PARENTNOTIFY
				Select Case Message.wParamLo
				Case WM_CREATE
					If Message.wParamHi = 1 Then
						Dim h As HWND = Cast(HWND, Message.lParam)
						UpDownControl.Handle = h
						If GetWindowLongPtr(h, GWLP_WNDPROC) <> @HookChildProc Then
							SetProp(h, "MFFControl", This.Child)
							SetProp(h, "@@@@Proc", Cast(..WNDPROC, SetWindowLongPtr(h, GWLP_WNDPROC, CInt(@HookChildProc))))
						End If
					End If
				End Select
			Case WM_DPICHANGED
				If Images Then Images->SetImageSize Images->ImageWidth, Images->ImageHeight, xdpi, ydpi
				If Images AndAlso Images->Handle Then Perform(TCM_SETIMAGELIST, 0, CInt(Images->Handle))
			Case CM_DRAWITEM
				Dim lpdis As DRAWITEMSTRUCT Ptr = Cast(DRAWITEMSTRUCT Ptr, Message.lParam)
				Dim As LOGFONT LogRec
				Dim As HFONT OldFontHandle, NewFontHandle
				Dim hdc As HDC = lpdis->hDC
				If FTabPosition = tpLeft OrElse FTabPosition = tpRight Then
					GetObject Font.Handle, SizeOf(LogRec), @LogRec
					LogRec.lfEscapement = 90 * 10
					NewFontHandle = CreateFontIndirect(@LogRec)
					OldFontHandle = SelectObject(hdc, NewFontHandle)
					SetBkMode(hdc, TRANSPARENT)
					For i As Integer = 0 To TabCount - 1
						.TextOut(hdc, IIf(FTabPosition = tpLeft, ScaleX(2), ScaleX(This.Width - ItemWidth(i))), ScaleY(ItemTop(i) + ItemHeight(i) - 5), Tabs[i]->Caption, Len(Tabs[i]->Caption))
					Next i
					SetBkMode(hdc, OPAQUE)
					NewFontHandle = SelectObject(hdc, OldFontHandle)
					DeleteObject(NewFontHandle)
				Else
					Dim i As Integer = lpdis->itemID
					If i >= 0 AndAlso i < TabCount Then
						OldFontHandle = SelectObject(hdc, Font.Handle)
						SetBkMode(hdc, TRANSPARENT)
						Dim As ..Rect R = lpdis->rcItem
						If Images Then
							ImageList_Draw(Images->Handle, IIf(Tabs[i]->ImageKey <> "", Images->IndexOf(Tabs[i]->ImageKey), Tabs[i]->ImageIndex), hdc, R.Left + ScaleX(4), R.Top + 2, ILD_TRANSPARENT)
							.TextOut(hdc, R.Left + ScaleX(10) + ScaleX(Images->ImageWidth), R.Top + ScaleY(3), Tabs[i]->Caption, Len(Tabs[i]->Caption))
						Else
							.TextOut(hdc, R.Left + ScaleX(5), R.Top + ScaleY(3), Tabs[i]->Caption, Len(Tabs[i]->Caption))
						End If
						SetBkMode(hdc, OPAQUE)
						SelectObject(hdc, OldFontHandle)
					End If
				End If
				Message.Result = 1
			Case WM_SIZE
			Case WM_DESTROY
				If Images Then Perform(TCM_SETIMAGELIST, 0, 0)
			Case WM_THEMECHANGED
				
			Case WM_ERASEBKGND
			Case WM_PAINT, WM_NCPAINT
			Case WM_LBUTTONDOWN
				DownButton = 0
				FMousePos = Message.lParamLo
				'' Capture only when the drag features that need it are on. Unconditional
				'' capture broke TCS_BUTTONS-style tabs outright: button tabs commit their
				'' click on mouse-UP (classic tabs select on mouse-DOWN, which masked this),
				'' and the unconditional ReleaseCapture below ran before the native control
				'' processed the up-click -- the WM_CAPTURECHANGED that ReleaseCapture
				'' generates cancels the native button-press tracking, so an unselected
				'' button tab never changed the selection.
				If FReorderable OrElse FDetachable Then SetCapture FHandle
			Case WM_LBUTTONUP
				DownButton = -1
				DownTab = 0
				If FReorderable OrElse FDetachable Then ReleaseCapture
			Case WM_MOUSEMOVE
				If CInt(FReorderable) AndAlso CInt(DownButton = 0) Then
					Dim As ..Rect R1, R2, R3
					If DownTab = 0 Then DownTab = SelectedTab
					If DownTab <> 0 Then
						Dim As TabControl Ptr pTabControl = DownTab->Parent
						Dim As My.Sys.Drawing.Point pt = Type<My.Sys.Drawing.Point>(Message.lParamLo, Message.lParamHi)
						ClientToScreen(pt)
						pTabControl->ScreenToClient(pt)
						Var SelTbIndex = DownTab->Index
						pTabControl->Perform(TCM_GETITEMRECT, SelTbIndex, CInt(@R1))
						If pt.X < R1.Left AndAlso SelTbIndex > 0 Then
							pTabControl->Perform(TCM_GETITEMRECT, SelTbIndex - 1, CInt(@R2))
							If pt.X < R2.Left + FMousePos - R1.Left Then
								pTabControl->ReorderTab pTabControl->Tabs[SelTbIndex], SelTbIndex - 1
								pTabControl->Perform(TCM_GETITEMRECT, SelTbIndex - 1, CInt(@R3))
								FMousePos = R3.Left + FMousePos - R1.Left
							End If
						ElseIf pt.X > R1.Right AndAlso SelTbIndex < pTabControl->TabCount - 1 Then
							pTabControl->Perform(TCM_GETITEMRECT, SelTbIndex + 1, CInt(@R2))
							If pt.X > R2.Right - R2.Left + FMousePos - R1.Left Then
								pTabControl->ReorderTab pTabControl->Tabs[SelTbIndex], SelTbIndex + 1
								pTabControl->Perform(TCM_GETITEMRECT, SelTbIndex + 1, CInt(@R3))
								FMousePos = R3.Left + FMousePos - R1.Left
							End If
						End If
					End If
				End If
				If CInt(FDetachable) AndAlso CInt(DownButton = 0) Then
					Dim As ..Rect R1, R2, R3
					Dim As Control Ptr ParentForm = GetForm
					If DownTab = 0 Then DownTab = SelectedTab
					If DownTab <> 0 Then
						If ParentForm <> 0 AndAlso ParentForm->Handle Then
							Dim As Point pt
							GetCursorPos @pt
							..ScreenToClient ParentForm->Handle, @pt
							Dim As TabControl Ptr pTabControl = GetChildTabControl(ParentForm->Handle, pt.X, pt.Y)
							If pTabControl <> 0 AndAlso pTabControl <> DownTab->Parent Then
								DownTab->Parent->Perform(TCM_GETITEMRECT, DownTab->Index, CInt(@R1))
								DownTab->Parent = pTabControl
								DownTab->SelectTab
								pTabControl->Perform(TCM_GETITEMRECT, DownTab->Index, CInt(@R3))
								FMousePos = R3.Left + FMousePos - R1.Left
							End If
						End If
					End If
				End If
			Case CM_COMMAND
			Case CM_NOTIFY
				Dim As LPNMHDR NM
				NM = Cast(LPNMHDR,Message.lParam)
				If NM->code = TCN_SELCHANGE Then
					SelectedTabIndex = SelectedTabIndex
				End If
			Case WM_NCHITTEST
				If FDesignMode Then Exit Sub
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Function TabControl.AddTab(ByRef Caption As WString, aObject As Any Ptr = 0, ImageIndex As Integer = -1) As TabPage Ptr
		FTabCount += 1
		Dim tp As TabPage Ptr = _New( TabPage)
		tp->FDynamic = True
		tp->Caption = Caption
		tp->Object = aObject
		tp->ImageIndex = ImageIndex
		Tabs = _Reallocate(Tabs, SizeOf(TabPage Ptr) * FTabCount)
		Tabs[FTabCount - 1] = tp
			If Handle Then
				Dim As TCITEMW Ti
				Dim As Integer LenSt = Len(Caption) + 1
				Dim As WString Ptr St = _CAllocate(LenSt * Len(WString))
				St = @Caption
				Ti.mask = TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
				Ti.pszText    = St
				Ti.cchTextMax = LenSt
				If Tabs[FTabCount - 1]->Object Then Ti.lParam = Cast(LPARAM, Tabs[FTabCount - 1]->Object)
				Ti.iImage = Tabs[FTabCount - 1]->ImageIndex
				SendMessageW(FHandle, TCM_INSERTITEMW, FTabCount - 1, CInt(@Ti))
				SetTabPageIndex(tp, FTabCount - 1)
				Ti.lParam = 0
			End If
			SetMargins
		This.Add(tp)
		tp->Visible = FTabCount = 1
		If OnTabAdded Then OnTabAdded(*Designer, This, Tabs[FTabCount - 1], FTabCount - 1)
		Return Tabs[FTabCount - 1]
	End Function
	
	Private Function TabControl.AddTab(ByRef Caption As WString, aObject As Any Ptr = 0, ByRef ImageKey As WString) As TabPage Ptr
		Dim tb As TabPage Ptr
		If Images Then
			tb = AddTab(Caption, aObject, Images->IndexOf(ImageKey))
		Else
			tb = AddTab(Caption, aObject, -1)
		End If
		If tb Then tb->ImageKey = ImageKey
		Return tb
	End Function
	
	Private Sub TabControl.AddTab(ByRef tp As TabPage Ptr)
		FTabCount += 1
		'tp->TabPageControl = @This
		Tabs = _Reallocate(Tabs, SizeOf(TabPage Ptr) * FTabCount)
		Tabs[FTabCount - 1] = tp
		If tp->Parent <> 0 AndAlso tp->Parent <> @This Then
			Dim As Boolean bDynamic = tp->FDynamic
			tp->FDynamic = False
			Cast(TabControl Ptr, tp->Parent)->DeleteTab(tp)
			tp->FDynamic = bDynamic
		End If
			If Handle Then
				Dim As TCITEMW Ti
				Dim As WString Ptr St
				WLet(St, tp->Caption)
				Ti.mask = TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
				Ti.pszText    = St
				Ti.cchTextMax = Len(tp->Caption)
				If tp->Object Then Ti.lParam = Cast(LPARAM, tp->Object)
				If tp->ImageKey <> "" AndAlso Images Then
					Ti.iImage = Images->IndexOf(tp->ImageKey)
				Else
					Ti.iImage = tp->ImageIndex
				End If
				SendMessageW(FHandle, TCM_INSERTITEMW, FTabCount - 1, CInt(@Ti))
				SetTabPageIndex(tp, FTabCount - 1)
				Ti.lParam = 0
				WDeAllocate(St)
			End If
			SetMargins
			tp->Visible = FTabCount = 1
		This.Add(Tabs[FTabCount - 1])
		If OnTabAdded Then OnTabAdded(*Designer, This, Tabs[FTabCount - 1], FTabCount - 1)
		Tabs[FTabCount - 1]->SendToBack
	End Sub
	
	Private Sub TabControl.ReorderTab(ByVal tp As TabPage Ptr, Index As Integer, bNoActivate As Boolean = False)
		Dim As Integer i
		Dim As TabPage Ptr It
		If Index >= 0 And Index <= FTabCount -1 Then
			If Index < tp->Index Then
				For i = tp->Index - 1 To Index Step -1
					It = Tabs[i]
					Tabs[i + 1] = It
					If i = Index Then
						Tabs[Index] = tp
						SetTabPageIndex(tp, Index)
					End If
					Tabs[i + 1]->Update
					SetTabPageIndex(It, i + 1)
				Next i
				Tabs[Index]->Update
			Else
				For i = tp->Index + 1 To Index
					It = Tabs[i]
					Tabs[i - 1] = It
					Tabs[i - 1]->Update
					SetTabPageIndex(It, i - 1)
				Next i
				Tabs[Index] = tp
				Tabs[Index]->Update
				SetTabPageIndex(tp, Index)
			End If
			If Not bNoActivate Then SelectedTabIndex = Index
			If OnTabReordered Then OnTabReordered(*Designer, This, tp, Index)
		End If
	End Sub
	
	Private Sub TabControl.SetTabPageIndex(tp As TabPage Ptr, Index As Integer)
			If tp AndAlso tp->Handle Then
				SetProp(tp->Handle, "@@@Index", Cast(.HANDLE, Index))
			End If
	End Sub
	
	Private Sub TabControl.DeleteTab(Index As Integer)
		Dim As Integer i
		Dim As TabPage Ptr It, Prev
		If Index >= 0 And Index <= FTabCount - 1 Then
			Prev = Tabs[Index]
			Prev->Parent = 0
			This.Remove(Tabs[Index])
			If Prev->FDynamic Then _Delete(Prev)
			For i = Index + 1 To FTabCount - 1
				It = Tabs[i]
				Tabs[i - 1] = It
				SetTabPageIndex(It, i - 1)
			Next i
			FTabCount -= 1
			If FTabCount = 0 Then
				_Deallocate(Tabs)
				Tabs = 0
			Else
				Tabs = _Reallocate(Tabs, FTabCount * SizeOf(TabPage Ptr))
			End If
				Perform(TCM_DELETEITEM, Index, 0)
			If Index > 0 Then
				SelectedTabIndex = Index - 1
			ElseIf Index < TabCount - 1 Then
				SelectedTabIndex = Index + 1
			End If
			If FTabCount = 0 Then SetMargins
			If OnTabRemoved Then OnTabRemoved(*Designer, This, Prev, Index)
		End If
	End Sub
	
	Private Sub TabControl.DeleteTab(Value As TabPage Ptr)
		DeleteTab IndexOfTab(Value)
	End Sub
	
	Private Sub TabControl.DetachTab(Value As TabPage Ptr)
		If Value = 0 Then Exit Sub
		Dim As Integer idx = IndexOfTab(Value)
		If idx < 0 Then Exit Sub
		Dim As Boolean bDynamic = Value->FDynamic
		Value->FDynamic = False
		DeleteTab idx
		Value->FDynamic = bDynamic
	End Sub
	
	Private Function TabControl.InsertTab(Index As Integer, ByRef Caption As WString, AObject As Any Ptr = 0) As TabPage Ptr
		Dim As Integer i
		Dim As TabPage Ptr It, tp
			Dim As TCITEM Ti
			Ti.mask = TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
		Dim As Integer iIndex = Index
		If iIndex < 0 Then
			iIndex = 0
		ElseIf iIndex > FTabCount Then
			iIndex = FTabCount
		End If
		'If Index >= 0 And Index <= FTabCount -1 Then
			FTabCount += 1
			Tabs = _Reallocate(Tabs,FTabCount*SizeOf(TabPage Ptr))
			For i = iIndex To FTabCount - 2
				It = Tabs[i]
				Tabs[i + 1] = It
				SetTabPageIndex(It, i + 1)
			Next i
			tp = _New( TabPage)
			Tabs[iIndex] = tp
			tp->FDynamic = True
			tp->Caption = Caption
			tp->Object = AObject
			'tp->TabPageControl = @This
				Dim As WString Ptr captionPtr
				WLet(captionPtr, Caption)
				Ti.pszText    = captionPtr
				Ti.cchTextMax = Len(Caption) + 1
				Ti.iImage = I_IMAGENONE
				If tp->Object Then Ti.lParam = Cast(LPARAM, tp->Object)
				Perform(TCM_INSERTITEM, iIndex, CInt(@Ti))
				SetTabPageIndex(tp, iIndex)
				Ti.lParam = 0
			SetMargins
			This.Add(tp)
			tp->Visible = FTabCount = 1
			If OnTabAdded Then OnTabAdded(*Designer, This, tp, iIndex)
			Return Tabs[iIndex]
		'End If
		'Return 0
	End Function
	
	Private Sub TabControl.InsertTab(Index As Integer, ByRef tp As TabPage Ptr)
		FTabCount += 1
		'tp->TabPageControl = @This
		Tabs = _Reallocate(Tabs, SizeOf(TabPage Ptr) * FTabCount)
		Tabs[FTabCount - 1] = tp
			If Handle Then
				Dim As TCITEMW Ti
				Dim As WString Ptr St
				WLet(St, tp->Caption)
				Ti.mask = TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
				Ti.pszText    = St
				Ti.cchTextMax = Len(tp->Caption)
				If tp->Object Then Ti.lParam = Cast(LPARAM, tp->Object)
				Ti.iImage = tp->ImageIndex
				SendMessageW(FHandle, TCM_INSERTITEMW, Index, CInt(@Ti))
				SetTabPageIndex(tp, FTabCount - 1)
				Ti.lParam = 0
			End If
			SetMargins
			tp->Visible = FTabCount = 1
		This.Add(Tabs[Index])
		If OnTabAdded Then OnTabAdded(*Designer, This, Tabs[Index], Index)
	End Sub
	
	Private Operator TabControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Function TabControl.IndexOfTab(Value As TabPage Ptr) As Integer
		Dim As Integer i
		For i = 0 To TabCount - 1
			If Tabs[i] = Value Then Return i
		Next i
		Return -1
	End Function
	
	
	Private Constructor TabControl
		SetMargins
		With This
				WLet(FClassAncestor, "SysTabControl32")
				.RegisterClass "TabControl", "SysTabControl32"
				UpDownControl.Style = UpDownOrientation.udHorizontal
			WLet(FClassName, "TabControl")
			.Child       = @This
				.ChildProc   = @WndProc
				Base.ExStyle     = 0
				Base.Style       = WS_CHILD
				.OnHandleIsAllocated = @HandleIsAllocated
				.DoubleBuffered = True
			FTabIndex          = -1
			FTabStop           = True
			FTabPosition = 2
			.Width       = 121
			.Height      = 121
		End With
	End Constructor
	
	Private Destructor TabControl
		For i As Integer = 0 To FTabCount - 1
			Tabs[i]->Parent = 0
			If Tabs[i]->FDynamic Then _Delete(Tabs[i])
		Next
		If Tabs <> 0 Then _Deallocate(Tabs)
		If FGroupName Then _Deallocate(FGroupName)
		'UnregisterClass "TabControl", GetModuleHandle(NULL)
	End Destructor
	
End Namespace

