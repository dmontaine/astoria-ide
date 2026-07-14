
#include once "inc/mongoose.bi"
' demo for udp(sntp-time-sync)
Dim Shared s_boot_timestamp As time_t = 0
Dim Shared s_sntp_conn As mg_connection Ptr = NULL

Private Sub sfn cdecl (ByVal c As mg_connection Ptr, ByVal ev As Long, ByVal ev_data As Any Ptr)
	If ev = MG_EV_SNTP_TIME Then
		Dim curtime As ULongInt = mg_now()
		MG_INFO("SNTP-updated current time is: %llu ms from epoch", curtime)
		Scope
			Dim t As ULongInt = *CPtr(ULongInt Ptr, ev_data)
			s_boot_timestamp = (t - mg_millis()) / 1000
			MG_INFO("Got SNTP time: %llu ms from epoch, ", t)
			
		End Scope
	ElseIf ev = MG_EV_CLOSE Then
		s_sntp_conn = NULL
	End If
End Sub

Private Sub timer_fn cdecl (ByVal arg As Any Ptr)
	Dim mgr As mg_mgr Ptr = CPtr(mg_mgr Ptr, arg)
	If s_sntp_conn = NULL Then
		s_sntp_conn = mg_sntp_connect(mgr, NULL, Cast(Any Ptr, @sfn), NULL)
	End If
	If s_sntp_conn <> NULL Then
		mg_sntp_request(s_sntp_conn)
	End If
End Sub

Dim mgr As mg_mgr
mg_mgr_init(@mgr)
mg_log_set(MG_LL_DEBUG)
mg_timer_add(@mgr, 5000, MG_TIMER_REPEAT Or MG_TIMER_RUN_NOW, Cast(Any Ptr, @timer_fn), @mgr)
While True
	mg_mgr_poll(@mgr, 300)
Wend
mg_mgr_free(@mgr)
Sleep
