'################################################################################
'#  SysUtils.bi                                                                 #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   SysUtils.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#  Modified by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                       #
'################################################################################


		#ifndef UNICODE
			#define UNICODE
		#endif
	#include once "windows.bi"

	#include once "win/wincrypt.bi"
	#include once "Win/CommCtrl.bi"
	#include once "Win/CommDlg.bi"
	#include once "Win/RichEdit.bi"
	#include once "win/iphlpapi.bi"
	#define Instance GetModuleHandle(NULL)
#include once "UString.bi"
#include once "Integer.bi"

	#define PublicOrPrivate Public
	#define __EXPORT__ Export

'#define In ,
'#macro Each(iter, arr)
'	index As Integer = LBound(arr) To UBound(arr)
'	#define iter arr(index)
'#endmacro

#define Each(iter, col) __index__ As Integer = 0 To col.Count - 1: Dim As Typeof(col.Item(__index__)) iter = col.Item(__index__)

#define Me This

#ifndef _L
		#define _L Print __LINE__, __FILE__, __FUNCTION__, GetErrorString(GetLastError, , True):
#endif

Const HELP_SETPOPUP_POS = &Hd

#macro RedefineClassKeyword
	#undef Class
	#define Class Type
	#define __StartOfClassBody__ End Type
	#macro __EndOfClassBody__
		Scope
		#undef Class
		#macro Class
			Scope
			#undef Class
			#define Class Type
		#endmacro
	#endmacro
#endmacro

'#DEFINE __AUTOMATE_CREATE_CHILDS__

	#define CM_NOTIFYCHILD 39998
	#define CM_CHANGEIMAGE 39999
	#define CM_CTLCOLOR    40000
	#define CM_COMMAND     40001
	#define CM_NOTIFY      40002
	#define CM_HSCROLL     40003
	#define CM_VSCROLL     40004
	#define CM_MEASUREITEM 40005
	#define CM_DRAWITEM    40006
	#define CM_HELPCONTEXT 40007
	#define CM_CANCELMODE  40008
	#define CM_HELP        40010
	#define CM_NEEDTEXT    40011
	#define CM_CREATE      40012
	
	'Dim Shared As Message Message
	
	Declare Function EnumThreadWindowsProc(FWindow As HWND,LData As LPARAM) As BOOL
	
	Declare Function MainHandle As HWND

Namespace ClassContainer
	Private Type ClassType
	Protected:
		FClassName As WString Ptr
		FClassAncestor As WString Ptr
	Public:
		ClassProc As Any Ptr
		Declare Property ClassName ByRef As WString
		Declare Property ClassName(ByRef Value As WString)
		Declare Property ClassAncestor ByRef As WString
		Declare Property ClassAncestor(ByRef Value As WString)
		Declare Constructor
		Declare Destructor
	End Type
	
	Dim Classes()  As ClassType
	
	Declare Function FindClass(ByRef ClassName As WString) As Integer
	
	Declare Sub StoreClass(ByRef ClassName As WString, ByRef ClassAncestor As WString, ClassProc As Any Ptr)
	
	Declare Function GetClassProc Overload(ByRef ClassName As WString) As Any Ptr
	
		Declare Function GetClassProc(FWindow As HWND) As Any Ptr
		
		Declare Function GetClassNameOf(FWindow As HWND) As String
		
		Declare Sub Finalization
End Namespace

Using ClassContainer


Declare Function ErrDescription(Code As Integer) ByRef As WString

Declare Function GetErrorString(ByVal Code As UInteger, ByVal MaxLen  As UShort = 1024, WithCode As Boolean = False) As UString

	#include once "SysUtils.bas"

