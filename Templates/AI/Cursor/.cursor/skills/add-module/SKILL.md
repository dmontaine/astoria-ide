---
name: add-module
description: Add a new .bas module (with optional .bi header) to this FreeBASIC project and register it in the .vfp manifest. Use when creating new source files or splitting code out of an existing file.
---

# Add a module to {{PROJECT}}

1. Create `NewName.bas`. If other files will call into it, also create `NewName.bi` holding the `Declare Sub/Function ...` lines and any shared `Type`s/`Const`s/`Enum`s.
2. Implement everything in the `.bas`; `#include once "NewName.bi"` in each file that needs the declarations.
3. **Register the file:** add `File=NewName.bas` to `{{PROJECT}}.vfp` (or add the file through the IDE's project Explorer, which maintains the manifest for you). A file not listed in the `.vfp` is invisible to the project.
4. Compile-check before moving on (see the build-run skill).

Conventions: identifiers are case-insensitive; keep one module per concern; match the project's existing indentation (tabs in generated files) and line endings.
