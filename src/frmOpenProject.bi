'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/OpenFileControl.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Panel.bi"
	
	Using My.Sys.Forms
	
	Type frmOpenProject Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub OpenFileControl1_FileActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As OpenFileControl)
		Declare Sub OpenFileControl1_FileActivate(ByRef Sender As OpenFileControl)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub ApplyProjectsInitialDir()
		Declare Constructor
		
		Dim As OpenFileControl OpenFileControl1
		Dim As CommandButton cmdOK, cmdCancel
		Dim As Panel pnlBottom
		Dim As UString SelectedFile
	End Type
	
	Common Shared pfOpenProject As frmOpenProject Ptr
'#End Region

	#include once "frmOpenProject.frm"
