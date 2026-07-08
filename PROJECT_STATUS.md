# VFBE Win64 Fork — Project Status & Handoff

**Last updated:** 2026-07-07 (Opus "Next Steps" backlog Phase A + B + C + D(partial) done & committed: robustness fixes, AI thread responsiveness, off-thread `Suggestions`/narrowed `FormatProject` disable, calmer debugger messages, owner-decided fresh-install starter project, Options-dialog jargon cleanup, feedback-channel policy + two silent-failure fixes; 13.3.A S1–S7 **all Opus-reviewed & committed**; owner-found Run-toolbar persistence regression fixed; Edit menu owner-approved; Search → Define F2 reliability pass; File/Open Project + path fixes)  
**Repository:** [codeberg.org/bigriverguy/VFBEWin64](https://codeberg.org/bigriverguy/VFBEWin64)  
**Local path:** `C:\Users\dmont\VisualFBEditor`  
**Owner:** bigriverguy (`dmontaine@gmail.com`)

This document captures project history, completed work, open items, and workflow rules for continuing development without re-discovering context.

---

## Current State (2026-07-06)

**The IDE compiles clean (0 errors, 0 warnings), runs stable, and is under active UX polish.**

| Area | Status |
|------|--------|
| **Core IDE** | Win64-only, compiles clean, self-hosted with bundled compiler (FBC 1.10.1) and GDB debugger |
| **Form Designer** | Working — grey-panel bug root-caused and fixed (2026-07-06); per-form control tree + PagePanel layer navigation shipped |
| **Dark mode** | Stable and enabled — title bar, menus, toolbars, tabs, central area all render dark; popup menus deferred (§13.10) |
| **Dead code** | GTK/Linux/32-bit code physically deleted across `src/` and `mff/`; Integrated (stabs) debugger + alt-compiler backends removed; only `-gen gcc` remains |
| **UI review** | In progress — **File** menu owner-approved (incl. Open Project); **Edit** menu owner-approved (all 25 items); **Search** → Define (F2) reliability improved (committed with S1–S4); **13.3.A S1–S7 all Opus-reviewed and committed** (see §13.3.A execution below); **View menu** is the next step-by-step target |
| **Panels** | Left/right/bottom panel pin/collapse/persistence all fixed and verified |
| **Debugger** | GDB-only; Step, Continue, Break, Step Out, command queue, and debug-tab show/hide all working; 3 GDB items pending owner smoke test (§7) |
| **Build** | `Compile.bat` for release, `CompileDebug.bat` for debug; `NOPAUSE=1` for agent runs |

**Active work:** Opus's "Next Steps" review (`Next Steps - Opus.md`, 2026-07-07) evaluated three prior AI reviews against the actual source and produced a verified, sequenced backlog. **Phase A + P1 + Phase B (P2/P3) + Phase C (U1/U2/partial U3-U4) + Phase D (F1, F2) + Phase E item E1 are done and committed** (see below); **R5 (bounded GDB read) deliberately deferred**, see Phase D notes. 13.3.A S1–S7 are **all committed** (Opus-reviewed). A Run-toolbar persistence regression the owner found post-S4 (my own S3 migration latching Run permanently visible) was root-caused and fixed 2026-07-07 — see the S5–S7 review outcome below. Next: the rest of Phase E (owner decisions: AI catalog size, plaintext keys, Android/ADB cleanup), the remaining Phase C static-event-handler/`.lng`-maintenance decisions, R5 (needs a dedicated live-GDB session), or resume §13.3 step-by-step UI review with the **View menu** (File + Edit complete; Search → Define reliability pass shipped with S1–S4).  
**Open items consolidated:** see [Open Items](#open-items) below.

---

## Opus "Next Steps" backlog — Phase A + P1 + Phase B + Phase C + Phase D(partial) done (2026-07-07)

Executes Phase A, item 5 (P1), Phase B (P2/P3), Phase C (U1/U2, partial U3-U4), and Phase D (F1, F2) of `Next Steps - Opus.md`'s consolidated, source-verified backlog (Opus cross-checked three prior AI reviews — Cursor, Deepseek, Sonnet — against the actual code before sequencing this plan; see that document for full methodology and the discarded/unsubstantiated claims).

| ID | Fix | Location | Verified |
|----|-----|----------|----------|
| **R1** | `LoadFunctions` bare `Return`s skipped `MutexUnlock tlockSave` under an allocation-failure path — real (if rare, OOM-gated) whole-IDE deadlock. Added `MutexUnlock tlockSave` before both early returns. | `src/Main.bas:3175-3181` | Compile-clean + launch check |
| **R2** | `SaveProject`'s two `Open ... For Output` calls ignored the result — a missing/read-only project folder silently no-op'd the save. Both now check the result and show a plain MsgBox + return `False` on failure. | `src/Main.bas:1637, 1652` | Compile-clean + launch check |
| **R4** | `PipeCmd`'s `CreateProcess` result was discarded, so a failed launch still called `WaitForSingleObject`/`CloseHandle` on invalid handles. Now checked before use, matching the pattern already used in `Debug.bas`'s debuggee launch. | `src/TabWindow.bas:10902-10908` | Compile-clean + launch check |
| **R3** | `AIResetContext` ("New Chat") could restart the AI thread while a previous request was still in flight — a race over shared globals (`AIBodyWStringPtr` etc. deallocated mid-use). Gated the Sub on `bInAIThread`, mirroring the guard `txtAIRequest_Activate` (the send path) already uses. | `src/AIService.bas:783-787` | Compile-clean + launch check |
| **P1** | `AIRelease` and `AIResetContext` both called `Sleep(500)`/`Sleep(300)` on the **main UI thread** while waiting for the aborted AI request thread to unwind — a visible stutter on every Stop/New-Chat click. Moved each tail (the delay + the state reset / thread restart) into a small helper Sub run on its own worker thread (`AIReleaseFinish`, `AIResetContextFinish`), so the UI thread returns immediately. Same effective delay, no main-thread block. | `src/AIService.bas:758-781` | Compile-clean + launch check |
| **P2** | `Suggestions`'s first-run project-content preload called `LoadFunctions` synchronously per file on the calling (UI) thread — could stall the UI for the duration of reading every project file. Replaced the inline call with `ThreadCounter(ThreadCreate_(@LoadOnlyFilePathOverwriteWithContent, ecc))`, the same background-worker wrapper already used for this exact `LoadFunctions` mode elsewhere (`Main.bas`'s `AddFolder`/project-open path). `LoadFunctionsCount`'s existing "IntelliSense is not fully loaded yet" messaging (already downstream in the same Sub) now covers the async case for free. | `src/TabWindow.bas:8169-8174` | Compile-clean + launch check |
| **P3** | `FormatProject` (already background-threaded, per `THREADING.md`) disabled the **entire main form** (`pfrmMain->Enabled = False`) for the whole project-wide format/unformat pass, blocking every menu, panel, and toolbar rather than just the two things it actually mutates (open-tab content and the project tree). Traced what the Sub touches — it walks live `TreeNode`s under the project root and directly edits any open tab's `txtCode` for project files — and narrowed the disable to just `ptabCode` (tab strip/editors) and `ptvExplorer` (project tree), the exact resources at risk of a concurrent edit. Other panels (AI Agent, Output/Problems, menus not tied to editing) stay usable during a format pass. | `src/TabWindow.bas:157-203` | Compile-clean + launch check |
| **U1** | Three Debug.bas user-facing messages rewritten in plain, calm language, and the raw "gdb" name replaced with "the debugger": the "gdb not found" and "source file not executable" errors, the `hard_closing` crash dialog ("Sorry an unrecoverable problem occurs... Report to dev please" → "The debugger ran into a problem and had to stop."), and the Stop-debuggee confirm (dropped the all-caps "USE CARREFULLY SYSTEM CAN BECOME UNSTABLE, LOSS OF DATA, MEMORY LEAK" for a calm one-liner about unsaved data). | `src/Debug.bas:1646, 1658, 2369-2373, 2377-2380` | Compile-clean + launch check |
| **U2** | Fresh-install startup landed on a completely empty IDE. Traced the actual cause: `WhenVisualFBEditorStarts` has no Options UI to set it (stays 0 forever) and `LoadWorkspace()` no-ops silently when `Settings/Workspace.ini` doesn't exist yet — the "commented-out" framing in the prior AI reviews was imprecise, but the empty-IDE symptom was real. **Owner decision (2026-07-07):** keep reopening the last project when one exists; open a starter project only when there's nothing to reopen. Implemented by checking `LoadWorkspace()`'s own return value (already `True`/`False` for "did anything actually load") and falling back to the same `AddNew` starter-template call the (unreachable) `WhenVisualFBEditorStarts` branch already used. | `src/Main.bas:9242-9249` | Compile-clean + launch check (fresh-install path not exercised live — needs owner test with `Workspace.ini` removed) |
| **U3/U4 (partial)** | Wording-only pass (no behavior/default changes): "Use Direct2D (For Windows)" → "Smoother text rendering (Direct2D)"; "Auto create resource and manifest files (.rc, .xml)" → "Automatically create the icon and manifest files needed to build"; "Update all language file (*.lng)" → "Update all language files"; casing fix "Intellisense limit" → "IntelliSense limit". **Deliberately not touched** (each already flagged as needing owner input, in this document or `Next Steps - Opus.md`): the "static event handler" checkbox cluster (changes Designer codegen), and whether the `.lng` maintainer tooling should be hidden from the general Options UI (depends on the still-open "are `.lng` files actively maintained for this fork" question). Also left `AutoComplete` vs `AutoSuggestions` naming alone — traced them to genuinely different features (inline completion dropdown vs. project-wide analysis), so merging their labels risked hiding a real distinction rather than just cleaning up drift. | `src/frmOptions.frm:803, 533, 2028, 1936` | Compile-clean + launch check |
| **F1** | Wrote down the feedback-channel policy Opus asked for (status bar = transient state; Output/Problems = background events, non-intrusive; `MsgBox` = irreversible/blocking only) as a new guiding principle, to apply opportunistically rather than as a big-bang sweep. See "Guiding principle: feedback-channel policy" above. | `PROJECT_STATUS.md` (this doc) | N/A (doc only) |
| **F2** | Two previously-silent failure paths now give a visible reason, per the new F1 policy. (1) `TabWindow.FormDesign`'s 50,000-line Designer cutoff exited with zero feedback — now sets a status-bar caption before bailing. (2) `LoadFunctions`'s missing-include case (all 4 `Open` attempts fail) fell through silently, leaving that header's symbols permanently absent from IntelliSense with no clue why — now logs to the Output panel (`ShowMessages(..., False)`, no tab-switch) *without* spamming: traced `GetRelativePath` first and confirmed it already searches the source file's folder, `ExePath`, every control library's include folder, the bundled compiler's own `inc/` folder, and any configured include paths before giving up — so this only fires on a genuinely unresolvable include (typo/deleted file), not on ordinary system headers. | `src/TabWindow.bas:8374-8378`, `src/Main.bas:3208-3214` | Compile-clean + launch check |
| **R5 (deferred)** | GDB's `readpipe` (`Debug.bas:461`) blocks on a plain synchronous `ReadFile` with no timeout — confirmed real, worker-thread-scoped (not full-IDE). **Deliberately not attempted this session:** commented-out code immediately below the current implementation shows a previous `PeekNamedPipe`-polling attempt that was abandoned in favor of the current blocking read, suggesting real fragility here; per this project's own GDB-debugging precedent (see "GDB live debugging beats offset-guessing" workflow), a change to the core pipe-read loop needs a reproducible live hang to verify against, which wasn't available this session. Reworking this blind risked breaking all debugging to fix a narrower-scope hang. Needs its own dedicated, carefully-verified session. | `src/Debug.bas:447-499` | Not attempted — traced and deferred |
| **E1** | `frmOptions.cmdApply_Click` wrote all ~296 INI keys (`piniSettings`/`piniTheme`) unconditionally on every Apply click — 96 distinct `WriteXxx` call sites, several inside loops (AI agents, terminals, other editors, help paths, include/library paths) and a large theme-colors block, none checking whether the value actually changed. Traced `IniFile.WriteXxx` (`Controls/MyFbFramework/mff/IniFile.bas`) and confirmed every write triggers a full-file disk rewrite (`Update` → `SaveToFile`) regardless of whether anything changed — so this was ~296 unconditional disk writes per Apply click, now down to just the keys that actually differ. Added 4 small dirty-check helpers (`IniValueChangedBool/Int/Float/Str`, `src/frmOptions.frm` just above `cmdApply_Click`) that compare the new value against what's already in the INI (`KeyExists`/`ReadXxx`, both in-memory lookups — no disk I/O) before allowing a write; every `WriteXxx` call site in the Sub is now wrapped `If IniValueChanged...(...) Then ... End If`. Generated mechanically (a one-off Python transform, not hand-typed) so all 295 sites got identical, verified treatment; sampled AI-agent-loop, IIf-laden theme-color, and hex-flag `WriteInteger` sites by hand to confirm correctness. **Gotcha found and fixed:** inlining the guard logic at each site (rather than via shared helpers) ballooned `cmdApply_Click`'s generated C function to ~8000 lines and crashed the `gcc` backend at `-O2` with zero diagnostic output — factoring the repeated KeyExists+Read+compare logic into the 4 shared helpers fixed it. | `src/frmOptions.frm:3284` (helpers just above), Sub body to `:3905` (pre-edit line numbers) | Compile-clean (verified via a temporary copy into the working main checkout, since this worktree session's `Compile.bat` was silently failing at the `gcc` step for unrelated environment reasons — see note below); **not launch-tested this session** (no GUI/computer-use access) |

**Verification performed:** compile-clean after each fix (0 errors; same 4 pre-existing `frmFindInFiles.frm` warnings throughout) + release-build launch/process-alive check after each. **Not verified this session** (no GUI/computer-use access): live click-through of Save-failure messaging, AI Stop/New Chat under an in-flight request, Suggestions on a large project, Format Project's narrowed disable, the three reworded Debug.bas messages, the fresh-install starter-project path, the reworded Options-dialog text, the FormDesign 50k-line status message, and the missing-include Output message — same gap noted throughout recent sessions; needs owner or a computer-use-capable session. **E1 specifically:** this worktree's `Compile.bat` failed silently at the `gcc` step (exit 1, zero output) even on an untouched baseline checkout of the same worktree, while the separate main checkout at `C:\Users\dmont\VisualFBEditor` compiled the identical baseline cleanly — ruled out the code change as the cause (baseline reproduced the same failure), tried a retry after a pause, and a byte-for-byte copy of the worktree to a plain path (all failed identically). Verified compile-clean by temporarily swapping the modified `frmOptions.frm` into the main checkout, compiling there (0 errors, clean), then restoring the main checkout's `frmOptions.frm` and rebuilt `VisualFBEditor64.exe` from git exactly as they were. Owner should re-run `Compile.bat` in a fresh worktree/session to confirm this isn't a recurring issue.

**Remaining Opus backlog** (not started, see `Next Steps - Opus.md` for full detail): rest of Phase C (static-event-handler default, `.lng` maintenance decision), R5 (needs a dedicated live-GDB session — see above), rest of Phase E (owner decisions: AI catalog size, plaintext keys, Android/ADB cleanup — E1's unconditional Options-Apply write is now done, see table above), Phase F (deferred structural: file splits, `FormDesign` debounce — deliberately last, touches the fragile designer path).

---

## 13.3.A execution — S1–S4 done (Sonnet 2026-07-06), Opus-reviewed & committed (2026-07-07)

Executes the Opus-designed plan in [ROADMAP.md §13.3.A](ROADMAP.md#1333a-approachability-pass--full-plan-designed-2026-07-06-opus-session). **Committed to `main` 2026-07-07 after Opus O4 review (see "O4 review outcome" below).**

### O4 review outcome (Opus, 2026-07-07)

Reviewed the full S1–S4 diff against the plan, focusing on the two areas the plan flagged as compile-clean-hides-a-break (§9 dormant-reference wiring; toolbar/band/INI mechanics). **No correctness bugs found.** Verified: all 5-band indices agree across `frmMain_Create`, the `mClick` toggle cases, and the ReBar add order; the `Bands.Count - 2` Maximize bound preserves "all but Format"; every `mi*`/`mnu*`/`tbt*` enable-state pointer is reassigned in the new structure; `git grep` for all removed symbols returns zero stale references; the `tbtToggleBreakpoint` double-assign fix and `tbtShowNextStatement` target are correct; toolbar captions sit in the correct `FCaption` positional arg (arg 6) with `tbsAutosize`; the frmTools insertion fix is sound (Tools menu has two separators bracketing the tool list, `-`+`Options` always last two children); and both Window-menu count translations (`>3`→`>1`, `>2`→`>0`) are faithful (subtract the 2 removed static items).

**One plan-mandated gap found and fixed before commit:** S3's ROADMAP gotcha required migrating the retired `ShowBuildToolbar`/`ShowDebugToolbar` INI keys into `ShowRunToolbar` ("if either was true, Run visible"); Sonnet's S3 did the default changes but not the migration, so a pre-13.3.A user who had hidden the old Run toolbar while keeping Build visible would have lost all toolbar access to Build/Stop/debug (menus still worked). Fixed in `frmMain_Create` (`Main.bas` ~9029): `ShowRunToolBar = ReadBool("ShowRunToolbar", True) OrElse ReadBool("ShowBuildToolbar", False) OrElse ReadBool("ShowDebugToolbar", False)` — only ever turns Run on, retired keys read once and never re-written. Compiled clean (0 errors; same 4 pre-existing `frmFindInFiles.frm` warnings). Toolbar text captions (Run/Build/Stop) confirmed rendering in a live owner screenshot.

**Owner follow-ups (non-blocking, carried forward):** (1) Help ▸ GitHub kept VFBE-repo + VFBE-wiki; plan text said VFBE-repo + FreeBASIC-wiki — owner to confirm. (2) Still needs owner eyes: does "Show Main Toolbar" reclaim editor space, and does Project Properties ▸ General lay out OK with the `*nix` icon field gone. See Deferred list below for the rest.

### S1 — Menu structure (all menus)

Reorganized every menu per the O1/O2 taxonomy: File (Advanced submenu for Print Preview/Page Setup), Edit (Advanced submenu for Unformat/Format Project/Add Spaces/Merge Blank Lines), View (merged Collapse+Uncollapse into one **Fold** submenu; split **Other Windows** into user windows vs. a new **Debug Windows** submenu; folded Window's Split Horizontally/Vertically into View, leaving Window holding only its open-document list), Project (Advanced submenu for Add User Control/Resource File/Manifest File), Tools (Command Prompt promoted to top-level, Add-Ins/External Tools moved to Advanced), Help (GitHub submenu trimmed to VisualFBEditor repo+wiki, rest moved to Advanced — **ambiguous spec wording, flagged for confirmation**, see Issues below). Biggest piece: **Build + Debug + Run menus merged into one Run menu** with **More Build Options** / **More Debug Options** submenus, preserving every `ChangeMenuItemsEnabled`/`ChangeEnabledDebug` pointer so enable-state wiring kept working across the move.

### S2 — Relabeling

Search: "Define" → "Go to Definition". Run menu: Start With Compile→**Run**, Compile→**Build**, End→**Stop**, Start→**Run Without Building**, Compile All→**Rebuild All**, Make Clean→**Clean**. Only `ML()` caption text changed — every dispatch `Key` string and hotkey stayed the same, so `HotKeys.txt` customizations and localization data aren't orphaned by a rename (deferred concern below).

### S3 — Toolbar consolidation

Build+Debug+Run toolbars merged into one Run toolbar (ReBar: 7 bands → 5: Standard, Edit, Project, Run, Format). Added visible **text-beside-icon captions** to the primaries (Run, Build, Stop, Save, Open) — `TBSTYLE_LIST` was already enabled on every toolbar but no button had ever passed a caption, so the capability was live but unused. Set **minimal defaults: Standard + Run visible, Edit/Project/Format hidden** — verified this only changes behavior for fresh installs (`ReadBool(key, default)` only applies the new default when the INI key is absent; existing users' saved toolbar visibility is untouched).

### S4 — Dead field removal

Removed the "Icon Resource File (For \*nix/\*bsd)" label + combobox from Project Properties ▸ General (`frmProjectProperties.frm`/`.bi`) — dead cross-platform UI in a Win64-only fork. Deliberately **kept** the underlying `ppe->IconResourceFileName` field, since it's auto-populated whenever a `.xpm` file is added to a project and used elsewhere (`Main.bas`/`TabWindow.bas`) for file-rename tracking — unrelated to the removed picker. Preserved the `.xpm` branch in `AddToCombo`/`AddToComboFileName` as an intentional no-op (matching the existing `.bat`/`makefile` pattern) so `.xpm` files don't fall through and get miscategorized as "Main File" now that their combobox is gone.

### Issues found and fixed along the way

1. **Startup crash (introduced by S3, caught before reporting complete):** `frmMain_Create` had a hardcoded `For i = 0 To 5 : MainReBar.Bands.Item(i)->Maximize : Next`, assuming the old 7-band layout (loop deliberately excluded the last band, Format). Once S3 dropped the ReBar to 5 bands, `Bands.Item(5)` returned null and `->Maximize` on it caused a `SIGSEGV` — app terminated right after the splash screen. Found via `CompileDebug.bat` + the bundled GDB in batch mode (exact backtrace on the first try: `ReBarBand.Maximize` with `THIS=0x0`, from `Main.bas:9073`). Fixed by computing the bound from `MainReBar.Bands.Count - 2` instead of a literal, so it can't silently go stale again. Re-verified via GDB (20s observation, zero signals) and a real release-build launch (8s alive check, correct window title).
2. **Pre-existing bug found and fixed (unrelated to my changes, hit while rewriting the same code):** the old toolbar code assigned `tbtToggleBreakpoint` twice — once for the real Toggle Breakpoint button, then again (copy-paste) for the Show Next Statement button, silently losing the real button's pointer. `ChangeEnabledDebug`'s `tbtToggleBreakpoint->Enabled = True` was therefore managing the wrong button. Fixed using `tbtShowNextStatement`, which was already declared but never used — clearly the original intent.
3. **Regression I introduced and caught before it shipped:** moving "External Tools..." into Tools ▸ Advanced broke `frmTools.frm`'s save handler, which located where to re-insert saved custom tools by finding that item as a direct sibling (`mi->Name = "Tools"`). Since it's no longer a direct child of the Tools menu, the lookup would have silently placed newly-saved tools at the wrong position. Fixed by computing the insertion point from the stable trailing separator+Options pair instead of a Name-based lookup.
4. **Two hardcoded gaps fixed while already touching this code (not part of the original ask, but directly adjacent and zero-risk):** `ShowFormatToolBar` was never being persisted to INI (only read) — added the missing `WriteBool`. `ChangeMenuItemsEnabled`/`Main.bas`'s Window-menu item-count checks (`miWindow->Count > 3`, `> 2`, loop starting at index 3) assumed 3 static Window-menu items (Split H/V/separator); now that Split H/V moved to View, Window holds only the separator, so these were updated to `> 1`/`> 0`/loop-from-1 to match.

### Deferred (flagged, not guessed at)

- **Comment/Block Comment/Uncomment → "Toggle Comment" merge** (owner-approved in the plan) — real behavior change (detecting current comment state to decide comment-vs-uncomment), and `CommentSingle`/`CommentBlock`/`UnComment`'s internals weren't verified well enough to merge safely blind.
- **Moving Bubble Help/Suggest Options/Parameter Info from Edit into the Options dialog**, and **moving Recent AI Chat from File into the AI Agent panel** — both cross into UI subsystems (`frmOptions.frm`, the AI Agent panel) not reviewed as part of this pass; scoped out rather than guessed at.
- **Designer menu disable-when-no-form-open** (O1's "only refinement" for the Designer menu) — would touch `tabCode_SelChange`, an area with a documented fragility history (this is the same code path implicated in the form-designer grey-panel bug earlier this session).
- **GitHub submenu's "VFBE repo + FB Wiki" reduction** — the ROADMAP spec's wording is ambiguous about which exact 2 items should remain. Kept VisualFBEditor's own repo+wiki as the safest reading (the only unambiguous "repo + its own wiki" pairing available); cheap to adjust if that's not what was meant.
- **Localization (`.lng`) files** — `ML()` keys on the exact English source string (`Settings/Languages/*.lng`, 15+ languages shipped, inherited from upstream). Renaming a caption (S2) breaks that language's translation lookup for the renamed string until its `.lng` file gets a matching new entry — not something a mechanical relabel pass can safely do across 15 languages. English (the default/base language) is entirely unaffected. Flagged for the owner to decide whether these language files are still meant to be actively maintained for this fork.

### Verification performed

- Compile: 0 errors at every phase gate (after S1, after S2, after S3, after S3's crash fix, after S4) — same 4 pre-existing warnings throughout (`frmFindInFiles.frm`, from Cursor's uncommitted Search-menu work, not introduced by this pass).
- Grepped `src/` after every symbol move/removal for stale references (the §9 "clean compile is not sufficient" rule) — caught issues #1 and #3 above this way, both before they were reported as done.
- Release build: fresh launch + process-alive check after the crash fix and again after S4 — window opens, correct title, stays running.

### Not verified (no GUI/computer-use access this session)

- Visual click-through of every moved menu item in each run-state (stopped/running/paused) — the gate explicitly calls for this and it needs a human or a computer-use-capable session.
- Whether "Show Main Toolbar" (Options ▸ General) actually reclaims the editor's vertical space when toggled off — traced the code (it does call `pfrmMain->RequestAlign`) but couldn't visually confirm; this project has a documented history of "last-mile" docking-space gaps (see the bottom-panel fix history below).
- Project Properties dialog's visual layout after S4's field removal — nothing sat directly below/adjacent to the removed controls in a way that looked wrong from reading the code, but there's now an unclosed blank rectangle where they were (every control on that page uses absolute `SetBounds`, nothing reflows).

---

## 13.3.A execution — S5–S7 done (Sonnet 2026-07-07), Opus-reviewed & committed (2026-07-07)

Continues from the S1–S4 commit (`0eaa880`). Committed after Opus O4 review (see "O4 review outcome (S5–S7)" below).

### O4 review outcome (S5–S7) + owner-found regression (Opus, 2026-07-07)

Reviewed the full S5–S7 diff and two runtime issues the owner found while exercising the S1–S4 build.

**Owner issue #1 — toolbar visibility choices didn't persist (Run toolbar).** Root cause was **my own S3 INI-migration line, not S5–S7.** The migration OR-ed the retired `ShowBuildToolbar`/`ShowDebugToolbar` keys into `ShowRunToolBar` on *every* load; since S1–S4 stopped writing those keys but never removed them, `ShowBuildToolbar=true` stayed frozen in the INI and permanently latched Run visible — "hide the Run toolbar" could never survive a restart. The INI is case-insensitive (`IniFile.KeyExists` compares `UCase`) and `WriteBool` flushes immediately, so Standard/Edit/Project/Format were never affected — only Run. **Fixed** (`Main.bas` ~9056): retired keys are now consulted *only as the default* for `ReadBool("ShowRunToolbar", …)` (so a saved value always wins — `ReadBool` ignores its default when the key exists), making the carry-forward genuinely one-time; then `KeyRemove` deletes the two retired keys so they can't re-latch or linger (satisfies the §9 "migrate retired keys, don't orphan" rule the original migration violated). Compiles clean. **Needs owner re-test** (toggle needs the GUI): hide Run → close via window X → relaunch → should stay hidden, and `ShowBuildToolBar` should be gone from `Settings/VisualFBEditor64.ini`.

**Owner issue #2 — most toolbar buttons have no beside-icon text.** Working as designed, not a bug: O3 deliberately labels only the 5 primaries (Run/Build/Stop/Open/Save) to keep one short bar; the other ~33 buttons are icon-only *with* hover tooltips (all wired). **Owner decision (2026-07-07): keep the 5 primaries as-is** — no change.

**S5–S7 verdict: no correctness bugs.**
- **S5** — `DeleteEditorFile` memory-safety verified against `CloseTab`: that Sub frees `tn` only when `ptvExplorer->Nodes.IndexOf(tn) <> -1` (a direct root child), and root children always have `ParentNode = 0`, so "CloseTab frees tn" ⟹ `bNestedInProject = False` ⟹ the post-close re-touch is skipped in exactly the freeing case. No use-after-free. **One functional follow-up (not a blocker), see Open Items:** deleting a *project-member* file removes the tree node + disk file but doesn't mark the project dirty / update the `.vfp` the way `RemoveFileFromProject` does, so the deleted file may still be listed in the `.vfp` until the next save.
- **S6** — clean; compiler confirms zero dangling references to the removed controls, and Sonnet correctly *deferred* Terminal + Other Editors after tracing them to live functionality (the plan's "candidate for removal" wording was wrong for both). Env-vars/encoding/compiler-paths removals were all genuinely dead.
- **S7** — correctly a no-op; targets already removed by commit `6b3200a`.

**Working tree at review time (before commit):** `src/Main.bas` (S5 + Run-migration fix), `src/frmOptions.frm`, `src/frmOptions.bi` (S6), plus `PROJECT_STATUS.md`.

### S5 — Delete Project/Delete File confirm + regroup

`DeleteProject` already had a proper Yes/No `MsgBox` confirm (pre-existing, not new). `DeleteEditorFile` (`Main.bas`) was a **complete no-op stub** — just a `' TODO: delete file from disk and project explorer` comment, no confirm, no deletion, despite being wired to a live "Delete File" menu item. Since the S5 ask ("add a confirm dialog") assumes something to confirm, and a confirm dialog wrapping a no-op would be actively misleading (user clicks Yes, nothing happens), implemented it for real:

- Mirrors `DeleteProject`'s confirm pattern (`MsgBox` Yes/No, `mtWarning`).
- Closes the active tab via the existing `CloseTab(tb, True)` (`WithoutMessage=True` — matches `DeleteProject`'s own choice to suppress the redundant "save before closing?" prompt, since the user already confirmed permanent deletion).
- Detaches the file's tree node from its project parent, then deletes the file from disk (`Kill`), guarded by `Dir(...)<>""` so an already-missing file doesn't crash.
- **Memory-safety subtlety traced before writing this:** `TreeNodeCollection.Remove` (`mff/TreeView.bas:395-398`) calls `_Delete` on the node — it frees it, doesn't just detach it. `CloseTab`'s own internal cleanup (`TabWindow.bas:1042-1051`) already does this for root-level/"Opened" (loose, non-project) file nodes, meaning `tn` can already be a dangling pointer by the time `CloseTab` returns for that case. Nested project-member nodes are left untouched by `CloseTab` (that's "Close File"'s normal, correct behavior — it shouldn't strip a file from the project tree). So `DeleteEditorFile` captures `tn->ParentNode <> 0` **before** calling `CloseTab`, and only re-touches `tn` afterward when it was nested (never for the root-level case, where it may already be freed).
- Regrouped both `Delete Project` and `Delete File` out of their old positions (previously each sat with zero separator directly below its own Close item) into their own bracketed group near the bottom of the File menu, right before the Advanced submenu/Exit — well away from Close Project/Close File.

Compiled clean; grepped for stale `miDeleteProject`/`miDeleteFile`/`DeleteEditorFile` references — all consistent (enable-state wiring in `TabWindow.bas` and the `mClick` dispatch are position-independent, unaffected by the reorder).

### S6 — Options dialog (O4) edits

**Executed, all confirmed dead/vestigial before removal — nothing here changes any currently-reachable behavior:**

- **Default Compiler → read-only info line.** Removed `cboCompiler64` (was already `.Visible = False`, had zero Load/Save wiring anywhere in the form). The existing `lblCompiler64`/`lblCompiler64Path` label pair ("Compiler 64-bit: ./Compiler/fbc64.exe") already *is* the read-only info line the plan asked for.
- **Compiler Paths removed.** `grbCompilerPaths`/`lvCompilerPaths` was already `.Visible = False`; its Add/Remove/Change button row (`hbxCompilers`) was empty (no buttons ever added to it) and its `ItemActivate` handler was an empty stub. Its own Save routine already unconditionally purged the "Compilers" INI section on every save (not just cleaned stale entries — nuked the section outright), so the feature was already fully inert. Traced `Project->CompilerPath` (the per-project field `BuildService.bas` actually consults for the fbc path) end-to-end: no UI anywhere sets it (not `frmProjectProperties.frm`, not this list) — it can only ever be non-empty via hand-edited `.vfp` files. Removing the dead registration UI doesn't touch `Project->CompilerPath` or `BuildService.bas`'s bundled-compiler fallback at all.
- **"Turn on Environment Variables" removed.** Confirmed non-functional by tracing the debuggee launch path: `Debug.bas`'s `CreateProcess` call passes `0` for `lpEnvironment` (line 436) — the debuggee always inherits the parent's environment unchanged. `TurnOnEnvironmentVariables`/`EnvironmentVariables` were read from INI, editable in Options, written back to INI — and never consulted anywhere else. Removed the checkbox+textbox; **left the backing globals and their INI load/save alone** (same precedent as S4 keeping `IconResourceFileName` — harmless orphaned state, trivial to fully purge later if wanted).
- **Code Editor ▸ Defaults encoding/line-ending pickers removed.** `hbxDefaultFileFormat`/`hbxDefaultNewLineFormat` (and their `cboDefaultFileFormat`/`cboDefaultNewLineFormat` combos) were already `.Visible = False`, never populated with a single `AddItem`, and never read from/written to any global or INI key anywhere in the form. Confirmed `ChangeFileEncoding`/`ChangeNewLineType` (`Main.bas`) already ignore their passed-in parameter entirely and unconditionally show "UTF-8"/"CR+LF" on the status bar — matching the plan's premise that `AddTab` forces UTF-8+CRLF for every file.

**Deferred (flagged, not guessed at) — both turned out to be real, working features, contradicting the plan's tentative wording:**

- **Debugger ▸ Terminal sub-page** — plan said "Remove; pick a sensible default terminal." Traced `TerminalPath`/`CurrentTerminal` and found them **genuinely consumed** at `TabWindow.bas:12042-12054`: when set, the compiled program launches inside the user's chosen terminal emulator instead of the default console. This is live, working, user-configurable functionality, not dead code — removing it is a deliberate feature reduction the plan explicitly wants, but doing it safely means also verifying the empty/default fallback path stays correct and re-touching an "Add/Change/Remove Terminal" browse-dialog flow, which is more surgery than could be done carefully in the remaining scope of this session. Left entirely untouched.
- **Code Editor ▸ Other Editors** — plan said "candidate for removal." Traced `pOtherEditors` and found it **genuinely consumed** in `Main.bas` (`NodeActivate`/`OpenTreeNodeOnSingleClick`, ~lines 6629-6684): double-clicking a file whose extension is registered launches the configured external editor instead of opening it in VFBE. Real, useful feature — the plan's "candidate for removal" phrasing turns out to be wrong once verified. Left entirely untouched.
- **Designer ▸ "Create non-static event handlers"** — not touched at all. This checkbox gates the `Enabled` state of three other checkboxes (`chkPlaceStaticEventHandlersAfterTheConstructor`, `chkCreateStaticEventHandlersWithAnUnderscoreAtTheBeginning`, `chkCreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt`) and affects the Designer's actual **generated event-handler code** for every control a user adds going forward. Picking the wrong default here could silently change codegen behavior project-wide. This is a real design decision about FreeBASIC event-handler generation conventions, not mechanical cleanup — needs owner input on what the sensible default actually is, same bar as S1's Comment-merge deferral.

### S7 — Docs GTK cleanup

**Already resolved — nothing to do.** `src/makefile` doesn't exist in the repo at all (confirmed via `find`/`Glob`), and `src/THREADING.md` has zero GTK references (confirmed via grep). Both must have been cleaned up in an earlier session (likely Batch 2.75.3) without the Open Items entry being removed. Cleared the stale entry from Open Items below. The only remaining "gtk" hits in `src/` are `src/BUILD.md`'s accurate "Linux, GTK, and 32-bit IDE builds are not supported in this fork" (correct, current documentation, not a stale reference) and two string-literal filters in `TabWindow.bas` (`"gtkwidget"`, excluding a legacy field name from a property-grid listing — functional code, not a doc reference, out of scope for a docs pass).

### Verification performed

- Compile: 0 errors after S5, after S6's four removals — same 4 pre-existing `frmFindInFiles.frm` warnings throughout.
- Grepped `src/frmOptions.frm`/`frmOptions.bi` for every removed symbol after S6 — zero stale references (only my own explanatory comments mention the old names).
- Grepped to confirm the three deferred/untouched features (`TurnOnEnvironmentVariables`/`EnvironmentVariables` globals, `pTerminals`/`CurrentTerminal`/`TerminalPath` in `TabWindow.bas`, `pOtherEditors` in `Main.bas`) are byte-for-byte unaffected by the S6 edits.
- Release build: fresh launch + process-alive check after all S5+S6 changes (6s observation) — window opens, stays running.

### Not verified (no GUI/computer-use access this session)

- Visual layout of the Options dialog's Compiler/Debugger/Code-Editor pages after S6's removals — the removed controls were already invisible or (for Compiler Paths) filled remaining client space via `DockStyle.alClient`, so removing them shouldn't visibly change anything, but this needs a human or computer-use session to actually confirm the pages still lay out correctly (no leftover blank gaps, no other control unexpectedly reflowing into the freed space).
- Delete File end-to-end: confirm dialog appearance, actual disk deletion, and tree-node detachment for both a root-level ("Opened"/loose) file and a nested project-member file — traced carefully against `CloseTab`'s and `TreeNodeCollection.Remove`'s exact behavior, but not exercised interactively.
- Delete Project/Delete File's new menu position — visual confirmation that the regrouping reads clearly in the running File menu.

---

## RESOLVED — Form designer grey-panel bug

**Status:** FIXED (2026-07-06). Full root-cause analysis, fix details, and original investigation record archived in [HISTORY.md](HISTORY.md).

---

## File menu — Open Project (owner-approved, 2026-07-06)

Part of the File menu step-by-step review. **Open Project** (`frmOpenProject`) was expanded: browse-for-`.vfp`, Examples tree, and MRU-style discovery with **PathUtils** fixes (`GetFileName` for extensionless folder names, `FindProjectVfpInFolder`, slash normalization) so Examples such as MDINotepad resolve correctly.

---

## Edit menu review & Suggestions lockup (2026-07-06)

### Edit menu audit

All 25 Edit menu entries were traced to their handlers. Every entry dispatches to a live implementation — no stale references, no dead code, no removed-feature stubs.

### Three path-evaluation bugs found and fixed

| # | Bug | Root cause | Fix |
|---|-----|-----------|-----|
| 1 | `GetControlLibraryVfpPath` returning "" for absolute paths | Mixed-slash search | Normalize to forward slashes before scan |
| 2 | Slash naming confusion (`Slash`/`BackSlash` reversed) | Names opposite to values | Renamed `WindowsSlash`/`UnixSlash` (20 files) |
| 3 | `GetFileName` dropping last character of extensionless names | Length formula assumed `.` always present | Guard on extension existence |

Bug #3 was the root cause of MDINotepad not appearing in the Examples list — `GetFileName("MDINotepad", False)` returned "MDINotepa", so `<dirname>.vfp` was never found.

### Suggestions lockup — fixed (2026-07-06)

**Symptom:** Edit → Suggestions froze the IDE. Root cause: menu handler called `Sub Suggestions` in `TabWindow.bas`, which loaded every project file synchronously on the main thread and ran `AnalyzeTab`.

**Wrong fix (Deepseek, reverted):** Background thread + toggle on the same menu key. Caused file-not-found on close (relative project paths) and broken checkmark toggle.

**Edit menu (flat):** **Code - Bubble Help**, **Code - Suggest Options**, and **Code - Parameter Info** are direct items under Edit (no Code submenu). Bubble Help toggles `GlobalSettings.ShowSymbolsTooltipsOnMouseHover`; Suggest Options toggles `AutoComplete`; Parameter Info toggles `ParameterInfoShow`.

**Fix (2026-07-06):** Flattened Edit menu (removed `miEditCode` submenu) so checkable toggles route through `WM_COMMAND` → `mClick` like **Use Debugger**. Submenu nesting caused checkmark-only toggles without updating globals. `ChangeShowSymbolsTooltipsOnMouseHover` closes open hover tooltips when disabled.

**Correct behavior (user-confirmed):** Edit → **Code - Bubble Help** toggles **bubble help** (`GlobalSettings.ShowSymbolsTooltipsOnMouseHover`) on/off — same setting as Options → IntelliSense → “Show Symbols Tooltips On Mouse Hover”. It does **not** run project-wide analysis.

**Edit → Suggest Options** (renamed from Complete Word menu item) toggles **auto-complete** (`AutoComplete` / Options → “Enable Auto Complete”) — enables/disables the intellisense dropdown while typing. **Ctrl+Space** and the toolbar Complete Word button still invoke `CompleteWord` manually.

**Edit → Code - Parameter Info** toggles **parameter hints** (`ParameterInfoShow` / `Options/ParameterInfoShow`) — enables/disables automatic parameter tooltips while typing `(`, `,`, `?`, etc. **Ctrl+J** (with Ctrl held) and the toolbar Parameter Info button still invoke `ParameterInfo` manually when enabled. Menu click without Ctrl toggles the setting.

**Implementation:**
- `ChangeShowSymbolsTooltipsOnMouseHover` in `Main.bas` (mirrors `ChangeUseDebugger`): updates global, syncs `miSuggestions->Checked`, persists INI, closes active hover tooltips when off.
- `ChangeAutoComplete` in `Main.bas` (same pattern): updates `AutoComplete`, syncs `miCompleteWord->Checked`, persists `Options/AutoComplete` to INI.
- `ChangeParameterInfoShow` in `Main.bas` (same pattern): updates `ParameterInfoShow`, syncs Parameter Info menu checkmark, persists `Options/ParameterInfoShow` to INI.
- Flat Edit items: `ML("Code - Bubble Help")` command `"Suggestions"`; `ML("Code - Suggest Options")` command `"SuggestOptions"`; both checkable, empty image key.
- Menu `Case "Suggestions"` toggles bubble help; menu `Case "SuggestOptions"` toggles auto-complete; toolbar `tbtSuggestions` uses key `AnalyzeSuggestions` → still calls `Sub Suggestions` for project analysis; toolbar/hotkey `CompleteWord` still calls `CompleteWord`.
- `frmOptions` Apply syncs both menu checkmarks when options change from the dialog.

**Note:** Toolbar Suggestions button still runs synchronous project analysis (may block on large projects); only the Edit menu item is the bubble-help toggle.

### Files modified this session

- `src/PathUtils.bas` — `GetFileName` fix, `FindProjectVfpInFolder` fallback fix, `CanonicalWinPath` comment
- `src/Main.bi` — `WindowsSlash`/`UnixSlash` defines, `SanitizeMRUListsOnLoad` declare, `ChangeShowSymbolsTooltipsOnMouseHover` declare
- `src/Main.bas` — `ChangeShowSymbolsTooltipsOnMouseHover`, checkable `miSuggestions`, toolbar key split, startup sync
- `src/VisualFBEditor.bas` — menu vs toolbar handler split
- `src/frmOptions.frm` — sync menu checkmark on Apply
- `src/TabWindow.bi` — slash rename
- 17 other `src/` files — slash rename only
- `Controls/MyFbFramework/mff/UString.bi`, `SysUtils.bi`, `Sys.bas` — `#ifndef UNICODE` guards

---

**Edit menu review status:** Complete — owner-approved all items (2026-07-06); flat menu checkmark toggles and handler routing verified; compile-clean.

**Parameter Info gating:** `ParameterInfoShow` is now user-togglable (was effectively always on); `ChangeParameterInfoShow` in `Main.bas` mirrors the Use Debugger / Bubble Help checkmark pattern.

---

## Search menu — Define (F2) reliability (2026-07-06)

Part of the §13.3 step-by-step UI review. **Search menu is not yet owner-approved**; this pass targets **Search → Define** (F2 / `TabWindow.Define`) only. Remaining Search items (Find, Find In Files, Replace, etc.) are pending review.

### Reliability issues identified and fixed

| # | Issue | Symptom | Fix |
|---|-------|---------|-----|
| 1 | Stale symbol tables | F2 after edits found nothing or wrong targets | When `TextChanged`, call `FormDesign(True)` and clear flag before lookup so symbol tables match the editor |
| 2 | Silent failure | No feedback when lookup failed or cursor had no word | Status bar panel 0: `No word at cursor`; `No definition found for 'Foo'` |
| 3 | String/comment false positives | F2 inside strings or comments could match spurious symbols | Silent skip using the same string/comment guard as `CompleteWord` |
| 4 | Missing `#define` / `#macro` | Preprocessor symbols not in lookup | Search `Content.Defines` and project-wide `pGlobalDefines` |
| 5 | Same-line self-match | F2 on a definition line skipped *all* same-line matches | `DefineOverlapsCaretWord` — StartChar-aware overlap check; skip only the definition under the caret, not every symbol on the line |
| 6 | Procedure scoping typo | Type-member Define missed when scoped via `cboFunction` | `te` → `te1` for procedure `OwnerTypeName` / `Elements` walk |
| 7 | Ambiguous multiple matches | `frmTrek` title gave no match count | Title: `Definitions for 'word' (N)` |

### Implementation

- **`DefineOverlapsCaretWord`** — private helper in `TabWindow.bas`; returns true when a symbol's `[StartChar, StartChar+Len(Name))` overlaps the caret word bounds.
- **`TabWindow.Define`** — symbol refresh, string/comment guard, define/macro lists, caret-aware same-line skip, status-bar messages, `frmTrek` title with count.

### Files modified (uncommitted)

- `src/TabWindow.bas` — `Define`, `DefineOverlapsCaretWord`

### Search menu review status

**In progress** — Define (F2) reliability pass complete (uncommitted); remaining Search menu entries pending owner review.

*(Form designer grey-panel investigation continues below for historical reference; see RESOLVED section above.)*

### Actual root cause (verified by live file-logging, not the earlier Bugbot hypothesis)

The grey panel had **nothing** to do with duplicate `FormDesign`, the workspace-defer logic, or the `RefreshDesignSurface` reparent — all were ruled out by tracing every `FormDesign` caller and exit. The real chain, established by logging inside `FormDesign` → `Designer.CreateControl` → `Designer.Symbols`:

1. `Designer.CreateControl("Form", …)` returned 0, so `FormDesign` bailed at `If .DesignControl = 0 Then Exit Sub` → empty `pnlForm` = grey (the "flash" is the Designer canvas appearing before the control-create fails).
2. `CreateControl` returned 0 because `Designer.Symbols("Form")` returned 0.
3. `Symbols` returned 0 because it called `DyLibLoad` on the MyFbFramework `Library.Path`, which was the **folder** `Controls\MyFbFramework` (no `mff64.dll`) — even though the DLL was already loaded (valid `Handle`). `DyLibLoad` on a directory returns 0.

The `"Form"` component's `Comps` entry binds its `Tag` to an MFF `Library` object whose `Path` is the raw `.vfp` component string `Controls/MyFbFramework` (a folder), **distinct** from the toolbox library that carries the real DLL path. So MFF ends up with multiple `Library` objects with inconsistent path representations, and `Comps["Form"].Tag` points at the folder-path one.

### Fixes shipped

1. **`src/Designer.bas` `Designer.Symbols`** — when `DyLibLoad(Path)` fails but the library has a live `Handle`, recover the real on-disk DLL path via `GetModuleFileNameW(Handle)` and `DyLibLoad` **that**. This both works around the folder-`Path` and keeps the module refcount balanced. (A first attempt that simply borrowed `CtlLib->Handle` without a matching `DyLibLoad` made the *first* designer work but under-flowed the refcount — the Designer destructor's `DyLibFree(st->Handle)` at `Designer.bas` ~2905 then unloaded `mff64.dll` after the first project closed, breaking every subsequent project. The `GetModuleFileNameW` + `DyLibLoad` form is the correct, refcount-safe fix.)
2. **`src/PathUtils.bas` `GetControlLibraryVfpPath`** — normalize to forward slashes before the `"/controls/"` scan. It previously ran `WinOsPath` (backslashes) then searched for a forward-slash substring, returning `""` for every absolute library path. That broke the project-open "already loaded" match (`bFinded` stayed false), causing duplicate library objects.

Also in this session: the `ClearUndo → OnLineChangeEdit → FormDesign` teardown chain from the old Bugbot writeup is **already dead** — the `WithoutShow=True` change to `ClearUndo` (`EditControl.bas`) stops `ClearUndo` from raising `OnLineChange` at all, so the `mAddingTab` guard debate was chasing a path that can no longer fire.

### Still open (non-fatal, deferred)

The underlying wart — MFF getting **multiple `Library` objects with inconsistent `Path` representations** (absolute-backslash DLL path from the toolbox loader vs. relative-forward-slash folder path from the `.vfp` component string), with `Comps["Form"].Tag` binding to the folder one — was not fully cleaned up. The two fixes make it harmless (the module is loaded and now resolves correctly), but the refactored library-loading path (`LoadToolBox` INI/dir-scan branches + `AddProject`'s `ControlLibrary` block + `GetControlLibraryVfpPath`/`GetControlLibraryFolder`) deserves a consolidation pass so one DLL maps to exactly one `Library` object with one canonical path. Low priority; captured here for a future session. **Queued for Cursor in §8 ("Queued for Cursor").**

### Original bug summary (historical investigation record below)

### Bug summary

Opening a `.frm` file: code editor loads and works; design surface **briefly flashes** (form HWND visible) then settles to an **empty grey `pnlForm`**. Behavior worked in the original download; broke during recent workspace/defer/LoadToolBox work. The **LoadToolBox HWND fix** enabled the brief flash (design control gets a valid parent HWND), but a **second `FormDesign` call tears down** the design surface that the first call built.

### Symptom timeline

1. **Original download** — `.frm` opens; code + design surface both work.
2. **After recent changes** — `.frm` would not open at all (HWND/parent issues).
3. **After expert fixes** — file opens; code editor OK; design surface **flash then grey `pnlForm`**.

### Root cause (Bugbot finding)

`AddTab` calls `.FormDesign` (line ~510), then later `.txtCode.ClearUndo` (line ~519). `ClearUndo` → `ChangeText` → `OnLineChangeEdit` with `TextChanged=True` → **`tb->FormDesign(...)`** at line ~3242. That **re-enters `TabWindow.FormDesign`** while `Des->DesignControl` already exists, hitting the teardown block at **lines 8407–8438** (`UnHook`, remove child controls, `DeleteComponentFunc`, clear `Objects`/`Components`/`Controls`). Guards for `mApplyingWorkspaceLoad`, `mApplyingDeferredFormDesign`, `mApplyingFormTabView`, and `mAddingTab` in `OnLineChangeEdit` (~3097) **did not fix** the issue per user — likely because `mAddingTab` is cleared at line ~544 **before** `ClearUndo` side-effects propagate, or `TextChanged` is set again on the `OnLineChange` path.

**Key call chain (AddTab open path):**
```
AddTab → .FormDesign (builds design surface)
       → .txtCode.ClearUndo → ChangeText → OnLineChangeEdit
       → tb->FormDesign (TEARDOWN when Des already set)
       → ApplyFormTabView → RefreshDesignSurface (HWND reparent, but surface already gutted)
```

**`TabWindow.FormDesign` teardown zone:** `src/TabWindow.bas` lines **8364–8455** (teardown at **8407–8438** when `Des->DesignControl` exists).

### Files modified (uncommitted — from `git status` / `git diff --stat`)

**Core bug surface (413 lines changed in these 6 files):**

| File | Diff |
|------|------|
| `src/Main.bas` | +365/- (workspace defer, `RunDeferredFormDesign`, `LoadToolBox`, `tabCode_SelChange` guards) |
| `src/TabWindow.bas` | +155/- (`AddTab`, `ApplyFormTabView`, `RefreshDesignSurface`, `OnLineChangeEdit` guards, `FormNeedDesign`) |
| `src/Main.bi` | +14/- (`mApplying*`, `mAddingTab`, `RunDeferredFormDesign` declare) |
| `src/TabWindow.bi` | +3/- |
| `src/Designer.bas` | +90/- |
| `src/EditControl.bas` | +2/- |

**Other modified (32 files total, 1484 insertions / 1376 deletions):**

- `src/PathUtils.bas`, `src/PathUtils.bi`, `src/SettingsService.bas`, `src/VisualFBEditor.bas`
- `src/frmComponents.frm`, `src/frmNewFile.{bi,frm}`, `src/frmOpenProject.{bi,frm}`, `src/frmOptions.frm`, `src/frmProjectProperties.frm`, `src/frmRecentProjects.frm`, `src/frmTemplates.frm`
- `Settings/VisualFBEditor64.ini`, `Settings/Others/HotKeys.txt`
- Binaries: `VisualFBEditor64.exe`, `Controls/MyFbFramework/mff64.dll`
- Example temps, deleted `Projects/*`, `Templates/Files/Form_3D.frm`

**Untracked (not in diff):** `src/frmOpenProjectFile.{bi,frm}`, `src/VisualFBEditor.vfp`, `Settings/Workspace.ini`, `Project/`, example temps/exes.

### Fixes attempted

- **LoadToolBox HWND fix** (`Main.bas` ~4801) — ensures `pApp->MainForm = @frmMain` before toolbox load; design HWND gets valid parent → **flash visible** (partial win).
- **`mApplyingWorkspaceLoad`** — skip immediate `FormDesign` in `AddTab` during `LoadWorkspace`; set `FormNeedDesign=True`; defer via `RunDeferredFormDesign()` after workspace load (`Main.bas` ~9122–9125).
- **`RunDeferredFormDesign`** (`Main.bas` ~4778) — batch deferred design for tabs with `FormNeedDesign`; calls `FormDesign` + `ApplyFormTabView`; ends with `tabCode_SelChange`.
- **`FormNeedDesign` flag** — defer design to `tbrTop_ButtonClick` Form/CodeAndForm paths (`TabWindow.bas` ~508, ~10100–10117).
- **`RefreshDesignSurface`** (`TabWindow.bas` ~313) — `SetParent` design HWND to `pnlForm`, `Des->Dialog`, repaint.
- **`ApplyFormTabView`** refactor (`TabWindow.bas` ~331) — centralize form-tab view setup; `mApplyingFormTabView` guard.
- **`mApplyingDeferredFormDesign` / `mApplyingFormTabView` guards** in `tabCode_SelChange` (`Main.bas` ~8098) — skip toolbar click during deferred apply.
- **`mAddingTab` + re-entrancy guards** in `OnLineChangeEdit` (`TabWindow.bas` ~3097) — suppress `FormDesign` when adding tab; **user reports still broken**.
- **`mAddingTab` lifecycle** in `AddTab` (`TabWindow.bas` ~359, ~544) — set True at start, False before return.

### Opus next steps (narrow scope)

1. **Trace ALL `FormDesign` callers** during `.frm` open via logging or static breakpoint reasoning:
   - `AddTab` ~510
   - `OnLineChangeEdit` ~3242
   - `RunDeferredFormDesign` ~4790
   - `tbrTop_ButtonClick` ~10101/10116
   - `tabCode_SelChange` side-effects
   - Any `OnUndoEdit` / undo paths that set `TextChanged`
2. **`ClearUndo` / `OnLineChangeEdit` / `OnUndoEdit` paths** — confirm whether `ClearUndo` after first `FormDesign` is necessary; consider moving `ClearUndo` before `FormDesign`, skipping `OnLineChange` during `ClearUndo` (`WithoutShow` already True but `ShowCaretPos` may still fire `OnLineChange`), or guarding `FormDesign` when `Des->DesignControl` is valid and tab is initializing.
3. **`TabWindow.FormDesign` teardown (~8407–8438)** — when `DesignControl` already exists during tab init, **skip teardown** or **skip re-entry** entirely (early `Exit Sub` if design surface is fresh/valid).
4. **`RunDeferredFormDesign`**, **`ApplyFormTabView`**, **`tabCode_SelChange`** — verify no duplicate `FormDesign` after deferred batch; check interaction with `mAddingTab=False` timing vs `ClearUndo`.
5. **Revert experiment:** `git checkout --` workspace-defer changes (`RunDeferredFormDesign`, `FormNeedDesign`, `mApplyingWorkspaceLoad` paths) while **keeping LoadToolBox fix only** — isolate whether defer logic introduced the double-call or only exposed it.

### Revert guidance

**Do NOT commit** current broken state. User may roll back to last known good:

```powershell
# Revert specific files
git checkout -- src/Main.bas src/Main.bi src/TabWindow.bas src/TabWindow.bi src/Designer.bas

# Or stash everything (including untracked — use with care)

## 1. Project overview

**Visual FB Editor (VFBE)** is a FreeBASIC IDE with visual designer, debugger, and project support, built on [MyFbFramework](https://github.com/XusinboyBekchanov/Controls/MyFbFramework).

This fork (**VFBEWin64**) is a **Win64-only** branch of upstream VisualFBEditor:

| Keep | Remove / defer |
|------|----------------|
| Native **WinAPI / Win32** UI | GTK / Linux IDE paths (physically deleted, not just hidden) |
| **64-bit** IDE and bundled `fbc64.exe` | 32-bit IDE (`VisualFBEditor32`, `mff32`) |
| Bundled compiler at `Compiler\fbc64.exe` (tracked in-repo; staying on 1.10.1 — see Tier 3, no viable 1.10.3 binary exists) | Dark-mode *implementation* — replaced with an inert stub, interface preserved for a future trustworthy reimplementation (not full removal — see §3a) |

**This is now a fully self-contained fork:** `Compiler/`, `Debuggers/`, and `Controls/MyFbFramework/` are tracked in git (previously vendored/gitignored) — see §3a and §12.

**Build outputs (repo root):**

- `mff64.dll` — `Controls\MyFbFramework\mff64.dll`
- `VisualFBEditor64.exe` — main IDE

**Settings:** `Settings/VisualFBEditor64.ini` (runtime; path via `ExePath/Settings/...`)

### Target audience

This shapes UI/UX decisions (§13.3) and the installer/distribution work (§13.5) — the product is for people who want to *write BASIC programs*, not people evaluating IDE architecture:

- **Returning BASIC programmers** — learned on Basic (QBasic, VB, etc.) years ago, remember it fondly, but have been put off by modern languages' object-orientation requirements and by how hard it's become to write a rich GUI program without a heavyweight framework or web stack.
- **Desktop-focused hobbyists** — want to build actual desktop programs, not web apps, and are put off by the disjointed nature of modern development (juggling many separate tools/services instead of one cohesive IDE that just works).
- **Students** — many schools still start programming instruction with Basic, since it's more approachable than even Python for a true beginner.

Common thread: **approachability and cohesion over power-user configurability.** None of these audiences want to assemble a toolchain or fight object-oriented ceremony to get a window on screen — the value proposition is "open one IDE, write BASIC, get a real GUI program," which is exactly the niche modern tooling has abandoned. Keep this in mind against feature creep: the original project's failure mode (§13.4) was doing too much without central attention; this audience is better served by a smaller, more polished, more approachable tool than by chasing feature parity with professional IDEs.

### Guiding principle: don't give the user unnecessary options (added 2026-07-03)

**This is a highly opinionated project, not a configurable one.** The focus is build → design → compile → run being as smooth and frictionless as possible. Power users who want knobs to turn have other IDEs; this one should not encourage settings-fiddling as a substitute for a good default.

**Rule of thumb when adding or reviewing any feature:**
- If there's only one reasonable choice, **don't expose a setting for it at all** — just do the right thing and don't show the option.
- If there are genuinely two reasonable choices (e.g. a debug build vs. a final/release build), give a single simple choice — one radio button or dropdown with plain labels (e.g. "Debugger: Development / Final") — not a settings page with independently-togglable flags that happen to combine into those two states.
- Only expose real configurability when there's a **real, user-facing reason** someone would need to change it — not "because the underlying implementation happens to have a flag here." An internal implementation detail becoming a user-facing setting is a smell, not a feature.
- When in doubt, prefer fewer visible options over more. This is the same anti-scope-creep instinct as §13.4's rename rationale, applied specifically to UI/settings surface rather than codebase surface.

**How to apply:** relevant to §13.3 (UI evaluation) and §13.5 (installer) — both should be scoped against this principle, not against "what a power-user IDE like VS Code offers." When §13.2's structured-programming pass or any future feature work exposes an existing internal flag as a new checkbox/dropdown "just in case," push back and ask whether the option needs to exist at all.

### Guiding principle: feedback-channel policy (added 2026-07-07, Opus "Next Steps" Phase D)

**When something fails or a background state changes, use the channel that matches how disruptive it is** — don't reach for whichever call happens to be nearby:
- **Status bar (`pstBar->Panels[0]->Caption`)** — transient, non-blocking editor/view state the user can glance at or ignore (e.g. "Loading project contents...", "this file is too large for the Form Designer — showing code only").
- **Output panel (`ShowMessages(..., ChangeTab:=False)`)** — build output, background analysis, and anything that happened off-screen that the user might want to check later but shouldn't be interrupted for right now. Pass `ChangeTab:=False` so it doesn't steal focus/switch tabs for routine background events; only let build/compile actions (which the user just triggered) auto-switch to Output.
- **`MsgBox`** — reserved for irreversible actions needing confirmation (delete, overwrite, stop a running program) or a failure that blocks the current operation and needs the user's attention right now (a save that didn't happen, a debugger that can't start). Never call `MsgBox` from a background/worker thread without marshaling to the main thread first (see `THREADING.md` rule 3).

**How to apply:** opportunistically, as each area is touched — **not** as a big-bang sweep across the codebase. Applied so far: `TabWindow.FormDesign`'s 50,000-line Designer cutoff and `LoadFunctions`'s missing-include case (both previously silent) now use the status bar / Output panel respectively (Opus Phase D, F2).

---


## 2. Repository & toolchain

### Git remote

```
origin  git@codeberg.org:bigriverguy/VFBEWin64.git
branch  main
```

SSH key: `~/.ssh/id_ed25519_codeberg` (Host `codeberg.org` in `~/.ssh/config`).

**Note:** Git may not be on PATH in all shells; full path:

`C:\Program Files\Git\bin\git.exe`

### Build before running the IDE

Close any running `VisualFBEditor64.exe` first (`mff64.dll` is locked while the IDE runs).

```powershell
cd C:\Users\dmont\VisualFBEditor
set NOPAUSE=1
Compile.bat
.\VisualFBEditor64.exe
```

- **Release:** `Compile.bat` (root)
- **Debug:** `CompileDebug.bat`
- **Gate:** `Compile.bat` must finish with **0 errors** before handoff or user testing
- Use `set NOPAUSE=1` in automated/agent shells to avoid orphaned `pause` processes

See also `src/BUILD.md` and `README.md`.

---


## 3. Roadmap: Tier 2.75 dead-code removal

Work is organized in batches.

| Batch | Scope | Status |
|-------|--------|--------|
| **2.75.1** | Panel/layout cleanup in `Main.bas` | **Complete** (compile-clean) |
| **2.75.2** | Bulk GTK preprocessor strip (`Tools/strip_gtk_preprocessor.ps1` on `src/` + `mff/`) | **Complete** (compile-clean). Manual test plan in §7 was **not fully signed off** before the owner explicitly directed the team to proceed into 2.75.3 anyway — see note below. |
| **2.75.3** | Physical deletion of commented `#IfNDef __USE_GTK__`/`__FB_WIN32__` remnants, dead-legacy-code pass, `mff/DarkMode/` handling | **Complete** — see §3a |
| **Phase 1** | 2.1.1 indentation, 2.1.2 dead code, 2.1.3 magic numbers | **Complete** (2026-07-05) |
| **Phase 2** | 2.2.1 naming conventions, 2.2.2 DRY pass (3 extractions done), 2.2.3 file splits | **Partial** — 2.2.1 + 2.2.2 (conservative) done; 2.2.3 deferred to next session |
| **Phase 3** | 2.3.1 compile-mode toggle, 2.3.2 UI sweep | **Complete** (2026-07-05) |
| **Phase 4** | 2.4.1 final audit, 2.4.2 docs cleanup | **Complete** (2026-07-05) |

> **Process note:** §7's original gate said Batch 2.75.3 should be blocked on full manual sign-off. The owner explicitly chose to start 2.75.3 before that checklist was finished (several boxes below are still open). That was a deliberate call, not an oversight — flagging it here so future sessions don't assume the gate was satisfied by testing.

### GTK strip tool

```powershell
.\Tools\strip_gtk_preprocessor.ps1 src mff
```

Evaluates `#If` / `#Else` / `#EndIf` with Win64 defines (`__USE_WINAPI__`, `__FB_WIN32__`, `__FB_64BIT__`, GTK off). Had a blind spot for the `__EXPORT_PROCS__` symbol (fixed — see §3a); re-run only if new GTK-era files are introduced, and review failures manually for interwoven blocks.

**Safety net for any future re-run (audit flag, 2026-07-03):** the `__EXPORT_PROCS__` blind spot silently deleted `mff64.dll`'s entire export dispatcher, and a clean compile did not catch it — the damage only surfaced when the Designer was exercised at runtime. Before re-running the tool: make sure the working tree is clean so the resulting diff is fully reviewable file-by-file, don't rely on compile-clean alone. After re-running: spot-check that `mff64.dll` still exports the expected symbols (e.g. `dumpbin /exports mff64.dll`) before treating the run as verified.

---



## 3a. Batch 2.75.3 — what actually happened


Full detail archived in [HISTORY.md](HISTORY.md). Key outcomes: Form Designer fix, dark-mode reimplementation with documented APIs, dead-subtree deletion, physical dead-code deletion across src/ and mff/, compile-warning resolution, _WIN32_WINNT header fix, and git-tracking policy change (self-contained fork).

---

## 3b. Examples/ audit — result: nothing to remove

Full detail archived in [HISTORY.md](HISTORY.md). All 33 examples audited for GTK/Linux/Win32-only content — none qualified for removal. Fixed Graphics/CanvasDraw.bas API drift and created missing .vfp project files. WellCOM DllMain still open.

---

## 4. Session history (chronological)

Complete session-by-session history archived in [HISTORY.md](HISTORY.md). Major milestones:

- **2026-07-06:** Form designer grey-panel fixed; File menu (incl. Open Project) and Edit menu step-by-step reviews owner-approved; Search → Define (F2) reliability pass (uncommitted)
- **2026-07-05:** Automatic workspace (.vfs removed); File menu restructure; Run menu consolidation; GDB fixes (Step Out, command queue, Break); bottom panel tab captions fixed
- **2026-07-04:** Dark mode crash #3 fixed (WM_THEMECHANGED recursion); per-form control tree; PagePanel layer navigation
- **2026-07-03:** _WIN32_WINNT header fix (116 locations); dark mode reimplemented; Integrated debugger + alt-compiler backends removed; Tier 3 compiler swap closed (no viable 1.10.3 binary)
- **2026-07-02:** GTK strip + dead-code deletion (Batch 2.75.3); bottom panel fixes; Form Designer export fix

---







---


## 5. Bottom panel — intended behavior (reference)

State model mirrors **left/right** panels:

| Concept | Left/Right | Bottom |
|---------|------------|--------|
| Pinned vs auto-hide | `TabPosition` (`tpTop` = pinned) | Same (`ptabBottom->TabPosition`) |
| Collapsed vs expanded | `SelectedTabIndex = -1`, splitter hidden | Same + `splBottom.Visible` |
| INI: pinned? | `LeftClosed` / `RightClosed` | `BottomClosed` |
| INI: collapsed? | `LeftCollapsed` / `RightCollapsed` | `BottomCollapsed` |
| INI: size | `LeftWidth` / `RightWidth` | `BottomHeight` (≥ 80) |

**INI semantics:**

| Key | `true` means | `false` means |
|-----|----------------|---------------|
| `BottomClosed` | Auto-hide (vertical tabs, `tpBottom`) | Pinned open (`tpTop`) |
| `BottomCollapsed` | Tab strip only (when auto-hide) | Content visible at `BottomHeight` |
| `BottomHeight` | Panel height when expanded | — |

**Key functions (`src/Main.bas`):**

- `GetBottomClosedStyle()` — `Not TabPosition = tpTop`
- `IsBottomCollapsed()` — `tpBottom And SelectedTabIndex = -1`
- `SetBottomClosedStyle(Value, WithClose)` — only place that changes `TabPosition`
- `CloseBottom()` / `ShowBottom()` — expand/collapse content only (no `TabPosition` change)
- `SaveMainWindowPanelLayout()` — early save on exit
- `UpdateBottomPinLayout()` — pin strip position (`BOTTOM_PIN_STRIP_WIDTH = 20`)

**Constants (`src/Main.bi`):** `DEFAULT_BOTTOM_PANEL_HEIGHT=200`, `MIN_BOTTOM_PANEL_HEIGHT=80`, `BOTTOM_PIN_STRIP_WIDTH=20`

---

## 6. Completed work

All completed items have been archived to [CHANGELOG.md](CHANGELOG.md). See that file for the full chronological record of shipped work with commit hashes.

**Still open from this section:**

- [ ] **frmNewProject icons** — template icons not displaying on new form (icon name derivation matches frmTemplates pattern but `@imgList32` may not be populated at form creation time); deferred

---

## 7. Manual test plan — regression validation

> **Handoff note (Claude Code):** Bottom panel **implementation bugs are resolved**, and both left and right panel Pin-click bugs are also now fixed (§4, §6). Batch 2.75.3 (dead-code deletion) **has already happened** — the owner explicitly directed the team to proceed before this checklist was fully signed off, rather than treating it as a hard gate. This checklist is now a **regression-validation pass** covering both the original panel work and the since-completed dead-code deletion, not a pre-2.75.3 gate.

Run a full pass on **latest** `VisualFBEditor64.exe` after `Compile.bat`. Check each box when verified.

### Debugger smoke test (new — added post-2.75.3)

`src/Debug.bas` was the single largest and riskiest file touched in Batch 2.75.3 (core breakpoint/stabs-parsing/debugger-dispatch internals). Dead-code deletion there was verified by clean compilation only; a compile-clean build can still hide a runtime behavior change if a "dead" branch was misjudged.

- [~] Integrated IDE debugger (non-GDB path) — **deprioritized**, not tested. Given §4's "GDB is the project's debugger" decision, this path is a candidate for eventual removal rather than something worth validating further right now.
- [x] Step into — line highlighting advances correctly — **owner verified** via GDB path: 2-line loop body (`b = a * 2` / `Print a, b`) stepped 8→9→8→9 per iteration, exactly as expected.
- [x] Inspect a local variable while stopped — **owner verified** via GDB path: values displayed correctly during stepping.
- [x] Integrated GDB debugger path — breakpoint stop + Step Into + inspect all confirmed working — **owner verified**. This also resolved an earlier false "Can not be used for debugging 32bit exe..." error, which turned out to be the *Integrated* (non-GDB) debugger's `check_bitness()` check firing because the debugger type wasn't actually set to GDB yet — not a real 32-bit/64-bit mismatch. `check_bitness()` (`Debug.bas` ~line 9871) doesn't check whether the underlying `GetBinaryType` call actually succeeded, so it can misreport in other failure modes too — low priority given this path is being deprioritized, but worth knowing if it resurfaces.
- [x] ~~Restart-while-debugging and normal stop/exit — no hang or crash~~ — superseded by the two bugs found below; IDE itself never froze, stayed usable throughout.
- [ ] **Gas64 vs GCC backend check** (resolves the open §4 decision point) — still open, deferred along with the bugs below

**Two real bugs found during earlier testing — fixed 2026-07-05:**

1. ~~**Step Out sends the wrong GDB command.**~~ Fixed: `Case "StepOut"` now calls `step_debug("finish")`.
2. ~~**Command dispatch race condition between debug actions.**~~ Fixed: 32-slot command queue under `tlockGDB` replaces the single `NewCommand` string.

**Also fixed 2026-07-05:** **Break while running** — `break_debug()` sends GDB `interrupt`; mutex released during blocking `readpipe` so the UI can inject it.

**Owner's call (2026-07-03):** defer Step Out + command race — **superseded** by fixes above (2026-07-05).

### Startup

- [x] Cold start — no ghost Find dialog, splash closes, main window active — **owner verified**
- [x] Bottom panel opens in same state as last session (pinned / auto-hide collapsed / auto-hide expanded) — **owner verified**
- [x] Cold start with bottom **collapsed** — editor fills space immediately (no empty gap) — **owner verified**

### Bottom panel (regression on fixes)

- [x] Pin open → exit → restart — stays pinned (`BottomClosed=false` in INI) — **owner verified**
- [x] Auto-hide expanded → exit → restart — reopens expanded — **owner verified**
- [x] Collapse (pin or click-away) — editor fills freed space — **owner verified**
- [x] First start collapsed — editor fills space — **owner verified**
- [x] Pin size/position acceptable in collapsed and expanded modes — **owner verified**
- [x] Single-click collapse when expanded — **owner verified**
- [x] Resize height persists (≥ 80px) — **owner verified**

### Bottom panel — tab captions & debug tabs (added 2026-07-05, **owner verified complete**)

- [x] Cold start — always-visible tabs show correct names (Output, Problems, Suggestions, Find, ToDo, Change Log, Immediate), not all "Globals"
- [x] Debug tabs (Locals, Globals, Procedures, Threads, Watches, Memory, Profiler) hidden at startup
- [x] Start debugging — debug tabs appear with correct names; end debugging — they hide again
- [x] Start/end debug multiple times — no duplicate tabs, no caption corruption
- [x] Close project — no crash; bottom tab captions remain correct
- [x] Restart IDE — bottom tab order persists (no scrambled order from saved `-1` indices)
- [x] Pin/collapse bottom panel — tab labels stay correct in both modes

### GDB debugger — Step Out, Break, command queue (added 2026-07-05, **pending owner verification**)

- [ ] Step Out — runs until current function returns (not same as Step Over)
- [ ] Rapid step/continue clicks — each enqueued command executes (no silent drops)
- [ ] Break while running — program stops; can inspect state; Continue resumes

### Run menu — debug & run commands (added 2026-07-05, **owner verified complete**)

- [x] **Run** menu contains session, stepping, Use Debugger/Profiler, breakpoints, GDB/watch, set/show next statement — no separate Debug menubar
- [x] **Use Debugger** checks/unchecks; debug tabs show/hide; step/run commands enable when debugger on + project open
- [x] **Use Profiler** disabled when debugger off; unchecks when debugger turned off
- [x] Start / Continue / Step / Run To Cursor / Set Next Statement enable states at startup and with editor focus
- [x] Clear All Breakpoints clears markers across open tabs

### Regression (Batch 2.75.2 + adjacent areas)

- [x] Left/right panels pin/collapse/restore — **owner verified**
- [x] Ctrl+F, Find In Files — **owner verified**
- [x] Compile/run, Output/Problems tabs — **owner verified**
- [x] Form design, property editing — **owner verified**
- [x] Toolbox insert, project explorer, AI Agent tab (if used) — **owner verified**
- [x] Session open/save, recent files/projects — **owner verified**

All items above passed **before** the owner separately found the critical `_WIN32_WINNT` compiler-header bug (see §4) while trying the `MDINotepad` example — that bug is a pre-existing defect in the bundled compiler's headers, unrelated to (and not caught by) this regression pass, since the regression checklist exercises the IDE's own UI/workflow rather than compiling every example project. Now fixed — see §4.

### Gate to Tier 3

**Regression validation is now complete**, aside from the still-open gas64-vs-GCC backend check above (§4/§8). Compiler-header robustness work (the `_WIN32_WINNT` fix, §4) happened in parallel/after this pass and doesn't need to be re-validated here — it's covered by its own verification in §4.

### Optional / housekeeping

- `docompile.bat` — gitignored local helper at repo root (owner convenience)
- Consider `.gitignore` for `VisualFBEditor64.exe` if binary commits are undesired (currently committed like initial import)

---

## Open Items

*All open/deferred items consolidated from across the document. Ordered by priority/readiness.*

### Immediate (stubs & bugs)

- [ ] **frmNewProject icons** — template icons not displaying on new form (`@imgList32` may not be populated at form creation time)
- [ ] **`OpenRecentFiles()`** — stub; needs `frmRecentFiles` dialog
- [ ] **`DeleteEditorFile` project-member `.vfp` sync** — S5 implemented real Delete File (confirm + disk delete + tree-node removal), but for a *project-member* file it doesn't mark the project dirty / update the `.vfp` the way `RemoveFileFromProject` does; the deleted file may still be listed in the `.vfp` until the next save. Mirror `RemoveFileFromProject`'s dirty-mark. Low priority; found in Opus S5 review 2026-07-07.
- [ ] **Toolbar persistence re-test** — confirm the Run-toolbar fix (2026-07-07): hide Run → close via window X → relaunch → stays hidden; `ShowBuildToolBar` gone from INI. Needs GUI.
- [ ] **GDB smoke test** — Step Out, rapid step/continue queue, Break while running — pending owner verification (§7)

### Low-priority cleanup

*(`src/makefile` and `src/THREADING.md` GTK-reference entries removed 2026-07-07 — both were already resolved by commit `6b3200a`; the Open Items entries had just gone stale. See §13.3.A S5–S7 execution.)*

### Queued for Cursor

- [ ] **MFF control library path consolidation** — one DLL → one `Library` object with one canonical path; retire `GetModuleFileNameW` workaround in `Designer.Symbols` (§8)

### Deferred enhancements (nice to have, not blocking)

- [ ] **2.2.3 Split oversized files** — `TabWindow.bas` (576 KB), `Main.bas` (412 KB), `EditControl.bas` (316 KB) (§13.2)
- [ ] **13.9 Blank Designer page on cold-open** — `PagePanel` page shows blank until a control is selected; cosmetic only (§13.9)
- [ ] **13.10 Dark mode: owner-drawn popup menus + input-field polish** — `WM_DRAWITEM ODT_MENU` handler is an empty stub; input-field faces stay light (§13.10)
- [ ] **13.11 Dark mode: dark dialog backgrounds** — `WM_ERASEBKGND` not filled with dark brush; gate on window class (§13.11)
- [ ] **13.8 Design-workspace status bar** — three-cell status bar docked to `pnlForm`; researched, non-trivial (§13.8)

### Unscheduled / future planning

- [ ] **13.3 UI review** - File + Edit owner-approved; Search → Define (F2) reliability improved (uncommitted); **View menu** is next after Search sign-off. **Full designed approachability plan in [ROADMAP.md](ROADMAP.md) §13.3.A** (progressive-disclosure model, no easy/advanced mode; O1–O4 owner-approved 2026-07-06). **S1–S4 executed (Sonnet, 2026-07-06) — see [13.3.A execution](#133a-execution--s1s4-done-sonnet-session-2026-07-06--not-committed-awaiting-opus-review) above for full detail, issues found/fixed, and deferred items; uncommitted, awaiting Opus diff review before commit/push.** S5–S7 (Delete confirm dialogs, Options-dialog audit, docs cleanup) remain queued in ROADMAP.
- [ ] **13.2.1.1 Standardize indentation** — convert mixed tabs/spaces across all source files (§13.2)
- [ ] **13.4 Rename the project** (e.g. "ABStudio") — deeper than cosmetic; dedicated pass needed (§13.4)
- [ ] **13.5 Standard Windows installer** — Inno Setup or WiX; depends on project rename decision (§13.5)
- [ ] **13.6 Full review/expansion of Examples/** — re-verify all examples compile; fix `WellCOM` DllMain; add appealing demos (§13.6)
- [ ] **13.7 Enhance AI integration** — deeper codebase-aware context, AI-assisted debugging, inline suggestions (§13.7)
- [ ] **Upstream sync strategy** — this fork intentionally diverges; merge only with explicit plan
- [ ] **Wiki/docs** — fork-specific documentation
- [ ] **Basic CI** — run `Compile.bat` on push

---

## 8. Planned next steps (historical design & research)

### Form Designer panel/layer navigation (part b) — shipped 2026-07-04, one known cosmetic gap left

**Owner's concern, raised 2026-07-03:** the `vbxGeneral` checkbox-overlap regression took multiple rounds of temporary runtime instrumentation to root-cause, because the framework's docking engine has timing-dependent passes hard to reason about statically. Owner's working theory: `frmOptions.frm` (~6,300 lines, 17 panels, deep nesting) was hand-coded directly because the Designer can't handle a form this large/complex, and its own navigation was hard to use.

**Characterized 2026-07-04:** owner pinned down two concrete gaps (confirmed by research, see below):
1. The Designer's project tree stops at the form/file level — no per-form list of child elements. Owner: "crucial in finding lost z-order elements" (directly why the checkbox-overlap bug took hours to diagnose).
2. No way to navigate between a form's internal pages/panels once viewing one — owner got stuck on `frmOptions`'s last panel ("AI Agent") with no path to any other.

Owner's conclusion: "Designer fine for simple 1 layer forms in visual mode, anything layered has to be hand coded" — and explicitly: **not interested in building a designer from scratch**, needed to know if the existing one can be salvaged.

**Researched 2026-07-04 — verdict: salvageable, additive scope, not a rewrite.**
- The project tree (`Main.bas:610-760`, `AddProject`) goes Project → category folders → files, four levels, and genuinely stops at the file node. Confirmed dead end.
- `cboClass` (`TabWindow.bas`, `Sub cboClass_Change` ~line 2811; population at `TabWindow.bas:9684-9754`) **already exists** and flatly lists every control on a form regardless of nesting depth, and can independently select any of them (`Des->SelectedControl = Ctrl`, `MoveDots`) — real, working VB/Delphi-style Object-selector infrastructure, just never surfaced as a discoverable tree.
- `PagePanel.bas` **already has a working panel-switch mechanism**: right-click a `PagePanel` in design mode → `UpDownControl_Changing` (`PagePanel.bas:277-291`) builds a "Show Panel" popup menu from `SelectedPanelIndex`, and picking one switches panels correctly. The owner independently found this spinner control and correctly guessed its purpose — "it just didn't work" — because it's disconnected from `cboClass`/tree selection: picking a control that lives on a currently-hidden panel doesn't flip that panel visible first (`BringToFront`, `Designer.bas:2082`, only does Z-order, never touches `SelectedPanelIndex`), so you silently select an invisible control.
- **The queryable data model the owner assumed didn't exist actually does** — `Designer.Objects`/`Components`/`Controls` (`Designer.bi:174-176`) plus `cboClass`'s already-populated flat list. It's presented as a flat, hidden combo instead of a tree, and panel-switching exists but is buried and disconnected.

**Scope for the actual fix:**
- **(a) Per-form control tree — done (2026-07-04).** Implemented in `Main.bas`: `tvExplorer` form nodes now lazily expand into a real, correctly-nested control tree (`AddControlTreeNode`/`ExpandFormControls`), walking the *live* container hierarchy (`Des->Controls.Contains`, `ControlCount`/`ControlByIndexFunc` — the same traversal `TabWindow.bas`'s dead `GetControls` already modeled, just never wired to anything) rather than reconstructing nesting from `cboClass` + `Parent` as originally planned — simpler and gets z-order-correct ordering for free. Selecting a control node calls into the same selection path `cboClass_Change` already used (`Des->SelectedControl`, `MoveDots`, `DesignerChangeSelection`). Single-click opens/selects any editable tree file (Forms, Includes, Modules, ...) consistently, matching how the rest of the tree already worked, while explicitly *not* single-click-triggering Shell-launches/external-tool handoffs/project-switching (those extension-based actions still require the existing double-click). Control-node icons reuse the Toolbox's own per-class icons (`EnsureControlIcon`, lazy-loaded from the owning control library DLL via the global `Comps` registry — the same source `imgListTools`/the Toolbox tree already pull from), so a `CheckBox` node looks like a checkbox, etc.
- **(b) Panel/layer navigation — shipped 2026-07-04.** The "layered canvas control" turned out to be `frmOptions.frm`'s own `pplGeneral`, a real `PagePanel` (confirmed via `frmOptions.bi:200`) used as a 17-page settings dialog — its pages are declared `As ScrollControl`, not `Panel`, which doesn't change any of the fixes below (traversal is by generic `ClassName`/`ControlByIndexFunc`, not type-specific) but is worth remembering if it ever looks like a type mismatch. Landed:
  - **Selection reveals the right page**: `RevealAncestorPanels` (`TabWindow.bas`) walks a selected control's ancestors for a `PagePanel` and flips it to the right child via `WriteProperty("SelectedPanel", ...)`; wired into both the new control-tree selection and the older `cboClass_Change`.
  - **In-canvas navigation, not just the tree**: `Designer.MovePanelLayer` (`Designer.bas`) cycles to the previous/next page (wraps at both ends) — bound to Ctrl+PageUp/PageDown (`Designer.KeyDown`) and to new "Previous Layer"/"Next Layer" items in the Designer's right-click menu, alongside a dynamic "Show Panel" submenu (`Designer.ChangeFirstMenuItem`) listing every page on the nearest `PagePanel` ancestor by name.
  - **Real bug found and fixed along the way**: right-click never selected the control it landed on (only left-click did, in `Designer.HookChildProc`'s `WM_LBUTTONDOWN` — `WM_RBUTTONUP` had no equivalent), so the new menu items were silently acting on stale selection state. Fixed by selecting under the cursor on right-click too.
  - **Load-time bug found and fixed**: `PagePanel.Add`'s "jump to the newest child" (correct for an interactive Toolbox drag) was firing once per pre-existing page every time the Designer reconstructs an existing multi-page form from source, silently overriding the form's own `SelectedPanelIndex = 0` init. Fixed with a `Loading` flag threaded from `Designer` → each control's `Loading` property (mirroring the existing `DesignMode` plumbing, since `PagePanel.bas` compiles into the separate `mff64.dll` and can't see IDE-only types directly) → `PagePanel.Add`, reset once the load finishes; plus a final "settle" re-application of `SelectedPanelIndex` after all of a `PagePanel`'s pages exist, since the form's own init statement necessarily runs before any of its pages are parented.
  - **Known cosmetic gap, deferred as "nice to have, not critical," end-of-project**: even with all of the above, `frmOptions.frm` still opens showing a *blank* page area until a control inside a page is actually selected (owner: "the layer doesn't show until the layer is in edit"). Diagnosed as a real, more specific case of the same bug class the fix above addresses — a page hidden throughout Designer reconstruction never gets a layout pass, so becoming `Visible=True` alone doesn't retroactively fix stale/never-computed child positions. Added `Controls[i]->RequestAlign` to `PagePanel.SelectedPanelIndex`'s real setter (`PagePanel.bas`) right where a page becomes visible, which should be the architecturally-correct fix — confirmed not sufficient in testing, root cause of *why* not is still open. Owner explicitly deprioritized further chasing this for now; all of the actual navigation (tree, menu, keyboard) works correctly once *any* selection has happened, so this is purely about the very first, cold-open frame.

**Recurring pattern worth remembering:** "sound design, unfinished last-mile integration" has now shown up repeatedly across this project (docking engine, `PagePanel` panel-switching *and* right-click selection *and* page-layout-on-show, several instances in one investigation alone). Owner's framing: "There is a lot to like about it, just that last 10% that takes 70% of the time and effort never got done." Treat this as a signature of this codebase generally, not a one-off — foundational pieces tend to be genuinely well thought out; look for missing integration/polish before assuming something needs to be rebuilt from scratch.

### Bug fix: File > Close / Close All left the project tree behind (found + fixed 2026-07-04)

Owner reported: after File > Close or File > Close All, everything else reset (tabs, Properties/Events panels, window caption) but the just-closed project's entry stayed in the project tree. Root cause: `TabWindow.CloseTab` (`TabWindow.bas:1057`) and `CloseAllTabs` (`Main.bas`) only ever close/remove *file* tab nodes — `CloseTab` has an explicit `tn->ImageKey <> "Project"` guard so a single file close never nukes the whole project node, which is correct, but nothing downstream of `CloseAllTabs` ever picked up the slack for "every tab in this project is now closed, so the project entry should go too." Only `CloseProject` (`Main.bas:2193-2294`, reached via File > Close Project / Explorer context menu / `CloseSession`) actually removes a project's tree node — `CloseSession` already does the right two-phase thing (close every tab, *then* sweep `tvExplorer.Nodes` calling `CloseProject` on each project node), but `CloseAllTabs` never got the second phase added.

**Fix:** `CloseAllTabs` (`Main.bas`) now does the same sweep after closing tabs, via a new `ProjectHasOpenTabs` helper (checks `tb->ptn` — a `TabWindow` field set once at construction via `GetParentNode`, already used the same way by `CloseProject`/`CloseSession`) that gates the sweep so a project is only auto-closed once *nothing* is left open under it — this correctly skips projects kept open via `WithoutCurrent`, or where the user hit Cancel on a per-tab unsaved-changes prompt, rather than force-closing over a deliberate Cancel. File > Close (single tab) deliberately still leaves the project tree alone otherwise — standard IDE convention (Visual Studio/VS Code don't remove a project from Explorer just because you closed one of its files) — only Close All now also closes empty projects.

*Planning items consolidated into [Open Items](#open-items) above. The historical design research and bug analyses below are preserved for reference.*

### Tier 3 — compiler toolchain (closed)

Tier 3 (compiler swap to 1.10.3) was attempted 2026-07-03 and closed: no viable 1.10.3 Windows binary exists anywhere. Staying on bundled FBC 1.10.1. Full writeup in §4. Longer term: vendor FreeBASIC compiler source into repo for AI-assisted review — natural point to revisit building a newer FBC from source.

---

## 9. Rules & skills (Cursor / agent workflow)

These live under `.cursor/` and should be followed for any UI, startup, or settings work.

### Always-applied rule

**File:** `.cursor/rules/contextual-change-validation.mdc`

Before handoff:

1. **Map the change surface** — all features, panels, INI consumers, init paths in the touched area
2. **Init / first-run audit** — cold start, missing INI keys, order of `LoadSettings` vs layout
3. **Compile** — `Compile.bat`, **0 errors**
4. **User test checklist** — whole area, not one control

**Do not:** hand off after testing only the changed line; skip init checks when touching `LoadSettings`, `frmMain_Create`/`Show`, `LoadToolBox`, or panel handlers; ask user to manual-test before compile + checklist are ready.

**Escalation:** If unresolved after **4 fix cycles** → Opus fix-review loop: compile → independent review → fix critical/high/medium → repeat (max 5 iterations). User manual test **only after** review sign-off.

### Skill (detailed workflow)

**File:** `.cursor/skills/contextual-change-validation/SKILL.md`

Includes:

- Change-surface tables (left/right/bottom panels, toolbox, startup)
- Minimal-INI test scenarios
- Checklist templates
- Opus/Bugbot review scope
- **Excluded scope:** obsolete dark mode / GTK → dead-code cleanup, not actionable bugs

### User / agent conventions (from session)

- **Minimize scope** — smallest correct diff; match existing code style
- **No commits** unless user explicitly asks
- **Every session ends with a compile-clean commit + push to Codeberg** (added 2026-07-03; compile-clean gate added 2026-07-03 after a second-AI audit flagged the risk of pushing broken intermediate state) — run `Compile.bat` and confirm **0 errors** first. Only if the compile is clean should you commit any outstanding working-tree changes (status doc updates, INI/scratch state, etc.) with a sensible message, then `git push origin main`, as the last action before signing off for the day. If the compile fails and can't be fixed in-session, say so and hold off on the commit/push rather than pushing broken code. This is a standing instruction, not a one-time request — don't wait to be asked again in future sessions.
- **INI key migration** (added 2026-07-03, second-AI audit) — new keys must ship with a default (never assume an existing user's INI has it); never rename or repurpose an existing key without a migration read of the old key name first, so existing users' settings aren't silently orphaned. Relevant now that §13.4's rename will touch `Settings/VisualFBEditor64.ini`, but applies to any INI key work.
- **WinAPI only** — do not reintroduce GTK/Linux IDE paths
- Close running IDE before rebuild
- `set NOPAUSE=1` for agent compile runs
- Prefer `Compile.bat` over ad-hoc `fbc64` unless debugging
- **Compile logs** (added 2026-07-05) — all compile log output goes to `Logs/<name>.txt`; delete contents of `Logs/` at the end of each session. `Logs/` is in `.gitignore`.
- **Cross-reference before deleting/moving** (added 2026-07-05) — after deleting or moving any item (menu item, control, function, variable, etc.), search the entire `src/` tree for references to that item and update or remove them before proceeding. A clean compile is not sufficient — dormant paths like `ChangeMenuItemsEnabled` can hold stale references that only trigger at runtime.

---

## 10. Key files map

| Area | Files |
|------|--------|
| Entry point | `src/VisualFBEditor.bas` (`_NOT_AUTORUN_FORMS_`) |
| Main UI & panels | `src/Main.bas`, `src/Main.bi` |
| Toolbar / commands | `src/VisualFBEditor.bas` (`PinBottom`, etc.) |
| Settings load/save | `src/SettingsService.bas`, `Settings/VisualFBEditor64.ini` |
| Tab editor chrome | `src/TabWindow.bas` |
| Splash | `src/frmSplash.frm` |
| Framework | `Controls/MyFbFramework/mff/` → `mff64.dll` (`TabControl.DetachTab` added 2026-07-05) |
| Workspace | `Settings/Workspace.ini` (auto save/restore; not user-facing) |
| File dialogs | `src/frmNewFile.*`, `src/frmOpenProject.*`, `src/frmRecentProjects.*` |
| Build | `Compile.bat`, `CompileDebug.bat` |
| GTK strip | `Tools/strip_gtk_preprocessor.ps1` |
| Build docs | `src/BUILD.md`, `README.md` |

**Panel init order (`frmMain_Create`):**

1. Read widths/heights from INI  
2. `bApplyingStartupLayout = True`  
3. `SetLeftClosedStyle` / `SetRightClosedStyle` / `SetBottomClosedStyle`  
4. `ShowBottom` if auto-hide but not collapsed  
5. `bApplyingStartupLayout = False`  

**Panel show (`frmMain_Show`):**

1. Maximize if saved  
2. `UpdateBottomPinLayout`; if `Not splBottom.Visible` → `CloseBottom` (fixes first-start dock)  
3. After `ActivateMainWindow`: re-expand auto-hide if INI says so; `CloseBottom` again if collapsed  

---

## 11. Handoff notes for Claude Code

**Primary handoff artifact:** this file (`PROJECT_STATUS.md`) + **§7 manual test plan**.

1. **Read this file first**, then `src/BUILD.md` and `.cursor/skills/contextual-change-validation/SKILL.md` before panel/settings changes.

2. **Bottom/left/right panel implementations are all complete** — do not reopen unless §7 regression tests fail. If they fail, the three panels share one state-machine pattern (`Set*ClosedStyle(Value, WithClose)`), so compare all three against each other in `src/Main.bas`/`src/VisualFBEditor.bas` before patching.

3. **Batch 2.75.3 (dead-code deletion) is complete** — see §3a for full detail. Don't re-run a bulk GTK strip; the remaining single marker in `TabWindow.bas` is intentional (user-code preprocessor evaluator, not build config).

4. **Owner action:** finish every unchecked item in **§7** (now framed as regression validation, not a pre-2.75.3 gate) before starting Tier 3 compiler-swap work.

5. **Avoid fix cycles** — map full surface, compile, checklist; if stuck after 4 iterations, stop and document root cause instead of tweaking one line.

6. **Build-log verification gotcha:** `Compile.bat`'s piped output is UTF-16 encoded. Raw `grep`/Bash text search against it silently reports zero matches even when warnings/errors are present. Always verify via the `Read` tool, never raw grep, against these logs.

7. **Upstream** is Xusinboy's VisualFBEditor; this fork intentionally diverges (Win64-only). Merge upstream only with explicit plan.

8. **Examples/** and **Tools/** are largely untouched by Tier 2.75; don't strip GTK from user examples unless that's a separate decision.

9. **Local convenience:** `docompile.bat` at repo root is gitignored (owner's personal compile shortcut).

10. **Tier 3 (compiler swap) attempted and closed 2026-07-03** — see §4/§8. No viable 1.10.3 Windows binary exists anywhere; staying on the currently-bundled 1.10.1. Don't re-attempt fetching a prebuilt 1.10.3 binary without new information (a genuine point-release build surfacing somewhere) — this was checked thoroughly (stw's portal, GitHub Releases, SourceForge, general web search) before concluding.

---

**Panel save (`frmMain_Close`):**

1. `SaveMainWindowPanelLayout()` — **first**, before `CloseSession`  
2. … session close, other INI keys …

---

## 12. Commit log (this fork)

| Commit | Description |
|--------|-------------|
| `bbfa399` | Initial Win64 fork import |
| `e212819` | Bottom panel persistence/collapse; startup guards; `SaveMainWindowPanelLayout`; `PROJECT_STATUS.md` |
| `e63f1a6` | Status doc commit-hash update |
| `ef3b43e` | First-start collapsed layout; gitignore `docompile.bat`; handoff/test-plan update |
| `2511d86` | Record commit hash for `ef3b43e`; save bottom panel INI state |
| `5a09739` | Update INI window/panel state; rebuild `VisualFBEditor64.exe` |
| `c267284` | Fix right panel not collapsing on Pin click |
| `7c1a055` | Save session state after verifying right panel collapse fix |
| `af5b4be` | Update designer-regenerated `Temp.bas` scratch files |
| `bef9267` | Fix Form Designer never activating: strip tool silently deleted exported component dispatchers |
| `b555406` | Track the bundled FBC compiler and GDB debugger toolchains in-repo |
| `64daa66` | Fix left panel not collapsing on Pin click |
| `15e66cc` | Remove 32-bit compiler binaries (`Compiler/bin/win32`) — out of scope |
| `ac29ec8` | Update designer-regenerated `Temp.bas` scratch files |
| `53d8e47` | Fix all compile warnings (first pass — see `56f6d18` for correction) |
| `56f6d18` | Remove risky dark-mode implementation (replaced with inert stub); finish fixing mixed-boolean warnings |
| `c494207` | Delete confirmed-dead code: `gir_headers/`, `WebView/`, `fbsound/`, `SoundPlayer.*` |
| `7baebd1` | Physically delete dead GTK/32-bit/Linux code and legacy comment cruft in `Debug.bas` |
| `add4642` | Physically delete dead GTK/32-bit/Linux code in `Designer`/`Main`/`TabWindow`/`VisualFBEditor.bas` |
| `76abaa5` | Physically delete remaining dead GTK/32-bit code across `MyFbFramework` and `src` headers |
| `4cf7275` | Fix critical `_WIN32_WINNT` header bug blocking user-project compiles; bottom-panel tab clearing on project close |
| `4bd0289` | Add missing example `.vfp` project files; audit Examples/ for GTK/Linux/Win32-only; add "no unnecessary options" guiding principle |
| `51441d7` | Fix `Graphics/CanvasDraw.bas` example against current `mff` API |
| `e139c2c` | Remove leftover 32-bit GCC internals (`i686-w64-mingw32`); clarify gas64/gcc relationship |
| `5021314` | Lock in decision: implement both gas64 and gcc backends, remove gas64 if GDB debugging fails |
| `59cd42c` | Close Tier 3 (compiler swap): no viable 1.10.3 binary exists, staying on 1.10.1 |
| `0934416` | Finalize gas64/GDB decision: gas64 is dead, Development/Final both use `-gen gcc` |
| `3886f3d` | Add note: UI/settings sweep for GTK/Linux/alt-compiler/alt-debugger remnants |
| `5fa5cf2` | Remove Integrated (stabs) debugger engine and alt-compiler-backend/debugger-choice code (~10,360 lines deleted) |
| `b3633bc` | Reimplement dark mode with documented Win32 APIs; fix startup-hang regression from `SettingsService` infinite loop |
| `a7c7839` | Fix General-options checkbox overlap (`ControlIndex` + `RequestAlign` on page visibility); flag Form Designer multi-page scalability concern |
| `f371d21` | Fix two real dark-mode crash bugs (`WM_SETTINGCHANGE` ANSI string + early-startup broadcast); document third still-open crash |
| `fd33a05` | Characterize and scope the Form Designer navigation gap; confirmed salvageable with additive scope, not a rewrite |
| `f292db0` | Add per-form control tree to project Explorer; fix File > Close All leaving empty project tree behind |
| `0c08fe5` | Add PagePanel layer/page navigation (tree + right-click menu + Ctrl+PageUp/PageDown); fix right-click-never-selects and load-time page-visibility bugs |
| `389f3ce` | Fix dark mode crash #3 (WM_THEMECHANGED ↔ SetWindowTheme infinite recursion → stack overflow); complete tab/body dark rendering |
| `d877cef` | Safe dark popup menus scaffolding; right panel pin fix |
| `7261267` | Phase 2 cleanup: magic numbers, dead code, naming fixes, orphaned UI, Development/Final compile toggle |
| `d7608ae` | 2.2.2 DRY: `SaveTabPagePlacement()` extraction (19 WriteString/Integer pairs → helper) |
| `6b3200a` | 2.4.1/2.4.2: delete `src/makefile` (Linux/GTK build system); fix `THREADING.md` GTK reference; remove final `__USE_GTK__` comment |
| `49ec5cc` | UI evaluation fixes: menu labels, dialog cleanup, debug tabs, Code Editor grouping, compiler options simplification, editor defaults |
| `37ba31e` | UI evaluation: File menu restructure, `frmNewProject`, debug tabs, startup options, MRU fix, editor defaults |
| `b9735e8` | Replace `.vfs` sessions with automatic workspace; restructure File menu; fix bottom panel tab captions |
| `ec42ea8` | Win64 IDE cleanup: simplify menus (Run menu consolidation), projects, build, and debugger (GDB fixes: Step Out, command queue, Break) |
| `cc9e7dd` | Fix form designer grey panel: resolve MFF control library by live module handle via `GetModuleFileNameW` |

---

## 13. Future enhancements

Full enhancement specs archived in [ROADMAP.md](ROADMAP.md). Quick reference:

| ID | Enhancement | Status |
|----|-------------|--------|
| 13.1 | Evaluate later GCC version | **Closed** — evaluated, declined |
| 13.2 | Structured programming pass (4 phases) | Phases 1-4 mostly complete; 2.1.1 indentation + 2.2.3 file splits deferred |
| 13.3 | UI evaluation & modernization | **In progress** — File + Edit owner-approved; Search → Define (F2) reliability improved (uncommitted); View menu next |
| 13.4 | Rename project ("ABStudio") | Unscheduled — dedicated pass needed |
| 13.5 | Standard Windows installer | Unscheduled — depends on 13.4 |
| 13.6 | Full review/expansion of Examples/ | Unscheduled — doc/polish phase |
| 13.7 | Enhance AI integration | Unscheduled — not yet scoped |
| 13.8 | Design-workspace status bar | Deferred — non-trivial |
| 13.9 | Blank Designer page on cold-open | Deferred — cosmetic only |
| 13.10 | Dark mode popup menus + input polish | Deferred |
| 13.11 | Dark mode dialog backgrounds | Deferred |

---

## Document maintenance

This document is the project's primary handoff artifact. To keep it navigable:

- **Add new content chronologically** within the relevant section rather than always at the top.
- **When a section exceeds ~100 lines of dense prose**, consider whether the new content justifies a new subsection or should replace older detail.
- **Remove, don't strike-through.** Once a bug is fixed and committed, strip its in-progress investigation notes — the root-cause analysis and fix description are worth keeping; the chronological debugging log usually isn't.
- **Update the [Current State](#current-state-2026-07-06) table** whenever a major area's status changes (bug fixed, feature shipped, new active work item).
- **Consolidate deferred items into [Open Items](#open-items)** rather than letting them drift across §7, §8, and §13.
- **Update the commit log (§12)** at the end of each session — it's the canonical chronological index of what shipped.
- **Cross-reference with `[section name](#anchor)` links** rather than bare "see §N" — anchors survive section renumbering better.
- **Target length:** aim to keep this document under ~800 lines (currently 708). If it grows past that, move content to the companion files listed below rather than expanding this file.
- **Companion files:** [CHANGELOG.md](CHANGELOG.md) (completed work + commit log), [HISTORY.md](HISTORY.md) (session history + bug investigations), [ROADMAP.md](ROADMAP.md) (full enhancement specs).

---

*End of status document.*
