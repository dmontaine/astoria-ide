'###############################################################################
'#  Splitter.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TSplitter.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "Splitter.bi"

Namespace My.Sys.Forms
		Private Function Splitter.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "align": Return @FAlign
			Case "minextra": Return @MinExtra
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Splitter.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "align": This.Align = *Cast(SplitterAlignmentConstants Ptr, Value)
			Case "minextra": This.MinExtra = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
		Private Sub Splitter.WndProc(ByRef Message As Message)
			'        If Message.Sender Then
			'            If Cast(TControl Ptr,Message.Sender)->Child Then
			'               Cast(Splitter Ptr,Cast(TControl Ptr,Message.Sender)->Child)->ProcessMessage(Message)
			'            End If
			'        End If
		End Sub
	
	Private Property Splitter.Align As SplitterAlignmentConstants
		Return Base.Align
	End Property
	
	Private Sub Splitter.DrawTrackSplit(x As Integer, y As Integer)
'			Static As Word DotBits(7) =>{&H5555, &HAAAA, &H5555, &HAAAA, &H5555, &HAAAA, &H5555, &HAAAA}
'			Dim As HDC Dc
'			Dim As HBRUSH hbr
'			Dim As HBITMAP Bmp
'			Dc  = GetDCEx(This.Parent->Handle,0,dcx_cache Or dcx_clipsiblings) ' or dcx_lockwindowupdate
'			Bmp = CreateBitmap(8,8,1,1,@DotBits(0))
'			hbr = SelectObject(Dc,CreatePatternBrush(Bmp))
'			DeleteObject(Bmp)
'			PatBlt(Dc, x, y, ScaleX(ClientWidth), ScaleY(ClientHeight), patinvert)
'			DeleteObject(SelectObject(Dc,hbr))
'			ReleaseDC(This.Parent->Handle,Dc)
	End Sub
	
	Private Property Splitter.Align(value As SplitterAlignmentConstants)
		Base.Align = *Cast(DockStyle Ptr, @value)
		Select Case value
		Case 1, 2
			This.Cursor = crSizeWE
			This.Width = 3
		Case 3, 4
			This.Cursor = crSizeNS
			This.Height = 3
		Case Else
			This.Cursor = crArrow
		End Select
	End Property
	
		Private Sub Splitter.ParentWndProc(ByRef Message As Message)
			Dim As Control Ptr Ctrl
			Select Case Message.Msg
			Case WM_MOUSEMOVE
				If Message.Captured Then
					Dim As Integer x, y
					Ctrl = Cast(Control Ptr, GetWindowLongPtr(Message.Captured ,GWLP_USERDATA))
					If Ctrl Then
						If Ctrl->Child Then
						End If
					End If
				End If
			Case WM_LBUTTONUP
				SendMessage Message.Captured, WM_LBUTTONUP, Message.lParam, Message.lParam
				If Message.Captured Then
					Ctrl = Cast(Control Ptr, GetWindowLongPtr(Message.Captured, GWLP_USERDATA))
					If Ctrl Then
						If Ctrl->Child Then
						End If
					End If
				End If
				ReleaseCapture
			End Select
		End Sub
	
	Private Sub Splitter.ProcessMessage(ByRef Message As Message)
		Static As Long xOrig, yOrig, xCur, yCur, i, down1
			Static As ..Point g_OrigCursorPos, g_CurCursorPos
			Select Case Message.Msg
			Case WM_SETCURSOR
				If CInt(Cursor.Handle <> 0) AndAlso CInt(Not FDesignMode) Then Message.Result = Cast(LResult, SetCursor(Cursor.Handle)): Return
			Case WM_PAINT
				Dim As ..Rect R
				Dim As HDC Dc
				Dc = GetDC(Handle)
				GetClientRect Handle, @R
				SetBKMode Dc, TRANSPARENT
				FillRect Dc, @R, Brush.Handle
				SetBKColor Dc, OPAQUE
				ReleaseDC Handle, DC
				Message.Result = 0
				Exit Sub
			Case WM_LBUTTONDOWN
			down1 = 1
				If (GetCursorPos(@g_OrigCursorPos)) Then
					SetCapture(Handle)
				End If
				Dim As ..Rect R
				Dim As ..Point P
				GetClientRect GetParent(Handle), @R
				..ClientToScreen GetParent(Handle), @P
				R.Left = P.X
				R.Top = P.Y
				R.Right = R.Right + P.X
				R.Bottom = R.Bottom + P.Y
				Select Case This.Align
				Case 1, 2
					R.Left = R.Left + ScaleX(This.MinExtra)
					R.Right = R.Right - ScaleX(This.MinExtra)
				Case 3, 4
					R.Top = R.Top + ScaleX(This.MinExtra)
					R.Bottom = R.Bottom - ScaleX(This.MinExtra)
				End Select
				ClipCursor @R
				xOrig = g_OrigCursorPos.x
				yOrig = g_OrigCursorPos.y
			'SetCapture Handle 'Parent->Handle
			'            x1 = loword(message.lparam)
			'            y1 = hiword(message.lparam)
			'            Select Case Align
			'            Case 1, 2
			'                  DrawTrackSplit(x1, FTop)
			'            Case 3, 4
			'                  DrawTrackSplit(FLeft, y1)
			'            End Select
			'            Down = 1
			Case WM_MOUSEMOVE
			'        int wnd_x = g_OrigWndPos.x +
			If down1 = 1 Then
				i = This.Parent->IndexOf(@This)
					If (GetCursorPos(@g_CurCursorPos)) Then
						xCur = g_CurCursorPos.x
						yCur = g_CurCursorPos.y
					If This.Parent->ControlCount Then
						This.Parent->UpdateLock
						Select Case Align
						Case SplitterAlignmentConstants.alLeft
							If i > 0 Then This.Parent->Controls[i - 1]->Width = This.Parent->Controls[i - 1]->Width - UnScaleX(xOrig) + UnScaleX(xCur)
						Case SplitterAlignmentConstants.alRight
							If i > 0 Then This.Parent->Controls[i - 1]->Width = This.Parent->Controls[i - 1]->Width + UnScaleX(xOrig) - UnScaleX(xCur)
						Case SplitterAlignmentConstants.alTop
							If i > 0 Then This.Parent->Controls[i - 1]->Height = This.Parent->Controls[i - 1]->Height - UnScaleY(yOrig) + UnScaleY(yCur)
						Case SplitterAlignmentConstants.alBottom
							If i > 0 Then This.Parent->Controls[i - 1]->Height = This.Parent->Controls[i - 1]->Height + UnScaleY(yOrig) - UnScaleY(yCur)
						End Select
						xOrig = xCur
						yOrig = yCur
						If OnMoving Then OnMoving(*Designer, This)
						This.Parent->RequestAlign
						This.Parent->UpdateUnLock
						This.Parent->Repaint
						'This.Parent->Update
						'Parent->Update
					End If
					End If
			End If
			'             x = loword(message.lparam)
			'             y = hiword(message.lparam)
			'             if down then
			'                select case Align
			'                case 1,2
			'                    DrawTrackSplit(x,FTop)
			'                    DrawTrackSplit(x1,FTop)
			'                case 3,4
			'                    DrawTrackSplit(FLeft,y)
			'                    DrawTrackSplit(FLeft,y1)
			'                end select
			'             end if
			'             x1 = loword(Message.lParam)
			'             y1 = hiword(Message.lParam)
			Case WM_LBUTTONUP
			down1 = 0
				ClipCursor 0
				releaseCapture
			'            dim as integer i
			'            if Down then
			'                select case Align
			'                case 1,2
			'                     DrawTrackSplit(x1,FTop)
			'                case 3,4
			'                     DrawTrackSplit(FLeft,y1)
			'                end select
			'                down = 0
			'                x = loword(Message.lParam)
			'                y = hiword(Message.lParam)
			'                i = Parent->IndexOf(Control)
			'                ReleaseCapture
			'                Parent->ChildProc = FOldParentProc
			'                Message.Captured  = 0
			'                If Parent->ControlCount Then
			'                   If Align = 1 Then
			'                       This.Left = x - This.Left
			'                       If i > 0 Then Parent->Controls[i-1]->Width = Parent->Controls[i-1]->Width + This.Left
			'                   ElseIf Align = 2 Then
			'                       This.Left = This.Left - x
			'                       If i > 0 Then Parent->Controls[i-1]->Width = Parent->Controls[i-1]->Width + This.Left
			'                   ElseIf Align = 3 Then
			'                       Top = y - Top
			'                       If i > 0 Then Parent->Controls[i-1]->Height = Parent->Controls[i-1]->Height + Top
			'                   ElseIf Align = 4 Then
			'                       Top = Top - y
			'                       If i > 0 Then Parent->Controls[i-1]->Height = Parent->Controls[i-1]->Height + Top
			'                   End If
			'                   Parent->RequestAlign
			'                   if onMoved then onMoved(This)
			'                End If
			'            End If
			'            ReleaseCapture
			'            x = Message.lParamLo
			'            y = Message.lParamHi
			'            i = Parent->IndexOf(This)
			'            Parent->ChildProc = FOldParentProc
			'            Message.Captured  = NULL
			'            If Parent->ControlCount Then
			'               If Align = 1 Then
			'                   This.Left = x - This.Left
			'                   If i > 0 Then Parent->Controls[i-1]->Width = Parent->Controls[i-1]->Width + This.Left
			'               ElseIf Align = 2 Then
			'                   'This.Left = This.Left - x
			'                    ?x1 - x, x1, x
			'                   If i > 0 Then Parent->Controls[i-1]->Width = Parent->Controls[i-1]->Width + x1 - x 'This.Left
			'               ElseIf Align = 3 Then
			'                   Top = y - Top
			'                   If i > 0 Then Parent->Controls[i-1]->Height = Parent->Controls[i-1]->Height + Top
			'               ElseIf Align = 4 Then
			'                   Top = Top - y
			'                   If i > 0 Then Parent->Controls[i-1]->Height = Parent->Controls[i-1]->Height + Top
			'               End If
			'               Parent->RequestAlign
			'            End If
			If OnMoved Then OnMoved(*Designer, This)
		End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator Splitter.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	
	Private Constructor Splitter
		With This
			.Child     = @This
				.RegisterClass "Splitter"
				.ChildProc = @WndProc
				.Style     = WS_CHILD
				.BackColor     = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
				'.DoubleBuffered = True
			WLet(FClassName, "Splitter")
			WLet(FClassAncestor, "")
			.Width     = 3
			.Align     = SplitterAlignmentConstants.alLeft
		End With
	End Constructor
	
	Private Destructor Splitter
			UnregisterClass "Splitter", GetModuleHandle(NULL)
	End Destructor
End Namespace

