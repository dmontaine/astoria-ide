#include once "Registry.bi"

Namespace My.Sys.Registry
		Private Function ReadRegistry(ByVal Group As HKEY, ByVal Section As LPCWSTR, ByVal Key As LPCWSTR) As String
			'' AstoriaIDE T-SON-4 (2026-07-12): rewritten to the standard two-call registry-query
			'' pattern instead of a fixed 2048-byte buffer. The old fixed buffer silently returned
			'' "" (not a truncated value) for anything longer: RegQueryValueEx fails with
			'' ERROR_MORE_DATA when the buffer is too small, so the old `If lResult = 0` guard
			'' skipped the whole decode. First call gets the exact required size; second call reads
			'' into a buffer sized for it. Also fixed a byte/char unit mismatch in the REG_SZ
			'' branch: lValueLength is a BYTE count but was passed directly as a CHARACTER count to
			'' Left() on a WString (registry string data here is UTF-16, since Section/Key are
			'' LPCWSTR -> the W-variant Reg* APIs).
			Dim As DWORD lDataTypeValue, lValueLength
			Dim As String Tstr1, Tstr2
			Dim As String sValue = ""
			Dim As HKEY lKeyValue
			Dim As Integer lResult
			Dim As Double td
			Dim As UByte Ptr pBuffer

			lResult = RegOpenKey(Group, Section, @lKeyValue)
			If lResult <> 0 Then Return ""

			lValueLength = 0
			lResult = RegQueryValueEx(lKeyValue, Key, 0, @lDataTypeValue, 0, @lValueLength)
			If lResult <> 0 OrElse lValueLength = 0 Then
				RegCloseKey(lKeyValue)
				Return ""
			End If

			pBuffer = _CAllocate(lValueLength)
			If pBuffer = 0 Then
				RegCloseKey(lKeyValue)
				Return ""
			End If

			lResult = RegQueryValueEx(lKeyValue, Key, 0, @lDataTypeValue, pBuffer, @lValueLength)

			If (lResult = 0) Then

				Select Case lDataTypeValue
				Case REG_DWORD
					If lValueLength >= 4 Then
						td = pBuffer[0] + &H100& * pBuffer[1] + &H10000 * pBuffer[2] + &H1000000 * CDbl(pBuffer[3])
						sValue = Format(td, "000")
					End If
				Case REG_BINARY
					' Return a binary field as a hex string (2 chars per byte)
					Tstr2 = ""
					For I As Integer = 0 To lValueLength - 1
						Tstr1 = Hex(pBuffer[I])
						If Len(Tstr1) = 1 Then Tstr1 = "0" & Tstr1
						Tstr2 += Tstr1
					Next
					sValue = Tstr2
				Case Else
					If lValueLength >= SizeOf(WString) Then
						sValue = Left(*Cast(WString Ptr, pBuffer), (lValueLength \ SizeOf(WString)) - 1)
					End If
				End Select

			End If

			_Deallocate(pBuffer)
			RegCloseKey(lKeyValue)

			Return sValue

		End Function

		'' Digits-only check (Trim'd) for the ValDWord path below -- CUInt() on non-numeric input
		'' silently returns 0 rather than failing, which would write 0 to the registry instead of
		'' rejecting the bad input.
		Private Function IsValidUInt(ByRef s As String) As Boolean
			Dim As String t = Trim(s)
			If Len(t) = 0 Then Return False
			For i As Integer = 1 To Len(t)
				If Mid(t, i, 1) < "0" OrElse Mid(t, i, 1) > "9" Then Return False
			Next
			Return True
		End Function

		Private Sub WriteRegistry(ByVal Group As HKEY, ByVal Section As LPCWSTR, ByVal Key As LPCWSTR, ByVal ValType As InTypes, value As String)
			'' AstoriaIDE T-SON-4 (2026-07-12): three fixes.
			'' 1. RegCreateKey's result was discarded, so a failed key creation still fell through to
			''    RegSetValueEx on an invalid handle -- now bails immediately on failure.
			'' 2. ValDWord: CUInt(value) on non-numeric input silently wrote 0 -- now validated first
			''    (IsValidUInt above) and skipped (no write) if invalid.
			'' 3. ValString: sNewVal was `String * 2048` (1 byte/char, ANSI layout) but RegSetValueEx
			''    here is the WIDE API (Section/Key are LPCWSTR) writing REG_SZ, which Windows reads
			''    back as UTF-16 (2 bytes/char) -- verified empirically (raw-byte dump) that this
			''    produced garbled, non-roundtripping string data on every write. Switched the buffer
			''    to `WString * 2048` (2 bytes/char, matching the API) and the byte-length argument
			''    from Len() (chars) to Len()*SizeOf(WString) (bytes) to match.
			'' Types other than ValDWord/ValString remain unimplemented no-ops, as before -- adding
			'' handlers for the rest is out of this fix's scope.
			Dim lResult As Integer
			Dim lKeyValue As HKEY
			Dim lNewVal As DWORD
			Dim sNewVal As WString * 2048

			lResult = RegCreateKey(Group, Section, @lKeyValue)
			If lResult <> 0 Then Return

			If ValType = ValDWord Then
				If IsValidUInt(value) Then
					lNewVal = CUInt(value)
					lResult = RegSetValueEx(lKeyValue, Key, 0&, ValType, Cast(Byte Ptr,@lNewVal), SizeOf(DWORD))
				End If
			ElseIf ValType = ValString Then
				sNewVal = value & Chr(0)
				lResult = RegSetValueEx(lKeyValue, Key, 0&, ValString, Cast(Byte Ptr,@sNewVal), Len(sNewVal) * SizeOf(WString))
			End If

			RegFlushKey(lKeyValue)
			RegCloseKey(lKeyValue)

		End Sub
End Namespace

