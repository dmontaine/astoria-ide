# Shared input layer for the shortcut tests.
#
# Real synthesized input (SendInput) only -- NEVER posted WM_COMMAND/BM_CLICK. TestPlan A7
# established that a posted message travels a path a real user cannot, so driving shortcut tests
# that way manufactures passes. E9 additionally showed that an unguarded harness types into
# whatever window Windows handed the foreground to, so every send refuses unless astoria.exe owns
# the foreground.

Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
[StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT {
  public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo;
}
[StructLayout(LayoutKind.Sequential)] public struct MOUSEINPUT {
  public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr dwExtraInfo;
}
[StructLayout(LayoutKind.Explicit)] public struct INPUTUNION {
  [FieldOffset(0)] public MOUSEINPUT mi;
  [FieldOffset(0)] public KEYBDINPUT ki;
}
[StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public INPUTUNION u; }
[StructLayout(LayoutKind.Sequential)] public struct RCT { public int L,T,R,B; }
public class Keys {
  [DllImport("user32.dll", SetLastError=true)] public static extern uint SendInput(uint n, INPUT[] p, int cb);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RCT r);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr p);
  public delegate bool EnumProc(IntPtr h, IntPtr p);

  const uint KEYEVENTF_KEYUP = 0x0002;
  const uint KEYEVENTF_EXTENDED = 0x0001;

  public static uint ForegroundPid() {
    uint pid; GetWindowThreadProcessId(GetForegroundWindow(), out pid); return pid;
  }
  public static string ForegroundDesc() {
    IntPtr h = GetForegroundWindow(); uint pid; GetWindowThreadProcessId(h, out pid);
    var t = new StringBuilder(300); GetWindowTextW(h, t, 300);
    var c = new StringBuilder(120); GetClassNameW(h, c, 120);
    return string.Format("pid={0} class='{1}' title='{2}'", pid, c, t);
  }
  // Returns false rather than sending into the wrong process.
  public static bool SendKeys(uint expectPid, ushort[] vks, bool[] isUp) {
    if (ForegroundPid() != expectPid) return false;
    var inp = new INPUT[vks.Length];
    for (int i = 0; i < vks.Length; i++) {
      inp[i].type = 1;
      inp[i].u.ki.wVk = vks[i];
      inp[i].u.ki.dwFlags = isUp[i] ? KEYEVENTF_KEYUP : 0;
    }
    return SendInput((uint)inp.Length, inp, Marshal.SizeOf(typeof(INPUT))) == (uint)inp.Length;
  }
  public static bool ClickAt(uint expectPid, int x, int y) {
    if (ForegroundPid() != expectPid) return false;
    SetCursorPos(x, y);
    var inp = new INPUT[2];
    inp[0].type = 0; inp[0].u.mi.dwFlags = 0x0002; // LEFTDOWN
    inp[1].type = 0; inp[1].u.mi.dwFlags = 0x0004; // LEFTUP
    return SendInput(2, inp, Marshal.SizeOf(typeof(INPUT))) == 2;
  }
  // Visible top-level windows of a process, for "did a dialog open?".
  public static string[] VisibleWindows(uint target) {
    var list = new System.Collections.Generic.List<string>();
    EnumWindows((h,l) => {
      uint pid; GetWindowThreadProcessId(h, out pid);
      if (pid == target && IsWindowVisible(h)) {
        var t = new StringBuilder(300); GetWindowTextW(h, t, 300);
        var c = new StringBuilder(120); GetClassNameW(h, c, 120);
        list.Add(c.ToString() + "|" + t.ToString());
      }
      return true;
    }, IntPtr.Zero);
    return list.ToArray();
  }
}
'@

$script:VK = @{
  'BACKSPACE'=0x08; 'TAB'=0x09; 'ENTER'=0x0D; 'RETURN'=0x0D; 'SHIFT'=0x10; 'CTRL'=0x11; 'ALT'=0x12
  'PAUSE'=0x13; 'CAPSLOCK'=0x14; 'ESC'=0x1B; 'ESCAPE'=0x1B; 'SPACE'=0x20
  'PGUP'=0x21; 'PGDN'=0x22; 'END'=0x23; 'HOME'=0x24
  'LEFT'=0x25; 'UP'=0x26; 'RIGHT'=0x27; 'DOWN'=0x28; 'INS'=0x2D; 'DEL'=0x2E
  'F1'=0x70;'F2'=0x71;'F3'=0x72;'F4'=0x73;'F5'=0x74;'F6'=0x75
  'F7'=0x76;'F8'=0x77;'F9'=0x78;'F10'=0x79;'F11'=0x7A;'F12'=0x7B
}
function Resolve-Vk([string]$k) {
  $u = $k.Trim().ToUpper()
  if ($script:VK.ContainsKey($u)) { return [int]$script:VK[$u] }
  if ($u.Length -eq 1) {
    $c = [char]$u
    if (($c -ge 'A' -and $c -le 'Z') -or ($c -ge '0' -and $c -le '9')) { return [int][byte][char]$u }
  }
  return -1
}

# "Ctrl+Shift+F8" -> ordered key-down/key-up sequence
function ConvertTo-KeySeq([string]$shortcut) {
  $parts = $shortcut.Split('+') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
  $mods = @(); $main = $null
  foreach ($p in $parts) {
    switch ($p.ToUpper()) {
      'CTRL'    { $mods += 0x11 }
      'CONTROL' { $mods += 0x11 }
      'ALT'     { $mods += 0x12 }
      'SHIFT'   { $mods += 0x10 }
      default   { $main = $p }
    }
  }
  if ($null -eq $main) { return $null }
  $vk = Resolve-Vk $main
  if ($vk -lt 0) { return $null }
  $vks = @(); $ups = @()
  foreach ($m in $mods) { $vks += [uint16]$m; $ups += $false }
  $vks += [uint16]$vk; $ups += $false
  $vks += [uint16]$vk; $ups += $true
  for ($i = $mods.Count - 1; $i -ge 0; $i--) { $vks += [uint16]$mods[$i]; $ups += $true }
  return [pscustomobject]@{ Vks = [uint16[]]$vks; Ups = [bool[]]$ups }
}

# NOTE: the parameter is TargetPid, not Pid -- $pid is a read-only automatic variable in
# PowerShell and binding a parameter to that name fails at call time, not at definition.
function Send-Shortcut([uint32]$TargetPid, [string]$shortcut) {
  $seq = ConvertTo-KeySeq $shortcut
  if ($null -eq $seq) { return "UNPARSED" }
  if (-not [Keys]::SendKeys($TargetPid, $seq.Vks, $seq.Ups)) { return "REFUSED" }
  Start-Sleep -Milliseconds 500
  return "SENT"
}
function Send-Text([uint32]$TargetPid, [string]$text) {
  foreach ($ch in $text.ToCharArray()) {
    $vk = Resolve-Vk ([string]$ch)
    if ($vk -lt 0) { continue }
    if (-not [Keys]::SendKeys($TargetPid, [uint16[]]@($vk,$vk), [bool[]]@($false,$true))) { return $false }
    Start-Sleep -Milliseconds 40
  }
  return $true
}
