'################################################################################
'#  Brush.bi                                                                    #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TBrush.bi                                                                  #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Modified by Xusinboy Bekchanov (2018-2019), Liu XiaLin (2020)               #
'################################################################################

#include once "Object.bi"

	Dim Shared As COLORREF darkBkColorTitle = BGR(10, 10, 10)
	Dim Shared As COLORREF darkBkColorMenu = BGR(41, 41, 41) 
	Dim Shared As COLORREF darkBkColorGreen = BGR(55, 166, 96)
	Dim Shared As COLORREF darkBkColorBlue = BGR(89, 143, 236)
	Dim Shared As COLORREF darkBkColor = &H303030
	Dim Shared As COLORREF darkBkColorDark = &H414141
	Dim Shared As COLORREF darkHlBkColor = &h626262
	Dim Shared As COLORREF darkTextColor = BGR(255, 255, 255) 
	
	' ugly colors for illustration purposes
	Dim Shared As HBRUSH g_brItemBackground
	Dim Shared As HBRUSH g_brItemBackgroundHot
	Dim Shared As HBRUSH g_brItemBackgroundSelected
	Dim Shared As HBRUSH hbrBkgnd, hbrHlBkgnd, hbrBkgndMenu
	Dim Shared As HTHEME g_menuTheme = 0

Namespace My.Sys.Drawing
		Private Enum BrushStyles
			bsSolid   = BS_SOLID
			bsClear   = BS_NULL
			bsHatch   = BS_HATCHED
			bsPattern = BS_PATTERN
		End Enum
		
		Private Enum HatchStyles
			hsHorizontal = HS_HORIZONTAL
			hsVertical   = HS_VERTICAL
			hsFDiagonal  = HS_FDIAGONAL
			hsDiagonal   = HS_BDIAGONAL
			hsCross      = HS_CROSS
			hsDiagCross  = HS_DIAGCROSS
		End Enum
	
	'Defines objects used to fill the interiors of graphical shapes such as rectangles, ellipses, pies, polygons, and paths (Windows only).
	Private Type Brush Extends My.Sys.Object
	Private:
		FColor       As Integer
		FStyle       As BrushStyles
		FHatchStyle  As HatchStyles
			FHandle      As HBRUSH
		Declare Sub Create
	Public:
		Parent As My.Sys.Object Ptr
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property Color As Integer
		Declare Property Color(Value As Integer)
		Declare Property Style As BrushStyles
		Declare Property Style(Value As BrushStyles)
		Declare Property HatchStyle As HatchStyles
		Declare Property HatchStyle(Value As HatchStyles)
		Declare Operator Cast As Any Ptr
			Declare Operator Let(Value As HBRUSH)
			Declare Property Handle As HBRUSH
			Declare Property Handle(Value As HBRUSH)
		OnCreate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Brush)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

	#include once "Brush.bas"

