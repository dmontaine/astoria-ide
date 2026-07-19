---
name: audit-project-manifest
description: Audit an Astoria .vfp project manifest against its FreeBASIC source and resource files. Use when files are missing from the IDE, builds omit code, the main file is wrong, or a rename/add/delete may have left stale manifest entries.
---

# Audit the project manifest

1. Locate `{{PROJECT}}.vfp` and read all `File=` and `*File=` entries without rewriting unrelated metadata.
2. Inventory project-owned `.bas`, `.bi`, `.frm`, `.rc`, and other explicitly tracked files. Exclude generated executables, `Temp/`, the change log, `.git/`, and AI guidance unless the manifest intentionally lists them.
3. Report before changing anything:
   - Existing source files missing from the manifest.
   - Manifest entries whose files do not exist.
   - Duplicate entries, including case-only duplicates.
   - More than one starred main file, or no main file when one is required.
   - Path separator, relative-path, or filename-case inconsistencies.
4. Determine the intended main file from the project type and existing bootstrap code; do not guess when multiple candidates are plausible.
5. Apply only confirmed corrections. Preserve entry order where possible and leave IDE-maintained metadata keys untouched.
6. Reopen or build the project in Astoria to verify the corrected manifest.
