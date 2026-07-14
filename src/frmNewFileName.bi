'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/Panel.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/TreeView.bi"

	Using My.Sys.Forms

	Type frmNewFileName Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor

		Dim As CommandButton cmdOK, cmdCancel
		Dim As Label lblName
		Dim As TextBox txtName
		Dim As Panel pnlBottom, pnlFileName
		'' Set by the caller before ShowModal -- Prompt is the label text (e.g. "New
		'' Module Name:"), DefaultName is the pre-filled/pre-selected suggested name.
		'' TargetNode is the tree node the chosen name must not collide with (checked
		'' the same way AddFromTemplate's own numeric-suffix loop already does);
		'' TargetExt is the extension that'll be appended to whatever the user types --
		'' tree node text always includes it (e.g. "Module2.bas"/"Module2.bas*"), so the
		'' collision check needs it too, even though the textbox itself is name-only.
		Dim As UString Prompt
		Dim As UString DefaultName
		Dim As UString TargetExt
		Dim As TreeNode Ptr TargetNode
		Dim As UString SelectedName
	End Type

	Common Shared pfNewFileName As frmNewFileName Ptr
'#End Region

	#include once "frmNewFileName.frm"
