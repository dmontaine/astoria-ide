# Astoria-IDE — Project Status & Handoff

**Last updated:** 2026-07-13 (this machine, unpushed — see banner below)
**Repository:** [github.com/dmontaine/astoria-ide](https://github.com/dmontaine/astoria-ide)
**Local path:** C:\Users\don\Astoria-IDE

This is the concise, authoritative handoff for the next work session. Completed-work narratives, investigations, and dated session notes are archived in [HISTORY.md](HISTORY.md). Shipped changes are indexed in [CHANGELOG.md](CHANGELOG.md), and fuller enhancement specifications live in [ROADMAP.md](ROADMAP.md).

## ⚠️ UNPUSHED — branches diverged, needs a manual merge before any more work

This machine has one local commit, **`2e160bb` "Examples: English-only translation cleanup + dead code sweep"**, sitting on top of `ffc21f3`, that is **not pushed** to `origin/main`. `git push` was rejected because `origin/main` moved on (presumably from the other computer) to `56fb483`, nine commits ahead of `ffc21f3`:

```
ffc21f3 (common ancestor — last commit this machine had before today's work)
├─ 2e160bb  Examples: English-only translation cleanup + dead code sweep   [LOCAL ONLY, this machine]
└─ 05ff947 → 472b4b2 → d48a6cd → cc31921 → cac01fd → 7b26251 → 28ac835 → f875fcc → 56fb483   [origin/main, from the other computer]
```

**Two of the origin commits directly overlap this machine's work** — likely doing some or all of the same cleanup independently:
- `56fb483 Translate Chinese comments to English in Examples/`
- `f875fcc MFF hygiene: remove dead Chinese-language leftovers, close out the rest`

**One origin commit renames a directory this machine's commit heavily edited**, which will produce path conflicts on merge/rebase:
- `cc31921 Rename Controls/MyFbFramework to Controls/Framework` (then `cac01fd`/`472b4b2` move the DLL around inside it again)

Did not attempt an automatic merge or rebase — real risk of silently duplicating or dropping work given the overlapping scope, and no budget left this session to see a conflict resolution through safely. **Before starting new work:**
1. `git fetch origin` (already done, so `origin/main` is up to date locally as of this note) then `git log 56fb483 --stat` / diff the two overlapping commits above against `2e160bb` to see how much they actually duplicate.
2. Likely resolution: `git rebase origin/main` (or merge) on this machine, dropping/skipping whatever hunks the other computer's `56fb483`/`f875fcc` already covered, keeping only what's genuinely new here (the dead-code sweep in `2e160bb` — batches 1/2/4/6/7/8 mostly touch files/categories the origin commits' titles don't mention, e.g. `SoundPlayer`, `directshow`/`directsound`, `Com_VBA`/`MDIScintilla`/`AiAgent`/`WebBrowser`, `Tools/` — but verify, don't assume).
3. Re-home any surviving edits under `Controls/MyFbFramework/...` to `Controls/Framework/...` per the origin rename before pushing.
4. This machine's full rationale for the translation cleanup (including the ChineseCalendar/gdipClock/gdipGoldFish/Midi deletion chain) and the dead-code sweep is below, unchanged — needed context for judging what's actually new vs. already covered upstream.

<a id="active-sub-project--debugger-reliability-queued-2026-07-11"></a>

## Debugger Reliability (Complete)

All DR-1 through DR-16 defects are fixed and owner-verified. This retained anchor keeps links from older historical records valid.

## Current State (2026-07-13)

- The IDE is Win64-only, builds cleanly with the bundled FBC 1.10.1 toolchain, and produces astoria.exe.
- The project title is **Astoria-IDE**. The GitHub repository name remains astoria-ide.
- **Debugger Reliability (DR-1 through DR-16) is closed:** all known defects were fixed and owner-verified.
- **MyFbFramework review is closed:** the six applicable tasks are complete; the remaining three became moot when HTTPServer was removed.
- **H-1 is complete:** `Canvas.Cls` no longer creates a GDI brush on its Direct2D clear path and closes a Direct2D drawing session before returning. `mff64.dll` and `astoria.exe` rebuilt successfully; owner smoke test passed. (Direct2D itself was fully removed the same day — see below — so this fix is now only preserved in git history, recoverable per [DIRECT2D_REMOVAL.md](DIRECT2D_REMOVAL.md).)
- **H-4 is complete:** removed the duplicate GDI `FillRect` in `Canvas.Cls`. `mff64.dll` and `astoria.exe` rebuilt successfully; owner smoke test passed.
- **View menu owner review is complete:** owner walkthrough surfaced six real bugs, all fixed and rebuilt clean:
  - Code/Form/Code and Form were enabled for any `.bas` file, not just form-capable ones (`.frm`, or a file whose design already found a class/controls); fixed across all four sync points (`tabCode_SelChange`, `ApplyFormTabView`, `ApplyView`, `ChangeMenuItemsEnabled`).
  - "Goto Code/Form" renamed to **Switch Form/Code**.
  - Switch Form/Code is a no-op in Code+Form split view (both panels already visible) — now greyed there.
  - Split Horizontally/Vertically (they split the code editor) are now greyed in Form-only view, where the code editor isn't visible.
  - Fold is now greyed in Form-only view for the same reason.
  - Debug Windows submenu is now greyed whenever Run → Use Debugger is unchecked (wired into `ChangeUseDebugger`, the single function all debugger-toggle paths funnel through).
- **Four deferred owner decisions resolved:**
  - **Change Log location:** each project's `<ProjectName>_Change.log` now lives in that project's own folder (`GetChangeLogPath`) instead of at `ExePath`, and is shown as a node under the project tree's **Others** folder (or the project root in flat/no-folders mode) via `EnsureChangeLogTreeNode` — added on project load (`AddProject`) and on folder-display-mode toggle (`ChangeFolderType`); double-clicking it jumps to the Change Log tab; renaming it is blocked (it's a synthesized node, not a real project file). Skipped for "show as folder" projects — the log is a real file in that folder already, so the filesystem-backed view shows it with no extra code.
  - **New-project subfolder layout:** owner decided each new project should get its own subfolder inside the configured Projects directory — already matched: `frmNewProject.frm` already creates each new project in its own `<ProjectsPath>\<ProjectName>\` subfolder (not flat), and `frmOpenProject.frm`'s project scan already expects that layout. No code change needed; decision recorded as confirming existing behavior.
  - **Default Projects Path:** owner decided the default must stay `./Projects` (relative to `ExePath`), never Documents, unless the user explicitly points it elsewhere via Tools ▸ Options ▸ General ▸ Projects Path — already matched: `SettingsService.bas` reads `iniSettings.ReadString("Options", "ProjectsPath", "./Projects")`. No code change needed.
  - **Theme storage:** already matched the decision — default and user themes both live in `Settings/Themes/` with no split location today. No code change needed; decision recorded as confirming existing behavior (in-place edits to a shipped theme's `.ini` remain expected behavior, not a bug, per this decision).
- **Run menu fully consolidated:** removed both the "More Build Options" and "More Debug Options" submenus; all their items (Rebuild All, Clean, Syntax Check, Make, Parameters, Run Without Building, Run To Cursor, Continue, Break, Clear All Breakpoints, Add Watch, Set/Show Next Statement, Use Profiler, GDB Command) now sit directly in the top-level Run menu, per owner's chosen "flatten into top level" approach. No commands remain split off into a buried submenu. Rebuilt clean.
- **Toolbar tooltip audit complete:** 13 buttons across the main toolbars (Pin ×3 on the left/right/bottom panels, Text/Component in the Form toolbox, Categorized/Properties in the Properties and Events panels, Clear Output/Erase Immediate Window/Add Watch/Remove Watch/Update in the bottom panel) had hint text already written but `ShowHint` left `False`, so the tooltip silently never displayed — fixed by setting `ShowHint = True`. `frmImageManager.frm`'s toolbar (Add/Add From.../Change/Remove/Up/Down/Sort) had no hint text at all — added. Deliberately left out of scope: the toolbar buttons that host an embedded child control (build-configuration combo, project/toolbox/properties/events search boxes, code-editor class/function dropdowns) — a tooltip there needs to go on the child control, not the `ToolButton` wrapper, which is a different mechanism than the fix applied here. Rebuilt clean.
- **Direct2D fully removed:** owner decision — GDI/GDI+ is now the sole rendering path everywhere (both the IDE's own code editor and the MFF `Canvas` control end-user programs use), replacing the "Use Direct2D" toggle discussion. Direct2D had been force-disabled its entire life (never live-tested) and already had one real bug found in it (H-1); rather than keep a second, unproven rendering path around, it was stripped entirely: `src/EditControl.bas`/`.bi`, `Controls/MyFbFramework/mff/Canvas.bas`/`.bi`, the `D2D1.bi` API binding module (deleted outright, ~2760 lines), the toolbar button/Options checkbox/INI setting, and the Canvas example project's Direct2D radio option. GDI/GDI+ behavior is untouched. Full rationale, scope, and git-based recovery instructions in [DIRECT2D_REMOVAL.md](DIRECT2D_REMOVAL.md) — owner's stated plan is to reconsider Direct2D only once proven stable, and to make it the *sole* default then, not a re-added option. Rebuilt clean (0 errors, 0 warnings) and owner-verified live in the running IDE — toolbar, Run menu, Options dialog, and the six View-menu fixes all re-exercised interactively with no regressions found.
- **Examples translation cleanup complete:** owner decision extended the English-only mandate from IDE chrome (a510b24/e83212f) to the `Examples/`, `Controls/MyFbFramework/examples/`, and `Tools/` trees. Removed 29 `.lng`/`Languages/` translation files (plus their auto-generated `english.html` doc previews) across 17 example/tool projects — safe because `Application.CurLanguage` (`Controls/MyFbFramework/mff/Application.bas`) fails open on a missing `.lng` file (prints a message, keeps the prior/English value) rather than erroring, so every affected example still runs identically. Fixed the two `.vfp` manifests that explicitly listed their `.lng` as a `File=` entry (`Examples/Game/Calculator/Calculator.vfp`, `Examples/Game/Maze/Maze.vfp`), and removed `Examples/MDIForm/MDIMain.frm`'s `Form_Close` hook that re-wrote a `<Language>.lng` file on every exit. Deleted `Controls/MyFbFramework/README_CN.md` and `changes_cn.txt` (Chinese-language docs; PROJECT_STATUS had flagged these previously) and the now-dangling `README_CN.md` link/`.vfp` entry that referenced them. Separately, `Examples/ChineseCalendar` had no `.lng` file at all — its Chinese lunar-calendar content (GanZhi, zodiac, month/holiday names, some PRC-specific) was hardcoded directly into `Lunar.bi`/`LunarCalendar.bi` and actually rendered on screen, so it wasn't a simple file deletion. `Examples/gdipClock` turned out to share that same dependency (`gdipDay.bi`/`gdipMonth.bas` `#include` `ChineseCalendar/Lunar.bi` and render the same Chinese text in its Day/Month calendar views, woven hundreds of lines deep into `frmClock.frm`'s menus/settings — not a clean strip). The cascade went one level further: `Examples/gdipGoldFish` and `Examples/Midi` both `#include` gdipClock's generic (non-Chinese) `gdip.bi`/`gdipAnimate.bi` helper files, and `gdipClock` in turn `#include`s `Midi/midi.bi` back (a mutual pair) plus `Sapi/Speech.bi` and `MDINotepad/Text.bi` (one-directional, no cascade — those two stand alone). Owner decided to delete the whole chain — `ChineseCalendar`, `gdipClock`, `gdipGoldFish`, and `Midi` — rather than attempt to decouple or rewrite gdipClock's calendar feature. Confirmed via repo-wide grep that nothing else references any of the four before deleting.
- **Examples dead-code sweep complete:** owner asked to remove dead code (commented-out blocks, unused private subs/functions/variables, unreachable code, unused `#include`s/dead `.bi` declarations) from every example/tool project under `Examples/`, `Controls/MyFbFramework/examples/`, and `Tools/` — ~55 projects, done in 8 parallel batches. Net result: 130 files changed, ~2,200 lines of dead code removed, 0 whole files or working behavior touched. Safety approach: this framework wires UI event handlers explicitly via `@HandlerName` address-of casts (confirmed in `Examples/DeviceExplorer/frmDeviceExplorer.frm`), not invisible reflection, so a repo-wide grep per identifier was a reliable "is this really dead" check; every batch was instructed to flag rather than guess on anything ambiguous, and to leave vendored API/COM/protocol binding headers (COM interfaces, Scintilla/Lexilla, USB SDK ports, Mongoose, SQLite, DirectShow/DirectSound) alone since "unused" entries there are normal reference-surface, not dead code. Notable finds surfaced along the way but deliberately left unfixed (out of scope for a dead-code pass):
  - `Examples/MultipleDisplay/Monitor.bas`: `EnumDisplayMonitorProc`'s `GetMonitorInfo` call is commented out, so `mtrMIEx(i).szDevice` is read later but never actually populated — a real latent bug.
  - `Examples/Bass/frmLiveFX.frm` (`InitDevice`): `If fx(2) Then BASS_ChannelRemoveFX(chan, fx(1))` looks like a copy-paste index bug (removes `fx(1)` instead of `fx(2)`).
  - `Examples/MDINotepad/MDIMain.frm` (`mnuFormat_Click`): `Case` lists test dead string literals `"mnuEncodingCRLF"/"mnuEncodingLF"/"mnuEncodingCR"` instead of the real control names `mnuEOLCRLF`/`mnuEOLLF`/`mnuEOLCR` — harmless today only because the correct names are also present as fallback alternates in the same `Case` line.
  - `Examples/DeviceExplorer/DeviceExplorer.bi` includes `../USBView/USBView.bi` with nothing from it referenced in DeviceExplorer's own code — but the prebuilt `DeviceExplorer64.exe` contains USBView strings, so this may be an intentional combined-build link rather than a leftover; flagged, not touched, since USBView wasn't in that batch's scope.
  - `Examples/MDIScintilla/MDIMain.frm`: `MDIChildDoubleClick` is implemented but its only call site was commented out, while the identical feature is active in sibling project `MDIScintillaControl` — reads as an intentionally-disabled feature here, left as-is pending an owner decision.
  - `Examples/IFileDialog/`: `IFileDialog.bi`'s test functions look unreachable under normal `__FB_MAIN__` semantics, but `frmIFileDialog.frm` is disabled in the `.vfp` project file while `IFileDialog.bi` is the active entry point — build-mode semantics weren't fully verified, so nothing was removed.
- Nothing is awaiting an owner response. The remaining items below are deferred or ready for a new, explicitly selected task.

## Next ready work

No task is currently selected. Choose from the open items below when ready.

For the reasoning, exact code locations, and prior hot-path findings, see [HISTORY.md](HISTORY.md).

## Open items

### Immediate

- [ ] Add a missing-executable check and user-visible message to the non-debug RunProgram/RunPr path.

### MFF hygiene and technical debt

- [ ] Consider the standalone-Canvas device-ownership issue only with a dedicated test harness; it is not exercised by the IDE.
- [ ] MFF control-library path consolidation.

### Deferred enhancements

- [ ] Standard Windows installer (per-user install model is approved).
- [ ] Full Examples review and expansion.
- [ ] Split oversized source files and standardize indentation.
- [ ] Form Designer cold-open blank page.
- [ ] Dark-mode popup menus, dialog backgrounds, and live re-theming on Options Apply.
- [ ] Design-workspace status bar.
- [ ] Establish an explicit upstream-sync strategy.
- [ ] Fork-specific wiki/documentation.
- [ ] Add tooltips to the embedded-child-control toolbar buttons (build-configuration combo, the four search boxes, code-editor class/function dropdowns) — needs a hint on the child control itself, not the `ToolButton` wrapper. Out of scope for the 2026-07-13 toolbar tooltip audit.

## Essential gotchas

1. After any source change, rebuild and commit the **release** executable with Compile.bat; MFF source reachable from mff.bi also needs FORCE_MFF=1 so mff64.dll is rebuilt.
2. UseDebugger=false in Settings/astoria.ini may be stale because it is written on clean exit. The live **Run → Use Debugger** toggle is authoritative.
3. Programs without a bound breakpoint run to exit. Breakpoints on comment lines do not bind.
4. Trace logs are local-only and ignored by Git.
5. Source files have mixed line endings; use small, byte-precise edits rather than broad multiline replacements.
6. If a script launches astoria.exe, click its title bar before testing. A background-launched app may not receive true foreground focus, producing misleading test symptoms.
7. Registry.bi is orphaned source and is not part of the MFF build graph. Check mff.bi includes before assuming an MFF edit will be compiled.
8. Supporting review documents live in P:\Astoria-Docs; they are not brought over by git pull.

## Working rules

- Keep changes narrowly scoped and match the surrounding code style.
- Before changing UI, startup, or settings behavior, map the affected surface, audit first-run/INI behavior, compile, and prepare a whole-area test checklist.
- Do not change the GDB worker loop without focused trace evidence and owner reproduction.
- Debugger fixes require owner live verification; compile-clean alone is insufficient.
- Before deleting or moving code, search all of src/ for references.
- New INI keys require defaults. Renames or repurposed keys require migration from the old key.
- Use WinAPI only; do not restore GTK/Linux code paths.
- Close the IDE before rebuilding; set NOPAUSE=1 for unattended builds.
- Use Compile.bat rather than ad-hoc compiler calls unless diagnosing the build.
- Treat commits and pushes as explicit actions: commit only when requested or when the user confirms the session should be finalized; compile cleanly first.

## Key files

| Area | Files |
|---|---|
| Entry point | src/AstoriaIDE.bas |
| Main UI and panels | src/Main.bas, src/Main.bi |
| Toolbar and commands | src/AstoriaIDE.bas |
| Settings | src/SettingsService.bas, Settings/astoria.ini |
| Editor chrome | src/TabWindow.bas |
| MFF framework | Controls/MyFbFramework/mff/ → mff64.dll |
| Build | Compile.bat, CompileDebug.bat |

## Reference material

- [HISTORY.md](HISTORY.md) — detailed investigations, completed sub-projects, dated session notes, and rationale.
- [CHANGELOG.md](CHANGELOG.md) — shipped work and commit history.
- [ROADMAP.md](ROADMAP.md) — full enhancement specifications.
- [DIRECT2D_REMOVAL.md](DIRECT2D_REMOVAL.md) — why Direct2D was removed (2026-07-13), full scope, and git-based instructions to bring it back.

*End of status document.*
