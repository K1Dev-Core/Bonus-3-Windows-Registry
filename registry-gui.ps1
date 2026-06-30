#requires -version 5.1
<#
.SYNOPSIS
  Windows Registry Tricks — GUI (WinForms)
  ครบทุกเมนูที่อาจารย์สั่ง ใช้ง่าย จิ้มแล้ว Apply ได้เลย
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ── 17 Tricks ───────────────────────────────────────────────────────────
$Tricks = @(
  # Security
  [PSCustomObject]@{ID="001";Cat="🔒 Security";Name="Disable USB Storage";         Desc="ป้องกัน Data Exfiltration + Malware จาก USB";            Path="HKLM\SYSTEM\CurrentControlSet\Services\UsbStor";                                           VName="Start";           Type="d"; Data="4"; Checked=$false}
  [PSCustomObject]@{ID="002";Cat="🔒 Security";Name="Hide Control Panel";           Desc="กัน User ไป Config มั่ว";                                 Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                        VName="NoControlPanel";  Type="d"; Data="1"; Checked=$false}
  [PSCustomObject]@{ID="003";Cat="🔒 Security";Name="Disable Task Manager";         Desc="ป้องกัน Kill Process / ปิดโปรแกรม";                         Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";                          VName="DisableTaskMgr";  Type="d"; Data="1"; Checked=$false}
  [PSCustomObject]@{ID="004";Cat="🔒 Security";Name="Disable Command Prompt";       Desc="ป้องกันใช้ Command Line";                                    Path="HKCU\Software\Policies\Microsoft\Windows\System";                                         VName="DisableCMD";      Type="d"; Data="1"; Checked=$false}
  [PSCustomObject]@{ID="005";Cat="🔒 Security";Name="Disable Registry Editor";      Desc="ป้องกันแก้ Registry ต่อ";                                     Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System";                          VName="DisableRegistryTools"; Type="d"; Data="1"; Checked=$false}
  [PSCustomObject]@{ID="006";Cat="🔒 Security";Name="Disable AutoRun";              Desc="ป้องกัน AutoRun Malware จาก USB แฟลชไดรฟ์";                  Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer";                        VName="NoDriveTypeAutoRun"; Type="d"; Data="255"; Checked=$false}
  # Hide / Show
  [PSCustomObject]@{ID="007";Cat="👁️  Hide/Show";Name="Hide Drive C:";             Desc="ซ่อน Drive C: จาก File Explorer";                            Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                        VName="NoDrives";        Type="d"; Data="4"; Checked=$false}
  [PSCustomObject]@{ID="008";Cat="👁️  Hide/Show";Name="Hide ALL Drives";           Desc="ซ่อนทุก Drive ไม่เห็นเลย";                                    Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                        VName="NoDrives";        Type="d"; Data="67108863"; Checked=$false}
  [PSCustomObject]@{ID="009";Cat="👁️  Hide/Show";Name="Remove Desktop Icons";      Desc="ซ่อน Desktop โล่งเตียน";                                      Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                        VName="NoDesktop";       Type="d"; Data="1"; Checked=$false}
  [PSCustomObject]@{ID="010";Cat="👁️  Hide/Show";Name="Hide System Tray";          Desc="ซ่อน Notification Area แถบ Taskbar";                           Path="HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer";                        VName="NoTrayItemsDisplay"; Type="d"; Data="1"; Checked=$false}
  # Logon
  [PSCustomObject]@{ID="011";Cat="📋 Logon";Name="Login Caption — Title Bar";       Desc="เปลี่ยนข้อความบน Title Bar ก่อน Login";                       Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";                          VName="legalnoticecaption"; Type="s"; Data="⚠️  SYSTEM ALERT ⚠️"; Checked=$false}
  [PSCustomObject]@{ID="012";Cat="📋 Logon";Name="Login Message — ข้อความต้อนรับ";  Desc="เปลี่ยนข้อความก่อน Login แบบกวนๆ";                            Path="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System";                          VName="legalnoticetext"; Type="s"; Data="Hi! Gorgeous! ✨`nOnly beautiful girls can continue."; Checked=$false}
  # Pranks
  [PSCustomObject]@{ID="013";Cat="😂 Pranks";Name="Rename Recycle Bin";             Desc='เปลี่ยนชื่อถังขยะเป็น "Delete Me If YOU DARE 💀"';           Path="HKCR\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}";                                      VName="@";               Type="s"; Data="Delete Me If YOU DARE 💀"; Checked=$false}
  [PSCustomObject]@{ID="014";Cat="😂 Pranks";Name="Change IE/Edge Title";           Desc='เปลี่ยน Title Browser เป็น "👾 HACKED"';                     Path="HKCU\Software\Microsoft\Internet Explorer\Main";                                          VName="Window Title";    Type="s"; Data="👾 HACKED BY P'NONG 👾"; Checked=$false}
  [PSCustomObject]@{ID="015";Cat="😂 Pranks";Name="Change Registered Owner";        Desc='เปลี่ยนชื่อเจ้าของเครื่องเป็น "Mr. Hacker 🏴‍☠️"';             Path="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion";                                       VName="RegisteredOwner"; Type="s"; Data="Mr. Hacker 🏴‍☠️"; Checked=$false}
  # Performance
  [PSCustomObject]@{ID="016";Cat="⚡ Performance";Name="Fast Shutdown (1s)";        Desc="ลดเวลา Shutdown รอแค่ 1 วินาที";                              Path="HKCU\Control Panel\Desktop";                                                               VName="WaitToKillAppTimeout"; Type="d"; Data="1000"; Checked=$false}
  [PSCustomObject]@{ID="017";Cat="⚡ Performance";Name="Menu Show Delay = 0";       Desc="เมนูเด้งทันที ไม่มีหน่วง";                                      Path="HKCU\Control Panel\Desktop";                                                               VName="MenuShowDelay";   Type="d"; Data="0"; Checked=$false}
)

$SelectedColor = [System.Drawing.Color]::FromArgb(232, 240, 254)

# ── Build form ───────────────────────────────────────────────────────────
$Form = New-Object System.Windows.Forms.Form
$Form.Text = " 🪟 Windows Registry Tricks — GUI"
$Form.Size = New-Object System.Drawing.Size(820, 720)
$Form.StartPosition = "CenterScreen"
$Form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("powershell.exe")
$Form.BackColor = "#FAFAFA"
$Form.FormBorderStyle = "FixedSingle"
$Form.MaximizeBox = $false

# ── Header ──────────────────────────────────────────────────────────────
$Header = New-Object System.Windows.Forms.Panel
$Header.Size = New-Object System.Drawing.Size(820, 70)
$Header.BackColor = "#1A1A2E"
$Header.Dock = "Top"

$Title = New-Object System.Windows.Forms.Label
$Title.Text = "  🪟  Windows Registry Tricks"
$Title.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$Title.ForeColor = "White"
$Title.Size = New-Object System.Drawing.Size(500, 40)
$Title.Location = New-Object System.Drawing.Point(15, 15)
$Header.Controls.Add($Title)

$Subtitle = New-Object System.Windows.Forms.Label
$Subtitle.Text = "ครบทุกเมนู  —  จิ้มเลย  →  Apply  →  แค่นั้น"
$Subtitle.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$Subtitle.ForeColor = "#AAAAAA"
$Subtitle.Size = New-Object System.Drawing.Size(400, 25)
$Subtitle.Location = New-Object System.Drawing.Point(20, 48)
$Header.Controls.Add($Subtitle)

$Form.Controls.Add($Header)

# ── Checklist Panel (Scrollable) ─────────────────────────────────────────
$CheckPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$CheckPanel.Size = New-Object System.Drawing.Size(790, 460)
$CheckPanel.Location = New-Object System.Drawing.Point(15, 85)
$CheckPanel.AutoScroll = $true
$CheckPanel.BorderStyle = "None"
$CheckPanel.BackColor = "White"

$Checkboxes = @{}

$Categories = $Tricks | Group-Object Cat
foreach ($Cat in $Categories) {
  # ── Category Header ──
  $CatHeader = New-Object System.Windows.Forms.Panel
  $CatHeader.Size = New-Object System.Drawing.Size(750, 30)
  $CatHeader.Margin = New-Object System.Windows.Forms.Padding(0, 8, 0, 2)

  $CatLabel = New-Object System.Windows.Forms.Label
  $CatLabel.Text = "  $($Cat.Name)  ($($Cat.Count) items)"
  $CatLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
  $CatLabel.ForeColor = "#1A1A2E"
  $CatLabel.Size = New-Object System.Drawing.Size(400, 28)
  $CatLabel.Location = New-Object System.Drawing.Point(5, 0)
  $CatHeader.Controls.Add($CatLabel)

  $CheckPanel.Controls.Add($CatHeader)

  # ── Trick Rows ──
  foreach ($Trick in $Cat.Group) {
    $Row = New-Object System.Windows.Forms.Panel
    $Row.Size = New-Object System.Drawing.Size(750, 38)
    $Row.Margin = New-Object System.Windows.Forms.Padding(0, 1, 0, 1)
    $Row.BackColor = "White"

    $CB = New-Object System.Windows.Forms.CheckBox
    $CB.Text = ""
    $CB.Size = New-Object System.Drawing.Size(25, 38)
    $CB.Location = New-Object System.Drawing.Point(10, 10)
    $CB.Checked = $false
    $CB.Tag = $Trick.ID

    $CB.Add_CheckedChanged({
      $id = $this.Tag
      $t = $Tricks | Where-Object ID -eq $id
      $t.Checked = $this.Checked
      $parent = $this.Parent
      if ($this.Checked) { $parent.BackColor = $SelectedColor }
      else { $parent.BackColor = "White" }
    })

    $TrickLabel = New-Object System.Windows.Forms.Label
    $TrickLabel.Text = "$($Trick.ID). $($Trick.Name)"
    $TrickLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $TrickLabel.Size = New-Object System.Drawing.Size(260, 22)
    $TrickLabel.Location = New-Object System.Drawing.Point(36, 4)
    $TrickLabel.ForeColor = "#1A1A2E"

    $DescLabel = New-Object System.Windows.Forms.Label
    $DescLabel.Text = $Trick.Desc
    $DescLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $DescLabel.Size = New-Object System.Drawing.Size(370, 20)
    $DescLabel.Location = New-Object System.Drawing.Point(36, 22)
    $DescLabel.ForeColor = "#666666"

    $PathLabel = New-Object System.Windows.Forms.Label
    $PathLabel.Text = $Trick.Path.Substring(0, [Math]::Min(70, $Trick.Path.Length))
    $PathLabel.Font = New-Object System.Drawing.Font("Consolas", 8)
    $PathLabel.Size = New-Object System.Drawing.Size(80, 16)
    $PathLabel.Location = New-Object System.Drawing.Point(660, 12)
    $PathLabel.ForeColor = "#999999"
    # Show path in tooltip
    $ToolTip = New-Object System.Windows.Forms.ToolTip
    $ToolTip.SetToolTip($PathLabel, "$($Trick.Path)`n$($Trick.VName) = $($Trick.Data)")

    $Row.Controls.Add($CB)
    $Row.Controls.Add($TrickLabel)
    $Row.Controls.Add($DescLabel)
    $Row.Controls.Add($PathLabel)

    $Checkboxes[$Trick.ID] = $CB
    $CheckPanel.Controls.Add($Row)
  }

  # ── Separator ──
  $Sep = New-Object System.Windows.Forms.Panel
  $Sep.Size = New-Object System.Drawing.Size(750, 1)
  $Sep.BackColor = "#E0E0E0"
  $Sep.Margin = New-Object System.Windows.Forms.Padding(0, 4, 0, 4)
  $CheckPanel.Controls.Add($Sep)
}

$Form.Controls.Add($CheckPanel)

# ── Bottom Bar ──────────────────────────────────────────────────────────
$BottomBar = New-Object System.Windows.Forms.Panel
$BottomBar.Size = New-Object System.Drawing.Size(820, 160)
$BottomBar.Location = New-Object System.Drawing.Point(0, 550)
$BottomBar.BackColor = "#F0F0F0"
$BottomBar.Dock = "Bottom"

# ── Buttons ──
$BtnApply = New-Object System.Windows.Forms.Button
$BtnApply.Text = "✅  Apply Selected"
$BtnApply.Size = New-Object System.Drawing.Size(170, 40)
$BtnApply.Location = New-Object System.Drawing.Point(20, 15)
$BtnApply.BackColor = "#2E7D32"
$BtnApply.ForeColor = "White"
$BtnApply.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$BtnApply.FlatStyle = "Flat"
$BtnApply.Add_Click({ Apply-Selected })

$BtnUndo = New-Object System.Windows.Forms.Button
$BtnUndo.Text = "↩️  Undo Selected"
$BtnUndo.Size = New-Object System.Drawing.Size(170, 40)
$BtnUndo.Location = New-Object System.Drawing.Point(205, 15)
$BtnUndo.BackColor = "#E65100"
$BtnUndo.ForeColor = "White"
$BtnUndo.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$BtnUndo.FlatStyle = "Flat"
$BtnUndo.Add_Click({ Undo-Selected })

$BtnSelectAll = New-Object System.Windows.Forms.Button
$BtnSelectAll.Text = "☑️  Select All"
$BtnSelectAll.Size = New-Object System.Drawing.Size(130, 35)
$BtnSelectAll.Location = New-Object System.Drawing.Point(395, 10)
$BtnSelectAll.BackColor = "#1565C0"
$BtnSelectAll.ForeColor = "White"
$BtnSelectAll.FlatStyle = "Flat"
$BtnSelectAll.Add_Click({ Select-All })

$BtnDeselect = New-Object System.Windows.Forms.Button
$BtnDeselect.Text = "☐  Deselect All"
$BtnDeselect.Size = New-Object System.Drawing.Size(130, 35)
$BtnDeselect.Location = New-Object System.Drawing.Point(395, 50)
$BtnDeselect.BackColor = "#546E7A"
$BtnDeselect.ForeColor = "White"
$BtnDeselect.FlatStyle = "Flat"
$BtnDeselect.Add_Click({ Deselect-All })

$BtnPreview = New-Object System.Windows.Forms.Button
$BtnPreview.Text = "📄  Preview .reg"
$BtnPreview.Size = New-Object System.Drawing.Size(130, 35)
$BtnPreview.Location = New-Object System.Drawing.Point(540, 10)
$BtnPreview.BackColor = "#6A1B9A"
$BtnPreview.ForeColor = "White"
$BtnPreview.FlatStyle = "Flat"
$BtnPreview.Add_Click({ Preview-Reg })

$BtnBackup = New-Object System.Windows.Forms.Button
$BtnBackup.Text = "💾  Backup Registry"
$BtnBackup.Size = New-Object System.Drawing.Size(130, 35)
$BtnBackup.Location = New-Object System.Drawing.Point(540, 50)
$BtnBackup.BackColor = "#00838F"
$BtnBackup.ForeColor = "White"
$BtnBackup.FlatStyle = "Flat"
$BtnBackup.Add_Click({ Backup-Reg })

$BtnAbout = New-Object System.Windows.Forms.Button
$BtnAbout.Text = "❓  About"
$BtnAbout.Size = New-Object System.Drawing.Size(120, 35)
$BtnAbout.Location = New-Object System.Drawing.Point(685, 10)
$BtnAbout.FlatStyle = "Flat"
$BtnAbout.Add_Click({ Show-About })

$BtnExit = New-Object System.Windows.Forms.Button
$BtnExit.Text = "✕  Exit"
$BtnExit.Size = New-Object System.Drawing.Size(120, 35)
$BtnExit.Location = New-Object System.Drawing.Point(685, 50)
$BtnExit.BackColor = "#C62828"
$BtnExit.ForeColor = "White"
$BtnExit.FlatStyle = "Flat"
$BtnExit.Add_Click({ $Form.Close() })

# ── Status Label ──
$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Text = "✅ พร้อมทำงาน — เลือกรายการที่ต้องการ แล้วกด Apply Selected"
$StatusLabel.Size = New-Object System.Drawing.Size(780, 40)
$StatusLabel.Location = New-Object System.Drawing.Point(20, 95)
$StatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$StatusLabel.ForeColor = "#1A1A2E"

$BottomBar.Controls.Add($BtnApply)
$BottomBar.Controls.Add($BtnUndo)
$BottomBar.Controls.Add($BtnSelectAll)
$BottomBar.Controls.Add($BtnDeselect)
$BottomBar.Controls.Add($BtnPreview)
$BottomBar.Controls.Add($BtnBackup)
$BottomBar.Controls.Add($BtnAbout)
$BottomBar.Controls.Add($BtnExit)
$BottomBar.Controls.Add($StatusLabel)

$Form.Controls.Add($BottomBar)

# ── Functions ────────────────────────────────────────────────────────────
function Get-Selected {
  return $Tricks | Where-Object { $_.Checked }
}

function Select-All {
  foreach ($cb in $Checkboxes.Values) { $cb.Checked = $true }
}

function Deselect-All {
  foreach ($cb in $Checkboxes.Values) { $cb.Checked = $false }
}

function Update-Status {
  param($Msg, $Color)
  $StatusLabel.Text = $Msg
  if ($Color) { $StatusLabel.ForeColor = $Color }
  $Form.Refresh()
}

function Apply-Selected {
  $selected = Get-Selected
  if ($selected.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show("กรุณาเลือกรายการก่อน", "แจ้งเตือน", "OK", "Warning")
    return
  }

  $OutDir = Join-Path ([Environment]::GetFolderPath("Desktop")) "RegistryTricks_$(Get-Date -f yyyyMMdd_HHmmss)"
  $applyDir = Join-Path $OutDir "apply"
  $undoDir  = Join-Path $OutDir "undo"
  New-Item -ItemType Directory -Path $applyDir -Force | Out-Null
  New-Item -ItemType Directory -Path $undoDir -Force | Out-Null

  foreach ($t in $selected) {
    # Apply file
    $content = "Windows Registry Editor Version 5.00`r`n"
    $content += "`r`n; $($t.Desc)`r`n; Path : $($t.Path)`r`n`r`n"
    $content += "[$($t.Path)]`r`n"
    if ($t.Type -eq "d") {
      $content += "`"$($t.VName)`"=dword:$($t.Data)`r`n"
    } else {
      $content += "`"$($t.VName)`"=`"$($t.Data)`"`r`n"
    }
    $content | Out-File -FilePath (Join-Path $applyDir "$($t.ID)_$($t.Name -replace ' ','_').reg") -Encoding ascii

    # Undo file
    $undo = "Windows Registry Editor Version 5.00`r`n"
    $undo += "`r`n; UNDO — Remove $($t.VName)`r`n`r`n"
    $undo += "[$($t.Path)]`r`n"
    $undo += "`"$($t.VName)`"=-`r`n"
    $undo | Out-File -FilePath (Join-Path $undoDir "$($t.ID)_$($t.Name -replace ' ','_').reg") -Encoding ascii
  }

  [System.Windows.Forms.MessageBox]::Show(
    "✅ Apply .reg files → $applyDir`n✅ Undo .reg files → $undoDir`n`n⚠️  Backup ก่อนนะครับ!",
    "Success — $($selected.Count) tricks",
    "OK",
    "Information"
  )
  Update-Status "✅ สร้าง .reg แล้วที่ $OutDir — ไป double-click ที่ apply/ หรือ undo/"
}

function Undo-Selected {
  $selected = Get-Selected
  if ($selected.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show("กรุณาเลือกรายการที่ต้องการ Undo", "แจ้งเตือน", "OK", "Warning")
    return
  }

  $OutDir = Join-Path ([Environment]::GetFolderPath("Desktop")) "RegistryTricks_Undo_$(Get-Date -f yyyyMMdd_HHmmss)"
  $undoDir = Join-Path $OutDir "undo"
  New-Item -ItemType Directory -Path $undoDir -Force | Out-Null

  foreach ($t in $selected) {
    $undo = "Windows Registry Editor Version 5.00`r`n"
    $undo += "`r`n; UNDO — $($t.Name)`r`n`r`n"
    $undo += "[$($t.Path)]`r`n"
    $undo += "`"$($t.VName)`"=-`r`n"
    $undo | Out-File -FilePath (Join-Path $undoDir "$($t.ID)_$($t.Name -replace ' ','_')_Undo.reg") -Encoding ascii
  }

  [System.Windows.Forms.MessageBox]::Show(
    "✅ Undo .reg files → $undoDir`n`nไป double-click เพื่อคืนค่ากลับ",
    "Undo — $($selected.Count) tricks",
    "OK",
    "Information"
  )
  Update-Status "✅ สร้าง Undo .reg แล้วที่ $OutDir"
}

function Preview-Reg {
  $selected = Get-Selected
  if ($selected.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show("เลือกรายการที่ต้องการ Preview ก่อน", "แจ้งเตือน", "OK", "Warning")
    return
  }

  $preview = @()
  foreach ($t in $selected) {
    $preview += "══════════════════════════════════════"
    $preview += "  $($t.ID). $($t.Name)"
    $preview += "  $($t.Desc)"
    $preview += "  Path : $($t.Path)"
    $preview += "  Value: `"$($t.VName)`" = $($t.Data)"
    $preview += ""
    $preview += "  [HIVE\$($t.Path.Substring(4))]"
    if ($t.Type -eq "d") {
      $preview += "  `"$($t.VName)`"=dword:$($t.Data)"
    } else {
      $preview += "  `"$($t.VName)`"=`"$($t.Data)`""
    }
    $preview += ""
  }

  [System.Windows.Forms.MessageBox]::Show(
    $preview -join "`r`n",
    "📄 Preview — $($selected.Count) tricks",
    "OK",
    "Information"
  )
}

function Backup-Reg {
  $backupDir = Join-Path ([Environment]::GetFolderPath("Desktop")) "RegistryBackup_$(Get-Date -f yyyyMMdd_HHmmss)"
  New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

  $keys = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",
          "HKCU\Control Panel\Desktop",
          "HKLM\SYSTEM\CurrentControlSet\Services\UsbStor"

  foreach ($key in $keys) {
    $safeName = $key -replace '\\', '_' -replace ' ', ''
    $file = Join-Path $backupDir "$safeName.reg"
    try {
      $null = reg export "$key" "$file" 2>&1
    } catch {
      # key might not exist, skip
    }
  }

  [System.Windows.Forms.MessageBox]::Show(
    "✅ Backup → $backupDir`n`n⚠️  เก็บ .reg ไว้ในที่ปลอดภัย",
    "Backup Complete",
    "OK",
    "Information"
  )
  Update-Status "✅ Backup แล้วที่ $backupDir"
}

function Show-About {
  [System.Windows.Forms.MessageBox]::Show(
    "🪟 Windows Registry Tricks GUI v1.0`r`n`r`n"
    + "🎯 สำหรับ Bonus 3 — Windows Registry`r`n"
    + "🔬 17 tricks  ครบทุกเมนูอาจารย์`r`n`r`n"
    + "⚠️  คำเตือน:`r`n"
    + "Registry คือฐานข้อมูลสำคัญของ Windows`r`n"
    + "ควร Backup ก่อน Apply ทุกครั้ง`r`n"
    + "หรือทดลองใน VM / Windows Sandbox`r`n`r`n"
    + "😆 สนุกกับการเรียนรู้ ขอให้เก่งครับ!",
    "About",
    "OK",
    "Information"
  )
}

# ── Run ──────────────────────────────────────────────────────────────────
$Form.ShowDialog()
