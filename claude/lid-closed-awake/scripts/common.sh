#!/bin/bash
# 闔蓋不睡（lid-closed-awake）共用函式。
# 只用 macOS 內建指令（pmset、ioreg、launchctl、caffeinate），不需要 Python 或其他安裝。
# 測試用：LCA_FAKE_* 可以假裝電源、電量、蓋子狀態；LCA_DRYRUN=1 只印出會執行的系統指令、不真的改設定；
#         LCA_PREFIX 把安裝位置整個搬到測試資料夾；LCA_HOME 假裝家目錄。

LCA_VERSION="1.0.0"
LCA_LABEL_GUARD="local.lidclosedawake.guard"
LCA_LABEL_DISPLAY="local.lidclosedawake.display"
LCA_LOW="${LCA_LOW:-20}"

LCA_ROOT="${LCA_PREFIX:-}"
LCA_SYS_DIR="$LCA_ROOT/Library/Application Support/LidClosedAwake"
LCA_DAEMON_PLIST="$LCA_ROOT/Library/LaunchDaemons/$LCA_LABEL_GUARD.plist"
LCA_SYS_LOG="$LCA_ROOT/Library/Logs/LidClosedAwake.log"

LCA_USER_HOME="${LCA_HOME:-$HOME}"
LCA_USER_DIR="$LCA_USER_HOME/Library/Application Support/LidClosedAwake"
LCA_AGENT_PLIST="$LCA_USER_HOME/Library/LaunchAgents/$LCA_LABEL_DISPLAY.plist"
LCA_USER_LOG="$LCA_USER_HOME/Library/Logs/LidClosedAwake-display.log"

# 電源：AC（插電）或 Battery（用電池）
lca_power_source() {
  if [ -n "$LCA_FAKE_SOURCE" ]; then echo "$LCA_FAKE_SOURCE"; return; fi
  if pmset -g batt 2>/dev/null | head -1 | grep -q "Battery Power"; then echo Battery; else echo AC; fi
}

# 電量百分比（桌機沒有電池時回空字串）
lca_battery_pct() {
  if [ -n "$LCA_FAKE_PCT" ]; then echo "$LCA_FAKE_PCT"; return; fi
  pmset -g batt 2>/dev/null | grep -Eo '[0-9]+%' | head -1 | tr -d '%'
}

# 蓋子：closed（闔著）、open（打開）、none（不是筆電）
lca_lid() {
  if [ -n "$LCA_FAKE_LID_FILE" ] && [ -f "$LCA_FAKE_LID_FILE" ]; then cat "$LCA_FAKE_LID_FILE"; return; fi
  if [ -n "$LCA_FAKE_LID" ]; then echo "$LCA_FAKE_LID"; return; fi
  local out
  out=$(ioreg -r -k AppleClamshellState -d 4 2>/dev/null | grep AppleClamshellState | head -1)
  case "$out" in
    *Yes*) echo closed ;;
    *No*) echo open ;;
    *) echo none ;;
  esac
}

# 系統睡眠開關：1＝闔蓋不睡，0＝平常（闔蓋會睡）
lca_sleep_disabled() {
  if [ -n "$LCA_FAKE_SLEEPDISABLED" ]; then echo "$LCA_FAKE_SLEEPDISABLED"; return; fi
  local v
  v=$(pmset -g 2>/dev/null | awk '/SleepDisabled/{print $2}')
  echo "${v:-0}"
}

# 執行會改系統的指令；LCA_DRYRUN=1 時只印出來
lca_run() {
  if [ "${LCA_DRYRUN:-0}" = 1 ]; then
    echo "[DRYRUN] $*"
  else
    "$@"
  fi
}

lca_is_root() { [ "$(id -u)" = 0 ]; }
