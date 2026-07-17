---
name: winapi-interop
description: Add or review Windows API interoperability in Win64 FreeBASIC code. Use for API declarations, structures, callbacks, window procedures, handles, pointers, Unicode calls, COM interfaces, or resource ownership.
---

# Write safe Win64 API interop

1. Find an existing declaration in FreeBASIC headers or the project before declaring an API, constant, structure, or callback manually.
2. Target Win64 only. Use pointer-sized types for pointers, handles, addresses, `WPARAM`, `LPARAM`, and results; never assume a pointer fits in `Integer`.
3. Prefer Unicode `...W` APIs and pass compatible `WString` data. Keep `String`, `WString`, and `ZString Ptr` conversions explicit and lifetime-safe.
4. Match the documented calling convention, callback signature, structure layout, field widths, and ByVal/ByRef behavior exactly. Initialize required size/version fields.
5. Check API success according to that function's contract. Capture `GetLastError()` immediately when applicable, before another API call overwrites it.
6. Pair every acquired resource with the correct release operation: handles, device contexts, GDI objects, allocated memory, COM references, libraries, hooks, and subclasses.
7. Keep callback targets alive for as long as Windows may call them. Do not pass pointers to temporary or out-of-scope data.
8. Compile and exercise both success and failure paths. Review casts closely; a cast can hide a width or ownership bug without making it safe.

When declarations are uncertain, verify against authoritative Microsoft documentation and the installed FreeBASIC headers before editing.
