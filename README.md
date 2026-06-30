# Windows Registry Tricks

GUI tool สำหรับแก้ Registry Windows ง่ายๆ ไม่ต้องเปิด regedit

## วิธีใช้

เปิด PowerShell (Admin) แล้วรัน:

```powershell
irm https://raw.githubusercontent.com/K1Dev-Core/Bonus-3-Windows-Registry/main/registry-gui.ps1 | Out-File gui.ps1 -Encoding ascii; .\gui.ps1
```

หรือใช้ curl:

```powershell
curl.exe -sLo gui.ps1 https://raw.githubusercontent.com/K1Dev-Core/Bonus-3-Windows-Registry/main/registry-gui.ps1; .\gui.ps1
```

## วิธีการใช้งาน

1. เลือกรายการที่ต้องการ (กด Ctrl ค้างเพื่อเลือกหลายอัน หรือกด Select All)
2. กด **Apply** → ไฟล์ .reg ถูกสร้างไว้ที่ Desktop
3. ไปที่ Desktop → เปิดโฟลเดอร์ `Tricks_xxxx` → double-click .reg เพื่อใช้งาน
4. ถ้าต้องการคืนค่า → ใช้ Backup ก่อน หรือกู้จาก .reg ที่ Backup ไว้

## ตัวอย่าง

| Trick | Registry Key | ผล |
|-------|-------------|-----|
| Disable USB Storage | HKLM\...\UsbStor | ปิดการใช้งาน USB |
| Hide Drive C: | HKCU\...\Explorer | ซ่อน Drive C |
| Fast Shutdown (1s) | HKCU\...\Desktop | ปิดเครื่องเร็วขึ้น |
| Disable Task Manager | HKCU\...\System | ปิด Task Manager |

⚠️ **ควร Backup ก่อน Apply ทุกครั้ง**
