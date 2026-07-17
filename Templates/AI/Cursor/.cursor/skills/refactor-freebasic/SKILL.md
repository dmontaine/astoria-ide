---
name: refactor-freebasic
description: Safely rename, move, split, or simplify FreeBASIC code in an Astoria project. Use for structural refactors that affect .bas, .bi, .frm, includes, case-insensitive symbols, or the .vfp manifest.
---

# Refactor FreeBASIC safely

1. Establish a clean build and define the behavior that must remain unchanged.
2. Search case-insensitively for the symbol, filename, include, manifest entry, callback, string lookup, resource reference, and generated form reference before editing.
3. Respect FreeBASIC semantics:
   - Identifiers are case-insensitive; case-only renames do not create distinct names.
   - `Dim` is procedure-scoped, not block-scoped.
   - Public declarations belong in `.bi`; implementations belong in `.bas` or the established project pattern.
   - Include order and `#include once` can affect visibility and duplicate definitions.
4. For file moves or splits, update `#include once` paths and `{{PROJECT}}.vfp` in the same change. Preserve the starred main-file entry.
5. For `.frm` changes, use the `edit-form-safely` skill and keep designer-managed names synchronized.
6. Make small mechanical steps, building after each meaningful stage. Do not combine behavior changes with a broad rename unless required.
7. Search again for stale old names and inspect the final diff for accidental formatting or line-ending churn.
8. Run the original behavior check after the final clean build.
