# Registry Tricks — ตำแหน่งใน regedit + วิธีทดสอบ

## 1. Disable USB Storage

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsbStor` |
| ค่าเดิม | `Start` = `3` (Manual) |
| ค่าใหม่ | `Start` = `4` (Disabled) |
| วิธีเช็ค | เสียบ USB → ไม่ขึ้น drive, Device Manager ขึ้น error |

## 2. Hide Control Panel

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` |
| ค่าเดิม | ไม่มีค่า หรือ `NoControlPanel` = `0` |
| ค่าใหม่ | `NoControlPanel` = `1` |
| วิธีเช็ค | เปิด Control Panel → ขึ้น "ถูกจำกัด" หรือไม่เข้า |

## 3. Disable Task Manager

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System` |
| ค่าเดิม | ไม่มีค่า หรือ `DisableTaskMgr` = `0` |
| ค่าใหม่ | `DisableTaskMgr` = `1` |
| วิธีเช็ค | กด Ctrl+Alt+Del → Task Manager → "ปิดโดยผู้ดูแลระบบ" |

## 4. Disable CMD

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System` |
| ค่าเดิม | ไม่มีค่า หรือ `DisableCMD` = `0` |
| ค่าใหม่ | `DisableCMD` = `1` |
| วิธีเช็ค | Win+R → `cmd` → ขึ้น "Command Prompt ถูกปิดโดยผู้ดูแลระบบ" |

## 5. Disable Regedit

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System` |
| ค่าเดิม | ไม่มีค่า หรือ `DisableRegistryTools` = `0` |
| ค่าใหม่ | `DisableRegistryTools` = `1` |
| วิธีเช็ค | Win+R → `regedit` → ขึ้น "ถูกปิดโดยผู้ดูแลระบบ" |

## 6. Disable AutoRun

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer` |
| ค่าเดิม | `NoDriveTypeAutoRun` = `0x91` (145) หรือไม่มี |
| ค่าใหม่ | `NoDriveTypeAutoRun` = `255` |
| วิธีเช็ค | เสียบ USB → ไม่ AutoRun ขึ้นมา |

## 7. Hide Drive C:

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` |
| ค่าเดิม | ไม่มีค่า หรือ `NoDrives` = `0` |
| ค่าใหม่ | `NoDrives` = `4` (bitmask สำหรับ C:) |
| วิธีเช็ค | เปิด File Explorer →  Drive C: หายไป |

## 8. Hide ALL Drives

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` |
| ค่าเดิม | `NoDrives` = `0` |
| ค่าใหม่ | `NoDrives` = `67108863` (ทุก drive) |
| วิธีเช็ค | เปิด File Explorer → ไม่เห็น drive ไหนเลย |

## 9. Hide Desktop Icons

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` |
| ค่าเดิม | ไม่มีค่า หรือ `NoDesktop` = `0` |
| ค่าใหม่ | `NoDesktop` = `1` |
| วิธีเช็ค | Desktop โล่ง ไม่มี icon ใดๆ |

## 10. Hide System Tray

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` |
| ค่าเดิม | ไม่มีค่า หรือ `NoTrayItemsDisplay` = `0` |
| ค่าใหม่ | `NoTrayItemsDisplay` = `1` |
| วิธีเช็ค | Taskbar ล่างขวา → ไม่มี icon อะไรเลย |

## 11. Login Caption Title

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` |
| ค่าเดิม | `legalnoticecaption` = ไม่มีค่า |
| ค่าใหม่ | `legalnoticecaption` = "Alert" |
| วิธีเช็ค | Lock screen (Win+L) → มี Title bar ข้อความขึ้นก่อน login |
| ต้อง Restart? | ใช่ |

## 12. Login Message Text

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` |
| ค่าเดิม | `legalnoticetext` = ไม่มีค่า |
| ค่าใหม่ | `legalnoticetext` = "Welcome" |
| วิธีเช็ค | Lock screen → ข้อความขึ้นก่อน login |
| ต้อง Restart? | ใช่ |

## 13. Rename Recycle Bin

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}` |
| ค่าเดิม | `@` = "Recycle Bin" |
| ค่าใหม่ | `@` = "DELETE ME" |
| วิธีเช็ค | เปิด Desktop → ถังขยะชื่อเปลี่ยน |
| ต้อง Restart? | อาจต้อง restart explorer |

## 14. Change IE Title

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main` |
| ค่าเดิม | `Window Title` = ไม่มีค่า |
| ค่าใหม่ | `Window Title` = "My Browser" |
| วิธีเช็ค | เปิด Edge/IE → Title bar เปลี่ยนตาม |
| ต้อง Restart? | ปิดเปิด browser ใหม่ |

## 15. Change Registered Owner

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion` |
| ค่าเดิม | `RegisteredOwner` = "Windows User" หรือชื่อตอนติดตั้ง |
| ค่าใหม่ | `RegisteredOwner` = "Admin" |
| วิธีเช็ค | `systeminfo \| find "Registered Owner"` |
| ต้อง Restart? | ไม่ต้อง |

## 16. Fast Shutdown 1s

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Control Panel\Desktop` |
| ค่าเดิม | `WaitToKillAppTimeout` = `5000` (5 วิ) หรือไม่มี |
| ค่าใหม่ | `WaitToKillAppTimeout` = `1000` (1 วิ) |
| วิธีเช็ค | เปิด Task Manager → Performance → ดูเวลาปิด |
| ต้อง Restart? | ใช่ ถึงเห็นผล |

## 17. Menu Delay 0

| รายการ | รายละเอียด |
|--------|-----------|
| Path ใน regedit | `HKEY_CURRENT_USER\Control Panel\Desktop` |
| ค่าเดิม | `MenuShowDelay` = `400` (0x190) |
| ค่าใหม่ | `MenuShowDelay` = `0` |
| วิธีเช็ค | คลิก Start → เมนูเด้งทันทีไม่หน่วง |
| ต้อง Restart? | ออกจากระบบแล้วกลับเข้า หรือ restart explorer |
