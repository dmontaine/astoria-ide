@echo off
REM Release build: Framework (framework.dll) then astoria.exe.
REM Flags: -gen gcc -mt -Wc -O2. Skips mff when sources are older than framework.dll.
REM Env: VERBOSE=1 (fbc -v), FORCE_MFF=1, SKIP_MFF=1, NOPAUSE=1. Close running IDE before linking.

call "%~dp0BuildCommon.bat"

if "%BUILD_MFF%"=="1" (
	echo [%time%] Building framework.dll...
	cd /d "%MFF_DIR%"
	"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -mt -Wc -O2 -x "../framework.dll" %FBC_VERBOSE%
	if errorlevel 1 exit /b 1
) else (
	echo [%time%] Skipping framework.dll ^(up to date; set FORCE_MFF=1 to rebuild^).
)

echo [%time%] Building astoria.exe...
cd /d "%SRC_DIR%"
"%FBC64%" "AstoriaIDE.bas" -s gui -gen gcc -mt -Wc -O2 -x "../astoria.exe" "AstoriaIDE.rc" -i "..\Controls\Framework" %FBC_VERBOSE%
if errorlevel 1 exit /b 1

echo [%time%] Release build complete.
cd /d "%ROOT%"

if "%NOPAUSE%"=="" pause
exit /b 0
