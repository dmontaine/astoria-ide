'#########################################################
'#  Main.bi                                              #
'#  This file is part of VisualFBEditor                  #
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

		#define SettingsPath ExePath & "/Settings/VisualFBEditor64.ini"

	#define Slash "\"
	#define BackSlash "/"

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
Declare Sub mClickAIChat(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
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
Common Shared As ImageList Ptr pimgList, pimgListTools, pimgListAIProviders32, pimgListAIModels32
Common Shared As ProgressBar Ptr pprProgress
Common Shared As CommandButton Ptr pbtnPropertyValue
Common Shared As TextBox Ptr ptxtPropertyValue, ptxtAIRequest
Common Shared As ToolBar Ptr ptbStandard
Common Shared As ToolButton Ptr SelectedTool
Common Shared As TreeNode Ptr SelectedToolNode
Common Shared As TabControl Ptr ptabCode, ptabLeft, ptabBottom, ptabRight
Common Shared As TreeView Ptr ptvExplorer
Common Shared As IniFile Ptr piniSettings, piniTheme
Common Shared As MenuItem Ptr mnuUseDebugger, mnuUseProfiler, miHelps, miXizmat, miWindow
Common Shared As MenuItem Ptr miPlainText, miUtf8, miUtf8BOM, miUtf16BOM, miUtf32BOM, miWindowsCRLF, miLinuxLF, miMacOSCR
Common Shared As HTTPConnection Ptr pHTTPAIAgent
Common Shared As FileEncodings DefaultFileFormat
Common Shared As NewLineTypes DefaultNewLineFormat
Common Shared As Boolean AutoIncrement
Common Shared As Boolean AutoComplete
Common Shared As Boolean AutoSuggestions, ProjectAutoSuggestions
Common Shared As Boolean AutoCreateRC
Common Shared As Boolean AutoCreateBakFiles, gLocalProperties
Common Shared As Boolean AutoSaveSession, SessionOpened
Common Shared As Boolean AddRelativePathsToRecent
Common Shared As Boolean UseMakeOnStartWithCompile
Common Shared As Boolean CreateNonStaticEventHandlers, CreateFormTypesWithoutTypeWord
Common Shared As Boolean PlaceStaticEventHandlersAfterTheConstructor, CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
Common Shared As Boolean LimitDebug, DisplayWarningsInDebug, TurnOnEnvironmentVariables
Common Shared As Boolean UseDebugger, ParameterInfoShow, LockControls
Common Shared As Boolean CompileGUI, bAIAgentFirstRun
Common Shared As Boolean mFormFindInFile
Common Shared As Boolean InDebug, FormClosing, Restarting, FastRunning, RunningToCursor
Common Shared As Boolean HighlightCurrentLine, HighlightCurrentWord, HighlightBrackets
Common Shared As Boolean mTabSelChangeByError
Common Shared As Boolean DisplayMenuIcons, ShowMainToolBar, DarkMode, ShowStandardToolBar, ShowEditToolBar, ShowProjectToolBar, ShowFormatToolBar, ShowBuildToolBar, ShowDebugToolBar, ShowRunToolBar
Common Shared As Boolean ShowKeywordsToolTip, ShowTooltipsAtTheTop, ShowHorizontalSeparatorLines, ShowHolidayFrame, ShowTipoftheDay
Common Shared As Boolean OpenCommandPromptInMainFileFolder, ShowProjectFolders
Common Shared As Integer WhenVisualFBEditorStarts, ShowTipoftheDayIndex
Common Shared As Integer AutoSaveBeforeCompiling, HistoryCodeDays
Common Shared As Double  HistoryCodeCleanDay
Common Shared As Integer IncludeMFFPath
Common Shared As Integer gSearchItemIndex
Common Shared As Integer InterfaceFontSize
Common Shared As Integer LastOpenedFileType
Common Shared As Integer LoadFunctionsCount, AIAgentPort, AIAgentContentSize
Common Shared As Boolean AIAgentStream
Common Shared As Double  AIAgentTop_P, AIAgentTemperature 'Between 0 and 2.
Const TARGET_COMPILE_DEFINE As String = "__USE_WINAPI__ -d _WIN32_WINNT=&h0A00"
Const BUNDLED_COMPILER_FOLDER As String = "Compiler"
Const BUNDLED_COMPILER_EXE As String = "fbc64.exe"
Const BUNDLED_GDB_PATH As String = "Debuggers\gdb-11.2.90.20220320-x86_64\bin\gdb.exe"
Common Shared As String  AIAgentHost, AIAgentAddress, AIAgentAPIKey, AIAgentModelName, AIAgentProvider, AIAgentName, AIRTF_HEADER, AIEditorFontName
Common Shared As WString Ptr DefaultProjectFile
Common Shared As WString Ptr InterfaceFontName
Common Shared As WString Ptr gSearchSave, EnvironmentVariables
Common Shared As WString Ptr ProjectsPath, LastOpenPath, CommandPromptFolder
Common Shared As WString Ptr DefaultHelp, HelpPath, KeywordsHelpPath, AsmKeywordsHelpPath, DefaultBuildConfiguration
Common Shared As WString Ptr DefaultMakeTool, CurrentMakeTool1, CurrentMakeTool2, DefaultAIAgent, CurrentAIAgent
Common Shared As WString Ptr DefaultTerminal, CurrentTerminal
Common Shared As WString Ptr DefaultCompiler64, CurrentCompiler64
Common Shared As WString Ptr MakeToolPath1, MakeToolPath2, TerminalPath, Compiler64Path
Common Shared As WString Ptr Compiler64Arguments, Make1Arguments, Make2Arguments, RunArguments, Debug64Arguments
Common Shared As Any Ptr tlock, tlockSave, tlockToDo, tlockGDB, tlockSuggestions

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

Type ModelInfo
	Name As String
	Host As String
	Address As String
	APIKey As String
	ModelName As String
	Provider As String
	Port As Integer
	Stream As Boolean
	ContentSize As Integer
	Temperature As Single 'Between 0 and 2.
	Top_P As Single ' <= 1
	Response_Format As String 'json_object
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
Common Shared As Dictionary Ptr pHelps, pCompilers, pMakeTools, pTerminals, pOtherEditors, pAIAgents

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
Declare Sub AddNew(ByRef Template As WString = "")
Declare Sub AddMRUFile(ByRef FileName As WString)
Declare Sub AddMRUProject(ByRef FileName As WString) '
Declare Sub AddMRUFolder(ByRef FolderName As WString)
Declare Sub AddMRUSession(ByRef FileName As WString) '
Declare Sub AddFromTemplates
Declare Sub AddFilesToProject
Declare Sub RemoveFileFromProject
Declare Sub RestoreStatusText
Declare Sub OpenUrl(ByVal url As String)
Declare Function AddProject(ByRef FileName As WString = "", pFilesList As WStringList Ptr = 0, tn As TreeNode Ptr = 0, bNew As Boolean = False) As TreeNode Ptr
Declare Function SaveProject(ByRef tn As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
Declare Function CloseProject(tn As TreeNode Ptr, WithoutMessage As Boolean = False) As Boolean
Declare Sub SetMainNode(tn As TreeNode Ptr)
Declare Sub OpenProjectFolder
Declare Sub OpenFiles(ByRef FileName As WString)
Declare Sub OpenSession
Declare Sub OpenProgram()
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
Declare Sub ClearThreadsWindow() ' Defined in VisualFBEditor.bas; forward-declared here since Main.bi pulls in Main.bas before VisualFBEditor.bas defines it
Declare Sub ChangeLockControls(bLockControls As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeUseDebugger(bUseDebugger As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeFileEncoding(FileEncoding As FileEncodings)
Declare Sub ChangeNewLineType(NewLineType As NewLineTypes)
	Common Shared As UINT_PTR CurrentTimer, CurrentTimerData
Declare Function WithoutPointers(ByRef e As String) As String
Declare Function WithoutQuotes(ByRef e As UString) As UString
Declare Sub ChangeFolderType(Value As ProjectFolderTypes)
Declare Sub SetMenuItemPairEnabled(mi_ As MenuItem Ptr, dmi_ As MenuItem Ptr, bEnabled As Boolean)
Declare Function FolderCopy(FromDir As UString, ToDir As UString) As Integer
Declare Sub Save
Declare Function SaveAllBeforeCompile() As Boolean
Declare Function SaveSession(WithoutQuestion As Boolean = False) As Boolean
Declare Sub CompileProgram(Param As Any Ptr)
Declare Sub CompileWithDebugger(Param As Any Ptr)
Declare Sub CompileAndRun(Param As Any Ptr)
Declare Sub MakeExecute(Param As Any Ptr)
Declare Sub MakeClean(Param As Any Ptr)
Declare Sub SyntaxCheck(Param As Any Ptr)
Declare Sub NextBookmark(iTo As Integer = 1)
Declare Sub ClearAllBookmarks
Declare Sub SaveAll()
Declare Sub FormatProject(UnFormat As Any Ptr)
Declare Sub SetSaveDialogParameters(ByRef FileName As WString)
Declare Function IfNegative(Value As Integer, NonNegative As Integer) As Integer
Declare Function GetChangedCommas(ByRef Value As WString, FromSecond As Boolean = False) As String
#include once "SettingsService.bi"
#include once "PathUtils.bi"
#include once "BuildService.bi"
#include once "AIService.bi"
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
Declare Sub LoadFromTabWindow(Param As Any Ptr)
Declare Sub LoadToolBox(ForLibrary As Library Ptr = 0)
Declare Function IsMyFbFrameworkLibrary(ByRef Path As UString) As Boolean
Declare Sub RemoveToolBoxLibraryNodes(CtlLibrary As Library Ptr)
Declare Sub InitToolBoxTree()
Declare Sub CloseAllTabs(WithoutCurrent As Boolean = False)
Declare Sub UpdateAllTabWindows
Declare Sub LoadTheme
Declare Sub LoadInterfaceTheme
Declare Sub RunHelp(Param As Any Ptr)

Common Shared As Integer tabLeftWidth, tabRightWidth, tabBottomHeight, leftSelectedTabIndex, rightSelectedTabIndex
Const DEFAULT_LEFT_PANEL_WIDTH As Integer = 350
Const DEFAULT_BOTTOM_PANEL_HEIGHT As Integer = 200
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