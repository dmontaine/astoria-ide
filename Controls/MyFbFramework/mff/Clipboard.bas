'******************************************************************************
'* ClipboardType
'* This file is part of MyFBFramework
'* Based on:
'*  TClipboard
'*  FreeBasic Windows GUI ToolKit
'*  Copyright (c) 2007-2008 Nastase Eodor
'*  nastase_eodor@yahoo.com
'* Updated and added cross-platform
'* by Xusinboy Bekchanov (2018-2019)
'******************************************************************************
#include once "Clipboard.bi"

'Provides methods to place data on and retrieve data from the system Clipboard.
Dim Shared As My.Sys.ClipboardType Clipboard
'pClipboard = @Clipboard

Namespace My.Sys
	Private Sub ClipboardType.Open
			OpenClipboard(NULL)
	End Sub
	
	Private Sub ClipboardType.Clear
			EmptyClipboard
	End Sub
	
	Private Sub ClipboardType.Close
			CloseClipboard
	End Sub
	
		Private Function ClipboardType.HasFormat(FFormat As WORD) As Boolean
			Return IsClipboardFormatAvailable(FFormat)
		End Function
	
	Private Sub ClipboardType.SetAsText(ByRef Value As WString)
			Dim pchData As WString Ptr
			Dim hClipboardData As HGLOBAL
			Dim sz As Integer
			This.Open
			This.Clear
			sz = (Len(Value) + 1) * SizeOf(WString)
			hClipboardData = GlobalAlloc(GMEM_MOVEABLE, sz)
			If hClipboardData Then
				pchData = Cast(WString Ptr, GlobalLock(hClipboardData))
				If pchData Then
					memcpy(pchData, @Value, sz)
					GlobalUnlock(hClipboardData)
				Else
					GlobalFree(hClipboardData)
				End If
				SetClipboardData(CF_UNICODETEXT, hClipboardData)
			End If
			This.Close
	End Sub
	
	Private Function ClipboardType.GetAsText ByRef As WString
			Dim hClipboardData As HANDLE
			This.Open
			hClipboardData = GetClipboardData(CF_UNICODETEXT)
			If hClipboardData <> 0 Then
				Dim pText As WString Ptr = CPtr(WString Ptr, GlobalLock(hClipboardData))
				WLet(FText, IIf(pText, *pText, WStr("")))
				GlobalUnlock(hClipboardData)
			Else
				WLet(FText, WStr(""))
			End If
			This.Close
		If FText Then Return *FText Else Return WStr("")
	End Function
	
		Private Sub ClipboardType.SetAsHandle(FFormat As WORD, Value As HANDLE)
			This.Open
			This.Clear
			SetClipboardData(FFormat, Value)
			This.Close
		End Sub
	
		Private Function ClipboardType.GetAsHandle(FFormat As WORD) As HANDLE
			This.Open
			Function = GetClipboardData(FFormat)
			This.Close
		End Function
	
	Private Property ClipboardType.FormatCount As Integer
			Return CountClipboardFormats
	End Property
	
	Private Property ClipboardType.FormatCount(Value As Integer)
	End Property
	
	Private Property ClipboardType.Format ByRef As WString
		Dim s As String = Space(255)
			Dim i As Integer, IFormat As UINT
			i = GetClipboardFormatName(IFormat, s, 255)
			If i > 0 Then
				FFormat = Cast(WString Ptr, _Reallocate(FFormat, (i + 1) * SizeOf(WString)))
				*FFormat = ..Left(s, i)
			End If
		If FFormat > 0 Then Return *FFormat Else Return WStr("")
	End Property
	
	Private Property ClipboardType.Format(ByRef Value As WString)
		WLet(FFormat, Value)
			RegisterClipboardFormat(FFormat)
	End Property
	
	Private Constructor ClipboardType
	End Constructor
	
	Private Destructor ClipboardType
		If FText Then _Deallocate( FText)
		If FFormat Then _Deallocate(FFormat)
	End Destructor
End Namespace