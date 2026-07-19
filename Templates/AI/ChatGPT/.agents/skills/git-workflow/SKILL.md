---
name: git-workflow
description: Commit, push, and manage version control for a Git-backed Astoria FreeBASIC project. Use when checking Git status or when the user asks to stage, commit, or push a project whose remote is recorded in project.astoria.
---

# Git workflow for an Astoria project

Read the project configuration before acting. `project.astoria` is the canonical project
description and contains `Mode=`, `GitURL=`, `GitProvider=`, `GitUserName=`, and `GitEmail=`.
Do not guess a remote or identity. An empty `GitURL=` means no remote is configured.

## Commit and push

Use either Astoria's **Project > Git Commit/Push** commands or the Git CLI. Astoria uses SSH
remotes such as `git@github.com:user/repository.git`. If authentication or host-key checks
fail, direct the user to `Templates\Git\sshkeys.md`; do not change the remote to HTTPS as a
workaround.

## Rules

- Inspect status and diffs before staging.
- Commit only when explicitly asked, using a clear scoped message.
- Push only when explicitly asked. Never force-push or rewrite published history without
  explicit authorization.
- Preserve unrelated user changes and avoid staging generated executables, `Temp/`, or
  `{{PROJECT}}_Change.log`.
- Keep `project.astoria` and its `AstoriaProject=1` marker. Edit it through Astoria's
  **Edit Project Description** command or as UTF-8 `Key=Value` lines.
- Use the Git CLI or IDE menu for Git operations; the Astoria MCP server does not provide
  Git tools.
