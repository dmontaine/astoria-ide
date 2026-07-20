# Shortcut sweep, pass 2: the commands whose effect pass 1 could not see.
#
# Pass 1 fired every shortcut from a neutral state and asked "did anything change?". For commands
# that need a precondition -- Cut with nothing selected, Redo with nothing to redo, Outdent on an
# unindented line -- "nothing happened" was the CORRECT behaviour, not a failure. Pass 2 sets up
# each precondition and asserts the specific effect.
#
# Two techniques worth knowing:
#   * CARET PROBE. For commands whose only effect is moving the caret (FindNext, bookmark
#     navigation, Define), typing a character afterwards shows where the caret actually landed --
#     the resulting text says whether the command moved it and where to.
#   * MARGIN PIXELS. Bookmarks (F6) and breakpoints (F9) only draw a marker in the editor margin,
#     which no text observable can see, so that strip is screenshotted and compared.

$ErrorActionPreference = 'Stop'
$sp = 'C:\Users\don\AppData\Local\Temp\claude\C--Users-don-Astoria-IDE\a801ea1d-b6dc-48c1-a0aa-a601aa6c8295\scratchpad'
. "$sp\keys.ps1"
Add-Type -AssemblyName System.Drawing

function Send-Pipe([string]$json) {
    $c = New-Object System.IO.Pipes.NamedPipeClientStream('.','AstoriaAgent',[System.IO.Pipes.PipeDirection]::InOut)
    try {
      $c.Connect(5000); $c.ReadMode = [System.IO.Pipes.PipeTransmissionMode]::Byte
      $w = New-Object System.IO.StreamWriter($c,(New-Object System.Text.UTF8Encoding($false))); $w.AutoFlush=$true
      $r = New-Object System.IO.StreamReader($c,(New-Object System.Text.UTF8Encoding($false)))
      $w.WriteLine($json); return $r.ReadLine()
    } catch { return '' } finally { $c.Dispose() }
}
function J([hashtable]$o) { $o | ConvertTo-Json -Compress -Depth 6 }

$root='C:\Users\don\Astoria-IDE'
$proj=Join-Path $root 'Projects\SC_Shortcuts'
$mainPath=Join-Path $proj 'Main.bas'

$p = Get-Process astoria -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $p) { throw "Astoria not running" }
$targetPid=[uint32]$p.Id; $h=$p.MainWindowHandle
"IDE pid=$targetPid`n"

# Open the shortcut project explicitly. Without this the IDE may still be on whatever the saved
# workspace restored -- if that is a .frm, it opens in form view and every click lands on the
# designer surface, so no keystroke reaches a code editor and the whole run reports NO-INSTRUMENT.
$null = Send-Pipe (J @{ id=1; cmd='open_project'; args=@{ path=(Join-Path $proj 'SC_Shortcuts.vfp') } })
Start-Sleep -Seconds 4

$seed = "Print ""alpha""`r`nPrint ""beta""`r`nPrint ""gamma"""

function Reset-Doc([string]$content = $seed) {
  $null = Send-Pipe (J @{ id=98; cmd='write_file'; args=@{ path=$mainPath; content=$content; open=$true } })
  Start-Sleep -Milliseconds 800
}
function Focus-Editor {
  [void][Keys]::SetForegroundWindow($h); Start-Sleep -Milliseconds 600
  if ([Keys]::ForegroundPid() -ne $targetPid) { return $false }
  $rc = New-Object RCT; [void][Keys]::GetWindowRect($h,[ref]$rc)
  [void][Keys]::ClickAt($targetPid, [int]($rc.L+($rc.R-$rc.L)*0.55), [int]($rc.T+($rc.B-$rc.T)*0.35))
  Start-Sleep -Milliseconds 400
  return $true
}
function Txt {
  $r = Send-Pipe (J @{ id=99; cmd='get_active_file' })
  try { return ($r | ConvertFrom-Json).result.content } catch { return '' }
}
function Wins { return ,([Keys]::VisibleWindows($targetPid)) }
function K([string]$s) { return (Send-Shortcut $targetPid $s) }
function T([string]$s) { return (Send-Text $targetPid $s) }

$results=@()
function Rec($name,$key,$verdict,$detail) {
  $script:results += [pscustomobject]@{ Name=$name; Key=$key; Verdict=$verdict; Detail=$detail }
  "{0,-20} {1,-18} {2,-8} {3}" -f $name,$key,$verdict,$detail
}
# Close anything modal that a previous test left up. A modal disables the main window, so every
# keystroke after it silently goes nowhere -- which is how the first run of this script produced a
# page of confident FAILs for Ctrl+A and Ctrl+X.
function Clear-Dialogs([int]$baseline = 1) {
  for ($i = 0; $i -lt 4; $i++) {
    if ((Wins).Count -le $baseline) { return $true }
    $null = K 'Escape'; Start-Sleep -Milliseconds 500
    if ((Wins).Count -le $baseline) { return $true }
    $null = K 'Alt+F4'; Start-Sleep -Milliseconds 800
  }
  return ((Wins).Count -le $baseline)
}

# Prepare: clear dialogs, reset, focus, caret to a known place, THEN prove input still lands.
# Every test calls this, so a dead instrument fails one test loudly instead of poisoning the rest.
function Prep([string]$content = $seed) {
  [void][Keys]::SetForegroundWindow($h); Start-Sleep -Milliseconds 400
  [void](Clear-Dialogs 1)
  Reset-Doc $content
  if (-not (Focus-Editor)) { return $false }
  $null = K 'Ctrl+Home'
  Start-Sleep -Milliseconds 300
  # instrument check: type a char, confirm it lands, undo it
  $b = Txt
  $null = T 'J'; Start-Sleep -Milliseconds 500
  $a = Txt
  if ($a -eq $b) { return $false }        # input is not reaching the editor
  $null = K 'Ctrl+Z'; Start-Sleep -Milliseconds 500
  return $true
}

"=== selection / clipboard ==="
# SelectAll: select everything then type -- the whole document should be replaced by one character.
if (Prep) {
  $null = K 'Ctrl+A'; $null = T 'Z'; Start-Sleep -Milliseconds 600
  $t = Txt
  Rec 'SelectAll' 'Ctrl+A' $(if ($t.Trim() -eq 'Z') {'PASS'} else {'FAIL'}) "doc after select-all + type = '$($t.Trim())'"
} else { Rec 'SelectAll' 'Ctrl+A' 'NO-INSTRUMENT' 'input did not reach the editor' }
# Cut: select all, cut -- document should be empty.
if (Prep) {
  $null = K 'Ctrl+A'; $null = K 'Ctrl+X'; Start-Sleep -Milliseconds 600
  $t = Txt
  Rec 'Cut' 'Ctrl+X' $(if ($t.Trim() -eq '') {'PASS'} else {'FAIL'}) "doc length after cut = $($t.Length)"
}
# Copy+Paste together: select all, copy, go to end, paste -- length should roughly double.
if (Prep) {
  $before = (Txt).Length
  $null = K 'Ctrl+A'; $null = K 'Ctrl+C'; $null = K 'Ctrl+End'; $null = K 'Ctrl+V'
  Start-Sleep -Milliseconds 800
  $after = (Txt).Length
  Rec 'Copy+Paste' 'Ctrl+C / Ctrl+V' $(if ($after -ge $before*1.8) {'PASS'} else {'FAIL'}) "length $before -> $after (expect about double)"
}
# Redo: type, undo, redo -- the character should come back.
if (Prep) {
  $null = T 'Q'; Start-Sleep -Milliseconds 400
  $typed = Txt
  $null = K 'Ctrl+Z'; Start-Sleep -Milliseconds 500
  $undone = Txt
  $null = K 'Ctrl+Shift+Z'; Start-Sleep -Milliseconds 600
  $redone = Txt
  $ok = ($undone -ne $typed) -and ($redone -eq $typed)
  Rec 'Redo' 'Ctrl+Shift+Z' $(if ($ok) {'PASS'} else {'FAIL'}) "typed=$($typed.Length) undone=$($undone.Length) redone=$($redone.Length)"
}

"`n=== indent / comment ==="
# Outdent: indent first, then outdent -- should return to the original text.
if (Prep) {
  $orig = Txt
  $null = K 'Ctrl+A'; $null = K 'Tab'; Start-Sleep -Milliseconds 500
  $indented = Txt
  $null = K 'Shift+Tab'; Start-Sleep -Milliseconds 600
  $out = Txt
  $ok = ($indented -ne $orig) -and ($out -eq $orig)
  Rec 'Outdent' 'Shift+Tab' $(if ($ok) {'PASS'} else {'FAIL'}) "orig=$($orig.Length) indented=$($indented.Length) outdented=$($out.Length)"
}
# BlockComment with a selection.
if (Prep) {
  $orig = Txt
  $null = K 'Ctrl+A'; $null = K 'Ctrl+Alt+I'; Start-Sleep -Milliseconds 700
  $t = Txt
  Rec 'BlockComment' 'Ctrl+Alt+I' $(if ($t -ne $orig) {'PASS'} else {'FAIL'}) "length $($orig.Length) -> $($t.Length)"
}
# Format / Unformat on deliberately messy code.
$messy = "dim   as integer x`r`nfor i as integer=1 to 10`r`nprint i`r`nnext i"
if (Prep $messy) {
  $orig = Txt
  $null = K 'Ctrl+Tab'; Start-Sleep -Milliseconds 900
  $t = Txt
  Rec 'Format' 'Ctrl+Tab' $(if ($t -ne $orig) {'PASS'} else {'NO-EFFECT'}) "length $($orig.Length) -> $($t.Length)"
}
if (Prep $messy) {
  $orig = Txt
  $null = K 'Ctrl+Shift+Tab'; Start-Sleep -Milliseconds 900
  $t = Txt
  Rec 'Unformat' 'Ctrl+Shift+Tab' $(if ($t -ne $orig) {'PASS'} else {'NO-EFFECT'}) "length $($orig.Length) -> $($t.Length)"
}

"`n=== completion popups ==="
# CompleteWord / ParameterInfo: expect either a popup window or an edit to the text.
if (Prep "Print ""alpha""`r`nPri") {
  $null = K 'Ctrl+End'; Start-Sleep -Milliseconds 300
  $w0 = (Wins).Count; $t0 = Txt
  $null = K 'Ctrl+Space'; Start-Sleep -Seconds 2
  $w1 = (Wins).Count; $t1 = Txt
  $ok = ($w1 -gt $w0) -or ($t1 -ne $t0)
  Rec 'CompleteWord' 'Ctrl+Space' $(if ($ok) {'PASS'} else {'NO-EFFECT'}) "windows $w0->$w1, text $($t0.Length)->$($t1.Length)"
  for ($i=0;$i -lt 2 -and (Wins).Count -gt $w0;$i++){ $null=K 'Escape'; Start-Sleep -Milliseconds 400 }
}
if (Prep "Print ""alpha""`r`nMid(") {
  $null = K 'Ctrl+End'; Start-Sleep -Milliseconds 300
  $w0 = (Wins).Count; $t0 = Txt
  $null = K 'Ctrl+J'; Start-Sleep -Seconds 2
  $w1 = (Wins).Count; $t1 = Txt
  $ok = ($w1 -gt $w0) -or ($t1 -ne $t0)
  Rec 'ParameterInfo' 'Ctrl+J' $(if ($ok) {'PASS'} else {'NO-EFFECT'}) "windows $w0->$w1, text $($t0.Length)->$($t1.Length)"
  for ($i=0;$i -lt 2 -and (Wins).Count -gt $w0;$i++){ $null=K 'Escape'; Start-Sleep -Milliseconds 400 }
}

"`n=== save ==="
# Save: dirty the buffer, press Ctrl+S, then read the file FROM DISK (not the editor) to prove the
# save actually reached the filesystem.
if (Prep) {
  $null = K 'Ctrl+End'; $null = T 'W'; Start-Sleep -Milliseconds 500
  $null = K 'Ctrl+S'; Start-Sleep -Seconds 2
  $onDisk = ''
  try { $onDisk = Get-Content $mainPath -Raw } catch {}
  Rec 'Save' 'Ctrl+S' $(if ($onDisk -match 'W') {'PASS'} else {'FAIL'}) "disk file $(if($onDisk -match 'W'){'contains'}else{'does NOT contain'}) the typed character"
}
# SaveProject: touch the project, press Ctrl+Shift+S, check the .vfp write time moves.
if (Prep) {
  $vfp = Join-Path $proj 'SC_Shortcuts.vfp'
  if (Test-Path $vfp) {
    (Get-Item $vfp).LastWriteTime = (Get-Date).AddMinutes(-5)
    $t0 = (Get-Item $vfp).LastWriteTime
    $null = K 'Ctrl+Shift+S'; Start-Sleep -Seconds 2
    $t1 = (Get-Item $vfp).LastWriteTime
    Rec 'SaveProject' 'Ctrl+Shift+S' $(if ($t1 -gt $t0) {'PASS'} else {'NO-EFFECT'}) "vfp mtime $(if($t1 -gt $t0){'advanced'}else{'unchanged'})"
  } else { Rec 'SaveProject' 'Ctrl+Shift+S' 'SKIP' 'no .vfp found' }
}

"`n=== caret-moving commands (caret probe) ==="
# FindNext: open Find, search for gamma, close, then F3 and type -- where the character lands says
# whether the caret moved to the match.
if (Prep) {
  $w0 = (Wins).Count
  $null = K 'Ctrl+F'; Start-Sleep -Seconds 1
  $null = T 'GAMMA'; Start-Sleep -Milliseconds 400
  $null = K 'Enter'; Start-Sleep -Milliseconds 600
  $null = K 'Escape'; Start-Sleep -Milliseconds 600
  for ($i=0;$i -lt 2 -and (Wins).Count -gt $w0;$i++){ $null=K 'Escape'; Start-Sleep -Milliseconds 400 }
  if (-not (Focus-Editor)) { Rec 'FindNext' 'F3' 'NO-FOCUS' 'lost focus after Find' }
  else {
    $before = Txt
    $null = K 'F3'; Start-Sleep -Milliseconds 700
    $null = T 'Z'; Start-Sleep -Milliseconds 600
    $after = Txt
    $moved = ($after -ne $before)
    Rec 'FindNext' 'F3' $(if ($moved) {'CHECK'} else {'NO-EFFECT'}) "text after F3 + type: $((($after -replace "`r`n",' | ')).Trim())"
  }
}
# Define (F2): go to definition -- if it navigates, the active file may change.
if (Prep) {
  $f0 = Send-Pipe (J @{ id=97; cmd='get_active_file' })
  $p0 = try { ($f0 | ConvertFrom-Json).result.path } catch { '' }
  $before = Txt
  $null = K 'F2'; Start-Sleep -Seconds 2
  $f1 = Send-Pipe (J @{ id=96; cmd='get_active_file' })
  $p1 = try { ($f1 | ConvertFrom-Json).result.path } catch { '' }
  $null = T 'Z'; Start-Sleep -Milliseconds 600
  $after = Txt
  $w1def = (Wins).Count
  $ok = ($p1 -ne $p0) -or ($after -ne $before) -or ($w1def -gt 1)
  Rec 'Define' 'F2' $(if ($ok) {'CHECK'} else {'NO-EFFECT'}) "active file $(if($p1 -ne $p0){'changed'}else{'same'}); windows now $w1def; caret probe $(if($after -ne $before){'landed'}else{'no change'})"
}

"`n=== margin markers (pixel comparison) ==="
function Margin-Shot([string]$tag) {
  $rc = New-Object RCT; [void][Keys]::GetWindowRect($h,[ref]$rc)
  # the line-number / marker margin sits just right of the left panel
  $x = [int]($rc.L + ($rc.R-$rc.L)*0.30)
  $y = [int]($rc.T + ($rc.B-$rc.T)*0.16)
  $w = 60; $ht = 160
  $bmp = New-Object System.Drawing.Bitmap $w,$ht
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($x,$y,0,0,(New-Object System.Drawing.Size $w,$ht))
  $path = "$sp\margin_$tag.png"
  $bmp.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  # crude signature: count non-background pixels
  $n = 0
  for ($i=0;$i -lt $w;$i+=2){ for ($j=0;$j -lt $ht;$j+=2){ $c=$bmp.GetPixel($i,$j); if ($c.R+$c.G+$c.B -gt 200) { $n++ } } }
  $bmp.Dispose()
  return $n
}
foreach ($m in @(@{N='ToggleBookmark';K='F6'}, @{N='Breakpoint';K='F9'})) {
  if (Prep) {
    $null = K 'Ctrl+Home'; Start-Sleep -Milliseconds 400
    $b = Margin-Shot "$($m.N)_before"
    $null = K $m.K; Start-Sleep -Seconds 1
    $a = Margin-Shot "$($m.N)_after"
    Rec $m.N $m.K $(if ($a -ne $b) {'PASS'} else {'NO-EFFECT'}) "margin signature $b -> $a"
  }
}

"`n================ PASS 2 SUMMARY ================"
$results | Group-Object Verdict | Sort-Object Count -Descending | ForEach-Object { "{0,-10} {1}" -f $_.Name,$_.Count }
$results | Export-Csv "$sp\shortcut_pass2.csv" -NoTypeInformation
"`nsaved $sp\shortcut_pass2.csv"


