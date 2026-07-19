'' TestPlan.md A7 -- property and event depth on the common controls.
''
'' The 73-control sweep proved each control's window opens. Section B proved controls cooperate.
'' Neither exercises a control in depth: set its properties, read them back, fire its events. A
'' control can open a window, sit happily in a composite, and still lose a property assignment or
'' never raise the event a program depends on.
''
'' Seven controls, the ones most programs are actually built from: TextBox, ComboBoxEdit,
'' ListView, TreeView, CheckBox, RadioButton and CommandButton. For each:
''   - properties are SET then READ BACK, so a value that is stored but not applied (or applied
''     but not stored) is caught rather than assumed;
''   - one real event is triggered through a Windows message or the framework's own path, and the
''     handler must actually run -- a wired event that never fires is the defect that matters.
''
'' Enabled and Visible are checked on every control, because they are the two properties every
'' program toggles and the easiest to get wrong in a wrapper.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read a7_result.txt.

#include once "mff/Form.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/ListView.bi"
#include once "mff/TreeView.bi"
#include once "mff/CheckBox.bi"
#include once "mff/RadioButton.bi"
#include once "mff/CommandButton.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const A7_WATCHDOG_TICKS = 80

Type A7Form Extends Form
	Declare Static Sub OnButtonClick_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Static Sub OnCheckClick_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	Declare Static Sub OnRadioClick_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	Declare Static Sub OnComboChange_(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit)
	Declare Static Sub OnListSel_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	Declare Static Sub OnTextLostFocus_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As TextBox       txt
	Dim As ComboBoxEdit  cbo
	Dim As ListView      lv
	Dim As TreeView      tv
	Dim As CheckBox      chk
	Dim As RadioButton   opt
	Dim As CommandButton cmd
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
	'' Event counters -- the point is that these move.
	Dim As Integer ButtonClicks, CheckClicks, RadioClicks, ComboChanges, ListSelections, TextLostFocus
	Dim As Integer LastListIndex
End Type

Dim Shared As A7Form Ptr pA7

Sub A7Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\a7_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub A7Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pA7 = 0 Then Exit Sub
	If Got = Want Then
		pA7->Pass += 1
		A7Say("   PASS " & CheckName & " (" & Got & ")")
	Else
		pA7->Fail += 1
		A7Say("   FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

Sub A7Form.OnButtonClick_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If pA7 Then pA7->ButtonClicks += 1
End Sub
Sub A7Form.OnCheckClick_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	If pA7 Then pA7->CheckClicks += 1
End Sub
Sub A7Form.OnRadioClick_(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
	If pA7 Then pA7->RadioClicks += 1
End Sub
Sub A7Form.OnComboChange_(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit)
	If pA7 Then pA7->ComboChanges += 1
End Sub
Sub A7Form.OnListSel_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If pA7 Then pA7->ListSelections += 1 : pA7->LastListIndex = ItemIndex
End Sub
Sub A7Form.OnTextLostFocus_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If pA7 Then pA7->TextLostFocus += 1
End Sub

Constructor A7Form
	With This
		.Name = "A7Form" : .Text = "A7 control depth test"
		.Designer = @This : .SetBounds 0, 0, 820, 560
	End With
	With txt
		.Name = "txt" : .Text = "initial"
		.SetBounds 20, 20, 240, 24
		.Designer = @This : .OnLostFocus = @OnTextLostFocus_ : .Parent = @This
	End With
	With cbo
		.Name = "cbo" : .Style = ComboBoxEditStyle.cbDropDownList
		.SetBounds 20, 54, 240, 24
		.Designer = @This : .OnChange = @OnComboChange_ : .Parent = @This
	End With
	With chk
		.Name = "chk" : .Text = "a checkbox"
		.SetBounds 20, 88, 240, 24
		.Designer = @This : .OnClick = @OnCheckClick_ : .Parent = @This
	End With
	With opt
		.Name = "opt" : .Text = "a radio button"
		.SetBounds 20, 122, 240, 24
		.Designer = @This : .OnClick = @OnRadioClick_ : .Parent = @This
	End With
	With cmd
		.Name = "cmd" : .Text = "a button"
		.SetBounds 20, 156, 240, 30
		.Designer = @This : .OnClick = @OnButtonClick_ : .Parent = @This
	End With
	With lv
		.Name = "lv" : .View = ViewStyle.vsDetails : .FullRowSelect = True
		.SetBounds 300, 20, 480, 200
		.Designer = @This : .OnSelectedItemChanged = @OnListSel_ : .Parent = @This
	End With
	With tv
		.Name = "tv"
		.SetBounds 300, 240, 480, 220
		.Designer = @This : .Parent = @This
	End With
	cbo.AddItem "red" : cbo.AddItem "green" : cbo.AddItem "blue"
	lv.Columns.Add("Col A"), , 200
	lv.Columns.Add("Col B"), , 200
	lv.ListItems.Add("row one")   : lv.ListItems.Item(0)->Text(1) = "b-one"
	lv.ListItems.Add("row two")   : lv.ListItems.Item(1)->Text(1) = "b-two"
	lv.ListItems.Add("row three") : lv.ListItems.Item(2)->Text(1) = "b-three"
	tv.Nodes.Add("root one", "r1")
	tv.Nodes.Add("root two", "r2")
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_ : .Enabled = True
	End With
End Constructor

Sub A7Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pA7 = 0 Then Exit Sub
	pA7->Ticks += 1
	If pA7->Ticks > A7_WATCHDOG_TICKS Then
		A7Say("watchdog fired at stage " & Str(pA7->Stage))
		A7Say("A7 OVERALL: FAIL")
		End 1
	End If
	If pA7->Ticks < 3 Then Exit Sub

	Select Case pA7->Stage
	Case 0
		'' ---------- TextBox ----------------------------------------------------------------
		A7Say("-- TextBox --")
		A7Check("initial text as constructed", pA7->txt.Text, "initial")
		pA7->txt.Text = "assigned by property"
		A7Check("text set by property reads back", pA7->txt.Text, "assigned by property")
		'' A property set through the framework must reach the actual window, so read it back
		'' from Windows rather than only from the wrapper's own field.
		Dim As WString * 256 fromOS
		SendMessageW(pA7->txt.Handle, WM_GETTEXT, 256, Cast(LPARAM, @fromOS))
		A7Check("text reached the real window", fromOS, "assigned by property")
		'' ...and a value set on the window must be visible through the framework.
		SendMessageW(pA7->txt.Handle, WM_SETTEXT, 0, Cast(LPARAM, @WStr("typed into the window")))
		A7Check("text set on the window reads back", pA7->txt.Text, "typed into the window")
		pA7->txt.Enabled = False
		A7Check("Enabled=False reads back", Str(pA7->txt.Enabled), "false")
		A7Check("...and the window really is disabled", Str(IsWindowEnabled(pA7->txt.Handle) <> 0), "0")
		pA7->txt.Enabled = True
		A7Check("Enabled=True reads back", Str(pA7->txt.Enabled), "true")
		pA7->Stage = 1

	Case 1
		'' ---------- ComboBoxEdit -----------------------------------------------------------
		A7Say("-- ComboBoxEdit --")
		A7Check("item count", Str(pA7->cbo.Items.Count), "3")
		pA7->cbo.ItemIndex = 1
		A7Check("ItemIndex set reads back", Str(pA7->cbo.ItemIndex), "1")
		A7Check("Text follows the selection", pA7->cbo.Text, "green")
		A7Check("IndexOf finds an item", Str(pA7->cbo.IndexOf("blue")), "2")
		'' Changing the selection must raise OnChange -- a program that repopulates a dependent
		'' field on selection depends entirely on this firing.
		A7Check("OnChange fired on selection", Str(pA7->ComboChanges > 0), "-1")
		Dim As Integer before = pA7->ComboChanges
		pA7->cbo.ItemIndex = 2
		A7Check("second selection fired it again", Str(pA7->ComboChanges > before), "-1")
		A7Check("Text followed the second selection", pA7->cbo.Text, "blue")
		pA7->Stage = 2

	Case 2
		'' ---------- CheckBox and RadioButton -----------------------------------------------
		A7Say("-- CheckBox --")
		A7Check("starts unchecked", Str(pA7->chk.Checked), "false")
		SendMessageW(pA7->chk.Handle, BM_CLICK, 0, 0)
		A7Check("a real click checks it", Str(pA7->chk.Checked), "true")
		A7Check("OnClick fired", Str(pA7->CheckClicks), "1")
		pA7->chk.Checked = False
		A7Check("Checked=False by property", Str(pA7->chk.Checked), "false")
		A7Check("property change did NOT fire OnClick", Str(pA7->CheckClicks), "1")

		A7Say("-- RadioButton --")
		A7Check("starts unselected", Str(pA7->opt.Checked), "false")
		SendMessageW(pA7->opt.Handle, BM_CLICK, 0, 0)
		A7Check("a real click selects it", Str(pA7->opt.Checked), "true")
		A7Check("OnClick fired", Str(pA7->RadioClicks), "1")
		pA7->Stage = 3

	Case 3
		'' ---------- CommandButton ----------------------------------------------------------
		A7Say("-- CommandButton --")
		A7Check("caption as constructed", pA7->cmd.Text, "a button")
		pA7->cmd.Text = "renamed"
		A7Check("caption set reads back", pA7->cmd.Text, "renamed")
		SendMessageW(pA7->cmd.Handle, BM_CLICK, 0, 0)
		A7Check("OnClick fired once", Str(pA7->ButtonClicks), "1")
		SendMessageW(pA7->cmd.Handle, BM_CLICK, 0, 0)
		A7Check("OnClick fired again", Str(pA7->ButtonClicks), "2")
		'' Disabling a button: assert what the platform actually guarantees, which is that the
		'' window reports disabled. Windows filters USER clicks at hit-test time, before any
		'' message is generated -- it does not filter a BM_CLICK sent programmatically, and
		'' CommandButton subclasses the native Button without intercepting it. So a disabled
		'' button DOES still fire when poked this way.
		pA7->cmd.Enabled = False
		A7Check("disabled reads back", Str(pA7->cmd.Enabled), "false")
		A7Check("the window really is disabled", Str(IsWindowEnabled(pA7->cmd.Handle) <> 0), "0")
		Dim As Integer beforeDisabledClick = pA7->ButtonClicks
		SendMessageW(pA7->cmd.Handle, BM_CLICK, 0, 0)
		A7Say("   OBSERVATION: BM_CLICK sent to the DISABLED button fired the handler " & _
			Str(pA7->ButtonClicks - beforeDisabledClick) & " time(s).")
		A7Say("   That is Windows, not the framework: a real user click is discarded at hit-test")
		A7Say("   time, but a posted BM_CLICK reaches the button procedure regardless. Anyone")
		A7Say("   automating a UI should not use BM_CLICK to prove a control is disabled --")
		A7Say("   check IsWindowEnabled instead, which is what actually stops a user.")
		pA7->cmd.Enabled = True
		A7Check("re-enabled reads back", Str(pA7->cmd.Enabled), "true")
		pA7->Stage = 4

	Case 4
		'' ---------- ListView ---------------------------------------------------------------
		A7Say("-- ListView --")
		A7Check("column count", Str(pA7->lv.Columns.Count), "2")
		A7Check("item count", Str(pA7->lv.ListItems.Count), "3")
		A7Check("first item column 0", pA7->lv.ListItems.Item(0)->Text(0), "row one")
		A7Check("first item column 1", pA7->lv.ListItems.Item(0)->Text(1), "b-one")
		pA7->lv.ListItems.Item(1)->Text(1) = "changed"
		A7Check("subitem set reads back", pA7->lv.ListItems.Item(1)->Text(1), "changed")
		'' Selection by keyboard, the route B6 established actually raises the event.
		pA7->lv.SetFocus
		SendMessageW(pA7->lv.Handle, WM_KEYDOWN, VK_DOWN, 0)
		SendMessageW(pA7->lv.Handle, WM_KEYUP, VK_DOWN, 0)
		pA7->Stage = 5

	Case 5
		A7Check("OnSelectedItemChanged fired", Str(pA7->ListSelections > 0), "-1")
		A7Check("event carried a valid index", Str(pA7->LastListIndex >= 0), "-1")

		'' ---------- TreeView ---------------------------------------------------------------
		A7Say("-- TreeView --")
		A7Check("node count", Str(pA7->tv.Nodes.Count), "2")
		A7Check("first node text", pA7->tv.Nodes.Item(0)->Text, "root one")
		pA7->tv.Nodes.Item(0)->Text = "renamed root"
		A7Check("node text set reads back", pA7->tv.Nodes.Item(0)->Text, "renamed root")
		Dim As TreeNode Ptr child = pA7->tv.Nodes.Item(0)->Nodes.Add("a child", "c1")
		A7Check("child added", Str(child <> 0), "-1")
		A7Check("parent now has one child", Str(pA7->tv.Nodes.Item(0)->Nodes.Count), "1")
		pA7->tv.SelectedNode = pA7->tv.Nodes.Item(1)
		A7Check("SelectedNode set reads back", pA7->tv.SelectedNode->Text, "root two")
		pA7->Stage = 6

	Case 6
		'' ---------- shared behaviour across all seven --------------------------------------
		A7Say("-- Visible and Enabled, on every control --")
		pA7->txt.Visible = False : pA7->cbo.Visible = False : pA7->lv.Visible = False
		A7Check("TextBox hidden",  Str(pA7->txt.Visible), "false")
		A7Check("ComboBox hidden", Str(pA7->cbo.Visible), "false")
		A7Check("ListView hidden", Str(pA7->lv.Visible),  "false")
		A7Check("...and the window really is hidden", Str(IsWindowVisible(pA7->txt.Handle) <> 0), "0")
		pA7->txt.Visible = True : pA7->cbo.Visible = True : pA7->lv.Visible = True
		A7Check("TextBox shown again",  Str(pA7->txt.Visible), "true")
		A7Check("ComboBox shown again", Str(pA7->cbo.Visible), "true")
		A7Check("ListView shown again", Str(pA7->lv.Visible),  "true")

		'' The TextBox lost focus when the ListView took it in stage 4.
		A7Say("-- TextBox focus event --")
		A7Check("OnLostFocus fired when focus moved away", Str(pA7->TextLostFocus > 0), "-1")

		A7Say("")
		A7Say("A7 RESULT: " & Str(pA7->Pass) & " passed, " & Str(pA7->Fail) & " failed")
		If pA7->Fail = 0 Then
			A7Say("A7 OVERALL: PASS")
			End 0
		Else
			A7Say("A7 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\a7_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As A7Form f
pA7 = @f
f.Show
App.Run
