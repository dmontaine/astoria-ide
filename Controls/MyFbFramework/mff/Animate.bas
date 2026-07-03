'###############################################################################
'#  Animate.bas                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Based on:                                                                  #
'#   TAnimate.bas                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#   Updated and added cross-platform code                                     #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                    #
'###############################################################################

#include once "Animate.bi"
Namespace My.Sys.Forms
		Private Function Animate.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autoplay": Return @FAutoPlay
			Case "autosize": Return @FAutoSize
			Case "center": Return @FCenter
			Case "commonavi": Return @FCommonAvi
			Case "file": Return FFile
			Case "repeat": Return @FRepeat
			Case "startframe": Return @FStartFrame
			Case "stopframe": Return @FStopFrame
			Case "timers": Return @FTimers
			Case "ratiofixed": Return @FRatioFixed
			Case "rate": Return @FRate
			Case "transparency": Return @FTransparent
			Case "position": Return @FPosition
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Animate.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "autoplay": AutoPlay = QBoolean(Value)
			Case "autosize": AutoSize = QBoolean(Value)
			Case "center": Center = QBoolean(Value)
			Case "commonavi": CommonAvi = *Cast(CommonAVIs Ptr, Value)
			Case "file": File = QWString(Value)
			Case "repeat": Repeat = QInteger(Value)
			Case "startframe": StartFrame = QLong(Value)
			Case "stopframe": StopFrame = QLong(Value)
			Case "timers": Timers = QBoolean(Value)
			Case "rate": Rate = QDouble(Value)
			Case "transparency": Transparency = QBoolean(Value)
			Case "position": Position = QDouble(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property Animate.Center As Boolean
		Return FCenter
	End Property
	
	Private Property Animate.Center(Value As Boolean)
		If FCenter <> Value Then FCenter = Value Else Return
			Base.Style = WS_CHILD Or SS_OWNERDRAW Or ACenter(abs_(FCenter)) Or ATransparent(abs_(FTransparent)) Or ATimer(abs_(FTimers)) Or AAutoPlay(abs_(FAutoPlay))
	End Property
	
	Private Property Animate.Transparency As Boolean
		Return FTransparent
	End Property
	
	Private Property Animate.Transparency(Value As Boolean)
		If FTransparent <> Value Then FTransparent = Value Else Return
			Base.Style = WS_CHILD Or SS_OWNERDRAW Or ACenter(abs_(FCenter)) Or ATransparent(abs_(FTransparent)) Or ATimer(abs_(FTimers)) Or AAutoPlay(abs_(FAutoPlay))
	End Property
	
	Private Property Animate.Timers As Boolean
		Return FTimers
	End Property
	
	Private Property Animate.Timers(Value As Boolean)
		If FTimers <> Value Then FTimers = Value Else Return
			Base.Style = WS_CHILD Or SS_OWNERDRAW Or ACenter(abs_(FCenter)) Or ATransparent(abs_(FTransparent)) Or ATimer(abs_(FTimers)) Or AAutoPlay(abs_(FAutoPlay))
	End Property
	
	Private Property Animate.File ByRef As WString
		If FFile> 0 Then Return *FFile Else Return WStr("")
	End Property
	
	Private Property Animate.File(ByRef Value As WString)
		FFile = _Reallocate(FFile, (Len(Value) + 1) * SizeOf(WString))
		*FFile = Value
			If Handle Then
				SetWindowLongPtr Handle, GWLP_HINSTANCE, CInt(GetModuleHandle(NULL))
			End If
	End Property
	
	Private Property Animate.Repeat As Integer
		Return FRepeat
	End Property
	
	Private Property Animate.Repeat(Value As Integer)
		FRepeat = Value
	End Property
	
	Private Property Animate.AutoPlay As Boolean
		Return FAutoPlay
	End Property
	
	Private Property Animate.AutoPlay(Value As Boolean)
		If FAutoPlay <> Value Then FAutoPlay = Value Else Return
			Base.Style = WS_CHILD Or SS_OWNERDRAW Or ACenter(abs_(FCenter)) Or ATransparent(abs_(FTransparent)) Or ATimer(abs_(FTimers)) Or AAutoPlay(abs_(FAutoPlay))
	End Property
	
	Private Property Animate.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property Animate.AutoSize(Value As Boolean)
		FAutoSize = Value
	End Property
	
	Private Property Animate.CommonAvi As CommonAVIs
		Return FCommonAvi
	End Property
	
	Private Property Animate.CommonAvi(Value As CommonAVIs)
		FCommonAvi = Value
			If Handle Then
				SetWindowLongPtr Handle, GWLP_HINSTANCE, CInt(GetModuleHandle("Shell32"))
			End If
	End Property
	
	Private Property Animate.Volume As Long
		Return FVolume
	End Property
	
	Private Property Animate.Volume(Value As Long)
		If FVolume <> Value Then FVolume = Value Else Return
	End Property
	
	Private Property Animate.Balance As Long
		Return FBalance
	End Property
	
	Private Property Animate.Balance(Value As Long)
		If FBalance <> Value Then FBalance = Value Else Return
		FBalance = Value
	End Property
	
	Private Property Animate.FullScreenMode As Boolean
				Return CBool(FFullScreenMode)
	End Property
	
	Private Property Animate.FullScreenMode(Value As Boolean)
	End Property
	
	Private Property Animate.Rate As Double
		Return FRate
	End Property
	
	Private Property Animate.Rate(Value As Double)
		If FRate <> Value Then FRate = Value Else Return
	End Property
	
	Private Property Animate.Position As Double
			If FOpenMode= 3 Then
			ElseIf FOpenMode= 4 Then
			Else
				If FPlay Then
					FPosition = Timer - FPlayTimeStart - FPlayTimePause
				Else
					FPosition = Timer - FPlayTimeStart - (FPlayTimePause+ (Timer - FPlayTimePauseStart))
				End If
			End If
		Return FPosition
	End Property
	
	Private Property Animate.Position(Value As Double)
		If FPosition <> Value Then FPosition = Value Else Return
			If FOpenMode= 3  Then
			End If
	End Property
	
	Private Property Animate.StartFrame As Long
		Return FStartFrame
	End Property
	
	Private Property Animate.StartFrame(Value As Long)
		FStartFrame = Value
		If FStartFrame < 0 Then FStartFrame = 0
		If FPlay Then This.Stop
		Play
	End Property
	
	Private Property Animate.StopFrame As Long
		Return FStopFrame
	End Property
	
	Private Property Animate.StopFrame(Value As Long)
		FStopFrame = Value
		If FStopFrame > FFrameCount - 1 OrElse FStopFrame< 1 Then FStopFrame = FFrameCount
		If FPlay Then This.Stop
		Play
	End Property
	
	Private Function Animate.FrameCount As Long
		Return FFrameCount
	End Function
	
	Private Function Animate.OpenMode As Integer
		Return FOpenMode
	End Function
	
	Private Sub Animate.SetMoviePosition(ByVal ALeft As Long, ByVal ATop As  Long, ByVal AWidth As Long, ByVal AHeight As Long)
			If FAutoSize Then
				FFrameWidth = ScaleX(AWidth) : FFrameHeight = ScaleY(AHeight)
				If FRatioFixed Then
					If FFrameWidth > FFrameHeight * FRatio Then
						FFrameWidth  = FFrameHeight * FRatio
					Else
						FFrameHeight  = FFrameWidth / FRatio
					End If
				End If
				If FCenter Then
					FFrameLeft = Max((ScaleX(AWidth) - FFrameWidth) / 2, 0) : FFrameTop = Max((ScaleY(AHeight) - FFrameHeight) / 2, 0)
				Else
					FFrameLeft = ScaleX(ALeft)  : FFrameTop = ScaleY(ATop)
				End If
				If FOpenMode= 3 Then
				End If
			Else
				FFrameWidth = FFrameWidthOrig : FFrameHeight = FFrameHeightOrig
				If FCenter Then
					FFrameLeft = Max((ScaleX(AWidth) - FFrameWidth) / 2, 0) : FFrameTop = Max((ScaleY(AHeight) - FFrameHeight) / 2, 0)
				Else
					FFrameLeft = 0 : FFrameTop = 0
				End If
				If FOpenMode= 3 Then
				End If
			End If
	End Sub
	
	Private Property Animate.FrameHeight As Long
		Return FFrameHeight
	End Property
	
	Private Property Animate.FrameHeight(Value As Long)
		FFrameHeight = Value
		This.Height = UnScaleY(Value)
	End Property
	
	Private Property Animate.FrameWidth As Long
		Return FFrameWidth
	End Property
	
	Private Property Animate.FrameWidth(Value As Long)
		FFrameWidth = Value
		This.Width = UnScaleX(Value)
	End Property
	
	Private Function Animate.FrameHeightOriginal As Long
		Return FFrameHeightOrig
	End Function
	
	Private Function Animate.FrameWidthOriginal As Long
		Return FFrameWidthOrig
	End Function
	
	Private Function Animate.Ratio As Double
		Return FRatio
	End Function
	
	Private Property Animate.RatioFixed As Boolean
		Return FRatioFixed
	End Property
	
	Private Property Animate.RatioFixed(Value As Boolean)
		FRatioFixed = Value
	End Property
	
		Private Sub Animate.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QAnimate(Sender.Child)
					SetClassLongPtr(.Handle, GCLP_HBRBACKGROUND, 0)
					If .FOpenMode Then .OpenFile
					If .FPlay Then .Play
				End With
			End If
		End Sub
		
		Private Sub Animate.WNDPROC(ByRef Message As Message)
			If Message.Sender Then
			End If
		End Sub
	
	'https://learn.microsoft.com/en-us/windows/win32/directshow/event-notification-codes.
	Private Sub Animate.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_COMMAND
				Select Case Message.wParamHi
				Case ACN_START
					If OnStart Then OnStart(*Designer, This)
				Case ACN_STOP
					If OnStop Then OnStop(*Designer, This)
				End Select
			Case WM_NCHITTEST
				Message.Result = HTCLIENT
			Case WM_ERASEBKGND, WM_PAINT
				SetMoviePosition(0, 0, This.Width, This.Height)
				If FOpenMode = 4 Then
				End If
			Case WM_NCPAINT
				'Dim As HDC Dc
				'Dc = GetDCEx(Handle, 0, DCX_WINDOW Or DCX_CACHE Or DCX_CLIPSIBLINGS)
				'Future utilisation
				'ReleaseDC Handle,Dc
				
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Function Animate.OpenFile(ByRef FileName As WString = "") As Integer
		FErrorInfo = ""
		FOpenMode = 0: FRate= 1
		If Trim(FileName) <> "" Then WLet(FFile, FileName)
			If Handle Then
				If OnOpen Then OnOpen(*Designer, This)
				If FPlay Then Stop
				If CommonAvi = 0 Then
					If *FFile <> "" Then
						If StartsWith(*FFile, "./") OrElse StartsWith(*FFile, ".\") Then
							WLetEx(FFile, ExePath & Mid(*FFile, 2))
						End If
							If False Then
						ElseIf Perform(ACM_OPENW, 0, CInt(FFile)) <> 0 Then
							FOpenMode= 2
							Dim As Integer Ptr Buff = _Allocate(18*SizeOf(Integer))
							Dim As Integer F = FreeFile_
							Open *FFile For Binary Access Read As #F
							Get #F, , *Buff, 18
							CloseFile_(F)
							FFrameCount  = Buff[12]
							FFrameWidth  = Buff[16]
							FFrameHeight = Buff[17]
							If FFrameCount > 10000 OrElse FFrameCount < 0 Then FFrameCount = 1
							If FFrameHeight > 0 Then FRatio = FFrameWidth / FFrameHeight Else FRatio = 1
							FFrameWidthOrig = FFrameWidth : FFrameHeightOrig = FFrameHeight
							FStopFrame= FFrameCount
							FPlayTimeStart = Timer
							FPlayTimePauseStart = Timer
							FPlayTimePause= 0
							If FAutoPlay Then Play
						Else
								FErrorInfo =  "Can not open the movie file! Or add code -  #define GIFMovieOn"
						End If
					End If
				Else
					If FindResource(GetModuleHandle("Shell32"), MAKEINTRESOURCE(FCommonAvi), "AVI") Then
						*FFile = ""
						If Perform(ACM_OPEN, CInt(GetModuleHandle("Shell32")), CInt(MAKEINTRESOURCE(FCommonAvi))) = 0 Then
							FErrorInfo =  "Can not play the Resource " & FCommonAvi
							Return 0
						Else
							Dim As HRSRC Resource
							Dim As HGLOBAL Global
							Dim As Any Ptr PResource
							Dim As UByte Ptr P
							Dim As Integer Size
							Dim As Integer Ptr Buff = _Allocate(18*SizeOf(Integer))
							Resource  = FindResource(GetModuleHandle("Shell32"),MAKEINTRESOURCE(FCommonAvi),"AVI")
							Global    = LoadResource(GetModuleHandle("Shell32"),Resource)
							PResource = LockResource(Global)
							Size = SizeofResource(GetModuleHandle("Shell32"), Resource)
							P = _Allocate(Size)
							P = PResource
							FreeResource(Resource)
							memcpy Buff, P, 18 * SizeOf(Integer)
							FFrameCount  = 100 'Buff[12]
							FFrameWidth  = Buff[16]
							FFrameHeight = Buff[17]
							If FFrameCount > 7200 OrElse FFrameCount < 0 Then FFrameCount = 100
							FFrameWidthOrig = FFrameWidth : FFrameHeightOrig = FFrameHeight
							If FFrameHeight > 0 Then FRatio = FFrameWidth / FFrameHeight Else FRatio = 1
							FStartFrame= 0 : FStopFrame= IIf(FFrameCount > 0, FFrameCount, 10)
							Print " FFrameCount=" & FFrameCount & " FFrameWidth=" & FFrameWidth & " FFrameHeight=" & FFrameHeight & " FCommonAvi=" & FCommonAvi
							FOpenMode= 1
							FPlayTimeStart = Timer
							FPlayTimePauseStart = Timer
							FPlayTimePause= 0
							If FAutoPlay Then Play
						End If
					Else
						FErrorInfo = "CommonAvi.Open not find the resource"
						Return FOpenMode
					End If
				End If
			End If
		Return FOpenMode
	End Function
	
	Private Function Animate.GetErrorInfo As String
		Return FErrorInfo
	End Function
	
	Private Function Animate.IsPlaying As Boolean
			If FOpenMode= 3 Then
			Else
				Return FPlay
				'Return Perform(ACM_ISPLAYING, 0, 0)
			End If
	End Function
	
	Private Sub Animate.Play
		FErrorInfo = ""
			If Handle Then
				If FPlayTimeStart = 0 Then
					FPlayTimeStart = Timer
				Else
					FPlayTimePause += Timer - FPlayTimePauseStart
				End If
				If OnStart Then OnStart(*Designer, This)
				If FOpenMode= 3 Then
				ElseIf FOpenMode < 3 Then
					Print "FFrameCount=" & FFrameCount & " FStartFrame=" &  FStartFrame & " FStopFrame=" & FStopFrame & " FRepeat=" & FRepeat
					If FStopFrame < 1 Then FStopFrame= FFrameCount
					Perform(ACM_PLAY, FRepeat, MAKELONG(FStartFrame, FStopFrame))
				End If
				FPlay = True
			End If
	End Sub
	
	Private Sub Animate.Stop
		FErrorInfo = ""
			If FOpenMode Then
				FPlayTimeStart = 0
				FPlayTimePause = 0
				If OnStop Then OnStop(*Designer, This)
				If FOpenMode= 4 Then
				ElseIf FOpenMode= 3 Then
				Else
					Perform(ACM_STOP, 0, 0)
					Perform(ACM_OPENW, 0, 0)
				End If
				FCommonAvi = 0
				FOpenMode = 0
				*FFile = ""
				FPlay = False
			End If
	End Sub
	
	Private Sub Animate.Pause
		FErrorInfo = ""
		Rate = 1
			If Handle Then
				FPlayTimePauseStart = Timer
				If OnPause Then OnPause(*Designer, This)
				If FOpenMode= 3 Then
				Else
					Perform(ACM_STOP, 0, 0)
				End If
				FPlay = False
			End If
	End Sub
	Private Sub Animate.Close
		FErrorInfo = ""
			If Handle Then
				FPlayTimeStart = 0
				FPlayTimePause = 0
				If OnClose Then OnClose(*Designer, This)
				If FOpenMode= 4 Then
				ElseIf FOpenMode= 3 Then
				Else
					Perform(ACM_STOP, 0, 0)
					Perform(ACM_OPENW, 0, 0)
				End If
				FOpenMode = 0
				FCommonAvi = 0
				*FFile = ""
				FPlay = False
			End If
	End Sub
	
	Private Operator Animate.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	
	Private Constructor Animate
		Dim As Boolean Result
			Dim As INITCOMMONCONTROLSEX ICC
			FFile = 0 'CAllocate_(0)
			ICC.dwSize = SizeOf(ICC)
			ICC.dwICC  = ICC_ANIMATE_CLASS
			Result = INITCOMMONCONTROLSEX(@ICC)
			If Not Result Then InitCommonControls
			ACenter(0)      = 0
			ACenter(1)      = ACS_CENTER
			ATransparent(0) = 0
			ATransparent(1) = ACS_TRANSPARENT
			ATimer(0)       = 0
			ATimer(1)       = ACS_TIMER
			AAutoPlay(0)    = 0
			AAutoPlay(1)    = ACS_AUTOPLAY
		FRepeat         = -1
		FRate           = 1
		FStopFrame      = -1
		FStartFrame     = 0
		FCenter = True
		FRatioFixed = True
		FTransparent = True
		FAutoSize = True
		FAutoPlay = True
		FTimers = True
		With This
			WLet(FClassName, "Animate")
			.Child             = @This
				.RegisterClass "Animate", ANIMATE_CLASS
				.ChildProc         = @WNDPROC
				WLet(FClassAncestor, ANIMATE_CLASS)
				.ExStyle           = WS_EX_TRANSPARENT
				.Style             = WS_CHILD Or SS_OWNERDRAW Or ACenter(abs_(FCenter)) Or ATransparent(abs_(FTransparent)) Or ATimer(abs_(FTimers)) Or AAutoPlay(abs_(FAutoPlay))
				.BackColor             = GetSysColor(COLOR_BTNFACE)
				.OnHandleIsAllocated = @HandleIsAllocated
				.DoubleBuffered = True
			.Width             = 100
			.Height            = 80
		End With
	End Constructor
	
	Private Destructor Animate
		If FFile Then _Deallocate( FFile)
	End Destructor
End Namespace

