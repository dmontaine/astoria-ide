'#########################################################
'#  frmOptions.bi                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/Form.bi"
#include once "mff/TreeView.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Label.bi"
#include once "mff/Panel.bi"
#include once "mff/TextBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/IniFile.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ListControl.bi"
#include once "mff/CommandButton.bi"
#include once "mff/CheckBox.bi"
#include once "mff/GroupBox.bi"
#include once "mff/Label.bi"
#include once "mff/Panel.bi"
#include once "mff/TextBox.bi"
#include once "mff/Picture.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/Dialogs.bi"
#include once "Main.bi"
#include once "EditControl.bi"
#include once "frmTheme.bi"
#include once "frmPath.bi"
#include once "mff/ListView.bi"
#include once "mff/RadioButton.bi"
#include once "mff/HotKey.bi"
#include once "mff/TimerComponent.bi"
#include once "mff/ScrollControl.bi"
#include once "mff/VerticalBox.bi"
#include once "mff/HorizontalBox.bi"
#include once "mff/PagePanel.bi"
#include once "mff/NumericUpDown.bi"

Using My.Sys.Forms

'#Region "Form"
	Type frmOptions Extends Form
		Declare Static Sub cmdOK_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdApply_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub Form_Destroy(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Static Sub Form_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
		Declare Static Sub Form_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
		Declare Static Sub cmdForeground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdInterfaceFont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub TreeView1_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
		Declare Static Sub cmdMFFPath_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdFont_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub lstColorKeys_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdBackground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdIndicator_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cboTheme_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub chkForeground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub chkBackground_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub chkIndicator_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub chkBold_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub chkItalic_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub chkUnderline_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdRemove_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdAddTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdRemoveTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdClearTerminals_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdFrame_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub chkFrame_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Static Sub cmdChangeTerminal_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdAddHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdChangeHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdRemoveHelp_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdClearHelps_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub LoadSettings()
		Declare Static Sub cmdAddInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdAddLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdRemoveInclude_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdRemoveLibrary_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdProjectsPath_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub lvShortcuts_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub cmdSetShortcut_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdAddEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdAddEditor_Click(ByRef Sender As Control)
		Declare Static Sub cmdChangeEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdChangeEditor_Click(ByRef Sender As Control)
		Declare Static Sub cmdRemoveEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdRemoveEditor_Click(ByRef Sender As Control)
		Declare Static Sub cmdClearEditor_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdClearEditor_Click(ByRef Sender As Control)
		Declare Static Sub lvOtherEditors_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvOtherEditors_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvTerminalPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvTerminalPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Static Sub lvHelpPaths_ItemActivate_(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub lvHelpPaths_ItemActivate(ByRef Sender As ListView, ByVal ItemIndex As Integer)
						Declare Static Sub cmdInFolder_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdInFolder_Click(ByRef Sender As Control)
		Declare Static Sub chkCreateNonStaticEventHandlers_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Sub chkCreateNonStaticEventHandlers_Click(ByRef Sender As CheckBox)
		Declare Static Sub _txtColorForeground_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		Declare Sub txtColorForeground_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Static Sub _txtColorBackground_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		Declare Sub txtColorBackground_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Static Sub _txtColorFrame_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		Declare Sub txtColorFrame_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Static Sub _txtColorIndicator_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
		Declare Sub txtColorIndicator_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Sub cboInterfaceTheme_Change(ByRef Sender As ComboBoxEdit)
		Declare Sub lstInterfaceColorKeys_Change(ByRef Sender As ListControl)
		Declare Sub cmdInterfaceThemeAdd_Click(ByRef Sender As Control)
		Declare Sub cmdInterfaceThemeRemove_Click(ByRef Sender As Control)
		Declare Sub cmdInterfaceColor_Click(ByRef Sender As Control)
		Declare Sub chkInterfaceColor_Click(ByRef Sender As CheckBox)
		Declare Constructor
		Declare Destructor
		
		Dim As TreeView tvOptions
		Dim As CommandButton cmdOK, cmdCancel, cmdApply, cmdMFFPath, cmdAddInclude, cmdRemoveInclude, cmdAddLibrary, cmdRemoveLibrary, cmdChangeTerminal, cmdAdd, cmdRemove, cmdForeground, cmdFont, cmdProjectsPath, cmdBackground, cmdIndicator, cmdAddTerminal, cmdRemoveTerminal, cmdClearTerminals, cmdSetShortcut
		Dim As Label lblBlack, lblCompiler64, lblCompiler64Path, lblTabSize, lblHistoryLimit, lblGridSize, lblFont, lblProjectsPath, lblForeground, lblBackground, lblIndicator, lblOthers, lblShortcut
		Dim As ScrollControl pnlGeneral, pnlCodeEditor, pnlDesigner, sccColors, sccInterfaceColors
		Dim As Panel pnlThemes, pnlShortcuts, pnlColorsAndFonts, pnlCompiler, pnlDebugger, pnlTerminal, pnlHelp, pnlIncludeMFFPath, pnlInterfaceFont, pnlGrid, pnlOtherEditors, pnlLine, pnlProjectsPath, pnlSelectShortcut, pnlAutoSaveCharMax
		Dim As HorizontalBox hbxEditors, hbxHelp, hbxTerminal, hbxColors, hbxThemeCommands, hbxForeground, hbxBackground, hbxFrame, hbxIndicator, pnlCommands, hbxIncludePaths, hbxLibraryPaths, hbxInterfaceColors, hbxInterfaceThemeCommands, hbxInterfaceColor
		Dim As Panel pnlChangeKeywordsCase, pnlChangeIdentifiersCase, pnlTreatTabAsSpaces, pnlTabSize, pnlHistoryLimit, pnlIntellisenseLimit, pnlHistoryFileSavingDays, pnlChangeEndingType, pnlCodeEditorHoverTime
		Dim As TextBox txtColorForeground, txtColorBackground, txtColorIndicator, txtColorFrame
		Dim As TextBox txtMFFpath, txtTabSize, txtHistoryLimit, txtGridSize, txtProjectsPath, txtInFolder, txtIntellisenseLimit, txtHistoryCodeDays,  txtFoldsHtml(0), txtFoldsLng, txtAutoSaveCharMax, txtCodeEditorHoverTime, txtInterfaceColor
		Dim As ComboBoxEdit cboIdentifiersCase, cboCase, cboTabStyle, cboTheme, cboTerminal, cboHelp, cboConstructions, cboInterfaceTheme
		Dim As CheckBox chkAutoCreateRC, chkAutoSaveCurrentFileBeforeCompiling, chkEnableAutoComplete, chkTabAsSpaces, chkAutoIndentation, chkShowSpaces, chkShowAlignmentGrid, chkSnapToGrid, chkChangeKeywordsCase, chkBold, chkItalic, chkUnderline
		Dim As HotKey hkShortcut
		Dim OpenD As OpenFileDialog
		Dim BrowsD As FolderBrowserDialog
		Dim ColorD As ColorDialog
		Dim FontD As FontDialog
		Dim As WString Ptr EditFontName, InterfFontName, oldInterfFontName
		Dim As Boolean oldDarkMode
		Dim As Integer EditFontSize, InterfFontSize, oldInterfFontSize
		Dim InterfaceColors(Any) As Integer
		Dim InterfaceColorsCount As Integer
		Dim Colors(Any, Any) As Integer
		Dim ColorsCount As Integer
		Dim As Boolean FDisposing
		Dim As WStringList HotKeysPriv, Templates
		Dim As Boolean HotKeysChanged
		Dim As Integer LibraryPathsCount
		Dim As ListControl lstIncludePaths, lstLibraryPaths, lstColorKeys, lstInterfaceColorKeys
		Dim As GroupBox grbGrid, grbColors, grbThemes, grbFont, grbDefaultCompilers, grbDefaultTerminal, grbTerminalPaths, grbIncludePaths, grbLibraryPaths, grbDefaultHelp, grbHelpPaths, grbWhenCompiling, grbShortcuts, grbOtherEditors, grbCommandPromptOptions, grbDisplay, grbCompletion, grbIntelliSense, grbHistory
		Dim As ListView lvTerminalPaths, lvHelpPaths, lvShortcuts, lvOtherEditors
		Dim As Label lblInterfaceFont
		Dim As CommandButton cmdInterfaceFont
		Dim As Label lblInterfaceFontLabel
		Dim As CheckBox chkDisplayIcons, chkShowMainToolbar, chkAutoCreateBakFiles, chkShowToolBoxLocal
		Dim As Label lblFrame, lblOpenCommandPromptIn, lblIntellisenseLimit, lblHistoryDay, lbAutoSaveCharMax, lblCodeEditorHoverTime, lblInterfaceColor
		Dim As CommandButton cmdFrame, cmdAddHelp, cmdChangeHelp, cmdRemoveHelp, cmdClearHelps, cmdAddEditor, cmdChangeEditor, cmdRemoveEditor, cmdClearEditor, cmdInFolder, cmdReplaceInFiles(0), cmdInterfaceThemeAdd, cmdInterfaceThemeRemove, cmdInterfaceColor
		Dim As CheckBox chkFrame, chkForeground, chkBackground, chkIndicator
		Dim As CheckBox chkHighlightCurrentWord
		Dim As CheckBox chkHighlightCurrentLine
		Dim As CheckBox chkHighlightBrackets, chkIncludeMFFPath, chkLimitDebug, chkDisplayWarningsInDebug, chkCreateNonStaticEventHandlers, chkShowKeywordsTooltip, chkShowSymbolsTooltipsOnMouseHover, chkShowClassesExplorerOnOpenWindow, chkAddSpacesToOperators, chkCreateFormTypesWithoutTypeWord, chkDarkMode, chkPlaceStaticEventHandlersAfterTheConstructor, chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, chkAddRelativePathsToRecent, chkShowTooltipsAtTheTop, chkChangeIdentifiersCase, chkSyntaxHighlightingIdentifiers, chkEnableAutoSuggestions, chkShowHorizontalSeparatorLines, chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt, chkShowHolidayFrame, ShowClassesExplorerOnOpenWindow, chkChangeEndingType, chkUseDirect2D, chkInterfaceColor
		Dim As Boolean oldDisplayMenuIcons
		Dim As Boolean LastApplySucceeded = True
		Dim As RadioButton optSaveCurrentFile, optDoNotSave, optSaveAllFiles, optPromptToSave, optMainFileFolder, optInFolder
		Dim As VerticalBox vbxCodeEditor, vbxGeneral, vbxColors
		Dim As VerticalBox vbxTheme, vbxIncludePaths, vbxLibraryPaths, vbxInterfaceTheme, vbxInterfaceColors
		Dim As PagePanel pplGeneral
	End Type
'#End Region


Declare Sub HistoryCodeClean(ByRef Path As WString)
Common Shared pfOptions As frmOptions Ptr

	#include once "frmOptions.frm"


