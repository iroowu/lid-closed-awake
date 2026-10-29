#!/bin/bash
# 電池保護（由系統每 60 秒跑一次，管理員身分）。
# 用電池而且電量 ≤ LCA_LOW%（預設 20%）：把闔蓋睡眠還原；蓋子闔著就讓電腦去睡，避免一路耗到沒電關機。
# 之後插上電：恢復闔蓋不睡。只有「插電」會解除，避免電量在 20%、21% 之間來回切換。

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/common.sh"

STATE="${LCA_STATE_DIR:-$LCA_SYS_DIR}"
LOG="${LCA_LOG:-$LCA_SYS_LOG}"
HOLD="$STATE/low_hold"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"; }

src=$(lca_power_source)
pct=$(lca_battery_pct)
lid=$(lca_lid)
sd=$(lca_sleep_disabled)

if [ "$src" = Battery ] && [ -n "$pct" ] && [ "$pct" -le "$LCA_LOW" ]; then
  if [ "$sd" = 1 ]; then
    lca_run pmset -a disablesleep 0
    touch "$HOLD"
    log "電量剩 ${pct}%（用電池）：已恢復闔蓋睡眠，避免沒電關機。插上電會自動改回闔蓋不睡。"
  fi
  if [ -f "$HOLD" ] && [ "$lid" = closed ]; then
    lca_run pmset sleepnow
    log "蓋子闔著、電量低：讓電腦去睡。"
  fi
elif [ "$src" = AC ] && [ -f "$HOLD" ]; then
  lca_run pmset -a disablesleep 1
  rm -f "$HOLD"
  log "插上電了：恢復闔蓋不睡。"
fi
exit 0
