@echo off
chcp 65001 >nul
title Windows Registry Tricks — TUI
setlocal enabledelayedexpansion

set VERSION=1.0
set OUTDIR=%CD%\registry-output

if not "%1"=="" set OUTDIR=%1

if not exist "%OUTDIR%\apply" mkdir "%OUTDIR%\apply"
if not exist "%OUTDIR%\undo"  mkdir "%OUTDIR%\undo"

:: ── Trick database ─────────────────────────────────────────────────
:: Format: name|desc|path|valuename|type(d/s)|data

set TRICKS[0]=001_disable_usb|Disable USB Storage — ป้องกัน Data Exfiltration|HKLM\SYSTEM\CurrentControlSet\Services\UsbStor|Start|d|4
set TRICKS[1]=002_no_controlpanel|Hide Control Panel — กัน User Config มั่ว|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer|NoControlPanel|d|1
set TRICKS[2]=003_disable_taskmgr|Disable Task Manager — ป้องกัน Kill Process|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System|DisableTaskMgr|d|1
set TRICKS[3]=004_disable_cmd|Disable Command Prompt|HKCU\Software\Policies\Microsoft\Windows\System|DisableCMD|d|1
set TRICKS[4]=005_disable_regedit|Disable Registry Editor — ป้องกันแก้ Registry|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System|DisableRegistryTools|d|1
set TRICKS[5]=006_disable_autoplay|Disable AutoRun — ป้องกัน AutoRun Malware|HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer|NoDriveTypeAutoRun|d|255
set TRICKS[6]=007_hide_drive_c|Hide Drive C: — ซ่อน C: จาก File Explorer|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer|NoDrives|d|4
set TRICKS[7]=008_hide_all_drives|Hide ALL Drives — ซ่อนทุก Drive|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer|NoDrives|d|67108863
set TRICKS[8]=009_no_desktop|Remove Desktop Icons|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer|NoDesktop|d|1
set TRICKS[9]=010_hide_tray|Hide System Tray|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer|NoTrayItemsDisplay|d|1
set TRICKS[10]=011_login_caption|เปลี่ยน Title bar ก่อน Login|HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System|legalnoticecaption|s|⚠️  SYSTEM ALERT ⚠️
set TRICKS[11]=012_login_message|เปลี่ยนข้อความก่อน Login — แกล้งเพื่อน|HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System|legalnoticetext|s|Hi! Gorgeous! ^%nl^% Only beautiful girls can continue.
set TRICKS[12]=013_recyclebin|เปลี่ยนชื่อ Recycle Bin — "Delete Me If YOU DARE 💀"|HKCR\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}|@|s|Delete Me If YOU DARE 💀
set TRICKS[13]=014_ie_title|เปลี่ยน Title IE — "👾 HACKED"|HKCU\Software\Microsoft\Internet Explorer\Main|Window Title|s|👾 HACKED BY P'NONG 👾
set TRICKS[14]=015_registered_owner|เปลี่ยน Registered Owner|HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion|RegisteredOwner|s|Mr. Hacker 🏴‍☠️
set TRICKS[15]=016_fast_shutdown|Speed up Shutdown — รอแค่ 1 วิ|HKCU\Control Panel\Desktop|WaitToKillAppTimeout|d|1000
set TRICKS[16]=017_menu_speed|Menu Show Delay = 0 — เมนูปรุ๊บปรั๊บ|HKCU\Control Panel\Desktop|MenuShowDelay|d|0

set TOTAL=17

:: ── Category boundaries ────────────────────────────────────────────
set CAT0=Security / Admin
set CAT1=Show / Hide
set CAT2=Logon Messages
set CAT3=Pranks (แกล้งเพื่อน)
set CAT4=Performance

set CAT_START0=0
set CAT_START1=6
set CAT_START2=10
set CAT_START3=12
set CAT_START4=15

:: ── Generate .reg files ────────────────────────────────────────────
:gen_all
cls
echo.
echo =======================================
echo   Generating ALL .reg files...
echo   Output: %OUTDIR%
echo =======================================
echo.
for /L %%i in (0,1,%TOTAL%) do (
  if defined TRICKS[%%i] (
    call :gen_one %%i
  )
)
echo.
echo Done! Files in:
echo   %OUTDIR%\apply\  — double-click to apply
echo   %OUTDIR%\undo\   — double-click to revert
echo.
echo ⚠ ALWAYS backup first!
echo   reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies" backup.reg
echo.
pause
goto main_menu

:gen_one
setlocal enabledelayedexpansion
set IDX=%1
for /F "tokens=1-6 delims=|" %%a in ("!TRICKS[%IDX%]!") do (
  set "NAME=%%a"
  set "DESC=%%b"
  set "PATH=%%c"
  set "VNAME=%%d"
  set "VTYPE=%%e"
  set "DATA=%%f"

  if "!VTYPE!"=="d" (
    :: DWORD
    echo Windows Registry Editor Version 5.00 > "%OUTDIR%\apply\!NAME!.reg"
    echo. >> "%OUTDIR%\apply\!NAME!.reg"
    echo ; !DESC! >> "%OUTDIR%\apply\!NAME!.reg"
    echo ; Path : !PATH! >> "%OUTDIR%\apply\!NAME!.reg"
    echo. >> "%OUTDIR%\apply\!NAME!.reg"
    echo [!!PATH!] >> "%OUTDIR%\apply\!NAME!.reg"
    echo "!VNAME!"=dword:!DATA! >> "%OUTDIR%\apply\!NAME!.reg"

    echo Windows Registry Editor Version 5.00 > "%OUTDIR%\undo\!NAME!.reg"
    echo. >> "%OUTDIR%\undo\!NAME!.reg"
    echo ; UNDO — !DESC! >> "%OUTDIR%\undo\!NAME!.reg"
    echo. >> "%OUTDIR%\undo\!NAME!.reg"
    echo [!!PATH!] >> "%OUTDIR%\undo\!NAME!.reg"
    echo "!VNAME!"=- >> "%OUTDIR%\undo\!NAME!.reg"
  ) else (
    :: STRING
    echo Windows Registry Editor Version 5.00 > "%OUTDIR%\apply\!NAME!.reg"
    echo. >> "%OUTDIR%\apply\!NAME!.reg"
    echo ; !DESC! >> "%OUTDIR%\apply\!NAME!.reg"
    echo ; Path : !PATH! >> "%OUTDIR%\apply\!NAME!.reg"
    echo. >> "%OUTDIR%\apply\!NAME!.reg"
    echo [!!PATH!] >> "%OUTDIR%\apply\!NAME!.reg"
    echo "!VNAME!"="!DATA!" >> "%OUTDIR%\apply\!NAME!.reg"

    echo Windows Registry Editor Version 5.00 > "%OUTDIR%\undo\!NAME!.reg"
    echo. >> "%OUTDIR%\undo\!NAME!.reg"
    echo ; UNDO — !DESC! >> "%OUTDIR%\undo\!NAME!.reg"
    echo. >> "%OUTDIR%\undo\!NAME!.reg"
    echo [!!PATH!] >> "%OUTDIR%\undo\!NAME!.reg"
    echo "!VNAME!"=- >> "%OUTDIR%\undo\!NAME!.reg"
  )
  echo   ✔ !NAME! — !DESC!
)
endlocal
goto :eof

:: ── Preview ────────────────────────────────────────────────────────
:preview_trick
cls
set /p IDX="Enter trick number (0-%TOTAL%): "
if "%IDX%"=="" goto main_menu
if %IDX% GTR %TOTAL% goto main_menu
if defined TRICKS[%IDX%] (
  for /F "tokens=1-6 delims=|" %%a in ("!TRICKS[%IDX%]!") do (
    cls
    echo =======================================
    echo   %%a
    echo =======================================
    echo.
    echo   Desc : %%b
    echo   Path : %%c
    echo   Name : %%d
    echo   Type : %%e
    echo   Data : %%f
    echo.
    echo   Apply: %OUTDIR%\apply\%%a.reg
    echo   Undo : %OUTDIR%\undo\%%a.reg
  )
) else (
  echo Invalid number.
)
echo.
pause
goto main_menu

:: ── Backup help ────────────────────────────────────────────────────
:backup_help
cls
echo =======================================
echo         Backup Instructions
echo =======================================
echo.
echo  [1] Export Registry Key:
echo    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" backup.reg
echo.
echo  [2] Export single key:
echo    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" exp.reg
echo.
echo  [3] System Restore Point:
echo    System Properties ^> System Protection ^> Create
echo.
echo  [4] Windows Sandbox / VM (แนะนำ ปลอดภัยที่สุด)
echo.
echo  [Restore]
echo    reg import backup.reg
echo    หรือ double-click .reg file
echo.
pause
goto main_menu

:: ── Main Menu ──────────────────────────────────────────────────────
:main_menu
cls
echo =======================================
echo     🪟  Windows Registry Tricks
echo           TUI v%VERSION%
echo =======================================
echo.
echo   Total: %TOTAL% tricks in 5 categories
echo   Output: %OUTDIR%
echo.
echo   [1] Generate ALL .reg files
echo   [2] Preview a trick
echo   [3] Show backup instructions
echo   [4] Change output directory
echo   [5] About / Disclaimer
echo   [0] Exit
echo.
set /p OPT="Choose [0-5]: "

if "%OPT%"=="1" goto gen_all
if "%OPT%"=="2" goto preview_trick
if "%OPT%"=="3" goto backup_help
if "%OPT%"=="4" goto change_dir
if "%OPT%"=="5" goto about
if "%OPT%"=="0" goto end

goto main_menu

:change_dir
cls
set /p NEWDIR="New output path [%OUTDIR%]: "
if not "%NEWDIR%"=="" (
  set OUTDIR=%NEWDIR%
  if not exist "%OUTDIR%\apply" mkdir "%OUTDIR%\apply"
  if not exist "%OUTDIR%\undo"  mkdir "%OUTDIR%\undo"
  echo Output changed to: %OUTDIR%
)
echo.
pause
goto main_menu

:about
cls
echo =======================================
echo           About / Disclaimer
echo =======================================
echo.
echo   Windows Registry Tricks — TUI v%VERSION%
echo.
echo   ⚠ WARNING ⚠
echo   Registry is a critical Windows database.
echo   Incorrect changes may cause system issues.
echo.
echo   ✅ Always backup before applying:
echo     - Export .reg file
echo     - Create System Restore Point
echo     - Use Windows Sandbox / VM
echo.
echo   🎯 Purpose:
echo     - Educational (Cybersecurity)
echo     - System Administration
echo     - Fun / Pranks on friends
echo.
echo   Created for Bonus 3 — Windows Registry
echo.
pause
goto main_menu

:end
echo.
echo Bye!
exit /b
