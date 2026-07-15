'###############################################################################
'#  ProgressBar.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TProgressBar.bi                                                           #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "Control.bi"

Namespace My.Sys.Forms
	#define QProgressBar(__Ptr__) (*Cast(ProgressBar Ptr,__Ptr__))
	
	Private Enum ProgressBarOrientation
		pbHorizontal, pbVertical
	End Enum
	
	'`ProgressBar` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`ProgressBar` - A progress bar is a window that an application can use to indicate the progress of a lengthy operation (Windows, Linux).
	Private Type ProgressBar Extends Control
	Private:
		FMode32      As Boolean
		FPosition    As Integer
		FMinValue    As Integer
		FMaxValue    As Integer
		FStep        As Integer
		FSmooth      As Boolean
		FMarquee     As Boolean
		FMarqueeOn   As Boolean
		FOrientation As ProgressBarOrientation
		ASmooth(2)   As Integer
		AMarquee(2)  As Integer
		FMarqueeInterval As Integer
		AOrientation(2) As Integer
			Declare Static Sub WndProc(ByRef Message As Message)
			Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
		Declare Sub SetRange(AMin As Integer, AMax As Integer)
	Public:
			'Loads configuration from persistence stream
			Declare Function ReadProperty(ByRef PropertyName As String) As Any Ptr
			'Saves configuration to persistence stream
			Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property MinValue As Integer
		'Minimum value of progress range
		Declare Property MinValue(Value As Integer)
		Declare Property MaxValue As Integer
		'Maximum value of progress range
		Declare Property MaxValue(Value As Integer)
		Declare Property Position As Integer
		'Current progress value between Min-Max
		Declare Property Position(Value As Integer)
		Declare Property StepValue As Integer
		'Increment value for StepIt method
		Declare Property StepValue(Value As Integer)
		Declare Property Smooth As Boolean
		'Enables smooth gradual filling
		Declare Property Smooth(Value As Boolean)
		Declare Property Marquee As Boolean
		'Enables indefinite progress animation mode
		Declare Property Marquee(Value As Boolean)
		Declare Property Orientation As ProgressBarOrientation
		'Display direction (Vertical/Horizontal)
		Declare Property Orientation(Value As ProgressBarOrientation)
		Declare Operator Cast As Control Ptr
		'Starts marquee animation with specified speed
		Declare Sub SetMarquee(MarqueeOn As Boolean, Interval As Integer)
		'Terminates marquee animation
		Declare Sub StopMarquee
		'Advances position by StepValue
		Declare Sub StepIt
		'Advances position by custom delta
		Declare Sub StepBy(Delta As Integer)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

	#include once "ProgressBar.bas"

