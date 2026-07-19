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

### Installer

Owner-verified through a full clean install and uninstall cycle: per-user install with no
elevation prompt, Start Menu and desktop shortcuts, and the seeded `ProjectsPath` pointing at a
findable location rather than the hidden install folder.

**Known limitation:** the installed app does not appear in Control Panel ▸ Programs and Features,
despite a well-formed uninstall registry entry. Most likely because the executables are unsigned.
Uninstall via the Start Menu shortcut works correctly.

### User interface

Owner walkthroughs of the View menu (which surfaced six real bugs, all fixed), the Code/Form menu
restructure and contextual greying, the Run menu consolidation, context-menu parity with the
toolbars, and a toolbar tooltip audit across 13 buttons plus the Image Manager toolbar.

### Settings

Verified that a missing `astoria.ini` is rebuilt from the shipped defaults template rather than
leaving the IDE silently unable to save.

## Known gaps — not yet tested

Stated plainly, because a tester's time is best spent here.

| Area | Status |
| --- | --- |
| **Database connectivity** | **SQLite3 is now proven** (2026-07-18): create, insert, query, aggregate, update, delete, and values surviving a close and reopen — 26 assertions, all passing. Testing it found and fixed a real defect in `AddField`. `MariaDBBox` remains unproven beyond compiling; it needs a reachable server. See [TestPlan.md](TestPlan.md) A1 and A3. |
| **WebBrowser rendering** | **Fixed and verified 2026-07-18.** The control could not render at all: it hosted the retired Internet Explorer engine through ATL `AtlAxWin`, whose host window was created with empty text, so nothing was instantiated and `Navigate` crashed the program. It now hosts **WebView2** (Edge/Chromium), which is the default on Windows. A page renders with its content confirmed twice over — the marker token read back from the DOM, and a screenshot of the window. **Navigation and history are verified too** (TestPlan A5): following a link, `GoBack` and `GoForward` each land on the expected page, asserted on both the DOM and the URL. Verified end to end through a real IDE build: the project links and `WebView2Loader.dll` is copied beside the exe. Requires the WebView2 runtime, which ships with Edge on Windows 10/11. See [TestPlan.md](TestPlan.md) A4. |
| **Any single control in depth** | The control sweep proves each control compiles and its window opens. It does not exercise properties, events, or interaction. A control can pass and still misbehave in use. Planned as [TestPlan.md](TestPlan.md) § A. |
| **Controls used together** | **Complete as of 2026-07-18 — all 13 planned scenarios pass.** Data-entry forms, tab-order traversal, nested containers, docking and box layouts under resize, list/detail selection, a shared ImageList across three consumers, full application chrome, timer-driven progress, second forms, database-to-view, a browser composite, and 26 control types on one form. Between them these found a framework shift-key bug, two silent image-index traps, and two build-configuration requirements. See [TestPlan.md](TestPlan.md) § B. |
| **Multi-machine / fresh user** | All testing to date is by one developer on two of their own machines. Nothing has been tested by someone encountering Astoria for the first time — the specific reason human testers are being sought. |
| **Clean-machine install** | The installer is verified on a development machine. It has not been installed on a machine without a FreeBASIC toolchain already present. |
| **Performance and scale** | No testing with large projects, long files, or many open documents. |
| **Accessibility** | Untested — screen readers, keyboard-only navigation, high-DPI and high-contrast modes. |
| **Debugger breadth** | DR-1..DR-16 closed known defects. There has been no systematic sweep of debugger features against a matrix of program types. |
| **AI templates beyond Claude Code** | The Claude Code template is exercised regularly in real use. The Codex, Cursor, Kun and OpenCode templates have had their MCP configuration written but not verified against those clients. |
| **Form designer breadth** | Used constantly in development, but never systematically tested against every control's design-time behaviour. |

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

- **State the assertion, not the conclusion.** "Launched and matched the expected window title" is
  useful; "works" is not, and cannot be re-checked later.
- **Move items out of [Known gaps](#known-gaps--not-yet-tested) only when they are genuinely
  tested.** That table is the honest part of this document and is worth more than the rest of it.
