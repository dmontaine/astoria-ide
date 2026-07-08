'#########################################################
'#  AIService.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "AIService.bi"
#include once "MD2RTF.bi"

Function EscapeJsonForPrompt(ByRef iText As WString) As String
	Dim As Integer Posi = 0, iLen = Len(iText)
	If iLen < 1 Then Return ""
	Dim As Integer bufferSize = iLen * 6 + 2
	Dim As WString Ptr ResultPtr = _Allocate(bufferSize * SizeOf(WString))     ' Pre-allocate maximum possible space
	Dim As String TmpStr
	For i As Integer = 0 To iLen  - 1
		If Posi >= bufferSize - 6 Then
			bufferSize *= 2
			ResultPtr = _Reallocate(ResultPtr, bufferSize * SizeOf(WString))
		End If
		If ResultPtr = 0 Then Return "" ' Guard against allocation failure
		Select Case iText[i]
		Case 92                  '"\\", "\"))    ' UnixSlash
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 92
			Posi += 1
			i += 1
		Case 34                  '"\""", """"))  ' Double quote
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 34
			Posi += 1
		Case 47                  '"\/", "/"))    ' Forward WindowsSlash
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 47
			Posi += 1
		Case 8                  '"\b", Chr(8))) ' Backspace
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 98
			Posi += 1
		Case 12                 '"\f", Chr(12)))' Form feed
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 102
			Posi += 1
		Case 10                 '"\n", Chr(10)))' Line feed
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 110
			Posi += 1
		Case 13                 '"\r", Chr(13)))' Carriage return
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 114
			Posi += 1
		Case 9                 '"\t", "    ")) ' Tab character
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
		Case 0 To 31: ' Control character \uXXXX
			TmpStr = Hex(iText[i], 4)
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 117
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[0]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[1]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[2]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[3]
			Posi += 1
		Case Else
			(*ResultPtr)[Posi] = iText[i]
			Posi += 1
		End Select
	Next
	(*ResultPtr)[Posi] = 0: (*ResultPtr)[Posi + 1] = 0
	' Marke issues
		Dim CodePage As Integer = GetACP()
		If CodePage = 936 Then ' GBK
			Function = *ResultPtr
		Else
			Function = ToUtf8(*ResultPtr)
		End If
	_Deallocate((ResultPtr))
End Function

Function EscapeFromJson(ByRef iText As WString) As WString Ptr
	Dim As Integer iLen = Len(iText)
	If iLen = 0 Then Return 0
	' Pre-allocate memory (worst case: up to 4 escape chars per tab)
	Dim As Integer bufferSize = iLen * 4 + 2
	Dim As WString Ptr ResultPtr = _Allocate(bufferSize * SizeOf(WString)) ' Pre-allocate maximum possible space
	If ResultPtr = 0 Then Return 0
	Dim As String HexVal
	Dim As Integer CharCode, Posi
	For i As Integer = 0 To iLen - 1
		If Posi >= bufferSize- 4 Then
			bufferSize *= 2
			ResultPtr = _Reallocate(ResultPtr, bufferSize * SizeOf(WString))
		End If
		If iText[i] = 92  AndAlso i < iLen - 1 Then
			Select Case iText[i + 1]
			Case 92                  '"\\", "\"))    ' UnixSlash
				(*ResultPtr)[Posi] = 92
				Posi += 1
				i += 1
			Case 34                  '"\""", """"))  ' Double quote
				(*ResultPtr)[Posi] = 34
				Posi += 1
				i += 1
			Case 47                  '"\/", "/"))    ' Forward WindowsSlash
				(*ResultPtr)[Posi] = 47
				Posi += 1
				i += 1
			Case 98                  '"\b", Chr(8))) ' Backspace
				(*ResultPtr)[Posi] = 8
				Posi += 1
				i += 1
			Case 102                 '"\f", Chr(12)))' Form feed
				(*ResultPtr)[Posi] = 12
				Posi += 1
				i += 1
			Case 110                 '"\n", Chr(10)))' Line feed
				(*ResultPtr)[Posi] = 10
				Posi += 1
				i += 1
			Case 114                 '"\r", Chr(13)))' Carriage return
				(*ResultPtr)[Posi] = 13
				Posi += 1
				i += 1
			Case 116                 '"\t", "    ")) ' Tab character
				(*ResultPtr)[Posi] = 32
				Posi += 1
				(*ResultPtr)[Posi] = 32
				Posi += 1
				(*ResultPtr)[Posi] = 32
				Posi += 1
				(*ResultPtr)[Posi] = 32
				Posi += 1
				i += 1
			Case 117  ' \u handles Unicode (e.g. \u0026)
				i += 1
				HexVal = Mid(iText, i + 2, 4)
				CharCode = Val("&h" & HexVal)
				(*ResultPtr)[Posi] = CharCode
				Posi += 1
				i += 4 ' Skip 4 hex digits
			Case Else
				(*ResultPtr)[Posi] = iText[i]
				Posi += 1
				(*ResultPtr)[Posi] = iText[i + 1]
				Posi += 1
				i += 1
			End Select
		Else
			(*ResultPtr)[Posi] = iText[i]
			Posi += 1
		End If
	Next
	(*ResultPtr)[Posi] = 0: (*ResultPtr)[Posi + 1] = 0   ' Truncate to actual used length
	Return ResultPtr
End Function
Function NormalizeAIAgentAPIKey(ByRef APIKey As String) As String
	Dim As String Result = Trim(APIKey)
	If Result = "" Then Return ""
	' Reject HTTP error payloads accidentally pasted into the API key field.
	If Left(Result, 1) = "{" OrElse InStr(LCase(Result), """error""") > 0 OrElse InStr(LCase(Result), "invalid key") > 0 OrElse InStr(LCase(Result), "aihubmix_api_error") > 0 Then Return ""
	' Strip a full Authorization header line if the user pasted it.
	Dim As Integer AuthPos = InStr(LCase(Result), "authorization:")
	If AuthPos > 0 Then Result = Trim(Mid(Result, AuthPos + Len("authorization:")))
	While Left(LCase(Result), 7) = "bearer "
		Result = Trim(Mid(Result, 8))
	Wend
	If LCase(Result) = "bearer" Then Return ""
	Return Result
End Function

Sub SyncCurrentAIAgentSettings(ByRef AgentKey As String)
	Dim As String Key = AgentKey
	If Key = "" Then Key = cboAIAgentModels.Text
	If Key = "" OrElse Key = ML("(not selected)") Then Return
	Dim As Integer Index = pAIAgents->IndexOfKey(Key)
	If Index < 0 AndAlso CurrentAIAgent Then
		Key = *CurrentAIAgent
		Index = pAIAgents->IndexOfKey(Key)
	End If
	If Index < 0 Then Return
	Dim As ModelInfo Ptr Info = Cast(ModelInfo Ptr, pAIAgents->Item(Index)->Object)
	If Info = 0 Then Return
	WLet(CurrentAIAgent, Info->Name)
	AIAgentModelName = Info->ModelName
	AIAgentProvider = Info->Provider
	AIAgentHost = Info->Host
	AIAgentPort = Info->Port
	AIAgentAddress = Info->Address
	AIAgentAPIKey = NormalizeAIAgentAPIKey(Info->APIKey)
	AIAgentTemperature = Info->Temperature
	AIAgentStream = Info->Stream
	AIAgentContentSize = Info->ContentSize
	bAIAgentFirstRun = True
	AIPostDataFirstTime = True
End Sub

Const OPENAI_MAX_CHUNK = 4096       ' OpenAI standard model
Const DEEPSEEK_MAX_CHUNK = 4000     ' DeepSeek standard model
Const CLAUDE_MAX_CHUNK = 100000     ' Claude 100K context
Const MISTRAL_MAX_CHUNK = 32000     ' Mistral 32K context
Const OLLAMA_MAX_CHUNK = 4096       ' Ollama local model
Const OPENROUTER_MAX_CHUNK = 8192    ' OpenRouter general limit
' Get maximum chunk size for current AI platform
Function AIGetMaxChunkSize() As Integer
	Select Case LCase(AIAgentProvider)
	Case "openai", "gpt"
		Return OPENAI_MAX_CHUNK
	Case "deepseek"
		Return DEEPSEEK_MAX_CHUNK
	Case "anthropic", "claude"
		Return CLAUDE_MAX_CHUNK
	Case "mistral"
		Return MISTRAL_MAX_CHUNK
	Case "ollama"
		Return OLLAMA_MAX_CHUNK
	Case "openrouter"
		Return OPENROUTER_MAX_CHUNK
	Case Else
		Return 4000 ' Default value
	End Select
End Function
Sub AIPrintAnswer(ByRef Content As WString)
	If Content = "" Then Return
	txtAIAgent.SelStart = Len(txtAIAgent.Text)
	txtAIAgent.SelEnd = txtAIAgent.SelStart
	txtAIAgent.SelText = Content
	If Not txtAIAgent.Focused Then
		txtAIAgent.ScrollToEnd
	End If
	'Next j
	'Erase BuffFormat
End Sub

Sub AISplitText(ByRef iText As WString, Chunks() As String, chunkSize As Integer = 4000, Overlap As Integer = 0)
	' Validate OverlapNew parameter
	Dim As Integer OverlapNew, chunkSizeNew = IIf(chunkSize < 4000, 4000, chunkSize)
	If OverlapNew >= chunkSizeNew  OrElse OverlapNew < 0 Then
		OverlapNew = chunkSizeNew \ 20
	End If
	
	' Initialize variables
	Dim As Integer TextLength = Len(iText)
	If TextLength = 0 Then
		ReDim Chunks(0)
		Chunks(0) = ""
		Exit Sub
	End If
	
	' Calculate estimated chunks with a safer margin
	Dim As Integer EstimatedChunks = (TextLength \ (chunkSizeNew - OverlapNew)) + 2
	ReDim Chunks(EstimatedChunks - 1)
	Dim ChunkCount As Integer = 0
	
	' Pre-defined break characters   \ n r . 92 110 114 46
	Dim As Boolean bFound
	Dim As Integer startPos = 1
	Dim As Integer endPos, lastGoodPos, currentChar, prevChar
	' Main splitting loop
	Do While startPos <= TextLength
		' Calculate end position
		endPos = startPos + chunkSizeNew - 1
		If endPos >= TextLength Then endPos = TextLength
		' Find natural break point
		lastGoodPos = endPos
		bFound = False
		For i As Integer = endPos To startPos Step -1
			currentChar = iText[i]
			prevChar = iText[i - 1]
			' Check for 92 + \n \r (newline/carriage return) combinations
			If prevChar = 92 Then
				If currentChar = 110 Or currentChar = 114 Then
					lastGoodPos = i + 1
					bFound = True
					Exit For
				End If
			End If
		Next
		If Not bFound Then
			' Check for ". " combinations
			For i As Integer = endPos To startPos Step -1
				If (prevChar = 46 AndAlso currentChar = 32) OrElse currentChar = 13 OrElse currentChar = 10  Then
					lastGoodPos = i + 1
					bFound = True
					Exit For
				End If
			Next
		End If
		If Not bFound Then lastGoodPos = endPos
		If ChunkCount > 20 Then Exit Do
		' Ensure we don't go before start position
		If lastGoodPos < startPos Then lastGoodPos = endPos
		' Store the chunk
		' Resize array if needed
		If ChunkCount > UBound(Chunks) Then
			ReDim Preserve Chunks(ChunkCount + EstimatedChunks)
		End If
		Chunks(ChunkCount) = Mid(iText, startPos, lastGoodPos - startPos + 1)
		If endPos >= TextLength Then Exit Do
		ChunkCount += 1
		' Adjust start position with OverlapNew
		startPos = lastGoodPos - OverlapNew + 1
	Loop
	
	' Adjust array to actual size
	If ChunkCount > 0 Then
		ReDim Preserve Chunks(ChunkCount - 1)
	Else
		ReDim Chunks(0)
		Chunks(0) = ""
	End If
End Sub

Sub HTTPAIAgent_Complete(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
	If Responce.StatusCode > 400 Then
		ShowMessages(Responce.StatusCode & "  " & Responce.Body)
		bInAIThread = False
		txtAIRequest.Enabled = True
		txtAIRequest.SetFocus
		cboAIAgentModels.Enabled = True
		If AIBodyWStringPtr Then _Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
	End If
End Sub
Sub HTTPAIAgent_Receive(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Buffer As String)
	'ShowMessages(Buffer) ' Sometimes got party of the string   'data: [DONE] ': OPENROUTER PROCESSING
	Dim As WString Ptr tmpBodyWStrPtr = FromUtf8(StrPtr(Buffer))
	If tmpBodyWStrPtr = 0 OrElse *tmpBodyWStrPtr = "" Then Return
	WAdd(AIBodyWStringPtr, *tmpBodyWStrPtr)
	If AIBodyWStringPtr = 0 Then _Deallocate((tmpBodyWStrPtr) ): Return
	If CBool(InStr(*tmpBodyWStrPtr, "[DONE]") < 1) AndAlso CBool(InStr(*tmpBodyWStrPtr, "OPENROUTER PROCESSING") < 1) AndAlso CBool(InStr(*tmpBodyWStrPtr, "failed to decode json")) AndAlso Not StartsWith(LCase(*tmpBodyWStrPtr), "error: ") AndAlso Not StartsWith(LCase(*tmpBodyWStrPtr), "{""error""") AndAlso Not StartsWith(*tmpBodyWStrPtr, "{""code""") Then
		If InStr(*tmpBodyWStrPtr, "data:") < 1 OrElse InStr(*tmpBodyWStrPtr, """content"":""") < 1 OrElse Right(*tmpBodyWStrPtr, 1) <> "}" Then _Deallocate(tmpBodyWStrPtr) : Return
	End If
	
	'' Check for complete JSON object (determines if packet is complete)
	Dim As Boolean inString   = False   ' False = not in string, True = in string
	Dim As Boolean escapeNext = False   ' Whether previous char was UnixSlash escape
	Dim As Integer braceCount = 0   ' Unclosed brace count ({ increments, } decrements)
	Dim As Integer lastEndPos = -1  ' Position of closing '}' for outermost object
	For i As Integer = 0 To Len(*tmpBodyWStrPtr) - 1
		If escapeNext Then
			' Previous was UnixSlash; current char is escaped and does not affect state
			escapeNext = False
		Else
			Select Case (*tmpBodyWStrPtr)[i]
			Case 92   ' \
				escapeNext = True
			Case 34   ' "
				inString = Not inString
			Case 123  ' {
				If Not inString Then braceCount += 1
			Case 125  ' }
				If Not inString Then
					braceCount -= 1
					' Found end position of top-level JSON object
					If braceCount = 0 Then lastEndPos = i
				End If
			End Select
		End If
	Next
	
	' Evaluate result
	If braceCount <> 0 Then
		' Braces mismatched; data may be incomplete, wait for more
		'ShowMessages("Waiting for more data, unclosed brace count: " & braceCount & "  Buffer:" & *tmpBodyWStrPtr)
		_Deallocate(tmpBodyWStrPtr)
		Return
		'ElseIf lastEndPos >= 0 Then
		'	' Parsed complete JSON object; end position is lastEndPos
		'	ShowMessages("Received complete JSON object; last '}' at position: " & lastEndPos)
	End If
	'                                      'qwen/qwen3.6-plus:free|OpenRouter    OpenRouter              'Silicon                       'GLM                          NO Thinking                                      'Nvidia
	Dim As String ContentStart(0 To 6) = {  """content"":"""    ,           """content"":""",           """content"":""",                """content"":""",           """content"":""",             """content"":""",                ",""content"":"""   }
	Dim As String ContentEnd(0 To 6) = {   """,""role"":""assistant",        """,""reasoning"":null",   """,""reasoning_content"":null", """}}]}",                    """},""logprobs"":null",    """},""finish_reason""",       """,""tool_calls"":"   }
	Dim As String ReasoningStart(0 To 4) = {",""reasoning"":"""       ,      ",""reasoning"":""",       ",""reasoning_content"":""",     ",""reasoning_content"":""", ",""reasoning_content"":"""                    }
	Dim As String ReasoningEnd(0 To 4) = {  """,""reasoning_details"":" ,    """},""finish_reason""",     """,""role"":""",               """}}]}",                   """},"""                                          }
	'","role":"assistant   ,"reasoning":"  ","role":"assistant"
	Dim As WString Ptr Buff()
	Dim As Integer k, iPosEnd, iPosStart, iPos3, BuffCount = Split(*AIBodyWStringPtr, "data: ", Buff())
	Dim As Boolean binReason
	ThreadsEnter
	For i As Integer = 0 To BuffCount - 1
		If Buff(i) = 0 OrElse Len(*Buff(i)) < 2 Then Continue For
		If InStr(*Buff(i), "chat.completion.chunk") Then
			'Skip the empty
			'If InStr(LCase(*Buff(i)), """content"":"""",""reasoning_content"":null") OrElse InStr(LCase(*Buff(i)), """content"":"""",""reasoning_content"":""""") OrElse InStr(LCase(*Buff(i)), """content"":"""",""role"":""assistant") Then Continue For
			'If InStr(LCase(*Buff(i)), """content"":"""",""reasoning_content"":null") OrElse InStr(LCase(*Buff(i)), """content"":"""",""reasoning_content"":""""") OrElse InStr(LCase(*Buff(i)), """content"":"""",""role"":""assistant") Then Continue For
			binReason = False
			For k = 0 To UBound(ReasoningEnd)
				iPosEnd = InStr(LCase(*Buff(i)), ReasoningEnd(k))
				If iPosEnd > 0 Then 'For think model
					iPosStart = InStrRev(LCase(*Buff(i)), ReasoningStart(k), iPosEnd)
					If iPosStart Then
						If Not bInNOTThingk Then
							bInNOTThingk = True
							txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
							txtAIAgent.SelEnd = txtAIAgent.SelStart
							txtAIAgent.SelText =  !"\r\n<think>\r\n"
						End If
						'Print "REASON:" & (iPosStart - iPosEnd - Len(ReasoningStart(k)))
						iPos3 = iPosEnd - iPosStart - Len(ReasoningStart(k))
						If iPos3 > 0 Then
							binReason = True
							_Deallocate(AIBodyWStringPtr ): AIBodyWStringPtr = 0
							AIBodyWStringPtr = EscapeFromJson(Mid(*Buff(i), iPosStart + Len(ReasoningStart(k)), iPos3))
							If AIBodyWStringPtr <> 0 Then AIPrintAnswer(*AIBodyWStringPtr)
						End If
						Exit For
					End If
				End If
			Next
			If Not binReason Then
				For k = 0 To UBound(ContentEnd)
					iPosEnd = InStr(LCase(*Buff(i)), ContentEnd(k))
					'"finish_reason":"stop"
					If iPosEnd > 0 Then
						iPosStart = InStrRev(LCase(*Buff(i)), ContentStart(k), iPosEnd)
						If iPosStart > 0 Then
							If Not bInThingk Then
								bInThingk = True
								txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
								txtAIAgent.SelEnd = txtAIAgent.SelStart
								txtAIAgent.SelText =  !"\r\n</think>\r\n"
							End If
							'Print "CONT:" & (iPosStart - iPosEnd - Len(ContentStart(k)))
							iPos3 = iPosEnd - iPosStart - Len(ContentStart(k))
							If iPos3 > 0 Then
								_Deallocate(AIBodyWStringPtr ): AIBodyWStringPtr = 0
								AIBodyWStringPtr = EscapeFromJson(Mid(*Buff(i), iPosStart + Len(ContentStart(k)), iPos3))
								If AIBodyWStringPtr <> 0 Then
									WAdd(AIAssistantsAnswersPtr, *AIBodyWStringPtr)
									AIPrintAnswer(*AIBodyWStringPtr)
								End If
							End If
							Exit For
						End If
					End If
				Next
				iPosStart = InStr(*Buff(i), ",""usage"":")
				If iPosStart Then
					k = InStr(*Buff(i), """total_tokens"":")  '15
					If k < 1 Then iPos3 = Len(*Buff(i)) Else iPos3 = InStr(k, *Buff(i), ",")
					If iPos3 < 1 Then iPos3 = Len(*Buff(i))
					*Buff(i) = Mid(*Buff(i), iPosStart + 10, iPos3 - iPosStart - 10)
					ShowMessages(*Buff(i))
				End If
			End If
			_Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
		Else
			',"usage":{"prompt_tokens":2939,"completion_tokens":420,"total_tokens":3359,
			If Buff(i) <> 0 Then
				If CBool(InStr(*Buff(i), "[DONE]") > 0) OrElse CBool(InStr(*Buff(i), "OPENROUTER PROCESSING") > 0) OrElse CBool(InStr(*Buff(i), "failed to decode json")) OrElse StartsWith(LCase(*Buff(i)), "error: ") OrElse StartsWith(LCase(*Buff(i)), "{""error""") OrElse StartsWith(*Buff(i), "{""code""") OrElse CBool(InStr(*Buff(i), "{") > 1) Then
					ShowMessages(*Buff(i))
						If AIAssistantsAnswersPtr AndAlso Trim(*AIAssistantsAnswersPtr) = "" Then
							If AIMessages.Count > 0  AndAlso AIMessages.Item(AIMessages.Count - 1)->Text = "NA" Then AIMessages.Remove AIMessages.Count - 1
						End If
						If  AIAssistantsAnswersPtr Then
							If AIMessages.Count > 0 Then AIMessages.Item(AIMessages.Count - 1)->Text = "[**AI Response:**] " & *AIAssistantsAnswersPtr
						End If
						WLet(AIBodyWStringSavePtr, txtAIAgent.Text)
						If AIBodyWStringSavePtr <> 0 Then
							_Deallocate(AIBodyWStringPtr ): AIBodyWStringPtr = 0
							AIBodyWStringPtr = MDtoRTF(*AIBodyWStringSavePtr)
							If AIBodyWStringPtr <> 0 Then
								txtAIAgent.TextRTF = *AIBodyWStringPtr
								txtAIAgent.Zoom = Int(txtAIAgent.ScaleX(100) * 0.50)
							End If
						End If
					txtAIRequest.Enabled = True
					txtAIRequest.SetFocus
					cboAIAgentModels.Enabled = True
					If AIBodyWStringPtr Then _Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
				Else
					WLet(AIBodyWStringPtr, *Buff(i))
				End If
			End If
		End If
		_Deallocate(Buff(i))
	Next
	Erase Buff
	If AIBodyWStringPtr Then _Deallocate(AIBodyWStringPtr ): AIBodyWStringPtr = 0 
	_Deallocate((tmpBodyWStrPtr))
	ThreadsLeave
End Sub

Sub AIRequest(Param As Any Ptr)
	bInAIThread = True
	bInThingk = False
	bInNOTThingk = False
	AIBold = False
	_Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
	SyncCurrentAIAgentSettings(cboAIAgentModels.Text)
	Dim As String EffectiveAPIKey = NormalizeAIAgentAPIKey(AIAgentAPIKey)
	If EffectiveAPIKey = "" Then
		ThreadsEnter
		ShowMessages(ML("API key is not configured for the selected AI agent.") & " (" & *CurrentAIAgent & ", " & AIAgentProvider & "). " & ML("Set it in Options -> AI Agents."))
		txtAIRequest.Enabled = True
		txtAIRequest.SetFocus
		cboAIAgentModels.Enabled = True
		ThreadsLeave
		bInAIThread = False
		Return
	End If
	HTTPAIAgent.Host = AIAgentHost
	HTTPAIAgent.Port = AIAgentPort
	Dim As HTTPRequest Request
	Dim As HTTPResponce Responce
	Request.ResourceAddress = AIAgentAddress
	Dim As String header1 = "Content-Type: application/json; charset=utf-8"
	Dim As String header2 = "Authorization: Bearer " + EffectiveAPIKey
	Request.Headers = header1 & !"\r\n" & header2 & !"\r\n"
	'Debug.Print AIPostData
	'Strange issue
		Dim CodePage As Integer = GetACP()
		If CodePage= 936 Then
			Request.Body = ToUtf8(AIPostData)
		Else
			Request.Body = AIPostData
		End If
	If bAIAgentFirstRun Then bAIAgentFirstRun = False
	ThreadsEnter
	txtAIRequest.Text = ""
	If AIBodyWStringSavePtr Then txtAIAgent.Text = *AIBodyWStringSavePtr Else txtAIAgent.Text = ""
	WLet(AIAssistantsAnswersPtr, "")
	txtAIAgent.SelAlignment = AlignmentConstants.taLeft
	txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
	txtAIAgent.SelEnd = txtAIAgent.SelStart
	txtAIAgent.SelBackColor = darkHlBkColor
	txtAIAgent.SelText = !"\r\n[**AI Response:**] " & (*CurrentAIAgent) & !"\r\n"
	txtAIAgent.SelBackColor = darkBkColor
	txtAIAgent.ScrollToEnd
	ThreadsLeave
	If AIAgentStream Then
		HTTPAIAgent.OnReceive = @HTTPAIAgent_Receive
	End If
	HTTPAIAgent.CallMethod("POST", Request, Responce)
	If Not AIAgentStream Then
		Dim As WString Ptr BuffPtr, Temp = FromUtf8(StrPtr(Responce.Body))
		If Temp = 0 Then Return
		Dim As Integer iPos1 = InStr(Responce.Body, ",""reasoning"":""")
		Dim As Integer iPos2 = InStrRev(Responce.Body, """}}],""")
		BuffPtr = EscapeFromJson(Mid(*Temp, iPos1 + 14, iPos2 - iPos1 - 14))
		If BuffPtr = 0 Then Return
		ThreadsEnter
		txtAIAgent.SelStart = Len(txtAIAgent.Text)
		txtAIAgent.SelEnd = txtAIAgent.SelStart
		txtAIAgent.SelAlignment = AlignmentConstants.taLeft
		txtAIAgent.SelBackColor = darkHlBkColor
		txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
		txtAIAgent.SelEnd = txtAIAgent.SelStart
		txtAIAgent.SelText = !"\r\n[**AI Response:**] " & (*CurrentAIAgent) & !"\r\n"
		txtAIAgent.ScrollToCaret
		txtAIAgent.SelBackColor = darkBkColor
		txtAIAgent.SelText = !"<Think>\r\n" & *BuffPtr & !"</Think>\r\n"
		txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
		txtAIAgent.SelEnd = txtAIAgent.SelStart
		ThreadsLeave
		iPos1 = InStrRev(*Temp, ",""content"":""")
		iPos2 = InStrRev(*Temp, """,""refusal""")
		_Deallocate((BuffPtr)): BuffPtr = 0
		BuffPtr = EscapeFromJson(Mid(*Temp, iPos1 + 12, iPos2 - iPos1 - 12))
		If BuffPtr <> 0 Then
			ThreadsEnter
			AIPrintAnswer(*BuffPtr)
			'txtAIRequest.Enabled = True
			txtAIRequest.SetFocus
			ThreadsLeave
		End If
		WDeAllocate(Temp)
		WDeAllocate(BuffPtr)
	End If
	bInAIThread = False
End Sub

Sub txtAIRequest_Activate(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
	If bInAIThread Then 
		ShowMessages(ML("Please waiting, AI is working hard......"))
		Return
	End If
	If Trim(txtAIRequest.Text, Any !"\t\n\r ") = "" Then Return
	txtAIRequest.Text = Trim(txtAIRequest.Text, Any !"\t\r\n ")
	txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
	txtAIAgent.SelEnd = txtAIAgent.SelStart
	txtAIAgent.SelBackColor = darkHlBkColor
	txtAIAgent.SelAlignment = AlignmentConstants.taLeft
	txtAIAgent.SelText = !"\r\n\r\n[**User Question:**] " & Date & " " & Time
	txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
	txtAIAgent.SelEnd = txtAIAgent.SelStart
	txtAIAgent.SelBackColor = darkBkColor
	txtAIAgent.SelText = !"\r\n" & txtAIRequest.Text & !"\r\n"
	txtAIAgent.ScrollToEnd
	WLet(AIBodyWStringSavePtr, txtAIAgent.Text)
	bInAIThread = True
	txtAIRequest.Enabled = False
	Dim As String site_url = "https://github.com/XusinboyBekchanov/VisualFBEditor"
	Dim As String site_name = "VisualFBEditor"
	Dim As String ExtraHeaders = IIf(InStr(LCase(AIAgentProvider),  "openrouter"), ", ""extra_headers"": {""HTTP-Referer"": """ & site_url & """, ""X-Title"": """ & site_name & """}}", "}")
	'Monitoring feedback:
	'Log actual token usage per API call; auto-adjust subsequent chunk size:
	'If lastTokenUsage > MaxChunkSize * 0.9 Then
	Dim As Integer MaxChunkSize = AIGetMaxChunkSize()
	Dim As Integer ChunkThreshold, ChunkOverlap, MaxChunks
	Dim As String UserChunks(), AssistantChunks()
	
	'AICalculateChunkParameters(ChunkThreshold, ChunkOverlap, MaxChunkSize)
	ChunkThreshold = MaxChunkSize * 0.8  ' Code needs smaller chunks
	If ChunkThreshold < 512 Then ChunkThreshold = 512    'Ensure minimum value
	ChunkOverlap = 0       ' Code needs larger overlap
	Dim As WString * MAX_PATH FileName , IncludeFile
	Dim As WString Ptr ControlBIContentPtr
	Dim As Integer ControlBIIndex
	Dim As String ContentType
	AIPostData = _
	"{""model"": """ & AIAgentModelName & """, " & _
	"""stream"": " & IIf(AIAgentStream, "true", "false") & ", " & _
	"""messages"": [" & "{""role"": ""system"", ""content"": """ & "Begin to sent file in chunks." & """}"
	
	' Find the control in txtAIRequest.Text
	ContentType= "Markdown "
	Dim As Boolean bShouldSend
	Dim As Integer  AIContextCount = AIContext.Count - 1
	For j As Integer = 0 To AIContextCount
		filename = AIContext.Item(j)->Key
		'Debug.Print FileName & " j=" & j
		bShouldSend = False
		'If InStr(FileName, "MyFbFramework") Then
		'	If InStr(txtAIRequest.Text, "MyFbFramework") > 0 Then bShouldSend = True
		'	If InStr(txtAIRequest.Text, "MFF") > 0 Then bShouldSend = True
		'	If InStr(txtAIRequest.Text, "Interface") > 0 Then bShouldSend = True
		'	If InStr(txtAIRequest.Text, "GUI ") > 0 Then bShouldSend = True
		'
		If j = 0 Then
			bShouldSend = True 'MyFbFramework must be send
		Else
			If InStr(filename, "VisualFBEditor") Then
				If InStr(txtAIRequest.Text, "VisualFBEditor") > 0 Then bShouldSend = True
				If InStr(txtAIRequest.Text, "VFBE") > 0 Then bShouldSend = True
				If InStr(txtAIRequest.Text, "IDE") > 0 Then bShouldSend = True
			Else
				bShouldSend = InStr(txtAIRequest.Text, filename)
			End If
		End If
		If bShouldSend AndAlso CBool(AIIncludeFileNameList.Count < 1 OrElse Not AIIncludeFileNameList.Contains(FileName)) Then
			WLet(ControlBIContentPtr, AIContext.Item(j)->Text)
			ContentType= "Markdown "
			If ControlBIContentPtr <> 0 AndAlso Trim(*ControlBIContentPtr) <> "" Then
				If Len(*ControlBIContentPtr) > MaxChunkSize Then
					AISplitText(" <context> ```" & ContentType & EscapeJsonForPrompt(*ControlBIContentPtr & " ``` </context> "), UserChunks(), ChunkThreshold, ChunkOverlap)
					MaxChunks = UBound(UserChunks) + 1
					For i As Integer = 0 To MaxChunks - 1
						AIPostData &= ", {""role"": ""system"", ""content"": ""[" & FileName & " Part " & (i + 1) & "/" & (MaxChunks) & "] " & UserChunks(i) & """}"
					Next
				Else
					AIPostData &= ", {""role"": ""system"", ""content"": """  & " <context> ```" & ContentType & EscapeJsonForPrompt(*ControlBIContentPtr) & " ``` </context> " & """}"
				End If
				AIIncludeFileNameList.Add(AIContext.Item(j)->Key)
			End If
			_Deallocate(ControlBIContentPtr ): ControlBIContentPtr = 0
			Erase UserChunks
		End If
	Next
	If AIMessages.Count > 0 Then
		For j As Integer = 0 To AIMessages.Count - 1
			If Len(AIMessages.Item(j)->Key) > MaxChunkSize OrElse Len(AIMessages.Item(j)->Text) > MaxChunkSize Then
				AISplitText(EscapeJsonForPrompt(AIMessages.Item(j)->Key), UserChunks(), ChunkThreshold, ChunkOverlap)
				AISplitText(EscapeJsonForPrompt(AIMessages.Item(j)->Text), AssistantChunks(), ChunkThreshold, ChunkOverlap)
				MaxChunks = Max(UBound(UserChunks), UBound(AssistantChunks)) + 1
				ReDim Preserve UserChunks(MaxChunks - 1)
				ReDim Preserve AssistantChunks(MaxChunks - 1)
				For i As Integer = 0 To MaxChunks - 1 'strictly adhere to the user/assistant alternating format required by the DeepSeek API.
					AIPostData &= ", {""role"": ""user"", ""content"": ""[User chunk " & (i + 1) & "/" & (MaxChunks) & "] " & UserChunks(i) & """}"
					AIPostData &= ", {""role"": ""assistant"", ""content"": ""[AI chunk " & (i + 1) & "/" & (MaxChunks) & "] " & AssistantChunks(i) & """}"
				Next
			Else
				AIPostData &= ", {""role"": ""user"", ""content"": """ & EscapeJsonForPrompt(AIMessages.Item(j)->Key) & """}"
				AIPostData &= ", {""role"": ""assistant"", ""content"": """ & EscapeJsonForPrompt(AIMessages.Item(j)->Text) & """}"
			End If
		Next
		Erase UserChunks
	End If
	If Len(txtAIRequest.Text) > MaxChunkSize Then
		AISplitText(EscapeJsonForPrompt(txtAIRequest.Text), UserChunks(), ChunkThreshold, ChunkOverlap)
		MaxChunks = UBound(UserChunks) + 1
		For i As Integer = 0 To MaxChunks - 1 'strictly adhere to the user/assistant alternating format required by the DeepSeek API.
			If i <> MaxChunks - 1 Then
				AIPostData &= ", {""role"": ""user"", ""content"": ""[**User question** Part " & (i + 1) & "/" & (MaxChunks) & "] " & UserChunks(i) & """}"
				AIPostData &= ", {""role"": ""assistant"", ""content"": ""[**Received** part " & (i + 1) & "/" & (MaxChunks) & "] - please send next segment: " & """}"
			Else
				AIPostData &= ", {""role"": ""user"", ""content"": ""[**User question** Part " & (i + 1) & "/" & (MaxChunks) & "] " & UserChunks(i) & """}]" & ExtraHeaders
			End If
		Next
	Else
		AIPostData  &= ", {""role"": ""user"", ""content"": """ & EscapeJsonForPrompt(txtAIRequest.Text) & """}]" & ExtraHeaders
	End If
	
	AIMessages.Add("[**User Question:**] " & txtAIRequest.Text, "NA")
	WLet(AIAssistantsAnswersPtr, "")
	ClearMessages
	Erase UserChunks
	Erase AssistantChunks
	cboAIAgentModels.Enabled = False
	If AIThread Then ThreadDetach(AIThread)
	AIThread = ThreadCreate(@AIRequest)
End Sub

Public Sub AIChatPaste(ByVal IsFBCode As Boolean = False)
	Dim As WString Ptr res(Any), tmpWStrPtr
	pstBar->Panels[0]->Caption = ML("Wait until tool quits")
	If IsFBCode Then
		WLet(tmpWStrPtr, Replace(Clipboard.GetAsText, Chr(9), "    "))
		AIMessages.Add "```FreeBasic " & Chr(10) & *tmpWStrPtr & Chr(10) & "```", " "
		WAdd(AIBodyWStringPtr, "```FreeBasic " & Chr(10) & *tmpWStrPtr & Chr(10) & "```")
		_Deallocate(tmpWStrPtr)
	Else
		Split(Clipboard.GetAsText, Chr(9), res())
		If UBound(res) < 1 Then Exit Sub
		For j As Integer = 0 To UBound(res) - 1 Step 2
			If Trim(*res(j)) <> "" Then
				AIMessages.Add *res(j), *res(j + 1)
				WAdd(AIBodyWStringPtr, *res(j) & Chr(10) & *res(j + 1) & Chr(10))
			End If
			_Deallocate(res(j))
			_Deallocate(res(j + 1))
		Next
		Erase res
	End If
	WLet(AIBodyWStringSavePtr, *AIBodyWStringPtr)
	If (Not IsFBCode) AndAlso (AIBodyWStringSavePtr <> 0) Then _Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0 : AIBodyWStringPtr = MDtoRTF(*AIBodyWStringSavePtr)
	If AIBodyWStringPtr Then
		txtAIAgent.TextRTF = *AIBodyWStringPtr
		txtAIAgent.Zoom = Int(txtAIAgent.ScaleX(100) * 0.50)
		txtAIAgent.ScrollToCaret
		txtAIRequest.Enabled = True
		txtAIRequest.SetFocus
	End If
	_Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
	frmMain.Cursor = 0
	pstBar->Panels[0]->Caption = ML("Press F1 for get more information")
End Sub

Sub AIReleaseFinish(Param As Any Ptr = 0)
	Sleep(500)
	ThreadsEnter
	WLet(AIAssistantsAnswersPtr, "")
	bInAIThread = False
	txtAIRequest.Enabled = True
	txtAIRequest.SetFocus
	cboAIAgentModels.Enabled = True
	ThreadsLeave
End Sub

Public Sub AIRelease()
	ThreadsEnter
	If pHTTPAIAgent <> 0 Then pHTTPAIAgent->Abort = True
	ThreadsLeave
	'If AIThread Then ThreadDetach(AIThread)
	ThreadCreate(@AIReleaseFinish)
End Sub

Sub AIResetContextFinish(Param As Any Ptr = 0)
	Sleep(300)
	If AIThread Then ThreadDetach(AIThread)
	AIThread = ThreadCreate(@AIRequest)
End Sub

Public Sub AIResetContext()
	If bInAIThread Then
		ShowMessages(ML("Please waiting, AI is working hard......"))
		Return
	End If
	txtAIAgent.Text = " "
	txtAIAgent.TextRTF = ""
	ThreadsEnter 
	If pHTTPAIAgent <> 0 Then pHTTPAIAgent->Abort = True
	ThreadsLeave
	_Deallocate(AIBodyWStringPtr): AIBodyWStringPtr = 0
	_Deallocate(AIBodyWStringSavePtr): AIBodyWStringSavePtr = 0
	AIPostData = _
	"{""model"": """ & AIAgentModelName & """, " & _
	"""stream"": " & "true" & ", " & _
	"""messages"": [" & _
	"{""role"": ""system"", ""content"": """ & "Clear all historical context and start a completely new conversation."  & """}, " & _
	"{""role"": ""user"", ""content"": """ & "Please use " & App.CurLanguage & " confirm the context has been reset." & """}]}"
	
	If AIMessages.Count > 0 Then
		Dim As WString * MAX_PATH FileName
		FileName = IIf(RecentAIChat, *RecentAIChat, WStr(Mid(FormatFileName(Left(AIMessages.Item(0)->Key, 50)) & Format(Now, "yyyymmdd_hhmm") & ".md", 16)))
		AIMessages.SaveToFile(ExePath & "/AIChat/" & FileName)
		If Not MRUAIChat.Contains(FileName) Then
			MRUAIChat.Add FileName
			miRecentAIChat->Add(FileName, "", FileName, @mClickAIChat)
		End If
		ShowMessages(ML("The conversation context was saved to") & " " & ExePath & "/AIChat/" & FileName)
		AIMessages.Clear
	End If
	_Deallocate((RecentAIChat)): RecentAIChat = 0
	AIIncludeFileNameList.Clear
	AIPostDataFirstTime = True
	txtAIRequest.Enabled = True
	WLet(AIAssistantsAnswersPtr, "")
	txtAIRequest.Enabled = True
	txtAIRequest.SetFocus
	cboAIAgentModels.Enabled = True
	ThreadCreate(@AIResetContextFinish)
End Sub

