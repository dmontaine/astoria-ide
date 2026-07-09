'#########################################################
'#  Localization.bas                                     #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "Localization.bi"

Function MS cdecl(ByRef V As WString, ...) As UString
	Dim As UString Result = V
	Dim args As Cva_List
	Cva_Start(args, V)
	For i As Integer = 1 To InStrCount(V, "$")
		Result = Replace(Result, "$" & Trim(Str(i)), * (Cva_Arg(args, WString Ptr)))
	Next
	MS = Result
	Cva_End(args)
End Function

Function HK(Key As String, Default As String, WithSpace As Boolean) As String
	Dim As String HotKey = HotKeys.Get(Key, Default)
	If HotKey = "" Then
		Return ""
	ElseIf WithSpace Then
		Return " (" & HotKey & ")"
	Else
		Return !"\t" & HotKey
	End If
End Function

