'#########################################################
'#  SettingsService.bas                                  #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "SettingsService.bi"
#include once "AIService.bi"

Const INDEXED_SETTINGS_SECTION_COUNT As Integer = 8
Const DEFAULT_AI_PORT As Integer = 443
Const DEFAULT_AI_TEMPERATURE As Double = 0.6
Const DEFAULT_AI_CONTENTSIZE_KB As Integer = 100

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
		Dim As UString FullExe = *FbcExe & Slash & CompExe
		If FileExists(FullExe) Then
			WLet(FbcExe, FullExe)
		ElseIf FileExists(*FbcExe & Slash & "bin" & Slash & CompExe) Then
			WLet(FbcExe, *FbcExe & Slash & "bin" & Slash & CompExe)
		ElseIf FileExists(*FbcExe & Slash & "bin" & Slash & "win64" & Slash & CompExe) Then
			WLet(FbcExe, *FbcExe & Slash & "bin" & Slash & "win64" & Slash & CompExe)
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

Sub LoadSettingsIni()
	If FileExists(SettingsPath) Then
		iniSettings.Load SettingsPath
	End If
End Sub

Private Function NoMoreIndexedSettingsKeys(i As Integer) As Boolean
	Dim As Integer keySum = 0
	keySum += iniSettings.KeyExists("AIAgents", "Version_" & WStr(i))
	keySum += iniSettings.KeyExists("MakeTools", "Version_" & WStr(i))
	keySum += iniSettings.KeyExists("Terminals", "Version_" & WStr(i))
	keySum += iniSettings.KeyExists("BuildConfigurations", "Name_" & WStr(i))
	keySum += iniSettings.KeyExists("Helps", "Version_" & WStr(i))
	keySum += iniSettings.KeyExists("OtherEditors", "Version_" & WStr(i))
	keySum += iniSettings.KeyExists("IncludePaths", "Path_" & WStr(i))
	keySum += iniSettings.KeyExists("LibraryPaths", "Path_" & WStr(i))
	Return keySum = -INDEXED_SETTINGS_SECTION_COUNT
End Function

Private Sub AddSeededAIAgent(ByRef AgentName As WString, ByRef HostName As WString = "openrouter.ai", ByRef AddressPath As WString = "api/v1/chat/completions")
	If AgentName = "" OrElse AIAgents.ContainsKey(AgentName) Then Return
	Dim As ModelInfo Ptr Info = _New(ModelInfo)
	Dim As Integer Sep = InStr(AgentName, "|")
	Info->Name = AgentName
	If Sep > 0 Then
		Info->ModelName = Left(AgentName, Sep - 1)
		Info->Provider = Mid(AgentName, Sep + 1)
	Else
		Info->ModelName = AgentName
		Info->Provider = "OpenRouter"
	End If
	Info->Port = DEFAULT_AI_PORT
	Info->Host = HostName
	Info->Address = AddressPath
	Info->APIKey = ""
	Info->Response_Format = ""
	Info->Temperature = DEFAULT_AI_TEMPERATURE
	Info->Top_P = 0
	Info->Stream = True
	Info->ContentSize = DEFAULT_AI_CONTENTSIZE_KB * 1024
	AIAgents.Add AgentName, Info->Host, Info
	If *CurrentAIAgent = AgentName Then
		AIAgentModelName = Info->ModelName
		AIAgentProvider = Info->Provider
		AIAgentHost = Info->Host
		AIAgentPort = Info->Port
		AIAgentAddress = Info->Address
		AIAgentAPIKey = NormalizeAIAgentAPIKey(Info->APIKey)
		AIAgentTemperature = Info->Temperature
		AIAgentStream = Info->Stream
		AIAgentContentSize = Info->ContentSize
		AIPostDataFirstTime = True
		AIIncludeFileNameList.Clear
	End If
End Sub

' When the INI has no [AIAgents] Version_N entries yet (first run / minimal INI),
' seed the default model catalog from upstream VisualFBEditor64.ini so the AI Agent
' dropdown lists the full set instead of only DefaultAIAgent.
Private Sub SeedDefaultAIAgents()
	AddSeededAIAgent(*DefaultAIAgent)
	AddSeededAIAgent("google/gemini-2.5-pro-exp-03-25:free|OpenRouter")
	AddSeededAIAgent("Pro/deepseek-ai/DeepSeek-V3.2-Exp|Silicon", "api.siliconflow.cn", "v1/chat/completions")
	AddSeededAIAgent("qwen/qwen3-coder:free|OpenRouter")
	AddSeededAIAgent("Pro/deepseek-ai/DeepSeek-V3.1-Terminus|Silicon", "api.siliconflow.cn", "v1/chat/completions")
	AddSeededAIAgent("Pro/deepseek-ai/DeepSeek-V3|Silicon", "api.siliconflow.cn", "v1/chat/completions")
	AddSeededAIAgent("Qwen/Qwen3-Coder-480B-A35B-Instruct|Silicon", "api.siliconflow.cn", "v1/chat/completions")
	AddSeededAIAgent("deepseek-chat|DeepSeek", "api.deepseek.com", "v1/chat/completions")
	AddSeededAIAgent("deepseek-reasoner|DeepSeek", "api.deepseek.com", "v1/chat/completions")
	AddSeededAIAgent("deepseek-ai/deepseek-r1-0528|Nvidia", "integrate.api.nvidia.com", "v1/chat/completions")
	AddSeededAIAgent("deepseek/deepseek-r1-0528:free|OpenRouter")
	AddSeededAIAgent("meta-llama/llama-4-maverick:free|OpenRouter")
	AddSeededAIAgent("deepseek/deepseek-prover-v2:free|OpenRouter")
	AddSeededAIAgent("qwen/qwen3.6-plus:free|OpenRouter")
	AddSeededAIAgent("Qwen/Qwen3-235B-A22B|HuggingFace", "api-inference.huggingface.co/models", "Qwen/Qwen3-235B-A22B")
	AddSeededAIAgent("Qwen/Qwen3-235B-A22B-Instruct-2507|Silicon", "api.siliconflow.cn", "v1/chat/completions")
	AddSeededAIAgent("gpt-4.1|AiHubMix", "aihubmix.com", "v1/chat/completions")
	AddSeededAIAgent("moonshot-v1-128k|Kemi", "api.moonshot.cn", "v1/chat/completions")
	AddSeededAIAgent("kimi-k2-instruct|Nvidia", "integrate.api.nvidia.com", "v1/chat/completions")
	AddSeededAIAgent("moonshotai/Kimi-K2-Thinking|Silicon", "api.siliconflow.cn", "v1/chat/completions")
	AddSeededAIAgent("hunter alpha|OpenRouter")
	AddSeededAIAgent("nvidia/nemotron-3-super-120b-a12b|Nvidia", "integrate.api.nvidia.com", "v1/chat/completions")
	AddSeededAIAgent("qwen/Qwen3-Coder-480B-A35B-Instruct|Nvidia", "integrate.api.nvidia.com", "v1/chat/completions")
	AddSeededAIAgent("qwen3.6-plus|AliYun", "dashscope.aliyuncs.com", "compatible-mode/v1")
	AddSeededAIAgent("glm-5.1|glm", "open.bigmodel.cn", "api/paas/v4/chat/completions")
	AddSeededAIAgent("deepseek/deepseek-chat-v3-0324:free|OpenRouter")
	AddSeededAIAgent("deepseek/deepseek-r1:free|OpenRouter")
	AddSeededAIAgent("qwen/qwq-32b:free|OpenRouter")
	AddSeededAIAgent("google/gemini-2.0-flash-thinking-exp:free|OpenRouter")
End Sub

Sub LoadSettings
	LoadSettingsIni()
	Dim As UString Temp
	Dim As ToolType Ptr Tool
	Dim As ModelInfo Ptr Info
	Dim i As Integer = 0
	WLet(DefaultAIAgent, iniSettings.ReadString("AIAgents", "DefaultAIAgent", "deepseek/deepseek-chat-v3-0324:free|OpenRouter"))
	WLet(CurrentAIAgent, *DefaultAIAgent)
	If iniSettings.KeyExists("AIAgents", "Version_0") = -1 Then SeedDefaultAIAgents()
	cboBuildConfiguration.AddItem ML("No options")
	Do
		Temp = iniSettings.ReadString("AIAgents", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Info = _New(ModelInfo)
			Info->Name = Temp
			Info->ModelName = iniSettings.ReadString("AIAgents", "ModelName_" & WStr(i), "deepseek/deepseek-chat-v3-0324:free")
			Info->Provider = iniSettings.ReadString("AIAgents", "Provider_" & WStr(i), "OpenRouter")
			Info->Port = iniSettings.ReadInteger("AIAgents", "Port_" & WStr(i), DEFAULT_AI_PORT)
			Info->Host = iniSettings.ReadString("AIAgents", "Host_" & WStr(i), "openrouter.ai")
			Info->Address = iniSettings.ReadString("AIAgents", "Address_" & WStr(i), "api/v1/chat/completions")
			Info->APIKey = NormalizeAIAgentAPIKey(iniSettings.ReadString("AIAgents", "APIKey_" & WStr(i), ""))
			Info->Response_Format = iniSettings.ReadString("AIAgents", "Response_Format_" & WStr(i), "")
			Info->Temperature = iniSettings.ReadFloat("AIAgents", "Temperature_" & WStr(i), DEFAULT_AI_TEMPERATURE)
			Info->Top_P = iniSettings.ReadFloat("AIAgents", "Top_P_" & WStr(i), 0)
			Info->Stream = iniSettings.ReadBool("AIAgents", "Stream_" & WStr(i), True)
			Info->ContentSize = iniSettings.ReadInteger("AIAgents", "ContentSize_" & WStr(i), DEFAULT_AI_CONTENTSIZE_KB) * 1024
			AIAgents.Add Temp, Info->Host, Info
			If *CurrentAIAgent = Temp Then
				AIAgentModelName = Info->ModelName
				AIAgentProvider = Info->Provider
				AIAgentHost = Info->Host
				AIAgentPort = Info->Port
				AIAgentAddress  = Info->Address
				AIAgentAPIKey = NormalizeAIAgentAPIKey(Info->APIKey)
				AIAgentTemperature = Info->Temperature
				AIAgentStream  = Info->Stream
				AIAgentContentSize  = Info->ContentSize
				AIPostDataFirstTime= True
				AIIncludeFileNameList.Clear
			End If
		End If
		Temp = iniSettings.ReadString("MakeTools", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = iniSettings.ReadString("MakeTools", "Path_" & WStr(i), "")
			Tool->Parameters = iniSettings.ReadString("MakeTools", "Command_" & WStr(i), "")
			MakeTools.Add Temp, Tool->Path, Tool
		End If
		Temp = iniSettings.ReadString("Terminals", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = iniSettings.ReadString("Terminals", "Path_" & WStr(i), "")
			Tool->Parameters = iniSettings.ReadString("Terminals", "Command_" & WStr(i), "")
			Terminals.Add Temp, Tool->Path, Tool
		End If
		Temp = iniSettings.ReadString("OtherEditors", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = iniSettings.ReadString("OtherEditors", "Path_" & WStr(i), "")
			Tool->Parameters = iniSettings.ReadString("OtherEditors", "Command_" & WStr(i), "")
			Tool->Extensions = iniSettings.ReadString("OtherEditors", "Extensions_" & WStr(i), "")
			OtherEditors.Add Temp, Tool->Path, Tool
		End If
		
		Temp = iniSettings.ReadString("Helps", "Version_" & WStr(i), "")
		If Temp <> "" Then Helps.Add Temp, iniSettings.ReadString("Helps", "Path_" & WStr(i), "")
		Temp = iniSettings.ReadString("BuildConfigurations", "Name_" & WStr(i), "")
		If Temp <> "" Then BuildConfigurations.Add Temp, iniSettings.ReadString("BuildConfigurations", "Switches_" & WStr(i), ""): cboBuildConfiguration.AddItem Temp
		Temp = iniSettings.ReadString("IncludePaths", "Path_" & WStr(i), "")
		If Temp <> "" Then IncludePaths.Add Temp
		Temp = iniSettings.ReadString("LibraryPaths", "Path_" & WStr(i), "")
		If Temp <> "" Then LibraryPaths.Add Temp
		i += 1
	Loop Until NoMoreIndexedSettingsKeys(i)
	
	WLet(DefaultCompiler64, "FreeBASIC")
	WLet(CurrentCompiler64, *DefaultCompiler64)
	SetBundledCompilerPath()
	WLet(DefaultMakeTool, iniSettings.ReadString("MakeTools", "DefaultMakeTool", "make"))
	WLet(CurrentMakeTool1, *DefaultMakeTool)
	WLet(MakeToolPath1, MakeTools.Get(*CurrentMakeTool1, "make"))
	WLet(CurrentMakeTool2, *DefaultMakeTool)
	WLet(MakeToolPath2, MakeTools.Get(*CurrentMakeTool2, "make"))
	WLet(DefaultTerminal, iniSettings.ReadString("Terminals", "DefaultTerminal", ""))
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
	WLet(CommandPromptFolder, iniSettings.ReadString("Options", "CommandPromptFolder", "./Projects"))
	LimitDebug = iniSettings.ReadBool("Options", "LimitDebug", False)
	DisplayWarningsInDebug = iniSettings.ReadBool("Options", "DisplayWarningsInDebug", False)
	TurnOnEnvironmentVariables = iniSettings.ReadBool("Options", "TurnOnEnvironmentVariables", True)
	WLet(EnvironmentVariables, iniSettings.ReadString("Options", "EnvironmentVariables"))
	WLet(ProjectsPath, iniSettings.ReadString("Options", "ProjectsPath", "./Projects"))
	GridSize = iniSettings.ReadInteger("Options", "GridSize", 10)
	ShowAlignmentGrid = iniSettings.ReadBool("Options", "ShowAlignmentGrid", True)
	SnapToGridOption = iniSettings.ReadBool("Options", "SnapToGrid", True)
	AutoIncrement = iniSettings.ReadBool("Options", "AutoIncrement", True)
	AutoCreateRC = iniSettings.ReadBool("Options", "AutoCreateRC", True)
	AutoSaveBeforeCompiling = iniSettings.ReadInteger("Options", "AutoSaveBeforeCompiling", 1)
	AutoCreateBakFiles = iniSettings.ReadBool("Options", "AutoCreateBakFiles", False)
	AddRelativePathsToRecent = iniSettings.ReadBool("Options", "AddRelativePathsToRecent", True)
	WhenVisualFBEditorStarts = iniSettings.ReadInteger("Options", "WhenVisualFBEditorStarts", 0)
	WLet(DefaultProjectFile, iniSettings.ReadString("Options", "DefaultProjectFile", "Files/Form.frm"))
	DefaultFileFormat = FileEncodings.Utf8
	DefaultNewLineFormat = NewLineTypes.WindowsCRLF
	LastOpenedFileType = iniSettings.ReadInteger("Options", "LastOpenedFileType", 0)
	AutoComplete = iniSettings.ReadBool("Options", "AutoComplete", True)
		AutoSuggestions = iniSettings.ReadBool("Options", "AutoSuggestions", True)
	AutoIndentation = iniSettings.ReadBool("Options", "AutoIndentation", True)
	ShowSpaces = iniSettings.ReadBool("Options", "ShowSpaces", True)
	ShowKeywordsToolTip = iniSettings.ReadBool("Options", "ShowKeywordsTooltip", True)
	ShowTooltipsAtTheTop = iniSettings.ReadBool("Options", "ShowTooltipsAtTheTop", False)
	GlobalSettings.ShowSymbolsTooltipsOnMouseHover = iniSettings.ReadBool("Options", "ShowSymbolsTooltipsOnMouseHover", True)
	GlobalSettings.ShowClassesExplorerOnOpenWindow = iniSettings.ReadBool("Options", "ShowClassesExplorerOnOpenWindow", True)
	ShowHorizontalSeparatorLines = iniSettings.ReadBool("Options", "ShowHorizontalSeparatorLines", True)
	ShowHolidayFrame = iniSettings.ReadBool("Options", "ShowHolidayFrame", True)
	UseDirect2D = iniSettings.ReadBool("Options", "UseDirect2D", False)
		' Prefer reliable GDI rendering until D2D path is explicitly re-enabled.
		If UseDirect2D Then
			UseDirect2D = False
			iniSettings.WriteBool("Options", "UseDirect2D", False)
		End If
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
	DarkMode = iniSettings.ReadBool("Options", "DarkMode", False)
	' Bypass the App.DarkMode property (which broadcasts WM_SETTINGCHANGE to
	' the whole desktop) here - at this point in startup nothing of ours has
	' been created yet, so there's nothing to refresh, and every control
	' will already paint correctly via its own first WM_PAINT.
	If g_buildNumber = 0 Then InitDarkMode
	SetDarkMode(DarkMode, False, False)
	'gLocalToolBox = iniSettings.ReadBool("Options", "ShowToolBoxLocal", False)
	gLocalProperties = iniSettings.ReadBool("Options", "PropertiesLocal", False)
	'gLocalKeyWords = iniSettings.ReadBool("Options", "KeyWordsLocal", False)
	ProjectAutoSuggestions = False
	pDefaultFont->Name = WGet(InterfaceFontName)
	pDefaultFont->Size  = InterfaceFontSize
	mnuMain.DisplayIcons = DisplayMenuIcons
	mnuMain.ImagesList = IIf(DisplayMenuIcons, @imgList, 0)
	MainReBar.Visible = ShowMainToolBar
	
	WLet(Compiler64Arguments, iniSettings.ReadString("Parameters", "Compiler64Arguments", "-b {S} -exx -mt"))
	WLet(Make1Arguments, iniSettings.ReadString("Parameters", "Make1Arguments", ""))
	WLet(Make2Arguments, iniSettings.ReadString("Parameters", "Make2Arguments", "clean"))
	WLet(RunArguments, iniSettings.ReadString("Parameters", "RunArguments", ""))
	WLet(Debug64Arguments, iniSettings.ReadString("Parameters", "Debug64Arguments", ""))
	pfSplash->lblProcess.Text = ML("Load On Startup") & ": " & ML("KeyWords")
	LoadKeyWords
	LoadTheme
		LoadD2D1
	EditControlFrame.LoadFromFile(ExePath & "/Resources/Frame.png")
End Sub

Sub LoadLanguageTexts
	LoadSettingsIni()
	App.CurLanguagePath = ExePath & "/Settings/Languages/"
	App.CurLanguage = iniSettings.ReadString("Options", "Language", "english")
	Dim As Boolean StartGeneral = True, StartKeyWords, StartProperty, StartCompiler, StartTemplates
	If App.CurLanguage = "" Then
		mpKeys.Add "#Til", "English"
		mlKeys.Add "#Til", "English"
		mlCompiler.Add "#Til", "English"
		App.CurLanguage = "English"
	Else
		mlKeys.Clear
		mcKeys.Clear
		mpKeys.Clear
		mlCompiler.Clear
		Dim As Integer i, Pos1, Pos2
		Dim As Integer Fn = FreeFile_, Result
		Dim As WString * 2048 Buff, tKey
		Dim As WString * MAX_PATH Filename = ExePath & "/Settings/Languages/" & App.CurLanguage & ".lng"
		Result = Open(FileName For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn)
		If Result = 0 Then
			Do Until EOF(Fn)
				Line Input #Fn, Buff
				If LCase(Trim(Buff)) = "[keywords]" Then
					StartKeyWords = True
					StartProperty = False
					StartCompiler = False
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[property]" Then
					StartKeyWords = False
					StartProperty = True
					StartCompiler = False
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[compiler]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = True
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[templates]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = False
					StartTemplates = True
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[general]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = False
					StartTemplates = False
					StartGeneral = True
				End If
				Pos1 = InStr(Buff, "=")
				If Len(Trim(Buff, Any !"\t ")) > 0 AndAlso Pos1 > 0 Then
					Pos2 = InStr(Pos1, Buff, "|")
					'David Change For the Control Property's Language.
					'note: "=" already convert To "~"
					tKey = Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")
					Var Pos3 = InStr(Buff, "~")
					If Pos3 > 0 AndAlso Pos3 < Pos1 Then Buff = Replace(Buff, "~", "=")
					If StartGeneral = True Then
						If Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then mlKeys.Add Trim(Left(Buff, Pos1 - 1), Any !"\t "), Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					ElseIf StartProperty = True Then
						If Pos2 > 0 Then
							mpKeys.Add tKey, Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1), Any !"\t ")
							If Len(Buff) - Pos2 <= 1 Then
								mcKeys.Add tKey, Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")  & IIf(Trim(Mid(Buff, 1, Pos1 - 1)) <> Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1)), "  " & Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1), Any !"\t "), WStr(""))   ' No comment
							Else
								mcKeys.Add tKey, Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")  & IIf(Trim(Mid(Buff, 1, Pos1 - 1)) <> Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1)), "  " & Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1), Any !"\t "), WStr("")) & Chr(13, 10) & Trim(Mid(Buff, Pos2 + 1, Len(Buff) - Pos2), Any !"\t ")
							End If
						Else
							mpKeys.Add tKey, Trim(Mid(Buff, Pos1 + 1, Len(Buff) - Pos2), Any !"\t ")
							mcKeys.Add tKey, Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ") & "  " & Trim(Mid(Buff, Pos1 + 1, Len(Buff) - Pos2), Any !"\t ")
						End If
					ElseIf StartKeyWords = True Then
						
					ElseIf StartCompiler = True Then
						If Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then mlCompiler.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					ElseIf StartTemplates = True Then
						If Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then mlTemplates.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					End If
				End If
			Loop
			mlKeys.SortKeys
			mpKeys.SortKeys
			mlCompiler.SortKeys
			mlTemplates.SortKeys
			CloseFile_(Fn)
			Exit Sub
		Else
			MsgBox ML("Open file failure!") &  " " & Chr(13, 10) & ML("in function") & " Main.LoadLanguageTexts" & Chr(13, 10) & "  " & ExePath & "/Settings/Languages/" & App.CurLanguage & ".lng"
		End If
	End If
	mlKeys.Clear
	mcKeys.Clear
	mpKeys.Clear
	mlCompiler.Clear
	mpKeys.Add "#Til", "English"
	mlKeys.Add "#Til", "English"
	mlCompiler.Add "#Til", "English"
	App.CurLanguage = "english"
End Sub

Sub SaveMRU
	Dim As Integer i, MRUStart
	MRUStart = Max(MRUAIChat.Count - miRecentMax, 0)
	For i = MRUStart To MRUAIChat.Count - 1
		iniSettings.WriteString("MRUAIChat", "MRUAIChat_0" & WStr(i - MRUStart), MRUAIChat.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUAIChat", "MRUAIChat_0" & WStr(i))
	Next
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

