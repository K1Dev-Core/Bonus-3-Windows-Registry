# Windows Registry Tricks

GUI tool สำหรับแก้ Windows Registry ง่ายๆ ไม่ต้องเปิด regedit

## ⚠️ Backup ก่อนเสมอ

ก่อนแก้ Registry ต้อง Backup ไว้ก่อน เผื่อซวย จะได้ Restore คืนมาได้

### วิธีที่ 1: ใช้ regedit GUI

**Backup:**
```
Win+R → พิมพ์ regedit → Enter
ไปที่ Registry Key ที่ต้องการ เช่น
  HKEY_CURRENT_USER
    Software
      Microsoft
คลิกขวาที่ Key (เช่น Microsoft) → Export
ตั้งชื่อไฟล์ เช่น 20260629-backup-microsoft.reg → Save
```

**Restore:**
```
Double Click ที่ .reg ไฟล์
หรือ Right Click → Merge
```

### วิธีที่ 2: ใช้ Command Line (PowerShell / CMD)

**Backup** (Run as Administrator):
```cmd
reg export HKCU\Software 20250529backup.reg
```
**Restore:**
```cmd
reg import 20250529backup.reg
```

### Registry Hive ที่สำคัญ

| ช่อ | ชื่อเต็ม | ใช้เก็บอะไร |
|-----|---------|------------|
| HKCR | HKEY_CLASSES_ROOT | File association, COM |
| HKCU | HKEY_CURRENT_USER | ค่าตั้งค่าผู้ใช้ปัจจุบัน |
| HKLM | HKEY_LOCAL_MACHINE | ค่าตั้งค่าทั้งระบบ |
| HKU | HKEY_USERS | ทุก user ในเครื่อง |
| HKCC | HKEY_CURRENT_CONFIG | Hardware profile |

**Backup ทั้งหมด** (ต้อง Export ทีละ Hive):
```cmd
reg export HKCR hkcr.reg
reg export HKCU hkcu.reg
reg export HKLM hklm.reg
reg export HKU hku.reg
reg export HKCC hkcc.reg
```

---

## วิธีใช้ GUI

เปิด PowerShell (Run as Administrator) แล้วรัน:

```powershell
irm https://raw.githubusercontent.com/K1Dev-Core/Bonus-3-Windows-Registry/main/registry-gui.ps1 | Out-File gui.ps1 -Encoding ascii; .\gui.ps1
```

หรือใช้ curl:

```powershell
curl.exe -sLo gui.ps1 https://raw.githubusercontent.com/K1Dev-Core/Bonus-3-Windows-Registry/main/registry-gui.ps1; .\gui.ps1
```

### วิธีการใช้งาน

1. เลือกรายการที่ต้องการ (กด Ctrl ค้างเพื่อเลือกหลายอัน หรือกด Select All)
2. กด **Backup** ก่อนเพื่อสำรองข้อมูล
3. กด **Apply** → ไฟล์ .reg ถูกสร้างไว้ที่ Desktop
4. ไปที่ Desktop → เปิดโฟลเดอร์ `Tricks_xxxx` → double-click .reg เพื่อใช้งาน
5. ถ้าต้องการคืนค่า → ใช้ .reg ที่ Backup ไว้ หรือกด Backup ใน GUI

### แต่ละปุ่มทำอะไร

| ปุ่ม | การทำงาน |
|------|---------|
| **Apply** | สร้าง .reg ไฟล์ส่งไป Desktop |
| **Select All** | เลือกทั้งหมด 17 รายการ |
| **Clear** | ยกเลิกเลือก |
| **Backup** | Export Registry keys ที่เกี่ยวข้อง |
| **Exit** | ปิดโปรแกรม |

### รายการทั้งหมด

| # | หมวด | ชื่อ | ค่าเดิม | ค่าใหม่ | เช็คยังไง |
|---|------|------|--------|--------|----------|
| 001 | Security | Disable USB Storage | Start=3 | Start=4 | เสียบ USB ไม่ติด |
| 002 | Security | Hide Control Panel | ไม่มี → 1 | Control Panel หาย |
| 003 | Security | Disable Task Manager | ไม่มี → 1 | Ctrl+Alt+Del → Error |
| 004 | Security | Disable CMD | ไม่มี → 1 | เปิด CMD ไม่ได้ |
| 005 | Security | Disable Regedit | ไม่มี → 1 | เปิด Regedit ไม่ได้ |
| 006 | Security | Disable AutoRun | 145 → 255 | USB ไม่ AutoRun |
| 007 | Hide/Show | Hide Drive C: | 0 → 4 | C: หายใน Explorer |
| 008 | Hide/Show | Hide All Drives | 0 → 67108863 | ไม่เห็น drive ไหน |
| 009 | Hide/Show | Hide Desktop Icons | ไม่มี → 1 | Desktop โล่ง |
| 010 | Hide/Show | Hide System Tray | ไม่มี → 1 | Taskbar icon หาย |
| 011 | Logon | Login Caption Title | ไม่มี → "Alert" | Win+L → ก่อน login |
| 012 | Logon | Login Message Text | ไม่มี → "Welcome" | Win+L → ข้อความ |
| 013 | Pranks | Rename Recycle Bin | "Recycle Bin" → "DELETE ME" | ถังขยะชื่อเปลี่ยน |
| 014 | Pranks | Change IE Title | ไม่มี → "My Browser" | Title bar เปลี่ยน |
| 015 | Pranks | Change Registered Owner | ชื่อเดิม → "Admin" | systeminfo |
| 016 | Performance | Fast Shutdown 1s | 5000 → 1000 | ปิดเครื่องเร็ว |
| 017 | Performance | Menu Delay 0 | 400 → 0 | เมนูเด้งทันที |

### รายละเอียดเพิ่มเติม

ดู `registry-guide.md` สำหรับ Path ใน regedit แบบละเอียด + วิธีทดสอบแต่ละข้อ
