'################################################################################
'#  BitmapType.bi                                                               #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TBitmap.bi                                                                 #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Updated and added cross-platform                                            #
'#  by Xusinboy Bekchanov (2018-2019)                                           #
'################################################################################

#include once "Object.bi"
#include once "Graphics.bi"
		#inclib "gdiplus"
		#include once "win/gdiplus-c.bi"

Namespace My.Sys.Drawing
	#define QBitmapType(__Ptr__) (*Cast(BitmapType Ptr,__Ptr__))
	
	'Is an object used to work with images defined by pixel data (Windows, Linux, Web).
	Private Type BitmapType Extends My.Sys.Object
	Private:
		FWidth       As ULong
		FHeight      As ULong
			FDevice      As HDC
		FTransparent As Boolean
		FLoadFlag(2) As Integer
		FResName As WString Ptr
		Declare Sub Create
	Public:
			Declare Virtual Function ReadProperty(PropertyName As String) As Any Ptr
			Declare Virtual Function WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		Graphic      As Any Ptr
			Handle       As HBITMAP
			pImage As GpImage Ptr
		Brush        As My.Sys.Drawing.Brush
		Pen          As My.Sys.Drawing.Pen
		Tag          As Any Ptr
		Declare Property Width As Integer
		Declare Property Width(Value As Integer)
		Declare Property Height As Integer
		Declare Property Height(Value As Integer)
		Declare Property Transparency As Boolean
		Declare Property Transparency(Value As Boolean)
		Declare Function LoadFromFile(ByRef File As WString, cxDesired As Integer = 0, cyDesired As Integer = 0, iMaskColor As Integer = 0) As Boolean
		Declare Function SaveToFile(ByRef File As WString) As Boolean
			Declare Function LoadFromHICON(IcoHandle As HICON) As Boolean
			Declare Function LoadFromScreen(x As Double, y As Double, iWidth As Double, iHeight As Double, iHandle As HWND = 0) As Boolean
		Declare Function LoadFromResourceName(ResName As String, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0, iMaskColor As Integer = 0) As Boolean
		Declare Function LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
		Declare Function ToString() ByRef As WString
		Declare Sub Clear
		Declare Sub Free
		Declare Operator Cast As Any Ptr
		Declare Operator Let(ByRef Value As WString)
			Declare Operator Let(Value As HBITMAP)
			Declare Operator Let(Value As HICON)
		Declare Constructor
		Declare Destructor
		Changed As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As BitmapType)
	End Type
End Namespace

	#include once "Bitmap.bas"

