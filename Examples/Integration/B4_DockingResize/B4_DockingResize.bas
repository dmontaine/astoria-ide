'' TestPlan.md B4 -- docking and anchoring under resize.
''
'' Four panels docked alTop, alBottom, alLeft and alClient on one form. Docking is arithmetic
'' redone every time the form changes size, so it is exactly the kind of thing that looks right at
'' the design size and goes wrong at the extremes -- Astoria's own Options dialog has produced
'' several bugs of this shape.
''
'' SELF-DRIVING AND SELF-EXITING. The form resizes itself through a sequence of sizes and checks
'' its own children after each one, then exits. An earlier version was resized by an outside
'' script, which parked a window on the tester's desktop for as long as that script ran.
''
'' The checks are invariants, not screenshots: each band must span the full client width, the left
'' band must fill exactly the height between the top and bottom bands, and the client panel must
'' abut the left band and reach the right edge -- with no gap or overlap at any boundary. A layout
'' bug shows up as an arithmetic mismatch rather than something a human has to spot.
''
'' Run it and read b4_result.txt. It needs no interaction and closes itself.

#include once "mff/Form.bi"
#include once "mff/Panel.bi"
#include once "mff/Label.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B4_WATCHDOG_TICKS = 60      '' 60 x 250ms = 15 seconds, hard upper bound

Type B4Form Extends Form
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As Panel pnlTop, pnlBottom, pnlLeft, pnlClient
	Dim As Label lblTop, lblBottom, lblLeft, lblClient
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
End Type

Dim Shared As B4Form Ptr pB4

Sub B4Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b4_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B4Check(ByRef CheckName As String, ByVal Passed As Boolean, ByRef Detail As String)
	If pB4 = 0 Then Exit Sub
	If Passed Then
		pB4->Pass += 1
		B4Say("   PASS " & CheckName)
	Else
		pB4->Fail += 1
		B4Say("   FAIL " & CheckName & "  [" & Detail & "]")
	End If
End Sub

Constructor B4Form
	With This
		.Name = "B4Form"
		.Text = "B4 docking resize test"
		.Designer = @This
		.SetBounds 0, 0, 800, 560
	End With
	'' Order matters: each alTop/alBottom/alLeft claims its band from what remains, and alClient
	'' takes the remainder, so alClient is added last on purpose.
	With pnlTop
		.Name = "pnlTop" : .Align = DockStyle.alTop : .Height = 60
		.Designer = @This : .Parent = @This
	End With
	With pnlBottom
		.Name = "pnlBottom" : .Align = DockStyle.alBottom : .Height = 40
		.Designer = @This : .Parent = @This
	End With
	With pnlLeft
		.Name = "pnlLeft" : .Align = DockStyle.alLeft : .Width = 160
		.Designer = @This : .Parent = @This
	End With
	With pnlClient
		.Name = "pnlClient" : .Align = DockStyle.alClient
		.Designer = @This : .Parent = @This
	End With
	With lblTop
		.Name = "lblTop" : .Text = "TOP alTop h=60"
		.SetBounds 8, 8, 300, 20 : .Designer = @This : .Parent = @pnlTop
	End With
	With lblBottom
		.Name = "lblBottom" : .Text = "BOTTOM alBottom h=40"
		.SetBounds 8, 8, 300, 20 : .Designer = @This : .Parent = @pnlBottom
	End With
	With lblLeft
		.Name = "lblLeft" : .Text = "LEFT alLeft w=160"
		.SetBounds 8, 8, 150, 20 : .Designer = @This : .Parent = @pnlLeft
	End With
	With lblClient
		.Name = "lblClient" : .Text = "CLIENT alClient - takes what is left"
		.SetBounds 8, 8, 320, 20 : .Designer = @This : .Parent = @pnlClient
	End With
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With
End Constructor

'' Checks every docking invariant against the form's current client area.
Sub B4Verify(ByRef SizeLabel As String)
	If pB4 = 0 Then Exit Sub
	Dim As Integer cw = pB4->ClientWidth, ch = pB4->ClientHeight
	Dim As Integer tL = pB4->pnlTop.Left,    tT = pB4->pnlTop.Top
	Dim As Integer tR = tL + pB4->pnlTop.Width, tB = tT + pB4->pnlTop.Height
	Dim As Integer bL = pB4->pnlBottom.Left, bT = pB4->pnlBottom.Top
	Dim As Integer bR = bL + pB4->pnlBottom.Width, bB = bT + pB4->pnlBottom.Height
	Dim As Integer lL = pB4->pnlLeft.Left,   lT = pB4->pnlLeft.Top
	Dim As Integer lR = lL + pB4->pnlLeft.Width, lB = lT + pB4->pnlLeft.Height
	Dim As Integer cL = pB4->pnlClient.Left, cT = pB4->pnlClient.Top
	Dim As Integer cR = cL + pB4->pnlClient.Width, cB = cT + pB4->pnlClient.Height

	B4Say("--- " & SizeLabel & "  (client " & Str(cw) & "x" & Str(ch) & ") ---")
	B4Check("top spans full width",       tL = 0 AndAlso tR = cw, Str(tL) & ".." & Str(tR) & " vs " & Str(cw))
	B4Check("top anchored at y=0",        tT = 0, Str(tT))
	B4Check("bottom spans full width",    bL = 0 AndAlso bR = cw, Str(bL) & ".." & Str(bR) & " vs " & Str(cw))
	B4Check("bottom flush to base",       bB = ch, Str(bB) & " vs " & Str(ch))
	B4Check("left starts at x=0",         lL = 0, Str(lL))
	B4Check("left fills between bands",   lT = tB AndAlso lB = bT, Str(lT) & ".." & Str(lB) & " vs " & Str(tB) & ".." & Str(bT))
	B4Check("client abuts left band",     cL = lR, Str(cL) & " vs " & Str(lR))
	B4Check("client reaches right edge",  cR = cw, Str(cR) & " vs " & Str(cw))
	B4Check("client fills between bands", cT = tB AndAlso cB = bT, Str(cT) & ".." & Str(cB) & " vs " & Str(tB) & ".." & Str(bT))
	B4Check("no vertical gap or overlap", tB = lT AndAlso lB = bT, "top.b=" & Str(tB) & " left.t=" & Str(lT))
End Sub

Sub B4Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB4 = 0 Then Exit Sub
	pB4->Ticks += 1
	If pB4->Ticks > B4_WATCHDOG_TICKS Then
		B4Say("watchdog fired at stage " & Str(pB4->Stage))
		B4Say("B4 OVERALL: FAIL")
		End 1
	End If
	'' One tick of settling between a resize and the check, so the layout pass has run.
	Select Case pB4->Stage
	Case 0
		If pB4->Ticks < 2 Then Exit Sub
		B4Verify("design 800x560") : pB4->Stage = 1
	Case 1
		pB4->SetBounds 100, 100, 1200, 800 : pB4->Stage = 2
	Case 2
		B4Verify("large 1200x800") : pB4->Stage = 3
	Case 3
		pB4->SetBounds 100, 100, 420, 300 : pB4->Stage = 4
	Case 4
		B4Verify("small 420x300") : pB4->Stage = 5
	Case 5
		pB4->WindowState = WindowStates.wsMaximized : pB4->Stage = 6
	Case 6
		B4Verify("maximised") : pB4->Stage = 7
	Case 7
		pB4->WindowState = WindowStates.wsNormal : pB4->Stage = 8
	Case 8
		B4Verify("restored after maximise")
		B4Say("")
		B4Say("B4 RESULT: " & Str(pB4->Pass) & " passed, " & Str(pB4->Fail) & " failed")
		If pB4->Fail = 0 Then
			B4Say("B4 OVERALL: PASS")
			End 0
		Else
			B4Say("B4 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b4_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B4Form f
pB4 = @f
f.Show
App.Run
