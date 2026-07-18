'#########################################################
'#  Main.bi                                              #
'#  This file is part of AstoriaIDE                      #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

		#define UNICODE
	#include once "windows.bi"
#include once "mff/WStringList.bi"
#include once "mff/Dictionary.bi"
#include once "mff/Form.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Dialogs.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/TabControl.bi"
#include once "mff/ToolPalette.bi"
#include once "mff/TextBox.bi"
#include once "mff/StatusBar.bi" 'David Change
#include once "mff/IniFile.bi"
#include once "mff/HTTP.bi"
	#include once "mff/PageSetupDialog.bi"
	#include once "mff/PrintDialog.bi"
	#include once "mff/PrintPreviewDialog.bi"
	#include once "mff/Printer.bi"

		#define SettingsPath ExePath & "/Settings/astoria.ini"
	#define WorkspacePath ExePath & "/Settings/Workspace.ini"

	#define WindowsSlash "\"
	#define UnixSlash "/"

	' --- DR Phase 1 debugger trace (instrumentation only; strip after Phase 1) ---
	Declare Sub DbgTrace(ByRef tag As String, ByRef info As String = "")
	Declare Function DbgTraceEsc(ByRef s As String, ByVal iMax As Integer = 200) As String

	' --- DR-3 slice 2D: worker->UI marshal of the debug panels (bodies in Debug.bas) ---
	Declare Sub FillDebugPanelsOnUI()   ' UI thread: fill lvLocals/lvGlobals/lvThreads/lvWatches from staged raw data
	Declare Sub SnapshotWatchNames()    ' UI thread: refresh the worker-visible watch-name snapshot

	' --- DR-7: worker->UI marshal of Output text + watch-edit result + session-start panel clear ---
	Declare Sub FlushDebugOutputOnUI()  ' UI thread: apply queued ShowMessages/UpdateWatch/panel-clear

	' --- close-on-stop: close debugger-auto-opened tabs when a debug session ends ---
	Common Shared As Boolean bCloseDebugTabsPending   ' set by deinit (any thread), serviced by TimerProcGDB (UI thread)
	Declare Sub CloseDebuggerOpenedTabs()             ' UI thread: close tabs flagged OpenedByDebugger (unmodified only)

	Type WStringOrStringList As WStringList
	Type WStringOrStringListItem As WStringListItem

Extern "rtlib"
	Declare Function LineInputWstr Alias "fb_FileLineInputWstr"(ByVal filenumber As Long, ByVal dst As WString Ptr, ByVal maxchars As Integer) As Long
End Extern

Using My.Sys.Forms

Namespace VisualFBEditor
	Type Application Extends My.Application
		Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
	End Type
End Namespace

Type HelpOptions
	CurrentPath As WString * MAX_PATH
	CurrentWord As WString * MAX_PATH
End Type
Common Shared As HelpOptions HelpOption

#include once "Localization.bi"
Declare Sub PopupClick(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
Declare Sub ShowPanelMenuItem_Click(ByRef Sender As MenuItem)
Declare Sub mClick(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub ReconcileAgentPipe()   '' start/stop the MCP agent pipe to match AllowAgentControl (MCP_SERVER_PLAN.md Task 6)
Declare Sub UpdateMcpAgentStatusBar()   '' refresh the status-bar MCP Agent On/Off indicator
Declare Sub mClickMRU(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub mClickHelp(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub mClickTool(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub mClickWindow(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)

Common Shared As Form Ptr pfrmMain
Common Shared As ComboBoxEdit Ptr pcboBuildConfiguration
Common Shared As SaveFileDialog Ptr pSaveD
Common Shared As ListView Ptr plvSearch, plvToDo
Common Shared As StatusBar Ptr pstBar 'David Changed
Common Shared As TreeListView Ptr plvProperties, plvEvents
Common Shared As ImageList Ptr pimgList, pimgListTools
Common Shared As ProgressBar Ptr pprProgress
Common Shared As CommandButton Ptr pbtnPropertyValue
Common Shared As TextBox Ptr ptxtPropertyValue
Common Shared As ToolBar Ptr ptbStandard
Common Shared As ToolButton Ptr SelectedTool
Common Shared As TreeNode Ptr SelectedToolNode
Common Shared As TabControl Ptr ptabCode, ptabLeft, ptabBottom, ptabRight
Common Shared As TreeView Ptr ptvExplorer
Common Shared As IniFile Ptr piniSettings, piniTheme
Common Shared As MenuItem Ptr mnuUseDebugger, mnuUseProfiler, miHelps, miXizmat, miWindow
Common Shared As FileEncodings DefaultFileFormat
Common Shared As NewLineTypes DefaultNewLineFormat
Common Shared As Boolean AutoIncrement
Common Shared As Boolean AutoComplete
Common Shared As Boolean AutoSuggestions, ProjectAutoSuggestions
Common Shared As Boolean AutoCreateRC
Common Shared As Boolean AutoCreateBakFiles
Common Shared As Boolean AllowAgentControl        '' Tools > Options: MCP/agent pipe (default ON, agent-first). Gates StartAgentPipe. See MCP_SERVER_PLAN.md.
Common Shared As Boolean AddRelativePathsToRecent
Common Shared As Boolean UseMakeOnStartWithCompile
Common Shared As Boolean CreateNonStaticEventHandlers, CreateFormTypesWithoutTypeWord
Common Shared As Boolean PlaceStaticEventHandlersAfterTheConstructor, CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
Common Shared As Boolean LimitDebug, DisplayWarningsInDebug, TurnOnEnvironmentVariables
Common Shared As Boolean PersonalLicenseGPL3, PersonalLicenseLGPL, PersonalLicenseApache, PersonalLicenseBSD, PersonalLicenseFreeware, PersonalLicenseProprietary, PersonalLicenseOther
Common Shared As Boolean UseDebugger, ParameterInfoShow, LockControls
Common Shared As Boolean CompileGUI
Common Shared As Boolean mFormFindInFile
Common Shared As Boolean InDebug, FormClosing, Restarting, FastRunning, RunningToCursor
Common Shared As Boolean HighlightCurrentLine, HighlightCurrentWord, HighlightBrackets
Common Shared As Boolean mTabSelChangeByError
Common Shared As Boolean DisplayMenuIcons, ShowMainToolBar, ShowStandardToolBar, ShowEditToolBar, ShowProjectToolBar, ShowFormatToolBar, ShowRunToolBar
Common Shared As Boolean ShowKeywordsToolTip, ShowTooltipsAtTheTop, ShowHorizontalSeparatorLines, ShowHolidayFrame, ShowTipoftheDay
Common Shared As Boolean OpenCommandPromptInMainFileFolder, ShowProjectFolders
Common Shared As Integer WhenVisualFBEditorStarts, ShowTipoftheDayIndex
Common Shared As Integer AutoSaveBeforeCompiling, HistoryCodeDays
Common Shared As Double  HistoryCodeCleanDay
Common Shared As Integer IncludeMFFPath
Common Shared As Integer gSearchItemIndex
Common Shared As Integer InterfaceFontSize
Common Shared As Integer LastOpenedFileType
Common Shared As Integer LoadFunctionsCount
Const TARGET_COMPILE_DEFINE As String = "__USE_WINAPI__ -d _WIN32_WINNT=&h0A00"
Const BUNDLED_COMPILER_FOLDER As String = "Compiler"
Const BUNDLED_COMPILER_EXE As String = "fbc64.exe"
Const BUNDLED_GDB_PATH As String = "Debuggers\gdb-11.2.90.20220320-x86_64\bin\gdb.exe"
Common Shared As WString Ptr DefaultProjectFile
Common Shared As WString Ptr InterfaceFontName
Common Shared As WString Ptr gSearchSave, EnvironmentVariables
Common Shared As WString Ptr PersonalName, PersonalCompany, PersonalWebsite, PersonalEmail, PersonalAddress, PersonalLicenseOtherText
Common Shared As WString Ptr ProjectsPath, LastOpenPath, CommandPromptFolder
Common Shared As WString Ptr DefaultHelp, HelpPath, KeywordsHelpPath, AsmKeywordsHelpPath, DefaultBuildConfiguration
Common Shared As WString Ptr DefaultMakeTool, CurrentMakeTool1, CurrentMakeTool2
Common Shared As WString Ptr DefaultTerminal, CurrentTerminal
Common Shared As WString Ptr DefaultCompiler64, CurrentCompiler64
Common Shared As WString Ptr MakeToolPath1, MakeToolPath2, TerminalPath, Compiler64Path
Common Shared As WString Ptr Compiler64Arguments, Make1Arguments, Make2Arguments, RunArguments, Debug64Arguments
Common Shared As Any Ptr tlock, tlockSave, tlockToDo, tlockGDB, tlockSuggestions
Common Shared As Any Ptr tlockDbgTrace	' DR Phase 1 trace (strip after Phase 1)

Type Library
	Name As UString
	Tips As UString
	Path As UString
	HeadersFolder As UString
	SourcesFolder As UString
	IncludeFolder As UString
	Lib32Folder As UString
	Lib64Folder As UString
	Lib64ArmFolder As UString
	LibX32Folder As UString
	LibX64Folder As UString
	Enabled As Boolean
	Handle As Any Ptr
End Type

Type ToolType
	Name As UString
	Path As UString
	Parameters As UString
	Extensions As UString
	Declare Function GetCommand(ByRef FileName As WString = "", WithoutProgram As Boolean = False) As UString
End Type

'Type FileType
'	FileName As UString
'	DateChanged As Double
'	Includes As WStringList
'	IncludeLines As IntegerList
'	Namespaces As WStringOrStringList
'	Types As WStringOrStringList
'	Enums As WStringOrStringList
'	Procedures As WStringOrStringList
'	Args As WStringOrStringList
'	LineLabels As WStringOrStringList
'	Lines As List
'	InProcess As Boolean
'End Type

Common Shared As List Ptr pTools, pControlLibraries
Common Shared As WStringOrStringList Ptr pComps, pGlobalNamespaces, pGlobalTypes, pGlobalEnums, pGlobalDefines, pGlobalFunctions, pGlobalTypeProcedures, pGlobalArgs
Common Shared As WStringList Ptr pAddIns, pIncludeFiles, pLoadPaths, pIncludePaths, pLibraryPaths
'Common Shared As WStringList Ptr pLocalTypes, pLocalEnums, pLocalProcedures, pLocalFunctions, pLocalFunctionsOthers, pLocalArgs,
Common Shared As Dictionary Ptr pHelps, pCompilers, pMakeTools, pTerminals

Enum LoadParam
	OnlyFilePath
	OnlyFilePathOverwrite
	OnlyFilePathOverwriteWithContent
	OnlyIncludeFiles
	FilePathAndIncludeFiles
End Enum

Enum ProjectFolderTypes
	ShowWithFolders
	ShowWithoutFolders
	ShowAsFolder
End Enum

Declare Sub NewProject
Declare Sub OpenProject
Declare Sub OpenRecentProject
Declare Sub NewFile
Declare Sub OpenEditorFile
Declare Sub CloseEditorFile
Declare Sub DeleteEditorFile
Declare Sub CancelFileDeletion
Declare Sub SaveEditorFile
Declare Sub SaveEditorFileAs
Declare Sub AddNew(ByRef Template As WString = "")
Declare Sub AddMRUFile(ByRef FileName As WString)
Declare Sub AddMRUProject(ByRef FileName As WString) '
Declare Sub AddMRUFolder(ByRef FolderName As WString)
Declare Sub PruneMissingMRUProjects()
Declare Sub SanitizeMRUListsOnLoad()
Declare Sub AddFromTemplates
Declare Sub AddFilesToProject
Declare Sub RestoreStatusText
Declare Sub OpenUrl(ByRef url As WString)
Declare Function AddProject(ByRef FileName As WString = "", pFilesList As WStringList Ptr = 0, tn As TreeNode Ptr = 0, bNew As Boolean = False) As TreeNode Ptr
Declare Function CreatePendingProjectFile(ByRef TemplatePath As WString, ByRef SuggestedBaseName As WString, tnParent As TreeNode Ptr, bOpenTab As Boolean = True) As TreeNode Ptr
Declare Function SaveProject(ByRef tn As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
Declare Function CloseProject(tn As TreeNode Ptr, WithoutMessage As Boolean = False) As Boolean
Declare Sub SetMainNode(tn As TreeNode Ptr)
Declare Sub OpenProjectFolder
Declare Sub OpenFiles(ByRef FileName As WString)
Declare Sub OpenFilesU(FileName As UString)
Declare Function AddFolderU(FolderName As UString) As TreeNode Ptr
Declare Function PrepareForAnotherProjectU(NewProjectPath As UString = "") As Boolean
Declare Sub AddNewU(Template As UString)
Declare Function GetOpenProjectNode() As TreeNode Ptr
Declare Function GetProjectDirectory() As UString
Declare Function OpenProjectDescriptionPath() As UString
Declare Sub EditProjectDescription
Declare Function OpenProjectIsGitRepo() As Boolean
Declare Sub GitCommit
Declare Sub GitPull
Declare Sub GitPush
Declare Sub GitSetupSshKey
Declare Sub SetupSshKey(ByRef provider As String)
Declare Sub AddNewProjectFile(ByRef Template As WString, ByRef ItemName As WString)
Declare Function ContainsFileName(tn As TreeNode Ptr, ByRef FileName As WString) As Boolean
Declare Function GetTreeNodeChild(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
Declare Function PrepareForAnotherProject(ByRef NewProjectPath As WString = "") As Boolean
Declare Sub SaveWorkspace()
Declare Function LoadWorkspace() As Boolean
Declare Function CloseAllDocuments() As Boolean
Declare Sub PrintThis()
Declare Sub PrintPreview()
Declare Sub PageSetup()
Declare Sub ReloadHistoryCode
Declare Sub SetAsMain(IsTab As Boolean)
Declare Sub SetAutoColors
Declare Sub StartProgress()
Declare Sub StopProgress()
Declare Sub ThreadCounter(Id As Any Ptr)
Declare Function EqualPaths(ByRef a As WString, ByRef b As WString) As Boolean
Declare Sub ChangeEnabledDebug(bStart As Boolean, bBreak As Boolean, bEnd As Boolean)
Declare Sub ClearThreadsWindow() ' Defined in AstoriaIDE.bas; forward-declared here since Main.bi pulls in Main.bas before AstoriaIDE.bas defines it
Declare Sub ChangeLockControls(bLockControls As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeUseDebugger(bUseDebugger As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeShowSymbolsTooltipsOnMouseHover(bEnabled As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeAutoComplete(bEnabled As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeParameterInfo(bEnabled As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeUseProfiler(bUseProfiler As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeFileEncoding(FileEncoding As FileEncodings)
Declare Sub ChangeNewLineType(NewLineType As NewLineTypes)
	Common Shared As UINT_PTR CurrentTimer, CurrentTimerData
Declare Function WithoutPointers(ByRef e As String) As String
Declare Function WithoutQuotes(ByRef e As UString) As UString
Declare Sub ChangeFolderType(Value As ProjectFolderTypes)
Declare Function FolderCopy(FromDir As UString, ToDir As UString) As Integer
Declare Sub Save
Declare Function SaveAllBeforeCompile() As Boolean
Declare Sub CompileProgram(Param As Any Ptr)
Declare Sub CompileAndRun(Param As Any Ptr)
Declare Sub MakeExecute(Param As Any Ptr)
Declare Sub MakeClean(Param As Any Ptr)
Declare Sub SyntaxCheck(Param As Any Ptr)
Declare Sub NextBookmark(iTo As Integer = 1)
Declare Sub ClearAllBookmarks
Declare Sub ClearAllBreakpoints
Declare Sub SaveAll()
Declare Sub FormatProject(UnFormat As Any Ptr)
Declare Sub SetSaveDialogParameters(ByRef FileName As WString)
Declare Function IfNegative(Value As Integer, NonNegative As Integer) As Integer
Declare Function GetChangedCommas(ByRef Value As WString, FromSecond As Boolean = False) As String
#include once "SettingsService.bi"
#include once "PathUtils.bi"
#include once "BuildService.bi"
Declare Function GetXY(XorY As Integer) As Integer
	Declare Function FileTimeToVariantTime(ByRef FT As FILETIME) As DATE_
	Declare Function GetFileLastWriteTime(ByRef FileName As WString) As FILETIME
Declare Function FolderExists(ByRef FolderName As WString) As Boolean
Declare Sub LoadFunctions(ByRef Path As WString, LoadParameter As LoadParam = FilePathAndIncludeFiles, ByRef Types As WStringOrStringList, ByRef Enums As WStringOrStringList, ByRef Functions As WStringOrStringList, ByRef Args As WStringOrStringList, ByRef TypeProcedures As WStringOrStringList, ec As Control Ptr = 0, CtlLibrary As Library Ptr = 0, CurFile As Any Ptr = 0, OldFile As Any Ptr = 0)
Declare Sub LoadFunctionsSub(Param As Any Ptr)
Declare Sub LoadOnlyFilePath(Param As Any Ptr)
Declare Sub LoadOnlyFilePathOverwrite(Param As Any Ptr)
Declare Sub LoadOnlyFilePathOverwriteWithContent(Param As Any Ptr)
Declare Sub LoadOnlyIncludeFiles(Param As Any Ptr)
Declare Sub LoadToolBox(ForLibrary As Library Ptr = 0)
Declare Function IsMyFbFrameworkLibrary(ByRef Path As UString) As Boolean
Declare Function GetMyFbFrameworkLibrary() As Library Ptr
Declare Sub RunDeferredFormDesign()
Common Shared As Boolean mApplyingWorkspaceLoad
Common Shared As Boolean mApplyingDeferredFormDesign
Common Shared As Boolean mApplyingFormTabView
Common Shared As Boolean mAddingTab
Common Shared As Library Ptr MFFCtlLibrary
Declare Sub InitToolBoxTree()
Declare Sub CloseAllTabs(WithoutCurrent As Boolean = False)
Declare Sub UpdateAllTabWindows
Declare Sub LoadTheme
Declare Sub RunHelp(Param As Any Ptr)

Common Shared As Integer tabLeftWidth, tabRightWidth, tabBottomHeight, leftSelectedTabIndex, rightSelectedTabIndex
Const DEFAULT_LEFT_PANEL_WIDTH As Integer = 350
Const DEFAULT_BOTTOM_PANEL_HEIGHT As Integer = 150
Const MIN_BOTTOM_PANEL_HEIGHT As Integer = 80
Const BOTTOM_PIN_STRIP_WIDTH As Integer = 20
Declare Sub SetLeftClosedStyle(Value As Boolean, WithClose As Boolean = True)
Declare Sub SetRightClosedStyle(Value As Boolean, WithClose As Boolean = True)
Declare Sub SetBottomClosedStyle(Value As Boolean, WithClose As Boolean = True)
Declare Function GetBottomClosedStyle As Boolean
Declare Function IsBottomCollapsed As Boolean
Declare Sub SaveMainWindowPanelLayout()
Declare Function GetLeftClosedStyle As Boolean
Declare Function IsLeftCollapsed As Boolean
Declare Sub UpdateLeftPinLayout()
Declare Function GetRightClosedStyle As Boolean
Declare Sub pnlToolBox_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)

Dim Shared symbols(0 To 15) As UByte
Const plus  As UByte = 43
Const minus As UByte = 45
Const dot   As UByte = 46
Declare Function IsNumeric(ByRef subject As Const WString, base_ As Integer = 10) As Boolean
Declare Function utf16BeByte2wchars( ta() As UByte ) ByRef As WString

' Win64-only fork: kept because shared compile paths still branch on bitness symbol
#define IsBit32() (False)

	#include once "Main.bas"