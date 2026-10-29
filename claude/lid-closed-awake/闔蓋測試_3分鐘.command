#!/bin/bash
# 闔蓋不睡｜三分鐘闔蓋測試
cd "$(dirname "$0")" || exit 1
clear
/bin/bash "./scripts/heartbeat_test.sh" 3
echo
read -r -p "看完按 Return 關閉。" _
