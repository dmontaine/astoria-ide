# ROADMAP 13.28 pt 3 bisection driver.
# For each ASTORIA_BISECT value, restart Astoria, run the menuprobe, and record whether the
# defect reproduces (Alt+C/G/R all "no menu" while Alt+F opens).
$ErrorActionPreference = 'Stop'
$sp = 'C:\Users\don\AppData\Local\Temp\claude\C--Users-don-Astoria-IDE\a801ea1d-b6dc-48c1-a0aa-a601aa6c8295\scratchpad'

$cases = @(
  '',                    # baseline, all pieces present
  'toolbars',
  'statusbar',
  'leftpanel',
  'rightpanel',
  'bottompanel',
  'toolbars,statusbar,leftpanel,rightpanel,bottompanel'   # all off
)

$grid = @()
foreach ($spec in $cases) {
  Get-Process astoria -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 3
  $env:ASTORIA_BISECT = $spec
  $label = if ($spec -eq '') { '(baseline)' } else { $spec }
  Write-Host ""
  Write-Host "=== case: $label ===" -ForegroundColor Cyan

  Start-Process 'C:\Users\don\Astoria-IDE\astoria.exe' -WorkingDirectory 'C:\Users\don\Astoria-IDE' | Out-Null
  Start-Sleep -Seconds 35
  $alive = @(Get-Process astoria -ErrorAction SilentlyContinue).Count
  if ($alive -eq 0) {
    Write-Host "  IDE did not survive startup with ASTORIA_BISECT=$spec" -ForegroundColor Red
    $grid += [pscustomobject]@{ Case=$label; Result='no-startup'; Detail='exited before probe' }
    continue
  }

  $out = & "$sp\menuprobe.ps1" 2>&1 | Out-String
  $out.Trim() -split "`n" | ForEach-Object { "    $_" }

  $reproduces = ($out -match 'defect reproduces under this probe')
  $notRepro   = ($out -match 'defect is NOT reproducing')
  $invalid    = ($out -match 'INSTRUMENT INVALID')
  $r = if ($invalid) { 'invalid' } elseif ($reproduces) { 'REPRODUCES' } elseif ($notRepro) { 'FIXED' } else { 'other' }
  $grid += [pscustomobject]@{ Case=$label; Result=$r; Detail=($out -split "`n" | Where-Object { $_ -match 'Alt\+[CGR]' }) -join ' ; ' }
}

Get-Process astoria -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
$env:ASTORIA_BISECT = ''
Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Yellow
$grid | Format-Table Case,Result -AutoSize
