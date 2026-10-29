#!/bin/bash
# 闔蓋不睡｜查看狀態（只讀，不改任何設定）
cd "$(dirname "$0")" || exit 1
clear
/bin/bash "./scripts/status.sh"
echo
read -r -p "看完按 Return 關閉。" _
