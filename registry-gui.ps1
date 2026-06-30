Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Tricks = @(
  [PSCustomObject]@{ID="001";Cat="Security";Name="Disable USB Storage";         Desc="Block USB mass storage";           Path="HKLM\SYSTEM\CurrentControlSet\Services\UsbStor";                       VName="Start";          Type="d"; Data="4"}
  [PSCustomObject]@{ID="002";Cat="Security";Name="Hide Control Panel";           Desc="Remove Control Panel from users";  Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoControlPanel"; Type="d"; Data="1"}
  [PSCustomObject]@{ID="003";Cat="Security";Name="Disable Task Manager";         Desc="Prevent taskman access";           Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";        VName="DisableTaskMgr"; Type="d"; Data="1"}
  [PSCustomObject]@{ID="004";Cat="Security";Name="Disable CMD";                  Desc="Block command prompt";             Path="HKCU\Software\Policies\Microsoft\Windows\System";                       VName="DisableCMD";     Type="d"; Data="1"}
  [PSCustomObject]@{ID="005";Cat="Security";Name="Disable Regedit";              Desc="Block registry editor";            Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";        VName="DisableRegistryTools"; Type="d"; Data="1"}
  [PSCustomObject]@{ID="006";Cat="Security";Name="Disable AutoRun";              Desc="Block autorun infections";         Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDriveTypeAutoRun"; Type="d"; Data="255"}
  [PSCustomObject]@{ID="007";Cat="Hide/Show";Name="Hide Drive C:";               Desc="Hide C: from Explorer";            Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDrives";       Type="d"; Data="4"}
  [PSCustomObject]@{ID="008";Cat="Hide/Show";Name="Hide ALL Drives";             Desc="Hide every drive";                 Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDrives";       Type="d"; Data="67108863"}
  [PSCustomObject]@{ID="009";Cat="Hide/Show";Name="Hide Desktop Icons";          Desc="Clean desktop";                    Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDesktop";      Type="d"; Data="1"}
  [PSCustomObject]@{ID="010";Cat="Hide/Show";Name="Hide System Tray";            Desc="Hide notification area";           Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoTrayItemsDisplay"; Type="d"; Data="1"}
  [PSCustomObject]@{ID="011";Cat="Logon";Name="Login Caption Title";             Desc="Custom login title bar text";      Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";        VName="legalnoticecaption"; Type="s"; Data="SYSTEM ALERT"}
  [PSCustomObject]@{ID="012";Cat="Logon";Name="Login Message Text";              Desc="Custom message before login";      Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";        VName="legalnoticetext"; Type="s"; Data="Welcome"}
  [PSCustomObject]@{ID="013";Cat="Pranks";Name="Rename Recycle Bin";             Desc="Change Recycle Bin name";          Path="HKCR\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}";                    VName="@";               Type="s"; Data="DELETE ME"}
  [PSCustomObject]@{ID="014";Cat="Pranks";Name="Change IE Title";                Desc="Change IE/Edge window title";      Path="HKCU\Software\Microsoft\Internet Explorer\Main";                       VName="Window Title";   Type="s"; Data="HACKED"}
  [PSCustomObject]@{ID="015";Cat="Pranks";Name="Change Registered Owner";        Desc="Change PC owner name";             Path="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion";                     VName="RegisteredOwner"; Type="s"; Data="Mr. Hacker"}
  [PSCustomObject]@{ID="016";Cat="Performance";Name="Fast Shutdown (1s)";        Desc="Shutdown waits only 1 sec";        Path="HKCU\Control Panel\Desktop";                                            VName="WaitToKillAppTimeout"; Type="d"; Data="1000"}
  [PSCustomObject]@{ID="017";Cat="Performance";Name="Menu Delay = 0";            Desc="No menu show delay";               Path="HKCU\Control Panel\Desktop";                                            VName="MenuShowDelay";  Type="d"; Data="0"}
)

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Windows Registry Tricks v2"
$Form.Size = New-Object System.Drawing.Size(680, 520)
$Form.StartPosition = "CenterScreen"
$Form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$List = New-Object System.Windows.Forms.ListBox
$List.Size = New-Object System.Drawing.Size(640, 340)
$List.Location = New-Object System.Drawing.Point(15, 15)
$List.SelectionMode = "MultiExtended"
$List.Font = New-Object System.Drawing.Font("Consolas", 10)
$List.Sorted = $false
$Tricks | ForEach-Object { $null = $List.Items.Add("$($_.ID) | $($_.Cat,-10) | $($_.Name,-22) | $($_.Desc)") }
$Form.Controls.Add($List)

$Lbl = New-Object System.Windows.Forms.Label
$Lbl.Text = "Select items (hold Ctrl or Shift), then click Apply."
$Lbl.Size = New-Object System.Drawing.Size(640, 20)
$Lbl.Location = New-Object System.Drawing.Point(15, 360)
$Form.Controls.Add($Lbl)

function Get-Selected {
  $result = @()
  foreach ($i in $List.SelectedIndices) { $result += $Tricks[$i] }
  return $result
}

$BtnApply = New-Object System.Windows.Forms.Button
$BtnApply.Text = "Apply Selected"
$BtnApply.Size = New-Object System.Drawing.Size(150, 40)
$BtnApply.Location = New-Object System.Drawing.Point(15, 390)
$BtnApply.Add_Click({
  $sel = Get-Selected
  if ($sel.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Select items from the list first.","Error"); return }
  $OutDir = Join-Path ([Environment]::GetFolderPath("Desktop")) "RegistryTricks_$(Get-Date -f yyyyMMdd_HHmmss)"
  $apply = Join-Path $OutDir "apply"
  $undo  = Join-Path $OutDir "undo"
  New-Item -ItemType Directory -Path $apply -Force | Out-Null
  New-Item -ItemType Directory -Path $undo -Force | Out-Null
  foreach ($t in $sel) {
    $c = "Windows Registry Editor Version 5.00`r`n`r`n[$($t.Path)]`r`n"
    if ($t.Type -eq "d") { $c += "`"$($t.VName)`"=dword:$($t.Data)`r`n" }
    else { $c += "`"$($t.VName)`"=`"$($t.Data)`"`r`n" }
    $c | Out-File (Join-Path $apply "$($t.ID).reg") -Encoding ascii
    "Windows Registry Editor Version 5.00`r`n`r`n[$($t.Path)]`r`n`"$($t.VName)`"=-`r`n" | Out-File (Join-Path $undo "$($t.ID)_undo.reg") -Encoding ascii
  }
  [System.Windows.Forms.MessageBox]::Show("Done!`nApply: $apply`nUndo: $undo`n`nDouble-click .reg to apply.","Applied $($sel.Count) tricks")
})

$BtnSelect = New-Object System.Windows.Forms.Button
$BtnSelect.Text = "Select All"
$BtnSelect.Size = New-Object System.Drawing.Size(120, 40)
$BtnSelect.Location = New-Object System.Drawing.Point(175, 390)
$BtnSelect.Add_Click({ $List.SelectedIndices.Clear(); 0..($Tricks.Count-1) | ForEach-Object { $List.SelectedIndices.Add($_) } })

$BtnClear = New-Object System.Windows.Forms.Button
$BtnClear.Text = "Clear"
$BtnClear.Size = New-Object System.Drawing.Size(120, 40)
$BtnClear.Location = New-Object System.Drawing.Point(305, 390)
$BtnClear.Add_Click({ $List.ClearSelected() })

$BtnBackup = New-Object System.Windows.Forms.Button
$BtnBackup.Text = "Backup"
$BtnBackup.Size = New-Object System.Drawing.Size(100, 40)
$BtnBackup.Location = New-Object System.Drawing.Point(435, 390)
$BtnBackup.Add_Click({
  $dir = Join-Path ([Environment]::GetFolderPath("Desktop")) "RegistryBackup_$(Get-Date -f yyyyMMdd_HHmmss)"
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
  "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer","HKCU\Control Panel\Desktop","HKLM\SYSTEM\CurrentControlSet\Services\UsbStor" | ForEach-Object {
    $f = Join-Path $dir ($_ -replace '\\','_') + ".reg"
    reg export $_ $f 2>$null
  }
  [System.Windows.Forms.MessageBox]::Show("Backup saved to:`n$dir","Done")
})

$BtnExit = New-Object System.Windows.Forms.Button
$BtnExit.Text = "Exit"
$BtnExit.Size = New-Object System.Drawing.Size(100, 40)
$BtnExit.Location = New-Object System.Drawing.Point(545, 390)
$BtnExit.Add_Click({ $Form.Close() })

$Form.Controls.Add($BtnApply)
$Form.Controls.Add($BtnSelect)
$Form.Controls.Add($BtnClear)
$Form.Controls.Add($BtnBackup)
$Form.Controls.Add($BtnExit)

$Form.ShowDialog()
