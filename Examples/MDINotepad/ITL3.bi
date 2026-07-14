#pragma once
' ITL3 ITaskbarList3
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

Type ITL3
Private : 'Private variables
hWndForm As HWND
mInit As Long
tl3 As ITaskbarList3 Ptr
Public :
'Constructor and destructor
Declare Constructor
Declare Destructor
'Public functions - class methods
Declare Function SetState(tbpFlags As TBPFLAG) As HRESULT
Declare Function SetValue(ullCompleted As ULONGLONG, ullTotal As ULONGLONG) As HRESULT
Declare Sub Initial(ByVal nVal As HWND)
'Public functions - class properties
Declare Property WndForm() As HWND
Declare Property WndForm(ByVal nVal As HWND)
End Type

#ifndef __USE_MAKE__
#include once "ITL3.bas"
#endif
