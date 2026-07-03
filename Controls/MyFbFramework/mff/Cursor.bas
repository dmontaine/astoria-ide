'******************************************************************************
'* Cursor.bi                                                                  *
'* Authors: Nastase Eodor, Xusinboy Bekchanov                                 *
'* Based on:                                                                  *
'*  TCursor                                                                   *
'*  This file is part of FreeBasic Windows GUI ToolKit                        *
'*  Copyright (c) 2007-2008 Nastase Eodor                                     *
'*  Version 1.0.0                                                             *
'*  nastase_eodor@yahoo.com                                                   *
'* Updated and added cross-platform                                          *
'* by Xusinboy Bekchanov (2018-2019)                                         *
'******************************************************************************

#include once "Cursor.bi"
#include once "Bitmap.bi"

Namespace My.Sys.Drawing
		Private Function Cursor.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "graphic": Return @Graphic
			Case "height": Return @FHeight
			Case "hotspotx": Return @FHotSpotX
			Case "hotspoty": Return @FHotSpotY
			Case "width": Return @FWidth
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Cursor.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "height": This.Height = QInteger(Value)
				Case "hotspotx": This.HotSpotX = QInteger(Value)
				Case "hotspoty": This.HotSpotY = QInteger(Value)
				Case "width": This.Width = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property Cursor.Width As Integer
		Return FWidth
	End Property
	
	Private Property Cursor.Width(Value As Integer)
		FWidth = Value
	End Property
	
	Private Property Cursor.Height As Integer
		Return FHeight
	End Property
	
	Private Property Cursor.Height(Value As Integer)
		FHeight = Value
	End Property
	
	Private Property Cursor.HotSpotX As Integer
		Return FHotSpotX
	End Property
	
	Private Property Cursor.HotSpotX(Value As Integer)
		FHotSpotX = Value
	End Property
	
	Private Property Cursor.HotSpotY As Integer
		Return FHotSpotY
	End Property
	
	Private Property Cursor.HotSpotY(Value As Integer)
		FHotSpotY = Value
	End Property
	
		Private Function Cursor.LoadFromFile(ByRef File As WString, cx As Integer = 0, cy As Integer = 0) As Boolean
				Dim As ICONINFO ICIF
				Dim As BITMAP BMP
				If Handle Then DestroyCursor(Handle)
				Handle = LoadImage(0, File, IMAGE_CURSOR, cx, cy, LR_LOADFROMFILE)
				If Handle = 0 Then Return False
				GetIconInfo(Handle, @ICIF)
				GetObject(ICIF.hbmColor, SizeOf(BMP), @BMP)
				FWidth  = BMP.bmWidth
				FHeight = BMP.bmHeight
				FHotSpotX = ICIF.xHotspot
				FHotSpotY = ICIF.yHotspot
				DeleteObject(ICIF.hbmColor)
				DeleteObject(ICIF.hbmMask)
			If Changed Then Changed(*Designer, This)
			Return True
		End Function
	
		Private Function Cursor.SaveToFile(ByRef File As WString) As Boolean
			Return False
		End Function
	
		Private Function Cursor.LoadFromResourceName(ByRef ResName As WString, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
				Dim As ICONINFO ICIF
				Dim As BITMAP BMP
				Dim As Any Ptr ModuleHandle_ = ModuleHandle: If ModuleHandle = 0 Then ModuleHandle_ = GetModuleHandle(NULL)
				If Handle Then DestroyCursor(Handle)
				Handle = LoadImage(ModuleHandle_, ResName, IMAGE_CURSOR, cxDesired, cyDesired, LR_COPYFROMRESOURCE)
				If Handle = 0 Then Return False
	'			GetIconInfo(Handle, @ICIF)
	'			GetObject(ICIF.hbmColor,SizeOf(BMP), @BMP)
	'			FWidth  = BMP.bmWidth
	'			FHeight = BMP.bmHeight
	'			FHotSpotX = ICIF.xHotSpot
	'			FHotSpotY = ICIF.yHotSpot
	'			?DeleteObject(ICIF.hbmColor)
	'			?DeleteObject(ICIF.hbmMask)
			If Changed Then Changed(*Designer, This)
			Return True
		End Function
	
		Private Function Cursor.LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
				Dim As ICONINFO ICIF
				Dim As BITMAP BMP
				Dim As Any Ptr ModuleHandle_ = ModuleHandle: If ModuleHandle = 0 Then ModuleHandle_ = GetModuleHandle(NULL)
				If Handle Then DestroyCursor(Handle)
				Handle = LoadImage(ModuleHandle_, MAKEINTRESOURCE(ResID), IMAGE_CURSOR, cxDesired, cyDesired, LR_COPYFROMRESOURCE)
				If Handle = 0 Then Return False
				GetIconInfo(Handle,@ICIF)
				GetObject(ICIF.hbmColor,SizeOf(BMP), @BMP)
				FWidth  = BMP.bmWidth
				FHeight = BMP.bmHeight
				FHotSpotX = ICIF.xHotspot
				FHotSpotY = ICIF.yHotspot
				DeleteObject(ICIF.hbmColor)
				DeleteObject(ICIF.hbmMask)
			If Changed Then Changed(*Designer, This)
			Return True
		End Function
	
	Private Sub Cursor.Create
	End Sub
	
	Private Operator Cursor.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Operator Cursor.Let(ByRef Value As WString)
		WLet(FResName, Value)
			If (Not LoadFromResourceName(Value)) AndAlso (Not LoadFromResourceID(Val(Value))) Then
				LoadFromFile(Value)
			End If
	End Operator
	
	Private Function Cursor.ToString() ByRef As WString
		If FResName > 0 Then Return *FResName Else Return WStr("")
	End Function
	
		Private Function Cursor.ToBitmap() As HBITMAP
			Dim As BitmapType bmpType
			bmpType = Handle
			Return bmpType.Handle
		End Function
	
	Private Operator Cursor.Let(Value As Integer)
			If Handle Then DestroyCursor(Handle)
			Handle = Cast(HCURSOR, Value)
			If Ctrl AndAlso Ctrl->Handle Then SendMessage(Ctrl->Handle, WM_SETCURSOR, Cast(WPARAM, Ctrl->Handle), Cast(LPARAM, 1))
	End Operator
	
		Private Operator Cursor.Let(Value As HCURSOR)
			If Handle Then DestroyCursor(Handle)
			Handle = Value
			If Ctrl AndAlso Ctrl->Handle Then SendMessage(Ctrl->Handle, WM_SETCURSOR, Cast(WPARAM, Ctrl->Handle), Cast(LPARAM, 1))
		End Operator
	
	Private Operator Cursor.Let(Value As Cursor)
			If Handle Then DestroyCursor(Handle)
		Handle = Value.Handle
			If Ctrl AndAlso Ctrl->Handle Then SendMessage(Ctrl->Handle, WM_SETCURSOR, Cast(WPARAM, Ctrl->Handle), Cast(LPARAM, 1))
	End Operator
	
	Private Constructor Cursor
		WLet(FClassName, "Cursor")
'		#ifndef __USE_GTK__
'			Handle = LoadCursor(NULL,IDC_ARROW)
'		#endif
		If Changed Then Changed(*Designer, This)
	End Constructor
	
	Private Destructor Cursor
			If Handle <> 0 Then 
				DestroyCursor Handle
			End If
		If FResName Then _Deallocate(FResName)
	End Destructor
End Namespace

	Sub CursorLoadFromFile Alias "CursorLoadFromFile"(Cur As My.Sys.Drawing.Cursor Ptr, ByRef File As WString) __EXPORT__
		Cur->LoadFromFile(File)
	End Sub
