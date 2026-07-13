'#########################################################
'#  PathUtils.bas                                        #
'#  This file is part of AstoriaIDE                  #
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

'' Collapses ".." segments anywhere in an already-drive-letter/absolute path (e.g.
'' "C:\A\B\..\..\C" -> "C:\A\C"). GetFullPath's drive-letter branch previously only handled
'' a *trailing* "\..": a Settings.ini value with an embedded ".." (e.g. Lib64=../../astoria.dll,
'' joined onto an already-ExePath-prefixed path by a caller like frmComponents.frm) passed
'' through uncollapsed, breaking string-equality comparisons against the same file resolved via
'' GetFullPath's other, SearchPath-based branch (which Windows normalizes for free). Found via
'' the cJSON toolbox investigation, 2026-07-13.
Function CollapseDotDotSegments(ByRef path As UString) As UString
	Dim As UString s = Replace(path, UnixSlash, WindowsSlash)
	Dim segs() As UString
	If Split(s, WindowsSlash, segs()) <= 0 Then Return path
	Dim result(UBound(segs)) As UString
	Dim As Long rCount = 0
	For i As Long = 0 To UBound(segs)
		If segs(i) = ".." Then
			If rCount > 0 Then rCount -= 1
		ElseIf segs(i) <> "." AndAlso segs(i) <> "" Then
			result(rCount) = segs(i)
			rCount += 1
		End If
	Next
	Dim As UString joined = ""
	For i As Long = 0 To rCount - 1
		If i > 0 Then joined &= WindowsSlash
		joined &= result(i)
	Next
	Return joined
End Function

Function GetFullPath(ByRef Path As WString, ByRef FromFile As WString) As UString
	If CInt(InStr(Path, ":") > 0) OrElse CInt(StartsWith(Path, "/")) OrElse CInt(StartsWith(Path, "\")) Then
		If EndsWith(Path, "\..") OrElse EndsWith(Path, "/..") Then
			Return WinOsPath(GetFolderName(GetFolderName(Path)))
		Else
			Return CollapseDotDotSegments(WinOsPath(Path))
		End If
	ElseIf StartsWith(Path, "./") OrElse StartsWith(Path, ".\") Then
		If FromFile = "" Then
			If EndsWith(ExePath, "\..") OrElse EndsWith(ExePath, "/..") Then
				Return WinOsPath(GetFolderName(GetFolderName(ExePath)) & Mid(Path, 3))
			Else
				Return WinOsPath(ExePath & WindowsSlash & Mid(Path, 3))
			End If
		Else
			Return WinOsPath(GetFolderName(FromFile) & Mid(Path, 3))
		End If
	ElseIf StartsWith(Path, "../") OrElse StartsWith(Path, "..\") Then
		If FromFile = "" Then
			Return WinOsPath(GetFolderName(ExePath) & Mid(Path, 4))
		Else
			Return WinOsPath(GetFolderName(GetFolderName(FromFile)) & Mid(Path, 4))
		End If
	Else
		If FromFile = "" Then
			Dim As UString Path_ = GetFullPathInSystem(Path)
			If Path_ <> "" Then
				Return WinOsPath(Path_)
			Else
				Return WinOsPath(ExePath & WindowsSlash & Path)
			End If
		Else
			Return WinOsPath(GetFolderName(FromFile) & Path)
		End If
	End If
End Function

Function GetFolderName(ByRef FileName As WString, WithSlash As Boolean = True) As UString
	Dim Posi As Long = InStrRev(FileName, Any "\/", Len(FileName) - 1)
	If Posi <= 0 Then Return ""
	If Not WithSlash Then Posi -= 1
	Return Left(FileName, Posi)
End Function

' Canonical Windows path: normalizes to backslashes for Win32 API calls.
Function CanonicalWinPath(path As UString) As UString
	path = Trim(path, Any !" \t" + Chr(10) + Chr(13))
	If path = "" Then Return ""
	Return Replace(path, UnixSlash, WindowsSlash)
End Function

Private Function CollapseRepeatedSlashes(path As UString) As UString
	While InStr(path, "//") > 0
		path = Replace(path, "//", "/")
	Wend
	Return path
End Function

' Normalize a filesystem path read from INI (slashes, trim, collapse duplicates).
Function SanitizeIniPath(path As UString) As UString
	Return CollapseRepeatedSlashes(CanonicalWinPath(path))
End Function

' True when path is relative, UNC, or its drive root responds to GetFileAttributesW.
Function IsIniPathDriveAvailable(path As UString) As Boolean
	path = SanitizeIniPath(path)
	If path = "" Then Return True
	If Len(path) < 2 OrElse Mid(path, 2, 1) <> ":" Then Return True
	Dim As UString driveRoot = UCase(Left(path, 1)) & ":/"
	Dim As WString Ptr rootPtr
	WLet(rootPtr, driveRoot)
	Dim As DWORD attrs = GetFileAttributesW(*rootPtr)
	WDeAllocate(rootPtr)
	Return attrs <> INVALID_FILE_ATTRIBUTES
End Function

' Critical Options paths: canonicalize and fall back when the drive is unavailable.
Function SanitizeIniCriticalPath(path As UString, defaultPath As UString) As UString
	path = SanitizeIniPath(path)
	If path = "" Then Return SanitizeIniPath(defaultPath)
	If Not IsIniPathDriveAvailable(path) Then Return SanitizeIniPath(defaultPath)
	Return path
End Function

' Optional/tool/MRU paths: canonicalize; clear when the drive is unavailable.
Function SanitizeIniOptionalPath(path As UString) As UString
	path = SanitizeIniPath(path)
	If path = "" Then Return ""
	If Not IsIniPathDriveAvailable(path) Then Return ""
	Return path
End Function

Function WinOsPath(path As UString) As UString
	Return CanonicalWinPath(path)
End Function

' Win32 Dir() needs backslashes; normalize before building scan patterns.
Function OsPathForDir(path As UString) As UString
	Return CanonicalWinPath(path)
End Function

Function FormatMsgPath(ByRef Path As WString) As UString
	Dim As UString p = WinOsPath(Path)
	If p = "" Then Return ""
	Return Replace(p, "\", "\" & WChr(13, 10))
End Function

Function FormatMsgPathU(path As UString) As UString
	Dim As WString Ptr pathPtr
	WLet(pathPtr, path)
	Dim As UString result = FormatMsgPath(*pathPtr)
	WDeAllocate(pathPtr)
	Return result
End Function

' Control libraries live only under ExePath/Controls. Returns canonical "Controls/Name" for .vfp storage.
Function GetControlLibraryVfpPath(path As UString) As UString
	'' Normalize to forward slashes up front: the "/controls/" scan below is forward-WindowsSlash
	'' based, but absolute library paths arrive with backslashes (WinOsPath), which made this
	'' return "" for every already-loaded library and broke the project-open "already loaded"
	'' match (bFinded stayed false, causing duplicate library creation).
	path = Replace(Trim(path, Any !" \t" + Chr(10) + Chr(13)), "\", "/")
	If path = "" Then Return ""
	If Right(LCase(path), 4) = ".dll" Then
		path = GetFolderNameU(path, False)
	End If
	Dim As UString lower = LCase(path)
	Dim As Integer ctrlPos = InStr(lower, "/controls/")
	If ctrlPos > 0 Then
		path = Mid(path, ctrlPos + 1)
	ElseIf StartsWith(lower, "controls/") OrElse StartsWith(lower, "controls\") Then
		' already under Controls
	ElseIf InStr(path, ":") = 0 AndAlso Not StartsWith(path, "..") AndAlso InStr(path, "/") = 0 AndAlso InStr(path, "\") = 0 Then
		path = "Controls/" & path
	Else
		Return ""
	End If
	path = Replace(path, "\", "/")
	lower = LCase(path)
	While StartsWith(lower, "controls/controls/")
		path = "Controls/" & Mid(path, Len("Controls/Controls/") + 1)
		lower = LCase(path)
	Wend
	Return path
End Function

Function GetControlLibraryFolder(path As UString) As UString
	Dim As UString vfpPath = GetControlLibraryVfpPath(path)
	If vfpPath = "" Then Return ""
	Return WinOsPath(GetFullPathU(vfpPath))
End Function

Function IsValidProjectItemName(itemName As UString) As Boolean
	itemName = Trim(itemName, Any !" \t" + Chr(10) + Chr(13))
	If itemName = "" Then Return False
	If InStr(itemName, "\") > 0 OrElse InStr(itemName, "/") > 0 OrElse InStr(itemName, ":") > 0 Then Return False
	If InStr(itemName, ".") > 0 Then Return False
	Return True
End Function

Function IsProjectOpenFileType(ByRef FileName As WString) As Boolean
	Dim extPos As Integer = InStrRev(LCase(FileName), ".")
	If extPos <= 0 Then Return False
	Select Case LCase(Mid(FileName, extPos))
	Case ".bi", ".bas", ".frm"
		Return True
	Case Else
		Return False
	End Select
End Function

Function FindProjectVfpInFolder(folder As UString) As UString
	folder = OsPathForDir(folder)
	If folder = "" Then Return ""
	If Not FolderExistsU(folder) Then Return ""
	Dim As UString folderName = GetFileNameU(folder, False)
	Dim As UString preferredPath = folder & WindowsSlash & folderName & ".vfp"
	If FileExistsU(preferredPath) Then Return CanonicalWinPath(preferredPath)
	Dim As WStringList matches
	Dim As WString * MAX_PATH folderPath = folder
	Dim As WString * MAX_PATH vfpPattern = folderPath & WindowsSlash & "*.vfp"
	Dim As WString * MAX_PATH entry = Dir(vfpPattern)
	While entry <> ""
		matches.Add CanonicalWinPath(folder & WindowsSlash & entry)
		entry = Dir()
	Wend
	If matches.Count = 1 Then Return matches.Item(0)
	If matches.Count > 1 Then
		' Prefer <foldername>.vfp when multiple .vfp files exist in the same directory
		For i As Integer = 0 To matches.Count - 1
			If GetFileNameU(matches.Item(i), True) = folderName & ".vfp" Then Return matches.Item(i)
		Next
		matches.Sort
		Return matches.Item(0)
	End If
	Return ""
End Function

Function FolderExistsU(path As UString) As Boolean
	path = WinOsPath(Trim(path, Any !" \t" + Chr(10) + Chr(13)))
	If path = "" Then Return False
	Dim As WString Ptr pathPtr
	WLet(pathPtr, path)
	Dim As DWORD attrs = GetFileAttributesW(*pathPtr)
	WDeAllocate(pathPtr)
	If attrs = INVALID_FILE_ATTRIBUTES Then Return False
	Return (attrs And FILE_ATTRIBUTE_DIRECTORY) <> 0
End Function

Function FileExistsU(path As UString) As Boolean
	path = WinOsPath(Trim(path, Any !" \t" + Chr(10) + Chr(13)))
	If path = "" Then Return False
	Dim As WString Ptr pathPtr
	WLet(pathPtr, path)
	Dim As DWORD attrs = GetFileAttributesW(*pathPtr)
	WDeAllocate(pathPtr)
	If attrs = INVALID_FILE_ATTRIBUTES Then Return False
	Return (attrs And FILE_ATTRIBUTE_DIRECTORY) = 0
End Function

' A folder browse dialog always returns an absolute OS path. When that path sits inside the
' app's own install folder (e.g. picking the bundled Projects or MyFbFramework folder), storing
' it verbatim hard-codes the current install location into Settings and breaks the moment the
' app folder is moved or renamed. Return a ".\"-relative form in that case; paths genuinely
' outside ExePath (a Projects folder deliberately kept on another drive, say) are left absolute.
Function MakePathPortable(path As UString) As UString
	path = WinOsPath(Trim(path, Any !" \t" + Chr(10) + Chr(13)))
	If path = "" Then Return path
	Dim As WString Ptr pathPtr, exePtr
	WLet(pathPtr, path)
	WLet(exePtr, ExePath & WindowsSlash & WindowsSlash)
	Dim As UString shortened = GetShortFileName(*pathPtr, *exePtr)
	WDeAllocate(pathPtr)
	WDeAllocate(exePtr)
	If shortened = path Then Return path
	Return ".\" & shortened
End Function

Function CopyFileU(src As UString, dest As UString) As Boolean
	src = WinOsPath(Trim(src, Any !" \t" + Chr(10) + Chr(13)))
	dest = WinOsPath(Trim(dest, Any !" \t" + Chr(10) + Chr(13)))
	If src = "" OrElse dest = "" Then Return False
	Dim As WString Ptr srcPtr
	Dim As WString Ptr destPtr
	WLet(srcPtr, src)
	WLet(destPtr, dest)
	Dim As Boolean result = (CopyFileW(*srcPtr, *destPtr, 0) <> 0)
	WDeAllocate(srcPtr)
	WDeAllocate(destPtr)
	Return result
End Function

Function GetFolderNameU(path As UString, WithSlash As Boolean = True) As UString
	Dim As WString Ptr pathPtr
	WLet(pathPtr, WinOsPath(path))
	Dim As UString result = GetFolderName(*pathPtr, WithSlash)
	WDeAllocate(pathPtr)
	Return result
End Function

Function GetFileNameU(path As UString, WithExtension As Boolean = True) As UString
	Dim As WString Ptr pathPtr
	WLet(pathPtr, WinOsPath(path))
	Dim As UString result = GetFileName(*pathPtr, WithExtension)
	WDeAllocate(pathPtr)
	Return result
End Function

Function EnsureDirectoryExistsImpl(path As UString) As Boolean
	path = WinOsPath(Trim(path, Any !" \t" + Chr(10) + Chr(13)))
	If path = "" Then Return False
	If FolderExistsU(path) Then Return True
	Dim As WString Ptr pathPtr
	WLet(pathPtr, path)
	Dim As Long dirErr = SHCreateDirectoryExW(0, *pathPtr, 0)
	WDeAllocate(pathPtr)
	If dirErr = 0 OrElse dirErr = ERROR_ALREADY_EXISTS Then Return True
	If CreateDirectoryW(path, NULL) <> 0 Then Return True
	If GetLastError() = ERROR_ALREADY_EXISTS Then Return True
	Return FolderExistsU(path)
End Function

Function GetFullPathU(FolderPath As UString) As UString
	Dim As WString Ptr pathPtr
	WLet(pathPtr, FolderPath)
	Dim As UString result = GetFullPath(*pathPtr)
	WDeAllocate(pathPtr)
	Return result
End Function

Function EnsureDirectoryExists(FolderPath As UString) As Boolean
	Dim As UString pathSetting = Trim(FolderPath, Any !" \t" + Chr(10) + Chr(13))
	If pathSetting = "" Then Return False
	Return EnsureDirectoryExistsImpl(GetFullPathU(pathSetting))
End Function

Function GetFileName(ByRef FileName As WString, WithExtension As Boolean = True) As UString
	Dim As Long nPos, Posi = InStrRev(FileName, Any "\/:")
	Dim As Long dotPos = InStrRev(FileName, ".")
	Dim As Boolean hasExt = (dotPos > 0 AndAlso dotPos > Posi)
	nPos = IIf(hasExt, dotPos, Len(FileName))
	If Posi > 0 Then
		Return IIf(WithExtension, Mid(FileName, Posi + 1), Mid(FileName, Posi + 1, nPos - Posi - IIf(hasExt, 1, 0)))
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
	Dim As UString CompileWith = " " & Replace(LTrim(sLine), UnixSlash, WindowsSlash)
	Dim As UString pFileName = Replace(FileName, UnixSlash, WindowsSlash)
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
		If CInt(InStr(ExeFileName, ":") = 0) AndAlso CInt(Not StartsWith(ExeFileName, WindowsSlash)) Then
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
	Return Replace(Path, UnixSlash, WindowsSlash)
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
		If FromFile = "" Then
			Return WinOsPath(GetFolderName(ExePath) & Mid(Path, 4))
		Else
			Return WinOsPath(GetFolderName(GetFolderName(FromFile)) & Mid(Path, 4))
		End If
	End If
	Dim Result As UString = WinOsPath(GetFolderName(FromFile) & Path)
	If GetFolderName(FromFile) <> "" AndAlso FileExists(Result) Then
		Return Result
	Else
		Dim Result As UString = GetOSPath(ExePath & WindowsSlash & Path)
		If FileExists(Result) Then
			Return Result
		Else
			Dim As Library Ptr CtlLibrary
			For i As Integer = 0 To ControlLibraries.Count - 1
				CtlLibrary = ControlLibraries.Item(i)
				If Not CtlLibrary->Enabled Then Continue For
				Result = GetOSPath(GetFullPath(GetFullPath(CtlLibrary->IncludeFolder, CtlLibrary->Path)) & IIf(EndsWith(CtlLibrary->IncludeFolder, "\") OrElse EndsWith(CtlLibrary->IncludeFolder, "/"), "", WindowsSlash) & Path)
				If FileExists(Result) Then Return Result
			Next
			Result = GetOSPath(GetFolderName(GetFullPath(*Compiler64Path)) & "inc\" & Path)
			If FileExists(Result) Then
				Return Result
			Else
				For i As Integer = 0 To pIncludePaths->Count - 1
					Result = GetOSPath(pIncludePaths->Item(i) & IIf(EndsWith(pIncludePaths->Item(i), "\") OrElse EndsWith(pIncludePaths->Item(i), "/"), "", WindowsSlash) & Path)
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

