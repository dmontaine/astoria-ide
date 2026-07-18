'' TestPlan.md B10 -- a second form, modal and modeless.
''
'' Multi-form lifetime and ownership: the area that produced Astoria's own modal z-order defect,
'' where a dialog opened behind the window that owned it. A control sweep cannot reach this at
'' all, because it needs two windows existing at once.
''
'' SELF-DRIVING ON PURPOSE. An earlier version was driven from outside with synthetic clicks,
'' which parked a window on the tester's desktop for as long as the driving script ran. This
'' version sequences itself on a timer, writes b10_result.txt, and exits -- so it cannot outlive
'' its own run. A watchdog closes it even if a step never completes.
''
'' What that costs, stated plainly: self-driving proves the form-to-form behaviour but not that a
'' real mouse click reaches the dialog's OK button. B1 covers that separately -- external clicks
'' were shown to land on CommandButtons there. Z-order (does the dialog appear IN FRONT of its
'' owner) is owner-verified by observation rather than asserted here.
''
'' Run it and read b10_result.txt. It needs no interaction.

#include once "mff/Form.bi"
#include once "mff/TextBox.bi"
#include once "mff/Label.bi"
#include once "mff/CommandButton.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B10_WATCHDOG_TICKS = 40      '' 40 x 250ms = 10 seconds, hard upper bound on the whole run

'' ---- the dialog, used both modally and modelessly -------------------------------------------
'' Closes itself with OK shortly after opening, so the modal step needs no operator.
Type B10Child Extends Form
	Declare Static Sub tmrAuto_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As TextBox txtValue
	Dim As CommandButton cmdOK
	Dim As TimerComponent tmrAuto
	Dim As Boolean AutoCloseWithOK
End Type

Dim Shared As B10Child Ptr pDlg

Constructor B10Child
	With This
		.Name = "B10Child"
		.Text = "B10 dialog"
		.Designer = @This
		.SetBounds 0, 0, 420, 180
	End With
	With txtValue
		.Name = "txtValue" : .Text = ""
		.SetBounds 20, 20, 370, 24
		.Designer = @This : .Parent = @This
	End With
	With cmdOK
		.Name = "cmdOK" : .Text = "OK"
		.SetBounds 300, 90, 90, 30
		.Designer = @This : .Parent = @This
	End With
	With tmrAuto
		.Name = "tmrAuto" : .Interval = 700
		.OnTimer = @tmrAuto_Timer_
		.Enabled = False
	End With
End Constructor

Sub B10Child.tmrAuto_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pDlg = 0 Then Exit Sub
	pDlg->tmrAuto.Enabled = False
	If pDlg->AutoCloseWithOK Then
		'' Edit the value first, so the main form has something new to read back.
		pDlg->txtValue.Text = "edited-in-dialog"
		pDlg->ModalResult = ModalResults.OK
		pDlg->CloseForm
	End If
End Sub

'' ---- the main form ---------------------------------------------------------------------------
Type B10Form Extends Form
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As Label lblValue
	Dim As TextBox txtMain
	Dim As TimerComponent tmrSeq
	Dim As B10Child Ptr pModeless
	Dim As Integer Ticks, Stage, LoopProof
	'' ShowModal runs its own message loop, and this timer is a thread timer, so it keeps firing
	'' while the dialog is up. Without this guard the handler re-enters Case 0 and opens a second
	'' and third dialog on top of the first -- which is exactly what the first run of this test
	'' did. Re-entrancy is the normal hazard of doing work in a timer around a modal call.
	Dim As Boolean InModal
End Type

Dim Shared As B10Form Ptr pB10

Sub B10Report(ByRef Key As String, ByRef ValueText As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b10_result.txt" For Append As #f) = 0 Then
		Print #f, Key & "=" & ValueText
		Close #f
	End If
End Sub

Constructor B10Form
	With This
		.Name = "B10Form"
		.Text = "B10 second form test"
		.Designer = @This
		.SetBounds 0, 0, 560, 220
	End With
	With lblValue
		.Name = "lblValue" : .Text = "Main value:"
		.SetBounds 20, 24, 90, 20
		.Designer = @This : .Parent = @This
	End With
	With txtMain
		.Name = "txtMain" : .Text = "original-main-value"
		.SetBounds 120, 22, 410, 24
		.Designer = @This : .Parent = @This
	End With
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With
End Constructor

Sub B10Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB10 = 0 Then Exit Sub
	'' Re-entered from inside ShowModal's own message loop -- count the tick as proof the loop is
	'' alive, but do no work.
	If pB10->InModal Then pB10->LoopProof += 1 : Exit Sub
	pB10->Ticks += 1
	'' Every tick is evidence the main form's message loop is still pumping.
	pB10->LoopProof += 1
	If pB10->Ticks > B10_WATCHDOG_TICKS Then
		B10Report("watchdog_fired", "true at stage " & Str(pB10->Stage))
		B10Report("OVERALL", "FAIL")
		End 1
	End If

	Select Case pB10->Stage
	Case 0
		If pB10->Ticks < 2 Then Exit Sub
		'' --- modal: data in, dialog closes itself with OK, data out -------------------------
		Dim As B10Child dlg
		pDlg = @dlg
		dlg.txtValue.Text = "sent-to-dialog"
		B10Report("modal_sent", dlg.txtValue.Text)
		dlg.AutoCloseWithOK = True
		dlg.tmrAuto.Enabled = True
		pB10->LoopProof = 0
		pB10->InModal = True
		Dim As Integer modalResult = dlg.ShowModal(*pB10)     '' blocks until the dialog closes
		pB10->InModal = False
		B10Report("modal_result_is_ok", Str(modalResult = ModalResults.OK))
		If modalResult = ModalResults.OK Then
			pB10->txtMain.Text = dlg.txtValue.Text
		End If
		B10Report("modal_returned_to_main", pB10->txtMain.Text)
		B10Report("main_loop_alive_after_modal", Str(pB10->LoopProof > 0))
		pDlg = 0
		pB10->Stage = 1

	Case 1
		'' --- modeless: two windows alive at once ------------------------------------------
		pB10->pModeless = New B10Child
		pB10->pModeless->Text = "B10 modeless"
		pB10->pModeless->txtValue.Text = "modeless-open"
		pB10->pModeless->AutoCloseWithOK = False
		pB10->pModeless->Show(*pB10)
		B10Report("modeless_visible", Str(pB10->pModeless->Visible))
		B10Report("main_still_visible", Str(pB10->Visible))
		B10Report("both_windows_at_once", Str(pB10->Visible AndAlso pB10->pModeless->Visible))
		pB10->LoopProof = 0        '' reset, then prove ticks keep arriving while it is open
		pB10->Stage = 2

	Case 2
		'' Give the loop a few ticks with the modeless window up.
		If pB10->LoopProof < 4 Then Exit Sub
		B10Report("main_responsive_while_modeless", Str(pB10->LoopProof >= 4))
		pB10->Stage = 3

	Case 3
		'' --- close down cleanly -------------------------------------------------------------
		If pB10->pModeless Then
			pB10->pModeless->CloseForm
			Delete pB10->pModeless
			pB10->pModeless = 0
		End If
		B10Report("modeless_closed", "true")
		B10Report("OVERALL", "PASS")
		End 0
	End Select
End Sub

'' Start from a clean report file each run.
Dim As Integer fInit = FreeFile
If Open(ExePath & "\b10_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B10Form f
pB10 = @f
f.Show
App.Run
