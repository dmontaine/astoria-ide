'' TestPlan.md B6 -- list/detail.
''
'' A ListView on the left whose selection drives detail TextBoxes on the right: the second most
'' common form shape after data entry, and the simplest case of one control's event changing
'' another control's contents. Testing each control alone can never catch a broken event route
'' between them.
''
'' The runner selects rows from outside and asserts on b6_result.txt, which the selection handler
'' rewrites every time it fires. If the event never arrives the file stays empty; if the wrong row
'' is read the values will not match the row asked for.

#include once "mff/Form.bi"
#include once "mff/ListView.bi"
#include once "mff/TextBox.bi"
#include once "mff/Label.bi"

Using My.Sys.Forms

Type B6Form Extends Form
	Declare Static Sub lvPeople_SelectedItemChanged_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	Declare Constructor
	Dim As ListView lvPeople
	Dim As Label lblName, lblRole
	Dim As TextBox txtName, txtRole
	Dim As Integer Fires
End Type

Dim Shared As B6Form Ptr pB6

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
		.SetBounds 360, 20, 60, 20
		.Designer = @This : .Parent = @This
	End With
	With txtName
		.Name = "txtName" : .Text = ""
		.SetBounds 430, 18, 260, 24
		.Designer = @This : .Parent = @This
	End With
	With lblRole
		.Name = "lblRole" : .Text = "Role:"
		.SetBounds 360, 56, 60, 20
		.Designer = @This : .Parent = @This
	End With
	With txtRole
		.Name = "txtRole" : .Text = ""
		.SetBounds 430, 54, 260, 24
		.Designer = @This : .Parent = @This
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
	'' Push into the detail controls, then read them BACK out, so the file reports what the
	'' TextBoxes actually hold rather than what we meant to put there.
	pB6->txtName.Text = nameText
	pB6->txtRole.Text = roleText
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b6_result.txt" For Output As #f) = 0 Then
		Print #f, "fires=" & Str(pB6->Fires)
		Print #f, "index=" & Str(ItemIndex)
		Print #f, "detail_name=" & pB6->txtName.Text
		Print #f, "detail_role=" & pB6->txtRole.Text
		Close #f
	End If
End Sub

Dim As B6Form f
pB6 = @f
f.Show
App.Run
