'' TestPlan.md A6 -- ScintillaControl editing.
''
'' The 73-control sweep proved this control's window opens. It proved nothing about whether the
'' editor actually edits. That matters more here than for most controls: ScintillaControl is the
'' same engine the IDE's own code editor is built on, so a user reaching for it is reaching for
'' the thing Astoria itself depends on.
''
'' Asserts on observable state after each operation rather than on "it did not crash":
''   1. Text round-trip     -- set .Text, read it back, compare exactly.
''   2. Line addressing     -- .LineText(n) returns the right line, proving the buffer is really
''                             line-structured and not just a string that happens to match.
''   3. Selection edit      -- SelectAll + .SelText replaces content, read back and compare.
''   4. Undo                -- reverts to the previous text exactly.
''   5. Redo                -- reapplies it exactly.
''   6. Styling             -- set a style's ForeColor/BackColor, read them back.
''
'' Undo/redo is the interesting part. It is a Scintilla-managed history, entirely separate from
'' the framework's own undo, and it is what a user gets "for free" when they drop the control on
'' a form -- so it is worth knowing it survives programmatic edits, not just typed ones.
''
'' Work happens on a timer rather than in the constructor: Scintilla needs its window created
'' before text operations mean anything, and that has not happened while the constructor runs.
''
'' Results go to a6_result.txt because this is a GUI subsystem program -- Print has nowhere to go.

#include once "mff/Form.bi"
#include once "ScintillaControl.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const A6_TEXT1 = "alpha line one" & Chr(13) & Chr(10) & "beta line two" & Chr(13) & Chr(10) & "gamma line three"
Const A6_TEXT2 = "replaced entirely"

Type A6Form Extends Form
	Declare Static Sub tmr_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As ScintillaControl sci
	Dim As TimerComponent tmr
	Dim As Boolean Done
End Type

Dim Shared As A6Form Ptr pForm
Dim Shared As String gLog

Sub Note(ByRef s As String)
	gLog &= s & Chr(13) & Chr(10)
End Sub

'' Compares and records in one step, so every assertion leaves evidence whether it passes or not.
Function Check(ByRef what As String, ByRef got As String, ByRef want As String) As Boolean
	If got = want Then
		Note("PASS  " & what)
		Return True
	End If
	Note("FAIL  " & what)
	Note("        wanted [" & want & "]")
	Note("        got    [" & got & "]")
	Return False
End Function

Sub WriteResult(ByRef Verdict As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\a6_result.txt" For Output As #f) = 0 Then
		Print #f, Verdict
		Print #f, gLog
		Close #f
	End If
End Sub

Constructor A6Form
	With This
		.Name = "A6Form"
		.Text = "A6 ScintillaControl editing test"
		.Designer = @This
		.SetBounds 0, 0, 760, 520
	End With
	With sci
		.Name = "sci"
		.Align = DockStyle.alClient
		.Designer = @This
		.Parent = @This
	End With
	With tmr
		.Name = "tmr"
		.Interval = 700
		.OnTimer = @tmr_Timer_
		.Enabled = True
	End With
End Constructor

Sub A6Form.tmr_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pForm = 0 OrElse pForm->Done Then Exit Sub
	pForm->Done = True
	pForm->tmr.Enabled = False

	Dim As Integer failures = 0

	'' 1. Text round-trip.
	pForm->sci.Text = A6_TEXT1
	If Not Check("text round-trip", pForm->sci.Text, A6_TEXT1) Then failures += 1

	'' 2. Line addressing -- proves a real line-structured buffer.
	If Not Check("LineText(0)", Trim(pForm->sci.LineText(0), Any Chr(13) & Chr(10)), "alpha line one") Then failures += 1
	If Not Check("LineText(2)", Trim(pForm->sci.LineText(2), Any Chr(13) & Chr(10)), "gamma line three") Then failures += 1

	'' 3. Selection edit -- replace everything through the selection API.
	pForm->sci.SelectAll()
	pForm->sci.SelText = A6_TEXT2
	If Not Check("SelText replace", pForm->sci.Text, A6_TEXT2) Then failures += 1

	'' 4. Undo -- must restore the previous text exactly.
	pForm->sci.Undo()
	If Not Check("undo restores previous text", pForm->sci.Text, A6_TEXT1) Then failures += 1

	'' 5. Redo -- must reapply it exactly.
	pForm->sci.Redo()
	If Not Check("redo reapplies edit", pForm->sci.Text, A6_TEXT2) Then failures += 1

	'' 6. Styling -- set and read back on style 0 (the default style).
	pForm->sci.ForeColor(0) = &hFF0000
	pForm->sci.BackColor(0) = &h00FF00
	If Not Check("style ForeColor round-trip", Str(pForm->sci.ForeColor(0)), Str(&hFF0000)) Then failures += 1
	If Not Check("style BackColor round-trip", Str(pForm->sci.BackColor(0)), Str(&h00FF00)) Then failures += 1

	If failures = 0 Then
		WriteResult("A6_OK  all assertions passed")
	Else
		WriteResult("A6_FAIL  " & Str(failures) & " assertion(s) failed")
	End If

	pForm->CloseForm
End Sub

Dim As A6Form f
pForm = @f
f.MainForm = True
f.Show
App.Run
