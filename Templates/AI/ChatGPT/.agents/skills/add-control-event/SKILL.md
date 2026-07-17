---
name: add-control-event
description: Add an MFF control to a form and wire an event handler in this FreeBASIC GUI project. Use when adding buttons, textboxes, or other controls, or hooking up OnClick/OnChange-style events.
---

# Add a control and wire an event

Preferred: use the Astoria Form Designer (drop the control on the form, double-click it to generate the handler). When editing by hand, follow the MFF pattern the designer generates:

1. Include the control's header near the other `mff/` includes:
   ```
   #include once "mff/CommandButton.bi"
   ```
2. In the form's `Type ... Extends Form` block, declare the handler and the control:
   ```
   Declare Sub cmdGo_Click(ByRef Sender As Control)
   Dim As CommandButton cmdGo
   ```
3. In the `Constructor`, configure and wire it (keep the `' <name>` comment line -- the designer expects it):
   ```
   ' cmdGo
   With cmdGo
       .Name = "cmdGo"
       .Text = "Go"
       .SetBounds 10, 10, 90, 28
       .Designer = @This
       .Parent = @This
       .OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdGo_Click)
   End With
   ```
4. Implement the handler after the `Type` block:
   ```
   Private Sub <FormType>.cmdGo_Click(ByRef Sender As Control)
       ' ...
   End Sub
   ```

Notes: `.Parent` may be the form (`@This`) or a container control (e.g. `@Panel1`). Control text properties are `WString`. Common controls: `CommandButton`, `Label`, `TextBox`, `CheckBox`, `ComboBoxEdit`, `ListView`, `Panel` -- each has a matching `mff/<Name>.bi`.
