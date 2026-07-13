#include once "HTTP.bi"
	#include once "win/wininet.bi"

Namespace My.Sys.Forms
		Private Function HTTPConnection.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "host": Return Cast(Any Ptr, StrPtr(This.Host))
			Case "port": Return Cast(Any Ptr, @This.Port)
			Case "timeout" : Return Cast(Any Ptr, @This.Timeout)
			Case "useragent": Return Cast(Any Ptr, StrPtr(This.UserAgent))
			Case "maxresponsesize": Return Cast(Any Ptr, @This.MaxResponseSize)
			Case "abort" : Return @FAbort
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function HTTPConnection.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "host": This.Host = *Cast(ZString Ptr, Value)
			Case "port": This.Port = QInteger(Value)
			Case "timeout" : This.Timeout = QInteger(Value)
			Case "useragent": This.UserAgent = *Cast(ZString Ptr, Value)
			Case "maxresponsesize": This.MaxResponseSize = QInteger(Value)
			Case "abort" : This.Abort = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	Private Property HTTPConnection.Abort As Boolean
		Return FAbort
	End Property
	
	Private Property HTTPConnection.Abort(Value As Boolean)
		FAbort = Value
	End Property
	
	Private Sub HTTPConnection.CallMethod(HTTPMethod As String, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
		FAbort = False
			Dim As HINTERNET hSession, hConnect, hRequest
			Dim As Boolean hSendRequest
			Dim As String result
			
			hSession = InternetOpen(This.UserAgent, INTERNET_OPEN_TYPE_DIRECT, "", "", 0)
			If hSession = 0 Then
				Responce.StatusCode= 405
				Responce.Body = "{""Error"":{""Message"":""FAILED To Open Internet session"",""code"":405}}"
				If OnReceive Then OnReceive(*Designer, This, Request, Responce.Body)
				If OnComplete Then OnComplete(*Designer, This, Request, Responce)
				Return
			End If
			'CONNECT_TIMEOUT
			InternetSetOption(hSession, INTERNET_OPTION_CONNECT_TIMEOUT, @Timeout, SizeOf(Timeout))
			' RECEIVE_TIMEOUT
			InternetSetOption(hSession, INTERNET_OPTION_RECEIVE_TIMEOUT, @Timeout, SizeOf(Timeout))
			' SEND_TIMEOUT
			InternetSetOption(hSession, INTERNET_OPTION_SEND_TIMEOUT, @Timeout, SizeOf(Timeout))
			
			'hConnect = InternetOpenUrl(hSession, "http" & IIf(Port = 80, "", "s") & "://" & Host & IIf(Port = 80 OrElse Port = 443, "", ":" & Trim(Str(Port))), "", 0, INTERNET_FLAG_RELOAD, 0)
			hConnect = InternetConnect(hSession, Host, IIf(Port = 80, INTERNET_DEFAULT_HTTP_PORT, INTERNET_DEFAULT_HTTPS_PORT), NULL, NULL, INTERNET_SERVICE_HTTP, 0, 0)
			If hConnect = 0 Then
				Responce.StatusCode= 406
				Responce.Body = "{""error"":{""message"":""Failed to open URL"",""code"":406}}"
				If OnReceive Then OnReceive(*Designer, This, Request, Responce.Body)
				If OnComplete Then OnComplete(*Designer, This, Request, Responce)
				InternetCloseHandle(hSession)
				Return
			End If
			
			hRequest = HttpOpenRequest(hConnect, HTTPMethod, "/" & Request.ResourceAddress, NULL, NULL, NULL, IIf(Port = 80, INTERNET_FLAG_RELOAD Or INTERNET_FLAG_NO_CACHE_WRITE, INTERNET_FLAG_SECURE Or INTERNET_FLAG_RELOAD Or INTERNET_FLAG_NO_CACHE_WRITE), 0)
			If hRequest = 0 Then
				Responce.StatusCode= 407
				Responce.Body = "{""error"":{""message"":""Failed to open request"",""code"":407}}"
				If OnReceive Then OnReceive(*Designer, This, Request, Responce.Body)
				If OnComplete Then OnComplete(*Designer, This, Request, Responce)
				InternetCloseHandle(hConnect)
				InternetCloseHandle(hSession)
				Return
			End If
			
			' Send request with retry logic
			'' AstoriaIDE T-SON-2 (F-N7): this Sleep(1000) x up to 3 runs on the CALLING thread --
			'' CallMethod blocks for up to 3 seconds on a failing send. If called from the UI thread
			'' that freezes the UI for up to 3s; ThreadsEnter/ThreadsLeave provide no protection
			'' either way (they're no-ops -- see T-OPUS-1 / Component.bas). Callers that can't
			'' tolerate a multi-second block should invoke CallMethod from a worker thread.
			Dim retryCount As Integer = 0
			Do While retryCount < 3
				hSendRequest = HttpSendRequest(hRequest, Request.Headers, Len(Request.Headers), Cast(LPVOID, StrPtr(Request.Body)), Len(Request.Body))
				If hSendRequest Then Exit Do
				retryCount += 1
				Sleep(1000)
			Loop
			
			If retryCount >= 3 Then
				Responce.StatusCode= 408
				Responce.Body = "{""error"":{""message"":""Failed to send request after 3 attempts (Error: " &  GetLastError() & ")"", ""code"": 408}}"
				If OnReceive Then OnReceive(*Designer, This, Request, Responce.Body)
				If OnComplete Then OnComplete(*Designer, This, Request, Responce)
				InternetCloseHandle(hRequest)
				InternetCloseHandle(hConnect)
				InternetCloseHandle(hSession)
				Return
			End If
			
			Dim As Integer statusCode
			Dim As DWORD statusCodeSize = SizeOf(statusCode)
			HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_CODE Or HTTP_QUERY_FLAG_NUMBER, @statusCode, @statusCodeSize, 0)
			Responce.StatusCode = statusCode
			
			Dim As DWORD responseHeadersSize = 0
			HttpQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF, 0, @responseHeadersSize, 0)
			If responseHeadersSize > 0 Then
				'Dim As ZString * 4096 responseHeadersBytes
				'If HttpQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF, @responseHeadersBytes, SizeOf(responseHeadersBytes), 0) Then
				'	Responce.Headers = responseHeadersBytes
				'End If
			End If
			
			'Safer buffer handling
			Dim As DWORD bytesRead, dwBufferSize = 8192
			Dim As Long bResult
			Dim As DWORD dwBytesRead
			Dim As ZString Ptr BufferPtr = _Allocate(dwBufferSize)
			Dim As String szBuffer
			Do
				bResult = InternetReadFile(hRequest, BufferPtr, dwBufferSize, @bytesRead)
				If bResult AndAlso bytesRead > 0 Then
					szBuffer = String(bytesRead, 0)
					memcpy(StrPtr(szBuffer), BufferPtr, bytesRead)
				Else
					FAbort = True
					szBuffer = ""
				End If
				'' AstoriaIDE T-SON-2 (F-N7): optional response-size cap. MaxResponseSize = 0 (the
				'' default) preserves the prior unbounded behavior exactly. When set, checked before
				'' appending so Body never exceeds the cap -- an unbounded hostile/huge endpoint can
				'' otherwise exhaust the host app's memory (the chunk that would overflow it is
				'' dropped, not truncated mid-chunk, and the read stops there).
				If MaxResponseSize > 0 AndAlso Len(Responce.Body) + Len(szBuffer) > MaxResponseSize Then
					Responce.Reason = "Response truncated at MaxResponseSize (" & MaxResponseSize & " bytes)"
					FAbort = True
				Else
					Responce.Body &= szBuffer '*BufferPtr
					If OnReceive Then OnReceive(*Designer, This, Request, szBuffer)
				End If
			Loop While FAbort = False
			_Deallocate(BufferPtr)
			If OnComplete Then OnComplete(*Designer, This, Request, Responce)
			InternetCloseHandle(hRequest)
			InternetCloseHandle(hConnect)
			InternetCloseHandle(hSession)
	End Sub
	
	Constructor HTTPConnection
		WLet(FClassName, "HTTPConnection")
	End Constructor
	
	Destructor HTTPConnection
		
	End Destructor
End Namespace

