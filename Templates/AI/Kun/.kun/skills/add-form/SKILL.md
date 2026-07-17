---
name: add-form
description: Add a new form (.frm) to this FreeBASIC GUI project and show it from existing code. Use when the app needs another window or dialog.
---

# Add a new form to {{PROJECT}}

1. **Preferred:** in the Astoria IDE, right-click the project in the Explorer -> Add -> Form. This generates the `.frm` and registers it in the `.vfp`.
2. **By hand:** copy the shape of an existing `.frm`; rename the `Type`, the `Dim Shared` instance, and every `.Name`/`' <name>` comment consistently; then add `File=NewForm.frm` to `{{PROJECT}}.vfp`.
3. **Bootstrap block rule:** only the project's *main* form keeps the `#if _MAIN_FILE_ = __FILE__` block (`MainForm = True`, `.Show`, `App.Run`). A secondary form must NOT have one -- remove it if you copied it in.
4. Show the form from other code:
   - `NewForm.Show` -- modeless.
   - `NewForm.ShowModal(OwnerForm)` -- modal, owned by (and kept above) `OwnerForm`; returns a `ModalResults` value.
5. Compile-check (see the build-run skill).
