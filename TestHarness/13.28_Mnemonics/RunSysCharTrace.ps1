# ROADMAP 13.28 part 3 - drives the Phase 1 cdb trace.
#
# Launches astoria.exe under cdb with non-stopping logging breakpoints, then
# sends a WORKING mnemonic and a CURSED one and compares what Windows did.
#
# The comparison is the experiment. A single letter proves nothing here: the
# question is not "does Alt+C do nothing" (established) but "does Alt+C reach
# the same code Alt+E reaches". Alt+E is the control and MUST produce a bell;
# if it does not, the trace is broken and Alt+C's silence means nothing.

param(
    [string[]] $Letters = @('E','C','G','R','F'),
    [int]      $SettleMs = 1500
)

$root    = "C:\Users\don\Astoria-IDE"
$cdb     = "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\cdb.exe"
$script  = Join-Path $root "TestHarness\13.28_Mnemonics\SysCharTrace.cdb"
$log     = Join-Path $env:TEMP "_astoria_syschar_trace.log"

if (-not (Test-Path $cdb))    { Write-Host "cdb.exe not found at $cdb"; exit 1 }
if (-not (Test-Path $script)) { Write-Host "trace script not found at $script"; exit 1 }

$env:_NT_SYMBOL_PATH = "srv*C:\Symbols*https://msdl.microsoft.com/download/symbols"

# ---------------------------------------------------------------- key sending
# INPUT is 40 bytes on x64 and KEYBDINPUT starts at offset 8. Getting this
# wrong makes SendInput return 0 and send nothing at all, which reads exactly
# like a dead shortcut. This cost the earlier harnesses a full false result set.
$sig = @'
using System;
using System.Runtime.InteropServices;
public static class TraceKeys {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h, out int pid);

    [StructLayout(LayoutKind.Explicit, Size = 40)]
    public struct INPUT {
        [FieldOffset(0)]  public int type;
        [FieldOffset(8)]  public short wVk;
        [FieldOffset(10)] public short wScan;
        [FieldOffset(12)] public int dwFlags;
        [FieldOffset(16)] public int time;
        [FieldOffset(24)] public IntPtr dwExtraInfo;
    }
    [DllImport("user32.dll")] public static extern uint SendInput(uint n, INPUT[] p, int cb);
    const int KEYEVENTF_KEYUP = 0x0002;
    static INPUT Key(short vk, bool up) {
        var i = new INPUT(); i.type = 1; i.wVk = vk;
        i.dwFlags = up ? KEYEVENTF_KEYUP : 0; return i;
    }
    // Returns how many events SendInput actually accepted - never assume it sent them.
    public static uint SendAlt(char letter) {
        short VK_MENU = 0x12; short vk = (short)Char.ToUpper(letter);
        var seq = new INPUT[] { Key(VK_MENU,false), Key(vk,false), Key(vk,true), Key(VK_MENU,true) };
        return SendInput((uint)seq.Length, seq, Marshal.SizeOf(typeof(INPUT)));
    }
    public static uint SendEscape() {
        short VK_ESCAPE = 0x1B;
        var seq = new INPUT[] { Key(VK_ESCAPE,false), Key(VK_ESCAPE,true) };
        return SendInput((uint)seq.Length, seq, Marshal.SizeOf(typeof(INPUT)));
    }
    public static int ForegroundPid() {
        int pid; GetWindowThreadProcessId(GetForegroundWindow(), out pid); return pid;
    }
}
'@
Add-Type -TypeDefinition $sig -Language CSharp

# ------------------------------------------------------------------- clean up
Get-Process astoria -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Closing existing astoria.exe (pid $($_.Id))"
    $_.CloseMainWindow() | Out-Null; Start-Sleep -Milliseconds 800
    if (-not $_.HasExited) { $_.Kill() }
}
Remove-Item $log -ErrorAction SilentlyContinue

# --------------------------------------------------------------- launch under cdb
Write-Host "Launching astoria.exe under cdb (symbols may take a moment on first run)..."
$cdbArgs = @('-logo', "`"$log`"", '-cf', "`"$script`"", "`"$root\astoria.exe`"")
$dbg = Start-Process -FilePath $cdb -ArgumentList $cdbArgs -WorkingDirectory $root `
                     -PassThru -WindowStyle Minimized

# Wait for Astoria's window. Under a debugger with symbol loading this is slower
# than a bare launch, so allow generously before calling it a failure.
$p = $null
for ($i = 0; $i -lt 90; $i++) {
    Start-Sleep -Seconds 1
    $p = Get-Process astoria -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($p) { break }
    if ($dbg.HasExited) { Write-Host "cdb exited early (code $($dbg.ExitCode)). See $log"; exit 1 }
}
if (-not $p) { Write-Host "Astoria never presented a window. See $log"; exit 1 }
Write-Host "Astoria up: pid $($p.Id), hwnd 0x$($p.MainWindowHandle.ToString('X'))"
Start-Sleep -Seconds 3   # let startup settle so its own beeps/menus do not pollute the log

# ------------------------------------------------------------------- the sweep
foreach ($ch in $Letters) {
    [void][TraceKeys]::SendEscape(); Start-Sleep -Milliseconds 300
    [void][TraceKeys]::SetForegroundWindow($p.MainWindowHandle)
    Start-Sleep -Milliseconds 700

    # Guard: never synthesize input unless Astoria owns the foreground, or the
    # keystroke lands in whatever window Windows handed it to instead.
    if ([TraceKeys]::ForegroundPid() -ne $p.Id) {
        Write-Host ("Alt+{0}: SKIPPED - Astoria does not own the foreground" -f $ch)
        continue
    }

    "=== MARK Alt+$ch ===" | Out-File -FilePath "$log.marks" -Append -Encoding utf8
    Write-Host ("--- sending Alt+{0} ---" -f $ch)
    $sent = [TraceKeys]::SendAlt($ch)
    if ($sent -ne 4) { Write-Host ("  WARNING: SendInput accepted {0}/4 events" -f $sent) }
    Start-Sleep -Milliseconds $SettleMs
    [void][TraceKeys]::SendEscape(); Start-Sleep -Milliseconds 400
}

# ------------------------------------------------------------------- teardown
Write-Host "`nSweep complete. Closing target..."
$alive = -not $p.HasExited
Write-Host ("Astoria still alive at end of sweep: {0}" -f $alive)   # an abort looks like a clean run
if ($alive) { $p.CloseMainWindow() | Out-Null; Start-Sleep -Seconds 2 }
Get-Process astoria -ErrorAction SilentlyContinue | ForEach-Object { if (-not $_.HasExited) { $_.Kill() } }
Start-Sleep -Milliseconds 500
if (-not $dbg.HasExited) { $dbg.Kill() }

Write-Host "`nTrace log: $log"
