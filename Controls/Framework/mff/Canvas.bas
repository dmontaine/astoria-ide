'################################################################################
'#  Canvas.bas                                                                   #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TCanvas.bi                                                                 #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'################################################################################

#include once "Canvas.bi"

Namespace My.Sys.Drawing
		Private Function Canvas.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "pen": Return @Pen
			Case "brush": Return @Brush
			Case "font": Return @Font
			Case "clip": Return @Clip
			Case "copymode": Return @CopyMode
				Case "handle": Return @Handle
			Case "height": iTemp = This.Height: Return @iTemp
			Case "width": iTemp = This.Width: Return @iTemp
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Canvas.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "clip": This.Clip = QBoolean(Value)
			Case "copymode": This.CopyMode = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property Canvas.BackColor As Integer
		Return FBackColor
	End Property
	
	Private Property Canvas.BackColor(Value As Integer)
		FBackColor = Value
		FillColor = FBackColor
	End Property
	
	Private Property Canvas.FillColor As Integer
		Return FFillColor
	End Property
	
	Private Property Canvas.FillColor(Value As Integer)
		If FFillColor <> Value Then
			FFillColor = Value
				If FFillColor = -1 Then FFillColor = FBackColor
				SetBkColor Handle, FFillColor
				Brush.Color = FFillColor
				If UsingGdip Then
					If GdipBrush Then GdipDeleteBrush(GdipBrush)
					GdipCreateSolidFill(RGBtoARGB(FFillColor, FillOpacity), Cast(GpSolidFill Ptr Ptr, @GdipBrush))
				End If
		End If
	End Property
	
	Private Property Canvas.FillMode As BrushFillMode
		Return FFillMode
	End Property
	
	Private Property Canvas.FillMode(Value As BrushFillMode)
		If FFillMode <> Value Then
			FFillMode = Value
				SetBkMode Handle, FFillMode
		End If
	End Property
	
	Private Property Canvas.HatchStyle As HatchStyles
		Return FHatchStyle
	End Property
	
	Private Property Canvas.HatchStyle(Value As HatchStyles)
		If FHatchStyle <> Value Then
			FHatchStyle = Value
				Brush.HatchStyle = Value
				If UsingGdip Then
					If GdipBrush Then GdipDeleteBrush(GdipBrush)
					GdipCreateHatchBrush(GdipHatchStyles, RGBtoARGB(FFillColor, FillOpacity), RGBtoARGB(FDrawColor, FillOpacity), Cast(GpHatch Ptr Ptr, @GdipBrush))
				End If
		End If
	End Property
	
	Private Property Canvas.FillStyles As BrushStyles
		Return FFillStyles
	End Property
	
	Private Property Canvas.FillStyles(Value As BrushStyles)
		'https://learn.microsoft.com/zh-cn/windows/win32/gdiplus/-gdiplus-brushes-and-filled-shapes-about
		'If FFillStyles <> Value Then
		FFillStyles = Value
			Brush.Style= Value
			If UsingGdip Then
				If GdipBrush Then GdipDeleteBrush(GdipBrush)
				Select Case FFillStyles
				Case BrushStyles.bsHatch
					GdipCreateHatchBrush(GdipHatchStyles, RGBtoARGB(FFillColor, FillOpacity), RGBtoARGB(FDrawColor, FillOpacity), Cast(GpHatch Ptr Ptr, @GdipBrush))
				Case BrushStyles.bsPattern
					GdipCreateLineBrush(@GpLineGradientPara.PointFrom, @GpLineGradientPara.PointTo, RGBtoARGB(GpLineGradientPara.ColorStart, FillOpacity), RGBtoARGB(GpLineGradientPara.ColorEnd, FillOpacity),  GpLineGradientPara.WrapModes, Cast(GpLineGradient Ptr Ptr, @GdipBrush))
					Print "GdipBrush=" & GdipBrush
					'Case BrushStyles.bsClear
					'	'ElseIf Value = BrushStyles.bsHatch Then
					'	'GdipCreateHatchBrush(HatchStyle.
				Case Else
					GdipCreateSolidFill(RGBtoARGB(FFillColor, FillOpacity), Cast(GpSolidFill Ptr Ptr, @GdipBrush))
				End Select
			End If
		'End If
	End Property
	
	Private Property Canvas.Width As Integer
		If ParentControl Then
			Return ParentControl->Width
		Else
				Scope
					Dim As BITMAP header
					ZeroMemory(@header, SizeOf(BITMAP))
					
					Dim As HGDIOBJ bmp = GetCurrentObject(Handle, OBJ_BITMAP)
					GetObject(bmp, SizeOf(BITMAP), @header)
					Dim As Integer iWidth = header.bmWidth
					If iWidth > 1 Then
						Return iWidth
					End If
				End Scope
				Return GetDeviceCaps(Handle, LOGPIXELSX)
		End If
	End Property
	
	Private Property Canvas.Height As Integer
		If ParentControl Then
			Return ParentControl->Height
		Else
				Scope
					Dim As BITMAP header
					ZeroMemory(@header, SizeOf(BITMAP))
					
					Dim As HGDIOBJ bmp = GetCurrentObject(Handle, OBJ_BITMAP)
					GetObject(bmp, SizeOf(BITMAP), @header)
					Dim As Integer iHeight = header.bmHeight
					If iHeight > 1 Then
						Return iHeight
					End If
				End Scope
				Return GetDeviceCaps(Handle, LOGPIXELSY)
		End If
	End Property
	
	Private Property Canvas.ScaleWidth As Integer
		Return FScaleWidth
	End Property
	
	Private Property Canvas.ScaleHeight As Integer
		Return FScaleHeight
	End Property
	
	Private Property Canvas.DrawWidth As Integer
			If UsingGdip Then Return FDrawWidth
		Return Pen.Size
	End Property

	Private Property Canvas.DrawWidth(Value As Integer)
			If FDrawWidth <> Value Then
				FDrawWidth = Value
				Pen.Size = Value
				If UsingGdip Then
					If GdipPen Then GdipDeletePen(GdipPen)
					GdipCreatePen1(RGBtoARGB(Pen.Color, BackColorOpacity), FDrawWidth, &H2, @GdipPen)
					GdipSetPenEndCap GdipPen, 2
				End If
			End If
	End Property

	Private Property Canvas.DrawColor As Integer
			If UsingGdip Then Return FDrawColor
		Return Pen.Color
	End Property

	Private Property Canvas.DrawColor(Value As Integer)
			If FDrawColor <> Value Then
				FDrawColor = Value
				Pen.Color = Value
				If UsingGdip Then
					If GdipPen Then GdipDeletePen(GdipPen)
					GdipCreatePen1(RGBtoARGB(Pen.Color, BackColorOpacity), FDrawWidth, &H2, @GdipPen)
					GdipSetPenEndCap GdipPen, 2
				Else
					SelectObject(Handle, Pen.Handle)
				End If
			End If
	End Property

	Private Property Canvas.DrawStyle As PenStyle
			If UsingGdip Then Return FDrawStyle
		Return Pen.Style
	End Property
	'https://learn.microsoft.com/zh-cn/windows/win32/api/gdipluspen/nf-gdipluspen-pen-setdashstyle
	Private Property Canvas.DrawStyle(Value As PenStyle)
			If FDrawStyle <> Value Then
				FDrawStyle = Value
				Pen.Style = Value
				If UsingGdip Then
					If GdipPen Then GdipDeletePen(GdipPen)
					GdipCreatePen1(RGBtoARGB(Pen.Color, BackColorOpacity), FDrawWidth, &H2, @GdipPen)
					GdipSetPenEndCap GdipPen, 2
					Dim As GpDashStyle tGpDashStyle
					Select Case Value
					Case PenStyle.psDash
						tGpDashStyle = DashStyleDash
					Case PenStyle.psDot
						tGpDashStyle = DashStyleDot
					Case PenStyle.psDashDot
						tGpDashStyle = DashStyleDashDot
					Case PenStyle.psDashDotDot
						tGpDashStyle = DashStyleDashDotDot
					Case Else
						tGpDashStyle = DashStyleSolid
					End Select
					GdipSetPenDashStyle(GdipPen, tGpDashStyle)
				End If
			End If
	End Property
	
	Private Sub Canvas.Cls(x As Double = 0, y As Double = 0, x1 As Double = 0, y1 As Double = 0)
		Dim As Any Ptr Handle_
		Dim As Boolean AcquiredDevice = Not HandleSetted
		If AcquiredDevice Then Handle_ = GetDevice
		If ParentControl > 0 Then
				If UsingGdip Then
					GdipGraphicsClear(GdipGraphics, &h00000000)
					'Return
				End If
				Dim As HBRUSH B = CreateSolidBrush(FBackColor)
			Dim As Rect R
			If x = x1 AndAlso y = y1 AndAlso x = y Then
				R.Left = 0
				R.Top = 0
				R.Right = ScaleX(ParentControl->Width)
				R.Bottom = ScaleY(ParentControl->Height)
				'Remove Scale
				imgScaleX = 1
				imgScaleY = 1
				imgOffsetX = 0
				imgOffsetY = 0
				FDrawWidth = 1
				FScaleWidth = ScaleX(This.Width)
				FScaleHeight =  ScaleY(This.Height)
					.FillRect Handle, Cast(..Rect Ptr, @R), B
			Else
				R.Left = ScaleX(x) * imgScaleX + imgOffsetX
				R.Top = ScaleY(y) * imgScaleY + imgOffsetY
				R.Right = ScaleX(x1) * imgScaleX + imgOffsetX
				R.Bottom = ScaleY(y1) * imgScaleY + imgOffsetY
					.FillRect Handle, Cast(..Rect Ptr, @R), B
			End If
				DeleteObject B
		End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	Private Property Canvas.Ctrl As My.Sys.ComponentModel.Component Ptr
		Return ParentControl
	End Property
	
	Private Property Canvas.Ctrl(Value As My.Sys.ComponentModel.Component Ptr)
		ParentControl = Value
		If ParentControl Then
			'			ParentControl->Canvas = @This
			'			If *Ctrl Is My.Sys.Forms.Control Then
			'				Brush.Color = Cast(My.Sys.Forms.Control Ptr, Ctrl)->BackColor
			'			End If
		End If
	End Property
	
	Private Property Canvas.Pixel(xy As Point) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Return .GetPixel(Handle, ScaleX(xy.X), ScaleY(xy.Y))
		If Not HandleSetted Then ReleaseDevice Handle_
	End Property
	
	Private Property Canvas.Pixel(xy As Point, Value As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			.SetPixel(Handle, ScaleX(xy.X) * imgScaleX + imgOffsetX, ScaleY(xy.Y) * imgScaleY + imgOffsetY, Value)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Property
	
	Private Function Canvas.GetDevice As Any Ptr
		'' KNOWN ISSUE (2026-07-12, documented + deferred — MFF hot-path review H-2):
		'' HandleSetted conflates two meanings that collide:
		''   (1) "a DC was set EXTERNALLY by the caller (a control owns it) -> never release it"
		''       -- how the IDE uses Canvas (EditControl/Designer set HandleSetted True/False
		''       around their own bufDC); and
		''   (2) "we currently hold a DC we acquired OURSELVES via GetDevice."
		'' GetDevice sets HandleSetted = True (meaning 2) at the end, but ReleaseDevice tests
		'' HandleSetted to honor meaning (1) and bails (`If HandleSetted Then Exit Sub`). Net: a
		'' Canvas used STANDALONE (no external SetHandle; HandleSetted starts False) acquires a DC
		'' here on first draw, latches HandleSetted True, and never releases it -- not per-call
		'' (subsequent draws reuse the held Handle) and not even in the destructor (same guard).
		'' One leaked DC per standalone-drawing Canvas lifetime.
		'' NOT FIXED, deliberately: the IDE never hits this path (its controls always set
		'' HandleSetted externally + own the DC), so a fix has ZERO IDE benefit while risking the
		'' 83 HandleSetted checks the working control-owned paint path depends on -- and the only
		'' affected pattern (standalone Canvas) isn't exercised anywhere in the IDE/examples, so a
		'' fix can't be live-verified here. A correct fix needs a SECOND flag (e.g. FOwnsDevice,
		'' set only when GetDevice acquires) so ReleaseDevice/the destructor release only what
		'' Canvas itself owns -- do that with a standalone-Canvas test harness, not blind.
		Dim As Any Ptr Handle_
		If Not HandleSetted Then
			If ParentControl Then
					If ParentControl->Handle Then
						If Clip Then
							Handle_ = GetDCEx(ParentControl->Handle, 0, DCX_PARENTCLIP Or DCX_CACHE)
						Else
							Handle_ = GetDC(ParentControl->Handle)
						End If
						SelectObject(Handle_, Font.Handle)
						SelectObject(Handle_, Pen.Handle)
						SelectObject(Handle_, Brush.Handle)
						SetROP2 Handle_, Pen.Mode
						If UsingGdip Then
							If GdipGraphics Then Return GdipGraphics 'GdipDeleteGraphics(GdipGraphics)
							GdipCreateFromHDC(Handle, @GdipGraphics)
							If  GdipGraphics = NULL Then
								Print Date & " " & Time & Chr(9) & __FUNCTION__ & Chr(9) & "Initial GdipGraphics failure! "
							Else
								GdipSetSmoothingMode(GdipGraphics, SmoothingModeAntiAlias)
								GdipSetCompositingQuality(GdipGraphics, &H3) 'CompositingQualityGammaCorrected
								GdipSetInterpolationMode(GdipGraphics, 7)
							End If
							'Handle_ = GdipGraphics
						End If
					End If
			End If
			Handle = Handle_
		Else
			Handle_ = Handle
		End If
		HandleSetted = True
		Return Handle_
	End Function
	
	Private Sub Canvas.ReleaseDevice(Handle As Any Ptr = 0)
		'' The `If HandleSetted Then Exit Sub` below is the honor-meaning-(1) guard that also
		'' wrongly suppresses release of a self-acquired DC -- see the H-2 note in GetDevice.
		Dim As Any Ptr Handle_ = Handle
		If Handle_ = 0 Then Handle_ = This.Handle
			If HandleSetted Then Exit Sub
			If ParentControl Then
				'If ParentControl->DoubleBuffered Then
				'	BitBlt(Handle_, 0, 0, R.Right - R.left, R.Bottom - R.top, memDC, 0, 0, SRCCOPY)
				'	DeleteObject(CompatibleBmp)
				'	DeleteDC(memDC)
				'End If
			If Handle_ Then
				ReleaseDC ParentControl->Handle, Handle_
			End If
			End If
	End Sub
	
	Private Sub Canvas.Scale(x As Double, y As Double, x1 As Double, y1 As Double)
		If ParentControl Then
			imgScaleX = Min(ParentControl->Width, ParentControl->Height) / (x1 - x)
			imgScaleY = Min(ParentControl->Width, ParentControl->Height) / (y1 - y)
			imgOffsetX = ScaleX(IIf(ParentControl->Width > ParentControl->Height, (ParentControl->Width - ParentControl->Height) / 2 - x * imgScaleX, -x * imgScaleX))
			imgOffsetY = ScaleY(IIf(ParentControl->Height > ParentControl->Width, (ParentControl->Height - ParentControl->Width) / 2 - y * imgScaleY, -y * imgScaleY))
			FScaleWidth = ScaleX(x1 - x)
			FScaleHeight = ScaleY(y1 - y)
		Else
			imgScaleX = 1
			imgScaleY = 1
			imgOffsetX = 0
			imgOffsetY = 0
			FDrawWidth = 1
			FScaleWidth = ScaleX(This.Width)
			FScaleHeight = ScaleY( This.Height)
		End If
	End Sub
	
	Private Sub Canvas.MoveTo(x As Double, y As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				FMoveToX = ScaleX(x) * imgScaleX + imgOffsetX : FMoveToY = ScaleY(y) * imgScaleY + imgOffsetY
			Else
				.MoveToEx Handle, ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, 0
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.LineTo(x As Double, y As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		Dim As Double FMoveToXNew = ScaleX(x) * imgScaleX + imgOffsetX - 0.5
		Dim As Double FMoveToYNew = ScaleY(y) * imgScaleY + imgOffsetY - 0.5
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				GdipDrawLine GdipGraphics, GdipPen, FMoveToX, FMoveToY, FMoveToXNew, FMoveToYNew
			Else
				.LineTo Handle, FMoveToXNew, FMoveToYNew
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Line(x As Double, y As Double, x1 As Double, y1 As Double, FillColorBk As Integer = -1, BoxBF As String = "" )
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		FMoveToX = x1: FMoveToY = y1
		If BoxBF <> "" Then
			If BoxBF = "F" Then
				'Special code for VB6
				Dim As Integer OldFillColor = Brush.Color
				If FillColorBk <> Brush.Color Then
					If FillColorBk = -1 Then FillColorBk = FBackColor
					Brush.Color = FillColorBk
				End If
					If UsingGdip AndAlso GdipGraphics <> 0 Then
						GdipFillRectangle(GdipGraphics, GdipBrush, x, y, x1, y1)
					Else
						Rectangle(x, y, x1, y1)
					End If
				If FillColorBk <> OldFillColor Then
					Brush.Color = OldFillColor
				End If
			Else
					If UsingGdip AndAlso GdipGraphics <> 0 Then
						GdipDrawLine GdipGraphics, GdipPen, x, y, x1, y1
					Else
						Rectangle(x, y, x1, y1)
					End If
			End If
		Else
			Dim As Integer OldPenColor
			If FillColorBk <> -1 Then
				OldPenColor = Pen.Color
				Pen.Color = FillColorBk
			End If
				If UsingGdip AndAlso GdipGraphics <> 0 Then
					GdipDrawLine GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY
				Else
					.MoveToEx Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, 0
					.LineTo Handle, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY
				End If
			If FillColorBk <> -1 Then Pen.Color = OldPenColor
		End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
		Private Sub Canvas.Rectangle Overload(x As Double, y As Double, x1 As Double, y1 As Double)
			Dim As Any Ptr Handle_
			If Not HandleSetted Then Handle_ = GetDevice
				If UsingGdip AndAlso GdipGraphics <> 0 Then
					If GdipBrush Then GdipFillRectangle(GdipGraphics, GdipBrush, ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1 - x) * imgScaleX, ScaleY(y1 - y) * imgScaleY)
					GdipDrawRectangle(GdipGraphics, GdipPen,  ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1 - x) * imgScaleX, ScaleY(y1 - y) * imgScaleY)
				Else
					.Rectangle Handle, ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX , ScaleY(y1) * imgScaleY + imgOffsetY
				End If
			If Not HandleSetted Then ReleaseDevice Handle_
		End Sub
	
	Private Sub Canvas.Rectangle(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillRectangle(GdipGraphics, GdipBrush, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX, ScaleY(R.Bottom - R.Top) * imgScaleY)
				GdipDrawRectangle(GdipGraphics, GdipPen, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX , ScaleY(R.Bottom - R.Top) * imgScaleY)
			Else
				.Rectangle Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right) * imgScaleX + imgOffsetX, ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Ellipse Overload(x As Double, y As Double, x1 As Double, y1 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillEllipse(GdipGraphics, GdipBrush, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX((x1)) * imgScaleX, ScaleY((y1)) * imgScaleY)
				GdipDrawEllipse(GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX, ScaleY(y1) * imgScaleY)
			Else
				.Ellipse(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY)
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Ellipse(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillEllipse(GdipGraphics, GdipBrush, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX, ScaleY(R.Bottom - R.Top) * imgScaleY)
				GdipDrawEllipse(GdipGraphics, GdipPen, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX, ScaleY(R.Bottom - R.Top) * imgScaleY)
			Else
				.Ellipse Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right) * imgScaleX + imgOffsetX, ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Circle(x As Double, y As Double, Radial As Double, FillColorBK As Integer = -1)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		'Special code for VB6
		If FillColorBK = -1 Then FillColorBK = FFillColor
		Dim As Integer OldFillColor = Brush.Color
		Brush.Color = FillColorBK
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillEllipse(GdipGraphics, GdipBrush, ScaleX(x - Radial / 2) * imgScaleX + imgOffsetX, ScaleY(y - Radial / 2) * imgScaleY + imgOffsetY, ScaleX(Radial) * imgScaleX, ScaleY(Radial) * imgScaleY)
				GdipDrawEllipse GdipGraphics, GdipPen, ScaleX(x - Radial / 2) * imgScaleX + imgOffsetX, ScaleY(y - Radial / 2) * imgScaleY + imgOffsetY, ScaleX(Radial) * imgScaleX, ScaleY(Radial) * imgScaleY
			Else
				.Ellipse Handle, ScaleX(x - Radial / 2) * imgScaleX + imgOffsetX, ScaleY(y - Radial / 2) * imgScaleY + imgOffsetY, ScaleX(x + Radial / 2) * imgScaleX + imgOffsetX, ScaleY(y + Radial / 2) * imgScaleY + imgOffsetY
			End If
		Brush.Color = OldFillColor
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.RoundRect Overload(x As Double, y As Double, x1 As Double, y1 As Double, nWidth As Integer, nHeight As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				'Gdipmove_to Handle, x * imgScaleX + imgOffsetX - 0.5, (y + nWidth / 2) * imgScaleY + imgOffsetY - 0.5
				'GdipDrawArc(GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(nWidth / 2) * imgScaleX, ScaleY(nHeight / 2) * imgScaleY, 180, 270)
				GdipDrawLine(GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY)
				'GdipDrawArc(GdipGraphics, GdipPen, ScaleX(x + nWidth - nWidth / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nWidth / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX(nWidth / 2) * imgScaleX, ScaleY(nHeight / 2) * imgScaleY, -90, 0)
				GdipDrawLine(GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY)
				'GdipDrawArc(GdipGraphics, GdipPen, ScaleX(x +  nWidth / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nHeight - nWidth / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX(nWidth / 2) * imgScaleX, ScaleY(nHeight / 2) * imgScaleY, 0, 90)
				'GdipDrawLine(GdipGraphics, GdipPen, ScaleX(x + nWidth / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nHeight) * imgScaleY + imgOffsetY - 0.5)
				'GdipDrawArc(GdipGraphics, GdipPen, ScaleX(x + nWidth / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nHeight - nWidth / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX(nWidth / 2) * imgScaleX, ScaleY(nHeight / 2) * imgScaleY, 90, 180)
			Else
				.RoundRect Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nWidth) * imgScaleX , ScaleY(nHeight) * imgScaleY
				
			End If
			
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Polygon(Points() As Point, Count As Long)
		If Count < 3 Then Return
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				If GdipBrush Then GdipFillPolygon GdipGraphics, GdipBrush, @tGpPoints(0), Count, FillMode
				GdipDrawPolygon GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.Polygon Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.RoundRect(R As Rect, nWidth As Integer, nHeight As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		This.RoundRect R.Left, R.Top, R.Right, R.Bottom, nWidth, nHeight
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Chord(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				'.Chord(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nXRadial1) * imgScaleX, ScaleY(nYRadial1) * imgScaleY, ScaleX(nXRadial2) * imgScaleX, ScaleY(nYRadial2) * imgScaleY)
			Else
				.Chord(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nXRadial1) * imgScaleX, ScaleY(nYRadial1) * imgScaleY, ScaleX(nXRadial2) * imgScaleX, ScaleY(nYRadial2) * imgScaleY)
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Pie(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillPie(GdipGraphics, GdipBrush, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1 - x) * imgScaleX + imgOffsetX, ScaleY(y1 - x) * imgScaleY + imgOffsetY, nXRadial1, nYRadial1)
				GdipDrawPie(GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1 - x) * imgScaleX + imgOffsetX, ScaleY(y1 - x) * imgScaleY + imgOffsetY, nXRadial1, nYRadial1)
			Else
				.Pie(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nXRadial1) * imgScaleX, ScaleY(nYRadial1) * imgScaleY, ScaleX(nXRadial2) * imgScaleX , ScaleY(nYRadial2) * imgScaleY)
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Arc(x As Double, y As Double, x1 As Double, y1 As Double, xStart As Double, yStart As Double, xEnd As Double, yEnd As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				'.Arc(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(xStart) * imgScaleX + imgOffsetX, ScaleY(yStart) * imgScaleY + imgOffsetY, ScaleX(xEnd) * imgScaleX + imgOffsetX, ScaleY(yEnd) * imgScaleY + imgOffsetY)
			Else
				.Arc(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(xStart) * imgScaleX + imgOffsetX, ScaleY(yStart) * imgScaleY + imgOffsetY, ScaleX(xEnd) * imgScaleX + imgOffsetX, ScaleY(yEnd) * imgScaleY + imgOffsetY)
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.ArcTo(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				'.ArcTo Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nXRadial1) * imgScaleX , ScaleY(nYRadial1) * imgScaleY, ScaleX(nXRadial2) * imgScaleX, ScaleY(nYRadial2) * imgScaleY
			Else
				.ArcTo Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nXRadial1) * imgScaleX , ScaleY(nYRadial1) * imgScaleY, ScaleX(nXRadial2) * imgScaleX, ScaleY(nYRadial2) * imgScaleY
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.AngleArc(x As Double, y As Double, Radius As Double, StartAngle As Double, SweepAngle As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				GdipDrawArc(GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(Radius) * imgScaleX, ScaleY(Radius) * imgScaleY, StartAngle, SweepAngle)
			Else
				.MoveToEx Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, 0
				.AngleArc Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(Radius) * imgScaleX, StartAngle, SweepAngle
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Polyline(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				If GdipBrush Then GdipFillPolygon(GdipGraphics, GdipBrush, Cast(GpPointF Ptr, @tGpPoints(0)), Count, FillMode)
				GdipDrawPolygon GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.Polyline Handle, Cast(..Point Ptr, @tPoints(0)), Count
				.ExtFloodFill Handle, (tPoints(0).X + tPoints(Count \ 2).X) / 2, (tPoints(0).Y + tPoints(Count \ 2).Y) / 2, FFillColor, FillStyle.fsSurface
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolylineTo(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				If GdipBrush Then GdipFillPolygon GdipGraphics, GdipBrush, Cast(GpPointF Ptr, @tGpPoints(0)), Count, FillMode
				GdipDrawPolygon GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.PolylineTo Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolyBeizer(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				If GdipBrush Then GdipFillClosedCurve(GdipGraphics, GdipBrush, Cast(GpPointF Ptr, @tGpPoints(0)), Count)
				GdipDrawBeziers(GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count)
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.PolyBezier Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolyBeizerTo(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
					Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				'GdipFillPolygon GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
				GdipDrawBeziers GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.PolyBezierTo Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.SetPixel(x As Double, y As Double, PixelColor As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then

			Else
				.SetPixel Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, PixelColor
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.GetPixel(x As Double, y As Double) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Function = .GetPixel(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
		Private Sub Canvas.SetHandle(CanvasHandle As HDC)
				Handle = CanvasHandle
				'SelectObject(Handle, Font.Handle)
				If UsingGdip Then
					If GdipGraphics Then GdipDeleteGraphics(GdipGraphics)
					GdipCreateFromHDC(Handle, @GdipGraphics)
					If  GdipGraphics = NULL Then
						Print Date & " " & Time & Chr(9) & __FUNCTION__ & Chr(9) & "Initial GdipGraphics failure! "
					Else
						GdipSetSmoothingMode(GdipGraphics, SmoothingModeAntiAlias)
						GdipSetCompositingQuality(GdipGraphics, &H3) 'CompositingQualityGammaCorrected
						GdipSetInterpolationMode(GdipGraphics, 7)
					End If
				End If
			HandleSetted = True
		End Sub

	Private Sub Canvas.UnSetHandle()
			If UsingGdip Then
				If GdipGraphics Then GdipDeleteGraphics(GdipGraphics)
			End If
			Handle = 0
		HandleSetted = False
	End Sub
	
	Private Sub Canvas.TextOut(x As Double, y As Double, ByRef s As WString, FG As Integer = -1, BK As Integer = -1)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			SetBkMode Handle, TRANSPARENT
			If FG = -1 Then SetTextColor(Handle, Font.Color) Else SetTextColor(Handle, FG)
			If BK = -1 Then
				Brush = GetStockObject(NULL_BRUSH)
			Else
				SetBkColor(Handle, BK)
				SetBkMode(Handle, OPAQUE)
			End If
			SelectObject(Handle, Font.Handle)
			.TextOut(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, @s, Len(s))
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.Get(x As Double, y As Double, nWidth As Integer, nHeight As Integer, ByRef ImageSource As My.Sys.Drawing.BitmapType) As Any Ptr
			Return Get(x, y, nWidth , nHeight, ImageSource.Handle)
	End Function
	
	Private Function Canvas.Get(x As Double, y As Double, nWidth As Integer, nHeight As Integer, ByVal ImageSource As Any Ptr) As Any Ptr
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim As GpImage Ptr pImage1
			Dim As GpImage Ptr pImage2
			Dim As HBITMAP     ImageDest
			GdipCreateBitmapFromHBITMAP(ImageSource, NULL, Cast(GpBitmap Ptr Ptr, @pImage1))
			GdipCloneBitmapArea (x, y, nWidth, nHeight, 0, Cast(GpBitmap Ptr , pImage1) , Cast(GpBitmap Ptr Ptr, @pImage2))
			If UsingGdip Then
				' // Free the image
				If pImage1 Then GdipDisposeImage pImage1
				Return pImage2
			Else
				GdipCreateHBITMAPFromBitmap(Cast(GpBitmap Ptr , pImage2) , @ImageDest, 0)
				If pImage1 Then GdipDisposeImage pImage1
				If pImage2 Then GdipDisposeImage pImage2
				Return ImageDest
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
		Return 0
	End Function
	
	Private Sub Canvas.DrawAlpha(x As Double, y As Double, nWidth As Double = -1, nHeight As Double = -1, ByRef Image As My.Sys.Drawing.BitmapType, iSourceAlpha As Integer = 255)
		If nWidth = -1 Then nWidth = ScaleX(Image.Width)
		If nHeight = -1 Then nHeight = ScaleY(Image.Height)
			If CBool(Image.pImage = NULL) OrElse UsingGdip = False Then
				DrawAlpha(x, y, nWidth, nHeight, Image.Handle, iSourceAlpha)
			Else
				If Image.pImage <> NULL Then DrawAlpha(x, y, nWidth, nHeight, Image.pImage, iSourceAlpha)
			End If
	End Sub

	Private Sub Canvas.DrawAlpha(x As Double, y As Double, nWidth As Double = -1, nHeight As Double = -1, ByVal Image As Any Ptr, iSourceAlpha As Integer = 255)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				If nWidth = -1 Then nWidth = ScaleX(Width)
				If nHeight = -1 Then nHeight = ScaleY(Height)
				GdipDrawImageRect(GdipGraphics, Image, x, y, nWidth, nHeight)
			Else
				Dim As HDC hMemDC = CreateCompatibleDC(Handle) ' Create Dc
				SelectObject(hMemDC, Image) ' Select BITMAP in New Dc
				Dim As BITMAP Bitmap01
				GetObject(Image, SizeOf(Bitmap01), @Bitmap01)
				
				Dim As BLENDFUNCTION bfn ' Struct With info For AlphaBlend
				bfn.BlendOp = AC_SRC_OVER
				bfn.BlendFlags = 0
				bfn.SourceConstantAlpha = iSourceAlpha
				bfn.AlphaFormat = AC_SRC_ALPHA
				If nWidth = -1 Then nWidth = ScaleX(Bitmap01.bmWidth)
				If nHeight = -1 Then nHeight = ScaleY(Bitmap01.bmHeight)
				SetStretchBltMode(Handle, HALFTONE)
				AlphaBlend(Handle, x, y, nWidth, nHeight, hMemDC, 0, 0, Bitmap01.bmWidth, Bitmap01.bmHeight, bfn) ' Display BITMAP
				DeleteDC(hMemDC) ' Delete Dc
			
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Draw(x As Double, y As Double, Image As Any Ptr)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			If UsingGdip AndAlso GdipGraphics <> 0 Then
				GdipDrawImageRect(GdipGraphics, Image, x, y, ScaleX(Width), ScaleY(Height))
			Else
				Dim As HDC MemDC
				Dim As HBITMAP OldBitmap
				Dim As BITMAP Bitmap01
				MemDC = CreateCompatibleDC(Handle)
				OldBitmap = SelectObject(MemDC, Cast(HBITMAP, Image))
				GetObject(Cast(HBITMAP, Image), SizeOf(Bitmap01), @Bitmap01)
				BitBlt(Handle, ScaleX(x), ScaleY(y), Bitmap01.bmWidth, Bitmap01.bmHeight, MemDC, 0, 0, SRCCOPY)
				SelectObject(MemDC, OldBitmap)
				DeleteDC(MemDC)
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Draw(x As Double, y As Double, ByRef Image As My.Sys.Drawing.BitmapType)
			This.Draw(x, y, Image.Handle)
	End Sub
	
	Private Sub Canvas.Draw(x As Double, y As Double, ByRef Image As My.Sys.Drawing.Icon)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			DrawIconEx(Handle, x, y, Image.Handle, Image.Width, Image.Height, 0, 0, DI_NORMAL)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
		Private Sub Canvas.DrawTransparent(x As Double, y As Double, Image As Any Ptr, cTransparentColor As UInteger = 0)
			Dim As Any Ptr Handle_
			If Not HandleSetted Then Handle_ = GetDevice
				Dim As BITMAP     bm
				Dim As COLORREF   cColor
				Dim As HBITMAP    bmAndBack, bmAndObject, bmAndMem, bmSave
				Dim As HBITMAP    bmBackOld, bmObjectOld, bmMemOld, bmSaveOld
				Dim As HDC        hdcMem, hdcBack, hdcObject, hdcTemp, hdcSave
				Dim As ..Point      ptSize
				
				hdcTemp = CreateCompatibleDC(Handle)
				SelectObject(hdcTemp, Cast(HBITMAP, Image))   ' Select bitmap into DC
				
				GetObject(Cast(HBITMAP, Image), SizeOf(BITMAP), Cast(LPSTR, @bm))
				ptSize.X = bm.bmWidth            ' Get bitmap width
				ptSize.Y = bm.bmHeight           ' Get bitmap height
				DPtoLP(hdcTemp, @ptSize, 1)      ' Convert from device
				' coordinates to logical
				' points
				
				' Create several DCs to hold temporary data.
				hdcBack   = CreateCompatibleDC(Handle)
				hdcObject = CreateCompatibleDC(Handle)
				hdcMem    = CreateCompatibleDC(Handle)
				hdcSave   = CreateCompatibleDC(Handle)
				
				' Create a bitmap for each DC.
				
				' Monochrome DC
				bmAndBack   = CreateBitmap(ptSize.X, ptSize.Y, 1, 1, NULL)
				
				' Monochrome DC
				bmAndObject = CreateBitmap(ptSize.X, ptSize.Y, 1, 1, NULL)
				
				bmAndMem    = CreateCompatibleBitmap(Handle, ptSize.X, ptSize.Y)
				bmSave      = CreateCompatibleBitmap(Handle, ptSize.X, ptSize.Y)
				
				' Each DC must have a bitmap object selected to store
				' pixels.
				bmBackOld   = SelectObject(hdcBack, bmAndBack)
				bmObjectOld = SelectObject(hdcObject, bmAndObject)
				bmMemOld    = SelectObject(hdcMem, bmAndMem)
				bmSaveOld   = SelectObject(hdcSave, bmSave)
				
				' Set mapping mode.
				SetMapMode(hdcTemp, GetMapMode(Handle))
				
				' Save the bitmap passed in the function parameter because
				' it will be modified.
				BitBlt(hdcSave, 0, 0, ptSize.X, ptSize.Y, hdcTemp, 0, 0, SRCCOPY)
				
				' Set background color (in source DC) of parts
				' that will be transparent.
				cColor = SetBkColor(hdcTemp, cTransparentColor)
				
				' Create bitmap mask by calling BitBlt from source
				' bitmap to monochrome bitmap.
				BitBlt(hdcObject, 0, 0, ptSize.X, ptSize.Y, hdcTemp, 0, 0, SRCCOPY)
				
				' Restore source DC background color to
				' original color.
				SetBkColor(hdcTemp, cColor)
				
				' Create mask inversion.
				BitBlt(hdcBack, 0, 0, ptSize.X, ptSize.Y, hdcObject, 0, 0, NOTSRCCOPY)
				
				' Copy main DC background to destination.
				BitBlt(hdcMem, 0, 0, ptSize.X, ptSize.Y, Handle, x, y, SRCCOPY)
				
				' Apply mask where bitmap will be placed.
				BitBlt(hdcMem, 0, 0, ptSize.X, ptSize.Y, hdcObject, 0, 0, SRCAND)
				
				' Apply mask to transparent bitmap pixels.
				BitBlt(hdcTemp, 0, 0, ptSize.X, ptSize.Y, hdcBack, 0, 0, SRCAND)
				
				' Xor bitmap with background on destination DC.
				BitBlt(hdcMem, 0, 0, ptSize.X, ptSize.Y, hdcTemp, 0, 0, SRCPAINT)
				
				' Copy to screen.
				BitBlt(Handle, x, y, ptSize.X, ptSize.Y, hdcMem, 0, 0, SRCCOPY)
				
				' Put original bitmap back into bitmap passed in
				' function parameter.
				BitBlt(hdcTemp, 0, 0, ptSize.X, ptSize.Y, hdcSave, 0, 0, SRCCOPY)
				
				' Delete bitmaps from memory.
				DeleteObject(SelectObject(hdcBack, bmBackOld))
				DeleteObject(SelectObject(hdcObject, bmObjectOld))
				DeleteObject(SelectObject(hdcMem, bmMemOld))
				DeleteObject(SelectObject(hdcSave, bmSaveOld))
				
				' Delete DCs from memory.
				DeleteDC(hdcMem)
				DeleteDC(hdcBack)
				DeleteDC(hdcObject)
				DeleteDC(hdcSave)
				DeleteDC(hdcTemp)
			If Not HandleSetted Then ReleaseDevice Handle_
		End Sub
		
		Private Sub Canvas.DrawTransparent(x As Double, y As Double, ByRef Image As My.Sys.Drawing.BitmapType, cTransparentColor As UInteger = 0)
				DrawTransparent ScaleX(x), ScaleY(y), Image.Handle, cTransparentColor
		End Sub
	
	Private Sub Canvas.DrawStretch(x As Double, y As Double, nWidth As Integer, nHeight As Integer, Image As Any Ptr)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim As HDC MemDC
			Dim As HBITMAP OldBitmap
			Dim As BITMAP Bitmap01
			MemDC = CreateCompatibleDC(Handle)
			OldBitmap = SelectObject(MemDC, Cast(HBITMAP, Image))
			GetObject(Cast(HBITMAP, Image), SizeOf(Bitmap01), @Bitmap01)
			SetStretchBltMode(Handle, HALFTONE)
			'SetStretchBltMode(Handle, COLORONCOLOR)
			StretchBlt(Handle, ScaleX(x), ScaleY(y), ScaleX(nWidth), ScaleX(nHeight), MemDC, 0, 0, Bitmap01.bmWidth, Bitmap01.bmHeight, SRCCOPY)
			SelectObject(MemDC, OldBitmap)
			DeleteDC(MemDC)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.CopyRect(Dest As Rect, Canvas As Canvas, Source As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.FloodFill(x As Double, y As Double, FillColorBK As Integer = -1, FillStyleBK As FillStyle)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If FillColorBK = -1 Then FillColorBK = FBackColor
			.ExtFloodFill Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, FillColorBK, FillStyleBK
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.FillRect(R As Rect, FillColorBK As Integer = -1)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If FillColorBK = -1 Then FillColorBK = FBackColor
			Static As HBRUSH B
			If B Then DeleteObject B
			R.Left = ScaleX(R.Left) * imgScaleX + imgOffsetX
			R.Top = ScaleY(R.Top) * imgScaleY + imgOffsetY
			R.Right = ScaleX(R.Right) * imgScaleX + imgOffsetX
			R.Bottom = ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			If FillColorBK <> -1 Then
				If Not UsingGdip Then
					B = CreateSolidBrush(FillColorBK)
					.FillRect Handle, Cast(..Rect Ptr, @R), B
				Else
					GdipFillRectangle(GdipGraphics, GdipBrush, R.Left, R.Top, R.Right, R.Bottom)
				End If
			Else
				If Not UsingGdip Then
					.FillRect Handle, Cast(..Rect Ptr, @R), Brush.Handle
				Else
					GdipFillRectangle(GdipGraphics, GdipBrush, R.Left, R.Top, R.Right, R.Bottom)
				End If
			End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.DrawFocusRect(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			R.Left = ScaleX(R.Left) * imgScaleX + imgOffsetX
			R.Top = ScaleY(R.Top) * imgScaleY + imgOffsetY
			R.Right = ScaleX(R.Right) * imgScaleX + imgOffsetX
			R.Bottom = ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			.DrawFocusRect Handle, Cast(..Rect Ptr, @R)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.TextWidth(ByRef FText As WString) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim Sz As ..Size
			GetTextExtentPoint32(Handle, @FText, Len(FText), @Sz)
			Function = UnScaleX(Sz.cx)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
	Private Function Canvas.TextHeight(ByRef FText As WString) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim Sz As ..Size
			GetTextExtentPoint32(Handle, @FText, Len(FText), @Sz)
			Function = UnScaleY(Sz.cy)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
	Private Operator Canvas.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Sub Canvas.Font_Create(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Font)
		With *Cast(Canvas Ptr, Sender.Parent)
				If .Handle Then SelectObject(.Handle, Sender.Handle)
		End With
	End Sub
	
	Private Sub Canvas.Pen_Create(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Pen)
			With *Cast(Canvas Ptr, Sender.Parent)
				If .Handle Then
					SelectObject(.Handle, Sender.Handle)
					SetROP2 .Handle, Sender.Mode
				End If
				If .UsingGdip = True Then
					If .GdipPen Then GdipDeletePen(.GdipPen)
					GdipCreatePen1(RGBtoARGB(.Pen.Color, .BackColorOpacity), .FDrawWidth, &H2, @.GdipPen)
				End If
			End With
	End Sub
	
	Private Sub Canvas.Brush_Create(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Brush)
			With *Cast(Canvas Ptr, Sender.Parent)
				If .Handle Then SelectObject(.Handle, Sender.Handle)
				If .UsingGdip = True Then
					If .GdipBrush Then GdipDeleteBrush(.GdipBrush)
					GdipCreateSolidFill(RGBtoARGB(.FFillColor, .FillOpacity), Cast(GpSolidFill Ptr Ptr, @.GdipBrush))
				End If
			End With
	End Sub
	
	Private Constructor Canvas
		Clip = False
		WLet(FClassName, "Canvas")
			FGdipStartupInput.GdiplusVersion = 1                    ' attempt to start GDI+
			GdiplusStartup(@GdipToken, @FGdipStartupInput, NULL)
			If GdipToken = NULL Then Print Date & " " & Time & Chr(9) & __FUNCTION__ & Chr(9) & "Initial GDIPlus failure!  GdipToken = " & GdipToken
		Font.Parent = @This
		Font.OnCreate = @Font_Create
		Pen.Parent = @This
		Pen.OnCreate = @Pen_Create
		Brush.Parent = @This
		Brush.OnCreate = @Brush_Create
		Brush.Style = BrushStyles.bsSolid
		imgScaleX = 1
		imgScaleY = 1
		FDrawWidth = 1
		FScaleWidth = ScaleX(This.Width)
		FScaleHeight = ScaleY(This.Height)
		FillOpacity = 50
		BackColorOpacity = 100
	End Constructor
	
	Private Destructor Canvas
			If Handle Then ReleaseDevice
			' // Shutdown Gdiplus
			If GdipPen Then GdipDeletePen(GdipPen)
			If GdipBrush Then GdipDeleteBrush(GdipBrush)
			If GdipGraphics Then GdipDeleteGraphics(GdipGraphics)
			If GdipToken Then GdiplusShutdown GdipToken
	End Destructor
End Namespace


