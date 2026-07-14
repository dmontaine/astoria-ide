#include "Windows.bi"

#include "DarkMode.bi"

' === Private helper: get the true Windows version via RtlGetVersion ===

Private Function GetTrueWindowsVersion() As DWORD
	' RtlGetVersion is exported by name from ntdll.dll.
	' It returns the real OS version without compatibility-shim lying
	' (unlike GetVersionEx, which lies to apps without a compatible manifest).
	Dim As OSVERSIONINFOW osvi
	osvi.dwOSVersionInfoSize = SizeOf(OSVERSIONINFOW)

	Dim As Any Ptr hNtdll = GetModuleHandleW("ntdll.dll")
	If hNtdll = 0 Then Return 0

	Dim As Function(ByVal lpVersionInfo As LPOSVERSIONINFOW) As LONG RtlGetVersion
	RtlGetVersion = Cast(Any Ptr, GetProcAddress(hNtdll, "RtlGetVersion"))
	If RtlGetVersion = 0 Then Return 0

	If RtlGetVersion(@osvi) <> 0 Then Return 0

	Return osvi.dwBuildNumber
End Function

' === Private helper: read system dark mode preference from registry ===

Private Function ReadSystemDarkModePreference() As BOOL
	' Reads HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme
	' Returns TRUE if the system is in dark mode, FALSE if light mode or can't read
	Dim As HKEY hKey
	Dim As DWORD dwType, dwValue, dwSize
	Dim As Long result

	result = RegOpenKeyExW( _
		HKEY_CURRENT_USER, _
		"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", _
		0, _
		KEY_READ, _
		@hKey)

	If result <> ERROR_SUCCESS Then Return False

	dwSize = SizeOf(DWORD)
	result = RegQueryValueExW(hKey, "AppsUseLightTheme", NULL, @dwType, Cast(LPBYTE, @dwValue), @dwSize)
	RegCloseKey(hKey)

	If result <> ERROR_SUCCESS Then Return False
	If dwType <> REG_DWORD Then Return False

	' AppsUseLightTheme: 0 = dark, 1 = light
	Return (dwValue = 0)
End Function

' === Public functions ===

Function ShouldAppsUseDarkMode() As BOOL
	' Checks the live system preference from registry - this reads the
	' CURRENT system setting, not a cached value.
	If Not g_darkModeSupported Then Return False
	Return ReadSystemDarkModePreference()
End Function

Function AllowDarkModeForWindow(hWnd As HWND, allow As BOOL) As BOOL
	' Apply or remove the dark Explorer theme from a window.
	' For common controls (ListViews, TreeViews, ScrollBars, etc.),
	' SetWindowTheme with "DarkMode_Explorer" enables the dark visual style.
	' For top-level windows, title bar dark mode is handled separately
	' by RefreshTitleBarThemeColor / SetTitleBarThemeColor.
	If hWnd = 0 Then Return False

	' Re-entrancy guard. SetWindowTheme synchronously sends WM_THEMECHANGED
	' back to the window it themes, and several controls' WM_THEMECHANGED
	' handlers (Form, Grid, ListView, TreeListView, TreeView) respond by
	' calling this function again for that same window - without this guard
	' that's unbounded mutual recursion and a stack-overflow crash (this was
	' the long-standing "enabling dark mode crashes the app" bug: 0xc0000005
	' with the guard page hit at a varying point in the cycle's frames, so
	' the faulting module looked like UxTheme.dll). Same-window re-entry is
	' cut here, at the one choke point all those handlers share; nested calls
	' for a *different* window (e.g. a ListView theming its header from
	' inside its own handler) still pass. GUI is single-threaded, so a
	' Static slot is sufficient.
	Static As HWND hWndInProgress
	If hWndInProgress = hWnd Then Return False
	Dim As HWND hWndPrev = hWndInProgress
	hWndInProgress = hWnd

	If allow Then
		SetWindowTheme(hWnd, "DarkMode_Explorer", NULL)
	Else
		SetWindowTheme(hWnd, NULL, NULL)
	End If

	hWndInProgress = hWndPrev
	Return True
End Function

Function IsHighContrast() As BOOL
	' Uses the documented SystemParametersInfoW API - already safe.
	' Preserved from the previous stub; this implementation was never problematic.
	Dim As HIGHCONTRASTW highContrast = (SizeOf(HIGHCONTRASTW))
	If (SystemParametersInfoW(SPI_GETHIGHCONTRAST, SizeOf(HIGHCONTRASTW), @highContrast, False)) Then
		Return highContrast.dwFlags And HCF_HIGHCONTRASTON
	End If
	Return False
End Function

Sub SetTitleBarThemeColor(hWnd As HWND, dark As BOOL)
	' Apply dark mode to the window's title bar using DwmSetWindowAttribute.
	'
	' DWMWA_USE_IMMERSIVE_DARK_MODE values:
	'   20 = Windows 10 2004+ (build >= 19041) and Windows 11
	'   19 = Windows 10 1809-1909 (build 17763-18362)
	If hWnd = 0 Then Exit Sub
	If Not g_darkModeSupported Then Exit Sub
	If IsHighContrast() Then Exit Sub  ' Don't interfere with high contrast themes

	Dim As DWORD attrib = IIf(g_buildNumber >= WIN10_2004, _
		DWMWA_USE_IMMERSIVE_DARK_MODE, _
		DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1)

	Dim As BOOL value = dark
	DwmSetWindowAttribute(hWnd, attrib, @value, SizeOf(BOOL))
End Sub

Sub RefreshTitleBarThemeColor(hWnd As HWND)
	' Re-apply the current dark/light mode to the title bar and force a
	' non-client area redraw so the change takes effect immediately.
	If hWnd = 0 Then Exit Sub
	If Not g_darkModeSupported Then Exit Sub

	SetTitleBarThemeColor(hWnd, g_darkModeEnabled)

	' SWP_FRAMECHANGED forces the window manager to re-evaluate the
	' non-client area (title bar, borders). Without this, DwmSetWindowAttribute
	' changes won't be visible until the next window resize or focus change.
	SetWindowPos(hWnd, NULL, 0, 0, 0, 0, _
		SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_NOOWNERZORDER Or SWP_FRAMECHANGED)
End Sub

Function IsColorSchemeChangeMessage(lParam As LPARAM) As BOOL
	' Windows broadcasts WM_SETTINGCHANGE with lParam pointing to
	' "ImmersiveColorSet" when the user toggles between light and dark mode
	' in Windows Settings > Personalization > Colors.
	If lParam = 0 Then Return False
	If g_buildNumber < WIN10_1809 Then Return False

	Dim As WString Ptr pwsz = Cast(WString Ptr, lParam)
	If *pwsz = "ImmersiveColorSet" Then Return True

	Return False
End Function

Function IsColorSchemeChangeMessage(message As UINT, lParam As LPARAM) As BOOL
	' Overload retained for interface compatibility; delegates to the
	' lParam-only variant since the message check is handled at the call site.
	Return IsColorSchemeChangeMessage(lParam)
End Function

Sub AllowDarkModeForApp(allow As BOOL)
	' Sets the global dark mode flag. The original implementation called
	' undocumented uxtheme ordinals here; this safe version simply sets the
	' flag - the actual per-window dark mode application happens in
	' AllowDarkModeForWindow, SetTitleBarThemeColor, and each control's
	' SetDark method.
	g_darkModeEnabled = allow
End Sub

Sub EnableDarkScrollBarForWindowAndChildren(hwnd As HWND)
	' Apply the dark Explorer theme to a window and all its child windows,
	' enabling dark scrollbars on common controls.
	If hwnd = 0 Then Exit Sub
	If Not g_darkModeSupported Then Exit Sub

	SetWindowTheme(hwnd, "DarkMode_Explorer", NULL)

	Dim As HWND hChild = GetWindow(hwnd, GW_CHILD)
	While hChild <> 0
		SetWindowTheme(hChild, "DarkMode_Explorer", NULL)
		EnableDarkScrollBarForWindowAndChildren(hChild)  ' recursive
		hChild = GetWindow(hChild, GW_HWNDNEXT)
	Wend
End Sub

Sub InitDarkMode()
	' Detect the Windows version and determine if dark mode is supported.
	' Called once at startup - after this, g_darkModeSupported indicates
	' whether the current Windows build supports dark mode features.
	If g_buildNumber <> 0 Then Exit Sub

	g_buildNumber = GetTrueWindowsVersion()

	' Windows 10 1809 (build 17763) is the minimum for dark mode support -
	' title bar dark mode via DwmSetWindowAttribute requires this build.
	g_darkModeSupported = (g_buildNumber >= WIN10_1809)
End Sub

Function IsWindows11() As BOOL
	Return g_buildNumber >= WIN11
End Function

Sub SetDarkMode(useDark As Boolean, fixDarkScrollbar_ As Boolean, DoBroadcast As Boolean = True)
	' Master switch: enable or disable dark mode globally.
	'
	' When enabling, sets g_darkModeEnabled = True; the WM_PAINT handler in
	' Control.bas detects this and calls SetDark(True) on every control
	' during its next paint cycle. When disabling, controls revert to
	' system colors on next paint.
	'
	' fixDarkScrollbar is accepted for interface compatibility but isn't
	' needed with the SetWindowTheme-based approach.
	'
	' DoBroadcast controls the desktop-wide WM_SETTINGCHANGE notification
	' below. It exists only to make already-visible windows refresh
	' immediately when the user toggles the setting live (Options dialog).
	' At startup, when this runs before any of the app's own windows exist
	' yet, there's nothing to refresh - every control will already paint in
	' the correct state via its own first WM_PAINT - so callers applying a
	' saved setting at startup should pass False here.
	If Not g_darkModeSupported Then Exit Sub

	Dim As Boolean prevState = g_darkModeEnabled
	g_darkModeEnabled = useDark

	If DoBroadcast AndAlso prevState <> useDark Then
		' BroadcastThemeChangeEvent (uxtheme) would do this but it's
		' undocumented. Send WM_SETTINGCHANGE with "ImmersiveColorSet"
		' instead - the framework's WM_THEMECHANGED/WM_SETTINGCHANGE
		' handlers already call AllowDarkModeForWindow + RefreshTitleBarThemeColor.
		'
		' WM_SETTINGCHANGE's lParam must point to a wide (UTF-16) string -
		' StrPtr() returns an ANSI string pointer, which every other window
		' on the desktop (not just ours) reads as if it were wide, running
		' past the buffer. That mismatch crashed inside UxTheme.dll. Use a
		' Static WString so the pointer stays valid and correctly encoded.
		Static As WString * 32 wsImmersiveColorSet = "ImmersiveColorSet"
		SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0, _
			Cast(LPARAM, @wsImmersiveColorSet), _
			SMTO_ABORTIFHUNG, 1000, NULL)
	End If
End Sub
