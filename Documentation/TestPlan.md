# Astoria IDE — Test Plan

The forward-looking companion to [Testing.md](Testing.md). Testing.md records what **has** been
tested; this document lists what **should** be, as named scenarios with a result recorded against
each one. It is maintained as we go: run a test, fill in its row, in the same commit as any fix it
produced.

It exists because the coverage so far is a mile wide and an inch deep. The 73-control sweep proved
every control compiles and opens its window — but nothing about properties, events, or what happens
when controls are used **together**, which is how they are actually used. A control that passes
alone can still break when docked inside a container, or when its events fire while another control
holds focus. Those interactions are where the remaining defects most likely live.

Related: [ControlTesting.md](ControlTesting.md) for per-control results, [Controls.md](Controls.md)
for what each control is, [FrameworkFeatures.md](FrameworkFeatures.md) for the framework surface.

## How to read this

**Status:** ✅ pass · ❌ fail · ⚠️ partial (see Result) · `-` not yet run

**Who runs it** — the important column, and the reason this plan is structured the way it is:

| Mark | Meaning |
| --- | --- |
| 🤖 **Agent** | I can run it unattended, end to end, and assert on a real observable. Preferred: repeatable, and cheap enough to re-run every release. |
| 🤝 **Assisted** | I drive the mechanics and capture the evidence; a human makes the final judgement call — usually "is this *right*", not "did it happen". |
| 👤 **Human** | Needs a person: fresh eyes, assistive technology, a clean machine, or a judgement about whether something is confusing. |

### What "agent-automatable" actually means here

Proven capabilities, each already used on this project:

- **Drive the IDE over the agent pipe (MCP)** — create projects, write files, build, read build
  errors, run programs and capture their console output.
- **Drive the IDE's own UI from outside** — enumerate windows and controls, read control state
  (list contents, selection, enabled/checked), click buttons, send keystrokes, open menus, and
  inspect menu item state including icons.
- **Capture a screenshot and visually inspect it.** This is what makes rendering testable without
  a human: a window can be captured to PNG and read back as an image. Verified 2026-07-18.
- **Inspect side effects on disk** — settings files, project files, generated `.frm`/`.rc`,
  git state, process lifetime (including orphaned processes).

Honest limits: I cannot judge whether something is *confusing*, cannot use a screen reader or
assistive technology, have no clean machine without a FreeBASIC toolchain, and cannot substitute
for someone meeting Astoria for the first time. Anything resting on those is 👤 by definition —
see [Testing.md § For human testers](Testing.md#for-human-testers).

---

## Section A — Depth on single components

Closing the "no control tested in depth" and "database/WebBrowser unproven" gaps from Testing.md.
Each of these goes beyond "it opens": set properties, fire events, read results back.

| ID | Scenario | What it proves | Who | Status | Result |
| --- | --- | --- | --- | --- | --- |
| A1 | **SQLite3Component data path** — create a database, create a table, insert rows, query them back, verify the values, close. | The database data path works, not merely that it compiles. Closes the single largest known gap. | 🤖 | ✅ | 26/26 checks. Insert, count, conditional count, scalar reads, SUM, full ordered result set (every row and column asserted), update, delete, and values surviving close+reopen. **Found a real defect:** `AddField(t, f, type)` could never succeed — `nNull` defaults to 0 (meaning NOT NULL) with no default value, and SQLite refuses to add such a column to an existing table. Text defaults were also emitted unquoted (`DEFAULT PNG`), parsed as a column name. Both fixed in `SQLite3Component.AddField`; regression checks added here. Run: `Examples/Integration/A1_SQLite3DataPath`. |
| A2 | **SQLite3Component error handling** — query a missing table, open an unwritable path. | Failures surface as errors rather than crashing or silently returning empty. | 🤖 | - | |
| A3 | **MariaDBBox connection** — connect to a real MariaDB/MySQL server, query, read a result set. | Same as A1 for the client-server driver. Needs a reachable server, so a human must provide or stand one up. | 🤝 | - | |
| A4 | **WebBrowser rendering** — navigate to a local HTML file with known text and a known colour, screenshot, confirm the page actually rendered. | Page rendering, the second-largest gap. A screenshot makes this agent-checkable. | 🤖 | ✅ | **Failed first, then fixed.** As shipped the control could not render and crashed on `Navigate`: it hosted the retired IE engine via ATL `AtlAxWin`, whose host window was created with empty text, so no control was instantiated and the `IWebBrowser2` pointers stayed null. Reproduced from both a timer callback and a button click. **Fixed by moving to WebView2** (upstream MyFbFramework's implementation, which this fork's copy lacked), made the *default* on Windows so a user dropping the control gets a working one without knowing a `#define` exists. Now passes on both kinds of evidence: `DOM_OK` — marker token read back from the DOM after 2s, body length 558, correct URL — and a screenshot showing the page's heading, colours and yellow block. Verified end to end through a real IDE build, which links and copies `WebView2Loader.dll` beside the exe. Run: `Examples/Integration/A4_WebBrowserRender`. |
| A5 | **WebBrowser navigation** — follow a link, go back, read the resulting URL/title. | Navigation and history, not just first paint. | 🤖 | ✅ | 4/4. Page one loaded; the link was **clicked in the page** (`ExecuteScript` → `element.click()`) rather than navigated to directly, so this tests link-following and creates the history entry; `GoBack` returned to page one; `GoForward` returned to page two. Each step asserts both the expected page token in the DOM and the resulting URL. Screenshot confirms it ends on page two. Run: `Examples/Integration/A4_WebBrowserRender/A5_WebBrowserNavigate.bas`. |
| A6 | **ScintillaControl editing** — set text, apply styling, read text back, exercise undo/redo. | The editor control used by the IDE itself behaves under programmatic use. | 🤖 | - | |
| A7 | **Common control property/event depth** — for TextBox, ComboBox, ListView, TreeView, CheckBox, RadioButton, CommandButton: set representative properties, trigger each documented event, assert the handler ran and read state back. | Turns "the window opened" into real coverage for the controls most programs actually use. | 🤖 | - | |
| A8 | **Dialog components return values** — OpenFile, SaveFile, Color, Font: open from a button, make a selection, confirm the value reaches the program. | Non-visual components deliver results; these can only be confirmed by driving the native dialog. | 🤝 | - | |

## Section B — Multi-component integration

The core of this plan. Every scenario is a single generated project containing **several**
controls that must cooperate — the case the per-control sweep cannot reach.

| ID | Scenario | What it proves | Who | Status | Result |
| --- | --- | --- | --- | --- | --- |
| B1 | **Data-entry form** — Label + TextBox + ComboBox + CheckBox + RadioButton group + CommandButton. Fill fields, click the button, have the handler read every value and print them. | The most common form shape in existence. Proves event wiring and cross-control value reads. | 🤖 | ✅ | Driven from outside: text typed in with `WM_SETTEXT`, checkbox and radio clicked with `BM_CLICK`, then Submit. The handler read all six controls back correctly. The decisive assertion is the radio group — clicking Beta set `radio_beta=true` **and** `radio_alpha=false`, so the group genuinely deselects, which no single-control test can show. Screenshot matches the reported values. Run: `Examples/Integration/B1_DataEntryForm`. |
| B2 | **Tab order and keyboard traversal** — the B1 form driven entirely by Tab/Shift-Tab/Space/Enter. | Keyboard navigation across mixed control types, and that `TabIndex` means what it says. | 🤖 | - | |
| B3 | **Container nesting** — controls inside GroupBox inside Panel inside TabControl; switch tabs and confirm children survive. | Nested parenting and tab-page switching, a known source of layout bugs. | 🤖 | - | |
| B4 | **Docking and anchoring under resize** — mixed `alTop`/`alLeft`/`alClient`/`alBottom` children; resize the window large, small, and maximised; screenshot each. | Layout maths under real resizing. Astoria's own Options dialog has produced several such bugs. | 🤖 | ✅ | **50/50 checks across five sizes** — design 800×560, large 1200×800, small 420×300, maximised, and restored-after-maximise. Panel rectangles are read in client coordinates and checked against invariants rather than eyeballed: bands span the full width, the left band fills exactly between them, the client panel abuts the left band and fills to the right edge, and there is no gap or overlap at any boundary. Run: `Examples/Integration/B4_DockingResize`. |
| B5 | **Layout boxes** — HorizontalBox/VerticalBox with mixed children and margins, resized. | The box layouts specifically, which the IDE uses heavily and which caused the Options row-spacing work. | 🤖 | - | |
| B6 | **List/detail** — ListView or TreeView selection driving a detail panel of TextBoxes. | Selection events propagating between controls; the second-most-common form shape. | 🤖 | ✅ | Driven by real keyboard input (arrow keys on the focused ListView): down → `Grace/Rear Admiral`, down → `Alan/Cryptanalyst`, up → back to `Grace`. The detail TextBoxes are read *back out* after being written, so the file reports what they hold rather than what was meant. The fire count increments exactly once per change — no missed or duplicated events. Note: `LVM_SETITEMSTATE` sent from outside did **not** raise `OnSelectedItemChanged`; keyboard selection did. Worth knowing before relying on programmatic selection. Run: `Examples/Integration/B6_ListDetail`. |
| B7 | **Shared ImageList** — one ImageList feeding a ToolBar, a TreeView and a ListView at once. | A non-visual component shared by three consumers — exactly the sharing that broke menu icons in the IDE. | 🤖 | - | |
| B8 | **Menu + ToolBar + StatusBar together** — a form with all three, wired to the same commands. | The full application chrome co-existing on one form. | 🤖 | - | |
| B9 | **Timer + ProgressBar** — a timer advancing a progress bar while the UI stays responsive. | Periodic UI updates without freezing; a classic source of message-loop bugs. | 🤖 | - | |
| B10 | **Second form** — main form opens a modal dialog and a modeless window, passes data both ways, closes them. | Multi-form lifetime and ownership — the area that produced the modal z-order defect in the IDE itself. | 🤖 | ✅ | Modal round trip: value sent in, edited in the dialog, `ModalResult` OK honoured, `edited-in-dialog` read back into the main form. Modeless: both windows visible simultaneously and the main form's message loop still pumping while it was open. **Z-order is owner-verified** — the owner watched repeated runs and confirmed the dialog always appears in front of its owner. The test is deliberately **self-driving and self-exiting**: an earlier externally-driven version parked a window on the tester's desktop for as long as the driving script ran. Writing it also surfaced a re-entrancy trap worth knowing — a thread timer keeps firing inside `ShowModal`'s own message loop, so the first version opened three nested dialogs; the shipped version guards against it. Run: `Examples/Integration/B10_SecondForm` (no interaction needed). |
| B11 | **Database → view** — SQLite3Component query results populating a ListView. | Ties Section A's data path to a real display path. The realistic reason anyone uses the DB controls. | 🤖 | - | |
| B12 | **WebBrowser + controls** — address TextBox + Go button + status Label driving a WebBrowser. | The composite that a WebBrowser is always part of; also re-tests A4/A5 in context. | 🤖 | - | |
| B13 | **Everything form** — one form carrying at least 20 different controls, built, run, screenshotted, closed. | A blunt smoke test for resource, handle or ID exhaustion that only appears at density. | 🤖 | - | |

## Section C — Designer integration

Section B tests controls at **runtime**. These test the same combinations at **design time**, in
the IDE — which is where a first-time user meets them, and which Testing.md lists as never
systematically covered.

| ID | Scenario | What it proves | Who | Status | Result |
| --- | --- | --- | --- | --- | --- |
| C1 | **Place and wire in the designer** — drop several controls onto a form, set properties in the property grid, wire event handlers, build and run. | The designer round-trip end to end, as a human does it. | 🤝 | - | |
| C2 | **Designer round-trip fidelity** — save, close, reopen the project; confirm every control, property and handler survived. | `.frm` generation and re-parsing, the file format the whole product depends on. | 🤖 | - | |
| C3 | **Rename a control that events reference** — rename, then confirm handlers still bind and the project still builds. | Refactoring safety in the designer. A likely defect area. | 🤝 | - | |
| C4 | **Multi-select operations** — select several controls, align/size/space them, undo, redo. | The Form Designer menu's core value, against multiple controls at once. | 🤝 | - | |
| C5 | **Copy/paste between forms** — copy a control group from one form and paste into another. | Cross-form clipboard handling and name-collision behaviour. | 🤝 | - | |
| C6 | **Split view with designer** — edit code and form side by side, switch focus, confirm the Code/Form menus track the active pane. | The split-view focus tracking added this cycle, in combination rather than alone. | 🤖 | - | |

## Section D — Whole-workflow scenarios

End-to-end paths a real user takes, each crossing several IDE subsystems.

| ID | Scenario | What it proves | Who | Status | Result |
| --- | --- | --- | --- | --- | --- |
| D1 | **Console app lifecycle** — create, edit, build, run, read output, close, reopen. | The simplest complete path. Regression canary for everything else. | 🤖 | - | |
| D2 | **Windows app lifecycle** — same, with a form and the designer. | The default path for a new user, given Windows Application is the default template. | 🤝 | - | |
| D3 | **Git: local project** — create local, add files, commit and push from the Project menu. | The Git menu against a real remote. | 🤝 | - | |
| D4 | **Git: clone existing** — all three clone classifications (empty, Astoria project, foreign/refused). | Owner-verified 2026-07-18; re-run each release. | 🤝 | ✅ | Owner-verified: all three paths behave; module fields grey out for a complete project. |
| D5 | **AI/MCP multi-file project** — an assistant creates a project, writes several files, builds, fixes an error, runs. | The MCP integration on something larger than one file. | 🤖 | - | |
| D6 | **Debugger against a multi-form program** — breakpoints in event handlers, step, inspect locals and watches, stop, confirm no orphaned process. | Debugger breadth, listed as a gap, against a realistic program rather than a toy. | 🤝 | - | |
| D7 | **AI templates beyond Claude Code** — verify the ChatGPT, Cursor, Kun and OpenCode template MCP configs against those clients. | Listed as a gap; each needs its own client installed. | 👤 | - | |

## Section E — Environment and robustness

| ID | Scenario | What it proves | Who | Status | Result |
| --- | --- | --- | --- | --- | --- |
| E1 | **Missing settings file** — delete `astoria.ini`, start, confirm it is rebuilt from the template with all sections. | Verified 2026-07-18. Re-run each release. | 🤖 | ✅ | Rebuilt from `astoria.default.ini`; all sections present; terminal dropdown populated. |
| E2 | **Corrupt settings file** — truncate it, fill it with garbage, remove a section; start each time. | Recovery from damage, not just absence. Untested. | 🤖 | - | |
| E3 | **Deleted project recovery** — delete an open project's folder outside the IDE, restart. | Verified 2026-07-18: opens with no project and no error dialog, and prunes the recent list. | 🤖 | ✅ | No modal; stale recent entries pruned. |
| E4 | **Scale: large file** — open a very large source file; measure open, scroll, and edit responsiveness. | Performance, listed as wholly untested. | 🤖 | - | |
| E5 | **Scale: many documents** — open 50+ documents and several projects at once. | Handle and memory behaviour under load. | 🤖 | - | |
| E6 | **Scale: large project** — a project with a large number of source files and forms. | Project tree, parsing and build times at size. | 🤖 | - | |
| E7 | **Clean-machine install** — install from the installer on a machine that has never had Astoria or FreeBASIC. | The highest-risk untested path. Needs a clean machine or VM. | 👤 | - | |
| E8 | **High-DPI and scaling** — 125%/150%/200%, and a monitor change while running. | Layout under scaling. Partially checkable by screenshot; a person should confirm it looks right. | 🤝 | - | |
| E9 | **Keyboard-only operation of the IDE** — create, edit, build and run without touching the mouse. | Accessibility baseline, and a good approachability signal. | 🤝 | - | |
| E10 | **Screen reader and high contrast** — exercise with a screen reader and in high-contrast mode. | Accessibility proper. Cannot be simulated; needs a person with the tooling. | 👤 | - | |

---

## How these get run

Sections A, B and most of D1/D5 are generated projects driven over the agent pipe, the same
mechanism as the 73-control sweep — so they can live under `Examples/Integration/` beside
`Examples/Controls/`, with sources committed and binaries ignored. That makes every one of them
reproducible by opening its `.vfp` and pressing build, which is the property that made the control
sweep useful to a human tester afterwards.

Priority order, highest value first:

1. **A1, A4** — the two named gaps in Testing.md that a screenshot and a query now make checkable.
2. **B1, B4, B6, B10** — the four commonest form shapes, where integration bugs are most likely.
3. **C2** — `.frm` round-trip fidelity, because a defect there damages user projects rather than
   merely misbehaving.
4. Everything else as time allows; 👤 items go to human testers as they arrive.

## Maintaining this document

- **Fill in the Result column with the assertion, not a verdict.** "Queried 3 inserted rows and
  matched all field values" is re-checkable; "works" is not. This mirrors the rule in Testing.md.
- **A test that fails stays ❌ with a note**, and gets a line in Testing.md's known gaps if it
  represents a real limitation rather than a fixable bug.
- **When a scenario passes, also record it in [Testing.md](Testing.md)** — that document remains
  the summary a tester reads first; this one is the detail behind it.
- **Add scenarios as they occur to you.** A test that was worth running once is worth a row here,
  so the next release re-runs it.
