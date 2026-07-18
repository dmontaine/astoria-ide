'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#cmdline "Main.rc"
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/HotKey.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor

		Dim As HotKey ctlTest
	End Type

	Constructor MainType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' Main
		With This
			.Name = "Main"
			.Text = "HotKey test"
			.Designer = @This
			.SetBounds 0, 0, 350, 300
		End With
		' ctlTest
		With ctlTest
			.Name = "ctlTest"
			.SetBounds 20, 20, 180, 28
			.Designer = @This
			.Parent = @This
		End With
	End Constructor

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
