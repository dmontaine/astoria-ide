# Astoria IDE — Testing

What has been tested, how, and — just as important — what has **not**. This is a live document:
it is updated as testing happens, not written once at the end.

If you are evaluating Astoria as a tester, read [Known gaps](#known-gaps--not-yet-tested) first.
It tells you where the thin ice is, and those are the areas where your findings are most valuable.

Related: [TestPlan.md](TestPlan.md) for what is *planned* — named scenarios, each marked as
agent-automatable or needing a person, with a result recorded against it;
[AstoriaIDESignificantChanges.md](AstoriaIDESignificantChanges.md) for what Astoria is,
[DetailedChangelog.md](DetailedChangelog.md) for every change, and
[ControlTesting.md](ControlTesting.md) for the per-control results in full.

## How we test

Four methods, in increasing order of confidence.

| Method | What it proves | What it does not |
| --- | --- | --- |
| **Clean build** | The tree compiles with zero errors and zero warnings using the bundled FBC 1.10.1. | Nothing about behaviour. |
| **Automated harness** | Driven through the IDE's own agent pipe: open a project, build it, launch the result, check the window, close it. Used for the 73-control sweep. | Only what it explicitly checks — see the false-pass note below. |
| **End-to-end client** | A real external client exercising a whole workflow, e.g. an MCP client doing create → write → build → fix → run. | Coverage of paths the workflow does not touch. |
| **Owner verification** | A human using the feature in the running IDE and confirming it behaves. This is the strongest signal we have and most features carry it. | It is one person on one machine — which is why human testers are being sought. |

**A lesson worth recording.** The control harness originally asked only *"is a window open?"*. A
modal *"DLL not found"* dialog answers that just as well as a working program, so two startup
failures were recorded as passes. The check now matches the expected window title. Treat any
automated pass whose assertion is weaker than the thing it claims as suspect — this document tries
to state assertions precisely for that reason.

## What has been tested

### Controls and the toolbox — complete

All 73 toolbox controls plus the Cursor pointer. Each control got a generated single-control
project, built by the IDE itself, then launched, title-checked and closed. **73 of 73 pass**
Tests 1 and 2; all but `WebBrowser` also carry owner visual inspection.

Full results, per control, in [ControlTesting.md](ControlTesting.md). Three library defects were
found and fixed by this sweep (MariaDBBox, SQLite3Component, WebBrowser), and one missing runtime
DLL was discovered and shipped.

### Debugger reliability — complete

Defects DR-1 through DR-16 are fixed and owner-verified. This was a dedicated sub-project against
the integrated GDB debugger.

### Agent MCP server — complete

Tasks 0–7, verified end-to-end from a real stdio MCP client speaking JSON-RPC 2.0:
`create_project` → `write_file` → `build` → `get_errors` → fix → `run`, producing correct program
output. Verification itself found and fixed two MCP bugs and surfaced two pre-existing ones.

Later hardening: `run` output capture no longer truncates at a NUL byte (wide/UTF-16 program
output previously showed only its first character).

**Multi-file MCP lifecycle (TestPlan D5): 14/14.** A live agent created a project, added and
registered a header/module pair, wrote a three-file program with a deliberate error in the
secondary module, built, read the structured `Math.bas:6` error, repaired it, rebuilt and ran.
Output assertions proved both the unique run and the cross-module calculation (`sum_squares=385`).
The test found and fixed two consistency defects: `list_files` now reports the live project model
instead of a stale on-disk manifest, and `write_file` always synchronizes an already-open editor
buffer even when the caller does not request that the file be focused.

### Whole-workflow lifecycle

**Windows application with the designer, end to end (TestPlan D2).** The default path for a new
user: create from the default template, place controls, set properties, wire an event, build, run,
close, reopen. Event wiring verified in all three of its parts — declared, assigned, implemented —
since that is the machinery C3's rename defect lived in. Found one artefact, a scratch file left in
the project folder (ROADMAP §13.24).

**Console application, end to end (TestPlan D1): 12/12.** Create from the template, edit, build,
run, read the output back, switch away to another project, reopen, confirm the edit survived, and
rebuild. Driven through the agent pipe, asserting on program *output* rather than exit status.

This is the regression canary: it touches project creation, the template, the editor, the build
pipeline, process launch and output capture, and workspace persistence in one pass. If something
fundamental breaks, this fails first.

### Build and toolchain

The IDE builds clean with the bundled FBC 1.10.1. Both project templates were verified by
compiling them unmodified — the Console Application template was fixed during this (it referenced
an undeclared `DebugWindowHandle`) and re-verified via both `fbc64` directly and MCP
`create_project` + `build`.

Runtime DLL copying was verified by deleting the DLLs from test projects and rebuilding through
the IDE: ScintillaControl received all three, MariaDBBox received only `libmariadb.dll`, and
controls needing none received none.

### New Project and `project.astoria`

The two-mode dialog (Create Local / Use Existing Git) is owner-verified, including the
`.gitignore`/`.gitattributes` stamping, the AI-friendly marking, and the clone-refusal path for
repositories that are not Astoria projects. Verifying AI-friendly stamping surfaced and fixed a
real bug — write-only `.vfp` metadata keys being dropped by the IDE's first project save.

### Git workflow

Commit, Pull and Push from the Git menu, plus SSH key setup and remote repository creation, are
owner-verified **against GitHub**. GitHub is currently the only provider offered, so this is full
coverage of what ships.

The complete ongoing workflow is owner-verified by TestPlan D3: create through **Use Existing Git
Project**, follow the browser-assisted missing-repository path (repository name copied to the
clipboard), edit, commit, push and pull from Astoria's Git menu. As an additional parity check, a
tracked file deleted locally was not restored by Pull, exactly matching command-line Git: the
deletion remains an uncommitted working-tree change until restored with `git restore <path>` or
committed.

### Installer

Owner-verified through a full clean install and uninstall cycle: per-user install with no
elevation prompt, Start Menu and desktop shortcuts, and the seeded `ProjectsPath` pointing at a
findable location rather than the hidden install folder.

**Known limitation:** the installed app does not appear in Control Panel ▸ Programs and Features,
despite a well-formed uninstall registry entry. Most likely because the executables are unsigned.
Uninstall via the Start Menu shortcut works correctly.

### User interface

**ScintillaControl** (TestPlan A6): text round-trip, line addressing, selection replacement, undo,
redo, and style colour round-trips — 8 assertions, all passing. Its undo history is Scintilla's own
and independent of the framework's.

**Native dialog return values** (TestPlan A8): owner-verified 2026-07-19 with the reusable
`Examples/Integration/A8_DialogValues` fixture. OpenFile returned the exact selected file path;
SaveFile returned the exact path chosen by the tester; Color returned `16711680` and changed the
preview; and Font returned Arial Black at 18 pt with italic enabled. The fixture's Save status said
FAIL because the tester chose `A8-results.txt` rather than the suggested `A8-selected.txt`, but the
returned value itself proves the component contract under test. The application stayed alive
through every dialog and retry, then closed without a crash. An earlier Open crash was diagnosed as
a fixture wiring error: its hand-built buttons lacked `.Designer = @This`, so the event handler
received a null owner. After correcting that fixture error, the complete run passed.

**Form designer, Section C of the test plan — C1–C6 all pass; the section is complete.** Place-and-wire (C1),
save/reopen round-trip fidelity (C2), multi-select align/size with undo (C4), cross-form copy/paste
including name-collision resolution (C5), and split-view focus tracking (C6) all pass. **C3 now
passes too**, after a fix: renaming a control used to update the sites describing it but nothing
referencing it, leaving the project unbuildable (ROADMAP §13.17). Section C is complete.

Designer keyboard commands — Ctrl+Z/Ctrl+Y/Ctrl+X/Ctrl+C/Ctrl+V — work in both the code editor and
the designer after the Code/Form menu restructure, with Code and Form still greying contextually.

Two of these were measured rather than observed, which is worth imitating. C6 sampled Windows' own
top-level menu state four times a second and logged the transitions, because that is the state
`TranslateAccelerator` consults — so it proves the shortcuts *can fire*, not merely that the menu
looks right. C5 read the resulting `.frm` through the agent pipe and checked control names, the
declaration line, bounds and the rebuild, rather than trusting the screen.

Owner walkthroughs of the View menu (which surfaced six real bugs, all fixed), the Code/Form menu
restructure and contextual greying, the Run menu consolidation, context-menu parity with the
toolbars, and a toolbar tooltip audit across 13 buttons plus the Image Manager toolbar.

### Settings

Verified that a missing `astoria.ini` is rebuilt from the shipped defaults template rather than
leaving the IDE silently unable to save.

### Reloading files changed outside the IDE

Owner-verified 2026-07-19. When a file open in the IDE is changed on disk by something else — a
`git pull`, an AI assistant, a sync client, another editor — clicking back into the IDE now raises
a single prompt naming the shared folder once and listing every changed file distinctly, and
accepting it reloads them all.

This began as a hang: the prompt used to be raised from inside the application-activation handler,
where a modal disables its owner and may never come to the front, leaving the IDE unresponsive with
nothing on screen to answer (ROADMAP §13.18). It is now posted and shown after activation completes.

**Two further defects were found by testing the fix, which is the argument for testing fixes rather
than shipping them.** The first crashed the IDE on accepting a reload — an array of `UString` grown
with `ReDim Preserve`, which shallow-copies a heap-owning type and double-frees it. That crash also
lost the workspace, because `SaveWorkspace` runs only on a clean close, making it look like a third
separate bug. The second made the prompt *appear* to list only one of two changed files: it listed
both, but `MsgBoxForm` clips unbreakable text at a fixed width, and two paths sharing a directory
prefix clip to the same visible string (ROADMAP §13.22, still open — it will affect any dialog that
shows a path).

### Designer round-trip

The designer has been exercised end to end (TestPlan C1): controls placed, properties set in the
grid, an event handler wired, then built and run. The handler is declared, assigned and implemented,
the includes match exactly the controls placed, user code sits outside the region the designer
rewrites, and no line of the original file was removed or altered. Separately, a designer edit was
made to an existing form and the file diffed byte for byte (TestPlan C2). The only
difference is the edit itself — the moved control's `SetBounds` line — with every other control,
property, handler, comment and include untouched.

Two other differences appeared and neither is a defect. The UTF-8 BOM is removed on save **by
design**: FreeBASIC treats a BOM as a signal to make string literals wide, so a BOM'd source
prints garbled console output, and the IDE normalises to BOM-less UTF-8 (the agent build does the
same downgrade). And deleting a control leaves its `#include` behind, which is safer than removing
a line the user may depend on elsewhere.

## A worked example: when reading the code lies

Recorded because the debugging pattern generalises, and because the failure mode was expensive.

**Symptom.** Ctrl+Z did nothing on the form designer. No error, no log entry, no visible effect.

**Four fixes were proposed and built before the cause was known**, each reasoned from reading the
source, each plausible, each wrong: route Undo through the designer branch of the menu dispatcher;
move it into the shared dispatcher; add a keyboard handler to `Designer.KeyDown`; enable the menu
item when the designer has focus. Every one of them was built and every one failed, because all
four assumed the keystroke was *reaching* the application.

**It was not.** Instrumentation — not reading — showed the truth in stages:

1. A bare `Z` reached the designer's window procedure; with Ctrl held, only `VK_CONTROL` arrived.
2. `mClick` was never entered, so no menu command was being dispatched.
3. A/B against **F5**, which works, showed both keys were consumed identically by
   `TranslateAccelerator` — but only F5 produced a `WM_COMMAND`.
4. Undo lived in the **Code** menu, which greys in Form view. **Windows suppresses an accelerator
   whose parent menu is disabled**: it consumes the keystroke and sends no command at all.

**The transferable lesson.** *Greying a top-level menu silently disables every keyboard shortcut
inside it.* Any command valid in more than one context must live in a menu that is never greyed —
which is why the **Code/Form** menu now exists.

**The method lesson.** Every conclusion drawn from reading the code was wrong; every conclusion
drawn from a trace was right. When a symptom is *nothing happens at all*, prove where the input
dies before proposing what to fix. A diagnosis that has not been measured is a hypothesis, and
should be labelled as one — the earlier written-up diagnosis of this bug ("the designer has no
undo") read with complete confidence and was false, and its recommended fix would have made the
breakage permanent.

## Known gaps — not yet tested

Stated plainly, because a tester's time is best spent here.

| Area | Status |
| --- | --- |
| **Database connectivity** | **SQLite3 is now proven** (2026-07-18): create, insert, query, aggregate, update, delete, and values surviving a close and reopen — 26 assertions, all passing. Testing it found and fixed a real defect in `AddField`. **Error handling is proven too** (A2, 20 assertions): missing tables, bad SQL, use after close and impossible paths all report rather than crash, and the component stays usable afterwards — but note it reports failures *only* through its `OnErrorOut` event, so a program that does not wire that event sees a failed query as an empty result. **`MariaDBBox` is now proven too** (A3, 2026-07-18, against MariaDB 10.6.8): the data path works end to end, including a non-ASCII UTF-8 round trip and values surviving a real disconnect and reconnect — 24 assertions, all passing. **Testing it found four real defects, all since fixed** (ROADMAP §13.20): `CreateTable` emitted SQLite syntax and could never create a table; `AddField` failed to quote text defaults; `AddField` silently made columns `NOT NULL` while *reporting success*; and `Insert` returned 0 whether it succeeded or failed, so a caller could not detect a failed insert. The component was a copy of `SQLite3Component` that had evidently never been run against a server — two of its four defects were invisible in a return code, which is why the test now asserts on `information_schema` and on observed effects rather than on what a call claims about itself. After the fixes, 34 assertions pass. `Insert` now returns the new row id, or `-1` on failure. See [TestPlan.md](TestPlan.md) A1, A2 and A3. |
| **WebBrowser rendering** | **Fixed and verified 2026-07-18.** The control could not render at all: it hosted the retired Internet Explorer engine through ATL `AtlAxWin`, whose host window was created with empty text, so nothing was instantiated and `Navigate` crashed the program. It now hosts **WebView2** (Edge/Chromium), which is the default on Windows. A page renders with its content confirmed twice over — the marker token read back from the DOM, and a screenshot of the window. **Navigation and history are verified too** (TestPlan A5): following a link, `GoBack` and `GoForward` each land on the expected page, asserted on both the DOM and the URL. Verified end to end through a real IDE build: the project links and `WebView2Loader.dll` is copied beside the exe. Requires the WebView2 runtime, which ships with Edge on Windows 10/11. See [TestPlan.md](TestPlan.md) A4. |
| **Any single control in depth** | **Covered for the seven common controls as of 2026-07-18** (TestPlan A7, 50 assertions): properties set and read back — cross-checked against the real window, not just the wrapper — and one real event fired per control. ScintillaControl is additionally covered for editing, undo/redo and styling (A6). The remaining controls still have only the sweep's "it compiles and its window opens", so a control outside those seven can still pass and misbehave in use. |
| **Controls used together** | **Complete as of 2026-07-18 — all 13 planned scenarios pass.** Data-entry forms, tab-order traversal, nested containers, docking and box layouts under resize, list/detail selection, a shared ImageList across three consumers, full application chrome, timer-driven progress, second forms, database-to-view, a browser composite, and 26 control types on one form. Between them these found a framework shift-key bug, two silent image-index traps, and two build-configuration requirements. See [TestPlan.md](TestPlan.md) § B. |
| **Multi-machine / fresh user** | All testing to date is by one developer on two of their own machines. Nothing has been tested by someone encountering Astoria for the first time — the specific reason human testers are being sought. |
| **Clean-machine install** | The installer is verified on a development machine. It has not been installed on a machine without a FreeBASIC toolchain already present. |
| **Performance and scale** | No testing with large projects, long files, or many open documents. |
| **Accessibility** | Untested — screen readers, keyboard-only navigation, high-DPI and high-contrast modes. |
| **Debugger breadth** | DR-1..DR-16 closed known defects. There has been no systematic sweep of debugger features against a matrix of program types. |
| **AI templates beyond Claude Code** | The Claude Code template is exercised regularly in real use. The Codex, Cursor, Kun and OpenCode templates have had their MCP configuration written but not verified against those clients. |
| **Form designer breadth** | **Partly closed as of 2026-07-18.** The designer's core workflows are now covered by TestPlan C1–C6 (place and wire, round-trip, multi-select operations, cross-form paste, split-view focus), and one real defect remains from it — C3, renaming a control breaks the build (§13.17). What is still untested is *breadth*: those tests exercise a handful of common controls, not every control's design-time behaviour, so a less-used control could still misbehave in the designer. |

## For human testers

The most useful things you can do, roughly in order:

1. **Install from the installer, not the repository**, on a machine that has never had Astoria or
   FreeBASIC on it. That path has the least coverage and the highest chance of a first-run problem.
2. **Create a project from scratch and build it** — both a Console Application and a Windows
   Application. Then do it again using the Git mode against a repository of your own.
3. **Use the form designer in anger.** Place controls, set properties, wire events, and build.
   Depth here is exactly what our testing lacks.
4. **Tell us what confused you**, not only what broke. Astoria's central claim is that it is
   approachable; a moment of confusion is a bug against that claim.
5. **If you use an AI assistant**, try it through the MCP integration and tell us how the
   experience compared to your assistant working on files from outside.

Report anything you find, including things you are unsure about. A duplicate report costs us a
minute; an unreported problem can cost a release.

## Maintaining this document

Add to it whenever testing happens, in the same commit as the change being tested where possible.
Two rules:

- **Update the reference documents too, in the same pass.** A test result that changes what a
  control does, warns about, or requires belongs in [Controls.md](Controls.md) and
  [ControlTesting.md](ControlTesting.md) as well as here. Those drift precisely because nothing
  forces a visit to them — see the rule table at the top of [TestPlan.md](TestPlan.md).
- **State the assertion, not the conclusion.** "Launched and matched the expected window title" is
  useful; "works" is not, and cannot be re-checked later.
- **Move items out of [Known gaps](#known-gaps--not-yet-tested) only when they are genuinely
  tested.** That table is the honest part of this document and is worth more than the rest of it.
