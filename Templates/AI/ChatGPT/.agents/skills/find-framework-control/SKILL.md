---
name: find-framework-control
description: Find the correct MFF framework control, header, properties, events, and working FreeBASIC examples. Use before adding an unfamiliar GUI control or when a control API, event signature, or constructor pattern is uncertain.
---

# Find an MFF control pattern

1. Search `<AstoriaDir>\Controls\Framework\mff` for control names and matching `.bi` headers. Read declarations before assuming a property or event exists.
2. Search the current project and `<AstoriaDir>\Examples` for real uses of the control. Prefer examples that show both the designer `With` block and event handler.
3. Record the minimum verified pattern:
   - Required `#include once "mff/<Control>.bi"`.
   - Control type and declaration.
   - Required parent/designer assignments.
   - Relevant properties and their types, especially `WString` text.
   - Exact event field and handler signature.
4. Prefer the Astoria Form Designer when it exposes the control. Use the verified hand-written pattern only when necessary.
5. Do not invent VB.NET, VBA, or WinForms members with similar names.
6. After adding the control, build the project and verify the event fires at runtime.

When several controls fit, briefly compare them and choose based on behavior already demonstrated in the framework or examples.
