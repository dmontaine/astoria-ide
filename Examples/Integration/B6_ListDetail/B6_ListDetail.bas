'' TestPlan.md B6 -- list/detail.
''
'' A ListView on the left whose selection drives detail TextBoxes on the right: the second most
'' common form shape after data entry, and the simplest case of one control's event changing
'' another control's contents. Testing each control alone can never catch a broken event route
'' between them.
''
'' SELF-DRIVING AND SELF-EXITING. It focuses the ListView and posts real arrow-key messages to its
'' own handle, so selection changes travel the same path a user's keypress does, then exits. An
'' earlier version was driven from an outside script, which parked a window on the tester's
'' desktop for as long as that script ran.
''
'' A finding worth keeping from writing this: sending LVM_SETITEMSTATE from outside the process
'' did NOT raise OnSelectedItemChanged, while keyboard selection does. Anyone automating a
'' ListView should drive it with keys rather than by setting item state directly.
''
'' Run it and read b6_result.txt. It needs no interaction and closes itself.

#include once "mff/Form.bi"
#include once "mff/ListView.bi"
#include once "mff/TextBox.bi"
#include once "mff/Label.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B6_WATCHDOG_TICKS = 60      '' 60 x 250ms = 15 seconds, hard upper bound

Type B6Form Extends Form
	Declare Static Sub lvPeople_SelectedItemChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As ListView lvPeople
	Dim As Label lblName, lblRole
	Dim As TextBox txtName, txtRole
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Fires, Pass, Fail
	Dim As Integer LastIndex
	Dim As UString LastName, LastRole
End Type

Dim Shared As B6Form Ptr pB6

Sub B6Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b6_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B6Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB6 = 0 Then Exit Sub
	If Got = Want Then
		pB6->Pass += 1
		B6Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB6->Fail += 1
		B6Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

Constructor B6Form
	With This
		.Name = "B6Form"
		.Text = "B6 list detail test"
		.Designer = @This
		.SetBounds 0, 0, 720, 420
	End With
	With lvPeople
		.Name = "lvPeople"
		.Align = DockStyle.alLeft
		.Width = 340
		.FullRowSelect = True
		.View = ViewStyle.vsDetails
		.Designer = @This
		.OnSelectedItemChanged = @lvPeople_SelectedItemChanged_
		.Parent = @This
	End With
	With lblName
		.Name = "lblName" : .Text = "Name:"
		.SetBounds 360, 20, 60, 20 : .Designer = @This : .Parent = @This
	End With
	With txtName
		.Name = "txtName" : .Text = ""
		.SetBounds 430, 18, 260, 24 : .Designer = @This : .Parent = @This
	End With
	With lblRole
		.Name = "lblRole" : .Text = "Role:"
		.SetBounds 360, 56, 60, 20 : .Designer = @This : .Parent = @This
	End With
	With txtRole
		.Name = "txtRole" : .Text = ""
		.SetBounds 430, 54, 260, 24 : .Designer = @This : .Parent = @This
	End With
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With

	lvPeople.Columns.Add("Name"), , 160
	lvPeople.Columns.Add("Role"), , 160
	lvPeople.ListItems.Add "Ada"
	lvPeople.ListItems.Item(0)->Text(1) = "Mathematician"
	lvPeople.ListItems.Add "Grace"
	lvPeople.ListItems.Item(1)->Text(1) = "Rear Admiral"
	lvPeople.ListItems.Add "Alan"
	lvPeople.ListItems.Item(2)->Text(1) = "Cryptanalyst"
End Constructor

'' The whole point of the test: a selection in one control writing into two others.
Sub B6Form.lvPeople_SelectedItemChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	If pB6 = 0 Then Exit Sub
	pB6->Fires += 1
	Dim As UString nameText, roleText
	If ItemIndex >= 0 AndAlso ItemIndex < pB6->lvPeople.ListItems.Count Then
		nameText = pB6->lvPeople.ListItems.Item(ItemIndex)->Text(0)
		roleText = pB6->lvPeople.ListItems.Item(ItemIndex)->Text(1)
	End If
	'' Push into the detail controls, then read them BACK out, so what is recorded is what the
	'' TextBoxes actually hold rather than what we meant to put there.
	pB6->txtName.Text = nameText
	pB6->txtRole.Text = roleText
	pB6->LastIndex = ItemIndex
	pB6->LastName  = pB6->txtName.Text
	pB6->LastRole  = pB6->txtRole.Text
End Sub

Sub B6Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB6 = 0 Then Exit Sub
	pB6->Ticks += 1
	If pB6->Ticks > B6_WATCHDOG_TICKS Then
		B6Say("watchdog fired at stage " & Str(pB6->Stage))
		B6Say("B6 OVERALL: FAIL")
		End 1
	End If

	Select Case pB6->Stage
	Case 0
		If pB6->Ticks < 2 Then Exit Sub
		'' Focus the list, then drive it with real key messages. Use the control's own SetFocus
		'' rather than the Win32 one -- the names collide inside a member Sub.
		pB6->lvPeople.SetFocus
		pB6->Stage = 1
	Case 1
		Dim As Integer firesBefore = pB6->Fires
		SendMessageW(pB6->lvPeople.Handle, WM_KEYDOWN, VK_DOWN, 0)
		SendMessageW(pB6->lvPeople.Handle, WM_KEYUP, VK_DOWN, 0)
		B6Say("-- after first Down --")
		B6Check("selection moved to row 1", Str(pB6->LastIndex), "1")
		B6Check("detail name follows selection", pB6->LastName, "Grace")
		B6Check("detail role follows selection", pB6->LastRole, "Rear Admiral")
		B6Check("event fired exactly once", Str(pB6->Fires - firesBefore), "1")
		pB6->Stage = 2
	Case 2
		Dim As Integer firesBefore = pB6->Fires
		SendMessageW(pB6->lvPeople.Handle, WM_KEYDOWN, VK_DOWN, 0)
		SendMessageW(pB6->lvPeople.Handle, WM_KEYUP, VK_DOWN, 0)
		B6Say("-- after second Down --")
		B6Check("selection moved to row 2", Str(pB6->LastIndex), "2")
		B6Check("detail name follows selection", pB6->LastName, "Alan")
		B6Check("detail role follows selection", pB6->LastRole, "Cryptanalyst")
		B6Check("event fired exactly once", Str(pB6->Fires - firesBefore), "1")
		pB6->Stage = 3
	Case 3
		Dim As Integer firesBefore = pB6->Fires
		SendMessageW(pB6->lvPeople.Handle, WM_KEYDOWN, VK_UP, 0)
		SendMessageW(pB6->lvPeople.Handle, WM_KEYUP, VK_UP, 0)
		B6Say("-- after Up --")
		B6Check("selection moved back to row 1", Str(pB6->LastIndex), "1")
		B6Check("detail name follows selection", pB6->LastName, "Grace")
		B6Check("detail role follows selection", pB6->LastRole, "Rear Admiral")
		B6Check("event fired exactly once", Str(pB6->Fires - firesBefore), "1")
		pB6->Stage = 4
	Case 4
		B6Say("")
		B6Say("B6 RESULT: " & Str(pB6->Pass) & " passed, " & Str(pB6->Fail) & " failed")
		If pB6->Fail = 0 Then
			B6Say("B6 OVERALL: PASS")
			End 0
		Else
			B6Say("B6 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b6_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B6Form f
pB6 = @f
f.Show
App.Run
