#!/bin/bash
# 關閉闔蓋不睡，恢復 Mac 原本的樣子。要用管理員身分跑：sudo /bin/bash uninstall.sh
# 做三件事：移除電池保護常駐工作、刪掉安裝的程式、pmset -a disablesleep 0（闔蓋會睡，Mac 的預設值）。

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/common.sh"

if ! lca_is_root && [ "${LCA_DRYRUN:-0}" != 1 ]; then
  echo "需要管理員權限。請用「關閉闔蓋不睡.command」，或在終端機打：sudo /bin/bash \"$DIR/uninstall.sh\""
  exit 1
fi

lca_run launchctl bootout "system/$LCA_LABEL_GUARD" 2>/dev/null
rm -f "$LCA_DAEMON_PLIST"
rm -rf "$LCA_SYS_DIR"
lca_run pmset -a disablesleep 0

mkdir -p "$(dirname "$LCA_SYS_LOG")"
echo "$(date '+%Y-%m-%d %H:%M:%S') 已關閉闔蓋不睡，恢復闔蓋會睡" >> "$LCA_SYS_LOG"
echo "✅ 已關閉闔蓋不睡：闔上蓋子會像平常一樣睡眠。"
