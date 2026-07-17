# Connecting an AI agent to Astoria IDE (MCP)

Astoria can act as an **MCP server**, letting a local AI agent (Claude Code, Claude
Desktop, or any MCP-compatible client) drive the running IDE — create a project, write
a module, build it, read the compiler errors, fix them, and run it — all from a chat
prompt.

No Python, Node, or other runtime is required. The bridge is a small native FreeBASIC
console program, **`astoria-mcp.exe`**, that ships next to `astoria.exe`.

## How it fits together

```
  MCP client  ── stdio (JSON-RPC 2.0) ──►  astoria-mcp.exe  ── named pipe ──►  astoria.exe
 (Claude Code)                              (the sidecar)      \\.\pipe\         (the IDE)
                                                               AstoriaAgent
```

- `astoria-mcp.exe` is the only piece that tracks the MCP spec. It forwards each tool
  call to the IDE over a local named pipe.
- The IDE only listens on that pipe **when you opt in** (see below). The pipe is
  local-only; it is not a network socket.
- If Astoria isn't running when your agent makes its first request, the sidecar
  **launches it for you** and waits for it to come up (it won't open a second copy if
  one is already running). The opt-in below is still required — a launch alone doesn't
  grant access.

## 1. Confirm it's on in the IDE

Astoria is agent-first, so the agent pipe is **on by default**. You can see its state
at a glance in the **status bar**, which reads **“MCP Agent: On”** or **“MCP Agent:
Off.”**

To change it: **Tools ▸ Options ▸ General ▸ “Allow AI agent control (MCP)”**. The pipe
starts/stops the moment you click **OK** — no restart. The setting is remembered between
sessions (stored as `AllowAgentControl` under `[Options]` in `Settings/astoria.ini`).

## 2. Point your MCP client at the sidecar

Add Astoria to your client's MCP server list, using the **full path** to
`astoria-mcp.exe` in your install directory.

**Claude Desktop** — edit `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "astoria": {
      "command": "C:\\Program Files\\Astoria IDE\\astoria-mcp.exe",
      "args": []
    }
  }
}
```

**Claude Code** — from a terminal:

```
claude mcp add astoria "C:\Program Files\Astoria IDE\astoria-mcp.exe"
```

Adjust the path to wherever Astoria is installed (the sidecar sits beside
`astoria.exe`). Restart the client so it picks up the new server.

## 3. Use it

With Astoria running and the checkbox ticked, ask your agent something like:

> Create a FreeBASIC console project that prints every prime below 1,000,000, build it,
> fix any errors, and run it.

The agent will use the tools below to do the work directly in the IDE.

## Available tools (15)

| Tool | What it does |
|------|--------------|
| `get_status` | Whether a project is open, active file, build state |
| `list_files` | Files in the current project |
| `read_file` | Contents of a project file |
| `get_active_file` | Path + contents of the file in the active editor |
| `get_build_output` | Text from the last build |
| `get_errors` | Structured errors/warnings from the last build |
| `write_file` | Overwrite a project file on disk |
| `add_file` | Add a new file to the project |
| `set_active_file_content` | Replace the active editor's contents |
| `open_in_editor` | Open a project file in the editor |
| `build` | Compile the current project (async) |
| `syntax_check` | Syntax-check without a full build |
| `run` | Run the built program |
| `create_project` | Create a new project headlessly |
| `open_project` | Open an existing project by path |

## Security notes

- **On by default, but user-controllable.** Because Astoria is meant to be driven by an
  agent, the pipe listens out of the box. Un-tick **“Allow AI agent control”** (or close
  Astoria) to stop the listener; the status bar shows the current state.
- **Local only.** The transport is a Windows named pipe on the local machine, not a
  network port.
- **Project-scoped.** File tools operate within the open project's folder.
- If you don't want any local process able to drive the IDE, turn the toggle off when
  you're not working with an agent.

## Troubleshooting

- **Client can't connect / tools error out** — the sidecar will auto-launch Astoria,
  but the **“Allow AI agent control” checkbox must be ticked** for the pipe to open. If
  the IDE opened but tools still fail, tick the checkbox (Tools ▸ Options ▸ General) and
  retry. The sidecar reports a clear message when the pipe isn't up.
- **Wrong path** — the `command` must be the absolute path to `astoria-mcp.exe`.
- **Nothing happens on a tool call** — check the IDE is not blocked on a modal dialog;
  the pipe dispatches work on the UI thread.

See [MCP_SERVER_PLAN.md](MCP_SERVER_PLAN.md) for the full architecture and protocol.
