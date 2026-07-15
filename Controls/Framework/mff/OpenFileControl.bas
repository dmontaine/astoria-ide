'###############################################################################
'#  Dialogs.bi                                                                 #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   Dialogs.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "OpenFileControl.bi"

Namespace My.Sys.Forms
		Private Function OpenFileControl.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "defaultext": Return FDefaultExt
			Case "filename": WLet(FFileName, FileName): Return FFileName
			Case "filetitle": WLet(FFileTitle, FileTitle): Return FFileTitle
			Case "filter": Return FFilter
			Case "initialdir": WLet(FInitialDir, InitialDir): Return FInitialDir
			Case "multiselect": Return @FMultiSelect
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function OpenFileControl.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "defaultext": DefaultExt = QWString(Value)
			Case "filename": FileName = QWString(Value)
			Case "filetitle": FileTitle = QWString(Value)
			Case "filter": Filter = QWString(Value)
			Case "initialdir": InitialDir = QWString(Value)
			Case "multiselect": MultiSelect = QBoolean(Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property OpenFileControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property OpenFileControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property OpenFileControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property OpenFileControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property OpenFileControl.MultiSelect As Boolean
		Return FMultiSelect
	End Property
	
	Private Property OpenFileControl.MultiSelect(Value As Boolean)
		FMultiSelect = Value
		If Value Then
			Options.Include ofAllowMultiSelect
		Else
			Options.Exclude ofAllowMultiSelect
		End If
	End Property
	
	Private Property OpenFileControl.InitialDir ByRef As WString
		If FHandle Then
				Dim As Integer iSize = 1024
				Dim As WString * 1024 Path
				If SendMessage(FHandle, CDM_GETFOLDERPATH, iSize, Cast(WPARAM, @Path)) > 0 Then
					WLet(FInitialDir, Path)
				End If
		End If
		If FInitialDir > 0 Then Return *FInitialDir Else Return WStr("")
	End Property
	
	Private Property OpenFileControl.InitialDir(ByRef Value As WString)
		FInitialDir    = _Reallocate(FInitialDir, (Len(Value) + 1) * SizeOf(WString))
		*FInitialDir = Value
	End Property
	
	Private Property OpenFileControl.DefaultExt ByRef As WString
		If FDefaultExt > 0 Then Return *FDefaultExt Else Return WStr("")
	End Property
	
	Private Property OpenFileControl.DefaultExt(ByRef Value As WString)
		FDefaultExt    = _Reallocate(FDefaultExt, (Len(Value) + 1) * SizeOf(WString))
		*FDefaultExt = Value
			SendMessage(FHandle, CDM_SETDEFEXT, 0, Cast(LPARAM, FDefaultExt))
	End Property
	
	Private Property OpenFileControl.FileName ByRef As WString
		If FHandle Then
				Dim As Integer iSize = 1024
				Dim As WString * 1024 Path
				If SendMessage(FHandle, CDM_GETFILEPATH, iSize, Cast(WPARAM, @Path)) > 0 Then
					WLet(FFileName, Path)
				End If
		End If
		If FFileName > 0 Then Return *FFileName Else Return WStr("")
	End Property
	
	Private Property OpenFileControl.FileName(ByRef Value As WString)
		WLet(FFileName, Value)
	End Property
	
	Private Property OpenFileControl.FileTitle ByRef As WString
		If FHandle Then
			FileName
				Dim As Integer iSize = 1024
				Dim As WString * 1024 Path
				If SendMessage(FHandle, CDM_GETSPEC, iSize, Cast(WPARAM, @Path)) > 0 Then
					WLet(FFileTitle, Path)
				End If
		End If
		If FFileTitle > 0 Then Return *FFileTitle Else Return WStr("")
	End Property
	
	Private Property OpenFileControl.FileTitle(ByRef Value As WString)
		WLet(FFileTitle, Value)
		FileName = InitialDir & "/" & *FFileTitle
	End Property
	
	Private Property OpenFileControl.Filter ByRef As WString
		If FFilter > 0 Then Return *FFilter Else Return WStr("")
	End Property
	
	Private Property OpenFileControl.Filter(ByRef Value As WString)
		FFilter    = _Reallocate(FFilter, (Len(Value) + 1) * SizeOf(WString))
		*FFilter = Value
	End Property
	
	Private Property OpenFileControl.FilterIndex As Integer
		Return FFilterIndex
	End Property
	
	Private Property OpenFileControl.FilterIndex(Value As Integer)
		FFilterIndex    = Value
	End Property
	
		Function OpenFileControl.HookListView(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			Select Case uMsg
			Case WM_NOTIFY
				If (Cast(LPNMHDR, lParam)->code = NM_CUSTOMDRAW) Then
					Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, lParam)
					Select Case nmcd->dwDrawStage
					Case CDDS_PREPAINT
						Return CDRF_NOTIFYITEMDRAW
					Case CDDS_ITEMPREPAINT
						Return CDRF_DODEFAULT
					End Select
				End If
			End Select
			Return CallWindowProc(GetProp(hDlg, "@@@@Proc"), hDlg, uMsg, wParam, lParam)
		End Function
		
		Function OpenFileControl.HookListViewParent(hDlg As HWND, uMsg As UINT, wParam1 As WPARAM, lParam1 As LPARAM) As LRESULT
			Select Case uMsg
			Case WM_NOTIFY
			End Select
			Return CallWindowProc(GetProp(hDlg, "@@@@Proc"), hDlg, uMsg, wParam1, lParam1)
		End Function
		
		Function OpenFileControl.HookChildProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			Dim As OpenFileControl Ptr OpenDial = Cast(OpenFileControl Ptr, GetWindowLongPtr(hDlg, GWLP_USERDATA))
			Select Case uMsg
			Case WM_PAINT
				If OpenDial Then
					If Not OpenDial->FFirstShowed Then
						OpenDial->FFirstShowed = True
						MoveWindow hDlg, OpenDial->ScaleX(OpenDial->FLeft), OpenDial->ScaleY(OpenDial->FTop), OpenDial->ScaleX(OpenDial->FWidth), OpenDial->ScaleY(OpenDial->FHeight), True
					End If
				End If
			Case WM_WINDOWPOSCHANGING
				If OpenDial Then
					If OpenDial->Constraints.Left <> 0 Then Cast(WINDOWPOS Ptr, lParam)->x  = OpenDial->ScaleX(OpenDial->Constraints.Left)
					If OpenDial->Constraints.Top <> 0 Then Cast(WINDOWPOS Ptr, lParam)->y  = OpenDial->ScaleY(OpenDial->Constraints.Top)
					If OpenDial->Constraints.Width <> 0 Then Cast(WINDOWPOS Ptr, lParam)->cx = OpenDial->ScaleX(OpenDial->Constraints.Width)
					If OpenDial->Constraints.Height <> 0 Then Cast(WINDOWPOS Ptr, lParam)->cy = OpenDial->ScaleY(OpenDial->Constraints.Height)
				End If
			Case WM_CHILDACTIVATE
				If OpenDial Then
					MoveWindow hDlg, OpenDial->FLeft, OpenDial->FTop, OpenDial->FWidth, OpenDial->FHeight, True
				End If
			Case WM_CTLCOLORMSGBOX To WM_CTLCOLORSTATIC, WM_CTLCOLORBTN, WM_CTLCOLOREDIT
'			Case WM_DRAWITEM
'				CallWindowProc(GetProp(hDlg, "@@@@Proc"), hDlg, uMsg, wParam, lParam)
'				Dim As DRAWITEMSTRUCT Ptr diStruct = Cast(DRAWITEMSTRUCT Ptr, lParam)
'				If diStruct->itemID = -1 Then Return 0
'				Dim As Integer ItemID, State
'				Dim As ..Rect R
'				Dim As HDC Dc
'    			Dim As HBITMAP hbmIcon = Cast(HBITMAP, diStruct->itemData)
'    			Dim As HBITMAP hbmMask
'    			#define CX_BITMAP 16
'				#define CY_BITMAP 16
'				ItemID = Cast(Integer, diStruct->itemID)
'				State = Cast(Integer, diStruct->itemState)
'				R = Cast(..Rect, diStruct->rcItem)
'				Dc = diStruct->hDC
'				If (diStruct->itemState And ODS_COMBOBOXEDIT) <> 0 Then State = State Or ODS_ComboBOXEDIT
'				If (diStruct->itemState And ODS_DEFAULT) <> 0 Then State = State Or ODS_DEFAULT
'				Dim As WString * 256 FItemText
'				'Var L = SendMessage(diStruct->hwndItem, CB_GETLBTEXTLEN, diStruct->itemID, 0)
'				'WReallocate(FItemText, L)
'				SendMessage(diStruct->hwndItem, CB_GETLBTEXT, diStruct->itemID, CInt(@FItemText))
'				?diStruct->itemData
''				Dim As COMBOBOXINFO cbi
''				cbi.cbSize = SizeOf(COMBOBOXINFO)
''				Dim As BOOL result = GetComboBoxInfo(diStruct->hwndItem, @cbi)
''				If result Then
''					If cbi.hwndList Then
''						Dim As Integer L
''						Dim As WString Ptr FText
''						L = SendMessage(cbi.hwndList, LB_GETTEXTLEN, diStruct->itemID, 0)
''						WReallocate FText, L
''						WLet FText, Space(L)
''						SendMessage(cbi.hwndList, LB_GETTEXT, diStruct->itemID, CInt(@FText))
''						FItemText = *FText
''					End If
''				End If
'				?FItemText ', L
'				If (State And ODS_SELECTED) = ODS_SELECTED Then
'					'TextOut(Dc, R.Left + 2, R.Top, @FItemText, Len(FItemText))
'					'If (State And ODS_FOCUS) = ODS_FOCUS Then DrawFocusRect(DC, @R)
'				Else
'					'TextOut(Dc, R.Left + 2, R.Top, @FItemText, Len(FItemText))
'				End If
'				Dim As TEXTMETRIC tm
'				Dim As Integer x
'				Dim As Integer y
'				GetTextMetrics(diStruct->hDC, @tm)
'				y = (diStruct->rcItem.bottom + diStruct->rcItem.top - tm.tmHeight) / 2
'				x = LoWord(GetDialogBaseUnits()) / 4
'				
'				ExtTextOut(diStruct->hDC, CX_BITMAP + 2 * x, y, ETO_CLIPPED Or ETO_OPAQUE, @diStruct->rcItem, @FItemText, Len(FItemText), NULL)
'            
'				Dim As HDC hdc = CreateCompatibleDC(diStruct->hDC)
'				If hdc = NULL Then Return 0
'				
'				SelectObject(hdc, hbmMask)
'				BitBlt(diStruct->hDC, x, diStruct->rcItem.top + 1, CX_BITMAP, CY_BITMAP, hdc, 0, 0, SRCAND)
'				
'				SelectObject(hdc, hbmIcon)
'				BitBlt(diStruct->hDC, x, diStruct->rcItem.top + 1, CX_BITMAP, CY_BITMAP, hdc, 0, 0, SRCPAINT)
' 				
'				DeleteDC(hdc)
'				
'    			If (diStruct->itemState And ODS_FOCUS) Then DrawFocusRect(diStruct->hDC, @diStruct->rcItem)
'				
'				Return 0
			End Select
			Return CallWindowProc(GetProp(hDlg, "@@@@Proc"), hDlg, uMsg, wParam, lParam)
		End Function
		
		Function OpenFileControl.HookComboBoxParent(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			Return CallWindowProc(GetProp(hDlg, "@@@@Proc"), hDlg, uMsg, wParam, lParam)
		End Function
		
		Function OpenFileControl.EnumChildsProc(hDlg As HWND, lParam1 As LPARAM) As Boolean
			Select Case GetClassNameOf(hDlg)
			Case "ComboBox"
				SetWindowTheme(hDlg, NULL, NULL)
				Dim As COMBOBOXINFO cbi
				cbi.cbSize = SizeOf(COMBOBOXINFO)
				Dim As BOOL result = GetComboBoxInfo(hDlg, @cbi)
				If result Then
					If cbi.hwndList Then SetWindowTheme(cbi.hwndList, NULL, NULL)
				End If
				If GetWindowLongPtr(hDlg, GWLP_WNDPROC) <> @HookChildProc Then
					SetProp(hDlg, "@@@@Proc", Cast(WNDPROC, SetWindowLongPtr(hDlg, GWLP_WNDPROC, CInt(@HookChildProc))))
				End If
			Case "ToolbarWindow32"
				SetWindowTheme(hDlg, NULL, NULL)
			Case "SysHeader32"
				SetWindowTheme(hDlg, NULL, NULL)
			Case "SysListView32"
				ListView_SetTextColor(hDlg, GetSysColor(COLOR_WINDOWTEXT))
				ListView_SetTextBkColor(hDlg, GetSysColor(COLOR_WINDOW))
				ListView_SetBkColor(hDlg, GetSysColor(COLOR_WINDOW))
			Case Else
				SetWindowTheme(hDlg, NULL, NULL)
			End Select
			SendMessageW(hDlg, WM_THEMECHANGED, 0, 0)
			Return True
		End Function
		
		Function OpenFileControl.EnumListViewsProc(hDlg As HWND, lParam1 As LPARAM) As Boolean
			Select Case GetClassNameOf(hDlg)
			Case "SysListView32"
				Dim As HWND hHeader = ListView_GetHeader(hDlg)
				SetWindowTheme(hHeader, NULL, NULL)
				ListView_SetTextColor(hDlg, GetSysColor(COLOR_WINDOWTEXT)) 'Color1)
				ListView_SetTextBkColor(hDlg, GetSysColor(COLOR_WINDOW)) 'Color1)
				ListView_SetBkColor(hDlg, GetSysColor(COLOR_WINDOW)) 'Color1)
				If Cast(WNDPROC, GetWindowLongPtr(hDlg, GWLP_WNDPROC)) <> CInt(@HookListView) Then
					SetProp(hDlg, "@@@@Proc", Cast(WNDPROC, SetWindowLongPtr(hDlg, GWLP_WNDPROC, CInt(@HookListView))))
				End If
				If Cast(WNDPROC, GetWindowLongPtr(GetParent(hDlg), GWLP_WNDPROC)) <> CInt(@HookListViewParent) Then
					SetProp(GetParent(hDlg), "@@@@Proc", Cast(WNDPROC, SetWindowLongPtr(GetParent(hDlg), GWLP_WNDPROC, CInt(@HookListViewParent))))
				End If
				SendMessageW(hDlg, WM_THEMECHANGED, 0, 0)
			End Select
			Return True
		End Function
		
		Private Function OpenFileControl.Hook(FWindow As HWND, Msg As UINT, wParam As WPARAM, lParam As LPARAM) As UInteger
			Static As OpenFileControl Ptr OpenDial
			Select Case Msg
			Case WM_INITDIALOG
				OpenDial = Cast(OpenFileControl Ptr, Cast(LPOPENFILENAME, lParam)->lCustData)
				OpenDial->Handle = GetParent(FWindow)
				SetWindowLongPtr(FWindow, GWLP_USERDATA, CInt(OpenDial))
				If OpenDial->Parent = 0 OrElse OpenDial->Parent->Handle = 0 Then SendMessage(GetParent(FWindow), WM_SYSCOMMAND, SC_CLOSE, 0)
				Dim As HWND ModalWnd = GetParent(FWindow)
				'ShowWindow(ModalWnd, SW_HIDE)
				SetWindowLong(ModalWnd, GWL_STYLE, WS_CHILD Or DS_CONTROL)
				SetWindowLong(ModalWnd, GWL_EXSTYLE, WS_EX_CONTROLPARENT)
				SetParent ModalWnd, OpenDial->Parent->Handle
				ShowWindow(GetDlgItem(ModalWnd, IDOK), SW_HIDE)
				ShowWindow(GetDlgItem(ModalWnd, IDCANCEL), SW_HIDE)
				Dim As ..Rect R
				GetWindowRect GetDlgItem(ModalWnd, cmb13), @R
				MapWindowPoints 0, GetParent(GetDlgItem(ModalWnd, cmb13)), Cast(..Point Ptr, @R), 2
				MoveWindow(GetDlgItem(ModalWnd, cmb13), R.Left, R.Top, R.Right - R.Left + 100, R.Bottom - R.Top, True)
				GetWindowRect GetDlgItem(ModalWnd, cmb1), @R
				MapWindowPoints 0, GetParent(GetDlgItem(ModalWnd, cmb1)), Cast(..Point Ptr, @R), 2
				MoveWindow(GetDlgItem(ModalWnd, cmb1), R.Left, R.Top, R.Right - R.Left + 100, R.Bottom - R.Top, True)
				If OpenDial->FVisible Then ShowWindow(ModalWnd, SW_SHOWNORMAL)
				'ShowWindow(OpenDial->Parent->Handle, SW_SHOWNORMAL)
				'ChangeStyle WS_CAPTION, False
				'EndDialog ModalWnd, 0
				'ShowWindow(ModalWnd, SW_HIDE)
				'SendMessage(ModalWnd, WM_DESTROY, 0, 0)
			Case WM_NOTIFY
				Dim As OpenFileControl Ptr OpenDial = Cast(OpenFileControl Ptr, GetWindowLongPtr(FWindow, GWLP_USERDATA))
				Dim As OFNOTIFY Ptr POF
				POF = Cast(OFNOTIFY Ptr, lParam)
				Select Case POF->hdr.code
				Case CDN_FILEOK
					If OpenDial Then If OpenDial->OnFileActivate Then OpenDial->OnFileActivate(*OpenDial->Designer, *OpenDial)
					SetWindowLongPtr FWindow, DWLP_MSGRESULT, 1
					Return 1
				Case CDN_SELCHANGE
					If OpenDial Then If OpenDial->OnSelectionChange Then OpenDial->OnSelectionChange(*OpenDial->Designer, *OpenDial)
				Case CDN_FOLDERCHANGE
					If OpenDial Then If OpenDial->OnFolderChange Then OpenDial->OnFolderChange(*OpenDial->Designer, *OpenDial)
				Case CDN_TYPECHANGE
					Dim As Integer Index
					Index = (*Cast(OPENFILENAME Ptr, POF->lpOFN)).nFilterIndex
					If OpenDial Then
						OpenDial->FilterIndex = Index
						If OpenDial->OnTypeChange Then
							OpenDial->OnTypeChange(*OpenDial->Designer, *OpenDial, Index)
						End If
					End If
				Case CDN_INITDONE
					'MoveWindow GetParent(FWindow), -500, -500, 800, 500, True
					'MoveWindow FWindow, 0, 0, 1000, 1000, True
				End Select
			End Select
			Return False
		End Function
	
	Private Sub OpenFileControl.CreateWnd(Param As Any Ptr)
			Dim As OpenFileControl Ptr OpenDial = Param
			On Error Goto ErrorHandler
			Dim bResult As Boolean
			OpenDial->FileNames.Clear
			Dim cwsFile As WString  * (MAX_PATH + 1) * 100
			Dim dwFlags As DWORD = Cast(Integer, OpenDial->Options)
			Dim dwBufLen As DWORD
			Dim wMarkers As WString * 4 = "||"
			If Right(*OpenDial->FFilter, 1) <> "|" Then wMarkers += "|"
			Dim wFilter As WString Ptr '* 260 = ""
			WLet(wFilter, *OpenDial->FFilter & wMarkers)
			Dim dwFilterStrSize As DWORD = Len(wFilter)
			Dim pchar As WCHAR Ptr = wFilter
			For i As Long = 0 To Len(*wFilter) - 1
				If pchar[i] = Asc("|") Then pchar[i] = 0
			Next
			If WGet(OpenDial->FInitialDir) = "" Then WLet(OpenDial->FInitialDir, CurDir)
			If dwBufLen = 0 Then
				If (dwFlags And OFN_ALLOWMULTISELECT = OFN_ALLOWMULTISELECT) Then dwBufLen = 32768  ' // 64 Kb buffer
			End If
			If dwBufLen < 260 Then dwBufLen = 260
			'WReAllocate cwsFile, Len(*FFileName & "|")
			WLet(OpenDial->FFileTitle, Space(dwBufLen))
			cwsFile = *OpenDial->FFileName & "|"
			Dim cbPos As Long = Len(cwsFile) - 1
			'IF LEN(*cwsFile) < dwBufLen THEN cwsFile = ReAllocate(cwsFile, (dwBufLen + 1) * SizeOf(WString)): *cwsFile += SPACE(dwBufLen - LEN(*cwsFile))
			Dim dwFileStrSize As Integer = Len(cwsFile)
			pchar = @cwsFile
			pchar[cbPos] = 0
			cbPos = Len(*OpenDial->FFileTitle) - 1
			pchar = OpenDial->FFileTitle
			pchar[cbPos] = 0
			Dim ofn As OPENFILENAME
			ZeroMemory(@ofn, SizeOf(ofn))
			ofn.lStructSize     = SizeOf(ofn)
			'If pApp->MainForm Then ofn.hwndOwner       = pApp->MainForm->Handle
			ofn.hwndOwner = 0
			ofn.lpstrFilter     = wFilter
			ofn.nFilterIndex    = 1
			ofn.lpstrFile       = @cwsFile
			ofn.lpstrFileTitle       = OpenDial->FFileTitle
			ofn.nMaxFileTitle       = 256
			'ofn.lpstrFile[0] = 0
			ofn.nMaxFile        = (MAX_PATH + 1) * 100
			ofn.lpstrInitialDir = OpenDial->FInitialDir
			ofn.Flags = dwFlags
			ofn.lpfnHook           = Cast(LPOFNHOOKPROC, @Hook)
			ofn.lCustData          = Cast(LPARAM, OpenDial)
			If OpenDial->FDefaultExt Then ofn.lpstrDefExt = OpenDial->FDefaultExt
			bResult = GetOpenFileName(@ofn)
			OpenDial->ThreadID = 0
			'Deallocate cwsFile
			WDeAllocate(wFilter)
			Exit Sub
	ErrorHandler:
			MsgBox ErrDescription(Err) & " (" & Err & ") " & _
			"in line " & Erl() & " " & _
			"in function " & ZGet(Erfn()) & " " & _
			"in module " & ZGet(Ermn())
	End Sub
	
	Private Sub OpenFileControl.CreateWnd
			If This.Parent <> 0 AndAlso This.Parent->Handle <> 0 Then
				FHandle = 0
				ThreadID = ThreadCreate(@CreateWnd, @This)
				Do While FHandle = 0
					Sleep(300, 1)
					pApp->DoEvents
				Loop
				SetProp(FHandle, "@@@@Proc", Cast(WNDPROC, SetWindowLongPtr(FHandle, GWLP_WNDPROC, CInt(@HookChildProc))))
'					SetProp(FHandle, "@@@@Proc", Cast(WNDPROC, SetWindowLongPtr(FHandle, GWLP_WNDPROC, CInt(@HookChildProc))))
'					SendMessageW(FHandle, WM_THEMECHANGED, 0, 0)
'					EnumChildWindows(FHandle, Cast(WNDENUMPROC, @EnumChildsProc), 0)
'				End If
				SetWindowLongPtr(FHandle, GWLP_USERDATA, CInt(@This))
			End If
	End Sub
	
	
	Private Constructor OpenFileControl
			Options.Include OFN_PATHMUSTEXIST
			Options.Include OFN_FILEMUSTEXIST
			Options.Include OFN_HIDEREADONLY
			Options.Include OFN_ENABLESIZING
			Options.Include OFN_EXPLORER
			Options.Include OFN_ENABLEHOOK
			'OFN_NONETWORKBUTTON
			'OFN_LONGNAMES
			'OFN_NODEREFERENCELINKS
			'OFN_OVERWRITEPROMPT
			'OFN_CREATEPROMPT
			'OFN_DONTADDTORECENT
		Child = @This
		FTabIndex          = -1
		FTabStop           = True
		WLet(FClassName, "OpenFileControl")
		WLet(FFilter, "")
		FilterIndex       = 1
		'Control.Child     = @This
	End Constructor
	
	Private Destructor OpenFileControl
		If FInitialDir Then _Deallocate(FInitialDir)
		If FDefaultExt Then _Deallocate(FDefaultExt)
		If FFileName Then _Deallocate(FFileName)
		If FFileTitle Then _Deallocate(FFileTitle)
		If FFilter Then _Deallocate(FFilter)
			If FHandle Then SetWindowLongPtr(FHandle, GWLP_WNDPROC, CInt(GetProp(FHandle, "@@@@Proc")))
			SendMessage(FHandle, WM_SYSCOMMAND, SC_CLOSE, 0)
			FHandle = 0
	End Destructor
End Namespace

