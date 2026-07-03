#include "Windows.bi"

#include "DarkMode.bi"

' No-op stub implementation - see the comment in DarkMode.bi. g_darkModeSupported
' and g_darkModeEnabled default to False and are never set True, so every guard
' of the form "If g_darkModeSupported AndAlso g_darkModeEnabled Then" throughout
' the framework's control classes takes its existing light-mode branch, exactly
' as it already did at runtime under the previous implementation.

Function ShouldAppsUseDarkMode() As BOOL
	Return False
End Function

Function AllowDarkModeForWindow(hWnd As HWND, allow As BOOL) As BOOL
	Return False
End Function

Function IsHighContrast() As BOOL
	Dim As HIGHCONTRASTW highContrast = (SizeOf(HIGHCONTRASTW))
	If (SystemParametersInfoW(SPI_GETHIGHCONTRAST, SizeOf(HIGHCONTRASTW), @highContrast, False)) Then
		Return highContrast.dwFlags And HCF_HIGHCONTRASTON
	End If
	Return False
End Function

Sub SetTitleBarThemeColor(hWnd As HWND, dark As BOOL)
End Sub

Sub RefreshTitleBarThemeColor(hWnd As HWND)
End Sub

Function IsColorSchemeChangeMessage(lParam As LPARAM) As BOOL
	Return False
End Function

Function IsColorSchemeChangeMessage(message As UINT, lParam As LPARAM) As BOOL
	Return False
End Function

Sub AllowDarkModeForApp(allow As BOOL)
End Sub

Sub EnableDarkScrollBarForWindowAndChildren(hwnd As HWND)
End Sub

Function IsWindows11() As BOOL
	Return False
End Function

Sub InitDarkMode()
End Sub

Sub SetDarkMode(useDark As Boolean, fixDarkScrollbar_ As Boolean)
End Sub
