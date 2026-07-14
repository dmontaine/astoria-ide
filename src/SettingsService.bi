'#########################################################
'#  SettingsService.bi                                   #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

Declare Function GetBundledCompilerFolder() As UString
Declare Function GetBundledCompilerExe() As UString
Declare Sub SetBundledCompilerPath()
Declare Sub ResolveFbcExePath(ByRef FbcExe As WString Ptr, CompilerTool As ToolType Ptr, ByRef fbcCommand As WString Ptr)
Declare Sub LoadSettingsIni()
Declare Sub LoadSettings
Declare Sub LoadLanguageTexts
Declare Sub SaveMRU

