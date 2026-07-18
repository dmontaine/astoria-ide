'' TestPlan.md B13 -- many different controls on one form.
''
'' A blunt density check. Every other scenario uses a handful of controls; this one puts 26
'' different types on a single form at once and asks whether anything breaks that only breaks at
'' scale: window handles failing to be created, control IDs colliding, a shared resource running
'' out, or one control's creation disturbing another's.
''
'' It is deliberately cheap to run and cheap to read. The assertions are the ones that catch
'' resource problems rather than layout ones:
''   - every control got a real window handle (a failed creation shows up as 0)
''   - every handle is DISTINCT (a collision would mean two controls sharing one window)
''   - a sample of controls still report the text and state they were given, so a later control's
''     creation did not corrupt an earlier one
''   - the message loop is still running afterwards
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b13_result.txt.

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/LinkLabel.bi"
#include once "mff/TextBox.bi"
#include once "mff/RichTextBox.bi"
#include once "mff/CommandButton.bi"
#include once "mff/CheckBox.bi"
#include once "mff/RadioButton.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/CheckedListBox.bi"
#include once "mff/ListView.bi"
#include once "mff/TreeView.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/TrackBar.bi"
#include once "mff/DateTimePicker.bi"
#include once "mff/MonthCalendar.bi"
#include once "mff/GroupBox.bi"
#include once "mff/Panel.bi"
#include once "mff/StatusBar.bi"
#include once "mff/ToolBar.bi"
#include once "mff/HScrollBar.bi"
#include once "mff/VScrollBar.bi"
#include once "mff/NumericUpDown.bi"
#include once "mff/ImageBox.bi"
#include once "mff/HotKey.bi"
#include once "mff/IPAddress.bi"
#include once "mff/Splitter.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B13_WATCHDOG_TICKS = 60
Const B13_COUNT = 26

Type B13Form Extends Form
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As Label          c01
	Dim As LinkLabel      c02
	Dim As TextBox        c03
	Dim As RichTextBox    c04
	Dim As CommandButton  c05
	Dim As CheckBox       c06
	Dim As RadioButton    c07
	Dim As ComboBoxEdit   c08
	Dim As CheckedListBox c09
	Dim As ListView       c10
	Dim As TreeView       c11
	Dim As ProgressBar    c12
	Dim As TrackBar       c13
	Dim As DateTimePicker c14
	Dim As MonthCalendar  c15
	Dim As GroupBox       c16
	Dim As Panel          c17
	Dim As StatusBar      c18
	Dim As ToolBar        c19
	Dim As HScrollBar     c20
	Dim As VScrollBar     c21
	Dim As NumericUpDown  c22
	Dim As ImageBox       c23
	Dim As HotKey         c24
	Dim As IPAddress      c25
	Dim As Splitter       c26
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Pass, Fail
End Type

Dim Shared As B13Form Ptr pB13

Sub B13Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b13_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B13Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB13 = 0 Then Exit Sub
	If Got = Want Then
		pB13->Pass += 1
		B13Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB13->Fail += 1
		B13Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

'' Places a control in a simple grid so nothing overlaps and the form stays readable.
Sub B13Place(ByRef Ctl As Control, ByVal Index As Integer, ByRef Parent As Control, ByRef Designer As Any Ptr)
	Dim As Integer col = Index Mod 3
	Dim As Integer row = Index \ 3
	Ctl.SetBounds 12 + col * 300, 12 + row * 56, 280, 46
	Ctl.Designer = Designer
	Ctl.Parent = @Parent
End Sub

Constructor B13Form
	With This
		.Name = "B13Form"
		.Text = "B13 control density test"
		.Designer = @This
		.SetBounds 0, 0, 960, 620
	End With
	c01.Name = "c01" : c01.Text = "Label"           : B13Place(c01,  0, This, @This)
	c02.Name = "c02" : c02.Text = "LinkLabel"       : B13Place(c02,  1, This, @This)
	c03.Name = "c03" : c03.Text = "TextBox value"   : B13Place(c03,  2, This, @This)
	c04.Name = "c04" : c04.Text = "RichTextBox"     : B13Place(c04,  3, This, @This)
	c05.Name = "c05" : c05.Text = "CommandButton"   : B13Place(c05,  4, This, @This)
	c06.Name = "c06" : c06.Text = "CheckBox"        : B13Place(c06,  5, This, @This)
	c07.Name = "c07" : c07.Text = "RadioButton"     : B13Place(c07,  6, This, @This)
	c08.Name = "c08" : c08.Text = "ComboBoxEdit"    : B13Place(c08,  7, This, @This)
	c09.Name = "c09" : c09.Text = "CheckedListBox"  : B13Place(c09,  8, This, @This)
	c10.Name = "c10" : c10.Text = "ListView"        : B13Place(c10,  9, This, @This)
	c11.Name = "c11" : c11.Text = "TreeView"        : B13Place(c11, 10, This, @This)
	c12.Name = "c12" : c12.Text = "ProgressBar"     : B13Place(c12, 11, This, @This)
	c13.Name = "c13" : c13.Text = "TrackBar"        : B13Place(c13, 12, This, @This)
	c14.Name = "c14" : c14.Text = "DateTimePicker"  : B13Place(c14, 13, This, @This)
	c15.Name = "c15" : c15.Text = "MonthCalendar"   : B13Place(c15, 14, This, @This)
	c16.Name = "c16" : c16.Text = "GroupBox"        : B13Place(c16, 15, This, @This)
	c17.Name = "c17" : c17.Text = "Panel"           : B13Place(c17, 16, This, @This)
	c18.Name = "c18" : c18.Text = "StatusBar"       : c18.Designer = @This : c18.Parent = @This
	c19.Name = "c19" : c19.Text = "ToolBar"         : B13Place(c19, 17, This, @This)
	c20.Name = "c20" : c20.Text = "HScrollBar"      : B13Place(c20, 18, This, @This)
	c21.Name = "c21" : c21.Text = "VScrollBar"      : B13Place(c21, 19, This, @This)
	c22.Name = "c22" : c22.Text = "NumericUpDown"   : B13Place(c22, 20, This, @This)
	c23.Name = "c23" : c23.Text = "ImageBox"        : B13Place(c23, 21, This, @This)
	c24.Name = "c24" : c24.Text = "HotKey"          : B13Place(c24, 22, This, @This)
	c25.Name = "c25" : c25.Text = "IPAddress"       : B13Place(c25, 23, This, @This)
	c26.Name = "c26" : c26.Text = "Splitter"        : B13Place(c26, 24, This, @This)
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With
End Constructor

Sub B13Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB13 = 0 Then Exit Sub
	pB13->Ticks += 1
	If pB13->Ticks > B13_WATCHDOG_TICKS Then
		B13Say("watchdog fired")
		B13Say("B13 OVERALL: FAIL")
		End 1
	End If
	If pB13->Ticks < 4 Then Exit Sub      '' let every control finish creating

	'' Collect the handles once, then reason about them.
	Dim As HWND h(1 To B13_COUNT)
	h(1)  = pB13->c01.Handle : h(2)  = pB13->c02.Handle : h(3)  = pB13->c03.Handle
	h(4)  = pB13->c04.Handle : h(5)  = pB13->c05.Handle : h(6)  = pB13->c06.Handle
	h(7)  = pB13->c07.Handle : h(8)  = pB13->c08.Handle : h(9)  = pB13->c09.Handle
	h(10) = pB13->c10.Handle : h(11) = pB13->c11.Handle : h(12) = pB13->c12.Handle
	h(13) = pB13->c13.Handle : h(14) = pB13->c14.Handle : h(15) = pB13->c15.Handle
	h(16) = pB13->c16.Handle : h(17) = pB13->c17.Handle : h(18) = pB13->c18.Handle
	h(19) = pB13->c19.Handle : h(20) = pB13->c20.Handle : h(21) = pB13->c21.Handle
	h(22) = pB13->c22.Handle : h(23) = pB13->c23.Handle : h(24) = pB13->c24.Handle
	h(25) = pB13->c25.Handle : h(26) = pB13->c26.Handle

	B13Say("-- " & Str(B13_COUNT) & " different control types on one form --")

	'' 1. every control created a window
	Dim As Integer created
	For i As Integer = 1 To B13_COUNT
		If h(i) <> 0 Then created += 1 Else B13Say("   control " & Str(i) & " has NO handle")
	Next
	B13Check("controls with a real window handle", Str(created), Str(B13_COUNT))

	'' 2. no two controls share a handle
	Dim As Integer dupes
	For i As Integer = 1 To B13_COUNT
		For j As Integer = i + 1 To B13_COUNT
			If h(i) <> 0 AndAlso h(i) = h(j) Then
				dupes += 1
				B13Say("   controls " & Str(i) & " and " & Str(j) & " share a handle")
			End If
		Next j
	Next i
	B13Check("duplicate handles", Str(dupes), "0")

	'' 3. a sample of controls still hold what they were given -- a later control's creation
	''    must not have disturbed an earlier one
	B13Check("first control's text intact",  pB13->c01.Text, "Label")
	B13Check("middle control's text intact", pB13->c13.Text, "TrackBar")
	B13Check("last control's text intact",   pB13->c26.Text, "Splitter")
	B13Check("text control still readable",  pB13->c03.Text, "TextBox value")

	'' 4. the form is still alive and pumping after creating everything
	B13Check("message loop still running", Str(pB13->Ticks >= 4), "-1")

	B13Say("")
	B13Say("B13 RESULT: " & Str(pB13->Pass) & " passed, " & Str(pB13->Fail) & " failed")
	If pB13->Fail = 0 Then
		B13Say("B13 OVERALL: PASS")
		End 0
	Else
		B13Say("B13 OVERALL: FAIL")
		End 1
	End If
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b13_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B13Form f
pB13 = @f
f.Show
App.Run
