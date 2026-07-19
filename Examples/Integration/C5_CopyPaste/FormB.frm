'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#cmdline "FormB.rc"
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"

	Using My.Sys.Forms

	Type FormBType Extends Form
		Declare Constructor

		Dim As Label lblShared, lblShared1
		Dim As CommandButton btnGo
		Dim As TextBox txtNotes
	End Type

	Constructor FormBType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' FormB
		With This
			.Name = "FormB"
			.Text = "C5 Destination (FormB)"
			.Designer = @This
			.SetBounds 0, 0, 420, 320
		End With
		' lblShared -- SAME NAME as a control in FormA; pasting FormA's group must resolve this
		With lblShared
			.Name = "lblShared"
			.Text = "Existing label B"
			.SetBounds 220, 20, 160, 24
			.Designer = @This
			.Parent = @This
		End With
		' btnGo
		With btnGo
			.Name = "btnGo"
			.Text = "Go A"
			.TabIndex = 1
			.ControlIndex = 1
			.SetBounds 30, 102, 100, 28
			.Designer = @This
			.Parent = @This
		End With
		' txtNotes
		With txtNotes
			.Name = "txtNotes"
			.Text = "notes A"
			.TabIndex = 2
			.ControlIndex = 1
			.SetBounds 30, 66, 160, 24
			.Designer = @This
			.Parent = @This
		End With
		' lblShared1
		With lblShared1
			.Name = "lblShared1"
			.Text = "Group label A"
			.TabIndex = 3
			.ControlIndex = 0
			.SetBounds 30, 30, 160, 24
			.Designer = @This
			.Parent = @This
		End With
	End Constructor

	Dim Shared FormB As FormBType

	#if _MAIN_FILE_ = __FILE__
		FormB.MainForm = True
		FormB.Show
		App.Run
	#endif
'#End Region
