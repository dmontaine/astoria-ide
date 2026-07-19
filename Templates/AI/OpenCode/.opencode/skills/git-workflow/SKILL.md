---
name: git-workflow
description: Commit, push, and manage version control for a git-backed Astoria FreeBASIC project. Use when the project has a Git remote (recorded in project.astoria) and you need to stage, commit, push, or check status.
---

# Git workflow for an Astoria project

An Astoria project can be **git-backed** -- created with the New Project dialog's **Use
Existing Git Project** mode (cloned from a remote) or later placed under version control.
When it is, the remote and identity are recorded in **`project.astoria`**, the project's
description file in the project root. Read them from there; don't guess.

## Where the remote lives

`project.astoria` carries (one `Key=Value` per line, UTF-8):

- `Mode=ExistingGit` -- this project is backed by a remote (vs `Mode=LocalProject`).
- `GitURL=` -- the remote, an SSH URL like `git@github.com:user/Repo.git`.
- `GitProvider=` / `GitUserName=` / `GitEmail=` -- provider + identity used for the remote.

Read them with the **use-astoria-mcp** `read_file` tool, or open `project.astoria` directly.
If `GitURL=` is empty, the project isn't wired to a remote yet -- don't invent one.

## Committing and pushing

Two equivalent paths:

1. **In the Astoria IDE:** the **Project menu**'s **Git Commit / Push** options (enabled for
   git-backed projects; they read the remote from `project.astoria`).
2. **Command line** (works anywhere; needs an SSH key registered with the provider):
   ```
   git add -A
   git commit -m "clear, scoped message"
   git push
   ```

Astoria clones and pushes over **SSH** (`git@host:user/repo.git`). If `git push` fails with a
permission or host-key error, the machine has no SSH key for that provider -- tell the user to
set one up (see `Templates/Git/sshkeys.md` in the Astoria install). **Don't** rewrite the
remote to HTTPS to work around it.

## Rules

- **Commit only when asked.** Never `git commit`/`git push` on your own initiative.
- **Never force-push** or rewrite published history unless the user explicitly asks.
- A **`.gitignore`/`.gitattributes`** pair already ships with git-backed projects -- don't
  commit `Temp/`, produced `.exe` files, or `{{PROJECT}}_Change.log`; `.gitattributes` keeps
  line endings consistent.
- **Keep `project.astoria`.** It's the marker that identifies this folder as an Astoria
  project and the source of the Git remote -- don't delete or rename it. Edit it via
  **Project menu > Edit Project Description**, or by hand (it must keep its `AstoriaProject=1`
  line).
- The **MCP server does not expose git operations** -- use the git CLI (or the IDE menu) for
  commit/push, not an MCP tool.
