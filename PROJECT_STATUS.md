# VFBE Win64 Fork — Project Status & Handoff

**Last updated:** 2026-07-11 (**T16 done — Fable adversarial review of all five Wave-3 commits** (T3 `4394ca2`, T4 `1fbb944`, T7 `cda99f8`, T2a `8d04929`, T2b+T17 `e83212f`), reviewed individually per the owner's per-task-commit decision. Charter covered: injection via file/tool names, paths with spaces, failure paths, clipboard, threading. **Verdict: sound overall — 3 findings for Sonnet follow-up (1 confirmed bug, 2 hardening), 5 notes, nothing that warrants reverting anything.** Full findings in the "T16 findings" section under the remediation queue. Clipboard: the `|clip` clobber is fully gone, no remaining clipboard writes on any reviewed path. T2b/T17 verified clean: `[Helps]` renumbering is contiguous and terminates `SettingsService`'s indexed-key loop correctly at i=4 (`keySum = -7` requires *all seven* sections exhausted at the same index, so sections ending at different indices are fine); `DefaultHelp` still names `Version_0`; `tML` still has live uses in both Find files, so nothing was orphaned. Local rebuild of the reviewed tree: compile-clean. **Owner smoke test still owed** (the accumulated Wave-3 list in the T16 row): Open Containing Folder, an external tool, Delete Project on a disposable project, Options ▸ Apply, clipboard-preservation check, and double-clicking a file with a registered External Editor.)

**Last updated:** 2026-07-11 (**T2a done — startup writability probe**, plus an **owner-found main-window-size regression fixed in the same session**. T2a: right after the splash's "Load On Startup: Settings" step (`Main.bas`, before `LoadLanguageTexts`/`LoadSettings` run), attempts a real `Open ... For Output` against a throwaway `Settings/.writetest` file — not just an ACL check — and on failure shows one `MsgBox` ("Astoria IDE needs to run from a folder you can write to — install per-user or move it out of Program Files.") and exits (`End 1`) instead of limping on with settings that silently never save. Verified both directions: a normal writable launch proceeds silently (probe file created and cleaned up, confirmed absent afterward) and a disposable copy with `Settings` write-denied via `icacls` correctly showed the MsgBox and did not open the main IDE window (owner-witnessed). **Regression found and fixed along the way:** while doing the normal-launch check, the owner reported the main window opening as a ~133×38 sliver (just the caption bar) with the New Project dialog mostly off-screen. Root-caused to `Settings/astoria.ini` shipping `Width=`/`Height=`/`Maximized=` present-but-*empty* — the vendored `IniFile.ReadInteger`/`ReadBool` (`mff/IniFile.bas:298-312`) only fall back to their default when a key is *absent*, not when it's empty, so a blank `Width=` read back as `0`. Traced to a forced-kill mid-save during this session's own testing (`Stop-Process -Force`), not a pre-existing shipped bug — worth being more careful about graceful shutdown in future test launches. Fixed both the data (restored the last known-good `Width=1661`/`Height=1039`/`Maximized=false` from git history) and the code (`Main.bas`: `frmMain.Width`/`Height` now floor at 400/300 before falling back to the 1024×768 default, matching the same guard pattern already used a few lines below for `tabLeftWidth`/`tabBottomHeight`) so a future blank-value corruption self-heals instead of reproducing the tiny window. Verified via direct `GetWindowRect` measurement post-fix: `1661x1039`, correct. Compile-clean throughout.)

**Last updated:** 2026-07-11 (**T7 done — checked the 6 remaining unchecked `Open ... For Output` writes.** Added the R2 pattern (check result → surface failure → bail) at `BuildService.bas:259` (batch-compile file rewrite), `frmImageManager.frm:398` (resource file), `frmOptions.frm:3119` (`HotKeys.txt`), `frmTools.frm:241` (`Tools.ini`), `Main.bas:8364` (Immediate-window scratch file), `TabWindow.bas:2884` (generated `.bi` from `ConvertHToBi`). **One deliberate deviation from the literal instruction, found while auditing each site's calling context rather than pattern-matching blind:** `BuildService.bas:259` runs inside `Compile()`, which `THREADING.md`'s own table lists as worker-thread work, and the doc's rule 3 explicitly forbids calling `MsgBox` from a worker thread without marshaling — this codebase has no such marshaling helper. Used `ShowMessages` (Output panel, wrapped in the same `ThreadsEnter`/`ThreadsLeave` this exact function already uses a few lines below for compile status) instead of a raw `MsgBox`, to avoid introducing a new instance of the exact bug class `THREADING.md` warns about. The other 5 sites are UI-thread event handlers (button clicks, keydown, Designer-triggered header conversion) — direct `MsgBox` per the literal R2 pattern is correct there. Also fixed two related silent-corruption risks found while placing the guards, not just "add a check": `frmTools.frm`'s `cmdOK_Click` used to tear down the in-memory External Tools list (`_Delete`/`pTools->Clear`/menu removal) and close the dialog as success *even if the write had failed* — the guard now bails before any of that runs. `frmOptions.frm`'s HotKeys-save failure now skips only the hotkeys write-and-rebind block (via `Else`, not `Exit Sub`) so the rest of `cmdApply_Click`'s unrelated settings (already partially applied above this point in the same handler) still go through instead of being abandoned mid-apply. Compile-clean, `git grep` sweep confirmed all 6 sites guarded and the pre-existing correctly-checked/intentionally-silent sites (`TabWindow.bas:11391/11424`, `Main.bas:1376` workspace autosave) untouched, launch-tested.)

**Last updated:** 2026-07-11 (**T4 done — native project delete.** Replaced the shelled `rd /s /q` in `DeleteProject()` (`Main.bas`) with `SHFileOperationW`: no `cmd.exe` round-trip, deletes go to the Recycle Bin (`FOF_ALLOWUNDO`) instead of a permanent delete, and a failure now surfaces via `MsgBox` (F1 feedback-channel policy) with `DeleteProject` returning `False` instead of silently reporting success. `pFrom` is a fixed `WString * 1024` buffer, explicitly `ZeroMemory`'d before assignment so the required double-null-termination is guaranteed rather than relying on possibly-uninitialized stack memory. The `ChDir ExePath` guard (Windows won't remove a directory that's any process's CWD) is preserved untouched, as scoped. **Verified with a standalone throwaway test program** (compiled with the same bundled `fbc64.exe`, same struct/flags) against a disposable nested test folder — confirmed `SHFileOperationW` returns 0, the folder is gone from disk, and it lands in the Recycle Bin (checked via `Shell.Application` COM) rather than being permanently deleted; chosen because the full in-app click-through (right-click → Delete Project → confirm) needs GUI access this session doesn't have and is already covered by T16's later combined owner smoke test. Compile-clean, `git grep` sweep clean (no remaining `rd /s /q` outside this comment), launch-tested.)

**Last updated:** 2026-07-11 (**T1 decision gate resolved — owner signed off Option B: per-user install, portable model kept.** Fable's write-surface survey ([`Documents/fable_t1_settings_location.md`](../../Documents/fable_t1_settings_location.md)) found 9 ExePath write clusters — including in-place shipped-theme edits and dead `Languages.txt` dumps — and weighed APPDATA migration vs. keeping everything under `ExePath` with the §13.5 installer targeting `{localappdata}\Programs\AstoriaIDE` (Inno Setup `PrivilegesRequired=lowest`, VS Code user-installer style + portable zip). Owner chose the latter: **no APPDATA migration, no Program Files install; the fragile `SettingsService`/startup code stays untouched.** T2 redefined to T2a (startup writability probe with a clear MsgBox) + T2b (delete the `Languages.txt` write sites). **§13.5 is now unblocked.** Two deferred owner questions recorded in Open Items (`_Change.log` location, default `ProjectsPath`). Same day, per owner reminder that the project is English-only: **T17 added** (English-only shipped-content sweep — ru/zh/de/French Help manuals + Tip-of-the-Day files, and the `[Helps]` INI catalog entries; Sonnet, because `[Helps]` is an indexed-key section needing careful renumbering). Next: Wave 3 — T3 (PipeCmd), T4 (project delete), T7 (unchecked writes), T2a/T2b, T17, then T16 combined review.)

**Last updated:** 2026-07-11 (**Wave 1 (hygiene) of the Fable remediation queue complete — T8, T9, T10, T11, T12, T13 all done.** T9 (Haiku): repo hygiene sweep — deleted the Downloads-path line from `src/Temp.rc`, untracked + gitignored three scratch files, added five `.gitignore` rules. T10 (Haiku): cleaned the tracked `Settings/astoria.ini` — stripped `RecentSession`, MRU lists, window-geometry keys. T11 (Haiku): deleted four unreachable Chinese data files from `Settings/Others/` (dead since C4 hard-set English-only; `git grep` sweep confirmed zero callers). T8 (Sonnet): reworked CI — deleted `.github/workflows/windows.bat` and its three unverified downloads (7-Zip, FreeBASIC 1.10.0, upstream MyFbFramework `master.zip`), `windows.yml` now checks out with `@v4` and calls the repo's own `Compile.bat` directly so CI can't drift from local builds and fails on real compiler errors. T12 (Sonnet): README refresh — dropped the stale `Language: English` header, rewrote Requirements to state the compiler is bundled (was contradicting the fork's own pitch), fixed the malformed MyFbFramework URL in both README.md and this doc's §1, flagged the seven upstream-VFBE screenshots with an owner-facing TODO for replacement. T13 (Sonnet): **version reset to 1.0 (owner decision, upstream numbering no longer followed)** in `src/AstoriaIDE.rc`; `src/Manifest.xml` identity fixed (`Form1` → `AstoriaIDE`) and `asInvoker` uncommented; `src/THREADING.md` retitled. T13 compile + launch check both passed (`FileVersion 1.0.0.0` / `ProductVersion 1.0` / `ProductName AstoriaIDE` confirmed in the built exe; process launched, stayed responsive, stopped cleanly). **Next: T1 decision gate** (Fable, settings-location memo) — gates T2 and §13.5.)

**Last updated:** 2026-07-11 (**Fable full-project review complete; remediation sub-project queued (T1–T16)** — Fable (`claude-fable-5`) reviewed PROJECT_STATUS + the project elements against the design goals for robustness, security, reliability, and consistency. Verdict: consistent with the design goals; the significant findings are forward-looking — two §13.5 installer blockers (settings/temp/logs written under `ExePath`, which fails under Program Files with no 64-bit UAC-virtualization safety net; unquoted GDB path in the debugger launch) and one user-facing defect class (the shared `PipeCmd` launcher pipes every command through `cmd /c "…"|clip`, silently clobbering the user's clipboard on Open-Containing-Folder / external tools / Delete Project) — plus repo/CI/doc hygiene drift. Full report: [`Documents/fable_review.md`](../../Documents/fable_review.md). Sixteen tasks queued in execution order with per-model instructions — see "⭐ ACTIVE SUB-PROJECT — Fable review remediation" below.)

**Last updated:** 2026-07-10 (**Project renamed VisualFBEditor → AstoriaIDE**, `c93abbe` — full identity rename per ROADMAP §13.4, now marked done there: output binary `VisualFBEditor64.exe` → `astoria.exe`, source/project/resource files → `AstoriaIDE.bas/.rc/.vfp`/`AstoriaIDE.ico`, settings file `Settings/VisualFBEditor64.ini` → `Settings/astoria.ini` (existing settings preserved, not a fresh file), window title/splash screen/~15 dialog-title strings, README, and ~44 source-file header comments. Internal code identifiers — `VisualFBEditorApp`, `Namespace VisualFBEditor`, `WhenVisualFBEditorStarts` — deliberately left as-is (not user-facing). GitHub repo name/clone URL untouched (separate owner decision). Same commit replaced `frmAbout` with a fresh owner-authored dialog and cleared the build's last two compile warnings (ambiguous `=` in `IIf()` args, mismatched `Find()`/`ReplaceInFile()` param declarations) — compile is now genuinely 0 errors, 0 warnings. Same session: stale `Temp/Untitled.bas` scratch file deleted (`84b5bee`); and, just before, a Lazarus-style **Code/Form view top tab strip** (`tcView`) replaced the old per-tab Code/Form/Code+Form toolbar toggle buttons (`4b643af`, owner+Opus) — switching logic centralized into `TabWindow` methods (`ApplyView`/`ShowView`/`SyncViewTab`/`CurrentView`/`SetFormViewsEnabled`), ~20 former `tbrTop.Buttons.Item(...)->Checked` call sites migrated, compile-clean, owner-tested across all three views and both file types. See [CHANGELOG.md](CHANGELOG.md) for both UI-change entries.)

**Last updated:** 2026-07-08 (**C4 — full `.lng`/translation-capability removal (English-only)**, compile-clean, **owner smoke-test needed before commit** — see "C4: full language-system removal" below. Earlier same day: **E1 merged into `main`** (`b078d99`) from its background-task worktree, compile-clean, owner-verified. While testing E1, owner found **"Close Project" greyed out on startup with a reloaded project** — root-caused and fixed, owner-verified: see "Startup Close-Project-greyed fix" below.)

**Last updated:** 2026-07-07 (**Close Project crash+hang root-caused & fixed** — GDB-traced to a dangling tree-node `.Tag` use-after-free in `tvExplorer_SelChange` + tabs never closing; fixed via null-after-free, robust tab-close by node ancestry, and a safety bail. Also: **empty-workspace startup now prompts File → New Project** (owner design), and the **New Project / Open Project dialogs cross-navigate** via new "Open Existing Project" / "Open New Project" buttons. D1 Designer-menu greying now complete (incl. the form-close gap, fixed via `ChangeMenuItemsEnabled`). Earlier same day: Opus "Next Steps" backlog fully worked through except R5/E1/`.lng` cleanup; 13.3.A S1–S7 all Opus-reviewed & committed)  
**Repository:** [github.com/dmontaine/astoria-ide](https://github.com/dmontaine/astoria-ide) (renamed lowercase 2026-07-10, following the AstoriaIDE rebrand — GitHub redirects the old `Astoria-IDE` URL; Codeberg retired 2026-07-09 — see below)  
**Local path:** `C:\Users\don\Astoria-IDE`  
**Owner:** bigriverguy (`dmontaine@gmail.com`)

**Last updated:** 2026-07-09 (**AI Agent subsystem removal scoped & queued as the next sub-project** — owner reversed the earlier 13.7 "enhance AI" plan and decided to remove the built-in AI subsystem entirely; see "⭐ NEXT SUB-PROJECT" below. Also committed/pushed the pre-existing Help ▸ GitHub menu removal to GitHub.)

**Last updated:** 2026-07-10 (**AI Agent subsystem removal: AI14 Opus review DONE, verdict clean; committed & pushed (`924a814`)** — Opus independently re-reviewed Sonnet's whole diff and ran the verification Sonnet couldn't. Findings: (1) the `SettingsService.bas` indexed-key loop — the exact code class that caused the 2026-07-03 startup infinite loop — was handled correctly: `INDEXED_SETTINGS_SECTION_COUNT` 8→7 with the matching `AIAgents` `KeyExists` line removed, and the termination test uses the named constant (`-INDEXED_SETTINGS_SECTION_COUNT`), not a magic number, so count and condition can't drift; (2) the left tab control drops cleanly to 2 tabs (Project=0, Toolbox=1) with **no** hardcoded index access to it anywhere; (3) the Options dialog keys its pages by name, not contiguous index, so no page-index shift; (4) `mClick` dispatch is string-based — clean removal; (5) independent `git grep` sweep confirms the only remaining AI refs are in `src/Temp.bas` (verified not `#include`d and not in the `.vfp` manifest — inert). Clean release compile reproduced (0 errors, same 6 baseline warnings). **Launch smoke-test passed**: app starts, window titled "Visual FB Editor (64-bit)", `Responding=True`, and **0 ms CPU over a 3s idle window** — directly rules out a settings-loop spin regression. **Still recommended (owner):** a quick interactive click-through (left panel shows 2 tabs, Options dialog opens, menus intact) — no GUI-automation access this session, so visual confirmation is the one remaining gap. See "⭐ NEXT SUB-PROJECT" below.)

**Last updated:** 2026-07-10 (**AI Agent subsystem removal: AI1–AI13 done (Sonnet), compile-clean** — every AI-specific file, panel, menu, settings path, and shipped-default INI key removed; two gaps beyond the original scope found and fixed (`src/MD2RTF.bi`, a markdown→RTF converter with zero non-AI callers, deleted entire; a few dangling `AIService.bi` includes). 0 compile errors, only pre-existing baseline warnings. `git grep` sweep clean outside `src/Temp.bas` (confirmed not part of the build). THREADING.md and other docs updated. Committed from the owner's second machine and pushed; Opus reviewed on pull — see the AI14 entry above.)

This document captures project history, completed work, open items, and workflow rules for continuing development without re-discovering context.

---

## Current State (2026-07-10)

**The IDE compiles clean (0 errors, 0 warnings), runs stable, is renamed to AstoriaIDE, and is under active UX polish.**

| Area | Status |
|------|--------|
| **Core IDE** | Win64-only, compiles clean (0 errors, **0 warnings** as of `c93abbe`), self-hosted with bundled compiler (FBC 1.10.1) and GDB debugger |
| **Identity** | Renamed VisualFBEditor → **AstoriaIDE** (2026-07-10, `c93abbe`) — binary `astoria.exe`, settings `Settings/astoria.ini`, source/project files `AstoriaIDE.bas/.rc/.vfp`; see ROADMAP §13.4 |
| **Form Designer** | Working — grey-panel bug root-caused and fixed (2026-07-06); per-form control tree + PagePanel layer navigation shipped; Code/Form switching now via a top tab strip (`tcView`, 2026-07-10, `4b643af`), not toolbar toggle buttons |
| **Dark mode** | Stable and enabled — title bar, menus, toolbars, tabs, central area all render dark; popup menus deferred (§13.10) |
| **Dead code** | GTK/Linux/32-bit code physically deleted across `src/` and `mff/`; Integrated (stabs) debugger + alt-compiler backends removed; only `-gen gcc` remains |
| **UI review** | In progress — **File** menu owner-approved (incl. Open Project); **Edit** menu owner-approved (all 25 items); **Search** → Define (F2) reliability improved (committed with S1–S4); **13.3.A S1–S7 all Opus-reviewed and committed** (see §13.3.A execution below) — this already restructured the View menu (Fold submenu, Debug Windows split) as part of S1; **owner walkthrough/sign-off of the View menu** is the next step-by-step checkpoint |
| **Panels** | Left/right/bottom panel pin/collapse/persistence all fixed and verified |
| **Debugger** | GDB-only; Step, Continue, Break, Step Out, command queue, and debug-tab show/hide all working; 3 GDB items pending owner smoke test (§7) |
| **Build** | `Compile.bat` for release, `CompileDebug.bat` for debug; `NOPAUSE=1` for agent runs; output is now `astoria.exe` |

**Active work:** **§13.3 step-by-step UI review — next up: owner sign-off on the View menu** (File + Edit already signed off; the View-menu restructuring itself shipped as part of 13.3.A S1, so this checkpoint is a walkthrough/approval, not new design work). This is the resumed backlog after the AI Agent subsystem removal completed.

**Also active:** the **Fable review remediation queue (T1–T16, 2026-07-11)** — see "⭐ ACTIVE SUB-PROJECT — Fable review remediation" below for the execution order and per-model instructions. **Wave 1 (T8–T13) DONE; T1 decision gate DONE** — owner signed off **Option B: per-user install** (everything stays under `ExePath`; §13.5 installer targets `{localappdata}\Programs\AstoriaIDE`; T2 redefined to a startup writability probe + `Languages.txt` cleanup). **§13.5 is unblocked. Wave 3 is now fully DONE: T3 (PipeCmd rework), T4 (native project delete), T7 (unchecked writes), T2a (writability probe, plus an owner-found main-window-size regression fixed in the same session), T2b (`Languages.txt` cleanup), and T17 (English-only shipped-content sweep)** — all committed individually (owner changed Wave 3 from a batched hold to per-task commits, 2026-07-11). **T16 (Fable adversarial review) DONE 2026-07-11 — all 3 findings fixed same day (Sonnet)**: `Compile()`'s early return now replicates the common `StopProgress`/`CompileContextFree` exit; `DeleteProject` normalizes the path via `CanonicalWinPath` before `SHFileOperationW`; the Immediate-window exe launch is quoted. Compile-clean, launch-tested — see "T16 findings" below. Next up: **the owner smoke test** (list in the T16 row — Open Containing Folder, an External Tool, Delete Project, Options ▸ Apply, clipboard-preservation check, double-click a file with a registered External Editor), then Wave 4 (Opus: T5/T6 debugger).

The **AI Agent subsystem removal** (owner decision, 2026-07-09 — see "⭐ COMPLETED SUB-PROJECT" below) is **DONE**: AI1–AI14 complete, compile-clean, committed (`924a814`) and pushed, Opus-reviewed (`7e9c228`) and owner-reviewed (2026-07-10). With it closed, the sequencing hold it placed on the rest of the backlog is lifted — the §13.3 View-menu review and the deferred Phase F structural items (low priority) are unblocked.

Prior to that: Opus's "Next Steps" review (`Next Steps - Opus.md`, 2026-07-07) evaluated three prior AI reviews against the actual source and produced a verified, sequenced backlog. **Every phase is done and committed, including R5 (bounded GDB read, done 2026-07-08) and E1 (Apply dirty-tracking, done in a background-task worktree and merged into `main` 2026-07-08)** — see below. 13.3.A S1–S7 are **all committed** (Opus-reviewed). A Run-toolbar persistence regression the owner found post-S4 (my own S3 migration latching Run permanently visible) was root-caused and fixed 2026-07-07 — see the S5–S7 review outcome below.  
**Open items consolidated:** see [Open Items](#open-items) below.

---

## ⭐ ACTIVE SUB-PROJECT — Fable review remediation (queued 2026-07-11)

**Source:** full-project review by Fable (`claude-fable-5`), 2026-07-11 — report at [`Documents/fable_review.md`](../../Documents/fable_review.md); finding IDs (`F-S*` security/robustness, `F-R*` reliability, `F-C*` consistency/hygiene) refer to that document, which holds the full evidence and file/line detail for every task below. Verdict: the project is consistent with its design goals; nothing found contradicts an owner decision — several findings are *consequences* of owner decisions that now need follow-through (English-only leftovers, §13.5 installer prerequisites).

**Relationship to the existing backlog:**
- Does **not** displace the §13.3 View-menu walkthrough — that's an owner checkpoint needing no agent work, and can happen at any point during Waves 1–3.
- ~~**§13.5 (installer) is blocked on T1 + T2**~~ **Resolved 2026-07-11:** T1 signed off (Option B — per-user install; see the T1 row). §13.5 proceeds with Inno Setup `PrivilegesRequired=lowest` → `{localappdata}\Programs\AstoriaIDE` + a portable-zip artifact; `ExePath` writes stay as-is by design. T2a's writability probe is the guard for mis-placed installs.
- **T6 is the existing `set_bp` pipe-race Open Item, unchanged** — folded in here only for sequencing; its Opus assignment and attempt-#1 lessons (recorded in Open Items) stand.

**Standing gates for every task (§9 rules, restated):** compile-clean (0 errors, `Compile.bat` with `set NOPAUSE=1`) before handoff; cross-reference `git grep` sweep before deleting/moving anything — a clean compile is not sufficient; owner smoke test before committing anything that changes runtime behavior; commits only per the session-end rule; smallest correct diff, matching existing style. **Model-assignment check (§9):** if the session's model is not the one a task's row assigns, warn the owner of the mismatch before doing any work and proceed only on per-task confirmation.

### Execution order

> **Read the `Order` column, not the task numbers.** T-IDs (T1–T17) are stable labels from the review; they do **not** indicate sequence. E.g. T2 runs at position 11 (Wave 3, Sonnet), after T3/T4/T7 — not right after T1. Wave 3 was originally planned as one batch (T3 → T4 → T7 → T2a/T2b → T17, held uncommitted until T16). **Owner changed this 2026-07-11: commit each Wave-3 task individually** as it lands, matching this project's normal per-session commit convention (§9), rather than batching. **T16's adversarial review must therefore cover each Wave-3 commit individually** when it runs, not one combined diff.

| Order | Wave | Task | Model | Finding | Scope |
|---|---|---|---|---|---|
| 1 | 1 — hygiene | **T9 — Repo hygiene sweep** | Haiku | F-C2, F-C7 | Delete the `C:\Users\don\Downloads\AstoriaBridge.png` line (`src/Temp.rc:52`), then `git rm --cached` + gitignore `src/Temp.bas`, `src/Temp.rc`, `src/compile_out.txt`; add ignore rules for compiled example exes (`Examples/**/*64.exe`) and `Settings/Workspace.ini` |
| 2 | 1 — hygiene | **T10 — Clean shipped `Settings/astoria.ini`** | Haiku | F-C1 | Strip `RecentSession` (stale `D:\GitHub\...` path), the `[MRUFiles]`/`[MRUProjects]`/`[MRUSessions]` entry lists, and window-geometry keys from the *tracked* INI. Interim measure until T1/T2 lands the default-INI model |
| 3 | 1 — hygiene | **T11 — Delete unreachable Chinese data files** | Haiku | F-C4 | `Settings/Others/`: `Compiler options.chinese(Simplified).txt`, `Compiler options.chinese(Traditional).txt`, `KeywordsHelp.chinese(Simplified).txt`, `KeywordsHelp.chinese(Traditional).txt` — unreachable since C4 hard-set `App.CurLanguage = "English"` (`SettingsService.bas:242-245`). `git grep` consumer sweep first (expected: zero hits) |
| 4 | 1 — hygiene | **T8 — CI cleanup** | Sonnet | F-R3 | `.github/workflows/`: remove all three unverified downloads (7-Zip 9.20, FreeBASIC 1.10.0, upstream MyFbFramework `master.zip` — vestigial; the repo is self-contained by policy and CI should prove exactly that); `actions/checkout@v2`→`v4`; fail on compiler errors, not just output-file absence; converge on calling `Compile.bat` so CI and local builds can't drift |
| 5 | 1 — hygiene | **T12 — README refresh** | Sonnet | F-C5 | Drop the `Language: English` translation-table remnant; fix "Requirements: FreeBASIC 1.10.0+" (the compiler is bundled — that's the fork's pitch); fix the malformed MyFbFramework URL (`XusinboyBekchanov/Controls/MyFbFramework` — also present in §1 of this doc); flag the seven upstream-VFBE screenshots for owner replacement |
| 6 | 1 — hygiene | **T13 — Manifest + identity polish** | Sonnet | F-S6, F-C6 | `src/Manifest.xml`: `assemblyIdentity name="Form1"` → proper AstoriaIDE identity; uncomment `requestedExecutionLevel level="asInvoker"`; retitle `src/THREADING.md` ("Visual FB Editor" → AstoriaIDE); **version numbering: owner decided 2026-07-11 — reset to 1.0, upstream's numbering is not followed from now on** — update `src/AstoriaIDE.rc` (`VER_FILEVERSION` 1,0,0,0 / `VER_FILEVERSION_STR` "1.0.0.0" / `VER_PRODUCTVERSION` + `_STR` "1.0") and the matching `Manifest.xml` `assemblyIdentity version`. Launch check required after the manifest/rc change |
| 7 | 2 — decision | **T1 — User-data location decision memo** — ✅ **DONE 2026-07-11, owner signed off: Option B (per-user install)** | Fable | F-S4, F-C1 | Memo at [`Documents/fable_t1_settings_location.md`](../../Documents/fable_t1_settings_location.md). Full write-surface survey found 9 write clusters (3 beyond T1's original list: in-place **shipped-theme edits** `frmOptions.frm:3443+`, `<Project>_Change.log` at the IDE root `Main.bas:7063/8619/9481`, dead `Languages.txt` dumps `frmFind.frm:575`/`frmFindInFiles.frm:476`). **Owner decision: keep the portable model — everything stays under `ExePath`; the §13.5 installer targets `{localappdata}\Programs\AstoriaIDE` (Inno Setup, `PrivilegesRequired=lowest`, VS Code user-installer style, plus a portable-zip artifact). No APPDATA migration; no machine-wide/Program Files install offered.** T2 redefined accordingly (next row). Two deferred owner questions recorded in Open Items (`_Change.log` location; default `ProjectsPath` → Documents) |
| 8 | 3 — robustness | **T3 — `PipeCmd` rework** — ✅ **DONE 2026-07-11** | Sonnet | F-S1, F-S5 | Removed the `\|clip` suffix and the blanket `cmd /c` wrapper; `PipeCmd(cmd, UseShell:=False)` now runs commands directly via `CreateProcess`, shelling out only when `UseShell:=True` is passed. Added `CommandTargetIsBatchFile()` (`TabWindow.bas`) so user-configured External Tools still detect `.bat`/`.cmd` targets CreateProcess can't launch directly. Call sites: `frmTools.frm` (×2) auto-detect batch targets; `OpenUrl` and `OpenProjectFolder` replaced with `ShellExecuteW` "open" (fixes the `cmd`-splits-on-`&` bug, drops the shell entirely); the "Other Editor" double-click launch (`Main.bas`, found via full sweep — not in the review's original list) had a genuine UI-freeze bug — `PipeCmd`'s blocking wait ran synchronously on the UI thread, freezing the IDE until the external editor closed — fixed by routing through the existing `ThreadCreate_`/`ThreadCounter` worker pattern; the compile-probe (Immediate window) keeps `UseShell:=True` (needs `>`/`2>` redirection); a bare-exe launch site (`Main.bas:8404`, also found via the sweep, beyond the original list) simplified with no shell. **Delete Project** (`Main.bas:2830`, T4's territory) got only the mechanical signature adaptation (`UseShell:=True`, since `rd` is a cmd builtin) — delete logic untouched, flagged in a comment for T4. Also fixed a small pre-existing leak (the allocated command string was never deallocated). Compile-clean + launch check passed. **Committed individually** (owner requested per-task commits rather than the batched Wave-3 hold — T16's review will need to cover this commit specifically) |
| 9 | 3 — robustness | **T4 — Native project delete** — ✅ **DONE 2026-07-11** | Sonnet | F-S2 | Replaced the shell `rd /s /q` with `SHFileOperationW` (`FOF_ALLOWUNDO` — Recycle Bin, not permanent delete); failure now surfaces via `MsgBox` per F1 and `DeleteProject` returns `False`. `ChDir ExePath` guard preserved untouched. Verified with a standalone test program against a disposable nested folder (return code, Recycle Bin landing confirmed via `Shell.Application`) — full in-app click-through deferred to T16's owner smoke test (no GUI access this session). See "Last updated" above for detail |
| 10 | 3 — robustness | **T7 — Check the 6 remaining unchecked `Open For Output` writes** — ✅ **DONE 2026-07-11** | Sonnet | F-R2 | Guarded all 6: `BuildService.bas:259`, `frmImageManager.frm:398`, `frmOptions.frm:3119`, `frmTools.frm:241`, `Main.bas:8364` (shifted from the review's `:8326`), `TabWindow.bas:2884`. `BuildService.bas:259` runs on `Compile()`'s worker thread (`THREADING.md`), so used `ShowMessages` instead of a raw `MsgBox` per rule 3 (no marshaling helper exists) — the other 5 are UI-thread handlers, direct `MsgBox` as specified. See "Last updated" above for the two silent-corruption risks also fixed in `frmTools.frm`/`frmOptions.frm` while placing the guards |
| 11 | 3 — robustness | **T2 — Portable-model safety net (redefined by T1 sign-off, 2026-07-11)** — ✅ **DONE 2026-07-11 (both halves)** | Sonnet | F-S4 | **T2a:** startup writability probe (real `Open For Output` against `Settings/.writetest`, not just an ACL check) right before `LoadSettings`; on failure, one `MsgBox` and `End 1`. Verified both directions (normal launch silent; write-denied copy via `icacls` correctly blocked). Also fixed an owner-found regression hit during testing: blank `Width=`/`Height=` in `astoria.ini` read as `0` (vendored `IniFile.ReadInteger` only defaults on absent keys, not empty ones) — restored the data and added a floor guard in `Main.bas`. **T2b:** deleted the dead `Languages.txt` write sites (`frmFind.frm:575`, `frmFindInFiles.frm:476` — translation-era debug dumps, meaningless post-C4); the `tML` guard/parse logic used elsewhere in the same subs was left untouched (unrelated to the dead write). `git grep` sweep confirmed zero remaining `Languages.txt` references. Compile-clean + launch check passed for both. **No settings-path changes; `SettingsService`/startup load order untouched** |
| 12 | 3 — robustness | **T16 — Adversarial review of Wave 3** — ✅ **DONE 2026-07-11 (Fable)** | Fable | — | Reviewed all five Wave-3 commits individually (T3 `4394ca2`, T4 `1fbb944`, T7 `cda99f8`, T2a `8d04929`, T2b+T17 `e83212f`) against injection, paths-with-spaces, failure paths, clipboard, threading. **3 findings for Sonnet (F-T16-1 confirmed bug, F-T16-2/3 hardening) + 5 no-action notes — see "T16 findings" below.** Clipboard clobber confirmed fully gone; T2b/T17 renumbering verified against `SettingsService`'s loop; local rebuild compile-clean. **Owner smoke test still owed:** Open Containing Folder, an external tool from Tools ▸ External Tools, Delete Project (on a disposable project), Options ▸ Apply, a clipboard-preservation check (copy text → do the above → paste), and double-clicking a file with a registered External Editor (T3's UI-freeze fix) |
| 13 | 4 — fragile core | **T5 — Quote the GDB path in the debugger launch** | Opus | F-S3 | `Debug.bas:1691` → `CreatePipeD` (`Debug.bas:436`): `szCmd` (path to bundled `gdb.exe`) is concatenated unquoted into `lpCommandLine` — breaks (or resolves the wrong binary) once installed to a path with spaces. Quote it or pass as `lpApplicationName`. Full live debug smoke test (breakpoint → step → variables → continue → stop), same bar as R5; if feasible, test from a copy of the repo at a path containing a space |
| 14 | 4 — fragile core | **T6 — `set_bp` pipe race, attempt #2** | Opus | F-R1 | Existing Open Item, unchanged — follow its recorded attempt-#1 lessons: gate break-command sends on `Not Running`; never hold `tlockGDB` across a blocking read; move the comment-line check ahead of `set_bp`; instrument with file-trace and get an owner repro **before** changing code |
| 15 | 5 — close-out | **T14 — PROJECT_STATUS.md consolidation pass** | Opus | F-C3 | After Waves 1–4 land: resolve the frmNewProject-icons vs. B2-closed contradiction in Open Items; merge the six "Last updated" blocks into one; refresh the stale "Basic CI" open item (CI exists; T8 reworked it); archive completed sub-project detail (AI removal task list, C4 transform detail, this section once done) to HISTORY.md per the doc's own maintenance policy; fix the self-reported line count |
| 16 | 5 — close-out | **T15 — Theme-catalog owner question** | Fable | F-C6 | The IDE ships ~115 editor themes (`Settings/Themes/`) vs. the "don't give the user unnecessary options" principle — present a curated-shortlist option (e.g. 6–10 best light/dark) to the owner. Decision memo only; **no action without owner sign-off.** Can run at any point |
| 17 | 1 — hygiene (addendum, added 2026-07-11 per owner reminder) | **T17 — English-only shipped-content sweep** — ✅ **DONE 2026-07-11** | Sonnet | F-C4 follow-through | Deleted `Help/FB-manual-ru_RU-1.00.0.chm/.chw`, `Help/FB-manual-zh_CN-1.09.0.chm/.chw`, `Help/FB-manual-de_DE-1.00.0.chm/.chw`, `Help/Win32SDK.chinese.chm`, and `Help/Tip of the Day/chinese(Simplified).tip`, `chinese(Traditional).tip`, `french.tip` — confirmed unreachable via sweep (`App.CurLanguage` hard-set `"English"`, `frmTipOfDay.frm:168-169` falls back to `english.tip`), zero other references found. Removed the ru/zh/de entries from the shipped INI's `[Helps]` catalog and **renumbered contiguously** (`en_US` stays `Version_0`; `win32_fb`/`VisualFBEditor`/`MyFbFramework` shifted to `1`/`2`/`3`) — confirmed the Options-dialog `[Helps]` writer (`frmOptions.frm:3210-3224`) is actually self-healing regardless (rewrites the whole section from the in-memory list, cleans up stale trailing keys), but renumbered anyway for a clean shipped default per the indexed-key caution. `DefaultHelp` unchanged (still points at `en_US`, still valid). Compile-clean + launch check passed — confirmed the renumbered `[Helps]` section survived a real run unchanged. **Out of scope (prior recorded decision, untouched):** `.lng`/language assets under `Controls/MyFbFramework/examples/**`, `Examples/**`, and `Tools/**` — third-party demo apps' own translations, not IDE capability |

### T16 findings (Fable, 2026-07-11) — for Sonnet follow-up commits

**Findings (fix before the owner smoke test):**

- ~~**F-T16-1 — `Compile()` early return skips cleanup**~~ — ✅ **fixed 2026-07-11 (Sonnet)** *(T7, `BuildService.bas:268`, confirmed bug, medium).* The new guard's `Return 0` on a failed batch-file rewrite is the **only** early `Return` in the whole function. `StartProgress` has already run (line 62), and the common exit (lines 477–479) is what calls `StopProgress` and `CompileContextFree(ctx)` — so this path leaves the status-bar progress marquee spinning forever and leaks the compile context's allocations. Every other failure in this function sets `CompileResult = 0` and falls through. **Fix:** before `Return 0`, replicate the common exit (`ThreadsEnter() : StopProgress : ThreadsLeave() : CompileContextFree(ctx)`), or restructure to fall through. *Failure scenario: mark a project's batch compilation file read-only, hit Build → Output message appears, but the progress bar never stops for the rest of the session.*
- ~~**F-T16-2 — normalize the delete path for `SHFileOperationW`**~~ — ✅ **fixed 2026-07-11 (Sonnet)** *(T4, `Main.bas` ~2833, hardening, low).* `ProjectPath` is handed to `SHFileOperationW` unnormalized. Shell APIs don't reliably accept forward slashes, and this codebase mixes `/` and `\` freely — `OpenProjectFolder` normalizes with `Replace(..., "/", "\")` for exactly this reason before its own shell call. Failure mode today is loud (the new MsgBox), not silent, but it's a one-line `CanonicalWinPath(ProjectPath)` (PathUtils) to make delete work regardless of where the project path came from.
- ~~**F-T16-3 — quote the Immediate-window exe launch**~~ — ✅ **fixed 2026-07-11 (Sonnet)** *(T3, `Main.bas` ~8407 `PipeCmd *ExeName`, hardening, low-medium).* `ExePath\Temp\FBTemp.exe` is passed to `CreateProcess` **unquoted**; the old code's `cmd /c "..."` wrapper effectively quoted it. If the IDE lives at a path with spaces (portable unzip to e.g. `C:\My Tools\`), CreateProcess's progressive token resolution applies — the classic unquoted-path hijack pattern, same class as T5's GDB finding. **Fix:** `PipeCmd """" & *ExeName & """"`. (T1's installer target `{localappdata}\Programs\AstoriaIDE` has no spaces, but the portable zip can land anywhere.)

**Notes (no action — pre-existing or accepted behavior, recorded so T5/T6 and future work know):**

- **N1 (T3):** `CommandTargetIsBatchFile` mis-classifies an *unquoted* `.bat` path containing spaces (first-token heuristic) — unreachable in practice: `GetCommand` always quotes the program path, and CreateProcess itself falls back to launching `.bat` via cmd.exe. The helper's comment ("CreateProcess can't launch those directly") is technically inaccurate, but explicit shell routing is *safer* than relying on CreateProcess's implicit cmd spawn (the BatBadBut argument-injection pattern), so keep it.
- **N2 (T3, pre-existing):** External-Tool `{S}`/`{E}`/`{F}` substitutions insert paths unquoted unless the user's parameter template quotes them — a path with spaces splits into multiple args. Unchanged by T3.
- **N3 (T3, pre-existing):** `WaitComplete` external tools intentionally block the UI thread (`ExecuteToolInMainThread` → `PipeCmd`'s `INFINITE` wait), and `PipeCmd`'s failure MsgBox can fire from worker threads (`ExecuteTool` path) — a standing THREADING.md rule-3 tension that predates T3.
- **N4 (T4):** with `FOF_NOCONFIRMATION`, a folder too large for the Recycle Bin is permanently deleted with no extra prompt — acceptable (the user already confirmed the delete), but the Recycle-Bin safety net is not absolute.
- **N5 (T2a):** two simultaneous launches can race on the same `Settings/.writetest` probe name; the loser gets a spurious "can't write" MsgBox. Milliseconds-wide window, benign outcome (relaunch works).

### Per-model instructions

- **Haiku (T9–T11):** strictly mechanical — no source-code edits beyond deleting the one specified line in `src/Temp.rc`. Run the cross-reference `git grep` sweep before each deletion/untrack; if a sweep turns up an unexpected consumer, **stop and record it in this section rather than improvising**. After all three tasks, run `Compile.bat` once (`set NOPAUSE=1`) to prove the build references nothing removed. Do not touch `Controls/MyFbFramework/examples/**` — framework example assets (including their `.lng` files) are out of scope by prior decision.
- **Sonnet (T2–T4, T7, T8, T12, T13):** one task = one contained diff, compile-clean per task. **All tasks (Wave 1 and Wave 3) commit individually** once verified, per the session-end rule (§9) — owner decided 2026-07-11 against batching Wave 3 behind a combined hold. T16 (Fable) still reviews the Wave-3 commits as a set once T4/T7/T2/T17 land; a smoke test then covers: Open Containing Folder, an external tool from Tools ▸ External Tools, Delete Project (on a disposable project), Options ▸ Apply, a clipboard-preservation check (copy text → do the above → paste), and double-clicking a file with a registered External Editor.
- **Opus (T5, T6, T14):** fragile-core bar — live verification with the owner and file-trace over guesswork, per the R5/attempt-#1 precedents. T5 and T6 both touch `Debug.bas`; run them sequentially against a settled tree (after Wave 3) so debugger testing happens once.
- **Fable (T1, T15, T16):** decision memos go to `Documents/` and require owner sign-off before any implementation task consumes them. T16 is an adversarial review, not a rubber stamp — actively try to break the combined diff (injection via file/tool names, paths with spaces, failure-path behavior, clipboard side effects, UI-thread blocking); findings return to Sonnet before any commit.

---

## ⭐ COMPLETED SUB-PROJECT — AI Agent subsystem removal (owner-approved 2026-07-09, DONE 2026-07-10)

**DONE.** All AI removal tasks (AI1–AI14) complete, compile-clean, committed (`924a814`) + pushed, Opus-reviewed (`7e9c228`) and owner-reviewed. The sequencing hold this placed on the rest of the backlog is lifted; next active item is the §13.3 View-menu review. Owner call on AI10's `VisualFBEditor IDE Environment.md`: **delete** (declined restore, 2026-07-10) — recoverable from git history at `924a814^` if ever wanted. Task detail retained below for the record.

**Owner decision (2026-07-09):** remove the built-in AI Agent subsystem from the IDE entirely. This **reverses the earlier 2026-07-03 "13.7 Enhance AI integration" plan** — it was **the owner's own decision** to reverse that direction. Rationale: a self-maintained multi-provider AI client (OpenAI/DeepSeek/Claude/Mistral/Ollama/OpenRouter, streaming + context management) is a whole subsystem to maintain that isn't this tool's focus, and external tools (Claude Code, Cursor, DeepSeek-based tools) are advancing far faster than a solo-maintained internal client could track — the same anti-scope-creep discipline that motivates this fork. The `ROADMAP.md` §13.7 section is marked REVERSED with the full reasoning.

**Scope decisions (owner-confirmed):**
- **Remove all vestiges of AI in all locations** — code, forms, settings, resources, docs.
- **Keep `Examples/AiAgent/`** — a third-party MyFbFramework control demo (CM.Wang, ©2025), independent of the IDE's built-in feature; it is itself an example of the "wire your own external AI" pattern.
- **No new AI launcher feature.** A purpose-built external-AI launcher was evaluated and **dropped as redundant**: the existing **Tools ▸ External Tools** dialog (`frmTools.frm`) already lets users register any external program (path + parameters + file-extension association), which is exactly the "users can add AI agent links to external tools" path the owner intended. Nothing to build.

**Why this is one atomic pass (not stageable):** the AI state globals live in `src/Main.bi` and are referenced across four core files, so there is no half-removed state that compiles. Work stays uncommitted until compile-clean **and** owner smoke-test (this project's standard gate), then commits as one change.

### Tasks (execute in order AI1 → AI14)

Each task below is a discrete definition. Owner = who should do it (**Sonnet** = mechanical/contained execution; **Opus** = judgment calls, reasoning-bearing docs, and review).

- **AI1 — Delete the AI-specific files.** Remove `src/AIService.bas` (823 lines), `src/AIService.bi` (22), `src/frmAIAgent.frm` (594), and `Resources/AIAgent/*.ini` (`Address.ini`, `Host.ini`, `ModelName.ini`, `Provider.ini` — dropdown seed lists for the deleted config dialog). **Owner: Sonnet.**
- **AI2 — Update the project manifest.** Remove the three `File=` entries (`AIService.bi`, `frmAIAgent.frm`, `AIService.bas`) from `src/VisualFBEditor.vfp`. **Owner: Sonnet.**
- **AI3 — Remove the dangling includes.** Delete `#include once "frmAIAgent.frm"` from `src/Temp.bas:9` (this — not the manifest — is the form's actual compile path) and `#include once "AIService.bi"` from `src/Main.bi:289`. **Owner: Sonnet.**
- **AI4 — Remove the AI global-state block from `src/Main.bi`.** The ~10-line `Common Shared` cluster: `pHTTPAIAgent`, `bAIAgentFirstRun`, `AIAgentPort`, `AIAgentContentSize`, `AIAgentStream`, `AIAgentTop_P`, `AIAgentTemperature`, `AIAgentHost/Address/APIKey/ModelName/Provider/Name`, `AIRTF_HEADER`, `AIEditorFontName`, `DefaultAIAgent`, `CurrentAIAgent`, and the `pAIAgents` Dictionary. Referenced by all four core files — miss any and the build breaks with undefined symbols. **Owner: Sonnet.**
- **AI5 — Remove the AI chat panel + tab + chat MRU from `src/Main.bas`** (~169 refs — the largest single edit; the chat panel UI lives here, not in a form). Includes the `pnlAIAgent` left-panel tab (3rd tab, `tabLeft` index 2) and the `AIChat*` recent-chat file logic. **Owner: Sonnet (draft) → Opus spot-review of the diff before compile.**
- **AI6 — Remove the AI Agent Options page** from `src/frmOptions.frm` (~213 refs) and its implementation in `src/Temp.bas`. Verify removing the `pnlAIAgent` page does not mis-renumber sibling page `TabIndex`es. **Owner: Sonnet.**
- **AI7 — Remove the AIChat menu dispatch from `src/VisualFBEditor.bas`** (~80 refs): the `mClickAIChat` handler and its `AIChatEdit`/`AIChatPaste`/`AIChatPasteCode`/`AIChatOpen`/`AIChatSave`/`AIChatSaveAs` cases (the "Recent AI Chat" save/load-as-`.md` feature). **Owner: Sonnet.**
- **AI8 — Remove AI settings from `src/SettingsService.bas`** (~51 refs): `SeedDefaultAIAgents` and all AI agent load/save (host/port/key/model/temperature/provider). **Owner: Sonnet.**
- **AI9 — Clean the shipped default INI.** Strip `AIAgentParent`/`AIAgentIndex`, the `[AIAgents]` section (`DefaultAIAgent=...`), and `[MRUAIChat]` from `Settings/VisualFBEditor64.ini` so a fresh install ships no AI residue. Do **not** migrate existing users' own INIs. **Owner: Sonnet.**
- **AI10 — Delete `Help/AI prompt/`** (`KnowledgeBase/VisualFBEditor IDE Environment.md` + `MyFbFramework GUI Form Interface Guidelines.md/.json`) and `Resources/KnowledgeBase.png` — these existed solely to feed the AI's context. *(Note for owner: the 2,874-line `VisualFBEditor IDE Environment.md` is a full menu/feature reference that has standalone value as maintainer documentation; if you'd rather keep it, relocate it out of the AI folder instead of deleting. Default per "remove all vestiges": delete.)* **Owner: Sonnet, pending that one-line owner call.**
- **AI11 — Compile-clean gate + owner smoke-test.** Build clean (0 errors); confirm the left panel now shows 2 tabs (Project/Toolbox, no AI Agent); Options has no AI Agent page; no orphaned AI menu items or dispatch cases; app launches and runs. **Owner: Sonnet (run) → Opus verify.**
- **AI12 — `git grep` stale-reference sweep** for every removed symbol (`AIAgent`, `AIService`, `AIChat`, `AIMessages`, `AIRequest`, `SeedDefaultAIAgents`, `frmAIAgent`, `bInAIThread`, `pAIAgents`, `pHTTPAIAgent`) across `src/` — the project's "clean compile is not sufficient" rule. Zero hits expected (outside `Examples/AiAgent/`). **Owner: Sonnet.**
- **AI13 — Documentation cleanup.** Remove the AI Agent row from `src/THREADING.md`; drop/strike backlog item **C3** ("move Recent AI Chat into AI Agent panel" — now moot); update any Options keep-lists that still name "Help/AI Agent"; confirm no PROJECT_STATUS.md / ROADMAP.md section still describes AI as present or planned. **Owner: Opus** (records reasoning, not just deletion).
- **AI14 — Final full-diff review, then commit (single atomic commit).** Confirm no stray refs, coherent message, `.exe` rebuilt. **Owner: Opus.**

**Opus start-tasks (done 2026-07-09, this session):** scoping + evaluation ([`Documents/sonnet_ai_recommendation.md`](../../Documents/sonnet_ai_recommendation.md)), this sub-project write-up, the §13.7 reversal in ROADMAP.md, and committing/pushing the pre-existing working state (Help ▸ GitHub menu removal) to GitHub. **No further Opus setup is required before AI1** — Sonnet can begin the removal.

**Progress (Sonnet, 2026-07-10): AI1–AI13 done.** All AI-specific files/resources deleted (`AIService.bas/.bi`, `frmAIAgent.frm`, `Resources/AIAgent/*.ini`, `Help/AI prompt/` incl. `KnowledgeBase/`, `Resources/KnowledgeBase.png`); manifest and all dangling includes cleaned (`VisualFBEditor.vfp`, `Main.bi`, `frmOptions.frm`); the AI global-state block, chat panel/tab, Options page, menu dispatch, and settings load/save all removed from `Main.bas`/`Main.bi`, `frmOptions.frm`/`.bi`, `VisualFBEditor.bas`, `SettingsService.bas`; shipped default `Settings/VisualFBEditor64.ini` stripped of `[AIAgents]`/`[MRUAIChat]`/`AIAgentParent`/`AIAgentIndex` (existing users' own INIs untouched, per plan). **Two gaps found beyond the original scope, both fixed:** (1) `src/MD2RTF.bi` (a ~650-line markdown→RTF converter) turned out to exist solely to render AI chat responses — zero non-AI callers found via `git grep` — so it was deleted too, along with its `#include` in `TabWindow.bi` and its manifest entry; (2) a handful of dangling `#include`s (`AIService.bi` in `Main.bi` *and* `SettingsService.bas`) that the original per-file line-count scope didn't anticipate. **AI11 compile gate: passed** — 0 errors, only the same pre-existing baseline warnings (2 `warning 34` parser quirks + 4 `frmFindInFiles.frm` warnings already documented above). **AI12 sweep: clean** — zero stale references to any removed AI symbol across all *compiled* source; the only hits are in `src/Temp.bas`, which is not part of the build (not `#include`d, not in the `.vfp` manifest — confirmed a Designer-regenerated scratch duplicate of `frmOptions.frm`, matching this doc's existing note elsewhere that `Temp.bas` isn't real source) and was correctly left untouched. **AI13: THREADING.md's AI Agent row/rules removed and renumbered; C3 was already struck/superseded from the prior Opus session; no stale "Help/AI Agent" keep-list found (already resolved by earlier edits); all §13.7 references confirmed marked REVERSED.** **Partial verification done:** fresh launch + process-alive check (4s, no crash) — same minimal check used elsewhere in this doc. **Full visual/interactive owner smoke-test still not done** (no GUI/computer-use access this session): left panel showing 2 tabs not visually confirmed, Options dialog not opened, no click-through of menus. Needed before AI14's commit. AI14 (final diff review + commit) not yet done, held for Opus per the original design or owner instruction.

---

## Opus "Next Steps" backlog — all phases done (2026-07-08)

Executes Phase A, item 5 (P1), Phase B (P2/P3), Phase C (U1/U2, U3/U4, event-handler cluster, `.lng` decision), Phase D (F1, F2), and Phase E (O1, O2, O3, E1) of `Next Steps - Opus.md`'s consolidated, source-verified backlog (Opus cross-checked three prior AI reviews — Cursor, Deepseek, Sonnet — against the actual code before sequencing this plan; see that document for full methodology and the discarded/unsubstantiated claims). R5 (needed live GDB reproduction) and E1 (large rewrite, spun off as its own background task) were the last two items; both are now done.

| ID | Fix | Location | Verified |
|----|-----|----------|----------|
| **R1** | `LoadFunctions` bare `Return`s skipped `MutexUnlock tlockSave` under an allocation-failure path — real (if rare, OOM-gated) whole-IDE deadlock. Added `MutexUnlock tlockSave` before both early returns. | `src/Main.bas:3175-3181` | Compile-clean + launch check |
| **R2** | `SaveProject`'s two `Open ... For Output` calls ignored the result — a missing/read-only project folder silently no-op'd the save. Both now check the result and show a plain MsgBox + return `False` on failure. | `src/Main.bas:1637, 1652` | Compile-clean + launch check |
| **R4** | `PipeCmd`'s `CreateProcess` result was discarded, so a failed launch still called `WaitForSingleObject`/`CloseHandle` on invalid handles. Now checked before use, matching the pattern already used in `Debug.bas`'s debuggee launch. | `src/TabWindow.bas:10902-10908` | Compile-clean + launch check |
| **R3** | `AIResetContext` ("New Chat") could restart the AI thread while a previous request was still in flight — a race over shared globals (`AIBodyWStringPtr` etc. deallocated mid-use). Gated the Sub on `bInAIThread`, mirroring the guard `txtAIRequest_Activate` (the send path) already uses. | `src/AIService.bas:783-787` | Compile-clean + launch check |
| **P1** | `AIRelease` and `AIResetContext` both called `Sleep(500)`/`Sleep(300)` on the **main UI thread** while waiting for the aborted AI request thread to unwind — a visible stutter on every Stop/New-Chat click. Moved each tail (the delay + the state reset / thread restart) into a small helper Sub run on its own worker thread (`AIReleaseFinish`, `AIResetContextFinish`), so the UI thread returns immediately. Same effective delay, no main-thread block. | `src/AIService.bas:758-781` | Compile-clean + launch check |
| **P2** | `Suggestions`'s first-run project-content preload called `LoadFunctions` synchronously per file on the calling (UI) thread — could stall the UI for the duration of reading every project file. Replaced the inline call with `ThreadCounter(ThreadCreate_(@LoadOnlyFilePathOverwriteWithContent, ecc))`, the same background-worker wrapper already used for this exact `LoadFunctions` mode elsewhere (`Main.bas`'s `AddFolder`/project-open path). `LoadFunctionsCount`'s existing "IntelliSense is not fully loaded yet" messaging (already downstream in the same Sub) now covers the async case for free. | `src/TabWindow.bas:8169-8174` | Compile-clean + launch check |
| **P3** | `FormatProject` (already background-threaded, per `THREADING.md`) disabled the **entire main form** (`pfrmMain->Enabled = False`) for the whole project-wide format/unformat pass, blocking every menu, panel, and toolbar rather than just the two things it actually mutates (open-tab content and the project tree). Traced what the Sub touches — it walks live `TreeNode`s under the project root and directly edits any open tab's `txtCode` for project files — and narrowed the disable to just `ptabCode` (tab strip/editors) and `ptvExplorer` (project tree), the exact resources at risk of a concurrent edit. Other panels (AI Agent, Output/Problems, menus not tied to editing) stay usable during a format pass. | `src/TabWindow.bas:157-203` | Compile-clean + launch check |
| **U1** | Three Debug.bas user-facing messages rewritten in plain, calm language, and the raw "gdb" name replaced with "the debugger": the "gdb not found" and "source file not executable" errors, the `hard_closing` crash dialog ("Sorry an unrecoverable problem occurs... Report to dev please" → "The debugger ran into a problem and had to stop."), and the Stop-debuggee confirm (dropped the all-caps "USE CARREFULLY SYSTEM CAN BECOME UNSTABLE, LOSS OF DATA, MEMORY LEAK" for a calm one-liner about unsaved data). | `src/Debug.bas:1646, 1658, 2369-2373, 2377-2380` | Compile-clean + launch check |
| **U2** | Fresh-install startup landed on a completely empty IDE. Traced the actual cause: `WhenVisualFBEditorStarts` has no Options UI to set it (stays 0 forever) and `LoadWorkspace()` no-ops silently when `Settings/Workspace.ini` doesn't exist yet — the "commented-out" framing in the prior AI reviews was imprecise, but the empty-IDE symptom was real. **Owner decision (2026-07-07):** keep reopening the last project when one exists; open a starter project only when there's nothing to reopen. Implemented by checking `LoadWorkspace()`'s own return value (already `True`/`False` for "did anything actually load") and falling back to the same `AddNew` starter-template call the (unreachable) `WhenVisualFBEditorStarts` branch already used. | `src/Main.bas:9242-9249` | Compile-clean + launch check (fresh-install path not exercised live — needs owner test with `Workspace.ini` removed) |
| **U3/U4** | Wording-only pass (no behavior/default changes): "Use Direct2D (For Windows)" → "Smoother text rendering (Direct2D)"; "Auto create resource and manifest files (.rc, .xml)" → "Automatically create the icon and manifest files needed to build"; "Update all language file (*.lng)" → "Update all language files"; casing fix "Intellisense limit" → "IntelliSense limit". Left `AutoComplete` vs `AutoSuggestions` naming alone — traced them to genuinely different features (inline completion dropdown vs. project-wide analysis), so merging their labels risked hiding a real distinction rather than just cleaning up drift. | `src/frmOptions.frm:803, 533, 2028, 1936` | Compile-clean + launch check |
| **U3 (event-handler cluster)** | **Owner decision (2026-07-07):** collapse the Designer's 4-checkbox "static event handler" cluster to one simple choice, per the "single toggle over independent flags" rule — today's defaults become the "modern" preset. Traced the actual codegen first (`TabWindow.bas` ~3455-3521): all 4 flags interact in genuinely nuanced ways across several branches (non-static vs. static handler generation, placement, naming, and a `Declare Static` companion line generated alongside even in the non-static path). Given that real complexity in code sitting near the historically fragile Designer/`FormDesign` area, did **not** touch `TabWindow.bas`'s codegen logic at all — zero risk there. Instead hid the 3 secondary checkboxes (`.Visible = False`, same low-risk pattern already used in S6) and relabeled the primary one "Event handlers: Non-static (modern)" so it reads as the single governing choice; their INI-backed defaults (already matching "today's defaults") are now fixed rather than user-toggleable. | `src/frmOptions.frm:1715, 1985, 1994, 2343` | Compile-clean + launch check (**Options ▸ Designer page layout not visually confirmed — hiding absolutely-positioned controls leaves blank gaps rather than reflowing, same caveat as S4's field removal**) |
| **U3 (.lng maintenance)** | **Owner decision (2026-07-07): English only going forward** — the 15+ `.lng` translation files inherited from upstream are not considered an active maintenance obligation for this fork. No code changed this session (owner explicitly deferred the Options-dialog simplification — hiding/relabeling the language picker and `.lng` maintainer tools — to a future pass); recorded here so future caption-rename work (e.g. a View-menu relabel) doesn't need to preserve non-English `.lng` lookups or re-ask this question. | N/A (decision only) | N/A |
| **F1** | Wrote down the feedback-channel policy Opus asked for (status bar = transient state; Output/Problems = background events, non-intrusive; `MsgBox` = irreversible/blocking only) as a new guiding principle, to apply opportunistically rather than as a big-bang sweep. See "Guiding principle: feedback-channel policy" above. | `PROJECT_STATUS.md` (this doc) | N/A (doc only) |
| **F2** | Two previously-silent failure paths now give a visible reason, per the new F1 policy. (1) `TabWindow.FormDesign`'s 50,000-line Designer cutoff exited with zero feedback — now sets a status-bar caption before bailing. (2) `LoadFunctions`'s missing-include case (all 4 `Open` attempts fail) fell through silently, leaving that header's symbols permanently absent from IntelliSense with no clue why — now logs to the Output panel (`ShowMessages(..., False)`, no tab-switch) *without* spamming: traced `GetRelativePath` first and confirmed it already searches the source file's folder, `ExePath`, every control library's include folder, the bundled compiler's own `inc/` folder, and any configured include paths before giving up — so this only fires on a genuinely unresolvable include (typo/deleted file), not on ordinary system headers. | `src/TabWindow.bas:8374-8378`, `src/Main.bas:3208-3214` | Compile-clean + launch check |
| **R5 — done (2026-07-08, owner-verified)** | GDB's `readpipe` (`Debug.bas`) blocked on a plain synchronous `ReadFile` with no timeout — worker-thread-scoped. **Fix:** poll with `PeekNamedPipe` before each read; the debug worker thread now bails on **app close** (`FormClosing`) or a **broken pipe** (GDB terminated/crashed) instead of stalling. The broken-pipe bail also fixes a latent **tight infinite loop** the old code hit when the pipe broke (repeated 0-byte reads). Data-available behavior is byte-for-byte unchanged, so normal debugging is unaffected. **Owner-verified:** full debug session (breakpoint → step → variables → continue → stop) works. Did **not** attempt a response-timeout ("surface a hung GDB mid-session") — that risks false positives on slow-but-legit GDB commands and needs a reproducible hang to tune; left as a possible follow-up. | `src/Debug.bas:447-513` | Compile-clean + owner live-test |
| **O1** | **Owner decision (2026-07-07):** trim the default AI catalog to a small, recognizable set + the existing "Add AI Agent" button for anything else, instead of seeding all 29 models. `SeedDefaultAIAgents` now seeds 3: the app's own default (`*DefaultAIAgent`, a free OpenRouter DeepSeek model), a free Google Gemini model via OpenRouter, and DeepSeek's own direct API — one aggregator example, one recognizable brand, one direct-API example. The manual "Add AI Agent" button (`cmdAddAIAgent`, already existed) covers everything else. | `src/SettingsService.bas:123-129` | Compile-clean + launch check |
| **O3** | **Owner decision (2026-07-07):** remove the Android/ADB deploy code — out of scope for this Win64-only, desktop-BASIC-hobbyist fork. Removed `RunPr`'s entire Gradle/`local.properties`/ADB branch (install/uninstall/launch via `adb`) along with the now-unreferenced `RunEmulator` and `RunLogCat` worker Subs (~285 lines total). The `.vfp` backward-compat fields (`ppe->AndroidSDKLocation`/`AndroidNDKLocation`, read/written for old project files) were deliberately left alone, matching the same precedent as S4's `IconResourceFileName` — harmless orphaned struct fields, not active build logic. | `src/TabWindow.bas` (formerly ~11516-11674, ~11917-12040, ~12196) | Compile-clean + launch check |
| **E1 — done (2026-07-08, merged from background task)** | `frmOptions.cmdApply_Click` wrote all ~296 INI keys (`piniSettings`/`piniTheme`) unconditionally on every Apply click — 96 distinct `WriteXxx` call sites, several inside loops (AI agents, terminals, other editors, help paths, include/library paths) and a large theme-colors block, none checking whether the value actually changed. Traced `IniFile.WriteXxx` (`Controls/MyFbFramework/mff/IniFile.bas`) and confirmed every write triggers a full-file disk rewrite (`Update` → `SaveToFile`) regardless of whether anything changed. Added 4 small dirty-check helpers (`IniValueChangedBool/Int/Float/Str`, `src/frmOptions.frm` just above `cmdApply_Click`) that compare the new value against what's already in the INI (`KeyExists`/`ReadXxx`, in-memory lookups — no disk I/O) before allowing a write; every `WriteXxx` call site is now wrapped `If IniValueChanged...(...) Then ... End If`. Generated mechanically (a one-off Python transform) so all ~295 sites got identical, verified treatment; sampled AI-agent-loop, IIf-laden theme-color, and hex-flag `WriteInteger` sites by hand to confirm correctness. **Gotcha found and fixed:** inlining the guard logic at each site (rather than via shared helpers) ballooned the generated C function to ~8000 lines and crashed the `gcc` backend at `-O2` with zero diagnostic output — factoring the repeated logic into the 4 shared helpers fixed it. Merged into `main` 2026-07-08 (`cbc71d1`); **not yet launch-tested against a real Options ▸ Apply click** — needs owner live verification before being trusted (see note below on this task's own compile-clean environment quirk). | `src/frmOptions.frm` (helpers + ~400-line `cmdApply_Click` body) | Compile-clean (merge build) — **owner live-test of Options ▸ Apply still needed** |

**Verification performed:** compile-clean after each fix (0 errors; same 4 pre-existing `frmFindInFiles.frm` warnings throughout) + release-build launch/process-alive check after each. **Not verified this session** (no GUI/computer-use access): live click-through of Save-failure messaging, AI Stop/New Chat under an in-flight request, Suggestions on a large project, Format Project's narrowed disable, the three reworded Debug.bas messages, the fresh-install starter-project path, the reworded Options-dialog text, the FormDesign 50k-line status message, the missing-include Output message, the trimmed AI-agent list on a fresh install, and Run/Build after the Android-code removal — same gap noted throughout recent sessions; needs owner or a computer-use-capable session.

**Owner decisions taken 2026-07-07, no code needed:**
- **O2** — plaintext AI Agent API keys in the INI: **left as-is.** Low risk for a single-user desktop tool; comparable IDEs do the same.

**Remaining Opus backlog:** R5 **done** (2026-07-08); E1 **done** (2026-07-08, merged from background task, see table above — still needs owner live-test); Phase F (deferred structural: file splits, `FormDesign` debounce — deliberately last, touches the fragile designer path; not started, low priority, see `Next Steps - Opus.md`). Everything else in the Opus backlog is done.

### Deferred-task triage (Opus, 2026-07-07) — `Documents/Deferred Task Recommendations - Opus.md`

After the Next Steps backlog was worked through, Opus triaged every remaining deferred/untouched item into three buckets by fragility and payoff. Full reasoning in the linked document; the split:

- **Opus (fragile-core / live-verification-only):** **R5** (GDB read timeout — gated on owner producing a reproducible hang); ~~**P4**~~ (see outcome below — **attempted & reverted 2026-07-07**); ~~**D1**~~ (**done 2026-07-07** — see below).

#### D1 outcome — Designer menu disabled when no form is open (Opus, 2026-07-07)

The top-level **Designer** menu (`miFormFormat`, "&Designer") now greys out when the active document has no designable form with controls. Made `miFormFormat` a `Dim Shared` pointer, created it disabled (no form at startup), and gate its `Enabled` on `cboClass.Items.Count > 1` at the exact three sites that already govern `miForm`/`miCodeAndForm`: `tabCode_SelChange` (Main.bas, both branches + the `newIndex = -1`/no-tab-selected exit) and `ApplyFormTabView` (TabWindow.bas, both branches). Used the stricter `Count > 1` gate (needs actual controls) rather than `miForm`'s `bFormFile`, because the Designer operations (Align/Make Same Size/Spacing/Order/Lock) act on existing controls — a form file with zero controls has nothing to align, so the menu stays greyed until controls exist. The separate right-click `mnuDesigner` popup and the `"FormFormat"`-key collision with the Format-toolbar toggle are pre-existing and untouched (the Designer parent menu has no click handler, so the key never dispatches). Compile-clean + launch check.

**D1 form-close gap — fixed (2026-07-07, owner-verified).** The menu didn't grey on form/tab close because `tabCode_SelChange`'s `If tb = tbOld Then Exit Sub` early-exits (Main.bas ~8156/8170) return *before* the per-select enable-logic. **Fix:** compute `miFormFormat->Enabled` in **`ChangeMenuItemsEnabled`** (TabWindow.bas, end of the Sub) from the active tab (`ptabCode->SelectedTab`'s `cboClass.Items.Count > 1`) — that Sub is already called by `CloseTab` on every tab close, so the menu now greys on close regardless of the `tabCode_SelChange` early-exits. Owner-verified: greys on form close, re-enables on switching back to a form. (Known-cosmetic, owner-accepted: during a modal save-file dialog on close, the menu momentarily dims then re-activates until the last form closes — harmless since the dialog is modal.)

#### Close Project crash → hang → tabs-not-closing — root-caused & fixed (Opus, 2026-07-07, owner-verified)

Owner reported `File → Close Project` **aborting the app** (project never closed; reopened on restart). This was **not D1** (GDB confirmed zero frames in any D1 code). It was a deep, pre-existing, multi-layer bug in `CloseProject`, cracked with a **GDB debug (`-g -exx`) backtrace** and then, when GDB's crashing-thread stack came back corrupt, a **file-trace** (`DbgTraceCP`) that pinned the exact teardown step. Three real defects, fixed in order:

1. **Use-after-free crash (the abort).** `CloseProject` freed the tree nodes' `ExplorerElement`/`ProjectElement` (`Main.bas` ~2518/2531/2544) but left the nodes' `.Tag` pointers **dangling**, then `tvExplorer.Nodes.Remove` fired `tvExplorer_SelChange`, which does `*eeSel Is ControlTreeElement` on `Item.Tag` → `fb_IsTypeOf` on a freed vtable → SIGSEGV. (The 8+ live `LoadFunctions` parser threads in the first backtrace were *victims* of the corrupted heap, not the cause — a `LoadFunctionsCount` drain was tried and **removed** once the file-trace showed `LFcount=0` at the crash, i.e. deterministic, not a race.) **Fix:** null each `.Tag` immediately after `_Delete`.
2. **Tabs never closed → hang on next interaction.** The old close loop matched `tb->ptn = tn` and did `Exit For` after one — it closed nothing here (stale/mismatched `ptn`), so the project was freed out from under its still-open tabs, whose dangling refs then hung the app (owner had to Task-Manager kill). **Fix:** a new `NodeInProject(node, proj)` helper + a **robust close-all loop** that closes every tab whose tree node is `tn` or a descendant (re-scanning after each close), **plus a safety bail**: if any project tab still won't close, `CloseProject` returns `False` *without* freeing — so it can never leave dangling refs (no hang), by construction.
3. **Reopened on restart.** Was a downstream effect of (2): tabs stayed open → the workspace saved them on app-close → reload. Fixed once tabs actually close.

**Owner-verified:** project + tabs close cleanly, app stays responsive, stays closed on restart.

#### Empty-workspace startup → File → New Project (owner design, 2026-07-07, owner-verified)

The earlier U2 "starter project" used `AddNew(Files/Form.frm)`, which is wrong — `AddNew` only opens a project for a `.vfp` path and otherwise shows "Open a project first" (owner hit this popup after closing the project). **Owner's chosen design:** when there's nothing to reopen, automatically invoke **File → New Project** (`NewProject`, `Main.bas` ~9304) so the user picks the project type. A startup modal here is already the norm (`frmTipOfDay.ShowModal` just below) and it's the original intent (see the commented `Case 1: NewProject`). Cancelling leaves an empty IDE.

#### New Project ↔ Open Project cross-navigation buttons (owner request, 2026-07-07, owner-verified)

- **`frmNewProject`:** added an **"Open Existing Project"** button (lower-left, aligned with OK). Sets `OpenExistingRequested`, closes with Cancel; `NewProject()` then calls `OpenProject()`.
- **`frmOpenProject`:** added an **"Open New Project"** button (lower-left, leftmost) and **moved the existing Browse button to its right** (both `alNone`, explicit `SetBounds`, same height, aligned with OK — no overlap). Sets `OpenNewRequested`, closes with Cancel; `OpenProject()` then calls `NewProject()`. Forward-ref `OpenProject → NewProject` is safe (both `Declare`d in `Main.bi`; mutual toggling recurses but only on repeated clicks — acceptable).

**D1 form-close greying gap — now fixed** (see the D1 outcome section above; resolved via `ChangeMenuItemsEnabled`, owner-verified). No D1 loose ends remain. **R5 (GDB read timeout) done & owner-verified 2026-07-08.** **E1 (Options Apply dirty-tracking) done 2026-07-08**, merged from its background-task worktree (see table above) — still needs an owner live-test of Options ▸ Apply.

#### Startup Close-Project-greyed fix — root-caused & fixed (Sonnet, 2026-07-08, owner-verified)

While live-testing E1, owner found `File → Close Project` **greyed out on startup** when reopening a project from the saved workspace (though it worked once you clicked any node in the Explorer tree). Root cause: `miCloseProject->Enabled` is only ever refreshed by `ChangeMenuItemsEnabled` (`TabWindow.bas:263`), which the tree's `SelChange` handler calls when the selected node's parent changes (`Main.bas:6810-6824`). At startup, `LoadWorkspace()` → `AddProject()` ends with `tn->SelectItem` (`Main.bas:1050`), but that's a thin wrapper over Win32 `TreeView_Select(Parent->Handle, ...)` (`TreeView.bas:12-14`) — if the tree control's handle isn't realized yet at that point in startup, the call silently no-ops: no visual selection, no `SelChange` event, and `tvExplorer.SelectedNode` stays `0` (confirmed via `TreeView.SelectedNode`'s getter, which also requires `Handle`). So the reloaded project's menu state never gets computed until the user manually clicks a tree node.

**First attempt (incomplete):** just calling `ChangeMenuItemsEnabled` after `LoadWorkspace()` returns wasn't enough — it reads `tvExplorer.SelectedNode`, which was still `0` (the earlier `SelectItem` truly never took effect, not just unrefreshed). Owner tested and confirmed still greyed.

**Fix:** after `LoadWorkspace()`/`RunDeferredFormDesign()` (`Main.bas` ~9291, by which point the tree handle is realized), look up the loaded project's node via `GetOpenProjectNode()`, call `tnLoadedProject->SelectItem` to actually re-select it now that the handle exists, then call `ChangeMenuItemsEnabled` directly. Compile-clean; **owner-verified**: Close Project (and the other project-scoped menu items gated the same way — Save Project, Delete Project, Project Properties) are enabled immediately on startup with a reloaded project, no tree click needed. | `src/Main.bas:9291-9297` | Compile-clean + owner live-test

#### E1 live-test follow-up: menu-icons toggle partially applied live — root-caused & fixed (Sonnet, 2026-07-08, owner-verified)

While live-testing E1's Options ▸ Apply, owner found: unchecking "Display icons in the menu" and clicking Apply showed the correct "changes apply the next time the application is run" message, but most menu icons **vanished immediately anyway** (a few were retained) — a half-applied, inconsistent state. **Confirmed pre-existing, not an E1 regression** (`git show cbc71d1` shows the offending line as unchanged context, not part of E1's diff). Root cause: `cmdApply_Click` set `pfrmMain->Menu->ImagesList = IIf(DisplayMenuIcons, pimgList, 0)` live, immediately dropping the shared icon-list reference for the whole menu — but already-rendered menu items keep their cached icon until a full menu rebuild, so only some disappeared. The startup path (`SettingsService.bas:310`) already sets this correctly from `DisplayMenuIcons` on the next run. **Fix:** removed the live `ImagesList` assignment from `cmdApply_Click` entirely — the setting now only takes effect on restart, matching the message shown. Compile-clean; **owner-verified**: icons stay untouched after Apply, message is now accurate. | `src/frmOptions.frm:3844` (removed) | Compile-clean + owner live-test

**New open item (owner-reported 2026-07-08, deferred):** **breakpoint repaint glitch** — after setting a breakpoint, the rest of the code editor goes invisible until the user clicks back into the form/editor window. Cosmetic repaint/invalidate issue in the breakpoint-set path (likely a missing `Refresh`/`Invalidate` on the `EditControl` after the gutter/breakpoint change). Not investigated; logged for a future session.

#### P4 outcome — attempted, live-tested, reverted (Opus, 2026-07-07)

Implemented the **surgical** version: debounce only the single hot edit-path caller (`OnLineChangeEdit`, `TabWindow.bas:3248`) via a 300 ms one-shot timer (`TimerProcDesign` in `Main.bas`, mirroring the `TimerProcGDB` NULL-window pattern), coalescing toward a full rebuild, operating on the *current* tab at fire time (no captured pointer), re-checking every guard the grey-panel fix trusts. Compiled clean; **owner live-tested**. Result: **regression** — changing a control's **Location** via the property list no longer updated the control (Caption still did, because the grid applies caption straight to the live control, whereas Location relies on the `FormDesign` rebuild the debounce delayed). Root problem: **`OnLineChangeEdit` is not the "rapid-typing hot path" — it is the common funnel for *every* text change**, including discrete edits (property-grid apply, paste, and the line-changes undo/redo generate) that need an *immediate* designer refresh. A blanket debounce there is the wrong shape. **Reverted to `640e94e` (nothing committed).** A correct P4 would have to debounce *only* genuine consecutive keystroke-typing while keeping discrete edits synchronous — substantially more invasive surgery in the grey-panel code, for a typing-lag nobody has reported as a pain point. **Parked as not worth the risk/reward** unless designer responsiveness becomes an actual complaint. Design + change-surface map preserved in this session's history if ever revisited.
- **Sonnet (mechanical / contained):** ~~**E1**~~ (Apply dirty-tracking — **done 2026-07-08**, see above); ~~**C1**~~ Comment→Toggle-Comment merge — **done 2026-07-08, owner-verified, see "C1: Toggle Comment merge" below**; ~~**C2**~~ move Bubble Help/Suggest Options/Parameter Info into Options — **done 2026-07-10 (Sonnet)**, see "C2: Edit-menu settings moved to Options" below; ~~**C3**~~ move Recent AI Chat into AI Agent panel — **superseded 2026-07-09**: the AI Agent panel is being removed entirely (see ⭐ AI Agent subsystem removal sub-project above), so Recent AI Chat is deleted rather than moved; ~~**C4**~~ `.lng` translation system — **owner escalated scope from "hide the UI" to full code-level removal 2026-07-08, done, see "C4: full language-system removal" below, owner smoke-test pending**; ~~**C5**~~ GitHub submenu reduction — **owner escalated to full removal 2026-07-09**: rather than pick which 2 items to keep, deleted the entire Help ▸ GitHub topic (2 top-level items + 5-item Advanced submenu, all 7 pointing at the un-forked upstream `XusinboyBekchanov/VisualFBEditor`/`MyFbFramework` repos anyway) and its `mClick` dispatch cases in `VisualFBEditor.bas`, including an already-orphaned `GitHubWebSite` case with no menu item pointing to it. Also removed the corresponding blank/bound `HotKeys.txt` entries. Compile-clean; **owner smoke-test still needed**; ~~**B1**~~ `DeleteEditorFile` `.vfp` dirty-sync — **found already done 2026-07-10**, see Open Items; ~~**B2**~~ `frmNewProject` template icons — **checked 2026-07-08, not reproducible**: owner confirmed all 5 default templates (Windows/Console/Dynamic/Static/Control) show correct icons at &gt;100% display scaling. Traced the load path (`ImageList.Add` → `BitmapType.LoadFromResourceName`'s disk-file fallback reading `Resources/App*.png`, all correctly 32×32) and found no defect; closing as already-working rather than risk an unnecessary change. ~~**B3**~~ `OpenRecentFiles()` dialog — **fixed 2026-07-10**, see Open Items; **O1/O2** Terminal / Other Editors removal *only if owner opts to remove* (default: leave — working features, harmless).
- **Do Not Attempt (fragile-core churn, no audience payoff):** **F1** split the oversized files (`TabWindow`/`Main`/`EditControl` — pure maintainability, high FB compile-break risk); **F2** MFF library-path consolidation (the wart is already harmless; the fix reworks the grey-panel-bug code — risk ≫ reward). Leave both unless a real bug forces the issue.

#### C4: full language-system removal (Sonnet, 2026-07-08, compile-clean — **owner smoke-test needed before commit**)

Owner escalated C4 from "hide the Options UI" to **removing the `.lng` translation capability at the code level entirely** — English-only, permanently, not just hidden. Two layers, both removed:

**Layer 1 — the 4 pure-lookup wrapper functions**, stripped from ~2,010 call sites across 38 `src/*.bas`/`*.frm` files via a Python script (paren-matching would have been overkill: these are single-argument functions, so the transform just deletes the function *name*, keeping `(...)` — e.g. `ML("Save")` → `("Save")`). The script tracked string-literal and comment state per line so it never touched text inside `"..."` or after an unescaped `'`, and skipped `src/Localization.bas`/`.bi` (hand-edited instead, see below) and `src/Temp.bas` (a runtime-generated scratch file, reverted after the script ran over it by mistake — same category as the other pre-existing `Temp.bas` churn files noted throughout this doc, not real source). Removed: `ML()` (2,049 sites, defined in the shared `mff/Application.bas` framework — **left the framework definition itself alone**, since other example apps under `Controls/MyFbFramework/examples`, `Examples/`, etc. may still use it; only VFBE's own call sites were touched), `MC()`, `MP()`, `MLCompilerFun()` (all three defined in `src/Localization.bas`, now deleted entirely along with their `.bi` declares). **Explicitly NOT touched:** `HK()` (misfiled in the same source file, but it's actually the customizable-hotkey-display helper — unrelated to translation, reads from `HotKeys` config) and `MS()` (does real `$1`/`$2` placeholder substitution beyond lookup — kept as a function, simplified to drop only the language-lookup branch, call sites unchanged).
- **Fallout from the transform:** 5 sites broke type inference because `ML()`'s declared `ByRef As WString` return type had been implicitly coercing bare string literals for `IIf()`/branch-type matching — bare `("Loaded")` next to a `WStr("")` sibling branch is a different type than `ML("Loaded")` was. Fixed by wrapping the literal in `WStr(...)` at each site (`frmAddIns.frm:142-144`, `TabWindow.bas` ×3 in a `Comments &=` `IIf`).
- **2 new (accepted) compiler warnings**, both `warning 34: '=' parsed as equality operator in function argument, not assignment to BYREF function result`, at `TabWindow.bas:1045` and `frmFind.frm:785` — both `SomeProperty->Caption = WStr("X") & IIf(comparison, ...)` shapes. Confirmed cosmetic/parser-quirk, not a functional regression: rewrapping the literals with `WStr()` (the same fix as above) did **not** change the warning at all, proving it isn't about the literal's type — it's an FB-parser ambiguity narrowly tied to an `IIf(a = b, ...)` on the right of a property assignment, present at only these 2 of 2,010 changed sites, and the build is 0-errors either way.

**Layer 2 — the loading/UI/maintenance capability**, all removed:
- `SettingsService.LoadLanguageTexts` gutted from a ~100-line `.lng` parser down to two lines (`LoadSettingsIni()` + `App.CurLanguage = "English"` — kept for the couple of unrelated features that still key off `App.CurLanguage`, e.g. `frmTipOfDay`'s per-language `.tip` file and `frmCompilerOptions`' per-language template, both of which already had a graceful English fallback and now just always take it).
- The entire **"Localization" Options page** removed: its tree node, the `pnlLocalization`/`grbLanguage`/`pnlLanguage`/`cboLanguage` container chain, the `chkAllLNG` checkbox, the `cmdUpdateLng` "Scan and Update" button and its ~665-line `cmdUpdateLng_Click` handler (the `.lng`-file-regeneration tool) plus its `UzLot` Uzbek-transliteration helper (~100 lines, used only by that handler). Confirmed via the framework's `PagePanel.SelectedPanel` implementation that page `ControlIndex` values are creation-order bookkeeping only (real page-switching goes through named `.Visible = (Key = "...")` toggles elsewhere) — so deleting one page needed no renumbering of the others.
- The separate **"Display Property of Control in localized language" checkbox** (`chkShowPropLocal`, fed `MC()`/`MP()`) and its backing `gLocalProperties` global, fully removed (load, save, ini write, `Common Shared` declaration). Its sibling `chkShowToolBoxLocal`/`gLocalToolBox` was **already** dead/commented-out before this session (pre-existing, unrelated to this removal) and was left alone — out of scope.
- The Language-changed-on-Apply restart-warning (`newIndex`/`oldIndex` tracking, `Common Shared` in `frmOptions.bi`) and the `Languages` WStringList, all removed as dead weight.
- Deleted `Settings/Languages/` entirely (20 `.lng` files + `Readme.txt` + `english.html`) via `git rm`.
- **Deliberately left alone:** `Tools/LNGCreator` (a standalone mini-app, not part of the running IDE) and the per-example `.lng` files under `Controls/MyFbFramework/examples/*`/`Examples/*` — out of scope, no bugs, not worth the churn.

**Verification:** compile-clean throughout (0 errors; same 4 pre-existing `frmFindInFiles.frm` warnings + the 2 new accepted ones above). **Owner smoke-test 2026-07-08: passed** — dialogs, menus, and captions all correct; the only thing noticed was the Options ▸ Code Editor ▸ Defaults page being empty, confirmed **pre-existing** (not a C4 regression, owner hadn't looked at that page before) — logged as a new open item below, not fixed here (out of scope for this change).

**Options ▸ Code Editor ▸ Defaults page — removed (Sonnet, 2026-07-08, owner-verified).** Confirmed `vbxDefaults` had zero children (`grbDefaults`/`pnlDefaults` were empty containers, nothing ever parented into them) — genuinely dead, not just hidden. Removed the whole chain: the `tnEditor->Nodes.Add(("Defaults"), "Defaults")` tree node, the `.pnlDefaults.Visible = Key = "Defaults"` toggle, and the `pnlDefaults`/`grbDefaults`/`vbxDefaults` control declarations + creation blocks (`frmOptions.frm`/`.bi`). Left the *other* `grbDefault*` groupboxes alone (`grbDefaultCompilers`, `grbDefaultTerminal`, `grbDefaultHelp`, `grbDefaultAIAgent` — different, populated, real features). Compile-clean, owner-verified: no "Defaults" sub-item under Code Editor, nothing else in the tree affected.

#### C1: Toggle Comment merge (Sonnet, 2026-07-08, owner-verified)

Collapsed **Single Comment** (Ctrl+I, unconditionally added a `'` prefix) and **Uncomment Block** (Ctrl+Shift+I, already handled removing *either* single-`'` or block-`/' '/`-style comments) into one **Toggle Comment** command on Ctrl+I: comments the selected line(s) if not already commented, uncomments if they are. Added `EditControl.ToggleComment` (`EditControl.bas`, checks only the first selected line's leading/trailing markers, same detection `UnComment` already used, then delegates to the existing `CommentSingle`/`UnComment`) rather than rewriting either's per-line logic. Wired `Case "SingleComment"` in the `mClick` dispatcher to call it; removed the separate "Uncomment Block" menu item/toolbar button/hotkey (the underlying `EditControl.UnComment` Sub and its `Case "UnComment"` dispatch stay in place, just no longer exposed as its own user-facing command, since `ToggleComment` now calls it internally).

**Owner follow-up (same session):** removed **Block Comment** (Ctrl+Alt+I, the `/' '/`-wrap style) entirely — owner confirmed Toggle Comment already comments/uncomments each line of a multi-line selection individually, which is the expected BASIC-programmer behavior, making the block-wrap style redundant. Deleted `EditControl.CommentBlock` (the only caller was the removed menu item), its `Case "BlockComment"` dispatch, its entry in the shared gating `Case` list, the menu item/toolbar button/icon registration, and all now-unused `miBlockComment`/`tbtBlockComment` declarations. `EditControl2.bi`'s own unrelated `CommentBlock` declare is dead/orphaned pre-existing code (that file isn't `#include`d anywhere) and was left alone.

#### C2: Edit-menu settings moved to Options (Sonnet, 2026-07-10, compile-clean — **owner visual check needed**)

Investigated the S1–S4 "Deferred" scope gap below and found the picture had changed since it was written: **Bubble Help** (`ShowSymbolsTooltipsOnMouseHover`) and **Suggest Options** (`AutoComplete`) already had fully-wired Options ▸ Code Editor checkboxes (`chkShowSymbolsTooltipsOnMouseHover`, `chkEnableAutoComplete` — both already read on dialog Load and written on Apply), living in parallel with the redundant Edit-menu toggles. Only **Parameter Info** (`ParameterInfoShow`) had no Options presence at all.

**Removed from the Edit menu:** `miSuggestions` ("Code - Bubble Help") and `miCompleteWord` ("Code - Suggest Options") — deleted their `miEdit->Add(...)` calls, their dead `Checked`-sync lines in `ChangeShowSymbolsTooltipsOnMouseHover`/`ChangeAutoComplete` (`Main.bas`), their `Dim Shared` declarations, their `mClick` dispatch cases (`"Suggestions"`/`"SuggestOptions"`, `AstoriaIDE.bas`), and a dangling unguarded `miSuggestions->Enabled = bEnabled` in `TabWindow.bas`'s `ChangeMenuItemsEnabled` (`TabWindow.bas:306`) that would otherwise have null-dereferenced on every enable-state refresh once the pointer stayed permanently 0. Neither item carried a real keyboard shortcut (`HK()` had no matching `HotKeys.txt` entry for either), so nothing was lost.

**Parameter Info handled differently, on purpose.** Traced how this app's keyboard shortcuts actually work (`Menus.bas` ~1538–1561): the framework builds its native accelerator table by scanning every *menu item's caption* for an embedded `\tCtrl+X`-style suffix — there's no separate registration path, so deleting a menu item deletes its shortcut. `miParameterInfo`'s caption carries `Ctrl+J` this way, and the old `"ParameterInfo"` dispatch case had dual behavior: a plain menu click toggled the auto-show setting, while the *accelerator* (Ctrl held) invoked Parameter Info immediately — genuinely one "edit action" and one "on/off setting" sharing a single case via a `GetKeyState(VK_CONTROL)` check. Splitting them: the menu item stays (preserving Ctrl+J), now non-checkable and re-pointed at the same `"InvokeParameterInfo"` key the toolbar button already used (always invoke now, no toggle); the old dual-behavior `"ParameterInfo"` case is deleted as dead code. The on/off "auto-show" setting moved to a new `chkParameterInfoShow` checkbox in Options ▸ Code Editor ▸ IntelliSense (`frmOptions.frm`/`.bi`), wired the same way as its siblings — Load populates it from `ParameterInfoShow`, Apply writes it back through the existing `ChangeParameterInfo(...)` Sub (which already handles the state update, closing any open tooltip, and the INI write) rather than duplicating that logic.

**Verification:** compile-clean (0 errors, same baseline warnings), launch/process-alive check passed. **Not verified this session** (no GUI/computer-use access): the new checkbox's visual placement in the IntelliSense group box, and a live click-through confirming Ctrl+J still invokes Parameter Info and the Edit menu no longer shows the three removed/changed items as expected — same recurring gap as everywhere else in this doc; needs owner or a computer-use-capable session.

Compile-clean throughout; owner-verified both the toggle behavior (comment ↔ uncomment on repeated Ctrl+I, single line and multi-line selections) and that Block Comment is fully gone from menu/toolbar/hotkey.

**Already resolved (dropped from the deferred list):** the Designer event-handler cluster (collapsed to one toggle, `640e94e`) and the `.lng` maintenance question (decided: English-only).

**E1 background-task session note (worktree, 2026-07-08):** the E1 worktree's `Compile.bat` failed silently at the `gcc` step (exit 1, zero output) even on an untouched baseline checkout of the same worktree, while the separate main checkout at `C:\Users\dmont\VisualFBEditor` compiled the identical baseline cleanly — ruled out the code change as the cause (baseline reproduced the same failure), tried a retry after a pause, and a byte-for-byte copy of the worktree to a plain path (all failed identically). Verified compile-clean at the time by temporarily swapping the modified `frmOptions.frm` into the main checkout, compiling there (0 errors, clean), then restoring the main checkout's `frmOptions.frm`. This was a worktree-environment quirk, not a code defect. **Confirmed 2026-07-08:** merged into `main` (`b078d99`) and recompiled clean here (0 errors, same 4 pre-existing `frmFindInFiles.frm` warnings) — the worktree's `gcc` failure does not reproduce in the main checkout.

---

## 13.3.A execution — S1–S4 done (Sonnet 2026-07-06), Opus-reviewed & committed (2026-07-07)

Executes the Opus-designed plan in [ROADMAP.md §13.3.A](ROADMAP.md#1333a-approachability-pass--full-plan-designed-2026-07-06-opus-session). **Committed to `main` 2026-07-07 after Opus O4 review (see "O4 review outcome" below).**

### O4 review outcome (Opus, 2026-07-07)

Reviewed the full S1–S4 diff against the plan, focusing on the two areas the plan flagged as compile-clean-hides-a-break (§9 dormant-reference wiring; toolbar/band/INI mechanics). **No correctness bugs found.** Verified: all 5-band indices agree across `frmMain_Create`, the `mClick` toggle cases, and the ReBar add order; the `Bands.Count - 2` Maximize bound preserves "all but Format"; every `mi*`/`mnu*`/`tbt*` enable-state pointer is reassigned in the new structure; `git grep` for all removed symbols returns zero stale references; the `tbtToggleBreakpoint` double-assign fix and `tbtShowNextStatement` target are correct; toolbar captions sit in the correct `FCaption` positional arg (arg 6) with `tbsAutosize`; the frmTools insertion fix is sound (Tools menu has two separators bracketing the tool list, `-`+`Options` always last two children); and both Window-menu count translations (`>3`→`>1`, `>2`→`>0`) are faithful (subtract the 2 removed static items).

**One plan-mandated gap found and fixed before commit:** S3's ROADMAP gotcha required migrating the retired `ShowBuildToolbar`/`ShowDebugToolbar` INI keys into `ShowRunToolbar` ("if either was true, Run visible"); Sonnet's S3 did the default changes but not the migration, so a pre-13.3.A user who had hidden the old Run toolbar while keeping Build visible would have lost all toolbar access to Build/Stop/debug (menus still worked). Fixed in `frmMain_Create` (`Main.bas` ~9029): `ShowRunToolBar = ReadBool("ShowRunToolbar", True) OrElse ReadBool("ShowBuildToolbar", False) OrElse ReadBool("ShowDebugToolbar", False)` — only ever turns Run on, retired keys read once and never re-written. Compiled clean (0 errors; same 4 pre-existing `frmFindInFiles.frm` warnings). Toolbar text captions (Run/Build/Stop) confirmed rendering in a live owner screenshot.

**Owner follow-ups (non-blocking, carried forward):** (1) Help ▸ GitHub kept VFBE-repo + VFBE-wiki; plan text said VFBE-repo + FreeBASIC-wiki — owner to confirm. (2) Still needs owner eyes: does "Show Main Toolbar" reclaim editor space, and does Project Properties ▸ General lay out OK with the `*nix` icon field gone. See Deferred list below for the rest.

### S1 — Menu structure (all menus)

Reorganized every menu per the O1/O2 taxonomy: File (Advanced submenu for Print Preview/Page Setup), Edit (Advanced submenu for Unformat/Format Project/Add Spaces/Merge Blank Lines), View (merged Collapse+Uncollapse into one **Fold** submenu; split **Other Windows** into user windows vs. a new **Debug Windows** submenu; folded Window's Split Horizontally/Vertically into View, leaving Window holding only its open-document list), Project (Advanced submenu for Add User Control/Resource File/Manifest File), Tools (Command Prompt promoted to top-level, Add-Ins/External Tools moved to Advanced), Help (GitHub submenu trimmed to VisualFBEditor repo+wiki, rest moved to Advanced — **ambiguous spec wording, flagged for confirmation**, see Issues below). Biggest piece: **Build + Debug + Run menus merged into one Run menu** with **More Build Options** / **More Debug Options** submenus, preserving every `ChangeMenuItemsEnabled`/`ChangeEnabledDebug` pointer so enable-state wiring kept working across the move.

### S2 — Relabeling

Search: "Define" → "Go to Definition". Run menu: Start With Compile→**Run**, Compile→**Build**, End→**Stop**, Start→**Run Without Building**, Compile All→**Rebuild All**, Make Clean→**Clean**. Only `ML()` caption text changed — every dispatch `Key` string and hotkey stayed the same, so `HotKeys.txt` customizations and localization data aren't orphaned by a rename (deferred concern below).

### S3 — Toolbar consolidation

Build+Debug+Run toolbars merged into one Run toolbar (ReBar: 7 bands → 5: Standard, Edit, Project, Run, Format). Added visible **text-beside-icon captions** to the primaries (Run, Build, Stop, Save, Open) — `TBSTYLE_LIST` was already enabled on every toolbar but no button had ever passed a caption, so the capability was live but unused. Set **minimal defaults: Standard + Run visible, Edit/Project/Format hidden** — verified this only changes behavior for fresh installs (`ReadBool(key, default)` only applies the new default when the INI key is absent; existing users' saved toolbar visibility is untouched).

### S4 — Dead field removal

Removed the "Icon Resource File (For \*nix/\*bsd)" label + combobox from Project Properties ▸ General (`frmProjectProperties.frm`/`.bi`) — dead cross-platform UI in a Win64-only fork. Deliberately **kept** the underlying `ppe->IconResourceFileName` field, since it's auto-populated whenever a `.xpm` file is added to a project and used elsewhere (`Main.bas`/`TabWindow.bas`) for file-rename tracking — unrelated to the removed picker. Preserved the `.xpm` branch in `AddToCombo`/`AddToComboFileName` as an intentional no-op (matching the existing `.bat`/`makefile` pattern) so `.xpm` files don't fall through and get miscategorized as "Main File" now that their combobox is gone.

### Issues found and fixed along the way

1. **Startup crash (introduced by S3, caught before reporting complete):** `frmMain_Create` had a hardcoded `For i = 0 To 5 : MainReBar.Bands.Item(i)->Maximize : Next`, assuming the old 7-band layout (loop deliberately excluded the last band, Format). Once S3 dropped the ReBar to 5 bands, `Bands.Item(5)` returned null and `->Maximize` on it caused a `SIGSEGV` — app terminated right after the splash screen. Found via `CompileDebug.bat` + the bundled GDB in batch mode (exact backtrace on the first try: `ReBarBand.Maximize` with `THIS=0x0`, from `Main.bas:9073`). Fixed by computing the bound from `MainReBar.Bands.Count - 2` instead of a literal, so it can't silently go stale again. Re-verified via GDB (20s observation, zero signals) and a real release-build launch (8s alive check, correct window title).
2. **Pre-existing bug found and fixed (unrelated to my changes, hit while rewriting the same code):** the old toolbar code assigned `tbtToggleBreakpoint` twice — once for the real Toggle Breakpoint button, then again (copy-paste) for the Show Next Statement button, silently losing the real button's pointer. `ChangeEnabledDebug`'s `tbtToggleBreakpoint->Enabled = True` was therefore managing the wrong button. Fixed using `tbtShowNextStatement`, which was already declared but never used — clearly the original intent.
3. **Regression I introduced and caught before it shipped:** moving "External Tools..." into Tools ▸ Advanced broke `frmTools.frm`'s save handler, which located where to re-insert saved custom tools by finding that item as a direct sibling (`mi->Name = "Tools"`). Since it's no longer a direct child of the Tools menu, the lookup would have silently placed newly-saved tools at the wrong position. Fixed by computing the insertion point from the stable trailing separator+Options pair instead of a Name-based lookup.
4. **Two hardcoded gaps fixed while already touching this code (not part of the original ask, but directly adjacent and zero-risk):** `ShowFormatToolBar` was never being persisted to INI (only read) — added the missing `WriteBool`. `ChangeMenuItemsEnabled`/`Main.bas`'s Window-menu item-count checks (`miWindow->Count > 3`, `> 2`, loop starting at index 3) assumed 3 static Window-menu items (Split H/V/separator); now that Split H/V moved to View, Window holds only the separator, so these were updated to `> 1`/`> 0`/loop-from-1 to match.

### Deferred (flagged, not guessed at)

- **Comment/Block Comment/Uncomment → "Toggle Comment" merge** (owner-approved in the plan) — real behavior change (detecting current comment state to decide comment-vs-uncomment), and `CommentSingle`/`CommentBlock`/`UnComment`'s internals weren't verified well enough to merge safely blind.
- ~~**Moving Bubble Help/Suggest Options/Parameter Info from Edit into the Options dialog**~~ — **done 2026-07-10**, see "C2: Edit-menu settings moved to Options" above. **Moving Recent AI Chat from File into the AI Agent panel** is moot — the AI Agent panel was removed entirely (see ⭐ AI Agent subsystem removal sub-project); Recent AI Chat was deleted rather than moved.
- **Designer menu disable-when-no-form-open** (O1's "only refinement" for the Designer menu) — would touch `tabCode_SelChange`, an area with a documented fragility history (this is the same code path implicated in the form-designer grey-panel bug earlier this session).
- **GitHub submenu's "VFBE repo + FB Wiki" reduction** — the ROADMAP spec's wording is ambiguous about which exact 2 items should remain. Kept VisualFBEditor's own repo+wiki as the safest reading (the only unambiguous "repo + its own wiki" pairing available); cheap to adjust if that's not what was meant.
- **Localization (`.lng`) files** — `ML()` keys on the exact English source string (`Settings/Languages/*.lng`, 15+ languages shipped, inherited from upstream). Renaming a caption (S2) breaks that language's translation lookup for the renamed string until its `.lng` file gets a matching new entry — not something a mechanical relabel pass can safely do across 15 languages. English (the default/base language) is entirely unaffected. Flagged for the owner to decide whether these language files are still meant to be actively maintained for this fork.

### Verification performed

- Compile: 0 errors at every phase gate (after S1, after S2, after S3, after S3's crash fix, after S4) — same 4 pre-existing warnings throughout (`frmFindInFiles.frm`, from Cursor's uncommitted Search-menu work, not introduced by this pass).
- Grepped `src/` after every symbol move/removal for stale references (the §9 "clean compile is not sufficient" rule) — caught issues #1 and #3 above this way, both before they were reported as done.
- Release build: fresh launch + process-alive check after the crash fix and again after S4 — window opens, correct title, stays running.

### Not verified (no GUI/computer-use access this session)

- Visual click-through of every moved menu item in each run-state (stopped/running/paused) — the gate explicitly calls for this and it needs a human or a computer-use-capable session.
- Whether "Show Main Toolbar" (Options ▸ General) actually reclaims the editor's vertical space when toggled off — traced the code (it does call `pfrmMain->RequestAlign`) but couldn't visually confirm; this project has a documented history of "last-mile" docking-space gaps (see the bottom-panel fix history below).
- Project Properties dialog's visual layout after S4's field removal — nothing sat directly below/adjacent to the removed controls in a way that looked wrong from reading the code, but there's now an unclosed blank rectangle where they were (every control on that page uses absolute `SetBounds`, nothing reflows).

---

## 13.3.A execution — S5–S7 done (Sonnet 2026-07-07), Opus-reviewed & committed (2026-07-07)

Continues from the S1–S4 commit (`0eaa880`). Committed after Opus O4 review (see "O4 review outcome (S5–S7)" below).

### O4 review outcome (S5–S7) + owner-found regression (Opus, 2026-07-07)

Reviewed the full S5–S7 diff and two runtime issues the owner found while exercising the S1–S4 build.

**Owner issue #1 — toolbar visibility choices didn't persist (Run toolbar).** Root cause was **my own S3 INI-migration line, not S5–S7.** The migration OR-ed the retired `ShowBuildToolbar`/`ShowDebugToolbar` keys into `ShowRunToolBar` on *every* load; since S1–S4 stopped writing those keys but never removed them, `ShowBuildToolbar=true` stayed frozen in the INI and permanently latched Run visible — "hide the Run toolbar" could never survive a restart. The INI is case-insensitive (`IniFile.KeyExists` compares `UCase`) and `WriteBool` flushes immediately, so Standard/Edit/Project/Format were never affected — only Run. **Fixed** (`Main.bas` ~9056): retired keys are now consulted *only as the default* for `ReadBool("ShowRunToolbar", …)` (so a saved value always wins — `ReadBool` ignores its default when the key exists), making the carry-forward genuinely one-time; then `KeyRemove` deletes the two retired keys so they can't re-latch or linger (satisfies the §9 "migrate retired keys, don't orphan" rule the original migration violated). Compiles clean. **Needs owner re-test** (toggle needs the GUI): hide Run → close via window X → relaunch → should stay hidden, and `ShowBuildToolBar` should be gone from `Settings/VisualFBEditor64.ini`.

**Owner issue #2 — most toolbar buttons have no beside-icon text.** Working as designed, not a bug: O3 deliberately labels only the 5 primaries (Run/Build/Stop/Open/Save) to keep one short bar; the other ~33 buttons are icon-only *with* hover tooltips (all wired). **Owner decision (2026-07-07): keep the 5 primaries as-is** — no change.

**S5–S7 verdict: no correctness bugs.**
- **S5** — `DeleteEditorFile` memory-safety verified against `CloseTab`: that Sub frees `tn` only when `ptvExplorer->Nodes.IndexOf(tn) <> -1` (a direct root child), and root children always have `ParentNode = 0`, so "CloseTab frees tn" ⟹ `bNestedInProject = False` ⟹ the post-close re-touch is skipped in exactly the freeing case. No use-after-free. **One functional follow-up (not a blocker), see Open Items:** deleting a *project-member* file removes the tree node + disk file but doesn't mark the project dirty / update the `.vfp` the way `RemoveFileFromProject` does, so the deleted file may still be listed in the `.vfp` until the next save.
- **S6** — clean; compiler confirms zero dangling references to the removed controls, and Sonnet correctly *deferred* Terminal + Other Editors after tracing them to live functionality (the plan's "candidate for removal" wording was wrong for both). Env-vars/encoding/compiler-paths removals were all genuinely dead.
- **S7** — correctly a no-op; targets already removed by commit `6b3200a`.

**Working tree at review time (before commit):** `src/Main.bas` (S5 + Run-migration fix), `src/frmOptions.frm`, `src/frmOptions.bi` (S6), plus `PROJECT_STATUS.md`.

### S5 — Delete Project/Delete File confirm + regroup

`DeleteProject` already had a proper Yes/No `MsgBox` confirm (pre-existing, not new). `DeleteEditorFile` (`Main.bas`) was a **complete no-op stub** — just a `' TODO: delete file from disk and project explorer` comment, no confirm, no deletion, despite being wired to a live "Delete File" menu item. Since the S5 ask ("add a confirm dialog") assumes something to confirm, and a confirm dialog wrapping a no-op would be actively misleading (user clicks Yes, nothing happens), implemented it for real:

- Mirrors `DeleteProject`'s confirm pattern (`MsgBox` Yes/No, `mtWarning`).
- Closes the active tab via the existing `CloseTab(tb, True)` (`WithoutMessage=True` — matches `DeleteProject`'s own choice to suppress the redundant "save before closing?" prompt, since the user already confirmed permanent deletion).
- Detaches the file's tree node from its project parent, then deletes the file from disk (`Kill`), guarded by `Dir(...)<>""` so an already-missing file doesn't crash.
- **Memory-safety subtlety traced before writing this:** `TreeNodeCollection.Remove` (`mff/TreeView.bas:395-398`) calls `_Delete` on the node — it frees it, doesn't just detach it. `CloseTab`'s own internal cleanup (`TabWindow.bas:1042-1051`) already does this for root-level/"Opened" (loose, non-project) file nodes, meaning `tn` can already be a dangling pointer by the time `CloseTab` returns for that case. Nested project-member nodes are left untouched by `CloseTab` (that's "Close File"'s normal, correct behavior — it shouldn't strip a file from the project tree). So `DeleteEditorFile` captures `tn->ParentNode <> 0` **before** calling `CloseTab`, and only re-touches `tn` afterward when it was nested (never for the root-level case, where it may already be freed).
- Regrouped both `Delete Project` and `Delete File` out of their old positions (previously each sat with zero separator directly below its own Close item) into their own bracketed group near the bottom of the File menu, right before the Advanced submenu/Exit — well away from Close Project/Close File.

Compiled clean; grepped for stale `miDeleteProject`/`miDeleteFile`/`DeleteEditorFile` references — all consistent (enable-state wiring in `TabWindow.bas` and the `mClick` dispatch are position-independent, unaffected by the reorder).

### S6 — Options dialog (O4) edits

**Executed, all confirmed dead/vestigial before removal — nothing here changes any currently-reachable behavior:**

- **Default Compiler → read-only info line.** Removed `cboCompiler64` (was already `.Visible = False`, had zero Load/Save wiring anywhere in the form). The existing `lblCompiler64`/`lblCompiler64Path` label pair ("Compiler 64-bit: ./Compiler/fbc64.exe") already *is* the read-only info line the plan asked for.
- **Compiler Paths removed.** `grbCompilerPaths`/`lvCompilerPaths` was already `.Visible = False`; its Add/Remove/Change button row (`hbxCompilers`) was empty (no buttons ever added to it) and its `ItemActivate` handler was an empty stub. Its own Save routine already unconditionally purged the "Compilers" INI section on every save (not just cleaned stale entries — nuked the section outright), so the feature was already fully inert. Traced `Project->CompilerPath` (the per-project field `BuildService.bas` actually consults for the fbc path) end-to-end: no UI anywhere sets it (not `frmProjectProperties.frm`, not this list) — it can only ever be non-empty via hand-edited `.vfp` files. Removing the dead registration UI doesn't touch `Project->CompilerPath` or `BuildService.bas`'s bundled-compiler fallback at all.
- **"Turn on Environment Variables" removed.** Confirmed non-functional by tracing the debuggee launch path: `Debug.bas`'s `CreateProcess` call passes `0` for `lpEnvironment` (line 436) — the debuggee always inherits the parent's environment unchanged. `TurnOnEnvironmentVariables`/`EnvironmentVariables` were read from INI, editable in Options, written back to INI — and never consulted anywhere else. Removed the checkbox+textbox; **left the backing globals and their INI load/save alone** (same precedent as S4 keeping `IconResourceFileName` — harmless orphaned state, trivial to fully purge later if wanted).
- **Code Editor ▸ Defaults encoding/line-ending pickers removed.** `hbxDefaultFileFormat`/`hbxDefaultNewLineFormat` (and their `cboDefaultFileFormat`/`cboDefaultNewLineFormat` combos) were already `.Visible = False`, never populated with a single `AddItem`, and never read from/written to any global or INI key anywhere in the form. Confirmed `ChangeFileEncoding`/`ChangeNewLineType` (`Main.bas`) already ignore their passed-in parameter entirely and unconditionally show "UTF-8"/"CR+LF" on the status bar — matching the plan's premise that `AddTab` forces UTF-8+CRLF for every file.

**Deferred (flagged, not guessed at) — both turned out to be real, working features, contradicting the plan's tentative wording:**

- **Debugger ▸ Terminal sub-page** — plan said "Remove; pick a sensible default terminal." Traced `TerminalPath`/`CurrentTerminal` and found them **genuinely consumed** at `TabWindow.bas:12042-12054`: when set, the compiled program launches inside the user's chosen terminal emulator instead of the default console. This is live, working, user-configurable functionality, not dead code — removing it is a deliberate feature reduction the plan explicitly wants, but doing it safely means also verifying the empty/default fallback path stays correct and re-touching an "Add/Change/Remove Terminal" browse-dialog flow, which is more surgery than could be done carefully in the remaining scope of this session. Left entirely untouched.
- **Code Editor ▸ Other Editors** — plan said "candidate for removal." Traced `pOtherEditors` and found it **genuinely consumed** in `Main.bas` (`NodeActivate`/`OpenTreeNodeOnSingleClick`, ~lines 6629-6684): double-clicking a file whose extension is registered launches the configured external editor instead of opening it in VFBE. Real, useful feature — the plan's "candidate for removal" phrasing turns out to be wrong once verified. Left entirely untouched.
- **Designer ▸ "Create non-static event handlers"** — not touched at all. This checkbox gates the `Enabled` state of three other checkboxes (`chkPlaceStaticEventHandlersAfterTheConstructor`, `chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning`, `chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt`) and affects the Designer's actual **generated event-handler code** for every control a user adds going forward. Picking the wrong default here could silently change codegen behavior project-wide. This is a real design decision about FreeBASIC event-handler generation conventions, not mechanical cleanup — needs owner input on what the sensible default actually is, same bar as S1's Comment-merge deferral.

### S7 — Docs GTK cleanup

**Already resolved — nothing to do.** `src/makefile` doesn't exist in the repo at all (confirmed via `find`/`Glob`), and `src/THREADING.md` has zero GTK references (confirmed via grep). Both must have been cleaned up in an earlier session (likely Batch 2.75.3) without the Open Items entry being removed. Cleared the stale entry from Open Items below. The only remaining "gtk" hits in `src/` are `src/BUILD.md`'s accurate "Linux, GTK, and 32-bit IDE builds are not supported in this fork" (correct, current documentation, not a stale reference) and two string-literal filters in `TabWindow.bas` (`"gtkwidget"`, excluding a legacy field name from a property-grid listing — functional code, not a doc reference, out of scope for a docs pass).

### Verification performed

- Compile: 0 errors after S5, after S6's four removals — same 4 pre-existing `frmFindInFiles.frm` warnings throughout.
- Grepped `src/frmOptions.frm`/`frmOptions.bi` for every removed symbol after S6 — zero stale references (only my own explanatory comments mention the old names).
- Grepped to confirm the three deferred/untouched features (`TurnOnEnvironmentVariables`/`EnvironmentVariables` globals, `pTerminals`/`CurrentTerminal`/`TerminalPath` in `TabWindow.bas`, `pOtherEditors` in `Main.bas`) are byte-for-byte unaffected by the S6 edits.
- Release build: fresh launch + process-alive check after all S5+S6 changes (6s observation) — window opens, stays running.

### Not verified (no GUI/computer-use access this session)

- Visual layout of the Options dialog's Compiler/Debugger/Code-Editor pages after S6's removals — the removed controls were already invisible or (for Compiler Paths) filled remaining client space via `DockStyle.alClient`, so removing them shouldn't visibly change anything, but this needs a human or computer-use session to actually confirm the pages still lay out correctly (no leftover blank gaps, no other control unexpectedly reflowing into the freed space).
- Delete File end-to-end: confirm dialog appearance, actual disk deletion, and tree-node detachment for both a root-level ("Opened"/loose) file and a nested project-member file — traced carefully against `CloseTab`'s and `TreeNodeCollection.Remove`'s exact behavior, but not exercised interactively.
- Delete Project/Delete File's new menu position — visual confirmation that the regrouping reads clearly in the running File menu.

---

## RESOLVED — Form designer grey-panel bug

**Status:** FIXED (2026-07-06). Full root-cause analysis, fix details, and original investigation record archived in [HISTORY.md](HISTORY.md).

---

## File menu — Open Project (owner-approved, 2026-07-06)

Part of the File menu step-by-step review. **Open Project** (`frmOpenProject`) was expanded: browse-for-`.vfp`, Examples tree, and MRU-style discovery with **PathUtils** fixes (`GetFileName` for extensionless folder names, `FindProjectVfpInFolder`, slash normalization) so Examples such as MDINotepad resolve correctly.

---

## Edit menu review & Suggestions lockup (2026-07-06)

### Edit menu audit

All 25 Edit menu entries were traced to their handlers. Every entry dispatches to a live implementation — no stale references, no dead code, no removed-feature stubs.

### Three path-evaluation bugs found and fixed

| # | Bug | Root cause | Fix |
|---|-----|-----------|-----|
| 1 | `GetControlLibraryVfpPath` returning "" for absolute paths | Mixed-slash search | Normalize to forward slashes before scan |
| 2 | Slash naming confusion (`Slash`/`BackSlash` reversed) | Names opposite to values | Renamed `WindowsSlash`/`UnixSlash` (20 files) |
| 3 | `GetFileName` dropping last character of extensionless names | Length formula assumed `.` always present | Guard on extension existence |

Bug #3 was the root cause of MDINotepad not appearing in the Examples list — `GetFileName("MDINotepad", False)` returned "MDINotepa", so `<dirname>.vfp` was never found.

### Suggestions lockup — fixed (2026-07-06)

**Symptom:** Edit → Suggestions froze the IDE. Root cause: menu handler called `Sub Suggestions` in `TabWindow.bas`, which loaded every project file synchronously on the main thread and ran `AnalyzeTab`.

**Wrong fix (Deepseek, reverted):** Background thread + toggle on the same menu key. Caused file-not-found on close (relative project paths) and broken checkmark toggle.

**Edit menu (flat):** **Code - Bubble Help**, **Code - Suggest Options**, and **Code - Parameter Info** are direct items under Edit (no Code submenu). Bubble Help toggles `GlobalSettings.ShowSymbolsTooltipsOnMouseHover`; Suggest Options toggles `AutoComplete`; Parameter Info toggles `ParameterInfoShow`.

**Fix (2026-07-06):** Flattened Edit menu (removed `miEditCode` submenu) so checkable toggles route through `WM_COMMAND` → `mClick` like **Use Debugger**. Submenu nesting caused checkmark-only toggles without updating globals. `ChangeShowSymbolsTooltipsOnMouseHover` closes open hover tooltips when disabled.

**Correct behavior (user-confirmed):** Edit → **Code - Bubble Help** toggles **bubble help** (`GlobalSettings.ShowSymbolsTooltipsOnMouseHover`) on/off — same setting as Options → IntelliSense → “Show Symbols Tooltips On Mouse Hover”. It does **not** run project-wide analysis.

**Edit → Suggest Options** (renamed from Complete Word menu item) toggles **auto-complete** (`AutoComplete` / Options → “Enable Auto Complete”) — enables/disables the intellisense dropdown while typing. **Ctrl+Space** and the toolbar Complete Word button still invoke `CompleteWord` manually.

**Edit → Code - Parameter Info** toggles **parameter hints** (`ParameterInfoShow` / `Options/ParameterInfoShow`) — enables/disables automatic parameter tooltips while typing `(`, `,`, `?`, etc. **Ctrl+J** (with Ctrl held) and the toolbar Parameter Info button still invoke `ParameterInfo` manually when enabled. Menu click without Ctrl toggles the setting.

**Implementation:**
- `ChangeShowSymbolsTooltipsOnMouseHover` in `Main.bas` (mirrors `ChangeUseDebugger`): updates global, syncs `miSuggestions->Checked`, persists INI, closes active hover tooltips when off.
- `ChangeAutoComplete` in `Main.bas` (same pattern): updates `AutoComplete`, syncs `miCompleteWord->Checked`, persists `Options/AutoComplete` to INI.
- `ChangeParameterInfoShow` in `Main.bas` (same pattern): updates `ParameterInfoShow`, syncs Parameter Info menu checkmark, persists `Options/ParameterInfoShow` to INI.
- Flat Edit items: `ML("Code - Bubble Help")` command `"Suggestions"`; `ML("Code - Suggest Options")` command `"SuggestOptions"`; both checkable, empty image key.
- Menu `Case "Suggestions"` toggles bubble help; menu `Case "SuggestOptions"` toggles auto-complete; toolbar `tbtSuggestions` uses key `AnalyzeSuggestions` → still calls `Sub Suggestions` for project analysis; toolbar/hotkey `CompleteWord` still calls `CompleteWord`.
- `frmOptions` Apply syncs both menu checkmarks when options change from the dialog.

**Note:** Toolbar Suggestions button still runs synchronous project analysis (may block on large projects); only the Edit menu item is the bubble-help toggle.

### Files modified this session

- `src/PathUtils.bas` — `GetFileName` fix, `FindProjectVfpInFolder` fallback fix, `CanonicalWinPath` comment
- `src/Main.bi` — `WindowsSlash`/`UnixSlash` defines, `SanitizeMRUListsOnLoad` declare, `ChangeShowSymbolsTooltipsOnMouseHover` declare
- `src/Main.bas` — `ChangeShowSymbolsTooltipsOnMouseHover`, checkable `miSuggestions`, toolbar key split, startup sync
- `src/VisualFBEditor.bas` — menu vs toolbar handler split
- `src/frmOptions.frm` — sync menu checkmark on Apply
- `src/TabWindow.bi` — slash rename
- 17 other `src/` files — slash rename only
- `Controls/MyFbFramework/mff/UString.bi`, `SysUtils.bi`, `Sys.bas` — `#ifndef UNICODE` guards

---

**Edit menu review status:** Complete — owner-approved all items (2026-07-06); flat menu checkmark toggles and handler routing verified; compile-clean.

**Parameter Info gating:** `ParameterInfoShow` is now user-togglable (was effectively always on); `ChangeParameterInfoShow` in `Main.bas` mirrors the Use Debugger / Bubble Help checkmark pattern.

---

## Search menu — Define (F2) reliability (2026-07-06)

Part of the §13.3 step-by-step UI review. **Search menu is not yet owner-approved**; this pass targets **Search → Define** (F2 / `TabWindow.Define`) only. Remaining Search items (Find, Find In Files, Replace, etc.) are pending review.

### Reliability issues identified and fixed

| # | Issue | Symptom | Fix |
|---|-------|---------|-----|
| 1 | Stale symbol tables | F2 after edits found nothing or wrong targets | When `TextChanged`, call `FormDesign(True)` and clear flag before lookup so symbol tables match the editor |
| 2 | Silent failure | No feedback when lookup failed or cursor had no word | Status bar panel 0: `No word at cursor`; `No definition found for 'Foo'` |
| 3 | String/comment false positives | F2 inside strings or comments could match spurious symbols | Silent skip using the same string/comment guard as `CompleteWord` |
| 4 | Missing `#define` / `#macro` | Preprocessor symbols not in lookup | Search `Content.Defines` and project-wide `pGlobalDefines` |
| 5 | Same-line self-match | F2 on a definition line skipped *all* same-line matches | `DefineOverlapsCaretWord` — StartChar-aware overlap check; skip only the definition under the caret, not every symbol on the line |
| 6 | Procedure scoping typo | Type-member Define missed when scoped via `cboFunction` | `te` → `te1` for procedure `OwnerTypeName` / `Elements` walk |
| 7 | Ambiguous multiple matches | `frmTrek` title gave no match count | Title: `Definitions for 'word' (N)` |

### Implementation

- **`DefineOverlapsCaretWord`** — private helper in `TabWindow.bas`; returns true when a symbol's `[StartChar, StartChar+Len(Name))` overlaps the caret word bounds.
- **`TabWindow.Define`** — symbol refresh, string/comment guard, define/macro lists, caret-aware same-line skip, status-bar messages, `frmTrek` title with count.

### Files modified (uncommitted)

- `src/TabWindow.bas` — `Define`, `DefineOverlapsCaretWord`

### Search menu review status

**In progress** — Define (F2) reliability pass complete (uncommitted); remaining Search menu entries pending owner review.

*(Form designer grey-panel investigation continues below for historical reference; see RESOLVED section above.)*

### Actual root cause (verified by live file-logging, not the earlier Bugbot hypothesis)

The grey panel had **nothing** to do with duplicate `FormDesign`, the workspace-defer logic, or the `RefreshDesignSurface` reparent — all were ruled out by tracing every `FormDesign` caller and exit. The real chain, established by logging inside `FormDesign` → `Designer.CreateControl` → `Designer.Symbols`:

1. `Designer.CreateControl("Form", …)` returned 0, so `FormDesign` bailed at `If .DesignControl = 0 Then Exit Sub` → empty `pnlForm` = grey (the "flash" is the Designer canvas appearing before the control-create fails).
2. `CreateControl` returned 0 because `Designer.Symbols("Form")` returned 0.
3. `Symbols` returned 0 because it called `DyLibLoad` on the MyFbFramework `Library.Path`, which was the **folder** `Controls\MyFbFramework` (no `mff64.dll`) — even though the DLL was already loaded (valid `Handle`). `DyLibLoad` on a directory returns 0.

The `"Form"` component's `Comps` entry binds its `Tag` to an MFF `Library` object whose `Path` is the raw `.vfp` component string `Controls/MyFbFramework` (a folder), **distinct** from the toolbox library that carries the real DLL path. So MFF ends up with multiple `Library` objects with inconsistent path representations, and `Comps["Form"].Tag` points at the folder-path one.

### Fixes shipped

1. **`src/Designer.bas` `Designer.Symbols`** — when `DyLibLoad(Path)` fails but the library has a live `Handle`, recover the real on-disk DLL path via `GetModuleFileNameW(Handle)` and `DyLibLoad` **that**. This both works around the folder-`Path` and keeps the module refcount balanced. (A first attempt that simply borrowed `CtlLib->Handle` without a matching `DyLibLoad` made the *first* designer work but under-flowed the refcount — the Designer destructor's `DyLibFree(st->Handle)` at `Designer.bas` ~2905 then unloaded `mff64.dll` after the first project closed, breaking every subsequent project. The `GetModuleFileNameW` + `DyLibLoad` form is the correct, refcount-safe fix.)
2. **`src/PathUtils.bas` `GetControlLibraryVfpPath`** — normalize to forward slashes before the `"/controls/"` scan. It previously ran `WinOsPath` (backslashes) then searched for a forward-slash substring, returning `""` for every absolute library path. That broke the project-open "already loaded" match (`bFinded` stayed false), causing duplicate library objects.

Also in this session: the `ClearUndo → OnLineChangeEdit → FormDesign` teardown chain from the old Bugbot writeup is **already dead** — the `WithoutShow=True` change to `ClearUndo` (`EditControl.bas`) stops `ClearUndo` from raising `OnLineChange` at all, so the `mAddingTab` guard debate was chasing a path that can no longer fire.

### Still open (non-fatal, deferred)

The underlying wart — MFF getting **multiple `Library` objects with inconsistent `Path` representations** (absolute-backslash DLL path from the toolbox loader vs. relative-forward-slash folder path from the `.vfp` component string), with `Comps["Form"].Tag` binding to the folder one — was not fully cleaned up. The two fixes make it harmless (the module is loaded and now resolves correctly), but the refactored library-loading path (`LoadToolBox` INI/dir-scan branches + `AddProject`'s `ControlLibrary` block + `GetControlLibraryVfpPath`/`GetControlLibraryFolder`) deserves a consolidation pass so one DLL maps to exactly one `Library` object with one canonical path. Low priority; captured here for a future session. **Queued for Cursor in §8 ("Queued for Cursor").**

### Original bug summary (historical investigation record below)

### Bug summary

Opening a `.frm` file: code editor loads and works; design surface **briefly flashes** (form HWND visible) then settles to an **empty grey `pnlForm`**. Behavior worked in the original download; broke during recent workspace/defer/LoadToolBox work. The **LoadToolBox HWND fix** enabled the brief flash (design control gets a valid parent HWND), but a **second `FormDesign` call tears down** the design surface that the first call built.

### Symptom timeline

1. **Original download** — `.frm` opens; code + design surface both work.
2. **After recent changes** — `.frm` would not open at all (HWND/parent issues).
3. **After expert fixes** — file opens; code editor OK; design surface **flash then grey `pnlForm`**.

### Root cause (Bugbot finding)

`AddTab` calls `.FormDesign` (line ~510), then later `.txtCode.ClearUndo` (line ~519). `ClearUndo` → `ChangeText` → `OnLineChangeEdit` with `TextChanged=True` → **`tb->FormDesign(...)`** at line ~3242. That **re-enters `TabWindow.FormDesign`** while `Des->DesignControl` already exists, hitting the teardown block at **lines 8407–8438** (`UnHook`, remove child controls, `DeleteComponentFunc`, clear `Objects`/`Components`/`Controls`). Guards for `mApplyingWorkspaceLoad`, `mApplyingDeferredFormDesign`, `mApplyingFormTabView`, and `mAddingTab` in `OnLineChangeEdit` (~3097) **did not fix** the issue per user — likely because `mAddingTab` is cleared at line ~544 **before** `ClearUndo` side-effects propagate, or `TextChanged` is set again on the `OnLineChange` path.

**Key call chain (AddTab open path):**
```
AddTab → .FormDesign (builds design surface)
       → .txtCode.ClearUndo → ChangeText → OnLineChangeEdit
       → tb->FormDesign (TEARDOWN when Des already set)
       → ApplyFormTabView → RefreshDesignSurface (HWND reparent, but surface already gutted)
```

**`TabWindow.FormDesign` teardown zone:** `src/TabWindow.bas` lines **8364–8455** (teardown at **8407–8438** when `Des->DesignControl` exists).

### Files modified (uncommitted — from `git status` / `git diff --stat`)

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

- **LoadToolBox HWND fix** (`Main.bas` ~4801) — ensures `pApp->MainForm = @frmMain` before toolbox load; design HWND gets valid parent → **flash visible** (partial win).
- **`mApplyingWorkspaceLoad`** — skip immediate `FormDesign` in `AddTab` during `LoadWorkspace`; set `FormNeedDesign=True`; defer via `RunDeferredFormDesign()` after workspace load (`Main.bas` ~9122–9125).
- **`RunDeferredFormDesign`** (`Main.bas` ~4778) — batch deferred design for tabs with `FormNeedDesign`; calls `FormDesign` + `ApplyFormTabView`; ends with `tabCode_SelChange`.
- **`FormNeedDesign` flag** — defer design to `tbrTop_ButtonClick` Form/CodeAndForm paths (`TabWindow.bas` ~508, ~10100–10117).
- **`RefreshDesignSurface`** (`TabWindow.bas` ~313) — `SetParent` design HWND to `pnlForm`, `Des->Dialog`, repaint.
- **`ApplyFormTabView`** refactor (`TabWindow.bas` ~331) — centralize form-tab view setup; `mApplyingFormTabView` guard.
- **`mApplyingDeferredFormDesign` / `mApplyingFormTabView` guards** in `tabCode_SelChange` (`Main.bas` ~8098) — skip toolbar click during deferred apply.
- **`mAddingTab` + re-entrancy guards** in `OnLineChangeEdit` (`TabWindow.bas` ~3097) — suppress `FormDesign` when adding tab; **user reports still broken**.
- **`mAddingTab` lifecycle** in `AddTab` (`TabWindow.bas` ~359, ~544) — set True at start, False before return.

### Opus next steps (narrow scope)

1. **Trace ALL `FormDesign` callers** during `.frm` open via logging or static breakpoint reasoning:
   - `AddTab` ~510
   - `OnLineChangeEdit` ~3242
   - `RunDeferredFormDesign` ~4790
   - `tbrTop_ButtonClick` ~10101/10116
   - `tabCode_SelChange` side-effects
   - Any `OnUndoEdit` / undo paths that set `TextChanged`
2. **`ClearUndo` / `OnLineChangeEdit` / `OnUndoEdit` paths** — confirm whether `ClearUndo` after first `FormDesign` is necessary; consider moving `ClearUndo` before `FormDesign`, skipping `OnLineChange` during `ClearUndo` (`WithoutShow` already True but `ShowCaretPos` may still fire `OnLineChange`), or guarding `FormDesign` when `Des->DesignControl` is valid and tab is initializing.
3. **`TabWindow.FormDesign` teardown (~8407–8438)** — when `DesignControl` already exists during tab init, **skip teardown** or **skip re-entry** entirely (early `Exit Sub` if design surface is fresh/valid).
4. **`RunDeferredFormDesign`**, **`ApplyFormTabView`**, **`tabCode_SelChange`** — verify no duplicate `FormDesign` after deferred batch; check interaction with `mAddingTab=False` timing vs `ClearUndo`.
5. **Revert experiment:** `git checkout --` workspace-defer changes (`RunDeferredFormDesign`, `FormNeedDesign`, `mApplyingWorkspaceLoad` paths) while **keeping LoadToolBox fix only** — isolate whether defer logic introduced the double-call or only exposed it.

### Revert guidance

**Do NOT commit** current broken state. User may roll back to last known good:

```powershell
# Revert specific files
git checkout -- src/Main.bas src/Main.bi src/TabWindow.bas src/TabWindow.bi src/Designer.bas

# Or stash everything (including untracked — use with care)

## 1. Project overview

**Visual FB Editor (VFBE)** is a FreeBASIC IDE with visual designer, debugger, and project support, built on [MyFbFramework](https://github.com/XusinboyBekchanov/MyFbFramework).

This fork (**VFBEWin64**) is a **Win64-only** branch of upstream VisualFBEditor:

| Keep | Remove / defer |
|------|----------------|
| Native **WinAPI / Win32** UI | GTK / Linux IDE paths (physically deleted, not just hidden) |
| **64-bit** IDE and bundled `fbc64.exe` | 32-bit IDE (`VisualFBEditor32`, `mff32`) |
| Bundled compiler at `Compiler\fbc64.exe` (tracked in-repo; staying on 1.10.1 — see Tier 3, no viable 1.10.3 binary exists) | Dark-mode *implementation* — replaced with an inert stub, interface preserved for a future trustworthy reimplementation (not full removal — see §3a) |

**This is now a fully self-contained fork:** `Compiler/`, `Debuggers/`, and `Controls/MyFbFramework/` are tracked in git (previously vendored/gitignored) — see §3a and §12.

**Build outputs (repo root):**

- `mff64.dll` — `Controls\MyFbFramework\mff64.dll`
- `astoria.exe` — main IDE (renamed from `VisualFBEditor64.exe`, 2026-07-10, §13.4)

**Settings:** `Settings/astoria.ini` (renamed from `Settings/VisualFBEditor64.ini`, 2026-07-10 — existing settings preserved; runtime path via `ExePath/Settings/...`)

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

### Guiding principle: feedback-channel policy (added 2026-07-07, Opus "Next Steps" Phase D)

**When something fails or a background state changes, use the channel that matches how disruptive it is** — don't reach for whichever call happens to be nearby:
- **Status bar (`pstBar->Panels[0]->Caption`)** — transient, non-blocking editor/view state the user can glance at or ignore (e.g. "Loading project contents...", "this file is too large for the Form Designer — showing code only").
- **Output panel (`ShowMessages(..., ChangeTab:=False)`)** — build output, background analysis, and anything that happened off-screen that the user might want to check later but shouldn't be interrupted for right now. Pass `ChangeTab:=False` so it doesn't steal focus/switch tabs for routine background events; only let build/compile actions (which the user just triggered) auto-switch to Output.
- **`MsgBox`** — reserved for irreversible actions needing confirmation (delete, overwrite, stop a running program) or a failure that blocks the current operation and needs the user's attention right now (a save that didn't happen, a debugger that can't start). Never call `MsgBox` from a background/worker thread without marshaling to the main thread first (see `THREADING.md` rule 3).

**How to apply:** opportunistically, as each area is touched — **not** as a big-bang sweep across the codebase. Applied so far: `TabWindow.FormDesign`'s 50,000-line Designer cutoff and `LoadFunctions`'s missing-include case (both previously silent) now use the status bar / Output panel respectively (Opus Phase D, F2).

---


## 2. Repository & toolchain

### Git remote

```
origin  https://github.com/dmontaine/astoria-ide.git
branch  main
```

**Codeberg retired 2026-07-09** — `bigriverguy/VFBEWin64` on Codeberg is no longer the working repo; GitHub (`dmontaine/astoria-ide`, renamed lowercase 2026-07-10 following the AstoriaIDE rebrand) is now the sole remote. The Codeberg repo received a final push with its README replaced by a retirement notice pointing here. The old SSH key (`~/.ssh/id_ed25519_codeberg`, host `codeberg.org` in `~/.ssh/config`) is no longer used for this project.

**Note:** Git may not be on PATH in all shells; full path:

`C:\Program Files\Git\bin\git.exe`

### Build before running the IDE

Close any running `astoria.exe` first (`mff64.dll` is locked while the IDE runs).

```powershell
cd C:\Users\don\Astoria-IDE
set NOPAUSE=1
Compile.bat
.\astoria.exe
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
| **Phase 1** | 2.1.1 indentation, 2.1.2 dead code, 2.1.3 magic numbers | **Complete** (2026-07-05) |
| **Phase 2** | 2.2.1 naming conventions, 2.2.2 DRY pass (3 extractions done), 2.2.3 file splits | **Partial** — 2.2.1 + 2.2.2 (conservative) done; 2.2.3 deferred to next session |
| **Phase 3** | 2.3.1 compile-mode toggle, 2.3.2 UI sweep | **Complete** (2026-07-05) |
| **Phase 4** | 2.4.1 final audit, 2.4.2 docs cleanup | **Complete** (2026-07-05) |

> **Process note:** §7's original gate said Batch 2.75.3 should be blocked on full manual sign-off. The owner explicitly chose to start 2.75.3 before that checklist was finished (several boxes below are still open). That was a deliberate call, not an oversight — flagging it here so future sessions don't assume the gate was satisfied by testing.

### GTK strip tool

```powershell
.\Tools\strip_gtk_preprocessor.ps1 src mff
```

Evaluates `#If` / `#Else` / `#EndIf` with Win64 defines (`__USE_WINAPI__`, `__FB_WIN32__`, `__FB_64BIT__`, GTK off). Had a blind spot for the `__EXPORT_PROCS__` symbol (fixed — see §3a); re-run only if new GTK-era files are introduced, and review failures manually for interwoven blocks.

**Safety net for any future re-run (audit flag, 2026-07-03):** the `__EXPORT_PROCS__` blind spot silently deleted `mff64.dll`'s entire export dispatcher, and a clean compile did not catch it — the damage only surfaced when the Designer was exercised at runtime. Before re-running the tool: make sure the working tree is clean so the resulting diff is fully reviewable file-by-file, don't rely on compile-clean alone. After re-running: spot-check that `mff64.dll` still exports the expected symbols (e.g. `dumpbin /exports mff64.dll`) before treating the run as verified.

---



## 3a. Batch 2.75.3 — what actually happened


Full detail archived in [HISTORY.md](HISTORY.md). Key outcomes: Form Designer fix, dark-mode reimplementation with documented APIs, dead-subtree deletion, physical dead-code deletion across src/ and mff/, compile-warning resolution, _WIN32_WINNT header fix, and git-tracking policy change (self-contained fork).

---

## 3b. Examples/ audit — result: nothing to remove

Full detail archived in [HISTORY.md](HISTORY.md). All 33 examples audited for GTK/Linux/Win32-only content — none qualified for removal. Fixed Graphics/CanvasDraw.bas API drift and created missing .vfp project files. WellCOM DllMain still open.

---

## 4. Session history (chronological)

Complete session-by-session history archived in [HISTORY.md](HISTORY.md). Major milestones:

- **2026-07-06:** Form designer grey-panel fixed; File menu (incl. Open Project) and Edit menu step-by-step reviews owner-approved; Search → Define (F2) reliability pass (uncommitted)
- **2026-07-05:** Automatic workspace (.vfs removed); File menu restructure; Run menu consolidation; GDB fixes (Step Out, command queue, Break); bottom panel tab captions fixed
- **2026-07-04:** Dark mode crash #3 fixed (WM_THEMECHANGED recursion); per-form control tree; PagePanel layer navigation
- **2026-07-03:** _WIN32_WINNT header fix (116 locations); dark mode reimplemented; Integrated debugger + alt-compiler backends removed; Tier 3 compiler swap closed (no viable 1.10.3 binary)
- **2026-07-02:** GTK strip + dead-code deletion (Batch 2.75.3); bottom panel fixes; Form Designer export fix

---







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

## 6. Completed work

All completed items have been archived to [CHANGELOG.md](CHANGELOG.md). See that file for the full chronological record of shipped work with commit hashes.

**Still open from this section:**

- [ ] **frmNewProject icons** — template icons not displaying on new form (icon name derivation matches frmTemplates pattern but `@imgList32` may not be populated at form creation time); deferred

---

## 7. Manual test plan — regression validation

> **Handoff note (Claude Code):** Bottom panel **implementation bugs are resolved**, and both left and right panel Pin-click bugs are also now fixed (§4, §6). Batch 2.75.3 (dead-code deletion) **has already happened** — the owner explicitly directed the team to proceed before this checklist was fully signed off, rather than treating it as a hard gate. This checklist is now a **regression-validation pass** covering both the original panel work and the since-completed dead-code deletion, not a pre-2.75.3 gate.

Run a full pass on **latest** `astoria.exe` (formerly `VisualFBEditor64.exe`, renamed §13.4) after `Compile.bat`. Check each box when verified.

### Debugger smoke test (new — added post-2.75.3)

`src/Debug.bas` was the single largest and riskiest file touched in Batch 2.75.3 (core breakpoint/stabs-parsing/debugger-dispatch internals). Dead-code deletion there was verified by clean compilation only; a compile-clean build can still hide a runtime behavior change if a "dead" branch was misjudged.

- [~] Integrated IDE debugger (non-GDB path) — **deprioritized**, not tested. Given §4's "GDB is the project's debugger" decision, this path is a candidate for eventual removal rather than something worth validating further right now.
- [x] Step into — line highlighting advances correctly — **owner verified** via GDB path: 2-line loop body (`b = a * 2` / `Print a, b`) stepped 8→9→8→9 per iteration, exactly as expected.
- [x] Inspect a local variable while stopped — **owner verified** via GDB path: values displayed correctly during stepping.
- [x] Integrated GDB debugger path — breakpoint stop + Step Into + inspect all confirmed working — **owner verified**. This also resolved an earlier false "Can not be used for debugging 32bit exe..." error, which turned out to be the *Integrated* (non-GDB) debugger's `check_bitness()` check firing because the debugger type wasn't actually set to GDB yet — not a real 32-bit/64-bit mismatch. `check_bitness()` (`Debug.bas` ~line 9871) doesn't check whether the underlying `GetBinaryType` call actually succeeded, so it can misreport in other failure modes too — low priority given this path is being deprioritized, but worth knowing if it resurfaces.
- [x] ~~Restart-while-debugging and normal stop/exit — no hang or crash~~ — superseded by the two bugs found below; IDE itself never froze, stayed usable throughout.
- [ ] **Gas64 vs GCC backend check** (resolves the open §4 decision point) — still open, deferred along with the bugs below

**Two real bugs found during earlier testing — fixed 2026-07-05:**

1. ~~**Step Out sends the wrong GDB command.**~~ Fixed: `Case "StepOut"` now calls `step_debug("finish")`.
2. ~~**Command dispatch race condition between debug actions.**~~ Fixed: 32-slot command queue under `tlockGDB` replaces the single `NewCommand` string.

**Also fixed 2026-07-05:** **Break while running** — `break_debug()` sends GDB `interrupt`; mutex released during blocking `readpipe` so the UI can inject it.

**Owner's call (2026-07-03):** defer Step Out + command race — **superseded** by fixes above (2026-07-05).

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

### Bottom panel — tab captions & debug tabs (added 2026-07-05, **owner verified complete**)

- [x] Cold start — always-visible tabs show correct names (Output, Problems, Suggestions, Find, ToDo, Change Log, Immediate), not all "Globals"
- [x] Debug tabs (Locals, Globals, Procedures, Threads, Watches, Memory, Profiler) hidden at startup
- [x] Start debugging — debug tabs appear with correct names; end debugging — they hide again
- [x] Start/end debug multiple times — no duplicate tabs, no caption corruption
- [x] Close project — no crash; bottom tab captions remain correct
- [x] Restart IDE — bottom tab order persists (no scrambled order from saved `-1` indices)
- [x] Pin/collapse bottom panel — tab labels stay correct in both modes

### GDB debugger — Step Out, Break, command queue (added 2026-07-05, **pending owner verification**)

- [ ] Step Out — runs until current function returns (not same as Step Over)
- [ ] Rapid step/continue clicks — each enqueued command executes (no silent drops)
- [ ] Break while running — program stops; can inspect state; Continue resumes

### Run menu — debug & run commands (added 2026-07-05, **owner verified complete**)

- [x] **Run** menu contains session, stepping, Use Debugger/Profiler, breakpoints, GDB/watch, set/show next statement — no separate Debug menubar
- [x] **Use Debugger** checks/unchecks; debug tabs show/hide; step/run commands enable when debugger on + project open
- [x] **Use Profiler** disabled when debugger off; unchecks when debugger turned off
- [x] Start / Continue / Step / Run To Cursor / Set Next Statement enable states at startup and with editor focus
- [x] Clear All Breakpoints clears markers across open tabs

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

### Optional / housekeeping

- `docompile.bat` — gitignored local helper at repo root (owner convenience)
- Consider `.gitignore` for `astoria.exe` (formerly `VisualFBEditor64.exe`) if binary commits are undesired (currently committed like initial import)

---

## Open Items

*All open/deferred items consolidated from across the document. Ordered by priority/readiness.*

### Fable review remediation (2026-07-11)

- [ ] **T1–T16 remediation queue** — see [⭐ ACTIVE SUB-PROJECT — Fable review remediation](#-active-sub-project--fable-review-remediation-queued-2026-07-11) for the full ordered task table and per-model instructions (not duplicated here, per the consolidation rule). Note: T6 there *is* the "Breakpoint-during-debug pipe race" item below — one piece of work, tracked once. **Status: Wave 1 (T8–T13) done; T1 done (Option B, per-user install); Wave 3 (T3, T4, T7, T2a, T2b, T17) all done 2026-07-11, each committed individually; next up T16 (Fable's Wave-3 review), then owner smoke test, then Wave 4 (Opus: T5/T6 debugger).**
- [ ] **`<Project>_Change.log` location (owner question, deferred)** — the ChangeLog panel writes per-project changelogs to the **IDE root** (`Main.bas:7063/8619/9481`), not the project folder. Moving them to the project's own folder is more natural but is a behavior change — owner call, separate task. Surfaced by the T1 write-surface survey.
- [ ] **Default `ProjectsPath` → Documents (owner question, deferred)** — new projects default to `.\Projects` inside the app folder; consider defaulting to `Documents\AstoriaIDE Projects` so user work doesn't live in the install dir. Pairs well with §13.5 installer work. Surfaced by the T1 survey.

### Immediate (stubs & bugs)

- [ ] **frmNewProject icons** — template icons not displaying on new form (`@imgList32` may not be populated at form creation time)
- [x] ~~**B3 `OpenRecentFiles()` dialog**~~ — **fixed 2026-07-10 (Sonnet)**, real bug, not a stub. The dialog-based design (`OpenRecentFiles()`/`frmRecentFiles`) this item originally described was superseded at some point by a live **File ▸ Recent Files submenu** (`miRecentFiles`, populated via `AddMRU`/`mClickMRU` — individual entries open on click, plus a "Clear Recently Opened" item) — that part already worked. But the menu item itself had a stray `Visible = False` set at creation (`Main.bas`) that was never restored anywhere, so the whole feature was permanently invisible in the File menu regardless of how many recent files existed; separately, the submenu was never populated from the INI-loaded MRU list at startup, only lazily rebuilt once a file was opened *this* session. Fixed by dropping the `Visible = False` and factoring the item-population logic (previously only inside `AddMRU`) into a shared `RebuildMRUMenu` helper called both from `AddMRU` and once at menu-creation time right after the MRU list loads from the INI — the item is now visible immediately on startup, populated with prior sessions' recent files, and greyed out (not hidden) only when the list is genuinely empty. Compile-clean, launch-tested (process stays responsive).
- [x] ~~**`DeleteEditorFile` project-member `.vfp` sync**~~ — **already done** (found already implemented on review, 2026-07-10; landed in `331b570`, 2026-07-09, undocumented at the time). `DeleteEditorFile` (`Main.bas:1190-1199`) marks the file `ee->PendingDelete` and dirty-flags the project node (`*` suffix); `SaveProject` (`Main.bas:1730-1759`) excludes pending-delete files from the written `.vfp`, then only deletes from disk + removes the tree node after that write succeeds (`Main.bas:1864-1875`) — a full deferred-delete-until-save flow (with a "Cancel Deletion" undo path) that goes further than the originally-scoped dirty-mark mirror.
- [ ] **Toolbar persistence re-test** — confirm the Run-toolbar fix (2026-07-07): hide Run → close via window X → relaunch → stays hidden; `ShowBuildToolBar` gone from INI. Needs GUI.
- [ ] **GDB smoke test** — Step Out, rapid step/continue queue, Break while running — pending owner verification (§7)
- [ ] **Breakpoint-during-debug pipe race (was misfiled as a repaint glitch)** — *owner-reported 2026-07-08, investigated by Sonnet 2026-07-08, escalated to Opus (`.claude` task).* Not a cosmetic paint bug: `PaintControl`/`PaintControl(True)` are actually identical (`PaintControlPriv` forces `bFull = True` unconditionally, `EditControl.bas:4051`), so the original "missing full repaint" hypothesis is disproven. Real cause: `Case "Breakpoint"` (`VisualFBEditor.bas:761`) calls `set_bp` (`Debug.bas:1791`) **only when `iFlagStartDebug = 1`** (i.e. only while actively debugging) — matching the owner's report that this appeared right after a live debug session. `set_bp` sends `break`/`tbreak`/`clear` via `run_pipe_write` + a **direct synchronous `readpipe()` call on the UI thread**, but the debug session's dedicated worker thread (`Debug.bas` ~2024+) is *simultaneously* running its own GDB read/dispatch loop on the **same shared pipe handles** (`Dim Shared As HANDLE hReadPipe, hWritePipe`, `Debug.bas:382`). Every other debug command (Continue, Step, etc.) avoids this by going through the mutex-protected `EnqueueDebugCommand` queue that the worker thread drains safely (`Debug.bas:325`, `:2031`) — `set_bp` is the one command that bypasses the queue and races the worker thread's reads on the same handles. Genuine correctness bug (GDB's response to `break ...` can be stolen by whichever thread's `ReadFile` wins), not just cosmetic — the blank-editor symptom is a plausible downstream effect of the worker thread stalling on stolen output. **Fix needs care:** route `set_bp`'s commands through `EnqueueDebugCommand` like Continue/Step, then handle the "breakpoint set" confirmation asynchronously without blocking the UI thread — requires live GDB verification during an active debug session (same fragile-core/live-verify bar as R5). Assigned to Opus, not Sonnet.

  **Opus attempt #1 (2026-07-08) — reverted, introduced a lock.** Tried exactly that: `set_bp` enqueues `break`/`tbreak`/`clear`, and the worker loop got a "drain-only" branch (`writepipe(cmd) : readpipe()`, no stop-processing) for those commands. Compiled clean but **owner live-test hit a hard lock** (set a breakpoint, a couple of Step-Into, then Run → froze). Reverted `Debug.bas` to the R5 commit; rebuilt known-good. **Lessons for attempt #2:**
  - The drain-only `readpipe()` **blocks (polls forever) if GDB isn't at the prompt** when the break command is dequeued (e.g. a `break` dequeued right after a `c\n`/step that set `Running=True`, so the inferior is running) — and it holds `tlockGDB` while blocked, so the UI thread deadlocks on its next lock. A correct fix must only send break/tbreak/clear **while the inferior is stopped** (not just "when dequeued"), or must not hold `tlockGDB` across a blocking read.
  - **Path facts (verified):** `F9` is the menu "Breakpoint" command (`HotKeys.txt: Breakpoint=F9`) → `mClick` → `set_bp` + `ec->Breakpoint`. **Gutter-click goes through `EditControl.Breakpoint` only — it never calls `set_bp`** (0 hits in `EditControl.bas`), so a gutter-set breakpoint mid-session toggles only the local icon and is *not* sent to GDB until the next run. So `set_bp` (F9/menu) is the only mid-session→GDB path.
  - **Pre-existing ordering bug (not mine):** in `mClick`, `set_bp` runs *before* `ec->Breakpoint`'s blank/comment-line check, so F9 on a comment line enqueues a bad `break` to GDB even though the local toggle is (correctly) refused with the "Don't set breakpoint to this line" MsgBox → GDB/local divergence.
  - **Strong recommendation for attempt #2:** do NOT keep guessing — instrument the queue / worker loop / `set_bp` with file-trace (`DbgTraceCP`-style), have the owner reproduce the exact set-bp → step → Run lock, and read the command/response sequence + where it blocks. Then fix precisely (likely: gate break-command send on `Not Running`, and move the comment-check ahead of `set_bp`).
- [ ] **Designer/Property undo-redo not recorded** — *pre-existing, surfaced during the P4 live-test 2026-07-07.* Undo/redo works for **text-editor** edits but **not** for changes made in the visual Designer or the Property tab. Likely cause: Designer/property-grid-driven code changes write to the source via a path that doesn't push an entry onto the `EditControl` undo stack, so there's nothing to undo. Designer undo is genuinely hard; scope with owner before attempting. Good candidate for the file-trace method (log the property-apply/designer-move → undo-stack path). Not P4-related (confirmed on the clean baseline).
- [ ] **Ctrl+Y = "Cut Current Line" (approachability gotcha)** — *surfaced 2026-07-07.* Redo is `Ctrl+Shift+Z` (intentional default, three sites + `HotKeys.txt`), which is fine; but `Ctrl+Y` is bound to **Cut Current Line** (`Main.bas:5802`). Returning QBasic/VB users reflexively press Ctrl+Y expecting *redo* and instead delete the current line. Consider for the §13.3 approachability pass (e.g. also bind Ctrl+Y → Redo, or surface the mapping). Owner decision, not a bug.

### Low-priority cleanup

*(`src/makefile` and `src/THREADING.md` GTK-reference entries removed 2026-07-07 — both were already resolved by commit `6b3200a`; the Open Items entries had just gone stale. See §13.3.A S5–S7 execution.)*

### Queued for Cursor

- [ ] **MFF control library path consolidation** — one DLL → one `Library` object with one canonical path; retire `GetModuleFileNameW` workaround in `Designer.Symbols` (§8)

### Deferred enhancements (nice to have, not blocking)

- [ ] **2.2.3 Split oversized files** — `TabWindow.bas` (576 KB), `Main.bas` (412 KB), `EditControl.bas` (316 KB) (§13.2)
- [ ] **13.9 Blank Designer page on cold-open** — `PagePanel` page shows blank until a control is selected; cosmetic only (§13.9)
- [ ] **13.10 Dark mode: owner-drawn popup menus + input-field polish** — `WM_DRAWITEM ODT_MENU` handler is an empty stub; input-field faces stay light (§13.10)
- [ ] **13.11 Dark mode: dark dialog backgrounds** — `WM_ERASEBKGND` not filled with dark brush; gate on window class (§13.11)
- [ ] **13.8 Design-workspace status bar** — three-cell status bar docked to `pnlForm`; researched, non-trivial (§13.8)

### Unscheduled / future planning

- [ ] **13.3 UI review** - File + Edit owner-approved; Search → Define (F2) reliability improved. **13.3.A S1–S7 executed and committed (Sonnet 2026-07-06/07, Opus-reviewed)** — see [13.3.A execution](#133a-execution--s1s4-done-sonnet-2026-07-06-opus-reviewed--committed-2026-07-07) above; this already restructured every menu including View (Fold submenu, Debug Windows split). **Owner walkthrough/sign-off of the View menu** is the next step-by-step checkpoint (design/implementation done, approval pending).
- [ ] **13.2.1.1 Standardize indentation** — convert mixed tabs/spaces across all source files (§13.2)
- [x] ~~**13.4 Rename the project**~~ — **DONE 2026-07-10** (`c93abbe`): renamed to **AstoriaIDE** (`astoria.exe`, `Settings/astoria.ini`, `AstoriaIDE.bas/.rc/.vfp`); see ROADMAP §13.4 for the full touch-point list. GitHub repo name/clone URL intentionally left unchanged (separate decision).
- [ ] **13.5 Standard Windows installer** — Inno Setup or WiX; project-rename decision is now resolved (§13.4 done), so this is unblocked (§13.5)
- [ ] **13.6 Full review/expansion of Examples/** — re-verify all examples compile; fix `WellCOM` DllMain; add appealing demos (§13.6)
- [x] ~~**13.7 Enhance AI integration**~~ — **REVERSED by owner 2026-07-09**: AI subsystem being removed entirely instead (see ⭐ AI Agent subsystem removal sub-project above; ROADMAP.md §13.7)
- [ ] **Upstream sync strategy** — this fork intentionally diverges; merge only with explicit plan
- [ ] **Wiki/docs** — fork-specific documentation
- [ ] **Basic CI** — run `Compile.bat` on push

---

## 8. Planned next steps (historical design & research)

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

*Planning items consolidated into [Open Items](#open-items) above. The historical design research and bug analyses below are preserved for reference.*

### Tier 3 — compiler toolchain (closed)

Tier 3 (compiler swap to 1.10.3) was attempted 2026-07-03 and closed: no viable 1.10.3 Windows binary exists anywhere. Staying on bundled FBC 1.10.1. Full writeup in §4. Longer term: vendor FreeBASIC compiler source into repo for AI-assisted review — natural point to revisit building a newer FBC from source.

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
- **Every session ends with a compile-clean commit + push to GitHub** (added 2026-07-03; compile-clean gate added 2026-07-03 after a second-AI audit flagged the risk of pushing broken intermediate state; **remote switched from Codeberg to GitHub 2026-07-09, Codeberg retired**) — run `Compile.bat` and confirm **0 errors** first. Only if the compile is clean should you commit any outstanding working-tree changes (status doc updates, INI/scratch state, etc.) with a sensible message, then `git push origin main`, as the last action before signing off for the day. If the compile fails and can't be fixed in-session, say so and hold off on the commit/push rather than pushing broken code. This is a standing instruction, not a one-time request — don't wait to be asked again in future sessions.
- **INI key migration** (added 2026-07-03, second-AI audit) — new keys must ship with a default (never assume an existing user's INI has it); never rename or repurpose an existing key without a migration read of the old key name first, so existing users' settings aren't silently orphaned. This was the rule §13.4's rename followed when it renamed `Settings/VisualFBEditor64.ini` → `Settings/astoria.ini` (existing settings preserved, not a fresh file); applies to any INI key work going forward.
- **WinAPI only** — do not reintroduce GTK/Linux IDE paths
- Close running IDE before rebuild
- `set NOPAUSE=1` for agent compile runs
- Prefer `Compile.bat` over ad-hoc `fbc64` unless debugging
- **Compile logs** (added 2026-07-05) — all compile log output goes to `Logs/<name>.txt`; delete contents of `Logs/` at the end of each session. `Logs/` is in `.gitignore`.
- **Cross-reference before deleting/moving** (added 2026-07-05) — after deleting or moving any item (menu item, control, function, variable, etc.), search the entire `src/` tree for references to that item and update or remove them before proceeding. A clean compile is not sufficient — dormant paths like `ChangeMenuItemsEnabled` can hold stale references that only trigger at runtime.
- **Model-assignment check** (added 2026-07-11, owner rule) — when the owner starts a task that this document assigns to a **different** model (e.g. a T1–T16 row, or any task with an explicit "Owner: Sonnet/Opus/Haiku/Fable" designation), the session's model must **warn the owner of the mismatch before doing any work** — state which model the task is assigned to and why (the assignment tiers exist because fragile-core work needs the live-verification bar and mechanical work shouldn't burn review-tier capacity). Proceed only if the owner confirms after the warning; a confirmation is per-task, not standing. Tasks with no recorded assignment need no warning.

---

## 10. Key files map

| Area | Files |
|------|--------|
| Entry point | `src/AstoriaIDE.bas` (renamed from `src/VisualFBEditor.bas`, §13.4) (`_NOT_AUTORUN_FORMS_`) |
| Main UI & panels | `src/Main.bas`, `src/Main.bi` |
| Toolbar / commands | `src/AstoriaIDE.bas` (`PinBottom`, etc.) |
| Settings load/save | `src/SettingsService.bas`, `Settings/astoria.ini` |
| Tab editor chrome | `src/TabWindow.bas` |
| Splash | `src/frmSplash.frm` |
| Framework | `Controls/MyFbFramework/mff/` → `mff64.dll` (`TabControl.DetachTab` added 2026-07-05) |
| Workspace | `Settings/Workspace.ini` (auto save/restore; not user-facing) |
| File dialogs | `src/frmNewFile.*`, `src/frmOpenProject.*`, `src/frmRecentProjects.*` |
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
| `4cf7275` | Fix critical `_WIN32_WINNT` header bug blocking user-project compiles; bottom-panel tab clearing on project close |
| `4bd0289` | Add missing example `.vfp` project files; audit Examples/ for GTK/Linux/Win32-only; add "no unnecessary options" guiding principle |
| `51441d7` | Fix `Graphics/CanvasDraw.bas` example against current `mff` API |
| `e139c2c` | Remove leftover 32-bit GCC internals (`i686-w64-mingw32`); clarify gas64/gcc relationship |
| `5021314` | Lock in decision: implement both gas64 and gcc backends, remove gas64 if GDB debugging fails |
| `59cd42c` | Close Tier 3 (compiler swap): no viable 1.10.3 binary exists, staying on 1.10.1 |
| `0934416` | Finalize gas64/GDB decision: gas64 is dead, Development/Final both use `-gen gcc` |
| `3886f3d` | Add note: UI/settings sweep for GTK/Linux/alt-compiler/alt-debugger remnants |
| `5fa5cf2` | Remove Integrated (stabs) debugger engine and alt-compiler-backend/debugger-choice code (~10,360 lines deleted) |
| `b3633bc` | Reimplement dark mode with documented Win32 APIs; fix startup-hang regression from `SettingsService` infinite loop |
| `a7c7839` | Fix General-options checkbox overlap (`ControlIndex` + `RequestAlign` on page visibility); flag Form Designer multi-page scalability concern |
| `f371d21` | Fix two real dark-mode crash bugs (`WM_SETTINGCHANGE` ANSI string + early-startup broadcast); document third still-open crash |
| `fd33a05` | Characterize and scope the Form Designer navigation gap; confirmed salvageable with additive scope, not a rewrite |
| `f292db0` | Add per-form control tree to project Explorer; fix File > Close All leaving empty project tree behind |
| `0c08fe5` | Add PagePanel layer/page navigation (tree + right-click menu + Ctrl+PageUp/PageDown); fix right-click-never-selects and load-time page-visibility bugs |
| `389f3ce` | Fix dark mode crash #3 (WM_THEMECHANGED ↔ SetWindowTheme infinite recursion → stack overflow); complete tab/body dark rendering |
| `d877cef` | Safe dark popup menus scaffolding; right panel pin fix |
| `7261267` | Phase 2 cleanup: magic numbers, dead code, naming fixes, orphaned UI, Development/Final compile toggle |
| `d7608ae` | 2.2.2 DRY: `SaveTabPagePlacement()` extraction (19 WriteString/Integer pairs → helper) |
| `6b3200a` | 2.4.1/2.4.2: delete `src/makefile` (Linux/GTK build system); fix `THREADING.md` GTK reference; remove final `__USE_GTK__` comment |
| `49ec5cc` | UI evaluation fixes: menu labels, dialog cleanup, debug tabs, Code Editor grouping, compiler options simplification, editor defaults |
| `37ba31e` | UI evaluation: File menu restructure, `frmNewProject`, debug tabs, startup options, MRU fix, editor defaults |
| `b9735e8` | Replace `.vfs` sessions with automatic workspace; restructure File menu; fix bottom panel tab captions |
| `ec42ea8` | Win64 IDE cleanup: simplify menus (Run menu consolidation), projects, build, and debugger (GDB fixes: Step Out, command queue, Break) |
| `cc9e7dd` | Fix form designer grey panel: resolve MFF control library by live module handle via `GetModuleFileNameW` |

---

## 13. Future enhancements

Full enhancement specs archived in [ROADMAP.md](ROADMAP.md). Quick reference:

| ID | Enhancement | Status |
|----|-------------|--------|
| 13.1 | Evaluate later GCC version | **Closed** — evaluated, declined |
| 13.2 | Structured programming pass (4 phases) | Phases 1-4 mostly complete; 2.1.1 indentation + 2.2.3 file splits deferred |
| 13.3 | UI evaluation & modernization | **In progress** — File + Edit owner-approved; 13.3.A S1–S7 committed (restructured every menu incl. View); owner sign-off on View menu next |
| 13.4 | Rename project | **Done (2026-07-10)** — renamed to **AstoriaIDE** (`c93abbe`) |
| 13.5 | Standard Windows installer | Unscheduled — 13.4 dependency now resolved |
| 13.6 | Full review/expansion of Examples/ | Unscheduled — doc/polish phase |
| 13.7 | ~~Enhance AI integration~~ | **Reversed (owner, 2026-07-09)** — AI subsystem being removed entirely; see AI-removal sub-project |
| 13.8 | Design-workspace status bar | Deferred — non-trivial |
| 13.9 | Blank Designer page on cold-open | Deferred — cosmetic only |
| 13.10 | Dark mode popup menus + input polish | Deferred |
| 13.11 | Dark mode dialog backgrounds | Deferred |

---

## Document maintenance

This document is the project's primary handoff artifact. To keep it navigable:

- **Add new content chronologically** within the relevant section rather than always at the top.
- **When a section exceeds ~100 lines of dense prose**, consider whether the new content justifies a new subsection or should replace older detail.
- **Remove, don't strike-through.** Once a bug is fixed and committed, strip its in-progress investigation notes — the root-cause analysis and fix description are worth keeping; the chronological debugging log usually isn't.
- **Update the [Current State](#current-state-2026-07-06) table** whenever a major area's status changes (bug fixed, feature shipped, new active work item).
- **Consolidate deferred items into [Open Items](#open-items)** rather than letting them drift across §7, §8, and §13.
- **Update the commit log (§12)** at the end of each session — it's the canonical chronological index of what shipped.
- **Cross-reference with `[section name](#anchor)` links** rather than bare "see §N" — anchors survive section renumbering better.
- **Target length:** aim to keep this document under ~800 lines (currently 708). If it grows past that, move content to the companion files listed below rather than expanding this file.
- **Companion files:** [CHANGELOG.md](CHANGELOG.md) (completed work + commit log), [HISTORY.md](HISTORY.md) (session history + bug investigations), [ROADMAP.md](ROADMAP.md) (full enhancement specs).

---

*End of status document.*
