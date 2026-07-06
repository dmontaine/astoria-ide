param(
    [Parameter(Mandatory = $true)]
    [string]$DllPath,
    [Parameter(Mandatory = $true)]
    [string]$SourceDir
)

if (-not (Test-Path -LiteralPath $DllPath)) { exit 0 }

$dll = Get-Item -LiteralPath $DllPath
$files = @(Get-ChildItem -LiteralPath $SourceDir -Recurse -Include '*.bas', '*.bi', '*.frm', '*.rc' -File)
if ($files.Count -eq 0) { exit 0 }

$newest = $files | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($newest.LastWriteTime -gt $dll.LastWriteTime) { exit 0 }
exit 1
