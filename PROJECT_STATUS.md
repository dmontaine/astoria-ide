# VFBE Win64 Fork — Project Status & Handoff

**Last updated:** 2026-07-02  
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
| Native **WinAPI / Win32** UI | GTK / Linux IDE paths |
| **64-bit** IDE and bundled `fbc64.exe` | 32-bit IDE (`VisualFBEditor32`, `mff32`) |
| Bundled compiler at `Compiler\fbc64.exe` | Dark-mode dead code (`mff/DarkMode/`) |

**Build outputs (repo root):**

- `mff64.dll` — `Controls\MyFbFramework\mff64.dll`
- `VisualFBEditor64.exe` — main IDE

**Settings:** `Settings/VisualFBEditor64.ini` (runtime; path via `ExePath/Settings/...`)

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

Work is organized in batches. **Do not start the next batch until the current one compiles and passes manual sign-off.**

| Batch | Scope | Status |
|-------|--------|--------|
| **2.75.1** | Panel/layout cleanup in `Main.bas` | **Complete** (compile-clean) |
| **2.75.2** | Bulk GTK preprocessor strip (`Tools/strip_gtk_preprocessor.ps1` on `src/` + `mff/`) | **Complete** (compile-clean); manual test mostly done |
| **2.75.3+** | Commented `#IfNDef __USE_GTK__` cleanup, `mff/DarkMode/` removal, dead-code comment cleanup | **Planned / deferred** |

### GTK strip tool

```powershell
.\Tools\strip_gtk_preprocessor.ps1 src mff
```

Evaluates `#If` / `#Else` / `#EndIf` with Win64 defines (`__USE_WINAPI__`, `__FB_WIN32__`, `__FB_64BIT__`, GTK off). Re-run only when needed; review failures manually for interwoven blocks.

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

**User confirmation:** State retention works after (4). Collapse/reclaim fix (5) pending user sign-off on latest build.

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
- [x] Bottom panel pin/collapse/expand behavior (multi-iteration)
- [x] Bottom panel INI persistence (save timing + startup restore)
- [x] Bottom panel collapse reclaims editor height (latest; needs user test)
- [x] Codeberg remote + SSH
- [x] `ActivateMainWindow()` at end of `frmMain_Show` (editor foreground on startup)

---

## 7. Open items & manual test before 2.75.3

### User sign-off still needed

Run a full pass on **latest** `VisualFBEditor64.exe` after `Compile.bat`:

**Startup**

- [ ] Cold start — no ghost Find dialog, splash closes, main window active
- [ ] Bottom panel opens in same state as last session (pinned / auto-hide collapsed / auto-hide expanded)

**Bottom panel**

- [ ] Pin open → exit → restart — stays pinned (`BottomClosed=false` in INI)
- [ ] Auto-hide expanded → exit → restart — reopens expanded
- [ ] Collapse (pin or click-away) — **editor fills freed space** (no empty gap)
- [ ] Pin size/position acceptable in collapsed and expanded modes
- [ ] Single-click collapse when expanded
- [ ] Resize height persists (≥ 80px)

**Regression**

- [ ] Left/right panels pin/collapse/restore
- [ ] Ctrl+F, Find In Files
- [ ] Compile/run, Output/Problems tabs
- [ ] Form design, property editing

### Known deferred cleanup (not blocking unless touched)

- Commented `#IfNDef __USE_GTK__` blocks in source
- `mff/DarkMode/` directory removal
- Stray dead-code comments from GTK era
- `src/makefile` still references GTK defines (not used by `Compile.bat`)
- `src/THREADING.md` mentions GTK UI wrapping (historical)

### Optional / housekeeping

- `docompile.bat` — local helper at repo root (wrong path casing); not part of official build
- Consider `.gitignore` for `VisualFBEditor64.exe` if binary commits are undesired (currently committed like initial import)

---

## 8. Planned next steps (Tier 2.75.3+)

1. **User sign-off** on bottom panel + Batch 2.75.2 checklist
2. **Batch 2.75.3** — remove commented GTK preprocessor remnants (careful diff; compile after each logical chunk)
3. **Remove `mff/DarkMode/`** if no WinAPI references remain
4. **Dead-code comment pass** — grep for `__USE_GTK__`, `GTK`, `Linux`, `dark mode` in `src/` and `mff/`
5. **Update `THREADING.md`** — WinAPI-only threading notes
6. Longer term: upstream sync strategy (if any), wiki/docs for fork-specific behavior

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
- **No commits** unless user explicitly asks (exception: this handoff push)
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

**Panel save (`frmMain_Close`):**

1. `SaveMainWindowPanelLayout()` — **first**, before `CloseSession`  
2. … session close, other INI keys …

---

## 11. Handoff notes for Claude Code

1. **Read this file first**, then `src/BUILD.md` and `.cursor/skills/contextual-change-validation/SKILL.md` before panel/settings changes.

2. **Bottom panel is the highest-risk area** — save timing, `TabPosition` vs collapse, `ptabBottom->Height`, and `frmMain_ActiveControlChanged` interact. Compare any change to **left/right** panel patterns in the same file.

3. **Avoid fix cycles** — map full surface, compile, checklist; if stuck after 4 iterations, stop and document root cause instead of tweaking one line.

4. **Batch 2.75.3** is cleanup, not feature work — keep diffs reviewable; compile after each chunk.

5. **Upstream** is Xusinboy’s VisualFBEditor; this fork intentionally diverges (Win64-only). Merge upstream only with explicit plan.

6. **Examples/** and **Tools/** are largely untouched by Tier 2.75; don’t strip GTK from user examples unless that’s a separate decision.

---

## 12. Commit log (this fork)

| Commit | Description |
|--------|-------------|
| `bbfa399` | Initial Win64 fork import |
| `e212819` | Bottom panel persistence/collapse; startup guards; `SaveMainWindowPanelLayout`; `PROJECT_STATUS.md` |

---

*End of status document.*
