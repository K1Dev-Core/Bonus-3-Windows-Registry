#!/usr/bin/env bash
# ============================================================================
#  registry-tui.sh — Interactive TUI for Windows Registry Tricks
#  Generate .reg (apply + undo), preview, backup reminders.
#
#  Usage:
#    chmod +x registry-tui.sh
#    ./registry-tui.sh
#    ./registry-tui.sh /path/to/output
# ============================================================================

set -euo pipefail

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
C='\033[0;36m'; B='\033[1m'; N='\033[0m'

OUTDIR="${1:-./registry-output}"
mkdir -p "$OUTDIR/apply" "$OUTDIR/undo"

# ── Registry trick database ──────────────────────────────────────────────
# Each entry: name | description | registry_path | valuename | type | data
# type: d=dword, s=string, r=remove-value

declare -a TRICKS CATS

idx=0
add_trick() {
  TRICKS[$idx]="$1|$2|$3|$4|$5|$6"
  idx=$((idx+1))
}

# Security / Admin
add_trick "001_disable_usb"     "Disable USB Storage — ป้องกัน Data Exfiltration + Malware"           "HKLM\\SYSTEM\\CurrentControlSet\\Services\\UsbStor"                            "Start"            d "4"
add_trick "002_no_controlpanel" "Hide Control Panel — กัน User ไป Config มั่ว"                         "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer"        "NoControlPanel"   d "1"
add_trick "003_disable_taskmgr" "Disable Task Manager — ป้องกัน Kill Process"                          "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System"          "DisableTaskMgr"   d "1"
add_trick "004_disable_cmd"     "Disable Command Prompt — ป้องกัน Command Line"                         "HKCU\\Software\\Policies\\Microsoft\\Windows\\System"                         "DisableCMD"       d "1"
add_trick "005_disable_regedit" "Disable Registry Editor — ป้องกันแก้ Registry"                         "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System"          "DisableRegistryTools" d "1"
add_trick "006_disable_autoplay" "Disable AutoRun — ป้องกัน AutoRun Malware จาก USB"                    "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer"        "NoDriveTypeAutoRun" d "255"

# Hide / Show
add_trick "007_hide_drive_c"    "Hide Drive C: — ซ่อน C: จาก File Explorer"                            "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer"        "NoDrives"         d "4"
add_trick "008_hide_all_drives" "Hide ALL Drives — ซ่อนทุก Drive"                                      "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer"        "NoDrives"         d "67108863"
add_trick "009_no_desktop"      "Remove Desktop Icons — ซ่อน Desktop ทั้งหมด"                           "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer"        "NoDesktop"        d "1"
add_trick "010_hide_tray"       "Hide Tray (System Tray) — ซ่อน Notification Area"                     "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer"        "NoTrayItemsDisplay" d "1"

# Logon Messages
add_trick "011_login_caption"   "เปลี่ยน Title bar ก่อน Login"                                          "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System"           "legalnoticecaption" s "⚠️  SYSTEM ALERT ⚠️"
add_trick "012_login_message"   "เปลี่ยนข้อความก่อน Login — แกล้งเพื่อน"                                "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System"           "legalnoticetext"  s "Hi! Gorgeous! ✨%nOnly beautiful girls can continue."

# Pranks
add_trick "013_recyclebin"      "เปลี่ยนชื่อ Recycle Bin — \"Delete Me If YOU DARE 💀\""                 "HKCR\\CLSID\\{645FF040-5081-101B-9F08-00AA002F954E}"                          "@"                s "Delete Me If YOU DARE 💀"
add_trick "014_ie_title"        "เปลี่ยน Title Internet Explorer — \"👾 HACKED\""                       "HKCU\\Software\\Microsoft\\Internet Explorer\\Main"                           "Window Title"     s "👾 HACKED BY P'NONG 👾"
add_trick "015_registered_owner" "เปลี่ยน Registered Owner — \"Mr. Hacker\""                            "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"                        "RegisteredOwner"  s "Mr. Hacker 🏴‍☠️"

# Performance
add_trick "016_fast_shutdown"   "Speed up Shutdown — รอแค่ 1 วินาที"                                    "HKCU\\Control Panel\\Desktop"                                                  "WaitToKillAppTimeout" d "1000"
add_trick "017_menu_speed"      "Menu Show Delay = 0 — เมนูปรุงทันที"                                    "HKCU\\Control Panel\\Desktop"                                                  "MenuShowDelay"    d "0"

TOTAL=$idx
CATEGORIES=("Security / Admin" "Show / Hide" "Logon Messages" "Pranks" "Performance")
CAT_STARTS=(0 6 10 12 15)  # index start of each category

# ── Generate .reg files ──────────────────────────────────────────────────
gen_files() {
  local i="$1" name desc path valuename type data undo_val undo_type
  IFS='|' read -r name desc path valuename type data <<< "${TRICKS[$i]}"

  local f_apply="$OUTDIR/apply/${name}.reg"
  local f_undo="$OUTDIR/undo/${name}.reg"

  case "$type" in
    d)
      cat > "$f_apply" <<REG
Windows Registry Editor Version 5.00

; $desc
; Path : $path

[$path]
"$valuename"=dword:$(printf "%08x" "$data")
REG
      cat > "$f_undo" <<REG
Windows Registry Editor Version 5.00

; UNDO — Remove value "$valuename"
; To restore: re-import your backup .reg file

[$path]
"$valuename"=-
REG
      ;;
    s)
      local data_esc="${data//%/\%}"  # .reg uses %n for newline
      cat > "$f_apply" <<REG
Windows Registry Editor Version 5.00

; $desc
; Path : $path

[$path]
"$valuename"="$data_esc"
REG
      cat > "$f_undo" <<REG
Windows Registry Editor Version 5.00

; UNDO — Remove value "$valuename"

[$path]
"$valuename"=-
REG
      ;;
  esac
}

do_gen_all() {
  echo -e "\n${B}${C}Generating .reg files → ${Y}$OUTDIR${N}\n"
  for i in $(seq 0 $((TOTAL-1))); do
    gen_files "$i"
    IFS='|' read -r name desc _ <<< "${TRICKS[$i]}"
    echo -e "  ${G}✔${N} $name — $desc"
  done
  echo -e "\n${G}Done!${N}"
  echo -e "  apply/ — double-click .reg to apply"
  echo -e "  undo/  — double-click .reg to revert"
  echo -e "\n${Y}⚠️  ALWAYS backup first! Example:${N}"
  echo -e "  reg export \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\" backup.reg\n"
}

do_gen_one() {
  local i="$1"
  gen_files "$i"
  IFS='|' read -r name desc path valuename type data <<< "${TRICKS[$i]}"
  echo -e "\n${G}✔${N} Generated ${C}${name}${N}"
  echo -e "  ${desc}"
  echo -e "  Path  : ${B}$path${N}"
  echo -e "  Value : ${Y}$valuename${N} = ${C}$data${N} ($type)"
  echo -e "  Apply: ${OUTDIR}/apply/${name}.reg"
  echo -e "  Undo : ${OUTDIR}/undo/${name}.reg"
}

do_preview() {
  local i="$1"
  IFS='|' read -r name desc path valuename type data <<< "${TRICKS[$i]}"
  echo -e "\n${B}${C}══════════════════════════════════════${N}"
  echo -e "  ${B}${name}${N}"
  echo -e "  ${desc}"
  echo -e "  ${B}Path:${N}  ${path}"
  echo -e "  ${B}Name:${N}  ${valuename}"
  echo -e "  ${B}Type:${N}  ${type}"
  echo -e "  ${B}Data:${N}  ${data}"
  echo -e "${B}${C}══════════════════════════════════════${N}"
}

do_export_backup_command() {
  local i="$1"
  IFS='|' read -r name desc path valuename type data <<< "${TRICKS[$i]}"
  local key_short
  key_short="$(echo "$path" | sed 's/\\/\n/g' | head -2 | tail -1)"
  echo -e "\n${Y}Backup command for this key:${N}"
  echo -e "  reg export \"${path}\" \"backup-${name}.reg\""
  echo -e "${R}  Run this FIRST!${N}\n"
}

# ── TUI ──────────────────────────────────────────────────────────────────
main_menu() {
  while true; do
    clear
    echo -e "${B}${C}╔══════════════════════════════════════════════════╗${N}"
    echo -e "${B}${C}║     🪟  Windows Registry Tricks — TUI Menu     ║${N}"
    echo -e "${B}${C}╚══════════════════════════════════════════════════╝${N}"
    echo -e ""
    echo -e "  ${Y}Total:${N} ${B}$TOTAL${N} tricks in 5 categories"
    echo -e "  ${Y}Output:${N} ${C}$OUTDIR${N}"
    echo -e ""
    echo -e "  ${B}1)${N} Generate ALL .reg files (apply + undo)"
    echo -e "  ${B}2)${N} Pick trick by category"
    echo -e "  ${B}3)${N} Preview a specific trick"
    echo -e "  ${B}4)${N} Show backup instructions"
    echo -e "  ${B}5)${N} Change output directory"
    echo -e "  ${B}0)${N} Exit"
    echo -e ""
    read -p "$(echo -e '  Choose [0-5]: ')" opt
    case "$opt" in
      1) do_gen_all; press_enter ;;
      2) category_menu ;;
      3) pick_preview ;;
      4) pick_backup_help ;;
      5) change_outdir ;;
      0) echo -e "\n${G}Bye!${N}"; exit 0 ;;
      *) ;;
    esac
  done
}

category_menu() {
  while true; do
    clear
    echo -e "${B}${C}╔════════════════════════════╗${N}"
    echo -e "${B}${C}║     Select Category        ║${N}"
    echo -e "${B}${C}╚════════════════════════════╝${N}\n"
    for ci in "${!CATEGORIES[@]}"; do
      echo -e "  ${B}$((ci+1)))${N} ${CATEGORIES[$ci]}"
    done
    echo -e "  ${B}0)${N} Back"
    echo -e ""
    read -p "  Category: " cat_opt
    [[ "$cat_opt" == "0" ]] && return
    cat_idx=$((cat_opt-1))
    [[ $cat_idx -lt 0 || $cat_idx -ge ${#CATEGORIES[@]} ]] && continue

    local start="${CAT_STARTS[$cat_idx]}"
    local end
    if [[ $cat_idx -eq $((${#CATEGORIES[@]}-1)) ]]; then
      end=$TOTAL
    else
      end="${CAT_STARTS[$((cat_idx+1))]}"
    fi

    while true; do
      clear
      echo -e "${B}${C}╔══════════════════════════════════════════════════╗${N}"
      printf "${B}${C}║  %-48s ║${N}\n" " ${CATEGORIES[$cat_idx]}"
      echo -e "${B}${C}╚══════════════════════════════════════════════════╝${N}\n"
      for j in $(seq $start $((end-1))); do
        IFS='|' read -r name desc _ <<< "${TRICKS[$j]}"
        local idx_display=$((j-start+1))
        echo -e "  ${B}${idx_display})${N} ${desc}"
      done
      echo -e "  ${B}0)${N} Back"
      echo -e ""
      read -p "  Pick trick: " trick_opt
      [[ "$trick_opt" == "0" ]] && break
      local idx=$((start + trick_opt - 1))
      [[ $idx -lt $start || $idx -ge $end ]] && continue
      action_menu "$idx"
    done
  done
}

action_menu() {
  local i="$1"
  IFS='|' read -r name desc path valuename type data <<< "${TRICKS[$i]}"
  while true; do
    clear
    echo -e "${B}${C}╔════════════════════════════════════════════╗${N}"
    printf "${B}${C}║  %-46s ║${N}\n" " $name"
    echo -e "${B}${C}╚════════════════════════════════════════════╝${N}"
    echo -e "  ${desc}"
    echo -e "  ${B}Path:${N}  ${path}"
    echo -e "  ${B}Value:${N} ${valuename} = ${data}"
    echo -e ""
    echo -e "  ${B}1)${N} Preview .reg content"
    echo -e "  ${B}2)${N} Generate .reg file"
    echo -e "  ${B}3)${N} Show backup command"
    echo -e "  ${B}0)${N} Back"
    echo -e ""
    read -p "  Action: " act
    case "$act" in
      1) do_preview "$i"; press_enter ;;
      2) do_gen_one "$i"; press_enter ;;
      3) do_export_backup_command "$i"; press_enter ;;
      0) return ;;
      *) ;;
    esac
  done
}

pick_preview() {
  clear
  echo -e "${B}${C}Preview Trick${N}\n"
  echo -e "  ${B}0)${N} Back"
  for i in $(seq 0 $((TOTAL-1))); do
    IFS='|' read -r name desc _ <<< "${TRICKS[$i]}"
    echo -e "  ${B}$((i+1)))${N} $name — $desc"
  done
  echo -e ""
  read -p "  Trick #: " p
  [[ "$p" == "0" ]] && return
  p=$((p-1))
  [[ $p -ge 0 && $p -lt $TOTAL ]] || return
  do_preview "$p"
  press_enter
}

pick_backup_help() {
  clear
  echo -e "${B}${Y}╔════════════════════════════════════════════╗${N}"
  echo -e "${B}${Y}║         Backup Instructions               ║${N}"
  echo -e "${B}${Y}╚════════════════════════════════════════════╝${N}"
  echo -e ""
  echo -e "  ${B}Option 1: Export Registry Key${N}"
  echo -e "    reg export \"HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\" backup.reg"
  echo -e ""
  echo -e "  ${B}Option 2: Export a single key${N}"
  echo -e "    reg export \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer\" explorer-policy-backup.reg"
  echo -e ""
  echo -e "  ${B}Option 3: System Restore Point${N}"
  echo -e "    System Properties → System Protection → Create"
  echo -e ""
  echo -e "  ${B}Option 4: Windows Sandbox / VM${N}"
  echo -e "    ปลอดภัยที่สุด — ทดลองใน VM ไม่กระทบเครื่องจริง"
  echo -e ""
  echo -e "  ${B}Restore:${N}"
  echo -e "    reg import backup.reg"
  echo -e "    # หรือ double-click .reg file"
  echo -e ""
  press_enter
}

change_outdir() {
  read -p "  New output path [${OUTDIR}]: " newdir
  if [[ -n "$newdir" ]]; then
    OUTDIR="$newdir"
    mkdir -p "$OUTDIR/apply" "$OUTDIR/undo"
    echo -e "  ${G}→ Output: $OUTDIR${N}"
  fi
  press_enter
}

press_enter() {
  echo -e ""
  read -p "  Press Enter to continue..." _
}

# ── Entry point ──────────────────────────────────────────────────────────
main_menu
