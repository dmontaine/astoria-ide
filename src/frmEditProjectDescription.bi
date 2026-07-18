'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/Panel.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CheckBox.bi"

	Using My.Sys.Forms

	Type frmEditProjectDescription Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub chkAI_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Sub chkAI_Click(ByRef Sender As CheckBox)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor

		Dim As CommandButton cmdOK, cmdCancel
		Dim As Label lblInfo, lblAuthor, lblLicense, lblDescription
		Dim As TextBox txtInfo, txtAuthor, txtDescription
		Dim As ComboBoxEdit cboLicense, cboAITool
		Dim As CheckBox chkAIFriendly
		Dim As Panel pnlBottom, pnlAuthor, pnlLicense, pnlAI
		'' Caller sets before ShowModal.
		Dim As UString ProjectFolder   '' the open project's folder (trailing separator ok)
		Dim As UString DescPath        '' full path to project.astoria
		Dim As UString VfpPath         '' full path to the project's .vfp ("" = skip .vfp sync)
		'' Original AI state, to decide whether to (re)stamp the AI template on OK.
		Dim As Boolean oldAIFriendly
		Dim As UString oldAITool
	End Type

	Common Shared pfEditProjectDescription As frmEditProjectDescription Ptr
'#End Region

	#include once "frmEditProjectDescription.frm"
