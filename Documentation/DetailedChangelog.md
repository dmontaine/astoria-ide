# Detailed Changelog

Every change made to Astoria IDE, in date order, oldest first. This is the complete record: it
does not filter for significance.

For the curated view aimed at users, see
[AstoriaIDESignificantChanges.md](AstoriaIDESignificantChanges.md). For the higher-level
milestone archive, see [CHANGELOG.md](../CHANGELOG.md) at the repository root; for narrative
session notes, [HISTORY.md](../HISTORY.md). For testing, [Testing.md](Testing.md).

**How to read an entry.** Each line is one commit: its short hash, what changed, and where it
landed. Hashes link to the repository, so `git show <hash>` gives the full detail and diff.
Areas are: **IDE** (`src/`), **Framework/Controls** (`Controls/`), **Templates**, **Examples**,
**Docs**, **Settings**, **Build/Tools**.

**Maintaining this file.** It is generated from the commit history, so the way to add an entry
is to write a good commit message. Regenerate rather than hand-edit; a stale hand-edit is worse
than no entry. Run `.\GenerateChangelog.ps1` from the repository root; `-Check` reports whether
the file is current and writes nothing, which suits a pre-commit hook.

Everything above the **Total: 439 commits, 2026-07-02 to 2026-07-20.**

## 2026-07-02

- **`bbfa399`** — Initial Win64 fork import
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings, Templates · 2263 files*
- **`e212819`** — Fix bottom panel persistence and collapse layout; add project status handoff doc.
  *Docs, IDE, Settings · 6 files*
- **`e63f1a6`** — Update PROJECT_STATUS.md with commit hash e212819.
  *Docs · 1 file*
- **`ef3b43e`** — Fix first-start collapsed bottom layout; update handoff status and gitignore docompile.bat.
  *Build/Tools, Docs, IDE · 3 files*
- **`2511d86`** — Record commit hash for ef3b43e; save current bottom panel state (pinned open) to INI backup.
  *Docs, Settings · 2 files*
- **`5a09739`** — Update INI window/panel state and rebuild VisualFBEditor64.exe.
  *IDE, Settings · 2 files*
- **`c267284`** — Fix right panel not collapsing on Pin click.
  PinRight always called SetRightClosedStyle with WithClose=False, deferring the actual collapse to frmMain_ActiveControlChanged.
  *Build/Tools, IDE, Settings · 4 files*
- **`7c1a055`** — Save session state after verifying right panel collapse fix.
  *Settings · 1 file*
- **`af5b4be`** — Update designer-regenerated Temp.bas scratch files from testing sessions.
  *Examples · 2 files*
- **`bef9267`** — Fix Form Designer never activating: strip tool silently deleted exported component dispatchers.
  Root cause: Tools/strip_gtk_preprocessor.ps1 only recognized a fixed set of platform macros (__FB_WIN32__, __USE_GTK__, etc.).
  *Build/Tools, Framework/Controls, IDE, Settings · 769 files*
- **`b555406`** — Track the bundled FBC compiler and GDB debugger toolchains in-repo.
  This project is self-contained: the exact FreeBASIC compiler and GDB debugger versions used to build/debug it are part of the project, not an external dependency to be separately provisioned.
  *Build/Tools · 3306 files*
- **`64daa66`** — Fix left panel not collapsing on Pin click.
  Same root cause as the earlier PinRight fix: PinLeft always called SetLeftClosedStyle with WithClose=False, deferring the actual collapse to frmMain_ActiveControlChanged firing on a later focus change.
  *Framework/Controls, IDE, Settings · 4 files*
- **`15e66cc`** — Remove 32-bit compiler binaries (Compiler/bin/win32) - out of scope for this Win64-only fork.
  *Build/Tools, Settings · 8 files*
- **`ac29ec8`** — Update designer-regenerated Temp.bas scratch files from testing sessions.
  *Examples · 2 files*
- **`53d8e47`** — Fix all compile warnings.
  - Canvas.bas, Debug.bas: wrap bare string literals passed as WString Ptr (@"...") with WStr(...) - FreeBASIC defaults untyped literals to ZString, so the pointer type didn't match the declared WString Ptr parameters. - Main.bas/TabWindow.bi: same fix for SelectSearchResult()'s SearchText default...
  *Framework/Controls, IDE · 6 files*
- **`56f6d18`** — Remove risky dark-mode implementation; actually finish fixing the mixed-boolean warnings.
  Dark mode was disabled but the previous implementation still ran unconditionally at every startup: InitDarkMode() probes an undocumented ntdll.dll function (RtlGetNtVersionNumbers) and resolves several uxtheme.dll functions by ordinal number (GetProcAddress with raw ordinals 49, 104, 106, 132, 133...
  *Framework/Controls, IDE · 6 files*
- **`c494207`** — Delete confirmed-dead code: gir_headers/, WebView/, fbsound/, SoundPlayer.
  All four are never included by mff.bi or referenced from any compiled file: - gir_headers/ (6.3MB): GTK GObject-Introspection bindings, Linux/GTK-only. - WebView/ (WebKitWebView.bi, WebView2.bi): the only "reference" anywhere was a commented-out line in WebBrowser.bi, not an actual #include....
  *Framework/Controls, IDE · 109 files*
- **`7baebd1`** — Physically delete dead GTK/32-bit/Linux code and legacy comment cruft in Debug.bas
  Removes stray '#ifdef/#ifndef __USE_GTK__ / __FB_WIN32__ marker comments throughout the integrated debugger (all branches were already inert since this is a Win64-only build), plus several fully dead legacy blocks found along the way:
  *Framework/Controls, IDE · 3 files*
- **`add4642`** — Physically delete dead GTK/32-bit/Linux code in Designer/Main/TabWindow/VisualFBEditor.bas
  Removes stray '#ifdef/#ifndef __USE_GTK__ / __FB_WIN32__ marker comments throughout these four files (all branches were already inert on this Win64-only build), plus several fully dead legacy blocks found in the same pass:
  *Framework/Controls, IDE · 6 files*
- **`76abaa5`** — Physically delete remaining dead GTK/32-bit code across MyFbFramework and src headers
  Completes the GTK/32-bit dead-code deletion pass across the whole tree.
  *Framework/Controls, IDE · 23 files*

## 2026-07-03

- **`e58a647`** — Update PROJECT_STATUS.md with tonight's session; save INI/scratch state.
  Rewrites the status doc to match reality: marks Batch 2.75.3 complete with a full account of what happened (Designer export-table bug, DarkMode stub, subtree deletions, git-tracking policy change, warnings fix, panel Pin fixes, physical dead-code deletion across src/ and mff/), reframes the manual...
  *Docs, Examples, Settings · 3 files*
- **`7e1b79b`** — Add standing rule: end every session with a commit + push to Codeberg.
  *Docs · 1 file*
- **`b221cf2`** — Update PROJECT_STATUS.md with tonight's session; save INI/scratch state.
  Records the debugger smoke test findings: GDB debugging confirmed working for breakpoints, Step Into, and variable inspection.
  *Build/Tools, Docs, Examples, Settings · 6 files*
- **`ae74b31`** — Rename "Service" top-level menu to "Tools"; disambiguate the inner "Tools" submenu to "External Tools"
  The top-level menu's literal English source text read "Service" (src/Main.bas, variable miXizmat - "xizmat" is Uzbek for "service", matching the original author).
  *Framework/Controls, IDE · 3 files*
- **`085d486`** — Document second-AI audit follow-ups: compile-clean push gate, strip-tool safety net, gas64/toolchain cross-link, INI key migration convention
  Save current INI/panel state.
  *Docs, Settings · 2 files*
- **`5eeb2f9`** — Rebuild mff64.dll and VisualFBEditor64.exe (clean compile, 0 errors/0 warnings)
  *Framework/Controls, IDE · 2 files*
- **`074a150`** — Remove stray compile_log.txt build-log artifact tracked since initial import
  Leftover UTF-16 build log from whoever ran the initial fork import; not part of any build script or workflow.
  *Docs · 1 file*
- **`3bddafe`** — Fix AI KnowledgeBase path bug: VisualFBEditor IDE Environment.md was never loading
  Main.bas looked for the file directly under "Help\AI prompt\" but it actually lives under "Help\AI prompt\KnowledgeBase\", so the Dir() check always failed and the AI agent silently fell back to a ~40-line inline stub instead of the full 2,874-line IDE reference.
  *Framework/Controls, IDE · 3 files*
- **`4cf7275`** — Fix critical _WIN32_WINNT header bug blocking user-project compiles; bottom-panel tab clearing
  Bundled compiler headers (Compiler/inc/win/*.bi) gated all Windows-8.1+ API declarations behind exact-equality _WIN32_WINNT checks instead of minimum-version checks, so targeting Windows 10 (this project's TARGET_COMPILE_DEFINE) silently excluded them.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings · 30 files*
- **`4bd0289`** — Add missing example .vfp project files; add "no unnecessary options" guiding principle; audit Examples/ for GTK/Linux/Win32-only
  Audited all 33 Examples/ subdirectories for GTK dependency, Linux-only code, or Win32-only (non-64-bit) source, per the owner's ad-hoc request.
  *Docs, Examples, Framework/Controls, IDE · 18 files*
- **`51441d7`** — Fix Graphics example against current mff API; add future Examples/ review task
  CanvasDraw.bas called CreateDoubleBuffer/TransferDoubleBuffer, which no longer exist (double-buffering is now handled internally via Control's DoubleBuffered property); used bare integers against the now strictly-typed PenStyle enum property; and had an ambiguous StretchMode reference (both...
  *Docs, Examples, Framework/Controls, IDE · 4 files*
- **`e139c2c`** — Remove leftover 32-bit GCC internals; clarify gas64/gcc are not two competing compilers
  Compiler/bin/libexec/gcc/i686-w64-mingw32/9.3.0/ was a complete parallel 32-bit GCC toolchain (cc1.exe, as.exe, ld.exe, 9 DLLs -- 31 MB) that the earlier 32-bit-removal commit (15e66cc) missed, since it only caught the top-level Compiler/bin/win32/ folder.
  *Build/Tools, Docs, Framework/Controls, IDE · 6 files*
- **`5021314`** — Lock in decision: implement both gas64 and gcc, remove gas64 if GDB debugging fails
  Owner decided to try both Development (gas64) and Final (gcc) modes as designed, rather than pre-emptively picking one.
  *Docs · 1 file*
- **`59cd42c`** — Close Tier 3 (compiler swap): no viable 1.10.3 binary exists, staying on 1.10.1
  Attempted to fetch the FreeBASIC 1.10.3 build already planned in the doc (stw's portal build #875, commit 8708d1a).
  *Docs · 1 file*
- **`0934416`** — Finalize gas64/GDB decision: gas64 is dead, Development/Final both use gcc
  Empirical test confirmed gas64 doesn't emit usable debug info at all (zero .loc directives, no .stabs) -- not a GDB compatibility gap, the compiler backend itself doesn't produce debuggable output. gas64 is removed from consideration per the already-agreed contingency.
  *Docs · 1 file*
- **`3886f3d`** — Add note: UI/settings sweep for GTK/Linux/alt-compiler/alt-debugger remnants
  Companion to the in-progress code-stripping pass -- deleting a dead code branch doesn't guarantee its Project Properties/Options UI control gets deleted too, so flagging an explicit visual sweep once the code-level pass lands, rather than assuming the UI cleans up automatically.
  *Docs · 1 file*
- **`5fa5cf2`** — Remove Integrated (stabs) debugger and alt-compiler-backend/debugger-choice code
  GDB is now the only debugger and gcc the only compile backend, so the code that existed solely to support alternatives is gone rather than left dormant, per this project's standing rule against shipping unused code.
  *Docs, Examples, Framework/Controls, IDE · 19 files*
- **`b3633bc`** — Reimplement dark mode with documented Win32 APIs; fix startup-hang regression
  Dark mode had been replaced with an inert stub (56f6d18) after the original ordinal-resolved uxtheme/IAT-hooking implementation was flagged as unreliable.
  *Docs, Framework/Controls, IDE · 8 files*
- **`a7c7839`** — Fix General-options checkbox overlap; flag Form Designer scalability concern
  Un-hiding Dark Mode (previous commit) surfaced a second, pre-existing bug on the same options page, unrelated to dark mode itself and never previously noticed: pnlInterfaceFont/chkDisplayIcons/chkShowMainToolbar/chkShowPropLocal/ chkDarkMode are relocated into vbxGeneral at runtime after already...
  *Docs, Framework/Controls, IDE, Settings · 5 files*

## 2026-07-04

- **`f371d21`** — Fix two real dark-mode crash bugs; document third still-open crash
  Enabling dark mode crashed the app (0xc0000005 inside UxTheme.dll, confirmed via Windows Event Viewer).
  *Docs, Framework/Controls, IDE, Settings · 7 files*
- **`fd33a05`** — Characterize and scope the Form Designer navigation gap; salvageable, not a rewrite
  Follow-up to yesterday's raised concern about whether the visual Form Designer can handle complex/nested forms at all.
  *Docs, Settings · 2 files*
- **`f292db0`** — Add per-form control tree to project Explorer; fix Close All leaving project tree behind
  Form nodes now lazily expand into a correctly-nested, real-icon control tree built from the live Designer container hierarchy, closing part (a) of the Form Designer navigation gap (owner-scoped 2026-07-03/07-04).
  *Docs, Framework/Controls, IDE · 5 files*
- **`0c08fe5`** — Add PagePanel layer/page navigation to the Form Designer
  Closes part (b) of the Form Designer navigation gap: selecting a control now reveals its PagePanel page (tree selection and the older cboClass selector), Ctrl+PageUp/PageDown cycles pages, and the Designer's right-click menu gained "Show Panel"/"Previous Layer"/"Next Layer" entries — all reusable...
  *Docs, Framework/Controls, IDE · 10 files*
- **`389f3ce`** — Fix dark mode crash (WM_THEMECHANGED recursion) and complete tab/body dark rendering
  Root cause of the long-standing "enabling dark mode crashes the app" bug, caught live under the bundled GDB: SetWindowTheme synchronously sends WM_THEMECHANGED back to the window it themes, and five control classes' WM_THEMECHANGED handlers (Form, Grid, ListView, TreeListView, TreeView) respond by...
  *Docs, Framework/Controls, IDE, Settings · 6 files*
- **`d877cef`** — Safe dark popup menus + right panel pin fix
  - Form.bas: WM_INITMENUPOPUP sets MFT_OWNERDRAW on popup items when dark mode is on (skips system menu via lParam HIWORD check) - Form.bas: WM_DRAWITEM ODT_MENU renders dark items with text, accelerator split at tab, DT_HIDEPREFIX for hidden ampersands - Control.bas: WM_MEASUREITEM ODT_MENU sets...
  *Docs, Framework/Controls, IDE · 5 files*

## 2026-07-05

- **`7261267`** — Phase 2: magic numbers, dead code, naming fixes, orphaned UI, Dev/Final compile toggle (2.1.2-2.1.3, 2.2.1, 2.3.1-2.3.2)
  *Docs, Framework/Controls, IDE, Settings · 31 files*
- **`d7608ae`** — 2.2.2 DRY: SaveTabPagePlacement extraction (19 WriteString/Integer pairs -> helper); update PROJECT_STATUS
  *Docs, Framework/Controls, IDE · 4 files*
- **`6b3200a`** — 2.4.1/2.4.2: delete src/makefile (Linux/GTK build system), fix THREADING.md GTK reference, remove final __US_GTK__ comment
  *Docs, Framework/Controls, IDE · 8 files*
- **`49ec5cc`** — UI evaluation fixes: menu labels, dialog cleanup, debug tabs, Code Editor grouping, compiler options simplification, editor defaults
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings · 22 files*
- **`37ba31e`** — UI evaluation: File menu restructure, frmNewProject, debug tabs, startup options, MRU fix, editor defaults
  *Docs, Examples, Framework/Controls, IDE, Settings · 16 files*
- **`b9735e8`** — Replace .vfs sessions with automatic workspace; restructure File menu; fix bottom panel tab captions.
  Sessions are removed from UX—workspace restores on startup via Settings/Workspace.ini.
  *Build/Tools, Docs, Framework/Controls, IDE, Settings · 25 files*
- **`ec42ea8`** — Win64 IDE cleanup: simplify menus, projects, build, and debugger.
  Remove legacy line numbering, On Error helpers, Close Folder, and bundled 32-bit tools; streamline templates and New Project path handling.
  *Build/Tools, Docs, Framework/Controls, IDE, Settings, Templates · 44 files*

## 2026-07-06

- **`cc9e7dd`** — Fix form designer grey panel: resolve MFF control library by live module handle
  Opening a .frm showed a brief flash then an empty grey pnlForm because Designer.CreateControl("Form") returned 0: Designer.Symbols resolved the MyFbFramework library via DyLibLoad on Library.Path, which had been left as the folder "Controls\MyFbFramework" (no mff64.dll) even though the DLL was...
  *Docs, Examples, Framework/Controls, IDE, Settings, Templates · 32 files*
- **`e5e1080`** — Edit menu review: flat checkmark toggles for bubble help, autocomplete, and parameter info.
  Open Project and PathUtils fixes improve example discovery; PROJECT_STATUS records owner-approved File and Edit menu reviews.
  *Docs, Framework/Controls, IDE, Settings · 31 files*
- **`6cdce7b`** — Add UI approachability plan (ROADMAP §13.3.A); track split-out docs
  Documents the owner-approved O1-O4 design for the UI approachability pass: progressive-disclosure model (advanced items in per-menu Advanced submenus, no easy/advanced mode toggle), full menu taxonomy, Run/Build/Debug menu consolidation with the debug-state enable rules, minimal-default + labeled...
  *Docs · 4 files*

## 2026-07-07

- **`0eaa880`** — 13.3.A S1-S4: approachability pass (menus, toolbars, dead field) + S3 INI migration
  Opus-reviewed execution of the ROADMAP §13.3.A approachability plan:
  *Docs, Framework/Controls, IDE · 10 files*
- **`93bbfa2`** — 13.3.A S5-S7: File-menu safety, Options dead-UI removal, + Run-toolbar persistence fix
  S5 - Delete Project/Delete File: - DeleteEditorFile was a no-op stub; implemented for real (MsgBox Yes/No confirm, CloseTab, tree-node detach, disk delete) mirroring DeleteProject.
  *Docs, IDE · 5 files*
- **`d75b4b3`** — Opus Next Steps Phase A + P1: robustness fixes + AI thread responsiveness
  Verified backlog from Next Steps - Opus.md (2026-07-07 cross-review of Cursor/Deepseek/Sonnet findings against actual source):
  *Docs, Framework/Controls, IDE · 6 files*
- **`5d9cd62`** — Opus Next Steps Phase B: Suggestions preload + FormatProject disable off UI thread
  - P2: Suggestions' first-run project-content preload called LoadFunctions synchronously per file on the UI thread.
  *Docs, IDE · 3 files*
- **`a7531fb`** — Opus Next Steps Phase C: calmer debugger text, fresh-install starter project, Options wording
  - U1: rewrote three Debug.bas user-facing messages in plain, calm language and dropped the raw "gdb" name in favor of "the debugger" -- the gdb-not-found/source-not-executable errors, the hard_closing crash dialog, and the all-caps Stop-debuggee confirm. - U2: fresh installs landed on a completely...
  *Docs, IDE · 5 files*
- **`8aba6c2`** — Opus Next Steps Phase D (partial): feedback-channel policy + two silent-failure fixes
  - F1: wrote down the feedback-channel policy Opus asked for (status bar = transient state, Output panel = background events, MsgBox = irreversible/ blocking only) as a new guiding principle in PROJECT_STATUS.md, to apply opportunistically rather than as a big-bang sweep. - F2...
  *Docs, IDE · 4 files*
- **`1a90746`** — Opus Next Steps Phase E: trim AI catalog, remove Android/ADB deploy code
  Owner decisions (2026-07-07):
  *Docs, IDE · 4 files*
- **`640e94e`** — Opus Next Steps Phase C completion: collapse event-handler cluster, record .lng decision
  Owner decisions (2026-07-07):
  *Docs, IDE · 3 files*
- **`cbc71d1`** — Opus Next Steps Phase E (E1): Options-Apply dirty-tracking to cut unconditional INI writes
  cmdApply_Click wrote all ~296 INI keys unconditionally on every Apply click; IniFile.WriteXxx triggers a full-file disk rewrite per call, so this was ~296 unconditional disk writes per click.
  *Docs, IDE · 2 files*
- **`a114ee5`** — D1: grey out the Designer menu when no form with controls is open
  The top-level "Designer" menu (miFormFormat) now disables when the active document has no designable form with controls.
  *Docs, IDE · 4 files*
- **`f92a43a`** — Fix File > Close Project crash/hang; New Project startup + dialog cross-nav
  Close Project was aborting the app (project never closed, reopened on restart).
  *Docs, Framework/Controls, IDE · 8 files*

## 2026-07-08

- **`e4d9a95`** — D1: grey the Designer menu on form/tab close
  The Designer menu didn't grey when closing a form because tabCode_SelChange's "If tb = tbOld Then Exit Sub" early-exits return before the per-select enable-logic.
  *Docs, IDE · 3 files*
- **`25e81cf`** — R5: bounded/cancellable GDB readpipe (poll with PeekNamedPipe)
  readpipe blocked ReadFile on the debug worker thread with no timeout, so an unresponsive/terminated GDB stalled the thread (and on a broken pipe the old loop spun on repeated 0-byte reads).
  *Docs, IDE · 3 files*
- **`26983f8`** — Document breakpoint-during-debug pipe race (escalated to Opus)
  Sonnet investigated the "editor goes blank after setting a breakpoint" report.
  *Docs · 1 file*
- **`2dbd348`** — Record failed set_bp fix attempt #1 (introduced a lock, reverted)
  Opus attempt to route set_bp through EnqueueDebugCommand + a drain-only worker-loop branch compiled clean but owner live-test hit a hard lock (set breakpoint, step-into x2, Run -> froze).
  *Docs · 1 file*
- **`4e3eb17`** — Fix Close Project (and other project-scoped menu items) greyed out on startup
  LoadWorkspace's AddProject ends with tn->SelectItem, but that's a no-op if the tree control's Win32 handle isn't realized yet at that point in startup -- so the SelChange event that normally refreshes ChangeMenuItemsEnabled never fires for a reloaded project.
  *Docs, IDE · 2 files*
- **`7ee5542`** — Fix menu-icons Options toggle applying live instead of on next run
  cmdApply_Click set Menu->ImagesList immediately on Apply, but already- rendered menu items keep their cached icon until a full rebuild, so unchecking "Display icons in the menu" dropped most icons immediately while leaving a few behind -- contradicting the "next run" message shown right after.
  *Docs, IDE · 2 files*
- **`a510b24`** — C4: remove the .lng translation-capability at the code level (English-only)
  Owner escalated C4 from "hide the Options language UI" to full removal.
  *Docs, IDE, Settings · 67 files*
- **`820eebb`** — C1: merge Comment into a single Toggle Comment command; remove Block Comment
  Single Comment (Ctrl+I) and Uncomment Block (Ctrl+Shift+I) collapse into one Toggle Comment bound to Ctrl+I: comments the selection if not already commented, uncomments it if it is (checked against the first selected line, same detection UnComment already used).
  *Docs, IDE · 7 files*

## 2026-07-09

- **`331b570`** — Fix pending-delete files silently surviving Close Project
  pfSave (the shared Save-changes dialog) destroys its native listbox on WM_CLOSE -- clicking Yes/No/Cancel calls CloseForm, which sends WM_CLOSE, and since nothing overrides Action to "hide" it falls through to DefWindowProc and really tears the window down.
  *Framework/Controls, IDE · 5 files*
- **`d6fb59e`** — Fix Delete Project crashing and silently failing to delete from disk
  DeleteProject had three separate bugs stacked on top of each other:
  *IDE · 2 files*
- **`72489b9`** — Fix Add Module crash and duplicate-tab bug
  GetMainFile's scratch-save path (used to analyze an unsaved-to-disk tab) tried to save into ExePath/Temp/Untitled.bas without ensuring the Temp folder exists -- SaveToFile doesn't create missing parent directories, so it failed with "Save file failure!" (repeatedly, once per call site hit during a...
  *IDE · 3 files*
- **`273df0f`** — Update local editor state, examples, and build artifacts
  Commit accumulated working-directory changes from local development sessions: compiled example binaries, temp/settings files, and source edits under src/ and Controls/MyFbFramework.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings · 69 files*
- **`5240ad0`** — Make Projects/MFF path settings survive moving the install folder
  Settings/VisualFBEditor64.ini's ProjectsPath had a hard-coded absolute path from before the repo moved (C:\Users\dmont\VisualFBEditor\...), which broke New Project on startup ("Parent folder not exists") once the folder no longer existed at that location.
  *Examples, IDE, Settings · 8 files*
- **`6ff623a`** — Remove contextual-change-validation rule and skill
  *Build/Tools · 2 files*
- **`b70101c`** — Update repository references from Codeberg to GitHub
  Codeberg (bigriverguy/VFBEWin64) is no longer used; the project now lives at github.com/dmontaine/astoria-ide.
  *Docs · 3 files*
- **`b62f18f`** — Switch remote from Codeberg to GitHub; workspace path portability fix
  Main.bas: make saved workspace/project file paths portable across install-folder moves (MakePathPortable on save, GetFullPath on load, guard missing .vfp on load).
  *Docs, IDE, Settings · 6 files*
- **`8639e1c`** — Make RecentFiles/RecentProject/RecentFile portable across install moves
  These INI keys stored absolute paths (e.g. from a prior "C:\Users\Public\..." location) with no resolution against the current install folder, unlike Workspace.ini's already-portable project/tab paths.
  *IDE, Settings · 3 files*
- **`f8e2ebd`** — Track the full MinGW GCC toolchain so a fresh clone can actually compile
  .gitignore's lib*.dll*/zlib*.dll*/*.o patterns predate commit b555406 ("Track the bundled FBC compiler and GDB debugger toolchains in-repo") and were never revisited afterward -- they silently kept excluding the exact runtime DLLs (libmpfr-6.dll, libgmp-10.dll, libmpc-3.dll, libwinpthread-1.dll...
  *Build/Tools · 866 files*
- **`164c5ea`** — Prompt for a name up front when creating a new project file
  Previously, new files (Add Module/Add Form, project templates' default files) got an auto-generated default name with no chance to rename, and renaming only happened later via a repeated sequence of system Save-As dialogs at save/close time -- each of which also allowed saving outside the project...
  *IDE · 8 files*
- **`d275dc9`** — Remove Help ▸ GitHub menu; scope AI-subsystem removal as next sub-project
  Existing working state from the prior session: deletes the entire Help ▸ GitHub topic (2 top-level items + 5-item Advanced submenu) and its mClick dispatch cases in VisualFBEditor.bas, plus an orphaned GitHubWebSite case and the related HotKeys.txt entries.
  *Docs, IDE, Settings · 6 files*

## 2026-07-10

- **`924a814`** — Remove the built-in AI Agent subsystem (AI1-AI13)
  Owner decision (2026-07-09): reverses the earlier ROADMAP.md §13.7 "enhance AI integration" plan in favor of removing the AI Agent subsystem entirely.
  *Build/Tools, Docs, IDE, Settings · 24 files*
- **`7e9c228`** — AI14: record Opus final review of AI-subsystem removal (verdict clean)
  Opus re-reviewed Sonnet's AI-removal diff (924a814) and independently verified it.
  *Docs · 1 file*
- **`f42b610`** — Close out AI-removal sub-project; unpause backlog to View-menu review
  AI subsystem removal is fully done (AI1-AI14, reviewed by Opus and owner).
  *Docs · 1 file*
- **`4b643af`** — Replace Code/Form view toggle buttons with a top tab strip
  Lazarus-style code/designer switching: each source tab's Code / Form / Code+Form toolbar toggle buttons are replaced by a top tab strip (tcView), ordered Code And Form (default) / Code / Form.
  *Docs, IDE · 6 files*
- **`84b5bee`** — Remove stale Temp/Untitled.bas scratch file
  *Build/Tools · 1 file*
- **`c93abbe`** — Rename project VisualFBEditor -> AstoriaIDE; fix About dialog and compiler warnings
  Rebrand (full identity rename per ROADMAP §13.4): - Renamed src/VisualFBEditor.bas/.rc/.vfp -> AstoriaIDE.bas/.rc/.vfp, root VisualFBEditor.vfp/.code-workspace -> AstoriaIDE.*, Resources/VisualFBEditor.ico -> AstoriaIDE.ico, Settings/VisualFBEditor64.ini -> Settings/astoria.ini (existing settings...
  *Build/Tools, Docs, Framework/Controls, IDE, Settings · 66 files*
- **`fe4df69`** — Sync PROJECT_STATUS.md with AstoriaIDE rename and tab-strip commits
  Doc had gone stale relative to c93abbe (VisualFBEditor -> AstoriaIDE rename, astoria.exe/astoria.ini) and 4b643af (Code/Form top tab strip).
  *Docs, Settings · 2 files*
- **`d6a7625`** — Update PROJECT_STATUS.md repo URL to lowercase astoria-ide
  GitHub renamed the repo to dmontaine/astoria-ide (lowercase) following the AstoriaIDE rebrand; old Astoria-IDE URL still redirects but origin now points at the canonical lowercase URL directly.
  *Docs · 1 file*
- **`11c033d`** — Default all toolbars visible on first run (owner decision)
  Reverses 13.3.A O3's "Standard + Run only" minimal default -- owner wants Standard/Edit/Project/Run/Format all visible out of the box.
  *Framework/Controls, IDE · 3 files*
- **`0508858`** — Fix CI: windows.bat hardcoded wrong checkout-folder name
  The AstoriaIDE rebrand (c93abbe) updated windows.bat to cd into a folder literally named "AstoriaIDE", but GitHub's checkout action names the workspace after the actual repo, which is "astoria-ide" (lowercase, hyphenated).
  *Build/Tools · 1 file*
- **`f20012c`** — Ignore *.dll.a MinGW import-library build byproducts
  libmff64.dll.a is auto-generated by every -dll build of mff64.dll but never consumed -- the IDE loads mff64.dll dynamically at runtime via DyLibLoad (Main.bas:86), and no build step links against the import lib.
  *Build/Tools · 1 file*
- **`dfe553e`** — Mark B1 (DeleteEditorFile .vfp dirty-sync) done in Open Items
  Investigated as the next Sonnet task; found it was already fully implemented in 331b570 (2026-07-09) as a deferred-delete-until-save flow, more complete than the originally-scoped dirty-mark mirror.
  *Docs · 1 file*
- **`62404e0`** — Fix File > Recent Files being permanently invisible (B3)
  Investigated B3 ("OpenRecentFiles() stub") as the next Sonnet task and found the dialog-based design it described had already been replaced by a live File > Recent Files submenu (miRecentFiles, populated via AddMRU/mClickMRU) -- that part worked correctly.
  *Docs, IDE · 3 files*
- **`4a11208`** — Move Bubble Help/Suggest Options/Parameter Info off Edit menu (C2)
  Bubble Help (ShowSymbolsTooltipsOnMouseHover) and Suggest Options (AutoComplete) already had fully-wired Options > Code Editor checkboxes sitting redundant alongside the Edit-menu toggles; removed the Edit-menu items (miSuggestions, miCompleteWord), their dead Checked-sync lines, their mClick...
  *Docs, IDE · 7 files*
- **`0c88cc5`** — Update splash screen text: title without version, static version line
  Top line (lblSplash) now reads "Astoria IDE for Free Basic" with no version number appended (was pulling ProductVersion from the .rc file).
  *IDE · 2 files*
- **`7c631cb`** — Replace splash screen logo with Astoria Bridge artwork
  Resized the provided AstoriaBridge.png (1342x1172) to 343x270 to match the splash form's lblImage bounds exactly -- the framework draws this image via native Win32 SS_CENTERIMAGE (centers at native size, does not scale), so an unresized drop-in would have rendered zoomed-in and cropped.
  *Build/Tools · 1 file*
- **`121daef`** — Double splash screen display time; fix version-line overwrite bug
  Splash has no fixed display duration -- it stays up for exactly as long as real startup work takes, closing the moment frmMain_Show fires.
  *IDE · 2 files*
- **`bbd8265`** — Fix frmAbout compile error and a latent OnClick crash
  The About dialog's close button was renamed to BtnClose in frmAbout.frm (added an lblImage logo + repositioned controls for a taller layout) but frmAbout.bi still declared the field as cmdClose -- straightforward name mismatch causing the compile to fail.
  *IDE · 3 files*
- **`6b20050`** — Set About dialog close button caption to "Close"
  *IDE · 2 files*
- **`ab75ca3`** — Session working-state: INI/MRU, .vfp file-order, Temp scratch resave
  Incidental churn from having the IDE open this session: recent-file/ project MRU entries in astoria.ini, the Designer's harmless *File= marker reorder in AstoriaIDE.vfp, a cleared VER_ORIGINALFILENAME_STR in AstoriaIDE.rc, and the usual Temp.bas/Temp.rc Designer-scratch resave (not part of the...
  *IDE, Settings · 5 files*

## 2026-07-11

- **`7f9b27d`** — Queue Fable review remediation (T1-T16) in PROJECT_STATUS; add model-assignment rule
  - New ACTIVE SUB-PROJECT section: 16 tasks from the 2026-07-11 Fable full-project review (Documents/fable_review.md), in execution order across 5 waves with per-model (Haiku/Sonnet/Opus/Fable) instructions. - Owner decision recorded: version resets to 1.0 (upstream numbering dropped) - folded into...
  *Docs · 1 file*
- **`33e1ffd`** — Complete Wave 1 hygiene (T9-T11): repo cleanup and shipped-state sanitization
  T9 — Repo hygiene sweep: - Delete C:\Users\don\Downloads\AstoriaBridge.png reference from src/Temp.rc - Untrack + gitignore src/Temp.bas, src/Temp.rc, src/compile_out.txt (Designer-generated scratch files, not real source per prior decisions) - Add gitignore rules for Examples/**/*64.exe and...
  *Build/Tools, Docs, IDE, Settings · 10 files*
- **`a132e23`** — Complete Wave 1 finalization (T8, T12, T13): CI, README, identity/version
  T8 — CI cleanup: - Delete .github/workflows/windows.bat and its three unverified downloads (7-Zip 9.20, FreeBASIC 1.10.0 from SourceForge, upstream MyFbFramework master.zip) -- the repo is self-contained by policy, CI should prove exactly that instead of re-fetching artifacts it mostly didn't use...
  *Build/Tools, Docs, IDE, Settings · 9 files*
- **`7a8e653`** — T1 done: settings-location decision — Option B (per-user install) signed off
  Owner decision (2026-07-11): keep the portable model.
  *Docs · 1 file*
- **`a18fe05`** — Add T17: English-only shipped-content sweep (owner reminder)
  C4 removed translation capability at the code level, but shipped content still carries non-English assets T11 didn't cover: ru/zh/de FB manuals (.chm/.chw) + Win32SDK.chinese.chm in Help/, chinese/french .tip files (unreachable -- App.CurLanguage is hard-set "English"), and the ru/zh/de entries in...
  *Docs · 1 file*
- **`b69ae42`** — Clarify remediation queue: Order column is the sequence, not T-numbers
  Owner momentarily misread T2 as next-after-T1; add a note above the execution-order table stating T-IDs are stable labels, sequence comes from the Order column, and Wave 3 runs as one batch (T3, T4, T7, T2a/T2b, T17) held uncommitted until the T16 review.
  *Docs · 1 file*
- **`4394ca2`** — T3 done: rework PipeCmd -- drop clipboard clobber and blanket shell wrapper
  PipeCmd always ran every command through `cmd /c "..."|clip`, which silently overwrote the user's clipboard on ordinary actions (Open Containing Folder, external tools, Delete Project) and re-parsed filenames/args through cmd.exe's fragile quoting for no reason most callers needed.
  *Docs, IDE · 7 files*
- **`1fbb944`** — T4: replace shelled project delete with native SHFileOperationW
  DeleteProject() (Main.bas) used PipeCmd "rd /s /q ..." (UseShell:=True) to remove a deleted project's folder -- a cmd.exe round-trip that permanently deleted with no error reporting; failures were silent.
  *Docs, IDE, Settings · 4 files*
- **`cda99f8`** — T7: check the 6 remaining unchecked Open For Output writes
  Replicated the R2 pattern (check result, surface failure, bail) at all 6 sites: BuildService.bas:259 (batch-compile file rewrite), frmImageManager.frm:398 (resource file), frmOptions.frm:3119 (HotKeys.txt), frmTools.frm:241 (Tools.ini), Main.bas:8364 (Immediate window scratch file -- shifted from...
  *Docs, IDE · 8 files*
- **`8d04929`** — T2a: startup writability probe; fix main-window-size regression
  T2a: right after the splash's "Load On Startup: Settings" step, before LoadLanguageTexts/LoadSettings run, attempt a real Open For Output against a throwaway Settings/.writetest file -- not just an ACL check.
  *Docs, IDE, Settings · 4 files*
- **`e83212f`** — T2b + T17 done: drop dead Languages.txt writes; English-only content sweep
  T2b -- delete the dead Languages.txt write sites (frmFind.frm:575, frmFindInFiles.frm:476): translation-era debug dumps to the IDE root, guarded by `tML = "ML("` -- meaningless since C4 removed the ML() system entirely.
  *Build/Tools, Docs, IDE, Settings · 15 files*
- **`226bae2`** — T16 done: Fable adversarial review of Wave 3 -- 3 findings for Sonnet
  Reviewed all five Wave-3 commits individually (T3 4394ca2, T4 1fbb944, T7 cda99f8, T2a 8d04929, T2b+T17 e83212f) against the charter: injection via file/tool names, paths with spaces, failure paths, clipboard, threading.
  *Docs · 1 file*
- **`d80135f`** — Fix T16 findings: Compile() cleanup, delete path, exe quoting
  F-T16-1 (confirmed bug): Compile()'s early Return 0 on a failed batch-file rewrite (BuildService.bas) was the function's only early return and skipped the common exit's StopProgress/CompileContextFree -- left the progress marquee spinning forever and leaked the compile context on that path.
  *Docs, IDE, Settings · 5 files*
- **`d84b2ef`** — Fix Add External Tool (and 5 other path-picker flows) silently failing
  Owner smoke-test finding: Tools > External Tools > Add, browse to chrome.exe, path fills in correctly, click OK -- dialog closes but no tool appears in the list.
  *Docs, IDE, Settings · 10 files*
- **`7a0c829`** — Fix Add External Tool: Form_Close was clobbering ModalResult to Cancel
  Live MsgBox diagnostic tracing (owner walked through it interactively) found the actual root cause after the earlier snapshot-fields fix proved insufficient: frmPath.frm's Form_Close, wired as the framework's OnClose callback, fires on every WM_CLOSE -- including the one cmdOK_Click itself triggers...
  *Docs, IDE · 4 files*
- **`e585cd1`** — Log dark-mode Apply live-repaint gap as deferred item (13.12)
  Owner smoke test (2026-07-11): toggling Dark Mode + Options Apply updates some controls immediately (a text box confirmed) but others stay light until the IDE is relaunched; full theme is correct on next launch, so this is a live-repaint completeness gap, not a persistence bug.
  *Docs · 2 files*
- **`f4b00a0`** — Add pending audit: confirm External Editors is actually removed
  Owner's understanding (2026-07-11 smoke test) is this feature was removed many cycles ago, superseded by External Tools.
  *Docs · 1 file*
- **`6c3a995`** — Mark Wave 1 (T8-T13) done in the execution-order table
  These landed before this session's Wave 3 work (33e1ffd, a132e23) but the table rows never got the checkmark annotation the later rows use -- doc-only fix while validating overall remediation-queue status.
  *Docs · 1 file*
- **`937c2f2`** — Replace sample Project1/Project2 with Project3 console app; sync tool/recent-file settings
  Add chrome and notepad++ external tools; update astoria.ini recent files/projects to point at Project3.
  *Build/Tools, Examples, Settings · 7 files*
- **`bf2bef2`** — T5: quote the bundled GDB path in the debugger launch
  CreatePipeD (Debug.bas) concatenated szCmd (the full path to the bundled gdb.exe) into CreateProcess's lpCommandLine unquoted.
  *Docs, IDE · 3 files*
- **`b5cc3eb`** — Debugger UI: promote Step Out, clarify step tooltips, drop T6 tracing
  - Move Step Out onto the top-level Run menu, directly under Step Over (was buried in the More Debug Options submenu); hotkey and toolbar button unchanged. - Expand the Step Into/Over/Out toolbar tooltips to describe what each command does, keeping the auto-appended hotkey. - Remove the T6...
  *IDE · 3 files*
- **`33243f8`** — Remove stray "Download - Copy" duplicate example folder
  Accidental duplicate of Examples/Download; deletes the 9 copied files.
  *Examples · 10 files*
- **`9991f76`** — WIP: T6 debugger — set_bp pipe-race fix + T14 doc consolidation (mid-session handoff)
  Committed mid-investigation for cross-machine sync (owner request); the debugger fix is NOT yet owner-verified.
  *Docs, IDE · 4 files*
- **`0907d6e`** — Extract debugger work into a dedicated Debugger Reliability sub-project
  Owner live-testing of the T6 set_bp fix surfaced three more distinct, separately-rooted debugger defects, so debugger work is now its own reliability effort rather than a single Fable-remediation task.
  *Docs · 1 file*
- **`9c18bd8`** — T15: curate shipped editor themes to a 10-theme shortlist (owner: Option B)
  Owner signed off the fable_t15_theme_catalog.md memo same day: Option B, shortlist as proposed, shipped default reset to Default Theme.
  *Docs, Settings · 88 files*
- **`72c48c2`** — Close the Fable review remediation sub-project
  Owner confirmed the accumulated smoke-test list was completed earlier (findings all dispositioned as they surfaced: frmPath ModalResult bug fixed in 7a0c829, 13.12 dark-mode Apply gap deferred, External-Editors audit question recorded).
  *Docs · 1 file*
- **`24b5c0c`** — T14 archival: move the closed Fable-remediation section to HISTORY.md
  The deferred piece of T14, unblocked by the queue closing today.
  *Docs · 2 files*
- **`5100072`** — Reshape Debugger Reliability plan around a GdbSession transport
  Adds Phase 0 (fragility audit) findings and reorganizes the sub-project around a single-owner transport rewrite.
  *Docs · 1 file*
- **`f40bb8a`** — Debugger Reliability Phase 1: commit instrumented trace build (temporary)
  Cross-machine handoff — the owner will run the repros on another machine, so the trace instrumentation and its rebuilt binary are committed (the prior session kept DbgTrace working-tree-only; committing here for sync).
  *Docs, IDE · 6 files*
- **`7ad2556`** — Debugger Reliability: first owner repro pass analyzed (5 obs)
  Analyzed Settings\debug_trace.log from the owner's instrumented-build repro.
  *Docs · 1 file*
- **`d4736f4`** — DR-4 refinement: blanking is the .frm CodeAndForm (split) view
  Owner clarified the gutter-click blank happens in the CodeAndForm (divided) view, not Form-only.
  *Docs · 1 file*
- **`b7af611`** — DR-4: full repaint on breakpoint toggle (fixes .frm CodeAndForm blank)
  EditControl.Breakpoint called the partial repaint (bFull=False) after toggling a breakpoint marker.
  *Framework/Controls, IDE · 3 files*
- **`6223698`** — DR-9: untrack + gitignore example build artifacts (*.exe/*.o/*.obj)
  Untrack 6 compiled example binaries (FileBrowser64.exe, MDIForm64.exe, MediaPlayer64.exe, Radar64.exe, USBView64.exe, Test_WellCOM64.exe).
  *Examples · 6 files*
- **`8581a9d`** — DR-4 closed: owner-verified fix in .frm CodeAndForm split view
  Owner confirmed: "Set breakpoint using gutter works.
  *Docs · 1 file*
- **`9fc5071`** — Debugger: 2nd repro pass findings + 3 new defects (DR-11/12/13)
  Second owner repro pass (obs #6).
  *Docs · 1 file*
- **`1899513`** — Debugger 2A: strict-lockstep gate on the worker command queue (fixes DR-3 desync)
  The GDB worker loop (Debug.bas:2095) dequeued+sent a queued command at the top of every iteration unconditionally.
  *Framework/Controls, IDE · 3 files*
- **`2555f44`** — Mark DR-3 2A (lockstep desync fix) done + owner-verified
  *Docs · 1 file*
- **`d8a2e8f`** — DR-12: fix dead toolbar Toggle Breakpoint button (command-name mismatch)
  The toolbar button dispatched command "ToggleBreakpoint", but no Case "ToggleBreakpoint" handler exists -- only Case "Breakpoint" (what the Run menu's Toggle Breakpoint item dispatches).
  *Framework/Controls, IDE · 3 files*
- **`f534b42`** — DR-11: commit temporary CloseProject trace instrumentation
  Adds 9 DbgTrace markers through CloseProject's teardown and tvExplorer_SelChange (src/Main.bas) to locate exactly where closing a project freezes the IDE when a non-project ("standalone") file is open (owner-reported 2026-07-11; deterministic 2/2).
  *IDE · 2 files*
- **`99bfcb1`** — Cross-machine handoff: rewrite Debugger Reliability banner (2026-07-11)
  Owner is switching machines mid-session.
  *Docs · 1 file*
- **`22271a3`** — DR-3 slice 2D: marshal debug-panel fills to the UI thread (fixes deadlock + DR-13)
  Owner-verified ("works, no problems"): quick-F8-after-stop no longer freezes; panels + highlight intact.
  *Docs, IDE · 5 files*
- **`b90b862`** — gitignore debugger trace logs + record DR-11 static root-cause analysis
  - .gitignore: Settings/debug_trace.log and *.pass1/pass2.log (local-only per-machine trace instrumentation output; must not be committed). - PROJECT_STATUS.md DR-11 row: read-only static analysis (no code changed) ranking the CloseProject-freeze candidates and mapping each to the last-seen DbgTrace...
  *Build/Tools, Docs · 2 files*
- **`3b60be6`** — DR-11 resolved: not reproducible post-DR-3-fix (downstream symptom)
  Owner re-tested with the exact original setup (relaunch/workspace-restore + standalone Brush.bas open, then close project): no freeze.
  *Docs · 1 file*
- **`e596c53`** — DR-8 + debug/project-close UX cleanup (owner-verified)
  Owner-verified this build: "everything works correctly."
  *Docs, IDE · 7 files*
- **`70ede51`** — Temporarily restore all 96 editor themes for owner re-curation
  Owner didn't want T15's auto-picked 10-theme shortlist and will choose their own set.
  *Docs, Settings · 87 files*
- **`5c50f20`** — T15 re-curation: shortlist shipped editor themes to 12 (owner picks)
  Owner re-picked the shortlist after the themes were temporarily restored to all 96 for review.
  *Settings · 84 files*
- **`8835186`** — Rebuild astoria.exe after theme re-curation
  No source change -- themes are loaded at runtime via a folder scan, not compiled in.
  *IDE · 1 file*

## 2026-07-12

- **`0f30654`** — Debugger 2B: race-free Stop/kill (DR-6) + dead-inferior cleanup (DR-14)
  DR-6: Stop-while-running called kill_debug() on the UI thread, which raced the worker on the shared GDB pipe (a second readpipe) and closed hReadPipe/hWritePipe while the worker could be mid-ReadFile.
  *IDE · 3 files*
- **`fa8cec6`** — Project3: make it a runnable debugger test target
  - Project3.vfp: mark Module1.bas as the main file (*File= prefix).
  *Examples · 2 files*
- **`bb63c1b`** — Mark DR-6/DR-14 done (slice 2B); rewrite session handoff banner
  2B (DR-6 + DR-14) owner-verified.
  *Docs · 1 file*
- **`47d2583`** — Debugger 2C: unified breakpoint arm/clear (DR-1/DR-10) + DR-14 residual
  All breakpoint toggles (F9, gutter-click, Run > Toggle Breakpoint) now route through EditControl.Breakpoint -> arm_breakpoint, which ENQUEUES break/clear/ tbreak.
  *IDE · 5 files*
- **`4b7a47a`** — Project3: expand debugger test bench
  Replace the 4-line infinite loop with a longer console program for exercising the debugger: Factorial/Fibonacci functions (step in/out, locals/watches), loops with accumulators (breakpoints that hit repeatedly), a free-running heartbeat loop (Stop-while-running + mid-run arm), and deliberate...
  *Examples · 1 file*
- **`abc9d14`** — Docs: mark slice 2C done (DR-1/DR-10), DR-14 residual fixed; DR-4 next
  Slice 2C owner-verified 2026-07-12.
  *Docs · 1 file*
- **`c542ec8`** — Docs: note orphaned astoria.exe process surviving window close
  A process held astoria.exe locked minutes after the window was closed (owner confirmed closed; PID 19912 blocked a rebuild).
  *Docs · 1 file*
- **`57007dc`** — DR-15: kill the inferior on app close when running freely (fixes orphaned debuggee)
  CloseAllDocuments already enqueued "q" for an active debug session on close, but GDB does not act on stdin while the inferior is running freely in synchronous all-stop mode, so the queued q could sit unprocessed forever -- deinit's bare "q\n" + close-handles never reached GDB, orphaning the...
  *IDE · 1 file*
- **`9e40c42`** — Phase 4 dead-code sweep: remove the vestigial integrated (stabs) debugger
  Removes ~1160 lines of dead code left over from the old integrated/stabs debugger (pre-GDB), confirmed dead via a full src/ cross-reference (every symbol checked case-insensitively; none had a live reader/writer outside its own declaration):
  *IDE · 3 files*
- **`07ea740`** — Rebuild astoria.exe with DR-15 fix + Phase 4 dead-code sweep
  The tracked exe was last rebuilt at 47d2583, before DR-15 (57007dc) and the Phase 4 sweep (9e40c42) -- every verification since used a debug build that was discarded afterward, so the committed binary never picked up the fix.
  *IDE · 1 file*
- **`8ce74f2`** — DR-7: marshal worker-thread Output/watch-edit/panel-clear touches to the UI thread
  Residual from the 2D audit, now closed.
  *IDE · 3 files*
- **`ce10b5c`** — Rebuild astoria.exe with DR-7 marshal fix
  Release build, owner quick-tested a normal debug session behaves identically post-marshal (breakpoint/step/watch/output).
  *IDE · 1 file*
- **`7604d8d`** — DR-4 instrumentation: trace the paint-state driving the visible-line count
  Temporary trace (EC.Paint) for the disappearing-text-on-breakpoint-toggle bug.
  *IDE · 1 file*
- **`c0cd0b8`** — Cross-machine handoff: AMD -> Intel for DR-4 (2026-07-12)
  Updates the status banner and defect table for this session's work: DR-15 (orphaned process on close) and DR-7 (worker-thread UI marshal residual) both fixed + verified, Phase 4 dead-code sweep done.
  *Docs · 1 file*
- **`fee21d3`** — DR-4: Intel EC.Paint trace captured -- geometry hypothesis disproven
  The toggle's full paint reaches EC.Paint on Intel with geometry IDENTICAL to every restoring paint (dwClientY=526, dwCharY=16, vlc1=32, LinesCount=68, path=GDI) -- the paint loop covers all 32 visible lines, so vlc1 is not short.
  *Docs · 1 file*
- **`56afc8a`** — DR-4 FIXED: gutter click no longer horizontally scrolls the viewport
  DR-4 ("text disappears on breakpoint toggle") was never a paint/geometry bug.
  *Docs, IDE · 3 files*
- **`8fe9f67`** — Docs: 2-clicks-to-close investigated -- not a code bug (Windows activation)
  Instrumented the close path (CloseAllDocuments entry state + every Return False/True + the frmMain_Close call-site result) and reproduced the multi-click close.
  *Docs · 1 file*
- **`63104f1`** — DR-16(b) FIXED: marshal deinit's UI touches off the worker thread
  deinit() runs on the worker thread (confirmed: its only two live callers are both inside run_debug's loop -- the 'q'-dequeue branch and the LOOP.inferiorGone branch).
  *Docs, IDE · 3 files*
- **`957ff18`** — Docs: rewrite session handoff banner for machine switch
  Refresh the stale AMD-to-Intel banner with this session's actual state: DR-4 fixed, close-path investigated (not a bug), DR-16(b) fixed.
  *Docs · 1 file*
- **`600a8c7`** — DR-16(a): pre-flight GDB/exe/MainFile checks to the UI thread before debug start
  Owner design decision: fix properly rather than defer.
  *IDE · 3 files*
- **`91b054f`** — Rebuild astoria.exe with DR-16(a) fix
  Release build, owner-verified: happy path unchanged, missing-exe error path now shows the message immediately on the UI thread.
  *IDE · 1 file*
- **`f40ff39`** — Docs: mark DR-16(a) done, DR-16 fully closed; log 3 new owner-flagged items
  DR-16(a) owner-verified this session (happy path + missing-exe error path).
  *Docs · 1 file*
- **`892f28b`** — Docs: theme re-curation was already done (5c50f20); track the dropped T15 color-tweaks question
  Verified against the repo: Settings/Themes/ has exactly the 12 files the owner picked, matching the commit.
  *Docs · 1 file*
- **`90f4dc7`** — Phase 4 dead-code sweep (cont'd): remove kill_debug() and line_highlight's unreachable branch
  The two items flagged during the DR-16 audit, both re-verified before removal:
  *IDE · 1 file*
- **`64ea0ed`** — Rebuild astoria.exe after Phase 4 dead-code sweep
  Pure removal of unreachable code (kill_debug, line_highlight's dead branch), no behavioral change to verify live.
  *IDE · 1 file*
- **`45eef81`** — Docs: Phase 4 dead-code items done; flag instrumentation-strip as needing owner go-ahead
  kill_debug() and line_highlight's unreachable branch removed and documented.
  *Docs · 1 file*
- **`c906d19`** — Docs: MyFbFramework review (Fable 2026-07-12) — findings + task list
  First review of Controls/MyFbFramework/ (vendored LGPL UI framework, now git-tracked).
  *Docs · 1 file*
- **`cec7355`** — Docs: cross-machine handoff banner — MFF review done, deeper-review guidance
  Adds the AMD/other-computer handoff banner: DR-1..DR-16 fully closed, Phase 4 dead-code done, first MyFbFramework review complete (task list in Open Items).
  *Docs · 1 file*
- **`a91b02e`** — Docs: T0 resolved — MFF is a separately-maintained fork, patch locally
  Owner decision 2026-07-12: MyFbFramework will be a separately maintained fork with no upstream sync; all source (incl. modifications) is published on GitHub, satisfying LGPL.
  *Docs · 1 file*
- **`3a787b9`** — Docs: correct the MFF droppable-controls count (~15-20 widgets, not ~150)
  Dependency analysis showed the earlier "~150 unused files" figure wrongly counted foundational types the used controls require transitively (Integer/ Sys/Control/Object/Font/Brush/UString/List/Bitmap/etc. -- referenced by dozens to hundreds of mff files; dropping any breaks the build).
  *Docs · 1 file*
- **`fd7f9a6`** — Docs: point to the consolidated P:\Astoria-Docs report location
  The supporting reports (fable_review.md, mff_review.md, debugger_fragility_audit.md, sonnet_ai_recommendation.md, fable_t1_settings_location.md, fable_t15_theme_catalog.md, Deferred Task Recommendations - Opus.md) were each machine's local Documents/ folder -- never git-tracked, so a git pull never...
  *Docs · 2 files*
- **`4a0798b`** — MFF cleanup: drop HTTPServer, Animate, and orphaned ListItemsOld
  Widget/hygiene trim of the vendored MyFbFramework (T0 residual + F-H3), per the Fable MFF review.
  *Docs, Framework/Controls, IDE · 13 files*
- **`2aee074`** — T-OPUS-1: resolve the ThreadsEnter/ThreadsLeave contract (F-M1)
  The framework's cross-thread-safety API (ThreadsEnter/ThreadsLeave, Component.bas) is a pair of empty no-op stubs on the WinAPI build -- the framework-level root cause of the IDE's DR-3/DR-7 debugger-hang class, since every "ThreadsEnter ... touch UI ...
  *Framework/Controls, IDE · 2 files*
- **`8726f3f`** — Docs: mark T-OPUS-1 done (ThreadsEnter/Leave contract resolved)
  *Docs · 1 file*
- **`bbf8dc2`** — T-OPUS-2: audit UString accounting; fix dead-but-unsafe AppendBuffer (F-M2)
  Audit verdict: the IDE's reachable UString memory surface is SAFE. - Resize (live at BuildService.bas:353) is used safely -- resize-then-fully- overwrite via MultiByteToWideChar; the "dealloc+calloc destroys old content on grow" quirk is harmless because the caller overwrites the whole buffer....
  *Docs, Framework/Controls, IDE · 4 files*
- **`9331526`** — T-SON-3: guard unchecked Open in MFF list/combo/bitmap controls (F-R-mff)
  Same defect class as the main review's F-R2: SaveToFile/LoadFromFile in CheckedListBox, ComboBoxEdit, and ListControl opened a file and proceeded to read/write it without checking whether Open succeeded -- on a locked/read-only/ permission-denied target (the Program-Files scenario F-S4 warned...
  *Docs, Framework/Controls, IDE · 7 files*
- **`f4d0ac5`** — T-SON-4: fix Registry.bas truncation, validation, and a UTF-16 write bug (F-R-reg)
  Key finding: Registry.bi is not included by mff.bi at all (confirmed via the include graph and a byte-identical mff64.dll before/after this change), so Registry.bas is orphaned source, never compiled into the shipped DLL -- same class of finding as the dead code closed in the Phase 4 sweep.
  *Docs, Framework/Controls · 2 files*
- **`9b19f1e`** — T-SON-2: harden HTTPConnection -- UserAgent property, response cap, retry docs (F-N7)
  Three fixes to the HTTP client (kept when HTTPServer was dropped -- the IDE uses this one):
  *Docs, Framework/Controls, IDE · 5 files*
- **`73ca4ce`** — Docs: mark MFF review fully closed; rewrite the top handoff banner
  Both sub-projects opened this week (Debugger Reliability DR-1..DR-16, MFF review) are now fully closed.
  *Docs · 1 file*
- **`7f4dc5e`** — Docs: MFF hot-path deep-pass (Fable 2026-07-12) — 4 findings, none IDE-critical
  Targeted read of the framework's hot paths (Control WndProc/paint, Canvas + Bitmap GDI lifecycle).
  *Docs · 1 file*
- **`27540ae`** — H-3: document the WM_PAINT GetDC-not-BeginPaint fence; drop the dead commented BeginPaint
  Investigating the H-3 "fix" (switch WM_PAINT from GetDC to BeginPaint/EndPaint) revealed the BeginPaint form was already present, commented out -- someone switched FROM BeginPaint TO GetDC upstream (before this fork; the -S search lands on the initial MFF-import commit, not a paint change) and left...
  *Docs, Framework/Controls · 2 files*
- **`7ff604c`** — H-2: document the Canvas GetDevice/ReleaseDevice HandleSetted collision; defer the fix
  MFF hot-path review H-2.
  *Docs, Framework/Controls · 2 files*
- **`eb56592`** — Docs: cross-machine handoff — H-1 fix plan recorded, H-4 next, H-2/H-3 done
  Session ended on budget before H-1 was edited (only read).
  *Docs · 1 file*

## 2026-07-13

- **`7fe5388`** — Docs: refresh project handoff
  *Docs · 2 files*
- **`bfbf203`** — Fix Canvas Direct2D clear cleanup
  Avoid creating a GDI brush on the Direct2D clear path and close an acquired Direct2D drawing session before returning.
  *Docs, Framework/Controls, IDE · 4 files*
- **`934a9b6`** — Remove duplicate Canvas GDI fill
  Remove the redundant FillRect after Canvas.Cls has already filled the selected rectangle.
  *Docs, Framework/Controls, IDE · 4 files*
- **`e1595a3`** — Fix View menu owner-review findings: 6 enablement bugs
  Owner walkthrough of the View menu (deferred sign-off item) surfaced six real bugs, all fixed and rebuilt clean:
  *Docs, Framework/Controls, IDE · 7 files*
- **`d099dc6`** — Resolve 4 deferred owner decisions: Change Log location, project paths, themes
  - Change Log: <ProjectName>_Change.log now lives in the project's own folder instead of ExePath, and appears as a node under the project tree's Others folder (double-click jumps to the Change Log tab; rename is blocked since it's a synthesized node, not a real file).
  *Docs, IDE · 5 files*
- **`faaf086`** — Flatten Run menu: remove More Build Options and More Debug Options submenus
  All build and debug commands now sit directly in the top-level Run menu instead of split between the top level and two buried submenus, per owner's chosen "flatten into top level" approach.
  *Docs, IDE · 5 files*
- **`603cbe4`** — Remove Direct2D rendering entirely; GDI/GDI+ is now the sole path
  Direct2D was force-disabled at every startup and never exercised live by a real user, and already had one real bug found in it the same day (H-1).
  *Docs, Framework/Controls, IDE · 19 files*
- **`ffc21f3`** — Add missing tooltips to frmImageManager toolbar buttons
  Finishes the toolbar tooltip audit: Add/AddDropdown/Change/Remove/Up/Down/Sort had no hint text at all, unlike the ShowHint-only gaps fixed elsewhere.
  *IDE · 1 file*
- **`05ff947`** — Add missing-exe check to Run; fix debug Returned code always showing 0
  Non-debug RunProgram/RunPr now checks the target exe exists before launching, matching the pre-flight check the debug path already had.
  *Docs, IDE · 6 files*
- **`f875fcc`** — MFF hygiene: remove dead Chinese-language leftovers, close out the rest
  Deleted README_CN.md and changes_cn.txt (dead Chinese translations no longer maintained), removing their two references: the File=README_CN.md entry in MyFbFramework.vfp, and the dead language-switcher link at the top of Controls/MyFbFramework/README.md.
  *Docs, Framework/Controls · 6 files*
- **`472b4b2`** — Rename MFF DLL to astoria.dll, move it to the repo root
  Owner request: source file names stay the same, but the compiled MFF build artifact should be astoria.dll living next to astoria.exe, reflecting how much of MFF's own code is now locally owned/changed (Direct2D removal, H-1/H-4, the hot-path review).
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings · 19 files*
- **`d48a6cd`** — Remove toolbox component picker; fix a real GetFullPath .. bug
  Owner decision: no more choosing which Controls\* libraries appear in the toolbox (matches the project's "no unnecessary options" posture).
  *Docs, IDE, Settings · 9 files*
- **`cc31921`** — Rename Controls/MyFbFramework to Controls/Framework
  Owner request: rename the MyFbFramework directory to Framework, and MyFbFramework.wiki/MyFbFramework.vfp to match inside it.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE, Settings, Templates · 725 files*
- **`cac01fd`** — Rename astoria.dll to framework.dll, move back into Controls/Framework
  Owner request, for consistency with the just-renamed folder.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE · 18 files*
- **`7b26251`** — Redesign New Project dialog: combined name prompts, optional Form/Module
  Merges what used to be a template-picker dialog plus a separate popup name prompt into one dialog: template icons on top, inline Project Name (required)/Primary Form Name/Primary Module Name fields below.
  *Docs, IDE · 7 files*
- **`28ac835`** — Regen app icon; sync Project4 test bench and example .vfp schema
  - AstoriaIDE.ico regenerated via new Resources/gen_step1.py script - Project4 rebuilt with New Project dialog (Module1.bas -> Main.bas, matching current default naming), .vfp picks up current schema fields - DeviceExplorer.vfp normalized to current .vfp schema from IDE open/save - astoria.exe...
  *Build/Tools, Examples, IDE · 9 files*
- **`56fb483`** — Translate Chinese comments to English in Examples/
  104 of 620 tracked Examples/ files had Chinese-language comments; translated meaning-preserving to English, code untouched.
  *Docs, Examples · 105 files*
- **`2e160bb`** — Examples: English-only translation cleanup + dead code sweep
  Extends the English-only mandate (a510b24/e83212f) from IDE chrome to Examples/, Controls/MyFbFramework/examples/, and Tools/, then removes dead code across the same trees.
  *Build/Tools, Docs, Examples, Framework/Controls · 261 files*
- **`9f94ac9`** — Document unpushed/diverged branch state for next session
  origin/main moved 9 commits ahead (likely the other computer) while this session's Examples cleanup was in progress, including two commits that appear to overlap it directly.
  *Docs · 1 file*
- **`6afd4da`** — Flatten and validate example projects
  *Docs, Examples · 444 files*
- **`489a3ed`** — Update project task status
  *Docs · 2 files*
- **`e9bc31d`** — Remove temporary project files and sync settings
  *Examples, Framework/Controls, Settings · 4 files*
- **`e3f5817`** — Document settings synchronization policy
  *Docs · 2 files*
- **`49f838a`** — Document session handoff
  *Docs · 1 file*
- **`2f445e4`** — T01: standardize src/ indentation to tabs; normalize src/ line endings to CRLF
  Fixed 3 files with space or mixed tab/space indentation (Main.bas, TabWindow.bas, frmOptions.frm) to match the codebase-wide tab convention.
  *Build/Tools, IDE · 73 files*
- **`6f933f4`** — T16: add tooltips to build-config combo, search boxes, class/function dropdowns; flatten Tools menu; reconcile backlog
  - T16: added .Hint text to cboBuildConfiguration, the four Designer search boxes (Explorer/Toolbox/Properties/Events), and the code editor's cboClass/cboFunction dropdowns, following the existing .Hint = (...) convention. - Flattened the Tools menu: removed the "Advanced" submenu, promoting Add-Ins...
  *Docs, IDE · 4 files*

## 2026-07-14

- **`2f9d513`** — Remove Other Editors panel from Options; External Tools covers the use case
  Owner decision: users can already register a per-extension launch tool under Tools > External Tools, making the dedicated Other Editors panel in Tools > Options > Code Editor redundant.
  *IDE · 6 files*
- **`7f4ac71`** — Document session handoff (2026-07-14)
  - T01 (partial): src/ indentation and line endings standardized (2f445e4) - T16: toolbar tooltips added (6f933f4) - Tools menu flattened; T02/T13 dropped by owner decision (6f933f4) - Other Editors panel removed from Options (2f9d513) - Sync tracked Settings/astoria.ini per standing rule
  *Docs, Settings · 3 files*
- **`fc0c34d`** — T12: live dark-mode re-theming after Options Apply (partial)
  Toggling Dark Mode in Options now re-themes the running UI live instead of only partially (previously the full dark look needed a restart).
  *Docs, Framework/Controls, IDE, Settings · 10 files*
- **`070c747`** — T12 follow-up: fix cold-start dark mode and remaining owner-verified glitches
  Three bugs found via owner testing after the initial T12 commit, all owner-verified fixed:
  *Docs, Framework/Controls, IDE, Settings · 7 files*
- **`67b0891`** — T10 + T11: dark-mode popup menus and dialogs
  T10: dark-theme the main menu bar, context menus, and toolbar dropdowns (Form.bas, Control.bas, ToolBar.bas) - fixes a submenu-header caption bug, adds separator/checkmark/radio/arrow glyph painting, and wires the same owner-draw handling into Control.bas/ToolBar.bas since context menus and toolbar...
  *Docs, Framework/Controls, IDE, Settings · 12 files*
- **`4795d9b`** — T01: standardize Controls/ indentation to tabs; normalize line endings to CRLF
  Converted 124 files with space-only or mixed tab/space indentation to tabs (126 flagged, 2 - SystemInformation.bas/.bi - hand-fixed instead since their original spacing was too inconsistent, 3 vs 7 spaces, for any single per-file unit to fit cleanly).
  *Build/Tools, Framework/Controls, IDE, Settings · 132 files*
- **`6682da9`** — T01: standardize Examples/ indentation to tabs; normalize line endings to CRLF
  Small, clean scope compared to Controls/: 7 files with space indentation (Basic.bi, Calculator.frm, Com_HtmlFile2.frm, Maze.frm, Temp.bas, WlanListNetworks.bas, WellCOM2.0_vtable.bi), each with a single consistent 3- or 4-space unit throughout - auto-detected conversion produced zero remainder...
  *Build/Tools, Docs, Examples, Framework/Controls, IDE · 12 files*
- **`595e3de`** — Add StageRelease.ps1: assemble an end-user-facing release tree
  Copies only what an end-user developer needs to run Astoria-IDE and compile their own FreeBasic programs with it - not this repo's own IDE source (src/), build scripts, or maintainer docs.
  *Build/Tools · 1 file*
- **`2a04a71`** — Add Personal Information page to Tools > Options
  New page between Designer and Help in the Options tree: Name, Company, Web site, E-mail address, a multi-line Address field, and a multi-select License group (GPL3/LGPL/Apache/BSD/Freeware/Proprietary/Other, with the Other checkbox enabling its own description field).
  *IDE · 6 files*
- **`39d9b15`** — T08: build a per-user Windows installer with Inno Setup
  Adds AstoriaIDE.iss (packages the StageRelease.ps1 tree into a per-user, no-admin Inno Setup installer with Start Menu shortcuts and a proper uninstall entry) and BuildInstaller.ps1 (runs staging + compile together, since re-running the compile alone just repackages a stale tree).
  *Build/Tools, Docs · 4 files*
- **`b05fdac`** — Add context-menu parity: code pane done, Designer partial
  Owner dislikes using toolbars, so both the code editor's and the Form Designer's right-click menus should offer everything the toolbars do.
  *Docs, IDE · 4 files*
- **`64a3191`** — Ignore IDE-generated Temp.bas scratch files
  Temp.bas is the per-build file the IDE writes when compiling/previewing a form; it is machine-local generated output, not source.
  *Build/Tools, Examples, Templates · 22 files*

## 2026-07-15

- **`ab8d166`** — Designer context menu: fix format submenus not rendering
  The Align / Make Same Size / Horizontal Spacing / Vertical Spacing / Center in Parent submenus were added to mnuDesigner with a @mClick handler on the submenu-header items (4-arg Menu.Add).
  *Docs, Framework/Controls, IDE, Settings · 5 files*
- **`036c5fa`** — Designer context menu: format items now visible; Align submenu works
  Two fixes for the Designer right-click menu format block: - Submenu headers use 3-arg Menu.Add (no @mClick), matching the working mnuCode "Toggle" header - a handler on a header broke rendering. - Stop toggling the format items' Visible in ChangeFirstMenuItem.
  *Docs, IDE, Settings · 4 files*
- **`9d797cd`** — Designer context menu: rule out two theories for empty format submenus
  Third attempt at the Align/Make Same Size/Horizontal Spacing/Vertical Spacing/Center in Parent submenu bug (only Align renders its children; the other four show the arrow but an empty flyout).
  *Docs, IDE · 3 files*
- **`f69c4a8`** — Remove dark mode entirely for stability
  Owner decision: dark mode had a recurring history of owner-draw-only glitches (T10/T11/T12), culminating in a dark-only context-menu render bug where popup submenus after the first painted empty.
  *Docs, Framework/Controls, IDE · 74 files*
- **`bb622c1`** — Sync Settings/astoria.ini window width from this machine
  Per standing rule: astoria.ini is tracked and committed whenever it changes so both development computers stay synchronized.
  *Settings · 1 file*
- **`06d0a6a`** — New Project dialog: add Author, License, Git URL, AI-friendly fields
  Owner-requested additions to frmNewProject (dialog expanded 480x290 -> 480x418): Author (defaults from Options > Personal Information > Name, editable per-project), License dropdown (GPL/LGPL/Apache/MIT/Mozilla/BSD/ Freeware/Proprietary/Other, pick-only via cbDropDownList), Use Git checkbox + Git...
  *Docs, Framework/Controls, IDE · 5 files*
- **`eea3392`** — Add Project Setup Templates implementation plan
  Scopes the Templates/{Licenses,Git,AI,Readme} work into 8 sequenced tasks (lowest-risk-first) with per-task model recommendations, an AI-agnostic tool dropdown design (Claude Code/Cursor/ChatGPT/OpenCode/Kun), and 5 open questions for owner review.
  *Docs · 1 file*
- **`894598f`** — Add Project Setup Templates scaffolding
  Groundwork for the Project Setup Templates feature (see PROJECT_SETUP_PLAN.md): stampable, ship-with-the-app template content under Templates/, using the token set {{PROJECT}} {{AUTHOR}} {{YEAR}} {{DATE}} {{LICENSE}}.
  *Templates · 31 files*
- **`f2b28a7`** — Project Setup Plan: add Task 8 (Project Properties editor)
  Owner-requested: a form (via the project Properties menu) to change setup choices made at creation — License, Use Git + Git URL, AI tool, and a new Project Description — reading/writing the .vfp metadata (Author/License/UseGit/GitURL/ AIFriendly + AITool).
  *Docs · 1 file*
- **`4d1217a`** — New Project dialog: add Description field + AI Agent dropdown
  Continues the Project Setup Templates feature (PROJECT_SETUP_PLAN.md).
  *Docs, IDE · 4 files*
- **`987e8b7`** — New Project dialog: wire up Git and AI-friendly behavior; fix a framework Z-order bug
  - Replace the free-typed Git URL field with Git Provider/Username/Email fields that construct git@<host>:<user>/<project>.git for GitHub/GitLab/Bitbucket/ Codeberg. - On OK, stamp Templates/AI/<tool> into AI-friendly projects with token substitution, and run git init/commit/remote-add locally...
  *Docs, Framework/Controls, IDE · 7 files*

## 2026-07-16

- **`84d066a`** — Fix silently non-modal first MsgBox: create the measurement window hidden
  The first MsgBox of every app run was silently non-modal: MsgBoxForm.Execute pre-creates its window for text measurement, Control's constructor defaults FVisible=True, and CreateWnd auto-shows a visible-flagged Form -- so the box appeared on screen mid-setup, and Form.ShowModal's already-visible...
  *Framework/Controls, IDE · 4 files*
- **`557f31f`** — PROJECT_STATUS: record the first-MsgBox-per-run non-modality root cause and fix
  *Docs · 1 file*
- **`0c309b3`** — Remove stray Projects/Main.bas (owner cleanup of local test artifacts)
  *Examples · 1 file*
- **`787cc6d`** — New Project Git flow: verify Yes re-checks the remote; stamp .gitignore/.gitattributes; fix initial-commit ordering
  Three fixes to the Use Git path in the New Project dialog, all owner-verified live:
  *IDE · 3 files*
- **`4c103b3`** — PROJECT_STATUS: record the Git-flow fixes (Yes re-check, gitignore stamping, commit ordering)
  *Docs · 1 file*
- **`86948b5`** — Round-trip the New Project metadata keys through project load/save
  The ten .vfp metadata keys the New Project dialog appends (Author, License, Description, UseGit, GitProvider, GitUserName, GitEmail, GitURL, AIFriendly, AITool) were write-only: AddProject's parser deliberately skipped them and the project writer regenerates the .vfp purely from the in-memory...
  *IDE · 4 files*
- **`20d955a`** — PROJECT_STATUS: record the metadata round-trip fix and close out AI stamping verification
  *Docs · 1 file*
- **`9ca88b6`** — Remove dead App.DarkMode from the two new-project templates
  Dark mode was removed from the framework (2026-07-15), including the Application.DarkMode property, but both project-creation templates still set App.DarkMode = True in their main-file bootstrap -- so every newly created Windows Application project (and any form added from Templates/Files/Form.frm)...
  *Templates · 2 files*
- **`2a515c9`** — AI templates: default FreeBASIC/Astoria rules + skills set across all five tools
  Replaces the per-tool starter scaffolds with a complete, owner-verified default set.
  *Templates · 16 files*
- **`2a82e60`** — PROJECT_STATUS: AI templates complete; record the template DarkMode regression and Examples follow-up
  *Docs · 1 file*
- **`51bd45a`** — Examples: remove dead dark-mode code left by the framework's dark-mode removal
  Dark mode was stripped from the MFF framework on 2026-07-15, but Examples/ was never swept (its build audit predates the removal), leaving 76 files referencing the deleted App.DarkMode property -- every one failed to compile with "error 18: Element not defined, DarkMode".
  *Examples · 83 files*
- **`71e1b16`** — PROJECT_STATUS: Examples dark-mode sweep complete (51bd45a)
  *Docs · 1 file*
- **`c5d8a82`** — Settings: scrub test-project references from astoria.ini
  All seven local Test* projects from the 2026-07-16 New Project verification runs are deleted; blank the Recent file/project keys (the previously committed values pointed at an already-removed Projects\test too) and drop the Test* MRU entries.
  *Settings · 1 file*
- **`fdb515e`** — Add native Codex FreeBASIC skills
  *Docs, Templates · 23 files*
- **`95f81e9`** — Add Cursor-native AI project skills matching the Codex skill set
  *Docs, Templates · 18 files*
- **`708a15c`** — Add native OpenCode FreeBASIC skills matching the Cursor/Codex/Kun set
  - Create .opencode/skills/ with 13 SKILL.md files (5 shared playbooks + 8 extended skills: add-resource, audit-project-manifest, debug-freebasic-app, edit-form-safely, find-framework-control, prepare-release, refactor-freebasic, winapi-interop) - Update opencode.json with skills.paths referencing...
  *Templates · 15 files*
- **`08ba401`** — AI templates: bring Claude Code to the shared 13-skill set; add Kun skills
  The other agents (Codex/Cursor/OpenCode/Kun) fleshed out their template folders to a common 13-skill set.
  *Templates · 23 files*
- **`c2850f0`** — PROJECT_STATUS: reflect Claude Code 13-skill parity + Kun/OpenCode skills
  The "AI template folders — complete" section lagged the 08ba401 parity work: - ClaudeCode listed at 5 skills -> now 13. - Kun's 13 native .kun/skills/ noted (had been left untracked). - OpenCode's 13 .opencode/skills/ noted (was understated as "via opencode.json").
  *Docs · 1 file*
- **`1fc1a7d`** — Add Agent MCP Server spec (MCP_SERVER_PLAN.md)
  Design spec + implementation plan for letting an AI agent drive the live IDE via MCP (owner-chosen direction).
  *Docs · 2 files*
- **`2d833f4`** — Remove the Documentation/ folder (redundant FreeBASIC HTML reference)
  Documentation/ held 1092 loose HTML pages (~15MB) of the FreeBASIC language reference.
  *Build/Tools, Docs · 1093 files*
- **`35bde89`** — Document Documentation/ folder removal in PROJECT_STATUS + CHANGELOG
  Records the 2d833f4 removal of the redundant 1092-file FreeBASIC HTML reference (duplicated Help/FB-manual-en_US-1.10.1.chm), with the post-removal staging re-verification (3,771 files, 302 MB, folder absent, Help CHM intact).
  *Docs · 2 files*
- **`b33a2f9`** — Main-menu Code/Form restructure (WIP checkpoint for handoff)
  Owner-requested: put the code-pane and form-pane right-click commands on the main menu bar.
  *Docs, Framework/Controls, IDE · 4 files*
- **`f3538e1`** — Code/Form menus: contextual greying by file, view, and focused pane; right-click debug-op parity
  Completes the main-menu Code/Form restructure's two open UX items (owner decisions + all seven verification tests passed live):
  *IDE · 3 files*
- **`d0a9a6b`** — PROJECT_STATUS: Code/Form menu restructure complete (f3538e1)
  *Docs · 1 file*
- **`6aa6961`** — View selector: icon buttons docked below the viewport; fix TabControl capture breaking button-style tabs
  The per-document Code+Form/Code/Form view strip rendered as flat buttons -- bare grey-on-grey text visually adrift from the viewport it controls (owner report).
  *Framework/Controls, IDE · 4 files*
- **`9b45068`** — Docs: view-selector restyle handoff; teachers/educators recorded as target audience (ROADMAP 13.13)
  *Docs · 2 files*
- **`6799e6f`** — MCP Task 0: Agent pipe + UI-thread dispatch skeleton (ping)
  First step of MCP_SERVER_PLAN.md -- the named-pipe server inside astoria.exe (Layer C/D) that the future astoria-mcp sidecar will drive, proving the hardest part (cross-thread marshaling) in isolation with a trivial ping.
  *IDE · 8 files*
- **`04a9c4c`** — MCP Task 1: read-only pipe commands (get_status, list_files, read_file, get_active_file, get_build_output)
  Grows the UI-thread dispatch with the five read-only tools from MCP_SERVER_PLAN.md section 3 -- no mutation, no async, safe surface to validate the round-trip.
  *IDE · 2 files*
- **`8ad6f61`** — MCP Task 2: astoria-mcp.exe sidecar (JSON-RPC 2.0 / MCP over stdio)
  The MCP sidecar (Layer A of MCP_SERVER_PLAN.md) -- a FreeBASIC console app that speaks MCP to a client (Claude Code/Desktop) over stdio and forwards each tools/call to the running IDE over the \.\pipe\AstoriaAgent pipe.
  *Build/Tools, IDE · 4 files*
- **`8293bd9`** — MCP Task 3: file & editor mutation commands (write_file, add_file, set_active_file_content, open_in_editor)
  Adds the four mutating tools from MCP_SERVER_PLAN.md section 3, all guarded by the project-root path check (AgentResolveProjectPath) so nothing writes or opens outside the open project.
  *IDE · 5 files*
- **`730b3f4`** — MCP Task 4: build / syntax_check / run / get_errors with async build and console-output capture
  Closes the agent feedback loop (write -> build -> read errors -> fix -> run -> read output).
  *IDE · 4 files*
- **`438404e`** — MCP Task 5: headless project ops (create_project, open_project) + fix pipe start blocked by startup modal
  Two project-level tools (15 total), and a fix to when the agent pipe starts.
  *IDE · 6 files*
- **`d90d621`** — Docs: Agent MCP Server handoff — Tasks 0–5 done, 6–7 remain
  MCP_SERVER_PLAN.md status updated with a per-task "Implementation progress" section (commits, files, key decisions, the 15-tool surface, the INI gate, and what Tasks 6–7 still need).
  *Docs · 2 files*

## 2026-07-17

- **`83426ef`** — MCP Task 6: Options opt-in toggle (default on), status-bar indicator, sidecar auto-launch, packaging + docs
  Makes the Agent MCP server user-controllable and shippable.
  *Build/Tools, Docs, IDE · 12 files*
- **`b70143c`** — AI templates: add MCP (use-astoria-mcp skill + per-tool server config) to all five
  Now that Astoria is an MCP server, teach the stamped project templates to use it.
  *Docs, Templates · 21 files*
- **`dc11415`** — PROJECT_STATUS: end-of-night handoff -- MCP Task 6 + AI-template MCP done, Task 7 queued
  Sets "Next ready work" to Task 7 (drive the MCP loop from a real client) and records that the five AI templates gained MCP support (for the owning agents to verify).
  *Docs · 1 file*
- **`b5e6ae8`** — MCP Task 7: end-to-end verified; fix editor-driven agent loop (+ IDE-wide BOM bug)
  Drove the full MCP loop from a real stdio JSON-RPC client (the contract Claude Desktop/Code use), both via write_file and via set_active_file_content: create_project (auto-launch) -> edit broken primes -> build (fails: Variable not declared, total) -> get_errors -> fix -> build -> run -> "Primes...
  *Docs, IDE, Templates · 9 files*
- **`e41ce94`** — Fix Console Application template: declare DebugWindowHandle in NoInterface.bi
  mff/NoInterface.bi (included by console/no-GUI programs, e.g. the Console Application project template) used DebugWindowHandle in its Debug.Print routines but never declared it -- only Application.bas (the GUI path) did.
  *Docs, Framework/Controls · 3 files*
- **`026e417`** — Console template: proper hello-world starter with a headless-safe pause
  Replace the bare colours+title stub (which printed nothing and used a stale "VisualFBEditor" title) with a real starter: sets the window title, prints a green "Hello, world!" plus a short hint, and pauses so the window stays open.
  *Templates · 1 file*
- **`1642db0`** — MCP run: harden stdout capture against NUL truncation
  `run` returned only the first character of a program's stdout when the output contained NUL bytes -- the common trigger being a BOM'd FB source, which makes Print emit UTF-16LE (null-interleaved) wide text (e.g. "Primes..." came back as "P").
  *Docs, IDE · 2 files*
- **`a11d260`** — MCP: don't block the IDE with startup modals on agent auto-launch; don't hang run on a GUI target
  Two GUI-project bugs found while exercising the MCP link end-to-end.
  *Framework/Controls, IDE · 6 files*
- **`72ea598`** — MCP create_project: mark AI-friendly and stamp the creating agent's AI template
  An agent-created project now carries the same AI scaffolding as the New Project dialog's "Make project AI friendly" -- so whichever assistant created it lands in a project already set up for it.
  *IDE · 4 files*
- **`c713f13`** — Don't block startup with a "File not found" modal when a workspace file was deleted
  Reopening the last workspace after a referenced project or tab file was deleted or moved (e.g. an agent-created test project cleaned up between sessions) popped a modal "File not found" dialog on startup that blocked the main window until dismissed.
  *IDE · 4 files*
- **`5ff2dce`** — New Project dialog: template dropdown as a matching field row; add project.astoria description-file module
  Two things toward the New Project rework:
  *IDE · 8 files*
- **`8010c24`** — New Project: two-mode redesign (Create Local / Use Existing Git) + write project.astoria (WIP, owner testing)
  Task 1 of the project-creation redesign (owner-confirmed design).
  *Docs, IDE · 6 files*
- **`fc9fc8a`** — New Project: Edit Project Description menu + clearer clone refusal
  Task 2 of the two-mode redesign, plus a message tidy in the clone flow.
  *IDE · 5 files*
- **`c1c4374`** — PROJECT_STATUS: Task 2 (Edit Project Description) done; note main-tree build/run gotcha
  *Docs · 1 file*
- **`fcf2b67`** — AI templates (ClaudeCode): add git-workflow skill + document project.astoria
  Git and MCP are now features, but the ClaudeCode template never mentioned project.astoria and had no git guidance.
  *Templates · 3 files*
- **`a34dc2f`** — New Project: populate AI Agent dropdown from Templates/AI subfolders
  The AI Agent dropdown was a hardcoded list with a label->folder map.
  *IDE · 1 file*
- **`386eb86`** — PROJECT_STATUS: queue Tasks 4 & 5 (git onboarding automation) after Task 3
  SSH key setup + empty remote-repo creation, with the feasibility conclusions (CLI/API over browser automation; one unavoidable provider auth; gh/glab GitHub-first, assisted-browser fallback).
  *Docs · 1 file*
- **`ef5a625`** — PROJECT_STATUS: document AI Agent dropdown (data-driven) + ClaudeCode template git/MCP updates
  *Docs · 1 file*
- **`d61eb06`** — Add top-level Git menu (Git Pull / Git Push) between Run and Tools
  A dedicated Git menu for git-backed projects, room to grow.
  *IDE · 4 files*
- **`fffee48`** — Git menu: add Git Commit with a message prompt
  Git Commit prompts for a message (framework InputBox), then runs git add -A + git commit -F <tempfile> in the open project folder via RunGitInProject.
  *IDE · 4 files*
- **`1efc161`** — Git Commit: themed message dialog + fix BOM in commit-message file
  Two fixes on the Git Commit item: - The commit message file was written with Open ...
  *IDE · 3 files*
- **`0fec0c5`** — Git menu: plain-English result summaries for Commit/Pull/Push
  Replaced the raw git-output dump in the result boxes with a short readable summary via ShowGitResult: commit -> "Committed to <branch> as <hash>" + the message + change line; pull -> "Pulled changes" / "Already up to date"; push -> "Pushed your commits" / "Nothing to push".
  *IDE · 1 file*
- **`60da4ee`** — Git Commit: show the files that will be committed; ignore Temp.bas scratch
  - The Git Commit dialog now lists what git add -A will stage (git status --porcelain, formatted as modified/new/deleted/renamed), in a read-only box above the message -- so a scratch file being swept in is visible, not a surprise.
  *IDE, Templates · 4 files*
- **`415e2e9`** — PROJECT_STATUS: Git menu (Task 3) done; register frmGitCommit in .vfp
  *Docs, IDE · 2 files*
- **`fd89417`** — Git menu: Set Up SSH Key (Task 4, slice 1)
  New Git menu item (in a setup group below Commit/Pull/Push).
  *IDE · 3 files*
- **`0ef786a`** — PROJECT_STATUS: Task 4 slice 1 (Set Up SSH Key) done
  *Docs · 1 file*
- **`a28ad9e`** — Task 4 complete: gh/glab SSH-key auto-add + wire setup into New Project
  - SetupSshKey (refactored out of GitSetupSshKey, now public) tries the provider CLI first: if gh (GitHub) / glab (GitLab) is installed AND authenticated (`<cli> auth status` exit 0), it offers to add the key directly via `<cli> ssh-key add`; on decline or failure it falls back to the...
  *IDE · 3 files*
- **`92c2a54`** — PROJECT_STATUS: Task 4 complete (SSH key setup: gh/glab auto-add + New Project wiring)
  *Docs · 1 file*
- **`95b04f7`** — Task 5: Create Remote Repository (Git menu item + New Project preflight)
  New Git menu item "Create Remote Repository" (setup group, next to Set Up SSH Key) and a New-Project preflight:
  *IDE · 4 files*
- **`7b7b435`** — New Project: rename 'Use Existing Git Project' radio to 'Git Project' (it now creates the repo if missing)
  *IDE · 1 file*
- **`7e490d8`** — PROJECT_STATUS: Task 5 done + Git Project rename; Tasks 1-5 all built
  *Docs · 1 file*
- **`76c13ae`** — New Project: GitHub-only provider shown as a static bold label
  The four-provider dropdown is retired (GitLab/Bitbucket/Codeberg lag on the CLI automation). cboGitProvider is hidden/inert; a bold 'GitHub' label sits where the dropdown was, left-justified with its left edge, keeping the 'Git Provider:' caption.
  *IDE · 2 files*
- **`0313fda`** — PROJECT_STATUS: note GitHub-only provider (dropdown retired for now)
  *Docs · 1 file*
- **`c104169`** — New Project: 'Main' startup convention; drop Form/Module name fields
  Every template's startup file is now named Main -- Main.frm for a GUI Windows Application (with its class/instance/.rc renamed Form1->Main), Main.bas for the Console/Library templates (UserControl1->Main); each template .vfp updated.
  *IDE, Templates · 11 files*
- **`d4d775f`** — Edit Project Description: structured dialog (Part B)
  Replaces the raw-text open with frmEditProjectDescription: a read-only block (Project Name / Template / Mode / Startup Main.frm|Main.bas / Created / Git remote) plus editable Author, License, Description, and Make-AI-friendly + AI Tool.
  *IDE · 5 files*
- **`5d1f3a7`** — PROJECT_STATUS: 'Main' startup convention + Edit Project Description dialog
  *Docs · 1 file*
- **`b3689ac`** — Options Personal Information redesign + Git identity plumbing; fix missing-INI and stale-recent-project bugs
  Tools > Options > Personal Information: - Licenses in three columns (two rows of three, Other + field on a third row).
  *Docs, IDE · 9 files*
- **`29fa4d5`** — Seed a missing astoria.ini from a defaults template; drop the dead [Debuggers] section
  The empty Tools > Options terminal dropdown was a regression from the earlier missing-INI fix, not a UI bug.
  *Docs, IDE, Settings · 6 files*

## 2026-07-18

- **`92a6c24`** — Built-in terminal list, working menu icons, and help/page cleanup
  Terminals are now built in and not user-editable: the list lives in SeedBuiltInTerminals() rather than indexed [Terminals] keys, and offers only the consoles Windows ships -- Standard Windows Console, Command Prompt, Windows PowerShell, and the newly added Windows Terminal.
  *Docs, IDE, Settings · 11 files*
- **`e4ef524`** — Project3 test bench: drop the UTF-8 BOM from Module1.bas
  A BOM'd FreeBASIC source makes Print emit wide (null-interleaved) characters -- the exact trigger for the run-output bug fixed earlier.
  *Examples · 1 file*
- **`9111017`** — Control testing: per-control test programs, results doc, and two library fixes
  Adds Documentation/ControlTesting.md - a status table for all 74 toolbox elements (Name, Visual, Compiled, Tested, Verified, Notes) - plus the 73 generated test projects under Examples/Controls/, one Windows Application per control containing exactly that control.
  *Build/Tools, Docs, Examples, Framework/Controls · 296 files*
- **`0986f18`** — Ship libmariadb.dll; correct two control-test results that were false passes
  MariaDBBox linked but would not start: the repo carried only the link-time libmariadb.lib / libmariadbclient.a (plus a stray .pdb), never the runtime libmariadb.dll.
  *Build/Tools, Docs, Framework/Controls · 3 files*
- **`c5c7c2f`** — ControlTesting: mark the four retested controls owner-verified
  TabPage, Menu, MariaDBBox and SQLite3Component were rerun after the owner's review pass, so their Verified column was held at `-`.
  *Docs · 1 file*
- **`a100adf`** — Copy a control library's runtime DLLs beside the exe on build
  A program using ScintillaControl or MariaDBBox built successfully and then refused to start anywhere the DLLs were not already adjacent - which is every machine except the one that built it.
  *Docs, Framework/Controls, IDE · 6 files*
- **`1635bc4`** — Re-enable WebBrowser, show Cursor once, and document controls and framework
  Four related changes, all from auditing what the toolbox does and does not show.
  *Docs, Examples, Framework/Controls, IDE · 9 files*
- **`cb66e26`** — Docs: record Astoria's changes, drop cross-platform noise, credit upstream
  Three revisions across the documentation set.
  *Docs · 3 files*
- **`0c71690`** — Declare 1.0 feature complete; add tester-facing documentation set
  Preparation for recruiting human testers.
  *Docs · 4 files*
- **`acea2cc`** — StageRelease: ship Documentation, and stop shipping Examples build output
  Documentation/ was excluded by omission, with a comment explaining why.
  *Build/Tools · 1 file*
- **`d4e36d1`** — StageRelease: export from git archive; release binaries and 1.0 handoff
  Staging now exports `git archive HEAD` into a scratch tree and copies from that, so a file that is not committed cannot ship.
  *Build/Tools, Docs, IDE, Settings · 5 files*
- **`2a16812`** — Stop tracking the live settings file; ship defaults via astoria.default.ini
  Settings/astoria.ini is the per-user settings file: every run rewrites window geometry and MRU lists into it, and [PersonalInfo] now holds a name, e-mail and Git login.
  *Build/Tools, Docs, Settings · 4 files*
- **`8ecfc9f`** — Add a maintained test plan covering multi-component and in-depth scenarios
  Testing.md records what has been tested; this is the forward-looking companion listing what should be, as named scenarios with a result recorded against each.
  *Docs · 2 files*
- **`e0873d9`** — Run TestPlan A1 and A4: SQLite3 data path proven, WebBrowser found broken
  A1 -- SQLite3Component data path: PASS, 26/26.
  *Build/Tools, Docs, Examples, Framework/Controls · 9 files*
- **`e91ff88`** — WebBrowser: replace the dead IE backend with WebView2, and make it the default
  TestPlan A4 found the WebBrowser control could not render a page and crashed the program on Navigate.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE · 15 files*
- **`0c1375d`** — Significant changes: add the no-broken-features rule and the Windows installer
  Two owner-requested additions to Section 1.
  *Docs · 1 file*
- **`15bab4f`** — ROADMAP: record the upstream framework backport review and reference-doc adaptation
  Two owner-added items, recorded here because the session task list does not survive a session.
  *Docs · 1 file*
- **`97a590d`** — Run TestPlan A5: WebBrowser navigation and history pass
  4/4.
  *Docs, Examples · 3 files*
- **`02d263d`** — Run TestPlan B1, B4, B6 and B10: multi-control integration passes
  First real coverage of controls cooperating rather than each opening alone.
  *Build/Tools, Docs, Examples · 7 files*
- **`7cddbb4`** — PROJECT_STATUS: record the integration-testing session and where to resume
  Handoff entry for 2026-07-18 afternoon.
  *Docs · 1 file*
- **`80e7804`** — Convert B1, B4 and B6 to self-driving, and run B7 (shared ImageList)
  The three externally-driven tests parked a window on the tester's desktop for as long as the driving script ran -- unacceptable for a suite meant to be re-run every release.
  *Build/Tools, Docs, Examples · 7 files*
- **`e764153`** — Run TestPlan B13 and B3, and give the whole integration suite a manifest
  B13 -- 26 different control types on one form: 7/7.
  *Build/Tools, Docs, Examples · 19 files*
- **`8e7b39b`** — Run TestPlan B11 and B12: database-to-view and browser composite pass
  B11 -- SQLite3 query results into a ListView: 13/13.
  *Build/Tools, Docs, Examples · 10 files*
- **`a7aee72`** — Run TestPlan B2, B5, B8 and B9 -- Section B complete, and fix a framework shift-key bug
  All thirteen multi-component scenarios now pass.
  *Build/Tools, Docs, Examples, Framework/Controls, IDE · 23 files*
- **`d72cf7d`** — Run TestPlan A7: property and event depth on the seven common controls
  50/50 across TextBox, ComboBoxEdit, ListView, TreeView, CheckBox, RadioButton and CommandButton.
  *Build/Tools, Docs, Examples · 6 files*
- **`2518520`** — Run TestPlan A2: SQLite3Component error handling
  20/20.
  *Build/Tools, Docs, Examples · 4 files*
- **`b02a4bc`** — Fix the modifier-key mask across Astoria's own source, and record C2 as partial
  TestPlan B2 found the framework testing GetKeyState(VK_SHIFT) And 8000 -- decimal 8000 is &h1F40 and shares no bits with the &h8000 key-down flag.
  *Docs, Framework/Controls, IDE · 10 files*
- **`a428121`** — Preserve a file's encoding and line endings on save; TestPlan C2 passes
  C2 asked whether a designer edit round-trips without disturbing the rest of the file.
  *Docs, IDE · 5 files*
- **`375eb91`** — Revert the encoding change: BOM-less normalisation on save is deliberate policy
  a428121 treated the IDE's BOM stripping as a fidelity defect and made saving preserve whatever encoding a file arrived with.
  *Docs, IDE · 5 files*
- **`d38c6a9`** — ROADMAP: record the optional BOM normalisation pass as 13.16
  Measured while answering whether anything deviates from the BOM-less UTF-8 rule.
  *Docs · 1 file*
- **`4b758ea`** — Run TestPlan C1: designer place-and-wire end to end passes
  Owner started from an empty Windows Application form, placed a TextBox, CommandButton and Label, set properties in the property grid, wired a click handler with a line of code, then built and ran it.
  *Docs · 2 files*
- **`127a52a`** — Run TestPlan C3: renaming a control breaks the build; record as ROADMAP 13.17
  C3 asked whether renaming a control leaves handlers bound and the project building.
  *Docs · 2 files*
- **`0d20163`** — Classify designer rename refactoring as required for 1.0 (owner decision)
  ROADMAP 13.17 was recorded as a deferred enhancement on the grounds that the failure is discoverable rather than silent.
  *Docs · 2 files*
- **`bde3984`** — ROADMAP 13.18: modal from the activation handler can hang the IDE, mandatory before 1.0 beta
  Owner hit this during C4 setup: the IDE would not respond to clicks, could not be closed, and had to be killed from Task Manager, with no dialog visible and no error.
  *Docs · 1 file*
- **`9cc0f7e`** — Run TestPlan C4: align and size pass, designer has no undo (ROADMAP 13.19)
  Owner scattered four labels, multi-selected them, and applied Align Left then Make Same Size.
  *Docs · 2 files*
- **`623aa2a`** — Add designer Undo/Redo (UNBUILT, UNTESTED) and write the session handoff
  WARNING: src/AstoriaIDE.bas carries a designer Undo/Redo implementation that has never been compiled or run.
  *IDE · 1 file*
- **`1eb56be`** — PROJECT_STATUS: add the session handoff that 623aa2a's message claimed
  The previous commit's message described a handoff entry, but the script that should have written it failed on a string-escape error and only the source change was committed.
  *Docs · 1 file*
- **`1c00c1f`** — Split the Code and Form menus, add a never-greyed Code/Form menu
  Ctrl+Z, Ctrl+Y and the clipboard shortcuts now work on the form designer.
  *Docs, IDE · 8 files*
- **`f84d52d`** — DetailedChangelog: regenerate through 1c00c1f
  Was 32 commits stale, ending at cb66e26 - it predated the other machine's WebView2 and TestPlan work as well as today's menu restructure.
  *Docs · 1 file*
- **`5736988`** — TestPlan C6 passes: split-view menus track the focused pane
  Verified by sampling Windows' top-level menu state four times a second and logging transitions, rather than by eye.
  *Docs · 1 file*
- **`7aba862`** — TestPlan C5 passes: cross-form paste resolves name collisions
  Adds Examples/Integration/C5_CopyPaste, a fixture built to force the failure rather than hope for it: FormA carries lblShared/txtNotes/btnGo and FormB carries its own lblShared, so pasting FormA's group into FormB guarantees a duplicate name.
  *Docs, Examples · 7 files*
- **`aec71cf`** — Documentation: fold C5/C6 into Testing, regenerate the changelog
  Testing.md now records the state of the form designer rather than a single fix: TestPlan C1-C6 are complete except C3, and C3's failure (renaming a control breaks the build, ROADMAP 13.17) is named as the one defect the section found.
  *Docs · 2 files*
- **`5872357`** — Docs: reconcile WebBrowser across the reference docs
  Testing.md and TestPlan.md already recorded the WebView2 work, but the two user-facing references still described the control as it was before it: as "re-enabled" with a one-line compile fix and rendering unproven.
  *Docs · 3 files*
- **`2168e93`** — C5 fixture: keep the .vfp as the IDE writes it
  The C5_CopyPaste project file was generated by script, then rewritten by the IDE when the project was saved during the test - it adds a BOM and normalises the key set.
  *Examples · 1 file*
- **`22c60b1`** — Add the rule: update the reference docs after every test
  A test is finished when the documents say what is now known, not when it passes.
  *Docs · 2 files*
- **`9c86531`** — TestPlan A6 passes: ScintillaControl edits, undoes and styles correctly
  8/8 assertions.
  *Docs, Examples · 7 files*
- **`d9c3193`** — A6 gets a project file; document what the Integration fixtures do not cover
  A6_ScintillaEditing now has a .vfp and is verified both ways.
  *Docs, Examples, IDE · 4 files*
- **`e235059`** — Astoria is a project-based build system, not an editor; session handoff
  States plainly in the user-facing document what this session established by accident: there is no way to open a loose source file and work on it.
  *Docs, IDE · 4 files*
- **`9aa11e2`** — A3 fixture: MariaDBBox against a real server, credentials from the environment
  Prepares TestPlan A3, the last unproven data path.
  *Examples · 2 files*
- **`cc23967`** — A3 setup: keep the real DB password out of the tracked file
  The setup script shipped with a CHANGE_ME placeholder and told the owner to edit it in place.
  *Build/Tools, Examples · 2 files*
- **`b1819b1`** — TestPlan A3 passes: MariaDBBox data path works, four defects confirmed
  Run against MariaDB 10.6.8.
  *Docs, Examples, IDE · 6 files*
- **`1f1864c`** — Fix all four MariaDBBox defects found by TestPlan A3
  A3 now passes 34/34 against MariaDB 10.6.8, up from 24 passing with 4 defects recorded.
  *Docs, Examples, Framework/Controls · 7 files*
- **`8ecf02b`** — DetailedChangelog: fold in the five commits through 1f1864c
  *Docs · 1 file*
- **`fc9ebc9`** — Fix C3: rename a control and its references follow (ROADMAP 13.17)
  The 1.0 blocker.
  *Examples, IDE · 5 files*
- **`9b813de`** — TestPlan C3 passes: the last 1.0 blocker is closed
  Owner re-ran the designer rename against the fixed IDE.
  *Docs · 3 files*
- **`35a5305`** — Fix 13.18: never raise a modal from the app-activation handler
  Clicking the IDE to focus it could raise a modal "file changed, reload?" dialog from inside frmMain_ActivateApp.
  *Docs, IDE · 5 files*
- **`cd08ffb`** — Fix a crash I introduced in the 13.18 reload prompt, and instrument the detection
  Owner hit two problems with the first 13.18 fix.
  *Examples, IDE · 5 files*

## 2026-07-19

- **`36cacd8`** — Fix the 13.18 prompt listing two files as one, and record the cause as 13.22
  The batching worked from the first run.
  *Docs, Examples, IDE · 6 files*
- **`6d685d3`** — ROADMAP 13.18 resolved, owner-confirmed: no known 1.0 beta blockers remain
  With two files changed on disk in one project, activation raises a single dialog naming the shared folder once and listing both files distinctly, the IDE stays responsive, and accepting reloads both without incident.
  *Docs, Examples · 4 files*
- **`b207443`** — Claude template: add the three rules this session's defects would have prevented
  Only Templates/AI/ClaudeCode, per owner instruction; it is the master copy the other AI templates are derived from.
  *Templates · 3 files*
- **`ef63898`** — Claude template: add testing discipline
  Verify by effect rather than return value; make the assertion as strong as the claim; measure before theorising.
  *Templates · 2 files*
- **`b69a0d0`** — Documentation current, session handoff, and a CLAUDE.md for the IDE itself
  Adds a repository-root CLAUDE.md.
  *Docs · 4 files*
- **`b788865`** — TestPlan D1 passes: console app lifecycle, 12/12
  Create from the Console Application template, edit, build, run, read the output back, switch away to another project, reopen, confirm the edit survived, and rebuild.
  *Build/Tools, Docs, IDE · 7 files*
- **`08eaece`** — Drop the gh/glab CLI dependency; Git setup steps use the browser
  Owner decision: if someone is running Astoria, a browser is available, so a command-line tool is not worth depending on.
  *Docs, IDE · 6 files*
- **`2077c81`** — ROADMAP 13.23: document how to set up Git for use with Astoria
  Raised by the owner while testing.
  *Docs · 3 files*
- **`50b055e`** — TestPlan D2 passes; record the Temp.bas artefact as 13.24
  Windows app lifecycle through the designer: create from the default template, place a Label, TextBox and CommandButton, set properties, wire the button's Click, build, run, close, reopen.
  *Docs · 4 files*
- **`be3b611`** — TestPlan: D3 tested the wrong premise; a local project is not a Git repo
  D3 read "Git: local project - create local, add files, commit and push".
  *Docs · 2 files*
- **`01d0c22`** — ROADMAP 13.25-13.27: first-start dialog, local-to-Git conversion, panel focus
  Three tasks raised by the owner while testing.
  *Docs · 3 files*
- **`79a2c10`** — Session handoff: D1/D2 pass, gh removed, four tasks recorded
  Documents the session and tidies two things the testing left behind.
  *Build/Tools, Docs · 3 files*
- **`b5bf467`** — Upgrade Cursor AI template to ClaudeCode parity
  *Docs, Templates · 8 files*
- **`0b42427`** — ChatGPT template: align skills and safety rules
  *Templates · 10 files*
- **`de8c1e5`** — Update OpenCode template to ClaudeCode parity: MCP + git-workflow + new rules
  - Add .mcp.json for Astoria MCP server integration - Add use-astoria-mcp skill (drive IDE via MCP: build, run, edit files) - Add git-workflow skill (commit/push via project.astoria) - Update AGENTS.md with: UTF-8 NO BOM rule, Str() gotcha, ReDim Preserve danger, project.astoria, MCP-first editing...
  *Templates · 4 files*
- **`11a9fb1`** — Sync Kun AI templates with ClaudeCode: add AGENTS.md sections (BOM warning, Str/ReDim pitfalls, project.astoria, testing discipline, git-workflow, MCP editing), update SKILL.md to match CLAUDE.md scope, add git-workflow skill and .mcp.json
  *Templates · 2 files*
- **`3e2c6cc`** — Add Kimi AI templates mirror
  *Templates · 19 files*
- **`6ebf35c`** — TestPlan D3 passes Git-backed workflow
  *Docs · 2 files*
- **`be8c169`** — Fix MCP multi-file consistency and pass D5
  *Build/Tools, Docs, IDE · 6 files*
- **`5f0f84c`** — Kun template: align skills and safety rules
  *Templates · 2 files*
- **`4840947`** — Mark native dialog return-value test complete
  *Docs, Examples · 5 files*
- **`c838493`** — Fix settings recovery and multi-form debugging
  *Build/Tools, Docs, Examples, IDE · 16 files*
- **`6f1dcee`** — Verify clean install and remove framework warnings
  *Docs, Framework/Controls, IDE · 9 files*
- **`46078e6`** — Revert warning cleanup that broke startup
  *Docs, Framework/Controls, IDE · 7 files*
- **`4d7499b`** — Tidy test artefacts: complete the A8 fixture, ignore generated output
  Three separate things the recent test runs left in the tree.
  *Build/Tools, Docs, Examples · 5 files*
- **`205d0ea`** — Remove every compiler warning from user builds and from the IDE's own
  A user building any project saw six framework warnings; building the DeviceExplorer example added two more.
  *Docs, Examples, Framework/Controls, IDE · 8 files*
- **`3f26136`** — Rebuild framework.dll so the shipped binary matches its source
  The previous commit fixed warnings in Control.bas and Application.bas but left the committed DLL as it was, on the reasoning that default arguments are resolved in the caller from the .bi declarations and so the binary could not change.
  *Framework/Controls · 1 file*
- **`e66d153`** — Handoff: warnings removed, and why the earlier attempt broke startup
  Documents the session and closes an open question.
  *Docs · 2 files*
- **`0d6c6be`** — 13.27: the IDE no longer chooses the left panel for you
  ApplyView ended both the "Form" and "CodeAndForm" branches with an unconditional tpToolbox->SelectTab, so every application of a form view dragged the left panel to the Toolbox -- including re-applications the user never asked for.
  *Docs, IDE · 5 files*
- **`0086f1a`** — Enforce CRLF project-wide instead of freezing it, and re-sweep 374 files
  The T01 sweeps (2f445e4, 4795d9b, 6682da9) established CRLF across src/, Controls/ and Examples/, and added scoped `-crlf` .gitattributes rules so the conversion would survive core.autocrlf=true.
  *Build/Tools, Examples, Framework/Controls, IDE · 374 files*
- **`3c9dc6b`** — 13.27 owner-verified; ship the binary that was tested
  Rebuilt at 21:27 and verified by the owner: startup lands on Project, New Project selects Project, saving / adding a file / switching views no longer move the panel, and View > Toolbox still works.
  *Docs, IDE · 2 files*
- **`a4c3369`** — PROJECT_STATUS: the handoff the previous session did not get to write
  Records 13.27 as owner-verified, the 256-file line-ending drift and the switch from freezing CRLF to enforcing it, and two method notes: git will not surface EOL drift under `text` because it normalises the working tree to LF for comparison, and a piped build exit code reports the pipe's success...
  *Docs · 1 file*
- **`21d60d1`** — Commit the MCP sidecar from the same build as astoria.exe
  3c9dc6b shipped astoria.exe from the 21:27 build and left astoria-mcp.exe, built in the same pass, sitting uncommitted -- reintroducing the binary/source mismatch 3f26136 existed to close.
  *IDE · 1 file*
- **`03e1209`** — Ignore local test artefacts and regenerate the changelog
  Throwaway New Project fixtures from the 13.27 verification, built binaries inside the tracked Projects/ fixtures (the existing `Projects/*.exe` rule only matched the top level, so a build inside Projects/Project3/ escaped it), and the suffixed debugger traces alongside the already-ignored...
  *Build/Tools, Docs · 2 files*
- **`2567952`** — Add the changelog generator the documentation already assumed existed
  DetailedChangelog.md has always described itself as generated from commit messages, and CLAUDE.md told contributors to "regenerate rather than hand-edit" -- but no generator existed, so every entry was appended by hand.
  *Build/Tools, Docs · 3 files*
- **`9369086`** — TestPlan E9 fails: the IDE cannot be operated by keyboard alone
  Build and run are fully reachable from the keyboard and the menu bar is properly keyboard-driven -- Alt+F opens File, mnemonics are underlined, arrows walk between menus.
  *Docs · 3 files*
- **`925553d`** — DetailedChangelog: regenerate through 9369086
  *Docs · 1 file*
- **`18d3325`** — TestPlan E11 passes, and fix the crash it found on a second launch
  E11 asked what happens when two Astoria processes run at once.
  *Build/Tools, Docs, IDE · 8 files*
- **`9429448`** — DetailedChangelog: regenerate through 18d3325
  Picks up the E11 result and the 13.29 second-launch crash fix.
  *Docs · 1 file*
- **`ae1bb5a`** — E10a: the editor ignores high contrast; 13.29 owner-verified
  Splits E10 into E10a (high contrast) and E10b (screen reader).
  *Docs · 3 files*
- **`feb9a1c`** — DetailedChangelog: regenerate through ae1bb5a
  Picks up the E10a high-contrast result and ROADMAP 13.30.
  *Docs · 1 file*
- **`94d8cae`** — 13.30: the editor now follows the system high-contrast theme
  Astoria never called SPI_GETHIGHCONTRAST anywhere in src/.
  *Docs, IDE · 6 files*
- **`33f1317`** — DetailedChangelog: regenerate through 94d8cae
  Picks up the 13.30 high-contrast fix and the E10a pass.
  *Docs · 1 file*
- **`712c29b`** — UI: remove Tip of the Day, fix the toolbars to three rows, one Toolbars toggle
  Three owner-requested changes, made together because they touch the same startup and chrome code.
  *Build/Tools, Docs, IDE · 22 files*
- **`9ec16d0`** — DetailedChangelog: regenerate through 712c29b
  Picks up the Tip of the Day removal and the toolbar changes.
  *Docs · 1 file*

## 2026-07-20

- **`e8cad6f`** — E12: shortcut sweep harness, two real defects, rest deferred
  Tools > Options > General > Shortcuts advertises 54 assigned shortcuts.
  *Build/Tools, Docs · 7 files*
- **`7fc0f09`** — DetailedChangelog: regenerate through e8cad6f
  Picks up the E12 shortcut sweep and ROADMAP 13.32-13.34.
  *Docs · 1 file*
- **`4ff9dd8`** — Fix both shortcut defects E12 found (13.32, 13.33)
  13.32 -- Ctrl+Shift+O (Open Project) could never fire.
  *Docs, IDE, Settings · 6 files*
- **`4ed09fa`** — DetailedChangelog: regenerate through 4ff9dd8
  Picks up the 13.32/13.33 shortcut fixes.
  *Docs · 1 file*
- **`5318633`** — 13.28 part 1: a modal dialog can be used and closed from the keyboard
  E9 recorded the New Project dialog as taking no keyboard input at all -- no initial focus, Tab moving nothing, Escape not closing it, only Alt+F4 dismissing it.
  *Docs, Framework/Controls, IDE · 9 files*
- **`3cd3ea6`** — DetailedChangelog: regenerate through 5318633
  Picks up the 13.28 part 1 modal keyboard fix.
  *Docs · 1 file*
- **`58f3fbc`** — 13.28 part 2: the project tree can be reached and walked from the keyboard
  Ctrl+R ("Project Explorer") put the caret in the panel's search box, and Tab never carried focus on into the tree, so a keyboard-only user could reach the panel but never a file in it.
  *Docs, IDE · 5 files*
- **`0241bba`** — DetailedChangelog: regenerate through 58f3fbc
  Picks up 13.28 part 2, 13.36, and the 13.34 harness caveat.
  *Docs · 1 file*
- **`8b7d69e`** — PROJECT_STATUS: handoff for the Section E testing session
  Five defects found and fixed this session (13.29 second-launch crash, 13.30 high contrast, 13.32 and 13.33 dead shortcuts, 13.28 parts 1-2 keyboard access), plus 13.31 UI simplification, and two new ones recorded (13.35, 13.36).
  *Docs · 1 file*
- **`637f448`** — DetailedChangelog: regenerate through 8b7d69e
  Picks up the session handoff.
  *Docs · 1 file*
- **`824b24c`** — Shortcut integrity: fix 13.35 at the generator, and validate at startup
  Every shortcut defect found so far has been bad DATA rather than bad dispatch: a missing entry (13.32), blank duplicates shadowing a real binding (13.33), and an accelerator quietly eating a menu mnemonic.
  *IDE, Settings · 7 files*
- **`ec554be`** — Framework: gated diagnostics for the Alt+C/G/R defect (13.28 part 3)
  Three hypotheses formed by reading code had already been disproved, so these measure instead of proposing a fourth.
  *Framework/Controls · 2 files*
- **`5cc5417`** — 13.28 part 3: record the investigation, its harnesses, and the rebuilt binaries
  Alt+C, Alt+G and Alt+R still do not open their menus.
  *Build/Tools, Docs, Framework/Controls, IDE · 14 files*
- **`1624d0f`** — DetailedChangelog: regenerate through 5cc5417
  *Docs · 1 file*
- **`4dcd77a`** — 13.28 part 3: eliminate hypothesis 12 and the user-mode debugger route
  Two approaches closed off, neither of them the fix, both recorded so they are not retried.
  *Build/Tools, Docs · 4 files*
- **`d590ed3`** — DetailedChangelog: regenerate through 4dcd77a
  *Docs · 1 file*
- **`07d829c`** — 13.28 part 3: verify every kernel-debug prerequisite on the target
  Checked the setup requirements rather than assuming them, since the last two recommendations in this investigation both failed on unchecked premises.
  *Build/Tools, Docs · 2 files*
- **`0245a49`** — 13.28 part 3: target configured for kernel debugging, pending reboot
  kdnet.exe enabled network debugging on the Realtek GbE NIC.
  *Build/Tools · 1 file*
- **`b072609`** — 13.28 part 3: the defect reproduces on the second machine, silently
  The previous session's handoff asked for three keystrokes on the other computer, on the grounds that either answer would be progress.
  *Build/Tools, Docs · 3 files*
- **`a61a1d1`** — DetailedChangelog: regenerate through b072609
  Picks up the cross-machine confirmation for 13.28 part 3.
  *Docs · 1 file*
- **`3380be4`** — 13.28 pt 3: six more hypotheses eliminated, cause still unknown
  Not solved.
  *Build/Tools, Docs, IDE · 9 files*
