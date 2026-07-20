# What window actually has the focus in astoria.exe, and what is its class?
#
# The framework log said system keys arrive at "SuperWndProc[TabControl]" -- that is MFF's OWN
# class name for the object, not the Win32 window class. If the underlying class is
# SysTabControl32 then comctl32 really is handling the message and the tab-label theory is
# testable; if it is something else, the theory is built on a misreading.

$sig = @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class Focus {
    [StructLayout(LayoutKind.Sequential)]
    public struct GUITHREADINFO {
        public int cbSize; public int flags;
        public IntPtr hwndActive, hwndFocus, hwndCapture,
                      hwndMenuOwner, hwndMoveSize, hwndCaret;
        public int left, top, right, bottom;
    }
    [DllImport("user32.dll")] public static extern bool GetGUIThreadInfo(int idThread, ref GUITHREADINFO gti);
    [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h, out int pid);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll")] public static extern IntPtr GetParent(IntPtr h);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern IntPtr SendMessageW(IntPtr h, uint msg, IntPtr wp, IntPtr lp);

    public static string Cls(IntPtr h) { var sb = new StringBuilder(256); GetClassNameW(h, sb, 256); return sb.ToString(); }
    public static string Txt(IntPtr h) { var sb = new StringBuilder(512); GetWindowTextW(h, sb, 512); return sb.ToString(); }

    public static IntPtr FocusHwnd(int tid) {
        var g = new GUITHREADINFO(); g.cbSize = Marshal.SizeOf(typeof(GUITHREADINFO));
        if (!GetGUIThreadInfo(tid, ref g)) return IntPtr.Zero;
        return g.hwndFocus;
    }
    // TCM_GETITEMCOUNT = 0x1304
    public static int TabCount(IntPtr h) { return SendMessageW(h, 0x1304, IntPtr.Zero, IntPtr.Zero).ToInt32(); }
}
'@
Add-Type -TypeDefinition $sig -Language CSharp

$p = Get-Process astoria -ErrorAction SilentlyContinue |
     Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { Write-Host "astoria.exe not running."; exit 1 }

[void][Focus]::SetForegroundWindow($p.MainWindowHandle)
Start-Sleep -Milliseconds 600

$tid = [Focus]::GetWindowThreadProcessId($p.MainWindowHandle, [ref]$null)
$h = [Focus]::FocusHwnd($tid)
if ($h -eq [IntPtr]::Zero) { Write-Host "No focus window reported."; exit 1 }

Write-Host "Focus chain (focused window first, up to the main window):`n"
$cur = $h
$depth = 0
while ($cur -ne [IntPtr]::Zero -and $depth -lt 12) {
    $cls = [Focus]::Cls($cur)
    $txt = [Focus]::Txt($cur)
    $extra = ""
    if ($cls -eq "SysTabControl32") { $extra = "  <-- comctl32 tab control, tabs=" + [Focus]::TabCount($cur) }
    Write-Host ("  {0}0x{1:X}  class='{2}'  text='{3}'{4}" -f ("  " * $depth), $cur.ToInt64(), $cls, $txt, $extra)
    $cur = [Focus]::GetParent($cur)
    $depth++
}
