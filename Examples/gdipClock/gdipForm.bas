' Trans Form - Transparent window
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdipForm.bi"

Private Constructor gdipForm
	Initial()
End Constructor

Private Destructor gdipForm
	Release()
End Destructor

Private Sub gdipForm.Initial()
	
End Sub

Private Sub gdipForm.Release()
	'Free the Graphics object
	If mGraphics Then GdipDeleteGraphics(mGraphics)
	'Free the bitmap
	If hHBitmap Then DeleteObject(hHBitmap)
	'Deselect the drawn object
	If hOldDC AndAlso hMemDC Then SelectObject(hMemDC, hOldDC)
	'Free the compatible device context
	If hMemDC Then DeleteDC(hMemDC)
	'Release the device
	If hScrDC Then ReleaseDC(0, hScrDC)
	'Free the image
	If mImage Then GdipDisposeImage(mImage)
	If mBitmap Then DeleteObject(mBitmap)
End Sub

Private Sub gdipForm.Create(Handle As HWND, Img As GpImage Ptr)
	Release()
	
	mHandle = Handle
	
	GdipGetImageDimension(Img, @sWidth, @sHeight)
	
	With bmHeader.bmiHeader
		.biSize = SizeOf(bmHeader)
		.biBitCount = 32  'Needs an alpha channel, hence 32bpp bitmap
		.biWidth = sWidth
		.biHeight = sHeight
		.biPlanes = 1
		.biSizeImage = .biWidth * .biHeight * 4  '4 bytes per pixel at 32-bit
	End With
	
	'Get the device context for the given window; release with ReleaseDC
	hScrDC = GetDC(mHandle)
	'Create a memory DC compatible with the given device; free with DeleteDC when no longer needed
	hMemDC = CreateCompatibleDC(hScrDC)
	'Create a device-independent bitmap; free with DeleteObject
	hHBitmap = CreateDIBSection(hMemDC, @bmHeader, DIB_RGB_COLORS, 0, 0, 0)
	'Select a drawable object into the device context (DC); restore with SelectObject(hMemDC, hOldDC)
	hOldDC = SelectObject(hMemDC, hHBitmap)
	
	'Create a Graphics object for drawing via the Windows device driver; free with GdipDeleteGraphics
	GdipCreateFromHDC(hMemDC, @mGraphics)
	
	GdipSetSmoothingMode(mGraphics, SmoothingModeAntiAlias)
	GdipSetSmoothingMode(mGraphics, SmoothingModeAntiAlias)
	GdipSetPixelOffsetMode(mGraphics, PixelOffsetModeHighQuality)
	GdipSetTextRenderingHint(mGraphics, TextRenderingHintAntiAlias)
	
	'Background color
	'GdipGraphicsClear(mGraphics, mBackColor)
	
	'Draw the image into the given rectangle; free with GdipDisposeImage
	GdipDrawImageRect(mGraphics, Img, 0, 0, sWidth, sHeight)
End Sub

Private Sub gdipForm.DrawImage(sImg As GpImage Ptr, sX As Single = 0, sY As Single = 0)
	If sImg = NULL Then Exit Sub
	Dim As Single sWidth, sHeight
	GdipGetImageDimension(sImg, @sWidth, @sHeight)
	GdipDrawImageRect(mGraphics, sImg, sX, sY, sWidth, sHeight)
End Sub

Private Property gdipForm.Enabled() As Boolean
	'Return whether the window has the transparency effect
	If mHandle = NULL Then Return False
	mEnabled = IIf((GetWindowLong(mHandle, GWL_EXSTYLE) And WS_EX_LAYERED) = WS_EX_LAYERED, True, False)
	Return mEnabled
End Property

Private Property gdipForm.Enabled(val As Boolean)
	mEnabled = val
	If mHandle = NULL Then Return
	If mEnabled Then
		'Update the window to enable the transparency effect
		SetWindowLong(mHandle, GWL_EXSTYLE, GetWindowLong(mHandle, GWL_EXSTYLE) Or WS_EX_LAYERED)
	Else
		'Update the window to disable the transparency effect
		SetWindowLong(mHandle, GWL_EXSTYLE, GetWindowLong(mHandle, GWL_EXSTYLE) And Not WS_EX_LAYERED)
	End If
End Property

Private Property gdipForm.Graphic() As GpGraphics Ptr
	Return mGraphics
End Property

Private Sub gdipForm.Transform(ByVal Alpha As Integer = 255)
	With ULWpsize
		.cx = sWidth
		.cy = sHeight
	End With
	With ULWpblend
		.BlendOp = AC_SRC_OVER
		.BlendFlags = 0
		.SourceConstantAlpha = Alpha
		.AlphaFormat = AC_SRC_ALPHA
	End With
	
	Dim lRT As Rect
	'Get the control's bounding rectangle
	GetWindowRect(mHandle, @lRT)
	With ULWpptDst
		.X = lRT.Left
		.Y = lRT.Top
	End With
	
	With ULWpptSrc
		.X = 0
		.Y = 0
	End With
	
	'Set the window's WS_EX_LAYERED style
	If Enabled <> True Then Exit Sub
	
	'Update the window with the transparency effect
	UpdateLayeredWindow(mHandle, hScrDC, @ULWpptDst, @ULWpsize, hMemDC, @ULWpptSrc, ULWcrKey, @ULWpblend, ULW_ALPHA)
End Sub

