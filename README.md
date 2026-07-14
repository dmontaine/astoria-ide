# Astoria IDE
## IDE for FreeBasic

#### Introduction
Astoria IDE is the IDE for FreeBasic with visual designer, debugger, project support and etc. It is a fork of <a href="https://github.com/XusinboyBekchanov/VisualFBEditor">VisualFBEditor</a>, based on the library <a href="https://github.com/XusinboyBekchanov/MyFbFramework">MyFbFramework</a>.

#### Requirements:

None — this fork bundles the FreeBASIC compiler (`Compiler\fbc64.exe`, FBC 1.10.1) and the GDB debugger in-repo. Just clone and build; no separate FreeBASIC installation needed. Windows 64-bit only.

#### Screenshots

<!-- TODO(owner): these are inherited from upstream VisualFBEditor and show the
     old UI/branding. Replace with current AstoriaIDE screenshots -- see
     Fable review F-C5 / PROJECT_STATUS.md T12. -->
![VisualFBEditor-1](https://user-images.githubusercontent.com/35757455/197079538-16cc5d7d-150e-46f1-b673-f9fe7352ad17.png)
![VisualFBEditor-2](https://user-images.githubusercontent.com/35757455/197079581-596100e9-86be-4469-8aae-104309845b2c.png)
![VisualFBEditor-3](https://user-images.githubusercontent.com/35757455/197079617-4c4d6902-3809-40da-a746-46bcdf993a75.png)
![VisualFBEditor-4](https://user-images.githubusercontent.com/35757455/197079674-2a2a685e-2403-4b8b-9b3b-95c4cc8bf5dc.png)
![VisualFBEditor-5](https://user-images.githubusercontent.com/35757455/197079706-5419cc84-db93-48b2-93f9-456db2414956.png)
![VisualFBEditor-6](https://user-images.githubusercontent.com/35757455/197079725-a88431cb-34e7-4a75-be8f-cd7f3f845ce5.png)
![image](https://github.com/XusinboyBekchanov/VisualFBEditor/assets/32607344/f98ffda9-88be-4e67-8074-1b58b24ae151)

#### Compilation:

> **Note:** This fork builds the IDE as **64-bit Windows only** (native WinAPI). Run root `Compile.bat` to build `framework.dll` and `astoria.exe`, or use the manual commands below. The bundled compiler is `Compiler\fbc64.exe`. Linux, GTK, and 32-bit IDE builds are not supported in this fork.

#### Quick build (recommended):
```shell
  cd Path_to_AstoriaIDE
  Compile.bat
```

#### Windows 64-bit (manual):
```shell
  cd Path_to_AstoriaIDE/Controls/Framework/mff
  fbc64 -b "mff.bi" "mff.rc" -dll -x "../framework.dll"
  cd Path_to_AstoriaIDE/src
  fbc64 "AstoriaIDE.bas" -s gui -x "../astoria.exe" "AstoriaIDE.rc" -i "Path_to_AstoriaIDE/Controls/Framework"
```

See also `src/BUILD.md` for the full build pipeline.
__
