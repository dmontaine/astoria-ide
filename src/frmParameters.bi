'#########################################################
'#  frmParameters.bi                                      #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/GroupBox.bi"

Using My.Sys.Forms

Type frmParameters Extends Form
	Declare Static Sub cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Static Sub Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Static Sub Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	Declare Static Sub lblAddCompilerOption64_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Sub LoadSettings()
	Declare Constructor
	Declare Destructor
	
	Dim As GroupBox grbCompile, grbMake, grbRun, grbDebug
	Dim As CommandButton cmdOK, cmdCancel
	Dim As Label lblfbc64, lblMake1, llblMake2, lblRun, lblDebug64, lblAddCompilerOption64
	Dim As TextBox txtfbc64, txtMake1, txtMake2, txtRun, txtDebug64
	Dim As ComboBoxEdit cboCompiler64, cboMake1, cboMake2, cboRun
End Type

Common Shared pfParameters As frmParameters Ptr

	#include once "frmParameters.frm"

