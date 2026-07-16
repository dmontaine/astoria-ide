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

| Tool | Primary file(s) | Status |
|---|---|---|
| `ClaudeCode/` | `CLAUDE.md`, `AGENTS.md` | **Complete** (authored by Claude Code) |
| `Cursor/` | `.cursorrules`, `.cursor/rules/*.mdc`, `AGENTS.md` | Starter — have Cursor finish it |
| `ChatGPT/` | `AGENTS.md` (Codex convention) | Starter — have ChatGPT/Codex finish it |
| `OpenCode/` | `AGENTS.md`, `opencode.json` | Starter — have OpenCode finish it |
| `Kun/` | `AGENTS.md` | Starter — **verify Kun's actual config convention** (deepseek-gui.com landing page did not document it; `AGENTS.md` assumed as the cross-tool default) |

Every folder carries a `resources/` directory (with a `.gitkeep`) for the
assistant to drop project-specific context into.

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
