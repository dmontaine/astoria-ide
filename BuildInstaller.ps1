<#
.SYNOPSIS
    One-command build of the Astoria-IDE installer.

.DESCRIPTION
    Combines StageRelease.ps1 (copies the current repo state - including
    whatever astoria.exe you last built - into the release tree) with the
    Inno Setup compiler. The two travel together: recompiling AstoriaIDE.iss
    alone would just repackage whatever was already in the staged release
    tree, not the IDE/source you just changed - see StageRelease.ps1's own
    header comment for why the release tree isn't a live view of the repo.

    Run this whenever you want to test the packaged installer experience.
    Day-to-day IDE development doesn't need it - keep using Compile.bat and
    running astoria.exe directly from the repo for that.
#>

$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot

Write-Host "=== Step 1/2: Staging release ===" -ForegroundColor Cyan
& (Join-Path $RepoRoot "StageRelease.ps1")

Write-Host ""
Write-Host "=== Step 2/2: Compiling installer ===" -ForegroundColor Cyan

$IsccCandidates = @(
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
)
$Iscc = $IsccCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $Iscc) {
    throw "ISCC.exe (Inno Setup compiler) not found in any expected location. Install Inno Setup 6 from https://jrsoftware.org/isdl.php"
}

& $Iscc (Join-Path $RepoRoot "AstoriaIDE.iss")
if ($LASTEXITCODE -ne 0) {
    throw "ISCC.exe exited with code $LASTEXITCODE"
}
