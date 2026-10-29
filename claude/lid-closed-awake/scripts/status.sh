#!/bin/bash
# 查看闔蓋不睡的狀態。只讀、不改任何設定，不需要管理員密碼。

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/common.sh"

uid=$(id -u)
todo=""
add_todo() { todo="$todo\n   ・$1"; }

echo "闔蓋不睡 v$LCA_VERSION｜目前狀態"
echo "────────────────────────"

lid=$(lca_lid)
if [ "$lid" = none ]; then
  echo "這台 Mac 沒有蓋子（不是筆電），不需要這個工具。"
  exit 0
fi

sd=$(lca_sleep_disabled)
if [ "$sd" = 1 ]; then
  echo "① 闔蓋睡眠：已關掉，闔上蓋子也不睡 ✅"
else
  echo "① 闔蓋睡眠：平常設定，闔上蓋子會睡"
  add_todo "點兩下「開啟闔蓋不睡.command」"
fi

if [ -f "$LCA_DAEMON_PLIST" ] && launchctl print "system/$LCA_LABEL_GUARD" >/dev/null 2>&1; then
  if [ -f "$LCA_SYS_DIR/low_hold" ]; then
    echo "② 電池保護：有在跑。剛才電量太低，已暫時恢復闔蓋睡眠，插上電會自動改回來 ⚠️"
  else
    echo "② 電池保護：有在跑 ✅（用電池且電量 ≤ ${LCA_LOW}% 時自動恢復睡眠）"
  fi
elif [ -f "$LCA_DAEMON_PLIST" ]; then
  echo "② 電池保護：檔案在，但系統沒有載入 ⚠️（重新點一次「開啟闔蓋不睡.command」）"
else
  echo "② 電池保護：沒有裝"
fi

src=$(lca_power_source)
pct=$(lca_battery_pct)
if [ "$src" = AC ]; then
  echo "③ 電源：插著電 ✅${pct:+（電量 ${pct}%）}"
else
  echo "③ 電源：用電池（${pct}%）。闔蓋不睡很耗電，要長時間闔蓋請插電"
fi

if [ "$lid" = closed ]; then echo "④ 蓋子：闔著"; else echo "④ 蓋子：打開"; fi

if launchctl print "gui/$uid/$LCA_LABEL_DISPLAY" >/dev/null 2>&1; then
  echo "⑤ 進階「闔蓋時畫面不上鎖」：開 ✅（帶出門前記得關）"
else
  echo "⑤ 進階「闔蓋時畫面不上鎖」：關（只影響要操作畫面的工作，手機遙控聊天不受影響）"
fi

lock=$(sysadminctl -screenLock status 2>&1 | tail -1)
case "$lock" in
  *"is off"*) echo "⑥ 螢幕上鎖：螢幕睡著後不需要密碼" ;;
  *immediate*) echo "⑥ 螢幕上鎖：螢幕睡著立刻需要密碼" ;;
  *delay*) echo "⑥ 螢幕上鎖：螢幕睡著一段時間後需要密碼（${lock##*delay is }）" ;;
  *) echo "⑥ 螢幕上鎖：查不到" ;;
esac

if ps -axo comm= 2>/dev/null | grep -q '/Applications/Claude.app/Contents/MacOS/Claude'; then
  echo "⑦ Claude 桌面版：開著 ✅"
else
  echo "⑦ Claude 桌面版：沒開（要用手機遙控，電腦上的 Claude 桌面版要開著）"
  add_todo "打開 Claude 桌面版"
fi

code=$(curl -s -o /dev/null -m 6 -w '%{http_code}' https://api.anthropic.com 2>/dev/null)
if [ -n "$code" ] && [ "$code" != 000 ]; then
  echo "⑧ 網路：連得到 Claude ✅"
else
  echo "⑧ 網路：連不到 Claude 的伺服器"
  add_todo "檢查 Wi-Fi"
fi

echo "────────────────────────"
if [ -z "$todo" ]; then
  echo "結論：可以闔上蓋子出門，用手機的 Claude App 遙控了。"
  if [ "$src" != AC ]; then echo "      （建議插著電再闔蓋）"; fi
else
  printf "結論：還差這幾步：%b\n" "$todo"
fi

if [ -f "$LCA_SYS_LOG" ]; then
  echo
  echo "最近的紀錄："
  tail -3 "$LCA_SYS_LOG" | sed 's/^/   /'
fi
