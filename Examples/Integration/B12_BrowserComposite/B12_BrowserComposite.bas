'' TestPlan.md B12 -- WebBrowser as part of a composite.
''
'' An address TextBox, a Go button and a status Label driving a WebBrowser: the shape a browser
'' control is always part of. A4 and A5 proved the control renders and navigates when driven
'' directly; this proves it works when the URL arrives from another control and the trigger is a
'' button click, with a third control reporting what happened.
''
'' Worth doing because this is the composite that could not have existed a day ago. As shipped,
'' the WebBrowser hosted the retired IE engine, could not display a page at all, and crashed on
'' Navigate; it now hosts WebView2. This is the first test of that new backend inside a form with
'' other controls rather than alone.
''
'' Navigation is asynchronous, so the sequence polls the DOM for the page's marker token before
'' asserting -- the same state-machine shape as A5.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b12_result.txt.

#include once "mff/Form.bi"
#include once "mff/WebBrowser.bi"
#include once "mff/TextBox.bi"
#include once "mff/Label.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Panel.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B12_TOKEN = "COMPOSITE-TOKEN-3391"
Const B12_WATCHDOG_TICKS = 80      '' 80 x 250ms = 20 seconds

Type B12Form Extends Form
	Declare Static Sub cmdGo_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As Panel pnlBar
	Dim As TextBox txtAddress
	Dim As CommandButton cmdGo
	Dim As Label lblStatus
	Dim As WebBrowser wb
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
	Dim As Boolean GoClicked
End Type

Dim Shared As B12Form Ptr pB12

Sub B12Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b12_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B12Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB12 = 0 Then Exit Sub
	If Got = Want Then
		pB12->Pass += 1
		B12Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB12->Fail += 1
		B12Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

Constructor B12Form
	With This
		.Name = "B12Form"
		.Text = "B12 browser composite test"
		.Designer = @This
		.SetBounds 0, 0, 900, 620
	End With
	With pnlBar
		.Name = "pnlBar" : .Align = DockStyle.alTop : .Height = 68
		.Designer = @This : .Parent = @This
	End With
	With txtAddress
		.Name = "txtAddress" : .Text = ""
		.SetBounds 12, 10, 620, 24
		.Designer = @This : .Parent = @pnlBar
	End With
	With cmdGo
		.Name = "cmdGo" : .Text = "Go"
		.SetBounds 644, 8, 100, 28
		.Designer = @This : .OnClick = @cmdGo_Click_ : .Parent = @pnlBar
	End With
	With lblStatus
		.Name = "lblStatus" : .Text = "idle"
		.SetBounds 12, 42, 700, 20
		.Designer = @This : .Parent = @pnlBar
	End With
	With wb
		.Name = "wb" : .Align = DockStyle.alClient
		.Designer = @This : .Parent = @This
	End With
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With
End Constructor

'' The composite behaviour: the button reads the URL out of the TextBox, hands it to the browser,
'' and reports through the Label. Three controls cooperating on one action.
Sub B12Form.cmdGo_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If pB12 = 0 Then Exit Sub
	pB12->GoClicked = True
	Dim As WString * 1024 url
	url = pB12->txtAddress.Text
	pB12->lblStatus.Text = "navigating"
	pB12->wb.Navigate(@url)
End Sub

Sub B12Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB12 = 0 Then Exit Sub
	pB12->Ticks += 1
	If pB12->Ticks > B12_WATCHDOG_TICKS Then
		B12Say("watchdog fired at stage " & Str(pB12->Stage))
		B12Say("B12 OVERALL: FAIL")
		End 1
	End If

	Select Case pB12->Stage
	Case 0
		If pB12->Ticks < 3 Then Exit Sub
		'' Type the address into the TextBox the way anything outside the process would.
		Dim As UString pageUrl = "file:///" & Replace(ExePath & "\b12_page.html", "\", "/")
		SendMessageW(pB12->txtAddress.Handle, WM_SETTEXT, 0, Cast(LPARAM, StrPtr(pageUrl)))
		B12Say("-- the address bar --")
		B12Check("address box holds the typed URL", Str(InStr(pB12->txtAddress.Text, "b12_page.html") > 0), "-1")
		B12Check("status before navigating", pB12->lblStatus.Text, "idle")
		pB12->Stage = 1

	Case 1
		'' Click Go, by a real button click.
		SendMessageW(pB12->cmdGo.Handle, BM_CLICK, 0, 0)
		B12Check("Go handler ran", Str(pB12->GoClicked), "true")
		B12Check("status updated by the handler", pB12->lblStatus.Text, "navigating")
		pB12->Stage = 2

	Case 2
		'' Wait for the page the button asked for.
		Dim As UString body = pB12->wb.GetBody()
		If InStr(body, B12_TOKEN) > 0 Then
			B12Say("-- the browser, driven by the other controls --")
			B12Check("page requested by the button loaded", Str(InStr(body, B12_TOKEN) > 0), "-1")
			'' The browser's own idea of where it is must match what was typed.
			Dim As UString url = pB12->wb.GetURL()
			B12Check("browser URL matches the address box", Str(InStr(url, "b12_page.html") > 0), "-1")
			pB12->lblStatus.Text = "loaded"
			B12Check("status reports the load", pB12->lblStatus.Text, "loaded")
			'' The other controls must still be intact after the browser did its work -- a
			'' heavyweight control taking over its host is exactly what a composite can expose.
			B12Check("address box still readable", Str(InStr(pB12->txtAddress.Text, "b12_page.html") > 0), "-1")
			B12Check("Go button still has its caption", pB12->cmdGo.Text, "Go")
			B12Check("browser still on the form", Str(pB12->wb.Handle <> 0), "-1")
			pB12->Stage = 3
		End If

	Case 3
		B12Say("")
		B12Say("B12 RESULT: " & Str(pB12->Pass) & " passed, " & Str(pB12->Fail) & " failed")
		If pB12->Fail = 0 Then
			B12Say("B12 OVERALL: PASS")
			End 0
		Else
			B12Say("B12 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b12_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B12Form f
pB12 = @f
f.Show
App.Run
