'#########################################################
'#  VisualFBEditor.bas                                   #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################
	#define _NOT_AUTORUN_FORMS_

		#cmdline "-x ../VisualFBEditor64.exe"

#define APP_TITLE "Visual FB Editor"
#define VER_MAJOR "1"
#define VER_MINOR "3"
#define VER_PATCH "8"
#define VER_BUILD "0"
Const VERSION    = VER_MAJOR + "." + VER_MINOR + "." + VER_PATCH
Const BUILD_DATE = __DATE__
Const SIGN       = APP_TITLE + " " + VERSION

On Error Goto AA

' Dev leak audits (local only — do not ship enabled):
'   Uncomment #define MEMCHECK 1 and/or #define FILENUMCHECK 1 below, rebuild, exercise the IDE, check stderr on exit.
'   Or pass -d MEMCHECK=1 -d FILENUMCHECK=1 to fbc64. Shipped default: both off.
'#define MEMCHECK 1
'#define FILENUMCHECK 1
	#define MEMCHECK 0
	#define FILENUMCHECK 0
#ifndef _WIN32_WINNT
	#define _WIN32_WINNT &h0602
#endif
#define _L DebugPrint_ __LINE__ & ": " & __FILE__ & ": " & __FUNCTION__:

Declare Sub DebugPrint_(ByRef MSG As WString)

#include once "Main.bi"
#include once "Debug.bi"
#include once "Designer.bi"
#include once "frmAddProcedure.frm"
#include once "frmAddType.frm"
#include once "frmOptions.bi"
#include once "frmGoto.bi"
#include once "frmFind.bi"
#include once "frmFindInFiles.bi"
#include once "frmProjectProperties.bi"
#include once "frmImageManager.bi"
#include once "frmParameters.bi"
#include once "frmAddIns.bi"
#include once "frmTools.bi"
#include once "frmAbout.bi"
#include once "TabWindow.bi"

Sub DebugPrint_(ByRef msg As WString)
	Debug.Print msg, True, False, False, False
End Sub

Sub StartDebuggingWithCompile(Param As Any Ptr)
	'	ThreadsEnter
	'	ChangeEnabledDebug False, True, True
	'	ThreadsLeave
	If Compile("RunWithDebug") Then Else ThreadsEnter: ChangeEnabledDebug True, False, False: ThreadsLeave
End Sub

Sub StartDebugging(Param As Any Ptr)
	ThreadsEnter
	ChangeEnabledDebug False, True, True
	ThreadsLeave
	RunProgramWithDebug(0)
End Sub

Sub RunCmd(Param As Any Ptr)
	Dim As UString MainFile = GetMainFile()
	Dim As UString cmd
	Dim As WString Ptr Workdir, CmdL
	If Trim(MainFile) = "" OrElse Trim(MainFile) = ("Untitled") Then MainFile = GetFullPath(*ProjectsPath & "\1", pApp->FileName)
	If OpenCommandPromptInMainFileFolder Then
		WLet(Workdir, GetFolderName(MainFile))
	Else
		WLet(Workdir, *CommandPromptFolder)
	End If
		cmd = Environ("COMSPEC") & " /K cd /D """ & *Workdir & """"
		Dim As Integer iClass
		Dim SInfo As STARTUPINFO
		Dim PInfo As PROCESS_INFORMATION
		WLet(CmdL, cmd)
		SInfo.cb = Len(SInfo)
		SInfo.dwFlags = STARTF_USESHOWWINDOW
		SInfo.wShowWindow = SW_NORMAL
		iClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
		If CreateProcessW(NULL, CmdL, ByVal NULL, ByVal NULL, False, iClass, NULL, Workdir, @SInfo, @PInfo) Then
			CloseHandle(PInfo.hProcess)
			CloseHandle(PInfo.hThread)
		End If
		If CmdL Then _Deallocate( CmdL)
	If Workdir Then _Deallocate( Workdir)
End Sub

Sub FindInFiles
	ThreadCounter(ThreadCreate_(@FindSub))
End Sub
Sub ReplaceInFiles
	ThreadCounter(ThreadCreate_(@ReplaceSub))
End Sub

Sub mClickMRU(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
	Select Case Sender.ToString
	Case "ClearFiles"
		miRecentFiles->Clear
		miRecentFiles->Enabled = False
		MRUFiles.Clear
	Case Else
		OpenFiles GetFullPath(Sender.ToString)
	End Select
End Sub

Sub mClickHelp(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	HelpOption.CurrentPath = Cast(MenuItem Ptr, @Sender)->ImageKey
	HelpOption.CurrentWord = ""
	ThreadCounter(ThreadCreate_(@RunHelp, @HelpOption))
End Sub

Sub mClickTool(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As UserToolType Ptr tt = mi->Tag
	If tt <> 0 Then tt->Execute
End Sub

Sub mClickWindow(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As TabWindow Ptr tb = mi->Tag
	If tb <> 0 Then tb->SelectTab
End Sub

Sub SelectNextControl
	Select Case frmMain.ActiveControl
	Case @txtExplorer: tvExplorer.SetFocus
	Case @tvExplorer: txtExplorer.SetFocus
	Case @txtForm: tvToolBox.SetFocus
	Case @tvToolBox: txtForm.SetFocus
	Case @txtProperties: lvProperties.SetFocus
	Case @lvProperties: txtProperties.SetFocus
	Case @txtEvents: lvEvents.SetFocus
	Case @lvEvents: txtEvents.SetFocus
	End Select
End Sub

Sub DispatchDesignerCommand(des As Designer Ptr, Cmd As String)
	Select Case Cmd
	Case "Cut":                         des->CutControl
	Case "Copy":                        des->CopyControl
	Case "Paste":                       des->PasteControl
	Case "Delete":                      des->DeleteControl
	Case "Duplicate":                   des->DuplicateControl
	Case "SelectAll":                   des->SelectAllControls
	Case "Indent":                      des->SelectNextControl
	Case "Outdent":                     des->SelectNextControl - 1
	Case "AlignLefts":                  des->AlignLefts
	Case "AlignCenters":                des->AlignCenters
	Case "AlignRights":                 des->AlignRights
	Case "AlignTops":                   des->AlignTops
	Case "AlignMiddles":                des->AlignMiddles
	Case "AlignBottoms":                des->AlignBottoms
	Case "AlignToGrid":                 des->AlignToGrid
	Case "MakeSameSizeWidth":           des->MakeSameSizeWidth
	Case "MakeSameSizeHeight":          des->MakeSameSizeHeight
	Case "MakeSameSizeBoth":            des->MakeSameSizeBoth
	Case "SizeToGrid":                  des->SizeToGrid
	Case "HorizontalSpacingMakeEqual":  des->HorizontalSpacingMakeEqual
	Case "HorizontalSpacingIncrease":   des->HorizontalSpacingIncrease
	Case "HorizontalSpacingDecrease":   des->HorizontalSpacingDecrease
	Case "HorizontalSpacingRemove":     des->HorizontalSpacingRemove
	Case "VerticalSpacingMakeEqual":    des->VerticalSpacingMakeEqual
	Case "VerticalSpacingIncrease":     des->VerticalSpacingIncrease
	Case "VerticalSpacingDecrease":     des->VerticalSpacingDecrease
	Case "VerticalSpacingRemove":       des->VerticalSpacingRemove
	Case "CenterInParentHorizontally":  des->CenterInParentHorizontally
	Case "CenterInParentVertically":    des->CenterInParentVertically
	Case "SendToBack":                  des->SendToBack
	Case "BringToFront":                des->BringToFront
	End Select
End Sub

Sub ClearThreadsWindow
	lvThreads.Nodes.Clear
	tpThreads->Caption = ("Threads")
End Sub

Sub mClick(ByRef Designer_ As My.Sys.Object, Sender As My.Sys.Object)
	Select Case Sender.ToString
	Case "NewProject":                          NewProject
	Case "OpenProject":                         OpenProject
	Case "RecentProject":                       OpenRecentProject
	Case "DeleteProject":                       DeleteProject
	Case "OpenFolder":                          OpenFolder
	Case "SaveProject":                         SaveProject ptvExplorer->SelectedNode
	Case "SaveProjectAs":                       SaveProject ptvExplorer->SelectedNode, True
	Case "CloseProject":                        CloseProject GetParentNode(ptvExplorer->SelectedNode)
	Case "NewFile":                             NewFile
	Case "OpenFile":                            OpenEditorFile
	Case "CloseFile":                           CloseEditorFile
	Case "DeleteFile":                          DeleteEditorFile
	Case "SaveFile":                            SaveEditorFile
	Case "SaveFileAs":                          SaveEditorFileAs
	Case "New":                                 NewFile
	Case "Open":                                OpenEditorFile
	Case "Save":                                SaveEditorFile
	Case "Print":                               PrintThis
	Case "PrintPreview":                        PrintPreview
	Case "PageSetup":                           PageSetup
	Case "CommandPrompt":                       ThreadCounter(ThreadCreate_(@RunCmd))
	Case "AddFromTemplates":                    AddFromTemplates
	Case "AddFilesToProject":                   AddFilesToProject
	Case "Rename":                              RenameFile
	Case "CancelFileDeletion":                  CancelFileDeletion
	Case "OpenProjectFolder":                   OpenProjectFolder
	Case "ProjectProperties":                   pfProjectProperties->ShowModal *pfrmMain : pfProjectProperties->CenterToParent
	Case "SetAsMain":                           SetAsMain @Sender = miTabSetAsMain
	Case "ClearStartUp":                        SetMainNode 0
	Case "ReloadHistoryCode":                   ReloadHistoryCode
	Case "ProblemsCopy":                        If lvProblems.ListItems.Count < 1 Then Return Else Clipboard.SetAsText lvProblems.SelectedItem->Text(0)
	Case "ProblemsCopyAll":
		Dim As WString Ptr tmpStrPtr
		If lvProblems.ListItems.Count < 1 Then Return
		For j As Integer = 0 To lvProblems.ListItems.Count - 1
			WAdd(tmpStrPtr, !"\r\n" & lvProblems.ListItems.Item(j)->Text(0))
		Next
		Clipboard.SetAsText *tmpStrPtr
		_Deallocate(tmpStrPtr)
	Case "UseDirect2D":                         frmMain.UpdateLock: UseDirect2D = tbtUseDirect2D->Checked: UpdateAllTabWindows: frmMain.Repaint: frmMain.UpdateUnLock
	Case "ProjectExplorer":                     tpProject->SelectTab: txtExplorer.SetFocus
	Case "PropertiesWindow":                    tpProperties->SelectTab: txtProperties.SetFocus
	Case "EventsWindow":                        tpEvents->SelectTab: txtEvents.SetFocus
	Case "Toolbox":                             tpToolbox->SelectTab: txtForm.SetFocus
	Case "OutputWindow":                        tpOutput->SelectTab
	Case "ProblemsWindow":                      tpProblems->SelectTab
	Case "SuggestionsWindow":                   tpSuggestions->SelectTab
	Case "FindWindow":                          tpFind->SelectTab
	Case "ToDoWindow":                          tpToDo->SelectTab
	Case "ChangeLogWindow":                     tpChangeLog->SelectTab
	Case "ImmediateWindow":                     tpImmediate->SelectTab
	Case "LocalsWindow":                        tpLocals->SelectTab
	Case "GlobalsWindow":                       tpGlobals->SelectTab
		'Case "ProceduresWindow":                    tpProcedures->SelectTab
	Case "ThreadsWindow":                       tpThreads->SelectTab
	Case "WatchWindow":                         tpWatches->SelectTab
	Case "ImageManager":                        pfImageManager->Show *pfrmMain : pfImageManager->CenterToParent
	Case "Toolbars":                            'ShowMainToolbar = Not ShowMainToolbar: ReBar1.Visible = ShowMainToolbar: pfrmMain->RequestAlign
	Case "Standard":                            ShowStandardToolBar = Not ShowStandardToolBar: MainReBar.Bands.Item(0)->Visible = ShowStandardToolBar: mnuStandardToolBar->Checked = ShowStandardToolBar: pfrmMain->RequestAlign
	Case "Edit":                                ShowEditToolBar = Not ShowEditToolBar: MainReBar.Bands.Item(1)->Visible = ShowEditToolBar: mnuEditToolBar->Checked = ShowEditToolBar: pfrmMain->RequestAlign
	Case "Project":                             ShowProjectToolBar = Not ShowProjectToolBar: MainReBar.Bands.Item(2)->Visible = ShowProjectToolBar: mnuProjectToolBar->Checked = ShowProjectToolBar: pfrmMain->RequestAlign
	'' 13.3.A O3: Build/Debug toolbars folded into Run; bands are now Standard(0), Edit(1),
	'' Project(2), Run(3), Format(4).
	Case "Run":                                 ShowRunToolBar = Not ShowRunToolBar: MainReBar.Bands.Item(3)->Visible = ShowRunToolBar: mnuRunToolBar->Checked = ShowRunToolBar: pfrmMain->RequestAlign
	Case "FormFormat":                          ShowFormatToolBar = Not ShowFormatToolBar: MainReBar.Bands.Item(4)->Visible = ShowFormatToolBar: mnuFormatToolBar->Checked = ShowFormatToolBar: pfrmMain->RequestAlign
	Case "TBUseDebugger":                       ChangeUseDebugger tbtUseDebugger->Checked, 0
	Case "UseDebugger":                         ChangeUseDebugger Not UseDebugger, 1
	Case "UseProfiler":                         If UseDebugger Then ChangeUseProfiler Not mnuUseProfiler->Checked, 1
	Case "ClearAllBreakpoints":                 ClearAllBreakpoints
	Case "ShowWithFolders":                     ChangeFolderType ProjectFolderTypes.ShowWithFolders
	Case "ShowWithoutFolders":                  ChangeFolderType ProjectFolderTypes.ShowWithoutFolders
	Case "ShowAsFolder":                        ChangeFolderType ProjectFolderTypes.ShowAsFolder
	Case "SyntaxCheck":                         If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@SyntaxCheck))
	Case "CompileAll":                          If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileAll))
	Case "Compile":                             If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileProgram))
	Case "Make":                                If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@MakeExecute))
	Case "MakeClean":                           If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@MakeClean))
	Case "Suggestions":                         ChangeShowSymbolsTooltipsOnMouseHover Not GlobalSettings.ShowSymbolsTooltipsOnMouseHover, 1
	Case "SuggestOptions":                      ChangeAutoComplete Not AutoComplete, 1
	Case "ParameterInfo"
		If (GetKeyState(VK_CONTROL) And 8000) <> 0 Then
			If ParameterInfoShow Then ParameterInfo 0
		Else
			ChangeParameterInfo Not ParameterInfoShow, 1
		End If
	Case "InvokeParameterInfo":                 If ParameterInfoShow Then ParameterInfo 0
	Case "AnalyzeSuggestions":                  Suggestions
	Case "FormatProject":                       ThreadCounter(ThreadCreate_(@FormatProject)) 'FormatProject 0
	Case "UnformatProject":                     ThreadCounter(ThreadCreate_(@FormatProject, Cast(Any Ptr, 1))) 'FormatProject Cast(Any Ptr, 1)
	Case "Parameters":                          pfParameters->ShowModal *pfrmMain : pfParameters->CenterToParent
	Case "GDBCommand":                          GDBCommand
	Case "StartWithCompile"
		ClearThreadsWindow
		If SaveAllBeforeCompile Then
			ChangeEnabledDebug False, True, True
			If iFlagStartDebug = 0 Then
				If UseDebugger Then
					runtype = RTFRUN
					CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
					ThreadCounter(ThreadCreate_(@StartDebuggingWithCompile))
				Else
					ThreadCounter(ThreadCreate_(@CompileAndRun))
				End If
			Else
				continue_debug()
			End If
		End If
	Case "Start", "Continue"
		ClearThreadsWindow
		If iFlagStartDebug = 0 Then
			If UseDebugger Then
				runtype= RTFRUN
				CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
				ThreadCounter(ThreadCreate_(@StartDebugging))
			Else
				ThreadCounter(ThreadCreate_(@RunProgram))
			End If
		Else
			ChangeEnabledDebug False, True, True
			continue_debug()
		End If
	Case "Break":
		If iFlagStartDebug = 1 Then
			break_debug()
		End If
	Case "End":
		If Running Then
			kill_debug()
		Else
			command_debug "q"
		End If
		ClearDebugPanels
	Case "Restart"
		ClearThreadsWindow
		command_debug("r")
	Case "StepInto":
		ClearThreadsWindow
		If iFlagStartDebug = 0 Then
			runtype = RTSTEP
			CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
			ThreadCounter(ThreadCreate_(@StartDebugging))
		Else
			step_debug("s")
		End If
	Case "StepOver":
		ClearThreadsWindow
		If iFlagStartDebug = 0 Then
			CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
			ThreadCounter(ThreadCreate_(@StartDebugging))
		Else
			step_debug("n")
		End If
	Case "SaveAs", "Close", "CloseFile", "SyntaxCheck", "Compile", "CompileAndRun", "Run", "RunToCursor", "SplitHorizontally", "SplitVertically", _
		"Start", "Stop", "StepOut", "FindNext", "FindPrev", "Goto", "SetNextStatement", "SplitLines", "CombineLines", "SortLines", "DeleteBlankLines", "FormatWithBasisWord", "ConvertFromHexStrUnicode", "ConvertToHexStrUnicode", "ConvertToUppercaseFirstLetter", "ConvertToLowercase", "ConvertToUppercase", "SplitUp", "SplitDown", "SplitLeft", "SplitRight", _
		"AddWatch", "NextBookmark", "PreviousBookmark", "ClearAllBookmarks", "Code", "Form", "CodeAndForm", "GotoCodeForm", "AddProcedure", "AddType"
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Select Case Sender.ToString
		Case "Save":                        SaveEditorFile
		Case "SaveAs":                      SaveEditorFileAs
		Case "Close", "CloseFile":          CloseEditorFile
		Case "SplitLines":                  tb->SplitLines
		Case "CombineLines":                tb->CombineLines
		Case "SortLines":                   tb->SortLines
		Case "DeleteBlankLines":            tb->DeleteBlankLines
		Case "FormatWithBasisWord" :        tb->FormatWithBasisWord
		Case "ConvertToLowercase":          tb->ConvertToLowercase
		Case "ConvertToUppercase":          tb->ConvertToUppercase
		Case "ConvertToHexStrUnicode":          tb->ConvertToHexStrUnicode
		Case "ConvertFromHexStrUnicode":          tb->ConvertFromHexStrUnicode
		Case "ConvertToUppercaseFirstLetter": tb->ConvertToUppercaseFirstLetter
		Case "SplitHorizontally":           tb->txtCode.SplittedHorizontally = Not mnuSplitHorizontally->Checked
		Case "SplitVertically":             tb->txtCode.SplittedVertically = Not mnuSplitVertically->Checked
		Case "SplitUp", "SplitDown", "SplitLeft", "SplitRight":
			Var ptabCode = Cast(TabControl Ptr, mnuTabs.ParentWindow)
			Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			Var tp = Cast(TabPanel Ptr, tb->Parent->Parent)
			Var ptabPanelNew = _New(TabPanel)
			Var bUpDown = False
			Select Case Sender.ToString
			Case "SplitUp"
				ptabPanelNew->Align = DockStyle.alTop
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alTop
				bUpDown = True
			Case "SplitDown"
				ptabPanelNew->Align = DockStyle.alBottom
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alBottom
				bUpDown = True
			Case "SplitLeft"
				ptabPanelNew->Align = DockStyle.alLeft
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alLeft
			Case "SplitRight"
				ptabPanelNew->Align = DockStyle.alRight
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alRight
			End Select
			Var ptabPanel = Cast(TabPanel Ptr, tb->Parent->Parent)
			Var Idx = tp->IndexOf(tb->Parent)
			tp->Add ptabPanelNew, Idx
			tp->Add @ptabPanelNew->splGroup, Idx + 1
			Var SplitterCount = 0 'Fix(tp->ControlCount / 2)
			For i As Integer = 1 To tp->ControlCount - 2 Step 2
				If bUpDown Then
					If tp->Controls[i]->Align = DockStyle.alTop OrElse tp->Controls[i]->Align = DockStyle.alBottom Then SplitterCount += 1
				Else
					If tp->Controls[i]->Align = DockStyle.alLeft OrElse tp->Controls[i]->Align = DockStyle.alRight Then SplitterCount += 1
				End If
			Next
			For i As Integer = 0 To tp->ControlCount - 2 Step 2
				If bUpDown Then
					tp->Controls[i]->Height = (tp->Height - ptabPanelNew->splGroup.Height * SplitterCount) / (SplitterCount + 1)
				Else
					tp->Controls[i]->Width = (tp->Width - ptabPanelNew->splGroup.Width * SplitterCount) / (SplitterCount + 1)
				End If
			Next
			'ptabPanel->tabCode.DeleteTab tb
			tb->Parent = @ptabPanelNew->tabCode
				tb->ImageKey = tb->ImageKey
				ptabPanelNew->tabCode.Add @tb->btnClose
				tp->RequestAlign
			ptabCode = @ptabPanelNew->tabCode
			TabPanels.Add ptabPanelNew
		Case "SetNextStatement":
			ClearThreadsWindow
			Dim As Integer iStartLine, iEndLine, iStartChar, iEndChar
			tb->txtCode.GetSelection iStartLine, iEndLine, iStartChar, iEndChar
			command_debug("jump " & Replace(tb->FileName, "\", "/") & ":" & Str(iEndLine))
		Case "StepOut":
			ClearThreadsWindow
			If iFlagStartDebug = 0 Then
				ThreadCounter(ThreadCreate_(@StartDebugging))
			Else
				step_debug("finish")
			End If
		Case "RunToCursor":
			ClearThreadsWindow
			If iFlagStartDebug = 1 Then
				ChangeEnabledDebug False, True, True
				set_bp True
				continue_debug
			Else
				RunningToCursor = True
				CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
				ThreadCounter(ThreadCreate_(@StartDebugging))
			End If
		Case "AddWatch":
			If tb->txtCode.SelText <> "" Then lvWatches.Nodes.Add(tb->txtCode.SelText)
		Case "FindNext":                    pfFind->Find(True)
		Case "FindPrev":                    pfFind->Find(False)
		Case "Goto":                        pfGoto->Show *pfrmMain : pfGoto->CenterToParent
		Case "NextBookmark":                NextBookmark 1
		Case "PreviousBookmark":            NextBookmark -1
		Case "ClearAllBookmarks":           ClearAllBookmarks
		Case "Code":                        tb->ShowView("Code")
		Case "Form":                        tb->ShowView("Form")
		Case "CodeAndForm":                 tb->ShowView("CodeAndForm")
		Case "GotoCodeForm":
			If tb->txtCode.Focused Then
				If tb->CurrentView() = "Code" Then tb->ShowView(tb->LastButton)
				If tb->Des Then DesignerChangeSelection(*tb->Des, tb->Des->SelectedControl)
			Else
				If tb->CurrentView() = "Form" Then tb->ShowView("Code")
				Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				tb->txtCode.SetFocus
				OnLineChangeEdit *tb->txtCode.Designer, tb->txtCode, iSelEndLine, iSelEndLine
			End If
		Case "AddProcedure":                frmAddProcedure.ShowModal frmMain
		Case "AddType":                     frmAddType.ShowModal frmMain
		End Select
	Case "SaveAll":                         SaveAll
	Case "CloseAll":                        CloseAllTabs
	Case "CloseAllWithoutCurrent":          CloseAllTabs(True)
	Case "Exit":                            pfrmMain->CloseForm
	Case "Find":                            pfFind->mFormFind = True: pfFind->Show *pfrmMain
	Case "FindInFiles":                     mFormFindInFile = True:  pfFindFile->Show *pfrmMain : pfFindFile->CenterToParent
	Case "ReplaceInFiles":                  mFormFindInFile = False:  pfFindFile->Show *pfrmMain : pfFindFile->CenterToParent
	Case "Replace":                         pfFind->mFormFind = False: pfFind->Show *pfrmMain
	Case "PinLeft":
		Dim pinLeftBtn As ToolButton Ptr = tbLeft.Buttons.Item("PinLeft")
		If pinLeftBtn = 0 Then Exit Select
		' Checked toggles before OnClick. When expanded, one click collapses to the tab strip.
		' (Mirrors "PinRight"/"PinBottom" — relying on frmMain_ActiveControlChanged to collapse
		' later isn't reliable whenever the click itself doesn't shift focus somewhere outside
		' tabLeft/pnlLeftPin, e.g. while working in a form Designer.)
		If splLeft.Visible Then
			If pinLeftBtn->Checked Then pinLeftBtn->Checked = False
			SetLeftClosedStyle True, True
		ElseIf pinLeftBtn->Checked Then
			SetLeftClosedStyle False, False
		Else
			SetLeftClosedStyle True, False
		End If
	Case "PinRight":
		Dim pinRightBtn As ToolButton Ptr = tbRight.Buttons.Item("PinRight")
		If pinRightBtn = 0 Then Exit Select
		' Checked toggles before OnClick. When expanded, one click collapses to the tab strip.
		' (Mirrors "PinBottom" below — relying on frmMain_ActiveControlChanged to collapse
		' later doesn't work here because that handler skips the right panel while focus is
		' inside a form Designer, which is the common case when the right panel is in use.)
		If splRight.Visible Then
			If pinRightBtn->Checked Then pinRightBtn->Checked = False
			SetRightClosedStyle True, True
		ElseIf pinRightBtn->Checked Then
			SetRightClosedStyle False, False
		Else
			SetRightClosedStyle True, False
		End If
	Case "PinBottom":
		Dim pinBtn As ToolButton Ptr = tbBottom.Buttons.Item("PinBottom")
		If pinBtn = 0 Then Exit Select
		' Checked toggles before OnClick. When expanded, one click collapses to the tab strip.
		If splBottom.Visible Then
			If pinBtn->Checked Then pinBtn->Checked = False
			SetBottomClosedStyle True, True
		ElseIf pinBtn->Checked Then
			SetBottomClosedStyle False, False
		Else
			SetBottomClosedStyle True, False
		End If
	Case "EraseOutputWindow":               txtOutput.Text = ""
	Case "EraseImmediateWindow":            txtImmediate.Text = ""
	Case "Update":
			iStateMenu = IIf(tbBottom.Buttons.Item("Update")->Checked, 2, 1): If Running = False Then command_debug("")
	Case "AddForm":                         AddFromTemplate ExePath + "/Templates/Files/Form.frm"
	Case "AddModule":                       AddFromTemplate ExePath + "/Templates/Files/Module.bas"
	Case "AddIncludeFile":                  AddFromTemplate ExePath + "/Templates/Files/Include File.bi"
	Case "AddUserControl":                  AddFromTemplate ExePath + "/Templates/Files/User Control.bas"
	Case "AddResource":                     AddFromTemplate ExePath + "/Templates/Files/Resource.rc"
	Case "AddManifest":                     AddFromTemplate ExePath + "/Templates/Files/Manifest.xml"
	Case "Undo", "Redo", "CutCurrentLine", "Cut", "Copy", "Paste", "SelectAll", "Duplicate", "SingleComment", "UnComment", _
		"Indent", "Outdent", "Format", "Unformat", "AddSpaces", "Breakpoint", "ToggleBookmark", "CollapseAll", "UnCollapseAll", "CollapseAllProcedures", "UnCollapseAllProcedures", _
		"CollapseCurrent", "UnCollapseCurrent", "CompleteWord", "Define", _
		"AlignLefts", "AlignCenters", "AlignRights", "AlignTops", "AlignMiddles", "AlignBottoms", "AlignToGrid", "MakeSameSizeWidth", "MakeSameSizeHeight", "MakeSameSizeBoth", "SizeToGrid", _
		"HorizontalSpacingMakeEqual", "HorizontalSpacingIncrease", "HorizontalSpacingDecrease", "HorizontalSpacingRemove", "VerticalSpacingMakeEqual", "VerticalSpacingIncrease", "VerticalSpacingDecrease", _
		"VerticalSpacingRemove", "CenterInParentHorizontally", "CenterInParentVertically", "SendToBack", "BringToFront", "LockControls", "TBLockControls"
		If Sender.ToString = "LockControls" OrElse Sender.ToString = "TBLockControls" Then
			Select Case Sender.ToString
			Case "TBLockControls": ChangeLockControls tbtLockControls->Checked, 0
			Case "LockControls": ChangeLockControls Not miLockControls->Checked, 1
			End Select
			If ptabCode <> 0 Then
				Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
				If tb <> 0 Then
					Dim des As Designer Ptr = tb->Des
					If des <> 0 Then
						des->LockControls = miLockControls->Checked
						des->Parent->Repaint
					End If
				End If
			End If
		End If
		Dim As Form Ptr ActiveForm = Cast(Form Ptr, pApp->ActiveForm)
		If ActiveForm = 0 Then Exit Sub
		If ActiveForm->ActiveControl = 0 Then
			Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			If tb <> 0 AndAlso tb->cboClass.ItemIndex > 0 Then
				Dim des As Designer Ptr = tb->Des
				If des = 0 Then Exit Sub
				DispatchDesignerCommand(des, Sender.ToString)
			End If
			Exit Sub
		End If
		Select Case Sender.ToString
		Case "Indent", "Outdent":           SelectNextControl
		End Select
		If ActiveForm->ActiveControl->ClassName <> "EditControl" AndAlso ActiveForm->ActiveControl->ClassName <> "TextBox" AndAlso ActiveForm->ActiveControl->ClassName <> "RichTextBox" AndAlso ActiveForm->ActiveControl->ClassName <> "Panel" AndAlso ActiveForm->ActiveControl->ClassName <> "ComboBoxEdit" AndAlso ActiveForm->ActiveControl->ClassName <> "ComboBoxEx" Then Exit Sub
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If ActiveForm->ActiveControl->ClassName = "TextBox" OrElse ActiveForm->ActiveControl->ClassName = "RichTextBox" Then
			Dim txt As TextBox Ptr = Cast(TextBox Ptr, pfrmMain->ActiveControl)
			Select Case Sender.ToString
			Case "Undo":                            txt->Undo
			Case "Cut":                             txt->CutToClipboard
			Case "Copy":                            txt->CopyToClipboard
			Case "Paste":                           txt->PasteFromClipboard
			Case "SelectAll":                       txt->SelectAll
			End Select
		ElseIf ActiveForm->ActiveControl->ClassName = "ComboBoxEdit" OrElse ActiveForm->ActiveControl->ClassName = "ComboBoxEx" Then
			Dim cbo As ComboBoxEdit Ptr = Cast(ComboBoxEdit Ptr, ActiveForm->ActiveControl)
			Select Case Sender.ToString
			Case "Undo":                            cbo->Undo
			Case "Cut":                             cbo->CutToClipboard
			Case "Copy":                            cbo->CopyToClipboard
			Case "Paste":                           cbo->PasteFromClipboard
			Case "SelectAll":                       cbo->SelectAll
			End Select
		ElseIf tb <> 0 Then
			If tb->cboClass.ItemIndex > 0 Then
				Dim des As Designer Ptr = tb->Des
				If des = 0 Then Exit Sub
				DispatchDesignerCommand(des, Sender.ToString)
			ElseIf ActiveForm->ActiveControl->ClassName = "EditControl" OrElse ActiveForm->ActiveControl->ClassName = "Panel" Then
				Dim ec As EditControl Ptr = @tb->txtCode
				Select Case Sender.ToString
				Case "Redo":                        ec->Redo
				Case "Undo":                        ec->Undo
				Case "CutCurrentLine":              ec->CutCurrentLineToClipboard
				Case "Cut":                         ec->CutToClipboard
				Case "Copy":                        ec->CopyToClipboard
				Case "Paste":                       ec->PasteFromClipboard
				Case "Duplicate":                   ec->DuplicateLine
				Case "SelectAll":                   ec->SelectAll
				Case "SingleComment":               ec->ToggleComment
				Case "UnComment":                   ec->UnComment
				Case "Indent":                      ec->Indent
				Case "Outdent":                     ec->Outdent
				Case "Format":                      ec->FormatCode
				Case "Unformat":                    ec->UnformatCode
				Case "AddSpaces":                   tb->AddSpaces
				Case "Breakpoint":
					If iFlagStartDebug = 1 Then
						set_bp
					End If
					ec->Breakpoint
				Case "CollapseAll":                 ec->CollapseAll
				Case "UnCollapseAll":               ec->UnCollapseAll
				Case "CollapseAllProcedures":       ec->CollapseAllProcedures
				Case "UnCollapseAllProcedures":     ec->UnCollapseAllProcedures
				Case "CollapseCurrent":             ec->CollapseCurrent
				Case "UnCollapseCurrent":           ec->UnCollapseCurrent
				Case "CompleteWord":                CompleteWord
				Case "ToggleBookmark":              ec->Bookmark
				Case "Define":                      tb->Define
				End Select
			End If
		End If
	Case "Options":                         pfOptions->Show *pfrmMain : pfOptions->CenterToParent
	Case "AddIns":                          pfAddIns->Show *pfrmMain : pfAddIns->CenterToParent
	Case "Tools":                           pfTools->Show *pfrmMain : pfTools->CenterToParent
	Case "Content":                         ThreadCounter(ThreadCreate_(@RunHelp))
	Case "FreeBasicForums":                 OpenUrl "https://www.freebasic.net/forum/index.php"
	Case "FreeBasicWiKi":                   OpenUrl "https://www.freebasic.net/wiki/wikka.php?wakka=PageIndex"
	Case "About":                           pfAbout->Show *pfrmMain : pfAbout->CenterToParent
	Case "TipoftheDay":                     pfTipOfDay->ShowModal *pfrmMain : pfTipOfDay->CenterToParent
	End Select
End Sub

pApp->MainForm = @frmMain
pApp->Run

End
AA:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "


