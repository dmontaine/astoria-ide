# Astoria IDE — Significant Changes from VisualFBEditor

*An introduction for prospective users*

> Imported from `AstoriaIDESignificantChanges.doc` (P:\Astoria-Docs) on 2026-07-18 and converted
> to Markdown so that changes to it are tracked in version control alongside the code they
> describe. This file is now the authoritative copy — edit it here, not the `.doc`.
>
> This document covers **significant** differences only. For every change, see
> [DetailedChangelog.md](DetailedChangelog.md); for what has been tested, see
> [Testing.md](Testing.md).

## Introduction

Astoria IDE is a 64-bit Windows development environment for FreeBASIC. It began as a fork of
VisualFBEditor and has since grown into a distinctly different tool, guided by a deliberately
opinionated design philosophy.

**Opinionated by design.** Most development environments grow by accumulating options. Every
preference becomes a setting, every setting becomes a decision the user has to make before getting
any work done. Astoria takes the opposite position: where there is a clearly better answer, we make
that choice once, on the user's behalf, and remove the option entirely.

In practice this means Astoria ships with its compiler and debugger already bundled and configured,
offers only the terminals Windows itself provides, and targets 64-bit Windows exclusively. There is
no toolchain to install, no paths to configure, and no way to end up in a broken configuration by
changing something you did not understand. A newly installed Astoria can compile and run a program
immediately.

The trade-off is real and we accept it: a user with unusual requirements has fewer levers to pull.
We think that is the right exchange. Configurability that only a small minority needs is paid for by
every beginner who has to walk past it.

**One tool, not a stack.** Astoria combines text editing, visual GUI form design, project
management, version control, and AI assistance in a single application. Newcomers to programming are
frequently defeated not by the language but by the assembly required around it — a compiler here, an
editor there, a separate designer, a version control client, and a pile of configuration joining
them together. Astoria is intended to be the whole environment.

## Primary audiences

- **Learners and hobbyists.** People who want to write real Windows programs, including graphical
  ones, without first serving an apprenticeship in build tooling. FreeBASIC is approachable and
  readable, and Astoria aims to keep the surrounding environment equally approachable.
- **Educators and students.** Modern development stacks are overwhelming in a classroom, and school
  budgets are limited. Astoria pairs an easy-to-learn language with a single tool covering both text
  and GUI development, plus built-in version control and AI integration. It works with frontier AI
  models and, importantly, with open-source models through OpenCode — which matters a great deal
  when per-seat costs are a constraint. An instructor can have students clone an example project
  from a Git repository or build one locally from scratch, using the same dialog either way.
- **Solo developers and small teams.** Practitioners who want GUI and console development, Git, and
  AI assistance in one place, with sensible defaults rather than a configuration project of their
  own.
- **AI-assisted developers.** Astoria treats an AI coding assistant as a first-class participant in
  development rather than an afterthought bolted on from outside.

## Section 1: Significant features not found in VisualFBEditor

- **AI agent integration.** Astoria ships an MCP (Model Context Protocol) server, so an AI assistant
  can work inside the running IDE rather than merely editing files behind its back. An assistant can
  create and open projects, read and modify files, compile, run programs, and read back build errors
  — while you watch it happen in the editor. This is the single largest departure from
  VisualFBEditor.
- **AI-friendly projects.** Any new project can be marked AI-friendly, which is the default. Astoria
  then installs a ready-made template for your assistant of choice — Claude Code, ChatGPT/Codex,
  Cursor, Kun, or OpenCode — preloaded with FreeBASIC-specific skills and coding rules. Projects
  created by an AI agent are marked automatically, with that agent's template applied. The assistant
  arrives already knowing the language's conventions and the project's layout.
- **Built-in Git workflow.** Version control is part of the IDE rather than a separate errand. A Git
  menu provides Commit, Pull, and Push, and Astoria will also set up your SSH key and create the
  remote repository for you. Your Git identity is entered once in Options and reused everywhere;
  commits are attributed using repository-local settings, so Astoria never disturbs your machine's
  global Git configuration.
- **Two ways to start a project.** The New Project dialog offers a clear choice: create a purely
  local project, or use an existing Git project. Choosing the latter clones the repository — and if
  it is empty, Astoria populates it from your chosen template just like a new local project. If it
  already contains a complete project, Astoria loads it as-is and disables the fields that no longer
  apply.
- **The `project.astoria` description file.** Every Astoria project carries a readable description
  file recording the choices made when it was created: template, author, license, Git details, and
  AI settings. It can be edited later from the Project menu. It also serves as Astoria's marker for
  its own projects — Astoria opens empty repositories and Astoria projects, and declines unfamiliar
  ones rather than guessing at their structure.
- **A standard Windows installer.** Astoria installs the way Windows software is expected to:
  a per-user install that needs no administrator rights and raises no elevation prompt, with Start
  Menu and desktop shortcuts and a projects folder placed somewhere you can actually find rather
  than buried in the install directory. There is no unpacking an archive and hunting for the
  executable, and uninstalling is a single step.
- **A bundled, zero-configuration toolchain.** The 64-bit FreeBASIC compiler and the GDB debugger
  ship with Astoria, already wired up. Nothing to download, nothing to point at.
- **Clearer switching between code and form.** Each open document carries its own Code / Form /
  Code+Form selector, presented as labelled buttons with icons directly beneath the editing area, so
  it is obvious which view you are in and what it belongs to. The Code and Form menus grey out when
  they do not apply, and in a split view they follow whichever pane has the keyboard focus.
- **Windows Terminal support.** Programs can be run in Windows Terminal alongside the classic
  console, the command prompt, and PowerShell.
- **Substantial reliability work.** A large share of the effort behind Astoria is not visible as a
  feature at all. Dialogs no longer appear behind the main window; a deleted or missing project no
  longer blocks startup with an error and is dropped from the recent list; a missing settings file is
  rebuilt from shipped defaults instead of leaving the IDE silently unable to save anything; and
  debugged programs no longer survive as orphaned processes after the IDE closes.
- **Nothing broken, unstable, or half-finished is shipped on purpose.** A menu item that does
  nothing, a control that fails the moment you use it, a setting with no effect — these cost a
  newcomer more than a missing feature does, because they cannot tell a broken tool from their own
  mistake. So the standing rule is that a feature either works or does not ship. A control that
  cannot be built is removed from the toolbox rather than left to fail at compile time. A setting
  that does nothing is deleted rather than left as a checkbox. Where something is genuinely
  unproven, it is written down as unproven instead of being presented as working.

  This is an aim held to deliberately, not a claim of perfection — Astoria is one developer's work
  and has not yet met a wide range of machines. What backs the aim up is that testing is used to
  find these things and the findings are published: `Documentation/Testing.md` lists what has been
  verified **and what has not**, and `Documentation/TestPlan.md` records every planned test with its
  result, including the failures. Recent examples of the rule in action: the WebBrowser control was
  found to be incapable of displaying a page and was rebuilt on a modern engine rather than shipped
  as a control that opens an empty window; and a database function that could never succeed was
  found by testing it and fixed.

## Section 2: Significant VisualFBEditor features not found in Astoria IDE

These are removals rather than omissions. Each was a deliberate decision, and each follows from the
philosophy described above.

- **Linux and cross-platform development.** VisualFBEditor, built on the cross-platform
  MyFbFramework, could be built and run on Linux through GTK. Astoria is 64-bit Windows only. The GTK
  and Linux code paths have been removed rather than left dormant. Supporting two platforms means
  every feature must be designed, built, and tested twice, and the compromises show up in both;
  concentrating on one platform is what makes the bundled toolchain, the integrated debugger, and the
  Windows-native form designer work as well as they do. If you develop on Linux, VisualFBEditor
  remains the better choice.
- **32-bit compilation and compiler selection.** VisualFBEditor let you configure multiple compilers
  and build for 32-bit or 64-bit Windows. Astoria targets 64-bit Windows only, using the compiler it
  ships with. The Default Compiler entry in Options is now an information line rather than a choice.
  If you must produce 32-bit binaries, Astoria is not the right tool.
- **Choice of debugger.** VisualFBEditor allowed several debuggers to be registered and selected,
  including external ones. Astoria uses its bundled GDB, integrated directly into the IDE, and offers
  no selection.
- **User-defined terminals.** VisualFBEditor let you add arbitrary terminal programs with custom
  command lines. Astoria offers only the consoles Windows provides — the standard console, Command
  Prompt, Windows PowerShell, and Windows Terminal — and there is always one selected. There is
  nothing to add, edit, or misconfigure.
- **Multi-language user interface.** VisualFBEditor shipped translations of its interface. Astoria's
  interface is English only.
- **The bundled VisualFBEditor help file.** Astoria no longer lists its parent project's help. The
  FreeBASIC manual, the Win32 reference, and the MyFbFramework documentation remain available;
  Astoria's own documentation is being written to replace what was removed.
- **A large amount of configuration complexity.** This deserves to be named as a removal in its own
  right, because for many users it is the most consequential one. VisualFBEditor exposed a great many
  settings, and a beginner had no way to tell which of them mattered. Astoria has removed whole
  categories of them — debugger registration, compiler configuration, terminal definitions, target
  architecture — along with the settings pages and dialogs that went with them. Where an option
  survives, we aim to have chosen a sensible default so that most users never need to open it at all.

This is an ongoing effort rather than a finished one. The guiding rule is progressive disclosure:
less common commands move one level deeper, into an Advanced submenu within their own menu, rather
than behind a global "expert mode." A beginner never trips over them, and anyone who goes looking
will find them one click away. We would rather remove a setting than add a switch that turns it off.

---

*Astoria IDE is feature complete for version 1.0. Features described here are subject to change.*
