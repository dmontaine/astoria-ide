'#########################################################
'#  Designer.bas                                        #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#           Nastase Eodor(nastasa.eodor@gmail.com)      #
'#########################################################

#include once "Designer.bi"
#include once "EditControl.bi"

	#define CtrlHandle HWND

Namespace My.Sys.Forms
		Function Designer.GetControl(ControlHandle As HWND) As Any Ptr
			Return Cast(Any Ptr, GetProp(ControlHandle, "MFFControl"))
		End Function

		Function Designer.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "loading": Return @Loading
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
		End Function

		Function Designer.FindPagePanelAncestor(Ctrl As Any Ptr) As Any Ptr
			Dim As Any Ptr WalkCtrl = Ctrl
			Dim As SymbolsType Ptr stWalk = SymbolsReadProperty(WalkCtrl)
			' Ctrl itself may already be the PagePanel (e.g. right-clicked directly
			' on its own surface rather than on one of its page's controls).
			If stWalk <> 0 AndAlso QWString(stWalk->ReadPropertyFunc(WalkCtrl, "ClassName")) = "PagePanel" Then Return WalkCtrl
			Do While stWalk <> 0
				Dim As Any Ptr ParentCtrl = stWalk->ReadPropertyFunc(WalkCtrl, "Parent")
				If ParentCtrl = 0 Then Return 0
				Dim As SymbolsType Ptr stParent = SymbolsReadProperty(ParentCtrl)
				If stParent = 0 Then Return 0
				If QWString(stParent->ReadPropertyFunc(ParentCtrl, "ClassName")) = "PagePanel" Then Return ParentCtrl
				WalkCtrl = ParentCtrl
				stWalk = stParent
			Loop
			Return 0
		End Function

		Sub Designer.MovePanelLayer(ByVal Direction As Integer)
			Dim As Any Ptr PagePanelCtrl = FindPagePanelAncestor(SelectedControl)
			If PagePanelCtrl = 0 Then Exit Sub
			Dim As SymbolsType Ptr st = SymbolsWriteProperty(PagePanelCtrl)
			If st = 0 OrElse st->ReadPropertyFunc = 0 OrElse st->ControlByIndexFunc = 0 Then Exit Sub
			Dim As Integer Ptr pIndex = st->ReadPropertyFunc(PagePanelCtrl, "SelectedPanelIndex")
			Dim As Integer Ptr pCount = st->ReadPropertyFunc(PagePanelCtrl, "ControlCount")
			If pIndex = 0 OrElse pCount = 0 Then Exit Sub
			' ControlCount includes PagePanel's own hidden spinner, always pinned to
			' the last raw slot (see PagePanel.Add), so real pages occupy raw
			' indices 0..ControlCount-2 - matches SelectedPanelIndex's own indexing.
			Dim As Integer LastPage = *pCount - 2
			If LastPage < 0 Then Exit Sub
			Dim As Integer NewIndex = *pIndex + Direction
			If NewIndex < 0 Then NewIndex = LastPage
			If NewIndex > LastPage Then NewIndex = 0
			st->WritePropertyFunc(PagePanelCtrl, "SelectedPanelIndex", @NewIndex)
			Dim As Any Ptr PageCtrl = st->ControlByIndexFunc(PagePanelCtrl, NewIndex)
			If PageCtrl = 0 Then Exit Sub
			If Not SelectedControls.Contains(PageCtrl) Then SelectedControls.Clear
			SelectedControl = PageCtrl
			Dim As SymbolsType Ptr stPage = SymbolsReadProperty(PageCtrl)
			If stPage <> 0 Then
				Dim As Any Ptr hw = stPage->ReadPropertyFunc(PageCtrl, "Handle")
				If hw <> 0 Then MoveDots(PageCtrl, False) Else MoveDots(0, False)
			End If
			If OnChangeSelection Then OnChangeSelection(This, PageCtrl)
		End Sub
	
	Function Designer.GetParentControl(iControl As Any Ptr, ByVal toRoot As Boolean = True) As Any Ptr
		If iControl = 0 Then Return iControl
		Dim As Any Ptr iParentControl, iParentControlSave
		Dim As SymbolsType Ptr st = Symbols(iControl)
		If st AndAlso st->ReadPropertyFunc  Then
			iParentControl = st->ReadPropertyFunc(iControl, "Parent")
			Dim As Integer ii
			If toRoot Then
				Do Until iParentControl = 0
					iParentControlSave = iControl
					iControl = iParentControl
					iParentControl = st->ReadPropertyFunc(iControl, "Parent")
					ii +=1
					If ii > 10 Then Exit Do
				Loop
				iParentControl = iParentControlSave
			End If
		End If
		Return iParentControl
	End Function
	
	Sub Designer.ProcessMessage(ByRef message As Message)
		
		'message.Result = -1
		
	End Sub
	
	'Sub Designer.HandleIsAllocated(BYREF Sender As Control)
	'    With QDesigner(@Sender)
	'        .CreateDots(GetParent(Sender.Handle))
	'        .Dialog = Sender.Handle
	'            'dim as RECT R
	'            'GetClientRect(Sender.Handle, @R)
	'            'if .FShowGrid then
	'              '.DrawGrid(GetDC(Sender.Handle), R)
	'            'else
	'              'FillRect(GetDC(Sender.Handle), @R, cast(HBRUSH, 16))
	'            'end if
	'    End With
	'End Sub
	
	Sub Designer.ChangeFirstMenuItem()
		If SelectedControl = DesignControl Then
			mnuDesigner.Item("LockControls")->Visible = True
			mnuDesigner.Item("Copy")->Visible = False
			mnuDesigner.Item("Cut")->Visible = False
			mnuDesigner.Item("Delete")->Visible = False
			mnuDesigner.Item("DuplicateSeparator")->Visible = False
			mnuDesigner.Item("Duplicate")->Visible = False
			mnuDesigner.Item("OrderSeparator")->Visible = False
			mnuDesigner.Item("BringToFront")->Visible = False
			mnuDesigner.Item("SendToBack")->Visible = False
			mnuDesigner.Item(0)->Caption = ("Default event")
			mnuDesigner.Item(0)->Image = "Code"
		Else
			mnuDesigner.Item("LockControls")->Visible = False
			mnuDesigner.Item("Copy")->Visible = True
			mnuDesigner.Item("Cut")->Visible = True
			mnuDesigner.Item("Delete")->Visible = True
			mnuDesigner.Item("DuplicateSeparator")->Visible = True
			mnuDesigner.Item("Duplicate")->Visible = True
			mnuDesigner.Item("OrderSeparator")->Visible = True
			mnuDesigner.Item("BringToFront")->Visible = True
			mnuDesigner.Item("SendToBack")->Visible = True
			Dim As SymbolsType Ptr st = Symbols(SelectedControl)
			If st AndAlso st->ReadPropertyFunc Then
				Select Case QWString(st->ReadPropertyFunc(SelectedControl, "ClassName"))
				Case "MainMenu", "PopupMenu"
					mnuDesigner.Item(0)->Caption = ("Menu Editor")
					mnuDesigner.Item(0)->Image = ""
				Case "ToolBar"
					mnuDesigner.Item(0)->Caption = ("ToolBar Editor")
					mnuDesigner.Item(0)->Image = ""
				Case "StatusBar"
					mnuDesigner.Item(0)->Caption = ("StatusBar Editor")
					mnuDesigner.Item(0)->Image = ""
				Case "ImageList"
					mnuDesigner.Item(0)->Caption = ("ImageList Editor")
					mnuDesigner.Item(0)->Image = ""
				Case Else
					mnuDesigner.Item(0)->Caption = ("Default event")
					mnuDesigner.Item(0)->Image = "Code"
				End Select
			End If
		End If
		' "Show Panel"/"Previous Layer"/"Next Layer" - let a control's page on a
		' stacked/layered PagePanel be switched from within the visual design
		' surface itself, not just via the project tree, since PagePanel's own
		' design-time spinner never actually works (Design Mode intercepts clicks
		' for selection, not the control's real click behavior).
		Dim As Any Ptr PagePanelCtrl = FindPagePanelAncestor(SelectedControl)
		mnuShowPanelDesigner->Visible = (PagePanelCtrl <> 0)
		mnuDesigner.Item("ShowPanelSeparator")->Visible = (PagePanelCtrl <> 0)
		mnuDesigner.Item("PreviousLayer")->Visible = (PagePanelCtrl <> 0)
		mnuDesigner.Item("NextLayer")->Visible = (PagePanelCtrl <> 0)
		If PagePanelCtrl <> 0 Then
			mnuShowPanelDesigner->Clear
			Dim As SymbolsType Ptr stPanel = SymbolsReadProperty(PagePanelCtrl)
			If stPanel <> 0 AndAlso stPanel->ControlByIndexFunc <> 0 Then
				Dim As Integer Ptr pCount = stPanel->ReadPropertyFunc(PagePanelCtrl, "ControlCount")
				If pCount <> 0 Then
					For i As Integer = 0 To *pCount - 1
						Dim As Any Ptr PageCtrl = stPanel->ControlByIndexFunc(PagePanelCtrl, i)
						Dim As SymbolsType Ptr stPage = SymbolsReadProperty(PageCtrl)
						If stPage <> 0 AndAlso QWString(stPage->ReadPropertyFunc(PageCtrl, "ClassName")) <> "NumericUpDown" Then
							Dim As MenuItem Ptr mnu = mnuShowPanelDesigner->Add(QWString(stPage->ReadPropertyFunc(PageCtrl, "Name")), "", "", Cast(NotifyEvent, @ShowPanelMenuItem_Click))
							mnu->Tag = PageCtrl
						End If
					Next i
				End If
			End If
		End If
	End Sub
	
	Sub Designer.CheckTopMenuVisible(ChangeHeight As Boolean = True, bMoveDots As Boolean = True)
			If DesignControl = 0 Then Exit Sub
			Dim As SymbolsType Ptr st = Symbols(DesignControl)
			If st = 0 OrElse st->ReadPropertyFunc = 0 OrElse st->WritePropertyFunc = 0 Then Exit Sub
			Var CurrentMenu = st->ReadPropertyFunc(DesignControl, "Menu")
			If CurrentMenu <> 0 AndAlso QInteger(st->ReadPropertyFunc(CurrentMenu, "Count")) <> 0 Then
				Dim ncm As NONCLIENTMETRICS
				ncm.cbSize = SizeOf(ncm)
				SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(ncm), @ncm, 0)
				If UnScaleY(ncm.iMenuHeight) <> TopMenuHeight Then
					Dim As Integer OldHeight = QInteger(st->ReadPropertyFunc(DesignControl, "Height"))
					Dim As Integer NewHeight = OldHeight + UnScaleY(ncm.iMenuHeight) - TopMenuHeight
					TopMenuHeight = UnScaleY(ncm.iMenuHeight)
					TopMenu->Tag = @This
					'TopMenu->OnPaint = @TopMenu_Paint
					st->WritePropertyFunc(DesignControl, "Height", @NewHeight)
					If Not ChangeHeight Then st->WritePropertyFunc(DesignControl, "Height", @OldHeight)
					If bMoveDots Then MoveDots DesignControl, False
					TopMenu->Visible = True
					TopMenu->BringToFront
					TopMenu->Repaint
				End If
			ElseIf TopMenuHeight <> 0 Then
				Dim As Integer OldHeight = QInteger(st->ReadPropertyFunc(DesignControl, "Height"))
				Dim As Integer NewHeight = OldHeight - TopMenuHeight
				TopMenuHeight = 0
				TopMenu->Visible = False
				st->WritePropertyFunc(DesignControl, "Height", @NewHeight)
				If Not ChangeHeight Then st->WritePropertyFunc(DesignControl, "Height", @OldHeight)
				If bMoveDots Then MoveDots DesignControl, False
			End If
	End Sub
	
		Function Designer.EnumChildsProc(hDlg As HWND, lParam As LPARAM) As Boolean
			If lParam Then
				With *Cast(WindowList Ptr, lParam)
					.Count = .Count + 1
					.Child = _Reallocate(.Child, .Count * SizeOf(HWND))
					.Child[.Count-1] = hDlg
				End With
			End If
			Return True
		End Function
		
		Sub Designer.GetChilds(Parent As HWND = 0)
			FChilds.Count = 0
			'FChilds.Child = CAllocate_(0)
			EnumChildWindows(IIf(Parent, Parent, FDialog), Cast(WNDENUMPROC, @EnumChildsProc), CInt(@FChilds))
		End Sub
	
		Sub Designer.ClipCursor(hDlg As HWND)
			Dim As ..Rect R
			If IsWindow(hDlg) Then
				GetClientRect(hDlg, @R)
				MapWindowPoints(hDlg, 0,Cast(..Point Ptr, @R), 2)
				.ClipCursor(@R)
			Else
				.ClipCursor(0)
			End If
		End Sub
	
	Sub Designer.DrawBox(R As My.Sys.Drawing.Rect)
			FHDC = GetDCEx(FDialog, 0, DCX_PARENTCLIP Or DCX_CACHE Or DCX_CLIPSIBLINGS)
			Brush = GetStockObject(NULL_BRUSH)
			PrevBrush = SelectObject(FHDC, Brush)
			SetROP2(FHDC, R2_NOT)
			Rectangle(FHDC, ScaleX(R.Left), ScaleY(R.Top), ScaleX(R.Right), ScaleY(R.Bottom))
			SelectObject(FHDC, PrevBrush)
			ReleaseDC(FDialog, FHDC)
	End Sub
	
	Sub Designer.DrawBoxs(R() As My.Sys.Drawing.Rect)
		'''for future implementation of multiselect suport
		For i As Integer = 0 To UBound(R)
			DrawBox(R(i))
		Next
	End Sub
	
	Function Designer.GetClassAcceptControls(AClassName As String) As Boolean
		'''for future implementation of classbag struct
		Return False
	End Function
	
	Sub Designer.Clear
			GetChilds
			For i As Integer = FChilds.Count -1 To 0 Step -1
				DestroyWindow(FChilds.Child[i])
			Next
		HideDots
	End Sub
	
	Sub Designer.SelectNextControl(Direction As Integer = 0)
		If Components.Count > 0 Then
			SelectedControls.Clear
			If Direction < 0 Then
				Var iIndex = Components.IndexOf(SelectedControl)
				If iIndex < 1 Then
					MoveDots Components.Item(Components.Count - 1)
				Else
					MoveDots Components.Item(iIndex - 1)
				End If
			Else
				Var iIndex = Components.IndexOf(SelectedControl)
				If iIndex = Components.Count - 1 Then
					MoveDots Components.Item(0)
				Else
					MoveDots Components.Item(iIndex + 1)
				End If
			End If
		End If
	End Sub
	
	Function Designer.ClassExists() As Boolean
		'FClass = SelectedClass
			Dim As WNDCLASSEX wcls
			wcls.cbSize = SizeOf(wcls)
		Return SelectedClass <> "" 'and (GetClassInfoEx(0, FClass, @wcls) or GetClassInfoEx(instance, FClass, @wcls))
	End Function
	
	'function Designer.GetClassName(hDlg as HWND) as string
	'dim as Wstring Ptr s
	'WReallocate s, 256
	'*s = space(255)
	'dim as integer L = .GetClassName(hDlg, s, Len(*s))
	'return trim(Left(*s, L))
	'end function
	'
	Function Designer.ControlAt(Parent As Any Ptr, X As Integer, Y As Integer, CtrlPressed As Any Ptr = 0) As Any Ptr
			Dim As SymbolsType Ptr st = Symbols(Parent)
			If st AndAlso st->ReadPropertyFunc Then
				Dim ParentHwndPtr As HWND Ptr = Cast(HWND Ptr, st->ReadPropertyFunc(Parent, "Handle"))
				If ParentHwndPtr = 0 Then Return Parent
				Dim ParentHwnd As HWND = *Cast(HWND Ptr, st->ReadPropertyFunc(Parent, "Handle"))
				Dim Result As HWND = ChildWindowFromPointEx(ParentHwnd, Type<..Point>(ScaleX(X), ScaleY(Y)), CWP_SKIPINVISIBLE)
				If IsWindowVisible(Result) = 0 Then Return Parent
				If GetControl(Result) = Parent Then Return Parent
				If Result = 0 OrElse Result = ParentHwnd OrElse GetControl(Result) = 0 Then
					Return Parent
				Else
					Dim As ..Rect R
					GetWindowRect Result, @R
					MapWindowPoints 0, ParentHwnd, Cast(..Point Ptr, @R), 2
					Return ControlAt(GetControl(Result), X - UnScaleX(R.Left), Y - UnScaleY(R.Top))
				End If
			End If
			'		dim as RECT R
			'		GetChilds(Parent)
			'		for i as integer = 0 to FChilds.Count -1
			'			if IsWindowVisible(FChilds.Child[i]) then
			'			   GetWindowRect(FChilds.Child[i], @R)
			'			   MapWindowPoints(0, Parent, cast(POINT ptr, @R) ,2)
			'			   if (X > R.Left and X < R.Right) and (Y > R.Top and Y < R.Bottom) then
			'				  return FChilds.Child[i]
			'			   end If
			'			end if
			'		next i
		'    return Parent
	End Function
	
	
	Sub Designer.CreateDots(ParentCtrl As Control Ptr)
		For i As Integer = 0 To 7
				If ParentCtrl > 0 AndAlso ParentCtrl->Handle > 0 Then FDots(0, i) = CreateWindowEx(0, "DOT", "", WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN, 0, 0, ScaleX(FDotSize), ScaleY(FDotSize), ParentCtrl->Handle, 0, Instance, 0)
				If IsWindow(FDots(0, i)) Then
					SetWindowLongPtr(FDots(0, i), GWLP_USERDATA, CInt(@This))
				End If
		Next i
	End Sub
	
	Sub Designer.DestroyDots
		For j As Integer = UBound(FDots) To 0 Step -1
			For i As Integer = 7 To 0 Step -1
					DestroyWindow(FDots(j, i))
			Next i
		Next j
	End Sub
	
	Sub Designer.HideDots
		For j As Integer = 0 To UBound(FDots)
			For i As Integer = 0 To 7
					ShowWindow(FDots(j, i), SW_HIDE)
			Next i
		Next j
	End Sub
	
	
		Sub Designer.MoveDots(Control As Any Ptr, bSetFocus As Boolean = True)
			Dim As ..Rect R
		Dim As My.Sys.Drawing.Point P
		Dim As Integer iWidth, iHeight
			Dim As HWND ControlHandle
		ControlHandle = GetControlHandle(Control)
		Dim As Integer CountOfControls
			If IsWindow(ControlHandle) Then
			SelectedControl = Control
			FSelControl = ControlHandle
			If SelectedControls.Count = 0 Then SelectedControls.Add SelectedControl
				CountOfControls = SelectedControls.Count
			'if Control <> FDialog then
			Dim As Integer DotsCount = UBound(FDots)
			For j As Integer = DotsCount To CountOfControls Step -1
				For i As Integer = 7 To 0 Step -1
						If FDots(j, i) > 0 Then DestroyWindow(FDots(j, i))
				Next
			Next
			ReDim Preserve FDots(SelectedControls.Count - 1, 7) As CtrlHandle
				For j As Integer = SelectedControls.Count - 1 To DotsCount + 1 Step - 1 'For Compile with FBC 1.10
					For i As Integer = 0 To 7
						FDots(j, i) = CreateWindowEx(0, "DOT", "", WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN, 0, 0, ScaleX(FDotSize), ScaleY(FDotSize), GetParent(FDialog), 0, Instance, 0)
						SetWindowLongPtr(FDots(j, i), GWLP_USERDATA, CInt(@This))
					Next
				Next
				For j As Integer = 0 To SelectedControls.Count - 1
					GetWindowRect(GetControlHandle(SelectedControls.Items[j]), @R)
					iWidth  = R.Right  - R.Left
					iHeight = R.Bottom - R.Top
					P.X     = R.Left
					P.Y     = R.Top
					ScreenToClient(GetParent(FDialog), Cast(..Point Ptr, @P))
					MoveWindow FDots(j, 0), P.X - ScaleX(FDotSize), P.Y - ScaleY(FDotSize), ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 1), P.X + iWidth / 2 - 3, P.Y - ScaleY(FDotSize), ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 2), P.X + iWidth, P.Y - ScaleY(FDotSize), ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 3), P.X + iWidth, P.Y + iHeight / 2 - 3, ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 4), P.X + iWidth, P.Y + iHeight, ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 5), P.X + iWidth / 2 - 3, P.Y + iHeight, ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 6), P.X - ScaleX(FDotSize), P.Y + iHeight, ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 7), P.X - ScaleX(FDotSize), P.Y + iHeight / 2 - 3, ScaleX(FDotSize), ScaleY(FDotSize), True
					For i As Integer = 0 To 7
						'SetParent(FDots(i), GetParent(Control))
						SetProp(FDots(j, i),"@@@Control", GetControlHandle(SelectedControls.Items[j]))
						SetProp(FDots(j, i),"@@@Control2", SelectedControls.Items[j])
						BringWindowToTop FDots(j, i)
						ShowWindow(FDots(j, i), SW_SHOW)
					Next i
				Next j
				FHDC = GetDC(GetParent(ControlHandle))
				'SetROP2(hdc, R2_NOTXORPEN)
				RedrawWindow(FDialog, NULL, NULL, RDW_INVALIDATE)
				'DrawFocusRect(Fhdc, @type<RECT>(R.Left, R.Top, R.Right, R.Bottom + 10))
				ReleaseDC(ControlHandle, FHDC)
			If bSetFocus Then
					'SetFocus(Dialog)
				'else
				'   HideDots
				'end If
				If OnChangeSelection Then OnChangeSelection(This, SelectedControl, UnScaleX(P.X), UnScaleY(P.Y), UnScaleX(iWidth), UnScaleY(iHeight))
			End If
		Else
			HideDots
		End If
	End Sub
	
	Sub Designer.MoveControl(Control As Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)
		Dim As SymbolsType Ptr st = Symbols(Control)
		If st AndAlso st->ComponentSetBoundsSub AndAlso st->Q_ComponentFunc Then
			st->ComponentSetBoundsSub(st->Q_ComponentFunc(Control), iLeft, iTop, iWidth, iHeight)
		End If
	End Sub
	
	Sub Designer.GetControlBounds(Control As Any Ptr, ByRef iLeft As Integer, ByRef iTop As Integer, ByRef iWidth As Integer, ByRef iHeight As Integer)
		Dim As SymbolsType Ptr st = Symbols(Control)
		If st AndAlso st->ComponentGetBoundsSub AndAlso st->Q_ComponentFunc Then
			st->ComponentGetBoundsSub(st->Q_ComponentFunc(Control), iLeft, iTop, iWidth, iHeight)
		End If
	End Sub
	
	Sub Designer.SetControlBounds(Control As Any Ptr, ByRef iLeft As Integer, ByRef iTop As Integer, ByRef iWidth As Integer, ByRef iHeight As Integer)
		Dim As SymbolsType Ptr st = Symbols(Control)
		If st AndAlso st->ComponentSetBoundsSub AndAlso st->Q_ComponentFunc Then
			st->ComponentSetBoundsSub(st->Q_ComponentFunc(Control), iLeft, iTop, iWidth, iHeight)
		End If
	End Sub
	
		Function Designer.IsDot(hDlg As HWND) As Integer
			Dim As String s
			If GetWindowLongPtr(hDlg, GWLP_USERDATA) = CInt(@This) Then
				'if UCase(s) = "DOT" then
				For j As Integer = 0 To SelectedControls.Count - 1
					For i As Integer = 0 To 7
						If FDots(j, i) = hDlg Then Return i
					Next i
				Next j
			End If
			Return -1
		End Function
	
	Sub Designer.DblClick(X As Integer, Y As Integer, Shift As Integer, Ctrl As Any Ptr = 0)
		SelectedControl = ControlAt(DesignControl, X, Y, Ctrl)
		If OnDblClickControl Then OnDblClickControl(This, SelectedControl)
	End Sub
	
		Function Designer.GetControlHandle(Control As Any Ptr) As HWND
			If Control = 0 Then Return 0
			Dim As SymbolsType Ptr st = Symbols(Control)
			If st = 0 OrElse st->ReadPropertyFunc = 0 Then Return 0
			Var tHandle = st->ReadPropertyFunc(Control, "Handle")
			If tHandle = 0 Then Return 0
			Return *Cast(HWND Ptr, tHandle)
	End Function
	
	Sub Designer.MouseDown(X As Integer, Y As Integer, Shift As Integer, Ctrl As Any Ptr = 0)
			Dim As Boolean bCtrl = GetKeyState(VK_CONTROL) And 8000
			Dim As Boolean bShift = GetKeyState(VK_SHIFT) And 8000
		pfrmMain->ActiveControl = GetControl(FDialogParent)
			Dim As ..Point P
			Dim As ..Rect R
		FDown   = True
		FStepX = GridSize
		FStepY = GridSize
		FBeginX = IIf(SnapToGridOption, (X\FStepX)*FStepX,X)
		FBeginY = IIf(SnapToGridOption, (Y\FStepY)*FStepY,Y)
		FEndX   = FBeginX
		FEndY   = FBeginY
		FNewX   = FBeginX
		FNewY   = FBeginY
		HideDots
		Dim As Any Ptr SelCtrl = ControlAt(DesignControl, X, Y, Ctrl)
		FDotIndex   = IsDot(FOverControl)
		If FDotIndex = -1 Then
			If bCtrl Or bShift Then
				If SelectedControls.Contains(SelCtrl) Then
					If SelectedControls.Count > 1 Then SelectedControls.Remove SelectedControls.IndexOf(SelCtrl)
					SelectedControl = SelectedControls.Items[0]
				ElseIf SelectedControls.Count = 0 OrElse (Symbols(SelectedControls.Items[0]) AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc AndAlso Symbols(SelCtrl) AndAlso Symbols(SelCtrl)->ReadPropertyFunc AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc(SelectedControls.Items[0], "Parent") = Symbols(SelCtrl)->ReadPropertyFunc(SelCtrl, "Parent")) Then
					SelectedControls.Add SelCtrl
					SelectedControl = SelCtrl
				End If
			ElseIf Not SelectedControls.Contains(SelCtrl) Then
				SelectedControls.Clear
				SelectedControls.Add SelCtrl
				SelectedControl = SelCtrl
			Else
				SelectedControl = SelCtrl
			End If
		End If
		FSelControl = GetControlHandle(SelectedControl)
		If FDotIndex <> -1 Then
			FCanInsert  = False
			FCanMove    = False
			FCanSize    = Not FLockControls
				'If Not IsWindow(FSelControl) Then
				FSelControl = GetProp(FDots(0, FDotIndex),"@@@Control")
				SelectedControl = GetControl(FSelControl)
				'End If
			'BringWindowToTop(FSelControl)
			Dim As Integer iCount = SelectedControls.Count - 1
			ReDim As Integer FLeft(iCount), FTop(iCount), FWidth(iCount), FHeight(iCount)
			ReDim As Integer FLeftNew(iCount), FTopNew(iCount), FWidthNew(iCount), FHeightNew(iCount)
			For j As Integer = 0 To iCount
					GetWindowRect(GetControlHandle(SelectedControls.Items[j]), @R)
					P.X         = R.Left
					P.Y         = R.Top
					FWidth(j)   = UnScaleX(R.Right - R.Left)
					FHeight(j)  = UnScaleY(R.Bottom - R.Top)
					ScreenToClient(GetParent(FSelControl), @P)
					FLeft(j)    = UnScaleX(P.X)
					FTop(j)     = UnScaleY(P.Y)
			Next
				If FLockControls Then
					SetCursor(crArrow)
				Else
					Select Case FDotIndex
					Case 0: SetCursor(crSizeNWSE)
					Case 1: SetCursor(crSizeNS)
					Case 2: SetCursor(crSizeNESW)
					Case 3: SetCursor(crSizeWE)
					Case 4: SetCursor(crSizeNWSE)
					Case 5: SetCursor(crSizeNS)
					Case 6: SetCursor(crSizeNESW)
					Case 7: SetCursor(crSizeWE)
					End Select
					SetCapture(FDialog)
				End If
		Else
			If FSelControl <> FDialog Then
				'BringWindowToTop(FSelControl)
				If ClassExists Then
					FCanInsert = True
					FCanMove   = False
					FCanSize   = False
						SetCursor(crCross)
				Else
					FCanInsert = False
					FCanMove   = Not FLockControls
					FCanSize   = False
						SetCursor(crSize) :SetCapture(FDialog)
					If OnChangeSelection Then OnChangeSelection(This, SelectedControl)
					Dim As Integer iCount = SelectedControls.Count - 1
					ReDim As Integer FLeft(iCount), FTop(iCount), FWidth(iCount), FHeight(iCount)
					ReDim As Integer FLeftNew(iCount), FTopNew(iCount), FWidthNew(iCount), FHeightNew(iCount)
					For j As Integer = 0 To iCount
							GetWindowRect(GetControlHandle(SelectedControls.Items[j]), @R)
							P.X         = R.Left
							P.Y         = R.Top
							FWidth(j)   = UnScaleX(R.Right - R.Left)
							FHeight(j)  = UnScaleY(R.Bottom - R.Top)
							ScreenToClient(GetParent(FSelControl), @P)
							FLeft(j)    = UnScaleX(P.X)
							FTop(j)     = UnScaleY(P.Y)
					Next
				End If
			Else
				HideDots
				FCanInsert = IIf(ClassExists, True, False)
				FCanMove   = 0
				FCanSize   = False
				If FCanInsert Then
						SetCursor(crCross)
				Else
					If OnChangeSelection Then OnChangeSelection(This, SelectedControl)
				End If
				If Not FCanInsert AndAlso Not FCanMove AndAlso (CBool(FSelControl = FDialog) OrElse Not FLockControls) Then
						FHDC = GetDC(FDialog)
						'SetROP2(hdc, R2_NOTXORPEN)
						DrawFocusRect(FHDC, @Type<..Rect>(ScaleX(FBeginX), ScaleY(FBeginY), ScaleX(FNewX), ScaleY(FNewY)))
						FOldX = FNewX
						FOldY = FNewY
						ReleaseDC(FDialog, FHDC)
						SetCapture(FDialog)
				End If
			End If
		End If
	End Sub
	
	Sub Designer.MouseMove(X As Integer, Y As Integer, Shift As Integer)
			Dim As ..Point P
		FStepX = GridSize
		FStepY = GridSize
		FNewX = IIf(SnapToGridOption, (X \ FStepX) * FStepX, X)
		FNewY = IIf(SnapToGridOption, (Y \ FStepY) * FStepY, Y)
		'dim hdc As HDC = GetDC(FHandle)
		If FDown Then
			If FCanInsert Then
					SetCursor(crCross)
				DrawBox(Type<My.Sys.Drawing.Rect>(FBeginX, FBeginY, FNewX, FNewY))
				DrawBox(Type<My.Sys.Drawing.Rect>(FBeginX, FBeginY, FEndX, FEndY))
			End If
			If FCanSize Then
				For j As Integer = 0 To SelectedControls.Count - 1
					FLeftNew(j) = FLeft(j)
					FTopNew(j) = FTop(j)
					FWidthNew(j) = FWidth(j)
					FHeightNew(j) = FHeight(j)
						Select Case FDotIndex
						Case 0: FLeftNew(j) = FLeft(j) + (FNewX - FBeginX): FTopNew(j) = FTop(j) + (FNewY - FBeginY): FWidthNew(j) = FWidth(j) - (FNewX - FBeginX): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 1: FTopNew(j) = FTop(j) + (FNewY - FBeginY): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 2: FTopNew(j) = FTop(j) + (FNewY - FBeginY): FWidthNew(j) = FWidth(j) + (FNewX - FBeginX): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 3: FWidthNew(j) = FWidth(j) + (FNewX - FBeginX)
						Case 4: FWidthNew(j) = FWidth(j) + (FNewX - FBeginX): FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 5: FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 6: FLeftNew(j) = FLeft(j) + (FNewX - FBeginX): FWidthNew(j) = FWidth(j) - (FNewX - FBeginX): FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 7: FLeftNew(j) = FLeft(j) - (FBeginX - FNewX): FWidthNew(j) = FWidth(j) + (FBeginX - FNewX)
						End Select
						'ComponentSetBoundsSub(Q_ComponentFunc(SelectedControl), FLeftNew, FTopNew, FWidthNew, FHeightNew)
						MoveWindow(GetControlHandle(SelectedControls.Items[j]), ScaleX(FLeftNew(j)), ScaleY(FTopNew(j)), ScaleX(FWidthNew(j)), ScaleY(FHeightNew(j)), True)
				Next
					RedrawWindow(FDialog, NULL, NULL, RDW_INVALIDATE)
			End If
			If FCanMove Then
				If FBeginX <> FEndX Or FBeginY <> FEndY Then
					For j As Integer = 0 To SelectedControls.Count - 1
							MoveWindow(GetControlHandle(SelectedControls.Items[j]), ScaleX(FLeft(j) + (FNewX - FBeginX)), ScaleY(FTop(j) + (FNewY - FBeginY)), ScaleX(FWidth(j)), ScaleY(FHeight(j)), True)
					Next j
						RedrawWindow(FDialog, NULL, NULL, RDW_INVALIDATE)
				End If
			End If
			If Not FCanInsert AndAlso Not FCanMove AndAlso Not FCanSize AndAlso (CBool(FSelControl = FDialog) OrElse Not FLockControls) Then
					FHDC = GetDC(FDialog)
					'SetROP2(hdc, R2_NOTXORPEN)
					DrawFocusRect(FHDC, @Type<..Rect>(ScaleX(Min(FBeginX, FOldX)), ScaleY(Min(FBeginY, FOldY)), ScaleX(Max(FBeginX, FOldX)), ScaleY(Max(FBeginY, FOldY))))
					DrawFocusRect(FHDC, @Type<..Rect>(ScaleX(Min(FBeginX, FNewX)), ScaleX(Min(FBeginY, FNewY)), ScaleX(Max(FBeginX, FNewX)), ScaleY(Max(FBeginY, FNewY))))
				FOldX = FNewX
				FOldY = FNewY
					ReleaseDC(FDialog, FHDC)
			End If
		Else
				P = Type(ScaleX(X), ScaleY(Y))
				ClientToScreen(FDialog, @P)
				ScreenToClient(GetParent(FDialog), @P)
				FOverControl = ChildWindowFromPoint(GetParent(FDialog), P)
				If OnMouseMove Then OnMouseMove(This, X, Y, GetControl(FOverControl))
				Dim As Integer Id = IsDot(FOverControl)
				If Id <> -1 Then
					If FLockControls Then
						SetCursor(crArrow)
					Else
						Select Case Id
						Case 0 : SetCursor(crSizeNWSE)
						Case 1 : SetCursor(crSizeNS)
						Case 2 : SetCursor(crSizeNESW)
						Case 3 : SetCursor(crSizeWE)
						Case 4 : SetCursor(crSizeNWSE)
						Case 5 : SetCursor(crSizeNS)
						Case 6 : SetCursor(crSizeNESW)
						Case 7 : SetCursor(crSizeWE)
						End Select
					End If
				Else
					If GetAncestor(FOverControl,GA_ROOTOWNER) <> FDialog Then
						ReleaseCapture
					End If
					SetCursor(crArrow)
					ClipCursor(0)
				End If
		End If
		FEndX = FNewX
		FEndY = FNewY
	End Sub
	
	Function Designer.GetContainerControl(Ctrl As Any Ptr) As Any Ptr
		Dim As SymbolsType Ptr st = Symbols(Ctrl)
		If st = 0 Then Return 0
		If st->ControlIsContainerFunc <> 0 Then
			If Ctrl Then
				If st->ControlIsContainerFunc(Ctrl) Then
					Return Ctrl
				ElseIf st->ReadPropertyFunc <> 0 AndAlso st->ReadPropertyFunc(Ctrl, "Parent") Then
					Return GetContainerControl(st->ReadPropertyFunc(Ctrl, "Parent"))
				End If
			End If
		End If
		Return Ctrl
	End Function
	
	Sub Designer.MouseUp(X As Integer, Y As Integer, Shift As Integer)
		Dim As Rect R
		If FDown Then
			'    	if (FBeginX > FEndX and FBeginY > FEndY) then
			'            swap FBeginX, FNewX
			'            swap FBeginY, FNewY
			'        end if
			'        if (FBeginX > FEndX and FBeginY < FEndY) then
			'            swap FBeginX, FNewX
			'        end if
			'        if (FBeginX < FEndX and FBeginY > FEndY) then
			'            swap FBeginY, FNewY
			'        end if
			FDown = False
			If Not FCanMove AndAlso Not FCanInsert AndAlso Not FCanSize Then
				If FBeginX > FNewX Then Swap FBeginX, FNewX
				If FBeginY > FNewY Then Swap FBeginY, FNewY
				SelectedControls.Clear
					If CBool(FSelControl = FDialog) OrElse Not FLockControls Then
						FHDC = GetDC(FDialog)
						DrawFocusRect(FHDC, @Type<Rect>(ScaleX(FBeginX), ScaleY(FBeginY), ScaleX(FNewX), ScaleY(FNewY)))
						ReleaseDC(FDialog, FHDC)
					End If
					SelectedControl = DesignControl
					FSelControl = FDialog
					Dim As Rect R, R1
					Dim As Any Ptr Ctrl
					For i As Integer = Objects.Count - 1 To 0 Step -1
						Ctrl = Objects.Item(i)
						Dim As SymbolsType Ptr st = Symbols(Ctrl)
						If Ctrl AndAlso st AndAlso st->ReadPropertyFunc <> 0 AndAlso st->ReadPropertyFunc(Ctrl, "Handle") AndAlso IsWindowVisible(*Cast(HWND Ptr, st->ReadPropertyFunc(Ctrl, "Handle"))) Then
							GetWindowRect(*Cast(HWND Ptr, st->ReadPropertyFunc(Ctrl, "Handle")), @R)
							MapWindowPoints(0, FDialog, Cast(Point Ptr, @R) , 2)
							R1 = Type<Rect>(UnScaleX(R.Left), UnScaleY(R.Top), UnScaleX(R.Right), UnScaleY(R.Bottom))
							If Not (R1.Right < FBeginX OrElse R1.Left > FNewX OrElse R1.Top > FNewY OrElse R1.Bottom < FBeginY) Then
								If SelectedControls.Count = 0 OrElse (Symbols(SelectedControls.Items[0]) AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc <> 0 AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc(SelectedControls.Items[0], "Parent") = st->ReadPropertyFunc(Ctrl, "Parent")) Then
									SelectedControls.Add Ctrl
								End If
							End If
						End If
					Next i
				If SelectedControls.Count > 0 Then
					SelectedControl = SelectedControls.Items[0]
					FSelControl = GetControlHandle(SelectedControl)
				End If
				MoveDots(SelectedControl)
			End If
			If FCanInsert Then
				If FBeginX > FNewX Then Swap FBeginX, FNewX
				If FBeginY > FNewY Then Swap FBeginY, FNewY
				DrawBox(Type<My.Sys.Drawing.Rect>(FBeginX, FBeginY, FNewX, FNewY))
				'if GetClassAcceptControls(GetClassName(FSelControl)) Then
				'R.Left   = FBeginX
				'R.Top    = FBeginY
				'R.Right  = FNewX
				'R.Bottom = FNewY
				'MapWindowPoints(FDialog, FSelControl, cast(POINT ptr, @R), 2)
				'if OnInsertingControl then
				'OnInsertingControl(this, FClass, FStyleEx, FStyle, FID)
				'end if
				'CreateControl(FClass, "", "", FSelControl, R.Left, R.Top, R.Right -R.Left, R.Bottom -R.Top)
				'else
				FClass = SelectedClass
				If OnInsertingControl Then
					FName = SelectedClass
					OnInsertingControl(This, SelectedClass, FName)
				End If
				SelectedControl = GetContainerControl(SelectedControl)
				Dim As ..Rect R
				If SelectedControl <> DesignControl Then
						GetWindowRect FSelControl, @R
						MapWindowPoints 0, FDialog, Cast(..Point Ptr, @R), 2
				End If
				Dim ctr As Any Ptr
				ctr = SelectedControl
				If SelectedType = 3 Or SelectedType = 4 Then
					Dim cpnt As Any Ptr = CreateComponent(SelectedClass, FName, ctr, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top))
					If OnInsertComponent Then OnInsertComponent(This, FClass, cpnt, 0, 0, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top))
					If FSelControl Then
						SelectedControls.Clear
					End If
						MoveDots(cpnt)
						'LockWindowUpdate(0)
				Else
					CreateControl(SelectedClass, FName, FName, ctr, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top), FNewX - FBeginX, FNewY - FBeginY)
					If FSelControl Then
						SelectedControls.Clear
							LockWindowUpdate(FSelControl)
							BringWindowToTop(FSelControl)
						If OnInsertControl Then OnInsertControl(This, FClass, SelectedControl, 0, 0, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top), FNewX - FBeginX, FNewY - FBeginY)
							MoveDots(SelectedControl)
							LockWindowUpdate(0)
					Else
						Dim cpnt As Any Ptr = CreateComponent(FClass, FName, ctr, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top))
						If cpnt Then
							If OnInsertComponent Then OnInsertComponent(This, FClass, cpnt, 0, 0, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top))
							If FSelControl Then
								SelectedControls.Clear
							End If
								MoveDots(cpnt)
								'LockWindowUpdate(0)
						Else
							SelectedControl = DesignControl
							MoveDots(SelectedControl)
						End If
					End If
				End If
				FCanInsert = False
			End If
			If FCanSize Then
				FCanSize = False
				If FBeginX <> FNewX OrElse FBeginY <> FNewY Then
					For j As Integer = 0 To SelectedControls.Count - 1
						If OnModified Then OnModified(This, SelectedControls.Items[j], , , , FLeftNew(j), FTopNew(j), FWidthNew(j), FHeightNew(j))
					Next j
				End If
				MoveDots(SelectedControl)
			End If
			If FCanMove Then
				FCanMove = False
				If FBeginX <> FEndX OrElse FBeginY <> FEndY Then
					For j As Integer = 0 To SelectedControls.Count - 1
						If OnModified Then OnModified(This, SelectedControls.Items[j], , , , FLeft(j) + (FEndX - FBeginX), FTop(j) + (FEndY - FBeginY), FWidth(j), FHeight(j))
					Next
				End If
				MoveDots(SelectedControl)
			End If
			FBeginX = FEndX
			FBeginY = FEndY
			FNewX   = FBeginX
			FNewY   = FBeginY
				ClipCursor(0)
				ReleaseCapture
		Else
				ClipCursor(0)
		End If
	End Sub
	
	Sub Designer.SelectAllControls()
		If DesignControl Then
			SelectedControls.Clear
			Dim As Any Ptr Ctrl
			Dim As SymbolsType Ptr st = Symbols(DesignControl)
			If st AndAlso st->ReadPropertyFunc AndAlso st->ControlByIndexFunc Then
				For i As Integer = 0 To iGet(st->ReadPropertyFunc(DesignControl, "ControlCount")) - 1
					Ctrl = st->ControlByIndexFunc(DesignControl, i)
					SelectedControls.Add Ctrl
				Next
			End If
			If Ctrl = 0 Then SelectedControl = DesignControl Else SelectedControl = Ctrl
			MoveDots SelectedControl
		End If
	End Sub
	
	Sub Designer.DeleteControls(Ctrl As Any Ptr, EventOnly As Boolean = False)
		Dim As SymbolsType Ptr st = Symbols(Ctrl)
		If Controls.Contains(Ctrl) Then
			If st AndAlso st->ReadPropertyFunc AndAlso st->ControlByIndexFunc Then
				For i As Integer = 0 To iGet(st->ReadPropertyFunc(Ctrl, "ControlCount")) - 1
					DeleteControls st->ControlByIndexFunc(Ctrl, i), EventOnly
				Next
			End If
		End If
		If OnDeleteControl Then OnDeleteControl(This, Ctrl)
		If EventOnly Then
			If st AndAlso CInt(st->IsControlFunc) AndAlso CInt(st->IsControlFunc(Ctrl)) Then
				If st->ControlFreeWndSub Then st->ControlFreeWndSub(Ctrl)
			ElseIf st AndAlso st->ReadPropertyFunc Then
					Dim As HWND Ptr phWnd = st->ReadPropertyFunc(Ctrl, "Handle")
					If phWnd <> 0 AndAlso *phWnd <> 0 Then DestroyWindow *phWnd
			End If
		Else
			If Controls.Contains(Ctrl) Then
				If st AndAlso st->ReadPropertyFunc Then
					Dim As Any Ptr AParent = st->ReadPropertyFunc(Ctrl, "Parent")
					If st->RemoveControlSub AndAlso AParent Then st->RemoveControlSub(AParent, Ctrl)
					If st->WritePropertyFunc Then
						If st->ReadPropertyFunc(DesignControl, "CancelButton") = Ctrl Then
							st->WritePropertyFunc(DesignControl, "CancelButton", 0)
							If OnModified Then OnModified(This, DesignControl, "CancelButton")
						End If
						If st->ReadPropertyFunc(DesignControl, "DefaultButton") = Ctrl Then
							st->WritePropertyFunc(DesignControl, "DefaultButton", 0)
							If OnModified Then OnModified(This, DesignControl, "DefaultButton")
						End If
					End If
				End If
				Controls.Remove Controls.IndexOf(Ctrl)
			End If
			If Objects.Contains(Ctrl) Then
				If st AndAlso st->ReadPropertyFunc AndAlso st->WritePropertyFunc Then
					If st->ReadPropertyFunc(DesignControl, "Menu") = Ctrl Then
						st->WritePropertyFunc(DesignControl, "Menu", 0)
						If OnModified Then OnModified(This, DesignControl, "Menu")
					End If
					For i As Integer = Objects.Count - 1 To 0 Step -1
						If Objects.Item(i) > 0 AndAlso st->ReadPropertyFunc(Objects.Item(i), "Parent") = Ctrl Then
							DeleteControls Objects.Item(i), EventOnly
						End If
						If Objects.Item(i) > 0 AndAlso st->ReadPropertyFunc(Objects.Item(i), "ParentMenu") = Ctrl Then
							DeleteControls Objects.Item(i), EventOnly
						End If
					Next
				End If
				Objects.Remove Objects.IndexOf(Ctrl)
			End If
			If st AndAlso st->DeleteComponentFunc Then
				'If ReadPropertyFunc(Ctrl, "Tag") <> 0 Then Delete_(Cast(Dictionary Ptr, ReadPropertyFunc(Ctrl, "Tag")))
				st->DeleteComponentFunc(Ctrl)
			End If
		End If
		'if OnModified then OnModified(this, Ctrl, , , , -1, -1, -1, -1)
	End Sub
	
	Sub Designer.DeleteControl()
		If SelectedControl Then
			If SelectedControl <> DesignControl Then
				For i As Integer = 0 To SelectedControls.Count - 1
					DeleteControls SelectedControls.Item(i)
				Next
				FSelControl = FDialog
				SelectedControls.Clear
				SelectedControl = DesignControl
				SelectedControls.Add SelectedControl
				MoveDots SelectedControl
			End If
		End If
	End Sub
	
	Sub Designer.DeleteMenuItems(pMenu As Any Ptr, mi As Any Ptr)
		Dim As SymbolsType Ptr st = Symbols(mi)
		If st AndAlso st->ReadPropertyFunc AndAlso st->MenuItemByIndexFunc Then
			For i As Integer = iGet(st->ReadPropertyFunc(mi, "Count")) - 1 To 0 Step -1
				DeleteMenuItems pMenu, st->MenuItemByIndexFunc(mi, i)
			Next
		End If
		If OnDeleteControl Then OnDeleteControl(This, mi)
		If st Then
			Dim As Any Ptr AParent = st->ReadPropertyFunc(mi, "ParentMenuItem")
			If AParent Then
				Dim As SymbolsType Ptr st = Symbols(AParent)
				If st AndAlso st->MenuItemRemoveSub Then st->MenuItemRemoveSub(AParent, mi)
			Else
				Dim As SymbolsType Ptr st = Symbols(pMenu)
				If st AndAlso st->MenuRemoveSub Then st->MenuRemoveSub(pMenu, mi)
			End If
			If st->ObjectDeleteFunc Then
				st->ObjectDeleteFunc(mi)
			End If
		End If
	End Sub
	
	'sub Designer.DeleteControl(hDlg as HWND)
	'	if IsWindow(hDlg) then
	'		if hDlg <> FDialog then
	'		   if OnDeleteControl then OnDeleteControl(this, GetControl(hDlg))
	'		   DestroyWindow(hDlg)
	'		   if OnModified then OnModified(this, GetControl(hDlg))
	'		   FSelControl = FDialog
	'		   MoveDots SelectedControl
	'	   end if
	'	end if
	'end sub
	Dim Shared CopyList As PointerList
	Sub Designer.CopyControl()
		CopyList.Clear
			If IsWindow(FSelControl) Then
			If FSelControl <> FDialog Then
				For j As Integer = 0 To SelectedControls.Count - 1
					Dim As SymbolsType Ptr st = Symbols(SelectedControls.Items[j])
					CopyList.Add SelectedControls.Items[j], st
				Next
					'Save data to system clipboard
					Dim As UInteger fformat = RegisterClipboardFormat("VFEFormat") 'Register our data format
					If (OpenClipboard(NULL)) Then 'To use the clipboard, you must open it.
						'Fill in our data structure
						Dim As HGLOBAL hgBuffer
						EmptyClipboard()  'Clear buffer
						hgBuffer = GlobalAlloc(GMEM_DDESHARE, SizeOf(UInteger)) 'Allocate memory
						Dim As UInteger Ptr buffer = Cast(UInteger Ptr, GlobalLock(hgBuffer))
						'Write data to memory
						*buffer = Cast(UInteger, @CopyList)
						'Copy data to clipboard
						GlobalUnlock(hgBuffer)
						SetClipboardData(fformat, hgBuffer) 'Place data on clipboard
						CloseClipboard() 'Close clipboard when done.
					End If
			End If
		End If
	End Sub
	
	Sub Designer.CutControl()
			If IsWindow(FSelControl) Then
			If FSelControl <> FDialog Then
				CopyControl
				For j As Integer = 0 To SelectedControls.Count - 1
					DeleteControls SelectedControls.Items[j], True
				Next
				'if OnModified then OnModified(this, GetControl(FSelControl))
				FSelControl = FDialog
				SelectedControl = DesignControl
				MoveDots SelectedControl
			End If
		End If
	End Sub
	
	Sub Designer.AddPasteControls(Ctrl As Any Ptr, st As SymbolsType Ptr, ByVal ParentCtrl As Any Ptr, bStart As Boolean)
		Dim As Integer iStepX, iStepY
		If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
		If bStart Then
			iStepX = GridSize
			iStepY = GridSize
			If Ctrl = ParentCtrl Then ParentCtrl = st->ReadPropertyFunc(Ctrl, "Parent")
		End If
		If OnInsertingControl Then
			FName = WGet(st->ReadPropertyFunc(Ctrl, "Name"))
			OnInsertingControl(This, WGet(st->ReadPropertyFunc(Ctrl, "ClassName")), FName)
		End If
		Dim As Integer FLeft, FTop, FWidth, FHeight
		If st->ComponentGetBoundsSub AndAlso st->Q_ComponentFunc Then st->ComponentGetBoundsSub(st->Q_ComponentFunc(Ctrl), FLeft, FTop, FWidth, FHeight)
		Dim As Any Ptr NewCtrl
		If st->IsControlFunc <> 0 AndAlso st->IsControlFunc(Ctrl) Then
			NewCtrl = This.CreateControl(WGet(st->ReadPropertyFunc(Ctrl, "ClassName")), FName, WGet(st->ReadPropertyFunc(Ctrl, "Text")), ParentCtrl, FLeft + iStepX, FTop + iStepY, FWidth, FHeight)
		Else
			NewCtrl = This.CreateComponent(WGet(st->ReadPropertyFunc(Ctrl, "ClassName")), FName, ParentCtrl, FLeft + iStepX, FTop + iStepY)
		End If
		If FSelControl Then
				LockWindowUpdate(FSelControl)
				BringWindowToTop(FSelControl)
			Dim As String AClassName = WGet(st->ReadPropertyFunc(Ctrl, "ClassName"))
			Dim As SymbolsType Ptr st = Symbols(AClassName)
			CtrlSymbols.Add Ctrl, st
			If OnInsertControl Then OnInsertControl(This, WGet(st->ReadPropertyFunc(Ctrl, "ClassName")), NewCtrl, Ctrl, 0, FLeft + iStepX, FTop + iStepY, FWidth, FHeight)
			If bStart Then SelectedControls.Add NewCtrl
		End If
		If Controls.Contains(Ctrl) Then
			If st->ControlByIndexFunc Then
				For i As Integer = 0 To iGet(st->ReadPropertyFunc(Ctrl, "ControlCount")) - 1
					AddPasteControls st->ControlByIndexFunc(Ctrl, i), st, NewCtrl, False
				Next
			End If
		End If
	End Sub
	
	Sub Designer.PasteControl()
			If IsWindow(FSelControl) Then
				'Read our data from the clipboard; second call is just to get the format
				'Second call only to obtain the format
				Dim As UInteger fformat = RegisterClipboardFormat("VFEFormat")
			Dim ParentCtrl As Any Ptr = GetControl(FSelControl)
			Dim As SymbolsType Ptr st = Symbols(ParentCtrl)
			If st AndAlso st->ControlIsContainerFunc <> 0 AndAlso st->ReadPropertyFunc <> 0 Then
				If Not st->ControlIsContainerFunc(ParentCtrl) Then ParentCtrl = st->ReadPropertyFunc(ParentCtrl, "Parent")
			End If
				If Clipboard.HasFormat(fformat) Then
					If ( OpenClipboard(NULL) ) Then
						'Extract data from buffer
						Dim As HANDLE hData = GetClipboardData(fformat)
						Dim As UInteger Ptr buffer = Cast(UInteger Ptr, GlobalLock( hData ))
						GlobalUnlock( hData )
						CloseClipboard()
						Dim As PointerList Ptr Value = Cast(Any Ptr, *buffer)
					'If ReadPropertyFunc <> 0 AndAlso ComponentGetBoundsSub <> 0 Then
					SelectedControls.Clear
					For j As Integer = 0 To Value->Count - 1
						If FSelControl Then AddPasteControls Value->Item(j), Value->Object(j), ParentCtrl, True
						MoveDots(SelectedControl)
							LockWindowUpdate(0)
					Next
					End If
				End If
			'if OnModified then OnModified(this, GetControl(hDlg))
			'FSelControl = FDialog
		End If
	End Sub
	
	Sub Designer.DuplicateControl()
		CopyControl
		PasteControl
	End Sub
	
		Sub Designer.UnHookControl(Control As HWND)
			If Control AndAlso IsWindow(Control) Then
				If GetWindowLongPtr(Control, GWLP_WNDPROC) = @HookChildProc Then
					SetWindowLongPtr(Control, GWLP_WNDPROC, CInt(GetProp(Control, "@@@Proc")))
					RemoveProp(Control, "@@@Designer")
					RemoveProp(Control, "@@@Proc")
				End If
				GetChilds(Control)
				For i As Integer = 0 To FChilds.Count - 1
					If GetWindowLongPtr(FChilds.Child[i], GWLP_WNDPROC) = @HookChildProc Then
						SetWindowLongPtr(FChilds.Child[i], GWLP_WNDPROC, CInt(GetProp(FChilds.Child[i], "@@@Proc")))
						RemoveProp(FChilds.Child[i], "@@@Designer")
						RemoveProp(FChilds.Child[i], "@@@Proc")
					End If
				Next
			End If
		End Sub
	
		Sub Designer.HookControl(Control As HWND)
			If IsWindow(Control) Then
				SetProp(Control, "@@@Designer", @This)
				If GetWindowLongPtr(Control, GWLP_WNDPROC) <> @HookChildProc Then
					SetProp(Control, "@@@Proc", Cast(WNDPROC, SetWindowLongPtr(Control, GWLP_WNDPROC, CInt(@HookChildProc))))
				End If
			End If
			GetChilds(Control)
			For i As Integer = 0 To FChilds.Count - 1
				SetProp(FChilds.Child[i], "@@@Designer", @This)
				'SetWindowLongPtr(FChilds.Child[i], GWLP_USERDATA, CInt(GetControl(Control)))
				If GetProp(FChilds.Child[i], "MFFControl") = 0 Then SetProp(FChilds.Child[i], "MFFControl", GetControl(Control))
				If GetWindowLongPtr(FChilds.Child[i], GWLP_WNDPROC) <> @HookChildProc Then
					SetProp(FChilds.Child[i], "@@@Proc", Cast(WNDPROC, SetWindowLongPtr(FChilds.Child[i], GWLP_WNDPROC, CInt(@HookChildProc))))
				End If
			Next
	End Sub
	
	Function Designer.CreateControl(AClassName As String, ByRef AName As WString, ByRef AText As WString, AParent As Any Ptr, x As Integer, y As Integer, cx As Integer, cy As Integer, bNotHook As Boolean = False) As Any Ptr
		On Error Goto ErrorHandler
		Dim As SymbolsType Ptr st = Symbols(AClassName)
		Ctrl = 0
		FSelControl = 0
			Dim As HWND ParentHandle
		If st Then
			If st->CreateControlFunc <> 0 Then
				ChDir GetFolderName(st->Path)
				Ctrl = st->CreateControlFunc(AClassName, _
				AName, _
				AText, _
				x, _
				y, _
				IIf(cx, cx, 50), _
				IIf(cy, cy, 50), _
				AParent)
				If Ctrl Then
					Objects.Add Ctrl
					CtrlSymbols.Add Ctrl, st
					Components.Add Ctrl
					Controls.Add Ctrl
					SelectedControl = Ctrl
					If st->ReadPropertyFunc Then
							Dim As HWND Ptr hHandle = st->ReadPropertyFunc(Ctrl, "Handle")
							If AParent <> 0 Then ParentHandle = *Cast(HWND Ptr, st->ReadPropertyFunc(AParent, "Handle"))
							If hHandle <> 0 Then FSelControl = *hHandle
					End If
					If st->WritePropertyFunc Then
						Dim As Boolean bTrue = True
						st->WritePropertyFunc(Ctrl, "DesignMode", @bTrue)
						st->WritePropertyFunc(Ctrl, "ControlDesigner", @This)
						st->WritePropertyFunc(Ctrl, "Loading", @Loading)
					End If
				Else

				End If
			End If
		End If
		SelectedClass = ""
			If IsWindow(FSelControl) Then
				If Not bNotHook Then
					If GetParent(FSelControl) <> ParentHandle Then
						HookControl(GetParent(FSelControl))
					Else
						HookControl(FSelControl)
					End If
					'AName = iif(AName="", AName = AClassName & ...)
					'SetProp(Control, "Name", ...)
					'possibly using in propertylist inspector
					Select Case GetClassNameOf(FSelControl)
					Case "ToolBar", "ToolPalette"
						RedrawWindow FSelControl, 0, 0, RDW_INVALIDATE
						UpdateWindow FSelControl
					End Select
				End If
			End If
		'DyLibFree(MFF)
		Return Ctrl
		Exit Function
		ErrorHandler:
		MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
	End Function
	
	
	Function Designer.Symbols(Ctrl As Any Ptr) As SymbolsType Ptr
		If Ctrl = 0 Then Return 0
		If Ctrl = OldCtrl Then Return OldCtrlSymbols
		Var Idx = 0
		If CtrlSymbols.Contains(Ctrl, Idx) Then
			OldCtrlSymbols = CtrlSymbols.Object(Idx)
			OldCtrl = Ctrl
			Return OldCtrlSymbols
		End If
		OldCtrlSymbols = 0
		OldCtrl = Ctrl
		Return 0
	End Function
	
	Function Designer.SymbolsReadProperty(Ctrl As Any Ptr) As SymbolsType Ptr
		Dim As SymbolsType Ptr st = Symbols(Ctrl)
		If st AndAlso st->ReadPropertyFunc Then Return st Else Return 0
	End Function
	
	Function Designer.SymbolsWriteProperty(Ctrl As Any Ptr) As SymbolsType Ptr
		Dim As SymbolsType Ptr st = Symbols(Ctrl)
		If st AndAlso st->WritePropertyFunc Then Return st Else Return 0
	End Function
	
	Function Designer.Symbols(AClassName As String) As SymbolsType Ptr
		If OldClassName = AClassName Then Return OldSymbols
		Var Idx = 0
		If Comps.Contains(AClassName, , , , Idx) Then
			Dim As TypeElement Ptr te = Comps.Object(Idx)
			If te <> 0 AndAlso te->Tag <> 0 Then
				If OldLibrary = te->Tag Then Return OldSymbols
				Dim As Integer libIdx = -1
				If FLibs.Contains(te->Tag, libIdx) Then
					OldClassName = AClassName
					OldLibrary = te->Tag
					OldSymbols = FSymbols.Item(libIdx)
					Return OldSymbols
				Else
					Dim As Library Ptr CtlLib = te->Tag
					Dim As UString dllPath = GetFullPath(CtlLib->Path)
					Dim As Any Ptr libHandle = DyLibLoad(dllPath)
					If libHandle = 0 AndAlso CtlLib->Handle <> 0 Then
						'' CtlLib->Path can be a folder (not the .dll) after a project opens, so
						'' DyLibLoad fails even though the module is already loaded. Re-load it by its
						'' real on-disk path (recovered from the live handle) so the refcount stays
						'' balanced: the Designer destructor DyLibFree's st->Handle, and borrowing the
						'' handle without a matching DyLibLoad would unload framework.dll after the first
						'' designer closes and break every project opened afterwards.
						Dim As WString * (MAX_PATH + 1) modPath
						If GetModuleFileNameW(Cast(HMODULE, CtlLib->Handle), @modPath, MAX_PATH) > 0 Then
							dllPath = modPath
							libHandle = DyLibLoad(dllPath)
						End If
					End If
					If libHandle = 0 Then Goto SymbolsFailed
					If CtlLib->Handle = 0 Then CtlLib->Handle = libHandle
					Var st = _New(SymbolsType)
					st->Handle = libHandle
					st->Path = dllPath
					st->CreateControlFunc = DyLibSymbol(libHandle, "CreateControl")
					st->CreateComponentFunc = DyLibSymbol(libHandle, "CreateComponent")
					st->ReadPropertyFunc = DyLibSymbol(libHandle, "ReadProperty")
					st->WritePropertyFunc = DyLibSymbol(libHandle, "WriteProperty")
					st->DeleteComponentFunc = DyLibSymbol(libHandle, "DeleteComponent")
					st->DeleteAllObjectsFunc = DyLibSymbol(libHandle, "DeleteAllObjects")
					st->RemoveControlSub = DyLibSymbol(libHandle, "RemoveControl")
					st->ControlByIndexFunc = DyLibSymbol(libHandle, "ControlByIndex")
					st->Q_ComponentFunc = DyLibSymbol(libHandle, "Q_Component")
					st->ComponentGetBoundsSub = DyLibSymbol(libHandle, "ComponentGetBounds")
					st->ComponentSetBoundsSub = DyLibSymbol(libHandle, "ComponentSetBounds")
					st->ControlIsContainerFunc = DyLibSymbol(libHandle, "ControlIsContainer")
					st->IsControlFunc = DyLibSymbol(libHandle, "IsControl")
					st->IsComponentFunc = DyLibSymbol(libHandle, "IsComponent")
					st->ControlSetFocusSub = DyLibSymbol(libHandle, "ControlSetFocus")
					st->ControlFreeWndSub = DyLibSymbol(libHandle, "ControlFreeWnd")
					st->ControlRepaintSub = DyLibSymbol(libHandle, "ControlRepaint")
					st->ToStringFunc = DyLibSymbol(libHandle, "ToString")
					st->CreateObjectFunc = DyLibSymbol(libHandle, "CreateObject")
					st->ObjectDeleteFunc = DyLibSymbol(libHandle, "ObjectDelete")
					st->MenuByIndexFunc = DyLibSymbol(libHandle, "MenuByIndex")
					st->MenuItemByIndexFunc = DyLibSymbol(libHandle, "MenuItemByIndex")
					st->MenuFindByCommandFunc = DyLibSymbol(libHandle, "MenuFindByCommand")
					st->MenuRemoveSub = DyLibSymbol(libHandle, "MenuRemove")
					st->MenuItemRemoveSub = DyLibSymbol(libHandle, "MenuItemRemove")
					st->ToolBarButtonByIndexFunc = DyLibSymbol(libHandle, "ToolBarButtonByIndex")
					st->ToolBarRemoveButtonSub = DyLibSymbol(libHandle, "ToolBarRemoveButton")
					st->StatusBarPanelByIndexFunc = DyLibSymbol(libHandle, "StatusBarPanelByIndex")
					st->StatusBarRemovePanelSub = DyLibSymbol(libHandle, "StatusBarRemovePanel")
					st->GraphicTypeLoadFromFileFunc = DyLibSymbol(libHandle, "GraphicTypeLoadFromFile")
					st->BitmapTypeLoadFromFileFunc = DyLibSymbol(libHandle, "BitmapTypeLoadFromFile")
					st->IconLoadFromFileFunc = DyLibSymbol(libHandle, "IconLoadFromFile")
					st->CursorLoadFromFileFunc = DyLibSymbol(libHandle, "CursorLoadFromFile")
					st->ImageListAddFromFileSub = DyLibSymbol(libHandle, "ImageListAddFromFile")
					st->ImageListIndexOfFunc = DyLibSymbol(libHandle, "ImageListIndexOf")
					st->ImageListClearSub = DyLibSymbol(libHandle, "ImageListClear")
					If st->CreateControlFunc = 0 Then
						_Delete(st)
						Goto SymbolsFailed
					End If
					FSymbols.Add st
					FLibs.Add CtlLib
					OldClassName = AClassName
					OldLibrary = CtlLib
					OldSymbols = st
					Return st
				End If
			End If
		End If
SymbolsFailed:
		OldClassName = AClassName
		OldLibrary = 0
		OldSymbols = 0
		Return 0
	End Function
	
	Function Designer.CreateComponent(AClassName As String, AName As String, AParent As Any Ptr, x As Integer, y As Integer, bNotHook As Boolean = False) As Any Ptr
		Dim As SymbolsType Ptr st = Symbols(AClassName)
		Dim As Any Ptr Cpnt
			FSelControl = 0
		If st Then
			If st->CreateComponentFunc <> 0 Then
				ChDir GetFolderName(st->Path)
				Cpnt = st->CreateComponentFunc(AClassName, AName, x, y, AParent)
				If Cpnt Then
					Objects.Add Cpnt
					Components.Add Cpnt
					CtrlSymbols.Add Cpnt, st
					SelectedControl = Cpnt
					If st->WritePropertyFunc Then
						Dim As Boolean bTrue = True
						st->WritePropertyFunc(Cpnt, "DesignMode", @bTrue)
						Dim As BitmapType pBitmap
							If st->ReadPropertyFunc Then
								pBitmap.LoadFromResourceName(AClassName, st->Handle)
								Dim As HWND Ptr Result
								If AParent <> 0 Then Result = Cast(HWND Ptr, st->ReadPropertyFunc(AParent, "Handle"))
								If AParent = 0 OrElse Result = 0 OrElse *Result = 0 Then
									FSelControl = CreateWindowExW(0, "Button", Cast(LPCWSTR, @""), WS_CHILD Or BS_BITMAP, ScaleX(x), ScaleY(y), ScaleX(16), ScaleY(16), *Cast(HWND Ptr, st->ReadPropertyFunc(DesignControl, "Handle")), Cast(HMENU, 1000), Instance, Cpnt)
								Else
									FSelControl = CreateWindowExW(0, "Button", Cast(LPCWSTR, @""), WS_CHILD Or BS_BITMAP, ScaleX(x), ScaleY(y), ScaleX(16), ScaleY(16), *Result, Cast(HMENU, 1000), Instance, Cpnt)
								End If
								st->WritePropertyFunc(Cpnt, "Handle", @FSelControl)
								SetWindowLongPtr(FSelControl, GWLP_USERDATA, CInt(Cpnt))
								SetProp(FSelControl, "MFFControl", Cpnt)
								SendMessage(FSelControl, BM_SETIMAGE, 0, Cast(LPARAM, pBitmap.Handle))
								ShowWindow(FSelControl, SW_SHOWNORMAL)
							End If
					End If
				End If
			End If
		End If
			If IsWindow(FSelControl) Then
				If Not bNotHook Then
					HookControl(FSelControl)
					'AName = iif(AName="", AName = AClassName & ...)
					'SetProp(Control, "Name", ...)
					'possibly using in propertylist inspector
				End If
			End If
		SelectedClass = ""
		Return Cpnt
	End Function
	
	Function Designer.CreateObject(AClassName As String) As Any Ptr
		Dim As SymbolsType Ptr st = Symbols(AClassName)
		Dim As Any Ptr Obj
		If st Then
			If st->CreateObjectFunc <> 0 Then
				ChDir GetFolderName(st->Path)
				Obj = st->CreateObjectFunc(AClassName)
				If Obj Then
					Objects.Add Obj
					CtrlSymbols.Add Obj, st
				End If
			End If
		End If
		Return Obj
	End Function
	
	Sub Designer.UpdateGrid
			InvalidateRect(FDialog, 0, True)
	End Sub
	
	Sub Designer.DrawTopMenu()
			Dim As HDC FHDc
			Dim As ..Rect R
			Dim As PAINTSTRUCT Ps
			FHDc = BeginPaint(TopMenu->Handle, @Ps)
			Dim As HPEN Pen = CreatePen(PS_SOLID, 0, BGR(255, 255, 255))
			Dim As HPEN PrevPen = SelectObject(FHDc, Pen)
			Dim As HBRUSH Brush = CreateSolidBrush(BGR(255, 255, 255))
			Dim As HBRUSH PrevBrush = SelectObject(FHDc, Brush)
			Dim Sz As ..Size
			GetClientRect(TopMenu->Handle, @R)
			Dim As SymbolsType Ptr st = Symbols(DesignControl)
			If st AndAlso st->ReadPropertyFunc Then
				Dim As Any Ptr CurrentMenu = st->ReadPropertyFunc(DesignControl, "Menu")
				If CurrentMenu <> 0 Then
					RectsCount = 0
					SelectObject(FHDc, TopMenu->Font.Handle)
					Rectangle FHDc, 0, 0, ScaleX(TopMenu->Width), ScaleY(TopMenu->Height)
					DeleteObject(Pen)
					DeleteObject(Brush)
					Dim As SymbolsType Ptr st = Symbols(CurrentMenu)
					If st AndAlso st->ReadPropertyFunc AndAlso st->MenuByIndexFunc Then
						For i As Integer = 0 To QInteger(st->ReadPropertyFunc(CurrentMenu, "Count")) - 1
							RectsCount += 1
							ReDim Preserve Ctrls(RectsCount)
							ReDim Preserve Rects(RectsCount)
							Ctrls(RectsCount) = st->MenuByIndexFunc(CurrentMenu, i)
							If RectsCount = 1 Then
								Rects(RectsCount).Left = 0
							Else
								Rects(RectsCount).Left = Rects(RectsCount - 1).Right
							End If
							Rects(RectsCount).Top = 0
							GetTextExtentPoint32(FHDc, st->ReadPropertyFunc(Ctrls(RectsCount), "Caption"), Len(QWString(st->ReadPropertyFunc(Ctrls(RectsCount), "Caption"))), @Sz)
							Rects(RectsCount).Right = Rects(RectsCount).Left + UnScaleX(Sz.cx + 16)
							Rects(RectsCount).Bottom = Rects(RectsCount).Top + UnScaleY(Sz.cy + 6)
							If RectsCount = ActiveRect Then
								Pen = CreatePen(PS_SOLID, 0, BGR(153, 209, 255))
								Brush = CreateSolidBrush(BGR(204, 232, 255))
								SelectObject(FHDc, Pen)
								SelectObject(FHDc, Brush)
								Rectangle FHDc, ScaleX(Rects(RectsCount).Left), 0, ScaleX(Rects(RectsCount).Right), ScaleY(TopMenu->Height)
								DeleteObject(Pen)
								DeleteObject(Brush)
							ElseIf RectsCount = MouseRect Then
								Pen = CreatePen(PS_SOLID, 0, BGR(204, 232, 255))
								Brush = CreateSolidBrush(BGR(229, 243, 255))
								SelectObject(FHDc, Pen)
								SelectObject(FHDc, Brush)
								Rectangle FHDc, ScaleX(Rects(RectsCount).Left), 0, ScaleX(Rects(RectsCount).Right), ScaleY(TopMenu->Height)
								DeleteObject(Pen)
								DeleteObject(Brush)
							End If
							SetBkMode(FHDc, TRANSPARENT)
							SetTextColor(FHDc, IIf(QBoolean(st->ReadPropertyFunc(Ctrls(RectsCount), "Enabled")), BGR(0, 0, 0), BGR(109, 109, 109)))
							If QWString(st->ReadPropertyFunc(Ctrls(RectsCount), "Caption")) = "-" Then
								.TextOut(FHDc, ScaleX(Rects(RectsCount).Left) + 8, ScaleY(Rects(RectsCount).Top + 3), Cast(LPCWSTR, @"|"), 1)
							Else
								.TextOut(FHDc, ScaleX(Rects(RectsCount).Left) + 8, ScaleY(Rects(RectsCount).Top + 3), st->ReadPropertyFunc(Ctrls(RectsCount), "Caption"), Len(QWString(st->ReadPropertyFunc(Ctrls(RectsCount), "Caption"))))
							End If
							SetBkMode(FHDc, OPAQUE)
							'.TextOut Rects(RectsCount).Left + 5, Rects(RectsCount).Top + 3, QWString(Des->ReadPropertyFunc(Ctrls(RectsCount), "Caption")), BGR(0, 0, 0), -1
						Next i
					End If
				End If
			End If
			SelectObject(FHDc, PrevPen)
			SelectObject(FHDc, PrevBrush)
			EndPaint TopMenu->Handle, @Ps
	End Sub
	
	Sub Designer.DrawToolBar(Handle As Any Ptr)
			Dim As HDC FHDc
			Dim As ..Rect R
			Dim As PAINTSTRUCT Ps
			FHDc = BeginPaint(Handle, @Ps)
			Dim As HPEN Pen = CreatePen(PS_SOLID, 0, GetSysColor(COLOR_BTNFACE))
			Dim As HPEN PrevPen = SelectObject(FHDc, Pen)
			Dim As HBRUSH Brush = CreateSolidBrush(GetSysColor(COLOR_BTNFACE))
			Dim As HBRUSH PrevBrush = SelectObject(FHDc, Brush)
			Dim Sz As ..Size
			Dim As Any Ptr ImagesList
			Dim As Any Ptr ImagesListHandle
			GetClientRect(Handle, @R)
			Dim As Any Ptr Ctrl = GetControl(Handle)
			If Ctrl <> 0 Then
				Dim Rects(Any) As ..Rect
				Dim Ctrls(Any) As Any Ptr
				Dim As Integer RectsCount, BitmapWidth, BitmapHeight
				Dim As Boolean IsToolBarList
				Dim As SymbolsType Ptr st = Symbols(Ctrl)
				If st AndAlso st->ReadPropertyFunc AndAlso st->ToolBarButtonByIndexFunc Then
					BitmapWidth = QInteger(st->ReadPropertyFunc(Ctrl, "BitmapWidth"))
					BitmapHeight = QInteger(st->ReadPropertyFunc(Ctrl, "BitmapHeight"))
					IsToolBarList = QBoolean(st->ReadPropertyFunc(Ctrl, "List"))
					ImagesList = st->ReadPropertyFunc(Ctrl, "ImagesList")
					If ImagesList <> 0 Then ImagesListHandle = st->ReadPropertyFunc(ImagesList, "ImageListHandle")
					RectsCount = 0
					SelectObject(FHDc, TopMenu->Font.Handle)
					Rectangle FHDc, 0, 0, R.Right - R.Left, R.Bottom - R.Top
					DeleteObject(Pen)
					DeleteObject(Brush)
					For i As Integer = 0 To QInteger(st->ReadPropertyFunc(Ctrl, "ButtonsCount")) - 1
						RectsCount += 1
						ReDim Preserve Rects(RectsCount)
						ReDim Preserve Ctrls(RectsCount)
						Ctrls(RectsCount) = st->ToolBarButtonByIndexFunc(Ctrl, i)
						If RectsCount = 1 Then
							Rects(RectsCount).Left = 0
						Else
							Rects(RectsCount).Left = Rects(RectsCount - 1).Right + 1
						End If
						Rects(RectsCount).Top = 0
						Rects(RectsCount).Right = Rects(RectsCount).Left + QInteger(st->ReadPropertyFunc(Ctrls(RectsCount), "Width"))
						Rects(RectsCount).Bottom = Rects(RectsCount).Top + QInteger(st->ReadPropertyFunc(Ctrls(RectsCount), "Height")) - 1
						'					If RectsCount = ActiveRect Then
						'						.Pen.Color = BGR(0, 120, 215)
						'						.Brush.Color = BGR(174, 215, 247)
						'						.Rectangle Rects(RectsCount)
						'					End If
						If ImagesListHandle <> 0 Then
							Dim As UString ImageKey = WGet(st->ReadPropertyFunc(Ctrls(RectsCount), "ImageKey"))
							Dim As Integer ImageIndex = QInteger(st->ReadPropertyFunc(Ctrls(RectsCount), "ImageIndex"))
							If ImageKey <> "" Then
								Dim As SymbolsType Ptr st = Symbols(ImagesList)
								If st AndAlso st->ImageListIndexOfFunc Then ImageIndex = st->ImageListIndexOfFunc(ImagesList, ImageKey)
							End If
							If ImageIndex > -1 Then
									ImageList_Draw(ImagesListHandle, ImageIndex, FHDc, ScaleX(Rects(RectsCount).Left + IIf(IsToolBarList, 3, (Rects(RectsCount).Right - Rects(RectsCount).Left - BitmapWidth - IIf(QInteger(st->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = ToolButtonStyle.tbsDropDown, 15, 0) - IIf(QInteger(st->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = ToolButtonStyle.tbsWholeDropdown, 10, 0)) / 2)), ScaleY(Rects(RectsCount).Top + IIf(Rects(RectsCount).Bottom - Rects(RectsCount).Top - 6 < BitmapHeight, 3, 3)), ILD_TRANSPARENT)
							End If
						End If
						Select Case QInteger(st->ReadPropertyFunc(Ctrls(RectsCount), "Style"))
						Case ToolButtonStyle.tbsDropDown, ToolButtonStyle.tbsWholeDropdown
							Pen = CreatePen(PS_SOLID, 0, BGR(0, 0, 0))
							SelectObject(FHDc, Pen)
							Brush = CreateSolidBrush(BGR(0, 0, 0))
							SelectObject(FHDc, Brush)
							.MoveToEx FHDc, ScaleX(Rects(RectsCount).Right - 11), ScaleY(Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) - 1), 0
							.LineTo FHDc, ScaleX(Rects(RectsCount).Right - 5), ScaleY(Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) - 1)
							.LineTo FHDc, ScaleX(Rects(RectsCount).Right - 8), ScaleY(Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) + 2)
							.LineTo FHDc, ScaleX(Rects(RectsCount).Right - 11), ScaleY(Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2) - 1)
							.ExtFloodFill FHDc, ScaleX(Rects(RectsCount).Right - 8), ScaleY(Rects(RectsCount).Top + Fix((Rects(RectsCount).Bottom - Rects(RectsCount).Top) / 2)), 0, FLOODFILLBORDER
							DeleteObject(Pen)
							DeleteObject(Brush)
						End Select
						GetTextExtentPoint32(FHDc, st->ReadPropertyFunc(Ctrls(RectsCount), "Caption"), Len(QWString(st->ReadPropertyFunc(Ctrls(RectsCount), "Caption"))), @Sz)
						SetBkMode(FHDc, TRANSPARENT)
						SetTextColor(FHDc, IIf(QBoolean(st->ReadPropertyFunc(Ctrls(RectsCount), "Enabled")), BGR(0, 0, 0), BGR(109, 109, 109)))
						If QInteger(st->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = 7 Then
							Pen = CreatePen(PS_SOLID, 0, BGR(0, 0, 0))
							SelectObject(FHDc, Pen)
							.MoveToEx FHDc, ScaleX(Rects(RectsCount).Left + (Rects(RectsCount).Right - Rects(RectsCount).Left) / 2), ScaleY(Rects(RectsCount).Top + 5), 0
							.LineTo FHDc, ScaleX(Rects(RectsCount).Left + (Rects(RectsCount).Right - Rects(RectsCount).Left) / 2), ScaleY(Rects(RectsCount).Bottom)
							DeleteObject(Pen)
							Pen = CreatePen(PS_SOLID, 0, BGR(255, 255, 255))
							SelectObject(FHDc, Pen)
							.MoveToEx FHDc, ScaleX(Rects(RectsCount).Left + (Rects(RectsCount).Right - Rects(RectsCount).Left) / 2 + 1), ScaleY(Rects(RectsCount).Top + 5), 0
							.LineTo FHDc, ScaleX(Rects(RectsCount).Left + (Rects(RectsCount).Right - Rects(RectsCount).Left) / 2 + 1), ScaleY(Rects(RectsCount).Bottom)
							DeleteObject(Pen)
						Else
							.TextOut(FHDc, ScaleX(Rects(RectsCount).Left + IIf(IsToolBarList, BitmapWidth + 7, (Rects(RectsCount).Right - Rects(RectsCount).Left - UnScaleX(Sz.cx) - IIf(QInteger(st->ReadPropertyFunc(Ctrls(RectsCount), "Style")) = ToolButtonStyle.tbsDropDown, 15, 0)) / 2)), _
							ScaleY(IIf(IsToolBarList, Rects(RectsCount).Top + (Rects(RectsCount).Bottom - Rects(RectsCount).Top - UnScaleY(Sz.cy)) / 2, Rects(RectsCount).Bottom - UnScaleY(Sz.cy) - 6)), st->ReadPropertyFunc(Ctrls(RectsCount), "Caption"), Len(QWString(st->ReadPropertyFunc(Ctrls(RectsCount), "Caption"))))
						End If
					Next i
				End If
			End If
			SelectObject(FHDc, PrevPen)
			SelectObject(FHDc, PrevBrush)
			EndPaint Handle, @Ps
	End Sub
	
	Sub Designer.DrawThis()
		FStepX = GridSize
		FStepY = GridSize
			Dim As HDC mDc
			Dim As HBITMAP mBMP, pBMP
			Dim As ..Rect R, BrushRect = Type(0, 0, ScaleX(FStepX), ScaleY(FStepY))
			Dim As PAINTSTRUCT Ps
			Dim As Boolean WithGraphic
			Dim As Integer BackColor
			Dim As SymbolsType Ptr st = Symbols(DesignControl)
			If st AndAlso st->ReadPropertyFunc Then BackColor = QInteger(st->ReadPropertyFunc(DesignControl, "BackColor"))
			Dim As HBRUSH Brush = CreateSolidBrush(BackColor)
			FHDC = BeginPaint(FDialog,@Ps)
			GetClientRect(FDialog, @R)
			If BitmapHandle <> 0 Then
				FillRect(FHDC, @R, Brush) 'Cast(HBRUSH, 16))
				With Parent->Canvas
					.HandleSetted = True
					.Handle = FHDC
					.Draw 0, 0, BitmapHandle
					.HandleSetted = False
					WithGraphic = True
				End With
			End If
			If ShowAlignmentGrid Then
				If WithGraphic Then
					For i As Integer = R.Left To R.Right Step ScaleX(FStepX)
						For j As Integer = R.Top To R.Bottom Step ScaleY(FStepX)
							SetPixel(FHDC, i, j, 0)
						Next
					Next
				Else
					If FGridBrush Then
						DeleteObject(FGridBrush)
					End If
					mDc   = CreateCompatibleDC(FHDC)
					mBMP  = CreateCompatibleBitmap(FHDC, ScaleX(FStepX), ScaleY(FStepY))
					pBMP  = SelectObject(mDc, mBMP)
					FillRect(mDc, @BrushRect, Brush) 'Cast(HBRUSH, 16))
					SetPixel(mDc, 0, 0, 0)
					'for lines use MoveTo and LineTo or Rectangle function or whatever...
					FGridBrush = CreatePatternBrush(mBMP)
					FillRect(FHDC, @R, FGridBrush)
				End If
			ElseIf Not WithGraphic Then
				FillRect(FHDC, @R, Brush) 'Cast(HBRUSH, 16))
			End If
			DeleteObject(Brush)
			For j As Integer = 0 To SelectedControls.Count - 1
				GetWindowRect(GetControlHandle(SelectedControls.Items[j]), @R)
				MapWindowPoints 0, FDialog, Cast(..Point Ptr, @R), 2
				DrawFocusRect(FHDC, @Type<..Rect>(R.Left - 2, R.Top - 2, R.Right + 2, R.Bottom + 2))
			Next j
			If ShowAlignmentGrid Then
				SelectObject(mDc, pBMP)
				DeleteObject(mBMP)
				DeleteDC(mDc)
			End If
			EndPaint FDialog,@Ps
	End Sub
	
		Function Designer.HookChildProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
		If FormClosing Then Return False
		Static As My.Sys.Forms.Designer Ptr Des
			Des = GetProp(hDlg, "@@@Designer")
		If Des Then
				Dim As ..Point P
			With *Des
					Select Case uMsg
					Case WM_NCHITTEST
						Dim As SymbolsType Ptr st = .Symbols(.SelectedControl)
						If st AndAlso st->IsControlFunc AndAlso CInt(Not st->IsControlFunc(.SelectedControl)) Then
							Return HTTRANSPARENT
						End If
					Case WM_GETDLGCODE: 'Return DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTTAB
					Case WM_PAINT, WM_ERASEBKGND
						Select Case GetClassNameOf(hDlg)
						Case "ToolBar", "ToolPalette"
							.DrawToolBar hDlg
							Return 1
						End Select
					Case WM_LBUTTONDBLCLK
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.DblClick(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						'Return 0
					Case WM_LBUTTONDOWN
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseDown(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF, GetProp(hDlg, "MFFControl"))
						'Return 0
					Case WM_LBUTTONUP
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseUp(GetXY(.UnScaleX(P.X)), GetXY(.UnScaleY(P.Y)), wParam And &HFFFF )
						'Return 0
					Case WM_MOUSEMOVE
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseMove(GetXY(.UnScaleX(P.X)), GetXY(.UnScaleY(P.Y)), wParam And &HFFFF )
						'Return 0
					Case WM_RBUTTONUP
						'if .FSelControl <> .FDialog then
						Dim As ..Point P
						P.X = LoWord(lParam)
						P.Y = HiWord(lParam)
						ClientToScreen(hDlg, @P)
						' Unlike WM_LBUTTONDOWN (above), right-click never selected the
						' control it landed on - ChangeFirstMenuItem (and anything that
						' depends on SelectedControl, e.g. the "Show Panel"/layer menu)
						' was acting on whatever was last left-clicked instead.
						Dim As Any Ptr RClickCtrl = GetProp(hDlg, "MFFControl")
						If RClickCtrl <> 0 AndAlso Not .SelectedControls.Contains(RClickCtrl) Then
							.SelectedControls.Clear
							.SelectedControls.Add RClickCtrl
							.SelectedControl = RClickCtrl
							.MoveDots(RClickCtrl)
						End If
						'mnuDesigner.Popup(P.x, P.y)
						.ChangeFirstMenuItem
						TrackPopupMenu(mnuDesigner.Handle, 0, P.X, P.Y, 0, hDlg, 0)
						'end if
						Return 0
					Case WM_KEYDOWN
						.KeyDown(wParam, 0)
					Case WM_COMMAND
						If IsWindow(Cast(HWND, lParam)) Then
						Else
							.GetPopupMenuItems
							Dim As MenuItem Ptr mi
							For i As Integer = 0 To .FPopupMenuItems.Count -1
								mi = .FPopupMenuItems.Items[i]
								If mi->Command = LoWord(wParam) Then
									If mi->OnClick Then mi->OnClick(*mi->Designer, *mi)
									Exit For
								End If
							Next i
							'							If HiWord(wParam) = 0 Then
							'								Select Case LoWord(wParam)
							'								Case 10: .DeleteControl()
							'								Case 11: 'MessageBox(.FDialog, "Not implemented yet.","Designer", 0)
							'								Case 12: .CopyControl()
							'								Case 13: .CutControl()
							'								Case 14: .PasteControl()
							'								Case 16: .BringToFront()
							'								Case 17: .SendToBack()
							'								Case 19: If Des->OnClickProperties Then Des->OnClickProperties(*Des, .GetControl(.FSelControl))
							'								End Select
							'							End If
						End If '
						'						''''Call and execute the based commands of dialogue.
						'						'return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
						'						'''if don't want to call
						'						'return 0
					Case WM_NCDESTROY
						Return 0
				End Select
			End With
		End If
			Return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
		'#Else
		'Dim As Any Ptr Ctrl = Cast(Any Ptr, GetWindowLongPtr(hDlg, GWLP_USERDATA))
		'If Ctrl <> 0 AndAlso Des <> 0 AndAlso Des->ReadPropertyFunc <> 0 AndAlso QWString(Des->ReadPropertyFunc(Ctrl, "ClassAncestor")) = "" Then
		'Select Case uMsg
		
		'case WM_MOUSEFIRST to WM_MOUSELAST
		'	return true
		'case WM_NCHITTEST
		'	return HTTRANSPARENT
		'case WM_KEYFIRST to WM_KEYLAST
		'	return 0
		'end select
		'End If
		'return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
		'#EndIf
	End Function
	
	Public Sub Designer.AlignLefts
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = iLeft
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignCenters
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = iLeft + iWidth / 2 - iiWidth / 2
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignRights
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = iLeft + iWidth - iiWidth
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignTops
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiTop = iTop
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignMiddles
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiTop = iTop + iHeight / 2 - iiHeight / 2
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignBottoms
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiTop = iTop + iHeight - iiHeight
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignToGrid
		If Components.Count > 0 Then
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = Int(iiLeft / GridSize) * GridSize
				iiTop = Int(iiTop / GridSize) * GridSize
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.MakeSameSizeWidth
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiWidth = iWidth
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.MakeSameSizeHeight
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiHeight = iHeight
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.MakeSameSizeBoth
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiWidth = iWidth
				iiHeight = iHeight
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.SizeToGrid
		If Components.Count > 0 Then
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = Int(iiLeft / GridSize) * GridSize
				iiTop = Int(iiTop / GridSize) * GridSize
				iiWidth = Int(iiWidth / GridSize) * GridSize
				iiHeight = Int(iiHeight / GridSize) * GridSize
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.HorizontalSpacingMakeEqual
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 3 Then Exit Sub
		Dim As Integer iMin, iMax, iLefts, iWidths, iAverage, iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
			iWidths += iiWidth
		Next
		iListOfLefts.Sort
		iMin = iListOfLefts.Item(0)
		iMax = iListOfLefts.Item(iCount - 1)
		iIndex = iListOfWidths.IndexOfObject(iListOfLefts.Object(iCount - 1))
		iWidths -= iListOfWidths.Item(iIndex)
		iAverage = (iMax - iMin - iWidths) / (iCount - 1)
		iIndex = iListOfWidths.IndexOfObject(iListOfLefts.Object(0))
		iLefts = iMin + iListOfWidths.Item(iIndex)
		For i As Integer = 1 To iCount - 2
			Ctrl = iListOfLefts.Object(i)
			iIndex = iListOfTops.IndexOfObject(Ctrl)
			iLefts += iAverage
			iiLeft = iLefts
			iiTop = iListOfTops.Item(iIndex)
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
			iLefts += iiWidth
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.HorizontalSpacingIncrease
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfLefts.Sort
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfLefts.Object(i)
			iIndex = iListOfTops.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(i) + GridSize * i
			iiTop = iListOfTops.Item(iIndex)
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.HorizontalSpacingDecrease
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfLefts.Sort
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfLefts.Object(i)
			iIndex = iListOfTops.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(i) - GridSize * i
			iiTop = iListOfTops.Item(iIndex)
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.HorizontalSpacingRemove
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex, iLefts
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfLefts.Sort
		iIndex = iListOfWidths.IndexOfObject(iListOfLefts.Object(0))
		iLefts = iListOfLefts.Item(0) + iListOfWidths.Item(iIndex)
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfLefts.Object(i)
			iIndex = iListOfTops.IndexOfObject(Ctrl)
			iiLeft = iLefts
			iiTop = iListOfTops.Item(iIndex)
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
			iLefts += iiWidth
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.VerticalSpacingMakeEqual
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 3 Then Exit Sub
		Dim As Integer iMin, iMax, iTops, iHeights, iAverage, iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
			iHeights += iiHeight
		Next
		iListOfTops.Sort
		iMin = iListOfTops.Item(0)
		iMax = iListOfTops.Item(iCount - 1)
		iIndex = iListOfHeights.IndexOfObject(iListOfTops.Object(iCount - 1))
		iHeights -= iListOfHeights.Item(iIndex)
		iAverage = (iMax - iMin - iHeights) / (iCount - 1)
		iIndex = iListOfHeights.IndexOfObject(iListOfTops.Object(0))
		iTops = iMin + iListOfHeights.Item(iIndex)
		For i As Integer = 1 To iCount - 2
			Ctrl = iListOfTops.Object(i)
			iIndex = iListOfLefts.IndexOfObject(Ctrl)
			iTops += iAverage
			iiLeft = iListOfLefts.Item(iIndex)
			iiTop = iTops
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
			iTops += iiHeight
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.VerticalSpacingIncrease
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfTops.Sort
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfTops.Object(i)
			iIndex = iListOfLefts.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(iIndex)
			iiTop = iListOfTops.Item(i) + GridSize * i
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.VerticalSpacingDecrease
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfTops.Sort
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfTops.Object(i)
			iIndex = iListOfLefts.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(iIndex)
			iiTop = iListOfTops.Item(i) - GridSize * i
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.VerticalSpacingRemove
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex, iTops
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfTops.Sort
		iIndex = iListOfHeights.IndexOfObject(iListOfTops.Object(0))
		iTops = iListOfTops.Item(0) + iListOfHeights.Item(iIndex)
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfTops.Object(i)
			iIndex = iListOfLefts.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(iIndex)
			iiTop = iTops
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
			iTops += iiHeight
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.CenterInParentHorizontally
		Dim As SymbolsType Ptr st = Symbols(SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
		Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent")
		If ParentCtrl = 0 Then Exit Sub
		Dim As Integer iLeft, iTop, iWidth, iHeight
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		GetControlBounds(ParentCtrl, iLeft, iTop, iWidth, iHeight)
		For i As Integer = 0 To SelectedControls.Count - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iiLeft = (iWidth - iiWidth) / 2
			SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.CenterInParentVertically
		Dim As SymbolsType Ptr st = Symbols(SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
		Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent")
		If ParentCtrl = 0 Then Exit Sub
		Dim As Integer iLeft, iTop, iWidth, iHeight
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		GetControlBounds(ParentCtrl, iLeft, iTop, iWidth, iHeight)
		For i As Integer = 0 To SelectedControls.Count - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iiTop = (iHeight - iiHeight) / 2
			SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Property Designer.LockControls As Boolean
		Return FLockControls
	End Property
	
	Public Property Designer.LockControls(Value As Boolean)
		FLockControls = Value
	End Property
	
	Sub Designer.BringToFront(Ctrl As Any Ptr = 0)
		Dim As SymbolsType Ptr st = Symbols(SelectedControl)
			If Ctrl = 0 Then
				SetWindowPos FSelControl, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
			ElseIf Symbols(Ctrl) AndAlso Symbols(Ctrl)->ReadPropertyFunc Then
				SetWindowPos *Cast(HWND Ptr, Symbols(Ctrl)->ReadPropertyFunc(Ctrl, "Handle")), HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
			End If
		If Ctrl = 0 AndAlso st AndAlso st->ReadPropertyFunc AndAlso st->WritePropertyFunc AndAlso st->ReadPropertyFunc(SelectedControl, "Parent") Then
			Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent"), CtrlAfter
			Dim As SymbolsType Ptr stParent = Symbols(ParentCtrl)
			If stParent->ReadPropertyFunc AndAlso stParent->ControlByIndexFunc Then
				Dim As Integer ControlCount = QInteger(stParent->ReadPropertyFunc(ParentCtrl, "ControlCount"))
				If ControlCount > 1 Then
					Dim As Integer newIndex = ControlCount - 1
					CtrlAfter = stParent->ControlByIndexFunc(ParentCtrl, newIndex)
					If SelectedControl <> CtrlAfter Then
						st->WritePropertyFunc(SelectedControl, "ControlIndex", @newIndex)
						If OnModified Then OnModified(This, SelectedControl, , , CtrlAfter)
					End If
				End If
			End If
		End If
	End Sub
	
	Sub Designer.SendToBack(Ctrl As Any Ptr = 0)
		Dim As SymbolsType Ptr st = Symbols(SelectedControl)
			If Ctrl = 0 Then
				SetWindowPos FSelControl, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
			ElseIf Symbols(Ctrl) AndAlso Symbols(Ctrl)->ReadPropertyFunc Then
				SetWindowPos *Cast(HWND Ptr, Symbols(Ctrl)->ReadPropertyFunc(Ctrl, "Handle")), HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
			End If
		If st AndAlso st->ReadPropertyFunc AndAlso st->WritePropertyFunc AndAlso st->ReadPropertyFunc(SelectedControl, "Parent") Then
			Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent"), Ctrl
			Dim As SymbolsType Ptr stParent = Symbols(ParentCtrl)
			If stParent AndAlso stParent->ReadPropertyFunc AndAlso stParent->ControlByIndexFunc AndAlso QInteger(stParent->ReadPropertyFunc(ParentCtrl, "ControlCount")) > 1 Then
				Dim As Integer NewIndex = 0
				Ctrl = stParent->ControlByIndexFunc(ParentCtrl, NewIndex)
				If SelectedControl <> Ctrl Then
					st->WritePropertyFunc(SelectedControl, "ControlIndex", @NewIndex)
					If OnModified Then OnModified(This, SelectedControl, , Ctrl)
				End If
			End If
		End If
	End Sub
	
	Function Designer.EnumPopupMenuItems(ByRef Item As MenuItem) As Boolean
		FPopupMenuItems.Add Item
		For i As Integer = 0 To Item.Count -1
			EnumPopupMenuItems *Item.Item(i)
		Next i
		Return True
	End Function
	
	Sub Designer.GetPopupMenuItems
		FPopupMenuItems.Clear
		If Parent AndAlso Parent->ContextMenu Then
			For i As Integer = 0 To Parent->ContextMenu->Count -1
				EnumPopupMenuItems *Parent->ContextMenu->Item(i)
			Next i
		End If
	End Sub
	
		Function Designer.HookDialogProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
		Static As Boolean bCtrl, bShift
		Static As Any Ptr Ctrl
		Static As My.Sys.Forms.Designer Ptr Des
			bShift = GetKeyState(VK_SHIFT) And 8000
			bCtrl = GetKeyState(VK_CONTROL) And 8000
			Des = GetProp(hDlg, "@@@Designer")
		If Des Then
			With *Des
					Select Case uMsg
					Case WM_PAINT, WM_ERASEBKGND
						'Function = CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
						.DrawThis
						Return 1
						'Exit Function
					Case WM_NCHITTEST
						Return HTTRANSPARENT
					Case WM_NCCALCSIZE
						If .TopMenuHeight <> 0 Then
							Dim As LPNCCALCSIZE_PARAMS pncc = Cast(LPNCCALCSIZE_PARAMS, lParam)
							'pncc->rgrc[0] Is the New rectangle
							'pncc->rgrc[1] Is the old rectangle
							'pncc->rgrc[2] Is the client rectangle
							Des->TopMenu->SetBounds(.UnScaleX(pncc->rgrc(2).Left), .UnScaleY(pncc->rgrc(2).Top) - .TopMenuHeight, .UnScaleX(pncc->rgrc(2).Right - pncc->rgrc(2).Left), .TopMenuHeight)
							pncc->rgrc(0).Top += .ScaleY(.TopMenuHeight)
						End If
					Case WM_SIZE
						SendMessage GetParent(hDlg), WM_SIZE, 0, 0
					Case WM_SYSCOMMAND
						Return 0
					Case WM_SETCURSOR
						Return 0
					Case WM_GETDLGCODE: 'Return DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTTAB
					Case WM_LBUTTONDBLCLK
						.DblClick(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF)
						'Return 0
					Case WM_LBUTTONDOWN
						.MouseDown(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF )
						Return 0
					Case WM_LBUTTONUP
						.MouseUp(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF )
						Return 0
					Case WM_MOUSEMOVE
						.MouseMove(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF )
						'Return 0
					Case WM_RBUTTONUP
						'if .FSelControl <> .FDialog then
						Dim As ..Point P
						P.X = LoWord(lParam)
						P.Y = HiWord(lParam)
						ClientToScreen(hDlg, @P)
						.ChangeFirstMenuItem
						TrackPopupMenu(mnuDesigner.Handle, 0, P.X, P.Y, 0, hDlg, 0)
						'end if
						Return 0
					Case WM_KEYDOWN
						.KeyDown(wParam, 0)
					Case WM_COMMAND
						If IsWindow(Cast(HWND, lParam)) Then
						Else
							.GetPopupMenuItems
							Dim As MenuItem Ptr mi
							For i As Integer = 0 To .FPopupMenuItems.Count -1
								mi = .FPopupMenuItems.Items[i]
								If mi->Command = LoWord(wParam) Then
									If mi->OnClick Then mi->OnClick(*mi->Designer, *mi)
									Exit For
								End If
							Next i
							'.Parent->ProcessMessage(Type(Ctrl, FWindow, Msg, wParam, lParam, 0, LoWord(wParam), HiWord(wParam), LoWord(lParam), HiWord(lParam), False))
							'							?LoWord(wParam)
							'							If HiWord(wParam) = 0 Then
							'								Select Case LoWord(wParam)
							'								Case 10: .DeleteControl()
							'								Case 11: 'MessageBox(.FDialog, "Not implemented yet.","Designer", 0)
							'								Case 12: .CopyControl()
							'								Case 13: .CutControl()
							'								Case 14: .PasteControl()
							'								Case 16: .BringToFront()
							'								Case 17: .SendToBack()
							'								Case 19: If Des->OnClickProperties Then Des->OnClickProperties(*Des, .GetControl(.FSelControl))
							'								End Select
							'							End If
						End If '
						''''Call and execute the based commands of dialogue.
						'Return CallWindowProc(GetProp(GetParent(hDlg), "@@@Proc"), hDlg, uMsg, wParam, lParam)
						'''if don't want to call
						'return 0
					Case WM_ACTIVATE
						SendMessage frmMain.Handle, WM_NCACTIVATE, 0, 0
						Return 0
					Case WM_ACTIVATEAPP
						'SendMessage *pfrmMain->Handle, WM_NCACTIVATE, 0, 0
						Return 0
				End Select
			End With
		End If
			Return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
	End Function
	
		Function Designer.HookTopMenuProc(hDlg As HWND, uMsg As UINT, WPARAM As WPARAM, LPARAM As LPARAM) As LRESULT
			Static As My.Sys.Forms.Designer Ptr Des
			Des = GetProp(hDlg, "@@@Designer")
			If Des Then
				With *Des
					Static Tracked As Boolean
					Select Case uMsg
					Case WM_PAINT, WM_ERASEBKGND
						.DrawTopMenu
						Return 1
					Case WM_LBUTTONDOWN
						Dim As Integer X = .UnScaleX(LoWord(LPARAM)), Y = .UnScaleY(HiWord(LPARAM)), i, CurRect
						For i = 1 To .RectsCount
							With .Rects(i)
								If X >= .Left And X <= .Right And Y >= .Top And Y <= .Bottom Then
									CurRect = i
									Exit For
								End If
							End With
						Next i
						Dim As SymbolsType Ptr st = .Symbols(.Ctrls(CurRect))
						If CurRect AndAlso .Ctrls(CurRect) AndAlso st AndAlso st->ReadPropertyFunc AndAlso QWString(st->ReadPropertyFunc(.Ctrls(CurRect), "Caption")) = "-" Then
							CurRect = 0
						ElseIf .ActiveRect <> 0 Then
							.ActiveRect = 0
							RedrawWindow hDlg, 0, 0, RDW_INVALIDATE
							UpdateWindow hDlg
						ElseIf CurRect <> 0 Then
							If st AndAlso st->ReadPropertyFunc AndAlso QInteger(st->ReadPropertyFunc(.Ctrls(CurRect), "Count")) = 0 Then
								If .OnClickMenuItem Then .OnClickMenuItem(*Des, .Ctrls(CurRect))
							Else
								.ActiveRect = CurRect
								RedrawWindow hDlg, 0, 0, RDW_INVALIDATE
								UpdateWindow hDlg
								If st AndAlso st->ReadPropertyFunc Then
									Dim As HMENU Ptr PHANDLE = Cast(HMENU Ptr, st->ReadPropertyFunc(.Ctrls(.ActiveRect), "Handle"))
									If PHANDLE <> 0 Then
										Dim As ..Point P
										P.X = .ScaleX(.Rects(.ActiveRect).Left)
										P.Y = .ScaleY(.Rects(.ActiveRect).Bottom)
										..ClientToScreen(hDlg, @P)
										Var b = TrackPopupMenu(*PHANDLE, TPM_RETURNCMD, P.X, P.Y, 0, hDlg, 0)
										Dim As SymbolsType Ptr stDesignControl = .Symbols(.DesignControl)
										If stDesignControl AndAlso stDesignControl->ReadPropertyFunc Then
											Dim As Any Ptr CurrentMenu = stDesignControl->ReadPropertyFunc(.DesignControl, "Menu")
											If CurrentMenu <> 0 Then
												Dim As SymbolsType Ptr st = .Symbols(CurrentMenu)
												If st AndAlso st->MenuFindByCommandFunc Then
													Dim As Any Ptr mi = st->MenuFindByCommandFunc(CurrentMenu, b)
													If mi <> 0 Then
														If .OnClickMenuItem Then .OnClickMenuItem(*Des, mi)
													End If
												End If
											End If
										End If
										.ActiveRect = 0
										RedrawWindow hDlg, 0, 0, RDW_INVALIDATE
										UpdateWindow hDlg
									End If
								End If
							End If
						End If
					Case WM_COMMAND
					Case WM_LBUTTONUP
					Case WM_MOUSEMOVE
						Dim As Integer X = .UnScaleX(LoWord(LPARAM)), Y = .UnScaleY(HiWord(LPARAM)), i, CurRect
						For i = 1 To .RectsCount
							With .Rects(i)
								If X >= .Left And X <= .Right And Y >= .Top And Y <= .Bottom Then
									CurRect = i
									Exit For
								End If
							End With
						Next i
						Dim As SymbolsType Ptr st = .Symbols(.Ctrls(CurRect))
						If CurRect AndAlso .Ctrls(CurRect) AndAlso st AndAlso st->ReadPropertyFunc AndAlso QWString(st->ReadPropertyFunc(.Ctrls(CurRect), "Caption")) = "-" Then
							CurRect = 0
							.ActiveRect = 0
							.MouseRect = 0
							RedrawWindow hDlg, 0, 0, RDW_INVALIDATE
							UpdateWindow hDlg
						ElseIf .ActiveRect <> 0 AndAlso CurRect <> 0 AndAlso CurRect <> .ActiveRect AndAlso .Ctrls(CurRect) <> 0 Then
							If st AndAlso st->ReadPropertyFunc Then
								Dim As HMENU Ptr PHANDLE = Cast(HMENU Ptr, st->ReadPropertyFunc(.Ctrls(CurRect), "Handle"))
								.ActiveRect = CurRect
								RedrawWindow hDlg, 0, 0, RDW_INVALIDATE
								UpdateWindow hDlg
								If PHANDLE <> 0 Then
									Dim As ..Point P
									P.X = .ScaleX(.Rects(CurRect).Left)
									P.Y = .ScaleY(.Rects(CurRect).Bottom)
									..ClientToScreen(hDlg, @P)
									Var b = TrackPopupMenu(*PHANDLE, TPM_RETURNCMD, P.X, P.Y, 0, hDlg, 0)
									.ActiveRect = 0
									RedrawWindow hDlg, 0, 0, RDW_INVALIDATE
									UpdateWindow hDlg
								End If
							End If
						ElseIf CurRect <> 0 OrElse .MouseRect <> 0 Then
							If CurRect <> .MouseRect Then
								.MouseRect = CurRect
								RedrawWindow hDlg, 0, 0, RDW_INVALIDATE
								UpdateWindow hDlg
							End If
						End If
						If Tracked = False Then
							Dim As TRACKMOUSEEVENT event_
							event_.cbSize = SizeOf(TRACKMOUSEEVENT)
							event_.dwFlags = TME_LEAVE
							event_.hwndTrack = hDlg
							'event_.dwHoverTime = 10
							TRACKMOUSEEVENT(@event_)
							Tracked = True
						End If
					Case WM_MOUSELEAVE
						If .MouseRect <> 0 Then
							.MouseRect = 0
							RedrawWindow hDlg, 0, 0, RDW_INVALIDATE
							UpdateWindow hDlg
						End If
						Tracked = False
					End Select
				End With
			End If
			Return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, WPARAM, LPARAM)
		End Function
	
		Function Designer.HookDialogParentProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
		Static As My.Sys.Forms.Designer Ptr Des
			Des = GetProp(hDlg, "@@@Designer")
		If Des Then
			With *Des
					Dim As ..Point P
					Select Case uMsg
					Case WM_NCHITTEST
					Case WM_GETDLGCODE: 'Return DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTTAB
					Case WM_LBUTTONDBLCLK
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.DblClick(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF)
						'Return 0
					Case WM_LBUTTONDOWN
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseDown(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						Return 0
					Case WM_LBUTTONUP
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseUp(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						Return 0
					Case WM_RBUTTONUP
						'if .FSelControl <> .FDialog then
						Dim As ..Point P
						P.X = LoWord(lParam)
						P.Y = HiWord(lParam)
						ClientToScreen(hDlg, @P)
						'mnuDesigner.Popup(P.x, P.y)
						.ChangeFirstMenuItem
						TrackPopupMenu(mnuDesigner.Handle, 0, P.X, P.Y, 0, hDlg, 0)
						'end if
						Return 0
					Case WM_MOUSEMOVE
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseMove(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						Return 0
					Case WM_KEYDOWN
						.KeyDown(wParam, 0)
					Case WM_COMMAND
						If IsWindow(Cast(HWND, lParam)) Then
						Else
							If HiWord(wParam) = 0 Then
								Var mi = mnuDesigner.Find(LoWord(wParam))
								If mi AndAlso mi->OnClick Then mi->OnClick(*mi->Designer, *mi): Return 0
								'Select Case LoWord(wParam)
								'Case 10: .DeleteControl()
								'Case 11: 'MessageBox(.FDialog, "Not implemented yet.","Designer", 0)
								'Case 12: .CopyControl()
								'Case 13: .CutControl()
								'Case 14: .PasteControl()
								'Case 16: .BringToFront()
								'Case 17: .SendToBack()
								'Case 19: If Des->OnClickProperties Then Des->OnClickProperties(*Des, .GetControl(.FSelControl))
								'End Select
							End If
						End If '
						
						''''Call and execute the based commands of dialogue.
						Return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
						'''if don't want to call
						'return 0
				End Select
			End With
		End If
			Return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
	End Function
	
	Sub Designer.Hook
			If IsWindow(FDialog) Then
				SetProp(FDialog, "@@@Designer", @This)
				If GetWindowLongPtr(FDialog, GWLP_WNDPROC) <> @HookDialogProc Then
					SetProp(FDialog, "@@@Proc", Cast(Any Ptr, SetWindowLongPtr(FDialog, GWLP_WNDPROC, CInt(@HookDialogProc))))
				End If
			HookParent
			'GetChilds
			'for i as integer = 0 to FChilds.Count-1
			'	HookControl(FChilds.Child[i])
			'next
		End If
	End Sub
	
	Sub Designer.UnHook
			If FDialog Then
				SetWindowLongPtr(FDialog, GWLP_WNDPROC, CInt(GetProp(FDialog, "@@@Proc")))
				RemoveProp(FDialog, "@@@Designer")
				RemoveProp(FDialog, "@@@Proc")
				UnHookParent
				GetChilds
				For i As Integer = 0 To FChilds.Count-1
					UnHookControl(FChilds.Child[i])
				Next
			End If
	End Sub
	
	Sub Designer.HookParent
			If IsWindow(FDialog) Then
				SetProp(GetParent(FDialog), "@@@Designer", @This)
				If GetWindowLongPtr(GetParent(FDialog), GWLP_WNDPROC) <> @HookDialogParentProc Then
					SetProp(GetParent(FDialog), "@@@Proc", Cast(Any Ptr, SetWindowLongPtr(GetParent(FDialog), GWLP_WNDPROC, CInt(@HookDialogParentProc))))
				End If
				SetProp(TopMenu->Handle, "@@@Designer", @This)
				If GetWindowLongPtr(TopMenu->Handle, GWLP_WNDPROC) <> @HookTopMenuProc Then
					SetProp(TopMenu->Handle, "@@@Proc", Cast(Any Ptr, SetWindowLongPtr(TopMenu->Handle, GWLP_WNDPROC, CInt(@HookTopMenuProc))))
				End If
			End If
	End Sub
	
	Sub Designer.UnHookParent
			If FDialog Then
				SetWindowLongPtr(GetParent(FDialog), GWLP_WNDPROC, CInt(GetProp(GetParent(FDialog), "@@@Proc")))
				RemoveProp(FDialog, "@@@Designer")
				RemoveProp(FDialog, "@@@Proc")
			End If
	End Sub
	
	Sub Designer.KeyDown(KeyCode As Integer, Shift As Integer, Ctrl As Any Ptr = 0)
		Static bShift As Boolean
		Static bCtrl As Boolean
			bShift = GetKeyState(VK_SHIFT) And 8000
			bCtrl = GetKeyState(VK_CONTROL) And 8000
		Select Case KeyCode
		Case Keys.Key_Delete: DeleteControl()
		Case Keys.Key_Enter: If OnDblClickControl Then OnDblClickControl(This, SelectedControl)
		Case VK_PRIOR: If bCtrl Then MovePanelLayer(-1)
		Case VK_NEXT: If bCtrl Then MovePanelLayer(1)
		Case Keys.Key_Left, Keys.Key_Right, Keys.Key_Up, Keys.Key_Down
			FStepX = GridSize
			FStepY = GridSize
			Dim As Integer FStepX1 = FStepX
			Dim As Integer FStepY1 = FStepY
			Dim As Integer FLeft, FTop, FWidth, FHeight
			If bCtrl Then FStepX1 = 1: FStepY1 = 1
				Dim As ..Point P
				Dim As ..Rect R
				Dim As HWND ControlHandle
				For j As Integer = 0 To SelectedControls.Count - 1
					ControlHandle = GetControlHandle(SelectedControls.Items[j])
					GetWindowRect(ControlHandle, @R)
					P.X     = R.Left
					P.Y     = R.Top
					FWidth  = UnScaleX(R.Right - R.Left)
					FHeight = UnScaleY(R.Bottom - R.Top)
					ScreenToClient(GetParent(ControlHandle), @P)
					FLeft   = UnScaleX(P.X)
					FTop    = UnScaleY(P.Y)
					If bShift Then
						Select Case KeyCode
						Case Keys.Key_Left: FWidth = FWidth - FStepX1
						Case Keys.Key_Right: FWidth = FWidth + FStepX1
						Case Keys.Key_Up: FHeight = FHeight - FStepY1
						Case Keys.Key_Down: FHeight = FHeight + FStepY1
						End Select
					ElseIf ControlHandle <> Dialog Then
						Select Case KeyCode
						Case Keys.Key_Left: FLeft = FLeft - FStepX1
						Case Keys.Key_Right: FLeft = FLeft + FStepX1
						Case Keys.Key_Up: FTop = FTop - FStepY1
						Case Keys.Key_Down: FTop = FTop + FStepY1
						End Select
					End If
					MoveWindow(ControlHandle, ScaleX(FLeft), ScaleY(FTop), ScaleX(FWidth), ScaleY(FHeight), True)
					If OnModified Then OnModified(This, SelectedControls.Items[j], , , , FLeft, FTop, FWidth, FHeight)
				Next
				MoveDots(SelectedControl)
		End Select
	End Sub
	
		Function Designer.DotWndProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
		Dim As My.Sys.Forms.Designer Ptr Des
			Des = Cast(My.Sys.Forms.Designer Ptr, GetWindowLongPtr(hDlg, GWLP_USERDATA))
		If Des Then
			With *Des
					Select Case uMsg
					Case WM_PAINT
						Dim As PAINTSTRUCT Ps
						Dim As HDC FHDc = BeginPaint(hDlg, @Ps)
						Dim As HPEN Pen = CreatePen(PS_SOLID, 0, IIf(GetProp(hDlg, "@@@Control2") = .SelectedControl AndAlso Not .FLockControls, GetSysColor(COLOR_HIGHLIGHTTEXT), GetSysColor(COLOR_HIGHLIGHT)))
						Dim As HPEN PrevPen = SelectObject(FHDc, Pen)
						Dim As HBRUSH Brush = CreateSolidBrush(IIf(GetProp(hDlg, "@@@Control2") = .SelectedControl AndAlso Not .FLockControls, GetSysColor(COLOR_HIGHLIGHT), GetSysColor(COLOR_HIGHLIGHTTEXT)))
						Dim As HBRUSH PrevBrush = SelectObject(FHDc, Brush)
						Rectangle(FHDc, Ps.rcPaint.Left, Ps.rcPaint.Top, Ps.rcPaint.Right, Ps.rcPaint.Bottom)
						SelectObject(FHDc, PrevBrush)
						SelectObject(FHDc, PrevPen)
						EndPaint(hDlg, @Ps)
						DeleteObject(Pen)
						DeleteObject(Brush)
						Return 0
						'or use WM_ERASEBKGND message
					Case WM_MOUSEMOVE
						'.MouseMove(loWord(lParam), hiWord(lParam),wParam and &HFFFF )
						Select Case .IsDot(hDlg)
						Case 0 : SetCursor(crSizeNWSE)
						Case 1 : SetCursor(crSizeNS)
						Case 2 : SetCursor(crSizeNESW)
						Case 3 : SetCursor(crSizeWE)
						Case 4 : SetCursor(crSizeNWSE)
						Case 5 : SetCursor(crSizeNS)
						Case 6 : SetCursor(crSizeNESW)
						Case 7 : SetCursor(crSizeWE)
						End Select
						.FOverControl = hDlg
					Case WM_LBUTTONDOWN
						Dim P As ..Point
						P.X = LoWord(lParam)
						P.Y = HiWord(lParam)
						ScreenToClient .FDialog, @P
						.MouseDown(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						Return 0
					Case WM_LBUTTONUP
						.MouseUp(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF )
						Return 0
						
					Case WM_NCHITTEST
						Return HTTRANSPARENT
					Case WM_KEYUP
					Case WM_KEYDOWN
						.KeyDown(wParam, wParam And &HFFFF)
					Case WM_DESTROY
						RemoveProp(hDlg,"@@@Control")
						Return 0
				End Select
			End With
		End If
			Return DefWindowProc(hDlg, uMsg, wParam, lParam)
	End Function
	
	Sub Designer.RegisterDotClass(ByRef clsName As WString)
			Dim As WNDCLASSEX wcls
			wcls.cbSize        = SizeOf(wcls)
			wcls.lpszClassName = @clsName
			wcls.lpfnWndProc   = @DotWndProc
			wcls.cbWndExtra   += 4
			wcls.hInstance     = Instance
			RegisterClassEx(@wcls)
	End Sub
	
		Property Designer.Dialog As HWND
			Return FDialog
		End Property
	
	Sub Designer.PaintControl()
		If FDown AndAlso ((FCanInsert) OrElse (FCanMove = False AndAlso FCanSize = False)) Then
		End If
		'cairo_fill(cr)
	End Sub
	
		Property Designer.Dialog(value As HWND)
			If value <> FDialog Then
				UnHook
				FDialog = value
				If value <> 0 Then
					'CreateDots(GetParent(FDialog))
					If FActive Then Hook
					InvalidateRect(FDialog, 0, True)
				End If
			End If
		End Property
		
		Property Designer.TopMenuHeight As Integer
			Return FTopMenuHeight
		End Property
		
		Property Designer.TopMenuHeight(Value As Integer)
			FTopMenuHeight = Value
		End Property
	
	Property Designer.Active As Boolean
		Return FActive
	End Property
	
	Property Designer.Active(value As Boolean)
		If value <> FActive Then
			FActive = value
			If value Then
				Hook
			Else
				UnHook
				HideDots
			End If
				InvalidateRect(FDialog, 0, True)
		End If
	End Property
	
	Property Designer.ChildCount As Integer
			GetChilds
		Return FChilds.Count
	End Property
	
	Property Designer.ChildCount(value As Integer)
	End Property
	
		Property Designer.Child(index As Integer) As HWND
			If index > -1 And index < FChilds.Count Then
				Return FChilds.Child[index]
			End If
			Return 0
		End Property
	
		Property Designer.Child(index As Integer,value As HWND)
		End Property
	
	Property Designer.StepX As Integer
		Return FStepX
	End Property
	
	Property Designer.StepX(value As Integer)
		If value <> FStepX Then
			FStepX = value
			UpdateGrid
		End If
	End Property
	
	Property Designer.StepY As Integer
		Return FStepY
	End Property
	
	Property Designer.StepY(value As Integer)
		If value <> FStepY Then
			FStepY = value
			UpdateGrid
		End If
	End Property
	
	Property Designer.DotColor As Integer
			Dim As LOGBRUSH LB
			If GetObject(FDotBrush, SizeOf(LB), @LB) Then
				FDotColor = LB.lbColor
			End If
		Return FDotColor
	End Property
	
	Property Designer.DotColor(value As Integer)
		If value <> FDotColor Then
			FDotColor = value
				If FDotBrush Then DeleteObject(FDotBrush)
				FDotBrush = CreateSolidBrush(FDotColor)
				For i As Integer = 0 To 7
					InvalidateRect(FDots(0, i), 0, True)
				Next
		End If
	End Property
	
	Property Designer.DotSize As Integer
		Return FDotSize
	End Property
	
	Property Designer.DotSize(value As Integer)
		FDotSize = value
	End Property
	
	Property Designer.SnapToGrid As Boolean
		Return FSnapToGrid
	End Property
	
	Property Designer.SnapToGrid(value As Boolean)
		FSnapToGrid = value
	End Property
	
	Property Designer.ShowGrid As Boolean
		Return FShowGrid
	End Property
	
	Property Designer.ShowGrid(value As Boolean)
		FShowGrid = value
			If IsWindow(FDialog) Then InvalidateRect(FDialog, 0, True)
	End Property
	
	Property Designer.ClassName As String
		Return FClass
	End Property
	
	Property Designer.ClassName(value As String)
		FClass = value
	End Property
	
	Operator Designer.cast As Any Ptr
		Return @This
	End Operator
	
	Constructor Designer(ParentControl As Control Ptr)
		FStepX      = 10
		FStepY      = 10
		FShowGrid   = True
		FActive     = True
		FSnapToGrid = 1
		FDotSize 	= 7
		FDotColor 	= clBlack
		FSelDotColor = clBlue
		Parent = ParentControl
		xdpi = Parent->xdpi
		ydpi = Parent->ydpi
			FDialogParent = ParentControl->Handle
			FDotBrush   = CreateSolidBrush(FDotColor)
			FSelDotBrush   = CreateSolidBrush(FSelDotColor)
		'FIsChild = True
		RegisterDotClass "DOT"
		WLet(FClassName, "Designer")
		'OnHandleIsAllocated = @HandleIsAllocated
		'ChangeStyle WS_CHILD, True
		'FDesignMode = True
		'Base.Child             = Cast(Control Ptr, @This)
		CreateDots(ParentControl)
		
		'mnuDesigner.ImagesList = @imgList '<m>
		ParentControl->ContextMenu = @mnuDesigner
	End Constructor
	
	Destructor Designer
		UnHook
			DeleteObject(FDotBrush)
			DeleteObject(FSelDotBrush)
			DeleteObject(FGridBrush)
			'DestroyMenu(FPopupMenu)
			If FChilds.Child Then _Deallocate( FChilds.Child)
		DestroyDots
			UnregisterClass("DOT", Instance)
		'If DeleteAllObjectsFunc <> 0 Then DeleteAllObjectsFunc()
		For i As Integer = 0 To FSymbols.Count - 1
			Dim As SymbolsType Ptr st = FSymbols.Item(i)
			If st Then
				If st->Handle Then DyLibFree(st->Handle)
				_Delete(st)
			End If
		Next
		FSymbols.Clear
		FLibs.Clear
		If pApp = 0 Then pApp = @VisualFBEditorApp
		WDeAllocate(FClassName)
		WDeAllocate(FTemp)
	End Destructor
End Namespace

mnuDesigner.Add(("Default event"), "Code", "Default", @PopupClick)
mnuDesigner.Add("-")
mnuDesigner.Add(("Lock Controls"), "LockControls", "LockControls", @PopupClick)
mnuDesigner.Add(("Copy") & !"\t Ctrl+C", "Copy", "Copy", @PopupClick)
mnuDesigner.Add(("Cut") & !"\t Ctrl+X", "Cut", "Cut", @PopupClick)
mnuDesigner.Add(("Paste") & !"\t Ctrl+V", "Paste", "Paste", @PopupClick)
mnuDesigner.Add(("Delete"), "", "Delete", @PopupClick)
mnuDesigner.Add("-", "", "DuplicateSeparator")
mnuDesigner.Add(("Duplicate") & !"\t Ctrl+D", "", "Duplicate", @mClick)
mnuDesigner.Add("-", "", "OrderSeparator")
mnuDesigner.Add(("Bring to Front"), "BringToFront", "BringToFront", @PopupClick)
mnuDesigner.Add(("Send to Back"), "SendToBack", "SendToBack", @PopupClick)
mnuDesigner.Add("-", "", "ShowPanelSeparator")
mnuDesigner.Add(("Previous Layer") & !"\t Ctrl+PgUp", "", "PreviousLayer", @PopupClick)
mnuDesigner.Add(("Next Layer") & !"\t Ctrl+PgDn", "", "NextLayer", @PopupClick)
mnuShowPanelDesigner = mnuDesigner.Add(("Show Panel"), "", "ShowPanel")
mnuDesigner.Add("-")
mnuDesigner.Add(("Properties"), "Property", "Properties", @PopupClick)


