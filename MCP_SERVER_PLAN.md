# Agent MCP Server — Spec & Implementation Plan

**Status:** Scoped, not started. Design locked for a later implementation session; owner has UI tweaks to finish first.
**Author of plan:** Claude (Opus 4.8), 2026-07-16
**Background:** see `P:\Astoria-Docs\How AI can work with Astoria IDE.docx` for the architecture discussion this plan formalizes.

---

## 1. Goal

Let an AI agent **drive the live Astoria IDE** through the Model Context Protocol (MCP): create/open projects, add and edit files, type into the code pane, build, run, and — critically — **read results back** (compile errors, output). Once Astoria is an MCP server, *any* MCP-capable client (Claude Code, Claude Desktop, and whatever speaks MCP later) can control it; the interface is built once and reused.

**Non-goal (v1):** autonomous/unattended operation. The agent proposes; the human watches the IDE and can intervene at any point.

## 2. Chosen architecture

A **FreeBASIC console sidecar** speaks MCP over stdio to the client and forwards commands to the IDE over a **local named pipe**. Rationale (from the design doc): zero new runtime dependency (reuses the bundled `fbc64`); stdio is MCP's well-trodden transport and a console app owns stdio naturally (the GUI `astoria.exe` does not); the JSON-RPC/MCP complexity is isolated in the small sidecar (contains MCP-spec churn), leaving the IDE only a *dumb command pipe*.

```
┌─────────────┐  MCP / JSON-RPC 2.0   ┌──────────────────┐  line-JSON over    ┌───────────────────────┐
│ MCP client  │  over stdio           │  astoria-mcp.exe │  a named pipe      │  astoria.exe          │
│ (Claude     │◄─────────────────────►│  (FB sidecar)    │◄──────────────────►│  pipe worker thread   │
│  Code/Desk) │  tools/list,          │  translates      │  {id,cmd,args} /   │      │ WM_APP post    │
│             │  tools/call           │  MCP <-> pipe    │  {id,ok,result}    │      ▼                │
└─────────────┘                       └──────────────────┘                    │  UI thread executes   │
                                                                              │  (mClick / functions) │
                                                                              └───────────────────────┘
```

- **Layer A — MCP sidecar** (`astoria-mcp.exe`): implements `initialize`, `tools/list`, `tools/call`; owns the tool schemas; maps each `tools/call` to one pipe command and back. The only component that tracks the MCP spec.
- **Layer B — named pipe** (`\\.\pipe\AstoriaAgent`, see §8 for the exact/dynamic name): newline-delimited JSON request/response, one in-flight request at a time per connection.
- **Layer C — IDE pipe worker**: a background thread in `astoria.exe` reading the pipe. It **never touches HWNDs directly** — it enqueues each command and `PostMessage(hMain, WM_APP_AGENTCMD, …)`, then waits for the UI thread to complete it (§5).
- **Layer D — UI-thread dispatch**: the main window proc drains the queue and runs the mapped IDE function (§6), which is the same code the menus/toolbars already call via `mClick`.

## 3. The MCP tool surface (the vocabulary)

The load-bearing design decision — this becomes a stable public interface, so v1 is deliberately small but closes the full loop (**create → write → build → read errors → fix → run → read output**). Names are `snake_case`; every tool returns `{ ok: bool, … }` or an MCP error.

### v1 — core

| Tool | Input | Returns | Purpose |
|---|---|---|---|
| `get_status` | — | `{ project, main_file, open_files[], building, running }` | Health check + current context. Read-only. |
| `list_files` | — | `{ files[], main_file }` | Files in the open project (from the `.vfp`). |
| `read_file` | `{ path }` | `{ content }` | Read a project file (path is project-relative or an absolute path *inside* the project root). |
| `get_active_file` | — | `{ path, content }` | The focused editor tab's path + text. |
| `write_file` | `{ path, content, register?, open? }` | `{ path, registered, opened }` | Create/overwrite a file; optionally add its `File=` line to the `.vfp` and open it in a tab. |
| `add_file` | `{ name, kind: "module"\|"header"\|"form", register?, open? }` | `{ path }` | New source file from the matching template, registered in the `.vfp`. |
| `set_active_file_content` | `{ content }` | `{ ok }` | Replace the **active** editor's text (the "type into the code pane" op). |
| `open_in_editor` | `{ path }` | `{ ok }` | Open/focus a code tab for a file. |
| `build` | `{ all?: bool }` | `{ ok, exit_code, output, errors[] }` | Compile the project; **blocks until the build finishes** (§7); `errors[]` is parsed (§ get_errors). |
| `syntax_check` | — | `{ ok, errors[] }` | Parse-only check, no binary produced. |
| `run` | `{ args?: string }` | `{ started, exit_code?, note }` | Build-if-stale then launch the produced `.exe`. |
| `get_build_output` | — | `{ text }` | Raw text of the Output/messages pane from the last build/run. |
| `get_errors` | — | `{ errors: [ { file, line, col?, code, message } ] }` | Structured errors parsed from the last build's messages. |

### v2 — later / optional

| Tool | Notes |
|---|---|
| `create_project` | `{ name, template, path?, description?, author?, license?, ai_tool? }` → create + open. Needs a **headless** factoring of `NewProject()`/`frmNewProject.cmdOK_Click` (today that logic lives inside the dialog). |
| `open_project` | `{ vfp_path }` → open an existing `.vfp`. |
| `stop` | Terminate the running program (only meaningful once run-output capture exists). |
| `get_program_output` | Captured stdout/stderr of the last `run` — requires launching the child with redirected pipes (non-trivial for a GUI target; console targets are easy). |
| `rebuild` / `clean` | Clean + full rebuild. |
| `get_symbols` / `find_definition` | Expose the IDE's existing class/function indexing to the agent. |

**Design rules for the surface**
- **Read-only tools are safe and cheap** — expose them first (`get_status`, `list_files`, `read_file`, `get_active_file`, `get_build_output`, `get_errors`).
- **Every mutating tool is scoped to the open project's folder** — reject paths that escape the project root (see §8).
- **Prefer returning results the agent can act on** (structured `errors[]`, not just a blob) — the feedback path is what makes the agent useful.
- **Keep the vocabulary stable.** Add tools; don't repurpose or rename existing ones once shipped.

## 4. IDE-side command pipe protocol

Newline-delimited JSON, request/response, one in-flight request per connection.

```jsonc
// request  (sidecar -> IDE)
{ "id": 42, "cmd": "build", "args": { "all": false } }

// success  (IDE -> sidecar)
{ "id": 42, "ok": true, "result": { "exit_code": 0, "output": "…", "errors": [] } }

// failure
{ "id": 42, "ok": false, "error": { "code": "no_project", "message": "No project is open." } }
```

- `cmd` values are the pipe-level command names (roughly 1:1 with the MCP tools; the sidecar owns the MCP-name ↔ pipe-name mapping so either side can evolve independently).
- Errors use short stable `code`s (`no_project`, `bad_path`, `build_failed`, `not_found`, `busy`, …) plus a human `message`.
- The pipe carries **no MCP framing** — it is deliberately dumb, so the IDE never needs an MCP/JSON-RPC library.

## 5. UI-thread dispatch (the one real pitfall)

Win32 GUI is single-threaded; the pipe worker must not touch windows/controls. Pattern (already used by this codebase for the GDB worker and the dark-mode `WM_SETTINGCHANGE` lesson):

1. Pipe worker parses a request → pushes an `AgentCommand` (cmd, args, a result slot, a completion `HANDLE` event) onto a thread-safe queue.
2. Worker calls `PostMessage(hMain, WM_APP_AGENTCMD, 0, queueIndex)` and **waits on the command's event**.
3. The main window proc handles `WM_APP_AGENTCMD` **on the UI thread**, runs the mapped function (§6), writes the result into the slot, and `SetEvent`s it.
4. Worker wakes, serializes the response to the pipe.

- **Quick/mutating commands** (file ops, editor text, `get_*`) run synchronously in step 3 and return in milliseconds — GUI stays responsive.
- **Long-running commands** (`build`, `run`, `syntax_check`) must **not** block the UI thread: step 3 kicks off the *existing* worker-thread build/run (`ThreadCreate_(@CompileProgram)` etc.) and returns; the build/run thread `SetEvent`s a completion event when done; the **pipe worker** (not the UI thread) waits on that, then issues a follow-up `get_build_output`-style read on the UI thread and responds. Net: neither the GUI nor the agent call is improperly blocked; the agent's `build` latency is just the real build time.

## 6. Mapping tools → existing IDE code

Most operations already exist and are reachable through `mClick` (`AstoriaIDE.bas:190`, a `Select Case Sender.ToString`) or direct functions. Exact signatures to confirm at implementation time.

| Pipe cmd | Existing entry point |
|---|---|
| `build` | `Compile()` (`BuildService.bi:31`) / `mClick "Compile"` → `ThreadCreate_(@CompileProgram)` |
| `syntax_check` | `mClick "SyntaxCheck"` → `SyntaxCheck` |
| `run` | `mClick "CompileAndRun"` / `"Run"`; `RunProgram` / `RunPr` (`TabWindow.bas:11923/12099`) |
| `get_build_output` / `get_errors` | the pane fed by `ShowMessages` (`TabWindow.bas`); parse `file(line) error N:` lines |
| `create_project` (v2) | `NewProject()` (`Main.bas:2315`) — factor the creation body out of `frmNewProject.cmdOK_Click` into a headless function both call |
| `add_file` / `write_file` register | `AddFilesToProject` (`Main.bi:223`) + `.vfp` `File=` update |
| `set_active_file_content` | the active `EditControl`'s text property |
| `open_in_editor` | the tab-open path in `TabWindow.bas` |
| `list_files` / `read_file` / `get_active_file` / `get_status` | read the `.vfp` model + active tab; no mutation |

**Refactor note:** the biggest non-trivial mapping is `create_project` — today the logic is embedded in the New Project dialog's OK handler. A small headless `CreateProjectHeadless(name, template, …)` that both the dialog and the pipe call is the clean move (and dovetails with the Project Setup Templates stamping work).

## 7. Async & concurrency

- **One build/run at a time.** If `build`/`run` is already in progress, new mutating commands return `{ code: "busy" }` (or queue — v1 rejects).
- `build` blocks the *agent call* until completion (§5) and returns the parsed result; the agent doesn't poll.
- `run` (v1) reports *launched* + (for console targets) the process exit code once it exits; live stdout streaming is v2.

## 8. Security & opt-in

A pipe that creates files and runs compiled binaries is a **code-execution surface**. Therefore:

- **Off by default.** A Tools ▸ Options toggle ("Allow AI agent control", default off) starts/stops the pipe listener. No listener, no surface.
- **Local only.** Named pipes are machine-local; do **not** add a TCP/HTTP transport in v1.
- **Project-scoped paths.** Every path argument is resolved against the open project's root and rejected (`bad_path`) if it escapes it. No writing outside the project.
- **Single client.** Accept one sidecar connection at a time.
- **Optional handshake token.** The IDE writes a random token to a user-readable location on enable; the sidecar must present it on connect. (v1 may skip this given pipes are local + opt-in; note it as a hardening step.)
- **Visible activity.** Surface agent actions in the Output pane / status bar so the human sees what the agent did.

## 9. Packaging & client config

- Ship `astoria-mcp.exe` (the sidecar) in the release tree next to `astoria.exe` (add to `StageRelease.ps1` + the installer).
- Provide a copy-paste MCP client config, e.g.:
  ```jsonc
  // Claude Desktop / Claude Code MCP config
  { "mcpServers": {
      "astoria": { "command": "C:\\…\\Astoria IDE\\astoria-mcp.exe", "args": [] }
  } }
  ```
- The sidecar connects to a **running** IDE. If none is running: v1 returns a clear error ("start Astoria IDE first"); optionally the sidecar can launch `astoria.exe` and wait for the pipe (v2 decision).
- Document the whole thing as a Help topic + a README section.

## 10. Task breakdown (suggested phasing)

Lowest-risk first; each phase is independently testable.

- **Task 0 — Pipe + UI dispatch skeleton.** Named-pipe worker thread, the `WM_APP_AGENTCMD` queue/marshal, and a trivial `ping` command. Proves the hardest bit (threading) in isolation. *(Opus; risk: med — threading/marshaling.)*
- **Task 1 — Read-only commands.** `get_status`, `list_files`, `read_file`, `get_active_file`, `get_build_output`. No mutation, no async — safe surface to validate the round-trip. *(Sonnet.)*
- **Task 2 — The FB MCP sidecar.** `astoria-mcp.exe`: JSON-RPC 2.0 over stdio, `initialize`/`tools/list`/`tools/call`, the tool schemas, and the MCP↔pipe mapping — wired to the Task-1 read-only tools end to end from a real MCP client. *(Opus; risk: med — hand-written protocol.)*
- **Task 3 — File & editor mutations.** `write_file`, `add_file`, `set_active_file_content`, `open_in_editor` (+ the project-root path guard). *(Sonnet/Opus.)*
- **Task 4 — Build/run + feedback.** `build`, `syntax_check`, `run`, `get_errors` with the async completion-event handling (§5/§7). *(Opus.)*
- **Task 5 — Project ops.** Headless `CreateProjectHeadless`, then `create_project` / `open_project`. *(Opus.)*
- **Task 6 — Security/opt-in + packaging.** Options toggle, path scoping, ship `astoria-mcp.exe`, client-config docs. *(Sonnet.)*
- **Task 7 — End-to-end verify.** Drive the primes-program loop from a real MCP client: create → write → build → read errors → fix → run → read output. *(via `/run` `/verify`.)*

## 11. Open questions for owner

1. **Sidecar name/location** — `astoria-mcp.exe` beside `astoria.exe`? Ship it built, or build on first use?
2. **IDE-not-running behavior** — error out (v1) or have the sidecar launch the IDE?
3. **`run` output** — is capturing the program's stdout/stderr in scope early, or is "launched, watch the IDE" acceptable for v1? (Console targets are easy; GUI targets don't have stdout.)
4. **Multiple projects/windows** — scope the agent to the single active project (simplest), or address projects by path?
5. **Token handshake** — include the token in v1, or rely on local-pipe + opt-in and add it later?
6. **Tool naming** — confirm the v1 tool names now (they become a stable interface): `get_status`, `list_files`, `read_file`, `get_active_file`, `write_file`, `add_file`, `set_active_file_content`, `open_in_editor`, `build`, `syntax_check`, `run`, `get_build_output`, `get_errors`.

## 12. Notes

- This reuses the codebase's existing single-threaded-UI discipline; no new architectural pattern is introduced.
- The `create_project` headless refactor overlaps with the Project Setup Templates feature (`PROJECT_SETUP_PLAN.md`) — worth coordinating so both call one creation function.
- Nothing here is needed for the lighter "agent writes files + `fbc64`, IDE live-reloads" workflow; this plan is specifically for **driving the live IDE** via MCP.
