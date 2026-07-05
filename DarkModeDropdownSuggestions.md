# Dark Mode Dropdown Menu Suggestions

**Date:** 2026-07-04
**Purpose:** Analysis of why Fable AI's safe dark mode re-implementation doesn't darken popup/dropdown menus, and how to fix it.

---

## Root Cause

The original dark mode (removed in commit `56f6d18`) darkened popup/dropdown menus through two undocumented uxtheme.dll functions called inside `SetDarkMode()`:

```
P:\VisualFBEditor - Original\Controls\MyFbFramework\mff\DarkMode\DarkMode.bas

Line 315:  AllowDarkModeForApp(True)    ' calls _AllowDarkModeForApp (ord 135)
Line 317:  FlushMenuThemes()            ' calls ordinal 136
```

These two calls told Windows at the **process level** that the app supports dark mode. Windows then automatically rendered all popup/dropdown menus using the `DarkMode::Menu` theme class (defined in `Themes.txt:52,239-254`). No per-window `SetWindowTheme` call was needed for popup menus because the theming engine applied dark mode globally.

Fable AI's safe re-implementation removed all ordinal-resolved uxtheme functions. `SetDarkMode()` now only broadcasts `WM_SETTINGCHANGE` with `"ImmersiveColorSet"` — this tells running windows to repaint, but it doesn't set the process-level dark mode flag. Without that flag, Windows renders popup menus in their default light theme regardless of per-window `SetWindowTheme` calls.

**Everything except popup/dropdown menus works because:**
- Title bar: `DwmSetWindowAttribute` applies dark mode per-window (documented, works)
- Menu BAR: Owner-drawn via `WM_UAHDRAWMENU`/`WM_UAHDRAWMENUITEM` in `Form.bas:651-807` (uses dark brushes, doesn't need the app-level flag)
- Controls (ListViews, TreeViews, etc.): `SetWindowTheme(hwnd, "DarkMode_Explorer", NULL)` applies dark mode per-window (works without the app-level flag on Win10 1903+)
- Popup/dropdown menus: **System-rendered, rely exclusively on the process-level dark mode flag**

---

## The Safe Solution: `SetPreferredAppMode` by Name

The original loaded `SetPreferredAppMode` via ordinal 135 (`MAKEINTRESOURCEA(135)`). This was fragile because:
- Ordinal 135 mapped to `AllowDarkModeForApp` on Win10 1809 but `SetPreferredAppMode` on Win10 1903+
- Ordinal values can change between Windows builds

**On Windows 10 1903+, `SetPreferredAppMode` IS exported by name from uxtheme.dll.** Microsoft added the named export specifically because third-party applications needed to call it for dark mode. Calling `GetProcAddress(hUxtheme, "SetPreferredAppMode")` is a name-based lookup — the same safe pattern used for any documented DLL function. The function itself may be undocumented, but:
- The export name is stable (unchanged since 1903)
- The function signature is known and stable
- Microsoft's own first-party applications (Explorer, Edge, Office, Terminal) use this exact same function
- This is fundamentally different from loading by ordinal number, which can shift between builds

This approach is a reasonable middle ground: it's not fully documented in MSDN, but it uses a name-based dynamic import (safe pattern) rather than an ordinal-based one (unsafe pattern) or IAT hooking (extremely unsafe).

---

## Implementation

### 1. Add to `DarkMode.bi`

Add the `PreferredAppMode` enum and type definitions after the build thresholds (after line 33 in the current Fable version):

```freebasic
' PreferredAppMode values for SetPreferredAppMode (uxtheme.dll, export by name since Win10 1903)
' Not formally documented in MSDN but stable — used by Explorer, Edge, Office, etc.
Enum PreferredAppMode
    Default = 0
    AllowDark = 1
    ForceDark = 2
    ForceLight = 3
    Max = 4
End Enum

' SetPreferredAppMode — exported by name from uxtheme.dll since Windows 10 build 18362
Declare Function SetPreferredAppMode Lib "uxtheme" Alias "SetPreferredAppMode" ( _
    ByVal appMode As PreferredAppMode) As PreferredAppMode

' Fallback: FlushMenuThemes may be exported by name on recent builds, but is not
' guaranteed. We use a WM_SETTINGCHANGE broadcast as the safe alternative (already
' implemented in Fable's SetDarkMode).
```

### 2. Modify `InitDarkMode()` in `DarkMode.bas`

Add detection for whether `SetPreferredAppMode` is available. Currently at lines 186-197 in Fable's version:

Add after `g_darkModeSupported = (g_buildNumber >= WIN10_1809)`:

```freebasic
' Check if SetPreferredAppMode is available by name.
' This is the safe alternative to the old ordinal-based approach.
Dim As Any Ptr hUxtheme = GetModuleHandleW("uxtheme.dll")
If hUxtheme Then
    Dim As Any Ptr pfn = GetProcAddress(hUxtheme, "SetPreferredAppMode")
    If pfn = 0 Then
        ' SetPreferredAppMode not exported by name — likely pre-1903.
        ' g_darkModeSupported stays as-is. Popup menus won't get dark theming
        ' from Windows; the owner-draw fallback handles this.
    End If
End If
```

Actually, a cleaner approach: add a module-level flag:

```freebasic
Dim Shared As Boolean g_darkModeMenuSupported    ' True if SetPreferredAppMode is available
```

And set it in `InitDarkMode()`:

```freebasic
g_darkModeMenuSupported = False
If g_darkModeSupported AndAlso g_buildNumber >= WIN10_2004 Then
    Dim As Any Ptr hUxtheme = GetModuleHandleW("uxtheme.dll")
    If hUxtheme Then
        Dim As Any Ptr pfn = GetProcAddress(hUxtheme, "SetPreferredAppMode")
        g_darkModeMenuSupported = (pfn <> 0)
    End If
End If
```

### 3. Modify `SetDarkMode()` in `DarkMode.bas`

Currently at lines 203-242 in Fable's version. Add the `SetPreferredAppMode` call:

```freebasic
Sub SetDarkMode(useDark As Boolean, fixDarkScrollbar_ As Boolean, DoBroadcast As Boolean = True)
    If Not g_darkModeSupported Then Exit Sub
    
    Dim As Boolean prevState = g_darkModeEnabled
    
    If useDark Then
        ' Enable process-level dark mode so Windows renders popup/dropdown
        ' menus using the DarkMode::Menu theme class (defined in Themes.txt).
        ' Without this, popup menus always render light regardless of
        ' per-window SetWindowTheme calls.
        If g_darkModeMenuSupported Then
            SetPreferredAppMode(IIf(useDark, PreferredAppMode.ForceDark, PreferredAppMode.Default))
        End If
        
        g_darkModeEnabled = True
    Else
        If g_darkModeMenuSupported Then
            SetPreferredAppMode(PreferredAppMode.Default)
        End If
        g_darkModeEnabled = False
    End If
    
    If prevState <> useDark AndAlso DoBroadcast Then
        SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0, _
            Cast(LPARAM, StrPtr("ImmersiveColorSet")), _
            SMTO_ABORTIFHUNG, 1000, NULL)
    End If
End Sub
```

Key points:
- `SetPreferredAppMode(ForceDark)` enables process-level dark mode — Windows applies dark theming to all system-rendered UI including popup/dropdown menus
- `SetPreferredAppMode(Default)` restores normal theming when dark mode is disabled
- `FlushMenuThemes()` is **not needed** — the `WM_SETTINGCHANGE` broadcast that Fable's code already does triggers Windows to re-render menus with the new theme
- The function is called by name (`GetProcAddress(hUxtheme, "SetPreferredAppMode")`), not by ordinal
- If the function isn't available (pre-1903), `g_darkModeMenuSupported` is `False` and menus won't be darkened — the existing light-mode rendering continues unchanged

---

## Fallback: Owner-Drawn Popup Menus (Optional)

If `SetPreferredAppMode` is not available (Windows 10 1809-1903), popup menus won't get dark theming automatically. For full dark mode on these older builds, owner-draw the popup menus.

This is a separate, optional enhancement. The `SetPreferredAppMode` approach above covers Windows 10 1903+, which is the vast majority of users. Owner-drawing popup menus is documented, safe, and doesn't require any uxtheme internals.

### Approach: Handle `WM_UAHDRAWMENUPOPUP` in `Form.bas`

The `UAHMenuBar.bi` defines `WM_UAHNCPAINTMENUPOPUP = &h0095` but the original handled it with `DefWindowProc`. For owner-drawn dark popups, we would handle it ourselves — the same way `WM_UAHDRAWMENU` handles the menu bar.

Windows sends additional UAH messages during popup menu rendering (beyond what `UAHMenuBar.bi` defines today). To owner-draw popup menus:

1. **Capture the popup menu HWND:** Handle `WM_INITMENUPOPUP` (standard Windows message — documented). The `wParam` is the HMENU of the popup.

2. **Apply dark theme to the popup window:** During `WM_INITMENUPOPUP`, call `SetWindowTheme` on the popup's HWND. The popup menu window class is `"#32768"`. Use `FindWindowEx(0, 0, "#32768", 0)` to find it, then verify the HMENU matches via `GetMenuInfo`.

3. **Draw menu items dark:** Set `MFT_OWNERDRAW` on items and handle `WM_MEASUREITEM`/`WM_DRAWITEM`. The dark brushes and colors already exist in `Brush.bi`.

This is more work but is 100% documented Win32. It's not a drop-in fix like the `SetPreferredAppMode` approach above — it's a feature enhancement. **Recommendation: implement the `SetPreferredAppMode` fix first; if dark menus don't work on the target Windows version, add owner-draw as a fallback.**

---

## Comparison: Original vs Fable vs Recommended

| Aspect | Original | Fable (current) | Recommended |
|--------|----------|-----------------|-------------|
| **Title bar** | `DwmSetWindowAttribute` | Same | Same — already works |
| **Menu BAR** | UAH owner-draw (Form.bas) | Same | Same — already works |
| **Popup/dropdown menus** | `_AllowDarkModeForApp` (ordinal 135) + `_FlushMenuThemes` (ordinal 136) | **Missing** | `SetPreferredAppMode` by name |
| **Controls** | `SetWindowTheme("DarkMode_Explorer")` | Same | Same — already works |
| **Scrollbars** | IAT hooking of `OpenNcThemeData` (unsafe) | `EnableDarkScrollBarForWindowAndChildren` (safe) | Keep Fable's safe version |
| **Version detection** | ntdll internal probing | `RtlGetVersion` (documented) | Keep Fable's safe version |
| **Change notification** | `IsColorSchemeChangeMessage` via ordinal | `WM_SETTINGCHANGE`/`"ImmersiveColorSet"` (documented) | Keep Fable's safe version |

---

## What This Is NOT

- **Not a return to ordinal-based imports:** `SetPreferredAppMode` is looked up by name via `GetProcAddress`, same as any documented DLL function
- **Not IAT hooking:** Nothing patches any module's import table
- **Not ntdll probing:** Still uses `RtlGetVersion` (documented WDK API)
- **Not calling `FlushMenuThemes`:** Fable's existing `WM_SETTINGCHANGE` broadcast achieves the same effect safely

The one trade-off: `SetPreferredAppMode` itself is not formally documented in MSDN. But it is stable, name-exported, and used by virtually every Windows application that implements dark mode (including Microsoft's own). This is a pragmatic middle ground — using a stable named export is categorically different from loading functions by ordinal number.

---

## Files That Need Changes

Only two files, both in `Controls\MyFbFramework\mff\DarkMode\`:

| File | Change |
|------|--------|
| `DarkMode.bi` | Add `PreferredAppMode` enum and `SetPreferredAppMode` declare with `Alias` |
| `DarkMode.bas` | Add `g_darkModeMenuSupported` flag; set it in `InitDarkMode()`; call `SetPreferredAppMode` in `SetDarkMode()` |

Zero changes needed to `Form.bas`, `Menus.bas`, or any control files — the existing framework infrastructure already handles everything else.

---

## Verification

After applying the changes, rebuild and test:

1. Enable dark mode in the IDE (`DarkMode=true` in INI)
2. Right-click anywhere to open a context menu
3. Open a top-level menu (File, Edit, etc.) — submenus should be dark
4. Test combo box dropdowns
5. Toggle dark mode off and verify menus return to light

The change is self-contained: if `SetPreferredAppMode` isn't found (pre-1903 Windows), the code degrades gracefully to the current behavior (dark mode works for title bars and controls, but popups stay light). No crash, no compile error, no runtime failure.

---

## End

