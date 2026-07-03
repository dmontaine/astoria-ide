'###############################################################################
'#  Icon.bi                                                                    #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TIcon.bi                                                                  #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################
#include once "Icon.bi"

Namespace My.Sys.Drawing
		Private Function Icon.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "handle": Return @Handle
			Case "height": Return @FHeight
			Case "width": Return @FWidth
			Case "resname": Return FResName
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Icon.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value <> 0 Then
				Select Case LCase(PropertyName)
				Case "height": This.Height = QInteger(Value)
				Case "width": This.Width = QInteger(Value)
				Case "resname": This.ResName = QWString(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property Icon.ResName ByRef As WString
		If FResName > 0 Then Return *FResName Else Return WStr("")
	End Property
	
		Private Property Icon.ResName(ByRef Value As WString)
			WLet(FResName, Value)
		End Property
	
	Private Function Icon.ToString() ByRef As WString
		If FResName > 0 Then Return *FResName Else Return WStr("")
	End Function
	
		Private Property Icon.Width As Integer
			Return FWidth
		End Property
	
	Private Property Icon.Width(Value As Integer)
	End Property
	
		Private Property Icon.Height As Integer
			Return FWidth
		End Property
	
	Private Property Icon.Height(Value As Integer)
	End Property
	
		Private Function Icon.ToBitmap() As HBITMAP
			Dim As HWND desktop = GetDesktopWindow()
			If (desktop = NULL) Then
				Return NULL
			End If
			
			Dim As HDC screen_dev = GetDC(desktop)
			If (screen_dev = NULL) Then
				Return NULL
			End If
			
			' Create a compatible DC
			Dim As HDC dst_hdc = CreateCompatibleDC(screen_dev)
			If (dst_hdc = NULL) Then
				ReleaseDC(desktop, screen_dev)
				Return NULL
			End If
			
			' Create a new bitmap of icon size
			Dim As HBITMAP bmp = CreateCompatibleBitmap(screen_dev, 16, 16)
			If (bmp = NULL) Then
				DeleteDC(dst_hdc)
				ReleaseDC(desktop, screen_dev)
				Return NULL
			End If
			
			'Select it into the compatible DC
			Dim As HBITMAP old_dst_bmp = Cast(HBITMAP, SelectObject(dst_hdc, bmp))
			If (old_dst_bmp = NULL) Then
				DeleteObject(bmp)
				Return NULL
			End If
			
			' Fill the background of the compatible DC with the given colour
			'SetBkColor(dst_hdc, RGB(255, 255, 255))
			'ExtTextOut(dst_hdc, 0, 0, ETO_OPAQUE, @rect, NULL, 0, NULL)
			
			' Draw the icon into the compatible DC
			DrawIconEx(dst_hdc, 0, 0, Handle, 16, 16, 0, GetSysColorBrush( COLOR_MENU ), DI_NORMAL)
			
			' Restore settings
			SelectObject(dst_hdc, old_dst_bmp)
			DeleteDC(dst_hdc)
			ReleaseDC(desktop, screen_dev)
			'DestroyIcon(hIcon)
			Return bmp
		End Function
	
	Private Function Icon.LoadFromFile(ByRef File As WString, cx As Integer = 0, cy As Integer = 0) As Boolean
			Dim As ICONINFO ICIF
			Dim As BITMAP BMP
			If Handle Then DestroyIcon(Handle)
			Handle = LoadImage(0, File, IMAGE_ICON, cx, cy, LR_LOADFROMFILE Or LR_LOADTRANSPARENT)
			If Handle = 0 Then Return False
			GetIconInfo(Handle, @ICIF)
			GetObject(ICIF.hbmColor, SizeOf(BMP), @BMP)
			FWidth  = BMP.bmWidth
			FHeight = BMP.bmHeight
			DeleteObject(ICIF.hbmColor)
			DeleteObject(ICIF.hbmMask)
		If Changed Then Changed(*Designer, This)
		Return True
	End Function
	
		Private Function Icon.SaveToFile(ByRef File As WString) As Boolean
			Return False
		End Function
	
		Private Function Icon.LoadFromResourceName(ByRef ResourceName As WString, ModuleHandle As Any Ptr = 0, cx As Integer = 0, cy As Integer = 0) As Boolean
				Dim As ICONINFO ICIF
				Dim As BITMAP BMP
				This.ResName = ResourceName
				Dim As Any Ptr ModuleHandle_ = ModuleHandle: If ModuleHandle = 0 Then ModuleHandle_ = GetModuleHandle(NULL)
				If Handle Then DestroyIcon(Handle)
				Handle = LoadImage(ModuleHandle_, ResName, IMAGE_ICON, cx, cy, LR_COPYFROMRESOURCE)
				If Handle = 0 Then Return False
				GetIconInfo(Handle, @ICIF)
				GetObject(ICIF.hbmColor, SizeOf(BMP), @BMP)
				FWidth  = BMP.bmWidth
				FHeight = BMP.bmHeight
				DeleteObject(ICIF.hbmColor)
				DeleteObject(ICIF.hbmMask)
			If Changed Then Changed(*Designer, This)
			Return True
		End Function
	
		Private Function Icon.LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cx As Integer = 0, cy As Integer = 0) As Boolean
				Dim As ICONINFO ICIF
				Dim As BITMAP BMP
				This.ResName = WStr(ResID)
				Dim As Any Ptr ModuleHandle_ = ModuleHandle: If ModuleHandle = 0 Then ModuleHandle_ = GetModuleHandle(NULL)
				If Handle <> 0 Then DestroyIcon(Handle)
				Handle = LoadImage(ModuleHandle_, MAKEINTRESOURCE(ResID), IMAGE_ICON, cx, cy, LR_COPYFROMRESOURCE)
				If Handle = 0 Then Return False
				GetIconInfo(Handle, @ICIF)
				GetObject(ICIF.hbmColor, SizeOf(BMP), @BMP)
				FWidth  = BMP.bmWidth
				FHeight = BMP.bmHeight
				DeleteObject(ICIF.hbmColor)
				DeleteObject(ICIF.hbmMask)
			If Changed Then Changed(*Designer, This)
			Return True
		End Function
	
	Private Operator Icon.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Operator Icon.Cast As WString Ptr
		Return This.FResName
	End Operator
	
	Private Operator Icon.Let(ByRef Value As WString)
			If (Not LoadFromResourceName(Value)) AndAlso (Not LoadFromResourceID(Val(Value))) Then
				LoadFromFile(Value)
			End If
		This.ResName = Value
	End Operator
	
	Private Operator Icon.Let(Value As Integer)
		LoadFromResourceID(Value)
		This.ResName = WStr(Value)
	End Operator
	
	Private Operator Icon.Let(Value As Icon)
			If Handle Then DestroyIcon(Handle)
		Handle = Value.Handle
		If Changed Then Changed(*Designer, This)
	End Operator
	
			Private Operator Icon.Let(Value As HICON)
				If Handle Then DestroyIcon(Handle)
			Handle = Value
			If Changed Then Changed(*Designer, This)
		End Operator
	
	Private Constructor Icon
		WLet(FClassName, "Icon")
	End Constructor
	
	Private Destructor Icon
		If FResName Then _Deallocate(FResName)
			If Handle Then DestroyIcon Handle
	End Destructor
End Namespace

Sub IconLoadFromFile Alias "IconLoadFromFile"(Ico As My.Sys.Drawing.Icon Ptr, ByRef File As WString, cx As Integer = 0, cy As Integer = 0) __EXPORT__
	Ico->LoadFromFile(File, cx, cy)
End Sub

