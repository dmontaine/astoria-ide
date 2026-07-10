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
- **2.1.2 Remove dead/comment-cruft and empty handlers:** sweep for commented-out code blocks, dead `Declare` forwards with no implementation, empty no-op event handlers. Clean `src/Temp.bas` (238 KB of designer-generated scratch). Gate: compile clean + grep for removed identifiers.
- **2.1.3 Audit and fix magic numbers:** hunt for unnamed numeric literals standing in for counts/sizes/flags. Known example: `SettingsService.bas` `NoMoreIndexedSettingsKeys` `Return keySum = -9` (already fixed, but the pattern repeats). Gate: compile clean + spot-check constant values.

#### Phase 2 — Codebase readability (moderate risk, file-by-file)

- **2.2.1 Standardize variable naming conventions:** pick one convention and apply uniformly. Rename file-by-file (not cross-file), avoids breaking `Alias`/`Export`/`Declare` bindings. Gate: `CompileDebug.bat` after each file.
- **2.2.2 DRY pass — extract repeated code within files:** identify duplicated logic patterns within single files and extract into `Private Function`/`Sub`. Gate: compile after each extraction.
- **2.2.3 Split oversized files by logical domain:** `TabWindow.bas` (Editor/Designer/Debug/Project/Build), `Main.bas` (panels/settings/toolbars/project tree), `EditControl.bas` (highlighting/folding/intellisense). Gate: compile after each split, verify `Export`/`Alias` bindings.

#### Phase 3 — Architecture improvements (high value, high risk)

- **2.3.1 Development/Final compile-mode toggle:** replace 6 Project Properties controls with one "Development"/"Final" radio pair. Both use `-gen gcc`. Gate: compile clean + compile a test project in both modes.
- **2.3.2 UI/settings sweep — remove orphaned controls:** audit `frmOptions.frm`, `frmProjectProperties.frm` for GTK/Linux controls, alt-compiler radios, alt-debugger references, orphaned theme pickers whose underlying code was deleted in Tier 2.75.3. Gate: compile clean + visual verification.
- **2.3.3 Extract shared framework utilities:** move common patterns into shared modules. Candidates: INI key migration, GDB command construction, panel-size clamping, DPI scaling helpers. Gate: compile after each extraction.

#### Phase 4 — Legacy tech debt (lowest priority)

- **2.4.1 Final audit for remaining GTK/Linux/32-bit artifacts:** verify nothing new was introduced since Tier 2.75.3. Gate: `grep -rn "GTK\|__USE_GTK__\|__FB_LINUX__\|32bit\|i686" src/ mff/` returns zero (except intentional `CheckCondition()` in `TabWindow.bas`).
- **2.4.2 Clean `src/makefile` and `src/THREADING.md`:** remove GTK references. Gate: docs-only, compile not affected.

#### Recommended execution order

```
2.1.1 → 2.1.3 → 2.1.2   (mechanical, safe, quick wins)
2.2.1 → 2.3.2            (variable naming + UI sweep — user-facing)
2.3.1                     (compile toggle — immediate user value)
2.2.2 → 2.2.3            (DRY + file splits — the real structural work, highest risk)
2.3.3 → 2.4.1 → 2.4.2   (final cleanup)

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

### 13.4 Rename the project (e.g. "ABStudio" — Astoria Basic Studio)

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

### 13.6 Full review and expansion of Examples/ (added 2026-07-03)

**Sequencing:** owner-specified — do this in a **testing/fine-tuning or documentation phase**, after the core work (Tier 3 compiler swap, §13.2 structural pass) is done, not now. Noted here so it isn't forgotten, not to be picked up immediately.

**Why this is on the list:** the 2026-07-03 GTK/Linux/Win32-only audit (§3b) went through all 33 `Examples/` folders and found the premise (remove GTK/Linux/Win32-only examples) didn't hold, but surfaced real gaps along the way: several examples had no `.vfp` project file at all, two had genuine API-drift bugs from being written against an older `mff` version (one fixed — `Graphics/CanvasDraw.bas`, §3b — one still open — `WellCOM Example/WellCOM.bas`'s `DllMain` conflict), and this was only found because someone happened to try compiling them. That's a sign `Examples/` hasn't had a systematic pass in a while.

**Scope for that future pass:**
- Re-verify every example still compiles clean against the *then-current* `mff` API (will have moved again after §13.2's structural pass) — same direct-`fbc64`-compile verification technique used in §3b/§4, not just visual inspection.
- Finish the `WellCOM Example` `DllMain` fix left open in §3b.
- Consider whether new examples are worth adding — the target audience (§1) benefits from seeing approachable, appealing demos (graphics/drawing examples in particular resonate with returning Basic programmers per the discussion that led to this item); a documentation/polish phase is a natural time to ask "what's missing" rather than only "what's broken."
- Natural pairing with §13.5 (installer) — examples get bundled with the installer, so this pass and that one should probably be sequenced together or at least cross-checked.

### 13.7 Enhance AI integration in the IDE (added 2026-07-03)

**Secondary audience note that motivated this:** beyond the core §1 audience (returning Basic programmers, desktop hobbyists, students), the owner observed that some business users might be drawn to VFBE for a different reason — a robust, no-nonsense IDE focused on getting work done, with strong AI integration, rather than for BASIC nostalgia specifically. This doesn't change the §1 audience-driven minimalism principle (still don't add configuration surface just because a power-user audience might want it) — it's specifically about the AI feature area being worth investing in further, since a good AI-integrated workflow is something both audiences would value.

**Starting point:** the AI system (`src/AIService.bas`, ~810 lines) already supports multiple providers (OpenAI, DeepSeek, Claude, Mistral, Ollama, OpenRouter) with streaming and context management — per the 2026-07-03 complexity audit, this is reasonably-scoped code, not bloated. The AI Agent also just had a real bug fixed this session (§4 note elsewhere in this doc / see the `_WIN32_WINNT`-adjacent fix list): `VisualFBEditor IDE Environment.md`, a 2,874-line reference of every IDE menu/feature, was silently failing to load into AI context due to a wrong path in `Main.bas` — now fixed, so the AI Agent should have meaningfully richer IDE-awareness going forward than it did before this session.

**Not yet scoped** — no specific feature list decided. Candidate areas to consider when this is picked up: deeper codebase-aware context (not just the static IDE-environment reference now correctly loading, but live awareness of the user's actual open project); AI-assisted debugging or error-message explanation; inline code suggestions beyond the existing `Suggestions` tab. Should be scoped deliberately when picked up rather than growing organically — same anti-scope-creep discipline as the rest of §13.

### 13.8 Design-workspace status bar (deferred 2026-07-04 — "nice to have, not critical")

Owner spec, captured verbatim for whenever this is picked up: a status bar docked to the bottom of the Form Designer's visual workspace (`TabWindow.pnlForm`), full width of that panel specifically (not the whole tab — must track `pnlForm`'s width as the Code/Form splitter moves), three cells:
1. Name of the form being edited.
2. Name of the control currently being edited/selected.
3. Layer info — "none" when the selection isn't inside a `PagePanel`, otherwise "Layer N of Total" plus two left/right buttons (only enabled in layer mode) to move between layers, reusing the `Designer.MovePanelLayer` added this session.

Cells 1 and 2 should update live as the user renames the form or the selected control via the property grid.

**Why deferred, not just "todo":** researched 2026-07-04 and confirmed genuinely non-trivial — `pnlForm` itself docks normally via the framework's Align system, but the *design control* (the form being edited) inside it is positioned via raw HWND math independent of that docking (its `ParentHandle` is set directly, sized to match the form's own declared bounds, scaled for DPI) — specifically in `pnlForm_Message`'s `WM_SIZE` handler (scrollbar-range math against `Des->GetControlBounds(...)` vs. `pnl->ClientWidth`/`ClientHeight`, `TabWindow.bas` ~10227-10286) and `Designer.HookDialogProc`'s `WM_NCCALCSIZE` case (`Designer.bas` ~2253-2261, which already reserves space at the *top* for the form's own menu bar via `TopMenuHeight` — the model to mirror for a *bottom* reservation). This is the exact same layout-engine territory as the docking-engine bug that's already this project's most expensive-to-debug area (see the recurring "sound design, unfinished last mile" pattern noted throughout §8) — worth doing carefully in a dedicated session, not squeezed in alongside other work.

There's no native "embed a control inside a status bar panel" API in `mff/StatusBar.bi` (`StatusPanel` reserves width/caption only) — the existing global status bar (`pstBar`, `Main.bas` ~5206-5223) works around this by parenting a plain control (a progress bar, in that case) over a reserved panel's x-offset manually; the same trick would be needed for cells 3's left/right layer buttons.

For the live-update wiring: every property-grid commit (including "Name") funnels through `Sub PropertyChanged` (`TabWindow.bas` ~2555-2667), which already special-cases `PropertyName = "Name"` (~2588-2596) to call `TabWindow.ChangeName` — that's the one choke point to hook for keeping cells 1/2 in sync, regardless of whether the edit came from the property grid's cell editor, its textbox, or its combo.

### 13.9 Blank Designer page on cold-open until a control is selected (deferred 2026-07-04 — "nice to have, not critical")

See §8's panel/layer navigation write-up for full context. A `PagePanel` page (e.g. `frmOptions.frm`'s "General" page) shows blank the moment the file is opened, even though `SelectedPanelIndex`/`Visible` are (as of this session's fixes) correctly set — it only renders once a control inside that page is actually selected. Added `Controls[i]->RequestAlign` to `PagePanel.SelectedPanelIndex`'s real setter (the architecturally-obvious fix — force a layout pass the moment a page becomes visible) but confirmed via testing this wasn't sufficient; the real trigger that makes it render (selecting a control *inside* the page) does something beyond what `RequestAlign` alone captures. Owner explicitly deprioritized further chasing this — all of the actual navigation (tree, right-click menu, Ctrl+PageUp/PageDown) works correctly the moment any selection has happened, so this is purely a cold-open-frame cosmetic issue, not a functional blocker. Next session starting here should re-open with fresh eyes on what specifically differs between "becoming visible via `SelectedPanelIndex`'s setter" and "becoming visible via selecting a control inside it" (`Designer.MoveDots`/`DesignerChangeSelection` are the obvious next things to diff against `RequestAlign`).

### 13.10 Dark mode: owner-drawn popup menus + input-field polish (deferred 2026-07-04)

Dark mode is stable and near-complete (see §4), but popup/dropdown menus remain light. Windows provides **no documented API** for dark Win32 popup menus — the choices are the undocumented uxtheme-ordinal route (rejected on principle for this fork) or fully owner-drawn menu items. The framework already has the opt-in switch (`Menus.bas` `Menu.Style` property → `TraverseItems` flips every item to `MFT_OWNERDRAW`, `Menus.bi:205`) and the item data is already threaded through (`MENUITEMINFO.dwItemData` carries the `MenuItem Ptr`, `Menus.bas:120`), but the actual renderer is missing: `WM_DRAWITEM ODT_MENU` in `Control.bas:1257-1260` (and `Form.bas:990-992`) is an empty stub with only a commented-out `ImageList_Draw`. Do NOT just enable `Menu.Style` — menus render blank without the drawer.

Scope when picked up: implement `WM_MEASUREITEM`/`WM_DRAWITEM` for `ODT_MENU` — item text, right-aligned accelerator text (caption already stores the accelerator after a tab), icons (`FImage`/`ImagesList`), checkmarks/radio marks, separators, submenu arrows, disabled/hot states — using the existing dark palette (`hbrBkgndMenu`/`darkBkColorMenu` in `Brush.bi/bas` were created for exactly this and are currently unused). Test exhaustively: menus are the most-used surface in the IDE. Optionally in the same pass: darken input-field faces (search `TextBox`, `ComboBoxEdit`/`ComboBoxEx` edit areas) beyond what the `DarkMode_CFD` theme provides, via `WM_CTLCOLOREDIT`-style handling.

### 13.11 Dark mode: dark dialog/modal backgrounds (nice to have, not essential)

Modal dialogs and secondary forms (Find/Replace, About, GoTo, etc.) currently render with a white background in dark mode. The `WM_ERASEBKGND` handler in `Control.bas:862-868` does not fill with a dark brush — the dark fill only happens in `WM_PAINT`, leaving a white flash or persistent white background when `WM_ERASEBKGND` fires without a subsequent `WM_PAINT`. A naive dark-fill in `WM_ERASEBKGND` was attempted and reverted (2026-07-04) because it caused white borders around owner-drawn popup menus — indicating `WM_ERASEBKGND` is sent to multiple window classes including menu windows, and a blanket fill would need to be scoped more carefully (e.g. only for form/dialog class names, not the `#32768` menu class). Additionally, the `WM_CTLCOLORBTN`/`WM_CTLCOLORSTATIC` handler at `Control.bas:925-987` applies dark colors but is gated on `FDefaultBackColor = FBackColor` — any control with an explicit `BackColor` set will not go dark, which may affect some dialog controls. Investigation scope when picked up: gate the `WM_ERASEBKGND` dark fill on the window class (exclude menu windows), and audit dialog `.frm` files for controls with non-default `BackColor`.

---
