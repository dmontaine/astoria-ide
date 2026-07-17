'###############################################################################
'#  JsonLite.bas -- see JsonLite.bi for the design contract.                   #
'###############################################################################

'' ---------------------------------------------------------------- lifecycle

Destructor JsonValue
	'' Free the whole subtree iteratively along siblings to keep recursion
	'' depth bounded by nesting depth only (Delete of each child recurses
	'' into ITS children the same way).
	Dim As JsonValue Ptr c = Child
	While c
		Dim As JsonValue Ptr nxt = c->NextSib
		Delete c
		c = nxt
	Wend
	Child = 0
End Destructor

Function JsonNewNull() As JsonValue Ptr
	Return New JsonValue
End Function

Function JsonNewBool(b As Boolean) As JsonValue Ptr
	Dim v As JsonValue Ptr = New JsonValue
	v->Kind = jkBool : v->BoolValue = b
	Return v
End Function

Function JsonNewNumber(n As Double) As JsonValue Ptr
	Dim v As JsonValue Ptr = New JsonValue
	v->Kind = jkNumber : v->NumValue = n
	Return v
End Function

Function JsonNewString(ByRef s As String) As JsonValue Ptr
	Dim v As JsonValue Ptr = New JsonValue
	v->Kind = jkString : v->StrValue = s
	Return v
End Function

Function JsonNewObject() As JsonValue Ptr
	Dim v As JsonValue Ptr = New JsonValue
	v->Kind = jkObject
	Return v
End Function

Function JsonNewArray() As JsonValue Ptr
	Dim v As JsonValue Ptr = New JsonValue
	v->Kind = jkArray
	Return v
End Function

'' ---------------------------------------------------------------- accessors

Function JsonValue.Count() As Integer
	Dim As Integer n
	Dim As JsonValue Ptr c = Child
	While c
		n += 1
		c = c->NextSib
	Wend
	Return n
End Function

Function JsonValue.Find(ByRef nm As String) As JsonValue Ptr
	Dim As JsonValue Ptr c = Child
	While c
		If c->Name = nm Then Return c
		c = c->NextSib
	Wend
	Return 0
End Function

Function JsonValue.ItemAt(idx As Integer) As JsonValue Ptr
	Dim As Integer n
	Dim As JsonValue Ptr c = Child
	While c
		If n = idx Then Return c
		n += 1
		c = c->NextSib
	Wend
	Return 0
End Function

Function JsonValue.GetStr(ByRef nm As String, ByRef dflt As String = "") As String
	Dim As JsonValue Ptr c = Find(nm)
	If c = 0 OrElse c->Kind <> jkString Then Return dflt
	Return c->StrValue
End Function

Function JsonValue.GetNum(ByRef nm As String, dflt As Double = 0) As Double
	Dim As JsonValue Ptr c = Find(nm)
	If c = 0 OrElse c->Kind <> jkNumber Then Return dflt
	Return c->NumValue
End Function

Function JsonValue.GetBool(ByRef nm As String, dflt As Boolean = False) As Boolean
	Dim As JsonValue Ptr c = Find(nm)
	If c = 0 OrElse c->Kind <> jkBool Then Return dflt
	Return c->BoolValue
End Function

Sub JsonValue.Append(v As JsonValue Ptr)
	If v = 0 Then Exit Sub
	v->NextSib = 0
	If Child = 0 Then
		Child = v
	Else
		Dim As JsonValue Ptr c = Child
		While c->NextSib
			c = c->NextSib
		Wend
		c->NextSib = v
	End If
End Sub

Sub JsonValue.SetMember(ByRef nm As String, v As JsonValue Ptr)
	If v = 0 Then Exit Sub
	v->Name = nm
	'' Replace an existing member of the same name (keeps objects well-formed).
	Dim As JsonValue Ptr prev = 0, c = Child
	While c
		If c->Name = nm Then
			v->NextSib = c->NextSib
			If prev Then prev->NextSib = v Else Child = v
			c->NextSib = 0
			Delete c
			Exit Sub
		End If
		prev = c
		c = c->NextSib
	Wend
	Append(v)
End Sub

'' ---------------------------------------------------------------- serializer

Function JsonEscape(ByRef s As String) As String
	Dim As String sOut
	For i As Integer = 0 To Len(s) - 1
		Dim As Integer b = s[i]
		Select Case b
		Case Asc("""") : sOut &= "\"""
		Case Asc("\")  : sOut &= "\\"
		Case 8  : sOut &= "\b"
		Case 9  : sOut &= "\t"
		Case 10 : sOut &= "\n"
		Case 12 : sOut &= "\f"
		Case 13 : sOut &= "\r"
		Case Is < 32
			sOut &= "\u" & LCase(Right("000" & Hex(b), 4))
		Case Else
			sOut &= Chr(b)   '' includes raw UTF-8 multibyte sequences -- valid JSON
		End Select
	Next i
	Return sOut
End Function

'' Numbers: integers up to 2^53 print without a decimal point (ids, line
'' numbers); everything else falls back to FB's Str() double formatting.
Private Function JsonNumToStr(n As Double) As String
	If n = Int(n) AndAlso Abs(n) < 9007199254740992.0 Then
		Return Str(CLngInt(n))
	End If
	Return Str(n)
End Function

Function JsonSerialize(v As JsonValue Ptr) As String
	If v = 0 Then Return "null"
	Select Case v->Kind
	Case jkNull   : Return "null"
	Case jkBool   : If v->BoolValue Then Return "true" Else Return "false"
	Case jkNumber : Return JsonNumToStr(v->NumValue)
	Case jkString : Return """" & JsonEscape(v->StrValue) & """"
	Case jkArray
		Dim As String sOut = "["
		Dim As JsonValue Ptr c = v->Child
		While c
			If c <> v->Child Then sOut &= ","
			sOut &= JsonSerialize(c)
			c = c->NextSib
		Wend
		Return sOut & "]"
	Case jkObject
		Dim As String sOut = "{"
		Dim As JsonValue Ptr c = v->Child
		While c
			If c <> v->Child Then sOut &= ","
			sOut &= """" & JsonEscape(c->Name) & """:" & JsonSerialize(c)
			c = c->NextSib
		Wend
		Return sOut & "}"
	End Select
	Return "null"
End Function

'' ---------------------------------------------------------------- parser

'' Recursive-descent over the UTF-8 byte string. ix is a 0-based byte index.
'' Every Parse* returns 0 on error; the caller frees nothing on failure paths
'' below because partially built subtrees are deleted where they are dropped.

Const JSONLITE_MAX_DEPTH = 64

Private Sub JsonSkipWs(ByRef s As String, ByRef ix As Integer)
	While ix < Len(s)
		Select Case s[ix]
		Case 32, 9, 10, 13
			ix += 1
		Case Else
			Exit While
		End Select
	Wend
End Sub

'' Append one Unicode code point as UTF-8 bytes.
Private Sub JsonAppendUtf8(ByRef sOut As String, cp As UInteger)
	If cp < &H80 Then
		sOut &= Chr(cp)
	ElseIf cp < &H800 Then
		sOut &= Chr(&HC0 Or (cp Shr 6)) & Chr(&H80 Or (cp And &H3F))
	ElseIf cp < &H10000 Then
		sOut &= Chr(&HE0 Or (cp Shr 12)) & Chr(&H80 Or ((cp Shr 6) And &H3F)) & Chr(&H80 Or (cp And &H3F))
	Else
		sOut &= Chr(&HF0 Or (cp Shr 18)) & Chr(&H80 Or ((cp Shr 12) And &H3F)) & Chr(&H80 Or ((cp Shr 6) And &H3F)) & Chr(&H80 Or (cp And &H3F))
	End If
End Sub

Private Function JsonHex4(ByRef s As String, ix As Integer, ByRef hexVal As UInteger) As Boolean
	If ix + 3 >= Len(s) Then Return False
	hexVal = 0
	For i As Integer = 0 To 3
		Dim As Integer b = s[ix + i], d
		Select Case b
		Case Asc("0") To Asc("9") : d = b - Asc("0")
		Case Asc("a") To Asc("f") : d = b - Asc("a") + 10
		Case Asc("A") To Asc("F") : d = b - Asc("A") + 10
		Case Else : Return False
		End Select
		hexVal = (hexVal Shl 4) Or d
	Next i
	Return True
End Function

'' Parses the body of a string literal; ix must sit just past the opening
'' quote and lands just past the closing quote on success.
Private Function JsonParseStringBody(ByRef s As String, ByRef ix As Integer, ByRef sOut As String) As Boolean
	sOut = ""
	While ix < Len(s)
		Dim As Integer b = s[ix]
		Select Case b
		Case Asc("""")
			ix += 1
			Return True
		Case Asc("\")
			ix += 1
			If ix >= Len(s) Then Return False
			Select Case s[ix]
			Case Asc("""") : sOut &= """" : ix += 1
			Case Asc("\")  : sOut &= "\"  : ix += 1
			Case Asc("/")  : sOut &= "/"  : ix += 1
			Case Asc("b")  : sOut &= Chr(8)  : ix += 1
			Case Asc("f")  : sOut &= Chr(12) : ix += 1
			Case Asc("n")  : sOut &= Chr(10) : ix += 1
			Case Asc("r")  : sOut &= Chr(13) : ix += 1
			Case Asc("t")  : sOut &= Chr(9)  : ix += 1
			Case Asc("u")
				Dim As UInteger cp
				If Not JsonHex4(s, ix + 1, cp) Then Return False
				ix += 5
				'' UTF-16 surrogate pair -> one code point
				If cp >= &HD800 AndAlso cp <= &HDBFF Then
					If ix + 1 < Len(s) AndAlso s[ix] = Asc("\") AndAlso s[ix + 1] = Asc("u") Then
						Dim As UInteger lo
						If Not JsonHex4(s, ix + 2, lo) Then Return False
						If lo >= &HDC00 AndAlso lo <= &HDFFF Then
							cp = &H10000 + ((cp - &HD800) Shl 10) + (lo - &HDC00)
							ix += 6
						End If
					End If
				End If
				JsonAppendUtf8(sOut, cp)
			Case Else
				Return False
			End Select
		Case 0 To 31
			Return False   '' raw control characters are invalid inside JSON strings
		Case Else
			sOut &= Chr(b)
			ix += 1
		End Select
	Wend
	Return False   '' unterminated
End Function

Private Function JsonParseValue(ByRef s As String, ByRef ix As Integer, depth As Integer) As JsonValue Ptr
	If depth > JSONLITE_MAX_DEPTH Then Return 0
	JsonSkipWs(s, ix)
	If ix >= Len(s) Then Return 0
	Select Case s[ix]
	Case Asc("{")
		ix += 1
		Dim As JsonValue Ptr obj = JsonNewObject()
		JsonSkipWs(s, ix)
		If ix < Len(s) AndAlso s[ix] = Asc("}") Then ix += 1 : Return obj
		Do
			JsonSkipWs(s, ix)
			If ix >= Len(s) OrElse s[ix] <> Asc("""") Then Delete obj : Return 0
			ix += 1
			Dim As String nm
			If Not JsonParseStringBody(s, ix, nm) Then Delete obj : Return 0
			JsonSkipWs(s, ix)
			If ix >= Len(s) OrElse s[ix] <> Asc(":") Then Delete obj : Return 0
			ix += 1
			Dim As JsonValue Ptr v = JsonParseValue(s, ix, depth + 1)
			If v = 0 Then Delete obj : Return 0
			v->Name = nm
			obj->Append(v)
			JsonSkipWs(s, ix)
			If ix >= Len(s) Then Delete obj : Return 0
			If s[ix] = Asc(",") Then ix += 1 : Continue Do
			If s[ix] = Asc("}") Then ix += 1 : Return obj
			Delete obj : Return 0
		Loop
	Case Asc("[")
		ix += 1
		Dim As JsonValue Ptr arr = JsonNewArray()
		JsonSkipWs(s, ix)
		If ix < Len(s) AndAlso s[ix] = Asc("]") Then ix += 1 : Return arr
		Do
			Dim As JsonValue Ptr v = JsonParseValue(s, ix, depth + 1)
			If v = 0 Then Delete arr : Return 0
			arr->Append(v)
			JsonSkipWs(s, ix)
			If ix >= Len(s) Then Delete arr : Return 0
			If s[ix] = Asc(",") Then ix += 1 : Continue Do
			If s[ix] = Asc("]") Then ix += 1 : Return arr
			Delete arr : Return 0
		Loop
	Case Asc("""")
		ix += 1
		Dim As String sv
		If Not JsonParseStringBody(s, ix, sv) Then Return 0
		Return JsonNewString(sv)
	Case Asc("t")
		If Mid(s, ix + 1, 4) = "true" Then ix += 4 : Return JsonNewBool(True)
		Return 0
	Case Asc("f")
		If Mid(s, ix + 1, 5) = "false" Then ix += 5 : Return JsonNewBool(False)
		Return 0
	Case Asc("n")
		If Mid(s, ix + 1, 4) = "null" Then ix += 4 : Return JsonNewNull()
		Return 0
	Case Asc("-"), Asc("0") To Asc("9")
		Dim As Integer startPos = ix
		If s[ix] = Asc("-") Then ix += 1
		While ix < Len(s)
			Select Case s[ix]
			Case Asc("0") To Asc("9"), Asc("."), Asc("e"), Asc("E"), Asc("+"), Asc("-")
				ix += 1
			Case Else
				Exit While
			End Select
		Wend
		If ix = startPos Then Return 0
		Return JsonNewNumber(Val(Mid(s, startPos + 1, ix - startPos)))
	End Select
	Return 0
End Function

Function JsonParse(ByRef s As String) As JsonValue Ptr
	Dim As Integer ix = 0
	Dim As JsonValue Ptr v = JsonParseValue(s, ix, 0)
	If v = 0 Then Return 0
	JsonSkipWs(s, ix)
	If ix <> Len(s) Then Delete v : Return 0   '' trailing garbage
	Return v
End Function
