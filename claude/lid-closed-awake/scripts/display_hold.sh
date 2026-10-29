#!/bin/bash
# 進階：闔蓋時讓畫面保持醒著，螢幕就不會上鎖（使用者身分常駐，每 10 秒看一次蓋子）。
# 為什麼要：闔蓋不睡之後，系統雖然醒著，但闔蓋約 3 分鐘螢幕睡著時，Mac 會上鎖；
#           鎖住以後，要「操作畫面」的工作（點 App、用瀏覽器、螢幕錄影）會卡住。
# 做法：蓋子闔著就掛 caffeinate -d（不讓顯示器睡），打開蓋子立刻放手，回到平常的螢幕睡眠與上鎖規則。
#       用電池且電量 ≤ LCA_LOW% 時也放手，省電。

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/common.sh"

LOG="${LCA_LOG:-$LCA_USER_LOG}"
INTERVAL="${LCA_INTERVAL:-10}"
LOOPS="${LCA_LOOPS:-0}"   # 測試用：跑幾圈就結束；0＝一直跑

mkdir -p "$(dirname "$LOG")"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"; }

pid=""
stop_hold() {
  if [ -n "$pid" ]; then
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    pid=""
  fi
}
finish() { stop_hold; exit 0; }
trap finish TERM INT HUP

n=0
while :; do
  want=0
  if [ "$(lca_lid)" = closed ]; then
    want=1
    if [ "$(lca_power_source)" = Battery ]; then
      pct=$(lca_battery_pct)
      if [ -n "$pct" ] && [ "$pct" -le "$LCA_LOW" ]; then want=0; fi
    fi
  fi

  alive=0
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then alive=1; fi

  if [ "$want" = 1 ] && [ "$alive" = 0 ]; then
    # -w $$：這支程式結束時 caffeinate 跟著結束，不會留下沒人管的防睡程序
    /usr/bin/caffeinate -d -i -s -w $$ &
    pid=$!
    log "闔蓋：讓畫面保持醒著，不上鎖（caffeinate pid $pid）"
  elif [ "$want" = 0 ] && [ "$alive" = 1 ]; then
    stop_hold
    log "開蓋或電量低：放手，恢復平常的螢幕睡眠與上鎖"
  fi

  n=$((n + 1))
  if [ "$LOOPS" -gt 0 ] && [ "$n" -ge "$LOOPS" ]; then finish; fi
  sleep "$INTERVAL" &
  wait $!
done
