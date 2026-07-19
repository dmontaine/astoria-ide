'' TestPlan.md B5 -- layout boxes.
''
'' A VerticalBox and a HorizontalBox, each with mixed children, resized. B4 covered docking; this
'' covers the box layouts, which the IDE leans on heavily -- Astoria's own Options dialog is built
'' from them, and the row-spacing work there came from exactly this arithmetic.
''
'' Boxes are checked by their defining property rather than by remembered coordinates: in a
'' VerticalBox children share a left edge and width and stack downwards without overlapping; in a
'' HorizontalBox they share a top edge and height and run left to right. Those hold at any size,
'' so the same assertions can be applied after every resize.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b5_result.txt.

#include once "mff/Form.bi"
#include once "mff/VerticalBox.bi"
#include once "mff/HorizontalBox.bi"
#include once "mff/Panel.bi"
#include once "mff/CommandButton.bi"
#include once "mff/TextBox.bi"
#include once "mff/Label.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B5_WATCHDOG_TICKS = 60

Type B5Form Extends Form
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As VerticalBox   vbx
	Dim As HorizontalBox hbx
	Dim As Label   vLabel
	Dim As TextBox vText
	Dim As CommandButton vButton
	Dim As Label   hLabel
	Dim As TextBox hText
	Dim As CommandButton hButton
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
End Type

Dim Shared As B5Form Ptr pB5

Sub B5Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b5_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B5Check(ByRef CheckName As String, ByVal Passed As Boolean, ByRef Detail As String)
	If pB5 = 0 Then Exit Sub
	If Passed Then
		pB5->Pass += 1
		B5Say("   PASS " & CheckName)
	Else
		pB5->Fail += 1
		B5Say("   FAIL " & CheckName & "  [" & Detail & "]")
	End If
End Sub

Constructor B5Form
	With This
		.Name = "B5Form" : .Text = "B5 layout boxes test"
		.Designer = @This : .SetBounds 0, 0, 760, 520
	End With
	'' A VerticalBox down the left, a HorizontalBox across the bottom.
	With vbx
		.Name = "vbx" : .Align = DockStyle.alLeft : .Width = 300
		.Designer = @This : .Parent = @This
	End With
	With hbx
		.Name = "hbx" : .Align = DockStyle.alBottom : .Height = 60
		.Designer = @This : .Parent = @This
	End With
	'' Mixed child types on purpose: a box must not care what it is arranging.
	vLabel.Name  = "vLabel"  : vLabel.Text  = "in a VerticalBox"   : vLabel.Designer  = @This : vLabel.Parent  = @vbx
	vText.Name   = "vText"   : vText.Text   = "vertical"           : vText.Designer   = @This : vText.Parent   = @vbx
	vButton.Name = "vButton" : vButton.Text = "V button"           : vButton.Designer = @This : vButton.Parent = @vbx
	hLabel.Name  = "hLabel"  : hLabel.Text  = "in a HorizontalBox" : hLabel.Designer  = @This : hLabel.Parent  = @hbx
	hText.Name   = "hText"   : hText.Text   = "horizontal"         : hText.Designer   = @This : hText.Parent   = @hbx
	hButton.Name = "hButton" : hButton.Text = "H button"           : hButton.Designer = @This : hButton.Parent = @hbx
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_ : .Enabled = True
	End With
End Constructor

Sub B5Verify(ByRef SizeLabel As String)
	If pB5 = 0 Then Exit Sub
	B5Say("--- " & SizeLabel & " ---")

	'' ---- VerticalBox: same left and width, stacked downwards, no overlap ----------------
	Dim As Integer aL = pB5->vLabel.Left,  aT = pB5->vLabel.Top,  aW = pB5->vLabel.Width,  aB = aT + pB5->vLabel.Height
	Dim As Integer bL = pB5->vText.Left,   bT = pB5->vText.Top,   bW = pB5->vText.Width,   bB = bT + pB5->vText.Height
	Dim As Integer cL = pB5->vButton.Left, cT = pB5->vButton.Top, cW = pB5->vButton.Width, cB = cT + pB5->vButton.Height
	B5Check("vertical: children share a left edge", aL = bL AndAlso bL = cL, Str(aL) & "/" & Str(bL) & "/" & Str(cL))
	B5Check("vertical: children share a width",     aW = bW AndAlso bW = cW, Str(aW) & "/" & Str(bW) & "/" & Str(cW))
	B5Check("vertical: stacked in order",           aT < bT AndAlso bT < cT, Str(aT) & "<" & Str(bT) & "<" & Str(cT))
	B5Check("vertical: no overlap",                 aB <= bT AndAlso bB <= cT, Str(aB) & "<=" & Str(bT) & ", " & Str(bB) & "<=" & Str(cT))
	B5Check("vertical: children have real width",   aW > 0, Str(aW))

	'' ---- HorizontalBox: same top and height, left to right, no overlap ------------------
	Dim As Integer dL = pB5->hLabel.Left,  dT = pB5->hLabel.Top,  dH = pB5->hLabel.Height,  dR = dL + pB5->hLabel.Width
	Dim As Integer eL = pB5->hText.Left,   eT = pB5->hText.Top,   eH = pB5->hText.Height,   eR = eL + pB5->hText.Width
	Dim As Integer fL = pB5->hButton.Left, fT = pB5->hButton.Top, fH = pB5->hButton.Height, fR = fL + pB5->hButton.Width
	B5Check("horizontal: children share a top edge", dT = eT AndAlso eT = fT, Str(dT) & "/" & Str(eT) & "/" & Str(fT))
	B5Check("horizontal: children share a height",   dH = eH AndAlso eH = fH, Str(dH) & "/" & Str(eH) & "/" & Str(fH))
	B5Check("horizontal: laid out in order",         dL < eL AndAlso eL < fL, Str(dL) & "<" & Str(eL) & "<" & Str(fL))
	B5Check("horizontal: no overlap",                dR <= eL AndAlso eR <= fL, Str(dR) & "<=" & Str(eL) & ", " & Str(eR) & "<=" & Str(fL))
	B5Check("horizontal: children have real height", dH > 0, Str(dH))
End Sub

Sub B5Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB5 = 0 Then Exit Sub
	pB5->Ticks += 1
	If pB5->Ticks > B5_WATCHDOG_TICKS Then
		B5Say("watchdog fired at stage " & Str(pB5->Stage))
		B5Say("B5 OVERALL: FAIL")
		End 1
	End If
	Select Case pB5->Stage
	Case 0
		If pB5->Ticks < 3 Then Exit Sub
		B5Verify("design 760x520") : pB5->Stage = 1
	Case 1
		pB5->SetBounds 100, 100, 1100, 760 : pB5->Stage = 2
	Case 2
		B5Verify("large 1100x760") : pB5->Stage = 3
	Case 3
		pB5->SetBounds 100, 100, 460, 340 : pB5->Stage = 4
	Case 4
		B5Verify("small 460x340") : pB5->Stage = 5
	Case 5
		B5Say("")
		B5Say("B5 RESULT: " & Str(pB5->Pass) & " passed, " & Str(pB5->Fail) & " failed")
		If pB5->Fail = 0 Then
			B5Say("B5 OVERALL: PASS")
			End 0
		Else
			B5Say("B5 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b5_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B5Form f
pB5 = @f
f.Show
App.Run
