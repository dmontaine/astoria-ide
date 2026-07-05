# VFBE Win64 Fork — Project Status & Handoff

**Last updated:** 2026-07-03  
**Repository:** [codeberg.org/bigriverguy/VFBEWin64](https://codeberg.org/bigriverguy/VFBEWin64)  
**Local path:** `C:\Users\dmont\VisualFBEditor`  
**Owner:** bigriverguy (`dmontaine@gmail.com`)

This document captures project history, completed work, open items, and workflow rules for continuing development (e.g. in Claude Code) without re-discovering context.

---

## 1. Project overview

**Visual FB Editor (VFBE)** is a FreeBASIC IDE with visual designer, debugger, and project support, built on [MyFbFramework](https://github.com/XusinboyBekchanov/Controls/MyFbFramework).

This fork (**VFBEWin64**) is a **Win64-only** branch of upstream VisualFBEditor:

| Keep | Remove / defer |
|------|----------------|
| Native **WinAPI / Win32** UI | GTK / Linux IDE paths (physically deleted, not just hidden) |
| **64-bit** IDE and bundled `fbc64.exe` | 32-bit IDE (`VisualFBEditor32`, `mff32`) |
| Bundled compiler at `Compiler\fbc64.exe` (tracked in-repo; staying on 1.10.1 — see Tier 3, no viable 1.10.3 binary exists) | Dark-mode *implementation* — replaced with an inert stub, interface preserved for a future trustworthy reimplementation (not full removal — see §3a) |

**This is now a fully self-contained fork:** `Compiler/`, `Debuggers/`, and `Controls/MyFbFramework/` are tracked in git (previously vendored/gitignored) — see §3a and §12.

**Build outputs (repo root):**

- `mff64.dll` — `Controls\MyFbFramework\mff64.dll`
- `VisualFBEditor64.exe` — main IDE

**Settings:** `Settings/VisualFBEditor64.ini` (runtime; path via `ExePath/Settings/...`)

### Target audience

This shapes UI/UX decisions (§13.3) and the installer/distribution work (§13.5) — the product is for people who want to *write BASIC programs*, not people evaluating IDE architecture:

- **Returning BASIC programmers** — learned on Basic (QBasic, VB, etc.) years ago, remember it fondly, but have been put off by modern languages' object-orientation requirements and by how hard it's become to write a rich GUI program without a heavyweight framework or web stack.
- **Desktop-focused hobbyists** — want to build actual desktop programs, not web apps, and are put off by the disjointed nature of modern development (juggling many separate tools/services instead of one cohesive IDE that just works).
- **Students** — many schools still start programming instruction with Basic, since it's more approachable than even Python for a true beginner.

Common thread: **approachability and cohesion over power-user configurability.** None of these audiences want to assemble a toolchain or fight object-oriented ceremony to get a window on screen — the value proposition is "open one IDE, write BASIC, get a real GUI program," which is exactly the niche modern tooling has abandoned. Keep this in mind against feature creep: the original project's failure mode (§13.4) was doing too much without central attention; this audience is better served by a smaller, more polished, more approachable tool than by chasing feature parity with professional IDEs.

### Guiding principle: don't give the user unnecessary options (added 2026-07-03)

**This is a highly opinionated project, not a configurable one.** The focus is build → design → compile → run being as smooth and frictionless as possible. Power users who want knobs to turn have other IDEs; this one should not encourage settings-fiddling as a substitute for a good default.

**Rule of thumb when adding or reviewing any feature:**
- If there's only one reasonable choice, **don't expose a setting for it at all** — just do the right thing and don't show the option.
- If there are genuinely two reasonable choices (e.g. a debug build vs. a final/release build), give a single simple choice — one radio button or dropdown with plain labels (e.g. "Debugger: Development / Final") — not a settings page with independently-togglable flags that happen to combine into those two states.
- Only expose real configurability when there's a **real, user-facing reason** someone would need to change it — not "because the underlying implementation happens to have a flag here." An internal implementation detail becoming a user-facing setting is a smell, not a feature.
- When in doubt, prefer fewer visible options over more. This is the same anti-scope-creep instinct as §13.4's rename rationale, applied specifically to UI/settings surface rather than codebase surface.

**How to apply:** relevant to §13.3 (UI evaluation) and §13.5 (installer) — both should be scoped against this principle, not against "what a power-user IDE like VS Code offers." When §13.2's structured-programming pass or any future feature work exposes an existing internal flag as a new checkbox/dropdown "just in case," push back and ask whether the option needs to exist at all.

---

## 2. Repository & toolchain

### Git remote

```
origin  git@codeberg.org:bigriverguy/VFBEWin64.git
branch  main
```

SSH key: `~/.ssh/id_ed25519_codeberg` (Host `codeberg.org` in `~/.ssh/config`).

**Note:** Git may not be on PATH in all shells; full path:

`C:\Program Files\Git\bin\git.exe`

### Build before running the IDE

Close any running `VisualFBEditor64.exe` first (`mff64.dll` is locked while the IDE runs).

```powershell
cd C:\Users\dmont\VisualFBEditor
set NOPAUSE=1
Compile.bat
.\VisualFBEditor64.exe
```

- **Release:** `Compile.bat` (root)
- **Debug:** `CompileDebug.bat`
- **Gate:** `Compile.bat` must finish with **0 errors** before handoff or user testing
- Use `set NOPAUSE=1` in automated/agent shells to avoid orphaned `pause` processes

See also `src/BUILD.md` and `README.md`.

---

## 3. Roadmap: Tier 2.75 dead-code removal

Work is organized in batches.

| Batch | Scope | Status |
|-------|--------|--------|
| **2.75.1** | Panel/layout cleanup in `Main.bas` | **Complete** (compile-clean) |
| **2.75.2** | Bulk GTK preprocessor strip (`Tools/strip_gtk_preprocessor.ps1` on `src/` + `mff/`) | **Complete** (compile-clean). Manual test plan in §7 was **not fully signed off** before the owner explicitly directed the team to proceed into 2.75.3 anyway — see note below. |
| **2.75.3** | Physical deletion of commented `#IfNDef __USE_GTK__`/`__FB_WIN32__` remnants, dead-legacy-code pass, `mff/DarkMode/` handling | **Complete** — see §3a |

> **Process note:** §7's original gate said Batch 2.75.3 should be blocked on full manual sign-off. The owner explicitly chose to start 2.75.3 before that checklist was finished (several boxes below are still open). That was a deliberate call, not an oversight — flagging it here so future sessions don't assume the gate was satisfied by testing.

### GTK strip tool

```powershell
.\Tools\strip_gtk_preprocessor.ps1 src mff
```

Evaluates `#If` / `#Else` / `#EndIf` with Win64 defines (`__USE_WINAPI__`, `__FB_WIN32__`, `__FB_64BIT__`, GTK off). Had a blind spot for the `__EXPORT_PROCS__` symbol (fixed — see §3a); re-run only if new GTK-era files are introduced, and review failures manually for interwoven blocks.

**Safety net for any future re-run (audit flag, 2026-07-03):** the `__EXPORT_PROCS__` blind spot silently deleted `mff64.dll`'s entire export dispatcher, and a clean compile did not catch it — the damage only surfaced when the Designer was exercised at runtime. Before re-running the tool: make sure the working tree is clean so the resulting diff is fully reviewable file-by-file, don't rely on compile-clean alone. After re-running: spot-check that `mff64.dll` still exports the expected symbols (e.g. `dumpbin /exports mff64.dll`) before treating the run as verified.

---

## 3a. Batch 2.75.3 — what actually happened

Beyond the originally-scoped "strip commented GTK markers," this batch also caught and fixed a **shipped-broken Designer** and expanded to a broader dead-legacy-code pass at the owner's explicit direction ("also remove old dead legacy code" encountered along the way, not just GTK-tagged code).

**Root-cause fix — Form Designer never activated for any `.frm` file:**
`Tools/strip_gtk_preprocessor.ps1` didn't recognize the `__EXPORT_PROCS__` macro and silently deleted the entire `#ifdef __EXPORT_PROCS__` export-dispatcher block from `mff.bi` plus per-file `Export` functions in ~14 `mff/*.bas` files, so `mff64.dll` shipped with **zero exports**. Fixed the strip tool and manually restored the missing blocks (2 `ToolBar.bas` functions deliberately deferred — restoring them hits an unresolved FreeBASIC "Illegal specification" compiler quirk on a `Private Enum` parameter; not called anywhere in the IDE itself). Commit `bef9267`.

**Dark mode — replaced, not removed:**
The undocumented-API dark-mode implementation (ordinal-resolved `uxtheme.dll` calls, `ntdll` version probing, IAT hooking) was flagged by the owner as unreliable and untrusted. Replaced with an inert stub (`mff/DarkMode/DarkMode.bi`/`.bas`) that preserves the exact public interface as no-ops, so every call site still compiles and behaves as before (dark mode was already forced off). This intentionally leaves a clean seam for a trustworthy reimplementation later rather than deleting the integration points. `mff/DarkMode/IatHook.bi` (zero references) deleted outright; `UAHMenuBar.bi` kept (still used by `Form.bas`, unrelated to the ordinal/IAT fragility). Commit `56f6d18`.

**Dark mode — reimplemented with documented APIs (2026-07-03):** the seam left above was filled in. `DarkMode.bi`/`.bas` now use only documented, stable Win32 APIs: `SetWindowTheme` (uxtheme), `DwmSetWindowAttribute` (dwmapi, declared by hand with an explicit `Alias` since FB's default linkage would otherwise mangle the symbol and fail to link), `RtlGetVersion` (ntdll, documented WDK API, gives the true build number unlike `GetVersionEx`), a registry read of `HKCU...Personalize\AppsUseLightTheme` for the live system preference, and `WM_SETTINGCHANGE`/`"ImmersiveColorSet"` for change notification. No ordinals, no IAT hooking, no internal-structure probing. Every existing `SetDark`/`AllowDarkModeForWindow`/etc. call site across ~25 control files was already intact and needed no changes — only the 11 functions in `DarkMode.bas` had to be rewritten. The Dark Mode checkbox (previously force-hidden and force-disabled) is un-hidden — reparented onto the General options page since its old home (`grbThemes`/`pnlThemes`) turned out to be an orphaned page with no tree node pointing to it, not reachable from the UI at all — and now actually persists to/from the INI instead of being hardcoded off in three separate places (`Main.bas`, `SettingsService.bas`, `frmOptions.frm`'s save path). The broken interface color/theme picker on that same orphaned page stays hidden — separate, still-broken feature, out of scope here.

**Dark mode — crash history (2026-07-04, ALL RESOLVED — see the "crash #3 root-caused and fixed" entry below):** the checkbox and persistence are correct, and the app runs fine with the setting off. But turning it on genuinely crashed the app — confirmed via repeated reproduction, not a one-off. Two real bugs were found and fixed in the first investigation session, and a third remained open until the follow-up session the same day:

1. **Fixed:** `SetDarkMode`'s `WM_SETTINGCHANGE` broadcast passed `StrPtr("ImmersiveColorSet")` — an ANSI string pointer — as the lParam, which the Win32 API contract requires to be a wide (UTF-16) string. Every window on the desktop that received the broadcast (not just ours) read past the buffer trying to interpret it as wide, and this reproducibly crashed inside `UxTheme.dll` (`0xc0000005`, confirmed via Windows Event Viewer). Fixed with a `Static As WString * 32` so the pointer is both correctly encoded and has a guaranteed lifetime.
2. **Fixed:** `SetDarkMode` was being called (via `SettingsService.LoadSettings`, applying the saved INI setting) very early in startup, while only the splash screen exists, and still performed the full desktop-wide broadcast every time — pointless that early (nothing of ours exists yet to refresh) and needless risk. Added a `DoBroadcast As Boolean = True` parameter; the startup call site now bypasses the `App.DarkMode` property (which always broadcasts) and calls `SetDarkMode` directly with broadcast suppressed. The live Options-dialog Apply-button path is unchanged and still broadcasts, since that's the case that actually needs it.
3. **Still open:** even with both of the above fixed, enabling dark mode still crashes — confirmed by two separate repro runs, both `0xc0000005` inside `UxTheme.dll` at the same faulting offset as bug #1, but the *symptom's timing varies*: one run crashed during a splash-screen label repaint, another got further and crashed at main-form load. This points at `SetWindowTheme`/`AllowDarkModeForWindow` itself being unsafe to call this early in the control-creation sequence (`g_darkModeEnabled` is now `True` from very early in startup, so *every* control's first `WM_PAINT` tries to theme it, immediately, including ones created before whatever Windows normally expects to be initialized first) — not a string/encoding issue this time. Leading hypothesis for next session: defer actually enabling dark mode (setting `g_darkModeEnabled`/calling `SetDark` on existing controls) until after the main form and its full control tree exist, rather than applying it while only the splash screen is up.

**Crash #3 root-caused and FIXED (2026-07-04, follow-up session, via live GDB debugging):** the "unsafe to theme controls early" hypothesis above turned out to be wrong. A debug build (`CompileDebug.bat`, `-g -exx -O0`) run under the bundled GDB (`Debuggers/gdb-11.2.90.20220320-x86_64/bin/gdb.exe -batch -ex run -ex bt`) caught the crash live with a symbolic backtrace: **infinite recursion → stack overflow.** `SetWindowTheme` synchronously sends `WM_THEMECHANGED` back to the window it themes (observed wParam=-1, lParam=0x80000001 — the system-generated signature, decimal msg 794), and five control classes' `WM_THEMECHANGED` handlers (`Form`, `Grid`, `ListView`, `TreeListView`, `TreeView`) respond by calling `AllowDarkModeForWindow` → `SetWindowTheme` again → unbounded mutual recursion until the stack guard page is hit. Every earlier observation now fits: the "same UxTheme.dll faulting offset" was just where the guard page happened to be hit inside the recursion cycle's frames, and the variable crash timing (splash label vs. main-form load) was whichever themed window received the message first. **Fix:** one same-window re-entrancy guard (a `Static As HWND` slot) inside `AllowDarkModeForWindow` itself (`DarkMode.bas`) — the single choke point all five handlers share — rather than five per-class guards; nested calls for a *different* window (e.g. a ListView theming its header from inside its own handler) still pass. **This also fixed a latent crash-on-system-theme-change:** those handlers are gated on `g_darkModeSupported` only (not `g_darkModeEnabled`), so the same recursion would have fired even with dark mode off the moment the user toggled Windows' own light/dark setting while the IDE ran.

**Dark mode visual completion (same session):** with the crash gone, dark mode rendered only partially (light menu bar/toolbars on some activation states, light tab strips, big white central area). Findings and fixes:
- **Menu bar / toolbars needed no code changes** — the full adzm-style UAH owner-drawn dark menu bar (`Form.bas` `WM_UAHDRAWMENU`/`WM_UAHDRAWMENUITEM`/`WM_NCPAINT` handlers, structs in `mff/DarkMode/UAHMenuBar.bi`) and the ToolBar/ReBar `NM_CUSTOMDRAW` dark paths were already present and working; GDB breakpoint instrumentation confirmed 8 bar paints × 12 items all executing the dark path. An early screenshot showing them light was a transient corrected by a window-activation cycle.
- **`TabControl` (`TabControl.bas`) was the real gap**: its dark custom paint existed only for `tpLeft`/`tpRight` (rotated side captions); all three visible strips (`tabLeft` Project/Toolbox/AI Agent, `tabBottom` Output/... , and each editor `tabCode`) are `tpTop` (the constructor default — the `tpBottom`/`tpRight` assignments in `Main.bas` are commented out), where `TCS_OWNERDRAWFIXED` is deliberately switched off, so the native control painted them light. Added a horizontal-tab dark-paint branch mirroring the vertical one (strip fill, `hbrHlBkgnd` selected-tab highlight, `ImageList_Draw` icon, caption via `DrawText`).
- **The big central white area was `WM_ERASEBKGND` claiming "erased" while painting nothing** (`Message.Result = -1` with no `FillRect`), so the default white showed through the empty `tabCode` body. Now fills with `hbrBkgnd` before claiming handled.

**Current state:** `DarkMode=true` is enabled in the owner's INI and stable — title bar, menu bar, toolbars, tab strips, central area, panels, trees, output, and status bar all render dark. **Known remaining gaps (deferred, see §13.10):** popup/dropdown menus are still light — Windows has no documented API for dark Win32 popup menus; the framework's owner-draw scaffolding exists (`Menu.Style` flips items to `MFT_OWNERDRAW`) but its `WM_DRAWITEM ODT_MENU` handler is empty, so enabling it today would draw blank menus. Also minor: input-field faces (search box, combo edit areas) stay light-ish under the `DarkMode_CFD` theme.

**Post-merge regression #2 found and fixed (2026-07-03) — General options page checkbox overlap:** un-hiding Dark Mode surfaced a second, independent, pre-existing bug (not caused by tonight's work, just never noticed since nobody had looked closely at this exact page before): `pnlInterfaceFont`/`chkDisplayIcons`/`chkShowMainToolbar`/`chkShowPropLocal`/`chkDarkMode` are relocated into `vbxGeneral` at runtime (`frmOptions.frm`'s Constructor, "Move interface settings to General" block) *after* they were already constructed — and originally only `pnlInterfaceFont` got an explicit `.ControlIndex` to pin its stacking position; the other four didn't. Fixed by giving all four explicit sequential `ControlIndex` values (1–4), matching the pattern the file already uses elsewhere (`chkAutoCreateRC.ControlIndex = 1`, etc.) — Add(), Component.bas.

That fix alone wasn't sufficient: a second, deeper issue meant these same 5 relocated controls' on-screen positions got reset back to their pre-relocation absolute coordinates the first time the General page became visible, landing on top of the five controls that were always native to `vbxGeneral`. Root-caused via three rounds of temporary instrumentation (removed afterward) added directly to `Control.RequestAlign`/`Component.Move`/`Component.SetBounds` in the shared framework, logging every call `vbxGeneral` and its children made during a live run — confirmed `RequestAlign` always computes the correct stacked position on every pass, but something in a native-window-recreation cascade re-applies stale pre-relocation bounds afterward, specifically for controls that had already been constructed (with a window) under their old parent before being reparented. The exact trigger point wasn't pinned to one line even with this instrumentation. Rather than risk a deeper change to this 20+-year-old inherited docking engine on partial understanding, applied a safe, targeted fix: `frmOptions.frm`'s `TreeView1_SelChange` now forces one more explicit `vbxGeneral.RequestAlign` right after the General page becomes visible, guaranteeing the final on-screen layout is always the correct computed stack regardless of what the earlier reset does. Verified visually (screenshot) — all rows render cleanly, Dark Mode checkbox shows on its own line, unchecked.

**Confirmed-dead subtree deletion:** `mff/gir_headers/`, `mff/WebView/`, `mff/fbsound/`, `SoundPlayer.bas`/`.bi` — 109 files, ~104k lines, zero references anywhere, verified via clean rebuild. Commit `c494207`.

**Compile warnings:** all resolved (WString default-parameter fixes, `AndAlso`-chained boolean/pointer-property comparisons isolated into explicit `Boolean` locals). Commits `53d8e47` + `56f6d18` (first pass under-verified due to a UTF-16 log encoding gotcha with raw `grep`; corrected in the second commit).

**Physical dead-code deletion** (the literal instruction: delete, don't hide) across:
- `src/Debug.bas` — dead conditional-breakpoint UI functions, a dead `get_main_file_from_exe`/`get_name_files_from_exe` pair, a duplicate ~300-line dead 32-bit stabs-parsing branch, misc stray markers. Commit `7baebd1`.
- `src/Designer.bas`/`.bi`, `src/Main.bas`/`.bi`, `src/TabWindow.bas`, `src/VisualFBEditor.bas` — dead WM_KEYDOWN/GTK popup-menu branches, a ~300-line dead GTK VTE-terminal integration block, a dead ListView-based property-panel implementation (superseded by the current `TreeListView`-based one), dead debugger-UI branches. Commit `add4642`.
- `Controls/MyFbFramework/mff/*.bas` (16 files) — dead GTK-only branches, dead sort/alignment/tooltip logic, dead PNG-loading functions; `NativeFontControl.bas`/`.bi` deleted outright (100% commented out, confirmed unreferenced anywhere). Commit `76abaa5`.

**Verification:** every commit above passed a clean `Compile.bat` rebuild (0 warnings, 0 errors — checked with the `Read` tool, since the log is UTF-16 and raw `grep` silently false-negatives on it). A final repo-wide sweep confirms only one GTK/32-bit marker remains anywhere in `src/` or `mff/`: `TabWindow.bas`'s `CheckCondition()`, which evaluates `#if` conditions in the *user's* FreeBASIC code being edited — a legitimate IDE feature, correctly left alone.

**Git-tracking policy change:** `Compiler/` and `Debuggers/` are now tracked in git (previously vendored/gitignored) — this is intentionally a fully self-contained fork going forward. Commit `b555406`. 32-bit compiler binaries (`Compiler/bin/win32`) removed as out of scope. Commit `15e66cc`.

---

## 3b. Examples/ GTK/Linux/Win32-only audit (2026-07-03) — result: nothing to remove

**Premise checked and rejected:** went through all 33 `Examples/` subdirectories looking for GTK-dependent, Linux-only, or Win32-only (non-64-bit-compatible) example projects to remove as leftover cross-platform cruft. **None qualified.** The `#ifdef __USE_GTK__` blocks present in ~15 `.frm` files are harmless MyFbFramework designer boilerplate (an icon-loading fallback that resolves to the Windows `#else` branch) — not real GTK dependencies. `__FB_WIN32__`/`__FB_LINUX__`/`__FB_UNIX__` checks found are standard FreeBASIC "which OS" conditionals that correctly fall through to Windows-appropriate code. Every example either has valid 64-bit `.vfp` compile args already, or has source that's fully Win64-portable regardless of a missing project file.

**Follow-up work done as a result of the audit, instead:**

- **Fixed a real bug found incidentally:** `Examples/Add-In/Module1.bas` and `Examples/Add-In/My Add-In.bas` both called `mff.MenuFindByName(mnuMenu, "Service")` — the top-level menu commit `ae74b31` renamed from "Service" to "Tools". Both files fixed (string and the `mnuService`→`mnuTools` variable rename for clarity). `Module1.bas` is the more complete/current of the two duplicate implementations (has an extra `OnBeforeCompile` handler `My Add-In.bas` lacks) and is now the file wired into the new `.vfp`; `My Add-In.bas` is left in place, fixed, but not part of the compiled project.
- **Created missing `.vfp` project files** for examples that had none (a project-hygiene gap, not a platform issue): `Add-In`, `Graphics`, `Web Page`, `WellCOM Example` (two projects: `WellCOM.vfp` the COM server DLL, `Test_WellCOM.vfp` the console test client), and three of four `Game` subfolders (`Calculator`, `FiveInARow`, `Maze` — `Sudoku` already had one). Also created missing `Manifest.xml`/resource `.rc` files where a `.frm`'s embedded `#cmdline "Form1.rc"` designer directive pointed at a file that didn't exist (`Web Page`, `Maze`, `FiveInARow`'s manifest).
- **Verified by direct compilation** (same technique as the `_WIN32_WINNT` fix verification, §4): every new project was compiled directly with `fbc64.exe` using IDE-equivalent flags before being considered done. Confirmed compiling clean: `Add-In`, `Web Page`, `Maze`, `Calculator`, `FiveInARow`, `Test_WellCOM`, `Graphics` (see below).

**`Examples/Graphics/CanvasDraw.bas` — fixed (2026-07-03).** Investigated before assuming a rewrite was needed, and it turned out to be three small, well-evidenced fixes rather than an open-ended API-drift rewrite:
- `CreateDoubleBuffer`/`TransferDoubleBuffer` calls (4 total) simply don't exist anymore in `mff/Canvas.bi` — no replacement needed, since double-buffering is now handled internally by the framework (the old manual buffer-blit logic in `Canvas.bas` is commented out, `Control.bi` now exposes a `DoubleBuffered` property instead). Deleted the dead calls.
- `.Pen.Style = 3` / `.Pen.Style = 0` (bare integers) failed against the now strictly-typed `PenStyle` enum property. The original author had already left themselves the answer in a comment (`'PenStyle.psDashDot`) — swapped the magic numbers for the named constants (`psDashDot = 3`, `psSolid = 0`, confirmed against the enum).
- `.StretchImage = StretchMode.smStretchProportional` was ambiguous, not wrong — `My.Sys.Forms` (`Control.bi`) and `My.Sys.Drawing` (`Graphic.bi`) each independently define an identical `StretchMode` enum for their own purposes, and the example has `Using` for both namespaces in scope. `Picture.StretchImage` specifically expects the `My.Sys.Forms` one; fully-qualifying the reference resolved it with no framework changes needed.

Verified via direct `fbc64` compile — clean, 0 errors.

**`Examples/WellCOM Example/WellCOM.bas` doesn't compile with the bundled FreeBASIC 1.10.1 — still open, flagged for a decision, not fixed.** It defines its own `Function DllMain(...) As Boolean`, which conflicts at the C level with FreeBASIC's auto-generated `DllMain` entry point when compiling with `-dll` (`error 42: conflicting types for 'DllMain'`). This means the shipped `WellCOM.dll` (currently a 32-bit binary, itself a leftover gap) can't simply be recompiled for 64-bit with today's toolchain — the source itself needs a fix for how it defines the DLL entry point, which requires FreeBASIC-internals understanding to get right without silently breaking COM initialization behavior. Left as a known, documented issue rather than guessed at.

---

## 4. Session history (chronological)

### Infrastructure

- Fork initialized; Codeberg repo `bigriverguy/VFBEWin64` configured
- Initial commit: `bbfa399` — *Initial Win64 fork import*
- SSH to Codeberg verified (`Hi there, bigriverguy!`)

### Batch 2.75.2 fallout — startup freeze

**Symptom:** Splash stuck; invisible “ghost” Find region.

**Cause:** GTK strip + form autolaunch blocks. `frmSplash.frm` and 13 other `frm*.frm` files had module-level `Form.Show` + `App.Run`. During `Main.bas` includes, `frmFind` autolaunched and blocked startup.

**Fix:**

- Removed standalone `Form.Show` / `App.Run` from splash + 13 forms
- `VisualFBEditor.bas` defines `_NOT_AUTORUN_FORMS_` before includes

### UI fixes (post–2.75.2)

| Issue | Fix |
|-------|-----|
| Tab close button showed `Ã—` | `TabWindow.bas`: `Caption = WChr(&HD7)` (×), Segoe UI 8pt |
| Bottom panel UX regressions (pin, collapse, overlap, two-click minimize, startup focus) | `Main.bas`, `Main.bi`, `VisualFBEditor.bas` — state machine aligned with left/right panels |
| `BottomHeight=19` in INI broke layout | Clamp: `MIN_BOTTOM_PANEL_HEIGHT=80`, `DEFAULT=200`; INI corrected |

### Bottom panel — persistence vs layout (iterative)

Several fix cycles addressed bottom panel **save/restore** vs **collapse layout**:

1. **Wrong save key:** `BottomClosed` was derived from pin checkbox instead of layout (`TabPosition`) — fixed to match left/right.
2. **Added `BottomCollapsed` INI key** and `IsBottomCollapsed()`.
3. **`ShowBottom` / `CloseBottom` changed `TabPosition`** unlike left/right — refactored so only `SetBottomClosedStyle` changes `TabPosition`.
4. **State not retained on restart:** Focus changes during **exit** collapsed the panel before INI save; **startup** `ActivateMainWindow()` collapsed restored auto-hide panels.
   - `SaveMainWindowPanelLayout()` at **start** of `frmMain_Close`
   - Skip auto-collapse in `frmMain_ActiveControlChanged` when `FormClosing` or `bApplyingStartupLayout`
   - Re-expand bottom after `ActivateMainWindow` in `frmMain_Show` when INI says expanded
5. **Collapse did not reclaim editor space:** `CloseBottom` left `ptabBottom->Height` at expanded size; pin click used `SetBottomClosedStyle(True, False)` without `CloseBottom`
   - Reset both `pnlBottom` and `ptabBottom` heights on collapse
   - Pin click while expanded: `SetBottomClosedStyle(True, True)`
6. **First cold start collapsed — editor gap:** `CloseBottom` in `frmMain_Create` ran before the form was shown; dock layout kept full `pnlBottom` height until manual collapse
   - `frmMain_Show` re-applies `CloseBottom` once the main window is visible (and again after startup focus restore)

**Status: bottom panel code issues — FIXED** (persistence, collapse/reclaim, first-start layout). See §7 for remaining **manual test plan** items.

### Left/right panel Pin click not collapsing

Same root pattern as bottom panel item 5 above, found independently in each: Pin click while the panel was expanded called `SetLeftClosedStyle`/`SetRightClosedStyle(Value, WithClose:=False)`, relying on `frmMain_ActiveControlChanged`'s focus-loss detection to actually collapse — unreliable, especially when focus stayed inside a Form Designer. Fixed both to mirror the already-correct bottom-panel pattern: `WithClose:=True` when collapsing from an expanded state. Right panel: commit `c267284`. Left panel: commit `64daa66`.

### Form Designer never activating (root-caused during 2.75.3)

See §3a — this was actually a fallout of the Batch 2.75.2 GTK strip tool, not a new regression, but wasn't caught until this session. Fixed in commit `bef9267`.

### Critical fix: bundled Windows headers silently dropped Windows-8.1+ APIs for every user project (2026-07-03)

**Discovered when the owner tried to compile the `MDINotepad` example project and got 11 errors in `Controls/MyFbFramework/mff/Control.bas`** (`WM_POINTERDOWN`/`POINTER_INFO`/`GetPointerInfo`/`PT_MOUSE` all "not declared"). This turned out to be a serious, longstanding bug — not something introduced by tonight's session — that likely blocked **any** standard GUI project from compiling through the IDE, not just this one example.

**Root cause:** `src/Main.bi` defines `TARGET_COMPILE_DEFINE = "__USE_WINAPI__ -d _WIN32_WINNT=&h0A00"` (Windows 10), unconditionally appended to every user-project compile command (`TabWindow.bas:11378`). The bundled compiler's Windows headers (`Compiler/inc/win/*.bi`) gate all "Windows 8.1 and later" API declarations behind **exact-equality** version checks — `#if _WIN32_WINNT = &h0602` — instead of the correct minimum-version form (`#if _WIN32_WINNT >= &h0602`). Since the project explicitly targets Windows 10 (`&h0A00 ≠ &h0602`), every one of those blocks was silently excluded, even though Windows 10 is a strict superset of Windows 8.1 and should include all of it. `Control.bas` (the base class for every MyFbFramework control, pulled in by the default `Form.frm` template used by GUI/Windows Application projects) hits this via its pointer-input handling — meaning essentially any new GUI project with a form would fail the same way.

**Verified via the original download too:** the owner confirmed the same `MDINotepad` project also fails on the unmodified upstream project (different failure signature — fails earlier, before producing a detailed error list — consistent with the upstream toolchain not even being fully set up). This confirms the defect predates this fork and Tier 2.75 cleanup entirely.

**Scope confirmed systemic, not isolated:** grepped the whole `Compiler/inc/win/` tree — the same exact-equality anti-pattern (`_WIN32_WINNT = &h0602`) appears **116 times across 18 files** (`aclui.bi`, `authz.bi`, `combaseapi.bi`, `commctrl.bi`, `ncrypt.bi`, `ntddndis.bi`, `shellapi.bi`, `shldisp.bi`, `shlobj.bi`, `shobjidl.bi`, `userenv.bi`, `winbase.bi`, `wincrypt.bi`, `windot11.bi`, `wingdi.bi`, `winnls.bi`, `winnt.bi`, `winuser.bi`) — a single consistent spelling, no case/spacing variants. This is almost certainly a FreeBASIC header-porting bug: Microsoft's own SDK headers use "at least this version" semantics (`NTDDI_VERSION >= NTDDI_WIN8`), not exact equality.

**Safety verified before fixing:** confirmed (via cross-referencing every declared symbol name against the rest of each file, including `#elseif` chains) that no file has a competing higher-version guard (`>= &h0603`, `&h0A00`, etc.) for the same symbols — so widening `=` to `>=` cannot cause duplicate-definition conflicts anywhere. All 116 occurrences are either standalone `#if`/`#endif` blocks or the terminal branch of an `#elseif` chain with nothing after them.

**Fix:** mechanical find-and-replace, `_WIN32_WINNT = &h0602` → `_WIN32_WINNT >= &h0602`, across all 18 files. Purely additive — for the IDE's own self-build (which doesn't force `_WIN32_WINNT`, so `Control.bi`'s own `#ifndef` fallback sets it to exactly `&h0602`), behavior is unchanged; for user projects (`&h0A00`), the correct Windows-8.1+ API set now compiles.

**Verified:**
- IDE self-build (`Compile.bat`) still compiles clean, 0 errors/0 warnings, after the header fix.
- Direct reproduction: compiled `Examples/MDINotepad/MDIMain.frm` with the exact flags the IDE uses (`-d __USE_WINAPI__ -d _WIN32_WINNT=&h0A00`, etc.) — failed before the fix (matching the owner's screenshot), succeeds cleanly after, producing a working executable.

**Not yet done:** full regression pass compiling other example projects to confirm no other examples relied on the old (buggy) exclusion behavior. (The "does 1.10.3 already fix this" question is now moot — Tier 3's compiler swap was attempted and closed 2026-07-03, staying on 1.10.1; see §4's compiler-version-decision section.)

### Ad-hoc addition: stale bottom-panel content on project close (2026-07-03)

**Not part of any planned tier — arose from the owner noticing the Output/Problems tabs kept a closed project's content after opening a different project.** Investigated all 14 bottom-panel tabs (`src/Main.bas` ~line 8200) and found they split into two groups with different natural lifetimes:

- **Analysis tabs (6): Output, Problems, Suggestions, Find, ToDo, Change Log** — hold scan/compile results scoped to whichever project or file produced them (confirmed `Change Log` is explicitly keyed to the current tree node via `mChangelogName`). Stale content here is actively misleading once a different project is open.
- **Debug/profiler tabs (8): Locals, Globals, Procedures, Threads, Watches, Memory, Profiler, Immediate** — only ever have content during an active debug/profiling run, which can't exist without a project open.

**Fix:** two new Subs in `src/Main.bas` (next to the existing `ClearMessages()`):
- `ClearAnalysisPanels()` — clears the 6 analysis tabs, called from `CloseProject` (Main.bas).
- `ClearDebugPanels()` — clears the 8 debug/profiler tabs, called from the `Case "End"` debug-stop handler in `src/VisualFBEditor.bas` (so it fires when a debug session ends, not just on project close), and also from `CloseProject` as a backstop.

**Gotcha hit along the way, worth remembering for any future cross-file Sub call:** `Main.bi` `#include`s `Main.bas` near its own end (line ~316), and `VisualFBEditor.bas` pulls in `Main.bi` near its top (line 36) — before it reaches its own Sub definitions further down (e.g. `ClearThreadsWindow` at line 299). So a Sub defined in `VisualFBEditor.bas` is **not** visible to code in `Main.bas` without an explicit forward `Declare` in `Main.bi` (added one for `ClearThreadsWindow`, following the existing `ChangeEnabledDebug`-style pattern) — even though calling in the other direction (`VisualFBEditor.bas` calling a `Main.bas` Sub) works fine, since `Main.bas`'s content is textually inlined before `VisualFBEditor.bas` continues past line 36.

Compiled clean (0 errors/0 warnings) after the fix. Not yet manually smoke-tested in the running IDE.

### FreeBASIC compiler version decision (Tier 3 — attempted 2026-07-03, reversed: staying on 1.10.1)

Owner plans to replace the bundled `Compiler/` tree and eventually vendor the compiler's own source for future AI-assisted review. Compared 1.10.1 (currently bundled), 1.10.3, 1.10.4 (unreleased), and 1.20 (unreleased) — **originally decided on 1.10.3** from the `fbc-1.10` maintenance branch. 1.20 was ruled out for now: it removes null-termination from fixed-length strings (`STRING*N`/`WSTRING*N`), a breaking change that would need an audit of this codebase's fixed-string usage first. Owner specified a preferred binary source: community continuous builds at `users.freebasic-portal.de/stw/builds/` (maintainer "stw", trusted long-time contributor) over the "official" release, since stw's build is expected to be equal-or-better quality.

**Tier 3 was started 2026-07-03 and immediately hit a dead end: no viable 1.10.3 Windows binary exists anywhere, from any source.** What was found:
- **stw's portal build #875** (`fbc_win64_mingw_0875_2025-04-21.zip`) was the specific build the plan pointed at — its changelog entry cites the exact right commit (`8708d1a`, confirmed on GitHub to be the real `1.10.3` tag). But the downloaded binary itself reports `--version` as **1.20.0**, and its bundled `changelog.txt` confirms large 1.20-era features already present (the same breaking `STRING*N` change, a WIP Clang backend, Android support). Root cause: stw's `win64/` build series is one continuous numbered stream tracking **trunk**, not a separate frozen maintenance branch — the "1.10.3 Release" commit is just a changelog-update commit that appears in trunk's shared history at that point, not a marker that trunk itself was in a 1.10.3 state. Trunk had already moved well past it by build #875.
- **No official binary exists either.** Checked GitHub Releases (`freebasic/fbc/releases`) — only goes up to 1.10.1 with attached Windows assets, nothing for 1.10.2/1.10.3. Checked SourceForge (`sourceforge.net/projects/fbc/files/`) — same story, no 1.10.2 or 1.10.3 release folder exists at all. A web search turned up nothing beyond 1.10.1 on any mirror either.
- **Getting an actual 1.10.3 binary would require building FreeBASIC from source** at the `1.10.3` git tag — a real undertaking, since FreeBASIC is self-hosting (needs an existing `fbc` to bootstrap a new one) plus a full MinGW-w64/GCC toolchain, not a quick task.

**Decided (owner, 2026-07-03): stay on the currently-bundled 1.10.1 rather than build from source for one point-release's worth of bugfixes.** Tier 3's "replace the compiler" work is closed for now, not deferred to "later in this same form" — if a genuine prebuilt point-release binary ever surfaces, or if the source-build effort becomes worthwhile for other reasons (e.g. paired with the already-planned "vendor the compiler's own source" work), this can be revisited then.

**This unblocks something:** the gas64-vs-GDB debugging check (below) was explicitly sequenced to wait for Tier 3 to land first, since a compiler swap could have invalidated the result. With Tier 3 now closed (staying on 1.10.1), **that sequencing reason no longer applies — the gas64/GDB check can proceed directly against the current toolchain whenever it's picked up**, no need to wait.

### Debugger backend decision: GDB, not gas64/Integrated

VFBE already supports two debugger paths for **user projects** (not the IDE itself) as a per-project setting (`ToGAS`/`ToGCC` in `src/BuildService.bas`/`src/TabWindow.bas`): the "Integrated IDE Debugger" in `src/Debug.bas` (requires the user's project compiled with `-gen gas/gas64 -g`, reads FreeBASIC's native stabs debug format directly) versus the "Integrated GDB Debugger" (requires `-gen gcc` + gcc debug flags, standard GDB). These are matched pairs, not interchangeable — `Debug.bas` explicitly errors if the wrong backend/debug-format combination is used.

**Decided: GDB is the project's debugger.** Settled by what's actually bundled: `Debuggers/gdb-11.2.90.20220320-x86_64/` contains only `gdb.exe`/`gdbserver.exe` — there's no separate gas64-native debugger tool anywhere in this repo, so the practical toolchain already implies GDB. This also matched the research-backed recommendation from the same session (Tiko, a comparable FreeBASIC IDE, recently reversed its own default away from gas64 back to GCC for 64-bit builds).

**RESOLVED 2026-07-03: `gas64` is dead. `-gen gcc` is the only compile backend, for both Development and Final.** The empirical check flagged above as a hard precondition was run and came back conclusively negative — not "GDB can't read gas64's format," but **gas64 doesn't emit usable debug information at all**:
- Compiled a small test program with `-gen gas64 -g` and inspected every layer: the raw generated `.asm`, the assembled `.o`, and the final linked `.exe`.
- The `.asm` output contains exactly one debug-related directive — `.file "test.bas"` (just names the source file) — and **zero `.loc` directives anywhere** (the directives that map machine instructions to source line numbers; without them there is no line-level information for any debugger to use). No `.stabs` directives either, despite `Debug.bas`'s Integrated debugger expecting stabs format from this exact backend/flag combination.
- The final `.exe` does contain DWARF sections (`.debug_info`, `.debug_line`, etc.), but they belong entirely to the statically-linked C runtime startup code (`crt2.o`/`crtbegin.o`/`fbrt0.o`), not to the user's own compiled program — confirmed by checking `info sources` in GDB, which lists only mingw-w64/libgcc C runtime paths, never the user's `.bas` file.
- Confirmed with two different program structures (a bare top-level script and a `Sub`-based structure closer to how real VFBE projects are written) — identical result both times.
- Net effect: `break test.bas:3` fails with "No source file named test.bas," and no variable can be inspected, because there is nothing for *any* debugger (GDB or the Integrated stabs-parser) to read. This isn't a GDB integration gap fixable from VFBE's side — the compiler backend itself doesn't produce debuggable output in this FreeBASIC version.

**Decided: `gas64` is removed from consideration entirely, per the contingency already agreed on.** `-gen gcc` + GDB is the only compile/debug path going forward. This also resolves the tradeoff that motivated considering `gas64` in the first place (fast compiles for the edit/compile/run loop) — there's no way to get that benefit from `gas64` without giving up debuggability, so it's not a real tradeoff anymore, just a dead end.

**Consequence: the Integrated (stabs) Debugger in `Debug.bas` is now confirmed dead code, not just "a candidate for future pruning."** It exists specifically to pair with `-gen gas/gas64 -g` output, which has just been shown not to contain the stabs data that debugger expects. See the code-stripping section below.

**Already decided and unaffected by this: Clang/LLVM (owner discussion, 2026-07-03).** MinGW isn't actually a distinct option here — the bundled `gcc.exe` under `Compiler/bin/win64/` is already a MinGW-w64 build; that's what makes it produce native Windows PE executables at all. Clang/LLVM is more interesting but not worth pursuing: `TabWindow.bas`'s `CompileTo` project setting exposed **four** backend choices in Project Properties — `ToGAS`, `ToGCC`, `ToLLVM`, `ToCLANG` — but `Compiler/bin/win64/` only ships GCC/binutils; there's no bundled `clang.exe` or LLVM tooling at all, so selecting Clang or LLVM would just fail. Not worth bundling a second full toolchain for a speculative benefit when FreeBASIC's own GCC backend is far more battle-tested. **With `gas64` now also dead, `ToGCC` is the only surviving backend** — all three others (`ToGAS`, `ToLLVM`, `ToCLANG`) are removed in the code-stripping pass below, not just deprioritized.

### Concrete design: Development/Final compile-mode toggle (owner decision, 2026-07-03)

**Decision: fully opinionated, no exposed compiler flags of any kind.** Per the owner's stance: don't surface compiler internals to this audience at all — pick the best default for the ~99% of users who don't care, and let the ~1% who do go find a different tool. This collapses what's currently **six separate Project Properties controls** into **one two-state choice**:

- Compile tab today: `optCompileToGas` / `optCompileToGcc` / `optCompileToLLVM` (backend radios) plus `optOptimizationFastCode` / `optOptimizationLevel` / `optOptimizationSmallCode` (three more controls, meaningful only for GCC)
- Debugging tab today: `chkCreateDebugInfo` (separate checkbox, disconnected from the compile-backend choice even though they're really the same decision)

**FINALIZED 2026-07-03: `gas64` is confirmed dead (see the gas64/GDB finding above) — both modes now use `-gen gcc`.** The two-state choice survives, just with a narrower meaning than originally hoped:
- **Development:** `-gen gcc`, debug info on, no optimization (`-O0`, the compiler default) — matches how the IDE's own `Compile.bat` already builds itself. Fastest of the two, immediately debuggable. Default for day-to-day edit/compile/run.
- **Final:** `-gen gcc`, debug info off, one fixed optimization level chosen by the project itself, never the user (`-O2` is a reasonable, uncontroversial default for typical hobbyist-scale programs — no need to expose the `-Ofast`-vs-`-Os` tradeoff to anyone). Produces the smaller/faster executable to hand out.

**`ToGAS`/`ToLLVM`/`ToCLANG` are all fully removed** — `ToGCC` is the only surviving backend. See the code-stripping section below for what this means in `Debug.bas`, `TabWindow.bas`, `VisualFBEditor.bas`, and `frmProjectProperties.frm`.

**Related cleanup found and done while investigating this (2026-07-03): leftover 32-bit GCC internals removed.** `Compiler/bin/libexec/gcc/i686-w64-mingw32/9.3.0/` was a complete parallel 32-bit GCC toolchain (its own `cc1.exe`, `as.exe`, `ld.exe`, plus 9 dependency DLLs — 31 MB, 12 files) sitting next to the real 64-bit one (`bin/libexec/gcc/x86_64-w64-mingw32/9.3.0/`). The earlier 32-bit-removal commit (`15e66cc`) only caught the top-level `Compiler/bin/win32/` folder and missed this deeper one. Confirmed zero references anywhere in build scripts or source before deleting; verified `-gen gcc` (IDE self-build via `Compile.bat`) still compiles clean afterward.

**Alternative worth a future conversation, not decided:** rather than a persisted per-project setting the user has to remember to toggle, "Development vs Final" could instead be modeled as two different **actions** — e.g. the existing "Run" (implying the fast/debuggable path) versus a separate "Build Release"/"Publish" command (implying the optimized path) — with *no* settings UI at all, since the mode would be implied by which command is invoked rather than a stored radio state. That pushes "don't expose it" one step further than even two radio buttons. Flagged here because it's in the spirit of today's discussion, but the two-radio design above is the one actually decided; this is offered as a possible refinement for later, not a competing plan.

### Code-stripping pass: remove dead alternative-debugger/compiler-backend support (2026-07-03, complete)

With `gas64` confirmed dead and Clang/LLVM never bundled, all code and UI that existed only to support them has been physically removed (not hidden), per this project's established dead-code discipline (§3a). Executed in two compile-gated passes, per owner instruction:

**Pass 1 — the Integrated (stabs) debugger engine and its dispatch branches:**
- `Debug.bas`: removed the entire Integrated debugger engine (breakpoint injection via `WriteProcessMemory`, stabs-format debug-info parsing, the DWARF-parser cluster, duplicate `cutup_*` chain, `elf_extract`, `proc_newfast`, `brkv_test`) — 12,059 → 2,409 lines. `RunWithDebug` rewritten from a ~130-line function branching on custom-tool-path vs. GDB down to a ~40-line GDB-only function. The `DebuggerTypes` enum and `DefaultDebuggerType64`/`CurrentDebuggerType64` removed.
- `VisualFBEditor.bas`: collapsed all debug-dispatch `Case` branches (`Start`, `End`, `Restart`, `StepInto`, `StepOver`, `SetNextStatement`, `StepOut`, `RunToCursor`, `Breakpoint`, etc.) from `If CurrentDebugger = IntegratedGDBDebugger Then <GDB> Else <Integrated> End If` down to the GDB body only. Removed `"ShowVar"`/`"LocateProcedure"`/`"EnableDisable"`/`"VariableDump"`/`"PointedDataDump"`/`"MemoryDumpWatch"`/`"ShowStringWatch"`/`"ShowExpandVariableWatch"`/`"ShowString"`/`"ShowExpandVariable"` cases (Integrated-only, no GDB equivalent). `"AddWatch"` reimplemented on the existing GDB watch mechanism. `"Break"` (pause-while-running) left as a documented no-op — it was only ever wired for the Integrated debugger; GDB has no equivalent yet. This is a pre-existing gap, not a regression.
- `Main.bas`: removed `TimerProc` (only reachable from the deleted engine), a dead `shwtab`/`proc_sh` handler, emptied `tvPrc_NodeActivate`/`tvVar_Message` bodies (widgets kept for now, pending the UI sweep below).

**Pass 2 — the compile-backend choice and the debugger-choice/custom-external-debugger-tool feature:**
- `TabWindow.bi`/`TabWindow.bas`/`BuildService.bas`: `CompileToVariants` enum reduced to `ByDefault, ToGCC`; all `ToGAS`/`ToLLVM`/`ToCLANG` branches removed from compile-line construction.
- `frmProjectProperties.frm`/`.bi`: removed `optCompileToGas`/`optCompileToLLVM`/`optCompileToClang` radio buttons and their handlers; renamed the shared enable/disable handler to `UpdateOptimizationControlsEnabled`. Kept the optimization-level controls (independent setting, out of scope).
- Per owner decision ("Remove everything") the debugger-*choice* mechanism was removed together with the separate custom-external-debugger-tool feature it was entangled with, since neither has a reason to exist with GDB as the only debugger: `Main.bi`/`Main.bas` (`pDebuggers` Dictionary, `Debugger64Path`/`GDBDebugger64Path` settings; added `BUNDLED_GDB_PATH` constant so GDB's path is hardcoded like the bundled compiler), `SettingsService.bas` (removed the corresponding INI-loading blocks), `frmParameters.frm`/`.bi` (removed the `cboDebug64` debugger-choice combo; kept the unrelated `txtDebug64` extra-debug-arguments field), `frmOptions.frm`/`.bi` (removed the whole `grbDefaultDebuggers`/`grbDebuggerPaths` group — combos, `lvDebuggerPaths` ListView, Add/Remove/Change/Clear buttons and their handlers — 249 lines. Kept the rest of the "Debugger" options page: `chkLimitDebug`, `chkDisplayWarningsInDebug`, `chkTurnOnEnvironmentVariables`/`txtEnvironmentVariables`, which are general debug preferences unrelated to debugger choice).
- Two example `.vfp` files needed a `CompileTo=` ordinal migration since the enum shrank: `Examples/ChineseCalendar/ChineseCalendar.vfp` (old `ToGAS`=1 → `ByDefault`=0) and `Examples/gdipClock/gdipClock.vfp` (old `ToGCC`=3 → new `ToGCC`=1). Repo-wide grep confirmed no other `.vfp`/template needed migration.

**Result:** 14 source files changed, 146 insertions(+), 10,360 deletions(-) — `Debug.bas` alone accounts for -9,812 net lines. Verified via a final clean Release compile (0 errors/warnings) and a repo-wide grep confirming no removed identifier remains referenced anywhere in `.bas`/`.bi`/`.frm` files. Every intermediate compile error was resolved by tracing the exact error back to its definition/callers (never guessed) — stragglers the original mapping missed included `kill_process`, `re_ini`, `get_var_value`, `proc_loc`/`proc_enable`, `var_dump`/`string_sh`/`shwexp_new`, `check_bitness`, `reinit()`, all confirmed genuinely Integrated-only before removal, except `kill_process` which was restored with just its Integrated-only inner branch trimmed since `CloseSession` has a legitimate unconditional caller.

**Deferred (not part of this pass):** the child TreeView widgets `tvPrc`/`tvVar`/`tvThd`/`tvWch` in the Debug panel are now fully inert (their handlers were emptied, not removed, since the widgets themselves still exist) — folding them into the still-open **UI/settings sweep** noted under §13.2 is the natural next step, along with any other GTK/Linux/alt-compiler/alt-debugger remnants visible in the UI but not yet touched by this code-level pass.

**Post-merge regression found and fixed (2026-07-03):** this pass's `SettingsService.bas` edit removed the `"Debuggers"` section from `NoMoreIndexedSettingsKeys`'s multi-section key-existence check (8 sections remain) but left the function's termination condition at `Return keySum = -9` — a magic number that was never updated to match the new count (should be `-8`). Since `keySum` can now reach at most `-8`, the condition could never be true, and `LoadSettings`' `Do ... Loop Until NoMoreIndexedSettingsKeys(i)` (line ~225) never terminated — a genuine infinite loop, not a deadlock, burning 100% CPU on every startup. The commit compiled clean and passed the dead-identifier grep sweep, but nobody actually *launched* the app afterward, so this shipped to Codeberg undetected until the next session's dark-mode work prompted an actual smoke test. Found by binary-bisecting between this commit and the previous known-good commit (`e139c2c`), then narrowing file-by-file until the exact function was implicated. Fixed by correcting the constant to `-8`. **Lesson: a clean compile + grep sweep is necessary but not sufficient for large removals — launch the app at least once afterward, especially after touching loop-termination logic.**

---

## 5. Bottom panel — intended behavior (reference)

State model mirrors **left/right** panels:

| Concept | Left/Right | Bottom |
|---------|------------|--------|
| Pinned vs auto-hide | `TabPosition` (`tpTop` = pinned) | Same (`ptabBottom->TabPosition`) |
| Collapsed vs expanded | `SelectedTabIndex = -1`, splitter hidden | Same + `splBottom.Visible` |
| INI: pinned? | `LeftClosed` / `RightClosed` | `BottomClosed` |
| INI: collapsed? | `LeftCollapsed` / `RightCollapsed` | `BottomCollapsed` |
| INI: size | `LeftWidth` / `RightWidth` | `BottomHeight` (≥ 80) |

**INI semantics:**

| Key | `true` means | `false` means |
|-----|----------------|---------------|
| `BottomClosed` | Auto-hide (vertical tabs, `tpBottom`) | Pinned open (`tpTop`) |
| `BottomCollapsed` | Tab strip only (when auto-hide) | Content visible at `BottomHeight` |
| `BottomHeight` | Panel height when expanded | — |

**Key functions (`src/Main.bas`):**

- `GetBottomClosedStyle()` — `Not TabPosition = tpTop`
- `IsBottomCollapsed()` — `tpBottom And SelectedTabIndex = -1`
- `SetBottomClosedStyle(Value, WithClose)` — only place that changes `TabPosition`
- `CloseBottom()` / `ShowBottom()` — expand/collapse content only (no `TabPosition` change)
- `SaveMainWindowPanelLayout()` — early save on exit
- `UpdateBottomPinLayout()` — pin strip position (`BOTTOM_PIN_STRIP_WIDTH = 20`)

**Constants (`src/Main.bi`):** `DEFAULT_BOTTOM_PANEL_HEIGHT=200`, `MIN_BOTTOM_PANEL_HEIGHT=80`, `BOTTOM_PIN_STRIP_WIDTH=20`

---

## 6. Completed work checklist

- [x] Win64-only fork scope documented (`README.md`, `BUILD.md`)
- [x] `Compile.bat` / `CompileDebug.bat` two-step build (mff + IDE)
- [x] Batch 2.75.1 panel/layout cleanup
- [x] Batch 2.75.2 GTK preprocessor strip + compile fix
- [x] Startup freeze fix (autolaunch removal, `_NOT_AUTORUN_FORMS_`)
- [x] Tab close button glyph (×)
- [x] Bottom panel pin/collapse/expand behavior (multi-iteration) — **fixed**
- [x] Bottom panel INI persistence (save timing + startup restore) — **fixed**
- [x] Bottom panel collapse reclaims editor height — **fixed**
- [x] First-start collapsed layout reclaims editor space (`frmMain_Show` re-apply) — **fixed**
- [x] Codeberg remote + SSH
- [x] `ActivateMainWindow()` at end of `frmMain_Show` (editor foreground on startup)
- [x] Right panel Pin click not collapsing — **fixed** (`c267284`)
- [x] Left panel Pin click not collapsing — **fixed** (`64daa66`)
- [x] Form Designer never activating for any `.frm` file — **fixed**, root-caused to strip-tool `__EXPORT_PROCS__` blind spot (`bef9267`)
- [x] `Compiler/`, `Debuggers/` tracked in git (self-contained fork) (`b555406`)
- [x] 32-bit compiler binaries removed (`Compiler/bin/win32`) (`15e66cc`); missed leftover found and removed 2026-07-03 — `Compiler/bin/libexec/gcc/i686-w64-mingw32/9.3.0/` (31 MB, 12 files), verified both `-gen gcc` and `-gen gas64` still compile clean afterward
- [x] All compile warnings resolved, 0 warnings/0 errors (`53d8e47`, `56f6d18`)
- [x] Dark-mode implementation replaced with inert stub (interface preserved) (`56f6d18`)
- [x] Confirmed-dead subtrees deleted: `gir_headers/`, `WebView/`, `fbsound/`, `SoundPlayer.*` (`c494207`)
- [x] Batch 2.75.3 — physical dead-code deletion across `Debug.bas`, `Designer.bas`/`.bi`, `Main.bas`/`.bi`, `TabWindow.bas`, `VisualFBEditor.bas`, ~15 `mff/*.bas` files, `NativeFontControl.bas`/`.bi` deleted outright (`7baebd1`, `add4642`, `76abaa5`)
- [x] AI KnowledgeBase path bug fixed — `VisualFBEditor IDE Environment.md` was never loading due to a missing `\KnowledgeBase\` path segment in `Main.bas` (found via second-AI audit verification, §4)
- [x] Ad-hoc: bottom-panel analysis/debug tabs now clear on project close and debug-session-end instead of retaining stale cross-project content — see §4
- [x] Form Designer capability gap, part (a): per-form control tree in the project Explorer, with panel-aware icons and consistent single-click-open behavior — see §8
- [x] Bug fix: File > Close All left an empty project's tree entry behind — see §8
- [x] Form Designer capability gap, part (b): PagePanel layer/page navigation from the control tree, the Designer's right-click menu, and Ctrl+PageUp/PageDown; fixed a real right-click-never-selects bug and a load-time page-visibility bug along the way — see §8 (one known cosmetic gap deferred, §13.9)
- [x] Dark mode crash #3 root-caused (WM_THEMECHANGED ↔ SetWindowTheme infinite recursion → stack overflow, caught live under GDB) and fixed with a re-entrancy guard in `AllowDarkModeForWindow`; also fixed a latent crash-on-system-theme-change — see §4
- [x] Dark mode visual completion: horizontal (tpTop) tab-strip dark painting + real dark background fill in `TabControl` — dark mode now stable and enabled; popup menus deferred to §13.10 — see §4

---

## 7. Manual test plan — regression validation

> **Handoff note (Claude Code):** Bottom panel **implementation bugs are resolved**, and both left and right panel Pin-click bugs are also now fixed (§4, §6). Batch 2.75.3 (dead-code deletion) **has already happened** — the owner explicitly directed the team to proceed before this checklist was fully signed off, rather than treating it as a hard gate. This checklist is now a **regression-validation pass** covering both the original panel work and the since-completed dead-code deletion, not a pre-2.75.3 gate.

Run a full pass on **latest** `VisualFBEditor64.exe` after `Compile.bat`. Check each box when verified.

### Debugger smoke test (new — added post-2.75.3)

`src/Debug.bas` was the single largest and riskiest file touched in Batch 2.75.3 (core breakpoint/stabs-parsing/debugger-dispatch internals). Dead-code deletion there was verified by clean compilation only; a compile-clean build can still hide a runtime behavior change if a "dead" branch was misjudged.

- [~] Integrated IDE debugger (non-GDB path) — **deprioritized**, not tested. Given §4's "GDB is the project's debugger" decision, this path is a candidate for eventual removal rather than something worth validating further right now.
- [x] Step into — line highlighting advances correctly — **owner verified** via GDB path: 2-line loop body (`b = a * 2` / `Print a, b`) stepped 8→9→8→9 per iteration, exactly as expected.
- [x] Inspect a local variable while stopped — **owner verified** via GDB path: values displayed correctly during stepping.
- [x] Integrated GDB debugger path — breakpoint stop + Step Into + inspect all confirmed working — **owner verified**. This also resolved an earlier false "Can not be used for debugging 32bit exe..." error, which turned out to be the *Integrated* (non-GDB) debugger's `check_bitness()` check firing because the debugger type wasn't actually set to GDB yet — not a real 32-bit/64-bit mismatch. `check_bitness()` (`Debug.bas` ~line 9871) doesn't check whether the underlying `GetBinaryType` call actually succeeded, so it can misreport in other failure modes too — low priority given this path is being deprioritized, but worth knowing if it resurfaces.
- [x] ~~Restart-while-debugging and normal stop/exit — no hang or crash~~ — superseded by the two bugs found below; IDE itself never froze, stayed usable throughout.
- [ ] **Gas64 vs GCC backend check** (resolves the open §4 decision point) — still open, deferred along with the bugs below

**Two real bugs found during this testing — confirmed pre-existing (not introduced by any cleanup), deferred, not blocking:**

1. **Step Out sends the wrong GDB command.** `src/VisualFBEditor.bas`, `Case "StepOut"` (~line 705) calls `step_debug("n")` — `"n"` is GDB's *next* (step-over) command, not `"finish"` (proper step-out: run until the current function returns). So Step Out currently behaves identically to Step Over instead of leaving the current function. Confirmed via `git log -L` on this exact line range: present since `bbfa399` (initial fork import), never touched by any commit since — this is inherited from upstream, not something this fork's cleanup work caused.
2. **Command dispatch race condition between debug actions.** The mechanism that hands a command to the background GDB-communication thread (`NewCommand`, a single shared string set by `step_debug()`/`continue_debug()` and cleared by the reader loop in `Debug.bas`) is not a real queue. Firing multiple debug actions in quick succession (e.g. Step Over, then Step Out, then Step Into, then Continue) can silently overwrite an earlier pending command before the background thread ever reads it — some clicks do nothing not because anything hung, but because a later click clobbered them first. Also confirmed pre-existing via `git log -L` (`readpipe()`, `continue_debug()`, `set_bp()` all untouched since `bbfa399`; the one function touched by cleanup, `step_debug()`, only had a dead comment block removed — the live logic is byte-identical to before).

**Owner's call (2026-07-03, 8 AM Portland time):** defer both. Neither makes the IDE unusable — basic breakpoint + Step Into + variable inspection all work correctly at a normal (non-rapid-clicking) pace, which covers ordinary debugging use. **Revisit if:** future manual testing specifically needs reliable Step Over/Step Out, or needs firing debug actions in fast succession. Until then, the practical guidance for using the debugger is: click one debug action at a time and wait for it to visibly take effect before clicking the next, and treat Step Out as equivalent to Step Over for now.

### Startup

- [x] Cold start — no ghost Find dialog, splash closes, main window active — **owner verified**
- [x] Bottom panel opens in same state as last session (pinned / auto-hide collapsed / auto-hide expanded) — **owner verified**
- [x] Cold start with bottom **collapsed** — editor fills space immediately (no empty gap) — **owner verified**

### Bottom panel (regression on fixes)

- [x] Pin open → exit → restart — stays pinned (`BottomClosed=false` in INI) — **owner verified**
- [x] Auto-hide expanded → exit → restart — reopens expanded — **owner verified**
- [x] Collapse (pin or click-away) — editor fills freed space — **owner verified**
- [x] First start collapsed — editor fills space — **owner verified**
- [x] Pin size/position acceptable in collapsed and expanded modes — **owner verified**
- [x] Single-click collapse when expanded — **owner verified**
- [x] Resize height persists (≥ 80px) — **owner verified**

### Regression (Batch 2.75.2 + adjacent areas)

- [x] Left/right panels pin/collapse/restore — **owner verified**
- [x] Ctrl+F, Find In Files — **owner verified**
- [x] Compile/run, Output/Problems tabs — **owner verified**
- [x] Form design, property editing — **owner verified**
- [x] Toolbox insert, project explorer, AI Agent tab (if used) — **owner verified**
- [x] Session open/save, recent files/projects — **owner verified**

All items above passed **before** the owner separately found the critical `_WIN32_WINNT` compiler-header bug (see §4) while trying the `MDINotepad` example — that bug is a pre-existing defect in the bundled compiler's headers, unrelated to (and not caught by) this regression pass, since the regression checklist exercises the IDE's own UI/workflow rather than compiling every example project. Now fixed — see §4.

### Gate to Tier 3

**Regression validation is now complete**, aside from the still-open gas64-vs-GCC backend check above (§4/§8). Compiler-header robustness work (the `_WIN32_WINNT` fix, §4) happened in parallel/after this pass and doesn't need to be re-validated here — it's covered by its own verification in §4.

### Known deferred cleanup (not blocking unless touched)

> **Doc-hygiene note (audit flag, 2026-07-03, deferred):** this list overlaps with §8's "Low-priority cleanup" (both list `src/makefile` and `src/THREADING.md`). Worth consolidating into one canonical deferred-items list eventually — not urgent, noting so it doesn't silently drift out of sync.

- ~~Commented `#IfNDef __USE_GTK__` blocks in source~~ — **done**, see §3a
- ~~`mff/DarkMode/` directory~~ — **done** (replaced with inert stub, not removed — see §3a for why)
- ~~Stray dead-code comments from GTK era~~ — **done**, see §3a
- `src/makefile` still references GTK defines (not used by `Compile.bat`) — still open, low priority
- `src/THREADING.md` mentions GTK UI wrapping (historical) — still open, low priority
- **Debugger: Step Out sends wrong GDB command, and debug-action command dispatch has a race condition** — found during this session's debugger smoke test (see above), confirmed pre-existing/inherited from upstream, deferred per owner's call. Good candidate example for the §13.2 structured-programming/tech-debt pass when that's picked up.

### Optional / housekeeping

- `docompile.bat` — gitignored local helper at repo root (owner convenience)
- Consider `.gitignore` for `VisualFBEditor64.exe` if binary commits are undesired (currently committed like initial import)

---

## 8. Planned next steps

### Form Designer panel/layer navigation (part b) — shipped 2026-07-04, one known cosmetic gap left

**Owner's concern, raised 2026-07-03:** the `vbxGeneral` checkbox-overlap regression took multiple rounds of temporary runtime instrumentation to root-cause, because the framework's docking engine has timing-dependent passes hard to reason about statically. Owner's working theory: `frmOptions.frm` (~6,300 lines, 17 panels, deep nesting) was hand-coded directly because the Designer can't handle a form this large/complex, and its own navigation was hard to use.

**Characterized 2026-07-04:** owner pinned down two concrete gaps (confirmed by research, see below):
1. The Designer's project tree stops at the form/file level — no per-form list of child elements. Owner: "crucial in finding lost z-order elements" (directly why the checkbox-overlap bug took hours to diagnose).
2. No way to navigate between a form's internal pages/panels once viewing one — owner got stuck on `frmOptions`'s last panel ("AI Agent") with no path to any other.

Owner's conclusion: "Designer fine for simple 1 layer forms in visual mode, anything layered has to be hand coded" — and explicitly: **not interested in building a designer from scratch**, needed to know if the existing one can be salvaged.

**Researched 2026-07-04 — verdict: salvageable, additive scope, not a rewrite.**
- The project tree (`Main.bas:610-760`, `AddProject`) goes Project → category folders → files, four levels, and genuinely stops at the file node. Confirmed dead end.
- `cboClass` (`TabWindow.bas`, `Sub cboClass_Change` ~line 2811; population at `TabWindow.bas:9684-9754`) **already exists** and flatly lists every control on a form regardless of nesting depth, and can independently select any of them (`Des->SelectedControl = Ctrl`, `MoveDots`) — real, working VB/Delphi-style Object-selector infrastructure, just never surfaced as a discoverable tree.
- `PagePanel.bas` **already has a working panel-switch mechanism**: right-click a `PagePanel` in design mode → `UpDownControl_Changing` (`PagePanel.bas:277-291`) builds a "Show Panel" popup menu from `SelectedPanelIndex`, and picking one switches panels correctly. The owner independently found this spinner control and correctly guessed its purpose — "it just didn't work" — because it's disconnected from `cboClass`/tree selection: picking a control that lives on a currently-hidden panel doesn't flip that panel visible first (`BringToFront`, `Designer.bas:2082`, only does Z-order, never touches `SelectedPanelIndex`), so you silently select an invisible control.
- **The queryable data model the owner assumed didn't exist actually does** — `Designer.Objects`/`Components`/`Controls` (`Designer.bi:174-176`) plus `cboClass`'s already-populated flat list. It's presented as a flat, hidden combo instead of a tree, and panel-switching exists but is buried and disconnected.

**Scope for the actual fix:**
- **(a) Per-form control tree — done (2026-07-04).** Implemented in `Main.bas`: `tvExplorer` form nodes now lazily expand into a real, correctly-nested control tree (`AddControlTreeNode`/`ExpandFormControls`), walking the *live* container hierarchy (`Des->Controls.Contains`, `ControlCount`/`ControlByIndexFunc` — the same traversal `TabWindow.bas`'s dead `GetControls` already modeled, just never wired to anything) rather than reconstructing nesting from `cboClass` + `Parent` as originally planned — simpler and gets z-order-correct ordering for free. Selecting a control node calls into the same selection path `cboClass_Change` already used (`Des->SelectedControl`, `MoveDots`, `DesignerChangeSelection`). Single-click opens/selects any editable tree file (Forms, Includes, Modules, ...) consistently, matching how the rest of the tree already worked, while explicitly *not* single-click-triggering Shell-launches/external-tool handoffs/project-switching (those extension-based actions still require the existing double-click). Control-node icons reuse the Toolbox's own per-class icons (`EnsureControlIcon`, lazy-loaded from the owning control library DLL via the global `Comps` registry — the same source `imgListTools`/the Toolbox tree already pull from), so a `CheckBox` node looks like a checkbox, etc.
- **(b) Panel/layer navigation — shipped 2026-07-04.** The "layered canvas control" turned out to be `frmOptions.frm`'s own `pplGeneral`, a real `PagePanel` (confirmed via `frmOptions.bi:200`) used as a 17-page settings dialog — its pages are declared `As ScrollControl`, not `Panel`, which doesn't change any of the fixes below (traversal is by generic `ClassName`/`ControlByIndexFunc`, not type-specific) but is worth remembering if it ever looks like a type mismatch. Landed:
  - **Selection reveals the right page**: `RevealAncestorPanels` (`TabWindow.bas`) walks a selected control's ancestors for a `PagePanel` and flips it to the right child via `WriteProperty("SelectedPanel", ...)`; wired into both the new control-tree selection and the older `cboClass_Change`.
  - **In-canvas navigation, not just the tree**: `Designer.MovePanelLayer` (`Designer.bas`) cycles to the previous/next page (wraps at both ends) — bound to Ctrl+PageUp/PageDown (`Designer.KeyDown`) and to new "Previous Layer"/"Next Layer" items in the Designer's right-click menu, alongside a dynamic "Show Panel" submenu (`Designer.ChangeFirstMenuItem`) listing every page on the nearest `PagePanel` ancestor by name.
  - **Real bug found and fixed along the way**: right-click never selected the control it landed on (only left-click did, in `Designer.HookChildProc`'s `WM_LBUTTONDOWN` — `WM_RBUTTONUP` had no equivalent), so the new menu items were silently acting on stale selection state. Fixed by selecting under the cursor on right-click too.
  - **Load-time bug found and fixed**: `PagePanel.Add`'s "jump to the newest child" (correct for an interactive Toolbox drag) was firing once per pre-existing page every time the Designer reconstructs an existing multi-page form from source, silently overriding the form's own `SelectedPanelIndex = 0` init. Fixed with a `Loading` flag threaded from `Designer` → each control's `Loading` property (mirroring the existing `DesignMode` plumbing, since `PagePanel.bas` compiles into the separate `mff64.dll` and can't see IDE-only types directly) → `PagePanel.Add`, reset once the load finishes; plus a final "settle" re-application of `SelectedPanelIndex` after all of a `PagePanel`'s pages exist, since the form's own init statement necessarily runs before any of its pages are parented.
  - **Known cosmetic gap, deferred as "nice to have, not critical," end-of-project**: even with all of the above, `frmOptions.frm` still opens showing a *blank* page area until a control inside a page is actually selected (owner: "the layer doesn't show until the layer is in edit"). Diagnosed as a real, more specific case of the same bug class the fix above addresses — a page hidden throughout Designer reconstruction never gets a layout pass, so becoming `Visible=True` alone doesn't retroactively fix stale/never-computed child positions. Added `Controls[i]->RequestAlign` to `PagePanel.SelectedPanelIndex`'s real setter (`PagePanel.bas`) right where a page becomes visible, which should be the architecturally-correct fix — confirmed not sufficient in testing, root cause of *why* not is still open. Owner explicitly deprioritized further chasing this for now; all of the actual navigation (tree, menu, keyboard) works correctly once *any* selection has happened, so this is purely about the very first, cold-open frame.

**Recurring pattern worth remembering:** "sound design, unfinished last-mile integration" has now shown up repeatedly across this project (docking engine, `PagePanel` panel-switching *and* right-click selection *and* page-layout-on-show, several instances in one investigation alone). Owner's framing: "There is a lot to like about it, just that last 10% that takes 70% of the time and effort never got done." Treat this as a signature of this codebase generally, not a one-off — foundational pieces tend to be genuinely well thought out; look for missing integration/polish before assuming something needs to be rebuilt from scratch.

### Bug fix: File > Close / Close All left the project tree behind (found + fixed 2026-07-04)

Owner reported: after File > Close or File > Close All, everything else reset (tabs, Properties/Events panels, window caption) but the just-closed project's entry stayed in the project tree. Root cause: `TabWindow.CloseTab` (`TabWindow.bas:1057`) and `CloseAllTabs` (`Main.bas`) only ever close/remove *file* tab nodes — `CloseTab` has an explicit `tn->ImageKey <> "Project"` guard so a single file close never nukes the whole project node, which is correct, but nothing downstream of `CloseAllTabs` ever picked up the slack for "every tab in this project is now closed, so the project entry should go too." Only `CloseProject` (`Main.bas:2193-2294`, reached via File > Close Project / Explorer context menu / `CloseSession`) actually removes a project's tree node — `CloseSession` already does the right two-phase thing (close every tab, *then* sweep `tvExplorer.Nodes` calling `CloseProject` on each project node), but `CloseAllTabs` never got the second phase added.

**Fix:** `CloseAllTabs` (`Main.bas`) now does the same sweep after closing tabs, via a new `ProjectHasOpenTabs` helper (checks `tb->ptn` — a `TabWindow` field set once at construction via `GetParentNode`, already used the same way by `CloseProject`/`CloseSession`) that gates the sweep so a project is only auto-closed once *nothing* is left open under it — this correctly skips projects kept open via `WithoutCurrent`, or where the user hit Cancel on a per-tab unsaved-changes prompt, rather than force-closing over a deliberate Cancel. File > Close (single tab) deliberately still leaves the project tree alone otherwise — standard IDE convention (Visual Studio/VS Code don't remove a project from Explorer just because you closed one of its files) — only Close All now also closes empty projects.

### Immediate

1. ~~**Regression validation** — complete §7 manual test plan~~ — **done** (2026-07-03), all items passed except the still-open gas64-vs-GCC backend check (§4)
2. **Low-priority cleanup** (optional, not blocking): `src/makefile` GTK defines, `src/THREADING.md` GTK mentions
3. ~~**Examples/ GTK/Linux/Win32-only audit**~~ — **done** (2026-07-03). Result: **none of the 33 example folders needed removal** — the premise didn't hold. See §3b for full findings and follow-up work done/flagged as a result.

### Tier 3 — compiler toolchain (attempted 2026-07-03, closed for now — see §4)

4. ~~**Verify a compiled `fbc64` is available for 1.10.3**~~ — **done** (2026-07-03): no viable 1.10.3 Windows binary exists anywhere (stw's portal build #875 is mislabeled — it's actually trunk/1.20, not a frozen 1.10.3 build; no official binary exists on GitHub Releases or SourceForge either). Full writeup in §4.
5. ~~**Replace `Compiler/` tree** with the 1.10.3 build~~ — **not happening** (2026-07-03): staying on the currently-bundled 1.10.1 rather than building FreeBASIC from source for one point-release's worth of fixes. Removed cleanly from the immediate plan, not silently dropped — see §4 for the reasoning and what would need to be true to revisit it.
6. **Longer term:** vendor the FreeBASIC compiler's own source into the repo tree, in preparation for future AI-assisted review/modification of the compiler itself (owner-flagged as upcoming, no timeline yet). If this happens, it's the natural point to reconsider building a newer FreeBASIC version from source too, rather than doing that build effort as a one-off just for a point release.

### Longer term / unscheduled

7. Upstream sync strategy (if any) — this fork intentionally diverges (Win64-only); merge upstream only with an explicit plan
8. Wiki/docs for fork-specific behavior
9. Basic CI (e.g. run `Compile.bat` on push) — flagged by a second-AI audit (2026-07-03, deferred) as worth adding once the project outgrows one-person manual verification; not urgent today since compile-clean-before-commit is already enforced by convention (§9).

---

## 9. Rules & skills (Cursor / agent workflow)

These live under `.cursor/` and should be followed for any UI, startup, or settings work.

### Always-applied rule

**File:** `.cursor/rules/contextual-change-validation.mdc`

Before handoff:

1. **Map the change surface** — all features, panels, INI consumers, init paths in the touched area
2. **Init / first-run audit** — cold start, missing INI keys, order of `LoadSettings` vs layout
3. **Compile** — `Compile.bat`, **0 errors**
4. **User test checklist** — whole area, not one control

**Do not:** hand off after testing only the changed line; skip init checks when touching `LoadSettings`, `frmMain_Create`/`Show`, `LoadToolBox`, or panel handlers; ask user to manual-test before compile + checklist are ready.

**Escalation:** If unresolved after **4 fix cycles** → Opus fix-review loop: compile → independent review → fix critical/high/medium → repeat (max 5 iterations). User manual test **only after** review sign-off.

### Skill (detailed workflow)

**File:** `.cursor/skills/contextual-change-validation/SKILL.md`

Includes:

- Change-surface tables (left/right/bottom panels, toolbox, startup)
- Minimal-INI test scenarios
- Checklist templates
- Opus/Bugbot review scope
- **Excluded scope:** obsolete dark mode / GTK → dead-code cleanup, not actionable bugs

### User / agent conventions (from session)

- **Minimize scope** — smallest correct diff; match existing code style
- **No commits** unless user explicitly asks
- **Every session ends with a compile-clean commit + push to Codeberg** (added 2026-07-03; compile-clean gate added 2026-07-03 after a second-AI audit flagged the risk of pushing broken intermediate state) — run `Compile.bat` and confirm **0 errors** first. Only if the compile is clean should you commit any outstanding working-tree changes (status doc updates, INI/scratch state, etc.) with a sensible message, then `git push origin main`, as the last action before signing off for the day. If the compile fails and can't be fixed in-session, say so and hold off on the commit/push rather than pushing broken code. This is a standing instruction, not a one-time request — don't wait to be asked again in future sessions.
- **INI key migration** (added 2026-07-03, second-AI audit) — new keys must ship with a default (never assume an existing user's INI has it); never rename or repurpose an existing key without a migration read of the old key name first, so existing users' settings aren't silently orphaned. Relevant now that §13.4's rename will touch `Settings/VisualFBEditor64.ini`, but applies to any INI key work.
- **WinAPI only** — do not reintroduce GTK/Linux IDE paths
- Close running IDE before rebuild
- `set NOPAUSE=1` for agent compile runs
- Prefer `Compile.bat` over ad-hoc `fbc64` unless debugging

---

## 10. Key files map

| Area | Files |
|------|--------|
| Entry point | `src/VisualFBEditor.bas` (`_NOT_AUTORUN_FORMS_`) |
| Main UI & panels | `src/Main.bas`, `src/Main.bi` |
| Toolbar / commands | `src/VisualFBEditor.bas` (`PinBottom`, etc.) |
| Settings load/save | `src/SettingsService.bas`, `Settings/VisualFBEditor64.ini` |
| Tab editor chrome | `src/TabWindow.bas` |
| Splash | `src/frmSplash.frm` |
| Framework | `Controls/MyFbFramework/mff/` → `mff64.dll` |
| Build | `Compile.bat`, `CompileDebug.bat` |
| GTK strip | `Tools/strip_gtk_preprocessor.ps1` |
| Build docs | `src/BUILD.md`, `README.md` |

**Panel init order (`frmMain_Create`):**

1. Read widths/heights from INI  
2. `bApplyingStartupLayout = True`  
3. `SetLeftClosedStyle` / `SetRightClosedStyle` / `SetBottomClosedStyle`  
4. `ShowBottom` if auto-hide but not collapsed  
5. `bApplyingStartupLayout = False`  

**Panel show (`frmMain_Show`):**

1. Maximize if saved  
2. `UpdateBottomPinLayout`; if `Not splBottom.Visible` → `CloseBottom` (fixes first-start dock)  
3. After `ActivateMainWindow`: re-expand auto-hide if INI says so; `CloseBottom` again if collapsed  

---

## 11. Handoff notes for Claude Code

**Primary handoff artifact:** this file (`PROJECT_STATUS.md`) + **§7 manual test plan**.

1. **Read this file first**, then `src/BUILD.md` and `.cursor/skills/contextual-change-validation/SKILL.md` before panel/settings changes.

2. **Bottom/left/right panel implementations are all complete** — do not reopen unless §7 regression tests fail. If they fail, the three panels share one state-machine pattern (`Set*ClosedStyle(Value, WithClose)`), so compare all three against each other in `src/Main.bas`/`src/VisualFBEditor.bas` before patching.

3. **Batch 2.75.3 (dead-code deletion) is complete** — see §3a for full detail. Don't re-run a bulk GTK strip; the remaining single marker in `TabWindow.bas` is intentional (user-code preprocessor evaluator, not build config).

4. **Owner action:** finish every unchecked item in **§7** (now framed as regression validation, not a pre-2.75.3 gate) before starting Tier 3 compiler-swap work.

5. **Avoid fix cycles** — map full surface, compile, checklist; if stuck after 4 iterations, stop and document root cause instead of tweaking one line.

6. **Build-log verification gotcha:** `Compile.bat`'s piped output is UTF-16 encoded. Raw `grep`/Bash text search against it silently reports zero matches even when warnings/errors are present. Always verify via the `Read` tool, never raw grep, against these logs.

7. **Upstream** is Xusinboy's VisualFBEditor; this fork intentionally diverges (Win64-only). Merge upstream only with explicit plan.

8. **Examples/** and **Tools/** are largely untouched by Tier 2.75; don't strip GTK from user examples unless that's a separate decision.

9. **Local convenience:** `docompile.bat` at repo root is gitignored (owner's personal compile shortcut).

10. **Tier 3 (compiler swap) attempted and closed 2026-07-03** — see §4/§8. No viable 1.10.3 Windows binary exists anywhere; staying on the currently-bundled 1.10.1. Don't re-attempt fetching a prebuilt 1.10.3 binary without new information (a genuine point-release build surfacing somewhere) — this was checked thoroughly (stw's portal, GitHub Releases, SourceForge, general web search) before concluding.

---

**Panel save (`frmMain_Close`):**

1. `SaveMainWindowPanelLayout()` — **first**, before `CloseSession`  
2. … session close, other INI keys …

---

## 12. Commit log (this fork)

| Commit | Description |
|--------|-------------|
| `bbfa399` | Initial Win64 fork import |
| `e212819` | Bottom panel persistence/collapse; startup guards; `SaveMainWindowPanelLayout`; `PROJECT_STATUS.md` |
| `e63f1a6` | Status doc commit-hash update |
| `ef3b43e` | First-start collapsed layout; gitignore `docompile.bat`; handoff/test-plan update |
| `2511d86` | Record commit hash for `ef3b43e`; save bottom panel INI state |
| `5a09739` | Update INI window/panel state; rebuild `VisualFBEditor64.exe` |
| `c267284` | Fix right panel not collapsing on Pin click |
| `7c1a055` | Save session state after verifying right panel collapse fix |
| `af5b4be` | Update designer-regenerated `Temp.bas` scratch files |
| `bef9267` | Fix Form Designer never activating: strip tool silently deleted exported component dispatchers |
| `b555406` | Track the bundled FBC compiler and GDB debugger toolchains in-repo |
| `64daa66` | Fix left panel not collapsing on Pin click |
| `15e66cc` | Remove 32-bit compiler binaries (`Compiler/bin/win32`) — out of scope |
| `ac29ec8` | Update designer-regenerated `Temp.bas` scratch files |
| `53d8e47` | Fix all compile warnings (first pass — see `56f6d18` for correction) |
| `56f6d18` | Remove risky dark-mode implementation (replaced with inert stub); finish fixing mixed-boolean warnings |
| `c494207` | Delete confirmed-dead code: `gir_headers/`, `WebView/`, `fbsound/`, `SoundPlayer.*` |
| `7baebd1` | Physically delete dead GTK/32-bit/Linux code and legacy comment cruft in `Debug.bas` |
| `add4642` | Physically delete dead GTK/32-bit/Linux code in `Designer`/`Main`/`TabWindow`/`VisualFBEditor.bas` |
| `76abaa5` | Physically delete remaining dead GTK/32-bit code across `MyFbFramework` and `src` headers |

---

## 13. Future enhancements (owner-added, unscheduled)

These are **enhancements, not bugs** — added by the owner after Tier 3 was scoped. No committed order yet; see the owner's own numbering below. None of this work has started.

**Read §13.4's context note before scoping any of this section.** This is a hobby project with no timeline pressure, and the underlying goal across all of §13 — not just the rename — is to avoid the original upstream project's failure mode (too much scope, too little central attention, eventual collapse to one maintainer). Favor depth and coherence over speed or breadth when picking this up.

### 13.1 Evaluate a later GCC version

FreeBASIC's Win64 backend compiles through a bundled `gcc`/`binutils` (`as`, `ld`, `dlltool`, `GoRC`) under `Compiler/bin/win64/`, not just `fbc64.exe` itself. Tier 3 (compiler swap) was attempted and closed 2026-07-03 — no viable 1.10.3 binary exists, staying on 1.10.1 (see §4/§8) — so this is now independent of any near-term compiler swap, not something to bundle with it:
- Any independent GCC upgrade would be evaluated against the current 1.10.1-paired GCC/binutils version, not a future 1.10.3 pairing that isn't happening.
- A newer GCC needs a matching MinGW-w64 runtime/headers set; swapping GCC alone without the matching toolchain risks subtle ABI or linker-flag mismatches (`Compile.bat`'s `ld` invocation has a long hand-tuned flag list — see the build log in §3a's verification note).
- Decide: adopt whatever GCC ships with the chosen fbc build, or independently source a newer one and re-verify the full flag set still links cleanly.
- **Cross-dependency note (audit flag, 2026-07-03):** §4 has an open gas64-vs-GDB compatibility question tested empirically against the *current* `Compiler/bin/win64/` toolchain. If this swap changes that toolchain, re-verify §4's decision rather than assuming it still holds.

### 13.2 Structured programming, consistency, and legacy-tech-debt removal

**Owner's stated goal:** this codebase carries the accumulated effect of many independent programmers working on it over many years with minimal communication between them. The point of this pass isn't cosmetic formatting — it's to impose one consistent set of conventions and structure over code that currently has as many styles as it had contributors, so the system becomes legible and maintainable going forward rather than an archaeology exercise every time someone touches it.

Concrete goals, in the owner's words plus scope notes:
- **Structured programming** — reduce/eliminate spaghetti control flow inherited from the codebase's age (deeply nested conditionals, non-local control flow, functions doing too many unrelated things). `src/Debug.bas` (§3a) is the most extreme example already encountered — a ~12,500-line file mixing multiple debugger-backend eras in one module.
- **Variable consistency** — one naming convention applied uniformly (this codebase currently mixes Hungarian-ish prefixes in some modules with plain names in others, and inconsistent `Private`/scope conventions).
- **Standard indenting** — one whitespace style repo-wide (currently mixed tabs/spaces even within single files).
- **Move repeating code into classes/procedures** — DRY pass; likely the highest-value structural work here, since duplicated logic (already seen in miniature during Tier 2.75.3 — e.g. the duplicate `udt(0)`–`udt(16)` block found dead in `Debug.bas`) is exactly what independent, uncoordinated contributors tend to produce instead of factoring shared code.
- **Remove legacy tech debt** broadly, not just GTK/32-bit remnants already handled in Tier 2.75.3.
- **Audit for magic numbers** — unnamed numeric literals standing in for a count/size/flag that has to stay in sync with something else by hand. `SettingsService.bas`'s `NoMoreIndexedSettingsKeys` (see the 2026-07-03 regression writeup above in §4) is the concrete example: `Return keySum = -9` encoded "9 sections checked" as a bare literal with nothing tying it to the 8 (now-9, formerly-9) `KeyExists` lines above it, so removing one line silently broke the count and caused an infinite loop that a clean compile couldn't catch. Prefer deriving the comparison from the actual number of checks (e.g. counting the lines, or an explicit named constant) wherever this pattern repeats.

Execution notes:
- There's no established "prettier"-equivalent formatter for FreeBASIC. Whitespace/indentation normalization is safely scriptable in bulk; naming, structure, and DRY refactors are not — those risk breaking `Alias`/`Export` bindings (as already seen with the `ToolBar.bas` compiler quirk in §3a) and need file-by-file compile verification, same discipline as the dead-code deletion pass.
- This is real restructuring work, not a mechanical pass — expect it to be the largest single effort in the project, larger than Tier 2.75 was. Owner has explicitly said timeline is not a constraint here (see §13.4) — no need to compress this into a quick pass.
- ~~Should happen **after** the Tier 3 compiler swap~~ — moot: Tier 3 was attempted and closed 2026-07-03 (no viable 1.10.3 binary exists, staying on 1.10.1 — see §4), so there's no pending compiler swap to wait for anymore.
- Natural pairing with §13.4 (rename): if the project is getting a fresh identity specifically to mark a disciplined restart, this is the pass that actually earns that fresh identity.
- **Concrete target added 2026-07-03, tied to the §1 "no unnecessary options" principle:** collapse the Project Properties compile/debug settings (`optCompileToGas`/`optCompileToGcc`/`optCompileToLLVM`, `optOptimizationFastCode`/`optOptimizationLevel`/`optOptimizationSmallCode`, `chkCreateDebugInfo` — six controls across two tabs today) into a single opinionated "Development"/"Final" two-state choice, with no exposed compiler flags at all. Full design and final resolution (gas64 confirmed dead, both modes use `gcc`) written up under §4's gas64/GDB discussion ("Concrete design: Development/Final compile-mode toggle").
- **UI/settings cleanup note added 2026-07-03 (owner):** beyond the code-level removal already in progress (§4's "Code-stripping pass"), do a pass specifically over **user-facing settings and UI elements** — not just source code branches — for leftover support of: **GTK**, **Linux**, **alternative compiler backends** (`gas64`, Clang, LLVM), and **alternative debuggers** (the Integrated stabs debugger). The code-level dead-code removal (§3a, and the in-progress pass in §4) should naturally take most of this UI surface with it as the underlying branches are deleted, but call it out explicitly so nothing lingers unnoticed — e.g. a stray Options/Settings checkbox, a leftover GTK theme control, a Linux-specific path field, or a Project Properties control whose underlying code got deleted but whose UI declaration didn't. Worth a dedicated visual sweep of `frmOptions.frm`/`frmProjectProperties.frm` (and any other settings dialogs) once the code-stripping pass lands, checking for orphaned controls left behind.

### 13.3 UI evaluation and modernization

Owner asked whether this review needs a different AI trained specifically on front-end/UX practices, or whether it can be done here.

**Answer:** This can be done in this same environment. The relevant knowledge — Windows desktop UX conventions (Fluent Design / WinUI spacing, typography, and interaction patterns; conventions from comparable dev tools like VS Code and Visual Studio, since VFBE is a code editor, not a general consumer app), accessibility basics (contrast ratios, keyboard navigation, focus indicators), and layout/information-hierarchy heuristics — isn't a separate specialized model; it's general knowledge any capable model has, not something that requires a different AI trained on it. The Claude Code preview tooling can drive the actual built app, take screenshots, and inspect computed styles directly, which is what a review needs. There isn't a categorically "better-suited" different AI for this — the limiting factor is doing the review carefully (screenshot-driven, one panel/dialog at a time) rather than which model does it.
What **would** add value beyond any AI review: a human with fresh eyes and no context on the app's history, and/or usability testing with an actual end-user developer completing a real task — those catch friction an AI reviewer working from screenshots tends to miss.
Recommended approach when this is scheduled: run the built IDE, screenshot each major surface (main window, Designer, dialogs, Toolbox, Find/Replace, Settings), evaluate against Fluent/WinUI conventions and basic accessibility, and produce a scoped list of concrete changes rather than a vague "modernize" pass.

**Design against the target audience (§1), not against power users:** the primary audiences (returning Basic programmers, desktop-focused hobbyists, students) value approachability and a cohesive single tool over configurability or professional-IDE feature depth. UI evaluation should weight "is this discoverable and non-intimidating to someone who hasn't touched an IDE in 20 years, or ever" above "does this match what VS Code/Visual Studio power users expect." Avoid recommending changes that add configuration surface or professional-IDE conventions (command palettes, complex multi-pane customization) purely because they're modern — that cuts against the actual audience.

### 13.4 Rename the project (e.g. "ABStudio" — Astoria Basic Studio)

**Owner's context (important — shapes how all of Tier 4 should be approached):** this is a hobby project, and the owner is explicitly willing to spend months building an elegant system from the source-code level up — timeline is not a constraint. The owner's diagnosis of what went wrong with the original upstream project: it tried to do too much, with too little central guidance or attention to detail, and eventually its contributor base collapsed to a single person doing peripheral maintenance because the system had become too difficult to manage as a whole.

That history is the actual reason the rename matters, beyond a cosmetic label: it's meant to mark a deliberate, disciplined fresh start distinct from that trajectory — one with central direction and attention to detail, paired with the structural cleanup in §13.2. Given that framing, this fork should explicitly avoid repeating the original failure mode: **resist scope creep, keep changes centrally reviewed, and prioritize depth/coherence in one area over breadth across many.** Worth keeping in mind for how all of §13 (not just the rename) gets sequenced and scoped as it's picked up.

Flagging the rename itself as a **larger mechanical undertaking than it looks**, not a reason to avoid it — a rename this deep should be a dedicated pass with its own compile-and-test cycle, not folded into other work. Known touch points:
- Output binaries: `VisualFBEditor64.exe`, `mff64.dll` — filenames referenced throughout `Compile.bat`, `.gitignore`, this doc, `README.md`, `BUILD.md`
- Window class names / mutex or single-instance-detection strings (if any) in `src/VisualFBEditor.bas` / `Main.bas` — renaming these changes on-disk identity, not just cosmetics
- Splash screen, About dialog, title bar text, `App.Title` (`src/Main.bas` per §3a warnings-fix notes)
- INI file name/path (`Settings/VisualFBEditor64.ini`) — needs a migration story if existing users' settings shouldn't be silently orphaned; see the INI key migration convention in §9
- Repository name on Codeberg (`VFBEWin64`) — a rename here changes clone URLs for anyone already tracking it
- Every doc file (`README.md`, `PROJECT_STATUS.md`, `src/BUILD.md`, `src/THREADING.md`) and likely dozens of in-code comments/strings referencing "VisualFBEditor" or "VFBE"
- Decide scope up front: cosmetic rename only (title/About/docs) vs. full identity rename (binaries, repo, INI, window classes) — the second is much larger and should be scheduled as its own tier.

### 13.5 Standard Windows installer for end-user developers

Distinct audience from the current git-clone-and-compile workflow: an end-user developer who wants to *write FreeBASIC programs in the IDE*, not modify the IDE's own source — this is the audience described in §1 (returning Basic programmers, desktop-focused hobbyists, students). Implies a second distribution artifact alongside the source repo, not a replacement for it:
- Real installer/uninstaller (Inno Setup or WiX are the standard choices for a WinAPI-native app like this; both produce a proper uninstall entry in Windows Settings)
- Pre-built binaries only — `VisualFBEditor64.exe`, `mff64.dll`, the bundled `fbc64` compiler and GDB debugger — no IDE source tree
- Examples centralized and included (currently under `Examples/` per the key-files map, §10) — bundle as part of the installer, not a separate download
- Source, if offered at all to this audience, as a single centralized zip rather than the live dev tree (keeps the installer surface small and avoids exposing `Compiler/`/`Debuggers/` internals meant for the fork's own maintainers)
- Needs a decision on installer scope before starting: does this ship the bundled compiler (making it a fully standalone IDE+compiler), or does it assume the end user already has FreeBASIC installed? Given this fork bundles its own `Compiler/` tree already (§3a), standalone is the more consistent choice.
- Depends on Tier 3 (compiler swap) being done first, so the installer ships the final intended compiler version rather than needing a re-package immediately after.

### 13.6 Full review and expansion of Examples/ (added 2026-07-03)

**Sequencing:** owner-specified — do this in a **testing/fine-tuning or documentation phase**, after the core work (Tier 3 compiler swap, §13.2 structural pass) is done, not now. Noted here so it isn't forgotten, not to be picked up immediately.

**Why this is on the list:** the 2026-07-03 GTK/Linux/Win32-only audit (§3b) went through all 33 `Examples/` folders and found the premise (remove GTK/Linux/Win32-only examples) didn't hold, but surfaced real gaps along the way: several examples had no `.vfp` project file at all, two had genuine API-drift bugs from being written against an older `mff` version (one fixed — `Graphics/CanvasDraw.bas`, §3b — one still open — `WellCOM Example/WellCOM.bas`'s `DllMain` conflict), and this was only found because someone happened to try compiling them. That's a sign `Examples/` hasn't had a systematic pass in a while.

**Scope for that future pass:**
- Re-verify every example still compiles clean against the *then-current* `mff` API (will have moved again after §13.2's structural pass) — same direct-`fbc64`-compile verification technique used in §3b/§4, not just visual inspection.
- Finish the `WellCOM Example` `DllMain` fix left open in §3b.
- Consider whether new examples are worth adding — the target audience (§1) benefits from seeing approachable, appealing demos (graphics/drawing examples in particular resonate with returning Basic programmers per the discussion that led to this item); a documentation/polish phase is a natural time to ask "what's missing" rather than only "what's broken."
- Natural pairing with §13.5 (installer) — examples get bundled with the installer, so this pass and that one should probably be sequenced together or at least cross-checked.

### 13.7 Enhance AI integration in the IDE (added 2026-07-03)

**Secondary audience note that motivated this:** beyond the core §1 audience (returning Basic programmers, desktop hobbyists, students), the owner observed that some business users might be drawn to VFBE for a different reason — a robust, no-nonsense IDE focused on getting work done, with strong AI integration, rather than for BASIC nostalgia specifically. This doesn't change the §1 audience-driven minimalism principle (still don't add configuration surface just because a power-user audience might want it) — it's specifically about the AI feature area being worth investing in further, since a good AI-integrated workflow is something both audiences would value.

**Starting point:** the AI system (`src/AIService.bas`, ~810 lines) already supports multiple providers (OpenAI, DeepSeek, Claude, Mistral, Ollama, OpenRouter) with streaming and context management — per the 2026-07-03 complexity audit, this is reasonably-scoped code, not bloated. The AI Agent also just had a real bug fixed this session (§4 note elsewhere in this doc / see the `_WIN32_WINNT`-adjacent fix list): `VisualFBEditor IDE Environment.md`, a 2,874-line reference of every IDE menu/feature, was silently failing to load into AI context due to a wrong path in `Main.bas` — now fixed, so the AI Agent should have meaningfully richer IDE-awareness going forward than it did before this session.

**Not yet scoped** — no specific feature list decided. Candidate areas to consider when this is picked up: deeper codebase-aware context (not just the static IDE-environment reference now correctly loading, but live awareness of the user's actual open project); AI-assisted debugging or error-message explanation; inline code suggestions beyond the existing `Suggestions` tab. Should be scoped deliberately when picked up rather than growing organically — same anti-scope-creep discipline as the rest of §13.

### 13.8 Design-workspace status bar (deferred 2026-07-04 — "nice to have, not critical")

Owner spec, captured verbatim for whenever this is picked up: a status bar docked to the bottom of the Form Designer's visual workspace (`TabWindow.pnlForm`), full width of that panel specifically (not the whole tab — must track `pnlForm`'s width as the Code/Form splitter moves), three cells:
1. Name of the form being edited.
2. Name of the control currently being edited/selected.
3. Layer info — "none" when the selection isn't inside a `PagePanel`, otherwise "Layer N of Total" plus two left/right buttons (only enabled in layer mode) to move between layers, reusing the `Designer.MovePanelLayer` added this session.

Cells 1 and 2 should update live as the user renames the form or the selected control via the property grid.

**Why deferred, not just "todo":** researched 2026-07-04 and confirmed genuinely non-trivial — `pnlForm` itself docks normally via the framework's Align system, but the *design control* (the form being edited) inside it is positioned via raw HWND math independent of that docking (its `ParentHandle` is set directly, sized to match the form's own declared bounds, scaled for DPI) — specifically in `pnlForm_Message`'s `WM_SIZE` handler (scrollbar-range math against `Des->GetControlBounds(...)` vs. `pnl->ClientWidth`/`ClientHeight`, `TabWindow.bas` ~10227-10286) and `Designer.HookDialogProc`'s `WM_NCCALCSIZE` case (`Designer.bas` ~2253-2261, which already reserves space at the *top* for the form's own menu bar via `TopMenuHeight` — the model to mirror for a *bottom* reservation). This is the exact same layout-engine territory as the docking-engine bug that's already this project's most expensive-to-debug area (see the recurring "sound design, unfinished last mile" pattern noted throughout §8) — worth doing carefully in a dedicated session, not squeezed in alongside other work.

There's no native "embed a control inside a status bar panel" API in `mff/StatusBar.bi` (`StatusPanel` reserves width/caption only) — the existing global status bar (`pstBar`, `Main.bas` ~5206-5223) works around this by parenting a plain control (a progress bar, in that case) over a reserved panel's x-offset manually; the same trick would be needed for cells 3's left/right layer buttons.

For the live-update wiring: every property-grid commit (including "Name") funnels through `Sub PropertyChanged` (`TabWindow.bas` ~2555-2667), which already special-cases `PropertyName = "Name"` (~2588-2596) to call `TabWindow.ChangeName` — that's the one choke point to hook for keeping cells 1/2 in sync, regardless of whether the edit came from the property grid's cell editor, its textbox, or its combo.

### 13.9 Blank Designer page on cold-open until a control is selected (deferred 2026-07-04 — "nice to have, not critical")

See §8's panel/layer navigation write-up for full context. A `PagePanel` page (e.g. `frmOptions.frm`'s "General" page) shows blank the moment the file is opened, even though `SelectedPanelIndex`/`Visible` are (as of this session's fixes) correctly set — it only renders once a control inside that page is actually selected. Added `Controls[i]->RequestAlign` to `PagePanel.SelectedPanelIndex`'s real setter (the architecturally-obvious fix — force a layout pass the moment a page becomes visible) but confirmed via testing this wasn't sufficient; the real trigger that makes it render (selecting a control *inside* the page) does something beyond what `RequestAlign` alone captures. Owner explicitly deprioritized further chasing this — all of the actual navigation (tree, right-click menu, Ctrl+PageUp/PageDown) works correctly the moment any selection has happened, so this is purely a cold-open-frame cosmetic issue, not a functional blocker. Next session starting here should re-open with fresh eyes on what specifically differs between "becoming visible via `SelectedPanelIndex`'s setter" and "becoming visible via selecting a control inside it" (`Designer.MoveDots`/`DesignerChangeSelection` are the obvious next things to diff against `RequestAlign`).

### 13.10 Dark mode: owner-drawn popup menus + input-field polish (deferred 2026-07-04)

Dark mode is stable and near-complete (see §4), but popup/dropdown menus remain light. Windows provides **no documented API** for dark Win32 popup menus — the choices are the undocumented uxtheme-ordinal route (rejected on principle for this fork) or fully owner-drawn menu items. The framework already has the opt-in switch (`Menus.bas` `Menu.Style` property → `TraverseItems` flips every item to `MFT_OWNERDRAW`, `Menus.bi:205`) and the item data is already threaded through (`MENUITEMINFO.dwItemData` carries the `MenuItem Ptr`, `Menus.bas:120`), but the actual renderer is missing: `WM_DRAWITEM ODT_MENU` in `Control.bas:1257-1260` (and `Form.bas:990-992`) is an empty stub with only a commented-out `ImageList_Draw`. Do NOT just enable `Menu.Style` — menus render blank without the drawer.

Scope when picked up: implement `WM_MEASUREITEM`/`WM_DRAWITEM` for `ODT_MENU` — item text, right-aligned accelerator text (caption already stores the accelerator after a tab), icons (`FImage`/`ImagesList`), checkmarks/radio marks, separators, submenu arrows, disabled/hot states — using the existing dark palette (`hbrBkgndMenu`/`darkBkColorMenu` in `Brush.bi/bas` were created for exactly this and are currently unused). Test exhaustively: menus are the most-used surface in the IDE. Optionally in the same pass: darken input-field faces (search `TextBox`, `ComboBoxEdit`/`ComboBoxEx` edit areas) beyond what the `DarkMode_CFD` theme provides, via `WM_CTLCOLOREDIT`-style handling.

### 13.11 Dark mode: dark dialog/modal backgrounds (nice to have, not essential)

Modal dialogs and secondary forms (Find/Replace, About, GoTo, etc.) currently render with a white background in dark mode. The `WM_ERASEBKGND` handler in `Control.bas:862-868` does not fill with a dark brush — the dark fill only happens in `WM_PAINT`, leaving a white flash or persistent white background when `WM_ERASEBKGND` fires without a subsequent `WM_PAINT`. A naive dark-fill in `WM_ERASEBKGND` was attempted and reverted (2026-07-04) because it caused white borders around owner-drawn popup menus — indicating `WM_ERASEBKGND` is sent to multiple window classes including menu windows, and a blanket fill would need to be scoped more carefully (e.g. only for form/dialog class names, not the `#32768` menu class). Additionally, the `WM_CTLCOLORBTN`/`WM_CTLCOLORSTATIC` handler at `Control.bas:925-987` applies dark colors but is gated on `FDefaultBackColor = FBackColor` — any control with an explicit `BackColor` set will not go dark, which may affect some dialog controls. Investigation scope when picked up: gate the `WM_ERASEBKGND` dark fill on the window class (exclude menu windows), and audit dialog `.frm` files for controls with non-default `BackColor`.

---

*End of status document.*
