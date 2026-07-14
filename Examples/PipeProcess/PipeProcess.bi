#pragma once
' PipeProcess - pipe handling
' Copyright (c) 2023 CM.Wang
' Freeware. Use at your own risk.

Type PipeProcess
Private : 'Private variables
	dwMode As DWORD
	hPipeErrRead As HANDLE
	hPipeErrWrite As HANDLE
	hPipeInRead As HANDLE
	hPipeInWrite As HANDLE
	hPipeOutRead As HANDLE
	hPipeOutWrite As HANDLE
	mErrorLevel As Long
	mOwner As Any Ptr = 0
	mThread As Any Ptr 'Thread ID
	mThreadAlive As Boolean = False
	stProcessInfo As PROCESS_INFORMATION
	stStartInfo As STARTUPINFO

Private : 'Private functions
	Declare Static Function ThreadPipeRead(ByVal pParam As LPVOID) As DWORD

Public : 'Constructor and destructor
	Declare Constructor
	Declare Destructor

Public : 'Public functions, class events
	OnPipeClosed As Sub(Owner As Any Ptr, ErrorLevel As Long)
	OnPipeRead As Sub(Owner As Any Ptr, DataRead As ZString, Length As Long)
Public : 'Public functions, class methods
	Declare Function PipeCreate(Owner As Any Ptr, cmd As WString, msrtn As WString) As WINBOOL
	Declare Function PipeWrite(a As String) As Long
	Declare Sub PipeRead()
	Declare Function PipeClosed() As WINBOOL
Public : 'Public functions, class properties
End Type

#ifndef __USE_MAKE__
	#include once "PipeProcess.bas"
#endif
