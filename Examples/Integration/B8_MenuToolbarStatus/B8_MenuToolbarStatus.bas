'' TestPlan.md B8 -- menu, toolbar and status bar together.
''
'' The full application chrome on one form, with the menu item and the toolbar button wired to the
'' SAME handler and the status bar reporting the result. This is what an application window
'' actually looks like, and the three pieces have to coexist: each claims space at the edges of
'' the form, and two different input routes have to reach one piece of logic.
''
'' The assertion worth having is that both routes reach the same handler and produce the same
'' effect. A program where the toolbar quietly does something subtly different from the menu item
'' it mirrors is a real and common defect, and one that testing each control alone cannot see.
''
'' Menu items are invoked through MenuItem.Click and toolbar buttons through their OnClick, which
'' is what the framework itself calls when the user picks either -- toolbar buttons are not
'' separate windows, so there is no handle to post a click to.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b8_result.txt.

#include once "mff/Form.bi"
#include once "mff/Menus.bi"
#include once "mff/ToolBar.bi"
#include once "mff/StatusBar.bi"
#include once "mff/Panel.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B8_WATCHDOG_TICKS = 60

Type B8Form Extends Form
	Declare Static Sub DoAction_(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As MainMenu  mnu
	Dim As ToolBar   tb
	Dim As StatusBar sb
	Dim As Panel     pnlBody
	Dim As TimerComponent tmrSeq
	Dim As MenuItem Ptr miAction
	Dim As ToolButton Ptr btnAction
	Dim As Integer Ticks, Stage, Pass, Fail
	Dim As Integer ActionCount
	Dim As String LastSource
End Type

Dim Shared As B8Form Ptr pB8

Sub B8Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b8_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B8Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB8 = 0 Then Exit Sub
	If Got = Want Then
		pB8->Pass += 1
		B8Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB8->Fail += 1
		B8Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

'' One handler, two callers. The status bar is updated here so both routes produce identical
'' visible effects -- if only one route updated it, the difference would show immediately.
Sub B8Form.DoAction_(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	If pB8 = 0 Then Exit Sub
	pB8->ActionCount += 1
	pB8->sb.Panel(0)->Caption = "action " & Str(pB8->ActionCount) & " from " & pB8->LastSource
End Sub

Constructor B8Form
	With This
		.Name = "B8Form" : .Text = "B8 menu toolbar status test"
		.Designer = @This : .SetBounds 0, 0, 680, 420
	End With
	'' Menu across the top.
	Dim As MenuItem Ptr miFile = mnu.Add("&File", "", "File")
	miAction = miFile->Add("&Do It", "", "DoIt", @DoAction_)
	mnu.ParentWindow = @This
	This.Menu = @mnu
	'' Toolbar under it.
	With tb
		.Name = "tb" : .Align = DockStyle.alTop : .Height = 36
		.Designer = @This : .Parent = @This
	End With
	btnAction = tb.Buttons.Add(ToolButtonStyle.tbsAutosize, -1, , @DoAction_, "btnDoIt", "Do It")
	'' Status bar at the bottom.
	With sb
		.Name = "sb" : .Designer = @This : .Parent = @This
	End With
	sb.Add("ready", 400)
	'' Body fills what is left -- this is what proves the three chrome pieces took their space
	'' from the edges rather than overlapping the content.
	With pnlBody
		.Name = "pnlBody" : .Align = DockStyle.alClient
		.Designer = @This : .Parent = @This
	End With
	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_ : .Enabled = True
	End With
End Constructor

Sub B8Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB8 = 0 Then Exit Sub
	pB8->Ticks += 1
	If pB8->Ticks > B8_WATCHDOG_TICKS Then
		B8Say("watchdog fired at stage " & Str(pB8->Stage))
		B8Say("B8 OVERALL: FAIL")
		End 1
	End If
	If pB8->Ticks < 3 Then Exit Sub

	Select Case pB8->Stage
	Case 0
		B8Say("-- the three pieces of chrome coexist --")
		B8Check("menu is attached",          Str(pB8->Menu <> 0), "-1")
		B8Check("menu item exists",          Str(pB8->miAction <> 0), "-1")
		B8Check("toolbar has a window",      Str(pB8->tb.Handle <> 0), "-1")
		B8Check("toolbar button exists",     Str(pB8->btnAction <> 0), "-1")
		B8Check("status bar has a window",   Str(pB8->sb.Handle <> 0), "-1")
		B8Check("status bar has a panel",    Str(pB8->sb.Count), "1")
		B8Check("status bar starts ready",   pB8->sb.Panel(0)->Caption, "ready")
		B8Check("body panel has a window",   Str(pB8->pnlBody.Handle <> 0), "-1")
		'' Report the actual geometry before asserting on it -- StatusBar positions itself, and
		'' guessing at the relationship is how the first version of this check went wrong.
		B8Say("   client height = " & Str(pB8->ClientHeight))
		B8Say("   toolbar  top=" & Str(pB8->tb.Top) & " height=" & Str(pB8->tb.Height))
		B8Say("   body     top=" & Str(pB8->pnlBody.Top) & " height=" & Str(pB8->pnlBody.Height))
		B8Say("   status   top=" & Str(pB8->sb.Top) & " height=" & Str(pB8->sb.Height))
		'' The body must start below the toolbar: that is what proves the chrome claimed its
		'' space from the edge rather than covering the content.
		B8Check("body starts below the toolbar", Str(pB8->pnlBody.Top >= pB8->tb.Top + pB8->tb.Height), "-1")
		'' And it must not run past the bottom of the client area.
		B8Check("body fits inside the client area", Str(pB8->pnlBody.Top + pB8->pnlBody.Height <= pB8->ClientHeight), "-1")
		B8Check("no action has run yet", Str(pB8->ActionCount), "0")
		pB8->Stage = 1

	Case 1
		'' ---- route one: the menu item -----------------------------------------------------
		B8Say("-- the same action, from the menu --")
		pB8->LastSource = "menu"
		pB8->miAction->Click
		B8Check("menu click ran the action", Str(pB8->ActionCount), "1")
		B8Check("status bar reports the menu", pB8->sb.Panel(0)->Caption, "action 1 from menu")
		pB8->Stage = 2

	Case 2
		'' ---- route two: the toolbar button ------------------------------------------------
		B8Say("-- the same action, from the toolbar --")
		pB8->LastSource = "toolbar"
		If pB8->btnAction->OnClick Then pB8->btnAction->OnClick(*pB8, *pB8->btnAction)
		B8Check("toolbar click ran the action", Str(pB8->ActionCount), "2")
		B8Check("status bar reports the toolbar", pB8->sb.Panel(0)->Caption, "action 2 from toolbar")
		'' Both routes reached one handler: the count advanced once per invocation, and the same
		'' status bar was updated by each.
		B8Check("one handler served both routes", Str(pB8->ActionCount), "2")
		pB8->Stage = 3

	Case 3
		B8Say("")
		B8Say("B8 RESULT: " & Str(pB8->Pass) & " passed, " & Str(pB8->Fail) & " failed")
		If pB8->Fail = 0 Then
			B8Say("B8 OVERALL: PASS")
			End 0
		Else
			B8Say("B8 OVERALL: FAIL")
			End 1
		End If
	End Select
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b8_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B8Form f
pB8 = @f
f.Show
App.Run
