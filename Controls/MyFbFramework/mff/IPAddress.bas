'###############################################################################
'#  IPAddress.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "IPAddress.bi"

Namespace My.Sys.Forms
		Private Function IPAddress.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case "text": Text: Return FText.vptr
			Case "onchange": Return OnChange
			Case "onfieldchanged": Return OnFieldChanged
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function IPAddress.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "tabindex": TabIndex = QInteger(Value)
			Case "text": Text = QWString(Value)
			Case "onchange": OnChange = Value
			Case "onfieldchanged": OnFieldChanged = Value
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property IPAddress.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property IPAddress.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property IPAddress.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property IPAddress.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub IPAddress.Clear
			SendMessage FHandle, IPM_CLEARADDRESS, 0, 0
	End Sub
	
	Private Property IPAddress.Text ByRef As WString
			Return Base.Text
	End Property
	
	Private Property IPAddress.Text(ByRef Value As WString)
		FText = Value
		If Value = "" Then
			This.Clear
		Else
			Dim res(Any) As UString, Addresses(3) As Integer
			Split(Value, ".", res())
			For i As Integer = 0 To 3
				If UBound(res) >= i Then
					Addresses(i) = Max(0, Min(Val(res(i)), 255))
				End If
			Next
				SendMessage FHandle, IPM_SETADDRESS, 0, MAKEIPADDRESS(Addresses(0), Addresses(1), Addresses(2), Addresses(3))
		End If
	End Property
	
		Private Sub IPAddress.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			With *Cast(IPAddress Ptr, @Sender)
				.Text = .FText
			End With
		End Sub
		
		Private Sub IPAddress.WndProc(ByRef Message As Message)
		End Sub
		
		Private Function IPAddress.IPAddressWndProc(FWindow As HWND, Msg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			Dim As IPAddress Ptr Ctrl
			Dim Message As Message
			Ctrl = GetProp(FWindow, "MFFControl")
			Message = Type(Ctrl, FWindow, Msg, wParam, lParam, 0, LoWord(wParam), HiWord(wParam), LoWord(lParam), HiWord(lParam), Message.Captured)
			If Ctrl Then
				With *Ctrl
					If Ctrl->ClassName <> "" Then
						.ProcessMessage(Message)
						If Message.Handled Then
							Return Message.Result
						ElseIf Message.Result = -1 Then
							Return Message.Result
						ElseIf Message.Result = -2 Then
							Msg = Message.Msg
							wParam = Message.wParam
							lParam = Message.lParam
						ElseIf Message.Result <> 0 Then
							Return Message.Result
						End If
					End If
				End With
			End If
			Dim As Any Ptr cp = GetClassProc(FWindow)
			If cp <> 0 Then
				Message.Result = CallWindowProc(cp, FWindow, Msg, wParam, lParam)
			End If
			Return Message.Result
		End Function
	
	Private Sub IPAddress.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_COMMAND
				Select Case Message.wParamHi
				Case EN_CHANGE
					If OnChange Then OnChange(*Designer, This)
				Case EN_KILLFOCUS
					If OnLostFocus Then OnLostFocus(*Designer, This)
				Case EN_SETFOCUS
					If OnGotFocus Then OnGotFocus(*Designer, This)
				End Select
				Message.Result = 0
			Case CM_NOTIFY
				Dim lpnmipa As NMIPADDRESS Ptr = Cast(NMIPADDRESS Ptr, Message.lParam)
				Select Case lpnmipa->hdr.code
				Case IPN_FIELDCHANGED
					If OnFieldChanged Then OnFieldChanged(*Designer, This, lpnmipa->iField, lpnmipa->iValue)
				End Select
			End Select
		Base.ProcessMessage Message
	End Sub
	
	Private Operator IPAddress.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	
	Private Constructor IPAddress
			Dim As INITCOMMONCONTROLSEX icex
			
			icex.dwSize = SizeOf(INITCOMMONCONTROLSEX)
			icex.dwICC =  ICC_INTERNET_CLASSES
			
			InitCommonControlsEx(@icex)
		
		With This
			WLet(FClassName, "IPAddress")
			FTabIndex          = -1
			FTabStop           = True
				.RegisterClass "IPAddress", WC_IPADDRESS, @IPAddressWndProc
				WLet(FClassAncestor, WC_IPADDRESS)
				.ExStyle      = 0
				.Style        = WS_CHILD
				.ChildProc    = @WndProc
				.OnHandleIsAllocated = @HandleIsAllocated
			.Width        = 150
			.Height       = 20
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor IPAddress
			Handle = 0
			UnregisterClass "IPAddress", GetModuleHandle(NULL)
	End Destructor
End Namespace

