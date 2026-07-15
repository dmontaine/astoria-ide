'###############################################################################
'#  MsgBoxForm.bi                                                              #
'#  Dark-mode-aware replacement for the native MessageBox                     #
'###############################################################################

#pragma once

#include once "Form.bi"
#include once "Label.bi"
#include once "CommandButton.bi"

Namespace My.Sys.Forms
	Private Enum MsgBoxIcon
		mbxIconNone
		mbxIconInfo
		mbxIconWarning
		mbxIconQuestion
		mbxIconError
	End Enum

	Private Enum MsgBoxButtons
		mbxOK
		mbxOKCancel
		mbxYesNo
		mbxYesNoCancel
	End Enum

	'A native MessageBox is a system-owned "#32770" dialog with no supported
	'way to theme it from the outside - T11 spent a long session methodically
	'ruling out every documented Win32/DWM angle (WM_ERASEBKGND coverage, the
	'right NM_CUSTOMDRAW stage, DWM backdrop material, extended frame) against
	'a persistent light band that survived all of them, with no tool left in
	'this environment to identify what was actually painting it. This dialog
	'sidesteps the problem entirely: it's a plain Form, which already dark-
	'themes correctly (see PROJECT_STATUS.md T12), so nothing new to theme.
	'See MsgBox in Application.bas for the call site.
	Private Type MsgBoxForm Extends Form
	Private:
		FIcon As My.Sys.Drawing.Icon
		FIconX As Integer
		FIconY As Integer
		FMessage As Label
		FButton0 As CommandButton
		FButton1 As CommandButton
		FButton2 As CommandButton
		FButtonResult(0 To 2) As ModalResults
		Declare Sub HandleButtonClick(Index As Integer)
		Declare Static Sub FormPaint_(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
		Declare Static Sub Button0Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Button1Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Button2Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Public:
		Declare Function Execute(ByRef MsgStr As WString, ByRef Caption As WString, Icon As MsgBoxIcon, Buttons As MsgBoxButtons, OwnerForm As Form Ptr = 0) As ModalResults
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#include once "MsgBoxForm.bas"
