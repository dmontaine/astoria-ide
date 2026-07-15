'################################################################################
'#  ToolTips.bi                                                                 #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
'################################################################################

#include once "ToolTips.bi"

Namespace My.Sys.Forms
		Sub ToolTips.HandleIsAllocated(ByRef Sender As Control)
			With QToolTips(@Sender)
				
			End With
		End Sub
		
		Sub ToolTips.WNDPROC(ByRef Message As Message)
		End Sub
		
		Sub ToolTips.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_NOTIFY
				Dim As LPNMHDR LP = Cast(LPNMHDR, Message.lParam)
				Select Case LP->code
				Case TTN_LINKCLICK
					Dim As PNMLINK pNMLink1 = Cast(PNMLINK, Message.lParam)
					Dim As LITEM item = pNMLink1->item
					If OnLinkClicked Then OnLinkClicked(*Designer, This, item.szUrl)
				End Select
			Case WM_MOUSEMOVE
				Message.Result = -1
				Return
			End Select
			Base.ProcessMessage(Message)
		End Sub
		
		Private Sub ToolTips.CreateWnd
			Base.CreateWnd
			If Parent AndAlso Parent->Handle Then
				Dim As TOOLINFO    ti
				ZeroMemory(@ti, SizeOf(ti))
				
				ti.cbSize = SizeOf(ti)
				ti.hwnd   = Parent->Handle
				'ti.uId    = Cast(UINT, FHandle)
			
				'FHandle = CreateWindowW(TOOLTIPS_CLASS, "", WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, Cast(HMENU, NULL), GetModuleHandle(NULL), NULL)
				ti.uFlags = TTF_IDISHWND Or TTF_TRACK Or TTF_ABSOLUTE Or TTF_PARSELINKS Or TTF_TRANSPARENT
				ti.hinst  = GetModuleHandle(NULL)
				ti.lpszText  = FText.vptr
				
				SendMessage(FHandle, TTM_ADDTOOL, 0, Cast(LPARAM, @ti))
			End If
		End Sub
	
	Private Sub ToolTips.Show
		If FText = "" Then FText = " "
			Dim As TOOLINFO    ti
			ZeroMemory(@ti, SizeOf(ti))
			
			ti.cbSize = SizeOf(ti)
			ti.hwnd   = Parent->Handle
			'ti.uId    = Cast(UINT, FHandle)
			
			If FHandle = 0 Then
				CreateWnd
				'FHandle = CreateWindowW(TOOLTIPS_CLASS, "", WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, Cast(HMENU, NULL), GetModuleHandle(NULL), NULL)
				ti.uFlags = TTF_IDISHWND Or TTF_TRACK Or TTF_ABSOLUTE Or TTF_PARSELINKS Or TTF_TRANSPARENT
				ti.hinst  = GetModuleHandle(NULL)
				ti.lpszText  = FText.vptr
				
				SendMessage(FHandle, TTM_ADDTOOL, 0, Cast(LPARAM, @ti))
			Else
				SendMessage(FHandle, TTM_GETTOOLINFO, 0, CInt(@ti))
				
				ti.lpszText = FText.vptr
				
				SendMessage(FHandle, TTM_UPDATETIPTEXT, 0, CInt(@ti))
			End If
			
			SendMessage(FHandle, TTM_SETMAXTIPWIDTH, 0, 1000)
			SendMessage(FHandle, TTM_TRACKACTIVATE, True, Cast(LPARAM, @ti))
			
			Var Result = SendMessage(FHandle, TTM_GETBUBBLESIZE, 0, Cast(LPARAM, @ti))
			
			Dim As ..Rect rc
			.ClientToScreen(Parent->Handle, Cast(..Point Ptr, @rc))
			SendMessage(FHandle, TTM_TRACKPOSITION, 0, MAKELPARAM(rc.Left + FLeft, rc.Top + FTop))
	End Sub
	
	Private Sub ToolTips.Hide
			If Parent AndAlso Parent->Handle Then
				Dim As TOOLINFO    ti
				ZeroMemory(@ti, SizeOf(ti))
				
				ti.cbSize = SizeOf(ti)
				ti.hwnd   = Parent->Handle
				'ti.uId    = Cast(UINT, FHandle)
				
				SendMessage(FHandle, TTM_TRACKACTIVATE, False, Cast(LPARAM, @ti))
			End If
	End Sub
	
	Private Operator ToolTips.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ToolTips
		With This
			WLet(FClassName, "ToolTips")
			WLet(FClassAncestor, "tooltips_class32")
				.RegisterClass "ToolTips", "tooltips_class32"
				.Style        = WS_POPUP
				.ExStyle      = 0 'WS_EX_TOPMOST
				.ChildProc    = @WNDPROC
				.OnHandleIsAllocated = @HandleIsAllocated
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor ToolTips
			'UnregisterClass "ToolTips", GetModuleHandle(NULL)
	End Destructor
End Namespace

