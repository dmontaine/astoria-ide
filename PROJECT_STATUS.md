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
| Bundled compiler at `Compiler\fbc64.exe` (tracked in-repo; 1.10.3 swap-in planned, see Tier 3) | Dark-mode *implementation* — replaced with an inert stub, interface preserved for a future trustworthy reimplementation (not full removal — see §3a) |

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

---

## 3a. Batch 2.75.3 — what actually happened

Beyond the originally-scoped "strip commented GTK markers," this batch also caught and fixed a **shipped-broken Designer** and expanded to a broader dead-legacy-code pass at the owner's explicit direction ("also remove old dead legacy code" encountered along the way, not just GTK-tagged code).

**Root-cause fix — Form Designer never activated for any `.frm` file:**
`Tools/strip_gtk_preprocessor.ps1` didn't recognize the `__EXPORT_PROCS__` macro and silently deleted the entire `#ifdef __EXPORT_PROCS__` export-dispatcher block from `mff.bi` plus per-file `Export` functions in ~14 `mff/*.bas` files, so `mff64.dll` shipped with **zero exports**. Fixed the strip tool and manually restored the missing blocks (2 `ToolBar.bas` functions deliberately deferred — restoring them hits an unresolved FreeBASIC "Illegal specification" compiler quirk on a `Private Enum` parameter; not called anywhere in the IDE itself). Commit `bef9267`.

**Dark mode — replaced, not removed:**
The undocumented-API dark-mode implementation (ordinal-resolved `uxtheme.dll` calls, `ntdll` version probing, IAT hooking) was flagged by the owner as unreliable and untrusted. Replaced with an inert stub (`mff/DarkMode/DarkMode.bi`/`.bas`) that preserves the exact public interface as no-ops, so every call site still compiles and behaves as before (dark mode was already forced off). This intentionally leaves a clean seam for a trustworthy reimplementation later rather than deleting the integration points. `mff/DarkMode/IatHook.bi` (zero references) deleted outright; `UAHMenuBar.bi` kept (still used by `Form.bas`, unrelated to the ordinal/IAT fragility). Commit `56f6d18`.

**Confirmed-dead subtree deletion:** `mff/gir_headers/`, `mff/WebView/`, `mff/fbsound/`, `SoundPlayer.bas`/`.bi` — 109 files, ~104k lines, zero references anywhere, verified via clean rebuild. Commit `c494207`.

**Compile warnings:** all resolved (WString default-parameter fixes, `AndAlso`-chained boolean/pointer-property comparisons isolated into explicit `Boolean` locals). Commits `53d8e47` + `56f6d18` (first pass under-verified due to a UTF-16 log encoding gotcha with raw `grep`; corrected in the second commit).

**Physical dead-code deletion** (the literal instruction: delete, don't hide) across:
- `src/Debug.bas` — dead conditional-breakpoint UI functions, a dead `get_main_file_from_exe`/`get_name_files_from_exe` pair, a duplicate ~300-line dead 32-bit stabs-parsing branch, misc stray markers. Commit `7baebd1`.
- `src/Designer.bas`/`.bi`, `src/Main.bas`/`.bi`, `src/TabWindow.bas`, `src/VisualFBEditor.bas` — dead WM_KEYDOWN/GTK popup-menu branches, a ~300-line dead GTK VTE-terminal integration block, a dead ListView-based property-panel implementation (superseded by the current `TreeListView`-based one), dead debugger-UI branches. Commit `add4642`.
- `Controls/MyFbFramework/mff/*.bas` (16 files) — dead GTK-only branches, dead sort/alignment/tooltip logic, dead PNG-loading functions; `NativeFontControl.bas`/`.bi` deleted outright (100% commented out, confirmed unreferenced anywhere). Commit `76abaa5`.

**Verification:** every commit above passed a clean `Compile.bat` rebuild (0 warnings, 0 errors — checked with the `Read` tool, since the log is UTF-16 and raw `grep` silently false-negatives on it). A final repo-wide sweep confirms only one GTK/32-bit marker remains anywhere in `src/` or `mff/`: `TabWindow.bas`'s `CheckCondition()`, which evaluates `#if` conditions in the *user's* FreeBASIC code being edited — a legitimate IDE feature, correctly left alone.

**Git-tracking policy change:** `Compiler/` and `Debuggers/` are now tracked in git (previously vendored/gitignored) — this is intentionally a fully self-contained fork going forward. Commit `b555406`. 32-bit compiler binaries (`Compiler/bin/win32`) removed as out of scope. Commit `15e66cc`.

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

### FreeBASIC compiler version decision (for upcoming Tier 3 work)

Owner plans to replace the bundled `Compiler/` tree and eventually vendor the compiler's own source for future AI-assisted review. Compared 1.10.1 (currently bundled), 1.10.3, 1.10.4 (unreleased), and 1.20 (unreleased) — **decided on 1.10.3** from the `fbc-1.10` maintenance branch. 1.20 was ruled out for now: it removes null-termination from fixed-length strings (`STRING*N`/`WSTRING*N`), a breaking change that would need an audit of this codebase's fixed-string usage first. Owner specified a preferred binary source: community continuous builds at `users.freebasic-portal.de/stw/builds/` (maintainer "stw", trusted long-time contributor) over the "official" release, since stw's build is expected to be equal-or-better quality. **Not yet started** — see Tier 3 in §8.

### Debugger backend decision: GDB, not gas64/Integrated

VFBE already supports two debugger paths for **user projects** (not the IDE itself) as a per-project setting (`ToGAS`/`ToGCC` in `src/BuildService.bas`/`src/TabWindow.bas`): the "Integrated IDE Debugger" in `src/Debug.bas` (requires the user's project compiled with `-gen gas/gas64 -g`, reads FreeBASIC's native stabs debug format directly) versus the "Integrated GDB Debugger" (requires `-gen gcc` + gcc debug flags, standard GDB). These are matched pairs, not interchangeable — `Debug.bas` explicitly errors if the wrong backend/debug-format combination is used.

**Decided: GDB is the project's debugger.** Settled by what's actually bundled: `Debuggers/gdb-11.2.90.20220320-x86_64/` contains only `gdb.exe`/`gdbserver.exe` — there's no separate gas64-native debugger tool anywhere in this repo, so the practical toolchain already implies GDB. This also matched the research-backed recommendation from the same session (Tiko, a comparable FreeBASIC IDE, recently reversed its own default away from gas64 back to GCC for 64-bit builds).

**Open decision point (not yet decided): compile-backend default for user projects (`-gen gas64` vs `-gen gcc`).** This is a separate question from which debugger tool is used, and it's still open:
- Owner has read further forum threads since the debugger decision above and believes the FreeBASIC 1.10.1-era `gas64` problems that motivated caution have since been fixed upstream (not independently verified by Claude — worth a quick sanity check when this is picked up, e.g. skim the later pages of the [gas64 thread](https://www.freebasic.net/forum/viewtopic.php?t=27478) for confirmation of what was fixed and when).
- The real remaining tradeoff, per the owner: `-gen gas64` compiles faster but produces larger/slower executables; `-gen gcc` compiles slower but produces smaller/faster executables.
- **Owner's judgment:** the target audience (§1 — returning Basic programmers, hobbyists, students) cares more about a fast edit/compile/run work cycle than runtime file size or execution speed, and doesn't believe the size/speed difference is significant enough to matter. This leans toward **`-gen gas64` as the default for user projects.**
- **Unresolved technical dependency before finalizing:** does the bundled GDB (11.2.90) actually debug a `-gen gas64`-compiled executable correctly? `Debug.bas`'s existing code pairs `-gen gas/gas64` specifically with the *Integrated* (native-stabs) debugger, not GDB, in its own error-checking logic — but GDB has long-standing native support for the STABS debug format, which is plausibly what `-gen gas64 -g` already emits, so this may just work without needing the Integrated debugger path at all. This needs an empirical check (compile a small test program with `-gen gas64 -g`, debug it via VFBE's GDB path, confirm breakpoints/stepping/watches work) before locking in `-gen gas64` as the default — otherwise the GDB decision and a gas64-by-default decision could quietly conflict in practice even though they don't conflict on paper.
- Once resolved: if GDB works cleanly against gas64 output, default new projects to `-gen gas64` + GDB (fast compiles, standard debugger, best of both). If not, fall back to `-gen gcc` + GDB as originally implied, accepting the slower compile.

Whether the Integrated (stabs) Debugger code path in `Debug.bas` should eventually be pared down once this is settled (rather than kept as an unused alternate path) is a separate, not-yet-decided question — flagging it as a candidate for a future §13.2-style consistency pass rather than deciding now.

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
- [x] 32-bit compiler binaries removed (`Compiler/bin/win32`) (`15e66cc`)
- [x] All compile warnings resolved, 0 warnings/0 errors (`53d8e47`, `56f6d18`)
- [x] Dark-mode implementation replaced with inert stub (interface preserved) (`56f6d18`)
- [x] Confirmed-dead subtrees deleted: `gir_headers/`, `WebView/`, `fbsound/`, `SoundPlayer.*` (`c494207`)
- [x] Batch 2.75.3 — physical dead-code deletion across `Debug.bas`, `Designer.bas`/`.bi`, `Main.bas`/`.bi`, `TabWindow.bas`, `VisualFBEditor.bas`, ~15 `mff/*.bas` files, `NativeFontControl.bas`/`.bi` deleted outright (`7baebd1`, `add4642`, `76abaa5`)

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

- [ ] Cold start — no ghost Find dialog, splash closes, main window active
- [ ] Bottom panel opens in same state as last session (pinned / auto-hide collapsed / auto-hide expanded)
- [ ] Cold start with bottom **collapsed** — editor fills space immediately (no empty gap)

### Bottom panel (regression on fixes)

- [x] Pin open → exit → restart — stays pinned (`BottomClosed=false` in INI) — **owner verified**
- [x] Auto-hide expanded → exit → restart — reopens expanded — **owner verified**
- [x] Collapse (pin or click-away) — editor fills freed space — **owner verified**
- [x] First start collapsed — editor fills space — **owner verified**
- [ ] Pin size/position acceptable in collapsed and expanded modes
- [ ] Single-click collapse when expanded
- [ ] Resize height persists (≥ 80px)

### Regression (Batch 2.75.2 + adjacent areas)

- [ ] Left/right panels pin/collapse/restore
- [ ] Ctrl+F, Find In Files
- [ ] Compile/run, Output/Problems tabs
- [ ] Form design, property editing
- [ ] Toolbox insert, project explorer, AI Agent tab (if used)
- [ ] Session open/save, recent files/projects

### Gate to Tier 3

**All unchecked items above (including the debugger smoke test) should pass** — or be explicitly deferred with a note in this file — before starting Tier 3 compiler-swap work in §8, since a compiler swap makes it harder to isolate whether a future regression came from the dead-code deletion or the new compiler.

### Known deferred cleanup (not blocking unless touched)

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

### Immediate

1. **Regression validation** — complete **§7 manual test plan**, including the new debugger smoke test, before starting Tier 3
2. **Low-priority cleanup** (optional, not blocking): `src/makefile` GTK defines, `src/THREADING.md` GTK mentions

### Tier 3 — compiler toolchain (owner-directed, not yet started)

3. **Verify a compiled `fbc64` is available for 1.10.3** from `users.freebasic-portal.de/stw/builds/` (build ~#0875, commit `8708d1a`, per owner's preferred source); if not, stand up a build environment instead
4. **Replace `Compiler/` tree** with the 1.10.3 build; verify `fbc64 -version` reports 1.10.3; full clean rebuild + §7 regression pass again afterward
5. **Longer term:** vendor the FreeBASIC compiler's own source into the repo tree, in preparation for future AI-assisted review/modification of the compiler itself (owner-flagged as upcoming, no timeline yet)

### Longer term / unscheduled

6. Upstream sync strategy (if any) — this fork intentionally diverges (Win64-only); merge upstream only with an explicit plan
7. Wiki/docs for fork-specific behavior

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
- **Every session ends with a push to Codeberg** (added 2026-07-03) — commit any outstanding working-tree changes (status doc updates, INI/scratch state, etc.) with a sensible message, then `git push origin main`, as the last action before signing off for the day. This is a standing instruction, not a one-time request — don't wait to be asked again in future sessions.
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

10. **Tier 3 (compiler swap) not yet started** — see §8. Owner has already decided on FreeBASIC 1.10.3 from the `stw` community build portal over the official release; don't re-litigate that decision without new information.

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

FreeBASIC's Win64 backend compiles through a bundled `gcc`/`binutils` (`as`, `ld`, `dlltool`, `GoRC`) under `Compiler/bin/win64/`, not just `fbc64.exe` itself. Worth bundling with the Tier 3 compiler swap rather than doing separately, since:
- The FreeBASIC 1.10.3 build already decided on (stw's portal, §8) will have shipped with a specific paired GCC/binutils version — need to check what that is before assuming an independent upgrade is possible.
- A newer GCC needs a matching MinGW-w64 runtime/headers set; swapping GCC alone without the matching toolchain risks subtle ABI or linker-flag mismatches (`Compile.bat`'s `ld` invocation has a long hand-tuned flag list — see the build log in §3a's verification note).
- Decide: adopt whatever GCC ships with the chosen fbc build, or independently source a newer one and re-verify the full flag set still links cleanly.

### 13.2 Structured programming, consistency, and legacy-tech-debt removal

**Owner's stated goal:** this codebase carries the accumulated effect of many independent programmers working on it over many years with minimal communication between them. The point of this pass isn't cosmetic formatting — it's to impose one consistent set of conventions and structure over code that currently has as many styles as it had contributors, so the system becomes legible and maintainable going forward rather than an archaeology exercise every time someone touches it.

Concrete goals, in the owner's words plus scope notes:
- **Structured programming** — reduce/eliminate spaghetti control flow inherited from the codebase's age (deeply nested conditionals, non-local control flow, functions doing too many unrelated things). `src/Debug.bas` (§3a) is the most extreme example already encountered — a ~12,500-line file mixing multiple debugger-backend eras in one module.
- **Variable consistency** — one naming convention applied uniformly (this codebase currently mixes Hungarian-ish prefixes in some modules with plain names in others, and inconsistent `Private`/scope conventions).
- **Standard indenting** — one whitespace style repo-wide (currently mixed tabs/spaces even within single files).
- **Move repeating code into classes/procedures** — DRY pass; likely the highest-value structural work here, since duplicated logic (already seen in miniature during Tier 2.75.3 — e.g. the duplicate `udt(0)`–`udt(16)` block found dead in `Debug.bas`) is exactly what independent, uncoordinated contributors tend to produce instead of factoring shared code.
- **Remove legacy tech debt** broadly, not just GTK/32-bit remnants already handled in Tier 2.75.3.

Execution notes:
- There's no established "prettier"-equivalent formatter for FreeBASIC. Whitespace/indentation normalization is safely scriptable in bulk; naming, structure, and DRY refactors are not — those risk breaking `Alias`/`Export` bindings (as already seen with the `ToolBar.bas` compiler quirk in §3a) and need file-by-file compile verification, same discipline as the dead-code deletion pass.
- This is real restructuring work, not a mechanical pass — expect it to be the largest single effort in the project, larger than Tier 2.75 was. Owner has explicitly said timeline is not a constraint here (see §13.4) — no need to compress this into a quick pass.
- Should happen **after** the Tier 3 compiler swap — no point restructuring files that might still change during compiler validation.
- Natural pairing with §13.4 (rename): if the project is getting a fresh identity specifically to mark a disciplined restart, this is the pass that actually earns that fresh identity.

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
- INI file name/path (`Settings/VisualFBEditor64.ini`) — needs a migration story if existing users' settings shouldn't be silently orphaned
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

---

*End of status document.*
