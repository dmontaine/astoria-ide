'#########################################################
'#  BuildService.bas                                     #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "BuildService.bi"

Sub CompileContextFree(ByRef ctx As CompileContext)
	WDeAllocate(ctx.FbcExe)
	WDeAllocate(ctx.PipeApplicationName)
	WDeAllocate(ctx.PipeCommand)
	WDeAllocate(ctx.ExeName)
	WDeAllocate(ctx.LogText)
	WDeAllocate(ctx.fbcCommand)
	WDeAllocate(ctx.CompileWith)
	WDeAllocate(ctx.MFFPathC)
	WDeAllocate(ctx.FirstLine)
	WDeAllocate(ctx.ErrTitle)
	WDeAllocate(ctx.ErrFileName)
	WDeAllocate(ctx.LogFileName)
	WDeAllocate(ctx.LogFileName2)
	WDeAllocate(ctx.BatFileName)
	WDeAllocate(ctx.MainFile)
	WDeAllocate(ctx.MainFileNameOnly)
	WDeAllocate(ctx.ProjectPath)
	WDeAllocate(ctx.BatchCompilationFileName)
	WDeAllocate(ctx.ProcessWorkDir)
End Sub

Sub CompileSetProcessWorkDir(ByRef ctx As CompileContext, Parameter As String, BatchMode As Boolean)
	If BatchMode Then
		Dim As UString BatchFileFull = GetFullPath(*ctx.BatchCompilationFileName)
		WLet(ctx.ProcessWorkDir, GetFolderName(BatchFileFull))
	ElseIf CInt(Parameter = "Make") OrElse CInt(Parameter = "MakeClean") OrElse CInt(CInt(Parameter = "Run" OrElse Parameter = "RunWithDebug") AndAlso CInt(UseMakeOnStartWithCompile) AndAlso CInt(FileExists(GetFolderName(*ctx.MainFile) & "/makefile") OrElse FileExists(*ctx.ProjectPath & "/makefile"))) Then
		If FileExists(GetFolderName(*ctx.MainFile) & "/makefile") Then
			WLet(ctx.ProcessWorkDir, GetFolderName(*ctx.MainFile))
		Else
			WLet(ctx.ProcessWorkDir, *ctx.ProjectPath)
		End If
	Else
		WLet(ctx.ProcessWorkDir, GetFolderName(*ctx.MainFile))
	End If
End Sub

Function Compile(Parameter As String, bAll As Boolean) As Integer
	On Error Goto ErrorHandler
	Dim ctx As CompileContext
	Dim As Integer NumberErr, NumberWarning, NumberInfo, NodesCount, CompileResult = 1
	Dim As UString CompileLine
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	ThreadsEnter()
	ClearMessages
	NodesCount = IIf(bAll, tvExplorer.Nodes.Count, 1)
	lvProblems.ListItems.Clear
	tpProblems->Caption = ML("Problems") '    'Inits
	ThreadsLeave()
	For k As Integer = 0 To NodesCount - 1
		ThreadsEnter()
		StartProgress
		If bAll Then ProjectNode = tvExplorer.Nodes.Item(k) Else ProjectNode = 0
		WLet(ctx.MainFile, GetMainFile(AutoSaveBeforeCompiling, Project, ProjectNode))
		If Project Then
			If EndsWith(LCase(*Project->FileName), ".vfp") Then
				WLet(ctx.ProjectPath, GetFolderName(*Project->FileName))
			Else
				WLet(ctx.ProjectPath, *Project->FileName)
			End If
		Else
			WLet(ctx.ProjectPath, GetFolderName(*ctx.MainFile))
		End If
		ThreadsLeave()
		If Len(*ctx.MainFile) <= 0 Then
			ThreadsEnter()
			ShowMessages ML("No Main file specified for the project.") & "!"
			ThreadsLeave()
			CompileResult = 0
			Continue For
		End If
		WLet(ctx.FirstLine, GetFirstCompileLine(*ctx.MainFile, Project, CompileLine))
		Versioning *ctx.MainFile, *ctx.FirstLine & CompileLine, Project, ProjectNode
		WLet(ctx.ExeName, GetExeFileName(*ctx.MainFile, CompileLine & " " & *ctx.FirstLine))
		If Project AndAlso Trim(*Project->CompilerPath) <> "" Then
			WLet(ctx.FbcExe, GetFullPath(*Project->CompilerPath))
		Else
			WLet(ctx.FbcExe, GetFullPath(GetBundledCompilerExe()))
		End If
		If *ctx.FbcExe = "" Then
			ThreadsEnter()
			ShowMessages ML("Invalid defined compiler path.")
			ThreadsLeave()
			CompileResult = 0
			Continue For
		Else
			If Not FileExists(*ctx.FbcExe) Then
				ThreadsEnter()
				ShowMessages ML("File") & " """ & *ctx.FbcExe & """ " & ML("not found") & "!"
				ThreadsLeave()
				CompileResult = 0
				Continue For
			End If
		End If
		Dim As Integer iLine
		WLet(ctx.MFFPathC, *MFFPath)
		If CInt(InStr(*ctx.MFFPathC, ":") = 0) AndAlso CInt(Not StartsWith(*ctx.MFFPathC, "/")) Then WLet(ctx.MFFPathC, ExePath & "/" & *MFFPath)
		WLet(ctx.BatFileName, ExePath + "/debug.bat")
		Dim As Boolean Band, Yaratilmadi
		Dim As UserToolType Ptr Tool
		For i As Integer = 0 To Tools.Count - 1
			Tool = Tools.Item(i)
			If Tool->LoadType = LoadTypes.BeforeCompile Then Tool->Execute
		Next
		Dim As Any Ptr AddInDll
		Dim As Sub(VisualFBEditorApp As Any Ptr, ByRef CompilingProgramPath As WString) OnBeforeCompile
		For i As Integer = 0 To AddIns.Count - 1
			AddInDll = AddIns.Object(i)
			If AddInDll <> 0 Then
				OnBeforeCompile = DyLibSymbol(AddInDll, "OnBeforeCompile")
				If OnBeforeCompile Then
					OnBeforeCompile(@VisualFBEditorApp, *ctx.ExeName)
				End If
			End If
		Next
		If Parameter <> "Check" Then
			If Dir(*ctx.ExeName) <> "" Then
				If *ctx.ExeName = ExePath OrElse Kill(*ctx.ExeName) <> 0 Then
					ThreadsEnter()
					ShowMessages(Str(Time) & ": " &  ML("Cannot compile - the program is now running") & " " & *ctx.ExeName)
					ThreadsLeave()
					Band = True
					CompileResult = 0
					Continue For
				End If
			End If
		End If
		Dim As Integer Idx
		Dim As ToolType Ptr CompilerTool
		If Parameter = "Make" Then
			Idx = pMakeTools->IndexOfKey(*CurrentMakeTool1)
			If Idx <> -1 Then CompilerTool = pMakeTools->Item(Idx)->Object
		ElseIf Parameter = "MakeClean" Then
			Idx = pMakeTools->IndexOfKey(*CurrentMakeTool2)
			If Idx <> -1 Then CompilerTool = pMakeTools->Item(Idx)->Object
		Else
			CompilerTool = 0
		End If
		If CompilerTool <> 0 Then
			WLet(ctx.CompileWith, CompilerTool->GetCommand(, True))
		Else
			WLet(ctx.CompileWith, "")
		End If
		If Parameter = "Check" Then WAdd(ctx.CompileWith, " -c")
		WAdd(ctx.CompileWith, " " & *ctx.FirstLine)
		WLet(ctx.MainFileNameOnly, GetFileName(*ctx.MainFile))
			If InStr(LCase(*ctx.CompileWith), ".rc") < 1 AndAlso FileExists(Left(*ctx.MainFile, Len(*ctx.MainFile) - 4) & ".rc") Then WAdd(ctx.CompileWith, " """  & GetFileName(Left(*ctx.MainFile, Len(*ctx.MainFile) - 4) & ".rc"""))
		If Project Then
			Select Case Project->CompileTo
			Case ByDefault:
			Case ToGAS: WAdd(ctx.CompileWith, " -gen gas64")
			Case ToLLVM: WAdd(ctx.CompileWith, " -gen llvm" )
			Case ToGCC: WAdd(ctx.CompileWith, " -gen gcc" )
			Case ToCLANG: WAdd(ctx.CompileWith, " -gen clang" )
			End Select
			For i As Integer = 0 To Project->Components.Count - 1
				If EndsWith(Project->Components.Item(i), Slash) Then
					WAdd(ctx.CompileWith, " -i """ & GetRelativePath(Left(Project->Components.Item(i), Len(Project->Components.Item(i)) - 1), *ctx.ProjectPath & Slash) & """")
				Else
					WAdd(ctx.CompileWith, " -i """ & GetRelativePath(Project->Components.Item(i), *ctx.ProjectPath & Slash) & """")
				End If
			Next
		End If
		Dim CtlLibrary As Library Ptr
		For i As Integer = 0 To ControlLibraries.Count - 1
			CtlLibrary = ControlLibraries.Item(i)
			If CtlLibrary <> 0 AndAlso CtlLibrary->Enabled Then
				If EndsWith(CtlLibrary->IncludeFolder, Slash) Then
					WAdd(ctx.CompileWith, " -i """ & Left(CtlLibrary->IncludeFolder, Len(CtlLibrary->IncludeFolder) - 1) & """")
				Else
					WAdd(ctx.CompileWith, " -i """ & CtlLibrary->IncludeFolder & """")
				End If
				Dim As UString LibFolder
						LibFolder = CtlLibrary->Lib64Folder
				If LibFolder <> "" Then
					If EndsWith(LibFolder, Slash) Then
						WAdd(ctx.CompileWith, " -p """ & Left(LibFolder, Len(LibFolder) - 1) & """")
					Else
						WAdd(ctx.CompileWith, " -p """ & LibFolder & """")
					End If
				End If
			End If
		Next
		For i As Integer = 0 To pIncludePaths->Count - 1
			WAdd(ctx.CompileWith, " -i """ & pIncludePaths->Item(i) & """")
		Next
		For i As Integer = 0 To pLibraryPaths->Count - 1
			WAdd(ctx.CompileWith, " -p """ & pLibraryPaths->Item(i) & """")
		Next
		WAdd(ctx.CompileWith, " -d _DebugWindow_=" & Str(txtImmediate.Handle))
		WLet(ctx.LogFileName2, ExePath & "/Temp/Compile.log")
		Dim As UString OtherModuleFiles
		If CInt(ProjectNode <> 0) AndAlso CInt(Project <> 0) AndAlso CInt(Project->PassAllModuleFilesToCompiler) Then
			For i As Integer = 0 To ProjectNode->Nodes.Count - 1
				If EndsWith(LCase(ProjectNode->Nodes.Item(i)->Text), ".bas") Then
					If LCase(*ctx.MainFileNameOnly) <> LCase(ProjectNode->Nodes.Item(i)->Text) Then
						OtherModuleFiles &= " """ & GetRelative(*Cast(ExplorerElement Ptr, ProjectNode->Nodes.Item(i)->Tag)->FileName, GetFolderName(*Project->MainFileName)) & """"
					End If
				Else
					For j As Integer = 0 To ProjectNode->Nodes.Item(i)->Nodes.Count - 1
						If EndsWith(LCase(ProjectNode->Nodes.Item(i)->Nodes.Item(j)->Text), ".bas") Then
							If LCase(*ctx.MainFileNameOnly) <> LCase(ProjectNode->Nodes.Item(i)->Nodes.Item(j)->Text) Then
								OtherModuleFiles &= " """ & GetRelative(*Cast(ExplorerElement Ptr, ProjectNode->Nodes.Item(i)->Nodes.Item(j)->Tag)->FileName, GetFolderName(*Project->MainFileName)) & """"
							End If
						End If
					Next
				End If
			Next
		End If
		If InStr(*ctx.CompileWith, "{S}") > 0 Then
			WLet(ctx.fbcCommand, Replace(*ctx.CompileWith, "{S}", """" & *ctx.MainFileNameOnly & """" & OtherModuleFiles))
		Else
			WLet(ctx.fbcCommand, """" & *ctx.MainFileNameOnly & """" & OtherModuleFiles & " " & *ctx.CompileWith)
		End If
		If Parameter <> "" AndAlso Parameter <> "Make" AndAlso Parameter <> "MakeClean" Then
			If Parameter = "Check" Then WAdd(ctx.fbcCommand, " -x """ & *ctx.ExeName & """")
		End If
		If InStr(LCase(*ctx.FbcExe), ".exe") = 0 Then
			ResolveFbcExePath ctx.FbcExe, 0, ctx.fbcCommand
		End If
		If CInt(Parameter = "Make") OrElse CInt(CInt(Parameter = "Run" OrElse Parameter = "RunWithDebug") AndAlso CInt(UseMakeOnStartWithCompile) AndAlso CInt(FileExists(GetFolderName(*ctx.MainFile) & "/makefile") OrElse FileExists(*ctx.ProjectPath & "/makefile"))) Then
			Dim As String Colon = ""
			WLet(ctx.PipeCommand, """" & *MakeToolPath1 & """ FBC" & Colon & "=""""""" & *ctx.FbcExe & """"""" XFLAG" & Colon & "=""-x """"" & *ctx.ExeName & """""""" & IIf(UseDebugger, " GFLAG" & Colon & "=-g", "") & " " & *Make1Arguments)
		ElseIf Parameter = "MakeClean" Then
			WLet(ctx.PipeCommand, """" & *MakeToolPath2 & """ " & *Make2Arguments)
		Else
			WLet(ctx.PipeCommand, """" & *ctx.FbcExe & """ " & *ctx.fbcCommand)
		End If
		ctx.BatchCompilationFileName = 0
		Dim BatchMode As Boolean = False
		Dim As UString BatchFileFull
		If Project Then ctx.BatchCompilationFileName = Project->BatchCompilationFileNameWindows
		If WGet(ctx.BatchCompilationFileName) <> "" AndAlso Parameter <> "Make" AndAlso Parameter <> "MakeClean" Then
			BatchMode = True
			If LCase(GetFileName(*ctx.BatchCompilationFileName)) = "makefile" Then
				WLet(ctx.PipeCommand, "make")
			Else
				WLet(ctx.PipeCommand, *ctx.BatchCompilationFileName)
			End If
			BatchFileFull = GetFullPath(*ctx.BatchCompilationFileName)
			Dim As Integer Fn1 = FreeFile_
			Open BatchFileFull For Input As #Fn1
			Dim pBuff As WString Ptr
			Dim As Integer FileSize
			Dim As WStringList Lines
			FileSize = LOF(Fn1)
			WReAllocate(pBuff, FileSize)
			Do Until EOF(Fn1)
				LineInputWstr Fn1, pBuff, FileSize
				Lines.Add *pBuff
			Loop
			CloseFile_(Fn1)
			WDeAllocate(pBuff)
			Dim As Integer Fn2 = FreeFile_
			Open BatchFileFull For Output As #Fn2
			For i As Integer = 0 To Lines.Count - 1
				If StartsWith(Lines.Item(i), "set FBC=") Then
					Print #Fn2, "set FBC=" & *ctx.FbcExe
				ElseIf StartsWith(Lines.Item(i), "set MFF=") Then
					Print #Fn2, "set MFF=" & *ctx.MFFPathC
				Else
					Print #Fn2, Lines.Item(i)
				End If
			Next i
			CloseFile_(Fn2)
		End If
		CompileSetProcessWorkDir ctx, Parameter, BatchMode
		Dim As Boolean Log2_, ERRGoRc
		ThreadsEnter()
		ShowMessages(Str(Time) + ": " + IIf(Parameter = "MakeClean", ML("Clean"), ML("Compilation")) & ": " & *ctx.PipeCommand + WChr(13) + WChr(10))
		ThreadsLeave()
		Dim As Dictionary CompileCommands
		CompileCommands.Add "", *ctx.PipeCommand
		Dim As UShort bFlagErr
		Dim As Double CompileElapsedTime = Timer
		Dim lpWorkDir As WString Ptr
		For cc As Integer = 0 To CompileCommands.Count - 1
			WLet(ctx.PipeCommand, CompileCommands.Item(cc)->Text)
			If cc > 0 Then
				ThreadsEnter()
				ShowMessages(Str(Time) + ": " + CompileCommands.Item(cc)->Key & *ctx.PipeCommand)
				ThreadsLeave()
			End If
			Dim As String TmpStrKey = "@freebasic compiler@copyright@standalone@target@backend@compiling@compiling rc@compiling rc failed@compiling c@assembling@linking@obj@creating@restarting@creating import library@archiving@"
			Dim As WString * 2048 TmpStr
			Dim As Integer BufferSize = 128
			Dim si As STARTUPINFO
			Dim pi As PROCESS_INFORMATION
			Dim sa As SECURITY_ATTRIBUTES
			Dim hReadPipe As HANDLE
			Dim hWritePipe As HANDLE
			Dim sBuffer As ZString * 2048
			Dim sOutput As UString
			Dim bytesRead As DWORD
			Dim result_ As Integer
			sa.nLength = SizeOf(SECURITY_ATTRIBUTES)
			sa.lpSecurityDescriptor = NULL
			sa.bInheritHandle = True
			If CreatePipe(@hReadPipe, @hWritePipe, @sa, ByVal 0) = 0 Then
				ShowMessages(ML("Error: Couldn't Create Pipe"), False)
				CompileResult = 0
				Continue For
			End If
			si.cb = Len(STARTUPINFO)
			si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
			si.hStdOutput = hWritePipe
			si.hStdError = hWritePipe
			si.hStdInput  = hReadPipe
			si.wShowWindow = 0
			lpWorkDir = ctx.ProcessWorkDir
			If lpWorkDir = 0 OrElse *lpWorkDir = "" Then lpWorkDir = 0
			If CreateProcess(ctx.PipeApplicationName, ctx.PipeCommand, @sa, @sa, 1, NORMAL_PRIORITY_CLASS Or CREATE_NEW_CONSOLE, ByVal 0, lpWorkDir, @si, @pi) = 0 Then
				ShowMessages(ML("Error: Couldn't Create Process") & ": " & GetErrorString(GetLastError), False)
				CompileResult = 0
				Continue For
			End If
			CloseHandle hWritePipe
			Dim As Integer Pos1, FirstErrFlag
			Do
				result_ = ReadFile(hReadPipe, @sBuffer, BufferSize, @bytesRead, ByVal 0)
				sBuffer = Left(sBuffer, bytesRead)
				If CBool(FirstErrFlag < 2) AndAlso CBool(InStr(sBuffer, "compiling:")) Then sBuffer += Chr(10) : FirstErrFlag += 1: BufferSize = 2048
				Pos1 = InStrRev(sBuffer, Chr(10))
				If Pos1 > 0 Then
					sOutput += Left(sBuffer, Pos1 - 1)
					Dim res() As WString Ptr
					If CBool(InStr(sOutput, "GoRC.exe' terminated with exit code") > 0) OrElse CBool(InStr(sOutput, "of Resource Script ") > 0) Then
						sOutput = Replace(sOutput, Chr(13, 10), " ")
						ERRGoRc = True
					End If
					Dim As String buffer = Str(sOutput)
					Dim As Integer wideCharsNeeded = MultiByteToWideChar(CP_ACP, 0, StrPtr(buffer), -1, NULL, 0)
					sOutput.Resize wideCharsNeeded
					MultiByteToWideChar(CP_ACP, 0, StrPtr(buffer), -1, sOutput.m_Data, wideCharsNeeded)
					Split sOutput, Chr(10), res()
					For i As Integer = 0 To UBound(res)
						*res(i) = Trim(*res(i), Any !"\t\n\r ")
						If Len(*res(i)) < 10 OrElse StartsWith(Trim(*res(i)), "|") Then Continue For
						Dim As Integer nPos = InStr(*res(i), ":")
						If nPos < 1 Then nPos = InStr(*res(i), " ")
						If nPos < 1 Then
							nPos = Len(*res(i)) + 1
							TmpStr = Trim(*res(i))
						Else
							TmpStr = Trim(Left(*res(i), nPos - 1))
						End If
						Dim As Boolean bErrorInfo = InStr(LCase(TmpStrKey), "@" & LCase(TmpStr) & "@") OrElse InStr(LCase(*res(i)), "ld.exe") > 0
						If Not bErrorInfo Then
							bFlagErr = SplitError(*res(i), ctx.ErrFileName, ctx.ErrTitle, iLine)
							If iLine > 0 OrElse InStr(LCase(*ctx.ErrTitle), "runtime error") > 0 Then
								If bFlagErr = 2 Then
									NumberErr += 1
								ElseIf bFlagErr = 1 Then
									NumberWarning += 1
								Else
									NumberInfo += 1
								End If
							End If
							If bFlagErr >= 0 AndAlso *ctx.ErrFileName <> "" AndAlso iLine> 0 Then
								If InStr(*ctx.ErrFileName, "/") = 0 AndAlso InStr(*ctx.ErrFileName, "\") = 0 Then WLetEx(ctx.ErrFileName, GetFolderName(*ctx.MainFile) & *ctx.ErrFileName)
								lvProblems.ListItems.Add *ctx.ErrTitle, IIf(bFlagErr = 1, "Warning", IIf(bFlagErr = 2, "Error", "Info"))
								lvProblems.ListItems.Item(lvProblems.ListItems.Count - 1)->Text(1) = WStr(iLine)
								lvProblems.ListItems.Item(lvProblems.ListItems.Count - 1)->Text(2) = *ctx.ErrFileName
								FirstErrFlag += 1
								ShowMessages(*res(i), False)
							Else
								ShowMessages(Str(Time) & ": " & *res(i), False)
							End If
						Else
							If StartsWith(TmpStr, "FreeBASIC") Then
								nPos = Len(*res(i)) + 1
								TmpStr = Replace(Replace(*res(i), "FreeBASIC Compiler", ML("FreeBASIC Compiler")), "Version", ML("Version"))
								Var Pos1 = InStr(TmpStr, "built for ")
								If Pos1 > 0 Then
									TmpStr = Left(TmpStr, Pos1 - 1) & MS("built for $1", Mid(TmpStr, Pos1 + 10))
								End If
							ElseIf StartsWith(TmpStr, "Copyright") Then
								nPos = Len(*res(i)) + 1
								TmpStr = Replace(Replace(*res(i), "Copyright", ML("Copyright")), "The FreeBASIC development team.", ML("The FreeBASIC development team."))
							End If
							ThreadsEnter()
							ShowMessages Str(Time) & ": " & ML(TmpStr) & " " & Trim(Mid(*res(i), nPos))
							ThreadsLeave()
						End If
						_Deallocate(res(i)): res(i) = 0
						sOutput = ""
					Next i
					Erase res
					If sBuffer <> "" Then sOutput = Mid(sBuffer, Pos1 + 1)
				Else
					sOutput += sBuffer
				End If
			Loop While result_
			CloseHandle pi.hProcess
			CloseHandle pi.hThread
			CloseHandle hReadPipe
			If NumberErr > 0 Then Exit For
		Next cc
		Yaratilmadi = Dir(*ctx.ExeName) = ""
		ThreadsEnter()
		ShowMessages("")
		If lvProblems.ListItems.Count <> 0 Then
			tpProblems->Caption = ML("Problems") & IIf(NumberErr + NumberWarning + NumberInfo > 0, WStr(" (" & WStr(NumberErr + NumberWarning + NumberInfo) & " " & ML("Pos") & ")"), WStr(""))
			Dim As UString Problems
			Problems = IIf(NumberErr > 0, ML("Errors") & " (" & WStr(NumberErr) & " " & ML("Pos") & ")", WStr(""))
			Problems &= IIf(NumberWarning > 0, IIf(Problems = "", WStr(""), WStr(", ")) & ML("Warnings") & " (" & WStr(NumberWarning) & " " & ML("Pos") & ")", WStr(""))
			Problems &= IIf(NumberInfo > 0, IIf(Problems = "", WStr(""), WStr(", ")) & ML("Messages") & " (" & WStr(NumberInfo) & " " & ML("Pos") & ")", WStr(""))
			ShowMessages(Str(Time) & ": " & MS("Found $1.", *Problems.vptr), False)
		Else
			tpProblems->Caption = ML("Problems")
		End If
		ThreadsLeave()
		For i As Integer = 0 To Tools.Count - 1
			Tool = Tools.Item(i)
			If Tool->LoadType = LoadTypes.AfterCompile Then Tool->Execute
		Next
		If Yaratilmadi Or Band Then
			ThreadsEnter()
			If Parameter <> "Check" Then
				If lvProblems.ListItems.Count < 1 Then ShowMessages(Str(Time) & ": " & MS("Found $1.",  ML("Errors") & " (1) " & ML("Pos")), False)
				ShowMessages(Str(Time) & ": " & ML("Do not build file.")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				If (Not Log2_) AndAlso lvProblems.ListItems.Count <> 0 Then tpProblems->SelectTab
			ElseIf lvProblems.ListItems.Count <> 0 Then
				ShowMessages(Str(Time) & ": " & ML("Checking ended.")) & " " & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				tpProblems->SelectTab
			Else
				ShowMessages(Str(Time) & ": " & ML("No errors or warnings were found.")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
			End If
			StopProgress
			ThreadsLeave()
			CompileResult = 0
		Else
			ThreadsEnter()
			If InStr(*ctx.LogText, "warning") > 0 Then
				If Parameter <> "Check" Then
					ShowMessages(Str(Time) & ": " & ML("Layout has been successfully completed, but there are warnings.")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				End If
			Else
				If Parameter <> "Check" Then
					ShowMessages(Str(Time) & ": " & ML("Layout succeeded!")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				Else
					ShowMessages(Str(Time) & ": " & ML("Syntax errors not found!")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				End If
			End If
			StopProgress
			ThreadsLeave()
			If Parameter = "Run" Then
				If Project <> 0 Then
					RunPr , *Project->FileName, *Project->CommandLineArguments, *ctx.MainFile, CompileLine, *ctx.FirstLine
				Else
					RunPr , "", "", *ctx.MainFile, CompileLine, *ctx.FirstLine
				End If
			ElseIf Parameter = "RunWithDebug" Then
				If Project <> 0 Then
					RunWithDebug , *Project->FileName, *Project->CommandLineArguments, *ctx.MainFile, CompileLine, *ctx.FirstLine
				Else
					RunWithDebug , "", "", *ctx.MainFile, CompileLine, *ctx.FirstLine
				End If
			End If
		End If
	Next k
	ThreadsEnter()
	StopProgress
	ThreadsLeave()
	CompileContextFree(ctx)
	Return CompileResult
	Exit Function
	ErrorHandler:
	ThreadsEnter()
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
	ThreadsLeave()
End Function

