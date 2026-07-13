'###############################################################################
'#  DateTimePicker.bi                                                          #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                    #
'###############################################################################

#include once "DateTimePicker.bi"

Namespace My.Sys.Forms
		Private Function DateTimePicker.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "calendarrightalign": Return @FRightAlign
			Case "checked": Return @FChecked
			Case "dateformat": Return @FDateFormat
			Case "customformat": Return FCustomFormat
			Case "shownone": Return @FShowNone
			Case "showupdown": Return @FShowUpDown
			Case "selecteddate": Return @FSelectedDate
			Case "selecteddatetime": Return @FSelectedDateTime
			Case "selectedtime": Return @FSelectedTime
			Case "tabindex": Return @FTabIndex
			Case "timepicker": Return @FTimePicker
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function DateTimePicker.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "calendarrightalign": CalendarRightAlign = QBoolean(Value)
			Case "checked": Checked = QBoolean(Value)
			Case "dateformat": DateFormat = *Cast(DateTimePickerFormat Ptr, Value)
			Case "customformat": CustomFormat = QWString(Value)
			Case "shownone": ShowNone = QBoolean(Value)
			Case "showupdown": ShowUpDown = QBoolean(Value)
			Case "selecteddate": SelectedDate = QLong(Value)
			Case "selecteddatetime": SelectedDateTime = QDouble(Value)
			Case "selectedtime": SelectedTime = QDouble(Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case "timepicker": TimePicker = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	
	Private Property DateTimePicker.CustomFormat ByRef As WString
		Return WGet(FCustomFormat)
	End Property
	
	Private Property DateTimePicker.CustomFormat(ByRef Value As WString)
		WLet(FCustomFormat, Value)
		If FHandle Then
			If FDateFormat = DateTimePickerFormat.CustomFormat Then
					DateTime_SetFormat(FHandle, FCustomFormat)
			End If
		End If
	End Property
	
	Private Property DateTimePicker.AutoNextPart As Boolean
		Return FAutoNextPart
	End Property
		
	Private Property DateTimePicker.AutoNextPart(Value As Boolean)
		FAutoNextPart = Value 
	End Property
	
	Private Property DateTimePicker.Checked As Boolean
		If FHandle Then
				FChecked = DateTime_GetSystemTime(FHandle, 0)
		End If
		Return FChecked
	End Property
	
	Private Property DateTimePicker.Checked(Value As Boolean)
		FChecked = Value
		If FHandle Then
				' The incoming date string should be in the format YYYYMMDD
				Dim As SYSTEMTIME pst
				Dim As Double sDateTime = This.SelectedDateTime
				pst.wYear  = Year(sDateTime)
				pst.wMonth = Month(sDateTime)
				pst.wDay   = Day(sDateTime)
				pst.wHour   = Hour(sDateTime)
				pst.wMinute = Minute(sDateTime)
				pst.wSecond = Second(sDateTime)
				If Value Then
					DateTime_SetSystemTime(FHandle, GDT_VALID, @pst)
				Else
					DateTime_SetSystemTime(FHandle, GDT_NONE, @pst)
				End If
		End If
	End Property
	
	Private Property DateTimePicker.SelectedDate As Long
		If FHandle Then
				Dim As SYSTEMTIME pst
				Dim As DWORD Result
				Result = DateTime_GetSystemTime(FHandle, @pst)
				FSelectedDate = DateSerial(pst.wYear, pst.wMonth, pst.wDay)
				If Result = GDT_NONE Then
					
				End If
		End If
		Return FSelectedDate
	End Property
	
	Private Property DateTimePicker.SelectedDate(Value As Long)
		FSelectedDate = Value
		If FHandle Then
				' The incoming date string should be in the format YYYYMMDD
				Dim As SYSTEMTIME pst
				pst.wYear  = Year(Value)
				pst.wMonth = Month(Value)
				pst.wDay   = Day(Value)
				Dim As Double sTime = This.SelectedTime
				pst.wHour   = Hour(sTime)
				pst.wMinute = Minute(sTime)
				pst.wSecond = Second(sTime)
				DateTime_SetSystemtime(FHandle, GDT_VALID, @pst)
		End If
	End Property
	
	Private Property DateTimePicker.SelectedDateTime As Double
		If FHandle Then
				Dim As SYSTEMTIME pst
				DateTime_GetSystemtime(FHandle, @pst)
				FSelectedDateTime = DateSerial(pst.wYear, pst.wMonth, pst.wDay) + TimeSerial(pst.wHour, pst.wMinute, pst.wSecond)
		End If
		Return FSelectedDateTime
	End Property
	
	Private Property DateTimePicker.SelectedDateTime(Value As Double)
		FSelectedDateTime = Value
		If FHandle Then
				Dim As SYSTEMTIME pst
				pst.wYear  = Year(Value)
				pst.wMonth = Month(Value)
				pst.wDay   = Day(Value)
				pst.wHour   = Hour(Value)
				pst.wMinute = Minute(Value)
				pst.wSecond = Second(Value)
				DateTime_SetSystemtime(FHandle, GDT_VALID, @pst)
		End If
	End Property
	
	Private Property DateTimePicker.Text ByRef As WString
			Return Base.Text
	End Property
	
	Private Property DateTimePicker.Text(ByRef Value As WString)
		If IsDate(Value) Then
			FText = Value
			Dim As Integer Pos1 = InStr(Value, ":")
			If Pos1 > 0 Then
				SelectedDate = DateValue(Trim(..Left(Value, Pos1 - 3)))
				SelectedTime = TimeValue(Trim(Mid(Value, Pos1 - 2)))
			Else
				SelectedDate = DateValue(Trim(Value))
			End If
		End If
	End Property
	
	Private Property DateTimePicker.SelectedTime As Double
		If FHandle Then
				Dim As SYSTEMTIME pst
				DateTime_GetSystemTime(FHandle, @pst)
				FSelectedTime = TimeSerial(pst.wHour, pst.wMinute, pst.wSecond)
		End If
		Return FSelectedTime
	End Property
	
	Private Property DateTimePicker.SelectedTime(Value As Double)
		FSelectedTime = Value
		If FHandle Then
				Dim As SYSTEMTIME pst
				Dim As Long lDate = This.SelectedDate
				pst.wYear  = Year(lDate)
				pst.wMonth = Month(lDate)
				pst.wDay   = Day(lDate)
				pst.wHour   = Hour(Value)
				pst.wMinute = Minute(Value)
				pst.wSecond = Second(Value)
				DateTime_SetSystemTime(FHandle, GDT_VALID, @pst)
		End If
	End Property
	
	Private Property DateTimePicker.CalendarRightAlign As Boolean
			FRightAlign = StyleExists(DTS_RIGHTALIGN)
		Return FRightAlign
	End Property
	
	Private Property DateTimePicker.CalendarRightAlign(Value As Boolean)
		FRightAlign = Value
			ChangeStyle DTS_RIGHTALIGN, Value
		If FHandle Then RecreateWnd
	End Property
	
	Private Property DateTimePicker.ShowUpDown As Boolean
			FShowUpDown = StyleExists(DTS_UPDOWN)
		Return FShowUpDown
	End Property
	
	Private Property DateTimePicker.ShowUpDown(Value As Boolean)
		FShowUpDown = Value
			ChangeStyle DTS_UPDOWN, Value
		If FHandle Then RecreateWnd
	End Property
	
	Private Property DateTimePicker.ShowNone As Boolean
			FShowNone = StyleExists(DTS_SHOWNONE)
		Return FShowNone
	End Property
	
	Private Property DateTimePicker.ShowNone(Value As Boolean)
		FShowNone = Value
			ChangeStyle DTS_SHOWNONE, Value
		If FHandle Then RecreateWnd
	End Property
	
	Private Property DateTimePicker.DateFormat As DateTimePickerFormat
		If FHandle Then
				Dim As DWORD dwStyle = GetWindowLong(FHandle, GWL_STYLE)
				If (dwStyle And DTS_LONGDATEFORMAT) Then
					FDateFormat = DateTimePickerFormat.LongDate
				ElseIf (dwStyle And DTS_SHORTDATEFORMAT) Then
					FDateFormat = DateTimePickerFormat.ShortDate
				ElseIf (dwStyle And DTS_SHORTDATECENTURYFORMAT) Then
					FDateFormat = DateTimePickerFormat.ShortDateCentury
				ElseIf (dwStyle And DTS_TIMEFORMAT) Then
					FDateFormat = DateTimePickerFormat.TimeFormat
				Else
					FDateFormat = DateTimePickerFormat.CustomFormat
				End If
		End If
		Return FDateFormat
	End Property
	
	Private Property DateTimePicker.DateFormat(Value As DateTimePickerFormat)
		FDateFormat = Value
			ChangeStyle DTS_LONGDATEFORMAT, Value = DateTimePickerFormat.LongDate
			ChangeStyle DTS_SHORTDATEFORMAT, Value = DateTimePickerFormat.ShortDate
			ChangeStyle DTS_SHORTDATECENTURYFORMAT, Value =  DateTimePickerFormat.ShortDateCentury
			ChangeStyle DTS_TIMEFORMAT, Value = DateTimePickerFormat.TimeFormat
			If FHandle Then
				' Need to rebuild the control
				RecreateWnd
				If Value = DateTimePickerFormat.CustomFormat Then
					DateTime_SetFormat(FHandle, FCustomFormat)
				End If
			End If
	End Property
	
	Private Property DateTimePicker.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property DateTimePicker.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property DateTimePicker.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property DateTimePicker.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
		Private Sub DateTimePicker.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			If Sender.Child Then
				With QDateTimePicker(Sender.Child)
					If .FDateFormat = DateTimePickerFormat.CustomFormat Then DateTime_SetFormat(.FHandle, .FCustomFormat)
					.SelectedDateTime = .SelectedDateTime
				End With
			End If
		End Sub
		
		Private Sub DateTimePicker.WndProc(ByRef Message As Message)
		End Sub
		
	
	Private Property DateTimePicker.TimePicker As Boolean 'David Change
		Return FTimePicker
	End Property
	
	Private Property DateTimePicker.TimePicker(Value As Boolean)'David Change
		If FTimePicker <> Value Then
			FTimePicker = Value
		End If
			If FTimePicker Then
				This.Style  = WS_CHILD Or DTS_TIMEFORMAT Or DTS_UPDOWN Or DTS_SHOWNONE ' NO repons
			Else
				This.Style  = WS_CHILD Or DTS_SHORTDATEFORMAT
			End If
			If FHandle Then RecreateWnd
	End Property
	
	
	Private Sub DateTimePicker.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_KEYDOWN
				PressedKey = LoWord(Message.wParam)
			Case WM_CHAR
				PressedKey = Message.wParam
			Case WM_KEYUP
				PressedKey = 0
				'David Change
				'bShift = GetKeyState(VK_SHIFT) And 8000
				'bCtrl = GetKeyState(VK_CONTROL) And 8000
				If ParentHandle>0 Then
					Select Case Message.wParam
					Case VK_RETURN, VK_ESCAPE,VK_LEFT,VK_RIGHT,VK_TAB 'VK_DOWN, VK_UP
						PostMessage(ParentHandle, CM_COMMAND, Message.wParam, 9993)
						'case VK_HOME,VK_END,VK_PRIOR,VK_NEXT,VK_INSERT,VK_DELETE,VK_BACK
						'case VK_MENU 'VK_CONTROL VK_SHIFT
						'print "TextBox VK_MENU: ",VK_MENU
						'case else
					End Select
				End If
				InvalidateRect(Handle,NULL,False)
				UpdateWindow Handle
			Case CM_NOTIFY 'WM_PAINT
				Dim lpChange As NMDATETIMECHANGE Ptr = Cast(NMDATETIMECHANGE Ptr, Message.lParam)
				Select Case lpChange->nmhdr.code
				Case DTN_DATETIMECHANGE
					If OnDateTimeChanged Then OnDateTimeChanged(*Designer, This)
					If FAutoNextPart AndAlso PressedKey >= Asc("0") AndAlso PressedKey <= Asc("9") Then
						Perform WM_KEYDOWN, VK_RIGHT, 0
					End If
				End Select
				InvalidateRect(Handle,Null,False)
				UpdateWindow Handle
			Case Else
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator DateTimePicker.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	
	Private Constructor DateTimePicker
		Dim As Boolean Result
		
		'Dim As INITCOMMONCONTROLSEX ICC
		
		'ICC.dwSize = SizeOF(ICC)
		
		'ICC.dwICC  = ICC_DATE_CLASSES
		
		'Result = InitCommonControlsEx(@ICC)
		'If Not Result Then InitCommonControls
		WLet(FFormat, "dd MMMM yyyy")
		FChecked = True
		FTabIndex          = -1
		FTabStop           = True
		With This
			WLet(FClassName, "DateTimePicker")
			WLet(FClassAncestor, "SysDateTimePick32")
				Base.RegisterClass WStr("DateTimePicker"), WStr("SysDateTimePick32")
				.ExStyle      = 0 'WS_EX_LEFT OR WS_EX_LTRREADING OR WS_EX_RIGHTSCROLLBAR OR WS_EX_CLIENTEDGE
				.Style        = WS_CHILD Or DTS_SHORTDATEFORMAT
				.ChildProc    = @WndProc
				.OnHandleIsAllocated = @HandleIsAllocated
			.SelectedDateTime = Now
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor DateTimePicker
			UnregisterClass "DateTimePicker",GetModuleHandle(NULL)
	End Destructor
End Namespace

