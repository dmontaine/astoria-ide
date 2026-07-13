@echo off
REM Shared paths and mff staleness check for Compile*.bat (do not run directly).
REM Sets: ROOT, FBC64, MFF_DIR, MFF_DLL, SRC_DIR, EXE_OUT, FBC_VERBOSE, BUILD_MFF
REM Env: VERBOSE=1 (pass -v to fbc), SKIP_MFF=1 (never build mff), FORCE_MFF=1 (always build mff)

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "FBC64=%ROOT%\Compiler\fbc64.exe"
set "MFF_DIR=%ROOT%\Controls\MyFbFramework\mff"
set "MFF_DLL=%ROOT%\astoria.dll"
set "SRC_DIR=%ROOT%\src"
set "EXE_OUT=%ROOT%\astoria.exe"

if defined VERBOSE (set "FBC_VERBOSE=-v") else (set "FBC_VERBOSE=")

set "BUILD_MFF=1"
if "%FORCE_MFF%"=="1" goto :mff_check_done
if "%SKIP_MFF%"=="1" set "BUILD_MFF=0" & goto :mff_check_done
if not exist "%MFF_DLL%" goto :mff_check_done

powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\BuildCompareMff.ps1" -DllPath "%MFF_DLL%" -SourceDir "%MFF_DIR%"
if errorlevel 1 set "BUILD_MFF=0"

:mff_check_done
exit /b 0
