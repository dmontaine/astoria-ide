'###############################################################################
'#  Picture.bas                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Liu ZiQI                                           #
'#  Based on:                                                                  #
'#   TStatic.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Created by Liu ZiQI (2019)                                                 #
'###############################################################################
'https://blog.csdn.net/mmmvp/article/details/365155

#include once "Picture.bi"
Namespace My.Sys.Forms
		Private Function Picture.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autosize": Return @FAutoSize
			Case "centerimage": Return @FCenterImage
			Case "graphic": Return Cast(Any Ptr, @This.Graphic)
			Case "realsizeimage": Return @FRealSizeImage
			Case "stretchimage": Return @FStretchImage
			Case "transparent": Return @FTransparent
			Case "style": Return @FPictureStyle
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Picture.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "autosize": This.AutoSize = QBoolean(Value)
				Case "centerimage": This.CenterImage = QBoolean(Value)
				Case "stretchimage": This.StretchImage = *Cast(StretchMode Ptr, Value)
				Case "graphic": This.Graphic = QWString(Value)
				Case "realsizeimage": This.RealSizeImage = QBoolean(Value)
				Case "transparent": This.Transparent = QBoolean(Value)
				Case "style": This.Style = *Cast(PictureStyle Ptr, Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property Picture.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property Picture.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property Picture.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property Picture.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property Picture.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property Picture.AutoSize(Value As Boolean)
		If Value <> FAutoSize Then
			Base.AutoSize = Value
				Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FPictureStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize)) Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
		End If
		RecreateWnd
	End Property
	
	Private Property Picture.StretchImage As StretchMode
		Return FStretchImage
	End Property
	
	Private Property Picture.StretchImage(Value As StretchMode)
		If Value <> FStretchImage Then
			FStretchImage = Value
				InvalidateRect(Handle, NULL, True)
		End If
	End Property
	
	Private Property Picture.Style As PictureStyle
		Return FPictureStyle
	End Property
	
	Private Property Picture.Style(Value As PictureStyle)
		If Value <> FPictureStyle Then
			FPictureStyle = Value
				Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FPictureStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize)) Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
		End If
		RecreateWnd
	End Property
	
	Private Property Picture.RealSizeImage As Boolean
		Return FRealSizeImage
	End Property
	
	Private Property Picture.RealSizeImage(Value As Boolean)
		If Value <> FRealSizeImage Then
			FRealSizeImage = Value
				Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FPictureStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize)) Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
			RecreateWnd
		End If
	End Property
	
	Private Property Picture.CenterImage As Boolean
		Return FCenterImage
	End Property
	
	Private Property Picture.CenterImage(Value As Boolean)
		If Value <> FCenterImage Then
			FCenterImage = Value
			Graphic.CenterImage = Value
				Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FPictureStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize)) Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
			RecreateWnd
		End If
	End Property
	
	Private Sub Picture.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					Select Case ImageType
					Case 0
						QPicture(.Ctrl->Child).Style = PictureStyle.ssBitmap
						QPicture(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Bitmap.Handle))
					Case 1
						QPicture(.Ctrl->Child).Style = PictureStyle.ssIcon
						QPicture(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
					Case 2
						QPicture(.Ctrl->Child).Style = PictureStyle.ssCursor
						QPicture(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
					Case 3
						QPicture(.Ctrl->Child).Style = PictureStyle.ssEmf
						QPicture(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(0))
					End Select
			End If
		End With
	End Sub
	
		Private Sub Picture.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QPicture(Sender.Child)
						.Perform(STM_SETIMAGE, .Graphic.ImageType, CInt(.Graphic.Image))
				End With
			End If
		End Sub
		
		Private Sub Picture.WndProc(ByRef Message As Message)
		End Sub
	
	
	Private Sub Picture.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC,Message.wParam)
				SetBkMode Dc, Transparent
				SetTextColor Dc, Font.Color
				If Not FTransparent OrElse FDesignMode Then
					SetBkColor Dc, FBackColor
					SetBkMode Dc, OPAQUE
				Else
					Message.Result = Cast(LRESULT, GetStockObject(NULL_BRUSH))
				End If
			Case WM_PAINT
				Dim As HDC Dc, memDC
				Dim As HBITMAP MemBmp, hOldBmp
				Dim As PAINTSTRUCT Ps
				Dim As ..Rect R
				GetClientRect Handle, @R
				Dc = BeginPaint(Handle, @Ps)
				If Dc = 0 Then
					EndPaint This.Handle, @Ps
					Message.Result = 0
					Return
				End If
				If DoubleBuffered Then
					memDC = CreateCompatibleDC(Dc)
					MemBmp   = CreateCompatibleBitmap(Dc, R.Right - R.Left, R.Bottom - R.Top)
					hOldBmp = SelectObject(memDC, MemBmp)
					FillRect memDC, @R, Brush.Handle
					Canvas.SetHandle memDC
				Else
					FillRect Dc, @R, Brush.Handle
					Canvas.SetHandle Dc
				End If
				With Graphic
					If .Visible AndAlso .Bitmap.Handle > 0 Then
						Select Case Graphic.StretchImage
						Case StretchMode.smNone
							Canvas.DrawAlpha .StartX, .StartY, , , .Bitmap
						Case StretchMode.smStretch
							Canvas.DrawAlpha .StartX, .StartY, ScaleX(This.Width) * .ScaleFactor, ScaleY(This.Height) * .ScaleFactor, .Bitmap
						Case Else 'StretchMode.smStretchProportional
							Dim As Double imgWidth = .Bitmap.Width
							Dim As Double imgHeight = .Bitmap.Height
							Dim As Double PicBoxWidth = ScaleX(This.Width) * .ScaleFactor
							Dim As Double PicBoxHeight = ScaleY(This.Height) * .ScaleFactor
							Dim As Double img_ratio = imgWidth / imgHeight
							Dim As Double PicBox_ratio =  PicBoxWidth / PicBoxHeight
							If (PicBox_ratio >= img_ratio) Then
								imgHeight = PicBoxHeight
								imgWidth = imgHeight *img_ratio
							Else
								imgWidth = PicBoxWidth
								imgHeight = imgWidth / img_ratio
							End If
							If .CenterImage Then
								Canvas.DrawAlpha Max((PicBoxWidth - imgWidth * .ScaleFactor) / 2, .StartX), Max((PicBoxHeight - imgHeight * .ScaleFactor) / 2, Graphic.StartY), imgWidth * Graphic.ScaleFactor, imgHeight * .ScaleFactor, .Bitmap
							Else
								Canvas.DrawAlpha .StartX, .StartY, imgWidth, imgHeight, .Bitmap
							End If
						End Select
					End If
				End With
				If ShowCaption Then
					Canvas.TextOut(Current.X, Current.Y, FText, Font.Color, FBackColor)
				End If
				If OnPaint Then OnPaint(*Designer, This, Canvas)
				Canvas.UnSetHandle
				If DoubleBuffered Then
					BitBlt(Dc, 0, 0, R.Right - R.left, R.Bottom - R.top, memDC, 0, 0, SRCCOPY)
					SelectObject memDC, hOldBmp
					DeleteObject(MemBmp)
					DeleteDC(memDC)
				End If
				EndPaint Handle, @Ps
				Message.Result = 0
				Return
			Case WM_SIZE
				InvalidateRect(Handle, NULL, True)
			Case CM_DRAWITEM
				Dim As DRAWITEMSTRUCT Ptr diStruct
				Dim As My.Sys.Drawing.Rect R
				Dim As HDC Dc
				diStruct = Cast(DRAWITEMSTRUCT Ptr, Message.lParam)
				R = *Cast(My.Sys.Drawing.Rect Ptr, @diStruct->rcItem)
				Dc = diStruct->hDC
				If OnDraw Then OnDraw(*Designer, This, R, Dc)
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Property Picture.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property Picture.Transparent(Value As Boolean)
		FTransparent = Value
			ChangeExStyle WS_EX_TRANSPARENT, Value
	End Property
	
	Private Operator Picture.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor Picture
			'https://blog.csdn.net/mmmvp/article/details/365155
			'Constant     Description
			AStyle(0)=0
			AStyle(1)=SS_BITMAP'Display a bitmap (.BMP) in a static control; TEXT specifies a bitmap in resources (not a filename). Ignores width/height; control auto-sizes to bitmap.
			AStyle(2)=SS_ICON'Display an icon (.ICO) in a static control; TEXT specifies an icon in resources. Ignores width/height; control auto-sizes to icon.
			AStyle(3)=SS_ENHMETAFILE'Display an enhanced metafile (.EMF) in a static control; TEXT specifies metafile name. Fixed size; metafile scaled to client area.
			AStyle(4)=SS_BLACKFRAME'Draw border using window frame color (default black); interior transparent like parent form.
			AStyle(5)=SS_BLACKRECT'Draw solid rectangle using window frame color (default black).
			AStyle(6)=SS_GRAYFRAME'Draw border using screen background color; interior transparent like parent form.
			AStyle(7)=SS_GRAYRECT'Draw solid rectangle using screen background color.
			AStyle(8)=SS_WHITEFRAME'Draw border using window background color (default white); interior transparent.
			AStyle(9)=SS_WHITERECT'Draw solid rectangle using window background color (default white).
			AStyle(10)=SS_ETCHEDFRAME'Draw etched 3D border; interior transparent like parent form.
			AStyle(11)=SS_ETCHEDHORZ'Draw etched 3D horizontal lines; interior transparent.
			AStyle(12)=SS_ETCHEDVERT'Draw etched 3D vertical lines; interior transparent.
			AStyle(13)=SS_RIGHTJUST'With SS_BITMAP or SS_ICON: when auto-sizing, anchor bottom-right; only top/left position changes.
			AStyle(14)=SS_NOPREFIX'Do not interpret '&'; normally '&' underlines next char and '&&' is literal '&'. SS_NOPREFIX disables this.
			AStyle(15)=SS_NOTIFY'Send STN_CLICKED, STN_DBLCLK, STN_DISABLE, or STN_ENABLE to parent on click/double-click.
			AStyle(16)=SS_OWNERDRAW'Owner-draw static control; parent receives WM_DRAWITEM when repaint needed.
			AStyle(17)=SS_REALSIZEIMAGE'Do not auto-size to bitmap/icon; image larger than control is clipped.
			AStyle(18)=SS_SUNKEN'Draw sunken control.
			AStyle(19)=SS_CENTER'Center text horizontally; format before display; wrap at control width.
			AStyle(20)=SS_CENTERIMAGE'Center text vertically; when image smaller than client, fill edges with top-left pixel color.
			AStyle(21)=SS_LEFT'Left-align text; format before display; wrap at control width.
			AStyle(22)=SS_LEFTNOWORDWRAP'Left-align text; clip overflow; no word wrap.
			AStyle(23)=SS_RIGHT'Right-align text; format before display; wrap at control width.
			AStyle(24)=SS_SIMPLE'Single-line text at top-left; no wrap. Parent cannot handle WM_CTLCOLORSTATIC.
			
			ACenterImage(0)  = SS_RIGHTJUST
			ACenterImage(1)  = SS_CENTERIMAGE
			ARealSizeImage(0)= 0
			ARealSizeImage(1) = SS_REALSIZEIMAGE
			ARealSizeControl(0) = SS_REALSIZECONTROL
			ARealSizeControl(1) = 0
		This.Canvas.Ctrl    = @This
		Graphic.Ctrl = @This
		Graphic.OnChange = @GraphicChange
		FRealSizeImage   = False
		FCenterImage = True
		FPictureStyle = PictureStyle.ssBitmap
		With This
			.Child       = @This
				.RegisterClass "Picture", "Static"
				.ChildProc   = @WndProc
				Base.ExStyle     = 0
				Base.Style = WS_CHILD Or WS_EX_LAYERED Or SS_NOTIFY Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize)) Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize)) Or AStyle(abs_(FPictureStyle))
				BackColor       = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = GetSysColor(COLOR_BTNFACE)
				.OnHandleIsAllocated = @HandleIsAllocated
				WLet(FClassAncestor, "Static")
			WLet(FClassName, "Picture")
			FTabIndex          = -1
			.Width       = 80
			.Height      = 60
			.ShowCaption = False
		End With
	End Constructor
	Private Destructor Picture
	End Destructor
End Namespace


