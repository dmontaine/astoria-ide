# VFBE Win64 Fork — Project Status & Handoff

> ⏸️ **DEBUGGER RELIABILITY SUB-PROJECT — ACTIVE (WIP, synced across machines via git).** See [⭐ ACTIVE SUB-PROJECT — Debugger Reliability](#-active-sub-project--debugger-reliability-queued-2026-07-11) for the full charter and defect table (DR-1..DR-16).
>
> **Status at a glance (2026-07-12, end of AMD-machine session):** ✅ **FIXED + owner-verified this session:** **DR-15** (`57007dc`+`07ea740`) — orphaned `astoria.exe`/debuggee on close; `CloseAllDocuments` now calls `kill_inferior_process()` before enqueueing `q` when the inferior is running freely (GDB doesn't act on stdin while it runs — same quirk as the DR-6 Stop-button fix). **DR-7 fully closed** (`8ce74f2`+`ce10b5c`, owner quick-tested) — the last worker-thread UI touches (`readpipe`'s `ShowMessages`, `run_debug`'s loop-body `ShowMessages`, watch-edit `UpdateWatch`, `load_file`'s session-start panel clear) now stage data via `QueueShowMessages`/`FlushDebugOutputOnUI`, mirroring the 2D pattern exactly. **Phase 4 dead-code sweep done** (`9e40c42`) — removed ~1160 lines of the vestigial integrated (stabs) debugger (`timer_data`, `set_bp`, `hard_closing`, ~230 lines of dead globals, ~65 orphaned Declares + their backing types), cross-reference-verified, compile-clean. All prior DR-1/DR-3/DR-6/DR-8/DR-9/DR-10/DR-12/DR-13/DR-14 remain fixed+verified (see table). **DR-11** resolved as a downstream symptom of DR-3. ✅ **DR-4 FIXED + owner-verified 2026-07-12 (Intel machine).** It was never a paint bug — the `EC.Paint` trace proved geometry healthy/identical on every paint. Real cause: a gutter/line-number click sets the caret to **end-of-line** and `ScrollToCaret` **horizontally scrolls** to it; on the narrower Intel window that shifted the viewport right (short lines off-left, long lines tail-only — looked like disappearing text). Fix: gutter click updates the caret via `ShowCaretPos False` (no scroll) instead of `ScrollToCaret` (`EditControl.bas` `WM_LBUTTONDOWN`). `HScrollPos=0` confirmed in-trace post-fix; `EC.Paint` instrumentation stripped. ✅ **"2-clicks-to-close-X" investigated → NOT a code bug (2026-07-12).** Instrumented the close path (`CloseAllDocuments` entry state + every `Return False`/`True` + the `frmMain_Close` call-site result) and reproduced: the 3-click close fired **only one** `Close.enter`, which returned `CAD.true` and closed immediately — clicks 1–2 never reached the close handler (no `WM_CLOSE`). So the close *logic* is correct; the extra clicks are **Windows activate-then-act behavior** on an unfocused window (the debuggee's console window stealing focus during debug set it up). No fix; diagnostic instrumentation reverted (the pre-existing `Close.enter`/`CloseProj.*` traces already show whether the handler fired). ✅ **DR-16(b) FIXED (2026-07-12, Sonnet, compiles clean, no observed symptom before/after — preventive)** — `deinit`'s direct `ChangeEnabledDebug`/`DeleteDebugCursor` worker-thread calls now stage via `bDeinitCleanupPending`, applied by `FlushDebugOutputOnUI` on the UI thread (DR-7 pattern). Confirmed `deinit`'s only 2 live callers are both worker-thread (inside `run_debug`'s loop); 2 more call sites found during the audit are dead code (`kill_debug` has zero callers; `line_highlight`'s legacy `"[Inferior 1"` branch is unreachable — `run_debug`'s loop intercepts it first) — flagged for Phase 4, not touched. ✅ **DR-16(a) FIXED + owner-verified (2026-07-12, Sonnet, `600a8c7`+`91b054f`).** Owner chose to fix properly rather than defer — widened scope after tracing turned up a second worker-thread-MsgBox hazard in `GetMainFile()` (called to compute the exe path). New `PrepareDebugSession()` runs the GDB/exe/MainFile checks on the UI thread before any of the 5 debug-start entry points spawn the worker; `StartDebuggingWithCompile` (F5) deliberately not covered (exe doesn't exist yet at that point). **DR-16 fully closed. All open DR items now resolved — the transport rewrite + this session's residual sweep are done.** **DR-2** — still resolved-unless-it-recurs (unchanged since 2C). **⚠️ Testing-methodology gotcha (2026-07-12, Sonnet session):** launching `astoria.exe` via PowerShell `Start-Process` does **not** give the window real OS foreground focus (Windows' foreground-lock protection silently blocks `SetForegroundWindow` from a background script, confirmed via `IsForeground=False` even after an explicit call) — every automated test that session ran against an *unfocused* window, which looked like DR-4 and the "2-clicks-to-close" both spuriously "reverting." Root cause was 100% the unfocused window, not code — confirmed by having the owner click the title bar once before retesting, after which both worked on the first try, no regression. **Lesson: after any Claude-launched rebuild, click the window once before testing** (or don't trust a "regression" report from an agent-launched instance without that click first).
>
> **Standing rule (non-negotiable, carried over from the original T6 charter): instrument-first — add file-trace, have the owner reproduce, read the actual interleaving, *then* fix. Do NOT reorder/restructure the GDB worker loop without a confirming trace.**
>
> **⏭️ CROSS-MACHINE HANDOFF (2026-07-12, Intel machine → other computer). `git pull` first thing** — synced to `origin/main` @ `c906d19`, nothing uncommitted but the usual not-ours noise (`Controls/MyFbFramework/mff/Temp.bas`, `Settings/astoria.ini`, `Examples/DeviceExplorer/DeviceExplorer.vfp` — leave alone). **This session:** (1) DR-16(a) done + owner-verified — **the Debugger Reliability sub-project (DR-1…DR-16) is now fully closed**; (2) Phase 4 dead-code items removed (`90f4dc7`+`64ea0ed`); (3) **first review of `Controls/MyFbFramework/` (MFF, the vendored GUI framework) — see the new [MyFbFramework review](#myfbframework-review-fable-2026-07-12) Open-Items subsection + the full report.** **Report location:** `P:\Astoria-Docs\mff_review.md` — supporting docs like this (also `fable_review.md`, `debugger_fragility_audit.md`, etc.) live outside the git repo, on a shared drive (pCloud, mapped as `P:\Astoria-Docs` on both machines) rather than in `Documents/` locally — so a `git pull` won't bring them (never tracked), but no manual copying is needed either, since the path is identical and already synced on both computers. The actionable task list is embedded inline in Open Items (self-contained: each task has file:line + fix); read the full doc at that path for findings/framing. **MFF next steps:** **T0 is now RESOLVED (owner 2026-07-12): MFF is a separately-maintained fork, no upstream sync, everything published on GitHub — so fix it freely in place** (the `UPSTREAM.md`-pin idea is dropped as pointless with no sync relationship). The *only* residual T0 sub-decision is internal — **and the droppable surface is much smaller than "150 files" (that early figure wrongly counted transitively-required infrastructure).** Dependency analysis (2026-07-12): of ~98 control modules, ~55 are directly used and **most of the rest are foundational types the used controls depend on transitively — NOT droppable** (`Integer`/`Sys`/`Control`/`Object`/`Font`/`Brush`/`UString`/`List`/`Bitmap`/`Pen`/`Cursor`/`Component`/etc., each referenced by dozens-to-hundreds of other mff files; dropping any breaks the build). The genuinely-droppable set is **~15–20 standalone *widgets*** the IDE never instantiates. Recommendation: since MFF is now owned, keeping an unused widget is cheap (DLL size + compile time only, no maintenance burden), so **keep the form-building staples for future expansion** — `Chart`, `Grid`/`GridData`, `DateTimePicker`, `MonthCalendar`, `NotifyIcon` (classic VB-style widgets the target audience expects) plus the situational ones (`WebBrowser`, `IPAddress`, `Header`, `HScrollBar`/`VScrollBar`, `PageScroller`, `SystemInformation`; note `PrintDocument` is already lightly wired into the IDE's own print path). **Actively drop only** `HTTPServer` (security liability + niche — kills the F-N* class) and clear legacy cruft (`ListItemsOld`, `Animate`). Keep the HTTP *client* (used by the IDE). Decide before starting the F-N* tasks. **Highest-value fix is T-OPUS-1** — the `ThreadsEnter`/`ThreadsLeave` no-op stub, root cause of the DR-3/DR-7 class, helps the IDE itself. **Owner asked whether a deeper MFF review is warranted — Fable's answer: yes, and more clearly so now that MFF is owned code (the earlier "might re-sync from upstream, don't over-invest" hedge is void).** Still scope it, though — not a 200-file audit: a *targeted* Opus deep-pass on the ~6–8 hot-path core files only — `Control.bas`, `Form.bas`, `Canvas.bas`, the `WndProc`/message dispatch, and the GDI create/select/delete/restore lifecycle across `Canvas`/`Bitmap` (where an undiscovered bug would hurt the IDE itself, and where the unconfirmed GDI-handle-leak suspicion F-R-gdi lives). Bounded ~half-session. **Remember: any MFF source edit needs a `mff64.dll` rebuild (`FORCE_MFF=1`) to take effect.**
>
> **Session status (2026-07-12, continued on the Intel machine after the handoff above).** DR-16(a) — the last open item from the prior handoff — is now **done and owner-verified** (see table + status-at-a-glance). **All debugger-reliability defects opened this sub-project (DR-1 through DR-16) are now closed.** Phase 4's two flagged dead-code items (`kill_debug()`, `line_highlight`'s unreachable branch) are also **now removed** (`90f4dc7`+`64ea0ed`) — owner explicitly asked for another Phase 4 pass after confirming it was the only remaining Fable-review-list work (verified: yes, modulo two/three deferred owner-decision questions that are separate from Phase 4, see Open Items). Also flagged this session, not yet actioned: a pre-existing gap in the non-debug `RunProgram`/`RunPr` path (no missing-exe check, unrelated to DR-16a) and two owner UX requests (consolidate the Run menu, audit toolbar tooltips) — all logged under [Open Items](#open-items) → Immediate. **The one Phase 4 item still open is a bigger judgment call, not mechanical: the instrumentation-strip pass** — remove `bDbgTrace`/the remaining `DbgTrace` calls sprinkled through `Debug.bas` (writepipe/readpipe, worker-loop branches, `line_hl` parse, `EC.Breakpoint`/`EC.Paint` paint state, `Close.enter`, etc.) now that the sub-project's behavioral work is fully done. Deliberately not done automatically this session — stripping trace instrumentation is harder to undo than adding it (if a new regression surfaces, the trace has to be rebuilt from scratch), so get an explicit owner go-ahead before doing it, rather than treating "Phase 4 pass" as an automatic license to strip everything. **⚑ Gotchas (still apply):** (1) **rebuild + commit a RELEASE exe (`Compile.bat`) after every debugger-behavior source fix, immediately** — a prior session lost time when debug-build verification runs left the tracked exe stale relative to source; every fix this session was release-rebuilt before committing, keep doing that. (2) `UseDebugger=false` in `astoria.ini` is STALE (written only on clean exit) — the live Run ▸ Use Debugger toggle is what counts. (3) A program with **no bound breakpoint runs to exit** (DR-8 removed break-at-entry); breakpoints on **comment lines** don't bind. (4) Trace logs are git-ignored/local-only — each machine accumulates its own. (5) Source files have MIXED line endings (LF-only lines inside CRLF files) — use byte-precise single-line `Edit` anchors, never large multiline string matches. (6) **NEW: if Claude launches `astoria.exe` for you via a script/automation, click the window once before testing anything** — Windows blocks a background-launched process from getting true foreground focus, and an unfocused window can produce misleading "regression" symptoms (this session chased a false DR-4/close-bug "reversion" for a while before finding this — see the status-at-a-glance entry above for the full story).

**Last updated:** 2026-07-12 (AMD-machine session close) — **Fable review remediation CLOSED and archived.** All tasks T1–T17 done and the owner smoke-test list completed; the full task table now lives in [HISTORY.md](HISTORY.md) (T14 archival), with a summary stub of the load-bearing outcomes below. Highlights: T1 owner decision **Option B — per-user install** (portable model kept, **§13.5 unblocked**); Wave 3 robustness fixes committed individually; T16's 3 findings fixed; T5 GDB-path quoting owner-verified against a spaced path; T15 themes curated 96 → 10 (`9c18bd8`); the owner-found shared-`frmPath` `ModalResult` bug (silently breaking every "Add" dialog) fixed (`7a0c829`); Step Out promoted to the top-level Run menu with clarifying step tooltips. **Debugger work is now its own active sub-project** — see [⭐ ACTIVE SUB-PROJECT — Debugger Reliability](#-active-sub-project--debugger-reliability-queued-2026-07-11) (DR-1..DR-5). Full dated session-by-session narrative is archived in [HISTORY.md](HISTORY.md).

**Repository:** [github.com/dmontaine/astoria-ide](https://github.com/dmontaine/astoria-ide) (renamed lowercase 2026-07-10, following the AstoriaIDE rebrand — GitHub redirects the old `Astoria-IDE` URL; Codeberg retired 2026-07-09 — see below)  
**Local path:** `C:\Users\don\Astoria-IDE`  
**Owner:** bigriverguy (`dmontaine@gmail.com`)

This document captures project history, completed work, open items, and workflow rules for continuing development without re-discovering context. Detailed session-by-session narrative and completed sub-project write-ups are archived in [HISTORY.md](HISTORY.md); shipped work with commit hashes lives in [CHANGELOG.md](CHANGELOG.md).

---

## Current State (2026-07-10)

**The IDE compiles clean (0 errors, 0 warnings), runs stable, is renamed to AstoriaIDE, and is under active UX polish.**

| Area | Status |
|------|--------|
| **Core IDE** | Win64-only, compiles clean (0 errors, **0 warnings** as of `c93abbe`), self-hosted with bundled compiler (FBC 1.10.1) and GDB debugger |
| **Identity** | Renamed VisualFBEditor → **AstoriaIDE** (2026-07-10, `c93abbe`) — binary `astoria.exe`, settings `Settings/astoria.ini`, source/project files `AstoriaIDE.bas/.rc/.vfp`; see ROADMAP §13.4 |
| **Form Designer** | Working — grey-panel bug root-caused and fixed (2026-07-06); per-form control tree + PagePanel layer navigation shipped; Code/Form switching now via a top tab strip (`tcView`, 2026-07-10, `4b643af`), not toolbar toggle buttons |
| **Dark mode** | Stable and enabled — title bar, menus, toolbars, tabs, central area all render dark; popup menus deferred (§13.10) |
| **Dead code** | GTK/Linux/32-bit code physically deleted across `src/` and `mff/`; Integrated (stabs) debugger + alt-compiler backends removed; only `-gen gcc` remains |
| **UI review** | In progress — **File** menu owner-approved (incl. Open Project); **Edit** menu owner-approved (all 25 items); **Search** → Define (F2) reliability improved (committed with S1–S4); **13.3.A S1–S7 all Opus-reviewed and committed** (see §13.3.A execution below) — this already restructured the View menu (Fold submenu, Debug Windows split) as part of S1; **owner walkthrough/sign-off of the View menu** is the next step-by-step checkpoint |
| **Panels** | Left/right/bottom panel pin/collapse/persistence all fixed and verified |
| **Debugger** | GDB-only; core Step/Continue/Break/Step Out/queue/debug-tab show-hide functional, but a dedicated **[Debugger Reliability sub-project](#-active-sub-project--debugger-reliability-queued-2026-07-11)** is now open for known defects (DR-1/DR-10 breakpoint-arm-during-debug, DR-2 step no-highlight, DR-3 rapid-F8 hang — **DR-4 gutter-click blank is FIXED**, `b7af611`) |
| **Build** | `Compile.bat` for release, `CompileDebug.bat` for debug; `NOPAUSE=1` for agent runs; output is now `astoria.exe` |

**Active work:** **§13.3 step-by-step UI review — next up: owner sign-off on the View menu** (File + Edit already signed off; the View-menu restructuring itself shipped as part of 13.3.A S1, so this checkpoint is a walkthrough/approval, not new design work). This is the resumed backlog after the AI Agent subsystem removal completed.

**Recently closed:** the **Fable review remediation queue (T1–T17, queued and closed 2026-07-11)** — see "⭐ COMPLETED SUB-PROJECT — Fable review remediation" below for the outcome summary and the decisions that remain load-bearing (§13.5 unblocked, theme shortlist, deferred owner questions). The full execution-order table, T16 findings, per-model instructions, and the wave-by-wave progress narrative (including the Add External Tool / `frmPath` bug hunt) are archived in [HISTORY.md](HISTORY.md). **T6 and all further debugger work was extracted into the [Debugger Reliability sub-project](#-active-sub-project--debugger-reliability-queued-2026-07-11)** — the only piece of the remediation still open.

The **AI Agent subsystem removal** (owner decision, 2026-07-09 — see "⭐ COMPLETED SUB-PROJECT" below) is **DONE**: AI1–AI14 complete, compile-clean, committed (`924a814`) and pushed, Opus-reviewed (`7e9c228`) and owner-reviewed (2026-07-10). With it closed, the sequencing hold it placed on the rest of the backlog is lifted — the §13.3 View-menu review and the deferred Phase F structural items (low priority) are unblocked.

Prior to that: Opus's "Next Steps" review (`Next Steps - Opus.md`, 2026-07-07) evaluated three prior AI reviews against the actual source and produced a verified, sequenced backlog. **Every phase is done and committed, including R5 (bounded GDB read, done 2026-07-08) and E1 (Apply dirty-tracking, done in a background-task worktree and merged into `main` 2026-07-08)** — see below. 13.3.A S1–S7 are **all committed** (Opus-reviewed). A Run-toolbar persistence regression the owner found post-S4 (my own S3 migration latching Run permanently visible) was root-caused and fixed 2026-07-07 — see the S5–S7 review outcome below.  
**Open items consolidated:** see [Open Items](#open-items) below.

---

## ⭐ COMPLETED SUB-PROJECT — Fable review remediation (2026-07-11)

**DONE and CLOSED (2026-07-11, same day it was queued).** All 17 tasks from Fable's full-project review (`P:\Astoria-Docs\fable_review.md`) are complete, and the accumulated owner smoke-test list was completed with every finding dispositioned. The full execution-order table (T1–T17 with per-task detail and commit hashes), the T16 adversarial-review findings (3, all fixed) and its five standing no-action notes (N1–N5 — pre-existing/accepted behaviors that future tool- and debugger-work should know about), and the per-model instructions are archived in [HISTORY.md](HISTORY.md) §"Fable review remediation sub-project — full task table".

**Outcomes that remain load-bearing for future work:**
- **T1 owner decision (Option B — per-user install):** portable model kept, everything stays under `ExePath`; the §13.5 installer targets `{localappdata}\Programs\AstoriaIDE` (Inno Setup, `PrivilegesRequired=lowest`, VS Code user-installer style) plus a portable-zip artifact; no APPDATA migration. T2a's startup writability probe guards mis-placed installs. **§13.5 is unblocked.** Memo: `P:\Astoria-Docs\fable_t1_settings_location.md`.
- **T15 owner decision (Option B — curated shortlist):** shipped editor themes cut 96 → 10 (`9c18bd8`); shipped default reset to `CurrentTheme=Default Theme`. Memo: `P:\Astoria-Docs\fable_t15_theme_catalog.md`. **⏳ RE-CURATION IN PROGRESS (2026-07-11):** owner didn't want the auto-picked 10 and will choose their own set. **All 96 originals have been temporarily re-committed to `Settings/Themes/`** (restored from `9c18bd8^`) so the owner can browse/preview them live in Options ▸ Themes — see the Open Item. Next session: owner names their picks → re-curate (keep those, `git rm` the rest), and point `CurrentTheme` at a kept theme.
- **T6 was extracted, not finished:** all debugger work continues in the [Debugger Reliability sub-project](#-active-sub-project--debugger-reliability-queued-2026-07-11) (DR-1..DR-5) — the only part of the review's remediation still open.
- **Deferred owner questions recorded in Open Items:** `<Project>_Change.log` location; default `ProjectsPath` → Documents; decouple user color-tweaks from shipped theme files (T15 memo, fact 5); the "is External Editors actually removed?" audit.
- An owner-found **"Add" dialog bug** surfaced during the smoke tests (shared `frmPath`'s `Form_Close` clobbered `ModalResult` on every close, silently breaking every Add flow) — root-caused and fixed the same day (`7a0c829`).

---

## ⭐ ACTIVE SUB-PROJECT — Debugger Reliability (queued 2026-07-11)

**Why this exists as its own sub-project.** T6 (the `set_bp` pipe race) started as one Fable-remediation task in Wave 4. Owner live-testing of the attempt-#2 fix surfaced **three more debugger defects**, each with a different root cause and none caused by the `set_bp` change. That makes the debugger a reliability effort in its own right, not a single bug — so it's extracted from the Fable queue and tracked here. **Fable Wave 4 is now: T5 done (owner-verified); T6 and all further debugger work moved here.** With this out, the Fable queue's only remaining items are T15 (theme-catalog memo) and the accumulated owner smoke-test list.

**Owner's framing (2026-07-11):** the debugger "is going to take a lot of work to make it reliable." Treat this as an open-ended reliability pass, not a fixed checklist — the defect table below is what's *known so far*, expected to grow as tracing exposes more.

**Standing rules (fragile-core bar — carried over from the T6 charter, non-negotiable):**
1. **Instrument-first.** Add focused file-trace, have the owner reproduce, read the actual interleaving, *then* fix. T6 attempt #1 hard-locked precisely because it changed the worker loop on a static guess.
2. **Live-verify with the owner on every fix.** No debugger fix is DONE on compile-clean alone — the owner runs the repro. (This session has no GUI access.)
3. **Do NOT reorder or restructure the GDB worker loop without a confirming trace.**
4. §9 gates otherwise: smallest correct diff, matching style, per-task commit after owner verify.

### Known defects

| ID | Defect | Symptom | Root-cause status | Path / notes |
|---|---|---|---|---|
| **DR-1** | `set_bp` pipe race (was **T6**) | F9 breakpoint mid-session can race the worker thread on the shared pipe; also plants phantom GDB breakpoints on comment lines | attempt #2 code written, compile-clean. **Partial live obs (2026-07-11, obs #6):** menu Run ▸ Toggle Breakpoint *did* reach `set_bp` (armed `break frmBrowser.frm:452` on the UI thread, `Running=false`, worker idle) — no immediate race when the worker is idle. Full checklist (hit the bp; comment-line refusal; toggle-off) **still incomplete** — the session wedged via DR-3 desync before we could see it. Reached only via menu (F9/gutter bypass = DR-10; toolbar dead = DR-12). | **✅ FIXED via slice 2C (owner-verified 2026-07-12).** `arm_breakpoint` (`Debug.bas`) enqueues break/clear/tbreak; the worker applies them in its lockstep loop (`LOOP.armbp`), so the UI thread never touches the pipe — the race is no longer expressible. `set_bp` is now dead (Phase 4 delete). |
| **DR-2** | Step-Into no-highlight (**BUG A**) | A single deliberate Step Into does not scroll to or highlight the current line; even manual scroll shows no highlight; later steps also don't highlight | **not root-caused — needs trace** | worker sets `fcurlig` in `line_highlight` (`Debug.bas:765`, forced `-2` at `:2134`); UI-thread `TimerProcGDB` (`Main.bas:3028`) reads it → `SetSelection`/`CurExecutedLine`/`PaintControl`. Neither scroll nor paint happens. §7 lists this as owner-verified-working in an earlier build → possible **regression**. |
| **DR-3** | Rapid-F8 hang (**BUG B**) | Mashed/held Step Into freezes the app | root-caused **statically**: worker dequeues + sends a new command while `Running=True` (`Debug.bas:2056`–2069), so back-to-back `s` sends desync the read stream — `RefreshDebugPanelsAfterStop` (`:1986`) reads leftover step annotations instead of its own responses → a later `readpipe` blocks forever. **⚠️ TRACE OVERTURNS THIS (2026-07-11, obs #4).** Hang reproduced; worker froze *after* the `_l_` (locals) `readpipe` returned successfully — it never wrote the next command. Every pipe read was satisfied, so the freeze is **not** a read desync. Real block: `get_read_data(3)` (`Debug.bas:1962`) does `readpipe → ThreadsEnter → fill_locals_variables (UI work, unmarshaled) → ThreadsLeave`; the worker deadlocks in `ThreadsEnter`/`fill_locals_variables` while the UI thread (trace: `ENQ cmd=s` at the *same tick* the refresh began) also wants `ThreadsEnter`. **DR-3 is a DR-7 deadlock** (worker mutates UI + holds a lock), aggravated by the off-thread `Updateinfox` `DoEvents ×101`. Aggravator: stopped deep in GDI+ (`CANVAS.BAS:1436`, 8 threads) makes refresh slow → wide race window. **⚠️⚠️ SECOND HANG MODE CONFIRMED (2026-07-11, obs #6) — the original stream-desync IS real too.** Trace caught the exact loop bug: worker loop ([`Debug.bas:2095`](src/Debug.bas:2095)) priority is **send (A) → pendingRefresh (B) → readStop (C)**. When `bPendingDebugPanelRefresh` (set by the UI thread's `TimerProcGDB` after the *previous* stop) is still set as the next step is sent, the loop runs branch **(B) before (C)** — `RefreshDebugPanelsAfterStop`'s `_l_` read swallows the just-sent step's stop annotation (`BRUSH.BAS:18` + locals merged in one read), so the next `readpipe` blocks forever. Queued presses pile up (`ENQ count=1,2,3`), view never advances. So DR-3 has **two** hang modes (deadlock + desync), both from the non-lockstep loop. | **✅ FULLY FIXED — 2A + 2D, both owner-verified.** **2A** (`1899513`): desync mode — gated the dequeue so a command is only pulled once the previous stop is read (`Not Running`) **and** refreshed (`Not bPendingDebugPanelRefresh`). **2D** (2026-07-11, uncommitted→committing): the deadlock mode — **root cause found: `ThreadsEnter`/`ThreadsLeave` are no-op stubs (`Component.bas:257`)**, so the worker's `fill_locals_variables`(→`lvLocals.Nodes.Clear/.Add`) raced the UI thread's `AddTab`. Fix: worker `RefreshDebugPanelsAfterStop` now **read-only** — sends the queries, stores raw replies (`gRawLocals`/`gRawGlobals`/`gRawThreads`/`gRawWatch`), sets `bPanelFillPending`; the UI-thread `TimerProcGDB` calls new `FillDebugPanelsOnUI` to parse+fill. Watches read a UI-maintained snapshot (`SnapshotWatchNames`) so the worker never touches `lvWatches`. Also removed the off-thread `Updateinfoxserver`/`DoEvents` (part-1, fixes DR-13). **No lock shared between threads** — worker owns the pipe, UI owns the controls. Owner: "works, no problems" (quick-F8 no longer freezes; panels+highlight intact). *Residual DR-7 (documented, lower-risk, not the freeze): `readpipe`→`ShowMessages` to Output + the worker-loop `UpdateWatch` on the watch-edit path — a follow-up slice.* |
| **DR-4** | ✅ **FIXED + owner-verified 2026-07-12 (Intel).** (Was: "split-view gutter blank, regressed, deferred.") | Gutter-click a breakpoint and text appears to disappear — actually the viewport **scrolls right**: short lines vanish off the left, long lines show only their tail. Only on the narrower (Intel) window. | **Old hypothesis DISPROVED (2026-07-12):** it is **NOT** `.frm` CodeAndForm-split-only and **NOT** theme-specific — it reproduces on a **plain single-pane `.bas`** (`Projects/Project3/Module1.bas`). So `PaintControl True` in `EditControl.Breakpoint` ([`EditControl.bas`](src/EditControl.bas:241)) simply is **not repainting the whole viewport** even in the simple single-pane case. Cosmetic/non-fatal (refocus restores). Not caused by the 2C `FECLine` capture change (that's a pure read added before the same `PaintControl True`). | **✅ ROOT-CAUSED + FIXED (2026-07-12, Intel; owner-verified + `HScrollPos=0` confirmed in trace).** NOT a paint/geometry bug at all (the `EC.Paint` trace proved geometry healthy & identical on every paint — no short `vlc1`). It's **horizontal scroll**: `WM_LBUTTONDOWN` sets the caret to **end-of-line** on a gutter/line-number click (`If X < LeftMargin Then FSelEndChar = Len(...)`, [`EditControl.bas`](src/EditControl.bas:6964) — the "click margin selects line" behavior), then `ScrollToCaret`→`ShowCaretPos True` h-scrolls to reveal that end. On a **narrow window** the end-of-line X exceeds `dwClientX`, so it scrolls right (short lines off-left, long lines tail-only); the wider AMD window fit the lines so it never scrolled — that's the whole "Intel-specific" story (window width, not GPU). The owner's own clue nailed it: clicking the *start* of a text line restored the view (caret→col 0 → `HScrollPos`→0). **Fix:** a gutter click is a breakpoint/line action and must not change the horizontal scroll — call `ShowCaretPos False` (updates the caret without the scroll block, gated by `If Scroll`) instead of `ScrollToCaret` when `X < LeftMargin`. Line-select still sets the caret to end-of-line; it just no longer yanks the viewport. `EC.Paint` instrumentation stripped now that DR-4 is closed. |
| **DR-5** | GDB response-timeout (deferred R5 follow-up) | A genuinely hung mid-session GDB has no timeout — the app waits indefinitely | deliberately deferred at R5 (risk of false positives on slow-but-legit GDB commands; needs a reproducible hang to tune) | `Debug.bas` `readpipe` — R5 added app-close/broken-pipe bail via `PeekNamedPipe`, but not a response-timeout. Low priority; revisit only with a reproducible hang. |
| **DR-6** | Stop/Kill debug races the worker + misuses the mutex (**new 2026-07-11, fragility audit**) | Pressing Stop/End mid-session can intermittently hang or crash | root-caused **statically** (crash/UB class): `kill_debug` (UI thread, `Debug.bas:2233`, from `AstoriaIDE.bas:314`) runs while the worker's read loop is live — (1) its `readpipe()` (`:2264`) races the worker on `hReadPipe`; (2) `deinit` closes `hReadPipe`/`hWritePipe` (`:2344`) possibly while the worker is mid-`ReadFile` → operate-on-closed-handle; (3) `deinit`'s `MutexUnlock tlockGDB` (`:2348`) unlocks a **non-owned** mutex on the kill path and **double-unlocks** on the worker `q` path | **Fold into DR-3's worker-loop rework** — both are "who owns the worker lifecycle + its lock." Fix: signalled worker shutdown + UI-thread join *before* closing handles; make `deinit`'s unlock ownership-correct. R5's `FormClosing` bail covers app-close, **not** Stop. See `P:\Astoria-Docs\debugger_fragility_audit.md` §A. |
| **DR-7** | Worker thread mutates UI without marshaling (**new 2026-07-11, fragility audit**) | Latent corruption/crash; also a live suspect for DR-2/DR-4's missed repaints | root-caused **statically** (rule-3 violations): (1) `readpipe`→`ShowMessages` (`:486`) writes `txtOutput`/`frmMain` from the worker on every stop-read (`ShowMessages` self-marshals nothing, `Main.bas:8716`); (2) `Updateinfoxserver(100)` (`:2140`) runs `pApp->DoEvents` ×101 **off-thread** — pumps the message loop from the worker (prime suspect for missed paints between `fcurlig` set and `TimerProcGDB`); (3) `RefreshDebugPanelsAfterStop` holds `ThreadsEnter` across blocking `readpipe` loops (`:1992`) → UI stall | **✅ FULLY FIXED (2026-07-12, `8ce74f2`, owner quick-tested).** 2D (2026-07-11) fixed (2) the off-thread `DoEvents` and the panel-fill half of (1)/(3). **This session closed the residual:** `readpipe`'s own `ShowMessages`, `run_debug`'s loop-body `ShowMessages` (4 sites), the watch-edit `UpdateWatch` call, and `load_file`'s session-start `lvLocals`/`lvGlobals.Nodes.Clear` + message all now stage data (`QueueShowMessages`/`gPendingWatchIndex`/`bClearVarPanelsPending`) instead of touching controls directly; new `FlushDebugOutputOnUI` (called from `TimerProcGDB`, mirrors `FillDebugPanelsOnUI`) applies it on the UI thread. **New residual found while tracing `deinit`'s call graph — see DR-16.** |
| **DR-8** | ✅ **FIXED + owner-verified (2026-07-11).** Was: debug start always broke at program entry, landing inside an `#include`d file | Starting a debug session stopped at the first executable statement — for a form app a module-level global initializer pulled in via `#include` (e.g. `Brush.bas:16`), *not* the user's own code. | root-caused statically (confirmed by trace): `run_debug` unconditionally sent `b 1\n` every launch → GDB broke at `main` entry, whose first source line is the include's module-init. | **Fix: removed the `b 1` break-at-entry** (`Debug.bas` ~2096). Debug now runs to the user's first breakpoint (or runs freely if none). Owner-verified. **Paired UX (owner request, same build, owner-verified):** (1) **close-on-stop** — debugger-auto-opened files (framework `#include`s not already open) are flagged `OpenedByDebugger` and closed when the session ends (`deinit`→`bCloseDebugTabsPending`→`TimerProcGDB`/`CloseDebuggerOpenedTabs`, UI thread; skips modified tabs); (2) **Close Project = clean slate** — `CloseProjectAndClean` closes the project + all remaining files and clears `Workspace.ini` so next launch starts clean (project reopens only if it was open at app close). |
| **DR-9** | Committed example binary carries stale cross-machine source paths (**new 2026-07-11, trace pass; environmental**) | First debug of `Examples/FileBrowser` used a committed `FileBrowser64.exe` built on the *other* machine (`C:\Users\dmont\VisualFBEditor\...`). GDB → `No such file or directory`, breakpoints rejected (`No source file named ...frmBrowser.frm`), no highlight. After a **local rebuild** (paths → `C:\Users\don\Astoria-IDE\...`) everything resolved and highlighting worked. | confirmed by trace (run 1 = dmont paths; runs 2–4 = don paths after rebuild). `FileBrowser64.exe` is **git-tracked** (`git ls-files` confirms). | Fix (hygiene): gitignore/remove committed example build artifacts (`*.exe`/`*.o` under `Examples/`) so stale cross-machine debug info can't mislead. Consider forcing a rebuild before Start Debugging. |
| **DR-10** | F9 and gutter-click bypass `set_bp` — mid-session breakpoints don't arm live (**new 2026-07-11, trace pass**) | Adding a breakpoint mid-session via **F9 or gutter-click** only sets the visual marker; the running program does **not** stop there. It silently takes effect on the *next* launch. Only the toolbar/menu "Toggle Breakpoint" arms it immediately. Three toggle paths, inconsistent behavior. | root-caused (trace: 0 `set_bp` calls in the whole session despite F9 + gutter use). Editor's own [`Case VK_F9`](src/EditControl.bas:6659) → `EditControl.Breakpoint` (marker-only) wins over the F9 menu accelerator; gutter-click ([`EditControl.bas:233`](src/EditControl.bas:233)) does the same. Both bypass the `Case "Breakpoint"` → `set_bp` handler ([`AstoriaIDE.bas:597`](src/AstoriaIDE.bas:597)) that arms during debug. | **✅ FIXED via slice 2C (owner-verified 2026-07-12).** All three toggle paths (F9, gutter, menu) now flow through `EditControl.Breakpoint` → `arm_breakpoint` (enqueue). **Two sub-bugs found here:** (a) `EditControl.Breakpoint` read `FECLine->Breakpoint` *after* `PaintControl` clobbered the shared `FECLine` member → arm-on always sent `clear` (captured into a local now); (b) `clear LINESPEC` never matches on this GDB → switched to `delete <N>` via a set-time number map (`BpMap*`). |
| **DR-13** | A **step press right after a stop is silently swallowed** (**new 2026-07-11, owner-found + trace**) | Stopped at entry; a quick F8 "did nothing"; a later, deliberate F8 stepped. Trace: **only 1 `ENQ`/`LOOP.send` for 2 intended steps** — the lost press never reached `step_debug` (no `ENQ`, no `ENQ.DROP`, and `EnqueueDebugCommand` would *block* on `tlockGDB`, not drop — so the keypress itself was lost, not the enqueue). | root-caused (trace): the off-thread **`Updateinfoxserver` `DoEvents ×101` on the worker thread** ([`Debug.bas:2140`](src/Debug.bas:2140)) fires at every stop (`[Updateinfox]` in trace). Pumping the message queue from the worker dispatches the pending F8 `WM_KEYDOWN` **without the main loop's `TranslateAccelerator`**, so it never becomes the "StepInto" command — swallowed. The later F8 (~112k ticks on, worker idle) went through the normal loop and worked. **(NOT the `UseDebugger` toggle — that was ON; the on-disk `astoria.ini UseDebugger=false` is just stale, written only on clean exit.)** | **✅ FIXED (2026-07-11, slice 2D part-1, owner-verified)** — removed the off-thread `Updateinfoxserver`/`DoEvents` at the stop (`Debug.bas`), so the post-stop keypress is no longer dispatched untranslated. Note: removing it *alone* unmasked DR-3's deadlock (froze instead of swallowed); the 2D worker→UI marshal (part-2) was needed alongside. Combined = fixed. |
| **DR-14** | Worker **hangs refreshing debug panels against an exited/never-running inferior** (**new 2026-07-11, owner-found + trace, during DR-6/2B repro**) | Started FileBrowser under the debugger while a prior instance's window was still open → the new inferior **exited immediately** (`[Thread … exited with code 1]`; `info inferiors` → `* 1 <null>`). Worker (RTFRUN) sent `c` → GDB `"The program is not being run."` → worker treated it as a normal stop → `LOOP.refresh` sent `_l_`/`thread apply all bt` **against the dead program** → read desync/block → **IDE locked** (trace ends mid-read). | root-caused (trace `debug_trace.log`, 2026-07-11): the worker loop doesn't detect inferior-exit. After `r`/`c` returns "not being run" (or an `[Inferior … exited]`/`<null>` connection), it still runs `line_highlight`→`bPendingDebugPanelRefresh`→`RefreshDebugPanelsAfterStop` ([`Debug.bas`](src/Debug.bas:2159)), which queries a dead program and blocks. | **✅ FIXED via slice 2B (`0f30654`) + RESIDUAL fixed 2026-07-12 (slice 2C session).** 2B detected `[Inferior ` / `not being run`. But a plain console app (`Module1.exe`) exits with `Program exited...` / `info inferiors` → `* 1 <null>`, which slipped past that check → the DR-14 hang recurred. Now the worker also bails when `info inferiors` shows **no live process** (the reliable signal, in the `bGetPid` block) and on the `Program exited` string. Owner-verified 2026-07-12. |
| **DR-12** | Toolbar "Toggle Breakpoint" button is **dead** (**new 2026-07-11, owner-found**) | Clicking the toolbar Toggle-Breakpoint icon does nothing — no marker appears, no `set_bp`. The Run ▸ Toggle Breakpoint **menu** item works. | root-caused (owner repro + code): the toolbar button dispatches command `"ToggleBreakpoint"` ([`Main.bas:6524`](src/Main.bas:6524)) but there is **no `Case "ToggleBreakpoint"`** handler — the only handler is `Case "Breakpoint"` ([`AstoriaIDE.bas:597`](src/AstoriaIDE.bas:597)), which is the *menu's* command ([`Main.bas:6293`](src/Main.bas:6293)). Command-name mismatch → dead button, always (not debug-specific). | **Trivial fix:** change the toolbar command string `"ToggleBreakpoint"` → `"Breakpoint"` at `Main.bas:6524`. Sharpens DR-10: the *only* working path to `set_bp` is the **menu** (toolbar dead, F9/gutter bypass it). |
| **DR-11** | ✅ **RESOLVED — no longer reproducible (owner-verified 2026-07-11).** Was: closing a project froze the IDE when a non-project ("standalone") file was open | Originally: owner force-killed a frozen app, **relaunched**; workspace-restore reopened the project *and* `Brush.bas` (a framework `#include` the debugger had auto-opened — see DR-8). Closing the project **froze** — deterministically (2/2). **Re-test 2026-07-11 (post-DR-3-fix, exact original setup incl. relaunch/restore): did NOT freeze — 3 clean `CloseProject` runs all reached `CloseProj.done`; project closed, `Brush.bas` correctly kept.** | **Root cause: almost certainly a downstream symptom of DR-3.** The original chain was DR-3 froze the app mid-debug → owner **force-killed** it → force-kill left the workspace/session file corrupt → workspace-restore rebuilt a bad tree (cyclic/null parentage) → `CloseProject` hung (candidate ① below). With DR-3 fixed there is no mid-debug freeze, so no force-kill, so no corrupt workspace — trace confirms the restored `SelChange` nodes now show `tag=0` and take the safe path. **No code fix needed; resolved by fixing DR-3.** *Static analysis retained below for the record / in case it ever recurs.* 9 `DbgTrace` markers added through `CloseProject` teardown + `tvExplorer_SelChange` in `src/Main.bas` (committed as temporary instrumentation, same convention as the GDB trace build). **Static analysis (2026-07-11, Opus — read-only, no code changed) ranked the candidates and mapped each to the last-seen trace marker:** ① **`NodeInProject` unbounded parent-walk** ([`Main.bas:2646`](src/Main.bas:2646): `Do While n<>0 : n=n->ParentNode`) — a cyclic/self-referential `ParentNode` on the restored standalone-file node loops **forever** (deterministic hang, exactly fits "non-project file open"). Called at [`:2741`](src/Main.bas:2741) (tab-close loop) and [`:2756`](src/Main.bas:2756) (safety pass). **Tell: freeze with last marker `CloseProj.enter` (→ tab-close-loop NodeInProject) or `CloseProj.tabsClosed` (→ safety-pass NodeInProject), no `SelChange.*`.** ② **`Nodes.Remove` ([`:2820`](src/Main.bas:2820)) → `tvExplorer_SelChange` → `OpenTreeNodeOnSingleClick` ([`:7099`](src/Main.bas:7099))** — weaker than the banner assumed: `OpenTreeNodeOnSingleClick` early-exits on a null Tag ([`:7014`](src/Main.bas:7014), and CloseProject nulls all Tags first) and acts on **tabs**, not tree selection, so it doesn't obviously re-fire `SelChange`. **Tell: last marker `beforeNodesRemove` then `SelChange.enter/beforeOpen` with no `afterOpen`.** Ruled out: the tab-close `Do…Loop While bClosedTab` ([`:2735`](src/Main.bas:2735)) — `CloseTab` genuinely `_Delete`s the tab ([`TabWindow.bas:1018`](src/TabWindow.bas:1018)), so it terminates. | **Leading hypothesis: ① `NodeInProject` cyclic-chain hang.** Repro (owner): open FileBrowser project with a non-project file open (e.g. `Brush.bas`), close the project, force-kill on freeze, read `Settings\debug_trace.log`'s **last `CloseProj.*`/`SelChange.*` line** — that single line picks ① vs ②. **Candidate fix (pending trace confirm, do NOT apply blind):** if ①, add a depth cap to `NodeInProject`'s walk (hang-proof + harmless) *and* fix whatever produces the cyclic parentage on restore; if ②, guard `tvExplorer_SelChange` against re-entry / skip `OpenTreeNodeOnSingleClick` during a project close. A project close should safely keep non-project tabs regardless. |
| **DR-15** | ✅ **FIXED + owner-verified (2026-07-12, `57007dc`).** Orphaned `astoria.exe`/debuggee process survives closing the IDE mid-debug-session | Owner observation (2026-07-12): closed the IDE while a debug session was active — the window closed but the debuggee (and its GDB session) kept running, an `astoria.exe` process lingered and blocked a rebuild. | **First hypothesis (no debugger teardown in `frmMain_Close`) was WRONG — corrected by the trace, a good instrument-first example.** `CloseAllDocuments` ([`Main.bas:2058`](src/Main.bas:2058)) already enqueued `q` on close. Real cause: **GDB does not act on stdin (incl. `q`) while the inferior is running freely** in synchronous all-stop mode — the same quirk already fixed for the Stop button in DR-6/2B. The queued `q` sat unprocessed; `deinit`'s bare `writepipe "q\n"` + close-handles never reached a GDB that wasn't listening → debuggee orphaned. Reproduced on the **AMD machine** (not graphics-dependent, unlike DR-4) once running-freely (no breakpoint) was tested specifically — stopped-at-breakpoint closes were already fine, which is why the first quick test looked clean. | **Fix:** `CloseAllDocuments` now calls `If Running Then kill_inferior_process()` before enqueueing `q` — mirrors the already-proven `Case "End"` Stop-button logic (`AstoriaIDE.bas` ~312). `kill_inferior_process` is race-free (plain `TerminateProcess` on the tracked PID). Owner-verified both scenarios (stopped-at-breakpoint, running-freely) close cleanly — no lingering `astoria.exe`/`gdb.exe`/debuggee. **Gotcha hit during verify:** the committed release `astoria.exe` wasn't rebuilt after the source fix landed (debug-build verification runs restored the old tracked exe each time) — owner briefly saw the pre-fix behavior return on a stale binary, not a regression; rebuilding+committing a release exe resolved it (`07ea740`). **Residual, NOT blocking, no code fix attempted:** a couple of orphaned `Console Window Host` (`conhost.exe`) processes remain after force-killing a console debuggee — known low-severity Windows artifact of `TerminateProcess` vs a normal exit; doesn't lock files or block rebuilds. |
| **DR-16** | Residual worker-thread UI touches found while tracing `deinit`'s call graph during the DR-7 fix (**new 2026-07-12**) | Two more instances of the DR-7/DR-3 hazard class (worker touches a UI control directly; `ThreadsEnter`/`ThreadsLeave` are no-ops) — neither has an observed symptom (like DR-7's residual, lower-risk) but both are genuine unmarshaled races. | (a) `load_file` ([`Debug.bas`](src/Debug.bas)) calls a **blocking modal `MsgBox`** directly from the worker thread ("could not find program to debug"). (b) `deinit()` — called from the worker on every session-end path — calls `ChangeEnabledDebug` (14+ toolbar/menu `.Enabled` writes) and `DeleteDebugCursor` (calls `.Repaint` on a control) directly. Re-audited `deinit`'s full call graph before fixing (per the standing instruction): confirmed `deinit()` has exactly **two live callers, both on the worker thread** inside `run_debug`'s loop (the `'q'`-dequeue branch and the `LOOP.inferiorGone` branch) — no UI-thread caller exists. **Two more call sites were dead code, found during the audit:** `kill_debug()` had zero real callers anywhere (orphaned since the DR-6/2B rework), and `line_highlight`'s own legacy `"[Inferior 1"` branch (→`paste_updatevar`→`deinit`) was unreachable — `run_debug`'s loop already intercepts `"[Inferior "` upstream (the DR-14 branch) before `line_highlight` is ever called with that data. **✅ Both removed 2026-07-12 (`90f4dc7`+`64ea0ed`)** — re-verified before removal (also confirmed `get_read_data`'s own `Case 1` that calls `line_highlight` is itself dead, never invoked with `iFlag=1` by any of its 3 live call sites), compile-clean, no behavioral change (pure unreachable-code removal, not runtime-tested). | **(b) ✅ FIXED (2026-07-12, Sonnet).** Same stage-then-flush pattern as DR-7: new `bDeinitCleanupPending` flag, set by `deinit()` instead of calling `DeleteDebugCursor`/`ChangeEnabledDebug` directly; `FlushDebugOutputOnUI` (UI thread, ticks via `TimerProcGDB`) applies both, same order preserved. Compiles clean; no observed symptom before or after (preventive fix, matches DR-7's residual class) — release-rebuilt and committed. **(a) ✅ FIXED + owner-verified (2026-07-12, `600a8c7`+`91b054f`).** Owner design decision: fix properly, not defer — widened scope beyond the original finding when tracing what a UI-thread pre-check would need turned up a second, previously-unflagged instance of the same hazard: `GetMainFile()` (needed to compute the exe path) has its own side effect (conditional scratch-save of an unsaved modified tab) *and* its own embedded `MsgBox` ("Project Main File don't set"), called from `RunProgramWithDebug` on the worker thread. New `PrepareDebugSession()` runs on the UI thread before all 5 `ThreadCreate_(@StartDebugging)` sites (Start/Continue, StepInto, StepOver, StepOut, Run to Cursor): calls `GetMainFile`/`GetFirstCompileLine` exactly once (audited — `GetExeFileName`/`GetFolderName`/`Replace` are pure, safe on either thread), stages the results, runs both existence checks. `load_file`'s own checks kept as a defensive fallback, downgraded to non-blocking `QueueShowMessages`. Deliberately NOT covering `StartDebuggingWithCompile` (F5) — the exe doesn't exist yet at that call site, so the check doesn't apply the same way; flagged, not fixed. Owner-verified: happy path (Ctrl+F5, exe present) unchanged; error path (Ctrl+F5, exe deleted) shows the message immediately, before any worker thread spins up. **DR-16 fully closed.** |

### First repro-pass findings (2026-07-11, owner obs #1–#3 of 5)

Owner ran the instrumented build against `Examples/FileBrowser`; `Settings\debug_trace.log` (536 lines, this machine — **not git-synced**) analyzed for observations #1–#3. #4 (F8 hang) and #5 (Stop/End) still pending.

- **Obs #1 "stops at line 16 of brush.bas"** → **DR-8 + DR-9** (above), *not* a transport bug. The always-on `b 1` entry break + first step landing in the include's module-init, compounded in run 1 by the stale committed exe.
- **Obs #2 "gutter-click blanks lines in `.frm` but not `.bas`"** → **reframes DR-4.** Trace *disproves* the old "executed-line paint branch" theory: every `.frm` gutter-click fired with `CurExecutedLine=-1` (executed-line state empty). Real mechanism: [`EditControl.Breakpoint`](src/EditControl.bas:241) calls the **partial** `PaintControl`; the partial-paint skip in [`PaintControlPriv` ~4295](src/EditControl.bas:4295) leaves lines cleared-but-not-redrawn. **Owner refinement (2026-07-11): it's specific to the `.frm` *CodeAndForm* (split) view, NOT the Form-only view** — the `.frm` view modes are Code / Form / CodeAndForm ([AstoriaIDE.bas:341](src/AstoriaIDE.bas:341)), and CodeAndForm puts the editor in a **divided** layout (`bDividedX`/`bDividedY`). The partial-repaint skip's own divided-layout branch (`bDividedX AndAlso zz = 0` in the rect calc at [4306](src/EditControl.bas:4306)) is the suspect; a single-pane `.bas` (or Code-only view) survives the skip. **DR-4 is decoupled from the GDB transport work** — pure editor paint. **✅ FIXED + owner-verified 2026-07-11** (`b7af611`): forced full repaint (`PaintControl True`) in `EditControl.Breakpoint`. Owner: "Set breakpoint using gutter works. Editor lines no longer disappear."
- **Obs #3 "adding breakpoint while debugging works, no hang"** → **DR-10** (above). No hang is real, but F9/gutter never touched `set_bp`, so DR-1's race was *not* exercised and the breakpoints didn't arm mid-session (trace: sent on the next `r` instead). To actually test DR-1, arm via the **toolbar/menu** "Toggle Breakpoint" while stopped.
- **Obs #4 "repeated F8 → program hung"** → **reframes DR-3 as a DR-7 deadlock** (detail in the DR-3 row). Worker froze after the locals `readpipe` returned — *not* a read desync; it deadlocked in `ThreadsEnter`/`fill_locals_variables` (unmarshaled UI work while holding the lock) against the UI thread enqueuing the next step at the same tick. **Fix = 2D (marshal) first, then 2A.** Repro aggravated by stopping deep in GDI+ (`CANVAS.BAS:1436`, 8 threads → slow refresh, wide window).
- **Obs #5 "Stop from Debug menu, stopped + running"** → **DR-6 NOT exercised (both took the safe path).** `Case "End"` ([AstoriaIDE.bas:312](src/AstoriaIDE.bas:312)) calls the dangerous `kill_debug()` **only when `Running=True`**; otherwise `command_debug "q"` (safe enqueue). Both repros had `Running=False` at Stop-time (stopped at entry/breakpoint), so the worker dequeued `q` and ran `deinit` **on itself** (tids 14552/16408, not the UI thread) — clean, no hang/crash, relaunched fine. `kill_debug.terminate` never appears in the trace. **To actually test DR-6: Continue until the program runs freely (window responsive, past all breakpoints), *then* Stop.** Bonus: the `If Running` check is racy (repro B: `Running` flipped to true on the worker at the same tick the UI thread had already taken the `q` branch) — reinforces 2B (signalled shutdown + join). `deinit`'s `MutexUnlock tlockGDB` ([Debug.bas:2391](src/Debug.bas:2391)) double-unlock on the `q`-path remains latent (didn't crash here).
- **Bonus:** **DR-2 (step no-highlight) did NOT reproduce** in the rebuilt runs — `Timer.act ... branch=highlight` fired correctly on `Brush.bas:16/17`. Narrows DR-2 to conditions not hit here (possibly only the stale-exe/no-source case, i.e. downstream of DR-9).

### Target architecture — `GdbSession` (single-owner transport)

**The invariant:** exactly one thread (the debug worker) ever touches the GDB pipe (`hReadPipe`/`hWritePipe`). Every other caller — `set_bp`, `break_debug`, `kill_debug`, watches, set-value, step/continue — *posts* a command to the queue and receives results via a **marshaled** callback. The worker owns the pipe's whole lifecycle: it is the only reader/writer, and the only thing that closes the handles, on its own signalled exit. `tlockGDB` protects only the queue, never pipe I/O.

**Why this is the fix, not a patch:** DR-1/3/6/7 are four symptoms of one missing property — no single owner of the pipe + ad-hoc locking. The invariant dissolves them as a class:
- **DR-1** — `set_bp` enqueues a break/clear instead of touching the pipe → no shared-handle race is even expressible.
- **DR-3** — the worker reads one command's full stop + refreshes panels *before* dequeuing the next → strict lockstep is inherent, not bolted on.
- **DR-6** — Stop enqueues a quit / sets a stop flag; the worker leaves its loop and does its *own* cleanup; the UI thread joins it *before* anything closes → no read-vs-close race, and no cross-thread `MutexUnlock` (the worker unlocks only what it locked).
- **DR-7** — the worker never calls `ShowMessages`/`DoEvents` directly; it posts output/panel/highlight updates to the UI thread → rule-3 clean; the off-thread `DoEvents` is deleted.

**Scope guard (why this isn't the "rewrite the whole thing" that was ruled out):** this replaces **only the transport/threading layer**. The GDB *protocol* (CLI + `\x1a\x1a` annotations) and all *parsing/panels/UI* (variables, threads, watches, the `fcurlig`→`TimerProcGDB` highlight) are **kept** — they work and are owner-verified (R5). The command surface (`step_debug`/`continue_debug`/`set_bp`/panel calls) keeps its signatures, so the rewrite is verifiable **in slices against the current known-good behaviour**, not as a big-bang. Whether `GdbSession` ends as a formal encapsulated type or as the invariant enforced over the existing subs is a shape call made as it firms up — the value is the invariant. (A later, *separate* phase could switch the protocol to **GDB/MI**, which would retire the annotation parsing and the `"(gdb) "` string-scan; explicitly out of scope here.)

### Plan (instrument-first, `GdbSession`-centered)

- **Phase 0 — fragility audit (DONE 2026-07-11, Opus).** Broad static read of the whole subsystem before instrumenting — report at `P:\Astoria-Docs\debugger_fragility_audit.md`. Surfaced DR-6 and DR-7 (above) plus a robustness list (`CreatePipeD` ignores all launch failures; `writepipe` ignores `WriteFile`; `EnqueueDebugCommand` silently drops when the 32-slot queue is full; `load_file` implicit-return-on-success) and a dead-code inventory (the ~165-line `timer_data` is never called; `hard_closing` unreachable; a 5 MB `sourcebuf` + the whole integrated/stabs state block is vestigial; pervasive commented cruft; dead `iTime` params). Dead-code sweep deferred to a separate mechanical pass *after* the behavioural fixes land.
- **Phase 1 — one trace pass. ⏳ INSTRUMENTATION DONE + COMMITTED; FIRST REPRO PASS DONE 2026-07-11 (Opus) — all 5 obs analyzed (see "First repro-pass findings" below). Net: DR-3 reframed as a DR-7 deadlock (2D before 2A); DR-4 decoupled (editor paint, 1-line candidate fix); DR-1 reshaped (DR-10 — F9/gutter bypass `set_bp`); DR-2 didn't repro; DR-6 not yet exercised (needs Stop-while-running-freely). New: DR-8/9/10. **Next: a targeted second repro pass for the still-untested paths (DR-1 via toolbar/menu, DR-6 via Stop-while-running), then Phase 2 starting with 2D.** Added `DbgTrace`/`DbgTraceEsc` (own mutex `tlockDbgTrace`, gated by `bDbgTrace`, appends to `Settings\debug_trace.log`) with thread-id on: every `writepipe`/`readpipe` + the worker-thread `ShowMessages` (DR-7); worker-loop branch per iteration `LOOP.send/refresh/read.begin/afterstop` (DR-3, idle ticks silent); `line_hl.enter` (raw annotation) + `line_hl.parsed` (`sFile`/`sLine`/`fcurlig`) + `Timer.act` branch (DR-2 verdict); `set_bp` enter/bail/break (DR-1); `kill_debug`/`deinit` (DR-6); `Updateinfox` off-thread `DoEvents` (DR-7); `EC.Breakpoint` paint state (DR-4). Compile-clean, launch-checked. **Next: owner runs the 5 repros (banner), then read the log before any Phase-2 edit.**
- **Phase 2 — build the `GdbSession` transport in verifiable slices.** The transport rewrite delivered as a sequence, each slice compile-clean + owner live-verify + one commit; the command surface is unchanged so every slice runs against the current baseline (no big-bang valley). Dependency-driven order:
  - **2A — lockstep worker loop (DR-3).** Reorder the loop: if `Running`, read the pending stop → refresh panels → *then* dequeue+send the next command; never send while `Running`. Preserve the `bGDBLocked` bookkeeping exactly. *Verify:* mash F8 (no hang); normal step/continue/inspect unchanged.
  - **2B — signalled shutdown + lock/handle ownership (DR-6).** Stop enqueues quit / sets a stop flag; the worker exits its own loop and closes the handles + unlocks the `tlockGDB` it owns; the UI-thread Stop path *waits for the worker to finish* instead of calling `readpipe`/closing handles/`MutexUnlock` itself. Kills `deinit`'s non-owned/double unlock. *Verify:* Stop while stopped, while running, mid-step — no hang/crash; relaunch works.
  - **2C — mid-session commands onto the queue (DR-1/DR-10). ✅ DONE + owner-verified 2026-07-12.** All breakpoint toggles (F9/gutter/menu) → `EditControl.Breakpoint` → `arm_breakpoint`, which enqueues `break`/`clear`/`tbreak`; the worker applies them in its lockstep loop (`LOOP.armbp`), never the UI thread. `set_bp` retired (dead code). Verified: mid-session arm-on stops at the newly-armed line, toggle-off removes it, comment-line refusal, run-to-cursor. **Five sub-bugs fixed during verify** (see the status-at-a-glance + DR-1/DR-10/DR-14 rows): `armbp` lock-release-before-loop; DR-14 exit-detect residual; `clear`→`delete N` (clear never matches this GDB); silent-`delete` read (`WithoutAnswer=True`); and the `FECLine`-clobbered-by-`PaintControl` bug that made arm-on always send `clear`.
  - **2D — marshal worker→UI (DR-7). ✅ DONE + owner-verified 2026-07-11.** Discovery that `ThreadsEnter`/`ThreadsLeave` are no-op stubs (`Component.bas:257`) confirmed the worker→UI panel fills were always racing. Fix: `RefreshDebugPanelsAfterStop` is now read-only (stores `gRaw*` + `bPanelFillPending`); the UI-thread `TimerProcGDB` calls `FillDebugPanelsOnUI`; watches use `SnapshotWatchNames`; off-thread `DoEvents` removed. Fixed DR-3's deadlock mode **and** DR-13. *Residual DR-7 (follow-up): `readpipe`→`ShowMessages` to Output + the watch-edit `UpdateWatch` on the worker — lower-risk, never the freeze.* DR-2 already didn't reproduce (post-DR-9); DR-4 was fixed separately (`b7af611`).
  - **2E — residual paint (DR-2/DR-4).** Whatever highlight/blank-editor behaviour survives 2D, fixed per the trace (the `fcurlig`→`TimerProcGDB`→`PaintControl` handoff now runs clean on the UI thread). *Verify:* single Step-Into highlights + scrolls; gutter-click mid-session doesn't blank.
  - **Robustness items folded in where they touch the same code:** `CreatePipeD` failure checks + `writepipe`'s `WriteFile` check land with **2B** (handle lifecycle); the silent queue-drop (`EnqueueDebugCommand`) is surfaced with **2A**; `load_file`'s implicit success-return tidied with **2C**.
- **Phase 3 — full re-verify.** Owner runs the complete checklist on the final build (set bp → step → inspect → continue → stop; F9 mid-session; gutter-click; rapid step; Stop at each state) before behavioural work closes. Partially covered by the DR-15/DR-7 quick-tests this session; DR-4 still blocks full closure.
- **Phase 4 — dead-code sweep. ✅ DONE (2026-07-12, `9e40c42`).** Removed `timer_data` (~155 dead lines), `set_bp`, `hard_closing`, ~230 lines of dead globals/init code (the integrated/stabs state block incl. the 5 MB `sourcebuf`), ~65 orphaned Declares in `Debug.bi` + their backing Types/Enums, and the inert `blocker` mutex — ~1160 lines total, each removal cross-referenced across all of `src/` (case-insensitive) per §9, not just compile-clean. Kept `prun`/`dbghand`/`runtype`/`flagkill`/`exename`/`mainfolder` (the live Run-without-debug path). Refreshed `THREADING.md`'s stale debug-worker entry and dropped its now-inaccurate `blocker` mutex section. Dead `iTime` params and remaining commented cruft were NOT chased further (diminishing returns vs. the risk of an open-ended sweep) — low priority if revisited.

**Cross-references:** the full attempt-#1 (reverted) and attempt-#2 write-ups, verified path facts, and the "gutter-click never calls `set_bp`" finding live in the [Breakpoint-during-debug pipe race](#open-items) Open Item — not duplicated here.

---

## ⭐ COMPLETED SUB-PROJECT — AI Agent subsystem removal (owner-approved 2026-07-09, DONE 2026-07-10)

**DONE.** All AI removal tasks (AI1–AI14) complete, compile-clean, committed (`924a814`) + pushed, Opus-reviewed (`7e9c228`) and owner-reviewed. The sequencing hold this placed on the rest of the backlog is lifted; next active item is the §13.3 View-menu review. Owner call on AI10's `VisualFBEditor IDE Environment.md`: **delete** (declined restore, 2026-07-10) — recoverable from git history at `924a814^` if ever wanted. The task-by-task detail (AI1–AI14) is archived in [HISTORY.md](HISTORY.md).

**Owner decision (2026-07-09):** remove the built-in AI Agent subsystem from the IDE entirely. This **reverses the earlier 2026-07-03 "13.7 Enhance AI integration" plan** — it was **the owner's own decision** to reverse that direction. Rationale: a self-maintained multi-provider AI client (OpenAI/DeepSeek/Claude/Mistral/Ollama/OpenRouter, streaming + context management) is a whole subsystem to maintain that isn't this tool's focus, and external tools (Claude Code, Cursor, DeepSeek-based tools) are advancing far faster than a solo-maintained internal client could track — the same anti-scope-creep discipline that motivates this fork. The `ROADMAP.md` §13.7 section is marked REVERSED with the full reasoning.

**Scope decisions (owner-confirmed):**
- **Remove all vestiges of AI in all locations** — code, forms, settings, resources, docs.
- **Keep `Examples/AiAgent/`** — a third-party MyFbFramework control demo (CM.Wang, ©2025), independent of the IDE's built-in feature; it is itself an example of the "wire your own external AI" pattern.
- **No new AI launcher feature.** A purpose-built external-AI launcher was evaluated and **dropped as redundant**: the existing **Tools ▸ External Tools** dialog (`frmTools.frm`) already lets users register any external program (path + parameters + file-extension association), which is exactly the "users can add AI agent links to external tools" path the owner intended. Nothing to build.

**Why this is one atomic pass (not stageable):** the AI state globals live in `src/Main.bi` and are referenced across four core files, so there is no half-removed state that compiles. Work stays uncommitted until compile-clean **and** owner smoke-test (this project's standard gate), then commits as one change.

**Task-by-task detail archived.** The full AI1–AI14 task definitions, per-model assignments, and the Sonnet/Opus progress logs have been moved to [HISTORY.md](HISTORY.md) (§"AI Agent subsystem removal — task-by-task detail") now that the sub-project is closed. Outcome summary is above; the deleted-file inventory and commit hashes are in [CHANGELOG.md](CHANGELOG.md).

---

## Opus "Next Steps" backlog — all phases done (2026-07-08)

Executes Phase A, item 5 (P1), Phase B (P2/P3), Phase C (U1/U2, U3/U4, event-handler cluster, `.lng` decision), Phase D (F1, F2), and Phase E (O1, O2, O3, E1) of `Next Steps - Opus.md`'s consolidated, source-verified backlog (Opus cross-checked three prior AI reviews — Cursor, Deepseek, Sonnet — against the actual code before sequencing this plan; see that document for full methodology and the discarded/unsubstantiated claims). R5 (needed live GDB reproduction) and E1 (large rewrite, spun off as its own background task) were the last two items; both are now done.

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
| **U3/U4** | Wording-only pass (no behavior/default changes): "Use Direct2D (For Windows)" → "Smoother text rendering (Direct2D)"; "Auto create resource and manifest files (.rc, .xml)" → "Automatically create the icon and manifest files needed to build"; "Update all language file (*.lng)" → "Update all language files"; casing fix "Intellisense limit" → "IntelliSense limit". Left `AutoComplete` vs `AutoSuggestions` naming alone — traced them to genuinely different features (inline completion dropdown vs. project-wide analysis), so merging their labels risked hiding a real distinction rather than just cleaning up drift. | `src/frmOptions.frm:803, 533, 2028, 1936` | Compile-clean + launch check |
| **U3 (event-handler cluster)** | **Owner decision (2026-07-07):** collapse the Designer's 4-checkbox "static event handler" cluster to one simple choice, per the "single toggle over independent flags" rule — today's defaults become the "modern" preset. Traced the actual codegen first (`TabWindow.bas` ~3455-3521): all 4 flags interact in genuinely nuanced ways across several branches (non-static vs. static handler generation, placement, naming, and a `Declare Static` companion line generated alongside even in the non-static path). Given that real complexity in code sitting near the historically fragile Designer/`FormDesign` area, did **not** touch `TabWindow.bas`'s codegen logic at all — zero risk there. Instead hid the 3 secondary checkboxes (`.Visible = False`, same low-risk pattern already used in S6) and relabeled the primary one "Event handlers: Non-static (modern)" so it reads as the single governing choice; their INI-backed defaults (already matching "today's defaults") are now fixed rather than user-toggleable. | `src/frmOptions.frm:1715, 1985, 1994, 2343` | Compile-clean + launch check (**Options ▸ Designer page layout not visually confirmed — hiding absolutely-positioned controls leaves blank gaps rather than reflowing, same caveat as S4's field removal**) |
| **U3 (.lng maintenance)** | **Owner decision (2026-07-07): English only going forward** — the 15+ `.lng` translation files inherited from upstream are not considered an active maintenance obligation for this fork. No code changed this session (owner explicitly deferred the Options-dialog simplification — hiding/relabeling the language picker and `.lng` maintainer tools — to a future pass); recorded here so future caption-rename work (e.g. a View-menu relabel) doesn't need to preserve non-English `.lng` lookups or re-ask this question. | N/A (decision only) | N/A |
| **F1** | Wrote down the feedback-channel policy Opus asked for (status bar = transient state; Output/Problems = background events, non-intrusive; `MsgBox` = irreversible/blocking only) as a new guiding principle, to apply opportunistically rather than as a big-bang sweep. See "Guiding principle: feedback-channel policy" above. | `PROJECT_STATUS.md` (this doc) | N/A (doc only) |
| **F2** | Two previously-silent failure paths now give a visible reason, per the new F1 policy. (1) `TabWindow.FormDesign`'s 50,000-line Designer cutoff exited with zero feedback — now sets a status-bar caption before bailing. (2) `LoadFunctions`'s missing-include case (all 4 `Open` attempts fail) fell through silently, leaving that header's symbols permanently absent from IntelliSense with no clue why — now logs to the Output panel (`ShowMessages(..., False)`, no tab-switch) *without* spamming: traced `GetRelativePath` first and confirmed it already searches the source file's folder, `ExePath`, every control library's include folder, the bundled compiler's own `inc/` folder, and any configured include paths before giving up — so this only fires on a genuinely unresolvable include (typo/deleted file), not on ordinary system headers. | `src/TabWindow.bas:8374-8378`, `src/Main.bas:3208-3214` | Compile-clean + launch check |
| **R5 — done (2026-07-08, owner-verified)** | GDB's `readpipe` (`Debug.bas`) blocked on a plain synchronous `ReadFile` with no timeout — worker-thread-scoped. **Fix:** poll with `PeekNamedPipe` before each read; the debug worker thread now bails on **app close** (`FormClosing`) or a **broken pipe** (GDB terminated/crashed) instead of stalling. The broken-pipe bail also fixes a latent **tight infinite loop** the old code hit when the pipe broke (repeated 0-byte reads). Data-available behavior is byte-for-byte unchanged, so normal debugging is unaffected. **Owner-verified:** full debug session (breakpoint → step → variables → continue → stop) works. Did **not** attempt a response-timeout ("surface a hung GDB mid-session") — that risks false positives on slow-but-legit GDB commands and needs a reproducible hang to tune; left as a possible follow-up. | `src/Debug.bas:447-513` | Compile-clean + owner live-test |
| **O1** | **Owner decision (2026-07-07):** trim the default AI catalog to a small, recognizable set + the existing "Add AI Agent" button for anything else, instead of seeding all 29 models. `SeedDefaultAIAgents` now seeds 3: the app's own default (`*DefaultAIAgent`, a free OpenRouter DeepSeek model), a free Google Gemini model via OpenRouter, and DeepSeek's own direct API — one aggregator example, one recognizable brand, one direct-API example. The manual "Add AI Agent" button (`cmdAddAIAgent`, already existed) covers everything else. | `src/SettingsService.bas:123-129` | Compile-clean + launch check |
| **O3** | **Owner decision (2026-07-07):** remove the Android/ADB deploy code — out of scope for this Win64-only, desktop-BASIC-hobbyist fork. Removed `RunPr`'s entire Gradle/`local.properties`/ADB branch (install/uninstall/launch via `adb`) along with the now-unreferenced `RunEmulator` and `RunLogCat` worker Subs (~285 lines total). The `.vfp` backward-compat fields (`ppe->AndroidSDKLocation`/`AndroidNDKLocation`, read/written for old project files) were deliberately left alone, matching the same precedent as S4's `IconResourceFileName` — harmless orphaned struct fields, not active build logic. | `src/TabWindow.bas` (formerly ~11516-11674, ~11917-12040, ~12196) | Compile-clean + launch check |
| **E1 — done (2026-07-08, merged from background task)** | `frmOptions.cmdApply_Click` wrote all ~296 INI keys (`piniSettings`/`piniTheme`) unconditionally on every Apply click — 96 distinct `WriteXxx` call sites, several inside loops (AI agents, terminals, other editors, help paths, include/library paths) and a large theme-colors block, none checking whether the value actually changed. Traced `IniFile.WriteXxx` (`Controls/MyFbFramework/mff/IniFile.bas`) and confirmed every write triggers a full-file disk rewrite (`Update` → `SaveToFile`) regardless of whether anything changed. Added 4 small dirty-check helpers (`IniValueChangedBool/Int/Float/Str`, `src/frmOptions.frm` just above `cmdApply_Click`) that compare the new value against what's already in the INI (`KeyExists`/`ReadXxx`, in-memory lookups — no disk I/O) before allowing a write; every `WriteXxx` call site is now wrapped `If IniValueChanged...(...) Then ... End If`. Generated mechanically (a one-off Python transform) so all ~295 sites got identical, verified treatment; sampled AI-agent-loop, IIf-laden theme-color, and hex-flag `WriteInteger` sites by hand to confirm correctness. **Gotcha found and fixed:** inlining the guard logic at each site (rather than via shared helpers) ballooned the generated C function to ~8000 lines and crashed the `gcc` backend at `-O2` with zero diagnostic output — factoring the repeated logic into the 4 shared helpers fixed it. Merged into `main` 2026-07-08 (`cbc71d1`); **not yet launch-tested against a real Options ▸ Apply click** — needs owner live verification before being trusted (see note below on this task's own compile-clean environment quirk). | `src/frmOptions.frm` (helpers + ~400-line `cmdApply_Click` body) | Compile-clean (merge build) — **owner live-test of Options ▸ Apply still needed** |

**Verification performed:** compile-clean after each fix (0 errors; same 4 pre-existing `frmFindInFiles.frm` warnings throughout) + release-build launch/process-alive check after each. **Not verified this session** (no GUI/computer-use access): live click-through of Save-failure messaging, AI Stop/New Chat under an in-flight request, Suggestions on a large project, Format Project's narrowed disable, the three reworded Debug.bas messages, the fresh-install starter-project path, the reworded Options-dialog text, the FormDesign 50k-line status message, the missing-include Output message, the trimmed AI-agent list on a fresh install, and Run/Build after the Android-code removal — same gap noted throughout recent sessions; needs owner or a computer-use-capable session.

**Owner decisions taken 2026-07-07, no code needed:**
- **O2** — plaintext AI Agent API keys in the INI: **left as-is.** Low risk for a single-user desktop tool; comparable IDEs do the same.

**Remaining Opus backlog:** R5 **done** (2026-07-08); E1 **done** (2026-07-08, merged from background task, see table above — still needs owner live-test); Phase F (deferred structural: file splits, `FormDesign` debounce — deliberately last, touches the fragile designer path; not started, low priority, see `Next Steps - Opus.md`). Everything else in the Opus backlog is done.

### Deferred-task triage (Opus, 2026-07-07) — `P:\Astoria-Docs\Deferred Task Recommendations - Opus.md`

After the Next Steps backlog was worked through, Opus triaged every remaining deferred/untouched item into three buckets by fragility and payoff. Full reasoning in the linked document; the split:

- **Opus (fragile-core / live-verification-only):** **R5** (GDB read timeout — gated on owner producing a reproducible hang); ~~**P4**~~ (see outcome below — **attempted & reverted 2026-07-07**); ~~**D1**~~ (**done 2026-07-07** — see below).

#### D1 outcome — Designer menu disabled when no form is open (Opus, 2026-07-07)

The top-level **Designer** menu (`miFormFormat`, "&Designer") now greys out when the active document has no designable form with controls. Made `miFormFormat` a `Dim Shared` pointer, created it disabled (no form at startup), and gate its `Enabled` on `cboClass.Items.Count > 1` at the exact three sites that already govern `miForm`/`miCodeAndForm`: `tabCode_SelChange` (Main.bas, both branches + the `newIndex = -1`/no-tab-selected exit) and `ApplyFormTabView` (TabWindow.bas, both branches). Used the stricter `Count > 1` gate (needs actual controls) rather than `miForm`'s `bFormFile`, because the Designer operations (Align/Make Same Size/Spacing/Order/Lock) act on existing controls — a form file with zero controls has nothing to align, so the menu stays greyed until controls exist. The separate right-click `mnuDesigner` popup and the `"FormFormat"`-key collision with the Format-toolbar toggle are pre-existing and untouched (the Designer parent menu has no click handler, so the key never dispatches). Compile-clean + launch check.

**D1 form-close gap — fixed (2026-07-07, owner-verified).** The menu didn't grey on form/tab close because `tabCode_SelChange`'s `If tb = tbOld Then Exit Sub` early-exits (Main.bas ~8156/8170) return *before* the per-select enable-logic. **Fix:** compute `miFormFormat->Enabled` in **`ChangeMenuItemsEnabled`** (TabWindow.bas, end of the Sub) from the active tab (`ptabCode->SelectedTab`'s `cboClass.Items.Count > 1`) — that Sub is already called by `CloseTab` on every tab close, so the menu now greys on close regardless of the `tabCode_SelChange` early-exits. Owner-verified: greys on form close, re-enables on switching back to a form. (Known-cosmetic, owner-accepted: during a modal save-file dialog on close, the menu momentarily dims then re-activates until the last form closes — harmless since the dialog is modal.)

#### Close Project crash → hang → tabs-not-closing — root-caused & fixed (Opus, 2026-07-07, owner-verified)

Owner reported `File → Close Project` **aborting the app** (project never closed; reopened on restart). This was **not D1** (GDB confirmed zero frames in any D1 code). It was a deep, pre-existing, multi-layer bug in `CloseProject`, cracked with a **GDB debug (`-g -exx`) backtrace** and then, when GDB's crashing-thread stack came back corrupt, a **file-trace** (`DbgTraceCP`) that pinned the exact teardown step. Three real defects, fixed in order:

1. **Use-after-free crash (the abort).** `CloseProject` freed the tree nodes' `ExplorerElement`/`ProjectElement` (`Main.bas` ~2518/2531/2544) but left the nodes' `.Tag` pointers **dangling**, then `tvExplorer.Nodes.Remove` fired `tvExplorer_SelChange`, which does `*eeSel Is ControlTreeElement` on `Item.Tag` → `fb_IsTypeOf` on a freed vtable → SIGSEGV. (The 8+ live `LoadFunctions` parser threads in the first backtrace were *victims* of the corrupted heap, not the cause — a `LoadFunctionsCount` drain was tried and **removed** once the file-trace showed `LFcount=0` at the crash, i.e. deterministic, not a race.) **Fix:** null each `.Tag` immediately after `_Delete`.
2. **Tabs never closed → hang on next interaction.** The old close loop matched `tb->ptn = tn` and did `Exit For` after one — it closed nothing here (stale/mismatched `ptn`), so the project was freed out from under its still-open tabs, whose dangling refs then hung the app (owner had to Task-Manager kill). **Fix:** a new `NodeInProject(node, proj)` helper + a **robust close-all loop** that closes every tab whose tree node is `tn` or a descendant (re-scanning after each close), **plus a safety bail**: if any project tab still won't close, `CloseProject` returns `False` *without* freeing — so it can never leave dangling refs (no hang), by construction.
3. **Reopened on restart.** Was a downstream effect of (2): tabs stayed open → the workspace saved them on app-close → reload. Fixed once tabs actually close.

**Owner-verified:** project + tabs close cleanly, app stays responsive, stays closed on restart.

#### Empty-workspace startup → File → New Project (owner design, 2026-07-07, owner-verified)

The earlier U2 "starter project" used `AddNew(Files/Form.frm)`, which is wrong — `AddNew` only opens a project for a `.vfp` path and otherwise shows "Open a project first" (owner hit this popup after closing the project). **Owner's chosen design:** when there's nothing to reopen, automatically invoke **File → New Project** (`NewProject`, `Main.bas` ~9304) so the user picks the project type. A startup modal here is already the norm (`frmTipOfDay.ShowModal` just below) and it's the original intent (see the commented `Case 1: NewProject`). Cancelling leaves an empty IDE.

#### New Project ↔ Open Project cross-navigation buttons (owner request, 2026-07-07, owner-verified)

- **`frmNewProject`:** added an **"Open Existing Project"** button (lower-left, aligned with OK). Sets `OpenExistingRequested`, closes with Cancel; `NewProject()` then calls `OpenProject()`.
- **`frmOpenProject`:** added an **"Open New Project"** button (lower-left, leftmost) and **moved the existing Browse button to its right** (both `alNone`, explicit `SetBounds`, same height, aligned with OK — no overlap). Sets `OpenNewRequested`, closes with Cancel; `OpenProject()` then calls `NewProject()`. Forward-ref `OpenProject → NewProject` is safe (both `Declare`d in `Main.bi`; mutual toggling recurses but only on repeated clicks — acceptable).

**D1 form-close greying gap — now fixed** (see the D1 outcome section above; resolved via `ChangeMenuItemsEnabled`, owner-verified). No D1 loose ends remain. **R5 (GDB read timeout) done & owner-verified 2026-07-08.** **E1 (Options Apply dirty-tracking) done 2026-07-08**, merged from its background-task worktree (see table above) — still needs an owner live-test of Options ▸ Apply.

#### Startup Close-Project-greyed fix — root-caused & fixed (Sonnet, 2026-07-08, owner-verified)

While live-testing E1, owner found `File → Close Project` **greyed out on startup** when reopening a project from the saved workspace (though it worked once you clicked any node in the Explorer tree). Root cause: `miCloseProject->Enabled` is only ever refreshed by `ChangeMenuItemsEnabled` (`TabWindow.bas:263`), which the tree's `SelChange` handler calls when the selected node's parent changes (`Main.bas:6810-6824`). At startup, `LoadWorkspace()` → `AddProject()` ends with `tn->SelectItem` (`Main.bas:1050`), but that's a thin wrapper over Win32 `TreeView_Select(Parent->Handle, ...)` (`TreeView.bas:12-14`) — if the tree control's handle isn't realized yet at that point in startup, the call silently no-ops: no visual selection, no `SelChange` event, and `tvExplorer.SelectedNode` stays `0` (confirmed via `TreeView.SelectedNode`'s getter, which also requires `Handle`). So the reloaded project's menu state never gets computed until the user manually clicks a tree node.

**First attempt (incomplete):** just calling `ChangeMenuItemsEnabled` after `LoadWorkspace()` returns wasn't enough — it reads `tvExplorer.SelectedNode`, which was still `0` (the earlier `SelectItem` truly never took effect, not just unrefreshed). Owner tested and confirmed still greyed.

**Fix:** after `LoadWorkspace()`/`RunDeferredFormDesign()` (`Main.bas` ~9291, by which point the tree handle is realized), look up the loaded project's node via `GetOpenProjectNode()`, call `tnLoadedProject->SelectItem` to actually re-select it now that the handle exists, then call `ChangeMenuItemsEnabled` directly. Compile-clean; **owner-verified**: Close Project (and the other project-scoped menu items gated the same way — Save Project, Delete Project, Project Properties) are enabled immediately on startup with a reloaded project, no tree click needed. | `src/Main.bas:9291-9297` | Compile-clean + owner live-test

#### E1 live-test follow-up: menu-icons toggle partially applied live — root-caused & fixed (Sonnet, 2026-07-08, owner-verified)

While live-testing E1's Options ▸ Apply, owner found: unchecking "Display icons in the menu" and clicking Apply showed the correct "changes apply the next time the application is run" message, but most menu icons **vanished immediately anyway** (a few were retained) — a half-applied, inconsistent state. **Confirmed pre-existing, not an E1 regression** (`git show cbc71d1` shows the offending line as unchanged context, not part of E1's diff). Root cause: `cmdApply_Click` set `pfrmMain->Menu->ImagesList = IIf(DisplayMenuIcons, pimgList, 0)` live, immediately dropping the shared icon-list reference for the whole menu — but already-rendered menu items keep their cached icon until a full menu rebuild, so only some disappeared. The startup path (`SettingsService.bas:310`) already sets this correctly from `DisplayMenuIcons` on the next run. **Fix:** removed the live `ImagesList` assignment from `cmdApply_Click` entirely — the setting now only takes effect on restart, matching the message shown. Compile-clean; **owner-verified**: icons stay untouched after Apply, message is now accurate. | `src/frmOptions.frm:3844` (removed) | Compile-clean + owner live-test

**New open item (owner-reported 2026-07-08, deferred):** **breakpoint repaint glitch** — after setting a breakpoint, the rest of the code editor goes invisible until the user clicks back into the form/editor window. Cosmetic repaint/invalidate issue in the breakpoint-set path (likely a missing `Refresh`/`Invalidate` on the `EditControl` after the gutter/breakpoint change). Not investigated; logged for a future session.

#### P4 outcome — attempted, live-tested, reverted (Opus, 2026-07-07)

Implemented the **surgical** version: debounce only the single hot edit-path caller (`OnLineChangeEdit`, `TabWindow.bas:3248`) via a 300 ms one-shot timer (`TimerProcDesign` in `Main.bas`, mirroring the `TimerProcGDB` NULL-window pattern), coalescing toward a full rebuild, operating on the *current* tab at fire time (no captured pointer), re-checking every guard the grey-panel fix trusts. Compiled clean; **owner live-tested**. Result: **regression** — changing a control's **Location** via the property list no longer updated the control (Caption still did, because the grid applies caption straight to the live control, whereas Location relies on the `FormDesign` rebuild the debounce delayed). Root problem: **`OnLineChangeEdit` is not the "rapid-typing hot path" — it is the common funnel for *every* text change**, including discrete edits (property-grid apply, paste, and the line-changes undo/redo generate) that need an *immediate* designer refresh. A blanket debounce there is the wrong shape. **Reverted to `640e94e` (nothing committed).** A correct P4 would have to debounce *only* genuine consecutive keystroke-typing while keeping discrete edits synchronous — substantially more invasive surgery in the grey-panel code, for a typing-lag nobody has reported as a pain point. **Parked as not worth the risk/reward** unless designer responsiveness becomes an actual complaint. Design + change-surface map preserved in this session's history if ever revisited.
- **Sonnet (mechanical / contained):** ~~**E1**~~ (Apply dirty-tracking — **done 2026-07-08**, see above); ~~**C1**~~ Comment→Toggle-Comment merge — **done 2026-07-08, owner-verified, see "C1: Toggle Comment merge" below**; ~~**C2**~~ move Bubble Help/Suggest Options/Parameter Info into Options — **done 2026-07-10 (Sonnet)**, see "C2: Edit-menu settings moved to Options" below; ~~**C3**~~ move Recent AI Chat into AI Agent panel — **superseded 2026-07-09**: the AI Agent panel is being removed entirely (see ⭐ AI Agent subsystem removal sub-project above), so Recent AI Chat is deleted rather than moved; ~~**C4**~~ `.lng` translation system — **owner escalated scope from "hide the UI" to full code-level removal 2026-07-08, done, see "C4: full language-system removal" below, owner smoke-test pending**; ~~**C5**~~ GitHub submenu reduction — **owner escalated to full removal 2026-07-09**: rather than pick which 2 items to keep, deleted the entire Help ▸ GitHub topic (2 top-level items + 5-item Advanced submenu, all 7 pointing at the un-forked upstream `XusinboyBekchanov/VisualFBEditor`/`MyFbFramework` repos anyway) and its `mClick` dispatch cases in `VisualFBEditor.bas`, including an already-orphaned `GitHubWebSite` case with no menu item pointing to it. Also removed the corresponding blank/bound `HotKeys.txt` entries. Compile-clean; **owner smoke-test still needed**; ~~**B1**~~ `DeleteEditorFile` `.vfp` dirty-sync — **found already done 2026-07-10**, see Open Items; ~~**B2**~~ `frmNewProject` template icons — **checked 2026-07-08, not reproducible**: owner confirmed all 5 default templates (Windows/Console/Dynamic/Static/Control) show correct icons at &gt;100% display scaling. Traced the load path (`ImageList.Add` → `BitmapType.LoadFromResourceName`'s disk-file fallback reading `Resources/App*.png`, all correctly 32×32) and found no defect; closing as already-working rather than risk an unnecessary change. ~~**B3**~~ `OpenRecentFiles()` dialog — **fixed 2026-07-10**, see Open Items; **O1/O2** Terminal / Other Editors removal *only if owner opts to remove* (default: leave — working features, harmless) — **update 2026-07-11:** owner's understanding is External Editors was already removed; this session's `frmPath` fix found live code for it, so this needs reconciling before deciding — see the "Audit: is 'External Editors' actually gone?" Open Item.
- **Do Not Attempt (fragile-core churn, no audience payoff):** **F1** split the oversized files (`TabWindow`/`Main`/`EditControl` — pure maintainability, high FB compile-break risk); **F2** MFF library-path consolidation (the wart is already harmless; the fix reworks the grey-panel-bug code — risk ≫ reward). Leave both unless a real bug forces the issue.

#### C4: full language-system removal (Sonnet, 2026-07-08, owner smoke-test passed)

Owner escalated C4 to **removing the `.lng` translation capability at the code level entirely** — English-only, permanently. Both layers removed: the 4 pure-lookup wrapper functions stripped from ~2,010 call sites across 38 files via a state-tracking Python transform (`ML()`/`MC()`/`MP()`/`MLCompilerFun()`, leaving `HK()` and `MS()`), and the loading/UI/maintenance capability (the `.lng` parser in `LoadLanguageTexts`, the Localization Options page and its ~665-line regeneration tool, the `Settings/Languages/` directory). Full transform detail, the fallout fixes, and the two accepted parser-quirk warnings are archived in [HISTORY.md](HISTORY.md) (§"C4 — full language-system removal, detailed write-up").

**Options ▸ Code Editor ▸ Defaults page — removed (Sonnet, 2026-07-08, owner-verified).** Confirmed `vbxDefaults` had zero children (`grbDefaults`/`pnlDefaults` were empty containers, nothing ever parented into them) — genuinely dead, not just hidden. Removed the whole chain: the `tnEditor->Nodes.Add(("Defaults"), "Defaults")` tree node, the `.pnlDefaults.Visible = Key = "Defaults"` toggle, and the `pnlDefaults`/`grbDefaults`/`vbxDefaults` control declarations + creation blocks (`frmOptions.frm`/`.bi`). Left the *other* `grbDefault*` groupboxes alone (`grbDefaultCompilers`, `grbDefaultTerminal`, `grbDefaultHelp`, `grbDefaultAIAgent` — different, populated, real features). Compile-clean, owner-verified: no "Defaults" sub-item under Code Editor, nothing else in the tree affected.

#### C1: Toggle Comment merge (Sonnet, 2026-07-08, owner-verified)

Collapsed **Single Comment** (Ctrl+I, unconditionally added a `'` prefix) and **Uncomment Block** (Ctrl+Shift+I, already handled removing *either* single-`'` or block-`/' '/`-style comments) into one **Toggle Comment** command on Ctrl+I: comments the selected line(s) if not already commented, uncomments if they are. Added `EditControl.ToggleComment` (`EditControl.bas`, checks only the first selected line's leading/trailing markers, same detection `UnComment` already used, then delegates to the existing `CommentSingle`/`UnComment`) rather than rewriting either's per-line logic. Wired `Case "SingleComment"` in the `mClick` dispatcher to call it; removed the separate "Uncomment Block" menu item/toolbar button/hotkey (the underlying `EditControl.UnComment` Sub and its `Case "UnComment"` dispatch stay in place, just no longer exposed as its own user-facing command, since `ToggleComment` now calls it internally).

**Owner follow-up (same session):** removed **Block Comment** (Ctrl+Alt+I, the `/' '/`-wrap style) entirely — owner confirmed Toggle Comment already comments/uncomments each line of a multi-line selection individually, which is the expected BASIC-programmer behavior, making the block-wrap style redundant. Deleted `EditControl.CommentBlock` (the only caller was the removed menu item), its `Case "BlockComment"` dispatch, its entry in the shared gating `Case` list, the menu item/toolbar button/icon registration, and all now-unused `miBlockComment`/`tbtBlockComment` declarations. `EditControl2.bi`'s own unrelated `CommentBlock` declare is dead/orphaned pre-existing code (that file isn't `#include`d anywhere) and was left alone.

#### C2: Edit-menu settings moved to Options (Sonnet, 2026-07-10, compile-clean — **owner visual check needed**)

Investigated the S1–S4 "Deferred" scope gap below and found the picture had changed since it was written: **Bubble Help** (`ShowSymbolsTooltipsOnMouseHover`) and **Suggest Options** (`AutoComplete`) already had fully-wired Options ▸ Code Editor checkboxes (`chkShowSymbolsTooltipsOnMouseHover`, `chkEnableAutoComplete` — both already read on dialog Load and written on Apply), living in parallel with the redundant Edit-menu toggles. Only **Parameter Info** (`ParameterInfoShow`) had no Options presence at all.

**Removed from the Edit menu:** `miSuggestions` ("Code - Bubble Help") and `miCompleteWord` ("Code - Suggest Options") — deleted their `miEdit->Add(...)` calls, their dead `Checked`-sync lines in `ChangeShowSymbolsTooltipsOnMouseHover`/`ChangeAutoComplete` (`Main.bas`), their `Dim Shared` declarations, their `mClick` dispatch cases (`"Suggestions"`/`"SuggestOptions"`, `AstoriaIDE.bas`), and a dangling unguarded `miSuggestions->Enabled = bEnabled` in `TabWindow.bas`'s `ChangeMenuItemsEnabled` (`TabWindow.bas:306`) that would otherwise have null-dereferenced on every enable-state refresh once the pointer stayed permanently 0. Neither item carried a real keyboard shortcut (`HK()` had no matching `HotKeys.txt` entry for either), so nothing was lost.

**Parameter Info handled differently, on purpose.** Traced how this app's keyboard shortcuts actually work (`Menus.bas` ~1538–1561): the framework builds its native accelerator table by scanning every *menu item's caption* for an embedded `\tCtrl+X`-style suffix — there's no separate registration path, so deleting a menu item deletes its shortcut. `miParameterInfo`'s caption carries `Ctrl+J` this way, and the old `"ParameterInfo"` dispatch case had dual behavior: a plain menu click toggled the auto-show setting, while the *accelerator* (Ctrl held) invoked Parameter Info immediately — genuinely one "edit action" and one "on/off setting" sharing a single case via a `GetKeyState(VK_CONTROL)` check. Splitting them: the menu item stays (preserving Ctrl+J), now non-checkable and re-pointed at the same `"InvokeParameterInfo"` key the toolbar button already used (always invoke now, no toggle); the old dual-behavior `"ParameterInfo"` case is deleted as dead code. The on/off "auto-show" setting moved to a new `chkParameterInfoShow` checkbox in Options ▸ Code Editor ▸ IntelliSense (`frmOptions.frm`/`.bi`), wired the same way as its siblings — Load populates it from `ParameterInfoShow`, Apply writes it back through the existing `ChangeParameterInfo(...)` Sub (which already handles the state update, closing any open tooltip, and the INI write) rather than duplicating that logic.

**Verification:** compile-clean (0 errors, same baseline warnings), launch/process-alive check passed. **Not verified this session** (no GUI/computer-use access): the new checkbox's visual placement in the IntelliSense group box, and a live click-through confirming Ctrl+J still invokes Parameter Info and the Edit menu no longer shows the three removed/changed items as expected — same recurring gap as everywhere else in this doc; needs owner or a computer-use-capable session.

Compile-clean throughout; owner-verified both the toggle behavior (comment ↔ uncomment on repeated Ctrl+I, single line and multi-line selections) and that Block Comment is fully gone from menu/toolbar/hotkey.

**Already resolved (dropped from the deferred list):** the Designer event-handler cluster (collapsed to one toggle, `640e94e`) and the `.lng` maintenance question (decided: English-only).

**E1 background-task session note (worktree, 2026-07-08):** the E1 worktree's `Compile.bat` failed silently at the `gcc` step (exit 1, zero output) even on an untouched baseline checkout of the same worktree, while the separate main checkout at `C:\Users\dmont\VisualFBEditor` compiled the identical baseline cleanly — ruled out the code change as the cause (baseline reproduced the same failure), tried a retry after a pause, and a byte-for-byte copy of the worktree to a plain path (all failed identically). Verified compile-clean at the time by temporarily swapping the modified `frmOptions.frm` into the main checkout, compiling there (0 errors, clean), then restoring the main checkout's `frmOptions.frm`. This was a worktree-environment quirk, not a code defect. **Confirmed 2026-07-08:** merged into `main` (`b078d99`) and recompiled clean here (0 errors, same 4 pre-existing `frmFindInFiles.frm` warnings) — the worktree's `gcc` failure does not reproduce in the main checkout.

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
- ~~**Moving Bubble Help/Suggest Options/Parameter Info from Edit into the Options dialog**~~ — **done 2026-07-10**, see "C2: Edit-menu settings moved to Options" above. **Moving Recent AI Chat from File into the AI Agent panel** is moot — the AI Agent panel was removed entirely (see ⭐ AI Agent subsystem removal sub-project); Recent AI Chat was deleted rather than moved.
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

**Visual FB Editor (VFBE)** is a FreeBASIC IDE with visual designer, debugger, and project support, built on [MyFbFramework](https://github.com/XusinboyBekchanov/MyFbFramework).

This fork (**VFBEWin64**) is a **Win64-only** branch of upstream VisualFBEditor:

| Keep | Remove / defer |
|------|----------------|
| Native **WinAPI / Win32** UI | GTK / Linux IDE paths (physically deleted, not just hidden) |
| **64-bit** IDE and bundled `fbc64.exe` | 32-bit IDE (`VisualFBEditor32`, `mff32`) |
| Bundled compiler at `Compiler\fbc64.exe` (tracked in-repo; staying on 1.10.1 — see Tier 3, no viable 1.10.3 binary exists) | Dark-mode *implementation* — replaced with an inert stub, interface preserved for a future trustworthy reimplementation (not full removal — see §3a) |

**This is now a fully self-contained fork:** `Compiler/`, `Debuggers/`, and `Controls/MyFbFramework/` are tracked in git (previously vendored/gitignored) — see §3a and §12.

**Build outputs (repo root):**

- `mff64.dll` — `Controls\MyFbFramework\mff64.dll`
- `astoria.exe` — main IDE (renamed from `VisualFBEditor64.exe`, 2026-07-10, §13.4)

**Settings:** `Settings/astoria.ini` (renamed from `Settings/VisualFBEditor64.ini`, 2026-07-10 — existing settings preserved; runtime path via `ExePath/Settings/...`)

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
origin  https://github.com/dmontaine/astoria-ide.git
branch  main
```

**Codeberg retired 2026-07-09** — `bigriverguy/VFBEWin64` on Codeberg is no longer the working repo; GitHub (`dmontaine/astoria-ide`, renamed lowercase 2026-07-10 following the AstoriaIDE rebrand) is now the sole remote. The Codeberg repo received a final push with its README replaced by a retirement notice pointing here. The old SSH key (`~/.ssh/id_ed25519_codeberg`, host `codeberg.org` in `~/.ssh/config`) is no longer used for this project.

**Note:** Git may not be on PATH in all shells; full path:

`C:\Program Files\Git\bin\git.exe`

### Build before running the IDE

Close any running `astoria.exe` first (`mff64.dll` is locked while the IDE runs).

```powershell
cd C:\Users\don\Astoria-IDE
set NOPAUSE=1
Compile.bat
.\astoria.exe
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

All completed items have been archived to [CHANGELOG.md](CHANGELOG.md). See that file for the full chronological record of shipped work with commit hashes. Nothing from this section remains open — the one lingering item (frmNewProject template icons) was investigated and closed as not-reproducible; see its entry under [Open Items](#open-items).

---

## 7. Manual test plan — regression validation

> **Handoff note (Claude Code):** Bottom panel **implementation bugs are resolved**, and both left and right panel Pin-click bugs are also now fixed (§4, §6). Batch 2.75.3 (dead-code deletion) **has already happened** — the owner explicitly directed the team to proceed before this checklist was fully signed off, rather than treating it as a hard gate. This checklist is now a **regression-validation pass** covering both the original panel work and the since-completed dead-code deletion, not a pre-2.75.3 gate.

Run a full pass on **latest** `astoria.exe` (formerly `VisualFBEditor64.exe`, renamed §13.4) after `Compile.bat`. Check each box when verified.

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
- Consider `.gitignore` for `astoria.exe` (formerly `VisualFBEditor64.exe`) if binary commits are undesired (currently committed like initial import)

---

## Open Items

*All open/deferred items consolidated from across the document. Ordered by priority/readiness.*

### Fable review remediation (2026-07-11)

- [x] ~~**T1–T16 remediation queue**~~ — **CLOSED 2026-07-11: every task T1–T17 done** (Wave 1 hygiene; T1 Option B decision; Wave 3 robustness, committed individually; T16 review, 3 findings fixed; T5 owner-verified; T15 theme shortlist decided + implemented `9c18bd8`; T14 consolidation) **and the owner smoke-test list completed** (owner-confirmed 2026-07-11 — findings all dispositioned, see the T16 row). Outcome summary at [⭐ COMPLETED SUB-PROJECT — Fable review remediation](#-completed-sub-project--fable-review-remediation-2026-07-11); the full task table is archived in [HISTORY.md](HISTORY.md) (T14 archival, 2026-07-11). **T6 and all further debugger work extracted 2026-07-11 into the [Debugger Reliability sub-project](#-active-sub-project--debugger-reliability-queued-2026-07-11) (DR-1..DR-5) — see the item below, now retitled DR-1; that work remains open.** Archival of the remediation section to HISTORY.md (T14's deferred piece) is now unblocked.
- [ ] **`<Project>_Change.log` location (owner question, deferred)** — the ChangeLog panel writes per-project changelogs to the **IDE root** (`Main.bas:7063/8619/9481`), not the project folder. Moving them to the project's own folder is more natural but is a behavior change — owner call, separate task. Surfaced by the T1 write-surface survey.
- [ ] **Default `ProjectsPath` → Documents (owner question, deferred)** — new projects default to `.\Projects` inside the app folder; consider defaulting to `Documents\AstoriaIDE Projects` so user work doesn't live in the install dir. Pairs well with §13.5 installer work. Surfaced by the T1 survey.

### MyFbFramework review (Fable, 2026-07-12)

*First review of `Controls/MyFbFramework/` (the vendored, now-git-tracked LGPL UI framework the IDE is built on). Full report: `P:\Astoria-Docs\mff_review.md`. MFF plays two roles — the IDE's own runtime dependency (`mff64.dll`) **and** a control library shipped to IDE users; severity depends on which (see report §0). **Any MFF source edit needs a `mff64.dll` rebuild (`FORCE_MFF=1`) to take effect.** All tasks gated on **T0**.*

- [x] ~~**T0 (posture decision)**~~ — **RESOLVED by owner 2026-07-12: patch locally, always.** MFF is now a **separately maintained fork with no upstream sync** — all source (incl. modifications) is published on GitHub, satisfying LGPL's make-available obligation; the `COPYING.LGPL*` notices in the tree cover notice-preservation, and git history is the record of what the fork changed. So: (a) fix MFF freely in place, no upstream-compat constraint; the `UPSTREAM.md`/baseline-pin idea is **dropped as low-value** (no sync relationship to diff against). **One sub-decision still open, now purely internal (not upstream-driven):** which standalone controls to drop from `mff64.dll`. **NOTE: the earlier "~150 unused files" was wrong** — dependency analysis (2026-07-12) shows most non-directly-included modules are foundational types the used controls need transitively (`Integer`/`Sys`/`Control`/`Object`/`Font`/`Brush`/`UString`/`List`/`Bitmap`/etc., referenced by dozens-to-hundreds of mff files — dropping any breaks the build). The genuinely-droppable set is **~15–20 standalone widgets** the IDE never uses. Since MFF is owned code, keeping an unused widget is nearly free (DLL size only), so **keep the form-building staples** (`Chart`, `Grid`/`GridData`, `DateTimePicker`, `MonthCalendar`, `NotifyIcon`, + situational: `WebBrowser`, `IPAddress`, `Header`, scrollbars, `PageScroller`, `SystemInformation`; `PrintDocument` is already lightly IDE-wired) and **actively drop only `HTTPServer`** (security liability, kills the F-N* class) **+ legacy cruft** (`ListItemsOld`, `Animate`). Keep the HTTP *client* (IDE uses it). If HTTPServer is dropped, the F-N* tasks (T-OPUS-3 / T-SON-1 / T-SON-2 / T-HAIKU-1) disappear. Decide before starting them. **✅ DONE + owner-verified 2026-07-12: `HTTPServer` + `Animate` + orphaned `ListItemsOld` dropped** (removed the 2 `#include`s + 4 factory `Case` entries from `mff/mff.bi`, `git rm`'d the 6 files, cleaned the now-dead `src/` refs — `TabWindow.bas:3684` HTTPServer event-case, `Main.bas:3419` Animate toolbox-exclusion — and the 2 stale `ControlParent.csv` HTTPServer-child rows). `mff64.dll` rebuilt (`FORCE_MFF=1`), IDE relinked + toolbox verified: `HTTPServer`/`Animate` gone, `HTTPConnection` client kept, other controls fine. **Component discovery is fully dynamic** (`Main.bas:5402` `Dir()`-scans mff `*.bi`/`*.bas`), so deleting the files auto-removed them from the Designer — no manifest to maintain.
- [x] ~~**T-OPUS-1 — resolve the `ThreadsEnter`/`ThreadsLeave` contract (F-M1).**~~ — **✅ DONE 2026-07-12 (Opus), `2aee074`.** Decision: **formalize as no-ops + mandate marshaling; do NOT add a lock.** A real critical section would be *wrong*, not a fix — Win32 controls have thread affinity (a worker touching a control is undefined regardless of any lock), and a global lock held by a worker that then repaints/`SendMessage`s the UI thread deadlocks (exactly the DR-3 hang); they're a GTK-ism with no Win32 equivalent. Survey: **69 `ThreadsEnter` sites in `src/`, 0 in MFF itself.** Added an authoritative "intentional no-op, DO NOT add a lock" block comment at `Component.bas` stub + the marshal-to-UI rule; rewrote `THREADING.md` from "kept for API consistency" to the real contract (blocks guarantee NOTHING; marshal via the debugger's `RefreshDebugPanelsAfterStop`→`TimerProcGDB`→`Fill/FlushDebugPanelsOnUI` pattern; legacy sites migrated opportunistically — debugger done, compile/find latent). Comment+doc only → zero behavior change, `mff64.dll` byte-unaffected. **Note:** the ~69 legacy worker→UI sites remain latent races (each a potential DR-3/DR-7); this task *decided the contract and documented the fix path*, it did not retro-marshal all 69 (that's ongoing, per-symptom).
- [x] ~~**T-OPUS-2 — audit `UString.AppendBuffer`/`Resize` accounting (F-M2).**~~ — **✅ DONE 2026-07-12 (Opus).** **Audit verdict: the IDE's reachable UString surface is memory-safe.** `Resize` is live (`BuildService.bas:353`) but used safely (resize-then-fully-overwrite via `MultiByteToWideChar`; the "destroys content on grow" quirk is harmless there). `operator[]` bounds-guard correct (per review). **`AppendBuffer` was genuinely memory-unsafe but DEAD** (`Private`, zero callers anywhere — only a binary `.chm` match), so the bugs were inert: `m_Data` is a `WString Ptr` yet `m_BufferLen` is a byte count, so `memcpy(m_Data + m_BufferLen, …)` wrote at *double* the correct offset (`m_Length*4` not `*2`); `newLen`/null-terminator mixed chars+bytes; `Resize` (dealloc+calloc) would lose content mid-append. Fixed anyway (shipped framework code): rewrote `AppendBuffer` with byte-accurate offsets + content-preserving grow + consistent field updates, deriving length from `m_Length` (authoritative) not the flaky `m_BufferLen`. **Boundary test (`-exx`, throwaway) also exposed + fixed a pre-existing bug: the `UString(WString)` constructor never set `m_BufferLen`** (unlike the `String`/`ZString` ctors) — `m_BufferLen` is a UString-internal field with no external readers, so inert, but fixed for invariant consistency. All boundary cases (empty/nonempty/multi/large/repeated/odd-bytes) pass bounds-checked. `mff64.dll` rebuilt, IDE relinked + smoke-tested. **(Opus)**
- [x] ~~**T-OPUS-3 — `HTTPServer` memory-safety + traversal hardening (F-N1/N3/N4).**~~ — **MOOT: `HTTPServer` dropped from the build (2026-07-12), so the leak / UAF / broken-decoder / traversal findings no longer ship.** Nothing left to harden.
- [x] ~~**T-SON-1 — `HTTPServer` DoS caps + safe bind (F-N2/N5).**~~ — **MOOT: `HTTPServer` dropped.**
- [ ] **T-SON-2 — `HTTPConnection` hardening (F-N7).** *(Still live — this is the HTTP **client**, which the IDE uses and we KEPT.)* Optional response-size cap; make the hardcoded spoofed Chrome User-Agent a property with a neutral default; document the blocking 3×`Sleep(1000)` retry. **(Sonnet)**
- [x] ~~**T-SON-3 — unchecked-`Open` sweep in MFF (F-R-mff).**~~ — **✅ DONE 2026-07-12 (Sonnet).** Guarded all 8 call sites (`SaveToFile`/`LoadFromFile` ×2 each in `CheckedListBox.bas`, `ComboBoxEdit.bas`, `ListControl.bas`; `BitmapType.SaveToFile` in `Bitmap.bas`). Used MFF's own established convention (`Result = Open(...) : If Result = 0 Then …`, matching `Application.bas:106,637`) rather than a `MsgBox`/`ShowMessages` popup — these are generic library controls used by any host app, not IDE-specific code, so no IDE UI channel is appropriate; a failed open now just skips the read/write (control ends up cleared/unchanged) instead of writing to or reading from an unopened file number. `Bitmap.bas`'s `SaveToFile` returns `Boolean`, so it now returns the real `Open` result instead of a hardcoded `True`. *(The `Animate.bas:335` site from the review is gone — Animate was dropped.)* `mff64.dll` rebuilt (`FORCE_MFF=1`), IDE relinked + smoke-tested. **(Sonnet)**
- [x] ~~**T-SON-4 — `Registry` robustness (F-R-reg).**~~ — **✅ DONE 2026-07-12 (Sonnet).** **Key finding: `Registry.bi` is NOT included by `mff.bi` at all** (confirmed — not in its include graph, and `mff64.dll` is byte-identical before/after this change), so `Registry.bas` is orphaned source, not shipped in the DLL, same class of finding as the dead-code items closed in the Phase 4 sweep. Fixed anyway (owned framework source; cheap and correct to fix while touching it) and validated against a real (disposable, self-cleaning) `HKEY_CURRENT_USER` test key: (1) `ReadRegistry` rewritten to the standard two-call dynamic-size pattern — the old fixed 2048-byte buffer didn't truncate, it silently returned `""` for any longer value (`RegQueryValueEx` fails `ERROR_MORE_DATA`, skipping the decode entirely); verified a 2999-char value now reads back exactly. (2) **Found + fixed a real correctness bug beyond the review's scope, verified by raw-byte dump:** `WriteRegistry`'s `ValString` path used a `String * 2048` (1 byte/char, ANSI) buffer but calls the *wide* `RegSetValueEx` API (`W`-variant, since `Section`/`Key` are `LPCWSTR`) — every REG_SZ write was corrupted (interleaved with null bytes, non-roundtripping). Switched to `WString * 2048` + correct byte-length arg; roundtrip now verified exact. (3) `WriteRegistry` now checks `RegCreateKey`'s result (was discarded — a failed key-create fell through to `RegSetValueEx` on an invalid handle) and validates `ValDWord` input is numeric before `CUInt` (was silently writing 0 for garbage input). All 5 boundary checks pass (DWORD roundtrip, invalid-input rejection, string roundtrip, >2048B read, missing-value no-crash). *(Scope note: the write-side 2048-char cap on strings is unchanged — only the review's two specific findings, read-truncation and write-validation, were in scope; unimplemented `InTypes` other than `ValDWord`/`ValString` remain no-ops, as before.)* No `mff64.dll`/`astoria.exe` change needed (confirmed byte-identical rebuild). **(Sonnet)**
- [x] ~~**T-HAIKU-1 — remove debug `Print` in `HTTPServer.bas:165` (F-N6).**~~ — **MOOT: `HTTPServer` dropped.**
- [ ] **T-DEFER (MFF) — not blocking:** widget-trimming **partially done** (F-H3 — `HTTPServer`/`Animate`/`ListItemsOld` dropped 2026-07-12; the remaining ~12–17 keep-listed widgets are deliberately retained per the T0 note). **CN/example baggage (F-H2) — ⚠️ partially a landmine:** `README_CN.md`/`changes_cn.txt` are safe to delete, but **`MyFbFramework.wiki/` is NOT baggage — the IDE reads it live for component help (`Main.bas:5420` `wikiFolder`), so deleting it removes toolbox component docs;** `examples/`/`help/` need a usage check first (not yet done). `Canvas` GDI-handle audit (F-R-gdi) — revisit only on observed long-session handle growth. Revisit the rest with owner appetite.

### Immediate (stubs & bugs)

- [ ] **Consolidate the Run menu (owner-flagged, 2026-07-12)** — the Run menu currently splits related actions across the top-level menu and a **More Build Options** submenu (e.g. "Run" (F5, compiles first) is top-level, but "Run Without Building" (Ctrl+F5) is buried in the submenu) — owner found this confusing while trying to locate a specific entry during DR-16(a) testing. Consolidate into one flat menu.
- [ ] **Toolbar icon tooltips (owner-flagged, 2026-07-12)** — some toolbar icons show no tooltip on hover. Audit all toolbar buttons and ensure every one has a tooltip/hint assigned (owner doesn't use icon-only navigation and relies on tooltips to identify them).
- [ ] **`RunProgram` (non-debug Run) has no missing-exe check (found 2026-07-12, testing DR-16(a))** — `RunProgram`→`RunPr` (`TabWindow.bas`) builds the launch command line and calls `CreateProcessW` directly with no `FileExists` check anywhere, unlike the debug path (`load_file`/`PrepareDebugSession`, now fixed under DR-16(a)). Owner deleted `Project3`'s exe and clicked plain "Run" (`UseDebugger` off) — nothing visible happened, no error, no message. Pre-existing gap, not touched by this session's work; would need its own `FileExists` check + user-visible message (same message text as `load_file`'s would fit) added to `RunProgram` before the `RunPr` call.
- [x] ~~**Theme re-curation (owner picking their own set)**~~ — **DONE 2026-07-11 (`5c50f20`).** Owner browsed the temporarily-restored 96 themes in Options ▸ Themes and picked a final 12: Default Theme, dracula, github, gradient-dark, hopscotch, kimbie.dark, kimbie.light, monokai, night-owl, purebasic, qtcreator_dark, qtcreator_light. The other 84 `Settings/Themes/*.ini` deleted (recoverable from git history). Verified 2026-07-12: `Settings/Themes/` has exactly 12 `.ini` files, matching the commit.
- [ ] **Decouple user color-tweaks from shipped theme files (T15 memo, fact 5)** — *deferred owner question, surfaced by the T15 theme-catalog memo but never given its own tracked item (found stale/dropped 2026-07-12).* Per `P:\Astoria-Docs\fable_t15_theme_catalog.md` fact 5: if a user tweaks colors within a shipped theme (e.g. via Options ▸ Themes color pickers), those edits currently write back into the shipped `Settings/Themes/*.ini` file itself — so a future app update that re-ships/updates that theme file would silently clobber the user's customization. Consider separating user overrides into their own file/section that layers on top of the shipped theme rather than mutating it in place. Owner call on whether/how to prioritize.

- [x] ~~**frmNewProject icons**~~ — **closed 2026-07-08 as not-reproducible (B2).** Owner confirmed all 5 default templates (Windows/Console/Dynamic/Static/Control) show correct icons at >100% display scaling; traced the load path (`ImageList.Add` → `BitmapType.LoadFromResourceName`'s disk-file fallback reading `Resources/App*.png`, all correctly 32×32) and found no defect. Closed as already-working rather than risk an unnecessary change. (This resolves the earlier contradiction where §6 still listed it as an open bug.)
- [x] ~~**B3 `OpenRecentFiles()` dialog**~~ — **fixed 2026-07-10 (Sonnet)**, real bug, not a stub. The dialog-based design (`OpenRecentFiles()`/`frmRecentFiles`) this item originally described was superseded at some point by a live **File ▸ Recent Files submenu** (`miRecentFiles`, populated via `AddMRU`/`mClickMRU` — individual entries open on click, plus a "Clear Recently Opened" item) — that part already worked. But the menu item itself had a stray `Visible = False` set at creation (`Main.bas`) that was never restored anywhere, so the whole feature was permanently invisible in the File menu regardless of how many recent files existed; separately, the submenu was never populated from the INI-loaded MRU list at startup, only lazily rebuilt once a file was opened *this* session. Fixed by dropping the `Visible = False` and factoring the item-population logic (previously only inside `AddMRU`) into a shared `RebuildMRUMenu` helper called both from `AddMRU` and once at menu-creation time right after the MRU list loads from the INI — the item is now visible immediately on startup, populated with prior sessions' recent files, and greyed out (not hidden) only when the list is genuinely empty. Compile-clean, launch-tested (process stays responsive).
- [x] ~~**`DeleteEditorFile` project-member `.vfp` sync**~~ — **already done** (found already implemented on review, 2026-07-10; landed in `331b570`, 2026-07-09, undocumented at the time). `DeleteEditorFile` (`Main.bas:1190-1199`) marks the file `ee->PendingDelete` and dirty-flags the project node (`*` suffix); `SaveProject` (`Main.bas:1730-1759`) excludes pending-delete files from the written `.vfp`, then only deletes from disk + removes the tree node after that write succeeds (`Main.bas:1864-1875`) — a full deferred-delete-until-save flow (with a "Cancel Deletion" undo path) that goes further than the originally-scoped dirty-mark mirror.
- [ ] **Toolbar persistence re-test** — confirm the Run-toolbar fix (2026-07-07): hide Run → close via window X → relaunch → stays hidden; `ShowBuildToolBar` gone from INI. Needs GUI.
- [ ] **Audit: is "External Editors" actually gone?** — *owner note, 2026-07-11 smoke test:* owner's understanding is this was removed "many cycles ago," distinct from and superseding External Tools. But this session's `frmPath` fix touched live code for it: `frmOptions.frm`'s `cmdAddEditor_Click`/`cmdChangeEditor_Click` (`lvOtherEditors` list, Options ▸ Code Editor ▸ Other Editors page), the `OtherEditors` Dictionary loaded from the INI's `[OtherEditors]` section (`SettingsService.bas`), and a double-click-to-launch path in the Project Explorer (`tvExplorer_NodeActivate`, `Main.bas` — the one T3 moved off the UI thread) that checks a file's extension against `OtherEditors` and launches the registered program via `PipeCmd`. None of this looked like dead/unreachable code from a static read — reconcile which is true: (a) the UI is hidden/inaccessible somewhere and this is genuinely orphaned code worth deleting, or (b) it's still live and the owner's "removed" understanding is about a *different*, now-conflated feature. If (a), remove the Options page, the Dictionary load/save, and the double-click dispatch together (cross-reference sweep first, per §9).
- [ ] **GDB smoke test** — Step Out, rapid step/continue queue, Break while running — pending owner verification (§7)
- [ ] **Breakpoint-during-debug pipe race (was misfiled as a repaint glitch)** — **➡️ Now tracked under the [Debugger Reliability sub-project](#-active-sub-project--debugger-reliability-queued-2026-07-11) as DR-1; BUG A/BUG B below are DR-2/DR-3; a new DR-4 (gutter-click blanks the editor) was added 2026-07-11. The detailed attempt-#1/#2 history in this item stands as the reference.** *owner-reported 2026-07-08, investigated by Sonnet 2026-07-08, escalated to Opus (`.claude` task).* Not a cosmetic paint bug: `PaintControl`/`PaintControl(True)` are actually identical (`PaintControlPriv` forces `bFull = True` unconditionally, `EditControl.bas:4051`), so the original "missing full repaint" hypothesis is disproven. Real cause: `Case "Breakpoint"` (`VisualFBEditor.bas:761`) calls `set_bp` (`Debug.bas:1791`) **only when `iFlagStartDebug = 1`** (i.e. only while actively debugging) — matching the owner's report that this appeared right after a live debug session. `set_bp` sends `break`/`tbreak`/`clear` via `run_pipe_write` + a **direct synchronous `readpipe()` call on the UI thread**, but the debug session's dedicated worker thread (`Debug.bas` ~2024+) is *simultaneously* running its own GDB read/dispatch loop on the **same shared pipe handles** (`Dim Shared As HANDLE hReadPipe, hWritePipe`, `Debug.bas:382`). Every other debug command (Continue, Step, etc.) avoids this by going through the mutex-protected `EnqueueDebugCommand` queue that the worker thread drains safely (`Debug.bas:325`, `:2031`) — `set_bp` is the one command that bypasses the queue and races the worker thread's reads on the same handles. Genuine correctness bug (GDB's response to `break ...` can be stolen by whichever thread's `ReadFile` wins), not just cosmetic — the blank-editor symptom is a plausible downstream effect of the worker thread stalling on stolen output. **Fix needs care:** route `set_bp`'s commands through `EnqueueDebugCommand` like Continue/Step, then handle the "breakpoint set" confirmation asynchronously without blocking the UI thread — requires live GDB verification during an active debug session (same fragile-core/live-verify bar as R5). Assigned to Opus, not Sonnet.

  **Opus attempt #1 (2026-07-08) — reverted, introduced a lock.** Tried exactly that: `set_bp` enqueues `break`/`tbreak`/`clear`, and the worker loop got a "drain-only" branch (`writepipe(cmd) : readpipe()`, no stop-processing) for those commands. Compiled clean but **owner live-test hit a hard lock** (set a breakpoint, a couple of Step-Into, then Run → froze). Reverted `Debug.bas` to the R5 commit; rebuilt known-good. **Lessons for attempt #2:**
  - The drain-only `readpipe()` **blocks (polls forever) if GDB isn't at the prompt** when the break command is dequeued (e.g. a `break` dequeued right after a `c\n`/step that set `Running=True`, so the inferior is running) — and it holds `tlockGDB` while blocked, so the UI thread deadlocks on its next lock. A correct fix must only send break/tbreak/clear **while the inferior is stopped** (not just "when dequeued"), or must not hold `tlockGDB` across a blocking read.
  - **Path facts (verified):** `F9` is the menu "Breakpoint" command (`HotKeys.txt: Breakpoint=F9`) → `mClick` → `set_bp` + `ec->Breakpoint`. **Gutter-click goes through `EditControl.Breakpoint` only — it never calls `set_bp`** (0 hits in `EditControl.bas`), so a gutter-set breakpoint mid-session toggles only the local icon and is *not* sent to GDB until the next run. So `set_bp` (F9/menu) is the only mid-session→GDB path.
  - **Pre-existing ordering bug (not mine):** in `mClick`, `set_bp` runs *before* `ec->Breakpoint`'s blank/comment-line check, so F9 on a comment line enqueues a bad `break` to GDB even though the local toggle is (correctly) refused with the "Don't set breakpoint to this line" MsgBox → GDB/local divergence.
  - **Strong recommendation for attempt #2:** do NOT keep guessing — instrument the queue / worker loop / `set_bp` with file-trace (`DbgTraceCP`-style), have the owner reproduce the exact set-bp → step → Run lock, and read the command/response sequence + where it blocks. Then fix precisely (likely: gate break-command send on `Not Running`, and move the comment-check ahead of `set_bp`).

  **Opus attempt #2 (2026-07-11) — code done, compile-clean, ⚠️ owner live-verify still owed.** Took the *smaller* of the two paths the lessons pointed at — **do not touch the worker loop at all** (attempt #1's worker-loop "drain-only" branch was what mis-synced and locked). The whole fix lives in `set_bp` (`Debug.bas`):
  - **(comment-check moved ahead of the GDB send)** `set_bp` now resolves the selected line up front and `Exit Sub`s on a blank/`'`/`rem` line *before* any `run_pipe_write`, mirroring `EditControl.Breakpoint`'s own refusal (operands `CInt`-wrapped to match that code and clear FB warning 38). F9 on a comment line no longer plants a phantom GDB breakpoint while the editor declines the local toggle.
  - **(serialize + never send while running)** the `break`/`tbreak`/`clear` + `readpipe()` block is wrapped `MutexLock tlockGDB` … `MutexUnlock tlockGDB`, with `If Running Then MutexUnlock tlockGDB : Exit Sub` immediately after the lock. **Why this is race- and deadlock-free:** `Running` is only ever flipped by the worker *under this same lock*, and the worker's **only** unlocked pipe access is its `readpipe(True)` at `Debug.bas` ~2077, which runs only while `Running=True`. So holding the lock with `Running=False` proves the worker is not mid-read — `set_bp` reads a stopped GDB (at the prompt, so `readpipe()` returns promptly, never the off-prompt block that hung attempt #1). If `Running=True`, `set_bp` bails and the local icon still toggles (`EditControl.Breakpoint`); `run_debug` re-sends every editor breakpoint on the next run, so nothing is lost.
  - **Residual (documented, not the reported bug):** `run_debug`'s pre-loop startup sequence (`b 1` / per-line `break` / `r`, `Debug.bas` ~2014–2043) does its pipe I/O on the worker thread **before** the loop takes `tlockGDB` and sets `Running=True`. A F9 fired in that sub-second startup window is still unserialized — but its worst case is a garbled/missed breakpoint at startup, **not** the hard lock (nothing does an off-prompt blocking read here). Closing it fully means wrapping that setup block in `tlockGDB` too; deferred to avoid widening the fragile-core change until the primary fix is owner-verified.
  - **Owner verify checklist:** (1) start debug, stop at a breakpoint, F9 a *new* breakpoint, Step-Into a couple of times, then Run — must **not** freeze (this was attempt #1's hard lock); (2) F9 on a comment/blank line mid-session — MsgBox refuses locally and GDB stays consistent; (3) toggle a breakpoint off (F9 on a bp line) while stopped — clears cleanly; (4) normal breakpoint → run → hit → inspect → continue still works. If any freeze recurs, re-add the file-trace and capture the interleaving before further changes.

  **Owner live-verify (2026-07-11) — FAILED, two *separate* pre-existing debugger bugs found (⏸️ investigation paused for a cross-machine handoff; resume here).** Neither is caused by the `set_bp` change (that only touches the F9 path; both symptoms are in the F8/step + highlight paths):
  - **BUG A — Step Into does not highlight or scroll to the current line.** On a *single deliberate* Step Into: the code viewport does **not** move to the debug line, and the executed line is **not highlighted even after the owner manually scrolls to it**; subsequent steps also produce no highlight. So this is **not** the rapid-step desync — it's a genuine failure of the stop→highlight handoff. Path to investigate: worker sets `fcurlig` (in `line_highlight`, `Debug.bas:765`, after forcing `fcurlig = -2` at `Debug.bas:2134`); UI-thread `TimerProcGDB` (`Main.bas:3028`, started via `SetTimer(...,@TimerProcGDB)` at debug-start) is supposed to read `fcurlig`, then `SetSelection`/`CurExecutedLine = fcurlig-1`/`PaintControl`. Since *neither* the scroll (`SetSelection`) nor the paint (`CurExecutedLine`) happens, suspect: `line_highlight` never setting `fcurlig` to a real line (annotation not parsed → stays `-2` → timer takes the Output-tab branch), or the timer not firing / `CurEC` wrong / `ChangeEnabledDebug` path. **Confirm with a trace of `line_highlight`'s parse result and what `TimerProcGDB` actually does each tick before changing code.** (Note §7 lists "Step into — line highlighting advances correctly — owner verified" from an earlier build, so this may be a regression somewhere between that and now, or a display-scaling/tab-target difference — the trace will tell.)
  - **BUG B — rapid F8 (Step Into held/mashed) hangs the app.** Root-caused statically: the worker loop dequeues and `writepipe`s a new command even while `Running=True` (`Debug.bas:2056`–2069 — branch 1 fires regardless of `Running`), so mashed F8 sends `s`,`s`,`s` back-to-back; the worker reads step 1's stop, then `RefreshDebugPanelsAfterStop` (`Debug.bas:1986`) reads the **leftover** step-2/step-3 annotations instead of its `_l_`/`thread`/`print` responses → read-stream desync → a later `readpipe` waits for a `(gdb)` prompt already consumed and blocks forever (PeekNamedPipe 0 bytes) → hang. **Planned fix (needs trace confirmation first):** reorder the worker loop to strict lockstep — priority `Running` (read pending stop) → `bPendingDebugPanelRefresh` (refresh) → *then* dequeue/send the next command — so no command is sent until the previous one's stop is read and panels refreshed. Preserve the intricate `bGDBLocked` lock bookkeeping exactly. Verified safe against the "End while running" path: `q\n` is only ever enqueued when *not* running (`AstoriaIDE.bas` End case uses `kill_debug` directly while `Running`), so gating dequeue on `Not Running` doesn't strand a quit.
  - **Resume plan:** (1) re-add focused file-trace (worker dequeue+`Running`, each write/read result, `line_highlight` parse outcome + `fcurlig`, `TimerProcGDB` action per tick); (2) owner reproduces BUG A (single step) and BUG B (mash F8); (3) read the interleaving; (4) fix BUG B via the lockstep reorder and BUG A per what the trace shows; (5) remove trace, rebuild, owner re-verify the full checklist above. The `set_bp` fix itself is believed sound but is **not yet owner-verified** (verification was interrupted by these two bugs) — re-run checklist items (1)–(4) once A/B are fixed.
- [ ] **Gutter-click breakpoint blanks the editor (DR-4, new 2026-07-11)** — *owner-reported; reproduces **only while the debugger is active** (owner-confirmed: no repro with the debugger off).* Clicking the gutter to toggle a breakpoint makes most displayed lines disappear until you click back into the code window. **Path traced 2026-07-11:** gutter-click → `WM_LBUTTONUP` (`EditControl.bas:6990`) → `EditControl.Breakpoint` (`:233`) → toggles `FECLine->Breakpoint` + calls `PaintControl`. It **never** calls `set_bp` or the parent `Case "Breakpoint"` dispatch (`AstoriaIDE.bas:595`), so **no GDB path is involved — this is not DR-1's pipe race.** `EditControl.Breakpoint` runs identical code whether debugging or not, so the difference is that **`PaintControl` renders incompletely while a debug session is active**: the paint code branches on the executed-line highlight state (`CurExecutedLine`/`OldExecutedLine`/`CurEC`, `EditControl.bas:3227/4366/5030`), which is only populated during debug. **Strong hypothesis: same root cause as DR-2** (the debug-mode paint pipeline is broken) — both a step (DR-2) and a gutter-toggle (DR-4) call `PaintControl` mid-debug and both misbehave; investigate together, and expect the trace of `TimerProcGDB`/`line_highlight`/`PaintControl` to cover both. "Click in the code window restores it" is a focus/caret event forcing a fuller repaint. Tracked under the [Debugger Reliability sub-project](#-active-sub-project--debugger-reliability-queued-2026-07-11) as DR-4.
- [ ] **Designer/Property undo-redo not recorded** — *pre-existing, surfaced during the P4 live-test 2026-07-07.* Undo/redo works for **text-editor** edits but **not** for changes made in the visual Designer or the Property tab. Likely cause: Designer/property-grid-driven code changes write to the source via a path that doesn't push an entry onto the `EditControl` undo stack, so there's nothing to undo. Designer undo is genuinely hard; scope with owner before attempting. Good candidate for the file-trace method (log the property-apply/designer-move → undo-stack path). Not P4-related (confirmed on the clean baseline).
- [ ] **Ctrl+Y = "Cut Current Line" (approachability gotcha)** — *surfaced 2026-07-07.* Redo is `Ctrl+Shift+Z` (intentional default, three sites + `HotKeys.txt`), which is fine; but `Ctrl+Y` is bound to **Cut Current Line** (`Main.bas:5802`). Returning QBasic/VB users reflexively press Ctrl+Y expecting *redo* and instead delete the current line. Consider for the §13.3 approachability pass (e.g. also bind Ctrl+Y → Redo, or surface the mapping). Owner decision, not a bug.

### Low-priority cleanup

*(`src/makefile` and `src/THREADING.md` GTK-reference entries removed 2026-07-07 — both were already resolved by commit `6b3200a`; the Open Items entries had just gone stale. See §13.3.A S5–S7 execution.)*

### Queued for Cursor

- [ ] **MFF control library path consolidation** — one DLL → one `Library` object with one canonical path; retire `GetModuleFileNameW` workaround in `Designer.Symbols` (§8)

### Deferred enhancements (nice to have, not blocking)

- [ ] **2.2.3 Split oversized files** — `TabWindow.bas` (576 KB), `Main.bas` (412 KB), `EditControl.bas` (316 KB) (§13.2)
- [ ] **13.9 Blank Designer page on cold-open** — `PagePanel` page shows blank until a control is selected; cosmetic only (§13.9)
- [ ] **13.10 Dark mode: owner-drawn popup menus + input-field polish** — `WM_DRAWITEM ODT_MENU` handler is an empty stub; input-field faces stay light (§13.10)
- [ ] **13.11 Dark mode: dark dialog backgrounds** — `WM_ERASEBKGND` not filled with dark brush; gate on window class (§13.11)
- [ ] **13.12 Dark mode: Options ▸ Apply doesn't fully re-theme open panels live** — owner smoke test 2026-07-11: toggling Dark Mode + Apply updates some controls immediately (a text box confirmed) but others stay light until relaunch; full theme is correct on next launch. `SetColors` (called on Apply) is a false lead — syntax-highlighting colors only, not the app theme; real mechanism is `App.DarkMode` → `SetDarkMode(Value, False)` (`Application.bas:53-56`), whose implementation wasn't located before this was deferred. See ROADMAP §13.12 for the traced call chain (§13.12)
- [ ] **13.8 Design-workspace status bar** — three-cell status bar docked to `pnlForm`; researched, non-trivial (§13.8)

### Unscheduled / future planning

- [ ] **13.3 UI review** - File + Edit owner-approved; Search → Define (F2) reliability improved. **13.3.A S1–S7 executed and committed (Sonnet 2026-07-06/07, Opus-reviewed)** — see [13.3.A execution](#133a-execution--s1s4-done-sonnet-2026-07-06-opus-reviewed--committed-2026-07-07) above; this already restructured every menu including View (Fold submenu, Debug Windows split). **Owner walkthrough/sign-off of the View menu** is the next step-by-step checkpoint (design/implementation done, approval pending).
- [ ] **13.2.1.1 Standardize indentation** — convert mixed tabs/spaces across all source files (§13.2)
- [x] ~~**13.4 Rename the project**~~ — **DONE 2026-07-10** (`c93abbe`): renamed to **AstoriaIDE** (`astoria.exe`, `Settings/astoria.ini`, `AstoriaIDE.bas/.rc/.vfp`); see ROADMAP §13.4 for the full touch-point list. GitHub repo name/clone URL intentionally left unchanged (separate decision).
- [ ] **13.5 Standard Windows installer** — Inno Setup or WiX; project-rename decision is now resolved (§13.4 done), so this is unblocked (§13.5)
- [ ] **13.6 Full review/expansion of Examples/** — re-verify all examples compile; fix `WellCOM` DllMain; add appealing demos (§13.6)
- [x] ~~**13.7 Enhance AI integration**~~ — **REVERSED by owner 2026-07-09**: AI subsystem being removed entirely instead (see ⭐ AI Agent subsystem removal sub-project above; ROADMAP.md §13.7)
- [ ] **Upstream sync strategy** — this fork intentionally diverges; merge only with explicit plan
- [ ] **Wiki/docs** — fork-specific documentation
- [x] ~~**Basic CI**~~ — **DONE (T8, `a132e23`).** `.github/workflows/windows.yml` checks out with `actions/checkout@v4` and calls the repo's own `Compile.bat` directly (removed the three unverified 7-Zip/FreeBASIC/upstream-MyFbFramework downloads), so CI proves the self-contained build and fails on real compiler errors rather than just missing output.

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
- **Every session ends with a compile-clean commit + push to GitHub** (added 2026-07-03; compile-clean gate added 2026-07-03 after a second-AI audit flagged the risk of pushing broken intermediate state; **remote switched from Codeberg to GitHub 2026-07-09, Codeberg retired**) — run `Compile.bat` and confirm **0 errors** first. Only if the compile is clean should you commit any outstanding working-tree changes (status doc updates, INI/scratch state, etc.) with a sensible message, then `git push origin main`, as the last action before signing off for the day. If the compile fails and can't be fixed in-session, say so and hold off on the commit/push rather than pushing broken code. This is a standing instruction, not a one-time request — don't wait to be asked again in future sessions.
- **INI key migration** (added 2026-07-03, second-AI audit) — new keys must ship with a default (never assume an existing user's INI has it); never rename or repurpose an existing key without a migration read of the old key name first, so existing users' settings aren't silently orphaned. This was the rule §13.4's rename followed when it renamed `Settings/VisualFBEditor64.ini` → `Settings/astoria.ini` (existing settings preserved, not a fresh file); applies to any INI key work going forward.
- **WinAPI only** — do not reintroduce GTK/Linux IDE paths
- Close running IDE before rebuild
- `set NOPAUSE=1` for agent compile runs
- Prefer `Compile.bat` over ad-hoc `fbc64` unless debugging
- **Compile logs** (added 2026-07-05) — all compile log output goes to `Logs/<name>.txt`; delete contents of `Logs/` at the end of each session. `Logs/` is in `.gitignore`.
- **Cross-reference before deleting/moving** (added 2026-07-05) — after deleting or moving any item (menu item, control, function, variable, etc.), search the entire `src/` tree for references to that item and update or remove them before proceeding. A clean compile is not sufficient — dormant paths like `ChangeMenuItemsEnabled` can hold stale references that only trigger at runtime.
- **Model-assignment check** (added 2026-07-11, owner rule) — when the owner starts a task that this document assigns to a **different** model (e.g. a T1–T16 row, or any task with an explicit "Owner: Sonnet/Opus/Haiku/Fable" designation), the session's model must **warn the owner of the mismatch before doing any work** — state which model the task is assigned to and why (the assignment tiers exist because fragile-core work needs the live-verification bar and mechanical work shouldn't burn review-tier capacity). Proceed only if the owner confirms after the warning; a confirmation is per-task, not standing. Tasks with no recorded assignment need no warning.

---

## 10. Key files map

| Area | Files |
|------|--------|
| Entry point | `src/AstoriaIDE.bas` (renamed from `src/VisualFBEditor.bas`, §13.4) (`_NOT_AUTORUN_FORMS_`) |
| Main UI & panels | `src/Main.bas`, `src/Main.bi` |
| Toolbar / commands | `src/AstoriaIDE.bas` (`PinBottom`, etc.) |
| Settings load/save | `src/SettingsService.bas`, `Settings/astoria.ini` |
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
| 13.3 | UI evaluation & modernization | **In progress** — File + Edit owner-approved; 13.3.A S1–S7 committed (restructured every menu incl. View); owner sign-off on View menu next |
| 13.4 | Rename project | **Done (2026-07-10)** — renamed to **AstoriaIDE** (`c93abbe`) |
| 13.5 | Standard Windows installer | Unscheduled — 13.4 dependency now resolved |
| 13.6 | Full review/expansion of Examples/ | Unscheduled — doc/polish phase |
| 13.7 | ~~Enhance AI integration~~ | **Reversed (owner, 2026-07-09)** — AI subsystem being removed entirely; see AI-removal sub-project |
| 13.8 | Design-workspace status bar | Deferred — non-trivial |
| 13.9 | Blank Designer page on cold-open | Deferred — cosmetic only |
| 13.10 | Dark mode popup menus + input polish | Deferred |
| 13.11 | Dark mode dialog backgrounds | Deferred |
| 13.12 | Dark mode: Options Apply doesn't fully re-theme live | Deferred — owner smoke test 2026-07-11 |

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
- **Target length:** aim to keep this document under ~800 lines (currently ~1,150, down from ~1,220 after the T14 consolidation pass archived the dated header pile, the AI-removal task list, and the C4 write-up to [HISTORY.md](HISTORY.md)). Still over target — the remaining reduction lever is archiving more of the completed session-narrative sections (§"Opus Next Steps backlog", the two §13.3.A execution logs, the Search-menu investigation record) to HISTORY.md. If it grows again, move content to the companion files below rather than expanding this file.
- **Companion files:** [CHANGELOG.md](CHANGELOG.md) (completed work + commit log), [HISTORY.md](HISTORY.md) (session history + bug investigations), [ROADMAP.md](ROADMAP.md) (full enhancement specs).

---

*End of status document.*
