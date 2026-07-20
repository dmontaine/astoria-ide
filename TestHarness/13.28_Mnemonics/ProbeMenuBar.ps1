# Reads the REAL top-level menu bar of the running astoria.exe.
# Answers, per item: is the caption Windows sees still carrying its '&' mnemonic,
# is the item MFT_STRING (mnemonic-capable) or MFT_OWNERDRAW (Windows cannot read
# the text, so the mnemonic is dead unless the app handles WM_MENUCHAR), and is it
# enabled (a disabled top-level menu swallows its mnemonic).

$sig = @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class MenuProbe {
    [DllImport("user32.dll")] public static extern IntPtr GetMenu(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern int GetMenuItemCount(IntPtr hMenu);

    [StructLayout(LayoutKind.Sequential)]
    public struct MENUITEMINFO {
        public int cbSize; public int fMask; public int fType; public int fState;
        public int wID; public IntPtr hSubMenu; public IntPtr hbmpChecked;
        public IntPtr hbmpUnchecked; public IntPtr dwItemData;
        public IntPtr dwTypeData; public int cch; public IntPtr hbmpItem;
    }

    [DllImport("user32.dll", CharSet = CharSet.Unicode, EntryPoint = "GetMenuItemInfoW", SetLastError = true)]
    public static extern bool GetMenuItemInfo(IntPtr hMenu, int item, bool byPos, ref MENUITEMINFO mii);

    public static int StructSize() { return Marshal.SizeOf(typeof(MENUITEMINFO)); }

    public static string Describe(IntPtr hMenu, int i) {
        var mii = new MENUITEMINFO();
        mii.cbSize = Marshal.SizeOf(typeof(MENUITEMINFO));
        mii.fMask = 0x00000001 /*MIIM_STATE*/ | 0x00000004 /*MIIM_SUBMENU*/
                  | 0x00000040 /*MIIM_STRING*/ | 0x00000100 /*MIIM_FTYPE*/;
        IntPtr buf = Marshal.AllocHGlobal(512);
        try {
            mii.dwTypeData = buf; mii.cch = 255;
            if (!GetMenuItemInfo(hMenu, i, true, ref mii))
                return "(query failed, GetLastError=" + Marshal.GetLastWin32Error() + ")";
            string cap = Marshal.PtrToStringUni(buf, mii.cch);
            bool ownerDraw = (mii.fType & 0x00000100) != 0;   // MFT_OWNERDRAW
            bool grayed    = (mii.fState & 0x00000003) != 0;   // MFS_GRAYED|MFS_DISABLED
            string amp = cap.Contains("&") ? ("Alt+" + cap.Substring(cap.IndexOf('&') + 1, 1).ToUpper()) : "(none)";
            // A menu-bar item with hSubMenu == 0 is a COMMAND, not a popup: Alt+<letter>
            // sends WM_COMMAND and never enters menu mode, so nothing appears on screen.
            // Windows matches a menu-bar mnemonic but will NOT open a popup that has no items,
            // and sends no WM_MENUCHAR either (it did match). That is silent, and looks exactly
            // like a dead mnemonic.
            string sub;
            if (mii.hSubMenu == IntPtr.Zero) {
                sub = "NO POPUP (command item!)";
            } else {
                int cnt = GetMenuItemCount(mii.hSubMenu);
                sub = "popup=0x" + mii.hSubMenu.ToInt64().ToString("X") + " items=" + cnt
                    + (cnt == 0 ? "  <<< EMPTY" : "");
            }
            return string.Format("{0,-14} mnemonic={1,-8} {2,-9} {3,-24} id={4}",
                "\"" + cap + "\"", amp,
                grayed ? "DISABLED" : "enabled",
                sub, mii.wID);
        } finally { Marshal.FreeHGlobal(buf); }
    }
}
'@
Add-Type -TypeDefinition $sig -Language CSharp

$p = Get-Process astoria -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { Write-Host "astoria.exe is not running with a main window."; exit 1 }

$hMenu = [MenuProbe]::GetMenu($p.MainWindowHandle)
if ($hMenu -eq [IntPtr]::Zero) { Write-Host "Main window has no menu bar."; exit 1 }

$n = [MenuProbe]::GetMenuItemCount($hMenu)
Write-Host "Top-level menu bar of PID $($p.Id) - $n items`n"
for ($i = 0; $i -lt $n; $i++) {
    Write-Host ("  [{0,2}] {1}" -f $i, [MenuProbe]::Describe($hMenu, $i))
}
