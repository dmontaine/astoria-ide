param([switch]$SkipE4)
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$exe = Join-Path $repo "astoria.exe"
$fixtureRoot = Join-Path $repo "Projects\E_ScaleFixtures"

function Send-Pipe([hashtable]$request, [int]$timeoutMs = 180000) {
    $json = $request | ConvertTo-Json -Compress -Depth 6
    $c = New-Object System.IO.Pipes.NamedPipeClientStream('.','AstoriaAgent',[System.IO.Pipes.PipeDirection]::InOut)
    $c.Connect(5000); $c.ReadMode = [System.IO.Pipes.PipeTransmissionMode]::Byte
    $w = New-Object System.IO.StreamWriter($c,(New-Object System.Text.UTF8Encoding($false))); $w.AutoFlush = $true
    $r = New-Object System.IO.StreamReader($c,(New-Object System.Text.UTF8Encoding($false)))
    $w.WriteLine($json); $line = $r.ReadLine(); $c.Dispose(); return ($line | ConvertFrom-Json)
}
function Measure-Call([scriptblock]$body) {
    $sw = [Diagnostics.Stopwatch]::StartNew(); $value = & $body; $sw.Stop()
    [pscustomobject]@{ Value=$value; Ms=$sw.ElapsedMilliseconds }
}
function Check([string]$test, [string]$what, [bool]$ok, [string]$detail) {
    $script:results += [pscustomobject]@{ Test=$test; Check=$what; Pass=$ok; Detail=$detail }
    "{0} {1} {2} -- {3}" -f $(if($ok){'PASS'}else{'FAIL'}),$test,$what,$detail
}

if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force }
[IO.Directory]::CreateDirectory($fixtureRoot) | Out-Null
$utf8 = New-Object Text.UTF8Encoding($false)

# E4: 100,000-line / roughly 8 MB source file with unique first/last markers.
$large = Join-Path $fixtureRoot "E4_Large.bas"
$builder = New-Object Text.StringBuilder
[void]$builder.AppendLine("' E4-FIRST-MARKER")
for ($i=1; $i -le 99998; $i++) { [void]$builder.AppendLine(("Dim As Integer scale_value_{0:D6} = {0} ' padding for a realistic source line" -f $i)) }
[void]$builder.AppendLine("' E4-LAST-MARKER")
[IO.File]::WriteAllText($large,$builder.ToString(),$utf8)
$e4Vfp = Join-Path $fixtureRoot 'E4_Large.vfp'
[IO.File]::WriteAllLines($e4Vfp,[string[]]@('*File=E4_Large.bas','ProjectType=0','Subsystem=1','ProjectName="E4_Large"','OpenProjectAsFolder=false'),$utf8)

# E5: 60 simultaneously open source documents.
$manyDocs = Join-Path $fixtureRoot "E5_ManyDocs"
[IO.Directory]::CreateDirectory($manyDocs) | Out-Null
$docPaths = 1..60 | ForEach-Object { $p=Join-Path $manyDocs ("Doc{0:D2}.bas" -f $_); [IO.File]::WriteAllText($p,("' E5 document {0}`r`nDim Shared As Integer Value{0} = {0}`r`n" -f $_),$utf8); $p }
$e5Vfp = Join-Path $manyDocs 'E5_ManyDocs.vfp'
$e5Lines = @('*File=Doc01.bas') + @(2..60 | ForEach-Object { 'File=Doc{0:D2}.bas' -f $_ }) + @('ProjectType=0','Subsystem=1','ProjectName="E5_ManyDocs"','OpenProjectAsFolder=false')
[IO.File]::WriteAllLines($e5Vfp,[string[]]$e5Lines,$utf8)

# E6: a project containing 250 registered source files.
$largeProject = Join-Path $fixtureRoot "E6_LargeProject"
[IO.Directory]::CreateDirectory($largeProject) | Out-Null
[IO.File]::WriteAllText((Join-Path $largeProject 'Main.bas'),"Print `"E6`"`r`n",$utf8)
$vfpLines = New-Object Collections.Generic.List[string]
$vfpLines.Add('*File=Main.bas')
for($i=1;$i -le 249;$i++){ $name=("Module{0:D3}.bas" -f $i); [IO.File]::WriteAllText((Join-Path $largeProject $name),("' module {0}`r`n" -f $i),$utf8); $vfpLines.Add("File=$name") }
$vfpLines.AddRange([string[]]@('ProjectType=0','Subsystem=1','ProjectName="E6_LargeProject"','OpenProjectAsFolder=false','Manifest=true','UseGit=false','AIFriendly=false'))
$vfp = Join-Path $largeProject 'E6_LargeProject.vfp'
[IO.File]::WriteAllLines($vfp,$vfpLines,$utf8)

$results = @()
$p = Start-Process -FilePath $exe -WorkingDirectory $repo -PassThru
try {
    $ready=$false
    for($i=0;$i -lt 40 -and -not $ready;$i++){ Start-Sleep -Milliseconds 250; try{$ready=(Send-Pipe @{id=1;cmd='ping'}).ok}catch{} }
    Check 'ALL' 'IDE starts and agent responds' $ready ("pid="+$p.Id)

    if(-not $SkipE4) {
        $m = Measure-Call { Send-Pipe @{id=9;cmd='open_project';args=@{path=$e4Vfp}} }
        Start-Sleep -Seconds 3
        $mOpen = Measure-Call { Send-Pipe @{id=10;cmd='open_in_editor';args=@{path=$large}} }
        Check 'E4' 'open 100,000-line file' ($m.Value.ok -and $mOpen.Value.ok) ("project=$($m.Ms) ms, editor=$($mOpen.Ms) ms, $([math]::Round((Get-Item $large).Length/1MB,2)) MB")
        $mRead = Measure-Call { Send-Pipe @{id=11;cmd='get_active_file'} }
        $content = $mRead.Value.result.content
        Check 'E4' 'read/navigate through complete editor buffer' ($content.StartsWith("' E4-FIRST") -and $content.Contains('E4-LAST-MARKER')) ("$($mRead.Ms) ms, $($content.Length) chars")
        $edited = $content + "' E4-EDIT-MARKER`r`n"
        $mEdit = Measure-Call { Send-Pipe @{id=12;cmd='set_active_file_content';args=@{content=$edited}} }
        $confirm = Send-Pipe @{id=13;cmd='get_active_file'}
        Check 'E4' 'edit large file and read change back' ($mEdit.Value.ok -and $confirm.result.content.EndsWith("E4-EDIT-MARKER`r`n")) ("$($mEdit.Ms) ms")
        Check 'E4' 'IDE remains responsive' ((Send-Pipe @{id=14;cmd='ping'}).ok -and $p.Responding) ("working-set=$([math]::Round($p.WorkingSet64/1MB,1)) MB")
    }

    $null = Send-Pipe @{id=99;cmd='open_project';args=@{path=$e5Vfp}}
    $openSw=[Diagnostics.Stopwatch]::StartNew(); $allOpened=$true
    $id=100
    foreach($path in $docPaths){ $reply=Send-Pipe @{id=$id;cmd='open_in_editor';args=@{path=$path}}; if(-not $reply.ok){$allOpened=$false}; $id++ }
    $openSw.Stop(); $status=Send-Pipe @{id=170;cmd='get_status'}
    $openCount=@($status.result.open_files | Where-Object { $_ -like "$manyDocs*" }).Count
    $p.Refresh()
    Check 'E5' 'open 60 documents simultaneously' ($allOpened -and $openCount -eq 60) ("$openCount open, $($openSw.ElapsedMilliseconds) ms")
    Check 'E5' 'healthy under document load' ((Send-Pipe @{id=171;cmd='ping'}).ok -and $p.Responding) ("handles=$($p.HandleCount), working-set=$([math]::Round($p.WorkingSet64/1MB,1)) MB")

    $mProject=Measure-Call { Send-Pipe @{id=200;cmd='open_project';args=@{path=$vfp}} }
    $mList=Measure-Call { Send-Pipe @{id=201;cmd='list_files'} }
    $fileCount=@($mList.Value.result.files).Count
    Check 'E6' 'open 250-file project' ($mProject.Value.ok -and $fileCount -eq 250) ("open=$($mProject.Ms) ms, list=$($mList.Ms) ms, files=$fileCount")
    Check 'E6' 'IDE remains responsive' ((Send-Pipe @{id=202;cmd='ping'}).ok -and $p.Responding) ("handles=$($p.HandleCount), working-set=$([math]::Round($p.WorkingSet64/1MB,1)) MB")
}
finally {
    if(-not $p.HasExited){ $null=$p.CloseMainWindow(); if(-not $p.WaitForExit(10000)){ Stop-Process -Id $p.Id -Force } }
}

''
$results | Format-Table -AutoSize
foreach($test in 'E4','E5','E6'){ $rows=@($results|Where-Object Test -eq $test); if($rows.Count){ "$test RESULT: $(@($rows|Where-Object Pass).Count)/$($rows.Count)" } }
if(@($results|Where-Object {-not $_.Pass}).Count){exit 1}
