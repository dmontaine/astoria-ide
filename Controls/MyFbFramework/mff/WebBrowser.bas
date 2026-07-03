'################################################################################
'#  WebBrowser.bas                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2023)                                     #
'################################################################################

#include once "WebBrowser.bi"

Namespace My.Sys.Forms
		Private Function WebBrowser.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function WebBrowser.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property WebBrowser.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property WebBrowser.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property WebBrowser.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property WebBrowser.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub WebBrowser.Navigate(ByVal URL As WString Ptr)
				Dim vUrl As VARIANT: vUrl.vt = VT_BSTR : vUrl.bstrVal = SysAllocString(URL)
				g_IWebBrowser->Navigate2(Cast(IWebBrowser2 Ptr, pIWebBrowser), @vUrl, NULL, NULL, NULL, NULL)
				VariantClear(@vUrl)
	End Sub
	
	Private Sub WebBrowser.GoForward()
				g_IWebBrowser->GoForward(Cast(IWebBrowser2 Ptr, pIWebBrowser))
	End Sub
	
	Private Sub WebBrowser.GoBack()
				g_IWebBrowser->GoBack(Cast(IWebBrowser2 Ptr, pIWebBrowser))
	End Sub
	
	Private Sub WebBrowser.Refresh()
				g_IWebBrowser->Refresh(Cast(IWebBrowser2 Ptr, pIWebBrowser))
	End Sub
	
	Private Function WebBrowser.GetURL() As UString
		Dim As UString sRet
		Dim As WString Ptr buf = sRet.vptr
				g_IWebBrowser->get_LocationURL(Cast(IWebBrowser2 Ptr, pIWebBrowser), @buf)
				Return *buf
	End Function
	
	Private Function WebBrowser.State() As Integer
		Dim iState As Integer
				g_IWebBrowser->get_Busy(Cast(IWebBrowser2 Ptr, pIWebBrowser), Cast(VARIANT_BOOL Ptr, @iState))
		Return iState
	End Function
	
	Private Sub WebBrowser.Stop()
				g_IWebBrowser->Stop(Cast(IWebBrowser2 Ptr, pIWebBrowser))
	End Sub
	
	Private Function WebBrowser.GetBody(ByVal flag As Long = 0) As UString
				Dim tText As WString Ptr
				Dim As IHTMLDocument2 Ptr htmldoc2
				Dim As IDispatch Ptr doc
				g_IWebBrowser->get_Document(Cast(IWebBrowser2 Ptr, pIWebBrowser), @doc)
				Function = ""
				If doc > 0 AndAlso (doc->lpVtbl->QueryInterface(doc, @IID_IHTMLDocument2, Cast(PVOID Ptr, @htmldoc2)) = S_OK) Then
					If htmldoc2 Then
						Dim As IHTMLElement Ptr BODY
						htmldoc2->lpVtbl->get_body(htmldoc2, @BODY)
						If BODY > 0 Then
							Select Case flag
							Case 0
								BODY->lpVtbl->get_innerHTML(BODY, @tText)
							Case 1
								BODY->lpVtbl->get_outerHTML(BODY, @tText)
							Case 2
								BODY->lpVtbl->get_innerText(BODY, @tText)
							Case 3
								BODY->lpVtbl->get_outerText(BODY, @tText)
							End Select
							Function = *tText
							BODY->lpVtbl->Release(BODY)
						End If
						htmldoc2->lpVtbl->Release(htmldoc2)
					End If
					doc->lpVtbl->Release(doc)
				End If
				_Deallocate(tText)
	End Function
	
	Private Function WebBrowser.ExecuteScript(ByRef JavaScript As WString, bWait As Boolean = False) ByRef As WString
		If Trim(JavaScript) = "" Then Return WStr("")
		WLet(ScriptResult,"")
		Return *ScriptResult
	End Function
	
	Private Sub WebBrowser.SetBody(ByRef tText As WString, ByVal flag As Long = 0)
				Dim As IHTMLDocument2 Ptr htmldoc2
				Dim As IDispatch Ptr doc
				g_IWebBrowser->get_Document(Cast(IWebBrowser2 Ptr, pIWebBrowser), @doc)
				If doc > 0 AndAlso (doc->lpVtbl->QueryInterface(doc, @IID_IHTMLDocument2, Cast(PVOID Ptr, @htmldoc2)) = S_OK) Then
					If htmldoc2 Then
						Dim As IHTMLElement Ptr BODY
						htmldoc2->lpVtbl->get_body(htmldoc2, @BODY)
						If BODY > 0 Then
							Select Case flag
							Case 0
								BODY->lpVtbl->put_innerHTML(BODY, @tText)
							Case 1
								BODY->lpVtbl->put_outerHTML(BODY, @tText)
							Case 2
								BODY->lpVtbl->put_innerText(BODY, @tText)
							Case 3
								BODY->lpVtbl->put_outerText(BODY, @tText)
							End Select
							BODY->lpVtbl->Release(BODY)
						End If
						htmldoc2->lpVtbl->Release(htmldoc2)
					End If
					doc->lpVtbl->Release(doc)
				End If
	End Sub
	
		
		Private Property NewWindowRequestedEventArgs.Handled() As Boolean
				Return False
		End Property
		
		Private Property NewWindowRequestedEventArgs.Handled(Value As Boolean)
		End Property
		
		Private Function NewWindowRequestedEventArgs.GetIsUserInitiated() As Boolean
				Return False
		End Function
		
		Private Function NewWindowRequestedEventArgs.GetURL() ByRef As WString
				Return ""
		End Function
		
		Private Sub WebBrowser.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			If Sender Then
				With QWebBrowser(Sender.Child)
						Dim i As Integer
						Dim AtlAxWinInit As Function As Boolean
						Dim AtlAxGetControl As Function(ByVal hWin As HWND, ByRef pp As Integer Ptr) As Integer
						Dim iIUnknown As Integer
						Dim pIUnknown As Integer Ptr = @iIUnknown
						Dim IUnknown1 As IUnknownVtbl Ptr
						If .hWebBrowser <> 0 Then
							AtlAxGetControl = Cast(Any Ptr, GetProcAddress(.hWebBrowser, "AtlAxGetControl"))
							If AtlAxGetControl <> 0 Then
								AtlAxGetControl(.FHandle, pIUnknown)
								If pIUnknown <> 0 AndAlso *pIUnknown <> 0 Then
									IUnknown1 = Cast(IUnknownVtbl Ptr, *pIUnknown)
									i = IUnknown1->AddRef(Cast(IUnknown Ptr, pIUnknown))
									i = IUnknown1->QueryInterface(Cast(IUnknown Ptr, pIUnknown), @IID_IWebBrowser2, @.pIWebBrowser)
									.g_IWebBrowser = Cast(IWebBrowser2Vtbl Ptr, *(.pIWebBrowser))
									i = .g_IWebBrowser->AddRef(Cast(IWebBrowser2 Ptr, .pIWebBrowser))
									i = IUnknown1->Release(Cast(IUnknown Ptr, pIUnknown))
								End If
							End If
						End If
				End With
			End If
		End Sub
		
		Private Sub WebBrowser.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub WebBrowser.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator WebBrowser.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	Private Constructor WebBrowser
		With This
			WLet(FClassName, "WebBrowser")
			FText = "about:blank"
			FTabIndex          = -1
			FTabStop           = True
					hWebBrowser = LoadLibrary("atl.dll")
					If hWebBrowser Then
						Dim AtlAxWinInit As Function As Boolean
						AtlAxWinInit = Cast(Any Ptr, GetProcAddress(hWebBrowser, "AtlAxWinInit"))
						If AtlAxWinInit Then
							AtlAxWinInit()
							.RegisterClass "WebBrowser", "AtlAxWin"
						End If
						WLet(.FClassAncestor, "AtlAxWin")
					End If
					.Style        = WS_CHILD Or WS_VSCROLL Or WS_HSCROLL
				.ExStyle      = WS_EX_CLIENTEDGE
				.ChildProc    = @WndProc
				.OnHandleIsAllocated = @HandleIsAllocated
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor WebBrowser
			'This.Stop()
				If g_IWebBrowser Then g_IWebBrowser->Quit(Cast(IWebBrowser2 Ptr, pIWebBrowser))
				DestroyWindow FHandle
				FHandle = 0
				FreeLibrary(hWebBrowser)
				'UnregisterClass "WebBrowser", GetModuleHandle(NULL)
	End Destructor
End Namespace

