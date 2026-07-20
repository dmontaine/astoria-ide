'#########################################################
'#  SettingsService.bas                                  #
'#  This file is part of AstoriaIDE                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "SettingsService.bi"
#include once "PathUtils.bi"

Const INDEXED_SETTINGS_SECTION_COUNT As Integer = 5

'' The terminal list is built in, not user-editable: Astoria offers exactly the consoles Windows
'' itself ships. Keeping it in code (rather than indexed [Terminals] keys in astoria.ini) means it
'' can never end up empty or stale -- an empty list is what made the Options terminal dropdown look
'' broken. Only the *choice* (DefaultTerminal) is persisted.
''
'' {D} is the target's directory and {F} its full path; see ToolType.GetCommand.
Sub SeedBuiltInTerminals()
	Dim As ToolType Ptr Tool
	Terminals.Clear
	Tool = _New(ToolType) : Tool->Name = TERMINAL_WINDOWS_CONSOLE
	Tool->Path = "" : Tool->Parameters = ""
	Terminals.Add TERMINAL_WINDOWS_CONSOLE, Tool->Path, Tool
	Tool = _New(ToolType) : Tool->Name = "Command Prompt"
	Tool->Path = "cmd.exe" : Tool->Parameters = "/K ""cd /D ""{D}"" & ""{F}"""""
	Terminals.Add "Command Prompt", Tool->Path, Tool
	Tool = _New(ToolType) : Tool->Name = "Windows PowerShell"
	Tool->Path = "PowerShell.exe" : Tool->Parameters = "-NoExit"
	Terminals.Add "Windows PowerShell", Tool->Path, Tool
	Tool = _New(ToolType) : Tool->Name = "Windows Terminal"
	Tool->Path = "wt.exe" : Tool->Parameters = "-d ""{D}"" cmd /K """"{F}"""""
	Terminals.Add "Windows Terminal", Tool->Path, Tool
End Sub

Function GetBundledCompilerFolder() As UString
	Return ExePath & "/" & BUNDLED_COMPILER_FOLDER
End Function

Function GetBundledCompilerExe() As UString
	Return GetBundledCompilerFolder() & "/" & BUNDLED_COMPILER_EXE
End Function

Sub SetBundledCompilerPath()
	WLet(Compiler64Path, GetBundledCompilerExe())
End Sub

Sub ResolveFbcExePath(ByRef FbcExe As WString Ptr, CompilerTool As ToolType Ptr, ByRef fbcCommand As WString Ptr)
	If FbcExe = 0 Then Return
		While EndsWith(*FbcExe, "\") OrElse EndsWith(*FbcExe, "/")
			*FbcExe = Left(*FbcExe, Len(*FbcExe) - 1)
		Wend
	If CompilerTool = 0 OrElse Trim(CompilerTool->Parameters) = "" Then Return
	Dim As UString Params = CompilerTool->Parameters
	Dim As UString CompExe = Params
	Dim As Integer sp = InStr(CompExe, " ")
	If sp > 0 Then CompExe = Left(CompExe, sp - 1)
	If InStr(LCase(*FbcExe), ".exe") = 0 Then
		Dim As UString FullExe = *FbcExe & WindowsSlash & CompExe
		If FileExists(FullExe) Then
			WLet(FbcExe, FullExe)
		ElseIf FileExists(*FbcExe & WindowsSlash & "bin" & WindowsSlash & CompExe) Then
			WLet(FbcExe, *FbcExe & WindowsSlash & "bin" & WindowsSlash & CompExe)
		ElseIf FileExists(*FbcExe & WindowsSlash & "bin" & WindowsSlash & "win64" & WindowsSlash & CompExe) Then
			WLet(FbcExe, *FbcExe & WindowsSlash & "bin" & WindowsSlash & "win64" & WindowsSlash & CompExe)
		End If
	End If
	If fbcCommand <> 0 Then
		If StartsWith(*fbcCommand, Params & " ") Then
			WLet(fbcCommand, Mid(*fbcCommand, Len(Params) + 2))
		ElseIf StartsWith(*fbcCommand, CompExe & " ") Then
			WLet(fbcCommand, Mid(*fbcCommand, Len(CompExe) + 2))
		ElseIf *fbcCommand = Params OrElse *fbcCommand = CompExe Then
			WLet(fbcCommand, "")
		ElseIf StartsWith(*fbcCommand, Params) Then
			WLet(fbcCommand, LTrim(Mid(*fbcCommand, Len(Params) + 1), Any !" \t"))
		ElseIf StartsWith(*fbcCommand, CompExe) Then
			WLet(fbcCommand, LTrim(Mid(*fbcCommand, Len(CompExe) + 1), Any !" \t"))
		End If
	End If
End Sub

Private Sub MergeOneShippedDefault(ByRef Defaults As IniFile, ByRef Section As WString, ByRef Key As WString)
	If Defaults.KeyExists(Section, Key) = -1 Then Exit Sub
	If iniSettings.KeyExists(Section, Key) <> -1 Then Exit Sub
	Dim As UString Value = Defaults.ReadString(Section, Key, "")
	iniSettings.WriteString Section, Key, Value
End Sub

Private Sub MergeMissingShippedSettings(ByRef DefaultsPath As WString)
	'' An existing astoria.ini is user data, so it remains authoritative. Repair only
	'' keys shipped in astoria.default.ini that are absent; never replace a value the
	'' user already has, and never touch personal information, MRU or custom sections.
	Dim As IniFile Defaults
	Defaults.Load DefaultsPath
	If Defaults.SectionCount = 0 Then Exit Sub

	MergeOneShippedDefault Defaults, "MakeTools", "DefaultMakeTool"
	MergeOneShippedDefault Defaults, "MakeTools", "Version_0"
	MergeOneShippedDefault Defaults, "MakeTools", "Path_0"
	MergeOneShippedDefault Defaults, "MakeTools", "Command_0"
	MergeOneShippedDefault Defaults, "Terminals", "DefaultTerminal"
	MergeOneShippedDefault Defaults, "Helps", "DefaultHelp"
	MergeOneShippedDefault Defaults, "Helps", "Version_0"
	MergeOneShippedDefault Defaults, "Helps", "Path_0"
	MergeOneShippedDefault Defaults, "Helps", "Version_1"
	MergeOneShippedDefault Defaults, "Helps", "Path_1"
	MergeOneShippedDefault Defaults, "Helps", "Version_2"
	MergeOneShippedDefault Defaults, "Helps", "Path_2"
	MergeOneShippedDefault Defaults, "IncludePaths", "Path_0"
	MergeOneShippedDefault Defaults, "LibraryPaths", "Path_0"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "DefaultBuildConfiguration"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "Name_0"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "Switches_0"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "Name_1"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "Switches_1"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "Name_2"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "Switches_2"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "Name_3"
	MergeOneShippedDefault Defaults, "BuildConfigurations", "Switches_3"
	MergeOneShippedDefault Defaults, "Options", "ShowSymbolsTooltipsOnMouseHover"
End Sub

Sub LoadSettingsIni()
	'' No settings file yet -- a fresh install, or the user deleted it. Seed a minimal
	'' one before loading.
	''
	'' This is load-bearing, not cosmetic: IniFile records its target path only inside
	'' Load(), and the guarded call below skips Load entirely when the file is absent.
	'' With no path recorded, every later iniSettings.Write* call ends in
	'' IniFile.Update -> SaveToFile("") which fails silently (a Debug.Print only) -- so
	'' the whole session's settings went nowhere AND no astoria.ini was ever created,
	'' leaving the IDE permanently unable to persist anything. Seeding one real section
	'' also keeps Update's FLines.Item(0) access valid on the very first write.
	''
	'' The seed is a *copy of Settings/astoria.default.ini*, not a bare [Options] stub. A stub
	'' technically fixes the persistence bug above, but leaves the IDE crippled in a way that
	'' looks like unrelated UI bugs: with no [Terminals] the Tools > Options terminal dropdown
	'' is empty and has no default, and [Helps]/[MakeTools]/[IncludePaths]/[LibraryPaths] are
	'' gone too. The template ships the tool defaults only -- no MRU, window state, or personal
	'' info -- so a recreated file matches a fresh install. Copying byte-for-byte also
	'' preserves the UTF-8 BOM the shipped astoria.ini uses.
	If Not FileExists(SettingsPath) Then
		EnsureDirectoryExists(ExePath & "/Settings")
		Dim As UString DefaultsPath = ExePath & "/Settings/astoria.default.ini"
		Dim As Boolean Seeded = False
		If FileExists(DefaultsPath) Then Seeded = CopyFileU(DefaultsPath, SettingsPath)
		'' Last resort if the template is missing (damaged install): one real section is still
		'' enough to give IniFile a path to write to and keep Update's FLines.Item(0) valid.
		If Not Seeded Then
			Dim As Integer fnNew = FreeFile
			If Open(SettingsPath For Output Encoding "utf-8" As #fnNew) = 0 Then
				Print #fnNew, "[Options]"
				Close #fnNew
			End If
		End If
	End If
	If FileExists(SettingsPath) Then
		iniSettings.Load SettingsPath
		'' A present file may still be truncated, malformed or missing a section. The
		'' old path accepted that silently and left tool lists empty (TestPlan E2).
		'' Merge only absent shipped defaults after loading so valid user choices win.
		Dim As UString RepairDefaultsPath = ExePath & "/Settings/astoria.default.ini"
		If FileExists(RepairDefaultsPath) Then MergeMissingShippedSettings RepairDefaultsPath
	End If
End Sub

Private Function NoMoreIndexedSettingsKeys(i As Integer) As Boolean
	Dim As Integer keySum = 0
	keySum += iniSettings.KeyExists("MakeTools", "Version_" & WStr(i))
	keySum += iniSettings.KeyExists("BuildConfigurations", "Name_" & WStr(i))
	keySum += iniSettings.KeyExists("Helps", "Version_" & WStr(i))
	keySum += iniSettings.KeyExists("IncludePaths", "Path_" & WStr(i))
	keySum += iniSettings.KeyExists("LibraryPaths", "Path_" & WStr(i))
	Return keySum = -INDEXED_SETTINGS_SECTION_COUNT
End Function

Sub LoadSettings
	LoadSettingsIni()
	Dim As UString Temp
	Dim As ToolType Ptr Tool
	Dim i As Integer = 0
	cboBuildConfiguration.AddItem ("No options")
	Do
		Temp = iniSettings.ReadString("MakeTools", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = SanitizeIniOptionalPath(iniSettings.ReadString("MakeTools", "Path_" & WStr(i), ""))
			Tool->Parameters = iniSettings.ReadString("MakeTools", "Command_" & WStr(i), "")
			MakeTools.Add Temp, Tool->Path, Tool
		End If
		Temp = iniSettings.ReadString("Helps", "Version_" & WStr(i), "")
		If Temp <> "" Then Helps.Add Temp, SanitizeIniOptionalPath(iniSettings.ReadString("Helps", "Path_" & WStr(i), ""))
		Temp = iniSettings.ReadString("BuildConfigurations", "Name_" & WStr(i), "")
		If Temp <> "" Then BuildConfigurations.Add Temp, iniSettings.ReadString("BuildConfigurations", "Switches_" & WStr(i), ""): cboBuildConfiguration.AddItem Temp
		Temp = SanitizeIniOptionalPath(iniSettings.ReadString("IncludePaths", "Path_" & WStr(i), ""))
		If Temp <> "" Then IncludePaths.Add Temp
		Temp = SanitizeIniOptionalPath(iniSettings.ReadString("LibraryPaths", "Path_" & WStr(i), ""))
		If Temp <> "" Then LibraryPaths.Add Temp
		i += 1
	Loop Until NoMoreIndexedSettingsKeys(i)

	'' The framework's architecture-specific lib folder must be on the library path or anything
	'' using WebBrowser fails to link: WebView2.bi does #inclib "WebView2Loader.dll", and the
	'' import library lives in lib\win-x64, not in the lib folder the INI lists. Added here
	'' rather than to the INI defaults so existing installs get it too -- a settings file that
	'' already exists is never rewritten with new defaults (see LoadSettingsIni).
	Dim As UString FrameworkArchLib = ".\Controls\Framework\Lib\win-x64"
	Dim As Boolean HasArchLib
	For k As Integer = 0 To LibraryPaths.Count - 1
		If LCase(Trim(LibraryPaths.Item(k))) = LCase(FrameworkArchLib) Then HasArchLib = True: Exit For
	Next k
	If Not HasArchLib Then LibraryPaths.Add FrameworkArchLib

	WLet(DefaultCompiler64, "FreeBASIC")
	WLet(CurrentCompiler64, *DefaultCompiler64)
	SetBundledCompilerPath()
	WLet(DefaultMakeTool, iniSettings.ReadString("MakeTools", "DefaultMakeTool", "make"))
	WLet(CurrentMakeTool1, *DefaultMakeTool)
	WLet(MakeToolPath1, MakeTools.Get(*CurrentMakeTool1, "make"))
	WLet(CurrentMakeTool2, *DefaultMakeTool)
	WLet(MakeToolPath2, MakeTools.Get(*CurrentMakeTool2, "make"))
	'' Terminals are built in and there is no "(not selected)" choice -- a terminal is always
	'' selected. Anything unrecognised in the INI (an old hand-edited name, or one of the
	'' user-defined entries earlier versions allowed) falls back to the standard console.
	SeedBuiltInTerminals()
	WLet(DefaultTerminal, iniSettings.ReadString("Terminals", "DefaultTerminal", TERMINAL_WINDOWS_CONSOLE))
	If Not Terminals.ContainsKey(*DefaultTerminal) Then WLet(DefaultTerminal, TERMINAL_WINDOWS_CONSOLE)
	WLet(CurrentTerminal, *DefaultTerminal)
	WLet(TerminalPath, Terminals.Get(*CurrentTerminal, ""))
	WLet(DefaultHelp, iniSettings.ReadString("Helps", "DefaultHelp", ""))
	WLet(HelpPath, Helps.Get(*DefaultHelp, ""))
	WLet(DefaultBuildConfiguration, iniSettings.ReadString("BuildConfigurations", "DefaultBuildConfiguration", ""))
	cboBuildConfiguration.ItemIndex = Max(0, cboBuildConfiguration.IndexOf(*DefaultBuildConfiguration))
	UseMakeOnStartWithCompile = iniSettings.ReadBool("Options", "UseMakeOnStartWithCompile", False)
	CreateNonStaticEventHandlers = iniSettings.ReadBool("Options", "CreateNonStaticEventHandlers", True)
	PlaceStaticEventHandlersAfterTheConstructor = iniSettings.ReadBool("Options", "PlaceStaticEventHandlersAfterTheConstructor", True)
	CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning = iniSettings.ReadBool("Options", "CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning", False)
	CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt = iniSettings.ReadBool("Options", "CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt", True)
	CreateFormTypesWithoutTypeWord = iniSettings.ReadBool("Options", "CreateFormTypesWithoutTypeWord", False)
	OpenCommandPromptInMainFileFolder = iniSettings.ReadBool("Options", "OpenCommandPromptInMainFileFolder", True)
	WLet(CommandPromptFolder, SanitizeIniCriticalPath(iniSettings.ReadString("Options", "CommandPromptFolder", "./Projects"), "./Projects"))
	LimitDebug = iniSettings.ReadBool("Options", "LimitDebug", False)
	DisplayWarningsInDebug = iniSettings.ReadBool("Options", "DisplayWarningsInDebug", False)
	TurnOnEnvironmentVariables = iniSettings.ReadBool("Options", "TurnOnEnvironmentVariables", True)
	WLet(EnvironmentVariables, iniSettings.ReadString("Options", "EnvironmentVariables"))
	WLet(ProjectsPath, SanitizeIniCriticalPath(iniSettings.ReadString("Options", "ProjectsPath", "./Projects"), "./Projects"))
	GridSize = iniSettings.ReadInteger("Options", "GridSize", 10)
	ShowAlignmentGrid = iniSettings.ReadBool("Options", "ShowAlignmentGrid", True)
	SnapToGridOption = iniSettings.ReadBool("Options", "SnapToGrid", True)
	AutoIncrement = iniSettings.ReadBool("Options", "AutoIncrement", True)
	AutoCreateRC = iniSettings.ReadBool("Options", "AutoCreateRC", True)
	AutoSaveBeforeCompiling = iniSettings.ReadInteger("Options", "AutoSaveBeforeCompiling", 1)
	AutoCreateBakFiles = iniSettings.ReadBool("Options", "AutoCreateBakFiles", False)
	'' MCP/agent pipe. Default ON -- Astoria is used agent-first, so the pipe listens
	'' unless the user unticks Tools > Options > Allow AI agent control. Migrates the
	'' Task 0-5 stopgap key EnableAgentPipe if that was set explicitly.
	AllowAgentControl = iniSettings.ReadBool("Options", "AllowAgentControl", iniSettings.ReadBool("Options", "EnableAgentPipe", True))
	AddRelativePathsToRecent = iniSettings.ReadBool("Options", "AddRelativePathsToRecent", True)
	WhenVisualFBEditorStarts = iniSettings.ReadInteger("Options", "WhenVisualFBEditorStarts", 0)
	WLet(DefaultProjectFile, SanitizeIniPath(iniSettings.ReadString("Options", "DefaultProjectFile", "Files/Form.frm")))
	DefaultFileFormat = FileEncodings.Utf8
	DefaultNewLineFormat = NewLineTypes.WindowsCRLF
	LastOpenedFileType = iniSettings.ReadInteger("Options", "LastOpenedFileType", 0)
	AutoComplete = iniSettings.ReadBool("Options", "AutoComplete", True)
	ParameterInfoShow = iniSettings.ReadBool("Options", "ParameterInfoShow", True)
		AutoSuggestions = iniSettings.ReadBool("Options", "AutoSuggestions", True)
	AutoIndentation = iniSettings.ReadBool("Options", "AutoIndentation", True)
	ShowSpaces = iniSettings.ReadBool("Options", "ShowSpaces", True)
	ShowKeywordsToolTip = iniSettings.ReadBool("Options", "ShowKeywordsTooltip", True)
	ShowTooltipsAtTheTop = iniSettings.ReadBool("Options", "ShowTooltipsAtTheTop", False)
	GlobalSettings.ShowSymbolsTooltipsOnMouseHover = iniSettings.ReadBool("Options", "ShowSymbolsTooltipsOnMouseHover", True)
	GlobalSettings.ShowClassesExplorerOnOpenWindow = iniSettings.ReadBool("Options", "ShowClassesExplorerOnOpenWindow", True)
	ShowHorizontalSeparatorLines = iniSettings.ReadBool("Options", "ShowHorizontalSeparatorLines", True)
	ShowHolidayFrame = iniSettings.ReadBool("Options", "ShowHolidayFrame", True)
	HighlightBrackets = iniSettings.ReadBool("Options", "HighlightBrackets", True)
	HighlightCurrentLine = iniSettings.ReadBool("Options", "HighlightCurrentLine", True)
	HighlightCurrentWord = iniSettings.ReadBool("Options", "HighlightCurrentWord", True)
	TabAsSpaces = iniSettings.ReadBool("Options", "TabAsSpaces", True)
	ChoosedTabStyle = iniSettings.ReadInteger("Options", "ChoosedTabStyle", 1)
	CodeEditorHoverTime = iniSettings.ReadInteger("Options", "CodeEditorHoverTime", 0)
	TabWidth = iniSettings.ReadInteger("Options", "TabWidth", 4)
	AutoSaveCharMax = iniSettings.ReadInteger("Options", "AutoSaveCharMax", 100)
	HistoryLimit = iniSettings.ReadInteger("Options", "HistoryLimit", 20)
	IntellisenseLimit = iniSettings.ReadInteger("Options", "IntellisenseLimit", 100)
	HistoryCodeDays = iniSettings.ReadInteger("Options", "HistoryCodeDays", 100)
	HistoryCodeCleanDay = iniSettings.ReadInteger("Options", "HistoryCodeCleanDay", DateValue(Format(Now, "yyyy/mm/dd")))
	If HistoryCodeCleanDay <> DateValue(Format(Now, "yyyy/mm/dd")) Then HistoryCodeClean(ExePath & "/Temp")
	' Personal Information (Tools > Options > Personal Information)
	WLet(PersonalName, iniSettings.ReadString("PersonalInfo", "Name", ""))
	WLet(PersonalCompany, iniSettings.ReadString("PersonalInfo", "Company", ""))
	WLet(PersonalWebsite, iniSettings.ReadString("PersonalInfo", "Website", ""))
	WLet(PersonalEmail, iniSettings.ReadString("PersonalInfo", "Email", ""))
	' Address is a multiline field; stored with a "\n" placeholder since IniFile
	' stores each key as a single line, so a literal embedded CRLF would corrupt
	' the ini's line-based structure.
	WLet(PersonalAddress, Replace(iniSettings.ReadString("PersonalInfo", "Address", ""), "\n", !"\r\n"))
	'' Git identity -- feeds the New Project dialog's Use Existing Git mode and the
	'' Git Commit/Push dialogs so the user isn't retyping it per project.
	WLet(PersonalGitLogin, iniSettings.ReadString("PersonalInfo", "GitLogin", ""))
	WLet(PersonalGitUserName, iniSettings.ReadString("PersonalInfo", "GitUserName", ""))
	WLet(PersonalGitEmail, iniSettings.ReadString("PersonalInfo", "GitEmail", ""))
	PersonalLicenseGPL3 = iniSettings.ReadBool("PersonalInfo", "LicenseGPL3", False)
	PersonalLicenseLGPL = iniSettings.ReadBool("PersonalInfo", "LicenseLGPL", False)
	PersonalLicenseApache = iniSettings.ReadBool("PersonalInfo", "LicenseApache", False)
	PersonalLicenseBSD = iniSettings.ReadBool("PersonalInfo", "LicenseBSD", False)
	PersonalLicenseFreeware = iniSettings.ReadBool("PersonalInfo", "LicenseFreeware", False)
	PersonalLicenseProprietary = iniSettings.ReadBool("PersonalInfo", "LicenseProprietary", False)
	PersonalLicenseOther = iniSettings.ReadBool("PersonalInfo", "LicenseOther", False)
	WLet(PersonalLicenseOtherText, iniSettings.ReadString("PersonalInfo", "LicenseOtherText", ""))
	SyntaxHighlightingIdentifiers = iniSettings.ReadBool("Options", "SyntaxHighlightingIdentifiers", True)
	ChangeIdentifiersCase = iniSettings.ReadBool("Options", "ChangeIdentifiersCase", True)
	ChangeKeyWordsCase = iniSettings.ReadBool("Options", "ChangeKeyWordsCase", True)
	ChangeEndingType = iniSettings.ReadBool("Options", "ChangeEndingType", True)
	ChoosedIdentifiersCase = iniSettings.ReadInteger("Options", "ChoosedIdentifiersCase", 0)
	ChoosedKeyWordsCase = iniSettings.ReadInteger("Options", "ChoosedKeyWordsCase", 0)
	ChoosedConstructions = iniSettings.ReadInteger("Options", "ChoosedConstructions", 0)
	AddSpacesToOperators = iniSettings.ReadBool("Options", "AddSpacesToOperators", True)
	WLet(CurrentTheme, iniSettings.ReadString("Options", "CurrentTheme", "Default Theme"))
	WLet(EditorFontName, iniSettings.ReadString("Options", "EditorFontName", "Courier New"))
	EditorFontSize = iniSettings.ReadInteger("Options", "EditorFontSize", 10)
		WLet(InterfaceFontName, iniSettings.ReadString("Options", "InterfaceFontName", "Segoe UI"))
		InterfaceFontSize = iniSettings.ReadInteger("Options", "InterfaceFontSize", 9)
	DisplayMenuIcons = iniSettings.ReadBool("Options", "DisplayMenuIcons", True)
	ShowMainToolBar = iniSettings.ReadBool("Options", "ShowMainToolbar", True)
	'gLocalToolBox = iniSettings.ReadBool("Options", "ShowToolBoxLocal", False)
	'gLocalKeyWords = iniSettings.ReadBool("Options", "KeyWordsLocal", False)
	ProjectAutoSuggestions = False
	pDefaultFont->Name = WGet(InterfaceFontName)
	pDefaultFont->Size  = InterfaceFontSize
	'' ImagesList must be bound *unconditionally*, even when icons are switched off. MenuItem
	'' resolves its image key to an index once, inside Add, and only when Owner->ImagesList is
	'' already set (Menus.bas). Binding it to 0 here left every item with ImageIndex = -1 for the
	'' life of the process, so ticking "Display Icons in the Menu" produced no icons -- the keys
	'' had nothing left to resolve against. DisplayIcons is the real switch: MenuItem.SetInfo
	'' checks it and blanks hbmpItem when it is false.
	mnuMain.ImagesList = @imgList
	mnuMain.DisplayIcons = DisplayMenuIcons
	MainReBar.Visible = ShowMainToolBar
	
	WLet(Compiler64Arguments, iniSettings.ReadString("Parameters", "Compiler64Arguments", "-b {S} -exx -mt"))
	WLet(Make1Arguments, iniSettings.ReadString("Parameters", "Make1Arguments", ""))
	WLet(Make2Arguments, iniSettings.ReadString("Parameters", "Make2Arguments", "clean"))
	WLet(RunArguments, iniSettings.ReadString("Parameters", "RunArguments", ""))
	WLet(Debug64Arguments, iniSettings.ReadString("Parameters", "Debug64Arguments", ""))
	pfSplash->lblProcess.Text = ("Load On Startup") & ": " & ("KeyWords")
	LoadKeyWords
	LoadTheme
	EditControlFrame.LoadFromFile(ExePath & "/Resources/Frame.png")
End Sub

' English-only: this used to load a chosen Settings/Languages/*.lng file into the
' mlKeys/mcKeys/mpKeys/mlCompiler translation tables consulted by ML()/MC()/MP()/
' MLCompilerFun(). Those wrapper calls have been removed from the app entirely, so
' the load/parse logic is gone too. App.CurLanguage is still set (App.Language's
' default) because unrelated code still keys off it.
Sub LoadLanguageTexts
	LoadSettingsIni()
	App.CurLanguage = "English"
End Sub

Sub SaveMRU
	Dim As Integer i, MRUStart
	MRUStart = Max(MRUFiles.Count - miRecentMax, 0)
	For i = MRUStart To MRUFiles.Count - 1
		iniSettings.WriteString("MRUFiles", "MRUFile_0" & WStr(i - MRUStart), MRUFiles.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUFiles", "MRUFile_0" & WStr(i))
	Next
	MRUStart = Max(MRUFolders.Count - miRecentMax, 0)
	For i = MRUStart To MRUFolders.Count - 1
		iniSettings.WriteString("MRUFolders", "MRUFolder_0" & WStr(i - MRUStart), MRUFolders.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUFolders", "MRUFolder_0" & WStr(i))
	Next
	MRUStart = Max(MRUProjects.Count - miRecentMax, 0)
	For i = MRUStart To MRUProjects.Count - 1
		iniSettings.WriteString("MRUProjects", "MRUProject_0" & WStr(i - MRUStart), MRUProjects.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUProjects", "MRUProject_0" & WStr(i))
	Next
End Sub

