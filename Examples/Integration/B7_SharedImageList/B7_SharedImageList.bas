'' TestPlan.md B7 -- one ImageList shared by a ToolBar, a TreeView and a ListView.
''
'' This scenario exists because of a real defect. Astoria's menu icons were dead for the life of
'' the process: MenuItem resolves an image KEY to an index once, inside Add, and only if its owner
'' already has an ImagesList bound. Startup bound the list conditionally, so with icons switched
'' off every item was stamped ImageIndex = -1 permanently, and switching them on later had nothing
'' to resolve against. A shared image list is exactly that hazard, multiplied by three consumers.
''
'' So this checks two things, not one:
''   1. The supported order -- bind the list, THEN add items by key -- resolves correctly for all
''      three consumers from a single shared ImageList.
''   2. The hazardous order -- add items by key BEFORE binding the list -- is exercised and its
''      behaviour RECORDED. If it silently yields -1, that is the menu-icon trap living on in
''      three more controls, and worth knowing about even if it is by design.
''
'' SELF-DRIVING AND SELF-EXITING. Run it and read b7_result.txt.

#include once "mff/Form.bi"
#include once "mff/ImageList.bi"
#include once "mff/ToolBar.bi"
#include once "mff/TreeView.bi"
#include once "mff/ListView.bi"
#include once "mff/TimerComponent.bi"

Using My.Sys.Forms

Const B7_WATCHDOG_TICKS = 40

Type B7Form Extends Form
	Declare Static Sub tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	Declare Constructor
	Dim As ImageList imgShared
	Dim As ToolBar tbBound
	Dim As TreeView tvBound
	Dim As ListView lvBound
	Dim As TreeView tvUnbound        '' the hazardous order: items added before the list is bound
	Dim As TimerComponent tmrSeq
	Dim As Integer Ticks, Stage, Pass, Fail
End Type

Dim Shared As B7Form Ptr pB7

Sub B7Say(ByRef Line_ As String)
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b7_result.txt" For Append As #f) = 0 Then
		Print #f, Line_
		Close #f
	End If
End Sub

Sub B7Check(ByRef CheckName As String, ByRef Got As String, ByRef Want As String)
	If pB7 = 0 Then Exit Sub
	If Got = Want Then
		pB7->Pass += 1
		B7Say("PASS " & CheckName & " (" & Got & ")")
	Else
		pB7->Fail += 1
		B7Say("FAIL " & CheckName & ": expected [" & Want & "] got [" & Got & "]")
	End If
End Sub

Constructor B7Form
	With This
		.Name = "B7Form"
		.Text = "B7 shared image list test"
		.Designer = @This
		.SetBounds 0, 0, 760, 460
	End With

	'' --- one image list, three (then four) consumers -----------------------------------------
	imgShared.Name = "imgShared"
	Dim As UString resDir = ExePath & "\..\..\..\Controls\Framework\resources\"
	imgShared.AddFromFile(resDir & "CheckBox.png", "one")
	imgShared.AddFromFile(resDir & "Chart.png",    "two")
	imgShared.AddFromFile(resDir & "Animate.png",  "three")

	'' Supported order for all three: bind the shared list FIRST, then add items by key.
	With tbBound
		.Name = "tbBound" : .Align = DockStyle.alTop : .Height = 40
		.Designer = @This : .Parent = @This
	End With
	tbBound.ImagesList = @imgShared
	tbBound.Buttons.Add(ToolButtonStyle.tbsAutosize, "one",   , , "btnOne",   "One")
	tbBound.Buttons.Add(ToolButtonStyle.tbsAutosize, "two",   , , "btnTwo",   "Two")
	tbBound.Buttons.Add(ToolButtonStyle.tbsAutosize, "three", , , "btnThree", "Three")

	With tvBound
		.Name = "tvBound" : .Align = DockStyle.alLeft : .Width = 240
		.Designer = @This : .Parent = @This
	End With
	'' BOTH lists are required. TreeNodeCollection.Add's image-key overload resolves the key only
	'' when Images AND SelectedImages are both bound; with either missing it silently assigns -1
	'' and the node has no image for the life of the control. Setting only Images -- the obvious
	'' thing to do -- is what the first run of this test did, and it looked exactly like a bug.
	tvBound.Images = @imgShared
	tvBound.SelectedImages = @imgShared
	tvBound.Nodes.Add("Node one",   "n1", "", "one",   "one")
	tvBound.Nodes.Add("Node two",   "n2", "", "two",   "two")
	tvBound.Nodes.Add("Node three", "n3", "", "three", "three")

	With lvBound
		.Name = "lvBound" : .Align = DockStyle.alClient
		.View = ViewStyle.vsDetails
		.Designer = @This : .Parent = @This
	End With
	lvBound.Images = @imgShared
	lvBound.SmallImages = @imgShared
	lvBound.Columns.Add("Item"), , 200
	lvBound.ListItems.Add("Row one",   "one")
	lvBound.ListItems.Add("Row two",   "two")
	lvBound.ListItems.Add("Row three", "three")

	'' Hazardous order, deliberately: nodes added by key BEFORE the shared list is bound.
	With tvUnbound
		.Name = "tvUnbound" : .Align = DockStyle.alRight : .Width = 200
		.Designer = @This : .Parent = @This
	End With
	tvUnbound.Nodes.Add("Early one", "e1", "", "one", "one")
	tvUnbound.Nodes.Add("Early two", "e2", "", "two", "two")
	tvUnbound.Images = @imgShared          '' bound only afterwards

	With tmrSeq
		.Name = "tmrSeq" : .Interval = 250
		.OnTimer = @tmrSeq_Timer_
		.Enabled = True
	End With
End Constructor

Sub B7Form.tmrSeq_Timer_(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	If pB7 = 0 Then Exit Sub
	pB7->Ticks += 1
	If pB7->Ticks > B7_WATCHDOG_TICKS Then
		B7Say("watchdog fired at stage " & Str(pB7->Stage))
		B7Say("B7 OVERALL: FAIL")
		End 1
	End If
	If pB7->Ticks < 3 Then Exit Sub

	'' --- the image list itself -----------------------------------------------------------
	B7Say("-- the shared image list --")
	B7Check("image count", Str(pB7->imgShared.Count), "3")
	B7Check("key 'one' resolves",   Str(pB7->imgShared.IndexOf("one")),   "0")
	B7Check("key 'two' resolves",   Str(pB7->imgShared.IndexOf("two")),   "1")
	B7Check("key 'three' resolves", Str(pB7->imgShared.IndexOf("three")), "2")

	'' --- all three consumers point at the SAME list ---------------------------------------
	B7Say("-- one list, three consumers --")
	B7Check("toolbar uses the shared list",  Str(pB7->tbBound.ImagesList = @pB7->imgShared), "-1")
	B7Check("treeview uses the shared list", Str(pB7->tvBound.Images     = @pB7->imgShared), "-1")
	B7Check("listview uses the shared list", Str(pB7->lvBound.Images     = @pB7->imgShared), "-1")

	'' --- supported order: bound first, then items added by key ----------------------------
	B7Say("-- bound BEFORE items added (the supported order) --")
	B7Check("toolbar button 0 index", Str(pB7->tbBound.Buttons.Item(0)->ImageIndex), "0")
	B7Check("toolbar button 1 index", Str(pB7->tbBound.Buttons.Item(1)->ImageIndex), "1")
	B7Check("toolbar button 2 index", Str(pB7->tbBound.Buttons.Item(2)->ImageIndex), "2")
	B7Check("treenode 0 index", Str(pB7->tvBound.Nodes.Item(0)->ImageIndex), "0")
	B7Check("treenode 1 index", Str(pB7->tvBound.Nodes.Item(1)->ImageIndex), "1")
	B7Check("treenode 2 index", Str(pB7->tvBound.Nodes.Item(2)->ImageIndex), "2")
	B7Check("listitem 0 index", Str(pB7->lvBound.ListItems.Item(0)->ImageIndex), "0")
	B7Check("listitem 1 index", Str(pB7->lvBound.ListItems.Item(1)->ImageIndex), "1")
	B7Check("listitem 2 index", Str(pB7->lvBound.ListItems.Item(2)->ImageIndex), "2")

	'' --- the hazardous order: RECORDED, not asserted --------------------------------------
	'' This is the shape that killed the menu icons. Whatever it does, say so plainly.
	B7Say("-- items added BEFORE the list was bound (the menu-icon hazard) --")
	Dim As Integer e0 = pB7->tvUnbound.Nodes.Item(0)->ImageIndex
	Dim As Integer e1 = pB7->tvUnbound.Nodes.Item(1)->ImageIndex
	B7Say("   node 0 ImageIndex = " & Str(e0))
	B7Say("   node 1 ImageIndex = " & Str(e1))
	If e0 = 0 AndAlso e1 = 1 Then
		B7Say("   OBSERVATION: keys resolved even though the list was bound afterwards -- this")
		B7Say("   control is NOT vulnerable to the ordering trap that killed the menu icons.")
	Else
		B7Say("   OBSERVATION: keys did NOT resolve when the list was bound after the items were")
		B7Say("   added. Same trap as the menu icons: bind the ImageList BEFORE adding items, or")
		B7Say("   the images are silently absent for the life of the control. TreeView has a")
		B7Say("   second version of the same trap -- its key overload needs BOTH Images and")
		B7Say("   SelectedImages bound, and assigns -1 without complaint if either is missing.")
	End If

	B7Say("")
	B7Say("B7 RESULT: " & Str(pB7->Pass) & " passed, " & Str(pB7->Fail) & " failed")
	If pB7->Fail = 0 Then
		B7Say("B7 OVERALL: PASS")
		End 0
	Else
		B7Say("B7 OVERALL: FAIL")
		End 1
	End If
End Sub

Dim As Integer fInit = FreeFile
If Open(ExePath & "\b7_result.txt" For Output As #fInit) = 0 Then Close #fInit

Dim As B7Form f
pB7 = @f
f.Show
App.Run
