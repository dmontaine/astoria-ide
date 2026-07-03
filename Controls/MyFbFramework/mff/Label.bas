'###############################################################################
'#  Label.bi                                                                   #
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

#include once "Label.bi"

Namespace My.Sys.Forms
		Private Function Label.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "autosize": Return @FAutoSize
			Case "border": Return @FBorder
			Case "canvas": Return @Canvas
			Case "caption": Return Cast(Any Ptr, This.FText.vptr)
			Case "centerimage": Return @FCenterImage
			Case "realsizeimage": Return @FRealSizeImage
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case "text": Return Cast(Any Ptr, This.FText.vptr)
			Case "transparent": Return @FTransparent
			Case "graphic": Return Cast(Any Ptr, @This.Graphic)
			Case "wordwraps": Return @FWordWraps
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Label.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "alignment": If Value <> 0 Then This.Alignment = *Cast(AlignmentConstants Ptr, Value)
			Case "autosize": If Value <> 0 Then This.AutoSize = QBoolean(Value)
			Case "border": If Value <> 0 Then This.Border = *Cast(LabelBorder Ptr, Value)
			Case "caption": If Value <> 0 Then This.Caption = *Cast(WString Ptr, Value)
			Case "centerimage": If Value <> 0 Then This.CenterImage = QBoolean(Value)
			Case "realsizeimage": If Value <> 0 Then This.RealSizeImage = QBoolean(Value)
			Case "style": If Value <> 0 Then This.Style = *Cast(LabelStyle Ptr, Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case "text": If Value <> 0 Then This.Text = *Cast(WString Ptr, Value)
			Case "transparent": If Value <> 0 Then This.Transparent = QBoolean(Value)
			Case "graphic": This.Graphic = QWString(Value)
			Case "wordwraps": This.WordWraps = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property Label.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property Label.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property Label.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property Label.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property Label.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property Label.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property Label.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property Label.Transparent(Value As Boolean)
		FTransparent = Value
			ChangeExStyle WS_EX_TRANSPARENT, Value
	End Property
	
	Private Property Label.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property Label.Text(ByRef Value As WString)
			If FTransparent Then Visible = False
		Base.Text = Value
			If FTransparent Then Visible = True
		SetAutoSize
	End Property
	
	Private Property Label.Border As LabelBorder
		Return FBorder
	End Property
	
	Private Sub Label.ChangeLabelStyle
		If Style <> lsText Then
				Base.Style = WS_CHILD Or SS_NOTIFY Or ABorder(abs_(FBorder)) Or AStyle(abs_(FStyle)) Or AWordWraps(abs_(FWordWraps)) Or ARealSizeImage(abs_(FRealSizeImage)) Or ACenterImage(abs_(FCenterImage))
		Else
				Base.Style = WS_CHILD Or SS_NOTIFY Or ABorder(abs_(FBorder)) Or AStyle(abs_(FStyle)) Or AWordWraps(abs_(FWordWraps)) Or AAlignment(abs_(FAlignment)) Or ACenterImage(abs_(FCenterImage))
		End If
		RecreateWnd
	End Sub
	
	Private Sub Label.CalculateSize(ByRef Size As My.Sys.Drawing.Size)
		Size.Width = This.Width
		Size.Height = This.Height
		If CBool(Font.Orientation = 0) AndAlso FAutoSize Then
				If FHandle Then
					Dim Sz As ..Size
					Dim As HDC Dc = GetDC(Handle)
					If Dc > 0 Then
						Dim As .HANDLE PrevFont = SelectObject(Dc, Cast(HFONT, SendMessage(FHandle, WM_GETFONT, 0, 0)))
						GetTextExtentPoint32(Dc, FText.vptr, Len(FText), @Sz)
						Size.Width = Sz.cx
						Size.Height = Sz.cy
						SelectObject(Dc, PrevFont)
					End If
				End If
		End If
	End Sub
	
	Private Sub Label.SetAutoSize
		If FAutoSize Then
			Dim Size As My.Sys.Drawing.Size
			CalculateSize Size
			SetBounds This.Left, This.Top, Size.Width, Size.Height
		End If
	End Sub
	
	Private Property Label.Border(Value As LabelBorder)
		If Value <> FBorder Then
			FBorder = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.Style As LabelStyle
		Return FStyle
	End Property
	
	Private Property Label.Style(Value As LabelStyle)
		If Value <> FStyle Then
			FStyle = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.RealSizeImage As Boolean
		Return FRealSizeImage
	End Property
	
	Private Property Label.RealSizeImage(Value As Boolean)
		If Value <> FRealSizeImage Then
			FRealSizeImage = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.CenterImage As Boolean
		Return FCenterImage
	End Property
	
	Private Property Label.CenterImage(Value As Boolean)
		If Value <> FCenterImage Then
			FCenterImage = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.Alignment As AlignmentConstants
		Return FAlignment
	End Property
	
	Private Property Label.Alignment(Value As AlignmentConstants)
		If Value <> FAlignment Then
			FAlignment = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property Label.AutoSize(Value As Boolean)
		If Value <> FAutoSize Then
			FAutoSize = Value
			SetAutoSize
		End If
	End Property
	
	Private Property Label.WordWraps As Boolean
		Return FWordWraps
	End Property
	
	Private Property Label.WordWraps(Value As Boolean)
		If Value <> FWordWraps Then
			FWordWraps = Value
				ChangeLabelStyle
		End If
	End Property
	
	Private Sub Label.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					Select Case ImageType
					Case IMAGE_BITMAP
						QLabel(.Ctrl->Child).Style = lsBitmap
						QLabel(.Ctrl->Child).Perform(BM_SETIMAGE, ImageType, CInt(Sender.Bitmap.Handle))
						QLabel(.Ctrl->Child).RecreateWnd
					Case IMAGE_ICON
						QLabel(.Ctrl->Child).Style = lsIcon
						QLabel(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
						QLabel(.Ctrl->Child).RecreateWnd
					Case IMAGE_CURSOR
						QLabel(.Ctrl->Child).Style = lsCursor
						QLabel(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(Sender.Icon.Handle))
						QLabel(.Ctrl->Child).RecreateWnd
					Case IMAGE_ENHMETAFILE
						QLabel(.Ctrl->Child).Style = lsEmf
						QLabel(.Ctrl->Child).Perform(BM_SETIMAGE,ImageType,CInt(0))
						QLabel(.Ctrl->Child).RecreateWnd
					End Select
			End If
		End With
	End Sub
	
		Private Sub Label.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QLabel(Sender.Child)
					.Perform(STM_SETIMAGE, .Graphic.ImageType, CInt(.Graphic.Image))
					.SetAutoSize
				End With
			End If
		End Sub
		
		Private Sub Label.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub Label.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_CTLCOLOR
				Static As HDC Dc
				Dc = Cast(HDC,Message.wParam)
				SetBkMode Dc, Transparent
				SetTextColor Dc, Font.Color
				If Not FTransparent Then
					SetBkColor Dc, This.BackColor
					SetBkMode Dc, OPAQUE
				Else
					Message.Result = Cast(LRESULT, GetStockObject(NULL_BRUSH))
				End If
			Case CM_COMMAND
				'If Message.wParamHi = STN_CLICKED Then
				'	If OnClick Then OnClick(*Designer, This)
				'End If
				'If Message.wParamHi = STN_DBLCLK Then
				'	If OnDblClick Then OnDblClick(*Designer, This)
				'End If
			Case WM_WINDOWPOSCHANGING
				If FAutoSize Then
					Dim Size As My.Sys.Drawing.Size
					CalculateSize Size
					Cast(WINDOWPOS Ptr, Message.lParam)->cx = Size.Width
					Cast(WINDOWPOS Ptr, Message.lParam)->cy = Size.Height
				End If
				If FTransparent Then
					SetWindowPos FHandle, 0, 0, 0, 0, 0, SWP_NOZORDER Or SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOSENDCHANGING Or SWP_FRAMECHANGED
				End If
			Case WM_SIZE
				InvalidateRect(Handle,NULL,True)
			Case CM_DRAWITEM
				Dim As DRAWITEMSTRUCT Ptr diStruct
				Dim As ..Rect R
				Dim As HDC Dc
				diStruct = Cast(DRAWITEMSTRUCT Ptr, Message.lParam)
				R = Cast(..Rect, diStruct->rcItem)
				Dc = diStruct->hDC
				If OnDraw Then
					OnDraw(*Designer, This, *Cast(Rect Ptr, @R), Dc)
				Else
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator Label.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor Label
			AStyle(0)           = 0
			AStyle(1)           = SS_BITMAP
			AStyle(2)           = SS_ICON
			AStyle(3)           = SS_ICON
			AStyle(4)           = SS_ENHMETAFILE
			AStyle(5)           = SS_OWNERDRAW
			AAlignment(0)       = SS_LEFT
			AAlignment(1)       = SS_CENTER
			AAlignment(2)       = SS_RIGHT
			ABorder(0)          = 0
			ABorder(1)          = SS_SIMPLE
			ABorder(2)          = SS_SUNKEN
			ACenterImage(0)     = SS_RIGHTJUST
			ACenterImage(1)     = SS_CENTERIMAGE
			ARealSizeImage(0)   = 0
			ARealSizeImage(1)   = SS_REALSIZEIMAGE
			AWordWraps(0)       = SS_ENDELLIPSIS
			AWordWraps(1)       = 0
		Graphic.Ctrl = @This
		Graphic.OnChange = @GraphicChange
		FRealSizeImage   = 1
		FWordWraps       = True
		FAlignment       = 0
		FTabIndex        = -1
		With This
			.Child       = @This
				.RegisterClass "Label", "Static"
				.ChildProc        = @WndProc
				Base.ExStyle      = 0 'WS_EX_TRANSPARENT
				ChangeLabelStyle
				.BackColor        = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
				.DoubleBuffered   = True
				.OnHandleIsAllocated = @HandleIsAllocated
				WLet(FClassAncestor, "Static")
			WLet(FClassName, "Label")
			.Width       = 90
			.Height      = ScaleY(Max(8, Font.Size) /72*96+6)  'Chinese vs English point size vs pixels: size 8 = 5pt = (5/72)*96 ~= 6px
		End With
	End Constructor
	
	Private Destructor Label
	End Destructor
End Namespace

