'#########################################################
'#  RenameRefactor.bi                                    #
'#  This file is part of AstoriaIDE                      #
'#########################################################

'' Identifier-aware line rewriting for the designer's rename refactoring (ROADMAP 13.17).
''
'' Kept in its own file rather than inline in TabWindow.bas so that it can be tested directly:
'' the tokenizer is the part with the interesting failure modes (strings, comments, token
'' boundaries), and TabWindow.bas cannot be included from a test harness.
'' See Examples/Integration/C3_RenameRefactor.

#pragma once

'' Self-contained: UString is a framework type, and this header must compile on its own so the
'' test can include it without dragging in TabWindow.bi. #include once makes it a no-op inside the
'' IDE build, where the framework is already included.
#include once "mff/UString.bi"

Private Function IsIdentifierChar(ByVal ch As UInteger) As Boolean
	Select Case ch
	Case Asc("0") To Asc("9"), Asc("A") To Asc("Z"), Asc("a") To Asc("z"), Asc("_")
		Return True
	End Select
	Return False
End Function

'' Replaces whole-identifier occurrences of OldName in one line, leaving string literals and
'' comment text alone.
''
'' Whole-identifier matching is what makes this safe, and it is doing more work than it looks:
''   - `Label1_Click` is a single token, so renaming `Label1` does NOT touch the handler's name.
''     Keeping the handler name is the existing, deliberate policy (ROADMAP 13.17) and this
''     preserves it for free rather than by a special case.
''   - `Label10` and `MyLabel1` are likewise single tokens and are left alone.
''   - Text inside strings is skipped, so a caption that happens to read "Label1" survives, as does
''     the `.Name = "Label1"` the designer owns and rewrites itself.
Private Function RenameIdentifierInLine(ByRef Line_ As WString, ByRef OldName As WString, ByRef NewName As WString) As UString
	Dim As UString Res
	Dim As Integer i, n = Len(Line_)
	Dim As UString LOld = LCase(OldName)
	While i < n
		Dim As UInteger ch = Line_[i]
		If ch = Asc("""") Then
			'' Copy the literal verbatim. A doubled "" inside it reads as a quote followed by the
			'' start of another literal, which lands on the same place either way.
			Res &= WChr(ch)
			i += 1
			While i < n
				Res &= WChr(Line_[i])
				If Line_[i] = Asc("""") Then
					i += 1
					Exit While
				End If
				i += 1
			Wend
		ElseIf ch = Asc("'") Then
			'' Rest of the line is a comment.
			While i < n
				Res &= WChr(Line_[i])
				i += 1
			Wend
		ElseIf IsIdentifierChar(ch) Then
			Dim As Integer s = i
			While i < n AndAlso IsIdentifierChar(Line_[i])
				i += 1
			Wend
			Dim As UString Tok = Mid(Line_, s + 1, i - s)
			If LCase(Tok) = LOld Then Res &= NewName Else Res &= Tok
		Else
			Res &= WChr(ch)
			i += 1
		End If
	Wend
	Return Res
End Function
