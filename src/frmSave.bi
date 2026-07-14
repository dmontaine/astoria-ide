'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ListControl.bi"
	#include once "mff/Label.bi"
	#include once "mff/CommandButton.bi"

	Using My.Sys.Forms
	
	Type frmSave Extends Form
		Declare Static Sub cmdYes_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdYes_Click(ByRef Sender As Control)
		Declare Static Sub cmdNo_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdNo_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub Form_Show_(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As ListControl lstFiles
		Dim As Label lblMessage
		Dim As CommandButton cmdYes, cmdNo, cmdCancel
		Dim As List SelectedItems
	End Type

	Common Shared pfSave As frmSave Ptr
	
	#include once "frmSave.frm"

