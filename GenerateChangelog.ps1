<#
.SYNOPSIS
    Regenerates Documentation/DetailedChangelog.md from the commit history.

.DESCRIPTION
    DetailedChangelog.md has always described itself as generated from commit messages, but no
    generator existed and entries were appended by hand. Hand-appending drifts: it invented area
    names outside the documented vocabulary ("Controls", "Tools", "Other"), and it cannot get the
    file count right without running git anyway.

    This script is the missing tool. It rewrites everything from the "**Total:" line onward and
    leaves the prose preamble above it alone, so the explanatory text stays editable in the
    document where it belongs rather than being duplicated here.

    Merge commits are excluded -- that matches the existing file, which lists 406 of 409 commits
    (two merges, plus the regeneration commit itself).

    The changelog cannot list the commit that regenerates it: the entry would have to contain a
    hash that does not exist until after the entry is written, and amending to insert it changes
    that hash again. This is why the file says "Commits after the last one listed here are not yet
    folded in." Regenerate, then commit; the regeneration commit lands unlisted and is picked up by
    the next run.

.PARAMETER Check
    Verify only: exits 1 if the file is out of date, printing how many commits are missing.
    Nothing is written. Suitable for a pre-commit hook or CI.

.EXAMPLE
    .\GenerateChangelog.ps1
    Rewrite the changelog through HEAD.

.EXAMPLE
    .\GenerateChangelog.ps1 -Check
    Report whether the changelog is current without modifying it.
#>
[CmdletBinding()]
param(
    [string] $Repo   = $PSScriptRoot,
    [string] $Path   = 'Documentation/DetailedChangelog.md',
    [string] $To     = 'HEAD',
    [int]    $MaxSummary = 300,
    [switch] $Check
)

$ErrorActionPreference = 'Stop'
$script:MaxSummary = $MaxSummary

if (-not $Repo) { $Repo = (Get-Location).Path }
$file = Join-Path $Repo $Path
if (-not (Test-Path $file)) { throw "Changelog not found: $file" }

# The preamble is prose and is maintained in the document. We regenerate from this marker down.
$marker = '**Total:'

# --- area vocabulary -------------------------------------------------------------------------
# The documented set, from the "How to read an entry" paragraph:
#   IDE (src/), Framework/Controls (Controls/), Templates, Examples, Docs, Settings, Build/Tools.
# Anything unmatched is deliberately reported rather than silently bucketed, so a new top-level
# directory shows up as a warning instead of quietly becoming "Other".
function Get-Area {
    param([string] $p)
    switch -Regex ($p) {
        '^src/'                          { return 'IDE' }
        '^Controls/'                     { return 'Framework/Controls' }
        '^Templates/'                    { return 'Templates' }
        '^Examples/'                     { return 'Examples' }
        '^Settings/'                     { return 'Settings' }
        '^Documentation/'                { return 'Docs' }
        '^Projects/'                     { return 'Examples' }
        '^(Tools|Compiler|Debuggers|AddIns|Help|Resources|TestHarness|Temp)/' { return 'Build/Tools' }
        '^\.(github|vscode|cursor|claude|agents|opencode|kun)/'              { return 'Build/Tools' }
        '^[^/]+\.(bat|ps1|iss|py)$'      { return 'Build/Tools' }
        '^[^/]+\.(md|txt)$'              { return 'Docs' }
        '^[^/]+\.(exe|dll)$'             { return 'IDE' }
        '^[^/]+\.bas$'                   { return 'Examples' }
        '^\.git(ignore|attributes)$'     { return 'Build/Tools' }
        '^[^/]+\.(vfp|vfs|log|code-workspace)$' { return 'Build/Tools' }
        '^CHMVIEW$'                      { return 'Build/Tools' }
        default                          { return $null }
    }
}

# numstat renders renames as "a => b" or "dir/{a => b}/f". Resolve to the post-rename path so the
# area is attributed to where the file now lives.
function Resolve-NumstatPath {
    param([string] $p)
    if ($p -notmatch '=>') { return $p }
    if ($p -match '^(.*)\{(.*) => (.*)\}(.*)$') {
        return ($Matches[1] + $Matches[3] + $Matches[4]) -replace '//', '/'
    }
    return ($p -split ' => ')[-1].Trim()
}

# A commit body may carry trailers and a generated-by footer; neither belongs in a changelog entry.
# The established convention in this file is the body's FIRST SENTENCE -- not the first paragraph.
# Commit bodies here are long and explanatory; one sentence keeps an entry scannable, and the full
# reasoning is a `git show <hash>` away, which is what the preamble tells the reader to do.
function Get-Summary {
    param([string] $body)
    if (-not $body) { return '' }
    $lines = $body -split "`r?`n"
    $para = New-Object System.Collections.Generic.List[string]
    foreach ($l in $lines) {
        $t = $l.Trim()
        if ($t -eq '') { if ($para.Count -gt 0) { break } else { continue } }
        if ($t -match '^(Co-Authored-By|Signed-off-by|Refs|Fixes|Closes):') { continue }
        # The Claude Code footer, matched by its leading robot emoji (surrogate pair) or its text.
        if ($t.StartsWith([char]0xD83E + [char]0xDD16) -or $t -match '^Generated with') { continue }
        $para.Add($t)
    }
    $text = ($para -join ' ').Trim()
    if (-not $text) { return '' }
    $text = Get-FirstSentence $text

    # A first "sentence" can still run long when the body opens with a bullet list, which joins into
    # one unbroken line. Cap it at a word boundary; the preamble already tells the reader that
    # `git show <hash>` is where the full detail lives.
    if ($text.Length -gt $script:MaxSummary) {
        $cut = $text.Substring(0, $script:MaxSummary)
        $sp = $cut.LastIndexOf(' ')
        if ($sp -gt 0) { $cut = $cut.Substring(0, $sp) }
        $text = $cut.TrimEnd(',', ';', ':', '-', ' ') + '...'
    }
    return $text
}

# Sentence detection has to survive this repo's prose: version numbers, "etc.)", flag names full of
# dots, and parenthesised asides. A terminator counts only when followed by whitespace and then
# something that looks like a new sentence -- and not when it closes a known abbreviation.
function Get-FirstSentence {
    param([string] $text)
    $abbr = @('e.g','i.e','etc','vs','cf','al','approx','ca','Dr','Mr','Mrs','Ms','St','Inc','Ltd','No','Fig','Ver','v')
    $len = $text.Length
    for ($i = 0; $i -lt $len; $i++) {
        $ch = $text[$i]
        if ($ch -ne '.' -and $ch -ne '!' -and $ch -ne '?') { continue }
        if ($i -eq $len - 1) { return $text }

        # Must be followed by whitespace to end a sentence: "3.7" and "etc.)" are not ends.
        if (-not [char]::IsWhiteSpace($text[$i + 1])) { continue }

        $j = $i + 1
        while ($j -lt $len -and [char]::IsWhiteSpace($text[$j])) { $j++ }
        if ($j -ge $len) { return $text.Substring(0, $i + 1) }

        # A new sentence starts with a capital, a digit, or markdown emphasis/code punctuation.
        $nxt = $text[$j]
        if (-not ([char]::IsUpper($nxt) -or [char]::IsDigit($nxt) -or $nxt -eq '`' -or $nxt -eq '*' -or $nxt -eq '"')) { continue }

        # Not an end if the token before the period is a known abbreviation.
        $k = $i - 1
        while ($k -ge 0 -and ($text[$k] -match '[\w.]')) { $k-- }
        $word = $text.Substring($k + 1, $i - $k - 1)
        if ($abbr -contains $word) { continue }

        return $text.Substring(0, $i + 1)
    }
    return $text
}

# --- read history ----------------------------------------------------------------------------
$RS = [char]30   # record separator
$US = [char]31   # unit separator

Push-Location $Repo
try {
    $fmt = "%x1e%h%x1f%ad%x1f%s%x1f%b%x1f"
    $raw = & git log --no-merges --reverse --date=short --numstat --format=$fmt $To
    if ($LASTEXITCODE -ne 0) { throw "git log failed with exit code $LASTEXITCODE" }
} finally {
    Pop-Location
}

$text = $raw -join "`n"
$records = $text -split $RS | Where-Object { $_.Trim() -ne '' }

$unmapped = New-Object System.Collections.Generic.HashSet[string]
$commits = @()

foreach ($rec in $records) {
    $parts = $rec -split $US
    if ($parts.Count -lt 4) { continue }

    $hash    = $parts[0].Trim()
    $date    = $parts[1].Trim()
    $subject = $parts[2].Trim()
    $body    = $parts[3]
    $stat    = ''
    if ($parts.Count -ge 5) { $stat = $parts[4] }

    $areas = New-Object System.Collections.Generic.HashSet[string]
    $count = 0
    foreach ($line in ($stat -split "`r?`n")) {
        $t = $line.Trim()
        if ($t -eq '') { continue }
        $cols = $t -split "`t"
        if ($cols.Count -lt 3) { continue }
        $count++
        $p = Resolve-NumstatPath $cols[2]
        $a = Get-Area $p
        if ($a) { [void]$areas.Add($a) } else { [void]$unmapped.Add($p) }
    }

    $commits += [pscustomobject]@{
        Hash    = $hash
        Date    = $date
        Subject = $subject
        Summary = Get-Summary $body
        Areas   = ($areas | Sort-Object)
        Files   = $count
    }
}

if ($commits.Count -eq 0) { throw 'No commits parsed -- refusing to write an empty changelog.' }

# --- render ------------------------------------------------------------------------------------
$sb = New-Object System.Text.StringBuilder
$first = $commits[0].Date
$last  = $commits[-1].Date
[void]$sb.Append("**Total: $($commits.Count) commits, $first to $last.**`n")

$currentDate = ''
foreach ($c in $commits) {
    if ($c.Date -ne $currentDate) {
        $currentDate = $c.Date
        [void]$sb.Append("`n## $currentDate`n`n")
    }
    [void]$sb.Append("- **``$($c.Hash)``** $([char]0x2014) $($c.Subject)`n")
    if ($c.Summary) { [void]$sb.Append("  $($c.Summary)`n") }
    if ($c.Files -gt 0) {
        $noun = 'files'
        if ($c.Files -eq 1) { $noun = 'file' }
        $areaText = ($c.Areas -join ', ')
        [void]$sb.Append("  *$areaText $([char]0x00B7) $($c.Files) $noun*`n")
    }
}

$existing = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
$idx = $existing.IndexOf($marker)
if ($idx -lt 0) { throw "Marker '$marker' not found in $Path -- cannot locate the generated region." }
$preamble = $existing.Substring(0, $idx)

# The preamble is carried over verbatim from disk, where core.autocrlf may have checked it out as
# CRLF, while the generated body is built with LF. Emitting that unchanged yields a mixed-ending
# file. Normalise the whole document to LF and let git render the working copy per .gitattributes /
# autocrlf -- one convention per file, decided in one place.
$output = ($preamble + $sb.ToString()) -replace "`r`n", "`n"

# --- write or check ------------------------------------------------------------------------------
if ($Check) {
    $normExisting = $existing -replace "`r`n", "`n"
    $normOutput   = $output   -replace "`r`n", "`n"
    if ($normExisting -eq $normOutput) {
        Write-Host "Changelog is current ($($commits.Count) commits)."
        exit 0
    }
    $listed = ([regex]::Matches($existing, '(?m)^- \*\*`')).Count
    Write-Host "Changelog is OUT OF DATE: $listed entries listed, $($commits.Count) non-merge commits in history."
    Write-Host "Run .\GenerateChangelog.ps1 to regenerate."
    exit 1
}

if ($unmapped.Count -gt 0) {
    Write-Warning "$($unmapped.Count) path(s) matched no area and were omitted from area lists. First few:"
    $unmapped | Select-Object -First 5 | ForEach-Object { Write-Warning "  $_" }
    Write-Warning "Add a rule to Get-Area in $($MyInvocation.MyCommand.Name) if these should be attributed."
}

# BOM-less UTF-8 with LF, matching the file as it stands. Astoria's house policy is to never write
# a BOM (see CLAUDE.md), and Set-Content -Encoding utf8 on PowerShell 5.1 would add one.
$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($file, $output, $enc)

Write-Host "Wrote $Path : $($commits.Count) commits, $first to $last."
Write-Host "Note: the commit that records this regeneration will not be listed until the next run."
