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
| `D5_McpMultiFile.ps1` | D5 — AI/MCP multi-file project | Builds a three-file project with a deliberate error, then repairs it. |
| `E2_CorruptSettings.ps1` | E2 — corrupt settings recovery | Restores the owner's original `astoria.ini` after every case. |
| `E4_E6_Scale.ps1` | E4, E6 — scale | `-SkipE4` runs the 250-file project only; E4's 100,000-line member is beyond the practical 1.0 limit. |
| `E11_MultipleInstances.ps1` | E11 — multiple instances | **Starts the IDE itself rather than driving a running one**, and expects two failures while ROADMAP §13.29 is open (E11-3, E11-5). Backs up and restores `astoria.ini`/`Workspace.ini`. |

**One warning from E11 that applies to any harness here.** Do not measure a crash with an exit
code. `cmd`'s `ERRORLEVEL` does not carry `0xC0000005` out of `start /wait`, and a
`... & echo EXIT=%ERRORLEVEL%` compound line reports the *previous* errorlevel because `cmd`
expands the variable when it parses the line. Both of those produced a confident "clean exit" for a
launch that was crashing on every attempt. Count crash records in the Windows Application event log
instead (Provider `Application Error`, Id 1000, filtered to `astoria.exe`), and make the counter
prove it can read the log before believing a zero from it.
