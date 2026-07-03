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

