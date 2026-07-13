# Astoria-IDE — Project Status & Handoff

**Last updated:** 2026-07-13 02:05:39 -07:00 (last push)
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
- **H-1 is complete:** `Canvas.Cls` no longer creates a GDI brush on its Direct2D clear path and closes a Direct2D drawing session before returning. `mff64.dll` and `astoria.exe` rebuilt successfully; owner smoke test passed. Direct2D remains force-disabled in the IDE, so no live Direct2D-path test was available.
- **H-4 is complete:** removed the duplicate GDI `FillRect` in `Canvas.Cls`. `mff64.dll` and `astoria.exe` rebuilt successfully; owner smoke test passed.
- Nothing is awaiting an owner response. The remaining items below are deferred or ready for a new, explicitly selected task.

## Next ready work

No task is currently selected. Choose from the open items below when ready.

For the reasoning, exact code locations, and prior hot-path findings, see [HISTORY.md](HISTORY.md).

## Open items

### Immediate

- [ ] Consolidate the Run menu so related commands are not split between the top level and **More Build Options**.
- [ ] Audit toolbar buttons and add missing tooltips.
- [ ] Add a missing-executable check and user-visible message to the non-debug RunProgram/RunPr path.

### Deferred owner decisions

- [ ] Decide whether per-project <Project>_Change.log files should live in the project folder instead of the IDE root.
- [ ] Decide whether new projects should default to Documents\Astoria-IDE Projects instead of the application folder.
- [ ] Decide whether user theme-color edits should be stored separately from shipped theme files.

### MFF hygiene and technical debt

- [ ] Delete README_CN.md and changes_cn.txt if desired. Do **not** delete MyFbFramework.wiki/: the IDE reads it for component help. Check usage before removing examples/ or help/.
- [ ] Consider the standalone-Canvas device-ownership issue only with a dedicated test harness; it is not exercised by the IDE.
- [ ] MFF control-library path consolidation.

### Deferred enhancements

- [ ] Complete the owner walkthrough/sign-off for the View menu.
- [ ] Standard Windows installer (per-user install model is approved).
- [ ] Full Examples review and expansion.
- [ ] Split oversized source files and standardize indentation.
- [ ] Form Designer cold-open blank page.
- [ ] Dark-mode popup menus, dialog backgrounds, and live re-theming on Options Apply.
- [ ] Design-workspace status bar.
- [ ] Establish an explicit upstream-sync strategy.
- [ ] Fork-specific wiki/documentation.

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

*End of status document.*
