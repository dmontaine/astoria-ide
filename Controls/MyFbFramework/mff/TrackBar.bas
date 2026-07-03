'###############################################################################
'#  TrackBar.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TTrackBar.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "TrackBar.bi"

Namespace My.Sys.Forms
		Private Function TrackBar.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "frequency": Return @FFrequency
			Case "maxvalue": Return @FMaxValue
			Case "minvalue": Return @FMinValue
			Case "linesize": Return @FLineSize
			Case "pagesize": Return @FPageSize
			Case "position": Return @FPosition
			Case "selstart": Return @FSelStart
			Case "selend": Return @FSelEnd
			Case "slidervisible": Return @FSliderVisible
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case "tickmark": Return @FTickMark
			Case "tickstyle": Return @FTickStyle
			Case "thumblength": Return @FThumbLength
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function TrackBar.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "frequency": This.Frequency = QInteger(Value)
				Case "maxvalue": MaxValue = QInteger(Value)
				Case "minvalue": MinValue = QInteger(Value)
				Case "linesize": LineSize = QInteger(Value)
				Case "pagesize": PageSize = QInteger(Value)
				Case "position": Position = QInteger(Value)
				Case "selstart": SelStart = QInteger(Value)
				Case "selend": SelEnd = QInteger(Value)
				Case "slidervisible": SliderVisible = QBoolean(Value)
				Case "style": This.Style = *Cast(TrackBarOrientation Ptr, Value)
				Case "tabindex": This.TabIndex = QInteger(Value)
				Case "tickmark": This.TickMark = *Cast(TickMarks Ptr, Value)
				Case "tickstyle": This.TickStyle = *Cast(TickStyles Ptr, Value)
				Case "thumblength": ThumbLength = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property TrackBar.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TrackBar.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TrackBar.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TrackBar.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub TrackBar.SetRanges(APosition As Integer, AMin As Integer, AMax As Integer)
		If AMax < AMin Then Exit Sub
		If APosition < AMin Then APosition = AMin
		If APosition > AMax Then APosition = AMax
		If FMinValue <> AMin Then
			FMinValue = AMin
				If Handle Then Perform(TBM_SETRANGEMIN, 1, AMin)
		End If
		If FMaxValue <> AMax Then
			FMaxValue = AMax
				If Handle Then Perform(TBM_SETRANGEMAX, 1, AMax)
		End If
		If FPosition <> APosition Then
			FPosition = APosition
				If Handle Then Perform(TBM_SETPOS, 1, APosition)
			If OnChange Then OnChange(*Designer, This, Position)
		End If
	End Sub
	
	Private Property TrackBar.MinValue As Integer
		Return FMinValue
	End Property
	
	Private Property TrackBar.MinValue(Value As Integer)
		FMinValue = Value
			If Handle Then Perform(TBM_SETRANGEMIN, 1, Value)
		'SetRanges(FPosition, Value, FMaxValue)
	End Property
	
	Private Property TrackBar.MaxValue As Integer
		Return FMaxValue
	End Property
	
	Private Property TrackBar.MaxValue(Value As Integer)
		FMaxValue = Value
			If Handle Then Perform(TBM_SETRANGEMAX, 1, Value)
		'SetRanges(FPosition, FMinValue, Value)
	End Property
	
	Private Property TrackBar.Position As Integer
			If Handle Then FPosition = Perform(TBM_GETPOS, 0, 0)
		Return FPosition
	End Property
	
	Private Property TrackBar.Position(Value As Integer)
		FPosition = Value
			If Handle Then Perform(TBM_SETPOS, True, FPosition)
		If OnChange Then OnChange(*Designer, This, FPosition)
		'SetRanges(Value, FMinValue, FMaxValue)
	End Property
	
	Private Property TrackBar.LineSize  As Integer
		Return FLineSize
	End Property
	
	Private Property TrackBar.LineSize(Value As Integer)
		If Value <> FLineSize Then
			FLineSize = Value
				If Handle Then Perform(TBM_SETLINESIZE, 0, FLineSize)
		End If
	End Property
	
	Private Property TrackBar.PageSize  As Integer
		Return FPageSize
	End Property
	
	Private Property TrackBar.PageSize(Value As Integer)
		If Value <> FPageSize Then
			FPageSize = Value
				If Handle Then Perform(TBM_SETPAGESIZE, 0, FPageSize)
		End If
	End Property
	
	Private Property TrackBar.ThumbLength  As Integer
		Return FThumbLength
	End Property
	
	Private Property TrackBar.ThumbLength(Value As Integer)
		If Value <> FThumbLength Then
			FThumbLength = Value
				If Handle Then Perform(TBM_SETTHUMBLENGTH, Value, 0)
		End If
	End Property
	
	Private Property TrackBar.Frequency As Integer
		Return FFrequency
	End Property
	
	Private Property TrackBar.Frequency(Value As Integer)
		If Value <> FFrequency Then
			FFrequency = Value
				If Handle Then Perform(TBM_SETTICFREQ, FFrequency, 1)
		End If
	End Property
	
	Private Property TrackBar.SliderVisible As Boolean
		Return FSliderVisible
	End Property
	
	Private Property TrackBar.SliderVisible(Value As Boolean)
		If Value <> FSliderVisible Then
			FSliderVisible = Value
				Base.Style = WS_CHILD Or TBS_FIXEDLENGTH Or TBS_ENABLESELRANGE Or AStyle(Abs_(FStyle)) Or ATickStyles(Abs_(FTickStyle)) Or ATickMarks(Abs_(FTickMark)) Or ASliderVisible(Abs_(FSliderVisible))
		End If
	End Property
	
	Private Property TrackBar.SelStart As Integer
		Return FSelStart
	End Property
	
	Private Property TrackBar.SelStart(Value As Integer)
		If Value <> FSelStart Then
			FSelStart = Value
				If Handle Then
					If (FSelStart = 0) And (FSelEnd = 0) Then
						Perform(TBM_CLEARSEL, 1, 0)
					Else
						Perform(TBM_SETSEL, 1, MakeLong(FSelStart, FSelEnd))
					End If
				End If
		End If
	End Property
	
	Private Property TrackBar.SelEnd As Integer
		Return FSelEnd
	End Property
	
	Private Property TrackBar.SelEnd(Value As Integer)
		If Value <> SelEnd Then
			FSelEnd = Value
				If Handle Then
					If (FSelStart = 0) And (FSelEnd = 0) Then
						Perform(TBM_CLEARSEL, 1, 0)
					Else
						Perform(TBM_SETSEL, 1, MakeLong(FSelStart, FSelEnd))
					End If
				End If
		End If
	End Property
	
	Private Sub TrackBar.AddTickMark(Value As Integer)
			If Handle Then Perform(TBM_SETTIC, 0, Value)
	End Sub
	
	
	Private Sub TrackBar.ClearTickMarks
			If Handle Then Perform(TBM_CLEARTICS, True, 0)
	End Sub
	
	Private Property TrackBar.TickMark As TickMarks
		Return FTickMark
	End Property
	
	Private Property TrackBar.TickMark(Value As TickMarks)
		FTickMark = Value
			Base.Style = WS_CHILD Or TBS_FIXEDLENGTH Or TBS_ENABLESELRANGE Or AStyle(Abs_(FStyle)) Or ATickStyles(Abs_(FTickStyle)) Or ATickMarks(Abs_(FTickMark)) Or ASliderVisible(Abs_(FSliderVisible))
			RecreateWnd
	End Property
	
	Private Property TrackBar.TickStyle As TickStyles
		Return FTickStyle
	End Property
	
	Private Property TrackBar.TickStyle(Value As TickStyles)
		FTickStyle = Value
			Base.Style = WS_CHILD Or TBS_FIXEDLENGTH Or TBS_ENABLESELRANGE Or AStyle(abs_(FStyle)) Or ATickStyles(abs_(FTickStyle)) Or ATickMarks(abs_(FTickMark)) Or ASliderVisible(abs_(FSliderVisible))
			RecreateWnd
	End Property
	
	Private Property TrackBar.Style As TrackBarOrientation
		Return FStyle
	End Property
	
	Private Property TrackBar.Style(Value As TrackBarOrientation)
		Dim As Integer OldStyle
		Dim As Integer iWidth, iHeight
		OldStyle = FStyle
		If FStyle <> Value Then
			FStyle = Value
			If OldStyle = 0 Then
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
				Base.Style = WS_CHILD Or TBS_FIXEDLENGTH Or TBS_ENABLESELRANGE Or AStyle(abs_(FStyle)) Or ATickStyles(abs_(FTickStyle)) Or ATickMarks(abs_(FTickMark)) Or ASliderVisible(abs_(FSliderVisible))
				RecreateWnd
		End If
	End Property
	
		Private Sub TrackBar.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QTrackBar(Sender.Child)
					If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso .FDefaultBackColor = .FBackColor Then
						SetWindowTheme(.FHandle, "DarkMode_Explorer", nullptr)
						'SetWindowTheme(.FHandle, "DarkMode_InfoPaneToolbar", nullptr)
						'SetWindowTheme(.FHandle, "", "")
'						SendMessage(.FHandle, PBM_SETBKCOLOR, 0, Cast(LPARAM, darkHlBkColor))
'						SendMessage(.FHandle, PBM_SETBARCOLOR, 0, Cast(LPARAM, BGR(6, 176, 37)))
						.Brush.Handle = hbrBkgnd
						SendMessageW(.FHandle, WM_THEMECHANGED, 0, 0)
						AllowDarkModeForWindow(.FHandle, g_darkModeEnabled)
						'UpdateWindow(.FHandle)
					End If
					.Perform(TBM_SETTHUMBLENGTH, .FThumbLength, 0)
					.Perform(TBM_SETLINESIZE, 0, .FLineSize)
					.Perform(TBM_SETPAGESIZE, 0, .FPageSize)
					.Perform(TBM_SETRANGEMIN, 0, .FMinValue)
					.Perform(TBM_SETRANGEMAX, 0, .FMaxValue)
					If (.FSelStart = 0) And (.FSelEnd = 0) Then
						.Perform(TBM_CLEARSEL, 1, 0)
					Else
						.Perform(TBM_SETSEL, 1, MAKELONG(.FSelStart, .FSelEnd))
					End If
					.Perform(TBM_SETPOS, 1, .FPosition)
					.Perform(TBM_SETTICFREQ, .FFrequency, 1)
				End With
			End If
		End Sub
		
		Private Sub TrackBar.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub TrackBar.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_HSCROLL
				FPosition = Perform(TBM_GETPOS, 0, 0)
				If OnChange Then OnChange(*Designer, This, Position)
			Case CM_VSCROLL
				FPosition = Perform(TBM_GETPOS, 0, 0)
				If OnChange Then OnChange(*Designer, This, Position)
			
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator TrackBar.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	
	Private Constructor TrackBar
		Dim As Boolean Result
			Dim As INITCOMMONCONTROLSEX ICC
			ICC.dwSize = SizeOf(ICC)
			ICC.dwICC  = ICC_BAR_CLASSES
			Result = InitCommonControlsEx(@ICC)
			If Not Result Then InitCommonControls
			AStyle(0)         = TBS_HORZ
			AStyle(1)         = TBS_VERT
			ATickStyles(0)    = TBS_NOTICKS
			ATickStyles(1)    = TBS_AUTOTICKS
			ATickStyles(2)    = 0
			ATickMarks(0)     = TBS_BOTTOM
			ATickMarks(1)     = TBS_TOP
			ATickMarks(2)     = TBS_BOTH
			ASliderVisible(0) = TBS_NOTHUMB
			ASliderVisible(1) = 0
		MaxValue         = 10
		MinValue         = 0
		Frequency        = 1
		SliderVisible    = 1
		LineSize         = 1
		PageSize         = 2
		Frequency        = 1
		ThumbLength      = 20
		TickMark         = tmBottomRight
		TickStyle        = tsAuto
		FTabIndex        = -1
		FTabStop         = True
		With This
			.Child       = @This
				.RegisterClass "TrackBar", TRACKBAR_CLASS
				.ChildProc         = @WndProc
				.ExStyle           = 0
				Base.Style         = WS_CHILD Or TBS_FIXEDLENGTH Or TBS_ENABLESELRANGE Or AStyle(Abs_(FStyle)) Or ATickStyles(Abs_(FTickStyle)) Or ATickMarks(Abs_(FTickMark)) Or ASliderVisible(Abs_(FSliderVisible))
				.BackColor         = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor  = .BackColor
				WLet(FClassAncestor, TRACKBAR_CLASS)
				.OnHandleIsAllocated = @HandleIsAllocated
			WLet(FClassName, "TrackBar")
			.Width             = 150
			.Height            = 45
		End With
	End Constructor
	
	Private Destructor TrackBar
	End Destructor
End Namespace

