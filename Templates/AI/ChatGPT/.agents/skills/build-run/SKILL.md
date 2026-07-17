---
name: build-run
description: Build and run this FreeBASIC project. Use when compiling, running, or checking whether {{PROJECT}} builds, or when a build fails.
---

# Build and run {{PROJECT}}

1. **Preferred:** open `{{PROJECT}}.vfp` in the Astoria IDE and press **F5** (build + run). The IDE handles `.frm` main files, resource (`.rc`) generation, and the framework include path automatically.
2. **Console project, command line:** `fbc -s console <MainFile>.bas`, then run the `.exe` produced next to it.
3. **GUI project, command line:** `<AstoriaDir>\Compiler\fbc64.exe -s gui -i <AstoriaDir>\Controls\Framework <MainFile>.bas`. Caveats: `fbc` does not accept a `.frm` file as direct input, and the generated `#cmdline "<name>.rc"` line expects an IDE-generated resource file -- the IDE is the reliable path for GUI builds.
4. The main file is the `*File=` (starred) entry in `{{PROJECT}}.vfp`.
5. On failure, read the FIRST `file(line) error N: message` line, open that location, fix the root cause, and rebuild -- later errors usually cascade from the first.
