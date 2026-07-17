---
name: add-resource
description: Add or replace icons, images, manifests, dialogs, strings, or other Windows resources in an Astoria FreeBASIC project. Use when changing .rc content or resource files while keeping source and .vfp references synchronized.
---

# Add a project resource

1. Inspect the project's existing `.rc`, resource folders, source lookups, and `{{PROJECT}}.vfp` conventions before choosing a path or identifier.
2. Reuse the existing resource organization and identifier style. Choose a unique numeric or symbolic ID; search the project first to avoid collisions.
3. Add the asset and update the `.rc` entry. Quote paths containing spaces and keep paths relative to the `.rc` file unless the project consistently does otherwise.
4. Update source references and includes together. Preserve Unicode/ANSI API expectations and the asset format expected by the loader.
5. Add the resource file to `{{PROJECT}}.vfp` only if this project tracks comparable resources there; do not invent a new manifest convention.
6. Do not edit generated executables or files under `Temp/`.
7. Build through Astoria so resource compilation is exercised, then run the affected UI and verify the resource loads at its intended size and state.

For replacements, confirm all old references are gone before deleting the old asset, and ask before destructive deletion.
