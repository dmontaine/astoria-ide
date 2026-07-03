'###############################################################################
'#  ProgressBar.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TProgressBar.bi                                                           #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "ProgressBar.bi"

Namespace My.Sys.Forms
		Private Function ProgressBar.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "marquee": Return @FMarquee
			Case "maxvalue": Return @FMaxValue
			Case "minvalue": Return @FMinValue
			Case "orientation": Return @FOrientation
			Case "position": Return @FPosition
			Case "smooth": Return @FSmooth
			Case "stepvalue": Return @FStep
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function ProgressBar.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "marquee": Marquee = QBoolean(Value)
				Case "maxvalue": MaxValue = QInteger(Value)
				Case "minvalue": MinValue = QInteger(Value)
				Case "orientation": Orientation = *Cast(ProgressBarOrientation Ptr, Value)
				Case "smooth": Smooth = QBoolean(Value)
				Case "stepvalue": StepValue = QInteger(Value)
				Case "position": Position = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Sub ProgressBar.SetRange(AMin As Integer, AMax As Integer)
		If AMax < AMin Then Exit Sub
		If Not CInt(FMode32) And ((AMin < 0) Or (AMin > 85535) Or (AMax < 0) Or (AMax > 85535)) Then Exit Sub
		If (FMinValue <> AMin) Or (FMaxValue <> AMax) Then
				If Handle Then
					If FMode32 Then
						Perform(PBM_SETRANGE32, AMin, AMax)
					Else
						Perform(PBM_SETRANGE, 0, MakeLong(AMin, AMax))
					End If
					If FMinValue > AMin Then Perform(PBM_SETPOS, AMin, 0)
				End If
		End If
		FMinValue = AMin
		FMaxValue = AMax
	End Sub
	

	Private Sub ProgressBar.SetMarquee(MarqueeOn As Boolean, Interval As Integer)
		FMarqueeOn = MarqueeOn
		FMarqueeInterval = Interval
			SendMessage(Handle, PBM_SETMARQUEE, Cast(WPARAM, FMarqueeOn), Cast(LPARAM, FMarqueeInterval))
	End Sub
	
	Private Sub ProgressBar.StopMarquee()
		FMarqueeOn = False
			SendMessage(Handle, PBM_SETMARQUEE, Cast(WPARAM, FMarqueeOn), Cast(LPARAM, FMarqueeInterval))
	End Sub
	
	Private Property ProgressBar.MinValue As Integer
		Return FMinValue
	End Property
	
	Private Property ProgressBar.MinValue(Value As Integer)
		FMinValue = Value
		SetRange(FMinValue,FMaxValue)
	End Property
	
	Private Property ProgressBar.MaxValue As Integer
		Return FMaxValue
	End Property
	
	Private Property ProgressBar.MaxValue(Value As Integer)
		FMaxValue = Value
		SetRange(FMinValue,FMaxValue)
	End Property
	
	Private Property ProgressBar.Position As Integer
			If Handle Then
				If FMode32 Then
					Return Perform(PBM_GETPOS, 0, 0)
				Else
					Return Perform(PBM_DELTAPOS, 0, 0)
				End If
			End If
		Return FPosition
	End Property
	
	Private Property ProgressBar.Position(Value As Integer)
		If Not CInt(FMode32) And ((Value < 0) Or (Value  > 65535)) Then Exit Property
		FPosition = Value
			If Handle Then Perform(PBM_SETPOS, Value, 0)
	End Property
	
	Private Property ProgressBar.StepValue As Integer
		Return FStep
	End Property
	
	Private Property ProgressBar.StepValue(Value As Integer)
		If Value <> FStep Then
			FStep = Value
				If Handle Then Perform(PBM_SETSTEP, FStep, 0)
		End If
	End Property
	
	Private Property ProgressBar.Smooth As Boolean
		Return FSmooth
	End Property
	
	Private Property ProgressBar.Smooth(Value As Boolean)
		If FSmooth <> Value Then
			FSmooth = Value
				Style = WS_CHILD Or AOrientation(Abs_(FOrientation)) Or ASmooth(Abs_(FSmooth)) Or AMarquee(Abs_(FMarquee))
		End If
	End Property
	
	Private Property ProgressBar.Marquee As Boolean
		Return FMarquee
	End Property
	
	Private Property ProgressBar.Marquee(Value As Boolean)
		If FMarquee <> Value Then
			FMarquee = Value
				Style = WS_CHILD Or AOrientation(Abs_(FOrientation)) Or ASmooth(Abs_(FSmooth)) Or AMarquee(Abs_(FMarquee))
		End If
	End Property
	
	Private Property ProgressBar.Orientation As ProgressBarOrientation
		Return FOrientation
	End Property
	
	Private Property ProgressBar.Orientation(Value As ProgressBarOrientation)
		Dim As Integer OldOrientation, iWidth, iHeight
		OldOrientation = FOrientation
		If FOrientation <> Value Then
			FOrientation = Value
			If OldOrientation = 0 Then
				iWidth = This.Width
				iHeight = This.Height
				This.Width = iHeight
				This.Height = iWidth
			Else
				iWidth = This.Width
				iHeight = This.Height
				This.Width = iHeight
				This.Height = iWidth
			End If
				Base.Style = WS_CHILD Or AOrientation(Abs_(FOrientation)) Or ASmooth(Abs_(FSmooth)) Or AMarquee(Abs_(FMarquee))
		End If
	End Property
	
		Private Sub ProgressBar.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With  QProgressBar(Sender.Child)
					If .FMode32 Then
						.Perform(PBM_SETRANGE32, .FMinValue, .FMaxValue)
					Else
						.Perform(PBM_SETRANGE, 0, MakeLong(.FMinValue, .FMaxValue))
					End If
					.Perform(PBM_SETSTEP, .FStep, 0)
					.Position = .FPosition
					If .FMarqueeInterval <> 0 Then .Perform(PBM_SETMARQUEE, Cast(WPARAM, .FMarqueeOn), Cast(LPARAM, .FMarqueeInterval))
				End With
			End If
		End Sub
		
		Private Sub ProgressBar.WndProc(ByRef Message As Message)
		End Sub
	
		Private Sub ProgressBar.SetDark(Value As Boolean)
			Base.SetDark Value
			If Value Then
				'SetWindowTheme(.FHandle, "DarkMode", nullptr)
				'SetWindowTheme(.FHandle, "DarkMode_InfoPaneToolbar", nullptr)
				SetWindowTheme(FHandle, "", "")
				SendMessage(FHandle, PBM_SETBKCOLOR, 0, Cast(LPARAM, darkHlBkColor))
				SendMessage(FHandle, PBM_SETBARCOLOR, 0, Cast(LPARAM, BGR(6, 176, 37)))
				Brush.Handle = hbrBkgnd
				'SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
				'_AllowDarkModeForWindow(FHandle, g_darkModeEnabled)
				'UpdateWindow(.FHandle)
			Else
				FDarkMode = False
				'SetWindowTheme(.FHandle, "DarkMode", nullptr)
				'SetWindowTheme(.FHandle, "DarkMode_InfoPaneToolbar", nullptr)
				SetWindowTheme(FHandle, NULL, NULL)
'				SendMessage(FHandle, PBM_SETBKCOLOR, 0, Cast(LPARAM, darkHlBkColor))
'				SendMessage(FHandle, PBM_SETBARCOLOR, 0, Cast(LPARAM, BGR(6, 176, 37)))
				Brush.Color = FBackColor
				'SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
				'_AllowDarkModeForWindow(FHandle, g_darkModeEnabled)
				'UpdateWindow(.FHandle)
			End If
			'SendMessage FHandle, WM_THEMECHANGED, 0, 0
		End Sub
	
	Private Sub ProgressBar.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
				Case WM_PAINT
					If g_darkModeSupported AndAlso g_darkModeEnabled AndAlso FDefaultBackColor = FBackColor Then
						If Not FDarkMode Then
							SetDark True
	'						FDarkMode = True
	'						'SetWindowTheme(.FHandle, "DarkMode", nullptr)
	'						'SetWindowTheme(.FHandle, "DarkMode_InfoPaneToolbar", nullptr)
	'						SetWindowTheme(FHandle, "", "")
	'						SendMessage(FHandle, PBM_SETBKCOLOR, 0, Cast(LPARAM, darkHlBkColor))
	'						SendMessage(FHandle, PBM_SETBARCOLOR, 0, Cast(LPARAM, BGR(6, 176, 37)))
	'						Brush.Handle = hbrBkgnd
	'						SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
	'						_AllowDarkModeForWindow(FHandle, g_darkModeEnabled)
	'						'UpdateWindow(.FHandle)
						End If
					Else
						If FDarkMode Then
							SetDark False
	'						FDarkMode = False
	'						'SetWindowTheme(.FHandle, "DarkMode", nullptr)
	'						'SetWindowTheme(.FHandle, "DarkMode_InfoPaneToolbar", nullptr)
	'						SetWindowTheme(FHandle, NULL, NULL)
	''						SendMessage(FHandle, PBM_SETBKCOLOR, 0, Cast(LPARAM, darkHlBkColor))
	''						SendMessage(FHandle, PBM_SETBARCOLOR, 0, Cast(LPARAM, BGR(6, 176, 37)))
	'						Brush.Color = FBackColor
	'						SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
	'						_AllowDarkModeForWindow(FHandle, g_darkModeEnabled)
	'						'UpdateWindow(.FHandle)
						End If
					End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Sub ProgressBar.StepIt
			If Handle Then Perform(PBM_STEPIT, 0, 0)
	End Sub
	
	Private Sub ProgressBar.StepBy(Delta As Integer)
			If Handle Then  Perform(PBM_DELTAPOS, Delta, 0)
	End Sub
	
	Private Operator ProgressBar.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ProgressBar
			Dim As INITCOMMONCONTROLSEX ICC
			ICC.dwSize = SizeOf(ICC)
			ICC.dwICC  = ICC_PROGRESS_CLASS
			FMode32 = InitCommonControlsEx(@ICC)
			ASmooth(0) = 0
			ASmooth(1) = PBS_SMOOTH
			AMarquee(0) = 0
			AMarquee(1) = PBS_MARQUEE
			AOrientation(0)  = 0
			AOrientation(1)  = PBS_VERTICAL
		FMinValue  = 0
		FMaxValue  = 100
		FStep      = 10
		FMarquee = False
		With This
			.Child             = @This
				.RegisterClass "ProgressBar", PROGRESS_CLASS
				.ChildProc         = @WndProc
				.ExStyle           = 0
				Base.Style             = WS_CHILD Or AOrientation(Abs_(FOrientation)) Or ASmooth(Abs_(FSmooth)) Or AMarquee(Abs_(FMarquee))
				.OnHandleIsAllocated = @HandleIsAllocated
				WLet(FClassAncestor, PROGRESS_CLASS)
				.Height            = GetSystemMetrics(SM_CYVSCROLL)
				.DoubleBuffered = True
			WLet(FClassName, "ProgressBar")
			.Width             = 150
		End With
	End Constructor
	
	Private Destructor ProgressBar
	End Destructor
End Namespace

