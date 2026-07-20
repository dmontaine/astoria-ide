# A control application for the Alt+C / Alt+R / Alt+G investigation.
#
# Same machine, same session, same mnemonic letters, but a stock Win32 menu owned by
# WinForms instead of MFF. This is the discriminator:
#   - if Alt+C/R/G work HERE but not in Astoria  -> the cause is in Astoria/MFF
#   - if they fail here too                      -> something on this machine eats them,
#                                                   and no change to Astoria can fix it
#
# Deliberately includes Alt+F/Alt+T as in-app controls, so a run that fails everything
# is recognisable as a broken test rather than a finding.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "AstoriaMnemonicControl"
$form.Width = 640
$form.Height = 260
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

$menu = New-Object System.Windows.Forms.MainMenu

# Same letters, same order-ish as Astoria's bar.
foreach ($spec in @("&File", "&Code", "&Run", "&Git", "&Tools")) {
    $top = New-Object System.Windows.Forms.MenuItem $spec
    # A popup needs at least one child or Windows will not open it.
    $child = New-Object System.Windows.Forms.MenuItem "Item one"
    [void]$top.MenuItems.Add($child)
    [void]$menu.MenuItems.Add($top)
}
$form.Menu = $menu

$label = New-Object System.Windows.Forms.Label
$label.Text = "Control app for mnemonic testing. Close when done."
$label.Dock = "Fill"
$form.Controls.Add($label)

[System.Windows.Forms.Application]::Run($form)
