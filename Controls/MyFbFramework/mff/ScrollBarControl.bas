'###############################################################################
'#  ScrollBarControl.bi                                                        #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TScrollBar.bi                                                             #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "ScrollBarControl.bi"

Namespace My.Sys.Forms
		Private Function ScrollBarControl.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "arrowchangesize": Return @This.FArrowChangeSize
			Case "maxvalue": Return @This.FMax
			Case "minvalue": Return @This.FMin
			Case "pagesize": Return @This.FPageSize
			Case "position": Return @This.FPosition
			Case "style": Return @This.FStyle
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function ScrollBarControl.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "arrowchangesize": This.ArrowChangeSize = QInteger(Value)
			Case "maxvalue": This.MaxValue = QInteger(Value)
			Case "minvalue": This.MinValue = QInteger(Value)
			Case "pagesize": This.PageSize = QInteger(Value)
			Case "position": This.Position = QInteger(Value)
			Case "style": This.Style = *Cast(ScrollBarControlStyle Ptr, Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property ScrollBarControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property ScrollBarControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property ScrollBarControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property ScrollBarControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property ScrollBarControl.Style As ScrollBarControlStyle
		Return FStyle
	End Property
	
	Private Property ScrollBarControl.Style(Value As ScrollBarControlStyle)
		Dim As ScrollBarControlStyle OldStyle
		Dim As Integer iWidth, iHeight
		OldStyle = FStyle
		If Value <> FStyle Then
			If OldStyle = sbHorizontal Then
				iHeight = Height
				iWidth = This.Width
				Height = iWidth
				This.Width  = iHeight
			Else
				iWidth = This.Width
				iHeight = Height
				This.Width = iHeight
				Height  = iWidth
			End If
			FStyle = Value
				Base.Style = WS_CHILD Or AStyle(abs_(FStyle))
			If This.Parent Then This.Parent->RequestAlign
		End If
	End Property
	
	Private Property ScrollBarControl.MinValue As Integer
		Return FMin
	End Property
	
	Private Property ScrollBarControl.MinValue(Value As Integer)
		FMin = Value
			If Handle Then Perform(SBM_SETRANGE, FMin, FMax)
	End Property
	
	Private Property ScrollBarControl.MaxValue As Integer
		Return FMax
	End Property
	
	Private Property ScrollBarControl.MaxValue(Value As Integer)
		FMax = Value
			If Handle Then Perform(SBM_SETRANGE, FMin, FMax)
	End Property
	
	Private Property ScrollBarControl.Position As Integer
			If Handle Then FPosition = Perform(SBM_GETPOS, 0, 0)
		Return FPosition
	End Property
	
	Private Property ScrollBarControl.Position(Value As Integer)
		FPosition = Value
			If Handle Then Perform(SBM_SETPOS, FPosition, True)
		If OnScroll Then OnScroll(*Designer, This, FPosition)
	End Property
	
	Private Property ScrollBarControl.ArrowChangeSize As Integer
		Return FArrowChangeSize
	End Property
	
	Private Property ScrollBarControl.ArrowChangeSize(Value As Integer)
		FArrowChangeSize = Value
	End Property
	
	Private Property ScrollBarControl.PageSize As Integer
		Return FPageSize
	End Property
	
	Private Property ScrollBarControl.PageSize(Value As Integer)
		If FPageSize > FMax Or Value = FPageSize Then Exit Property
		FPageSize = Value
			SIF.fMask = SIF_PAGE
			SIF.nPage = FPageSize
			If Handle Then Perform(SBM_SETSCROLLINFO, True, CInt(@SIF))
	End Property
	
		Private Sub ScrollBarControl.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QScrollBarControl(Sender.Child)
					.MinValue = .MinValue
					.MaxValue = .MaxValue
					.Position = .FPosition
					.PageSize = .PageSize
				End With
			End If
		End Sub
		
		Private Sub ScrollBarControl.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub ScrollBarControl.ProcessMessage(ByRef Message As Message)
			Static As Integer OldPos
			Select Case Message.Msg
			Case WM_PAINT
				'			#IF DEFINED(APPLICATION)
				'			If UCase(Application.OSVersion) = "WINDOWS XP" Then
				'			   Hint = This.Hint 'XP ?!
				'			End If
				'			#ENDIF
				Message.Result = 0
			Case CM_CREATE
				SIF.cbSize = SizeOf(SIF)
				SIF.fMask  = SIF_RANGE Or SIF_PAGE
				SIF.nMin   = FMin
				SIF.nMax   = FMax
				SIF.nPage  = FPageSize
				SetScrollInfo(FHandle, SB_CTL, @SIF, True)
			Case CM_HSCROLL, CM_VSCROLL
				Var lo = LoWord(Message.wParam)
				SIF.cbSize = SizeOf(SIF)
				SIF.fMask  = SIF_ALL
				GetScrollInfo (FHandle, SB_CTL, @SIF)
				OldPos = SIF.nPos
				Select Case lo
				Case SB_TOP, SB_LEFT
					SIF.nPos = SIF.nMin
				Case SB_BOTTOM, SB_RIGHT
					SIF.nPos = SIF.nMax
				Case SB_LINEUP, SB_LINELEFT
					SIF.nPos -= FArrowChangeSize
				Case SB_LINEDOWN, SB_LINERIGHT
					SIF.nPos += FArrowChangeSize
				Case SB_PAGEUP, SB_PAGELEFT
					SIF.nPos -= SIF.nPage
				Case SB_PAGEDOWN, SB_PAGERIGHT
					SIF.nPos += SIF.nPage
				Case SB_THUMBPOSITION, SB_THUMBTRACK
					SIF.nPos = SIF.nTrackPos
				End Select
				SIF.fMask = SIF_POS
				SetScrollInfo(FHandle, SB_CTL, @SIF, True)
				GetScrollInfo(FHandle, SB_CTL, @SIF)
				If (Not SIF.nPos = OldPos) Then
					If OnScroll Then
						OnScroll(*Designer, This, Cast(Integer, SIF.nPos))
					End If
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator ScrollBarControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	
	Private Constructor ScrollBarControl
			SIF.cbSize = SizeOf(SCROLLINFO)
		MaxValue        = 100
		MinValue        = 0
		Position        = 0
		ArrowChangeSize = 1
		PageSize        = 3
			AStyle(0)   = SB_HORZ
			AStyle(1)   = SB_VERT
		FTabIndex       = -1
		With This
			.Child      = @This
				.RegisterClass "ScrollBarControl", "ScrollBar"
				.ChildProc   = @WndProc
				.ExStyle     = 0
				Base.Style       = WS_CHILD Or AStyle(Abs_(FStyle))
				.OnHandleIsAllocated = @HandleIsAllocated
				.DoubleBuffered = True
			WLet(FClassName, "ScrollBarControl")
			WLet(FClassAncestor, "ScrollBar")
			.Width      = 121
			.Height     = 17
		End With
	End Constructor
	
	Private Destructor ScrollBarControl
	End Destructor
End Namespace

