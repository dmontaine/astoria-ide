# Alt+<letter> probe for ROADMAP 13.28 part 3, built for the BISECTION (not for diagnosis).
#
# It answers one question: did a menu open? That is all a bisect needs -- the bell/no-bell
# distinction matters for explaining the defect, not for locating it.
#
# Menu state is read with GetGUIThreadInfo (GUI_INMENUMODE + hwndMenuOwner), not inferred from a
# screenshot or a timing guess.
#
# The instrument proves itself on every run: Alt+F must OPEN and Alt+C must NOT, inside the same
# process. A run where Alt+F fails to open is a broken probe, not a finding -- two harnesses in this
# investigation already reported everything dead because they were sending nothing at all.

param([string]$Letters = 'F,C,G,R,V,P,T,W,H', [switch]$Quiet)

$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System; using System.Text; using System.Runtime.InteropServices;
[StructLayout(LayoutKind.Sequential)] public struct GUITHREADINFO3 {
  public int cbSize; public int flags; public IntPtr hwndActive; public IntPtr hwndFocus;
  public IntPtr hwndCapture; public IntPtr hwndMenuOwner; public IntPtr hwndMoveSize;
  public IntPtr hwndCaret; public int l,t,r,b;
}
[StructLayout(LayoutKind.Sequential)] public struct KBDIN { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
// MOUSEINPUT must be in the union even though only keys are sent: it is the LARGEST member and so
// it is what sizes the union (32 bytes). Omitting it gives a 32-byte INPUT instead of 40, and
// SendInput then fails with ERROR_INVALID_PARAMETER (87) and sends nothing -- which reads exactly
// like "every key is dead". This is the documented trap in the 13.28 README and it was walked into
// again here; only the Alt+F positive control caught it.
[StructLayout(LayoutKind.Sequential)] public struct MSEIN { public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
[StructLayout(LayoutKind.Explicit)] public struct INU {
  [FieldOffset(0)] public MSEIN mi;
  [FieldOffset(0)] public KBDIN ki;
}
[StructLayout(LayoutKind.Sequential)] public struct INP { public uint type; public INU u; }
public class MP {
  [DllImport("user32.dll", SetLastError=true)] public static extern uint SendInput(uint n, INP[] p, int cb);
  [DllImport("user32.dll")] public static extern bool GetGUIThreadInfo(uint tid, ref GUITHREADINFO3 g);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  const uint KEYUP = 2;
  public static bool Fg(uint expectPid) { uint p; GetWindowThreadProcessId(GetForegroundWindow(), out p); return p == expectPid; }
  public static void Send(ushort[] vk, bool[] up) {
    var a = new INP[vk.Length];
    for (int i=0;i<vk.Length;i++){ a[i].type=1; a[i].u.ki.wVk=vk[i]; a[i].u.ki.dwFlags = up[i]?KEYUP:0; }
    SendInput((uint)a.Length, a, Marshal.SizeOf(typeof(INP)));
  }
  // true while the thread owning the foreground window is in menu mode
  public static bool InMenu(out IntPtr owner) {
    owner = IntPtr.Zero;
    IntPtr fg = GetForegroundWindow(); uint pid; uint tid = GetWindowThreadProcessId(fg, out pid);
    var g = new GUITHREADINFO3(); g.cbSize = Marshal.SizeOf(typeof(GUITHREADINFO3));
    if (!GetGUIThreadInfo(tid, ref g)) return false;
    owner = g.hwndMenuOwner;
    return ((g.flags & 0x4) != 0) || g.hwndMenuOwner != IntPtr.Zero;   // GUI_INMENUMODE
  }
}
'@

$sz = [System.Runtime.InteropServices.Marshal]::SizeOf([type][INP])
if ($sz -ne 40) { throw "INPUT struct is $sz bytes, must be 40 on x64 -- SendInput would fail with error 87 and send nothing" }

$p = Get-Process astoria -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $p) { throw "Astoria is not running." }
$targetPid = [uint32]$p.Id
$h = $p.MainWindowHandle

function Test-Alt([string]$L) {
  [void][MP]::SetForegroundWindow($h); Start-Sleep -Milliseconds 500
  # make sure no menu is left open from the previous letter
  for ($i=0; $i -lt 3; $i++) {
    $o = [IntPtr]::Zero
    if (-not [MP]::InMenu([ref]$o)) { break }
    [MP]::Send(@([uint16]0x1B,[uint16]0x1B), @($false,$true)); Start-Sleep -Milliseconds 250
  }
  if (-not [MP]::Fg($targetPid)) { return 'NO-FOREGROUND' }

  $vk = [uint16][byte][char]$L
  # Alt down, letter down, letter up, Alt up
  [MP]::Send(@([uint16]0x12,$vk,$vk,[uint16]0x12), @($false,$false,$true,$true))

  # poll: a menu can take a moment to appear
  $opened = $false; $owner = [IntPtr]::Zero
  for ($i=0; $i -lt 60; $i++) {
    Start-Sleep -Milliseconds 25
    $o = [IntPtr]::Zero
    if ([MP]::InMenu([ref]$o)) { $opened = $true; $owner = $o; break }
  }
  # leave no menu open behind us
  if ($opened) {
    [MP]::Send(@([uint16]0x1B,[uint16]0x1B), @($false,$true)); Start-Sleep -Milliseconds 300
  }
  if ($opened) { return "MENU OPENED (owner=$owner)" } else { return 'no menu' }
}

$results = @{}
foreach ($L in ($Letters -split ',')) {
  $L = $L.Trim().ToUpper()
  if ($L -eq '') { continue }
  $r = Test-Alt $L
  $results[$L] = $r
  if (-not $Quiet) { "  Alt+{0}  {1}" -f $L, $r }
}

# --- the instrument must prove it can fire both ways, in this same process ---
$fOk = $results['F'] -like 'MENU OPENED*'
$cBad = $results['C'] -eq 'no menu'
""
if (-not $fOk) {
  "INSTRUMENT INVALID: Alt+F did not open a menu. Nothing above is evidence."
} else {
  "instrument OK: Alt+F opened a menu (positive control fired)"
  if ($cBad) { "  and Alt+C did not -- the defect reproduces under this probe" }
  else       { "  and Alt+C ALSO opened -- the defect is NOT reproducing right now" }
}

