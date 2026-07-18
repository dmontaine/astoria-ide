'' TestPlan A4, control experiment.
''
'' Same navigation, but issued from a CommandButton click -- exactly how the framework's own
'' WebBrowser example does it (Controls/Framework/examples/WebBrowser). This removes the timer
'' callback as a variable: if Navigate also fails to return here, the context is not the cause.

#include once "mff/Form.bi"
#include once "mff/WebBrowser.bi"
#include once "mff/CommandButton.bi"

Using My.Sys.Forms

Type BForm Extends Form
	Declare Static Sub cmdGo_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Constructor
	Dim As WebBrowser wb
	Dim As CommandButton cmdGo
End Type

Dim Shared As BForm Ptr pB

Sub Trace(ByRef s As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\a4_button_trace.txt" For Append As #f) = 0 Then
		Print #f, s
		Close #f
	End If
End Sub

Constructor BForm
	With This
		.Name = "BForm"
		.Text = "A4 button navigate test"
		.Designer = @This
		.SetBounds 0, 0, 900, 640
	End With
	With cmdGo
		.Name = "cmdGo"
		.Text = "Go"
		.Align = DockStyle.alTop
		.Height = 32
		.Designer = @This
		.OnClick = @cmdGo_Click_
		.Parent = @This
	End With
	With wb
		.Name = "wb"
		'' Required. The control is hosted through ATL's AtlAxWin, which decides WHICH ActiveX
		'' control to create from the host window's text. Leave it unset and the window is
		'' created with empty text, nothing is hosted, and the interface pointers stay null --
		'' so Navigate has nothing to call. The framework's own example sets this too.
		.Text = "about:blank"
		.Align = DockStyle.alClient
		.Designer = @This
		.Parent = @This
	End With
End Constructor

Sub BForm.cmdGo_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If pB = 0 Then Exit Sub
	Dim As WString * 1024 url
	url = "file:///" & Replace(ExePath & "\a4_page.html", "\", "/")
	Trace "BEFORE Navigate (button click) [" & url & "]"
	pB->wb.Navigate(@url)
	Trace "AFTER Navigate returned (button click)"
End Sub

Dim As BForm f
pB = @f
f.Show
App.Run
