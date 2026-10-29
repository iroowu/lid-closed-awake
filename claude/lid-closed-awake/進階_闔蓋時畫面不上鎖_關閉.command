#!/bin/bash
# 闔蓋不睡｜進階：關閉「闔蓋時畫面不上鎖」（不需要密碼）
cd "$(dirname "$0")" || exit 1
clear
/bin/bash "./scripts/display_uninstall.sh"
echo
read -r -p "按 Return 關閉。" _
