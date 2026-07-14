@echo off
REM Debug build of astoria.exe only (never rebuilds framework.dll).
REM Use after src-only edits. Same flags as CompileDebug.bat for the IDE step.
REM Env: VERBOSE=1, NOPAUSE=1.

set "SKIP_MFF=1"
call "%~dp0BuildCommon.bat"

echo [%time%] Building astoria.exe only ^(debug^)...
cd /d "%SRC_DIR%"
"%FBC64%" "AstoriaIDE.bas" -s gui -gen gcc -mt -g -exx -x "../astoria.exe" "AstoriaIDE.rc" -i "..\Controls\Framework" %FBC_VERBOSE%
if errorlevel 1 exit /b 1

echo [%time%] IDE-only debug build complete.
cd /d "%ROOT%"

if "%NOPAUSE%"=="" pause
exit /b 0
