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

### 13.17 Rename refactoring for controls in the designer (found by TestPlan C3, 2026-07-18)

Renaming a control in the property grid updates the four places that describe the **control** — its
`Dim`, its comment, its `With` block and its `.Name` — but nothing that **references** it. The
event handler keeps its old name, and any code referring to the old control variable is left
untouched, so the project stops building:

```
Error: Variable not declared, Label1 in 'Label1.Text = "Hello, " & TextBox1.Text'
```

**Not silent, and not data loss** — the error names the file, the line and the identifier, and a
user fixes it in seconds. That is why this is an enhancement rather than a 1.0 bug fix. But on a
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
