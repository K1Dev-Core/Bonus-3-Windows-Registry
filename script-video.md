# Video Script — Windows Registry Tricks GUI

**ความยาว:** 3-5 นาที
**ภาษา:** ไทย
**เครื่องมือ:** OBS / Any screen recorder

---

## 1. Intro (30 วิ)

| ภาพ | เสียง |
|-----|-------|
| เปิด Desktop, กด Win+R → พิมพ์ `regedit` → แสดง Registry Editor คร่าวๆ | "Registry คือฐานข้อมูลสำคัญของ Windows เก็บทุกอย่างตั้งแต่ตั้งค่าเครื่องไปจนถึง Security Policy การแก้ Registry ด้วยมือมันเสี่ยงและยุ่งยาก วันนี้เรามีตัวช่วย" |

## 2. Download + รัน (30 วิ)

| ภาพ | เสียง |
|-----|-------|
| เปิด PowerShell (Admin) พิมพ์:
`irm https://raw.githubusercontent.com/K1Dev-Core/Bonus-3-Windows-Registry/main/registry-gui.ps1 | Out-File gui.ps1 -Encoding ascii`
แล้วกด Enter
จากนั้นพิมพ์ `.\gui.ps1` | "โหลดสคริปต์ด้วยคำสั่งนี้ ที่นี้รันเลย" |

## 3. GUI Overview (30 วิ)

| ภาพ | เสียง |
|-----|-------|
| GUI โผล่ขึ้นมา ชี้ ListBox, ปุ่มต่างๆ | "โปรแกรมจะแสดงรายการทั้งหมด 17 รายการ แบ่งเป็น 5 หมวด Security, Hide/Show, Logon, Pranks และ Performance" |

## 4. เลือกรายการ (30 วิ)

| ภาพ | เสียง |
|-----|-------|
| กด Select All → รายการ全部变成 ไฮไลต์ | "กด Select All เพื่อเลือกทั้งหมด หรือคลิกทีละรายการ กด Ctrl ค้างเพื่อเลือกหลายๆอัน" |
| Clear → ไฮไลต์หาย | "กด Clear เพื่อยกเลิก" |

## 5. Apply (45 วิ)

| ภาพ | เสียง |
|-----|-------|
| เลือก 2-3 รายการ (เช่น Disable USB, Fast Shutdown, Hide Drive C)
กด Apply
Message Box โผล่ | "เลือก Disable USB Storage, Fast Shutdown และ Hide Drive C แล้วกด Apply" |
| เปิด Desktop → โฟลเดอร์ Tricks_xxxx → แสดงไฟล์ .reg ด้านใน | "โปรแกรมจะสร้าง .reg ไฟล์ไว้ที่ Desktop ลองเปิดดู" |
| Double-click ไฟล์ .reg → Windows ถาม Yes/No | "ถ้าอยากใช้งานจริงก็ double-click แล้วกด Yes ได้เลย แต่รอบนี้ขอแค่โชว์ก่อน" |

## 6. Backup (30 วิ)

| ภาพ | เสียง |
|-----|-------|
| กดปุ่ม Backup → Message Box → เปิด Desktop → โฟลเดอร์ RegistryBackup_xxxx | "ก่อนแก้ Registry ควร Backup ก่อนทุกครั้ง ปุ่ม Backup จะ export Registry keys ที่เกี่ยวข้องไปไว้ที่ Desktop ถ้าพังจะได้กู้คืน" |

## 7. ปิดท้าย (15 วิ)

| ภาพ | เสียง |
|-----|-------|
| กด Exit → GUI ปิด | "เป็นยังไงบ้าง ง่ายใช่ไหมครับ อย่าลืมลองไปทำตามกันดู" |

---

## Tips การถ่าย

- **เปิด PowerShell As Administrator** ก่อน (บาง Registry ต้องใช้สิทธิ์ Admin)
- ถ่ายจอที่ 1920x1080 เพื่อความคมชัด
- ใช้ Mouse cursor highlight ตอนคลิกเพื่อให้คนดูเห็นชัดๆ
- ถ้า clipboard สะอาดดี ไม่มีข้อมูลสำคัญ

## คำสั่งที่ใช้ในคลิป

```powershell
# โหลด
irm https://raw.githubusercontent.com/K1Dev-Core/Bonus-3-Windows-Registry/main/registry-gui.ps1 | Out-File gui.ps1 -Encoding ascii
# รัน
.\gui.ps1
```
