'###############################################################################
'#  HotKey.bi                                                                  #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'###############################################################################

#include once "HotKey.bi"

Namespace My.Sys.Forms
		Private Function HotKey.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "text": Text: Return FText.vptr
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function HotKey.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "text": This.Text = QWString(Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property HotKey.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property HotKey.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property HotKey.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property HotKey.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
		Private Sub HotKey.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			If Sender.Child Then
				With QHotKey(Sender.Child)
					
				End With
			End If
		End Sub
		
		Private Sub HotKey.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub HotKey.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_COMMAND
				Select Case Message.wParamHi
				Case EN_CHANGE
					If OnChange Then OnChange(*Designer, This)
				End Select
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Property HotKey.Text ByRef As WString
			Dim wHotKey As WORD
			wHotKey = SendMessage(Handle, HKM_GETHOTKEY, 0, 0)
			FText = GetChrKeyCode(LoByte(LoWord(wHotKey)))
			If (HiByte(LoWord(wHotKey)) And HOTKEYF_SHIFT) = HOTKEYF_SHIFT Then FText = "Shift+" & FText
			If (HiByte(LoWord(wHotKey)) And HOTKEYF_ALT) = HOTKEYF_ALT Then FText = "Alt+" & FText
			If (HiByte(LoWord(wHotKey)) And HOTKEYF_CONTROL) = HOTKEYF_CONTROL Then FText = "Ctrl+" & FText
		Return *FText.vptr
	End Property
	
	Private Property HotKey.Text(ByRef Value As WString)
		FText = Value
			Dim sKey As String = Value
			Dim wHotKey As WORD
			Var Pos1 = InStrRev(sKey, "+")
			If Pos1 > 0 Then sKey = Mid(sKey, Pos1 + 1)
			wHotKey = MAKEWORD(GetAscKeyCode(sKey), IIf(InStr(Value, "Ctrl") > 0, HOTKEYF_CONTROL, 0) Or IIf(InStr(Value, "Shift") > 0, HOTKEYF_SHIFT, 0) Or IIf(InStr(Value, "Alt") > 0, HOTKEYF_ALT, 0))
			SendMessage(Handle, HKM_SETHOTKEY, wHotKey, 0)
	End Property
	
	Private Operator HotKey.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	
	Private Constructor HotKey
		With This
			WLet(FClassName, "HotKey")
			WLet(FClassAncestor, "msctls_hotkey32")
			FTabIndex          = -1
			FTabStop           = True
				.RegisterClass "HotKey","msctls_hotkey32"
				.Style        = WS_CHILD
				.ExStyle      = 0
				.ChildProc    = @WndProc
				.OnHandleIsAllocated = @HandleIsAllocated
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor HotKey
			UnregisterClass "HotKey", GetModuleHandle(NULL)
	End Destructor
End Namespace

