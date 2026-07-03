'#########################################################
'#  PathUtils.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "PathUtils.bi"

Function GetShortFileName(ByRef FileName As WString, ByRef FilePath As WString) As UString
	If StartsWith(FileName, GetFolderName(FilePath)) Then
		Return Mid(FileName, Len(GetFolderName(FilePath)) + 1)
	Else
		Return FileName
	End If
End Function

Function GetFullPathInSystem(ByRef Path As WString) As UString
	If InStr(Path, ":") > 0 OrElse Path = "" Then
		Return Path
	Else
		Dim As WString * MAX_PATH fullPath
		Dim As WString Ptr lpFilePart
		If SearchPath(NULL, Path, ".exe", MAX_PATH - 1, @fullPath, 0) = 0 Then
			
		End If
		Return fullPath
	End If
End Function

Function GetFullPath(ByRef Path As WString, ByRef FromFile As WString) As UString
	If CInt(InStr(Path, ":") > 0) OrElse CInt(StartsWith(Path, "/")) OrElse CInt(StartsWith(Path, "\")) Then
		If EndsWith(Path, "\..") OrElse EndsWith(Path, "/..") Then
			Return GetFolderName(GetFolderName(Path))
		Else
			Return Path
		End If
	ElseIf StartsWith(Path, "./") OrElse StartsWith(Path, ".\") Then
		If FromFile = "" Then
			If EndsWith(ExePath, "\..") OrElse EndsWith(ExePath, "/..") Then
				Return GetFolderName(GetFolderName(ExePath)) & Mid(Path, 3)
			Else
				Return ExePath & Slash & Mid(Path, 3)
			End If
		Else
			Return GetFolderName(FromFile) & Mid(Path, 3)
		End If
	ElseIf StartsWith(Path, "../") OrElse StartsWith(Path, "..\") Then
		If FromFile = "" Then
			Return GetFolderName(ExePath) & Mid(Path, 4)
		Else
			Return GetFolderName(GetFolderName(FromFile)) & Mid(Path, 4)
		End If
	Else
		If FromFile = "" Then
			Dim As UString Path_ = GetFullPathInSystem(Path)
			If Path_ <> "" Then
				Return Path_
			Else
				Return ExePath & Slash & Path
			End If
		Else
			Return GetFolderName(FromFile) & Path
		End If
	End If
End Function

Function GetFolderName(ByRef FileName As WString, WithSlash As Boolean = True) As UString
	Dim Posi As Long = InStrRev(FileName, Any "\/", Len(FileName) - 1)
	If Posi <= 0 Then Return ""
	If Not WithSlash Then Posi -= 1
	Return Left(FileName, Posi)
End Function

Function GetFileName(ByRef FileName As WString, WithExtension As Boolean = True) As UString
	Dim As Long nPos, Posi = InStrRev(FileName, Any "\/:")
	nPos = InStrRev(FileName, ".")
	If nPos < 1 OrElse nPos < Posi Then nPos = Len(FileName)
	If Posi > 0 Then
		Return IIf(WithExtension, Mid(FileName, Posi + 1), Mid(FileName, Posi + 1, nPos - Posi - 1))
	Else
		Return IIf(WithExtension, FileName, Mid(FileName, 1, nPos - 1))
	End If
End Function

Function GetBakFileName(ByRef FileName As WString) As UString
	If FileName = "" Then Return ""
	Dim As String BakDate = Format(Now, "yyyymmdd_hhmm") 'David Change ReplaceAny(__DATE_ISO__ & "_" & Time,":/\-","")
	Dim As WString * MAX_PATH iFileName
	Dim Pos1 As Long = InStrRev(FileName, ".")
	If Pos1 = 0 Then Pos1 = Len(FileName)
	If Pos1 > 0 Then
		Return ExePath + "/Temp/" + GetFileName(FileName) + "_" & BakDate & ".bak"
	Else
		Return ExePath + "/Temp/" + BakDate & ".bak"
	End If
End Function

Function GetExeFileName(ByRef FileName As WString, ByRef sLine As WString) As UString
	Dim As UString CompileWith = " " & Replace(LTrim(sLine), BackSlash, Slash)
	Dim As UString pFileName = Replace(FileName, BackSlash, Slash)
	Dim As UString ExeFileName
	Dim As String SearchChar
	Dim As Long Pos1, Pos2
	Pos1 = InStr(CompileWith, " -x ")
	If Pos1 > 0 Then
		If Mid(CompileWith, Pos1 + 4, 1) = """" Then
			SearchChar = """"
		Else
			SearchChar = " "
			Pos1 -= 1
		End If
		Pos2 = InStr(Pos1 + 5, CompileWith, SearchChar)
		If Pos2 > 0 Then
			ExeFileName = Mid(CompileWith, Pos1 + 5, Pos2 - Pos1 - 5)
		Else
			ExeFileName = Mid(CompileWith, Pos1 + 5)
		End If
		If CInt(InStr(ExeFileName, ":") = 0) AndAlso CInt(Not StartsWith(ExeFileName, Slash)) Then
			Return GetFolderName(pFileName) + ExeFileName
		Else
			Return ExeFileName
		End If
	End If
	Pos1 = InStrRev(pFileName, ".")
	If Pos1 = 0 Then Pos1 = Len(pFileName) + 1
	If Pos1 > 0 Then
			Return Left(pFileName, Pos1 - 1) & IIf(InStr(CompileWith, "-dll"), ".dll", ".exe")
	End If
End Function

Function GetOSPath(ByRef Path As WString) As UString
	Return Replace(Path, BackSlash, Slash)
End Function

Function GetRelativePath(ByRef Path As WString, ByRef FromFile As WString) As UString
	If CInt(InStr(Path, ":") > 0) OrElse CInt(StartsWith(Path, "/")) OrElse CInt(StartsWith(Path, "\")) Then
		Return GetOSPath(Path)
	ElseIf StartsWith(Path, "./") OrElse StartsWith(Path, ".\") Then
		If FromFile = "" Then
			Return GetOSPath(ExePath & "\" & Mid(Path, 3))
		Else
			Return GetOSPath(GetFolderName(FromFile) & Mid(Path, 3))
		End If
	ElseIf StartsWith(Path, "../") OrElse StartsWith(Path, "..\") Then
		Return GetOSPath(GetFolderName(GetFolderName(FromFile)) & Mid(Path, 4))
	End If
	Dim Result As UString = GetOSPath(GetFolderName(FromFile) & Path)
	If GetFolderName(FromFile) <> "" AndAlso FileExists(Result) Then
		Return Result
	Else
		Dim Result As UString = GetOSPath(ExePath & Slash & Path)
		If FileExists(Result) Then
			Return Result
		Else
			Dim As Library Ptr CtlLibrary
			For i As Integer = 0 To ControlLibraries.Count - 1
				CtlLibrary = ControlLibraries.Item(i)
				If Not CtlLibrary->Enabled Then Continue For
				Result = GetOSPath(GetFullPath(GetFullPath(CtlLibrary->IncludeFolder, CtlLibrary->Path)) & IIf(EndsWith(CtlLibrary->IncludeFolder, "\") OrElse EndsWith(CtlLibrary->IncludeFolder, "/"), "", Slash) & Path)
				If FileExists(Result) Then Return Result
			Next
			Result = GetOSPath(GetFolderName(GetFullPath(*Compiler64Path)) & "inc\" & Path)
			If FileExists(Result) Then
				Return Result
			Else
				For i As Integer = 0 To pIncludePaths->Count - 1
					Result = GetOSPath(pIncludePaths->Item(i) & IIf(EndsWith(pIncludePaths->Item(i), "\") OrElse EndsWith(pIncludePaths->Item(i), "/"), "", Slash) & Path)
					If FileExists(Result) Then Return Result
				Next
				Return GetOSPath(Path)
			End If
		End If
	End If
End Function

Function GetRelative(ByRef FileName As WString, ByRef FromFile As WString) As UString
	If StartsWith(FileName, FromFile) Then
		Dim As UString Path = Mid(FileName, Len(FromFile) + 1)
		If StartsWith(Path, "\") OrElse StartsWith(Path, "/") Then Path = Mid(Path, 2)
		Return Path
	Else Return FileName
	End If
End Function

