# Test harnesses

Re-runnable scripts for the agent-automatable tests in
[Documentation/TestPlan.md](../Documentation/TestPlan.md).

**Deliberately outside the shipped tree.** `StageRelease.ps1` copies a fixed list of directories
and this is not one of them, so these never reach a release. They are development tooling, not
something a user runs.

Each script drives the IDE through its agent pipe (`\.\pipe\AstoriaAgent`), so the IDE must be
running. They assert on observable results — program output, file contents, window state — rather
than on a command having returned without error.

| Script | Test | Notes |
| --- | --- | --- |
| `D1_ConsoleLifecycle.ps1` | D1 — console app lifecycle | Deletes and recreates `Projects/D1_ConsoleLifecycle` on every run, so it is safe to repeat. |
