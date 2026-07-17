---
name: fix-compile-errors
description: Diagnose FreeBASIC compile and link errors in this project. Use when fbc reports errors, the build fails, or an error message needs interpreting.
---

# Fix compile errors

FreeBASIC errors are precise: `file.bas(12) error 18: Element not defined, X`. Open the file at that line and fix the root cause. **Always fix the FIRST error before looking at the rest -- later ones usually cascade.**

Common errors in this project's ecosystem:

- **`error 18: Element not defined, X`** -- missing `#include once` for the header that declares `X`, or a typo. Identifiers are case-insensitive, so `myVar` and `MyVar` are the same name.
- **`error 4: Duplicated definition`** -- two declarations collide, possibly differing only by case, or a `.bi` was included without `#include once`.
- **Linker `undefined reference to X`** -- `X` was declared but never implemented, or its `.bas` file is missing from the `.vfp`'s `File=` list.
- **`error 24: Invalid data types` on `IIf`** -- `IIf` cannot return a `String`; rewrite as an explicit `If/Else` assignment.
- **A variable visible where you didn't expect** -- `Dim` is procedure-scoped, not block-scoped; a `Dim` inside an `If`/loop lives until `End Sub`. Move declarations to the top of the procedure or rename.
- **Type mismatch on text** -- MFF control text properties are `WString`; don't mix them with `ZString` pointers without an explicit conversion.
- **GUI project fails at command line but builds in the IDE** -- missing `-i <AstoriaDir>\Controls\Framework`, `.frm` passed directly to `fbc` (not accepted), or the `#cmdline "<name>.rc"` resource the IDE would generate is absent. Build in the IDE.
