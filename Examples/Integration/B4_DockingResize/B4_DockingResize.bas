'' TestPlan.md B4 -- docking and anchoring under resize.
''
'' Four panels docked alTop, alBottom, alLeft and alClient on one form. Docking is arithmetic
'' performed every time the form changes size, so it is exactly the kind of thing that looks
'' right at the design size and goes wrong at the extremes -- Astoria's own Options dialog has
'' produced several bugs of this shape.
''
'' The program only builds the layout. The test runner resizes the window (large, small,
'' maximised) and checks the invariants against the real window rectangles: the top and bottom
'' bands span the full client width, the left band fills the height between them, the client
'' panel takes exactly the remaining space, and no two panels overlap. Screenshots are taken at
'' each size so a human can confirm what the numbers claim.

#include once "mff/Form.bi"
#include once "mff/Panel.bi"
#include once "mff/Label.bi"

Using My.Sys.Forms

Type B4Form Extends Form
	Declare Constructor
	Dim As Panel pnlTop, pnlBottom, pnlLeft, pnlClient
	Dim As Label lblTop, lblBottom, lblLeft, lblClient
End Type

Constructor B4Form
	With This
		.Name = "B4Form"
		.Text = "B4 docking resize test"
		.Designer = @This
		.SetBounds 0, 0, 800, 560
	End With
	'' Order matters for docking: each alTop/alBottom/alLeft claims its band from what is left,
	'' and alClient takes the remainder, so alClient is added last on purpose.
	With pnlTop
		.Name = "pnlTop"
		.Align = DockStyle.alTop
		.Height = 60
		.Designer = @This
		.Parent = @This
	End With
	With pnlBottom
		.Name = "pnlBottom"
		.Align = DockStyle.alBottom
		.Height = 40
		.Designer = @This
		.Parent = @This
	End With
	With pnlLeft
		.Name = "pnlLeft"
		.Align = DockStyle.alLeft
		.Width = 160
		.Designer = @This
		.Parent = @This
	End With
	With pnlClient
		.Name = "pnlClient"
		.Align = DockStyle.alClient
		.Designer = @This
		.Parent = @This
	End With
	'' Captions make each band identifiable in a screenshot.
	With lblTop
		.Name = "lblTop" : .Text = "TOP alTop h=60"
		.SetBounds 8, 8, 300, 20
		.Designer = @This : .Parent = @pnlTop
	End With
	With lblBottom
		.Name = "lblBottom" : .Text = "BOTTOM alBottom h=40"
		.SetBounds 8, 8, 300, 20
		.Designer = @This : .Parent = @pnlBottom
	End With
	With lblLeft
		.Name = "lblLeft" : .Text = "LEFT alLeft w=160"
		.SetBounds 8, 8, 150, 20
		.Designer = @This : .Parent = @pnlLeft
	End With
	With lblClient
		.Name = "lblClient" : .Text = "CLIENT alClient - takes what is left"
		.SetBounds 8, 8, 320, 20
		.Designer = @This : .Parent = @pnlClient
	End With
End Constructor

Dim As B4Form f
f.Show
App.Run
