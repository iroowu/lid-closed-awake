#!/bin/bash
# 進階：關閉「闔蓋時畫面不上鎖」，恢復平常的螢幕睡眠與上鎖。不需要管理員密碼。

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/common.sh"

uid=$(id -u)
lca_run launchctl bootout "gui/$uid/$LCA_LABEL_DISPLAY" 2>/dev/null
rm -f "$LCA_AGENT_PLIST"
rm -f "$LCA_USER_DIR/display_hold.sh" "$LCA_USER_DIR/common.sh"
rmdir "$LCA_USER_DIR" 2>/dev/null
mkdir -p "$(dirname "$LCA_USER_LOG")"
echo "$(date '+%Y-%m-%d %H:%M:%S') 已關閉：闔蓋時畫面不上鎖" >> "$LCA_USER_LOG"
echo "✅ 已關閉進階選項：闔蓋後螢幕會照平常的規則睡眠、上鎖。"
