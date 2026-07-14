#pragma once

' Dark mode support using only documented, stable Win32 APIs.
' No ordinal resolution, no IAT hooking, no internal structure probing -
' see PROJECT_STATUS.md for the history of why the previous implementation
' (ordinal-resolved uxtheme calls + IAT hooking) was removed.
'
' Title bar dark mode: DwmSetWindowAttribute (dwmapi.dll) - documented
' Control theming:      SetWindowTheme (uxtheme.dll) - documented
' Version detection:    RtlGetVersion (ntdll.dll) - documented WDK API
' System preference:    Registry read (HKCU) - documented
' Change notification:  WM_SETTINGCHANGE / "ImmersiveColorSet" - documented
'
' Minimum requirement:  Windows 10 version 1809 (build 17763)
' Works fully on:       Windows 10 2004+ and Windows 11
'
' All per-control SetDark methods in the framework are fully intact and
' activate automatically when g_darkModeEnabled is set to True.

Dim Shared As Boolean g_darkModeSupported
Dim Shared As Boolean g_darkModeEnabled
Dim Shared As DWORD g_buildNumber

#define nullptr 0

' DWMWA constants for title bar dark mode
#define DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1  19
#define DWMWA_USE_IMMERSIVE_DARK_MODE               20

' Windows build thresholds
#define WIN10_1809  17763
#define WIN10_2004  19041
#define WIN11       22000

' Not in the bundled FreeBASIC 1.10.1 dwmapi.bi (there isn't one) - declared
' here by name against the bundled libdwmapi.dll.a import lib. The explicit
' Alias is required: without it FB's default language linkage mangles the
' symbol to all-caps and the link fails with an undefined reference.
Declare Function DwmSetWindowAttribute Lib "dwmapi" Alias "DwmSetWindowAttribute" (ByVal hwnd As HWND, ByVal dwAttribute As DWORD, ByVal pvAttribute As Any Ptr, ByVal cbAttribute As DWORD) As HRESULT

Declare Function ShouldAppsUseDarkMode() As BOOL
Declare Function AllowDarkModeForWindow(hWnd As HWND, allow As BOOL) As BOOL
Declare Function IsHighContrast() As BOOL
Declare Sub RefreshTitleBarThemeColor(hWnd As HWND)
Declare Sub SetTitleBarThemeColor(hWnd As HWND, dark As BOOL)
Declare Function IsColorSchemeChangeMessage Overload(lParam As LPARAM) As BOOL
Declare Function IsColorSchemeChangeMessage Overload(message As UINT, lParam As LPARAM) As BOOL
Declare Sub AllowDarkModeForApp(allow As BOOL)
Declare Sub EnableDarkScrollBarForWindowAndChildren(hwnd As HWND)
Declare Sub BroadcastThemeChangedToChildren(hwnd As HWND)
Declare Sub InitDarkMode()
Declare Function IsWindows11() As BOOL
Declare Sub SetDarkMode(useDarkMode As Boolean, fixDarkScrollbar As Boolean, DoBroadcast As Boolean = True)

#include once "DarkMode.bas"
