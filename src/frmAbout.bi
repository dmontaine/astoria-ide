'#########################################################
'#  frmAbout.bi                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/CommandButton.bi"
#include once "mff/ImageBox.bi"
#include once "mff/Picture.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmAbout Extends Form
		Declare Static Sub Form_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub BtnClose_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub BtnClose_Click(ByRef Sender As Control)
		Declare Constructor
		Dim As Label Label1, Label2, Label3, Label31, Label311, Label3111, Label31111, Label311111, Label3111111
		Dim As ImageBox lblImage
		Dim As CommandButton BtnClose
	End Type

	Common Shared As frmAbout Ptr pfAbout
'#End Region

	#include once "frmAbout.frm"


