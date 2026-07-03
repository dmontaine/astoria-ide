'#########################################################
'#  Localization.bas                                     #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "Localization.bi"

Function MS cdecl(ByRef V As WString, ...) As UString
	Dim As UString Result
	Dim As Boolean bFind
	If LCase(App.CurLanguage) <> "english" Then
		Dim As Integer tIndex = mlKeys.IndexOfKey(V)
		If tIndex >= 0 Then
			Result = mlKeys.Item(tIndex)->Text
			bFind = True
		End If
	End If
	If Not bFind Then Result = V
	Dim args As Cva_List
	Cva_Start(args, V)
	For i As Integer = 1 To Min(InStrCount(V, "$"), InStrCount(Result, "$"))
		Result = Replace(Result, "$" & Trim(Str(i)), * (Cva_Arg(args, WString Ptr)))
	Next
	MS = Result
	Cva_End(args)
End Function

Function MLCompilerFun(ByRef V As WString) ByRef As WString
	If LCase(App.CurLanguage) = "english" Then Return V
	Dim As Integer tIndex = mlCompiler.IndexOfKey(V) ' For improve the speed
	If tIndex >= 0 Then Return mlCompiler.Item(tIndex)->Text Else Return V
End Function

'David Change For the comment of control's Properties
Function MC(ByRef V As WString) ByRef As WString
	If (Not gLocalProperties) Then Return V
	Dim As WString * 2048 TempV = ""
	Dim As Integer Posi = InStrRev(V, ".")
	TempV = IIf(Posi > 0, Mid(V, Posi + 1), V)
	Dim As Integer tIndex = mcKeys.IndexOfKey(TempV) 'David Changed
	If tIndex >= 0 Then Return mcKeys.Item(tIndex)->Text
	Return V
End Function

Function MP(ByRef V As WString) ByRef As WString
	If (Not gLocalProperties) OrElse LCase(App.CurLanguage) = "english" Then Return V
	Dim As Integer tIndex = -1, tIndex2 = -1
	If InStr(V,".") Then
		Static As WString * 2048 TempWstr = ""
		Dim As WString Ptr LineParts(Any)
		Split(V, ".", LineParts())
		For k As Integer = 0 To UBound(LineParts)
			tIndex = mpKeys.IndexOfKey(*LineParts(k))
			If tIndex >=0 Then
				If k = 0 Then
					TempWstr = mpKeys.Item(tIndex)->Text
				Else
					TempWstr &= "." & mpKeys.Item(tIndex)->Text
				End If
			Else
				If k=0 Then
					TempWstr = *LineParts(k)
				Else
					TempWstr &= "." & *LineParts(k)
				End If
			End If
			_Deallocate(LineParts(k))
		Next
		Erase LineParts
		If TempWstr = "" Then
			Return V
		Else
			Return TempWstr
		End If
	Else
		tIndex = mpKeys.IndexOfKey(V)
		If tIndex >= 0 Then
			If mpKeys.Item(tIndex)->Text = "" Then
				Return V
			Else
				Return mpKeys.Item(tIndex)->Text
			End If
		Else
			Return V
		End If
	End If
	Return V
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

