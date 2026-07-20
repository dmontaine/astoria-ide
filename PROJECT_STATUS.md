# Astoria-IDE — Project Status & Handoff

## Session handoff (2026-07-20, morning) — 13.28 pt 3: two approaches eliminated, kernel route prepared

**Machine switch in progress.** This session ran on the machine that reproduces the defect; work
continues from the second computer. **This machine is the intended kernel-debug TARGET and can be
used to run Astoria.** Nothing in `src/` or `Controls/` was changed — only harness files and
documentation. No rebuild happened; the binaries are still the 04:12–04:15 build from the previous
session.

### The one thing to do first, on the other computer — **ANSWERED 2026-07-20**

**It fails on the second computer too, and it fails silently.** The owner pressed `Alt+C`, `Alt+G`
and `Alt+R` on the other machine, running the same binary: no menu opens, and **no bell** — the
identical signature, not merely "no menu". The distinction was checked deliberately, because a beep
would have meant Windows entered menu mode and failed to match, which is ordinary
no-such-mnemonic behaviour and would have pointed somewhere else entirely.

**What this buys.** The defect is **not machine-local**: machine state, installed software, and any
per-machine input hook are ruled out for free. The twelve hypotheses were aimed at the right target
after all, and the kernel trace is worth its setup. It also means the failing set {C, G, R} is
reproducible on demand on either machine, so any future instrument can be developed wherever is
convenient and validated on both.

**What it does not settle.** Two machines sharing a Windows version and a similar configuration are
not proof that nothing environmental is involved — only that nothing *specific to one machine* is.
If the kernel trace comes back empty, "something common to both Windows installs" is still live and
a third machine, or a different Windows build, becomes the cheap next test rather than more
hypotheses.

**Original instruction, retained for the record:** Press `Alt+C`, `Alt+G`, `Alt+R` in Astoria there.
This has never been tried and it is worth more than any instrument built today. Works there → the
defect is machine-local and twelve hypotheses have been aimed at the wrong target. Fails on both →
it is in Astoria, machine state is ruled out for free, and the kernel trace is worth its setup.
Three keystrokes, either answer is progress.

### What was eliminated

| | Result |
| --- | --- |
| **Hypothesis 12** — a hidden/duplicate menu-bar item claiming C/G/R matches first and silently swallows the key | **Refuted.** Live dump: 11 items, each of C/G/R claimed exactly once, all enabled with populated popups (28/31/7). Position does not explain it either — failing indices 3, 6, 7; working 0, 1, 2, 8, 9, 10. |
| **A user-mode `cdb` trace of `user32`** | **Dead end, and the run is void** — it failed its own positive control. `Alt+E` produced no beep and `Alt+F` no menu signal, so the silence for C/G/R means nothing. Menu-mode handling lives in `win32kfull.sys`; the `user32!*Menu*` exports are the API entry points apps *call*, not the code that services a keystroke. |

The second one is a correction to a recommendation made earlier in the same session. Checking which
side of the syscall boundary a function lives on, before building a trace around it, would have
caught it in a minute. Recorded in the harness README so it is not retried.

**Two incidental findings for 13.35, not 13.28:** `&Form` in the menu bar is a genuine duplicate
`Alt+F` (harmless only because `&File` matches first), and `Code/Form` is the one top-level menu
with no mnemonic at all. Worth checking whether `ValidateHotKeys` covers menu-bar-to-menu-bar
collisions or only accelerator-to-menu.

### What was gained

- **Debugging Tools for Windows installed** at `C:\Program Files (x86)\Windows Kits\10\Debuggers\x64`
  (`cdb`, `kd`, `symchk`, `dbh`), debuggers-only feature set, not the full SDK. Symbol cache at
  `C:\Symbols`, `_NT_SYMBOL_PATH` set at user scope. Useful beyond this defect.
- **Kernel symbols verified usable** — `win32kfull.sys` public PDB matches this build and names
  `xxxMNFindChar`, `xxxMNKeyFilter`, `xxxMNChar`, `xxxMNLoop`, `xxxSysCommand`,
  `xxxHandleMenuMessages`. This premise was checked *before* recommending the invasive setup.
- **KDNET setup written up** in the harness README, with machine roles and **every prerequisite
  verified on the target**: BitLocker off on both machines, Secure Boot **already off**
  (`UEFISecureBootEnabled = 0`), and a debug-supported Realtek PCIe GbE NIC (`busparams=2.0.0`).
  No firmware change and no reboot risk remain. **The only missing piece is an ethernet cable** —
  the Realtek port reports "Not plugged in" and the machine is on Wi-Fi only, which `kdnet.exe`
  does not list as supported.

### Unexplained, worth knowing

`astoria.exe` (pid 19872) **exited on its own** partway through the session, between the menu probe
and the next attach. No WER report, no Application Error event, no System log entry — it did not
fault. Cause unknown. This is the second recorded instance of the binary behaving oddly outside a
build (the 2026-07-20 early-hours entry records the exe changing on disk when nothing should have
written it). If it recurs, find out what is doing it.

### Files added

`TestHarness/13.28_Mnemonics/SysCharTrace.cdb` and `RunSysCharTrace.ps1` — kept despite the void
result. They are correct instruments pointed at the wrong layer, the non-stopping-breakpoint pattern
is reusable, and `RunSysCharTrace.ps1` carries the working `SendInput` guard and foreground check.

## Session handoff (2026-07-20, small hours) — shortcut integrity fixed; 13.28 pt 3 narrowed, not solved

**Everything below is committed and pushed. The tree is clean and `astoria.exe`, `astoria-mcp.exe`
and `framework.dll` are all current builds of this source.**

### Shipped and verified

| | What | Verified |
| --- | --- | --- |
| **13.35** | The shortcut generator no longer produces bad data. User tools get unique names (`UserTool0…`) instead of all being `"Tools"`; the Options editor no longer lists items whose shortcut it cannot persist; the writer refuses to emit a duplicate key. | Compiles clean; **Options round-trip NOT owner-verified** |
| **13.35** | `ValidateHotKeys` — a startup integrity check for duplicate keys, one combination bound to two commands, and accelerators shadowing a menu mnemonic. Writes `Temp/_astoria_hotkeys.log` **only when something is wrong**. | Found the real `Alt+C` collision unaided; other two checks proved against injected faults |
| **13.35** | Assignment-time prevention in Options: refuses a shortcut that would shadow a top-level menu or that another command already owns. Shares `ShadowedMenuFor` with the validator so detection and prevention cannot drift. | Compiles clean; **dialogs not yet exercised by hand** |
| — | `HotKeys.txt`: UTF-8 BOM removed (it silently killed the first entry), 24 orphan entries pruned, all verified unreachable. | File verified BOM-less, CRLF, 73 entries |
| — | Shortcut changes: `CommandPrompt` `Alt+C` → **`Ctrl+Shift+C`**; `Format`/`Unformat` `Ctrl+Tab`/`Ctrl+Shift+Tab` → **`Ctrl+K`/`Ctrl+Shift+K`** (Ctrl+Tab is the Windows standard for switching documents). | `Ctrl+Shift+C` verified by effect; **`Ctrl+K` compiled only** |
| — | Dead code removed: the unreachable `UnComment` dispatch route, four dangling `TabWindow` declarations with no implementation, three unreachable encoding retries in the Immediate window. | Compiles clean |

### Do these first

1. **Three hand checks**, each seconds long, all on changes automated testing cannot vouch for:
   Options ▸ Shortcuts → change a shortcut, save, confirm `HotKeys.txt` has exactly one `Tools=`
   line and no blanks; try assigning `Alt+P` (must refuse, naming Project) and `Ctrl+S` (must
   refuse, naming Save); and confirm `Ctrl+K` actually formats code.
2. **Decide the fate of the instrumentation.** `framework.dll` and `astoria.exe` contain diagnostic
   code for 13.28 (all gated off by an environment variable or a sentinel file, costing a normal run
   one `Static` read). It is committed because the defect is open. A backup of this exact tree is at
   `P:\Astoria-IDE-Backups\instrumented-syskey-2026-07-20.zip`. **Strip it and rebuild with
   `FORCE_MFF=1` before cutting a release.**

### 13.28 part 3 — much better understood, still open

`Alt+C`, `Alt+G` and `Alt+R` do not open their menus. **Read
[TestHarness/13.28_Mnemonics/README.md](TestHarness/13.28_Mnemonics/README.md) before touching
this** — it lists eleven disproved hypotheses, the instruments, and the traps.

The single most useful thing learned: **the owner identified the defect signature by ear.** A letter
with no menu makes Windows beep; C, G and R are *silent*. The automated probe could not tell those
apart and had been reporting them identically all session. The bell means the keystroke never
reaches the menu-mnemonic code at all.

What is established: the cursed set is exactly {C, G, R}; it follows the **letter, not the menu**
(rename Code's mnemonic to D and `Alt+D` works while `Alt+C` still fails, and `Alt+R` stays dead
when no menu uses R); it is not MFF (a minimal MFF app opens all three), not the accelerator table
(dumped in-process), not the message loop, not the system menu, not add-ins, not settings.

The open contradiction: `WM_SYSCHAR` reaches the form with `Handled=0, Result=0` and falls through
to `DefWindowProc`, which then produces neither menu activation nor `WM_MENUCHAR` — while `Alt+E`,
matching nothing, produces both.

**One caveat on this session's evidence.** The owner noticed the IDE appearing to abort during a run
while I continued reading probe output as though it were healthy. Probe output looks identical
either way. The C/G/R result itself is corroborated by ear and reproduced across many runs, but any
*single* run from this session should be re-confirmed before being built on.


**Last updated:** 2026-07-20 (early hours) — Section E testing finished except the screen reader,
**five defects found and fixed** (13.29, 13.30, 13.32, 13.33, 13.28 parts 1–2), two new ones
recorded (13.35, 13.36), and the keyboard-accessibility failure that was the plan's only ❌ is now
mostly closed. **FEATURE COMPLETE FOR 1.0**; remaining work is testing and targeted
reliability/polish fixes. See [Documentation/TestPlan.md](Documentation/TestPlan.md) and
[Documentation/Testing.md](Documentation/Testing.md).

*Current activity: **integration testing**. No known 1.0 beta blockers remain. TestPlan sections
A–D are complete; Section E is complete except **E10b screen reader**, which cannot be run here at
all — it needs a person who uses one. E9 keyboard-only is no longer a flat failure: parts 1 and 2 of
13.28 are fixed, parts 3 and 4 remain. E12 (keyboard shortcuts) is a new scenario, partially run —
see 13.34 for what is left and, more importantly, for the five ways its harness produced confident
wrong answers.*

*Earlier in this testing run: seven scenarios (A1, A4, A5, B1, B4, B6, B10), two of which passed
only after fixing real defects the tests found — the WebBrowser control could not render a page at
all and has been rebuilt on WebView2, and `SQLite3Component.AddField` could never succeed in its
obvious form.*

*Previous entry, 2026-07-17:* (In progress: **New Project two-mode redesign + `project.astoria`** — built, compiles clean, NOT yet owner-verified; owner continuing tests on the other computer. See "Session handoff (2026-07-17) — New Project two-mode redesign" below. Earlier: Agent MCP Server **COMPLETE — Tasks 0–7**. Task 7 verified end-to-end from a real stdio MCP client: create → write → build → get_errors → fix → run produced the correct output (`Primes below 1000000 = 78498`). Verification fixed two MCP bugs — Fix B: `create_project` opens the main file; Fix C: agent build saves dirty editors first — and flagged two pre-existing ones, both since fixed (broken Console Application template; `run`-capture NUL truncation — the latter hardened 2026-07-17, pending GUI/MCP verify on the other computer). Earlier today: Task 6 (toggle default-on, status-bar indicator, auto-launch, packaging) `83426ef`; five AI templates gained MCP config `b70143c`.)
**Repository:** [github.com/dmontaine/astoria-ide](https://github.com/dmontaine/astoria-ide)
**Local path:** C:\Users\don\Astoria-IDE

This is the concise, authoritative handoff for the next work session. Completed-work narratives, investigations, and dated session notes are archived in [HISTORY.md](HISTORY.md). Shipped changes are indexed in [CHANGELOG.md](CHANGELOG.md), and fuller enhancement specifications live in [ROADMAP.md](ROADMAP.md).

## Session handoff (2026-07-20, early hours) — Section E finished bar the screen reader; five defects fixed

**Everything is committed and pushed through `0241bba`; the tree is clean and `astoria.exe` is the
build the tests actually ran against.** One thing to know about that binary: after the final commit
the working-copy exe changed on disk at a time nothing should have rebuilt it, so it was restored
from the commit rather than shipped unverified. If that recurs, find out what is writing it before
trusting a build.

### What was fixed

| | What | Verified |
| --- | --- | --- |
| **13.29** | Launching Astoria while it is already running **crashed** the second process (`0xC0000005`) and never raised the running IDE. | Owner-verified |
| **13.30** | The editor ignored the system **high-contrast** theme; with a light theme, line numbers vanished entirely. | Owner-verified |
| **13.31** | UI simplification: **Tip of the Day removed**, toolbars pinned to three rows, View ▸ Toolbars reduced to one on/off toggle. | Owner-verified |
| **13.32** | `Ctrl+Shift+O` (Open Project) was advertised in Options and could never fire. | Owner-verified |
| **13.33** | `Ctrl+Shift+D` (External Tools) did nothing — three blank duplicate `Tools=` lines in `HotKeys.txt` shadowed the real binding. | Owner-verified |
| **13.28 pt 1** | The **New Project dialog took no keyboard input at all** and could not be closed — the release-relevant blocker. | Automated; **not** owner-verified |
| **13.28 pt 2** | The **project tree could not be reached** from the keyboard, so no file could be opened without a mouse. | Automated; **not** owner-verified |

### Do these first

1. **Three hand checks on the two unverified fixes.** Each is seconds, and each covers a change that
   automated testing cannot fully vouch for:
   - **New Project**: `Ctrl+Shift+N`, press Tab a few times, press Escape. Then confirm the
     dialogs that already worked still do — Options, Find, Goto — since 13.28 pt 1 changed
     `Form.ShowModal` in the **framework**, which every modal in every user program also goes through.
   - **Project tree**: `Ctrl+R`, arrow to a source file, press **Enter**. Enter did not open a file
     under synthesized input; the wiring reads correct and the navigation may simply have been on a
     folder, but it is unconfirmed. This is the one open question on part 2.
   - **Designer undo (13.36)**: confirm the defect you hit — Cut a control, `Ctrl+Z`.
2. **13.36 — designer Cut then Undo does not restore the control.** Owner-observed by hand. Undo
   itself is fine (it works in the code editor), so this is the designer route only. It contradicts
   both TestPlan C4 and the reasoning at `AstoriaIDE.bas:151` that one history serves both views, so
   resolve which is wrong before changing code.
3. **13.28 parts 3 and 4** — `Alt+R` does not open the Run menu, and `Ctrl+F9` is silent when focus
   is in the Project search box. New clue for part 3: **`Alt+E` fails the same way**, so this is
   menu mnemonics generally, not one broken binding.
4. **13.34 — finish the shortcut sweep.** 18 of 54 confirmed working, 2 were broken and are fixed.
   Read 13.34 before running the harness; the traps below are why.

### Read this before writing another UI test

The shortcut sweep produced **five separate false results**, each confident and each wrong. They are
documented in 13.34 and in `TestHarness/README.md`, and they generalise:

- **Focus, then reset — never the reverse.** `write_file` reloads the document and drops editor
  focus. Reported four working shortcuts as dead.
- **A leftover modal disables everything after it.** Astoria's "Definitions for…" window does not
  close on Escape, and while it is up the main window is disabled. Produced fifteen false failures.
- **The IDE may not be where you left it.** On restart it restores the saved workspace; if that is a
  `.frm`, clicks land on the designer, not a code editor.
- **Another application can eat the shortcut before Astoria sees it.** A background app was
  capturing `Ctrl+Shift+Z` among others. Nothing in Astoria can detect this.
- **Synthesized `Ctrl+Z` does not behave like a hand.** It never undid anything, while `Ctrl+A`
  worked on the same focus in the same session — which looked exactly like a broken Undo. **It is
  not broken**; the owner confirmed by hand. Cause still unknown. **Every Undo/Redo result in the
  sweep is void.**

The instrument check (type a character, confirm it lands, before testing anything) caught two of
these and is the reason the surviving results can be trusted. It does **not** cover the last one: it
proves a character arrives, not that a shortcut behaves as it does under a hand. **Confirm any
negative by hand before recording it as a defect.**

### Still open

- **E10b screen reader** — the only untestable scenario; needs a person who uses one. Carry to the
  human-tester round.
- **13.35** — the shortcut file is keyed on a non-unique menu item name, which is what generated
  13.33's bad data. Every Options save can reintroduce duplicates; a user who adds two external
  tools and saves can silently blank a working shortcut. Not urgent (the loader now tolerates it),
  but the generator is untouched.
- **13.21, 13.22, 13.24** — unchanged, all minor.
- **External Tools does not close on Escape.** It is shown with `Show`, not `ShowModal`, so it is
  modeless and 13.28's modal fallback does not reach it. Left deliberately: it is not a trap, and
  the app-wide pump that would fix it also serves the main window, where Escape must not close
  anything.

## Session handoff (2026-07-19, night) — 13.27 verified, and CRLF enforced instead of frozen

**Where things stand: three commits, all built and the fix owner-verified.** `0d6c6be` (13.27),
`0086f1a` (line-ending sweep), `3c9dc6b` (verified binary + ROADMAP). Nothing pushed. Untracked
debug traces and `Projects/Project3/Module1.exe` were deliberately left alone.

**13.27 is resolved and owner-verified.** The left panel no longer jumps to the Toolbox. Astoria
selects the Project pane only when you enter a different project — startup, New Project, Open
Project / Open Folder — and `View ▸ Toolbox` still works because that is the user asking. The four
verification checks are recorded in ROADMAP 13.27. One is worth repeating here: the startup test was
run with `LeftSelectedTab=1` written into `astoria.ini` first, because at its default `0` the test
cannot fail — `0` is already Project.

**The previous session's work was recovered, not lost.** It had been staged but never committed, and
PROJECT_STATUS was never written; the ROADMAP 13.27 writeup it left behind was intact and accurate.

**The line-ending convention had quietly stopped holding, and now it cannot.** A survey found **256
tracked source files violating the CRLF rule** — 253 entirely LF, 3 mixed. The T01 sweeps
(`2f445e4`, `4795d9b`, `6682da9`) had set the convention with scoped `-crlf` attributes, but `-crlf`
means `-text`: *store as-is, never convert*. It froze the CRLF that had just been written and froze
LF arriving afterwards just as faithfully — it preserved the convention without enforcing it, and a
whole-file EOL flip produces no readable diff, so nothing ever surfaced. Two causes:

- **Whole-file rewrites by tooling.** `src/TabWindow.bas` was CRLF through 2026-07-18 and flipped at
  `fc9ebc9`, whose numstat is `13178/13154` — the entire file rewritten to land a targeted fix.
- **New files born LF.** `AgentMcp.bas`, `AgentPipe.bas`, `JsonLite.bas`, `ProjectDescription.bas`,
  `RenameRefactor.bi`, `frmGitCommit.*` and the Integration fixtures postdate the sweeps and never
  had CRLF at all.

`.gitattributes` now uses `text eol=crlf`, which normalises to LF in the blob and checks out CRLF
unconditionally, so a non-compliant working tree is no longer representable. Patterns are repo-wide
rather than scoped to three directories — scoping is how `Templates/Files` and `Tools/LNGCreator`
escaped the original pass. **Do not weaken these back to `-crlf`/`-text`.** Post-sweep scan:
**4108/4108 compliant, 0 violations**, and the whole tree compiles clean.

**Two method notes worth keeping.**

- *Git will not show you this class of drift.* Under `text`, git normalises the working tree to LF
  for comparison, so LF files compare equal to their blobs and `git status` reports clean. After the
  renormalising commit the files had to be deleted and re-checked-out to actually become CRLF; the
  proof was a byte-level scan of all 4108 files, not `git status`.
- *A piped build exit code is worthless.* `Compile.bat` piped to a file returned `0` from the pipe.
  The build was confirmed by effect instead: log tail `Release build complete.`, ~3-minute duration,
  exe timestamps newer than the newest source, and a **SHA256 differing from the pre-fix binary** —
  the last because the new exe happened to be byte-identical in *size* to the old one.

**Next.** Nothing is pushed. The remaining TestPlan queue is unchanged: E9 keyboard-only, E10 screen
reader / high contrast, E11 multiple Astoria instances, plus the unavailable mixed-DPI portion of E8.
`DetailedChangelog.md` needs regenerating for the three new commits. ROADMAP 13.27 carries one minor
leftover: `LeftSelectedTab` is now a write-only ini key.

## Session handoff (2026-07-19, evening) — integration testing through E8

**Where things stand:** TestPlan A–D are complete. E1–E7 pass; E8 passes at 125%, 150% and 200%
on a single monitor. The remaining queue is E9 (keyboard-only workflow), E10 (screen reader and
high contrast), E11 (two Astoria processes with independent projects), plus the unavailable
mixed-DPI monitor-move portion of E8.

**Clean-machine packaging is proven.** `BuildInstaller.ps1` staged commit `c838493` into
`C:\Users\don\Astoria-IDE-Release` (4,178 files, 287 MB) and built unsigned installer version
1.3.7 at `C:\Users\don\Astoria-IDE-Installer\AstoriaIDE-Setup-1.3.7.exe`. The owner installed it
on a bare computer with no existing FreeBASIC toolchain, then compiled and ran a program. That
installer predates the final warning-only cleanup described below; rebuild it from the new HEAD
before distributing another copy.

**The D6 multi-form debugger workflow passes after five fixes.** Breakpoints in Main and Child
event handlers, Step Over, Locals, Watches, FreeBASIC string values/types, returned values, Stop,
and process cleanup were owner-verified. Step Out may first land in the framework dispatcher; this
is documented as a GDB caller-frame limitation. The reusable fixture is
`Examples/Integration/D6_DebugMultiForm`.

**Do not repeat the attempted compiler-warning cleanup from `6f1dcee`.** Replacing the optional
`ByRef WString` defaults and simplifying the `Debug.Print` overload removed the five
`Application.bas` warnings and compiled successfully, but the resulting IDE crashed reliably with
an access violation while loading the Toolbox. A stable global empty `WString` default was also
tried and produced the same crash. The full change was reverted to the last owner-verified
implementation; the harmless warnings remain. The restored release build was then launched through
startup and remained alive and responsive after Toolbox loading. Reliability takes precedence over
cosmetic warning removal unless a future fix is both ABI-safe and startup-tested.

**Do not sweep local artifacts into the next commit.** `Examples/DeviceExplorer/DeviceExplorer.vfp`
was changed by the owner's test run and was deliberately left unstaged, along with generated
projects/results, old debug traces, and `.claude/`.

## Session handoff (2026-07-18, afternoon) — integration testing begins, WebBrowser rebuilt

**Where things stand: tree clean, everything pushed through `02d263d`.** This session moved from
"does each control open" to "do controls work, and work together" — and that shift immediately
found real defects, which is the argument for continuing it.

**A maintained test plan now exists:** [Documentation/TestPlan.md](Documentation/TestPlan.md), 44
scenarios in five sections, each marked 🤖 agent-automatable / 🤝 assisted / 👤 human, with Status
and Result columns filled in as they run. It is the forward-looking companion to Testing.md, which
remains the summary a tester reads first.

**Seven scenarios run, all now passing — two of them only after fixing what they found:**

| | Result |
| --- | --- |
| A1 SQLite3 data path | ✅ 26/26. **Found and fixed a real defect** (below). |
| A4 WebBrowser rendering | ✅ **after rebuilding the control on WebView2** (below). |
| A5 WebBrowser navigation | ✅ 4/4 — link followed, GoBack, GoForward. |
| B1 data-entry form | ✅ Six controls read back; radio group correctly deselects. |
| B4 docking under resize | ✅ 50/50 across five sizes incl. maximise and restore. |
| B6 list/detail | ✅ Keyboard-driven selection; exactly one event per change. |
| B10 second form | ✅ Modal round-trip + modeless coexistence; **z-order owner-verified**. |

**The WebBrowser control could not display a page at all, and crashed on `Navigate`.** It hosted
the retired IE engine through ATL `AtlAxWin`, whose host window was created with empty text, so no
control was ever instantiated. Replaced with upstream MyFbFramework's **WebView2** implementation,
which this fork's copy lacked, and made the *default* on Windows rather than opt-in — a user
dropping the control on a form cannot be expected to know a `#define` exists. Static linking was
tried and rejected (the static loader is MSVC-built and needs intrinsics MinGW lacks; stubbing them
would disable Control Flow Guard), so `WebView2Loader.dll` is copied beside built exes by
`BuildService.CopyFrameworkRuntimeDlls`, and the arch lib folder is added to the library path in
code so existing installs get it. Verified end to end through a real IDE build. **Requires the
WebView2 runtime** — ships with Edge on Windows 10/11, but is a genuine dependency for a
clean-machine install (E7).

**`SQLite3Component.AddField` could never succeed** in its obvious three-argument form: `nNull`
defaults to 0 meaning NOT NULL with no default, which SQLite refuses to add to an existing table.
Text defaults were also emitted unquoted, so the vendor's own example was broken. Both fixed.

**Also this session:** shipped defaults separated from live user settings (below); the significant-
changes doc gained the no-broken-features rule and the installer entry; ROADMAP §13.14/§13.15
record the upstream backport review and the framework-reference adaptation.

**Next, highest value first:**
1. **B7 shared ImageList** — one ImageList feeding a ToolBar, TreeView and ListView. This is the
   exact bug class that broke menu icons; most likely of the remaining B items to find something.
2. **B13 twenty-control density check** — cheap, and the kind of thing that only fails at scale.
3. **B3 nested containers** and **B9 timer + progress bar**.
4. **A2** (SQLite error handling) and **A6/A7** (control property/event depth).

**Two harness lessons worth carrying:** externally-driven GUI tests park a window on the tester's
desktop for the whole run — B10 was rewritten to drive itself and exit, and B1/B4/B6 should follow
if that becomes annoying. And a thread timer keeps firing inside `ShowModal`'s message loop, which
opened three nested dialogs before B10 guarded against it.

## Session handoff (2026-07-18, evening) — designer testing, three release blockers, ONE UNBUILT CHANGE

### Read this first: there is an uncompiled, untested change in the tree

`src/AstoriaIDE.bas` (commit `623aa2a`) carries a **designer Undo/Redo** implementation that has
**never been built or run**. The build was interrupted before it started, so `astoria.exe` is older
than the source edit and the committed binaries do **not** contain it.

**First action next session:** run `Compile.bat`, then verify by hand — open a form, move or align a
control, press Ctrl+Z, and confirm both that the control returns *and* that the design surface
redraws. It is one self-contained block and safe to revert if it misbehaves.

Why it is small: the designer never needed a history of its own. Every designer change is **already**
in the code editor's undo stack, because `DesignerModified` (`TabWindow.bas`) brackets each one with
`EditControl.Changing`/`Changed`, which is what creates an `EditControlHistory` entry. The only thing
missing was the route — with a control selected, `cboClass.ItemIndex > 0` sends commands to
`DispatchDesignerCommand`, which had no Undo/Redo case, so C4's Ctrl+Z did nothing. The change adds
that case, delegates to `tb->txtCode.Undo`/`.Redo`, and rebuilds the surface via `FormNeedDesign` +
`RunDeferredFormDesign()`. One history serves both views — the form/code consistency that was asked
for.

**Open question:** `TabWindow.bas:3329` already rebuilds a form when its text changes, so the explicit
rebuild may be redundant and could show as flicker. If it does, drop those two lines — but confirm the
refresh still happens before doing so.

Upstream was checked first and has **nothing to backport**: neither VisualFBEditor's `Designer.bas`
nor its main dispatcher implements designer undo; it routes `Undo` only to text controls, exactly as
Astoria did.

### Three release blockers found by testing today

| | Status | What |
| --- | --- | --- |
| **§13.17** | **Required for 1.0** | Renaming a control updates the four sites describing it but nothing referencing it, so the project stops building. Owner-classified mandatory on the *it just works* rule. Task #18. |
| **§13.18** | **Mandatory before 1.0 beta** | `frmMain_ActivateApp` raises a modal MsgBox when an open file changed on disk, so clicking the IDE to focus it can hang the application with no visible dialog — owner had to kill it from Task Manager. Strong hypothesis, **not reproduced programmatically**; confirming test is to press Enter/Escape before killing it next time. Task #19. |
| **§13.19** | Decision pending | The designer had no undo. Addressed by the unbuilt change above; the cheap alternative — grey Undo/Redo out in Form view — stays recorded if the real fix is deferred. |

### Test plan progress

Section A: A1, A2, A4, A5, A7 pass. Section B: **complete, 13/13**. Section C: C1 pass, C2 pass,
C3 fail (§13.17), C4 partial (align/size pass, undo absent → §13.19). **C5 was never run** —
copy/paste between forms, the most interesting one left, because pasting must invent non-colliding
names and C3 showed the naming machinery has gaps.

The scratch project at `C:\Users\don\dontest` is left in place for C5: a working Windows Application
with four aligned labels, a TextBox, a CommandButton and a wired handler. It builds.

### A discipline worth keeping

**Do not edit a file on disk while the IDE has it open** — that is what triggered the §13.18 hang.
Close the IDE first, or have the owner make the edit.

## Shipped defaults separated from live user settings (2026-07-18)

`Settings/astoria.ini` is **no longer tracked**. It is the live per-user settings file — every run
rewrites window geometry and MRU lists into it, and `[PersonalInfo]` now holds a name, e-mail, and
Git login — so tracking it churned unrelated session state into commits and would have published
personal details into a public repository as soon as those fields were filled in. The shipped
defaults are `Settings/astoria.default.ini`, which **is** tracked; `LoadSettingsIni` copies it when
no settings file exists, so a fresh clone or an installed release creates its own on first run.

**This is release hygiene, not a feature** — it changes nothing a user sees. Released builds were
already unaffected: `StageRelease.ps1` has always deleted `astoria.ini` from the staged tree, and
it copies from a `git archive HEAD` export, which by definition cannot contain an untracked file.
That `Remove-Item` is now a belt-and-braces no-op and is commented as such. Verified by exporting
the staged tree: `astoria.ini` absent, `astoria.default.ini` present.

**Consequence worth knowing:** any deliberate default that lived only in `astoria.ini` no longer
reaches a new install — but this was already true, since that file never shipped. Defaults now come
from `astoria.default.ini` (tool defaults: MakeTools, Terminals, Helps, Include/Library paths,
BuildConfigurations) with code defaults filling the rest. `DisplayMenuIcons` is not in the template
and defaults to `True` in code, which matches the intent of the `d4e36d1` release staging. If a
first-run experience should have a specific interface theme or font, add it to the template — the
current one deliberately carries tool defaults only.

## Feature complete for version 1.0 (2026-07-18)

**Astoria IDE is feature complete for version 1.0.** No further features are planned for this
release. Work from here is limited to:

- **Testing** — see [Documentation/Testing.md](Documentation/Testing.md) for what has been covered
  and, more usefully, the known gaps.
- **Program flow and UI tweaks** as testing shows they are needed.
- **Bug fixes** arising from either.

**A new feature request should be declined for 1.0 and recorded in [ROADMAP.md](ROADMAP.md)
instead.** The bar for changing anything else is now "a tester hit a problem", not "this would be
better".

This is in preparation for **recruiting human testers**. Everything to date has been tested by one
developer on two of their own machines; nobody has yet come to Astoria fresh. The documentation a
tester needs is in `Documentation/`:

| Document | Purpose |
| --- | --- |
| [AstoriaIDESignificantChanges.md](Documentation/AstoriaIDESignificantChanges.md) | What Astoria is, who it is for, and how it differs from VisualFBEditor. Start here. |
| [Testing.md](Documentation/Testing.md) | What has been tested, what has not, and what a tester can most usefully do. |
| [Controls.md](Documentation/Controls.md) | Reference for every toolbox control: purpose, key members, warnings. |
| [FrameworkFeatures.md](Documentation/FrameworkFeatures.md) | The non-toolbox framework: registry, ini files, HTTP, drawing, collections. |
| [ControlTesting.md](Documentation/ControlTesting.md) | Per-control test results in full. |
| [DetailedChangelog.md](Documentation/DetailedChangelog.md) | Every change, in date order. |

All six are maintained going forward. `Documentation/AstoriaIDESignificantChanges.md` supersedes
the `.doc` on P:\Astoria-Docs — edit the Markdown, which is version-controlled.

## Session handoff (2026-07-19, evening) — every compiler warning removed

**Tree clean, everything pushed.** `astoria.exe` and `framework.dll` are both current release
builds, and the DLL now matches its source.

### Warnings: all gone, none suppressed

| Build | Before | After |
| --- | --- | --- |
| Any user project (framework) | 6 | **0** |
| DeviceExplorer example | +2 `-Wmissing-braces` | **0** |
| The IDE itself | 7 | **0** |
| `framework.dll` | 0 | **0** |

**One rule explains all thirteen `warning 36` lines.** FreeBASIC reports "Mismatching parameter
initializer" when a `ByRef WString` parameter carries a default on **both** the `Declare` and the
definition — the two `""` literals are separate objects, so they do not match despite reading
identically. **The default belongs to the declaration; the definition must not repeat it.** Worth
knowing before writing new framework or IDE code, because the warning is otherwise baffling.

The `-Wmissing-braces` pair came from DeviceExplorer's `DEFINE_PROPERTYKEY` macro flattening a
`GUID` alongside `pid` in a `PROPERTYKEY`. Fixed by nesting the GUID's initializer, and verified by
diffing the **generated C**: values byte-for-byte identical, only braces added. That check mattered
more than the warning — a silently altered GUID would break device property lookups far more quietly.

### Why the earlier attempt broke startup — now answered

`6f1dcee` was reverted in `46078e6` as "warning cleanup that broke startup", cause unrecorded. It is
no longer a mystery: **that change deleted the `Msg1`–`Msg4` parameters from `Debug.Print`**, which
is not a warning fix but the removal of a four-argument overload the framework calls. It also
changed `MsgBox`'s default from `""` to `WStr("")` in both places rather than removing the
duplicate. No further investigation is needed, and the framework header cleanup it attempted is
safe to redo as long as no parameter is removed.

### Verification, in order

A four-line program reproduced all six framework warnings — a seconds-long loop instead of a full
IDE build, which is what made this tractable. Each fix was confirmed against it; the IDE rebuilt to
zero warnings; **the IDE starts and its agent pipe answers `get_status`**, the exact gate the last
attempt failed; DeviceExplorer was rebuilt *through the IDE* with a clean Output pane; and after the
DLL rebuild the whole chain was re-run through the pipe, including opening a `.frm` (where the
designer instantiates controls through `framework.dll`).

`framework.dll` was rebuilt at the owner's request for source/binary parity: same size, 163 bytes
different (0.02%) — build stamps only, confirming the fix could not alter codegen.

## Session handoff (2026-07-19, later) — D1/D2 pass, gh dropped, four new tasks

**Tree clean, everything pushed.** `astoria.exe` is a current release build. The IDE was rebuilt from
the pulled source at the start of this session, so it includes the C3 rename-refactor and §13.18
work from the other machine.

### Tests

| Test | Result |
| --- | --- |
| **D1** console lifecycle | ✅ 12/12, fully automated — `TestHarness/D1_ConsoleLifecycle.ps1` |
| **D2** Windows app lifecycle | ✅ owner-verified; found §13.24 |
| **D3** Git-backed project | re-specified and set up; **not yet run** |

D1 asserts on program *output*, not exit status, and rebuilds after reopening — a project that is
merely listed is not the same as one that still works.

### The gh/glab CLI is gone (`08eaece`)

Owner's call: if someone is running Astoria, a browser is available. All three CLI use sites now use
the browser path they already had as a fallback — SSH key registration, Create Remote Repository, and
the New Project clone preflight — each putting the key or repository name on the clipboard first.

I had built a **Set Up GitHub CLI** menu item to make the dependency easier to acquire, and it was
the wrong question: the right one was whether the dependency earned its place. It did not. That
feature, its winget install flow, a registry PATH-refresh helper and a console runner were all
removed. Three findings from the attempt, each of which argued for removal rather than for more
engineering: gh's sign-in cannot avoid a console; a tool installed while Astoria runs is invisible to
it; and the failure message had to disambiguate three states that each needed different user action.

### Four tasks raised by the owner while testing

§13.23 (Git setup documentation), §13.25 (first-start dialog: use Git? use AI? personal info),
§13.26 (convert a local project to Git), §13.27 (left panel jumps to the Toolbox). They share a
theme — Git and AI are presented to everyone as though everyone wants them. **Decide §13.25 first;**
a user who answers "no Git" never meets §13.23's or §13.26's problem at all.

§13.24 also came out of D2: analysis leaves a scratch `Temp.bas` beside the user's source.

### Next

1. **§13.27** — smallest and most visible; cause identified in `ApplyView`.
2. **D3** — set up and ready; step 3 (the new-repository page, with the name on the clipboard) is the
   path changed by the gh removal and has not been exercised.
3. **§13.25**, then §13.26 in whatever shape §13.25 leaves it.

## Session handoff (2026-07-19) — both 1.0 blockers closed; no known beta blockers remain

**Tree clean, everything pushed.** `astoria.exe` is a current release build including every
fix below. This session closed **§13.17** and **§13.18**, the two items that gated 1.0, and
fixed four defects in `MariaDBBox` found by running TestPlan A3.

### Tests run

| Test | Result |
| --- | --- |
| **A3** MariaDBBox connection | ✅ **34/34** against MariaDB 10.6.8, after finding and fixing 4 real defects |
| **C3** rename a referenced control | ✅ after fixing §13.17 — owner-verified, project rebuilt from scratch |
| **§13.18** activation-modal hang | ✅ owner-confirmed after three rounds (see below) |

Section C is now **complete**. Section A is complete except A8. Section B was already complete.

### MariaDBBox: four defects, all fixed (§13.20)

The component was a copy of `SQLite3Component` that had evidently never been run against a
server. `CreateTable` emitted SQLite's `AUTOINCREMENT`; `AddField` left text defaults
unquoted; `AddField` silently made columns `NOT NULL` **while reporting success**; and
`Insert` returned `0` whether it succeeded or failed. All four fixed, with the recording
checks promoted to regression assertions.

**`Insert`'s contract changed** — it now returns the new row id, or `-1` on failure. No
in-repo callers, but external code checking `Insert(...) = 0` for success is testing the old
broken behaviour. Noted in `Controls.md`.

Credentials come from `MARIADB_TEST_*` environment variables and a gitignored `*.local.sql`;
no password is in the repository. The server-side setup is already done on this machine.

### §13.18 took three rounds, and the second and third were self-inflicted

Worth reading before touching this code:

1. The **original cause** — a modal raised from inside `frmMain_ActivateApp` — was fixed by
   deferring to a posted `WM_APP_FILECHANGED`, batching all changed files into one prompt,
   and foregrounding the window first.
2. That fix **crashed the IDE** on accepting a reload: the queue was an array of `UString`
   grown with `ReDim Preserve`, which shallow-copies a heap-owning type and double-frees it.
   It surfaced at the next unrelated touch, so it presented as the *reload* being broken.
   Because `SaveWorkspace` runs only on a clean close, the crash also lost the session and
   reopened the previous project — which looked like a third, separate bug and was not.
3. The prompt then **appeared to list only one of two changed files**. It was listing both;
   `MsgBoxForm` clips unbreakable text at a fixed width, and two paths sharing a directory
   prefix clip to the same visible string.

**Method note, because it cost real time.** Three hypotheses were formed about (3) — forward
slashes, the IDE re-saving the file, form regeneration — and all three were wrong; they aimed
at detection, which was working correctly the whole time. One trace line per tab settled it in
a single run. The owner's suggestion that the dialog might be truncating is what closed it.
Measure before theorising.

### Open, in the order I would take them

**Four items raised by the owner while testing on 2026-07-19 (§13.23, §13.25–§13.27).** Together
they describe one theme: Git and AI are presented to every user as though everyone wants them, and
the user is left to work out the setup. §13.25 (first-start dialog) is the largest and would
subsume part of the others — a user who answers "no Git" never meets §13.23's documentation gap or
§13.26's conversion problem. Worth deciding §13.25 first, since it changes what the other two need
to cover.

0. **§13.23 — document how to set up Git for use with Astoria.** Raised 2026-07-19. The Git
   integration works but nothing describes the one-time sequence, two steps of which end in a
   browser and cannot be automated. It is the one path where a beginner can get stuck with an error
   (authentication failure at push) that points nowhere near the step they missed. Also settle
   whether Astoria should detect a missing `git` and say so plainly.

1. **§13.27 — the left panel jumps to the Toolbox and stays there.** Smallest of the new items and
   the most visible: the user selects the Project tab, saves, and is thrown back to the Toolbox.
2. **§13.25 — first-start dialog** (use Git? use AI? personal information), and **§13.26** — convert
   a local project to a Git project. Decide §13.25 first; it changes §13.26's scope.
3. **§13.22 — `MsgBoxForm` clips long unbreakable text.** Not a blocker, but it will mislead
   in any future dialog that names a file, and it already did once. Widening the box when the
   natural width exceeds the fixed 380 is probably the cheapest correct fix.
2. **Workspace is lost on any crash.** `SaveWorkspace` runs only on clean shutdown. Not yet a
   roadmap entry; it made a crash look like a separate bug and would annoy a real user.
3. **§13.21 — the auto-namer reuses a control name its old handler still references.** Needs a
   policy decision; the untested risk is wiring `OnClick` on the new control generating a
   handler name that already exists.
4. **TestPlan D1 and D5** — agent-runnable lifecycle tests. Then A8, then Sections D and E.
5. Tasks #15 (upstream MFF backport review), #16 (framework reference), #17 (optional BOM pass).

### Also this session

- **`CLAUDE.md` added at the repository root** — guidance for an AI working on *Astoria
  itself*, which did not exist before. The template under `Templates/AI/ClaudeCode/` ships into
  user projects and describes writing FreeBASIC apps; it is not what someone maintaining the
  IDE reads. The new file carries the build procedure, the FreeBASIC traps that have cost time
  here (BOM, `ReDim Preserve`, `&h8000`, keyword collisions), the document-maintenance rule,
  and the testing discipline.
- **The Claude project template gained** the UTF-8 BOM rule (absent entirely), the
  `ReDim Preserve` rule, `Str(a = b)`, editing through MCP rather than behind the IDE's back,
  and a testing-discipline section. `AGENTS.md` in that folder mirrors it.

## Session handoff (2026-07-18, latest) — designer shortcuts, C5/C6/A6, doc rules

All committed and pushed; `main` in sync. `astoria.exe` is a current **release** build (`-Wc -O2`).

**Tests run this session**

| Test | Result |
| --- | --- |
| **C4** designer undo/redo | ✅ after the menu restructure (see previous handoff) |
| **C5** cross-form copy/paste | ✅ — new fixture `Examples/Integration/C5_CopyPaste`. Name collision resolves (`lblShared` → `lblShared1`), declarations update, project rebuilds and runs |
| **C6** split-view menu tracking | ✅ — measured by sampling Windows' menu state on a timer, not by eye |
| **A6** ScintillaControl editing | ✅ 8/8 — text round-trip, line addressing, selection replace, undo, redo, style colours |

Section C is complete **except C3** (renaming a control breaks the build, ROADMAP §13.17) — still the
one 1.0 blocker.

**Rule added, and it earned its keep immediately.** `Documentation/TestPlan.md` now opens with a
table of which documents to update after every test. It exists because WebBrowser went from "cannot
render" to "verified" while `Controls.md` kept telling readers to prove it worked first, and the
runtime-DLL table never gained `WebView2Loader.dll`. Test documents stay current because running a
test forces a visit; reference documents drift because nothing does. A6 was the first test run under
the rule and it turned up three reference-doc updates that would otherwise have been skipped.

**A6 is verified through a real project**, not just by hand. It now carries a `.vfp`; built by the
IDE, the three Scintilla DLLs are copied automatically. TestPlan records the general limitation: the
Integration fixtures are loose `.bas` files compiled by `fbc`, so they bypass the project pipeline
entirely — anything touching deployment must be re-checked through a project.

**Single-file editing is unreachable, by design.** Owner established that with no project open the
IDE offers no Open File command, and with one open Build targets the project. A warning added for
that case was removed as dead code. This is now stated for users in
`Documentation/AstoriaIDESignificantChanges.md`: Astoria is a project-based build system, and anyone
wanting to edit a lone `.bas` should use a text editor.

**Next up, in the order I would take them**

1. **A3 — MariaDBBox connection.** The last unproven data path and the largest remaining gap in
   `Testing.md`. Needs connection details (host, port, user, password, a database that can take
   test tables); MariaDB is installed on this machine.
2. **C3 / ROADMAP §13.17** — the 1.0 blocker.
3. **D1, D5** — agent-runnable lifecycle tests.
4. **A8, D2, D3, D6** — need owner interaction.

## Session handoff (2026-07-18, later) — menu restructure: Code / Code-Form / Form

**Designer keyboard commands work.** Ctrl+Z, Ctrl+Y and the clipboard shortcuts now function on the
form designer as well as in the code editor. Owner-verified in both views; Code and Form still grey
contextually as designed.

**The cause was not what ROADMAP §13.19 recorded.** That entry concluded the designer had no undo
implementation and proposed either building an undo stack or greying Undo out for honesty. Both were
wrong: the designer always had undo — every designer edit is written into the code editor's history
by `DesignerModified`. Undo simply lived in the **Code** menu, which greys in Form view, and
**Windows' TranslateAccelerator consumes an accelerator whose parent menu is disabled and sends no
WM_COMMAND at all**. The keystroke was destroyed in the message loop, which is why it produced no
error and no log entry of any kind. §13.19 is corrected in place.

**Owner's fix, implemented:** menus now separate by context —

| Menu | Holds | Greyed? |
| --- | --- | --- |
| **Code** | Cut Current Line, Toggle Comment, Indent/Outdent, Format, Advanced, Add Procedure/Type, Complete Word, Syntax Check, Convert | contextually |
| **Code/Form** *(new)* | Undo, Redo, Cut, Copy, Paste, Duplicate, Select All | **never** |
| **Form** | Default Event, Align, Make Same Size, Size to Grid, Spacing, Center in Parent | contextually |

The Form menu's duplicate clipboard items (wired to `@PopupClick`) were removed in favour of the
single shared set, which `mClick` routes to the editor or the designer by focus.

**Rule to preserve:** any command valid in more than one context belongs in Code/Form. Greying a
top-level menu silently kills every shortcut inside it.

Two supporting changes were needed for the designer to be recognised as an editing context at all:
`frmMain_ActiveControlChanged` now treats `ClassName = "Form"` (the designed form is itself an MFF
Form) as enabling, and `mClick`'s dispatch guard accepts it.

TestPlan C4 now passes. `Documentation/Testing.md` carries the debugging case study — four fixes
were built from reading the code before instrumentation found the real cause, and that pattern is
worth not repeating.

## Session handoff (2026-07-18) — controls audit, documentation set, release staging

Everything below is committed and pushed. `astoria.exe` and `astoria-mcp.exe` are freshly built
**release** binaries (`-Wc -O2`, no `-g -exx`) matching this source, smoke-tested: the IDE starts
and its agent pipe answers `get_status`.

**Shipped this session**

- **Runtime DLL copying.** A control library declares what its programs need at runtime via a
  `RuntimeDlls` key in `Controls/<Name>/Settings.ini`; `CopyControlRuntimeDlls`
  (`src/BuildService.bas`) copies those beside the built exe on every successful build, before any
  Run. Fixes programs using ScintillaControl or MariaDBBox failing to start anywhere but the build
  machine. `libmariadb.dll` (missing from the repo entirely) is now shipped.
- **All 73 toolbox controls pass** compile + open/close, owner-verified except WebBrowser. See
  `Documentation/ControlTesting.md`.
- **WebBrowser re-enabled** — one framework bug (`GetURL()` declared `ByRef As WString` returning a
  literal). `ListViewEx` and `SearchBar` stay excluded: their implementation `.bas` files were never
  shipped by MyFbFramework, which needs an upstream fix, not a local one.
- **Toolbox Cursor** now appears once rather than in all four groups.
- **Six documents** in `Documentation/`, indexed above.
- **`StageRelease.ps1` now exports `git archive HEAD`** instead of copying the working tree.

**Test these first on the other computer**

1. **Drop a WebBrowser control onto a form in the designer.** This is the one gap in its
   verification. `mff.bi` does *not* include WebBrowser, so `framework.dll` does not contain it —
   and the designer instantiates controls through that DLL (see `cc9e7dd`). A hand-written `.frm`
   using one compiles and runs correctly; whether the *designer* can place one is untested and may
   need WebBrowser adding to the DLL build.
2. **Page rendering.** Nothing has ever loaded a page in a WebBrowser control.
3. **Build any project** and confirm the DLL copying reports in the Messages pane.

**Before packaging for testers**

`StageRelease.ps1` ships what was last *committed*. Build release and commit the binaries before
staging — it warns if they differ. Staged result on this machine: **4,072 files, 286 MB**, from
commit `acea2cc`.

**Open, not blocking**

- The 73 control test projects ship under `Examples/Controls`. Owner decided to leave them for now;
  worth revisiting, since near-identical single-control stubs dilute the real teaching examples.
- The installed app still does not appear in Programs and Features (unsigned binaries — SignPath.io
  offers free signing for open-source projects and would likely resolve it).
- `Settings/astoria.ini` is tracked and must be committed whenever it changes so both machines stay
  in sync.

<a id="active-sub-project--debugger-reliability-queued-2026-07-11"></a>

## Debugger Reliability (Complete)

All DR-1 through DR-16 defects are fixed and owner-verified. This retained anchor keeps links from older historical records valid.

## Current State (2026-07-13)

- `Settings/astoria.ini` is intentionally tracked and must be committed and pushed whenever it changes so the two development computers stay synchronized.
- Tracked scratch files under the framework and DeviceExplorer were removed, the obsolete DeviceExplorer project file was deleted, and the repository-root `Temp/` folder was cleared.

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
- **`Controls/MyFbFramework/` renamed to `Controls/Framework/`** (owner request), plus `MyFbFramework.wiki` → `Framework.wiki` and `MyFbFramework.vfp` → `Framework.vfp` inside it. Scope grew from the literal 3 renames to ~140 files once every reference was tracked down: build scripts, `Main.bas`/`Main.bi`/`TabWindow.bas`/`mff.rc`/`PathUtils.bas`, `Controls/Framework/Settings.ini`'s own internal header/source/include/lib-folder keys (still pointed at the old folder name after the directory move — a real break, caught before it shipped), the `LCase(DirName) = "myfbframework"` folder-name check in `LoadToolBox` that identifies MFF for load-order purposes (updated to `"framework"`), `IsMyFbFrameworkLibrary`'s doc comment, `AstoriaIDE.vfp`/`src/AstoriaIDE.vfp`, `AstoriaIDE.code-workspace`, all ~80 `Examples/*/*.vfp` and `Templates/Projects/*.vfp` `ControlLibrary=` references (bulk `sed` replace, verified UTF-8 BOM/encoding preserved), the `Examples/MyFbFramework Examples` entry (actually a small redirect *file*, not a folder — renamed to `Examples/Framework Examples` and its content updated), and `Examples/Add-In`'s Linux-branch fallback path. Deliberately left untouched: upstream GitHub/Gitee URLs to the real `MyFbFramework` project (that's its actual name, unrelated to this fork's local folder naming), historical narrative in `HISTORY.md`/`ROADMAP.md`/`DIRECT2D_REMOVAL.md` (the latter's `git show`/`git checkout` recovery commands specifically *must* keep the old path — they target historical commits where that was the real path), prose/branding mentions of "MyFbFramework" as the library's name (Tip of the Day, generated wiki doc text, `mff.rc`'s `VER_PRODUCTNAME_STR`), and pre-existing already-broken dev tooling unrelated to this task (`.vscode/tasks.json`, `src/.poseidon`, `.claude/settings.local.json` — all still reference pre-AstoriaIDE-rename names like `VisualFBEditor.bas`, so fixing just the Framework part wouldn't make them work anyway). Live-verified twice: Form Designer renders, Toolbox shows all 5 libraries. **Note:** this rename happened concurrently with this machine's `Controls/MyFbFramework/examples/...` dead-code sweep below; merging the two re-homed those edits onto the renamed `Controls/Framework/...` paths via git's rename detection.
- **MFF DLL renamed again, `astoria.dll` → `framework.dll`, and moved back inside `Controls/Framework/`** (owner request, for consistency with the just-renamed folder): reverses the earlier root-relocation decision, and conveniently *simplifies* things back — since the DLL and its headers/sources share a folder again, `Controls/Framework/Settings.ini`'s `Lib64`/`HeadersFolder`/`SourcesFolder`/`IncludeFolder`/`Lib*Folder` keys reverted from the explicit root-relative paths back to their original plain-relative forms (`Lib64=framework.dll`, `HeadersFolder=mff`, etc.) — no more `../../` trick needed. Build scripts' `-x` output path reverted from three levels up (`../../../`) to one level up from `mff/` (`../framework.dll`), matching the pre-astoria.dll-rename convention. `IsMyFbFrameworkLibrary` restored its folder-name check alongside the filename check (both now say "framework"), since the location no longer needs a filename-only fallback. `Main.bas`'s startup `DyLibLoad`, `frmOptions.frm`'s `MFFDll`, and `Examples/Add-In`'s two samples updated to the new path. Old root-level `astoria.dll`/`libastoria.dll.a` deleted. Live-verified: Form Designer renders, Toolbox shows all 5 libraries.
- **Upstream-sync policy decided:** no standing sync strategy — given the scope of local changes across the fork (Direct2D removal, the toolbox/component-picker rework, the Framework rename, and everything else this owns now), this is treated as a totally separate project going forward, not a tracked fork of upstream `VisualFBEditor`/`MyFbFramework`. An occasional one-off sync may still happen at the owner's discretion, but there's no policy or process to establish. Removed from the deferred-enhancements list rather than left open.
- **Form Designer cold-open blank page confirmed not an issue:** owner tested it and it works correctly. Removed from the deferred-enhancements list; the earlier concern (`ROADMAP.md` §13.9, a suspected first-frame `PagePanel` cosmetic gap) doesn't reproduce.
- **New Project dialog redesigned** (`frmNewProject.frm`/`.bi`): combined what used to be a type-picker dialog plus a separate popup name-prompt (`frmNewFileName`, reused from the file-add flow) into one dialog. Below the template icon list are three inline fields — Project Name (required), Primary Form Name, Primary Module Name — with Form/Module enabling based on the selected template: both active for Windows Application (it ships a default Form and can *optionally* also get a fresh Module, sourced from the generic `Templates\Files\Module.bas` since Windows Application's own template doesn't include one), only Module active for every other template. All three fields start blank with no auto-generated suggestion (previously auto-filled "ProjectN"); Project Name is required, Form/Module Name are optional — leaving either blank simply skips creating that file rather than erroring, with the surviving file taking over the project's starred/main-file slot if only one of the two was created. `frmNewFileName`'s own dialog (still used elsewhere, e.g. adding a file to an already-open project) had its width cut in half (657→328px) as part of this pass. Along the way, found and fixed scattered non-sequential `TabIndex` values that broke Tab-key navigation between the new fields (Windows dialogs need contiguous ascending TabIndex order for `SelectNextControl`'s sort-based logic to produce a sane cycle) — renumbered to a clean 0–14 sequence matching visual order. Iterated through several rounds of live owner testing (dual-popup → combined dialog → sizing → blank-by-default → dual-active-fields-for-Windows-Application → Tab order) before landing here; all verified working.
- **Examples Chinese-comment-translation complete:** all Chinese-language comments across `Examples/` (104 of 620 tracked files — the rest had none) translated to English, meaning-preserving, code untouched. Verified by a full-tree scan for CJK characters after the edits: zero remain anywhere under `Examples/`. **Superseded for the ChineseCalendar/gdipClock/gdipGoldFish/Midi chain** by outright deletion (see the next bullet) — that translation pass only translated source *comments* in those four projects, leaving the actual rendered Chinese UI content (holiday names, month names, GanZhi characters) untouched. The comment translations in the other ~100 files stand as-is.
- **Examples translation cleanup complete:** owner decision extended the English-only mandate from IDE chrome (a510b24/e83212f) to the `Examples/`, `Controls/MyFbFramework/examples/`, and `Tools/` trees. Removed 29 `.lng`/`Languages/` translation files (plus their auto-generated `english.html` doc previews) across 17 example/tool projects — safe because `Application.CurLanguage` (`Controls/MyFbFramework/mff/Application.bas`) fails open on a missing `.lng` file (prints a message, keeps the prior/English value) rather than erroring, so every affected example still runs identically. Fixed the two `.vfp` manifests that explicitly listed their `.lng` as a `File=` entry (`Examples/Game/Calculator/Calculator.vfp`, `Examples/Game/Maze/Maze.vfp`), and removed `Examples/MDIForm/MDIMain.frm`'s `Form_Close` hook that re-wrote a `<Language>.lng` file on every exit. Separately, `Examples/ChineseCalendar` had no `.lng` file at all — its Chinese lunar-calendar content (GanZhi, zodiac, month/holiday names, some PRC-specific) was hardcoded directly into `Lunar.bi`/`LunarCalendar.bi` and actually rendered on screen, so it wasn't a simple file deletion. `Examples/gdipClock` turned out to share that same dependency (`gdipDay.bi`/`gdipMonth.bas` `#include` `ChineseCalendar/Lunar.bi` and render the same Chinese text in its Day/Month calendar views, woven hundreds of lines deep into `frmClock.frm`'s menus/settings — not a clean strip). The cascade went one level further: `Examples/gdipGoldFish` and `Examples/Midi` both `#include` gdipClock's generic (non-Chinese) `gdip.bi`/`gdipAnimate.bi` helper files, and `gdipClock` in turn `#include`s `Midi/midi.bi` back (a mutual pair) plus `Sapi/Speech.bi` and `MDINotepad/Text.bi` (one-directional, no cascade — those two stand alone). Owner decided to delete the whole chain — `ChineseCalendar`, `gdipClock`, `gdipGoldFish`, and `Midi` — rather than attempt to decouple or rewrite gdipClock's calendar feature. Confirmed via repo-wide grep that nothing else references any of the four before deleting.
- **Examples dead-code sweep complete:** owner asked to remove dead code (commented-out blocks, unused private subs/functions/variables, unreachable code, unused `#include`s/dead `.bi` declarations) from every example/tool project under `Examples/`, `Controls/MyFbFramework/examples/`, and `Tools/` — ~55 projects, done in 8 parallel batches. Net result: 130 files changed, ~2,200 lines of dead code removed, 0 whole files or working behavior touched. Safety approach: this framework wires UI event handlers explicitly via `@HandlerName` address-of casts (confirmed in `Examples/DeviceExplorer/frmDeviceExplorer.frm`), not invisible reflection, so a repo-wide grep per identifier was a reliable "is this really dead" check; every batch was instructed to flag rather than guess on anything ambiguous, and to leave vendored API/COM/protocol binding headers (COM interfaces, Scintilla/Lexilla, USB SDK ports, Mongoose, SQLite, DirectShow/DirectSound) alone since "unused" entries there are normal reference-surface, not dead code. This sweep ran concurrently with the other machine's Chinese-comment-translation pass above; merging the two meant reconciling ~17 files where both sides touched the same lines (this machine's dead-code deletion vs. the other machine's comment translation) — resolved by keeping the deletions and adopting the translated comments for whatever code survived. Notable finds surfaced along the way but deliberately left unfixed (out of scope for a dead-code pass):
  - `Examples/MultipleDisplay/Monitor.bas`: `EnumDisplayMonitorProc`'s `GetMonitorInfo` call is commented out, so `mtrMIEx(i).szDevice` is read later but never actually populated — a real latent bug.
  - `Examples/Bass/frmLiveFX.frm` (`InitDevice`): `If fx(2) Then BASS_ChannelRemoveFX(chan, fx(1))` looks like a copy-paste index bug (removes `fx(1)` instead of `fx(2)`).
  - `Examples/MDINotepad/MDIMain.frm` (`mnuFormat_Click`): `Case` lists test dead string literals `"mnuEncodingCRLF"/"mnuEncodingLF"/"mnuEncodingCR"` instead of the real control names `mnuEOLCRLF`/`mnuEOLLF`/`mnuEOLCR` — harmless today only because the correct names are also present as fallback alternates in the same `Case` line.
  - `Examples/DeviceExplorer/DeviceExplorer.bi` includes `../USBView/USBView.bi` with nothing from it referenced in DeviceExplorer's own code — but the prebuilt `DeviceExplorer64.exe` contains USBView strings, so this may be an intentional combined-build link rather than a leftover; flagged, not touched, since USBView wasn't in that batch's scope.
  - `Examples/MDIScintilla/MDIMain.frm`: `MDIChildDoubleClick` is implemented but its only call site was commented out, while the identical feature is active in sibling project `MDIScintillaControl` — reads as an intentionally-disabled feature here, left as-is pending an owner decision.
  - `Examples/IFileDialog/`: `IFileDialog.bi`'s test functions look unreachable under normal `__FB_MAIN__` semantics, but `frmIFileDialog.frm` is disabled in the `.vfp` project file while `IFileDialog.bi` is the active entry point — build-mode semantics weren't fully verified, so nothing was removed.
- Nothing is awaiting an owner response. The remaining items below are deferred or ready for a new, explicitly selected task.

## Session handoff (2026-07-13)

- Flattened `Examples` to one `.vfp` project per immediate child folder, compiled all 51 projects in owner-approved batches, retained 30 passing projects, removed 21 failures, and documented the audit in `EXAMPLES_BUILD_AUDIT.md` (`6afd4da`).
- Reconciled the numbered backlog with owner decisions: the authoritative remaining tasks are the unchecked `T01`, `T08`, `T10`, `T11`, `T12`, and `T16` entries below (`489a3ed`). `T02` (standardize variable naming) and `T13` (design-workspace status bar) were later dropped by owner decision.
- Removed tracked scratch files and the obsolete DeviceExplorer project file, cleared repository-root `Temp/`, and synchronized the tracked `Settings/astoria.ini` (`e9bc31d`).
- Documented the standing rule that `Settings/astoria.ini` must be committed and pushed whenever changed so both development computers remain synchronized (`e3f5817`).
- `main` is synchronized with `origin/main`. No tracked changes remain at handoff.
- Intentionally untracked local artifacts remain: `.claude/`, `Projects/Project3/Module1.exe`, `Projects/Project3/Temp.bas`, and six `Settings/debug_trace.*.log` files. Review or remove them only if explicitly requested.

## Session handoff (2026-07-14)

- T01 (partial): `src/` indentation standardized to tabs (three files had space or garbled mixed-tab/space indentation) and line endings normalized to CRLF, with scoped `.gitattributes` rules (`/src/*.bas`, `*.bi`, `*.frm -crlf`) so the CRLF actually persists on commit instead of being silently reverted by `core.autocrlf=true` — discovered that gap the hard way (`git add` after a plain conversion produced zero diff). `Controls/` and `Examples/` still need the same pass (`2f445e4`).
- T16 done: toolbar tooltips added to `cboBuildConfiguration`, the four Designer search boxes (Explorer/Toolbox/Properties/Events), and the code editor's `cboClass`/`cboFunction` dropdowns (`6f933f4`).
- Tools menu flattened: removed the "Advanced" submenu, Add-Ins and External Tools are now top-level items (`6f933f4`).
- Backlog reconciled: `T02` (standardize variable naming) and `T13` (design-workspace status bar) dropped by owner decision (`6f933f4`).
- Other Editors panel removed from Tools > Options > Code Editor — owner decision, since External Tools already covers per-extension launch tools. Removed entirely (panel, list view, buttons, tree node, load/save/ini wiring, the `OtherEditors` dictionary, extension-based double-click auto-launch routing, and `RunOtherEditorTool`), not just hidden. `frmPath.frm` (shared Add/Change dialog also used by Terminal Paths and Help Paths) is untouched (`2f9d513`).
- `main` is synchronized with `origin/main` as of this handoff.

## Session handoff (2026-07-14) — T12 live dark-mode re-theming

Owner-selected T12: after toggling Dark Mode in Tools ▸ Options ▸ Apply, only part of the UI re-themed live; a restart made the whole app dark. Root cause: dark mode is a single global flag (`g_darkModeEnabled`) that each MFF control picks up on its next `WM_PAINT`. At startup the flag is set before any window exists so every control paints dark; at Apply it flips on already-visible windows and relied on a desktop-wide `WM_SETTINGCHANGE` broadcast that only reaches **top-level** windows — nested controls were never invalidated or re-themed.

**Fixes landed and owner-verified (except the one glitch below):**
- **Full-tree re-theme on Apply** — `Form.ProcessMessage` now handles `WM_SETTINGCHANGE`/`ImmersiveColorSet` by calling the existing `Form.SetDark` (whose trailing `Repaint` uses `RDW_ALLCHILDREN`, cascading a fresh paint so every descendant self-flips), then `BroadcastThemeChangedToChildren` (new, in `DarkMode.bas`) to push `WM_THEMECHANGED` to every descendant window — visible or hidden — so controls that theme sub-windows re-theme too. Safe against the historical dark-mode recursion crash: the loop runs through `WM_THEMECHANGED`, and nothing in this path emits `WM_SETTINGCHANGE`, so it can't re-enter itself; per-window recursion is already cut by the `AllowDarkModeForWindow` guard.
- **Popup menus (Tools menu white-on-white after reverting to light)** — `WM_INITMENUPOPUP` set `MFT_OWNERDRAW` on popup items in dark mode but never cleared it; the owner-draw handler only paints while dark, so a reverted item rendered blank. Made the flag toggle symmetric (set in dark, strip in light). Self-healing per popup open; a no-op for anyone who never enables dark mode.
- **Tree/List headers (Properties/Events headers stayed white going to dark)** — `TreeListView`'s `WM_THEMECHANGED` handler themed the column header via `AllowDarkModeForWindow` (`"DarkMode_Explorer"`, which leaves a header light) while `SetDark` correctly uses `"DarkMode_ItemsView"`. Made the handler apply `"DarkMode_ItemsView"`/`NULL` to match `SetDark`.
- **RichTextBox on hidden tabs** — `RichTextBox` only self-flipped on `WM_PAINT`, which never fires on an unselected tab page, so a description pane toggled while hidden kept its old colours. Added a `WM_THEMECHANGED` handler mirroring its `WM_PAINT` self-flip, so the new broadcast reaches it regardless of tab.

**RichTextBox white-flash glitch — fixed** (follow-up session, same day): the Property/Event description panes (`txtLabelProperty`/`txtLabelEvent`) darkened then flashed back to white ~0.5s after switching to dark. Root cause confirmed: `EM_SETBKGNDCOLOR` was getting silently reset by the RichEdit control itself after the dark→light→dark transition, and `RichTextBox`'s `WM_PAINT` handler only re-asserted colours on the `FDarkMode` *transition* (`If Not FDarkMode Then SetDark True`), so a reset that happened while already dark was never caught. Fix: `WM_PAINT` now cheaply re-asserts `EM_SETBKGNDCOLOR` (background only, not the expensive full-text `EM_SETCHARFORMAT` reformat) on every paint while already dark, right before forwarding to the RichEdit's own paint logic, so it can never paint a stale colour. Owner-verified.

**Cold-start dark mode — two more bugs found and fixed** (owner discovered dark cold-start behaves differently than toggling dark live):
- **Properties/Events headers white on a dark cold start** — cold start relies solely on each control's own first `WM_PAINT` to self-theme (`SettingsService.LoadSettings` sets `g_darkModeEnabled` before any window exists, deliberately with no broadcast). That path turned out weaker than live Options▸Apply, which additionally sends an explicit `WM_THEMECHANGED` to every descendant via `BroadcastThemeChangedToChildren`. Fix: `Main.bas`, right after `frmMain.Show` (once the full window tree exists), if starting in dark mode, re-enters the same `WM_SETTINGCHANGE`/`ImmersiveColorSet` path Options▸Apply uses — so a dark cold start ends up in the identical state as toggling dark after launch. Owner-verified (one minor residual: headers can flash white for ~0.5s before this cascade lands; deferred as a low-priority cosmetic item, not re-opened as a task).
- **Tools menu white-on-white, but only after a dark cold start then switching to light** (menu was fine if the app cold-started light, or if dark was toggled live) — root cause was *not* the owner-draw flag math (`MFT_OWNERDRAW` toggling in `WM_INITMENUPOPUP` was verified correct via instrumented tracing in every case). The real bug: `SetMenuItemInfo` there was scoped to `fMask = MIIM_FTYPE` only. Toggling `MFT_OWNERDRAW` with that narrow mask let Windows silently drop the item's cached display string once it became owner-draw, so reverting to classic (`MFT_STRING`) rendering left nothing to draw — invisible/"white on white" items. Fix: widened `fMask` to `MIIM_FTYPE Or MIIM_BITMAP Or MIIM_STRING Or MIIM_ID` so the string/bitmap/ID are re-supplied alongside the flag flip. Owner-verified across repeated dark↔light cycles.

T12 is now complete for all practical purposes — see Open Items below for the one deferred cosmetic flash.

Build/verify: framework changed, so rebuild with `FORCE_MFF=1 NOPAUSE=1 Compile.bat` (close the IDE first); owner live-verifies dark↔light toggles.

## Session handoff (2026-07-14) — T10 + T11 dark-mode popup menus and dialogs

Owner-selected T10 then T11, the two remaining items in the dark-mode area after T12. Both done and owner-verified; see their entries under Open Items → Deferred enhancements above for the full account of each (T10: three rounds fixing the main menu bar, then context/toolbar-dropdown menus, then checkmark/radio/arrow glyph rendering; T11: an extended native-MessageBox theming attempt that hit an unresolvable DWM-level rendering issue, then a pivot to a custom `Form`-based `MsgBoxForm` that sidesteps the problem entirely). `main` was not pushed this session; framework changed, so rebuild with `FORCE_MFF=1 NOPAUSE=1 Compile.bat`.

## Session handoff (2026-07-14) — T08 Windows installer

Owner-selected T08. Full account under Open Items → Deferred enhancements above. Shipped: `StageRelease.ps1` (release-tree staging), `AstoriaIDE.iss` (Inno Setup packaging, Inno Setup 6.7.3 installed this session to build/test it), `BuildInstaller.ps1` (combined one-command build), a corrected `license.txt`, and an installer-side fix for `ProjectsPath` defaulting into a hidden folder. Verified end-to-end via a real clean install/uninstall cycle, not just a compile-clean check. One limitation investigated at length but deliberately not resolved this session: the app doesn't appear in Control Panel/Settings' installed-apps lists, most likely due to being unsigned — see the T08 entry for what was ruled out (Smart App Control, registry redirection) and what's still open (a Help topic documenting Start Menu launch/uninstall; possible future code-signing via SignPath.io).

## Session handoff (2026-07-14) — Context menu parity with toolbars

Owner-requested (personal accessibility preference — dislikes using icon/tool bars): audit the code pane's and Form Designer's right-click context menus and add whatever toolbar commands they were missing, so every toolbar action is also reachable by right-click.

- **Code pane (`mnuCode`, `src/TabWindow.bas`) — done, owner-verified.** Added Undo, Redo, Find, Format, Unformat, Toggle Comment, Complete Word, Parameter Info, Syntax Check, Suggestions — all dispatched via the existing shared `@mClick` handler and using the `HK()` helper (`Localization.bas`) so a user-customized hotkey still shows correct text next to each item. Owner confirmed this menu looks correct.
- **Form Designer (`mnuDesigner`, `src/Designer.bas`) — implemented, compiles clean, but NOT working as intended; owner reports "nothing much added" when right-clicking with a control selected.** Added an Align / Make Same Size / Size to Grid / Horizontal Spacing / Vertical Spacing / Center in Parent block (mirroring the Designer menu's own submenu structure) between the existing `Duplicate` item and `OrderSeparator`, bounded by two new separator keys `FormatSeparator1`/`FormatSeparator2`, all dispatched via `@mClick` (confirmed `PopupClick`, `mnuDesigner`'s other handler, only recognizes a small fixed command set and doesn't know these — `@mClick` is the same dispatcher the top menu bar/Format toolbar already use for these exact command strings). Added matching `Visible = True/False` toggle lines for all eight new keys in `Designer.ChangeFirstMenuItem` (~`src/Designer.bas:114`), following the exact pattern already used for `Copy`/`Cut`/`Delete`/`Duplicate`/etc. Build is clean (0 errors) and the toggle logic reads correctly on inspection, but the owner's live test showed no visible change. **Not debugged further this session — out of time/credits.** Next session should:
  1. Confirm `ChangeFirstMenuItem` is actually being called on the right-click path the owner used (call sites: `src/Designer.bas:1687`, `:2324`, `:2534`) — it's possible one interaction path (e.g. right-click without first left-clicking to select) shows the menu before `ChangeFirstMenuItem` runs, leaving stale `Visible` state from a prior bare-background popup.
  2. Check whether giving `@mClick` a handler on a submenu *header* item (e.g. `Align`, `MakeSameSize`) conflicts with the framework's submenu-arrow/flyout behavior — the existing convention for a header-only item (see `mnuCode`'s `Toggle` submenu, `src/TabWindow.bas`) passes no handler at all (`mnuCode.Add(("Toggle"), "", "Toggle")`, 3 args, not 4). Try dropping `@mClick` from the six new header items (`Align`, `MakeSameSize`, `HorizontalSpacing`, `VerticalSpacing`, `CenterInParent`; `SizeToGrid` has no submenu so keep its handler) as the first thing to try.
  3. If still not visible, add temporary instrumented logging (or a debugger breakpoint) inside `ChangeFirstMenuItem`'s `Else` branch to confirm the `Item("Align")` lookups aren't silently failing (e.g. key typo/collision) before the `->Visible = True` assignment.
- Rebuilt clean via `Compile.bat` (framework.dll unchanged, astoria.exe rebuilt, 0 errors). Not committed until this handoff.

## Session handoff (2026-07-15) — Dark mode fully removed

Owner decision: **remove dark mode entirely, for stability.** The trigger was a dark-mode-only context-menu render bug (dark popup submenus after the first rendered empty — instrumentation proved the menu *data* was correct, so it was purely a dark owner-draw paint fault), on top of a history of dark-mode-only glitches (T10/T11/T12). Rather than keep chasing owner-draw quirks, the whole dark-mode structure was deleted. Owner directive: "hard-disable plus remove as much code as you can safely… be as aggressive as you can safely be and document where the remaining code is."

**Approach (safety-first):** first pinned `g_darkModeSupported = False` so every dark path became provably unreachable and compiled/ran in a verified light-only state; then deleted the now-dead code in waves, compiling between each. Net result: **68 files changed, ~2,650 lines removed, 4 files deleted; 0 dark-mode references remain anywhere** in `src/` or the framework, and the build is clean (framework.dll + astoria.exe) and launches.

**What was removed:**
- **IDE (`src/`):** the Tools ▸ Options **Dark Mode** checkbox (`frmOptions.frm`/`.bi`) and its load/save; the `DarkMode` INI read + `InitDarkMode`/`SetDarkMode` calls (`SettingsService.bas`); the `DarkMode` global (`Main.bi`); the cold-start dark re-theme cascade and `InitDarkMode` call (`Main.bas`); per-control dark branches in `EditControl.bas` (divider colors, tooltip theming, scroll-bar theming, `EditControl.SetDark`), `TabWindow.bas`, `frmMenuEditor.frm` (designer-preview text colors), and `frmTipOfDay.frm` (the `"D"` dark tip-image suffix).
- **Framework menu owner-draw (the actual bug source):** the entire dark `WM_INITMENUPOPUP` / `WM_MEASUREITEM`(ODT_MENU) / `WM_DRAWITEM`(ODT_MENU) owner-draw system in `Control.bas`, `Form.bas`, `ToolBar.bas`, plus Form's `WM_UAHDRAWMENU`/`WM_UAHDRAWMENUITEM` menu-bar painting and its `WM_SETTINGCHANGE`/`WM_THEMECHANGED` live re-theme cascade (`BroadcastThemeChangedToChildren`).
- **The `SetDark` virtual hierarchy:** all 11 `X.SetDark` method definitions, all 13 `Declare Virtual Sub SetDark` declarations, and every `SetDark` call site / WM_PAINT dark trigger across ~20 control files.
- **Per-control dark custom-draw:** dark colour branches in Grid/ListView/TreeListView (headers, `WM_THEMECHANGED`), TabControl, ReBar, OpenFileControl, StatusBar, TreeView, TrackBar, NumericUpDown, ComboBoxEx/Edit, ProgressBar, GroupBox, SearchBox, RichTextBox, etc. (dark-only `If` blocks removed; `If/Else` collapsed to the light branch; `IIf(g_darkModeEnabled, dark, light)` simplified to the light value).
- **Globals/module:** the `DarkMode/` folder deleted outright (`DarkMode.bas`, `DarkMode.bi`, `UAHMenuBar.bi`, `Themes.txt`); the dark colour/brush globals in `Brush.bi`/`Brush.bas` (`darkBkColor`, `darkTextColor`, `hbrBkgnd`, `hbrHlBkgnd`, `hbrBkgndMenu`, and the now-dead `g_brItemBackground*`/`g_menuTheme`); `Application.DarkMode` property + `FDarkMode` field; the `#include`s of the deleted headers; and the `FDarkMode`/`FComboBoxDarkMode`/`FReBarDarkMode` fields.

**Intentional preservations / side effects (the "document the remainder" part — there is no live dark code left, only these adaptations):**
- The **user ForeColor/BackColor feature is untouched.** CheckBox/RadioButton custom-draw ran for *both* dark mode and a user-set `FForeColor`; the condition was simplified from `(g_darkModeSupported AndAlso g_darkModeEnabled OrElse FForeColor <> 0)` to `(FForeColor <> 0)`, and the disabled-text colour that was `darkHlBkColor` is now the literal `&H626262` (same grey). RichTextBox still re-asserts `FForeColor`/`FBackColor` after `EM_SETTEXTEX` (kept; comment de-darkened). Grid/ComboBoxEx custom colours preserved via their light-branch values.
- `nullptr` (a `#define nullptr 0` that happened to live in the deleted `DarkMode.bi`) was replaced with `NULL` at its 4 remaining framework call sites.
- The `frmOptions.frm` "Interface Colors" theme-ini reader kept its default values by inlining the former dark-colour constants as literals (`&H303030`, `&H626262`, `BGR(255,255,255)`); its `[Colors]` ini keys are still named `DarkBackground`/`DarkBackgroundHighlight` (theme-file key names, not dark-mode code) — harmless, left as-is.
- A stale `DarkMode=true` key may remain in a user's `Settings/astoria.ini`; it is simply ignored now (no reader). `astoria.ini` was **not** committed with this work (its diff was incidental test-run window/MRU state).
- `src/EditControl2.bi` is an orphaned, non-`#include`d duplicate (listed only in `AstoriaIDE.vfp`) and still contains a stale `SetDark` decl — it does not compile, so it is inert; left untouched as pre-existing dead file.
- `SysUtils.bas` keeps `WM_UAHDRAWMENU`/`WM_UAHDRAWMENUITEM` entries in its numeric message-name debug table (generic, not dark infrastructure).

Owner-verified (build compiles clean, launches, no Dark Mode checkbox in Tools ▸ Options ▸ General, app behaves correctly).

## Session handoff (2026-07-15) — New Project dialog: Author/License/Git/AI-friendly fields

Owner-requested: expand the New Project dialog (`src/frmNewProject.frm`/`.bi`) with four new fields — Use Git (checkbox), Git URL (entry field, same line as Use Git), Author (defaults from Options ▸ Personal Information ▸ Name), a License dropdown, and Make project AI friendly (checkbox). Owner-verified live and confirmed "looks good."

**Scope decisions made up front** (owner chose, before implementation): Git URL is stored as project metadata only — **no `git` commands are ever run** by Astoria itself. License selection writes a real `LICENSE` file into the new project folder. "Make project AI friendly" is captured as a flag only for now — **no file is generated yet**; what it should produce is explicitly deferred to a later session ("we'll wire everything up needed for the git and ai project entries later").

**What was built:**
- Dialog expanded 480×290 → 480×418 to fit four new stacked rows, inserted after the existing Primary Module Name row and before the OK/Cancel/Open Existing button row: **Author** (TextBox, pre-filled from `*PersonalName` in `Form_Create`, editable per-project), **License** (`ComboBoxEdit` with `Style = ComboBoxEditStyle.cbDropDownList` so it's pick-only, not free-text — options `GPL, LGPL, Apache, MIT, Mozilla, BSD, Freeware, Proprietary, Other`, defaults to GPL), **Use Git + Git URL** (checkbox + TextBox on one row, TextBox `Enabled` gated by the checkbox via a new `chkUseGit_Click` handler — mirrors the existing `chkLicenseOther`/`txtPersonalLicenseOther` pattern in `frmOptions.frm`), **Make project AI friendly** (standalone checkbox).
- `TabIndex` renumbered to a clean contiguous 0–25 across the whole form (verified via grep + sort — the project's established convention, see the 2026-07-14 New Project dialog history above and its `SelectNextControl` Tab-cycle rationale).
- On OK, after the existing project-folder/`.vfp` creation logic completes (unchanged), a new block appends `Author=`, `License=`, `UseGit=`, `GitURL=`, `AIFriendly=` as plain `Key="value"` lines to the generated `.vfp`, in the same flat key=value format the template already uses for `CompanyName=`/`ProjectDescription=`/etc. Confirmed safe: `AddProject`'s `.vfp` key parser (`Main.bas`, ~line 974) is a long `If/ElseIf Parameter = "..."` chain with no matching branch for these new keys and no final catch-all `Else` — an unrecognized key is simply skipped, exactly like any other key the loader doesn't yet know about. Nothing reads these new keys back yet (deliberately out of scope — no Project Properties UI change was requested or made).
- New `WriteLicenseFile` sub (`frmNewProject.frm`) writes a `LICENSE` file for every option except "Other" (which writes nothing, matching the existing free-text "Other" convention already used for the license checkboxes in Options): full text embedded for **MIT** and **BSD** (both short, standard, safe to vendor verbatim); the license's own official short-form notice + canonical URL for **GPL/LGPL/Apache/Mozilla** (the usual convention — their full legal text runs to tens of KB and is meant to be fetched from the authoritative source, not duplicated per-project); a short plain-language notice for **Freeware/Proprietary**.
- `frmNewProject.bi`: added `#include once "mff/CheckBox.bi"` and `"mff/ComboBoxEdit.bi"`, new control `Dim`s, and the `WriteLicenseFile`/`chkUseGit_Click` declarations.

**One implementation pitfall hit and fixed:** FreeBASIC's built-in `IIf` doesn't support `String`-typed return values cleanly (`error 24: Invalid data types`) — every `IIf(cond, "true", "false")`-shaped expression (used for the boolean-to-string metadata lines, and originally for a `HolderName` fallback in `WriteLicenseFile`) had to be rewritten as an explicit `If/Else` assignment instead. Worth remembering for any future boolean→string conversion in this codebase — this framework's own code never returns a `String` from `IIf` either, only numeric/enum values, which is presumably why this hadn't been hit before.

**Explicitly NOT done this session (owner-deferred to later):** no `git init`/`git remote` execution, no LICENSE-file-content editing UI, no Project Properties display of the new fields, no CLAUDE.md/AI-scaffold generation. These are open follow-ups — see Open Items below.

Build/verify: framework unchanged (IDE-only source), rebuilt via `Compile.bat` (no `FORCE_MFF=1` needed), 0 errors, owner live-verified in the running IDE (dialog layout, tab order, Author pre-fill, License dropdown lock, Git URL enable/disable gating).

## Session handoff (2026-07-15) — Project Setup Templates: scaffolding + New Project Description/AI dropdown

Continues the Project Setup Templates feature (full plan: [PROJECT_SETUP_PLAN.md](PROJECT_SETUP_PLAN.md)).

**Template scaffolding shipped** (commit `894598f`) under `Templates/` — stampable, ship-with-the-app content (tokens `{{PROJECT}} {{AUTHOR}} {{YEAR}} {{DATE}} {{LICENSE}}`):
- `Templates/Licenses/*.txt` — 8 licenses extracted verbatim from `WriteLicenseFile` and tokenized (Task 1 essentially pre-done).
- `Templates/Git/` — `gitignore.txt`, `gitattributes.txt` (`* text=auto`), per-host wizard guides + `sshkeys.md` (public key only).
- `Templates/Readme/README.md` — tokened front-door with a "Status / Next steps" section (the lightweight stand-in for a per-project status doc; **owner decided end-user projects do NOT need a full PROJECT_STATUS** — a README section covers it).
- `Templates/AI/<tool>/` — per-tool assistant guidance (ClaudeCode complete; Cursor/ChatGPT/OpenCode/Kun are starter scaffolds — see "AI template folders" below).
- `PROJECT_SETUP_PLAN.md` gained **Task 8** (post-creation Project Properties editor, commit `f2b28a7`).

**New Project dialog — Description + AI Agent dropdown** (`frmNewProject.frm`/`.bi`):
- **Project Description** — multiline (vertical scrollbar) field; **label-above, full-width**, positioned as the **last field** just above the buttons. Persisted to the `.vfp` as `Description="…"` with newlines encoded as `\n` (same technique as the Personal-Info Address field).
- **AI Agent** dropdown on the "Make project AI friendly" row (label "AI Agent:"): Claude Code (default), Cursor, ChatGPT (Codex), OpenCode, Kun (Deepseek); **disabled until the checkbox is ticked** (gated like Use Git → Git URL). Persisted as `AITool="…"`.
- Layout: `URL:` label added to the Git row (right-aligned; field aligned to the 150px column like the others); all inline labels vertically centered via `CenterImage` (SS_CENTERIMAGE) rather than a fixed top margin; `TabIndex` renumbered to the new order (Author → License → Git → AI → Description → buttons).
- Owner: "looks good"; a couple of minor alignment tweaks the owner will handle manually.
- Build: IDE-only, rebuilt via `Compile.bat` (no `FORCE_MFF`), 0 errors, owner-verified live.

Still deferred (see the plan): the token-substitution/stamping helpers (Task 0), wiring the AI-tool/Git/README stamping (Tasks 2a/3/4), the Git setup wizard (Task 5), and the Project Properties editor (Task 8).

## Session handoff (2026-07-15) — New Project dialog: Git wiring, provider/username/email fields, and a framework Z-order fix

Continues directly from the two sessions above. **Not yet owner-verified end-to-end** — the final rebuild finished right as the owner had to step away, so next session should live-test before trusting this. Build is clean (0 errors) as of commit time.

**Git/AI-friendly wiring** (`src/frmNewProject.frm`/`.bi`): the fields captured metadata only before this session; they now do real work on OK.
- **AI-friendly** stamps `Templates/AI/<mapped-tool-folder>/` into the new project, substituting `{{PROJECT}}`/`{{AUTHOR}}`/`{{YEAR}}`/`{{DATE}}`/`{{LICENSE}}`/`{{DESCRIPTION}}` in every file (`StampAITemplate`/`CopyTemplateTree`/`StampTemplateFile`), skipping `.gitkeep` placeholders.
- **Git**: the dialog's free-typed **Git URL** field was removed entirely (owner request, mid-session) and replaced with three fields — **Git Provider** (dropdown: GitHub/GitLab/Bitbucket/Codeberg — Gitea/Forgejo/SourceHut/SourceForge deliberately left out, see below), **Git Username**, **Git Email** (defaults from Options ▸ Personal Information ▸ E-mail, stays editable). `BuildGitURL` constructs `git@<host>:<username>/<project>.git` from those plus the project name; `GitProviderHost`/`GitProviderGuideName` map the dropdown label to its fixed public domain and matching `Templates/Git/*.md` guide. Git Username is required if Use Git is checked.
- When Use Git is checked, a **preflight `git ls-remote` existence check** (`RemoteRepoExists`, run from a temp `.bat` in `Temp\` so its exit code can be captured — `PipeCmd` itself returns nothing) runs before any project files are created. If the repo doesn't exist yet, a Yes/No/Cancel warning dialog offers: **Yes** — I've created it, continue; **No** — continue without Git (unchecks Use Git, clears the fields); **Cancel** — stop and return to the New Project dialog with nothing written to disk. This runs uniformly for **all four providers** (owner decision, extending an initial GitHub-only scope), gated only on an SSH key existing at `%USERPROFILE%\.ssh\`.
- If the key exists, `SetupGitRepository` runs `git init`/`config user.name`/`config user.email` (from the dialog's own Username/Email, local to that repo only, never `--global`)/`add .`/`commit -m "Initial commit"`/`branch -M main`/`remote add origin` from a temp `.bat` in `ExePath\Temp` (not the project folder itself — see bugs below). **Deliberately stops short of `git push`** — that's treated as a separate, explicit, owner-driven action, not part of project creation.
- No SSH key → no automation; a message box points at the matching `Templates/Git/*.md` guide (falls back to `other.md` for Bitbucket, since no `bitbucket.md` exists yet — flagged as a follow-up, not written this session).
- `.vfp` metadata gained `GitProvider=`/`GitUserName=`/`GitEmail=` alongside `Author=`/`License=`/`Description=`/`UseGit=`/`GitURL=`/`AIFriendly=`/`AITool=`.

**Real bugs found and fixed along the way** (each confirmed by direct reproduction, not just code reading):
1. **`git commit` silently producing zero commits** on a machine with no global `git user.name`/`user.email` configured — `git init`/`add`/`remote add` all succeeded, but the commit step failed non-interactively with no visible error. Fixed by setting repo-local identity from the dialog's fields before committing (see above).
2. **A UI-thread hang risk in the git setup script invocation**: the first draft called `PipeCmd Chr(34) & batPath & Chr(34), True`, but `PipeCmd`'s `UseShell:=True` path already wraps its argument in `cmd /c "..."` — the extra manual quotes doubled into `cmd /c ""<path>""`, which cmd.exe can misparse into a stray interactive shell that never exits, and `PipeCmd` waits `INFINITE` on that process. Fixed by passing the raw path and letting `PipeCmd` add the one quote pair, matching every other `UseShell:=True` call site in the codebase.
3. **The git setup `.bat` script leaking into the repo's first commit**: it was originally written inside the new project folder itself, so `git add .` staged it (and `git commit` then included it) before the trailing `Kill` ever ran. Moved to `ExePath\Temp` instead.
4. **The actual root cause of "the repo-existence warning dialog flashes and disappears / ends up hidden behind other windows"**: `Application.MsgBox` (`Controls/Framework/mff/Application.bas`) always passed `pApp->MainForm` as the message box's owner, never whatever dialog was actually active and modal on top (here, the New Project dialog) — first suspected as a stray-Enter-key-repeat auto-dismissing the dialog (a real, separate, now-also-fixed risk — see below — but not the actual cause here). Tried switching the owner to `pApp->ActiveForm` first; that alone didn't fix it (still ended up behind *both* the New Project window and the main window) because `MsgBoxForm` is a `Static` (app-lifetime-persistent) instance whose real Win32 owner is only ever set once, at its *first* `CreateWnd` call — `CreateWnd` is a no-op on every later call once `FHandle` already exists, so changing which Form gets passed as `OwnerForm` on a later call changes `FParent` bookkeeping (affects `CenterToParent`) but not the actual native owner/z-order relationship. The real fix: `Form.ShowModal()` (`Controls/Framework/mff/Form.bas`) now explicitly calls `SetWindowPos(..., HWND_TOP, ...)` and `SetForegroundWindow(...)` right after making itself visible, forcing correct z-order/focus regardless of the owner-reuse quirk. **This is a framework-wide change affecting every modal dialog in the app, not just this one** — worth a broader spot-check next session (Options, Find/Replace, project/file delete confirmations, etc.), not just the Git warning box.
5. **Defensive, smaller fix kept alongside #4**: a held Enter key (since the New Project OK button is `Default=True`) can leave repeat `WM_KEYDOWN(VK_RETURN)` messages queued right as a follow-up dialog opens, which would land on *its* own default button the instant its modal loop starts pumping. `cmdOK_Click` now drains (not dispatches) pending keyboard messages via `PeekMessage(..., PM_REMOVE)` immediately before showing the repo-existence warning. This didn't turn out to be the actual bug hit this session, but it's a real class of risk worth keeping the guard for.

**Not done / explicitly out of scope this session:**
- No `Templates/Git/bitbucket.md` guide yet (falls back to `other.md`).
- No GitHub/GitLab/etc. API-based repo auto-creation — Astoria only wires up a *local* repo pointing at a remote the user creates first (matching every `Templates/Git/*.md` guide's own manual steps). Auto-creating the remote repo itself would need a token or an authenticated CLI (e.g. `gh`), which isn't part of this codebase.
- Gitea/Forgejo (self-hostable, no single fixed public domain) and SourceHut/SourceForge (different URL shape entirely — `~user/repo` and project-path-based, respectively) were deliberately left out of the provider dropdown.

**Build/verify:** framework changed (`Controls/Framework/mff/Application.bas`, `Form.bas`), so rebuilt with `FORCE_MFF=1 NOPAUSE=1 Compile.bat` — 0 errors. **Owner has not yet live-verified this session's changes** (git automation across providers, the existence-check dialog, AI stamping, or the Z-order fix's effect on other dialogs) — treat all of the above as implemented-but-unverified until that happens. **Update 2026-07-16: the "Z-order" symptom's real root cause was found and fixed — see the next handoff section; it was never a z-order bug at all.**

## Session handoff (2026-07-16) — MsgBox was silently non-modal on its first use per run (the real "Z-order" bug)

Owner re-tested the Repository Not Found warning and it still misbehaved after both prior fixes (the one-shot `SetWindowPos(HWND_TOP)` from `987e8b7` and an uncommitted `GWLP_HWNDPARENT` re-own attempt). Root cause was pinned with temporary trace instrumentation (`ShowModal` entry/exit, `WM_ACTIVATE`, `WM_WINDOWPOSCHANGED` logging to a file), which produced a decisive timeline. Fixed in `84d066a`, owner-verified live.

**The actual bug — nothing to do with z-order:** the **first `MsgBox` of every app run was silently non-modal.**
1. `MsgBoxForm.Execute` pre-creates its window (`This.CreateWnd`) so the message text can be measured via the window's font/HDC before layout.
2. `Control`'s constructor defaults `FVisible = True`, and `Control.CreateWnd` ends with "if FVisible, show the form" — so the box appeared on screen, **visible and activated, in the middle of Execute's setup** (the owner-observed "briefly appears in the top position").
3. `Form.ShowModal()` begins with an already-visible guard (`If IsWindowVisible(FHandle) Then SetFocus : Exit Function`) — it early-exited: **no modal loop, no form disabling, and an immediate garbage return value** (`Exit Function` without setting a result → 0).
4. In the New Project Git flow, that garbage result fell into `cmdOK_Click`'s `Case Else` → `Me.BringToFront` — and since the New Project dialog is *owned by* frmMain, Windows raised the **owner group as a unit** over the unowned, stranded box: the "sinks two layers back, behind both windows" symptom. (Before the `BringToFront` was added, nothing raised the pair, hence the older one-layer-behind variant.)
5. **Only the first `MsgBox` per run was affected** — later calls find `Handle <> 0`, skip the pre-create, and run genuinely modally. This is why T11's owner verification passed (a stranded box still *looks* functional: the app's main message pump delivers its button clicks, the box closes on click — you can't see that `MsgBox` already returned), and why both prior "fixes" appeared not to work: **they sit after the early exit and never executed in the failing scenario.**

**The fix (one real line, `MsgBoxForm.bas`):** set `This.Visible = False` before the measurement `CreateWnd`, so the window is created hidden and `ShowModal` runs its normal path. The `GWLP_HWNDPARENT` re-own in `Form.ShowModal()` was kept (with a corrected comment): the singleton's window is created before any `OwnerForm` is known, so its native owner is otherwise missing/stale, and Windows z-orders owned windows as a group relative to their owner. The prior `SetWindowPos(HWND_TOP)`/`SetForegroundWindow` calls also remain. All trace instrumentation was removed before commit.

**Owner-verified live:** the Repository Not Found dialog appears on top of the New Project dialog, stays there, is truly modal, and Yes/No/Cancel return real results.

**Implication worth spot-checking sometime:** every result-consuming confirmation in the app (file-delete prompts, save-on-close, etc.) was in this bug's blast radius whenever it happened to be the session's first message box — each would have proceeded with answer 0 (→ `mrOK` via `MsgBox`'s `Case Else` mapping) regardless of what the user clicked. Worth keeping in mind if any past "it ignored my answer" weirdness gets reported.

**Debugging lesson recorded for next time:** the first instrumentation pass wrote its trace to a CWD-relative path — a native file dialog (`GetOpenFileName` etc.) changes the process CWD, which silently dropped exactly the trace lines that mattered. Framework-side trace logging must use an absolute path (e.g. `ExePath & "\Settings\..."`).

## Session handoff (2026-07-16, later) — Git flow: Yes re-checks the remote, .gitignore/.gitattributes stamped, initial-commit ordering fixed

Same day, continuing directly from the MsgBox fix above — with the warning dialog finally functional, live testing of the Git flow surfaced three gaps, all fixed in `787cc6d` and owner-verified (Cancel/No/Yes-recheck live; Yes-path git results inspected on disk):

- **Yes now re-checks instead of trusting.** Owner report: answering Yes ("I've created it") just proceeded, so a still-missing remote produced the same local-only outcome as No. The existence check + warning is now a loop — Yes re-runs `git ls-remote`; only an actual success lets creation and Git setup proceed, and a repeat failure re-shows the warning with a "STILL could not be found" lead-in (button text now "I've created it -- check again and continue").
- **`Templates/Git/gitignore.txt`/`gitattributes.txt` were shipped (`894598f`) but never referenced by any code.** New `WriteGitSupportFiles` stamps them into the project as `.gitignore`/`.gitattributes` (token-substituted) whenever Use Git is checked, per the original plan (`PROJECT_SETUP_PLAN.md` Task 3's "stamped in as" intent).
- **Ordering bug: `SetupGitRepository` (`git add .` + initial commit) ran before `StampAITemplate`,** so AI-friendly files would have missed the initial commit. AI stamping and the git support files now both run before Git setup; a comment in `cmdOK_Click` records the constraint for anything added later.

**Verified on disk** (owner's `Projects/TestA` Yes-path run): initial commit contains all five files including `.gitignore`/`.gitattributes`, `{{PROJECT}}` token substituted, `origin` remote set, repo-local (not global) `user.name`/`user.email` from the dialog fields, clean status. No-path projects (`Test10`/`TestB`): created without git, `UseGit=false` in `.vfp`. Cancel: nothing written.

**AI-friendly stamping verified, and it caught a third bug (fixed in `86948b5`):** the owner's first AI-checked run (a Windows Application project) produced correct `CLAUDE.md`/`AGENTS.md`/`resources/` with all tokens substituted — but its `.vfp` lost the entire appended metadata block (`Author=`…`AITool=`). Cause: those ten keys were **write-only** — `AddProject`'s parser deliberately skipped them (a recorded 2026-07-15 "out of scope" decision) and the project writer regenerates the `.vfp` purely from the in-memory `ProjectElement`, so the IDE's first project save dropped them all. Windows Application projects hit this instantly (creation opens the Form Designer, which triggers a save); the earlier Console-template tests only kept their metadata because nothing ever re-saved them. Fix: ten matching `ProjectElement` fields (`TabWindow.bi` + destructor), parser branches, and writer lines (`Main.bas`) — writer uses `WGet` (not `*`) since pre-existing projects and all template `.vfp`s have null pointers for these. Owner-verified: `TestAI3` keeps all ten keys after the IDE's own save demonstrably rewrote its `.vfp` (writer-added `Manifest=` key present), `AIFriendly=true`/`AITool="Claude Code"` intact. **Rule for the future: any new `.vfp` key must be added to the parser AND writer in `Main.bas` at the same time it's introduced, or the first save eats it.**

**Minor recorded nit:** after answering No, the `.vfp` metadata still records the `GitUserName=` typed before the No cleared the field (the metadata block uses variables captured before the dialog); harmless, fix only if the owner cares. **Local test artifacts:** `Projects/Test10`/`TestA`/`TestB`/`TestAI`/`TestAI3` (and a `TestA` repo on the owner's GitHub) are disposable leftovers from this verification.

## AI template folders — complete (2026-07-16)

All five `Templates/AI/<Tool>/` folders now carry a **default rules + skills set** (`2a515c9`, owner-verified) — the starter-scaffold phase is over. These files get **stamped into a newly created end-user FreeBASIC project** when "Make project AI friendly" is checked, written for a beginner using that tool on a FreeBASIC project (NOT for Astoria's own repo).

- **Shared canonical `AGENTS.md`** (identical baseline in all five folders, deliberately kept in lockstep): rules — FreeBASIC language rules (incl. `IIf` can't return `String`), build/run facts verified by real compiles (IDE **F5** preferred; `fbc` rejects `.frm` as direct input; GUI CLI needs `-i Controls\Framework` and the IDE-generated `.rc`), Astoria project rules (`.vfp` manifest sync, IDE-maintained metadata keys, designer-managed `.frm` regions, hands off `Temp/`/exes/change log), editing discipline, VCS conduct — plus five task playbooks: build-run, add-module, add-control-event (wiring pattern from `Examples/Calculator`), add-form (main-form bootstrap rule, Show/ShowModal), fix-compile-errors (real fbc error numbers).
- **Per-tool native conventions on top:** ClaudeCode → `CLAUDE.md` + **15 native `.claude/skills/*/SKILL.md` skills** (shared set + `use-astoria-mcp` + `git-workflow`; also carries the upgraded BOM/`ReDim`/`project.astoria`/testing baseline); Cursor → `.cursor/rules/` + `.cursorrules` + **15 native `.cursor/skills/*/SKILL.md` skills** + `.cursor/mcp.json` (**mirrored to ClaudeCode parity 2026-07-19**, including `git-workflow` and the same rule upgrades; MCP config format verified); ChatGPT (Codex) → `AGENTS.md` plus 13+ native `.agents/skills/*/SKILL.md` skills (needs the git-workflow / baseline mirror pass); Kun → full `SKILL.md` + `AGENTS.md` + **13 native `.kun/skills/*/SKILL.md` skills** (still needs the same mirror); OpenCode → `AGENTS.md` + `opencode.json` + **13 native `.opencode/skills/*/SKILL.md` skills** (still needs the same mirror).
- **Tokens** (`{{PROJECT}}`/`{{AUTHOR}}`/`{{YEAR}}`/`{{DATE}}`/`{{LICENSE}}`/`{{DESCRIPTION}}`) are used throughout, never hardcoded; each folder keeps a `resources/` for extra per-project context. Owner-verified live (`TestAI4`): the `.claude/` dot-folder tree stamps correctly with all tokens substituted.
- **Maintenance rule:** edit the shared baseline in **all five** `AGENTS.md` files (and per-tool mirrors) together — see [Templates/AI/README.md](Templates/AI/README.md).
- **MCP added to all five (2026-07-17):** each folder gained a `use-astoria-mcp` skill (drive the live IDE via the `astoria` MCP tools instead of manual F5/CLI), an MCP-first note in `build-run`/`AGENTS.md`/`CLAUDE.md`, and an MCP server config in the tool's native place — Claude `.mcp.json`, Cursor `.cursor/mcp.json`, OpenCode `opencode.json` `mcp` block; ChatGPT/Codex and Kun carry it in the skill's "Connecting" section (their client formats are global/unverified). Configs use a new `{{ASTORIA_MCP_EXE}}` token, **not yet wired into the stamping substitution helper** (add it with the Project Setup Templates work; the IDE knows the path from `ExePath`). **Cursor MCP config verified 2026-07-19** (`.cursor/mcp.json` / `mcpServers` / local `command` shape matches current Cursor docs). Remaining: ChatGPT/Codex and Kun owning-agent verification.

Same session: found and fixed (`9ca88b6`) a dead `App.DarkMode = True` in **both new-project templates** — left over from the 2026-07-15 dark-mode removal, it made every new Windows Application project fail with `error 18: Element not defined` (verified by standalone `fbc64` compiles both with and without the line). **The matching `Examples/` sweep is also done (`51bd45a`, ran as a spun-off task session):** 68 files lost their single dead bootstrap line; 8 projects (DeviceExplorer, USBView, FileBrowser, MediaPlayer, Sudoku, Hash ×2 forms, MDIForm) had the whole dark-mode toggle feature removed (menus, toolbar buttons, handlers, ImageList/`.rc` entries, 3 PNG resources). Verification (26/26 touched projects compile clean) surfaced and fixed three more pre-existing breakages: the `nullptr` define that lived in the deleted `DarkMode.bi` (both `frmSpRecognizer.frm` copies → `NULL`), FileBrowser's include of removed `../MDINotepad/FileAct.bi` (→ Hash's identical copy), Hash's missing `ITL3.bas` (restored from history), plus the accidentally-deleted `DeviceExplorer.vfp` from `e9bc31d` (restored, owner decision). Zero `DarkMode`/`darkTextColor`/`darkBkColor`/`nullptr` references remain under `Examples/`.

## Session handoff (2026-07-16) — Main-menu Code/Form restructure (COMPLETE)

Owner-requested (accessibility — dislikes toolbars, wants every command reachable from the menu bar): put the code-pane and form-pane right-click menus onto the main menu bar too. Started on the other machine (WIP checkpoint `b33a2f9`), **finished on this machine (`f3538e1`) — all seven verification tests owner-passed live.** Menu construction is in `src/Main.bas` (~line 6115+, `mnuMain`); the greying rule is in `TabWindow.bas`.

**Done:**
- **Edit → Code** and **Designer → Form** top menus renamed (captions only; the keys `Tahrir`/`FormFormat` and the `mi*` variables are unchanged, so the existing contextual enable/disable wiring is untouched).
- **Code menu** (was Edit) keeps all its items and gained: **Complete Word**, **Syntax Check**, **Suggestions**, a **Convert** submenu (to Lower/Upper/Capitalize, to/from Unicode Hex), a **Lines** submenu (Split/Combine/Sort/Format-With-Basis-Word), and **Split Horizontally / Split Vertically / Fold** moved in from the **View** menu (code-pane specific). The old **Search** top menu was folded in as a **Code ▸ Search** submenu and removed from the bar.
- **Form menu** (was Designer) keeps Align/Make-Same-Size/Size-to-Grid/Spacing/Center/Order/Lock and gained the form right-click's control ops: **Default Event, Copy, Cut, Paste, Delete, Duplicate** (top) and **Previous/Next Layer + Properties** (bottom), all via `@PopupClick` (acts on the active designer's selection; `PopupClick` is forward-declared in `Main.bi:74`, so it is usable from `Main.bas`). Only **Show Panel** was omitted (it's built dynamically per-selection at right-click time — can't be a static top entry).
- **Menu bar reordered** → `File · View · Project · Code · Form · Run · Tools · Window · Help` (owner wanted Project/Code/Form adjacent in that order).
- New duplicate items use **plain captions (no accelerator text)** so they don't double-register in the accelerator table (the shortcuts stay owned by the original items / the Run menu / the folded-in Search submenu). The code right-click's **debug ops** (Toggle Breakpoint, Add Watch, Run To Cursor, Set Next Statement) were **left in the Run menu**, not duplicated into Code.

**Both open UX items resolved (`f3538e1`, owner answers obtained + all seven tests passed live):**
1. **Form/Code-menu greying — rebuilt around one central rule.** Owner's scenario turned out to be split view, and their expectation (confirmed by direct question) is **focus tracking**: in split view the Form menu is enabled only while the designer pane last held focus, the Code menu the opposite. New `UpdateCodeFormMenuEnabled` (`TabWindow.bas`) implements: no tab → both grey; Code-only view → Code only; Form-only view → Form only; split view → follows `gDesignerPaneFocused`. It replaced the three scattered `cboClass.Items.Count > 1` conditions — that combo is the code editor's *class dropdown* and fills for ANY file containing a `Type` (the original `.bas` false positive); form-capability is now `tb->Des->DesignControl` (the Form Designer actually holds this tab's design), which also keeps UserControl.bas designs working. Pane focus is maintained by `frmMain_ActiveControlChanged` (parent-chain walk, since the designer surface is a foreign window hosted in `pnlForm`; focus moving to Properties/Toolbox/output panels deliberately keeps the current pane context) and defaulted by `ApplyView` on every view switch.
2. **Right-click vs main-menu consistency — owner chose "grey both consistently."** Implemented as: the code popup's three debugger ops (Add Watch / Run To Cursor / Set Next Statement) now mirror the Run menu's debugger-state greying via `ChangeEnabledDebug`. Everything else in both popups intentionally stays active — a right-click is itself a context-establishing action on that pane, so unlike the always-reachable menu bar there's no out-of-context state left to grey; debugger state is the one dimension that doesn't come from where you clicked (owner confirmed this reading post-verification). The designer popup needed no change (the main Form menu has no per-item contextual greying to mirror).

Still pending from the other machine's session: the New Project dialog's minor alignment tweaks the owner said they'd handle manually.

**Same-day follow-up — view selector restyled + a framework TabControl bug fixed (`6aa6961`, owner-verified):** the per-document Code+Form/Code/Form strip rendered as flat buttons — bare grey-on-grey text with nothing visually attaching it to the viewport (owner report: "lost in the surrounding sea of grey"). Final form after three owner-eyeballed iterations: **button-style tabs (`TabStyle.tsButtons`) with icons** (the old toolbar toggles' own `imgList` images: CodeAndForm/Code/Form), **docked below the viewport** (`alBottom` — owner: "removes possible confusion" with the document tab strip above). The button restyle exposed a real framework bug, fixed in `TabControl.bas`: the message hook took `SetCapture`/`ReleaseCapture` around **every** click, unconditionally, for the drag-reorder/detach features — button-style tabs commit their click on mouse-UP (classic tabs select on DOWN, which masked this for years), and the early `ReleaseCapture` generates `WM_CAPTURECHANGED` before the native control processes the up-click, cancelling the press, so unselected button tabs never changed selection. Capture is now conditional on `Reorderable`/`Detachable`; owner-verified that view buttons switch views and drag-reorder still works on the document and left/right panel strips (the only opt-in users).

**Owner direction recorded (2026-07-16): teachers/educators added as a named target audience** — easy-to-learn language, one tool for text+GUI, built-in Git and AI integration, working with both frontier models and open-source models via OpenCode (school-budget friendly). Teaching plans and resources for educators are a future task set **gated on a final stable IDE** — see [ROADMAP.md](ROADMAP.md) §13.13 and the new entry in Deferred enhancements below.

## Session handoff (2026-07-17) — New Project two-mode redesign + project.astoria (WIP, owner testing)

**Owner-driven redesign of project creation. Built + compiles clean; NOT yet owner-verified —
owner is testing on the other computer.** This is a 3-task feature; tracked in the task list as
"New Project dialog: two modes…", "Project menu: Edit Project Description", "Project menu: Git
Commit / Push automation". Only task 1 is (partly) done.

**The design (owner-confirmed decisions):**
- Project creation has **two mutually-exclusive modes** (radio at the top of the New Project
  dialog): **Create Local Project** (purely local, no git) and **Use Existing Git Project**
  (clone an existing remote). This *replaces* the old "Use Git" checkbox + the whole
  try-remote/fail/"create the repo first" prompt loop.
- **Use Existing Git** clones `git@<provider-host>:<username>/<ProjectName>.git` (built from the
  existing Provider dropdown + Git Username + the Project Name = repo name), then classifies:
  clone fails → "could not be cloned"; **empty repo** → Astoria populates it from the chosen
  template like a new local project; **complete Astoria project** (has a `project.astoria`) →
  load as-is; **foreign** (non-empty, no `project.astoria`) → delete the clone + refuse
  ("Astoria only loads its own projects or empty repositories").
- **`project.astoria`** — a dedicated, human-readable description file written into *every*
  Astoria-created project, recording all creation choices (`Mode`, ProjectName, Template,
  Author, License, Description, Git provider/user/email/URL, AIFriendly, AITool, Created). It is
  the **marker** that identifies a folder as an Astoria project (drives the clone-classify
  refuse logic). The `.vfp` stays the build manifest.
- Commit & push are **NOT** done at creation — they become **Project-menu options** (task 3),
  for git-backed projects (empty or populated).
- **Teaching angle** (owner): local-create lets students build from scratch; existing-git lets an
  instructor hand students an example repo to clone.

**Done this session (task 1, uncommitted→committed in this handoff):**
- `src/ProjectDescription.bi/.bas` — the `project.astoria` module: `WriteProjectDescription` /
  `ReadProjectDescription` / `IsAstoriaProject` / `FolderIsEffectivelyEmpty`. **Verified working**
  by driving an MCP `create_project` — it wrote a clean, correct `project.astoria`. Wired into
  both the New Project dialog *and* MCP `create_project` (every Astoria project gets one).
- New Project dialog (`src/frmNewProject.frm`/`.bi`) rewritten: two-radio mode selector
  (`optCreateLocal`/`optUseExistingGit` in a new `pnlMode` first row; the old `pnlGit`/`chkUseGit`
  removed), `UpdateModeFields` (git fields on only in existing-git mode), and `cmdOK_Click`
  reworked into the local-vs-clone branch above. New helpers: `CloneGitRepository` (temp-.bat +
  batch-mode SSH `git clone`, mirrors `RemoteRepoExists`), `FindProjectVfp`, `DeleteFolderRecursive`
  (`rmdir /s /q` after `attrib -r`). `SetupGitRepository`/`RemoteRepoExists` are now **unused dead
  code** (left in place; the create-new-repo flow they served is gone) — remove in a cleanup pass.
- Compiles clean (IDE + sidecar); the redesigned dialog opens without crashing (constructor +
  `Form_Create` + `UpdateModeFields` all run).

**One decision left for the owner to confirm (flagged in-session):** in Use-Existing-Git mode the
Template/Form/Module fields are kept **enabled** (not greyed) — they're "used only if the cloned
repo turns out empty," which avoids a mid-dialog re-prompt. Owner had earlier leaned toward
"disable them while checked, re-prompt on empty"; the simpler enabled/single-pass version was
shipped for now. Switch to disabled+reprompt if the owner prefers.

**What still needs owner testing (needs real SSH remotes):** (1) Local create → project opens, a
`project.astoria` lands in the folder; (2) mode switch enables/disables the git fields; (3) clone
paths against the owner's own repos — an **empty** repo, a **complete** Astoria project pushed up,
and a **foreign** repo (to see refuse-and-delete).

**Remaining tasks:** ~~task 2~~ **DONE**. ~~Task 3~~ **DONE** — dedicated top-level **Git menu**
(Commit/Pull/Push; owner chose that over burying it under Project). ~~Tasks 4 & 5~~ **DONE** — git
onboarding automation (**Set Up SSH Key** + **Create Remote Repository** in the Git menu, plus New
Project integration); see the "Git onboarding automation" section. **Tasks 1–5 of the New Project
two-mode + git feature are all built** (all 2026-07-17). Remaining: owner end-to-end verification of
the git flows against real remotes, and the optional refinements noted in each handoff.

## Same-day follow-up (2026-07-17) — Personal Information page, Git identity plumbing, and two settings/recent-project bugs

Owner-driven polish pass over Tools ▸ Options ▸ Personal Information, plus two real bugs the owner
surfaced by testing destructive scenarios by hand.

**Options ▸ Personal Information (`src/frmOptions.frm`/`.bi`):**
- **Licenses laid out in three columns** (`pnlLicenseRow1`/`pnlLicenseRow2`, three `alLeft`
  checkboxes at 140px each) — two rows of three, with Other + its entry field on a third row. This
  also fixed the **GPL3 checkbox caption overlapping the word "License"** in the group-box header:
  the first row inside each group box now carries `.ExtraMargins.Top = 16` to clear the caption.
- **New "Git" group box** (`grbPersonalGit`) holding **Login Name / User Name / E-mail**. Owner's
  reasoning: boxing the section the way License is boxed means the three fields don't each have to
  be prefixed with "Git", and it separates them properly from the Address box above.
- Every personal row got `.ExtraMargins.Top = 6` — the fields were "squished together" — and the
  dialog grew to `679 × 536` (~½" larger) to hold the new layout.

**Git identity is now stored once and reused everywhere.** The three values persist to
`[PersonalInfo]` (`GitLogin`/`GitUserName`/`GitEmail`) via `SettingsService.bas`, are exposed as
`PersonalGitLogin`/`PersonalGitUserName`/`PersonalGitEmail` (`Main.bi`), and are consumed by:
**New Project** (prefills Git Username; e-mail falls back to `PersonalEmail` when the Git one is
blank), **Git Commit** (`GitCommit` sets the repo-local `user.name`/`user.email` *before*
`git add -A`, so commits are attributed correctly without touching the machine's global git
config), and **Set Up SSH Key** (prefers `PersonalGitEmail` for the key comment).

**AI-friendly now defaults to ON** in the New Project dialog (owner: "the default state … should
be on"), with the AI-tool dropdown enabled to match.

**Bug — a deleted project left the IDE stuck on it.** Owner deleted a project folder outside the
IDE; the IDE kept treating it as the last-opened project and put up a "File not found" modal at
startup. Two fixes in `Main.bas`: (1) at startup, `RecentFiles`/`RecentFile`/`RecentProject`/
`RecentFolder` are cleared when their target no longer exists; (2) the AddProject not-found branch
clears the matching Recent pointers and calls `PruneMissingMRUProjects()`, so a failed open also
evicts the entry from the recent list. **Verified**: with the project deleted, the IDE opens with
no modal and no project — just the New Project prompt.

**Bug — a missing `astoria.ini` was never recreated, and settings silently went nowhere.** Found
by the owner deliberately deleting `Settings/astoria.ini` to see whether Astoria would rebuild it;
it did not. Root cause: `IniFile` records its target path **only** inside `Load()` (`If FileName
<> "" Then WLet(FFile, FileName)`), but `LoadSettingsIni()` called `Load` only when the file
already existed. With no path recorded, every `iniSettings.Write*` ended in `SaveToFile(*FFile)`
with an unset `FFile` — failing with nothing louder than a `Debug.Print`, so the whole session's
settings never reached `Settings/`, and the file was never created. (The smoking gun: a partial
`astoria.ini` turning up in the *working directory* instead.) Fixed in `SettingsService.bas` —
when the file is absent, seed a minimal `[Options]` file (UTF-8 **with BOM**, matching the shipped
INI's encoding, which also keeps `Update`'s `FLines.Item(0)` access valid on the first write) and
then load it normally. **Verified** by reproducing the owner's exact test: deleted the INI,
launched, and it was recreated and taking writes.

## Same-day follow-up (2026-07-17) — INI defaults template + dead `[Debuggers]` section removed

Owner reported two INI issues after verifying the New Project clone paths (all three work; module
fields correctly grey out for a complete cloned project).

**The empty terminal dropdown was a regression from the missing-INI fix, not a UI bug.** Tools ▸
Options ▸ Terminal showed an unpopulated dropdown with no default. Instrumenting
`frmOptions.LoadSettings` and then querying the live control from outside (`CB_GETCOUNT`/
`CB_GETCURSEL`) proved the UI path was already correct — 3 terminals, 4 items, index 1 =
"Standard Windows Console". The real cause: the earlier fix seeded a **bare `[Options]` stub** when
`astoria.ini` was absent, so a recreated file had no `[Terminals]` — and none of
`[Helps]`/`[MakeTools]`/`[IncludePaths]`/`[LibraryPaths]` either. That reads as a broken dropdown
but is really a crippled config. Fixed by shipping **`Settings/astoria.default.ini`** (tool
defaults only — no MRU, window state, or personal info) and having `LoadSettingsIni` copy it
byte-for-byte when the settings file is missing, which also preserves the UTF-8 BOM. The bare stub
survives only as a last resort if the template itself is missing (damaged install). **Verified** by
deleting `astoria.ini`, launching, and reading the live combo: all sections restored, terminal
dropdown populated with "Standard Windows Console" selected.

**`[Debuggers]` removed from the shipped INI — it was entirely dead.** Nothing in `src/` reads the
section (no reader for `DefaultDebugger32/64`, `GDBDebugger32/64`, or the indexed entries): the
debugger is hardcoded to the bundled 64-bit GDB via `BUNDLED_GDB_PATH` (`Main.bi`), and there is no
UI for choosing one. The section still listed a 32-bit `gdb-…-i686` folder that **does not ship**
(only `Debuggers/gdb-11.2.90.20220320-x86_64` exists) plus the upstream author's machine paths
(`D:\FreeBasic\FBdebugger296\…`, `F:\Install\…VSCode…`). The stale `[Compilers]`
`DefaultCompiler32` key went with it — also unread, and the Options save path already purges the
rest of that section. 233 → 205 lines.

Note: the default template intentionally omits the `VisualFBEditor` help entry (upstream's own
editor help, wrong branding for this fork); the file still ships in `Help/` and the existing
`astoria.ini` still lists it, so this is reversible if the owner wants it kept.

## Same-day follow-up (2026-07-18) — built-in terminal list, menu icons fixed, help/page cleanup

Owner-requested tweaks after verifying the INI work.

**Terminals are now built in and not user-editable** (owner's call: "the only terminals should be
those provided by Windows"). The list lives in `SeedBuiltInTerminals()` (`SettingsService.bas`)
instead of indexed `[Terminals]` keys: Standard Windows Console, Command Prompt, Windows
PowerShell, and the newly added **Windows Terminal** (`wt.exe -d "{D}" cmd /K "{F}"`). Only the
*choice* (`DefaultTerminal`) is persisted. Consequences:
- The "Terminal Paths" ListView and its Add/Change/Remove/Clear buttons are gone from Tools ▸
  Options ▸ Terminal, along with their handlers and declarations — the page is just the Default
  Terminal dropdown now.
- **The "(not selected)" entry is gone**: index 0 is a real terminal, so a default is always shown.
  An unrecognised name in the INI (hand-edited, or a user-defined entry from an older version)
  falls back to the standard console rather than leaving a blank the user has to notice.
- Keeping the list in code means it can never end up empty or stale — the exact failure that made
  the dropdown look broken in the first place.
- Verified live via `CB_GETCOUNT`/`CB_GETCURSEL`: `count=4 cursel=0 'Standard Windows Console'`,
  no ListView, no terminal buttons on the dialog.

**"Display Icons in the Menu" fixed rather than removed — the icons were already there.** Menu
items already declare image keys (`"New"`, `"Open"`, `"Save"`…) and `imgList` is populated, but
`MenuItem` resolves a key to an index exactly once, inside `Add`, and only when
`Owner->ImagesList` is already bound (`Menus.bas`). Startup bound it as
`IIf(DisplayMenuIcons, @imgList, 0)`, so with the setting off **every item was stamped
`ImageIndex = -1` for the life of the process** and ticking the box later had nothing left to
resolve against. `ImagesList` is now bound unconditionally; `DisplayIcons` is the real switch
(`MenuItem.SetInfo` blanks `hbmpItem` when false). New `ApplyMenuIcons` (`Main.bas`) walks the menu
and pushes `MIIM_BITMAP` straight to the OS in both directions — re-assigning `ImageKey` to turn
icons on, assigning a blank bitmap to turn them off — so the setting applies **live**. The
"changes will be applied the next time the application is run" prompt and its
`oldDisplayMenuIcons` tracking field were removed with it. Verified: 61 of 176 menu items carry
bitmaps with icons enabled (only items that declare a key get one).

**Smaller items:** the `VisualFBEditor` help entry is out of both `astoria.ini` and the defaults
template (Astoria will ship its own documentation; the `.chm` still sits in `Help/` for now), with
the remaining Helps indices renumbered. The Options page formerly labelled "Designer" is now **Form
Designer** (caption only — the `"Designer"` key still drives page selection). Also fixed a latent
`IIf`-returning-a-String on the help dropdown, which FreeBASIC only surfaced once the identical
terminal line above it was removed.

## Git onboarding automation — Tasks 4 & 5 (queued after Task 3, owner-requested 2026-07-17)

Today the "Use Existing Git Project" flow requires the user to have **already** (a) set up an SSH
key with the provider and (b) created the empty remote repo — both manual, documented only in
`Templates/Git/*.md`. These two tasks automate that onboarding. **"Automated" here still allows
user interaction** (gathering info, a one-time provider login) — it removes the mechanical steps,
not the consent. Full feasibility analysis was worked through 2026-07-17; the design conclusions:

- **The robust mechanism is the provider CLI/API, NOT browser automation.** Driving a provider's
  web UI (Playwright/CDP or Claude-in-Chrome) is fragile: bot detection, 2FA, and CAPTCHA
  specifically block scripted submission on auth/security pages, and the DOM churns. Use it only as
  an *assisted* fallback (open the right page prefilled + copy to clipboard; user clicks Save).
- **One interactive provider auth is unavoidable and by design** — a `gh`/`glab` device-flow login,
  a pasted token, or a logged-in browser. That's the "user info" the automation gathers.
- **CLI coverage is uneven:** strong for **GitHub** (`gh`), decent for **GitLab** (`glab`), weak for
  **Bitbucket** (app-password API only) and **Codeberg/Gitea** (`tea` is niche). So full automation
  is GitHub-first; assisted-browser is the fallback for the other three.

**Task 4 — SSH public key setup. COMPLETE (`fd89417` + `a28ad9e`, 2026-07-17)** — see the Task-4
handoff below. **Git menu ▸ Set Up SSH Key** generates an ed25519 key if none exists, seeds
`known_hosts`, copies the public key to the clipboard, then registers it: **`gh`/`glab` auto-add**
when the CLI is installed + authenticated (`<cli> auth status` exit 0 → `<cli> ssh-key add`), else
assisted-browser. Also **wired into `frmNewProject`'s no-key path** (Use Existing Git offers to run
the same `SetupSshKey` with the dialog's provider). Original notes: (a) **generate the keypair
locally** — `ssh-keygen -t ed25519 -C "<email>" -f %USERPROFILE%\.ssh\id_ed25519 -N ""`, handle
key-already-exists, pre-seed `known_hosts`. (b) **register the public key** — `gh`/`glab` if authed;
else
assisted-browser (done).

**Task 5 — create the empty remote repository. DONE (`95b04f7`, 2026-07-17)** — see the Task-5
handoff below. **Git menu ▸ Create Remote Repository** creates an empty private repo for the open
project via `gh`/`glab` when authed (GitHub also wires `origin`), else opens the provider's new-repo
page. And the **New Project (Git Project mode) preflight** (`RemoteRepoExists`, previously dead code,
revived): when the repo doesn't exist, it offers **"Create it now?"** — CLI creates it and the clone
continues (empty → populated); browser path stops for a retry. (REST-API-with-PAT path not built —
CLI + assisted-browser cover it.)

**Suggested slice order:** (1) the fully-safe local piece first — `ssh-keygen` + `known_hosts`
seeding + a `gh`/`glab` presence/auth detection helper; (2) GitHub happy-path via `gh` for both key
and repo; (3) assisted-browser fallback for the other providers. Note Claude (the assistant) can
generate keys and call `gh`/`glab`, but must not type passwords/tokens into fields or submit
account-security web forms unprompted — those stay user-confirmed.

## Session handoff (2026-07-16) — Agent MCP Server (Tasks 0–5 of 8)

**Astoria is now a working MCP server.** An MCP client (Claude Code/Desktop) can drive the live IDE — create/open projects, read/write files, type into the editor, build, run, and read back errors and program output. Full spec + per-task detail: [MCP_SERVER_PLAN.md](MCP_SERVER_PLAN.md) (its "Implementation progress" section is authoritative). Commits `6799e6f` (T0) → `438404e` (T5), all on `origin/main`.

**Architecture (from the plan):** MCP client ⇄ `astoria-mcp.exe` sidecar (JSON-RPC 2.0 over stdio) ⇄ named pipe `\\.\pipe\AstoriaAgent` ⇄ a worker thread in `astoria.exe` that marshals each command onto the UI thread. New source: `src/JsonLite.bi/.bas` (dependency-free UTF-8 JSON, shared by both exes), `src/AgentPipe.bi/.bas` (the IDE-side pipe + command dispatch), `src/AgentMcp.bas` (the sidecar). `Compile.bat` builds `astoria-mcp.exe` alongside `astoria.exe`; both are committed at the repo root.

**15 tools live and owner-verified via a PowerShell `NamedPipeClientStream` harness** (and Task 2 through a real JSON-RPC request stream into the sidecar): `get_status`, `list_files`, `read_file`, `get_active_file`, `get_build_output`, `write_file`, `add_file`, `set_active_file_content`, `open_in_editor`, `build`, `syntax_check`, `run`, `get_errors`, `create_project`, `open_project`. The full loop was exercised end-to-end: create a project → write code with an error → build → read the structured error (file/line/severity/message) → fix via write_file → rebuild clean → run → read captured program stdout. Every path argument is guarded to the open project's root (relative and absolute escapes rejected as `bad_path`); `create_project`/`open_project` are the intentional exceptions (they target new/other projects).

**How it's controlled (as of Task 6):** **default ON** (agent-first). Tools ▸ Options ▸ General ▸ **“Allow AI agent control (MCP)”** — un-tick + OK stops the pipe, re-tick + OK starts it, no restart. A **status-bar panel shows “MCP Agent: On/Off”** (it reuses the old always-UTF-8 encoding panel). Persisted as `[Options] AllowAgentControl`; the old `EnableAgentPipe` dev key still works (auto-migrated). The pipe starts from the top of `frmMain_Show`, so it comes up even on a no-argument launch (previously the Tip-of-the-Day startup modal blocked it). The sidecar **auto-launches** the IDE if it isn't running. See [AGENT_MCP_SETUP.md](AGENT_MCP_SETUP.md) for the full client-connection guide.

**Testing notes for the next session (learned the hard way):**
- Launch the IDE, then talk to the pipe from PowerShell with a **blocking** `StreamReader.ReadLine()` — `build`/`run` just take longer and `ReadLine` waits. (An async `Task.Run`/`Wait` wrapper threw spuriously; don't bother.)
- Use a **disposable copy** of a project (e.g. a throwaway `Projects/AgentX/`) for mutation/build tests; closing the IDE with a dirty project pops a save prompt, so force-kill (`Stop-Process -Name astoria -Force`) when a test left unsaved changes.
- Rebuild picks up in the *next* IDE launch only — restart the IDE after `Compile.bat` to test new behavior.

**Remaining — Task 7 (real-client verify). Task 6 is code-complete (2026-07-17), pending owner UI verification:**
- **Task 6 — DONE (code-complete):** the Tools ▸ Options **"Allow AI agent control (MCP)"** checkbox (**default ON**, agent-first) starts/stops the listener live via `ReconcileAgentPipe()`, replacing the INI gate (old key auto-migrated); a **status-bar "MCP Agent: On/Off" indicator** (repurposed encoding panel, `UpdateMcpAgentStatusBar`); path-scoping audit passed with no code changes (file tools use `AgentResolveProjectPath`, `create_project` uses `IsValidProjectItemName`, `open_project` is intentionally any-`.vfp`); sidecar **auto-launch** of the IDE (`PipeCallEnsuring`); `astoria-mcp.exe` added to `StageRelease.ps1` (installer globs it in); `AGENT_MCP_SETUP.md` covers the client config + tool surface. **Owner still to verify:** the checkbox on Options ▸ General, the status-bar indicator, and that toggling starts/stops the pipe.
- **Task 7:** drive the whole thing from an actual MCP client (Claude Code/Desktop) — nothing has exercised it outside the PowerShell/stdio harness yet.
- **Open design question the plan raises (§11):** whether `create_project` should eventually share one `CreateProjectHeadless` with `frmNewProject.cmdOK_Click` (today the agent has its own focused creator; the dialog's OK handler still owns git/AI/license/form+module logic). Not required for Task 6/7; note it if the dialog and agent creation ever diverge.

## Session handoff (2026-07-17) — MCP `run` output capture hardened against NUL truncation

**Code-complete, compiles clean, unit-verified against the real `fbc64`. NOT yet verified through the live GUI + MCP `run` — that is the next step, to be done on the other computer.** Commit on branch `claude/objective-lewin-0172b6` (see the git note at the end of this section for where it lands).

**The bug:** MCP `run` returned only the *first character* of a program's stdout when that output contained NUL bytes — the classic trigger being a FreeBASIC source with a UTF-8 BOM, which makes `Print` emit UTF-16LE (null-interleaved) wide text (e.g. `"Primes…"` came back as `"P"`). Contrary to the original hypothesis, the truncation was **not** in `JsonNewString`/`JsonEscape` (FB `String` is length-prefixed and `JsonEscape` already renders byte 0 as a `\u0000` escape). The real culprit was `OemToUtf8` (`src/AgentPipe.bas`): it converted the OEM bytes to a wide buffer with an explicit length (correct), then called `WStrToUtf8(*w)`, which uses `-1` (NUL-terminated) in `WideCharToMultiByte` and so stopped at the first `0x0000` wide char.

**The fix (`src/AgentPipe.bas` only, +58/−2):**
- **`WBufToUtf8(w, nWide)`** — new NUL-safe wide→UTF-8 converter that passes an explicit length instead of `-1`, so interior NULs survive (each becomes a `\u0000` in the JSON) rather than truncating.
- **`OemToUtf8`** now routes through `WBufToUtf8`, making the OEM path itself NUL-safe (stray NULs in binary output round-trip instead of cutting the string).
- **`AgentDecodeRunOutput(s)`** — new entry point for captured stdout. Detects UTF-16LE by BOM (`FF FE`) or by heuristic (≥50% NULs in the odd/high byte positions, sampled over ≤1 KB) and decodes it as little-endian wide; otherwise falls back to the (now NUL-safe) OEM path.
- The `run` result builder calls `AgentDecodeRunOutput(outText)` in place of `OemToUtf8(outText)` (`AgentHandleBuildCmd`).

This fixes the wide-text case *and* hardens capture against any stray NULs, independent of the separate template-BOM trigger (which the agent's BOM-less save already avoids for agent-created sources — but a user-opened BOM'd source, or genuinely binary output, still needs this).

**Verification done here (no GUI available in this environment):**
- Extracted the three functions verbatim into a standalone program, compiled with the project's own `Compiler/fbc64.exe`, and ran 5 cases — all PASS: UTF-16LE with BOM, UTF-16LE without BOM (heuristic), plain ASCII (untouched), a long wide string, and empty input. The exact repro `"Primes..."` now round-trips fully (was `"P"`).
- Full IDE compile-only check (`fbc64 -c AstoriaIDE.bas …`, which `#include`s `AgentPipe.bas`) succeeds with 0 errors, confirming it compiles in real context.

**Next step (on the other computer, GUI test):** rebuild (`Compile.bat` — IDE-only, no `FORCE_MFF` needed; `AgentPipe.bas` is IDE-side), then from a real MCP client do `create_project` (or open a project) → make a source that prints wide/UTF-16 output (a BOM'd FB source is the easy trigger) → `build` → `run`, and confirm the `output` field contains the **full** text, matching what the exe prints when run directly. A plain ASCII program should be unchanged.

**Aside (self-inflicted, already cleaned up):** while editing comments, a literal `\u0000` typed into an Edit was interpreted as an actual NUL byte and written into the source twice; both were stripped via a lossless Latin1 round-trip and the file now has zero NUL bytes. That's why the new comments avoid writing that escape literally.

## Session handoff (2026-07-17) — New Project: Task 2 (Edit Project Description) + clone-refusal message

**Task 2 of the two-mode redesign is code-complete (`fc9fc8a`), compiles clean (full `fbc64 -c`),
and was owner-GUI-tested from the main-tree debug build.** On `origin/main`.

- **Project menu ▸ Edit Project Description** ([Main.bas](src/Main.bas) `EditProjectDescription`,
  wired in [AstoriaIDE.bas](src/AstoriaIDE.bas) `mClick`, item created just below Project
  Properties in `CreateMenusAndToolBars`). Opens the open project's `project.astoria` in an editor
  tab for hand-editing. **Enabled only when that file exists** — existence, not marker-validity, so
  a malformed one is still editable to fix (`ChangeMenuItemsEnabled` in [TabWindow.bas](src/TabWindow.bas)).
  Selection-independent (tracks the open project, not the tree cursor).
- New helper `OpenProjectDescriptionPath()` returns the clean single-separator path (strips
  `GetProjectDirectory`'s trailing slash) so it matches the on-disk path and `GetTab`'s dedup.
- Include order: moved `ProjectDescription.bi` before `TabWindow.bi` in `Main.bas` so
  `ChangeMenuItemsEnabled` can see the declarations.
- **Design choice to confirm:** opens the raw `project.astoria` in the code editor (matches the
  plan's "open for editing", no new dialog). Switch to a structured form later if wanted.
- Also in `fc9fc8a`: the **clone-refusal message** now spells out that an existing repo must
  contain a `project.astoria` with an `AstoriaProject=1` line (an empty file is not enough) — the
  old wording implied mere presence sufficed. `IsAstoriaProject` reads the marker, not just the
  file. (See `ProjectDescription.bas` `ReadProjectDescription`.)

**Gotcha learned this session (workflow, not code):** the IDE resolves `ProjectsPath=.\Projects`
relative to the *running exe's* directory (ExePath). Building/launching a debug exe from the
`.claude\worktrees\...` worktree makes new-project and clone folders land under the worktree, not
the real `Projects\`. **Always build + run owner test builds from the main tree
`C:\Users\don\Astoria-IDE`.** The clone target itself is correct: `frmNewProject.cmdOK_Click` sets
`localFolder = <ProjectsPath>\<ProjectName>` and clones there — never derived from the origin repo's
directory, so a teacher's `Examples\...` upload location never follows a student's clone.

## Session handoff (2026-07-17) — Git menu ▸ Set Up SSH Key (Task 4, slice 1)

**Task 4 slice 1** — the fully-safe local + assisted-browser path. Built, compiles clean; `fd89417`.
Exposed as a new Git-menu item **Set Up SSH Key…** in a setup group (separator) below Commit/Pull/Push;
always enabled (onboarding, not project-gated). Owner requested each git action get its own menu item.

- **`GitSetupSshKey`** ([Main.bas](src/Main.bas)): `EnsureSshKey(comment, log)` returns the existing
  public key (prefers `id_ed25519.pub`, else `id_rsa`/`id_ecdsa` — **never overwrites an existing
  key**), or generates a fresh ed25519 (no passphrase) via `ssh-keygen` + seeds `known_hosts` for
  github/gitlab/bitbucket/codeberg, through a temp `.bat` (`PipeCmd`). Then copies the public key to
  the clipboard (`Clipboard.SetAsText`) and, on a Yes/No, opens the provider's SSH-keys page
  (`SshKeyPageUrl`; provider from the open project's `project.astoria`, else GitHub) via
  `ShellExecuteW`. **Astoria never enters credentials or submits the page** — the user pastes + saves.
- Comment/label defaults to `*PersonalEmail` (Options), else `astoria-ide`. Needs `ssh-keygen` on
  PATH (ships with Git for Windows); a failure surfaces the ssh-keygen output.

**Task 4 completed (`a28ad9e`):** `SetupSshKey(provider)` (refactored out of `GitSetupSshKey`, now
public + declared in `Main.bi`) tries the provider CLI first — `RunCmdCaptured("<cli> auth status")`;
if exit 0, offers `<cli> ssh-key add "<pub>" --title "Astoria (<machine>)"`, falling back to the
assisted-browser on decline/failure. `frmNewProject`'s Use-Existing-Git no-key path now offers to
run `SetupSshKey(gitProvider)` and stops the attempt (the fresh key still has to be registered with
the provider before a clone authenticates). New general `RunCmdCaptured` helper (non-git commands).

**Task 5 completed (`95b04f7`):** `TryCliCreateRepo(provider, repoName, sourceFolder, out)` —
`gh`/`glab` create an empty private repo when authed; GitHub with a local git repo also gets
`origin` via `gh repo create --source --remote`. `NewRepoPageUrl`/`OpenNewRepoPage` are the
assisted-browser fallback. **Git menu ▸ Create Remote Repository** (`GitCreateRemoteRepo`) creates
one for the open project (name/provider from `project.astoria`, else folder/GitHub). New Project
(Git Project mode) preflights `RemoteRepoExists` before cloning and offers to create a missing repo.
Caveats: `gh repo create` uses the *authenticated* account (mismatch with a different typed username
breaks the clone URL); Bitbucket/Codeberg always use the browser. Also renamed the New Project
mode radio **"Use Existing Git Project" → "Git Project"** (`7b7b435`), since it now creates the repo
if it doesn't exist. **The whole New Project two-mode + git feature (Tasks 1–5) is now built.**

**GitHub-only for now (`76c13ae`):** owner decision — until GitLab/Bitbucket/Codeberg catch up on
the CLI automation, GitHub is the only provider. The New Project provider **dropdown is retired**:
`cboGitProvider` is hidden/inert, replaced by a static **bold "GitHub" label** (`lblGitProviderValue`)
where the dropdown sat (keeping the "Git Provider:" caption); `gitProvider` is hardcoded to `"GitHub"`
in `cmdOK_Click`. To bring back a choice later: re-show + repopulate `cboGitProvider` and delete
`lblGitProviderValue`. (The provider-specific plumbing — `SshKeyPageUrl`/`NewRepoPageUrl`/`glab`
branches — is all still there, so re-enabling is UI-only.)

## Session handoff (2026-07-17) — Git menu (Task 3): Commit / Pull / Push

**Task 3, delivered as a dedicated top-level Git menu** (owner's call: its own menu between Run and
Tools, room to grow — not buried under Project). Built, compiles clean, **owner GUI-verified** on a
real cloned repo (commit + push worked end to end). Commits `d61eb06` → `60da4ee`.

- **Menu** `mnuMain` "&Git" between Run and Tools ([Main.bas](src/Main.bas) `CreateMenusAndToolBars`):
  **Git Commit…** · separator · **Git Pull** · **Git Push**. All three enabled only when the open
  project's folder is a Git working tree (`OpenProjectIsGitRepo` = a `.git` entry, wired into
  `ChangeMenuItemsEnabled`); dispatched in [AstoriaIDE.bas](src/AstoriaIDE.bas) `mClick`.
- **Execution:** `RunGitInProject(args, out, exit)` runs `git <args>` in the project folder via a
  temp `.bat` with batch-mode SSH (`GIT_SSH_COMMAND=ssh -o BatchMode=yes -o ConnectTimeout=15 -o
  StrictHostKeyChecking=accept-new`, `GIT_TERMINAL_PROMPT=0`) — same plumbing as
  `CloneGitRepository`; can't hang on a prompt; captures combined stdout+stderr and the exit code.
  Commit = `git add -A` then `git commit -F <tempfile>` (message via file, no cmd-quoting risk).
- **Commit dialog** `frmGitCommit` ([.bi](src/frmGitCommit.bi)/[.frm](src/frmGitCommit.frm), new;
  registered in `src/AstoriaIDE.vfp`): a **themed** modal (replaced the crude framework `InputBox`)
  with a read-only **"Files to be committed"** list (from `git status --porcelain`, formatted
  modified/new/deleted/renamed) above a multiline message box + OK/Cancel. A clean tree
  short-circuits to "Nothing to commit" without opening the dialog.
- **Result boxes are plain-English** (`ShowGitResult`), not raw git dumps: commit → "Committed to
  <branch> as <hash>" + message + change line; pull → "Pulled changes" / "Already up to date"; push
  → "Pushed your commits" / "Nothing to push". Failures keep git's own text (the actionable part).
- **Two bugs fixed on the way:** the message file was written with `Encoding "utf-8"` (BOM) so
  `git commit -F` folded a BOM into the message (`i>>?` garble) — now raw UTF-8, no BOM; and a
  scratch file (`Temp.bas`, which Astoria writes into the project folder for an unsaved main file —
  [TabWindow.bas:11171](src/TabWindow.bas:11171)) was being swept into commits by `git add -A`.
  `Templates/Git/gitignore.txt` now ignores `Temp.bas`. **Note:** a git repo created *outside*
  Astoria (hand `git init` + push) has no `.gitignore`, so scratch/build files still get committed
  there until one is added — the new commit-dialog file list at least makes that visible.

**Not done / possible follow-ups:** no Git menu items yet for status/log/branch/diff (the menu is
built to grow); commit is "all" (`git add -A`) with no per-file staging UI; `DeviceExplorer64.exe`
and similar already-tracked build artifacts in hand-made repos aren't auto-untracked.

## Session handoff (2026-07-17) — AI Agent dropdown data-driven + ClaudeCode template git/MCP updates

Two owner-requested changes, both on `origin/main`, compile clean, owner GUI-testing the dropdown.

**AI Agent dropdown now populates from `Templates/AI/` subfolders (`a34dc2f`, `frmNewProject.frm`).**
The New Project dialog's AI Agent list was a hardcoded five-item list with a label→folder map
(`AIToolFolderName`). It now **scans `Templates/AI/` for subdirectories** and lists them verbatim,
sorted, defaulting to `ClaudeCode` when present — so adding or removing an agent is just
adding/removing a folder there (rescanned each time the dialog opens; no rebuild). The folder name
is now used as the label, the stored `AITool=` value (`.vfp` + `project.astoria`), and the
`StampAITemplate` source folder, so `AIToolFolderName` is reduced to an identity. **Behavior change:**
`AITool=` now stores the folder name (e.g. `ClaudeCode`) instead of the old pretty label
(`Claude Code`); nothing reads it back into logic, so it's harmless. Trade-off: the dropdown shows
raw folder names — a prettier display would re-introduce the hardcoded map the owner wanted gone.

**ClaudeCode AI template: git-workflow skill + `project.astoria` documented (`fcf2b67`).** Git and
MCP are now shipped features, but the AI templates never mentioned `project.astoria` and had no git
guidance. Added `.claude/skills/git-workflow/SKILL.md` (remote lives in `project.astoria`;
commit/push via Project menu or git CLI over SSH; SSH-key requirement; commit-only-when-asked /
no-force-push rules; MCP exposes no git ops) and documented `project.astoria` (the `AstoriaProject=1`
marker file, edited via **Project ▸ Edit Project Description**) in both `CLAUDE.md` and `AGENTS.md`.
**Scope: ClaudeCode only** — owner will have the other four tool agents mirror this into their own
`Templates/AI/<tool>/` folders using ClaudeCode as the model. (Corrected a wrong assumption along the
way: the `.vfp` *does* still carry the git/metadata keys — `frmNewProject` writes them to both the
`.vfp` and `project.astoria` — so that existing template rule was not stale.)

**Cursor mirrored (2026-07-19):** `Templates/AI/Cursor/` now matches ClaudeCode's upgraded baseline —
added `.cursor/skills/git-workflow/SKILL.md`; upgraded `use-astoria-mcp` (prefer MCP edit / BOM /
`get_errors` habits + verified Connecting note); brought `AGENTS.md`, `freebasic.mdc`,
`freebasic-tasks.mdc`, and `.cursorrules` up to date with UTF-8-no-BOM, `Str(a=b)`, `ReDim Preserve`,
`project.astoria`, MCP-edit discipline, and testing discipline. `.cursor/mcp.json` format confirmed
against current Cursor docs. ChatGPT/OpenCode/Kun still need the same mirror pass.

## Session handoff (2026-07-17) — "Main" startup convention + Edit Project Description dialog

Owner-driven, owner-verified (created Console + Windows App build/run; edited a project's metadata).
Two parts, commits `c104169` (A) and `d4d775f` (B).

**Part A — "Main" startup convention.** Every project template's startup file is now named **Main**:
`Main.frm` for a GUI **Windows Application** (its `Form1Type`/`Form1`/`.Name`/`#cmdline "Form1.rc"`
all renamed `Form1→Main`), `Main.bas` for Console/Dynamic/Static Library (empty `Module1.bas`) and
Control Library (`UserControl1→Main`); each template `.vfp` updated (`*File=` + `ApplicationTitle`).
So the New Project dialog **no longer asks for a form/module name**: the **Primary Form Name** /
**Primary Module Name** rows were removed (dialog 64px shorter, `cboTemplate_Change` gutted, the
Windows-App extra-module option dropped), and `cmdOK_Click` just copies the template's `Main.*` file
as-is and rewrites the project `.vfp`'s `*File=` to the bare name. Rationale (owner): the startup
form/module is a fixed concept, always "Main", created automatically — decoupled from whatever files
the user later adds/deletes.

**Part B — Edit Project Description dialog** (`frmEditProjectDescription`, replaces the raw-text
open). Read-only block: Project Name, Template, Mode, **Startup** (`Main.frm`/`Main.bas`, detected on
disk), Created, Git remote. Editable: **Author, License, Description, Make-AI-friendly + AI Tool**
(dropdown data-driven from `Templates/AI`). On OK: `WriteProjectDescription` (project.astoria) +
`UpdateVfpMetadataKeys` (syncs the `.vfp` `Author/License/Description/AIFriendly/AITool` lines) +
`StampAiTemplateInto` (stamps `Templates/AI/<tool>/` with token substitution **only** when
AI-friendliness is newly enabled or the tool changed). `StampAiTemplateInto`/`AiCopyTree`/`AiStampFile`
are a public shared copy of the New Project stamping (a future cleanup could dedupe those + AgentPipe's
copy). **Deliberately NOT editable** (owner's "be precise" call, avoids risky on-disk file ops):
Project Name (rename), Startup, Git fields (they mirror the real remote in `.git`), Mode, Template,
Created. Design decisions confirmed by owner: Git fields read-only; AI toggle *does* stamp; Default
Form/Module became moot (the "Main" convention supersedes storing per-project names).

## Next ready work

**In progress: New Project dialog two-mode redesign + `project.astoria`.** Task 1 (dialog +
module) and **Task 2 (Edit Project Description, `fc9fc8a`)** are done and compile clean; Task 1 is
**not yet fully owner-verified** (clone paths need real remotes). See "Session handoff (2026-07-17)
— New Project two-mode redesign" and the Task-2 handoff below for the full plan, what's done, the
field enabled/disabled decision to confirm, and exactly what to test. **Tasks 3, 4, and 5 are all
done** — the top-level **Git menu** (Commit/Pull/Push + Set Up SSH Key + Create Remote Repository)
and the New Project git integration; see their handoffs below. **All of Tasks 1–5 are now built;**
what remains is owner end-to-end verification against real remotes.

**Agent MCP Server — COMPLETE (Tasks 0–7, 2026-07-17).** Verified end-to-end from a real
MCP client (stdio JSON-RPC 2.0): `create_project` → `write_file` → `build` → `get_errors`
→ fix → `run` produced the correct output (`Primes below 1000000 = 78498`). Two MCP-side
bugs found and fixed during verification (Fix B: `create_project` opens the main file;
Fix C: agent build saves dirty editors first — see [MCP_SERVER_PLAN.md](MCP_SERVER_PLAN.md) Task 7).

*Done 2026-07-17 (code-complete, pending GUI/MCP verify on the other computer):* the **MCP
`run` output capture is hardened against NUL truncation** — see the 2026-07-17 handoff below.

*Done 2026-07-17:* the **Console Application template** is fixed — `mff/NoInterface.bi` now
declares `DebugWindowHandle` (it referenced but never declared it), so console projects compile;
verified via `fbc64` and MCP `create_project`+`build` of the unmodified template. Its stray BOM
was already stripped.

*Parallel, owner-driven:* have each of the five AI agents review its own
`Templates/AI/<tool>/` folder and confirm/adjust its MCP config (the `use-astoria-mcp`
skill + native server config landed 2026-07-17; Codex/Kun formats need per-client
verification).

For the reasoning, exact code locations, and prior hot-path findings, see [HISTORY.md](HISTORY.md).

## Open items

### Immediate

- [ ] **New Project Git/AI wiring — verified except two optional tail items.** Remaining: (a) optionally, the Yes path against the other providers (GitLab/Bitbucket/Codeberg) — GitHub is verified end-to-end; (b) a light spot-check of other modals (Options, Find/Replace, delete confirmations), since `ShowModal` now re-owns windows to their current parent. **Done 2026-07-16:** the warning dialog's misbehavior was the first-MsgBox-per-run non-modality bug (`84d066a`); Yes/No/Cancel paths, Yes's re-check loop, `.gitignore`/`.gitattributes` stamping, and full GitHub git setup owner-verified (`787cc6d`); AI-friendly stamping owner-verified, which surfaced and fixed the write-only `.vfp` metadata keys being dropped by the IDE's first project save (`86948b5`) — see the two 2026-07-16 handoffs above.
- [x] **Form Designer context menu (`mnuDesigner`) format submenus — RESOLVED by removing dark mode (2026-07-15).** The empty-flyout symptom (Align worked, the other four format submenus showed an arrow but an empty flyout) occurred **only in dark mode**. Instrumentation this session proved the menu *data* was fully correct — every submenu HMENU was populated and correctly linked into `mnuDesigner` (right position, right `hSubMenu`, right item count) — so the fault was purely in the dark-mode owner-draw paint path, not the FreeBASIC menu structure or the build-order theories chased earlier. With dark mode removed, these context-menu submenus now render natively and correctly. No context-menu code change was needed beyond the dark-mode removal. (The Attempt A/B/C build-time rewrites of the `mnuDesigner` construction from the prior session remain in place; they're harmless and the pre-built-before-attach shape is fine.)

### Deferred enhancements

- [ ] **Teaching plans and resources for educators (owner-added 2026-07-16, gated on a final stable IDE).** Teachers/educators are now a named target audience: Astoria's pitch to them is an easy-to-learn language + a single tool for both text and GUI development + built-in Git and AI integration, with the AI side working across both frontier models (high cost) and open-source models via OpenCode — the latter appealing for limited school budgets. Full rationale and scope notes in [ROADMAP.md](ROADMAP.md) §13.13. Do not start until the IDE is declared stable.
- [x] **T01 — Standardize indentation.** Done for all three trees. `src/` (`2f445e4`). `Controls/` (124 files converted to tabs via a per-file auto-detected indent unit, since files ranged 2/3/4-space plus stray-space typos with no single global unit; 2 files - `SystemInformation.bas`/`.bi` - hand-fixed instead since their spacing was too inconsistent for any unit to fit). `Examples/` (7 files, all clean 3- or 4-space, converted with zero remainder warnings). CRLF normalized throughout (only a handful of LF-only files existed by this point) via the same scoped `.gitattributes -crlf` pattern extended to `/Controls/**` and `/Examples/**`.
- [x] **T03 — Extract repeated logic within files.**
- [x] **T05 — Simplify the Development/Final compile-mode controls.**
- [x] **T06 — Audit UI/settings for orphaned controls.**
- [x] **T08 — Build a standard Windows installer.** Done: per-user, no-admin-required Inno Setup installer, owner-verified via a full clean install/uninstall cycle.
  - **Staging** (`StageRelease.ps1`): assembles an end-user-facing release tree at `%USERPROFILE%\Astoria-IDE-Release` (sibling of the repo, never git-tracked — rerun any time to regenerate it). Excludes `src/` (GPL source access is satisfied by the GitHub repo instead), build scripts, maintainer docs, the developer's personal `astoria.ini`/`Tools.ini` and debug trace logs, redundant reference material (`Documentation/`, `Compiler/doc`, `Compiler/examples` — covered by the IDE's own Help content or the FreeBASIC website), and dead/stale dev tooling (`Tools/LNGCreator` — the `.lng` translation system it targets was already removed; `Tools/strip_gtk_preprocessor.*` — one-time maintainer scripts for this repo's own Win64 migration; `Tools/ToolsX.ini` — a stale cross-platform-era leftover). Deliberately **keeps** `Controls/*/mff/*.bas` despite being source: every project's `Form.frm` template does `#include once "mff/Form.bi"`, which text-includes its own `.bas` implementation, so a user's own project needs the real framework source to compile — a prebuilt `framework.dll` + headers-only isn't sufficient for FreeBasic's `Type` system. Current result: 3,688 files, ~303MB.
  - **Packaging** (`AstoriaIDE.iss`, compiled with Inno Setup 6.7.3): reads exclusively from the staged tree, never back into the dev repo. Per-user install (`PrivilegesRequired=lowest`, installs under `%LOCALAPPDATA%\Programs\Astoria IDE`, no elevation prompt), Start Menu + optional desktop shortcuts, proper Windows uninstall registration, fixed `AppId` GUID so future versions upgrade in place. `license.txt` corrected along the way: was still branded "VisualFBEditor" with only the 2018 upstream copyright; now leads with "Astoria IDE for Free Basic", `Copyright (C) 2026 Donald Montaine`, and a preserved `Derived from VisualFBEditor, Copyright (C) 2018 Xusinboy Bekchanov` attribution line (a GPL requirement, not just courtesy).
  - **`[Code]` section fixes a real UX gap**: the app's compiled-in `ProjectsPath` default (`./Projects`, relative to `ExePath`) is deliberately unchanged in source — correct for a dev/portable checkout — but under this installer `ExePath` resolves to a hidden `%LOCALAPPDATA%` folder, so a fresh end user's own project files would land somewhere they'd never find them. The installer now seeds a fresh `astoria.ini` with `ProjectsPath` pointing at `Documents\AstoriaProjects` (no spaces, to avoid path-quoting issues when passed through to `fbc64`/`gdb`) — but only when no `astoria.ini` already exists, so upgrading over an existing install never touches a user's own settings. Owner-verified: correct path shows in Tools ▸ Options ▸ General after a fresh install.
  - **`BuildInstaller.ps1`**: one-command wrapper running `StageRelease.ps1` then `ISCC.exe` back to back, since the two must always travel together (re-running just one repackages stale content — see its header comment).
  - **Known limitation, deliberately not chased further**: the installed app does not appear in Control Panel ▸ Programs and Features or Settings ▸ Apps, despite a completely well-formed uninstall registry entry (verified byte-for-byte, including checking for WOW6432Node registry redirection — none found) and full functionality otherwise (Start Menu launch/uninstall shortcuts work correctly and persist normally). Ruled out: Smart App Control (owner disabled it — no change). Most likely cause: `astoria.exe`/`unins000.exe` are unsigned (confirmed via `Get-AuthenticodeSignature`), unlike a working comparison case (Discord, signed) — some Windows reputation/filtering mechanism most likely excludes unsigned per-user installs from that specific list, though the exact enforcement point wasn't pinned down in logs. Considered and set aside: MSIX + Microsoft Store submission (the $19 fee would provide signing, but MSIX's sandboxed app-container model is real engineering risk for an IDE that spawns child compiler/debugger processes and needs broad file-system access — disproportionate for what this is). Worth a future look: **SignPath.io**, which offers free Authenticode signing for verified open-source projects (this is GPL-licensed) — would fix this without any MSIX conversion. Pragmatic mitigation instead: document how to find/launch/uninstall via the Start Menu as a Help topic — **not yet written**, natural next step if picked up.
- [x] **T09 — Expand and further document the retained Examples.**
- [x] **T10 — Implement dark-mode popup menus.** Done, owner-verified. Three rounds: (1) the main menu bar's own dropdowns in `Form.bas` — fixed a submenu-header caption bug (owner-draw items that open a submenu get Windows ID -1, making the old `GetMenuItemInfo`-by-ID text lookup ambiguous; now reads straight from the live `MenuItem` object instead), added separator-line/checkmark/radio-dot/submenu-arrow painting (owner-draw suppresses all of Windows' own item chrome, not just the text), and set the popup's `MIM_BACKGROUND` brush so the outer margin matches. (2) Context menus (`Control.ContextMenu`, e.g. the code editor's right-click menu) and toolbar dropdown-button menus (`ToolBar`'s `DropDownMenu`) are tracked with a different `TrackPopupMenu` owner window (the control/toolbar itself, not the Form) and so needed the identical `WM_INITMENUPOPUP`/`WM_MEASUREITEM`/`WM_DRAWITEM` handling duplicated into `Control.bas` and `ToolBar.bas` — without it those two menu classes stayed fully light regardless of dark mode. (3) `DrawFrameControl(DFC_MENU, ...)` (checkmark/radio/arrow glyphs) turned out to paint its box using fixed system 3D-face colors regardless of what's selected into the DC, so checked items showed a light square even once everything else was dark — replaced with manually-drawn glyphs (GDI line/ellipse/polygon) in all three files.
- [x] **T11 — Implement dark-mode dialog/modal backgrounds.** Done, owner-verified (OK/error and Yes-No/warning variants). Scope narrowed to the native `MessageBox()` API specifically — the app's own `Form`-based dialogs (Options, etc.) already dark-themed correctly via T12. First attempted to theme the real native MessageBox in place: a thread-scoped `WH_CBT` hook (installed only for the duration of one `MessageBox()` call, in `MsgBox`/`Application.bas`) caught the dialog's `HWND` via `HCBT_CREATEWND`, then `SetWindowSubclass` handled `WM_CTLCOLORDLG`/`WM_CTLCOLORSTATIC`/`WM_ERASEBKGND`/`WM_NOTIFY`(`NM_CUSTOMDRAW`) to theme it — title bar, message text, icon, and (after finding a button only sends `CDDS_PREPAINT`, never `CDDS_ITEMPREPAINT`, unlike itemized controls) the button all ended up correctly dark. One background band survived every further fix tried against it (full-client `WM_ERASEBKGND` coverage confirmed via logging, a magenta test-fill proving our own paint calls weren't reaching it, DWM backdrop-material suppression via `DWMWA_SYSTEMBACKDROP_TYPE`/`DwmExtendFrameIntoClientArea` confirmed successful via HRESULT logging) with no tool available in this environment to identify what was actually compositing over it. Rather than continue indefinitely, pivoted to building `MsgBoxForm` (`Controls/Framework/mff/MsgBoxForm.bi`/`.bas`) — a plain `Form` that lays out a system icon, word-wrapped message text (measured via `DrawTextW`/`DT_CALCRECT`, since `Label.AutoSize` only single-line-measures regardless of `WordWraps`), and OK/Cancel/Yes/No buttons matching the requested `ButtonsTypes`, and swapped `MsgBox` (`Application.bas`) to build and `ShowModal` it instead of calling `MessageBox()`. Being a plain `Form`, it dark-themes automatically with zero new theming code. All the CBT-hook/subclass/backdrop-suppression code and its temporary diagnostic logging were removed from `DarkMode.bas`/`.bi` as dead code once the pivot landed. The five raw `MessageBox()` calls in `Debug.bas` (pipe-creation failure paths, not the shared `MsgBox` wrapper) still bypass this and stay native/light — very low-traffic edge cases, left alone.
- [x] **T12 — Complete live dark-mode re-theming after Options Apply.** Done (see the 2026-07-14 T12 handoff below, plus same-day follow-up fixes): live toggling, cold-start dark, and the RichTextBox description panes all re-theme correctly in both directions. One deferred cosmetic item moved to the Deferred enhancements list below (Properties/Events header flash on cold dark start).
- [x] **T14 — Fix the cold-open blank Designer page.**
- [x] **T15 — Create fork-specific wiki/documentation.**
- [x] **T16 — Add tooltips to embedded toolbar controls.** Covered the build-configuration combo, four search boxes (Explorer/Toolbox/Properties/Events), and code-editor class/function dropdowns.
- [x] **Personal Information page (owner-requested, 2026-07-14).** New page in Tools ▸ Options, between Designer and Help: Name, Company, Web site, E-mail address, a multi-line Address field, and a multi-select License group (GPL3/LGPL/Apache/BSD/Freeware/Proprietary/Other, with the Other checkbox enabling its own description field). Follows the existing Options page pattern exactly (TreeView node + Panel toggled by `TreeView1_SelChange`, fields populated in `LoadSettings`, saved in `cmdApply_Click` — shared by OK and Apply). Persisted to a new `[PersonalInfo]` section in `astoria.ini`; the multi-line Address field is stored with a `"\n"` placeholder instead of a literal CRLF, since `IniFile` stores each key as a single line and an embedded newline would corrupt the file's line-based structure. Owner-verified (`2a04a71`).
- [x] **Cosmetic: Properties/Events header flash on cold dark start.** Moot — dark mode was removed entirely on 2026-07-15 (see the session handoff above). T10/T11/T12 above are retained as historical record of the dark-mode work that was later removed.

### Recently completed cleanup

- [x] **T17 — Remove dead/commented code and empty handlers.**
- [x] **T18 — Audit and replace applicable magic numbers.**
- [x] **T19 — Audit remaining GTK/Linux/32-bit artifacts.**
- [x] **T20 — Clean obsolete platform references from build documentation.**
- [x] **`Documentation/` folder removed (2026-07-16, `2d833f4`).** 1092 loose HTML pages (~15 MB) that duplicated the FreeBASIC language reference already shipped compiled in `Help/FB-manual-en_US-1.10.1.chm`; nothing in code/build/help referenced it (StageRelease already excluded it — its comment updated to past tense). Staging re-verified clean afterward (3,771 files, 302 MB; `Documentation/` absent, Help CHM intact).

## Essential gotchas

1. After any source change, rebuild and commit the **release** executable with Compile.bat; MFF source reachable from mff.bi also needs FORCE_MFF=1 so framework.dll is rebuilt.
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
| MFF framework | Controls/Framework/mff/ → Controls/Framework/framework.dll |
| Build | Compile.bat, CompileDebug.bat |

## Reference material

- [HISTORY.md](HISTORY.md) — detailed investigations, completed sub-projects, dated session notes, and rationale.
- [CHANGELOG.md](CHANGELOG.md) — shipped work and commit history.
- [ROADMAP.md](ROADMAP.md) — full enhancement specifications.
- [PROJECT_SETUP_PLAN.md](PROJECT_SETUP_PLAN.md) — Project Setup Templates feature (licenses/git/readme/AI stamping, Properties editor) plan & task breakdown.
- [MCP_SERVER_PLAN.md](MCP_SERVER_PLAN.md) — Agent MCP Server spec: architecture, the v1 tool surface, pipe protocol, and phased tasks for letting an AI agent drive the live IDE (scoped, not started).
- [DIRECT2D_REMOVAL.md](DIRECT2D_REMOVAL.md) — why Direct2D was removed (2026-07-13), full scope, and git-based instructions to bring it back.

*End of status document.*
