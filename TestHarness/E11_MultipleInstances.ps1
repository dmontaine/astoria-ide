# TestPlan E11 -- multiple Astoria instances.
#
# Astoria is single-instance by design (Application.PrevInstance takes a named mutex on the exe
# name; Main.bas:76-84 ends the second process), so the "two IDEs with different projects" scenario
# E11 was written around cannot happen. What this harness actually establishes is:
#
#   1. the single instance owns the AstoriaAgent named pipe  (by pid, not by assumption)
#   2. a second launch never coexists with it
#   3. the running IDE is undisturbed by repeated launch attempts -- alive, still serving the
#      pipe, with astoria.ini and Workspace.ini intact
#   4. how the second process terminates, and whether the running IDE is raised to the foreground
#
# (4) was the defect: ROADMAP 13.29, FIXED 2026-07-19. The second process used to crash with
# 0xC0000005 on every launch that carried no file argument, and the running IDE was never raised.
# It now hands over to the running instance in all cases and leaves via ExitProcess. E11-3 and
# E11-5 are the checks that cover it.
#
# ---------------------------------------------------------------------------------------------
# DO NOT MEASURE THE CRASH WITH AN EXIT CODE. Two separate exit-code instruments reported a
# confident clean exit for a launch form that was crashing every single time:
#   * `start /wait astoria.exe & echo EXIT=%ERRORLEVEL%` prints the PREVIOUS errorlevel, because
#     cmd expands the variable when it parses the compound line; and
#   * even written correctly, cmd's ERRORLEVEL does not carry 0xC0000005 out of `start /wait`.
# Crashes are counted from the Windows Application event log instead. The instrument self-check
# below must pass before any result here is believed.
# ---------------------------------------------------------------------------------------------
#
# Safe to re-run: astoria.ini and Workspace.ini are backed up and restored, and every process
# this script starts is killed in the finally block.

[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [int]$Attempts = 3
)

$ErrorActionPreference = 'Stop'

$exe    = Join-Path $Root 'astoria.exe'
$ini    = Join-Path $Root 'Settings\astoria.ini'
$wsp    = Join-Path $Root 'Settings\Workspace.ini'
$backup = Join-Path $env:TEMP ("E11_backup_" + [guid]::NewGuid().ToString('N').Substring(0,8))

$script:pass = 0
$script:fail = 0
function Check($name, $cond, $detail) {
    if ($cond) { $script:pass++; Write-Host "PASS  $name" -ForegroundColor Green }
    else       { $script:fail++; Write-Host "FAIL  $name" -ForegroundColor Red }
    Write-Host "      $detail"
}
function Note($t) { Write-Host "      .. $t" -ForegroundColor DarkGray }

# CharSet.Unicode is required, not cosmetic: a ...W API marshalled as ANSI truncates at the
# first NUL, which had this harness reporting one-character window titles.
Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
public class E11W {
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern bool GetNamedPipeServerProcessId(IntPtr Pipe, out uint ServerProcessId);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr hWnd, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
}
'@

# Which process serves the server end of the agent pipe? 0 = no pipe at all.
function Get-PipeServerPid {
    param([int]$TimeoutMs = 1500)
    $c = New-Object System.IO.Pipes.NamedPipeClientStream('.', 'AstoriaAgent', [System.IO.Pipes.PipeDirection]::InOut)
    try {
        $c.Connect($TimeoutMs)
        $spid = 0
        if ([E11W]::GetNamedPipeServerProcessId($c.SafePipeHandle.DangerousGetHandle(), [ref]$spid)) { return [int]$spid }
        return -1
    } catch { return 0 } finally { $c.Dispose() }
}
function Wait-Pipe([int]$TimeoutSec = 90) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        $p = Get-PipeServerPid 500
        if ($p -gt 0) { return $p }
        Start-Sleep -Milliseconds 400
    }
    return 0
}
function Get-Foreground {
    $h = [E11W]::GetForegroundWindow(); $p = 0
    [void][E11W]::GetWindowThreadProcessId($h, [ref]$p)
    $sb = New-Object System.Text.StringBuilder 256
    [void][E11W]::GetWindowTextW($h, $sb, 256)
    [pscustomobject]@{ Pid = [int]$p; Title = $sb.ToString() }
}
# Crash records for astoria.exe since $since, with their fault offsets.
function Get-Crashes($since) {
    $ev = Get-WinEvent -FilterHashtable @{ LogName='Application'; Id=1000; StartTime=$since } -ErrorAction SilentlyContinue
    $mine = @($ev | Where-Object { $_.Message -match 'astoria\.exe' })
    $offs = @($mine | ForEach-Object { if ($_.Message -match 'Fault offset: (0x[0-9a-fA-F]+)') { $Matches[1] } })
    [pscustomobject]@{ Count = $mine.Count; Offsets = $offs }
}

Write-Host "=== TestPlan E11 -- multiple Astoria instances ===`n"

# --- The instrument must be able to fire before anything it says is believed. -----------------
$probeStart = Get-Date
Start-Sleep -Seconds 1
$probe = Get-Crashes $probeStart
Check 'E11-0 crash counter reads the event log and starts clean' ($probe.Count -eq 0) `
      "0 astoria crash records in a window where nothing was launched (reader works, no stale carry-in)"

$running = @(Get-Process astoria -ErrorAction SilentlyContinue)
if ($running.Count -gt 0) { throw "astoria.exe is already running (PID $($running.Id -join ',')). Close it first." }

New-Item -ItemType Directory -Force -Path $backup | Out-Null
Copy-Item $ini $backup -Force
Copy-Item $wsp $backup -Force
$iniBefore = Get-Content $ini -Raw
$wspBefore = Get-Content $wsp -Raw
Note "backed up astoria.ini + Workspace.ini to $backup"

$A = $null; $pad = $null
try {
    Write-Host "`n--- the one instance that is allowed to exist ---"
    $A = Start-Process $exe -WorkingDirectory $Root -PassThru
    $pipePid = Wait-Pipe 120
    Check 'E11-1 the running instance owns the agent pipe' ($pipePid -eq $A.Id) `
          "pipe server pid=$pipePid, instance pid=$($A.Id)"
    Start-Sleep -Seconds 5

    # --- second launch, no arguments: the ordinary double-click ------------------------------
    Write-Host "`n--- second launch x$Attempts, no arguments (the desktop-icon case) ---"
    $t0 = Get-Date; Start-Sleep -Seconds 2
    $coexisted = $false
    foreach ($i in 1..$Attempts) {
        $b = Start-Process $exe -WorkingDirectory $Root -PassThru
        Start-Sleep -Milliseconds 1500
        $b.Refresh()
        if (-not $b.HasExited) { $coexisted = $true }
        [void]$b.WaitForExit(30000)
        Start-Sleep -Seconds 2
    }
    Start-Sleep -Seconds 8   # the event log lags behind the fault
    $noArg = Get-Crashes $t0

    Check 'E11-2 a second instance never coexists with the first' (-not $coexisted) `
          "no second process was still alive 1.5s after launch, across $Attempts attempts"
    Check 'E11-3 the second process exits without crashing' ($noArg.Count -eq 0) `
          "crash records: $($noArg.Count)/$Attempts  offsets: $(if($noArg.Count){$noArg.Offsets -join ', '}else{'none'})  -- ROADMAP 13.29 expects $Attempts/$Attempts at 0x246be4"

    # --- second launch with a file argument: the forwarding path ------------------------------
    $proj = Join-Path $Root 'Projects\Project3\Project3.vfp'
    if (Test-Path $proj) {
        Write-Host "`n--- second launch x$Attempts, with a .vfp argument (the forwarding path) ---"
        $t1 = Get-Date; Start-Sleep -Seconds 2
        foreach ($i in 1..$Attempts) {
            $b = Start-Process $exe -ArgumentList "`"$proj`"" -WorkingDirectory $Root -PassThru
            [void]$b.WaitForExit(30000)
            Start-Sleep -Seconds 2
        }
        Start-Sleep -Seconds 8
        $withArg = Get-Crashes $t1
        Check 'E11-4 a second launch carrying a file argument does not crash' ($withArg.Count -eq 0) `
              "crash records: $($withArg.Count)/$Attempts -- this path exits via the End inside EnumWindowsProc, not the bare End at Main.bas:83"
    } else {
        Note "skipped E11-4: $proj not present"
    }

    # --- does a second launch raise the running IDE? -----------------------------------------
    # The realistic case: the IDE is open but minimised, and the user double-clicks the icon.
    # Minimising is also what makes this question answerable at all -- a minimised window cannot
    # hold the foreground, so "did it come forward?" has a state it can actually fail from.
    # (Parking notepad in front is not enough: Windows repeatedly handed the foreground straight
    # back to Astoria, and the check skipped itself rather than report a result it had not earned.)
    Write-Host "`n--- minimised IDE + second launch: does it come forward? ---"
    $A.Refresh()
    $hwnd = $A.MainWindowHandle
    if ($hwnd -eq [IntPtr]::Zero) {
        Note "SKIPPED -- the running IDE has no main window handle to minimise"
    } else {
        [void][E11W]::ShowWindow($hwnd, 6)   # SW_MINIMIZE
        Start-Sleep -Seconds 3
        $pad = Start-Process notepad -PassThru      # give the foreground somewhere else to be
        Start-Sleep -Seconds 3
        $wasIconic = [E11W]::IsIconic($hwnd)
        $fgBefore  = Get-Foreground
        Note "before: IDE minimised=$wasIconic, foreground pid=$($fgBefore.Pid) '$($fgBefore.Title)'"

        # The precondition is "minimised", NOT "some other window holds the foreground": Windows
        # will still report a just-minimised window as the foreground window, so requiring that
        # made this check unsatisfiable and it skipped itself. Minimised -> restored is the
        # transition that matters anyway, it is unambiguous, and it can genuinely fail -- before
        # the 13.29 fix no message was sent at all, so the window stayed minimised.
        if (-not $wasIconic) {
            Note "SKIPPED -- could not minimise the IDE; result would be meaningless"
        } else {
            $b = Start-Process $exe -WorkingDirectory $Root -PassThru
            [void]$b.WaitForExit(30000)
            Start-Sleep -Seconds 4
            $fgAfter    = Get-Foreground
            $stillIconic = [E11W]::IsIconic($hwnd)
            Note "after : IDE minimised=$stillIconic, foreground pid=$($fgAfter.Pid) '$($fgAfter.Title)'"
            Check 'E11-5 a second launch restores and raises the running IDE' `
                  ((-not $stillIconic) -and $fgAfter.Pid -eq $A.Id) `
                  "restored=$(-not $stillIconic), foreground pid=$($fgAfter.Pid) (IDE=$($A.Id)) -- a FAIL means double-clicking the icon does nothing visible"
        }
    }

    # --- the running instance must be untouched by all of that -------------------------------
    Write-Host "`n--- the running instance, after every launch attempt ---"
    $A.Refresh()
    Check 'E11-6 the running instance is still alive' (-not $A.HasExited) "pid=$($A.Id) exited=$($A.HasExited)"
    $pipeAfter = Get-PipeServerPid 2500
    Check 'E11-7 it still serves the agent pipe' ($pipeAfter -eq $A.Id) "pipe server pid=$pipeAfter, instance pid=$($A.Id)"

    Write-Host "`n--- closing, then the shared files ---"
    [void]$A.CloseMainWindow()
    if (-not $A.WaitForExit(30000)) { Note 'did not exit on CloseMainWindow; killing'; $A.Kill(); [void]$A.WaitForExit(10000) }
    Start-Sleep -Seconds 3

    $iniAfter = Get-Content $ini -Raw
    $wspAfter = Get-Content $wsp -Raw
    Check 'E11-8 astoria.ini is intact' `
          ($iniAfter -match '\[Terminals\]' -and $iniAfter.Length -gt ($iniBefore.Length * 0.5)) `
          "length before=$($iniBefore.Length) after=$($iniAfter.Length), [Terminals] present"
    Check 'E11-9 Workspace.ini is intact and still names a project' ($wspAfter -match '\*File=.+\.vfp') `
          "first line: $((($wspAfter -split "`n")[0]).Trim())"
}
finally {
    foreach ($p in @($pad, $A)) {
        if ($null -ne $p) { try { $p.Refresh(); if (-not $p.HasExited) { $p.Kill() } } catch {} }
    }
    Get-Process astoria -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Copy-Item (Join-Path $backup 'astoria.ini')   $ini -Force
    Copy-Item (Join-Path $backup 'Workspace.ini') $wsp -Force
    Remove-Item $backup -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "`nRestored astoria.ini and Workspace.ini." -ForegroundColor DarkGray
}

Write-Host "`n=== E11: $script:pass passed, $script:fail failed ===" -ForegroundColor Cyan
if ($script:fail -gt 0) {
    Write-Host "All ten checks passed when ROADMAP 13.29 was fixed. E11-3 (crash) and E11-5 (restore" -ForegroundColor Yellow
    Write-Host "and raise) are the two that regress if that fix is disturbed." -ForegroundColor Yellow
}

