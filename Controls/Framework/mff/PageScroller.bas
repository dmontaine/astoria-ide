'################################################################################
'#  PageScroller.bi                                                             #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                          #
'################################################################################

#include once "PageScroller.bi"

Namespace My.Sys.Forms
		Private Function PageScroller.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "arrowchangesize": Return @FArrowChangeSize
			Case "autoscroll": Return @FAutoScroll
			Case "childdragdrop": Return @FChildDragDrop
			Case "position": Position: Return @FPosition
			Case "style": Return @This.FStyle
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function PageScroller.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "arrowchangesize": This.ArrowChangeSize = QInteger(Value)
				Case "autoscroll": This.AutoScroll = QBoolean(Value)
				Case "childdragdrop": This.ChildDragDrop = QBoolean(Value)
				Case "position": This.Position = QInteger(Value)
				Case "style": This.Style = *Cast(PageScrollerStyle Ptr, Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property PageScroller.ArrowChangeSize As Integer
		Return FArrowChangeSize
	End Property
	
	Private Property PageScroller.ArrowChangeSize(Value As Integer)
		FArrowChangeSize = Value
	End Property
	
	Private Property PageScroller.AutoScroll As Boolean
		Return FAutoScroll
	End Property
	
	Private Property PageScroller.AutoScroll(Value As Boolean)
		FAutoScroll = Value
			ChangeStyle PGS_AUTOSCROLL, Value
	End Property
	
	Private Property PageScroller.ChildDragDrop As Boolean
		Return FChildDragDrop
	End Property
	
	Private Property PageScroller.ChildDragDrop(Value As Boolean)
		FChildDragDrop = Value
			ChangeStyle PGS_DRAGNDROP, Value
	End Property
	
	Private Property PageScroller.Position As Integer
			If FHandle Then
				FPosition = SendMessage(FHandle, PGM_GETPOS, 0, 0)
			End If
		Return FPosition
	End Property
	
	Private Property PageScroller.Position(Value As Integer)
		FPosition = Max(0, Value)
			If FHandle Then
				SendMessage(FHandle, PGM_SETPOS, 0, Cast(LPARAM, FPosition))
			End If
	End Property
	
	Private Property PageScroller.Style As PageScrollerStyle
		Return FStyle
	End Property
	
	Private Property PageScroller.Style(Value As PageScrollerStyle)
		Dim As PageScrollerStyle OldStyle
		Dim As Integer iWidth, iHeight
		OldStyle = FStyle
		If Value <> FStyle Then
				ChangeStyle PGS_HORZ, False
				ChangeStyle PGS_VERT, False
			Select Case Value
			Case psHorizontal
					ChangeStyle PGS_HORZ, True
			Case psVertical
					ChangeStyle PGS_VERT, True
			End Select
			FStyle = Value
		End If
	End Property
	
	Private Property PageScroller.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property PageScroller.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property PageScroller.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property PageScroller.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
		Private Sub PageScroller.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			If Sender.Child Then
				With QPageScroller(Sender.Child)
					If .ChildControl AndAlso .ChildControl->Handle Then SendMessage(.Handle, PGM_SETCHILD, 0, Cast(LPARAM, .ChildControl->Handle))
				End With
			End If
		End Sub
		
		Private Sub PageScroller.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub PageScroller.Add(Ctrl As Control Ptr, Index As Integer = -1)
		If ChildControl = 0 Then
			ChildControl = Ctrl
			Base.Add(Ctrl)
				If FHandle AndAlso Ctrl->Handle Then
					SendMessage(FHandle, PGM_SETCHILD, 0, Cast(LPARAM, Ctrl->Handle))
				End If
		Else
			Print "MFF: Can't add second control to PageScroller"
		End If
	End Sub
	
	Private Sub PageScroller.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_PAINT
				Dim As HDC Dc
				Dim As PAINTSTRUCT Ps
				Dc = BeginPaint(FHandle, @Ps)
				FillRect Dc, @Ps.rcPaint, Brush.Handle
				EndPaint FHandle, @Ps
				Message.Result = 0
				Return
			Case CM_NOTIFY
				Dim As NMHDR Ptr nmhdr_ = Cast(NMHDR Ptr, Message.lParam)
				If nmhdr_->code = PGN_CALCSIZE Then
					Dim As NMPGCALCSIZE Ptr nmcal = Cast(NMPGCALCSIZE Ptr, Message.lParam)
					If nmcal->dwFlag = PGF_CALCWIDTH Then
						nmcal->iWidth = ChildControl->Width
					ElseIf nmcal->dwFlag = PGF_CALCHEIGHT Then
						nmcal->iHeight = ChildControl->Height
					EndIf
				ElseIf nmhdr_->code = PGN_SCROLL Then
					Type NMPGSCROLL2 Field = 1
						As NMHDR hdr
						As Short fwKeys
						As ..Rect rcParent
						As Integer iDir
						As Integer iXpos
						As Integer iYpos
						As Integer iScroll
					End Type
					Dim As NMPGSCROLL2 Ptr nmgs = Cast(NMPGSCROLL2 Ptr, Message.lParam)
					Dim As Integer NewPos = nmgs->iXpos + nmgs->iYpos
					Select Case nmgs->iDir
					Case PGF_SCROLLDOWN
						NewPos = Min(ChildControl->Height, NewPos + FArrowChangeSize)
					Case PGF_SCROLLRIGHT
						NewPos = Min(ChildControl->Width, NewPos + FArrowChangeSize)
					Case PGF_SCROLLUP, PGF_SCROLLLEFT
						NewPos = Max(0, NewPos - FArrowChangeSize)
					End Select
					nmgs->iScroll = FArrowChangeSize
					If OnScroll Then OnScroll(*Designer, This, NewPos)
				EndIf
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator PageScroller.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	
	Private Constructor PageScroller
		With This
			WLet(FClassName, "PageScroller")
			WLet(FClassAncestor, "SysPager")
			FArrowChangeSize = 40
				.RegisterClass "PageScroller", "SysPager"
				Base.Style        = WS_CHILD Or PGS_HORZ
				.ExStyle      = 0
				.ChildProc    = @WndProc
				.OnHandleIsAllocated = @HandleIsAllocated
				.DoubleBuffered = True
			FTabIndex          = -1
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor PageScroller
			UnregisterClass "PageScroller", GetModuleHandle(NULL)
	End Destructor
End Namespace

