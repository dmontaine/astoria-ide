'###############################################################################
'#  Graphics.bi                                                                 #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TGraphics.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "Object.bi"

'Namespace My.Sys.Drawing
Namespace Colors
	#define clScrollBar           GetSysColor(COLOR_SCROLLBAR)
	#define clBackground          GetSysColor(COLOR_BACKGROUND)
	#define clActiveCaption       GetSysColor(COLOR_ACTIVECAPTION)
	#define clInactiveCaption     GetSysColor(COLOR_INACTIVECAPTION)
	#define clMenu                GetSysColor(COLOR_MENU)
	#define clWindow              GetSysColor(COLOR_WINDOW)
	#define clWindowFrame         GetSysColor(COLOR_WINDOWFRAME)
	#define clMenuText            GetSysColor(COLOR_MENUTEXT)
	#define clWindowText          GetSysColor(COLOR_WINDOWTEXT)
	#define clCaptionText         GetSysColor(COLOR_CAPTIONTEXT)
	#define clActiveBorder        GetSysColor(COLOR_ACTIVEBORDER)
	#define clInactiveBorder      GetSysColor(COLOR_INACTIVEBORDER)
	#define clAppWorkSpace        GetSysColor(COLOR_APPWORKSPACE)
	#define clHighlight           GetSysColor(COLOR_HIGHLIGHT)
	#define clHighlightText       GetSysColor(COLOR_HIGHLIGHTTEXT)
	#define clBtnFace             GetSysColor(COLOR_BTNFACE)
	#define clBtnShadow           GetSysColor(COLOR_BTNSHADOW)
	#define clGrayText            GetSysColor(COLOR_GRAYTEXT)
	#define clBtnText             GetSysColor(COLOR_BTNTEXT)
	#define clInactiveCaptionText GetSysColor(COLOR_INACTIVECAPTIONTEXT)
	#define clBtnHighlight        GetSysColor(COLOR_BTNHIGHLIGHT)
	#define cl3DDkShadow          GetSysColor(COLOR_3DDKSHADOW)
	#define cl3DLight             GetSysColor(COLOR_3DLIGHT)
	#define clInfoText            GetSysColor(COLOR_INFOTEXT)
	#define clInfoBk              GetSysColor(COLOR_INFOBK)

#define clAliceBlue                &HFFF8F0   '   RGB(240, 248, 255)   'Alice Blue
#define clAntiqueWhite             &HD7EBFA   '   RGB(250, 235, 215)   'Antique White
#define clAqua                     &HFFFF00   '   RGB(0, 255, 255)   'Aqua
#define clAquamarine               &HD4FF7F   '   RGB(127, 255, 212)   'Aquamarine
#define clAzure                    &HFFFFF0   '   RGB(240, 255, 255)   'Azure
#define clBeige                    &HDCF5F5   '   RGB(245, 245, 220)   'Beige
#define clBisque                   &HC4E4FF   '   RGB(255, 228, 196)   'Bisque
#define clBlack                    &H000000   '   RGB(0, 0, 0)   'Black
#define clBlanchedAlmond           &HCDEBFF   '   RGB(255, 235, 205)   'Blanched Almond
#define clBlue                     &HFF0000   '   RGB(0, 0, 255)   'Blue
#define clBlueViolet               &HE22B8A   '   RGB(138, 43, 226)   'Blue Violet
#define clBrown                    &H2A2AA5   '   RGB(165, 42, 42)   'Brown
#define clBurlyWood                &H87B8DE   '   RGB(222, 184, 135)   'Burly Wood
#define clCadetBlue                &HA09E5F   '   RGB(95, 158, 160)   'Cadet Blue
#define clChartreuse               &H00FF7F   '   RGB(127, 255, 0)   'Chartreuse
#define clChocolate                &H1E69D2   '   RGB(210, 105, 30)   'Chocolate
#define clCoral                    &H507FFF   '   RGB(255, 127, 80)   'Coral
#define clCornflowerBlue           &HED9564   '   RGB(100, 149, 237)   'Cornflower Blue
#define clCornsilk                 &HDCF8FF   '   RGB(255, 248, 220)   'Cornsilk
#define clCrimson                  &H3C14DC   '   RGB(220, 20, 60)   'Crimson
#define clCyan                     &HFFFF00   '   RGB(0, 255, 255)   'Cyan
#define clDarkBlue                 &H8B0000   '   RGB(0, 0, 139)   'Dark Blue
#define clDarkCyan                 &H8B8B00   '   RGB(0, 139, 139)   'Dark Cyan
#define clDarkGoldenrod            &H0B86B8   '   RGB(184, 134, 11)   'Dark Goldenrod
#define clDarkGray                 &HA9A9A9   '   RGB(169, 169, 169)   'Dark Gray
#define clDarkGreen                &H006400   '   RGB(0, 100, 0)   'Dark Green
#define clDarkKhaki                &H6BB7BD   '   RGB(189, 183, 107)   'Dark Khaki
#define clDarkMagenta              &H8B008B   '   RGB(139, 0, 139)   'Dark Magenta
#define clDarkOliveGreen           &H2F6B55   '   RGB(85, 107, 47)   'Dark Olive Green
#define clDarkOrange               &H008CFF   '   RGB(255, 140, 0)   'Dark Orange
#define clDarkOrchid               &HCC3299   '   RGB(153, 50, 204)   'Dark Orchid
#define clDarkRed                  &H00008B   '   RGB(139, 0, 0)   'Dark Red
#define clDarkSalmon               &H7A96E9   '   RGB(233, 150, 122)   'Dark Salmon
#define clDarkSeaGreen             &H8FBC8F   '   RGB(143, 188, 143)   'Dark Sea Green
#define clDarkSlateBlue            &H8B3D48   '   RGB(72, 61, 139)   'Dark Slate Blue
#define clDarkSlateGray            &H4F4F2F   '   RGB(47, 79, 79)   'Dark Slate Gray
#define clDarkTurquoise            &HD1CE00   '   RGB(0, 206, 209)   'Dark Turquoise
#define clDarkViolet               &HD30094   '   RGB(148, 0, 211)   'Dark Violet
#define clDeepPink                 &H9314FF   '   RGB(255, 20, 147)   'Deep Pink
#define clDeepSkyBlue              &HFFBF00   '   RGB(0, 191, 255)   'Deep Sky Blue
#define clDefault                  &H20000000
#define clDimGray                  &H696969   '   RGB(105, 105, 105)   'Dim Gray
#define clDkGray                   &H808080
#define clDodgerBlue               &HFF901E   '   RGB(30, 144, 255)   'Dodger Blue
#define clFireBrick                &H2222B2   '   RGB(178, 34, 34)   'Fire Brick
#define clFloralWhite              &HF0FAFF   '   RGB(255, 250, 240)   'Floral White
#define clForestGreen              &H228B22   '   RGB(34, 139, 34)   'Forest Green
#define clFuchsia                  &HFF00FF   '   RGB(255, 0, 255)   'Fuchsia
#define clGainsboro                &HDCDCDC   '   RGB(220, 220, 220)   'Gainsboro
#define clGhostWhite               &HFFF8F8   '   RGB(248, 248, 255)   'Ghost White
#define clGold                     &H00D7FF   '   RGB(255, 215, 0)   'Gold
#define clGoldenrod                &H20A5DA   '   RGB(218, 165, 32)   'Goldenrod
#define clGray                     &H808080   '   RGB(128, 128, 128)   'Gray
#define clGreen                    &H008000   '   RGB(0, 128, 0)   'Green
#define clGreenYellow              &H2FFFAD   '   RGB(173, 255, 47)   'Green Yellow
#define clHoneydew                 &HF0FFF0   '   RGB(240, 255, 240)   'Honeydew
#define clHotPink                  &HB469FF   '   RGB(255, 105, 180)   'Hot Pink
#define clIndianRed                &H5C5CCD   '   RGB(205, 92, 92)   'Indian Red
#define clIndigo                   &H82004B   '   RGB(75, 0, 130)   'Indigo
#define clIvory                    &HF0FFFF   '   RGB(255, 255, 240)   'Ivory
#define clKhaki                    &H8CE6F0   '   RGB(240, 230, 140)   'Khaki
#define clLavender                 &HFAE6E6   '   RGB(230, 230, 250)   'Lavender
#define clLavenderBlush            &HF5F0FF   '   RGB(255, 240, 245)   'Lavender Blush
#define clLawnGreen                &H00FC7C   '   RGB(124, 252, 0)   'Lawn Green
#define clLemonChiffon             &HCDFAFF   '   RGB(255, 250, 205)   'Lemon Chiffon
#define clLightBlue                &HE6D8AD   '   RGB(173, 216, 230)   'Light Blue
#define clLightCoral               &H8080F0   '   RGB(240, 128, 128)   'Light Coral
#define clLightCyan                &HFFFFE0   '   RGB(224, 255, 255)   'Light Cyan
#define clLightGoldenrodYellow     &HD2FAFA   '   RGB(250, 250, 210)   'Light Goldenrod Yellow
#define clLightGreen               &H90EE90   '   RGB(144, 238, 144)   'Light Green
#define clLightGrey                &HD3D3D3   '   RGB(211, 211, 211)   'Light Grey
#define clLightPink                &HC1B6FF   '   RGB(255, 182, 193)   'Light Pink
#define clLightSalmon              &H7AA0FF   '   RGB(255, 160, 122)   'Light Salmon
#define clLightSeaGreen            &HAAB220   '   RGB(32, 178, 170)   'Light Sea Green
#define clLightSkyBlue             &HFACE87   '   RGB(135, 206, 250)   'Light Sky Blue
#define clLightSlateGray           &H998877   '   RGB(119, 136, 153)   'Light Slate Gray
#define clLightSteelBlue           &HDEC4B0   '   RGB(176, 196, 222)   'Light Steel Blue
#define clLightYellow              &HE0FFFF   '   RGB(255, 255, 224)   'Light Yellow
#define clLime                     &H00FF00   '   RGB(0, 255, 0)   'Lime
#define clLimeGreen                &H32CD32   '   RGB(50, 205, 50)   'Lime Green
#define clLinen                    &HE6F0FA   '   RGB(250, 240, 230)   'Linen
#define clLtGray                   &HC0C0C0
#define clMagenta                  &HFF00FF   '   RGB(255, 0, 255)   'Magenta
#define clMaroon                   &H000080   '   RGB(128, 0, 0)   'Maroon
#define clMediumAquamarine         &HAACD66   '   RGB(102, 205, 170)   'Medium Aquamarine
#define clMediumBlue               &HCD0000   '   RGB(0, 0, 205)   'Medium Blue
#define clMediumOrchid             &HD355BA   '   RGB(186, 85, 211)   'Medium Orchid
#define clMediumPurple             &HDB7093   '   RGB(147, 112, 219)   'Medium Purple
#define clMediumSeaGreen           &H71B33C   '   RGB(60, 179, 113)   'Medium Sea Green
#define clMediumSlateBlue          &HEE687B   '   RGB(123, 104, 238)   'Medium Slate Blue
#define clMediumSpringGreen        &H9AFA00   '   RGB(0, 250, 154)   'Medium Spring Green
#define clMediumTurquoise          &HCCD148   '   RGB(72, 209, 204)   'Medium Turquoise
#define clMediumVioletRed          &H8515C7   '   RGB(199, 21, 133)   'Medium Violet Red
#define clMidnightBlue             &H701919   '   RGB(25, 25, 112)   'Midnight Blue
#define clMintCream                &HFAFFF5   '   RGB(245, 255, 250)   'Mint Cream
#define clMistyRose                &HE1E4FF   '   RGB(255, 228, 225)   'Misty Rose
#define clMoccasin                 &HB5E4FF   '   RGB(255, 228, 181)   'Moccasin
#define clNavajoWhite              &HADDEFF   '   RGB(255, 222, 173)   'Navajo White
#define clNavy                     &H800000   '   RGB(0, 0, 128)   'Navy
#define clNone                     &H1FFFFFFF
#define clOldLace                  &HE6F5FD   '   RGB(253, 245, 230)   'Old Lace
#define clOlive                    &H008080   '   RGB(128, 128, 0)   'Olive
#define clOliveDrab                &H238E6B   '   RGB(107, 142, 35)   'Olive Drab
#define clOrange                   &H00A5FF   '   RGB(255, 165, 0)   'Orange
#define clOrangeRed                &H0045FF   '   RGB(255, 69, 0)   'Orange Red
#define clOrchid                   &HD670DA   '   RGB(218, 112, 214)   'Orchid
#define clPaleGoldenrod            &HAAE8EE   '   RGB(238, 232, 170)   'Pale Goldenrod
#define clPaleGreen                &H98FB98   '   RGB(152, 251, 152)   'Pale Green
#define clPaleTurquoise            &HEEEEAF   '   RGB(175, 238, 238)   'Pale Turquoise
#define clPaleVioletRed            &H9370DB   '   RGB(219, 112, 147)   'Pale Violet Red
#define clPapayaWhip               &HD5EFFF   '   RGB(255, 239, 213)   'Papaya Whip
#define clPeachPuff                &HB9DAFF   '   RGB(255, 218, 185)   'Peach Puff
#define clPeru                     &H3F85CD   '   RGB(205, 133, 63)   'Peru
#define clPink                     &HCBC0FF   '   RGB(255, 192, 203)   'Pink
#define clPlum                     &HDDA0DD   '   RGB(221, 160, 221)   'Plum
#define clPowderBlue               &HE6E0B0   '   RGB(176, 224, 230)   'Powder Blue
#define clPurple                   &H800080   '   RGB(128, 0, 128)   'Purple
#define clRed                      &H0000FF   '   RGB(255, 0, 0)   'Red
#define clRosyBrown                &H8F8FBC   '   RGB(188, 143, 143)   'Rosy Brown
#define clRoyalBlue                &HE16941   '   RGB(65, 105, 225)   'Royal Blue
#define clSaddleBrown              &H13458B   '   RGB(139, 69, 19)   'Saddle Brown
#define clSalmon                   &H7280FA   '   RGB(250, 128, 114)   'Salmon
#define clSandyBrown               &H60A4F4   '   RGB(244, 164, 96)   'Sandy Brown
#define clSeaGreen                 &H578B2E   '   RGB(46, 139, 87)   'Sea Green
#define clSeashell                 &HEEF5FF   '   RGB(255, 245, 238)   'Seashell
#define clSienna                   &H2D52A0   '   RGB(160, 82, 45)   'Sienna
#define clSilver                   &HC0C0C0   '   RGB(192, 192, 192)   'Silver
#define clSkyBlue                  &HEBCE87   '   RGB(135, 206, 235)   'Sky Blue
#define clSlateBlue                &HCD5A6A   '   RGB(106, 90, 205)   'Slate Blue
#define clSlateGray                &H908070   '   RGB(112, 128, 144)   'Slate Gray
#define clSnow                     &HFAFAFF   '   RGB(255, 250, 250)   'Snow
#define clSpringGreen              &H7FFF00   '   RGB(0, 255, 127)   'Spring Green
#define clSteelBlue                &HB48246   '   RGB(70, 130, 180)   'Steel Blue
#define clTan                      &H8CB4D2   '   RGB(210, 180, 140)   'Tan
#define clTeal                     &H808000   '   RGB(0, 128, 128)   'Teal
#define clThistle                  &HD8BFD8   '   RGB(216, 191, 216)   'Thistle
#define clTomato                   &H4763FF   '   RGB(255, 99, 71)   'Tomato
#define clTurquoise                &HD0E040   '   RGB(64, 224, 208)   'Turquoise
#define clViolet                   &HEE82EE   '   RGB(238, 130, 238)   'Violet
#define clWheat                    &HB3DEF5   '   RGB(245, 222, 179)   'Wheat
#define clWhite                    &HFFFFFF   '   RGB(255, 255, 255)   'White
#define clWhiteSmoke               &HF5F5F5   '   RGB(245, 245, 245)   'White Smoke
#define clYellow                   &H00FFFF   '   RGB(255, 255, 0)   'Yellow
#define clYellowGreen              &H32CD9A   '   RGB(154, 205, 50)   'Yellow Green
End Namespace

Declare Function ColorToRGB(FColor As Integer) As Integer
Declare Function RGBAToBGR(FColor As UInteger) As Integer
Declare Function IsDarkColor(lColor As Long) As Boolean
Declare Function ShiftColor(clrFirst As Long, clrSecond As Long, lAlpha As Long) As Long
Declare Function RGBtoARGB(RGBColor As ULong, Opacity As Long) As ULong
Declare Function BGRToRGBA(FColor As UInteger) As UInteger
Declare Function GetRed(FColor As Long) As Integer
Declare Function GetGreen(FColor As Long) As Integer
Declare Function GetBlue(FColor As Long) As Integer
#define RGBA_R( c ) ( CUInt( c ) Shr 16 And 255 )
#define RGBA_G( c ) ( CUInt( c ) Shr  8 And 255 )
#define RGBA_B( c ) ( CUInt( c )        And 255 )
#define RGBA_A( c ) ( CUInt( c ) Shr 24         )


'End Namespace

#include once "Pen.bi"
#include once "Brush.bi"
#include once "Icon.bi"
#include once "Cursor.bi"
#include once "Bitmap.bi"
#include once "Font.bi"

	#include once "Graphics.bas"

