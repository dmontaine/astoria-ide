'#########################################################
'#  Localization.bi                                      #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

Declare Function MS cdecl(ByRef V As WString, ...) As UString
Declare Function HK(Key As String, Default As String = "", WithSpace As Boolean = False) As String
Declare Function MP(ByRef V As WString) ByRef As WString
Declare Function MLCompilerFun(ByRef V As WString) ByRef As WString
Declare Function MC(ByRef V As WString) ByRef As WString

