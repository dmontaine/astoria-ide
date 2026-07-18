'' TestPlan.md B1 -- data-entry form.
''
'' Label + TextBox + ComboBoxEdit + CheckBox + a RadioButton group + CommandButton on one form.
'' The single commonest form shape there is, and the case the 73-control sweep cannot reach: that
'' sweep proves each control opens a window on its own, not that a handler can read values back
'' out of six different controls, nor that clicking one radio button clears its neighbour.
''
'' SELF-DRIVING AND SELF-EXITING. It posts real Windows messages -- WM_SETTEXT and BM_CLICK -- to
'' its own control handles, which is the same path an external tool or a user's mouse takes into
'' the control's window procedure, then reads every control back through the framework API and
'' exits. An earlier version was driven from an outside script, which parked a window on the
'' tester's desktop for as long as that script ran.
''
'' Run it and read b1_result.txt. It needs no interaction and closes itself.

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/CheckBox.bi"
#include once "mff/RadioButton.bi"
#include once "mff/CommandButton.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B1_WATCHDOG_TICKS = 40      '' 40 x 250ms = 10 seconds, hard upper bound

Type B1Form Extends Form
	Declare Static Sub cmdSubmit_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As Label lblCaption
	Dim As TextBox txtName
	Dim As ComboBoxEdit cboColour
	Dim As CheckBox chkAgree
	Dim As RadioButton optAlpha, optBeta
	Dim As CommandButton cmdSubmit
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
	Dim As Boolean Submitted
End Type

Dim Shared As B1Form Ptr pB1

Sub B1Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB1 = 0 Then Exit Sub
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b1_result.txt" For Append As #f) = 0 Then
		If Got = Want Then
			pB1->Pass += 1
			Print #f, "PASS " & CheckName & " (" & Got & ")"
		Else
			pB1->Fail += 1
			Print #f, "FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]"
		End If
		Close #f
	End If
End Sub

Sub B1Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b1_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Constructor B1Form
	With This
		.Name = "B1Form"
		.Text = "B1 data entry form"
		.Designer = @This
		.SetBounds 0, 0, 460, 320
	End With
	With lblCaption
		.Name = "lblCaption" : .Text = "Name:"
		.SetBounds 16, 16, 80, 20
		.Designer = @This : .Parent = @This
	End With
	With txtName
		.Name = "txtName" : .Text = ""
		.TabIndex = 0
		.SetBounds 100, 14, 320, 24
		.Designer = @This : .Parent = @This
	End With
	With cboColour
		.Name = "cboColour"
		.Style = ComboBoxEditStyle.cbDropDownList
		.TabIndex = 1
		.SetBounds 100, 50, 320, 24
		.Designer = @This : .Parent = @This
	End With
	With chkAgree
		.Name = "chkAgree" : .Text = "Agree to terms"
		.TabIndex = 2
		.SetBounds 100, 86, 320, 24
		.Designer = @This : .Parent = @This
	End With
	'' RadioButtons group by shared parent, so these two form one group automatically.
	With optAlpha
		.Name = "optAlpha" : .Text = "Alpha"
		.TabIndex = 3
		.SetBounds 100, 118, 140, 24
		.Designer = @This : .Parent = @This
	End With
	With optBeta
		.Name = "optBeta" : .Text = "Beta"
		.TabIndex = 4
		.SetBounds 250, 118, 140, 24
		.Designer = @This : .Parent = @This
	End With
	With cmdSubmit
		.Name = "cmdSubmit" : .Text = "Submit"
		.TabIndex = 5
		.SetBounds 100, 160, 140, 32
		.Designer = @This : .OnClick = @cmdSubmit_Click_ : .Parent = @This
	End With
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With
	'' Populated after the controls exist, the way a real form fills a lookup list.
	cboColour.AddItem "Red"
	cboColour.AddItem "Green"
	cboColour.AddItem "Blue"
	cboColour.ItemIndex = 2
	optAlpha.Checked = True
End Constructor

'' The point of the test: one handler reading six different controls.
Sub B1Form.cmdSubmit_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If pB1 = 0 Then Exit Sub
	pB1->Submitted = True
	B1Say("-- values as the Submit handler saw them --")
	B1Check("textbox holds the typed text", pB1->txtName.Text, "Grace Hopper")
	B1Check("combo text", pB1->cboColour.Text, "Blue")
	B1Check("combo index", Str(pB1->cboColour.ItemIndex), "2")
	B1Check("combo item count", Str(pB1->cboColour.Items.Count), "3")
	B1Check("checkbox was ticked by the click", Str(pB1->chkAgree.Checked), "true")
	'' The assertion no single-control test can make: selecting one radio must clear the other.
	B1Check("radio Beta selected", Str(pB1->optBeta.Checked), "true")
	B1Check("radio Alpha cleared by the group", Str(pB1->optAlpha.Checked), "false")
	B1Check("label text intact", pB1->lblCaption.Text, "Name:")
End Sub

Sub B1Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB1 = 0 Then Exit Sub
	pB1->Ticks += 1
	If pB1->Ticks > B1_WATCHDOG_TICKS Then
		B1Say("watchdog fired at stage " & Str(pB1->Stage))
		B1Say("B1 OVERALL: FAIL")
		End 1
	End If

	Select Case pB1->Stage
	Case 0
		If pB1->Ticks < 2 Then Exit Sub
		'' Type into the TextBox the same way anything outside the process would.
		SendMessageW(pB1->txtName.Handle, WM_SETTEXT, 0, Cast(LPARAM, @WStr("Grace Hopper")))
		pB1->Stage = 1
	Case 1
		'' Tick the checkbox and choose the second radio, by real button clicks.
		SendMessageW(pB1->chkAgree.Handle, BM_CLICK, 0, 0)
		SendMessageW(pB1->optBeta.Handle, BM_CLICK, 0, 0)
		pB1->Stage = 2
	Case 2
		SendMessageW(pB1->cmdSubmit.Handle, BM_CLICK, 0, 0)
		pB1->Stage = 3
	Case 3
		If Not pB1->Submitted Then
			B1Say("FAIL Submit handler never ran")
			B1Say("B1 OVERALL: FAIL")
			End 1
		End If
		B1Say("")
		B1Say("B1 RESULT: " & Str(pB1->Pass) & " passed, " & Str(pB1->Fail) & " failed")
		If pB1->Fail = 0 Then
			B1Say("B1 OVERALL: PASS")
			End 0
		Else
			B1Say("B1 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

'' Start from a clean report file each run.
Dim As Integer fInit = FreeFile
If Open(ExePath & "\b1_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B1Form f
pB1 = @f
f.Show
App.Run
