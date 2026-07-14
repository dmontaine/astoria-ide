#pragma once
' TimeMeter - timer
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

Type TimeMeter
Private :
tFrequency As LongInt
tStart As LongInt
tEnd As LongInt
Public :
Declare Constructor
Declare Destructor
Declare Sub Start() 'Start timing
Declare Function Passed() As Double 'Elapsed time
End Type

#ifndef __USE_MAKE__
#include once "TimeMeter.bas"
#endif
