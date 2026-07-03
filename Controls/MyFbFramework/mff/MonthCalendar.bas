'################################################################################
'#  MonthCalendar.bi                                                            #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
'################################################################################

#include once "MonthCalendar.bi"

Namespace My.Sys.Forms
		Private Function MonthCalendar.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "selecteddate": FSelectedDate = SelectedDate: Return @FSelectedDate
			Case "weeknumbers": Return @FWeekNumbers
			Case "todaycircle": Return @FTodayCircle
			Case "todayselector": Return @FTodaySelector
			Case "trailingdates": Return @FTrailingDates
			Case "shortdaynames": Return @FShortDayNames
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function MonthCalendar.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "selecteddate": SelectedDate = QLong(Value)
				Case "weeknumbers": WeekNumbers = QBoolean(Value)
				Case "todaycircle": TodayCircle = QBoolean(Value)
				Case "todayselector": TodaySelector = QBoolean(Value)
				Case "trailingdates": TrailingDates = QBoolean(Value)
				Case "shortdaynames": ShortDayNames = QBoolean(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property MonthCalendar.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property MonthCalendar.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property MonthCalendar.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property MonthCalendar.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property MonthCalendar.SelectedDate() As Long
		If This.FHandle Then
				Dim As SYSTEMTIME pst
				MonthCal_GetCurSel(This.FHandle, @pst)
				FSelectedDate = DateSerial(pst.wYear, pst.wMonth, pst.wDay)
		End If
		Return FSelectedDate
	End Property
	
	Private Property MonthCalendar.SelectedDate(ByVal Value As Long)
		If This.FHandle Then
				Dim As SYSTEMTIME pst
				pst.wYear  = Year(Value)
				pst.wMonth = Month(Value)
				pst.wDay   = Day(Value)
				MonthCal_SetCurSel(This.FHandle, @pst)
		End If
		FSelectedDate = Value
	End Property
	
	
	Private Property MonthCalendar.WeekNumbers() As Boolean
		If This.FHandle Then
				FWeekNumbers = StyleExists(MCS_WEEKNUMBERS)
		End If
		Return FWeekNumbers
	End Property
	
	Private Property MonthCalendar.WeekNumbers(ByVal Value As Boolean)
		If This.FHandle Then
				ChangeStyle MCS_WEEKNUMBERS, Value
				This.Repaint
		End If
		FWeekNumbers = Value
	End Property
	
	Private Property MonthCalendar.TodayCircle() As Boolean
		If This.FHandle Then
				FTodayCircle = Not StyleExists(MCS_NOTODAYCIRCLE)
		End If
		Return FTodayCircle
	End Property
	
	Private Property MonthCalendar.TodayCircle(ByVal Value As Boolean)
		If This.FHandle Then
				ChangeStyle MCS_NOTODAYCIRCLE, Not Value
				This.Repaint
		End If
		FTodayCircle = Value
	End Property
	
	Private Property MonthCalendar.TodaySelector() As Boolean
		If This.FHandle Then
				FTodaySelector = Not StyleExists(MCS_NOTODAY)
		End If
		Return FTodaySelector
	End Property
	
	Private Property MonthCalendar.TodaySelector(ByVal Value As Boolean)
		If This.FHandle Then
				ChangeStyle MCS_NOTODAY, Not Value
				This.Repaint
		End If
		FTodaySelector = Value
	End Property
	
	Private Property MonthCalendar.TrailingDates() As Boolean
		If This.FHandle Then
				This.Repaint
		End If
		Return FTrailingDates
	End Property
	
	Private Property MonthCalendar.TrailingDates(ByVal Value As Boolean)
		If This.FHandle Then
				This.Repaint
		End If
		FTrailingDates = Value
	End Property
	
	Private Property MonthCalendar.ShortDayNames() As Boolean
		If This.FHandle Then
		End If
		Return FShortDayNames
	End Property
	
	Private Property MonthCalendar.ShortDayNames(ByVal Value As Boolean)
		If This.FHandle Then
				This.Repaint
		End If
		FShortDayNames = Value
	End Property
	
		Private Sub MonthCalendar.HandleIsAllocated(ByRef Sender As My.Sys.Forms.Control)
			If Sender.Child Then
				With QMonthCalendar(Sender.Child)
					
				End With
			End If
		End Sub
		
		Private Sub MonthCalendar.WndProc(ByRef Message As Message)
		End Sub
	
	Private Sub MonthCalendar.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case CM_NOTIFY
				Dim lpChange As NMSELCHANGE Ptr = Cast(NMSELCHANGE Ptr, Message.lParam)
				Select Case lpChange->nmhdr.code
				Case MCN_SELECT
					If OnClick Then OnClick(*Designer, This)
					If OnSelect Then OnSelect(*Designer, This)
				Case MCN_SELCHANGE
					If OnSelectionChanged Then OnSelectionChanged(*Designer, This)
				End Select
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator MonthCalendar.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	
	Private Constructor MonthCalendar
		With This
			WLet(FClassName, "MonthCalendar")
			FTabIndex          = -1
			FTabStop           = True
				.RegisterClass "MonthCalendar", "SysMonthCal32"
				WLet(FClassAncestor, "SysMonthCal32")
				.Style        = WS_CHILD
				.ExStyle      = 0
				.ChildProc    = @WndProc
				.OnHandleIsAllocated = @HandleIsAllocated
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor MonthCalendar
			UnregisterClass "MonthCalendar",GetModuleHandle(NULL)
	End Destructor
End Namespace

