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

#include once "Component.bi"

Namespace Cursors
	#define crDefault     0
	#define crArrow       LoadCursor(0,IDC_ARROW)
	#define crAppStarting LoadCursor(0,IDC_APPSTARTING)
	#define crCross       LoadCursor(0,IDC_CROSS)
	#define crIBeam       LoadCursor(0,IDC_IBEAM)
	#define crIcon        LoadCursor(0,IDC_ICON)
	#define crNo          LoadCursor(0,IDC_NO)
	#define crSize        LoadCursor(0,IDC_SIZE)
	#define crSizeAll     LoadCursor(0,IDC_SIZEALL)
	#define crSizeNESW    LoadCursor(0,IDC_SIZENESW)
	#define crSizeNS      LoadCursor(0,IDC_SIZENS)
	#define crSizeNWSE    LoadCursor(0,IDC_SIZENWSE)
	#define crSizeWE      LoadCursor(0,IDC_SIZEWE)
	#define crUpArrow     LoadCursor(0,IDC_UPARROW)
	#define crWait        LoadCursor(0,IDC_WAIT)
	#define crHand        LoadCursor(0,IDC_HAND)
	#define crHelp        LoadCursor(0,IDC_HELP)
	#define crDrag        LoadCursor(GetModuleHandle(NULL),"DRAG")
	#define crMultiDrag   LoadCursor(GetModuleHandle(NULL),"MULTIDRAG")
	#define crHandPoint   LoadCursor(GetModuleHandle(NULL),"HANDPOINT")
	#define crSQLWait     LoadCursor(GetModuleHandle(NULL),"SQLWAIT")
	#define crHSplit      LoadCursor(GetModuleHandle(NULL),"HSPLIT")
	#define crVSplit      LoadCursor(GetModuleHandle(NULL),"VSPLIT")
	#define crNoDrop      LoadCursor(GetModuleHandle(NULL),"NODROP")
End Namespace

Namespace My.Sys.Drawing
	#define QCursor(__Ptr__) (*Cast(Cursor Ptr,__Ptr__))
	
	'Represents the image used to paint the mouse pointer (Windows, Linux).
	Private Type Cursor Extends My.Sys.Object
	Private:
		FWidth     As Integer
		FHeight    As Integer
		FHotSpotX  As Integer
		FHotSpotY  As Integer
		FResName As WString Ptr
		Declare Sub Create
	Public:
			Declare Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Ctrl 			As My.Sys.ComponentModel.Component Ptr
		Graphic    		As Any Ptr
			Handle		As HCURSOR
		Declare Property Width As Integer
		Declare Property Width(Value As Integer)
		Declare Property Height As Integer
		Declare Property Height(Value As Integer)
		Declare Property HotSpotX As Integer
		Declare Property HotSpotX(Value As Integer)
		Declare Property HotSpotY As Integer
		Declare Property HotSpotY(Value As Integer)
		Declare Function LoadFromFile(ByRef File As WString, cx As Integer = 0, cy As Integer = 0) As Boolean
		Declare Function SaveToFile(ByRef File As WString) As Boolean
		Declare Function LoadFromResourceName(ByRef ResName As WString, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
		Declare Function LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
			Declare Function ToBitmap() As HBITMAP
		Declare Function ToString() ByRef As WString
		Declare Operator Cast As Any Ptr
		Declare Operator Let(Value As Integer)
			Declare Operator Let(Value As HCURSOR)
		Declare Operator Let(ByRef Value As WString)
		Declare Operator Let(Value As Cursor)
		Declare Constructor
		Declare Destructor
		Changed As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Cursor)
	End Type
End Namespace

	#include once "Cursor.bas"

