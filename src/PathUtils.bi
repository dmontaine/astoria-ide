'#########################################################
'#  PathUtils.bi                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

Declare Function GetFileName(ByRef FileName As WString, WithExtension As Boolean = True) As UString
Declare Function GetExeFileName(ByRef FileName As WString, ByRef sLine As WString) As UString
Declare Function GetBakFileName(ByRef FileName As WString) As UString
Declare Function GetShortFileName(ByRef FileName As WString, ByRef FilePath As WString) As UString
Declare Function GetFolderName(ByRef FileName As WString, WithSlash As Boolean = True) As UString
Declare Function GetOSPath(ByRef Path As WString) As UString
Declare Function GetFullPathInSystem(ByRef Path As WString) As UString
Declare Function GetFullPath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
Declare Function GetRelative(ByRef FileName As WString, ByRef FromFile As WString) As UString
Declare Function GetRelativePath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
Declare Function EnsureDirectoryExists(FolderPath As UString) As Boolean
Declare Function GetFullPathU(FolderPath As UString) As UString
Declare Function FolderExistsU(path As UString) As Boolean
Declare Function FileExistsU(path As UString) As Boolean
Declare Function GetFolderNameU(path As UString, WithSlash As Boolean = True) As UString
Declare Function GetFileNameU(path As UString, WithExtension As Boolean = True) As UString
Declare Function CanonicalWinPath(path As UString) As UString
Declare Function SanitizeIniPath(path As UString) As UString
Declare Function IsIniPathDriveAvailable(path As UString) As Boolean
Declare Function SanitizeIniCriticalPath(path As UString, defaultPath As UString) As UString
Declare Function SanitizeIniOptionalPath(path As UString) As UString
Declare Function WinOsPath(path As UString) As UString
Declare Function OsPathForDir(path As UString) As UString
Declare Function FormatMsgPath(ByRef Path As WString) As UString
Declare Function FormatMsgPathU(path As UString) As UString
Declare Function GetControlLibraryVfpPath(path As UString) As UString
Declare Function GetControlLibraryFolder(path As UString) As UString
Declare Function IsValidProjectItemName(itemName As UString) As Boolean
Declare Function IsProjectOpenFileType(ByRef FileName As WString) As Boolean
Declare Function FindProjectVfpInFolder(folder As UString) As UString
Declare Function CopyFileU(src As UString, dest As UString) As Boolean
Declare Function MakePathPortable(path As UString) As UString

