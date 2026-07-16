# Project Setup Templates — Implementation Plan

**Status:** Scoped, not started. Awaiting owner review before Task 0 begins.
**Author of plan:** Claude (Opus 4.8), 2026-07-15
**Related commit:** `06d0a6a` — "New Project dialog: add Author, License, Git URL, AI-friendly fields"

---

## 1. Goal

Move the "stuff we stamp into a new project" out of compiled code and into
editable, ship-with-the-app template folders under `Templates/`, and turn three
today-incomplete features into real ones:

- **Licenses** — currently ~50 lines of license text are hardcoded as string
  literals inside `frmNewProject.WriteLicenseFile` ([src/frmNewProject.frm:696](src/frmNewProject.frm)).
  Move to files.
- **AI** — the `chkAIFriendly` checkbox is captured as a flag only; the code
  itself calls what it should generate "an open decision for a later session"
  ([src/frmNewProject.frm:528](src/frmNewProject.frm)). Make it stamp real,
  **per-AI-tool** guidance files into the project.
- **Git** — `UseGit`/`GitURL` are stored as `.vfp` metadata only; no git runs.
  Add stamped git files + an instructional, host-aware setup wizard.

And make those choices **editable after creation** (Task 8): a Project Properties
editor so License / Git / AI tool / Description aren't locked in at the New Project
dialog.

**Target audience note (owner):** beginners/hobbyists may use these features to
*learn* git and AI-assisted development. Instructions-first; automation later.

## 2. Why this fits the existing code

- `Templates/` already ships **wholesale**: `StageRelease.ps1:73` copies the
  whole folder into the release, and the installer recurses subdirs
  (`AstoriaIDE.iss:53`). **New subfolders under `Templates/` ship with zero
  build-config changes.**
- Helpers already exist: `CopyFileU` and `EnsureDirectoryExists`
  ([src/PathUtils.bas:298](src/PathUtils.bas), :350).
- The Git checkbox+URL pattern (`chkUseGit` gates `txtGitURL`) is the UI model
  to copy for the new AI-tool dropdown.

## 3. Design decisions (locked)

1. **Nest under `Templates/`**, not a new top-level `ProjectSetup/` folder — one
   home for stampable content, ships through the existing path.
2. **One shared substitution helper.** Everything below reuses it instead of
   three slightly-different token loops.
3. **Instruction text lives in files, not compiled in.** Host UIs go stale;
   editing a `.md`/`.txt` must not require a rebuild.
4. **Git wizard is instructional-only for v1.** `git init`, SSH, and remotes stay
   manual. Auto-running git is a later, opt-in tier — and never for anything
   touching `~/.ssh` or remote hosts.
5. **AI is per-tool.** A dropdown selects the assistant; each maps to a
   self-contained `Templates/AI/<tool>/` folder.

## 4. Target folder structure

```
Templates/
  Licenses/
    MIT.txt  Apache.txt  GPL.txt  LGPL.txt  Mozilla.txt
    BSD.txt  Freeware.txt  Proprietary.txt          (Other -> writes nothing)
  Git/
    gitignore.txt        (-> stamped in as .gitignore; FreeBASIC build output)
    gitattributes.txt    (-> stamped in as .gitattributes)
    github.md  codeberg.md  gitlab.md  other.md      (per-host wizard steps)
    sshkeys.md                                        (shared SSH tab content)
  Readme/
    README.md            (tokened front-door doc)
  AI/
    ClaudeCode/  CLAUDE.md   AGENTS.md   resources/.gitkeep
    Cursor/      .cursorrules (or .cursor/rules/)  AGENTS.md  resources/.gitkeep
    ChatGPT/     AGENTS.md   resources/.gitkeep
    OpenCode/    AGENTS.md   opencode.json  resources/.gitkeep
    Kun/         AGENTS.md   resources/.gitkeep      (Deepseek)
```

Tokens replaced on stamping: `{{PROJECT}}`, `{{AUTHOR}}`, `{{YEAR}}`,
`{{DATE}}`, `{{LICENSE}}`.

> **Note on shared content:** AGENTS.md is an emerging cross-tool convention.
> V1 keeps each tool folder self-contained (small duplication) for simple
> stamping logic. A later `_shared/` folder can de-duplicate if it's worth it.

## 5. AI-tool dropdown — UI change

The row-7 `chkAIFriendly` checkbox stays (gates the feature). Add a
`cboAITool` (`ComboBoxEdit`, drop-down-list) beside it, **enabled only when the
box is checked** — exactly mirroring `chkUseGit` -> `txtGitURL` on `pnlGit`
([src/frmNewProject.frm:199-233](src/frmNewProject.frm)).

- Options: **Claude Code** (default), **Cursor**, **ChatGPT (Codex)**,
  **OpenCode**, **Kun (Deepseek)**.
- Populated in `Form_Create` (like `cboLicense` at :636-646), disabled + reset
  there too.
- On OK: if checked, recursively stamp `Templates/AI/<selected>/` into the
  project via the folder-stamp helper.
- `.bi` change: add `cboAITool` to the `ComboBoxEdit` line (:38) and add a
  `chkAIFriendly_Click` handler pair (:24-25 pattern) to toggle the dropdown.

> **Layout caution:** the form is a fixed 480x418 dialog with hardcoded
> coordinates. Adding the dropdown to row 7 fits, but verify the panel row
> math; if a future row is added the form height must grow.

---

## 6. Task breakdown

Model column reflects the owner's preference to conserve credits (Sonnet for
mechanical/well-specified work, Opus for design-heavy or new-UI work). See
`[[model-selection-sonnet-for-cost]]`.

### Task 0 — Foundation: substitution + folder-stamp helpers
**Model: Sonnet 5** · **Blocks: 1,2,3,4** · Risk: low-med (core util)

Add to [src/PathUtils.bas](src/PathUtils.bas) / `.bi`:
- `Function CopyTemplateWithTokens(src As UString, dest As UString, tokens...) As Boolean`
  — read text with the **encoding fallback already used** in
  `cmdOK_Click` (utf-8 -> utf-16 -> utf-32 -> plain Open;
  [src/frmNewProject.frm:470-473](src/frmNewProject.frm)), replace the five
  tokens, write UTF-8.
- `Function StampTemplateFolder(srcDir As UString, destDir As UString, tokens...) As Boolean`
  — recurse `srcDir`; for text extensions (`.md .txt .json .bi .bas .rc .frm
  .cursorrules` + extensionless dotfiles) use `CopyTemplateWithTokens`, else
  raw `CopyFileU`. Create dest subdirs via `EnsureDirectoryExists`.
- Decide token-passing shape (a small `Type` or parallel arrays) and document it.

**Acceptance:** unit-exercise both on a scratch folder; tokens replaced, nested
dirs recreated, binary files unchanged.

### Task 1 — Licenses refactor
**Model: Sonnet 5** · **Depends: 0** · Risk: low (refactor of working code)

- Create `Templates/Licenses/*.txt` from the exact literals now in
  `WriteLicenseFile` ([src/frmNewProject.frm:700-751](src/frmNewProject.frm)),
  replacing year/holder with `{{YEAR}}`/`{{AUTHOR}}`. **Preserve text verbatim.**
- Rewrite `WriteLicenseFile` to `CopyTemplateWithTokens` from the folder; if the
  file is missing, keep today's behavior as fallback (no regression mid-transition).
- `cboLicense` keeps its fixed preferred order (:637-645) but only lists names
  whose file exists on disk.

**Acceptance:** create a project with each license; the emitted `LICENSE` file
is byte-identical to today's output (modulo the year/author tokens).

### Task 2a — AI-tool dropdown UI + stamping wiring
**Model: Opus 4.8** · **Depends: 0** · Risk: med (dialog logic + layout)

- `.bi`: add `cboAITool`; add `chkAIFriendly_Click_`/`chkAIFriendly_Click`.
- `.frm`: add the combo to `pnlAIFriendly` ([:234-256](src/frmNewProject.frm)),
  wire `OnClick` to enable/disable it, populate + reset in `Form_Create`.
- In `cmdOK_Click` after license writing (:546), if `chkAIFriendly.Checked` call
  `StampTemplateFolder(ExePath & "/Templates/AI/" & selectedTool, localFolder, ...)`.
- Persist the chosen tool to the `.vfp` metadata block (:539-543) as
  `AITool="..."` alongside the existing keys.

**Acceptance:** each dropdown option stamps its folder; unchecking disables the
combo; loader still ignores the new key (it's an unrecognized `.vfp` key, safe).

### Task 2b — Author the per-tool AI templates
**Model: Opus 4.8 for CLAUDE.md/AGENTS.md, Sonnet 5 for config boilerplate**
**Depends: (parallel with 2a)** · Risk: low

Write the actual content under `Templates/AI/<tool>/`. These are the product;
content quality is the point. Keep them short, correct, and token-aware
(`{{PROJECT}}`, `{{AUTHOR}}`). Include a `resources/` skeleton per the owner's
original note. Verify each tool's current config filename convention.

### Task 3 — Git files + stamping
**Model: Sonnet 5** · **Depends: 0, 2a (reuses stamping)** · Risk: low

- `Templates/Git/gitignore.txt` (FreeBASIC output: `*.exe *.o *.a *.dll *.obj`
  build dirs, editor cruft), `gitattributes.txt`.
- In `cmdOK_Click`, when `chkUseGit.Checked`, stamp both into the project
  (renamed to `.gitignore` / `.gitattributes`). No git commands run.

### Task 4 — README generator
**Model: Sonnet 5** · **Depends: 0** · Risk: low

- `Templates/Readme/README.md` with `# {{PROJECT}}`, author, license, stub
  sections.
- Generate on project create (**owner decision: always, or only when Git on** —
  see Open Questions). Uses `CopyTemplateWithTokens`.

### Task 5 — Git setup wizard dialog (`frmGitSetup`)
**Model: Opus 4.8** · **Depends: 3 (+6 content)** · Risk: high (new form)

- New modal form: tab control + Next/Previous, launched after project creation
  when Use Git was checked.
- **Host picker** (GitHub / Codeberg / GitLab / Other) -> the next tab loads that
  host's steps from `Templates/Git/<host>.md`. The Codeberg-vs-GitHub fork
  (create-empty-repo-first vs push-creates-it) is content, not code.
- **SSH-keys tab:** check `%USERPROFILE%\.ssh\` for `id_ed25519.pub`; if present,
  display its contents + a copy button ("you already have a key, skip to step
  3"); if absent, show the `ssh-keygen` steps. **Public key only — never read or
  display the private key.**
- Follow the existing `.frm`/`.bi` static-handler + `Designer` dispatch pattern.

### Task 6 — Per-host instruction content
**Model: Sonnet 5 (may need a web check for current host UIs)** · **Depends: none**
Risk: low (but goes stale — that's why it's in files)

Draft `github.md`, `codeberg.md`, `gitlab.md`, `other.md`, `sshkeys.md`.
Verify each host's current SSH-key + new-repo UI path at authoring time.

### Task 7 — Build + end-to-end verification
**Model: Sonnet 5 (or active model)** · **Depends: all** · Risk: low

Build, then walk New Project for: each license, each AI tool, Git on/off, README
present, wizard launches and SSH detection works both ways. Use the `/run` or
`/verify` skill.

### Task 8 — Project Properties / setup editor (post-creation)
**Model: Opus 4.8** · **Depends: 1, 2a, 3, 4** (reuses their templates, helpers, and
option lists) · Risk: med-high (new form; can regenerate already-stamped files)

*(Numeric ID only — sequenced before Task 7 verification; see §7.)*

A dialog to **change, after creation, the setup choices `frmNewProject` captured** —
Author, Project Description, License, Use Git + Git URL, and AI tool. Reads current
values from the project's `.vfp` metadata (`Author`/`License`/`UseGit`/`GitURL`/
`AIFriendly` + the new `AITool`; [src/frmNewProject.frm:539-543](src/frmNewProject.frm))
and writes changes back in the same flat `key="value"` format (safely ignored by
`AddProject`'s loader, same as today).

- **Access point:** most naturally the project node's **Properties** — verify the exact
  host in the existing menu structure (project-tree context menu vs. a Project menu)
  before wiring it. *(Owner suggested the Properties menu.)*
- **Reuse `frmNewProject`'s controls verbatim** — same `cboLicense`/`cboAITool`
  population and the same `chkUseGit`→`txtGitURL` / `chkAIFriendly`→`cboAITool` gating —
  so the create and edit dialogs never drift.
- **Add a Project Description field** (new): multi-line box, persisted as a new
  `Description="..."` `.vfp` key. Add it to the *create* dialog too (small addition)
  and to the token set as `{{DESCRIPTION}}` (used by the README front matter).
- **Reconciling on-disk files is the risky part.** By the time someone opens Properties
  they may have hand-edited `LICENSE`, `README.md`, or the AI files, so **every
  regeneration is opt-in and confirmed, never silent**:
  - License changed → offer to regenerate `LICENSE` (confirm overwrite).
  - AI tool changed → offer to stamp the newly selected `Templates/AI/<tool>/`; leave the
    previously stamped tool's files in place by default (removing them is a separate,
    explicit choice).
  - Use Git switched on → offer to stamp `.gitignore`/`.gitattributes` and/or launch the
    Git wizard (Task 5).
  - Description/Author changed → only touch files if the user opts to refresh README/AI
    templates.
- Follow the existing `.frm`/`.bi` static-handler + `Designer` dispatch pattern (as Task 5).

**Acceptance:** open Properties on an existing project; every field reflects the `.vfp`;
changing each and confirming updates the `.vfp` and, **only when opted in**, the matching
files; declining leaves files untouched; unrelated `.vfp` keys and body preserved
byte-for-byte.

## 7. Suggested sequencing

```
Task 0  (foundation)
  ├─ Task 1  Licenses        (Sonnet)
  ├─ Task 2a AI UI/wiring     (Opus)  ─┬─ Task 2b AI content (Opus/Sonnet, parallel)
  ├─ Task 3  Git files        (Sonnet) │
  └─ Task 4  README           (Sonnet) │
Task 6  host content (Sonnet, anytime) │
Task 5  Git wizard (Opus, after 3 & 6) ┘
Task 8  Properties editor (Opus, after 1/2a/3/4)
Task 7  verify (last — now also covers Task 8)
```

Lowest-risk-first: **0 → 1 → 3 → 4 → 2a/2b → 6 → 5 → 8 → 7.**

**v1 vs v2 (owner-agreed):** ship Tasks **0–4** as v1 (licenses, AI templates, git files,
README). The Git wizard (5/6) and the Properties editor (8) are v2 — both are new forms
and higher risk. Task 8 could ship in v1 as a *metadata-only* editor (no file
regeneration) if the reconciliation work is deferred.

## 8. Open questions for owner

1. **AI checkbox vs dropdown-only:** keep the `chkAIFriendly` checkbox gating the
   tool dropdown (recommended, matches Git pattern), or replace it with a
   dropdown that includes a "None" entry?
2. **README timing:** always generate, or only when Git is enabled?
3. **Extra v1 scope:** include `.editorconfig` and/or an optional `src/ docs/
   resources/` folder-scaffold, or defer both?
4. **Tool list:** confirm the five — Claude Code, Cursor, ChatGPT (Codex),
   OpenCode, Kun (Deepseek) — and which is the default (assumed Claude Code).
5. **Shared AGENTS.md:** self-contained per-tool folders for v1 (recommended), or
   a `_shared/` folder from the start?
6. **Properties editor (Task 8) access point:** project-tree context-menu
   **Properties**, a **Project ▸ Properties** menu item, or both?
7. **Properties editor regeneration policy:** confirm-then-overwrite for
   `LICENSE`/README/AI files on change (recommended), or **metadata-only** (never
   touch already-stamped files) for v1? And on an AI-tool switch, leave vs. remove
   the previously stamped tool's files?
8. **Project Description:** add the field to the *create* dialog now (with a
   `{{DESCRIPTION}}` token in README), or edit-only in the Properties editor?

## 9. Notes

- No installer/staging changes needed — `Templates/` ships wholesale (§2).
- The new `.vfp` metadata keys (`AITool`, etc.) are safely ignored by today's
  loader — its key parser is an If/ElseIf chain with no branch for unknown keys.
- Private SSH keys are never read. Only the `.pub` half is displayed.
