@echo off
REM Debug build for daily development: -g -exx -mt, no GCC optimization (fbc default -O0).
REM Skips mff when sources are older than mff64.dll. Overwrites release build outputs.
REM Env: VERBOSE=1, FORCE_MFF=1, SKIP_MFF=1, NOPAUSE=1.

call "%~dp0BuildCommon.bat"

if "%BUILD_MFF%"=="1" (
	echo [%time%] Building mff64.dll ^(debug^)...
	cd /d "%MFF_DIR%"
	"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -mt -g -exx -x "../mff64.dll" %FBC_VERBOSE%
	if errorlevel 1 exit /b 1
) else (
	echo [%time%] Skipping mff64.dll ^(up to date; set FORCE_MFF=1 to rebuild^).
)

echo [%time%] Building VisualFBEditor64.exe ^(debug^)...
cd /d "%SRC_DIR%"
"%FBC64%" "VisualFBEditor.bas" -s gui -gen gcc -mt -g -exx -x "../VisualFBEditor64.exe" "VisualFBEditor.rc" -i "..\Controls\MyFbFramework" %FBC_VERBOSE%
if errorlevel 1 exit /b 1

echo [%time%] Debug build complete.
cd /d "%ROOT%"

if "%NOPAUSE%"=="" pause
exit /b 0
