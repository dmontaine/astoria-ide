@echo off
REM Debug build for daily development: runtime checks (-exx), debug symbols (-g), no optimization (-O0).
REM Outputs mff64.dll and VisualFBEditor64.exe (same paths as Compile.bat; overwrites release build).

set FBC64=%~dp0Compiler\fbc64.exe

echo [%time%] Building mff64.dll (debug)...
cd Controls\MyFbFramework\mff
"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -g -exx -Wc -O0 -x "../mff64.dll" -v
if errorlevel 1 exit /b 1

echo [%time%] Building VisualFBEditor64.exe (debug)...
cd ..\..\..\src
"%FBC64%" "VisualFBEditor.bas" -s gui -gen gcc -g -exx -Wc -O0 -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v
if errorlevel 1 exit /b 1

echo [%time%] Debug build complete.
cd ..\

if "%NOPAUSE%"=="" pause
exit /b 0
