---
name: debug-freebasic-app
description: Diagnose runtime failures, crashes, hangs, incorrect behavior, or debugger problems in an Astoria FreeBASIC application. Use when the project compiles but misbehaves or when breakpoints, GDB output, or exit codes need interpretation.
---

# Debug a FreeBASIC application

1. Reproduce the smallest reliable case and record the exact action, observed result, expected result, and whether it occurs with Astoria's debugger enabled.
2. Build the current sources before debugging. Resolve compile or link errors with the `fix-compile-errors` skill first.
3. Set breakpoints on executable statements, not comments, declarations, blank lines, or generated layout-only lines. Confirm the breakpoint binds before drawing conclusions.
4. Trace inputs and state at the first point behavior diverges. Inspect pointer validity, object lifetime, array bounds, string type conversions, callback ownership, and WinAPI return values.
5. Separate failure classes:
   - Immediate process exit: inspect the real exit code and startup path.
   - Crash: identify the first failing frame and invalid value.
   - Hang: determine which loop, wait, modal window, or worker owns progress.
   - Debugger-only behavior: compare a normal F5 run with debugger use and preserve relevant GDB output.
6. Make one focused fix, rebuild, and repeat the original reproduction plus a nearby regression case.
7. Do not paper over unknown failures with delays, broad exception handling, or fabricated success codes.

Ask the user for a live UI check when correctness depends on interaction, focus, timing, modality, or rendering.
