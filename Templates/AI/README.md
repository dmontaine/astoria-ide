# Templates/AI — per-tool AI-assistant guidance

Each subfolder here is a self-contained template that the **New Project** dialog
stamps, *wholesale*, into a newly created project when "AI friendly" is checked
and a tool is selected. The stamping copies the selected `Templates/AI/<tool>/`
folder into the project root (recursively), replacing tokens as it goes.

**This `README.md` and any `_`-prefixed file at this level are NOT stamped** —
only the selected `<tool>/` subfolder is. Keep maintainer notes here.

## Tokens

Replaced on stamping (see the plan's substitution helper):

| Token | Meaning |
|---|---|
| `{{PROJECT}}` | Project name |
| `{{AUTHOR}}` | Author (from Options ▸ Personal Information ▸ Name) |
| `{{YEAR}}` | Current year |
| `{{DATE}}` | Creation date |
| `{{LICENSE}}` | Selected license name |

## Folders

All five folders carry the same **default rules + skills set** (2026-07-16): a
shared canonical `AGENTS.md` (rules: language / build / Astoria-project /
editing discipline; skills: build-run, add-module, add-control-event, add-form,
fix-compile-errors), plus each tool's native convention on top.

| Tool | Primary file(s) | Status |
|---|---|---|
| `ClaudeCode/` | `CLAUDE.md`, `.claude/skills/*/SKILL.md` (5 skills), `AGENTS.md` | **Complete** |
| `Cursor/` | `.cursor/rules/freebasic.mdc` (always-on rules), `.cursor/rules/freebasic-tasks.mdc` (compact playbooks), `.cursor/skills/*/SKILL.md` (13 native Cursor skills), `.cursorrules` (legacy pointer), `AGENTS.md` | **Complete** |
| `ChatGPT/` | `AGENTS.md`, `.agents/skills/*/SKILL.md` (13 native Codex skills; inline fallback retained) | **Complete** |
| `OpenCode/` | `AGENTS.md`, `opencode.json` (references `.opencode/skills/`), `.opencode/skills/*/SKILL.md` (13 native OpenCode skills) | **Complete** |
| `Kun/` | `SKILL.md` (rules + playbook summary), `AGENTS.md`, `.kun/skills/*/SKILL.md` (13 native Kun skills) | **Complete** — 13 native `.kun/skills/` match the Cursor/ChatGPT set (build-run, add-module, add-control-event, add-form, fix-compile-errors, add-resource, audit-project-manifest, debug-freebasic-app, edit-form-safely, find-framework-control, prepare-release, refactor-freebasic, winapi-interop); `SKILL.md` kept as the working summary |

When editing the shared baseline, change it in **all five** `AGENTS.md` files
(and the per-tool mirrors) — they are deliberately kept in lockstep.

Every folder carries a `resources/` directory (with a `.gitkeep`) for the
assistant to drop project-specific context into.

The Cursor, ChatGPT/Codex, Kun, and OpenCode templates additionally provide
native skills for safe form editing, manifest audits, framework-control
discovery, resources, runtime debugging, WinAPI interop, refactoring, and
release preparation. These extend the five shared playbooks without changing
the shared `AGENTS.md` baseline (Cursor: `.cursor/skills/`; ChatGPT:
`.agents/skills/`; Kun: `.kun/skills/`; OpenCode: `.opencode/skills/`).

## Design intent

- The **shared baseline** in each `AGENTS.md`/`CLAUDE.md` is FreeBASIC facts that
  don't change per tool (language rules, how to build, editing discipline). That
  content can be seeded from Astoria's own `freebasic` skill/reference.
- The **per-tool detail** (tone, config specifics, tool-only features) is left for
  each assistant to complete for its own file — ask the tool to flesh out its
  starter.
- `AGENTS.md` is an emerging cross-tool convention; folders are kept
  self-contained for v1 (small duplication) rather than sharing a `_shared/`
  folder. Revisit if the duplication becomes a burden.
