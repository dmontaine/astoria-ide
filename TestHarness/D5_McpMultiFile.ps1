# TestPlan D5 -- AI/MCP multi-file lifecycle through the live Astoria agent pipe.
# create -> add files -> introduce error -> build/get_errors -> fix -> run.
$ErrorActionPreference = "Stop"

function Send-Pipe([string]$json, [int]$timeoutMs = 180000) {
    $c = New-Object System.IO.Pipes.NamedPipeClientStream('.','AstoriaAgent',[System.IO.Pipes.PipeDirection]::InOut)
    $c.Connect(5000); $c.ReadMode = [System.IO.Pipes.PipeTransmissionMode]::Byte
    $w = New-Object System.IO.StreamWriter($c,(New-Object System.Text.UTF8Encoding($false))); $w.AutoFlush = $true
    $r = New-Object System.IO.StreamReader($c,(New-Object System.Text.UTF8Encoding($false)))
    $w.WriteLine($json); $line = $r.ReadLine(); $c.Dispose(); return $line
}
function J([hashtable]$o) { $o | ConvertTo-Json -Compress -Depth 8 }

$results = @()
function Check([string]$what, [bool]$ok, [string]$detail = "") {
    $script:results += [pscustomobject]@{ Check = $what; Pass = $ok; Detail = $detail }
    "{0}  {1}{2}" -f $(if ($ok) { "PASS" } else { "FAIL" }), $what, $(if ($detail) { "  -- $detail" } else { "" })
}

$name = "D5_McpMultiFile_" + (Get-Date -Format "yyyyMMdd_HHmmss")
$root = "C:\Users\don\Astoria-IDE\Projects\$name"
$marker = "D5-MARKER-" + (Get-Random -Minimum 10000 -Maximum 99999)
$mainPath = "$root\Main.bas"
$headerPath = "$root\Math.bi"
$modulePath = "$root\Math.bas"

# 1. Create a console project and add a header/module pair using MCP project operations.
$r = Send-Pipe (J @{ id=1; cmd="create_project"; args=@{ name=$name; template="Console Application" } })
Check "create_project succeeds" ($r -match '"ok":true')
Start-Sleep -Seconds 2

$r = Send-Pipe (J @{ id=2; cmd="add_file"; args=@{ name="Math"; kind="header"; register=$true; open=$false } })
Check "add_file registers header" ($r -match '"ok":true')
$r = Send-Pipe (J @{ id=3; cmd="add_file"; args=@{ name="Math"; kind="module"; register=$true; open=$false } })
Check "add_file registers module" ($r -match '"ok":true')

$header = @"
Declare Function SumSquares(ByVal limit As Integer) As Integer
"@
$brokenModule = @"
#include once "Math.bi"

Function SumSquares(ByVal limit As Integer) As Integer
    Dim As Integer total = 0
    For i As Integer = 1 To limit
        total += missingValue
    Next i
    Return total
End Function
"@
$main = @"
#include once "Math.bas"

Print "$marker"
Print "sum_squares="; SumSquares(10)
Sleep 300
"@

foreach ($item in @(@($headerPath,$header), @($modulePath,$brokenModule), @($mainPath,$main))) {
    $r = Send-Pipe (J @{ id=4; cmd="write_file"; args=@{ path=$item[0]; content=$item[1] } })
    Check ("write_file succeeds: " + [IO.Path]::GetFileName($item[0])) ($r -match '"ok":true')
}

$r = Send-Pipe (J @{ id=5; cmd="list_files" })
$fileList = $r | ConvertFrom-Json
$fileText = $fileList.result.files -join "|"
Check "live project lists Main.bas, Math.bi, and Math.bas" (($fileText -match 'Main\.bas') -and ($fileText -match 'Math\.bi') -and ($fileText -match 'Math\.bas')) $fileText

# 2. Build the deliberately broken secondary module and inspect structured errors.
$r = Send-Pipe (J @{ id=6; cmd="build" })
Check "broken multi-file build fails" (-not ($r -match '"exit_code":0'))
$r = Send-Pipe (J @{ id=7; cmd="get_errors" })
$errors = ($r | ConvertFrom-Json).result.errors
$rootError = $errors | Where-Object { $_.file -match 'Math\.bas$' -and $_.message -match 'missingValue|not defined|declared' } | Select-Object -First 1
Check "get_errors identifies Math.bas root error" ($null -ne $rootError) (($errors | ConvertTo-Json -Compress -Depth 5))
Check "root error includes a source line" ($null -ne $rootError -and [int]$rootError.line -gt 0) $(if ($rootError) { "line $($rootError.line)" } else { "no matching error" })

# 3. Repair through MCP, rebuild, and assert on meaningful output.
$fixedModule = $brokenModule.Replace("total += missingValue", "total += i * i")
$r = Send-Pipe (J @{ id=8; cmd="write_file"; args=@{ path=$modulePath; content=$fixedModule } })
Check "repair Math.bas through MCP" ($r -match '"ok":true')
$r = Send-Pipe (J @{ id=9; cmd="build" })
Check "fixed multi-file build succeeds" ($r -match '"exit_code":0')
$r = Send-Pipe (J @{ id=10; cmd="run" })
$out = ($r | ConvertFrom-Json).result.output
Check "run returns unique marker" ($out -match [regex]::Escape($marker)) ("output len " + $out.Length)
Check "run returns computed cross-module result" ($out -match 'sum_squares=\s*385') (($out -replace '\s+',' ').Trim())

""
$passed = ($results | Where-Object { $_.Pass }).Count
$total = $results.Count
"D5 RESULT: $passed/$total"
if ($passed -ne $total) {
    $results | Where-Object { -not $_.Pass } | Format-Table -AutoSize | Out-String
    exit 1
}
