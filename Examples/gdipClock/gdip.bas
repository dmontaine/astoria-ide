' gdip
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "gdip.bi"
#include once "gdipText.bi"
#include once "gdipForm.bi"

Private Constructor gdipToken
	Initial()
End Constructor

Private Destructor gdipToken
	Release()
End Destructor

Private Sub gdipToken.Initial()
	'Initialize the GDI+ library
	If mToken Then Exit Sub
	Dim uInput As GdiplusStartupInput
	uInput.GdiplusVersion = 1
	GdiplusStartup(@mToken, @uInput, NULL)
End Sub

Private Sub gdipToken.Release()
	'Clean up resources used by GDI+
	If mToken = 0 Then Exit Sub
	GdiplusShutdown mToken
	mToken = NULL
End Sub

Private Constructor gdipDC(ByVal phWnd As HANDLE = 0)
	Initial(phWnd)
End Constructor

Private Destructor gdipDC
	Release()
End Destructor

Private Property gdipDC.DC() As HDC
	Return mDC
End Property

Private Sub gdipDC.Initial(ByVal phWnd As HANDLE = 0, ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Release()
	If phWnd Then
		'Get the display device for the handle
		mHWND = phWnd
		mDC = GetDC(phWnd)
	Else
		'When the handle is 0, create an in-memory display device
		mDC = CreateCompatibleDC(0)
		mDtHWND = GetDesktopWindow()
		mDtDC = GetDC(mDtHWND)
		mBitmap = CreateCompatibleBitmap(mDtDC, pWidth, pHeight)
		mOldDC = SelectObject(mDC, mBitmap)
	End If
End Sub

Private Sub gdipDC.Release()
	'Free resources
	If mBitmap Then
		DeleteObject(mBitmap)
		mBitmap = NULL
	End If
	
	If mOldDC Then
		SelectObject(0, mOldDC)
		DeleteObject(mOldDC)
		mOldDC = NULL
	End If
	
	If mDC Then
		DeleteDC(mDC)
		ReleaseDC(0, mDC)
		mDC = NULL
	End If
	
	If mDtDC Then
		DeleteDC(mDtDC)
		ReleaseDC(0, mDtDC)
		mDtDC = NULL
	End If
End Sub

Private Constructor gdipGraphics(ByVal pDC As HDC = 0, ByVal pClear As Boolean = False)
	Initial(pDC)
End Constructor

Private Destructor gdipGraphics
	Release()
End Destructor

Private Sub gdipGraphics.Initial(ByVal pDC As HDC = 0, ByVal pClear As Boolean = False)
	'Initialize the mGraphics canvas
	Release()
	If pDC Then
		GdipCreateFromHDC(pDC, @mGraphics)
		GdipSetSmoothingMode(mGraphics, SmoothingModeAntiAlias)
		GdipSetPixelOffsetMode(mGraphics, PixelOffsetModeHighQuality)
		GdipSetTextRenderingHint(mGraphics, TextRenderingHintAntiAlias)
		
		If pClear Then GdipGraphicsClear(mGraphics, mBackColor)
	End If
End Sub

Private Sub gdipGraphics.Release()
	'Free the mGraphics canvas resources
	If mGraphics Then
		GdipDeleteGraphics(mGraphics)
		mGraphics = NULL
	End If
End Sub

Private Property gdipGraphics.Graphics() As GpGraphics Ptr
	Return mGraphics
End Property

Private Sub gdipGraphics.DrawImage(pImage As GpImage Ptr, pX As Single = 0, pY As Single = 0)
	'Draw pImage onto the mGraphics canvas at (pX, pY)
	Dim As Single sWidth, sHeight
	GdipGetImageDimension(pImage, @sWidth, @sHeight)
	GdipDrawImageRect(mGraphics, pImage, pX, pY, sWidth, sHeight)
End Sub

Private Constructor gdipImage
	WLet(mFileName, "")
End Constructor

Private Destructor gdipImage
	Release()
End Destructor

Private Sub gdipImage.Release
	'Free image resources
	If mImage Then
		GdipDisposeImage(mImage)
		mImage = NULL
	End If
	
	If mResizedImage Then
		GdipDisposeImage(mResizedImage)
		mResizedImage = NULL
	End If
	
	mWidth = 0
	mHeight = 0

	If mFileName Then 
		Deallocate(mFileName)
		mFileName = NULL
	End If
End Sub

Private Property gdipImage.ImageFile(ByRef pFileName As WString)
	'Load the image from a file into mImage
	Dim pImage As GpImage Ptr = NULL
	If Dir(pFileName) <> "" Then
		GdipLoadImageFromFile(@pFileName, @pImage)
	End If
	Image = pImage
	WLet(mFileName, pFileName)
End Property

Private Property gdipImage.ImageFile() ByRef As WString
	If mFileName Then
		Return *mFileName
	Else
		Return ""
	End If
End Property

Private Property gdipImage.Height As Single
	Return mHeight
End Property

Private Property gdipImage.Width As Single
	Return mWidth
End Property

Private Property gdipImage.Image(pImage As GpImage Ptr)
	'Assign the image from pImage into mImage
	Release()
	If pImage Then
		mImage = pImage
		If mImage Then
			GdipGetImageDimension(mImage, @mWidth, @mHeight)
		End If
	End If
End Property

Private Property gdipImage.Image As GpImage Ptr
	Return mImage
End Property

Private Function gdipImage.Resize(pNewWidth As Single, pNewHeight As Single) As GpImage Ptr
	'Scale mImage and return the result
	If mResizedImage Then GdipDisposeImage(mResizedImage)
	
	Dim fGraphics As GpGraphics Ptr
	'Prepare the canvas and bitmap
	GdipCreateBitmapFromScan0(pNewWidth, pNewHeight, 0, PixelFormat32bppARGB, 0, @mResizedImage)
	GdipGetImageGraphicsContext(mResizedImage, @fGraphics)
	
	'Create a scaling matrix
	Dim fMatrix As GpMatrix Ptr
	GdipCreateMatrix(@fMatrix)
	GdipScaleMatrix(fMatrix, pNewWidth / mWidth, pNewHeight / mHeight, 0)
	GdipSetWorldTransform(fGraphics, fMatrix)
	'Draw the scaled image
	GdipDrawImageRect(fGraphics, mImage, 0, 0, mWidth, mHeight)
	
	GdipDeleteGraphics(fGraphics)
	GdipDeleteMatrix(fMatrix)
	
	Return mResizedImage
End Function

Private Sub gdipBitmap.DrawScaleImage(pImage As GpImage Ptr, ByVal pWidth As Single = 0, ByVal pHeight As Single= 0)
	'Stretch pImage to fill and draw it onto mGraphics (mBitmap)
	If pImage = NULL Then Exit Sub
	
	Dim As Single fNewWidth, fNewHeight
	fNewWidth = IIf(pWidth = 0, mWidth, pWidth)
	fNewHeight = IIf(pHeight = 0, mHeight, pHeight)
	
	Dim As Single fOriginalWidth, fOriginalHeight
	GdipGetImageDimension(pImage, @fOriginalWidth, @fOriginalHeight)
	
	'Prepare the canvas and bitmap
	Dim fResizedImage As Any Ptr
	Dim fGraphics As GpGraphics Ptr
	GdipCreateBitmapFromScan0(fNewWidth, fNewHeight, 0, PixelFormat32bppARGB, 0, @fResizedImage)
	GdipGetImageGraphicsContext(fResizedImage, @fGraphics)
	
	'Create a scaling matrix
	Dim fMatrix As GpMatrix Ptr
	GdipCreateMatrix(@fMatrix)
	GdipScaleMatrix(fMatrix, fNewWidth / fOriginalWidth, fNewHeight / fOriginalHeight, 0)
	GdipSetWorldTransform(fGraphics, fMatrix)
	
	'Draw the image
	GdipDrawImageRect(fGraphics, pImage, 0, 0, fOriginalWidth, fOriginalHeight)
	'Draw the scaled image
	GdipDrawImageRect(mGraphics, fResizedImage, 0, 0, fNewWidth, fNewHeight)
	
	'Free resources
	GdipDeleteGraphics(fGraphics)
	GdipDeleteMatrix(fMatrix)
	GdipDisposeImage(fResizedImage)
End Sub

Private Sub gdipBitmap.DrawAlphaImage(pImage As GpImage Ptr, pAlpha As Single)
	'Alpha-blend pImage and draw it onto mGraphics (mBitmap)
	Dim As Single fOriginalWidth, fOriginalHeight
	GdipGetImageDimension(pImage, @fOriginalWidth, @fOriginalHeight)
	
	' Create image attributes
	Dim fImageAttr As GpImageAttributes Ptr
	GdipCreateImageAttributes(@fImageAttr)
	
	' Set the color matrix to perform alpha blending
	Dim fColorMatrix As ColorMatrix = Type( _
	{{1.0, 0.0, 0.0, 0.0, 0.0}, _
	{0.0, 1.0, 0.0, 0.0, 0.0}, _
	{0.0, 0.0, 1.0, 0.0, 0.0}, _
	{0.0, 0.0, 0.0, pAlpha/&HFF, 0.0}, _
	{0.0, 0.0, 0.0, 0.0, 1.0}} _
	)
	
	GdipSetImageAttributesColorMatrix(fImageAttr, ColorAdjustTypeBitmap, True, @fColorMatrix, NULL, ColorMatrixFlagsDefault)
	
	' Draw the alpha-blended image
	GdipDrawImageRectRect(mGraphics, pImage, 0, 0, fOriginalWidth, fOriginalHeight, 0, 0, fOriginalWidth, fOriginalHeight, UnitPixel, fImageAttr, NULL, NULL)
	GdipDisposeImageAttributes(fImageAttr)
End Sub

Private Sub gdipBitmap.DrawFromFile(ImageFile As WString)
	'Load the image from a file into mImage
	Dim pImage As GpImage Ptr
	GdipLoadImageFromFile(@ImageFile, @pImage)
	Image = Cast(Any Ptr, pImage)
End Sub

Private Sub gdipBitmap.DrawRotateImage(pImage As GpImage Ptr, pAngle As Single)
	'Rotate pImage by pAngle and draw it onto mGraphics (mBitmap)
	If pImage = NULL Then Exit Sub
	
	Dim As Single fOriginalWidth, fOriginalHeight
	GdipGetImageDimension(pImage, @fOriginalWidth, @fOriginalHeight)
	Dim fCenterX As Single = fOriginalWidth / 2.0
	Dim fCenterY As Single = fOriginalHeight / 2.0
	
	'Prepare the canvas and bitmap
	Dim fResizedImage As Any Ptr
	Dim fGraphics As GpGraphics Ptr
	GdipCreateBitmapFromScan0(fOriginalWidth, fOriginalHeight, 0, PixelFormat32bppARGB, 0, @fResizedImage)
	GdipGetImageGraphicsContext(fResizedImage, @fGraphics)
	
	'Create a scaling matrix
	Dim fMatrix As GpMatrix Ptr
	GdipCreateMatrix(@fMatrix)
	GdipTranslateMatrix(fMatrix, fCenterX, fCenterY, MatrixOrderPrepend)
	GdipRotateMatrix(fMatrix, pAngle, MatrixOrderPrepend)
	GdipTranslateMatrix(fMatrix, -fCenterX, -fCenterY, MatrixOrderPrepend)
	GdipSetWorldTransform(fGraphics, fMatrix)
	
	'Draw the image
	GdipDrawImageRect(fGraphics, pImage, 0, 0, fOriginalWidth, fOriginalHeight)
	'Draw the rotated image
	GdipDrawImageRect(mGraphics, fResizedImage, 0, 0, mWidth, mHeight)
	
	'Free resources
	GdipDeleteGraphics(fGraphics)
	GdipDeleteMatrix(fMatrix)
	GdipDisposeImage(fResizedImage)
End Sub

Private Sub gdipBitmap.DrawPartImage(pImage As GpImage Ptr, pDestX As Single, pDestY As Single,  pSrcX As Single, pSrcY As Single, pSrcWidth As Single, pSrcHeight As Single, ByVal pAlpha As Integer = &HFF)
	'Draw part of pImage onto mGraphics (mBitmap)
	
	' Create image attributes
	Dim fImageAttr As GpImageAttributes Ptr
	GdipCreateImageAttributes(@fImageAttr)
	
	' Set the color matrix to perform alpha blending
	Dim fColorMatrix As ColorMatrix = Type( _
	{{1.0, 0.0, 0.0, 0.0, 0.0}, _
	{0.0, 1.0, 0.0, 0.0, 0.0}, _
	{0.0, 0.0, 1.0, 0.0, 0.0}, _
	{0.0, 0.0, 0.0, pAlpha/&HFF, 0.0}, _
	{0.0, 0.0, 0.0, 0.0, 1.0}} _
	)
	
	GdipSetImageAttributesColorMatrix(fImageAttr, ColorAdjustTypeBitmap, True, @fColorMatrix, NULL, ColorMatrixFlagsDefault)
	
	GdipDrawImageRectRect(mGraphics, pImage, pDestX, pDestY, pSrcWidth, pSrcHeight, pSrcY, pSrcY, pSrcWidth, pSrcHeight, UnitPixel, fImageAttr, NULL, NULL)
	
	GdipDisposeImageAttributes(fImageAttr)
End Sub

Private Sub gdipBitmap.DrawImage(pImage As GpImage Ptr, pX As Single, pY As Single)
	'Draw pImage at its original size onto mGraphics (mBitmap)
	If pImage = NULL Then Exit Sub
	Dim As Single sWidth, sHeight
	GdipGetImageDimension(pImage, @sWidth, @sHeight)
	GdipDrawImageRect(mGraphics, pImage, pX, pY, sWidth, sHeight)
End Sub
Private Sub gdipBitmap.Release()
	GdipDisposeImage(mBitmap)
	mBitmap = NULL
	GdipDeleteGraphics(mGraphics)
	mGraphics = NULL
End Sub
Private Sub gdipBitmap.Initial(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Release()
	'Prepare the mGraphics canvas and mBitmap bitmap
	mWidth = pWidth
	mHeight = pHeight
	GdipCreateBitmapFromScan0(mWidth, mHeight, 0, PixelFormat32bppARGB, 0, @mBitmap)
	GdipGetImageGraphicsContext(mBitmap, @mGraphics)
	GdipSetSmoothingMode(mGraphics, SmoothingModeAntiAlias)
	GdipSetPixelOffsetMode(mGraphics, PixelOffsetModeHighQuality)
	GdipSetTextRenderingHint(mGraphics, TextRenderingHintAntiAlias)
End Sub
Private Property gdipBitmap.Image(pImage As GpBitmap Ptr)
	'Assign the image from pImage into mImage
	Release()
	mBitmap = pImage
	If mBitmap Then
		GdipGetImageDimension(mBitmap, @mWidth, @mHeight)
	End If
End Property
Private Property gdipBitmap.Image() As GpImage Ptr
	Return mBitmap
End Property
'Private Property gdipBitmap.Graphics(pGraphics As GpGraphics Ptr)
'
'End Property
Private Property gdipBitmap.Graphics() As GpGraphics Ptr
	Return mGraphics
End Property
Private Property gdipBitmap.Height() As Single
	Return mHeight
End Property
Private Property gdipBitmap.Width() As Single
	Return mWidth
End Property

Private Constructor gdipBitmap(ByVal pWidth As Single = 400, ByVal pHeight As Single = 300)
	Initial(pWidth, pHeight)
End Constructor

Private Destructor gdipBitmap
	Release()
End Destructor
