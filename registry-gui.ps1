Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Tricks = @(
  [PSCustomObject]@{ID="001";Cat="Security";Name="Disable USB Storage";         Desc="Block USB mass storage";                                Path="HKLM\SYSTEM\CurrentControlSet\Services\UsbStor";                       VName="Start";          Type="d"; Data="4"}
  [PSCustomObject]@{ID="002";Cat="Security";Name="Hide Control Panel";           Desc="Remove Control Panel from users";                        Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoControlPanel"; Type="d"; Data="1"}
  [PSCustomObject]@{ID="003";Cat="Security";Name="Disable Task Manager";         Desc="Prevent taskman access";                                  Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";        VName="DisableTaskMgr"; Type="d"; Data="1"}
  [PSCustomObject]@{ID="004";Cat="Security";Name="Disable CMD";                  Desc="Block command prompt";                                   Path="HKCU\Software\Policies\Microsoft\Windows\System";                       VName="DisableCMD";     Type="d"; Data="1"}
  [PSCustomObject]@{ID="005";Cat="Security";Name="Disable Regedit";              Desc="Block registry editor";                                  Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";        VName="DisableRegistryTools"; Type="d"; Data="1"}
  [PSCustomObject]@{ID="006";Cat="Security";Name="Disable AutoRun";              Desc="Block autorun infections";                               Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDriveTypeAutoRun"; Type="d"; Data="255"}
  [PSCustomObject]@{ID="007";Cat="Hide/Show";Name="Hide Drive C:";               Desc="Hide C: from Explorer";                                  Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDrives";       Type="d"; Data="4"}
  [PSCustomObject]@{ID="008";Cat="Hide/Show";Name="Hide ALL Drives";             Desc="Hide every drive";                                       Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDrives";       Type="d"; Data="67108863"}
  [PSCustomObject]@{ID="009";Cat="Hide/Show";Name="Hide Desktop Icons";          Desc="Clean desktop";                                          Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoDesktop";      Type="d"; Data="1"}
  [PSCustomObject]@{ID="010";Cat="Hide/Show";Name="Hide System Tray";            Desc="Hide notification area";                                 Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";      VName="NoTrayItemsDisplay"; Type="d"; Data="1"}
  [PSCustomObject]@{ID="011";Cat="Logon";Name="Login Caption Title";             Desc="Custom login title bar text";                            Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";        VName="legalnoticecaption"; Type="s"; Data="SYSTEM ALERT"}
  [PSCustomObject]@{ID="012";Cat="Logon";Name="Login Message Text";              Desc="Custom message before login";                            Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";        VName="legalnoticetext"; Type="s"; Data="Welcome"}
  [PSCustomObject]@{ID="013";Cat="Pranks";Name="Rename Recycle Bin";             Desc="Change Recycle Bin name";                                Path="HKCR\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}";                    VName="@";               Type="s"; Data="DELETE ME"}
  [PSCustomObject]@{ID="014";Cat="Pranks";Name="Change IE Title";                Desc="Change IE/Edge window title";                            Path="HKCU\Software\Microsoft\Internet Explorer\Main";                       VName="Window Title";   Type="s"; Data="HACKED"}
  [PSCustomObject]@{ID="015";Cat="Pranks";Name="Change Registered Owner";        Desc="Change PC owner name";                                   Path="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion";                     VName="RegisteredOwner"; Type="s"; Data="Mr. Hacker"}
  [PSCustomObject]@{ID="016";Cat="Performance";Name="Fast Shutdown (1s)";        Desc="Shutdown waits only 1 sec";                              Path="HKCU\Control Panel\Desktop";                                            VName="WaitToKillAppTimeout"; Type="d"; Data="1000"}
  [PSCustomObject]@{ID="017";Cat="Performance";Name="Menu Delay = 0";            Desc="No menu show delay";                                     Path="HKCU\Control Panel\Desktop";                                            VName="MenuShowDelay";  Type="d"; Data="0"}
)

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Windows Registry Tricks"
$Form.Size = New-Object System.Drawing.Size(700, 600)
$Form.StartPosition = "CenterScreen"
$Form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$CheckPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$CheckPanel.Size = New-Object System.Drawing.Size(670, 400)
$CheckPanel.Location = New-Object System.Drawing.Point(10, 10)
$CheckPanel.AutoScroll = $true

$Checkboxes = @{}
$Categories = $Tricks | Group-Object Cat

foreach ($Cat in $Categories) {
  $CatLabel = New-Object System.Windows.Forms.Label
  $CatLabel.Text = "--- $($Cat.Name) ($($Cat.Count)) ---"
  $CatLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
  $CatLabel.Size = New-Object System.Drawing.Size(650, 22)
  $CatLabel.Margin = New-Object System.Windows.Forms.Padding(0, 8, 0, 2)
  $CheckPanel.Controls.Add($CatLabel)

  foreach ($Trick in $Cat.Group) {
    $CB = New-Object System.Windows.Forms.CheckBox
    $CB.Text = "$($Trick.ID). $($Trick.Name)  —  $($Trick.Desc)"
    $CB.Size = New-Object System.Drawing.Size(650, 24)
    $CB.Margin = New-Object System.Windows.Forms.Padding(10, 1, 0, 1)
    $CB.Tag = $Trick.ID
    $Checkboxes[$Trick.ID] = $CB
    $CheckPanel.Controls.Add($CB)
  }
}

$Form.Controls.Add($CheckPanel)

$BtnApply = New-Object System.Windows.Forms.Button
$BtnApply.Text = "Apply Selected"
$BtnApply.Size = New-Object System.Drawing.Size(160, 40)
$BtnApply.Location = New-Object System.Drawing.Point(10, 420)
$BtnApply.Add_Click({
  $selected = $Tricks | Where-Object { $Checkboxes[$_.ID].Checked }
  if ($selected.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Select at least one trick","Error"); return }
  $OutDir = Join-Path ([Environment]::GetFolderPath("Desktop")) "RegistryTricks_$(Get-Date -f yyyyMMdd_HHmmss)"
  $apply = Join-Path $OutDir "apply"
  $undo  = Join-Path $OutDir "undo"
  New-Item -ItemType Directory -Path $apply -Force | Out-Null
  New-Item -ItemType Directory -Path $undo -Force | Out-Null
  foreach ($t in $selected) {
    $content = "Windows Registry Editor Version 5.00`r`n`r`n[$($t.Path)]`r`n"
    if ($t.Type -eq "d") { $content += "`"$($t.VName)`"=dword:$($t.Data)`r`n" }
    else { $content += "`"$($t.VName)`"=`"$($t.Data)`"`r`n" }
    $content | Out-File (Join-Path $apply "$($t.ID).reg") -Encoding ascii
    "Windows Registry Editor Version 5.00`r`n`r`n[$($t.Path)]`r`n`"$($t.VName)`"=-`r`n" | Out-File (Join-Path $undo "$($t.ID)_undo.reg") -Encoding ascii
  }
  [System.Windows.Forms.MessageBox]::Show("Done!`nApply: $apply`nUndo: $undo`n`nDouble-click .reg files to apply.","Applied $($selected.Count) tricks")
})

$BtnSelectAll = New-Object System.Windows.Forms.Button
$BtnSelectAll.Text = "Select All"
$BtnSelectAll.Size = New-Object System.Drawing.Size(120, 40)
$BtnSelectAll.Location = New-Object System.Drawing.Point(180, 420)
$BtnSelectAll.Add_Click({ foreach ($cb in $Checkboxes.Values) { $cb.Checked = $true } })

$BtnDeselect = New-Object System.Windows.Forms.Button
$BtnDeselect.Text = "Deselect All"
$BtnDeselect.Size = New-Object System.Drawing.Size(120, 40)
$BtnDeselect.Location = New-Object System.Drawing.Point(310, 420)
$BtnDeselect.Add_Click({ foreach ($cb in $Checkboxes.Values) { $cb.Checked = $false } })

$BtnBackup = New-Object System.Windows.Forms.Button
$BtnBackup.Text = "Backup Registry"
$BtnBackup.Size = New-Object System.Drawing.Size(140, 40)
$BtnBackup.Location = New-Object System.Drawing.Point(440, 420)
$BtnBackup.Add_Click({
  $dir = Join-Path ([Environment]::GetFolderPath("Desktop")) "RegistryBackup_$(Get-Date -f yyyyMMdd_HHmmss)"
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
  "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer","HKCU\Control Panel\Desktop","HKLM\SYSTEM\CurrentControlSet\Services\UsbStor" | ForEach-Object {
    $f = Join-Path $dir ($_ -replace '\\','_') + ".reg"
    reg export $_ $f 2>$null
  }
  [System.Windows.Forms.MessageBox]::Show("Backup saved to:`n$dir","Backup Done")
})

$BtnExit = New-Object System.Windows.Forms.Button
$BtnExit.Text = "Exit"
$BtnExit.Size = New-Object System.Drawing.Size(100, 40)
$BtnExit.Location = New-Object System.Drawing.Point(590, 420)
$BtnExit.Add_Click({ $Form.Close() })

$Form.Controls.Add($BtnApply)
$Form.Controls.Add($BtnSelectAll)
$Form.Controls.Add($BtnDeselect)
$Form.Controls.Add($BtnBackup)
$Form.Controls.Add($BtnExit)

$Form.ShowDialog()
