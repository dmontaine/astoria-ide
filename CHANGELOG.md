# VFBE Win64 Fork — Changelog

**Repository:** [github.com/dmontaine/Astoria-IDE](https://github.com/dmontaine/Astoria-IDE) (Codeberg retired 2026-07-09)

This file archives completed work and the full commit history. For current status and open items, see [`PROJECT_STATUS.md`](PROJECT_STATUS.md).

---

## Completed work

- [x] Project renamed VisualFBEditor → **AstoriaIDE** (§13.4): source/project/resource files (`AstoriaIDE.bas/.rc/.vfp`), build scripts, output binary (`astoria.exe`), settings file (`Settings/astoria.ini`), splash/title-bar/dialog-title strings, README, and ~44 source-file header comments. Internal code identifiers (`VisualFBEditorApp`, `Namespace VisualFBEditor`, `WhenVisualFBEditorStarts`) deliberately left as-is — pure implementation detail, not user-facing. `frmAbout` excluded per owner's in-progress edits.
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
- [x] 32-bit compiler binaries removed (`Compiler/bin/win32`) (`15e66cc`); missed leftover found and removed 2026-07-03 — `Compiler/bin/libexec/gcc/i686-w64-mingw32/9.3.0/` (31 MB, 12 files)
- [x] All compile warnings resolved, 0 warnings/0 errors (`53d8e47`, `56f6d18`)
- [x] Dark-mode implementation replaced with inert stub (interface preserved) (`56f6d18`)
- [x] Confirmed-dead subtrees deleted: `gir_headers/`, `WebView/`, `fbsound/`, `SoundPlayer.*` (`c494207`)
- [x] Batch 2.75.3 — physical dead-code deletion across `Debug.bas`, `Designer.bas`/`.bi`, `Main.bas`/`.bi`, `TabWindow.bas`, `VisualFBEditor.bas`, ~15 `mff/*.bas` files, `NativeFontControl.bas`/`.bi` deleted outright (`7baebd1`, `add4642`, `76abaa5`)
- [x] AI KnowledgeBase path bug fixed — `VisualFBEditor IDE Environment.md` was never loading due to a missing `\KnowledgeBase\` path segment
- [x] Bottom-panel analysis/debug tabs now clear on project close and debug-session-end
- [x] Per-form control tree in the project Explorer, with panel-aware icons and consistent single-click-open behavior
- [x] Bug fix: File > Close All left an empty project's tree entry behind
- [x] PagePanel layer/page navigation from the control tree, right-click menu, and Ctrl+PageUp/PageDown; fixed right-click-never-selects bug and load-time page-visibility bug
- [x] Dark mode crash #3 root-caused (WM_THEMECHANGED ↔ SetWindowTheme infinite recursion → stack overflow) and fixed with re-entrancy guard in `AllowDarkModeForWindow`
- [x] Dark mode visual completion: horizontal tab-strip dark painting + dark background fill in `TabControl`
- [x] **2.1.3 Magic numbers** — named constants added
- [x] **2.1.2 Dead code/comments** — 342 lines removed
- [x] **2.2.1 Variable naming** — typos and misleading names fixed
- [x] **2.3.2 UI/settings sweep — orphaned controls** — 5 dead compiler-management buttons + 1 label removed
- [x] **2.3.1 Development/Final compile-mode toggle** — replaced 6 Project Properties controls with single radio pair
- [x] **2.2.2 DRY pass** — `SaveTabPagePlacement()` extracted from 19 WriteString/Integer pairs
- [x] **2.4.1/2.4.2 Final audit + docs cleanup** — `src/makefile` deleted, `src/THREADING.md` GTK reference removed
- [x] **13.3 UI evaluation** — comprehensive review of all IDE surfaces; 28 fixes applied
- [x] **File menu restructured** — project items grouped, `frmNewProject` as simplified New Project form
- [x] **Debug tabs** — 7 debug tabs hidden when not debugging via `SetDebugTabsVisible`
- [x] **Window menu doc list** — all open documents listed with active checked
- [x] **MRU fixed** — frmTemplates reads from memory not stale INI; duplicate "Recent Projects" removed
- [x] **Startup simplified** — no template dialog on startup; default is Do Nothing; startup options removed
- [x] **Automatic workspace** — `.vfs` sessions removed from UX; `Settings/Workspace.ini` auto save/restore; single-project switch
- [x] **File menu (part 2)** — Project vs File sections; `frmNewFile`, `frmOpenProject`, `frmRecentProjects`
- [x] **Bottom panel tab captions** — `DetachTab`, hide debug tabs before HWND init, INI index `-1` guard
- [x] **Run menu consolidation** — all run/debug commands under **Run**; Debug menubar removed
- [x] **Bottom panel regression** — tab captions + debug hide/show verified fixed
- [x] **Form designer grey-panel bug** — root-caused (folder-path `DyLibLoad`) and fixed (`GetModuleFileNameW` recovery)
- [x] **File menu (step-by-step review)** — Open Project vs Recent Projects fix; `ProjectsPath` honored; path sanitization; tabbed open dialog with Projects + Examples tabs; Examples scan fixed
- [x] **GDB debugger fixes** — Step Out sends `finish`; 32-slot command queue replaces single string; Break while running via `interrupt` + mutex release
- [x] **`_WIN32_WINNT` header fix** — 116 exact-equality guards widened to `>=` across 18 winapi headers
- [x] **FreeBASIC compiler version decision** — evaluated 1.10.3, no viable binary exists; staying on 1.10.1
- [x] **Debugger backend: GDB** — `gas64` confirmed dead (no debug info emitted); Integrated stabs debugger + ToGAS/ToLLVM/ToCLANG code removed
- [x] **Development/Final compile-mode toggle finalized** — both `-gen gcc`, Development = `-O0 -g`, Final = `-O2`
- [x] **General options page checkbox overlap** — fixed via explicit ControlIndex values + `RequestAlign` on page switch
- [x] **Code/Designer view tabs** (Lazarus-style) — replaced the per-tab Code/Form/Code+Form toolbar toggle buttons with a top tab strip (`tcView`), order **Code And Form** (default) / **Code** / **Form**. Switching logic centralized into `TabWindow` methods (`ShowView`/`ApplyView`/`SyncViewTab`/`CurrentView`/`SetFormViewsEnabled`); the ~20 former `tbrTop.Buttons.Item(...)->Checked` call sites across `Main.bas`/`TabWindow.bas`/`VisualFBEditor.bas` now use those. Header-only strip (panels not reparented), so the designer-creation path is unchanged; non-form files bounce form views back to Code.
- [x] **View menu owner walkthrough** — six bugs found and fixed: Code/Form/Code and Form were enabled for any `.bas` file instead of only form-capable files; "Goto Code/Form" renamed to **Switch Form/Code** and greyed in Code+Form split view (no-op there); Split Horizontally/Vertically and Fold greyed in Form-only view (they operate on the code editor, not visible in that view); Debug Windows submenu greyed whenever Use Debugger is unchecked.
- [x] **Four deferred owner decisions resolved** — Change Log relocated: `<ProjectName>_Change.log` now lives in the project's own folder instead of `ExePath`, and is shown as a node under the project tree's Others folder (double-click jumps to the Change Log tab; rename blocked, it's a synthesized node). New-project subfolder layout, default Projects Path (`./Projects`, never Documents), and theme storage location all confirmed to already match the owner's decisions — no code change needed for any of the three.
- [x] **Run menu fully consolidated** — removed both the "More Build Options" and "More Debug Options" submenus; all their items now sit directly in the top-level Run menu.
- [x] **Toolbar tooltip audit** — 13 buttons across the main toolbars had hint text written but `ShowHint` left `False` (tooltip silently never displayed); fixed. `frmImageManager.frm`'s toolbar had no hint text at all; added.
- [x] **Direct2D removed entirely** — owner decision: GDI/GDI+ is now the sole rendering path, both for the IDE's code editor and the MFF `Canvas` control. Direct2D was force-disabled its whole life (never live-tested) and already had one bug found in it (H-1); rather than keep an unproven second path, it was stripped from `EditControl`, `Canvas`, the D2D1 API binding module (deleted), the Options/toolbar UI, and the Canvas example project. Recovery instructions in `DIRECT2D_REMOVAL.md`.
- [x] **Missing-executable check added to Run** — the non-debug `RunProgram`/`RunPr` path now checks the resolved target exists before launching it, showing "Application do not run. The executable was not found" instead of silently attempting `CreateProcess` on a nonexistent file. Matches the pre-flight check `PrepareDebugSession()` already gave the debug path.
- [x] **Debug-mode "Returned code" now reflects the real exit code** — `RunWithDebug` always displayed "Returned code: 0 - No error" regardless of what the program actually did (its `Result` variable was never assigned). Now parses GDB's own completion text (`Program exited normally` / `exited with code NN`, decoded from GDB's octal) into a real exit code, and stays silent — rather than showing a fabricated code — when Stop-while-running force-kills the debuggee (`kill_inferior_process`'s `TerminateProcess(h, 1)` is not a real program exit code).

---

## Full commit log

| Commit | Date | Description |
|--------|------|-------------|
| `bbfa399` | 2026-06-29 | Initial Win64 fork import |
| `e212819` | 2026-06-30 | Bottom panel persistence/collapse; startup guards; `SaveMainWindowPanelLayout`; `PROJECT_STATUS.md` |
| `e63f1a6` | 2026-06-30 | Status doc commit-hash update |
| `ef3b43e` | 2026-06-30 | First-start collapsed layout; gitignore `docompile.bat`; handoff/test-plan update |
| `2511d86` | 2026-06-30 | Record commit hash for `ef3b43e`; save bottom panel INI state |
| `5a09739` | 2026-06-30 | Update INI window/panel state; rebuild `VisualFBEditor64.exe` |
| `c267284` | 2026-07-01 | Fix right panel not collapsing on Pin click |
| `7c1a055` | 2026-07-01 | Save session state after verifying right panel collapse fix |
| `af5b4be` | 2026-07-01 | Update designer-regenerated `Temp.bas` scratch files |
| `bef9267` | 2026-07-02 | Fix Form Designer never activating: strip tool silently deleted exported component dispatchers |
| `b555406` | 2026-07-02 | Track the bundled FBC compiler and GDB debugger toolchains in-repo |
| `64daa66` | 2026-07-02 | Fix left panel not collapsing on Pin click |
| `15e66cc` | 2026-07-02 | Remove 32-bit compiler binaries (`Compiler/bin/win32`) — out of scope |
| `ac29ec8` | 2026-07-02 | Update designer-regenerated `Temp.bas` scratch files |
| `53d8e47` | 2026-07-02 | Fix all compile warnings (first pass) |
| `56f6d18` | 2026-07-02 | Remove risky dark-mode implementation (replaced with inert stub); finish fixing mixed-boolean warnings |
| `c494207` | 2026-07-02 | Delete confirmed-dead code: `gir_headers/`, `WebView/`, `fbsound/`, `SoundPlayer.*` |
| `7baebd1` | 2026-07-02 | Physically delete dead GTK/32-bit/Linux code and legacy comment cruft in `Debug.bas` |
| `add4642` | 2026-07-02 | Physically delete dead GTK/32-bit/Linux code in `Designer`/`Main`/`TabWindow`/`VisualFBEditor.bas` |
| `76abaa5` | 2026-07-03 | Physically delete remaining dead GTK/32-bit code across `MyFbFramework` and `src` headers |
| `4cf7275` | 2026-07-03 | Fix critical `_WIN32_WINNT` header bug blocking user-project compiles; bottom-panel tab clearing |
| `4bd0289` | 2026-07-03 | Add missing example `.vfp` project files; add "no unnecessary options" guiding principle; audit Examples/ |
| `51441d7` | 2026-07-03 | Fix Graphics example against current mff API; add future Examples/ review task |
| `e139c2c` | 2026-07-03 | Remove leftover 32-bit GCC internals |
| `5021314` | 2026-07-03 | Lock in decision: implement both gas64 and gcc, remove gas64 if GDB debugging fails |
| `59cd42c` | 2026-07-03 | Close Tier 3 (compiler swap): no viable 1.10.3 binary exists, staying on 1.10.1 |
| `0934416` | 2026-07-03 | Finalize gas64/GDB decision: gas64 is dead, Development/Final both use gcc |
| `3886f3d` | 2026-07-03 | Add note: UI/settings sweep for GTK/Linux/alt-compiler/alt-debugger remnants |
| `5fa5cf2` | 2026-07-03 | Remove Integrated (stabs) debugger and alt-compiler-backend/debugger-choice code |
| `b3633bc` | 2026-07-03 | Reimplement dark mode with documented Win32 APIs; fix startup-hang regression |
| `a7c7839` | 2026-07-03 | Fix General-options checkbox overlap; flag Form Designer scalability concern |
| `f371d21` | 2026-07-04 | Fix two real dark-mode crash bugs; document third still-open crash |
| `fd33a05` | 2026-07-04 | Characterize and scope the Form Designer navigation gap; salvageable, not a rewrite |
| `f292db0` | 2026-07-04 | Add per-form control tree to project Explorer; fix Close All leaving project tree behind |
| `0c08fe5` | 2026-07-04 | Add PagePanel layer/page navigation to the Form Designer |
| `389f3ce` | 2026-07-04 | Fix dark mode crash (WM_THEMECHANGED recursion) and complete tab/body dark rendering |
| `d877cef` | 2026-07-04 | Safe dark popup menus + right panel pin fix |
| `7261267` | 2026-07-04 | Phase 2: magic numbers, dead code, naming fixes, orphaned UI, Dev/Final compile toggle (2.1.2-2.1.3, 2.2.1, 2.3.1-2.3.2) |
| `d7608ae` | 2026-07-05 | 2.2.2 DRY: SaveTabPagePlacement extraction (19 WriteString/Integer pairs → helper) |
| `6b3200a` | 2026-07-05 | 2.4.1/2.4.2: delete src/makefile (Linux/GTK build system), fix THREADING.md GTK reference |
| `49ec5cc` | 2026-07-05 | UI evaluation fixes: menu labels, dialog cleanup, debug tabs, Code Editor grouping, compiler options simplification, editor defaults |
| `37ba31e` | 2026-07-05 | UI evaluation: File menu restructure, frmNewProject, debug tabs, startup options, MRU fix, editor defaults |
| `b9735e8` | 2026-07-05 | Replace .vfs sessions with automatic workspace; restructure File menu; fix bottom panel tab captions |
| `ec42ea8` | 2026-07-05 | Win64 IDE cleanup: simplify menus, projects, build, and debugger |
| `cc9e7dd` | 2026-07-06 | Fix form designer grey panel: resolve MFF control library by live module handle |
