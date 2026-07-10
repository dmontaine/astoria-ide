@echo off
REM Release build: MyFbFramework (mff64.dll) then astoria.exe.
REM Flags: -gen gcc -mt -Wc -O2. Skips mff when sources are older than mff64.dll.
REM Env: VERBOSE=1 (fbc -v), FORCE_MFF=1, SKIP_MFF=1, NOPAUSE=1. Close running IDE before linking.

call "%~dp0BuildCommon.bat"

if "%BUILD_MFF%"=="1" (
	echo [%time%] Building mff64.dll...
	cd /d "%MFF_DIR%"
	"%FBC64%" -b "mff.bi" "mff.rc" -dll -gen gcc -mt -Wc -O2 -x "../mff64.dll" %FBC_VERBOSE%
	if errorlevel 1 exit /b 1
) else (
	echo [%time%] Skipping mff64.dll ^(up to date; set FORCE_MFF=1 to rebuild^).
)

echo [%time%] Building astoria.exe...
cd /d "%SRC_DIR%"
"%FBC64%" "AstoriaIDE.bas" -s gui -gen gcc -mt -Wc -O2 -x "../astoria.exe" "AstoriaIDE.rc" -i "..\Controls\MyFbFramework" %FBC_VERBOSE%
if errorlevel 1 exit /b 1

echo [%time%] Release build complete.
cd /d "%ROOT%"

if "%NOPAUSE%"=="" pause
exit /b 0
