# Sends Alt+<letter> to the running astoria.exe and asks Windows, by effect,
# whether a menu actually dropped: GetGUIThreadInfo reports GUI_INMENUMODE and
# the hwndMenuOwner / popup handle. This does not trust "it looked like nothing
# happened" -- it reads the menu state out of the GUI thread.
#
# Guarded: refuses to send unless astoria.exe owns the foreground, so a stray
# run cannot type into whatever window Windows handed the foreground to.

$sig = @'
using System;
using System.Runtime.InteropServices;

public static class AltProbe {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr h, out int pid);
    [DllImport("user32.dll")] public static extern IntPtr GetMenu(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern int GetMenuItemCount(IntPtr hMenu);

    [StructLayout(LayoutKind.Sequential)]
    public struct GUITHREADINFO {
        public int cbSize; public int flags;
        public IntPtr hwndActive, hwndFocus, hwndCapture,
                      hwndMenuOwner, hwndMoveSize, hwndCaret;
        public int left, top, right, bottom;
    }
    [DllImport("user32.dll")] public static extern bool GetGUIThreadInfo(int idThread, ref GUITHREADINFO gti);

    // x64 INPUT is 40 bytes, not 32: the union is sized by MOUSEINPUT (32 bytes),
    // and 'type' is followed by 4 bytes of alignment padding, so KEYBDINPUT starts
    // at offset 8. Get either wrong and SendInput returns 0 with ERROR_INVALID_PARAMETER,
    // sending nothing at all -- which reads exactly like a dead shortcut.
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
        var i = new INPUT();
        i.type = 1; i.wVk = vk; i.dwFlags = up ? KEYEVENTF_KEYUP : 0;
        return i;
    }

    // Alt down, letter down, letter up, Alt up -- a real chord, as a hand makes it.
    public static void SendAlt(char letter) {
        short VK_MENU = 0x12;
        short vk = (short)Char.ToUpper(letter);
        var seq = new INPUT[] { Key(VK_MENU,false), Key(vk,false), Key(vk,true), Key(VK_MENU,true) };
        SendInput((uint)seq.Length, seq, Marshal.SizeOf(typeof(INPUT)));
    }

    // Bare Alt: enters menu mode on any Win32 menu bar. Used as the instrument check.
    public static void SendAltAlone() {
        short VK_MENU = 0x12;
        var seq = new INPUT[] { Key(VK_MENU,false), Key(VK_MENU,true) };
        SendInput((uint)seq.Length, seq, Marshal.SizeOf(typeof(INPUT)));
    }

    // Escape twice, to leave menu mode however deep we got.
    public static void SendEscape() {
        short VK_ESCAPE = 0x1B;
        var seq = new INPUT[] { Key(VK_ESCAPE,false), Key(VK_ESCAPE,true) };
        SendInput((uint)seq.Length, seq, Marshal.SizeOf(typeof(INPUT)));
    }

    public static string MenuState(int tid) {
        var g = new GUITHREADINFO();
        g.cbSize = Marshal.SizeOf(typeof(GUITHREADINFO));
        if (!GetGUIThreadInfo(tid, ref g)) return "gti failed";
        bool inMenu = (g.flags & 0x00000004) != 0;   // GUI_INMENUMODE
        bool popup  = (g.flags & 0x00000010) != 0;   // GUI_POPUPMENUMODE
        return string.Format("inMenuMode={0} popupMenu={1} menuOwner=0x{2:X}",
                             inMenu, popup, g.hwndMenuOwner.ToInt64());
    }

    public static int ForegroundPid() {
        int pid; GetWindowThreadProcessId(GetForegroundWindow(), out pid); return pid;
    }
}
'@
Add-Type -TypeDefinition $sig -Language CSharp

$p = Get-Process astoria -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { Write-Host "astoria.exe not running."; exit 1 }

$hwnd = $p.MainWindowHandle
[void][AltProbe]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds 600

# The guard: never synthesize input unless Astoria really owns the foreground.
if ([AltProbe]::ForegroundPid() -ne $p.Id) {
    Write-Host "REFUSING: astoria.exe does not own the foreground. Nothing was sent."
    exit 1
}

$tid = [AltProbe]::GetWindowThreadProcessId($hwnd, [ref]$null)

Write-Host "Instrument check - menu state with nothing sent:"
Write-Host ("  " + [AltProbe]::MenuState($tid))

# The instrument must prove it can report True before any False is believed.
# Plain Alt alone enters menu mode on every Win32 menu bar; if this does not
# register, the probe is broken and every negative below is meaningless.
[AltProbe]::SendAltAlone()
Start-Sleep -Milliseconds 500
$armed = [AltProbe]::MenuState($tid)
Write-Host ("Instrument check - after bare Alt: " + $armed)
[AltProbe]::SendEscape(); Start-Sleep -Milliseconds 300
if ($armed -notmatch 'inMenuMode=True') {
    Write-Host "`nABORT: the probe cannot detect menu mode even when it must be active."
    Write-Host "Any 'shortcut does nothing' result from this harness would be a false negative."
    exit 1
}
Write-Host ""

# D and U are the renamed Code/Run mnemonics; C and R are their OLD letters (must now fail --
# nothing claims them); G is the unchanged control (was failing, should still fail); F and T are
# the known-good controls. E is the "no such menu" reference.
# Full alphabet sweep, to find the COMPLETE set of unusable letters.
# Read the result with Temp\_astoria_menukeys.log, which distinguishes the two "nothing visible"
# cases: a letter with no menu produces WM_INITMENU + WM_MENUCHAR (Windows looked and found
# nothing), whereas a swallowed letter produces NO messages at all.
# O is excluded: Alt+O is a real accelerator (Import from Folder) and opens a modal dialog,
# which would disable the main window and turn every later letter into a false negative.
foreach ($ch in [char[]]('ABCDEFGHIJKLMNPQRSTUVWXYZ')) {
    # Re-establish Astoria as foreground for EVERY letter. Without this, one
    # shortcut that opens another window turns every later result into a false
    # negative -- which is exactly what happened on the first run.
    [AltProbe]::SendEscape(); Start-Sleep -Milliseconds 200
    [void][AltProbe]::SetForegroundWindow($hwnd)
    Start-Sleep -Milliseconds 400
    if ([AltProbe]::ForegroundPid() -ne $p.Id) {
        Write-Host ("  Alt+{0}: SKIPPED - could not restore Astoria to foreground" -f $ch)
        continue
    }

    [AltProbe]::SendAlt($ch)

    # THE BELL CHECK.
    #
    # A single sample 500ms later cannot tell two very different outcomes apart, because both
    # look like "no menu" by the time you read them:
    #   * Windows entered menu mode, found no such mnemonic, and BEEPED  (a letter with no menu)
    #   * Windows never entered menu mode at all                        (a swallowed letter)
    # The owner heard that difference -- Alt+A and Alt+B rang the system bell, Alt+C and Alt+G
    # and Alt+R were silent -- while this probe reported all four identically. That silence is
    # the actual defect signature, and the harness was blind to it.
    #
    # Menu mode for a non-matching letter is entered and abandoned in a few milliseconds, so poll
    # fast and record whether it was EVER entered, rather than sampling once after the fact.
    # The three outcomes separate themselves without any hardcoded list of which letters
    # "should" work -- baking that in would assume the answer the probe is meant to measure:
    #   opened   -> menu mode entered AND STILL ACTIVE at the end (it waits for the user)
    #   no match -> menu mode entered but already gone (Windows beeped and bailed)
    #   swallowed-> menu mode never entered at all
    $everMenu = $false
    for ($t = 0; $t -lt 60; $t++) {          # ~600ms at 10ms resolution
        if ([AltProbe]::MenuState($tid) -match 'inMenuMode=True') { $everMenu = $true }
        Start-Sleep -Milliseconds 10
    }
    $finalMenu = [AltProbe]::MenuState($tid) -match 'inMenuMode=True'
    $fg = [AltProbe]::ForegroundPid()

    if ($fg -ne $p.Id) {
        $other = (Get-Process -Id $fg -ErrorAction SilentlyContinue).ProcessName
        Write-Host ("  Alt+{0}: FIRED A COMMAND - foreground went to '{1}' (pid {2})" -f $ch, $other, $fg)
    } elseif ($finalMenu) {
        Write-Host ("  Alt+{0}: MENU OPENED" -f $ch)
    } elseif ($everMenu) {
        Write-Host ("  Alt+{0}: no such menu - menu mode entered then abandoned (BELL)" -f $ch)
    } else {
        Write-Host ("  Alt+{0}: SWALLOWED - menu mode never entered, no bell  <<< defect signature" -f $ch)
    }
    [AltProbe]::SendEscape(); Start-Sleep -Milliseconds 200
}

[AltProbe]::SendEscape()
Write-Host "`nDone; menu mode released."
