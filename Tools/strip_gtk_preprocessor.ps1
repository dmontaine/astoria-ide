param(
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]]$Roots
)

$Defined = @{
    '__FB_WIN32__'  = $true
    '__FB_64BIT__'  = $true
    '__USE_GTK__'   = $false
    '__USE_GTK3__'  = $false
    '__FB_LINUX__'  = $false
    '__USE_WINAPI__'= $true
}

function Eval-Condition([string]$Expr) {
    $e = $Expr.Trim()
    if (-not $e) { return $false }
    $e = [regex]::Replace($e, 'defined\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)', {
        param($m)
        if ($Defined.ContainsKey($m.Groups[1].Value) -and $Defined[$m.Groups[1].Value]) { '$true' } else { '$false' }
    }, 'IgnoreCase')
    $e = $e -ireplace '\bAndAlso\b', ' -and '
    $e = $e -ireplace '\bOrElse\b', ' -or '
    $e = $e -ireplace '\bNot\b', ' -not '
    $e = $e -replace '&&', ' -and ' -replace '\|\|', ' -or '
    try { return [bool](Invoke-Expression $e) } catch { return $false }
}

function Strip-GtkText([string]$Text) {
    $lines = $Text -split "`r?`n", -1
    $out = New-Object System.Collections.Generic.List[string]
    $stack = New-Object System.Collections.Generic.List[object]

    function Get-Active {
        foreach ($f in $stack) { if (-not $f.branchActive) { return $false } }
        return $true
    }

    foreach ($raw in $lines) {
        $line = $raw -replace "`r$", ''
        if ($line -match '^\s*#(?<kind>ifdef|ifndef|if|elseif|else|endif)\b(?<rest>.*)$') {
            $kind = $Matches.kind.ToLower()
            $rest = $Matches.rest.Trim()
            switch ($kind) {
                'ifdef' {
                    $sym = ($rest -split '\s+')[0]
                    $cond = $Defined.ContainsKey($sym) -and $Defined[$sym]
                    $parent = Get-Active
                    $stack.Add([pscustomobject]@{ parentActive = $parent; branchActive = ($parent -and $cond); taken = $cond })
                }
                'ifndef' {
                    $sym = ($rest -split '\s+')[0]
                    $cond = -not ($Defined.ContainsKey($sym) -and $Defined[$sym])
                    $parent = Get-Active
                    $stack.Add([pscustomobject]@{ parentActive = $parent; branchActive = ($parent -and $cond); taken = $cond })
                }
                'if' {
                    $cond = Eval-Condition $rest
                    $parent = Get-Active
                    $stack.Add([pscustomobject]@{ parentActive = $parent; branchActive = ($parent -and $cond); taken = $cond })
                }
                'elseif' {
                    if ($stack.Count -eq 0) { if (Get-Active) { $out.Add($line) }; continue }
                    $frame = $stack[$stack.Count - 1]
                    if (-not $frame.parentActive) { $frame.branchActive = $false; $frame.taken = $true }
                    elseif ($frame.taken) { $frame.branchActive = $false }
                    else {
                        $cond = Eval-Condition $rest
                        $frame.branchActive = $cond
                        $frame.taken = $cond
                    }
                }
                'else' {
                    if ($stack.Count -eq 0) { if (Get-Active) { $out.Add($line) }; continue }
                    $frame = $stack[$stack.Count - 1]
                    if (-not $frame.parentActive) { $frame.branchActive = $false }
                    elseif ($frame.taken) { $frame.branchActive = $false }
                    else { $frame.branchActive = $true; $frame.taken = $true }
                }
                'endif' {
                    if ($stack.Count -gt 0) { $stack.RemoveAt($stack.Count - 1) }
                }
            }
        }
        elseif (Get-Active) {
            $out.Add($line)
        }
    }

    return ($out -join "`r`n") + $(if ($Text.EndsWith("`n") -or $Text.EndsWith("`r`n")) { "`r`n" } else { '' })
}

$exts = @('.bas', '.bi', '.frm')
$changed = 0
$scanned = 0
foreach ($root in $Roots) {
    Get-ChildItem -Path $root -Recurse -File | Where-Object { $exts -contains $_.Extension.ToLower() } | ForEach-Object {
        $scanned++
        $original = [IO.File]::ReadAllText($_.FullName)
        $updated = Strip-GtkText $original
        if ($updated -ne $original) {
            [IO.File]::WriteAllText($_.FullName, $updated)
            $changed++
            Write-Host "updated: $($_.FullName)"
        }
    }
}
Write-Host "Scanned $scanned files, updated $changed."
