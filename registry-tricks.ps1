$Tricks = @(
  [PSCustomObject]@{ID="001";Cat="Security";Name="Disable USB Storage";         Path="HKLM\SYSTEM\CurrentControlSet\Services\UsbStor";                       VName="Start";          Type="d"; Data="4";  Orig="3"}
  [PSCustomObject]@{ID="002";Cat="Security";Name="Hide Control Panel";           Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoControlPanel"; Type="d"; Data="1";  Orig=""}
  [PSCustomObject]@{ID="003";Cat="Security";Name="Disable Task Manager";         Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";        VName="DisableTaskMgr"; Type="d"; Data="1";  Orig=""}
  [PSCustomObject]@{ID="004";Cat="Security";Name="Disable CMD";                  Path="HKCU\Software\Policies\Microsoft\Windows\System";                       VName="DisableCMD";     Type="d"; Data="1";  Orig=""}
  [PSCustomObject]@{ID="005";Cat="Security";Name="Disable Regedit";              Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";        VName="DisableRegistryTools"; Type="d"; Data="1";  Orig=""}
  [PSCustomObject]@{ID="006";Cat="Security";Name="Disable AutoRun";              Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDriveTypeAutoRun"; Type="d"; Data="255"; Orig=""}
  [PSCustomObject]@{ID="007";Cat="Hide/Show";Name="Hide Drive C";                Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDrives";       Type="d"; Data="4";  Orig=""}
  [PSCustomObject]@{ID="008";Cat="Hide/Show";Name="Hide All Drives";             Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDrives";       Type="d"; Data="67108863"; Orig=""}
  [PSCustomObject]@{ID="009";Cat="Hide/Show";Name="Hide Desktop Icons";          Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDesktop";      Type="d"; Data="1";  Orig=""}
  [PSCustomObject]@{ID="010";Cat="Hide/Show";Name="Hide System Tray";            Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoTrayItemsDisplay"; Type="d"; Data="1"; Orig=""}
  [PSCustomObject]@{ID="011";Cat="Logon";Name="Login Caption Title";             Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";        VName="legalnoticecaption"; Type="s"; Data="Alert"; Orig=""}
  [PSCustomObject]@{ID="012";Cat="Logon";Name="Login Message Text";              Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";        VName="legalnoticetext"; Type="s"; Data="Welcome"; Orig=""}
  [PSCustomObject]@{ID="013";Cat="Pranks";Name="Rename Recycle Bin";             Path="HKCR\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}";                    VName="";                Type="s"; Data="DELETEME"; Orig=""}
  [PSCustomObject]@{ID="014";Cat="Pranks";Name="Change IE Title";                Path="HKCU\Software\Microsoft\Internet Explorer\Main";                       VName="Window Title";   Type="s"; Data="My Browser"; Orig=""}
  [PSCustomObject]@{ID="015";Cat="Pranks";Name="Change Registered Owner";        Path="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion";                     VName="RegisteredOwner"; Type="s"; Data="Admin"; Orig=""}
  [PSCustomObject]@{ID="016";Cat="Performance";Name="Fast Shutdown (1s)";        Path="HKCU\Control Panel\Desktop";                                            VName="WaitToKillAppTimeout"; Type="d"; Data="1000"; Orig="5000"}
  [PSCustomObject]@{ID="017";Cat="Performance";Name="Menu Delay 0";              Path="HKCU\Control Panel\Desktop";                                            VName="MenuShowDelay";  Type="d"; Data="0";  Orig="400"}
)

$sel = @{}

function Show-Menu {
  Clear-Host
  Write-Host "============================================" -ForegroundColor Cyan
  Write-Host "      Windows Registry Tricks Tool" -ForegroundColor Cyan
  Write-Host "============================================" -ForegroundColor Cyan
  $c = ""
  $i = 0
  foreach ($t in $Tricks) {
    if ($t.Cat -ne $c) { $c = $t.Cat; Write-Host "`n--- $c ---" -ForegroundColor Yellow }
    $m = if ($sel.ContainsKey($i)) { "X" } else { " " }
    Write-Host " [$m] $($t.ID) $($t.Name)" -NoNewline
    Write-Host "  ($($t.Desc))" -ForegroundColor DarkGray
    $i++
  }
  Write-Host "`nSelected: $($sel.Count) item(s)" -ForegroundColor $(if($sel.Count-gt0){'Green'}else{'Gray'})
}

function Get-VName($t) {
  if ($t.VName) { "/v $($t.VName)" } else { "/ve" }
}

function View-Item($i) {
  $t = $Tricks[$i]
  $vf = Get-VName $t
  $val = reg query $t.Path $vf 2>$null | Out-String
  $m = [regex]::Match($val, "REG_\w+\s+(.*)")
  $vn = if ($t.VName) { $t.VName } else { "(Default)" }
  Write-Host "$($t.Path) [$vn]" -ForegroundColor Cyan
  if ($m.Success) { Write-Host "  Current: $($m.Groups[1].Value)" -ForegroundColor Green }
  else { Write-Host "  Current: (not set)" -ForegroundColor Yellow }
  Write-Host "  New: $($t.Data)" -ForegroundColor White
  if ($t.Orig) { Write-Host "  Original: $($t.Orig)" -ForegroundColor Magenta }
  else { Write-Host "  Original: (delete to restore)" -ForegroundColor Magenta }
}

function Apply-Trick($t) {
  $vf = Get-VName $t
  if ($t.Type -eq "d") { $cmd = "reg add `"$($t.Path)`" $vf /t REG_DWORD /d $($t.Data) /f" }
  else { $cmd = "reg add `"$($t.Path)`" $vf /t REG_SZ /d `"$($t.Data)`" /f" }
  cmd /c $cmd 2>$null | Out-Null
  return $LASTEXITCODE -eq 0
}

function Restore-Trick($t) {
  if ($t.Orig) {
    $vf = Get-VName $t
    if ($t.Type -eq "d") { $cmd = "reg add `"$($t.Path)`" $vf /t REG_DWORD /d $($t.Orig) /f" }
    else { $cmd = "reg add `"$($t.Path)`" $vf /t REG_SZ /d `"$($t.Orig)`" /f" }
    cmd /c $cmd 2>$null | Out-Null
  } else {
    if ($t.VName) { $cmd = "reg delete `"$($t.Path)`" /v $($t.VName) /f" }
    else { $cmd = "reg delete `"$($t.Path)`" /ve /f" }
    cmd /c $cmd 2>$null | Out-Null
  }
  return $LASTEXITCODE -eq 0
}

while ($true) {
  Show-Menu
  $ans = Read-Host "`n(num=toggle, a=apply, r=restore, ra=restore-all, b=backup, v#=view, all, none, q=quit)"

  switch -r ($ans.ToLower().Trim()) {
    "^q$" { exit }
    "^a$" {
      if ($sel.Count -eq 0) { Write-Host "Nothing selected!" -ForegroundColor Red; pause; break }
      $ok = 0; $fail = 0
      foreach ($i in $sel.Keys) { if (Apply-Trick $Tricks[$i]) { $ok++ } else { $fail++ } }
      Write-Host "Applied: $ok / $($sel.Count)" -ForegroundColor $(if ($fail -eq 0){'Green'}else{'Yellow'})
      pause; break
    }
    "^ra$" {
      $ok = 0; $fail = 0
      0..($Tricks.Count-1) | ForEach-Object { if (Restore-Trick $Tricks[$_]) { $ok++ } else { $fail++ } }
      Write-Host "Restored: $ok / $($Tricks.Count)" -ForegroundColor $(if ($fail -eq 0){'Green'}else{'Yellow'})
      pause; break
    }
    "^r$" {
      if ($sel.Count -eq 0) { Write-Host "Nothing selected!" -ForegroundColor Red; pause; break }
      $ok = 0; $fail = 0
      foreach ($i in $sel.Keys) { if (Restore-Trick $Tricks[$i]) { $ok++ } else { $fail++ } }
      Write-Host "Restored: $ok / $($sel.Count)" -ForegroundColor $(if ($fail -eq 0){'Green'}else{'Yellow'})
      pause; break
    }
    "^b$" {
      $dir = Join-Path ([Environment]::GetFolderPath("Desktop")) "Backup_$(Get-Date -f yyyyMMdd_HHmmss)"
      New-Item -ItemType Directory -Path $dir -Force | Out-Null
      "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer","HKCU\Control Panel\Desktop","HKLM\SYSTEM\CurrentControlSet\Services\UsbStor","HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | ForEach-Object {
        $f = Join-Path $dir (($_ -replace '\\','_') + ".reg")
        reg export $_ $f 2>$null
      }
      Write-Host "Backup saved to: $dir" -ForegroundColor Green
      pause; break
    }
    "^v(\d+)$" { View-Item ([int]$matches[1]-1); pause; break }
    "^all$" { for ($i=0;$i -lt $Tricks.Count;$i++) { $sel[$i] = $true }; break }
    "^none$" { $sel.Clear(); break }
    "^(\d+)-(\d+)$" {
      $a = [int]$matches[1]; $b = [int]$matches[2]
      if ($a -gt $b) { $a,$b = $b,$a }
      for ($n=$a;$n -le $b;$n++) { if ($n -ge 1 -and $n -le $Tricks.Count) { $sel[$n-1] = -not $sel[$n-1] } }
      break
    }
    "^\d+$" {
      $n = [int]$_
      if ($n -ge 1 -and $n -le $Tricks.Count) { $sel[$n-1] = -not $sel[$n-1] }
      break
    }
    "^[\d,\s]+$" {
      [regex]::Matches($_, '\d+') | ForEach-Object {
        $n = [int]$_.Value
        if ($n -ge 1 -and $n -le $Tricks.Count) { $sel[$n-1] = -not $sel[$n-1] }
      }
      break
    }
    default { Write-Host "Invalid: $ans" -ForegroundColor Red; pause }
  }
}
