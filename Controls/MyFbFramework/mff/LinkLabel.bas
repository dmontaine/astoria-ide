'###############################################################################
'#  LinkLabel.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "LinkLabel.bi"

Namespace My.Sys.Forms
		Private Function LinkLabel.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case "text": Return FText.vptr
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function LinkLabel.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "tabindex": TabIndex = QInteger(Value)
			Case "text": Text = QWString(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property LinkLabel.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property LinkLabel.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property LinkLabel.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property LinkLabel.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property LinkLabel.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property LinkLabel.Text(ByRef Value As WString)
		Base.Text = Value
	End Property
	
		Private Sub LinkLabel.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			If Sender.Child Then
				With QLinkLabel(Sender.Child)
					
				End With
			End If
		End Sub
		
		Private Sub LinkLabel.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub LinkLabel.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_ERASEBKGND 'WM_PAINT, WM_ERASEBKGND
				If Not FCreated Then
					FCreated = True
					UpdateWindow Message.hWnd
					Message.Result = -1
					Return
				End If
			Case CM_NOTIFY
				Select Case Cast(LPNMHDR, Message.lParam)->code
				Case NM_CLICK, NM_RETURN
					Dim As PNMLINK pNMLink1 = Cast(PNMLINK, Message.lParam)
					Dim As LITEM item = pNMLink1->item
					Dim As Integer Action = 1
					If OnLinkClicked Then OnLinkClicked(*Designer, This, item.iLink, item.szUrl, Action)
					If Action = 1 AndAlso item.szUrl <> "" Then
						ShellExecute(NULL, "open", item.szUrl, NULL, NULL, SW_SHOW)
					End If
				End Select
			End Select
		Base.ProcessMessage Message
	End Sub
	
	
	Private Operator LinkLabel.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	Private Constructor LinkLabel
		With This
			WLet(FClassName, "LinkLabel")
				.RegisterClass "LinkLabel", WC_LINK
				WLet(FClassAncestor, WC_LINK)
				.ExStyle      = 0
				.Style        = WS_CHILD
				.ChildProc    = @WndProc
				.OnHandleIsAllocated = @HandleIsAllocated
			FTabIndex          = -1
			.Width        = 100
			.Height       = 32
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor LinkLabel
			UnregisterClass "LinkLabel", GetModuleHandle(NULL)
	End Destructor
End Namespace

