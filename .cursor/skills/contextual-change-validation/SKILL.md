---
name: contextual-change-validation
description: Maps change surfaces from touched files and validates the full affected area — init paths, minimal-INI scenarios, compile, and area-wide user test checklists. Use when refactoring, changing UI or panels, editing startup/settings (LoadSettings, frmMain_Create, Main.bas), modifying SettingsService or VisualFBEditor64.ini, or before handoff for manual testing.
disable-model-invocation: false
---

# Contextual Change Validation

Validate the **context of the item being changed**, not just the individual item. All features in the affected area must be checked after a change.

## Step 1 — Map the change surface

From touched files, enumerate the full surface:

| Touched area | Expand to include |
|--------------|-------------------|
| Left panel | Toolbox tree, AI Agent tab, pin open/close, tab strip, `LeftClosed`, panel width, tab index persistence |
| Right panel | Properties/Events tabs, pin state, tab index persistence |
| Settings / INI | Every consumer of the changed key (`SettingsService.bas`, load/save callers) |
| Toolbox | Category nodes, Cursor tool, insert flow, library enable/disable, search/filter |
| Startup / Main | `frmMain_Create`/`Show`, `LoadSettings`, `LoadToolBox`, panel layout init |

List adjacent files and event handlers even if you did not edit them — they share init order and state.

## Step 2 — Init path audit

**Required when touching:** `LoadSettings`, `frmMain_Create`/`Show`, `LoadToolBox`, panel event handlers, or `SettingsService.bas`.

Check:

- Cold start (no prior session state assumptions)
- Order of operations: settings applied **before** visual state (e.g. tab index before `SetLeftClosedStyle`)
- Pin open/close restores saved tab indices
- First-run / missing INI keys use safe defaults
- No flash-expand or wrong initial layout on startup

**VFBE key files:** `src/Main.bas`, `src/SettingsService.bas`, `Settings/VisualFBEditor64.ini`

## Step 3 — Minimal-INI scenarios

Test mentally or via temp INI copies:

| Scenario | Keys / state |
|----------|----------------|
| Bare install | No `ControlLibraries` section |
| AI only | Only `DefaultAIAgent` set |
| Collapsed left | `LeftClosed=true` |
| Expanded left | `LeftClosed=false` |
| Saved tabs | `leftSelectedTabIndex` / `rightSelectedTabIndex` non-default |

Verify each scenario does not crash and respects saved layout.

## Step 4 — Compile

During development, use the debug build (runtime checks, symbols, no optimization):

```bat
CompileDebug.bat
```

Use `Compile.bat` only for release verification when explicitly requested.

**Gate:** 0 errors before handoff, Opus review, or user manual test.

## Step 5 — User test checklist template

Deliver a checklist for the **full area**, not a single fix. Copy and adapt:

```markdown
## [Area name] — manual test checklist

**Change surface:** [list features/panels/settings affected]

### Startup / layout
- [ ] Cold start with relevant INI variants (see Step 3)
- [ ] Pin open/close — layout and tab state correct
- [ ] Restart — persisted settings restored

### [Feature group 1 — e.g. Tree toolbox]
- [ ] [All behaviors in this group, not only the changed one]

### [Feature group 2]
- [ ] ...

### Regression (adjacent areas)
- [ ] [Panels, compile/run, property editing, etc. untouched but shared init]
```

## Step 6 — Code review scope (Opus / Bugbot)

When escalating or requesting review, include:

- **Diff description** covering the full change surface (natural language if git diff is unwieldy)
- **Adjacent init paths** — callers, load order, shared globals
- **Excluded scope** — obsolete features (e.g. dark mode) → dead-code cleanup, not actionable bugs

**Escalation:** Unresolved after **4 fix cycles** → Opus fix-review loop (max 5 iterations, user manual test only after Opus clean).

## Example — left panel refactor

From left-panel work; use as template for similar refactors:

**Left panel**
- [ ] Start with `LeftClosed=true` — panel stays collapsed, no flash-expand
- [ ] Pin-open — restores last selected tab (Project / Toolbox / AI Agent)
- [ ] Pin-close and pin-open again — tab selection persists across sessions
- [ ] Double-click tab strip toggles pin state

**Tree toolbox**
- [ ] Toolbox shows categories with Cursor children
- [ ] Click category header — selects Cursor (no stale tool)
- [ ] Activate a control — inserts on form designer
- [ ] After insert — selection resets to Cursor; required `#include` added
- [ ] Disable a control library — active tool resets safely
- [ ] Search/filter in toolbox still works

**Right panel**
- [ ] Pin-close then pin-open — Properties/Events tab restores (not blank)
- [ ] Tab selection persists across restart

**Regression**
- [ ] Bottom panel pin still works
- [ ] Form design, property editing, compile/run unaffected
