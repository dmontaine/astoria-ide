#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/CommandButton.bi"

Using My.Sys.Forms

Type D6Child Extends Form
	Declare Static Sub Apply_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Constructor
	Dim As Label lblPrompt
	Dim As TextBox txtValue
	Dim As CommandButton cmdApply
End Type

Constructor D6Child
	With This
		.Name = "D6Child" : .Text = "D6 child dialog"
		.Designer = @This : .SetBounds 0, 0, 430, 190
	End With
	With lblPrompt
		.Name = "lblPrompt" : .Text = "Value returned to the main form:"
		.Designer = @This : .Parent = @This : .SetBounds 20, 20, 280, 20
	End With
	With txtValue
		.Name = "txtValue" : .Text = ""
		.Designer = @This : .Parent = @This : .SetBounds 20, 48, 380, 25
	End With
	With cmdApply
		.Name = "cmdApply" : .Text = "Return value"
		.Designer = @This : .Parent = @This : .SetBounds 275, 105, 125, 32
		.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Apply_Click)
	End With
End Constructor

Sub D6Child.Apply_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim As D6Child Ptr child = Cast(D6Child Ptr, Sender.Designer)
	Dim As String returnedValue = child->txtValue.Text
	child->txtValue.Text = returnedValue & "-child"
	child->ModalResult = ModalResults.OK
	child->CloseForm
End Sub
