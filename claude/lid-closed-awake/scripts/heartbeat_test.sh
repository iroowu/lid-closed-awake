#!/bin/bash
# 闔蓋測試：每 10 秒記一次「現在幾點、蓋子狀態、連不連得到 Claude」，跑完算出中間有沒有斷掉。
# 用法：bash heartbeat_test.sh [分鐘數，預設 3]
# 測試期間把蓋子闔上至少 2 分鐘再打開。電腦如果睡著，紀錄會出現一大段空白。

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/common.sh"

MIN="${1:-3}"
INTERVAL="${LCA_INTERVAL:-10}"
LOG="${LCA_LOG:-$LCA_USER_HOME/Library/Logs/LidClosedAwake-heartbeat.log}"
mkdir -p "$(dirname "$LOG")"

echo "闔蓋測試開始：接下來 ${MIN} 分鐘，每 ${INTERVAL} 秒記一次。"
echo "現在把蓋子闔上，至少 2 分鐘後再打開，等這個視窗出現結果。"
echo "=== 測試開始 $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG"

SECS="${LCA_TEST_SECONDS:-$((MIN * 60))}"   # 測試用：LCA_TEST_SECONDS 直接指定秒數
end=$(( $(date +%s) + SECS ))
prev=""
maxgap=0
total=0
closed=0
net_fail_closed=0

while [ "$(date +%s)" -lt "$end" ]; do
  now=$(date +%s)
  lid=$(lca_lid)
  code=$(curl -s -o /dev/null -m 5 -w '%{http_code}' https://api.anthropic.com 2>/dev/null)
  net=ok
  if [ -z "$code" ] || [ "$code" = 000 ]; then net=fail; fi
  echo "$(date '+%H:%M:%S') 蓋子:$lid 網路:$net" >> "$LOG"
  if [ -n "$prev" ]; then
    gap=$((now - prev))
    if [ "$gap" -gt "$maxgap" ]; then maxgap=$gap; fi
  fi
  prev=$now
  total=$((total + 1))
  if [ "$lid" = closed ]; then
    closed=$((closed + 1))
    if [ "$net" = fail ]; then net_fail_closed=$((net_fail_closed + 1)); fi
  fi
  sleep "$INTERVAL"
done

limit=$((INTERVAL * 3))
echo
echo "共記錄 $total 次，其中闔蓋時 $closed 次，最大間隔 $maxgap 秒。"
if [ "$closed" -eq 0 ]; then
  echo "⚠️ 這段時間沒有偵測到闔蓋，請重新測一次，記得把蓋子闔上至少 2 分鐘。"
  result=noclose
elif [ "$maxgap" -gt "$limit" ]; then
  echo "❌ 中間停了 $maxgap 秒，電腦有睡著。請先看「查看狀態.command」，確認闔蓋睡眠已關掉。"
  result=fail
elif [ "$net_fail_closed" -gt 0 ]; then
  echo "⚠️ 電腦醒著，但闔蓋時有 $net_fail_closed 次連不到網路。請檢查 Wi-Fi。"
  result=netfail
else
  echo "✅ 通過：闔蓋約 $((closed * INTERVAL)) 秒，電腦一直醒著、網路也通。"
  result=pass
fi
echo "=== 測試結束：$result，最大間隔 ${maxgap} 秒 ===" >> "$LOG"
echo "（完整紀錄：$LOG）"
