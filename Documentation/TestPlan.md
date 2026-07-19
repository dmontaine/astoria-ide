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

## What the Section A and B fixtures do NOT cover

The fixtures under `Examples/Integration` are single `.bas` files compiled directly with `fbc`. That
makes them fast to write and easy to re-run, and it is fine for what they are for: proving that a
control or a combination of controls *behaves*.

**They do not exercise the build pipeline a user actually travels.** No `.vfp`, no IDE build, no
`.frm` handling, and — the one that bites — **no runtime-DLL copying**, which is driven by the
project. A fixture can therefore pass while the same program, created the way a user creates it,
fails to start.

This is not hypothetical. A6 was first built by hand with its DLLs copied manually, and it passed;
had the project-path copying been broken, it would still have passed. The 73-control sweep in
[ControlTesting.md](ControlTesting.md) does go through the IDE, which is exactly why it caught the
missing `libmariadb.dll` that no Integration fixture would have.

**So: any test whose subject touches deployment — runtime DLLs, resources, the generated `.rc`,
anything the project owns — must also be verified through a real `.vfp` project built by the IDE.**
A6 now carries a `.vfp` for that reason and is verified both ways.

Astoria is project-based by design, and more firmly than it first appears: **with no project open
the IDE offers no Open File command**, so a user cannot reach a loose source file at all, let alone
build one. With a project open, Build targets the project regardless of what else sits in the
editor. The unsupported path is therefore unreachable rather than merely discouraged — no guard is
needed, and one was written and then removed on discovering it could never fire.

Our fixtures reach it only because they are compiled by `fbc` directly, outside the IDE. That is a
convenience for testing, not a workflow, and it is precisely why anything touching deployment has to
be re-verified through a real project.

## Rule: update the documents after every test

**A test is not finished when it passes or fails. It is finished when the documents say what is now
known.** Every test run, do this before moving on:

| Document | Update when |
| --- | --- |
| **TestPlan.md** (this file) | Always — the status mark and a Result that states the assertion, not just "works". |
| **[Testing.md](Testing.md)** | The result changes what is proven or what remains unproven. Move an entry out of *Known gaps* only when genuinely tested; narrow it rather than delete it if only partly covered. |
| **[ControlTesting.md](ControlTesting.md)** | A control's status changes, or it gains/loses a runtime DLL or a caveat. |
| **[Controls.md](Controls.md)** | A control's behaviour, warnings, or "Changed in Astoria" note is now wrong. **This is the one most often missed.** |
| **[FrameworkFeatures.md](FrameworkFeatures.md)** | A non-toolbox framework capability changed. |
| **[DetailedChangelog.md](DetailedChangelog.md)** | Regenerate from history; never hand-edit. |
| **[ROADMAP.md](../ROADMAP.md)** | A test found a defect, or disproved an entry already there. |

**Why this rule exists.** On 2026-07-18 the WebBrowser control went from "cannot render at all" to
"rendering and navigation verified". TestPlan and Testing.md were updated the same day; Controls.md
was not, and for several commits it kept telling readers *"page rendering and navigation have not
been verified — prove it works before relying on it"* about a feature that demonstrably worked. The
runtime-DLL table likewise never gained `WebView2Loader.dll`, the exact omission that table exists
to prevent.

The pattern to guard against: **test documents stay current because running a test forces a visit to
them; reference documents drift, because nothing forces the visit.** A reference document that
understates what works is not harmlessly cautious — it tells users to avoid working features, and it
is read by people who will never see this plan.

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
| A2 | **SQLite3Component error handling** — query a missing table, open an unwritable path. | Failures surface as errors rather than crashing or silently returning empty. | 🤖 | ✅ | 20/20. Missing table, missing column, malformed SQL, insert into a non-existent table, duplicate `CreateTable`, use after `Close`, and an impossible file path. Each case checks three things: it did not crash, an error was actually **reported**, and the return value signals failure rather than looking like a legitimate empty result. Messages come through usefully — `no such table: …`, `near "THIS": syntax error`, `Base not opened`. Nine errors raised across the run. **The thing users need to know:** the component reports failures **only** through its `OnErrorOut` event — return values are `0`/`""`, which is indistinguishable from "no rows matched". A program that does not wire that event sees a failed query as an empty result, silently. That is the single most important fact about using this control. The closing section is the one a happy-path test cannot reach: after all those failures the component is **still usable** — the original row intact, its value correct, and new inserts still working. A component that wedged itself after one bad query would pass every individual check above and still be useless. Run: `Examples/Integration/A2_SQLite3Errors`. |
| A3 | **MariaDBBox connection** — connect to a real MariaDB/MySQL server, query, read a result set. | Same as A1 for the client-server driver. Needs a reachable server, so a human must provide or stand one up. | 🤝 | - | |
| A4 | **WebBrowser rendering** — navigate to a local HTML file with known text and a known colour, screenshot, confirm the page actually rendered. | Page rendering, the second-largest gap. A screenshot makes this agent-checkable. | 🤖 | ✅ | **Failed first, then fixed.** As shipped the control could not render and crashed on `Navigate`: it hosted the retired IE engine via ATL `AtlAxWin`, whose host window was created with empty text, so no control was instantiated and the `IWebBrowser2` pointers stayed null. Reproduced from both a timer callback and a button click. **Fixed by moving to WebView2** (upstream MyFbFramework's implementation, which this fork's copy lacked), made the *default* on Windows so a user dropping the control gets a working one without knowing a `#define` exists. Now passes on both kinds of evidence: `DOM_OK` — marker token read back from the DOM after 2s, body length 558, correct URL — and a screenshot showing the page's heading, colours and yellow block. Verified end to end through a real IDE build, which links and copies `WebView2Loader.dll` beside the exe. Run: `Examples/Integration/A4_WebBrowserRender`. |
| A5 | **WebBrowser navigation** — follow a link, go back, read the resulting URL/title. | Navigation and history, not just first paint. | 🤖 | ✅ | 4/4. Page one loaded; the link was **clicked in the page** (`ExecuteScript` → `element.click()`) rather than navigated to directly, so this tests link-following and creates the history entry; `GoBack` returned to page one; `GoForward` returned to page two. Each step asserts both the expected page token in the DOM and the resulting URL. Screenshot confirms it ends on page two. Run: `Examples/Integration/A4_WebBrowserRender/A5_WebBrowserNavigate.bas`. |
| A6 | **ScintillaControl editing** — set text, apply styling, read text back, exercise undo/redo. | The editor control used by the IDE itself behaves under programmatic use. | 🤖 | ✅ | **8/8.** Text round-trip; line addressing (`LineText(0)`/`LineText(2)` return the right lines, proving a genuinely line-structured buffer rather than a string that happens to match); `SelectAll` + `SelText` replacement; **undo restoring the previous text exactly**; redo reapplying it exactly; and style `ForeColor`/`BackColor` set and read back. The undo/redo pair is the interesting result — that history is Scintilla's own, entirely separate from the framework's, and it survives programmatic edits, not just typed ones. Worth having for a control the IDE's own editor is built on. Run: `Examples/Integration/A6_ScintillaEditing`. |
| A7 | **Common control property/event depth** — for TextBox, ComboBox, ListView, TreeView, CheckBox, RadioButton, CommandButton: set representative properties, trigger each documented event, assert the handler ran and read state back. | Turns "the window opened" into real coverage for the controls most programs actually use. | 🤖 | ✅ | 50/50 across seven controls. Properties are set **and read back** — and where it matters, read back from the real window rather than the wrapper: text set through the framework is confirmed with `WM_GETTEXT`, text set with `WM_SETTEXT` is confirmed through the framework, and `Enabled`/`Visible` are cross-checked against `IsWindowEnabled`/`IsWindowVisible`. A value stored but never applied, or applied but never stored, is caught either way. Events are triggered through real messages: `BM_CLICK` for button, checkbox and radio; arrow keys for ListView selection; `ItemIndex` assignment for the combo's `OnChange`; a focus move for the TextBox's `OnLostFocus`. Each handler must actually run — a wired event that never fires is the defect that matters. Also confirmed that setting `Checked` **by property does not** raise `OnClick`, which is what stops a program re-entering its own handler. **Observation worth knowing before automating a UI:** a `BM_CLICK` sent to a *disabled* button still fires its handler. That is Windows, not the framework — a real user click is discarded at hit-test time, but a posted message reaches the button procedure regardless, and `CommandButton` subclasses the native `Button` without intercepting it. Do not use `BM_CLICK` to prove a control is disabled; check `IsWindowEnabled`, which is what actually stops a user. Run: `Examples/Integration/A7_ControlDepth`. |
| A8 | **Dialog components return values** — OpenFile, SaveFile, Color, Font: open from a button, make a selection, confirm the value reaches the program. | Non-visual components deliver results; these can only be confirmed by driving the native dialog. | 🤝 | - | |

## Section B — Multi-component integration

The core of this plan. Every scenario is a single generated project containing **several**
controls that must cooperate — the case the per-control sweep cannot reach.

| ID | Scenario | What it proves | Who | Status | Result |
| --- | --- | --- | --- | --- | --- |
| B1 | **Data-entry form** — Label + TextBox + ComboBox + CheckBox + RadioButton group + CommandButton. Fill fields, click the button, have the handler read every value and print them. | The most common form shape in existence. Proves event wiring and cross-control value reads. | 🤖 | ✅ | Driven from outside: text typed in with `WM_SETTEXT`, checkbox and radio clicked with `BM_CLICK`, then Submit. The handler read all six controls back correctly. The decisive assertion is the radio group — clicking Beta set `radio_beta=true` **and** `radio_alpha=false`, so the group genuinely deselects, which no single-control test can show. Screenshot matches the reported values. Run: `Examples/Integration/B1_DataEntryForm`. |
| B2 | **Tab order and keyboard traversal** — the B1 form driven entirely by Tab/Shift-Tab/Space/Enter. | Keyboard navigation across mixed control types, and that `TabIndex` means what it says. | 🤖 | ✅ | 9/9. Six controls traversed by **posted** VK_TAB messages — posted, not sent, because the pump is what intercepts VK_TAB and a sent message bypasses it. Focus follows TabIndex order across TextBox, CheckBox, ComboBox and buttons, and wraps from last to first. Backward traversal checked both ways: `SelectNextControl(True)` directly, and Shift+Tab through the pump with shift simulated via `SetKeyboardState` (thread-local, so it cannot disturb the machine). **Fixed a latent framework bug it exposed:** the shift test was `GetKeyState(VK_SHIFT) And 8000` in five files — decimal `8000` is `&h1F40`, which shares no bits with the `&h8000` key-down flag. It happened to work for the `-128` state `SetKeyboardState` produces, but evaluates to zero for `&h8000` (-32768), the documented down value. Now `And &h8000`, correct for both. Run: `Examples/Integration/B2_TabTraversal`. |
| B3 | **Container nesting** — controls inside GroupBox inside Panel inside TabControl; switch tabs and confirm children survive. | Nested parenting and tab-page switching, a known source of layout bugs. | 🤖 | ✅ | 22/22. Three levels of nesting verified by asserting the **parent chain** rather than assuming it, then switching to the other tab and back. The assertion this exists for is **handle stability**: every nested control's window handle is unchanged after the round trip, so the framework hides and shows the page rather than destroying and recreating its children — a changed handle would silently break event wiring and anything holding the old handle, while text and state would still look correct. Content, checkbox state, parent chain and visibility all survive too. Run: `Examples/Integration/B3_NestedContainers`. |
| B4 | **Docking and anchoring under resize** — mixed `alTop`/`alLeft`/`alClient`/`alBottom` children; resize the window large, small, and maximised; screenshot each. | Layout maths under real resizing. Astoria's own Options dialog has produced several such bugs. | 🤖 | ✅ | **50/50 checks across five sizes** — design 800×560, large 1200×800, small 420×300, maximised, and restored-after-maximise. Panel rectangles are read in client coordinates and checked against invariants rather than eyeballed: bands span the full width, the left band fills exactly between them, the client panel abuts the left band and fills to the right edge, and there is no gap or overlap at any boundary. Run: `Examples/Integration/B4_DockingResize`. |
| B5 | **Layout boxes** — HorizontalBox/VerticalBox with mixed children and margins, resized. | The box layouts specifically, which the IDE uses heavily and which caused the Options row-spacing work. | 🤖 | ✅ | 30/30 across three sizes. Each box is checked by its **defining property** rather than remembered coordinates: in a VerticalBox children share a left edge and width, stack downward and never overlap; in a HorizontalBox they share a top edge and height and run left to right. Those hold at any size, so the same assertions apply after every resize. Children are deliberately mixed types — a box must not care what it arranges. Run: `Examples/Integration/B5_LayoutBoxes`. |
| B6 | **List/detail** — ListView or TreeView selection driving a detail panel of TextBoxes. | Selection events propagating between controls; the second-most-common form shape. | 🤖 | ✅ | Driven by real keyboard input (arrow keys on the focused ListView): down → `Grace/Rear Admiral`, down → `Alan/Cryptanalyst`, up → back to `Grace`. The detail TextBoxes are read *back out* after being written, so the file reports what they hold rather than what was meant. The fire count increments exactly once per change — no missed or duplicated events. Note: `LVM_SETITEMSTATE` sent from outside did **not** raise `OnSelectedItemChanged`; keyboard selection did. Worth knowing before relying on programmatic selection. Run: `Examples/Integration/B6_ListDetail`. |
| B7 | **Shared ImageList** — one ImageList feeding a ToolBar, a TreeView and a ListView at once. | A non-visual component shared by three consumers — exactly the sharing that broke menu icons in the IDE. | 🤖 | ✅ | 16/16. One list, three consumers, all resolving image keys to the right indices in the supported order (bind the list, then add items). **The hazard is real and not confined to menus:** items added *before* the list is bound get `ImageIndex = -1` silently and permanently — the same trap that killed the menu icons. **A second variant found while writing this:** TreeView's image-key overload requires **both** `Images` *and* `SelectedImages` to be bound; with either missing it assigns `-1` without complaint. Setting only `Images` is the obvious thing to do and it looks exactly like a framework bug. Both are recorded in the test's own output so anyone running it sees them. Run: `Examples/Integration/B7_SharedImageList`. |
| B8 | **Menu + ToolBar + StatusBar together** — a form with all three, wired to the same commands. | The full application chrome co-existing on one form. | 🤖 | ✅ | 16/16. Menu item and toolbar button wired to the **same handler**, with the status bar reporting each — so a toolbar that quietly did something different from the menu item it mirrors would show up immediately. Both routes reach one handler and advance one counter. The body panel is confirmed to start below the toolbar and fit inside the client area, proving the chrome claimed space from the edges rather than covering the content. **Observation:** `StatusBar.Top` reports `2` rather than its on-screen position, so layout must not be computed from it — the first version of this check asserted against it and failed for that reason. Run: `Examples/Integration/B8_MenuToolbarStatus`. |
| B9 | **Timer + ProgressBar** — a timer advancing a progress bar while the UI stays responsive. | Periodic UI updates without freezing; a classic source of message-loop bugs. | 🤖 | ✅ | 7/7. The bar is checked at **every step**, not just at the end, so a dropped update cannot hide behind a correct final value. Responsiveness is asserted rather than assumed: a second, independent timer runs throughout and is counted — 24 heartbeat ticks arrived during the work, so the loop was never starved. Checking only that the bar reached its maximum would say nothing about whether the window was alive while it did. Run: `Examples/Integration/B9_TimerProgress`. |
| B10 | **Second form** — main form opens a modal dialog and a modeless window, passes data both ways, closes them. | Multi-form lifetime and ownership — the area that produced the modal z-order defect in the IDE itself. | 🤖 | ✅ | Modal round trip: value sent in, edited in the dialog, `ModalResult` OK honoured, `edited-in-dialog` read back into the main form. Modeless: both windows visible simultaneously and the main form's message loop still pumping while it was open. **Z-order is owner-verified** — the owner watched repeated runs and confirmed the dialog always appears in front of its owner. The test is deliberately **self-driving and self-exiting**: an earlier externally-driven version parked a window on the tester's desktop for as long as the driving script ran. Writing it also surfaced a re-entrancy trap worth knowing — a thread timer keeps firing inside `ShowModal`'s own message loop, so the first version opened three nested dialogs; the shipped version guards against it. Run: `Examples/Integration/B10_SecondForm` (no interaction needed). |
| B11 | **Database → view** — SQLite3Component query results populating a ListView. | Ties Section A's data path to a real display path. The realistic reason anyone uses the DB controls. | 🤖 | ✅ | 13/13. Rows inserted, queried with `ORDER BY`, then loaded into a ListView — and the **view is compared against the query cell by cell**, not against the values the test remembers inserting, so a populate loop that dropped or reordered a row could not pass a count-only check. Alphabetical ordering is asserted separately from insertion order, and the status label reflects the load. **Found an include-order trap:** including `SQLite3Component.bi` *before* the framework makes `Control.bas` fail to compile on `WM_POINTERDOWN` and friends — the control library pulls in `windows.bi` first, so the framework's own Windows-version include becomes a no-op. Put `mff/` first, as the shipped examples do. Run: `Examples/Integration/B11_DatabaseToView`. |
| B12 | **WebBrowser + controls** — address TextBox + Go button + status Label driving a WebBrowser. | The composite that a WebBrowser is always part of; also re-tests A4/A5 in context. | 🤖 | ✅ | 10/10. The URL is typed into the TextBox with `WM_SETTEXT`, the Go button clicked with `BM_CLICK`, and the handler reads the address out of one control, hands it to the browser, and reports through a third — three controls cooperating on one action. The page's marker token is confirmed in the DOM and the browser's own `GetURL` is matched against what was typed. It also checks the **other controls survive**: after the browser has loaded a page, the address box is still readable, the button still has its caption, and the browser is still on the form — a heavyweight control taking over its host is exactly what a composite can expose. This is the first exercise of the new WebView2 backend alongside other controls rather than alone. Run: `Examples/Integration/B12_BrowserComposite`. |
| B13 | **Everything form** — one form carrying at least 20 different controls, built, run, screenshotted, closed. | A blunt smoke test for resource, handle or ID exhaustion that only appears at density. | 🤖 | ✅ | 7/7 with **26 different control types** on one form: every control got a real window handle, no two share a handle, first/middle/last controls still hold their text (so no later creation corrupted an earlier one), and the message loop survives. **Found a build-configuration trap:** the first run failed with *"Unable to register class 'LinkLabel'"*. `LinkLabel` wraps `SysLink`, which only exists with ComCtl32 v6 — available only when the program embeds a manifest. The IDE adds one to every project, so a user never sees this; a hand-run `fbc` build does. The whole integration suite now builds with a manifest, matching what the IDE produces. Run: `Examples/Integration/B13_ControlDensity`. |

## Section C — Designer integration

Section B tests controls at **runtime**. These test the same combinations at **design time**, in
the IDE — which is where a first-time user meets them, and which Testing.md lists as never
systematically covered.

| ID | Scenario | What it proves | Who | Status | Result |
| --- | --- | --- | --- | --- | --- |
| C1 | **Place and wire in the designer** — drop several controls onto a form, set properties in the property grid, wire event handlers, build and run. | The designer round-trip end to end, as a human does it. | 🤝 | ✅ | Owner started from an empty Windows Application form, placed a TextBox, CommandButton and Label, set properties in the grid, wired a click handler with one line of code, then built and ran it. Everything held: the three controls are declared and constructed with the properties that were set; the **matching `#include` lines were added for exactly the three controls placed** — no more, no fewer, which is the concern B7 and C2 raised about include handling; the event handler is **declared, assigned and implemented** (`Declare Sub`, `.OnClick = Cast(...)`, and the `Private Sub` body), not left as a stray procedure; and the handler body sits **outside** `'#End Region`, so user code lives beyond the block the designer rewrites. Diffed against the empty baseline, **no original line was removed or altered** — the designer only added, across four separate writes. `Main.rc` and the manifest were generated, the project built with only the pre-existing framework warnings, and the program ran. Two things confirmed as normal rather than reported as defects: the designer emits both `.Text` and `.Caption` with the same value for controls that have both (80 shipped forms do this), and an explicit `.ID` for some controls (11 do). A `Temp.bas` build scratch file is left in the project folder, which is known and gitignored. |
| C2 | **Designer round-trip fidelity** — save, close, reopen the project; confirm every control, property and handler survived. | `.frm` generation and re-parsing, the file format the whole product depends on. | 🤝 | ✅ | Owner made a designer edit (nudged a control) on a form and saved; the file was diffed byte for byte. **Result: exactly one difference — the `SetBounds` line of the control that moved.** Every other control, property, handler, comment and include byte-identical. That is the round-trip fidelity this scenario exists to prove, and it is the assertion that matters, because a defect here damages a user's saved project rather than merely misbehaving at runtime. **Two other differences appeared and neither is a defect.** (1) The UTF-8 BOM was removed on save. That is **deliberate policy, not a bug**: FreeBASIC treats a BOM as a signal to make string literals wide, so a BOM'd source prints garbled console output — the IDE normalises to BOM-less UTF-8 on save, and the agent build downgrades `Utf8BOM`→`Utf8` for the same reason (`AgentPipe.bas`, `MCP_SERVER_PLAN.md`). This test initially mistook that healing for a fidelity defect and "fixed" it; the change was reverted once the rule was found. **Read the encoding policy before treating an encoding change as a bug.** (2) Deleting a control leaves its `#include` behind — defensible, since auto-removing an include could break hand-written code elsewhere in the file that uses the type. |
| C3 | **Rename a control that events reference** — rename, then confirm handlers still bind and the project still builds. | Refactoring safety in the designer. A likely defect area. | 🤝 | ❌ | **Handlers still bind; the project does not build.** Renaming a Label from `Label1` to `lblGreeting` in the property grid updated the four sites describing the control itself — its `Dim`, its comment, its `With` block and its `.Name` — and left the four event-related sites on the old name: the `Declare Sub Label1_Click`, the `.OnClick = @Label1_Click` wiring, the `Private Sub MainType.Label1_Click` body, and the user's own `Label1.Text = ...` inside it. The handler wiring stays **internally consistent**, so the event still binds, and keeping the handler name is defensible — renaming it would break anything that calls it. The single breakage is the user's line, which now refers to a control variable that no longer exists: `Error: Variable not declared, Label1 in 'Label1.Text = \"Hello, \" & TextBox1.Text'` at line 84. **Discoverable, not silent** — the error names the file, line and identifier, so a user can fix it in seconds. But on a large form a rename could break many lines with no warning at rename time, and the handler keeps a name (`Label1_Click`) that no longer matches its control. Recorded as ROADMAP §13.17 and **owner-classified as required for 1.0** — an ordinary designer action that leaves the project unbuildable fails the product's *it just works* standard, whatever the error message says. Project: `dontest`. |
| C4 | **Multi-select operations** — select several controls, align/size/space them, undo, redo. | The Form Designer menu's core value, against multiple controls at once. | 🤝 | ✅ | **Passes.** Align and Make Same Size verified across four multi-selected labels, persisting through a save. Undo/Redo initially did nothing and was recorded as ROADMAP §13.19 "the designer has no undo" — **that diagnosis was wrong**. The designer always had undo (designer edits are written into the code editor's history by `DesignerModified`); Undo simply lived in the **Code** menu, which greys in Form view, and Windows' `TranslateAccelerator` consumes an accelerator whose parent menu is disabled without sending any `WM_COMMAND`. Fixed by restructuring the menus: Code and Form now hold only context-specific commands, and a new never-greyed **Code/Form** menu holds Undo, Redo, Cut, Copy, Paste, Duplicate, Select All. Ctrl+Z/Ctrl+X/Ctrl+C/Ctrl+V all verified in both views. |
| C5 | **Copy/paste between forms** — copy a control group from one form and paste into another. | Cross-form clipboard handling and name-collision behaviour. | 🤝 | ✅ | **Passes, including the collision case.** Fixture `Examples/Integration/C5_CopyPaste` was built for this: FormA holds `lblShared`/`txtNotes`/`btnGo`, FormB holds its own `lblShared`, so pasting the group forces a duplicate name. All three controls transferred; the clash was resolved to `lblShared1`; the declaration became `Dim As Label lblShared, lblShared1`; FormB's original `lblShared` was left untouched at its own bounds; pasted controls kept their sizes with a paste offset. Project builds after the paste and the program runs and closes cleanly. Verified by reading the live editor buffer over the agent pipe, not from the screen. |
| C6 | **Split view with designer** — edit code and form side by side, switch focus, confirm the Code/Form menus track the active pane. | The split-view focus tracking added this cycle, in combination rather than alone. | 🤖 | ✅ | **Passes.** Measured by sampling Windows' own top-level menu state four times a second and logging every transition, rather than by eye — this is the state `TranslateAccelerator` consults, so it reflects whether each menu's shortcuts can actually fire. Code pane focused: `Code=enabled, Code/Form=enabled, Form=GREYED`. Designer pane focused: `Code=GREYED, Code/Form=enabled, Form=enabled`. Back to code: returns correctly. Focus tracking is right in both directions, and **Code/Form stayed enabled in every state** — the property the 2026-07-18 menu restructure depends on (see C4). |

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

**Include the framework first.** When a test uses a control library from `Controls\<Name>`
alongside `mff/`, include `mff/` first. A control library that pulls in `windows.bi` before the
framework has set the Windows version it targets leaves the framework's own include a no-op, and
`Control.bas` then fails to compile on declarations that need a higher `_WIN32_WINNT`. B11 found
this with SQLite3Component.

**Build them with a manifest.** Every test here embeds one via a two-line `.rc`
(`1 24 "Manifest.xml"`). Without it, controls needing ComCtl32 v6 — `LinkLabel` and anything
else wrapping a v6-only class — fail to register at startup with *"Unable to register class
..."*. The IDE adds a manifest to every project it creates, so this only bites when compiling a
`.bas` by hand, which is how the suite is run here. B13 found it the hard way.

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
