'#########################################################
'#  BuildService.bi                                      #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

Type CompileContext
	MainFileNameOnly As WString Ptr
	MainFile As WString Ptr
	LogFileName As WString Ptr
	LogFileName2 As WString Ptr
	LogText As WString Ptr
	BatFileName As WString Ptr
	fbcCommand As WString Ptr
	PipeApplicationName As WString Ptr
	PipeCommand As WString Ptr
	CompileWith As WString Ptr
	MFFPathC As WString Ptr
	ErrFileName As WString Ptr
	ErrTitle As WString Ptr
	ExeName As WString Ptr
	FirstLine As WString Ptr
	ProjectPath As WString Ptr
	FbcExe As WString Ptr
	BatchCompilationFileName As WString Ptr
	ProcessWorkDir As WString Ptr
End Type

Declare Sub CompileContextFree(ByRef ctx As CompileContext)
Declare Function Compile(Parameter As String = "", bAll As Boolean = False) As Integer

