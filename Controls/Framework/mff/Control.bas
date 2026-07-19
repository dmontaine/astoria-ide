'###############################################################################
'#  Control.bas                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TControl.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.1                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "Control.bi"

Namespace My.Sys.Forms
		Private Function SizeConstraints.ToString ByRef As WString
			WLet(FTemp, This.Left & "; " & This.Top & "; " & This.Width & "; " & This.Height)
			Return *FTemp
		End Function
		
		Private Function AnchorType.ToString ByRef As WString
			WLet(FTemp, This.Left & "; " & This.Top & "; " & This.Right & "; " & This.Bottom)
			Return *FTemp
		End Function
		
			Private Function Control.ReadProperty(ByRef PropertyName As String) As Any Ptr
				FTempString = LCase(PropertyName)
				Select Case FTempString
				Case "align": Return @FAlign
				Case "allowdrop": Return @FAllowDrop
				Case "allowdropfiles": Return @FAllowDropFiles
				Case "anchor": Return @Anchor
				Case "anchor.left": Return @Anchor.Left
				Case "anchor.right": Return @Anchor.Right
				Case "anchor.top": Return @Anchor.Top
				Case "anchor.bottom": Return @Anchor.Bottom
				Case "borderstyle": Return @FBorderStyle
				Case "backcolor": Return @FBackColor
				Case "canvas": Return @Canvas
				Case "constraints": Return @Constraints
				Case "constraints.left": Return @Constraints.Left
				Case "constraints.top": Return @Constraints.Top
				Case "constraints.width": Return @Constraints.Width
				Case "constraints.height": Return @Constraints.Height
				Case "contextmenu": Return ContextMenu
				Case "controlindex": FControlIndex = ControlIndex: Return @FControlIndex
				Case "controlcount": Return @FControlCount
				Case "cursor": Return @This.Cursor
				Case "doublebuffered": Return @DoubleBuffered
				Case "grouped": Return @FGrouped
				Case "helpcontext": Return @HelpContext
				Case "location": WLet(FTemp, WStr(FLeft) & ", " & WStr(FTop)): Return FTemp
				Case "location.x": Return @FLeft
				Case "location.y": Return @FTop
				Case "size": WLet(FTemp, WStr(FWidth) & ", " & WStr(FHeight)): Return FTemp
				Case "size.width": Return @FWidth
				Case "size.height": Return @FHeight
					Case "parenthandle": Return @FParentHandle
				Case "enabled": Return @FEnabled
				Case "forecolor": Return @FForeColor
				Case "font": Return @This.Font
				Case "id": Return @FID
				Case "ischild": Return @FIsChild
				Case "parent": Return FParent
				Case "showhint": Return @FShowHint
				Case "showcaption": Return @FShowCaption
				Case "hint": Return FHint
				Case "hovertime": Return @FHoverTime
				Case "subclass": Return @SubClass
				Case "tabstop": Return @FTabStop
				Case "text": Return FText.vptr
				Case "visible": Return @FVisible
				Case Else: Return Base.ReadProperty(PropertyName)
				End Select
				Return 0
			End Function
		
			Private Function Control.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
				If Value = 0 Then
					Select Case LCase(PropertyName)
					Case "parent": This.Parent = Value
					Case Else: Return Base.WriteProperty(PropertyName, Value)
					End Select
				Else
					Select Case LCase(PropertyName)
					Case "align": This.Align = *Cast(DockStyle Ptr, Value)
					Case "allowdrop": This.AllowDrop = QBoolean(Value)
					Case "allowdropfiles": This.AllowDropFiles = QBoolean(Value)
					Case "anchor.left": This.Anchor.Left = QInteger(Value)
					Case "anchor.right": This.Anchor.Right = QInteger(Value)
					Case "anchor.top": This.Anchor.Top = QInteger(Value)
					Case "anchor.bottom": This.Anchor.Bottom = QInteger(Value)
					Case "cursor": This.Cursor = QWString(Value)
					Case "doublebuffered": This.DoubleBuffered = QBoolean(Value)
					Case "borderstyle": This.BorderStyle = *Cast(BorderStyles Ptr, Value)
					Case "backcolor": This.BackColor = QInteger(Value)
					Case "constraints.left": This.Constraints.Left = QInteger(Value)
					Case "constraints.top": This.Constraints.Top = QInteger(Value)
					Case "constraints.width": This.Constraints.Width = QInteger(Value)
					Case "constraints.height": This.Constraints.Height = QInteger(Value)
					Case "controlindex": This.ControlIndex = QInteger(Value)
					Case "contextmenu": This.ContextMenu = Cast(PopupMenu Ptr, Value)
					Case "enabled": This.Enabled = QBoolean(Value)
					Case "grouped": This.Grouped = QBoolean(Value)
					Case "helpcontext": This.HelpContext = QInteger(Value)
					Case "hovertime": This.HoverTime = QInteger(Value)
					Case "font": This.Font = *Cast(My.Sys.Drawing.Font Ptr, Value)
					Case "id": This.ID = QInteger(Value)
					Case "ischild": This.IsChild = QInteger(Value)
					Case "forecolor": This.ForeColor = QInteger(Value)
					Case "location.x": This.Left = QInteger(Value)
					Case "location.y": This.Top = QInteger(Value)
					Case "size.width": This.Width = QInteger(Value)
					Case "size.height": This.Height = QInteger(Value)
					Case "parent": This.Parent = Value
						Case "parenthandle": This.ParentHandle = *Cast(HWND Ptr, Value)
					Case "tabstop": ChangeTabStop QBoolean(Value)
					Case "text": This.Text = QWString(Value)
					Case "visible": This.Visible = QBoolean(Value)
					Case "showhint": This.ShowHint = QBoolean(Value)
					Case "showcaption": This.ShowCaption = QBoolean(Value)
					Case "hint": This.Hint = QWString(Value)
					Case "subclass": This.SubClass = QBoolean(Value)
					Case Else: Return Base.WriteProperty(PropertyName, Value)
					End Select
				End If
				Return True
			End Function
		
		'Sub Requests(Cpnt As Component Ptr)
		'	If Cpnt AndAlso *Cpnt Is Control Then
		'		Dim Ctrl As Control Ptr = Cast(Control Ptr, Cpnt)
		'		If Ctrl->Controls Then
		'			Ctrl->RequestAlign
		'			For i As Integer = 0 To Ctrl->ControlCount - 1
		'				Requests Ctrl->Controls[i]
		'			Next i
		'			Ctrl->RequestAlign
		'		End If
		'		If Ctrl->OnReSize Then Ctrl->OnReSize(*Ctrl)
		'	End If
		'End Sub
		
		'    Property Control.Location As LocationType
		'        Return FLocation
		'    End Property
		'
		'    Property Control.Location(Value As LocationType)
		'        FLocation = Value
		'        FLeft = Value.X
		'        FTop = Value.Y
		'        If FHandle Then Move
		'    End Property
		Private Property Control.Current As My.Sys.Drawing.Point
			Return FCurrent
		End Property
		
		Private Property Control.Current(Value As My.Sys.Drawing.Point)
			FCurrent = Value
		End Property
		
		Private Property Control.Location As My.Sys.Drawing.Point
			Return Type(This.Left, This.Top)
		End Property
		
		Private Property Control.Location(Value As My.Sys.Drawing.Point)
			This.SetBounds Value.X, Value.Y, This.Width, This.Height
		End Property
		
		Private Property Control.HoverTime As Integer
			Return FHoverTime
		End Property
		
		Private Property Control.HoverTime(Value As Integer)
			FHoverTime = Value
		End Property
		
		Private Property Control.Size As My.Sys.Drawing.Size
			Return Type(This.Width, This.Height)
		End Property
		
		Private Property Control.Size(Value As My.Sys.Drawing.Size)
			This.SetBounds This.Left, This.Top, Value.Width, Value.Height
		End Property
		
		Private Property Control.AllowDrop As Boolean
			Return FAllowDrop
		End Property
		
		Private Property Control.AllowDrop(Value As Boolean)
			FAllowDrop = Value
				If FHandle AndAlso CInt(Not FDesignMode) Then
					FDropTarget.m_hWnd = FHandle
					FDropTarget.AllowDrop Value
				End If
		End Property
		
		Private Property Control.AllowDropFiles As Boolean
			Return FAllowDropFiles
		End Property
		
		Private Property Control.AllowDropFiles(Value As Boolean)
			FAllowDropFiles = Value
				ChangeExStyle WS_EX_ACCEPTFILES, Value
				If FHandle AndAlso CInt(Not FDesignMode) Then
					RecreateWnd
				End If
		End Property
		
			Private Function Control.ControlCount As Integer
				Return FControlCount
			End Function
		
			Private Function Control.Focused As Boolean
					Return GetFocus = FHandle
			End Function
		
			Private Function Control.GetTextLength() As Integer
					If FHandle Then
						Return Perform(WM_GETTEXTLENGTH, 0, 0)
					Else
						Return Len(FText)
					End If
			End Function
		
			Private Function Control.GetForm As Control Ptr
				If FParent = 0 OrElse WGet(FClassName) = "Form" OrElse WGet(FClassName) = "UserControl" Then
					Return @This
				Else
					Return QControl(FParent).GetForm()
				End If
			End Function
		
			Private Function Control.TopLevelControl As Control Ptr
				If FParent = 0 Then
					Return @This
				Else
					Return QControl(FParent).TopLevelControl()
				End If
			End Function
		
			Private Property Control.BorderStyle As BorderStyles
				Return FBorderStyle
			End Property
			
			Private Property Control.BorderStyle(Value As BorderStyles)
				FBorderStyle = Value
					ChangeExStyle WS_EX_CLIENTEDGE, Value
			End Property
		
			Private Property Control.Style As Integer
					If FHandle Then
						FStyle = GetWindowLong(FHandle, GWL_STYLE)
					End If
				Return FStyle
			End Property
			
			Private Property Control.Style(Value As Integer)
				FStyle = Value
					If FHandle Then
						SetWindowLong(FHandle, GWL_STYLE, FStyle)
						'SetWindowPos(FHandle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_DRAWFRAME)
						'RecreateWnd
					End If
			End Property
		
			Private Property Control.ExStyle As Integer
					If FHandle Then
						FExStyle = GetWindowLong(FHandle, GWL_EXSTYLE)
					End If
				Return FExStyle
			End Property
			
			Private Property Control.ExStyle(Value As Integer)
				FExStyle = Value
				'If FHandle Then RecreateWnd
			End Property
		
			Private Property Control.IsChild As Boolean
					FIsChild = StyleExists(WS_CHILD)
				Return FIsChild
			End Property
			
			Private Property Control.IsChild(Value As Boolean)
				FIsChild = Value
					ChangeStyle WS_CHILD, Value
					If FHandle Then RecreateWnd
			End Property
		
			Private Property Control.ID As Integer
					If FHandle Then
						FID = GetDlgCtrlID(FHandle)
					End If
				Return FID
			End Property
			
			Private Property Control.ID(Value As Integer)
				FID = Value
			End Property
		
		Private Property Control.ControlIndex As Integer
			If This.FParent Then
				Return Cast(Control Ptr, This.FParent)->IndexOf(@This)
			Else
				Return -1
			End If
		End Property
		
		Private Property Control.ControlIndex(Value As Integer)
			If This.FParent Then
				With *Cast(Control Ptr, This.FParent)
					.ChangeControlIndex @This, Value
					.RequestAlign
				End With
			End If
		End Property
		
			Private Property Control.Text ByRef As WString
					If FHandle Then
						Dim As Integer L
						L = Perform(WM_GETTEXTLENGTH, 0, 0)
						FText.Resize(L + 1) '  = WString(L + 1 + 1, 0)
						GetWindowText(FHandle, FText.vptr, L + 1)
					End If
				If FText.vptr = 0 Then Return WStr("") Else Return *FText.vptr
			End Property
			
			Private Property Control.Text(ByRef Value As WString)
				FText = Value
					If FHandle Then
						'If Value = "" Then
						'    SetWindowTextA FHandle, TempString
						'Else
						SetWindowTextW FHandle, FText.vptr
						'End If
					End If
			End Property
		
			Private Property Control.Hint ByRef As WString
				If FHint = 0 Then Return WStr("") Else Return *FHint
			End Property
			
			Private Property Control.Hint(ByRef Value As WString)
				WLet(FHint, Value)
				If FHint = 0 Then Return
					If FHandle Then
						If ToolTipHandle Then
							SendMessage(ToolTipHandle, TTM_GETTOOLINFO, 0, CInt(@FToolInfo))
							FToolInfo.lpszText = FHint
							SendMessage(ToolTipHandle, TTM_UPDATETIPTEXT, 0, CInt(@FToolInfo))
						ElseIf FShowHint Then
							AllocateHint
						End If
					End If
			End Property
		
			Private Property Control.Align As DockStyle
				Return FAlign
			End Property
			
			Private Property Control.Align(Value As DockStyle)
				FAlign = Value
				If FParent <> 0 Then QControl(FParent).RequestAlign
			End Property
		
			Private Function Control.ClientWidth As Integer
					If FHandle Then
						Dim As ..Rect R
						GetClientRect FHandle , @R
						FClientWidth = UnScaleX(R.Right)
						'            If UCase(ClassName) = "SYSTABCONTROL32" OR UCase(ClassName) = "TABCONTROL" Then
						'                InflateRect @R, -4, -4
						'                If (FParent->StyleExists(TCS_VERTICAL)) Then
						'                    Perform(TCM_GETITEMRECT, 0, CInt(@RR))
						'                    FClientWidth = R.Right - (RR.Right - RR.Left) - 3
						'                else
						'                    FClientWidth = R.Right - 2
						'                End If
						'            End If
					End If
				Return FClientWidth
			End Function
		
			Private Function Control.ClientHeight As Integer
					If FHandle Then
						Dim As ..Rect R
						GetClientRect FHandle, @R
						FClientHeight = UnScaleY(R.Bottom)
						'            If UCase(ClassName) = "SYSTABCONTROL32" OR UCase(ClassName) = "TABCONTROL" Then
						'                InflateRect @R,-4, -4
						'                If (Not FParent->StyleExists(TCS_VERTICAL)) Then
						'                    Perform(TCM_GETITEMRECT,0,CInt(@RR))
						'                    FClientHeight = R.Bottom - (RR.Bottom - RR.Top) - 3
						'                Else
						'                    FClientHeight = R.Bottom - 2
						'                End If
						'            End If
					End If
				Return FClientHeight
			End Function
		
			Private Property Control.ShowCaption As Boolean
				Return FShowCaption
			End Property
			
			Private Property Control.ShowCaption(Value As Boolean)
				FShowCaption = Value
					If ClassName = "Form" AndAlso FHandle Then
						ChangeStyle WS_CAPTION, Value
						If FHandle Then
							SetWindowLong(FHandle, GWL_STYLE, FStyle)
							SetWindowPos(FHandle, NULL, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE Or SWP_NOZORDER Or SWP_FRAMECHANGED)
						End If
					End If
			End Property
		
			Private Property Control.ShowHint As Boolean
				Return FShowHint
			End Property
			
			Private Property Control.ShowHint(Value As Boolean)
				FShowHint = Value
					If FHandle Then
						If ToolTipHandle Then SendMessage(ToolTipHandle, TTM_ACTIVATE, FShowHint, 0)
					End If
			End Property
		
			Private Property Control.BackColor As Integer
				Return FBackColor
			End Property
			
			Private Property Control.BackColor(Value As Integer)
				FBackColor = Value
				FBackColorRed = GetRed(Value) / 255.0
				FBackColorGreen = GetGreen(Value) / 255.0
				FBackColorBlue = GetBlue(Value) / 255.0
				Brush.Color = FBackColor
				Canvas.BackColor = FBackColor
					If ClassName = "RichTextBox" Then
						SendMessage(Handle, EM_SETBKGNDCOLOR, 0, FBackColor)
						Dim As CHARFORMAT2 Cf
						Cf.cbSize = SizeOf(Cf)
						Cf.dwMask = CFM_BACKCOLOR
						Cf.crBackColor = FBackColor
						SendMessage(FHandle, EM_SETCHARFORMAT, SCF_ALL, Cast(LPARAM, @Cf))
					End If
				Invalidate
			End Property
			
			Private Property Control.ForeColor As Integer
				Return FForeColor
			End Property
			
			Private Property Control.ForeColor(Value As Integer)
				FForeColor = Value
				FForeColorRed = GetRed(Value) / 255.0
				FForeColorGreen = GetGreen(Value) / 255.0
				FForeColorBlue = GetBlue(Value) / 255.0
				Font.Color = FForeColor
				Canvas.Font.Color = FForeColor
					If ClassName = "RichTextBox" Then
						Dim As CHARFORMAT2 Cf
						Cf.cbSize = SizeOf(Cf)
						Cf.dwMask = CFM_COLOR
						Cf.crTextColor = FForeColor
						SendMessage(FHandle, EM_SETCHARFORMAT, SCF_ALL, Cast(LPARAM, @Cf))
					End If
				Invalidate
			End Property
		
				Private Property Control.Parent As Control Ptr
					Return Cast(Control Ptr, FParent)
				End Property
			
				Private Property Control.Parent(Value As Control Ptr)
					If FParent <> Value Then
						FParent = Value
						If Value Then Value->Add(@This)
					End If
				End Property
		
			Private Function Control.StyleExists(iStyle As Integer) As Boolean
				Return (Style And iStyle) = iStyle
			End Function
		
			Private Function Control.ExStyleExists(iStyle As Integer) As Boolean
				Return (ExStyle And iStyle) = iStyle
			End Function
		
			Private Sub Control.ChangeStyle(iStyle As Integer, Value As Boolean)
				If Value Then
					If ((Style And iStyle) <> iStyle) Then Style = Style Or iStyle
				ElseIf ((Style And iStyle) = iStyle) Then
					Style = Style And Not iStyle
				End If
			End Sub
		
		Private Sub Control.ChangeExStyle(iStyle As Integer, Value As Boolean)
			If Value Then
				If ((ExStyle And iStyle) <> iStyle) Then ExStyle = ExStyle Or iStyle
			ElseIf ((ExStyle And iStyle) = iStyle) Then
				ExStyle = ExStyle And Not iStyle
			End If
		End Sub
		
			Private Sub Control.ChangeControlIndex(Ctrl As Control Ptr, Index As Integer)
				Dim OldIndex As Integer = This.IndexOf(Ctrl)
				If OldIndex > -1 AndAlso OldIndex <> Index AndAlso Index <= FControlCount - 1 Then
					If Index < OldIndex Then
						For i As Integer = OldIndex - 1 To Index Step -1
							Controls[i + 1] = Controls[i]
						Next i
						Controls[Index] = Ctrl
					Else
						For i As Integer = OldIndex + 1 To Index
							Controls[i - 1] = Controls[i]
						Next i
						Controls[Index] = Ctrl
					End If
				End If
			End Sub
		
		Private Sub Control.ChangeTabIndex(Value As Integer)
			FTabIndex = Value
				If FHandle = 0 Then Exit Sub
			Dim As Control Ptr ParentCtrl = GetForm
			Dim As Control Ptr Ctrl
			If ParentCtrl Then
				With *ParentCtrl
					.GetControls
					.FTabIndexList.Clear
					Dim As Integer Idx
					For i As Integer = 0 To .FControls.Count - 1
						Ctrl = .FControls.Item(i)
						If Ctrl <> @This AndAlso Ctrl->FTabIndex <> -2 Then .FTabIndexList.Add Ctrl->FTabIndex, Ctrl
					Next
					If FTabIndex = -1 OrElse FTabIndex > .FTabIndexList.Count Then FTabIndex = .FTabIndexList.Count
					.FTabIndexList.Sort
					If FTabIndex <> -2 Then .FTabIndexList.Insert FTabIndex, FTabIndex, @This
					For i As Integer = 0 To .FTabIndexList.Count - 1
						Ctrl = .FTabIndexList.Object(i)
						Ctrl->FTabIndex = i
					Next
				End With
			End If
		End Sub
		
			Private Property Control.ParentHandle As HWND
				Return FParentHandle
			End Property
			
			Private Property Control.ParentHandle(Value As HWND)
				FParentHandle = Value
			End Property
		
			Private Sub Control.ChangeTabStop(Value As Boolean)
				FTabStop = Value
					ChangeStyle WS_TABSTOP, Value
			End Sub
		
		Private Property Control.Grouped As Boolean
				FGrouped = StyleExists(WS_GROUP)
			Return FGrouped
		End Property
		
		Private Property Control.Grouped(Value As Boolean)
			FGrouped = Value
				ChangeStyle WS_GROUP, Value
		End Property
		
		Private Property Control.Enabled As Boolean
				If FHandle Then FEnabled = IsWindowEnabled(FHandle)
			Return FEnabled
		End Property
		
		Private Property Control.Enabled(Value As Boolean)
			FEnabled = Value
				If FHandle Then EnableWindow FHandle, FEnabled
		End Property
		
		Private Property Control.Visible() As Boolean
				If FHandle Then Return IsWindowVisible(FHandle)
			Return FVisible
		End Property
		
		Private Property Control.Visible(Value As Boolean)
			FVisible = Value
			If (Not FDesignMode) OrElse Value Then
					If Value AndAlso CBool((FHandle = 0) OrElse Not IsWindow(FHandle)) Then
						CreateWnd
					End If
					'If FParent Then FParent->RequestAlign
					If FHandle Then
						If Value Then
							ShowWindow(FHandle, SW_SHOW)
							'UpdateWindow(FHandle)
						Else
							ShowWindow(FHandle, SW_HIDE)
						End If
					End If
			End If
		End Property
		
		Private Sub Control.Show
			Visible = True
		End Sub
		
		Private Sub Control.Hide '...'
			Visible = False
		End Sub
		
		Private Sub Control.CreateWnd
			If FParent Then
				xdpi = FParent->xdpi
				ydpi = FParent->ydpi
				Font.xdpi = FParent->xdpi
				Font.ydpi = FParent->ydpi
				Canvas.xdpi = FParent->xdpi
				Canvas.ydpi = FParent->ydpi
			End If
			Dim As Long nLeft   = ScaleX(FLeft)
			Dim As Long nTop    = ScaleY(FTop)
			Dim As Long nWidth  = ScaleX(FWidth)
			Dim As Long nHeight = ScaleY(FHeight)
				If FHandle AndAlso IsWindow(FHandle) Then Exit Sub
				Dim As HWND HParent
				Dim As Integer ControlID = 0
				If (Style And WS_CHILD) = WS_CHILD Then
					If FParent Then
						HParent = FParent->Handle
						Handles.Add @This
						FID =  1000 + Handles.Count - 1 'Cast(Control Ptr, FParent)->ControlCount
						ControlID = FID
					ElseIf FOwner <> 0 AndAlso FOwner->Handle Then
						HParent = FOwner->Handle
					ElseIf FParentHandle <> 0 Then
						HParent = FParentHandle
					Else
						Exit Sub
					End If
				Else
					If FParent Then
						If Cast(Control Ptr, FParent)->FClient Then
							HParent = Cast(Control Ptr, FParent)->FClient
						Else
							HParent = FParent->Handle
						End If
					Else
						HParent = NULL
						'						If MainHandle Then
						'							HParent = MainHandle
						'						End If
						If FOwner Then
							HParent = FOwner->Handle
						End If
					End If
					ControlID = NULL
				End If
					Select Case FStartPosition
					Case 0 ' Manual
					Case 1, 4 ' CenterScreen, CenterParent
						If FStartPosition = 4 AndAlso FParent Then ' CenterParent
							With *Cast(Control Ptr, FParent)
								nLeft = ScaleX(.Left) + (ScaleX(.Width) - nWidth) \ 2: nTop  = ScaleY(.Top) + (ScaleY(.Height) - nHeight) \ 2
							End With
						Else ' CenterScreen
							nLeft = (GetSystemMetrics(SM_CXSCREEN) - nWidth) \ 2: nTop  = (GetSystemMetrics(SM_CYSCREEN) - nHeight) \ 2
						End If
					Case 2: nLeft = CW_USEDEFAULT: nTop = CW_USEDEFAULT ' WindowsDefaultLocation
					Case 3: nLeft = CW_USEDEFAULT: nTop = CW_USEDEFAULT: nWidth = CW_USEDEFAULT: nHeight = CW_USEDEFAULT ' WindowsDefaultBounds
					End Select
					Dim As Integer AControlParent(2) => {0, WS_EX_CONTROLPARENT}
					Dim As Integer ATabStop(2) = {0, WS_TABSTOP}, AGrouped(2) = {0, WS_GROUP}
					If ClassName = "WebBrowser" Then
						Style = WS_TABSTOP Or WS_CHILD Or WS_VISIBLE
						ExStyle = 0
						'					ElseIf ClassName = "IPAddress" Then
						'						Text = ""
						'						Style = WS_TABSTOP Or WS_CHILD Or WS_VISIBLE Or WS_OVERLAPPED
						'						ExStyle = 0
					Else
						If (Style And (WS_CLIPCHILDREN Or WS_CLIPSIBLINGS)) <> (WS_CLIPCHILDREN Or WS_CLIPSIBLINGS) Then
							Style = Style Or (WS_CLIPCHILDREN Or WS_CLIPSIBLINGS)
						End If
						If (Style And (ATabStop(abs_(FTabStop)) Or AGrouped(abs_(FGrouped)))) <> (ATabStop(abs_(FTabStop)) Or AGrouped(abs_(FGrouped))) Then
							Style = Style Or (ATabStop(abs_(FTabStop)) Or AGrouped(abs_(FGrouped)))
						End If
						If (ExStyle And AControlParent(abs_(FControlParent))) <> AControlParent(abs_(FControlParent)) Then
							ExStyle = ExStyle Or AControlParent(abs_(FControlParent))
						End If
					End If
					CreationControl = @This
					'RegisterClass ClassName, ClassAncestor
					Dim As DWORD dExStyle = FExStyle
					Dim As DWORD dStyle = FStyle
					'					If ExStyleExists(WS_EX_MDICHILD) Then
					'						Dim As MDICREATESTRUCT mdicreate
					'						mdicreate.szClass = FClassName
					'						mdicreate.szTitle = FText.vptr
					'						mdicreate.hOwner  = GetModuleHandle(0)
					'						mdicreate.x       = nLeft
					'						mdicreate.y       = nTop
					'						mdicreate.cx      = nWidth
					'						mdicreate.cy      = nHeight
					'						mdicreate.style   = dStyle
					'						mdicreate.lParam  = Cast(LPARAM, @This)
					'						FHandle = Cast(HWND, SendMessage(HParent, WM_MDICREATE, 0, Cast(LPARAM, @mdicreate)))
					'					Else
					FHandle = CreateWindowExW(dExStyle, _
					IIf(InStr(*FClassAncestor, "AtlAxWin"), FClassAncestor, FClassName), _
					IIf(CInt(*FClassName = "WebBrowser") AndAlso CInt(FParent <> 0) AndAlso CInt(FParent->FDesignMode), 0, IIf(InStr(*FClassAncestor, "AtlAxWin"), FProgID, FText.vptr)), _
					dStyle, _
					nLeft, _
					nTop, _
					nWidth, _
					nHeight, _
					HParent, _
					Cast(HMENU, ControlID), _
					Instance, _
					@This) ' '
					'End If
				If FHandle Then
						If GetWindowLongPtr(FHandle, GWLP_USERDATA) = 0 Then
							SetWindowLongPtr(FHandle, GWLP_USERDATA, CInt(Child))
						End If
						SetProp(FHandle, "MFFControl", @This)
						If SubClass Then
							PrevProc = Cast(Any Ptr, SetWindowLongPtr(FHandle, GWLP_WNDPROC, CInt(@CallWndProc)))
						End If
					BringToFront
					This.Font.Parent = @This 'If This.Font Then
						SendMessage FHandle, CM_CREATE, 0, 0
						If ShowHint AndAlso Hint <> "" Then AllocateHint
					If FParent Then
						FAnchoredParentWidth = Cast(Control Ptr, FParent)->Width
						FAnchoredParentHeight = Cast(Control Ptr, FParent)->Height
						FAnchoredLeft = FLeft
						FAnchoredTop = FTop
						FAnchoredRight = FAnchoredParentWidth - FWidth - FLeft
						FAnchoredBottom = FAnchoredParentHeight - FHeight - FTop
					End If
					Dim i As Integer
					This.RequestAlign
					For i = 0 To This.ControlCount - 1
						This.Controls[i]->RequestAlign
						This.Controls[i]->CreateWnd
					Next i
					This.RequestAlign
					If This.ContextMenu Then This.ContextMenu->ParentWindow = @This
					For i = 0 To This.FComponents.Count - 1
						If *Cast(My.Sys.Object Ptr, This.FComponents.Item(i)) Is NotifyIcon Then
							With *Cast(NotifyIcon Ptr, This.FComponents.Item(i))
								If .Visible Then
									.Visible = True
								End If
							End With
						End If
					Next i
					If OnHandleIsAllocated Then OnHandleIsAllocated(This)
					If OnCreate Then OnCreate(*Designer, This)
					If Not FEnabled Then Enabled = FEnabled
							If FVisible Then If ClassName = "Form" Then This.Show Else ShowWindow(FHandle, SW_SHOWNORMAL)
						Update
						If FAllowDrop Then
							FDropTarget.m_hWnd = FHandle
							FDropTarget.AllowDrop True
						End If
				Else
					'Print ClassName, GetErrorString(GetLastError, , True)
				End If
		End Sub
		
			Private Sub Control.RecreateWnd
				Dim As Integer i
					If FHandle = 0 Then Exit Sub
					'For i = 0 To ControlCount -1
					'    Controls[i]->FreeWnd
					'Next i
					FreeWnd
					CreateWnd
					For i = 0 To ControlCount -1
						Controls[i]->RecreateWnd
						Controls[i]->RequestAlign
					Next i
					RequestAlign
			End Sub
		
		Private Sub Control.FreeWnd
				If OnHandleIsDestroyed Then OnHandleIsDestroyed(This)
				If FHandle Then
					'					For i As Integer = 0 To ControlCount - 1
					'						Controls[i]->FreeWnd
					'					Next
					If ClassName <> "IPAddress" Then DestroyWindow FHandle
					Handle = 0
				End If
				If ToolTipHandle Then
					DestroyWindow ToolTipHandle
					ToolTipHandle = 0
				End If
		End Sub
		
		Private Property Control.ContextMenu As PopupMenu Ptr
			Return FContextMenu
		End Property
		
		Private Property Control.ContextMenu(Value As PopupMenu Ptr)
			FContextMenu = Value
			If FContextMenu Then FContextMenu->ParentWindow = @This
		End Property
		
		
		Private Sub Control.ProcessMessage(ByRef Message As Message)
			Static bShift As Boolean, bCtrl As Boolean, bAlt As Boolean
			If OnMessage Then OnMessage(*Designer, This, Message)
				'' ASTORIA CHANGE: &h8000, not decimal 8000. GetKeyState sets bit &h8000 when a key is down,
				'' and 8000 decimal is &h1F40 -- the two share no bits, so the test fails outright when the
				'' state is reported as &h8000 (-32768). It only appeared to work because some key-state
				'' representations (-128, as SetKeyboardState produces) happen to overlap &h1F40. Measured
				'' by TestPlan B2.
				bShift = GetKeyState(VK_SHIFT) And &h8000
				bCtrl = GetKeyState(VK_CONTROL) And &h8000
				bAlt = GetKeyState(VK_MENU) And &h8000
				Select Case Message.Msg
				Case WM_NCHITTEST
					If FDesignMode Then
						If ClassName <> "Form" AndAlso ClassName <> "GroupBox" Then
							Message.Result = HTTRANSPARENT
						End If
					End If
				Case WM_SHOWWINDOW
					If Message.wParam Then
						If OnShow Then OnShow(*Designer, This)
					Else
						If OnHide Then OnHide(*Designer, This)
					End If
				Case WM_ERASEBKGND
					If ClassName <> "ListControl" AndAlso Not FCreated Then
						FCreated = True
						UpdateWindow Message.hWnd
						Message.Result = 0
						Return
					End If
				Case WM_PAINT ', WM_ERASEBKGND ', WM_NCPAINT
					If OnPaint Then
						'' NOTE (2026-07-12): WM_PAINT is intentionally serviced with GetDC, NOT
						'' BeginPaint, and this case deliberately does NOT set Message.Handled -- it
						'' falls through to DefWindowProc, whose own BeginPaint/EndPaint is what
						'' actually validates the update region. Two invariants depend on this:
						''   1. Do NOT set Message.Handled/Result here. Without the DefWindowProc
						''      fall-through nothing validates the region, so Windows re-posts WM_PAINT
						''      forever -> CPU-pegging repaint loop.
						''   2. The BeginPaint/EndPaint form (the "textbook" fix -- would clip the DC to
						''      the invalid region, so partial repaints wouldn't redraw the whole client)
						''      was tried UPSTREAM and reverted; the reason is not recorded in this fork's
						''      history. If you ever retry it, it must both clip-to-invalid-region AND
						''      validate, mark the message handled, and be live-verified across every
						''      OnPaint surface (code tab strip, options color panel, search-box icons,
						''      menu editor) for flicker/clip regressions before it's trusted.
						Dim As HDC DC = GetDC(FHandle)
						Canvas.SetHandle DC
						OnPaint(*Designer, This, Canvas)
						Canvas.UnSetHandle
						ReleaseDC FHandle, DC
					End If
				Case WM_SETCURSOR
					If CInt(This.Cursor.Handle <> 0) AndAlso CInt(LoWord(Message.lParam) = HTCLIENT) AndAlso CInt(Not FDesignMode) Then
						Message.Result = Cast(LRESULT, SetCursor(This.Cursor.Handle))
					End If
				Case WM_HSCROLL
					If Not Message.lParam = NULL Then
						SendMessage Cast(HWND, Message.lParam), CM_HSCROLL, Cast(WPARAM, Message.wParam), Cast(LPARAM, Message.lParam)
					Else
						If OnScroll Then OnScroll(*Designer, This)
					End If
				Case WM_VSCROLL
					If Not Message.lParam = NULL Then
						SendMessage Cast(HWND, Message.lParam), CM_VSCROLL, Cast(WPARAM, Message.wParam), Cast(LPARAM, Message.lParam)
					Else
						If OnScroll Then OnScroll(*Designer, This)
					End If
				Case WM_CTLCOLORMSGBOX To WM_CTLCOLORSTATIC, WM_CTLCOLORBTN
					Dim As Control Ptr Child
					If Message.Msg = WM_CTLCOLORSTATIC Then
						If (GetWindowLong(CPtr(HWND, Message.lParam), GWL_STYLE) And SS_SIMPLE) = SS_SIMPLE Then
							Exit Select
						End If
					End If
					
					Child = GetProp(CPtr(HWND, Message.lParam), "MFFControl")
					If Child Then
						With *Child
							Var Result = SendMessage(CPtr(HWND, Message.lParam), CM_CTLCOLOR, Message.wParam, Message.lParam)
							If Result <> 0 Then
								Message.Result = Cast(LRESULT, Result)
							Else
								Message.Result = Cast(LRESULT, .Brush.Handle)
							End If
							Return
						End With
					Else
						Dim As HDC DC
						DC = Cast(HDC, Message.wParam)
						'Child = Cast(Control Ptr, GetWindowLongPtr(Message.hWnd, GWLP_USERDATA))
						'If Child Then
						SetBkMode(DC, TRANSPARENT)
						SetBkColor(DC, BackColor)
						SetTextColor(DC, Font.Color)
						SetBkMode(DC, OPAQUE)
						Message.Result = Cast(LRESULT, Brush.Handle)
						Return
						'End If
					End If
				Case WM_DPICHANGED
					Canvas.xdpi = xdpi
					Canvas.ydpi = ydpi
					Font.xdpi = xdpi
					Font.ydpi = ydpi
					Font.Size = Font.Size
					If oldxdpi = 0 OrElse oldydpi = 0 Then
						oldxdpi = 1 OrElse oldydpi = 1
					End If
					If Message.lParam <> 0 Then
						Dim As .Rect Ptr rct = Cast(Any Ptr, Message.lParam)
						MoveWindow FHandle, rct->Left, rct->Top, rct->Right - rct->Left, rct->Bottom - rct->Top, True
					Else
						If FParent = 0 OrElse FParent->ClassName <> "ReBar" Then
							If FHandle = GetCapture Then
								SetBounds Left, Top, FWidth, FHeight
							Else
								SetBounds FLeft, FTop, FWidth, FHeight
							End If
						End If
					End If
					If oldxdpi <> xdpi OrElse oldydpi <> ydpi Then
						oldxdpi = xdpi
						oldydpi = ydpi
						For i As Integer = 0 To ControlCount - 1
							Controls[i]->xdpi = xdpi
							Controls[i]->ydpi = ydpi
							Controls[i]->Perform(WM_DPICHANGED, Message.wParam, 0)
						Next
					End If
					Message.Result = 0
					Return
				Case WM_THEMECHANGED
				Case WM_CTLCOLORBTN
					'?1
				Case WM_SIZE
					If Controls Then
						RequestAlign
					End If
					If OnResize Then OnResize(*Designer, This, This.Width, This.Height)
				Case WM_WINDOWPOSCHANGING
					If Constraints.Left <> 0 Then Cast(WINDOWPOS Ptr, Message.lParam)->x  = ScaleX(Constraints.Left)
					If Constraints.Top <> 0 Then Cast(WINDOWPOS Ptr, Message.lParam)->y  = ScaleY(Constraints.Top)
					If Constraints.Width <> 0 Then Cast(WINDOWPOS Ptr, Message.lParam)->cx = ScaleX(Constraints.Width)
					If Constraints.Height <> 0 Then Cast(WINDOWPOS Ptr, Message.lParam)->cy = ScaleY(Constraints.Height)
				Case WM_WINDOWPOSCHANGED
					If OnMove Then OnMove(*Designer, This)
				Case WM_CANCELMODE
					SendMessage(FHandle, CM_CANCELMODE, 0, 0)
				Case WM_SHELLNOTIFY
					If Message.wParam >= 1000 AndAlso Message.wParam - 1000 < Handles.Count Then
						FLastNotifyIcon = Handles.Item(Message.wParam - 1000)
					Else
						FLastNotifyIcon = 0
					End If
					If FLastNotifyIcon Then
						Select Case Message.lParam
						Case WM_RBUTTONDOWN
							If FLastNotifyIcon->ContextMenu Then
								Dim As ..Point pt
								GetCursorPos(@pt)
								SetForegroundWindow(FHandle)
								FLastNotifyIcon->ContextMenu->ParentWindow = @This
								FLastNotifyIcon->ContextMenu->Popup pt.x, pt.y, @Message
								'TrackPopupMenuEx (ni->ContextMenu->Handle, TPM_LEFTALIGN Or TPM_RIGHTBUTTON, pt.x, pt.y, FHandle, NULL)
								PostMessage(FHandle, WM_NULL, 0, 0)
							End If
							Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
							Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
							If FLastNotifyIcon->OnMouseUp AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then FLastNotifyIcon->OnMouseUp(*FLastNotifyIcon->Designer, *FLastNotifyIcon, 1, MouseX, MouseY, Message.wParam And &HFFFF)
						Case WM_RBUTTONUP
							Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
							Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
							If FLastNotifyIcon->OnMouseUp AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then FLastNotifyIcon->OnMouseUp(*FLastNotifyIcon->Designer, *FLastNotifyIcon, 1, MouseX, MouseY, Message.wParam And &HFFFF)
						Case WM_LBUTTONDOWN
							If FLastNotifyIcon->OnClick Then FLastNotifyIcon->OnClick(*FLastNotifyIcon->Designer, *FLastNotifyIcon)
							Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
							Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
							If FLastNotifyIcon->OnMouseDown AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then FLastNotifyIcon->OnMouseDown(*FLastNotifyIcon->Designer, *FLastNotifyIcon, 0, MouseX, MouseY, Message.wParam And &HFFFF)
						Case WM_LBUTTONUP
							Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
							Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
							If FLastNotifyIcon->OnMouseUp AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then FLastNotifyIcon->OnMouseUp(*FLastNotifyIcon->Designer, *FLastNotifyIcon, 0, MouseX, MouseY, Message.wParam And &HFFFF)
						Case WM_MBUTTONDOWN
							If FLastNotifyIcon->OnClick Then FLastNotifyIcon->OnClick(*FLastNotifyIcon->Designer, *FLastNotifyIcon)
							Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
							Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
							If FLastNotifyIcon->OnMouseDown AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then FLastNotifyIcon->OnMouseDown(*FLastNotifyIcon->Designer, *FLastNotifyIcon, 2, MouseX, MouseY, Message.wParam And &HFFFF)
						Case WM_MBUTTONUP
							Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
							Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
							If FLastNotifyIcon->OnMouseUp AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then FLastNotifyIcon->OnMouseUp(*FLastNotifyIcon->Designer, *FLastNotifyIcon, 2, MouseX, MouseY, Message.wParam And &HFFFF)
						Case WM_MOUSEMOVE
							If FLastNotifyIcon->OnMouseMove Then FLastNotifyIcon->OnMouseMove(*Designer, *FLastNotifyIcon, 0, UnScaleX(GET_X_LPARAM(Message.lParam)), UnScaleY(GET_Y_LPARAM(Message.lParam)), Message.wParam And &HFFFF)
						Case WM_LBUTTONDBLCLK
							If FLastNotifyIcon->OnDblClick Then FLastNotifyIcon->OnDblClick(*FLastNotifyIcon->Designer, *FLastNotifyIcon)
						Case NIN_BALLOONUSERCLICK
							If FLastNotifyIcon->OnBalloonTipClicked Then FLastNotifyIcon->OnBalloonTipClicked(*FLastNotifyIcon->Designer, *FLastNotifyIcon)
						Case NIN_BALLOONSHOW
							If FLastNotifyIcon->OnBalloonTipShown Then FLastNotifyIcon->OnBalloonTipShown(*FLastNotifyIcon->Designer, *FLastNotifyIcon)
						Case NIN_BALLOONHIDE
							If FLastNotifyIcon->OnBalloonTipClosed Then FLastNotifyIcon->OnBalloonTipClosed(*FLastNotifyIcon->Designer, *FLastNotifyIcon)
						Case NIN_BALLOONTIMEOUT
							If FLastNotifyIcon->OnBalloonTipClosed Then FLastNotifyIcon->OnBalloonTipClosed(*FLastNotifyIcon->Designer, *FLastNotifyIcon)
						Case NIN_KEYSELECT
						Case NIN_SELECT
						End Select
					End If
				Case WM_LBUTTONDOWN
					DownButton = 0
					Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
					Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
					If OnMouseDown AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then OnMouseDown(*Designer, This, 0, MouseX, MouseY, Message.wParam And &HFFFF)
				Case WM_LBUTTONDBLCLK
					If OnDblClick Then OnDblClick(*Designer, This)
				Case WM_LBUTTONUP
					DownButton = -1
					If OnClick Then OnClick(*Designer, This)
					Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
					Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
					If OnMouseUp AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then OnMouseUp(*Designer, This, 0, MouseX, MouseY, Message.wParam And &HFFFF)
				Case WM_MBUTTONDOWN
					DownButton = 2
					Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
					Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
					If OnMouseDown AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then OnMouseDown(*Designer, This, 2, MouseX, MouseY, Message.wParam And &HFFFF)
				Case WM_MBUTTONUP
					DownButton = -1
					Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
					Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
					If OnMouseUp AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then OnMouseUp(*Designer, This, 2, MouseX, MouseY, Message.wParam And &HFFFF)
				Case WM_RBUTTONDOWN
					DownButton = 1
					Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
					Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
					If OnMouseDown AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then OnMouseDown(*Designer, This, 1, MouseX, MouseY, Message.wParam And &HFFFF)
				Case WM_RBUTTONUP
					DownButton = -1
					Dim As Integer MouseX = UnScaleX(GET_X_LPARAM(Message.lParam))
					Dim As Integer MouseY = UnScaleY(GET_Y_LPARAM(Message.lParam))
					If OnMouseUp AndAlso MouseX < 32000 AndAlso MouseY < 32000 AndAlso MouseX > -32000 AndAlso MouseY > -32000 Then OnMouseUp(*Designer, This, 1, MouseX, MouseY, Message.wParam And &HFFFF)
					If ContextMenu Then
						If ContextMenu->Handle Then
							Dim As ..Point P
							P.X = GET_X_LPARAM(Message.lParam)
							P.Y = GET_Y_LPARAM(Message.lParam)
							.ClientToScreen(This.Handle, @P)
							ContextMenu->Popup(P.X, P.Y)
						End If
					End If
				'Case WM_TOUCH
				Case WM_POINTERDOWN, WM_POINTERUPDATE, WM_POINTERUP
					If OnPointerDown = 0 AndAlso OnPointerUpdate = 0 AndAlso OnPointerUp = 0 Then
						Return
					End If
					Dim info As POINTER_INFO
					GetPointerInfo(Message.wParamLo, @info)
					Dim e As PointerEventArgs
					e.id = info.pointerId
					e.x = info.ptPixelLocation.X
					e.y = info.ptPixelLocation.Y
					Select Case info.pointerType
					Case PT_MOUSE:      e.pointerType = ptMouse
					Case PT_TOUCH:      e.pointerType = ptTouch
					Case PT_PEN:        e.pointerType = ptPen
					Case PT_POINTER:    e.pointerType = ptUnknown
					End Select
					e.buttons = 0
					Select Case info.pointerType
					Case PT_MOUSE
						If info.pointerFlags And POINTER_FLAG_FIRSTBUTTON Then e.buttons = e.buttons Or 1
						If info.pointerFlags And POINTER_FLAG_SECONDBUTTON Then e.buttons = e.buttons Or 2
						If info.pointerFlags And POINTER_FLAG_THIRDBUTTON Then e.buttons = e.buttons Or 4
					Case PT_TOUCH
						e.buttons = 1 ' finger = single button
					Case PT_PEN
						e.buttons = 1 ' pen = primary button
					End Select
					e.modifiers = Message.wParam And &HFFFF
					e.primary = IIf(info.pointerFlags And POINTER_FLAG_PRIMARY, 1, 0)
					Select Case Message.Msg
					Case WM_POINTERDOWN
						e.phase = PointerPhase.ppBegin
						If OnPointerDown Then OnPointerDown(*Designer, This, e)
					Case WM_POINTERUPDATE
						If info.pointerFlags And POINTER_FLAG_INCONTACT Then
							e.phase = PointerPhase.ppMove
						Else
							e.phase = PointerPhase.ppHover
						End If
						If OnPointerUpdate Then OnPointerUpdate(*Designer, This, e)
					Case WM_POINTERUP
						e.phase = PointerPhase.ppEnd
						If OnPointerUp Then OnPointerUp(*Designer, This, e)
					End Select
					If e.handled Then
						Message.Result = 0
					End If
				Case WM_GESTURENOTIFY
				Case WM_GESTURE
					If OnGesture = 0 Then
						Return
					End If
					Dim As GESTUREINFO gi
					gi.cbSize = SizeOf(GESTUREINFO)
					GetGestureInfo(Cast(HGESTUREINFO, Message.lParam), @gi)
					Dim e As GestureEventArgs
					If (gi.dwFlags And GF_BEGIN) = GF_BEGIN Then
						e.phase = GesturePhase.gpBegin
					ElseIf (gi.dwFlags And GF_INERTIA) = GF_INERTIA Then
						e.phase = GesturePhase.gpUpdate
					ElseIf(gi.dwFlags And GF_END) = GF_END Then
						e.phase = GesturePhase.gpEnd
					Else
						e.phase = GesturePhase.gpUpdate
					End If
					e.x = gi.ptsLocation.x
					e.y = gi.ptsLocation.y
					e.dx = LoWord(gi.ullArguments)
					e.dy = HiWord(gi.ullArguments)
					e.scale = gi.ullArguments / 100.0
					e.rotation = gi.ullArguments / 100.0
					Select Case gi.dwID
					Case GID_BEGIN:
					Case GID_END:
					Case GID_ZOOM: e.gestureType = GestureType.gtZoom
					Case GID_PAN: e.gestureType = GestureType.gtPan
					Case GID_ROTATE: e.gestureType = GestureType.gtRotate
					Case GID_TWOFINGERTAP: e.gestureType = GestureType.gtTwoFingerTap
					Case GID_PRESSANDTAP: e.gestureType = GestureType.gtPressAndTap
					End Select
					CloseGestureInfoHandle(Cast(HGESTUREINFO, Message.lParam))
					If OnGesture Then OnGesture(*Designer, This, e)
					If e.handled Then
						Message.Result = 0
					End If
				Case WM_MEASUREITEM
					Dim As MEASUREITEMSTRUCT Ptr miStruct
					miStruct = Cast(MEASUREITEMSTRUCT Ptr, Message.lParam)
					Select Case miStruct->CtlType
					Case ODT_LISTBOX, ODT_COMBOBOX, ODT_BUTTON, ODT_HEADER, ODT_LISTVIEW, ODT_STATIC, ODT_TAB
						Dim As Control Ptr Ctrl = Cast(Any Ptr, GetWindowLongPtr(GetDlgItem(FHandle, Message.wParam), GWLP_USERDATA))
						If Ctrl = 0 Then
							If Message.wParam - 1000 < Handles.Count Then
								Ctrl = Handles.Item(Message.wParam - 1000)
								If Ctrl Then
									Ctrl->Handle = GetDlgItem(FHandle, Message.wParam)
									SetWindowLongPtr Ctrl->Handle, GWLP_USERDATA, CInt(Ctrl)
								End If
							End If
						End If
						SendMessage(GetDlgItem(FHandle, Message.wParam), CM_MEASUREITEM, Message.wParam, Message.lParam)
					End Select
				Case WM_DRAWITEM
					Dim As DRAWITEMSTRUCT Ptr diStruct
					diStruct = Cast(DRAWITEMSTRUCT Ptr, Message.lParam)
					Select Case diStruct->CtlType
					Case ODT_BUTTON,ODT_COMBOBOX,ODT_HEADER,ODT_LISTBOX,ODT_LISTVIEW,ODT_STATIC,ODT_TAB
						SendMessage(Cast(HWND,diStruct->hwndItem),CM_DRAWITEM,Message.wParam,Message.lParam)
					End Select
				Case WM_COMMAND
					GetPopupMenuItems
					Dim As MenuItem Ptr mi
					For i As Integer = 0 To FPopupMenuItems.Count -1
						mi = FPopupMenuItems.Items[i]
						If mi->Command = Message.wParamLo Then
							If mi->OnClick Then mi->OnClick(*mi->Designer, *mi)
							Exit For
						End If
					Next i
					SendMessage(Cast(HWND, Message.lParam), CM_COMMAND, Message.wParam, Message.lParam)
				Case WM_SYSCOMMAND
					If Message.wParam = SC_KEYMENU Then
						Dim As Control Ptr frm = GetForm
						If frm <> 0 Then
							With *frm
								.GetControls
								Dim As Control Ptr Ctrl
								Dim As String Key = "&" & LCase(Chr(Message.lParam))
								For i As Integer = 0 To .FControls.Count - 1
									Ctrl = .FControls.Item(i)
									If InStr(LCase(Ctrl->Text), Key) > 0 Then
										Select Case Ctrl->ClassName
										Case "CommandButton"
											If Ctrl->OnClick Then Ctrl->OnClick(*Ctrl->Designer, *Ctrl)
											Message.Result = -2
											Message.Msg = 0
										Case "CheckBox", "RadioButton"
											SendMessage(Ctrl->Handle, CM_COMMAND, MAKEWPARAM(Ctrl->ID, BN_CLICKED), Cast(LPARAM, Ctrl->Handle))
											Message.Result = -2
											Message.Msg = 0
										Case "GroupBox"
											.FActiveControl = Ctrl
											Ctrl->SelectNextControl
											Message.Result = -2
											Message.Msg = 0
										Case "Label"
											.FActiveControl = Ctrl
											Ctrl->SelectNextControl
											Message.Result = -2
											Message.Msg = 0
										End Select
										Exit For
									End If
								Next
							End With
						End If
					End If
				Case WM_MOUSEMOVE
					If Not This.FMouseInClient Then
						This.FMouseInClient = True
						If OnMouseEnter Then OnMouseEnter(*Designer, This)
					End If
					If OnMouseMove Then OnMouseMove(*Designer, This, IIf(Message.wParam And MK_LBUTTON, 0, IIf(Message.wParam And MK_RBUTTON, 1, IIf(Message.wParam And MK_MBUTTON, 2, -1))), UnScaleX(GET_X_LPARAM(Message.lParam)), UnScaleY(GET_Y_LPARAM(Message.lParam)), Message.wParam And &HFFFF)
					If CInt(This.Tracked = False) AndAlso CInt((OnMouseLeave OrElse OnMouseHover OrElse OnMouseEnter)) Then
						Dim As TRACKMOUSEEVENT event_
						event_.cbSize = SizeOf(TRACKMOUSEEVENT)
						event_.dwFlags = TME_LEAVE Or TME_HOVER
						event_.hwndTrack = FHandle
						event_.dwHoverTime = FHoverTime 'milliseconds
						TRACKMOUSEEVENT(@event_)
						This.Tracked = True
					End If
				Case WM_MOUSEWHEEL
					Static scrDirection As Integer
						If Message.wParam < 4000000000 Then
							scrDirection = 1
						Else
							scrDirection = -1
						End If
					If OnMouseWheel Then OnMouseWheel(*Designer, This, scrDirection, UnScaleX(GET_X_LPARAM(Message.lParam)), UnScaleY(GET_Y_LPARAM(Message.lParam)), Message.wParam And &HFFFF)
				Case WM_MOUSELEAVE
					If OnMouseLeave Then OnMouseLeave(*Designer, This)
					This.FMouseInClient = False
					This.Tracked = False
				Case WM_MOUSEHOVER
					If OnMouseHover Then OnMouseHover(*Designer, This, DownButton, UnScaleX(GET_X_LPARAM(Message.lParam)), UnScaleY(GET_Y_LPARAM(Message.lParam)), Message.wParam And &HFFFF)
					This.Tracked = False
				Case WM_DROPFILES
					If OnDropFile Then
						Dim As HDROP iDrop = Cast(HDROP, Message.wParam)
						Dim As Integer filecount, length, i
						filecount = DragQueryFile(iDrop, -1, NULL, 0)
						Dim As WString Ptr filename
						For i = 0 To filecount - 1
							WReAllocate(filename, MAX_PATH)
							length = DragQueryFile(iDrop, i, filename, MAX_PATH)
							'*filename = Left(*filename, length)
							If OnDropFile Then OnDropFile(*Designer, This, *filename)
						Next
						_Deallocate( filename)
						DragFinish iDrop
					End If
				Case WM_CHAR
					If OnKeyPress Then OnKeyPress(*Designer, This, Message.wParam)
				Case WM_KEYDOWN
					If OnKeyDown Then OnKeyDown(*Designer, This, Message.wParam, IIf(bShift, ShiftMask, 0) Or IIf(bCtrl, CtrlMask, 0) Or IIf(bAlt, AltMask, 0))
					If GetKeyState(VK_MENU) >= 0 Then
						Select Case LoWord(Message.wParam)
						Case VK_TAB
							'							Dim Frm As Control Ptr = GetForm
							'							If Frm Then
							'								Frm->SelectNextControl bShift
							'								Message.Result = -1:
							'								Exit Sub
							'							End If
						Case VK_RETURN
							Dim frm As Control Ptr = GetForm
							If frm AndAlso frm->FDefaultButton AndAlso frm->FDefaultButton->OnClick Then
								frm->FDefaultButton->OnClick(*frm->Designer, *frm->FDefaultButton)
								Message.Result = -1:
								Exit Sub
							End If
						Case VK_ESCAPE
							Dim frm As Control Ptr = GetForm
							If frm AndAlso frm->FCancelButton AndAlso frm->FCancelButton->OnClick Then
								frm->FCancelButton->OnClick(*frm->Designer, *frm->FCancelButton)
								Message.Result = -1:
								Exit Sub
							End If
						End Select
					End If
				Case WM_KEYUP
					If OnKeyUp Then OnKeyUp(*Designer, This, LoWord(Message.wParam), IIf(bShift, ShiftMask, 0) Or IIf(bCtrl, CtrlMask, 0) Or IIf(bAlt, AltMask, 0))
				Case WM_SETFOCUS
					If OnGotFocus Then OnGotFocus(*Designer, This)
					If Not FDesignMode Then
						Dim frm As Control Ptr = GetForm
						If frm Then
							frm->FActiveControl = @This
							If frm->OnActiveControlChanged Then frm->OnActiveControlChanged(*frm)
						End If
					End If
				Case WM_KILLFOCUS
					If OnLostFocus Then OnLostFocus(*Designer, This)
				Case WM_NOTIFY
					Dim As LPNMHDR NM
					Static As HWND FWindow
					NM = Cast(LPNMHDR, Message.lParam)
					If NM->code = TTN_NEEDTEXT Then
						If FWindow Then SendMessage FWindow,CM_NEEDTEXT,Message.wParam, Message.lParam
					Else
						FWindow = NM->hwndFrom
						Dim As Control Ptr Ctrl = Cast(Any Ptr, GetWindowLongPtr(FWindow, GWLP_USERDATA))
						If Ctrl <> 0 Then
							If IndexOf(Ctrl) <> -1 Then
								Message.Msg = CM_NOTIFY
								Ctrl->ProcessMessage(Message)
							Else
								SendMessage FWindow, CM_NOTIFY, Message.wParam, Message.lParam
							End If
						End If
					End If
				Case WM_HELP
					'If (GetWindowLong(message.hwnd,GWL_STYLE) And WS_CHILD) <> WS_CHILD Then SendMessage(message.hwnd,CM_HELP,message.wParam,message.LParam)
				Case WM_NEXTDLGCTL
					Dim As Control Ptr NextCtrl
					Dim As Control Ptr frm = GetForm
					If frm Then
						NextCtrl = frm->SelectNextControl()
						If NextCtrl Then NextCtrl->SetFocus
					End If
				Case WM_DESTROY
					SetWindowLongPtr(FHandle, GWLP_USERDATA, 0)
					If OnDestroy Then OnDestroy(*Designer, This) Else Handle = 0
				Case WM_NCDESTROY
					Handle = 0
				End Select
		End Sub
		
		Private Sub Control.ProcessMessageAfter(ByRef Message As Message)
				Select Case Message.Msg
				Case WM_NCHITTEST
					If FDesignMode Then
						If ClassName <> "Form" Then
							'Message.Result = HTTRANSPARENT
						End If
					End If
				Case WM_DESTROY
					SetWindowLongPtr(FHandle, GWLP_USERDATA, 0)
					If OnDestroy Then OnDestroy(*Designer, This)
					'Handle = 0
				End Select
		End Sub
		
		Private Function Control.EnumPopupMenuItems(ByRef Item As MenuItem) As Boolean
			FPopupMenuItems.Add Item
			For i As Integer = 0 To Item.Count -1
				EnumPopupMenuItems *Item.Item(i)
			Next i
			Return True
		End Function
		
		Private Sub Control.GetPopupMenuItems
			FPopupMenuItems.Clear
			If ContextMenu Then
				For i As Integer = 0 To ContextMenu->Count - 1
					EnumPopupMenuItems *ContextMenu->Item(i)
				Next i
			End If
			If FLastNotifyIcon AndAlso FLastNotifyIcon->ContextMenu Then
				For i As Integer = 0 To FLastNotifyIcon->ContextMenu->Count - 1
					EnumPopupMenuItems *FLastNotifyIcon->ContextMenu->Item(i)
				Next i
			End If
		End Sub
		
		Private Function Control.EnumControls(Item As Control Ptr) As Boolean
			FControls.Add Item
			For i As Integer = 0 To Item->ControlCount - 1
				EnumControls Item->Controls[i]
			Next i
			Return True
		End Function
		
		Private Sub Control.GetControls
			FControls.Clear
			For i As Integer = 0 To ControlCount - 1
				EnumControls Controls[i]
			Next i
		End Sub
		
			Private Function Control.DefWndProc(FWindow As HWND, Msg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
				Dim Message As Message
				Dim As Control Ptr Ctrl
				'Dim As Integer CtrlID = GetDlgCtrlID(FWindow)
				'If CtrlID = 0 Then
				Ctrl = Cast(Any Ptr, GetWindowLongPtr(FWindow, GWLP_USERDATA))
				'Else
				'	Ctrl = Handles.Item(GetDlgCtrlID(FWindow) - 1000)
				'	If Ctrl->Handle = 0 Then Ctrl->Handle = FWindow
				'End If
				Message = Type(Ctrl, FWindow, Msg, wParam, lParam, 0, LoWord(wParam), HiWord(wParam), LoWord(lParam), HiWord(lParam), 0)
				If Ctrl Then
					'?Ctrl
					If Ctrl->ClassName <> "" Then
						Ctrl->ProcessMessage(Message)
						If Message.Handled Then
							Return Message.Result
						ElseIf Message.Result = -1 Then
							Return Message.Result
						ElseIf Message.Result = -2 Then
							Msg = Message.Msg
							wParam = Message.wParam
							lParam = Message.lParam
						ElseIf Message.Result = -3 Then
							Message.Result = DefMDIChildProc(FWindow, Msg, wParam, lParam)
							Return Message.Result
						ElseIf Message.Result = -4 Then
							Message.Result = DefFrameProc(FWindow, Message.hWnd, Msg, wParam, lParam)
							Return Message.Result
						ElseIf Message.Result <> 0 Then
							Return Message.Result
						End If
					End If
				End If
				Message.Result = DefWindowProc(FWindow, Msg, wParam, lParam)
				'				If Ctrl Then
				'					Ctrl->ProcessMessageAfter(Message)
				'				End If
				Return Message.Result
			End Function
			
			Private Function Control.CallWndProc(FWindow As HWND, Msg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
				Dim Message As Message
				Dim As Control Ptr Ctrl
				Dim As Any Ptr Proc = @DefWindowProc
				Dim As Integer CtrlID = GetDlgCtrlID(FWindow)
				'If CtrlID = 0 Then
				Ctrl = Cast(Any Ptr, GetWindowLongPtr(FWindow, GWLP_USERDATA))
				'Else
				'	Ctrl = Handles.Item(GetDlgCtrlID(FWindow) - 1000)
				'	If Ctrl->Handle = 0 Then Ctrl->Handle = FWindow
				'End If
				'Ctrl = Cast(Any Ptr,GetWindowLongPtr(FWindow,GWLP_USERDATA))
				Message = Type(Ctrl, FWindow,Msg,wParam,lParam,0,LoWord(wParam),HiWord(wParam),LoWord(lParam),HiWord(lParam),Message.Captured)
				If Ctrl Then
					Proc = Ctrl->PrevProc
					Ctrl->ProcessMessage(Message)
					If Message.Handled Then
						Return Message.Result
					ElseIf Message.Result = -1 Then
						Return Message.Result
					ElseIf Message.Result = -2 Then
						Msg = Message.Msg
						wParam = Message.wParam
						lParam = Message.lParam
					ElseIf Message.Result <> 0 Then
						Return Message.Result
					End If
					Message.Result = CallWindowProc(Proc,FWindow,Msg,wParam,lParam)
					'					If Ctrl Then
					'						Ctrl->ProcessMessageAfter(Message)
					'					End If
				End If
				Return Message.Result
			End Function
			
			Private Function Control.SuperWndProc(FWindow As HWND, Msg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
				'On Error Goto ErrorHandler
				Dim As Control Ptr Ctrl
				Dim Message As Message
				'Dim As Integer CtrlID = GetDlgCtrlID(FWindow)
				'If CtrlID = 0 Then
				Ctrl = Cast(Any Ptr, GetWindowLongPtr(FWindow, GWLP_USERDATA))
				'Else
				'	Ctrl = Handles.Item(GetDlgCtrlID(FWindow) - 1000)
				'	If Ctrl->Handle = 0 Then Ctrl->Handle = FWindow
				'End If
				'Ctrl = GetProp(FWindow, "MFFControl")
				Message = Type(Ctrl, FWindow, Msg, wParam, lParam, 0, LoWord(wParam), HiWord(wParam), LoWord(lParam), HiWord(lParam), Message.Captured)
				If Ctrl Then
					With *Ctrl
						If Ctrl->ClassName <> "" Then
							.ProcessMessage(Message)
							If Message.Handled Then
								Return Message.Result
							ElseIf Message.Result = -1 Then
								Return Message.Result
							ElseIf Message.Result = -2 Then
								Msg = Message.Msg
								wParam = Message.wParam
								lParam = Message.lParam
							ElseIf Message.Result <> 0 Then
								Return Message.Result
							End If
						End If
					End With
				End If
				Dim As Any Ptr cp = GetClassProc(FWindow)
				If cp <> 0 Then
					Message.Result = CallWindowProc(cp, FWindow, Msg, wParam, lParam)
				End If
				'				If Ctrl AndAlso Ctrl->ClassName <> "" Then
				'					Ctrl->ProcessMessageAfter(Message)
				'				End If
				Return Message.Result
				'    Exit Function
				'ErrorHandler:
				'    ?GetMessageName(msg) & " " & ErrDescription(Err) & " (" & Err & ") " & _
				'        "in line " & Erl() & " " & _
				'        "in function " & ZGet(Erfn()) & " " & _
				'        "in module " & ZGet(Ermn())
				'        Sleep
			End Function
			
			Private Function Control.Perform(Msg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
				If FHandle Then
					Return SendMessageW(FHandle, Msg, wParam, lParam)
				Else
					Return 0
				End If
			End Function
		
		Private Function Control.SelectNextControl(Prev As Boolean = False) As Control Ptr
				Dim As Control Ptr ParentCtrl = GetForm
				Dim As Control Ptr Ctrl
				If ParentCtrl Then
					With ParentCtrl->FTabIndexList
						Dim As Integer Idx = .IndexOfObject(ParentCtrl->FActiveControl)
						If Prev Then
							For i As Integer = Idx - 1 To 0 Step -1
								Ctrl = .Object(i)
								If Ctrl->FTabStop AndAlso Ctrl->Visible AndAlso Ctrl->Enabled Then Ctrl->SetFocus: Return Ctrl
							Next
							For i As Integer = .Count - 1 To Idx + 1 Step -1
								Ctrl = .Object(i)
								If Ctrl->FTabStop AndAlso Ctrl->Visible AndAlso Ctrl->Enabled Then Ctrl->SetFocus: Return Ctrl
							Next
						Else
							For i As Integer = Idx + 1 To .Count - 1
								Ctrl = .Object(i)
								If Ctrl->FTabStop AndAlso Ctrl->Visible AndAlso Ctrl->Enabled Then Ctrl->SetFocus: Return Ctrl
							Next
							For i As Integer = 0 To Idx - 1
								Ctrl = .Object(i)
								If Ctrl->FTabStop AndAlso Ctrl->Visible AndAlso Ctrl->Enabled Then Ctrl->SetFocus: Return Ctrl
							Next
						End If
					End With
				End If
			Return 0
		End Function
		
		Private Sub Control.Move(cLeft As Integer, cTop As Integer, cWidth As Integer, cHeight As Integer)
			Base.Move IIf(FDesignMode AndAlso (Designer = @This), 0, IIf(Constraints.Left, Constraints.Left, cLeft)), IIf(FDesignMode AndAlso (Designer = @This), 0, IIf(Constraints.Top, Constraints.Top, cTop)), IIf(Constraints.Width, Constraints.Width, cWidth), IIf(Constraints.Height, Constraints.Height, cHeight)
		End Sub
		
			Private Function Control.RegisterClass(ByRef wClassName As WString, ByRef wClassAncestor As WString = "", WndProcAddr As Any Ptr = 0) As Integer
				Dim As Integer Result
				Dim As WNDCLASSEX Wc
				Dim As Any Ptr ClassProc
				Dim PROC As Function(FWindow As HWND, MSG As UINT, WPARAM As WPARAM, LPARAM As LPARAM) As LRESULT = WndProcAddr
				ZeroMemory(@Wc, SizeOf(WNDCLASSEX))
				Wc.cbSize = SizeOf(WNDCLASSEX)
				If wClassAncestor <> "" Then
					If GetClassInfoEx(0, wClassAncestor, @Wc) <> 0 Then
						ClassProc = Wc.lpfnWndProc
						Wc.lpszClassName = @wClassName
						If wClassName <> "WebBrowser" Then
							Wc.lpfnWndProc   = IIf(WndProcAddr = 0, @SuperWndProc, PROC)
							Wc.cbWndExtra += 4
						End If
						Wc.hInstance     = Instance
						'If Cursor AndAlso Cursor->Handle Then Wc.hCursor = Cursor->Handle
						Result = .RegisterClassEx(@Wc)
						If Result Then
							StoreClass wClassName, wClassAncestor, ClassProc
						End If
					ElseIf GetClassInfoEx(Instance, wClassAncestor, @Wc) <> 0 Then
						ClassProc = GetClassProc(wClassAncestor)
						'If Cursor AndAlso Cursor->Handle Then Wc.hCursor = Cursor->Handle
						Wc.lpszClassName = @wClassName
						Wc.lpfnWndProc   = IIf(WndProcAddr = 0, @DefWndProc, PROC)
						Result = .RegisterClassEx(@Wc)
						If Result Then
							StoreClass wClassName, wClassAncestor, ClassProc
						End If
					Else
						MessageBox NULL, "Unable to register class" & " '" & wClassName & "'", "Control", MB_ICONERROR
					End If
				Else
					If GetClassInfoEx(GetModuleHandle(NULL), wClassName, @Wc) = 0 Then
						Wc.lpszClassName = @wClassName
						Wc.lpfnWndProc   = IIf(WndProcAddr = 0, @DefWndProc, PROC)
						Wc.style = CS_DBLCLKS Or CS_HREDRAW Or CS_VREDRAW
						Wc.hInstance     = Instance
						Wc.hCursor       = LoadCursor(NULL, IDC_ARROW)
						Wc.hbrBackground = Cast(HBRUSH, 0)
						Result = .RegisterClassEx(@Wc)
					End If
				End If
				Return Result
			End Function
		
		Private Sub Control.SetMargins(mLeft As Integer, mTop As Integer, mRight As Integer, mBottom As Integer)
			Margins.Left   = mLeft
			Margins.Top    = mTop
			Margins.Right  = mRight
			Margins.Bottom = mBottom
			RequestAlign
		End Sub
		
		Sub Control.GetMax(ByRef MaxWidth As Integer, ByRef MaxHeight As Integer)
			MaxWidth = 0
			MaxHeight = 0
			For i As Integer = 0 To ControlCount - 1
				With *Controls[i]
					If .FVisible Then
							If MaxWidth < .Left + .Width + .ExtraMargins.Right Then MaxWidth = .Left + .Width + .ExtraMargins.Right
							If MaxHeight < .Top + .Height + .ExtraMargins.Bottom Then MaxHeight = .Top + .Height + .ExtraMargins.Bottom
					End If
				End With
			Next
			MaxWidth += Margins.Right
			MaxHeight += Margins.Bottom
		End Sub
		
		Private Sub Control.RequestAlign(iClientWidth As Integer = -1, iClientHeight As Integer = -1, bInDraw As Boolean = False, bWithoutControl As Control Ptr = 0)
			Dim As Control Ptr Ptr ListLeft, ListRight, ListTop, ListBottom, ListClient
			Dim As Integer i,LeftCount = 0, RightCount = 0, TopCount = 0, BottomCount = 0, ClientCount = 0
			Dim As Integer tTop, bTop, lLeft, rLeft
			Dim As Integer aLeft, aTop, aWidth, aHeight
			If iClientWidth = -1 Then iClientWidth = ClientWidth
			If iClientHeight = -1 Then iClientHeight = ClientHeight
			'If ClassName = "ScrollControl" Then iClientWidth = Width: iClientHeight = Height
			If iClientWidth <= 0 OrElse iClientHeight <= 0 Then Exit Sub
			lLeft = Margins.Left
			rLeft = iClientWidth - Margins.Right
			tTop  = Margins.Top
			bTop  = iClientHeight - Margins.Bottom
			If ControlCount <> 0 Then
				'This.UpdateLock
				For i = 0 To ControlCount - 1
					'If Controls[i]->Handle = 0 Then Continue For
					Select Case Controls[i]->Align
					Case 1'alLeft
						LeftCount += 1
						ListLeft = _Reallocate(ListLeft,SizeOf(Control Ptr)*LeftCount)
						ListLeft[LeftCount - 1] = Controls[i]
					Case 2'alRight
						RightCount += 1
						ListRight = _Reallocate(ListRight,SizeOf(Control Ptr)*RightCount)
						ListRight[RightCount - 1] = Controls[i]
					Case 3'alTop
						TopCount += 1
						ListTop = _Reallocate(ListTop, SizeOf(Control Ptr)*TopCount)
						ListTop[TopCount - 1] = Controls[i]
					Case 4'alBottom
						BottomCount += 1
						ListBottom = _Reallocate(ListBottom,SizeOf(Control Ptr)*BottomCount)
						ListBottom[BottomCount - 1] = Controls[i]
					Case 5'alClient
						ClientCount += 1
						ListClient = _Reallocate(ListClient,SizeOf(Control Ptr)*ClientCount)
						ListClient[ClientCount - 1] = Controls[i]
					Case Else
						If ClassName = "VerticalBox" Then
							TopCount += 1
							ListTop = _Reallocate(ListTop, SizeOf(Control Ptr)*TopCount)
							ListTop[TopCount - 1] = Controls[i]
						ElseIf ClassName = "HorizontalBox" Then
							LeftCount += 1
							ListLeft = _Reallocate(ListLeft,SizeOf(Control Ptr)*LeftCount)
							ListLeft[LeftCount - 1] = Controls[i]
						ElseIf ClassName = "PagePanel" AndAlso Controls[i]->Name <> "PagePanel_NumericUpDownControl" Then
							ClientCount += 1
							ListClient = _Reallocate(ListClient,SizeOf(Control Ptr)*ClientCount)
							ListClient[ClientCount - 1] = Controls[i]
						End If
					End Select
					With *Controls[i]
						If Cast(Integer, .Anchor.Left) + Cast(Integer, .Anchor.Right) + Cast(Integer, .Anchor.Top) + Cast(Integer, .Anchor.Bottom) <> 0 Then
								If CInt(.FVisible) AndAlso CInt(.Handle) Then
								aLeft = .FLeft: aTop = .FTop: aWidth = .FWidth: aHeight = .FHeight
								This.FWidth = This.Width: This.FHeight = This.Height
								If .Anchor.Left <> asNone Then
									If .Anchor.Left = asAnchorProportional Then aLeft = This.FWidth / .FAnchoredParentWidth * .FAnchoredLeft
									If .Anchor.Right <> asNone Then aWidth = This.FWidth - aLeft - IIf(.Anchor.Right = asAnchor, .FAnchoredRight, This.FWidth / .FAnchoredParentWidth * .FAnchoredRight)
								ElseIf .Anchor.Right <> asNone Then
									aLeft = This.FWidth - .FWidth - IIf(.Anchor.Right = asAnchor, .FAnchoredRight, This.FWidth / .FAnchoredParentWidth * .FAnchoredRight)
								End If
								If .Anchor.Top <> asNone Then
									If .Anchor.Top = asAnchorProportional Then aTop = This.FHeight / .FAnchoredParentHeight * .FAnchoredTop
									If .Anchor.Bottom <> asNone Then aHeight = This.FHeight - aTop - IIf(.Anchor.Bottom = asAnchor, .FAnchoredBottom, This.FHeight / .FAnchoredParentHeight * .FAnchoredBottom)
								ElseIf .Anchor.Bottom <> asNone Then
									aTop = This.FHeight - .FHeight - IIf(.Anchor.Bottom = asAnchor, .FAnchoredBottom, This.FHeight / .FAnchoredParentHeight * .FAnchoredBottom)
								End If
								If bWithoutControl <> Controls[i] Then .SetBounds(aLeft, aTop, aWidth, aHeight)
							End If
						End If
					End With
				Next i
				'?ClassName, rLeft, bTop
				For i = 0 To TopCount -1
					With *ListTop[i]
						If .FVisible Then
								tTop += .ExtraMargins.Top + .Height + .ExtraMargins.Bottom + IIf(i = 0, 0, FVerticalSpacing)
							If bWithoutControl <> ListTop[i] Then .SetBounds(lLeft + .ExtraMargins.Left, tTop - .Height - .ExtraMargins.Bottom, rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, .Height)
						End If
					End With
				Next i
				'bTop = ClientHeight
				For i = 0 To BottomCount -1
					With *ListBottom[i]
						If .FVisible Then
							bTop -= .ExtraMargins.Top + .Height + .ExtraMargins.Bottom - IIf(i = 0, 0, FVerticalSpacing)
							If bWithoutControl <> ListBottom[i] Then .SetBounds(lLeft + .ExtraMargins.Left, bTop + .ExtraMargins.Top, rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, .Height)
						End If
					End With
				Next i
				'lLeft = 0
				For i = 0 To LeftCount -1
					With *ListLeft[i]
						If .FVisible Then
							lLeft += .ExtraMargins.Left + .Width + .ExtraMargins.Right + IIf(i = 0, 0, FHorizontalSpacing)
							If bWithoutControl <> ListLeft[i] Then .SetBounds(lLeft - .Width - .ExtraMargins.Right, tTop + .ExtraMargins.Top, .Width, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom)
						End If
					End With
				Next i
				'rLeft = ClientWidth
				For i = 0 To RightCount -1
					With *ListRight[i]
						If .FVisible Then
							rLeft -= .ExtraMargins.Left + .Width + .ExtraMargins.Right - IIf(i = 0, 0, FHorizontalSpacing)
							If bWithoutControl <> ListRight[i] Then .SetBounds(rLeft + .ExtraMargins.Left, tTop + .ExtraMargins.Top, .Width, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom)
						End If
					End With
				Next i
				For i = 0 To ClientCount - 1
					With *ListClient[i]
						'If .FVisible Then
						If bWithoutControl <> ListClient[i] Then .SetBounds(lLeft + .ExtraMargins.Left, tTop + .ExtraMargins.Top, rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom)
						'End If
					End With
				Next i
			End If
			If FAutoSize AndAlso ControlCount <> 0 Then
				Dim As Integer MaxWidth, MaxHeight
				
				GetMax MaxWidth, MaxHeight
				
					If Height <> MaxHeight + Height - iClientHeight OrElse Width <> MaxWidth + Width - iClientWidth  Then
						If MaxHeight + Height - iClientHeight <> 0 AndAlso MaxWidth + Width - iClientWidth <> 0 Then
							Move FLeft, FTop, MaxWidth + Width - iClientWidth, MaxHeight + Height - iClientHeight
						End If
					End If
			End If
				If FClient Then
					FClientX = lLeft: FClientY = tTop: FClientW = Max(0, rLeft - lLeft): FClientH = Max(0, bTop - tTop)
					MoveWindow FClient, ScaleX(FClientX), ScaleY(FClientY), ScaleX(FClientW), ScaleY(FClientH), True
				End If
			'#EndIf
			If ListLeft   Then _Deallocate( ListLeft)
			If ListRight  Then _Deallocate( ListRight)
			If ListTop    Then _Deallocate( ListTop)
			If ListBottom Then _Deallocate( ListBottom)
			If ListClient Then _Deallocate( ListClient)
			'This.UpdateUnLock
		End Sub
		
		Private Sub Control.ClientToScreen(ByRef P As My.Sys.Drawing.Point)
				If FHandle Then .ClientToScreen FHandle, Cast(..Point Ptr, @P)
		End Sub
		
		Private Sub Control.ScreenToClient(ByRef P As My.Sys.Drawing.Point)
				If FHandle Then .ScreenToClient FHandle, Cast(..Point Ptr, @P)
		End Sub
		
		Private Sub Control.Invalidate(ByVal iRect As Any Ptr = 0, ByVal bErase As Boolean = True)
				If FHandle Then
					If iRect = 0 Then
						InvalidateRect(FHandle, 0, bErase)
					Else
						InvalidateRect(FHandle, Cast(Rect Ptr, iRect), bErase)
					End If
				End If
		End Sub
		
		Private Sub Control.Repaint
				If FHandle Then
					RedrawWindow FHandle, 0, 0, RDW_INVALIDATE Or RDW_ALLCHILDREN
					Update
				End If
		End Sub
		
		Private Sub Control.Update
				If FHandle Then UpdateWindow FHandle
		End Sub
		
		Private Sub Control.UpdateLock
				If FHandle Then LockWindowUpdate FHandle
		End Sub
		
		Private Sub Control.UpdateUnLock
				If FHandle Then LockWindowUpdate 0
		End Sub
		
		Private Sub Control.SetFocus
				If FHandle Then .SetFocus FHandle
		End Sub
		
		Private Sub Control.BringToFront
				If FHandle Then SetWindowPos FHandle, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE 'BringWindowToTop Handle
		End Sub
		
		Private Sub Control.SendToBack
				If FHandle Then SetWindowPos FHandle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
		End Sub
		
			Private Sub Control.AllocateHint
				If FHandle Then
					If ToolTipHandle Then DestroyWindow ToolTipHandle
					ToolTipHandle = CreateWindowEx(0, TOOLTIPS_CLASS, "", TTS_ALWAYSTIP Or WS_POPUP, 0, 0, 0, 0, FHandle, NULL, GetModuleHandle(NULL), NULL)
					FToolInfo.cbSize=SizeOf(TOOLINFO)
					FToolInfo.uFlags   = TTF_IDISHWND Or TTF_SUBCLASS
					SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_INITIAL, 100)
					If FParent Then FToolInfo.hwnd = FParent->Handle
					FToolInfo.hinst    = GetModuleHandle(NULL)
					FToolInfo.uId      = Cast(Integer, FHandle)
					FToolInfo.lpszText = FHint
					SendMessage(ToolTipHandle, TTM_ADDTOOL, 0, CInt(@FToolInfo))
				End If
			End Sub
		
		Private Sub Control.Add(Ctrl As Control Ptr, Index As Integer = -1)
			'On Error Goto ErrorHandler
			If Ctrl Then
				Dim As Control Ptr FSaveParent = Ctrl->Parent
				Ctrl->FParent = @This
				FControlCount += 1
				Controls = _Reallocate(Controls, SizeOf(Control Ptr)*FControlCount)
				If Index = -1 Then
					Controls[FControlCount - 1] = Ctrl
				Else
					For i As Integer = Index To FControlCount - 2
						Controls[i + 1] = Controls[i]
					Next
					Controls[Index] = Ctrl
				End If
					If Ctrl->Handle Then
						If FHandle Then
							SetParent Ctrl->Handle, FHandle
							Ctrl->FAnchoredParentWidth = This.Width
							Ctrl->FAnchoredParentHeight = This.Height
							Ctrl->FAnchoredLeft = Ctrl->FLeft
							Ctrl->FAnchoredTop = Ctrl->FTop
							Ctrl->FAnchoredRight = Ctrl->FAnchoredParentWidth - Ctrl->FWidth - Ctrl->FLeft
							Ctrl->FAnchoredBottom = Ctrl->FAnchoredParentHeight - Ctrl->FHeight - Ctrl->FTop
						End If
					ElseIf FHandle Then
						'#IFDEF __AUTOMATE_CREATE_CHILDS__
						Ctrl->CreateWnd
						'#ENDIF
					End If
				If Ctrl->FTabIndex = -1 Then Ctrl->ChangeTabIndex - 1
				RequestAlign
				If FSaveParent Then
					If FSaveParent <> @This Then
						FSaveParent->Remove Ctrl
						FSaveParent->RequestAlign
					End If
				End If
			End If
			'Exit Sub
			'ErrorHandler:
			'Print ErrDescription(Err) & " (" & Err & ") " & _
			'"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
			'"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
			'"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
		End Sub
		
		Private Sub Control.AddRange cdecl(CountArgs As Integer, ...)
			'Dim value As Any Ptr
			Dim args As Cva_List
			'value = va_first()
			Cva_Start(args, CountArgs)
			For i As Integer = 1 To CountArgs
				'Add(va_arg(value, Control Ptr))
				Add(Cva_Arg(args, Control Ptr))
				'value = va_next(value, Long)
			Next
			Cva_End(args)
		End Sub
		
		Private Sub Control.Remove(Ctrl As Control Ptr)
			Dim As Any Ptr P
			Dim As Integer i,x,Index
			If Ctrl->FTabIndex <> -2 Then Ctrl->ChangeTabIndex -1
			Index = IndexOf(Ctrl)
			If Index >= 0 And Index <= FControlCount -1 Then
				For i = Index + 1 To FControlCount -1
					P = Controls[i]
					Controls[i -1] = P
				Next i
				FControlCount -= 1
				If FControlCount = 0 Then
					_Deallocate(Controls)
					Controls = 0
				Else
					Controls = _Reallocate(Controls,FControlCount*SizeOf(Control Ptr))
				End If
				'DeAllocate P
			End If
		End Sub
		
		Private Function Control.IndexOf(Ctrl As Control Ptr) As Integer
			Dim As Integer i
			For i = 0 To ControlCount -1
				If Controls[i] = Ctrl Then Return i
			Next i
			Return -1
		End Function
		
			Private Function Control.IndexOf(CtrlName As String) As Integer
				Dim As Integer i
				For i = 0 To ControlCount -1
					If Controls[i]->Name = CtrlName Then Return i
				Next i
				Return -1
			End Function
		
		Private Function Control.ControlByName(CtrlName As String) As Control Ptr
			Dim i As Integer = IndexOf(CtrlName)
			If i <> -1 Then
				Return Controls[i]
			Else
				Return 0
			End If
		End Function
		
		Private Operator Control.Cast As Any Ptr
			Return @This
		End Operator
		
		Private Operator Control.Let(ByRef Value As Control Ptr)
			If Value Then
				This = *Cast(Control Ptr,Value)
			End If
		End Operator
		
		Private Function Control.DoDragDrop(ByRef DataObject As DataObject, AllowedEffects As DragDropEffects) As DragDropEffects
				Dim dropEff As DWORD
				.DoDragDrop DataObject.pDataObject, Cast(LPDROPSOURCE, @FDropSource), AllowedEffects, @dropEff
				Return dropEff
			Return 0
		End Function
		
		Private Constructor Control
			WLet(FClassName, "Control")
			WLet(FClassAncestor, "")
			Text = ""
			FLeft = 0
			FTop = 0
			FWidth = 0
			FHeight = 0
			FBackColor = -1
			FDefaultBackColor = FBackColor
			FDefaultForeColor = FForeColor
			FTabIndex = -2
			FShowHint = True
			FShowCaption = True
			FVisible = True
			FEnabled = True
			Cursor.Ctrl = @This
				FDropTarget.Ctrl = @This
				FDropSource.Ctrl = @This
		End Constructor
		
		Private Destructor Control
				FDropTarget.AllowDrop False
			FreeWnd
			'If FText Then Deallocate FText
			If FProgID Then _Deallocate(FProgID)
			If FHint Then _Deallocate(FHint)
			'			Dim As Integer i
			'			For i = 0 To ControlCount -1
			'			    If Controls[i] Then Controls[i]->Free
			'			Next i
			If Controls Then _Deallocate( Controls)
			FControlCount = 0
			FPopupMenuItems.Clear
		End Destructor
End Namespace

	Function Q_Control Alias "QControl" (Ctrl As Any Ptr) As My.Sys.Forms.Control Ptr __EXPORT__
		Return Cast(My.Sys.Forms.Control Ptr, Ctrl)
	End Function

	Sub RemoveControl Alias "RemoveControl"(Parent As My.Sys.Forms.Control Ptr, Ctrl As My.Sys.Forms.Control Ptr) Export
		Parent->Remove Ctrl
	End Sub

	Function ControlByIndex Alias "ControlByIndex"(Parent As My.Sys.Forms.Control Ptr, Index As Integer) As My.Sys.Forms.Control Ptr Export
		Return Parent->Controls[Index]
	End Function

	Function ControlByName Alias "ControlByName"(Parent As My.Sys.Forms.Control Ptr, CtrlName As String) As My.Sys.Forms.Control Ptr Export
		Return Parent->ControlByName(CtrlName)
	End Function

	Function IsControl Alias "IsControl"(Cpnt As My.Sys.ComponentModel.Component Ptr) As Boolean Export
		Return *Cpnt Is My.Sys.Forms.Control
	End Function

	Sub ControlSetFocus Alias "ControlSetFocus"(Ctrl As My.Sys.Forms.Control Ptr) Export
		Ctrl->SetFocus()
	End Sub

	Sub ControlFreeWnd Alias "ControlFreeWnd"(Ctrl As My.Sys.Forms.Control Ptr) Export
		Ctrl->FreeWnd()
	End Sub

	Sub ControlRepaint Alias "ControlRepaint" (Ctrl As My.Sys.Forms.Control Ptr) Export
		Ctrl->Repaint()
	End Sub

