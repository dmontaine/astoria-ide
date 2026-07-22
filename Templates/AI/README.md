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
| `{{ASTORIA_MCP_EXE}}` | Full path to `astoria-mcp.exe` (the MCP sidecar, beside `astoria.exe`) — used by each tool's MCP server config |

> **`{{ASTORIA_MCP_EXE}}` is not yet wired into the stamping substitution helper.** Until it is, a stamped project's MCP config file keeps the literal `{{ASTORIA_MCP_EXE}}` placeholder; the `use-astoria-mcp` skill tells the user to replace it (or run `claude mcp add …`). Add the substitution when the Project Setup Templates stamping is implemented — the IDE knows the path from `ExePath`.

## Folders

All five folders carry the same **default rules + skills set** (2026-07-16): a
shared canonical `AGENTS.md` (rules: language / build / Astoria-project /
editing discipline; skills: build-run, add-module, add-control-event, add-form,
fix-compile-errors), plus each tool's native convention on top.

| Tool | Primary file(s) | Status |
|---|---|---|
| `ClaudeCode/` | `CLAUDE.md`, `.claude/skills/*/SKILL.md` (14 native skills incl. `use-astoria-mcp`), `AGENTS.md`, `.mcp.json` | **Complete** — canonical model for the other tools |
| `Cursor/` | `.cursor/rules/freebasic.mdc` (always-on), `.cursor/rules/freebasic-tasks.mdc`, `.cursor/skills/*/SKILL.md` (14 native skills), `.cursor/mcp.json`, `.cursorrules`, `AGENTS.md` | **Complete** — mirrored from ClaudeCode (2026-07-19): BOM/`ReDim`/`project.astoria`/testing/MCP-edit rules |
| `ChatGPT/` | `AGENTS.md`, `.agents/skills/*/SKILL.md` (13 native Codex skills; inline fallback retained) | **Complete** |
| `OpenCode/` | `AGENTS.md`, `opencode.json` (references `.opencode/skills/`), `.opencode/skills/*/SKILL.md` (13 native OpenCode skills) | **Complete** |
| `Kun/` | `SKILL.md` (rules + playbook summary), `AGENTS.md`, `.kun/skills/*/SKILL.md` (13 native Kun skills) | **Complete** — 13 native `.kun/skills/` match the Cursor/ChatGPT set (build-run, add-module, add-control-event, add-form, fix-compile-errors, add-resource, audit-project-manifest, debug-freebasic-app, edit-form-safely, find-framework-control, prepare-release, refactor-freebasic, winapi-interop); `SKILL.md` kept as the working summary |

When editing the shared baseline, change it in **all five** `AGENTS.md` files
(and the per-tool mirrors) — they are deliberately kept in lockstep.

## MCP (Agent MCP server) — added 2026-07-17

Astoria is now an MCP server (`astoria-mcp.exe`; see `AGENT_MCP_SETUP.md` and
`MCP_SERVER_PLAN.md` at the repo root). All five folders gained:

- a **`use-astoria-mcp`** skill — tells the agent to drive the live IDE via the
  `astoria` MCP tools (`build`/`run`/`get_errors`/`write_file`/…) instead of manual
  F5/CLI when the server is connected;
- an **MCP server config** in the tool's native place — Claude `.mcp.json`, Cursor
  `.cursor/mcp.json`, OpenCode `opencode.json` (`mcp` block); ChatGPT/Codex and Kun
  carry the config **in the skill's "Connecting" section** (their client formats are
  global/unverified), for the owning agent to formalize;
- an MCP-first note in each `build-run` skill and `AGENTS.md` (+ `CLAUDE.md`).

The config files use the `{{ASTORIA_MCP_EXE}}` placeholder (see Tokens above). Each
tool's owning agent should confirm its client's exact MCP config format and adjust.

Every folder carries a `resources/` directory (with a `.gitkeep`) for the
assistant to drop project-specific context into.

The Cursor, ChatGPT/Codex, Kun, and OpenCode templates additionally provide
native skills for safe form editing, manifest audits, framework-control
discovery, resources, runtime debugging, WinAPI interop, refactoring, release
preparation, and MCP driving (`use-astoria-mcp`). These
extend the shared playbooks (Cursor: `.cursor/skills/`; ChatGPT:
`.agents/skills/`; Kun: `.kun/skills/`; OpenCode: `.opencode/skills/`).

**Cursor MCP config verified (2026-07-19):** `.cursor/mcp.json` uses the documented
project-scope shape (`mcpServers` → `command`/`args` for local stdio). After
stamping, replace `{{ASTORIA_MCP_EXE}}` and reload Cursor.

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
