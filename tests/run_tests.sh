#!/bin/bash
# 不改任何系統設定的模擬測試：LCA_DRYRUN=1 只印出會下的系統指令，LCA_PREFIX／LCA_HOME 把檔案放進暫存資料夾。
# 用法：bash tests/run_tests.sh

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
S="$ROOT/claude/lid-closed-awake/scripts"
T="$(mktemp -d)"
pass=0; fail=0
ok() { echo "PASS  $1"; pass=$((pass + 1)); }
ng() { echo "FAIL  $1"; echo "      $2"; fail=$((fail + 1)); }

# ---------- 電池保護 guard.sh ----------
guard() { # $1 情境名 $2 電源 $3 電量 $4 蓋子 $5 睡眠開關 $6 先有 low_hold(1/0) $7 期望指令（空＝不下任何指令） $8 期望之後 low_hold(1/0)
  local st="$T/g_$1"; mkdir -p "$st"; rm -f "$st/low_hold"
  [ "$6" = 1 ] && touch "$st/low_hold"
  local out
  out=$(LCA_DRYRUN=1 LCA_STATE_DIR="$st" LCA_LOG="$st/log" LCA_FAKE_SOURCE="$2" LCA_FAKE_PCT="$3" \
        LCA_FAKE_LID="$4" LCA_FAKE_SLEEPDISABLED="$5" bash "$S/guard.sh" | tr '\n' '|')
  local hold=0; [ -f "$st/low_hold" ] && hold=1
  if [ "$out" = "$7" ] && [ "$hold" = "$8" ]; then ok "guard：$1"; else ng "guard：$1" "指令=[$out] 期望=[$7]；low_hold=$hold 期望=$8"; fi
}
guard "插電、電量滿、闔蓋 → 不動"            AC      100 closed 1 0 ""                                                         0
guard "電池 50%、闔蓋 → 不動"                 Battery 50  closed 1 0 ""                                                         0
guard "電池 21% → 不動（門檻是 20）"          Battery 21  closed 1 0 ""                                                         0
guard "電池 20%、開蓋 → 恢復睡眠、不叫它睡"   Battery 20  open   1 0 "[DRYRUN] pmset -a disablesleep 0|"                       1
guard "電池 15%、闔蓋 → 恢復睡眠並叫它睡"     Battery 15  closed 1 0 "[DRYRUN] pmset -a disablesleep 0|[DRYRUN] pmset sleepnow|" 1
guard "已恢復、仍闔蓋低電 → 再叫它睡"         Battery 12  closed 0 1 "[DRYRUN] pmset sleepnow|"                                1
guard "已恢復、電量回 25% 仍用電池 → 不改回"  Battery 25  open   0 1 ""                                                         1
guard "已恢復、插上電 → 改回闔蓋不睡"         AC      18  open   0 1 "[DRYRUN] pmset -a disablesleep 1|"                       0
guard "使用者自己關掉、低電 → 不動"           Battery 10  closed 0 0 ""                                                         0
guard "桌機沒有電量 → 不動"                   AC      ""  none   1 0 ""                                                         0

# ---------- 安裝與還原 install.sh／uninstall.sh ----------
P="$T/prefix"
out=$(LCA_DRYRUN=1 LCA_PREFIX="$P" LCA_FAKE_LID=open LCA_FAKE_SOURCE=AC bash "$S/install.sh" 2>&1)
plist="$P/Library/LaunchDaemons/local.lidclosedawake.guard.plist"
if [ -f "$plist" ] && plutil -lint "$plist" >/dev/null; then ok "install：plist 格式正確"; else ng "install：plist" "$(plutil -lint "$plist" 2>&1)"; fi
if grep -q "/Library/Application Support/LidClosedAwake/guard.sh" "$plist" && ! grep -q "$T" "$plist"; then ok "install：plist 指向正式位置、沒有測試路徑"; else ng "install：plist 路徑" "$(grep -n string "$plist")"; fi
if [ -x "$P/Library/Application Support/LidClosedAwake/guard.sh" ] && [ -f "$P/Library/Application Support/LidClosedAwake/common.sh" ]; then ok "install：程式複製到位"; else ng "install：程式" "$(ls -la "$P/Library/Application Support/LidClosedAwake")"; fi
echo "$out" | grep -q "\[DRYRUN\] launchctl bootstrap system $plist" && echo "$out" | grep -q "\[DRYRUN\] pmset -a disablesleep 1" \
  && ok "install：會登記常駐並開啟闔蓋不睡" || ng "install：指令" "$out"
out=$(LCA_DRYRUN=1 LCA_PREFIX="$P" LCA_FAKE_LID=open LCA_FAKE_SOURCE=Battery LCA_FAKE_PCT=40 bash "$S/install.sh" 2>&1)
echo "$out" | grep -q "你現在用電池（40%）" && ok "install：用電池時提醒插電" || ng "install：電池提醒" "$out"
out=$(LCA_DRYRUN=1 LCA_PREFIX="$T/desk" LCA_FAKE_LID=none bash "$S/install.sh" 2>&1)
[ ! -e "$T/desk/Library" ] && echo "$out" | grep -q "不是筆電" && ok "install：桌機直接結束、不裝任何東西" || ng "install：桌機" "$out"
out=$(LCA_PREFIX="$P" bash "$S/install.sh" 2>&1); rc=$?
[ "$rc" = 1 ] && echo "$out" | grep -q "需要管理員權限" && ok "install：沒有管理員權限會擋下" || ng "install：權限檢查" "rc=$rc $out"

out=$(LCA_DRYRUN=1 LCA_PREFIX="$P" bash "$S/uninstall.sh" 2>&1)
[ ! -e "$plist" ] && [ ! -e "$P/Library/Application Support/LidClosedAwake" ] && echo "$out" | grep -q "\[DRYRUN\] pmset -a disablesleep 0" \
  && ok "uninstall：刪乾淨並改回闔蓋會睡" || ng "uninstall" "$out"

# ---------- 進階：闔蓋時畫面不上鎖 ----------
H="$T/home"
out=$(LCA_DRYRUN=1 LCA_HOME="$H" LCA_FAKE_LID=open bash "$S/display_install.sh" 2>&1)
ap="$H/Library/LaunchAgents/local.lidclosedawake.display.plist"
[ -f "$ap" ] && plutil -lint "$ap" >/dev/null && grep -q "$H/Library/Application Support/LidClosedAwake/display_hold.sh" "$ap" \
  && ok "display_install：plist 正確" || ng "display_install" "$out"
out=$(LCA_DRYRUN=1 LCA_HOME="$H" bash "$S/display_uninstall.sh" 2>&1)
[ ! -e "$ap" ] && [ ! -e "$H/Library/Application Support/LidClosedAwake" ] && ok "display_uninstall：刪乾淨" || ng "display_uninstall" "$out"

# display_hold 實跑（會真的短暫啟動 caffeinate，不改設定）：闔蓋 → 有 caffeinate；開蓋 → 放手
LF="$T/lid"; echo closed > "$LF"; DL="$T/display.log"
LCA_FAKE_LID_FILE="$LF" LCA_FAKE_SOURCE=AC LCA_LOG="$DL" LCA_INTERVAL=1 LCA_LOOPS=8 bash "$S/display_hold.sh" &
hp=$!
sleep 2
c1=$(pgrep -P "$hp" caffeinate | wc -l | tr -d ' ')
echo open > "$LF"; sleep 2
c2=$(pgrep -P "$hp" caffeinate | wc -l | tr -d ' ')
echo closed > "$LF"; sleep 2
wait "$hp"
left=$(pgrep -f "caffeinate -d -i -s -w $hp" | wc -l | tr -d ' ')
[ "$c1" = 1 ] && [ "$c2" = 0 ] && [ "$left" = 0 ] && [ "$(grep -c '闔蓋：讓畫面保持醒著' "$DL")" = 2 ] \
  && ok "display_hold：闔蓋掛上、開蓋放手、結束後不留 caffeinate" || ng "display_hold" "闔蓋時=$c1 開蓋時=$c2 結束後殘留=$left；$(cat "$DL")"

echo closed > "$LF"
LCA_FAKE_LID_FILE="$LF" LCA_FAKE_SOURCE=Battery LCA_FAKE_PCT=10 LCA_LOG="$T/d2.log" LCA_INTERVAL=1 LCA_LOOPS=2 bash "$S/display_hold.sh" &
hp=$!; sleep 1; c3=$(pgrep -P "$hp" caffeinate | wc -l | tr -d ' '); wait "$hp"
[ "$c3" = 0 ] && ok "display_hold：電池 10% 時不掛" || ng "display_hold 低電" "caffeinate=$c3"

# ---------- 闔蓋測試 heartbeat_test.sh（縮短版） ----------
LF2="$T/lid2"; echo closed > "$LF2"
out=$(LCA_FAKE_LID_FILE="$LF2" LCA_LOG="$T/hb.log" LCA_INTERVAL=1 LCA_TEST_SECONDS=4 bash "$S/heartbeat_test.sh" 1 2>&1)
echo "$out" | grep -q "✅ 通過" && ok "heartbeat：闔蓋且沒斷 → 通過" || ng "heartbeat 通過" "$out"
echo open > "$LF2"
out=$(LCA_FAKE_LID_FILE="$LF2" LCA_LOG="$T/hb2.log" LCA_INTERVAL=1 LCA_TEST_SECONDS=4 bash "$S/heartbeat_test.sh" 1 2>&1)
echo "$out" | grep -q "沒有偵測到闔蓋" && ok "heartbeat：沒闔蓋 → 請重測" || ng "heartbeat 沒闔蓋" "$out"

# ---------- 查看狀態 status.sh（真的讀這台電腦，只讀） ----------
out=$(bash "$S/status.sh" 2>&1); rc=$?
[ "$rc" = 0 ] && echo "$out" | grep -q "結論：" && ok "status：正常跑完並給結論" || ng "status" "$out"

rm -rf "$T"
echo
echo "結果：$pass 項通過，$fail 項失敗"
[ "$fail" = 0 ]
