'' TestPlan.md B9 -- timer driving a progress bar.
''
'' A TimerComponent advancing a ProgressBar while the window stays responsive: the classic shape
'' of any long-running operation with feedback, and a classic source of message-loop bugs. A
'' program that does its work in a tight loop instead of on a timer shows a frozen bar and an
'' unresponsive window, which is the failure this scenario is meant to catch.
''
'' Responsiveness is asserted rather than assumed: a SECOND, independent timer runs throughout and
'' counts its own ticks. If the progress timer ever blocked the message loop, the watchdog timer
'' would stop being serviced and its count would fall behind. Checking only that the bar reached
'' its maximum would say nothing about whether the UI was alive while it did.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b9_result.txt.

#include once "mff/Form.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/Label.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B9_TARGET   = 10        '' progress steps to complete
Const B9_WATCHDOG = 120       '' hard upper bound in watchdog ticks

Type B9Form Extends Form
	Declare Static Sub tmrWork_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Static Sub tmrPulse_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As ProgressBar barWork
	Dim As Label lblStatus
	Dim As TimerComponent tmrWork      '' does the "work"
	Dim As TimerComponent tmrPulse     '' independent proof the loop is still being serviced
	Dim As Integer Steps, Pulses, Pass, Fail
	Dim As Integer PulsesAtStart, PulsesAtEnd
	Dim As Boolean Finished
End Type

Dim Shared As B9Form Ptr pB9

Sub B9Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b9_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B9Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB9 = 0 Then Exit Sub
	If Got = Want Then
		pB9->Pass += 1
		B9Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB9->Fail += 1
		B9Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

Constructor B9Form
	With This
		.Name = "B9Form" : .Text = "B9 timer progress test"
		.Designer = @This : .SetBounds 0, 0, 520, 200
	End With
	With lblStatus
		.Name = "lblStatus" : .Text = "0 of " & Str(B9_TARGET)
		.SetBounds 20, 20, 300, 20
		.Designer = @This : .Parent = @This
	End With
	With barWork
		.Name = "barWork"
		.SetBounds 20, 50, 460, 28
		.Designer = @This : .Parent = @This
	End With
	barWork.MaxValue = B9_TARGET
	barWork.Position = 0
	With tmrWork
		.Name = "tmrWork" : .Interval = 120
		.OnTimer = @tmrWork_Timer_ : .Enabled = True
	End With
	With tmrPulse
		.Name = "tmrPulse" : .Interval = 40
		.OnTimer = @tmrPulse_Timer_ : .Enabled = True
	End With
End Constructor

'' Independent heartbeat. Its only job is to be counted.
Sub B9Form.tmrPulse_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB9 = 0 Then Exit Sub
	pB9->Pulses += 1
	If pB9->Pulses > B9_WATCHDOG * 4 Then
		B9Say("watchdog fired")
		B9Say("B9 OVERALL: FAIL")
		End 1
	End If
End Sub

Sub B9Form.tmrWork_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB9 = 0 OrElse pB9->Finished Then Exit Sub

	If pB9->Steps = 0 Then
		B9Say("-- before any work --")
		B9Check("progress starts at zero", Str(pB9->barWork.Position), "0")
		B9Check("maximum is what was set",  Str(pB9->barWork.MaxValue), Str(B9_TARGET))
		pB9->PulsesAtStart = pB9->Pulses
	End If

	'' One step of "work" per tick, with the bar and label following it.
	pB9->Steps += 1
	pB9->barWork.Position = pB9->Steps
	pB9->lblStatus.Text = Str(pB9->Steps) & " of " & Str(B9_TARGET)

	'' The bar must actually hold the value it was given, every step -- not just at the end.
	If pB9->barWork.Position <> pB9->Steps Then
		pB9->Fail += 1
		B9Say("FAIL bar lost step " & Str(pB9->Steps) & ": reads " & Str(pB9->barWork.Position))
	End If

	If pB9->Steps >= B9_TARGET Then
		pB9->Finished = True
		pB9->tmrWork.Enabled = False
		pB9->PulsesAtEnd = pB9->Pulses

		B9Say("-- after the work --")
		B9Check("bar reached its maximum", Str(pB9->barWork.Position), Str(B9_TARGET))
		B9Check("label followed the bar", pB9->lblStatus.Text, Str(B9_TARGET) & " of " & Str(B9_TARGET))
		B9Check("every step was recorded", Str(pB9->Steps), Str(B9_TARGET))

		'' The assertion that matters: an independent timer kept being serviced throughout, so
		'' the message loop was never blocked by the work.
		Dim As Integer pulsesDuring = pB9->PulsesAtEnd - pB9->PulsesAtStart
		B9Say("   independent timer ticks during the work: " & Str(pulsesDuring))
		B9Check("message loop stayed responsive during the work", Str(pulsesDuring > 0), "-1")
		'' At 40ms against 120ms of work per step, the heartbeat should beat the worker roughly
		'' three to one. Anything at or below one-to-one means the loop was being starved.
		B9Check("heartbeat outpaced the worker", Str(pulsesDuring > B9_TARGET), "-1")

		B9Say("")
		B9Say("B9 RESULT: " & Str(pB9->Pass) & " passed, " & Str(pB9->Fail) & " failed")
		If pB9->Fail = 0 Then
			B9Say("B9 OVERALL: PASS")
			End 0
		Else
			B9Say("B9 OVERALL: FAIL")
			End 1
		End If
	End If
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b9_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B9Form f
pB9 = @f
f.Show
App.Run
