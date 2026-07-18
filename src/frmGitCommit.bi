'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/Panel.bi"
	#include once "mff/TextBox.bi"

	Using My.Sys.Forms

	Type frmGitCommit Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor

		Dim As CommandButton cmdOK, cmdCancel
		Dim As Label lblPrompt
		Dim As TextBox txtMessage
		Dim As Panel pnlBottom
		'' Result: the entered commit message, trimmed ("" if cancelled/empty). Read after
		'' ShowModal returns ModalResults.OK. Multiline -- first line is the git subject.
		Dim As UString CommitMessage
	End Type

	Common Shared pfGitCommit As frmGitCommit Ptr
'#End Region

	#include once "frmGitCommit.frm"
