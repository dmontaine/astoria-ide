' Gregorian Calendar Lunar Calendar
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.
' https://thuthuataccess.com/forum/thread-4765.html

#include once "Lunar.bi"

' pass in y, return the GanZhi (heavenly stem/earthly branch), 0=jiazi
Private Function Lunar.GanZhi(y As Integer) As String
	Dim TempStr As String
	Dim i As Long
	i = (y - 1864) Mod 60 'compute the GanZhi
	TempStr = Gan(i Mod 10) & Zhi(i Mod 12)
	Return TempStr
End Function

'compute the zodiac-animal string for the year
Private Function Lunar.YearAttribute(y As Integer) As String
	Return Animals((y - 1900) Mod 12)
End Function

'compute the solar term on the lunar calendar
Private Property Lunar.lSolarTerm() As String
	Dim baseDateAndTime As Double
	Dim newdate As Double
	Dim num As Double
	Dim y As Long
	Dim TempStr As String
	
	baseDateAndTime = DateValue("1900/1/6") + TimeValue("2:05:00")
	y = sYear
	TempStr = ""
	
	Dim i As Long
	For i = 1 To 24
		num = 525948.76 * (y - 1900) + TermInfo(i - 1)
		newdate = DateAdd("n", num, baseDateAndTime)  'computed in minutes; not in seconds, because that would overflow
		If Abs(DateDiff("d", newdate, sDate)) = 0 Then
			TempStr = SolarTerm(i - 1)
			Exit For
		End If
	Next
	
	Return TempStr
End Property

'compute holidays defined as the Nth weekday of a month
Private Property Lunar.wHoliday() As String
	Dim W As Long
	Dim i As Long
	Dim b As Long
	Dim FirstDay As Double
	Dim TempStr As String
	TempStr = ""
	b = UBound(wHolidayDB)
	For i = 0 To b
		If wHolidayDB(i).Month = sMonth Then  'when the month matches
			W = Weekday(sDate)
			If wHolidayDB(i).Recess = W Then  'only when the weekday also matches
				FirstDay = DateValue(sMonth & "/" & 1 & "/" & sYear) 'get the first day of the month
				If (DateDiff("ww", FirstDay, sDate) = wHolidayDB(i).Day) Then
					TempStr = *wHolidayDB(i).HolidayName
				End If
			End If
		End If
	Next
	Return TempStr
End Property

'find lunar-calendar holiday
Private Property Lunar.lHoliday() As String
	Dim i As Long
	Dim b As Long
	Dim TempStr As String
	Dim oy As Long
	Dim odate As Double
	Dim ndate As Double
	TempStr = ""
	b = UBound(lHolidayDB)
	If lMonth = 12 And (lDay = 29 Or lDay = 30) Then
		oy = lYear 'save the lunar year number
		odate = sDate
		ndate = sDate + 1
		Init(Year(ndate), Month(ndate), Day(ndate)) 'compute the next day's attributes
		If oy = lYear - 1 Then 'if the lunar year number has advanced by 1
			TempStr = "除夕"
			Init(Year(odate), Month(odate), Day(odate)) 'restore today's original data
		End If
	Else
		For i = 0 To b
			If (lHolidayDB(i).Month = lMonth) And _
				(lHolidayDB(i).Day = lDay) Then
				TempStr = *lHolidayDB(i).HolidayName
				Exit For
			End If
		Next
	End If
	Return TempStr
End Property

'find Gregorian-calendar holiday
Private Property Lunar.sHoliday() As String
	Dim i As Long
	Dim b As Long
	Dim TempStr As String
	
	TempStr = ""
	b = UBound(sHolidayDB)
	For i = 0 To b
		If (sHolidayDB(i).Month = sMonth) And _
			(sHolidayDB(i).Day = sDay) Then
			TempStr = *sHolidayDB(i).HolidayName
			Exit For
		End If
	Next
	Return TempStr
End Property

'lunar date name
Private Function Lunar.lDayName(d As Integer) As String
	Select Case d
	Case 0
	Case 10
		Return "初十"
	Case 20
		Return "二十"
	Case 30
		Return "三十"
	Case Else
		Return nStr2(d \ 10) & nStr1(d Mod 10)
	End Select
End Function

'initialize
Private Sub Lunar.Init(y As Integer, m As Integer, d As Integer)
	sYear = y
	sMonth = m
	sDay = d
	sDate = DateSerial(y, m, d)
	
	Dim DiffADate As Double, Counter As Integer, i As Integer, Temp As Integer
	DiffADate = DateDiff("d", DateValue("1900/1/31"), DateValue(y & "/" & m & "/" & d))

	Counter = -1
	lYear = 1900
	For i = lYear To 2199
		Temp = lYearDays(i)
		Counter = Counter + Temp
		If Counter >= DiffADate Then
			Counter = Counter - Temp
			Exit For
		End If
		lYear = lYear + 1
	Next
	
	Dim Leap As Integer
	Leap = LeapMonth(lYear)
	IsLeap = False
	lMonth = 1
	For i = 1 To 12
		If CBool(Leap > 0) And CBool(i = Leap + 1) And IsLeap = False Then
			IsLeap = True
			lMonth = lMonth - 1
			i = i - 1
			Temp = LeapDays(lYear)
		Else
			Temp = lMonthDays(lYear, i)
		End If
		If IsLeap = True And i <> Leap Then IsLeap = False
		Counter = Counter + Temp
		If Counter >= DiffADate Then
			Counter = Counter - Temp
			Exit For
		End If
		lMonth = lMonth + 1
	Next
	lDay = DiffADate - Counter
End Sub

'return which month (1-12) is the leap month of lunar year y, 0 if none
Private Function Lunar.LeapMonth(y As Integer) As Integer
	If y >= 1900 Then
		Return LunarInfo(y - 1900) And &HF
	Else
		Return 0
	End If
End Function

'return the number of days in the leap month of lunar year y
Private Function Lunar.LeapDays(y As Integer) As Integer
	If LunarInfo(y - 1900) And &HF Then
		If LunarInfo(y - 1900) And &H10000 Then
			Return 30
		Else
			Return 29
		End If
	Else
		Return 0
	End If
End Function

'return the total number of days in lunar year y, month m
Private Function Lunar.lMonthDays(y As Integer, m As Integer) As Integer
	If LunarInfo(y - 1900) And MonthMask(m - 1) Then
		Return 30
	Else
		Return 29
	End If
End Function

'return the total number of days in lunar year y
Private Function Lunar.lYearDays(y As Integer) As Integer
	Dim i As Integer
	Dim mYearDays As Integer = 348
	For i = 0 To 11
		If LunarInfo(y - 1900) And MonthMask(i) Then mYearDays = mYearDays + 1
	Next
	mYearDays = mYearDays + LeapDays(y)
	Return mYearDays
End Function


