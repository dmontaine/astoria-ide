# Astoria-IDE — Project Status & Handoff

**Last updated:** 2026-07-13 16:44:58 -07:00 (last push)
**Repository:** [github.com/dmontaine/astoria-ide](https://github.com/dmontaine/astoria-ide)
**Local path:** C:\Users\don\Astoria-IDE

This is the concise, authoritative handoff for the next work session. Completed-work narratives, investigations, and dated session notes are archived in [HISTORY.md](HISTORY.md). Shipped changes are indexed in [CHANGELOG.md](CHANGELOG.md), and fuller enhancement specifications live in [ROADMAP.md](ROADMAP.md).

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
- **Missing-executable check added to Run:** the non-debug `RunProgram`/`RunPr` path (`TabWindow.bas`) now checks the target `.exe` exists before launching, matching the pre-flight check the debug path already had via `PrepareDebugSession()`. Rebuilt clean.
- **Debug-mode "Returned code" fixed:** `RunWithDebug` always displayed "Returned code: 0 - No error" regardless of the real outcome (its `Result` was never assigned). Now parses GDB's own completion text into the real exit code (decoding GDB's octal `"exited with code NN"` format), and correctly stays silent — rather than showing a fabricated code — when Stop-while-running force-kills the debuggee. Live-verified both the normal-completion and Stop-while-running cases; see [HISTORY.md](HISTORY.md) for the two follow-up bugs caught along the way (an `SCODE` naming collision, and the Stop-kill-vs-real-exit distinction).
- Also investigated, not fixed: a one-off where a freshly-compiled test program's worker threads exited with `STATUS_CONTROL_C_EXIT` seconds after Start. Antivirus and a "second `run` sent while the first was still live" theory were both checked and ruled out; did not reproduce on a second isolated attempt. No code changed — see [HISTORY.md](HISTORY.md) for what was checked; revisit only if it recurs, capturing `Settings/debug_trace.log` immediately after.
- **MFF hygiene pass closed:** `README_CN.md` and `changes_cn.txt` deleted (dead Chinese-language leftovers), with the `File=README_CN.md` entry removed from `MyFbFramework.vfp` and the dead language-switcher link removed from `Controls/MyFbFramework/README.md`. The other two items on this list were dropped rather than attempted: MFF control-library path consolidation has a standing **Do Not Attempt** verdict from a prior deep review (`P:\Astoria-Docs\Deferred Task Recommendations - Opus.md`, item F2) — it touches the exact code that caused the grey-panel Form Designer bug (`cc9e7dd`) for no user-facing benefit; the standalone-Canvas device-ownership issue (H-2) needs a dedicated test harness that doesn't exist yet before a fix can be attempted or verified (rationale in `7ff604c`). Both remain recoverable from git/doc history if a concrete reason to revisit ever comes up.
- **MFF DLL renamed to `astoria.dll`, relocated to the repo root** (owner request, since MFF is now owned/forked code with significant local changes): source file names untouched, only the compiled build artifact moved. Touched build scripts (`Compile.bat`/`CompileDebug.bat`/`BuildCommon.bat`/`mff.bi`'s `#cmdline` fallback), the runtime `DyLibLoad` in `Main.bas`, `IsMyFbFrameworkLibrary`'s filename check, and — the part that made this more than a rename — `Controls/MyFbFramework/Settings.ini`'s `Lib64`/`HeadersFolder`/`SourcesFolder`/`IncludeFolder`/`Lib*Folder` keys, since the Designer's Toolbox/component-discovery system (`LoadToolBox`) resolves all of those relative to wherever the DLL physically sits — moving the DLL out of `Controls/MyFbFramework/` while its headers/sources stay put would have broken that resolution (the exact grey-panel-bug failure class) had the ini values not been updated to explicit root-relative (`./Controls/MyFbFramework/...`) paths. A stale persisted `Settings/astoria.ini` `[ControlLibraries] Path_1` entry (pre-dating this session, pointing at the old location) caused MFF to briefly load as **two separate DLL instances** simultaneously after the rename — found and fixed after the first live test had already passed (it happened not to break rendering, but risked MFF's shared runtime state); the leftover old `mff64.dll`/`libmff64.dll.a` build artifacts were deleted. `Examples/Add-In`'s two sample files (which `DyLibLoad` the framework to hook into a running IDE) updated to the new path. Live-verified twice: Form Designer renders and the Toolbox populates correctly, both before and after the stale-duplicate fix.
- **Toolbox component picker removed entirely** (owner decision, prompted by investigating why cJSON wasn't showing in the toolbox): the IDE no longer lets a user enable/disable which `Controls\*` libraries appear — every folder with a valid `Settings.ini`/`Lib64` entry is now always loaded, full stop. Deleted the "Add Components" toolbar button and `src/frmComponents.frm` outright; `LoadToolBox` (`Main.bas`) always does a fresh `Controls\*` scan (the old persisted `Settings/astoria.ini` `[ControlLibraries] Path_N`/`Enabled_N` branch and its 2-branch first-run/subsequent-run split are gone), `CtlLibrary->Enabled` is now hardcoded `True`, and `RemoveToolBoxLibraryNodes`/`GetLibKey` were deleted as dead code. Along the way, found and fixed a real bug in `PathUtils.bas`'s `GetFullPath`: it never collapsed `..` segments embedded in the middle of an already-absolute path (only a trailing one) — added `CollapseDotDotSegments`, applied in that one branch. This was masking itself: the MFF-DLL-rename work above (`Lib64=../../astoria.dll`) produced a path that only *looked* correct by coincidence (two independently-broken, uncollapsed strings happening to match), which is why only MyFbFramework ever showed in the toolbox while cJSON/MariaDBBox/ScintillaControl/SQLite3 silently didn't. Live-verified: all 5 libraries show at plain startup, no picker UI anywhere.
- **`Controls/MyFbFramework/` renamed to `Controls/Framework/`** (owner request), plus `MyFbFramework.wiki` → `Framework.wiki` and `MyFbFramework.vfp` → `Framework.vfp` inside it. Scope grew from the literal 3 renames to ~140 files once every reference was tracked down: build scripts, `Main.bas`/`Main.bi`/`TabWindow.bas`/`mff.rc`/`PathUtils.bas`, `Controls/Framework/Settings.ini`'s own internal header/source/include/lib-folder keys (still pointed at the old folder name after the directory move — a real break, caught before it shipped), the `LCase(DirName) = "myfbframework"` folder-name check in `LoadToolBox` that identifies MFF for load-order purposes (updated to `"framework"`), `IsMyFbFrameworkLibrary`'s doc comment, `AstoriaIDE.vfp`/`src/AstoriaIDE.vfp`, `AstoriaIDE.code-workspace`, all ~80 `Examples/*/*.vfp` and `Templates/Projects/*.vfp` `ControlLibrary=` references (bulk `sed` replace, verified UTF-8 BOM/encoding preserved), the `Examples/MyFbFramework Examples` entry (actually a small redirect *file*, not a folder — renamed to `Examples/Framework Examples` and its content updated), and `Examples/Add-In`'s Linux-branch fallback path. Deliberately left untouched: upstream GitHub/Gitee URLs to the real `MyFbFramework` project (that's its actual name, unrelated to this fork's local folder naming), historical narrative in `HISTORY.md`/`ROADMAP.md`/`DIRECT2D_REMOVAL.md` (the latter's `git show`/`git checkout` recovery commands specifically *must* keep the old path — they target historical commits where that was the real path), prose/branding mentions of "MyFbFramework" as the library's name (Tip of the Day, generated wiki doc text, `mff.rc`'s `VER_PRODUCTNAME_STR`), and pre-existing already-broken dev tooling unrelated to this task (`.vscode/tasks.json`, `src/.poseidon`, `.claude/settings.local.json` — all still reference pre-AstoriaIDE-rename names like `VisualFBEditor.bas`, so fixing just the Framework part wouldn't make them work anyway). Live-verified twice: Form Designer renders, Toolbox shows all 5 libraries.
- Nothing is awaiting an owner response. The remaining items below are deferred or ready for a new, explicitly selected task.

## Next ready work

No task is currently selected. Choose from the open items below when ready.

For the reasoning, exact code locations, and prior hot-path findings, see [HISTORY.md](HISTORY.md).

## Open items

### Immediate

No immediate items open.

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

1. After any source change, rebuild and commit the **release** executable with Compile.bat; MFF source reachable from mff.bi also needs FORCE_MFF=1 so astoria.dll is rebuilt.
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
| MFF framework | Controls/Framework/mff/ → astoria.dll (built to repo root, next to astoria.exe) |
| Build | Compile.bat, CompileDebug.bat |

## Reference material

- [HISTORY.md](HISTORY.md) — detailed investigations, completed sub-projects, dated session notes, and rationale.
- [CHANGELOG.md](CHANGELOG.md) — shipped work and commit history.
- [ROADMAP.md](ROADMAP.md) — full enhancement specifications.
- [DIRECT2D_REMOVAL.md](DIRECT2D_REMOVAL.md) — why Direct2D was removed (2026-07-13), full scope, and git-based instructions to bring it back.

*End of status document.*
