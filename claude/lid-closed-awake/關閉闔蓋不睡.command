#!/bin/bash
# 闔蓋不睡｜關閉，恢復 Mac 原本的樣子（by 儒儒醫師 Dr. Iroo）
cd "$(dirname "$0")" || exit 1
clear
cat <<'TXT'
闔蓋不睡｜關閉

這會把 Mac 改回原本的樣子：闔上蓋子就睡眠，並移除電池保護。
如果你有開進階的「闔蓋時畫面不上鎖」，也會一起關掉。

接下來會請你輸入「這台 Mac 的登入密碼」（打字時畫面不會出現符號，打完按 Return）。
TXT
echo
read -r -p "按 Return 繼續；不要的話直接關掉這個視窗。" _
/bin/bash "./scripts/display_uninstall.sh" >/dev/null 2>&1
sudo /bin/bash "./scripts/uninstall.sh"
echo
/bin/bash "./scripts/status.sh"
echo
read -r -p "看完按 Return 關閉。" _
