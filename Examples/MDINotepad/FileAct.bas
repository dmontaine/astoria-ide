' FileAct - file handling
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#pragma once
#include once "FileAct.bi"

'Return the hash algorithm name string for algorithm code Algorithm
Private Function AlgorithmWStr(ByVal Algorithm As HashAlgorithms = MD5) ByRef As WString
	Select Case Algorithm
	Case MD2
		Return WStr("MD2")
	Case MD4
		Return WStr("MD4")
	Case MD5
		Return WStr("MD5")
	Case SHA1
		Return WStr("SHA1")
	Case SHA256
		Return WStr("SHA256")
	Case Else
		Return WStr("SHA512")
	End Select
End Function

'Return the hash value of data nData (size nSize) using hash algorithm code Algorithm
Private Function GetHash(nData As Any Ptr, nSize As Integer, ByVal Algorithm As HashAlgorithms = MD5, ByVal nLCase As Boolean = False) As String
	Dim As Byte Ptr phalg, phhash
	Dim As ULong lhashlength, LRESULT, nlength
	Dim As String sbinhash, shex
	
	BCryptOpenAlgorithmProvider VarPtr(phalg), AlgorithmWStr(Algorithm), 0, 0 ' we want phalg
	BCryptCreateHash phalg, @phhash, NULL, 0, 0, 0, 0 ' we want phhash
	BCryptHashData(phhash, nData, nSize, 0 )
	BCryptGetProperty phalg, BCRYPT_HASH_LENGTH, Cast(PUCHAR, @lhashlength), 4, @LRESULT, 0
	sbinhash = String(lhashlength, 0)
	BCryptFinishHash phhash, StrPtr(sbinhash), lhashlength, 0
	BCryptDestroyHash phhash
	BCryptCloseAlgorithmProvider phalg, 0
	nlength = Len(sbinhash)*2 + 1 ' + 1 to accomodate a null terminator
	shex = Space(nlength)
	CryptBinaryToStringA StrPtr(sbinhash), Len(sbinhash), CRYPT_STRING_HEXRAW + CRYPT_STRING_NOCRLF, StrPtr(shex), @nlength
	
	If nLCase Then
		Return Left(shex, nlength)
	Else
		Return UCase(Left(shex, nlength))
	End If
End Function

'Get the data of file FileName into rtnData; returns the file size
Private Function FileDataGet Overload (ByRef FileName As Const WString, ByRef rtnData As Any Ptr) As UInteger
	Dim h As Integer = FreeFile
	Dim fsize As UInteger = 0
	
	If Open(FileName For Binary Access Read As #h) <> 0 Then Return fsize
	fsize= LOF(h)
	
	If fsize Then
		If rtnData Then
			rtnData = Reallocate(rtnData, fsize + 1)
		Else
			rtnData = CAllocate(fsize + 1)
		End If
		If Get(#h, , *Cast(UByte Ptr, rtnData), fsize) Then fsize = 0
	End If
	Close #h
	Return fsize
End Function

'Write data setData (size setSize) to file FileName; returns true on success
Private Function FileDataSet(ByRef FileName As Const WString, ByRef setData As Any Ptr, setSize As Integer) As Integer
	Dim h As Integer = FreeFile
	If Open(FileName For Binary Access Write As #h) <> 0 Then Return False
	If Put(#h, , *Cast(UByte Ptr, setData), setSize) Then Return False
	Close #h
	Return True
End Function

'Convert seconds Sec to a time string using the specified hour format hfmt, minute format mfmt, second format sfmt
Private Function Sec2Time(Sec As Single, hfmt As String = "#,#0", mfmt As String = "#00", sfmt As String = "#00") ByRef As String
	Dim h As Long
	Dim m As Long
	Dim s As Single
	Static r As String
	h = Sec \ 3600
	m = (Sec - h * 3600) \ 60
	s = Sec - h * 3600 - m * 60
	r = Format(h, hfmt) & ":" & Format(m, mfmt) & ":" & Format(s, sfmt)
	Return r
End Function

'Convert byte count Bytes to a string with a unit, using the specified integer format iFmt and decimal format sFmt
Private Function Bytes2Str(Bytes As Double, iFmt As String = "#,#0", sFmt As String = "#0.0") ByRef As String
	Dim dbb As Double
	Dim dba As Double
	Dim i As Long
	Dim u As String
	Static r As String
	
	dbb = Bytes
	
	Do
		dba = dbb / 1024
		If dba < 1 Then Exit Do
		i = i + 1
		dbb = dba
	Loop While True
	
	Select Case i
	Case 0
		u = " B"
	Case 1
		u = " KB"
	Case 2
		u = " MB"
	Case 3
		u = " GB"
	Case 4
		u = " TB"
	End Select
	If i Then
		r = Format(dbb, sFmt) & u
	Else
		r = Format(dbb, iFmt) & u
	End If
	Return r
End Function

'Return the byte count from the WFD
Private Function WFD2Bytes(wfd As WIN32_FIND_DATA Ptr) As ULongInt
	Return (Cast(ULONGLONG, wfd->nFileSizeHigh) Shl 32) Or wfd->nFileSizeLow
	'Return wfd->nFileSizeHigh * (MAXDWORD + 1) + wfd->nFileSizeLow
End Function

'Return the date/time value of FILETIME ft
Private Function WFD2TimeSerial(ft As FILETIME Ptr) As Double
	Dim lft As FILETIME
	FileTimeToLocalFileTime(ft, @lft)
	Dim st As SYSTEMTIME
	FileTimeToSystemTime(@lft, @st)
	Return DateSerial(st.wYear, st.wMonth, st.wDay) + TimeSerial(st.wHour, st.wMinute, st.wSecond)
End Function

'Return a time string for FILETIME ft using format tf
Private Function WFD2TimeStr(ft As FILETIME Ptr, tf As WString = "yyyy/mm/dd hh:mm:ss") As String
	Dim lft As FILETIME
	FileTimeToLocalFileTime(ft, @lft)
	Dim st As SYSTEMTIME
	FileTimeToSystemTime(@lft, @st)
	Dim dt As Double = DateSerial(st.wYear, st.wMonth, st.wDay) + TimeSerial(st.wHour, st.wMinute, st.wSecond)
	Return Format(dt, tf)
End Function

'Return a time string RtnPtr for FILETIME ft using format tf; returns the string length
Private Function WFD2TimeWStr(ft As FILETIME Ptr, ByRef tf As Const WString, ByRef RtnPtr As WString Ptr) As Integer
	Dim lft As FILETIME
	FileTimeToLocalFileTime(ft, @lft)
	Dim st As SYSTEMTIME
	FileTimeToSystemTime(@lft, @st)
	Dim dt As Double = DateSerial(st.wYear, st.wMonth, st.wDay) + TimeSerial(st.wHour, st.wMinute, st.wSecond)
	WLet(RtnPtr, Format(dt, tf))
	Return Len(*RtnPtr)
End Function

'Compare two WFDs; returns true on success
Private Function WFDCompare(ByVal sWFD As WIN32_FIND_DATA Ptr, ByVal tWFD As WIN32_FIND_DATA Ptr, ByVal chkData As Long = 0, ByVal chkMode As Long = 0) As Long
	Dim st As FILETIME Ptr
	Dim tt As FILETIME Ptr
	Dim suli As ULongInt
	Dim tuli As ULongInt
	
	Select Case chkData
	Case 0 'size
		suli = WFD2Bytes(sWFD)
		tuli = WFD2Bytes(tWFD)
	Case 1 'lastwritetime
		st = @sWFD->ftLastWriteTime
		tt = @tWFD->ftLastWriteTime
	Case 2 'creationtime
		st = @sWFD->ftCreationTime
		tt = @tWFD->ftCreationTime
	Case 3 'lastaccesstime
		st = @sWFD->ftLastAccessTime
		tt = @tWFD->ftLastAccessTime
	End Select
	
	Select Case chkData
	Case 0
		Select Case chkMode
		Case 0 '>
			If suli > tuli Then
				Return True
			Else
				Return False
			End If
		Case 1 '<
			If suli < tuli Then
				Return True
			Else
				Return False
			End If
		Case 2 '<>
			If suli <> tuli Then
				Return True
			Else
				Return False
			End If
		Case 3 '=
			If suli = tuli Then
				Return True
			Else
				Return False
			End If
		End Select
	Case Else
		Select Case chkMode
		Case 0 '>
			If memcmp(st, tt, SizeOf(FILETIME)) > 0 Then
			'If CompareFileTime(st, tt) > 0 Then
				Return True
			Else
				Return False
			End If
		Case 1 '<
			If memcmp(st, tt, SizeOf(FILETIME)) < 0 Then
			'If CompareFileTime(st, tt) < 0 Then
				Return True
			Else
				Return False
			End If
		Case 2 '<>
			If memcmp(st, tt, SizeOf(FILETIME)) <> 0 Then
			'If CompareFileTime(st, tt) <> 0 Then
				Return True
			Else
				Return False
			End If
		Case 3 '=
			If memcmp(st, tt, SizeOf(FILETIME)) = 0 Then
			'If CompareFileTime(st, tt) = 0 Then
				Return True
			Else
				Return False
			End If
		End Select
	End Select
	Return True
End Function

'Get the WIN32_FIND_DATA structure wfd for file FileName; returns true on success
Private Function WFDGet(FileName As Const WString, ByRef wfd As WIN32_FIND_DATA Ptr) As Integer
	Dim hFind As HANDLE = FindFirstFile(FileName, wfd)
	If hFind = INVALID_HANDLE_VALUE Then
		hFind = FindFirstFile(FileName & "\?", wfd)
		If hFind = INVALID_HANDLE_VALUE Then Return False
	End If
	FindClose(hFind)
	Return True
End Function

