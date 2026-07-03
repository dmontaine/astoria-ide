#pragma once

' Dark mode support has been disabled. The previous implementation resolved
' undocumented uxtheme.dll functions by ordinal number and patched a loaded
' module's import table at runtime (IatHook.bi) - both are inherently fragile
' (ordinals and internal behavior are not guaranteed stable across Windows
' updates) and were the source of reported instability. This stub preserves
' the same public interface as inert no-ops so every existing call site
' keeps compiling and behaves exactly as it already did at runtime (dark
' mode was already forced off via SetDarkMode False, False).

Dim Shared As Boolean g_darkModeSupported
Dim Shared As Boolean g_darkModeEnabled
Dim Shared As DWORD g_buildNumber

#define nullptr 0

	Declare Function ShouldAppsUseDarkMode() As BOOL
	Declare Function AllowDarkModeForWindow(hWnd As hWnd, allow As BOOL) As BOOL
	Declare Function IsHighContrast() As BOOL
	Declare Sub RefreshTitleBarThemeColor(hWnd As hWnd)
	Declare Sub SetTitleBarThemeColor(hWnd As hWnd, dark As BOOL)
	Declare Function IsColorSchemeChangeMessage Overload(lParam As lParam) As BOOL
	Declare Function IsColorSchemeChangeMessage Overload(message As UINT, lParam As lParam) As BOOL
	Declare Sub AllowDarkModeForApp(allow As BOOL)
	Declare Sub EnableDarkScrollBarForWindowAndChildren(hwnd As hwnd)
	Declare Sub InitDarkMode()
	Declare Function IsWindows11() As BOOL
Declare Sub SetDarkMode(useDarkMode As Boolean, fixDarkScrollbar As Boolean)

	#include once "DarkMode.bas"
