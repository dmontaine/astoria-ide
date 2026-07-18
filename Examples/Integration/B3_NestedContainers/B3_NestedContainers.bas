'' TestPlan.md B3 -- nested containers.
''
'' Controls inside a GroupBox, inside a Panel, inside a TabControl page: three levels of nesting,
'' then switch tabs away and back. Nested parenting and tab-page switching is a known source of
'' layout bugs, and switching pages is where a framework can quietly destroy and recreate child
'' windows.
''
'' The assertion that matters most is HANDLE STABILITY across a tab switch. If a child's window is
'' recreated when its page is hidden and shown, its handle changes -- and anything holding onto
'' that handle, or any subclassing and event wiring attached to it, is silently broken. A test
'' that only checked "the text is still right" would miss that entirely, because the framework
'' would have faithfully restored the text onto a brand new window.
''
'' Built with a manifest (see the .rc). Without one, controls that need ComCtl32 v6 fail to
'' register -- which is how B13 discovered that a bare fbc build differs from what the IDE
'' produces, since the IDE adds a manifest to every project.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b3_result.txt.

#include once "mff/Form.bi"
#include once "mff/TabControl.bi"
#include once "mff/Panel.bi"
#include once "mff/GroupBox.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/CheckBox.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B3_WATCHDOG_TICKS = 60

Type B3Form Extends Form
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As TabControl tabs
	Dim As TabPage Ptr pgOne, pgTwo
	Dim As Panel pnlOuter
	Dim As GroupBox grpInner
	Dim As Label lblDeep
	Dim As TextBox txtDeep
	Dim As CheckBox chkDeep
	Dim As Label lblOtherTab
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
	'' Handles captured before the tab switch, compared after it.
	Dim As HWND hPanelBefore, hGroupBefore, hLabelBefore, hTextBefore, hCheckBefore
End Type

Dim Shared As B3Form Ptr pB3

Sub B3Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b3_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B3Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB3 = 0 Then Exit Sub
	If Got = Want Then
		pB3->Pass += 1
		B3Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB3->Fail += 1
		B3Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

Constructor B3Form
	With This
		.Name = "B3Form"
		.Text = "B3 nested containers test"
		.Designer = @This
		.SetBounds 0, 0, 700, 460
	End With
	With tabs
		.Name = "tabs" : .Align = DockStyle.alClient
		.Designer = @This : .Parent = @This
	End With
	pgOne = tabs.AddTab("Nested")
	pgTwo = tabs.AddTab("Other")

	'' Level 1: a Panel filling the first page.
	With pnlOuter
		.Name = "pnlOuter" : .Align = DockStyle.alClient
		.Designer = @This : .Parent = pgOne
	End With
	'' Level 2: a GroupBox inside that Panel.
	With grpInner
		.Name = "grpInner" : .Text = "Inner group"
		.SetBounds 20, 20, 560, 220
		.Designer = @This : .Parent = @pnlOuter
	End With
	'' Level 3: ordinary controls inside the GroupBox.
	With lblDeep
		.Name = "lblDeep" : .Text = "Three levels deep"
		.SetBounds 20, 36, 240, 20
		.Designer = @This : .Parent = @grpInner
	End With
	With txtDeep
		.Name = "txtDeep" : .Text = "nested-value"
		.SetBounds 20, 66, 300, 24
		.Designer = @This : .Parent = @grpInner
	End With
	With chkDeep
		.Name = "chkDeep" : .Text = "Nested checkbox"
		.SetBounds 20, 102, 300, 24
		.Designer = @This : .Parent = @grpInner
	End With

	With lblOtherTab
		.Name = "lblOtherTab" : .Text = "The other page"
		.SetBounds 20, 20, 300, 20
		.Designer = @This : .Parent = pgTwo
	End With

	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With
End Constructor

Sub B3Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB3 = 0 Then Exit Sub
	pB3->Ticks += 1
	If pB3->Ticks > B3_WATCHDOG_TICKS Then
		B3Say("watchdog fired at stage " & Str(pB3->Stage))
		B3Say("B3 OVERALL: FAIL")
		End 1
	End If

	Select Case pB3->Stage
	Case 0
		If pB3->Ticks < 4 Then Exit Sub
		B3Say("-- the nesting, on the visible page --")
		B3Check("tab count", Str(pB3->tabs.TabCount), "2")
		B3Check("panel has a window",     Str(pB3->pnlOuter.Handle <> 0), "-1")
		B3Check("groupbox has a window",  Str(pB3->grpInner.Handle <> 0), "-1")
		B3Check("deep label has a window",Str(pB3->lblDeep.Handle <> 0), "-1")
		B3Check("deep text has a window", Str(pB3->txtDeep.Handle <> 0), "-1")
		B3Check("deep check has a window",Str(pB3->chkDeep.Handle <> 0), "-1")
		'' The parent chain is the nesting, so assert it rather than assuming it.
		B3Check("label's parent is the groupbox",  Str(pB3->lblDeep.Parent  = @pB3->grpInner), "-1")
		B3Check("groupbox's parent is the panel",  Str(pB3->grpInner.Parent = @pB3->pnlOuter), "-1")
		B3Check("panel's parent is the tab page",  Str(pB3->pnlOuter.Parent = pB3->pgOne), "-1")
		B3Check("nested text value", pB3->txtDeep.Text, "nested-value")

		pB3->hPanelBefore = pB3->pnlOuter.Handle
		pB3->hGroupBefore = pB3->grpInner.Handle
		pB3->hLabelBefore = pB3->lblDeep.Handle
		pB3->hTextBefore  = pB3->txtDeep.Handle
		pB3->hCheckBefore = pB3->chkDeep.Handle
		pB3->chkDeep.Checked = True
		pB3->Stage = 1

	Case 1
		'' Switch to the other page, so the nested page is hidden.
		pB3->tabs.SelectedTabIndex = 1
		pB3->Stage = 2

	Case 2
		B3Check("switched to the other tab", Str(pB3->tabs.SelectedTabIndex), "1")
		pB3->Stage = 3

	Case 3
		'' ...and back again.
		pB3->tabs.SelectedTabIndex = 0
		pB3->Stage = 4

	Case 4
		B3Say("-- after switching away and back --")
		B3Check("back on the nested tab", Str(pB3->tabs.SelectedTabIndex), "0")
		'' The assertion this scenario exists for: the children must be the SAME windows, not
		'' faithful copies. A changed handle silently breaks anything bound to the old one.
		B3Check("panel handle unchanged",    Str(pB3->pnlOuter.Handle = pB3->hPanelBefore), "-1")
		B3Check("groupbox handle unchanged", Str(pB3->grpInner.Handle = pB3->hGroupBefore), "-1")
		B3Check("label handle unchanged",    Str(pB3->lblDeep.Handle  = pB3->hLabelBefore), "-1")
		B3Check("text handle unchanged",     Str(pB3->txtDeep.Handle  = pB3->hTextBefore), "-1")
		B3Check("check handle unchanged",    Str(pB3->chkDeep.Handle  = pB3->hCheckBefore), "-1")
		'' State and content must survive too.
		B3Check("nested text survived the switch", pB3->txtDeep.Text, "nested-value")
		B3Check("nested checkbox state survived",  Str(pB3->chkDeep.Checked), "true")
		B3Check("parent chain still intact",       Str(pB3->lblDeep.Parent = @pB3->grpInner), "-1")
		'' And the nested controls should be visible again with the page.
		B3Check("deep label visible again",  Str(pB3->lblDeep.Visible), "true")
		B3Check("deep text visible again",   Str(pB3->txtDeep.Visible), "true")

		B3Say("")
		B3Say("B3 RESULT: " & Str(pB3->Pass) & " passed, " & Str(pB3->Fail) & " failed")
		If pB3->Fail = 0 Then
			B3Say("B3 OVERALL: PASS")
			End 0
		Else
			B3Say("B3 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b3_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B3Form f
pB3 = @f
f.Show
App.Run
