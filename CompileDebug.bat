@echo off
REM Debug build for daily development: -g -exx -mt, no GCC optimization (fbc default -O0).
REM Skips mff when sources are older than astoria.dll. Overwrites release build outputs.
REM Env: VERBOSE=1, FORCE_MFF=1, SKIP_MFF=1, NOPAUSE=1.

call "%~dp0BuildCommon.bat"

if "%BUILD_MFF%"=="1" (
	echo [%time%] Building astoria.dll ^(debug^)...
	cd /d "%MFF_DIR%"
	"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -mt -g -exx -x "../../../astoria.dll" %FBC_VERBOSE%
	if errorlevel 1 exit /b 1
) else (
	echo [%time%] Skipping astoria.dll ^(up to date; set FORCE_MFF=1 to rebuild^).
)

echo [%time%] Building astoria.exe ^(debug^)...
cd /d "%SRC_DIR%"
"%FBC64%" "AstoriaIDE.bas" -s gui -gen gcc -mt -g -exx -x "../astoria.exe" "AstoriaIDE.rc" -i "..\Controls\Framework" %FBC_VERBOSE%
if errorlevel 1 exit /b 1

echo [%time%] Debug build complete.
cd /d "%ROOT%"

if "%NOPAUSE%"=="" pause
exit /b 0
