'###############################################################################
'#  Splitter.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TSplitter.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "Control.bi"

Namespace My.Sys.Forms
	#define QSplitter(__Ptr__) (*Cast(Splitter Ptr, __Ptr__))
	
	Private Enum SplitterAlignmentConstants
		alNone
		alLeft
		alRight
		alTop
		alBottom
	End Enum
	
	'`Splitter` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`Splitter` - Represents a splitter control that enables the user to resize docked controls (Windows, Linux).
	Private Type Splitter Extends Control
	Private:
		FOldParentProc  As Any Ptr
			Declare Static Sub ParentWndProc(ByRef Message As Message)
			Declare Static Sub WndProc(ByRef Message As Message)
	Protected:
		Declare Sub DrawTrackSplit(x As Integer, y As Integer)
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
			'Deserializes properties from persistence stream
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
			'Serializes properties to persistence stream
			Declare Function WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		'Sets minimum space required on both sides of the splitter
		MinExtra As Integer
		Declare Operator Cast As Control Ptr
		Declare Property Align As SplitterAlignmentConstants
		'Determines splitter orientation and docking behavior (Left/Right/Top/Bottom)
		Declare Property Align(Value As SplitterAlignmentConstants)
		'Allows custom splitter appearance rendering
		OnPaint As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Splitter)
		'Raised during active resizing operations
		OnMoving As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Splitter)
		'Triggered after splitter completes resizing
		OnMoved As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Splitter)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

	#include once "Splitter.bas"

