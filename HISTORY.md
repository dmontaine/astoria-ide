# VFBE Win64 Fork — Session History

**Extracted from PROJECT_STATUS.md on 2026-07-06.** For current status, see [PROJECT_STATUS.md](PROJECT_STATUS.md).

---

## RESOLVED â€” Form designer grey-panel bug (Opus session, 2026-07-06)

**Status:** FIXED, compile-clean (release), user-verified across multiple sequential project opens. Committed and pushed.

### Actual root cause (verified by live file-logging, not the earlier Bugbot hypothesis)

The grey panel had **nothing** to do with duplicate `FormDesign`, the workspace-defer logic, or the `RefreshDesignSurface` reparent â€” all were ruled out by tracing every `FormDesign` caller and exit. The real chain, established by logging inside `FormDesign` â†’ `Designer.CreateControl` â†’ `Designer.Symbols`:

1. `Designer.CreateControl("Form", â€¦)` returned 0, so `FormDesign` bailed at `If .DesignControl = 0 Then Exit Sub` â†’ empty `pnlForm` = grey (the "flash" is the Designer canvas appearing before the control-create fails).
2. `CreateControl` returned 0 because `Designer.Symbols("Form")` returned 0.
3. `Symbols` returned 0 because it called `DyLibLoad` on the MyFbFramework `Library.Path`, which was the **folder** `Controls\MyFbFramework` (no `mff64.dll`) â€” even though the DLL was already loaded (valid `Handle`). `DyLibLoad` on a directory returns 0.

The `"Form"` component's `Comps` entry binds its `Tag` to an MFF `Library` object whose `Path` is the raw `.vfp` component string `Controls/MyFbFramework` (a folder), **distinct** from the toolbox library that carries the real DLL path. So MFF ends up with multiple `Library` objects with inconsistent path representations, and `Comps["Form"].Tag` points at the folder-path one.

### Fixes shipped

1. **`src/Designer.bas` `Designer.Symbols`** â€” when `DyLibLoad(Path)` fails but the library has a live `Handle`, recover the real on-disk DLL path via `GetModuleFileNameW(Handle)` and `DyLibLoad` **that**. This both works around the folder-`Path` and keeps the module refcount balanced. (A first attempt that simply borrowed `CtlLib->Handle` without a matching `DyLibLoad` made the *first* designer work but under-flowed the refcount â€” the Designer destructor's `DyLibFree(st->Handle)` at `Designer.bas` ~2905 then unloaded `mff64.dll` after the first project closed, breaking every subsequent project. The `GetModuleFileNameW` + `DyLibLoad` form is the correct, refcount-safe fix.)
2. **`src/PathUtils.bas` `GetControlLibraryVfpPath`** â€” normalize to forward slashes before the `"/controls/"` scan. It previously ran `WinOsPath` (backslashes) then searched for a forward-slash substring, returning `""` for every absolute library path. That broke the project-open "already loaded" match (`bFinded` stayed false), causing duplicate library objects.

Also in this session: the `ClearUndo â†’ OnLineChangeEdit â†’ FormDesign` teardown chain from the old Bugbot writeup is **already dead** â€” the `WithoutShow=True` change to `ClearUndo` (`EditControl.bas`) stops `ClearUndo` from raising `OnLineChange` at all, so the `mAddingTab` guard debate was chasing a path that can no longer fire.

### Still open (non-fatal, deferred)

The underlying wart â€” MFF getting **multiple `Library` objects with inconsistent `Path` representations** (absolute-backslash DLL path from the toolbox loader vs. relative-forward-slash folder path from the `.vfp` component string), with `Comps["Form"].Tag` binding to the folder one â€” was not fully cleaned up. The two fixes make it harmless (the module is loaded and now resolves correctly), but the refactored library-loading path (`LoadToolBox` INI/dir-scan branches + `AddProject`'s `ControlLibrary` block + `GetControlLibraryVfpPath`/`GetControlLibraryFolder`) deserves a consolidation pass so one DLL maps to exactly one `Library` object with one canonical path. Low priority; captured here for a future session. **Queued for Cursor in Â§8 ("Queued for Cursor").**

### Original bug summary (historical investigation record below)

### Bug summary

Opening a `.frm` file: code editor loads and works; design surface **briefly flashes** (form HWND visible) then settles to an **empty grey `pnlForm`**. Behavior worked in the original download; broke during recent workspace/defer/LoadToolBox work. The **LoadToolBox HWND fix** enabled the brief flash (design control gets a valid parent HWND), but a **second `FormDesign` call tears down** the design surface that the first call built.

### Symptom timeline

1. **Original download** â€” `.frm` opens; code + design surface both work.
2. **After recent changes** â€” `.frm` would not open at all (HWND/parent issues).
3. **After expert fixes** â€” file opens; code editor OK; design surface **flash then grey `pnlForm`**.

### Root cause (Bugbot finding)

`AddTab` calls `.FormDesign` (line ~510), then later `.txtCode.ClearUndo` (line ~519). `ClearUndo` â†’ `ChangeText` â†’ `OnLineChangeEdit` with `TextChanged=True` â†’ **`tb->FormDesign(...)`** at line ~3242. That **re-enters `TabWindow.FormDesign`** while `Des->DesignControl` already exists, hitting the teardown block at **lines 8407â€“8438** (`UnHook`, remove child controls, `DeleteComponentFunc`, clear `Objects`/`Components`/`Controls`). Guards for `mApplyingWorkspaceLoad`, `mApplyingDeferredFormDesign`, `mApplyingFormTabView`, and `mAddingTab` in `OnLineChangeEdit` (~3097) **did not fix** the issue per user â€” likely because `mAddingTab` is cleared at line ~544 **before** `ClearUndo` side-effects propagate, or `TextChanged` is set again on the `OnLineChange` path.

**Key call chain (AddTab open path):**
```
AddTab â†’ .FormDesign (builds design surface)
       â†’ .txtCode.ClearUndo â†’ ChangeText â†’ OnLineChangeEdit
       â†’ tb->FormDesign (TEARDOWN when Des already set)
       â†’ ApplyFormTabView â†’ RefreshDesignSurface (HWND reparent, but surface already gutted)
```

**`TabWindow.FormDesign` teardown zone:** `src/TabWindow.bas` lines **8364â€“8455** (teardown at **8407â€“8438** when `Des->DesignControl` exists).

### Files modified (uncommitted â€” from `git status` / `git diff --stat`)

**Core bug surface (413 lines changed in these 6 files):**

| File | Diff |
|------|------|
| `src/Main.bas` | +365/- (workspace defer, `RunDeferredFormDesign`, `LoadToolBox`, `tabCode_SelChange` guards) |
| `src/TabWindow.bas` | +155/- (`AddTab`, `ApplyFormTabView`, `RefreshDesignSurface`, `OnLineChangeEdit` guards, `FormNeedDesign`) |
| `src/Main.bi` | +14/- (`mApplying*`, `mAddingTab`, `RunDeferredFormDesign` declare) |
| `src/TabWindow.bi` | +3/- |
| `src/Designer.bas` | +90/- |
| `src/EditControl.bas` | +2/- |

**Other modified (32 files total, 1484 insertions / 1376 deletions):**

- `src/PathUtils.bas`, `src/PathUtils.bi`, `src/SettingsService.bas`, `src/VisualFBEditor.bas`
- `src/frmComponents.frm`, `src/frmNewFile.{bi,frm}`, `src/frmOpenProject.{bi,frm}`, `src/frmOptions.frm`, `src/frmProjectProperties.frm`, `src/frmRecentProjects.frm`, `src/frmTemplates.frm`
- `Settings/VisualFBEditor64.ini`, `Settings/Others/HotKeys.txt`
- Binaries: `VisualFBEditor64.exe`, `Controls/MyFbFramework/mff64.dll`
- Example temps, deleted `Projects/*`, `Templates/Files/Form_3D.frm`

**Untracked (not in diff):** `src/frmOpenProjectFile.{bi,frm}`, `src/VisualFBEditor.vfp`, `Settings/Workspace.ini`, `Project/`, example temps/exes.

### Fixes attempted

- **LoadToolBox HWND fix** (`Main.bas` ~4801) â€” ensures `pApp->MainForm = @frmMain` before toolbox load; design HWND gets valid parent â†’ **flash visible** (partial win).
- **`mApplyingWorkspaceLoad`** â€” skip immediate `FormDesign` in `AddTab` during `LoadWorkspace`; set `FormNeedDesign=True`; defer via `RunDeferredFormDesign()` after workspace load (`Main.bas` ~9122â€“9125).
- **`RunDeferredFormDesign`** (`Main.bas` ~4778) â€” batch deferred design for tabs with `FormNeedDesign`; calls `FormDesign` + `ApplyFormTabView`; ends with `tabCode_SelChange`.
- **`FormNeedDesign` flag** â€” defer design to `tbrTop_ButtonClick` Form/CodeAndForm paths (`TabWindow.bas` ~508, ~10100â€“10117).
- **`RefreshDesignSurface`** (`TabWindow.bas` ~313) â€” `SetParent` design HWND to `pnlForm`, `Des->Dialog`, repaint.
- **`ApplyFormTabView`** refactor (`TabWindow.bas` ~331) â€” centralize form-tab view setup; `mApplyingFormTabView` guard.
- **`mApplyingDeferredFormDesign` / `mApplyingFormTabView` guards** in `tabCode_SelChange` (`Main.bas` ~8098) â€” skip toolbar click during deferred apply.
- **`mAddingTab` + re-entrancy guards** in `OnLineChangeEdit` (`TabWindow.bas` ~3097) â€” suppress `FormDesign` when adding tab; **user reports still broken**.
- **`mAddingTab` lifecycle** in `AddTab` (`TabWindow.bas` ~359, ~544) â€” set True at start, False before return.

### Opus next steps (narrow scope)

1. **Trace ALL `FormDesign` callers** during `.frm` open via logging or static breakpoint reasoning:
   - `AddTab` ~510
   - `OnLineChangeEdit` ~3242
   - `RunDeferredFormDesign` ~4790
   - `tbrTop_ButtonClick` ~10101/10116
   - `tabCode_SelChange` side-effects
   - Any `OnUndoEdit` / undo paths that set `TextChanged`
2. **`ClearUndo` / `OnLineChangeEdit` / `OnUndoEdit` paths** â€” confirm whether `ClearUndo` after first `FormDesign` is necessary; consider moving `ClearUndo` before `FormDesign`, skipping `OnLineChange` during `ClearUndo` (`WithoutShow` already True but `ShowCaretPos` may still fire `OnLineChange`), or guarding `FormDesign` when `Des->DesignControl` is valid and tab is initializing.
3. **`TabWindow.FormDesign` teardown (~8407â€“8438)** â€” when `DesignControl` already exists during tab init, **skip teardown** or **skip re-entry** entirely (early `Exit Sub` if design surface is fresh/valid).
4. **`RunDeferredFormDesign`**, **`ApplyFormTabView`**, **`tabCode_SelChange`** â€” verify no duplicate `FormDesign` after deferred batch; check interaction with `mAddingTab=False` timing vs `ClearUndo`.
5. **Revert experiment:** `git checkout --` workspace-defer changes (`RunDeferredFormDesign`, `FormNeedDesign`, `mApplyingWorkspaceLoad` paths) while **keeping LoadToolBox fix only** â€” isolate whether defer logic introduced the double-call or only exposed it.

### Revert guidance

**Do NOT commit** current broken state. User may roll back to last known good:

```powershell
# Revert specific files
git checkout -- src/Main.bas src/Main.bi src/TabWindow.bas src/TabWindow.bi src/Designer.bas

# Or stash everything (including untracked â€” use with care)
git stash push -u -m "WIP form designer bug"

# Or restore entire working tree to origin/main
git checkout -- .
```

Binaries (`VisualFBEditor64.exe`, `mff64.dll`) and `Settings/VisualFBEditor64.ini` have local runtime changes â€” revert separately if needed.

### Last compile

`CompileDebug.bat` â€” **0 errors** (2026-07-06, end of session). Rebuild after any fix.

### User test checklist (form designer surface)

- [ ] Cold start IDE (no workspace) â†’ open `.frm` from File â†’ design surface shows form (not grey `pnlForm`)
- [ ] Cold start with saved workspace containing `.frm` tabs â†’ all form tabs restore with design surface
- [ ] Switch Code / Form / Code+Form toolbar on open `.frm` â€” no flash-to-grey
- [ ] Open second `.frm` tab â€” both design surfaces work
- [ ] Edit code line in constructor region â†’ design surface updates (no spurious teardown)
- [ ] Toolbox populates; drag control onto form works
- [ ] Save/reopen `.frm` â€” design surface persists
- [ ] Non-form `.bas` â€” Code-only view; no Form toolbar errors

---


## 3a. Batch 2.75.3 â€” what actually happened

Beyond the originally-scoped "strip commented GTK markers," this batch also caught and fixed a **shipped-broken Designer** and expanded to a broader dead-legacy-code pass at the owner's explicit direction ("also remove old dead legacy code" encountered along the way, not just GTK-tagged code).

**Root-cause fix â€” Form Designer never activated for any `.frm` file:**
`Tools/strip_gtk_preprocessor.ps1` didn't recognize the `__EXPORT_PROCS__` macro and silently deleted the entire `#ifdef __EXPORT_PROCS__` export-dispatcher block from `mff.bi` plus per-file `Export` functions in ~14 `mff/*.bas` files, so `mff64.dll` shipped with **zero exports**. Fixed the strip tool and manually restored the missing blocks (2 `ToolBar.bas` functions deliberately deferred â€” restoring them hits an unresolved FreeBASIC "Illegal specification" compiler quirk on a `Private Enum` parameter; not called anywhere in the IDE itself). Commit `bef9267`.

**Dark mode â€” replaced, not removed:**
The undocumented-API dark-mode implementation (ordinal-resolved `uxtheme.dll` calls, `ntdll` version probing, IAT hooking) was flagged by the owner as unreliable and untrusted. Replaced with an inert stub (`mff/DarkMode/DarkMode.bi`/`.bas`) that preserves the exact public interface as no-ops, so every call site still compiles and behaves as before (dark mode was already forced off). This intentionally leaves a clean seam for a trustworthy reimplementation later rather than deleting the integration points. `mff/DarkMode/IatHook.bi` (zero references) deleted outright; `UAHMenuBar.bi` kept (still used by `Form.bas`, unrelated to the ordinal/IAT fragility). Commit `56f6d18`.

**Dark mode â€” reimplemented with documented APIs (2026-07-03):** the seam left above was filled in. `DarkMode.bi`/`.bas` now use only documented, stable Win32 APIs: `SetWindowTheme` (uxtheme), `DwmSetWindowAttribute` (dwmapi, declared by hand with an explicit `Alias` since FB's default linkage would otherwise mangle the symbol and fail to link), `RtlGetVersion` (ntdll, documented WDK API, gives the true build number unlike `GetVersionEx`), a registry read of `HKCU...Personalize\AppsUseLightTheme` for the live system preference, and `WM_SETTINGCHANGE`/`"ImmersiveColorSet"` for change notification. No ordinals, no IAT hooking, no internal-structure probing. Every existing `SetDark`/`AllowDarkModeForWindow`/etc. call site across ~25 control files was already intact and needed no changes â€” only the 11 functions in `DarkMode.bas` had to be rewritten. The Dark Mode checkbox (previously force-hidden and force-disabled) is un-hidden â€” reparented onto the General options page since its old home (`grbThemes`/`pnlThemes`) turned out to be an orphaned page with no tree node pointing to it, not reachable from the UI at all â€” and now actually persists to/from the INI instead of being hardcoded off in three separate places (`Main.bas`, `SettingsService.bas`, `frmOptions.frm`'s save path). The broken interface color/theme picker on that same orphaned page stays hidden â€” separate, still-broken feature, out of scope here.

**Dark mode â€” crash history (2026-07-04, ALL RESOLVED â€” see the "crash #3 root-caused and fixed" entry below):** the checkbox and persistence are correct, and the app runs fine with the setting off. But turning it on genuinely crashed the app â€” confirmed via repeated reproduction, not a one-off. Two real bugs were found and fixed in the first investigation session, and a third remained open until the follow-up session the same day:

1. **Fixed:** `SetDarkMode`'s `WM_SETTINGCHANGE` broadcast passed `StrPtr("ImmersiveColorSet")` â€” an ANSI string pointer â€” as the lParam, which the Win32 API contract requires to be a wide (UTF-16) string. Every window on the desktop that received the broadcast (not just ours) read past the buffer trying to interpret it as wide, and this reproducibly crashed inside `UxTheme.dll` (`0xc0000005`, confirmed via Windows Event Viewer). Fixed with a `Static As WString * 32` so the pointer is both correctly encoded and has a guaranteed lifetime.
2. **Fixed:** `SetDarkMode` was being called (via `SettingsService.LoadSettings`, applying the saved INI setting) very early in startup, while only the splash screen exists, and still performed the full desktop-wide broadcast every time â€” pointless that early (nothing of ours exists yet to refresh) and needless risk. Added a `DoBroadcast As Boolean = True` parameter; the startup call site now bypasses the `App.DarkMode` property (which always broadcasts) and calls `SetDarkMode` directly with broadcast suppressed. The live Options-dialog Apply-button path is unchanged and still broadcasts, since that's the case that actually needs it.
3. **Still open:** even with both of the above fixed, enabling dark mode still crashes â€” confirmed by two separate repro runs, both `0xc0000005` inside `UxTheme.dll` at the same faulting offset as bug #1, but the *symptom's timing varies*: one run crashed during a splash-screen label repaint, another got further and crashed at main-form load. This points at `SetWindowTheme`/`AllowDarkModeForWindow` itself being unsafe to call this early in the control-creation sequence (`g_darkModeEnabled` is now `True` from very early in startup, so *every* control's first `WM_PAINT` tries to theme it, immediately, including ones created before whatever Windows normally expects to be initialized first) â€” not a string/encoding issue this time. Leading hypothesis for next session: defer actually enabling dark mode (setting `g_darkModeEnabled`/calling `SetDark` on existing controls) until after the main form and its full control tree exist, rather than applying it while only the splash screen is up.

**Crash #3 root-caused and FIXED (2026-07-04, follow-up session, via live GDB debugging):** the "unsafe to theme controls early" hypothesis above turned out to be wrong. A debug build (`CompileDebug.bat`, `-g -exx -O0`) run under the bundled GDB (`Debuggers/gdb-11.2.90.20220320-x86_64/bin/gdb.exe -batch -ex run -ex bt`) caught the crash live with a symbolic backtrace: **infinite recursion â†’ stack overflow.** `SetWindowTheme` synchronously sends `WM_THEMECHANGED` back to the window it themes (observed wParam=-1, lParam=0x80000001 â€” the system-generated signature, decimal msg 794), and five control classes' `WM_THEMECHANGED` handlers (`Form`, `Grid`, `ListView`, `TreeListView`, `TreeView`) respond by calling `AllowDarkModeForWindow` â†’ `SetWindowTheme` again â†’ unbounded mutual recursion until the stack guard page is hit. Every earlier observation now fits: the "same UxTheme.dll faulting offset" was just where the guard page happened to be hit inside the recursion cycle's frames, and the variable crash timing (splash label vs. main-form load) was whichever themed window received the message first. **Fix:** one same-window re-entrancy guard (a `Static As HWND` slot) inside `AllowDarkModeForWindow` itself (`DarkMode.bas`) â€” the single choke point all five handlers share â€” rather than five per-class guards; nested calls for a *different* window (e.g. a ListView theming its header from inside its own handler) still pass. **This also fixed a latent crash-on-system-theme-change:** those handlers are gated on `g_darkModeSupported` only (not `g_darkModeEnabled`), so the same recursion would have fired even with dark mode off the moment the user toggled Windows' own light/dark setting while the IDE ran.

**Dark mode visual completion (same session):** with the crash gone, dark mode rendered only partially (light menu bar/toolbars on some activation states, light tab strips, big white central area). Findings and fixes:
- **Menu bar / toolbars needed no code changes** â€” the full adzm-style UAH owner-drawn dark menu bar (`Form.bas` `WM_UAHDRAWMENU`/`WM_UAHDRAWMENUITEM`/`WM_NCPAINT` handlers, structs in `mff/DarkMode/UAHMenuBar.bi`) and the ToolBar/ReBar `NM_CUSTOMDRAW` dark paths were already present and working; GDB breakpoint instrumentation confirmed 8 bar paints Ã— 12 items all executing the dark path. An early screenshot showing them light was a transient corrected by a window-activation cycle.
- **`TabControl` (`TabControl.bas`) was the real gap**: its dark custom paint existed only for `tpLeft`/`tpRight` (rotated side captions); all three visible strips (`tabLeft` Project/Toolbox/AI Agent, `tabBottom` Output/... , and each editor `tabCode`) are `tpTop` (the constructor default â€” the `tpBottom`/`tpRight` assignments in `Main.bas` are commented out), where `TCS_OWNERDRAWFIXED` is deliberately switched off, so the native control painted them light. Added a horizontal-tab dark-paint branch mirroring the vertical one (strip fill, `hbrHlBkgnd` selected-tab highlight, `ImageList_Draw` icon, caption via `DrawText`).
- **The big central white area was `WM_ERASEBKGND` claiming "erased" while painting nothing** (`Message.Result = -1` with no `FillRect`), so the default white showed through the empty `tabCode` body. Now fills with `hbrBkgnd` before claiming handled.

**Current state:** `DarkMode=true` is enabled in the owner's INI and stable â€” title bar, menu bar, toolbars, tab strips, central area, panels, trees, output, and status bar all render dark. **Known remaining gaps (deferred, see Â§13.10):** popup/dropdown menus are still light â€” Windows has no documented API for dark Win32 popup menus; the framework's owner-draw scaffolding exists (`Menu.Style` flips items to `MFT_OWNERDRAW`) but its `WM_DRAWITEM ODT_MENU` handler is empty, so enabling it today would draw blank menus. Also minor: input-field faces (search box, combo edit areas) stay light-ish under the `DarkMode_CFD` theme.

**Post-merge regression #2 found and fixed (2026-07-03) â€” General options page checkbox overlap:** un-hiding Dark Mode surfaced a second, independent, pre-existing bug (not caused by tonight's work, just never noticed since nobody had looked closely at this exact page before): `pnlInterfaceFont`/`chkDisplayIcons`/`chkShowMainToolbar`/`chkShowPropLocal`/`chkDarkMode` are relocated into `vbxGeneral` at runtime (`frmOptions.frm`'s Constructor, "Move interface settings to General" block) *after* they were already constructed â€” and originally only `pnlInterfaceFont` got an explicit `.ControlIndex` to pin its stacking position; the other four didn't. Fixed by giving all four explicit sequential `ControlIndex` values (1â€“4), matching the pattern the file already uses elsewhere (`chkAutoCreateRC.ControlIndex = 1`, etc.) â€” Add(), Component.bas.

That fix alone wasn't sufficient: a second, deeper issue meant these same 5 relocated controls' on-screen positions got reset back to their pre-relocation absolute coordinates the first time the General page became visible, landing on top of the five controls that were always native to `vbxGeneral`. Root-caused via three rounds of temporary instrumentation (removed afterward) added directly to `Control.RequestAlign`/`Component.Move`/`Component.SetBounds` in the shared framework, logging every call `vbxGeneral` and its children made during a live run â€” confirmed `RequestAlign` always computes the correct stacked position on every pass, but something in a native-window-recreation cascade re-applies stale pre-relocation bounds afterward, specifically for controls that had already been constructed (with a window) under their old parent before being reparented. The exact trigger point wasn't pinned to one line even with this instrumentation. Rather than risk a deeper change to this 20+-year-old inherited docking engine on partial understanding, applied a safe, targeted fix: `frmOptions.frm`'s `TreeView1_SelChange` now forces one more explicit `vbxGeneral.RequestAlign` right after the General page becomes visible, guaranteeing the final on-screen layout is always the correct computed stack regardless of what the earlier reset does. Verified visually (screenshot) â€” all rows render cleanly, Dark Mode checkbox shows on its own line, unchecked.

**Confirmed-dead subtree deletion:** `mff/gir_headers/`, `mff/WebView/`, `mff/fbsound/`, `SoundPlayer.bas`/`.bi` â€” 109 files, ~104k lines, zero references anywhere, verified via clean rebuild. Commit `c494207`.

**Compile warnings:** all resolved (WString default-parameter fixes, `AndAlso`-chained boolean/pointer-property comparisons isolated into explicit `Boolean` locals). Commits `53d8e47` + `56f6d18` (first pass under-verified due to a UTF-16 log encoding gotcha with raw `grep`; corrected in the second commit).

**Physical dead-code deletion** (the literal instruction: delete, don't hide) across:
- `src/Debug.bas` â€” dead conditional-breakpoint UI functions, a dead `get_main_file_from_exe`/`get_name_files_from_exe` pair, a duplicate ~300-line dead 32-bit stabs-parsing branch, misc stray markers. Commit `7baebd1`.
- `src/Designer.bas`/`.bi`, `src/Main.bas`/`.bi`, `src/TabWindow.bas`, `src/VisualFBEditor.bas` â€” dead WM_KEYDOWN/GTK popup-menu branches, a ~300-line dead GTK VTE-terminal integration block, a dead ListView-based property-panel implementation (superseded by the current `TreeListView`-based one), dead debugger-UI branches. Commit `add4642`.
- `Controls/MyFbFramework/mff/*.bas` (16 files) â€” dead GTK-only branches, dead sort/alignment/tooltip logic, dead PNG-loading functions; `NativeFontControl.bas`/`.bi` deleted outright (100% commented out, confirmed unreferenced anywhere). Commit `76abaa5`.

**Verification:** every commit above passed a clean `Compile.bat` rebuild (0 warnings, 0 errors â€” checked with the `Read` tool, since the log is UTF-16 and raw `grep` silently false-negatives on it). A final repo-wide sweep confirms only one GTK/32-bit marker remains anywhere in `src/` or `mff/`: `TabWindow.bas`'s `CheckCondition()`, which evaluates `#if` conditions in the *user's* FreeBASIC code being edited â€” a legitimate IDE feature, correctly left alone.

**Git-tracking policy change:** `Compiler/` and `Debuggers/` are now tracked in git (previously vendored/gitignored) â€” this is intentionally a fully self-contained fork going forward. Commit `b555406`. 32-bit compiler binaries (`Compiler/bin/win32`) removed as out of scope. Commit `15e66cc`.

---

## 3b. Examples/ GTK/Linux/Win32-only audit (2026-07-03) â€” result: nothing to remove

**Premise checked and rejected:** went through all 33 `Examples/` subdirectories looking for GTK-dependent, Linux-only, or Win32-only (non-64-bit-compatible) example projects to remove as leftover cross-platform cruft. **None qualified.** The `#ifdef __USE_GTK__` blocks present in ~15 `.frm` files are harmless MyFbFramework designer boilerplate (an icon-loading fallback that resolves to the Windows `#else` branch) â€” not real GTK dependencies. `__FB_WIN32__`/`__FB_LINUX__`/`__FB_UNIX__` checks found are standard FreeBASIC "which OS" conditionals that correctly fall through to Windows-appropriate code. Every example either has valid 64-bit `.vfp` compile args already, or has source that's fully Win64-portable regardless of a missing project file.

**Follow-up work done as a result of the audit, instead:**

- **Fixed a real bug found incidentally:** `Examples/Add-In/Module1.bas` and `Examples/Add-In/My Add-In.bas` both called `mff.MenuFindByName(mnuMenu, "Service")` â€” the top-level menu commit `ae74b31` renamed from "Service" to "Tools". Both files fixed (string and the `mnuService`â†’`mnuTools` variable rename for clarity). `Module1.bas` is the more complete/current of the two duplicate implementations (has an extra `OnBeforeCompile` handler `My Add-In.bas` lacks) and is now the file wired into the new `.vfp`; `My Add-In.bas` is left in place, fixed, but not part of the compiled project.
- **Created missing `.vfp` project files** for examples that had none (a project-hygiene gap, not a platform issue): `Add-In`, `Graphics`, `Web Page`, `WellCOM Example` (two projects: `WellCOM.vfp` the COM server DLL, `Test_WellCOM.vfp` the console test client), and three of four `Game` subfolders (`Calculator`, `FiveInARow`, `Maze` â€” `Sudoku` already had one). Also created missing `Manifest.xml`/resource `.rc` files where a `.frm`'s embedded `#cmdline "Form1.rc"` designer directive pointed at a file that didn't exist (`Web Page`, `Maze`, `FiveInARow`'s manifest).
- **Verified by direct compilation** (same technique as the `_WIN32_WINNT` fix verification, Â§4): every new project was compiled directly with `fbc64.exe` using IDE-equivalent flags before being considered done. Confirmed compiling clean: `Add-In`, `Web Page`, `Maze`, `Calculator`, `FiveInARow`, `Test_WellCOM`, `Graphics` (see below).

**`Examples/Graphics/CanvasDraw.bas` â€” fixed (2026-07-03).** Investigated before assuming a rewrite was needed, and it turned out to be three small, well-evidenced fixes rather than an open-ended API-drift rewrite:
- `CreateDoubleBuffer`/`TransferDoubleBuffer` calls (4 total) simply don't exist anymore in `mff/Canvas.bi` â€” no replacement needed, since double-buffering is now handled internally by the framework (the old manual buffer-blit logic in `Canvas.bas` is commented out, `Control.bi` now exposes a `DoubleBuffered` property instead). Deleted the dead calls.
- `.Pen.Style = 3` / `.Pen.Style = 0` (bare integers) failed against the now strictly-typed `PenStyle` enum property. The original author had already left themselves the answer in a comment (`'PenStyle.psDashDot`) â€” swapped the magic numbers for the named constants (`psDashDot = 3`, `psSolid = 0`, confirmed against the enum).
- `.StretchImage = StretchMode.smStretchProportional` was ambiguous, not wrong â€” `My.Sys.Forms` (`Control.bi`) and `My.Sys.Drawing` (`Graphic.bi`) each independently define an identical `StretchMode` enum for their own purposes, and the example has `Using` for both namespaces in scope. `Picture.StretchImage` specifically expects the `My.Sys.Forms` one; fully-qualifying the reference resolved it with no framework changes needed.

Verified via direct `fbc64` compile â€” clean, 0 errors.

**`Examples/WellCOM Example/WellCOM.bas` doesn't compile with the bundled FreeBASIC 1.10.1 â€” still open, flagged for a decision, not fixed.** It defines its own `Function DllMain(...) As Boolean`, which conflicts at the C level with FreeBASIC's auto-generated `DllMain` entry point when compiling with `-dll` (`error 42: conflicting types for 'DllMain'`). This means the shipped `WellCOM.dll` (currently a 32-bit binary, itself a leftover gap) can't simply be recompiled for 64-bit with today's toolchain â€” the source itself needs a fix for how it defines the DLL entry point, which requires FreeBASIC-internals understanding to get right without silently breaking COM initialization behavior. Left as a known, documented issue rather than guessed at.

---


## 4. Session history (chronological)

### Infrastructure

- Fork initialized; Codeberg repo `bigriverguy/VFBEWin64` configured
- Initial commit: `bbfa399` â€” *Initial Win64 fork import*
- SSH to Codeberg verified (`Hi there, bigriverguy!`)

### Batch 2.75.2 fallout â€” startup freeze

**Symptom:** Splash stuck; invisible â€œghostâ€ Find region.

**Cause:** GTK strip + form autolaunch blocks. `frmSplash.frm` and 13 other `frm*.frm` files had module-level `Form.Show` + `App.Run`. During `Main.bas` includes, `frmFind` autolaunched and blocked startup.

**Fix:**

- Removed standalone `Form.Show` / `App.Run` from splash + 13 forms
- `VisualFBEditor.bas` defines `_NOT_AUTORUN_FORMS_` before includes

### UI fixes (postâ€“2.75.2)

| Issue | Fix |
|-------|-----|
| Tab close button showed `Ãƒâ€”` | `TabWindow.bas`: `Caption = WChr(&HD7)` (Ã—), Segoe UI 8pt |
| Bottom panel UX regressions (pin, collapse, overlap, two-click minimize, startup focus) | `Main.bas`, `Main.bi`, `VisualFBEditor.bas` â€” state machine aligned with left/right panels |
| `BottomHeight=19` in INI broke layout | Clamp: `MIN_BOTTOM_PANEL_HEIGHT=80`, `DEFAULT=200`; INI corrected |

### Bottom panel â€” persistence vs layout (iterative)

Several fix cycles addressed bottom panel **save/restore** vs **collapse layout**:

1. **Wrong save key:** `BottomClosed` was derived from pin checkbox instead of layout (`TabPosition`) â€” fixed to match left/right.
2. **Added `BottomCollapsed` INI key** and `IsBottomCollapsed()`.
3. **`ShowBottom` / `CloseBottom` changed `TabPosition`** unlike left/right â€” refactored so only `SetBottomClosedStyle` changes `TabPosition`.
4. **State not retained on restart:** Focus changes during **exit** collapsed the panel before INI save; **startup** `ActivateMainWindow()` collapsed restored auto-hide panels.
   - `SaveMainWindowPanelLayout()` at **start** of `frmMain_Close`
   - Skip auto-collapse in `frmMain_ActiveControlChanged` when `FormClosing` or `bApplyingStartupLayout`
   - Re-expand bottom after `ActivateMainWindow` in `frmMain_Show` when INI says expanded
5. **Collapse did not reclaim editor space:** `CloseBottom` left `ptabBottom->Height` at expanded size; pin click used `SetBottomClosedStyle(True, False)` without `CloseBottom`
   - Reset both `pnlBottom` and `ptabBottom` heights on collapse
   - Pin click while expanded: `SetBottomClosedStyle(True, True)`
6. **First cold start collapsed â€” editor gap:** `CloseBottom` in `frmMain_Create` ran before the form was shown; dock layout kept full `pnlBottom` height until manual collapse
   - `frmMain_Show` re-applies `CloseBottom` once the main window is visible (and again after startup focus restore)

**Status: bottom panel code issues â€” FIXED** (persistence, collapse/reclaim, first-start layout). See Â§7 for remaining **manual test plan** items.

### Left/right panel Pin click not collapsing

Same root pattern as bottom panel item 5 above, found independently in each: Pin click while the panel was expanded called `SetLeftClosedStyle`/`SetRightClosedStyle(Value, WithClose:=False)`, relying on `frmMain_ActiveControlChanged`'s focus-loss detection to actually collapse â€” unreliable, especially when focus stayed inside a Form Designer. Fixed both to mirror the already-correct bottom-panel pattern: `WithClose:=True` when collapsing from an expanded state. Right panel: commit `c267284`. Left panel: commit `64daa66`.

### Form Designer never activating (root-caused during 2.75.3)

See Â§3a â€” this was actually a fallout of the Batch 2.75.2 GTK strip tool, not a new regression, but wasn't caught until this session. Fixed in commit `bef9267`.

### Critical fix: bundled Windows headers silently dropped Windows-8.1+ APIs for every user project (2026-07-03)

**Discovered when the owner tried to compile the `MDINotepad` example project and got 11 errors in `Controls/MyFbFramework/mff/Control.bas`** (`WM_POINTERDOWN`/`POINTER_INFO`/`GetPointerInfo`/`PT_MOUSE` all "not declared"). This turned out to be a serious, longstanding bug â€” not something introduced by tonight's session â€” that likely blocked **any** standard GUI project from compiling through the IDE, not just this one example.

**Root cause:** `src/Main.bi` defines `TARGET_COMPILE_DEFINE = "__USE_WINAPI__ -d _WIN32_WINNT=&h0A00"` (Windows 10), unconditionally appended to every user-project compile command (`TabWindow.bas:11378`). The bundled compiler's Windows headers (`Compiler/inc/win/*.bi`) gate all "Windows 8.1 and later" API declarations behind **exact-equality** version checks â€” `#if _WIN32_WINNT = &h0602` â€” instead of the correct minimum-version form (`#if _WIN32_WINNT >= &h0602`). Since the project explicitly targets Windows 10 (`&h0A00 â‰  &h0602`), every one of those blocks was silently excluded, even though Windows 10 is a strict superset of Windows 8.1 and should include all of it. `Control.bas` (the base class for every MyFbFramework control, pulled in by the default `Form.frm` template used by GUI/Windows Application projects) hits this via its pointer-input handling â€” meaning essentially any new GUI project with a form would fail the same way.

**Verified via the original download too:** the owner confirmed the same `MDINotepad` project also fails on the unmodified upstream project (different failure signature â€” fails earlier, before producing a detailed error list â€” consistent with the upstream toolchain not even being fully set up). This confirms the defect predates this fork and Tier 2.75 cleanup entirely.

**Scope confirmed systemic, not isolated:** grepped the whole `Compiler/inc/win/` tree â€” the same exact-equality anti-pattern (`_WIN32_WINNT = &h0602`) appears **116 times across 18 files** (`aclui.bi`, `authz.bi`, `combaseapi.bi`, `commctrl.bi`, `ncrypt.bi`, `ntddndis.bi`, `shellapi.bi`, `shldisp.bi`, `shlobj.bi`, `shobjidl.bi`, `userenv.bi`, `winbase.bi`, `wincrypt.bi`, `windot11.bi`, `wingdi.bi`, `winnls.bi`, `winnt.bi`, `winuser.bi`) â€” a single consistent spelling, no case/spacing variants. This is almost certainly a FreeBASIC header-porting bug: Microsoft's own SDK headers use "at least this version" semantics (`NTDDI_VERSION >= NTDDI_WIN8`), not exact equality.

**Safety verified before fixing:** confirmed (via cross-referencing every declared symbol name against the rest of each file, including `#elseif` chains) that no file has a competing higher-version guard (`>= &h0603`, `&h0A00`, etc.) for the same symbols â€” so widening `=` to `>=` cannot cause duplicate-definition conflicts anywhere. All 116 occurrences are either standalone `#if`/`#endif` blocks or the terminal branch of an `#elseif` chain with nothing after them.

**Fix:** mechanical find-and-replace, `_WIN32_WINNT = &h0602` â†’ `_WIN32_WINNT >= &h0602`, across all 18 files. Purely additive â€” for the IDE's own self-build (which doesn't force `_WIN32_WINNT`, so `Control.bi`'s own `#ifndef` fallback sets it to exactly `&h0602`), behavior is unchanged; for user projects (`&h0A00`), the correct Windows-8.1+ API set now compiles.

**Verified:**
- IDE self-build (`Compile.bat`) still compiles clean, 0 errors/0 warnings, after the header fix.
- Direct reproduction: compiled `Examples/MDINotepad/MDIMain.frm` with the exact flags the IDE uses (`-d __USE_WINAPI__ -d _WIN32_WINNT=&h0A00`, etc.) â€” failed before the fix (matching the owner's screenshot), succeeds cleanly after, producing a working executable.

**Not yet done:** full regression pass compiling other example projects to confirm no other examples relied on the old (buggy) exclusion behavior. (The "does 1.10.3 already fix this" question is now moot â€” Tier 3's compiler swap was attempted and closed 2026-07-03, staying on 1.10.1; see Â§4's compiler-version-decision section.)

### Ad-hoc addition: stale bottom-panel content on project close (2026-07-03)

**Not part of any planned tier â€” arose from the owner noticing the Output/Problems tabs kept a closed project's content after opening a different project.** Investigated all 14 bottom-panel tabs (`src/Main.bas` ~line 8200) and found they split into two groups with different natural lifetimes:

- **Analysis tabs (6): Output, Problems, Suggestions, Find, ToDo, Change Log** â€” hold scan/compile results scoped to whichever project or file produced them (confirmed `Change Log` is explicitly keyed to the current tree node via `mChangelogName`). Stale content here is actively misleading once a different project is open.
- **Debug/profiler tabs (8): Locals, Globals, Procedures, Threads, Watches, Memory, Profiler, Immediate** â€” only ever have content during an active debug/profiling run, which can't exist without a project open.

**Fix:** two new Subs in `src/Main.bas` (next to the existing `ClearMessages()`):
- `ClearAnalysisPanels()` â€” clears the 6 analysis tabs, called from `CloseProject` (Main.bas).
- `ClearDebugPanels()` â€” clears the 8 debug/profiler tabs, called from the `Case "End"` debug-stop handler in `src/VisualFBEditor.bas` (so it fires when a debug session ends, not just on project close), and also from `CloseProject` as a backstop.

**Gotcha hit along the way, worth remembering for any future cross-file Sub call:** `Main.bi` `#include`s `Main.bas` near its own end (line ~316), and `VisualFBEditor.bas` pulls in `Main.bi` near its top (line 36) â€” before it reaches its own Sub definitions further down (e.g. `ClearThreadsWindow` at line 299). So a Sub defined in `VisualFBEditor.bas` is **not** visible to code in `Main.bas` without an explicit forward `Declare` in `Main.bi` (added one for `ClearThreadsWindow`, following the existing `ChangeEnabledDebug`-style pattern) â€” even though calling in the other direction (`VisualFBEditor.bas` calling a `Main.bas` Sub) works fine, since `Main.bas`'s content is textually inlined before `VisualFBEditor.bas` continues past line 36.

Compiled clean (0 errors/0 warnings) after the fix. Not yet manually smoke-tested in the running IDE.

### FreeBASIC compiler version decision (Tier 3 â€” attempted 2026-07-03, reversed: staying on 1.10.1)

Owner plans to replace the bundled `Compiler/` tree and eventually vendor the compiler's own source for future AI-assisted review. Compared 1.10.1 (currently bundled), 1.10.3, 1.10.4 (unreleased), and 1.20 (unreleased) â€” **originally decided on 1.10.3** from the `fbc-1.10` maintenance branch. 1.20 was ruled out for now: it removes null-termination from fixed-length strings (`STRING*N`/`WSTRING*N`), a breaking change that would need an audit of this codebase's fixed-string usage first. Owner specified a preferred binary source: community continuous builds at `users.freebasic-portal.de/stw/builds/` (maintainer "stw", trusted long-time contributor) over the "official" release, since stw's build is expected to be equal-or-better quality.

**Tier 3 was started 2026-07-03 and immediately hit a dead end: no viable 1.10.3 Windows binary exists anywhere, from any source.** What was found:
- **stw's portal build #875** (`fbc_win64_mingw_0875_2025-04-21.zip`) was the specific build the plan pointed at â€” its changelog entry cites the exact right commit (`8708d1a`, confirmed on GitHub to be the real `1.10.3` tag). But the downloaded binary itself reports `--version` as **1.20.0**, and its bundled `changelog.txt` confirms large 1.20-era features already present (the same breaking `STRING*N` change, a WIP Clang backend, Android support). Root cause: stw's `win64/` build series is one continuous numbered stream tracking **trunk**, not a separate frozen maintenance branch â€” the "1.10.3 Release" commit is just a changelog-update commit that appears in trunk's shared history at that point, not a marker that trunk itself was in a 1.10.3 state. Trunk had already moved well past it by build #875.
- **No official binary exists either.** Checked GitHub Releases (`freebasic/fbc/releases`) â€” only goes up to 1.10.1 with attached Windows assets, nothing for 1.10.2/1.10.3. Checked SourceForge (`sourceforge.net/projects/fbc/files/`) â€” same story, no 1.10.2 or 1.10.3 release folder exists at all. A web search turned up nothing beyond 1.10.1 on any mirror either.
- **Getting an actual 1.10.3 binary would require building FreeBASIC from source** at the `1.10.3` git tag â€” a real undertaking, since FreeBASIC is self-hosting (needs an existing `fbc` to bootstrap a new one) plus a full MinGW-w64/GCC toolchain, not a quick task.

**Decided (owner, 2026-07-03): stay on the currently-bundled 1.10.1 rather than build from source for one point-release's worth of bugfixes.** Tier 3's "replace the compiler" work is closed for now, not deferred to "later in this same form" â€” if a genuine prebuilt point-release binary ever surfaces, or if the source-build effort becomes worthwhile for other reasons (e.g. paired with the already-planned "vendor the compiler's own source" work), this can be revisited then.

**This unblocks something:** the gas64-vs-GDB debugging check (below) was explicitly sequenced to wait for Tier 3 to land first, since a compiler swap could have invalidated the result. With Tier 3 now closed (staying on 1.10.1), **that sequencing reason no longer applies â€” the gas64/GDB check can proceed directly against the current toolchain whenever it's picked up**, no need to wait.

### Debugger backend decision: GDB, not gas64/Integrated

VFBE already supports two debugger paths for **user projects** (not the IDE itself) as a per-project setting (`ToGAS`/`ToGCC` in `src/BuildService.bas`/`src/TabWindow.bas`): the "Integrated IDE Debugger" in `src/Debug.bas` (requires the user's project compiled with `-gen gas/gas64 -g`, reads FreeBASIC's native stabs debug format directly) versus the "Integrated GDB Debugger" (requires `-gen gcc` + gcc debug flags, standard GDB). These are matched pairs, not interchangeable â€” `Debug.bas` explicitly errors if the wrong backend/debug-format combination is used.

**Decided: GDB is the project's debugger.** Settled by what's actually bundled: `Debuggers/gdb-11.2.90.20220320-x86_64/` contains only `gdb.exe`/`gdbserver.exe` â€” there's no separate gas64-native debugger tool anywhere in this repo, so the practical toolchain already implies GDB. This also matched the research-backed recommendation from the same session (Tiko, a comparable FreeBASIC IDE, recently reversed its own default away from gas64 back to GCC for 64-bit builds).

**RESOLVED 2026-07-03: `gas64` is dead. `-gen gcc` is the only compile backend, for both Development and Final.** The empirical check flagged above as a hard precondition was run and came back conclusively negative â€” not "GDB can't read gas64's format," but **gas64 doesn't emit usable debug information at all**:
- Compiled a small test program with `-gen gas64 -g` and inspected every layer: the raw generated `.asm`, the assembled `.o`, and the final linked `.exe`.
- The `.asm` output contains exactly one debug-related directive â€” `.file "test.bas"` (just names the source file) â€” and **zero `.loc` directives anywhere** (the directives that map machine instructions to source line numbers; without them there is no line-level information for any debugger to use). No `.stabs` directives either, despite `Debug.bas`'s Integrated debugger expecting stabs format from this exact backend/flag combination.
- The final `.exe` does contain DWARF sections (`.debug_info`, `.debug_line`, etc.), but they belong entirely to the statically-linked C runtime startup code (`crt2.o`/`crtbegin.o`/`fbrt0.o`), not to the user's own compiled program â€” confirmed by checking `info sources` in GDB, which lists only mingw-w64/libgcc C runtime paths, never the user's `.bas` file.
- Confirmed with two different program structures (a bare top-level script and a `Sub`-based structure closer to how real VFBE projects are written) â€” identical result both times.
- Net effect: `break test.bas:3` fails with "No source file named test.bas," and no variable can be inspected, because there is nothing for *any* debugger (GDB or the Integrated stabs-parser) to read. This isn't a GDB integration gap fixable from VFBE's side â€” the compiler backend itself doesn't produce debuggable output in this FreeBASIC version.

**Decided: `gas64` is removed from consideration entirely, per the contingency already agreed on.** `-gen gcc` + GDB is the only compile/debug path going forward. This also resolves the tradeoff that motivated considering `gas64` in the first place (fast compiles for the edit/compile/run loop) â€” there's no way to get that benefit from `gas64` without giving up debuggability, so it's not a real tradeoff anymore, just a dead end.

**Consequence: the Integrated (stabs) Debugger in `Debug.bas` is now confirmed dead code, not just "a candidate for future pruning."** It exists specifically to pair with `-gen gas/gas64 -g` output, which has just been shown not to contain the stabs data that debugger expects. See the code-stripping section below.

**Already decided and unaffected by this: Clang/LLVM (owner discussion, 2026-07-03).** MinGW isn't actually a distinct option here â€” the bundled `gcc.exe` under `Compiler/bin/win64/` is already a MinGW-w64 build; that's what makes it produce native Windows PE executables at all. Clang/LLVM is more interesting but not worth pursuing: `TabWindow.bas`'s `CompileTo` project setting exposed **four** backend choices in Project Properties â€” `ToGAS`, `ToGCC`, `ToLLVM`, `ToCLANG` â€” but `Compiler/bin/win64/` only ships GCC/binutils; there's no bundled `clang.exe` or LLVM tooling at all, so selecting Clang or LLVM would just fail. Not worth bundling a second full toolchain for a speculative benefit when FreeBASIC's own GCC backend is far more battle-tested. **With `gas64` now also dead, `ToGCC` is the only surviving backend** â€” all three others (`ToGAS`, `ToLLVM`, `ToCLANG`) are removed in the code-stripping pass below, not just deprioritized.

### Concrete design: Development/Final compile-mode toggle (owner decision, 2026-07-03)

**Decision: fully opinionated, no exposed compiler flags of any kind.** Per the owner's stance: don't surface compiler internals to this audience at all â€” pick the best default for the ~99% of users who don't care, and let the ~1% who do go find a different tool. This collapses what's currently **six separate Project Properties controls** into **one two-state choice**:

- Compile tab today: `optCompileToGas` / `optCompileToGcc` / `optCompileToLLVM` (backend radios) plus `optOptimizationFastCode` / `optOptimizationLevel` / `optOptimizationSmallCode` (three more controls, meaningful only for GCC)
- Debugging tab today: `chkCreateDebugInfo` (separate checkbox, disconnected from the compile-backend choice even though they're really the same decision)

**FINALIZED 2026-07-03: `gas64` is confirmed dead (see the gas64/GDB finding above) â€” both modes now use `-gen gcc`.** The two-state choice survives, just with a narrower meaning than originally hoped:
- **Development:** `-gen gcc`, debug info on, no optimization (`-O0`, the compiler default) â€” matches how the IDE's own `Compile.bat` already builds itself. Fastest of the two, immediately debuggable. Default for day-to-day edit/compile/run.
- **Final:** `-gen gcc`, debug info off, one fixed optimization level chosen by the project itself, never the user (`-O2` is a reasonable, uncontroversial default for typical hobbyist-scale programs â€” no need to expose the `-Ofast`-vs-`-Os` tradeoff to anyone). Produces the smaller/faster executable to hand out.

**`ToGAS`/`ToLLVM`/`ToCLANG` are all fully removed** â€” `ToGCC` is the only surviving backend. See the code-stripping section below for what this means in `Debug.bas`, `TabWindow.bas`, `VisualFBEditor.bas`, and `frmProjectProperties.frm`.

**Related cleanup found and done while investigating this (2026-07-03): leftover 32-bit GCC internals removed.** `Compiler/bin/libexec/gcc/i686-w64-mingw32/9.3.0/` was a complete parallel 32-bit GCC toolchain (its own `cc1.exe`, `as.exe`, `ld.exe`, plus 9 dependency DLLs â€” 31 MB, 12 files) sitting next to the real 64-bit one (`bin/libexec/gcc/x86_64-w64-mingw32/9.3.0/`). The earlier 32-bit-removal commit (`15e66cc`) only caught the top-level `Compiler/bin/win32/` folder and missed this deeper one. Confirmed zero references anywhere in build scripts or source before deleting; verified `-gen gcc` (IDE self-build via `Compile.bat`) still compiles clean afterward.

**Alternative worth a future conversation, not decided:** rather than a persisted per-project setting the user has to remember to toggle, "Development vs Final" could instead be modeled as two different **actions** â€” e.g. the existing "Run" (implying the fast/debuggable path) versus a separate "Build Release"/"Publish" command (implying the optimized path) â€” with *no* settings UI at all, since the mode would be implied by which command is invoked rather than a stored radio state. That pushes "don't expose it" one step further than even two radio buttons. Flagged here because it's in the spirit of today's discussion, but the two-radio design above is the one actually decided; this is offered as a possible refinement for later, not a competing plan.

### Code-stripping pass: remove dead alternative-debugger/compiler-backend support (2026-07-03, complete)

With `gas64` confirmed dead and Clang/LLVM never bundled, all code and UI that existed only to support them has been physically removed (not hidden), per this project's established dead-code discipline (Â§3a). Executed in two compile-gated passes, per owner instruction:

**Pass 1 â€” the Integrated (stabs) debugger engine and its dispatch branches:**
- `Debug.bas`: removed the entire Integrated debugger engine (breakpoint injection via `WriteProcessMemory`, stabs-format debug-info parsing, the DWARF-parser cluster, duplicate `cutup_*` chain, `elf_extract`, `proc_newfast`, `brkv_test`) â€” 12,059 â†’ 2,409 lines. `RunWithDebug` rewritten from a ~130-line function branching on custom-tool-path vs. GDB down to a ~40-line GDB-only function. The `DebuggerTypes` enum and `DefaultDebuggerType64`/`CurrentDebuggerType64` removed.
- `VisualFBEditor.bas`: collapsed all debug-dispatch `Case` branches (`Start`, `End`, `Restart`, `StepInto`, `StepOver`, `SetNextStatement`, `StepOut`, `RunToCursor`, `Breakpoint`, etc.) from `If CurrentDebugger = IntegratedGDBDebugger Then <GDB> Else <Integrated> End If` down to the GDB body only. Removed `"ShowVar"`/`"LocateProcedure"`/`"EnableDisable"`/`"VariableDump"`/`"PointedDataDump"`/`"MemoryDumpWatch"`/`"ShowStringWatch"`/`"ShowExpandVariableWatch"`/`"ShowString"`/`"ShowExpandVariable"` cases (Integrated-only, no GDB equivalent). `"AddWatch"` reimplemented on the existing GDB watch mechanism. `"Break"` (pause-while-running) left as a documented no-op â€” it was only ever wired for the Integrated debugger; GDB has no equivalent yet. This is a pre-existing gap, not a regression.
- `Main.bas`: removed `TimerProc` (only reachable from the deleted engine), a dead `shwtab`/`proc_sh` handler, emptied `tvPrc_NodeActivate`/`tvVar_Message` bodies (widgets kept for now, pending the UI sweep below).

**Pass 2 â€” the compile-backend choice and the debugger-choice/custom-external-debugger-tool feature:**
- `TabWindow.bi`/`TabWindow.bas`/`BuildService.bas`: `CompileToVariants` enum reduced to `ByDefault, ToGCC`; all `ToGAS`/`ToLLVM`/`ToCLANG` branches removed from compile-line construction.
- `frmProjectProperties.frm`/`.bi`: removed `optCompileToGas`/`optCompileToLLVM`/`optCompileToClang` radio buttons and their handlers; renamed the shared enable/disable handler to `UpdateOptimizationControlsEnabled`. Kept the optimization-level controls (independent setting, out of scope).
- Per owner decision ("Remove everything") the debugger-*choice* mechanism was removed together with the separate custom-external-debugger-tool feature it was entangled with, since neither has a reason to exist with GDB as the only debugger: `Main.bi`/`Main.bas` (`pDebuggers` Dictionary, `Debugger64Path`/`GDBDebugger64Path` settings; added `BUNDLED_GDB_PATH` constant so GDB's path is hardcoded like the bundled compiler), `SettingsService.bas` (removed the corresponding INI-loading blocks), `frmParameters.frm`/`.bi` (removed the `cboDebug64` debugger-choice combo; kept the unrelated `txtDebug64` extra-debug-arguments field), `frmOptions.frm`/`.bi` (removed the whole `grbDefaultDebuggers`/`grbDebuggerPaths` group â€” combos, `lvDebuggerPaths` ListView, Add/Remove/Change/Clear buttons and their handlers â€” 249 lines. Kept the rest of the "Debugger" options page: `chkLimitDebug`, `chkDisplayWarningsInDebug`, `chkTurnOnEnvironmentVariables`/`txtEnvironmentVariables`, which are general debug preferences unrelated to debugger choice).
- Two example `.vfp` files needed a `CompileTo=` ordinal migration since the enum shrank: `Examples/ChineseCalendar/ChineseCalendar.vfp` (old `ToGAS`=1 â†’ `ByDefault`=0) and `Examples/gdipClock/gdipClock.vfp` (old `ToGCC`=3 â†’ new `ToGCC`=1). Repo-wide grep confirmed no other `.vfp`/template needed migration.

**Result:** 14 source files changed, 146 insertions(+), 10,360 deletions(-) â€” `Debug.bas` alone accounts for -9,812 net lines. Verified via a final clean Release compile (0 errors/warnings) and a repo-wide grep confirming no removed identifier remains referenced anywhere in `.bas`/`.bi`/`.frm` files. Every intermediate compile error was resolved by tracing the exact error back to its definition/callers (never guessed) â€” stragglers the original mapping missed included `kill_process`, `re_ini`, `get_var_value`, `proc_loc`/`proc_enable`, `var_dump`/`string_sh`/`shwexp_new`, `check_bitness`, `reinit()`, all confirmed genuinely Integrated-only before removal, except `kill_process` which was restored with just its Integrated-only inner branch trimmed since `CloseSession` has a legitimate unconditional caller.

**Deferred (not part of this pass):** the child TreeView widgets `tvPrc`/`tvVar`/`tvThd`/`tvWch` in the Debug panel are now fully inert (their handlers were emptied, not removed, since the widgets themselves still exist) â€” folding them into the still-open **UI/settings sweep** noted under Â§13.2 is the natural next step, along with any other GTK/Linux/alt-compiler/alt-debugger remnants visible in the UI but not yet touched by this code-level pass.

**Post-merge regression found and fixed (2026-07-03):** this pass's `SettingsService.bas` edit removed the `"Debuggers"` section from `NoMoreIndexedSettingsKeys`'s multi-section key-existence check (8 sections remain) but left the function's termination condition at `Return keySum = -9` â€” a magic number that was never updated to match the new count (should be `-8`). Since `keySum` can now reach at most `-8`, the condition could never be true, and `LoadSettings`' `Do ... Loop Until NoMoreIndexedSettingsKeys(i)` (line ~225) never terminated â€” a genuine infinite loop, not a deadlock, burning 100% CPU on every startup. The commit compiled clean and passed the dead-identifier grep sweep, but nobody actually *launched* the app afterward, so this shipped to Codeberg undetected until the next session's dark-mode work prompted an actual smoke test. Found by binary-bisecting between this commit and the previous known-good commit (`e139c2c`), then narrowing file-by-file until the exact function was implicated. Fixed by correcting the constant to `-8`. **Lesson: a clean compile + grep sweep is necessary but not sufficient for large removals â€” launch the app at least once afterward, especially after touching loop-termination logic.**

### Session 2026-07-05 (part 2): automatic workspace, File menu, bottom panel tab captions

**Automatic workspace (replaces `.vfs` sessions in UX):**

- Removed session menus, MRU sessions, `.vfs` filters, and `RenameProject` from the File menu.
- Internal workspace at `Settings/Workspace.ini` via `SaveWorkspace()` / `LoadWorkspace()` â€” saves open project + editor tabs on exit; restores on cold start unless a command-line file is opened or Options create-default-project applies.
- Single-project model: opening another project calls `PrepareForAnotherProject()` â†’ `CloseProject()` with save prompt.
- Renamed `CloseSession` â†’ `CloseAllDocuments()`; removed `AutoSaveSession` and session-related INI keys from `SettingsService.bas`.

**File menu restructure:**

- **Project section:** New Project, Open Project, Recent Projects, Close/Delete Project, Close Folder, Save Project / Save Project As.
- **File section (new):** New File, Open File, Recent Files (stub), Close File, Delete File (stub), Save File, Save File As.
- Removed ambiguous Save/Save As/Save All/Close/Close All items and Rename Project.
- WinAPI name clashes (`OpenFile`, `DeleteFile`) resolved: menu commands keep short names; internal subs are `OpenEditorFile()`, `CloseEditorFile()`, etc.
- **New forms:** `frmNewFile` (file templates from `Templates/Files/`), `frmOpenProject` (`.vfp` only), `frmRecentProjects`.
- Filter fixes: Open File no longer offers `.vfp`; New Project lists `Templates/Projects/*.vfp` only.

**Bottom panel tab caption bug (found + fixed same session):**

**Symptom:** All always-visible bottom tabs showed "Globals" instead of Output, Problems, etc.

**Root cause:** `SetDebugTabsVisible(False)` (added in prior commit) called `DeleteTab` on tabs created by `InsertTab`, which marks them `FDynamic`. `DeleteTab` then **destroyed** the `TabPage` objects while global pointers (`tpGlobals`, etc.) remained. `ClearDebugPanels` also wrote captions to freed tabs after project close â†’ heap corruption. Debug tabs were hidden **after** the tab-control HWND was created, so Win32 labels were built for all 14 tabs first. Saved INI indices of `-1` (from detached tabs) caused every tab to insert at index 0 on next load.

**Fix:**

- `TabControl.DetachTab()` â€” removes a tab from the strip without destroying the page (mirrors `AddTab`'s FDynamic guard).
- `SetDebugTabsVisible` uses `DetachTab` / guarded `AddTab`; `ClearDebugPanels` only updates captions when `Parent <> 0`.
- Hide debug tabs **before** `ptabBottom->Parent` assignment so `HandleIsAllocated` only registers the 7 always-visible tabs.
- `AddToTabControl`: treat saved index `-1` as default index; `SaveTabPagePlacement`: guard `Parent = 0`.

**Compile:** `CompileDebug.bat` â€” 0 errors (2026-07-05).

**Deferred to next session (owner):**

- [ ] **Bottom panel manual test checklist** â€” startup tab names, debug show/hide, project close, tab order persistence (checklist prepared in agent handoff).
- [ ] `OpenRecentFiles()` â€” stub; needs `frmRecentFiles` dialog.
- [ ] `DeleteEditorFile()` â€” stub.
- [ ] `frmNewProject` template icons â€” `@imgList32` may not be populated at form creation time.

### Session 2026-07-05 (part 3): Run menu consolidation & GDB debug UX

**Goal:** One **Run** menu for all run/debug commands; no duplicate Debug menubar; reliable enable/disable when **Use Debugger** is toggled.

**Run menu structure (menubar: Build â†’ Run â†’ Tools):**

1. **Session** â€” Start With Compile, Start, Continue, Break, End, Restart  
2. **Stepping** â€” Step Into/Over/Out, Run To Cursor  
3. **Debugger options** â€” Use Debugger, Use Profiler  
4. **Breakpoints** â€” Toggle Breakpoint, Clear All Breakpoints  
5. **Advanced** â€” GDB Command, Add Watch  
6. **Execution point** â€” Set Next Statement, Show Next Statement  

The separate **Debug** menubar item was removed. The **Debug toolbar** (View â†’ Toolbars â†’ Debug) is unchanged.

**Fixes in this session:**

- **GDB mutex deadlock** at breakpoint stop â€” debug thread no longer self-deadlocks on `tlockGDB`; Step/Continue work after stop (`Debug.bas`).
- **Debug tabs** â€” show/hide tied to **Use Debugger**; `DetachTab`/`AddTab` pattern preserved; no heap corruption on hide.
- **Use Debugger toggle** â€” menu check items don't auto-toggle in MFF; handler uses `Not UseDebugger` and syncs menu + toolbar checked state.
- **Menu enable state** â€” `ChangeMenuItemsEnabled` and `frmMain_ActiveControlChanged` call `ChangeEnabledDebug` instead of overriding run/step items; **Use Profiler** gated on debugger; **Clear All Breakpoints** implemented (`EditControl.ClearAllBreakpoints`, `ClearAllBreakpoints()`).
- **Set Next Statement / Run To Cursor** â€” editor-focus and idle-vs-stopped enable logic corrected.

**Key files:** `src/Main.bas`, `src/VisualFBEditor.bas`, `src/Debug.bas`, `src/TabWindow.bas`, `src/EditControl.bas`, `Controls/MyFbFramework/mff/TabControl.bas`.

**Compile:** `CompileDebug.bat` â€” 0 errors (2026-07-05).

**Owner sign-off:** Run menu complete (2026-07-05).

### Session 2026-07-05 (part 4): GDB debugger fixes & bottom tab captions

**Owner sign-off:** Bottom panel tab-caption regression fixed (2026-07-05).

**GDB debugger fixes:**

1. **Step Out** â€” `step_debug("finish")` instead of `"n"` (`VisualFBEditor.bas`).
2. **Command dispatch queue** â€” replaced single `NewCommand` string with a 32-slot ring buffer (`EnqueueDebugCommand`, `DequeueDebugCommandLocked` in `Debug.bas`); `continue_debug`, `step_debug`, `command_debug`, and close-all-documents quit path use the queue.
3. **Break while running** â€” `break_debug()` sends GDB `interrupt`; debug thread releases `tlockGDB` during blocking `readpipe` so the UI thread can inject the interrupt.

**Compile:** `CompileDebug.bat` â€” 0 errors (2026-07-05).

### Session 2026-07-06: Â§13.3 step-by-step UI review â€” File menu

**Owner sign-off:** File menu modified & approved (2026-07-06). Next: Edit menu (Â§13.3 step-by-step review).

**File menu work this session:**

- Open Project vs Recent Projects fix â€” distinct flows, no duplicate MRU entry points
- `ProjectsPath` from Options â€” Open Project dialog honors configured projects folder
- Path sanitization â€” `CanonicalWinPath`, INI hygiene for stored paths
- Open Project tabbed dialog â€” **Projects** + **Examples** tabs in `frmOpenProject`
- Examples scan `Dir()` fix â€” correct directory enumeration for Examples listing
- ScanTest listing â€” `Projects/ScanTest` and related scan paths verified in Open Project UI

See Â§13.3 **UI review progress** for menu-by-menu status.

---

