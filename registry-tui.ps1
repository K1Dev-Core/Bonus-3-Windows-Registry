#requires -version 5.1
<#
.SYNOPSIS
  Windows Registry Tricks TUI — ใช้ curl ดึงข้อมูล trick จาก GitHub
.DESCRIPTION
  curl มาแล้วรันเลย:
    powershell -c "iex (curl.exe -sL https://git.io/XXXXX)"
#>

$Version = "1.0"
$RepoRaw = "https://raw.githubusercontent.com/K1Dev-Core/Bonus-3-Windows-Registry/main"
$OutDir = Join-Path (Get-Location) "registry-output"

# ── ใช้ curl ดึง tricks.csv จาก GitHub ──────────────────────────────────
function Get-Tricks {
  Write-Host "`n  ⏳ Downloading tricks list via curl..." -ForegroundColor Yellow
  try {
    $csvRaw = curl.exe -sL "$RepoRaw/tricks.csv"
    if (-not $csvRaw) { throw "Empty response" }
    $lines = $csvRaw -split "`n" | Where-Object { $_ -and $_ -notmatch "^#" }
    $tricks = @()
    foreach ($line in $lines) {
      $parts = $line -split "\|"
      if ($parts.Count -ge 6) {
        $tricks += [PSCustomObject]@{
          ID      = $tricks.Count
          Name    = $parts[0].Trim()
          Desc    = $parts[1].Trim()
          Path    = $parts[2].Trim()
          VName   = $parts[3].Trim()
          VType   = $parts[4].Trim()
          Data    = $parts[5].Trim()
        }
      }
    }
    Write-Host "  ✅ Loaded $($tricks.Count) tricks from GitHub" -ForegroundColor Green
    return $tricks
  }
  catch {
    Write-Host "  ⚠️  curl failed, using embedded fallback..." -ForegroundColor Yellow
    return $null
  }
}

# ── Fallback tricks (built-in) ──────────────────────────────────────────
$FallbackTricks = @()
$FallbackTricks += [PSCustomObject]@{Name="001_disable_usb";     Desc="Disable USB Storage — ป้องกัน Data Exfiltration";           Path="HKLM\SYSTEM\CurrentControlSet\Services\UsbStor";                                          VName="Start";            VType="d"; Data="4"}
$FallbackTricks += [PSCustomObject]@{Name="002_no_controlpanel"; Desc="Hide Control Panel — กัน User Config มั่ว";                    Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                         VName="NoControlPanel";   VType="d"; Data="1"}
$FallbackTricks += [PSCustomObject]@{Name="003_disable_taskmgr"; Desc="Disable Task Manager";                                           Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";                           VName="DisableTaskMgr";   VType="d"; Data="1"}
$FallbackTricks += [PSCustomObject]@{Name="004_disable_cmd";     Desc="Disable Command Prompt";                                         Path="HKCU\Software\Policies\Microsoft\Windows\System";                                          VName="DisableCMD";       VType="d"; Data="1"}
$FallbackTricks += [PSCustomObject]@{Name="005_disable_regedit"; Desc="Disable Registry Editor";                                        Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";                           VName="DisableRegistryTools"; VType="d"; Data="1"}
$FallbackTricks += [PSCustomObject]@{Name="006_disable_autoplay";Desc="Disable AutoRun — ป้องกัน Malware จาก USB";                     Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer";                         VName="NoDriveTypeAutoRun"; VType="d"; Data="255"}
$FallbackTricks += [PSCustomObject]@{Name="007_hide_drive_c";    Desc="Hide Drive C: — ซ่อน C: จาก File Explorer";                    Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                         VName="NoDrives";         VType="d"; Data="4"}
$FallbackTricks += [PSCustomObject]@{Name="008_hide_all_drives"; Desc="Hide ALL Drives — ซ่อนทุก Drive";                                Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                         VName="NoDrives";         VType="d"; Data="67108863"}
$FallbackTricks += [PSCustomObject]@{Name="009_no_desktop";      Desc="Remove Desktop Icons";                                           Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                         VName="NoDesktop";        VType="d"; Data="1"}
$FallbackTricks += [PSCustomObject]@{Name="010_hide_tray";       Desc="Hide System Tray — ซ่อน Notification Area";                     Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                         VName="NoTrayItemsDisplay"; VType="d"; Data="1"}
$FallbackTricks += [PSCustomObject]@{Name="011_login_caption";   Desc="เปลี่ยน Title bar ก่อน Login";                                    Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";                           VName="legalnoticecaption"; VType="s"; Data="⚠️  SYSTEM ALERT ⚠️"}
$FallbackTricks += [PSCustomObject]@{Name="012_login_message";   Desc="เปลี่ยนข้อความก่อน Login — แกล้งเพื่อน";                           Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";                           VName="legalnoticetext";  VType="s"; Data="Hi! Gorgeous! ✨`nOnly beautiful girls can continue."}
$FallbackTricks += [PSCustomObject]@{Name="013_recyclebin";      Desc='เปลี่ยนชื่อ Recycle Bin — "Delete Me If YOU DARE 💀"';            Path="HKCR\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}";                                      VName="@";                VType="s"; Data="Delete Me If YOU DARE 💀"}
$FallbackTricks += [PSCustomObject]@{Name="014_ie_title";        Desc='เปลี่ยน Title Internet Explorer — "👾 HACKED"';                  Path="HKCU\Software\Microsoft\Internet Explorer\Main";                                          VName="Window Title";     VType="s"; Data="👾 HACKED BY P'NONG 👾"}
$FallbackTricks += [PSCustomObject]@{Name="015_registered_owner";Desc="เปลี่ยน Registered Owner";                                        Path="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion";                                       VName="RegisteredOwner";  VType="s"; Data="Mr. Hacker 🏴‍☠️"}
$FallbackTricks += [PSCustomObject]@{Name="016_fast_shutdown";   Desc="Speed up Shutdown — รอแค่ 1 วินาที";                               Path="HKCU\Control Panel\Desktop";                                                               VName="WaitToKillAppTimeout"; VType="d"; Data="1000"}
$FallbackTricks += [PSCustomObject]@{Name="017_menu_speed";      Desc="Menu Show Delay = 0 — เมนูปรุ๊บปรั๊บ";                              Path="HKCU\Control Panel\Desktop";                                                               VName="MenuShowDelay";    VType="d"; Data="0"}

# ── Generate .reg files ─────────────────────────────────────────────────
function Out-RegFile {
  param($Trick, $Apply)
  $dir = if ($Apply) { "apply" } else { "undo" }
  $path = Join-Path $OutDir $dir
  if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }

  $file = Join-Path $path "$($Trick.Name).reg"
  $nl = "`r`n"

  if ($Apply) {
    "@echo off`n" | Out-File -FilePath $file -Encoding ascii
    "REM Windows Registry Trick: $($Trick.Desc)$nl" | Out-File -FilePath $file -Encoding ascii -Append
  }

  if ($Apply) {
    $content = @"
Windows Registry Editor Version 5.00

; $($Trick.Desc)
; Path : $($Trick.Path)

[$($Trick.Path)]
"@
    if ($Trick.VType -eq "d") {
      $content += "$nl`"$($Trick.VName)`"=dword:$($Trick.Data)"
    } else {
      $content += "$nl`"$($Trick.VName)`"=`"$($Trick.Data)`""
    }
  } else {
    $content = @"
Windows Registry Editor Version 5.00

; UNDO — Remove value "$($Trick.VName)"
; Path : $($Trick.Path)

[$($Trick.Path)]
"$($Trick.VName)"=-
"@
  }

  $content | Out-File -FilePath $file -Encoding ascii -Append
  Write-Host "  ✔ $($Trick.Name)" -ForegroundColor Green
}

function Generate-All {
  param($Tricks)
  Write-Host "`n  ========================================" -ForegroundColor Cyan
  Write-Host "     Generating ALL .reg files..."          -ForegroundColor Cyan
  Write-Host "     Output: $OutDir"                       -ForegroundColor Cyan
  Write-Host "  ========================================" -ForegroundColor Cyan
  Write-Host "`n  [Apply]" -ForegroundColor Green
  foreach ($t in $Tricks) { Out-RegFile $t $true }
  Write-Host "`n  [Undo]" -ForegroundColor Yellow
  foreach ($t in $Tricks) { Out-RegFile $t $false }
  Write-Host "`n  ✅ Done!" -ForegroundColor Green
  Write-Host "  apply/ — double-click .reg to apply"
  Write-Host "  undo/  — double-click to revert"
  Write-Host "`n  ⚠️  ALWAYS backup first!" -ForegroundColor Red
  Write-Host "    reg export `"HKCU\Software\Microsoft\Windows\CurrentVersion\Policies`" backup.reg`n"
  Pause
}

function Preview-Trick {
  param($Tricks)
  $idx = Read-Host "`nEnter trick number (0-$($Tricks.Count-1))"
  $t = $Tricks[[int]$idx]
  Clear-Host
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host "  $($t.Name)" -ForegroundColor Cyan
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host "`n  Desc : $($t.Desc)"
  Write-Host "  Path : $($t.Path)"
  Write-Host "  Name : $($t.VName)"
  Write-Host "  Type : $($t.VType)"
  Write-Host "  Data : $($t.Data)"
  Write-Host "`n  Apply: $OutDir\apply\$($t.Name).reg"
  Write-Host "  Undo : $OutDir\undo\$($t.Name).reg"
  Pause
}

function Show-BackupHelp {
  Clear-Host
  Write-Host "========================================" -ForegroundColor Yellow
  Write-Host "         Backup Instructions"            -ForegroundColor Yellow
  Write-Host "========================================" -ForegroundColor Yellow
  Write-Host ""
  Write-Host "  [1] Export Registry Key:"
  Write-Host "    reg export `"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies`" backup.reg"
  Write-Host ""
  Write-Host "  [2] Export single key:"
  Write-Host "    reg export `"HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`" exp.reg"
  Write-Host ""
  Write-Host "  [3] System Restore Point:"
  Write-Host "    System Properties > System Protection > Create"
  Write-Host ""
  Write-Host "  [4] Windows Sandbox / VM (แนะนำ)" -ForegroundColor Green
  Write-Host ""
  Write-Host "  [Restore]"
  Write-Host "    reg import backup.reg"
  Write-Host "    หรือ double-click .reg file"
  Pause
}

function Show-About {
  Clear-Host
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host "           About / Disclaimer"            -ForegroundColor Cyan
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "  Windows Registry Tricks — TUI v$Version" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "  ⚠️  WARNING" -ForegroundColor Red
  Write-Host "  Registry is critical. Incorrect changes may"
  Write-Host "  cause system issues."
  Write-Host ""
  Write-Host "  ✅ Always backup before applying."
  Write-Host "  ✅ Use Windows Sandbox / VM."
  Write-Host ""
  Write-Host "  🎯 Purpose: Educational (Cybersecurity)"
  Write-Host ""
  Write-Host "  📡 Data source: curl from GitHub raw"
  Write-Host "  $RepoRaw/tricks.csv"
  Pause
}

# ── Main ─────────────────────────────────────────────────────────────────
$global:Tricks = Get-Tricks
if (-not $global:Tricks) { $global:Tricks = $FallbackTricks }

while ($true) {
  Clear-Host
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host "    🪟  Windows Registry Tricks"          -ForegroundColor Cyan
  Write-Host "           TUI v$Version — curl edition"   -ForegroundColor Cyan
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "  Total: $($global:Tricks.Count) tricks" -ForegroundColor Yellow
  Write-Host "  Output: $OutDir" -ForegroundColor Gray
  Write-Host ""
  Write-Host "  [1] Generate ALL .reg files (apply + undo)"
  Write-Host "  [2] Preview a trick"
  Write-Host "  [3] Show backup instructions"
  Write-Host "  [4] Change output directory"
  Write-Host "  [5] About / Disclaimer"
  Write-Host "  [0] Exit"
  Write-Host ""
  $opt = Read-Host "Choose [0-5]"

  switch ($opt) {
    "1" { Generate-All $global:Tricks }
    "2" { Preview-Trick $global:Tricks }
    "3" { Show-BackupHelp }
    "4" {
      $new = Read-Host "New output path [$OutDir]"
      if ($new) { $OutDir = $new }
    }
    "5" { Show-About }
    "0" { Write-Host "`nBye!`n"; exit }
  }
}
