'###############################################################################
'#  PagePanel.bas                                                              #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "PagePanel.bi"
'#Include Once "Canvas.bi"

Namespace My.Sys.Forms
		Private Function PagePanel.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "selectedpanel": Return SelectedPanel
			Case "selectedpanelindex": Return @FSelectedPanelIndex
			Case "tabindex": Return @FTabIndex
			Case "transparent": Return @FTransparent
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function PagePanel.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "designmode": DesignMode = QBoolean(Value)
					If FDesignMode Then 
							'FDesignMode = False
							'This.Add @StackPanel
							This.Add @NumericUpDownControl
							'FDesignMode = True
							MoveNumericUpDownControl
					End If
				Case "selectedpanel": SelectedPanel = Value
				Case "selectedpanelindex":
					' Call the real setter directly rather than relying solely on
					' NumericUpDownControl.Position's Win32 EN_CHANGE notification to
					' relay it - during Designer Constructor replay there's no
					' guarantee that notification fires (or that the spinner's HWND
					' even exists yet), so a design-time write could otherwise
					' silently do nothing. Still sync .Position afterward so the
					' spinner's displayed value matches.
					SelectedPanelIndex = QInteger(Value)
					If FDesignMode Then NumericUpDownControl.Position = FSelectedPanelIndex
				Case "tabindex": TabIndex = QInteger(Value)
				Case "transparent": This.Transparent = QBoolean(Value)
				Case "loading": FLoading = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Sub PagePanel.MoveNumericUpDownControl
		NumericUpDownControl.Width = 70
		'NumericUpDownControl.ExtraMargins.Left = (ClientWidth - NumericUpDownControl.Width) / 2
		'NumericUpDownControl.ExtraMargins.Right = NumericUpDownControl.ExtraMargins.Left
		NumericUpDownControl.SetBounds (ClientWidth - NumericUpDownControl.Width) / 2, ClientHeight - NumericUpDownControl.Height, 70, NumericUpDownControl.Height
	End Sub
	
	Private Property PagePanel.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property PagePanel.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property PagePanel.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property PagePanel.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
		Private Sub PagePanel.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QPagePanel(Sender.Child)
					.MoveNumericUpDownControl
					.RequestAlign
					.SelectedPanelIndex = .FSelectedPanelIndex
						If .FDesignMode Then .NumericUpDownControl.BringToFront
				End With
			End If
		End Sub
		
		Private Sub PagePanel.WNDPROC(ByRef Message As Message)
		End Sub
	
	
	Private Sub PagePanel.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC, Message.wParam)
				SetBkMode Dc, Transparent
				SetTextColor Dc, Font.Color
				If Not FTransparent OrElse FDesignMode Then
					SetBkColor Dc, FBackColor
					SetBkMode Dc, OPAQUE
				Else
					Message.Result = Cast(LRESULT, GetStockObject(NULL_BRUSH))
				End If
			Case WM_PAINT, WM_ERASEBKGND
				Dim As HDC Dc, memDC
				Dim As HBITMAP MemBmp
				Dim As PAINTSTRUCT Ps
				Dim As ..Rect R
				GetClientRect Handle, @R
				Dc = BeginPaint(Handle, @Ps)
				If Dc = 0 Then
					EndPaint This.Handle, @Ps
					Message.Result = 0
					Return
				End If
				If DoubleBuffered Then
					memDC = CreateCompatibleDC(Dc)
					MemBmp   = CreateCompatibleBitmap(Dc, R.Right - R.Left, R.Bottom - R.Top)
					SelectObject(memDC, MemBmp)
					FillRect memDC, @R, Brush.Handle
					Canvas.SetHandle memDC
				Else
					FillRect Dc, @R, Brush.Handle
					Canvas.SetHandle Dc
				End If
				If Graphic.Visible AndAlso Graphic.Bitmap.Handle > 0 Then
					With This
						Select Case Graphic.StretchImage
						Case StretchMode.smNone
							Canvas.DrawAlpha Graphic.StartX, Graphic.StartY, , , Graphic.Bitmap
						Case StretchMode.smStretch
							Canvas.DrawAlpha Graphic.StartX, Graphic.StartY, ScaleX(.Width) * Graphic.ScaleFactor, ScaleY(.Height) * Graphic.ScaleFactor, Graphic.Bitmap
						Case Else 'StretchMode.smStretchProportional
							Dim As Double imgWidth = Graphic.Bitmap.Width
							Dim As Double imgHeight = Graphic.Bitmap.Height
							Dim As Double PicBoxWidth = ScaleX(.Width) * Graphic.ScaleFactor
							Dim As Double PicBoxHeight = ScaleY(.Height) * Graphic.ScaleFactor
							Dim As Double img_ratio = imgWidth / imgHeight
							Dim As Double PicBox_ratio =  PicBoxWidth / PicBoxHeight
							If (PicBox_ratio >= img_ratio) Then
								imgHeight = PicBoxHeight
								imgWidth = imgHeight *img_ratio
							Else
								imgWidth = PicBoxWidth
								imgHeight = imgWidth / img_ratio
							End If
							If Graphic.CenterImage Then
								Canvas.DrawAlpha Max((PicBoxWidth - imgWidth * Graphic.ScaleFactor) / 2, Graphic.StartX), Max((PicBoxHeight - imgHeight * Graphic.ScaleFactor) / 2, Graphic.StartY), imgWidth * Graphic.ScaleFactor, imgHeight * Graphic.ScaleFactor, Graphic.Bitmap
							Else
								Canvas.DrawAlpha Graphic.StartX, Graphic.StartY, imgWidth, imgHeight, Graphic.Bitmap
							End If
						End Select
					End With
				End If
				If ShowCaption Then
					Canvas.TextOut(Current.X, Current.Y, FText, Font.Color, FBackColor)
				End If
				If OnPaint Then OnPaint(*Designer, This, Canvas)
				Canvas.UnSetHandle
				If DoubleBuffered Then
					BitBlt(Dc, 0, 0, R.Right - R.left, R.Bottom - R.top, memDC, 0, 0, SRCCOPY)
					DeleteObject(MemBmp)
					DeleteDC(memDC)
				End If
				EndPaint Handle, @Ps
				If FDesignMode AndAlso NeedBringToFront Then NeedBringToFront = False: NumericUpDownControl.BringToFront
				Message.Result = 0
				Return
			Case CM_COMMAND
				If Message.wParamHi = STN_CLICKED Then
					If OnClick Then OnClick(*Designer, This)
				End If
				If Message.wParamHi = STN_DBLCLK Then
					If OnDblClick Then OnDblClick(*Designer, This)
				End If
			Case WM_COMMAND
				If IsWindow(Cast(HWND, Message.lParam)) Then
				Else
					Dim As MenuItem Ptr mi
					For i As Integer = 0 To mnuShowPanel.Count - 1
						mi = mnuShowPanel.Item(i)
						If mi->Command = LoWord(Message.wParam) Then
							If mi->OnClick Then mi->OnClick(This, *mi)
							Exit For
						End If
					Next i
				End If
			Case WM_SIZE
				InvalidateRect(Handle, NULL, True)
				If FDesignMode Then
					MoveNumericUpDownControl
				End If
			Case CM_DRAWITEM
				
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Property PagePanel.SelectedPanel As Control Ptr
		If FSelectedPanelIndex >= 0 AndAlso FSelectedPanelIndex <= FControlCount - 1 Then Return Controls[FSelectedPanelIndex]
		Return 0
	End Property
	
	Private Property PagePanel.SelectedPanel(Value As Control Ptr)
		If IndexOf(Value) > -1 Then
			SelectedPanelIndex = IndexOf(Value)
		End If
	End Property
	
	Private Property PagePanel.SelectedPanelIndex As Integer
		Return FSelectedPanelIndex
	End Property
	
	Private Property PagePanel.SelectedPanelIndex(Value As Integer)
		If Value >= -1 AndAlso Value <= FControlCount - 1 Then
			FSelectedPanelIndex = Value
				Dim j As Integer = -1
				For i As Integer = 0 To FControlCount - 1
					If Controls[i] = @NumericUpDownControl Then Continue For
					j = j + 1
					Dim As Boolean bVisible = (j = FSelectedPanelIndex)
					Controls[i]->Visible = bVisible
						If FDesignMode Then ShowWindow(Controls[i]->Handle, IIf(bVisible, SW_SHOW, SW_HIDE))
						If bVisible Then
							SetWindowPos FHandle, IIf(FDesignMode, NumericUpDownControl.Handle, HWND_TOP), 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
							' A page that was hidden while its layout would otherwise have
							' been recomputed (e.g. throughout Designer reconstruction, or
							' just while sitting invisible behind another page) can come
							' back with stale/never-computed child positions - becoming
							' Visible again doesn't retroactively fix that on its own.
							' Force a fresh layout pass so it actually renders correctly
							' the moment it's shown, not only once something else (like
							' selecting a control inside it) happens to trigger one.
							Controls[i]->RequestAlign
						End If
				Next
		End If
	End Property
	
	Private Property PagePanel.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property PagePanel.Transparent(Value As Boolean)
		FTransparent = Value
	End Property
	
	Private Operator PagePanel.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Sub PagePanel.Add(Ctrl As Control Ptr, Index As Integer = -1)
		Base.Add(Ctrl, Index)
		If FDesignMode Then
				NumericUpDownControl.MaxValue = Max(-1, ControlCount - 2)
				UpDownControl.Enabled = NumericUpDownControl.MaxValue >= 0
				NeedBringToFront = True
				NumericUpDownControl.ControlIndex = ControlCount - 1
				' Jumping to the newest child is correct for a genuine interactive
				' add (e.g. dragging a new page from the Toolbox), but this same Add
				' also fires once per pre-existing page while the IDE Designer is
				' just recreating an existing form's controls from source - in that
				' case jumping on every single one would silently override whatever
				' page the form's own code actually selected (see FLoading).
				If Not FLoading Then
					NumericUpDownControl.Position = ControlCount - 2
				Else
					' The form's own SelectedPanelIndex assignment (if any) runs
					' before any of its pages exist yet, so the visibility-toggling
					' loop it triggers has nothing real to show/hide at that point -
					' every page added afterward just keeps its own default
					' Visible=True forever, and whichever ends up on top of the
					' Z-order (the last one added) is what's actually seen. Re-apply
					' the same index on every add while loading so each newly-added
					' page's Visible state gets correctly (re-)evaluated too.
					SelectedPanelIndex = FSelectedPanelIndex
				End If
		End If
	End Sub
	
	Private Sub PagePanel.CreateWnd
		Base.CreateWnd
	End Sub
	
	Private Sub PagePanel.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					.Ctrl->Repaint
			End If
		End With
	End Sub
	
	Private Sub PagePanel.NumericUpDownControl_Change(ByRef Sender As NumericUpDown)
		If OnSelChanging Then OnSelChanging(*Designer, This, Val(NumericUpDownControl.Text))
		SelectedPanelIndex = Val(NumericUpDownControl.Text)
		'NumericUpDownControl.BringToFront
		If OnSelChange Then OnSelChange(*Designer, This, FSelectedPanelIndex)
	End Sub
	
	Private Sub PagePanel.UpDownControl_Changing(ByRef Sender As UpDown, Value As Integer, Direction As Integer)
		Dim j As Integer = -1
		mnuShowPanel.Clear
		Var mnu = mnuShowPanel.Add(WStr(j) & ": " & Name, "", , Cast(NotifyEvent, @MenuItem_Click))
		mnu->Designer = @This
		For i As Integer = 0 To ControlCount - 1
			If Controls[i] = @NumericUpDownControl Then Continue For
			j = j + 1
			Var mnu = mnuShowPanel.Add(WStr(j) & ": " & Controls[i]->Name, "", , Cast(NotifyEvent, @MenuItem_Click))
			mnu->Designer = @This
		Next
			Dim p As My.Sys.Drawing.Point = Type(UpDownPanel.Left, UpDownPanel.Top + UpDownPanel.Height)
		NumericUpDownControl.ClientToScreen p
		mnuContext.Popup p.X, p.Y
	End Sub
	
	Private Sub PagePanel.MenuItem_Click(ByRef Sender As MenuItem)
		NumericUpDownControl.Position = mnuShowPanel.IndexOf(@Sender) - 1
	End Sub
	
	Private Constructor PagePanel
		With This
			.Child          = @This
			.Canvas.Ctrl    = @This
			.Graphic.Ctrl   = @This
			.Graphic.OnChange = @GraphicChange
			NumericUpDownControl.Name = "PagePanel_NumericUpDownControl"
			'NumericUpDownControl.Align = DockStyle.alBottom
				NumericUpDownControl.Width = 70
			NumericUpDownControl.Style = udHorizontal
			NumericUpDownControl.MinValue = -1
			NumericUpDownControl.Position = -1
			NumericUpDownControl.UpDownWidth = 28
			NumericUpDownControl.Designer = @This
			NumericUpDownControl.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NumericUpDown), @NumericUpDownControl_Change)
				UpDownPanel.SetBounds(NumericUpDownControl.Width - NumericUpDownControl.Height - NumericUpDownControl.UpDownWidth + 2, 0, NumericUpDownControl.Height - 4, NumericUpDownControl.Height)
				UpDownPanel.Parent = @NumericUpDownControl
				UpDownControl.SetBounds(UnScaleX(-1), -NumericUpDownControl.Height + 3, UpDownPanel.Width + 2, NumericUpDownControl.Height * 2 - 6)
				UpDownControl.Designer = @This
				UpDownControl.OnChanging = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As UpDown, Value As Integer, Direction As Integer), @UpDownControl_Changing)
				UpDownControl.Parent = @UpDownPanel
			mnuShowPanel.Caption = "Show Panel"
			mnuContext.ParentWindow = @This
			mnuContext.Add @mnuShowPanel
				.RegisterClass "PagePanel"
				.ChildProc   = @WNDPROC
				.ExStyle     = 0
				.Style       = WS_CHILD
				.BackColor       = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = GetSysColor(COLOR_BTNFACE)
				.OnHandleIsAllocated = @HandleIsAllocated
			FTabIndex          = -1
			WLet(FClassName, "PagePanel")
			.Width       = 121
			.Height      = 41
			.ShowCaption = False
			MoveNumericUpDownControl
		End With
	End Constructor
	
	Private Destructor PagePanel
			UnregisterClass "PagePanel", GetModuleHandle(NULL)
	End Destructor
End Namespace



