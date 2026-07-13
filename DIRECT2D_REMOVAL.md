# Direct2D removal — what happened and how to bring it back

**Removed:** 2026-07-13. **Last commit before removal:** `faaf0860ecfaa69752e1533969a9b499c155441e` (2026-07-13 11:07:58 -0700) — the entire pre-removal Direct2D implementation is recoverable from that commit (or any commit before it) via `git show <hash>:<path>` or `git checkout <hash> -- <path>`.

## Why it was removed

Owner decision, 2026-07-13, made deliberately and not as a bug fix:

- Direct2D had been **force-disabled the entire time** it existed in this codebase (`SettingsService.bas` unconditionally reset `UseDirect2D` to `False` on every startup, overwriting even a saved `True` value in the INI, with the comment *"Prefer reliable GDI rendering until D2D path is explicitly re-enabled"*). It had never been exercised by a real user in normal use.
- One real bug was already found in it (H-1, fixed 2026-07-13 earlier the same day): `Canvas.Cls`'s Direct2D clear path created an unnecessary GDI brush and didn't close the Direct2D drawing session before returning. That fix could only be verified by reading the code, not by running it live, since the toggle that would reach it was disabled by default.
- This project is explicitly opinionated and narrow in scope (see `PROJECT_STATUS.md`'s "no unnecessary options" principle, and prior decisions like removing the alternate debugger backend and collapsing dark-mode options). A GDI/Direct2D rendering-backend toggle that most users would never touch, backed by a code path with zero real-world verification, didn't fit that principle.
- The owner's stated plan: **reconsider Direct2D once it can be proven stable, and make it the default (not an option) if so** — not before. Until then, keep the codebase small: one rendering path (GDI/GDI+), fully removed rather than dormant-but-untested.

## Scope of the removal

Two independent systems both had Direct2D support, and both were fully stripped:

1. **The IDE's own code editor text rendering** (`src/EditControl.bas`/`.bi`) — the `UseDirect2D` toggle (toolbar button in `src/Main.bas`, `Case "UseDirect2D"` dispatch in `src/AstoriaIDE.bas`, the "Smoother text rendering (Direct2D)" checkbox in `src/frmOptions.frm`/`.bi`), and the INI load/force-disable logic + `LoadD2D1`/`UnloadD2D1` calls in `src/SettingsService.bas`/`src/Main.bas`.
2. **The MFF framework's `Canvas` control** (`Controls/MyFbFramework/mff/Canvas.bas`/`.bi`) — a Direct2D drawing capability exposed to *end-user GUI programs* built with this IDE (unrelated to the code editor). This included the public `UseDirect2D` property, all the `FUseDirect2D`/`pRenderTarget`-gated branches in every drawing method (`Cls`, `MoveTo`, `LineTo`, `Rectangle`, `Ellipse`, `Circle`, `RoundRect`, `Polygon`, `Polyline`, `PolylineTo`, `PolyBeizer`, `PolyBeizerTo`, `SetPixel`, `TextOut`, `DrawAlpha`, `Draw`, `FillRect`, `SetHandle`, `UnSetHandle`, `GetDevice`, `ReleaseDevice`, `Font_Create`, `Pen_Create`, `Brush_Create`), and the now-dead `CreateD2DBitmapFromHBITMAP` helper.
3. **The D2D1 API binding module** (`Controls/MyFbFramework/mff/D2D1/D2D1.bi`, ~2760 lines of raw D2D1/DirectWrite/Direct3D11/DXGI COM interface declarations) was deleted outright — nothing else `#include`'d it once (1) and (2) no longer did.
4. **The Canvas example project** (`Controls/MyFbFramework/examples/Canvas/Canvas Example.frm`) had a GDI/GDI+/Direct2D three-way radio-button demo; the Direct2D option (`RadioD2D1` and its click handler) was removed, leaving GDI/GDI+.

Everywhere a drawing method had a three-way branch (`If FUseDirect2D AndAlso pRenderTarget <> 0 Then <D2D> ElseIf UsingGdip Then <GDI+> Else <GDI>`), the D2D branch was deleted and the GDI+/GDI branches kept as-is, unchanged. GDI/GDI+ rendering behavior is untouched by this removal.

## How to bring it back

1. Recover the deleted/modified files from before the removal commit:
   ```
   git show faaf0860ecfaa69752e1533969a9b499c155441e:Controls/MyFbFramework/mff/D2D1/D2D1.bi > Controls/MyFbFramework/mff/D2D1/D2D1.bi
   git checkout faaf0860ecfaa69752e1533969a9b499c155441e -- Controls/MyFbFramework/mff/Canvas.bas Controls/MyFbFramework/mff/Canvas.bi src/EditControl.bas src/EditControl.bi src/Main.bas src/AstoriaIDE.bas src/frmOptions.frm src/frmOptions.bi src/SettingsService.bas Controls/MyFbFramework/mff/Application.bas "Controls/MyFbFramework/examples/Canvas/Canvas Example.frm" Controls/MyFbFramework/MyFbFramework.vfp
   ```
   This restores the exact pre-removal state of every file this removal touched — safer than reapplying by hand, since the D2D code was deeply interleaved with GDI/GDI+ logic throughout `Canvas.bas` and `EditControl.bas`.
2. Before re-enabling as a *user-facing option* again: **don't**. Per the owner's stated plan, if/when Direct2D is trusted, make it the sole renderer (replacing GDI), not a second option alongside it — re-litigate that decision with the owner first rather than assuming "restore = re-add the toggle."
3. Whatever the direction, the H-1 bug (`Canvas.Cls`'s duplicate GDI brush + unclosed Direct2D drawing session) will already be present in the restored code — it was fixed in commit history before this removal, so recovering from `faaf086` (or later) already includes that fix. Confirm it live before trusting the path again, since it still has zero real runtime verification.

## What did *not* change

GDI and GDI+ (`UsingGdip`) rendering are both fully intact and untouched — this removal only deleted the third (Direct2D) option, never exercised by default. Any project or example that doesn't reference `UseDirect2D`/`Direct2D` explicitly is unaffected.
