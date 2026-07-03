'################################################################################
'#  Form.bi                                                                     #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TForm.bi                                                                   #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Updated and added cross-platform                                            #
'#  by Xusinboy Bekchanov (2018-2019), Liu XiaLin (2020)                        #
'################################################################################

#include once "Form.bi"
#include once "Application.bi"
	#include once "win/uxtheme.bi"
	#include once "DarkMode/UAHMenuBar.bi"

Namespace My.Sys.Forms
		Private Function Form.ReadProperty(ByRef PropertyName As String) As Any Ptr
			FTempString = LCase(PropertyName)
			Select Case FTempString
			Case "activecontrol": Return FActiveControl
			Case "borderstyle": Return @FBorderStyle
			Case "cancelbutton": Return FCancelButton
			Case "caption": Return This.FText.vptr
			Case "defaultbutton": Return FDefaultButton
			Case "icon": Return @Icon
			Case "controlbox": Return @FControlBox
			Case "keypreview": Return @FKeyPreview
			Case "minimizebox": Return @FMinimizeBox
			Case "maximizebox": Return @FMaximizeBox
			Case "formstyle": Return @FFormStyle
			Case "menu": Return This.Menu
			Case "mainform": Return @FMainForm
			Case "modalresult": Return @ModalResult
			Case "opacity": Return @FOpacity
			Case "owner": Return FOwner
			Case "showintaskbar": Return @FShowInTaskbar
			Case "transparent": Return @FTransparent
			Case "transparentcolor": Return @FTransparentColor
			Case "windowstate": Return @FWindowState
			Case "startposition": Return @FStartPosition
			Case "graphic": Return Cast(Any Ptr, @This.Graphic)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function Form.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case "activecontrol": This.ActiveControl = 0
				Case "menu": This.Menu = 0
				Case "cancelbutton": This.CancelButton = 0
				Case "defaultbutton": This.DefaultButton = 0
				Case "owner": This.Owner = 0
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "activecontrol": This.ActiveControl = Cast(Control Ptr, Value)
				Case "borderstyle": This.BorderStyle = *Cast(FormBorderStyle Ptr, Value)
				Case "cancelbutton": This.CancelButton = Cast(Control Ptr, Value)
				Case "caption": This.Caption = QWString(Value)
				Case "defaultbutton": This.DefaultButton = Cast(Control Ptr, Value)
				Case "formstyle": This.FormStyle = *Cast(FormStyles Ptr, Value)
				Case "controlbox": This.ControlBox = QBoolean(Value)
				Case "keypreview": This.KeyPreview = QBoolean(Value)
				Case "minimizebox": This.MinimizeBox = QBoolean(Value)
				Case "maximizebox": This.MaximizeBox = QBoolean(Value)
				Case "icon": This.Icon = QWString(Value)
				Case "mainform": This.MainForm = QBoolean(Value)
				Case "menu": This.Menu = Cast(MainMenu Ptr, Value)
				Case "modalresult": This.ModalResult = QInteger(Value)
				Case "opacity": This.Opacity = QInteger(Value)
				Case "owner": This.Owner = Cast(Form Ptr, Value)
				Case "showintaskbar": This.ShowInTaskbar = QBoolean(Value)
				Case "text": This.Text = QWString(Value)
				Case "transparent": This.Transparent = QBoolean(Value)
				Case "transparentcolor": This.TransparentColor = QInteger(Value)
				Case "windowstate": This.WindowState = *Cast(WindowStates Ptr, Value)
				Case "startposition": This.StartPosition = *Cast(FormStartPosition Ptr, Value)
				Case "visible": This.Visible = QBoolean(Value)
				Case "graphic": This.Graphic = QWString(Value)
				Case "xdpi": This.xdpi = QSingle(Value)
				Case "ydpi": This.ydpi = QSingle(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property Form.ActiveControl As Control Ptr
		Return FActiveControl
	End Property
	
	Private Property Form.ActiveControl(Value As Control Ptr)
		FActiveControl = Value
		If FActiveControl Then FActiveControl->SetFocus
		If OnActiveControlChange Then OnActiveControlChange(*Designer, This)
	End Property
	
	Private Property Form.Owner As Form Ptr
		Return Cast(Form Ptr, FOwner)
	End Property
	
	Private Property Form.Owner(Value As Form Ptr)
		If Value <> FOwner Then
			FOwner = Value
				If Handle AndAlso FOwner AndAlso FOwner->Handle Then
					SetParent FOwner->Handle, Handle
				End If
		End If
	End Property
	
	Private Property Form.KeyPreview As Boolean
		Return FKeyPreview
	End Property
	
	Private Property Form.KeyPreview(Value As Boolean)
		FKeyPreview = Value
	End Property
	
	
	Private Property Form.DefaultButton As Control Ptr
		Return FDefaultButton
	End Property
	
	Private Property Form.DefaultButton(Value As Control Ptr)
		FDefaultButton = Value
		If FDefaultButton AndAlso UCase((*FDefaultButton).ClassName) = "COMMANDBUTTON" Then
			
		End If
	End Property
	
	Private Property Form.CancelButton As Control Ptr
		Return FCancelButton
	End Property
	
	Private Property Form.CancelButton(Value As Control Ptr)
		FCancelButton = Value
	End Property
	
	Private Property Form.MainForm As Boolean
		Return FMainForm
	End Property
	
	Private Property Form.MainForm(Value As Boolean)
		If Value <> FMainForm Then
			FMainForm = Value
			If pApp <> 0 Then
				If pApp->MainForm <> 0 Then Cast(Form Ptr, pApp->MainForm)->MainForm = False
					ChangeExStyle WS_EX_APPWINDOW, Value
				If FMainForm Then
					pApp->MainForm = @This
					App.MainForm = @This
				Else
					pApp->MainForm = 0
					App.MainForm = 0
				End If
			End If
		End If
	End Property
	
	Private Property Form.Menu As MainMenu Ptr
		Return FMenu
	End Property
	
	Private Property Form.Menu(Value As MainMenu Ptr)
		FMenu = Value
		If FMenu Then FMenu->ParentWindow = @This
	End Property
	
	Private Property Form.StartPosition As FormStartPosition
		Return FStartPosition
	End Property
	
	Private Property Form.StartPosition(Value As FormStartPosition)
		FStartPosition = Value
		If Not FDesignMode Then
				If FStartPosition = FormStartPosition.CenterParent Then
					CenterToParent
				ElseIf FStartPosition = FormStartPosition.CenterScreen Then
					CenterToScreen
				End If
		End If
	End Property
	
	Private Property Form.Opacity As Integer
		Return FOpacity
	End Property
	
	Private Property Form.Opacity(Value As Integer)
		FOpacity = Value
			ChangeExStyle WS_EX_LAYERED, FOpacity <> 255 OrElse FTransparent
			If FHandle Then SetLayeredWindowAttributes(FHandle, IIf(FTransparentColor = -1, FBackColor, FTransparentColor), FOpacity, IIf(FTransparent, LWA_COLORKEY, 0) Or LWA_ALPHA)
	End Property
	
	Private Property Form.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property Form.Transparent(Value As Boolean)
		FTransparent = Value
			ChangeExStyle WS_EX_LAYERED, FOpacity <> 255 OrElse FTransparent
			If FHandle Then SetLayeredWindowAttributes(FHandle, IIf(FTransparentColor = -1, FBackColor, FTransparentColor), FOpacity, IIf(FTransparent, LWA_COLORKEY, 0) Or LWA_ALPHA)
	End Property
	
	Private Property Form.TransparentColor As Integer
		Return FTransparentColor
	End Property
	
	Private Property Form.TransparentColor(Value As Integer)
		FTransparentColor = Value
			If FHandle Then SetLayeredWindowAttributes(FHandle, IIf(FTransparentColor = -1, FBackColor, FTransparentColor), FOpacity, IIf(FTransparent, LWA_COLORKEY, 0) Or LWA_ALPHA)
	End Property
	
	Private Property Form.ControlBox As Boolean
		Return FControlBox
	End Property
	
	Private Property Form.ControlBox(Value As Boolean)
		FControlBox = Value
			ChangeStyle WS_SYSMENU, Value
			SetWindowPos(FHandle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_DRAWFRAME)
	End Property
	
	Private Property Form.MinimizeBox As Boolean
		Return FMinimizeBox
	End Property
	
	Private Property Form.MinimizeBox(Value As Boolean)
		FMinimizeBox = Value
			ChangeStyle WS_MINIMIZEBOX, Value
			SetWindowPos(FHandle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_DRAWFRAME)
	End Property
	
	Private Property Form.MaximizeBox As Boolean
		Return FMaximizeBox
	End Property
	
	Private Property Form.MaximizeBox(Value As Boolean)
		FMaximizeBox = Value
			ChangeStyle WS_MAXIMIZEBOX, Value
			SetWindowPos(FHandle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_DRAWFRAME)
	End Property
	
	Private Property Form.BorderStyle As FormBorderStyle
		Return FBorderStyle
	End Property
	
	Private Property Form.BorderStyle(Value As FormBorderStyle)
		FBorderStyle = Value
			ChangeStyle WS_POPUP, False
			ChangeStyle WS_BORDER, False
			ChangeStyle WS_THICKFRAME, False
			ChangeStyle WS_DLGFRAME, False
			ChangeStyle DS_CONTROL, False
			ChangeExStyle WS_EX_TOOLWINDOW, False
			ChangeExStyle WS_EX_CLIENTEDGE, False
			ChangeExStyle WS_EX_WINDOWEDGE, False
			ChangeExStyle WS_EX_DLGMODALFRAME, False
			Select Case Value
			Case FormBorderStyle.None
				ChangeStyle WS_CAPTION, False
				ChangeStyle DS_CONTROL, True
				If Not FDesignMode Then ChangeStyle WS_POPUP, True
				ChangeExStyle WS_EX_CONTROLPARENT, True
			Case FormBorderStyle.SizableToolWindow
				ChangeStyle WS_BORDER, True
				ChangeStyle WS_THICKFRAME, True
				ChangeExStyle WS_EX_TOOLWINDOW, True
			Case FormBorderStyle.FixedToolWindow
				ChangeStyle WS_BORDER, True
				ChangeStyle WS_DLGFRAME, True
				ChangeExStyle WS_EX_TOOLWINDOW, True
			Case FormBorderStyle.Sizable
				ChangeStyle WS_THICKFRAME, True
				ChangeStyle WS_DLGFRAME, True
				ChangeStyle WS_BORDER, True
				ChangeExStyle WS_EX_WINDOWEDGE, True
			Case FormBorderStyle.Fixed3D
				ChangeStyle WS_DLGFRAME, True
				ChangeStyle WS_BORDER, True
				ChangeExStyle WS_EX_WINDOWEDGE, True
				ChangeExStyle WS_EX_CLIENTEDGE, True
			Case FormBorderStyle.FixedSingle
				ChangeStyle WS_DLGFRAME, True
				ChangeStyle WS_BORDER, True
				ChangeExStyle WS_EX_WINDOWEDGE, True
			Case FormBorderStyle.FixedDialog
				ChangeStyle WS_DLGFRAME, True
				ChangeStyle WS_BORDER, True
				ChangeExStyle WS_EX_DLGMODALFRAME, True
			End Select
			If Not FShowCaption Then ChangeStyle WS_CAPTION, False
			If FHandle Then SetWindowPos(FHandle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_DRAWFRAME)
	End Property
	
	Private Property Form.FormStyle As FormStyles
		Return FFormStyle
	End Property
	
	
	Private Property Form.FormStyle(Value As FormStyles)
		If Value = FFormStyle Then Exit Property
		FFormStyle = Value
		Select Case FFormStyle
		Case 0 'fsNormal
				If (ExStyle And WS_EX_TOPMOST) = WS_EX_TOPMOST Then
					ExStyle = ExStyle And Not WS_EX_TOPMOST
					If FHandle Then SetWindowPos Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOACTIVATE Or SWP_NOSIZE
				End If
		Case 1 'fsMDIForm
		Case 2 'fsMDIChild
				ChangeExStyle WS_EX_MDICHILD, True
				If FHandle <> 0 AndAlso Not DesignMode Then RecreateWnd
		Case 3 'fsStayOnTop
				If (ExStyle And WS_EX_TOPMOST) <> WS_EX_TOPMOST Then
					ExStyle = ExStyle Or WS_EX_TOPMOST
					If FHandle Then SetWindowPos Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOACTIVATE Or SWP_NOSIZE
				End If
		End Select
	End Property
	
	Private Property Form.Parent As Control Ptr
		Return Cast(Control Ptr, @FParent)
	End Property
	
	Private Property Form.Parent(value As Control Ptr)
			Base.Parent = value
		If *value Is Form Then
			If Cast(Form Ptr, value)->FFormStyle = fsMDIForm Then
					If IsWindow(FHandle) Then
						SetParent(FHandle, IIf(value, Cast(Form Ptr, value)->FClient, 0))
					End If
			End If
		End If
	End Property
	
	Private Property Form.ShowInTaskbar As Boolean
		Return FShowInTaskbar
	End Property
	
	Private Property Form.ShowInTaskbar(Value As Boolean)
		If FShowInTaskbar <> Value Then
			FShowInTaskbar = Value
				Dim As ITaskbarList Ptr pTaskbarList
				If SUCCEEDED(CoInitialize(NULL)) Then
					If SUCCEEDED(CoCreateInstance(@CLSID_TaskbarList, NULL, CLSCTX_INPROC_SERVER, @IID_ITaskbarList, Cast(LPVOID, @pTaskbarList))) Then
						pTaskbarList->lpVtbl->HrInit(pTaskbarList)
						If Value Then
							pTaskbarList->lpVtbl->DeleteTab(pTaskbarList, FHandle)
						Else
							pTaskbarList->lpVtbl->AddTab(pTaskbarList, FHandle)
						End If
						pTaskbarList->lpVtbl->Release(pTaskbarList)
					End If
					CoUninitialize()
				End If
		End If
	End Property
	
	Property Form.WindowState As WindowStates
			If Handle Then
				If IsIconic(Handle) Then
					FWindowState = WindowStates.wsMinimized
				ElseIf IsZoomed(Handle) Then
					FWindowState = WindowStates.wsMaximized
				Else
					FWindowState = WindowStates.wsNormal
				End If
			End If
		Return FWindowState
	End Property
	
	Private Property Form.WindowState(Value As WindowStates)
		FWindowState = Value
			If Handle Then
				If Not FDesignMode Then
					Dim nState As Long
					Select Case FWindowState
					Case WindowStates.wsMinimized:  nState = SW_SHOWMINIMIZED
					Case WindowStates.wsMaximized:  nState = SW_SHOWMAXIMIZED
					Case WindowStates.wsNormal:     nState = SW_SHOWNORMAL
					Case WindowStates.wsHide:       nState = SW_HIDE
					End Select
					ShowWindow(Handle, nState)
				End If
			Else
				ChangeStyle WS_MINIMIZE, False
				ChangeStyle WS_MAXIMIZE, False
				ChangeStyle WS_VISIBLE, True
				Select Case FWindowState
				Case WindowStates.wsMinimized:  ChangeStyle WS_MINIMIZE, True
				Case WindowStates.wsMaximized:  ChangeStyle WS_MAXIMIZE, True
				Case WindowStates.wsNormal:
				Case WindowStates.wsHide:       ChangeStyle WS_VISIBLE, False
				End Select
			End If
	End Property
	
	Private Property Form.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property Form.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property Form.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property Form.Text(ByRef Value As WString)
		Base.Text = Value
	End Property
	
	Private Property Form.Enabled As Boolean
		Return Base.Enabled
	End Property
	
	Private Property Form.Enabled(Value As Boolean)
		Base.Enabled = Value
	End Property
	
	Private Sub Form.ActiveControlChanged(ByRef Sender As Control)
		If Sender.Child Then
			With QForm(Sender.Child)
				If .OnActiveControlChange Then .OnActiveControlChange(*QForm(Sender.Child).Designer, QForm(Sender.Child))
			End With
		End If
	End Sub
	
		Private Sub Form.WNDPROC(ByRef message As Message)
			
		End Sub
		
		Private Sub Form.HandleIsDestroyed(ByRef Sender As Control)
			If Sender.Child Then
				With QForm(Sender.Child)
					SetMenu .Handle, NULL
					DrawMenuBar .Handle
				End With
			End If
		End Sub
		
		'		Function GetAscKeyCode(HotKey As String) As Integer
		'	        Select Case HotKey
		'	        Case "Backspace", "Back": Return 08
		'	        Case "Tab": Return 09
		'	        Case "Enter", "Return": Return 13
		'	        Case "Escape", "Esc": Return 27
		'	        Case "Space": Return 32
		'	        Case "PageUp": Return 33
		'	        Case "PageDown": Return 34
		'	        Case "End": Return 35
		'	        Case "Home": Return 36
		'	        Case "Left": Return 37
		'	        Case "Up": Return 38
		'	        Case "Right": Return 39
		'	        Case "Down": Return 40
		'	        Case "Print": Return 42
		'	        Case "Insert", "Ins": Return 45
		'	        Case "Num0": Return 96
		'	        Case "Num1": Return 97
		'	        Case "Num2": Return 98
		'	        Case "Num3": Return 99
		'	        Case "Num4": Return 100
		'	        Case "Num5": Return 101
		'	        Case "Num6": Return 102
		'	        Case "Num7": Return 103
		'	        Case "Num8": Return 104
		'	        Case "Num9": Return 105
		'	        Case "F1": Return 112
		'	        Case "F2": Return 113
		'	        Case "F3": Return 114
		'	        Case "F4": Return 115
		'	        Case "F5": Return 116
		'	        Case "F6": Return 117
		'	        Case "F7": Return 118
		'	        Case "F8": Return 119
		'	        Case "F9": Return 120
		'	        Case "F10": Return 121
		'	        Case "F11": Return 122
		'	        Case "F12": Return 123
		'	        Case "Delete", "Del": : Return 127
		'	        Case Else: Return Asc(HotKey)
		'	        End Select
		'	    End Function
		
		Function Form.HookClientProc(hDlg As HWND, uMsg As UINT, WPARAM As WPARAM, LPARAM As LPARAM) As LRESULT
			Dim As Form Ptr frm = GetProp(hDlg, "MFFControl")
			If frm Then
				Select Case uMsg
				Case WM_WINDOWPOSCHANGING
					Dim As WINDOWPOS Ptr lpwp = Cast(WINDOWPOS Ptr, LPARAM)
					lpwp->x = frm->ScaleX(frm->FClientX)
					lpwp->y = frm->ScaleY(frm->FClientY)
					lpwp->cx = frm->ScaleX(frm->FClientW)
					lpwp->cy = frm->ScaleY(frm->FClientH)
				Case WM_PAINT, WM_ERASEBKGND
					SendMessage frm->Handle, uMsg, WPARAM, LPARAM
				End Select
			End If
			Return CallWindowProc(GetProp(hDlg, "@@@@Proc"), hDlg, uMsg, WPARAM, LPARAM)
		End Function
	
		Private Sub Form.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QForm(Sender.Child)
						Dim As HMENU NoNeedSysMenu
						SetClassLong(.Handle, GCL_STYLE, .FClassStyle(.BorderStyle))
						If .FBorderStyle = 2 Then
							SetClassLongPtr(.Handle,GCLP_HICON,NULL)
							SendMessage(.Handle, WM_SETICON, 1, NULL)
							NoNeedSysMenu = GetSystemMenu(.Handle, False)
							DeleteMenu(NoNeedSysMenu, SC_TASKLIST, MF_BYCOMMAND)
							DeleteMenu(NoNeedSysMenu, 7, MF_BYPOSITION)
							DeleteMenu(NoNeedSysMenu, 5, MF_BYPOSITION)
							DeleteMenu(NoNeedSysMenu, SC_MAXIMIZE, MF_BYCOMMAND)
							DeleteMenu(NoNeedSysMenu, SC_MINIMIZE, MF_BYCOMMAND)
							DeleteMenu(NoNeedSysMenu, SC_SIZE, MF_BYCOMMAND)
							DeleteMenu(NoNeedSysMenu, SC_RESTORE, MF_BYCOMMAND)
						Else
							SendMessage(.Handle, WM_SETICON, 1, CInt(.Icon.Handle))
							'GetSystemMenu(.Handle, True)
							'EnableMenuItem(NoNeedSysMenu, SC_MINIMIZE, MF_BYCOMMAND Or MF_GRAYED)
							'EnableMenuItem(NoNeedSysMenu, SC_MAXIMIZE, MF_BYCOMMAND Or MF_GRAYED)
						End If
						If Not .FShowCaption Then .ShowCaption = False
						If Not .FShowInTaskbar Then .ShowInTaskbar = False
						If .Opacity <> 255 OrElse .Transparent Then SetLayeredWindowAttributes(.Handle, IIf(.TransparentColor = -1, .BackColor, .TransparentColor), .Opacity, IIf(.Transparent, LWA_COLORKEY, 0) Or LWA_ALPHA)
						.ChangeTabIndex - 2
						SendMessage(.Handle, WM_UPDATEUISTATE, MAKEWPARAM(UIS_CLEAR, UISF_HIDEFOCUS), NULL)
						If .Menu Then .Menu->ParentWindow = @Sender
						Select Case .FFormStyle
						Case fsMDIForm
							Dim FClientStruct As CLIENTCREATESTRUCT
							FClientStruct.hWindowMenu = 0 'GetSubMenu(GetMenu(.FHandle), WINDOWMENU)
							FClientStruct.idFirstChild = &H00FF
							.FClient = CreateWindowEx(0, "MDICLIENT", "", WS_CHILD Or WS_VISIBLE Or WS_VSCROLL Or WS_HSCROLL Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN, 0, 0, 100, 100, .FHandle, Cast(HMENU, &hcac), Instance, @FClientStruct)
							If GetWindowLongPtr(.FClient, GWLP_WNDPROC) <> @HookClientProc Then
								SetProp(.FClient, "MFFControl", Sender.Child)
								SetProp(.FClient, "@@@@Proc", Cast(..WNDPROC, SetWindowLongPtr(.FClient, GWLP_WNDPROC, CInt(@HookClientProc))))
							End If
							ShowWindow(.FClient, SW_SHOW)
						Case fsMDIChild
							If .FParent Then
								If *(.FParent) Is Form Then
									If Cast(Form Ptr, .FParent)->FFormStyle = fsMDIForm Then
										SetParent(.FHandle, Cast(Form Ptr, .FParent)->FClient)
									End If
								End If
							End If
						End Select
						'					.GetMenuItems
						'					Dim As String mnuCaption, HotKey
						'					Dim As Integer Pos1, CountOfHotKeys = 0
						'					Dim As MenuItem Ptr mi
						'					ReDim accl(1) As ACCEL
						'					For i As Integer = 0 To .FMenuItems.Count - 1
						'						mi = .FMenuItems.Items[i]
						'						mnuCaption = mi->Caption
						'						Pos1 = InStr(mnuCaption, !"\t")
						'						If Pos1 > 0 Then
						'							CountOfHotKeys = CountOfHotKeys + 1
						'							HotKey = Mid(mnuCaption, Pos1 + 1)
						'							ReDim Preserve accl(CountOfHotKeys - 1) As ACCEL
						'							If InStr(HotKey, "Ctrl") > 0 Then accl(CountOfHotKeys - 1).fVirt = accl(CountOfHotKeys - 1).fVirt Or FCONTROL
						'							If InStr(HotKey, "Shift") > 0 Then accl(CountOfHotKeys - 1).fVirt = accl(CountOfHotKeys - 1).fVirt Or FSHIFT
						'							If InStr(HotKey, "Alt") > 0 Then accl(CountOfHotKeys - 1).fVirt = accl(CountOfHotKeys - 1).fVirt Or FALT
						'							accl(CountOfHotKeys - 1).fVirt = accl(CountOfHotKeys - 1).fVirt Or FVIRTKEY
						'							Pos1 = InStrRev(HotKey, "+")
						'							If Pos1 > 0 Then HotKey = Mid(HotKey, Pos1 + 1)
						'							accl(CountOfHotKeys - 1).key = GetAscKeyCode(HotKey)
						'							accl(CountOfHotKeys - 1).cmd = mi->Command
						'						End If
						'					Next i
						'					If .Accelerator <> 0 Then DestroyAcceleratorTable(.Accelerator)
						'					.Accelerator = CreateAcceleratorTable(Cast(LPACCEL, @accl(0)), CountOfHotKeys)
						'					Erase accl
				End With
			End If
		End Sub
	
	
		Private Sub Form.SetDark(Value As Boolean)
			Base.SetDark Value
			RefreshTitleBarThemeColor(FHandle)
			If FClient Then
				If Value Then
					SetWindowTheme(FClient, "DarkMode_Explorer", nullptr)
				Else
					SetWindowTheme(FClient, NULL, NULL)
				End If
				AllowDarkModeForWindow(FClient, g_darkModeEnabled)
				SendMessageW(FClient, WM_THEMECHANGED, 0, 0)
			End If
			SendMessage FHandle, WM_NCACTIVATE, False, 0
			SendMessage FHandle, WM_NCACTIVATE, True, 0
			SendMessage FHandle, WM_THEMECHANGED, 0, 0
			Repaint
		End Sub
	
	Private Sub Form.ProcessMessage(ByRef msg As Message)
		Dim As Integer Action = 1
			Static As Boolean IsMenuItem
			Select Case msg.Msg
			Case WM_GETMINMAXINFO
				'David Change
				'Do not process this message for MDI child forms, as it will interfere with child form maximization
				If (GetWindowLongPtr(Handle, GWL_EXSTYLE) And WS_EX_MDICHILD) = WS_EX_MDICHILD Then
					'DefWindowProcW(Handle, Msg.Msg, Msg.wParam, Msg.lParam)
					Dim FLY_pMinMaxInfo As MINMAXINFO Ptr = Cast(MINMAXINFO Ptr, msg.lParam)
					msg.Result = 0
				End If
			Case WM_THEMECHANGED
				If (g_darkModeSupported) Then
					AllowDarkModeForWindow(msg.hWnd, g_darkModeEnabled)
					RefreshTitleBarThemeColor(msg.hWnd)
					UpdateWindow(msg.hWnd)
				End If
			Case WM_DPICHANGED
				xdpi = msg.wParamLo / 96
				ydpi = msg.wParamHi / 96
				If xdpi = 0 Then xdpi = 1 'FDpiFormX
				If ydpi = 0 Then ydpi = 1 'FDpiFormY
				'If Not IsIconic(FHandle) Then 'AndAlso (xdpi <> FDpiFormX OrElse ydpi <> FDpiFormY) Then
				'	'FDpiFormX = xdpi
				'	'FDpiFormY = ydpi
				'	RequestAlign
				'End If
				FDPIChanging = True
				LockWindowUpdate(FHandle)
				Base.ProcessMessage(msg)
				LockWindowUpdate(0)
				FDPIChanging = False
				Return
			Case WM_SIZE
				'xdpi = FDpiFormX
				'ydpi = FDpiFormY
				If OnResize Then OnResize(*Designer, This, This.Width, This.Height)
				If Not IsIconic(FHandle) Then
					'If Not FDPIChanging Then UpdateLock
					'RequestAlign
					'If Not FDPIChanging Then UpdateUnLock
					'If Graphic.Visible AndAlso Graphic.Bitmap.Handle > 0 Then Repaint
				End If
			Case WM_UAHDRAWMENU
				If g_darkModeSupported AndAlso g_darkModeEnabled Then
					Dim As UAHMENU Ptr pUDM = Cast(UAHMENU Ptr, msg.lParam)
					Dim As ..Rect rc = Type( 0 )
					
					' Get the menubar rect
					Dim As MENUBARINFO mbi = Type(  SizeOf(mbi) )
					GetMenuBarInfo(msg.hWnd, OBJID_MENU, 0, @mbi)
					
					Dim As ..Rect rcWindow
					GetWindowRect(msg.hWnd, @rcWindow)
					
					' the rcBar is offset by the window rect
					rc = mbi.rcBar
					OffsetRect(@rc, -rcWindow.Left, -rcWindow.Top)
					
					FillRect(pUDM->hdc, @rc, hbrBkgnd)
					
					msg.Result = True
					Return
				End If
			Case WM_UAHDRAWMENUITEM
				If g_darkModeSupported AndAlso g_darkModeEnabled Then
					Dim As UAHDRAWMENUITEM Ptr pUDMI = Cast(UAHDRAWMENUITEM Ptr, msg.lParam)
					
					Dim As HBRUSH Ptr pbrBackground = @hbrBkgnd
					
					' get the menu item string
					Dim As WString * 256 menuString
					Dim As MENUITEMINFO mii = Type( SizeOf(mii), MIIM_STRING Or MIIM_BITMAP)
					mii.dwTypeData = @menuString
					mii.cch = 256
					
					GetMenuItemInfo(pUDMI->um.hmenu, pUDMI->umi.iPosition, True, @mii)
					
					If mii.hbmpItem = HBMMENU_MBAR_MINIMIZE OrElse mii.hbmpItem = HBMMENU_MBAR_RESTORE OrElse mii.hbmpItem = HBMMENU_MBAR_CLOSE Then
						If mii.hbmpItem = HBMMENU_MBAR_MINIMIZE Then
							Dim As MENUITEMINFO mii0 = Type( SizeOf(mii), MIIM_STRING Or MIIM_BITMAP Or MIIM_CHECKMARKS Or MIIM_DATA)
							mii0.dwTypeData = @menuString
							mii0.cch = 256
							GetMenuItemInfo(pUDMI->um.hmenu, 0, True, @mii0)
							Dim As HWND h = Cast(HWND, SendMessage(FClient, WM_MDIGETACTIVE, 0, 0))
							If h Then
								Dim As HICON hIco = Cast(HICON, SendMessage(h, WM_GETICON, Cast(WPARAM, ICON_SMALL), 0))
								Dim As Integer iTop = ScaleY(31) + (pUDMI->dis.rcItem.Bottom - pUDMI->dis.rcItem.Top - 1 - ScaleY(16)) / 2
								If hIco = 0 Then hIco = LoadIcon(0, IDI_APPLICATION)
								DrawIconEx(pUDMI->um.hdc, 15, iTop, hIco, ScaleX(16), ScaleY(16), 0, 0, DI_NORMAL)
							End If
						End If
						
						Dim As HPEN Pen = CreatePen(PS_SOLID, 0, IIf(pUDMI->dis.itemState And ODS_SELECTED, BGR(153, 153, 153), BGR(98, 98, 98)))
						Dim As HPEN PrevPen = SelectObject(pUDMI->um.hdc, Pen)
						Dim As HBRUSH PrevBrush = SelectObject(pUDMI->um.hdc, hbrBkgnd)
						
						FillRect(pUDMI->um.hdc, @pUDMI->dis.rcItem, *pbrBackground)
						
						If pUDMI->dis.itemState And ODS_SELECTED Then SelectObject(pUDMI->um.hdc, hbrHlBkgnd)
						Rectangle pUDMI->um.hdc, pUDMI->dis.rcItem.Left, pUDMI->dis.rcItem.Top + 1, pUDMI->dis.rcItem.Right - 1, pUDMI->dis.rcItem.Bottom
						DeleteObject(Pen)
						
						Dim As Integer iLeft = pUDMI->dis.rcItem.Left + (pUDMI->dis.rcItem.Right - 1 - pUDMI->dis.rcItem.Left - 8) / 2
						Dim As Integer iTop = pUDMI->dis.rcItem.Top + (pUDMI->dis.rcItem.Bottom - 1 - pUDMI->dis.rcItem.Top - 8) / 2 + 1
						Select Case mii.hbmpItem
						Case HBMMENU_MBAR_MINIMIZE
							Pen = CreatePen(PS_SOLID, 0, BGR(122, 136, 150))
							SelectObject(pUDMI->um.hdc, Pen)
							Rectangle pUDMI->um.hdc, iLeft, iTop + 6, iLeft + 6, iTop + 6 + 2
							DeleteObject(Pen)
						Case HBMMENU_MBAR_RESTORE
							Pen = CreatePen(PS_SOLID, 0, BGR(122, 136, 150))
							SelectObject(pUDMI->um.hdc, Pen)
							Rectangle pUDMI->um.hdc, iLeft, iTop + 4, iLeft + 6, iTop + 4 + 4
							MoveToEx pUDMI->um.hdc, iLeft, iTop + 3, 0
							LineTo pUDMI->um.hdc, iLeft + 6, iTop + 3
							SetPixel pUDMI->um.hdc, iLeft + 2, iTop + 2, BGR(122, 136, 150)
							MoveToEx pUDMI->um.hdc, iLeft + 7, iTop + 2, 0
							LineTo pUDMI->um.hdc, iLeft + 7, iTop + 5
							Rectangle pUDMI->um.hdc, iLeft + 2, iTop, iLeft + 8, iTop + 2
							DeleteObject(Pen)
						Case HBMMENU_MBAR_CLOSE
							Pen = CreatePen(PS_SOLID, 2, BGR(122, 136, 150))
							SelectObject(pUDMI->um.hdc, Pen)
							MoveToEx pUDMI->um.hdc, iLeft + 1, iTop + 1, 0
							LineTo pUDMI->um.hdc, iLeft + 7, iTop + 7
							MoveToEx pUDMI->um.hdc, iLeft + 7, iTop + 1, 0
							LineTo pUDMI->um.hdc, iLeft + 1, iTop + 7
							DeleteObject(Pen)
						End Select
						
						SelectObject(pUDMI->um.hdc, PrevPen)
						SelectObject(pUDMI->um.hdc, PrevBrush)
						
					Else
						' get the item state for drawing
						
						Dim As DWORD dwFlags = DT_CENTER Or DT_SINGLELINE Or DT_VCENTER
						
						Enum POPUPITEMSTATES
							MPI_NORMAL = 1,
							MPI_HOT = 2,
							MPI_DISABLED = 3,
							MPI_DISABLEDHOT = 4,
						End Enum
						
						Dim As Integer iTextStateID = 0
						Dim As Integer iBackgroundStateID = 0
						If ((pUDMI->dis.itemState And ODS_INACTIVE) Or (pUDMI->dis.itemState And ODS_DEFAULT)) Then
							' normal display
							iTextStateID = MPI_NORMAL
							iBackgroundStateID = MPI_NORMAL
						End If
						If (pUDMI->dis.itemState And ODS_HOTLIGHT) Then
							' hot tracking
							iTextStateID = MPI_HOT
							iBackgroundStateID = MPI_HOT
							
							pbrBackground = @hbrHlBkgnd '@g_brItemBackgroundHot
						End If
						If (pUDMI->dis.itemState And ODS_SELECTED) Then
							' clicked -- MENU_POPUPITEM has no state for this, though MENU_BARITEM does
							iTextStateID = MPI_HOT
							iBackgroundStateID = MPI_HOT
							
							pbrBackground = @hbrHlBkgnd '@g_brItemBackgroundSelected
						End If
						If ((pUDMI->dis.itemState And ODS_GRAYED) Or (pUDMI->dis.itemState And ODS_DISABLED)) Then
							' disabled / grey text
							iTextStateID = MPI_DISABLED
							iBackgroundStateID = MPI_DISABLED
							pbrBackground = @hbrBkgnd
						End If
						If (pUDMI->dis.itemState And ODS_NOACCEL) Then
							dwFlags Or = DT_HIDEPREFIX
						End If
						
						If (g_menuTheme = 0) Then
							g_menuTheme = OpenThemeData(msg.hWnd, "Menu")
						End If
						
						'Dim As DTTOPTS opts = Type( SizeOf(opts), DTT_TEXTCOLOR, IIf(iTextStateID <> MPI_DISABLED, RGB(&h00, &h00, &h20), RGB(&h40, &h40, &h40) )
						
						FillRect(pUDMI->um.hdc, @pUDMI->dis.rcItem, *pbrBackground)
						SetBkMode pUDMI->um.hdc, Transparent
						If iTextStateID = MPI_DISABLED Then
							SetTextColor pUDMI->um.hdc, darkHlBkColor
						Else
							SetTextColor pUDMI->um.hdc, darkTextColor
						End If
						SetBkColor pUDMI->um.hdc, darkBkColor
						DrawText pUDMI->um.hdc, menuString, mii.cch, @pUDMI->dis.rcItem, dwFlags
						SetBkMode pUDMI->um.hdc, OPAQUE
						'DrawThemeTextEx(g_menuTheme, pUDMI->um.hdc, MENU_BARITEM, MBI_NORMAL, menuString, mii.cch, dwFlags, @pUDMI->dis.rcItem, @opts)
					End If
					
					msg.Result = True
					Return
				End If
			Case WM_NCPAINT, WM_NCACTIVATE
				If g_darkModeSupported AndAlso g_darkModeEnabled Then
					If FormStyle = FormStyles.fsMDIChild Then
						DefMDIChildProc(msg.hWnd, msg.Msg, msg.wParam, msg.lParam)
					ElseIf FormStyle = FormStyles.fsMDIForm Then
						DefFrameProc(msg.hWnd, FClient, msg.Msg, msg.wParam, msg.lParam)
					Else
						DefWindowProc(msg.hWnd, msg.Msg, msg.wParam, msg.lParam)
					End If
					Dim As MENUBARINFO mbi = Type( SizeOf(mbi) )
					If (GetMenuBarInfo(msg.hWnd, OBJID_MENU, 0, @mbi) = 0) Then
						msg.Result = True
						Return
					End If
					
					Dim As Rect rcClient = Type( 0 )
					GetClientRect(msg.hWnd, @rcClient)
					MapWindowPoints(msg.hWnd, nullptr, Cast(Point Ptr, @rcClient), 2)
					
					Dim As Rect rcWindow = Type( 0 )
					GetWindowRect(msg.hWnd, @rcWindow)
					
					OffsetRect(@rcClient, -rcWindow.Left, -rcWindow.Top)
					
					' the rcBar is offset by the window rect
					Dim As Rect rcAnnoyingLine = rcClient
					rcAnnoyingLine.Bottom = rcAnnoyingLine.Top
					rcAnnoyingLine.Top -= 1
					
					Dim As HDC Dc = GetWindowDC(msg.hWnd)
					FillRect(Dc, @rcAnnoyingLine, hbrBkgnd)
					ReleaseDC(msg.hWnd, Dc)
					msg.Result = True
					Return
				End If
			Case WM_PAINT
				If g_darkModeSupported AndAlso g_darkModeEnabled Then
					If Not FDarkMode Then SetDark True
				Else
					If FDarkMode Then SetDark False
				End If
				Dim As HDC Dc, memDC
				Dim As PAINTSTRUCT Ps
				Dim As ..Rect R
				GetClientRect Handle, @R
				Dim As HBITMAP Bmp, hOldBmp
				Dc = BeginPaint(Handle, @Ps)
				If DoubleBuffered Then
					memDC = CreateCompatibleDC(Dc)
					Bmp   = CreateCompatibleBitmap(Dc, R.Right - R.left, R.Bottom - R.Top)
					hOldBmp = SelectObject(memDC, Bmp)
					FillRect memDC, @R, Brush.Handle
					Canvas.SetHandle memDC
				Else
					FillRect Dc, @R, Brush.Handle
					Canvas.SetHandle Dc
				End If
				With Graphic
					If .Visible AndAlso .Bitmap.Handle > 0 Then
						Select Case Graphic.StretchImage
						Case StretchMode.smNone
							Canvas.DrawAlpha .StartX, .StartY, , , .Bitmap
						Case StretchMode.smStretch
							Canvas.DrawAlpha .StartX, .StartY, ScaleX(This.Width) * .ScaleFactor, ScaleY(This.Height) * .ScaleFactor, .Bitmap
						Case Else 'StretchMode.smStretchProportional
							Dim As Double imgWidth = .Bitmap.Width
							Dim As Double imgHeight = .Bitmap.Height
							Dim As Double PicBoxWidth = ScaleX(This.Width) * .ScaleFactor
							Dim As Double PicBoxHeight = ScaleY(This.Height) * .ScaleFactor
							Dim As Double img_ratio = imgWidth / imgHeight
							Dim As Double PicBox_ratio =  PicBoxWidth / PicBoxHeight
							If (PicBox_ratio >= img_ratio) Then
								imgHeight = PicBoxHeight
								imgWidth = imgHeight *img_ratio
							Else
								imgWidth = PicBoxWidth
								imgHeight = imgWidth / img_ratio
							End If
							If .CenterImage Then
								Canvas.DrawAlpha Max((PicBoxWidth - imgWidth * .ScaleFactor) / 2, .StartX), Max((PicBoxHeight - imgHeight * .ScaleFactor) / 2, Graphic.StartY), imgWidth * Graphic.ScaleFactor, imgHeight * .ScaleFactor, .Bitmap
							Else
								Canvas.DrawAlpha .StartX, .StartY, imgWidth, imgHeight, .Bitmap
							End If
						End Select
					End If
				End With
				If OnPaint Then OnPaint(*Designer, This, Canvas)
				Canvas.UnSetHandle
				If DoubleBuffered Then
					BitBlt(Dc, 0, 0, R.Right - R.left, R.Bottom - R.top, memDC, 0, 0, SRCCOPY)
					SelectObject memDC, hOldBmp
					DeleteObject(Bmp)
					DeleteDC(memDC)
				End If
				EndPaint Handle, @Ps
			Case WM_CLOSE
				If OnClose Then
					OnClose(*Designer, This, Action)
				End If
				Select Case Action
				Case 0
					msg.Result = -1
				Case 1
					If MainForm Then
						'PostQuitMessage 0
						End 0
					Else
						If InShowModal Then
							For i As Integer = 0 To pApp->FormCount - 1
								pApp->Forms[i]->Enabled = True
							Next i
						End If
						If FParent AndAlso FParent->Handle Then
							SetWindowPos FParent->Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
						End If
					End If
				Case 2
					ShowWindow Handle, SW_MINIMIZE
					msg.Result = -1
				Case 3
					ShowWindow Handle, SW_HIDE
					msg.Result = -1
				End Select
			Case WM_COMMAND
				GetMenuItems
				Dim As MenuItem Ptr mi
				For i As Integer = 0 To FMenuItems.Count -1
					mi = FMenuItems.Items[i]
					With *mi
						If .Command = msg.wParamLo Then
							If .OnClick Then .OnClick(*mi->Designer, *mi)
							msg.Result = -2
							msg.Msg = 0
							Exit For
						End If
					End With
				Next i
				IsMenuItem = False
			Case WM_MENUSELECT
				IsMenuItem = True
			Case WM_INITMENU
			Case WM_INITMENUPOPUP
				'			Case WM_TIMER
				'				If OnTimer Then OnTimer(This)
			Case WM_MDIACTIVATE
				If msg.lParam = msg.hWnd Then
					pApp->ActiveMDIChild = @This
					If OnActivate Then OnActivate(*Designer, This)
				End If
				If msg.wParam = msg.hWnd Then
					If OnDeActivate Then OnDeActivate(*Designer, This)
				End If
			Case WM_ACTIVATE
				'xdpi = FDpiFormX
				'ydpi = FDpiFormY
				Select Case msg.wParamLo
				Case WA_ACTIVE, WA_CLICKACTIVE
					pApp->ActiveForm = @This
					If OnActivate Then OnActivate(*Designer, This)
				Case WA_INACTIVE
					If OnDeActivate Then OnDeActivate(*Designer, This)
				End Select
			Case WM_ACTIVATEAPP
				Select Case msg.wParam
				Case 1
					If OnActivateApp Then OnActivateApp(*Designer, This)
				Case 0
					If OnDeActivateApp Then OnDeActivateApp(*Designer, This)
				End Select
			Case WM_MOUSEACTIVATE
				If FFormStyle <> FormStyles.fsMDIChild Then
					If GetActiveWindow() <> FHandle Then
						msg.Result = MA_ACTIVATEANDEAT
						Return
					End If
				End If
			Case WM_DESTROY
				If Accelerator Then DestroyAcceleratorTable(Accelerator)
			Case WM_DRAWITEM
				Dim As DRAWITEMSTRUCT Ptr diStruct
				diStruct = Cast(DRAWITEMSTRUCT Ptr, msg.lParam)
				Select Case diStruct->CtlType
				Case ODT_MENU
					'If This.Menu AndAlso This.Menu->ImagesList AndAlso This.Menu->ImagesList->Handle AndAlso diStruct->itemData <> 0 Then
					'    ImageList_Draw(This.Menu->ImagesList->Handle, Cast(MenuItem Ptr, diStruct->itemData)->ImageIndex, diStruct->hDC, 2, 2, ILD_NORMAL)
					'End If
				End Select
			Case CM_HELP
				Dim As My.Sys.Drawing.Point P
				Dim As HWND HControl
				Dim As Control Ptr Ctrl
				Dim As Integer ContextID,Id,i
				Dim As HELPINFO Ptr HIF
				HIF = Cast(HELPINFO Ptr, msg.lParam)
				If HIF->iContextType = HELPINFO_WINDOW Then
					HControl = HIF->hItemHandle
					Ctrl = Cast(Control Ptr, GetWindowLongPtr(HControl, GWLP_USERDATA))
					If Ctrl Then
						If Ctrl->HelpContext <> 0 Then
							ContextID = Ctrl->HelpContext
						Else
							If Ctrl->Parent Then
								Ctrl= Ctrl->Parent
								ContextID = Ctrl->HelpContext
							Else
								Exit Select
							End If
						End If
					End If
					Ctrl->ClientToScreen(P)
				Else  ' Message.HelpInfo.iContextType = HELPINFO_MENUITEM
					Id = 0
					If This.Menu Then
						For i = 0 To This.Menu->Count -1
							If This.Menu->Item(i)->Command = HIF->iCtrlId Then
								Id = i
								Exit For
							End If
						Next i
					End If
					'                 If Id Then ContextID = MainMenu.Item(Id)->HelpContext
					'                 If ContextID = 0 Then
					'                     For i = 0 to MainMenu.Count -1
					'                          If MainMenu.Items[i]->CommandID = HIF->iCtrlID Then
					'                              Id = i
					'                              Exit For
					'                          End If
					'                     Next i
					'                     If Id then ContextID = PopupMenu.Items[Id]->HelpContext
					'                 End If
					This.ClientToScreen(P)
				End If
				If (GetWindowLong(Handle,GWL_EXSTYLE) And WS_EX_CONTEXTHELP) = WS_EX_CONTEXTHELP Then
					pApp->HelpCommand(HELP_SETPOPUP_POS, CInt(@P))
					pApp->HelpCommand(HELP_CONTEXTPOPUP, ContextID)
				Else
					pApp->HelpContext(ContextID)
				End If
			End Select
		Base.ProcessMessage(msg)
			If msg.Result = 0 Then
				Select Case FFormStyle
				Case fsMDIChild
					msg.Result = -3
				Case fsMDIForm
					msg.hWnd = FClient
					msg.Result = -4
				End Select
			End If
	End Sub
	
	'David Change
	Private Sub Form.BringToFront
			'If Handle Then BringWindowToTop Handle
			'Const HWND_TOPMOST = -1
			'Const HWND_NOTOPMOST = -2
			If Handle Then SetWindowPos(Handle, HWND_TOP,0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE)' This.Left, This.Top, This.Width, This.Height, 0)
	End Sub
	
	Private Sub Form.SendToBack
			If Handle Then SetWindowPos Handle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
	End Sub
	
	Private Property Form.Visible() As Boolean
			If FHandle Then
				FVisible = IsWindowVisible(FHandle)
			End If
		Return FVisible
	End Property
	
	Private Property Form.Visible(Value As Boolean)
		FVisible = Value
		If Value Then
			Show
		Else
			Hide
		End If
	End Property
	
	Private Sub Form.ShowItems(Ctrl As Control Ptr)
	End Sub
	
	Private Sub Form.HideItems(Ctrl As Control Ptr)
	End Sub
	
	Private Sub Form.Show
			If IsIconic(Handle) Then
				ShowWindow Handle, SW_SHOWNORMAL
				'			ElseIf IsWindowVisible(Handle) Then
				'				This.SetFocus
			Else
				If Handle Then
					ShowWindow Handle, FCmdShow(FWindowState)
					If FParent Then Cast(Control Ptr, FParent)->RequestAlign
				Else
					CreateWnd
					Exit Sub
				End If
			End If
			SelectNextControl
		If OnShow Then OnShow(*Designer, This)
	End Sub
	
	Private Sub Form.Show(ByRef OwnerForm As Form)
		This.FParent = @OwnerForm
		This.Show
	End Sub
	
		Private Function Form.ShowModal(ByRef OwnerForm As Form) As Integer
			This.FParent = @OwnerForm
			CenterToParent
			Return This.ShowModal()
		End Function
		
		Private Function Form.ShowModal() As Integer
				Dim As Integer i
				Dim As Any Ptr Mtx
				FParentHandle = GetFocus()
				If IsWindowVisible(FHandle) Then
					This.SetFocus
					Exit Function
				End If
				If GetCapture <> 0 Then SendMessage(GetCapture,WM_CANCELMODE,0,0)
				'?"..." & GetCapture
				'ReleaseCapture
				For i = 0 To pApp->FormCount - 1
					pApp->Forms[i]->Enabled = False
				Next i
				Enabled = True
				Visible = True
				InShowModal = True
				Dim As MSG msg
				Dim TranslateAndDispatch As Boolean
				While GetMessage(@msg, NULL, 0, 0)
					TranslateAndDispatch = True
					If Accelerator Then TranslateAndDispatch = TranslateAccelerator(FHandle, Accelerator, @msg) = 0
					If TranslateAndDispatch Then
						Select Case msg.message
						Case WM_KEYDOWN
							Select Case msg.wParam
							Case VK_TAB ', VK_LEFT, VK_UP, VK_DOWN, VK_RIGHT, VK_PRIOR, VK_NEXT
								If Not GetFocus() = Handle Then
									SelectNextControl(GetKeyState(VK_SHIFT) And 8000)
									TranslateAndDispatch = False
								ElseIf IsDialogMessage(Handle, @msg) Then
									TranslateAndDispatch = False
								End If
							End Select
						End Select
					End If
					If TranslateAndDispatch Then
						TranslateMessage @msg
						DispatchMessage @msg
					End If
					If IsWindowVisible(FHandle) = 0 Then Exit While
				Wend
				For i = 0 To pApp->FormCount - 1
					pApp->Forms[i]->Enabled = True
				Next i
				InShowModal = False
				Visible = False
				ReleaseCapture
				'SetForegroundWindow FParentHandle
			Function = ModalResult
		End Function
	
	Private Sub Form.Hide
			If Handle Then
				If IsWindowVisible(Handle) Then
					If OnHide Then OnHide(*Designer, This)
					ShowWindow Handle, SW_HIDE
				End If
			End If
	End Sub
	
	Private Sub Form.Maximize
			If IsIconic(Handle) = 0 Then
				ShowWindow Handle, SW_MAXIMIZE
			End If
	End Sub
	
	Private Sub Form.Minimize
			If IsIconic(Handle) = 0 Then
				ShowWindow Handle, SW_MINIMIZE
			End If
	End Sub
	
	Private Sub Form.CloseForm
			If Handle Then SendMessage(Handle, WM_CLOSE, 0, 0)
	End Sub
	
	Private Sub Form.CenterToParent()
		If FParent Then
			With *Cast(Control Ptr, FParent)
					This.Move .Left + (.Width - This.Width) \ 2, .Top + (.Height - This.Height) \ 2, This.Width, This.Height
			End With
		End If
	End Sub
	
	Private Sub Form.CenterToScreen(ByVal ScrLeft As Integer = 0, ByVal ScrTop As Integer = 0, ByVal ScrWidth As Integer = 0, ByVal ScrHeight As Integer = 0)
			If ScrHeight = 0 AndAlso ScrWidth = 0 Then
				This.Left = (UnScaleX(GetSystemMetrics(SM_CXSCREEN)) - This.Width) \ 2
				This.Top  = (UnScaleY(GetSystemMetrics(SM_CYSCREEN)) - This.Height) \ 2
			Else
				This.Left = ScrLeft + (ScrWidth - This.Width) \ 2
				This.Top  = ScrTop + (ScrHeight - This.Height) \ 2
			End If
			Move This.Left, This.Top, This.Width, This.Height
	End Sub
	
	Private Function Form.EnumMenuItems(Item As MenuItem) As Boolean
		FMenuItems.Add Item
		For i As Integer = 0 To Item.Count -1
			EnumMenuItems *Item.Item(i)
		Next i
		Return True
	End Function
	
	Private Sub Form.GetMenuItems
		FMenuItems.Clear
		If This.Menu Then
				If IsMenu(This.Menu->Handle) = 0 Then Exit Sub
			For i As Integer = 0 To This.Menu->Count -1
				EnumMenuItems *This.Menu->Item(i)
			Next i
		End If
	End Sub
	
	Private Sub Form.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					'					Select Case ImageType
					'					Case 0
					'						QForm(.Ctrl->Child).ChangeStyle SS_BITMAP, True
					'						QForm(.Ctrl->Child).Perform(BM_SETIMAGE, ImageType, CInt(Sender.Bitmap.Handle))
					'					Case 1
					'						QForm(.Ctrl->Child).ChangeStyle SS_ICON, True
					'						QForm(.Ctrl->Child).Perform(BM_SETIMAGE, ImageType, CInt(Sender.Icon.Handle))
					'					Case 2
					'						QForm(.Ctrl->Child).ChangeStyle SS_ICON, True
					'						QForm(.Ctrl->Child).Perform(BM_SETIMAGE, ImageType, CInt(Sender.Icon.Handle))
					'					Case 3
					'						QForm(.Ctrl->Child).ChangeStyle SS_ENHMETAFILE, True
					'						QForm(.Ctrl->Child).Perform(BM_SETIMAGE, ImageType, CInt(0))
					'					End Select
					.Ctrl->Repaint
			End If
		End With
	End Sub
	
	Private Operator Form.Cast As Control Ptr
		Return @This
	End Operator
	
	Private Sub Form.IconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		With *Cast(Form Ptr, Sender.Graphic)
				SendMessage(.Handle, WM_SETICON, 1, CInt(.Icon.Handle))
		End With
	End Sub
	
	Private Constructor Form
			FMainStyle(0)  = 0
			FMainStyle(1)  = WS_EX_APPWINDOW
			FClassStyle(0) = CS_VREDRAW Or CS_HREDRAW Or CS_DBLCLKS
			FClassStyle(1) = CS_DBLCLKS
			FClassStyle(2) = CS_DBLCLKS Or CS_SAVEBITS Or CS_BYTEALIGNWINDOW
			FClassStyle(3) = CS_DBLCLKS
			FClassStyle(4) = CS_DBLCLKS
			FClassStyle(5) = CS_DBLCLKS
			FExStyle(0)    = WS_EX_CONTROLPARENT
			FExStyle(1)    = WS_EX_CONTROLPARENT
			FExStyle(2)    = WS_EX_CONTROLPARENT Or WS_EX_DLGMODALFRAME
			FExStyle(3)    = WS_EX_CONTROLPARENT
			FExStyle(4)    = WS_EX_CONTROLPARENT Or WS_EX_TOOLWINDOW
			FExStyle(5)    = WS_EX_CONTROLPARENT Or WS_EX_TOOLWINDOW
			FStyle(0)      = DS_CONTROL
			FStyle(1)      = WS_CAPTION Or WS_BORDER Or DS_CONTROL
			FStyle(2)      = WS_CAPTION Or WS_BORDER Or WS_SYSMENU
			FStyle(3)      = WS_OVERLAPPEDWINDOW
			FStyle(4)      = WS_CAPTION Or WS_BORDER Or WS_SYSMENU
			FStyle(5)      = WS_CAPTION Or WS_THICKFRAME Or WS_SYSMENU
			FChild(0) = 0
			FChild(1) = WS_CHILD
			FCmdShow(0) = SW_HIDE
			FCmdShow(1) = SW_SHOWNORMAL
			FCmdShow(2) = SW_SHOWMAXIMIZED
			FCmdShow(3) = SW_SHOWMINIMIZED
			xdpi = 0
			ydpi = 0
			This.RegisterClass "Form"
		Text = "Form"
		FBorderStyle   = 3
		FWindowState   = 1
		FControlBox = True
		FMinimizeBox = True
		FMaximizeBox = True
		FShowInTaskbar = True
		FOpacity = 255
		FTransparentColor = -1
		Canvas.Ctrl    = @This
		Graphic.Ctrl = @This
		Graphic.OnChange = @GraphicChange
		Icon.Graphic = @This
		Icon.Changed = @IconChanged
		With This
			.Child             = @This
				.ChildProc         = @WNDPROC
			WLet(FClassName, "Form")
			.OnActiveControlChanged = @ActiveControlChanged
				.ExStyle           = WS_EX_CONTROLPARENT Or WS_EX_WINDOWEDGE 'FExStyle(FBorderStyle) OR FMainStyle(FMainForm)
				.Style             = WS_CAPTION Or WS_SYSMENU Or WS_MINIMIZEBOX Or WS_MAXIMIZEBOX Or WS_THICKFRAME Or WS_DLGFRAME Or WS_BORDER 'FStyle(FBorderStyle) Or FChild(Abs_(FIsChild))
				.BackColor             = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
				.OnHandleIsAllocated = @HandleIsAllocated
				.Width             = 350 'CW_USEDEFAULT
				.Height            = 300 'CW_USEDEFAULT
				WLet(FClassAncestor, "")
			.StartPosition = DefaultLocation
		End With
		If pApp->MainForm = 0 Then
			pApp->MainForm = @This
			FMainForm = True
			
		End If
	End Constructor
	
	Private Destructor Form
		'		If OnFree Then OnFree(This)
		This.Menu = 0
		FMenuItems.Clear
			If Accelerator Then DestroyAcceleratorTable(Accelerator)
		'UnregisterClass ClassName, GetModuleHandle(NULL)
	End Destructor
End Namespace
