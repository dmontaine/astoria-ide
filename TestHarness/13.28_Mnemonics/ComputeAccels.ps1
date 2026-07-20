# Rebuilds, from the LIVE menu tree, the accelerator table MFF would have created -- and looks
# for anything that would swallow Alt+C / Alt+R / Alt+G.
#
# MFF builds accelerators in MainMenu.ParentWindow (Menus.bas ~1541) from every menu item whose
# caption contains a TAB, using deliberately loose parsing:
#
#   fVirt |= FCONTROL  if InStr(hotkey,"Ctrl")   <- substring test, anywhere in the string
#   fVirt |= FSHIFT    if InStr(hotkey,"Shift")
#   fVirt |= FALT      if InStr(hotkey,"Alt")
#   key    = GetAscKeyCode(text after the LAST "+")
#   GetAscKeyCode falls through to Asc(text) for anything it does not recognise -- so a
#   multi-character token yields the code of its FIRST CHARACTER.
#
# That means any caption carrying a tab followed by something that is not a real shortcut
# (a file path, say) still produces an accelerator entry, keyed on its first letter.

$sig = @'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class MenuWalk {
    [DllImport("user32.dll")] public static extern IntPtr GetMenu(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern int GetMenuItemCount(IntPtr hMenu);

    [StructLayout(LayoutKind.Sequential)]
    public struct MENUITEMINFO {
        public int cbSize; public int fMask; public int fType; public int fState;
        public int wID; public IntPtr hSubMenu; public IntPtr hbmpChecked;
        public IntPtr hbmpUnchecked; public IntPtr dwItemData;
        public IntPtr dwTypeData; public int cch; public IntPtr hbmpItem;
    }
    [DllImport("user32.dll", CharSet=CharSet.Unicode, EntryPoint="GetMenuItemInfoW")]
    public static extern bool GetMenuItemInfo(IntPtr hMenu, int item, bool byPos, ref MENUITEMINFO mii);

    // Returns "caption\thSubMenu" per item.
    public static List<string> Items(IntPtr hMenu) {
        var res = new List<string>();
        int n = GetMenuItemCount(hMenu);
        for (int i = 0; i < n; i++) {
            var mii = new MENUITEMINFO();
            mii.cbSize = Marshal.SizeOf(typeof(MENUITEMINFO));
            mii.fMask = 0x00000004 /*SUBMENU*/ | 0x00000040 /*STRING*/ | 0x00000100 /*FTYPE*/;
            IntPtr buf = Marshal.AllocHGlobal(2048);
            try {
                mii.dwTypeData = buf; mii.cch = 1023;
                if (!GetMenuItemInfo(hMenu, i, true, ref mii)) { continue; }
                string cap = Marshal.PtrToStringUni(buf, mii.cch);
                res.Add(cap + "" + mii.hSubMenu.ToInt64());
            } finally { Marshal.FreeHGlobal(buf); }
        }
        return res;
    }
}
'@
Add-Type -TypeDefinition $sig -Language CSharp

$p = Get-Process astoria -ErrorAction SilentlyContinue |
     Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { Write-Host "astoria.exe not running."; exit 1 }

$accels = New-Object System.Collections.Generic.List[object]

function Walk([IntPtr]$hMenu, [string]$path) {
    foreach ($row in [MenuWalk]::Items($hMenu)) {
        # PowerShell 5.1 has no `u{...} escape -- split on the literal char instead.
        $parts = $row.Split([char]1)
        $cap = $parts[0]
        $sub = [int64]$parts[1]
        $label = ($cap -split "`t")[0]

        if ($cap.Contains("`t")) {
            $hk = $cap.Substring($cap.IndexOf("`t") + 1)
            $fVirt = @()
            if ($hk -like "*Ctrl*")  { $fVirt += "Ctrl" }
            if ($hk -like "*Shift*") { $fVirt += "Shift" }
            if ($hk -like "*Alt*")   { $fVirt += "Alt" }
            $tok = $hk
            $plus = $hk.LastIndexOf("+")
            if ($plus -ge 0) { $tok = $hk.Substring($plus + 1) }
            # GetAscKeyCode: named keys, else Asc(first char)
            $named = @("Break","Backspace","Back","Tab","Enter","Return","Pause","Escape","Esc","Space",
                       "PageUp","PageDown","End","Home","Left","Up","Right","Down","Print","Insert","Ins",
                       "Delete","Del") + (0..9 | ForEach-Object { "Num$_" }) + (1..12 | ForEach-Object { "F$_" })
            $isNamed = $named -contains $tok
            $key = if ($isNamed) { $tok } elseif ($tok.Length -gt 0) { $tok.Substring(0,1).ToUpper() } else { "<EMPTY>" }
            $accels.Add([pscustomobject]@{
                Path  = $path
                Label = $label
                Raw   = $hk
                Mods  = ($fVirt -join "+")
                Key   = $key
                Loose = (-not $isNamed -and $tok.Length -gt 1)   # multi-char token -> first letter only
            })
        }
        if ($sub -ne 0) { Walk ([IntPtr]$sub) ("$path/$label") }
    }
}

Walk ([MenuWalk]::GetMenu($p.MainWindowHandle)) ""

Write-Host "Accelerator entries MFF would build: $($accels.Count)`n"

Write-Host "=== Entries whose key token was NOT a recognised key name ==="
Write-Host "=== (GetAscKeyCode falls back to the FIRST CHARACTER)     ===`n"
$loose = $accels | Where-Object { $_.Loose }
if ($loose.Count -eq 0) { Write-Host "  none" }
else { $loose | Format-Table Path,Label,Raw,Mods,Key -AutoSize -Wrap }

Write-Host "`n=== Anything that would consume a bare Alt+<letter> ==="
$bad = $accels | Where-Object { $_.Mods -eq "Alt" -and $_.Key.Length -eq 1 }
if ($bad.Count -eq 0) { Write-Host "  none" }
else { $bad | Format-Table Path,Label,Raw,Mods,Key -AutoSize -Wrap }

Write-Host "`n=== Specifically C / R / G, any modifier combination ==="
$accels | Where-Object { $_.Key -in @("C","R","G") } | Format-Table Path,Label,Raw,Mods,Key -AutoSize -Wrap
