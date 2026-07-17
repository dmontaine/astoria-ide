---
name: edit-form-safely
description: Safely edit Astoria MFF .frm files without damaging designer-managed code. Use when changing a form, its controls, layout, properties, event declarations, handlers, or main-form bootstrap code.
---

# Edit an Astoria form safely

1. Read the entire `.frm` and identify the `'#Region "Form"` designer-managed block, the form `Type`, `Constructor`, event handlers, shared instance, and optional main-file bootstrap.
2. Prefer the Astoria Form Designer for control and layout changes. Edit handler bodies outside the generated region directly.
3. If hand-editing the region, preserve its generated shape:
   - Keep each control declaration in the form `Type`.
   - Keep each `' <ControlName>` marker and matching `With <ControlName>` block.
   - Keep `.Name`, `.Designer`, `.Parent`, bounds, and event assignments consistent.
   - Rename every declaration, marker, `With` block, event target, and reference together.
4. Keep the `#if _MAIN_FILE_ = __FILE__` bootstrap only on the main form. Secondary forms must not start `App.Run`.
5. Do not reformat unrelated generated code. Preserve tabs and line endings.
6. Confirm every referenced control header is included, the form remains listed in `{{PROJECT}}.vfp`, and the project builds through Astoria.

Treat an unclear designer pattern as a reason to inspect a similar form under the project or Astoria `Examples/` before editing.
