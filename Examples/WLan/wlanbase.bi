#pragma once

#ifndef UNICODE
	#define UNICODE
#endif

#ifndef _WIN32_WINNT
	#define _WIN32_WINNT &h0602
#endif

#ifdef __FB_64BIT__
	#libpath "./lib/win64"
#else
	#libpath "./lib/win32"
#endif

' --- Required headers (assumed present) ---
#include once "windows.bi"
#include once "win/shlobj.bi"
#include once "win/shlwapi.bi"
#include once "win/ole2.bi"
#include once "vbcompat.bi"
#include once "win/ocidl.bi"
#include once "win/objbase.bi"
#include once "win/strmif.bi"
#include once "win/dshow.bi"
#include once "crt.bi"
#include once "win/commdlg.bi"
#include once "crt/string.bi"

#include once "wlanapi.bi"

'' ----------------------------------------------------------
'' Helper functions
'' ----------------------------------------------------------

' Convert GUID to WString
Function GUID2WStr(ByRef g As GUID) ByRef As WString
	Static As WString * 64 guidStr
	StringFromGUID2(@g, @guidStr, 64)
	Function = guidStr
End Function

' Convert SSID (utf8) to WString
Function SSID2WStr(ByRef ssid As DOT11_SSID) ByRef As WString
	Dim wideCharCount As Long
	Dim result As Long
	Dim error_code As Long
	Static finalWString As WString * 129
	finalWString = "(hidden)"
	If ssid.uSSIDLength Then
		wideCharCount = MultiByteToWideChar(CP_UTF8, 0, @ssid.ucSSID, CInt(ssid.uSSIDLength), ByVal 0, 0)
		If wideCharCount Then
			Dim wstrBuffer As WString * 129
			result = MultiByteToWideChar(CP_UTF8, 0, @ssid.ucSSID, CInt(ssid.uSSIDLength), wstrBuffer, wideCharCount)
			If result > 0 Then
				' --- Conversion succeeded ---
				finalWString = Left(wstrBuffer, result)
				Return finalWString
			End If ' If result > 0
		End If
	End If
	Return finalWString
End Function

' Get authentication algorithm description
Function GetAuthAlgorithmString(algo As DOT11_AUTH_ALGORITHM) As String
	Select Case algo
	Case DOT11_AUTH_ALGO_80211_OPEN: Return "Open"
	Case DOT11_AUTH_ALGO_80211_SHARED_KEY: Return "Shared key"
	Case DOT11_AUTH_ALGO_WPA: Return "WPA"
	Case DOT11_AUTH_ALGO_WPA_PSK: Return "WPA-PSK"
	Case DOT11_AUTH_ALGO_WPA_NONE: Return "WPA-None"
	Case DOT11_AUTH_ALGO_RSNA: Return "RSNA"
	Case DOT11_AUTH_ALGO_RSNA_PSK: Return "RSNA-PSK"
	Case DOT11_AUTH_ALGO_WPA3: Return "WPA3"
	Case DOT11_AUTH_ALGO_WPA3_SAE: Return "WPA3-SAE"
	Case DOT11_AUTH_ALGO_OWE: Return "OWE"
	Case DOT11_AUTH_ALGO_IHV_START: Return "IHV start"
	Case DOT11_AUTH_ALGO_IHV_END: Return "IHV end"
	Case Else: Return "Unknown (" & algo & ")"
	End Select
End Function

' Get cipher algorithm description
Function GetCipherAlgorithmString(algo As DOT11_CIPHER_ALGORITHM) As String
	Select Case algo
	Case DOT11_CIPHER_ALGO_NONE: Return "None"
	Case DOT11_CIPHER_ALGO_WEP40: Return "WEP40"
	Case DOT11_CIPHER_ALGO_TKIP: Return "TKIP"
	Case DOT11_CIPHER_ALGO_CCMP: Return "CCMP"
	Case DOT11_CIPHER_ALGO_WEP104: Return "WEP104"
	Case DOT11_CIPHER_ALGO_BIP: Return "BIP"
	Case DOT11_CIPHER_ALGO_GCMP: Return "GCMP"
	Case DOT11_CIPHER_ALGO_GCMP_256: Return "GCMP-256"
	Case DOT11_CIPHER_ALGO_CCMP_256: Return "CCMP-256"
	Case DOT11_CIPHER_ALGO_BIP_GMAC_128: Return "BIP-GMAC-128"
	Case DOT11_CIPHER_ALGO_BIP_GMAC_256: Return "BIP-GMAC-256"
	Case DOT11_CIPHER_ALGO_BIP_CMAC_256: Return "BIP-CMAC-256"
	Case DOT11_CIPHER_ALGO_WEP: Return "WEP"
	Case Else: Return "Unknown (" & algo & ")"
	End Select
End Function

' PHY type description
Function phy_type_to_string(t As DOT11_PHY_TYPE) As String
	Select Case t
	Case dot11_phy_type_any         : Return "Any" 'Not initialized"
	Case dot11_phy_type_fhss        : Return "FHSS" 'Frequency-hopping spread spectrum"
	Case dot11_phy_type_dsss        : Return "DSSS" 'Direct-sequence spread spectrum "
	Case dot11_phy_type_irbaseband  : Return "IR" 'Infrared (IR) baseband"
	Case dot11_phy_type_ofdm        : Return "802.11a OFDM" 'Orthogonal frequency-division (multiplexing)"
	Case dot11_phy_type_hrdsss      : Return "802.11b HRDSSS" 'High rate"
	Case dot11_phy_type_erp         : Return "802.11g ERP" 'Extended rate"
	Case dot11_phy_type_ht          : Return "802.11n (HT)" 'High throughput"
	Case dot11_phy_type_vht         : Return "802.11ac (VHT)" 'Very high throughput PHY type"
	Case dot11_phy_type_dmg         : Return "802.11ad (DMG)" 'Directional multi-gigabit"
	Case dot11_phy_type_he          : Return "802.11ax (Wi-Fi 6)" 'Very high throughput PHY type"
	Case dot11_phy_type_eht         : Return "802.11be (Wi-Fi 7)" 'Extremely high throughput PHY type"
	Case dot11_phy_type_IHV_start   : Return "IHV_start"
	Case dot11_phy_type_IHV_end     : Return "IHV_end"
	Case Else : Return "Unknown"
	End Select
End Function
