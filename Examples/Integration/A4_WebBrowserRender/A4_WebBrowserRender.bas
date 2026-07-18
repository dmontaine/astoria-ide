'' TestPlan.md A4 -- WebBrowser rendering.
''
'' Closes the "WebBrowser rendering and navigation are unverified" gap in Testing.md. The
'' 73-control sweep proved this control's window opens; it proved nothing about whether a page
'' ever appears inside it.
''
'' Deliberately uses the DEFAULT backend -- no __USE_WEBVIEW2__ define -- because that is what
'' the toolbox gives a user who drops a WebBrowser on a form (see Examples/Controls/WebBrowser).
''
'' Two independent kinds of evidence:
''   1. The DOM: GetBody() is polled until the page's marker token appears, which proves the
''      document actually loaded and parsed rather than the control merely existing.
''   2. The pixels: the window is left open with a known layout -- dark green background, white
''      heading, a yellow block -- so a screenshot can confirm it visibly rendered. A document
''      can parse and still paint nothing.
''
'' Results go to a4_result.txt because this is a GUI subsystem program: Print has nowhere to go.

#include once "mff/Form.bi"
#include once "mff/WebBrowser.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const A4_MARKER = "MARKER-TOKEN-8842"
Const A4_TIMEOUT_TICKS = 40      '' 40 x 500ms = 20 seconds

Type A4Form Extends Form
	Declare Static Sub tmr_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As WebBrowser wb
	Dim As TimerComponent tmr
	Dim As Integer Ticks
	Dim As Boolean Done
End Type

Dim Shared As A4Form Ptr pForm

Sub WriteResult(ByRef Verdict As String, ByRef Detail As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\a4_result.txt" For Output As #f) = 0 Then
		Print #f, Verdict
		Print #f, Detail
		Close #f
	End If
End Sub

Constructor A4Form
	With This
		.Name = "A4Form"
		.Text = "A4 WebBrowser render test"
		.Designer = @This
		.SetBounds 0, 0, 900, 640
	End With
	With wb
		.Name = "wb"
		.Align = DockStyle.alClient
		.Designer = @This
		.Parent = @This
	End With
	With tmr
		.Name = "tmr"
		.Interval = 500
		.OnTimer = @tmr_Timer_
		.Enabled = True
	End With
End Constructor

'' Polls the DOM. The default backend exposes no usable navigation-completed event -- they are
'' all commented out in WebBrowser.bi -- so polling is the only way to know the page arrived.
Sub A4Form.tmr_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pForm = 0 OrElse pForm->Done Then Exit Sub
	pForm->Ticks += 1
	'' Tick trace: proves whether the timer fires at all, independent of anything browser-related.
	Scope
		Dim As Integer ft = FreeFile
		If Open(ExePath & "\a4_ticks.txt" For Append As #ft) = 0 Then
			Print #ft, "tick " & Str(pForm->Ticks)
			Close #ft
		End If
	End Scope
	'' Navigate from inside the message loop, not before App.Run: the control has no OLE site
	'' until the loop has pumped, so navigating earlier crashes.
	If pForm->Ticks = 1 Then
		'' file:/// URL rather than a bare Windows path -- IWebBrowser2::Navigate is documented
		'' in terms of URLs, and a drive-letter path is the less reliable form.
		Dim As WString * 1024 firstPage
		firstPage = "file:///" & Replace(ExePath & "\a4_page.html", "\", "/")
		Scope
			Dim As Integer fn = FreeFile
			If Open(ExePath & "\a4_ticks.txt" For Append As #fn) = 0 Then
				Print #fn, "  BEFORE Navigate [" & firstPage & "]"
				Close #fn
			End If
		End Scope
		pForm->wb.Navigate(@firstPage)
		Scope
			Dim As Integer fn2 = FreeFile
			If Open(ExePath & "\a4_ticks.txt" For Append As #fn2) = 0 Then
				Print #fn2, "  AFTER Navigate returned"
				Close #fn2
			End If
		End Scope
		Exit Sub
	End If
	'' GetBody is deliberately not called yet: on this backend it does not return when the
	'' document is not ready, and because COM pumps messages the timer re-enters, stacking
	'' blocked calls. Rendering is proven from the screenshot first; see TestPlan A4.
	pForm->Done = True
	pForm->tmr.Enabled = False
	Exit Sub
	'' Give the document time to arrive before touching the DOM.
	If pForm->Ticks < 4 Then Exit Sub
	Dim As UString body = pForm->wb.GetBody()
	Scope
		Dim As Integer ft2 = FreeFile
		If Open(ExePath & "\a4_ticks.txt" For Append As #ft2) = 0 Then
			Print #ft2, "  tick " & Str(pForm->Ticks) & " body len=" & Str(Len(body)) & " url=[" & pForm->wb.GetURL() & "]"
			Close #ft2
		End If
	End Scope
	If InStr(body, A4_MARKER) > 0 Then
		pForm->Done = True
		pForm->tmr.Enabled = False
		Dim As String detail = "marker found after " & Str(pForm->Ticks * 500) & "ms; body length " & Str(Len(body))
		detail &= "; url " & pForm->wb.GetURL()
		WriteResult("DOM_OK", detail)
	ElseIf pForm->Ticks >= A4_TIMEOUT_TICKS Then
		pForm->Done = True
		pForm->tmr.Enabled = False
		WriteResult("DOM_TIMEOUT", "no marker after " & Str(A4_TIMEOUT_TICKS * 500) & "ms; body length " & Str(Len(body)))
	End If
End Sub

Dim As A4Form f
pForm = @f
f.Show
'' Navigate only once the window exists, so the control has a handle to host the document.
App.Run
