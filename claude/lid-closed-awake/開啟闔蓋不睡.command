#!/bin/bash
# 闔蓋不睡｜開啟（by 儒儒醫師 Dr. Iroo）
cd "$(dirname "$0")" || exit 1
clear
cat <<'TXT'
闔蓋不睡｜開啟

這會做兩件事：
  1. 讓 Mac 闔上蓋子也不睡：Claude、排程、下載都繼續跑，出門用手機遙控也接得到。
  2. 裝「電池保護」：用電池而且電量剩 20% 以下時，自動恢復闔蓋睡眠，避免沒電關機；
     插上電再自動改回闔蓋不睡。

安全提醒：
  ・長時間闔蓋請插著電。
  ・不要把醒著的電腦塞進包包或悶在棉被裡，會過熱。
  ・帶著電腦出門，請先點「關閉闔蓋不睡.command」。

接下來會請你輸入「這台 Mac 的登入密碼」。
打字時畫面不會出現任何符號，這是正常的，打完按 Return。
TXT
echo
read -r -p "按 Return 繼續；不要的話直接關掉這個視窗。" _
sudo /bin/bash "./scripts/install.sh"
echo
/bin/bash "./scripts/status.sh"
echo
read -r -p "看完按 Return 關閉。" _
