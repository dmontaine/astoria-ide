# Shortcut sweep: fire each shortcut defined in Settings/Others/HotKeys.txt with real synthesized
# input and record whether ANYTHING observably happened.
#
# For each shortcut, snapshot (editor text, visible top-level windows), send it, snapshot again:
#   WINDOW   a dialog/window appeared      -> the command ran
#   TEXT     the editor buffer changed     -> the command ran
#   NONE     neither                       -> candidate failure, needs a look
# NONE is not automatically a defect (some commands legitimately change neither), which is why the
# output separates "no observable effect" from "verified working" instead of calling NONE a fail.
#
# Destructive shortcuts are excluded by name and listed at the end for manual testing -- firing
# Exit or Close mid-sweep would end the run.

param([string]$Only = '')

$ErrorActionPreference = 'Stop'
$sp = 'C:\Users\don\AppData\Local\Temp\claude\C--Users-don-Astoria-IDE\a801ea1d-b6dc-48c1-a0aa-a601aa6c8295\scratchpad'
. "$sp\keys.ps1"

function Send-Pipe([string]$json) {
    $c = New-Object System.IO.Pipes.NamedPipeClientStream('.','AstoriaAgent',[System.IO.Pipes.PipeDirection]::InOut)
    try {
      $c.Connect(5000); $c.ReadMode = [System.IO.Pipes.PipeTransmissionMode]::Byte
      $w = New-Object System.IO.StreamWriter($c,(New-Object System.Text.UTF8Encoding($false))); $w.AutoFlush = $true
      $r = New-Object System.IO.StreamReader($c,(New-Object System.Text.UTF8Encoding($false)))
      $w.WriteLine($json); return $r.ReadLine()
    } catch { return '' } finally { $c.Dispose() }
}
function J([hashtable]$o) { $o | ConvertTo-Json -Compress -Depth 6 }

$root = 'C:\Users\don\Astoria-IDE'
$hkFile = Join-Path $root 'Settings\Others\HotKeys.txt'
$proj = Join-Path $root 'Projects\SC_Shortcuts'
$mainPath = Join-Path $proj 'Main.bas'

# Shortcuts that would end or derail the sweep. Tested by hand instead.
$destructive = @('Exit','Close','CloseProject','SaveAll','SaveSession','OpenSession','Print',
                 'CommandPrompt','StartWithCompile','Start','Restart','Break','Compile',
                 'StepInto','StepOver','StepOut','RunToCursor','ClearAllBreakpoints','Content')

$p = Get-Process astoria -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $p) { throw "Astoria is not running." }
$targetPid = [uint32]$p.Id
$h = $p.MainWindowHandle
"IDE pid=$targetPid"

# Parse HotKeys.txt
$shortcuts = @()
foreach ($line in Get-Content $hkFile) {
  if ($line -match '^\s*([A-Za-z0-9_]+)\s*=\s*(.+?)\s*$') {
    $shortcuts += [pscustomobject]@{ Name = $Matches[1]; Key = $Matches[2] }
  }
}
if ($Only) { $shortcuts = $shortcuts | Where-Object { $_.Name -like $Only } }
"parsed $($shortcuts.Count) assigned shortcuts"

function Focus-Editor {
  [void][Keys]::SetForegroundWindow($h); Start-Sleep -Milliseconds 600
  if ([Keys]::ForegroundPid() -ne $targetPid) { return $false }
  $rc = New-Object RCT; [void][Keys]::GetWindowRect($h, [ref]$rc)
  $cx = [int]($rc.L + ($rc.R - $rc.L) * 0.55)
  $cy = [int]($rc.T + ($rc.B - $rc.T) * 0.35)
  [void][Keys]::ClickAt($targetPid, $cx, $cy)
  Start-Sleep -Milliseconds 400
  return $true
}
function Get-EditorText {
  $r = Send-Pipe (J @{ id=99; cmd='get_active_file' })
  try { return ($r | ConvertFrom-Json).result.content } catch { return '' }
}
function Get-Wins { return ,([Keys]::VisibleWindows($targetPid)) }

# Reset the document to a known state between tests, so one command's edit cannot be read as the
# next command's effect.
$seed = "Print ""alpha""`r`nPrint ""beta""`r`nPrint ""gamma"""
function Reset-Doc {
  $null = Send-Pipe (J @{ id=98; cmd='write_file'; args=@{ path=$mainPath; content=$seed; open=$true } })
  Start-Sleep -Milliseconds 700
}

# Dismiss anything that opened, so the next test starts clean. E9 established Escape does not
# always close Astoria's dialogs, so Alt+F4 is the fallback and the close is verified.
function Dismiss-Extra([int]$baseCount) {
  for ($attempt = 1; $attempt -le 3; $attempt++) {
    $w = Get-Wins
    if ($w.Count -le $baseCount) { return $true }
    if ([Keys]::ForegroundPid() -eq $targetPid) {
      $null = Send-Shortcut $targetPid 'Escape'
      Start-Sleep -Milliseconds 400
      $w = Get-Wins
      if ($w.Count -le $baseCount) { return $true }
      $null = Send-Shortcut $targetPid 'Alt+F4'
      Start-Sleep -Milliseconds 700
    }
  }
  return ((Get-Wins).Count -le $baseCount)
}

$results = @()
Reset-Doc
if (-not (Focus-Editor)) { throw "cannot focus Astoria; refusing to send input" }
$baseWins = (Get-Wins).Count
"baseline visible windows = $baseWins"

# In-run instrument check: with the caret where the sweep will put it, does a keystroke actually
# reach the editor? Without this, a run of NONE results is ambiguous between "the shortcuts do not
# work" and "nothing was listening" -- and the first trial run produced exactly that ambiguity,
# because the document was reset AFTER focusing, which dropped focus before the key was sent.
$probeBefore = Get-EditorText
$null = Send-Text $targetPid 'Q'
Start-Sleep -Milliseconds 600
$probeAfter = Get-EditorText
if ($probeAfter -eq $probeBefore) {
  throw "INSTRUMENT DEAD: a typed character did not reach the editor. Every NONE below would be meaningless. Fix focus before trusting any result."
}
"instrument check OK - a typed character reaches the editor ($($probeBefore.Length) -> $($probeAfter.Length))"
""

foreach ($s in $shortcuts) {
  if ($destructive -contains $s.Name) {
    $results += [pscustomobject]@{ Name=$s.Name; Key=$s.Key; Effect='SKIPPED'; Note='destructive/stateful - manual' }
    continue
  }
  # Reset FIRST, then focus -- write_file reloads the document and drops editor focus, so focusing
  # before the reset sends the keystroke into a pane that is no longer listening.
  Reset-Doc
  if (-not (Focus-Editor)) {
    $results += [pscustomobject]@{ Name=$s.Name; Key=$s.Key; Effect='NO-FOCUS'; Note='refused to send' }
    continue
  }
  $txtBefore = Get-EditorText
  $winsBefore = (Get-Wins).Count

  $sent = Send-Shortcut $targetPid $s.Key
  Start-Sleep -Milliseconds 700

  if ($sent -ne 'SENT') {
    $results += [pscustomobject]@{ Name=$s.Name; Key=$s.Key; Effect=$sent; Note='not sent' }
    continue
  }

  $winsAfter = (Get-Wins).Count
  $txtAfter = Get-EditorText
  $effect = 'NONE'; $note = ''
  if ($winsAfter -gt $winsBefore) {
    $effect = 'WINDOW'
    $new = (Get-Wins) | Select-Object -Last 1
    $note = "$($winsAfter-$winsBefore) new window(s): $new"
  } elseif ($txtAfter -ne $txtBefore) {
    $effect = 'TEXT'
    $note = "editor text changed ($($txtBefore.Length) -> $($txtAfter.Length) chars)"
  }
  $results += [pscustomobject]@{ Name=$s.Name; Key=$s.Key; Effect=$effect; Note=$note }
  "{0,-22} {1,-22} {2,-8} {3}" -f $s.Name, $s.Key, $effect, $note

  if (-not (Dismiss-Extra $baseWins)) {
    "  !! could not dismiss windows opened by $($s.Name); stopping to avoid a wedged run"
    break
  }
}

""
"================ SUMMARY ================"
$results | Group-Object Effect | Sort-Object Count -Descending | ForEach-Object { "{0,-10} {1}" -f $_.Name, $_.Count }
""
"---- no observable effect (need a closer look) ----"
$results | Where-Object { $_.Effect -eq 'NONE' } | ForEach-Object { "  {0,-22} {1}" -f $_.Name, $_.Key }
$results | Export-Csv "$sp\shortcut_results.csv" -NoTypeInformation
"`nsaved $sp\shortcut_results.csv"
