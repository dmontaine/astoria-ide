'#########################################################
'#  AIService.bi                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

Declare Function NormalizeAIAgentAPIKey(ByRef APIKey As String) As String
Declare Sub SyncCurrentAIAgentSettings(ByRef AgentKey As String)
Declare Function EscapeJsonForPrompt(ByRef iText As WString) As String
Declare Function EscapeFromJson(ByRef iText As WString) As WString Ptr
Declare Function AIGetMaxChunkSize() As Integer
Declare Sub AIPrintAnswer(ByRef Content As WString)
Declare Sub AISplitText(ByRef iText As WString, Chunks() As String, chunkSize As Integer = 4000, Overlap As Integer = 0)
Declare Sub HTTPAIAgent_Complete(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
Declare Sub HTTPAIAgent_Receive(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Buffer As String)
Declare Sub AIRequest(Param As Any Ptr)
Declare Sub txtAIRequest_Activate(ByRef Designer As My.Sys.Object, ByRef Sender As TextBox)
Declare Sub AIChatPaste(ByVal IsFBCode As Boolean = False)
Declare Sub AIRelease()
Declare Sub AIResetContext()

