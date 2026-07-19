'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#cmdline "FormA.rc"
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "FormB.frm"

	Using My.Sys.Forms

	Type FormAType Extends Form
		Declare Constructor

		Dim As Label lblShared
		Dim As TextBox txtNotes
		Dim As CommandButton btnGo
	End Type

	Constructor FormAType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' FormA
		With This
			.Name = "FormA"
			.Text = "C5 Source (FormA)"
			.Designer = @This
			.SetBounds 0, 0, 420, 320
		End With
		' lblShared -- name deliberately duplicated in FormB, to force a collision on paste
		With lblShared
			.Name = "lblShared"
			.Text = "Group label A"
			.SetBounds 20, 20, 160, 24
			.Designer = @This
			.Parent = @This
		End With
		' txtNotes
		With txtNotes
			.Name = "txtNotes"
			.Text = "notes A"
			.SetBounds 20, 56, 160, 24
			.Designer = @This
			.Parent = @This
		End With
		' btnGo
		With btnGo
			.Name = "btnGo"
			.Caption = "Go A"
			.SetBounds 20, 92, 100, 28
			.Designer = @This
			.Parent = @This
		End With
	End Constructor

	Dim Shared FormA As FormAType

	#if _MAIN_FILE_ = __FILE__
		FormA.MainForm = True
		FormA.Show
		App.Run
	#endif
'#End Region
