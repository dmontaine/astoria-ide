# VFBE Win64 Fork — Future Enhancements

**Extracted from PROJECT_STATUS.md on 2026-07-06.** For current status and open items, see [PROJECT_STATUS.md](PROJECT_STATUS.md).

---

## 13. Future enhancements (owner-added, unscheduled)

These are **enhancements, not bugs** — added by the owner after Tier 3 was scoped. No committed order yet; see the owner's own numbering below. None of this work has started.

**Read §13.4's context note before scoping any of this section.** This is a hobby project with no timeline pressure, and the underlying goal across all of §13 — not just the rename — is to avoid the original upstream project's failure mode (too much scope, too little central attention, eventual collapse to one maintainer). Favor depth and coherence over speed or breadth when picking this up.

### 13.1 Evaluate a later GCC version — **CLOSED (2026-07-04): evaluated, declined**

Current: GCC 9.3.0 (MinGW-W64, posix-sjlj), Binutils 2.34. No actual problem exists — the IDE and all examples compile cleanly. A standalone GCC swap carries high ABI risk (FreeBASIC 1.10.1's bundled `crt*.o`, `libgcc.a`, and `libfbmt.a` were built against this specific GCC; mismatched exception models between `sjlj` and `seh` can silently corrupt the stack at runtime). Marginal benefits (10-20% faster compiles, 5-10% better -O2 output) don't justify the testing burden and risk. Revisit only if a specific, concrete problem attributable to the GCC version surfaces.

### 13.2 Structured programming, consistency, and legacy-tech-debt removal

**Owner's stated goal:** this codebase carries the accumulated effect of many independent programmers working on it over many years with minimal communication between them. The point of this pass isn't cosmetic formatting — it's to impose one consistent set of conventions and structure over code that currently has as many styles as it had contributors, so the system becomes legible and maintainable going forward rather than an archaeology exercise every time someone touches it.

**Codebase size:** ~277 files, ~5 MB total. Largest files: `TabWindow.bas` (576 KB), `Main.bas` (412 KB), `EditControl.bas` (316 KB), `Chart.bas` (114 KB), `Designer.bas` (117 KB).

#### Phase 1 — Safe mechanical cleanup (low risk, scriptable)

- **2.1.1 Standardize indentation (whitespace only):** convert mixed tabs/spaces to one consistent scheme across all `.bas`/`.bi`/`.frm`. Scriptable in bulk, zero logic changes. Gate: `CompileDebug.bat` clean.
- **2.1.2 Remove dead/comment-cruft and empty handlers — DONE:** swept commented-out code blocks, dead `Declare` forwards with no implementation, empty no-op event handlers, and designer-generated scratch code.
- **2.1.3 Audit and fix magic numbers — DONE:** audited unnamed numeric literals used for counts, sizes, and flags and replaced applicable cases with named constants.

#### Phase 2 — Codebase readability (moderate risk, file-by-file)

- **2.2.1 Standardize variable naming conventions:** pick one convention and apply uniformly. Rename file-by-file (not cross-file), avoids breaking `Alias`/`Export`/`Declare` bindings. Gate: `CompileDebug.bat` after each file.
- **2.2.2 DRY pass — extract repeated code within files — DONE:** extracted applicable duplicated logic into shared private functions and procedures.
- **2.2.3 Split oversized files by logical domain — CLOSED:** declined because the cross-file binding and regression risk outweighed the expected maintainability benefit.

#### Phase 3 — Architecture improvements (high value, high risk)

- **2.3.1 Development/Final compile-mode toggle — DONE:** replaced the former Project Properties controls with the simplified Development/Final compile-mode choice.
- **2.3.2 UI/settings sweep — remove orphaned controls — DONE:** audited and removed obsolete platform, compiler, debugger, and settings controls.

#### Phase 4 — Legacy tech debt (lowest priority)

- **2.4.1 Final audit for remaining GTK/Linux/32-bit artifacts — DONE:** verified that no unintended platform artifacts remain after the Win64-only cleanup.
- **2.4.2 Clean `src/makefile` and `src/THREADING.md` — DONE:** removed obsolete GTK references from build documentation.

#### Recommended execution order

```
2.1.1                     (remaining mechanical cleanup; 2.1.2 and 2.1.3 complete)
2.2.1                     (variable naming; 2.3.1 and 2.3.2 complete)
(2.2.2 complete; 2.2.3 closed as too risky; 2.3.3 removed)

### 13.3 UI evaluation and modernization

Owner asked whether this review needs a different AI trained specifically on front-end/UX practices, or whether it can be done here.

**Answer:** This can be done in this same environment. The relevant knowledge — Windows desktop UX conventions (Fluent Design / WinUI spacing, typography, and interaction patterns; conventions from comparable dev tools like VS Code and Visual Studio, since VFBE is a code editor, not a general consumer app), accessibility basics (contrast ratios, keyboard navigation, focus indicators), and layout/information-hierarchy heuristics — isn't a separate specialized model; it's general knowledge any capable model has, not something that requires a different AI trained on it. The Claude Code preview tooling can drive the actual built app, take screenshots, and inspect computed styles directly, which is what a review needs. There isn't a categorically "better-suited" different AI for this — the limiting factor is doing the review carefully (screenshot-driven, one panel/dialog at a time) rather than which model does it.
What **would** add value beyond any AI review: a human with fresh eyes and no context on the app's history, and/or usability testing with an actual end-user developer completing a real task — those catch friction an AI reviewer working from screenshots tends to miss.
Recommended approach when this is scheduled: run the built IDE, screenshot each major surface (main window, Designer, dialogs, Toolbox, Find/Replace, Settings), evaluate against Fluent/WinUI conventions and basic accessibility, and produce a scoped list of concrete changes rather than a vague "modernize" pass.

**Design against the target audience (§1), not against power users:** the primary audiences (returning Basic programmers, desktop-focused hobbyists, students) value approachability and a cohesive single tool over configurability or professional-IDE feature depth. UI evaluation should weight "is this discoverable and non-intimidating to someone who hasn't touched an IDE in 20 years, or ever" above "does this match what VS Code/Visual Studio power users expect." Avoid recommending changes that add configuration surface or professional-IDE conventions (command palettes, complex multi-pane customization) purely because they're modern — that cuts against the actual audience.

#### UI review progress (step-by-step, owner-driven — started 2026-07-06)

Distinct from the earlier bulk **13.3 UI evaluation** pass (28 fixes, archived in [CHANGELOG.md](CHANGELOG.md)) — this is a deliberate menu-by-menu review with owner approval at each step.

| Menu / surface | Status |
|----------------|--------|
| **File** | ✓ Modified & owner-approved (2026-07-06) |
| **Edit** | ✓ Owner-approved; refinements folded into the 13.3.A plan |
| **All remaining menus + toolbars + Options** | **Designed** — see 13.3.A (owner-approved O1–O4, 2026-07-06); execution queued as S1–S7 |

**File menu (approved 2026-07-06):** Open Project vs Recent Projects fix; `ProjectsPath` from Options; path sanitization (`CanonicalWinPath`, INI hygiene); Open Project tabbed dialog (Projects + Examples tabs); Examples scan `Dir()` fix; ScanTest listing. Session detail: §4 session 2026-07-06.

**Next:** superseded by the comprehensive approachability plan below (designed 2026-07-06, Opus). The ad-hoc "one menu at a time" review is replaced by a single designed target state covering every menu, the toolbars, and the Options dialog; File is already done, this specifies the rest.

---

#### 13.3.A Approachability pass — full plan (designed 2026-07-06, Opus session)

**Governing decision — progressive disclosure, NOT an easy/advanced mode toggle.** One opinionated UI. Advanced items live in an `Advanced ▸` submenu *inside their own parent menu*, never behind a global "expert mode." A beginner never trips over them; an intermediate finds them one click deeper — which is exactly how someone signals they're ready. A global mode was explicitly rejected: it forces a self-classification the user can't make on day one, it rots into two half-tested UIs, and it's the biggest "unnecessary option" of all. The growth path is *reach one level deeper + toggle whole toolbars/windows on* — mechanisms that already exist.

**Standing design rules for this pass:**
- **Fixed toolbar layout — no per-button customization.** None exists in the code today (`grep`-confirmed: zero `Customize`/`OnCustomize`); do **not** build it. The wholesale "Show Main Toolbar" off-switch (already present, `chkShowMainToolbar`) covers the "I don't want it" case with none of the error surface.
- **Pick one good default over any new knob.** No icon-size setting, no mode setting.
- **Context-surface** features when the activity makes them relevant (Designer menu only with a form open; debug windows only while debugging — already the pattern).
- **INI migration (per §9):** new defaults apply only when the key is *absent*; never force-write on startup; never overwrite an existing user's saved choice; migrate retired keys, don't orphan them.

##### Design decision 1 — menu taxonomy (O1)

Legend: **Keep** · **→Adv** (that menu's `Advanced ▸` submenu) · **Move** · **Remove** · **Relabel**. File + Edit were previously owner-approved, so their entries are *optional refinements*.

- **File** *(approved)*: Delete Project / Delete File → add confirm + regroup away from Close (safety). Print → Keep. Print Preview, Page Setup → **File ▸ Advanced** (Windows print dialog already covers PDF + page setup, so nothing is lost). Recent AI Chat → **Move** to the AI Agent panel. Command Prompt → **Move** to Tools. Everything else Keep.
- **Edit** *(approved — refinements)*: Unformat, Format Project, Unformat Project, Add Spaces, Merge Blank Lines → **→Adv**. Code – Bubble Help / Suggest Options / Parameter Info → **Move** to Options ▸ Code Editor (they're on/off settings, not edit actions). Comment/Block Comment/Uncomment → collapse to one **Toggle Comment** (owner agreed). Rest Keep.
- **Search**: **Relabel** "Define" → **"Go to Definition."** Rest Keep.
- **View**: merge Collapse/Uncollapse (6 items) → one **Fold ▸** (Collapse All / Expand All visible; per-scope →Adv). Split "Other Windows" — keep Output/Problems/Suggestions/Find/ToDo/Change Log/Immediate; **move** Locals/Globals/Threads/Watch to **View ▸ Debug Windows**. Keep Toolbars submenu (final list from O3).
- **Project**: Add User Control / Add Resource File / Add Manifest File → **→Adv**. Rest Keep.
- **Designer (Form Format)**: **Keep entirely** — this is the VB/Delphi Format menu the audience expects. Only refinement: disable the whole menu when no form is open.
- **Tools**: Add-Ins, External Tools → **→Adv** (or remove External Tools/Add-Ins entirely for coherence — owner leaning remove). + Command Prompt (moved in). Options Keep.
- **Window**: fold Split Horizontally/Vertically into **View**; retire the near-empty Window menu.
- **Help**: reduce the 7-item **GitHub ▸** to VFBE repo + FB Wiki (rest →Adv/remove). **Add "About"** if missing. Rest Keep.

##### Design decision 2 — Run / Build / Debug consolidation (O2)

Collapse the separate **Build** menu + **Run** menu + 3 toolbars into **one Run menu** (no separate Build menu). "Build" survives as a *command*, not a menu.

**Run menu top level (the 90% path):** ▶ Run (F5 — compile+run; = Continue when paused) · Build (Ctrl+F9 — compile only) · — · Stop (was "End") · Restart (Shift+F5) · — · Step Into (F8) / Step Over (Shift+F8) · Toggle Breakpoint (F9) · — · Use Debugger (toggle).

**Run ▸ More Build Options:** Rebuild All (was Compile All) · Clean (was Make Clean) · Syntax Check · Make · Compiler Parameters · Run Without Building (Ctrl+F5, was "Start").

**Run ▸ More Debug Options:** Step Out · Run To Cursor · Continue · Break · Clear All Breakpoints · Add Watch · Set Next Statement · Show Next Statement · Use Profiler · GDB Command.

**Relabel map:** `Start With Compile→Run` · `Start→Run Without Building` · `Compile→Build` · `Compile All→Rebuild All` · `Make Clean→Clean` · `End→Stop`.

**Context enable-state rules (the Opus-critical part — driven by `ChangeMenuItemsEnabled` + the debug state machine; §9 dormant-reference trap):**
- *Stopped, project open:* Run, Build, Rebuild All, Clean, Toggle Breakpoint = on; Stop/Step/Continue/Break/Restart = off.
- *Running (no debugger):* Stop, Restart = on; Run = off; stepping = off.
- *Paused at breakpoint:* Continue (F5), Step Into/Over/Out, Run To Cursor, Set Next Statement, Stop, Restart = on.
- *Use Debugger = off:* stepping, breakpoint-pause, Add Watch, GDB Command = hidden/disabled.

##### Design decision 3 — toolbar defaults & look (O3)

- **Default-visible on fresh install: Standard + Run only.** Edit / Project / Format = default-hidden (available in View ▸ Toolbars). After O2 the toolbar set is Standard, Edit, Project, Format, Run (Build+Debug folded into Run).
- **Look: one short toolbar, 16×16 icons + text-beside-icon labels** on the primaries (Run, Build, Stop, Save, Open), with **Run as a prominent labeled anchor** (icon-left/text-right). No new art needed (labels carry meaning; 16×16 is a color/shape cue). Fixed style, not a setting.
- **Show Main Toolbar** master toggle already exists (`chkShowMainToolbar`) — verify it hides the whole bar **and reclaims the editor space** (the last-mile polish this codebase tends to miss); default on.
- **Panels: do NOT touch the state machine.** Left panel (Project Explorer) visible; right/bottom keep current auto-hide defaults (they already context-surface). Any panel-default change is a separate §7-gated task.

##### Design decision 4 — Options dialog audit (O4)

The concentrated problem is **toolchain-path management** that leaks the bundled toolchain and adds build-breaking error surface:
- **Compiler ▸ Compiler Paths** (register alternative compilers) → **Remove.**
- **Compiler ▸ Default Compiler** (`cboCompiler64` already hidden) → **reduce to a read-only info line** ("Bundled: FreeBASIC 1.10.1"); the whole Compiler page can collapse to that blurb.
- **Debugger ▸ Terminal** sub-page (Default Terminal + Terminal Paths) → **Remove;** pick a sensible default terminal.
- **Debugger ▸ "Turn on Environment variables"** → →Adv or remove (power-user).
- **Code Editor ▸ Other Editors** (external-editor registration) → candidate for removal.
- **Designer ▸ "Create non-static event handlers"** → pick the right default, hide the toggle.
- **Code Editor ▸ Defaults** — verify its encoding/line-ending pickers aren't vestigial (the fork forces UTF-8 + CRLF in `AddTab`); remove them if so.
- Keep: General, Localization, Shortcuts, Colors & Fonts, Help/AI Agent.

##### Executable task list (Sonnet-level; each is a standalone session)

Blocked on the taxonomy above (already specified). Files: menus live in `Main.bas` `CreateMenusAndToolBars` (~5692–6030); enable-state in `ChangeMenuItemsEnabled` (`TabWindow.bas` ~243); toolbar visibility in `SettingsService.bas` / toolbar init.

- **S1 — Reorganize menu items** to the O1/O2 structure (create `Advanced ▸` submenus). *Gotcha:* keep every `mi*`/`mnu*` pointer assignment (referenced by `ChangeMenuItemsEnabled` + `mClick` handlers); after any move/remove, grep `src/` for the command string **and** its pointer var and update all sites — clean compile is NOT sufficient (§9). *Accept:* Compile.bat 0 errors, launch, click through every moved item in each run-state.
- **S2 — Relabel jargon items** per the relabel maps. *First:* determine how `ML()` keys — if the English string is the lookup key, update the localization strings file too, not just the call.
- **S3 — Toolbar consolidation + defaults + look + Show-Toolbar verify.** Merge Build/Debug/Run toolbars → one Run toolbar; set default-visible = Standard + Run; add text-beside-icon labels + Run anchor; verify `chkShowMainToolbar` reclaims space. *Gotcha:* read-with-default (absent key → new default); migrate old Build/Debug toolbar keys → Run (if either was true, Run visible); never force-reset existing users; HotKeys.txt merge not clobber. *Feasibility pre-check:* does MFF `ToolBar` expose a text-beside-icon style? If not, fall back to a `CommandButton` row (guaranteed).
- **S4 — Remove dead "\*nix/\*bsd Icon Resource File" field** from `frmProjectProperties.frm` (~line 203) — label, control, load/save. *Gotcha:* `.frm`; grep the control name across `src/`, verify the dialog still lays out (open Project Properties after building).
- **S5 — Confirm dialogs on Delete Project / Delete File** (MsgBox Yes/No), and regroup them away from Close in the File menu.
- **S6 — Execute the O4 Options edits** (remove Compiler Paths + Terminal page; reduce Default Compiler to info; Env-vars →Adv/remove; Other Editors remove; non-static-handlers default+hide; verify/remove vestigial Defaults pickers).
- **S7 — Docs cleanup** (already in Open Items): GTK refs in `src/makefile` and `src/THREADING.md`.

##### Opus review points

- **Review S1 and S3 diffs before commit** — the enable-state wiring and the toolbar/dock/INI-migration are the two places a clean compile hides a runtime break (§9 dormant references; panel-layout last-mile). Everything else Sonnet can compile-clean-and-push per the standing workflow.
- The **MFF library-path wart** (Open Items "Queued for Cursor") stays Opus-specced even if Sonnet edits it — it's an object-model design question, not mechanical.

##### Suggested sequence

`S3 (toolbars — highest daily-use win) → S1 → S2` (S2 depends on final structure), then `S4, S5, S6, S7` independently. Compile-clean + smoke-test gate on each (§9); §7 panel checklist only if S3 ends up touching panel layout.

### 13.4 Rename the project — **DONE (2026-07-10): renamed to "AstoriaIDE"**

Full identity rename completed: output binary (`astoria.exe`), source/project/resource files (`AstoriaIDE.bas/.rc/.vfp`), build scripts, settings file (`Settings/astoria.ini`), splash screen, dialog titles, window title, README, and source header comments. See [`CHANGELOG.md`](CHANGELOG.md) for the full touch-point list. `frmAbout` intentionally left untouched (owner's in-progress edit). Internal code identifiers (`VisualFBEditorApp`, `Namespace VisualFBEditor`, `WhenVisualFBEditorStarts`) were left as-is — cosmetic/user-facing scope only, not a source-level refactor. GitHub repo name/clone URL was **not** changed (out of scope for this pass; would need separate owner action since it affects existing clone URLs).

**Original planning note (superseded, retained for context):**

**Owner's context (important — shapes how all of Tier 4 should be approached):** this is a hobby project, and the owner is explicitly willing to spend months building an elegant system from the source-code level up — timeline is not a constraint. The owner's diagnosis of what went wrong with the original upstream project: it tried to do too much, with too little central guidance or attention to detail, and eventually its contributor base collapsed to a single person doing peripheral maintenance because the system had become too difficult to manage as a whole.

That history is the actual reason the rename matters, beyond a cosmetic label: it's meant to mark a deliberate, disciplined fresh start distinct from that trajectory — one with central direction and attention to detail, paired with the structural cleanup in §13.2. Given that framing, this fork should explicitly avoid repeating the original failure mode: **resist scope creep, keep changes centrally reviewed, and prioritize depth/coherence in one area over breadth across many.** Worth keeping in mind for how all of §13 (not just the rename) gets sequenced and scoped as it's picked up.

Flagging the rename itself as a **larger mechanical undertaking than it looks**, not a reason to avoid it — a rename this deep should be a dedicated pass with its own compile-and-test cycle, not folded into other work. Known touch points:
- Output binaries: `VisualFBEditor64.exe`, `mff64.dll` — filenames referenced throughout `Compile.bat`, `.gitignore`, this doc, `README.md`, `BUILD.md`
- Window class names / mutex or single-instance-detection strings (if any) in `src/VisualFBEditor.bas` / `Main.bas` — renaming these changes on-disk identity, not just cosmetics
- Splash screen, About dialog, title bar text, `App.Title` (`src/Main.bas` per §3a warnings-fix notes)
- INI file name/path (`Settings/VisualFBEditor64.ini`) — needs a migration story if existing users' settings shouldn't be silently orphaned; see the INI key migration convention in §9
- Repository name on GitHub (`dmontaine/astoria-ide`, migrated from Codeberg's `VFBEWin64` 2026-07-09) — a rename here changes clone URLs for anyone already tracking it
- Every doc file (`README.md`, `PROJECT_STATUS.md`, `src/BUILD.md`, `src/THREADING.md`) and likely dozens of in-code comments/strings referencing "VisualFBEditor" or "VFBE"
- Decide scope up front: cosmetic rename only (title/About/docs) vs. full identity rename (binaries, repo, INI, window classes) — the second is much larger and should be scheduled as its own tier.

### 13.5 Standard Windows installer for end-user developers

Distinct audience from the current git-clone-and-compile workflow: an end-user developer who wants to *write FreeBASIC programs in the IDE*, not modify the IDE's own source — this is the audience described in §1 (returning Basic programmers, desktop-focused hobbyists, students). Implies a second distribution artifact alongside the source repo, not a replacement for it:
- Real installer/uninstaller (Inno Setup or WiX are the standard choices for a WinAPI-native app like this; both produce a proper uninstall entry in Windows Settings)
- Pre-built binaries only — `VisualFBEditor64.exe`, `mff64.dll`, the bundled `fbc64` compiler and GDB debugger — no IDE source tree
- Examples centralized and included (currently under `Examples/` per the key-files map, §10) — bundle as part of the installer, not a separate download
- Source, if offered at all to this audience, as a single centralized zip rather than the live dev tree (keeps the installer surface small and avoids exposing `Compiler/`/`Debuggers/` internals meant for the fork's own maintainers)
- Needs a decision on installer scope before starting: does this ship the bundled compiler (making it a fully standalone IDE+compiler), or does it assume the end user already has FreeBASIC installed? Given this fork bundles its own `Compiler/` tree already (§3a), standalone is the more consistent choice.
- Depends on Tier 3 (compiler swap) being done first, so the installer ships the final intended compiler version rather than needing a re-package immediately after.

### 13.6 Full review and expansion of Examples/ — **DONE**

**Status:** completed. The Examples tree was flattened to one project per folder, every project was compile-tested, failures were removed, and the retained set was documented.

**Why this is on the list:** the 2026-07-03 GTK/Linux/Win32-only audit (§3b) went through all 33 `Examples/` folders and found the premise (remove GTK/Linux/Win32-only examples) didn't hold, but surfaced real gaps along the way: several examples had no `.vfp` project file at all, two had genuine API-drift bugs from being written against an older `mff` version (one fixed — `Graphics/CanvasDraw.bas`, §3b — one still open — `WellCOM Example/WellCOM.bas`'s `DllMain` conflict), and this was only found because someone happened to try compiling them. That's a sign `Examples/` hasn't had a systematic pass in a while.

**Scope for that future pass:**
- Re-verify every example still compiles clean against the *then-current* `mff` API (will have moved again after §13.2's structural pass) — same direct-`fbc64`-compile verification technique used in §3b/§4, not just visual inspection.
- Finish the `WellCOM Example` `DllMain` fix left open in §3b.
- Consider whether new examples are worth adding — the target audience (§1) benefits from seeing approachable, appealing demos (graphics/drawing examples in particular resonate with returning Basic programmers per the discussion that led to this item); a documentation/polish phase is a natural time to ask "what's missing" rather than only "what's broken."
- Natural pairing with §13.5 (installer) — examples get bundled with the installer, so this pass and that one should probably be sequenced together or at least cross-checked.

### 13.7 Enhance AI integration in the IDE — REVERSED (owner decision, 2026-07-09)

**Owner decision (2026-07-09): this expansion plan is cancelled. The AI Agent subsystem is being removed from the IDE entirely, not enhanced.** The owner reversed the 2026-07-03 direction (retained below for the record) after concluding that a self-maintained multi-provider AI client is a whole subsystem to maintain that isn't this tool's focus, and that external tools (Claude Code, Cursor, DeepSeek-based tools) are advancing far faster than a solo-maintained internal AI client could ever track — the same anti-scope-creep discipline that motivates this fork (§13.4 context: avoid the upstream project's "too much scope, too little central attention" failure mode). Users who want AI can wire an external tool through the **existing Tools ▸ External Tools launcher** (`frmTools.frm` — already supports an arbitrary program path, command-line parameters, and file-extension association), so no in-IDE AI client is needed to serve that use; a purpose-built AI launcher was evaluated and dropped as redundant with this existing feature.

Execution is tracked as the **AI Agent subsystem removal** sub-project in `PROJECT_STATUS.md` (tasks AI1–AI14). The only AI-related asset deliberately kept is `Examples/AiAgent/` — a third-party MyFbFramework control demo (CM.Wang), independent of the IDE's built-in feature.

**Superseded — original 2026-07-03 expansion rationale (for the record):**

- **Secondary audience note that motivated it:** beyond the core §1 audience (returning Basic programmers, desktop hobbyists, students), the owner had observed that some business users might be drawn to VFBE for a robust, no-nonsense IDE with strong AI integration rather than for BASIC nostalgia specifically — suggesting the AI feature area might be worth investing in further. *(Superseded: the external-tools path above serves this audience without an in-IDE AI subsystem.)*
- **Starting point it noted:** the AI system (`src/AIService.bas`, ~810 lines) already supported multiple providers (OpenAI, DeepSeek, Claude, Mistral, Ollama, OpenRouter) with streaming and context management, and a bug had just been fixed making the 2,874-line `VisualFBEditor IDE Environment.md` reference load into AI context correctly.
- **Candidate areas that were never scoped:** deeper codebase-aware context, AI-assisted debugging / error-message explanation, inline code suggestions beyond the `Suggestions` tab. None were started.

### 13.8 Design-workspace status bar (deferred 2026-07-04 — "nice to have, not critical")

Owner spec, captured verbatim for whenever this is picked up: a status bar docked to the bottom of the Form Designer's visual workspace (`TabWindow.pnlForm`), full width of that panel specifically (not the whole tab — must track `pnlForm`'s width as the Code/Form splitter moves), three cells:
1. Name of the form being edited.
2. Name of the control currently being edited/selected.
3. Layer info — "none" when the selection isn't inside a `PagePanel`, otherwise "Layer N of Total" plus two left/right buttons (only enabled in layer mode) to move between layers, reusing the `Designer.MovePanelLayer` added this session.

Cells 1 and 2 should update live as the user renames the form or the selected control via the property grid.

**Why deferred, not just "todo":** researched 2026-07-04 and confirmed genuinely non-trivial — `pnlForm` itself docks normally via the framework's Align system, but the *design control* (the form being edited) inside it is positioned via raw HWND math independent of that docking (its `ParentHandle` is set directly, sized to match the form's own declared bounds, scaled for DPI) — specifically in `pnlForm_Message`'s `WM_SIZE` handler (scrollbar-range math against `Des->GetControlBounds(...)` vs. `pnl->ClientWidth`/`ClientHeight`, `TabWindow.bas` ~10227-10286) and `Designer.HookDialogProc`'s `WM_NCCALCSIZE` case (`Designer.bas` ~2253-2261, which already reserves space at the *top* for the form's own menu bar via `TopMenuHeight` — the model to mirror for a *bottom* reservation). This is the exact same layout-engine territory as the docking-engine bug that's already this project's most expensive-to-debug area (see the recurring "sound design, unfinished last mile" pattern noted throughout §8) — worth doing carefully in a dedicated session, not squeezed in alongside other work.

There's no native "embed a control inside a status bar panel" API in `mff/StatusBar.bi` (`StatusPanel` reserves width/caption only) — the existing global status bar (`pstBar`, `Main.bas` ~5206-5223) works around this by parenting a plain control (a progress bar, in that case) over a reserved panel's x-offset manually; the same trick would be needed for cells 3's left/right layer buttons.

For the live-update wiring: every property-grid commit (including "Name") funnels through `Sub PropertyChanged` (`TabWindow.bas` ~2555-2667), which already special-cases `PropertyName = "Name"` (~2588-2596) to call `TabWindow.ChangeName` — that's the one choke point to hook for keeping cells 1/2 in sync, regardless of whether the edit came from the property grid's cell editor, its textbox, or its combo.

### 13.9 Blank Designer page on cold-open until a control is selected — **DONE**

Owner testing confirmed that the suspected cold-open blank-page problem does not reproduce and the Designer renders correctly. No further work is required.

### 13.10 Dark mode: owner-drawn popup menus + input-field polish (deferred 2026-07-04)

Dark mode is stable and near-complete (see §4), but popup/dropdown menus remain light. Windows provides **no documented API** for dark Win32 popup menus — the choices are the undocumented uxtheme-ordinal route (rejected on principle for this fork) or fully owner-drawn menu items. The framework already has the opt-in switch (`Menus.bas` `Menu.Style` property → `TraverseItems` flips every item to `MFT_OWNERDRAW`, `Menus.bi:205`) and the item data is already threaded through (`MENUITEMINFO.dwItemData` carries the `MenuItem Ptr`, `Menus.bas:120`), but the actual renderer is missing: `WM_DRAWITEM ODT_MENU` in `Control.bas:1257-1260` (and `Form.bas:990-992`) is an empty stub with only a commented-out `ImageList_Draw`. Do NOT just enable `Menu.Style` — menus render blank without the drawer.

Scope when picked up: implement `WM_MEASUREITEM`/`WM_DRAWITEM` for `ODT_MENU` — item text, right-aligned accelerator text (caption already stores the accelerator after a tab), icons (`FImage`/`ImagesList`), checkmarks/radio marks, separators, submenu arrows, disabled/hot states — using the existing dark palette (`hbrBkgndMenu`/`darkBkColorMenu` in `Brush.bi/bas` were created for exactly this and are currently unused). Test exhaustively: menus are the most-used surface in the IDE. Optionally in the same pass: darken input-field faces (search `TextBox`, `ComboBoxEdit`/`ComboBoxEx` edit areas) beyond what the `DarkMode_CFD` theme provides, via `WM_CTLCOLOREDIT`-style handling.

### 13.11 Dark mode: dark dialog/modal backgrounds (nice to have, not essential)

Modal dialogs and secondary forms (Find/Replace, About, GoTo, etc.) currently render with a white background in dark mode. The `WM_ERASEBKGND` handler in `Control.bas:862-868` does not fill with a dark brush — the dark fill only happens in `WM_PAINT`, leaving a white flash or persistent white background when `WM_ERASEBKGND` fires without a subsequent `WM_PAINT`. A naive dark-fill in `WM_ERASEBKGND` was attempted and reverted (2026-07-04) because it caused white borders around owner-drawn popup menus — indicating `WM_ERASEBKGND` is sent to multiple window classes including menu windows, and a blanket fill would need to be scoped more carefully (e.g. only for form/dialog class names, not the `#32768` menu class). Additionally, the `WM_CTLCOLORBTN`/`WM_CTLCOLORSTATIC` handler at `Control.bas:925-987` applies dark colors but is gated on `FDefaultBackColor = FBackColor` — any control with an explicit `BackColor` set will not go dark, which may affect some dialog controls. Investigation scope when picked up: gate the `WM_ERASEBKGND` dark fill on the window class (exclude menu windows), and audit dialog `.frm` files for controls with non-default `BackColor`.

### 13.12 Dark mode: Options ▸ Apply doesn't fully re-theme already-open panels (deferred 2026-07-11, owner smoke test)

Toggling Dark Mode on in Options and clicking **Apply** re-themes some controls live (a text box was confirmed updating immediately) but leaves others light until the IDE is closed and reopened — owner-observed gap, not yet isolated to specific panels beyond a general impression that tree/grid-heavy panels lag behind simple controls. Full dark theme is confirmed correct on next launch, so this is a live-repaint completeness issue, not a persistence bug.

Traced the call chain but stopped short of isolating the actual gap (owner deferred mid-investigation): `frmOptions.frm`'s `cmdApply_Click` does `DarkMode = .chkDarkMode.Checked : App.DarkMode = DarkMode : SetColors : UpdateAllTabWindows`. **`SetColors` is a false lead** — despite the name, it only reapplies syntax-highlighting colors (keywords, comments, identifiers, etc. via `SetColor`), unrelated to the app-wide dark theme. The real mechanism is the `App.DarkMode` property setter (`Application.bas:53-56`), which calls `SetDarkMode(Value, False)` (also invoked once at startup from `SettingsService.bas:214` with a `False, False` — differently, worth comparing the two call sites' parameter differences). Next step when picked up: find `SetDarkMode`'s implementation (not yet located this session — grep didn't surface a definition, only these two call sites and one in `Controls/Framework/mff/Application.bas`; may be in a `.bi`-declared-only + linked-elsewhere form, or named differently than expected) and determine which controls it does/doesn't walk and repaint, likely comparing against whatever full-repaint path runs at startup that the "next launch" case benefits from.

### 13.13 Target audience: teachers/educators — teaching plans and resources (owner-added 2026-07-16, gated on a stable IDE)

**Owner decision: educators are a named target audience for Astoria**, alongside end-user developers. The positioning: many development stacks overwhelm beginners and the people teaching them. Astoria combines:

- an **easy-to-learn language** (FreeBASIC),
- a **single tool** covering both text/console and GUI development,
- built-in **Git integration** (New Project dialog wires up the local repo, `.gitignore`/`.gitattributes`, provider guides), and
- built-in **AI integration** (the "AI friendly" project stamping with per-tool rules and skills),

with the AI side deliberately working across **both frontier models** (higher cost) **and open-source models via OpenCode** — the latter specifically appealing for schools operating on limited budgets.

**The task set — to be scoped only after the IDE is declared final/stable:** create **teaching plans and resources for educators**. (Curriculum/lesson plans, classroom setup guidance presumably including the per-user installer and the OpenCode path, and teaching-oriented reference material — exact scope to be defined with the owner when picked up. Nothing here has started; this section records the audience decision and the rationale so the intent survives until then.)

---

### 13.14 Review upstream MyFbFramework for fixes to backport (owner-added 2026-07-18)

Astoria vendors **MyFbFramework 1.3.7** (`Controls/Framework`, see `changes_en.txt`). Upstream —
[MyFbFramework](https://github.com/XusinboyBekchanov/MyFbFramework) — has moved on, and our copy is
demonstrably behind in ways that matter: the `WebBrowser` control in this tree was the **IE-only**
variant while upstream already had a working WebView2 implementation. The consequence was not
cosmetic — the control could not render a page at all and crashed on `Navigate` until it was
replaced on 2026-07-18 (see `Documentation/TestPlan.md` A4). If one control was that far behind,
others may be.

**The work:** diff `mff/` against upstream and read upstream's `changes_en.txt` from 1.3.7 forward;
list the fixes we lack; prioritise correctness fixes to controls we actually ship in the toolbox.
Linux/GTK-only and 32-bit-only changes can be skipped — Astoria is Win64-only.

**Look for missing files, not only changed ones.** `ListViewEx` and `SearchBar` each ship a `.bi`
whose implementation `.bas` was never included upstream, so any project using one fails with
"File not found"; both are excluded from the toolbox for that reason. Check whether upstream has
since supplied them.

**Preserve local adaptations.** Anything marked `ASTORIA CHANGE` must survive a backport — today
that means WebView2 as the default Windows backend, the guarded `#define`s in
`mff/WebView/WebView2.bi`, and the ByRef-`WString` fix in `NewWindowRequestedEventArgs.GetURL`
(**which upstream still has as a bug**). A blind overwrite reintroduces defects already fixed here.

This is bug-fix work and so is compatible with the 1.0 freeze; genuinely new upstream *features*
should be recorded here rather than taken.

### 13.15 Adapt the upstream framework reference (1300+ pages) into Astoria documentation (owner-added 2026-07-18)

Bring the **full** upstream framework reference into `Documentation/` as Astoria's own. Sources:
`Controls/Framework/help/MyFbFramework.chm` (1.1 MB) and the upstream `Framework.wiki` repository —
note `Controls/Framework/Framework.wiki` exists in this tree but is **empty** (an uncloned
submodule), so the wiki must be fetched.

**Three edits make it Astoria's rather than upstream's:**

1. **Remove Linux/GTK content.** Astoria is Win64-only and the GTK paths are gone from our tree, so
   GTK examples and Linux notes actively mislead here.
2. **Remove Win32/32-bit content**, for the same reason: we ship a 64-bit compiler only.
3. **Add our modifications and fixes**, so the reference describes the code we actually ship — at
   minimum `WebBrowser`'s WebView2 default (with the `AtlAxWin` failure recorded so it is not
   reintroduced), the `SQLite3Component.AddField` fix, and the `GetURL` ByRef fix.

**Build on the existing partial coverage rather than duplicating it:** `Documentation/Controls.md`
already covers the 73 toolbox controls (extracted from the `.chm`) and
`Documentation/FrameworkFeatures.md` covers the non-toolbox half. Decide whether the full reference
absorbs those or sits beside them — two documents disagreeing about the same control is worse than
either alone.

**Licence:** the framework is LGPL (`COPYING.LGPL.txt`, `COPYING.modifiedLGPL.txt`). Republished
documentation needs attribution to Xusinboy Bekchanov and a statement of what we changed.

Expect a batched job worked section by section across several sessions, not a single pass.

### 13.16 Optional: normalise UTF-8 BOMs across `src/` and `Examples/` in one deliberate pass (owner-added 2026-07-18)

**Optional, cosmetic, and explicitly not urgent.** Astoria's rule is BOM-less UTF-8 for FreeBASIC
sources: FreeBASIC reads a UTF-8 BOM as a signal to make string literals **wide**, so a BOM'd
source prints garbled console output. The IDE already normalises to BOM-less on save, and
`AgentPipe.bas` downgrades `Utf8BOM`→`Utf8` before an agent build.

**The tree is currently mixed** (measured 2026-07-18 while answering "does anything deviate from the
rule?"):

| Area | With BOM | Without |
| --- | --- | --- |
| `Templates/Projects` | **0** | 5 |
| Examples with a **console** subsystem | **0** | — |
| `src/` (IDE source) | 24 | 60 |
| `Examples/` (all) | 221 | 111 |

**Nothing ships in the state that actually misbehaves.** The templates every new project starts from
are clean, and no console-subsystem example carries a BOM — which is the only configuration where
the wide-literal behaviour reaches a user. The remainder are GUI sources, where it does not bite the
same way, and the IDE heals any of them the moment someone edits and saves.

**So this is a uniformity job, not a bug fix.** If it is done, do it as a deliberate one-off pass
rather than as a side effect of other work: it rewrites ~245 files and produces an enormous diff
that would bury real changes in history. Strip the BOM only; touch nothing else. Re-run the
integration suite afterwards, since encoding is exactly the kind of thing that looks harmless and
is not.

**Do not treat an encoding change as a defect without reading this section first.** TestPlan C2
mistook the IDE's BOM healing for a fidelity bug and "fixed" it, briefly reintroducing the garbled
output hazard before the policy was found and the change reverted.

### 13.17 Rename refactoring for controls in the designer — **RESOLVED 2026-07-18** (found by TestPlan C3)

**Status: fixed and owner-verified.** Option 3 was taken: an identifier-aware sweep over the file,
in `src/RenameRefactor.bi`, applied by `TabWindow.ChangeName` after its existing targeted branches.
The handler deliberately keeps its name, which whole-identifier matching preserves for free
(`Label1_Click` is a single token). C3 now passes and the tokenizer carries 18 assertions of its own
in `Examples/Integration/C3_RenameRefactor`. The original analysis is kept below.

**One thing the analysis below got wrong:** the branch handling `Label1.Text` already existed. It
sits inside `ElseIf b Then`, and `b` is only set between `Constructor` and `End Constructor`, so a
reference from an event handler body was never reached. The gap was in which lines were visited,
not in which patterns were known.

Renaming a control in the property grid updates the four places that describe the **control** — its
`Dim`, its comment, its `With` block and its `.Name` — but nothing that **references** it. The
event handler keeps its old name, and any code referring to the old control variable is left
untouched, so the project stops building:

```
Error: Variable not declared, Label1 in 'Label1.Text = "Hello, " & TextBox1.Text'
```

**Owner decision 2026-07-18: this is mandatory for 1.0, not a deferred enhancement.** The reasoning
is the product's own rule — *it just works*. Renaming a control is an ordinary thing to do in a
designer; that it silently leaves the project unbuildable is precisely the kind of rough edge a
newcomer cannot distinguish from their own mistake, which is the standard
`AstoriaIDESignificantChanges.md` commits Astoria to. The error being discoverable makes it cheap to
recover from; it does not make it acceptable to ship.

It is not silent data loss — the error names the file, the line and the identifier, and a user fixes
it in seconds. But on a
form with a control referenced from a dozen places, one rename produces a dozen errors with no
warning at the moment of renaming, and the handler is left with a name that no longer matches its
control (`Label1_Click` on a control called `lblGreeting`), which is quietly confusing for as long
as the project lives.

**Three options, cheapest first:**

1. **Warn at rename time** — "N references to `Label1` remain in code" — leaving the user to fix
   them. Small, honest, and no risk of touching code the user did not ask us to touch.
2. **Rename references inside the designer region only**, which the IDE already owns and rewrites.
   Does not help the handler body, which is where the reference usually is.
3. **A real rename refactor across the file** — the control variable everywhere, and optionally the
   handler with it. The most useful, and the one that has to be careful: renaming a handler breaks
   anything that calls it by name, so that part should be opt-in.

Note that keeping the handler name on rename is **deliberate-looking and defensible**; do not
"fix" it without deciding the policy first. See the C3 entry in `Documentation/TestPlan.md`.

### 13.18 Modal dialog raised from the app-activation handler can hang the IDE — **RESOLVED 2026-07-19, owner-confirmed** (owner-observed)

**What changed.** Options 1, 3 and 4 were taken together:

1. **No modal UI is raised from `frmMain_ActivateApp` any more.** It now only *detects* changed
   files, queues their names, and posts `WM_APP_FILECHANGED` to the main window. The prompt runs
   from the message handler, once activation has fully completed and the window is in a normal
   state.
3. **One prompt for all changed files**, listing them (capped at 12 with an "and N more" line).
   The old loop raised one modal per file, so a `git pull` touching six open files meant six
   sequential dialogs.
4. **The main window is restored and brought to the foreground** before the dialog appears, per the
   earlier `MsgBoxForm` z-order fix.

Filenames are queued rather than `TabWindow` pointers, because the prompt now runs after the
handler returns and a tab can be closed in between: a stale pointer would be a crash, a stale
filename simply finds no tab and is skipped. A `gInReloadPrompt` guard stops a second post stacking
another dialog while the first is up, and the queue is snapshotted and cleared before prompting so
that anything detected while the dialog is open queues for the next round instead of being lost.

Option 2 (a non-modal info bar) was **not** taken. It is the better end state, but the project is
feature complete for 1.0 and a new notification surface is a feature, not a program-flow fix. Worth
revisiting after 1.0.

**Update 2026-07-19 -- two further defects found by owner testing, both fixed.** The deferral and
batching themselves worked from the first run. What did not:

- **A crash on accepting the reload.** The queue was an array of `UString` grown with
  `ReDim Preserve`; `UString` owns a heap buffer and FB relocates elements with a shallow copy, so
  the old element's destructor freed a buffer the survivor still pointed at. A double free, which
  surfaced at the next touch and so presented as the reload being at fault. Because `SaveWorkspace`
  only runs on a clean close, the crash also lost the session and reopened the previous project --
  which looked like a third, separate bug and was not. Now held as one newline-delimited `UString`,
  with no dynamic UDT storage at all.
- **The prompt appeared to list only one of two changed files.** It was listing both; the *display*
  was clipping them. See 13.21 -- `MsgBoxForm` measures with `DT_WORDBREAK` into a fixed width, and
  paths have no spaces to break at, so both lines rendered as the same truncated prefix. The prompt
  now shows the shared folder once and lists bare file names.

**Method note worth keeping.** Three hypotheses were formed about why the `.frm` was missing --
forward slashes, the IDE re-saving the file, form regeneration -- and all three were wrong. Adding
one trace line per tab settled it in a single run by showing both files detected and queued, which
moved the search to the half of the code that was actually broken. Measure before theorising; the
owner's own suggestion that the dialog was truncating is what closed it.

**Owner-confirmed 2026-07-19.** With two files changed on disk in one project, activation raises a
single dialog naming the shared folder once and listing both files distinctly, the IDE stays
responsive, and accepting reloads both without incident. The three defects this entry went through
-- the original hang, a crash introduced by the first fix, and a clipping display that hid half the
result -- are all fixed.

**On the original symptom, stated precisely.** The reproduction of the *hang itself* was never
achieved programmatically, so what is proven is that the documented cause is gone and the feature
now behaves correctly across repeated owner runs. If a freeze on activation is ever seen again,
press Enter or Escape before killing the process: that still distinguishes an invisible modal from
a genuine deadlock, and would mean the cause was something other than this.

**Verification status of the original fix -- kept for the record.** The structural claim is
verifiable by reading the code and is certain: no modal can now be raised from inside the activation
handler. What has *not*
been done is reproducing the original hang and showing it gone, because the hang was never
reproducible programmatically in the first place (Windows' foreground lock prevents another process
from producing a genuine activation). **So this fix removes the documented cause; it has not been
proven against the symptom.** Confirming it needs an owner run: with two files open in the IDE,
change both on disk from outside, then click the IDE to focus it. Expected: one dialog listing both
files, visible and answerable, with the IDE responsive afterwards either way.

The original analysis follows.

**Symptom, observed by the owner during TestPlan C4 setup:** the IDE would not respond to being
clicked, could not be closed, and had to be killed from Task Manager. No dialog was visible and no
error appeared. Nothing was lost — the open file was intact and unmodified on disk — but the
session was gone.

**The code path.** `frmMain_ActivateApp` (`src/Main.bas`, ~10397) runs when the application is
activated. It walks every open tab, compares each file's last-write time against the one recorded
when it was loaded, and for any that changed calls:

```
MsgBox(tb->FileName & "\rFile was changed by another application. Reload it?", "File Changed", mtQuestion, btYesNo)
```

So **clicking the IDE to focus it can raise a modal dialog**. A modal disables its owner, which is
why the main window stops responding to clicks and ignores Close; if that dialog does not come to
the front — and one raised from inside an activation handler is precisely the case where it may not
— there is nothing on screen to answer, and the only way out is to kill the process.

This is the same family as the modal z-order defect this project already fixed once (`MsgBoxForm.bas`
had to set `Visible = False` before `CreateWnd`). Worth reading that fix before touching this one.

**Evidence status — read this before assuming it is understood.** The symptom is owner-observed and
the code path is certain, but the hang has **not been reproduced programmatically**: an attempt
failed because Windows' foreground lock prevents `SetForegroundWindow` from another process
producing a genuine activation, so the handler never ran. The hypothesis is strong and matches the
symptom exactly, but it is a hypothesis.

**The test that would confirm it, cheaply:** when the IDE next freezes this way, press **Enter** or
**Escape** before killing it. A modal-blocked application still processes keyboard input when clicks
do nothing, so if the IDE springs back the invisible-modal explanation is confirmed. If Enter and
Escape do nothing, it is a genuine deadlock and a different investigation entirely.

**Why this must be fixed before outside testers see it.** The trigger is a file changing on disk
while the IDE has it open — which is not exotic:

- **The IDE's own Git menu.** Pull, or switching branches, rewrites files that are very likely open.
- **AI agents.** Astoria's headline feature is AI integration, and an assistant editing project
  files is the normal case, not the edge case.
- **Cloud sync and external editors.** Any sync client or second editor touching a file does it.
- It is how the owner hit it: a file was edited outside the IDE while it was open.

A tester who meets this has no error message, no dialog, and no recourse but Task Manager. That is
the definition of a rough edge a newcomer cannot distinguish from their own mistake, and it fails
the *it just works* standard the product commits to.

**Fix options, in the order they should be considered:**

1. **Do not show modal UI from the activation handler.** Defer it — post a message and prompt once
   activation has fully completed, when the window is in a normal state. This alone likely removes
   the hang.
2. **Prefer a non-modal notification** — an info bar or status-bar prompt offering *Reload* — over a
   dialog. Nothing about "a file changed on disk" requires blocking the whole application.
3. **Batch the files.** The loop raises one dialog per changed file, so a `git pull` touching six
   open files means six sequential modals. One prompt listing them is better in every way.
4. If a modal is kept, ensure it is owned by the main window and explicitly brought to front, per
   the earlier `MsgBoxForm` fix.

There is already a correct re-entrancy guard (`Static bInActivateApp`), so that is not the bug; do
not "fix" it there.

### 13.19 Designer undo — **RESOLVED 2026-07-18.** The premise below was wrong

**Resolved.** Ctrl+Z, Ctrl+Y and the clipboard shortcuts now work on the design surface. The
original diagnosis in this entry was mistaken and is kept, struck through, because the mistake is
instructive.

**What this entry claimed:** the designer has no undo implementation, so undo would have to be
built from scratch (a command model, an operation stack) or the menu greyed out to be honest about
the gap.

**What was actually true:** the designer already had full undo, and always did. Every designer edit
is bracketed by `DesignerModified` with `EditControl.Changing`/`Changed`, which writes an entry
into the code editor's history — one history serving both views. Nothing needed building.

**The real defect was menu structure.** Undo lived in the **Code** menu, and the Code menu is greyed
in Form view. Windows' `TranslateAccelerator` **consumes an accelerator whose parent menu is
disabled and sends no `WM_COMMAND` at all** — so Ctrl+Z was destroyed in the message loop before
any window saw it. Not ignored: destroyed. That is why it produced no error, no log line, and no
observable behaviour of any kind.

**Fix (owner's design):** menus were restructured so that **Code** holds only code-specific
commands, **Form** only designer-specific ones, and a new **Code/Form** menu holds everything valid
in both — Undo, Redo, Cut, Copy, Paste, Duplicate, Select All. That menu is never greyed, so its
accelerators can never be suppressed. Verified working in both views.

**The lesson worth keeping:** *greying a top-level menu silently disables every keyboard shortcut
inside it.* Any future contextual-greying decision has to account for that, and any command usable
in more than one context belongs in a menu that is never greyed.

**On the proposed "cheap honesty fix":** greying Undo out in Form view would have been actively
harmful. The capability existed and worked; greying it would have made the breakage permanent and
made it look deliberate. It is worth noting how confident that recommendation reads given the
premise was false — the diagnosis was reasoned from reading the code, and reading agreed with
itself. It took measurement, not reading, to find the truth.

### 13.20 MariaDBBox: four defects from an untested SQLite copy — **RESOLVED 2026-07-18** (found by TestPlan A3)

**Status: all four FIXED and verified.** A3 now passes 34/34 against MariaDB 10.6.8, with the
checks that recorded these defects promoted to regression assertions (REGRESSION 1-4 in the test).
The fixes are in `Controls/MariaDBBox/MariaDBBox.bas`; user programs compile that source directly
(`MariaDBBox.bi` includes it), so `MariaDBBox_x64.dll` is design-time only and needed no rebuild.
The original findings are kept below as the record of what was wrong and why.

`Controls/MariaDBBox/MariaDBBox.bas` is evidently a copy of `SQLite3Component` that was adapted for
the MySQL client API but never run against a real server. The data path works — A3 passes 24 checks
including a close-and-reconnect persistence test — but four calls are broken, two of them silently.

1. **`CreateTableUtf` can never create a table.** It emits SQLite's `AUTOINCREMENT`; MariaDB
   requires `AUTO_INCREMENT`, so the statement is a syntax error. Fix: `AUTO_INCREMENT`.
2. **`AddField` does not quote a text default.** It escapes embedded apostrophes and then emits
   `DEFAULT hello`, which MariaDB parses as a column reference (`Unknown column 'hello' in
   'DEFAULT'`). This is the same defect A1 found in the SQLite twin, where it was fixed by
   `SQLite3DefaultIsLiteral`; port that helper.
3. **`AddField` silently makes columns `NOT NULL`.** `nNull` defaults to 0, which appends
   `NOT NULL` with no default. Unlike SQLite, MariaDB accepts this and invents an implicit
   default, so the call **succeeds** and the caller gets a column that does not mean what they
   asked for. Confirmed via `information_schema`: `AddField("people","name","VARCHAR(64)")`
   yields `IS_NULLABLE=NO`. Fix as in SQLite: only append `NOT NULL` when a default exists.
4. **`Insert` cannot report failure.** Every error path in `InsertUtf` returns 0, and the success
   path falls off the end with no assignment (the `last_insert_rowid` line is commented out), so
   it returns 0 there too. A caller has no way to distinguish a successful insert from a failed
   one. This is the most serious of the four because it loses data silently. Fix: return the new
   row id on success and a negative value on failure — and note this changes the contract, so the
   return convention should be documented at the same time.

**Related: the return conventions across this API are inconsistent** and should be documented even
if not changed. `Exec`, `Update` and `DeleteItem` return `-1` on error and otherwise
`mysql_affected_rows`; `Insert` returns 0 regardless; `Count` returns 0 both for "no rows" and for
"not opened". A3's first draft asserted the wrong convention for `Update`/`DeleteItem` and reported
two failures against working code.

**Priority.** Defects 1 and 2 fail loudly and are merely broken. Defects 3 and 4 succeed while
doing the wrong thing, which is the "it just works" standard's real target: a beginner cannot
diagnose an insert that reports success and stores nothing. Recommend fixing all four together,
mirroring the SQLite fixes, with A3 promoted from recording them to asserting the corrected
behaviour once done.


### 13.21 A renamed control frees its old name for reuse while its handler keeps it (observed 2026-07-18)

Follow-on from §13.17, seen in the owner's own test project immediately after the C3 fix.

Renaming a control deliberately does **not** rename its event handler, because renaming a handler
breaks anything that calls it by name. That policy is right, but it has a consequence worth stating:
the old control name becomes free again, and the designer's auto-namer will hand it to the next
control of that type. The test project now genuinely contains:

- a `Label` called `lblGreeting`, whose click handler is `MainType.Label1_Click`, and
- a different, unrelated `Label` called `Label1`.

Nothing is broken and the project builds. But the handler name now points at the wrong control by
implication, which is worse than the "name no longer matches its control" case §13.17 anticipated --
there, the name matched nothing; here it matches something else.

**The concrete risk to check:** wiring an `OnClick` on the new `Label1` should generate
`Label1_Click`, which already exists and belongs to another control. Whether the designer detects
the collision, silently reuses the existing handler, or emits a duplicate declaration has not been
tested. A duplicate `Declare Sub` would fail the build; silently reusing the other control's handler
would be worse, because it would work and be wrong.

**Options:** offer to rename the handler alongside the control (opt-in, since it is the breaking
half); or exclude names still referenced by a handler from the auto-namer's pool; or, cheapest,
detect the collision at wiring time and pick `Label1_Click_1`. Decide the policy before the first
one, per the note in §13.17.

Not a 1.0 blocker: it requires a specific sequence to reach, produces no silent data loss, and the
worst case discovered so far is a build error that names the duplicate.
### 13.22 MsgBoxForm clips long unbreakable text such as file paths (found while fixing 13.18)

`MsgBoxForm.Execute` measures its message with `DT_WORDBREAK` into a **fixed** content width
(`iContentWidth = 380` logical units). The box grows in height to fit the measured text, but never
in width. `DT_WORDBREAK` breaks between words, and a file path contains no spaces -- so a path
longer than the content width has no break opportunity and is clipped at the right edge instead of
wrapping.

**Why this matters more than a cosmetic clip.** Paths in one project share a long directory prefix,
so clipping removes exactly the part that distinguishes them. Two different files render as two
identical-looking lines. This was found the hard way: the 13.18 reload prompt correctly listed two
changed files, and the owner reasonably reported that only one was listed, because both lines
displayed the same truncated prefix. Several wrong hypotheses were chased through the detection and
queueing code before the owner suggested the display itself might be truncating. The dialog was not
merely ugly, it was actively misleading.

The 13.18 prompt now works around it by showing the shared folder once and listing bare file names,
which fit. **The underlying limitation remains** and will affect any dialog that puts a path, URL,
or other unbreakable token on its own line -- error messages naming a file are the obvious risk.

**Options:** measure the text first and widen the box (up to a sensible maximum, or a fraction of
the work area) when the natural width exceeds the fixed one; or add `DT_EDITCONTROL` / break long
tokens at character boundaries so they wrap rather than clip; or middle-ellipsize paths so the
distinguishing tail survives. Widening is the most generally correct and probably the cheapest.

Not a 1.0 blocker on its own -- no data is at risk and every current caller either uses short text
or has been worked around -- but it is a trap for future dialogs and should be fixed before many
more are written.

### 13.23 No documentation on setting up Git for use with Astoria (owner-raised 2026-07-19)

Astoria's Git integration works, and its individual steps each explain themselves in the moment.
What does not exist anywhere is the **sequence** — what a user has to do, once, before any of it
works. That sequence spans the IDE and a web browser, and nothing tells them so up front.

At minimum a user needs to: install Git for Windows (Astoria bundles the compiler and debugger, but
**not** git itself — `git` must be on PATH); enter their name, e-mail and GitHub username in
Tools ▸ Options ▸ Personal Information; generate an SSH key with Git ▸ Set Up SSH Key; **paste that
key into GitHub's SSH-keys page**, which the IDE opens but cannot complete for them; and create the
remote repository on GitHub before pushing to it.

Two of those steps end in the browser and cannot be automated without either handling the user's
credentials or shipping a CLI, which is deliberately not done (see the 2026-07-19 removal of the
gh/glab dependency). That makes documentation the *only* place the whole path can be described, not
a substitute for a feature we might build later.

**Why this matters more than a typical doc gap.** Git is where the target audience is most likely to
be starting from zero. A learner who has never used SSH keys has no idea that a generated key is
useless until it is registered, and the failure they meet is an authentication error at push time —
far from the step they actually missed. Everything else in Astoria is designed so a beginner cannot
end up somewhere they cannot get out of; this is the one path where they can.

**Scope:** a page in `Documentation/` written for someone who has never used Git, covering the
one-time setup in order, what each step is for, what Astoria does and what only they can do, and the
two or three errors they will hit if a step is skipped — with the fix for each. Should be linked
from `AstoriaIDESignificantChanges.md`, since that document tells prospective users the Git
integration exists.

**Also worth settling here:** whether Astoria should detect a missing `git` at startup or on first
Git use and say so plainly, rather than letting the first Commit fail obscurely. That is a small
feature, but it belongs with this documentation rather than on its own.

### 13.24 Analysis scratch file `Temp.bas` is left in the user's project folder (found by TestPlan D2, 2026-07-19)

When code analysis runs against a tab with unsaved changes, `TabWindow.bas` (around lines 11201 and
11235) writes the tab's current text to a scratch file so the analyser has something on disk to read:

```
FFileName = GetFolderName(tb->FileName) & "Temp.bas"
tb->txtCode.SaveToFile(FFileName, ...)
```

**Nothing deletes it.** After a perfectly ordinary D2 run — create a Windows Application, place three
controls, wire an event, build — the project folder contained `Temp.bas`, byte-identical to
`Main.frm`, sitting next to it.

**Why it matters despite being harmless today.** It is not in the `.vfp`, so it does not break the
build, and this repository's `.gitignore` lists `Temp.bas` — which says the artefact is known and has
been worked around rather than fixed. A user's project folder has no such `.gitignore`. They get an
unexplained duplicate of their form beside their form, and the two obvious things a beginner might do
with it are both bad: add it to the project (duplicate definitions, errors that make no sense) or
edit it by mistake (work silently discarded on the next analysis run).

It also lands in whatever the user commits, since their own Git repository will not be ignoring it.

**Two fixes, either acceptable:**

1. **Write it somewhere private.** `ExePath/Temp/` already exists and is already used for the
   Immediate window's scratch file (`Temp/FBTemp.bas`); a per-tab name there keeps the user's folder
   clean. The existing code already falls back to `ExePath/Temp/Untitled.bas` when the tab has no
   folder, so the path is half-built already.
2. **Delete it after use.** Smaller change, but leaves a window where a crash strands the file, and
   still touches the user's folder.

Option 1 is the correct one: the user's project directory should contain only what the user put
there. Worth doing before outside testers see it, because "what is this file?" is exactly the kind of
thing that erodes confidence in a tool that otherwise looks tidy.

### 13.25 First-start dialog: choose the shape of the IDE once (owner-raised 2026-07-19)

The first time Astoria runs, ask a short set of questions and configure itself from the answers,
instead of presenting every capability to every user whether they want it or not.

Proposed, from the owner:

- **Use Git?** If no, the Git features are **unavailable** — not greyed with an explanation, simply
  not part of this user's IDE. A learner writing their first program does not need version control
  in the menu bar, and its absence removes a whole category of "what is this for?".
- **Use AI?** Same shape. AI-friendly projects and the MCP server are a headline feature for some
  users and noise for others.
- **Personal Information** — offer to fill in name, e-mail and Git identity there and then, rather
  than leaving the user to discover Tools ▸ Options before their first commit fails.

**Why this fits the philosophy rather than contradicting it.** Astoria's line is "make the choice
once, on the user's behalf, and remove the option". This is the small set of choices Astoria
genuinely cannot make for someone: whether they use version control, whether they want an AI
assistant, and who they are. Asking once, at the only moment when asking is not an interruption, is
consistent with removing options everywhere else.

**Design points to settle:**

- Reversible afterwards, in Options — a first-start answer must not be a life sentence. That in turn
  means "unavailable" has to mean *hidden and inert*, not *deleted*, and turning it back on must
  work without a reinstall.
- Where the answers live (`astoria.ini`), and what a missing file means — the dialog must not
  reappear on every run, nor be skipped for a user whose settings were reset.
- Whether "no Git" should also hide the Git mode in New Project. It should, or the user meets Git
  anyway at the first thing they do.
- Interaction with 13.23: a user who says "yes, Git" is exactly the audience for the Git setup
  documentation, and this dialog is the natural place to link it.

### 13.26 No way to convert a local project into a Git project (owner-raised 2026-07-19)

New Project offers Create Local (no version control) or Use Existing Git Project. The choice is made
at creation and there is no path between them: someone who starts local and later wants version
control must create a second project in Git mode and move their files by hand.

This surfaced during TestPlan D3, when Git ▸ Commit was found greyed for a local project. The
greying is correct — the menu is gated on the folder containing `.git` — but "correct" and "a dead
end" are both true here.

**What a conversion has to do**, which is why this is a task rather than a one-liner: `git init`;
stamp the `.gitignore` and `.gitattributes` Astoria already writes for Git projects; make the first
commit with the user's configured identity; record the provider and URL in `project.astoria` so the
project reports itself as Git-backed; and then either wire an existing remote or hand off to Create
Remote Repository. Every one of those pieces exists already for the New Project Git path — this is
mostly a matter of sequencing them against an existing folder.

**Open:** whether it belongs in the Project menu ("Add version control…") or the Git menu, and
whether it should offer to create the remote in the same pass or leave that as a separate step.

### 13.27 The left panel jumps to the Toolbox — **RESOLVED and OWNER-VERIFIED 2026-07-19**

**Resolved.** Astoria no longer selects the Project or Toolbox panel except when the user enters a
different project. Whatever panel you choose stays chosen.

**Verified** by the owner against the 21:27 build of `0d6c6be`, four checks, all passing:

1. **Startup lands on Project.** Tested with `LeftSelectedTab=1` (Toolbox) written into
   `astoria.ini` first — with the value left at its default `0` this test cannot fail, because `0`
   *is* Project. Baiting the setting against the fix is what makes it an assertion.
2. **New Project selects Project** rather than inheriting the previous project's panel.
3. **No unrequested jumps.** With a form open and Project selected: saving, **adding a file**, and
   switching Code / Form / Code+Form all leave the panel alone. Adding a file is the deliberate
   case — it is precisely what the abandoned `ByUser` attempt still got wrong.
4. **View ▸ Toolbox still selects the Toolbox.** Removing auto-selection must not remove the
   manual path.

`ApplyView` used to end both the `"Form"` and `"CodeAndForm"` branches with an unconditional
`tpToolbox->SelectTab`, so every application of a form view dragged the panel there — including
re-applications the user never asked for, such as after a save.

**The fix is a rule, not a condition.** The first attempt made the jump conditional on the user
having chosen the view, threading a `ByUser` flag through `ApplyView`/`ShowView`. That fixed opening
a form but not adding a file, and the owner's call was better than the mechanism: *remove
auto-selection entirely; the system does not choose the panel.* The flag went with it — machinery
for deciding when the IDE should choose, in service of a rule that says it should not.

Astoria now selects the Project pane at exactly three moments, all of them "you have entered a
different project":

1. **Startup.** Previously it restored `LeftSelectedTab` from `astoria.ini`, which is the same
   problem in slower motion — the panel a previous session happened to end on is not a choice for
   this one.
2. **New Project.** This was the inconsistency the owner caught: Open Project and Open Folder
   already selected the Project pane, and New Project alone left you wherever you were, so a new
   project inherited the previous project's panel.
3. **Open Project / Open Folder** — unchanged, already did this.

**View ▸ Toolbox** remains, because that is the user asking.

**Method note.** A long detour went into instrumenting `TabPage.SelectTab` to find a "mystery path"
that was selecting the Toolbox when a file was added. The instrumentation never fired — its log path
contained `	ab_trace.log`, whose `	` had been turned into a literal tab by a shell heredoc, so
every write failed silently and the silence was read as evidence. The third such escape-mangling of
the session. Two lessons, both cheap: build Windows paths in generated code with `Chr(92)` or forward
slashes, and **prove an instrument can fire before trusting what it does not say.**

**Leftover, minor.** `LeftSelectedTab` in `astoria.ini` is now write-only: still written on tab
change (`Main.bas:8089`) and on close (`Main.bas:10561`), but never read back, since startup
hardcodes `0` (`Main.bas:8155`). The in-session `leftSelectedTabIndex` variable is still doing real
work — `Main.bas:7678` uses it to restore the panel after un-collapsing — so only the *persisted*
value is dead. Harmless, but it is the same species as the vestigial encoding/line-ending pickers
noted at the top of this document: a setting the UI implies is honoured and which is not. Either
stop writing it or drop the key.

### 13.28 The IDE cannot be operated by keyboard alone (found by TestPlan E9, 2026-07-19)

**Status: PART 1 RESOLVED 2026-07-20 — the blocker is gone. Parts 2–4 remain open.** Not yet
owner-verified.

**Part 1 (the New Project dialog) is fixed, and the cause was one omission in the framework.**
`Form.Show` focuses the first control; `Form.ShowModal` never did. A modal therefore opened with
focus on the form itself and nothing inside it focused — and that single omission disabled *both*
reported behaviours at once, which is why they looked like separate defects: the modal pump's
`VK_TAB` case takes its `GetFocus() = Handle` branch when no control is focused, so Tab moved
nothing; and `Control.bas`'s per-control `VK_ESCAPE` handler never received a key, because no
control was there to receive one. `ShowModal` now calls `SelectNextControl` as `Show` does.

Two supporting changes: a modal naming no `CancelButton` gets an `Escape` fallback in the pump that
cancels and closes it, so no modal can be a trap; and `frmNewProject` now names its `cmdCancel` as
`CancelButton`, routing Escape through the button's own handler rather than adding a second exit
path. Dialogs that already name a `CancelButton` are deliberately left to the existing per-control
handler, so Escape remains available to a focused control that legitimately uses it — closing an
open combo dropdown, for instance.

**Verified by effect** on three dialogs: New Project and Find each get initial focus on a real
control, move focus on Tab, and close on Escape. D1 re-run 12/12 and E11 10/10 as regression checks,
since this is framework code every dialog goes through. Documented in `Documentation/Controls.md`
because it changes behaviour for **user programs too**, not only the IDE.

**One dialog still does not close on Escape: External Tools.** It is shown with `Show`, not
`ShowModal` (`AstoriaIDE.bas:679`), so it is modeless and the modal pump's fallback does not reach
it. This is **not** the same trap — a modeless window does not disable the IDE, so the user is not
stuck — and the app-wide pump that would fix it also serves the main window, where Escape must
certainly not close anything. Left open deliberately rather than risking that.

**Remaining, still open.** Building and running are fully reachable from the keyboard and the menu
bar is properly keyboard-driven, but **a user who cannot use a mouse still cannot open a file**,
because the project tree cannot be reached (part 2 below).

Four defects, sharing one likely root cause: MFF forms do not run their input through a dialog
manager, so standard dialog navigation (initial focus, `Tab`, `Escape`, default button) is never
applied. The menu bar works because menus are native Win32 and handle their own navigation.

**1. The New Project dialog takes no keyboard input at all.** *This was the blocker.* **FIXED
2026-07-20 — see the status note above.** No control had initial focus, typing did nothing, `Tab`
moved nothing, and `Escape` did not close it; only `Alt+F4` dismissed it. Because the IDE opens
straight into this dialog when no project is loaded, a keyboard-only user met it first and could not
get past it *or out of it*. Input did reach the window (`Alt+F4` proved that); the dialog simply
ignored navigation, because nothing inside it was focused.

**2. The project tree cannot be reached.** **LARGELY FIXED 2026-07-20; one step needs a hand
check.** `Ctrl+R` ("Project Explorer") used to put the caret in the panel's *search box*, not the
tree; `Tab` did not move from there into the tree, so no project member could be opened.

`Ctrl+R` now focuses the **tree** (falling back to the search box only when no project is loaded,
where the tree has no nodes), and selects the first node if nothing is selected — a tree with no
selection ignores the arrow keys, so focusing it alone would still have looked unresponsive.

**A second defect surfaced once the tree could be reached, and it would have made the fix useless.**
`tvExplorer_SelChange` calls `OpenTreeNodeOnSingleClick`, so *any* selection change opened the file
— right for a mouse click, wrong for arrowing. Walking the tree opened every file passed over, and
each open moved focus to the editor, so the **second** arrow press went to the editor and keyboard
navigation ended after one keystroke. A keyboard move is now distinguished from a click
(`bExplorerKeyboardMove`, set on the arrow/paging keys in `tvExplorer_KeyDown`): arrows move the
selection without opening anything, and Enter still opens through the existing
`OnNodeActivate`/`tvExplorer_DblClick` route. The parent-node bookkeeping after the open still runs
on keyboard moves, so main-project tracking does not silently stop while navigating.

**Verified by effect:** Ctrl+R focuses the tree, and focus *stays* in the tree across four arrow
presses (it previously jumped to `EditControl` on the first). D1 re-run 12/12.

**Outstanding, and deliberately not recorded as a defect: Enter on a file node did not open it in
the harness.** The wiring reads correct — `tvExplorer_DblClick` acts on `SelectedNode`, and the
framework raises `OnNodeActivate` on `NM_RETURN` — and the navigation may simply have been sitting
on a folder. Given that synthesized `Ctrl+Z` was proved this same day not to reproduce hand
behaviour (§13.34), a negative from synthesized input is not evidence here. **Needs a hand check:
Ctrl+R, arrow to a source file, press Enter.**

**3. `Alt+R` does not open the Run menu**, although the mnemonic is advertised in the menu bar and
`Alt+F` works from an identical state. Workaround: `Alt+F`, then arrow right.

**Measured properly on 2026-07-20, and the earlier "Alt+E fails the same way" clue was wrong.**
The whole top-level menu bar was read out of the running process with `GetMenuItemInfo`, and each
`Alt+<letter>` was then driven with `SendInput` and judged by `GetGUIThreadInfo` menu state rather
than by appearance:

| Letter | Result |
| --- | --- |
| `Alt+F` `Alt+V` `Alt+P` `Alt+T` `Alt+W` `Alt+H` | menu opens ✅ |
| `Alt+C` | **opens a Command Prompt instead of the Code menu** ❌ |
| `Alt+R` | nothing ❌ |
| `Alt+G` | nothing ❌ — **not previously recorded** |
| `Alt+E` | nothing — **expected, not a defect** |

- **`Alt+E` is not a defect and never was.** There is no Edit menu; it is `&Code`
  (`Main.bas:6985`). That clue is what framed this item as "menu mnemonics generally", and it should
  not be used to guide the fix.
- **`Alt+C` was two defects stacked, and only the first is fixed.** `CommandPrompt=Alt+C` was an
  accelerator, and `TranslateAccelerator` runs before menu mnemonics, so pressing `Alt+C` opened a
  terminal. That binding has been **moved to `Ctrl+Shift+C`** (verified by effect: a terminal opens
  on the new chord, and `Alt+C` no longer hijacks the foreground), and `ValidateHotKeys` (§13.35)
  now detects the whole shadowing class automatically. **But `Alt+C` still does not open the Code
  menu.** Removing the accelerator was necessary and not sufficient — it simply joined `Alt+R` and
  `Alt+G` below. Do not record this item as closed.
  Note `Ctrl+`` was rejected despite being the VS/VS Code convention: `GetAscKeyCode`
  (`Menus.bas:1454`) falls through to `Asc()`, so a backtick registers as `VK_NUMPAD0`.
- **`Alt+C`, `Alt+R` and `Alt+G` are one unexplained defect, not three.** All three are
  `MFT_STRING`, **enabled**, ampersand intact, with no competing accelerator and no
  `WM_SYSCHAR`/`WM_SYSKEYDOWN` handler anywhere in `src/` or the framework — Windows should be
  resolving them itself. They are menu-bar indices **3, 6 and 7**; indices 0–2 and 8–10 all work,
  and the two odd items sit between them (index 4 `Code/Form` has no mnemonic, index 5 `&Form` is
  disabled *and* duplicates `&File`'s `F`).

  **Two hypotheses have been tested and disproved, so do not spend time on them again:**
  1. *A greyed top-level menu swallows its own mnemonic.* Disproved — `GetMenuItemInfo` shows Code,
     Run and Git all enabled at the moment the presses fail.
  2. *User tools with an empty `Accelerator=` corrupt the accelerator table.* `Main.bas` appends
     `\t` to every tool caption, and `MainMenu.ParentWindow` treats any `\t` caption as an
     accelerator, so it calls `GetAscKeyCode("")` → `Asc("")` and inserts junk `ACCEL` entries.
     Real, and worth fixing on its own merits — but **not** the cause here: moving `Tools.ini`
     aside entirely reproduced the identical failure on C, R and G.

  **CONFIRMED ON A SECOND MACHINE 2026-07-20 — the defect is not machine-local.** The owner pressed
  `Alt+C`, `Alt+G` and `Alt+R` in Astoria on the other computer, against the same binary: no menu
  opens and **no bell rings** — the identical silent signature. The bell was checked deliberately
  rather than assumed, because a beep on the second machine would have meant Windows entered menu
  mode and failed to match, i.e. ordinary no-such-mnemonic behaviour, pointing away from the
  win32k mnemonic path entirely. **Machine state, installed software and per-machine input hooks
  are therefore ruled out**, and the failing set reproduces on demand on either machine — so an
  instrument can be built wherever is convenient and validated on both. It does **not** rule out
  something common to both Windows installs: if the kernel trace comes back empty, a third machine
  or a different Windows build is the cheap next test, ahead of more hypotheses.

  **RESOLVED TO ASTORIA 2026-07-20 — it is not the machine, and not interference.** A stock
  WinForms control application was built with the *same* mnemonic letters (`&File &Code &Run &Git
  &Tools`) and driven by the identical probe, on the same machine in the same session, with a
  `WH_KEYBOARD_LL` hook recording what the input stack actually saw:

  | | `Alt+F` | `Alt+C` | `Alt+R` | `Alt+G` | `Alt+T` |
  | --- | --- | --- | --- | --- | --- |
  | WinForms control app | opens | **opens** | **opens** | **opens** | opens |
  | Astoria | opens | **nothing** | **nothing** | **nothing** | opens |

  The hook recorded `VK 0x43 / 0x52 / 0x47` delivered in **both** runs, so the keystrokes are
  generated and reach the input stack identically. **The third hypothesis — a background
  application capturing these combinations (§13.34's trap) — is therefore also disproved for
  C/R/G.** The cause is inside Astoria or MFF. The control app doubles as a regression fixture and
  its script is worth keeping.

  **INSTRUMENTED 2026-07-20, and the failure is now precisely characterised.** `frmMain_Message`
  gained an observer (`LogMenuKey`, gated on `Temp/_astoria_menukeys.on`, off by default, never
  alters handling) recording `WM_SYSKEYDOWN` / `WM_SYSCHAR` / `WM_MENUCHAR` / `WM_INITMENU` /
  `WM_INITMENUPOPUP`. Pressing each letter gives three distinct signatures:

  | | `WM_SYSCHAR` | then | Meaning |
  | --- | --- | --- | --- |
  | F V P T W H | arrives | `WM_INITMENU` + `WM_INITMENUPOPUP` (idx 0,1,2,8,9,10) | menu opens |
  | **E** (no such menu) | arrives | `WM_INITMENU` + **`WM_MENUCHAR`** | correct "no match" |
  | **C R G** | **arrives** | **nothing at all** | activation never starts |

  **`Alt+E` is the control that makes this readable.** It proves the mnemonic-matching path is
  healthy: Windows enters menu mode and reports "no match" via `WM_MENUCHAR`. C, R and G never get
  that far — the character reaches the form and menu activation is silently abandoned. **So this is
  not a mnemonic-matching fault; something consumes `WM_SYSCHAR` before `DefWindowProc` acts.**

  **Also disproved (hypothesis four):** the three are not command items. All eleven bar entries have
  valid popups — Code `0x13E1209`, Run `0x202121D`, Git `0x1DB067F` — and the working six can be
  matched one-for-one against the `WM_INITMENUPOPUP` wParams in the log. Code, Run and Git own
  perfectly good popups that are simply never initialised.

  **MECHANISM FOUND 2026-07-20 — the system keys never reach the form at all.** A second instrument
  was added one level down, in the framework (`AstoriaLogSysKey` in `Control.bas`, gated on the
  `ASTORIA_LOGSYSCHAR` environment variable and self-contained, so MFF gains no dependency on
  Astoria), logging `Handled`/`Result` after `ProcessMessage` at all three dispatch points. The
  result contradicts what the Astoria-level log implied:

  ```
  SuperWndProc[TabControl]  WM_SYSKEYDOWN  wParam=&h43  Handled=0  Result=0
  SuperWndProc[TabControl]  WM_SYSCHAR     wParam=&h63  Handled=0  Result=0
  ```

  **Every** `WM_SYSKEYDOWN`/`WM_SYSCHAR` — working letters included — arrives at a subclassed
  **`TabControl`**, not the Form. The focused window is the tab control, and `Control.SuperWndProc`
  forwards anything MFF does not handle to `CallWindowProc(cp, ...)`, which is comctl32's **own
  tab-control procedure**, not `DefWindowProc`. Only one Form-level message appears in the entire
  run: the `WM_MENUCHAR` from `Alt+E`.

  MFF is not the consumer — `Handled=0` and `Result=0` on every line, so `Control.ProcessMessage`
  passes them straight through to `CallWindowProc`.

  **The tab-label theory this suggested is REFUTED (2026-07-20), on two independent grounds.**

  1. *Structural.* The focused window's **Win32 class is `TabControl`** — a custom class registered
     by MFF — **not `SysTabControl32`**. There is no comctl32 tab control anywhere in the focus
     chain (`TabControl` → `Panel` → `Panel` → `Form`), so there is no tab-label mnemonic machinery
     to blame. The `"TabControl"` in the log above is MFF's own `ClassName` property; reading it as
     the Win32 class was the error that produced the theory.
  2. *Empirical.* The prediction was that the failing set moves with the open tabs. It does not:
     with `FormA.frm` restored and again with `A1_SQLite3DataPath.bas` opened from the command
     line, the result is identical — F V P T W H open, **C R G do not**.

  That is the sixth hypothesis to die on this defect. Also worth recording: **UI Automation reports
  zero tab controls** in the process, so MFF's tab control exposes no accessibility tree at all —
  relevant to E10b (screen reader), which is still untested.

  **What is actually established:** the failing set is C, R and G — menu-bar indices **3, 6 and 7** —
  and it is stable across documents, workspaces and restarts. Working indices are 0,1,2 and 8,9,10.
  System keys reach the focused custom `TabControl` and menu activation never starts.

  **SC_KEYMENU measurement, run 2026-07-20.** `WM_SYSCOMMAND`/`SC_KEYMENU` was added to
  `LogMenuKey`. Result, with focus in the code editor rather than the tab control:

  | Letter | Messages reaching the form |
  | --- | --- |
  | bare `Alt` | `SC_KEYMENU` (lParam=0) + `WM_INITMENU` |
  | F V P T W H | `WM_INITMENU` + `WM_INITMENUPOPUP` idx 0,1,2,8,9,10 |
  | **E** | `WM_INITMENU` + `WM_MENUCHAR` |
  | **C R G** | **nothing whatsoever** |

  So the kill happens **before** `SC_KEYMENU` is generated: Windows begins menu activation for
  `Alt+E` — a letter with genuinely no menu — but not for C, R or G. And it is **focus-independent**:
  the same three letters fail whether focus is the `TabControl` (where `WM_SYSKEYDOWN`/`WM_SYSCHAR`
  do reach the form) or the editor (where they do not reach it at all). That combination rules out
  the focused control as the consumer.

  **Hypothesis seven — the accelerator table — is also disproved.** The table MFF builds was
  reconstructed from the live menu captions cross-process, applying MFF's own loose parsing rules
  (`InStr` substring tests for Ctrl/Shift/Alt, `GetAscKeyCode` falling back to `Asc()` of the first
  character). 65 entries; **exactly one bare `Alt+<letter>` accelerator exists — `Alt+O`** (Import
  from Folder), which collides with no menu. Nothing consumes `Alt+C`, `Alt+R` or `Alt+G`. No entry
  had an unrecognised key token either, so the `Asc()` fallback is not firing anywhere.

  A tempting near-miss to record so it is not re-derived: C, R and G each have a `Ctrl+<letter>`
  accelerator (Copy, Project Explorer, Goto). **That is a coincidence** — F, V, P, T and H all have
  one too (Find, Paste, Print, Toolbox, Replace) and all work.

  **Seven hypotheses have now been disproved:** greyed menus, empty tool accelerators, background-app
  capture, command-items-without-popups, comctl32 tab-label mnemonics, tab-label dependence generally,
  and the accelerator table.

  **Message loop instrumented 2026-07-20 — and it is EXONERATED (hypothesis eight).**
  `AstoriaLogLoop` in `Application.bas` records every system key at the three points in
  `Application.Run` that can suppress one: straight off `GetMessage`, after `TranslateAccelerator`,
  and immediately before the `TranslateMessage`/`DispatchMessage` decision. Every letter — the
  failing ones included — reaches all three stages with `dispatch=YES`:

  ```
  1 arrived    WM_SYSCHAR  wParam=&h66 ('f')  dispatch=YES     <- opens its menu
  2 postAccel  WM_SYSCHAR  wParam=&h66        dispatch=YES
  3 final      WM_SYSCHAR  wParam=&h66        dispatch=YES
  1 arrived    WM_SYSCHAR  wParam=&h63 ('c')  dispatch=YES     <- opens nothing
  2 postAccel  WM_SYSCHAR  wParam=&h63        dispatch=YES
  3 final      WM_SYSCHAR  wParam=&h63        dispatch=YES
  ```

  30 `WM_SYSCHAR` stage-records across 10 letters, no `dispatch=NO` anywhere. `TranslateAccelerator`
  claims nothing, no `OnMessage`/`KeyPreview` hook claims anything, and every message is dispatched.
  This independently confirms the reconstructed-accelerator-table result by a completely different
  method.

  **Eight hypotheses disproved.** Greyed menus; empty tool accelerators; background-app capture;
  command-items-without-popups; comctl32 tab-label mnemonics; tab-label dependence; the accelerator
  table; the message loop.

  **Where the loss must now be.** `DispatchMessage` delivers `WM_SYSCHAR` to the focused control, and
  the menu never activates — so the message dies in the focused control's window-procedure chain,
  between `DispatchMessage` and the `SC_KEYMENU` that `DefWindowProc` should raise to the top-level
  window. "Focus-independent" was too strong a reading: both observed focus targets (`TabControl`,
  code editor) are MFF controls and both go through `Control.SuperWndProc`, so what is really
  established is independence from *which* MFF control, not from the control layer.

  **STRONG LEAD 2026-07-20 — the WINDOW'S SYSTEM MENU claims two of the three letters.**

  A further run happened to have focus on the Form itself rather than a control, so every system key
  went through `DefWndProc [Form]` — and showed `DefWindowProc` being called on the **top-level
  window** with `WM_SYSCHAR` for every letter, `Handled=0`, `Result=0`. So Windows' own
  `DefWindowProc` receives `Alt+C` on the main form and produces nothing, while the identical call
  with `'e'` produces `WM_MENUCHAR`. Two further hypotheses died on the way: all popups have items
  (Code 28, Run 31, Git 7 — so nothing is an empty menu), and `SuperWndProc`'s `cp`-is-null path was
  never reached in that run.

  Reading the **system menu** (`GetSystemMenu`) explains it:

  ```
  [0] "&Restore"   mnemonic=Alt+R   enabled
  [6] "&Close"     mnemonic=Alt+C   enabled
  ```

  `Alt+R` and `Alt+C` are claimed by **&Restore** and **&Close** — exactly the two failing letters
  that collide with the `&Code` and `&Run` menu-bar mnemonics. That also explains the otherwise
  baffling silence: a system-menu mnemonic match is handled entirely inside `DefWindowProc`, so the
  menu bar never activates (no `WM_INITMENU`) and no `WM_MENUCHAR` is raised either — unlike `Alt+E`,
  which genuinely matches nothing and therefore does produce both.

  **THE SYSTEM-MENU LEAD IS REFUTED — by evidence that was already in hand (hypothesis nine).**
  The WinForms control app built earlier carries `&File &Code &Run &Git &Tools` on an ordinary
  top-level window with the same standard system menu, and **Alt+C, Alt+R and Alt+G all open their
  menus there**, on this machine in the same session. If `&Close`/`&Restore` intercepted those
  letters, that app would fail identically. It does not.

  It is also wrong on the mechanics: `Alt+<letter>` is dispatched against the **menu bar**, while the
  system menu is reached by `Alt+Space`. The theory required non-standard behaviour and the control
  app is direct evidence the standard behaviour holds.

  **The lesson, and it is the recurring one on this defect:** the correlation was strong (C↔Close,
  R↔Restore) and the silence fit, but it never explained G — and a theory that leaves part of the
  evidence unexplained should be discarded, not proposed. The control app existed specifically to
  answer "is this Astoria or the machine", and it should have been re-consulted before the theory was
  written down rather than after.

  **ANSWERED 2026-07-20 by experiment — it is the LETTER, and the cursed set is exactly {C, G, R}.**

  *Experiment 1, letter vs position.* `&Code` → `Co&de` (D) and `&Run` → `R&un` (U), `&Git` left on G
  as the control. **`Alt+D` opened Code (bar index 3) and `Alt+U` opened Run (index 6)** — the very
  menus that had been dead. Nothing is wrong with those menus or their positions.

  *Experiment 2, the system menu, properly tested.* `&Project` → `Proje&ct` (C, at known-good index 2),
  `&Tools` → `Tool&s` (S, collides with system `&Size`), `&Window` → `Wi&ndow` (N, collides with
  `Mi&nimize`). Result: **S and N both open** — system-menu collisions are harmless — while **C fails
  even on Project**, a menu that works perfectly under P. The system-menu lead is dead for good.

  *Experiment 3, the full alphabet.* All 25 letters (O excluded — `Alt+O` is a real accelerator and
  opens a modal dialog that would poison the run) swept with the `LogMenuKey` instrument armed, which
  distinguishes the two invisible outcomes: a letter with no menu gives `WM_INITMENU` + `WM_MENUCHAR`
  (Windows looked and found nothing), a swallowed letter gives **nothing at all**.

  **22 of 25 letters produce `WM_INITMENU`. Exactly three do not: C, G and R.**

  **The decisive detail: `R` is cursed even though no menu uses it in that build** (Run was on U).
  Unassigned letters A, B, I, J, K, L, M, Q, X, Y, Z all correctly reach menu mode and report no
  match. R does not. **So the block is below the menu layer entirely** — it is not about menu data,
  mnemonics, positions, popups or enabled state, and every hypothesis framed in those terms was
  looking in the wrong place.

  **Correction to the earlier control-app reasoning.** The WinForms app was never a valid control for
  the *menu* question: WinForms implements its own mnemonic handling in managed code
  (`ProcessDialogChar`/`ProcessMnemonic`) before `DefWindowProc` sees the key, so it never exercises
  the Win32 menu-bar search at all. It remains a valid control for "is something machine-global eating
  these keys" — it received and acted on all three letters — but it cannot speak to anything below
  that.

  **MFF IS INNOCENT — measured 2026-07-20.** A minimal MyFbFramework application was built
  (`scratchpad/MffMnemonicTest.bas`, ~50 lines: one `Form`, one `MainMenu` with `&File &Code &Git
  &Run &Tools`, attached by `This.Menu = @mnu` exactly as `Main.bas:11087` does) and compiled against
  the same `Controls\Framework` with the same `fbc64` flags. **`Alt+C`, `Alt+G` and `Alt+R` all open
  their menus there**, alongside the `&File`/`&Tools` controls.

  So the block is **specific to Astoria**, not the framework, not the machine, not Windows, and not
  menu data. Every user program built on MFF is unaffected.

  **Bisection from the minimal app upward — step 1: context menus, NOT the cause.** Astoria attaches
  `ContextMenu`s to many controls and their items carry accelerator text after a tab, which is the
  shape MFF's accelerator builder keys on. Adding a `PopupMenu` with `&Copy⇥Ctrl+C`, `&Goto⇥Ctrl+G`
  and `Project Explorer⇥Ctrl+R` (Astoria's three real bindings on the cursed letters) changed
  nothing — all five mnemonics still open.

  Also confirmed by search: Astoria installs **no** `SetWindowsHookEx`/`WH_KEYBOARD`/`WH_GETMESSAGE`
  hook and calls **no** `RegisterHotKey`, and the only `CreateAcceleratorTable` in the tree is the
  one in `Menus.bas:1561` already cleared by measurement.

  **The REAL accelerator table, dumped in-process 2026-07-20 — nothing dynamic claims these keys.**
  The owner asked the right question: could something be adding actions and keys at runtime that
  override the Alt assignments? It fits the strangest fact — `R` stayed cursed after Run was moved to
  `U`, when no menu used R at all. Everything said about accelerators until now rested on a
  *reconstruction* re-parsed from menu captions plus `TranslateAccelerator`'s single boolean, neither
  of which would catch a table built by an unmodelled path — and `Menus.bas:1561` reassigns
  `FParentWindow->Accelerator` on every menu rebuild and Options save. So `AstoriaDumpAccels` in
  `Application.bas` now reads the table Windows actually matches against, via
  `CopyAcceleratorTable`, once, on the first `WM_SYSKEYDOWN`.

  **65 entries — exactly matching the reconstruction's 65, which validates that earlier method.**
  Everything keyed on C, G or R carries `FCONTROL`:

  ```
  Ctrl+R        fVirt=&h9   cmd=1143      Ctrl+G  fVirt=&h9  cmd=1244
  Ctrl+C        fVirt=&h9   cmd=1257      Ctrl+Shift+C  fVirt=&hD  cmd=1350
  ```

  Only **two** bare `Alt+<key>` accelerators exist in the whole table: `Alt+VK_F4` (Exit) and
  `Alt+O` (Import from Folder). *Caution when reading the raw dump: `vk=&h73` renders as `'s'`
  because the printer shows any value in ASCII range as a character — `&h73` is `VK_F4`, not the
  letter S. That is a flaw in the instrument's output, not a bare Alt+S accelerator.*

  **So dynamic key registration is conclusively ruled out**, by reading the real table rather than a
  model of it. Combined with the loop measurement (`TranslateAccelerator` declining the keys) and the
  absence of any hook or `RegisterHotKey`, nothing in the accelerator path touches Alt+C/G/R.

  **Bisection step 2: the window structure, NOT the cause.** `Panel` → `Panel` → `TabControl` was
  added to the minimal app with the tab control focused, and the focus chain was verified to match
  Astoria's exactly:

  ```
  class='TabControl' / class='Panel' / class='Panel' / class='Form'
  ```

  All five mnemonics still open, C, G and R included. So it is not the nesting, not the docking, not
  a focused MFF `TabControl`, and not the tab captions.

  **Module survey of a running Astoria.** No add-in is actually loaded — `AddIns\` contains
  `FBMemCheckAssist64.dll` and `My Add-In (x64).dll` but neither appears in the process's module
  list, so add-ins are ruled out without needing a bisection step. Nothing unexpected is loaded
  either: `framework.dll` plus Windows components. Worth noting for later that the text-services
  stack **is** present (`msctf.dll`, `tiptsf.dll`, `globinputhost.dll`, `TextShaping.dll`,
  `Windows.Globalization.dll`, `icu.dll`) — a TSF text service can intercept keystrokes, and Astoria
  initialises text input where the minimal app does not.

  **Next bisection step: add the editor control.** It is the largest remaining functional difference,
  it is where text input and any IME/TSF initialisation happens, and it is present in every state
  where the defect has been observed. If the mnemonics survive that, the remaining candidates are the
  toolbars/status bar/image lists and the worker threads.

  Note `Form.bas:951`'s `IsDialogMessage` was checked and is **not** involved; that call is scoped to
  `VK_TAB`. Five hypotheses have now died on this bug; the routing above is the first thing about it
  that was measured rather than reasoned.

**Two structural mnemonic faults found by the same probe:** `&Form` (bar index 5) duplicates
`&File`'s `F` *and* is disabled at startup, and `Code/Form` (index 4) has no mnemonic at all.

**A latent framework bug found while reading the accelerator builder:** `GetAscKeyCode` returns
`127` for `Delete`, but `VK_DELETE` is `46`. No shortcut currently binds Delete, so it is dormant.

**Harness note.** Two *further* false-negative mechanisms were found on 2026-07-20, bringing the
running total to six: the x64 `INPUT` struct is 40 bytes (the union is sized by `MOUSEINPUT`), and a
32-byte version made `SendInput` return 0 with `ERROR_INVALID_PARAMETER` — sending nothing, which
reads exactly like a dead shortcut; and `Alt+C` opening a terminal stole the foreground and turned
every later letter in the sweep into a false negative. Restore the foreground before **every**
keystroke, and make the instrument prove it can report a positive before believing any negative.

**4. `Ctrl+F9` (Build) silently does nothing when focus is in the Project search box.** The same
command from the Run menu builds correctly, and `Ctrl+F9` works once focus is elsewhere. An
advertised accelerator that fails silently depending on focus is the same shape as §13.19/C4, where
a greyed parent menu made `TranslateAccelerator` swallow a shortcut without sending `WM_COMMAND`.

**Not all dialogs are affected**, which is useful for locating the fix: the *Recent Projects* dialog
is keyboard-navigable (arrows move the selection, `Enter` opens), and it is the only reason E9 could
test build and run at all. Compare it against the New Project form.

**Suggested order.** (1) is the release-relevant one — a modal that cannot be closed from the
keyboard is a trap, not merely an inconvenience, and `Escape` alone would remove the trap even
before full `Tab` traversal lands. (2) follows, since without it the IDE cannot be used for its main
purpose without a mouse. (3) and (4) are smaller and independent.

**How to re-run this.** Use real synthesized input (`SendInput`), never posted `WM_COMMAND`/
`BM_CLICK` — A7 established that a posted message travels a path a real user cannot, and driving
this test that way would report a confident pass. Guard the harness so it refuses to send unless
`astoria.exe` owns the foreground: an unguarded run types into whatever application Windows has
handed the foreground to, which happened during this test. And prove the instrument can fire before
believing what it does not say — "typing does nothing" was nearly recorded as a defect on the
strength of a harness that was targeting a modally-disabled window.

### 13.29 Launching Astoria while it is already running crashes the second process — **RESOLVED 2026-07-19** (found by TestPlan E11)

**Status: fixed and OWNER-VERIFIED 2026-07-19.** Re-tested 10/10 by
`TestHarness/E11_MultipleInstances.ps1`, D1 re-run 12/12 as a startup regression check, and the
owner confirmed by hand that launching Astoria while it is already running now brings the running
IDE to the front instead of crashing. Astoria is deliberately
single-instance, and that part always worked — but the second process did not *exit*, it **crashed
with an access violation**, and the running IDE was never brought to the foreground. A user who
double-clicked the desktop icon while Astoria was already open (minimised, or behind another
window) got a Windows crash report and no IDE in front of them.

**The fix, in `Main.bas`.** Two changes, one per side of the handover:

- *Sender.* `EnumWindows` now runs **unconditionally**, not only when a file was named, so a plain
  second launch hands over instead of falling through. The payload travels in a fixed
  `ZString * 4096` rather than `StrPtr` of a var-len string, because `StrPtr("")` can be NULL and
  the receiver rejects a null pointer — which is exactly the no-file case that had to be carried.
  `AllowSetForegroundWindow` is called for the target process first, or its own
  `SetForegroundWindow` is refused and the user still sees nothing. The callback no longer calls
  `End` from inside the enumeration; it returns `False` to stop it.
- *Exit.* The bare `End` is replaced by `ExitProcess(0)`. **This is the crash fix.** Module-level
  code is run from the CRT's global initialiser table, and `End` unwound the CRT from inside that
  walk — the backtrace faulted in `msvcrt!_initterm_e` every time. Nothing needs flushing at that
  point: no file is open and `framework.dll` is not loaded until later.
- *Receiver.* The `WM_COPYDATA` handler already restored and foregrounded itself; it now treats an
  **empty** payload as "raise the window, open nothing" instead of ignoring it.

**Verified by the transition, not the end state.** With the IDE minimised, a second launch takes it
from `IsIconic=True` to `IsIconic=False` and into the foreground — a state change the old build
could not produce, because it sent no message at all. Crash records went from 3/3 to 0/3 on the
no-argument path.

**The running instance was never harmed.** Verified across nine second-launch attempts: it stayed
alive, kept serving the agent pipe, and `astoria.ini` and `Workspace.ini` were byte-intact
afterwards. This was alarming rather than destructive — but it was exactly the "cannot tell a broken
tool from their own mistake" case the product standard is written against, and it happened on the
most ordinary user action there is.

**Reproduced 6/6 with no arguments; 0/3 with a file argument.** Same fault offset every time
(`0xC0000005` at `0x246be4`, faulting module `astoria.exe`), so this was deterministic, not a race.

**The cause is narrow and the two paths differ by one statement.** `Main.bas:76-84`:

- With a file argument, `Command(-1)` is non-empty, the guard on line 80 passes, `EnumWindows`
  forwards the path to the running instance by `WM_COPYDATA`, and the process leaves through the
  `End` **inside `EnumWindowsProc`** (line 69). No crash.
- With no arguments, `Command(-1)` is **empty** — it excludes the program name — so the line 80
  guard fails, `EnumWindows` is skipped, and control reaches the bare `End` on **line 83**. That is
  the statement that faults.

So the fault was in the module-level `End`, reached before `DyLibLoad` of `framework.dll` and before
the `Application` object is fully stood up. **Confirmed under GDB rather than assumed:** the
backtrace put the faulting frame beneath `msvcrt!_initterm_e`, the CRT's global
constructor/terminator table walker. FreeBASIC runs module-level code from that table, so `End`
there tears the CRT down from inside the walk that is still executing it. (Astoria's own frames all
resolve to the nearest export, `StatusBarPanelByIndex`, and are not meaningful — `_initterm_e` is
the informative one.) The `End` inside `EnumWindowsProc` never faulted because it runs from a
callback, not directly from the initialiser frame.

**A second, separate defect on the same path: the second launch does not raise the running IDE.**
Measured with a non-Astoria window deliberately parked in the foreground first — after the second
launch the foreground was unchanged. Even once the crash is fixed, a bare `End` leaves the user
having double-clicked an icon for no visible effect. The forwarding machinery to do this properly
already exists and is proven to work (the `.vfp` path above); the no-argument case simply does not
use it. Foregrounding the existing main window before `End` would fix both halves of the user
experience.

**How to re-run this, and two warnings that cost real time here.** *Do not trust the exit code.*
Two separate instruments reported a confident clean exit for a launch form that was in fact
crashing every single time: `start /wait astoria.exe & echo EXIT=%ERRORLEVEL%` prints the *previous*
errorlevel because `cmd` expands the variable when it parses the compound line, and even written
correctly `cmd`'s `ERRORLEVEL` does not carry `0xC0000005` out of `start /wait`. Count crash records
in the Windows Application event log (Provider `Application Error`, Id 1000, filtered to
`astoria.exe`) instead — three attempts should produce three records, and the fault offset confirms
they are the same defect. *And do not reason about `Command(-1)` — print it.* The first explanation
formed here was that `Start-Process` passes a quoted path so the `.exe` guard misses on the trailing
quote; a four-line FreeBASIC probe showed `Command(-1)` excludes the program name and strips quotes
entirely, which killed that theory and pointed at the real one.

### 13.30 The code editor ignores the system high-contrast theme — **RESOLVED and OWNER-VERIFIED 2026-07-19** (found by TestPlan E10a)

**Status: fixed. The owner confirmed Astoria "came up nicely" when started with the Dusk
high-contrast theme already active.** One limitation was found during that check and **accepted
deliberately** — see "Accepted limitation" below.

Astoria never detected high contrast — there was no `SPI_GETHIGHCONTRAST` call anywhere in `src/`.
The IDE's own chrome survived anyway, because it uses system colours (`clBtnFace`, `GetSysColor`)
and contains **zero hardcoded `RGB(...)` literals**. The editor did not, because its colours come
from `Settings/Themes/*.ini`, which are fixed palettes that know nothing about the system theme.

Tested against the Windows 11 **"Night sky"** high-contrast theme (a dark one), confirmed active by
`SPI_GETHIGHCONTRAST` before any screenshot was taken — `COLOR_WINDOW` black, `COLOR_WINDOWTEXT`
white.

**1. Line numbers become invisible — the concrete defect.** With a light Astoria theme
(`CurrentTheme=github`) under a dark high-contrast theme, the line-number margin renders **black
while the theme's line-number foreground stays near-black**, so the numbers disappear entirely.
Measured, not inferred: `github.ini` asks for `LineNumbersForeground=556` (`0x00022C`) on
`LineNumbersBackground=16316664` (`0xF8F8F8`). The background was overridden to black by the system;
the foreground was not. Without high contrast that margin is light grey and perfectly readable, so
this is high-contrast-specific rather than a broken theme.

**2. The editor opts out of high contrast altogether.** The code area keeps the theme's own light
background, so a light-themed editor is a glaring white panel inside an otherwise black IDE. The
whole point of high contrast is that the user controls contrast globally; an editor that ignores it
defeats that for the one surface they spend all their time reading.

**3. RETRACTED — the selected project-tree node was never a defect.** It was originally recorded
here as orange text on pale lavender, "the worst contrast on screen". That was wrong, and the way it
was wrong is worth keeping. Astoria sets **no** tree colours anywhere — there is no
`ForeColor`/`BackColor` on any tree control, and the framework's `NM_CUSTOMDRAW` path returns
`CDRF_DODEFAULT` — so those colours came from Windows, not from Astoria. Measuring a second
high-contrast theme settled it: under **Dusk**, `COLOR_HIGHLIGHT` is (161,191,222) pale blue and
`COLOR_HIGHLIGHTTEXT` is (33,45,59) dark. High-contrast themes really do use a pale highlight with
dark text, so what was seen under **Night sky** was that theme's own selection colours, correctly
honoured. **Acting on this would have replaced correct behaviour with a bug.** The lesson: before
calling a colour wrong, check whether the application chose it at all.

**What passes, and is worth not re-testing.** With a dark Astoria theme against a dark high-contrast
theme everything is readable: menus, toolbar, project tree, tab strip, editor, the designer surface
and its form caption. That is a genuine pass but a *coincidence* — the two happened to agree. Do not
record "high contrast works" from a dark-on-dark run; the light-theme case is the one that tests
anything.

**The fix, in `Main.bas`.** `IsHighContrastMode()` wraps `SPI_GETHIGHCONTRAST`. `SetAutoColors` —
the single point where every editor style resolves — gained a final block that applies one rule:
**the system owns the background, and a theme foreground is kept only if it clears a 4.5:1 WCAG
contrast ratio against it**, otherwise it is replaced with `COLOR_WINDOWTEXT`. Syntax colour
therefore survives wherever it legitimately can. Line numbers are pinned to system colours at both
ends (the invisible-text case); selection follows `COLOR_HIGHLIGHT`/`COLOR_HIGHLIGHTTEXT`, and the
current-line and current-word highlights follow `COLOR_BTNFACE`. The whole block sits inside
`If IsHighContrastMode()`, so **with high contrast off not one value changes**.

Note the luminance helper reads a **COLORREF, which is BGR** — getting that backwards silently swaps
red and blue and shows up only as a wrong contrast decision, not as an error.

**Verified by exact pixel values rather than by eye.** With a light theme (`github`) under Dusk, the
line-number margin and the code area both render `45,50,54` — `COLOR_WINDOW` exactly — with digits
at `255,255,255`, `COLOR_WINDOWTEXT` exactly. Before the fix the margin was black with no visible
digits at all. With the dark `gradient-dark` theme, syntax highlighting is **preserved** (cyan,
orange and blue all clear 4.5:1), which is the property that distinguishes this from simply
flattening everything to white. D1 re-run 12/12.

**The high-contrast-*off* path is owner-verified too**: Astoria starts correctly after a theme
change, so the gated block genuinely changes nothing when high contrast is not active. That matters
because the fix touches the colour resolution every editor style passes through — a regression there
would have hit every user, not only high-contrast ones.

**Accepted limitation, owner's decision 2026-07-19: switching the system theme *while Astoria is
running* leaves the colours a mish-mash.** Colours are resolved at load, and there is no
`WM_SETTINGCHANGE` handling, so a theme change mid-session is not picked up. Closing and reopening
Astoria fixes it completely. The owner's reasoning, recorded so this is not re-opened as a bug:
Windows' own applications are imperfect under a live high-contrast switch, the workaround is trivial
and obvious, and a high-contrast user always retains the more important choice — picking a dark
editor theme, exactly as users who do not need high contrast pick from the same variety. Handling
`WM_SETTINGCHANGE` remains the correct eventual fix if this is ever revisited; it is not 1.0 work.

**One thing left unmeasured.** The bottom Code/Form tab strip appeared vertically clipped in both
captures ("Code And Form" cut off at the window edge). Whether that is high-contrast-related — HC
themes often enlarge system fonts and borders — or just this window size was not established, and
should be checked before it is written up as anything.

### 13.31 UI simplification: Tip of the Day removed, toolbars fixed and all-or-nothing — **RESOLVED and OWNER-VERIFIED 2026-07-19**

Three owner-requested changes, made together because they all touch the same startup and chrome
code. Recorded here rather than treated as new features: each **removes** a choice rather than
adding one, which is the direction the *it just works* rule points.

**1. Tip of the Day is gone.** The Help menu item, the startup modal, the `TipoftheDay` command
case, the `#include`, both globals, `src/frmTipOfDay.frm` and `Help/Tip of the Day/` are all
removed. `ShowTipoftheDay` and `ShowTipoftheDayIndex` are actively `KeyRemove`d on load so they do
not linger in a settings file that already has them.

**2. The toolbars are pinned to three fixed rows** — Standard+Edit+Project, then Run, then Format —
regardless of window or monitor width. Previously the ReBar reflowed on every resize, so a wide
monitor collapsed the whole set onto one very long line of icons, which the owner found harder to
read than the three-row form. `RBBS_BREAK` (`ReBarBand.Break`) on Run and on Format pins the
grouping, re-applied after any visibility change because hiding and re-showing bands otherwise lets
them reflow.

**The interacting detail worth knowing before touching this again:** *maximising a band makes it
fill its row*, so the old loop — which maximised bands 0..3 — would have shoved Standard's and
Edit's row-mates onto rows of their own, defeating the breaks. It now maximises only the **last band
on each row** (2, 3, 4). The framework compounds this: `ReBarBand.Update` calls
`If Not FBreak Then Maximize`, so a band without a break maximises itself. The null-pointer guard
from the 13.3.A startup crash (`Bands.Item(i)` returns null out of range) is kept.

**3. View ▸ Toolbars is one on/off toggle, not a submenu of five.** Backed by a single
`ShowToolBars` key; the five retired per-toolbar keys are `KeyRemove`d. Per-toolbar choice let a
user end up with a half-populated bar and no obvious way back, and bought nothing once the row
layout is fixed. **Consequence:** right-clicking a toolbar no longer does anything — that handler
existed only to pop the submenu, and leaving it wired would have dereferenced a `SubMenu` that no
longer exists. A user who had hidden individual bars gets them all back on upgrade, which is the
intent.

**Verified:** clean build, zero warnings, D1 re-run 12/12 (startup is on the changed path). The owner
confirmed all three by hand — including that the three rows hold with the window maximised, which is
the whole point of (2) and the one thing a narrow-window screenshot cannot show.

**A capture that looked like a failure was not one.** A screenshot taken during this work showed *no
toolbars at all* and was about to be investigated as a defect; the owner had toggled View ▸ Toolbars
off just before it was taken. That was the new single toggle working correctly. Worth remembering
that a screenshot records a state someone may have just changed, not necessarily the code's own
behaviour.

### 13.32 Ctrl+Shift+O (Open Project) is advertised but can never fire — **RESOLVED 2026-07-20** (found by TestPlan E12)

**Status: fixed and re-tested. Not yet owner-verified.** `Main.bas:6859` now reads
`miFile->Add(("&Open Project") & "..." & HK("OpenProject", "Ctrl+Shift+O"), ...)`, matching every
working sibling. Verified by effect: Ctrl+Shift+O opens the **Open Project** dialog, alongside
Ctrl+Shift+N as a control. D1 re-run 12/12.

**Confirmed with a positive control.** `Settings/Others/HotKeys.txt` assigns
`OpenProject=Ctrl+Shift+O`, and Tools ▸ Options ▸ General ▸ Shortcuts displays it, so a user is told
the shortcut exists. Pressing it does nothing at all — no window, no foreground change, after four
seconds. In the same run `Ctrl+Shift+N` opened the New Project dialog, so the test method was
working.

**Cause, one line.** Accelerators in this framework are registered from the menu item's own text:
every other item appends `& HK("Name")`, which puts `\tCtrl+Shift+O` on the caption for
`TranslateAccelerator` to find. `Main.bas:6859` is
`miFile->Add(("&Open Project") & "...", "", "OpenProject", @mClick)` — **no `& HK("OpenProject")`**.
The command itself is fine (`Case "OpenProject": OpenProject` dispatches correctly, and the menu
item works when clicked); only the accelerator is missing. Same family as §13.28: an advertised
shortcut that silently does nothing.

**A static sweep found five more shortcuts with no `HK("name")` anywhere in `src/`** —
`OpenSession` (Ctrl+Alt+O), `SaveSession` (Ctrl+Alt+S), `Close` (Ctrl+F4), `BlockComment`
(Ctrl+Alt+I), `UnComment` (Ctrl+Shift+I). **Do not treat that list as five more defects.**
`UnComment` demonstrably works, so some keys are handled directly by the editor control rather than
through a menu accelerator. The list is a set of candidates to verify by effect, and reporting it
as a verdict would have been wrong about at least one.

### 13.33 Ctrl+Shift+D (External Tools) does not open its dialog — **RESOLVED 2026-07-20** (found by TestPlan E12)

**Status: fixed and re-tested. Not yet owner-verified.** The cause turned out to be **data, not
code**, and the route to it is worth keeping because three plausible theories were wrong first.

**What it was not.** Not a conflict — no other shortcut is bound to Ctrl+Shift+D. Not the §13.19/C4
greyed-parent pattern — the Tools menu is never disabled. Not the editor swallowing the key — it
failed identically with focus in the code editor, the project tree, and the menu bar, while
Ctrl+Shift+N worked from all three.

**What settled it was looking at the menu.** A screenshot of the open Tools menu showed
*Command Prompt* with `Alt+C` beside it and *External Tools…* with **nothing** — so `HK("Tools")`
had returned an empty string and the caption never got its `\t` text. Accelerators are built in
`Menus.bas` (`MainMenu.ParentWindow`) by scanning captions for a tab character, so a caption without
one gets no accelerator at all.

**Root cause: `HotKeys.txt` contained four `Tools=` lines, three of them blank.** `LoadHotKeys` used
`Dictionary.Add` per line and the first entry wins, so the lookup returned `""` from the first blank
rather than `Ctrl+Shift+D` from the fourth. The duplicates exist because the Options dialog writes
one line per menu item keyed on `item->Name`, and **menu item names are not unique** — the
dynamically added user tools (chrome, notepad++) share the Tools name and contribute blank entries.

**Two changes.** `LoadHotKeys` now lets a later **non-empty** value fill in a key that is present but
blank, so a blank duplicate can never shadow a real binding whichever order they appear in. A blank
is still honoured when it is the only entry for a key — that is a deliberately cleared shortcut, and
skipping blanks outright would resurrect shortcuts a user had removed, because `HK()` falls back to
its code default when a key is absent entirely. Separately the three blank duplicates were removed
from the **shipped** `Settings/Others/HotKeys.txt`, which is tracked — meaning Ctrl+Shift+D was dead
on a fresh install too, not just on this machine.

**Verified by effect:** Ctrl+Shift+D now opens the Tools dialog, with Ctrl+Shift+N as a control.
D1 re-run 12/12.

### 13.35 The shortcut file is keyed on a non-unique menu item name (root cause behind §13.33, 2026-07-20)

**Status: FIXED 2026-07-20 at the generator, plus a startup validator. Compiles clean; the validator
is proven against injected faults. The end-to-end Options round-trip is NOT yet owner-verified —
see "What still needs a hand check" below.**

**The original defect.** `frmOptions.frm` wrote one line per menu item keyed on `item->Name`, and
names are not unique across the menu tree. `Main.bas:7231` named *every* dynamically added user tool
`"Tools"` — the same name as the real "External Tools" item — so N configured tools produced N+1
`Tools=` lines, the extras blank, and whichever landed last decided the binding. That is exactly how
§13.33 left `Ctrl+Shift+D` dead.

**Three changes, each closing a different step of the pipeline:**

1. **`Main.bas`** — user tools are now named `UserTool0`, `UserTool1`, … instead of all being
   `"Tools"`. Dispatch is by `mi->Tag` in `mClickTool` and never by name, so the rename is safe.
2. **`frmOptions.frm` `AddShortcuts`** — user tools and unnamed items are no longer listed in the
   Options shortcut editor at all. Their accelerator lives in `Tools.ini`, not `HotKeys.txt`, so an
   edit made there could never have taken effect; the dialog was offering a rebind that silently did
   nothing, which the product standard says should not ship.
3. **`frmOptions.frm` writer** — refuses to emit the same key twice, keeping the first. Belt and
   braces now that (1) and (2) remove the collisions, but the writer is the last place bad data can
   be created, so it no longer can.

**`ValidateHotKeys` (`Main.bas`) — the durable part.** Every shortcut defect found so far has been
bad *data*, not bad dispatch: a missing entry (§13.32), blank duplicates (§13.33), and an
accelerator eating a menu mnemonic (below). All three are decidable by reading the configuration, so
they are now checked at every startup instead of by driving the GUI. It writes
`Temp/_astoria_hotkeys.log` **only when something is wrong**, so the file's existence is the signal.
It never blocks startup and shows the user nothing — a false positive must not stop the IDE. Three
checks:

- **Duplicate keys** in `HotKeys.txt` — the loader tolerates these, but tolerating is not correcting.
- **One combination bound to two commands** — the loser fails silently, the most expensive symptom
  to diagnose by hand.
- **An accelerator shadowing a top-level menu mnemonic** — `TranslateAccelerator` runs before Windows
  resolves `Alt+<letter>` against the menu bar, so the menu just stops opening with nothing visibly
  wrong.

**Verified by effect, and the assertion was made as strong as the claim.** On the real configuration
the validator reported one problem, independently rediscovering the `Alt+C` collision that had been
found by hand-probing the GUI earlier the same day. Because a checker that reports nothing looks
identical to a passing one, the other two checks were then proved against *injected* faults — a
duplicate `Compile=` line and a second command on `Ctrl+F9` — and both fired. `HotKeys.txt` was
restored afterwards and confirmed byte-identical by SHA256.

**What still needs a hand check.** Open Options, change any shortcut, save, and confirm
`HotKeys.txt` contains exactly one `Tools=` line and no blank duplicates. This machine has two
external tools configured (`Tools/Tools.ini`: chrome, notepad++), so it *is* the reproduction case.
This was left to a hand check deliberately: GUI automation here has six recorded instances of
producing confident wrong answers (§13.34 plus two more found on 2026-07-20). If the fix has missed
a path, the validator will now say so in `Temp/_astoria_hotkeys.log` on the next start — the fix and
its detector are independent.

### 13.34 Finish the shortcut sweep (deferred from TestPlan E12, 2026-07-20)

**Status: deferred, harness committed.** 54 shortcuts are assigned in `HotKeys.txt`. The sweep
established 18 working and 2 broken (§13.32, §13.33); the rest are unfinished, in three groups:

1. **Eight results invalidated by harness contamination and needing a re-run** — Copy, Paste, Redo,
   BlockComment, Format, Unformat, CompleteWord, ParameterInfo. After the Cut test emptied the
   document, `Reset-Doc` stopped restoring it (`write_file` does not overwrite a live *dirty*
   editor buffer even with `open=true`), so those tests ran against an empty document. **Fix the
   harness before believing them:** close and reopen the tab rather than rewriting the file. Note
   the Copy+Paste assertion was `after >= before * 1.8`, which with `before = 0` passes
   unconditionally — a false pass that only surfaced because the lengths were printed.
2. **Not yet reached** — FindPrev, the bookmark commands, and Breakpoint. Bookmarks and breakpoints
   draw only a margin marker, so they need the pixel-comparison approach the harness already has.
3. **Nineteen destructive or stateful shortcuts** — Exit, Close, CloseProject, Save*/Open* session,
   Print, CommandPrompt, and the whole debugger/run set. These end or derail a sweep, so each needs
   its own run with the IDE restarted between.

**A fourth trap, and it is not in the harness at all: another application can eat the shortcut
before Astoria ever sees it.** The owner had a background app capturing **Ctrl+Shift+Q, Ctrl+Shift+E,
Ctrl+Shift+A, Ctrl+Shift+Z and Ctrl+Shift+W** system-wide. `Ctrl+Shift+Z` is **Redo**, which this
sweep recorded as FAIL — that result is therefore **void, not a defect**. Nothing in Astoria can
detect or report this: the keystroke never arrives. Before recording any shortcut as broken, check
that nothing else on the machine has claimed it.

**A fifth trap, and the worst of them: synthesized `Ctrl+Z` does not reproduce what a hand does.**
Driven by `SendInput`, Ctrl+Z never undid anything in the code editor across four runs — while
`Ctrl+A` worked in the same session, same focus, same input path, which appeared to prove the key
was arriving and Undo was broken. **It is not: the owner confirmed by hand that Ctrl+Z undoes
normally in the editor.** One run also showed the document *gaining* two characters after Ctrl+Z,
which was never explained. Cause unknown; do not trust synthesized Undo/Redo here. **Every
Undo and Redo result in this sweep is therefore void**, including pass 1's "Undo — TEXT", whose
+1-character delta was an edit being added rather than removed and should have been caught at the
time. Undo and Redo need testing by hand, or by a method proven against a hand-verified case first.

**Redo's status as of 2026-07-20: UNRESOLVED — do not record it either way.** The owner disabled
the capturing app's shortcuts and Ctrl+Shift+Z still does not redo, but the hook may not be released
until a reboot, so it is still unknown whether Astoria's Redo works. Re-test after a reboot with
`Ctrl+Z` (Undo, verified working) in the same run as a control: if Undo fires and Redo does not from
the same state, that is a genuine Astoria defect rather than interference.

**Three harness traps, each of which produced confident wrong answers before being caught.** They
are commented in the scripts, and they generalise to any UI test here:

- *Focus before, reset after.* `write_file` reloads the document and drops editor focus, so
  focusing and then resetting sends keystrokes into a pane that is no longer listening. The first
  run reported four working shortcuts as dead, including Ctrl+I.
- *A leftover modal disables everything after it.* The F2 test opens a "Definitions for…" window
  which **Escape does not close** (§13.28 again), and with it up the main window is disabled, so
  every later keystroke silently goes nowhere. One run produced fifteen confident FAILs this way.
- *The IDE may not be where you left it.* After a restart it restores the saved workspace; if that
  is a `.frm`, it opens in form view and clicks land on the designer surface, not a code editor.
  The harness now opens its own project explicitly.

**The instrument check is what makes the results trustworthy**, and it is not optional: each test
types a character and confirms it reaches the editor before running. When the environment was wrong
it reported `NO-INSTRUMENT` and stopped, rather than emitting a page of failures — which is exactly
what it did on two of the three traps above.

**And a caution the instrument check does not cover.** It proves a *character* reaches the editor.
It does not prove a given *shortcut* behaves as it does under a real hand — the Ctrl+Z trap above
passed the instrument check every time and was still wrong. A negative result for any shortcut
whose effect the harness cannot see directly should be confirmed by hand before it is recorded.

### 13.36 Designer: Cut a control, then Undo does not restore it (owner-observed 2026-07-20)

**Status: open, owner-observed by hand.** In the form designer, `Ctrl+X` deletes the selected
control and `Ctrl+Z` does not bring it back. **Undo itself is fine** — the owner confirmed Ctrl+Z
undoes normally in the code editor — so this is specific to the designer route.

**Why this contradicts what is already written down, and is worth resolving carefully.** TestPlan C4
is recorded as passing, and `AstoriaIDE.bas:151` carries a considered explanation of why the
designer needs no undo history of its own: every designer change is said to be in the code editor's
undo stack already, because `DesignerModified` brackets each one with `EditControl.Changing`/
`Changed`, which is what creates an `EditControlHistory` entry — so `Undo` in the designer is
routed to `tb->txtCode.Undo` and one history is meant to serve both views. Either `CutControl` does
not go through `DesignerModified`'s bracketing the way the other designer operations do, or the
entry is created but the surface is not rebuilt from the restored text. Worth checking `Cut`
specifically against an operation known to undo correctly (an align or a move), rather than
assuming the whole designer route is broken.

**Do not test this with synthesized input.** Ctrl+Z through `SendInput` does not behave as it does
under a hand — see §13.34. This one was found by hand and needs to be confirmed the same way.

### 13.28 pt 3 — bisection progress (2026-07-20, later)

**Twelve hypotheses were already ruled out. Six more were eliminated cheaply in this session; the
cause is still not identified.** New eliminations, each verified by effect:

- **No visible chrome is responsible.** A gated bisect built into `src/Main.bas` (behind
  `ASTORIA_BISECT`, temporary scaffolding to be removed once the defect is solved) skipped, in one
  build, each of: toolbars, status bar, left panel, right panel, bottom panel — separately and all
  together. The defect reproduces identically in every configuration, including the "all off" case
  where `frmMain` has almost nothing on it. Six of six configurations reproduce; the seventh
  (baseline) was inconclusive from a cold-startup Alt+F miss and does not weigh either way.
- **Menu icons are not responsible.** Skipping `ApplyMenuIcons` — no icons on any menu item, no
  `DisplayIcons`, no chance of an owner-drawn item interacting oddly with mnemonic search — leaves
  the defect intact.
- **`RegisterHotKey` is not used anywhere** in `src/` or `Controls/Framework/mff/`. Would have
  swallowed the key silently and fit the signature perfectly; it does not exist here.
- **The framework does not do control-mnemonic matching.** No `WM_SYSCHAR` handler in
  `Controls/Framework/mff/*.bas` competes with the default menu-mnemonic path.
- **Hypothesis 7 (the accelerator table) is now REFUTED for real.** `MffMnemonicTest.bas` previously
  put Ctrl+C/G/R on a **context menu**, which does not populate `FActiveForm->Accelerator`. It has
  been rebuilt with those items on the **main menu**, matching Astoria's actual configuration for
  the accelerator search a keystroke goes through — and Alt+C/G/R still all work in it. If the
  accelerator table were the mechanism, this would have failed.

**Fifth harness trap, again: the x64 `INPUT` struct is 40 bytes, not 32.** Omitting `MOUSEINPUT`
from the union gives 32 bytes because it becomes the size of the `KEYBDINPUT` alone rather than of
the largest union member. `SendInput` then fails with `ERROR_INVALID_PARAMETER (87)` and sends
*nothing at all* — every letter reads as "no menu". Already documented in the harness README,
walked into again anyway, and caught in one run only because the `Alt+F` positive control failed
alongside `Alt+C/G/R`. The revised `menuprobe.ps1` asserts `Marshal.SizeOf(INP) == 40` at startup so
this cannot silently recur.

**Instruments left behind for the next investigator.**

- `TestHarness/13.28_Mnemonics/menuprobe.ps1` (in scratchpad; move to `TestHarness/` when kept):
  positive-control-gated Alt+letter probe, with the struct assertion. Reports "no menu" per letter
  and refuses to declare a run valid until Alt+F opens.
- `ASTORIA_BISECT` env var in `Main.bas` / `Main.bi`: comma-list of subsystems to skip
  (`toolbars`, `statusbar`, `leftpanel`, `rightpanel`, `bottompanel`, `menuicons`). Empty or unset =
  normal startup, so nothing ships changed for anyone else. Add more gates as needed;
  `BisectSkip("part")` reads the env var once and caches.
- `MffMnemonicTest.bas` now truly parallels Astoria's main-menu accelerator configuration and still
  works, so it remains the useful control.

**What has not been tried and is worth continuing with.**

- **Bisect the menu itself, not the chrome around it.** Add a gate that builds a minimal 5-item
  menu (File / Code / Run / Git / Tools) instead of the full 11 — matches MffMnemonicTest exactly.
  If the defect disappears, something in the extra 6 items causes it (the odd `Code/Form` at
  index 4, the disabled `&Form` at index 5, or the sheer count) and can be narrowed further.
- **The message pump.** `Application.bas:407` calls `TranslateAccelerator` before `TranslateMessage`.
  `MffMnemonicTest` runs the same pump, but the accelerator table it hands over is different (its
  main menu holds Ctrl+C/G/R too, and Alt+C works there). Worth logging what
  `TranslateAccelerator` returns for each `Alt+<letter>` on `WM_SYSCHAR` in the real IDE, to see
  whether it is silently consuming the message.
- **Worker threads.** MffMnemonicTest is single-threaded; Astoria runs the agent pipe on a worker.
  A worker calling into GUI code (or holding a lock a GUI call needs) is a long shot, but easy to
  test with an `ASTORIA_BISECT=agentpipe` gate.

**Cost so far.** One synthesized-input trap earned back once; six eliminations; the bisect
scaffolding and the improved test app are reusable regardless of which direction the next attempt
takes.
