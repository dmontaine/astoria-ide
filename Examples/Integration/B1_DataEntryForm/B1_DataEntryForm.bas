'' TestPlan.md B1 -- data-entry form.
''
'' Label + TextBox + ComboBoxEdit + CheckBox + a RadioButton group + CommandButton on one form.
'' The single commonest form shape there is, and the case the 73-control sweep cannot reach: that
'' sweep proves each control opens a window on its own, not that a handler can read values back
'' out of six different controls when a button is pressed.
''
'' Driven from outside: the test runner types into the TextBox with WM_SETTEXT and clicks the
'' button, so the values crossing the boundary are real Windows input rather than something this
'' program handed itself. The click handler then reads every control through the framework API
'' and writes what it saw to b1_result.txt, which the runner asserts against.

#include once "mff/Form.bi"
#include once "mff/Label.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/CheckBox.bi"
#include once "mff/RadioButton.bi"
#include once "mff/CommandButton.bi"

Using My.Sys.Forms

Type B1Form Extends Form
	Declare Static Sub cmdSubmit_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Declare Constructor
	Dim As Label lblCaption
	Dim As TextBox txtName
	Dim As ComboBoxEdit cboColour
	Dim As CheckBox chkAgree
	Dim As RadioButton optAlpha, optBeta
	Dim As CommandButton cmdSubmit
End Type

Dim Shared As B1Form Ptr pB1

Constructor B1Form
	With This
		.Name = "B1Form"
		.Text = "B1 data entry form"
		.Designer = @This
		.SetBounds 0, 0, 460, 320
	End With
	With lblCaption
		.Name = "lblCaption"
		.Text = "Name:"
		.SetBounds 16, 16, 80, 20
		.Designer = @This
		.Parent = @This
	End With
	With txtName
		.Name = "txtName"
		.Text = ""
		.TabIndex = 0
		.SetBounds 100, 14, 320, 24
		.Designer = @This
		.Parent = @This
	End With
	With cboColour
		.Name = "cboColour"
		.Style = ComboBoxEditStyle.cbDropDownList
		.TabIndex = 1
		.SetBounds 100, 50, 320, 24
		.Designer = @This
		.Parent = @This
	End With
	With chkAgree
		.Name = "chkAgree"
		.Text = "Agree to terms"
		.TabIndex = 2
		.SetBounds 100, 86, 320, 24
		.Designer = @This
		.Parent = @This
	End With
	'' RadioButtons group by shared parent, so these two are one group automatically.
	With optAlpha
		.Name = "optAlpha"
		.Text = "Alpha"
		.TabIndex = 3
		.SetBounds 100, 118, 140, 24
		.Designer = @This
		.Parent = @This
	End With
	With optBeta
		.Name = "optBeta"
		.Text = "Beta"
		.TabIndex = 4
		.SetBounds 250, 118, 140, 24
		.Designer = @This
		.Parent = @This
	End With
	With cmdSubmit
		.Name = "cmdSubmit"
		.Text = "Submit"
		.TabIndex = 5
		.SetBounds 100, 160, 140, 32
		.Designer = @This
		.OnClick = @cmdSubmit_Click_
		.Parent = @This
	End With
	'' Populated after the controls exist, the way a real form fills a lookup list.
	cboColour.AddItem "Red"
	cboColour.AddItem "Green"
	cboColour.AddItem "Blue"
	cboColour.ItemIndex = 2
	optAlpha.Checked = True
End Constructor

'' Reads all six controls and reports what it saw. Everything asserted by the runner comes from
'' this one handler, so a failure here means the values did not survive the trip between controls.
Sub B1Form.cmdSubmit_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If pB1 = 0 Then Exit Sub
	Dim As Integer f = FreeFile
	If Open(ExePath & "\b1_result.txt" For Output As #f) = 0 Then
		Print #f, "textbox=" & pB1->txtName.Text
		Print #f, "combo_text=" & pB1->cboColour.Text
		Print #f, "combo_index=" & Str(pB1->cboColour.ItemIndex)
		Print #f, "combo_count=" & Str(pB1->cboColour.Items.Count)
		Print #f, "checkbox=" & Str(pB1->chkAgree.Checked)
		Print #f, "radio_alpha=" & Str(pB1->optAlpha.Checked)
		Print #f, "radio_beta=" & Str(pB1->optBeta.Checked)
		Print #f, "label=" & pB1->lblCaption.Text
		Close #f
	End If
End Sub

Dim As B1Form f
pB1 = @f
f.Show
App.Run
