'################################################################################
'#  NotifyIcon.bas                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2025)                                          #
'################################################################################

#include once "NotifyIcon.bi"
	Const WM_SHELLNOTIFY = WM_USER + 5

Namespace My.Sys.Forms
		Private Function NotifyIcon.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "balloontipicon": Return @BalloonTipIcon
			Case "balloontipicontype": Return @FBalloonTipIconType
			Case "balloontiptext": Return FBalloonTipText.vptr
			Case "balloontiptitle": Return FBalloonTipTitle.vptr
			Case "contextmenu": Return ContextMenu
			Case "icon": Return @Icon
			Case "text": Return FText.vptr
			Case "visible": Return @FVisible
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function NotifyIcon.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value <> 0 Then
				Select Case LCase(PropertyName)
				Case "balloontipicon": This.BalloonTipIcon = QWString(Value)
				Case "balloontipicontype": This.BalloonTipIconType = *Cast(ToolTipIconType Ptr, Value)
				Case "balloontiptext": This.BalloonTipText = QWString(Value)
				Case "balloontiptitle": This.BalloonTipTitle = QWString(Value)
				Case "contextmenu": This.ContextMenu = QPopupMenu(Value)
				Case "icon": This.Icon = QWString(Value)
				Case "text": This.Text = QWString(Value)
				Case "visible": This.Visible = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property NotifyIcon.BalloonTipIconType As ToolTipIconType
		Return FBalloonTipIconType
	End Property
	
		Private Sub NotifyIcon.ChangeStyle(ByRef Style As DWORD, iStyle As Integer, Value As Boolean)
			If Value Then
				If ((Style And iStyle) <> iStyle) Then Style = Style Or iStyle
			ElseIf ((Style And iStyle) = iStyle) Then
				Style = Style And Not iStyle
			End If
		End Sub
	
	Private Property NotifyIcon.BalloonTipIconType(Value As ToolTipIconType)
		FBalloonTipIconType = Value
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_NONE, False
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_INFO, False
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_WARNING, False
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_ERROR, False
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_USER, False
			Select Case FBalloonTipIconType
			Case ToolTipIconType.None: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_NONE, True
			Case ToolTipIconType.Info: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_INFO, True
			Case ToolTipIconType.Warning: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_WARNING, True
			Case ToolTipIconType.Error: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_ERROR, True
			Case ToolTipIconType.User: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_USER, True
			End Select
	End Property
	
	Private Property NotifyIcon.BalloonTipText ByRef As WString
		Return *FBalloonTipText.vptr
	End Property
	
	Private Property NotifyIcon.BalloonTipText(ByRef Value As WString)
		FBalloonTipText = Value
			FNotifyIconData.szInfo = Value
	End Property
	
	Private Property NotifyIcon.BalloonTipTitle ByRef As WString
		Return *FBalloonTipTitle.vptr
	End Property
	
	Private Property NotifyIcon.BalloonTipTitle(ByRef Value As WString)
		FBalloonTipTitle = Value
			FNotifyIconData.szInfoTitle = Value
	End Property
	
	Private Property NotifyIcon.Text ByRef As WString
		Return *FText.vptr
	End Property
	
	Private Property NotifyIcon.Text(ByRef Value As WString)
		FText = Value
			FNotifyIconData.szTip = Value
	End Property
	
	Private Property NotifyIcon.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property NotifyIcon.Visible(Value As Boolean)
		'If FVisible <> Value Then
		FVisible = Value
		If Not FDesignMode Then
				If Value Then
					If FParent AndAlso FParent->FHandle Then
						FNotifyIconData.hWnd = FParent->FHandle
						Shell_NotifyIcon(NIM_ADD, Cast(PNOTIFYICONDATA, @FNotifyIconData))
					End If
				Else
					Shell_NotifyIcon(NIM_DELETE, Cast(PNOTIFYICONDATA, @FNotifyIconData))
				End If
		End If
		'End If
	End Property
	
	Private Sub NotifyIcon.IconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		With *Cast(NotifyIcon Ptr, Sender.Graphic)
				.FNotifyIconData.hIcon = Sender.Handle
		End With
	End Sub
	
	Private Sub NotifyIcon.BalloonTipIconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		With *Cast(NotifyIcon Ptr, Sender.Graphic)
				.FNotifyIconData.hBalloonIcon = Sender.Handle
		End With
	End Sub
	
	Private Sub NotifyIcon.ShowBalloonTip(timeout As Integer)
			FNotifyIconData.uFlags = NIF_INFO
			FNotifyIconData.uTimeout = timeout
			
			Shell_NotifyIcon(NIM_MODIFY, Cast(PNOTIFYICONDATA, @FNotifyIconData))
	End Sub
	
	Private Sub NotifyIcon.ShowBalloonTip(timeout As Integer, ByRef tipTitle As WString, ByRef tipText As WString, tipIconType As ToolTipIconType, tipIcon As My.Sys.Drawing.Icon Ptr = 0)
			FNotifyIconData.uFlags = NIF_INFO
			FNotifyIconData.szInfoTitle = tipTitle
			FNotifyIconData.szInfo = tipText
			FNotifyIconData.uTimeout = timeout
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_NONE, False
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_INFO, False
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_WARNING, False
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_ERROR, False
			ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_USER, False
			Select Case tipIconType
			Case ToolTipIconType.None: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_NONE, True
			Case ToolTipIconType.Info: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_INFO, True
			Case ToolTipIconType.Warning: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_WARNING, True
			Case ToolTipIconType.Error: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_ERROR, True
			Case ToolTipIconType.User: ChangeStyle FNotifyIconData.dwInfoFlags, NIIF_USER, True
			End Select
			If tipIcon Then FNotifyIconData.hBalloonIcon = tipIcon->Handle
			
			Shell_NotifyIcon(NIM_MODIFY, Cast(PNOTIFYICONDATA, @FNotifyIconData))
	End Sub
	
	Function NotifyIcon.IsWindowsVistaOrHigher() As Boolean
			Dim As OSVERSIONINFOEX osvi
			osvi.dwOSVersionInfoSize = SizeOf(OSVERSIONINFOEX)
			
			If GetVersionEx(Cast(OSVERSIONINFO Ptr, @osvi)) = 0 Then Return False
			Return (osvi.dwMajorVersion > 6) Or (osvi.dwMajorVersion = 6 And osvi.dwMinorVersion >= 0)
	End Function
	
	Private Constructor NotifyIcon
		WLet(FClassName, "NotifyIcon")
		Icon.Graphic = @This
		Icon.Changed = @IconChanged
		BalloonTipIcon.Graphic = @This
		BalloonTipIcon.Changed = @BalloonTipIconChanged
			With FNotifyIconData
				If IsWindowsVistaOrHigher Then
					.cbSize = SizeOf (NOTIFYICONDATANEW)
				Else
					.cbSize = SizeOf (NOTIFYICONDATA)
				End If
				Handles.Add @This
				.uID  = 1000 + Handles.Count - 1
				.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
				.uCallbackMessage = WM_SHELLNOTIFY
				.szTip = ""
				.uVersion = NOTIFYICON_VERSION
			End With
	End Constructor
	
	Private Destructor NotifyIcon
			If FVisible Then Shell_NotifyIcon(NIM_DELETE, Cast(PNOTIFYICONDATA, @FNotifyIconData))
	End Destructor
End Namespace

