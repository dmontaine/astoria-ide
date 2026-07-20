'#########################################################
'#  Main.bas                                             #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "Main.bi"
#include once "mff/Dialogs.bi"
#include once "mff/Form.bi"
#include once "mff/SearchBox.bi"
#include once "mff/TextBox.bi"
#include once "mff/RichTextBox.bi"
#include once "mff/TabControl.bi"
#include once "mff/StatusBar.bi"
#include once "mff/Splitter.bi"
#include once "mff/HorizontalBox.bi"
#include once "mff/ToolBar.bi"
#include once "mff/ListControl.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/ComboBoxEx.bi"
#include once "mff/RadioButton.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/ScrollBarControl.bi"
#include once "mff/Label.bi"
#include once "mff/LinkLabel.bi"
#include once "mff/Panel.bi"
#include once "mff/TrackBar.bi"
#include once "mff/Clipboard.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"
#include once "mff/IniFile.bi"
#include once "mff/PointerList.bi"
#include once "mff/ReBar.bi"
#include once "mff/HTTP.bi"
#include once "fbthread.bi"
#include once "vbcompat.bi"
#include once "win/shellapi.bi"

Using My.Sys.Forms
Using My.Sys.Drawing

Const PROJECT_FOLDER_INCLUDES As Integer = 0
Const PROJECT_FOLDER_FORMS As Integer = 1
Const PROJECT_FOLDER_MODULES As Integer = 2
Const PROJECT_FOLDER_RESOURCES As Integer = 3
Const PROJECT_FOLDER_OTHERS As Integer = 4

Const SAVE_FILTER_BAS As Integer = 1
Const SAVE_FILTER_BI As Integer = 2
Const SAVE_FILTER_INC As Integer = 3
Const SAVE_FILTER_FRM As Integer = 4
Const SAVE_FILTER_RC As Integer = 5
Const SAVE_FILTER_OTHER As Integer = 6

Dim Shared As Boolean bQuitting
	'' Payload handed to the already-running instance. A fixed buffer rather than StrPtr of a
	'' var-len string, because StrPtr("") can be NULL and the receiver rejects a null pointer --
	'' which is precisely the "no file named" case this has to carry (ROADMAP 13.29).
	Dim Shared As ZString * 4096 HandoverPayload

	Function EnumWindowsProc(ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL
		Dim As Any Ptr VisualFBEditorAppPtr = GetProp(hWnd, "VisualFBEditorApp")

		If VisualFBEditorAppPtr <> 0 Then
			Dim As ZString Ptr FileFromCmdLine = Cast(ZString Ptr, lParam)
			'' Grant the instance we are handing over to the right to take the foreground.
			'' Without this its own SetForegroundWindow is refused and the user, who just
			'' launched Astoria, sees nothing happen at all.
			Dim As DWORD OtherProcessId
			GetWindowThreadProcessId(hWnd, @OtherProcessId)
			AllowSetForegroundWindow(OtherProcessId)
			Dim cds As COPYDATASTRUCT
			cds.dwData = 0
			cds.cbData = Len(*FileFromCmdLine) + 1
			cds.lpData = FileFromCmdLine
			If SendMessage(hWnd, WM_COPYDATA, 0, Cast(lParam, @cds)) <> 0 Then
				bQuitting = True
				Return False        '' handed over; stop enumerating
			End If
		End If

		Return True
	End Function

	If App.PrevInstance Then
		Var FileFromCommandLine = Command(-1)
		Var Pos1 = InStr(FileFromCommandLine, "2>CON")
		If Pos1 > 0 Then FileFromCommandLine = Left(FileFromCommandLine, Pos1 - 1)
		'' An .exe here would be this program's own name, never a file the user wants opened.
		'' Command(-1) already excludes the program name, so this is belt and braces.
		If Right(LCase(FileFromCommandLine), 4) = ".exe" Then FileFromCommandLine = ""
		HandoverPayload = Left(FileFromCommandLine, 4095)

		'' Hand over to the running instance UNCONDITIONALLY -- with a file to open when one was
		'' given, and in every case so that it comes to the front. The old code ran this only
		'' when a file was named, so a plain second launch (the desktop icon, the commonest case
		'' there is) fell straight through to the End below and did nothing visible (13.29).
		EnumWindows(@EnumWindowsProc, Cast(LPARAM, @HandoverPayload))

		'' Leave without FB's End. This is module-level code, which FreeBASIC runs from the CRT's
		'' global initialiser table; End unwinds the CRT from inside that walk and faulted in
		'' msvcrt!_initterm_e every time (13.29, 0xC0000005). Nothing needs flushing here -- no
		'' file is open and framework.dll is not loaded until below -- so leaving directly is
		'' both correct and the only thing that does not re-enter the teardown that crashed.
		ExitProcess(0)
	End If
	
	' MyFbFramework must load before any other FB control DLL in Controls\ (shared fbrt runtime).
	DyLibLoad(App.Path & "\Controls\Framework\framework.dll")
	
#include once "frmSplash.bi"
pfSplash->MainForm = False
pfSplash->Show
'' Splash text (title + version line) is set once in frmSplash's own Constructor -- this used
'' to immediately overwrite the version line here with a dynamic "(Version x.x.x.x  64-bit)"
'' string, silently undoing that. Removed so the static splash text actually sticks.
Dim Shared As Double SplashShownAt
SplashShownAt = Timer
pApp->DoEvents

Dim Shared As VisualFBEditor.Application VisualFBEditorApp
Dim Shared As ComboBoxEdit cboBuildConfiguration
Dim Shared As IniFile iniSettings, iniTheme, iniInterfaceTheme
Dim Shared As SearchBox txtExplorer, txtForm, txtProperties, txtEvents
Dim Shared As ToolBar tbStandard, tbEdit, tbRun, tbProject, tbExplorer, tbForm, tbProperties, tbEvents, tbBottom, tbLeft, tbRight, tbFormat
Dim Shared As StatusBar stBar
Dim Shared As Splitter splLeft, splRight, splBottom, splProperties, splEvents
Dim Shared As ListControl lstLeft
Dim Shared As CheckBox chkLeft
Dim Shared As RadioButton radButton
Dim Shared As ScrollBarControl scrLeft
Dim Shared As Label lblLeft
Dim Shared As Panel pnlLeft, pnlRight, pnlBottom, pnlBottomTab, pnlLeftPin, pnlRightPin, pnlBottomPin, pnlPropertyValue, pnlColor
Dim Shared As TrackBar trLeft
Dim Shared As MainMenu mnuMain
Dim Shared As MenuItem Ptr mnuStartWithCompile, mnuStart, mnuContinue, mnuBreak, mnuEnd, mnuRestart, mnuSplit, mnuSplitHorizontally, mnuSplitVertically, mnuWindowSeparator, miRecentFiles, miSetAsMain, miClearStartUp, miTabSetAsMain, miTabReloadHistoryCode, miRemoveFiles, miToolBars
Dim Shared As MenuItem Ptr miSaveProject, miSaveProjectAs, miCloseProject, miDeleteProject, miNewFile, miOpenFile, miCloseFile, miDeleteFile, miSaveFile, miSaveFileAs, miPrint, miPrintPreview, miPageSetup, miOpenProjectFolder, miProjectProperties, miEditProjectDescription, miGitCommit, miGitPull, miGitPush, miGitSshKey, miGitCreateRepo, miExplorerOpenProjectFolder, miExplorerRename, miExplorerProjectProperties, miExplorerCloseProject, miRename, miRemoveFileFromProject
Dim Shared As MenuItem Ptr miUndo, miRedo, miCutCurrentLine, miCut, miCopy, miPaste, miSingleComment, miDuplicate, miSelectAll, miIndent, miOutdent, miFormat, miUnformat, miFormatProject, miUnformatProject, miAddSpaces, miDeleteBlankLines, miParameterInfo, miStepInto, miStepOver, miStepOut, miRunToCursor, miGDBCommand, miAddWatch, miToggleBreakpoint, miClearAllBreakpoints, miSetNextStatement, miShowNextStatement
Dim Shared As MenuItem Ptr dmiMake, dmiMakeClean
Dim Shared As MenuItem Ptr miCode, miForm, miCodeAndForm, miGotoCodeForm, miFold, miDebugWindows, miCollapseCurrent, miCollapseAllProcedures, miCollapseAll, miUnCollapseCurrent, miUnCollapseAllProcedures, miUnCollapseAll, miImageManager, miAddProcedure, miAddType, miFind, miReplace, miFindNext, miFindPrevious, miGoto, miDefine, miToggleBookmark, miNextBookmark, miPreviousBookmark, miClearAllBookmarks, miSyntaxCheck, miCompile, miCompileAll, miMake, miMakeClean
Dim Shared As MenuItem Ptr miAlignLefts, miAlignCenters, miAlignRights, miAlignTops, miAlignMiddles, miAlignBottoms, miAlignToGrid, miMakeSameSizeWidth, miMakeSameSizeHeight, miMakeSameSizeBoth, miSizeToGrid, miHorizontalSpacingMakeEqual, miHorizontalSpacingIncrease, miHorizontalSpacingDecrease, miHorizontalSpacingRemove, miVerticalSpacingMakeEqual, miVerticalSpacingIncrease, miVerticalSpacingDecrease, miVerticalSpacingRemove, miCenterInParentHorizontally, miCenterInParentVertically, miOrderBringToFront, miOrderSendToBack, miLockControls
Dim Shared As MenuItem Ptr miFormFormat ' D1 (2026-07-07): top-level Form menu; greyed contextually by UpdateCodeFormMenuEnabled (TabWindow.bas)
Dim Shared As MenuItem Ptr miCodeMenu ' top-level Code menu; greyed contextually alongside miFormFormat (see UpdateCodeFormMenuEnabled)
Dim Shared As MenuItem Ptr miCodeFormMenu ' top-level Code/Form menu: commands valid in both views; NEVER greyed (a greyed parent menu kills its accelerators)
Dim Shared As Boolean gDesignerPaneFocused ' split view: True while the form-designer pane (not the code editor) last held focus
Dim Shared As MenuItem Ptr miShowWithFolders, miShowWithoutFolders, miShowAsFolder
Dim Shared As ToolButton Ptr tbtAlignLefts, tbtAlignCenters, tbtAlignRights, tbtAlignTops, tbtAlignMiddles, tbtAlignBottoms, tbtAlignToGrid, tbtMakeSameSizeWidth, tbtMakeSameSizeHeight, tbtMakeSameSizeBoth, tbtSizeToGrid, tbtHorizontalSpacingMakeEqual, tbtHorizontalSpacingIncrease, tbtHorizontalSpacingDecrease, tbtHorizontalSpacingRemove, tbtVerticalSpacingMakeEqual, tbtVerticalSpacingIncrease, tbtVerticalSpacingDecrease, tbtVerticalSpacingRemove, tbtCenterInParentHorizontally, tbtCenterInParentVertically, tbtOrderBringToFront, tbtOrderSendToBack, tbtLockControls
Dim Shared As ToolButton Ptr tbtSave, tbtSaveAll, tbtSyntaxCheck, tbtSuggestions, tbtCompile, tbtUndo, tbtRedo, tbtCut, tbtCopy, tbtPaste, tbtSingleComment, tbtFormat, tbtUnformat, tbtCompleteWord, tbtParameterInfo, tbtFind, tbtRemoveFileFromProject, tbtStartWithCompile, tbtStart, tbtBreak, tbtEnd, tbtUseDebugger, tbtNotSetted, tbtConsole, tbtGUI, tbtStepInto, tbtStepOver, tbtStepOut, tbtRunToCursor, tbtToggleBreakpoint, tbtSetNextStatement, tbtShowNextStatement
Dim Shared As SaveFileDialog SaveD
Dim Shared As ReBar MainReBar, rbLeft, rbRight, rbBottom
	Dim Shared As PageSetupDialog PageSetupD
	Dim Shared As PrintDialog PrintD
	Dim Shared As PrintPreviewDialog PrintPreviewD
	Dim Shared As My.Sys.ComponentModel.Printer pPrinter
Dim Shared As List Tools, TabPanels, ControlLibraries
Dim Shared As WStringOrStringList Comps, GlobalAsmFunctionsHelp, GlobalFunctionsHelp, Snippets, TypesInFunc, EnumsInFunc
'Dim Shared As WStringOrStringList GlobalNamespaces, GlobalTypes, GlobalEnums, GlobalDefines, GlobalFunctions, GlobalTypeProcedures, GlobalArgs
Dim Shared As WStringList AddIns, IncludeFiles, LoadPaths, IncludePaths, LibraryPaths, MRUFiles, MRUFolders, MRUProjects, ProfilingFunctions
Dim Shared As WString Ptr RecentFiles, RecentFile, RecentProject, RecentFolder
Dim Shared As Dictionary Helps, HotKeys, Compilers, MakeTools, Terminals, BuildConfigurations
'' Set once at startup; see LogMenuKey / ROADMAP 13.28. Off unless the sentinel file exists.
Dim Shared As Boolean bLogMenuKeys
Dim Shared As ListView lvProblems, lvSuggestions, lvSearch, lvToDo, lvMemory
Dim Shared As ProgressBar prProgress
Dim Shared As CommandButton btnPropertyValue
Dim Shared As TextBox txtPropertyValue, txtExpand
Dim Shared As RichTextBox txtLabelProperty, txtLabelEvent
Dim Shared As ComboBoxEdit cboPropertyValue
Dim Shared As PopupMenu mnuForm, mnuVars, mnuWatch, mnuExplorer, mnuTabs, mnuProcedures, mnuProblems
Dim Shared As ImageList imgList, imgListD, imgListTools, imgListStates, imgList32
Dim Shared As TreeListView lvProperties, lvEvents, lvLocals, lvGlobals, lvThreads, lvWatches, lvProfiler
Dim Shared As TreeView tvToolBox
Dim Shared As TreeNode Ptr tnToolControls, tnToolContainers, tnToolComponents, tnToolDialogs
Dim Shared As Panel pnlToolBox
Dim Shared As TabControl tabLeft, tabRight, tabBottom ', tabDebug
Dim Shared As TreeView tvExplorer, tvVar, tvPrc, tvThd, tvWch
Dim Shared As TextBox txtOutput, txtImmediate
Dim Shared As TextBox txtChangeLog ' Add Change Log
Dim Shared As TabPage Ptr tpProject, tpToolbox, tpProperties, tpEvents, tpOutput, tpProblems, tpSuggestions, tpFind, tpToDo, tpChangeLog, tpImmediate, tpLocals, tpGlobals, tpProcedures, tpThreads, tpWatches, tpMemory, tpProfiler
Dim Shared As Form frmMain
Dim Shared As Integer tabItemHeight
Dim Shared As Integer miRecentMax =20 'David Changed
Dim Shared As Boolean mLoadLog, mLoadToDo, mChangeLogEdited, ManifestIcoCopy
Dim Shared As WString * MAX_PATH mChangelogName  'David Changed
pApp = @VisualFBEditorApp
pfrmMain = @frmMain
pSaveD = @SaveD
piniSettings = @iniSettings
piniTheme = @iniTheme
pAddIns = @AddIns
pTools = @Tools
pControlLibraries = @ControlLibraries
pCompilers = @Compilers
pMakeTools = @MakeTools
pTerminals = @Terminals
pHelps = @Helps
plvSearch = @lvSearch
plvToDo = @lvToDo '
ptbStandard = @tbStandard
pcboBuildConfiguration = @cboBuildConfiguration
plvProperties = @lvProperties
plvEvents = @lvEvents
pprProgress = @prProgress
pstBar = @stBar   'David Change
ptxtPropertyValue = @txtPropertyValue
pbtnPropertyValue = @btnPropertyValue
ptvExplorer = @tvExplorer
ptabLeft = @tabLeft
ptabBottom = @tabBottom
ptabRight = @tabRight
pimgList = @imgList
pimgListTools = @imgListTools
pIncludeFiles = @IncludeFiles
pLoadPaths = @LoadPaths
pIncludePaths = @IncludePaths
pLibraryPaths = @LibraryPaths
pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Settings")

'' T2a: portable-model safety net (owner sign-off, T1: everything stays under ExePath, no
'' APPDATA migration). Everything below -- LoadSettings and the rest of startup -- assumes
'' ExePath\Settings is writable and fails silently if it isn't (e.g. a Program Files install
'' without elevation). Probe it for real with an actual write instead of just checking ACLs,
'' and fail loud with one clear, actionable message instead of limping on with a settings
'' file that silently never saves.
Dim As Integer ProbeFn
Dim As Integer ProbeResult
Dim As String ProbeFile
ProbeFn = FreeFile_
ProbeFile = ExePath & "/Settings/.writetest"
ProbeResult = Open(ProbeFile For Output As #ProbeFn)
If ProbeResult <> 0 Then
	MsgBox "Astoria IDE needs to run from a folder you can write to " & WChr(&H2014) & " install per-user or move it out of Program Files.", "Astoria IDE", mtError
	End 1
End If
CloseFile_(ProbeFn)
Kill ProbeFile

LoadLanguageTexts
LoadSettings

#include once "file.bi"
#include once "Designer.bi"
#include once "ProjectDescription.bi"
#include once "TabWindow.bi"
#include once "AgentPipe.bi"
#include once "Debug.bi"
#include once "frmFind.bi"
#include once "frmGoto.bi"
#include once "frmFindInFiles.bi"
#include once "frmAddIns.bi"
#include once "frmTools.bi"
#include once "frmAbout.bi"
#include once "frmImageManager.bi"
#include once "frmOptions.bi"
#include once "frmTemplates.bi"
#include once "frmNewFileName.bi"
#include once "frmGitCommit.bi"
#include once "frmEditProjectDescription.bi"
#include once "frmNewProject.bi"
#include once "frmNewFile.bi"
#include once "frmOpenProject.bi"
#include once "frmRecentProjects.bi"
#include once "frmOpenProjectFile.bi"
#include once "frmParameters.bi"
#include once "frmProjectProperties.bi"
#include once "frmSave.bi"
#include once "Debug.bi"

pComps = @Comps
pGlobalNamespaces = @Globals.Namespaces
pGlobalTypes = @Globals.Types
pGlobalEnums = @Globals.Enums
pGlobalDefines = @Globals.Defines
pGlobalFunctions = @Globals.Functions
pGlobalTypeProcedures = @Globals.TypeProcedures
pGlobalArgs = @Globals.Args
IncludePaths.Sorted = True
Comps.Sorted = True
Globals.Namespaces.Sorted = True
Globals.Types.Sorted = True
Globals.TypeProcedures.Sorted = True
Globals.Enums.Sorted = True
Globals.Defines.Sorted = True
Globals.Functions.Sorted = True
Globals.Args.Sorted = True
GlobalAsmFunctionsHelp.Sorted = True
GlobalFunctionsHelp.Sorted = True
WithFrame = Month(Now) = 12 OrElse Month(Now) = 1

Namespace VisualFBEditor
	Function Application.ReadProperty(ByRef PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case "mainprojectfile", "mainfile", "exefile"
			Dim As ProjectElement Ptr Project
			Dim As ExplorerElement Ptr ee
			Dim As TreeNode Ptr ProjectNode
			Dim As UString ProjectFile = ""
			Dim As UString CompileLine, MainFile = GetMainFile(, Project, ProjectNode)
			Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project, CompileLine)
			Dim As UString ExeFile = GetExeFileName(MainFile, CompileLine & " " & FirstLine)
			If ProjectNode <> 0 Then ee = ProjectNode->Tag
			If ee <> 0 Then ProjectFile = *ee->FileName
			Select Case LCase(PropertyName)
			Case "mainprojectfile": Return ProjectFile.vptr
			Case "mainfile": Return MainFile.vptr
			Case "exefile": Return ExeFile.vptr
			End Select
		Case "currentword"
			Dim As UString CurrentWord = ""
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			If tb <> 0 Then CurrentWord = tb->txtCode.GetWordAtCursor
			Return CurrentWord.vptr
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
	
	Function Application.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		If Value = 0 Then
			Select Case LCase(PropertyName)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
		Else
			Select Case LCase(PropertyName)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			
		End If
		Return True
	End Function
End Namespace

Sub ToolGroupsToCursor()
	SelectedClass = ""
	SelectedTool = 0
	SelectedToolNode = 0
	SelectedType = 0
	If tnToolControls <> 0 AndAlso tnToolControls->Nodes.Count > 0 Then
		tvToolBox.SelectedNode = tnToolControls->Nodes.Item(0)
	End If
End Sub

Sub ClearMessages()
	txtOutput.Text = ""
	txtOutput.Update
End Sub

' Output/Problems/Suggestions/Find/ToDo/Change Log hold results scoped to whichever
' project or file produced them; stale entries from a closed project are misleading
' once a different project is open. Cleared on CloseProject/CloseAllDocuments.
Sub ClearAnalysisPanels()
	ClearMessages()
	lvProblems.ListItems.Clear
	tpProblems->Caption = ("Problems")
	lvSuggestions.ListItems.Clear
	tpSuggestions->Caption = ("Suggestions")
	lvSearch.ListItems.Clear
	tpFind->Caption = ("Find")
	lvToDo.ListItems.Clear
	tpToDo->Caption = ("ToDo")
	txtChangeLog.Text = ""
	mLoadLog = False
	mLoadToDo = False
End Sub

Private Sub RemoveBottomDebugTab(tp As TabPage Ptr)
	If tp = 0 OrElse tp->Parent = 0 Then Exit Sub
	ptabBottom->DetachTab tp
End Sub

Private Sub AddBottomDebugTab(tp As TabPage Ptr)
	If tp = 0 OrElse tp->Parent <> 0 Then Exit Sub
	ptabBottom->AddTab tp
End Sub

Sub SetDebugTabsVisible(bVisible As Boolean)
	Static As Boolean bAlreadyVisible = True
	If bVisible = bAlreadyVisible Then Exit Sub
	bAlreadyVisible = bVisible
	If bVisible Then
		AddBottomDebugTab tpLocals
		AddBottomDebugTab tpGlobals
		AddBottomDebugTab tpProcedures
		AddBottomDebugTab tpThreads
		AddBottomDebugTab tpWatches
		AddBottomDebugTab tpMemory
		AddBottomDebugTab tpProfiler
	Else
		RemoveBottomDebugTab tpLocals
		RemoveBottomDebugTab tpGlobals
		RemoveBottomDebugTab tpProcedures
		RemoveBottomDebugTab tpThreads
		RemoveBottomDebugTab tpWatches
		RemoveBottomDebugTab tpMemory
		RemoveBottomDebugTab tpProfiler
	End If
End Sub

' Locals/Globals/Procedures/Threads/Watches/Memory/Profiler/Immediate only hold
' meaningful content during an active debug/profiling run. Cleared when a debug
' session ends (Case "End" in AstoriaIDE.bas), and as a backstop on
' CloseProject/CloseAllDocuments.
Sub ClearDebugPanels()
	ClearThreadsWindow
	lvLocals.Nodes.Clear
	If tpLocals <> 0 AndAlso tpLocals->Parent <> 0 Then tpLocals->Caption = ("Locals")
	tvVar.Nodes.Clear
	lvGlobals.Nodes.Clear
	If tpGlobals <> 0 AndAlso tpGlobals->Parent <> 0 Then tpGlobals->Caption = ("Globals")
	tvPrc.Nodes.Clear
	lvWatches.Nodes.Clear
	SnapshotWatchNames()   ' DR-3 2D: keep the worker-visible watch snapshot in sync
	If tpWatches <> 0 AndAlso tpWatches->Parent <> 0 Then tpWatches->Caption = ("Watches")
	tvWch.Nodes.Clear
	tvThd.Nodes.Clear
	lvMemory.ListItems.Clear
	lvProfiler.Nodes.Clear
	txtImmediate.Text = ""
	If Not UseDebugger Then SetDebugTabsVisible False
End Sub

Sub SetCodeVisible(tb As TabWindow Ptr)
	If tb->CurrentView() = "Form" Then tb->ShowView("Code")
End Sub

Sub SelectError(ByRef FileName As WString, iLine As Integer, tabw As TabWindow Ptr = 0)
	Dim tb As TabWindow Ptr
	If tabw <> 0 AndAlso ptabCode->IndexOfTab(tabw) <> -1 Then
		tb = tabw
		tb->SelectTab
	Else
		If FileName = "" OrElse EndsWith(LCase(FileName), ".exe") OrElse Dir(FileName) = ""  Then Exit Sub
		tb = AddTab(FileName)
	End If
	tb->txtCode.SetSelection iLine - 1, iLine - 1, 0, tb->txtCode.LineLength(iLine - 1)
	SetCodeVisible tb
End Sub

Sub lvProperties_CellEditing(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, CellEditor As Control Ptr, ByRef Cancel As Boolean)
End Sub

Sub lvProperties_CellEdited(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString, ByRef Cancel As Boolean)
	PropertyChanged Sender, NewText, False
End Sub

Sub txtPropertyValue_LostFocus(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	PropertyChanged Sender, txtPropertyValue.Text, False
End Sub

Dim Shared bNotChange As Boolean
Sub cboPropertyValue_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If Trim(cboPropertyValue.Text) = "" Then
		Exit Sub
	End If
	PropertyChanged Sender, cboPropertyValue.Text, True
End Sub

' Compile() moved to BuildService.bas

Sub SelectSearchResult(ByRef FileName As WString, iLine As Integer, ByVal iSelStart As Integer =-1, ByVal iSelLength As Integer =-1, tabw As TabWindow Ptr = 0, ByRef SearchText As WString = WStr(""))
	Dim tb As TabWindow Ptr
	If tabw <> 0 AndAlso ptabCode->IndexOfTab(tabw) <> -1 Then
		tb = tabw
		tb->SelectTab
	Else
		If FileName = "" Then Exit Sub
		tb = AddTab(FileName)
	End If
	If SearchText <> "" Then
		If iSelStart = -1 AndAlso tb->txtCode.LinesCount > iLine - 1 Then iSelStart = InStr(LCase(tb->txtCode.Lines(iLine - 1)), LCase(SearchText))
		If iSelLength = -1 Then iSelLength = Len(SearchText)
	End If
	tb->txtCode.TopLine = iLine - tb->txtCode.VisibleLinesCount / 2
	tb->txtCode.SetSelection iLine - 1, iLine - 1, iSelStart - 1, iSelStart + iSelLength - 1
End Sub

Sub txtOutput_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim Buff As WString Ptr = @txtOutput.Lines(txtOutput.GetLineFromCharIndex)
	If Buff > 0 AndAlso InStr(LCase(*Buff), ("debugprint")) > 1 Then Exit Sub
	Dim As WString Ptr ErrFileName, ErrTitle
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As Integer iLine
	Dim As WString Ptr Temp
	SplitError(*Buff, ErrFileName, ErrTitle, iLine)
	Dim MainFile As WString Ptr: WLet(MainFile, GetMainFile(False, Project, ProjectNode))
	If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLetEx(ErrFileName, GetFolderName(*MainFile) & *ErrFileName)
	WDeAllocate(Temp)
	WDeAllocate(MainFile)
	SelectError(*ErrFileName, iLine)
End Sub

Function GetTreeNodeChild(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
	If tn->Tag AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement AndAlso Cast(ProjectElement Ptr, tn->Tag)->ProjectFolderType = ProjectFolderTypes.ShowWithFolders Then
		If EndsWith(LCase(FileName), ".bi") Then
			Return tn->Nodes.Item(PROJECT_FOLDER_INCLUDES)
		ElseIf EndsWith(LCase(FileName), ".frm") Then
			Return tn->Nodes.Item(PROJECT_FOLDER_FORMS)
		ElseIf EndsWith(LCase(FileName), ".bas") OrElse EndsWith(LCase(FileName), ".inc") Then
			Return tn->Nodes.Item(PROJECT_FOLDER_MODULES)
		ElseIf EndsWith(LCase(FileName), ".rc") Then
			Return tn->Nodes.Item(PROJECT_FOLDER_RESOURCES)
		Else
			Return tn->Nodes.Item(PROJECT_FOLDER_OTHERS)
		End If
	Else
		Return tn
	End If
End Function

' Owner decision: the per-project Change Log lives beside the project (not at ExePath).
' tn is a project-root TreeNode (ImageKey "Project"/"MainProject"/"Opened"); falls back to
' the old ExePath location if tn's Tag isn't a real ProjectElement (shouldn't happen at the
' call sites, but avoids a null-deref).
Function GetChangeLogPath(tn As TreeNode Ptr) As UString
	If tn = 0 Then Return ExePath & WindowsSlash & "_Change.log"
	Dim As ExplorerElement Ptr ee = tn->Tag
	If ee <> 0 AndAlso *ee Is ProjectElement AndAlso ee->FileName <> 0 Then
		Return GetFolderName(*ee->FileName) & StringExtract(tn->Text, ".") & "_Change.log"
	End If
	Return ExePath & WindowsSlash & StringExtract(tn->Text, ".") & "_Change.log"
End Function

' Owner decision: the Change Log should be discoverable in the project tree (under
' "Others" when folders are shown, or directly under the project root in flat mode -- same
' routing GetTreeNodeChild already uses for any other uncategorized file). Skipped for
' ShowAsFolder projects: there the log is a real file inside the project folder once
' written, and the filesystem-backed folder view already shows it with no extra node.
Sub EnsureChangeLogTreeNode(tn As TreeNode Ptr)
	If tn = 0 OrElse tn->Tag = 0 Then Exit Sub
	Dim As ProjectElement Ptr ppe = Cast(ProjectElement Ptr, tn->Tag)
	If ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Then Exit Sub
	Dim As WString * 32 Sentinel = "_Change.log"
	Dim As TreeNode Ptr tnParent = GetTreeNodeChild(tn, Sentinel)
	If tnParent = 0 Then Exit Sub
	tnParent->Nodes.Add(StringExtract(tn->Text, ".") & "_Change.log", "ProjectChangeLog", , "File", "File")
End Sub

Sub ClearTreeNode(ByRef tn As TreeNode Ptr)
	If tn = 0 Then Exit Sub
	Dim As TabWindow Ptr tb
	Dim As TreeNode Ptr childNode
	Dim As ExplorerElement Ptr elemPtr
	For i As Integer = tn->Nodes.Count - 1 To 0 Step -1
		childNode = tn->Nodes.Item(i)
		If childNode = 0 Then Continue For
		ClearTreeNode(childNode)
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For j As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(j))
				If tb->tn = childNode Then
					tb->tn = 0
					Exit For
				End If
			Next j
		Next jj
		If childNode->Tag <> 0 Then
			elemPtr = Cast(ExplorerElement Ptr, childNode->Tag)
			childNode->Tag = 0
			If elemPtr = 0 Then Continue For
			_Delete(elemPtr)
		End If
	Next i
	tn->Nodes.Clear
End Sub

Function GetIconName(ByRef FileName As WString, ppe As ProjectElement Ptr = 0) As String
	Dim As String sMain = ""
	If ppe <> 0 Then
		If FileName = WGet(ppe->MainFileName) OrElse FileName = WGet(ppe->ResourceFileName) OrElse FileName = WGet(ppe->IconResourceFileName) OrElse FileName = WGet(ppe->BatchCompilationFileNameWindows) OrElse FileName = WGet(ppe->BatchCompilationFileNameLinux) Then
			sMain = "Main"
		End If
	End If
	If EndsWith(LCase(FileName), ".rc") OrElse EndsWith(LCase(FileName), ".res") OrElse EndsWith(LCase(FileName), ".xpm") Then
		Return sMain & "Resource"
	ElseIf EndsWith(LCase(FileName), ".vfp") Then
		Return sMain & "Project"
	ElseIf EndsWith(LCase(FileName), ".frm") Then
		Return sMain & "Form"
	ElseIf EndsWith(LCase(FileName), ".bas") Then
		Return sMain & "Module"
	ElseIf CBool(InStr(FileName, ".") = 0) AndAlso CBool(FileName <> "") AndAlso FolderExists(FileName) Then
		Return sMain & "Folder"
	Else
		Return sMain & "File"
	End If
End Function

Sub ExpandFolder(ByRef tn As TreeNode Ptr)
	If tn = 0 Then Exit Sub
	Dim As ExplorerElement Ptr ee = tn->Tag, ee1
	If ee = 0 OrElse ee->FileName = 0 Then Exit Sub
	ClearTreeNode tn
	Dim As TreeNode Ptr tn1, tnP = GetParentNode(tn)
	Dim As String f, IconName
	Dim As UInteger Attr
	Dim As WStringList Files
	f = Dir(*ee->FileName & "/*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	While f <> ""
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then
				If FileExists(f & WindowsSlash & f & ".vfp") Then
					IconName = "Project"
					tn1 = tn->Nodes.Add(GetFileName(f), , f, IconName, IconName)
					AddProject f & WindowsSlash & f & ".vfp", , tn1
					WLet(Cast(ExplorerElement Ptr, tn1->Tag)->FileName, *ee->FileName & WindowsSlash & f)
				Else
					IconName = "Opened"
					tn1 = tn->Nodes.Add(GetFileName(f), , f, IconName, IconName)
					ee1 = _New( ExplorerElement)
					WLet(ee1->FileName, *ee->FileName & WindowsSlash & f)
					tn1->Tag = ee1
				End If
				tn1->Nodes.Add ""
			End If
		Else
			Files.Add *ee->FileName & WindowsSlash & f
		End If
		f = Dir(Attr)
	Wend
	For i As Integer = 0 To Files.Count - 1
		If tnP->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tnP->Tag) Is ProjectElement Then
			IconName = GetIconName(Files.Item(i), tnP->Tag)
		Else
			IconName = GetIconName(Files.Item(i))
		End If
		'		If EndsWith(LCase(Files.Item(i)), ".vfp") Then
		'			IconName = "Project"
		'		ElseIf EndsWith(LCase(Files.Item(i)), ".rc") OrElse EndsWith(LCase(Files.Item(i)), ".res") OrElse EndsWith(LCase(Files.Item(i)), ".xpm") Then
		'			IconName = "Resource"
		'		Else
		'			IconName = "File"
		'		End If
		tn1 = tn->Nodes.Add(GetFileName(*ee->FileName & "/" & Files.Item(i)), , Files.Item(i), IconName, IconName)
		ee1 = _New( ExplorerElement)
		WLet(ee1->FileName, Files.Item(i))
		tn1->Tag = ee1
		If IconName = "Form" Then tn1->Nodes.Add ""
		Dim As TabWindow Ptr tb
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For j As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(j))
				If tb->FileName = Files.Item(i) Then
					tb->tn = tn1
					Exit For
				End If
			Next j
		Next jj
	Next i
End Sub

Function FindOpenTabWindowForNode(tn As TreeNode Ptr) As TabWindow Ptr
	Dim As TabWindow Ptr tb
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For j As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(j))
			If tb->tn = tn Then Return tb
		Next j
	Next jj
	Return 0
End Function

' Loads a control class's real icon (the same one the Toolbox tree already shows,
' e.g. CheckBox/TextBox/PagePanel) into imgList - the ImageList tvExplorer is bound
' to - on first use, from the control library DLL that owns it (same source
' InitToolBoxTree uses via the global Comps registry / imgListTools).
Sub EnsureControlIcon(ByRef ClassName As String)
	If ClassName = "" OrElse imgList.IndexOf(ClassName) >= 0 Then Exit Sub
	Dim As Integer idx = Comps.IndexOf(ClassName)
	If idx < 0 Then Exit Sub
	Dim As TypeElement Ptr tbi = Comps.Object(idx)
	If tbi = 0 OrElse tbi->Tag = 0 Then Exit Sub
	imgList.Add ClassName, ClassName, Cast(Library Ptr, tbi->Tag)->Handle
End Sub

' Mirrors TabWindow.bas's (currently unused) GetControls traversal, but builds
' tvExplorer tree nodes directly instead of a flat list, so nesting reflects the
' live container hierarchy (ControlCount/ControlByIndexFunc) rather than declaration order.
Sub AddControlTreeNode(ParentNode As TreeNode Ptr, Des As My.Sys.Forms.Designer Ptr, tb As TabWindow Ptr, Ctrl As Any Ptr)
	Dim As SymbolsType Ptr st = Des->SymbolsReadProperty(Ctrl)
	If st = 0 Then Exit Sub
	Dim As String CtrlName = QWString(st->ReadPropertyFunc(Ctrl, "Name"))
	Dim As String ClassName = QWString(st->ReadPropertyFunc(Ctrl, "ClassName"))
	EnsureControlIcon ClassName
	Dim As TreeNode Ptr tn = ParentNode->Nodes.Add(CtrlName & " (" & ClassName & ")", , , ClassName, ClassName)
	Dim As ControlTreeElement Ptr cte = _New(ControlTreeElement)
	cte->Ctrl = Ctrl
	cte->pTb = tb
	tn->Tag = cte
	If Des->Controls.Contains(Ctrl) Then
		Dim As Integer Ptr pCount = st->ReadPropertyFunc(Ctrl, "ControlCount")
		If pCount <> 0 AndAlso st->ControlByIndexFunc <> 0 Then
			For i As Integer = 0 To *pCount - 1
				AddControlTreeNode tn, Des, tb, st->ControlByIndexFunc(Ctrl, i)
			Next
		End If
	End If
End Sub

Sub ExpandFormControls(ByRef Item As TreeNode)
	ClearTreeNode @Item
	Dim As TabWindow Ptr tb = FindOpenTabWindowForNode(@Item)
	If tb = 0 OrElse tb->Des = 0 Then
		Item.Nodes.Add ("(Open the form to view its controls)")
		Exit Sub
	End If
	Dim As My.Sys.Forms.Designer Ptr Des = tb->Des
	Dim As Any Ptr FormCtrl = Des->DesignControl
	Dim As SymbolsType Ptr st = Des->SymbolsReadProperty(FormCtrl)
	If CInt(FormCtrl <> 0) AndAlso CInt(st <> 0) AndAlso CInt(Des->Controls.Contains(FormCtrl)) Then
		Dim As Integer Ptr pCount = st->ReadPropertyFunc(FormCtrl, "ControlCount")
		If pCount <> 0 AndAlso st->ControlByIndexFunc <> 0 Then
			For i As Integer = 0 To *pCount - 1
				AddControlTreeNode @Item, Des, tb, st->ControlByIndexFunc(FormCtrl, i)
			Next
		End If
	End If
	If Item.Nodes.Count = 0 Then Item.Nodes.Add ("(No controls)")
End Sub

Sub SelectControlTreeNode(cte As ControlTreeElement Ptr)
	If cte = 0 OrElse cte->Ctrl = 0 OrElse cte->pTb = 0 Then Exit Sub
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, cte->pTb)
	If tb->Des = 0 Then Exit Sub
	Dim As Any Ptr Ctrl = cte->Ctrl
	Dim As SymbolsType Ptr st = tb->Des->SymbolsReadProperty(Ctrl)
	If st = 0 Then Exit Sub
	If Not tb->IsSelected Then tb->SelectTab
	If tb->CurrentView() = "Code" Then
		tb->ShowView("CodeAndForm")
	End If
	RevealAncestorPanels tb->Des, Ctrl
	Dim As Any Ptr iParentCtrl = tb->Des->GetParentControl(Ctrl)
	If iParentCtrl <> 0 Then tb->Des->BringToFront iParentCtrl
	If Not tb->Des->SelectedControls.Contains(Ctrl) Then tb->Des->SelectedControls.Clear
	tb->Des->SelectedControl = Ctrl
	Dim As Any Ptr hw = st->ReadPropertyFunc(Ctrl, "Handle")
	If hw <> 0 Then tb->Des->MoveDots(Ctrl, False) Else tb->Des->MoveDots(0, False)
	DesignerChangeSelection *tb->Des, Ctrl
End Sub

Function AddFolder(ByRef FolderName As WString) As TreeNode Ptr
	Dim As TreeNode Ptr tn
	If FolderName <> "" Then
		AddMRUFolder FolderName
		Dim As Integer Pos1
		For i As Integer = 0 To tvExplorer.Nodes.Count - 1
			If tvExplorer.Nodes.Item(i)->Tag <> 0 AndAlso EqualPaths(*Cast(ExplorerElement Ptr, tvExplorer.Nodes.Item(i)->Tag)->FileName, FolderName) Then
				tvExplorer.Nodes.Item(i)->SelectItem
				Return tvExplorer.Nodes.Item(i)
			End If
		Next
		Dim As String IconName
		If FileExists(FolderName & WindowsSlash & GetFileName(FolderName) & ".vfp") Then
			IconName = "Opened"
			tn = tvExplorer.Nodes.Add(GetFileName(FolderName), , FolderName, IconName, IconName)
			AddProject FolderName & WindowsSlash & GetFileName(FolderName) & ".vfp", , tn
			WLet(Cast(ExplorerElement Ptr, tn->Tag)->FileName, FolderName)
			If MainNode = 0 Then SetMainNode tn
		Else
			IconName = "Opened"
			tn = tvExplorer.Nodes.Add(GetFileName(FolderName), , FolderName, IconName, IconName)
			Dim As ExplorerElement Ptr ee
			ee = _New( ExplorerElement)
			WLet(ee->FileName, FolderName)
			tn->Tag = ee
		End If
		ExpandFolder tn
		tn->Expand
	End If
	Return tn
End Function

Function PrepareForAnotherProjectU(NewProjectPath As UString) As Boolean
	Dim As WString Ptr pathPtr
	WLet(pathPtr, NewProjectPath)
	Dim As Boolean result = PrepareForAnotherProject(*pathPtr)
	WDeAllocate(pathPtr)
	Return result
End Function

Function AddFolderU(FolderName As UString) As TreeNode Ptr
	Dim As WString Ptr pathPtr
	WLet(pathPtr, FolderName)
	Dim As TreeNode Ptr tn = AddFolder(*pathPtr)
	WDeAllocate(pathPtr)
	Return tn
End Function

Sub OpenFilesU(FileName As UString)
	Dim As WString Ptr pathPtr
	WLet(pathPtr, FileName)
	OpenFiles *pathPtr
	WDeAllocate(pathPtr)
End Sub

Sub AddNewU(Template As UString)
	Dim As WString Ptr pathPtr
	WLet(pathPtr, Template)
	AddNew *pathPtr
	WDeAllocate(pathPtr)
End Sub

Function IfNegative(Value As Integer, NonNegative As Integer) As Integer
	If Value < 0 Then
		Return NonNegative
	Else
		Return Value
	End If
End Function

Dim Shared As PointerList Threads
Sub ThreadCounter(Id As Any Ptr)
	Threads.Add Id
End Sub

Function AddProject(ByRef FileName As WString, pFilesList As WStringList Ptr, tn1 As TreeNode Ptr, bNew As Boolean) As TreeNode Ptr
	Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr tn, tn3
	Dim As Boolean inFolder = tn1 <> 0
	If inFolder Then
		tn = tn1
	Else
		If FileName <> "" AndAlso Not bNew Then
			If Not FileExists(FileName) Then
				'' During workspace reload, silently skip a project whose file no longer
				'' exists (deleted/moved since last session) instead of blocking startup
				'' with a modal for something the user isn't actively opening.
				If Not mApplyingWorkspaceLoad Then MsgBox ("File not found") & ":" & WChr(13, 10) & WChr(13, 10) & FormatMsgPath(FileName)
				'' A project that no longer exists must not linger in the recent lists or
				'' stay the remembered "last project" -- otherwise every launch keeps
				'' pointing at something that can never be opened again.
				If *RecentProject <> "" AndAlso EqualPaths(*RecentProject, FileName) Then WLet(RecentProject, "")
				If *RecentFiles <> "" AndAlso EqualPaths(*RecentFiles, FileName) Then WLet(RecentFiles, "")
				PruneMissingMRUProjects()
				Return tn
			End If
			AddMRUProject FileName
			'Dim As WString Ptr buff '
			Dim As Integer Pos1
			For i As Integer = 0 To tvExplorer.Nodes.Count - 1
				If tvExplorer.Nodes.Item(i)->Tag <> 0 AndAlso EqualPaths(*Cast(ExplorerElement Ptr, tvExplorer.Nodes.Item(i)->Tag)->FileName, FileName) Then
					tvExplorer.Nodes.Item(i)->SelectItem
					Return tvExplorer.Nodes.Item(i)
				End If
			Next
			Dim Buff As WString * 1024 ' for V1.07 Line Input not working fine
			Dim As Integer Fn = FreeFile_
			Dim Result As Integer = -1
			Result = Open(FileName For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input As #Fn)
			If Result = 0 Then
				Do Until EOF(Fn)
					Line Input #Fn, Buff
					If InStr(LCase(Buff), "openprojectasfolder") > 0 AndAlso InStr(LCase(Buff), "true") > 0 Then
						Return AddFolder(GetFolderName(FileName, False))
					End If
				Loop
			End If
			CloseFile_(Fn)
			tn = tvExplorer.Nodes.Add(GetFileName(FileName), , FileName, "Project", "Project")
		Else
			Var n = 0
			Dim As String ProjectName = "Project"
			Dim NewName As String
			Do
				n = n + 1
				NewName = ProjectName & Str(n)
			Loop While tvExplorer.Nodes.Contains(NewName) OrElse tvExplorer.Nodes.Contains(NewName & "*")
			tn = tvExplorer.Nodes.Add(NewName & "*", , , "Project", "Project")
		End If
		'If tn <> 0 Then
		If ShowProjectFolders Then
			tn->Nodes.Add ("Includes"), "Includes", , "Opened", "Opened"
			tn->Nodes.Add ("Forms"), "Forms", , "Opened", "Opened"
			tn->Nodes.Add ("Modules"), "Modules", , "Opened", "Opened"  '.  Using "Modules" is better than "Sources"
			tn->Nodes.Add ("Resources"), "Resources", , "Opened", "Opened"
			tn->Nodes.Add ("Others"), "Others", , "Opened", "Opened"
			'End if
		End If
	End If
	If FileName <> "" Then
		Dim As TreeNode Ptr tn1, tn2
		'Dim buff As WString Ptr '
		Dim Pos1 As Integer
		Dim bMain As Boolean
		Dim As ProjectElement Ptr ppe
		Dim As WStringList Files
		Dim As WStringList Ptr pFiles
		ppe = _New( ProjectElement)
		If bNew Then
			WLet(ppe->FileName, Left(tn->Text, Len(tn->Text) - 1))
			WLet(ppe->TemplateFileName, FileName)
		Else
			WLet(ppe->FileName, FileName)
		End If
		If inFolder Then ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Else ppe->ProjectFolderType = IIf(ShowProjectFolders, 0, 1)
		tn->Tag = ppe
		If pFilesList = 0 Then pFiles = @Files Else pFiles = pFilesList
		Dim As String Parameter
		Dim As String IconName
		Dim As String ZvFile
		If bNew Then ZvFile = "*" Else ZvFile = ""
		Dim Buff As WString * 1024 ' for V1.07 Line Input not working fine
		Dim As Integer Fn = FreeFile_
		Dim Result As Integer = -1
		Result = Open(FileName For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn)
		If Result = 0 Then
			Do Until EOF(Fn)
				Line Input #Fn, Buff
				Pos1 = InStr(Buff, "=")
				If Pos1 <> 0 Then
					Parameter = Left(Buff, Pos1 - 1)
				Else
					Parameter = ""
				End If
				If Parameter = "File" OrElse Parameter = "*File" Then
					bMain = StartsWith(Buff, "*")
					Buff = Trim(Mid(Buff, Pos1+1 ))
					If Not inFolder Then
						tn1 = GetTreeNodeChild(tn, Buff)
					End If
					Dim As Boolean bFileCreated = True
					If bNew Then
						'' New-project scaffolding: prompt for a real name up front (same
						'' custom dialog AddFromTemplate uses) and stage the file under
						'' Temp/ instead of leaving it purely in-memory with a bare,
						'' unresolved name -- see CreatePendingProjectFile. Cancelling
						'' just skips this file (no node, no disk file) rather than
						'' aborting the whole new-project creation.
						Dim As UString TemplateSrc
						If CInt(InStr(Buff, ":") = 0) OrElse CInt(StartsWith(Buff, "/")) Then
							TemplateSrc = GetFolderName(FileName) & Replace(Buff, "/", "\")
						Else
							TemplateSrc = Buff
						End If
						tn2 = CreatePendingProjectFile(TemplateSrc, GetFileName(TemplateSrc, False), IIf(inFolder, tn, tn1), False)
						bFileCreated = (tn2 <> 0)
						If bFileCreated Then ee = Cast(ExplorerElement Ptr, tn2->Tag)
					Else
						ee = _New( ExplorerElement)
						If CInt(InStr(Buff, ":") = 0) OrElse CInt(StartsWith(Buff, "/")) Then
								WLet(ee->FileName, GetFolderName(FileName) & Replace(Buff, "/", "\"))
						Else
							WLet(ee->FileName, Buff)
						End If
					End If
					If bFileCreated Then
						Dim As Boolean FileEx = CInt(FileExists(*ee->FileName)) OrElse CInt(bNew)
						If bMain Then
							If EndsWith(LCase(*ee->FileName), ".rc") OrElse EndsWith(LCase(*ee->FileName), ".res") Then  ' Then
								WLet(ppe->ResourceFileName, *ee->FileName)
							ElseIf EndsWith(LCase(*ee->FileName), ".xpm") Then
								WLet(ppe->IconResourceFileName, *ee->FileName)
							ElseIf LCase(GetFileName(*ee->FileName)) = "makefile" Then
								If WGet(ppe->BatchCompilationFileNameWindows) = "" Then WLet(ppe->BatchCompilationFileNameWindows, *ee->FileName)
								If WGet(ppe->BatchCompilationFileNameLinux) = "" Then WLet(ppe->BatchCompilationFileNameLinux, *ee->FileName)
							ElseIf EndsWith(LCase(*ee->FileName), ".bat") Then
								WLet(ppe->BatchCompilationFileNameWindows, *ee->FileName)
							ElseIf EndsWith(LCase(*ee->FileName), ".sh") OrElse InStr(*ee->FileName, ".") = 0 Then
								WLet(ppe->BatchCompilationFileNameLinux, *ee->FileName)
							Else
								WLet(ppe->MainFileName, *ee->FileName)
							End If
						End If
						IconName = GetIconName(*ee->FileName, ppe)
						If Not FileEx Then IconName = "New"
						If Not inFolder Then
							If bNew Then
								'' Node + ExplorerElement already created by
								'' CreatePendingProjectFile -- just refresh the icon now
								'' that bMain-based ppe fields (e.g. MainRes) are known.
								tn2->ImageKey = IconName
								tn2->SelectedImageKey = IconName
							Else
								tn2 = tn1->Nodes.Add(GetFileName(*ee->FileName) & ZvFile,, *ee->FileName, IconName, IconName, True)
							End If
							If IconName = "Form" Then tn2->Nodes.Add ""
							If bMain Then
								If MainNode = 0 Then SetMainNode GetParentNode(tn1)
								If bNew AndAlso IconName <> "MainRes" Then
									Dim As TabWindow Ptr tbNew = AddTab(*ee->FileName, True, tn2)
									'' See CreatePendingProjectFile's matching comment: AddTab's
									'' bNew=True path sets .FileName from the tree node's text
									'' (no folder), not the path just loaded -- override it back.
									If tbNew <> 0 Then tbNew->FileName = *ee->FileName
									tn2->SelectItem
								End If
							End If
						End If
						If EndsWith(LCase(*ee->FileName), ".bas") OrElse EndsWith(LCase(*ee->FileName), ".frm") OrElse EndsWith(LCase(*ee->FileName), ".bi") OrElse EndsWith(LCase(*ee->FileName), ".inc") Then
							pFiles->Add *ee->FileName, ppe
							If Not LoadPaths.Contains(*ee->FileName) Then LoadPaths.Add *ee->FileName
							ThreadCounter(ThreadCreate_(@LoadOnlyFilePath, @LoadPaths.Item(LoadPaths.IndexOf(*ee->FileName))))
						End If
						ppe->Files_.Add *ee->FileName
						If inFolder Then
							ppe->Files.Add *ee->FileName
							If Not bNew Then _Delete( ee)
						ElseIf Not bNew Then
							tn2->Tag = ee
						End If
						If bNew Then tn1->Expand
					End If
				ElseIf Parameter = "ProjectType" Then
					ppe->ProjectType = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "Subsystem" Then
					ppe->Subsystem = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "ProjectName" Then
					WLet(ppe->ProjectName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "HelpFileName" Then
					WLet(ppe->HelpFileName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "ProjectDescription" Then
					WLet(ppe->ProjectDescription, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "PassAllModuleFilesToCompiler" Then
					ppe->PassAllModuleFilesToCompiler = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "OpenProjectAsFolder" Then
					ppe->OpenProjectAsFolder = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "MajorVersion" Then
					ppe->MajorVersion = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "MinorVersion" Then
					ppe->MinorVersion = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "RevisionVersion" Then
					ppe->RevisionVersion = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "BuildVersion" Then
					ppe->BuildVersion = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "AutoIncrementVersion" Then
					ppe->AutoIncrementVersion = IIf(bNew, AutoIncrement, CBool(Mid(Buff, Pos1 + 1)))
				ElseIf Parameter = "ApplicationTitle" Then
					WLet(ppe->ApplicationTitle, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "ApplicationIcon" Then
					WLet(ppe->ApplicationIcon, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "Manifest" Then
					ppe->Manifest = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "RunAsAdministrator" Then
					ppe->RunAsAdministrator = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "CompanyName" Then
					WLet(ppe->CompanyName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "FileDescription" Then
					WLet(ppe->FileDescription, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "InternalName" Then
					WLet(ppe->InternalName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "LegalCopyright" Then
					WLet(ppe->LegalCopyright, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "LegalTrademarks" Then
					WLet(ppe->LegalTrademarks, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "OriginalFilename" Then
					WLet(ppe->OriginalFilename, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "ProductName" Then
					WLet(ppe->ProductName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompileMode" Then
					ppe->CompileMode = Cast(CompileModeVariants, Val(Mid(Buff, Pos1 + 1)))
				ElseIf Parameter = "CompilationArguments64Windows" Then
					WLet(ppe->CompilationArguments64Windows, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompilationArguments64Linux" Then
					WLet(ppe->CompilationArguments64Linux, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				' Win64-only fork: kept because .vfp backward compatibility (no IDE UI)
				ElseIf Parameter = "CompilationArguments32Windows" Then
					WLet(ppe->CompilationArguments32Windows, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompilationArguments32Linux" Then
					WLet(ppe->CompilationArguments32Linux, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompilerPath" Then
					WLet(ppe->CompilerPath, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CommandLineArguments" Then
					WLet(ppe->CommandLineArguments, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				' Win64-only fork: kept because .vfp backward compatibility (no IDE UI)
				ElseIf Parameter = "AndroidSDKLocation" Then
					WLet(ppe->AndroidSDKLocation, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "AndroidNDKLocation" Then
					WLet(ppe->AndroidNDKLocation, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "JDKLocation" Then
					WLet(ppe->JDKLocation, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "Author" Then
					WLet(ppe->Author, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "License" Then
					WLet(ppe->License, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "Description" Then
					WLet(ppe->Description, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "UseGit" Then
					ppe->UseGit = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "GitProvider" Then
					WLet(ppe->GitProvider, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "GitUserName" Then
					WLet(ppe->GitUserName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "GitEmail" Then
					WLet(ppe->GitEmail, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "GitURL" Then
					WLet(ppe->GitURL, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "AIFriendly" Then
					ppe->AIFriendly = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "AITool" Then
					WLet(ppe->AITool, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "IncludePath" Then
					ppe->IncludePaths.Add Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "LibraryPath" Then
					ppe->LibraryPaths.Add Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "ControlLibrary" Then
					Dim As Library Ptr CtlLibrary
					Dim As Boolean bFinded, bChanged
					Dim As UString LibraryPath = Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
					Dim As UString LibraryVfpPath = GetControlLibraryVfpPath(LibraryPath)
					Dim As UString LibraryFolder = GetControlLibraryFolder(LibraryPath)
					If LibraryVfpPath = "" OrElse LibraryFolder = "" Then
						MsgBox ("Control library must be in the editor Controls folder.") & ":" & WChr(13, 10) & WChr(13, 10) & FormatMsgPathU(LibraryPath), , mtWarning
					Else
						ppe->Components.Add LibraryVfpPath
						For i As Integer = 0 To ControlLibraries.Count - 1
							CtlLibrary = ControlLibraries.Item(i)
							If GetControlLibraryVfpPath(CtlLibrary->Path) = LibraryVfpPath Then
								bFinded = True
								Exit For
							End If
						Next
						If bFinded Then
							If Not CtlLibrary->Enabled Then
								CtlLibrary->Enabled = True
								LoadToolBox CtlLibrary
								bChanged = True
							End If
						Else
							Dim LibKey As String = "Lib64"
							Dim As IniFile ini
							ini.Load LibraryFolder & WindowsSlash & "Settings.ini"
							Var CtlLibrary = _New(Library)
							CtlLibrary->Name = ini.ReadString("Setup", "Name")
							CtlLibrary->Tips = ini.ReadString("Setup", "Tips")
							CtlLibrary->Path = WinOsPath(GetFullPath(LibraryFolder & WindowsSlash & ini.ReadString("Setup", LibKey, " "), ""))
							CtlLibrary->HeadersFolder = ini.ReadString("Setup", "HeadersFolder")
							CtlLibrary->SourcesFolder = ini.ReadString("Setup", "SourcesFolder")
							CtlLibrary->IncludeFolder = GetFullPath(GetFullPath(ini.ReadString("Setup", "IncludeFolder"), CtlLibrary->Path))
							CtlLibrary->Enabled = True
							ControlLibraries.Add CtlLibrary
							LoadToolBox CtlLibrary
							bChanged = True
						End If
						If bChanged Then
							pnlToolBox.RequestAlign
							pnlToolBox_Resize *pnlToolBox.Designer, pnlToolBox, pnlToolBox.Width, pnlToolBox.Height
							pnlToolBox.RequestAlign
						End If
					End If
				End If
			Loop
		End If
		CloseFile_(Fn)
		If pFilesList = 0 Then
			For i As Integer = 0 To pFiles->Count - 1
				ThreadCounter(ThreadCreate_(@LoadOnlyIncludeFiles, @LoadPaths.Item(LoadPaths.IndexOf(pFiles->Item(i)))))
			Next
			If ProjectAutoSuggestions Then
				For i As Integer = 0 To pFiles->Count - 1
					Var ecc = _New(EditControlContent)
					ecc->FileName = pFiles->Item(i)
					ecc->Globals = @Cast(ProjectElement Ptr, pFiles->Object(i))->Globals
					ecc->Tag = pFiles->Object(i)
					Cast(ProjectElement Ptr, pFiles->Object(i))->Contents.Add ecc
					If Not LoadPaths.Contains(pFiles->Item(i)) Then LoadPaths.Add pFiles->Item(i)
					ThreadCounter(ThreadCreate_(@LoadOnlyFilePathOverwriteWithContent, ecc))
				Next
			End If
		End If
	End If
	If Not inFolder Then
		tn->Expand
	End If
	EnsureChangeLogTreeNode(tn)
	'pfProjectProperties->RefreshProperties
	tn->SelectItem
	Return tn
End Function

Sub OpenFolder()
	Dim As FolderBrowserDialog BrowseD
	BrowseD.InitialDir = GetFullPath(*ProjectsPath)
	If Not BrowseD.Execute Then Exit Sub
	AddFolder BrowseD.Directory
	WLet(RecentFolder, BrowseD.Directory)
	tpProject->SelectTab
End Sub

Sub OpenProject()
	Dim fOpenProject As frmOpenProject
	pfOpenProject = @fOpenProject
	If pfOpenProject->ShowModal(frmMain) = ModalResults.OK Then
		If pfOpenProject->SelectedFile <> "" Then
			OpenFiles pfOpenProject->SelectedFile
			tpProject->SelectTab
		End If
	End If
	' "Open New Project" button on the Open Project dialog: it closed with Cancel + this flag;
	' now bring up the New Project window instead.
	If pfOpenProject->OpenNewRequested Then NewProject()
End Sub

Sub OpenRecentProject()
	Dim fRecentProjects As frmRecentProjects
	pfRecentProjects = @fRecentProjects
	If pfRecentProjects->ShowModal(frmMain) = ModalResults.OK Then
		If pfRecentProjects->SelectedFile <> "" Then
			OpenFiles pfRecentProjects->SelectedFile
		End If
	End If
End Sub

Sub NewFile()
	If GetOpenProjectNode() = 0 Then
		MsgBox ("Open a project first."), , mtWarning
		Return
	End If
	Dim fNewFile As frmNewFile
	pfNewFile = @fNewFile
	If pfNewFile->ShowModal(frmMain) = ModalResults.OK Then
		If pfNewFile->SelectedTemplate <> "" AndAlso pfNewFile->SelectedName <> "" Then
			Dim As WString Ptr templatePtr
			Dim As WString Ptr namePtr
			WLet(templatePtr, pfNewFile->SelectedTemplate)
			WLet(namePtr, pfNewFile->SelectedName)
			AddNewProjectFile *templatePtr, *namePtr
			WDeAllocate(templatePtr)
			WDeAllocate(namePtr)
		End If
	End If
End Sub

Sub OpenEditorFile()
	If GetOpenProjectNode() = 0 Then
		MsgBox ("Open a project first."), , mtWarning
		Return
	End If
	Dim fOpenProjectFile As frmOpenProjectFile
	pfOpenProjectFile = @fOpenProjectFile
	If pfOpenProjectFile->ShowModal(frmMain) = ModalResults.OK Then
		If pfOpenProjectFile->SelectedFile <> "" Then
			Dim As WString Ptr filePtr
			WLet(filePtr, pfOpenProjectFile->SelectedFile)
			OpenFiles *filePtr
			WDeAllocate(filePtr)
		End If
	End If
	tpProject->SelectTab
End Sub

Sub CloseEditorFile()
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb <> 0 Then CloseTab(tb)
End Sub

Sub DeleteEditorFile()
	'' 13.3.A S5: was a total no-op stub (TODO comment only). Unified 2026-07-08 with the
	'' tree's right-click "Delete File" (previously a separate, disk-immediate "Remove"
	'' that only detached from the project without deleting) -- both now call this Sub,
	'' operating on the tree selection rather than requiring an open tab, so a project
	'' member can be deleted whether or not it's currently open.
	Dim As TreeNode Ptr tn = tvExplorer.SelectedNode
	If tn = 0 Then Exit Sub
	'' Safety: the tree's "Remove"/"Delete File" item is also enabled when the PROJECT
	'' root itself is selected (previously routed to CloseProject via the now-removed
	'' RemoveFileFromProject). Keep that behavior rather than treating the project's own
	'' .vfp as a plain file to delete -- Delete Project already exists as its own,
	'' properly-confirmed command for actually removing a project.
	If tn->ImageKey = "Project" OrElse tn->ImageKey = "MainProject" Then
		CloseProject tn
		Exit Sub
	End If
	Dim As ExplorerElement Ptr ee = tn->Tag
	If ee = 0 OrElse ee->PendingDelete Then Exit Sub '' already queued -- see "Cancel Deletion"
	Dim As WString * 1024 sFilePath = WGet(ee->FileName)
	Dim As Boolean bNestedInProject = (tn->ParentNode <> 0)
	'' Capture the owning PROJECT node (not just the immediate parent, which may be a
	'' subfolder category like "Forms") before Remove can invalidate tn, so the project
	'' can be flagged dirty afterward -- same "*" convention AddProject already uses for
	'' "this project has unsaved changes".
	Dim As TreeNode Ptr ptnProject = 0
	If bNestedInProject Then ptnProject = GetParentNode(tn)
	If MsgBox(("Are you sure you want to delete the file") & " """ & GetFileName(sFilePath) & """?", "Astoria IDE", mtWarning, btYesNo) <> mrYes Then Exit Sub
	'' Close this file's tab if it happens to be open in any panel; unlike the old
	'' active-tab-only version, it's fine if there is none.
	Dim tb As TabWindow Ptr
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCodeLocal = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCodeLocal->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCodeLocal->Tabs[i])
			If tb->tn = tn Then
				If Not CloseTab(tb, True) Then Exit Sub
				Exit For
			End If
		Next i
	Next j
	If bNestedInProject Then
		'' B1: a project-member file isn't actually removed from disk (or the tree) until
		'' the project is saved (SaveProject scans for ee->PendingDelete) -- so abandoning
		'' changes (closing without saving) leaves everything exactly as before, instead
		'' of the project reopening with a "File not found" for something the owner never
		'' actually chose to keep deleted. The node stays visible so a right-click offers
		'' "Cancel Deletion" to undo it before save.
		ee->PendingDelete = True
		tn->Text = GetFileName(sFilePath) & " " & ("(pending delete)")
		If ptnProject <> 0 AndAlso Not EndsWith(ptnProject->Text, "*") Then ptnProject->Text &= "*"
	Else
		'' Loose/"Opened" files aren't part of a project's save cycle, so those still
		'' delete immediately -- there's no "save" moment to defer to.
		If tn->ParentNode <> 0 AndAlso tn->ParentNode->Nodes.IndexOf(tn) <> -1 Then
			tn->ParentNode->Nodes.Remove tn->ParentNode->Nodes.IndexOf(tn)
		End If
		If sFilePath <> "" AndAlso Dir(sFilePath) <> "" Then Kill sFilePath
	End If
End Sub

Sub CancelFileDeletion()
	Dim As TreeNode Ptr tn = tvExplorer.SelectedNode
	If tn = 0 Then Exit Sub
	Dim As ExplorerElement Ptr ee = tn->Tag
	If ee = 0 OrElse Not ee->PendingDelete Then Exit Sub
	ee->PendingDelete = False
	tn->Text = GetFileName(WGet(ee->FileName))
End Sub

Sub SaveEditorFile()
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb <> 0 Then tb->Save
End Sub

Sub SaveEditorFileAs()
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb <> 0 Then
		tb->SaveAs
		frmMain.Caption = tb->FileName & " - " & App.Title
	End If
End Sub

Sub OpenUrl(ByRef url As WString)
	'' ShellExecuteW's "open" verb instead of shelling out through cmd /c
	'' start /b <url> -- cmd splits on "&" (common in query strings), and
	'' PipeCmd's old blanket wrapper also piped output to the clipboard.
	'' See PROJECT_STATUS Fable review remediation, T3 / finding F-S5.
	ShellExecuteW(0, WStr("open"), url, 0, 0, SW_SHOWNORMAL)
End Sub

Function GetOpenProjectNode() As TreeNode Ptr
	For i As Integer = 0 To tvExplorer.Nodes.Count - 1
		Var tn = tvExplorer.Nodes.Item(i)
		If CInt(tn->ImageKey = "Project") OrElse CInt(tn->ImageKey = "MainProject") Then Return tn
	Next
	Return 0
End Function

Function GetProjectDirectory() As UString
	Dim tnP As TreeNode Ptr = GetOpenProjectNode()
	If tnP = 0 OrElse tnP->Tag = 0 Then Return ""
	Dim ppe As ProjectElement Ptr = Cast(ProjectElement Ptr, tnP->Tag)
	If ppe = 0 Then Return ""
	Return GetFolderNameU(WGet(ppe->FileName))
End Function

'' Absolute path to the open project's project.astoria file, or "" if no project is
'' open. The trailing separator from GetProjectDirectory is stripped first so the path
'' matches the single-separator form the create flow writes on disk -- otherwise
'' ProjectDescriptionPath would emit "...MyProj\\project.astoria", which still resolves
'' but wouldn't string-match an already-open tab in GetTab.
Function OpenProjectDescriptionPath() As UString
	Dim As UString descDir = GetProjectDirectory()
	If descDir = "" Then Return ""
	If Right(descDir, 1) = "\" OrElse Right(descDir, 1) = "/" Then descDir = Left(descDir, Len(descDir) - 1)
	Return ProjectDescriptionPath(descDir)
End Function

'' Substitute the six {{...}} tokens in one template file's bytes and write the result.
'' Byte-based (templates are plain ASCII/UTF-8; markers are ASCII). Shared copy of
'' frmNewProject's StampTemplateFile so the Edit Project Description dialog can stamp too.
Private Sub AiStampFile(ByRef srcFile As UString, ByRef destFile As UString, ByRef projectName As String, ByRef author As String, ByRef license As String, ByRef description As String)
	Dim As Integer FnIn = FreeFile_
	If Open(srcFile For Binary Access Read As #FnIn) <> 0 Then Exit Sub
	Dim As Integer sz = LOF(FnIn)
	Dim As String contents = String(sz, 0)
	If sz > 0 Then Get #FnIn, 1, contents
	CloseFile_(FnIn)
	Dim As String au = Trim(author)
	If au = "" Then au = "the author"
	contents = Replace(contents, "{{PROJECT}}", projectName)
	contents = Replace(contents, "{{AUTHOR}}", au)
	contents = Replace(contents, "{{YEAR}}", Format(Now, "yyyy"))
	contents = Replace(contents, "{{DATE}}", Format(Now, "yyyy-mm-dd"))
	contents = Replace(contents, "{{LICENSE}}", license)
	contents = Replace(contents, "{{DESCRIPTION}}", description)
	Dim As Integer FnOut = FreeFile_
	If Open(destFile For Binary Access Write As #FnOut) = 0 Then
		If Len(contents) > 0 Then Put #FnOut, 1, contents
		CloseFile_(FnOut)
	End If
End Sub

'' Recursively copy srcFolder into destFolder, stamping each file; skip .gitkeep.
'' Drains each directory before recursing (Dir keeps one search handle).
Private Sub AiCopyTree(ByRef srcFolder As UString, ByRef destFolder As UString, ByRef projectName As String, ByRef author As String, ByRef license As String, ByRef description As String)
	If Not EnsureDirectoryExists(destFolder) Then Exit Sub
	Dim As WStringList names
	Dim As UInteger attr
	Dim As String f = Dir(srcFolder & WindowsSlash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, attr)
	Do While f <> ""
		If f <> "." AndAlso f <> ".." AndAlso f <> ".gitkeep" Then names.Add f
		f = Dir(attr)
	Loop
	For i As Integer = 0 To names.Count - 1
		Dim As UString itemName = names.Item(i)
		Dim As UString srcItem = srcFolder & WindowsSlash & itemName
		Dim As UString destItem = destFolder & WindowsSlash & itemName
		If FolderExistsU(srcItem) Then
			AiCopyTree(srcItem, destItem, projectName, author, license, description)
		Else
			AiStampFile(srcItem, destItem, projectName, author, license, description)
		End If
	Next i
End Sub

'' Stamp Templates/AI/<toolFolder>/ into destFolder with token substitution. Public so the
'' Edit Project Description dialog can enable AI-friendliness on an existing project.
Sub StampAiTemplateInto(ByRef destFolder As UString, ByRef toolFolder As UString, ByRef projectName As String, ByRef author As String, ByRef license As String, ByRef description As String)
	If Trim(toolFolder) = "" Then Exit Sub
	Dim As UString srcFolder = WinOsPath(ExePath & "/Templates/AI/" & toolFolder)
	If Not FolderExistsU(srcFolder) Then Exit Sub
	AiCopyTree(srcFolder, destFolder, projectName, author, license, description)
End Sub

'' Update the flat Key="value" metadata lines in a .vfp so they mirror project.astoria after
'' an edit. Rewrites only the given keys (adds a key if absent); every other line passes
'' through untouched. Values are wrapped in quotes like the New Project writer does.
Sub UpdateVfpMetadataKeys(ByRef vfpPath As UString, ByRef d As ProjectDescriptionData)
	If vfpPath = "" OrElse Not FileExistsU(vfpPath) Then Exit Sub
	'' key -> value (quoted)
	Dim As String aiText = "false"
	If d.AIFriendly Then aiText = "true"
	Dim As String descEnc = d.Description
	descEnc = Replace(descEnc, Chr(13) & Chr(10), "\n")
	descEnc = Replace(descEnc, Chr(10), "\n")
	Dim keyNames(0 To 4) As String = {"Author", "License", "Description", "AIFriendly", "AITool"}
	Dim keyVals(0 To 4) As String = {Chr(34) & d.Author & Chr(34), Chr(34) & d.License & Chr(34), Chr(34) & descEnc & Chr(34), aiText, Chr(34) & d.AITool & Chr(34)}
	'' Read all lines.
	Dim As WStringList lines
	Dim As Integer FnIn = FreeFile_
	Dim As Integer r = Open(vfpPath For Input Encoding "utf-8" As #FnIn)
	If r <> 0 Then r = Open(vfpPath For Input As #FnIn)
	If r <> 0 Then Exit Sub
	Dim As WString * 4096 ln
	Do Until EOF(FnIn)
		Line Input #FnIn, ln
		lines.Add ln
	Loop
	CloseFile_(FnIn)
	'' Rewrite matching keys in place; track which were seen.
	Dim seen(0 To 4) As Boolean
	For i As Integer = 0 To lines.Count - 1
		Dim As UString cur = lines.Item(i)
		For k As Integer = 0 To 4
			If StartsWith(cur, keyNames(k) & "=") Then
				lines.Item(i) = keyNames(k) & "=" & keyVals(k)
				seen(k) = True
				Exit For
			End If
		Next k
	Next i
	For k As Integer = 0 To 4
		If Not seen(k) Then lines.Add keyNames(k) & "=" & keyVals(k)
	Next k
	Dim As Integer FnOut = FreeFile_
	If Open(vfpPath For Output Encoding "utf-8" As #FnOut) <> 0 Then Exit Sub
	For i As Integer = 0 To lines.Count - 1
		Print #FnOut, lines.Item(i)
	Next i
	CloseFile_(FnOut)
End Sub

'' Project menu > Edit Project Description: open the structured dialog for the open
'' project's project.astoria (read-only for immutable/risky fields, editable metadata).
'' Enabled only when the file exists (ChangeMenuItemsEnabled); re-checked here.
Sub EditProjectDescription
	Dim As UString descPath = OpenProjectDescriptionPath()
	If descPath = "" OrElse Not FileExistsU(descPath) Then
		MsgBox ("This project has no project.astoria description file."), , mtWarning
		Exit Sub
	End If
	Dim fEdit As frmEditProjectDescription
	pfEditProjectDescription = @fEdit
	fEdit.ProjectFolder = GetProjectDirectory()
	fEdit.DescPath = descPath
	fEdit.VfpPath = ""
	Dim As TreeNode Ptr tnP = GetOpenProjectNode()
	If tnP <> 0 AndAlso tnP->Tag <> 0 Then fEdit.VfpPath = WGet(Cast(ProjectElement Ptr, tnP->Tag)->FileName)
	fEdit.ShowModal(frmMain)
End Sub

'' Whether the open project's folder is a Git working tree (has a .git entry).
'' Gates the Git menu; selection-independent (tracks the open project).
Function OpenProjectIsGitRepo() As Boolean
	Dim As UString gitDir = GetProjectDirectory()
	If gitDir = "" Then Return False
	Return FolderExistsU(gitDir & ".git")
End Function

'' Run a git subcommand in the open project's folder via a temp .bat (batch-mode
'' SSH, no interactive prompts -- can't hang on a credential/host-key prompt),
'' capturing combined stdout+stderr into OutText and the exit code into ExitCode.
'' Mirrors frmNewProject.CloneGitRepository's plumbing; blocks until git finishes
'' (bounded by ConnectTimeout). Returns True on exit code 0. UI thread.
Private Function RunGitInProject(ByRef GitArgs As String, ByRef OutText As String, ByRef ExitCode As Integer) As Boolean
	OutText = "" : ExitCode = -1
	Dim As UString projDir = GetProjectDirectory()
	If projDir = "" Then Return False
	'' Strip the trailing separator so `cd /d "..."` doesn't end in \" (cmd mis-parse).
	If Right(projDir, 1) = "\" OrElse Right(projDir, 1) = "/" Then projDir = Left(projDir, Len(projDir) - 1)
	EnsureDirectoryExists(ExePath & WindowsSlash & "Temp")
	Dim As UString batPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_op.bat"
	Dim As UString logPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_op.log"
	Dim As UString resultPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_op.result"
	If FileExistsU(logPath) Then Kill logPath
	If FileExistsU(resultPath) Then Kill resultPath
	Dim As Integer Fn = FreeFile_
	If Open(batPath For Output As #Fn) <> 0 Then Return False
	Print #Fn, "@echo off"
	Print #Fn, "set GIT_TERMINAL_PROMPT=0"
	Print #Fn, "set GIT_SSH_COMMAND=ssh -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
	Print #Fn, "cd /d " & Chr(34) & projDir & Chr(34)
	Print #Fn, "git " & GitArgs & " > " & Chr(34) & logPath & Chr(34) & " 2>&1"
	Print #Fn, "echo %errorlevel% > " & Chr(34) & resultPath & Chr(34)
	CloseFile_(Fn)
	PipeCmd batPath, True
	If FileExistsU(resultPath) Then
		Dim As Integer FnR = FreeFile_
		If Open(resultPath For Input As #FnR) = 0 Then
			Dim As String resultLine
			Line Input #FnR, resultLine
			CloseFile_(FnR)
			ExitCode = Val(Trim(resultLine))
		End If
		Kill resultPath
	End If
	If FileExistsU(logPath) Then
		Dim As Integer FnL = FreeFile_
		If Open(logPath For Binary Access Read As #FnL) = 0 Then
			Dim As LongInt sz = LOF(FnL)
			If sz > 0 Then
				OutText = String(sz, 0)
				Get #FnL, 1, OutText
			End If
			CloseFile_(FnL)
		End If
		Kill logPath
	End If
	If FileExistsU(batPath) Then Kill batPath
	Return (ExitCode = 0)
End Function

'' Run an arbitrary command line via a temp .bat, capturing combined stdout+stderr into
'' OutText and the exit code into ExitCode. Like RunGitInProject but not tied to the
'' project folder -- for setup tools (gh/glab). GIT_TERMINAL_PROMPT=0 keeps it from
'' blocking on a prompt. Returns True on exit 0. UI thread.
Private Function RunCmdCaptured(ByRef cmdLine As String, ByRef OutText As String, ByRef ExitCode As Integer) As Boolean
	OutText = "" : ExitCode = -1
	EnsureDirectoryExists(ExePath & WindowsSlash & "Temp")
	Dim As UString batPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_cmd.bat"
	Dim As UString logPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_cmd.log"
	Dim As UString resultPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_cmd.result"
	If FileExistsU(logPath) Then Kill logPath
	If FileExistsU(resultPath) Then Kill resultPath
	Dim As Integer Fn = FreeFile_
	If Open(batPath For Output As #Fn) <> 0 Then Return False
	Print #Fn, "@echo off"
	Print #Fn, "set GIT_TERMINAL_PROMPT=0"
	Print #Fn, cmdLine & " > " & Chr(34) & logPath & Chr(34) & " 2>&1"
	Print #Fn, "echo %errorlevel% > " & Chr(34) & resultPath & Chr(34)
	CloseFile_(Fn)
	PipeCmd batPath, True
	If FileExistsU(resultPath) Then
		Dim As Integer FnR = FreeFile_
		If Open(resultPath For Input As #FnR) = 0 Then
			Dim As String resultLine
			Line Input #FnR, resultLine
			CloseFile_(FnR)
			ExitCode = Val(Trim(resultLine))
		End If
		Kill resultPath
	End If
	If FileExistsU(logPath) Then
		Dim As Integer FnL = FreeFile_
		If Open(logPath For Binary Access Read As #FnL) = 0 Then
			Dim As LongInt sz = LOF(FnL)
			If sz > 0 Then
				OutText = String(sz, 0)
				Get #FnL, 1, OutText
			End If
			CloseFile_(FnL)
		End If
		Kill logPath
	End If
	If FileExistsU(batPath) Then Kill batPath
	Return (ExitCode = 0)
End Function

'' First line of rawOut that contains needle (case-insensitive), trimmed; "" if none.
Private Function GitFindLineContaining(ByRef rawOut As String, ByRef needle As String) As String
	Dim As String low = LCase(needle)
	Dim As Integer p = 1
	While p <= Len(rawOut)
		Dim As Integer nl = InStr(p, rawOut, Chr(10))
		Dim As String ln
		If nl = 0 Then
			ln = Mid(rawOut, p) : p = Len(rawOut) + 1
		Else
			ln = Mid(rawOut, p, nl - p) : p = nl + 1
		End If
		If InStr(LCase(ln), low) > 0 Then Return Trim(ln, Any !" \t" + Chr(13) + Chr(10))
	Wend
	Return ""
End Function

'' Parse git commit's first line "[branch (root-commit)? hash] subject" into its parts.
Private Sub GitParseCommitHeader(ByRef rawOut As String, ByRef branch As String, ByRef hash As String, ByRef subject As String)
	branch = "" : hash = "" : subject = ""
	Dim As Integer lb = InStr(rawOut, "[")
	Dim As Integer rb = InStr(rawOut, "]")
	If lb = 0 OrElse rb <= lb Then Exit Sub
	Dim As String inside = Trim(Mid(rawOut, lb + 1, rb - lb - 1))   '' "branch [(root-commit)] hash"
	Dim As Integer fsp = InStr(inside, " ")
	Dim As Integer lsp = InStrRev(inside, " ")
	If lsp > 0 Then
		hash = Trim(Mid(inside, lsp + 1))
		branch = Trim(Left(inside, fsp - 1))
	Else
		branch = inside
	End If
	Dim As String afterRb = Mid(rawOut, rb + 1)
	Dim As Integer nl = InStr(afterRb, Chr(10))
	If nl > 0 Then afterRb = Left(afterRb, nl - 1)
	subject = Trim(afterRb, Any !" \t" + Chr(13) + Chr(10))
End Sub

'' Turn `git status --porcelain` output ("XY path" per line) into a friendly list
'' ("modified  Foo.bas", "new  Bar.bi", ...) -- what `git add -A` will commit.
Private Function GitFormatStatusList(ByRef rawStatus As String) As UString
	Dim As UString result
	Dim As Integer p = 1
	While p <= Len(rawStatus)
		Dim As Integer nl = InStr(p, rawStatus, Chr(10))
		Dim As String ln
		If nl = 0 Then
			ln = Mid(rawStatus, p) : p = Len(rawStatus) + 1
		Else
			ln = Mid(rawStatus, p, nl - p) : p = nl + 1
		End If
		If Right(ln, 1) = Chr(13) Then ln = Left(ln, Len(ln) - 1)
		If Len(ln) < 4 Then Continue While   '' porcelain: 2 status chars + space + path
		Dim As String code = Left(ln, 2)
		Dim As String path = Trim(Mid(ln, 4))
		Dim As String word = "changed"
		If InStr(code, "?") > 0 Then
			word = "new"
		ElseIf InStr(code, "R") > 0 Then
			word = "renamed"
		ElseIf InStr(code, "D") > 0 Then
			word = "deleted"
		ElseIf InStr(code, "A") > 0 Then
			word = "new"
		ElseIf InStr(code, "M") > 0 Then
			word = "modified"
		End If
		result &= word & "  " & path & Chr(13, 10)
	Wend
	Return result
End Function

'' Show a git operation's result as a short plain-English summary rather than dumping
'' raw git output. op is "commit"/"pull"/"push". Known no-op and failure cases get their
'' own wording; failures still include git's own text (the actionable part). UI thread.
Private Sub ShowGitResult(ByRef op As String, gitOk As Boolean, exitCode As Integer, ByRef rawOut As String)
	Dim As String low = LCase(rawOut)
	Dim As String msg = ""
	Dim As Boolean isErr = False
	Select Case op
	Case "commit"
		If InStr(low, "nothing to commit") > 0 Then
			msg = "Nothing to commit -- there are no changes since the last commit."
		ElseIf Not gitOk Then
			isErr = True
			msg = "Commit failed (exit " & Str(exitCode) & ")." & Chr(10) & Chr(10) & Trim(rawOut)
		Else
			Dim As String branch, hash, subject
			GitParseCommitHeader(rawOut, branch, hash, subject)
			msg = "Committed"
			If branch <> "" Then msg &= " to " & branch
			If hash <> "" Then msg &= " as " & hash
			msg &= "."
			If subject <> "" Then msg &= Chr(10) & Chr(10) & Chr(34) & subject & Chr(34)
			Dim As String stat = GitFindLineContaining(rawOut, "changed")
			If stat <> "" Then msg &= Chr(10) & Chr(10) & stat
		End If
	Case "pull"
		If InStr(low, "already up to date") > 0 Then
			msg = "Already up to date -- nothing to pull."
		ElseIf Not gitOk Then
			isErr = True
			msg = "Pull failed (exit " & Str(exitCode) & ")." & Chr(10) & Chr(10) & Trim(rawOut)
		Else
			msg = "Pulled changes from the remote."
			Dim As String stat = GitFindLineContaining(rawOut, "changed")
			If stat <> "" Then msg &= Chr(10) & Chr(10) & stat
		End If
	Case "push"
		If InStr(low, "up-to-date") > 0 OrElse InStr(low, "up to date") > 0 Then
			msg = "Nothing to push -- the remote is already up to date."
		ElseIf Not gitOk Then
			isErr = True
			msg = "Push failed (exit " & Str(exitCode) & ")." & Chr(10) & Chr(10) & Trim(rawOut)
		Else
			msg = "Pushed your commits to the remote."
		End If
	Case Else
		isErr = Not gitOk
		msg = Trim(rawOut)
	End Select
	If Trim(msg) = "" Then
		If gitOk Then msg = op & " completed." Else msg = op & " failed (exit " & Str(exitCode) & ")."
	End If
	If isErr Then MsgBox msg, , mtWarning Else MsgBox msg, , mtInfo
End Sub

'' Git menu > Git Pull: `git pull` in the open project's folder, with a plain-English
'' result summary. Enabled only for a git-backed project (ChangeMenuItemsEnabled).
Sub GitPull
	If Not OpenProjectIsGitRepo() Then
		MsgBox ("The open project is not a Git repository."), , mtWarning
		Exit Sub
	End If
	Dim As String outText
	Dim As Integer ec
	Dim As Boolean gitOk = RunGitInProject("pull", outText, ec)
	ShowGitResult("pull", gitOk, ec, outText)
End Sub

'' Git menu > Git Push: `git push` in the open project's folder.
Sub GitPush
	If Not OpenProjectIsGitRepo() Then
		MsgBox ("The open project is not a Git repository."), , mtWarning
		Exit Sub
	End If
	Dim As String outText
	Dim As Integer ec
	Dim As Boolean gitOk = RunGitInProject("push", outText, ec)
	ShowGitResult("push", gitOk, ec, outText)
End Sub

'' Git menu > Git Commit: prompt for a message, then `git add -A` + `git commit`.
'' The message is passed through a temp file (`git commit -F`) so quotes, percent
'' signs, etc. in it can't break the .bat command line. Empty/cancelled aborts.
Sub GitCommit
	If Not OpenProjectIsGitRepo() Then
		MsgBox ("The open project is not a Git repository."), , mtWarning
		Exit Sub
	End If
	'' Show up front exactly what `git add -A` will commit (excludes .gitignore'd files).
	'' If nothing changed, don't even open the dialog.
	Dim As String statusOut
	Dim As Integer statusEc
	RunGitInProject("status --porcelain", statusOut, statusEc)
	If Trim(statusOut) = "" Then
		MsgBox ("Nothing to commit -- there are no changes since the last commit."), , mtInfo
		Exit Sub
	End If
	Dim fGitCommit As frmGitCommit
	pfGitCommit = @fGitCommit
	fGitCommit.FilesList = GitFormatStatusList(statusOut)
	If fGitCommit.ShowModal(frmMain) <> ModalResults.OK Then Exit Sub
	Dim As UString msg = Trim(fGitCommit.CommitMessage)
	If msg = "" Then Exit Sub   '' cancelled or empty -- git requires a message anyway
	EnsureDirectoryExists(ExePath & WindowsSlash & "Temp")
	Dim As UString msgPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_git_msg.txt"
	'' Write the message as raw UTF-8 with NO BOM. FB's `Open ... Encoding "utf-8"`
	'' prepends a BOM, and `git commit -F` folds that BOM into the commit message
	'' (showed up as a leading "i>>?" garble). Binary write of the UTF-8 bytes avoids it.
	If FileExistsU(msgPath) Then Kill msgPath
	Dim As Integer FnM = FreeFile_
	If Open(msgPath For Binary Access Write As #FnM) <> 0 Then
		MsgBox ("Could not write the commit message file."), , mtWarning
		Exit Sub
	End If
	Dim As String msgUtf8 = WStrToUtf8(msg)
	If Len(msgUtf8) > 0 Then Put #FnM, 1, msgUtf8
	CloseFile_(FnM)
	'' Commit identity from Tools > Options > Personal Information, set repo-LOCAL
	'' (never --global). Without this, a machine with no git identity configured fails
	'' the commit non-interactively with no visible error and leaves zero commits --
	'' the same trap the original project-creation git setup hit. Git User Name /
	'' Git E-Mail fall back to the general Name / E-mail address when unset.
	Dim As UString cfgName = Trim(*PersonalGitUserName)
	If cfgName = "" Then cfgName = Trim(*PersonalName)
	Dim As UString cfgEmail = Trim(*PersonalGitEmail)
	If cfgEmail = "" Then cfgEmail = Trim(*PersonalEmail)
	Dim As String cfgOut
	Dim As Integer cfgEc
	If cfgName <> "" Then RunGitInProject("config user.name " & Chr(34) & cfgName & Chr(34), cfgOut, cfgEc)
	If cfgEmail <> "" Then RunGitInProject("config user.email " & Chr(34) & cfgEmail & Chr(34), cfgOut, cfgEc)
	'' Stage everything (new/modified/deleted, minus .gitignore'd), then commit.
	Dim As String addOut
	Dim As Integer addEc
	RunGitInProject("add -A", addOut, addEc)
	Dim As String outText
	Dim As Integer ec
	Dim As Boolean gitOk = RunGitInProject("commit -F " & Chr(34) & msgPath & Chr(34), outText, ec)
	If FileExistsU(msgPath) Then Kill msgPath
	ShowGitResult("commit", gitOk, ec, outText)
End Sub

'' The provider's "add SSH key" settings page (for the assisted-browser key setup).
Private Function SshKeyPageUrl(ByRef provider As String) As UString
	Select Case LCase(Trim(provider))
	Case "gitlab":    Return "https://gitlab.com/-/user_settings/ssh_keys"
	Case "bitbucket": Return "https://bitbucket.org/account/settings/ssh-keys/"
	Case "codeberg":  Return "https://codeberg.org/user/settings/keys"
	Case Else:        Return "https://github.com/settings/ssh/new"
	End Select
End Function

'' Ensure an SSH key exists for this user, generating an ed25519 one if none is present,
'' and seed known_hosts for the common providers so the first push doesn't prompt. Returns
'' the path to the public key (existing or new), "" on failure. comment is the key's -C
'' label; setupLog gets ssh-keygen/ssh-keyscan output on a fresh generation. UI thread.
Private Function EnsureSshKey(ByRef comment As String, ByRef setupLog As String) As UString
	setupLog = ""
	Dim As String userProfile = Environ("USERPROFILE")
	If userProfile = "" Then Return ""
	Dim As UString sshDir = WinOsPath(userProfile & "/.ssh")
	'' Already have a key? Prefer ed25519, else any common type.
	Dim As UString edPub = WinOsPath(sshDir & "/id_ed25519.pub")
	If FileExistsU(edPub) Then Return edPub
	Dim As UString rsaPub = WinOsPath(sshDir & "/id_rsa.pub")
	If FileExistsU(rsaPub) Then Return rsaPub
	Dim As UString ecPub = WinOsPath(sshDir & "/id_ecdsa.pub")
	If FileExistsU(ecPub) Then Return ecPub
	'' Generate a fresh ed25519 key (no passphrase) + seed known_hosts, via a temp .bat.
	EnsureDirectoryExists(sshDir)
	EnsureDirectoryExists(ExePath & WindowsSlash & "Temp")
	Dim As UString edKey = WinOsPath(sshDir & "/id_ed25519")
	Dim As UString knownHosts = WinOsPath(sshDir & "/known_hosts")
	Dim As UString batPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_sshsetup.bat"
	Dim As UString logPath = ExePath & WindowsSlash & "Temp" & WindowsSlash & "_astoria_sshsetup.log"
	If FileExistsU(logPath) Then Kill logPath
	Dim As Integer Fn = FreeFile_
	If Open(batPath For Output As #Fn) <> 0 Then Return ""
	Print #Fn, "@echo off"
	Print #Fn, "ssh-keygen -t ed25519 -C " & Chr(34) & comment & Chr(34) & " -f " & Chr(34) & edKey & Chr(34) & " -N """" > " & Chr(34) & logPath & Chr(34) & " 2>&1"
	Print #Fn, "ssh-keyscan github.com gitlab.com bitbucket.org codeberg.org >> " & Chr(34) & knownHosts & Chr(34) & " 2>> " & Chr(34) & logPath & Chr(34)
	CloseFile_(Fn)
	PipeCmd batPath, True
	If FileExistsU(logPath) Then
		Dim As Integer FnL = FreeFile_
		If Open(logPath For Binary Access Read As #FnL) = 0 Then
			Dim As LongInt sz = LOF(FnL)
			If sz > 0 Then
				setupLog = String(sz, 0)
				Get #FnL, 1, setupLog
			End If
			CloseFile_(FnL)
		End If
		Kill logPath
	End If
	If FileExistsU(batPath) Then Kill batPath
	If FileExistsU(edPub) Then Return edPub
	Return ""
End Function

'' Reusable SSH-key setup for a provider label (GitHub/GitLab/Bitbucket/Codeberg).
'' Ensures a key exists (generating an ed25519 one if needed), copies the public key to
'' the clipboard, then registers it: if the provider CLI (gh/glab) is installed AND
'' authenticated, offers to add it directly; otherwise opens the provider's SSH-keys page
'' for a manual paste. Astoria never enters credentials or submits a web form -- adding
'' the key is the user's own action. UI thread. Public so frmNewProject can reuse it.
Sub SetupSshKey(ByRef provider As String)
	'' Key comment: prefer the Git-specific e-mail from Options > Personal Information
	'' (that's the address the host account is under), falling back to the general one.
	Dim As String comment = Trim(*PersonalGitEmail)
	If comment = "" Then comment = Trim(*PersonalEmail)
	If comment = "" Then comment = "astoria-ide"
	Dim As String setupLog
	Dim As UString pubPath = EnsureSshKey(comment, setupLog)
	If pubPath = "" Then
		Dim As UString em = ("Could not create or find an SSH key.") & Chr(13,10) & Chr(13,10) & _
			("This needs ssh-keygen, which ships with Git for Windows -- make sure Git is installed and on PATH.")
		If Trim(setupLog) <> "" Then em &= Chr(13,10) & Chr(13,10) & Trim(setupLog)
		MsgBox em, , mtWarning
		Exit Sub
	End If
	'' Read the public key and put it on the clipboard for pasting.
	Dim As String pubKey
	Dim As Integer FnP = FreeFile_
	If Open(pubPath For Binary Access Read As #FnP) = 0 Then
		Dim As LongInt sz = LOF(FnP)
		If sz > 0 Then
			pubKey = String(sz, 0)
			Get #FnP, 1, pubKey
		End If
		CloseFile_(FnP)
	End If
	pubKey = Trim(pubKey, Any !" \t" + Chr(13) + Chr(10))
	If pubKey <> "" Then Clipboard.SetAsText pubKey
	'' The public key is on the clipboard; the user pastes it into the provider's page. Astoria
	'' deliberately does not use a provider CLI to upload it: that would mean depending on a tool
	'' it does not ship, whose sign-in is a console flow, to save one paste. Everything Astoria
	'' needs for Git it already has -- git itself, bundled.
	'' Assisted-browser fallback: open the provider's SSH-keys page for a manual paste.
	Dim As UString url = SshKeyPageUrl(provider)
	Dim As UString ask = ("Your SSH public key is ready and copied to the clipboard:") & Chr(13,10) & pubPath & Chr(13,10) & Chr(13,10) & _
		("To give this machine access, add it to ") & provider & ("'s SSH keys.") & Chr(13,10) & Chr(13,10) & _
		("Open that page now so you can paste the key and save it?")
	If MsgBox(ask, "", mtInfo, btYesNo) = mrYes Then
		ShellExecuteW(0, WStr("open"), url, 0, 0, SW_SHOWNORMAL)
	End If
End Sub

'' Git menu > Set Up SSH Key: set up SSH access for the open project's provider (or GitHub).
Sub GitSetupSshKey
	Dim As UString provider = "GitHub"
	Dim As UString projFolder = GetProjectDirectory()
	If projFolder <> "" Then
		Dim As ProjectDescriptionData d
		If ReadProjectDescription(projFolder, d) AndAlso Trim(d.GitProvider) <> "" Then provider = d.GitProvider
	End If
	SetupSshKey(provider)
End Sub

'' The provider's "new repository" page (assisted-browser fallback for creating a repo).
Private Function NewRepoPageUrl(ByRef provider As String) As UString
	Select Case LCase(Trim(provider))
	Case "gitlab":    Return "https://gitlab.com/projects/new"
	Case "bitbucket": Return "https://bitbucket.org/repo/create"
	Case "codeberg":  Return "https://codeberg.org/repo/create"
	Case Else:        Return "https://github.com/new"
	End Select
End Function

'' Open the provider's "new repository" page in the browser.
Sub OpenNewRepoPage(ByRef provider As String)
	Dim As UString url = NewRepoPageUrl(provider)
	ShellExecuteW(0, WStr("open"), url, 0, 0, SW_SHOWNORMAL)
End Sub

'' Git menu > Create Remote Repository: create an empty remote repo for the open project on
'' its provider (from project.astoria, else GitHub), named after the project. Uses the
'' provider CLI when signed in (and wires origin for a local git repo), else opens the
'' provider's new-repo page. Astoria never enters credentials or submits a web form.
Sub GitCreateRemoteRepo
	Dim As UString projFolder = GetProjectDirectory()
	If projFolder = "" Then
		MsgBox ("Open a project first."), , mtWarning
		Exit Sub
	End If
	'' Name + provider from project.astoria; fall back to the folder name / GitHub.
	Dim As String repoName = ""
	Dim As UString provider = "GitHub"
	Dim As ProjectDescriptionData d
	If ReadProjectDescription(projFolder, d) Then
		If Trim(d.ProjectName) <> "" Then repoName = d.ProjectName
		If Trim(d.GitProvider) <> "" Then provider = d.GitProvider
	End If
	If Trim(repoName) = "" Then
		Dim As UString f = projFolder
		If Right(f, 1) = "\" OrElse Right(f, 1) = "/" Then f = Left(f, Len(f) - 1)
		repoName = GetFileNameU(f)
	End If
	If Trim(repoName) = "" Then
		MsgBox ("Could not determine a project name for the repository."), , mtWarning
		Exit Sub
	End If
	If MsgBox(("Astoria will open ") & provider & ("'s new-repository page, with the name ") & Chr(34) & repoName & Chr(34) & (" to use.") & Chr(13,10) & Chr(13,10) & _
		("Create it there as an empty private repository, then use Git > Push.") & Chr(13,10) & Chr(13,10) & ("Open the page now?"), "", mtInfo, btYesNo) = mrYes Then
		Clipboard.SetAsText repoName
		OpenNewRepoPage(provider)
	End If
End Sub

Sub AddNewProjectFile(ByRef Template As WString, ByRef ItemName As WString)
	Dim tnP As TreeNode Ptr = GetOpenProjectNode()
	If tnP = 0 Then
		MsgBox ("Open a project first."), , mtWarning
		Return
	End If
	Dim ppe As ProjectElement Ptr = Cast(ProjectElement Ptr, tnP->Tag)
	If ppe = 0 Then Return
	Dim As UString itemBaseName = Trim(ItemName, Any !" \t" + Chr(10) + Chr(13))
	If Not IsValidProjectItemName(itemBaseName) Then
		MsgBox ("Enter a valid name without paths or file extensions."), , mtWarning
		Return
	End If
	Dim As UString projectDir = GetProjectDirectory()
	If projectDir = "" Then
		MsgBox ("Project folder not found."), , mtWarning
		Return
	End If
	Dim As UString templateFile = GetFileNameU(Template)
	Dim As UString fileExt = ""
	Dim extPos As Integer = InStrRev(templateFile, ".")
	If extPos > 0 Then fileExt = Mid(templateFile, extPos)
	'' Existence/collision checks still look at the eventual real (project-folder)
	'' destination -- that's the name a user would recognize as "already exists" -- even
	'' though the file itself is staged under Temp/ until the project is saved.
	Dim As UString finalPath = WinOsPath(projectDir & WindowsSlash & itemBaseName & fileExt)
	If FileExistsU(finalPath) Then
		MsgBox ("File already exists") & ":" & WChr(13, 10) & WChr(13, 10) & FormatMsgPathU(finalPath), , mtWarning
		Return
	End If
	Dim tn1 As TreeNode Ptr = GetTreeNodeChild(tnP, finalPath)
	Dim As WString Ptr finalPathPtr
	WLet(finalPathPtr, finalPath)
	Dim As Boolean bCollides = ContainsFileName(tn1, *finalPathPtr)
	WDeAllocate(finalPathPtr)
	If bCollides Then
		MsgBox ("This path is exists!"), , mtWarning
		Return
	End If
	'' Stage in Temp/ rather than writing directly into the project folder -- moved into
	'' place (silently, no dialog) by SaveProjectFile once the project is actually saved;
	'' deleted by CloseProject if the project closes without saving. Same convention as
	'' CreatePendingProjectFile (used by AddFromTemplate/new-project seeding).
	Dim As UString tempPath = WinOsPath(ExePath & WindowsSlash & "Temp" & WindowsSlash & itemBaseName & fileExt)
	If Not EnsureDirectoryExists(ExePath & WindowsSlash & "Temp") OrElse Not CopyFileU(Template, tempPath) Then
		MsgBox ("Create file failure!") & ":" & WChr(13, 10) & WChr(13, 10) & FormatMsgPathU(tempPath), , mtWarning
		Return
	End If
	Dim As String IconName = GetIconName(tempPath)
	Dim As ExplorerElement Ptr ee = _New(ExplorerElement)
	WLet(ee->FileName, tempPath)
	WLet(ee->TemplateFileName, "")
	ee->PendingInTemp = True
	Dim As UString treeLabel = itemBaseName & fileExt & "*"
	Dim tn3 As TreeNode Ptr = tn1->Nodes.Add(treeLabel, , , IconName, IconName, True)
	tn3->Tag = ee
	If Not EndsWith(tnP->Text, "*") Then tnP->Text &= "*"
	If Not tnP->IsExpanded Then tnP->Expand
	If Not tn1->IsExpanded Then tn1->Expand
	tn3->SelectItem
	Dim As WString Ptr tempPathPtr
	WLet(tempPathPtr, tempPath)
	Dim As Boolean bIsForm = EndsWith(LCase(fileExt), ".frm")
	Dim As TabWindow Ptr tbNew = AddTab(*tempPathPtr, bIsForm, tn3)
	'' Forms go through AddTab's bNew=True path, which sets the tab's own .FileName from
	'' the tree node's text (no folder) rather than the path just loaded -- see the
	'' matching comment in CreatePendingProjectFile for why this needs overriding.
	If bIsForm AndAlso tbNew <> 0 Then tbNew->FileName = *tempPathPtr
	WDeAllocate(tempPathPtr)
	If EndsWith(LCase(fileExt), ".bas") OrElse EndsWith(LCase(fileExt), ".frm") OrElse EndsWith(LCase(fileExt), ".bi") OrElse EndsWith(LCase(fileExt), ".inc") Then
		ppe->Files_.Add tempPath
		If Not LoadPaths.Contains(tempPath) Then LoadPaths.Add tempPath
		ThreadCounter(ThreadCreate_(@LoadOnlyFilePath, @LoadPaths.Item(LoadPaths.IndexOf(tempPath))))
	End If
End Sub

Function PrepareForAnotherProject(ByRef NewProjectPath As WString) As Boolean
	Dim tnCur As TreeNode Ptr = GetOpenProjectNode()
	If tnCur = 0 Then Return True
	If NewProjectPath <> "" Then
		Dim ppe As ProjectElement Ptr = Cast(ProjectElement Ptr, tnCur->Tag)
		If ppe <> 0 AndAlso EqualPaths(WGet(ppe->FileName), NewProjectPath) Then Return True
	End If
	Return CloseProject(tnCur, False)
End Function

Function WorkspaceHasOpenItems() As Boolean
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		If ptabCode->TabCount > 0 Then Return True
	Next
	Return GetOpenProjectNode() <> 0
End Function

Sub ClearWorkspaceFile()
	If FileExists(WorkspacePath) Then Kill WorkspacePath
End Sub

Sub SaveWorkspace()
	If Not WorkspaceHasOpenItems() Then
		ClearWorkspaceFile()
		Return
	End If
	Dim As Integer Fn = FreeFile_
	If Open(WorkspacePath For Output Encoding "utf-8" As #Fn) <> 0 Then Return
	Dim tnP As TreeNode Ptr = GetOpenProjectNode()
	If tnP <> 0 Then
		Dim ppe As ProjectElement Ptr = Cast(ProjectElement Ptr, tnP->Tag)
		If ppe <> 0 AndAlso (InStr(WGet(ppe->FileName), "\") > 0 OrElse InStr(WGet(ppe->FileName), "/") > 0) Then
			Print #Fn, "*File=" & Replace(MakePathPortable(WGet(ppe->FileName)), "\", "/")
		End If
	End If
	Print #Fn, "UseDebugger=" & IIf(UseDebugger, "1", "0")
	Print #Fn, "[Tabs]"
	Dim As TabWindow Ptr tb
	Dim Zv As String
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb <> 0 AndAlso FileExists(tb->FileName) Then
				Zv = IIf(tb->IsSelected, "*", "")
				Print #Fn, Zv & "File=" & Replace(MakePathPortable(tb->FileName), "\", "/")
			End If
		Next i
	Next j
	CloseFile_(Fn)
End Sub

Function LoadWorkspace() As Boolean
	If Not FileExists(WorkspacePath) Then Return False
	Dim Buff As WString * 2048
	Dim As WStringList Files
	Dim As Integer Fn = FreeFile_
	Dim Result As Integer = Open(WorkspacePath For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(WorkspacePath For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(WorkspacePath For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(WorkspacePath For Input As #Fn)
	If Result <> 0 Then Return False
	Dim As WString Ptr filn
	Dim bMain As Boolean, bTabs As Boolean
	Dim Pos1 As Integer, n As Integer = 0
	Dim bProjectLoaded As Boolean = False
	Dim bUseDebuggerSaved As Boolean = False
	Dim bHasUseDebuggerSaved As Boolean = False
	MainNode = 0
	Do Until EOF(Fn)
		Line Input #Fn, Buff
		If StartsWith(LCase(Buff), "[tabs]") Then
			bTabs = True
			n = 0
		ElseIf StartsWith(LCase(Buff), "usedebugger=") Then
			Pos1 = InStr(Buff, "=")
			If Pos1 <> 0 Then
				bUseDebuggerSaved = (Val(Mid(Buff, Pos1 + 1)) <> 0)
				bHasUseDebuggerSaved = True
			End If
		ElseIf StartsWith(LCase(Buff), "file=") OrElse StartsWith(LCase(Buff), "*file=") Then
			Pos1 = InStr(Buff, "=")
			If Pos1 <> 0 Then
				n += 1
				bMain = StartsWith(Buff, "*")
				WLet(filn, GetFullPath(Replace(Mid(Buff, Pos1 + 1), UnixSlash, WindowsSlash)))
				If bTabs Then
					Var tb = AddTab(*filn, , , Not bMain)
					If tb AndAlso tb->Index <> n - 1 Then ptabCode->ReorderTab(tb, n - 1, True)
				ElseIf EndsWith(LCase(*filn), ".vfp") Then
					If Not bProjectLoaded AndAlso FileExists(*filn) Then
						AddProject(*filn, @Files)
						bProjectLoaded = True
					End If
				ElseIf FileExists(*filn) Then
					AddTab(*filn)
				End If
			End If
		End If
	Loop
	WDeAllocate(filn)
	For i As Integer = 0 To Files.Count - 1
		ThreadCounter(ThreadCreate_(@LoadOnlyIncludeFiles, @LoadPaths.Item(LoadPaths.IndexOf(Files.Item(i)))))
	Next
	If ProjectAutoSuggestions Then
		For i As Integer = 0 To Files.Count - 1
			Var ecc = _New(EditControlContent)
			ecc->FileName = Files.Item(i)
			ecc->Globals = @Cast(ProjectElement Ptr, Files.Object(i))->Globals
			ecc->Tag = Files.Object(i)
			Cast(ProjectElement Ptr, Files.Object(i))->Contents.Add ecc
			If Not LoadPaths.Contains(Files.Item(i)) Then LoadPaths.Add Files.Item(i)
			ThreadCounter(ThreadCreate_(@LoadOnlyFilePathOverwriteWithContent, ecc))
		Next
	End If
	CloseFile_(Fn)
	If bHasUseDebuggerSaved Then ChangeUseDebugger bUseDebuggerSaved, 1
	Return CBool(bProjectLoaded) OrElse (ptabCode->TabCount > 0)
End Function

Sub AddMRUListOnly(ByRef FileFolderName As WString, ByRef MRUList As WStringList)
	Dim As UString FileFolderName_
	If AddRelativePathsToRecent Then
		FileFolderName_ = GetShortFileName(FileFolderName, ExePath & WindowsSlash & WindowsSlash)
	Else
		FileFolderName_ = FileFolderName
	End If
	Dim As Integer i = MRUList.IndexOf(FileFolderName_)
	If i <> -1 Then MRUList.Remove i
	MRUList.Add FileFolderName_
End Sub

'' B3: shared by AddMRU (one new file added this session) and the startup population
'' below (the whole list, freshly loaded from the INI) -- rebuilds the submenu's items
'' from whatever is currently in MRUFilesFolders and greys the parent item out when
'' the list is empty, rather than leaving stale items or an always-enabled empty menu.
Sub RebuildMRUMenu(ByRef MRUFilesFolders As WStringList, miRecentFilesFolders As MenuItem Ptr, ByRef MRUType As String)
	miRecentFilesFolders->Clear
	For i As Integer = 0 To MRUFilesFolders.Count - 1
		miRecentFilesFolders->Add(MRUFilesFolders.Item(i), "", MRUFilesFolders.Item(i), @mClickMRU, , i)
	Next
	If MRUFilesFolders.Count > 0 Then
		miRecentFilesFolders->Add("-")
		miRecentFilesFolders->Add(("Clear Recently Opened"), "", "Clear" & MRUType, @mClickMRU)
	End If
	miRecentFilesFolders->Enabled = (MRUFilesFolders.Count > 0)
End Sub

Sub AddMRU(ByRef FileFolderName As WString, ByRef MRUFilesFolders As WStringList, miRecentFilesFolders As MenuItem Ptr, ByRef MRUType As String)
	AddMRUListOnly FileFolderName, MRUFilesFolders
	RebuildMRUMenu MRUFilesFolders, miRecentFilesFolders, MRUType
End Sub

Sub AddMRUFile(ByRef FileName As WString)
	AddMRU FileName, MRUFiles, miRecentFiles, "Files"
End Sub

Sub AddMRUProject(ByRef FileName As WString)
	AddMRUListOnly FileName, MRUProjects
End Sub

Sub AddMRUFolder(ByRef FolderName As WString)
	AddMRUListOnly FolderName, MRUFolders
End Sub

Sub PruneMissingMRUProjects()
	SanitizeMRUListsOnLoad()
End Sub

Sub SanitizeMRUListsOnLoad()
	Dim As Boolean changed = False
	Dim As UString path
	For i As Integer = MRUProjects.Count - 1 To 0 Step -1
		Dim As UString path = SanitizeIniOptionalPath(MRUProjects.Item(i))
		If path = "" OrElse (EndsWith(LCase(path), ".vfp") AndAlso Not FileExistsU(GetFullPathU(path))) Then
			MRUProjects.Remove i
			changed = True
		ElseIf path <> MRUProjects.Item(i) Then
			MRUProjects.Item(i) = path
			changed = True
		End If
	Next
	For i As Integer = MRUFiles.Count - 1 To 0 Step -1
		path = SanitizeIniOptionalPath(MRUFiles.Item(i))
		If path = "" OrElse Not FileExistsU(GetFullPathU(path)) Then
			MRUFiles.Remove i
			changed = True
		ElseIf path <> MRUFiles.Item(i) Then
			MRUFiles.Item(i) = path
			changed = True
		End If
	Next
	For i As Integer = MRUFolders.Count - 1 To 0 Step -1
		path = SanitizeIniOptionalPath(MRUFolders.Item(i))
		If path = "" OrElse Not FolderExistsU(GetFullPathU(path)) Then
			MRUFolders.Remove i
			changed = True
		ElseIf path <> MRUFolders.Item(i) Then
			MRUFolders.Item(i) = path
			changed = True
		End If
	Next
	If changed Then SaveMRU
End Sub

Function FolderCopy(FromDir As UString, ToDir As UString) As Integer
	Dim As WString * 1024 f, fsrc, fdest
	Dim As UInteger Attr
	Dim As WStringList Folders
	MkDir ToDir
	f = Dir(FromDir & WindowsSlash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	While f <> ""
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then Folders.Add FromDir & IIf(EndsWith(FromDir, WindowsSlash), "", WindowsSlash) & f
		Else
				fsrc = FromDir & WindowsSlash & f
				fdest = ToDir & WindowsSlash & f
				CopyFileW @fsrc, @fdest, False
		End If
		f = Dir(Attr)
	Wend
	For i As Integer = 0 To Folders.Count - 1
		FolderCopy Folders.Item(i), ToDir & WindowsSlash & GetFileName(Folders.Item(i))
	Next
	Folders.Clear
	Return 0
End Function

Function FolderExists(ByRef FolderName As WString) As Boolean
	If Trim(FolderName)="" Then Return False
	Dim AttrTester As Integer, DirString As String
	DirString = Dir(FolderName, fbDirectory, AttrTester)
	Return AttrTester = fbDirectory
End Function

Sub AddNew(ByRef Template As WString)
	If EndsWith(LCase(Template), ".vfp") Then
		Dim tnPrev As TreeNode Ptr = GetOpenProjectNode()
		If Not PrepareForAnotherProject("") Then Return
		Dim tn As TreeNode Ptr = AddProject(Template, , , True)
		If tn <> tnPrev Then ChangeUseDebugger False, 1
	Else
		MsgBox ("Open a project first."), , mtWarning
	End If
End Sub

Sub OpenFiles(ByRef FileName As WString)
	If EndsWith(LCase(FileName), ".vfp") Then
		Dim tnPrev As TreeNode Ptr = GetOpenProjectNode()
		If Not PrepareForAnotherProject(FileName) Then Return
		Dim tn As TreeNode Ptr = AddProject(FileName)
		If tn <> tnPrev Then ChangeUseDebugger False, 1
		WLet(RecentProject, FileName)
	ElseIf FolderExists(FileName) Then
		AddFolder FileName
		WLet(RecentFolder, FileName)
	ElseIf Trim(FileName)<>"" Then '
		If FileExists(FileName) Then AddMRUFile FileName
		AddTab FileName
		WLet(RecentFile, FileName)
	End If
	WLet(RecentFiles, FileName)
End Sub

Sub SetSaveDialogParameters(ByRef FileName As WString)
	pSaveD->Caption = ("Save File As")
	pSaveD->Filter = ("FreeBasic Module") & " (*.bas)|*.bas|" & ("FreeBasic Include File") & " (*.bi)|*.bi|" & ("Other Include File") & " (*.inc)|*.inc|" & ("Form Module") & " (*.frm)|*.frm|" & ("Resource File") & " (*.rc)|*.rc|" & ("All Files") & "|*.*|"
	If InStr(FileName, "/") = 0 AndAlso InStr(FileName, "\") = 0 Then
		If *LastOpenPath = "" Then
			pSaveD->InitialDir = *ProjectsPath
		Else
			pSaveD->InitialDir = *LastOpenPath
		End If
	Else
		pSaveD->InitialDir = GetFolderName(FileName)
	End If
	pSaveD->FileName = FileName
	If FileName = ("Untitled") Then
		'pSaveD->FileName = FileName & ".bas"
		pSaveD->InitialDir = GetFullPath(*ProjectsPath)
		pSaveD->FilterIndex = SAVE_FILTER_BAS
	ElseIf EndsWith(LCase(FileName), ".bas") Then
		pSaveD->FilterIndex = SAVE_FILTER_BAS
	ElseIf EndsWith(LCase(FileName), ".bi") Then
		pSaveD->FilterIndex = SAVE_FILTER_BI
	ElseIf EndsWith(LCase(FileName), ".inc") Then
		pSaveD->FilterIndex = SAVE_FILTER_INC
	ElseIf EndsWith(LCase(FileName), ".frm") Then
		pSaveD->FilterIndex = SAVE_FILTER_FRM
	ElseIf EndsWith(LCase(FileName), ".rc") Then
		pSaveD->FilterIndex = SAVE_FILTER_RC
	Else
		pSaveD->FileName = FileName
		pSaveD->FilterIndex = SAVE_FILTER_OTHER
	End If
End Sub

Function SaveProjectFile(ppe As ProjectElement Ptr, ee As ExplorerElement Ptr, tn As TreeNode Ptr) As Boolean
	If ppe = 0 OrElse ee = 0 OrElse tn = 0 Then Return False
	Dim As TabWindow Ptr tb = GetTabFromTn(tn)
	If ee->PendingInTemp Then
		'' The name was already chosen up front at file-creation time (see
		'' CreatePendingProjectFile/AddNewProjectFile) -- move the staged Temp/ copy into
		'' the project folder now, silently, instead of prompting again with a system
		'' Save dialog.
		If tb <> 0 AndAlso tb->Modified Then
			'' tb->Save (public) dispatches to the private SaveTab since FFileName
			'' already has a real path (the Temp copy) -- just flushes latest edits there.
			If Not tb->Save Then Return False
		End If
		Dim As UString projectDir = GetFolderNameU(WGet(ppe->FileName))
		Dim As UString destPath = WinOsPath(projectDir & GetFileName(*ee->FileName))
		If Not EnsureDirectoryExists(projectDir) Then Return False
		If FileExistsU(destPath) Then Kill destPath
		'' Copy+delete rather than FB's `Name...As` -- Temp/ (always under ExePath) and
		'' the project folder (chosen freely via Save Project As) aren't guaranteed to be
		'' on the same drive, and `Name` fails across volumes.
		If Not CopyFileU(*ee->FileName, destPath) Then
			MsgBox ("Couldn't save the project file - check that the folder still exists and isn't read-only") & "." & WChr(13,10) & destPath, "Astoria IDE", mtError
			Return False
		End If
		Kill *ee->FileName
		If WGet(ppe->MainFileName) = WGet(ee->FileName) Then WLet(ppe->MainFileName, destPath)
		If WGet(ppe->ResourceFileName) = WGet(ee->FileName) Then WLet(ppe->ResourceFileName, destPath)
		If WGet(ppe->IconResourceFileName) = WGet(ee->FileName) Then WLet(ppe->IconResourceFileName, destPath)
		If WGet(ppe->BatchCompilationFileNameWindows) = WGet(ee->FileName) Then WLet(ppe->BatchCompilationFileNameWindows, destPath)
		If WGet(ppe->BatchCompilationFileNameLinux) = WGet(ee->FileName) Then WLet(ppe->BatchCompilationFileNameLinux, destPath)
		WLet(ee->FileName, destPath)
		ee->PendingInTemp = False
		tn->Text = GetFileName(destPath)
		If tb <> 0 Then
			tb->FileName = destPath
			tb->Caption = GetFileName(destPath)
			If tb->mi <> 0 Then tb->mi->Caption = tb->Caption
			AddMRUFile destPath
		End If
		Return True
	End If
	If tb <> 0 Then
		If tb->Modified Then Return tb->Save
	ElseIf InStr(WGet(ee->FileName), "\") = 0 AndAlso InStr(WGet(ee->FileName), "/") = 0 Then
		SetSaveDialogParameters(WGet(ee->FileName))
		Do
			If pSaveD->Execute Then
				WLet(LastOpenPath, GetFolderName(pSaveD->FileName))
				If FileExists(pSaveD->FileName) Then
					Select Case MsgBox(("Want to replace the file") & " """ & pSaveD->FileName & """?", App.Title, mtWarning, btYesNoCancel)
					Case mrYes: Exit Do
					Case mrCancel: Return False
					Case mrNo:
					End Select
				Else
					Exit Do
				End If
			Else
				Return False
			End If
		Loop
		If WGet(ppe->MainFileName) = WGet(ee->FileName) Then WLet(ppe->MainFileName, pSaveD->FileName)
		If WGet(ppe->ResourceFileName) = WGet(ee->FileName) Then WLet(ppe->ResourceFileName, pSaveD->FileName)
		If WGet(ppe->IconResourceFileName) = WGet(ee->FileName) Then WLet(ppe->IconResourceFileName, pSaveD->FileName)
		If WGet(ppe->BatchCompilationFileNameWindows) = WGet(ee->FileName) Then WLet(ppe->BatchCompilationFileNameWindows, pSaveD->FileName)
		If WGet(ppe->BatchCompilationFileNameLinux) = WGet(ee->FileName) Then WLet(ppe->BatchCompilationFileNameLinux, pSaveD->FileName)
		WLet(ee->FileName, pSaveD->FileName)
		tn->Text = GetFileName(*ee->FileName)
		If WGet(ee->TemplateFileName) <> "" Then FileCopy WGet(ee->TemplateFileName), WGet(ee->FileName)
	End If
	Return True
End Function

Function SaveProject(ByRef tnP As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
	If tnP = 0 Then MsgBox(("Project not selected!")): Return True
	Dim As TreeNode Ptr tnPr = GetParentNode(tnP)
	If tnPr = 0 Then Return True
	Dim As ExplorerElement Ptr ee
	Dim As ProjectElement Ptr ppe
	ppe = tnPr->Tag
	If tnPr->ImageKey <> "Project" AndAlso tnPr->ImageKey <> "Opened" Then MsgBox(("Project not selected!")): Return True
	If CInt(ppe = 0) OrElse CInt(InStr(WGet(ppe->FileName), "\") = 0 AndAlso InStr(WGet(ppe->FileName), "/") = 0) OrElse CInt(bWithQuestion) Then
		SaveD.Caption = ("Save Project As")
		SaveD.InitialDir = GetFullPath(*ProjectsPath)
		If ppe <> 0 Then
			SaveD.FileName = WGet(ppe->FileName)
			'			If InStr(WGet(ppe->FileName), "\") = 0 AndAlso InStr(WGet(ppe->FileName), "\") = 0 Then
			'				SaveD.FileName = WGet(ppe->FileName) & ".vfp"
			'			Else
			'				SaveD.FileName = WGet(ppe->FileName)
			'			End If
		End If
		SaveD.Filter = ("AstoriaIDE Project") & " (*.vfp)|*.vfp|"
		If Not SaveD.Execute Then Return False
		WLet(LastOpenPath, GetFolderName(SaveD.FileName))
		If FileExists(SaveD.FileName) Then
			Select Case MsgBox(("Are you sure you want to overwrite the project") & "?" & WChr(13,10) & SaveD.FileName, "Astoria IDE", mtWarning, btYesNo)
			Case mrYes:
			Case mrNo: Return SaveProject(tnPr, bWithQuestion)
			End Select
		End If
		If ppe = 0 Then ppe = _New( ProjectElement)
		WLet(ppe->FileName, SaveD.FileName)
		AddMRUProject SaveD.FileName
	End If
	Dim As TreeNode Ptr tn1, tn2
	Dim As String Zv = "*"
	'' B1: files marked pending-delete (via "Delete File") are collected here -- path
	'' plus the originating TreeNode Ptr as the WStringList item's Object -- instead of
	'' being handed to SaveProjectFile, so they're skipped by both .vfp write branches
	'' below. Actually removed from disk+tree only after the .vfp write succeeds.
	Dim As WStringList PendingKill
	For i As Integer = 0 To tnPr->Nodes.Count - 1
		tn1 = tnPr->Nodes.Item(i)
		ee = tn1->Tag
		If ee <> 0 Then
			If ee->PendingDelete Then
				PendingKill.Add WGet(ee->FileName), tn1
			ElseIf Not SaveProjectFile(ppe, ee, tn1) Then
				Return False
			End If
		ElseIf tn1->Nodes.Count > 0 Then
			For j As Integer = 0 To tn1->Nodes.Count - 1
				tn2 = tn1->Nodes.Item(j)
				ee = tn2->Tag
				If ee <> 0 Then
					If ee->PendingDelete Then
						PendingKill.Add WGet(ee->FileName), tn2
					ElseIf Not SaveProjectFile(ppe, ee, tn2) Then
						Return False
					End If
				End If
			Next
		End If
	Next
	'' Folder-style projects (below) write from ppe->Files rather than walking the
	'' tree directly, so pending-delete files need excluding from that list too.
	For i As Integer = 0 To PendingKill.Count - 1
		Dim As Integer fIdx = ppe->Files.IndexOf(PendingKill.Item(i))
		If fIdx <> -1 Then ppe->Files.Remove fIdx
	Next i
	Dim As Integer Fn = FreeFile_
	Dim As Integer OpenResult
	If Not EndsWith(LCase(*ppe->FileName), ".vfp") Then
		OpenResult = Open(*ppe->FileName & "/" & GetFileName(*ppe->FileName) & ".vfp" For Output Encoding "utf-8" As #Fn)
		If OpenResult <> 0 Then
			MsgBox ("Couldn't save the project file - check that the folder still exists and isn't read-only") & "." & WChr(13,10) & *ppe->FileName, "Astoria IDE", mtError
			Return False
		End If
		For i As Integer = 0 To ppe->Files.Count - 1
			Zv = IIf(ppe AndAlso (ppe->Files.Item(i) = *ppe->MainFileName OrElse ppe->Files.Item(i) = *ppe->ResourceFileName OrElse ppe->Files.Item(i) = *ppe->IconResourceFileName OrElse ppe->Files.Item(i) = *ppe->BatchCompilationFileNameWindows OrElse ppe->Files.Item(i) = *ppe->BatchCompilationFileNameLinux), "*", "")
			If StartsWith(ppe->Files.Item(i), *ppe->FileName & "\") Then
				Print #Fn, Zv & "File=" & Replace(Mid(ppe->Files.Item(i), Len(*ppe->FileName & "\") + 1), "\", "/")
			Else
				Print #Fn, Zv & "File=" & ppe->Files.Item(i)
			End If
		Next
	Else
		OpenResult = Open(*ppe->FileName For Output Encoding "utf-8" As #Fn)
		If OpenResult <> 0 Then
			MsgBox ("Couldn't save the project file - check that the folder still exists and isn't read-only") & "." & WChr(13,10) & *ppe->FileName, "Astoria IDE", mtError
			Return False
		End If
		For i As Integer = 0 To tnPr->Nodes.Count - 1
			tn1 = tnPr->Nodes.Item(i)
			ee = tn1->Tag
			If ee <> 0 AndAlso Not ee->PendingDelete Then
				Zv = IIf(ppe AndAlso (*ee->FileName = *ppe->MainFileName OrElse *ee->FileName = *ppe->ResourceFileName OrElse *ee->FileName = *ppe->IconResourceFileName OrElse *ee->FileName = *ppe->BatchCompilationFileNameWindows OrElse *ee->FileName = *ppe->BatchCompilationFileNameLinux), "*", "")
				If StartsWith(*ee->FileName, GetFolderName(*ppe->FileName)) Then
					Print #Fn, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(*ppe->FileName)) + 1), "\", "/")
				Else
					Print #Fn, Zv & "File=" & *ee->FileName
				End If
			ElseIf tn1->Nodes.Count > 0 Then
				For j As Integer = 0 To tn1->Nodes.Count - 1
					tn2 = tn1->Nodes.Item(j)
					ee = tn2->Tag
					If ee <> 0 AndAlso Not ee->PendingDelete Then
						Zv = IIf(ppe AndAlso (*ee->FileName = *ppe->MainFileName OrElse *ee->FileName = *ppe->ResourceFileName OrElse *ee->FileName = *ppe->IconResourceFileName OrElse *ee->FileName = *ppe->BatchCompilationFileNameWindows OrElse *ee->FileName = *ppe->BatchCompilationFileNameLinux), "*", "")
						If StartsWith(Replace(*ee->FileName, "\", "/"), Replace(GetFolderName(*ppe->FileName), "\", "/")) Then
							Print #Fn, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(*ppe->FileName)) + 1), "\", "/")
						Else
							Print #Fn, Zv & "File=" & *ee->FileName
						End If
					End If
				Next
			End If
		Next
	End If
	Print #Fn, "ProjectType=" & ppe->ProjectType
	Print #Fn, "Subsystem=" & ppe->Subsystem
	Print #Fn, "ProjectName=""" & *ppe->ProjectName & """"
	Print #Fn, "HelpFileName=""" & *ppe->HelpFileName & """"
	Print #Fn, "ProjectDescription=""" & *ppe->ProjectDescription & """"
	Print #Fn, "PassAllModuleFilesToCompiler=" & ppe->PassAllModuleFilesToCompiler
	Print #Fn, "OpenProjectAsFolder=" & ppe->OpenProjectAsFolder
	Print #Fn, "MajorVersion=" & ppe->MajorVersion
	Print #Fn, "MinorVersion=" & ppe->MinorVersion
	Print #Fn, "RevisionVersion=" & ppe->RevisionVersion
	Print #Fn, "BuildVersion=" & ppe->BuildVersion
	Print #Fn, "AutoIncrementVersion=" & ppe->AutoIncrementVersion
	Print #Fn, "ApplicationTitle=""" & *ppe->ApplicationTitle & """"
	Print #Fn, "ApplicationIcon=""" & *ppe->ApplicationIcon & """"
	Print #Fn, "Manifest=" & ppe->Manifest
	Print #Fn, "RunAsAdministrator=" & ppe->RunAsAdministrator
	Print #Fn, "CompanyName=""" & *ppe->CompanyName & """"
	Print #Fn, "FileDescription=""" & *ppe->FileDescription & """"
	Print #Fn, "InternalName=""" & *ppe->InternalName & """"
	Print #Fn, "LegalCopyright=""" & *ppe->LegalCopyright & """"
	Print #Fn, "LegalTrademarks=""" & *ppe->LegalTrademarks & """"
	Print #Fn, "OriginalFilename=""" & *ppe->OriginalFilename & """"
	Print #Fn, "ProductName=""" & *ppe->ProductName & """"
	Print #Fn, "CompileMode=" & ppe->CompileMode
	Print #Fn, "CompilationArguments64Windows=""" & *ppe->CompilationArguments64Windows & """"
	Print #Fn, "CompilationArguments64Linux=""" & *ppe->CompilationArguments64Linux & """"
	' Win64-only fork: kept because .vfp backward compatibility (no IDE UI)
	Print #Fn, "CompilationArguments32Windows=""" & *ppe->CompilationArguments32Windows & """"
	Print #Fn, "CompilationArguments32Linux=""" & *ppe->CompilationArguments32Linux & """"
	Print #Fn, "CompilerPath=""" & *ppe->CompilerPath & """"
	Print #Fn, "CommandLineArguments=""" & *ppe->CommandLineArguments & """"
	' Win64-only fork: kept because .vfp backward compatibility (no IDE UI)
	Print #Fn, "AndroidSDKLocation=""" & *ppe->AndroidSDKLocation & """"
	Print #Fn, "AndroidNDKLocation=""" & *ppe->AndroidNDKLocation & """"
	Print #Fn, "JDKLocation=""" & *ppe->JDKLocation & """"
	' New Project dialog metadata (see TabWindow.bi). WGet (not *) on purpose:
	' any project created before these keys existed still has null pointers here,
	' and every template .vfp ships without these keys too.
	Print #Fn, "Author=""" & WGet(ppe->Author) & """"
	Print #Fn, "License=""" & WGet(ppe->License) & """"
	Print #Fn, "Description=""" & WGet(ppe->Description) & """"
	Print #Fn, "UseGit=" & ppe->UseGit
	Print #Fn, "GitProvider=""" & WGet(ppe->GitProvider) & """"
	Print #Fn, "GitUserName=""" & WGet(ppe->GitUserName) & """"
	Print #Fn, "GitEmail=""" & WGet(ppe->GitEmail) & """"
	Print #Fn, "GitURL=""" & WGet(ppe->GitURL) & """"
	Print #Fn, "AIFriendly=" & ppe->AIFriendly
	Print #Fn, "AITool=""" & WGet(ppe->AITool) & """"
	For i As Integer = 0 To ppe->Components.Count - 1
		Dim As UString ComponentPath = GetControlLibraryVfpPath(ppe->Components.Item(i))
		If ComponentPath <> "" Then Print #Fn, "ControlLibrary=""" & ComponentPath & """"
	Next
	For i As Integer = 0 To ppe->IncludePaths.Count - 1
		Print #Fn, "IncludePath=""" & Replace(ppe->IncludePaths.Item(i), "\", "/") & """"
	Next
	For i As Integer = 0 To ppe->LibraryPaths.Count - 1
		Print #Fn, "LibraryPath=""" & Replace(ppe->LibraryPaths.Item(i), "\", "/") & """"
	Next
	'Dim As Library Ptr CtlLibrary
	'For i As Integer = 0 To ControlLibraries.Count - 1
	'	CtlLibrary = ControlLibraries.Item(i)
	'	If CtlLibrary->Enabled Then
	'		Print #Fn, "ControlLibrary=""" & Replace(GetFolderName(CtlLibrary->Path, False), "\", "/") & """"
	'	End If
	'Next
	CloseFile_(Fn)
	'Else
	'	MsgBox ML("Save file failure!") & Chr(13,10) & *ppe->FileName
	'End If
	'' B1: only now -- once the project file itself is actually written -- do files
	'' the owner deleted this session (DeleteEditorFile, marked ee->PendingDelete and
	'' excluded from both write branches above) really disappear from disk and from
	'' the tree. Collected via PendingKill (path + originating TreeNode Ptr as the
	'' WStringList item's Object) during the per-node loop earlier in this Function.
	For i As Integer = 0 To PendingKill.Count - 1
		Dim As TreeNode Ptr tnKill = PendingKill.Object(i)
		If Dir(PendingKill.Item(i)) <> "" Then Kill PendingKill.Item(i)
		If tnKill <> 0 AndAlso tnKill->ParentNode <> 0 AndAlso tnKill->ParentNode->Nodes.IndexOf(tnKill) <> -1 Then
			tnKill->ParentNode->Nodes.Remove tnKill->ParentNode->Nodes.IndexOf(tnKill)
		End If
	Next i
	If tnPr->Text <> GetFileName(WGet(ppe->FileName)) Then tnPr->Text = GetFileName(WGet(ppe->FileName))
	tnPr->Tag = ppe
	Return True
End Function

Sub SaveAll()
	Dim tb As TabWindow Ptr
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb->Modified Then tb->Save
		Next i
	Next j
	For i As Integer = 0 To tvExplorer.Nodes.Count - 1
		If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
			SaveProject tvExplorer.Nodes.Item(i)
		End If
	Next i
End Sub

Function SaveAllBeforeCompile() As Boolean
	If AutoSaveBeforeCompiling = 1 Then
		Dim As ProjectElement Ptr Project
		Dim As TreeNode Ptr ProjectNode
		GetMainFile(AutoSaveBeforeCompiling, Project, ProjectNode)
		If ProjectNode <> 0 Then SaveProject(ProjectNode)
	ElseIf AutoSaveBeforeCompiling = 2 Then
		SaveAll
	ElseIf AutoSaveBeforeCompiling = 3 Then
		Dim tnP As TreeNode Ptr
		Dim As TreeNode Ptr tn
		Dim As TabWindow Ptr tb
		Dim Index As Integer
		With *pfSave
			.lstFiles.Clear
			For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
				tn = tvExplorer.Nodes.Item(i)
				If CInt(tn->ImageKey = "Project") AndAlso EndsWith(tn->Text, "*") Then
					.lstFiles.AddItem tn->Text, tn
				End If
			Next i
			For j As Integer = TabPanels.Count - 1 To 0 Step - 1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
				For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
					tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
					If tb->Modified Then
						tnP = tb->ptn
						Index = .lstFiles.IndexOfData(tnP)
						If Index <> -1 Then
							.lstFiles.InsertItem Index + 1, WSpace(2) & tb->Caption, tb
						Else
							.lstFiles.AddItem tb->Caption, tb
						End If
					End If
				Next i
			Next j
			If .lstFiles.ItemCount > 0 Then
				Select Case .ShowModal(*pfrmMain)
				Case ModalResults.Yes
					'' B1: read .SelectedItems (captured in cmdYes_Click before pfSave's
					'' WM_CLOSE tears the native listbox down) instead of .lstFiles.Selected,
					'' which always reads back False once ShowModal has returned -- see
					'' CloseProject for the full explanation.
					For i As Integer = .SelectedItems.Count - 1 To 0 Step -1
						If tvExplorer.Nodes.Contains(.SelectedItems.Item(i)) Then
							If Not SaveProject(.SelectedItems.Item(i)) Then Return False
						Else
							If Not Cast(TabWindow Ptr, .SelectedItems.Item(i))->Save Then Return False
						End If
					Next
				Case ModalResults.No
				Case Else: Return False '' Cancel, or the dialog closed via the window's X (ShowModal
				'' returns ModalResults.None then, which otherwise matches neither Yes nor No and
				'' silently falls through to continue the close without saving -- treat anything
				'' unrecognized as Cancel instead, since this dialog guards a destructive action.
				End Select
			End If
		End With
	End If
	Return True
End Function

Sub PrintThis()
		PrintD.Execute
End Sub

Sub PrintPreview()
		PrintPreviewD.Execute
End Sub

Sub PageSetup()
		PageSetupD.Execute
End Sub

Function ProjectHasOpenTabs(ProjectNode As TreeNode Ptr) As Boolean
	Dim As TabWindow Ptr tb
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb->ptn = ProjectNode Then Return True
		Next i
	Next jj
	Return False
End Function

Sub CloseAllTabs(WithoutCurrent As Boolean = False)
	Dim tb As TabWindow Ptr
	Dim j As Integer = ptabCode->SelectedTabIndex
	For jj As Integer = TabPanels.Count - 1 To 0 Step -1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Long = ptabCode->TabCount - 1 To 0 Step -1
			If WithoutCurrent Then
				If i = j Then Continue For
			End If
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			CloseTab(tb)
		Next i
	Next jj
	' CloseTab only ever removes a *file's* tree node, never a project's (see
	' TabWindow.CloseTab's explicit ImageKey<>"Project" guard) - so after closing
	' every tab, sweep and close any project that has nothing left open under it.
	' Mirrors the same sweep CloseAllDocuments already does; only skips a project if
	' one of its tabs is still open (kept via WithoutCurrent, or the user hit
	' Cancel on that tab's unsaved-changes prompt).
	Dim As TreeNode Ptr tn
	For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
		tn = tvExplorer.Nodes.Item(i)
		If CInt(tn->ImageKey = "Project") AndAlso Not ProjectHasOpenTabs(tn) Then
			CloseProject(tn, True)
		End If
	Next i
End Sub

Function CloseAllDocuments() As Boolean
		If prun AndAlso kill_process(("Trying to launch but debuggee still running")) = False Then
			Return False
		End If
	Dim tb As TabWindow Ptr
	Dim tn As TreeNode Ptr
	Dim tnP As TreeNode Ptr
	Dim Index As Integer
		If iFlagStartDebug = 1 Then
			'' DR-15: mirrors the Case "End" Stop-button fix (AstoriaIDE.bas ~312 / DR-6 2B).
			'' GDB does not act on stdin (incl. "q") while the inferior is running freely in
			'' synchronous all-stop mode, so the queued q above can sit unprocessed forever once
			'' FormClosing short-circuits every readpipe -- deinit's bare "q\n" + close-handles
			'' never reaches GDB, and the debuggee is left running (orphaned astoria.exe/debuggee
			'' on close). kill_inferior_process() is race-free wrt the GDB pipe/handles/lock.
			If Running Then kill_inferior_process()
			EnqueueDebugCommand !"q\n"
		End If
	With *pfSave
		.lstFiles.Clear
		For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
			tn = tvExplorer.Nodes.Item(i)
			If CInt(tn->ImageKey = "Project") AndAlso EndsWith(tn->Text, "*") Then
				.lstFiles.AddItem tn->Text, tn
			End If
			'If CInt(tn->ImageKey = "Project") AndAlso CInt(Not CloseProject(tn)) Then Action = 0: Return
		Next i
		For j As Integer = TabPanels.Count - 1 To 0 Step -1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
			For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				If tb->Modified Then
					tnP = tb->ptn
					Index = .lstFiles.IndexOfData(tnP)
					If Index <> -1 Then
						.lstFiles.InsertItem Index + 1, WSpace(2) & tb->Caption, tb
					Else
						.lstFiles.AddItem tb->Caption, tb
					End If
				End If
			Next i
		Next j
		If .lstFiles.ItemCount > 0 Then
			Select Case .ShowModal(*pfrmMain)
			Case ModalResults.Yes
				For i As Integer = .SelectedItems.Count - 1 To 0 Step -1
					If tvExplorer.Nodes.Contains(.SelectedItems.Item(i)) Then
						If Not SaveProject(.SelectedItems.Item(i)) Then Return False
					Else
						If Not Cast(TabWindow Ptr, .SelectedItems.Item(i))->Save Then Return False
					End If
				Next
			Case ModalResults.No
			Case Else: Return False '' Cancel, or the dialog closed via the window's X (ShowModal
				'' returns ModalResults.None then, which otherwise matches neither Yes nor No and
				'' silently falls through to continue the close without saving -- treat anything
				'' unrecognized as Cancel instead, since this dialog guards a destructive action.
			End Select
		End If
	End With
	For j As Integer = TabPanels.Count - 1 To 0 Step -1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			CloseTab(tb, True)
		Next i
	Next j
	For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
		tn = tvExplorer.Nodes.Item(i)
		If CInt(tn->ImageKey = "Project") Then CloseProject(tn, True)
	Next i
	Return True
End Function

Sub RunHelp(Param As Any Ptr)
	Type HH_AKLINK
		cbStruct     As Long         ' int       cbStruct;     // sizeof this structure
		fReserved    As Boolean      ' BOOL      fReserved;    // must be FALSE (really!)
		pszKeywords  As WString Ptr  ' LPCTSTR   pszKeywords;  // semi-colon separated keywords
		pszUrl       As WString Ptr  ' LPCTSTR   pszUrl;       // URL to jump to if no keywords found (may be NULL)
		pszMsgText   As WString Ptr  ' LPCTSTR   pszMsgText;   // Message text to display in MessageBox if pszUrl is NULL and no keyword match
		pszMsgTitle  As WString Ptr  ' LPCTSTR   pszMsgTitle;  // Message text to display in MessageBox if pszUrl is NULL and no keyword match
		pszWindow    As WString Ptr  ' LPCTSTR   pszWindow;    // Window to display URL in
		fIndexOnFail As Boolean      ' BOOL      fIndexOnFail; // Displays index if keyword lookup fails.
	End Type
	#define HH_DISPLAY_TOPIC   0000
	#define HH_DISPLAY_TOC     0001
	#define HH_KEYWORD_LOOKUP  0013
	#define HH_HELP_CONTEXT    0015
	Dim As UString CurrentHelpPath
	Dim As Integer IndexDefault
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If Param <> 0 Then CurrentHelpPath = Cast(HelpOptions Ptr, Param)->CurrentPath
	If CurrentHelpPath = "" Then
		IndexDefault = Helps.IndexOfKey(*DefaultHelp)
		CurrentHelpPath = *HelpPath
	End If
	CurrentHelpPath = GetFullPath(CurrentHelpPath)
	If Not FileExists(CurrentHelpPath) Then
		ThreadsEnter()
		ShowMessages ("File") & " " & CurrentHelpPath & " " & ("not found")
		ThreadsLeave()
	Else
	End If
		Dim As WString * MAX_PATH wszKeyword, wszKeywordUpper
		Dim As Boolean bFind
		Dim As Any Ptr gpHelpLib
		Dim HtmlHelpW As Function (ByVal hwndCaller As HWND, _
		ByVal pswzFile As WString Ptr, _
		ByVal uCommand As UINT, _
		ByVal dwData As DWORD_PTR _
		) As HWND
		gpHelpLib = DyLibLoad( "hhctrl.ocx" )
		HtmlHelpW = DyLibSymbol( gpHelpLib, "HtmlHelpW")
		If HtmlHelpW <> 0 Then
			If Param <> 0 Then wszKeyword = Cast(HelpOptions Ptr, Param)->CurrentWord
			If wszKeyword = "" AndAlso Param = 0 AndAlso tb <> 0 Then wszKeyword = tb->txtCode.GetWordAtCursor
			If wszKeyword = "" Then
				HtmlHelpW(0, CurrentHelpPath, HH_DISPLAY_TOC, NULL)
			Else
				wszKeywordUpper = UCase(wszKeyword)
				For i As Integer = -1 To Helps.Count - 1
					If i = IndexDefault Then Continue For
					If i = -1 Then
						CurrentHelpPath = GetFullPath(*HelpPath)
					Else
						CurrentHelpPath = GetFullPath(Helps.Item(i)->Text)
					End If
					If FileExists(CurrentHelpPath) Then
						Dim li As HH_AKLINK
						For j As Integer = 1 To 2
							With li
								.cbStruct     = SizeOf(HH_AKLINK)
								.fReserved    = False
								If j = 1 Then
									.pszKeywords  = @wszKeyword
								Else
									.pszKeywords  = @wszKeywordUpper
								End If
								.pszUrl       = NULL
								.pszMsgText   = NULL
								.pszMsgTitle  = NULL
								.pszWindow    = NULL
								.fIndexOnFail = False
							End With
							If HtmlHelpW(0, CurrentHelpPath, HH_KEYWORD_LOOKUP, Cast(DWORD_PTR, @li)) <> 0 Then
								bFind = True
								Exit For, For
							End If
						Next
					End If
				Next
				If Not bFind Then HtmlHelpW(0, *HelpPath, HH_DISPLAY_TOC, NULL) 'MsgBox ML("Keyword") & " """ & wszKeyword & """ " & ML("not found in Help") & "!"
			End If
			'DyLibFree(gpHelpLib)
		End If
End Sub

Sub OpenProjectTemplate(ByVal TabIndex As Integer = 0)
	Dim As String templateTitle
	If TabIndex = 0 Then
		templateTitle = "New Project"
	ElseIf TabIndex = 1 Then
		templateTitle = "Open Project"
	Else
		templateTitle = "Recent Project"
	End If
	pfTemplates->DialogMode = IIf(TabIndex = 0, 1, TabIndex)
	pfTemplates->Text = (templateTitle)
	If pfTemplates->ShowModal(frmMain) = ModalResults.OK Then
		If pfTemplates->SelectedFolder <> "" Then
			AddFolder pfTemplates->SelectedFolder
		ElseIf pfTemplates->SelectedTemplate <> "" Then
			AddNew pfTemplates->SelectedTemplate
		ElseIf pfTemplates->SelectedFile <> "" Then
			OpenFiles pfTemplates->SelectedFile
		End If
	End If
End Sub

'' Marks a just-opened, freshly-materialized new project (see NewProject/frmNewProject)
'' and its main file dirty ("*"), matching how every other new-file creation path already
'' looks. The file already sits on disk (frmNewProject commits it immediately, since the
'' user chose the project's name/location up front, unlike Add Module/Add Form's Temp
'' staging), but from the user's perspective it's still a freshly-created, not-yet-reviewed
'' file, so it should read the same way in the tree.
Sub MarkNewProjectModified()
	Dim As TreeNode Ptr tnP = GetOpenProjectNode()
	If tnP = 0 Then Return
	Dim As ProjectElement Ptr ppe = Cast(ProjectElement Ptr, tnP->Tag)
	If ppe = 0 Then Return
	If Not EndsWith(tnP->Text, "*") Then tnP->Text &= "*"
	Dim As UString mainFile = WGet(ppe->MainFileName)
	If mainFile = "" Then Return
	For i As Integer = 0 To tnP->Nodes.Count - 1
		Dim As TreeNode Ptr tn1 = tnP->Nodes.Item(i)
		Dim As ExplorerElement Ptr ee = tn1->Tag
		If ee <> 0 AndAlso EqualPaths(WGet(ee->FileName), mainFile) Then
			If Not EndsWith(tn1->Text, "*") Then tn1->Text &= "*"
			Return
		End If
		For j As Integer = 0 To tn1->Nodes.Count - 1
			Dim As TreeNode Ptr tn2 = tn1->Nodes.Item(j)
			Dim As ExplorerElement Ptr ee2 = tn2->Tag
			If ee2 <> 0 AndAlso EqualPaths(WGet(ee2->FileName), mainFile) Then
				If Not EndsWith(tn2->Text, "*") Then tn2->Text &= "*"
				Return
			End If
		Next j
	Next i
End Sub

Sub NewProject()
	Dim fNewProject As frmNewProject
	pfNewProject = @fNewProject
	If pfNewProject->ShowModal(frmMain) = ModalResults.OK Then
		If pfNewProject->SelectedProjectFile <> "" Then
			If Not PrepareForAnotherProjectU(pfNewProject->SelectedProjectFile) Then Return
			OpenFilesU pfNewProject->SelectedProjectFile
			MarkNewProjectModified()
		ElseIf pfNewProject->SelectedFolder <> "" Then
			AddFolderU pfNewProject->SelectedFolder
		ElseIf pfNewProject->SelectedTemplate <> "" Then
			If EndsWith(LCase(pfNewProject->SelectedTemplate), ".vfp") Then
				If Not PrepareForAnotherProjectU("") Then Return
			End If
			AddNewU pfNewProject->SelectedTemplate
		End If
		'' A new project is a new context, so show its tree rather than inheriting whichever panel
		'' the last project happened to leave selected. This matches Open Project and Open Folder,
		'' which already do it, and it is the only other point where Astoria picks this panel --
		'' see the startup note at leftSelectedTabIndex and ROADMAP 13.27.
		tpProject->SelectTab
	End If
	' "Open Existing Project" button on the New Project dialog: it closed with Cancel + this flag;
	' now bring up the Open Project window (only reached on the non-OK path, so no early Return skips it).
	If pfNewProject->OpenExistingRequested Then OpenProject()
End Sub

Function ContainsFileName(tn As TreeNode Ptr, ByRef FileName As WString) As Boolean
	Dim As ExplorerElement Ptr ee
	For i As Integer = 0 To tn->Nodes.Count - 1
		ee = tn->Nodes.Item(i)->Tag
		If ee <> 0 Then
			'
			If LCase(*ee->FileName) = LCase(Replace(FileName,"\","/")) OrElse LCase(*ee->FileName) = LCase(Replace(FileName,"/","\")) Then
				Return True
			End If
		End If
	Next
	Return False
End Function

'' Shows a lightweight name-entry dialog (frmNewFileName -- Name + OK/Cancel, no folder
'' browsing) and, on OK, stages the new file under ExePath/Temp instead of writing it
'' directly into the project folder -- SaveProjectFile moves it into place (silently, no
'' further dialog) once the project is actually saved; CloseProject deletes the staged
'' copy if the project closes without saving. Returns the new TreeNode Ptr, or 0 if the
'' user cancelled (in which case nothing at all -- no node, no file -- is created).
Function CreatePendingProjectFile(ByRef TemplatePath As WString, ByRef SuggestedBaseName As WString, tnParent As TreeNode Ptr, bOpenTab As Boolean = True) As TreeNode Ptr
	If tnParent = 0 Then Return 0
	Dim As UString TemplateFile = GetFileNameU(TemplatePath)
	Dim As UString FileExt = ""
	Dim As Integer extPos = InStrRev(TemplateFile, ".")
	If extPos > 0 Then FileExt = Mid(TemplateFile, extPos)
	Dim As UString TypeLabel = TemplateFile
	If extPos > 0 Then TypeLabel = Left(TemplateFile, extPos - 1)
	Dim fNewFileName As frmNewFileName
	pfNewFileName = @fNewFileName
	fNewFileName.Prompt = ("New") & " " & TypeLabel & " " & ("Name") & ":"
	fNewFileName.DefaultName = SuggestedBaseName
	fNewFileName.TargetExt = FileExt
	fNewFileName.TargetNode = tnParent
	If fNewFileName.ShowModal(frmMain) <> ModalResults.OK Then Return 0
	Dim As UString ChosenName = fNewFileName.SelectedName
	Dim As UString TempPath = WinOsPath(ExePath & WindowsSlash & "Temp" & WindowsSlash & ChosenName & FileExt)
	If Not EnsureDirectoryExists(ExePath & WindowsSlash & "Temp") OrElse Not CopyFileU(TemplatePath, TempPath) Then
		MsgBox ("Create file failure!") & ":" & WChr(13, 10) & WChr(13, 10) & FormatMsgPathU(TempPath), , mtWarning
		Return 0
	End If
	Dim As String IconName = GetIconName(TemplatePath)
	Dim As ExplorerElement Ptr ee = _New(ExplorerElement)
	WLet(ee->FileName, TempPath)
	WLet(ee->TemplateFileName, "")
	ee->PendingInTemp = True
	Dim As TreeNode Ptr tnNew = tnParent->Nodes.Add(ChosenName & FileExt & "*", , , IconName, IconName, True)
	tnNew->Tag = ee
	If bOpenTab Then
		'' Open the tab before selecting the node -- SelectItem fires the tree's single-click
		'' auto-open (tvExplorer_SelChange -> OpenPlainFileTreeNode), which for a brand-new
		'' node would otherwise open its own independent tab before AddTab below runs (same
		'' ordering requirement AddFromTemplate had before this helper absorbed its logic).
		Dim As TabWindow Ptr tbNew = AddTab(TempPath, True, tnNew)
		'' AddTab's bNew=True path sets the tab's own .FileName from the tree node's text
		'' (e.g. "Module2.bas", no folder) rather than the path just loaded -- needed for
		'' its Form1-name-substitution logic, which reads TreeN->Text directly and isn't
		'' affected by overriding FileName afterward. Without this override, the tab's
		'' FFileName has no path separator, so closing the project via the "modified
		'' files" prompt -- which can call tb->Save directly on this exact tab, not just
		'' SaveProjectFile -- takes the no-path branch and pops the system Save dialog,
		'' exactly the thing this whole feature exists to avoid.
		If tbNew <> 0 Then tbNew->FileName = TempPath
		tnNew->SelectItem
	End If
	Return tnNew
End Function

Sub AddFromTemplate(ByRef Template As WString)
	Dim As TreeNode Ptr ptn, tn1, tn3, tnSelecte
	tnSelecte = tvExplorer.SelectedNode
	If tnSelecte <> 0 Then
		ptn = GetParentNode(tnSelecte)
		If ptn->ImageKey = "Project" OrElse ptn->ImageKey = "Opened" Then
			If ptn->ImageKey = "Opened" Then
				Dim As String tmpKeyStr = " @Sub @StandartTypes @Property @Enum @EnumItem @Type @Function @Opened "
				If InStr(tmpKeyStr, " @" & tnSelecte->ImageKey & " ") Then
					tn1 = IIf(tnSelecte->ParentNode->ImageKey = tnSelecte->ImageKey, tnSelecte->ParentNode->ParentNode , tnSelecte->ParentNode)
				Else
					tn1 = tnSelecte
				End If
				If tnSelecte->ImageKey <> "Opened" Then tn1 = tn1->ParentNode
			Else
				tn1 = GetTreeNodeChild(ptn, Template)
			End If
			Dim As UString FileName = Replace(GetFileName(Template), " ", "")
			Dim As UString FileExt
			Dim Pos1 As Integer = InStrRev(FileName, ".")
			If Pos1 > 0 Then
				FileExt = Mid(FileName, Pos1)
				FileName = Left(FileName, Pos1 - 1)
			End If
			Dim As UString SuggestedName
			Dim As Integer n = 0
			Do
				n = n + 1
				SuggestedName = FileName & Str(n)
			Loop While tn1->Nodes.Contains(WStr(SuggestedName & FileExt)) OrElse tn1->Nodes.Contains(WStr(SuggestedName & FileExt & "*"))
			tn3 = CreatePendingProjectFile(Template, SuggestedName, tn1)
			If tn3 <> 0 Then
				If Not EndsWith(ptn->Text, "*") Then ptn->Text &= "*"
				If Not ptn->IsExpanded Then ptn->Expand
				If Not tn1->IsExpanded Then tn1->Expand
			End If
		End If
	End If
	If tn3 = 0 Then
		If GetOpenProjectNode() = 0 Then MsgBox ("Open a project first."), , mtWarning
	End If
End Sub

Sub AddFromTemplates
	pfTemplates->OnlyFiles = True
	If pfTemplates->ShowModal(frmMain) = ModalResults.OK Then
		AddFromTemplate pfTemplates->SelectedTemplate
	End If
End Sub

Sub AddFilesToProject
	Dim As TreeNode Ptr ptn, tn3
	Dim As ExplorerElement Ptr ee
	If tvExplorer.SelectedNode <> 0 Then
		ptn = GetParentNode(tvExplorer.SelectedNode)
		If ptn->ImageKey <> "Project" Then ptn = 0
	End If
	Dim OpenD As OpenFileDialog
	OpenD.Options.Include ofOldStyleDialog
	OpenD.MultiSelect = True
	OpenD.Filter = ("FreeBasic Files") & " (*.vfp, *.bas, *.frm, *.bi, *.inc; *.rc)|*.vfp;*.bas;*.frm;*.bi;*.inc;*.rc|" & ("AstoriaIDE Project") & " (*.vfp)|*.vfp|" & ("FreeBasic Module") & " (*.bas)|*.bas|" & ("FreeBasic Include File") & " (*.bi)|*.bi|" & ("Other Include File") & " (*.inc)|*.inc|" & ("Form Module") & " (*.frm)|*.frm|" & ("Resource File") & " (*.rc)|*.rc|" & ("All Files") & "|*.*|"
	If OpenD.Execute Then
		Dim tn1 As TreeNode Ptr
		For i As Integer = 0 To OpenD.FileNames.Count - 1
			If ptn <> 0 Then
				tn1 = GetTreeNodeChild(ptn, OpenD.FileNames.Item(i))
				If ContainsFileName(tn1, OpenD.FileNames.Item(i)) Then Continue For
				Dim As String IconName = GetIconName(OpenD.FileNames.Item(i))
				tn3 = tn1->Nodes.Add(GetFileName(OpenD.FileNames.Item(i)), , , IconName, IconName, True)
				ee = _New( ExplorerElement)
				WLet(ee->FileName, OpenD.FileNames.Item(i))
				tn3->Tag = ee
				'tn1->Expand
			Else
				OpenFiles OpenD.FileNames.Item(i)
			End If
		Next
		If ptn <> 0 Then
			If Not EndsWith(ptn->Text, "*") Then ptn->Text &= "*"
			If ptn->Nodes.Count > 0 Then
				If Not ptn->IsExpanded Then ptn->Expand
				For i As Integer = 0 To ptn->Nodes.Count - 1
					If CInt(ptn->Nodes.Item(i)->Nodes.Count > 0) Then ptn->Nodes.Item(i)->Expand
				Next
				'pfProjectProperties->RefreshProperties
			End If
		End If
	End If
End Sub

Dim Shared g_bAllowLabelEdit As Boolean
Sub RenameFile
	If tvExplorer.SelectedNode = 0 Then Exit Sub
	g_bAllowLabelEdit = True
	tvExplorer.SelectedNode->EditLabel
End Sub

Sub OpenProjectFolder
	Dim As TreeNode Ptr ptn, tnSelect = tvExplorer.SelectedNode
	If tnSelect = 0 Then Exit Sub
	ptn = GetParentNode(tnSelect)
	If ptn = 0 Then Exit Sub
	If ptn->ImageKey = "Opened" Then
		Dim As String tmpKeyStr = "@Sub@StandartTypes@Property@Enum@EnumItem@Type@Function@"
		If InStr(tmpKeyStr, " @" & tnSelect->ImageKey & "@") AndAlso tnSelect->ParentNode Then
			If tnSelect->ParentNode Then ptn = IIf(tnSelect->ParentNode->ImageKey = tnSelect->ImageKey, tnSelect->ParentNode->ParentNode , tnSelect->ParentNode)
		Else
			ptn = tnSelect
		End If
	End If
	Dim As ExplorerElement Ptr ee = ptn->Tag
	If ee = 0 Then Exit Sub
	If WGet(ee->FileName) <> "" Then
			'' ShellExecuteW opens the folder in Explorer directly -- no need to
			'' spawn explorer.exe via a shelled command line. See T3 / F-S1.
			Dim As UString FolderPath = Replace(GetFolderName(*ee->FileName), "/", "\")
			ShellExecuteW(0, WStr("open"), FolderPath, 0, 0, SW_SHOWNORMAL)
	End If
End Sub

Sub SetMainNode(tn As TreeNode Ptr)
	If MainNode <> 0 Then MainNode->Bold = False
	MainNode = tn
	If tn = 0 Then
		lblLeft.Text = ("Main Project") & ": " & ("Automatic")
	Else
		MainNode->Bold = True
		lblLeft.Text = ("Main Project") & ": " & MainNode->Text
	End If
End Sub

Sub ReloadHistoryCode()
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->txtCode.Modified Then
		tb->Save
	End If
	Dim As OpenFileDialog OpenD
	OpenD.InitialDir = ExePath & WindowsSlash & "Temp"
	OpenD.Filter = ("Backup Files") & " (*.bak)|" & GetFileName(tb->FileName) & "*.bak|" & ("All Files") & "|*.*|"
	If OpenD.Execute AndAlso Trim(OpenD.FileName) <> "" Then
		tb->txtCode.Changing "Reload"
		tb->txtCode.LoadFromFile(OpenD.FileName, tb->FileEncoding, tb->NewLineType)
		tb->FileEncoding = FileEncodings.Utf8
		tb->NewLineType = NewLineTypes.WindowsCRLF
		tb->txtCode.Changed "Reload"
			tb->DateFileTime = GetFileLastWriteTime(tb->FileName)
		tb->txtCode.Modified = True
	End If
	
End Sub

Function FileTimeToVariantTime(ByRef FT As FILETIME) As DATE_
	Dim dt As DATE_, ST As SYSTEMTIME
	FileTimeToSystemTime(@FT, @ST)
	SystemTimeToVariantTime @ST, @dt
	Return dt
End Function

Function GetFileLastWriteTime(ByRef FileName As WString) As FILETIME
	Dim fd As WIN32_FIND_DATAW
	Dim hFind As HANDLE = FindFirstFile(FileName, @fd)
	If hFind <> INVALID_HANDLE_VALUE Then
		FindClose hFind
		Return fd.ftLastWriteTime
	End If
End Function

Sub SetAsMain(IsTab As Boolean)
	Dim As TreeNode Ptr tn, ptn
	If IsTab AndAlso ptabCode->SelectedTab <> 0 Then
		tn = Cast(TabWindow Ptr, ptabCode->SelectedTab)->tn
	Else
		tn = tvExplorer.SelectedNode
	End If
	If CInt(ptabCode->Focused) AndAlso CInt(ptabCode->SelectedTab <> 0) Then tn = Cast(TabWindow Ptr, ptabCode->SelectedTab)->tn
	If tn = 0 Then Exit Sub Else ptn = GetParentNode(tn)
	If tn->ParentNode = 0 OrElse (ptn <> 0 AndAlso ptn->ImageKey = "Opened") OrElse (tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement) Then
		SetMainNode tn
		lblLeft.Text = ("Main Project") & ": " & MainNode->Text
	Else
		Dim As ExplorerElement Ptr ee = tn->Tag
		Dim As ProjectElement Ptr ppe
		Dim As WString * MAX_PATH tMainNode
		If ptn <> 0 Then
			ppe = ptn->Tag
			If ppe = 0 Then
				ppe = _New(ProjectElement)
				WLet(ppe->FileName, "")
				ptn->Tag = ppe
			ElseIf Not *Cast(ExplorerElement Ptr, ptn->Tag) Is ProjectElement Then
				Dim As UString FileName = *Cast(ExplorerElement Ptr, ppe)->FileName
				_Delete(Cast(ExplorerElement Ptr, ppe))
				ppe = _New(ProjectElement)
				WLet(ppe->FileName, FileName)
				ptn->Tag = ppe
				ptn->ImageKey = "Project"
				ptn->SelectedImageKey = "Project"
				ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder
				ChangeMenuItemsEnabled
			End If
			If ee <> 0 AndAlso ppe <> 0 Then
				'David Change
				'If *ee->FileName = *pee->Project->MainFileName OrElse *ee->FileName = *pee->Project->ResourceFileName Then Exit Sub
				If EndsWith(LCase(*ee->FileName), ".rc") OrElse EndsWith(LCase(*ee->FileName), ".xpm") OrElse EndsWith(LCase(*ee->FileName), ".bas") OrElse EndsWith(LCase(*ee->FileName), ".bi") OrElse EndsWith(LCase(*ee->FileName), ".frm") _
					OrElse EndsWith(LCase(*ee->FileName), ".inc") OrElse EndsWith(LCase(*ee->FileName), ".bat") OrElse CBool(LCase(GetFileName(*ee->FileName)) = "makefile") OrElse EndsWith(LCase(*ee->FileName), ".sh") OrElse InStr(*ee->FileName, ".") = 0 Then
					Dim As TreeNode Ptr tn1, tn2
					Dim As Integer tIndex
					Dim As String IconName
					If Not EndsWith(ptn->Text, "*") Then ptn->Text &= "*"
					If EndsWith(LCase(*ee->FileName), ".rc") Then
						WLet(ppe->ResourceFileName, *ee->FileName)
					ElseIf EndsWith(LCase(*ee->FileName), ".xpm") Then
						WLet(ppe->IconResourceFileName, *ee->FileName)
					ElseIf LCase(GetFileName(*ee->FileName)) = "makefile" Then
						WLet(ppe->BatchCompilationFileNameWindows, *ee->FileName)
						WLet(ppe->BatchCompilationFileNameLinux, *ee->FileName)
					ElseIf EndsWith(LCase(*ee->FileName), ".bat") Then
						WLet(ppe->BatchCompilationFileNameWindows, *ee->FileName)
					ElseIf EndsWith(LCase(*ee->FileName), ".sh") OrElse InStr(*ee->FileName, ".") = 0 Then
						WLet(ppe->BatchCompilationFileNameLinux, *ee->FileName)
					Else
						WLet(ppe->MainFileName, *ee->FileName)
					End If
					If Not ppe->Files.Contains(*ee->FileName) Then
						ppe->Files.Add *ee->FileName
					End If
					IconName = GetIconName(WGet(ee->FileName), ppe)
					If MainNode <> 0 Then MainNode->Bold = False
					MainNode = ptn 'MainNode must be root node
					MainNode->Bold = True
					tn->ImageKey = IconName
					tn->SelectedImageKey = IconName
					tMainNode = *ee->FileName
					For i As Integer = 0 To ptn->Nodes.Count - 1
						tn1 = ptn->Nodes.Item(i)
						If tn1->Nodes.Count = 0 Then
							If StartsWith(tn1->ImageKey, "Main") Then
								ee = tn1->Tag
								If ee <> 0 Then
									tn1->ImageKey = GetIconName(WGet(ee->FileName), ppe)
									tn1->SelectedImageKey = tn1->ImageKey
								End If
							End If
						Else
							For j As Integer = tn1->Nodes.Count - 1 To 0 Step -1
								tn2 = tn1->Nodes.Item(j)
								If StartsWith(tn2->ImageKey, "Main") Then
									ee = tn2->Tag
									If ee <> 0 Then
										tn2->ImageKey = GetIconName(WGet(ee->FileName), ppe)
										tn2->SelectedImageKey = tn2->ImageKey
									End If
								End If
							Next
						End If
					Next
					'					If tn1->Nodes.Count=1 Then 'Only one file
					'						tn1->Nodes.Remove(0)
					'						tn = tn1->Nodes.Add(GetFileName(*ee->FileName),, *ee->FileName, IconName, IconName, True)
					'						tn->Tag = ee
					'					End If
				End If
			End If
		End If
		'SaveProject ptn
	End If
End Sub

Sub Save()
	If tvExplorer.Focused Then
		Dim tn As TreeNode Ptr = GetParentNode(tvExplorer.SelectedNode)
		If tn = 0 Then Exit Sub
		If tn->ImageKey = "Project" Then
			SaveProject tn
			'		Else
			'			Dim tb As TabWindow Ptr
			'			If tn = 0 Then Exit Sub
			'			For i As Integer = 0 To ptabCode->TabCount - 1
			'				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			'				If tb->tn = tn Then
			'					tb->Save
			'					Exit For
			'				End If
			'			Next i
		End If
	Else
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		tb->Save
	End If
End Sub

Function NodeInProject(node As TreeNode Ptr, proj As TreeNode Ptr) As Boolean
	' True if 'node' is 'proj' or any descendant of it (walk up the parent chain).
	Dim As TreeNode Ptr n = node
	Do While n <> 0
		If n = proj Then Return True
		n = n->ParentNode
	Loop
	Return False
End Function

Function CloseProject(tn As TreeNode Ptr, WithoutMessage As Boolean = False) As Boolean
	If tn = 0 Then Return True
	If tn->ImageKey <> "Project" AndAlso tn->ImageKey <> "MainProject" AndAlso tn->ImageKey <> "Opened" Then Return True
	Dim tb As TabWindow Ptr
	Dim As Boolean bProjectModified = EndsWith(tn->Text, "*")
	DbgTrace("CloseProj.enter", "tn=" & Str(CInt(tn <> 0)))
	If Not WithoutMessage Then
		Dim tnP As TreeNode Ptr
		Dim Index As Integer
		With *pfSave
			.lstFiles.Clear
			If bProjectModified Then .lstFiles.AddItem tn->Text, tn
			'' B1: remind the owner what's about to actually vanish from disk when they
			'' click Yes -- these rows are informational only (ItemData=0, skipped below;
			'' the files themselves get Kill'd as part of SaveProject once the project row
			'' above is processed, not individually here).
			Dim As TreeNode Ptr tnPend1, tnPend2
			Dim As ExplorerElement Ptr eePend
			For i As Integer = 0 To tn->Nodes.Count - 1
				tnPend1 = tn->Nodes.Item(i)
				eePend = tnPend1->Tag
				If eePend <> 0 AndAlso eePend->PendingDelete Then
					.lstFiles.AddItem WSpace(2) & GetFileName(WGet(eePend->FileName)) & " " & ("(delete pending)"), 0
				ElseIf tnPend1->Nodes.Count > 0 Then
					For j As Integer = 0 To tnPend1->Nodes.Count - 1
						tnPend2 = tnPend1->Nodes.Item(j)
						eePend = tnPend2->Tag
						If eePend <> 0 AndAlso eePend->PendingDelete Then
							.lstFiles.AddItem WSpace(2) & GetFileName(WGet(eePend->FileName)) & " " & ("(delete pending)"), 0
						End If
					Next j
				End If
			Next i
			For j As Integer = TabPanels.Count - 1 To 0 Step -1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
				For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
					tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
					If tb->Modified Then
						tnP = tb->ptn
						If tnP = tn Then
							.lstFiles.AddItem IIf(bProjectModified, WSpace(2), WStr("")) & tb->Caption, tb
						End If
					End If
				Next i
			Next j
			If .lstFiles.ItemCount > 0 Then
				Select Case .ShowModal(*pfrmMain)
				Case ModalResults.Yes
					'' B1: clicking Yes/No/Cancel closes pfSave via WM_CLOSE, which (no OnClose
					'' override sets Action to "hide") really destroys the native listbox --
					'' so .lstFiles.Selected() reads back False for everything once ShowModal
					'' has returned. Read .SelectedItems instead: it's captured inside
					'' cmdYes_Click, before the window is torn down (same pattern already used
					'' by the sibling CloseAllDocuments). ItemData=0 rows are the "(delete
					'' pending)" informational entries -- skip those same as before.
					For i As Integer = .SelectedItems.Count - 1 To 0 Step -1
						If .SelectedItems.Item(i) <> 0 Then
							If tvExplorer.Nodes.Contains(.SelectedItems.Item(i)) Then
								If Not SaveProject(.SelectedItems.Item(i)) Then Return False
							Else
								If Not Cast(TabWindow Ptr, .SelectedItems.Item(i))->Save Then Return False
							End If
						End If
					Next
				Case ModalResults.No
				Case Else: Return False '' Cancel, or the dialog closed via the window's X (ShowModal
				'' returns ModalResults.None then, which otherwise matches neither Yes nor No and
				'' silently falls through to continue the close without saving -- treat anything
				'' unrecognized as Cancel instead, since this dialog guards a destructive action.
				End Select
			End If
		End With
	End If
	' Close every tab belonging to this project BEFORE freeing/removing the project node.
	' Otherwise leftover tabs keep dangling pointers into the freed project data and the app
	' hangs/faults on the next interaction (owner-reported 2026-07-07). Match by tree-node
	' ancestry (robust even if tb->ptn is stale) as well as the direct ptn pointer, and re-scan
	' after each close since CloseTab mutates the tab list.
	Dim As Boolean bClosedTab
	Do
		bClosedTab = False
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				If tb <> 0 AndAlso (tb->ptn = tn OrElse NodeInProject(tb->tn, tn)) Then
					If Not CloseTab(tb, True) Then Return False
					bClosedTab = True
					Exit For
				End If
			Next i
			If bClosedTab Then Exit For
		Next jj
	Loop While bClosedTab
	DbgTrace("CloseProj.tabsClosed", "")
	' SAFETY: if any tab still references this project, bail WITHOUT freeing (no dangling-ref hang).
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb <> 0 AndAlso (tb->ptn = tn OrElse NodeInProject(tb->tn, tn)) Then
				Return False
			End If
		Next i
	Next jj
	DbgTrace("CloseProj.safetyPassed", "")
	For j As Integer = tn->Nodes.Count - 1 To 0 Step -1
		If tn->Nodes.Item(j)->Nodes.Count = 0 Then
			'For jj As Integer = 0 To TabPanels.Count - 1
			'	Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			'	For i As Integer = 0 To ptabCode->TabCount - 1
			'		tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			'		If tn->Nodes.Item(j) = tb->tn Then
			'			If Not CloseTab(tb, True) Then Return False
			'			Exit For
			'		End If
			'	Next i
			'Next jj
			If tn->Nodes.Item(j)->Tag <> 0 Then
				Dim As ExplorerElement Ptr eeClose = Cast(ExplorerElement Ptr, tn->Nodes.Item(j)->Tag)
				'' Never got a real project-folder home (project closed without saving) --
				'' delete the staged Temp/ copy instead of leaving it there forever. If it
				'' *was* saved, SaveProjectFile already cleared PendingInTemp, so this is a
				'' no-op in that case.
				If eeClose->PendingInTemp AndAlso Dir(*eeClose->FileName) <> "" Then Kill *eeClose->FileName
				_Delete(eeClose): tn->Nodes.Item(j)->Tag = 0 ' null after free: Nodes.Remove below fires tvExplorer_SelChange, which derefs Tag in an Is-check
			End If
		Else
			For k As Integer = tn->Nodes.Item(j)->Nodes.Count - 1 To 0 Step - 1 '
				'For jj As Integer = 0 To TabPanels.Count - 1
				'	Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
				'	For i As Integer = 0 To ptabCode->TabCount - 1
				'		tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				'		If tn->Nodes.Item(j)->Nodes.Item(k) = tb->tn Then
				'			If Not CloseTab(tb, True) Then Return False
				'			Exit For
				'		End If
				'	Next i
				'Next jj
				If tn->Nodes.Item(j)->Nodes.Item(k)->Tag <> 0 Then
					Dim As ExplorerElement Ptr eeClose2 = Cast(ExplorerElement Ptr, tn->Nodes.Item(j)->Nodes.Item(k)->Tag)
					If eeClose2->PendingInTemp AndAlso Dir(*eeClose2->FileName) <> "" Then Kill *eeClose2->FileName
					_Delete(eeClose2): tn->Nodes.Item(j)->Nodes.Item(k)->Tag = 0 ' null after free (dangling-Tag Is-check crash)
				End If
			Next k
		End If
	Next
	DbgTrace("CloseProj.nodesFreed", "")
	'	If bProjectModified AndAlso Not WithoutMessage Then
	'		Select Case MsgBox(ML("Want to save the project") & " """ & tn->Text & """?", "Astoria IDE", mtWarning, btYesNoCancel)
	'		Case mrYES: If Not SaveProject(tn) Then Return False
	'		Case mrNO:
	'		Case mrCANCEL: Return False
	'		End Select
	'	End If
	If tn = MainNode Then SetMainNode 0
	If tn->Tag <> 0 Then _Delete(Cast(ProjectElement Ptr, tn->Tag)): tn->Tag = 0 ' null after free: Nodes.Remove below fires tvExplorer_SelChange -> *Tag Is ... (fb_IsTypeOf on freed vtable = SIGSEGV)
	'miSaveProject->Enabled = False
	'miSaveProjectAs->Enabled = False
	'miCloseProject->Enabled = False
	'miExplorerCloseProject->Enabled = False
	'miProjectProperties->Enabled = False
	'miExplorerProjectProperties->Enabled = False
	DbgTrace("CloseProj.beforeNodesRemove", "")
	If tvExplorer.Nodes.IndexOf(tn) <> -1 Then tvExplorer.Nodes.Remove tvExplorer.Nodes.IndexOf(tn)
	DbgTrace("CloseProj.afterNodesRemove", "")
	DbgTrace("CloseProj.clearAnalysis", "")
	ClearAnalysisPanels()
	DbgTrace("CloseProj.clearDebug", "")
	ClearDebugPanels()
	DbgTrace("CloseProj.changeUseDbg", "")
	ChangeUseDebugger False, 1
	DbgTrace("CloseProj.changeMenus", "")
	ChangeMenuItemsEnabled
	DbgTrace("CloseProj.done", "")
	Return True
End Function

' User-facing "Close Project" (File menu + Explorer right-click). Target-audience UX (owner,
' 2026-07-11): closing a project resets to a clean, empty environment -- every open file closes
' too -- and clears the saved session so the next app launch starts clean (doesn't reopen the
' project). Internal CloseProject callers (CloseSession, CloseAllTabs' sweep) are unaffected.
Sub CloseProjectAndClean(tn As TreeNode Ptr)
	If Not CloseProject(tn) Then Exit Sub   ' user cancelled an unsaved-changes prompt -> leave things as-is
	CloseAllTabs()                          ' close any remaining (standalone) files + any now-empty projects
	If Not WorkspaceHasOpenItems() Then ClearWorkspaceFile()   ' clean next start, immediately (survives a force-kill)
End Sub

Function DeleteProject() As Boolean
	Dim As TreeNode Ptr tn = GetParentNode(ptvExplorer->SelectedNode)
	If tn = 0 Then Return False
	If tn->Tag = 0 Then Return False
	If MsgBox(("Are you sure you want to delete the project") & " """ & tn->Text & """?", "Astoria IDE", mtWarning, btYesNo) <> mrYes Then Return False
	'' Read the project's path before CloseProject runs -- it frees tn->Tag (the
	'' ProjectElement) and nulls it as part of its normal cleanup, so reading it
	'' afterward dereferenced a freed/null pointer and crashed before the actual
	'' folder delete below ever ran.
	Dim As ProjectElement Ptr ppe = Cast(ProjectElement Ptr, tn->Tag)
	Dim As UString ProjectPath = GetFolderName(WGet(ppe->FileName), False)
	If Not CloseProject(tn, True) Then Return False
	'' FolderExists (the legacy Dir()-based check) doesn't match a bare directory
	'' path at all -- Dir() only enumerates against a wildcard, so a path with no
	'' "*" in it always came back with nothing found, regardless of trailing slash.
	'' FolderExistsU (PathUtils.bas, GetFileAttributesW-based) actually answers
	'' "does this exact path exist and is it a directory" correctly.
	If ProjectPath <> "" AndAlso FolderExistsU(ProjectPath) Then
		'' Opening/running a project ChDir's into its folder (see BUILD.md) -- Windows
		'' refuses to remove a directory that's any process's current directory, and
		'' since this inherits our CWD (PipeCmd passes no lpCurrentDirectory) that
		'' silently no-ops "rd" if the project we just closed left us sitting inside
		'' it. Step out to somewhere unrelated to the project first.
		ChDir ExePath
		'' T4: native delete via SHFileOperationW instead of a shelled "rd /s /q" --
		'' no cmd.exe round-trip, sends the folder to the Recycle Bin (FOF_ALLOWUNDO)
		'' rather than a permanent delete, and a failure surfaces through our own
		'' MsgBox (F1 feedback-channel policy: irreversible action = MsgBox tier)
		'' instead of failing silently the way the shelled "rd" did.
		'' pFrom must be double-null-terminated; ZeroMemory the whole fixed buffer
		'' first so everything past the path's own terminator is guaranteed zero
		'' rather than whatever was already on the stack.
		'' F-T16-2 (T16 review): SHFileOperationW is a shell API and doesn't reliably
		'' accept forward slashes; this codebase mixes "/" and "\" freely (ProjectPath
		'' is derived from GetFolderName, which preserves whatever separator the
		'' project's own path used). Normalize the same way OpenProjectFolder already
		'' does before its own shell call.
		Dim As WString * 1024 wDeletePath
		ZeroMemory(@wDeletePath, SizeOf(wDeletePath))
		wDeletePath = CanonicalWinPath(ProjectPath)
		Dim As SHFILEOPSTRUCTW fos
		ZeroMemory(@fos, SizeOf(fos))
		fos.wFunc = FO_DELETE
		fos.pFrom = @wDeletePath
		fos.fFlags = FOF_ALLOWUNDO Or FOF_NO_UI
		Dim As Long DeleteResult = SHFileOperationW(@fos)
		If DeleteResult <> 0 OrElse fos.fAnyOperationsAborted Then
			MsgBox ("Couldn't delete the project folder") & ":" & WChr(13,10) & ProjectPath, "Astoria IDE", mtError
			Return False
		End If
	End If
	Return True
End Function

Sub NextBookmark(iTo As Integer = 1)
	If ptabCode->SelectedTab = 0 Then Exit Sub
	Dim As Integer i, j, k, n, iStart, iEnd, iStartLine, iEndLine
	Dim As EditControl Ptr txt
	Dim As EditControlLine Ptr FECLine
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As Integer CurTabIndex = ptabCode->SelectedTab->Index
	If iTo = 1 Then
		iStart = 0
		iEnd = ptabCode->TabCount - 1
	Else
		iStart = ptabCode->TabCount - 1
		iEnd = 0
	End If
	For k = 1 To 2
		For j = IIf(k = 1, CurTabIndex, iStart) To IIf(k = 1, iEnd, CurTabIndex) Step iTo
			txt = @Cast(TabWindow Ptr, ptabCode->Tabs[j])->txtCode
			If iTo = 1 Then
				iStartLine = 0
				iEndLine = txt->Content.Lines.Count - 1
			Else
				iStartLine = txt->Content.Lines.Count - 1
				iEndLine = 0
			End If
			If k = 1 AndAlso j = CurTabIndex Then
				txt->GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				n = iSelEndLine + iTo
			Else
				n = iStartLine
			End If
			For i = n To iEndLine Step iTo
				FECLine = txt->Content.Lines.Items[i]
				If FECLine->Bookmark Then
					ptabCode->Tabs[j]->SelectTab
					txt->SetSelection i, i, 0, 0
					Exit Sub
				End If
			Next
		Next j
	Next k
End Sub

Sub ClearAllBookmarks
	For j As Integer = 0 To TabPanels.Count - 1
		
		For i As Integer = 0 To ptabCode->TabCount -1
			Cast(TabWindow Ptr, ptabCode->Tabs[i])->txtCode.ClearAllBookmarks
		Next
	Next
End Sub

Sub ClearAllBreakpoints
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			Cast(TabWindow Ptr, ptabCode->Tabs[i])->txtCode.ClearAllBreakpoints
		Next
	Next
End Sub

Sub ChangeUseProfiler(bUseProfiler As Boolean, ChangeObject As Integer = -1)
	If Not UseDebugger Then bUseProfiler = False
	If mnuUseProfiler <> 0 AndAlso mnuUseProfiler->Checked <> bUseProfiler Then mnuUseProfiler->Checked = bUseProfiler
End Sub

Sub ChangeUseDebugger(bUseDebugger As Boolean, ChangeObject As Integer = -1)
	UseDebugger = bUseDebugger
	If ChangeObject <> 0 AndAlso tbtUseDebugger <> 0 Then tbtUseDebugger->Checked = bUseDebugger
	If mnuUseDebugger <> 0 AndAlso mnuUseDebugger->Checked <> bUseDebugger Then mnuUseDebugger->Checked = bUseDebugger
	SetDebugTabsVisible bUseDebugger
	If Not bUseDebugger Then ChangeUseProfiler False
	If mnuUseProfiler <> 0 Then mnuUseProfiler->Enabled = bUseDebugger
	If miDebugWindows <> 0 Then miDebugWindows->Enabled = bUseDebugger
	If iFlagStartDebug = 0 Then ChangeEnabledDebug True, False, False
End Sub

Sub ChangeShowSymbolsTooltipsOnMouseHover(bEnabled As Boolean, ChangeObject As Integer = -1)
	GlobalSettings.ShowSymbolsTooltipsOnMouseHover = bEnabled
	If Not bEnabled AndAlso ptabCode <> 0 Then
		For i As Integer = 0 To ptabCode->TabCount - 1
			Var tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb <> 0 AndAlso tb->txtCode.MouseHoverToolTipShowed Then tb->txtCode.CloseMouseHoverToolTip
		Next
	End If
	'' C2: miSuggestions removed (Edit menu) -- the setting now lives only in Options.
	iniSettings.WriteBool "Options", "ShowSymbolsTooltipsOnMouseHover", bEnabled
End Sub

Sub ChangeAutoComplete(bEnabled As Boolean, ChangeObject As Integer = -1)
	AutoComplete = bEnabled
	'' C2: miCompleteWord removed (Edit menu) -- the setting now lives only in Options.
	iniSettings.WriteBool "Options", "AutoComplete", bEnabled
End Sub

Sub ChangeParameterInfo(bEnabled As Boolean, ChangeObject As Integer = -1)
	ParameterInfoShow = bEnabled
	If Not bEnabled AndAlso ptabCode <> 0 Then
		For i As Integer = 0 To ptabCode->TabCount - 1
			Var tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb <> 0 AndAlso tb->txtCode.ToolTipShowed Then tb->txtCode.CloseToolTip
		Next
	End If
	'' C2: miParameterInfo is now a plain "invoke now" command, not a toggle -- it no longer
	'' reflects this setting's Checked state (only the Options checkbox does).
	iniSettings.WriteBool "Options", "ParameterInfoShow", bEnabled
End Sub

Sub ChangeLockControls(bLockControls As Boolean, ChangeObject As Integer = -1)
	LockControls = bLockControls
	If ChangeObject <> 0 Then tbtLockControls->Checked = bLockControls
	If ChangeObject <> 1 AndAlso miLockControls->Checked <> LockControls Then miLockControls->Checked = bLockControls: mnuDesigner.Item("LockControls")->Checked = bLockControls
End Sub

Sub ChangeFileEncoding(FileEncoding As FileEncodings)
	'' Status-bar panel 3 was the file-encoding readout, but UTF-8 is the only
	'' supported encoding, so it never varied. The panel now shows the MCP agent
	'' state instead (see UpdateMcpAgentStatusBar); this hook is kept as a no-op
	'' for its call sites.
End Sub

'' Reflect the agent pipe's live state in the repurposed status-bar panel (3).
Sub UpdateMcpAgentStatusBar()
	If stBar.Count > 3 Then
		If AgentPipeActive() Then
			stBar.Panels[3]->Caption = "MCP Agent: On"
		Else
			stBar.Panels[3]->Caption = "MCP Agent: Off"
		End If
	End If
End Sub

Sub ChangeNewLineType(NewLineType As NewLineTypes)
	If stBar.Count > 4 Then stBar.Panels[4]->Caption = "CR+LF"
End Sub

Sub ChangeEnabledDebug(bStart As Boolean, bBreak As Boolean, bEnd As Boolean)
	Dim As Boolean bStopped = UseDebugger AndAlso bEnd
	Dim As Boolean bDebugCommands = UseDebugger AndAlso (bStopped OrElse (bStart AndAlso Not bBreak))
	tbtStartWithCompile->Enabled = bStart
	tbtStart->Enabled = bStart OrElse bEnd
	tbtBreak->Enabled = bBreak
	tbtEnd->Enabled = bEnd
	mnuStartWithCompile->Enabled = bStart
	mnuStart->Enabled = bStart OrElse bEnd
	mnuContinue->Enabled = bStopped
	mnuBreak->Enabled = bBreak
	mnuEnd->Enabled = bEnd
	mnuRestart->Enabled = UseDebugger AndAlso bStart AndAlso bStopped
	miStepInto->Enabled = bDebugCommands
	miStepOver->Enabled = bDebugCommands
	miStepOut->Enabled = bDebugCommands
	miRunToCursor->Enabled = bDebugCommands
	miGDBCommand->Enabled = bDebugCommands
	miAddWatch->Enabled = bDebugCommands
	miShowNextStatement->Enabled = bDebugCommands
	miSetNextStatement->Enabled = bDebugCommands
	tbtStepInto->Enabled = bDebugCommands
	tbtStepOver->Enabled = bDebugCommands
	tbtStepOut->Enabled = bDebugCommands
	tbtRunToCursor->Enabled = bDebugCommands
	tbtSetNextStatement->Enabled = bDebugCommands
	'' Code-pane right-click mirrors of the same debug commands -- owner decision
	'' (2026-07-16): context menus grey by context exactly like the main menus, so
	'' these three no longer offer debugger actions while the debugger is off/busy.
	If mnuCode.Item("AddWatch") Then mnuCode.Item("AddWatch")->Enabled = bDebugCommands
	If mnuCode.Item("RunToCursor") Then mnuCode.Item("RunToCursor")->Enabled = bDebugCommands
	If mnuCode.Item("SetNextStatement") Then mnuCode.Item("SetNextStatement")->Enabled = bDebugCommands
	tbtToggleBreakpoint->Enabled = True
	If mnuUseProfiler <> 0 Then mnuUseProfiler->Enabled = UseDebugger
	SetDebugTabsVisible UseDebugger
End Sub


	Function TimerProcGDB() As Integer
		FillDebugPanelsOnUI()   ' DR-3 2D: fill debug panels on the UI thread (no-op unless the worker staged data)
		FlushDebugOutputOnUI()  ' DR-7: apply queued Output text / watch-edit / panel-clear (no-op unless staged)
		If bCloseDebugTabsPending Then bCloseDebugTabsPending = False : CloseDebuggerOpenedTabs()   ' close-on-stop (UI thread)
		If fcurlig < 1 AndAlso fcurlig <> -2 Then Return 1
		DbgTrace("Timer.act", "fcurlig=" & fcurlig & " branch=" & IIf(fcurlig <> -2, "highlight", "output") & " file=" & DbgTraceEsc(CurrentFile))
		ChangeEnabledDebug True, False, True
		If fcurlig <> -2 Then
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			If tb = 0 OrElse Not EqualPaths(tb->FileName, CurrentFile) Then
				' close-on-stop: if the debugger opens a file that wasn't already open, flag the
				' new tab so it's closed again when debugging ends (framework #include etc.).
				Dim As Boolean bWasOpen = (GetTab(CurrentFile) <> 0)
				tb = AddTab(CurrentFile)
				If tb <> 0 AndAlso Not bWasOpen Then tb->OpenedByDebugger = True
			End If
			If tb Then
				CurEC = @tb->txtCode
				tb->txtCode.CurExecutedLine = fcurlig - 1
				tb->txtCode.SetSelection fcurlig - 1, fcurlig - 1, 0, 0
				tb->txtCode.PaintControl
			End If
		Else
			tpOutput->SelectTab
			txtOutput.SetSel txtOutput.GetTextLength, txtOutput.GetTextLength
			txtOutput.ScrollToCaret
		End If
		'info_all_variables_debug()
			SetForegroundWindow pApp->MainForm->Handle
		fcurlig = -1
		Return 1
	End Function

	Sub CloseDebuggerOpenedTabs()
		' UI thread (called from TimerProcGDB when deinit flags bCloseDebugTabsPending). Close the tabs
		' the debugger auto-opened (OpenedByDebugger) now that the session ended, skipping any with
		' unsaved edits. Re-scan after each close since CloseTab mutates the tab list.
		Dim As Boolean bClosed
		Do
			bClosed = False
			For jj As Integer = 0 To TabPanels.Count - 1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
				For i As Integer = 0 To ptabCode->TabCount - 1
					Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
					If CInt(tb <> 0) AndAlso CInt(tb->OpenedByDebugger) AndAlso CInt(Not tb->Modified) Then
						tb->OpenedByDebugger = False
						If CloseTab(tb, True) Then bClosed = True : Exit For
					End If
				Next i
				If bClosed Then Exit For
			Next jj
		Loop While bClosed
	End Sub

Function EqualPaths(ByRef a As WString, ByRef b As WString) As Boolean
	Dim FileNameLeft As WString Ptr
	Dim FileNameRight As WString Ptr
	WLet(FileNameLeft, Replace(a, "\", "/"))
	If EndsWith(*FileNameLeft, ":") Then *FileNameLeft = Left(*FileNameLeft, Len(*FileNameLeft) - 1)
	WLet(FileNameRight, Replace(b, "\", "/"))
	EqualPaths = LCase(*FileNameLeft) = LCase(*FileNameRight)
	WDeAllocate(FileNameLeft)
	WDeAllocate(FileNameRight)
End Function

Sub ChangeTabsTn(TnPrev As TreeNode Ptr, Tn As TreeNode Ptr)
	Dim tb As TabWindow Ptr
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb->tn = TnPrev Then
				tb->tn = Tn
				If ptabCode->SelectedTab = ptabCode->Tabs[i] Then Tn->SelectItem
				Exit For
			End If
		Next
	Next
End Sub

Declare Sub tvExplorer_NodeExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeNode, ByRef Cancel As Boolean)

Dim Shared bNotExpand As Boolean
Sub ChangeFolderType(Value As ProjectFolderTypes)
	Dim As TreeNode Ptr tn = tvExplorer.SelectedNode
	Select Case Value
	Case ProjectFolderTypes.ShowWithFolders: miShowWithFolders->RadioItem = True: ShowProjectFolders = True
	Case ProjectFolderTypes.ShowWithoutFolders: miShowWithoutFolders->RadioItem = True: ShowProjectFolders = False
	Case ProjectFolderTypes.ShowAsFolder: miShowAsFolder->RadioItem = True
	End Select
	If tn = 0 Then Exit Sub
	tn = GetParentNode(tn)
	If tn = 0 OrElse tn->Tag = 0 Then Exit Sub
	If tn->ImageKey <> "Project" Then Exit Sub
	Dim As ProjectElement Ptr ppe = Cast(ProjectElement Ptr, tn->Tag)
	Dim As ExplorerElement Ptr ee
	Dim As Boolean bFolderTypeChanged = (ppe->ProjectFolderType <> Value)
	If bFolderTypeChanged Then
		If ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Then
			bNotExpand = True
			ClearTreeNode tn
			bNotExpand = False
		End If
		Dim As TreeNode Ptr tnF, tnI, tnS, tnR, tnO
		Dim As TreeNode Ptr tn1, tn2
		If Value = ProjectFolderTypes.ShowWithFolders Then
			tnI = tn->Nodes.Add(("Includes"), "Includes", , "Opened", "Opened")
			tnF = tn->Nodes.Add(("Forms"), "Forms", , "Opened", "Opened")
			tnS = tn->Nodes.Add(("Modules"), "Modules",, "Opened", "Opened") ' "Modules" is better than "Sources"
			tnR = tn->Nodes.Add(("Resources"), "Resources", , "Opened", "Opened")
			tnO = tn->Nodes.Add(("Others"), "Others", , "Opened", "Opened")
		End If
		If ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Then
			tn->Text = tn->Text & ".vfp"
			WLetEx(ppe->FileName, *ppe->FileName & WindowsSlash & GetFileName(*ppe->FileName) & ".vfp")
			Dim As String IconName
			For j As Integer = 0 To ppe->Files.Count - 1
				ee = _New(ExplorerElement)
				WLet(ee->FileName, ppe->Files.Item(j))
				IconName = GetIconName(*ee->FileName, ppe)
				If Value = ProjectFolderTypes.ShowWithFolders Then
					If EndsWith(LCase(*ee->FileName), ".bi") Then
						tn1 = tnI
					ElseIf EndsWith(LCase(*ee->FileName), ".bas") Then
						tn1 = tnS
					ElseIf EndsWith(LCase(*ee->FileName), ".frm") Then
						tn1 = tnF
					ElseIf EndsWith(LCase(*ee->FileName), ".rc") Then
						tn1 = tnR
					Else
						tn1 = tnO
					End If
					tn2 = tn1->Nodes.Add(GetFileName(*ee->FileName), , , IconName, IconName, True)
					tn2->Tag = ee
				ElseIf Value = ProjectFolderTypes.ShowWithoutFolders Then
					tn2 = tn->Nodes.Add(GetFileName(*ee->FileName), , , IconName, IconName, True)
					tn2->Tag = ee
				End If
			Next
			ppe->Files.Clear
		Else
			For j As Integer = tn->Nodes.Count - 1 To 0 Step -1
				If ppe->ProjectFolderType = ProjectFolderTypes.ShowWithoutFolders Then
					If tn->Nodes.Item(j)->Tag <> 0 Then
						If Value = ProjectFolderTypes.ShowWithFolders Then
							If EndsWith(LCase(tn->Nodes.Item(j)->Text), ".bi") Then
								tn1 = tnI
							ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".bas") Then
								tn1 = tnS
							ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".frm") Then
								tn1 = tnF
							ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".rc") Then
								tn1 = tnR
							Else
								tn1 = tnO
							End If
							tn2 = tn1->Nodes.Add(tn->Nodes.Item(j)->Text, , , tn->Nodes.Item(j)->ImageKey, tn->Nodes.Item(j)->ImageKey, True)
							tn2->Tag = tn->Nodes.Item(j)->Tag
							ChangeTabsTn tn->Nodes.Item(j), tn2
							'                        If tn->Expanded Then
							'
							'                        End If
							'tn1->Expand
							tn->Nodes.Remove j
						ElseIf Value = ProjectFolderTypes.ShowAsFolder Then
							ppe->Files.Add *Cast(ExplorerElement Ptr, tn->Nodes.Item(j)->Tag)->FileName
						End If
					End If
				ElseIf ppe->ProjectFolderType = ProjectFolderTypes.ShowWithFolders Then
					For k As Integer = 0 To tn->Nodes.Item(j)->Nodes.Count - 1
						If Value = ProjectFolderTypes.ShowWithoutFolders Then
							Dim iIndex As Integer = -1
							For i As Integer = j + 1 To tn->Nodes.Count - 1
								If LCase(tn->Nodes.Item(i)->Text) > LCase(tn->Nodes.Item(j)->Nodes.Item(k)->Text) Then
									iIndex = i
									Exit For
								End If
							Next
							tn2 = tn->Nodes.Insert(iIndex, tn->Nodes.Item(j)->Nodes.Item(k)->Text, , , tn->Nodes.Item(j)->Nodes.Item(k)->ImageKey, tn->Nodes.Item(j)->Nodes.Item(k)->ImageKey)
							tn2->Tag = tn->Nodes.Item(j)->Nodes.Item(k)->Tag
							ChangeTabsTn tn->Nodes.Item(j)->Nodes.Item(k), tn2
						ElseIf Value = ProjectFolderTypes.ShowAsFolder Then
							ppe->Files.Add *Cast(ExplorerElement Ptr, tn->Nodes.Item(j)->Nodes.Item(k)->Tag)->FileName
						End If
					Next k
					If Value = ProjectFolderTypes.ShowWithoutFolders Then
						tn->Nodes.Remove j
					End If
				End If
			Next
			If Value = ProjectFolderTypes.ShowAsFolder Then
				tn->Text = GetFileName(GetFolderName(*ppe->FileName, False))
				WLet(ppe->FileName, GetFolderName(*ppe->FileName, False))
				tvExplorer_NodeExpanding(*tvExplorer.Designer, tvExplorer, *tn, False)
			End If
		End If
	End If
	ppe->ProjectFolderType = Value
	If bFolderTypeChanged Then EnsureChangeLogTreeNode(tn)
End Sub

Sub CompileProgram(Param As Any Ptr)
	'If Compile Then RunProgram(0) ', Run Program after compiled with FBC.exe only here.
	Compile
End Sub

Sub CompileAll(Param As Any Ptr)
	'If Compile Then RunProgram(0) ', Run Program after compiled with FBC.exe only here.
	Compile(, True)
End Sub

Sub CompileAndRun(Param As Any Ptr)
	Compile("Run")
	ThreadsEnter
	ChangeEnabledDebug True, False, False
	ThreadsLeave
End Sub

Sub MakeExecute(Param As Any Ptr)
	Compile("Make")
End Sub

Sub MakeClean(Param As Any Ptr)
	Compile("MakeClean")
End Sub

Sub SyntaxCheck(Param As Any Ptr)
	Compile("Check")
End Sub

Sub ToolBoxSelectNode(Node As TreeNode Ptr)
	If Node = 0 Then Exit Sub
	If Node->ParentNode = 0 Then
		' Category header: reset to Cursor without re-selecting a child (allows +/- collapse).
		SelectedClass = ""
		SelectedTool = 0
		SelectedToolNode = 0
		SelectedType = 0
		Exit Sub
	End If
	If Node->ImageKey = "Cursor" Then
		SelectedClass = ""
		SelectedTool = 0
		SelectedToolNode = 0
		SelectedType = 0
	Else
		SelectedClass = Node->ImageKey
		SelectedTool = 0
		SelectedToolNode = Node
		Dim te As TypeElement Ptr = Cast(TypeElement Ptr, Node->Tag)
		If te <> 0 Then SelectedType = te->ControlType
	End If
End Sub

Sub tvToolBox_SelChanged(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	ToolBoxSelectNode tvToolBox.SelectedNode
End Sub

Function GetToolBoxCategoryNode(CategoryIndex As Integer) As TreeNode Ptr
	Select Case CategoryIndex
	Case 1: Return tnToolControls
	Case 2: Return tnToolContainers
	Case 3: Return tnToolComponents
	Case 4: Return tnToolDialogs
	End Select
	Return 0
End Function

Function ToolBoxNodeExists(ParentNode As TreeNode Ptr, ByRef Key As WString) As Boolean
	If ParentNode = 0 Then Return False
	For i As Integer = 0 To ParentNode->Nodes.Count - 1
		If ParentNode->Nodes.Item(i)->ImageKey = Key Then Return True
	Next
	Return False
End Function

Sub InitToolBoxTree()
	tvToolBox.Nodes.Clear
	tnToolControls = tvToolBox.Nodes.Add(("Controls"), "Controls", "", "Folder", "Folder")
	tnToolContainers = tvToolBox.Nodes.Add(("Containers"), "Containers", "", "Folder", "Folder")
	tnToolComponents = tvToolBox.Nodes.Add(("Components"), "Components", "", "Folder", "Folder")
	tnToolDialogs = tvToolBox.Nodes.Add(("Dialogs"), "Dialogs", "", "Folder", "Folder")
	' One Cursor only, at the top of the tree. Upstream (VB/Delphi) gives every palette page
	' its own pointer because only one page is visible at a time; here all four groups are
	' expanded at once, so four identical entries just read as a glitch. Clicking a category
	' header also resets to Cursor (see ToolBoxSelectNode), so each group keeps a deselect
	' directly above it.
	tnToolControls->Nodes.Add("Cursor", "Cursor", "", "Cursor", "Cursor")
	tnToolControls->Expand()
	tnToolContainers->Expand()
	tnToolComponents->Expand()
	tnToolDialogs->Expand()
End Sub

Sub tvToolBox_NodeActivate(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	If Item.ParentNode = 0 AndAlso Item.Nodes.Count > 0 Then
		If Item.IsExpanded Then Item.Collapse Else Item.Expand
		Exit Sub
	End If
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	ToolBoxSelectNode tvToolBox.SelectedNode
	If SelectedClass = "" Then Exit Sub
	Dim As String FName, FClass = SelectedClass
	If tb->Des->OnInsertingControl Then
		FName = SelectedClass
		tb->Des->OnInsertingControl(*(tb->Des), SelectedClass, FName)
	End If
	Dim As ..Rect R
	Dim ctr As Any Ptr
	ctr = tb->Des->DesignControl
	Dim As Integer iLeft, iTop, iWidth, iHeight
	tb->Des->GetControlBounds(ctr, iLeft, iTop, iWidth, iHeight)
	If SelectedType = 3 Or SelectedType = 4 Then
		Dim cpnt As Any Ptr = tb->Des->CreateComponent(SelectedClass, FName, ctr, (iWidth - 16) / 2, (iHeight - 16) / 2)
		If tb->Des->OnInsertComponent Then tb->Des->OnInsertComponent(* (tb->Des), FClass, cpnt, 0, 0, (iWidth - 16) / 2, (iHeight - 16) / 2)
		If tb->Des->FSelControl Then tb->Des->SelectedControls.Clear
			tb->Des->MoveDots(cpnt)
	Else
		tb->Des->CreateControl(SelectedClass, FName, FName, ctr, (iWidth - 78) / 2, (iHeight - 36) / 2, 78, 36)
		If tb->Des->FSelControl Then
			tb->Des->SelectedControls.Clear
				LockWindowUpdate(tb->Des->FSelControl)
				BringWindowToTop(tb->Des->FSelControl)
			If tb->Des->OnInsertControl Then tb->Des->OnInsertControl(* (tb->Des), FClass, tb->Des->SelectedControl, 0, 0, (iWidth - 78) / 2, (iHeight - 36) / 2, 78, 36)
				tb->Des->MoveDots(tb->Des->SelectedControl)
				LockWindowUpdate(0)
		Else
			Dim cpnt As Any Ptr = tb->Des->CreateComponent(FClass, FName, ctr, (iWidth - 16) / 2, (iHeight - 16) / 2)
			If cpnt Then
				If tb->Des->OnInsertComponent Then tb->Des->OnInsertComponent(* (tb->Des), FClass, cpnt, 0, 0, (iWidth - 16) / 2, (iHeight - 16) / 2)
				If tb->Des->FSelControl Then tb->Des->SelectedControls.Clear
					tb->Des->MoveDots(cpnt)
			Else
				tb->Des->SelectedControl = tb->Des->DesignControl
				tb->Des->MoveDots(tb->Des->SelectedControl)
			End If
		End If
	End If
End Sub

' Controls hidden from the toolbox because they cannot be built. Both entries below ship a
' .bi whose implementation .bas was never included in MyFbFramework, so any project placing
' one fails at compile with "File not found". Nothing here can fix that -- the implementation
' has to come from upstream. WebBrowser was formerly listed here for a different reason (a
' ByRef WString returning a literal, since fixed in WebBrowser.bas) and is now available.
Function IsExcludedToolBoxControl(ControlName As String) As Boolean
	Select Case LCase(ControlName)
	Case "listviewex", "searchbar"
		Return True
	Case Else
		Return False
	End Select
End Function

Function GetTypeControl(ControlType As String) As Integer
	If Comps.Contains(ControlType) Then
		Var tbi = Cast(TypeElement Ptr, Comps.Object(Comps.IndexOf(ControlType))) 'Breakpoint
		Select Case LCase(tbi->TypeName)
		Case "control": Return 1
		Case "containercontrol": Return 2
		Case "component", "my.sys.componentmodel.component": Return 3
		Case "dialog": Return 4
		Case "": Return 0
		Case Else
			If ControlType = tbi->TypeName Then Return 0 Else Return GetTypeControl(tbi->TypeName)
		End Select
	Else
		Return 0
	End If
End Function

Sub pnlToolBox_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	tvToolBox.SetBounds 0, 0, NewWidth, NewHeight
End Sub

Function SetVisibleToToolBoxNode(Node As TreeNode Ptr, ByRef SearchText As WString) As Boolean
	Dim As Boolean bVisible
	If SearchText <> "" AndAlso Node->Nodes.Count > 0 Then
		Node->Expand
	End If
	For i As Integer = 0 To Node->Nodes.Count - 1
		If SetVisibleToToolBoxNode(Node->Nodes.Item(i), SearchText) Then bVisible = True
	Next
	If Node->ParentNode <> 0 Then
		If Not bVisible Then bVisible = SearchText = "" OrElse InStr(LCase(Node->Text), SearchText) > 0
		Node->Visible = bVisible
	End If
	Return bVisible
End Function

Function DirExists(ByRef DirPath As WString) As Integer
	Const InAttr = fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive
	Dim AttrTester As Integer, DirString As String
	DirString = Dir(DirPath, InAttr, AttrTester)
	If (AttrTester And fbDirectory) Then
		Return (-1)
	End If
	Return (0)
End Function

Function GetXY(XorY As Integer) As Integer
	Return IIf(XorY > 60000, XorY - 65535, XorY)
End Function

Function WithoutPointers(ByRef e As String) As String
	If EndsWith(LCase(e), " ptr") Then
		Return WithoutPointers(Trim(Left(e, Len(e) - 4)))
	ElseIf EndsWith(LCase(e), " pointer") Then
		Return WithoutPointers(Trim(Left(e, Len(e) - 8)))
	Else
		Return e
	End If
End Function

Function WithoutQuotes(ByRef e As UString) As UString
	Dim As UString s = e
	If StartsWith(s, """") Then s = Mid(s, 2)
	If EndsWith(s, """") Then s = Left(s, Len(s) - 1)
	Return Replace(s, """""", """")
End Function

Function DeleteSpaces(b As String) As String
	Dim iCount As Integer
	Dim bNew As String = b
	'	Do
	'		?bNew
	'		bNew = Replace(bNew, "  ", " ", , iCount)
	'		?bNew
	'		?iCount
	'	Loop While iCount > 0
	Return bNew
End Function

Sub LoadFunctions(ByRef Path As WString, LoadParameter As LoadParam = FilePathAndIncludeFiles, ByRef Types As WStringOrStringList, ByRef Enums As WStringOrStringList, ByRef Functions As WStringOrStringList, ByRef TypeProcedures As WStringOrStringList, ByRef Args As WStringOrStringList, ec As Control Ptr = 0, CtlLibrary As Library Ptr = 0, CurFileItem As Any Ptr = 0, OldFileItem As Any Ptr = 0)
	If FormClosing Then Exit Sub
	Dim As EditControlContent Ptr File = CurFileItem, OldFile = OldFileItem
	MutexLock tlockSave 'If LoadParameter <> LoadParam.OnlyFilePathOverwrite Then
	If LoadParameter <> LoadParam.OnlyIncludeFiles AndAlso LoadParameter <> LoadParam.OnlyFilePathOverwrite AndAlso LoadParameter <> LoadParam.OnlyFilePathOverwriteWithContent Then
		If ec = 0 Then
			If IncludeFiles.Contains(Path) Then
				MutexUnlock tlockSave
				Exit Sub
			Else
				If File = 0 Then
					File = _New(EditControlContent)
					File->FileName = Path
				End If
				IncludeFiles.Add Path, File
			End If
		End If
		If @Types = @Comps Then
			pfSplash->lblProcess.Text = Path
		End If
	End If
	Var Idx = -1
	If File = 0 Then
		If IncludeFiles.Contains(Path, , , , Idx) Then
			File = IncludeFiles.Object(Idx)
			If File = 0 Then
				File = _New(EditControlContent)
				File->FileName = Path
				IncludeFiles.Object(Idx) = File
			End If
		Else
			File = _New(EditControlContent)
			File->FileName = Path
			IncludeFiles.Add Path, File
		End If
		'ElseIf CurFileItem <> 0 AndAlso IncludeFiles.Contains(Path, , , , Idx) Then
		'	IncludeFiles.Object(Idx) = CurFileItem
	End If
	If OldFile <> 0 AndAlso OldFile->Includes.Contains(Path, , , , Idx) Then
		OldFile->Includes.Object(Idx) = File
	End If
	Dim As WString * 2048 b, b1, Comment, bTrim, bTrimLCase
	Dim As WString * 255 PathFunction, LoadFunctionPath
	Dim As String t, e, tOrig, bt, CurrentCondition
	Dim As Integer Pos1, Pos2, Pos3, Pos4, Pos5, l, n, nc, Index, iStart, i, j, iC, OldiC
	Dim As TypeElement Ptr te, tbi, typ, lastfunctionte
	Dim As Boolean inType, inUnion, inEnum, InFunc, InNamespace, InAsm, OldInType
	Dim As Boolean bTypeIsPointer
	Dim As Integer inPubProPri = 0
	Dim As Integer Result
	'Dim b As WString * 2048 ' for V1.07 Line Input not working fine
	Dim As EditControlLine Ptr FECLine
	Dim As Integer LastIndexFunction
	Dim As WStringList Lines, Namespaces, OldTypes
	Dim As IntegerList TypesPubProPri
	PathFunction = Path
	If ec <> 0 Then
		With *Cast(EditControl Ptr, ec)
			For i As Integer = 0 To .LinesCount - 1
				Lines.Add .Lines(i)
			Next
		End With
	Else
		Dim As Integer ff = FreeFile_
		Result = Open(PathFunction For Input Encoding "utf-32" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input Encoding "utf-16" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input Encoding "utf-8" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input As #ff)
		If Result = 0 Then
			inType = False
			i = 0
			Do Until EOF(ff)
				Line Input #ff, b
				If LoadParameter = LoadParam.OnlyFilePathOverwriteWithContent Then
					FECLine = _New( EditControlLine)
					If FECLine->Text = 0 Then
						MutexUnlock tlockSave
						Return
					End If
					WLet(FECLine->Text, b)
					If FECLine->Text = 0 Then
						MutexUnlock tlockSave
						Return
					End If
					File->Lines.Add(FECLine)
					iC = FindCommentIndex(b, OldiC)
					FECLine->CommentIndex = iC
					FECLine->InAsm = InAsm
					File->ChangeCollapsibility i
					If FECLine->ConstructionIndex = C_Asm Then
						InAsm = FECLine->ConstructionPart = 0
					End If
					FECLine->InAsm = InAsm
					OldiC = iC
					i += 1
				Else
					Lines.Add b
				End If
			Loop
		Else
			ThreadsEnter
			ShowMessages(("Could not find include file:") & " " & PathFunction, False)
			ThreadsLeave
		End If
		CloseFile_(ff)
	End If
	If LoadParameter = LoadParam.OnlyFilePathOverwriteWithContent Then
		LoadFunctionsWithContent Path, File->Tag, *File
		MutexUnlock tlockSave
		Exit Sub
	End If
	For i As Integer = 0 To Lines.Count - 1
		b1 = Replace(Lines.Item(i), !"\t", " ")
		If StartsWith(Trim(b1), "'") Then
			If i = 0 OrElse Trim(Comment) = "" Then
				Comment = Mid(Trim(b1), 2)
			Else
				Comment &= " <br> " & Mid(Trim(b1), 2)
			End If
			Continue For
		ElseIf Trim(b1) = "" Then
			Comment = ""
			Continue For
		Else
			Pos1 = MAX(InStrRev(b1, Chr(34)),1)
			Pos1 = InStr(Pos1, b1, "'")
			If Pos1 > 0 Then 
				Comment = Trim(Mid(b1, Pos1 + 1))
				b1 = Mid(b1, 1, Pos1)
			End If
		End If
		Dim As WString Ptr res(Any)
		Split(b1, """", res())
		b = ""
		For j As Integer = 0 To UBound(res)
			If j = 0 Then
				b = *res(0)
			ElseIf j Mod 2 = 0 Then
				b &= """" & *res(j)
			Else
				b &= """" & WSpace(Len(*res(j)))
			End If
			_Deallocate(res(j))
		Next
		Erase res
		Pos4 = InStr(b, "'")
		If Pos4 > 0 Then
			b = Left(b, Pos4 - 1)
		End If
		If inType Then
			b = Replace(b, ":", "%")
		End If
		Split(b, ":", res())
		Dim k As Integer = 1
		For j As Integer = 0 To UBound(res)
			l = Len(*res(j))
			b = Mid(b1, k, l)
			bTrim = Trim(b, Any !"\t ") 'DeleteSpaces(Trim(b, Any !"\t "))
			bTrimLCase = LCase(bTrim)
			k = k + Len(*res(j)) + 1
			If CInt(StartsWith(LTrim(LCase(b)), "#include ")) Then
				Pos1 = InStr(b, """")
				If Pos1 > 0 Then
					Pos2 = InStr(Pos1 + 1, b, """")
					LoadFunctionPath = GetRelativePath(Mid(b, Pos1 + 1, Pos2 - Pos1 - 1), PathFunction)
					Var Idx = IncludeFiles.IndexOf(LoadFunctionPath)
					If Idx <> -1 Then
						File->Includes.Add LoadFunctionPath, IncludeFiles.Object(Idx)
					Else
						File->Includes.Add LoadFunctionPath
					End If
					File->IncludeLines.Add i
				End If
			ElseIf LoadParameter <> LoadParam.OnlyIncludeFiles Then
				Pos3 = InStr(bTrimLCase, " as ")
				If CInt(StartsWith(bTrimLCase, "type ") OrElse StartsWith(bTrimLCase, "private type ") OrElse StartsWith(bTrimLCase, "public type ") OrElse _
					StartsWith(bTrimLCase, "class ") OrElse StartsWith(bTrimLCase, "private class ") OrElse StartsWith(bTrimLCase, "public class ")) AndAlso CInt(IIf(inType, Pos3 = 0, True)) Then
					Pos1 = InStr(" " & bTrimLCase, " type ")
					Pos5 = 5
					If Pos1 = 0 Then Pos1 = InStr(" " & bTrimLCase, " class "): Pos5 = 6
					If Pos1 > 0 Then
						Pos2 = InStr(bTrimLCase, " extends ")
						If Pos2 > 0 Then
							t = Trim(Mid(bTrim, Pos1 + Pos5, Pos2 - Pos1 - Pos5))
							e = Trim(Mid(bTrim, Pos2 + 9))
						ElseIf Pos3 > 0 Then
							If Trim(Left(LCase(bTrim), Pos3)) = "type" Then  'Like "Type As    Short gint16, gshort, gunichar2" Then
								Pos5 = InStrRev(bTrim, " ")
								t = Trim(Mid(bTrim, Pos5 + 1))
								e = Trim(Mid(bTrim, Pos3 + 4, Pos5 - (Pos3 + 4)))
							Else
								t = Trim(Mid(bTrim, Pos1 + Pos5, Pos3 - Pos1 - Pos5))
								e = Trim(Mid(bTrim, Pos3 + 4))
							End If
						Else
							Pos2 = InStr(Pos1 + Pos5, bTrim, " ")
							If Pos2 > 0 Then
								t = Trim(Mid(bTrim, Pos1 + Pos5, Pos2 - Pos1 - Pos5))
							Else
								t = Trim(Mid(bTrim, Pos1 + Pos5))
							End If
							e = ""
						End If
						Pos4 = InStr(e, "'")
						If Pos4 > 0 Then
							e = Trim(Left(e, Pos4 - 1))
						End If
						bTypeIsPointer = EndsWith(LCase(e), " ptr") OrElse EndsWith(LCase(e), " pointer")
						e = WithoutPointers(e)
						tOrig = t
						If t = "Object" And e = "Object" Then
							t = "My.Sys.Object"
							e = ""
						End If
						OldInType = inType
						inType = Pos3 = 0
						inPubProPri = 0
						If Types.Contains(t, , , , Idx) AndAlso Cast(TypeElement Ptr, Types.Object(Idx))->FileName = PathFunction AndAlso OldTypes.Count = 0 Then
							tbi = Types.Object(Idx)
						Else
							tbi = _New( TypeElement)
						End If
						tbi->Name = t
						tbi->DisplayName = t & IIf(Pos5 = 5, " [Type]", " [Class]")
						tbi->TypeIsPointer = bTypeIsPointer
						tbi->TypeName = e
						tbi->ElementType = IIf(Pos3 > 0, E_TypeCopy, E_Type)
						tbi->InCondition = CurrentCondition
						tbi->StartLine = i
						tbi->FileName = PathFunction
						If CtlLibrary Then tbi->IncludeFile = Replace(GetRelative(PathFunction, CtlLibrary->IncludeFolder), "\", "/")
						tbi->Parameters = Trim(Mid(bTrim, Pos1 + Pos5))
						tbi->CtlLibrary = CtlLibrary
						tbi->Tag = CtlLibrary
						If Comment <> "" Then tbi->Comment = Comment: Comment = ""
						If inType Then OldTypes.Add t, tbi
						typ = tbi
						If Types.Contains(t, , , , Idx) AndAlso Cast(TypeElement Ptr, Types.Object(Idx))->FileName = PathFunction Then
							If OldTypes.Count > 1 Then
								TypesInFunc.Add t, tbi
							End If
						ElseIf InFunc = False Then
							If OldTypes.Count > 1 Then
								Dim As TypeElement Ptr teOld = OldTypes.Object(OldTypes.Count - 2)
								teOld->Elements.Add t, tbi
								teOld->Types.Add t, tbi
							Else
								Types.Add t, tbi
								If Namespaces.Count > 0 Then
									Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
									If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add tOrig, tbi
									For n_i As Integer = 0 To Namespaces.Count - 1
										tbi->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
									Next
								End If
							End If
						Else
							TypesInFunc.Add t, tbi
						End If
					End If
				ElseIf StartsWith(bTrimLCase & " ", "end type ") OrElse StartsWith(bTrimLCase & " ", "end class ") OrElse StartsWith(bTrimLCase & " ", "__startofclassbody__ ") Then
					If OldTypes.Count > 0 Then
						If OldTypes.Count > 1 AndAlso typ->InCondition = "Not " & Cast(TypeElement Ptr, OldTypes.Object(OldTypes.Count - 2))->InCondition Then
							OldTypes.Remove OldTypes.Count - 1
						End If
						OldTypes.Remove OldTypes.Count - 1
					End If
					If OldTypes.Count > 0 Then
						inType = True
						typ = OldTypes.Object(OldTypes.Count - 1)
						tbi = typ
						Var Idx = TypesPubProPri.IndexOfObject(typ)
						If Idx > -1 Then inPubProPri = TypesPubProPri.Item(Idx)
					Else
						inType = False
					End If
				ElseIf StartsWith(bTrimLCase, "union ") Then
					inUnion = True
					t = Trim(Mid(bTrim, 7))
					Pos2 = InStr(t, "'")
					If Pos2 > 0 Then t = Trim(Left(t, Pos2 - 1))
					'If Not Types.Contains(t) Then
					tbi = _New( TypeElement)
					tbi->Name = t
					tbi->DisplayName = t & " [Union]"
					tbi->TypeName = ""
					tbi->ElementType = E_Union
					tbi->StartLine = i
					tbi->FileName = PathFunction
					tbi->CtlLibrary = CtlLibrary
					Types.Add t, tbi
					typ = tbi
					If Namespaces.Count > 0 Then
						Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
						If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add tbi->Name, tbi
					End If
					'End If
				ElseIf CInt(StartsWith(bTrimLCase, "end union")) Then
					inUnion = False
				ElseIf StartsWith(bTrimLCase, "#if ") Then
					CurrentCondition = Trim(Mid(bTrimLCase, 5))
				ElseIf StartsWith(bTrimLCase, "#ifdef") Then
					CurrentCondition = Trim(Mid(bTrimLCase, 7))
				ElseIf StartsWith(bTrimLCase, "#ifndef") Then
					CurrentCondition = "Not " & Trim(Mid(bTrimLCase, 8))
				ElseIf StartsWith(bTrimLCase, "#elseif") Then
					CurrentCondition = Trim(Mid(bTrimLCase, 8))
				ElseIf StartsWith(bTrimLCase, "#else") Then
					CurrentCondition = "Not " & CurrentCondition
				ElseIf StartsWith(bTrimLCase, "#endif") Then
					CurrentCondition = ""
				ElseIf StartsWith(bTrimLCase & " ", "#define ") Then
					If Not InFunc Then
						Dim As UString b2 = Trim(Mid(bTrim, 9))
						Pos1 = InStr(b2, " ")
						Pos2 = InStr(b2, "(")
						Pos3 = InStr(b2, ")")
						If Pos2 > 0 AndAlso (Pos2 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos2
						te = _New( TypeElement)
						If Pos1 = 0 Then
							te->Name = b2
						Else
							te->Name = Trim(Left(b2, Pos1 - 1))
						End If
						te->DisplayName = te->Name
						te->ElementType = E_Define
						te->Parameters = Trim(b2)
						Pos4 = InStr(te->Parameters, "'")
						If Pos4 > 0 Then
							te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
						End If
						If Pos1 > 0 Then
							te->Value = Trim(Mid(b2, IIf(Pos3, Pos3, Pos1) + 1))
						End If
						If inType Then
							te->Locals = inPubProPri
						End If
						te->StartLine = i
						te->EndLine = i
						If Comment <> "" Then te->Comment= Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						Globals.Defines.Add te->Name, te
						lastfunctionte = te
						If inType AndAlso typ <> 0 Then
							typ->Elements.Add te->Name, te
						Else
							LastIndexFunction = Functions.Add(te->Name, te)
							If Namespaces.Count > 0 Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
								For n_i As Integer = 0 To Namespaces.Count - 1
									te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
								Next
								te->FullName = te->OwnerNamespace & "." & te->Name
							Else
								te->FullName = te->Name
							End If
						End If
					End If
				ElseIf StartsWith(bTrimLCase & " ", "#macro ") Then
					Pos1 = InStr(8, bTrim, " ")
					Pos2 = InStr(8, bTrim, "(")
					Pos3 = InStr(8, bTrim, ")")
					If Pos2 > 0 AndAlso (Pos2 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos2
					te = _New( TypeElement)
					If Pos1 = 0 Then
						te->Name = Trim(Mid(bTrim, 8))
					Else
						te->Name = Trim(Mid(bTrim, 8, Pos1 - 8))
					End If
					te->DisplayName = te->Name
					te->ElementType = E_Macro
					te->Parameters = Trim(Mid(bTrim, 8))
					Pos4 = InStr(te->Parameters, "'")
					If Pos4 > 0 Then
						te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
					End If
					If Pos2 > 0 AndAlso Pos3 > 0 OrElse Pos1 > 0 Then
						te->Value = Trim(Mid(bTrim, IIf(Pos2 > 0, Pos3 + 1, Pos1 + 1)))
					End If
					te->StartLine = i
					te->EndLine = i
					If Comment <> "" Then te->Comment= Comment: Comment = ""
					te->FileName = PathFunction
					te->CtlLibrary = CtlLibrary
					Globals.Defines.Add te->Name, te
					lastfunctionte = te
					If inType AndAlso typ <> 0 Then
						typ->Elements.Add te->Name, te
					Else
						LastIndexFunction = Functions.Add(te->Name, te)
						If Namespaces.Count > 0 Then
							Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & te->Name
						Else
							te->FullName = te->Name
						End If
					End If
				ElseIf StartsWith(bTrimLCase & " ", "namespace ") AndAlso Pos3 = 0 Then
					InNamespace = True
					Pos1 = InStr(11, bTrim, " ")
					Dim As String Names
					Dim As WString Ptr res1(Any)
					If Pos1 = 0 Then
						Names = Trim(Mid(bTrim, 11))
					Else
						Names = Trim(Mid(bTrim, 11, Pos1 - 11))
					End If
					Split(Names, ".", res1())
					nc = UBound(res1)
					For n As Integer = 0 To nc
						te = _New( TypeElement)
						te->Name = Trim(*res1(n))
						te->DisplayName = te->Name
						te->ElementType = E_Namespace
						te->Parameters = bTrim
						Pos4 = InStr(te->Parameters, "'")
						If Pos4 > 0 Then
							te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
						End If
						te->StartLine = i
						te->EndLine = i
						te->ControlType = nc
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						Globals.Namespaces.Add te->Name, te
						If Namespaces.Count > 0 Then
							Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & te->Name
						Else
							te->FullName = te->Name
						End If
						Namespaces.Add te->Name, te
						_Deallocate(res1(n))
					Next
					Erase res1
				ElseIf StartsWith(bTrimLCase & " ", "end namespace ") Then
					InNamespace = False
					If Namespaces.Count > 0 Then
						nc = Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->ControlType
						For i As Integer = 0 To nc
							If Namespaces.Count > 0 Then Namespaces.Remove Namespaces.Count - 1
						Next i
					End If
				ElseIf StartsWith(bTrimLCase & " ", "declare ") Then
					iStart = 9
					Pos1 = InStr(9, bTrim, " ")
					Pos3 = InStr(9, bTrim, "(")
					If StartsWith(Trim(Mid(bTrimLCase, 9)), "static ") OrElse StartsWith(Trim(Mid(bTrimLCase, 9)), "virtual ") OrElse StartsWith(Trim(Mid(bTrimLCase, 9)), "abstract ") Then
						iStart = Pos1
						Pos1 = InStr(Pos1 + 1, bTrim, " ")
					End If
					Pos4 = InStr(Pos1 + 1, bTrim, " ")
					If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
					Pos4 = InStr(bTrim, "(")
					If Pos4 > 0 AndAlso (Pos4 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos4
					If StartsWith(LCase(Trim(Mid(bTrim, 9))), "operator") Then _Deallocate(res(j)): Continue For
					te = _New( TypeElement)
					te->Declaration = True
					Select Case LCase(IIf(Pos1 = 0, Trim(Mid(bTrim, iStart)), Trim(Mid(bTrim, iStart, Pos1 - iStart))))
					Case "sub": te->ElementType = E_Sub
					Case "function": te->ElementType = E_Function
					Case "property": te->ElementType = E_Property
					Case "operator": te->ElementType = E_Operator
					Case "constructor": te->ElementType = E_Constructor
					Case "destructor": te->ElementType = E_Destructor
					End Select
					If inType AndAlso typ <> 0 AndAlso (te->ElementType = E_Constructor OrElse te->ElementType = E_Destructor) Then
						te->Name = typ->Name
						te->DisplayName = typ->Name & " [" & IIf(te->ElementType = E_Constructor, "Constructor", "Destructor") & "] [Declare]"
						te->TypeName = typ->Name
						te->Parameters = typ->Name & IIf(Pos4 > 0, Mid(bTrim, Pos4), WStr("()"))
					Else
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos1))
						Else
							te->Name = Trim(Mid(bTrim, Pos1, Pos3 - Pos1))
						End If
						If te->ElementType = E_Property Then
							If EndsWith(bTrim, ")") Then
								te->DisplayName = te->Name & " [Let] [Declare]"
							Else
								te->DisplayName = te->Name & " [Get] [Declare]"
							End If
						Else
							te->DisplayName = te->Name & " [Declare]"
						End If
						te->Parameters = Trim(Mid(bTrim, Pos1))
						If inType AndAlso typ <> 0 Then te->DisplayName = typ->Name & "." & te->DisplayName
						Pos2 = InStr(bTrim, ")")
						Pos3 = InStr(Pos2, bTrimLCase, ")as ")
						If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " as ")
						If Pos3 = 0 Then
							te->TypeName = ""
						Else
							te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
						End If
						Pos4 = InStr(te->TypeName, "'")
						If Pos4 > 0 Then
							Pos5 = InStr(Trim(Mid(te->TypeName, Pos4 + 1)), " ")
							If Pos5 > 0 Then
								te->EnumTypeName = Left(Trim(Mid(te->TypeName, Pos4 + 1)), Pos5 - 1)
							Else
								te->EnumTypeName = Trim(Mid(te->TypeName, Pos4 + 1))
							End If
							te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
						End If
						te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
						te->TypeName = WithoutPointers(te->TypeName)
						Pos4 = InStrRev(te->TypeName, ".")
						If Pos4 > 0 AndAlso LCase(te->TypeName) <> "my.sys.object" Then
							te->TypeName = Mid(te->TypeName, Pos4 + 1)
						End If
					End If
					If inType Then
						te->Locals = inPubProPri
					End If
					If te->ElementType = E_Operator Then
						te->Locals = 2
					End If
					Pos4 = InStr(te->Parameters, "'")
					If Pos4 > 0 Then
						te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
					End If
					te->StartLine = i
					te->EndLine = i
					If Comment <> "" Then te->Comment = Comment: Comment = ""
					te->FileName = PathFunction
					te->CtlLibrary = CtlLibrary
					If inType AndAlso typ <> 0 AndAlso te->ElementType <> E_Constructor AndAlso te->ElementType <> E_Destructor Then
						typ->Elements.Add te->Name, te
					Else
						LastIndexFunction = Functions.Add(te->Name, te)
						lastfunctionte = te
						If Not inType Then
							If Namespaces.Count > 0 Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index <> -1 Then
									Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
								End If
								For n_i As Integer = 0 To Namespaces.Count - 1
									te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
								Next
								te->FullName = te->OwnerNamespace & "." & te->Name
							Else
								te->FullName = te->Name
							End If
						End If
					End If
				ElseIf inType OrElse inUnion Then
					If bTrimLCase = "public:" Then
						inPubProPri = 0
						Var Idx = TypesPubProPri.IndexOfObject(tbi)
						If Idx = -1 Then
							TypesPubProPri.Add inPubProPri, tbi
						Else
							TypesPubProPri.Item(Idx) = inPubProPri
						End If
						Comment = ""
					ElseIf bTrimLCase = "protected:" Then
						inPubProPri = 1
						Var Idx = TypesPubProPri.IndexOfObject(tbi)
						If Idx = -1 Then
							TypesPubProPri.Add inPubProPri, tbi
						Else
							TypesPubProPri.Item(Idx) = inPubProPri
						End If
						Comment = ""
					ElseIf bTrimLCase = "private:" Then
						inPubProPri = 2
						Var Idx = TypesPubProPri.IndexOfObject(tbi)
						If Idx = -1 Then
							TypesPubProPri.Add inPubProPri, tbi
						Else
							TypesPubProPri.Item(Idx) = inPubProPri
						End If
						Comment = ""
					ElseIf CInt(StartsWith(bTrimLCase, "as ")) OrElse CInt(StartsWith(bTrimLCase, "const ")) OrElse InStr(bTrimLCase, " as ") Then
						Dim As WString * 2048 b2 = bTrim
						Dim As WString * 2048 CurType, ElementValue, TypeComment
						Dim As WString Ptr res1(Any)
						Dim As Integer uu, ct
						Dim As Boolean bOldAs
						If StartsWith(LCase(b2), "dim ") Then
							b2 = Trim(Mid(b2, 4))
						ElseIf StartsWith(LCase(b2), "redim ") Then
							b2 = Trim(Mid(b2, 6))
						ElseIf StartsWith(LCase(b2), "static ") Then
							b2 = Trim(Mid(b2, 7))
						End If
						Pos1 = InStr(b2, "'")
						Pos2 = InStr(b2, "/'")
						If Pos2 > 0 AndAlso Pos2 < Pos1 Then
							Pos1 = InStr(b2, "'/")
							If Pos1 = 0 Then
								TypeComment = Trim(Mid(b2, Pos2 + 2))
								b2 = Trim(Left(b2, Pos2 - 1))
							Else
								TypeComment = Trim(Mid(b2, Pos2 + 2, Pos1 - 1 - (Pos2 + 2)))
								b2 = Trim(Left(b2, Pos2 - 1)) & " " & Trim(Mid(b2, Pos1 + 3))
							End If
						ElseIf Pos1 > 0 Then
							TypeComment = Trim(Mid(b2, Pos1 + 1))
							b2 = Trim(Left(b2, Pos1 - 1))
						End If
						Pos1 = InStr(b2, "=>")
						If Pos1 > 0 Then b2 = Trim(Left(b2, Pos1 - 1))
						If StartsWith(LCase(b2), "as ") Then
							If StartsWith(LCase(b2), "as ") Then CurType = Trim(Mid(b2, 4)) Else CurType = Trim(b2)
							bOldAs = True
							Pos1 = InStr(CurType, " ")
							Pos2 = InStr(CurType, " Ptr ")
							Pos3 = InStr(CurType, " Pointer ")
							If Pos2 > 0 Then
								Pos1 = Pos2 + 4
							ElseIf Pos3 > 0 Then
								Pos1 = Pos2 + 8
							End If
							If Pos1 > 0 Then
								Split GetChangedCommas(Mid(CurType, Pos1 + 1)), ",", res1()
								If UBound(res1) > -1 Then
									CurType = ..Left(CurType, Pos1 + Len(*res1(0)))
								End If
							End If
						Else
							Split GetChangedCommas(b2), ",", res1()
						End If
						For n As Integer = 0 To UBound(res1)
							*res1(n) = Trim(Replace(*res1(n), ";", ","))
							ElementValue = ""
							If InStr(LCase(b2), " sub(") = 0 Then
								Pos1 = InStr(*res1(n), "=")
								If Pos1 > 0 Then
									ElementValue = Trim(Mid(*res1(n), Pos1 + 1))
									If CBool(n = 0) AndAlso bOldAs Then
										CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n)) + Pos1 - 2))
										CurType = Replace(CurType, "`", "=")
									End If
								End If
								If Pos1 > 0 Then *res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(LCase(*res1(n)), " as ")
							If Pos1 > 0 AndAlso Not bOldAs Then
								CurType = Trim(Mid(*res1(n), Pos1 + Len("As") + 2))
								CurType = Replace(CurType, "`", "=")
								*res1(n) = Trim(..Left(*res1(n), Pos1 - 1))
							End If
							'If Pos1 > 0 Then
							'	CurType = Trim(Mid(*res1(n), Pos1 + 4))
							''								Pos2 = InStr(CurType, "*") 'David Change. Like Wstring * 200
							''								If Pos2 > 1 Then CurType = Trim(Mid(*res1(n), Pos1 + 4, Pos2 - Pos1 - 3)) Else CurType = Trim(Mid(*res1(n), Pos1 + 4))
							'	*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							'End If
							'If CBool(n = 0) AndAlso bOldAs Then
							'	CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n))))
							'	CurType = Replace(CurType, "`", "=")
							'End If
							Pos1 = InStr(*res1(n), ":")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							If StartsWith(LCase(*res1(n)), "byref") OrElse StartsWith(LCase(*res1(n)), "byval") Then
								ct += Len(*res1(n)) - Len(Trim(Mid(*res1(n), 6)))
								*res1(n) = Trim(Mid(*res1(n), 6))
							End If
							Pos1 = InStr(*res1(n), "(")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(LCase(*res1(n)), " alias ")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(..Left(*res1(n), Pos1 - 1))
							End If
							ct += Len(*res1(n)) - Len(Trim(*res1(n)))
							*res1(n) = Trim(*res1(n))
							Pos1 = InStrRev(*res1(n), " ")
							If Pos1 > 0 Then *res1(n) = Trim(Mid(*res1(n), Pos1 + 1))
							If CBool(n = 0) AndAlso bOldAs Then
								CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n)) - ct))
							End If
							If Not (StartsWith(LCase(CurType), "sub") OrElse StartsWith(LCase(CurType), "function")) Then
								Pos1 = InStrRev(CurType, ".")
								If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
							End If
							Var te = _New( TypeElement)
							te->Name = *res1(n)
							If tbi AndAlso tbi->Name <> "" Then
								te->DisplayName = tbi->Name & "." & te->Name
							Else
								te->DisplayName = te->Name
							End If
							te->TypeName = CurType
							Pos4 = InStr(te->TypeName, "'")
							If Pos4 > 0 Then
								Pos5 = InStr(Trim(Mid(te->TypeName, Pos4 + 1)), " ")
								If Pos5 > 0 Then
									te->EnumTypeName = Left(Trim(Mid(te->TypeName, Pos4 + 1)), Pos5 - 1)
								Else
									te->EnumTypeName = Trim(Mid(te->TypeName, Pos4 + 1))
								End If
								te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
							ElseIf TypeComment <> "" Then
								te->EnumTypeName = TypeComment
							End If
							te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
							te->TypeName = WithoutPointers(te->TypeName)
							te->Value = ElementValue
							te->ElementType = IIf(StartsWith(bTrimLCase, "const "), E_Constant, IIf(StartsWith(LCase(te->TypeName), "sub(") OrElse StartsWith(LCase(te->TypeName), "function("), E_Event, E_Field))
							te->Locals = inPubProPri
							te->StartLine = i
							te->Parameters = *res1(n) & " As " & CurType
							te->FileName = PathFunction
							te->CtlLibrary = CtlLibrary
							If Comment <> "" Then te->Comment = Comment: Comment = ""
							If tbi Then tbi->Elements.Add te->Name, te
							_Deallocate(res1(n))
						Next n
						Erase res1
					End If
				ElseIf CInt(StartsWith(Trim(LCase(b)), "enum ")) OrElse CInt(StartsWith(Trim(LCase(b)), "public enum ")) OrElse CInt(StartsWith(Trim(LCase(b)), "private enum ")) OrElse CInt(Trim(LCase(b)) = "enum") Then
					inEnum = True
					Pos2 = InStr(" " & bTrimLCase, " enum")
					t = Trim(Mid(" " & bTrim, Pos2 + 5))
					Pos2 = InStr(t, "'")
					If Pos2 > 0 Then t = Trim(Left(t, Pos2 - 1))
					If Not Comps.Contains(t) Then
						tbi = _New( TypeElement)
						tbi->Name = t
						tbi->DisplayName = t & " [Enum]"
						tbi->TypeName = ""
						tbi->ElementType = E_Enum
						tbi->StartLine = i
						tbi->FileName = PathFunction
						tbi->CtlLibrary = CtlLibrary
						If InFunc = False Then
							If inType Then
								tbi->Elements.Add t, tbi
								tbi->Enums.Add t, tbi
							Else
								Enums.Add t, tbi
								If Namespaces.Count > 0 Then
									Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
									If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add tbi->Name, tbi
									For n_i As Integer = 0 To Namespaces.Count - 1
										tbi->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
									Next
								End If
							End If
						Else
							EnumsInFunc.Add t, tbi
						End If
					End If
				ElseIf CInt(StartsWith(bTrimLCase, "end enum")) Then
					inEnum = False
				ElseIf inEnum Then
					If StartsWith(bTrim, "#") OrElse StartsWith(bTrim, "'") Then _Deallocate(res(j)): Continue For
					Dim As WString * 2048 b2 = b, ElementValue
					Dim As WString Ptr res1(Any)
					Pos2 = InStr(b2, "'")
					If Pos2 > 0 Then b2 = Trim(Left(b2, Pos2 - 1))
					Split b2, ",", res1()
					For n As Integer = 0 To UBound(res1)
						Pos3 = InStr(*res1(n), "=")
						If Pos3 > 0 Then
							ElementValue = Trim(Mid(*res1(n), Pos3 + 1))
						Else
							ElementValue = ""
						End If
						If Pos3 > 0 Then
							t = Trim(Left(*res1(n), Pos3 - 1))
						Else
							t = Trim(*res1(n))
						End If
						Var te = _New( TypeElement)
						te->Name = t
						If tbi AndAlso tbi->Name <> "" Then
							te->DisplayName = tbi->Name & "." & te->Name
						Else
							te->DisplayName = te->Name
						End If
						te->ElementType = E_EnumItem
						te->Value = ElementValue
						te->StartLine = i
						te->Parameters = Trim(*res1(n))
						te->FileName = PathFunction
						If tbi Then tbi->Elements.Add te->Name, te
						te = _New( TypeElement)
						te->Name = t
						If tbi AndAlso tbi->Name <> "" Then
							te->DisplayName = tbi->Name & "." & te->Name
						Else
							te->DisplayName = te->Name
						End If
						te->ElementType = E_EnumItem
						te->Value = ElementValue
						te->StartLine = i
						te->Parameters = Trim(*res1(n))
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						Args.Add te->Name, te
						_Deallocate(res1(n))
					Next n
					Erase res1
				Else 'If LoadParameter <> LoadParam.OnlyTypes Then
					If CInt(StartsWith(bTrimLCase & " ", "end sub ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end function ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end property ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end operator ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end destructor ")) Then
						InFunc = False
						If lastfunctionte <> 0 Then
							lastfunctionte->EndLine = i
							LastIndexFunction = -1
						End If
					ElseIf CInt(StartsWith(bTrimLCase, "operator ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private operator ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public operator ")) Then
						InFunc = True
					ElseIf CInt(StartsWith(bTrimLCase, "constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public constructor ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " constructor ") + 12
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name & " [Constructor]"
						te->TypeName = te->Name
						te->ElementType = E_Constructor
						te->Locals = IIf(StartsWith(bTrimLCase, "private "), 1, 0)
						te->StartLine = i
						te->Parameters = te->Name & IIf(Pos3 > 0, Mid(bTrim, Pos3), WStr("()"))
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & te->Name
						Else
							te->FullName = te->Name
						End If
						LastIndexFunction = Functions.Add(te->Name, te)
						lastfunctionte = te
					ElseIf CInt(StartsWith(bTrimLCase, "destructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private destructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public destructor ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " destructor ") + 11
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5), Any !"\t "))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name & " [Destructor]"
						te->TypeName = te->Name
						te->ElementType = E_Destructor
						te->Locals = IIf(StartsWith(bTrimLCase, "private "), 1, 0)
						te->StartLine = i
						te->Parameters = te->Name & IIf(Pos3 > 0, Mid(bTrim, Pos3), WStr("()"))
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & te->Name
						Else
							te->FullName = te->Name
						End If
						LastIndexFunction = Functions.Add(te->Name, te)
						lastfunctionte = te
					ElseIf CInt(StartsWith(bTrimLCase, "sub ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private sub ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public sub ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " sub ") + 4
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name
						Pos1 = InStr(te->Name, ".")
						If Pos1 > 0 Then
							bt = Left(te->Name, Pos1 - 1)
							te->Name = Mid(te->Name, Pos1 + 1)
							te->OwnerTypeName = bt
							te->Locals = 2
						Else
							bt = ""
							te->Locals = 0 'IIf(StartsWith(bTrimLCase, "private sub "), 1, 0)
						End If
						te->TypeName = ""
						te->ElementType = E_Sub
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If EndsWith(LCase(te->Parameters), " __export__") Then
							te->Parameters = Trim(Left(te->Parameters, Len(te->Parameters) - 11))
						End If
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							If bt = "" Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							End If
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & IIf(bt = "", "", bt & ".") & te->Name
						Else
							te->FullName = IIf(bt = "", "", bt & ".") & te->Name
						End If
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							'te->TypeProcedure = True
							'n = Types.IndexOf(bt)
							'If n > -1 Then
							'	Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							'ElseIf n = -1 Then
							'	If bt = "Object" Then
							'		n = Comps.IndexOf("My.Sys.Object")
							'	Else
							'		n = Comps.IndexOf(bt)
							'	End If
							'	If n > -1 AndAlso Comps.Object(n) <> 0 Then
							'		Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							'	Else
							'		'?bTrim
							'	End If
							'End If
							LastIndexFunction = TypeProcedures.Add(te->Name, te)
						Else
							'LastIndexFunction = Functions.Add(te->Name, te)
							LastIndexFunction = Functions.Add(te->Name, te)
						End If
						lastfunctionte = te
					ElseIf CInt(StartsWith(bTrimLCase, "function ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private function ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public function ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " function") + 9
						If StartsWith(Trim(Mid(bTrim, Pos5)), "=") Then _Deallocate(res(j)): Continue For
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name
						Pos1 = InStr(te->Name, ".")
						If Pos1 > 0 Then
							bt = Left(te->Name, Pos1 - 1)
							te->Name = Mid(te->Name, Pos1 + 1)
							te->OwnerTypeName = bt
							te->Locals = 2
						Else
							bt = ""
							te->Locals = 0 'IIf(StartsWith(bTrimLCase, "private function "), 1, 0)
						End If
						Pos4 = InStrRev(bTrim, ")")
						Pos3 = InStr(Pos4, bTrimLCase, ")as ")
						If Pos3 = 0 Then Pos3 = InStr(Pos4 + 1, bTrimLCase, " as ")
						te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
						te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
						te->TypeName = WithoutPointers(te->TypeName)
						te->ElementType = E_Function
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If EndsWith(LCase(te->Parameters), " __export__") Then
							te->Parameters = Trim(Left(te->Parameters, Len(te->Parameters) - 11))
						End If
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							If bt = "" Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							End If
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & IIf(bt = "", "", bt & ".") & te->Name
						Else
							te->FullName = IIf(bt = "", "", bt & ".") & te->Name
						End If
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							'te->TypeProcedure = True
							'n = Types.IndexOf(bt)
							'If n > -1 Then
							'	Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							'ElseIf n = -1 Then
							'	If bt = "Object" Then
							'		n = Comps.IndexOf("My.Sys.Object")
							'	Else
							'		n = Comps.IndexOf(bt)
							'	End If
							'	If n > -1 AndAlso Comps.Object(n) <> 0 Then
							'		Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							'	Else
							'		'?bTrim
							'	End If
							'End If
							LastIndexFunction = TypeProcedures.Add(te->Name, te)
						Else
							'LastIndexFunction = Functions.Add(te->Name, te)
							LastIndexFunction = Functions.Add(te->Name, te)
						End If
						lastfunctionte = te
					ElseIf CInt(StartsWith(bTrimLCase, "property ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private property ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public property ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " property") + 9
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						If EndsWith(bTrim, ")") Then
							te->DisplayName = te->Name & " [Let]"
						Else
							te->DisplayName = te->Name & " [Get]"
						End If
						Pos1 = InStr(te->Name, ".")
						If Pos1 > 0 Then
							bt = Left(te->Name, Pos1 - 1)
							te->Name = Mid(te->Name, Pos1 + 1)
							te->OwnerTypeName = bt
							te->Locals = 2
						Else
							bt = ""
							te->Locals = 0 'IIf(StartsWith(bTrimLCase, "private property "), 1, 0)
						End If
						Pos4 = InStr(bTrim, ")")
						Pos3 = InStr(Pos4, bTrimLCase, ")as ")
						If Pos3 = 0 Then Pos3 = InStr(Pos4 + 1, bTrimLCase, " as ")
						te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
						te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
						te->TypeName = WithoutPointers(te->TypeName)
						te->ElementType = E_Property
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							If bt = "" Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							End If
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & IIf(bt = "", "", bt & ".") & te->Name
						Else
							te->FullName = IIf(bt = "", "", bt & ".") & te->Name
						End If
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							'te->TypeProcedure = True
							'n = Types.IndexOf(bt)
							'If n > -1 Then Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							'If n = -1 Then
							'	n = Comps.IndexOf(bt)
							'	If n > -1 AndAlso Comps.Object(n) <> 0 Then Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							'End If
							'Else
							'	LastIndexFunction = Functions.Add(te->Name, te)
						End If
						LastIndexFunction = TypeProcedures.Add(te->Name, te)
						lastfunctionte = te
					ElseIf (CInt(Not inType) AndAlso CInt(Not inEnum) AndAlso CInt(Not InFunc) OrElse InStr(bTrimLCase, " shared ") > 0) AndAlso _
						CInt(CInt(StartsWith(bTrimLCase, "dim ")) OrElse _
						CInt(StartsWith(bTrimLCase, "common ")) OrElse _
						CInt(StartsWith(bTrimLCase, "static ")) OrElse _
						CInt(StartsWith(bTrimLCase, "const ")) OrElse _
						CInt(StartsWith(bTrimLCase, "redim ")) OrElse _
						CInt(StartsWith(bTrimLCase, "extern ")) OrElse _
						CInt(StartsWith(bTrimLCase, "var "))) Then
						Dim As WString * 2048 b2 = Trim(Mid(bTrim, InStr(bTrim, " ")))
						Dim As WString * 2048 CurType, ElementValue
						Dim As Integer ct
						Dim As WString Ptr res1(Any)
						Dim As Boolean bShared, bOldAs
						Pos1 = InStr(b2, "'")
						If Pos1 > 0 Then b2 = Trim(Left(b2, Pos1 - 1))
						If StartsWith(LCase(b2), "shared ") Then bShared = True: b2 = Trim(Mid(b2, 7))
						If StartsWith(LCase(b2), "import ") Then b2 = Trim(Mid(b2, 7))
						If StartsWith(LCase(b2), "as ") Then
							bOldAs = True
							CurType = Trim(Mid(b2, 4))
							Pos1 = InStr(CurType, " ")
							Pos2 = InStr(CurType, " Ptr ")
							Pos3 = InStr(CurType, " Pointer ")
							If Pos2 > 0 Then
								Pos1 = Pos2 + 4
							ElseIf Pos3 > 0 Then
								Pos1 = Pos2 + 8
							End If
							If Pos1 > 0 Then
								Split GetChangedCommas(Mid(CurType, Pos1 + 1)), ",", res1()
								If UBound(res1) > -1 Then
									CurType = Trim(..Left(CurType, Pos1 + Len(*res1(0))))
								End If
							End If
						Else
							Split GetChangedCommas(b2), ",", res1()
						End If
						For n As Integer = 0 To UBound(res1)
							*res1(n) = Trim(Replace(*res1(n), ";", ","))
							Pos1 = InStr(*res1(n), "=")
							If Pos1 > 0 Then
								ElementValue = Trim(Mid(*res1(n), Pos1 + 1))
								If CBool(n = 0) AndAlso bOldAs Then
									CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n)) + Pos1 - 2))
									CurType = Replace(CurType, "`", "=")
								End If
							Else
								ElementValue = ""
							End If
							If Pos1 > 0 Then *res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							Pos1 = InStr(LCase(*res1(n)), " as ")
							If Pos1 > 0 Then
								CurType = Trim(Mid(*res1(n), Pos1 + 4))
								CurType = Replace(CurType, "`", "=")
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(*res1(n), ":")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(..Left(*res1(n), Pos1 - 1))
							End If
							If StartsWith(LCase(*res1(n)), "byref") OrElse StartsWith(LCase(*res1(n)), "byval") Then
								ct += Len(*res1(n)) - Len(Trim(Mid(*res1(n), 6)))
								*res1(n) = Trim(Mid(*res1(n), 6))
							'Else
							'	Pos1 = InStrRev(*res1(n), " ") 'David Change,  a As WString*2
							'	*res1(n) = Trim(Mid(*res1(n), Pos1 + 1))
							End If
							Pos1 = InStr(*res1(n), "(")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(LCase(*res1(n)), " alias ")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							ct += Len(*res1(n)) - Len(Trim(*res1(n)))
							*res1(n) = Trim(*res1(n))
							Pos1 = InStrRev(*res1(n), " ")
							If Pos1 > 0 Then
								*res1(n) = Trim(Mid(*res1(n), Pos1 + 1))
							End If
							If CBool(n = 0) AndAlso bOldAs Then
								CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n)) - ct))
								CurType = Replace(CurType, "`", "=")
							End If
							If Not (StartsWith(LCase(CurType), "sub") OrElse StartsWith(LCase(CurType), "function")) Then
								Pos1 = InStrRev(CurType, ".")
								If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
							End If
							Var te = _New( TypeElement)
							te->Name = *res1(n)
							te->DisplayName = te->Name
							If StartsWith(bTrimLCase, "common ") Then
								te->ElementType = E_CommonVariable
							ElseIf StartsWith(bTrimLCase, "const ") Then
								te->ElementType = E_Constant
							ElseIf bShared Then
								te->ElementType = E_SharedVariable
							Else
								te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub(") OrElse StartsWith(LCase(te->TypeName), "function("), E_Event, E_Property)
							End If
							te->TypeIsPointer = EndsWith(LCase(CurType), " pointer") OrElse EndsWith(LCase(CurType), " ptr")
							te->TypeName = CurType
							te->TypeName = WithoutPointers(te->TypeName)
							te->Value = ElementValue
							te->Locals = 0 'IIf(bShared, 0, 2)
							te->StartLine = i
							te->Parameters = *res1(n) & " As " & CurType
							te->FileName = PathFunction
							te->CtlLibrary = CtlLibrary
							If Comment <> "" Then te->Comment = Comment: Comment = ""
							Args.Add te->Name, te
							If Namespaces.Count > 0 Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
								For n_i As Integer = 0 To Namespaces.Count - 1
									te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
								Next
							End If
							_Deallocate(res1(n))
						Next
						Erase res1
					End If
				End If
			End If
			_Deallocate(res(j))
		Next
		Erase res
		If FormClosing Then MutexUnlock tlockSave: Exit Sub
	Next
	Lines.Clear
	MutexUnlock tlockSave 'If LoadParameter <> LoadParam.OnlyFilePathOverwrite Then
	If CInt(LoadParameter <> LoadParam.OnlyFilePath) AndAlso CInt(LoadParameter <> LoadParam.OnlyFilePathOverwrite) AndAlso CInt(LoadParameter <> LoadParam.OnlyFilePathOverwriteWithContent) Then
		For i As Integer = 0 To File->Includes.Count - 1
			LoadFunctions File->Includes.Item(i), , Types, Enums, Functions, TypeProcedures, Args
			If FormClosing Then Exit Sub
		Next
	End If
End Sub

tlock = MutexCreate()
tlockSave = MutexCreate()
tlockToDo = MutexCreate()
tlockGDB = MutexCreate()
tlockSuggestions = MutexCreate()
tlockDbgTrace = MutexCreate()	' DR Phase 1 trace (strip after Phase 1)

Sub StartOfLoadFunctions
	LoadFunctionsCount += 1
	MutexLock tlock
	If LoadFunctionsCount = 1 Then
		stBar.Panels[2]->Caption = ""
	End If
End Sub

Sub EndOfLoadFunctions
	LoadFunctionsCount -= 1
	If LoadFunctionsCount = 0 Then
		stBar.Panels[2]->Caption = ("IntelliSense fully loaded")
		Dim As TabWindow Ptr tb
		For j As Integer = TabPanels.Count - 1 To 0 Step -1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
			For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				If tb Then
					tb->txtCode.Content.ExternalIncludesLoaded = False
				End If
			Next i
		Next j
	End If
	MutexUnlock tlock
End Sub

Sub LoadFunctionsSub(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		If Not IncludeFiles.Contains(QWString(Param)) Then LoadFunctions QWString(Param), FilePathAndIncludeFiles, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args
	End If
	EndOfLoadFunctions
End Sub

Sub LoadOnlyFilePath(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		If Not IncludeFiles.Contains(QWString(Param)) Then LoadFunctions QWString(Param), LoadParam.OnlyFilePath, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args
	End If
	EndOfLoadFunctions
End Sub

Sub LoadOnlyFilePathOverwrite(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		LoadFunctions QWString(Param), LoadParam.OnlyFilePathOverwrite, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args
	End If
	EndOfLoadFunctions
End Sub

Sub LoadOnlyFilePathOverwriteWithContent(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		LoadFunctions Cast(EditControlContent Ptr, Param)->FileName, LoadParam.OnlyFilePathOverwriteWithContent, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args, , , Param
	End If
	EndOfLoadFunctions
End Sub

Sub LoadOnlyIncludeFiles(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		LoadFunctions QWString(Param), LoadParam.OnlyIncludeFiles, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args
	End If
	EndOfLoadFunctions
End Sub

Enum Paragraph
	parStart
	parSyntax
	parUsage
	parParameters
	parReturnValue
	parDescription
	parExample
	parDifferencesFromQB
	parSeeAlso
End Enum

Sub LoadHelp
	Dim As WStringOrStringList Ptr pFunctions = @Globals.Functions
	Dim As Boolean InEnglish
	Dim As Integer Fn = FreeFile_, tEncode
	If LCase(App.CurLanguage) = "english" OrElse Dir(ExePath & "/Settings/Others/KeywordsHelp." & App.CurLanguage & ".txt") = "" Then
		InEnglish = True
		WLet(KeywordsHelpPath, ExePath & "/Settings/Others/KeywordsHelp.txt")
	Else
		WLet(KeywordsHelpPath, ExePath & "/Settings/Others/KeywordsHelp." & App.CurLanguage & ".txt")
	End If
	Dim As Integer Result = -1
	Result = Open(*KeywordsHelpPath For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(*KeywordsHelpPath For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(*KeywordsHelpPath For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(*KeywordsHelpPath For Input As #Fn): tEncode= 1
	If Result = 0 Then
			If tEncode = 1 AndAlso Not InEnglish Then MsgBox ("The file encoding is not UTF-8 (BOM). You should convert it to UTF-8 (BOM).") & Chr(13, 10) & *KeywordsHelpPath
		Dim As TypeElement Ptr te, te1
		Dim As WString * 1024 Buff, StartBuff, bTrim
		Dim As Boolean bStart, bStartEnd, bDescriptionStart, bDescriptionEnd, bReturnValueStart, bOperator
		Dim As Paragraph Parag
		Dim As WString * 1024 MLSyntax = ("Syntax"), MLUsage = ("Usage"), MLParameters = ("Parameters"), MLReturnValue = ("Return Value"), MLDescription = ("Description"), _
		MLExample = ("Example"), MLDifferencesFromQB = ("Differences from QB"), MLSeeAlso = ("See also"), MLMoreDetails = ("More details ..."), MLDot = (".")
		Dim As Integer Pos2, Pos1, LineNumber
		Do Until EOF(Fn)
			LineNumber += 1
			Line Input #Fn, Buff
			If Trim(Buff) = "" Then Continue Do
			If StartsWith(Buff, "---") Then
				If StartsWith(Buff, "------------ KeyWin32AbnormalTermination") Then
					pFunctions = @GlobalFunctionsHelp
				End If
				bStart = True : bDescriptionStart = False : bReturnValueStart = False
				Parag = parStart
			ElseIf Buff = "Syntax" OrElse Buff = MLSyntax Then
				Parag = parSyntax
			ElseIf Buff = "Usage" OrElse Buff = MLUsage Then
				Parag = parUsage
			ElseIf Buff = "Parameters" OrElse Buff = MLParameters Then
				Parag = parParameters
			ElseIf Buff = "Return Value" OrElse Buff = MLReturnValue Then
				Parag = parReturnValue: bReturnValueStart = True
			ElseIf Buff = "Description" OrElse Buff = MLDescription Then
				Parag = parDescription : bDescriptionStart = True
			ElseIf Buff = "Example" OrElse Buff = MLExample Then
				Parag = parExample
			ElseIf Buff = "Differences from QB" OrElse Buff = MLDifferencesFromQB Then
				Parag = parDifferencesFromQB
			ElseIf Buff = "See also" OrElse Buff = MLSeeAlso Then
				Parag = parSeeAlso
			Else
				If bStart Then
					If te <> 0 Then
						If bDescriptionEnd = False Then  ' the last one not add ending
							te->Comment &= " " & " <a href=""" & *KeywordsHelpPath & "|" & Str(LineNumber) & "|" & MLMoreDetails & "|" & StartBuff & """>" & MLMoreDetails & !"</a>\r"
							bDescriptionEnd = True
						End If
						If te->Name = "Print" Then
							te1 = _New( TypeElement)
							te1->Name = "?"
							te1->DisplayName = te->DisplayName
							te1->ElementType = te->ElementType
							te1->FileName = te->FileName
							te1->Parameters = te->Parameters
							te1->Comment = te->Comment
							pFunctions->Add te1->Name, te1
						ElseIf te->Name = "#include" Then
							te1 = _New( TypeElement)
							te1->Name = "once"
							te1->DisplayName = te->DisplayName
							te1->ElementType = te->ElementType
							te1->FileName = te->FileName
							te1->Parameters = te->Parameters
							te1->Comment = te->Comment
							pFunctions->Add te1->Name, te1
						End If
					End If
					bTrim = Trim(Buff)
					Pos2 = InStr(bTrim, "   ")  ' For good understanding, KeyWords + "   " + Local
					If Pos2 > 0 Then bTrim = Trim(Left(bTrim, Pos2))
					StartBuff = bTrim
					bOperator = False
					If StartsWith(bTrim, "Operator ") Then bOperator = True: bTrim = Trim(Mid(bTrim, 10))
					If StartsWith(bTrim, "Placement ") Then bTrim = Trim(Mid(bTrim, 11))
					Pos1 = InStr(bTrim, " ")
					If Pos1 > 0 Then bTrim = Left(bTrim, Pos1 - 1)
					Pos1 = InStr(bTrim, "...")
					If Pos1 > 0 Then bTrim = Left(bTrim, Pos1 - 1)
					Pos1 = InStr(bTrim, "(")
					If Pos1 = 1 Then bTrim = Mid(bTrim, Pos1 + 1) Else If Pos1 > 1 Then bTrim = Left(bTrim, Pos1 - 1)
					te = _New( TypeElement)
					te->Name = bTrim
					te->DisplayName = Trim(Buff)
					If bOperator Then
						te->ElementType = E_KeywordOperator
					Else
						te->ElementType = E_Keyword
					End If
					te->FileName = *KeywordsHelpPath
					pFunctions->Add te->Name, te
					bStartEnd = False
					bDescriptionEnd = False
					te->Comment = "<a href=""" & *KeywordsHelpPath & "|" & Str(LineNumber) & "|" & MLMoreDetails & "|" & StartBuff & """>" & IIf(Pos2 = 0, Trim(Buff), Left(Trim(Buff), Pos2)) & !"</a>\r   " & IIf(Pos2 = 0, WStr(""), LTrim(Mid(Trim(Buff), Pos2)))
					'DebugPrint  "te->Name " & te->Name, , False, False
					'Print te->Name
				ElseIf Parag = parStart Then
					If Buff <> "" AndAlso te <> 0 Then
						If te->Comment = "" Then
							te->Comment = Buff
						Else
							te->Comment &= " " & LTrim(Buff, !"\t")
						End If
						'DebugPrint  "te->Comment " & te->Comment, , False, False
					End If
				ElseIf Parag = parSyntax Then
					If Not bStartEnd Then
						If te <> 0 AndAlso Not EndsWith(te->Comment, ".") Then te->Comment &= "."
						bStartEnd = True
					End If
					If te <> 0 AndAlso Trim(Buff) <> "" Then
						If StartsWith(Trim(Buff), "Declare ") AndAlso te->Name <> "Declare" Then
							bTrim = LTrim(Mid(LTrim(Buff), 9))
							If StartsWith(bTrim, "Function ") Then
								Buff = LTrim(Mid(LTrim(bTrim), 10))
								te->ElementType = E_KeywordFunction
							ElseIf StartsWith(bTrim, "Sub ") Then
								Buff = LTrim(Mid(LTrim(bTrim), 5))
								te->ElementType = E_KeywordSub
							ElseIf StartsWith(bTrim, "Operator ") Then
								Buff = LTrim(Mid(LTrim(bTrim), 10))
								te->ElementType = E_KeywordOperator
							End If
						End If
						If te->Parameters = "" Then
							te->Parameters = Buff
						ElseIf EndsWith(te->Parameters, " ") Then
							te->Parameters &= LTrim(Buff)
						Else
							te->Parameters &= !"\r" & Buff
						End If
					End If
				ElseIf Parag = parUsage Then
					'If Buff <> "" AndAlso te <> 0 Then te->Comment &= !"\r" & Trim(Buff)
				ElseIf Parag = parParameters Then
					'If Buff <> "" AndAlso te <> 0 Then te->Comment &= !"\r" & Trim(Buff)
				ElseIf Parag = parReturnValue Then
					If Buff <> "" AndAlso te <> 0 Then
						If bReturnValueStart Then
							te->Comment &= !"\r" & MLReturnValue & !"\r   " & Buff '"<a href=""" & *KeywordsHelpPath & "~" & Str(LineNumber) & "~" & MLMoreDetails & "~" & StartBuff & """>" & MLReturnValue & !"</a>\r " & Trim(Buff)
						Else
							te->Comment &= !"\r" & Trim(Buff)
							bReturnValueStart = False
						End If
					End If
				ElseIf Parag = parDescription Then
					If Not bDescriptionEnd Then
						Pos1 = InStr(Buff, MLDot) 'you must add "." to your language file for good local showing
						If Pos1 = InStr(Buff, "...") Then Pos1 = InStr(Pos1 + 3, Buff, MLDot)
						'If Pos1 < 100 Then Pos1 = 100
						If Pos1 > 0 Then
							Buff = Left(Buff, Pos1) & " <a href=""" & *KeywordsHelpPath & "|" & Str(LineNumber) & "|" & MLMoreDetails & "|" & StartBuff & """>" & MLMoreDetails & !"</a>\r"
							bDescriptionEnd = True
						End If
						If Buff <> "" AndAlso te <> 0 Then
							If bDescriptionStart Then
								te->Comment &= !"\r" & MLDescription & !"\r   " & Buff '!"\r<a href=""" & *KeywordsHelpPath & "~" & Str(LineNumber) & "~" & MLMoreDetails & "~" & StartBuff & """>" & MLDescription & !"</a>\r " & Trim(Buff)
							Else
								te->Comment &= " " & Trim(Buff)
							End If
						End If
						bDescriptionStart = False
					End If
				ElseIf Parag = parExample Then
					
				ElseIf Parag = parDifferencesFromQB Then
					
				ElseIf Parag = parSeeAlso Then
					If te <> 0 AndAlso EndsWith(te->Parameters, !"\r") Then te->Parameters = Left(te->Parameters, Len(te->Parameters) - 1)
					If bDescriptionEnd = False Then
						te->Comment &= " <a href=""" & *KeywordsHelpPath & "|" & Str(LineNumber) & "|" & MLMoreDetails & "|" & StartBuff & """>" & MLMoreDetails & !"</a>\r"
						bDescriptionEnd = True
					End If
				End If
				bStart = False
			End If
		Loop
	End If
	CloseFile_(Fn)
	pFunctions = @GlobalAsmFunctionsHelp
	InEnglish = False
	Fn = FreeFile_
	If LCase(App.CurLanguage) = "english" OrElse Dir(ExePath & "/Settings/Others/AsmKeywordsHelp." & App.CurLanguage & ".txt") = "" Then
		InEnglish = True
		WLet(AsmKeywordsHelpPath, ExePath & "/Settings/Others/AsmKeywordsHelp.txt")
	Else
		WLet(AsmKeywordsHelpPath, ExePath & "/Settings/Others/AsmKeywordsHelp." & App.CurLanguage & ".txt")
	End If
	Result = -1
	Result = Open(*AsmKeywordsHelpPath For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(*AsmKeywordsHelpPath For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(*AsmKeywordsHelpPath For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(*AsmKeywordsHelpPath For Input As #Fn): tEncode= 1
	If Result = 0 Then
			If tEncode = 1 AndAlso Not InEnglish Then MsgBox ("The file encoding is not UTF-8 (BOM). You should convert it to UTF-8 (BOM).") & Chr(13, 10) & *AsmKeywordsHelpPath
		Dim As TypeElement Ptr te, te1
		Dim As WString * 1024 Buff, StartBuff, bTrim
		Dim As Boolean bAsmCommand, bExampleStarted
		Dim As Paragraph Parag
		Dim As List Commands
		Dim As WString * 1024 MLSyntax = ("Syntax"), MLExample = ("Example"), MLMoreDetails = ("More details ..."), MLDot = (".")
		Dim As Integer Pos1, Pos2, LineNumber
		Do Until EOF(Fn)
			LineNumber += 1
			Line Input #Fn, Buff
			If Trim(Buff) = "" Then Continue Do
			Dim As UString res(Any)
			Pos1 = InStr(Buff, " — ")
			bAsmCommand = False
			If Pos1 > 0 Then
				bAsmCommand = True
				Split(Left(Buff, Pos1 - 1), ", ", res())
				For i As Integer = 0 To UBound(res)
					If InStr(Trim(res(i)), " ") Then bAsmCommand = False: Exit For
				Next
			End If
			If bAsmCommand Then
				Parag = parStart
				Commands.Clear
				For i As Integer = 0 To UBound(res)
					te = _New( TypeElement)
					te->Name = Trim(res(i))
					te->DisplayName = Trim(res(i))
					te->ElementType = E_Keyword
					te->FileName = *AsmKeywordsHelpPath
					te->Comment = "<a href=""" & *AsmKeywordsHelpPath & "|" & Str(LineNumber - 1) & "|" & te->Name & "|" & te->Name & """>" & te->Name & !"</a>\r   " & Mid(Buff, Pos1 + 3) & !"\r"
					pFunctions->Add te->Name, te
					Commands.Add te
				Next
			ElseIf Buff = "Syntax" OrElse Buff = MLSyntax Then
				Parag = parSyntax
			ElseIf Buff = "Example" OrElse Buff = "Examples" OrElse Buff = MLExample Then
				Parag = parExample
				bExampleStarted = True
			ElseIf Buff = "Arithmetic And Logic Instructions" Then
				
			Else
				If Parag = parStart Then
					For i As Integer = 0 To Commands.Count - 1
						te = Commands.Item(i)
						If te->Comment = "" Then
							te->Comment = Buff
						Else
							te->Comment &= "   " & LTrim(Buff, !"\t")
						End If
					Next i
				ElseIf Parag = parSyntax Then
					For i As Integer = 0 To Commands.Count - 1
						te = Commands.Item(i)
						If te->Parameters = "" Then
							te->Parameters = Buff
						ElseIf EndsWith(te->Parameters, " ") Then
							te->Parameters &= LTrim(Buff)
						Else
							te->Parameters &= !"\r" & Buff
						End If
					Next
				ElseIf Parag = parExample Then
					For i As Integer = 0 To Commands.Count - 1
						te = Commands.Item(i)
						If bExampleStarted Then
							te->Comment &= !"\r\r" & MLExample & !"\r   " & Buff
							bExampleStarted	= False
						Else
							te->Comment &= !"\r" & "   " & Trim(Buff)
						End If
					Next
				End If
			End If
		Loop
	End If
	CloseFile_(Fn)
End Sub

Sub LoadSnippets
	Dim As UString f
	f = Dir(ExePath & "/Settings/Snippets/*.ini")
	While f <> ""
		Dim As Integer i, Pos1, Pos2, Pos3
		Dim As Integer Fn = FreeFile_, Result
		Dim As WString * 2048 Buff, Parameters, NewParameters
		Dim As TypeElement Ptr te, teParam
		Dim As UString FileName = ExePath & "/Settings/Snippets/" & f
		Result = Open(FileName For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn)
		If Result = 0 Then
			Do Until EOF(Fn)
				Line Input #Fn, Buff
				Pos1 = InStr(Buff, "=")
				If (Len(Trim(Buff, Any !"\t ")) > 0) AndAlso (Pos1 > 0) AndAlso Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then
					te = _New( TypeElement)
					te->Name = Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")
					te->DisplayName = te->Name
					te->ElementType = E_Snippet
					Parameters = Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					Parameters = Replace(Parameters, "\r", !"\r")
					Parameters = Replace(Parameters, "\t", !"\t")
					te->Comment = te->Name
					Snippets.Add te->Name, te
					Dim As Integer s = 1, idx, j, k
					Dim As String ch, Number
					Pos1 = InStr(Parameters, "$")
					NewParameters = ""
					Do While Pos1 > 0
						NewParameters &= Mid(Parameters, s, Pos1 - s)
						Number = ""
						teParam = _New(TypeElement)
						teParam->ElementType = E_Snippet
						For i As Integer = Pos1 + 1 To Len(Parameters) + 1
							ch = Chr(Parameters[i - 1])
							If ch = "{" Then
								Pos2 = InStr(i + 1, Parameters, ":")
								Pos3 = InStr(i + 1, Parameters, "}")
								Number = Mid(Parameters, i + 1, Pos2 - (i + 1))
								teParam->DisplayName = Mid(Parameters, Pos2 + 1, Pos3 - Pos2 - 1)
								NewParameters &= teParam->DisplayName
								j = j + Len(Number) + 4
								s = Pos3 + 1
								Exit For
							ElseIf ch >= "0" AndAlso ch <= "9" Then
								Number &= ch
								j = j + 1
							Else
								If Number <> "" AndAlso te->Elements.Contains(Number, , , , idx) Then
									teParam->DisplayName = Cast(TypeElement Ptr, te->Elements.Object(idx))->DisplayName
									NewParameters &= teParam->DisplayName
									j = j - Len(Number) + 1
								Else
									j = j + 1
								End If
								If ch = !"\r" Then
									j = 0
									k = 0
								End If
								s = i
								Exit For
							End If
						Next
						Pos2 = InStrRev(Parameters, !"\r", Pos1)
						teParam->Name = Number
						teParam->StartLine = InStrCount(Left(Parameters, Pos1), !"\r")
						teParam->EndLine = teParam->StartLine
						teParam->StartChar = Pos1 - Pos2 - 1 - k
						teParam->EndChar = teParam->StartChar + Len(teParam->DisplayName)
						te->Elements.Add teParam->Name, teParam
						Pos1 = InStr(s, Parameters, "$")
						k = j
					Loop
					NewParameters &= Mid(Parameters, s)
					te->Parameters = NewParameters
					te->Elements.Sort
				End If
			Loop
			Snippets.Sort
		End If
		CloseFile_(Fn)
		f = Dir()
	Wend
End Sub

Function GetTypeLink(ByRef TypeName As String, ByVal bMarkDown As Boolean = False) As String
	'putFont As Function(ByVal pThis As Any Ptr,ByVal pVal As IFontDisp Ptr) As HRESULT
	Dim As String NewTypeName
	If bMarkDown Then
		If StartsWith(TypeName, "Const ") Then
			NewTypeName = Trim(Mid(TypeName, 7))
			Return "[`Const`](""https://www.freebasic.net/wiki/KeyPgConst"")" & IIf(pkeywords1 <> 0 AndAlso pkeywords1->Contains(NewTypeName), "[`" & NewTypeName & "`](""https://www.freebasic.net/wiki/KeyPg" & NewTypeName & """)", "[`" & NewTypeName & "`]")
		Else
			Dim As Integer posi = InStrRev(LCase(TypeName), " as ") + 4
			If posi < 5 Then posi = 1
			NewTypeName = Trim(Mid(TypeName, posi))
			Return IIf(pkeywords1 <> 0 AndAlso pkeywords1->Contains(NewTypeName), "[`" & NewTypeName & "`](""https://www.freebasic.net/wiki/KeyPg" & NewTypeName & """)" , "[`" & NewTypeName & "`]")
		End If
	Else
		If StartsWith(TypeName, "Const ") Then
			NewTypeName = Trim(Mid(TypeName, 7))
			Return "<a href=""https://www.freebasic.net/wiki/KeyPgConst"">Const</a> " & IIf(pkeywords1 <> 0 AndAlso pkeywords1->Contains(NewTypeName), "<a href=""https://www.freebasic.net/wiki/KeyPg" & NewTypeName & """>" & NewTypeName & "</a>", "[[" & NewTypeName & "]]")
		Else
			Dim As Integer posi = InStrRev(LCase(TypeName), " as ") + 4
			If posi < 5 Then posi = 1
			NewTypeName = Trim(Mid(TypeName, posi))
			Return IIf(pkeywords1 <> 0 AndAlso pkeywords1->Contains(NewTypeName), "<a href=""https://www.freebasic.net/wiki/KeyPg" & NewTypeName & """>" & NewTypeName & "</a>", "[[" & NewTypeName & "]]")
		End If
	End If
End Function

Function IsMyFbFrameworkLibrary(ByRef Path As UString) As Boolean
	'' framework.dll (built from Controls/Framework/mff) lives inside Controls/Framework/,
	'' same folder as its headers/sources -- match both the folder and the filename.
	Dim As String pathText = LCase(Path)
	Return InStr(pathText, "framework") > 0 AndAlso Right(pathText, 13) = "framework.dll"
End Function

Function GetMyFbFrameworkLibrary() As Library Ptr
	If MFFCtlLibrary <> 0 Then Return MFFCtlLibrary
	For i As Integer = 0 To ControlLibraries.Count - 1
		Dim As Library Ptr ctlLib = ControlLibraries.Item(i)
		If ctlLib <> 0 AndAlso ctlLib->Enabled Then
			If IsMyFbFrameworkLibrary(ctlLib->Path) Then
				MFFCtlLibrary = ctlLib
				Return ctlLib
			End If
		End If
	Next
	Return 0
End Function

Sub RunDeferredFormDesign()
	mApplyingDeferredFormDesign = True
	Dim As TabControl Ptr pTabCodeWnd
	For j As Integer = 0 To TabPanels.Count - 1
		pTabCodeWnd = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To pTabCodeWnd->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, pTabCodeWnd->Tabs[i])
			If tb = 0 Then Continue For
			If tb->FormNeedDesign Then
				tb->FormNeedDesign = False
				If pApp = 0 Then pApp = @VisualFBEditorApp
				If pApp->MainForm = 0 Then pApp->MainForm = @frmMain
				tb->FormDesign
				ApplyFormTabView(tb)
			End If
		Next
	Next
	mApplyingDeferredFormDesign = False
	If ptabCode <> 0 AndAlso ptabCode->SelectedTabIndex >= 0 Then
		tabCode_SelChange *ptabCode->Designer, *ptabCode, ptabCode->SelectedTabIndex
	End If
End Sub

Sub LoadToolBox(ForLibrary As Library Ptr = 0)
	Dim As String f
	Dim As Integer i, j
	Dim As My.Sys.Drawing.Cursor cur
	Dim As String IncludePath
	Dim As UString Temp
	Dim As UInteger Attr
	If ForLibrary = 0 AndAlso ControlLibraries.Count = 0 Then
		IncludeMFFPath = iniSettings.ReadBool("Options", "IncludeMFFPath", True)
		WLet(MFFPath, SanitizeIniCriticalPath(iniSettings.ReadString("Options", "MFFPath", "./Controls/Framework"), "./Controls/Framework"))
		'' Every folder under Controls\ with a valid Settings.ini/Lib64 entry is always
		'' loaded into the toolbox -- no per-library enable/disable UI (owner decision,
		'' 2026-07-13; formerly the Add Components dialog, now removed). Re-scanned fresh
		'' every IDE session rather than cached in Settings/astoria.ini, so a newly added
		'' library folder shows up immediately with no extra step.
		Dim LibKey As String = "Lib64"
		Dim DirName As WString * 1024
		DirName = Dir(ExePath & WindowsSlash & "Controls" & WindowsSlash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
		While DirName <> ""
			If (Attr And fbDirectory) <> 0 Then
				If DirName <> "." AndAlso DirName <> ".." Then
					Dim As IniFile ini
					ini.Load ExePath & WindowsSlash & "Controls" & WindowsSlash & DirName & WindowsSlash & "Settings.ini"
					Dim FileName As UString = ini.ReadString("Setup", LibKey)
					If FileName <> "" Then
						Temp = "Controls" & WindowsSlash & DirName & WindowsSlash & FileName
						Var CtlLibrary = _New(Library)
						CtlLibrary->Name = ini.ReadString("Setup", "Name")
						CtlLibrary->Tips = ini.ReadString("Setup", "Tips")
						CtlLibrary->Path = GetFullPath(Temp)
						CtlLibrary->HeadersFolder = ini.ReadString("Setup", "HeadersFolder")
						CtlLibrary->SourcesFolder = ini.ReadString("Setup", "SourcesFolder")
						CtlLibrary->IncludeFolder = GetFullPath(GetFullPath(ini.ReadString("Setup", "IncludeFolder"), Temp))
						CtlLibrary->Lib32Folder = GetFullPath(GetFullPath(ini.ReadString("Setup", "Lib32Folder"), Temp))
						CtlLibrary->Lib64Folder = GetFullPath(GetFullPath(ini.ReadString("Setup", "Lib64Folder"), Temp))
						CtlLibrary->Lib64ArmFolder = GetFullPath(GetFullPath(ini.ReadString("Setup", "Lib64ArmFolder"), Temp))
						CtlLibrary->LibX32Folder = GetFullPath(GetFullPath(ini.ReadString("Setup", "LibX32Folder"), Temp))
						CtlLibrary->LibX64Folder = GetFullPath(GetFullPath(ini.ReadString("Setup", "LibX64Folder"), Temp))
						CtlLibrary->RuntimeDlls = ini.ReadString("Setup", "RuntimeDlls")
						CtlLibrary->FolderName = DirName
						CtlLibrary->FolderPath = ExePath & WindowsSlash & "Controls" & WindowsSlash & DirName
						CtlLibrary->Enabled = True
						If LCase(DirName) = "framework" Then
							If CtlLibrary->HeadersFolder = "" Then CtlLibrary->HeadersFolder = "mff"
							If CtlLibrary->SourcesFolder = "" Then CtlLibrary->SourcesFolder = "mff"
							MFFCtlLibrary = CtlLibrary
							ControlLibraries.Insert(0, CtlLibrary)
						Else
							ControlLibraries.Add CtlLibrary
						End If
					End If
				End If
			End If
			DirName = Dir(Attr)
		Wend
	End If
	Dim As Library Ptr CtlLibrary
	' MyFbFramework must load before other FB control DLLs in Controls\ (shared fbrt runtime).
	Dim As Integer iPass
	For iPass = 0 To 1
		For i = 0 To ControlLibraries.Count - 1
			CtlLibrary = ControlLibraries.Item(i)
			If iPass = 0 Then
				If Not IsMyFbFrameworkLibrary(CtlLibrary->Path) Then Continue For
			Else
				If IsMyFbFrameworkLibrary(CtlLibrary->Path) Then Continue For
			End If
			If ForLibrary <> 0 AndAlso CtlLibrary <> ForLibrary Then Continue For
			If CtlLibrary->Handle = 0 Then
				CtlLibrary->Handle = DyLibLoad(GetFullPath(CtlLibrary->Path))
				If Not FileExists(GetFullPath(CtlLibrary->Path)) Then
					MsgBox ("File not found") & ":" & WChr(13, 10) & WChr(13, 10) & FormatMsgPathU(CtlLibrary->Path) & WChr(13, 10) & WChr(13, 10) & ("Can not load control to toolbox")
				ElseIf CtlLibrary->Handle = 0 Then
					MsgBox ("File not loaded") & ":" & WChr(13, 10) & WChr(13, 10) & FormatMsgPathU(CtlLibrary->Path) & WChr(13, 10) & WChr(13, 10) & ("Can not load control to toolbox")
				End If
			End If
			If Not CtlLibrary->Enabled Then Continue For
			IncludePath = GetFullPath(GetFullPath(CtlLibrary->HeadersFolder, CtlLibrary->Path))
			If Not EndsWith(IncludePath, WindowsSlash) Then IncludePath &= WindowsSlash
			f = Dir(IncludePath & "*.bi")
			While f <> ""
				LoadFunctions GetOSPath(IncludePath & f), LoadParam.OnlyFilePath, Comps, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args, , CtlLibrary
				f = Dir()
			Wend
			IncludePath = GetFullPath(GetFullPath(CtlLibrary->SourcesFolder, CtlLibrary->Path))
			If Not EndsWith(IncludePath, WindowsSlash) Then IncludePath &= WindowsSlash
			f = Dir(IncludePath & "*.bas")
			While f <> ""
				LoadFunctions GetOSPath(IncludePath & f), LoadParam.OnlyFilePath, Comps, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args, , CtlLibrary
				f = Dir()
			Wend
		Next i
	Next iPass
	Comps.Sort
	If ForLibrary = 0 Then InitToolBoxTree()
	Var iOld = -1, iNew = 0
	Dim As String it = "Cursor"
	Dim As String wikiFolder = ExePath & "/Controls/Framework/Framework.wiki/"
	Dim As String wikiTitle
	Dim As List ECLines, teList
	Dim As TypeElement Ptr tbi, tbi1, te, te1
	For i = 0 To Comps.Count - 1
		tbi = Cast(TypeElement Ptr, Comps.Object(i))
		If tbi=0 Then Continue For
		If LCase(Comps.Item(i)) = "control" Or LCase(Comps.Item(i)) = "containercontrol" Or LCase(Comps.Item(i)) = "menu" Or LCase(Comps.Item(i)) = "component" Or LCase(Comps.Item(i)) = "dialog" Then Continue For
		If tbi->ElementType = E_TypeCopy Then Continue For
		If ForLibrary <> 0 AndAlso tbi->Tag <> ForLibrary Then Continue For
		iNew = GetTypeControl(Comps.Item(i))
		tbi->ControlType = iNew
		If iNew = 0 Then Continue For
		If IsExcludedToolBoxControl(Comps.Item(i)) Then Continue For
		it = Comps.Item(i)
			Dim As Any Ptr LibHandle
			LibHandle = Cast(Library Ptr, tbi->Tag)->Handle
			imgListTools.Add it, it, LibHandle
		Dim As TreeNode Ptr parentNode = GetToolBoxCategoryNode(iNew)
		If parentNode = 0 Then Continue For
		If ToolBoxNodeExists(parentNode, it) Then Continue For
		' Insert alphabetically, keeping any pinned Cursor node first. Only the Controls
		' group has one, so the scan starts at 0 elsewhere -- starting at 1 unconditionally
		' would leave the first real control out of the comparison and misplace whatever
		' sorts before it. The node image comes from imgListTools, keyed by control name
		' (loaded above from the control library resources).
		Dim As Integer firstSortable = 0
		If parentNode->Nodes.Count > 0 AndAlso parentNode->Nodes.Item(0)->Text = "Cursor" Then firstSortable = 1
		Dim As Integer insertIndex = parentNode->Nodes.Count
		For j = firstSortable To parentNode->Nodes.Count - 1
			If LCase(parentNode->Nodes.Item(j)->Text) > LCase(it) Then insertIndex = j: Exit For
		Next j
		Dim As TreeNode Ptr toolNode
		If insertIndex >= parentNode->Nodes.Count Then
			toolNode = parentNode->Nodes.Add(it, it, "", it, it)
		Else
			toolNode = parentNode->Nodes.Insert(insertIndex, it, it, "", it, it)
		End If
		toolNode->Tag = Comps.Object(i)
		iOld = iNew
	Next i
	' HTML STYLE
		' Markdown STYLE
		'This is a component of the MyFbFramework, which is part of the freeBasic framework and belongs to the container control.
		
		'This is part of the MyFbFramework FreeBasic framework. It belongs to the container control.
		'This is part of the properties of the grid control. It belongs to the .
		
		'The Grid control is similar in functionality to the DataGridView in VB.Net but uses the syntax and conventions defined by the MyFbFramework.
		If Dir(wikiFolder) = "" Then MkDir wikiFolder
		Dim As String ControlParent, TmpControlName, TmpControlChildName, TmpControlSubName, StringToC, tmpDefinition
		Dim As String ControlTypArr(0 To 4) = {"type", "Control", "Container Control", "component", "Dialog"}
		Dim As Integer Posi
		Dim As Boolean bNotEmpty
		Dim As Dictionary ControlParentDict
		Dim As WString Ptr FileContentPtr, FileContentPtr1, FileContentEmpty
		Dim As FileEncodings FileEncoding = FileEncodings.Utf8
		Dim As NewLineTypes NewLineType, NewLineType1
		Dim As UString controlParentFile = GetFullPath(ExePath & "/Controls/Framework/ControlParent.csv")
		If FileExists(controlParentFile) Then
			Dim As Integer cpFn = FreeFile_
			If Open(controlParentFile For Input As #cpFn) = 0 Then
				Dim As String cpLine
				Dim As Integer cpTab
				While Not EOF(cpFn)
					Line Input #cpFn, cpLine
					cpTab = InStr(cpLine, Chr(9))
					If cpTab > 0 Then ControlParentDict.Add Trim(Left(cpLine, cpTab - 1)), Trim(Mid(cpLine, cpTab + 1))
				Wend
				CloseFile_(cpFn)
			Else
				ControlParentDict.Add "NULL", "NULL"
			End If
		Else
			ControlParentDict.Add "NULL", "NULL"
		End If
		For i = 0 To Comps.Count - 1
			tbi = Cast(TypeElement Ptr, Comps.Object(i))
			If tbi = 0 OrElse tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			If tbi->ControlType = 0 Then
				Posi = ControlParentDict.IndexOfKey(Comps.Item(i))
				If Posi <> -1 Then TmpControlName = ControlParentDict.Item(Posi)->Text Else TmpControlName= ""
				tmpDefinition = "`" & Comps.Item(i) & "` is a type or collection of the " & TmpControlName & " control, part of the freeBasic framework MyFbFramework."
			Else
				TmpControlName = Comps.Item(i)
				tmpDefinition = "```" & Comps.Item(i) & "``` is a " & ControlTypArr(tbi->ControlType) & " within the MyFbFramework."
				tmpDefinition &= "The " & TmpControlName & " control structure is highly analogous to the VB6, vb.net " & TmpControlName & " control, with similar components, properties, and behaviors but uses the syntax and conventions defined by the MyFbFramework."
			End If
			
			WAdd(FileContentPtr, Chr(13, 10) & "## " & Comps.Item(i))
			WAdd(FileContentPtr, Chr(13, 10) & "### Definition")
			If Trim(tbi->OwnerNamespace) <> "" Then WAdd(FileContentPtr, Chr(13, 10) & "Namespace: " & tbi->OwnerNamespace & " ")
			FPropertyItems.Clear
			TabWindow.FillProperties Comps.Item(i)
			FPropertyItems.Sort
			WAdd(FileContentPtr, Chr(13, 10))
			WAdd(FileContentPtr, Chr(13, 10) & "`" & Comps.Item(i) & "` - " & IIf(Trim(tbi->Comment) <> "", WStr(tbi->Comment), WStr(tmpDefinition)))
			WAdd(FileContentPtr, Chr(13, 10))
			bNotEmpty = False
			WAdd(FileContentPtr, Chr(13, 10) & "### Properties")
			WLet(FileContentPtr1, Chr(13, 10) & "|Name|Description|Syntax|")
			WAdd(FileContentPtr1, Chr(13, 10) & "| :---- | :---- | :---- |")
			For j As Integer = 0 To FPropertyItems.Count - 1
				te = FPropertyItems.Object(j)
				If te = 0 OrElse te->ElementType <> ElementTypes.E_Field AndAlso te->ElementType <> ElementTypes.E_Property Then Continue For
				Var Pos1 = InStr(te->DisplayName, "[")
				If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
				WAdd(FileContentPtr1, Chr(13, 10) & "|" & FPropertyItems.Item(j) & "|" & Trim(te->Comment, Any !"\r\n\t ") & "|`" & te->Parameters & "`|")
				bNotEmpty = True
			Next
			If bNotEmpty Then
				WAdd(FileContentPtr, Chr(13, 10) & *FileContentPtr1)
			Else
				WAdd(FileContentPtr, Chr(13, 10) & "(No properties defined)")
			End If
			
			WAdd(FileContentPtr, Chr(13, 10))
			bNotEmpty = False
			WAdd(FileContentPtr, Chr(13, 10) & "### Methods")
			WLet(FileContentPtr1, Chr(13, 10) & "|Name|Description|Syntax|")
			WAdd(FileContentPtr1, Chr(13, 10) & "| :---- | :---- | :---- |")
			For j As Integer = 0 To FPropertyItems.Count - 1
				te = FPropertyItems.Object(j)
				If te = 0 OrElse te->ElementType <> ElementTypes.E_Function AndAlso te->ElementType <> ElementTypes.E_Sub AndAlso te->ElementType <> ElementTypes.E_Define AndAlso te->ElementType <> ElementTypes.E_Macro Then Continue For
				Var Pos1 = InStr(te->DisplayName, "[")
				If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
				WAdd(FileContentPtr1, Chr(13, 10) & "|" & FPropertyItems.Item(j) & "|" & Trim(te->Comment, Any !"\r\n\t ") & "|`" & IIf(te->ElementType = ElementTypes.E_Function, "Declare Function", "Declare Sub") & " " & te->Parameters & "`|")
				bNotEmpty = True
			Next
			If bNotEmpty Then
				WAdd(FileContentPtr, Chr(13, 10) & *FileContentPtr1)
			Else
				WAdd(FileContentPtr, Chr(13, 10) & "(No methods defined)")
			End If
			bNotEmpty = False
			WAdd(FileContentPtr, Chr(13, 10) & "### Events")
			WLet(FileContentPtr1, Chr(13, 10) & "|Name|Description|Syntax|")
			WAdd(FileContentPtr1, Chr(13, 10) & "| :---- | :---- | :---- |")
			For j As Integer = 0 To FPropertyItems.Count - 1
				te = FPropertyItems.Object(j)
				If te = 0 OrElse te->ElementType <> ElementTypes.E_Event Then Continue For
				Var Pos1 = InStr(te->DisplayName, "[")
				If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
				WAdd(FileContentPtr1, Chr(13, 10) & "|" & FPropertyItems.Item(j) & "|" & Trim(te->Comment, Any !"\r\n\t ") & "|`" & te->Parameters & "`|")
				bNotEmpty = True
			Next
			If bNotEmpty Then
				WAdd(FileContentPtr, Chr(13, 10) & *FileContentPtr1)
			Else
				WAdd(FileContentPtr, Chr(13, 10) & "(No events defined)")
			End If
			'SaveToFile(wikiFolder & Comps.Item(i) & ".md", *FileContentPtr, FileEncoding, NewLineType)
			_Deallocate(FileContentPtr ): FileContentPtr = 0
		Next i
		WLet(FileContentPtr, "## " & "Globals Enums")
		For i = 0 To Globals.Enums.Count - 1
			tbi = Cast(TypeElement Ptr, Globals.Enums.Object(i))
			If tbi = 0 OrElse tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			WAdd(FileContentPtr, Chr(13, 10) & "### " & Globals.Enums.Item(i) & " Enum")
			WAdd(FileContentPtr, Chr(13, 10) &  "`" & Globals.Enums.Item(i) & "` is a global enum within the MyFbFramework.")
			WAdd(FileContentPtr, Chr(13, 10) & tbi->Comment)
			If tbi->OwnerNamespace <> "" Then
				WAdd(FileContentPtr, Chr(13, 10) & "#### Definition")
				If Trim(tbi->OwnerNamespace) <> "" Then WAdd(FileContentPtr, Chr(13, 10) & "Namespace: " & tbi->OwnerNamespace)
			End If
			WAdd(FileContentPtr, Chr(13, 10) & "#### Fields")
			WAdd(FileContentPtr, Chr(13, 10) & "|Name|Description|Syntax|")
			WAdd(FileContentPtr, Chr(13, 10) & "| :---- | :---- | :---- |")
			For j As Integer = 0 To tbi->Elements.Count - 1
				te = tbi->Elements.Object(j)
				If te = 0 Then Continue For
				WAdd(FileContentPtr, Chr(13, 10) & "|`" & tbi->Elements.Item(j) & "`|" & te->Value & "|`" & te->Comment & "`|")
			Next
		Next i
		'SaveToFile(wikiFolder & "Globals Enums.md", *FileContentPtr, FileEncoding, NewLineType)
		_Deallocate(FileContentPtr ): FileContentPtr = 0
		If FileContentPtr1 Then Deallocate(FileContentPtr1 ): FileContentPtr1 = 0
		WLet(FileContentPtr1, "## Globals Procedures")
		WAdd(FileContentPtr1, Chr(13, 10) & "|Name|Type|Description|Syntax|")
		WAdd(FileContentPtr1, Chr(13, 10) & "| :---- | :---- | :---- | :---- |")
For i = 0 To Globals.Functions.Count - 1
			tbi = Cast(TypeElement Ptr, Globals.Functions.Object(i))
			If tbi = 0 OrElse tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			If tbi->ElementType <> ElementTypes.E_Define AndAlso tbi->ElementType <> ElementTypes.E_Macro AndAlso tbi->ElementType <> ElementTypes.E_Function AndAlso tbi->ElementType <> ElementTypes.E_Sub Then Continue For
			If tbi->Declaration Then Continue For
			WAdd(FileContentPtr1, Chr(13, 10) & "|" & Replace(tbi->FullName, "My.Sys.Forms.", "") & "|" & IIf(tbi->ElementType = ElementTypes.E_Function, " Function", IIf(tbi->ElementType = ElementTypes.E_Sub, " Method", IIf(tbi->ElementType = ElementTypes.E_Define, " Define", IIf(tbi->ElementType = ElementTypes.E_Macro, " Macro", "")))) & "|" )
			WAdd(FileContentPtr1, "|`" & IIf(tbi->ElementType = ElementTypes.E_Function, "Function", IIf(tbi->ElementType = ElementTypes.E_Sub, "Sub", IIf(tbi->ElementType = ElementTypes.E_Define, "#define", IIf(tbi->ElementType = ElementTypes.E_Macro, "#macro", "")))) & " " & tbi->Parameters & "`|")
		Next i
		'SaveToFile(wikiFolder & "Globals Procedures.md", *FileContentPtr1, FileEncoding, NewLineType)
		_Deallocate(FileContentPtr1 ): FileContentPtr1 = 0
		'WLet(FileContentPtr1, "## Globals Args")
		'For i = 0 To Globals.Args.Count - 1
		'	tbi = Cast(TypeElement Ptr, Globals.Args.Object(i))
		'	If tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
		'	WAdd(FileContentPtr1, Chr(13, 10) & "### " & tbi->Name)
		'	WAdd(FileContentPtr, Chr(13, 10) & "#### Definition")
		'	If Trim(tbi->OwnerNamespace) <> "" Then WAdd(FileContentPtr1, Chr(13, 10) & "Namespace:  " & tbi->OwnerNamespace)
		'	WAdd(FileContentPtr1, Chr(13, 10) &  "`" & tbi->Name & "` is a global variable in MyFbFramework.")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "`" & tbi->Name & "` - " & tbi->Comment)
		'	WAdd(FileContentPtr1, Chr(13, 10) & "#### Syntax")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "```FreeBasic")
		'	WAdd(FileContentPtr1, Chr(13, 10) & tbi->Parameters)
		'	WAdd(FileContentPtr1, Chr(13, 10) & "```")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "#### Property Value")
		'	WAdd(FileContentPtr1, Chr(13, 10) & GetTypeLink(tbi->TypeName, True))
		'Next i
		'SaveToFile(wikiFolder & "Globals Args.md", *FileContentPtr1, FileEncoding, NewLineType)
		'Deallocate FileContentPtr1 : FileContentPtr1 = 0
	

	For i = 0 To ControlLibraries.Count - 1
		CtlLibrary = ControlLibraries.Item(i)
		If CtlLibrary = 0 OrElse (ForLibrary <> 0 AndAlso CtlLibrary <> ForLibrary) Then Continue For
		If CtlLibrary->Handle Then DyLibFree(CtlLibrary->Handle)
	Next i
	Exit Sub
	ErrorHandler:
	Dim As String errMsg = ErrDescription(Err) & " (" & Err & ") in line " & Erl() & _
		" (Handler line: " & __LINE__ & ") in function " & ZGet(Erfn()) & _
		" (Handler function: " & __FUNCTION__ & ") in module " & ZGet(Ermn()) & _
		" (Handler file: " & __FILE__ & ") "
	MsgBox errMsg
End Sub

Sub LoadTheme
	iniTheme.Load ExePath & "/Settings/Themes/" & *CurrentTheme & ".ini"
	NormalText.ForegroundOption = iniTheme.ReadInteger("Colors", "NormalTextForeground", clBlack)
	NormalText.BackgroundOption = iniTheme.ReadInteger("Colors", "NormalTextBackground", clWhite)
	NormalText.FrameOption = iniTheme.ReadInteger("Colors", "NormalTextFrame", -1)
	NormalText.Bold = iniTheme.ReadInteger("FontStyles", "NormalTextBold", 0)
	NormalText.Italic = iniTheme.ReadInteger("FontStyles", "NormalTextItalic", 0)
	NormalText.Underline = iniTheme.ReadInteger("FontStyles", "NormalTextUnderline", 0)
	Bookmarks.ForegroundOption = iniTheme.ReadInteger("Colors", "BookmarksForeground", -1)
	Bookmarks.BackgroundOption = iniTheme.ReadInteger("Colors", "BookmarksBackground", -1)
	Bookmarks.FrameOption = iniTheme.ReadInteger("Colors", "BookmarksFrame", -1)
	Bookmarks.IndicatorOption = iniTheme.ReadInteger("Colors", "BookmarksIndicator", -1)
	Bookmarks.Bold = iniTheme.ReadInteger("FontStyles", "BookmarksBold", 0)
	Bookmarks.Italic = iniTheme.ReadInteger("FontStyles", "BookmarksItalic", 0)
	Bookmarks.Underline = iniTheme.ReadInteger("FontStyles", "BookmarksUnderline", 0)
	Breakpoints.ForegroundOption = iniTheme.ReadInteger("Colors", "BreakpointsForeground", -1)
	Breakpoints.BackgroundOption = iniTheme.ReadInteger("Colors", "BreakpointsBackground", -1)
	Breakpoints.FrameOption = iniTheme.ReadInteger("Colors", "BreakpointsFrame", -1)
	Breakpoints.IndicatorOption = iniTheme.ReadInteger("Colors", "BreakpointsIndicator", -1)
	Breakpoints.Bold = iniTheme.ReadInteger("FontStyles", "BreakpointsBold", 0)
	Breakpoints.Italic = iniTheme.ReadInteger("FontStyles", "BreakpointsItalic", 0)
	Breakpoints.Underline = iniTheme.ReadInteger("FontStyles", "BreakpointsUnderline", 0)
	Comments.ForegroundOption = iniTheme.ReadInteger("Colors", "CommentsForeground", -1)
	Comments.BackgroundOption = iniTheme.ReadInteger("Colors", "CommentsBackground", -1)
	Comments.FrameOption = iniTheme.ReadInteger("Colors", "CommentsFrame", -1)
	Comments.Bold = iniTheme.ReadInteger("FontStyles", "CommentsBold", 0)
	Comments.Italic = iniTheme.ReadInteger("FontStyles", "CommentsItalic", 0)
	Comments.Underline = iniTheme.ReadInteger("FontStyles", "CommentsUnderline", 0)
	CurrentBrackets.ForegroundOption = iniTheme.ReadInteger("Colors", "CurrentBracketsForeground", -1)
	CurrentBrackets.BackgroundOption = iniTheme.ReadInteger("Colors", "CurrentBracketsBackground", -1)
	CurrentBrackets.FrameOption = iniTheme.ReadInteger("Colors", "CurrentBracketsFrame", -1)
	CurrentBrackets.Bold = iniTheme.ReadInteger("FontStyles", "CurrentBracketsBold", 0)
	CurrentBrackets.Italic = iniTheme.ReadInteger("FontStyles", "CurrentBracketsItalic", 0)
	CurrentBrackets.Underline = iniTheme.ReadInteger("FontStyles", "CurrentBracketsUnderline", 0)
	CurrentLine.ForegroundOption = iniTheme.ReadInteger("Colors", "CurrentLineForeground", -1)
	CurrentLine.BackgroundOption = iniTheme.ReadInteger("Colors", "CurrentLineBackground", -1)
	CurrentLine.FrameOption = iniTheme.ReadInteger("Colors", "CurrentLineFrame", -1)
	CurrentWord.ForegroundOption = iniTheme.ReadInteger("Colors", "CurrentWordForeground", -1)
	CurrentWord.BackgroundOption = iniTheme.ReadInteger("Colors", "CurrentWordBackground", -1)
	CurrentWord.FrameOption = iniTheme.ReadInteger("Colors", "CurrentWordFrame", -1)
	CurrentWord.Bold = iniTheme.ReadInteger("FontStyles", "CurrentWordBold", 0)
	CurrentWord.Italic = iniTheme.ReadInteger("FontStyles", "CurrentWordItalic", 0)
	CurrentWord.Underline = iniTheme.ReadInteger("FontStyles", "CurrentWordUnderline", 0)
	ExecutionLine.ForegroundOption = iniTheme.ReadInteger("Colors", "ExecutionLineForeground", -1)
	ExecutionLine.BackgroundOption = iniTheme.ReadInteger("Colors", "ExecutionLineBackground", -1)
	ExecutionLine.FrameOption = iniTheme.ReadInteger("Colors", "ExecutionLineFrame", -1)
	ExecutionLine.IndicatorOption = iniTheme.ReadInteger("Colors", "ExecutionLineIndicator", -1)
	FoldLines.ForegroundOption = iniTheme.ReadInteger("Colors", "FoldLinesForeground", -1)
	Identifiers.ForegroundOption = iniTheme.ReadInteger("Colors", "IdentifiersForeground", NormalText.ForegroundOption)
	Identifiers.BackgroundOption = iniTheme.ReadInteger("Colors", "IdentifiersBackground", NormalText.BackgroundOption)
	Identifiers.FrameOption = iniTheme.ReadInteger("Colors", "IdentifiersFrame", NormalText.FrameOption)
	Identifiers.Bold = iniTheme.ReadInteger("FontStyles", "IdentifiersBold", 0)
	Identifiers.Italic = iniTheme.ReadInteger("FontStyles", "IdentifiersItalic", 0)
	Identifiers.Underline = iniTheme.ReadInteger("FontStyles", "IdentifiersUnderline", 0)
	IndicatorLines.ForegroundOption = iniTheme.ReadInteger("Colors", "IndicatorLinesForeground", -1)
	For k As Integer = 0 To UBound(Keywords)
		Keywords(k).ForegroundOption = iniTheme.ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Foreground", iniTheme.ReadInteger("Colors", "KeywordsForeground", -1))
		Keywords(k).BackgroundOption = iniTheme.ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Background", iniTheme.ReadInteger("Colors", "KeywordsBackground", -1))
		Keywords(k).FrameOption = iniTheme.ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Frame", iniTheme.ReadInteger("Colors", "KeywordsFrame", -1))
		Keywords(k).Bold = iniTheme.ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Bold", iniTheme.ReadInteger("Colors", "KeywordsBold", 0))
		Keywords(k).Italic = iniTheme.ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Italic", iniTheme.ReadInteger("Colors", "KeywordsItalic", 0))
		Keywords(k).Underline = iniTheme.ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Underline", iniTheme.ReadInteger("Colors", "KeywordsUnderline", 0))
	Next k
	LineNumbers.ForegroundOption = iniTheme.ReadInteger("Colors", "LineNumbersForeground", -1)
	LineNumbers.BackgroundOption = iniTheme.ReadInteger("Colors", "LineNumbersBackground", -1)
	LineNumbers.Bold = iniTheme.ReadInteger("FontStyles", "LineNumbersBold", 0)
	LineNumbers.Italic = iniTheme.ReadInteger("FontStyles", "LineNumbersItalic", 0)
	LineNumbers.Underline = iniTheme.ReadInteger("FontStyles", "LineNumbersUnderline", 0)
	Numbers.ForegroundOption = iniTheme.ReadInteger("Colors", "NumbersForeground", -1)
	Numbers.BackgroundOption = iniTheme.ReadInteger("Colors", "NumbersBackground", -1)
	Numbers.FrameOption = iniTheme.ReadInteger("Colors", "NumbersFrame", -1)
	Numbers.Bold = iniTheme.ReadInteger("FontStyles", "NumbersBold", 0)
	Numbers.Italic = iniTheme.ReadInteger("FontStyles", "NumbersItalic", 0)
	Numbers.Underline = iniTheme.ReadInteger("FontStyles", "NumbersUnderline", 0)
	RealNumbers.ForegroundOption = iniTheme.ReadInteger("Colors", "RealNumbersForeground", Numbers.ForegroundOption )
	RealNumbers.BackgroundOption = iniTheme.ReadInteger("Colors", "RealNumbersBackground", Numbers.ForegroundOption )
	RealNumbers.FrameOption = iniTheme.ReadInteger("Colors", "RealNumbersFrame", Numbers.ForegroundOption )
	RealNumbers.Bold = iniTheme.ReadInteger("FontStyles", "RealNumbersBold", Numbers.Bold)
	RealNumbers.Italic = iniTheme.ReadInteger("FontStyles", "RealNumbersItalic", Numbers.Italic)
	RealNumbers.Underline = iniTheme.ReadInteger("FontStyles", "RealNumbersUnderline", Numbers.Underline)
	Selection.ForegroundOption = iniTheme.ReadInteger("Colors", "SelectionForeground", -1)
	Selection.BackgroundOption = iniTheme.ReadInteger("Colors", "SelectionBackground", -1)
	Selection.FrameOption = iniTheme.ReadInteger("Colors", "SelectionFrame", -1)
	SpaceIdentifiers.ForegroundOption = iniTheme.ReadInteger("Colors", "SpaceIdentifiersForeground", -1)
	Strings.ForegroundOption = iniTheme.ReadInteger("Colors", "StringsForeground", -1)
	Strings.BackgroundOption = iniTheme.ReadInteger("Colors", "StringsBackground", -1)
	Strings.FrameOption = iniTheme.ReadInteger("Colors", "StringsFrame", -1)
	Strings.Bold = iniTheme.ReadInteger("FontStyles", "StringsBold", 0)
	Strings.Italic = iniTheme.ReadInteger("FontStyles", "StringsItalic", 0)
	Strings.Underline = iniTheme.ReadInteger("FontStyles", "StringsUnderline", 0)
	
	ColorOperators.ForegroundOption = iniTheme.ReadInteger("Colors", "OperatorsForeground", -1)
	ColorOperators.BackgroundOption = iniTheme.ReadInteger("Colors", "OperatorsBackground", -1)
	ColorOperators.FrameOption = iniTheme.ReadInteger("Colors", "ColorOperatorsFrame", -1)
	ColorOperators.Bold = iniTheme.ReadInteger("FontStyles", "OperatorsBold", 0)
	ColorOperators.Italic = iniTheme.ReadInteger("FontStyles", "OperatorsItalic", 0)
	ColorOperators.Underline = iniTheme.ReadInteger("FontStyles", "OperatorsUnderline", 0)
	
	ColorByRefParameters.ForegroundOption = iniTheme.ReadInteger("Colors", "ByRefParametersForeground", Identifiers.ForegroundOption)
	ColorByRefParameters.BackgroundOption = iniTheme.ReadInteger("Colors", "ByRefParametersBackground", Identifiers.BackgroundOption)
	ColorByRefParameters.FrameOption = iniTheme.ReadInteger("Colors", "ByRefParametersFrame", Identifiers.FrameOption)
	ColorByRefParameters.Bold = iniTheme.ReadInteger("FontStyles", "ByRefParametersBold", 0)
	ColorByRefParameters.Italic = iniTheme.ReadInteger("FontStyles", "ByRefParametersItalic", 0)
	ColorByRefParameters.Underline = iniTheme.ReadInteger("FontStyles", "ByRefParametersUnderline", 0)
	
	ColorByValParameters.ForegroundOption = iniTheme.ReadInteger("Colors", "ByValParametersForeground", Identifiers.ForegroundOption)
	ColorByValParameters.BackgroundOption = iniTheme.ReadInteger("Colors", "ByValParametersBackground", Identifiers.BackgroundOption)
	ColorByValParameters.FrameOption = iniTheme.ReadInteger("Colors", "ByValParametersFrame", Identifiers.FrameOption)
	ColorByValParameters.Bold = iniTheme.ReadInteger("FontStyles", "ByValParametersBold", 0)
	ColorByValParameters.Italic = iniTheme.ReadInteger("FontStyles", "ByValParametersItalic", 0)
	ColorByValParameters.Underline = iniTheme.ReadInteger("FontStyles", "ByValParametersUnderline", 0)
	
	ColorCommonVariables.ForegroundOption = iniTheme.ReadInteger("Colors", "CommonVariablesForeground", Identifiers.ForegroundOption)
	ColorCommonVariables.BackgroundOption = iniTheme.ReadInteger("Colors", "CommonVariablesBackground", Identifiers.BackgroundOption)
	ColorCommonVariables.FrameOption = iniTheme.ReadInteger("Colors", "CommonVariablesFrame", Identifiers.FrameOption)
	ColorCommonVariables.Bold = iniTheme.ReadInteger("FontStyles", "CommonVariablesBold", 0)
	ColorCommonVariables.Italic = iniTheme.ReadInteger("FontStyles", "CommonVariablesItalic", 0)
	ColorCommonVariables.Underline = iniTheme.ReadInteger("FontStyles", "CommonVariablesUnderline", 0)
	
	ColorComps.ForegroundOption = iniTheme.ReadInteger("Colors", "ComponentsForeground", Identifiers.ForegroundOption)
	ColorComps.BackgroundOption = iniTheme.ReadInteger("Colors", "ComponentsBackground", Identifiers.BackgroundOption)
	ColorComps.FrameOption = iniTheme.ReadInteger("Colors", "ComponentsFrame", Identifiers.FrameOption)
	ColorComps.Bold = iniTheme.ReadInteger("FontStyles", "ComponentsBold", 0)
	ColorComps.Italic = iniTheme.ReadInteger("FontStyles", "ComponentsItalic", 0)
	ColorComps.Underline = iniTheme.ReadInteger("FontStyles", "ComponentsUnderline", 0)
	
	ColorConstants.ForegroundOption = iniTheme.ReadInteger("Colors", "ConstantsForeground", Identifiers.ForegroundOption)
	ColorConstants.BackgroundOption = iniTheme.ReadInteger("Colors", "ConstantsBackground", Identifiers.BackgroundOption)
	ColorConstants.FrameOption = iniTheme.ReadInteger("Colors", "ConstantsFrame", Identifiers.FrameOption)
	ColorConstants.Bold = iniTheme.ReadInteger("FontStyles", "ConstantsBold", 0)
	ColorConstants.Italic = iniTheme.ReadInteger("FontStyles", "ConstantsItalic", 0)
	ColorConstants.Underline = iniTheme.ReadInteger("FontStyles", "ConstantsUnderline", 0)
	
	ColorDefines.ForegroundOption = iniTheme.ReadInteger("Colors", "DefinesForeground", Identifiers.ForegroundOption)
	ColorDefines.BackgroundOption = iniTheme.ReadInteger("Colors", "DefinesBackground", Identifiers.BackgroundOption)
	ColorDefines.FrameOption = iniTheme.ReadInteger("Colors", "DefinesFrame", Identifiers.FrameOption)
	ColorDefines.Bold = iniTheme.ReadInteger("FontStyles", "DefinesBold", 0)
	ColorDefines.Italic = iniTheme.ReadInteger("FontStyles", "DefinesItalic", 0)
	ColorDefines.Underline = iniTheme.ReadInteger("FontStyles", "DefinesUnderline", 0)
	
	ColorFields.ForegroundOption = iniTheme.ReadInteger("Colors", "FieldsForeground", Identifiers.ForegroundOption)
	ColorFields.BackgroundOption = iniTheme.ReadInteger("Colors", "FieldsBackground", Identifiers.BackgroundOption)
	ColorFields.FrameOption = iniTheme.ReadInteger("Colors", "FieldsFrame", Identifiers.FrameOption)
	ColorFields.Bold = iniTheme.ReadInteger("FontStyles", "FieldsBold", 0)
	ColorFields.Italic = iniTheme.ReadInteger("FontStyles", "FieldsItalic", 0)
	ColorFields.Underline = iniTheme.ReadInteger("FontStyles", "FieldsUnderline", 0)
	
	ColorGlobalFunctions.ForegroundOption = iniTheme.ReadInteger("Colors", "GlobalFunctionsForeground", Identifiers.ForegroundOption)
	ColorGlobalFunctions.BackgroundOption = iniTheme.ReadInteger("Colors", "GlobalFunctionsBackground", Identifiers.BackgroundOption)
	ColorGlobalFunctions.FrameOption = iniTheme.ReadInteger("Colors", "GlobalFunctionsFrame", Identifiers.FrameOption)
	ColorGlobalFunctions.Bold = iniTheme.ReadInteger("FontStyles", "GlobalFunctionsBold", 0)
	ColorGlobalFunctions.Italic = iniTheme.ReadInteger("FontStyles", "GlobalFunctionsItalic", 0)
	ColorGlobalFunctions.Underline = iniTheme.ReadInteger("FontStyles", "GlobalFunctionsUnderline", 0)
	
	ColorEnumMembers.ForegroundOption = iniTheme.ReadInteger("Colors", "EnumMembersForeground", Identifiers.ForegroundOption)
	ColorEnumMembers.BackgroundOption = iniTheme.ReadInteger("Colors", "EnumMembersBackground", Identifiers.BackgroundOption)
	ColorEnumMembers.FrameOption = iniTheme.ReadInteger("Colors", "EnumMembersFrame", Identifiers.FrameOption)
	ColorEnumMembers.Bold = iniTheme.ReadInteger("FontStyles", "EnumMembersBold", 0)
	ColorEnumMembers.Italic = iniTheme.ReadInteger("FontStyles", "EnumMembersItalic", 0)
	ColorEnumMembers.Underline = iniTheme.ReadInteger("FontStyles", "EnumMembersUnderline", 0)
	
	ColorGlobalEnums.ForegroundOption = iniTheme.ReadInteger("Colors", "GlobalEnumsForeground", Identifiers.ForegroundOption)
	ColorGlobalEnums.BackgroundOption = iniTheme.ReadInteger("Colors", "GlobalEnumsBackground", Identifiers.BackgroundOption)
	ColorGlobalEnums.FrameOption = iniTheme.ReadInteger("Colors", "GlobalEnumsFrame", Identifiers.FrameOption)
	ColorGlobalEnums.Bold = iniTheme.ReadInteger("FontStyles", "GlobalEnumsBold", 0)
	ColorGlobalEnums.Italic = iniTheme.ReadInteger("FontStyles", "GlobalEnumsItalic", 0)
	ColorGlobalEnums.Underline = iniTheme.ReadInteger("FontStyles", "GlobalEnumsUnderline", 0)
	
	ColorLineLabels.ForegroundOption = iniTheme.ReadInteger("Colors", "LineLabelsForeground", Identifiers.ForegroundOption)
	ColorLineLabels.BackgroundOption = iniTheme.ReadInteger("Colors", "LineLabelsBackground", Identifiers.BackgroundOption)
	ColorLineLabels.FrameOption = iniTheme.ReadInteger("Colors", "LineLabelsFrame", Identifiers.FrameOption)
	ColorLineLabels.Bold = iniTheme.ReadInteger("FontStyles", "LineLabelsBold", 0)
	ColorLineLabels.Italic = iniTheme.ReadInteger("FontStyles", "LineLabelsItalic", 0)
	ColorLineLabels.Underline = iniTheme.ReadInteger("FontStyles", "LineLabelsUnderline", 0)
	
	ColorLocalVariables.ForegroundOption = iniTheme.ReadInteger("Colors", "LocalVariablesForeground", Identifiers.ForegroundOption)
	ColorLocalVariables.BackgroundOption = iniTheme.ReadInteger("Colors", "LocalVariablesBackground", Identifiers.BackgroundOption)
	ColorLocalVariables.FrameOption = iniTheme.ReadInteger("Colors", "LocalVariablesFrame", Identifiers.FrameOption)
	ColorLocalVariables.Bold = iniTheme.ReadInteger("FontStyles", "LocalVariablesBold", 0)
	ColorLocalVariables.Italic = iniTheme.ReadInteger("FontStyles", "LocalVariablesItalic", 0)
	ColorLocalVariables.Underline = iniTheme.ReadInteger("FontStyles", "LocalVariablesUnderline", 0)
	
	ColorMacros.ForegroundOption = iniTheme.ReadInteger("Colors", "MacrosForeground", Identifiers.ForegroundOption)
	ColorMacros.BackgroundOption = iniTheme.ReadInteger("Colors", "MacrosBackground", Identifiers.BackgroundOption)
	ColorMacros.FrameOption = iniTheme.ReadInteger("Colors", "MacrosFrame", Identifiers.FrameOption)
	ColorMacros.Bold = iniTheme.ReadInteger("FontStyles", "MacrosBold", 0)
	ColorMacros.Italic = iniTheme.ReadInteger("FontStyles", "MacrosItalic", 0)
	ColorMacros.Underline = iniTheme.ReadInteger("FontStyles", "MacrosUnderline", 0)
	
	ColorGlobalNamespaces.ForegroundOption = iniTheme.ReadInteger("Colors", "GlobalNamespacesForeground", Identifiers.ForegroundOption)
	ColorGlobalNamespaces.BackgroundOption = iniTheme.ReadInteger("Colors", "GlobalNamespacesBackground", Identifiers.BackgroundOption)
	ColorGlobalNamespaces.FrameOption = iniTheme.ReadInteger("Colors", "GlobalNamespacesFrame", Identifiers.FrameOption)
	ColorGlobalNamespaces.Bold = iniTheme.ReadInteger("FontStyles", "GlobalNamespacesBold", 0)
	ColorGlobalNamespaces.Italic = iniTheme.ReadInteger("FontStyles", "GlobalNamespacesItalic", 0)
	ColorGlobalNamespaces.Underline = iniTheme.ReadInteger("FontStyles", "GlobalNamespacesUnderline", 0)
	
	ColorProperties.ForegroundOption = iniTheme.ReadInteger("Colors", "PropertiesForeground", Identifiers.ForegroundOption)
	ColorProperties.BackgroundOption = iniTheme.ReadInteger("Colors", "PropertiesBackground", Identifiers.BackgroundOption)
	ColorProperties.FrameOption = iniTheme.ReadInteger("Colors", "PropertiesFrame", Identifiers.FrameOption)
	ColorProperties.Bold = iniTheme.ReadInteger("FontStyles", "PropertiesBold", 0)
	ColorProperties.Italic = iniTheme.ReadInteger("FontStyles", "PropertiesItalic", 0)
	ColorProperties.Underline = iniTheme.ReadInteger("FontStyles", "PropertiesUnderline", 0)
	
	ColorSharedVariables.ForegroundOption = iniTheme.ReadInteger("Colors", "SharedVariablesForeground", Identifiers.ForegroundOption)
	ColorSharedVariables.BackgroundOption = iniTheme.ReadInteger("Colors", "SharedVariablesBackground", Identifiers.BackgroundOption)
	ColorSharedVariables.FrameOption = iniTheme.ReadInteger("Colors", "SharedVariablesFrame", Identifiers.FrameOption)
	ColorSharedVariables.Bold = iniTheme.ReadInteger("FontStyles", "SharedVariablesBold", 0)
	ColorSharedVariables.Italic = iniTheme.ReadInteger("FontStyles", "SharedVariablesItalic", 0)
	ColorSharedVariables.Underline = iniTheme.ReadInteger("FontStyles", "SharedVariablesUnderline", 0)
	
	ColorSubs.ForegroundOption = iniTheme.ReadInteger("Colors", "SubsForeground", Identifiers.ForegroundOption)
	ColorSubs.BackgroundOption = iniTheme.ReadInteger("Colors", "SubsBackground", Identifiers.BackgroundOption)
	ColorSubs.FrameOption = iniTheme.ReadInteger("Colors", "SubsFrame", Identifiers.FrameOption)
	ColorSubs.Bold = iniTheme.ReadInteger("FontStyles", "SubsBold", 0)
	ColorSubs.Italic = iniTheme.ReadInteger("FontStyles", "SubsItalic", 0)
	ColorSubs.Underline = iniTheme.ReadInteger("FontStyles", "SubsUnderline", 0)
	
	ColorGlobalTypes.ForegroundOption = iniTheme.ReadInteger("Colors", "GlobalTypesForeground", Identifiers.ForegroundOption)
	ColorGlobalTypes.BackgroundOption = iniTheme.ReadInteger("Colors", "GlobalTypesBackground", Identifiers.BackgroundOption)
	ColorGlobalTypes.FrameOption = iniTheme.ReadInteger("Colors", "GlobalTypesFrame", Identifiers.FrameOption)
	ColorGlobalTypes.Bold = iniTheme.ReadInteger("FontStyles", "GlobalTypesBold", 0)
	ColorGlobalTypes.Italic = iniTheme.ReadInteger("FontStyles", "GlobalTypesItalic", 0)
	ColorGlobalTypes.Underline = iniTheme.ReadInteger("FontStyles", "GlobalTypesUnderline", 0)
	
	SetAutoColors
		If TabPanels.Count > 0 Then UpdateAllTabWindows
End Sub

Declare Sub UpdateWindowMenu()

Sub UpdateAllTabWindows
	Dim As TabWindow Ptr tb
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
				If tb <> 0 Then
						tb->txtCode.RefreshRenderTarget()
					tb->txtCode.PaintControl True
				End If
			Next
		Next
	UpdateWindowMenu
End Sub

Sub UpdateWindowMenu
	If miWindow = 0 Then Exit Sub
	Dim As TabWindow Ptr tb, tbActive
	Dim As MenuItem Ptr miWindowItem
	Dim As Integer itemCount = miWindow->Count
	For idx As Integer = itemCount - 1 To 0 Step -1
		miWindowItem = miWindow->Item(idx)
		If miWindowItem->Name = "WindowDoc" Then miWindow->Remove miWindowItem
	Next
	Var mainTabCode = ptabCode
	tbActive = Cast(TabWindow Ptr, mainTabCode->SelectedTab)
	For j As Integer = 0 To TabPanels.Count - 1
		Var tabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For k As Integer = 0 To tabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, tabCode->Tabs[k])
			If tb <> 0 Then
				miWindowItem = miWindow->Add(WGet(tb->FileName), "", "WindowDoc", @mClickWindow, True, , tb = tbActive)
				miWindowItem->Tag = tb
			End If
		Next
	Next
	mnuWindowSeparator->Visible = miWindow->Count > 0 '' only static item now is the separator itself (index 0); Split H/V moved to View (13.3.A)
End Sub


'' HotKeys.txt can legitimately contain the SAME KEY MORE THAN ONCE, because the Options dialog
'' writes one line per menu item keyed on that item's Name -- and menu item names are not unique.
'' The Tools menu alone produced four "Tools=" lines, three of them blank (the dynamically added
'' user tools), which shadowed the real "Tools=Ctrl+Shift+D" and left Ctrl+Shift+D dead: the
'' caption never got its "\t..." text, so no accelerator was ever registered (ROADMAP 13.33).
''
'' So: a later NON-EMPTY value fills in a key that is present but blank. A blank duplicate can no
'' longer shadow a real binding, whichever order they appear in. Blank is still honoured when it is
'' the only entry for a key -- that is a deliberately unassigned shortcut, and skipping blanks
'' outright would resurrect shortcuts a user had cleared, because HK() falls back to its code
'' default when a key is absent entirely.
Sub LoadHotKeys
	Dim As Integer Fn = FreeFile_, Pos1
	Dim As String Buff
	If Open(ExePath & "/Settings/Others/HotKeys.txt" For Input As #Fn) = 0 Then
		Dim As Boolean bFirstLine = True
		While Not EOF(Fn)
			Line Input #Fn, Buff
			'' Strip a UTF-8 BOM off the first line. The file is opened without an encoding, so a
			'' BOM arrives as three raw bytes and becomes part of the first KEY -- "New" was being
			'' stored as <BOM>New and silently never matched. It went unnoticed for as long as it
			'' did because HK() falls back to its code default, and that default happened to be the
			'' same Ctrl+N, so the shortcut worked while its configuration entry was dead.
			'' The shipped file is now BOM-less; this keeps existing user files working too.
			If bFirstLine Then
				If Len(Buff) >= 3 AndAlso Left(Buff, 3) = Chr(239) & Chr(187) & Chr(191) Then Buff = Mid(Buff, 4)
				bFirstLine = False
			End If
			Pos1 = InStr(Buff, "=")
			If Pos1 > 0 Then
				Dim As String hkKey = Left(Buff, Pos1 - 1)
				Dim As String hkValue = Mid(Buff, Pos1 + 1)
				Dim As DictionaryItem Ptr existing = HotKeys.Item(hkKey)
				If existing = 0 Then
					HotKeys.Add hkKey, hkValue
				ElseIf Trim(existing->Text) = "" AndAlso Trim(hkValue) <> "" Then
					existing->Text = hkValue
				End If
			End If
		Wend
	End If
	CloseFile_(Fn)
End Sub


'' Integrity check for the whole shortcut configuration (ROADMAP 13.35).
''
'' The point of this is that shortcut defects here have never been dispatch bugs -- they
'' have been bad DATA: a missing entry (13.32), blank duplicates shadowing a real binding
'' (13.33), and an accelerator quietly eating a menu mnemonic (Alt+C vs the Code menu).
'' Every one of those was found by driving the GUI by hand, which does not scale to 54
'' shortcuts and cannot be re-run cheaply. All three are decidable by reading the config,
'' so they are checked here instead, at every startup.
''
'' It writes Temp/_astoria_hotkeys.log ONLY when something is wrong, so the existence of
'' that file is the signal. A clean configuration leaves nothing behind. Nothing is shown
'' to the user and nothing is blocked: this is a developer/tester instrument, and a false
'' positive must never stop the IDE from starting.
'' Given a key combination, returns the caption of the top-level menu it would shadow, or "".
''
'' TranslateAccelerator runs BEFORE Windows resolves Alt+<letter> against the menu bar, so an
'' accelerator on Alt+<letter> silently stops that menu from opening. There is no error, and
'' nothing looks wrong in the menu itself -- Alt+C vs the "&Code" menu cost a morning of GUI
'' probing to find. Shared deliberately: ValidateHotKeys uses it to report existing damage, and
'' the Options dialog uses it to refuse to create any more (ROADMAP 13.35).
Function ShadowedMenuFor(ByRef Combo As String) As String
	Dim As String Wanted = UCase(Trim(Combo))
	If Left(Wanted, 4) <> "ALT+" Then Return ""
	'' Only a bare Alt+<single letter> collides. Ctrl+Alt+X and Shift+Alt+X do not reach the
	'' menu-bar mnemonic path at all, so they are legitimate bindings.
	If Len(Wanted) <> 5 Then Return ""
	Dim As String Letter = Mid(Wanted, 5, 1)
	If Letter < "A" OrElse Letter > "Z" Then Return ""
	For i As Integer = 0 To mnuMain.Count - 1
		Dim As MenuItem Ptr Top = mnuMain.Item(i)
		If Top = 0 Then Continue For
		Dim As String Caption = Top->Caption
		Dim As Integer pAmp = InStr(Caption, "&")
		If pAmp = 0 OrElse pAmp >= Len(Caption) Then Continue For
		If UCase(Mid(Caption, pAmp + 1, 1)) = Letter Then Return Replace(Caption, "&", "")
	Next
	Return ""
End Function


Sub ValidateHotKeys
	Dim As String ProblemText
	Dim As Integer nProblems = 0

	'' 1. Duplicate keys in the file. The loader tolerates these (a later non-empty value
	''    fills a blank one), but tolerating is not the same as being correct -- two lines
	''    for one command means something upstream is still generating them.
	Dim As Dictionary SeenKeys
	Dim As Integer Fn = FreeFile_
	If Open(ExePath & "/Settings/Others/HotKeys.txt" For Input As #Fn) = 0 Then
		Dim As String Buff
		While Not EOF(Fn)
			Line Input #Fn, Buff
			Dim As Integer pEq = InStr(Buff, "=")
			If pEq > 0 Then
				Dim As String hkKey = Trim(Left(Buff, pEq - 1))
				If hkKey <> "" Then
					If SeenKeys.Item(hkKey) <> 0 Then
						ProblemText &= "DUPLICATE KEY: '" & hkKey & "' appears more than once in HotKeys.txt" & Chr(13, 10)
						nProblems += 1
					Else
						SeenKeys.Add hkKey, "1"
					End If
				End If
			End If
		Wend
		CloseFile_(Fn)
	End If

	'' 2. One key combination bound to two different commands. Whichever accelerator
	''    Windows registers second is the one that never fires, and the loser fails
	''    silently -- exactly the symptom that is most expensive to diagnose by hand.
	Dim As Dictionary ComboOwner
	For i As Integer = 0 To HotKeys.Count - 1
		Dim As DictionaryItem Ptr hkItem = HotKeys.Item(i)
		If hkItem = 0 Then Continue For
		Dim As String Combo = UCase(Trim(hkItem->Text))
		If Combo = "" Then Continue For
		Dim As DictionaryItem Ptr Owner = ComboOwner.Item(Combo)
		If Owner <> 0 Then
			ProblemText &= "CONFLICT: '" & hkItem->Text & "' is bound to both '" & Owner->Text & "' and '" & hkItem->Key & "'" & Chr(13, 10)
			nProblems += 1
		Else
			ComboOwner.Add Combo, hkItem->Key
		End If
	Next

	'' 3. An accelerator that shadows a top-level menu mnemonic. TranslateAccelerator runs
	''    BEFORE Windows gets to resolve Alt+<letter> against the menu bar, so the menu
	''    simply stops opening -- with no error and nothing wrong in the menu itself.
	''    This is the check that catches Alt+C (CommandPrompt) vs the "&Code" menu.
	For i As Integer = 0 To HotKeys.Count - 1
		Dim As DictionaryItem Ptr hkItem = HotKeys.Item(i)
		If hkItem = 0 Then Continue For
		Dim As String Shadowed = ShadowedMenuFor(hkItem->Text)
		If Shadowed <> "" Then
			ProblemText &= "SHADOWED MENU: " & hkItem->Text & " opens the '" & Shadowed & "' menu, but is also bound to '" & hkItem->Key & "' -- the menu will not open" & Chr(13, 10)
			nProblems += 1
		End If
	Next

	If nProblems = 0 Then Exit Sub

	Dim As Integer FnLog = FreeFile_
	If Open(ExePath & "/Temp/_astoria_hotkeys.log" For Output As #FnLog) = 0 Then
		Print #FnLog, "Astoria shortcut configuration problems (" & Trim(Str(nProblems)) & ")"
		Print #FnLog, "Checked at startup by ValidateHotKeys -- see ROADMAP 13.35."
		Print #FnLog, ""
		Print #FnLog, ProblemText
		CloseFile_(FnLog)
	End If
End Sub


Sub StartProgress
	prProgress.Visible = True
End Sub

Sub StopProgress
	prProgress.Visible = False
End Sub

Dim As Double tWidth = Max(8, DefaultFont.Size) * 0.85
stBar.Align = DockStyle.alBottom
stBar.Add ("Press F1 for help"), tWidth * 25
stBar.Add("", tWidth * 50) 'Row +Col 
stBar.Add ("IntelliSense fully loaded"), tWidth * 27
stBar.Add "MCP Agent: Off", tWidth * 17     '' repurposed from the (always-UTF-8) encoding readout; set live by UpdateMcpAgentStatusBar
stBar.Add "CR+LF", tWidth * 6
stBar.Add "NUM", tWidth * 4
stBar.Panels[0]->Width = Max(stBar.Width - 50 - stBar.Panels[1]->Width - stBar.Panels[2]->Width - stBar.Panels[3]->Width  - stBar.Panels[4]->Width - stBar.Panels[5]->Width, 20)
Var spProgress = stBar.Add("")
spProgress->Width = stBar.Panels[2]->Width + 3
prProgress.Width = stBar.Panels[2]->Width + 3
prProgress.Visible = False
prProgress.Marquee = True

	prProgress.SetMarquee True, 100
	prProgress.Top = 3
	prProgress.Parent = @stBar

'stBar.Add ""
'stBar.Panels[1]->Alignment = 1

Sub GDBCommand
	fTheme.Text = ("GDB Command")
	fTheme.lblThemeName.Text = ("Type command:")
	If fTheme.ShowModal(frmMain) = ModalResults.OK Then
		'ShowResult = True
			command_debug fTheme.txtThemeName.Text
	End If
End Sub

'' Push the current DisplayMenuIcons setting onto the already-built menu, so the Options
'' checkbox takes effect immediately instead of only on the next start.
''
'' MenuItem has no "refresh" entry point, so each item is nudged through a property that
'' writes MIIM_BITMAP straight to the OS: re-assigning ImageKey re-resolves the index and
'' pushes the bitmap (icons on), while assigning a blank bitmap pushes hbmpItem = 0 (off).
'' Items keep FImageKey either way, so this is reversible any number of times.
Sub ApplyMenuIconsToItems(Item As MenuItem Ptr)
	If Item = 0 Then Exit Sub
	For i As Integer = 0 To Item->Count - 1
		Dim As MenuItem Ptr Child = Item->Item(i)
		If Child Then
			If DisplayMenuIcons Then
				If Child->ImageKey <> "" Then Child->ImageKey = Child->ImageKey
			Else
				Dim As My.Sys.Drawing.BitmapType NoImage
				Child->Image = NoImage
			End If
			If Child->Count > 0 Then ApplyMenuIconsToItems(Child)
		End If
	Next
End Sub

Sub ApplyMenuIcons
	If BisectSkip("menuicons") Then Exit Sub   '' 13.28 pt 3 bisection -- TEMPORARY
	mnuMain.ImagesList = @imgList
	mnuMain.DisplayIcons = DisplayMenuIcons
	For i As Integer = 0 To mnuMain.Count - 1
		Dim As MenuItem Ptr Top = mnuMain.Item(i)
		If Top Then
			If DisplayMenuIcons Then
				If Top->ImageKey <> "" Then Top->ImageKey = Top->ImageKey
			Else
				Dim As My.Sys.Drawing.BitmapType NoImage
				Top->Image = NoImage
			End If
			ApplyMenuIconsToItems(Top)
		End If
	Next
	If frmMain.Handle Then DrawMenuBar(frmMain.Handle)
End Sub

Sub CreateMenusAndToolBars
	pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Create Menus And ToolBars")
	imgList.Name = "imgList"
	imgList.Add "StartWithCompile", "StartWithCompile"
	imgList.Add "Start", "Start"
	imgList.Add "Break", "Break"
	imgList.Add "EndProgram", "EndProgram"
	imgList.Add "New", "New"
	imgList.Add "Open", "Open"
	imgList.Add "Save", "Save"
	imgList.Add "SaveAll", "SaveAll"
	imgList.Add "Close", "Close"
	imgList.Add "Exit", "Exit"
	imgList.Add "Undo", "Undo"
	imgList.Add "Redo", "Redo"
	imgList.Add "Cut", "Cut"
	imgList.Add "Copy", "Copy"
	imgList.Add "Paste", "Paste"
	imgList.Add "Find", "Find"
	imgList.Add "Code", "Code"
	imgList.Add "CompleteWord", "CompleteWord"
	imgList.Add "Console", "Console"
	imgList.Add "Form", "Form"
	imgList.Add "MainForm", "MainForm"
	imgList.Add "Format", "Format"
	imgList.Add "Unformat", "Unformat"
	imgList.Add "CodeAndForm", "CodeAndForm"
	imgList.Add "SyntaxCheck", "SyntaxCheck"
	imgList.Add "UseDebugger", "UseDebugger"
	imgList.Add "Compile", "Compile"
	imgList.Add "Make", "Make"
	imgList.Add "Book", "Book"
	imgList.Add "About", "About"
	imgList.Add "Session", "Session"
	imgList.Add "File", "File"
	imgList.Add "MainFile", "MainFile"
	imgList.Add "Resource", "Resource"
	imgList.Add "MainResource", "MainResource"
	imgList.Add "Module", "Module"
	imgList.Add "MainModule", "MainModule"
	imgList.Add "NotSetted", "NotSetted"
	imgList.Add "UserControl", "UserControl"
	imgList.Add "Eraser", "Eraser"
	imgList.Add "Pin", "Pin"
	imgList.Add "Pinned", "Pinned"
	imgList.Add "ParameterInfo", "ParameterInfo"
	imgList.Add "Parameters", "Parameters"
	imgList.Add "Folder", "Folder"
	imgList.Add "MainProject", "MainProject"
	imgList.Add "Project", "Project"
	imgList.Add "Apply", "Apply"
	imgList.Add "Add", "Add"
	imgList.Add "Remove", "Remove"
	imgList.Add "Error", "Error"
	imgList.Add "Warning", "Warning"
	imgList.Add "Info", "Info"
	imgList.Add "Label", "Label"
	imgList.Add "Component", "Component"
	imgList.Add "Property", "Property"
	imgList.Add "Sub", "Sub"
	imgList.Add "Bookmark", "Bookmark"
	imgList.Add "Breakpoint", "Breakpoint"
	imgList.Add "Opened", "Opened"
	imgList.Add "Tools", "Tools"
	imgList.Add "StandartTypes", "StandartTypes"
	imgList.Add "Enum", "Enum"
	imgList.Add "Type", "Type"
	imgList.Add "Function", "Function"
	imgList.Add "Event", "Event"
	imgList.Add "Collapsed", "Collapsed"
	imgList.Add "Categorized", "Categorized"
	imgList.Add "Comment", "Comment"
	imgList.Add "UnComment", "UnComment"
	imgList.Add "Print", "Print"
	imgList.Add "PrintPreview", "PrintPreview"
	imgList.Add "FileError", "FileError"
	imgList.Add "Up", "Up"
	imgList.Add "Down", "Down"
	imgList.Add "Sort", "Sort"
	imgList.Add "EnumItem", "EnumItem"
	imgList.Add "Update", "Update"
	imgList.Add "Forum", "Forum"
	imgList.Add "Fixme", "Fixme"
	imgList.Add "Suggestions", "Suggestions"
	imgList.Add "FindSymbol", "FindSymbol"
	imgList.Add "NewChat", "NewChat"
	imgList.Add "AddComment", "AddComment"
	imgList.Add "TracepointError", "TracepointError"
	imgList.Add "Intellicode", "Intellicode"
	imgList.Add "OptimizeCode", "OptimizeCode"
	imgList.Add "ConvertC", "ConvertC"
	imgList.Add "Translate", "Translate"
	imgList.Add "TranslateE", "TranslateE"
	imgList.Add "WebBrowserItem", "WebBrowserItem"
	imgList.Add "AlignLefts", "AlignLefts"
	imgList.Add "AlignCenters", "AlignCenters"
	imgList.Add "AlignRights", "AlignRights"
	imgList.Add "AlignTops", "AlignTops"
	imgList.Add "AlignMiddles", "AlignMiddles"
	imgList.Add "AlignBottoms", "AlignBottoms"
	imgList.Add "AlignToGrid", "AlignToGrid"
	imgList.Add "MakeSameSizeWidth", "MakeSameSizeWidth"
	imgList.Add "MakeSameSizeHeight", "MakeSameSizeHeight"
	imgList.Add "MakeSameSizeBoth", "MakeSameSizeBoth"
	imgList.Add "SizeToGrid", "SizeToGrid"
	imgList.Add "HorizontalSpacingMakeEqual", "HorizontalSpacingMakeEqual"
	imgList.Add "HorizontalSpacingIncrease", "HorizontalSpacingIncrease"
	imgList.Add "HorizontalSpacingDecrease", "HorizontalSpacingDecrease"
	imgList.Add "HorizontalSpacingRemove", "HorizontalSpacingRemove"
	imgList.Add "VerticalSpacingMakeEqual", "VerticalSpacingMakeEqual"
	imgList.Add "VerticalSpacingIncrease", "VerticalSpacingIncrease"
	imgList.Add "VerticalSpacingDecrease", "VerticalSpacingDecrease"
	imgList.Add "VerticalSpacingRemove", "VerticalSpacingRemove"
	imgList.Add "CenterInParentHorizontally", "CenterInParentHorizontally"
	imgList.Add "CenterInParentVertically", "CenterInParentVertically"
	imgList.Add "BringToFront", "BringToFront"
	imgList.Add "SendToBack", "SendToBack"
	imgList.Add "LockControls", "LockControls"
	imgList.Add "StepInto", "StepInto"
	imgList.Add "StepOver", "StepOver"
	imgList.Add "StepOut", "StepOut"
	imgList.Add "RunToCursor", "RunToCursor"
	imgList.Add "SetNextStatement", "SetNextStatement"
	imgList.Add "ShowNextStatement", "ShowNextStatement"
	
	'imgListD.Add "StartWithCompileD", "StartWithCompile"
	'imgListD.Add "StartD", "Start"
	'imgListD.Add "BreakD", "Break"
	'imgListD.Add "EndD", "EndProgram"
	imgList32.Name = "imgList32"
	imgList32.ImageWidth = 32
	imgList32.ImageHeight = 32
	imgList32.Add "AppWindows", "AppWindows"
	imgList32.Add "AppAddin", "AppAddin"
	imgList32.Add "AppControl", "AppControl"
	imgList32.Add "AppConsole", "AppConsole"
	imgList32.Add "AppGUI", "AppGUI"
	imgList32.Add "AppDynamic", "AppDynamic"
	imgList32.Add "AppStatic", "AppStatic"
	imgList32.Add "AppEmpty", "AppEmpty"
	imgList32.Add "File32", "File32"
	imgList32.Add "Resource32", "Resource32"
	imgList32.Add "Module32", "Module32"
	imgList32.Add "UserControl32", "UserControl32"
	imgList32.Add "Form32", "Form32"
	imgList32.Add "Form3D32", "Form3D32"
	'imgList32.Add "FormRC", "FormRC"
	imgList32.Add "Manifest32", "Manifest32"
	
	'mnuMain.ImagesList = @imgList
	pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Load Hot Keys")
	LoadHotKeys
	'' 13.28 pt 3 bisection -- TEMPORARY. Inserts one dummy item BEFORE File, pushing every real
	'' menu index down by one. If Alt+C then works with Code at index 4 instead of 3, position
	'' relative to the menu-bar start is the mechanism.
	If BisectSkip("shiftindices") Then
		Dim miShim As MenuItem Ptr = mnuMain.Add(("Sh&im"), "", "Shim")
		miShim->Add("shim item", "", "ShimItem")
	End If
	Var miFile = mnuMain.Add(("&File"), "", "File")
	miFile->Add(("&New Project") & HK("NewProject", "Ctrl+Shift+N"), "Project", "NewProject", @mClick)
	'' The accelerator comes from the caption -- HK() appends "\tCtrl+Shift+O", which is what
	'' TranslateAccelerator matches on. This line had no HK() at all, so Ctrl+Shift+O was listed in
	'' Tools > Options > Shortcuts and could never fire (ROADMAP 13.32).
	miFile->Add(("&Open Project") & "..." & HK("OpenProject", "Ctrl+Shift+O"), "", "OpenProject", @mClick)
	miFile->Add(("&Recent Projects") & "...", "", "RecentProject", @mClick)
	miCloseProject = miFile->Add(("Close Project") & HK("CloseProject", "Ctrl+Shift+F4"), "", "CloseProject", @mClick, , , False)
	miFile->Add("-")
	miSaveProject = miFile->Add(("Save Project") & "..." & HK("SaveProject", "Ctrl+Shift+S"), "SaveAll", "SaveProject", @mClick, , , False)
	miSaveProjectAs = miFile->Add(("Save Project As") & "..." & HK("SaveProjectAs"), "", "SaveProjectAs", @mClick, , , False)
	miFile->Add("-")
	miNewFile = miFile->Add(("&New File") & HK("NewFile", "Ctrl+N"), "New", "NewFile", @mClick)
	miOpenFile = miFile->Add(("&Open File") & "..." & HK("OpenFile", "Ctrl+O"), "Open", "OpenFile", @mClick)
	miCloseFile = miFile->Add(("Close File") & HK("CloseFile", "Ctrl+F4"), "Close", "CloseFile", @mClick, , , False)
	miFile->Add("-")
	miSaveFile = miFile->Add(("Save File") & "..." & HK("SaveFile", "Ctrl+S"), "Save", "SaveFile", @mClick, , , False)
	miSaveFileAs = miFile->Add(("Save File &As") & "..." & HK("SaveFileAs"), "", "SaveFileAs", @mClick, , , False)
	miFile->Add("-")
	miPrint = miFile->Add(("&Print") & HK("Print", "Ctrl+P"), "Print", "Print", @mClick, , , False)

	Dim sTmp As WString * 1024
	For i As Integer = 0 To miRecentMax
		sTmp = SanitizeIniOptionalPath(iniSettings.ReadString("MRUProjects", "MRUProject_0" & WStr(i), ""))
		If Trim(sTmp) <> "" Then MRUProjects.Add sTmp
	Next
	For i As Integer = 0 To miRecentMax
		sTmp = SanitizeIniOptionalPath(iniSettings.ReadString("MRUFolders", "MRUFolder_0" & WStr(i), ""))
		If Trim(sTmp) <> "" Then MRUFolders.Add sTmp
	Next

	miRecentFiles = miFile->Add(("Recent Files"), "", "RecentFilesMRU", @mClick)
	For i As Integer = 0 To miRecentMax
		sTmp = SanitizeIniOptionalPath(iniSettings.ReadString("MRUFiles", "MRUFile_0" & WStr(i), ""))
		If Trim(sTmp) <> "" Then MRUFiles.Add sTmp
	Next
	SanitizeMRUListsOnLoad()
	'' B3: was stuck Visible = False here forever (never restored elsewhere) and never
	'' populated from the just-loaded INI list -- the whole feature was inaccessible until
	'' AddMRUFile happened to run later in the session (e.g. opening a file), at which point
	'' it worked correctly but only because AddMRU rebuilds unconditionally, not because
	'' anything here had shown it. Populate + enable/disable immediately instead.
	RebuildMRUMenu MRUFiles, miRecentFiles, "Files"

	miFile->Add("-")
	'' 13.3.A S5: Delete Project/Delete File regrouped into their own bracketed group, well away
	'' from Close Project/Close File (safety -- a misclick on Delete is destructive, on Close is not).
	miDeleteProject = miFile->Add(("Delete Project"), "", "DeleteProject", @mClick, , , False)
	miDeleteFile = miFile->Add(("Delete File"), "", "DeleteFile", @mClick, , , False)
	miFile->Add("-")
	Var miFileAdvanced = miFile->Add(("Advanced"), "", "FileAdvanced")
	miPrintPreview = miFileAdvanced->Add(("Print P&review") & HK("PrintPreview"), "PrintPreview", "PrintPreview", @mClick, , , False)
	miPageSetup = miFileAdvanced->Add(("Page Set&up") & "..." & HK("PageSetup"), "", "PageSetup", @mClick, , , False)
	miFile->Add("-")
	miFile->Add(("&Exit") & HK("Exit", "Alt+F4"), "Exit", "Exit", @mClick)
	
	Var miView = mnuMain.Add(("&View"), "", "View")
	miCode = miView->Add(("Code") & HK("Code", "Ctrl+F7"), "Code", "Code", @mClick, , , False)
	miForm = miView->Add(("Form") & HK("Form", "Shift+F7"), "Form", "Form", @mClick, , , False)
	miCodeAndForm = miView->Add(("Code And Form") & HK("CodeAndForm", "Ctrl+Shift+F7"), "CodeAndForm", "CodeAndForm", @mClick, , , False)
	miView->Add("-")
	miGotoCodeForm = miView->Add(("Switch Form/Code") & HK("GotoCodeForm", "F7"), "GotoCodeForm", "GotoCodeForm", @mClick, , , False)
	miView->Add("-")
	miView->Add(("Project Explorer") & HK("ProjectExplorer", "Ctrl+R"), "Project", "ProjectExplorer", @mClick)
	miView->Add(("Properties Window") & HK("PropertiesWindow", "F4"), "Property", "PropertiesWindow", @mClick)
	miView->Add(("Events Window") & HK("EventsWindow", "Ctrl+E"), "Event", "EventsWindow", @mClick)
	miView->Add(("Toolbox") & HK("Toolbox", "Ctrl+T"), "Tools", "Toolbox", @mClick)
	Var miOtherWindows = miView->Add(("Other Windows"))
	miOtherWindows->Add(("Output Window") & HK("OutputWindow"), "", "OutputWindow", @mClick)
	miOtherWindows->Add(("Problems Window") & HK("ProblemsWindow"), "", "ProblemsWindow", @mClick)
	miOtherWindows->Add(("Suggestions Window") & HK("SuggestionsWindow"), "", "SuggestionsWindow", @mClick)
	miOtherWindows->Add(("Find Window") & HK("FindWindow"), "", "FindWindow", @mClick)
	miOtherWindows->Add(("ToDo Window") & HK("ToDoWindow"), "", "ToDoWindow", @mClick)
	miOtherWindows->Add(("Change Log Window") & HK("ChangeLogWindow"), "", "ChangeLogWindow", @mClick)
	miOtherWindows->Add(("Immediate Window") & HK("ImmediateWindow"), "", "ImmediateWindow", @mClick)
	miDebugWindows = miView->Add(("Debug Windows"))
	miDebugWindows->Add(("Locals Window") & HK("LocalsWindow"), "", "LocalsWindow", @mClick)
	miDebugWindows->Add(("Globals Window") & HK("GlobalsWindow"), "", "GlobalsWindow", @mClick)
	'miDebugWindows->Add(ML("Procedures Window") & HK("ProceduresWindow"), "", "ProceduresWindow", @mclick)
	miDebugWindows->Add(("Threads Window") & HK("ThreadsWindow"), "", "ThreadsWindow", @mClick)
	miDebugWindows->Add(("Watch Window") & HK("WatchWindow"), "", "WatchWindow", @mClick)
	miView->Add("-")
	miImageManager = miView->Add(("Image Manager") & HK("ImageManager"), "", "ImageManager", @mClick, , , False)
	miView->Add("-")
	'' One checkable item, not a submenu of five. The toolbars are shown together or not at all --
	'' picking individual ones left a user with a half-populated bar and no obvious way back, and
	'' the row layout below is fixed anyway, so per-toolbar choice bought nothing.
	miToolBars = miView->Add(("Toolbars") & HK("Toolbars"), "", "Toolbars", @mClick, True)
	
	Var miProject = mnuMain.Add(("&Project"), "", "Project")
	miProject->Add(("Add &Form") & HK("AddForm", "Ctrl+Alt+N"), "Form", "AddForm", @mClick)
	miProject->Add(("Add &Module") & HK("AddModule","Ctrl+Alt+M"), "Module", "AddModule", @mClick)
	miProject->Add(("Add &Include File") & HK("AddIncludeFile",""), "File", "AddIncludeFile", @mClick)
	miProject->Add(("Add From Templates") & "..." & HK("AddFromTemplates"), "Add", "AddFromTemplates", @mClick)
	miProject->Add(("Add Files") & "..." & HK("AddFilesToProject"), "Add", "AddFilesToProject", @mClick)
	miProject->Add("-")
	Var miProjectAdvanced = miProject->Add(("Advanced"), "", "ProjectAdvanced")
	miProjectAdvanced->Add(("Add &User Control") & HK("AddUserControl", "Ctrl+Alt+U"), "UserControl", "AddUserControl", @mClick)
	miProjectAdvanced->Add(("Add &Resource File") & HK("AddResoureFile",""), "Resource", "AddResourceFile", @mClick)
	miProjectAdvanced->Add(("Add Ma&nifest File") & HK("AddManifestFile",""), "File", "AddManifestFile", @mClick)
	miProject->Add("-")
	miRename = miProject->Add(("R&ename") & HK("Rename"), "Rename", "Rename", @mClick, , , False)
	miRemoveFileFromProject = miProject->Add(("&Delete File"), "Remove", "DeleteFile", @mClick, , , False)
	miProject->Add("-")
	miOpenProjectFolder = miProject->Add(("&Open Project Folder") & HK("OpenProjectFolder"), "", "OpenProjectFolder", @mClick, , , False)
	miProject->Add(("Import from Folder") & "..." & HK("OpenFolder", "Alt+O"), "", "OpenFolder", @mClick)
	miProject->Add("-")
	miProjectProperties = miProject->Add(("&Project Properties") & "..." & HK("ProjectProperties"), "", "ProjectProperties", @mClick, , , False)
	miEditProjectDescription = miProject->Add(("Edit Project Description") & HK("EditProjectDescription"), "", "EditProjectDescription", @mClick, , , False)

	'' Mnemonic is Co&de (Alt+D), not &Code (Alt+C), as a workaround for ROADMAP 13.28 pt 3 --
	'' the letters C, G and R are silently swallowed by menu-mode search here (and in upstream
	'' VisualFBEditor), for reasons still unknown. Revert to "&Code" when that defect is fixed.
	Var miEdit = mnuMain.Add(("Co&de"), "", "Tahrir")
	miCodeMenu = miEdit ' shared pointer so UpdateCodeFormMenuEnabled can grey the whole menu contextually
	miCutCurrentLine = miEdit->Add(("C&ut Current Line") & HK("CutCurrentLine", "Ctrl+Y"), "", "CutCurrentLine", @mClick, , , False)
	miEdit->Add("-")
	miSingleComment = miEdit->Add(("&Toggle Comment") & HK("SingleComment", "Ctrl+I"), "Comment", "SingleComment", @mClick, , , False)
	miEdit->Add("-")
	miIndent = miEdit->Add(("&Indent") & HK("Indent", "Tab"), "", "Indent", @mClick, , , False)
	miOutdent = miEdit->Add(("&Outdent") & HK("Outdent", "Shift+Tab"), "", "Outdent", @mClick, , , False)
	miEdit->Add("-")
	'' Ctrl+Tab is the Windows standard for switching documents, not for formatting -- binding
	'' it here fought the tab control and surprised every tester. Ctrl+K/Ctrl+Shift+K instead.
	'' Not Shift+Alt+F (VS Code's) despite being the better-known formatting chord: Alt+letter
	'' bindings are the one class proven fragile here (Alt+C shadowed a menu; Alt+R and Alt+G
	'' fail for reasons still unknown), and reliability outranks conformance. See ROADMAP 13.28.
	miFormat = miEdit->Add(("&Format") & HK("Format", "Ctrl+K"), "Format", "Format", @mClick, , , False)
	miEdit->Add("-")
	Var miEditAdvanced = miEdit->Add(("Advanced"), "", "EditAdvanced")
	miUnformat = miEditAdvanced->Add(("&Unformat") & HK("Unformat", "Ctrl+Shift+K"), "Unformat", "Unformat", @mClick, , , False)
	miFormatProject = miEditAdvanced->Add(("&Format Project") & HK("FormatProject"), "", "FormatProject", @mClick, , , False)
	miUnformatProject = miEditAdvanced->Add(("&Unformat Project") & HK("UnformatProject"), "", "UnformatProject", @mClick, , , False)
	miAddSpaces = miEditAdvanced->Add(("Add &Spaces") & HK("AddSpaces"), "", "AddSpaces", @mClick, , , False)
	miDeleteBlankLines = miEditAdvanced->Add(("Merge Multiple Blank Lines"), "", "DeleteBlankLines", @mClick)
	miEdit->Add("-")
	'' C2: Bubble Help / Suggest Options were on/off settings, not edit actions -- moved to
	'' Options > Code Editor (chkShowSymbolsTooltipsOnMouseHover / chkEnableAutoComplete, which
	'' already existed there and were already wired). Parameter Info keeps a menu entry because
	'' its caption carries the Ctrl+J accelerator -- the framework's accelerator table is built
	'' by scanning menu captions (Menus.bas ~1538), so removing the item would silently kill the
	'' shortcut -- but it's no longer a toggle: it always invokes now (same as the toolbar
	'' button), with the on/off "auto-show" setting moved to its own new Options checkbox.
	miParameterInfo = miEdit->Add(("Code - Parameter Info") & HK("ParameterInfo", "Ctrl+J"), "", "InvokeParameterInfo", @mClick)
	miEdit->Add("-")
	miAddProcedure = miEdit->Add(("Add &Procedure") & "..." & HK("AddProcedure"), "", "AddProcedure", @mClick, , , False)
	miAddType = miEdit->Add(("Add &Type") & "..." & HK("AddType"), "", "AddType", @mClick, , , False)
	miEdit->Add("-")
	' Remaining code-pane commands (parity with the code-pane right-click menu). Plain
	' captions - no accelerator text - so these don't double-register in the accelerator
	' table (the shortcuts they duplicate are already carried by the original items above,
	' the Run menu, or the folded-in Search submenu).
	miEdit->Add(("Complete &Word"), "CompleteWord", "CompleteWord", @mClick)
	miEdit->Add(("S&yntax Check"), "SyntaxCheck", "SyntaxCheck", @mClick)
	miEdit->Add(("Su&ggestions"), "", "AnalyzeSuggestions", @mClick)
	miEdit->Add("-")
	Var miCodeConvert = miEdit->Add(("Con&vert"), "", "CodeConvert")
	miCodeConvert->Add(("to Lowercase"), "", "ConvertToLowercase", @mClick)
	miCodeConvert->Add(("to Uppercase"), "", "ConvertToUppercase", @mClick)
	miCodeConvert->Add(("Capitalize First Letter"), "", "ConvertToUppercaseFirstLetter", @mClick)
	miCodeConvert->Add("-")
	miCodeConvert->Add(("to Unicode Hex String"), "", "ConvertToHexStrUnicode", @mClick)
	miCodeConvert->Add(("from Unicode Hex String"), "", "ConvertFromHexStrUnicode", @mClick)
	Var miCodeLines = miEdit->Add(("&Lines"), "", "CodeLines")
	miCodeLines->Add(("Split Lines"), "", "SplitLines", @mClick)
	miCodeLines->Add(("Combine Lines"), "", "CombineLines", @mClick)
	miCodeLines->Add(("Sort Lines"), "", "SortLines", @mClick)
	miCodeLines->Add(("Format With Basis Word"), "", "FormatWithBasisWord", @mClick)
	miEdit->Add("-")
	' Split views and code folding (moved from the View menu - code-pane specific).
	mnuSplitHorizontally = miEdit->Add(("Split &Horizontally") & HK("SplitHorizontally"), "", "SplitHorizontally", @mClick, True, , False)
	mnuSplitVertically = miEdit->Add(("Split &Vertically") & HK("SplitVertically"), "", "SplitVertically", @mClick, True, , False)
	miFold = miEdit->Add(("Fold"), "", "Fold")
	miCollapseAll = miFold->Add(("Collapse All") & HK("CollapseAll"), "", "CollapseAll", @mClick, , , False)
	miUnCollapseAll = miFold->Add(("Expand All") & HK("UnCollapseAll"), "", "UnCollapseAll", @mClick, , , False)
	miFold->Add("-")
	Var miFoldAdvanced = miFold->Add(("Advanced"), "", "FoldAdvanced")
	miCollapseCurrent = miFoldAdvanced->Add(("Collapse Current") & HK("CollapseCurrent"), "", "CollapseCurrent", @mClick, , , False)
	miCollapseAllProcedures = miFoldAdvanced->Add(("Collapse All Procedures") & HK("CollapseAllProcedures"), "", "CollapseAllProcedures", @mClick, , , False)
	miUnCollapseCurrent = miFoldAdvanced->Add(("Expand Current") & HK("UnCollapseCurrent"), "", "UnCollapseCurrent", @mClick, , , False)
	miUnCollapseAllProcedures = miFoldAdvanced->Add(("Expand All Procedures") & HK("UnCollapseAllProcedures"), "", "UnCollapseAllProcedures", @mClick, , , False)
	miEdit->Add("-")
	' Search folded in as a Code submenu (it deals only with code): removed as a top-level
	' menu, re-parented here so all code operations live under one menu.
	Var miSearch = miEdit->Add(("&Search"), "", "Search")
	miFind = miSearch->Add(("&Find") & "..." & HK("Find", "Ctrl+F"), "Find", "Find", @mClick, , , False)
	miReplace = miSearch->Add(("&Replace") & "..."  & HK("Replace", "Ctrl+H"), "", "Replace", @mClick, , , False)
	miFindNext = miSearch->Add(("Find &Next") & HK("FindNext", "F3"), "", "FindNext", @mClick, , , False)
	miFindPrevious = miSearch->Add(("Find &Previous") & HK("FindPrev", "Shift+F3"), "", "FindPrev", @mClick, , , False)
	miSearch->Add("-")
	miSearch->Add(("Find In Files") & "..." & HK("FindInFiles", "Ctrl+Shift+F"), "", "FindInFiles", @mClick)
	miSearch->Add(("Replace In Files") & "..." & HK("ReplaceInFiles", "Ctrl+Shift+H"), "", "ReplaceInFiles", @mClick)
	miSearch->Add("-")
	miGoto = miSearch->Add(("&Goto") & HK("Goto", "Ctrl+G"), "", "Goto", @mClick, , , False)
	miSearch->Add("-")
	miDefine = miSearch->Add(("Go to &Definition") & HK("Define", "F2"), "", "Define", @mClick, , , False)
	Var miBookmark = miSearch->Add(("Bookmarks"), "", "Bookmarks")
	miToggleBookmark = miBookmark->Add(("Toggle Bookmark") & HK("ToggleBookmark", "F6"), "Bookmark", "ToggleBookmark", @mClick, , , False)
	miNextBookmark = miBookmark->Add(("Next Bookmark") & HK("NextBookmark", "Ctrl+F6"), "", "NextBookmark", @mClick, , , False)
	miPreviousBookmark = miBookmark->Add(("Previous Bookmark") & HK("PreviousBookmark", "Ctrl+Shift+F6"), "", "PreviousBookmark", @mClick, , , False)
	miClearAllBookmarks = miBookmark->Add(("Clear All Bookmarks") & HK("ClearAllBookmarks"), "", "ClearAllBookmarks", @mClick, , , False)
	
	'' Commands that apply in BOTH the code editor and the form designer. They live in their own
	'' top-level menu because Code and Form are greyed contextually, and a greyed top-level menu
	'' silently disables every keyboard shortcut inside it -- Windows' TranslateAccelerator
	'' consumes an accelerator whose parent menu is disabled and sends no WM_COMMAND. Undo used to
	'' sit in the Code menu, so Ctrl+Z did nothing whatsoever on the design surface.
	''
	'' This menu is therefore NEVER greyed. Its individual items still enable/disable themselves
	'' in ChangeMenuItemsEnabled, and mClick routes each one to the editor or the designer
	'' depending on what has focus.
	'' 13.28 pt 3 bisection -- TEMPORARY. The base caption is the one Astoria always shipped.
	'' With ASTORIA_BISECT=fixodditems the mnemonic-less item and the disabled duplicate-Alt+F
	'' are given proper unique mnemonics, so we can measure whether either oddity is what tells
	'' Windows' mnemonic search to swallow C/G/R.
	'' Under the fixodditems gate we give Code/Form a mnemonic. Was Alt+D, changed to Alt+E to
	'' avoid clashing with the workaround Alt+D on the real Code menu (13.28 pt 3 workaround).
	Dim cfCap As String = IIf(BisectSkip("fixodditems"), ("Cod&eForm"), ("Code/Form"))
	miCodeFormMenu = mnuMain.Add(cfCap, "", "CodeForm")
	miUndo = miCodeFormMenu->Add(("Undo") & HK("Undo", "Ctrl+Z"), "Undo", "Undo", @mClick, , , False)
	miRedo = miCodeFormMenu->Add(("Redo") & HK("Redo", "Ctrl+Shift+Z"), "Redo", "Redo", @mClick, , , False)
	miCodeFormMenu->Add("-")
	miCut = miCodeFormMenu->Add(("Cu&t") & HK("Cut", "Ctrl+X"), "Cut", "Cut", @mClick, , , False)
	miCopy = miCodeFormMenu->Add(("&Copy") & HK("Copy", "Ctrl+C"), "Copy", "Copy", @mClick, , , False)
	miPaste = miCodeFormMenu->Add(("&Paste") & HK("Paste", "Ctrl+V"), "Paste", "Paste", @mClick, , , False)
	miCodeFormMenu->Add("-")
	miDuplicate = miCodeFormMenu->Add(("&Duplicate") & HK("Duplicate", "Ctrl+D"), "", "Duplicate", @mClick, , , False)
	miSelectAll = miCodeFormMenu->Add(("Select &All") & HK("SelectAll", "Ctrl+A"), "", "SelectAll", @mClick, , , False)

	'' 13.28 pt 3 bisection -- TEMPORARY. Change "&Form" to "For&m" under the gate to remove the
	'' duplicate Alt+F it shares with &File. Alt+M is not otherwise claimed.
	Dim ffCap As String = IIf(BisectSkip("fixodditems"), ("For&m"), ("&Form"))
	miFormFormat = mnuMain.Add(ffCap, "", "FormFormat")
	miFormFormat->Enabled = False ' D1: no form open at startup; enabled by tabCode_SelChange/ApplyFormTabView when a form with controls is active
	' Control-edit ops (parity with the form-pane right-click menu). @PopupClick acts on
	' the active designer's selection unconditionally; plain captions (no accelerator text)
	' so the clipboard shortcuts stay owned by the Code menu.
	miFormFormat->Add(("Default &Event"), "Code", "Default", @PopupClick)
	miFormFormat->Add("-")
	miFormFormat->Add(("Delete"), "", "Delete", @PopupClick)
	miFormFormat->Add("-")
	Var miAlign = miFormFormat->Add(("&Align"), "Align", "Align", @mClick)
	miAlignLefts = miAlign->Add(("&Lefts") & HK("AlignLefts"), "AlignLefts", "AlignLefts", @mClick)
	miAlignCenters = miAlign->Add(("&Centers") & HK("AlignLefts"), "AlignCenters", "AlignCenters", @mClick)
	miAlignRights = miAlign->Add(("&Rights") & HK("AlignRights"), "AlignRights", "AlignRights", @mClick)
	miAlign->Add("-")
	miAlignTops = miAlign->Add(("&Tops") & HK("AlignTops"), "AlignTops", "AlignTops", @mClick)
	miAlignMiddles = miAlign->Add(("&Middles") & HK("AlignMiddles"), "AlignMiddles", "AlignMiddles", @mClick)
	miAlignBottoms = miAlign->Add(("&Bottoms") & HK("AlignBottoms"), "AlignBottoms", "AlignBottoms", @mClick)
	miAlign->Add("-")
	miAlignToGrid = miAlign->Add(("to &Grid") & HK("AlignToGrid"), "AlignToGrid", "AlignToGrid", @mClick)
	Var miMakeSameSize = miFormFormat->Add(("&Make Same Size"), "MakeSameSize", "MakeSameSize", @mClick)
	miMakeSameSizeWidth = miMakeSameSize->Add(("&Width") & HK("MakeSameSizeWidth"), "MakeSameSizeWidth", "MakeSameSizeWidth", @mClick)
	miMakeSameSizeHeight = miMakeSameSize->Add(("&Height") & HK("MakeSameSizeHeight"), "MakeSameSizeHeight", "MakeSameSizeHeight", @mClick)
	miMakeSameSizeBoth = miMakeSameSize->Add(("&Both") & HK("MakeSameSizeBoth"), "MakeSameSizeBoth", "MakeSameSizeBoth", @mClick)
	miFormFormat->Add("-")
	miFormFormat->Add(("Size to Gri&d") & HK("SizeToGrid"), "SizeToGrid", "SizeToGrid", @mClick)
	miFormFormat->Add("-")
	Var miHorizontalSpacing = miFormFormat->Add(("&Horizontal Spacing"), "HorizontalSpacing", "HorizontalSpacing", @mClick)
	miHorizontalSpacingMakeEqual = miHorizontalSpacing->Add(("Make &Equal") & HK("HorizontalSpacingMakeEqual"), "HorizontalSpacingMakeEqual", "HorizontalSpacingMakeEqual", @mClick)
	miHorizontalSpacingIncrease = miHorizontalSpacing->Add(("&Increase") & HK("HorizontalSpacingIncrease"), "HorizontalSpacingIncrease", "HorizontalSpacingIncrease", @mClick)
	miHorizontalSpacingDecrease = miHorizontalSpacing->Add(("&Decrease") & HK("HorizontalSpacingDecrease"), "HorizontalSpacingDecrease", "HorizontalSpacingDecrease", @mClick)
	miHorizontalSpacingRemove = miHorizontalSpacing->Add(("&Remove") & HK("HorizontalSpacingRemove"), "HorizontalSpacingRemove", "HorizontalSpacingRemove", @mClick)
	Var miVerticalSpacing = miFormFormat->Add(("&Vertical Spacing"), "VerticalSpacing", "VerticalSpacing", @mClick)
	miVerticalSpacingMakeEqual = miVerticalSpacing->Add(("Make &Equal") & HK("VerticalSpacingMakeEqual"), "VerticalSpacingMakeEqual", "VerticalSpacingMakeEqual", @mClick)
	miVerticalSpacingIncrease = miVerticalSpacing->Add(("&Increase") & HK("VerticalSpacingIncrease"), "VerticalSpacingIncrease", "VerticalSpacingIncrease", @mClick)
	miVerticalSpacingDecrease = miVerticalSpacing->Add(("&Decrease") & HK("VerticalSpacingDecrease"), "VerticalSpacingDecrease", "VerticalSpacingDecrease", @mClick)
	miVerticalSpacingRemove = miVerticalSpacing->Add(("&Remove") & HK("VerticalSpacingRemove"), "VerticalSpacingRemove", "VerticalSpacingRemove", @mClick)
	miFormFormat->Add("-")
	Var miCenterInParent = miFormFormat->Add(("&Center in Parent"), "CenterInParent", "CenterInParent", @mClick)
	miCenterInParentHorizontally = miCenterInParent->Add(("&Horizontally") & HK("CenterInParentHorizontally"), "CenterInParentHorizontally", "CenterInParentHorizontally", @mClick)
	miCenterInParentVertically = miCenterInParent->Add(("&Vertically") & HK("CenterInParentVertically"), "CenterInParentVertically", "CenterInParentVertically", @mClick)
	miFormFormat->Add("-")
	Var miOrder = miFormFormat->Add(("&Order"), "Order", "Order", @mClick)
	miOrderBringToFront = miOrder->Add(("&Bring to Front") & HK("BringToFront"), "BringToFront", "BringToFront", @mClick)
	miOrderSendToBack = miOrder->Add(("&Send to Back") & HK("SendToBack"), "SendToBack", "SendToBack", @mClick)
	miFormFormat->Add("-")
	miLockControls = miFormFormat->Add(("&Lock Controls") & HK("LockControls"), "LockControls", "LockControls", @mClick)
	miFormFormat->Add("-")
	miFormFormat->Add(("Previous Layer"), "", "PreviousLayer", @PopupClick)
	miFormFormat->Add(("Next Layer"), "", "NextLayer", @PopupClick)
	miFormFormat->Add("-")
	miFormFormat->Add(("Properties"), "Property", "Properties", @PopupClick)

	'' 13.3.A O2: Build + Debug + Run consolidated into one Run menu. "Build" survives as a command,
	'' not a menu. Top-level = the 90% path; the rest lives in the two "More ... Options" submenus.
	'' Captions are relabeled in the S2 pass; this pass only changes structure/grouping.
	'' R&un (Alt+U) rather than &Run (Alt+R) -- ROADMAP 13.28 pt 3 workaround; see &Code above.
	Var miRun = mnuMain.Add(("R&un"), "", "Run")
	mnuStartWithCompile = miRun->Add(("&Run") & HK("StartWithCompile", "F5"), "StartWithCompile", "StartWithCompile", @mClick, , , False)
	miCompile = miRun->Add(("&Build") & HK("Compile", "Ctrl+F9"), "Compile", "Compile", @mClick, , , False)
	miRun->Add("-")
	mnuEnd = miRun->Add(("&Stop") & HK("End"), "EndProgram", "End", @mClick, , , False)
	mnuRestart = miRun->Add(("R&estart") & HK("Restart", "Shift+F5"), "", "Restart", @mClick, , , False)
	miRun->Add("-")
	miStepInto = miRun->Add(("Step &Into") & HK("StepInto", "F8"), "StepInto", "StepInto", @mClick, , , False)
	miStepOver = miRun->Add(("Step &Over") & HK("StepOver", "Shift+F8"), "StepOver", "StepOver", @mClick, , , False)
	miStepOut = miRun->Add(("Step O&ut") & HK("StepOut", "Ctrl+Shift+F8"), "StepOut", "StepOut", @mClick, , , False)
	miToggleBreakpoint = miRun->Add(("&Toggle Breakpoint") & HK("Breakpoint", "F9"), "Breakpoint", "Breakpoint", @mClick, , , False)
	miRun->Add("-")
	mnuUseDebugger = miRun->Add(("&Use Debugger") & HK("UseDebugger"), "", "UseDebugger", @mClick, True)
	miRun->Add("-")
	miCompileAll = miRun->Add(("&Rebuild All") & HK("CompileAll", "Ctrl+Alt+F9"), "", "CompileAll", @mClick, , , False)
	miMakeClean = miRun->Add(("&Clean") & HK("MakeClean"), "", "MakeClean", @mClick, , , False)
	miSyntaxCheck = miRun->Add(("&Syntax Check") & HK("SyntaxCheck"), "SyntaxCheck", "SyntaxCheck", @mClick, , , False)
	miMake = miRun->Add(("&Make") & HK("Make"), "Make", "Make", @mClick, , , False)
	miRun->Add(("&Parameters") & HK("Parameters"), "Parameters", "Parameters", @mClick)
	mnuStart = miRun->Add(("Run Without &Building") & HK("Start", "Ctrl+F5"), "Start", "Start", @mClick, , , False)
	miRun->Add("-")
	miRunToCursor = miRun->Add(("&Run To Cursor") & HK("RunToCursor", "Ctrl+F8"), "RunToCursor", "RunToCursor", @mClick, , , False)
	mnuContinue = miRun->Add(("&Continue") & HK("Continue", "Ctrl+F5"), "Continue", "Continue", @mClick, , , False)
	mnuBreak = miRun->Add(("&Break") & HK("Break", "Ctrl+Break"), "Break", "Break", @mClick, , , False)
	miRun->Add("-")
	miClearAllBreakpoints = miRun->Add(("&Clear All Breakpoints") & HK("ClearAllBreakpoints", "Ctrl+Shift+F9"), "", "ClearAllBreakpoints", @mClick, , , False)
	miAddWatch = miRun->Add(("&Add Watch") & HK("AddWatch"), "", "AddWatch", @mClick, , , False)
	miSetNextStatement = miRun->Add(("Set &Next Statement") & HK("SetNextStatement"), "SetNextStatement", "SetNextStatement", @mClick, , , False)
	miShowNextStatement = miRun->Add(("Show Ne&xt Statement") & HK("ShowNextStatement"), "ShowNextStatement", "ShowNextStatement", @mClick, , , False)
	miRun->Add("-")
	mnuUseProfiler = miRun->Add(("Use &Profiler") & HK("UseProfiler"), "", "UseProfiler", @mClick, True)
	miGDBCommand = miRun->Add(("&GDB Command") & HK("GDBCommand"), "", "GDBCommand", @mClick, , , False)

	'' Git -- its own top-level menu (between Run and Tools) for git-backed projects.
	'' Enabled state is set contextually in ChangeMenuItemsEnabled. Grows as more git
	'' actions are added (commit, clone, etc.).
	'' G&it (Alt+I) rather than &Git (Alt+G) -- ROADMAP 13.28 pt 3 workaround; see &Code above.
	Var miGit = mnuMain.Add(("G&it"), "", "Git")
	miGitCommit = miGit->Add(("Git &Commit") & "..." & HK("GitCommit"), "", "GitCommit", @mClick, , , False)
	miGit->Add("-")
	miGitPull = miGit->Add(("Git &Pull") & HK("GitPull"), "", "GitPull", @mClick, , , False)
	miGitPush = miGit->Add(("Git Pus&h") & HK("GitPush"), "", "GitPush", @mClick, , , False)
	miGit->Add("-")
	'' Onboarding/setup actions (not project-gated).
	miGitSshKey = miGit->Add(("Set Up SSH &Key") & "..." & HK("GitSetupSshKey"), "", "GitSetupSshKey", @mClick)
	miGitCreateRepo = miGit->Add(("Create &Remote Repository") & "..." & HK("GitCreateRemoteRepo"), "", "GitCreateRemoteRepo", @mClick)

	miXizmat = mnuMain.Add(("&Tools"), "", "Service")
	'' Was Alt+C, which permanently shadowed the "&Code" menu: TranslateAccelerator runs before
	'' Windows resolves Alt+<letter> against the menu bar, so the menu simply never opened and
	'' a terminal appeared instead. Alt+<letter> belongs to menus (ROADMAP 13.28/13.35).
	'' Not Ctrl+` despite being the VS/VS Code convention -- GetAscKeyCode (Menus.bas:1454)
	'' falls through to Asc(), so a backtick would register as VK_NUMPAD0.
	miXizmat->Add(("&Command Prompt") & HK("CommandPrompt", "Ctrl+Shift+C"), "Console", "CommandPrompt", @mClick)
	miXizmat->Add("-")
	miXizmat->Add(("&Add-Ins") & "..." & HK("AddIns"), "", "AddIns", @mClick)
	miXizmat->Add(("&External Tools") & "..." & HK("Tools"), "", "Tools", @mClick)
	miXizmat->Add("-")
	Dim As My.Sys.Drawing.BitmapType Bitm
	Dim As WString * 1024 Buff
	Dim As MenuItem Ptr mi
	Dim As UserToolType Ptr tt
	'' Each user tool needs its OWN menu item name. They were all called "Tools" --
	'' the same name as the real "External Tools" item above -- so the Options dialog,
	'' which keys HotKeys.txt on item->Name, wrote one "Tools=" line per tool and
	'' shadowed the real binding with blanks. That is ROADMAP 13.33/13.35 at source.
	'' Dispatch is by mi->Tag in mClickTool and never by Name, so this rename is safe.
	Dim As Integer iUserTool = 0
	Dim As WString * 260 ToolsINI
		ToolsINI = ExePath & "/Tools/Tools.ini"
	If FileExists(ToolsINI) Then
		Dim As Integer Fn = FreeFile_
		Open ToolsINI For Input Encoding "utf8" As #Fn
		Do Until EOF(Fn)
			Line Input #Fn, Buff
			If StartsWith(Buff, "Path=") Then
				tt = 0
				If FileExistsU(GetFullPathU(Mid(Buff, 6))) Then
					tt = _New( UserToolType)
					tt->Path = Mid(Buff, 6)
				End If
			ElseIf tt <> 0 Then
				If StartsWith(Buff, "Name=") Then
					tt->Name = Mid(Buff, 6)
				ElseIf StartsWith(Buff, "Parameters=") Then
					tt->Parameters = Mid(Buff, 12)
				ElseIf StartsWith(Buff, "WorkingFolder=") Then
					tt->WorkingFolder = Mid(Buff, 15)
				ElseIf StartsWith(Buff, "Accelerator=") Then
					tt->Accelerator = Mid(Buff, 13)
				ElseIf StartsWith(Buff, "LoadType=") Then
					tt->LoadType = Cast(LoadTypes, Val(Mid(Buff, 10)))
				ElseIf StartsWith(Buff, "WaitComplete=") Then
					tt->WaitComplete = Cast(Boolean, Mid(Buff, 14))
					Tools.Add tt
					Dim As HICON IcoHandle
					ExtractIconEx(GetFullPath(tt->Path), NULL, NULL, @IcoHandle, 1)
					Bitm = IcoHandle
					DestroyIcon IcoHandle
					mi = miXizmat->Add(tt->Name & !"\t" & tt->Accelerator, Bitm, "UserTool" & Trim(Str(iUserTool)), @mClickTool)
					iUserTool += 1
					Bitm.Handle = 0
					mi->Tag = tt
					tt = 0
				End If
			End If
		Loop
		CloseFile_(Fn)
	End If
	miXizmat->Add("-")
	miXizmat->Add(("&Options") & HK("Options"), "Tools", "Options", @mClick)
	
	miWindow = mnuMain.Add(("&Window"), "", "Window")
	mnuWindowSeparator = miWindow->Add("-")
	mnuWindowSeparator->Visible = False
	
	Var miHelp = mnuMain.Add(("&Help"), "", "Help")
	miHelp->Add(("&Content") & HK("Content", "F1"), "Book", "Content", @mClick)
	miHelps = miHelp->Add(("&Others"), "", "Others")
	Dim As WString * 1024 sTmp2
	For i As Integer = 0 To pHelps->Count - 1
		sTmp = pHelps->Item(i)->Key 'iniSettings.ReadString("Helps", "Version_" & WStr(i), "")
		sTmp2 = pHelps->Item(i)->Text 'iniSettings.ReadString("Helps", "Path_" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			miHelps->Add(Trim(sTmp) & HK(sTmp), sTmp2, sTmp, @mClickHelp)
		End If
	Next
	miHelp->Add("-")
	miHelp->Add(("FreeBasic WiKi") & HK("FreeBasicWiKi"), "Book", "FreeBasicWiKi", @mClick)
	miHelp->Add(("FreeBasic Forums") & HK("FreeBasicForums"), "Forum", "FreeBasicForums", @mClick)
	miHelp->Add("-")
	miHelp->Add(("&About") & HK("About"), "About", "About", @mClick)
	
	'mnuForm.ImagesList = @imgList '<m>
	mnuForm.Add(("Cu&t"), "Cut", "Cut", @mClick)
	mnuForm.Add(("&Copy"), "Copy", "Copy", @mClick)
	mnuForm.Add(("&Paste"), "Paste", "Paste", @mClick)
	
	'mnuTabs.ImagesList = @imgList '<m>
	miTabSetAsMain = mnuTabs.Add(("&Set as Main"), "", "SetAsMain", @mClick)
	miTabReloadHistoryCode = mnuTabs.Add(("&Reload History Code"), "", "ReloadHistoryCode", @mClick)
	mnuTabs.Add("-")
	mnuTabs.Add(("&Close"), "Close", "Close", @mClick)
	mnuTabs.Add(("Close All Without Current"), "", "CloseAllWithoutCurrent", @mClick)
	mnuTabs.Add(("Close &All"), "", "CloseAll", @mClick)
	mnuTabs.Add("-")
	mnuTabs.Add(("Split Up"), "", "SplitUp", @mClick)
	mnuTabs.Add(("Split Down"), "", "SplitDown", @mClick)
	mnuTabs.Add(("Split Left"), "", "SplitLeft", @mClick)
	mnuTabs.Add(("Split Right"), "", "SplitRight", @mClick)
	mnuTabs.Add("-")
	mnuTabs.Add(("Split &Horizontally"), "", "SplitHorizontally", @mClick)
	mnuTabs.Add(("Split &Vertically"), "", "SplitVertically", @mClick)
	
	'mnuVars.ImagesList = @imgList '<m>
	mnuVars.Add(("Variable Dump"), "", "VariableDump", @mClick)
	mnuVars.Add(("Pointed data Dump"), "", "PointedDataDump", @mClick)
	mnuVars.Add("-")
	mnuVars.Add(("Show String"), "", "ShowString", @mClick)
	mnuVars.Add(("Show/Expand Variable"), "", "ShowExpandVariable", @mClick)
	
	mnuWatch.Add(("Memory Dump"), "", "MemoryDumpWatch", @mClick)
	mnuWatch.Add("-")
	mnuWatch.Add(("Show String"), "", "ShowStringWatch", @mClick)
	mnuWatch.Add(("Show/Expand Variable"), "", "ShowExpandVariableWatch", @mClick)
	
	mnuProblems.Add(("Copy "), "", "ProblemsCopy", @mClick)
	mnuProblems.Add(("Copy All"), "", "ProblemsCopyAll", @mClick)
	
	mnuProcedures.Add(("Locate procedure (source)"), "", "LocateProcedure", @mClick)
	mnuProcedures.Add(("Toggle sort by module or by procedure"), "", "ToggleSort", @mClick)
	mnuProcedures.Add("-")
	mnuProcedures.Add(("Enable/disable"), "", "EnableDisable", @mClick)
	
	'mnuExplorer.ImagesList = @imgList '<m>
	miSetAsMain = mnuExplorer.Add(("&Set As Main"), "", "SetAsMain", @mClick)
	miClearStartUp = mnuExplorer.Add(("&Clear Start Up"), "", "ClearStartUp", @mClick)
	mnuExplorer.Add("-")
	Var miAdd = mnuExplorer.Add(("&Add"), "Add", "Add", @mClick)
	miAdd->Add(("Add &Form"), "Form", "AddForm", @mClick)
	miAdd->Add(("Add &Module"), "Module", "AddModule", @mClick)
	miAdd->Add(("Add &Include File"), "File", "AddIncludeFile", @mClick)
	miAdd->Add(("Add &User Control"), "UserControl", "AddUserControl", @mClick)
	miAdd->Add(("Add &Resource File"), "Resource", "AddResourceFile", @mClick)
	miAdd->Add(("Add Ma&nifest File"), "File", "AddManifestFile", @mClick)
	miAdd->Add(("Add From Templates") & "...", "", "AddFromTemplates", @mClick)
	miAdd->Add(("Add Files") & "...", "", "AddFilesToProject", @mClick)
	miExplorerRename = mnuExplorer.Add(("Rename"), "", "Rename", @mClick, , , False)
	miRemoveFiles = mnuExplorer.Add(("&Delete File"), "Remove", "DeleteFile", @mClick)
	mnuExplorer.Add("-")
	miExplorerOpenProjectFolder = mnuExplorer.Add(("Open Project Folder"), "", "OpenProjectFolder", @mClick, , , False)
	miExplorerCloseProject = mnuExplorer.Add(("Close Project"), "", "CloseProject", @mClick, , , False)
	mnuExplorer.Add("-")
	miExplorerProjectProperties = mnuExplorer.Add(("Project &Properties") & "...", "", "ProjectProperties", @mClick, , , False)
	
	'txtCommands.Left = 300
	'txtCommands.AnchorRight = asAnchor
	'cboCommands.ImagesList = @imgList
	'txtCommands.Style = cbDropDown
	'txtCommands.Align = 3
	'txtCommands.Items.Add "fdfd"
	
	tbStandard.Name = "Standard"
	tbStandard.ImagesList = @imgList
	tbStandard.HotImagesList = @imgList
	'tbStandard.DisabledImagesList = @imgListD
	tbStandard.Flat = True
	tbStandard.List = True
	tbStandard.Buttons.Add tbsAutosize, "New", , @mClick, "New", , ("New") & HK("New", "Ctrl+N", True), True
	tbStandard.Buttons.Add tbsAutosize, "Open", , @mClick, "Open", ("Open"), ("Open") & HK("Open", "Ctrl+O", True), True
	tbtSave = tbStandard.Buttons.Add(tbsAutosize, "Save", , @mClick, "Save", ("Save"), ("Save") & "..." & HK("Save", "Ctrl+S", True), True, ToolButtonState.tstNone)
	tbtSaveAll = tbStandard.Buttons.Add(, "SaveAll", , @mClick, "SaveAll", , ("Save &All") & HK("SaveAll", "Ctrl+Alt+Shift+S", True), True, ToolButtonState.tstNone)
	tbStandard.Buttons.Add tbsSeparator
	tbtUndo = tbStandard.Buttons.Add(, "Undo", , @mClick, "Undo", , ("Undo") & HK("Undo", "Ctrl+Z", True), True, ToolButtonState.tstNone)
	tbtRedo = tbStandard.Buttons.Add(, "Redo", , @mClick, "Redo", , ("Redo") & HK("Redo", "Ctrl+Shift+Z", True), True, ToolButtonState.tstNone)
	tbStandard.Buttons.Add tbsSeparator
	tbtCut = tbStandard.Buttons.Add(, "Cut", , @mClick, "Cut", , ("Cut") & HK("Cut", "Ctrl+X", True), True, ToolButtonState.tstNone)
	tbtCopy = tbStandard.Buttons.Add(, "Copy", , @mClick, "Copy", , ("Copy") & HK("Copy", "Ctrl+C", True), True, ToolButtonState.tstNone)
	tbtPaste = tbStandard.Buttons.Add(, "Paste", , @mClick, "Paste", , ("Paste") & HK("Paste", "Ctrl+V", True), True, ToolButtonState.tstNone)
	tbStandard.Buttons.Add tbsSeparator
	tbtFind = tbStandard.Buttons.Add(, "Find", , @mClick, "Find", , ("Find") & HK("Find", "Ctrl+F", True), True, ToolButtonState.tstNone)
	'tbStandard.Buttons.Add tbsSeparator
	tbEdit.Name = "Edit"
	tbEdit.ImagesList = @imgList
	tbEdit.HotImagesList = @imgList
	'tbEdit.DisabledImagesList = @imgListD
	tbEdit.Flat = True
	tbEdit.List = True
	tbtFormat = tbEdit.Buttons.Add(, "Format", , @mClick, "Format", , ("Format") & HK("Format", "Ctrl+K", True), True, ToolButtonState.tstNone)
	'' This default read "Shift+Ctrl+Tab" while every other Unformat site read "Ctrl+Shift+Tab".
	'' Harmless only because HotKeys.txt supplies the value everywhere; had the key ever been
	'' absent, the toolbar tooltip would have advertised a different shortcut from the menu.
	tbtUnformat = tbEdit.Buttons.Add(, "Unformat", , @mClick, "Unformat", , ("Unformat") & HK("Unformat", "Ctrl+Shift+K", True), True, ToolButtonState.tstNone)
	tbEdit.Buttons.Add tbsSeparator
	tbtSingleComment = tbEdit.Buttons.Add(, "Comment", , @mClick, "SingleComment", , ("Toggle comment") & HK("SingleComment", "Ctrl+I", True), True, ToolButtonState.tstNone)
	tbEdit.Buttons.Add tbsSeparator
	tbtCompleteWord = tbEdit.Buttons.Add(, "CompleteWord", , @mClick, "CompleteWord", , ("Complete Word") & HK("CompleteWord", "Ctrl+Space", True), True, ToolButtonState.tstNone)
	tbtParameterInfo = tbEdit.Buttons.Add(, "ParameterInfo", , @mClick, "InvokeParameterInfo", , ("Parameter Info") & HK("ParameterInfo", "Ctrl+J", True), True)
	tbEdit.Buttons.Add tbsSeparator
	tbtSyntaxCheck = tbEdit.Buttons.Add(, "SyntaxCheck", , @mClick, "SyntaxCheck", , ("Syntax Check"), True, ToolButtonState.tstNone)
	tbtSuggestions = tbEdit.Buttons.Add(, "Suggestions", , @mClick, "AnalyzeSuggestions", , ("Suggestions"), True, ToolButtonState.tstNone)
	'tbStandard.Buttons.Add tbsSeparator
	'' 13.3.A O3: Build + Debug + Run toolbars consolidated into one Run toolbar (mirrors the O2
	'' Run-menu consolidation and drops the ReBar from 7 bands to 5). Primary buttons (Run, Build,
	'' Stop) get a visible caption -- every toolbar already had TBSTYLE_LIST (.List = True) enabled,
	'' but no button had ever passed a Caption, so the "text beside icon" style was silently unused.
	'' Secondary/advanced buttons stay icon-only. Order mirrors the Run menu's own top-level-then-
	'' advanced grouping. Bug fix along the way: the old code assigned the "ShowNextStatement" button
	'' to tbtToggleBreakpoint a second time (copy/paste), silently losing the real Toggle Breakpoint
	'' button's pointer; tbtShowNextStatement (declared, never used) is the correct target.
	tbRun.Name = "Run"
	tbRun.ImagesList = @imgList
	tbRun.HotImagesList = @imgList
	tbRun.Flat = True
	tbRun.List = True
	tbtStartWithCompile = tbRun.Buttons.Add(tbsAutosize, "StartWithCompile", , @mClick, "StartWithCompile", ("Run"), ("Run") & HK("StartWithCompile", "F5", True), True, ToolButtonState.tstNone)
	tbtCompile = tbRun.Buttons.Add(tbsAutosize, "Compile", , @mClick, "Compile", ("Build"), ("Build") & HK("Compile", "Ctrl+F9", True), True, ToolButtonState.tstNone)
	tbRun.Buttons.Add tbsSeparator
	tbtEnd = tbRun.Buttons.Add(tbsAutosize, "EndProgram", , @mClick, "End", ("Stop"), ("Stop") & HK("End", , True), True, ToolButtonState.tstNone)
	tbRun.Buttons.Add tbsSeparator
	tbtStepInto = tbRun.Buttons.Add(, "StepInto", , @mClick, "StepInto", , ("Step Into: run the current line, descending into any function it calls") & HK("StepInto", "F8", True), True)
	tbtStepOver = tbRun.Buttons.Add(, "StepOver", , @mClick, "StepOver", , ("Step Over: run the current line, executing function calls without descending into them") & HK("StepOver", "Shift+F8", True), True)
	tbtToggleBreakpoint = tbRun.Buttons.Add(, "Breakpoint", , @mClick, "Breakpoint", , ("Toggle Breakpoint") & HK("Breakpoint", "F9", True), True)
	tbRun.Buttons.Add tbsSeparator
	tbtUseDebugger = tbRun.Buttons.Add(Cast(ToolButtonStyle, tbsCheck Or tbsAutosize), "UseDebugger", , @mClick, "TBUseDebugger", , ("Use Debugger") & HK("UseDebugger", , True), True)
	tbRun.Buttons.Add tbsSeparator
	tbtStart = tbRun.Buttons.Add(, "Start", , @mClick, "Start", , ("Run Without Building") & HK("Start", "Ctrl+F5", True), True, ToolButtonState.tstNone)
	tbtBreak = tbRun.Buttons.Add(, "Break", , @mClick, "Break", , ("Break") & HK("Break", "Ctrl+Pause", True), True, ToolButtonState.tstNone)
	tbtStepOut = tbRun.Buttons.Add(, "StepOut", , @mClick, "StepOut", , ("Step Out: keep running until the current function returns to its caller") & HK("StepOut", "Ctrl+Shift+F8", True), True)
	tbtRunToCursor = tbRun.Buttons.Add(, "RunToCursor", , @mClick, "RunToCursor", , ("Run To Cursor") & HK("RunToCursor", "Ctrl+F8", True), True)
	tbRun.Buttons.Add tbsSeparator
	tbtSetNextStatement = tbRun.Buttons.Add(, "SetNextStatement", , @mClick, "SetNextStatement", , ("Set Next Statement") & HK("SetNextStatement", , True), True)
	tbtShowNextStatement = tbRun.Buttons.Add(, "ShowNextStatement", , @mClick, "ShowNextStatement", , ("Show Next Statement") & HK("ShowNextStatement", , True), True)
	tbRun.Buttons.Add tbsSeparator
	Var tbMake = tbRun.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsWholeDropdown), "Make", , @mClick, "Make", , ("Make"), True)
	dmiMake = tbMake->DropDownMenu.Add("Make", "", "Make", @mClick, , , False)
	dmiMakeClean = tbMake->DropDownMenu.Add("Make clean", "", "MakeClean", @mClick, , , False)
	tbRun.Buttons.Add , "Parameters", , @mClick, "Parameters", , ("Parameters"), True
	'tbStandard.Buttons.Add tbsSeparator
	tbProject.Name = "Project"
	tbProject.ImagesList = @imgList
	tbProject.HotImagesList = @imgList
	'tbProject.DisabledImagesList = @imgListD
	tbProject.Flat = True
	tbProject.List = True
	tbtNotSetted = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsCheckGroup), "NotSetted", , @mClick, "NotSetted", , ("Not Set"), True)
	tbtConsole = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsCheckGroup), "Console", , @mClick, "Console", , ("Console"), True)
	tbtGUI = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsCheckGroup), "Form", , @mClick, "GUI", , ("GUI"), True)
	tbProject.Buttons.Add tbsSeparator
	Var tbButton = tbProject.Buttons.Add(tbsCustom)
	tbButton->Width = 170
	tbButton->Child = @cboBuildConfiguration
	cboBuildConfiguration.Hint = ("Build Configuration: extra compiler switches to apply when building")
	tbFormat.Name = "Format"
	tbFormat.ImagesList = @imgList
	tbFormat.HotImagesList = @imgList
	tbFormat.Flat = True
	tbFormat.List = True
	tbtAlignLefts = tbFormat.Buttons.Add(, "AlignLefts", , @mClick, "AlignLefts", , ("Align Lefts"), True)
	tbtAlignCenters = tbFormat.Buttons.Add(, "AlignCenters", , @mClick, "AlignCenters", , ("Align Centers"), True)
	tbtAlignRights = tbFormat.Buttons.Add(, "AlignRights", , @mClick, "AlignRights", , ("Align Rights"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtAlignTops = tbFormat.Buttons.Add(, "AlignTops", , @mClick, "AlignTops", , ("Align Tops"), True)
	tbtAlignMiddles = tbFormat.Buttons.Add(, "AlignMiddles", , @mClick, "AlignMiddles", , ("Align Middles"), True)
	tbtAlignBottoms = tbFormat.Buttons.Add(, "AlignBottoms", , @mClick, "AlignBottoms", , ("Align Bottoms"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtAlignToGrid = tbFormat.Buttons.Add(, "AlignToGrid", , @mClick, "AlignToGrid", , ("Align to Grid"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtMakeSameSizeWidth = tbFormat.Buttons.Add(, "MakeSameSizeWidth", , @mClick, "MakeSameSizeWidth", , ("Make Same Width"), True)
	tbtMakeSameSizeHeight = tbFormat.Buttons.Add(, "MakeSameSizeHeight", , @mClick, "MakeSameSizeHeight", , ("Make Same Height"), True)
	tbtMakeSameSizeBoth = tbFormat.Buttons.Add(, "MakeSameSizeBoth", , @mClick, "MakeSameSizeBoth", , ("Make Same Size"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtSizeToGrid = tbFormat.Buttons.Add(, "SizeToGrid", , @mClick, "SizeToGrid", , ("Size to Grid"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtHorizontalSpacingMakeEqual = tbFormat.Buttons.Add(, "HorizontalSpacingMakeEqual", , @mClick, "HorizontalSpacingMakeEqual", , ("Make Equal Horizontal Space"), True)
	tbtHorizontalSpacingIncrease = tbFormat.Buttons.Add(, "HorizontalSpacingIncrease", , @mClick, "HorizontalSpacingIncrease", , ("Increase Horizontal Space"), True)
	tbtHorizontalSpacingDecrease = tbFormat.Buttons.Add(, "HorizontalSpacingDecrease", , @mClick, "HorizontalSpacingDecrease", , ("Decrease Horizontal Space"), True)
	tbtHorizontalSpacingRemove = tbFormat.Buttons.Add(, "HorizontalSpacingRemove", , @mClick, "HorizontalSpacingRemove", , ("Remove Horizontal Space"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtVerticalSpacingMakeEqual = tbFormat.Buttons.Add(, "VerticalSpacingMakeEqual", , @mClick, "VerticalSpacingMakeEqual", , ("Make Equal Vertical Space"), True)
	tbtVerticalSpacingIncrease = tbFormat.Buttons.Add(, "VerticalSpacingIncrease", , @mClick, "VerticalSpacingIncrease", , ("Increase Vertical Space"), True)
	tbtVerticalSpacingDecrease = tbFormat.Buttons.Add(, "VerticalSpacingDecrease", , @mClick, "VerticalSpacingDecrease", , ("Decrease Vertical Space"), True)
	tbtVerticalSpacingRemove = tbFormat.Buttons.Add(, "VerticalSpacingRemove", , @mClick, "VerticalSpacingRemove", , ("Remove Vertical Space"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtCenterInParentHorizontally = tbFormat.Buttons.Add(, "CenterInParentHorizontally", , @mClick, "CenterInParentHorizontally", , ("Center In Parent Horizontally"), True)
	tbtCenterInParentVertically = tbFormat.Buttons.Add(, "CenterInParentVertically", , @mClick, "CenterInParentVertically", , ("Center In Parent Vertically"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtOrderBringToFront = tbFormat.Buttons.Add(, "BringToFront", , @mClick, "BringToFront", , ("Bring to Front"), True)
	tbtOrderSendToBack = tbFormat.Buttons.Add(, "SendToBack", , @mClick, "SendToBack", , ("Send to Back"), True)
	tbFormat.Buttons.Add tbsSeparator
	tbtLockControls = tbFormat.Buttons.Add(Cast(ToolButtonStyle, tbsCheck Or tbsAutosize), "LockControls", , @mClick, "TBLockControls", , ("Lock Controls"), True)
End Sub

CreateMenusAndToolBars
'' Must run after the menus exist: the mnemonic-shadowing check reads the menu bar.
ValidateHotKeys
'' Checked once here rather than per message -- this sits in the main window's message path.
bLogMenuKeys = FileExists(ExePath & "/Temp/_astoria_menukeys.on")
'tbStandard.AddRange 1, @cboCommands

Sub tbLeft_OnResize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	pnlLeftPin.Height = NewHeight
End Sub

tbLeft.ImagesList = @imgList
tbLeft.Buttons.Add tbsCheck, "Pinned", , @mClick, "PinLeft", "", ("Pin"), True, Cast(ToolButtonState, tstEnabled Or tstChecked)
tbLeft.Flat = True
tbLeft.Width = 23
tbLeft.Parent = @pnlLeftPin
tbLeft.OnResize = @tbLeft_OnResize

tbExplorer.ImagesList = @imgList
tbExplorer.HotImagesList = @imgList
'tbExplorer.DisabledImagesList = @imgList
tbExplorer.Flat = True
tbExplorer.Align = DockStyle.alTop
tbExplorer.AutoSize = True
tbExplorer.ExtraMargins.Left = 2
tbExplorer.ExtraMargins.Right = tbLeft.Width
tbExplorer.Buttons.Add , "Add",, @mClick, "AddFilesToProject", , ("Add"), True
tbtRemoveFileFromProject = tbExplorer.Buttons.Add(, "Remove", , @mClick, "DeleteFile", , ("Delete File"), True, ToolButtonState.tstNone)
tbExplorer.Buttons.Add tbsSeparator
Var tbFolder = tbExplorer.Buttons.Add(tbsWholeDropdown, "Folder", , @mClick, "Folder", , ("Show Folders"), True)
miShowWithFolders = tbFolder->DropDownMenu.Add(("Show With Folders"), "", "ShowWithFolders", @mClick, , , True)
miShowWithoutFolders = tbFolder->DropDownMenu.Add(("Show Without Folders"), "", "ShowWithoutFolders", @mClick, , , True)
miShowAsFolder = tbFolder->DropDownMenu.Add(("Show As Folder"), "", "ShowAsFolder", @mClick, , , False)
tbExplorer.Buttons.Add tbsSeparator
Var tbSearch = tbExplorer.Buttons.Add(tbsCustom)
txtExplorer.Width = 2
txtExplorer.Hint = ("Search Explorer")
tbSearch->Child = @txtExplorer
tbSearch->Expand = True
tbExplorer.Buttons.Add tbsSeparator

Sub tbFormClick(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
End Sub

tbForm.ImagesList = @imgList
tbForm.HotImagesList = @imgList
'tbForm.DisabledImagesList = @imgListD
tbForm.Align = DockStyle.alTop
tbForm.Flat = True
tbForm.ExtraMargins.Left = 2
tbForm.ExtraMargins.Right = tbLeft.Width
tbForm.Buttons.Add tbsCheck, "Label", , @tbFormClick, "Text", "", ("Text"), True, Cast(ToolButtonState, tstChecked Or tstEnabled)
tbForm.Buttons.Add tbsSeparator
Var FormSearch = tbForm.Buttons.Add(tbsCustom)
txtForm.Width = 2
txtForm.Hint = ("Search Toolbox")
FormSearch->Child = @txtForm
FormSearch->Expand = True
tbForm.Buttons.Add tbsSeparator

imgListTools.Add "DropDown", "DropDown"
imgListTools.Add "DropRight", "DropRight"
imgListTools.Add "Kursor", "Cursor"
imgListTools.Add "Folder", "Folder"
tvToolBox.Align = DockStyle.alClient
tvToolBox.Images = @imgListTools
tvToolBox.SelectedImages = @imgListTools
tvToolBox.HideSelection = False
tvToolBox.OnSelChanged = @tvToolBox_SelChanged
tvToolBox.OnNodeActivate = @tvToolBox_NodeActivate

tabLeftWidth = iniSettings.ReadInteger("MainWindow", "LeftWidth", DEFAULT_LEFT_PANEL_WIDTH)
tabRightWidth = iniSettings.ReadInteger("MainWindow", "RightWidth", 200)
tabBottomHeight = iniSettings.ReadInteger("MainWindow", "BottomHeight", DEFAULT_BOTTOM_PANEL_HEIGHT)
If tabBottomHeight < MIN_BOTTOM_PANEL_HEIGHT Then tabBottomHeight = DEFAULT_BOTTOM_PANEL_HEIGHT

splLeft.Align = SplitterAlignmentConstants.alLeft
splRight.Align = SplitterAlignmentConstants.alRight
splBottom.Align = SplitterAlignmentConstants.alBottom

Sub CloseLeft()
	splLeft.Visible = False
	tabLeft.SelectedTabIndex = -1
	' Never narrower than the pin toolbar, so the pin is not clipped.
	pnlLeft.Width = Max(tabLeft.ItemWidth(0), tbLeft.Width) + 2
	' Pin stays visible in vertical tab mode so user can switch back to wide tabs.
	If GetLeftClosedStyle Then
		UpdateLeftPinLayout
	Else
		pnlLeftPin.Visible = False
	End If
	frmMain.RequestAlign
End Sub

Sub ShowLeft()
	tabLeft.SetFocus
	pnlLeft.Width = tabLeftWidth
	pnlLeft.RequestAlign
	splLeft.Visible = True
	UpdateLeftPinLayout
	frmMain.RequestAlign
End Sub

Sub CloseRight()
	splRight.Visible = False
	tabRight.SelectedTabIndex = -1
	pnlRight.Width = tabRight.ItemWidth(0) + 2
	If GetRightClosedStyle Then
		pnlRightPin.Align = DockStyle.alTop
		pnlRightPin.Height = tbRight.Height
		pnlRightPin.Visible = True
	Else
		pnlRightPin.Visible = False
	End If
	frmMain.RequestAlign
End Sub

Sub ShowRight()
	tabRight.SetFocus
	pnlRight.Width = tabRightWidth
	pnlRight.RequestAlign
	splRight.Visible = True
	pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - tabRight.ItemWidth(0) - 4
	pnlRightPin.Visible = True
	frmMain.RequestAlign
End Sub

Sub ActivateMainWindow()
	If frmMain.Handle = 0 Then Return
	Dim fgWnd As HWND = GetForegroundWindow()
	Dim fgThread As DWORD
	Dim ourThread As DWORD = GetCurrentThreadId()
	If fgWnd Then fgThread = GetWindowThreadProcessId(fgWnd, NULL)
	If fgThread <> 0 AndAlso fgThread <> ourThread Then AttachThreadInput ourThread, fgThread, 1
	If frmMain.WindowState = WindowStates.wsMinimized Then
		ShowWindow frmMain.Handle, SW_RESTORE
	Else
		ShowWindow frmMain.Handle, SW_SHOWNORMAL
	End If
	SetForegroundWindow frmMain.Handle
	frmMain.SetFocus
	If fgThread <> 0 AndAlso fgThread <> ourThread Then AttachThreadInput ourThread, fgThread, 0
End Sub

Sub UpdateBottomPinLayout()
	Dim pinStripWidth As Integer = BOTTOM_PIN_STRIP_WIDTH
	Dim pinRightInset As Integer = 8
	pnlBottomPin.Align = DockStyle.alNone
	pnlBottomPin.Anchor.Left = AnchorStyle.asNone
	pnlBottomPin.Anchor.Right = AnchorStyle.asNone
	pnlBottomPin.Anchor.Top = AnchorStyle.asNone
	pnlBottomPin.Anchor.Bottom = AnchorStyle.asNone
	pnlBottomPin.Width = pinStripWidth
	tbBottom.Align = DockStyle.alClient
	tbBottom.Width = pinStripWidth
	If ptabBottom->TabPosition = tpTop AndAlso pnlBottomPin.Visible Then
		pnlBottomTab.ExtraMargins.Right = pinStripWidth + pinRightInset
		pnlBottomPin.Height = BOTTOM_PIN_STRIP_WIDTH
		pnlBottomPin.Top = Max(2, (Max(tabItemHeight, BOTTOM_PIN_STRIP_WIDTH) - BOTTOM_PIN_STRIP_WIDTH) \ 2)
		pnlBottomPin.Left = Max(0, pnlBottom.Width - pinStripWidth - pinRightInset)
		pnlBottomPin.BringToFront
	ElseIf ptabBottom->TabPosition = tpBottom AndAlso pnlBottomPin.Visible Then
		pnlBottomTab.ExtraMargins.Right = pinStripWidth + 4
		Dim stripHeight As Integer = Max(pnlBottom.Height, BOTTOM_PIN_STRIP_WIDTH + 2)
		pnlBottomPin.Height = Min(BOTTOM_PIN_STRIP_WIDTH, stripHeight)
		pnlBottomPin.Top = Max(0, (stripHeight - pnlBottomPin.Height) \ 2)
		pnlBottomPin.Left = Max(0, pnlBottom.Width - pinStripWidth - 4)
		pnlBottomPin.BringToFront
	Else
		pnlBottomTab.ExtraMargins.Right = 0
	End If
	pnlBottom.RequestAlign
End Sub

Sub CloseBottom()
	splBottom.Visible = False
	ptabBottom->SelectedTabIndex = -1
	Dim collapsedHeight As Integer = Max(ptabBottom->ItemHeight(0) + 2, BOTTOM_PIN_STRIP_WIDTH + 2)
	pnlBottom.Height = collapsedHeight
	ptabBottom->Height = collapsedHeight
	If GetBottomClosedStyle() Then
		pnlBottomPin.Visible = True
		tbBottom.Buttons.Item("EraseOutputWindow")->Visible = False
		tbBottom.Buttons.Item("EraseImmediateWindow")->Visible = False
		tbBottom.Buttons.Item("AddWatch")->Visible = False
		tbBottom.Buttons.Item("RemoveWatch")->Visible = False
		tbBottom.Buttons.Item("Update")->Visible = False
		UpdateBottomPinLayout
	Else
		pnlBottomPin.Visible = False
		pnlBottomTab.ExtraMargins.Right = 0
	End If
	pnlBottom.RequestAlign
	frmMain.RequestAlign
End Sub

Sub ShowBottom()
	ptabBottom->SetFocus
	pnlBottom.Height = tabBottomHeight
	ptabBottom->Height = tabBottomHeight
	pnlBottom.RequestAlign
	splBottom.Visible = True
	pnlBottomPin.Visible = True
	UpdateBottomPinLayout
	frmMain.RequestAlign '<bp>
End Sub

Function GetLeftClosedStyle As Boolean
	Return Not tabLeft.TabPosition = tpTop
End Function

Function IsLeftCollapsed As Boolean
	Return tabLeft.TabPosition = tpLeft And tabLeft.SelectedTabIndex = -1
End Function

' Central left-pin layout, called from every path that changes the left panel
' mode: startup (SetLeftClosedStyle), pin click, tab-click expand (ShowLeft),
' collapse (CloseLeft) and pnlLeft resize.
' Vertical-tab mode docks the pin alTop so the layout engine reserves the top
' strip of pnlLeft exclusively for it: a floating pin there was either clipped
' off the narrow collapsed panel (Left = tabItemHeight >= panel width) or left
' stale over the client-aligned tabLeft because a fully unanchored control is
' skipped by RequestAlign. Wide mode restores the floating right-anchored pin
' below the horizontal tab strip (the layout that has always worked).
Sub UpdateLeftPinLayout()
	If GetLeftClosedStyle Then
		pnlLeftPin.Anchor.Right = AnchorStyle.asNone
		pnlLeftPin.Align = DockStyle.alTop
		pnlLeftPin.Height = tbLeft.Height
	Else
		pnlLeftPin.Align = DockStyle.alNone
		pnlLeftPin.Width = tbLeft.Width
		pnlLeftPin.Height = tbLeft.Height
		pnlLeftPin.Top = tabItemHeight
		pnlLeftPin.Left = tabLeftWidth - pnlLeftPin.Width - 4
		pnlLeftPin.Anchor.Right = AnchorStyle.asAnchor
	End If
	pnlLeftPin.Visible = True
	pnlLeft.RequestAlign
End Sub

Dim Shared bClosing As Boolean
Dim Shared bApplyingStartupLayout As Boolean
Sub SetLeftClosedStyle(Value As Boolean, WithClose As Boolean = True)
	If bClosing Then Exit Sub
	bClosing = True
	Dim pinBtn As ToolButton Ptr = tbLeft.Buttons.Item("PinLeft")
	If pinBtn <> 0 Then
		If Value Then
			tabLeft.TabPosition = tpLeft
			pinBtn->ImageKey = "Pin"
			pinBtn->Checked = False
			UpdateLeftPinLayout
			If WithClose Then CloseLeft
		Else
			pnlLeft.Width = tabLeftWidth
			tabLeft.TabPosition = tpTop
			splLeft.Visible = True
			pinBtn->ImageKey = "Pinned"
			pinBtn->Checked = True
			UpdateLeftPinLayout
			If leftSelectedTabIndex >= 0 AndAlso leftSelectedTabIndex < tabLeft.TabCount Then tabLeft.SelectedTabIndex = leftSelectedTabIndex
		End If
	End If
	frmMain.RequestAlign
	bClosing = False
End Sub

Sub tabLeft_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	SetLeftClosedStyle Not GetLeftClosedStyle
End Sub

Function ToolType.GetCommand(ByRef FileName As WString, WithoutProgram As Boolean) As UString
	Dim As ProjectElement Ptr Project
	Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr ProjectNode
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As UString ProjectFile = ""
	Dim As UString CompileLine, MainFile = GetMainFile(, Project, ProjectNode)
	Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project, CompileLine)
	Dim As UString ExeFile = GetExeFileName(MainFile, CompileLine & " " & FirstLine)
	Dim As UString CurrentWord = ""
	Dim As UString Params
	If Trim(This.Path) <> "" AndAlso Not WithoutProgram Then
		Params = """" & GetRelativePath(This.Path, pApp->FileName) & """ "
	End If
	Params &= This.Parameters
	If ProjectNode <> 0 Then ee = ProjectNode->Tag
	If ee <> 0 Then ProjectFile = *ee->FileName
	If tb <> 0 Then CurrentWord = tb->txtCode.GetWordAtCursor
	Params = Replace(Params, "{P}", ProjectFile)
	Params = Replace(Params, "{P|S}", IIf(ProjectFile = "", MainFile, ProjectFile))
	Params = Replace(Params, "{S}", MainFile)
	Params = Replace(Params, "{W}", CurrentWord)
	Params = Replace(Params, "{E}", ExeFile)
	Params = Replace(Params, "{D}", GetFolderName(ExeFile))
	If InStr(Params, "{|F}") > 0 Then
		Params = Replace(Params, "{|F}", "")
	ElseIf InStr(Params, "{F}") > 0 Then
		Params = Replace(Params, "{F}", FileName)
	ElseIf FileName <> "" Then
		Params &= " """ & FileName & """"
	End If
	Return Params
End Function

' Opens/focuses Item's own tab (creating it via AddTab if needed) and, for a Form
' node, auto-expands + populates its control tree. Shared by double-click activate
' and single-click open - assumes the caller has already ruled out anything that
' should instead launch externally (Shell/other-editor tools) or switch projects.
Sub OpenPlainFileTreeNode(ByRef Item As TreeNode, ee As ExplorerElement Ptr)
	Dim t As Boolean
	Dim As TabWindow Ptr tb
	Dim As TabControl Ptr ptabCode
	For j As Integer = 0 To TabPanels.Count - 1
		ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb->tn = @Item Then
				ptabCode->SelectedTabIndex = ptabCode->Tabs[i]->Index
				If tb->Des <> 0 AndAlso tb->CurrentView() = "Code" Then
					tb->ShowView("CodeAndForm")
				End If
				tb->txtCode.SetFocus
				t = True
				Exit For
			End If
		Next i
	Next j
	If Not t Then
		If ee <> 0 Then
			If InStr(WGet(ee->FileName), "\") = 0 AndAlso InStr(WGet(ee->FileName), "/") = 0 AndAlso WGet(ee->TemplateFileName) <> "" Then
				AddTab WGet(ee->TemplateFileName), True, @Item
			Else
				AddTab WGet(ee->FileName), , @Item
			End If
		End If
	End If
End Sub

Sub tvExplorer_NodeActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeNode)
	RestoreStatusText
	If Item.ImageKey = "Opened" Then Exit Sub
	If Item.ImageKey = "Project" AndAlso Item.ParentNode = 0 Then Exit Sub
	If Item.Name = "ProjectChangeLog" Then tpChangeLog->SelectTab : Exit Sub
	Dim As ExplorerElement Ptr ee = Item.Tag
	If ee <> 0 AndAlso ee->PendingDelete Then Exit Sub '' B1: about to be deleted on save, don't reopen
	If ee <> 0 Then
		If *ee Is TypeElement Then
			Dim As TypeElement Ptr te = Item.Tag
			If te->Tag <> 0 Then
				Dim As TabWindow Ptr tb = te->Tag
				If Not tb->IsSelected Then
					tb->SelectTab
				End If
				tb->txtCode.SetSelection te->StartLine, te->StartLine, te->StartChar, te->StartChar
			End If
			Exit Sub
		ElseIf *ee Is ControlTreeElement Then
			SelectControlTreeNode Cast(ControlTreeElement Ptr, ee)
			Exit Sub
		Else
			Dim As String extStr = LCase(Right(*ee->FileName, 4))
			If CBool(extStr = ".exe" OrElse extStr = ".dll"  OrElse extStr = ".png" OrElse extStr = ".jpg" OrElse extStr = ".bmp" OrElse extStr = ".ico" OrElse extStr = ".cur" OrElse extStr = ".gif" OrElse extStr = ".avi" OrElse _
				extStr = ".chm" OrElse extStr = ".zip" OrElse extStr = ".rar") OrElse EndsWith(LCase(*ee->FileName), ".dll.a") OrElse EndsWith(LCase(*ee->FileName), ".so") OrElse EndsWith(LCase(*ee->FileName), ".7z") Then
				Shell *ee->FileName
				'PipeCmd "", *ee->FileName
				Exit Sub
			ElseIf extStr = ".vfp" Then
				AddProject *ee->FileName
				WLet(RecentProject, *ee->FileName)
				tpProject->SelectTab
				Exit Sub
			End If
		End If
	End If
	OpenPlainFileTreeNode Item, ee
End Sub

' Single-click ("select") equivalent of NodeActivate, used from tvExplorer_SelChange.
' Deliberately narrower: only opens files that land in our own text/form editor.
' Anything NodeActivate would hand off externally (Shell-launch binaries/media)
' or that switches the active sub-project (.vfp) is skipped - those still
' require an explicit double-click, so a stray single click can't launch an
' external program or change projects.
Sub OpenTreeNodeOnSingleClick(ByRef Item As TreeNode)
	If Item.ImageKey = "Opened" Then Exit Sub
	If Item.ImageKey = "Project" Then Exit Sub
	Dim As ExplorerElement Ptr ee = Item.Tag
	If ee = 0 OrElse ee->FileName = 0 Then Exit Sub
	If ee->PendingDelete Then Exit Sub '' B1: about to be deleted on save, don't reopen
	If *ee Is TypeElement Then
		Dim As TypeElement Ptr te = Item.Tag
		If te->Tag <> 0 Then
			Dim As TabWindow Ptr tb = te->Tag
			If Not tb->IsSelected Then tb->SelectTab
			tb->txtCode.SetSelection te->StartLine, te->StartLine, te->StartChar, te->StartChar
		End If
		Exit Sub
	End If
	Dim As String extStr = LCase(Right(*ee->FileName, 4))
	If CBool(extStr = ".exe" OrElse extStr = ".dll"  OrElse extStr = ".png" OrElse extStr = ".jpg" OrElse extStr = ".bmp" OrElse extStr = ".ico" OrElse extStr = ".cur" OrElse extStr = ".gif" OrElse extStr = ".avi" OrElse _
		extStr = ".chm" OrElse extStr = ".zip" OrElse extStr = ".rar") OrElse EndsWith(LCase(*ee->FileName), ".dll.a") OrElse EndsWith(LCase(*ee->FileName), ".so") OrElse EndsWith(LCase(*ee->FileName), ".7z") OrElse extStr = ".vfp" Then
		Exit Sub
	End If
	OpenPlainFileTreeNode Item, ee
End Sub

Sub tvExplorer_NodeExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeNode, ByRef Cancel As Boolean)
	Dim As ExplorerElement Ptr ee = Item.Tag
	If ee = 0 Then Exit Sub
	If ee->FileName <> 0 AndAlso FolderExists(*ee->FileName) Then
		If bNotExpand Then Exit Sub
		bNotExpand = True
		ExpandFolder @Item
		bNotExpand = False
	ElseIf Item.ImageKey = "Form" Then
		ExpandFormControls Item
	End If
End Sub

Sub tvExplorer_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
	If tn = 0 Then Exit Sub
	tvExplorer_NodeActivate Designer, Sender, *tn
	'	If tn->ImageKey = "Project" Then Exit Sub
	'	Dim t As Boolean
	'	For i As Integer = 0 To ptabCode->TabCount - 1
	'		If Cast(TabWindow Ptr, ptabCode->Tabs[i])->tn = tn Then
	'			ptabCode->SelectedTabIndex = ptabCode->Tabs[i]->Index
	'			t = True
	'			Exit For
	'		End If
	'	Next i
	'	If Not t Then
	'		If tn->Tag <> 0 Then AddTab *Cast(ExplorerElement Ptr, tn->Tag)->FileName, , tn
	'	End If
	'	', Why the tvExplorer.SelectedNode changed after add tab
	'	tvExplorer.SelectedNode = tn
End Sub

'' Set while an arrow/paging key is moving the tree selection, so SelChange can tell a keyboard
'' move from a mouse click (ROADMAP 13.28 part 2). Selecting a node opens the file immediately,
'' which is right for a click and wrong for arrowing: a keyboard user walking the tree would open
'' every file passed over, and each open moves focus to the editor -- so the second arrow press
'' goes to the editor instead of the tree and navigation is over after one keystroke.
Dim Shared As Boolean bExplorerKeyboardMove

Sub tvExplorer_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	Select Case Key
	Case VK_RETURN
		'' Enter is the deliberate "open this" -- keep it, and let it open.
		bExplorerKeyboardMove = False
		tvExplorer_DblClick Designer, Sender
	Case VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_PRIOR, VK_NEXT
		bExplorerKeyboardMove = True
	End Select
End Sub

Function GetParentNode(tn As TreeNode Ptr) As TreeNode Ptr
	If tn = 0 OrElse tn->ParentNode = 0 Then
		Return tn
	ElseIf tn->ImageKey = "Project" Then 'tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement Then
		Return tn
	Else
		Return GetParentNode(tn->ParentNode)
	End If
End Function

Sub tvExplorer_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	DbgTrace("SelChange.enter", "tag=" & Str(CInt(Item.Tag <> 0)))
	Static OldParentNode As TreeNode Ptr
	Dim As ExplorerElement Ptr eeSel = Item.Tag
	If eeSel <> 0 AndAlso *eeSel Is ControlTreeElement Then
		SelectControlTreeNode Cast(ControlTreeElement Ptr, eeSel)
		Exit Sub
	End If
	' A single click on any real editable file node (Forms, Includes, Modules, ...)
	' opens it immediately, same as double-click would. An ARROW-KEY move does not: the user is
	' navigating, not choosing, and opening here would both open every file walked past and hand
	' focus to the editor, ending keyboard navigation after one keystroke (ROADMAP 13.28 part 2).
	' Enter still opens, through OnNodeActivate / tvExplorer_KeyDown.
	If bExplorerKeyboardMove Then
		'' Skip only the open -- the parent-node bookkeeping below still has to run, or the
		'' main-project tracking would silently stop updating while navigating by keyboard.
		bExplorerKeyboardMove = False
	Else
		DbgTrace("SelChange.beforeOpen", "")
		OpenTreeNodeOnSingleClick Item
		DbgTrace("SelChange.afterOpen", "")
	End If
	Dim As TreeNode Ptr ptn = tvExplorer.SelectedNode
	If ptn = 0 Then Exit Sub 'David Change For Safty
	ptn = GetParentNode(ptn)
	If ptn > 0 AndAlso OldParentNode <> ptn Then
		OldParentNode = ptn
		'If MainNode <> 0 Then MainNode->Bold = False
		'MainNode = ptn
		'lblLeft.Text = ML("Main Project") & ": " & MainNode->Text
		mLoadLog = False
		mLoadToDo = False
		If ptn->Tag > 0 Then
			Select Case Cast(ProjectElement Ptr, ptn->Tag)->ProjectFolderType
			Case ProjectFolderTypes.ShowWithFolders: miShowWithFolders->RadioItem = True
			Case ProjectFolderTypes.ShowWithoutFolders: miShowWithoutFolders->RadioItem = True
			Case ProjectFolderTypes.ShowAsFolder: miShowAsFolder->RadioItem = True
			End Select
		End If
		ChangeMenuItemsEnabled
		If ptn->ImageKey <> "Project" AndAlso ptn->ImageKey <> "MainProject" AndAlso ptn->ImageKey <> "Opened" Then  'David Change For compile Single .bas file Then
			'miSaveProject->Enabled = False
			'miSaveProjectAs->Enabled = False
			'miCloseProject->Enabled = False
			'miExplorerCloseProject->Enabled = False
			'miProjectProperties->Enabled = False
			'miExplorerProjectProperties->Enabled = False
			'			MainNode = 0
			'			lblLeft.Text = ML("Main Project") & ": " & ML("Automatic")
		Else
			'miSaveProject->Enabled = True
			'miSaveProjectAs->Enabled = True
			'miCloseProject->Enabled = True
			'miExplorerCloseProject->Enabled = True
			'miProjectProperties->Enabled = True
			'miExplorerProjectProperties->Enabled = True
			'			MainNode->ImageKey = "MainProject"
			'			MainNode->Bold = True
			If mApplyingWorkspaceLoad = False Then
				If tpChangeLog->IsSelected AndAlso Not mLoadLog Then
					If mChangeLogEdited AndAlso mChangelogName<> "" Then
						txtChangeLog.SaveToFile(mChangelogName)  ' David Change
						mChangeLogEdited = False
					End If
					mChangelogName = GetChangeLogPath(ptn)
					txtChangeLog.Text = "Waiting...... "
					If Dir(mChangelogName)<>"" AndAlso mChangelogName<> "" Then
						txtChangeLog.LoadFromFile(mChangelogName) ' David Change
						If InStr(txtChangeLog.Text,Chr(13,10)) < 1 Then txtChangeLog.Text = Replace(txtChangeLog.Text,Chr(10),Chr(13,10))
					Else
						txtChangeLog.Text = ""
					End If
					mLoadLog = True
				End If
				If tpToDo->IsSelected AndAlso Not mLoadToDo Then
					WLet(gSearchSave, WChr(84) + "ODO")
					ThreadCounter(ThreadCreate_(@FindSubProj, ptn))
					mLoadToDo = True
				End If
			End If
		End If
	End If
End Sub

Sub tvExplorer_MouseUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 1 Then Exit Sub
	Dim As TreeNode Ptr ptn, tn = tvExplorer.DraggedNode
	If tn = 0 Then
		tn = tvExplorer.SelectedNode
	Else
		tvExplorer.SelectedNode = tn
	End If
	If tn <> 0 AndAlso tn->ParentNode <> 0 Then
		ptn = GetParentNode(tn)
		If ptn->ImageKey <> "Project" Then
			miProjectProperties->Enabled = False
			miCloseProject->Enabled = False
			miDeleteProject->Enabled = False
		End If
		miSetAsMain->Caption = ("Set as Main")
		If tn->ImageKey = "Opened" Then
			miSetAsMain->Enabled = False
		End If
	Else
		miSetAsMain->Caption = ("Set as Start Up")
	End If
	Dim As String tmpKeyStr = " @Sub @StandartTypes @Property @Enum @EnumItem @Type @Function @Opened "
	Dim As ExplorerElement Ptr eeMenu
	If tn <> 0 Then eeMenu = tn->Tag
	If CInt(tn = 0) OrElse CInt(eeMenu <> 0 AndAlso *eeMenu Is ControlTreeElement) OrElse CInt(tn <> 0 AndAlso InStr(tmpKeyStr, " @" & tn->ImageKey & " ")) Then
		miSetAsMain->Enabled = IIf(tn <> 0 AndAlso tn->ParentNode <> 0, False, True)
		miRemoveFiles->Enabled = False
		miRemoveFiles->Caption = ("Delete File")
		miRemoveFiles->Name = "DeleteFile"
	ElseIf eeMenu <> 0 AndAlso eeMenu->PendingDelete Then
		'' B1: right-clicking a file already queued for deletion offers to undo it
		'' instead of a second, meaningless "Delete File".
		miSetAsMain->Enabled = False
		miRemoveFiles->Enabled = True
		miRemoveFiles->Caption = ("Cancel Deletion")
		miRemoveFiles->Name = "CancelFileDeletion"
	Else
		miSetAsMain->Enabled = True
		miRemoveFiles->Enabled = True
		miRemoveFiles->Caption = ("Delete File") & " " & tn->Text
		miRemoveFiles->Name = "DeleteFile"
	End If
End Sub

Sub tvExplorer_BeforeLabelEdit(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef NodeLabel As WString, ByRef Cancel As Boolean)
	If Not g_bAllowLabelEdit Then
		Cancel = True
		Exit Sub
	End If
	g_bAllowLabelEdit = False
	If Item.IsEmpty Then Exit Sub
	If Item.ImageKey = "Opened" Then
		Cancel = True
	ElseIf Item.Name = "ProjectChangeLog" Then
		Cancel = True '' synthesized node, not a real project file -- see EnsureChangeLogTreeNode
	End If
End Sub

Sub tvExplorer_AfterLabelEdit(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef NodeLabel As WString, ByRef Cancel As Boolean)
	If Item.IsEmpty Then Exit Sub
	If Item.ImageKey = "Opened" Then
		Cancel = True
	ElseIf Item.ImageKey = "Project" Then
		Dim As ProjectElement Ptr ppe = Item.Tag
		If ppe <> 0 AndAlso *ppe->FileName <> "" Then
			Dim As Boolean bModified = EndsWith(NodeLabel, "*")
			Dim As UString bFileName = GetFolderName(*ppe->FileName) & NodeLabel
			If bModified Then
				bFileName = Left(bFileName, Len(bFileName) - 1)
			End If
				If MoveFile(ppe->FileName, bFileName.vptr) = 0 Then
					MsgBox ("Renaming error!") & " " & GetErrorString(GetLastError, , True)
					Cancel = True
					Exit Sub
				End If
			WLet(ppe->FileName, bFileName)
		End If
	Else
		Dim As TabWindow Ptr tb = GetTabFromTn(@Item)
		Dim As TreeNode Ptr ptn = GetParentNode(@Item)
		Dim As ExplorerElement Ptr ee = Item.Tag
		Dim As Boolean bModified
		If ee <> 0 AndAlso *ee->FileName <> "" Then
			bModified = EndsWith(NodeLabel, "*")
			Dim As UString bFileName = GetFolderName(*ee->FileName) & NodeLabel
			If bModified Then
				bFileName = Left(bFileName, Len(bFileName) - 1)
			End If
			If InStr(*ee->FileName, Any ":\/") > 0 Then
					If MoveFile(ee->FileName, bFileName.vptr) = 0 Then
						MsgBox ("Renaming error!") & " " & GetErrorString(GetLastError, , True)
						Cancel = True
						Exit Sub
					End If
			End If
			If ptn <> 0 AndAlso ptn->ImageKey = "Project" Then
				Dim As ProjectElement Ptr pee = ptn->Tag
				If pee <> 0 Then
					If WGet(pee->MainFileName) = WGet(ee->FileName) Then WLet(pee->MainFileName, bFileName)
					If WGet(pee->ResourceFileName) = WGet(ee->FileName) Then WLet(pee->ResourceFileName, bFileName)
					If WGet(pee->IconResourceFileName) = WGet(ee->FileName) Then WLet(pee->IconResourceFileName, bFileName)
					If WGet(pee->BatchCompilationFileNameWindows) = WGet(ee->FileName) Then WLet(pee->BatchCompilationFileNameWindows, bFileName)
					If WGet(pee->BatchCompilationFileNameLinux) = WGet(ee->FileName) Then WLet(pee->BatchCompilationFileNameLinux, bFileName)
					If Not EndsWith(ptn->Text, "*") Then ptn->Text & = "*"
				End If
			End If
			WLet(ee->FileName, bFileName)
			If tb Then
				tb->FileName = bFileName
			End If
		End If
		If tb Then
			bModified = EndsWith(tb->Caption, "*")
			If bModified AndAlso Not EndsWith(NodeLabel, "*") Then
				tb->Caption = NodeLabel & "*"
			Else
				tb->Caption = NodeLabel
			End If
		End If
	End If
End Sub

tvExplorer.Images = @imgList
tvExplorer.SelectedImages = @imgList
tvExplorer.Align = DockStyle.alClient
tvExplorer.HideSelection = False
	tvExplorer.EditLabels = True
'tvExplorer.OnDblClick = @tvExplorer_DblClick
tvExplorer.OnNodeActivate = @tvExplorer_NodeActivate
tvExplorer.OnNodeExpanding = @tvExplorer_NodeExpanding
tvExplorer.OnMouseUp = @tvExplorer_MouseUp
tvExplorer.OnKeyDown = @tvExplorer_KeyDown
tvExplorer.OnSelChanged = @tvExplorer_SelChange
tvExplorer.OnBeforeLabelEdit = @tvExplorer_BeforeLabelEdit
tvExplorer.OnAfterLabelEdit = @tvExplorer_AfterLabelEdit
tvExplorer.ContextMenu = @mnuExplorer

Sub tabLeft_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewIndex As Integer)
	If bApplyingStartupLayout OrElse bClosing Then Exit Sub
	If NewIndex >= 0 AndAlso NewIndex < tabLeft.TabCount Then
		leftSelectedTabIndex = NewIndex
		iniSettings.WriteInteger("MainWindow", "LeftSelectedTab", leftSelectedTabIndex)
	End If
	If tabLeft.TabPosition = tpLeft And tabLeft.SelectedTabIndex <> -1 Then
		ShowLeft
	End If
End Sub

Sub tabLeft_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If tabLeft.TabPosition = tpLeft And tabLeft.SelectedTabIndex <> -1 Then
		ShowLeft
	End If
End Sub

Sub pnlLeft_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	If tabLeft.TabCount = 0 Then
		tabLeftWidth = NewWidth
	Else
		If tabLeft.SelectedTabIndex <> -1 Then tabLeftWidth = pnlLeft.Width
		If GetLeftClosedStyle Then UpdateLeftPinLayout()
	End If
End Sub

pnlLeft.Name = "pnlLeft"
pnlLeft.Align = DockStyle.alLeft
pnlLeft.Width = tabLeftWidth
pnlLeft.OnResize = @pnlLeft_Resize

tabLeft.Name = "tabLeft"
tabLeft.GroupName = "ToolWindow"
tabLeft.Width = tabLeftWidth
tabLeft.Align = DockStyle.alClient
tabLeft.Detachable = True
tabLeft.Reorderable = True
tabLeft.OnClick = @tabLeft_Click
tabLeft.OnDblClick = @tabLeft_DblClick
tabLeft.OnSelChange = @tabLeft_SelChange
pnlLeft.Add @tabLeft

Function AddToTabControl(ByRef Caption As WString, ByRef NameOfTabPage As WString, ByRef DefaultParent As WString = "", DefaultIndex As Integer = 0) As TabPage Ptr
	Dim As String Parent = iniSettings.ReadString("MainWindow", NameOfTabPage & "Parent", DefaultParent)
	Dim As Integer Index = iniSettings.ReadInteger("MainWindow", NameOfTabPage & "Index", DefaultIndex)
	If Parent = "" OrElse (Parent <> "tabLeft" AndAlso Parent <> "tabRight" AndAlso Parent <> "tabBottom") Then Parent = DefaultParent
	If Index < 0 Then Index = DefaultIndex
	Select Case Parent
	Case "tabLeft": Return tabLeft.InsertTab(Index, Caption)
	Case "tabRight": Return tabRight.InsertTab(Index, Caption)
	Case "tabBottom": Return tabBottom.InsertTab(Index, Caption)
	End Select
	Return 0
End Function


tpProject = AddToTabControl(("Project"), "Project", "tabLeft", 0)

tpToolbox = AddToTabControl(("Toolbox"), "Toolbox", "tabLeft", 1) ' ToolBox is better than "Form"
tpToolbox->Name = "Toolbox"

'' The left panel starts on Project, every time. This is the ONLY point at which Astoria
'' chooses that panel for the user -- nothing else selects Project or Toolbox on their
'' behalf, so whatever they pick stays picked until they pick something else.
''
'' The IDE used to jump to the Toolbox whenever a form view was applied, which included
'' re-applications the user never asked for: selecting Project, saving, and being thrown
'' back to the Toolbox. Reading a saved LeftSelectedTab has the same problem in slower
'' motion -- the panel a previous session happened to end on is not a choice for this one.
'' See ROADMAP 13.27.
leftSelectedTabIndex = 0

pnlLeftPin.Anchor.Right = AnchorStyle.asAnchor
pnlLeftPin.Top = tabItemHeight
pnlLeftPin.Width = tbLeft.Width
pnlLeftPin.Left = tabLeftWidth - pnlLeftPin.Width - 4
pnlLeftPin.Height = tbLeft.Height
pnlLeftPin.Parent = @pnlLeft

Function SetVisibleToTreeNode(Node As TreeNode Ptr, ByRef SearchText As WString) As Boolean
	Dim As Boolean bVisible
	If Node->Nodes.Count > 0 Then
		If SearchText = "" AndAlso (Node->ParentNode <> 0 OrElse Node->ImageKey <> "Project") Then
			Node->Collapse
		Else
			Node->Expand
		End If
	End If
	For i As Integer = 0 To Node->Nodes.Count - 1
		If SetVisibleToTreeNode(Node->Nodes.Item(i), SearchText) Then
			bVisible = True
		End If
	Next
	If Not bVisible Then
		bVisible = SearchText = "" OrElse InStr(LCase(Node->Text), SearchText) > 0
	End If
	Node->Visible = bVisible
	Return bVisible
End Function

Sub txtExplorer_Change(ByRef Designer As My.Sys.Object, Sender As TextBox)
	Dim As UString SearchText = Trim(LCase(txtExplorer.Text))
	For i As Integer = 0 To tvExplorer.Nodes.Count - 1
		SetVisibleToTreeNode(tvExplorer.Nodes.Item(i), SearchText)
	Next
	If SearchText <> "" Then
		tvExplorer.ExpandAll
	End If
End Sub

txtExplorer.OnChange = @txtExplorer_Change

lblLeft.Text = ("Main File") & ": " & ("Automatic")
lblLeft.Align = DockStyle.alBottom
lblLeft.Height = Max(8, DefaultFont.Size) / 72 * 96 + 5
tpProject->Add @tbExplorer
tpProject->Add @lblLeft
tpProject->Add @tvExplorer

pnlToolBox.Align = DockStyle.alClient
pnlToolBox.Add @tvToolBox
pnlToolBox.OnResize = @pnlToolBox_Resize

Sub txtForm_Change(ByRef Designer As My.Sys.Object, Sender As TextBox)
	Dim As UString SearchText = Trim(LCase(txtForm.Text))
	For i As Integer = 0 To tvToolBox.Nodes.Count - 1
		SetVisibleToToolBoxNode(tvToolBox.Nodes.Item(i), SearchText)
	Next
	If SearchText <> "" Then tvToolBox.ExpandAll
End Sub

txtForm.OnChange = @txtForm_Change

tpToolbox->Add @pnlToolBox 'tbToolBox
tpToolbox->Add @tbForm

'tpToolbox->Style = tpToolbox->Style Or ES_AUTOVSCROLL or WS_VSCROLL

'pnlLeft.Width = 153
'pnlLeft.Align = 1
'pnlLeft.AddRange 1, @tabLeft

Sub tbProperties_ButtonClick(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Select Case Sender.ToString
	Case "Properties"
		
	End Select
End Sub

tbRight.ImagesList = @imgList
tbRight.Buttons.Add tbsCheck, "Pinned", , @mClick, "PinRight", "", ("Pin"), True, Cast(ToolButtonState, tstEnabled Or tstChecked)
tbRight.Flat = True
tbRight.Width = 23
tbRight.Parent = @pnlRightPin

tbProperties.ImagesList = @imgList
tbProperties.Align = DockStyle.alTop
tbProperties.List = True
tbProperties.ExtraMargins.Right = tbRight.Width
tbProperties.Buttons.Add Cast(ToolButtonStyle, tbsCheck Or tbsAutosize), "Categorized", , @tbProperties_ButtonClick, "PropertyCategory", "", ("Categorized"), True, Cast(ToolButtonState, tstEnabled Or tstChecked)
tbProperties.Buttons.Add tbsSeparator
tbProperties.Buttons.Add tbsAutosize, "Property", , @tbProperties_ButtonClick, "Properties", "", ("Properties"), True, tstEnabled
tbProperties.Buttons.Add tbsShowText, "", , , "SelControlName", "", "", , ToolButtonState.tstNone
tbProperties.Buttons.Add tbsSeparator
Var PropertiesSearch = tbProperties.Buttons.Add(tbsCustom)
txtProperties.Width = 2
txtProperties.Hint = ("Search Properties")
PropertiesSearch->Child = @txtProperties
PropertiesSearch->Expand = True
tbProperties.Buttons.Add tbsSeparator
tbProperties.Flat = True

tbEvents.ImagesList = @imgList
tbEvents.Align = DockStyle.alTop
tbEvents.List = True
tbEvents.ExtraMargins.Right = tbRight.Width
tbEvents.Buttons.Add Cast(ToolButtonStyle, tbsAutosize Or tbsCheck), "Categorized", , @tbProperties_ButtonClick, "EventCategory", "", ("Categorized"), True, tstEnabled
tbEvents.Buttons.Add tbsSeparator
tbEvents.Buttons.Add tbsShowText, "", , , "SelControlName", "", "", , ToolButtonState.tstNone
tbEvents.Buttons.Add tbsSeparator
Var EventsSearch = tbEvents.Buttons.Add(tbsCustom)
txtEvents.Width = 2
txtEvents.Hint = ("Search Events")
EventsSearch->Child = @txtEvents
EventsSearch->Expand = True
tbEvents.Buttons.Add tbsSeparator
tbEvents.Flat = True

Sub txtPropertyValue_Activate(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	lvProperties.SetFocus
End Sub

Sub btnPropertyValue_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim As TypeElement Ptr te = Sender.Tag
	Select Case LCase(te->TypeName)
	Case "icon", "cursor", "bitmaptype", "graphictype"
		pfImageManager->WithoutMainNode = True
		If pfImageManager->ShowModal(*pfrmMain) = ModalResults.OK Then
			If pfImageManager->SelectedItem = 0 Then Exit Sub
			txtPropertyValue.Text = pfImageManager->SelectedItem->Text(0)
			PropertyChanged txtPropertyValue, txtPropertyValue.Text, False
		End If
		pfImageManager->WithoutMainNode = False
	Case "font"
		Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
		Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 OrElse st->WritePropertyFunc = 0 Then Exit Sub
		Dim As Any Ptr SelFont = txtPropertyValue.Tag
		If SelFont = 0 Then Exit Sub
		Dim As FontDialog fd
		Dim As WString * 255 FontName = QWString(st->ReadPropertyFunc(SelFont, "Name"))
		Dim As Integer FontColor = QInteger(st->ReadPropertyFunc(SelFont, "Color"))
		Dim As Integer FontSize = QInteger(st->ReadPropertyFunc(SelFont, "Size"))
		Dim As FontCharset FontCharset_ = QInteger(st->ReadPropertyFunc(SelFont, "Charset"))
		Dim As Boolean FontBold = QBoolean(st->ReadPropertyFunc(SelFont, "Bold"))
		Dim As Boolean FontItalic = QBoolean(st->ReadPropertyFunc(SelFont, "Italic"))
		Dim As Boolean FontUnderline = QBoolean(st->ReadPropertyFunc(SelFont, "Underline"))
		Dim As Boolean FontStrikeout = QBoolean(st->ReadPropertyFunc(SelFont, "Strikeout"))
		Dim As Integer FontOrientation = QInteger(st->ReadPropertyFunc(SelFont, "Orientation"))
		fd.Font.Name = FontName
		fd.Font.Color = FontColor
		fd.Font.Size = FontSize
		fd.Font.CharSet = FontCharset_
		fd.Font.Bold = FontBold
		fd.Font.Italic = FontItalic
		fd.Font.Underline = FontUnderline
		fd.Font.StrikeOut = FontStrikeout
		fd.Font.Orientation = FontOrientation
		If fd.Execute Then
			Dim As Integer SelCount = tb->Des->SelectedControls.Count
			'Dim As Boolean OnlySelected = Not tb->Des->SelectedControls.Contains(tb->Des->SelectedControl)
			'If OnlySelected Then SelCount = 1
			For i As Integer = 0 To SelCount - 1
				st = tb->Des->Symbols(tb->Des->SelectedControls.Item(i))
				If st = 0 OrElse st->ReadPropertyFunc = 0 OrElse st->WritePropertyFunc = 0 Then Continue For
				SelFont = st->ReadPropertyFunc(tb->Des->SelectedControls.Item(i), te->Name)
				If SelFont = 0 Then Continue For
				FontName = QWString(st->ReadPropertyFunc(SelFont, "Name"))
				FontColor = QInteger(st->ReadPropertyFunc(SelFont, "Color"))
				FontSize = QInteger(st->ReadPropertyFunc(SelFont, "Size"))
				FontCharset_ = QInteger(st->ReadPropertyFunc(SelFont, "Charset"))
				FontBold = QBoolean(st->ReadPropertyFunc(SelFont, "Bold"))
				FontItalic = QBoolean(st->ReadPropertyFunc(SelFont, "Italic"))
				FontUnderline = QBoolean(st->ReadPropertyFunc(SelFont, "Underline"))
				FontStrikeout = QBoolean(st->ReadPropertyFunc(SelFont, "Strikeout"))
				FontOrientation = QInteger(st->ReadPropertyFunc(SelFont, "Orientation"))
				If fd.Font.Name <> FontName Then FontName = fd.Font.Name: st->WritePropertyFunc(SelFont, "Name", @FontName): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Name")
				If fd.Font.Color <> FontColor Then FontColor = fd.Font.Color: st->WritePropertyFunc(SelFont, "Color", @FontColor): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Color")
				If fd.Font.Size <> FontSize Then FontSize = fd.Font.Size: st->WritePropertyFunc(SelFont, "Size", @FontSize): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Size")
				If fd.Font.CharSet <> FontCharset_ Then FontCharset_ = fd.Font.CharSet: st->WritePropertyFunc(SelFont, "Charset", @FontCharset_): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Charset")
				If fd.Font.Bold <> FontBold Then FontBold = fd.Font.Bold: st->WritePropertyFunc(SelFont, "Bold", @FontBold): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Bold")
				If fd.Font.Italic <> FontItalic Then FontItalic = fd.Font.Italic: st->WritePropertyFunc(SelFont, "Italic", @FontItalic): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Italic")
				If fd.Font.Underline <> FontUnderline Then FontUnderline = fd.Font.Underline: st->WritePropertyFunc(SelFont, "Underline", @FontUnderline): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Underline")
				If fd.Font.StrikeOut <> FontStrikeout Then FontStrikeout = fd.Font.StrikeOut: st->WritePropertyFunc(SelFont, "Strikeout", @FontStrikeout): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Strikeout")
				If fd.Font.Orientation <> FontOrientation Then FontOrientation = fd.Font.Orientation: st->WritePropertyFunc(SelFont, "Orientation", @FontOrientation): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Orientation")
			Next
			If st->ToStringFunc Then txtPropertyValue.Text = st->ToStringFunc(SelFont)
			If lvProperties.SelectedItem <> 0 Then lvProperties.SelectedItem->Text(1) = txtPropertyValue.Text
		End If
	Case Else
		Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
		Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 OrElse st->WritePropertyFunc = 0 Then Exit Sub
		Dim As ColorDialog cd
		cd.Color = Val(txtPropertyValue.Text)
		If cd.Execute Then
			txtPropertyValue.Text = Str(cd.Color)
			PropertyChanged(txtPropertyValue, txtPropertyValue.Text, False)
		End If
	End Select
End Sub

'txtPropertyValue.BorderStyle = 0
txtPropertyValue.Visible = False
txtPropertyValue.WantReturn = True
txtPropertyValue.OnActivate = @txtPropertyValue_Activate
txtPropertyValue.OnLostFocus = @txtPropertyValue_LostFocus

btnPropertyValue.Visible = False
btnPropertyValue.Text = "..."
btnPropertyValue.OnClick = @btnPropertyValue_Click

cboPropertyValue.OnActivate = @txtPropertyValue_Activate
cboPropertyValue.OnChange = @cboPropertyValue_Change
cboPropertyValue.Left = -1
cboPropertyValue.Top = -2

Sub pnlColor_Paint(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Canvas.Brush.Color = Val(txtPropertyValue.Text)
	'	SelectObject(Canvas.Handle, Canvas.Brush.Handle)
	'	Rectangle Canvas.Handle, 0, 0, 12, 12
	Canvas.Rectangle 0, 0, 12, 12
End Sub

pnlColor.SetBounds 3, 2, 12, 12
pnlColor.Visible = False
pnlColor.OnPaint = @pnlColor_Paint

pnlPropertyValue.Visible = False
pnlPropertyValue.Add @cboPropertyValue

'Dim Shared CtrlEdit As Control Ptr
Dim Shared Cpnt As Component Ptr
Sub lvProperties_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
	Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	Dim As Rect lpRect
	Dim As String PropertyName = GetItemText(Item)
	'Dim As TreeListViewItem Ptr Item = lvProperties.ListItems.Item(ItemIndex)
	'lvProperties.SetFocus
	pnlPropertyValue.Visible = False
	txtPropertyValue.Visible = False
	btnPropertyValue.Visible = False
	cboPropertyValue.Visible = False
	pnlColor.Visible = False
	ListView_GetSubItemRect(lvProperties.Handle, Item->GetItemIndex, 1, LVIR_BOUNDS, @lpRect)
	Var te = GetPropertyType(WGet(st->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), PropertyName)
	If te = 0 Then Exit Sub
	If LCase(te->TypeName) = "boolean" Then
		'CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Visible = True
		cboPropertyValue.Clear
		cboPropertyValue.AddItem " false"
		cboPropertyValue.AddItem " true"
		bNotChange = True
		cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Trim(Item->Text(1)))
	ElseIf LCase(te->TypeName) = "integer" AndAlso CInt(te->EnumTypeName <> "") AndAlso CInt(Globals.Enums.Contains(te->EnumTypeName)) Then
		'CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Visible = True
		cboPropertyValue.Clear
		Var tbi = Cast(TypeElement Ptr, Globals.Enums.Object(Globals.Enums.IndexOf(te->EnumTypeName)))
		If tbi Then
			For i As Integer = 0 To tbi->Elements.Count - 1
				cboPropertyValue.AddItem " " & i & " - " & (tbi->Elements.Item(i))
			Next i
			If Val(Item->Text(1)) >= 0 AndAlso Val(Trim(Item->Text(1))) <= tbi->Elements.Count - 1 Then
				bNotChange = True
				cboPropertyValue.ItemIndex = Val(Trim(Item->Text(1)))
			End If
		End If
	ElseIf GetTypeIsPointer(te) AndAlso IsBase(te->TypeName, "My.Sys.Object") Then
		'CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Visible = True
		cboPropertyValue.Clear
		cboPropertyValue.AddItem " " & ("(None)")
		For i As Integer = 1 To tb->cboClass.Items.Count - 1
			Cpnt = tb->cboClass.Items.Item(i)->Object
			If Cpnt <> 0 Then
				Dim As SymbolsType Ptr st = tb->Des->Symbols(Cpnt)
				If st AndAlso st->ReadPropertyFunc Then
					If CInt(te->EnumTypeName <> "") Then
						If IsBase(WGet(st->ReadPropertyFunc(Cpnt, "ClassName")), Trim(te->EnumTypeName)) Then
							cboPropertyValue.AddItem " " & WGet(st->ReadPropertyFunc(Cpnt, "Name"))
						End If
					ElseIf IsBase(WGet(st->ReadPropertyFunc(Cpnt, "ClassName")), GetOriginalType(WithoutPointers(Trim(te->TypeName)))) Then
						cboPropertyValue.AddItem " " & WGet(st->ReadPropertyFunc(Cpnt, "Name"))
					End If
				End If
			End If
		Next i
		bNotChange = True
		cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Item->Text(1))
	Else
		Dim tbi As TypeElement Ptr = 0
		If Comps.Contains(te->TypeName) Then
			tbi = Cast(TypeElement Ptr, Comps.Object(Comps.IndexOf(te->TypeName)))
		ElseIf Globals.Enums.Contains(te->TypeName) Then
			tbi = Cast(TypeElement Ptr, Globals.Enums.Object(Globals.Enums.IndexOf(te->TypeName)))
		End If
		If tbi <> 0 AndAlso tbi->ElementType = E_Enum Then
			'CtrlEdit = @pnlPropertyValue
			cboPropertyValue.Visible = True
			cboPropertyValue.Clear
			For i As Integer = 0 To tbi->Elements.Count - 1
				cboPropertyValue.AddItem " " & i & " - " & (tbi->Elements.Item(i))
			Next i
			If Val(Trim(Item->Text(1))) >= 0 AndAlso Val(Trim(Item->Text(1))) <= tbi->Elements.Count - 1 Then
				bNotChange = True
				cboPropertyValue.ItemIndex = Val(Trim(Item->Text(1)))
			End If
		Else
			'CtrlEdit = @txtPropertyValue
			'CtrlEdit->Text = Item->Text(1)
			txtPropertyValue.Text = Item->Text(1)
			txtPropertyValue.Visible = True
		End If
	End If
	Dim As String teTypeName = LCase(te->TypeName)
	pnlPropertyValue.SetBounds pnlPropertyValue.UnScaleX(lpRect.Left), pnlPropertyValue.UnScaleY(lpRect.Top), pnlPropertyValue.UnScaleX(lpRect.Right - lpRect.Left), pnlPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top - 1)
	txtPropertyValue.LeftMargin = 3
	If CInt(teTypeName = "icon") OrElse CInt(teTypeName = "cursor") OrElse CInt(teTypeName = "bitmaptype") OrElse CInt(teTypeName = "graphictype") OrElse CInt(teTypeName = "font") OrElse CInt(EndsWith(LCase(PropertyName), "color")) Then
		btnPropertyValue.SetBounds btnPropertyValue.UnScaleX(lpRect.Right - lpRect.Left) - btnPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1 - 1, -1, btnPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1 + 2, btnPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1 + 2
		txtPropertyValue.SetBounds 0, 0, txtPropertyValue.UnScaleX(lpRect.Right - lpRect.Left) - txtPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1, txtPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1
		'CtrlEdit->SetBounds UnScaleX(lpRect.Left), UnScaleY(lpRect.Top), UnScaleX(lpRect.Right - lpRect.Left) - btnPropertyValue.Width + UnScaleX(2), UnScaleY(lpRect.Bottom - lpRect.Top - 1)
		btnPropertyValue.Visible = True
		btnPropertyValue.Tag = te
		If teTypeName = "font" Then
			txtPropertyValue.Tag = st->ReadPropertyFunc(tb->Des->SelectedControl, te->Name)
		ElseIf EndsWith(LCase(PropertyName), "color") Then
			pnlColor.BackColor = Val(Trim(Item->Text(1)))
			pnlColor.Visible = True
			txtPropertyValue.LeftMargin = 16
		End If
	Else
		txtPropertyValue.SetBounds 0, 0, txtPropertyValue.UnScaleX(lpRect.Right - lpRect.Left), txtPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1
		cboPropertyValue.Width = cboPropertyValue.UnScaleX(lpRect.Right - lpRect.Left) + 2
		'CtrlEdit->SetBounds UnScaleX(lpRect.Left), UnScaleY(lpRect.Top), UnScaleX(lpRect.Right - lpRect.Left), UnScaleY(lpRect.Bottom - lpRect.Top - 1)
	End If
	'If CtrlEdit = @pnlPropertyValue Then cboPropertyValue.Width = UnScaleX(lpRect.Right - lpRect.Left + 2)
	'CtrlEdit->Visible = True
	pnlPropertyValue.Visible = True
	'#endif
	'If te->Comment <> 0 Then
	If LCase(App.CurLanguage) = "default" Then
		txtLabelProperty.TextRTF = "{\urtf1\b " & GetItemText(Item) & "\b0\par " & te->Comment & "}"
	Else
		txtLabelProperty.TextRTF = "{\urtf1\b " & Replace((GetItemText(Item)), !"\r\n", "\b0\par ") & "}"
	End If
	'Else
	'	txtLabelProperty.Text = ""
	'End If
End Sub

Sub lvEvents_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
	Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	Var te = GetPropertyType(WGet(st->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), GetItemText(Item))
	'If te = 0 Then Exit Sub
	'If te->Comment <> 0 Then
	If LCase(App.CurLanguage) = "default" Then
		txtLabelEvent.TextRTF = "{\urtf1\b " & Item->Text(0) & "\b0\par " & te->Comment & "}"
	Else
		txtLabelEvent.TextRTF = "{\urtf1\b " & Replace((Item->Text(0)), !"\r\n", "\b0\par ") & "}"
	End If
	'Else
	'	txtLabelEvent.Text = ""
	'End If
End Sub

'Sub lvProperties_ItemDblClick(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
'    If Item <> 0 Then ClickProperty Item->Index
'End Sub

Sub lvEvents_ItemDblClick(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Dim As TabWindow Ptr tb = tabRight.Tag
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
	If Item <> 0 Then FindEvent tb, tb->Des->SelectedControl, Item->Text(0)
End Sub

Sub lvProperties_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView)
	'If CtrlEdit = 0 Then Exit Sub
	If lvProperties.SelectedItem = 0 Then
		'CtrlEdit->Visible = False
		pnlPropertyValue.Visible = False
	Else
		Dim As Rect lpRect
		ListView_GetSubItemRect(lvProperties.Handle, lvProperties.SelectedItem->GetItemIndex, 1, LVIR_BOUNDS, @lpRect)
		pnlPropertyValue.SetBounds pnlPropertyValue.UnScaleX(lpRect.Left), pnlPropertyValue.UnScaleY(lpRect.Top), pnlPropertyValue.UnScaleX(lpRect.Right - lpRect.Left), pnlPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top - 1)
		pnlPropertyValue.Visible = True
		'CtrlEdit->Visible = True
		'End If
	End If
End Sub

Dim Shared lvWidth As Integer

Sub lvProperties_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	lvWidth = lvProperties.Width - 22
	lvProperties.Columns.Column(1)->Width = (lvWidth - 32) / 2
	lvProperties.Columns.Column(0)->Width = lvWidth - (lvWidth - 32) / 2
	txtPropertyValue.Width = (lvWidth - 32) / 2
	pnlPropertyValue.Width = (lvWidth - 32) / 2
	cboPropertyValue.Width = (lvWidth - 32) / 2 + 2
	lvProperties_EndScroll(*Sender.Designer, *Cast(TreeListView Ptr, @Sender))
End Sub

Sub lvEvents_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	lvWidth = lvEvents.Width - 22
	lvEvents.Columns.Column(0)->Width = lvWidth / 2
	lvEvents.Columns.Column(1)->Width = lvWidth / 2
	'lvEvents_EndScroll(*Cast(ListView Ptr, @Sender))
End Sub


Sub lvEvents_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeListViewItem Ptr)
	
End Sub

Sub lvProperties_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
	txtPropertyValue.Text = WChr(Key)
	txtPropertyValue.SetFocus
	txtPropertyValue.SetSel 1, 1
	Key = 0
End Sub

Sub lvProperties_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	Select Case Key
	Case VK_RETURN: txtPropertyValue.SetFocus
	Case VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR
	End Select
	'Key = 0
End Sub

Sub lvProperties_DrawItem(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ItemAction As Integer, ItemState As Integer, ByRef R As My.Sys.Drawing.Rect, ByRef Canvas As My.Sys.Drawing.Canvas)
	If Item = 0 Then Exit Sub
		Dim As ..Rect rc = *Cast(..Rect Ptr, @R)
		rc.Left += Sender.ScaleX(40 + Item->Indent * 16)
		If ItemAction = 17 Then                       'if selected Then
			FillRect Canvas.Handle, @rc, GetSysColorBrush(COLOR_HIGHLIGHT)
			SetBkColor Canvas.Handle, GetSysColor(COLOR_HIGHLIGHT)                    'Set text Background
			SetTextColor Canvas.Handle, GetSysColor(COLOR_HIGHLIGHTTEXT)                'Set text color
			If Sender.SelectedItem = Item AndAlso Sender.Focused Then
				DrawFocusRect Canvas.Handle, @rc  'draw focus rectangle
			End If
			lvProperties_EndScroll(Designer, Sender)
		Else
			FillRect Canvas.Handle, @rc, GetSysColorBrush(COLOR_WINDOW)
			SetBkColor Canvas.Handle, GetSysColor(COLOR_WINDOW)
			SetTextColor Canvas.Handle, GetSysColor(COLOR_WINDOWTEXT)
		End If
		'DRAW TEXT
		Dim zTxt As WString * 64
		Dim iIndent As Integer
		Dim l As Integer
		rc.Top = R.Top + Sender.ScaleX(2)
		For i As Integer = 0 To Sender.Columns.Count - 1
			If i = 1 AndAlso EndsWith(LCase(Item->Text(0)), "color") Then
				Canvas.Brush.Color = Val(Item->Text(1))
				SelectObject(Canvas.Handle, Canvas.Brush.Handle)
				Rectangle Canvas.Handle, rc.Left, R.Top + Sender.ScaleY(2), rc.Left + Sender.ScaleX(13 - 1), R.Top + Sender.ScaleY(1 + 13)
				rc.Left += Sender.ScaleX(13 + 3)
			Else
				rc.Left += Sender.ScaleX(3)
			End If
			rc.Right = l + Sender.ScaleX(Sender.Columns.Column(i)->Width)
			zTxt = Item->Text(i)
			iIndent = Item->Indent
			DrawText Canvas.Handle, @zTxt, Len(zTxt), @rc, DT_END_ELLIPSIS     'Draw text
			'TextOut Canvas.Handle, R.Left + IIf(i = 0, 40, l + 3) + 3 + IIf(i = 0, iIndent * 16, 0), R.Top + 2, @zTxt, Len(zTxt)     'Draw text
			If i = 0 Then
				'DRAW IMAGE
				If Sender.StateImages AndAlso Sender.StateImages->Handle AndAlso Item->State > 0 Then
					ImageList_Draw(Sender.StateImages->Handle, Item->State - 1, Canvas.Handle, R.Left + Sender.ScaleX(iIndent * 16 + 3), R.Top, ILD_TRANSPARENT)
				End If
				If Sender.Images AndAlso Sender.Images->Handle Then
					ImageList_Draw(Sender.Images->Handle, Item->ImageIndex, Canvas.Handle, R.Left + Sender.ScaleX(iIndent * 16 + 24), R.Top, ILD_TRANSPARENT)
				End If
			End If
			l += Sender.ScaleX(Sender.Columns.Column(i)->Width)
			rc.Left = l + Sender.ScaleX(3)
		Next
End Sub

imgListStates.Add "Collapsed", "Collapsed"
imgListStates.Add "Expanded", "Expanded"
imgListStates.Add "Property", "Property"
imgListStates.Add "Event", "Event"

lvProperties.Align = DockStyle.alClient
'lvProperties.Sort = ssSortAscending
lvProperties.StateImages = @imgListStates
lvProperties.Images = @imgListStates
'lvProperties.ColumnHeaderHidden = True
lvProperties.Columns.Add ("Property"), , 70
lvProperties.Columns.Add ("Value"), , 50, , True
pnlPropertyValue.Add @btnPropertyValue
pnlPropertyValue.Add @txtPropertyValue
pnlPropertyValue.Add @pnlColor
lvProperties.Add @pnlPropertyValue
lvProperties.OwnerDraw = True
lvProperties.OnDrawItem = @lvProperties_DrawItem
lvProperties.OnSelectedItemChanged = @lvProperties_SelectedItemChanged
lvProperties.OnEndScroll = @lvProperties_EndScroll
lvProperties.OnResize = @lvProperties_Resize
'lvProperties.OnMouseDown = @lvProperties_MouseDown
'lvProperties.OnKeyDown = @lvProperties_KeyDown
'lvProperties.OnItemDblClick = @lvProperties_ItemDblClick
lvProperties.OnKeyUp = @lvProperties_KeyUp
lvProperties.OnCellEditing = @lvProperties_CellEditing
lvProperties.OnCellEdited = @lvProperties_CellEdited
lvProperties.OnItemExpanding = @lvProperties_ItemExpanding
lvEvents.Align = DockStyle.alClient
lvEvents.SortOrder = ssSortAscending
lvEvents.Columns.Add ("Event"), , 70
lvEvents.Columns.Add ("Value"), , -2
lvEvents.OnSelectedItemChanged = @lvEvents_SelectedItemChanged
lvEvents.OnItemKeyDown = @lvEvents_KeyDown
lvEvents.OnItemDblClick = @lvEvents_ItemDblClick
lvEvents.OnResize = @lvEvents_Resize
lvEvents.Images = @imgListStates

splProperties.Align = SplitterAlignmentConstants.alBottom

splEvents.Align = SplitterAlignmentConstants.alBottom

txtLabelProperty.Height = Max(8, DefaultFont.Size) / 72 * 96 * 4 + 5
txtLabelProperty.Align = DockStyle.alBottom
txtLabelProperty.Multiline = True
txtLabelProperty.ReadOnly = True
txtLabelProperty.BackColor = clBtnFace
txtLabelProperty.WordWraps = True

txtLabelEvent.Height = Max(8, DefaultFont.Size) / 72 * 96 * 4 + 5
txtLabelEvent.Align = DockStyle.alBottom
txtLabelEvent.Multiline = True
txtLabelEvent.ReadOnly = True
txtLabelEvent.BackColor = clBtnFace
txtLabelEvent.WordWraps = True

Function GetRightClosedStyle As Boolean
	Return Not tabRight.TabPosition = tpTop
End Function

Function IsRightCollapsed As Boolean
	Return tabRight.TabPosition = tpRight And tabRight.SelectedTabIndex = -1
End Function

Sub SetRightClosedStyle(Value As Boolean, WithClose As Boolean = True)
	If bClosing Then Exit Sub
	bClosing = True
	With *tbRight.Buttons.Item("PinRight")
		If Value Then
			tabRight.TabPosition = tpRight
			.ImageKey = "Pin"
			.Checked = False
			pnlRightPin.Anchor.Right = AnchorStyle.asNone
			pnlRightPin.Align = DockStyle.alTop
			pnlRightPin.Height = tbRight.Height
			pnlRightPin.Visible = True
			If WithClose Then CloseRight
		Else
			tabRight.TabPosition = tpTop
			tabRight.Width = tabRightWidth
			pnlRight.Width = tabRightWidth
			'pnlRight.RequestAlign
			splRight.Visible = True
			pnlRightPin.Align = DockStyle.alNone
			pnlRightPin.Width = tbRight.Width
			pnlRightPin.Height = tbRight.Height
			pnlRightPin.Visible = True
			.ImageKey = "Pinned"
			.Checked = True
			pnlRightPin.Top = tabItemHeight
			pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - 4
			If rightSelectedTabIndex >= 0 AndAlso rightSelectedTabIndex < tabRight.TabCount Then tabRight.SelectedTabIndex = rightSelectedTabIndex
		End If
	End With
	frmMain.RequestAlign
	bClosing = False
End Sub

Sub tabRight_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	SetRightClosedStyle Not GetRightClosedStyle
End Sub

Sub tabRight_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewIndex As Integer)
	If bApplyingStartupLayout OrElse bClosing Then Exit Sub
	If NewIndex >= 0 AndAlso NewIndex < tabRight.TabCount Then
		rightSelectedTabIndex = NewIndex
		iniSettings.WriteInteger("MainWindow", "RightSelectedTab", rightSelectedTabIndex)
	End If
	If tabRight.TabPosition = tpRight And tabRight.SelectedTabIndex <> -1 Then
		ShowRight
		'		tabRight.SetFocus
		'		pnlRight.Width = tabRightWidth
		'		pnlRight.RequestAlign
		'		splRight.Visible = True
		'		frmMain.RequestAlign
	End If
End Sub

tvVar.Visible = False
tvVar.Align = DockStyle.alClient

Sub tvPrc_NodeActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeNode)
End Sub

tvPrc.Align = DockStyle.alClient
tvPrc.ContextMenu = @mnuProcedures
tvPrc.OnNodeActivate = @tvPrc_NodeActivate
tvThd.Visible = False
tvThd.Align = DockStyle.alClient
tvWch.ContextMenu = @mnuWatch
tvWch.Visible = False
tvWch.Align = DockStyle.alClient
tvWch.EditLabels = True
tvWch.Nodes.Add

Sub lvThreads_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Val(Item->Text(1)) = 0 Then Exit Sub
	SelectSearchResult(Item->Text(2), Val(Item->Text(1)))
End Sub

lvThreads.Align = DockStyle.alClient
lvThreads.Columns.Add ("Procedure"), , 500
lvThreads.Columns.Add ("Line"), , 50
lvThreads.Columns.Add ("File"), , 500
'lvThreads.StateImages = @imgListStates
lvThreads.Images = @imgListStates
lvThreads.OnItemActivate = @lvThreads_ItemActivate

Sub tvVar_Message(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef message As Message)
End Sub

tvVar.ContextMenu = @mnuVars
tvVar.OnMessage = @tvVar_Message

Sub lvVar_ItemExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item AndAlso Item->Nodes.Count > 0 AndAlso Item->Nodes.Item(0)->Text(0) = "" Then
		ptabBottom->UpdateLock
		Dim lvItem As TreeListViewItem Ptr
		Dim As WString Ptr p = @Item->Text(1)
		Dim As UString sText
		Dim As Boolean b
		Dim As Integer iCount, Pos1, Pos2
		Item->Nodes.Clear
		For i As Integer = 1 To Len(*p) - 1
			If (*p)[i] = Asc("{") Then
				iCount += 1
				b = True
			ElseIf b AndAlso (*p)[i] = Asc("}") Then
				iCount -= 1
				If iCount = 0 Then b = False
			ElseIf CInt(Not b) AndAlso CInt((*p)[i] = Asc(",") OrElse (*p)[i] = Asc("}")) Then
				Pos1 = InStr(sText, "=")
				If Pos1 > 0 Then
					lvItem = Item->Nodes.Add(Trim(Left(sText, Pos1 - 1)))
				Else
					lvItem = Item->Nodes.Add(Str(Item->Nodes.Count))
				End If
				lvItem->Text(1) = Trim(Mid(sText, Pos1 + 1))
				Pos1 = InStr(sText, "<vtable for ")
				Pos2 = InStr(sText, "+")
				If Pos1 > 0 AndAlso Pos2 > 0 Then
					lvItem->Text(2) = Replace(Mid(sText, Pos1 + 12, Pos2 - Pos1 - 12), "::", ".")
				End If
				If StartsWith(lvItem->Text(1), "{") Then
					lvItem->Nodes.Add
				End If
				sText = ""
				Continue For
			End If
			If (*p)[i] <> 13 AndAlso (*p)[i] <> 10 Then
				sText &= WChr((*p)[i])
			End If
		Next
		'Item->Nodes.Remove 0
		ptabBottom->UpdateUnLock
	End If
End Sub

lvLocals.Align = DockStyle.alClient
lvLocals.ContextMenu = @mnuVars
lvLocals.EditLabels = True
lvLocals.Columns.Add ("Variable"), , 150
lvLocals.Columns.Add ("Value"), , 500
lvLocals.Columns.Add ("Type"), , 500
lvLocals.Columns.Column(1)->Editable = True
'lvLocals.StateImages = @imgListStates
lvLocals.Images = @imgListStates
lvLocals.OnItemExpanding = @lvVar_ItemExpanding

lvGlobals.Align = DockStyle.alClient
lvGlobals.ContextMenu = @mnuVars
lvGlobals.EditLabels = True
lvGlobals.Columns.Add ("Variable"), , 150
lvGlobals.Columns.Add ("Value"), , 500
lvGlobals.Columns.Add ("Type"), , 500
lvGlobals.Columns.Column(1)->Editable = True
'lvGlobals.StateImages = @imgListStates
lvGlobals.Images = @imgListStates
lvGlobals.OnItemExpanding = @lvVar_ItemExpanding

Sub lvWatches_CellEditing(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, CellEditor As Control Ptr, ByRef Cancel As Boolean)
	If Item = 0 Then Exit Sub
	If SubItemIndex > 0 Then Exit Sub
	If Item->ParentItem > 0 Then
		Cancel = True
	End If
End Sub

Sub lvWatches_CellEdited(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString, ByRef Cancel As Boolean)
	If Item = 0 Then Exit Sub
	If SubItemIndex > 0 Then Exit Sub
	If NewText = "" Then
		WatchIndex = -1
		If Item->Index <> lvWatches.Nodes.Count - 1 Then
			lvWatches.Nodes.Remove Item->Index
		End If
	Else
		WatchIndex = Item->Index
		command_debug "print " & ResolveWatchGdbName(NewText, gRawLocals)
		If Item->Index = lvWatches.Nodes.Count - 1 Then
			lvWatches.Nodes.Add
		End If
	End If
	If lvWatches.Nodes.Count = 1 Then
		tpWatches->Caption = ("Watches")
	Else
		tpWatches->Caption = ("Watches") & " (" & Str(lvWatches.Nodes.Count - 1) & " " & ("Pos") & ")"
	End If
	SnapshotWatchNames()   ' DR-3 2D: keep the worker-visible watch snapshot in sync
End Sub

lvProblems.ContextMenu = @mnuProblems

lvWatches.Align = DockStyle.alClient
lvWatches.ContextMenu = @mnuVars
lvWatches.EditLabels = True
lvWatches.Columns.Add ("Variable"), , 150
lvWatches.Columns.Add ("Value"), , 500
lvWatches.Columns.Add ("Type"), , 500
lvWatches.Columns.Column(0)->Editable = True
lvWatches.Columns.Column(1)->Editable = True
'lvWatches.StateImages = @imgListStates
lvWatches.Images = @imgListStates
lvWatches.OnItemExpanding = @lvVar_ItemExpanding
lvWatches.OnCellEditing = @lvWatches_CellEditing
lvWatches.OnCellEdited = @lvWatches_CellEdited
lvWatches.Nodes.Add

lvMemory.Align = DockStyle.alClient
lvMemory.ContextMenu = @mnuVars
lvMemory.Columns.Add ("Address / delta"), , 150
lvMemory.Columns.Add ("Ascii value"), , 150
'lvMemory.StateImages = @imgListStates
lvMemory.Images = @imgListStates

Sub lvProfiler_ItemExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item AndAlso Item->Nodes.Count = 0 Then 'AndAlso Item->Nodes.Item(0)->Text(0) = "" Then
		ptabBottom->UpdateLock
		Item->Nodes.Clear
		Var Idx = ProfilingFunctions.IndexOf(Item->Text(0))
		Dim As TreeListViewItem Ptr tlvi, parenttlvi
		If Idx > -1 Then
			Dim As ProfilingFunction Ptr pfuncitem, pfunc = ProfilingFunctions.Object(Idx)
			parenttlvi = Item->Nodes.Add(ProfilingFunctions.Item(Idx), , 1)
			parenttlvi->Text(1) = pfunc->Count
			parenttlvi->Text(2) = pfunc->Time
			parenttlvi->Text(3) = pfunc->Total
			parenttlvi->Text(4) = pfunc->Proc
			parenttlvi->Text(5) = pfunc->Mangled
			For i As Integer = 0 To pfunc->Items.Count - 1
				pfuncitem = pfunc->Items.Object(i)
				tlvi = parenttlvi->Nodes.Add(pfunc->Items.Item(i), , 1)
				tlvi->Text(1) = pfuncitem->Count
				tlvi->Text(2) = pfuncitem->Time
				tlvi->Text(3) = pfuncitem->Total
				tlvi->Text(4) = pfuncitem->Proc
				tlvi->Text(5) = pfuncitem->Mangled
				'tlvi->Nodes.Add
			Next
		End If
		ptabBottom->UpdateUnLock
	End If
End Sub

Sub lvProfiler_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item = 0 Then Exit Sub
	Dim As String ItemText = Item->Text(0), FuncName
	Var Pos1 = InStr(ItemText, "(")
	If Pos1 > 0 Then ItemText = Left(ItemText, Pos1 - 1)
	Pos1 = InStr(ItemText, " [")
	If Pos1 > 0 Then ItemText = Left(ItemText, Pos1 - 1)
	Pos1 = InStrRev(ItemText, ".")
	If Pos1 > 0 Then
		FuncName = Mid(ItemText, Pos1 + 1)
	Else
		FuncName = ItemText
	End If
	Dim As TypeElement Ptr te
	Dim As Boolean bFinded
	Var Idx = pGlobalTypeProcedures->IndexOf(FuncName)
	If Idx <> -1 Then
		For i As Integer = Idx To pGlobalTypeProcedures->Count - 1
			If UCase(pGlobalTypeProcedures->Item(i)) <> UCase(FuncName) Then Exit For
			te = pGlobalTypeProcedures->Object(i)
			If UCase(te->FullName) = UCase(ItemText) Then
				bFinded = True
				Exit For
			End If
		Next
	End If
	If Not bFinded Then
		Var Idx = pGlobalFunctions->IndexOf(FuncName)
		If Idx <> -1 Then
			For i As Integer = Idx To pGlobalFunctions->Count - 1
				If UCase(pGlobalFunctions->Item(i)) <> UCase(FuncName) Then Exit For
				te = pGlobalFunctions->Object(i)
				If UCase(te->FullName) = UCase(ItemText) Then
					bFinded = True
					If Not te->Declaration Then Exit For
				End If
			Next
		End If
	End If
	If bFinded Then
		SelectSearchResult(te->FileName, te->StartLine + 2, 0, 0)
	End If
End Sub

lvProfiler.Align = DockStyle.alClient
lvProfiler.OwnerData = True
lvProfiler.Columns.Add ("Function"), , 500
lvProfiler.Columns.Add ("Count"), , 100, ColumnFormat.cfRight
lvProfiler.Columns.Add ("Time"), , 100, ColumnFormat.cfRight
lvProfiler.Columns.Add ("Total, %"), , 100, ColumnFormat.cfRight
lvProfiler.Columns.Add ("Proc, %"), , 100, ColumnFormat.cfRight
lvProfiler.Columns.Add ("Mangled"), , 500
lvProfiler.StateImages = @imgListStates
lvProfiler.Images = @imgListStates
lvProfiler.OnItemExpanding = @lvProfiler_ItemExpanding
lvProfiler.OnItemActivate = @lvProfiler_ItemActivate

Sub tabRight_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If tabRight.TabPosition = tpRight And tabRight.SelectedTabIndex <> -1 Then
		ShowRight
		'		tabRight.SetFocus
		'		pnlRight.Width = tabRightWidth
		'		pnlRight.RequestAlign
		'		splRight.Visible = True
		'		frmMain.RequestAlign
	End If
End Sub

Sub pnlRight_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	If tabRight.TabCount = 0 Then
		tabRightWidth = NewWidth
	Else
		If tabRight.SelectedTabIndex <> -1 Then tabRightWidth = tabRight.Width: If GetRightClosedStyle Then pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - tabItemHeight
	End If
End Sub

pnlRight.Align = DockStyle.alRight
pnlRight.Width = tabRightWidth
pnlRight.OnResize = @pnlRight_Resize

tabRight.Name = "tabRight"
tabRight.GroupName = "ToolWindow"
tabRight.Width = tabRightWidth
tabRight.Align = DockStyle.alClient
tabRight.OnClick = @tabRight_Click
tabRight.OnDblClick = @tabRight_DblClick
tabRight.OnSelChange = @tabRight_SelChange
tabRight.Detachable = True
tabRight.Reorderable = True
'tabRight.TabPosition = tpRight
tpProperties = AddToTabControl(("Properties"), "Properties", "tabRight", 0)
tpProperties->Add @tbProperties
tpProperties->Add @txtLabelProperty
tpProperties->Add @splProperties
tpProperties->Add @lvProperties
tpEvents = AddToTabControl(("Events"), "Events", "tabRight", 1)
tpEvents->Add @tbEvents
tpEvents->Add @txtLabelEvent
tpEvents->Add @splEvents
tpEvents->Add @lvEvents
rightSelectedTabIndex = iniSettings.ReadInteger("MainWindow", "RightSelectedTab", 0)
If rightSelectedTabIndex < 0 OrElse rightSelectedTabIndex >= tabRight.TabCount Then rightSelectedTabIndex = 0
pnlRight.Add @tabRight

pnlRightPin.Anchor.Right = AnchorStyle.asAnchor
pnlRightPin.Top = tabItemHeight
pnlRightPin.Width = 23
pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - 4
pnlRightPin.Height = tbRight.Height
pnlRightPin.Parent = @pnlRight
'pnlRight.Width = 153
'pnlRight.Align = 2
'pnlRight.AddRange 1, @tabRight

Function SetVisibleToTreeListViewItem(Sender As TreeListView, Node As TreeListViewItem Ptr, ByRef SearchText As WString) As Boolean
	Dim As Boolean bVisible
	If Node->Nodes.Count > 0 Then
		If SearchText = "" Then
			Node->Collapse
		Else
			Node->Expand
		End If
	End If
	For i As Integer = 0 To Node->Nodes.Count - 1
		If SetVisibleToTreeListViewItem(Sender, Node->Nodes.Item(i), SearchText) Then
			bVisible = True
		End If
	Next
	If Not bVisible Then
		bVisible = SearchText = "" OrElse InStr(LCase(Node->Text(0)), SearchText) > 0
	End If
	Node->Visible = bVisible
	Return bVisible
End Function

Sub txtProperties_Change(ByRef Designer As My.Sys.Object, Sender As TextBox)
	tabRight.UpdateLock
	Dim As UString SearchText = Trim(LCase(txtProperties.Text))
	For i As Integer = 0 To lvProperties.Nodes.Count - 1
		SetVisibleToTreeListViewItem(lvProperties, lvProperties.Nodes.Item(i), SearchText)
	Next
	tabRight.UpdateUnLock
End Sub

Sub txtEvents_Change(ByRef Designer As My.Sys.Object, Sender As TextBox)
	tabRight.UpdateLock
	Dim As UString SearchText = Trim(LCase(txtEvents.Text))
	For i As Integer = 0 To lvEvents.Nodes.Count - 1
		SetVisibleToTreeListViewItem(lvEvents, lvEvents.Nodes.Item(i), SearchText)
	Next
	tabRight.UpdateUnLock
End Sub

txtProperties.OnChange = @txtProperties_Change

txtEvents.OnChange = @txtEvents_Change

'ptabCode->Images.AddIcon bmp

Sub tabCode_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, newIndex As Integer)
	Static tbOld As TabWindow Ptr
	If newIndex = -1 Then UpdateCodeFormMenuEnabled: Exit Sub ' no tab selected → both Code and Form menus grey
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, Sender.Tab(newIndex))
	If tb = 0 Then tbFormat.Visible = False: Exit Sub
	If tb = tbOld Then Exit Sub
	'	pLocalTypes = @tb->Types
	'	pLocalEnums = @tb->Enums
	'	pLocalProcedures = @tb->Procedures
	'	pLocalFunctions = @tb->Functions
	'	pLocalFunctionsOthers = @tb->FunctionsOthers
	'	pLocalArgs = @tb->Args
	If tb->tn Then tb->tn->SelectItem
	For i As Integer = 1 To miWindow->Count - 1 '' index 0 is now the only static item (separator); Split H/V moved to View (13.3.A)
		If miWindow->Item(i) > 0 AndAlso tb->mi > 0 Then miWindow->Item(i)->Checked = miWindow->Item(i) = tb->mi
	Next
	If tb->Des <> 0 Then
		miLockControls->Checked = tb->Des->LockControls
	End If
	If tbOld AndAlso tb = tbOld Then Exit Sub
	If tbOld > 0 Then
		tbOld->lvPropertyWidth = tabRightWidth
		tbOld->FindFormPosiLeft = pfFind->Left
		tbOld->FindFormPosiTop = pfFind->Top
	End If
	If tb > 0 Then
		'tabRightWidth = tb->lvPropertyWidth
		If tb->FindFormPosiLeft > 0 Then pfFind->Left = tb->FindFormPosiLeft
		If tb->FindFormPosiTop > 0 Then pfFind->Top = tb->FindFormPosiTop
	End If
	tbOld = tb
	MouseHoverTimerVal = Timer
	If pfFind->cboFindRange.ItemIndex <> 2 Then
		WLet(gSearchSave, "")
	End If
	If frmMain.ActiveControl <> tb And frmMain.ActiveControl <> @tb->txtCode Then tb->txtCode.SetFocus
	' Clear via TextRTF (not Text) so the RichTextBox fully re-initialises after
	' the text replacement.
	txtLabelProperty.TextRTF = ""
	txtLabelEvent.TextRTF = ""
	pnlPropertyValue.Visible = False
	If tb->cboClass.Items.Count > 1 Then
		tb->FillAllProperties
		'tpProperties->SelectTab
		miCode->Enabled = True
		miForm->Enabled = True
		miCodeAndForm->Enabled = True
		' Switch Form/Code has nothing to do once both panels are already visible side by side.
		miGotoCodeForm->Enabled = tb->CurrentView() <> "CodeAndForm"
		' Split Horizontally/Vertically split the code editor, which isn't visible in Form-only view.
		mnuSplitHorizontally->Enabled = tb->CurrentView() <> "Form"
		mnuSplitVertically->Enabled = tb->CurrentView() <> "Form"
		miFold->Enabled = tb->CurrentView() <> "Form"
		tb->SetFormViewsEnabled(True)
	Else
		lvProperties.Nodes.Clear
		lvEvents.Nodes.Clear
		' A plain .bas module (no discovered class/controls) is not form-capable; only
		' .frm files are. (UserControl.bas files get here only before their form design
		' runs, at which point cboClass.Items.Count > 1 takes the branch above.)
		Dim As Boolean bFormFile = EndsWith(LCase(tb->FileName), ".frm")
		miCode->Enabled = bFormFile
		miForm->Enabled = bFormFile
		miCodeAndForm->Enabled = bFormFile
		' Switch Form/Code has nothing to do once both panels are already visible side by side.
		miGotoCodeForm->Enabled = bFormFile AndAlso tb->CurrentView() <> "CodeAndForm"
		' Split Horizontally/Vertically split the code editor, which isn't visible in Form-only view.
		mnuSplitHorizontally->Enabled = tb->CurrentView() <> "Form"
		mnuSplitVertically->Enabled = tb->CurrentView() <> "Form"
		miFold->Enabled = tb->CurrentView() <> "Form"
		tb->SetFormViewsEnabled(bFormFile)
		If mApplyingDeferredFormDesign = False AndAlso mApplyingFormTabView = False Then
			tb->ShowView("Code")
		End If
		'SetRightClosedStyle True, True
	End If
	'' Code/Form top menus: recompute for the newly selected tab (view/design state settled above).
	UpdateCodeFormMenuEnabled
	If tb->FileName = "" Then
		frmMain.Caption = tb->Caption & " - " & App.Title
	Else
		frmMain.Caption = tb->FileName & " - " & App.Title
	End If
	ChangeFileEncoding tb->FileEncoding
	ChangeNewLineType tb->NewLineType
	tbOld = tb
End Sub

Var ptabPanel = _New(TabPanel)
ptabPanel->Align = DockStyle.alClient
TabPanels.Add ptabPanel
ptabCode = @ptabPanel->tabCode

txtOutput.Name = "txtOutput"
txtOutput.Align = DockStyle.alClient
txtOutput.Multiline = True
txtOutput.ScrollBars = ScrollBarsType.Both
txtOutput.OnDblClick = @txtOutput_DblClick

Sub txtImmediate_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim As Integer iLine = txtImmediate.GetLineFromCharIndex(txtImmediate.SelStart)
	Dim As WString Ptr sLine ' = @txtImmediate.Lines(iLine) '  for got wrong value
	Dim bCtrl As Boolean
	'' ASTORIA CHANGE: &h8000, not decimal 8000. GetKeyState sets bit &h8000 when a key
	'' is down; 8000 decimal is &h1F40 and shares no bits with it, so the modifier was
	'' detected only for key-state values that happen to overlap &h1F40. Same mistake
	'' as the framework's, found by TestPlan B2 and fixed there first.
	bCtrl = GetKeyState(VK_CONTROL) And &h8000
	'
	WLet(sLine, txtImmediate.Lines(iLine))
	If CInt(Not bCtrl) AndAlso CInt(WGet(sLine) <> "") AndAlso CInt(Not StartsWith(Trim(WGet(sLine)),"'")) Then
		If Key = Keys.Key_Enter Then
			'
			SaveAll
			Dim As Integer Fn = FreeFile_
			Dim As Integer OpenResult2 = Open(ExePath & "/Temp/FBTemp.bas" For Output Encoding "utf-8" As #Fn)
			If OpenResult2 <> 0 Then
				MsgBox ("Couldn't write the Immediate window's scratch file - check that the Temp folder still exists and isn't read-only") & "." & WChr(13,10) & ExePath & "/Temp/FBTemp.bas", "Astoria IDE", mtError
				Exit Sub
			End If
			'Print #Fn, "#Include Once " + Chr(34) + "mff/SysUtils.bas"+Chr(34)
			For i As Integer =0 To iLine
				If StartsWith(Trim(LCase(txtImmediate.Lines(i))),"import ") Then Print #Fn, Mid(Trim(txtImmediate.Lines(i)),7)
			Next
			If CInt(StartsWith(Trim(*sLine),"?")) Then  '
				Print #Fn, "Print Str(" & Trim(Mid(*sLine,2)) & " & Space(1024))" ' space for wstring
			ElseIf CInt(StartsWith(Trim(LCase(*sLine)),"print ")) Then
				Print #Fn, "Print Str(" & Trim(Mid(*sLine,6)) & " & Space(1024))" 'space for wstring
			Else
				Print #Fn, "Print Str(" & Trim(*sLine) & " & Space(1024))" 'space for wstring
			End If
			CloseFile_(Fn)
			Dim As WString Ptr FbcExe, ExeName
			WLet(FbcExe, GetFullPath(GetBundledCompilerExe()))
			'' UseShell:=True -- this genuinely needs cmd's >/2> redirection,
			'' unlike the other PipeCmd call sites. See T3 / F-S1.
			PipeCmd """" & *FbcExe & """ -b """ & ExePath & "/Temp/FBTemp.bas"" -i """ & ExePath & "/" & *MFFPath & """ > """ & ExePath & "/Temp/Compile1.log"" 2> """ & ExePath & "/Temp/Compile2.log""", True
			Dim As WString Ptr LogText
			Dim Buff As WString * 2048 ' for V1.07 Line Input not working fine
			Dim As WString Ptr ErrFileName, ErrTitle
			Dim As Integer nLen, nLen2
			WLet(LogText, "")
			Fn = FreeFile_
			Dim Result As Integer=-1 '
			'' The utf-16 / utf-32 / utf-8 retries that used to follow were unreachable and are
			'' removed (2026-07-20). This Open carries no encoding, so it can only fail on ACCESS
			'' -- the file is missing or locked -- and re-opening the same inaccessible path with a
			'' different encoding fails identically. They read as encoding robustness while
			'' providing none: a genuinely UTF-16 log opens successfully here and is then read as
			'' ANSI, and the code written to catch that could never run.
			Result = Open(ExePath & "/Temp/Compile1.log" For Input As #Fn)
			If Result = 0 Then
				While Not EOF(Fn)
					Line Input #Fn, Buff
					SplitError(Trim(Buff), ErrFileName, ErrTitle, iLine)
					WAdd(LogText, *ErrTitle & !"\r")
				Wend
			Else
				MsgBox ("Open file failure!") & Chr(13,10) & "  " & ExePath & "/Temp/Compile1.log"
			End If
			CloseFile_(Fn)
			Fn = FreeFile_
			Result =-1
			Result = Open(ExePath & "/Temp/Compile2.log" For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/Compile2.log" For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/Compile2.log" For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/Compile2.log" For Input As #Fn)
			If Result = 0 Then
				While Not EOF(Fn)
					Line Input #Fn, Buff
					SplitError(Trim(Buff), ErrFileName, ErrTitle, iLine)
					WAdd(LogText, Trim(Buff) & !"\r")
				Wend
			Else
				MsgBox ("Open file failure!") & Chr(13,10) & "  " & ExePath & "/Temp/debug_compil2.log"
			End If
			CloseFile_(Fn)
			Key = 0
			If WGet(LogText) <> "" Then
				MsgBox !"Compile error:\r\r" & *LogText, , mtWarning
			Else
				WLet(ExeName, ExePath & "\Temp\FBTemp.exe") ' > output.txt
				'' F-T16-3 (T16 review): CreateProcess needs the leading token quoted when
				'' the path can contain spaces -- the old cmd /c wrapper this call used to
				'' go through effectively quoted it; T3's direct-launch path doesn't.
				PipeCmd """" & *ExeName & """"
				Fn = FreeFile_
				If Open Pipe(*ExeName For Input Encoding "utf-8" As #Fn) = 0 Then '
					Dim As Integer i
					While Not EOF(Fn)
						Line Input #Fn, Buff
						i = txtImmediate.GetCharIndexFromLine(iLine) + txtImmediate.GetLineLength(iLine)
						txtImmediate.SetSel i, i
						txtImmediate.SelText = WChr(13,10) + Trim(Buff)
						ptabBottom->Update
						txtImmediate.Update
						frmMain.Update
					Wend
				Else
					MsgBox ("Open file failure!") & Chr(13,10) & "  " & *ExeName
				End If
				CloseFile_(Fn)
				Kill *ExeName
			End If
			WDeAllocate(FbcExe)
			WDeAllocate(ExeName)
			WDeAllocate(LogText)
			WDeAllocate(ErrFileName)
			WDeAllocate(ErrTitle)
		End If
	End If
	WDeAllocate(sLine) '
	'If Not EndsWith(txtImmediate.Text, !"\r") Then txtImmediate.Text &= !"\r"
End Sub

txtImmediate.Align = DockStyle.alClient
txtImmediate.Multiline = True
txtImmediate.ScrollBars = ScrollBarsType.Both
txtImmediate.OnKeyDown = @txtImmediate_KeyDown
'
'txtImmediate.BackColor = NormalText.Background
'txtImmediate.Font.Color = NormalText.Foreground
txtImmediate.Text = "import #Include Once " + Chr(34) + ".." + WindowsSlash + "Controls" + WindowsSlash + "Framework"+ WindowsSlash + "mff" + WindowsSlash + "SysUtils.bas" + Chr(34) & Chr(13,10) & Chr(13,10)
txtImmediate.SetSel txtImmediate.GetTextLength, txtImmediate.GetTextLength

Sub txtChangeLog_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim bCtrl As Boolean
	bCtrl = GetKeyState(VK_CONTROL) And &h8000
	If CInt(Not bCtrl) OrElse Shift <> 1 Then mChangeLogEdited = True
	If CInt(bCtrl) And Key =13 Then
		txtChangeLog.SelText = __DATE_ISO__ & " " & Time & !"\t" & !"\t"  'Format(Now, "yyyy/mm/dd hh:mm:ss") & !"\t" & !"\t"
		mChangeLogEdited = True
	ElseIf CInt(bCtrl) And Shift And (Key =108 Or Key =76) Then
		Dim As TabWindow Ptr tb= Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb <> 0 Then
			Dim As WString Ptr sTmp
			WLet(sTmp, " {" & Replace(tb->Caption, "*", ""))
			WAdd(sTmp, "|" & tb->cboFunction.Text & " Ln" & Val(Trim(Replace(pstBar->Panels[1]->Caption, ("Row"), ""))) & "}")
			txtChangeLog.SelText = *sTmp
			WDeAllocate(sTmp)
			mChangeLogEdited = True
		End If
	ElseIf CInt(bCtrl) And Shift And (Key =99 Or Key =67) Then 'Ctrl+Shift+C
		Dim As TabWindow Ptr tb= Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb <> 0 Then
			Dim As WString Ptr txtChangeLogText =@txtChangeLog.Text
			Dim As Integer LStart = InStr(*txtChangeLogText, "{" & Replace(tb->Caption,"*",""))
			If LStart > 0 Then
				Dim As Integer LEnd = InStr(LStart,*txtChangeLogText, "|" & tb->cboFunction.Text)
				If LEnd > 0 Then LStart = LEnd
				txtChangeLog.SelStart = LStart
				txtChangeLog.SelEnd = LStart
				txtChangeLog.ScrollToCaret
			End If
		End If
	End If
End Sub
Sub txtChangeLog_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim As WString Ptr txtChangeLogText =@txtChangeLog.Text
	Dim As Integer LStart = txtChangeLog.SelStart
	Dim As Integer LEnd = InStr(LStart,*txtChangeLogText,"}")
	If LEnd < 1 Then Exit Sub
	Dim As WString Ptr FSelText
	LStart = InStrRev(*txtChangeLogText, "{", LEnd)
	LStart = Max(1,LStart)
	If LEnd > LStart Then
		Dim As WString * 255 CodeFileName = Mid(*txtChangeLogText, LStart, LEnd - LStart + 1)
		If Trim(CodeFileName) = "" Then Exit Sub
		Dim As Integer iPos = InStrRev(CodeFileName, " ")
		If iPos > 0 Then
			Dim As Integer iLine = Val(Mid(CodeFileName, iPos + 3))
			Dim As Integer iPos1 = InStr(iPos + 3, CodeFileName, Any !" }")
			'Clipboard.SetAsText Mid(CodeFileName,iPos+1,iPos1-ipos-1)
			'' Will Search With find Function
			'pfFind->txtFind.Text = Mid(CodeFileName,iPos+1,iPos1-ipos-1)
			Dim As Integer iPos2 = InStr(CodeFileName, "|")
			If iPos2 <= 0 Then Exit Sub
			Dim tn2 As TreeNode Ptr = FileNameInTreeNode(MainNode->Tag, Mid(CodeFileName, 2, iPos2 - 2))
			If tn2 = 0 Then Exit Sub
			If tn2->Tag <> 0 Then SelectError(*Cast(ExplorerElement Ptr, tn2->Tag)->FileName, iLine)
		End If
	End If
End Sub
'mChangeLogEdited
txtChangeLog.Align = DockStyle.alClient
txtChangeLog.Multiline = True
txtChangeLog.ScrollBars = ScrollBarsType.Both
txtChangeLog.OnKeyDown = @txtChangeLog_KeyDown
txtChangeLog.OnDblClick = @txtChangeLog_DblClick

Sub lvToDo_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvToDo.ListItems.Item(itemIndex)
	SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(lvToDo.Text), Item->Tag)
End Sub

lvToDo.Images = @imgList
'lvToDo.StateImages = @imgList
lvToDo.SmallImages = @imgList
lvToDo.Align = DockStyle.alClient
lvToDo.Columns.Add ("Content"), , 500, cfLeft
lvToDo.Columns.Add ("Line"), , 50, cfRight
lvToDo.Columns.Add ("Column"), , 50, cfRight
lvToDo.Columns.Add ("File"), , 700, cfLeft
lvToDo.OnItemActivate = @lvToDo_ItemActivate

Sub lvProblems_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvProblems.ListItems.Item(itemIndex)
	SelectError(GetFullPath(Item->Text(2)), Val(Item->Text(1)), Item->Tag)
End Sub

lvProblems.Images = @imgList
'lvErrors.StateImages = @imgList
lvProblems.SmallImages = @imgList
lvProblems.Align = DockStyle.alClient
lvProblems.Columns.Add ("Content"), , 500, cfLeft
lvProblems.Columns.Add ("Line"), , 50, cfRight
lvProblems.Columns.Add ("File"), , 700, cfLeft
lvProblems.OnItemActivate = @lvProblems_ItemActivate
'lvProblems.OnKeyDown = @lvErrors_KeyDown

Sub lvSuggestions_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvSuggestions.ListItems.Item(itemIndex)
	SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(lvSuggestions.Text), Item->Tag)
End Sub

lvSuggestions.Images = @imgList
'lvErrors.StateImages = @imgList
lvSuggestions.SmallImages = @imgList
lvSuggestions.Align = DockStyle.alClient
lvSuggestions.Columns.Add ("Content"), , 500, cfLeft
lvSuggestions.Columns.Add ("Line"), , 50, cfRight
lvSuggestions.Columns.Add ("Column"), , 50, cfRight
lvSuggestions.Columns.Add ("File"), , 700, cfLeft
lvSuggestions.Columns.Add ("Project"), , 500, cfLeft
lvSuggestions.OnItemActivate = @lvSuggestions_ItemActivate

Sub lvSearch_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvSearch.ListItems.Item(itemIndex)
	gSearchItemIndex = itemIndex
	SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(lvSearch.Text), Item->Tag)
	If pfFind->Visible Then 'David Change
		pfFind->Caption = ("Find")+": " + WStr(gSearchItemIndex+1) + " of " + WStr(lvSearch.ListItems.Count)
	End If
End Sub

lvSearch.Align = DockStyle.alClient
lvSearch.Columns.Add ("Line Text"), , 500, cfLeft
lvSearch.Columns.Add ("Line"), , 50, cfRight
lvSearch.Columns.Add ("Column"), , 50, cfRight
lvSearch.Columns.Add ("File"), , 700, cfLeft
lvSearch.OnItemActivate = @lvSearch_ItemActivate
'lvSearch.OnKeyDown = @lvSearch_KeyDown

Sub RestoreStatusText
	pstBar->Panels[0]->Caption = ("Press F1 for get more information")
End Sub

Function GetBottomClosedStyle As Boolean
	Return Not ptabBottom->TabPosition = tpTop
End Function

Function IsBottomCollapsed As Boolean
	Return ptabBottom->TabPosition = tpBottom And ptabBottom->SelectedTabIndex = -1
End Function

Sub SetBottomClosedStyle(Value As Boolean, WithClose As Boolean = True)
	If bClosing Then Exit Sub
	bClosing = True
	With *tbBottom.Buttons.Item("PinBottom")
		If Value Then
			ptabBottom->TabPosition = tpBottom
			.ImageKey = "Pin"
			.Checked = False
			If WithClose Then
				CloseBottom
			Else
				UpdateBottomPinLayout
			End If
		Else
			ptabBottom->TabPosition = tpTop
			ptabBottom->Height = tabBottomHeight
			pnlBottom.Height = tabBottomHeight
			pnlBottom.RequestAlign
			splBottom.Visible = True
			pnlBottomPin.Visible = True
			UpdateBottomPinLayout
			.ImageKey = "Pinned"
			.Checked = True
			If ptabBottom->SelectedTabIndex = -1 AndAlso ptabBottom->TabCount > 0 Then ptabBottom->SelectedTabIndex = 0
		End If
	End With
	frmMain.RequestAlign
	bClosing = False
End Sub

Sub tabBottom_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	SetBottomClosedStyle Not GetBottomClosedStyle
End Sub

Sub tabBottom_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As Control, newIndex As Integer)
	If bApplyingStartupLayout OrElse bClosing Then Exit Sub
	Dim As Boolean bIsBottomPositioned = CBool(ptabBottom->TabPosition = tpBottom)
	Dim As Boolean bHasSelectedTab = CBool(ptabBottom->SelectedTabIndex <> -1)
	Dim As Boolean bBottomNotVisible = CBool(Not splBottom.Visible)
	If bIsBottomPositioned AndAlso bHasSelectedTab AndAlso bBottomNotVisible Then
		ShowBottom
	End If
	Dim As TabPage Ptr tp = ptabBottom->SelectedTab
	tbBottom.Buttons.Item("EraseOutputWindow")->Visible = tp = tpOutput
	tbBottom.Buttons.Item("EraseImmediateWindow")->Visible = tp = tpImmediate
	tbBottom.Buttons.Item("AddWatch")->Visible = tp = tpWatches
	tbBottom.Buttons.Item("RemoveWatch")->Visible = tp = tpWatches
	tbBottom.Buttons.Item("Update")->Visible = tp = tpGlobals
	If newIndex = 9 Then tbBottom.Buttons.Item("AddWatch")->State = Cast(ToolButtonState, tbBottom.Buttons.Item("AddWatch")->State Or ToolButtonState.tstWrap)
	If MainNode <> 0 AndAlso MainNode->Text <> "" AndAlso InStr(MainNode->Text, ".") Then
		If ptabBottom->SelectedTab = tpChangeLog AndAlso CInt(Not mLoadLog) Then ' AndAlso CInt(Not mLoadToDo)
			If mChangeLogEdited AndAlso mChangelogName<> "" Then
				txtChangeLog.SaveToFile(mChangelogName)  ' David Change
				mChangeLogEdited = False
			End If
			mChangelogName = GetChangeLogPath(MainNode)
			txtChangeLog.Text = "Waiting...... "
			If Dir(mChangelogName)<>"" AndAlso mChangelogName<> "" Then
				txtChangeLog.LoadFromFile(mChangelogName) ' David Change
				If InStr(txtChangeLog.Text,Chr(13,10)) < 1 Then txtChangeLog.Text = Replace(txtChangeLog.Text,Chr(10),Chr(13,10))
			Else
				txtChangeLog.Text = ""
			End If
			mLoadLog = True
		ElseIf ptabBottom->SelectedTab = tpToDo AndAlso Not mLoadToDo Then
			WLet(gSearchSave, WChr(84) + "ODO")
			ThreadCounter(ThreadCreate_(@FindSubProj, MainNode))
			mLoadToDo = True
		End If
	End If
End Sub

Sub tabBottom_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control) '<...>
	Dim As Boolean bIsBottomPositioned = CBool(ptabBottom->TabPosition = tpBottom)
	Dim As Boolean bHasSelectedTab = CBool(ptabBottom->SelectedTabIndex <> -1)
	Dim As Boolean bBottomNotVisible = CBool(Not splBottom.Visible)
	If bIsBottomPositioned AndAlso bHasSelectedTab AndAlso bBottomNotVisible Then
		ShowBottom
	End If
End Sub

Sub ShowMessages(ByRef msg As WString, ChangeTab As Boolean = True)
	If ChangeTab Then
		tabBottom_SelChange(*ptabBottom->Designer, *ptabBottom, 0)
		tpOutput->SelectTab
	End If
	Dim As Integer AddingTextLength = Len(msg & WChr(13) & WChr(10))
	If txtOutput.GetTextLength + AddingTextLength > 64000 Then
		txtOutput.Text = Mid(txtOutput.Text, txtOutput.GetCharIndexFromLine(txtOutput.GetLineFromCharIndex(AddingTextLength) + 1))
	End If
	txtOutput.SetSel txtOutput.GetTextLength, txtOutput.GetTextLength
	txtOutput.SelText = msg & WChr(13) & WChr(10)
	tabBottom.Update
	txtOutput.Update
	frmMain.Update
	'    txtOutput.ScrollToCaret
End Sub

Sub pnlBottom_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	If tabBottom.TabCount = 0 Then
		tabBottomHeight = NewHeight
	ElseIf ptabBottom->SelectedTabIndex <> -1 AndAlso ptabBottom->TabPosition = tpTop AndAlso NewHeight >= MIN_BOTTOM_PANEL_HEIGHT Then
		tabBottomHeight = NewHeight
	End If
	If pnlBottomPin.Visible AndAlso ptabBottom->TabPosition = tpTop Then UpdateBottomPinLayout()
End Sub

pnlBottom.Name = "pnlBottom"
pnlBottom.Align = DockStyle.alBottom
pnlBottom.Height = tabBottomHeight
pnlBottom.OnResize = @pnlBottom_Resize

tbBottom.ImagesList = @imgList
tbBottom.Buttons.Add tbsCheck, "Pinned", , @mClick, "PinBottom", "", ("Pin"), True, Cast(ToolButtonState, tstEnabled Or tstChecked)
tbBottom.Buttons.Add tbsSeparator
tbBottom.Buttons.Add , "Eraser", , @mClick, "EraseOutputWindow", "", ("Clear Output"), True, tstEnabled
tbBottom.Buttons.Add , "Eraser", , @mClick, "EraseImmediateWindow", "", ("Erase immediate window"), True, tstEnabled
tbBottom.Buttons.Add , "Add", , @mClick, "AddWatch", "", ("Add Watch"), True, Cast(ToolButtonState, tstEnabled Or tstWrap)
tbBottom.Buttons.Add , "Remove", , @mClick, "RemoveWatch", "", ("Remove Watch"), True, tstEnabled
tbBottom.Buttons.Add tbsCheck, "Update", , @mClick, "Update", "", ("Update"), True, tstEnabled
tbBottom.Buttons.Item("EraseImmediateWindow")->Visible = False
tbBottom.Buttons.Item("AddWatch")->Visible = False
tbBottom.Buttons.Item("RemoveWatch")->Visible = False
tbBottom.Buttons.Item("Update")->Visible = False
tbBottom.Flat = True
tbBottom.Wrapable = True
tbBottom.Width = BOTTOM_PIN_STRIP_WIDTH
tbBottom.Align = DockStyle.alClient
tbBottom.Parent = @pnlBottomPin

'ptabBottom->Images.AddIcon bmp
ptabBottom->Name = "tabBottom"
ptabBottom->GroupName = "ToolWindow"
ptabBottom->Height = tabBottomHeight
ptabBottom->Align = DockStyle.alClient
'ptabBottom->TabPosition = tpBottom
ptabBottom->Detachable = True
ptabBottom->Reorderable = True
tpOutput = AddToTabControl(("Output"), "Output", "tabBottom", 0)
tpProblems = AddToTabControl(("Problems"), "Problems", "tabBottom", 1)
tpSuggestions = AddToTabControl(("Suggestions"), "Suggestions", "tabBottom", 2)
tpFind = AddToTabControl(("Find"), "Find", "tabBottom", 3)
tpToDo = AddToTabControl(("ToDo"), "ToDo", "tabBottom", 4)
tpChangeLog = AddToTabControl(("Change Log"), "ChangeLog", "tabBottom", 5)
tpImmediate = AddToTabControl(("Immediate"), "Immediate", "tabBottom", 6)
tpLocals = AddToTabControl(("Locals"), "Locals", "tabBottom", 7)
tpGlobals = AddToTabControl(("Globals"), "Globals", "tabBottom", 8)
tpProcedures = AddToTabControl(("Procedures"), "Procedures", "tabBottom", 9)
tpThreads = AddToTabControl(("Threads"), "Threads", "tabBottom", 10)
tpWatches = AddToTabControl(("Watches"), "Watches", "tabBottom", 11)
tpMemory = AddToTabControl(("Memory"), "Memory", "tabBottom", 12)
tpProfiler = AddToTabControl(("Profiler"), "Profiler", "tabBottom", 13)
tpOutput->Add @txtOutput
tpProblems->Add @lvProblems
tpSuggestions->Add @lvSuggestions
tpFind->Add @lvSearch
tpToDo->Add @lvToDo
tpChangeLog->Add @txtChangeLog
tpImmediate->Add @txtImmediate
tpLocals->Add @lvLocals
tpLocals->Add @tvVar
tpGlobals->Add @lvGlobals
tpProcedures->Add @tvPrc
tpThreads->Add @lvThreads
tpThreads->Add @tvThd
tpWatches->Add @lvWatches
tpWatches->Add @tvWch
tpMemory->Add @lvMemory
tpProfiler->Add @lvProfiler
' Hide debug-only tabs before the tab control HWND is created so startup labels stay correct.
SetDebugTabsVisible False
ptabBottom->OnClick = @tabBottom_Click
ptabBottom->OnDblClick = @tabBottom_DblClick
ptabBottom->OnSelChange = @tabBottom_SelChange
ptabBottom->Parent = @pnlBottomTab

pnlBottomTab.Align = DockStyle.alClient
pnlBottomTab.Parent = @pnlBottom

'pnlBottom.Height = 153
'pnlBottom.Align = 4
'pnlBottom.AddRange 1, @tabBottom
pnlBottomPin.Top = 2
pnlBottomPin.Width = BOTTOM_PIN_STRIP_WIDTH
pnlBottomPin.Height = BOTTOM_PIN_STRIP_WIDTH
pnlBottomPin.Parent = @pnlBottom

'pnlBottom.Add ptabBottom

	Dim Shared As Integer iLine, iChar, CanvasHeight, CanvasWidth
	Sub Document_PrintPage(ByRef Designer As My.Sys.Object, ByRef Sender As PrintDocument, ByRef Canvas As My.Sys.Drawing.Canvas, ByRef HasMorePages As Boolean)
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Return
		Canvas.Font = tb->txtCode.Font
		If iLine = 0 AndAlso iChar = 0 Then
			CanvasWidth = Sender.PrinterSettings.PrintableWidth
			CanvasHeight = Sender.PrinterSettings.PrintableHeight
		End If
		Dim As Integer CharHeight = Canvas.TextHeight("P")
		Dim As Integer CharWidth = Canvas.TextWidth("P")
		Dim As Integer CharsCount = (CanvasWidth - PageSetupD.LeftMargin - PageSetupD.RightMargin) / CharWidth, LinesCount = 0, LineCharsCount, SpacePos
		Dim As UString sLine, sLineToPrint
		For i As Integer = iLine To tb->txtCode.LinesCount - 1
			sLine = Replace(tb->txtCode.Lines(i), !"\t", Space(TabWidth))
			LineCharsCount = Len(sLine)
			Do
				LinesCount += 1
				If PageSetupD.TopMargin + PageSetupD.BottomMargin + LinesCount * CharHeight > CanvasHeight Then
					iLine = i
					HasMorePages = True
					Exit Sub
				End If
				sLineToPrint = Mid(sLine, iChar + 1, CharsCount)
				SpacePos = InStrRev(sLineToPrint, " ")
				If LineCharsCount > iChar + CharsCount AndAlso SpacePos > 0 Then
					sLineToPrint = Left(sLineToPrint, SpacePos) '& "_"
					iChar += SpacePos
				Else
					iChar += CharsCount
				End If
				Canvas.TextOut PageSetupD.LeftMargin, PageSetupD.TopMargin + (LinesCount - 1) * CharHeight, sLineToPrint
			Loop While LineCharsCount > iChar
			iChar = 0
		Next
		'Canvas.Line 10, 10, 20, 20
		iLine = 0
	End Sub
	
	PrintPreviewD.Document->OnPrintPage = @Document_PrintPage

Function ControlInParent Overload(Ctrl As Control Ptr, Parent As Control Ptr) As Boolean
	If Ctrl = 0 Then
		Return False
	ElseIf Ctrl = Parent Then
		Return True
	Else
		Return ControlInParent(Ctrl->Parent, Parent)
	End If
End Function

Function ControlInParent Overload(Ctrl As Control Ptr, ByRef ParentName As WString) As Boolean
	If Ctrl = 0 Then
		Return False
	ElseIf Ctrl->Name = ParentName Then
		Return True
	Else
		Return ControlInParent(Ctrl->Parent, ParentName)
	End If
End Function

Sub frmMain_ActiveControlChanged(ByRef Designer As My.Sys.Object, ByRef sender As My.Sys.Object)
	If frmMain.ActiveControl = 0 Then Exit Sub
	' Do not auto-collapse docked panels during startup layout or while the main form is closing;
	' focus changes in those phases would otherwise overwrite the layout saved on exit.
	If Not FormClosing AndAlso Not bApplyingStartupLayout Then
		If tabLeft.TabPosition = tpLeft And tabLeft.SelectedTabIndex <> -1 Then
			If (Not ControlInParent(frmMain.ActiveControl, @tabLeft)) AndAlso (Not ControlInParent(frmMain.ActiveControl, @pnlLeftPin)) Then
				CloseLeft
			End If
		End If
		If tabRight.TabPosition = tpRight And tabRight.SelectedTabIndex <> -1 Then
			If (Not ControlInParent(frmMain.ActiveControl, @tabRight)) AndAlso (Not ControlInParent(frmMain.ActiveControl, @pnlRightPin)) AndAlso (Not ControlInParent(frmMain.ActiveControl, "Designer")) Then
				CloseRight()
			End If
		End If
		Dim As Boolean bIsBottomPositioned = CBool(ptabBottom->TabPosition = tpBottom)
		Dim As Boolean bHasSelectedTab = CBool(ptabBottom->SelectedTabIndex <> -1)
		If bIsBottomPositioned AndAlso bHasSelectedTab AndAlso splBottom.Visible Then
			If Not ControlInParent(frmMain.ActiveControl, @tabBottom) AndAlso Not ControlInParent(frmMain.ActiveControl, @pnlBottomPin) Then
				CloseBottom
			End If
		End If
	End If
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb Then
		If tb->txtCode.ToolTipShowed Then tb->txtCode.CloseToolTip
		If tb->txtCode.DropDownShowed Then tb->txtCode.CloseDropDownToolTip
		If tb->txtCode.MouseHoverToolTipShowed Then tb->txtCode.CloseMouseHoverToolTip
	End If
	Dim As Form Ptr ActiveForm = Cast(Form Ptr, pApp->ActiveForm)
	If ActiveForm = 0 OrElse ActiveForm->ActiveControl = 0 Then
		If iFlagStartDebug = 0 Then ChangeEnabledDebug tvExplorer.Nodes.Count > 0, False, False
		Exit Sub
	End If
	Dim As Boolean bEnabled, bEnabledEditControl, bEnabledPanel, bEnabledIndentAndOutdent
	Select Case ActiveForm->ActiveControl->ClassName
	Case "EditControl"
		bEnabled = True
		bEnabledEditControl = True
	Case "Panel"
		bEnabled = True
		bEnabledPanel = True
		bEnabledIndentAndOutdent = True
	Case "TextBox", "RichTextBox", "ComboBoxEdit", "ComboBoxEx"
		bEnabled = True
	Case "Form"
		'' The design surface. The form being designed is itself an MFF Form hosted inside
		'' pnlForm, so clicking a control on it reports ClassName "Form" -- which was in no list
		'' here, leaving Undo/Redo greyed whenever the designer had focus.
		''
		'' A greyed item does not merely look wrong: Windows' TranslateAccelerator CONSUMES a
		'' keystroke whose menu item is disabled and sends no WM_COMMAND for it. So Ctrl+Z on the
		'' design surface was destroyed before any window saw it -- measured, with only
		'' VK_CONTROL reaching the designer's WndProc and mClick never entered. Enabling the item
		'' is what makes the accelerator deliver at all.
		''
		'' Gated on a live designer with a selected control, which is exactly when
		'' DispatchDesignerCommand can service the command.
		Scope
			Dim As TabWindow Ptr tbDes = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			'' Gated on a live designer only. NOT on cboClass.ItemIndex > 0 ("a control is
			'' selected"): the focus event arrives before the selection is reflected there, so
			'' that test reads 0 and the item stayed greyed -- measured as
			'' "Form guard: tb=-1 des=-1 cboClass=0".
			If tbDes <> 0 AndAlso tbDes->Des <> 0 Then bEnabled = True
		End Scope
	End Select
	Select Case ActiveForm->ActiveControl
	Case @txtExplorer, @tvExplorer, @txtForm, @tvToolBox, @txtProperties, @lvProperties, @txtEvents, @lvEvents
		bEnabledIndentAndOutdent = True
	End Select
	'' Split view: the Code/Form top menus track whichever editing pane last took focus.
	'' Only the two panes themselves flip the flag -- focus moving to Properties, the
	'' Toolbox, output panels etc. keeps the current pane context. The designer surface
	'' is a foreign window hosted inside pnlForm, so the MFF control that reports focus
	'' may be pnlForm itself or a wrapper inside it -- walk the parent chain to find out.
	Scope
		Dim As TabWindow Ptr tbPane = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tbPane Then
			If ActiveForm->ActiveControl = Cast(Control Ptr, @tbPane->txtCode) Then
				If gDesignerPaneFocused Then
					gDesignerPaneFocused = False
					UpdateCodeFormMenuEnabled
				End If
			Else
				Dim As Control Ptr cWalk = ActiveForm->ActiveControl
				While cWalk
					If cWalk = Cast(Control Ptr, @tbPane->pnlForm) Then
						If Not gDesignerPaneFocused Then
							gDesignerPaneFocused = True
							UpdateCodeFormMenuEnabled
						End If
						Exit While
					End If
					cWalk = cWalk->Parent
				Wend
			End If
		End If
	End Scope
	If bEnabledIndentAndOutdent Then
		If miIndent->Caption <> ("Move focus forward") & !"\tTab" Then
			miIndent->Caption = ("Move focus forward") & !"\tTab"
			miOutdent->Caption = ("Move focus backward") & !"\tShift+Tab"
		End If
	Else
		If miIndent->Caption <> ("Indent") & !"\tTab" Then
			miIndent->Caption = ("Indent") & !"\tTab"
			miOutdent->Caption = ("Outdent") & !"\tShift+Tab"
		End If
	End If
	miUndo->Enabled = bEnabled
	tbtUndo->Enabled = bEnabled
	miRedo->Enabled = bEnabled
	tbtRedo->Enabled = bEnabled
	miCutCurrentLine->Enabled = bEnabledEditControl
	miCut->Enabled = bEnabled
	tbtCut->Enabled = bEnabled
	miCopy->Enabled = bEnabled
	tbtCopy->Enabled = bEnabled
	miPaste->Enabled = bEnabled
	tbtPaste->Enabled = bEnabled
	miSingleComment->Enabled = bEnabledEditControl
	tbtSingleComment->Enabled = bEnabledEditControl
	miDuplicate->Enabled = bEnabledEditControl Or bEnabledPanel
	miSelectAll->Enabled = bEnabled
	miIndent->Enabled = bEnabledEditControl OrElse bEnabledIndentAndOutdent
	miOutdent->Enabled = bEnabledEditControl OrElse bEnabledIndentAndOutdent
	miFormat->Enabled = bEnabledEditControl
	tbtFormat->Enabled = bEnabledEditControl
	miUnformat->Enabled = bEnabledEditControl
	tbtUnformat->Enabled = bEnabledEditControl
	miAddSpaces->Enabled = bEnabledEditControl
	miDeleteBlankLines->Enabled = bEnabledEditControl
	tbtCompleteWord->Enabled = bEnabledEditControl
	miParameterInfo->Enabled = bEnabledEditControl
	tbtParameterInfo->Enabled = bEnabledEditControl
	miCollapseCurrent->Enabled = bEnabledEditControl
	miCollapseAllProcedures->Enabled = bEnabledEditControl
	miCollapseAll->Enabled = bEnabledEditControl
	miUnCollapseCurrent->Enabled = bEnabledEditControl
	miUnCollapseAllProcedures->Enabled = bEnabledEditControl
	miUnCollapseAll->Enabled = bEnabledEditControl
	If iFlagStartDebug = 0 Then
		ChangeEnabledDebug tvExplorer.Nodes.Count > 0, False, False
		If Not bEnabledEditControl Then
			miSetNextStatement->Enabled = False
			tbtSetNextStatement->Enabled = False
		End If
	Else
		Dim As Boolean bCanSetNext = bEnabledEditControl AndAlso mnuEnd->Enabled AndAlso Not mnuBreak->Enabled
		miSetNextStatement->Enabled = bCanSetNext
		tbtSetNextStatement->Enabled = bCanSetNext
	End If
	miToggleBookmark->Enabled = bEnabledEditControl
	miToggleBreakpoint->Enabled = bEnabledEditControl
End Sub

Sub frmMain_Resize(ByRef Designer As My.Sys.Object, ByRef sender As My.Sys.Object, NewWidth As Integer = -1, NewHeight As Integer = -1)
	stBar.Panels[0]->Width = Max(stBar.Width - 50 - stBar.Panels[1]->Width - stBar.Panels[2]->Width - stBar.Panels[3]->Width  - stBar.Panels[4]->Width - stBar.Panels[5]->Width, 20)
	prProgress.Left = stBar.Panels[0]->Width + stBar.Panels[1]->Width 
	UpdateBottomPinLayout
	frmMain.RequestAlign
End Sub

Sub frmMain_KeyDown(ByRef Designer As My.Sys.Object, ByRef sender As My.Sys.Object, Key As Integer, Shift As Integer)
	Select Case Key
	Case VK_TAB
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb > 0 AndAlso tb->txtCode.DropDownShowed Then
			tb->txtCode.CloseDropDown
			If tb->txtCode.Carets.Count > 0 Then
				If Shift And ShiftMask Then
					tb->txtCode.Outdent
				Else
					tb->txtCode.Indent
				End If
			Else
				If tb->txtCode.LastItemIndex <> -1 AndAlso tb->txtCode.cboIntellisense.OnSelected Then tb->txtCode.cboIntellisense.OnSelected(*tb->txtCode.cboIntellisense.Designer, tb->txtCode.cboIntellisense, tb->txtCode.LastItemIndex)
			End If
		End If
	End Select
End Sub

Sub frmMain_DropFile(ByRef Designer As My.Sys.Object, ByRef sender As My.Sys.Object, ByRef FileName As WString)
	OpenFiles FileName
End Sub

Sub ConnectAddIn(AddIn As String)
	Dim As Sub(VisualFBEditorApp As Any Ptr, ByRef AppPath As WString) OnConnection
	Dim As Any Ptr AddInDll
	Dim As String f
		f = Dir(ExePath & "/AddIns/" & AddIn & ".dll")
	AddInDll = DyLibLoad(ExePath & "/AddIns/" & f)
	If AddInDll <> 0 Then
		OnConnection = DyLibSymbol(AddInDll, "OnConnection")
		If OnConnection Then
			OnConnection(@VisualFBEditorApp, VisualFBEditorApp.FileName)
			AddIns.Add AddIn, AddInDll
		End If
	End If
End Sub

Sub DisConnectAddIn(AddIn As String)
	Dim As Sub(VisualFBEditorApp As Any Ptr) OnDisconnection
	Dim As Any Ptr AddInDll
	Dim i As Integer = AddIns.IndexOf(AddIn)
	If i <> -1 Then
		AddInDll = AddIns.Object(i)
		If AddInDll <> 0 Then
			OnDisconnection = DyLibSymbol(AddInDll, "OnDisconnection")
			If OnDisconnection Then
				OnDisconnection(@VisualFBEditorApp)
				DyLibFree(AddInDll)
			End If
		End If
		AddIns.Remove i
	End If
End Sub

Sub LoadAddIns
	Dim As String f, AddIn
		f = Dir(ExePath & "/AddIns/*.dll")
	While f <> ""
		AddIn = Left(f, InStrRev(f, ".") - 1)
		If iniSettings.ReadBool("AddInsOnStartup", AddIn, False) Then
			ConnectAddIn AddIn
		End If
		f = Dir()
	Wend
End Sub

Sub UnLoadAddins
	Dim As Any Ptr AddInDll
	For i As Integer = 0 To AddIns.Count - 1
		DisConnectAddIn AddIns.Item(i)
	Next
	AddIns.Clear
End Sub

Sub LoadTools
	Dim As UserToolType Ptr Tool
	For i As Integer = 0 To Tools.Count - 1
		Tool = Tools.Item(i)
		If Tool->LoadType = LoadTypes.OnEditorStartup Then Tool->Execute
	Next
End Sub

'' ---------------------------------------------------------------- high contrast (ROADMAP 13.30)
''
'' Astoria's chrome survives a high-contrast theme on its own, because it paints with system
'' colours. The editor does not: its colours come from Settings/Themes/*.ini, which are fixed
'' palettes that cannot know what the system theme is. Left alone, a light Astoria theme under a
'' dark high-contrast theme is a white panel in an otherwise black IDE -- and the line-number
'' margin renders the system background with the theme's near-black foreground on top of it, so
'' the numbers vanish entirely.
''
'' The rule applied below: when high contrast is on, the system owns the background, and any
'' foreground that cannot be read against it is replaced by the system text colour. Token colours
'' that still contrast are kept, so syntax highlighting survives wherever it legitimately can.

Function IsHighContrastMode() As Boolean
	Dim As HIGHCONTRASTW hc
	hc.cbSize = SizeOf(HIGHCONTRASTW)
	If SystemParametersInfoW(SPI_GETHIGHCONTRAST, SizeOf(HIGHCONTRASTW), @hc, 0) = 0 Then Return False
	Return (hc.dwFlags And HCF_HIGHCONTRASTON) <> 0
End Function

'' WCAG relative luminance of a Windows COLORREF (which is BGR, not RGB -- getting this backwards
'' silently swaps red and blue and only shows up as a wrong contrast decision).
Private Function ColorLuminance(ByVal c As Integer) As Double
	If c < 0 Then Return 0
	Dim As Double ch(0 To 2)
	ch(0) = ((c       ) And &hFF) / 255.0   '' R
	ch(1) = ((c Shr  8) And &hFF) / 255.0   '' G
	ch(2) = ((c Shr 16) And &hFF) / 255.0   '' B
	For i As Integer = 0 To 2
		If ch(i) <= 0.03928 Then
			ch(i) = ch(i) / 12.92
		Else
			ch(i) = ((ch(i) + 0.055) / 1.055) ^ 2.4
		End If
	Next i
	Return 0.2126 * ch(0) + 0.7152 * ch(1) + 0.0722 * ch(2)
End Function

Private Function ContrastRatio(ByVal c1 As Integer, ByVal c2 As Integer) As Double
	Dim As Double l1 = ColorLuminance(c1), l2 = ColorLuminance(c2)
	If l1 < l2 Then Swap l1, l2
	Return (l1 + 0.05) / (l2 + 0.05)
End Function

Sub GetColors(ByRef cs As ECColorScheme, DefaultForeground As Integer = -1, DefaultBackground As Integer = -1, DefaultFrame As Integer = -1, DefaultIndicator As Integer = -1)
	cs.Foreground = IIf(cs.ForegroundOption = -1, DefaultForeground, cs.ForegroundOption)
	cs.Background = IIf(cs.BackgroundOption = -1, DefaultBackground, cs.BackgroundOption)
	cs.Frame = IIf(cs.FrameOption = -1, DefaultFrame, cs.FrameOption)
	cs.Indicator = IIf(cs.IndicatorOption = -1, DefaultIndicator, cs.IndicatorOption)
	GetColor cs.Foreground, cs.ForegroundRed, cs.ForegroundGreen, cs.ForegroundBlue
	GetColor cs.Background, cs.BackgroundRed, cs.BackgroundGreen, cs.BackgroundBlue
	GetColor cs.Frame, cs.FrameRed, cs.FrameGreen, cs.FrameBlue
	GetColor cs.Indicator, cs.IndicatorRed, cs.IndicatorGreen, cs.IndicatorBlue
End Sub

'' Force one style onto the system background, keeping its foreground only if that foreground can
'' actually be read there. 4.5:1 is the WCAG AA threshold for body text. Defined after GetColors
'' because it calls it and there is no forward declaration.
Private Sub HighContrastStyle(ByRef cs As ECColorScheme, ByVal SysBack As Integer, ByVal SysText As Integer)
	cs.BackgroundOption = SysBack
	If cs.ForegroundOption = -1 OrElse ContrastRatio(cs.ForegroundOption, SysBack) < 4.5 Then
		cs.ForegroundOption = SysText
	End If
	GetColors cs, SysText, SysBack
End Sub

Sub SetAutoColors
	GetColors NormalText, clBlack, clWhite
	GetColors Bookmarks, , , , clAqua
	GetColors Breakpoints, NormalText.Background, clMaroon, , clMaroon
	GetColors Comments, clGreen
	GetColors CurrentBrackets, , , clGreen
	GetColors CurrentLine, , clBtnFace
	GetColors CurrentWord, , clBtnFace
	GetColors ExecutionLine, NormalText.Foreground, clYellow, , clYellow
	GetColors FoldLines, clBtnShadow
	GetColors Identifiers, NormalText.Foreground
	GetColors ColorByRefParameters, Identifiers.Foreground
	GetColors ColorByValParameters, Identifiers.Foreground
	GetColors ColorCommonVariables, Identifiers.Foreground
	GetColors ColorComps, Identifiers.Foreground
	GetColors ColorConstants, Identifiers.Foreground
	GetColors ColorDefines, Identifiers.Foreground
	GetColors ColorFields, Identifiers.Foreground
	GetColors ColorGlobalFunctions, Identifiers.Foreground
	GetColors ColorEnumMembers, Identifiers.Foreground
	GetColors ColorGlobalEnums, Identifiers.Foreground
	GetColors ColorLineLabels, Identifiers.Foreground
	GetColors ColorLocalVariables, Identifiers.Foreground
	GetColors ColorMacros, Identifiers.Foreground
	GetColors ColorGlobalNamespaces, Identifiers.Foreground
	GetColors ColorProperties, Identifiers.Foreground
	GetColors ColorSharedVariables, Identifiers.Foreground
	GetColors ColorSubs, Identifiers.Foreground
	GetColors ColorGlobalTypes, Identifiers.Foreground
	GetColors IndicatorLines, Identifiers.Foreground
	For k As Integer = 0 To UBound(Keywords)
		GetColors Keywords(k), clBlue
	Next k
	GetColors LineNumbers, NormalText.Foreground
	GetColors Numbers, NormalText.Foreground
	GetColors RealNumbers, NormalText.Foreground
	GetColors ColorOperators, NormalText.Foreground
	GetColors Selection, clHighlightText, clHighlight
	GetColors SpaceIdentifiers, clLtGray
	GetColors Strings, clMaroon
	If NormalText.Foreground = NormalText.Background Then
		NormalText.ForegroundOption = clBlack
		NormalText.BackgroundOption = clWhite
		GetColors NormalText, clBlack, clWhite
	End If

	'' High contrast: the system owns the colours, not the theme file (ROADMAP 13.30). Applied
	'' last so it overrides everything resolved above, and only while high contrast is actually on
	'' -- with it off, not one value here changes.
	If IsHighContrastMode() Then
		Dim As Integer SysBack = GetSysColor(COLOR_WINDOW)
		Dim As Integer SysText = GetSysColor(COLOR_WINDOWTEXT)

		HighContrastStyle NormalText, SysBack, SysText
		HighContrastStyle Identifiers, SysBack, SysText
		HighContrastStyle Comments, SysBack, SysText
		HighContrastStyle Strings, SysBack, SysText
		HighContrastStyle Numbers, SysBack, SysText
		HighContrastStyle RealNumbers, SysBack, SysText
		HighContrastStyle ColorOperators, SysBack, SysText
		HighContrastStyle SpaceIdentifiers, SysBack, SysText
		For k As Integer = 0 To UBound(Keywords)
			HighContrastStyle Keywords(k), SysBack, SysText
		Next k
		HighContrastStyle ColorByRefParameters, SysBack, SysText
		HighContrastStyle ColorByValParameters, SysBack, SysText
		HighContrastStyle ColorCommonVariables, SysBack, SysText
		HighContrastStyle ColorComps, SysBack, SysText
		HighContrastStyle ColorConstants, SysBack, SysText
		HighContrastStyle ColorDefines, SysBack, SysText
		HighContrastStyle ColorFields, SysBack, SysText
		HighContrastStyle ColorGlobalFunctions, SysBack, SysText
		HighContrastStyle ColorEnumMembers, SysBack, SysText
		HighContrastStyle ColorGlobalEnums, SysBack, SysText
		HighContrastStyle ColorLineLabels, SysBack, SysText
		HighContrastStyle ColorLocalVariables, SysBack, SysText
		HighContrastStyle ColorMacros, SysBack, SysText
		HighContrastStyle ColorGlobalNamespaces, SysBack, SysText
		HighContrastStyle ColorProperties, SysBack, SysText
		HighContrastStyle ColorSharedVariables, SysBack, SysText
		HighContrastStyle ColorSubs, SysBack, SysText
		HighContrastStyle ColorGlobalTypes, SysBack, SysText

		'' The line-number margin is the defect that started this: the theme asks for a near-black
		'' number on a near-white margin, the system supplies the background and not the
		'' foreground, and the numbers disappear. Pin both ends to system colours.
		LineNumbers.ForegroundOption = SysText
		LineNumbers.BackgroundOption = SysBack
		GetColors LineNumbers, SysText, SysBack

		'' Selection and the current-line/word highlights must follow the system too, or they
		'' repaint a theme colour over text that is now system-coloured.
		Selection.ForegroundOption = GetSysColor(COLOR_HIGHLIGHTTEXT)
		Selection.BackgroundOption = GetSysColor(COLOR_HIGHLIGHT)
		GetColors Selection, GetSysColor(COLOR_HIGHLIGHTTEXT), GetSysColor(COLOR_HIGHLIGHT)
		CurrentLine.BackgroundOption = GetSysColor(COLOR_BTNFACE)
		GetColors CurrentLine, SysText, GetSysColor(COLOR_BTNFACE)
		CurrentWord.BackgroundOption = GetSysColor(COLOR_BTNFACE)
		GetColors CurrentWord, SysText, GetSysColor(COLOR_BTNFACE)
		GetColors FoldLines, SysText
	End If
End Sub

pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Help")
LoadHelp
pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Snippets")
LoadSnippets

pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Toolbox")

Function CheckCompilerPaths As Boolean
	Dim As UString CompilerExe = GetFullPath(GetBundledCompilerExe())
	If FileExists(CompilerExe) Then Return True
	MsgBox ("Bundled compiler not found.") & !"\r" & CompilerExe, , mtWarning
	Return False
End Function

Dim Shared As Boolean bSharedFind
Sub frmMain_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	tabItemHeight = tabLeft.ItemHeight(0) + 4
	pnlPropertyValue.SendToBack
	pnlToolBox_Resize *pnlToolBox.Designer, pnlToolBox, pnlToolBox.Width, pnlToolBox.Height + 1
		SetProp(frmMain.Handle, "VisualFBEditorApp", @VisualFBEditorApp)
	
	pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Toolbox")
	LoadToolBox
	pnlToolBox_Resize *pnlToolBox.Designer, pnlToolBox, pnlToolBox.Width, pnlToolBox.Height
	
	pfTemplates->Visible = False: pfTemplates->Parent = @frmMain: pfTemplates->CreateWnd
	
	pnlRightPin.Height = tbRight.Height
	pnlLeftPin.Height = tbLeft.Height
	If Dir(ExePath & "/DebugInfo.log") <> "" Then
		CopyFileW ExePath & "/DebugInfo.log", ExePath & "/DebugInfo.bak", False
		Kill ExePath & "/DebugInfo.log"
	End If
	frmMain.Width = iniSettings.ReadInteger("MainWindow", "Width", 1024)
	'' A key that exists but is blank (e.g. Width=) reads back as 0 -- IniFile's
	'' ReadInteger only falls back to its default when the key is absent, not when
	'' its value is empty (mff/IniFile.bas:298-312) -- which produced a near-0x0 main
	'' window (owner-reported 2026-07-11). Guard the same way LeftWidth/BottomHeight
	'' already do a few lines below.
	If frmMain.Width < 400 Then frmMain.Width = 1024
	frmMain.Height = iniSettings.ReadInteger("MainWindow", "Height", 768)
	If frmMain.Height < 300 Then frmMain.Height = 768
	tabLeftWidth = iniSettings.ReadInteger("MainWindow", "LeftWidth", DEFAULT_LEFT_PANEL_WIDTH)
	If tabLeftWidth < 100 Then tabLeftWidth = DEFAULT_LEFT_PANEL_WIDTH
	tabRightWidth = iniSettings.ReadInteger("MainWindow", "RightWidth", tabRightWidth)
	tabBottomHeight = iniSettings.ReadInteger("MainWindow", "BottomHeight", tabBottomHeight)
	If tabBottomHeight < MIN_BOTTOM_PANEL_HEIGHT Then tabBottomHeight = DEFAULT_BOTTOM_PANEL_HEIGHT
	bApplyingStartupLayout = True
	LoadSettingsIni()
	Dim bLeftClosed As Boolean = iniSettings.ReadBool("MainWindow", "LeftClosed", False)
	SetLeftClosedStyle bLeftClosed, iniSettings.ReadBool("MainWindow", "LeftCollapsed", bLeftClosed)
	Dim bRightClosed As Boolean = iniSettings.ReadBool("MainWindow", "RightClosed", False)
	SetRightClosedStyle bRightClosed, iniSettings.ReadBool("MainWindow", "RightCollapsed", bRightClosed)
	Dim bBottomClosed As Boolean = iniSettings.ReadBool("MainWindow", "BottomClosed", False)
	Dim bBottomCollapsed As Boolean = iniSettings.ReadBool("MainWindow", "BottomCollapsed", bBottomClosed)
	SetBottomClosedStyle bBottomClosed, bBottomCollapsed
	If bBottomClosed AndAlso Not bBottomCollapsed Then ShowBottom
	UpdateBottomPinLayout
	bApplyingStartupLayout = False
	ShowProjectFolders = iniSettings.ReadBool("MainWindow", "ProjectFolders", True)
	If ShowProjectFolders Then
		miShowWithFolders->RadioItem = True
	Else
		miShowWithoutFolders->RadioItem = True
	End If
	tbForm.Buttons.Item(0)->Checked = iniSettings.ReadBool("MainWindow", "ToolLabels", True)
	ChangeUseDebugger iniSettings.ReadBool("MainWindow", "UseDebugger", False)
	ChangeShowSymbolsTooltipsOnMouseHover GlobalSettings.ShowSymbolsTooltipsOnMouseHover, 0
	ChangeAutoComplete AutoComplete, 0
	ChangeParameterInfo ParameterInfoShow, 0
	WLet(RecentFiles, SanitizeIniOptionalPath(iniSettings.ReadString("MainWindow", "RecentFiles", "")))
	WLet(RecentFile, SanitizeIniOptionalPath(iniSettings.ReadString("MainWindow", "RecentFile", "")))
	WLet(RecentProject, SanitizeIniOptionalPath(iniSettings.ReadString("MainWindow", "RecentProject", "")))
	WLet(RecentFolder, SanitizeIniOptionalPath(iniSettings.ReadString("MainWindow", "RecentFolder", "")))
	'' Values above may be a portable ".\"-relative path (see MakePathPortable, SaveWorkspace's
	'' same convention) -- resolve against the CURRENT ExePath so a moved/renamed install folder
	'' still finds them. Guard on non-empty first: GetFullPath("") returns ExePath itself, not "".
	If *RecentFiles <> "" Then WLet(RecentFiles, GetFullPath(*RecentFiles))
	If *RecentFile <> "" Then WLet(RecentFile, GetFullPath(*RecentFile))
	If *RecentProject <> "" Then WLet(RecentProject, GetFullPath(*RecentProject))
	If *RecentFolder <> "" Then WLet(RecentFolder, GetFullPath(*RecentFolder))
	'' Drop any "last opened" pointer whose target no longer exists (project/file deleted
	'' or moved outside the IDE). Otherwise the IDE keeps treating a deleted project as the
	'' most recent one -- it can't be reopened, and it lingers as the remembered project.
	'' The MRU lists get the same treatment in SanitizeMRUListsOnLoad; these four are the
	'' separate single-value pointers. Cleared here, they are written back empty on the
	'' next settings save, so the staleness does not persist.
	If *RecentFiles <> "" AndAlso Not FileExists(*RecentFiles) Then WLet(RecentFiles, "")
	If *RecentFile <> "" AndAlso Not FileExists(*RecentFile) Then WLet(RecentFile, "")
	If *RecentProject <> "" AndAlso Not FileExists(*RecentProject) Then WLet(RecentProject, "")
	If *RecentFolder <> "" AndAlso Not FolderExists(*RecentFolder) Then WLet(RecentFolder, "")
	'' The toolbars are all shown or all hidden -- one setting, one menu item (owner decision,
	'' 2026-07-19). This replaces five independent ShowXxxToolBar keys and the View ▸ Toolbars
	'' submenu that drove them. A user who had hidden individual bars gets them all back; that is
	'' the intent, since a half-populated bar with no obvious way back was the problem.
	'' Bands are Standard(0), Edit(1), Project(2), Run(3), Format(4).
	ShowToolBars = iniSettings.ReadBool("MainWindow", "ShowToolBars", True)
	'' Retired keys: the five per-toolbar ones, the Build/Debug bars folded into Run back in
	'' 13.3.A O3, and Tip of the Day. Removed so they cannot linger in a user's settings file.
	iniSettings.KeyRemove("MainWindow", "ShowStandardToolBar")
	iniSettings.KeyRemove("MainWindow", "ShowEditToolBar")
	iniSettings.KeyRemove("MainWindow", "ShowProjectToolbar")
	iniSettings.KeyRemove("MainWindow", "ShowFormatToolbar")
	iniSettings.KeyRemove("MainWindow", "ShowRunToolbar")
	iniSettings.KeyRemove("MainWindow", "ShowBuildToolbar")
	iniSettings.KeyRemove("MainWindow", "ShowDebugToolbar")
	iniSettings.KeyRemove("MainWindow", "ShowTipoftheDay")
	iniSettings.KeyRemove("MainWindow", "ShowTipoftheDayIndex")
	ApplyToolBarVisibility
	'Dim As Integer Subsystem = iniSettings.ReadInteger("MainWindow", "Subsystem", 0)
	tbtNotSetted->Checked = True
	'Select Case Subsystem
	'Case 0: tbtNotSetted->Checked = True
	'Case 1: tbtConsole->Checked = True
	'Case 2: tbtGUI->Checked = True
	'End Select
	windmain = frmMain.Handle
	htab2    = ptabCode->Handle
	tviewvar = tvVar.Handle
	tviewprc = tvPrc.Handle
	tviewthd = tvThd.Handle
	tviewwch = tvWch.Handle
	DragAcceptFiles(frmMain.Handle, True)

	App.Title = App.Title & " (" & ("64-bit") & ")"
	frmMain.Text = App.Title
	pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Check compiler paths")
	
	pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Add-Ins")
	LoadAddIns
	pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Tools")
	LoadTools
	
	bSharedFind = CheckCompilerPaths

		'' Pin the three rows first, then maximise only the LAST band on each one. Maximising a band
		'' makes it fill its row, so maximising a band that shares a row (Standard or Edit) would
		'' shove its neighbours onto rows of their own -- which is exactly the reflow this is meant
		'' to stop. Rows are Standard+Edit+Project / Run / Format, so the last-on-row bands are
		'' 2, 3 and 4.
		''
		'' 13.3.A history worth keeping: this loop was once a hardcoded "0 To 5" assuming 7 bands,
		'' and crashed on startup (SIGSEGV in ReBarBand.Maximize) once the count dropped to 5,
		'' because Bands.Item(i) returns a null pointer for an out-of-range i. Hence the guard.
		LockToolBarRows
		If MainReBar.Bands.Count >= 5 Then
			For i As Integer = 2 To 4
				If MainReBar.Bands.Item(i) <> 0 Then MainReBar.Bands.Item(i)->Maximize
			Next i
		End If
	'frmMain.RequestAlign
End Sub

For i As Integer = 48 To 57
	symbols(i - 48) = i
Next
For i As Integer = 97 To 102
	symbols(i - 87) = i
Next

Function IsNumeric(ByRef subject As Const WString, base_ As Integer = 10) As Boolean
	If subject = "" OrElse subject = "." OrElse subject = "+" OrElse subject = "-" Then Return False
	Err = 0
	
	If base_ < 2 OrElse base_ > 16 Then
		Err = 1000
		Return False
	End If
	
	Dim t As String = LCase(subject)
	
	If (t[0] = plus) OrElse (t[0] = minus) Then
		t = Mid(t, 2)
	End If
	
	If Left(t, 2) = "&h" Then
		If base_ <> 16 Then Return False
		t = Mid(t, 3)
	End If
	
	If Left(t, 2) = "&o" Then
		If base_ <> 8 Then Return False
		t = Mid(t, 3)
	End If
	
	If Left(t, 2) = "&b" Then
		If base_ <> 2 Then Return False
		t = Mid(t, 3)
	End If
	
	If Len(t) = 0 Then Return False
	Dim As Boolean isValid, hasDot = False
	
	For i As Integer = 0 To Len(t) - 1
		isValid = False
		
		For j As Integer = 0 To base_ - 1
			If t[i] = symbols(j) Then
				isValid = True
				Exit For
			End If
			If t[i] = dot Then
				If CInt(Not hasDot) AndAlso (base_ = 10) Then
					hasDot = True
					isValid = True
					Exit For
				End If
				Return False ' either more than one dot or not base 10
			End If
		Next j
		
		If Not isValid Then Return False
	Next i
	
	Return True
End Function

Function utf16BeByte2wchars( ta() As UByte ) ByRef As WString
	Type mstring
		p As WString Ptr ' pointer to wstring buffer
		l As UInteger ' length of string
	End Type
	Dim a As UInteger = 0
	Dim tal As UInteger = UBound(ta)
	Dim mstr As mstring
	
	'this is never deallocated..
	mstr.p = _Allocate( 0.25 * (tal + 1) * Len(WString))
	
	' iterate array
	Do While a <= tal
		(*mstr.p)[mstr.l] = 256 * ta(a) + ta(a + 1)
		a += 2
		mstr.l += 1
	Loop
	
	(*mstr.p)[mstr.l] = 0
	Function = *mstr.p
End Function

'' Bring the MCP agent pipe into line with the AllowAgentControl setting. Called
'' from Tools > Options (OK) so toggling the checkbox takes effect without a restart.
Sub ReconcileAgentPipe()
	If AllowAgentControl Then
		If Not AgentPipeActive() Then StartAgentPipe(frmMain.Handle)
	Else
		If AgentPipeActive() Then StopAgentPipe()
	End If
	UpdateMcpAgentStatusBar()
End Sub

Sub frmMain_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	'' Agent MCP pipe (MCP_SERVER_PLAN.md): off by default; the INI gate stands in
	'' for the Tools > Options toggle until MCP Task 6 ships it. Started here (top
	'' of OnShow) rather than after pApp->Run in AstoriaIDE.bas -- frmMain.Show can
	'' block on a startup modal (Tip of the Day, further down) that opens its own
	'' message loop, so code after the Main.bas include wouldn't run until the user
	'' dismissed the tip. The window handle already exists once OnShow fires.
	Static As Boolean bAgentPipeStarted
	If Not bAgentPipeStarted Then
		bAgentPipeStarted = True
		If AllowAgentControl Then StartAgentPipe(frmMain.Handle)
		UpdateMcpAgentStatusBar()
	End If
	Var MainMaximized = iniSettings.ReadBool("MainWindow", "Maximized", False)
	If MainMaximized Then frmMain.WindowState = WindowStates.wsMaximized
	If GetLeftClosedStyle Then UpdateLeftPinLayout()
	UpdateBottomPinLayout
	'' Apply the saved bottom-pane state explicitly. Testing splitter.Visible here is unreliable
	'' before the form is fully realized: it can report False even when frmMain_Create restored
	'' BottomClosed=false/BottomCollapsed=false, which then collapsed a previously resizable pane.
	Dim As Boolean savedBottomClosed = iniSettings.ReadBool("MainWindow", "BottomClosed", False)
	Dim As Boolean savedBottomCollapsed = iniSettings.ReadBool("MainWindow", "BottomCollapsed", savedBottomClosed)
	If savedBottomClosed AndAlso savedBottomCollapsed Then CloseBottom Else ShowBottom

	'' Splash has no fixed display time -- it stays up for exactly as long as startup takes
	'' (SplashShownAt captured right after Show). Holding it open for the same length of time
	'' again here doubles its total visible duration (owner request, 2026-07-10).
	Dim As Integer SplashExtraMs = CInt((Timer - SplashShownAt) * 1000)
	If SplashExtraMs > 0 Then Sleep(SplashExtraMs)
	pfSplash->CloseForm

	'' --mcp-agent: the sidecar auto-launched us for agent control (MCP). Suppress the
	'' interactive startup modals (New Project when there's nothing to reopen, and Tip of
	'' the Day) -- they would block the UI thread while the agent drives the IDE over the
	'' pipe, and the agent opens/creates whatever project it wants itself. The last
	'' workspace still reloads as normal, so get_status reflects the prior project.
	Dim As Boolean bAgentLaunched = (InStr(LCase(Command(-1)), "--mcp-agent") > 0)
	Var File = Command(-1)
	Var Pos1 = InStr(File, "2>CON")
	Var bFileOpening = False
	If Pos1 > 0 Then File = Left(File, Pos1 - 1)
	If bAgentLaunched Then File = ""   '' the only arg is our flag, not a file to open
	If File <> "" AndAlso Right(LCase(File), 4) <> ".exe" Then
		bFileOpening = True
	End If
	If bFileOpening Then
		OpenFiles GetFullPath(File)
	ElseIf bSharedFind AndAlso CBool(WhenVisualFBEditorStarts = 1 OrElse WhenVisualFBEditorStarts = 2) Then
		AddNew ExePath & WindowsSlash & "Templates" & WindowsSlash & WGet(DefaultProjectFile)
	Else
		mApplyingWorkspaceLoad = True
		Var bWorkspaceLoaded = LoadWorkspace()
		mApplyingWorkspaceLoad = False
		RunDeferredFormDesign()
		' Reloaded-project startup gap: AddProject's tn->SelectItem (called from inside LoadWorkspace)
		' silently no-ops because the tree control's Win32 handle isn't realized yet at that point in
		' startup -- so tvExplorer.SelectedNode is still 0 here, not just un-refreshed. Re-select the
		' project node now that the handle exists, then refresh menu state, so Close Project/Save
		' Project/etc. are correct from the first frame instead of only after a manual tree click.
		Var tnLoadedProject = GetOpenProjectNode()
		If tnLoadedProject <> 0 Then tnLoadedProject->SelectItem
		ChangeMenuItemsEnabled
		' Nothing to reopen (fresh install, or a workspace with no surviving project/tabs): prompt the
		' user with File > New Project so they choose the project type, instead of landing on an empty
		' IDE. This is the original design intent (see the commented Case 1: NewProject below).
		' Cancelling just leaves the empty IDE, which is fine.
		If Not bWorkspaceLoaded AndAlso Not bAgentLaunched Then
			NewProject
		End If
	End If
	'	Var FILE = Command(-1)
	'	Var Pos1 = InStr(file, "2>CON")
	'	If Pos1 > 0 Then file = Left(file, Pos1 - 1)
	'	If FILE <> "" AndAlso Right(LCase(FILE), 4) <> ".exe" Then
	'		OpenFiles GetFullPath(FILE)
	'	ElseIf bFind Then
	'		WLet RecentFiles, iniSettings.ReadString("MainWindow", "RecentFiles", "")
	'		Select Case WhenVisualFBEditorStarts
	'		Case 1: NewProject 'pfTemplates->ShowModal
	'		Case 2: AddNew WGet(DefaultProjectFile)
	'		Case 3: WLet RecentFiles, iniSettings.ReadString("MainWindow", "RecentFiles", "")
	'			'Auto Load the last one.
	'			OpenFiles GetFullPath(*RecentFiles)
	'		End Select
	'	End If
	bApplyingStartupLayout = True
	ActivateMainWindow()
	' ActivateMainWindow can disturb focus but must not replace the saved pane state.
	If savedBottomClosed AndAlso savedBottomCollapsed Then CloseBottom Else ShowBottom
	bApplyingStartupLayout = False
	SetDebugTabsVisible UseDebugger
	ChangeEnabledDebug tvExplorer.Nodes.Count > 0, False, False
End Sub

'' Files found changed on disk and awaiting the reload prompt.
''
'' Filenames rather than TabWindow pointers, deliberately: the prompt runs after the activation
'' handler has returned, and a tab could be closed in between. A stale pointer would be a crash;
'' a stale filename simply finds no tab and is skipped.
'' Held as one newline-delimited string rather than an array of UString.
''
'' The first version of this used `Dim Shared gChangedFiles() As UString` with `ReDim Preserve`,
'' and that CRASHED THE IDE when the reload was accepted. UString owns a heap buffer, and FB's
'' ReDim Preserve relocates elements with a shallow copy: the old element's destructor then frees
'' a buffer the surviving element still points at. A double free, which surfaces at the next touch
'' rather than at the fault, so it looked like the reload was to blame. Never ReDim Preserve an
'' array of a heap-owning UDT.
''
'' A path cannot contain a newline, so it is a safe delimiter and this needs no dynamic UDT storage
'' at all. Each entry ends with a newline, so the string is either empty or newline-terminated.
Dim Shared gChangedList As UString
Dim Shared gInReloadPrompt As Boolean

Private Function ChangedCount(ByRef s As UString) As Integer
	Dim As Integer c, p = 1
	Do
		Dim As Integer q = InStr(p, s, !"\n")
		If q = 0 Then Exit Do
		c += 1
		p = q + 1
	Loop
	Return c
End Function

Private Function ChangedAt(ByRef s As UString, ByVal idx As Integer) As UString
	Dim As Integer c, p = 1
	Do
		Dim As Integer q = InStr(p, s, !"\n")
		If q = 0 Then Exit Do
		If c = idx Then Return Mid(s, p, q - p)
		c += 1
		p = q + 1
	Loop
	Return ""
End Function

Private Sub QueueChangedFile(ByRef FileName As WString)
	If Len(FileName) = 0 Then Exit Sub
	'' Bracket both sides with the delimiter so a path cannot match a longer path that ends with it.
	If InStr(!"\n" & LCase(gChangedList), !"\n" & LCase(FileName) & !"\n") > 0 Then Exit Sub
	gChangedList &= FileName & !"\n"
End Sub

Private Function FindTabByFileName(ByRef FileName As WString) As TabWindow Ptr
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb <> 0 AndAlso LCase(tb->FileName) = LCase(FileName) Then Return tb
		Next i
	Next j
	Return 0
End Function

'' Raised from the main window's message handler on WM_APP_FILECHANGED, never from the activation
'' handler itself. See ROADMAP 13.18: clicking the IDE to focus it used to be able to raise a modal
'' from inside OnActivateApp. A modal disables its owner, so the main window stopped responding to
'' clicks and ignored Close -- and a dialog raised from an activation handler is precisely the case
'' where it may not come to the front, leaving nothing on screen to answer and no way out but Task
'' Manager. Deferring it to a posted message means the prompt appears with the window in a normal,
'' fully activated state.
Sub PromptReloadChangedFiles()
	'' The prompt is modal, and activation can fire again while it is up. Without this the second
	'' post would stack another dialog behind the first.
	If gInReloadPrompt Then Exit Sub
	If Len(gChangedList) = 0 Then Exit Sub
	gInReloadPrompt = True

	'' Snapshot and clear before prompting, so anything detected while the dialog is open queues
	'' for the next round rather than being lost or re-shown. One plain UString copy -- no arrays.
	Dim As UString Files = gChangedList
	gChangedList = ""
	Dim As Integer n = ChangedCount(Files)

	'' One prompt for all of them. The old code raised one dialog per file inside the loop, so a
	'' git pull touching six open files meant six sequential modals.
	''
	'' FULL PATHS MUST NOT BE PUT ON A LINE OF THEIR OWN HERE. MsgBoxForm.Execute measures the text
	'' with DT_WORDBREAK into a FIXED content width (380 logical units). A path contains no spaces,
	'' so there is no break opportunity and the line is clipped at the right edge rather than
	'' wrapped. Every changed file in a project shares a long directory prefix, so clipping removes
	'' precisely the part that tells them apart: two different files render as two identical-looking
	'' lines. That is not hypothetical -- it is how this was found, with the owner reasonably
	'' reporting that only one of two changed files had been listed.
	''
	'' So the shared folder is shown once and the files are listed by name, which fits.
	Dim As UString Folder = GetFolderName(ChangedAt(Files, 0), False)
	Dim As Boolean bSameFolder = True
	For i As Integer = 1 To n - 1
		If LCase(GetFolderName(ChangedAt(Files, i), False)) <> LCase(Folder) Then
			bSameFolder = False
			Exit For
		End If
	Next i

	Dim As UString Msg_
	If n = 1 Then
		Msg_ = ("File was changed by another application. Reload it?") & !"\r" & !"\r" & _
			GetFileName(ChangedAt(Files, 0)) & !"\r" & ("in ") & Folder
	Else
		Msg_ = ("These files were changed by another application. Reload them?") & !"\r"
		If bSameFolder Then Msg_ &= !"\r" & ("in ") & Folder & !"\r"
		'' Cap the list so a large pull cannot produce a dialog taller than the screen.
		Dim As Integer shown = n
		If shown > 12 Then shown = 12
		For i As Integer = 0 To shown - 1
			'' Bare name when they share a folder; otherwise the full path, which may still clip --
			'' but a mixed-folder batch is the rare case and the names still differ at the front.
			If bSameFolder Then
				Msg_ &= !"\r" & GetFileName(ChangedAt(Files, i))
			Else
				Msg_ &= !"\r" & ChangedAt(Files, i)
			End If
		Next i
		If n > shown Then Msg_ &= !"\r" & ("... and ") & Str(n - shown) & (" more")
	End If

	'' Belt and braces, per the MsgBoxForm z-order fix: make sure the window that owns the dialog
	'' is restored and foreground before the dialog appears.
	If frmMain.WindowState = WindowStates.wsMinimized Then ShowWindow frmMain.Handle, SW_RESTORE
	SetForegroundWindow frmMain.Handle

	If MsgBox(Msg_, ("Files Changed"), mtQuestion, btYesNo) = mrYes Then
		For i As Integer = 0 To n - 1
			Dim tb As TabWindow Ptr = FindTabByFileName(ChangedAt(Files, i))
			'' Skipped rather than assumed: the tab may have been closed while the prompt was up.
			If tb = 0 Then Continue For
			tb->txtCode.Changing "Reload"
			tb->txtCode.LoadFromFile(tb->FileName, tb->FileEncoding, tb->NewLineType)
			tb->FileEncoding = FileEncodings.Utf8
			tb->NewLineType = NewLineTypes.WindowsCRLF
			tb->txtCode.Changed "Reload"
			tb->DateFileTime = GetFileLastWriteTime(tb->FileName)
		Next i
	End If

	gInReloadPrompt = False
End Sub

Sub frmMain_ActivateApp(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	Static bInActivateApp As Boolean
	If bInActivateApp Then Exit Sub
	bInActivateApp = True
	Dim tb As TabWindow Ptr
	Dim As Boolean bAnyChanged
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb = 0 Then Continue For
			If InStr(tb->FileName, "/") > 0 OrElse InStr(tb->FileName, "\") > 0 Then
				If FileTimeToVariantTime(GetFileLastWriteTime(tb->FileName)) <> FileTimeToVariantTime(tb->DateFileTime) Then
					DbgTrace("ActivateApp.changed", tb->FileName)
					QueueChangedFile(tb->FileName)
					bAnyChanged = True
				End If
				'' Stamped here, as before, so a declined reload does not re-prompt on every
				'' subsequent activation.
				tb->DateFileTime = GetFileLastWriteTime(tb->FileName)
			End If
		Next i
	Next j
	bInActivateApp = False
	'' NO MODAL UI IN THIS HANDLER. Post and return; the prompt runs once activation is complete.
	If bAnyChanged Then PostMessageW(frmMain.Handle, WM_APP_FILECHANGED, 0, 0)
End Sub

Sub SaveMainWindowPanelLayout()
	iniSettings.WriteBool("MainWindow", "LeftClosed", GetLeftClosedStyle)
	iniSettings.WriteBool("MainWindow", "LeftCollapsed", IsLeftCollapsed)
	iniSettings.WriteInteger("MainWindow", "LeftWidth", tabLeftWidth)
	If tabLeft.SelectedTabIndex >= 0 Then leftSelectedTabIndex = tabLeft.SelectedTabIndex
	iniSettings.WriteInteger("MainWindow", "LeftSelectedTab", leftSelectedTabIndex)
	iniSettings.WriteBool("MainWindow", "RightClosed", GetRightClosedStyle)
	iniSettings.WriteBool("MainWindow", "RightCollapsed", IsRightCollapsed)
	iniSettings.WriteInteger("MainWindow", "RightWidth", tabRightWidth)
	If tabRight.SelectedTabIndex >= 0 Then rightSelectedTabIndex = tabRight.SelectedTabIndex
	iniSettings.WriteInteger("MainWindow", "RightSelectedTab", rightSelectedTabIndex)
	iniSettings.WriteBool("MainWindow", "BottomClosed", GetBottomClosedStyle)
	iniSettings.WriteBool("MainWindow", "BottomCollapsed", IsBottomCollapsed)
	If tabBottomHeight >= MIN_BOTTOM_PANEL_HEIGHT Then iniSettings.WriteInteger("MainWindow", "BottomHeight", tabBottomHeight)
End Sub

Private Sub SaveTabPagePlacement(ByRef KeyName As WString, ByRef tp As TabPage Ptr)
	If tp = 0 OrElse tp->Parent = 0 Then
		iniSettings.WriteString("MainWindow", KeyName & "Parent", "")
		iniSettings.WriteInteger("MainWindow", KeyName & "Index", -1)
		Return
	End If
	iniSettings.WriteString("MainWindow", KeyName & "Parent", tp->Parent->Name)
	iniSettings.WriteInteger("MainWindow", KeyName & "Index", tp->Parent->IndexOfTab(tp))
End Sub

Sub frmMain_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
	On Error Goto ErrorHandler
	DbgTrace("Close.enter", "iFlagStartDebug=" & iFlagStartDebug & " Running=" & Running & " iGlPid=" & iGlPid)
	SaveMainWindowPanelLayout()
	SaveWorkspace()
	If Not CloseAllDocuments Then Action = 0: Return
	FormClosing = True
	'' Agent MCP pipe: stop the listener and join its worker before teardown so a
	'' worker mid-command can't touch dying windows (no-op when never started).
	StopAgentPipe()
	If frmMain.WindowState <> WindowStates.wsMaximized Then
		iniSettings.WriteInteger("MainWindow", "Width", frmMain.Width)
		iniSettings.WriteInteger("MainWindow", "Height", frmMain.Height)
	End If
	iniSettings.WriteBool("MainWindow", "Maximized", frmMain.WindowState = WindowStates.wsMaximized)
	iniSettings.WriteBool("MainWindow", "ProjectFolders", ShowProjectFolders)
	iniSettings.WriteBool("MainWindow", "ToolLabels", tbForm.Buttons.Item(0)->Checked)
	iniSettings.WriteBool("MainWindow", "UseDebugger", UseDebugger)
	'iniSettings.WriteInteger("MainWindow", "Subsystem", IIf(tbtConsole->Checked, 1, IIf(tbtGUI->Checked, 2, 0)))
	iniSettings.WriteBool("MainWindow", "ShowMainToolBar", ShowMainToolBar)
	iniSettings.WriteBool("MainWindow", "ShowToolBars", ShowToolBars)
	iniSettings.WriteInteger("MainWindow", "MainHeight", frmMain.Height)
	SaveTabPagePlacement("Project", tpProject)
	SaveTabPagePlacement("ToolBox", tpToolbox)
	SaveTabPagePlacement("Properties", tpProperties)
	SaveTabPagePlacement("Events", tpEvents)
	SaveTabPagePlacement("Output", tpOutput)
	SaveTabPagePlacement("Problems", tpProblems)
	SaveTabPagePlacement("Suggestions", tpSuggestions)
	SaveTabPagePlacement("Find", tpFind)
	SaveTabPagePlacement("ToDo", tpToDo)
	SaveTabPagePlacement("ChangeLog", tpChangeLog)
	SaveTabPagePlacement("Immediate", tpImmediate)
	SaveTabPagePlacement("Locals", tpLocals)
	SaveTabPagePlacement("Globals", tpGlobals)
	SaveTabPagePlacement("Procedures", tpProcedures)
	SaveTabPagePlacement("Threads", tpThreads)
	SaveTabPagePlacement("Watches", tpWatches)
	SaveTabPagePlacement("Memory", tpMemory)
	SaveTabPagePlacement("Profiler", tpProfiler)
	iniSettings.WriteInteger("Options", "HistoryCodeCleanDay", HistoryCodeCleanDay)
	
	SaveMRU
	
	iniSettings.WriteString("MainWindow", "RecentFiles", MakePathPortable(*RecentFiles))
	iniSettings.WriteString("MainWindow", "RecentFile", MakePathPortable(*RecentFile))
	iniSettings.WriteString("MainWindow", "RecentProject", MakePathPortable(*RecentProject))
	iniSettings.WriteString("MainWindow", "RecentFolder", MakePathPortable(*RecentFolder))
	If mChangeLogEdited Then txtChangeLog.SaveToFile(GetChangeLogPath(MainNode)) '
	UnLoadAddins
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
End Sub

'' Diagnostic instrument for ROADMAP 13.28 part 3: Alt+C, Alt+R and Alt+G do not open their
'' menus, while Alt+F and Alt+T do, and a stock WinForms app with the same letters opens all
'' five on this machine. Three hypotheses formed by reading code have now been disproved, so
'' this measures what the window actually receives instead of proposing a fourth.
''
'' How to read the output:
''   WM_SYSKEYDOWN present, WM_SYSCHAR absent -> something consumed the key before translation
''                                               (TranslateAccelerator is the prime suspect)
''   WM_SYSCHAR present, WM_MENUCHAR follows  -> Windows saw the character and could NOT match
''                                               it to a menu item; the fault is in the menu data
''   WM_INITMENU / WM_INITMENUPOPUP           -> the menu did open
''
'' Enabled only when Temp/_astoria_menukeys.on exists, so a normal run costs nothing. It only
'' observes: it never sets Msg.Result and never returns, so message handling is unchanged.
Sub LogMenuKey(ByRef Tag As String, wp As WPARAM, lp As LPARAM)
	Dim As Integer FnLog = FreeFile_
	If Open(ExePath & "/Temp/_astoria_menukeys.log" For Append As #FnLog) = 0 Then
		Print #FnLog, Tag & "  wParam=&h" & Hex(wp) & "  lParam=&h" & Hex(lp)
		CloseFile_(FnLog)
	End If
End Sub

Sub frmMain_Message(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message)
		If bLogMenuKeys Then
			Select Case Msg.Msg
			Case WM_SYSKEYDOWN:    LogMenuKey("WM_SYSKEYDOWN   ", Msg.wParam, Msg.lParam)
			Case WM_SYSCHAR:       LogMenuKey("WM_SYSCHAR      ", Msg.wParam, Msg.lParam)
			Case WM_MENUCHAR:      LogMenuKey("WM_MENUCHAR     ", Msg.wParam, Msg.lParam)
			Case WM_INITMENU:      LogMenuKey("WM_INITMENU     ", Msg.wParam, Msg.lParam)
			Case WM_INITMENUPOPUP: LogMenuKey("WM_INITMENUPOPUP", Msg.wParam, Msg.lParam)
			Case WM_SYSCOMMAND
				'' DefWindowProc turns an unhandled WM_SYSCHAR on a CHILD window into
				'' WM_SYSCOMMAND / SC_KEYMENU (&hF100) sent to the TOP-LEVEL window, and that is
				'' the message that actually opens a menu -- lParam carries the character.
				'' So this splits the remaining search space for 13.28 part 3: if SC_KEYMENU
				'' arrives for Alt+F but not for Alt+C, the loss is below the form in the child's
				'' DefWindowProc path; if it arrives for both, the loss is in the menu search
				'' itself and the menu-bar data is back in scope despite measuring correct.
				''
				'' Filtered to SC_KEYMENU: WM_SYSCOMMAND also carries move/size/minimise traffic.
				'' Windows uses the low four bits of wParam internally, so mask before comparing.
				If (Msg.wParam And &hFFF0) = &hF100 Then LogMenuKey("SC_KEYMENU      ", Msg.wParam, Msg.lParam)
			End Select
		End If
		Select Case Msg.Msg
		Case WM_APP_AGENTCMD
			'' Agent MCP pipe: run the pending pipe command on the UI thread
			'' (see AgentPipe.bi / MCP_SERVER_PLAN.md section 5).
			AgentPipe_ExecutePendingOnUi()
			Msg.Result = 0
			Return
		Case WM_APP_FILECHANGED
			'' Files changed on disk: prompt now that activation has completed, never from inside
			'' the activation handler itself (ROADMAP 13.18).
			PromptReloadChangedFiles()
			Msg.Result = 0
			Return
		Case WM_COPYDATA
			Dim pCDS As COPYDATASTRUCT Ptr = Cast(COPYDATASTRUCT Ptr, Msg.lParam)
			Dim As ZString Ptr FileNameFromCmdLine = Cast(ZString Ptr, pCDS->lpData)
			If FileNameFromCmdLine <> 0 Then
				'' An empty payload means a second Astoria was launched with no file named. There
				'' is nothing to open, but the user still asked for the IDE, so raise it anyway
				'' rather than ignoring them (ROADMAP 13.29).
				If Len(*FileNameFromCmdLine) > 0 Then OpenFiles *FileNameFromCmdLine
				If frmMain.WindowState = WindowStates.wsMinimized Then ShowWindow frmMain.Handle, SW_RESTORE
				SetForegroundWindow frmMain.Handle
				SetFocus frmMain.Handle
				Msg.Result = -1
				Return
			End If
		End Select
End Sub

'' Force the toolbars into three fixed rows -- Standard+Edit+Project, then Run, then Format --
'' regardless of how wide the window or monitor is. RBBS_BREAK (ReBarBand.Break) starts a new row,
'' so a break on Run and on Format pins the grouping; without it the ReBar reflows on every resize
'' and a wide monitor collapses everything onto one very long line of icons (owner decision,
'' 2026-07-19). Re-applied after any visibility change, because hiding and re-showing bands
'' otherwise lets them reflow.
'' ROADMAP 13.28 pt 3 bisection scaffolding -- TEMPORARY. With ASTORIA_BISECT unset this returns
'' False for everything and startup is untouched, so the shipped behaviour is unchanged.
Function BisectSkip(ByRef Part As String) As Boolean
	Static As String Spec
	Static As Boolean Loaded
	If Not Loaded Then
		Spec = LCase(Environ("ASTORIA_BISECT"))
		Loaded = True
	End If
	If Spec = "" Then Return False
	Return InStr("," & Spec & ",", "," & LCase(Part) & ",") > 0
End Function

Sub LockToolBarRows
	If MainReBar.Bands.Count < 5 Then Exit Sub
	MainReBar.Bands.Item(0)->Break = False   '' Standard  -- row 1
	MainReBar.Bands.Item(1)->Break = False   '' Edit      -- row 1
	MainReBar.Bands.Item(2)->Break = False   '' Project   -- row 1
	MainReBar.Bands.Item(3)->Break = True    '' Run       -- row 2
	MainReBar.Bands.Item(4)->Break = True    '' Format    -- row 3
End Sub

'' All five toolbars are shown or hidden together; there is no per-toolbar choice any more.
Sub ApplyToolBarVisibility
	For i As Integer = 0 To MainReBar.Bands.Count - 1
		If MainReBar.Bands.Item(i) <> 0 Then MainReBar.Bands.Item(i)->Visible = ShowToolBars
	Next i
	If miToolBars <> 0 Then miToolBars->Checked = ShowToolBars
	If ShowToolBars Then LockToolBarRows
End Sub

pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Command bars")
'' The right-click handler that popped the View ▸ Toolbars submenu is gone with the submenu --
'' there is nothing left to choose, and leaving it wired would have dereferenced a SubMenu that no
'' longer exists.


MainReBar.Name = "MainReBar"
MainReBar.Align = DockStyle.alTop

rbLeft.Name = "LeftReBar"
rbLeft.Align = DockStyle.alLeft

rbRight.Name = "LeftReBar"
rbRight.Align = DockStyle.alRight

rbBottom.Name = "BottomReBar"
rbBottom.Align = DockStyle.alBottom

frmMain.Name = "frmMain"
frmMain.KeyPreview = True
frmMain.Icon.LoadFromResourceID(1)
'frmMain.StartPosition = FormStartPosition.DefaultBounds
frmMain.MainForm = True
	frmMain.Text = "Astoria IDE (x64)"
frmMain.OnActiveControlChange = @frmMain_ActiveControlChanged
frmMain.OnActivateApp = @frmMain_ActivateApp
frmMain.OnKeyDown = @frmMain_KeyDown
frmMain.OnResize = @frmMain_Resize
frmMain.OnCreate = @frmMain_Create
frmMain.OnShow = @frmMain_Show
frmMain.OnClose = @frmMain_Close
frmMain.OnDropFile = @frmMain_DropFile
frmMain.OnMessage = @frmMain_Message
frmMain.Menu = @mnuMain
'' 13.3.A O3: bands are now Standard(0), Edit(1), Project(2), Run(3), Format(4) -- Build/Debug
'' folded into Run, so the ReBar drops from 7 bands to 5. See the matching Item(N) updates in
'' AstoriaIDE.bas's toolbar-toggle Cases and this Sub's own visibility/save code below.
If Not BisectSkip("toolbars") Then      '' 13.28 pt 3 bisection -- TEMPORARY
	MainReBar.Add @tbStandard
	MainReBar.Add @tbEdit
	MainReBar.Add @tbProject
	MainReBar.Add @tbRun
	MainReBar.Add @tbFormat
	'rbBottom.Add @tbFormat
	frmMain.Add @MainReBar
End If
'frmMain.Add @rbLeft
'frmMain.Add @rbRight
'#else
'	tbStandard.Align = DockStyle.alTop
'	frmMain.Add @tbStandard
'#endif
pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("Main Form")
If Not BisectSkip("statusbar") Then frmMain.Add @stBar      '' 13.28 pt 3 bisection -- TEMPORARY
'frmMain.Add @rbBottom
If Not BisectSkip("leftpanel") Then                          '' 13.28 pt 3 bisection -- TEMPORARY
	frmMain.Add @pnlLeft
	frmMain.Add @splLeft
End If
If Not BisectSkip("rightpanel") Then                         '' 13.28 pt 3 bisection -- TEMPORARY
	frmMain.Add @pnlRight
	frmMain.Add @splRight
End If
If Not BisectSkip("bottompanel") Then                        '' 13.28 pt 3 bisection -- TEMPORARY
	frmMain.Add @pnlBottom
	frmMain.Add @splBottom
End If
frmMain.Add ptabPanel
frmMain.Show

Sub OnProgramStart() Constructor
End Sub

Sub OnProgramQuit() Destructor
	If bQuitting Then Exit Sub
	WDeAllocate(ProjectsPath)
	WDeAllocate(LastOpenPath)
	WDeAllocate(DefaultMakeTool)
	WDeAllocate(CurrentMakeTool1)
	WDeAllocate(CurrentMakeTool2)
	WDeAllocate(MakeToolPath1)
	WDeAllocate(MakeToolPath2)
	WDeAllocate(DefaultTerminal)
	WDeAllocate(CurrentTerminal)
	WDeAllocate(TerminalPath)
	WDeAllocate(DefaultCompiler64)
	WDeAllocate(CurrentCompiler64)
	WDeAllocate(Compiler64Path)
	WDeAllocate(Compiler64Arguments)
	WDeAllocate(Make1Arguments)
	WDeAllocate(Make2Arguments)
	WDeAllocate(RunArguments)
	WDeAllocate(Debug64Arguments)
	WDeAllocate(RecentFiles)
	WDeAllocate(RecentFile)
	WDeAllocate(RecentProject)
	WDeAllocate(RecentFolder)
	WDeAllocate(DefaultHelp)
	WDeAllocate(HelpPath)
	WDeAllocate(DefaultBuildConfiguration)
	WDeAllocate(KeywordsHelpPath)
	WDeAllocate(AsmKeywordsHelpPath)
	WDeAllocate(CurrentInterfaceTheme)
	WDeAllocate(CurrentTheme)
	WDeAllocate(DefaultProjectFile)
	WDeAllocate(EditorFontName)
	WDeAllocate(InterfaceFontName)
	WDeAllocate(MFFPath)
	WDeAllocate(MFFDll)
	WDeAllocate(gSearchSave)
	WDeAllocate(EnvironmentVariables)
	WDeAllocate(CommandPromptFolder)
	WDeAllocate(PersonalName)
	WDeAllocate(PersonalCompany)
	WDeAllocate(PersonalWebsite)
	WDeAllocate(PersonalEmail)
	WDeAllocate(PersonalAddress)
	WDeAllocate(PersonalLicenseOtherText)
	WDeAllocate(PersonalGitLogin)
	WDeAllocate(PersonalGitUserName)
	WDeAllocate(PersonalGitEmail)
	'For i As Integer = 0 To Threads.Count - 1
	'	If Threads.Item(i) <> 0 Then ThreadWait Threads.Item(i)
	'Next
	MutexDestroy tlockToDo
	MutexDestroy tlock
	MutexDestroy tlockSave
	MutexDestroy tlockGDB
	MutexDestroy tlockSuggestions
	Dim As UserToolType Ptr tt
	For i As Integer = 0 To Tools.Count - 1
		_Delete(Cast(UserToolType Ptr, Tools.Item(i)))
	Next
	Dim As ToolType Ptr Tool
	For i As Integer = 0 To pCompilers->Count - 1
		Tool = pCompilers->Item(i)->Object
		_Delete(Tool)
	Next i
	For i As Integer = 0 To pMakeTools->Count - 1
		Tool = pMakeTools->Item(i)->Object
		_Delete(Tool)
	Next i
	For i As Integer = 0 To pTerminals->Count - 1
		Tool = pTerminals->Item(i)->Object
		_Delete(Tool)
	Next i
	Dim As WStringOrStringList Ptr keywordlist
	For i As Integer = 0 To KeywordLists.Count - 1
		keywordlist = KeywordLists.Object(i)
		_Delete(keywordlist)
	Next i
	Dim As TabPanel Ptr tp
	For i As Integer = 0 To TabPanels.Count - 1
		tp = TabPanels.Item(i)
		_Delete(tp)
	Next i
	Dim As EditControlContent Ptr File
	For i As Integer = IncludeFiles.Count - 1 To 0 Step -1
		File = IncludeFiles.Object(i)
		If File Then _Delete(File)
	Next
	IncludeFiles.Clear
	Dim As Library Ptr CtlLibrary
	For i As Integer = 0 To ControlLibraries.Count - 1
		CtlLibrary = ControlLibraries.Item(i)
		_Delete(CtlLibrary)
	Next
	Dim As TypeElement Ptr te, te1
	For i As Integer = pGlobalNamespaces->Count - 1 To 0 Step -1
		te = pGlobalNamespaces->Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			te1 = te->Elements.Object(j)
			te->Elements.Remove j
		Next
		_Delete( Cast(TypeElement Ptr, pGlobalNamespaces->Object(i)))
	Next
	For i As Integer = Snippets.Count - 1 To 0 Step -1
		te = Snippets.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, Snippets.Object(i)))
	Next
	For i As Integer = pComps->Count - 1 To 0 Step -1
		DeleteFromTypeElement(pComps->Object(i))
		'te = pComps->Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, pComps->Object(i)))
		''pComps->Remove i
	Next
	For i As Integer = pGlobalTypes->Count - 1 To 0 Step -1
		DeleteFromTypeElement(pGlobalTypes->Object(i))
		'te = pGlobalTypes->Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, pGlobalTypes->Object(i)))
		''pGlobalTypes->Remove i
	Next
	For i As Integer = TypesInFunc.Count - 1 To 0 Step -1
		te = TypesInFunc.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, TypesInFunc.Object(i)))
	Next
	For i As Integer = pGlobalEnums->Count - 1 To 0 Step -1
		te = pGlobalEnums->Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, pGlobalEnums->Object(i)))
		'pGlobalEnums->Remove i
	Next
	For i As Integer = EnumsInFunc.Count - 1 To 0 Step -1
		te = EnumsInFunc.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, EnumsInFunc.Object(i)))
	Next
	For i As Integer = pGlobalFunctions->Count - 1 To 0 Step -1
		te = pGlobalFunctions->Object(i)
		_Delete( Cast(TypeElement Ptr, pGlobalFunctions->Object(i)))
		'pGlobalFunctions->Remove i
	Next
	For i As Integer = GlobalFunctionsHelp.Count - 1 To 0 Step -1
		te = GlobalFunctionsHelp.Object(i)
		_Delete( Cast(TypeElement Ptr, GlobalFunctionsHelp.Object(i)))
		'GlobalFunctionsHelp.Remove i
	Next
	For i As Integer = GlobalAsmFunctionsHelp.Count - 1 To 0 Step -1
		te = GlobalAsmFunctionsHelp.Object(i)
		_Delete( Cast(TypeElement Ptr, GlobalAsmFunctionsHelp.Object(i)))
		'GlobalAsmFunctionsHelp.Remove i
	Next
	For i As Integer = pGlobalTypeProcedures->Count - 1 To 0 Step -1
		te = pGlobalTypeProcedures->Object(i)
		_Delete( Cast(TypeElement Ptr, pGlobalTypeProcedures->Object(i)))
		'pGlobalFunctions->Remove i
	Next
	For i As Integer = pGlobalArgs->Count - 1 To 0 Step -1
		te = pGlobalArgs->Object(i)
		_Delete( Cast(TypeElement Ptr, pGlobalArgs->Object(i)))
		'pGlobalArgs->Remove i
	Next
End Sub

#include once "SettingsService.bas"
#include once "PathUtils.bas"
#include once "Localization.bas"
#include once "BuildService.bas"

