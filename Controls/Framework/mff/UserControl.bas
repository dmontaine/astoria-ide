'################################################################################
'#  UserControl.bi                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov                                                 #
'################################################################################

#include once "UserControl.bi"
'#Include Once "Canvas.bi"

Namespace My.Sys.Forms
		Private Sub UserControl.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QUserControl(Sender.Child)
				End With
			End If
		End Sub
		
		Private Sub UserControl.WndProc(ByRef Message As Message)
		End Sub
	Private Sub UserControl.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_PAINT
				Dim As HDC Dc
				Dim As PAINTSTRUCT Ps
				Dc = BeginPaint(Handle, @Ps)
				Canvas.SetHandle Dc
				FillRect Dc, @Ps.rcPaint, Brush.Handle
				If OnPaint Then OnPaint(*Designer, This, Canvas)
				Canvas.UnSetHandle
				EndPaint Handle, @Ps
				Message.Result = 0
				Return
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator UserControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor UserControl
		With This
			Canvas.Ctrl    = @This
			.Child       = @This
				.RegisterClass "UserControl"
				.ChildProc   = @WndProc
				.ExStyle     = 0
				.Style       = WS_CHILD
				.BackColor       = GetSysColor(COLOR_BTNFACE)
				.OnHandleIsAllocated = @HandleIsAllocated
			WLet(FClassName, "UserControl")
			.Width       = 121
			.Height      = 41
		End With
	End Constructor
	
	Private Destructor UserControl
			UnregisterClass "UserControl", GetModuleHandle(NULL)
	End Destructor
End Namespace

