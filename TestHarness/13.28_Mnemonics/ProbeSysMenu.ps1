# Reads the SYSTEM menu of the Astoria main window.
#
# Why: Alt+E enters menu mode and reports "no match" (WM_INITMENU + WM_MENUCHAR), but Alt+C,
# Alt+R and Alt+G produce nothing at all -- Windows does not even enter menu mode. A mnemonic
# that matches a DISABLED item is matched-but-not-actionable, which is silent in exactly that
# way. The standard system menu carries &Close and &Restore, and its items are routinely
# greyed depending on window state.

$sig = @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class SysMenu {
    [DllImport("user32.dll")] public static extern IntPtr GetSystemMenu(IntPtr hWnd, bool bRevert);
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

    public static string Describe(IntPtr hMenu, int i) {
        var mii = new MENUITEMINFO();
        mii.cbSize = Marshal.SizeOf(typeof(MENUITEMINFO));
        mii.fMask = 0x1 /*STATE*/ | 0x4 /*SUBMENU*/ | 0x40 /*STRING*/ | 0x100 /*FTYPE*/;
        IntPtr buf = Marshal.AllocHGlobal(1024);
        try {
            mii.dwTypeData = buf; mii.cch = 511;
            if (!GetMenuItemInfo(hMenu, i, true, ref mii)) return "(query failed " + Marshal.GetLastWin32Error() + ")";
            string cap = Marshal.PtrToStringUni(buf, mii.cch);
            bool grayed = (mii.fState & 0x3) != 0;
            bool sep = (mii.fType & 0x800) != 0;
            string amp = "(none)";
            int p = cap.IndexOf('&');
            if (p >= 0 && p < cap.Length - 1) amp = "Alt+" + char.ToUpper(cap[p+1]);
            return string.Format("{0,-22} mnemonic={1,-8} {2,-9} id={3}",
                sep ? "(separator)" : "\"" + cap + "\"", amp,
                grayed ? "DISABLED" : "enabled", mii.wID);
        } finally { Marshal.FreeHGlobal(buf); }
    }
}
'@
Add-Type -TypeDefinition $sig -Language CSharp

$p = Get-Process astoria -ErrorAction SilentlyContinue |
     Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { Write-Host "astoria.exe not running."; exit 1 }

# bRevert = false -> the window's own (possibly modified) copy, which is what Windows uses.
$h = [SysMenu]::GetSystemMenu($p.MainWindowHandle, $false)
if ($h -eq [IntPtr]::Zero) { Write-Host "No system menu."; exit 1 }

$n = [SysMenu]::GetMenuItemCount($h)
Write-Host "System menu of PID $($p.Id) - $n items`n"
for ($i = 0; $i -lt $n; $i++) { Write-Host ("  [{0,2}] {1}" -f $i, [SysMenu]::Describe($h, $i)) }
