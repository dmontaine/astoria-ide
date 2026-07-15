<#
.SYNOPSIS
    Assembles a clean, end-user-facing release tree for Astoria-IDE.

.DESCRIPTION
    Copies only what an end-user developer needs to run Astoria-IDE and compile
    their own FreeBasic programs with it - not this repo's own IDE source, build
    scripts, or maintainer documentation. Rerunnable at any time: clears the
    release directory and rebuilds it from scratch on every run, so it's always
    an exact reflection of the current repo state.

    Controls/*/mff/*.bas (and the MariaDBBox/ScintillaControl/SQLite3 equivalents)
    are intentionally included despite being source code: every project's Form.frm
    template does #include once "mff/Form.bi", and that header text-includes its
    own .bas implementation - FreeBasic's Type system needs the full definition,
    not just declarations, so a prebuilt framework.dll + headers-only isn't
    sufficient for a user's own project to compile. The GPL source-access
    requirement for the IDE's own source (src/) is satisfied by the project's
    GitHub repository, not by this release tree.

    The release directory lives outside this repo (a sibling of it), so it's
    never tracked by git regardless of .gitignore - only this script is.

.NOTES
    Rerun after any change to what should ship, then spot-check the result
    before distributing it.
#>

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
$ReleaseRoot = Join-Path $env:USERPROFILE "Astoria-IDE-Release"

if (-not $ReleaseRoot.EndsWith("Astoria-IDE-Release")) {
    throw "Refusing to continue: release path '$ReleaseRoot' doesn't end with 'Astoria-IDE-Release' - this script clears its target directory on every run, so this sanity check guards against a future edit accidentally pointing it somewhere unintended."
}

Write-Host "Repo root:    $RepoRoot"
Write-Host "Release root: $ReleaseRoot"
Write-Host ""

# --- Clear and recreate the release directory ---
if (Test-Path $ReleaseRoot) {
    Write-Host "Clearing existing release directory..."
    Remove-Item -Path $ReleaseRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $ReleaseRoot -Force | Out-Null

# --- Top-level files: runtime artifacts, not source ---
$TopLevelFiles = @(
    "astoria.exe",
    "license.txt"
)

foreach ($f in $TopLevelFiles) {
    $src = Join-Path $RepoRoot $f
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination (Join-Path $ReleaseRoot $f) -Force
        Write-Host "Copied file:      $f"
    } else {
        Write-Warning "Expected top-level file not found, skipped: $f"
    }
}

# --- Top-level directories: included wholesale (runtime deps, templates, docs users need) ---
# Documentation/ (a standalone HTML copy of the FreeBasic language reference) is
# deliberately NOT included: Help/ already ships this same information in the
# IDE's own compiled help form, and the FreeBASIC website covers anything beyond
# that - keeping both is redundant given this fork's opinionated, focused scope.
$WholesaleDirs = @(
    "Compiler",       # bundled fbc64 - users need this to compile their own programs
    "Debuggers",      # bundled gdb - needed for the IDE's debugging feature
    "Templates",      # New Project / New File skeletons, used by the IDE at runtime
    "Resources",      # icons/images the IDE loads at runtime
    "Help",           # in-IDE help content
    "Tools",          # user-facing utility tools (some ship their own .bas alongside a
                       # prebuilt .exe, e.g. COMWrapperBuilder - that's a tool FOR the
                       # user to run/modify, not IDE implementation, so kept as-is)
    "AddIns",         # compiled .dll IDE add-ins, no source
    "Examples"        # kept WITH source deliberately - these teach the framework
)

foreach ($d in $WholesaleDirs) {
    $src = Join-Path $RepoRoot $d
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination (Join-Path $ReleaseRoot $d) -Recurse -Force
        Write-Host "Copied directory: $d"
    } else {
        Write-Warning "Expected directory not found, skipped: $d"
    }
}

# Compiler/doc and Compiler/examples: the same "our own Help + Examples cover
# this" reasoning as Documentation/ above - drop the compiler's own bundled
# copies rather than ship the same material twice.
$compilerPrune = @("doc", "examples")
foreach ($sub in $compilerPrune) {
    $path = Join-Path $ReleaseRoot "Compiler\$sub"
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "Pruned:           Compiler\$sub"
    }
}

# Tools/: prune items inappropriate for the release, keep the legitimate
# Windows-native dev utilities (COMWrapperBuilder, ControlSpy, SPY/Spy++, depends).
#   LNGCreator      - creates .lng translation files; this fork already removed
#                     the whole translation system (English-only mandate)
#   strip_gtk_*     - one-time maintainer scripts that stripped dead GTK/Linux
#                     branches from THIS REPO'S OWN source during the Win64-only
#                     migration; nothing to do with what a user does with the IDE
#   Tools.ini       - the developer's own personal External Tools config
#                     (hardcoded paths to this machine's Chrome/Notepad++), same
#                     category as astoria.ini - not shipped for the same reason
#   ToolsX.ini      - stale leftover from the original cross-platform upstream
#                     project (references VisualFBEditor64_gtk2 and a Linux path)
$toolsPrune = @(
    "LNGCreator",
    "strip_gtk_preprocessor.ps1",
    "strip_gtk_preprocessor.py",
    "Tools.ini",
    "ToolsX.ini"
)
foreach ($item in $toolsPrune) {
    $path = Join-Path $ReleaseRoot "Tools\$item"
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "Pruned:           Tools\$item"
    }
}

# --- Controls/: wholesale, minus vendored/uncurated "examples" subfolders ---
# mff/*.bas (and the cJSON/MariaDBBox/ScintillaControl/SQLite3 equivalents) ship
# despite being source code - see the script header comment for why.
$controlsSrc = Join-Path $RepoRoot "Controls"
$controlsDst = Join-Path $ReleaseRoot "Controls"
Copy-Item -Path $controlsSrc -Destination $controlsDst -Recurse -Force
Write-Host "Copied directory: Controls (incl. framework .bas - see header comment)"

$removedExampleDirs = Get-ChildItem -Path $controlsDst -Recurse -Directory -Filter "examples"
foreach ($dir in $removedExampleDirs) {
    Remove-Item -Path $dir.FullName -Recurse -Force
}
if ($removedExampleDirs.Count -gt 0) {
    Write-Host ("Removed {0} vendored 'examples' subfolder(s) under Controls/" -f $removedExampleDirs.Count)
}

# --- Settings/: wholesale, minus the developer's personal ini and trace logs ---
# astoria.ini is skipped so the shipped app generates fresh defaults on first
# run (SettingsService.bas already handles every key being absent) rather than
# shipping this machine's MRU projects, window layout, and other personal state.
$settingsSrc = Join-Path $RepoRoot "Settings"
$settingsDst = Join-Path $ReleaseRoot "Settings"
Copy-Item -Path $settingsSrc -Destination $settingsDst -Recurse -Force
Remove-Item -Path (Join-Path $settingsDst "astoria.ini") -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $settingsDst -Filter "debug_trace*.log" -File | ForEach-Object {
    Remove-Item -Path $_.FullName -Force
}
Write-Host "Copied directory: Settings (excl. astoria.ini and debug_trace.*.log)"

# --- Everything else at the repo root is intentionally NOT copied: ---
#   src/                              - the IDE's own source (satisfied by GitHub instead)
#   .git, .github, .gitattributes,
#   .gitignore, .claude, .agents,
#   .vscode, *.code-workspace         - VCS/dev-tooling metadata
#   Compile*.bat, BuildCommon.bat,
#   BuildCompareMff.ps1               - build scripts for compiling the IDE itself
#   AstoriaIDE.vfp                    - the IDE's own project file
#   PROJECT_STATUS.md, HISTORY.md,
#   ROADMAP.md, CHANGELOG.md,
#   DIRECT2D_REMOVAL.md,
#   EXAMPLES_BUILD_AUDIT.md, README.md - maintainer-facing docs
#   Projects/, Temp/, DebugInfo.bak   - local scratch/dev artifacts

Write-Host ""
Write-Host "Release staged successfully at $ReleaseRoot"
$fileCount = (Get-ChildItem -Path $ReleaseRoot -Recurse -File).Count
$sizeMB = (Get-ChildItem -Path $ReleaseRoot -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host ("Files: {0:N0}   Total size: {1:N0} MB" -f $fileCount, $sizeMB)
