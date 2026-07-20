# Drives the WinForms control app with the same Alt+<letter> probe used on Astoria,
# plus a WH_KEYBOARD_LL hook that records what the input stack actually saw. The hook
# answers "were the keystrokes generated at all", which is the one thing the menu-state
# reading cannot tell us when the answer is "nothing happened".

$sig = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class Ctl {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h, out int pid);

    [StructLayout(LayoutKind.Sequential)]
    public struct GUITHREADINFO {
        public int cbSize; public int flags;
        public IntPtr hwndActive, hwndFocus, hwndCapture,
                      hwndMenuOwner, hwndMoveSize, hwndCaret;
        public int left, top, right, bottom;
    }
    [DllImport("user32.dll")] public static extern bool GetGUIThreadInfo(int idThread, ref GUITHREADINFO gti);

    [StructLayout(LayoutKind.Explicit, Size = 40)]
    public struct INPUT {
        [FieldOffset(0)]  public int type;
        [FieldOffset(8)]  public short wVk;
        [FieldOffset(12)] public int dwFlags;
    }
    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint SendInput(uint n, INPUT[] p, int cb);

    static INPUT K(short vk, bool up) {
        var i = new INPUT(); i.type = 1; i.wVk = vk; i.dwFlags = up ? 2 : 0; return i;
    }
    public static uint SendAlt(char letter) {
        short VK_MENU = 0x12; short vk = (short)Char.ToUpper(letter);
        var s = new INPUT[] { K(VK_MENU,false), K(vk,false), K(vk,true), K(VK_MENU,true) };
        return SendInput((uint)s.Length, s, Marshal.SizeOf(typeof(INPUT)));
    }
    public static uint Tap(short vk) {
        var s = new INPUT[] { K(vk,false), K(vk,true) };
        return SendInput((uint)s.Length, s, Marshal.SizeOf(typeof(INPUT)));
    }
    public static string State(int tid) {
        var g = new GUITHREADINFO(); g.cbSize = Marshal.SizeOf(typeof(GUITHREADINFO));
        if (!GetGUIThreadInfo(tid, ref g)) return "gti failed";
        return "inMenuMode=" + ((g.flags & 0x4) != 0);
    }
    public static int FgPid() { int p; GetWindowThreadProcessId(GetForegroundWindow(), out p); return p; }

    // ---- WH_KEYBOARD_LL ----
    public delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint tid);
    [DllImport("user32.dll")] public static extern bool UnhookWindowsHookEx(IntPtr hhk);
    [DllImport("user32.dll")] public static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);
    [DllImport("kernel32.dll")] public static extern IntPtr GetModuleHandle(string name);

    [StructLayout(LayoutKind.Sequential)]
    public struct KBDLLHOOKSTRUCT { public int vkCode, scanCode, flags, time; public IntPtr dwExtraInfo; }

    public static List<string> Seen = new List<string>();
    static IntPtr hHook = IntPtr.Zero;
    static HookProc keep;   // must be kept alive or the GC collects the callback

    static IntPtr Proc(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0) {
            var k = (KBDLLHOOKSTRUCT)Marshal.PtrToStructure(lParam, typeof(KBDLLHOOKSTRUCT));
            int msg = wParam.ToInt32();
            bool down = (msg == 0x0100 || msg == 0x0104);   // WM_KEYDOWN / WM_SYSKEYDOWN
            bool injected = (k.flags & 0x10) != 0;
            if (down) Seen.Add("vk=0x" + k.vkCode.ToString("X2") +
                               (injected ? " (injected)" : " (REAL)"));
        }
        return CallNextHookEx(hHook, nCode, wParam, lParam);
    }
    public static bool Install() {
        keep = new HookProc(Proc);
        hHook = SetWindowsHookEx(13, keep, GetModuleHandle(null), 0);
        return hHook != IntPtr.Zero;
    }
    public static void Remove() { if (hHook != IntPtr.Zero) UnhookWindowsHookEx(hHook); }
    public static void Clear() { Seen.Clear(); }
}
'@
Add-Type -TypeDefinition $sig -Language CSharp

$target = $args[0]   # "control" or "astoria"

if ($target -eq "astoria") {
    $p = Get-Process astoria -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    $what = "Astoria"
} elseif ($target -eq "mff") {
    $p = Get-Process MffMnemonicTest -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    $what = "minimal MFF app"
} else {
    $p = Get-Process powershell -ErrorAction SilentlyContinue |
         Where-Object { $_.MainWindowTitle -eq "AstoriaMnemonicControl" } | Select-Object -First 1
    $what = "WinForms control app"
}
if (-not $p) { Write-Host "Target not found ($target)."; exit 1 }

$hwnd = $p.MainWindowHandle
$tid  = [Ctl]::GetWindowThreadProcessId($hwnd, [ref]$null)

if (-not [Ctl]::Install()) { Write-Host "Could not install keyboard hook."; exit 1 }
Write-Host "Target: $what (pid $($p.Id))`n"

foreach ($ch in 'F','C','R','G','T') {
    [Ctl]::Tap(0x1B) | Out-Null; Start-Sleep -Milliseconds 200
    [void][Ctl]::SetForegroundWindow($hwnd); Start-Sleep -Milliseconds 500
    if ([Ctl]::FgPid() -ne $p.Id) { Write-Host "  Alt+$ch : SKIPPED (no foreground)"; continue }

    [Ctl]::Clear()
    $sent = [Ctl]::SendAlt($ch)
    Start-Sleep -Milliseconds 500
    # Pump, so the hook callback actually runs in this thread.
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 200

    $state = [Ctl]::State($tid)
    $hookSaw = ([Ctl]::Seen) -join ', '
    $verdict = if ($state -match 'inMenuMode=True') { "MENU OPENED " } else { "no menu     " }
    Write-Host ("  Alt+{0}: {1} sent={2} hook saw [{3}]" -f $ch, $verdict, $sent, $hookSaw)
    [Ctl]::Tap(0x1B) | Out-Null; Start-Sleep -Milliseconds 200
}

[Ctl]::Remove()
Write-Host "`nDone."
