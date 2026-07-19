#include once "Child.frm"

Type D6Main Extends Form
	Declare Static Sub OpenChild_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Constructor
	Dim As Label lblInput, lblResult
	Dim As TextBox txtInput
	Dim As CommandButton cmdOpenChild
End Type

Constructor D6Main
	With This
		.Name = "D6Main" : .Text = "TestPlan D6 - Multi-form debugger"
		.Designer = @This : .SetBounds 0, 0, 560, 250
	End With
	With lblInput
		.Name = "lblInput" : .Text = "Starting value:"
		.Designer = @This : .Parent = @This : .SetBounds 20, 25, 110, 20
	End With
	With txtInput
		.Name = "txtInput" : .Text = "debug-value"
		.Designer = @This : .Parent = @This : .SetBounds 135, 22, 390, 25
	End With
	With cmdOpenChild
		.Name = "cmdOpenChild" : .Text = "Open child dialog"
		.Designer = @This : .Parent = @This : .SetBounds 375, 68, 150, 32
		.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @OpenChild_Click)
	End With
	With lblResult
		.Name = "lblResult" : .Text = "Returned value: (none)"
		.Designer = @This : .Parent = @This : .SetBounds 20, 125, 505, 25
	End With
End Constructor

Sub D6Main.OpenChild_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim As D6Main Ptr owner = Cast(D6Main Ptr, Sender.Designer)
	Dim As String startingValue = owner->txtInput.Text
	Dim As D6Child child
	child.txtValue.Text = startingValue
	Dim As Integer dialogResult = child.ShowModal(*owner)
	Dim As String returnedValue = child.txtValue.Text
	If dialogResult = ModalResults.OK Then
		owner->lblResult.Text = "Returned value: " & returnedValue
	Else
		owner->lblResult.Text = "Dialog cancelled"
	End If
End Sub

Dim Shared As D6Main MainForm
MainForm.Show
App.Run
