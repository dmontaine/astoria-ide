'#########################################################
'#  frmOptions.bas                                       #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "frmOptions.bi"
#include once "TabWindow.bi"

Dim Shared fOptions As frmOptions
pfOptions = @fOptions

'#Region "Form"
	Constructor frmOptions
		' Form1
		This.Name = "frmOptions"
		This.Text = ("Options")
		This.OnCreate = @Form_Create
		This.OnClose = @Form_Close
			This.Icon.LoadFromResourceID(1)
		This.MinimizeBox = False
		This.MaximizeBox = False
		This.ExtraMargins.Bottom = -1
		This.ExtraMargins.Left = 0
		This.ExtraMargins.Top = 0
		This.SetBounds 0, 0, 631, 488
		This.StartPosition = FormStartPosition.CenterParent
		'This.Caption = ML("Options")
		This.CancelButton = @cmdCancel
		'This.DefaultButton = @cmdOK
		This.Designer = @This
		This.BorderStyle = FormBorderStyle.FixedDialog
		' pplGeneralr
		pplGeneral.Name = "pplGeneral"
		pplGeneral.Text = ""
		pplGeneral.Align = DockStyle.alClient
		pplGeneral.ExtraMargins.Bottom = 9
		pplGeneral.ExtraMargins.Top = 4
		pplGeneral.ExtraMargins.Right = 10
		pplGeneral.Margins.Left = 10
		pplGeneral.TabIndex = 67
		pplGeneral.SelectedPanelIndex = 0
		pplGeneral.SelectedPanel = @pnlCompiler
		pplGeneral.SetBounds 188, 4, 427, 400
		pplGeneral.Parent = @This
		' pnlGeneral
		pnlGeneral.Name = "pnlGeneral"
		pnlGeneral.Text = ""
		pnlGeneral.Align = DockStyle.alClient
		pnlGeneral.TabIndex = 1
		pnlGeneral.SetBounds 10, 0, 417, 400
		pnlGeneral.ControlIndex = 0
		pnlGeneral.Parent = @pplGeneral
		' pnlShortcuts
		pnlShortcuts.Name = "pnlShortcuts"
		pnlShortcuts.Text = ""
		pnlShortcuts.Align = DockStyle.alClient
		pnlShortcuts.TabIndex = 74
		pnlShortcuts.SetBounds 10, 0, 417, 400
		pnlShortcuts.ControlIndex = 2
		pnlShortcuts.Parent = @pplGeneral
		' pnlThemes
		pnlThemes.Name = "pnlThemes"
		pnlThemes.Text = ""
		pnlThemes.Align = DockStyle.alClient
		pnlThemes.TabIndex = 73
		pnlThemes.SetBounds 10, 0, 417, 400
		pnlThemes.ControlIndex = 3
		pnlThemes.Parent = @pplGeneral
		' pnlCodeEditor
		pnlCodeEditor.Name = "pnlCodeEditor"
		pnlCodeEditor.Text = ""
		pnlCodeEditor.Align = DockStyle.alClient
		pnlCodeEditor.TabIndex = 78
		pnlCodeEditor.SetBounds 10, 0, 417, 390
		pnlCodeEditor.ControlIndex = 4
		pnlCodeEditor.Parent = @pplGeneral
		' pnlColorsAndFonts
		pnlColorsAndFonts.Name = "pnlColorsAndFonts"
		pnlColorsAndFonts.Text = ""
		pnlColorsAndFonts.Align = DockStyle.alClient
		pnlColorsAndFonts.TabIndex = 79
		pnlColorsAndFonts.SetBounds 10, 0, 417, 400
		pnlColorsAndFonts.ControlIndex = 5
		pnlColorsAndFonts.Parent = @pplGeneral
		' pnlOtherEditors
		pnlOtherEditors.Name = "pnlOtherEditors"
		pnlOtherEditors.Text = ""
		pnlOtherEditors.Align = DockStyle.alClient
		pnlOtherEditors.TabIndex = 76
		pnlOtherEditors.SetBounds 10, 0, 417, 400
		pnlOtherEditors.ControlIndex = 6
		pnlOtherEditors.Parent = @pplGeneral
		' pnlCompiler
		pnlCompiler.Name = "pnlCompiler"
		pnlCompiler.Text = ""
		pnlCompiler.Align = DockStyle.alClient
		'pnlCompiler.ExtraMargins.Bottom = 9
		'pnlCompiler.ExtraMargins.Top = 4
		'pnlCompiler.ExtraMargins.Right = 10
		'pnlCompiler.Margins.Left = 10
		pnlCompiler.TabIndex = 67
		pnlCompiler.SetBounds 188, 4, 427, 400
		pnlCompiler.Parent = @pplGeneral
		' pnlDebugger
		pnlDebugger.Name = "pnlDebugger"
		pnlDebugger.Text = ""
		'pnlDebugger.ExtraMargins.Top = 4
		'pnlDebugger.ExtraMargins.Bottom = 9
		'pnlDebugger.ExtraMargins.Right = 10
		'pnlDebugger.Margins.Left = 10
		pnlDebugger.Align = DockStyle.alClient
		pnlDebugger.TabIndex = 69
		pnlDebugger.SetBounds 188, 4, 427, 400
		pnlDebugger.Parent = @pplGeneral
		' pnlTerminal
		pnlTerminal.Name = "pnlTerminal"
		pnlTerminal.Text = ""
		'pnlTerminal.Margins.Left = 10
		'pnlTerminal.ExtraMargins.Top = 4
		'pnlTerminal.ExtraMargins.Right = 10
		'pnlTerminal.ExtraMargins.Bottom = 9
		pnlTerminal.Align = DockStyle.alClient
		pnlTerminal.TabIndex = 70
		pnlTerminal.SetBounds 188, 4, 427, 400
		pnlTerminal.Parent = @pplGeneral
		' pnlDesigner
		pnlDesigner.Name = "pnlDesigner"
		pnlDesigner.Text = ""
		'pnlDesigner.ExtraMargins.Top = 4
		'pnlDesigner.ExtraMargins.Right = 10
		'pnlDesigner.ExtraMargins.Bottom = 9
		pnlDesigner.Align = DockStyle.alClient
		'pnlDesigner.Margins.Left = 10
		pnlDesigner.TabIndex = 71
		pnlDesigner.SetBounds -162, 4, 427, 400
		pnlDesigner.Parent = @pplGeneral
		'pnlThemes.ExtraMargins.Top = 4
		'pnlThemes.ExtraMargins.Bottom = 9
		'pnlThemes.ExtraMargins.Right = 10
		'pnlThemes.Margins.Left = 10
		'pnlShortcuts.Margins.Left = 10
		'pnlShortcuts.Margins.Right = 0
		'pnlShortcuts.ExtraMargins.Bottom = 9
		'pnlShortcuts.ExtraMargins.Top = 4
		'pnlShortcuts.ExtraMargins.Right = 10
		' pnlHelp
		pnlHelp.Name = "pnlHelp"
		pnlHelp.Text = ""
		'pnlHelp.ExtraMargins.Top = 4
		'pnlHelp.ExtraMargins.Right = 10
		'pnlHelp.ExtraMargins.Bottom = 9
		'pnlHelp.Margins.Left = 10
		pnlHelp.Align = DockStyle.alClient
		pnlHelp.TabIndex = 75
		pnlHelp.SetBounds 188, 4, 427, 400
		pnlHelp.Parent = @pplGeneral
		'pnlOtherEditors.ExtraMargins.Right = 10
		'pnlOtherEditors.ExtraMargins.Bottom = 9
		'pnlOtherEditors.ExtraMargins.Top = 4
		'pnlIncludes.ExtraMargins.Bottom = 9
		'pnlIncludes.ExtraMargins.Right = 10
		'pnlIncludes.ExtraMargins.Top = 4
		'pnlCodeEditor.ExtraMargins.Top = 4
		'pnlCodeEditor.ExtraMargins.Bottom = 9
		'pnlCodeEditor.ExtraMargins.Right = 10
		'pnlCodeEditor.Margins.Left = 10
		'pnlColorsAndFonts.ExtraMargins.Top = 4
		'pnlColorsAndFonts.ExtraMargins.Right = 10
		'pnlColorsAndFonts.ExtraMargins.Bottom = 9
		'pnlColorsAndFonts.Margins.Left = 10
		'pnlGeneral.Margins.Left = 10
		'pnlGeneral.ExtraMargins.Top = 0
		'pnlGeneral.ExtraMargins.Bottom = 9
		'pnlGeneral.ExtraMargins.Right = 10
		'pnlGeneral.Margins.Top = 0
		' pnlCommands
		With pnlCommands
			.Name = "pnlCommands"
			.Text = "Panel1"
			.TabIndex = 80
			.Align = DockStyle.alBottom
			.Margins.Top = 0
			.Margins.Right = 0
			.Margins.Left = 0
			.Margins.Bottom = 0
			.AutoSize = True
			.SetBounds 0, 415, 625, 44
			.Designer = @This
			.Parent = @This
		End With
		' tvOptions
		tvOptions.Name = "tvOptions"
		tvOptions.Text = "TreeView1"
		tvOptions.Align = DockStyle.alLeft
		tvOptions.ExtraMargins.Top = 10
		tvOptions.ExtraMargins.Left = 10
		tvOptions.ExtraMargins.Bottom = 10
		tvOptions.TabIndex = 0
		tvOptions.SetBounds 10, 10, 178, 393
		tvOptions.HideSelection = False
		tvOptions.OnSelChanged = @TreeView1_SelChange
		tvOptions.Parent = @This
		'cmdOK.Caption = ML("OK")
		' cmdApply
		cmdApply.Name = "cmdApply"
		cmdApply.Text = ("Apply")
		cmdApply.Align = DockStyle.alRight
		cmdApply.ExtraMargins.Bottom = 10
		cmdApply.ExtraMargins.Right = 10
		cmdApply.ExtraMargins.Top = 10
		cmdApply.TabIndex = 81
		cmdApply.SetBounds 525, 30, 90, 24
		cmdApply.OnClick = @cmdApply_Click
		cmdApply.Parent = @pnlCommands
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ("Cancel")
		cmdCancel.Align = DockStyle.alRight
		cmdCancel.ExtraMargins.Bottom = 10
		cmdCancel.ExtraMargins.Top = 10
		cmdCancel.TabIndex = 82
		cmdCancel.SetBounds 435, 10, 90, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @pnlCommands
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ("OK")
		cmdOK.Default = True
		cmdOK.Align = DockStyle.alRight
		cmdOK.ExtraMargins.Bottom = 10
		cmdOK.ExtraMargins.Top = 10
		cmdOK.TabIndex = 83
		cmdOK.SetBounds 345, 10, 90, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @pnlCommands
		' lblBlack
		lblBlack.Name = "lblBlack"
		lblBlack.Text = ""
		lblBlack.BorderStyle = BorderStyles.bsClient
		lblBlack.BackColor = 8421504
		lblBlack.ExtraMargins.Right = 1
		lblBlack.ExtraMargins.Left = 0
		lblBlack.Align = DockStyle.alClient
		lblBlack.ExtraMargins.Bottom = 1
		lblBlack.Anchor.Right = 1
		lblBlack.Anchor.Left = 1
		lblBlack.TabIndex = 61
		lblBlack.SetBounds 0, 0, 604, 1
		lblBlack.Parent = @pnlLine
		' grbDefaultCompilers
		With grbDefaultCompilers
			.Name = "grbDefaultCompilers"
			.Text = ("Default Compiler")
			.AutoSize = True
			.Align = DockStyle.alTop
			.ExtraMargins.Left = 0
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 84
			'.SetBounds 10, 0, 417, 400
			.Parent = @pnlCompiler
		End With
		' grbShortcuts
		With grbShortcuts
			.Name = "grbShortcuts"
			.Text = ("Shortcuts")
			.Align = DockStyle.alClient
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 85
			.SetBounds 10, 0, 417, 400
			.Parent = @pnlShortcuts
		End With
		'' 13.3.A S6 O4: "Compiler Paths" (register alternative compiler installations) removed --
		'' was already permanently hidden (grbCompilerPaths.Visible=False below this constructor),
		'' had no Add/Remove/Change buttons wired to it (empty hbxCompilers, empty ItemActivate
		'' handler), and its own Save routine unconditionally purged the "Compilers" INI section on
		'' every save. Project->CompilerPath (per-project override, set only via hand-edited .vfp
		'' files) and BuildService.bas's bundled-compiler fallback are untouched.
		' lblShortcut
		lblShortcut.Name = "lblShortcut"
		lblShortcut.Text = ("Select shortcut") & ":"
		lblShortcut.ExtraMargins.Right = 0
		lblShortcut.Align = DockStyle.alLeft
		lblShortcut.CenterImage = True
		lblShortcut.TabIndex = 20
		lblShortcut.SetBounds 0, 0, 126, 20
		lblShortcut.Parent = @pnlSelectShortcut
		' hkShortcut
		hkShortcut.Name = "hkShortcut"
		hkShortcut.ExtraMargins.Left = 0
		hkShortcut.ExtraMargins.Bottom = 0
		hkShortcut.ExtraMargins.Right = 0
		hkShortcut.Align = DockStyle.alClient
		hkShortcut.TabIndex = 21
		hkShortcut.SetBounds 126, 0, 206, 20
		hkShortcut.Parent = @pnlSelectShortcut
		' cmdSetShortcut
		cmdSetShortcut.Name = "cmdSetShortcut"
		cmdSetShortcut.Text = ("Set")
			cmdSetShortcut.ExtraMargins.Top = -1
			cmdSetShortcut.ExtraMargins.Bottom = -1
			cmdSetShortcut.ExtraMargins.Right = -1
		cmdSetShortcut.Align = DockStyle.alRight
		cmdSetShortcut.TabIndex = 22
		cmdSetShortcut.SetBounds 332, -1, 56, 22
		cmdSetShortcut.OnClick = @cmdSetShortcut_Click
		cmdSetShortcut.Parent = @pnlSelectShortcut
		' lvShortcuts
		With lvShortcuts
			.Name = "lvShortcuts"
			.Text = "lvShortcuts"
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
		lvShortcuts.TabIndex = 87
			.SetBounds 15, 22, 387, 328
			.OnSelectedItemChanged = @lvShortcuts_SelectedItemChanged
			.Parent = @grbShortcuts
		End With
		With grbDefaultTerminal
			.Name = "grbDefaultTerminal"
			.Text = ("Default Terminal")
			.Align = DockStyle.alTop
			.TabIndex = 91
			.SetBounds 10, 0, 417, 64
			.Parent = @pnlTerminal
		End With
		' cboTerminal
		With cboTerminal
			.Name = "cboTerminal"
			.Text = "cboTerminal"
			.TabIndex = 92
			.SetBounds 18, 24, 384, 21
			.Parent = @grbDefaultTerminal
		End With
		' grbTerminalPaths
		With grbTerminalPaths
			.Name = "grbTerminalPaths"
			.Text = ("Terminal Paths")
			.ExtraMargins.Top = 5
			.Align = DockStyle.alClient
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 93
			.SetBounds 10, 168, 417, 232
			.Parent = @pnlTerminal
		End With
		' lvTerminalPath
		With lvTerminalPaths
			.Name = "lvTerminalPaths"
			.Text = "lvTerminalPaths"
			.ExtraMargins.Bottom = 15
			.Align = DockStyle.alClient
		lvTerminalPaths.TabIndex = 94
			.SetBounds 15, 22, 387, 156
			.Designer = @This
			.OnItemActivate = @lvTerminalPaths_ItemActivate_
			.Parent = @grbTerminalPaths
		End With
		With cmdClearTerminals
			.Name = "cmdClearTerminals"
			.Text = ("&Clear")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 16
			.SetBounds 290, 0, 97, 24
			.OnClick = @cmdClearTerminals_Click
			.Parent = @hbxTerminal
		End With
		' cmdRemoveTerminal
		With cmdRemoveTerminal
			.Name = "cmdRemoveTerminal"
			.Text = ("&Remove")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 17
			.SetBounds 193, 0, 97, 24
			.OnClick = @cmdRemoveTerminal_Click
			.Parent = @hbxTerminal
		End With
		' cmdChangeTerminal
		cmdChangeTerminal.Name = "cmdChangeTerminal"
		cmdChangeTerminal.Text = ("Chan&ge")
		cmdChangeTerminal.ExtraMargins.Right = 0
		cmdChangeTerminal.ExtraMargins.Bottom = 0
		cmdChangeTerminal.ExtraMargins.Left = 0
		cmdChangeTerminal.Align = DockStyle.alRight
		cmdChangeTerminal.TabIndex = 18
		cmdChangeTerminal.SetBounds 96, 0, 97, 24
		cmdChangeTerminal.OnClick = @cmdChangeTerminal_Click
		cmdChangeTerminal.Parent = @hbxTerminal
		' cmdAddTerminal
		With cmdAddTerminal
			.Name = "cmdAddTerminal"
			.Text = ("&Add")
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.TabIndex = 19
			.SetBounds -1, 0, 97, 24
			.OnClick = @cmdAddTerminal_Click
			.Parent = @hbxTerminal
		End With
		' grbThemes
		With grbThemes
			.Name = "grbThemes"
			.Text = ("Themes")
			.Align = DockStyle.alClient
			.Margins.Top = 20
			.Margins.Right = 10
			.Margins.Left = 10
			.Margins.Bottom = 10
			.TabIndex = 96
			.SetBounds 10, 0, 417, 400
			.Parent = @pnlThemes
		End With
		' vbxGeneral
		With vbxGeneral
			.Name = "vbxGeneral"
			.Text = "VerticalBox1"
			.TabIndex = 99
			.Align = DockStyle.alTop
			.SetBounds 10, 0, 417, 383
			.Designer = @This
			.Parent = @pnlGeneral
		End With
		' chkAutoCreateBakFiles
		With chkAutoCreateBakFiles
			.Name = "chkAutoCreateBakFiles"
			.Text = ("Auto create bak files before saving")
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.TabIndex = 100
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 5, 223, 21
			.ID = 1009
			.Parent = @vbxGeneral
		End With
		' chkAutoCreateRC
		chkAutoCreateRC.Name = "chkAutoCreateRC"
		chkAutoCreateRC.Text = ("Automatically create the icon and manifest files needed to build")
		chkAutoCreateRC.ExtraMargins.Top = 0
		chkAutoCreateRC.Align = DockStyle.alTop
		chkAutoCreateRC.TabIndex = 101
		chkAutoCreateRC.Constraints.Height = 21
		chkAutoCreateRC.AutoSize = True
		chkAutoCreateRC.SetBounds 0, 26, 295, 21
		chkAutoCreateRC.Parent = @vbxGeneral
		chkAutoCreateRC.ControlIndex = 1
		' chkAddRelativePathsToRecent
		With chkAddRelativePathsToRecent
			.Name = "chkAddRelativePathsToRecent"
			.Text = ("Add relative paths to recent")
			.TabIndex = 103
			.ExtraMargins.Top = 0
			.Align = DockStyle.alTop
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 98, 190, 21
			.Parent = @vbxGeneral
		End With
		' grbIncludePaths
		With grbIncludePaths
			.Name = "grbIncludePaths"
			.Text = ("Include Paths")
			.Align = DockStyle.alClient
			.ExtraMargins.Left = 0
			.Margins.Top = 23
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 104
			.SetBounds 10, 0, 407, 214
			.Parent = @pnlCompiler
		End With
		' grbLibraryPaths
		With grbLibraryPaths
			.Name = "grbLibraryPaths"
			.Text = ("Library Paths")
			.Align = DockStyle.alBottom
			.ExtraMargins.Left = 0
			.ExtraMargins.Top = 8
			.Margins.Top = 20
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 105
			.SetBounds 10, 222, 407, 178
			.Parent = @pnlCompiler
		End With
		' pnlIncludeMFFPath
		With pnlIncludeMFFPath
			.Name = "pnlIncludeMFFPath"
			.Text = ""
			.Align = DockStyle.alTop
			.TabIndex = 106
			.AutoSize = true
			.SetBounds 15, 23, 387, 16
			.Parent = @grbIncludePaths
		End With
		' chkIncludeMFFPath
		With chkIncludeMFFPath
			.Name = "chkIncludeMFFPath"
			.Text = ("Include MFF Path") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 107
			.SetBounds 0, 0, 132, 16
			.Parent = @pnlIncludeMFFPath
		End With
		' txtMFFpath
		txtMFFpath.Name = "txtMFFpath"
		txtMFFpath.Align = DockStyle.alClient
		txtMFFpath.ExtraMargins.Left = 0
		txtMFFpath.ExtraMargins.Right = 0
		txtMFFpath.ExtraMargins.Top = 0
		txtMFFpath.TabIndex = 108
		txtMFFpath.SetBounds 282, -18, 57, 34
		txtMFFpath.Parent = @pnlIncludeMFFPath
		' cmdMFFPath
		cmdMFFPath.Name = "cmdMFFPath"
		cmdMFFPath.Text = "..."
		cmdMFFPath.TabIndex = 109
		cmdMFFPath.Align = DockStyle.alRight
		cmdMFFPath.SetBounds 363, 0, 24, 16
		cmdMFFPath.OnClick = @cmdMFFPath_Click
		cmdMFFPath.Parent = @pnlIncludeMFFPath
		' vbxCodeEditor
		With vbxCodeEditor
			.Name = "vbxCodeEditor"
			.Text = "HorizontalBox1"
			.TabIndex = 110
			.Align = DockStyle.alTop
			.SetBounds 10, 0, 420, 387
			.Designer = @This
			.Parent = @pnlCodeEditor
		End With
		' grbDisplay
		With grbDisplay
			.Name = "grbDisplay"
			.Text = ("Display")
			.Align = DockStyle.alTop
			.AutoSize = True
			.TabIndex = 260
			.SetBounds 0, 0, 420, 22
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' grbCompletion
		With grbCompletion
			.Name = "grbCompletion"
			.Text = ("Completion")
			.Align = DockStyle.alTop
			.AutoSize = True
			.TabIndex = 261
			.SetBounds 0, 0, 420, 22
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' grbIntelliSense
		With grbIntelliSense
			.Name = "grbIntelliSense"
			.Text = ("IntelliSense")
			.Align = DockStyle.alTop
			.AutoSize = True
			.TabIndex = 262
			.SetBounds 0, 0, 420, 22
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' grbHistory
		With grbHistory
			.Name = "grbHistory"
			.Text = ("History")
			.Align = DockStyle.alTop
			.AutoSize = True
			.TabIndex = 263
			.SetBounds 0, 0, 420, 22
			.Designer = @This
			.Parent = @vbxCodeEditor
		End With
		' chkAutoIndentation
		chkAutoIndentation.Name = "chkAutoIndentation"
		chkAutoIndentation.Text = ("Auto Indentation")
		chkAutoIndentation.ExtraMargins.Top = 2
		chkAutoIndentation.Align = DockStyle.alTop
		chkAutoIndentation.TabIndex = 111
		chkAutoIndentation.Constraints.Height = 21
		chkAutoIndentation.AutoSize = True
		chkAutoIndentation.SetBounds 0, 2, 137, 21
		chkAutoIndentation.ControlIndex = 0
		chkAutoIndentation.Parent = @grbCompletion
		' chkEnableAutoComplete
		chkEnableAutoComplete.Name = "chkEnableAutoComplete"
		chkEnableAutoComplete.Text = ("Enable Auto Complete")
		chkEnableAutoComplete.ExtraMargins.Top = 0
		chkEnableAutoComplete.Align = DockStyle.alTop
		chkEnableAutoComplete.TabIndex = 112
		chkEnableAutoComplete.Constraints.Height = 21
		chkEnableAutoComplete.AutoSize = True
		chkEnableAutoComplete.SetBounds 0, 23, 161, 21
		chkEnableAutoComplete.ControlIndex = 1
		chkEnableAutoComplete.Parent = @grbCompletion
		' chkEnableAutoSuggestions
	With chkEnableAutoSuggestions
		.Name = "chkEnableAutoSuggestions"
		.Text = ("Enable Auto Suggestions")
		.TabIndex = 228
		.Align = DockStyle.alTop
		.ControlIndex = 1
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 23, 174, 21
		.Designer = @This
		.Parent = @grbCompletion
	End With
		' chkShowSpaces
		chkShowSpaces.Name = "chkShowSpaces"
		chkShowSpaces.Text = ("Show Spaces")
		chkShowSpaces.Align = DockStyle.alTop
		chkShowSpaces.ExtraMargins.Top = 0
		chkShowSpaces.TabIndex = 113
		chkShowSpaces.Constraints.Height = 21
		chkShowSpaces.AutoSize = True
		chkShowSpaces.SetBounds 0, 65, 118, 21
		chkShowSpaces.ControlIndex = 3
		chkShowSpaces.Parent = @grbDisplay
		' chkShowHolidayFrame
	With chkShowHolidayFrame
		.Name = "chkShowHolidayFrame"
		.Text = ("Show Indent Guides")
		.TabIndex = 252
		.Align = DockStyle.alTop
		.AutoSize = True
		.ControlIndex = 8
		.Caption = ("Show Indent Guides")
		.Constraints.Height = 21
		.SetBounds 0, 86, 152, 21
		.Designer = @This
		.Parent = @grbDisplay
	End With

		' chkShowKeywordsTooltip
	With chkShowKeywordsTooltip
		.Name = "chkShowKeywordsTooltip"
		.Text = ("Show Keywords Tooltip")
		.TabIndex = 114
		.ExtraMargins.Top = 0
		.Align = DockStyle.alTop
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 86, 166, 21

		.Parent = @grbIntelliSense
	End With
		' chkShowTooltipsAtTheTop
	With chkShowTooltipsAtTheTop
		.Name = "chkShowTooltipsAtTheTop"
		.Text = ("Show Tooltips at the Top")
		.TabIndex = 115
		.ExtraMargins.Top = 0
		.Align = DockStyle.alTop
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 107, 174, 21
		.Designer = @This
		.Parent = @grbIntelliSense
	End With
		' chkShowSymbolsTooltipsOnMouseHover
	With chkShowSymbolsTooltipsOnMouseHover
		.Name = "chkShowSymbolsTooltipsOnMouseHover"
		.Text = ("Show Symbols Tooltips On Mouse Hover")
		.TabIndex = 114
		.ExtraMargins.Top = 0
		.Align = DockStyle.alTop
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 86, 166, 21

		.Parent = @grbIntelliSense
	End With
		' chkShowSymbolsTooltipsOnMouseHover
	With chkShowClassesExplorerOnOpenWindow
		.Name = "ShowClassesExplorerOnOpenWindow"
		.Text = ("Show Classes Explorer On Open Window")
		.TabIndex = 114
		.ExtraMargins.Top = 0
		.Align = DockStyle.alTop
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 86, 166, 21

		.Parent = @grbIntelliSense
	End With
		' chkShowHorizontalSeparatorLines
	With chkShowHorizontalSeparatorLines
		.Name = "chkShowHorizontalSeparatorLines"
		.Text = ("Show Horizontal Separator Lines")
		.TabIndex = 230
		.Align = DockStyle.alTop
		.ControlIndex = 6

		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 128, 210, 21
		.Designer = @This
		.Parent = @grbDisplay
	End With
		' chkUseDirect2D
	With chkUseDirect2D
		.Name = "chkUseDirect2D"
		.Text = ("Smoother text rendering (Direct2D)")
		.TabIndex = 278
		.Align = DockStyle.alTop
		.AutoSize = True
		.ControlIndex = 10
		.Constraints.Height = 21
		.SetBounds 0, 212, 117, 21
		.Designer = @This
		.Parent = @grbDisplay
	End With
		' chkHighlightCurrentWord
	With chkHighlightCurrentWord
		.Name = "chkHighlightCurrentWord"
		.Text = ("Highlight Current Word")
		.ExtraMargins.Top = 0
		.Align = DockStyle.alTop
		.TabIndex = 116
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 149, 165, 21
		.Parent = @grbDisplay
	End With
		' chkHighlightCurrentLine
	With chkHighlightCurrentLine
		.Name = "chkHighlightCurrentLine"
		.Text = ("Highlight Current Line")
		.ExtraMargins.Top = 0
		.Align = DockStyle.alTop
		.TabIndex = 117
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 170, 158, 21
		.Parent = @grbDisplay
	End With
		' chkHighlightBrackets
	With chkHighlightBrackets
		.Name = "chkHighlightBrackets"
		.Text = ("Highlight Brackets")
		.ExtraMargins.Top = 0
		.Align = DockStyle.alTop
		.TabIndex = 118
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 191, 140, 21
		.Parent = @grbDisplay
	End With
		' chkAddSpacesToOperators
	With chkAddSpacesToOperators
		.Name = "chkAddSpacesToOperators"
		.Text = ("Add Spaces To Operators")
		.TabIndex = 119
		.ExtraMargins.Top = 0
		.Align = DockStyle.alTop
		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 212, 178, 21

		.Parent = @grbCompletion
	End With
		' chkSyntaxHighlightingIdentifiers
	With chkSyntaxHighlightingIdentifiers
		.Name = "chkSyntaxHighlightingIdentifiers"
		.Text = ("Syntax Highlighting Identifiers")
		.TabIndex = 121
		.Align = DockStyle.alTop

		.Constraints.Height = 21
		.AutoSize = True
		.SetBounds 0, 233, 199, 21
		.Designer = @This
		.Parent = @grbIntelliSense
	End With
		' pnlChangeIdentifiersCase
	With pnlChangeIdentifiersCase
		.Name = "pnlChangeIdentifiersCase"
		.Text = "Panel1"
		.AutoSize = True
		.TabIndex = 206
		.Align = DockStyle.alTop
		.AutoSize = True
		.SetBounds 0, 233, 417, 23
		.Designer = @This
		.Parent = @grbIntelliSense
	End With
		' chkChangeIdentifiersCase
		With chkChangeIdentifiersCase
			.Name = "chkChangeIdentifiersCase"
			.Text = ("Change Identifiers Case To") & ":"
			.TabIndex = 120
			.Align = DockStyle.alLeft
			.ExtraMargins.Top = 0
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 0, 254, 171, 21
			.Designer = @This
			.Parent = @pnlChangeIdentifiersCase
		End With
		' cboIdentifiersCase
		cboIdentifiersCase.Name = "cboIdentifiersCase"
		cboIdentifiersCase.Text = "ComboBoxEdit2"
		cboIdentifiersCase.ExtraMargins.Right = 20
		cboIdentifiersCase.ExtraMargins.Top = 0
		cboIdentifiersCase.ExtraMargins.Left = 0
		cboIdentifiersCase.Align = DockStyle.alRight
		cboIdentifiersCase.ExtraMargins.Bottom = 2
		cboIdentifiersCase.TabIndex = 32
		cboIdentifiersCase.SetBounds 198, 0, 150, 21
		cboIdentifiersCase.Parent = @pnlChangeIdentifiersCase
		' chkChangeKeywordsCase
		chkChangeKeywordsCase.Name = "chkChangeKeywordsCase"
		chkChangeKeywordsCase.Text = ("Change Keywords Case To") & ":"
		chkChangeKeywordsCase.ExtraMargins.Top = 0
		chkChangeKeywordsCase.Align = DockStyle.alLeft
		chkChangeKeywordsCase.ExtraMargins.Right = 0
		chkChangeKeywordsCase.TabIndex = 31
		chkChangeKeywordsCase.Constraints.Height = 21
		chkChangeKeywordsCase.AutoSize = True
		chkChangeKeywordsCase.SetBounds 0, 0, 202, 21
		chkChangeKeywordsCase.Parent = @pnlChangeKeywordsCase
		' cboCase
		cboCase.Name = "cboCase"
		cboCase.Text = "ComboBoxEdit2"
		cboCase.ExtraMargins.Right = 20
		cboCase.ExtraMargins.Top = 0
		cboCase.ExtraMargins.Left = 0
		cboCase.Align = DockStyle.alRight
		cboCase.ExtraMargins.Bottom = 2
		cboCase.TabIndex = 32
		cboCase.SetBounds 198, 0, 150, 21
		cboCase.Parent = @pnlChangeKeywordsCase
		' chkTabAsSpaces
		chkTabAsSpaces.Name = "chkTabAsSpaces"
		chkTabAsSpaces.Text = ("Tab style:")
		chkTabAsSpaces.ExtraMargins.Top = 0
		chkTabAsSpaces.Align = DockStyle.alLeft
		chkTabAsSpaces.ExtraMargins.Right = 0
		'chkTabAsSpaces.Caption = ML("Treat Tab as Spaces") & ":"
		chkTabAsSpaces.TabIndex = 33
		chkTabAsSpaces.Constraints.Height = 21
		chkTabAsSpaces.AutoSize = True
		chkTabAsSpaces.SetBounds 0, 0, 171, 21
		chkTabAsSpaces.Parent = @pnlTreatTabAsSpaces
		' cboTabStyle
		cboTabStyle.Name = "cboTabStyle"
		cboTabStyle.Text = "cboCase1"
		cboTabStyle.ExtraMargins.Left = 0
		cboTabStyle.ExtraMargins.Right = 20
		cboTabStyle.Align = DockStyle.alRight
		cboTabStyle.ExtraMargins.Top = 0
		cboTabStyle.ExtraMargins.Bottom = 2
		cboTabStyle.TabIndex = 34
		cboTabStyle.SetBounds 198, 0, 150, 21
		cboTabStyle.Parent = @pnlTreatTabAsSpaces
		' lblTabSize
		lblTabSize.Name = "lblTabSize"
		lblTabSize.Text = ("Tab Size") & ":"
		lblTabSize.ExtraMargins.Left = 40
		lblTabSize.ExtraMargins.Right = 0
		lblTabSize.Align = DockStyle.alClient
		lblTabSize.ExtraMargins.Top = 2
		lblTabSize.TabIndex = 35
		lblTabSize.SetBounds 40, 2, 175, 18
		lblTabSize.Parent = @pnlTabSize
		' txtTabSize
		txtTabSize.Name = "txtTabSize"
		txtTabSize.Text = ""
		txtTabSize.ExtraMargins.Left = 0
		txtTabSize.ExtraMargins.Right = 20
		txtTabSize.ExtraMargins.Top = 0
		txtTabSize.Align = DockStyle.alRight
		txtTabSize.ExtraMargins.Bottom = 2
		txtTabSize.TabIndex = 36
		txtTabSize.SetBounds 198, 0, 72, 18
		txtTabSize.Parent = @pnlTabSize
		' lstIncludePaths
		lstIncludePaths.Name = "lstIncludePaths"
		lstIncludePaths.Text = "ListControl1"
		lstIncludePaths.Align = DockStyle.alClient
		lstIncludePaths.ExtraMargins.Right = 0
		lstIncludePaths.TabIndex = 122
		lstIncludePaths.ControlIndex = 0
		lstIncludePaths.SetBounds 0, 0, 342, 121
		lstIncludePaths.Parent = @hbxIncludePaths
		' lstLibraryPaths
		lstLibraryPaths.Name = "lstLibraryPaths"
		lstLibraryPaths.Text = "ListControl11"
		lstLibraryPaths.Align = DockStyle.alClient
		lstLibraryPaths.ExtraMargins.Right = 0
		lstLibraryPaths.ExtraMargins.Top = 0
		lstLibraryPaths.TabIndex = 123
		lstLibraryPaths.SetBounds 0, 2, 314, 134
		lstLibraryPaths.Parent = @hbxLibraryPaths
		' lblOthers
		lblOthers.Name = "lblOthers"
		lblOthers.Text = ("Others") & ":"
		lblOthers.Align = DockStyle.alTop
		lblOthers.ExtraMargins.Top = 5
		lblOthers.ExtraMargins.Bottom = 4
		lblOthers.TabIndex = 124
		lblOthers.SetBounds 15, 46, 387, 18
		lblOthers.Parent = @grbIncludePaths
		' cmdAddInclude
		cmdAddInclude.Name = "cmdAddInclude"
		cmdAddInclude.Text = "+"
		cmdAddInclude.TabIndex = 125
		cmdAddInclude.ControlIndex = 0
		cmdAddInclude.SetBounds 0, 0, 20, 22
		cmdAddInclude.OnClick = @cmdAddInclude_Click
		cmdAddInclude.Parent = @vbxIncludePaths
		' cmdRemoveInclude
		cmdRemoveInclude.Name = "cmdRemoveInclude"
		cmdRemoveInclude.Text = "-"
		cmdRemoveInclude.TabIndex = 126
		cmdRemoveInclude.ControlIndex = 1
		cmdRemoveInclude.SetBounds 0, 22, 20, 22
		cmdRemoveInclude.OnClick = @cmdRemoveInclude_Click
		cmdRemoveInclude.Parent = @vbxIncludePaths
		' cmdAddLibrary
		cmdAddLibrary.Name = "cmdAddLibrary"
		cmdAddLibrary.Text = "+"
		cmdAddLibrary.TabIndex = 127
		cmdAddLibrary.ControlIndex = 0
		cmdAddLibrary.SetBounds 0, 0, 24, 22
		cmdAddLibrary.OnClick = @cmdAddLibrary_Click
		cmdAddLibrary.Parent = @vbxLibraryPaths
		' cmdRemoveLibrary
		cmdRemoveLibrary.Name = "cmdRemoveLibrary"
		cmdRemoveLibrary.Text = "-"
		cmdRemoveLibrary.TabIndex = 128
		cmdRemoveLibrary.ControlIndex = 1
		cmdRemoveLibrary.SetBounds 0, 22, 24, 22
		cmdRemoveLibrary.OnClick = @cmdRemoveLibrary_Click
		cmdRemoveLibrary.Parent = @vbxLibraryPaths
		' lblHistoryLimit
		lblHistoryLimit.Name = "lblHistoryLimit"
		lblHistoryLimit.Text = ("History limit") & ":"
		lblHistoryLimit.ExtraMargins.Top = 2
		lblHistoryLimit.ExtraMargins.Left = 40
		lblHistoryLimit.ExtraMargins.Right = 0
		lblHistoryLimit.Align = DockStyle.alClient
		lblHistoryLimit.TabIndex = 37
		lblHistoryLimit.SetBounds 40, 2, 175, 18
		lblHistoryLimit.Parent = @pnlHistoryLimit
		' txtHistoryLimit
		txtHistoryLimit.Name = "txtHistoryLimit"
		txtHistoryLimit.ExtraMargins.Top = 0
		txtHistoryLimit.ExtraMargins.Right = 20
		txtHistoryLimit.ExtraMargins.Left = 0
		txtHistoryLimit.Align = DockStyle.alRight
		txtHistoryLimit.ExtraMargins.Bottom = 2
		txtHistoryLimit.TabIndex = 38
		txtHistoryLimit.SetBounds 198, 0, 72, 18
		txtHistoryLimit.Text = ""
		txtHistoryLimit.Parent = @pnlHistoryLimit
		' grbGrid
		grbGrid.Name = "grbGrid"
		grbGrid.Text = ("Grid")
		grbGrid.Align = DockStyle.alTop
		grbGrid.TabIndex = 129
		grbGrid.SetBounds 10, 0, 417, 122
		grbGrid.Parent = @pnlDesigner
		' lblGridSize
		lblGridSize.Name = "lblGridSize"
		lblGridSize.Text = ("Size") & ":"
		lblGridSize.TabIndex = 130
		lblGridSize.SetBounds 16, 31, 60, 18
		lblGridSize.Parent = @grbGrid
		' txtGridSize
		txtGridSize.Name = "txtGridSize"
		txtGridSize.Text = "10"
		txtGridSize.TabIndex = 131
		txtGridSize.SetBounds 73, 31, 114, 18
		txtGridSize.Parent = @grbGrid
		' chkShowAlignmentGrid
		chkShowAlignmentGrid.Name = "chkShowAlignmentGrid"
		chkShowAlignmentGrid.Text = ("Show Alignment Grid")
		chkShowAlignmentGrid.TabIndex = 65
		chkShowAlignmentGrid.SetBounds 8, -5, 186, 30
		chkShowAlignmentGrid.Parent = @pnlGrid
		' chkSnapToGrid
		chkSnapToGrid.Name = "chkSnapToGrid"
		chkSnapToGrid.Text = ("Snap to Grid")
		chkSnapToGrid.TabIndex = 66
		chkSnapToGrid.SetBounds 8, 19, 138, 24
		chkSnapToGrid.Parent = @pnlGrid
		' grbColors
		grbColors.Name = "grbColors"
		grbColors.Text = ("Colors")
		grbColors.Align = DockStyle.alClient
		grbColors.Margins.Top = 21
		grbColors.Margins.Right = 15
		grbColors.Margins.Left = 15
		grbColors.Margins.Bottom = 15
		grbColors.TabIndex = 132
		grbColors.SetBounds 10, 0, 417, 349
		grbColors.Parent = @pnlColorsAndFonts
		' grbFont
		grbFont.Name = "grbFont"
		grbFont.Text = ("Font (applies to all styles)")
		grbFont.Align = DockStyle.alBottom
		grbFont.ExtraMargins.Top = 5
		grbFont.AutoSize = True
		grbFont.TabIndex = 133
		grbFont.SetBounds 10, 354, 417, 46
		grbFont.Parent = @pnlColorsAndFonts
		' cboTheme
		cboTheme.Name = "cboTheme"
		cboTheme.Text = "ComboBoxEdit2"
		cboTheme.Align = DockStyle.alTop
		cboTheme.ExtraMargins.Right = 15
		cboTheme.ExtraMargins.Bottom = 15
		cboTheme.TabIndex = 39
		cboTheme.SetBounds 0, 0, 212, 21
		cboTheme.OnChange = @cboTheme_Change
		cboTheme.Parent = @vbxTheme
		' lstColorKeys
		lstColorKeys.Name = "lstColorKeys"
		lstColorKeys.Text = "ListControl1"
		lstColorKeys.Align = DockStyle.alClient
		lstColorKeys.ExtraMargins.Right = 15
		lstColorKeys.ControlIndex = 2
		lstColorKeys.TabIndex = 221
		lstColorKeys.SetBounds 0, 36, 212, 277
		lstColorKeys.OnChange = @lstColorKeys_Change
		lstColorKeys.Parent = @vbxTheme
		' cmdAdd
		cmdAdd.Name = "cmdAdd"
		cmdAdd.Text = ("&Add")
		cmdAdd.ControlIndex = 1
		cmdAdd.Align = DockStyle.alClient
		cmdAdd.ExtraMargins.Bottom = 0
		cmdAdd.TabIndex = 40
		cmdAdd.SetBounds 0, 0, 83, 23
		cmdAdd.OnClick = @cmdAdd_Click
		cmdAdd.Parent = @hbxThemeCommands
		' cmdRemove
		cmdRemove.Name = "cmdRemove"
		cmdRemove.Text = ("&Remove")
		cmdRemove.ControlIndex = 0
		cmdRemove.Align = DockStyle.alRight
		cmdRemove.TabIndex = 41
		cmdRemove.SetBounds 83, 0, 71, 23
		cmdRemove.OnClick = @cmdRemove_Click
		cmdRemove.Parent = @hbxThemeCommands
		' chkForeground
		chkForeground.Name = "chkForeground"
		chkForeground.Text = ("Auto")
		chkForeground.Align = DockStyle.alRight
		chkForeground.ExtraMargins.Left = 5
		chkForeground.TabIndex = 43
		chkForeground.SetBounds 106, 0, 48, 22
		chkForeground.OnClick = @chkForeground_Click
		chkForeground.Parent = @hbxForeground
		' txtColorForeground
		txtColorForeground.Name = "txtColorForeground"
		txtColorForeground.Text = ""
		txtColorForeground.Align = DockStyle.alClient
		txtColorForeground.TabIndex = 44
		txtColorForeground.SetBounds 0, 0, 77, 22
		txtColorForeground.BackColor = 0
		txtColorForeground.Designer = @This
		txtColorForeground.OnKeyPress = @_txtColorForeground_KeyPress
		txtColorForeground.Parent = @hbxForeground
		' cmdForeground
		cmdForeground.Name = "cmdForeground"
		cmdForeground.Text = "..."
		cmdForeground.Align = DockStyle.alRight
		cmdForeground.TabIndex = 45
		cmdForeground.SetBounds 77, 0, 24, 22
		'cmdForeground.Caption = "..."
		cmdForeground.OnClick = @cmdForeground_Click
		cmdForeground.Parent = @hbxForeground
		' cmdFont
		cmdFont.Name = "cmdFont"
		cmdFont.Text = "..."
		cmdFont.ExtraMargins.Bottom = 10
		cmdFont.ExtraMargins.Right = 10
		cmdFont.Align = DockStyle.alRight
		cmdFont.ExtraMargins.Top = 20
		cmdFont.TabIndex = 138
		cmdFont.SetBounds 383, 20, 24, 16
		'cmdFont.Caption = "..."
		cmdFont.OnClick = @cmdFont_Click
		cmdFont.Parent = @grbFont
		' lblFont
		lblFont.Name = "lblFont"
		lblFont.Text = ("Font")
		lblFont.Align = DockStyle.alClient
		lblFont.ExtraMargins.Left = 10
		lblFont.ExtraMargins.Top = 20
		lblFont.ExtraMargins.Bottom = 10
		lblFont.CenterImage = True
		lblFont.TabIndex = 139
		lblFont.SetBounds 10, 20, 373, 16
		lblFont.Parent = @grbFont
		'cmdProjectsPath.Caption = "..."
		' chkBackground
		chkBackground.Name = "chkBackground"
		chkBackground.Text = ("Auto")
		chkBackground.Align = DockStyle.alRight
		chkBackground.ExtraMargins.Left = 5
		chkBackground.TabIndex = 47
		chkBackground.SetBounds 106, 0, 48, 24
		chkBackground.OnClick = @chkBackground_Click
		chkBackground.Parent = @hbxBackground
		' txtColorBackground
		txtColorBackground.Name = "txtColorBackground"
		txtColorBackground.Align = DockStyle.alClient
		txtColorBackground.TabIndex = 48
		txtColorBackground.SetBounds 0, 0, 77, 24
		txtColorBackground.BackColor = 0
		txtColorBackground.Text = ""
		txtColorBackground.Designer = @This
		txtColorBackground.OnKeyPress = @_txtColorBackground_KeyPress
		txtColorBackground.Parent = @hbxBackground
		' cmdBackground
		cmdBackground.Name = "cmdBackground"
		cmdBackground.Text = "..."
		cmdBackground.Align = DockStyle.alRight
		cmdBackground.TabIndex = 49
		cmdBackground.SetBounds 77, 0, 24, 24
		'cmdBackground.Caption = "..."
		cmdBackground.OnClick = @cmdBackground_Click
		cmdBackground.Parent = @hbxBackground
		' hbxThemeCommands
		With hbxThemeCommands
			.Name = "hbxThemeCommands"
			.Text = "HorizontalBox1"
			.TabIndex = 219
			.ControlIndex = 0
			.Align = DockStyle.alTop
			.ExtraMargins.Bottom = 14
			.SetBounds 0, 0, 154, 23
			.Designer = @This
			.Parent = @vbxColors
		End With
		' lblForeground
		lblForeground.Name = "lblForeground"
		lblForeground.Text = ("Foreground") & ":"
		lblForeground.ControlIndex = 1
		lblForeground.Align = DockStyle.alTop
		lblForeground.TabIndex = 42
		lblForeground.SetBounds 0, 37, 154, 16
		lblForeground.Parent = @vbxColors
		' hbxForeground
		With hbxForeground
			.Name = "hbxForeground"
			.Text = "HorizontalBox1"
			.TabIndex = 224
			.ControlIndex = 2
			.Align = DockStyle.alTop
			.SetBounds 0, 53, 154, 22
			.Designer = @This
			.Parent = @vbxColors
		End With
		' lblBackground
		lblBackground.Name = "lblBackground"
		lblBackground.Text = ("Background") & ":"
		lblBackground.ControlIndex = 3
		lblBackground.Align = DockStyle.alTop
		lblBackground.ExtraMargins.Top = 2
		lblBackground.TabIndex = 46
		lblBackground.SetBounds 0, 77, 154, 16
		lblBackground.Parent = @vbxColors
		' hbxBackground
		With hbxBackground
			.Name = "hbxBackground"
			.Text = "HorizontalBox1"
			.TabIndex = 225
			.ControlIndex = 4
			.Align = DockStyle.alTop
			.SetBounds 0, 93, 154, 24
			.Designer = @This
			.Parent = @vbxColors
		End With
		' lblFrame
		With lblFrame
			.Name = "lblFrame"
			.Text = ("Frame") & ":"
			.ControlIndex = 5
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 2
			.TabIndex = 50
			.SetBounds 0, 119, 154, 16
			.Parent = @vbxColors
		End With
		' hbxFrame
		With hbxFrame
			.Name = "hbxFrame"
			.Text = "HorizontalBox1"
			.TabIndex = 226
			.ControlIndex = 6
			.Align = DockStyle.alTop
			.SetBounds 0, 135, 154, 23
			.Designer = @This
			.Parent = @vbxColors
		End With
		' lblIndicator
		lblIndicator.Name = "lblIndicator"
		lblIndicator.Text = ("Indicator") & ":"
		lblIndicator.ControlIndex = 7
		lblIndicator.Align = DockStyle.alTop
		lblIndicator.ExtraMargins.Top = 2
		lblIndicator.TabIndex = 54
		lblIndicator.SetBounds 0, 160, 154, 16
		lblIndicator.Parent = @vbxColors
		' hbxIndicator
		With hbxIndicator
			.Name = "hbxIndicator"
			.Text = "HorizontalBox1"
			.TabIndex = 227
			.ControlIndex = 11
			.Align = DockStyle.alTop
			.SetBounds 0, 176, 154, 23
			.Designer = @This
			.Parent = @vbxColors
		End With
		' chkBold
		chkBold.Name = "chkBold"
		chkBold.Text = ("Bold")
		chkBold.ControlIndex = 8
		chkBold.Align = DockStyle.alTop
		chkBold.ExtraMargins.Top = 5
		chkBold.TabIndex = 58
		chkBold.Constraints.Height = 21
		chkBold.AutoSize = True
		chkBold.SetBounds 0, 204, 75, 21
		chkBold.OnClick = @chkBold_Click
		chkBold.Parent = @vbxColors
		' chkItalic
		chkItalic.Name = "chkItalic"
		chkItalic.Text = ("Italic")
		chkItalic.ControlIndex = 9
		chkItalic.Align = DockStyle.alTop
		chkItalic.TabIndex = 59
		chkItalic.Constraints.Height = 21
		chkItalic.AutoSize = True
		chkItalic.SetBounds 0, 225, 78, 21
		chkItalic.OnClick = @chkItalic_Click
		chkItalic.Parent = @vbxColors
		' chkUnderline
		chkUnderline.Name = "chkUnderline"
		chkUnderline.Text = ("Underline")
		chkUnderline.ControlIndex = 10
		chkUnderline.Align = DockStyle.alTop
		chkUnderline.TabIndex = 60
		chkUnderline.Constraints.Height = 21
		chkUnderline.AutoSize = True
		chkUnderline.SetBounds 0, 246, 100, 21
		chkUnderline.OnClick = @chkUnderline_Click
		chkUnderline.Parent = @vbxColors
		' chkIndicator
		chkIndicator.Name = "chkIndicator"
		chkIndicator.Text = ("Auto")
		chkIndicator.Align = DockStyle.alRight
		chkIndicator.ExtraMargins.Left = 5
		chkIndicator.TabIndex = 55
		chkIndicator.SetBounds 106, 0, 48, 23
		chkIndicator.OnClick = @chkIndicator_Click
		chkIndicator.Parent = @hbxIndicator
		' txtColorIndicator
		txtColorIndicator.Name = "txtColorIndicator"
		txtColorIndicator.Text = ""
		txtColorIndicator.Align = DockStyle.alClient
		txtColorIndicator.TabIndex = 56
		txtColorIndicator.SetBounds 0, 0, 77, 23
		txtColorIndicator.BackColor = 0
		txtColorIndicator.Designer = @This
		txtColorIndicator.OnKeyPress = @_txtColorIndicator_KeyPress
		txtColorIndicator.Parent = @hbxIndicator
		' cmdIndicator
		cmdIndicator.Name = "cmdIndicator"
		cmdIndicator.Text = "..."
		cmdIndicator.Align = DockStyle.alRight
		cmdIndicator.TabIndex = 57
		cmdIndicator.SetBounds 77, 0, 24, 23
		'cmdIndicator.Caption = "..."
		cmdIndicator.OnClick = @cmdIndicator_Click
		cmdIndicator.Parent = @hbxIndicator
		'
		' lblCompiler64
		lblCompiler64.Name = "lblCompiler64"
		lblCompiler64.Text = ("Compiler 64-bit:") 
		lblCompiler64.TabIndex = 144
		lblCompiler64.SetBounds 15, 22, 120, 16
		lblCompiler64.Parent = @grbDefaultCompilers
		' lblCompiler64Path
		lblCompiler64Path.Name = "lblCompiler64Path"
		lblCompiler64Path.Font.Bold = True
		lblCompiler64Path.Text = "./" & BUNDLED_COMPILER_FOLDER & "/" & BUNDLED_COMPILER_EXE
		lblCompiler64Path.TabIndex = 145
		lblCompiler64Path.SetBounds 140, 20, 262, 16
		lblCompiler64Path.Parent = @grbDefaultCompilers
		'' 13.3.A S6 O4: Default Compiler reduced to a read-only info line. cboCompiler64 was
		'' already permanently hidden and had no Load/Save wiring anywhere in this form -- the
		'' visible "Compiler 64-bit: ./Compiler/fbc64.exe" label pair above is the entire feature.
		' pnlInterfaceFont
		With pnlInterfaceFont
			.Name = "pnlInterfaceFont"
			.Text = "Panel2"
			.Align = DockStyle.alTop
			.ExtraMargins.Bottom = 20
			.AutoSize = True
			.TabIndex = 147
			.SetBounds 10, 20, 397, 20
			.Parent = @grbThemes
		End With
		' lblInterfaceFontLabel
		With lblInterfaceFontLabel
			.Name = "lblInterfaceFontLabel"
			.Text = ("Interface font") & ":"
			.ControlIndex = 6
			.Align = DockStyle.alLeft
			.TabIndex = 148
			.SetBounds 0, 0, 108, 20
			.Parent = @pnlInterfaceFont
		End With
		' lblInterfaceFont
		With lblInterfaceFont
			.Name = "lblInterfaceFont"
			.Text = "Segoe UI, 9 pt"
			.ControlIndex = 5
			.Align = DockStyle.alLeft
			.TabIndex = 149
			.SetBounds 108, 0, 264, 20
			'.Caption = "Tahoma, 8 pt"
			.Parent = @pnlInterfaceFont
		End With
		' cmdInterfaceFont
		With cmdInterfaceFont
			.Name = "cmdInterfaceFont"
			.Text = "..."
			.ControlIndex = 7
			.Align = DockStyle.alRight
			.TabIndex = 150
			.SetBounds 373, 0, 24, 20
			'.Caption = "..."
			.OnClick = @cmdInterfaceFont_Click
			.Parent = @pnlInterfaceFont
		End With
		' chkDisplayIcons
		With chkDisplayIcons
			.Name = "chkDisplayIcons"
			.Text = ("Display Icons in the Menu")
			.Align = DockStyle.alTop
			.TabIndex = 151
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 60, 177, 21
			.Parent = @grbThemes
		End With
		' chkShowMainToolbar
		With chkShowMainToolbar
			.Name = "chkShowMainToolbar"
			.Text = ("Show main Toolbar")
			.Align = DockStyle.alTop
			.TabIndex = 152
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 81, 145, 21
			.Parent = @grbThemes
		End With
		'chkShowToolBoxLocal
		With chkShowToolBoxLocal
			.Name = "chkShowToolBoxLocal"
			.Text = ("Display ToolBox in localized language.")
			.Align = DockStyle.alTop
			.TabIndex = 153
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 102, 235, 21
			.Parent = @grbThemes
		End With
		' chkFrame
		With chkFrame
			.Name = "chkFrame"
			.Text = ("Auto")
			.Align = DockStyle.alRight
			.ExtraMargins.Left = 5
			.TabIndex = 51
			.SetBounds 106, 0, 48, 23
			.OnClick = @chkFrame_Click
			.Parent = @hbxFrame
		End With
		' txtColorFrame
		With txtColorFrame
			.Name = "txtColorFrame"
			.Align = DockStyle.alClient
			.TabIndex = 52
			.SetBounds 0, 0, 77, 23
			.BackColor = 0
			.Designer = @This
			.OnKeyPress = @_txtColorFrame_KeyPress
			.Parent = @hbxFrame
		End With
		' cmdFrame
		With cmdFrame
			.Name = "cmdFrame"
			.Text = "..."
			.Align = DockStyle.alRight
			.TabIndex = 53
			.SetBounds 77, 0, 24, 23
			'.Caption = "..."
			.OnClick = @cmdFrame_Click
			.Parent = @hbxFrame
		End With
		' grbDefaultHelp
		With grbDefaultHelp
			.Name = "grbDefaultHelp"
			.Text = ("Default Help")
			.Align = DockStyle.alTop
			.Margins.Top = 22
			.Margins.Left = 15
			.Margins.Bottom = 18
			.Margins.Right = 15
			.AutoSize = True
			.TabIndex = 155
			.SetBounds 10, 0, 417, 61
			.Parent = @pnlHelp
		End With
		' cboHelp
		With cboHelp
			.Name = "cboHelp"
			.Text = "cboHelp"
			.Align = DockStyle.alTop
			.TabIndex = 156
			.SetBounds 15, 22, 387, 21
			.Parent = @grbDefaultHelp
		End With
		' grbHelpPaths
		With grbHelpPaths
			.Name = "grbHelpPaths"
			.Text = ("Help Paths")
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 5
			.Margins.Top = 22
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 157
			.SetBounds 10, 66, 417, 334
			.Parent = @pnlHelp
		End With
		' lvHelpPaths
		With lvHelpPaths
			.Name = "lvHelpPaths"
			.Text = "lvTerminalPaths1"
			.ExtraMargins.Bottom = 15
			.Align = DockStyle.alClient
			lvHelpPaths.TabIndex = 158
			.SetBounds 15, 22, 387, 258
			.Designer = @This
			.OnItemActivate = @lvHelpPaths_ItemActivate_
			.Parent = @grbHelpPaths
		End With
		With cmdClearHelps
			.Name = "cmdClearHelps"
			.Text = ("&Clear")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 23
			.SetBounds 290, 0, 97, 24
			.OnClick = @cmdClearHelps_Click
			.Parent = @hbxHelp
		End With
		' cmdRemoveHelp
		With cmdRemoveHelp
			.Name = "cmdRemoveHelp"
			.Text = ("&Remove")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.Align = DockStyle.alRight
			.TabIndex = 24
			.SetBounds 193, 0, 97, 24
			.OnClick = @cmdRemoveHelp_Click
			.Parent = @hbxHelp
		End With
		' cmdChangeHelp
		With cmdChangeHelp
			.Name = "cmdChangeHelp"
			.Text = ("Chan&ge")
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.TabIndex = 25
			.SetBounds 96, 0, 97, 24
			.OnClick = @cmdChangeHelp_Click
			.Parent = @hbxHelp
		End With
		' cmdAddHelp
		With cmdAddHelp
			.Name = "cmdAddHelp"
			.Text = ("&Add")
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.TabIndex = 26
			.SetBounds -1, 0, 97, 24
			.OnClick = @cmdAddHelp_Click
			.Parent = @hbxHelp
		End With
		' cmdClearHelp
		' optSaveCurrentFile
		With optSaveCurrentFile
			.Name = "optSaveCurrentFile"
			.Text = ("Save Current Project / File")
			.TabIndex = 62
			.SetBounds 18, 22, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' optDoNotSave
		With optDoNotSave
			.Name = "optDoNotSave"
			.Text = ("Don't Save")
			.TabIndex = 63
			.SetBounds 18, 90, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' optSaveAllFiles
		With optSaveAllFiles
			.Name = "optSaveAllFiles"
			.Text = ("Save All Files")
			.TabIndex = 64
			.SetBounds 18, 45, 184, 16
			.Parent = @grbWhenCompiling
		End With
		' pnlGrid
		With pnlGrid
			.Name = "pnlGrid"
			.Text = "Panel2"
			.TabIndex = 159
			.SetBounds 10, 63, 314, 56
			.Parent = @grbGrid
		End With
		' chkLimitDebug
		With chkLimitDebug
			.Name = "chkLimitDebug"
			.Text = ("Limit debug to the directory of the main file")
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 10
			.TabIndex = 160
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 138, 261, 21
			.Parent = @pnlDebugger
		End With
		' chkDisplayWarningsInDebug
		With chkDisplayWarningsInDebug
			.Name = "chkDisplayWarningsInDebug"
			.Text = ("Display warnings in debug")
			.ExtraMargins.Top = 5
			.Align = DockStyle.alTop
			.TabIndex = 161
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 159, 179, 21
			.Parent = @pnlDebugger
		End With
		' chkCreateNonStaticEventHandlers
		With chkCreateNonStaticEventHandlers
			.Name = "chkCreateNonStaticEventHandlers"
			.Text = ("Event handlers: Non-static (modern)")
			.TabIndex = 162
			.SetBounds 12, 150, 288, 24

			.Designer = @This
			.OnClick = @chkCreateNonStaticEventHandlers_Click_
			.Parent = @pnlDesigner
		End With
		' grbOtherEditors
		With grbOtherEditors
			.Name = "grbOtherEditors"
			.Text = ("Other Editors")
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 0
			.ExtraMargins.Left = 0
			.Margins.Top = 21
			.Margins.Right = 15
			.Margins.Left = 15
			.Margins.Bottom = 15
			.TabIndex = 166
			.SetBounds 10, 0, 407, 400
			.Parent = @pnlOtherEditors
		End With
		' lvOtherEditors
		With lvOtherEditors
			.Name = "lvOtherEditors"
			.Text = "lvHelpPaths1"
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 0
			.Align = DockStyle.alClient
			.ExtraMargins.Bottom = 15
			.TabIndex = 167
			.SetBounds 15, 21, 387, 325
			.Designer = @This
			.OnItemActivate = @lvOtherEditors_ItemActivate_
			.Parent = @grbOtherEditors
		End With
		' cmdClearEditor
		With cmdClearEditor
			.Name = "cmdClearEditor"
			.Text = ("&Clear")
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.Align = DockStyle.alRight
			.TabIndex = 27
			.SetBounds 290, 0, 97, 24
			.Designer = @This
			.OnClick = @cmdClearEditor_Click_
			.Parent = @hbxEditors
		End With
		' cmdRemoveEditor
		With cmdRemoveEditor
			.Name = "cmdRemoveEditor"
			.Text = ("&Remove")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.TabIndex = 28
			.SetBounds 193, 0, 97, 24
			.Designer = @This
			.OnClick = @cmdRemoveEditor_Click_
			.Parent = @hbxEditors
		End With
		' cmdChangeEditor
		With cmdChangeEditor
			.Name = "cmdChangeEditor"
			.Text = ("Chan&ge")
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Left = 0
			.ExtraMargins.Right = 0
			.TabIndex = 29
			.SetBounds 96, 0, 97, 24
			.Designer = @This
			.OnClick = @cmdChangeEditor_Click_
			.Parent = @hbxEditors
		End With
		' cmdAddEditor
		With cmdAddEditor
			.Name = "cmdAddEditor"
			.Text = ("&Add")
			.Align = DockStyle.alRight
			.ExtraMargins.Left = 0
			.ExtraMargins.Bottom = 0
			.ExtraMargins.Right = 0
			.TabIndex = 30
			.SetBounds -1, 0, 97, 24
			'.Caption = "Add"
			.Designer = @This
			.OnClick = @cmdAddEditor_Click_
			.Parent = @hbxEditors
		End With
			'.Caption = "Change"
			'.Caption = "Remove"
			'.Caption = "Clear"
		' grbWhenCompiling
		With grbWhenCompiling
			.Name = "grbWhenCompiling"
			.Text = ("When compiling") & ":"
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 5
			.TabIndex = 169
			.SetBounds 0, 222, 417, 120
			.Parent = @vbxGeneral
		End With
		' lblProjectsPath
		lblProjectsPath.Name = "lblProjectsPath"
		lblProjectsPath.Text = ("Projects path") & ":"
		lblProjectsPath.Align = DockStyle.alTop
		lblProjectsPath.ExtraMargins.Top = 5
		lblProjectsPath.TabIndex = 170
		lblProjectsPath.SetBounds 0, 347, 417, 16
		lblProjectsPath.Parent = @vbxGeneral
		' txtProjectsPath
		txtProjectsPath.Name = "txtProjectsPath"
		txtProjectsPath.Text = "./Projects"
		txtProjectsPath.Align = DockStyle.alClient
		txtProjectsPath.ExtraMargins.Bottom = 0
		txtProjectsPath.ExtraMargins.Right = 0
		txtProjectsPath.ControlIndex = 0
		txtProjectsPath.TabIndex = 2
		txtProjectsPath.SetBounds 0, 0, 394, 20
		txtProjectsPath.Parent = @pnlProjectsPath
		' cmdProjectsPath
		cmdProjectsPath.Name = "cmdProjectsPath"
		cmdProjectsPath.Text = "..."
		cmdProjectsPath.Align = DockStyle.alRight
			cmdProjectsPath.ExtraMargins.Bottom = -1
			cmdProjectsPath.ExtraMargins.Top = -1
			cmdProjectsPath.ExtraMargins.Right = -1
		cmdProjectsPath.ControlIndex = 1
		cmdProjectsPath.TabIndex = 3
		cmdProjectsPath.SetBounds 394, -1, 24, 22
		cmdProjectsPath.OnClick = @cmdProjectsPath_Click
		cmdProjectsPath.Parent = @pnlProjectsPath
		'' 13.3.A S6 O4: Default file-format/new-line-format pickers removed -- confirmed vestigial.
		'' Both rows were already permanently hidden (hbxDefaultFileFormat/hbxDefaultNewLineFormat
		'' .Visible=False below), never populated with any AddItem calls, and never read from or
		'' saved to any global/INI state anywhere in this form. ChangeFileEncoding/ChangeNewLineType
		'' (Main.bas) already ignore their parameter and unconditionally show "UTF-8"/"CR+LF" on the
		'' status bar, matching AddTab forcing UTF-8+CRLF for every file.
		' optPromptToSave
		With optPromptToSave
			.Name = "optPromptToSave"
			.Text = ("Prompt To Save")
			.TabIndex = 176
			.SetBounds 18, 68, 184, 16

			.Parent = @grbWhenCompiling
		End With
		' chkCreateFormTypesWithoutTypeWord
		With chkCreateFormTypesWithoutTypeWord
			.Name = "chkCreateFormTypesWithoutTypeWord"
			.Text = ("Create Form types without Type word")
			.TabIndex = 180
			.SetBounds 12, 128, 288, 24

			.Parent = @pnlDesigner
		End With
		' grbCommandPromptOptions
		With grbCommandPromptOptions
			.Name = "grbCommandPromptOptions"
			.Text = ("Command Prompt options")
			.TabIndex = 181
			.Align = DockStyle.alTop
			.ExtraMargins.Top = 5
			.SetBounds 10, 69, 417, 94

			.Parent = @pnlTerminal
		End With
		' optMainFileFolder
		With optMainFileFolder
			.Name = "optMainFileFolder"
			.Text = ("Main File folder")
			.TabIndex = 182
			.SetBounds 20, 39, 220, 20

			.Parent = @grbCommandPromptOptions
		End With
		' lblOpenCommandPromptIn
		With lblOpenCommandPromptIn
			.Name = "lblOpenCommandPromptIn"
			.Text = ("Open command prompt in:")
			.TabIndex = 183
			.SetBounds 20, 19, 380, 20

			.Parent = @grbCommandPromptOptions
		End With
		' optInFolder
		With optInFolder
			.Name = "optInFolder"
			.Text = ("Folder") & ":"
			.TabIndex = 184
			.SetBounds 20, 59, 120, 20

			.Parent = @grbCommandPromptOptions
		End With
		' txtInFolder
		With txtInFolder
			.Name = "txtInFolder"
			.Text = "./Projects"
			.TabIndex = 185
			.SetBounds 140, 58, 240, 20
			.Parent = @grbCommandPromptOptions
		End With
		' cmdInFolder
		With cmdInFolder
			.Name = "cmdInFolder"
			.Text = "..."
			.TabIndex = 186
			.SetBounds 380, 57, 24, 22
			.Designer = @This
			.OnClick = @cmdInFolder_Click_
			.Parent = @grbCommandPromptOptions
		End With
		' lblIntellisenseLimit
		With lblIntellisenseLimit
			.Name = "lblIntellisenseLimit"
			.Text = ("IntelliSense limit (items)") & ":"
			.TabIndex = 187

			.ExtraMargins.Top = 2
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 40
			.Align = DockStyle.alClient
			.SetBounds 40, 2, 175, 18
			.Parent = @pnlIntellisenseLimit
		End With
		' txtIntellisenseLimit
		With txtIntellisenseLimit
			.Name = "txtIntellisenseLimit"
			.TabIndex = 188
			.Text = ""
			.ExtraMargins.Left = 0
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 20
			.Align = DockStyle.alRight
			.ControlIndex = 2
			.ExtraMargins.Bottom = 2
			.SetBounds 198, 0, 72, 18
			.Parent = @pnlIntellisenseLimit
		End With
		'' 13.3.A S6 O4: "Turn on Environment variables" removed -- confirmed non-functional. The
		'' debuggee is launched via CreateProcess in Debug.bas with lpEnvironment=0 (inherits the
		'' parent's environment unchanged); EnvironmentVariables/TurnOnEnvironmentVariables were
		'' saved to/loaded from INI but never applied anywhere. The globals + their INI round-trip
		'' are left in place (harmless, matches the S4 precedent of keeping a dead-but-referenced
		'' field) in case a future session wires up real env-var injection for the debuggee.
		' chkDarkMode
		With chkDarkMode
			.Name = "chkDarkMode"
			.Text = ("Dark Mode (Windows 10 1809 and above)")
			.TabIndex = 195
			.Align = DockStyle.alTop
			.Constraints.Height = 21
			.AutoSize = True
			.SetBounds 10, 142, 323, 21
			.Parent = @grbThemes
		End With
		' chkPlaceStaticEventHandlersAfterTheConstructor
		With chkPlaceStaticEventHandlersAfterTheConstructor
			.Name = "chkPlaceStaticEventHandlersAfterTheConstructor"
			.Text = ("Place static event handlers after the Constructor")
			.TabIndex = 196

			.SetBounds 32, 172, 310, 24
			.Parent = @pnlDesigner
			.Visible = False
		End With
		' chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
		With chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
			.Name = "chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning"
			.Text = ("Create static event handlers with an underscore at the beginning")
			.TabIndex = 197

			.SetBounds 32, 195, 380, 24
			.Parent = @pnlDesigner
			.Visible = False
		End With
		' txtHistoryCodeDays
		With txtHistoryCodeDays
			.Name = "txtHistoryCodeDays"
			.Text = "3"
			.TabIndex = 198
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 20
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 2
			.SetBounds 198, 0, 72, 18
			.Designer = @This
			.Parent = @pnlHistoryFileSavingDays
		End With
		' pnlLine
		With pnlLine
			.Name = "pnlLine"
			.Text = "Panel2"
			.TabIndex = 203
			.Align = DockStyle.alBottom
			.ExtraMargins.Right = 10
			.ExtraMargins.Left = 10
			.BackColor = 16777215
			.SetBounds 10, 413, 605, 2
			.Designer = @This
			.Parent = @This
		End With
		' pnlProjectsPath
		With pnlProjectsPath
			.Name = "pnlProjectsPath"
			.Text = "Panel1"
			.TabIndex = 204
			.Align = DockStyle.alTop
			.AutoSize = True
			.ControlIndex = 7
			.SetBounds 0, 363, 417, 20
			.Designer = @This
			.Parent = @vbxGeneral
		End With
		' pnlSelectShortcut
		With pnlSelectShortcut
			.Name = "pnlSelectShortcut"
			.Text = "Panel1"
			.TabIndex = 205
			.Align = DockStyle.alBottom
			.AutoSize = True
			.SetBounds 15, 365, 387, 20
			.Designer = @This
			.Parent = @grbShortcuts
		End With
		' pnlChangeKeywordsCase
	With pnlChangeKeywordsCase
		.Name = "pnlChangeKeywordsCase"
		.Text = "Panel1"
		.TabIndex = 206
		.Align = DockStyle.alTop
		.AutoSize = True
		.SetBounds 0, 233, 417, 23
		.Designer = @This
		.Parent = @grbIntelliSense
	End With
		' lblHistoryDay
		With lblHistoryDay
			.Name = "lblHistoryDay"
			.Text = ("History file saving days") & ":"
			.TabIndex = 199
			.ExtraMargins.Top = 2
			.ExtraMargins.Right = 0
			.ExtraMargins.Left = 40
			.Align = DockStyle.alClient
			.ControlIndex = 0

			.SetBounds 40, 2, 175, 18
			.Designer = @This
			.Parent = @pnlHistoryFileSavingDays
		End With
		' pnlChangeEndingType
	With pnlChangeEndingType
		.Name = "pnlChangeEndingType"
		.Text = "Panel1"
		.AutoSize = True
		.TabIndex = 266
		.Align = DockStyle.alTop
		.ControlIndex = 17
		.SetBounds 0, 361, 250, 21
		.Designer = @This
		.Parent = @grbCompletion
	End With
		' pnlTreatTabAsSpaces
	With pnlTreatTabAsSpaces
		.Name = "pnlTreatTabAsSpaces"
		.Text = "Panel1"
		.AutoSize = True
		.TabIndex = 207
		.Align = DockStyle.alTop
		.AutoSize = True
		.SetBounds 0, 256, 417, 23
		.Designer = @This
		.Parent = @grbHistory
	End With
		' pnlTabSize
	With pnlTabSize
		.Name = "pnlTabSize"
		.Text = "Panel1"
		.AutoSize = True
		.TabIndex = 208
		.Align = DockStyle.alTop
		.AutoSize = True
		.SetBounds 0, 279, 417, 20
		.Designer = @This
		.Parent = @grbHistory
	End With
		' pnlHistoryLimit
	With pnlHistoryLimit
		.Name = "pnlHistoryLimit"
		.Text = "Panel1"
		.AutoSize = True
		.TabIndex = 211
		.Align = DockStyle.alTop
		.AutoSize = True
		.SetBounds 0, 299, 417, 20
		.Designer = @This
		.Parent = @grbHistory
	End With
		' pnlIntellisenseLimit
	With pnlIntellisenseLimit
		.Name = "pnlIntellisenseLimit"
		.Text = "Panel1"
		.AutoSize = True
		.TabIndex = 215
		.Align = DockStyle.alTop
		.AutoSize = True
		.SetBounds 0, 319, 417, 20
		.Designer = @This
		.Parent = @grbHistory
	End With
		' pnlHistoryFileSavingDays
	With pnlHistoryFileSavingDays
		.Name = "pnlHistoryFileSavingDays"
		.Text = "Panel1"
		.AutoSize = True
		.TabIndex = 218
		.Align = DockStyle.alTop
		.AutoSize = True
		.SetBounds 0, 339, 417, 20
		.Designer = @This
		.Parent = @grbHistory
	End With
		lvShortcuts.Columns.Add ("Action"), , 250
		lvShortcuts.Columns.Add ("Shortcut"), , 100
		lvOtherEditors.Columns.Add ("Version"), , 126
		lvOtherEditors.Columns.Add ("Extensions"), , 126
		lvOtherEditors.Columns.Add ("Path"), , 126
		lvOtherEditors.Columns.Add ("Command line"), , 80
		lvTerminalPaths.Columns.Add ("Version"), , 190
		lvTerminalPaths.Columns.Add ("Path"), , 190
		lvTerminalPaths.Columns.Add ("Command line"), , 80
		lvHelpPaths.Columns.Add ("Version"), , 190
		lvHelpPaths.Columns.Add ("Path"), , 190
		' hbxEditors
		With hbxEditors
			.Name = "hbxEditors"
			.Text = "HorizontalBox1"
			.TabIndex = 209
			.Align = DockStyle.alBottom
			.SetBounds 15, 361, 387, 24
			.Designer = @This
			.Parent = @grbOtherEditors
		End With
		' hbxHelp
		With hbxHelp
			.Name = "hbxHelp"
			.Text = "HorizontalBox1"
			.TabIndex = 212
			.Align = DockStyle.alBottom
			.SetBounds 15, 295, 387, 24
			.Designer = @This
			.Parent = @grbHelpPaths
		End With
		' hbxTerminal
		With hbxTerminal
			.Name = "hbxTerminal"
			.Text = "HorizontalBox1"
			.TabIndex = 213
			.Align = DockStyle.alBottom
			.SetBounds 15, 193, 387, 24
			.Designer = @This
			.Parent = @grbTerminalPaths
		End With
		' hbxColors
		With hbxColors
			.Name = "hbxColors"
			.Text = "HorizontalBox1"
			.TabIndex = 217
			.Align = DockStyle.alClient
			.SetBounds 15, 21, 387, 313
			.Designer = @This
			.Parent = @grbColors
		End With
		' vbxTheme
		With vbxTheme
			.Name = "vbxTheme"
			.Text = "VerticalBox1"
			.TabIndex = 222
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 227, 313
			.Designer = @This
			.Parent = @hbxColors
		End With
		' vbxColors
		With vbxColors
			.Name = "vbxColors"
			.Text = "VerticalBox1"
			.TabIndex = 223
			.ControlIndex = 0
			.Align = DockStyle.alNone
			.SetBounds 0, 0, 154, 252
			.Designer = @This
			.Parent = @sccColors
		End With
		' sccColors
		With sccColors
			.Name = "sccColors"
			.Text = "ScrollControl1"
			.TabIndex = 220
			.Align = DockStyle.alRight
			.SetBounds 227, 0, 160, 313
			.Designer = @This
			.Parent = @hbxColors
		End With
		' pnlAutoSaveCharMax
	With pnlAutoSaveCharMax
		.Name = "pnlAutoSaveCharMax"
		.Text = "Panel1"
		.TabIndex = 230
		.Align = DockStyle.alTop
		.AutoSize = True
		.ControlIndex = 18
		.SetBounds 0, 337, 420, 20
		.Designer = @This
		.Parent = @grbHistory
	End With
		' lbAutoSaveCharMax
		With lbAutoSaveCharMax
			.Name = "lbAutoSaveCharMax"
			.Text = ("Autosave after entered chars") & ": "
			.ExtraMargins.Top = 2
			.ExtraMargins.Left = 40
			.ExtraMargins.Right = 0
			.Align = DockStyle.alClient
			.TabIndex = 231
			.SetBounds 40, 2, 175, 18
			.Parent = @pnlAutoSaveCharMax
		End With
		' txtAutoSaveCharMax
		With txtAutoSaveCharMax
			.Name = "txtAutoSaveCharMax"
			.ExtraMargins.Top = 0
			.ExtraMargins.Right = 20
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 2
			.TabIndex = 232
			.SetBounds 198, 0, 72, 18
			.Text = "100"
			.Parent = @pnlAutoSaveCharMax
		End With
		' chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
		With chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
			.Name = "chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt"
			.Text = ("Create event handlers without static event handler if event allows it")
			.TabIndex = 233
			.ControlIndex = 4
			.SetBounds 32, 219, 380, 24
			.Designer = @This
			.Parent = @pnlDesigner
			.Visible = False
		End With
			'.ExtraMargins.Top = 4
			'.ExtraMargins.Right = 10
			'.ExtraMargins.Bottom = 9
			'.Margins.Left = 10
		' pnlCodeEditorHoverTime
	With pnlCodeEditorHoverTime
		.Name = "pnlCodeEditorHoverTime"
		.Text = "Panel1"
		.AutoSize = True
		.TabIndex = 254
		.Align = DockStyle.alTop
		.ControlIndex = 18
		.SetBounds 0, 384, 72, 20
		.Designer = @This
		.Parent = @grbHistory
	End With
		' lblCodeEditorHoverTime
		With lblCodeEditorHoverTime
			.Name = "lblCodeEditorHoverTime"
			.Text = ("Hover time") & ":"
			.TabIndex = 255
			.Align = DockStyle.alClient
			.Caption = ("Hover time") & ":"
			.ExtraMargins.Left = 40
			.ExtraMargins.Top = 2
			.SetBounds 0, 0, 0, 20
			.Designer = @This
			.Parent = @pnlCodeEditorHoverTime
		End With
		' txtCodeEditorHoverTime
		With txtCodeEditorHoverTime
			.Name = "txtCodeEditorHoverTime"
			.TabIndex = 257
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 2
			.ExtraMargins.Right = 20
			.SetBounds 198, 0, 72, 18
			.Designer = @This
			.Parent = @pnlCodeEditorHoverTime
		End With
		' chkChangeEndingType
		With chkChangeEndingType
			.Name = "chkChangeEndingType"
			.Text = ("Auto-insert End blocks") & ":"
			.TabIndex = 267
			.Align = DockStyle.alLeft
			.AutoSize = True
			.Caption = ("Auto-insert End blocks") & ":"
			.Constraints.Height = 21
			.SetBounds 0, 0, 172, 15
			.Designer = @This
			.Parent = @pnlChangeEndingType
		End With
		' cboConstructions
		With cboConstructions
			.Name = "cboConstructions"
			.Text = "ComboBoxEdit2"
			.ExtraMargins.Right = 20
			.ExtraMargins.Top = 0
			.ExtraMargins.Left = 0
			.Align = DockStyle.alRight
			.ExtraMargins.Bottom = 2
			.TabIndex = 268
			.SetBounds 80, 0, 150, 21
			.Designer = @This
			.Parent = @pnlChangeEndingType
		End With
		' vbxIncludePaths
		With vbxIncludePaths
			.Name = "vbxIncludePaths"
			.Text = "VerticalBox1"
			.TabIndex = 281
			.ControlIndex = 1
			.Align = DockStyle.alRight
			.SetBounds 367, 0, 24, 44
			.Designer = @This
			.Parent = @hbxIncludePaths
		End With
		' hbxIncludePaths
		With hbxIncludePaths
			.Name = "hbxIncludePaths"
			.Text = "HorizontalBox1"
			.TabIndex = 286
			.Align = DockStyle.alClient
			.SetBounds 15, 66, 387, 121
			.Designer = @This
			.Parent = @grbIncludePaths
		End With
		' vbxLibraryPaths
		With vbxLibraryPaths
			.Name = "vbxLibraryPaths"
			.Text = "VerticalBox1"
			.TabIndex = 283
			.ControlIndex = 1
			.Align = DockStyle.alRight
			.SetBounds 25, 0, 24, 44
			.Designer = @This
			.Parent = @hbxLibraryPaths
		End With
		' hbxLibraryPaths
		With hbxLibraryPaths
			.Name = "hbxLibraryPaths"
			.Text = "HorizontalBox1"
			.TabIndex = 286
			.Align = DockStyle.alClient
			.SetBounds 15, 20, 383, 136
			.Designer = @This
			.Parent = @grbLibraryPaths
		End With
		' hbxInterfaceColors
		With hbxInterfaceColors
			.Name = "hbxInterfaceColors"
			.Text = "HorizontalBox1"
			.TabIndex = 285
			.Align = DockStyle.alClient
			.ControlIndex = 0
			.ExtraMargins.Top = 30
			.SetBounds 10, 215, 397, 175
			.Designer = @This
			.Parent = @grbThemes
		End With
		' vbxInterfaceTheme
		With vbxInterfaceTheme
			.Name = "vbxInterfaceTheme"
			.Text = "VerticalBox1"
			.TabIndex = 286
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 237, 209
			.Designer = @This
			.Parent = @hbxInterfaceColors
		End With
		' cboInterfaceTheme
		With cboInterfaceTheme
			.Name = "cboInterfaceTheme"
			.Text = "ComboBoxEdit2"
			.TabIndex = 287
			.Align = DockStyle.alTop
			.ExtraMargins.Right = 15
			.ExtraMargins.Bottom = 15
			.SetBounds 0, 0, 222, 21
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ComboBoxEdit), @cboInterfaceTheme_Change)
			.Parent = @vbxInterfaceTheme
		End With
		' lstInterfaceColorKeys
		With lstInterfaceColorKeys
			.Name = "lstInterfaceColorKeys"
			.Text = "ListControl1"
			.TabIndex = 288
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 15
			.SetBounds 0, 36, 222, 147
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ListControl), @lstInterfaceColorKeys_Change)
			.Parent = @vbxInterfaceTheme
		End With
		' sccInterfaceColors
		With sccInterfaceColors
			.Name = "sccInterfaceColors"
			.Text = "ScrollControl1"
			.TabIndex = 289
			.Align = DockStyle.alRight
			.SetBounds 227, 0, 160, 215
			.Designer = @This
			.Parent = @hbxInterfaceColors
		End With
		' vbxInterfaceColors
		With vbxInterfaceColors
			.Name = "vbxInterfaceColors"
			.Text = "VerticalBox1"
			.TabIndex = 290
			.SetBounds 0, 0, 160, 75
			.Designer = @This
			.Parent = @sccInterfaceColors
		End With
		' hbxInterfaceThemeCommands
		With hbxInterfaceThemeCommands
			.Name = "hbxInterfaceThemeCommands"
			.Text = "HorizontalBox1"
			.TabIndex = 291
			.Align = DockStyle.alTop
			.ExtraMargins.Bottom = 14
			.SetBounds 0, 0, 154, 23
			.Designer = @This
			.Parent = @vbxInterfaceColors
		End With
		' cmdInterfaceThemeAdd
		With cmdInterfaceThemeAdd
			.Name = "cmdInterfaceThemeAdd"
			.Text = ("&Add")
			.TabIndex = 292
			.Align = DockStyle.alClient
			.SetBounds 0, 0, 89, 23
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdInterfaceThemeAdd_Click)
			.Parent = @hbxInterfaceThemeCommands
		End With
		' cmdInterfaceThemeRemove
		With cmdInterfaceThemeRemove
			.Name = "cmdInterfaceThemeRemove"
			.Text = ("&Remove")
			.TabIndex = 293
			.Align = DockStyle.alRight
			.SetBounds 89, 0, 71, 23
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdInterfaceThemeRemove_Click)
			.Parent = @hbxInterfaceThemeCommands
		End With
		' lblInterfaceColor
		With lblInterfaceColor
			.Name = "lblInterfaceColor"
			.Text = ("Color") & ":"
			.TabIndex = 294
			.Align = DockStyle.alTop
			.Caption = ("Color") & ":"
			.SetBounds 0, 37, 154, 16
			.Designer = @This
			.Parent = @vbxInterfaceColors
		End With
		' hbxInterfaceColor
		With hbxInterfaceColor
			.Name = "hbxInterfaceColor"
			.Text = "HorizontalBox1"
			.TabIndex = 295
			.Align = DockStyle.alTop
			.SetBounds 0, 53, 154, 22
			.Designer = @This
			.Parent = @vbxInterfaceColors
		End With
		' chkInterfaceColor
		With chkInterfaceColor
			.Name = "chkInterfaceColor"
			.Text = ("Auto")
			.TabIndex = 296
			.Align = DockStyle.alRight
			.ExtraMargins.Left = 5
			.SetBounds 112, 0, 48, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox), @chkInterfaceColor_Click)
			.Parent = @hbxInterfaceColor
		End With
		' txtInterfaceColor
		With txtInterfaceColor
			.Name = "txtInterfaceColor"
			.TabIndex = 297
			.Align = DockStyle.alClient
			.BackColor = 0
			.SetBounds 0, 0, 77, 22
			.Designer = @This
			.Parent = @hbxInterfaceColor
		End With
		' cmdInterfaceColor
		With cmdInterfaceColor
			.Name = "cmdInterfaceColor"
			.Text = "..."
			.TabIndex = 298
			.Align = DockStyle.alRight
			.SetBounds 83, 0, 24, 22
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdInterfaceColor_Click)
			.Parent = @hbxInterfaceColor
		End With
		' Move interface settings to General; hide broken interface theme UI
		pnlInterfaceFont.Parent = @vbxGeneral
		pnlInterfaceFont.Align = DockStyle.alTop
		pnlInterfaceFont.ControlIndex = 0
		chkDisplayIcons.Parent = @vbxGeneral
		chkDisplayIcons.ControlIndex = 1
		chkShowMainToolbar.Parent = @vbxGeneral
		chkShowMainToolbar.ControlIndex = 2
		chkDarkMode.Parent = @vbxGeneral
		chkDarkMode.ControlIndex = 4
		' The rest of the "Themes" page (interface color/theme picker) is
		' still broken and stays orphaned - see PROJECT_STATUS.md.
		hbxInterfaceColors.Visible = False
		grbThemes.Visible = False
	End Constructor
	
	Private Sub frmOptions._txtColorIndicator_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		(*Cast(frmOptions Ptr, Sender.Designer)).txtColorIndicator_KeyPress(Sender, Key)
	End Sub
	
	Private Sub frmOptions._txtColorFrame_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		(*Cast(frmOptions Ptr, Sender.Designer)).txtColorFrame_KeyPress(Sender, Key)
	End Sub
	
	Private Sub frmOptions._txtColorBackground_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		(*Cast(frmOptions Ptr, Sender.Designer)).txtColorBackground_KeyPress(Sender, Key)
	End Sub
	
	Private Sub frmOptions._txtColorForeground_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		(*Cast(frmOptions Ptr, Sender.Designer)).txtColorForeground_KeyPress(Sender, Key)
	End Sub
	
	Private Sub frmOptions.chkCreateNonStaticEventHandlers_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		(*Cast(frmOptions Ptr, Sender.Designer)).chkCreateNonStaticEventHandlers_Click(Sender)
	End Sub
	
	Destructor frmOptions
		FDisposing = True
		WDeAllocate(InterfFontName)
		WDeAllocate(oldInterfFontName)
		WDeAllocate(EditFontName)
	End Destructor
	
'#End Region

Private Sub frmOptions.cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	cmdApply_Click(Designer, Sender)
	If fOptions.LastApplySucceeded Then fOptions.CloseForm
End Sub

Private Sub frmOptions.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	fOptions.cboTheme.ItemIndex = fOptions.cboTheme.IndexOf(*CurrentTheme)
	fOptions.cboTheme_Change(Designer, Sender)
	fOptions.CloseForm
End Sub

Sub AddColors(ByRef cs As ECColorScheme, Foreground As Boolean = True, Background As Boolean = True, Frame As Boolean = True, Indicator As Boolean = True, Bold As Boolean = True, Italic As Boolean = True, Underline As Boolean = True)
	With fOptions
		.Colors(.ColorsCount, 0) = IIf(Foreground, cs.ForegroundOption, -2)
		.Colors(.ColorsCount, 1) = IIf(Background, cs.BackgroundOption, -2)
		.Colors(.ColorsCount, 2) = IIf(Frame, cs.FrameOption, -2)
		.Colors(.ColorsCount, 3) = IIf(Indicator, cs.IndicatorOption, -2)
		.Colors(.ColorsCount, 4) = IIf(Bold, cs.Bold, -2)
		.Colors(.ColorsCount, 5) = IIf(Italic, cs.Italic, -2)
		.Colors(.ColorsCount, 6) = IIf(Underline, cs.Underline, -2)
		.ColorsCount += 1
	End With
End Sub

Sub SyncColorOption(ByRef cs As ECColorScheme, Foreground As Boolean = True, Background As Boolean = True, Frame As Boolean = True, Indicator As Boolean = True, Bold As Boolean = True, Italic As Boolean = True, Underline As Boolean = True)
	With fOptions
		.Colors(.ColorsCount, 0) = IIf(Foreground, cs.ForegroundOption, -2)
		.Colors(.ColorsCount, 1) = IIf(Background, cs.BackgroundOption, -2)
		.Colors(.ColorsCount, 2) = IIf(Frame, cs.FrameOption, -2)
		.Colors(.ColorsCount, 3) = IIf(Indicator, cs.IndicatorOption, -2)
		.Colors(.ColorsCount, 4) = IIf(Bold, cs.Bold, -2)
		.Colors(.ColorsCount, 5) = IIf(Italic, cs.Italic, -2)
		.Colors(.ColorsCount, 6) = IIf(Underline, cs.Underline, -2)
		.ColorsCount += 1
	End With
End Sub

Sub SyncOptionsColorsFromGlobals
	With fOptions
		.ColorsCount = 0
		SyncColorOption Bookmarks
		SyncColorOption Breakpoints
		SyncColorOption Comments, , , , False
		SyncColorOption CurrentBrackets, , , , False
		SyncColorOption CurrentLine, , , , False, False, False, False
		SyncColorOption CurrentWord, , , , False
		SyncColorOption ExecutionLine, , , , , False, False, False
		SyncColorOption FoldLines, , False, False, False, False, False, False
		SyncColorOption Identifiers, , , , False
		SyncColorOption ColorByRefParameters, , , , False
		SyncColorOption ColorByValParameters, , , , False
		SyncColorOption ColorCommonVariables, , , , False
		SyncColorOption ColorComps, , , , False
		SyncColorOption ColorConstants, , , , False
		SyncColorOption ColorDefines, , , , False
		SyncColorOption ColorFields, , , , False
		SyncColorOption ColorGlobalFunctions, , , , False
		SyncColorOption ColorEnumMembers, , , , False
		SyncColorOption ColorGlobalEnums, , , , False
		SyncColorOption ColorLineLabels, , , , False
		SyncColorOption ColorLocalVariables, , , , False
		SyncColorOption ColorMacros, , , , False
		SyncColorOption ColorGlobalNamespaces, , , , False
		SyncColorOption ColorProperties, , , , False
		SyncColorOption ColorSharedVariables, , , , False
		SyncColorOption ColorSubs, , , , False
		SyncColorOption ColorGlobalTypes, , , , False
		SyncColorOption IndicatorLines, , False, False, False, False, False, False
		For k As Integer = 0 To UBound(Keywords)
			SyncColorOption Keywords(k), , , , False
		Next
		SyncColorOption LineNumbers, , , False, False
		SyncColorOption NormalText, , , , False
		SyncColorOption Numbers, , , , False
		SyncColorOption RealNumbers, , , , False
		SyncColorOption ColorOperators, , , , False
		SyncColorOption Selection, , , , False, False, False, False
		SyncColorOption SpaceIdentifiers, , , , False, False, False, False
		SyncColorOption Strings, , , , False
	End With
End Sub

Sub frmOptions.LoadSettings()
	With fOptions
		.tvOptions.SelectedNode = .tvOptions.Nodes.Item(0)
		.TreeView1_SelChange *.tvOptions.Designer, .tvOptions, * (.tvOptions.Nodes.Item(0))
		.chkTabAsSpaces.Checked = TabAsSpaces
		.cboTabStyle.ItemIndex = ChoosedTabStyle
		.txtCodeEditorHoverTime.Text = Str(CodeEditorHoverTime)
		.cboIdentifiersCase.ItemIndex = ChoosedIdentifiersCase
		.cboCase.ItemIndex = ChoosedKeyWordsCase
		.cboConstructions.ItemIndex = ChoosedConstructions
		.chkSyntaxHighlightingIdentifiers.Checked = SyntaxHighlightingIdentifiers 
		.chkChangeIdentifiersCase.Checked = ChangeIdentifiersCase
		.chkChangeKeywordsCase.Checked = ChangeKeyWordsCase
		.chkChangeEndingType.Checked = ChangeEndingType
		.chkAddSpacesToOperators.Checked = AddSpacesToOperators
		.chkLimitDebug.Checked = LimitDebug
		.txtTabSize.Text = Str(TabWidth)
		.txtHistoryLimit.Text = Str(HistoryLimit)
		.txtIntellisenseLimit.Text = Str(IntellisenseLimit)
		.txtHistoryCodeDays.Text = Str(HistoryCodeDays)
		.txtAutoSaveCharMax.Text = Str(AutoSaveCharMax)
		.txtMFFpath.Text = *MFFPath
		.chkIncludeMFFPath.Checked = IncludeMFFPath
		.txtProjectsPath.Text = *ProjectsPath
		.chkEnableAutoComplete.Checked = AutoComplete
		.chkEnableAutoSuggestions.Checked = AutoSuggestions
		.chkAutoIndentation.Checked = AutoIndentation
		.chkAutoCreateRC.Checked = AutoCreateRC
		.chkAutoCreateBakFiles.Checked = AutoCreateBakFiles
		.chkAddRelativePathsToRecent.Checked = AddRelativePathsToRecent
		.chkCreateNonStaticEventHandlers.Checked = CreateNonStaticEventHandlers
		.chkPlaceStaticEventHandlersAfterTheConstructor.Checked = PlaceStaticEventHandlersAfterTheConstructor
		.chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning.Checked = CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
		.chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt.Checked = CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
		.chkCreateFormTypesWithoutTypeWord.Checked = CreateFormTypesWithoutTypeWord
		.chkCreateNonStaticEventHandlers_Click(.chkCreateNonStaticEventHandlers)
		.optMainFileFolder.Checked = OpenCommandPromptInMainFileFolder
		.optInFolder.Checked = Not OpenCommandPromptInMainFileFolder
		.txtInFolder.Text = *CommandPromptFolder
		Select Case AutoSaveBeforeCompiling
		Case 0: .optDoNotSave.Checked = True
		Case 1: .optSaveCurrentFile.Checked = True
		Case 2: .optSaveAllFiles.Checked = True
		Case 3: .optPromptToSave.Checked = True
		End Select
		.chkShowSpaces.Checked = ShowSpaces
		.chkShowKeywordsTooltip.Checked = ShowKeywordsToolTip
		.chkShowTooltipsAtTheTop.Checked = ShowTooltipsAtTheTop
		.chkShowSymbolsTooltipsOnMouseHover.Checked = GlobalSettings.ShowSymbolsTooltipsOnMouseHover
		.chkShowClassesExplorerOnOpenWindow.Checked = GlobalSettings.ShowClassesExplorerOnOpenWindow
		.chkShowHorizontalSeparatorLines.Checked = ShowHorizontalSeparatorLines
		.chkShowHolidayFrame.Checked = ShowHolidayFrame
		.chkUseDirect2D.Checked = UseDirect2D
		.chkHighlightBrackets.Checked = HighlightBrackets
		.chkHighlightCurrentLine.Checked = HighlightCurrentLine
		.chkHighlightCurrentWord.Checked = HighlightCurrentWord
		.txtGridSize.Text = Str(GridSize)
		.chkShowAlignmentGrid.Checked = ShowAlignmentGrid
		.chkSnapToGrid.Checked = SnapToGridOption
		.chkDisplayIcons.Checked = DisplayMenuIcons
		.chkShowMainToolbar.Checked = ShowMainToolBar
		'.chkShowToolBoxLocal.Checked = gLocalToolBox
		.chkDarkMode.Checked = DarkMode
		Dim As String f
		HotKeysChanged = False
		.cboTheme.Clear
		f = Dir(ExePath & "/Settings/Themes/*.ini")
		While f <> ""
			If ..Left(f, Len(f) - 4) <> "" Then .cboTheme.AddItem ..Left(f, Len(f) - 4)
			f = Dir()
		Wend
		.cboTheme.ItemIndex = .cboTheme.IndexOf(*CurrentTheme)
		LoadTheme
		.cboTerminal.Clear
		.lvTerminalPaths.ListItems.Clear
		.cboTerminal.AddItem ("(not selected)")
		For i As Integer = 0 To pTerminals->Count - 1
			.lvTerminalPaths.ListItems.Add pTerminals->Item(i)->Key
			.lvTerminalPaths.ListItems.Item(i)->Text(1) = pTerminals->Item(i)->Text
			.lvTerminalPaths.ListItems.Item(i)->Text(2) = Cast(ToolType Ptr, pTerminals->Item(i)->Object)->Parameters
			.cboTerminal.AddItem pTerminals->Item(i)->Key
		Next
		.cboTerminal.ItemIndex = Max(0, .cboTerminal.IndexOf(*DefaultTerminal))
		.lvOtherEditors.ListItems.Clear
		For i As Integer = 0 To pOtherEditors->Count - 1
			.lvOtherEditors.ListItems.Add pOtherEditors->Item(i)->Key
			.lvOtherEditors.ListItems.Item(i)->Text(1) = Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Extensions
			.lvOtherEditors.ListItems.Item(i)->Text(2) = pOtherEditors->Item(i)->Text
			.lvOtherEditors.ListItems.Item(i)->Text(3) = Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Parameters
		Next
		.cboHelp.Clear
		.lvHelpPaths.ListItems.Clear
		.cboHelp.AddItem ("(not selected)")
		For i As Integer = 0 To pHelps->Count - 1
			.lvHelpPaths.ListItems.Add pHelps->Item(i)->Key
			.lvHelpPaths.ListItems.Item(i)->Text(1) = pHelps->Item(i)->Text
			.cboHelp.AddItem pHelps->Item(i)->Key
		Next
		.cboHelp.ItemIndex = Max(0, .cboHelp.IndexOf(*DefaultHelp))
		.lblCompiler64Path.Text = "./" & BUNDLED_COMPILER_FOLDER & "/" & BUNDLED_COMPILER_EXE
		.lstIncludePaths.Clear
		For i As Integer = 0 To pIncludePaths->Count - 1
			.lstIncludePaths.AddItem pIncludePaths->Item(i)
		Next
		.lstLibraryPaths.Clear
		For i As Integer = 0 To pLibraryPaths->Count - 1
			.lstLibraryPaths.AddItem pLibraryPaths->Item(i)
		Next
		.ColorsCount = 0
		AddColors Bookmarks
		AddColors Breakpoints
		AddColors Comments, , , , False
		AddColors CurrentBrackets, , , , False
		AddColors CurrentLine, , , , False, False, False, False
		AddColors CurrentWord, , , , False
		AddColors ExecutionLine, , , , , False, False, False
		AddColors FoldLines, , False, False, False, False, False, False
		AddColors Identifiers, , , , False
		AddColors ColorByRefParameters, , , , False
		AddColors ColorByValParameters, , , , False
		AddColors ColorCommonVariables, , , , False
		AddColors ColorComps, , , , False
		AddColors ColorConstants, , , , False
		AddColors ColorDefines, , , , False
		AddColors ColorFields, , , , False
		AddColors ColorGlobalFunctions, , , , False
		AddColors ColorEnumMembers, , , , False
		AddColors ColorGlobalEnums, , , , False
		AddColors ColorLineLabels, , , , False
		AddColors ColorLocalVariables, , , , False
		AddColors ColorMacros, , , , False
		AddColors ColorGlobalNamespaces, , , , False
		AddColors ColorProperties, , , , False
		AddColors ColorSharedVariables, , , , False
		AddColors ColorSubs, , , , False
		AddColors ColorGlobalTypes, , , , False
		AddColors IndicatorLines, , False, False, False, False, False, False
		For k As Integer = 0 To UBound(Keywords)
				AddColors Keywords(k), , , , False
		Next
		
		AddColors LineNumbers, , , False, False
		AddColors NormalText, , , , False
		AddColors Numbers, , , , False
		AddColors RealNumbers, , , , False
		AddColors ColorOperators, , , , False
		AddColors Selection, , , , False, False, False, False
		AddColors SpaceIdentifiers, , , , False, False, False, False
		AddColors Strings, , , , False
		
		.lstColorKeys.ItemIndex = 0
		.lstColorKeys_Change(*.lstColorKeys.Designer, .lstColorKeys)
		WLet(.EditFontName, *EditorFontName)
		.EditFontSize = EditorFontSize
		.lblFont.Font.Name = *EditorFontName
		.lblFont.Caption = * (.EditFontName) & ", " & .EditFontSize & "pt"
		WLet(.InterfFontName, *InterfaceFontName)
		WLet(.oldInterfFontName, *InterfaceFontName)
		.InterfFontSize = InterfaceFontSize
		.oldInterfFontSize = InterfaceFontSize
		.oldDisplayMenuIcons = DisplayMenuIcons
		.lblInterfaceFont.Font.Name = *InterfaceFontName
		.lblInterfaceFont.Caption = * (.InterfFontName) & ", " & .InterfFontSize & "pt"
	End With
End Sub

Function Html2Text(ByRef inHtml As WString, ByRef StrMarkStart As WString = "", ByRef StrMarkEnd As WString = "") As String
	If Trim(inHtml) = "" Then Return ""
	Dim As  String ret
	Dim As String HtmlCodes(0 To ...) = { "nbsp", " ", "amp", "&", "quot", """", "lt", "<", "gt", ">" }
	Dim As Integer i = 1, j, k, p, q
	If Len(StrMarkStart) > 0 Then
		k = InStr(inHtml, StrMarkStart)
		If k < 1 Then k = 1
		j = InStr(inHtml, StrMarkEnd)
		If j < 1 Then j = Len(inHtml)
		ret = Trim(Mid(inHtml, k, j - k + 1))
	Else
		ret = Trim(inHtml)
	End If
	
	Do
		p = InStr(i, LCase(ret), "<script") 'remove <script
		If p > 0 Then
			q = InStr(p, LCase(ret), "</script>")
			If q > 0 Then
				ret = Left(ret, p - 1)  + Mid(ret, q + 9)
			Else
				ret = Left(ret, p - 1)
				Exit Do
			End If
		End If
		i = InStr(i, ret, "<")
		If i < 1 Then Exit Do
		k = InStr(i, ret, ">")
		If k > 0 Then
			If ( LCase(Mid(ret, i + 1, Len("br "))) = "br " ) OrElse ( LCase(Mid(ret, i + 1, Len("br>"))) = "br>" ) Then
				ret = Left(ret, i - 1) + Chr(13, 10) + Mid(ret, k + 1)
			Else
				ret = Left(ret, i - 1) + Mid(ret, k + 1)
			End If
		Else
			Exit Do
		End If
	Loop
	
	i = 1
	Do
		i = InStr(i, ret, "&")
		If i < 1 Then Exit Do
		If ( Asc( ret , i + 1 ) = Asc( "#" ) ) Then
			Dim As Integer j = i + 2
			Dim As Integer c = 0
			Do
				Select Case Asc( ret, j )
				Case Asc("0") To Asc("9")
					If ( c <= 255 ) Then c = c * 10 + Asc( ret, j ) - Asc("0")
				Case Else
					Exit Do
				End Select
				j += 1
			Loop
			If ( c > 0 And c <= 255 ) Then
				If ( Mid( ret, j, 1) = ";" ) Then j += 1
				ret = Trim(Left(ret, i - 1)) + Chr(c) + Trim(Mid(ret, j))
			End If
		Else
			
			For q As Integer = 0 To UBound(HtmlCodes) Step 2
				If ( LCase(Mid( ret, i + 1, Len( HtmlCodes(q) ))) = HtmlCodes(q) ) Then
					j = i + Len( HtmlCodes(q) ) + 1
					If ( Mid( ret, j, 1) = ";" ) Then j += 1
					ret = Left(ret, i - 1) + HtmlCodes(q + 1) + Mid(ret, j)
					i += Len( HtmlCodes(q + 1) ) - 1
					Exit For
				End If
			Next
		End If
		i += 1
	Loop
	Return ret
End Function

Sub AddShortcuts(item As MenuItem Ptr, ByRef Prefix As WString = "")
	With fOptions
		If StartsWith(item->Name, "Recent") OrElse item->Caption = "-" Then Exit Sub
		Dim As UString itemCaption = Replace(IIf(Len(Prefix) = 0, WStr(""), Prefix & WStr(" -> ")) & item->Caption, "&", "")
		Dim As UString itemHotKey
		Dim As Integer Pos1 = InStr(itemCaption, !"\t")
		If Pos1 > 0 Then
			itemHotKey = Mid(itemCaption, Pos1 + 1)
			itemCaption = Left(itemCaption, Pos1 - 1)
		End If
		If item->Count = 0 Then
			.HotKeysPriv.Add item->Name
			.lvShortcuts.ListItems.Add itemCaption
			.lvShortcuts.ListItems.Item(.lvShortcuts.ListItems.Count - 1)->Text(1) = itemHotKey
			.lvShortcuts.ListItems.Item(.lvShortcuts.ListItems.Count - 1)->Tag = item
		Else
			For i As Integer = 0 To item->Count - 1
				AddShortcuts item->Item(i), itemCaption
			Next
		End If
	End With
End Sub

Private Sub frmOptions.Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.tvOptions.Nodes.Clear
		Var tnGeneral = .tvOptions.Nodes.Add(("General"), "General")
		Var tnEditor = .tvOptions.Nodes.Add(("Code Editor"), "CodeEditor")
		Var tnCompiler = .tvOptions.Nodes.Add(("Compiler"), "Compiler")
		Var tnDebugger = .tvOptions.Nodes.Add(("Debugger"), "Debugger")
		.tvOptions.Nodes.Add(("Designer"), "Designer")
		tnGeneral->Nodes.Add(("Shortcuts"), "Shortcuts")
		tnEditor->Nodes.Add(("Colors And Fonts"), "ColorsAndFonts")
		tnEditor->Nodes.Add(("Other Editors"), "OtherEditors")
		tnDebugger->Nodes.Add(("Terminal"), "Terminal")
		Var tnHelp = .tvOptions.Nodes.Add(("Help"), "Help")
		.tvOptions.ExpandAll
		.cboCase.Clear
		.cboCase.AddItem ("Original Case")
		.cboCase.AddItem ("Lower Case")
		.cboCase.AddItem ("Upper Case")
		.cboIdentifiersCase.Clear
		.cboIdentifiersCase.AddItem ("Original Case")
		.cboIdentifiersCase.AddItem ("Capitalized Case")
		.cboIdentifiersCase.AddItem ("Lower Case")
		.cboIdentifiersCase.AddItem ("Upper Case")
		.cboConstructions.Clear
		.cboConstructions.AddItem ("All Constructions")
		.cboConstructions.AddItem ("Only Procedures")
		.cboTabStyle.Clear
		.cboTabStyle.AddItem ("Everywhere")
		.cboTabStyle.AddItem ("Only after the words")
		.lstColorKeys.Clear
		.lstColorKeys.AddItem ("Bookmarks")
		.lstColorKeys.AddItem ("Breakpoints")
		.lstColorKeys.AddItem ("Comments")
		.lstColorKeys.AddItem ("Current Brackets")
		.lstColorKeys.AddItem ("Current Line")
		.lstColorKeys.AddItem ("Current Word")
		.lstColorKeys.AddItem ("Executed Line")
		.lstColorKeys.AddItem ("Fold Lines")
		.lstColorKeys.AddItem ("Identifiers")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("ByRef Parameters")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("ByVal Parameters")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Common Variables")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Components")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Constants")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Defines")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Fields")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Functions")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Enum Members")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Enums")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Line Labels")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Local Variables")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Macros")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Namespaces")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Properties")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Shared Variables")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Subs")
		.lstColorKeys.AddItem ("Identifiers") & ": " & ("Types")
		.lstColorKeys.AddItem ("Indicator Lines")
		For k As Integer = 0 To KeywordLists.Count - 1
			.lstColorKeys.AddItem ("Keywords") & ": " & (KeywordLists.Item(k))
		Next k
		.lstColorKeys.AddItem ("Line Numbers")
		.lstColorKeys.AddItem ("Normal Text")
		.lstColorKeys.AddItem ("Numbers")
		.lstColorKeys.AddItem ("Real Numbers")
		.lstColorKeys.AddItem ("Operators")
		.lstColorKeys.AddItem ("Selection")
		.lstColorKeys.AddItem ("Space Identifiers")
		.lstColorKeys.AddItem ("Strings")
		ReDim .Colors(.lstColorKeys.Items.Count - 1, 7)
		.lstColorKeys.ItemIndex = 0
		For i As Integer = 0 To pfrmMain->Menu->Count - 1
			AddShortcuts(pfrmMain->Menu->Item(i))
		Next
		.LoadSettings
	End With
End Sub

Sub SetColor(ByRef cs As ECColorScheme)
	With fOptions
		cs.ForegroundOption = .Colors(.ColorsCount, 0)
		cs.BackgroundOption = .Colors(.ColorsCount, 1)
		cs.FrameOption = .Colors(.ColorsCount, 2)
		cs.IndicatorOption = .Colors(.ColorsCount, 3)
		cs.Bold = .Colors(.ColorsCount, 4)
		cs.Italic = .Colors(.ColorsCount, 5)
		cs.Underline = .Colors(.ColorsCount, 6)
		.ColorsCount += 1
	End With
End Sub

Sub SetColors
	With fOptions
		.ColorsCount = 0
		SetColor Bookmarks
		SetColor Breakpoints
		SetColor Comments
		SetColor CurrentBrackets
		SetColor CurrentLine
		SetColor CurrentWord
		SetColor ExecutionLine
		SetColor FoldLines
		SetColor Identifiers
		SetColor ColorByRefParameters
		SetColor ColorByValParameters
		SetColor ColorCommonVariables
		SetColor ColorComps
		SetColor ColorConstants
		SetColor ColorDefines
		SetColor ColorFields
		SetColor ColorGlobalFunctions
		SetColor ColorEnumMembers
		SetColor ColorGlobalEnums
		SetColor ColorLineLabels
		SetColor ColorLocalVariables
		SetColor ColorMacros
		SetColor ColorGlobalNamespaces
		SetColor ColorProperties
		SetColor ColorSharedVariables
		SetColor ColorSubs
		SetColor ColorGlobalTypes
		SetColor IndicatorLines
		For k As Integer = 0 To UBound(Keywords)
			SetColor Keywords(k)
		Next k
		SetColor LineNumbers
		SetColor NormalText
		SetColor Numbers
		SetColor RealNumbers
		SetColor ColorOperators
		SetColor Selection
		SetColor SpaceIdentifiers
		SetColor Strings
		SetAutoColors
	End With
End Sub

' Dirty-check helpers for cmdApply_Click: skip a WriteXxx call when the INI already
' holds the value being applied, so Apply only touches keys that actually changed.
' Factored out (rather than inlined at each of the ~300 call sites) because inlining
' the KeyExists+Read+compare logic per site previously ballooned cmdApply_Click into
' a single ~8000-line generated function that crashed the GCC backend at -O2.
Private Function IniValueChangedBool(ByVal Ini As IniFile Ptr, ByRef Section As WString, ByRef Key As WString, NewValue As Boolean) As Boolean
	Return (Ini->KeyExists(Section, Key) = -1) OrElse (Ini->ReadBool(Section, Key) <> NewValue)
End Function

Private Function IniValueChangedInt(ByVal Ini As IniFile Ptr, ByRef Section As WString, ByRef Key As WString, NewValue As Integer) As Boolean
	Return (Ini->KeyExists(Section, Key) = -1) OrElse (Ini->ReadInteger(Section, Key) <> NewValue)
End Function

Private Function IniValueChangedFloat(ByVal Ini As IniFile Ptr, ByRef Section As WString, ByRef Key As WString, NewValue As Double) As Boolean
	Return (Ini->KeyExists(Section, Key) = -1) OrElse (Ini->ReadFloat(Section, Key) <> NewValue)
End Function

Private Function IniValueChangedStr(ByVal Ini As IniFile Ptr, ByRef Section As WString, ByRef Key As WString, ByRef NewValue As WString) As Boolean
	Return (Ini->KeyExists(Section, Key) = -1) OrElse (Ini->ReadString(Section, Key) <> NewValue)
End Function

Private Sub frmOptions.cmdApply_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	On Error Goto ErrorHandler
	fOptions.LastApplySucceeded = True
	Dim As ToolType Ptr Tool
	Dim As UString tempStr
	With fOptions
		Dim As UString projectsPathInput = Trim(.txtProjectsPath.Text, Any !" \t" + Chr(10) + Chr(13))
		If projectsPathInput <> "" Then
			Dim As UString projectsDir = GetFullPathU(projectsPathInput)
			If Not FolderExistsU(projectsDir) Then
				If Not EnsureDirectoryExists(projectsPathInput) AndAlso Not FolderExistsU(projectsDir) Then
					MsgBox ("New Projects Directory Could Not Be Created")
					fOptions.LastApplySucceeded = False
					Exit Sub
				End If
			End If
		End If
		SetBundledCompilerPath()
		For i As Integer = 0 To pTerminals->Count - 1
			_Delete(Cast(ToolType Ptr, pTerminals->Item(i)->Object))
		Next
		pTerminals->Clear
		For i As Integer = 0 To .lvTerminalPaths.ListItems.Count - 1
			tempStr = .lvTerminalPaths.ListItems.Item(i)->Text(0)
			Tool = _New(ToolType)
			Tool->Name = tempStr
			Tool->Path = .lvTerminalPaths.ListItems.Item(i)->Text(1)
			Tool->Parameters = .lvTerminalPaths.ListItems.Item(i)->Text(2)
			pTerminals->Add tempStr, .lvTerminalPaths.ListItems.Item(i)->Text(1), Tool
		Next
		If *DefaultTerminal <> IIf(.cboTerminal.ItemIndex = 0, "", .cboTerminal.Text) OrElse Not pTerminals->ContainsKey(*CurrentTerminal) Then
			WLet(DefaultTerminal, IIf(.cboTerminal.ItemIndex = 0, "", .cboTerminal.Text))
			WLet(CurrentTerminal, *DefaultTerminal)
		End If
		WLet(TerminalPath, pTerminals->Get(*CurrentTerminal))
		For i As Integer = 0 To pOtherEditors->Count - 1
			_Delete(Cast(ToolType Ptr, pOtherEditors->Item(i)->Object))
		Next
		pOtherEditors->Clear
		For i As Integer = 0 To .lvOtherEditors.ListItems.Count - 1
			tempStr = .lvOtherEditors.ListItems.Item(i)->Text(0)
			Tool = _New(ToolType)
			Tool->Name = tempStr
			Tool->Extensions = .lvOtherEditors.ListItems.Item(i)->Text(1)
			Tool->Path = .lvOtherEditors.ListItems.Item(i)->Text(2)
			Tool->Parameters = .lvOtherEditors.ListItems.Item(i)->Text(3)
			pOtherEditors->Add tempStr, .lvOtherEditors.ListItems.Item(i)->Text(2), Tool
		Next
		pHelps->Clear
		miHelps->Clear
		For i As Integer = 0 To .lvHelpPaths.ListItems.Count - 1
			tempStr = .lvHelpPaths.ListItems.Item(i)->Text(0)
			pHelps->Add tempStr, .lvHelpPaths.ListItems.Item(i)->Text(1)
			miHelps->Add(tempStr, .lvHelpPaths.ListItems.Item(i)->Text(1), , @mClickHelp)
		Next
		WLet(DefaultHelp, IIf(.cboHelp.ItemIndex = 0, "", .cboHelp.Text))
		WLet(HelpPath, pHelps->Get(*DefaultHelp))
		pIncludePaths->Clear
		For i As Integer = 0 To .lstIncludePaths.ItemCount - 1
			pIncludePaths->Add .lstIncludePaths.Item(i)
		Next
		pLibraryPaths->Clear
		For i As Integer = 0 To .lstLibraryPaths.ItemCount - 1
			pLibraryPaths->Add .lstLibraryPaths.Item(i)
		Next
		IncludeMFFPath = .chkIncludeMFFPath.Checked
		WLet(MFFPath, .txtMFFpath.Text)
		WLet(ProjectsPath, .txtProjectsPath.Text)
			WLet(MFFDll, *MFFPath & "/mff64.dll")
		TabWidth = Val(.txtTabSize.Text)
		HistoryLimit = Val(.txtHistoryLimit.Text)
		IntellisenseLimit = Val(.txtIntellisenseLimit.Text)
		If Val(.txtHistoryCodeDays.Text) < HistoryCodeDays Then
			HistoryCodeDays = Val(.txtHistoryCodeDays.Text)
			HistoryCodeClean(ExePath & "/Temp")
		Else
			HistoryCodeDays = Val(.txtHistoryCodeDays.Text)
		End If
		AutoSaveCharMax = Val(.txtAutoSaveCharMax.Text)
		LimitDebug = .chkLimitDebug.Checked
		DisplayWarningsInDebug = .chkDisplayWarningsInDebug.Checked
		AutoIndentation = .chkAutoIndentation.Checked
		AutoComplete = .chkEnableAutoComplete.Checked
		ChangeAutoComplete AutoComplete, 0
		AutoSuggestions = .chkEnableAutoSuggestions.Checked
		AutoCreateRC = .chkAutoCreateRC.Checked
		AutoCreateBakFiles = .chkAutoCreateBakFiles.Checked
		AddRelativePathsToRecent = .chkAddRelativePathsToRecent.Checked
		CreateNonStaticEventHandlers = .chkCreateNonStaticEventHandlers.Checked
		PlaceStaticEventHandlersAfterTheConstructor = .chkPlaceStaticEventHandlersAfterTheConstructor.Checked
		CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt = .chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt.Checked
		CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning = .chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning.Checked
		CreateFormTypesWithoutTypeWord = .chkCreateFormTypesWithoutTypeWord.Checked
		OpenCommandPromptInMainFileFolder = .optMainFileFolder.Checked
		WLet(CommandPromptFolder, .txtInFolder.Text)
		AutoSaveBeforeCompiling = IIf(.optSaveCurrentFile.Checked, 1, IIf(.optSaveAllFiles.Checked, 2, IIf(.optPromptToSave.Checked, 3, 0)))
		ShowSpaces = .chkShowSpaces.Checked
		ShowKeywordsToolTip = .chkShowKeywordsTooltip.Checked
		ShowTooltipsAtTheTop = .chkShowTooltipsAtTheTop.Checked
		GlobalSettings.ShowSymbolsTooltipsOnMouseHover = .chkShowSymbolsTooltipsOnMouseHover.Checked
		ChangeShowSymbolsTooltipsOnMouseHover GlobalSettings.ShowSymbolsTooltipsOnMouseHover, 0
		GlobalSettings.ShowClassesExplorerOnOpenWindow = .chkShowClassesExplorerOnOpenWindow.Checked
		ShowHorizontalSeparatorLines = .chkShowHorizontalSeparatorLines.Checked
		ShowHolidayFrame = .chkShowHolidayFrame.Checked
		UseDirect2D = .chkUseDirect2D.Checked
		HighlightBrackets = .chkHighlightBrackets.Checked
		HighlightCurrentLine = .chkHighlightCurrentLine.Checked
		HighlightCurrentWord = .chkHighlightCurrentWord.Checked
		TabAsSpaces = .chkTabAsSpaces.Checked
		ChoosedTabStyle = .cboTabStyle.ItemIndex
		CodeEditorHoverTime = Val(.txtCodeEditorHoverTime.Text)
		GridSize = Val(.txtGridSize.Text)
		ShowAlignmentGrid = .chkShowAlignmentGrid.Checked
		SnapToGridOption = .chkSnapToGrid.Checked
		SyntaxHighlightingIdentifiers = .chkSyntaxHighlightingIdentifiers.Checked
		ChangeIdentifiersCase = .chkChangeIdentifiersCase.Checked
		ChangeKeyWordsCase = .chkChangeKeywordsCase.Checked
		ChangeEndingType = .chkChangeEndingType.Checked
		ChoosedIdentifiersCase = .cboIdentifiersCase.ItemIndex
		ChoosedKeyWordsCase = .cboCase.ItemIndex
		ChoosedConstructions = .cboConstructions.ItemIndex
		AddSpacesToOperators = .chkAddSpacesToOperators.Checked
		WLet(CurrentTheme, .cboTheme.Text)
		WLet(EditorFontName, * (.EditFontName))
		EditorFontSize = .EditFontSize
		WLet(InterfaceFontName, * (.InterfFontName))
		InterfaceFontSize = .InterfFontSize
		DisplayMenuIcons = .chkDisplayIcons.Checked
		ShowMainToolBar = .chkShowMainToolbar.Checked
		'gLocalToolBox = .chkShowToolBoxLocal.Checked
		DarkMode = .chkDarkMode.Checked
		App.DarkMode = DarkMode
		SetColors
		UpdateAllTabWindows
		If .HotKeysChanged Then
			Dim As Integer Pos1, Fn = FreeFile_
			Dim As MenuItem Ptr Item
			Dim As String Key
			Open ExePath & "/Settings/Others/HotKeys.txt" For Output As #Fn
			For i As Integer = 0 To .lvShortcuts.ListItems.Count - 1
				If .HotKeysPriv.Item(i) = "" Then Continue For
				Item = .lvShortcuts.ListItems.Item(i)->Tag
				Pos1 = InStr(Item->Caption, !"\t")
				If Pos1 = 0 Then Pos1 = Len(Item->Caption) + 1
				Key = .lvShortcuts.ListItems.Item(i)->Text(1)
				Item->Caption = ..Left(Item->Caption, Pos1 - 1) & !"\t" & Key
				Print #Fn, .HotKeysPriv.Item(i) & "=" & Key
			Next
			CloseFile_(Fn)
			pfrmMain->Menu->ParentWindow = pfrmMain
		End If
		Dim i As Integer = 0
		Do Until piniSettings->KeyExists("Compilers", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "Compilers", "Version_" & WStr(i)
			piniSettings->KeyRemove "Compilers", "Path_" & WStr(i)
			piniSettings->KeyRemove "Compilers", "Command_" & WStr(i)
			i += 1
		Loop
		piniSettings->KeyRemove "Compilers", "DefaultCompiler64"
		If IniValueChangedStr(piniSettings, "Parameters", "Compiler64Arguments", *Compiler64Arguments) Then
			piniSettings->WriteString "Parameters", "Compiler64Arguments", *Compiler64Arguments
		End If
		If IniValueChangedStr(piniSettings, "MakeTools", "DefaultMakeTool", *DefaultMakeTool) Then
			piniSettings->WriteString "MakeTools", "DefaultMakeTool", *DefaultMakeTool
		End If
		For i As Integer = 0 To pMakeTools->Count - 1
			If IniValueChangedStr(piniSettings, "MakeTools", "Version_" & WStr(i), pMakeTools->Item(i)->Key) Then
				piniSettings->WriteString "MakeTools", "Version_" & WStr(i), pMakeTools->Item(i)->Key
			End If
			If IniValueChangedStr(piniSettings, "MakeTools", "Path_" & WStr(i), pMakeTools->Item(i)->Text) Then
				piniSettings->WriteString "MakeTools", "Path_" & WStr(i), pMakeTools->Item(i)->Text
			End If
			If IniValueChangedStr(piniSettings, "MakeTools", "Command_" & WStr(i), Cast(ToolType Ptr, pMakeTools->Item(i)->Object)->Parameters) Then
				piniSettings->WriteString "MakeTools", "Command_" & WStr(i), Cast(ToolType Ptr, pMakeTools->Item(i)->Object)->Parameters
			End If
		Next
		i = pMakeTools->Count
		Do Until piniSettings->KeyExists("MakeTools", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "MakeTools", "Version_" & WStr(i)
			piniSettings->KeyRemove "MakeTools", "Path_" & WStr(i)
			piniSettings->KeyRemove "MakeTools", "Command_" & WStr(i)
			i += 1
		Loop
		If IniValueChangedStr(piniSettings, "Terminals", "DefaultTerminal", *DefaultTerminal) Then
			piniSettings->WriteString "Terminals", "DefaultTerminal", *DefaultTerminal
		End If
		For i As Integer = 0 To pTerminals->Count - 1
			If IniValueChangedStr(piniSettings, "Terminals", "Version_" & WStr(i), pTerminals->Item(i)->Key) Then
				piniSettings->WriteString "Terminals", "Version_" & WStr(i), pTerminals->Item(i)->Key
			End If
			If IniValueChangedStr(piniSettings, "Terminals", "Path_" & WStr(i), pTerminals->Item(i)->Text) Then
				piniSettings->WriteString "Terminals", "Path_" & WStr(i), pTerminals->Item(i)->Text
			End If
			If IniValueChangedStr(piniSettings, "Terminals", "Command_" & WStr(i), Cast(ToolType Ptr, pTerminals->Item(i)->Object)->Parameters) Then
				piniSettings->WriteString "Terminals", "Command_" & WStr(i), Cast(ToolType Ptr, pTerminals->Item(i)->Object)->Parameters
			End If
		Next
		i = pTerminals->Count
		Do Until piniSettings->KeyExists("Terminals", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "Terminals", "Version_" & WStr(i)
			piniSettings->KeyRemove "Terminals", "Path_" & WStr(i)
			piniSettings->KeyRemove "Terminals", "Command_" & WStr(i)
			i += 1
		Loop
		For i As Integer = 0 To pOtherEditors->Count - 1
			If IniValueChangedStr(piniSettings, "OtherEditors", "Version_" & WStr(i), pOtherEditors->Item(i)->Key) Then
				piniSettings->WriteString "OtherEditors", "Version_" & WStr(i), pOtherEditors->Item(i)->Key
			End If
			If IniValueChangedStr(piniSettings, "OtherEditors", "Extensions_" & WStr(i), Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Extensions) Then
				piniSettings->WriteString "OtherEditors", "Extensions_" & WStr(i), Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Extensions
			End If
			If IniValueChangedStr(piniSettings, "OtherEditors", "Path_" & WStr(i), pOtherEditors->Item(i)->Text) Then
				piniSettings->WriteString "OtherEditors", "Path_" & WStr(i), pOtherEditors->Item(i)->Text
			End If
			If IniValueChangedStr(piniSettings, "OtherEditors", "Command_" & WStr(i), Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Parameters) Then
				piniSettings->WriteString "OtherEditors", "Command_" & WStr(i), Cast(ToolType Ptr, pOtherEditors->Item(i)->Object)->Parameters
			End If
		Next
		Do Until piniSettings->KeyExists("OtherEditors", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "OtherEditors", "Version_" & WStr(i)
			piniSettings->KeyRemove "OtherEditors", "Extensions_" & WStr(i)
			piniSettings->KeyRemove "OtherEditors", "Path_" & WStr(i)
			piniSettings->KeyRemove "OtherEditors", "Command_" & WStr(i)
			i += 1
		Loop
		If IniValueChangedStr(piniSettings, "Helps", "DefaultHelp", *DefaultHelp) Then
			piniSettings->WriteString "Helps", "DefaultHelp", *DefaultHelp
		End If
		For i As Integer = 0 To pHelps->Count - 1
			If IniValueChangedStr(piniSettings, "Helps", "Version_" & WStr(i), pHelps->Item(i)->Key) Then
				piniSettings->WriteString "Helps", "Version_" & WStr(i), pHelps->Item(i)->Key
			End If
			If IniValueChangedStr(piniSettings, "Helps", "Path_" & WStr(i), pHelps->Item(i)->Text) Then
				piniSettings->WriteString "Helps", "Path_" & WStr(i), pHelps->Item(i)->Text
			End If
		Next
		i = pHelps->Count
		Do Until piniSettings->KeyExists("Helps", "Version_" & WStr(i)) = -1
			piniSettings->KeyRemove "Helps", "Version_" & WStr(i)
			piniSettings->KeyRemove "Helps", "Path_" & WStr(i)
			i += 1
		Loop
		For i As Integer = 0 To pIncludePaths->Count - 1
			If IniValueChangedStr(piniSettings, "IncludePaths", "Path_" & WStr(i), pIncludePaths->Item(i)) Then
				piniSettings->WriteString "IncludePaths", "Path_" & WStr(i), pIncludePaths->Item(i)
			End If
		Next
		i = pIncludePaths->Count
		Do Until piniSettings->KeyExists("IncludePaths", "Path_" & WStr(i)) = -1
			piniSettings->KeyRemove "IncludePaths", "Path_" & WStr(i)
			i += 1
		Loop
		For i As Integer = 0 To pLibraryPaths->Count - 1
			If IniValueChangedStr(piniSettings, "LibraryPaths", "Path_" & WStr(i), pLibraryPaths->Item(i)) Then
				piniSettings->WriteString "LibraryPaths", "Path_" & WStr(i), pLibraryPaths->Item(i)
			End If
		Next
		i = pLibraryPaths->Count
		Do Until piniSettings->KeyExists("LibraryPaths", "Path_" & WStr(i)) = -1
			piniSettings->KeyRemove "LibraryPaths", "Path_" & WStr(i)
			i += 1
		Loop
		If IniValueChangedBool(piniSettings, "Options", "IncludeMFFPath", IncludeMFFPath) Then
			piniSettings->WriteBool "Options", "IncludeMFFPath", IncludeMFFPath
		End If
		If IniValueChangedStr(piniSettings, "Options", "MFFPath", *MFFPath) Then
			piniSettings->WriteString "Options", "MFFPath", *MFFPath
		End If
		If IniValueChangedStr(piniSettings, "Options", "ProjectsPath", *ProjectsPath) Then
			piniSettings->WriteString "Options", "ProjectsPath", *ProjectsPath
		End If
		If IniValueChangedInt(piniSettings, "Options", "TabWidth", TabWidth) Then
			piniSettings->WriteInteger "Options", "TabWidth", TabWidth
		End If
		If IniValueChangedInt(piniSettings, "Options", "HistoryLimit", HistoryLimit) Then
			piniSettings->WriteInteger "Options", "HistoryLimit", HistoryLimit
		End If
		If IniValueChangedInt(piniSettings, "Options", "IntellisenseLimit", IntellisenseLimit) Then
			piniSettings->WriteInteger "Options", "IntellisenseLimit", IntellisenseLimit
		End If
		If IniValueChangedInt(piniSettings, "Options", "HistoryCodeDays", HistoryCodeDays) Then
			piniSettings->WriteInteger "Options", "HistoryCodeDays", HistoryCodeDays
		End If
		If IniValueChangedInt(piniSettings, "Options", "AutoSaveCharMax", AutoSaveCharMax) Then
			piniSettings->WriteInteger "Options", "AutoSaveCharMax", AutoSaveCharMax
		End If
		If IniValueChangedInt(piniSettings, "Options", "HistoryCodeCleanDay", HistoryCodeCleanDay) Then
			piniSettings->WriteInteger "Options", "HistoryCodeCleanDay", HistoryCodeCleanDay
		End If
		If IniValueChangedBool(piniSettings, "Options", "UseMakeOnStartWithCompile", UseMakeOnStartWithCompile) Then
			piniSettings->WriteBool "Options", "UseMakeOnStartWithCompile", UseMakeOnStartWithCompile
		End If
		If IniValueChangedBool(piniSettings, "Options", "LimitDebug", LimitDebug) Then
			piniSettings->WriteBool "Options", "LimitDebug", LimitDebug
		End If
		If IniValueChangedBool(piniSettings, "Options", "DisplayWarningsInDebug", DisplayWarningsInDebug) Then
			piniSettings->WriteBool "Options", "DisplayWarningsInDebug", DisplayWarningsInDebug
		End If
		If IniValueChangedBool(piniSettings, "Options", "TurnOnEnvironmentVariables", TurnOnEnvironmentVariables) Then
			piniSettings->WriteBool "Options", "TurnOnEnvironmentVariables", TurnOnEnvironmentVariables
		End If
		If IniValueChangedStr(piniSettings, "Options", "EnvironmentVariables", *EnvironmentVariables) Then
			piniSettings->WriteString "Options", "EnvironmentVariables", *EnvironmentVariables
		End If
		If IniValueChangedBool(piniSettings, "Options", "AutoIncrement", AutoIncrement) Then
			piniSettings->WriteBool "Options", "AutoIncrement", AutoIncrement
		End If
		If IniValueChangedBool(piniSettings, "Options", "AutoIndentation", AutoIndentation) Then
			piniSettings->WriteBool "Options", "AutoIndentation", AutoIndentation
		End If
		If IniValueChangedBool(piniSettings, "Options", "AutoComplete", AutoComplete) Then
			piniSettings->WriteBool "Options", "AutoComplete", AutoComplete
		End If
		If IniValueChangedBool(piniSettings, "Options", "AutoSuggestions", AutoSuggestions) Then
			piniSettings->WriteBool "Options", "AutoSuggestions", AutoSuggestions
		End If
		If IniValueChangedBool(piniSettings, "Options", "AutoCreateRC", AutoCreateRC) Then
			piniSettings->WriteBool "Options", "AutoCreateRC", AutoCreateRC
		End If
		If IniValueChangedBool(piniSettings, "Options", "AutoCreateBakFiles", AutoCreateBakFiles) Then
			piniSettings->WriteBool "Options", "AutoCreateBakFiles", AutoCreateBakFiles
		End If
		If IniValueChangedBool(piniSettings, "Options", "AddRelativePathsToRecent", AddRelativePathsToRecent) Then
			piniSettings->WriteBool "Options", "AddRelativePathsToRecent", AddRelativePathsToRecent
		End If
		If IniValueChangedStr(piniSettings, "Options", "DefaultProjectFile", WGet(DefaultProjectFile)) Then
			piniSettings->WriteString "Options", "DefaultProjectFile", WGet(DefaultProjectFile)
		End If
		If IniValueChangedInt(piniSettings, "Options", "AutoSaveBeforeCompiling", AutoSaveBeforeCompiling) Then
			piniSettings->WriteInteger "Options", "AutoSaveBeforeCompiling", AutoSaveBeforeCompiling
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowSpaces", ShowSpaces) Then
			piniSettings->WriteBool "Options", "ShowSpaces", ShowSpaces
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowKeywordsTooltip", ShowKeywordsToolTip) Then
			piniSettings->WriteBool "Options", "ShowKeywordsTooltip", ShowKeywordsToolTip
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowTooltipsAtTheTop", ShowTooltipsAtTheTop) Then
			piniSettings->WriteBool "Options", "ShowTooltipsAtTheTop", ShowTooltipsAtTheTop
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowSymbolsTooltipsOnMouseHover", GlobalSettings.ShowSymbolsTooltipsOnMouseHover) Then
			piniSettings->WriteBool "Options", "ShowSymbolsTooltipsOnMouseHover", GlobalSettings.ShowSymbolsTooltipsOnMouseHover
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowClassesExplorerOnOpenWindow", GlobalSettings.ShowClassesExplorerOnOpenWindow) Then
			piniSettings->WriteBool "Options", "ShowClassesExplorerOnOpenWindow", GlobalSettings.ShowClassesExplorerOnOpenWindow
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowHorizontalSeparatorLines", ShowHorizontalSeparatorLines) Then
			piniSettings->WriteBool "Options", "ShowHorizontalSeparatorLines", ShowHorizontalSeparatorLines
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowHolidayFrame", ShowHolidayFrame) Then
			piniSettings->WriteBool "Options", "ShowHolidayFrame", ShowHolidayFrame
		End If
		If IniValueChangedBool(piniSettings, "Options", "UseDirect2D", UseDirect2D) Then
			piniSettings->WriteBool "Options", "UseDirect2D", UseDirect2D
		End If
		If IniValueChangedBool(piniSettings, "Options", "HighlightBrackets", HighlightBrackets) Then
			piniSettings->WriteBool "Options", "HighlightBrackets", HighlightBrackets
		End If
		If IniValueChangedBool(piniSettings, "Options", "HighlightCurrentLine", HighlightCurrentLine) Then
			piniSettings->WriteBool "Options", "HighlightCurrentLine", HighlightCurrentLine
		End If
		If IniValueChangedBool(piniSettings, "Options", "HighlightCurrentWord", HighlightCurrentWord) Then
			piniSettings->WriteBool "Options", "HighlightCurrentWord", HighlightCurrentWord
		End If
		If IniValueChangedBool(piniSettings, "Options", "TabAsSpaces", TabAsSpaces) Then
			piniSettings->WriteBool "Options", "TabAsSpaces", TabAsSpaces
		End If
		If IniValueChangedInt(piniSettings, "Options", "CodeEditorHoverTime", CodeEditorHoverTime) Then
			piniSettings->WriteInteger "Options", "CodeEditorHoverTime", CodeEditorHoverTime
		End If
		If IniValueChangedInt(piniSettings, "Options", "GridSize", GridSize) Then
			piniSettings->WriteInteger "Options", "GridSize", GridSize
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowAlignmentGrid", ShowAlignmentGrid) Then
			piniSettings->WriteBool "Options", "ShowAlignmentGrid", ShowAlignmentGrid
		End If
		If IniValueChangedBool(piniSettings, "Options", "SnapToGrid", SnapToGridOption) Then
			piniSettings->WriteBool "Options", "SnapToGrid", SnapToGridOption
		End If
		If IniValueChangedBool(piniSettings, "Options", "CreateNonStaticEventHandlers", CreateNonStaticEventHandlers) Then
			piniSettings->WriteBool "Options", "CreateNonStaticEventHandlers", CreateNonStaticEventHandlers
		End If
		If IniValueChangedBool(piniSettings, "Options", "PlaceStaticEventHandlersAfterTheConstructor", PlaceStaticEventHandlersAfterTheConstructor) Then
			piniSettings->WriteBool "Options", "PlaceStaticEventHandlersAfterTheConstructor", PlaceStaticEventHandlersAfterTheConstructor
		End If
		If IniValueChangedBool(piniSettings, "Options", "CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning", CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning) Then
			piniSettings->WriteBool "Options", "CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning", CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning
		End If
		If IniValueChangedBool(piniSettings, "Options", "CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt", CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt) Then
			piniSettings->WriteBool "Options", "CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt", CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
		End If
		If IniValueChangedBool(piniSettings, "Options", "CreateFormTypesWithoutTypeWord", CreateFormTypesWithoutTypeWord) Then
			piniSettings->WriteBool "Options", "CreateFormTypesWithoutTypeWord", CreateFormTypesWithoutTypeWord
		End If
		If IniValueChangedBool(piniSettings, "Options", "OpenCommandPromptInMainFileFolder", OpenCommandPromptInMainFileFolder) Then
			piniSettings->WriteBool "Options", "OpenCommandPromptInMainFileFolder", OpenCommandPromptInMainFileFolder
		End If
		If IniValueChangedStr(piniSettings, "Options", "CommandPromptFolder", *CommandPromptFolder) Then
			piniSettings->WriteString "Options", "CommandPromptFolder", *CommandPromptFolder
		End If
		If IniValueChangedBool(piniSettings, "Options", "SyntaxHighlightingIdentifiers", SyntaxHighlightingIdentifiers) Then
			piniSettings->WriteBool "Options", "SyntaxHighlightingIdentifiers", SyntaxHighlightingIdentifiers
		End If
		If IniValueChangedBool(piniSettings, "Options", "ChangeIdentifiersCase", ChangeIdentifiersCase) Then
			piniSettings->WriteBool "Options", "ChangeIdentifiersCase", ChangeIdentifiersCase
		End If
		If IniValueChangedBool(piniSettings, "Options", "ChangeKeywordsCase", ChangeKeyWordsCase) Then
			piniSettings->WriteBool "Options", "ChangeKeywordsCase", ChangeKeyWordsCase
		End If
		If IniValueChangedBool(piniSettings, "Options", "ChangeEndingType", ChangeEndingType) Then
			piniSettings->WriteBool "Options", "ChangeEndingType", ChangeEndingType
		End If
		If IniValueChangedInt(piniSettings, "Options", "ChoosedIdentifiersCase", ChoosedIdentifiersCase) Then
			piniSettings->WriteInteger "Options", "ChoosedIdentifiersCase", ChoosedIdentifiersCase
		End If
		If IniValueChangedInt(piniSettings, "Options", "ChoosedKeywordsCase", ChoosedKeyWordsCase) Then
			piniSettings->WriteInteger "Options", "ChoosedKeywordsCase", ChoosedKeyWordsCase
		End If
		If IniValueChangedInt(piniSettings, "Options", "ChoosedConstructions", ChoosedConstructions) Then
			piniSettings->WriteInteger "Options", "ChoosedConstructions", ChoosedConstructions
		End If
		If IniValueChangedBool(piniSettings, "Options", "AddSpacesToOperators", AddSpacesToOperators) Then
			piniSettings->WriteBool "Options", "AddSpacesToOperators", AddSpacesToOperators
		End If
		
		If IniValueChangedStr(piniSettings, "Options", "CurrentTheme", *CurrentTheme) Then
			piniSettings->WriteString "Options", "CurrentTheme", *CurrentTheme
		End If
		
		If IniValueChangedStr(piniSettings, "Options", "EditorFontName", *EditorFontName) Then
			piniSettings->WriteString "Options", "EditorFontName", *EditorFontName
		End If
		If IniValueChangedInt(piniSettings, "Options", "EditorFontSize", EditorFontSize) Then
			piniSettings->WriteInteger "Options", "EditorFontSize", EditorFontSize
		End If
		If IniValueChangedStr(piniSettings, "Options", "InterfaceFontName", *InterfaceFontName) Then
			piniSettings->WriteString "Options", "InterfaceFontName", *InterfaceFontName
		End If
		If IniValueChangedInt(piniSettings, "Options", "InterfaceFontSize", InterfaceFontSize) Then
			piniSettings->WriteInteger "Options", "InterfaceFontSize", InterfaceFontSize
		End If
		
		If IniValueChangedBool(piniSettings, "Options", "DisplayMenuIcons", DisplayMenuIcons) Then
			piniSettings->WriteBool "Options", "DisplayMenuIcons", DisplayMenuIcons
		End If
		If IniValueChangedBool(piniSettings, "Options", "ShowMainToolbar", ShowMainToolBar) Then
			piniSettings->WriteBool "Options", "ShowMainToolbar", ShowMainToolBar
		End If
		If IniValueChangedBool(piniSettings, "Options", "DarkMode", DarkMode) Then
			piniSettings->WriteBool "Options", "DarkMode", DarkMode
		End If
		'piniSettings->WriteBool "Options", "ShowToolBoxLocal", gLocalToolBox
		' Not applied live: setting Menu->ImagesList immediately drops the icon lookup for the
		' whole menu, but already-rendered items keep their cached icon, leaving a half-applied
		' state (most icons gone, a few stuck) that contradicts the "next run" message below.
		' SettingsService.bas's startup path already sets this correctly from DisplayMenuIcons.
		MainReBar.Visible = ShowMainToolBar
		pfrmMain->RequestAlign
			txtLabelProperty.BackColor = clBtnFace
			txtLabelEvent.BackColor = clBtnFace
			fAddIns.txtDescription.BackColor = clBtnFace
		
		piniTheme->Load ExePath & "/Settings/Themes/" & *CurrentTheme & ".ini"
		If IniValueChangedInt(piniTheme, "Colors", "BookmarksForeground", Bookmarks.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "BookmarksForeground", Bookmarks.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "BookmarksBackground", Bookmarks.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "BookmarksBackground", Bookmarks.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "BookmarksFrame", Bookmarks.FrameOption) Then
			piniTheme->WriteInteger("Colors", "BookmarksFrame", Bookmarks.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "BookmarksIndicator", Bookmarks.IndicatorOption) Then
			piniTheme->WriteInteger("Colors", "BookmarksIndicator", Bookmarks.IndicatorOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "BookmarksBold", Bookmarks.Bold) Then
			piniTheme->WriteInteger("FontStyles", "BookmarksBold", Bookmarks.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "BookmarksItalic", Bookmarks.Italic) Then
			piniTheme->WriteInteger("FontStyles", "BookmarksItalic", Bookmarks.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "BookmarksUnderline", Bookmarks.Underline) Then
			piniTheme->WriteInteger("FontStyles", "BookmarksUnderline", Bookmarks.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "BreakpointsForeground", Breakpoints.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "BreakpointsForeground", Breakpoints.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "BreakpointsBackground", Breakpoints.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "BreakpointsBackground", Breakpoints.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "BreakpointsFrame", Breakpoints.FrameOption) Then
			piniTheme->WriteInteger("Colors", "BreakpointsFrame", Breakpoints.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "BreakpointsIndicator", Breakpoints.IndicatorOption) Then
			piniTheme->WriteInteger("Colors", "BreakpointsIndicator", Breakpoints.IndicatorOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "BreakpointsBold", Breakpoints.Bold) Then
			piniTheme->WriteInteger("FontStyles", "BreakpointsBold", Breakpoints.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "BreakpointsItalic", Breakpoints.Italic) Then
			piniTheme->WriteInteger("FontStyles", "BreakpointsItalic", Breakpoints.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "BreakpointsUnderline", Breakpoints.Underline) Then
			piniTheme->WriteInteger("FontStyles", "BreakpointsUnderline", Breakpoints.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CommentsForeground", Comments.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "CommentsForeground", Comments.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CommentsBackground", Comments.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "CommentsBackground", Comments.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CommentsFrame", Comments.FrameOption) Then
			piniTheme->WriteInteger("Colors", "CommentsFrame", Comments.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CommentsBold", Comments.Bold) Then
			piniTheme->WriteInteger("FontStyles", "CommentsBold", Comments.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CommentsItalic", Comments.Italic) Then
			piniTheme->WriteInteger("FontStyles", "CommentsItalic", Comments.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CommentsUnderline", Comments.Underline) Then
			piniTheme->WriteInteger("FontStyles", "CommentsUnderline", Comments.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentBracketsForeground", CurrentBrackets.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "CurrentBracketsForeground", CurrentBrackets.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentBracketsBackground", CurrentBrackets.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "CurrentBracketsBackground", CurrentBrackets.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentBracketsFrame", CurrentBrackets.FrameOption) Then
			piniTheme->WriteInteger("Colors", "CurrentBracketsFrame", CurrentBrackets.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CurrentBracketsBold", CurrentBrackets.Bold) Then
			piniTheme->WriteInteger("FontStyles", "CurrentBracketsBold", CurrentBrackets.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CurrentBracketsItalic", CurrentBrackets.Italic) Then
			piniTheme->WriteInteger("FontStyles", "CurrentBracketsItalic", CurrentBrackets.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CurrentBracketsUnderline", CurrentBrackets.Underline) Then
			piniTheme->WriteInteger("FontStyles", "CurrentBracketsUnderline", CurrentBrackets.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentLineForeground", CurrentLine.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "CurrentLineForeground", CurrentLine.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentLineBackground", CurrentLine.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "CurrentLineBackground", CurrentLine.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentLineFrame", CurrentLine.FrameOption) Then
			piniTheme->WriteInteger("Colors", "CurrentLineFrame", CurrentLine.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentWordForeground", CurrentWord.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "CurrentWordForeground", CurrentWord.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentWordBackground", CurrentWord.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "CurrentWordBackground", CurrentWord.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CurrentWordFrame", CurrentWord.FrameOption) Then
			piniTheme->WriteInteger("Colors", "CurrentWordFrame", CurrentWord.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CurrentWordBold", CurrentWord.Bold) Then
			piniTheme->WriteInteger("FontStyles", "CurrentWordBold", CurrentWord.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CurrentWordItalic", CurrentWord.Italic) Then
			piniTheme->WriteInteger("FontStyles", "CurrentWordItalic", CurrentWord.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CurrentWordUnderline", CurrentWord.Underline) Then
			piniTheme->WriteInteger("FontStyles", "CurrentWordUnderline", CurrentWord.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ExecutionLineForeground", ExecutionLine.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "ExecutionLineForeground", ExecutionLine.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ExecutionLineBackground", ExecutionLine.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "ExecutionLineBackground", ExecutionLine.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ExecutionLineFrame", ExecutionLine.FrameOption) Then
			piniTheme->WriteInteger("Colors", "ExecutionLineFrame", ExecutionLine.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ExecutionLineIndicator", ExecutionLine.IndicatorOption) Then
			piniTheme->WriteInteger("Colors", "ExecutionLineIndicator", ExecutionLine.IndicatorOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "FoldLinesForeground", FoldLines.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "FoldLinesForeground", FoldLines.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "IdentifiersForeground", Identifiers.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "IdentifiersForeground", Identifiers.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "IdentifiersBackground", Identifiers.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "IdentifiersBackground", Identifiers.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "IdentifiersFrame", Identifiers.FrameOption) Then
			piniTheme->WriteInteger("Colors", "IdentifiersFrame", Identifiers.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "IdentifiersBold", Identifiers.Bold) Then
			piniTheme->WriteInteger("FontStyles", "IdentifiersBold", Identifiers.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "IdentifiersItalic", Identifiers.Italic) Then
			piniTheme->WriteInteger("FontStyles", "IdentifiersItalic", Identifiers.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "IdentifiersUnderline", Identifiers.Underline) Then
			piniTheme->WriteInteger("FontStyles", "IdentifiersUnderline", Identifiers.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "ByRefParametersForeground", IIf(ColorByRefParameters.ForegroundOption = Identifiers.ForegroundOption, -1, ColorByRefParameters.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "ByRefParametersForeground", IIf(ColorByRefParameters.ForegroundOption = Identifiers.ForegroundOption, -1, ColorByRefParameters.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ByRefParametersBackground", IIf(ColorByRefParameters.BackgroundOption = Identifiers.BackgroundOption, -1, ColorByRefParameters.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "ByRefParametersBackground", IIf(ColorByRefParameters.BackgroundOption = Identifiers.BackgroundOption, -1, ColorByRefParameters.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ByRefParametersFrame", IIf(ColorByRefParameters.FrameOption = Identifiers.FrameOption, -1, ColorByRefParameters.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "ByRefParametersFrame", IIf(ColorByRefParameters.FrameOption = Identifiers.FrameOption, -1, ColorByRefParameters.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ByRefParametersBold", ColorByRefParameters.Bold) Then
			piniTheme->WriteInteger("FontStyles", "ByRefParametersBold", ColorByRefParameters.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ByRefParametersItalic", ColorByRefParameters.Italic) Then
			piniTheme->WriteInteger("FontStyles", "ByRefParametersItalic", ColorByRefParameters.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ByRefParametersUnderline", ColorByRefParameters.Underline) Then
			piniTheme->WriteInteger("FontStyles", "ByRefParametersUnderline", ColorByRefParameters.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "ByValParametersForeground", IIf(ColorByValParameters.ForegroundOption = Identifiers.ForegroundOption, -1, ColorByValParameters.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "ByValParametersForeground", IIf(ColorByValParameters.ForegroundOption = Identifiers.ForegroundOption, -1, ColorByValParameters.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ByValParametersBackground", IIf(ColorByValParameters.BackgroundOption = Identifiers.BackgroundOption, -1, ColorByValParameters.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "ByValParametersBackground", IIf(ColorByValParameters.BackgroundOption = Identifiers.BackgroundOption, -1, ColorByValParameters.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ByValParametersFrame", IIf(ColorByValParameters.FrameOption = Identifiers.FrameOption, -1, ColorByValParameters.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "ByValParametersFrame", IIf(ColorByValParameters.FrameOption = Identifiers.FrameOption, -1, ColorByValParameters.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ByValParametersBold", ColorByValParameters.Bold) Then
			piniTheme->WriteInteger("FontStyles", "ByValParametersBold", ColorByValParameters.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ByValParametersItalic", ColorByValParameters.Italic) Then
			piniTheme->WriteInteger("FontStyles", "ByValParametersItalic", ColorByValParameters.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ByValParametersUnderline", ColorByValParameters.Underline) Then
			piniTheme->WriteInteger("FontStyles", "ByValParametersUnderline", ColorByValParameters.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "CommonVariablesForeground", IIf(ColorCommonVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorCommonVariables.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "CommonVariablesForeground", IIf(ColorCommonVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorCommonVariables.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CommonVariablesBackground", IIf(ColorCommonVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorCommonVariables.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "CommonVariablesBackground", IIf(ColorCommonVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorCommonVariables.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "CommonVariablesFrame", IIf(ColorCommonVariables.FrameOption = Identifiers.FrameOption, -1, ColorCommonVariables.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "CommonVariablesFrame", IIf(ColorCommonVariables.FrameOption = Identifiers.FrameOption, -1, ColorCommonVariables.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CommonVariablesBold", ColorCommonVariables.Bold) Then
			piniTheme->WriteInteger("FontStyles", "CommonVariablesBold", ColorCommonVariables.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CommonVariablesItalic", ColorCommonVariables.Italic) Then
			piniTheme->WriteInteger("FontStyles", "CommonVariablesItalic", ColorCommonVariables.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "CommonVariablesUnderline", ColorCommonVariables.Underline) Then
			piniTheme->WriteInteger("FontStyles", "CommonVariablesUnderline", ColorCommonVariables.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "ComponentsForeground", IIf(ColorComps.ForegroundOption = Identifiers.ForegroundOption, -1, ColorComps.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "ComponentsForeground", IIf(ColorComps.ForegroundOption = Identifiers.ForegroundOption, -1, ColorComps.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ComponentsBackground", IIf(ColorComps.BackgroundOption = Identifiers.BackgroundOption, -1, ColorComps.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "ComponentsBackground", IIf(ColorComps.BackgroundOption = Identifiers.BackgroundOption, -1, ColorComps.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ComponentsFrame", IIf(ColorComps.FrameOption = Identifiers.FrameOption, -1, ColorComps.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "ComponentsFrame", IIf(ColorComps.FrameOption = Identifiers.FrameOption, -1, ColorComps.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ComponentsBold", ColorComps.Bold) Then
			piniTheme->WriteInteger("FontStyles", "ComponentsBold", ColorComps.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ComponentsItalic", ColorComps.Italic) Then
			piniTheme->WriteInteger("FontStyles", "ComponentsItalic", ColorComps.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ComponentsUnderline", ColorComps.Underline) Then
			piniTheme->WriteInteger("FontStyles", "ComponentsUnderline", ColorComps.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "ConstantsForeground", IIf(ColorConstants.ForegroundOption = Identifiers.ForegroundOption, -1, ColorConstants.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "ConstantsForeground", IIf(ColorConstants.ForegroundOption = Identifiers.ForegroundOption, -1, ColorConstants.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ConstantsBackground", IIf(ColorConstants.BackgroundOption = Identifiers.BackgroundOption, -1, ColorConstants.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "ConstantsBackground", IIf(ColorConstants.BackgroundOption = Identifiers.BackgroundOption, -1, ColorConstants.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "ConstantsFrame", IIf(ColorConstants.FrameOption = Identifiers.FrameOption, -1, ColorConstants.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "ConstantsFrame", IIf(ColorConstants.FrameOption = Identifiers.FrameOption, -1, ColorConstants.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ConstantsBold", ColorConstants.Bold) Then
			piniTheme->WriteInteger("FontStyles", "ConstantsBold", ColorConstants.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ConstantsItalic", ColorConstants.Italic) Then
			piniTheme->WriteInteger("FontStyles", "ConstantsItalic", ColorConstants.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "ConstantsUnderline", ColorConstants.Underline) Then
			piniTheme->WriteInteger("FontStyles", "ConstantsUnderline", ColorConstants.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "DefinesForeground", IIf(ColorDefines.ForegroundOption = Identifiers.ForegroundOption, -1, ColorDefines.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "DefinesForeground", IIf(ColorDefines.ForegroundOption = Identifiers.ForegroundOption, -1, ColorDefines.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "DefinesBackground", IIf(ColorDefines.BackgroundOption = Identifiers.BackgroundOption, -1, ColorDefines.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "DefinesBackground", IIf(ColorDefines.BackgroundOption = Identifiers.BackgroundOption, -1, ColorDefines.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "DefinesFrame", IIf(ColorDefines.FrameOption = Identifiers.FrameOption, -1, ColorDefines.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "DefinesFrame", IIf(ColorDefines.FrameOption = Identifiers.FrameOption, -1, ColorDefines.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "DefinesBold", ColorDefines.Bold) Then
			piniTheme->WriteInteger("FontStyles", "DefinesBold", ColorDefines.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "DefinesItalic", ColorDefines.Italic) Then
			piniTheme->WriteInteger("FontStyles", "DefinesItalic", ColorDefines.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "DefinesUnderline", ColorDefines.Underline) Then
			piniTheme->WriteInteger("FontStyles", "DefinesUnderline", ColorDefines.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "FieldsForeground", IIf(ColorFields.ForegroundOption = Identifiers.ForegroundOption, -1, ColorFields.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "FieldsForeground", IIf(ColorFields.ForegroundOption = Identifiers.ForegroundOption, -1, ColorFields.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "FieldsBackground", IIf(ColorFields.BackgroundOption = Identifiers.BackgroundOption, -1, ColorFields.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "FieldsBackground", IIf(ColorFields.BackgroundOption = Identifiers.BackgroundOption, -1, ColorFields.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "FieldsFrame", IIf(ColorFields.FrameOption = Identifiers.FrameOption, -1, ColorFields.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "FieldsFrame", IIf(ColorFields.FrameOption = Identifiers.FrameOption, -1, ColorFields.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "FieldsBold", ColorFields.Bold) Then
			piniTheme->WriteInteger("FontStyles", "FieldsBold", ColorFields.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "FieldsItalic", ColorFields.Italic) Then
			piniTheme->WriteInteger("FontStyles", "FieldsItalic", ColorFields.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "FieldsUnderline", ColorFields.Underline) Then
			piniTheme->WriteInteger("FontStyles", "FieldsUnderline", ColorFields.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "GlobalFunctionsForeground", IIf(ColorGlobalFunctions.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalFunctions.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalFunctionsForeground", IIf(ColorGlobalFunctions.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalFunctions.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "GlobalFunctionsBackground", IIf(ColorGlobalFunctions.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalFunctions.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalFunctionsBackground", IIf(ColorGlobalFunctions.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalFunctions.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "GlobalFunctionsFrame", IIf(ColorGlobalFunctions.FrameOption = Identifiers.FrameOption, -1, ColorGlobalFunctions.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalFunctionsFrame", IIf(ColorGlobalFunctions.FrameOption = Identifiers.FrameOption, -1, ColorGlobalFunctions.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalFunctionsBold", ColorGlobalFunctions.Bold) Then
			piniTheme->WriteInteger("FontStyles", "GlobalFunctionsBold", ColorGlobalFunctions.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalFunctionsItalic", ColorGlobalFunctions.Italic) Then
			piniTheme->WriteInteger("FontStyles", "GlobalFunctionsItalic", ColorGlobalFunctions.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalFunctionsUnderline", ColorGlobalFunctions.Underline) Then
			piniTheme->WriteInteger("FontStyles", "GlobalFunctionsUnderline", ColorGlobalFunctions.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "EnumMembersForeground", IIf(ColorEnumMembers.ForegroundOption = Identifiers.ForegroundOption, -1, ColorEnumMembers.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "EnumMembersForeground", IIf(ColorEnumMembers.ForegroundOption = Identifiers.ForegroundOption, -1, ColorEnumMembers.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "EnumMembersBackground", IIf(ColorEnumMembers.BackgroundOption = Identifiers.BackgroundOption, -1, ColorEnumMembers.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "EnumMembersBackground", IIf(ColorEnumMembers.BackgroundOption = Identifiers.BackgroundOption, -1, ColorEnumMembers.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "EnumMembersFrame", IIf(ColorEnumMembers.FrameOption = Identifiers.FrameOption, -1, ColorEnumMembers.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "EnumMembersFrame", IIf(ColorEnumMembers.FrameOption = Identifiers.FrameOption, -1, ColorEnumMembers.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "EnumMembersBold", ColorEnumMembers.Bold) Then
			piniTheme->WriteInteger("FontStyles", "EnumMembersBold", ColorEnumMembers.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "EnumMembersItalic", ColorEnumMembers.Italic) Then
			piniTheme->WriteInteger("FontStyles", "EnumMembersItalic", ColorEnumMembers.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "EnumMembersUnderline", ColorEnumMembers.Underline) Then
			piniTheme->WriteInteger("FontStyles", "EnumMembersUnderline", ColorEnumMembers.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "GlobalEnumsForeground", IIf(ColorGlobalEnums.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalEnums.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalEnumsForeground", IIf(ColorGlobalEnums.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalEnums.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "GlobalEnumsBackground", IIf(ColorGlobalEnums.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalEnums.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalEnumsBackground", IIf(ColorGlobalEnums.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalEnums.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "GlobalEnumsFrame", IIf(ColorGlobalEnums.FrameOption = Identifiers.FrameOption, -1, ColorGlobalEnums.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalEnumsFrame", IIf(ColorGlobalEnums.FrameOption = Identifiers.FrameOption, -1, ColorGlobalEnums.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalEnumsBold", ColorGlobalEnums.Bold) Then
			piniTheme->WriteInteger("FontStyles", "GlobalEnumsBold", ColorGlobalEnums.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalEnumsItalic", ColorGlobalEnums.Italic) Then
			piniTheme->WriteInteger("FontStyles", "GlobalEnumsItalic", ColorGlobalEnums.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalEnumsUnderline", ColorGlobalEnums.Underline) Then
			piniTheme->WriteInteger("FontStyles", "GlobalEnumsUnderline", ColorGlobalEnums.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "LineLabelsForeground", IIf(ColorLineLabels.ForegroundOption = Identifiers.ForegroundOption, -1, ColorLineLabels.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "LineLabelsForeground", IIf(ColorLineLabels.ForegroundOption = Identifiers.ForegroundOption, -1, ColorLineLabels.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "LineLabelsBackground", IIf(ColorLineLabels.BackgroundOption = Identifiers.BackgroundOption, -1, ColorLineLabels.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "LineLabelsBackground", IIf(ColorLineLabels.BackgroundOption = Identifiers.BackgroundOption, -1, ColorLineLabels.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "LineLabelsFrame", IIf(ColorLineLabels.FrameOption = Identifiers.FrameOption, -1, ColorLineLabels.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "LineLabelsFrame", IIf(ColorLineLabels.FrameOption = Identifiers.FrameOption, -1, ColorLineLabels.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LineLabelsBold", ColorLineLabels.Bold) Then
			piniTheme->WriteInteger("FontStyles", "LineLabelsBold", ColorLineLabels.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LineLabelsItalic", ColorLineLabels.Italic) Then
			piniTheme->WriteInteger("FontStyles", "LineLabelsItalic", ColorLineLabels.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LineLabelsUnderline", ColorLineLabels.Underline) Then
			piniTheme->WriteInteger("FontStyles", "LineLabelsUnderline", ColorLineLabels.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "LocalVariablesForeground", IIf(ColorLocalVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorLocalVariables.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "LocalVariablesForeground", IIf(ColorLocalVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorLocalVariables.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "LocalVariablesBackground", IIf(ColorLocalVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorLocalVariables.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "LocalVariablesBackground", IIf(ColorLocalVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorLocalVariables.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "LocalVariablesFrame", IIf(ColorLocalVariables.FrameOption = Identifiers.FrameOption, -1, ColorLocalVariables.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "LocalVariablesFrame", IIf(ColorLocalVariables.FrameOption = Identifiers.FrameOption, -1, ColorLocalVariables.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LocalVariablesBold", ColorLocalVariables.Bold) Then
			piniTheme->WriteInteger("FontStyles", "LocalVariablesBold", ColorLocalVariables.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LocalVariablesItalic", ColorLocalVariables.Italic) Then
			piniTheme->WriteInteger("FontStyles", "LocalVariablesItalic", ColorLocalVariables.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LocalVariablesUnderline", ColorLocalVariables.Underline) Then
			piniTheme->WriteInteger("FontStyles", "LocalVariablesUnderline", ColorLocalVariables.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "MacrosForeground", IIf(ColorMacros.ForegroundOption = Identifiers.ForegroundOption, -1, ColorMacros.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "MacrosForeground", IIf(ColorMacros.ForegroundOption = Identifiers.ForegroundOption, -1, ColorMacros.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "MacrosBackground", IIf(ColorMacros.BackgroundOption = Identifiers.BackgroundOption, -1, ColorMacros.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "MacrosBackground", IIf(ColorMacros.BackgroundOption = Identifiers.BackgroundOption, -1, ColorMacros.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "MacrosFrame", IIf(ColorMacros.FrameOption = Identifiers.FrameOption, -1, ColorMacros.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "MacrosFrame", IIf(ColorMacros.FrameOption = Identifiers.FrameOption, -1, ColorMacros.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "MacrosBold", ColorMacros.Bold) Then
			piniTheme->WriteInteger("FontStyles", "MacrosBold", ColorMacros.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "MacrosItalic", ColorMacros.Italic) Then
			piniTheme->WriteInteger("FontStyles", "MacrosItalic", ColorMacros.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "MacrosUnderline", ColorMacros.Underline) Then
			piniTheme->WriteInteger("FontStyles", "MacrosUnderline", ColorMacros.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "GlobalNamespacesForeground", IIf(ColorGlobalNamespaces.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalNamespaces.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalNamespacesForeground", IIf(ColorGlobalNamespaces.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalNamespaces.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "GlobalNamespacesBackground", IIf(ColorGlobalNamespaces.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalNamespaces.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalNamespacesBackground", IIf(ColorGlobalNamespaces.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalNamespaces.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "GlobalNamespacesFrame", IIf(ColorGlobalNamespaces.FrameOption = Identifiers.FrameOption, -1, ColorGlobalNamespaces.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalNamespacesFrame", IIf(ColorGlobalNamespaces.FrameOption = Identifiers.FrameOption, -1, ColorGlobalNamespaces.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalNamespacesBold", ColorGlobalNamespaces.Bold) Then
			piniTheme->WriteInteger("FontStyles", "GlobalNamespacesBold", ColorGlobalNamespaces.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalNamespacesItalic", ColorGlobalNamespaces.Italic) Then
			piniTheme->WriteInteger("FontStyles", "GlobalNamespacesItalic", ColorGlobalNamespaces.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalNamespacesUnderline", ColorGlobalNamespaces.Underline) Then
			piniTheme->WriteInteger("FontStyles", "GlobalNamespacesUnderline", ColorGlobalNamespaces.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "PropertiesForeground", IIf(ColorProperties.ForegroundOption = Identifiers.ForegroundOption, -1, ColorProperties.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "PropertiesForeground", IIf(ColorProperties.ForegroundOption = Identifiers.ForegroundOption, -1, ColorProperties.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "PropertiesBackground", IIf(ColorProperties.BackgroundOption = Identifiers.BackgroundOption, -1, ColorProperties.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "PropertiesBackground", IIf(ColorProperties.BackgroundOption = Identifiers.BackgroundOption, -1, ColorProperties.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "PropertiesFrame", IIf(ColorProperties.FrameOption = Identifiers.FrameOption, -1, ColorProperties.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "PropertiesFrame", IIf(ColorProperties.FrameOption = Identifiers.FrameOption, -1, ColorProperties.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "PropertiesBold", ColorProperties.Bold) Then
			piniTheme->WriteInteger("FontStyles", "PropertiesBold", ColorProperties.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "PropertiesItalic", ColorProperties.Italic) Then
			piniTheme->WriteInteger("FontStyles", "PropertiesItalic", ColorProperties.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "PropertiesUnderline", ColorProperties.Underline) Then
			piniTheme->WriteInteger("FontStyles", "PropertiesUnderline", ColorProperties.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "SharedVariablesForeground", IIf(ColorSharedVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorSharedVariables.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "SharedVariablesForeground", IIf(ColorSharedVariables.ForegroundOption = Identifiers.ForegroundOption, -1, ColorSharedVariables.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "SharedVariablesBackground", IIf(ColorSharedVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorSharedVariables.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "SharedVariablesBackground", IIf(ColorSharedVariables.BackgroundOption = Identifiers.BackgroundOption, -1, ColorSharedVariables.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "SharedVariablesFrame", IIf(ColorSharedVariables.FrameOption = Identifiers.FrameOption, -1, ColorSharedVariables.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "SharedVariablesFrame", IIf(ColorSharedVariables.FrameOption = Identifiers.FrameOption, -1, ColorSharedVariables.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "SharedVariablesBold", ColorSharedVariables.Bold) Then
			piniTheme->WriteInteger("FontStyles", "SharedVariablesBold", ColorSharedVariables.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "SharedVariablesItalic", ColorSharedVariables.Italic) Then
			piniTheme->WriteInteger("FontStyles", "SharedVariablesItalic", ColorSharedVariables.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "SharedVariablesUnderline", ColorSharedVariables.Underline) Then
			piniTheme->WriteInteger("FontStyles", "SharedVariablesUnderline", ColorSharedVariables.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "SubsForeground", IIf(ColorSubs.ForegroundOption = Identifiers.ForegroundOption, -1, ColorSubs.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "SubsForeground", IIf(ColorSubs.ForegroundOption = Identifiers.ForegroundOption, -1, ColorSubs.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "SubsBackground", IIf(ColorSubs.BackgroundOption = Identifiers.BackgroundOption, -1, ColorSubs.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "SubsBackground", IIf(ColorSubs.BackgroundOption = Identifiers.BackgroundOption, -1, ColorSubs.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "SubsFrame", IIf(ColorSubs.FrameOption = Identifiers.FrameOption, -1, ColorSubs.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "SubsFrame", IIf(ColorSubs.FrameOption = Identifiers.FrameOption, -1, ColorSubs.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "SubsBold", ColorSubs.Bold) Then
			piniTheme->WriteInteger("FontStyles", "SubsBold", ColorSubs.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "SubsItalic", ColorSubs.Italic) Then
			piniTheme->WriteInteger("FontStyles", "SubsItalic", ColorSubs.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "SubsUnderline", ColorSubs.Underline) Then
			piniTheme->WriteInteger("FontStyles", "SubsUnderline", ColorSubs.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "GlobalTypesForeground", IIf(ColorGlobalTypes.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalTypes.ForegroundOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalTypesForeground", IIf(ColorGlobalTypes.ForegroundOption = Identifiers.ForegroundOption, -1, ColorGlobalTypes.ForegroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "GlobalTypesBackground", IIf(ColorGlobalTypes.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalTypes.BackgroundOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalTypesBackground", IIf(ColorGlobalTypes.BackgroundOption = Identifiers.BackgroundOption, -1, ColorGlobalTypes.BackgroundOption), True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "GlobalTypesFrame", IIf(ColorGlobalTypes.FrameOption = Identifiers.FrameOption, -1, ColorGlobalTypes.FrameOption)) Then
			piniTheme->WriteInteger("Colors", "GlobalTypesFrame", IIf(ColorGlobalTypes.FrameOption = Identifiers.FrameOption, -1, ColorGlobalTypes.FrameOption), True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalTypesBold", ColorGlobalTypes.Bold) Then
			piniTheme->WriteInteger("FontStyles", "GlobalTypesBold", ColorGlobalTypes.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalTypesItalic", ColorGlobalTypes.Italic) Then
			piniTheme->WriteInteger("FontStyles", "GlobalTypesItalic", ColorGlobalTypes.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "GlobalTypesUnderline", ColorGlobalTypes.Underline) Then
			piniTheme->WriteInteger("FontStyles", "GlobalTypesUnderline", ColorGlobalTypes.Underline)
		End If
		
		If IniValueChangedInt(piniTheme, "Colors", "IndicatorLinesForeground", IndicatorLines.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "IndicatorLinesForeground", IndicatorLines.ForegroundOption, True)
		End If
		
		For k As Integer = 0 To UBound(Keywords)
			If IniValueChangedInt(piniTheme, "Colors", Replace(KeywordLists.Item(k), " ", "") & "Foreground", Keywords(k).ForegroundOption) Then
				piniTheme->WriteInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Foreground", Keywords(k).ForegroundOption, True)
			End If
			If IniValueChangedInt(piniTheme, "Colors", Replace(KeywordLists.Item(k), " ", "") & "Background", Keywords(k).BackgroundOption) Then
				piniTheme->WriteInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Background", Keywords(k).BackgroundOption, True)
			End If
			If IniValueChangedInt(piniTheme, "Colors", Replace(KeywordLists.Item(k), " ", "") & "Frame", Keywords(k).FrameOption) Then
				piniTheme->WriteInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Frame", Keywords(k).FrameOption, True)
			End If
			If IniValueChangedInt(piniTheme, "FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Bold", Keywords(k).Bold) Then
				piniTheme->WriteInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Bold", Keywords(k).Bold)
			End If
			If IniValueChangedInt(piniTheme, "FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Italic", Keywords(k).Italic) Then
				piniTheme->WriteInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Italic", Keywords(k).Italic)
			End If
			If IniValueChangedInt(piniTheme, "FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Underline", Keywords(k).Underline) Then
				piniTheme->WriteInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Underline", Keywords(k).Underline)
			End If
		Next k
		
		If IniValueChangedInt(piniTheme, "Colors", "LineNumbersForeground", LineNumbers.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "LineNumbersForeground", LineNumbers.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "LineNumbersBackground", LineNumbers.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "LineNumbersBackground", LineNumbers.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LineNumbersBold", LineNumbers.Bold) Then
			piniTheme->WriteInteger("FontStyles", "LineNumbersBold", LineNumbers.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LineNumbersItalic", LineNumbers.Italic) Then
			piniTheme->WriteInteger("FontStyles", "LineNumbersItalic", LineNumbers.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "LineNumbersUnderline", LineNumbers.Underline) Then
			piniTheme->WriteInteger("FontStyles", "LineNumbersUnderline", LineNumbers.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "NormalTextForeground", NormalText.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "NormalTextForeground", NormalText.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "NormalTextBackground", NormalText.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "NormalTextBackground", NormalText.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "NormalTextFrame", NormalText.FrameOption) Then
			piniTheme->WriteInteger("Colors", "NormalTextFrame", NormalText.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "NormalTextBold", NormalText.Bold) Then
			piniTheme->WriteInteger("FontStyles", "NormalTextBold", NormalText.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "NormalTextItalic", NormalText.Italic) Then
			piniTheme->WriteInteger("FontStyles", "NormalTextItalic", NormalText.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "NormalTextUnderline", NormalText.Underline) Then
			piniTheme->WriteInteger("FontStyles", "NormalTextUnderline", NormalText.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "NumbersForeground", Numbers.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "NumbersForeground", Numbers.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "NumbersBackground", Numbers.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "NumbersBackground", Numbers.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "NumbersFrame", Numbers.FrameOption) Then
			piniTheme->WriteInteger("Colors", "NumbersFrame", Numbers.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "NumbersBold", Numbers.Bold) Then
			piniTheme->WriteInteger("FontStyles", "NumbersBold", Numbers.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "NumbersItalic", Numbers.Italic) Then
			piniTheme->WriteInteger("FontStyles", "NumbersItalic", Numbers.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "NumbersUnderline", Numbers.Underline) Then
			piniTheme->WriteInteger("FontStyles", "NumbersUnderline", Numbers.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "OperatorsForeground", ColorOperators.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "OperatorsForeground", ColorOperators.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "OperatorsBackground", ColorOperators.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "OperatorsBackground", ColorOperators.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "OperatorsFrame", ColorOperators.FrameOption) Then
			piniTheme->WriteInteger("Colors", "OperatorsFrame", ColorOperators.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "OperatorsBold", ColorOperators.Bold) Then
			piniTheme->WriteInteger("FontStyles", "OperatorsBold", ColorOperators.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "OperatorsItalic", ColorOperators.Italic) Then
			piniTheme->WriteInteger("FontStyles", "OperatorsItalic", ColorOperators.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "OperatorsUnderline", ColorOperators.Underline) Then
			piniTheme->WriteInteger("FontStyles", "OperatorsUnderline", ColorOperators.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "RealNumbersForeground", RealNumbers.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "RealNumbersForeground", RealNumbers.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "RealNumbersBackground", RealNumbers.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "RealNumbersBackground", RealNumbers.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "RealNumbersFrame", RealNumbers.FrameOption) Then
			piniTheme->WriteInteger("Colors", "RealNumbersFrame", RealNumbers.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "RealNumbersBold", RealNumbers.Bold) Then
			piniTheme->WriteInteger("FontStyles", "RealNumbersBold", RealNumbers.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "RealNumbersItalic", RealNumbers.Italic) Then
			piniTheme->WriteInteger("FontStyles", "RealNumbersItalic", RealNumbers.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "RealNumbersUnderline", RealNumbers.Underline) Then
			piniTheme->WriteInteger("FontStyles", "RealNumbersUnderline", RealNumbers.Underline)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "SelectionForeground", Selection.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "SelectionForeground", Selection.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "SelectionBackground", Selection.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "SelectionBackground", Selection.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "SelectionFrame", Selection.FrameOption) Then
			piniTheme->WriteInteger("Colors", "SelectionFrame", Selection.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "SpaceIdentifiersForeground", SpaceIdentifiers.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "SpaceIdentifiersForeground", SpaceIdentifiers.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "StringsForeground", Strings.ForegroundOption) Then
			piniTheme->WriteInteger("Colors", "StringsForeground", Strings.ForegroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "StringsBackground", Strings.BackgroundOption) Then
			piniTheme->WriteInteger("Colors", "StringsBackground", Strings.BackgroundOption, True)
		End If
		If IniValueChangedInt(piniTheme, "Colors", "StringsFrame", Strings.FrameOption) Then
			piniTheme->WriteInteger("Colors", "StringsFrame", Strings.FrameOption, True)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "StringsBold", Strings.Bold) Then
			piniTheme->WriteInteger("FontStyles", "StringsBold", Strings.Bold)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "StringsItalic", Strings.Italic) Then
			piniTheme->WriteInteger("FontStyles", "StringsItalic", Strings.Italic)
		End If
		If IniValueChangedInt(piniTheme, "FontStyles", "StringsUnderline", Strings.Underline) Then
			piniTheme->WriteInteger("FontStyles", "StringsUnderline", Strings.Underline)
		End If
		
		LoadTheme
		SyncOptionsColorsFromGlobals
		UpdateAllTabWindows
		
		Dim As TabWindow Ptr tb
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
				tb->txtCode.Font.Name = *EditorFontName
				tb->txtCode.Font.Size = EditorFontSize
			Next
		Next
	End With
	Exit Sub
	ErrorHandler:
	fOptions.LastApplySucceeded = False
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
End Sub

Private Sub frmOptions.Form_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
	If *InterfaceFontName <> *fOptions.oldInterfFontName OrElse InterfaceFontSize <> fOptions.oldInterfFontSize Then MsgBox ("Interface font changes will be applied the next time the application is run.")
	If DisplayMenuIcons <> fOptions.oldDisplayMenuIcons Then MsgBox ("Display icons in the menu changes will be applied the next time the application is run.")
	'If DarkMode <> fOptions.oldDarkMode Then MsgBox ML("Dark Mode changes will be applied the next time the application is run.")
	'If fOptions.HotKeysChanged Then MsgBox ML("Hotkey changes will be applied the next time the application is run.")
End Sub

Private Sub frmOptions.TreeView1_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	With fOptions
		If .FDisposing Then Exit Sub
		Dim Key As String = Item.Name
		.pnlGeneral.Visible = Key = "General"
		.pnlCodeEditor.Visible = Key = "CodeEditor"
		.pnlShortcuts.Visible = Key = "Shortcuts"
		.pnlColorsAndFonts.Visible = Key = "ColorsAndFonts"
		.pnlOtherEditors.Visible = Key = "OtherEditors"
		.pnlCompiler.Visible = Key = "Compiler"
		.pnlDebugger.Visible = Key = "Debugger"
		.pnlTerminal.Visible = Key = "Terminal"
		.pnlDesigner.Visible = Key = "Designer"
		.pnlHelp.Visible = Key = "Help"
		If Key = "General" Then
			' The interface-settings controls relocated into vbxGeneral at
			' runtime (pnlInterfaceFont, chkDisplayIcons, chkShowMainToolbar,
			' chkDarkMode) can end up repositioned back to
			' their pre-relocation bounds by a native-window recreation that
			' happens when this page first becomes visible. Forcing one more
			' layout pass here, after that settles, guarantees the final
			' on-screen stacking is correct regardless of that timing.
			.vbxGeneral.RequestAlign
		End If
	End With
End Sub

Private Sub frmOptions.cmdMFFPath_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.BrowsD.InitialDir = GetFullPath(.txtMFFpath.Text)
		If .BrowsD.Execute Then
			.txtMFFpath.Text = MakePathPortable(.BrowsD.Directory)
		End If
	End With
End Sub

Private Sub frmOptions.cmdFont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.FontD.Font.Name = * (.EditFontName)
		.FontD.Font.Size = .EditFontSize
		If .FontD.Execute Then
			WLet(.EditFontName, .FontD.Font.Name)
			.EditFontSize = .FontD.Font.Size
			.lblFont.Font.Name = * (.EditFontName)
			.lblFont.Caption = * (.EditFontName) & ", " & .EditFontSize & "pt"
		End If
	End With
End Sub

Function LinearizeColorComponent(c As Double) As Double
    If c <= 0.03928 Then Return c / 12.92
	Return ((c + 0.055) / 1.055) ^ 2.4
End Function

Function GetLuminance(r As UByte, g As UByte, b As UByte) As Double
    Dim As Double fr = r / 255
    Dim As Double fg = g / 255
    Dim As Double fb = b / 255

    fr = LinearizeColorComponent(fr)
    fg = LinearizeColorComponent(fg)
    fb = LinearizeColorComponent(fb)

    Return 0.2126 * fr + 0.7152 * fg + 0.0722 * fb
End Function

Function GetReadableTextColor(bgColor As Integer) As ULong 'BGR format
	Dim As ULong bgColorNew = Max(0, bgColor)
	Dim As UByte b = (bgColorNew Shr 16) And &hFF
	Dim As UByte g = (bgColorNew Shr 8) And &hFF
	Dim As UByte r = bgColorNew And &hFF
	
	Dim As Double lum = GetLuminance(r, g, b)
	
	Dim As Double contrastWhite = (1.0 + 0.05) / (lum + 0.05)
	Dim As Double contrastBlack = (lum + 0.05) / (0.0 + 0.05)
	
	If contrastWhite > contrastBlack Then Return &hFFFFFF
	Return 0
End Function

Private Sub frmOptions.lstColorKeys_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		If UBound(.Colors, 1) < 0 Then Exit Sub
		Dim As Integer NormOrIdentifiers = IIf(i > 8 AndAlso i < 26, 8, 30 + UBound(Keywords))
		.txtColorForeground.BackColor = IIf(.Colors(i, 0) = -1, .Colors(NormOrIdentifiers, 0), .Colors(i, 0))
		.chkForeground.Checked = CBool(i <> NormOrIdentifiers) AndAlso CBool(.Colors(i, 0) = -1 OrElse .Colors(i, 0) = .Colors(NormOrIdentifiers, 0))
		.txtColorForeground.Text = "&H" & Hex(.txtColorForeground.BackColor, 6)
		.txtColorForeground.ForeColor = GetReadableTextColor(.txtColorForeground.BackColor)
		
		.txtColorBackground.BackColor = IIf(.Colors(i, 1) = -1, .Colors(NormOrIdentifiers, 1), .Colors(i, 1))
		.txtColorBackground.Visible = .Colors(i, 1) <> -2
		.txtColorBackground.Text = "&H" & Hex(.txtColorBackground.BackColor, 6)
		.txtColorBackground.ForeColor = GetReadableTextColor(.txtColorBackground.BackColor)
		.lblBackground.Visible = .Colors(i, 1) <> -2
		.cmdBackground.Visible = .Colors(i, 1) <> -2
		.chkBackground.Visible = .Colors(i, 1) <> -2
		.chkBackground.Checked = CBool(i <> NormOrIdentifiers) AndAlso CBool(.Colors(i, 1) = -1 OrElse .Colors(i, 1) = .Colors(NormOrIdentifiers, 1))
		
		.txtColorFrame.BackColor = IIf(.Colors(i, 2) = -1, .Colors(NormOrIdentifiers, 2), .Colors(i, 2))
		.txtColorFrame.Visible = .Colors(i, 2) <> -2
		.txtColorFrame.Text = "&H" & Hex(.txtColorFrame.BackColor, 6)
		.txtColorFrame.ForeColor = GetReadableTextColor(.txtColorFrame.BackColor)
		.lblFrame.Visible = .Colors(i, 2) <> -2
		.cmdFrame.Visible = .Colors(i, 2) <> -2
		.chkFrame.Visible = .Colors(i, 2) <> -2
		.chkFrame.Checked = CBool(i <> NormOrIdentifiers) AndAlso .Colors(i, 2) = (.Colors(i, 2) = -1 OrElse .Colors(i, 2) = .Colors(NormOrIdentifiers, 2))
		
		.txtColorIndicator.BackColor = IIf(.Colors(i, 3) = -1, .Colors(NormOrIdentifiers, 3), .Colors(i, 3))
		.txtColorIndicator.Visible = .Colors(i, 3) <> -2
		.txtColorIndicator.Text = "&H" & Hex(.txtColorIndicator.BackColor, 6)
		.txtColorIndicator.ForeColor = GetReadableTextColor(.txtColorIndicator.BackColor)
		.lblIndicator.Visible = .Colors(i, 3) <> -2
		.cmdIndicator.Visible = .Colors(i, 3) <> -2
		.chkIndicator.Visible = .Colors(i, 3) <> -2
		.chkIndicator.Checked = CBool(i <> 0) AndAlso .Colors(i, 3) = (.Colors(i, 3) = -1 OrElse .Colors(i, 3) = .Colors(0, 3))
		
		.chkBold.Visible = .Colors(i, 4) <> -2
		.chkBold.Checked = .Colors(i, 4)
		.chkItalic.Visible = .Colors(i, 4) <> -2
		.chkItalic.Checked = .Colors(i, 5)
		.chkUnderline.Visible = .Colors(i, 4) <> -2
		.chkUnderline.Checked = .Colors(i, 6)
	End With
End Sub

Private Sub frmOptions.cmdForeground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 0)
		If .Execute Then
			fOptions.txtColorForeground.BackColor = .Color
			fOptions.chkForeground.Checked = False
			fOptions.Colors(i, 0) = .Color
			fOptions.txtColorForeground.Text = "&H" & Hex(.Color, 6)
			fOptions.txtColorForeground.ForeColor = GetReadableTextColor(fOptions.txtColorForeground.BackColor)
		End If
	End With
End Sub

Private Sub frmOptions.cmdBackground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 1)
		If .Execute Then
			fOptions.txtColorBackground.BackColor = .Color
			fOptions.chkBackground.Checked = False
			fOptions.Colors(i, 1) = .Color
			fOptions.txtColorBackground.Text = "&H" & Hex(.Color, 6)
			fOptions.txtColorBackground.ForeColor = GetReadableTextColor(fOptions.txtColorBackground.BackColor)
		End If
	End With
End Sub

Private Sub frmOptions.cmdFrame_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 2)
		If .Execute Then
			fOptions.txtColorFrame.BackColor = .Color
			fOptions.chkFrame.Checked = False
			fOptions.Colors(i, 2) = .Color
			fOptions.txtColorFrame.Text = "&H" & Hex(.Color, 6)
			fOptions.txtColorFrame.ForeColor = GetReadableTextColor(fOptions.txtColorFrame.BackColor)
		End If
	End With
End Sub

Private Sub frmOptions.cmdIndicator_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions.ColorD
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = fOptions.Colors(i, 3)
		If .Execute Then
			fOptions.txtColorIndicator.BackColor = .Color
			fOptions.chkIndicator.Checked = False
			fOptions.Colors(i, 3) = .Color
			fOptions.txtColorIndicator.Text = "&H" & Hex(.Color, 6)
			fOptions.txtColorIndicator.ForeColor = GetReadableTextColor(fOptions.txtColorIndicator.BackColor)
		End If
	End With
End Sub

Private Sub frmOptions.cboTheme_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If UBound(.Colors) = -1 Then Exit Sub
		WLet(CurrentTheme, .cboTheme.Text)
		LoadTheme
		SyncOptionsColorsFromGlobals
		.lstColorKeys_Change(*.lstColorKeys.Designer, .lstColorKeys)
		UpdateAllTabWindows
	End With
End Sub

Private Sub frmOptions.chkForeground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 0) = IIf(.chkForeground.Checked, -1, .txtColorForeground.BackColor)
	End With
End Sub

Private Sub frmOptions.chkBackground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 1) = IIf(.chkBackground.Checked, -1, .txtColorBackground.BackColor)
	End With
End Sub

Private Sub frmOptions.chkFrame_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 2) = IIf(.chkFrame.Checked, -1, .txtColorFrame.BackColor)
	End With
End Sub

Private Sub frmOptions.chkIndicator_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 3) = IIf(.chkIndicator.Checked, -1, .txtColorIndicator.BackColor)
	End With
End Sub

Private Sub frmOptions.chkBold_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 4) = IIf(.chkBold.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.chkItalic_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 5) = IIf(.chkItalic.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.chkUnderline_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
	With fOptions
		Var i = .lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Colors(i, 6) = IIf(.chkUnderline.Checked, -1, 0)
	End With
End Sub

Private Sub frmOptions.cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If pfTheme->ShowModal(fOptions) = ModalResults.OK Then
		With fOptions
			.cboTheme.AddItem pfTheme->txtThemeName.Text
			.cboTheme.ItemIndex = .cboTheme.IndexOf(pfTheme->txtThemeName.Text)
			.cboTheme_Change(Designer, Sender)
		End With
	End If
End Sub

Private Sub frmOptions.cmdRemove_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		Kill ExePath & "/Settings/Themes/" & .cboTheme.Text & ".ini"
		.cboTheme.RemoveItem .cboTheme.ItemIndex
		.cboTheme.ItemIndex = 0
		.cboTheme_Change(Designer, Sender)
	End With
End Sub

Private Sub frmOptions.cmdAddTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	pfPath->txtVersion.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->txtCommandLine.Text = ""
	If pfPath->ShowModal(fOptions) = ModalResults.OK Then
		With fOptions
			If .cboTerminal.IndexOf(pfPath->txtVersion.Text) = -1 Then
				.lvTerminalPaths.ListItems.Add pfPath->txtVersion.Text
				.lvTerminalPaths.ListItems.Item(.lvTerminalPaths.ListItems.Count - 1)->Text(1) = pfPath->txtPath.Text
				.lvTerminalPaths.ListItems.Item(.lvTerminalPaths.ListItems.Count - 1)->Text(2) = pfPath->txtCommandLine.Text
				.cboTerminal.AddItem pfPath->txtVersion.Text
			Else
				MsgBox ("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If .lvTerminalPaths.SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .lvTerminalPaths.SelectedItem->Text(0)
		pfPath->txtPath.Text = .lvTerminalPaths.SelectedItem->Text(1)
		pfPath->txtCommandLine.Text = .lvTerminalPaths.SelectedItem->Text(2)
		If pfPath->ShowModal(fOptions) = ModalResults.OK Then
			If .lvTerminalPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .cboTerminal.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .cboTerminal.IndexOf(.lvTerminalPaths.SelectedItem->Text(0))
				.cboTerminal.Item(i) = pfPath->txtVersion.Text
				.lvTerminalPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.lvTerminalPaths.SelectedItem->Text(1) = pfPath->txtPath.Text
				.lvTerminalPaths.SelectedItem->Text(2) = pfPath->txtCommandLine.Text
			Else
				MsgBox ("This version is exists!")
			End If
		End If
	End With
End Sub

Private Sub frmOptions.cmdRemoveTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If .lvTerminalPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboTerminal.IndexOf(.lvTerminalPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboTerminal.RemoveItem iIndex
		If .cboTerminal.ItemIndex = -1 Then .cboTerminal.ItemIndex = 0
		.lvTerminalPaths.ListItems.Remove .lvTerminalPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearTerminals_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.lvTerminalPaths.ListItems.Clear
		.cboTerminal.Clear
		.cboTerminal.AddItem ("(not selected)")
		.cboTerminal.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdAddHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	pfPath->txtVersion.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->WithoutCommandLine = True
	If pfPath->ShowModal(fOptions) = ModalResults.OK Then
		With fOptions
			If .cboHelp.IndexOf(pfPath->txtVersion.Text) = -1 Then
				.lvHelpPaths.ListItems.Add pfPath->txtVersion.Text
				.lvHelpPaths.ListItems.Item(.lvHelpPaths.ListItems.Count - 1)->Text(1) = pfPath->txtPath.Text
				.cboHelp.AddItem pfPath->txtVersion.Text
			Else
				MsgBox ("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If .lvHelpPaths.SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .lvHelpPaths.SelectedItem->Text(0)
		pfPath->txtPath.Text = .lvHelpPaths.SelectedItem->Text(1)
		pfPath->WithoutCommandLine = True
		If pfPath->ShowModal(fOptions) = ModalResults.OK Then
			If .lvHelpPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .cboHelp.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .cboHelp.IndexOf(.lvHelpPaths.SelectedItem->Text(0))
				.cboHelp.Item(i) = pfPath->txtVersion.Text
				.lvHelpPaths.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.lvHelpPaths.SelectedItem->Text(1) = pfPath->txtPath.Text
			Else
				MsgBox ("This version is exists!")
			End If
		End If
	End With
End Sub

Private Sub frmOptions.cmdRemoveHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		If .lvHelpPaths.SelectedItem = 0 Then Exit Sub
		Var iIndex = .cboHelp.IndexOf(.lvHelpPaths.SelectedItem->Text(0))
		If iIndex > -1 Then .cboHelp.RemoveItem iIndex
		If .cboHelp.ItemIndex = -1 Then .cboHelp.ItemIndex = 0
		.lvHelpPaths.ListItems.Remove .lvHelpPaths.SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearHelps_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.lvHelpPaths.ListItems.Clear
		.cboHelp.Clear
		.cboHelp.AddItem ("(not selected)")
		.cboHelp.ItemIndex = 0
	End With
End Sub

Private Sub frmOptions.cmdInterfaceFont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.FontD.Font.Name = * (.InterfFontName)
		.FontD.Font.Size = .InterfFontSize
		If .FontD.Execute Then
			WLet(.InterfFontName, .FontD.Font.Name)
			.InterfFontSize = .FontD.Font.Size
			.lblInterfaceFont.Font.Name = * (.InterfFontName)
			.lblInterfaceFont.Caption = *(.InterfFontName) & ", " & .InterfFontSize & "pt"
		End If
	End With
End Sub

Private Sub frmOptions.cmdAddInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal(fOptions) = ModalResults.OK Then
		With fOptions
			If Not .lstIncludePaths.Items.Contains(pfPath->txtPath.Text) Then
					.lstIncludePaths.AddItem pfPath->txtPath.Text
			Else
				MsgBox ("This path is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdAddLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	pfPath->txtPath.Text = ""
	pfPath->ChooseFolder = True
	If pfPath->ShowModal(fOptions) = ModalResults.OK Then
		With fOptions
			If Not .lstLibraryPaths.Items.Contains(pfPath->txtPath.Text) Then
					.lstLibraryPaths.AddItem pfPath->txtPath.Text
			Else
				MsgBox ("This path is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdRemoveInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var Index = fOptions.lstIncludePaths.ItemIndex
	If Index <> -1 Then fOptions.lstIncludePaths.RemoveItem Index
End Sub

Private Sub frmOptions.cmdRemoveLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Var Index = fOptions.lstLibraryPaths.ItemIndex
	If Index <> -1 Then fOptions.lstLibraryPaths.RemoveItem Index
End Sub

Private Sub frmOptions.cmdProjectsPath_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		.BrowsD.InitialDir = GetFullPath(.txtProjectsPath.Text)
		If .BrowsD.Execute Then
			.txtProjectsPath.Text = MakePathPortable(.BrowsD.Directory)
		End If
	End With
End Sub

Private Sub frmOptions.lvShortcuts_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	With fOptions
		Var Index = .lvShortcuts.SelectedItemIndex
		If Index > -1 Then
			.hkShortcut.Text = .lvShortcuts.SelectedItem->Text(1)
		End If
	End With
End Sub

Private Sub frmOptions.cmdSetShortcut_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	With fOptions
		Var Index = .lvShortcuts.SelectedItemIndex
		If Index > -1 Then
			.lvShortcuts.SelectedItem->Text(1) = .hkShortcut.Text
			.HotKeysChanged = True
		End If
	End With
End Sub

Private Sub frmOptions.cmdAddEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdAddEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdAddEditor_Click(ByRef Sender As Control)
	pfPath->txtVersion.Text = ""
	pfPath->txtExtensions.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->txtCommandLine.Text = ""
	pfPath->WithExtensions = True
	If pfPath->ShowModal(*pfrmMain) = ModalResults.OK Then
		With lvOtherEditors.ListItems
			Var ItemsCount = .Count
			If .IndexOf(pfPath->txtVersion.Text) = -1 Then
				.Add pfPath->txtVersion.Text
				.Item(ItemsCount)->Text(1) = pfPath->txtExtensions.Text
				.Item(ItemsCount)->Text(2) = pfPath->txtPath.Text
				.Item(ItemsCount)->Text(3) = pfPath->txtCommandLine.Text
			Else
				MsgBox ("This version is exists!")
			End If
		End With
	End If
End Sub

Private Sub frmOptions.cmdChangeEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdChangeEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdChangeEditor_Click(ByRef Sender As Control)
	With lvOtherEditors
		If .SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .SelectedItem->Text(0)
		pfPath->txtExtensions.Text = .SelectedItem->Text(1)
		pfPath->txtPath.Text = .SelectedItem->Text(2)
		pfPath->txtCommandLine.Text = .SelectedItem->Text(3)
		pfPath->WithExtensions = True
		If pfPath->ShowModal(*pfrmMain) = ModalResults.OK Then
			If .SelectedItem->Text(0) = pfPath->txtVersion.Text OrElse .ListItems.IndexOf(pfPath->txtVersion.Text) = -1 Then
				Var i = .ListItems.IndexOf(.SelectedItem->Text(0))
				.SelectedItem->Text(0) = pfPath->txtVersion.Text
				.SelectedItem->Text(1) = pfPath->txtExtensions.Text
				.SelectedItem->Text(2) = pfPath->txtPath.Text
				.SelectedItem->Text(3) = pfPath->txtCommandLine.Text
			Else
				MsgBox ("This version is exists!")
			End If
		End If
	End With
End Sub

Private Sub frmOptions.cmdRemoveEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdRemoveEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdRemoveEditor_Click(ByRef Sender As Control)
	With lvOtherEditors
		If .SelectedItem = 0 Then Exit Sub
		.ListItems.Remove .SelectedItemIndex
	End With
End Sub

Private Sub frmOptions.cmdClearEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdClearEditor_Click(Sender)
End Sub
Private Sub frmOptions.cmdClearEditor_Click(ByRef Sender As Control)
	lvOtherEditors.ListItems.Clear
End Sub

Sub HistoryCodeClean(ByRef Path As WString)
	Dim As WString * 1024 f, f1
	Dim As Double d2
	Dim As UInteger Attr, NameCount
	If Trim(Path) = "" Then Exit Sub
	If FormClosing Then Exit Sub
	If EndsWith(Path, "\Windows") Then Exit Sub
	f = Dir(Path & WindowsSlash & "*.bak", fbArchive, Attr)
	While Len(Trim(f)) > 0
		If FormClosing Then Exit Sub
		f1 = Mid(f, Len(f) - 16)
		If Len(f1) > 16 Then
			d2 = DateValue(Mid(f1, 1, 4) & "/" & Mid(f1, 5, 2) & "/" & Mid(f1, 7, 2))
			If DateDiff( "d", d2, Now()) > HistoryCodeDays Then Kill Path & WindowsSlash & f
		End If
		f = Dir()
	Wend
	HistoryCodeCleanDay = DateValue(Format(Now, "yyyy/mm/dd"))
End Sub

Private Sub frmOptions.lvOtherEditors_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvOtherEditors_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvOtherEditors_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeEditor_Click cmdChangeEditor
End Sub

Private Sub frmOptions.lvTerminalPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvTerminalPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvTerminalPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeTerminal_Click *cmdChangeTerminal.Designer, cmdChangeTerminal
End Sub


Private Sub frmOptions.lvHelpPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
	(*Cast(frmOptions Ptr, Sender.Designer)).lvHelpPaths_ItemActivate(Sender, ItemIndex)
End Sub
Private Sub frmOptions.lvHelpPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	cmdChangeHelp_Click *cmdChangeHelp.Designer, cmdChangeHelp
End Sub

Private Sub frmOptions.cmdInFolder_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmOptions Ptr, Sender.Designer)).cmdInFolder_Click(Sender)
End Sub
Private Sub frmOptions.cmdInFolder_Click(ByRef Sender As Control)
	BrowsD.InitialDir = GetFullPath(txtInFolder.Text)
	If BrowsD.Execute Then
		txtInFolder.Text = BrowsD.Directory
	End If
End Sub

Private Sub frmOptions.chkCreateNonStaticEventHandlers_Click(ByRef Sender As CheckBox)
	chkPlaceStaticEventHandlersAfterTheConstructor.Enabled = chkCreateNonStaticEventHandlers.Checked
	chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning.Enabled = chkCreateNonStaticEventHandlers.Checked
	chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt.Enabled = chkCreateNonStaticEventHandlers.Checked
End Sub

Private Sub frmOptions.txtColorForeground_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		txtColorForeground.BackColor = Val(txtColorForeground.Text)
		txtColorForeground.ForeColor = GetReadableTextColor(txtColorForeground.BackColor)
		chkForeground.Checked = False
		Colors(i, 0) = txtColorForeground.BackColor
	End If
End Sub

Private Sub frmOptions.txtColorBackground_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		txtColorBackground.BackColor = Val(txtColorBackground.Text)
		txtColorBackground.ForeColor = GetReadableTextColor(txtColorBackground.BackColor)
		chkBackground.Checked = False
		Colors(i, 1) = txtColorBackground.BackColor
	End If
End Sub

Private Sub frmOptions.txtColorFrame_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then 
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		txtColorFrame.BackColor = Val(txtColorFrame.Text)
		txtColorFrame.ForeColor = GetReadableTextColor(txtColorFrame.BackColor)
		chkFrame.Checked = False
		Colors(i, 2) = txtColorFrame.BackColor
	End If
End Sub

Private Sub frmOptions.txtColorIndicator_KeyPress(ByRef Sender As Control, Key As Integer)
	If Key = 13 Then 
		Var i = fOptions.lstColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		txtColorIndicator.BackColor = Val(txtColorIndicator.Text)
		txtColorIndicator.ForeColor = GetReadableTextColor(txtColorIndicator.BackColor)
		chkIndicator.Checked = False
		Colors(i, 3) = txtColorIndicator.BackColor
	End If
End Sub

Private Sub frmOptions.cboInterfaceTheme_Change(ByRef Sender As ComboBoxEdit)
	If UBound(InterfaceColors) = -1 Then Exit Sub
	iniInterfaceTheme.Load ExePath & "/Settings/Themes/Interface/" & fOptions.cboInterfaceTheme.Text & ".ini"
	InterfaceColors(0) = iniInterfaceTheme.ReadInteger("Colors", "DarkBackground", darkBkColor)
	InterfaceColors(1) = iniInterfaceTheme.ReadInteger("Colors", "DarkBackgroundHighlight", darkHlBkColor)
	InterfaceColors(2) = iniInterfaceTheme.ReadInteger("Colors", "Text", darkTextColor)
	lstInterfaceColorKeys_Change(lstInterfaceColorKeys)
End Sub

Private Sub frmOptions.lstInterfaceColorKeys_Change(ByRef Sender As ListControl)
	Var i = lstInterfaceColorKeys.ItemIndex
	If i = -1 Then Exit Sub
	If UBound(InterfaceColors) < 0 Then Exit Sub
	txtInterfaceColor.BackColor = InterfaceColors(i)
	chkInterfaceColor.Checked = CBool(InterfaceColors(i) = -1)
	txtInterfaceColor.Text = "&H" & Hex(txtInterfaceColor.BackColor, 6)
	txtInterfaceColor.ForeColor = GetReadableTextColor(txtInterfaceColor.BackColor)
End Sub

Private Sub frmOptions.cmdInterfaceThemeAdd_Click(ByRef Sender As Control)
	If pfTheme->ShowModal(fOptions) = ModalResults.OK Then
		cboInterfaceTheme.AddItem pfTheme->txtThemeName.Text
		cboInterfaceTheme.ItemIndex = cboInterfaceTheme.IndexOf(pfTheme->txtThemeName.Text)
		cboInterfaceTheme_Change(cboInterfaceTheme)
	End If
End Sub

Private Sub frmOptions.cmdInterfaceThemeRemove_Click(ByRef Sender As Control)
	Kill ExePath & "/Settings/Themes/Interface/" & cboInterfaceTheme.Text & ".ini"
	cboInterfaceTheme.RemoveItem cboInterfaceTheme.ItemIndex
	cboInterfaceTheme.ItemIndex = 0
	cboInterfaceTheme_Change(cboInterfaceTheme)
End Sub

Private Sub frmOptions.cmdInterfaceColor_Click(ByRef Sender As Control)
	With ColorD
		Var i = lstInterfaceColorKeys.ItemIndex
		If i = -1 Then Exit Sub
		.Color = InterfaceColors(i)
		If .Execute Then
			txtInterfaceColor.BackColor = .Color
			chkInterfaceColor.Checked = False
			InterfaceColors(i) = .Color
			txtInterfaceColor.Text = "&H" & Hex(.Color, 6)
			txtInterfaceColor.ForeColor = GetReadableTextColor(txtInterfaceColor.BackColor)
		End If
	End With
End Sub

Private Sub frmOptions.chkInterfaceColor_Click(ByRef Sender As CheckBox)
	Var i = lstInterfaceColorKeys.ItemIndex
	If i = -1 Then Exit Sub
	InterfaceColors(i) = IIf(chkInterfaceColor.Checked, -1, txtInterfaceColor.BackColor)
End Sub

