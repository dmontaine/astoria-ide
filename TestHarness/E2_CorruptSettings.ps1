$ErrorActionPreference = "Stop"

$repo = Split-Path $PSScriptRoot -Parent
$settings = Join-Path $repo "Settings\astoria.ini"
$defaults = Join-Path $repo "Settings\astoria.default.ini"
$backup = Join-Path $env:TEMP ("astoria-e2-" + [guid]::NewGuid().ToString("N") + ".ini")
$exe = Join-Path $repo "astoria.exe"
$hadSettings = Test-Path -LiteralPath $settings
if ($hadSettings) { Copy-Item -LiteralPath $settings -Destination $backup }

function Send-Pipe([string]$json) {
    $c = New-Object System.IO.Pipes.NamedPipeClientStream('.','AstoriaAgent',[System.IO.Pipes.PipeDirection]::InOut)
    $c.Connect(500); $c.ReadMode = [System.IO.Pipes.PipeTransmissionMode]::Byte
    $w = New-Object System.IO.StreamWriter($c,(New-Object System.Text.UTF8Encoding($false))); $w.AutoFlush = $true
    $r = New-Object System.IO.StreamReader($c,(New-Object System.Text.UTF8Encoding($false)))
    $w.WriteLine($json); $line = $r.ReadLine(); $c.Dispose(); return $line
}

function Restore-Settings {
    if ($hadSettings) { Copy-Item -LiteralPath $backup -Destination $settings -Force }
    elseif (Test-Path -LiteralPath $settings) { Remove-Item -LiteralPath $settings -Force }
}

function Run-Case([string]$name, [string]$content) {
    Restore-Settings
    [System.IO.File]::WriteAllText($settings, $content, (New-Object System.Text.UTF8Encoding($false)))
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $p = Start-Process -FilePath $exe -WorkingDirectory $repo -PassThru
    $reply = $null
    for ($i=0; $i -lt 40 -and -not $reply; $i++) {
        Start-Sleep -Milliseconds 250
        try { $reply = Send-Pipe '{"id":1,"cmd":"ping"}' } catch { }
    }
    $sw.Stop()
    $alive = -not $p.HasExited
    $responding = $alive -and $p.Responding
    $ping = $reply -match '"ok":true'
    if ($alive) { $null = $p.CloseMainWindow(); if (-not $p.WaitForExit(10000)) { Stop-Process -Id $p.Id -Force } }
    $text = [System.IO.File]::ReadAllText($settings)
    $coreSections = @('MakeTools','BuildConfigurations','Helps','IncludePaths','LibraryPaths','Terminals')
    $missing = @($coreSections | Where-Object { $text -notmatch ('(?m)^\[' + [regex]::Escape($_) + '\]') })
    [pscustomobject]@{ Case=$name; Started=$alive; Responding=$responding; AgentPing=$ping; StartupMs=$sw.ElapsedMilliseconds; CoreSectionsRestored=($missing.Count -eq 0); Missing=($missing -join ',') }
}

try {
    $defaultText = [System.IO.File]::ReadAllText($defaults)
    $cases = @(
        @{ Name='truncated'; Content="[Options]`r`nAllowAgentControl=true`r`n" },
        @{ Name='garbage'; Content="this is not an ini file`r`n%%% broken [] ==`r`n[Options]`r`nAllowAgentControl=true`r`n" },
        @{ Name='missing section'; Content=($defaultText -replace '(?ms)^\[Terminals\].*?(?=^\[|\z)', '') }
    )
    $results = @($cases | ForEach-Object { Run-Case $_.Name $_.Content })
    $results | Format-Table -AutoSize
    $passed = @($results | Where-Object { $_.Started -and $_.Responding -and $_.AgentPing -and $_.CoreSectionsRestored }).Count
    "E2 RESULT: $passed/$($results.Count)"
    if ($passed -ne $results.Count) { exit 1 }
}
finally {
    Get-Process astoria -ErrorAction SilentlyContinue | ForEach-Object { if (-not $_.HasExited) { $_.CloseMainWindow() | Out-Null; $_.WaitForExit(5000) | Out-Null } }
    Restore-Settings
    if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Force }
}
