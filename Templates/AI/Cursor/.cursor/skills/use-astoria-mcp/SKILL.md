---
name: use-astoria-mcp
description: Drive the live Astoria IDE through its MCP server (build, run, read errors, edit files) instead of asking the user to press F5 or shelling out to fbc. Use whenever the "astoria" MCP server is connected.
---

# Drive the Astoria IDE over MCP

Astoria ships an MCP server -- `astoria-mcp.exe`, a sidecar beside `astoria.exe` -- that
exposes the running IDE as tools. When the **`astoria`** MCP server is connected, use its
tools to build, run, read errors, and edit project files directly. Don't ask the user to
press **F5** or run `fbc` by hand; do it yourself and read the results back.

## Prerequisites

- Astoria runs with **Tools > Options > "Allow AI agent control (MCP)"** enabled -- it is
  **on by default**. The IDE status bar reads **"MCP Agent: On"** when the pipe is live.
- If the IDE isn't running, the sidecar **launches it automatically** on the first tool
  call (it won't open a second copy).
- Your client must be pointed at the server -- see **Connecting** below.

## Tools

**Status / read**
- `get_status` -- is a project open, the active file, and build/run state
- `list_files` -- files in the project (from its `.vfp`)
- `read_file` -- a project file's contents
- `get_active_file` -- the focused editor tab's path + text
- `get_build_output` -- raw output text from the last build or run
- `get_errors` -- structured `errors[]` (file, line, severity, message)

**Edit**
- `write_file` -- create/overwrite a project file (optionally register in the `.vfp` + open)
- `add_file` -- add a new source file from the matching template
- `set_active_file_content` -- replace the focused editor's full text
- `open_in_editor` -- open/focus a project file

**Build / run / projects**
- `build` -- compile the project (blocks; returns success, exit code, output, `errors[]`)
- `syntax_check` -- parse-only check, no executable
- `run` -- build + run; for console targets returns captured output + exit code
- `create_project` -- new project from a template
- `open_project` -- open an existing `.vfp`

All file-path arguments are confined to the open project's folder; paths outside it are
rejected.

## The loop

Typical cycle for a change:

1. `write_file` / `set_active_file_content` / `add_file` -- make the edit
2. `build` (or `syntax_check` for a fast check)
3. `get_errors` -- if any, fix the **first** one and rebuild (later errors usually cascade)
4. `run` -- read the console output / exit code to confirm behavior, not just that it compiled

Prefer this over the raw CLI: the IDE handles `.frm` main files, resource (`.rc`)
generation, and the framework include path that bare `fbc` does not.

## Connecting

Cursor reads MCP servers from **`.cursor/mcp.json`** (project scope). This template ships
one. If its `command` still contains the `{{ASTORIA_MCP_EXE}}` placeholder, replace it with
the full path to `astoria-mcp.exe` (it sits beside `astoria.exe` in your Astoria install),
then reload Cursor so it connects. Verify the exact `mcp.json` shape against Cursor's
current MCP docs. See `AGENT_MCP_SETUP.md` in the Astoria install for the full reference.
