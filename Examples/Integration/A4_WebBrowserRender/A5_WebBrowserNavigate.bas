'' TestPlan.md A5 -- WebBrowser navigation and history.
''
'' A4 proved a page renders. This proves the browser is a browser: that following a link actually
'' navigates, and that Back and Forward walk the history rather than being no-ops.
''
'' The link is followed by clicking it in the page (ExecuteScript -> element.click()), not by
'' calling Navigate with the second URL. Calling Navigate would prove nothing about links, and
'' would not put an entry in the history for Back to return from.
''
'' Runs as a state machine on a timer because every step is asynchronous: navigation completes
'' whenever it completes, so each state polls the DOM for the token belonging to the page it
'' expects, then triggers the next step.
''
'' Results go to a5_result.txt -- this is a GUI subsystem program, so Print has nowhere to go.

#include once "mff/Form.bi"
#include once "mff/WebBrowser.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const A5_TOKEN1 = "MARKER-TOKEN-8842"        '' page one
Const A5_TOKEN2 = "SECOND-PAGE-TOKEN-5517"   '' page two
Const A5_TIMEOUT_TICKS = 80                  '' 80 x 500ms = 40 seconds overall

Type A5Form Extends Form
	Declare Static Sub tmr_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As WebBrowser wb
	Dim As TimerComponent tmr
	Dim As Integer Ticks
	Dim As Integer Stage
	Dim As Boolean Done
	Dim As Integer Pass, Fail
	Dim As String Log
End Type

Dim Shared As A5Form Ptr pF

Sub A5Check(ByRef CheckName As String, ByVal Passed As Boolean, ByRef Detail As String)
	If pF = 0 Then Exit Sub
	If Passed Then
		pF->Pass += 1
		pF->Log &= "PASS " & CheckName & " (" & Detail & ")" & Chr(13, 10)
	Else
		pF->Fail += 1
		pF->Log &= "FAIL " & CheckName & " (" & Detail & ")" & Chr(13, 10)
	End If
End Sub

Sub A5Finish(ByRef Verdict As String)
	If pF = 0 Then Exit Sub
	pF->Done = True
	pF->tmr.Enabled = False
	Dim As Integer f = FreeFile
	If Open(ExePath & "\a5_result.txt" For Output As #f) = 0 Then
		Print #f, pF->Log;
		Print #f, "A5 RESULT: " & Str(pF->Pass) & " passed, " & Str(pF->Fail) & " failed"
		Print #f, "A5 OVERALL: " & Verdict
		Close #f
	End If
End Sub

Constructor A5Form
	With This
		.Name = "A5Form"
		.Text = "A5 WebBrowser navigation test"
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

Sub A5Form.tmr_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pF = 0 OrElse pF->Done Then Exit Sub
	pF->Ticks += 1
	If pF->Ticks > A5_TIMEOUT_TICKS Then
		A5Check("completed within time limit", False, "timed out at step " & Str(pF->Stage))
		A5Finish("FAIL")
		Exit Sub
	End If

	'' Navigate from inside the message loop; the control is not ready before it has pumped.
	If pF->Ticks = 1 Then
		Dim As WString * 1024 page1
		page1 = "file:///" & Replace(ExePath & "\a4_page.html", "\", "/")
		pF->wb.Navigate(@page1)
		pF->Stage = 1
		Exit Sub
	End If
	If pF->Ticks < 4 Then Exit Sub

	Dim As UString body = pF->wb.GetBody()
	Dim As UString url = pF->wb.GetURL()

	Select Case pF->Stage
	Case 1  '' waiting for page one, then click the link
		If InStr(body, A5_TOKEN1) > 0 Then
			A5Check("page one loaded", InStr(url, "a4_page.html") > 0, url)
			'' Click the link in the page rather than navigating to it directly: that is what
			'' makes this a test of link-following, and it is what creates the history entry.
			pF->wb.ExecuteScript("document.getElementsByTagName('a')[0].click();")
			pF->Stage = 2
		End If
	Case 2  '' waiting for page two, reached by the link
		If InStr(body, A5_TOKEN2) > 0 Then
			A5Check("link followed to page two", InStr(url, "a4_page2.html") > 0, url)
			pF->wb.GoBack()
			pF->Stage = 3
		End If
	Case 3  '' waiting for Back to return to page one
		If InStr(body, A5_TOKEN1) > 0 Then
			A5Check("GoBack returned to page one", InStr(url, "a4_page.html") > 0, url)
			pF->wb.GoForward()
			pF->Stage = 4
		End If
	Case 4  '' waiting for Forward to reach page two again
		If InStr(body, A5_TOKEN2) > 0 Then
			A5Check("GoForward returned to page two", InStr(url, "a4_page2.html") > 0, url)
			If pF->Fail = 0 Then A5Finish("PASS") Else A5Finish("FAIL")
		End If
	End Select
End Sub

Dim As A5Form f
pF = @f
f.Show
App.Run
