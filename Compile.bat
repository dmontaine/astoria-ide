@echo off
REM Release build: MyFbFramework (mff64.dll) then VisualFBEditor64.exe.
REM Flags: -gen gcc -Wc -O2 -v. Close running IDE before linking the exe.

set FBC64=%~dp0Compiler\fbc64.exe

echo [%time%] Building mff64.dll...
cd Controls\MyFbFramework\mff
"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -Wc -O2 -x "../mff64.dll" -v
if errorlevel 1 exit /b 1

echo [%time%] Building VisualFBEditor64.exe...
cd ..\..\..\src
"%FBC64%" "VisualFBEditor.bas" -s gui -gen gcc -Wc -O2 -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" -v
if errorlevel 1 exit /b 1

echo [%time%] Release build complete.
cd ..\

if "%NOPAUSE%"=="" pause
exit /b 0
