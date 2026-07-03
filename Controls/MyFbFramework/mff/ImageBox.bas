'###############################################################################
'#  ImageBox.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TStatic.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "ImageBox.bi"

Namespace My.Sys.Forms
		Private Function ImageBox.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autosize": Return @FAutoSize
			Case "centerimage": Return @FCenterImage
			Case "realsizeimage": Return @FRealSizeImage
			Case "style": Return @FImageStyle
			Case "graphic": Return Cast(Any Ptr, @This.Graphic)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function ImageBox.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "autosize": If Value <> 0 Then This.AutoSize = QBoolean(Value)
			Case "centerimage": If Value <> 0 Then This.CenterImage = QBoolean(Value)
			Case "realsizeimage": If Value <> 0 Then This.RealSizeImage = QBoolean(Value)
			Case "style": If Value <> 0 Then This.Style = *Cast(ImageBoxStyle Ptr, Value)
			Case "graphic": This.Graphic = QWString(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property ImageBox.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property ImageBox.AutoSize(Value As Boolean)
		FAutoSize = Value
			Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FImageStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize)) Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
		RecreateWnd
	End Property
	
	Private Property ImageBox.DesignMode As Boolean
		Return FDesignMode
	End Property
	
	
	Private Property ImageBox.DesignMode(Value As Boolean)
		FDesignMode = Value
		If Value Then
		End If
	End Property
		
	Private Property ImageBox.Style As ImageBoxStyle
		Return FImageStyle
	End Property
	
	Private Property ImageBox.Style(Value As ImageBoxStyle)
		'If Value <> FImageStyle Then
			FImageStyle = Value
				Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FImageStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize)) Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
			RecreateWnd
		'End If
	End Property
	
	Private Property ImageBox.RealSizeImage As Boolean
		Return FRealSizeImage
	End Property
	
	Private Property ImageBox.RealSizeImage(Value As Boolean)
		If Value <> FRealSizeImage Then
			FRealSizeImage = Value
				Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FImageStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize))  Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
			RecreateWnd
		End If
	End Property
	
	Private Property ImageBox.CenterImage As Boolean
		Return FCenterImage
	End Property
	
	Private Property ImageBox.CenterImage(Value As Boolean)
		If Value <> FCenterImage Then
			FCenterImage = Value
				Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FImageStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize))  Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
			RecreateWnd
		End If
	End Property
	
	Private Sub ImageBox.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					Select Case ImageType
					Case 0
						QImageBox(.Ctrl->Child).Style = ImageBoxStyle.ssBitmap
						QImageBox(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Bitmap.Handle))
					Case 1
						QImageBox(.Ctrl->Child).Style = ImageBoxStyle.ssIcon
						QImageBox(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
					Case 2
						QImageBox(.Ctrl->Child).Style = ImageBoxStyle.ssCursor
						QImageBox(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
					Case 3
						QImageBox(.Ctrl->Child).Style = ImageBoxStyle.ssEmf
						QImageBox(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(0))
					End Select
			End If
		End With
	End Sub
	
		Private Sub ImageBox.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QImageBox(Sender.Child)
						.Perform(STM_SETIMAGE, .Graphic.ImageType, CInt(.Graphic.Image))
				End With
			End If
		End Sub
		
		Private Sub ImageBox.WndProc(ByRef Message As Message)
		End Sub
	
	
	Private Sub ImageBox.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_SIZE
				InvalidateRect(Handle,NULL,True)
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC,Message.wParam)
				SetBkMode Dc, TRANSPARENT
				SetTextColor Dc, This.Font.Color
				SetBkColor Dc, This.BackColor
				SetBkMode Dc, OPAQUE
'			Case CM_COMMAND
'				If Message.wParamHi = STN_CLICKED Then
'					If OnClick Then OnClick(This)
'				End If
'				If Message.wParamHi = STN_DBLCLK Then
'					If OnDblClick Then OnDblClick(This)
'				End If
			Case CM_DRAWITEM
				Dim As DRAWITEMSTRUCT Ptr diStruct
				Dim As ..Rect R
				Dim As HDC Dc
				diStruct = Cast(DRAWITEMSTRUCT Ptr, Message.lParam)
				R = Cast(..Rect, diStruct->rcItem)
				Dc = diStruct->hDC
				If OnDraw Then
					OnDraw(*Designer, This, *Cast(My.Sys.Drawing.Rect Ptr, @R), Dc)
				Else
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator ImageBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ImageBox
			AStyle(0)        = SS_BITMAP
			AStyle(1)        = SS_ICON
			AStyle(2)        = SS_ICON
			AStyle(3)        = SS_ENHMETAFILE
			AStyle(4)        = SS_OWNERDRAW
			ACenterImage(0)  = SS_RIGHTJUST
			ACenterImage(1)  = SS_CENTERIMAGE
			ARealSizeImage(0)= 0
			ARealSizeImage(1) = SS_REALSIZEIMAGE
			ARealSizeControl(0) = SS_REALSIZECONTROL
			ARealSizeControl(1) = 0
		FImageStyle = 0
		Graphic.Ctrl = @This
		Graphic.OnChange = @GraphicChange
		FRealSizeImage   = 0
		FCenterImage   = True
		With This
			.Child       = @This
			WLet(FClassName, "ImageBox")
				.RegisterClass "ImageBox", "Static"
				.ChildProc   = @WndProc
				Base.ExStyle     = 0
				Base.Style = WS_CHILD Or SS_NOTIFY Or AStyle(abs_(FImageStyle)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ARealSizeControl(abs_(FAutoSize)) Or ACenterImage(abs_(FCenterImage AndAlso Not FAutoSize))
				.BackColor       = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
				.OnHandleIsAllocated = @HandleIsAllocated
				WLet(FClassAncestor, "Static")
			.Width       = 90
			.Height      = 17
		End With
	End Constructor
	
	Private Destructor ImageBox
	End Destructor
End Namespace

