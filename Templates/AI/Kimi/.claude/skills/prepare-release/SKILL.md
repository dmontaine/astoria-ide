---
name: prepare-release
description: Prepare and verify a release of an Astoria FreeBASIC project. Use for clean release builds, artifact and dependency checks, version/readme/license review, packaging preparation, or a pre-release checklist; do not publish automatically.
---

# Prepare a release

1. Confirm the requested version, target, and release scope. Review working-tree changes; do not discard unrelated user work.
2. Verify `{{PROJECT}}.vfp`, the starred main file, required resources, framework dependencies, license, and user-facing README information.
3. Remove release blockers from the intended artifact set: debug-only behavior, absolute developer paths, temporary files, trace logs, stale executables, secrets, and missing runtime dependencies. Do not delete source files merely because they are excluded from packaging.
4. Perform the project's normal clean release build through Astoria. Do not substitute an ad-hoc command for a project-specific release procedure.
5. Test the built artifact from the intended distribution layout, not only from the source tree. Exercise startup, primary workflow, error reporting, and clean exit.
6. Record the produced artifact paths, build result, smoke-test result, known limitations, and any manual checks still required.
7. Do not commit, tag, push, upload, sign, or publish unless the user explicitly requests that separate action.

When no packaging method exists, provide a minimal reproducible staging checklist rather than inventing an installer or deployment system.
