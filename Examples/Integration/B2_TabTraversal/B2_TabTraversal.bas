'' TestPlan.md B2 -- tab order and keyboard traversal.
''
'' Six controls with explicit TabIndex values, traversed by the keyboard alone. Keyboard
'' navigation across mixed control types is the thing a mouse-driven test never checks, and it is
'' what someone who cannot use a mouse depends on entirely.
''
'' How the framework does it: the message pump intercepts WM_KEYDOWN/VK_TAB and calls
'' Form.SelectNextControl(backwards), where "backwards" is GetKeyState(VK_SHIFT). So this test
'' posts a real VK_TAB into the queue -- posted, not sent, because a sent message bypasses the
'' pump that does the intercepting -- and then reads which control actually has the focus.
''
'' Shift is simulated with SetKeyboardState rather than by injecting a real keystroke: it changes
'' only this thread's keyboard state, which is exactly what GetKeyState reads, so the test cannot
'' disturb whatever else the machine is doing.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b2_result.txt.

#include once "mff/Form.bi"
#include once "mff/TextBox.bi"
#include once "mff/CheckBox.bi"
#include once "mff/CommandButton.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B2_WATCHDOG_TICKS = 80

Type B2Form Extends Form
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As TextBox       t0, t1
	Dim As CheckBox      c2
	Dim As ComboBoxEdit  b3
	Dim As CommandButton d4, d5
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
End Type

Dim Shared As B2Form Ptr pB2

Sub B2Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b2_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B2Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB2 = 0 Then Exit Sub
	If Got = Want Then
		pB2->Pass += 1
		B2Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB2->Fail += 1
		B2Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

'' Which of the six controls currently holds the focus, by name.
Function B2Focused() As String
	If pB2 = 0 Then Return "?"
	Dim As HWND h = GetFocus()
	If h = pB2->t0.Handle Then Return "t0"
	If h = pB2->t1.Handle Then Return "t1"
	If h = pB2->c2.Handle Then Return "c2"
	If h = pB2->b3.Handle Then Return "b3"
	If h = pB2->d4.Handle Then Return "d4"
	If h = pB2->d5.Handle Then Return "d5"
	Return "none"
End Function

'' Presses Tab through the message queue. Posted, not sent: the pump is what turns VK_TAB into
'' a focus change, and a sent message never reaches it.
Sub B2PressTab(ByVal WithShift As Boolean)
	If pB2 = 0 Then Exit Sub
	Dim ks(0 To 255) As UByte
	If WithShift Then
		GetKeyboardState(@ks(0))
		ks(VK_SHIFT) = &h80            '' high bit = key down, which is what GetKeyState reports
		SetKeyboardState(@ks(0))
	End If
	PostMessage(GetFocus(), WM_KEYDOWN, VK_TAB, 0)
	PostMessage(GetFocus(), WM_KEYUP,   VK_TAB, 0)
End Sub

Sub B2ReleaseShift()
	Dim ks(0 To 255) As UByte
	GetKeyboardState(@ks(0))
	ks(VK_SHIFT) = 0
	SetKeyboardState(@ks(0))
End Sub

Constructor B2Form
	With This
		.Name = "B2Form" : .Text = "B2 tab traversal test"
		.Designer = @This : .SetBounds 0, 0, 520, 340
	End With
	With t0
		.Name = "t0" : .Text = "first" : .TabIndex = 0
		.SetBounds 20, 20, 200, 24 : .Designer = @This : .Parent = @This
	End With
	With t1
		.Name = "t1" : .Text = "second" : .TabIndex = 1
		.SetBounds 20, 54, 200, 24 : .Designer = @This : .Parent = @This
	End With
	With c2
		.Name = "c2" : .Text = "third (checkbox)" : .TabIndex = 2
		.SetBounds 20, 88, 200, 24 : .Designer = @This : .Parent = @This
	End With
	With b3
		.Name = "b3" : .TabIndex = 3
		.SetBounds 20, 122, 200, 24 : .Designer = @This : .Parent = @This
	End With
	With d4
		.Name = "d4" : .Text = "fifth" : .TabIndex = 4
		.SetBounds 20, 156, 200, 28 : .Designer = @This : .Parent = @This
	End With
	With d5
		.Name = "d5" : .Text = "sixth" : .TabIndex = 5
		.SetBounds 20, 192, 200, 28 : .Designer = @This : .Parent = @This
	End With
	b3.AddItem "alpha"
	b3.AddItem "beta"
	b3.ItemIndex = 0
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_ : .Enabled = True
	End With
End Constructor

Sub B2Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB2 = 0 Then Exit Sub
	pB2->Ticks += 1
	If pB2->Ticks > B2_WATCHDOG_TICKS Then
		B2Say("watchdog fired at stage " & Str(pB2->Stage))
		B2Say("B2 OVERALL: FAIL")
		End 1
	End If
	If pB2->Ticks < 3 Then Exit Sub

	Select Case pB2->Stage
	Case 0
		pB2->t0.SetFocus
		pB2->Stage = 1
	Case 1
		B2Say("-- forward traversal, in TabIndex order --")
		B2Check("focus starts on the first control", B2Focused(), "t0")
		B2PressTab(False) : pB2->Stage = 2
	Case 2
		B2Check("Tab 1 moved to TabIndex 1", B2Focused(), "t1")
		B2PressTab(False) : pB2->Stage = 3
	Case 3
		B2Check("Tab 2 moved to TabIndex 2", B2Focused(), "c2")
		B2PressTab(False) : pB2->Stage = 4
	Case 4
		B2Check("Tab 3 moved to TabIndex 3", B2Focused(), "b3")
		B2PressTab(False) : pB2->Stage = 5
	Case 5
		B2Check("Tab 4 moved to TabIndex 4", B2Focused(), "d4")
		B2PressTab(False) : pB2->Stage = 6
	Case 6
		B2Check("Tab 5 moved to TabIndex 5", B2Focused(), "d5")
		B2PressTab(False) : pB2->Stage = 7
	Case 7
		'' Sixth Tab from the last control should wrap round to the first.
		B2Check("Tab from the last control wraps to the first", B2Focused(), "t0")
		pB2->Stage = 8

	Case 8
		'' ---- backwards, via SelectNextControl directly ---------------------------------
		'' This is the function the pump calls for Shift+Tab, so it isolates the traversal
		'' itself from whether the shift key is detected.
		B2Say("-- backward traversal, calling SelectNextControl(True) directly --")
		pB2->t1.SetFocus
		pB2->SelectNextControl(True)
		pB2->Stage = 9
	Case 9
		B2Check("SelectNextControl(True) moves backwards", B2Focused(), "t0")
		pB2->Stage = 10

	Case 10
		'' ---- Shift+Tab through the real key path ---------------------------------------
		B2Say("-- backward traversal, by Shift+Tab through the message pump --")
		pB2->t1.SetFocus
		B2PressTab(True)
		'' Report what the framework's own shift test actually evaluates to while shift is
		'' held. The framework writes "GetKeyState(VK_SHIFT) And 8000" -- decimal 8000 is
		'' &h1F40, which shares no bits with the &h8000 down-flag, so by inspection it should
		'' always be false. Measure it rather than trust the reasoning.
		Scope
			Dim As Integer ks = GetKeyState(VK_SHIFT)
			B2Say("   GetKeyState(VK_SHIFT)          = " & Str(ks))
			B2Say("   ... And 8000   (as written)    = " & Str(ks And 8000))
			B2Say("   ... And &h8000 (as intended)   = " & Str(ks And &h8000))
		End Scope
		pB2->Stage = 11
	Case 11
		Dim As String got = B2Focused()
		B2ReleaseShift()
		If got = "t0" Then
			pB2->Pass += 1
			B2Say("PASS Shift+Tab moved backwards (t0)")
		Else
			pB2->Fail += 1
			B2Say("FAIL Shift+Tab moved backwards: expected [t0] got [" & got & "]")
			B2Say("   Shift was not detected, so Shift+Tab behaved as a plain Tab.")
			B2Say("   Cause: the framework tests GetKeyState(VK_SHIFT) And 8000. GetKeyState sets")
			B2Say("   bit &h8000 when a key is down, and 8000 DECIMAL is &h1F40 -- the two share no")
			B2Say("   bits, so the test is always false. It should be And &h8000.")
		End If
		pB2->Stage = 12

	Case 12
		B2Say("")
		B2Say("B2 RESULT: " & Str(pB2->Pass) & " passed, " & Str(pB2->Fail) & " failed")
		If pB2->Fail = 0 Then
			B2Say("B2 OVERALL: PASS")
			End 0
		Else
			B2Say("B2 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b2_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B2Form f
pB2 = @f
f.Show
App.Run
