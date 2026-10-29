#!/bin/bash
# 進階：開啟「闔蓋時畫面不上鎖」。不需要管理員密碼（只裝在目前這個使用者底下）。
# 放到 ~/Library/Application Support/LidClosedAwake/，登記成 ~/Library/LaunchAgents/local.lidclosedawake.display.plist。

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/common.sh"

if [ "$(lca_lid)" = none ]; then echo "這台 Mac 沒有蓋子（不是筆電），不需要這個工具。"; exit 0; fi

mkdir -p "$LCA_USER_DIR" "$(dirname "$LCA_AGENT_PLIST")" "$(dirname "$LCA_USER_LOG")" || exit 1
cp "$DIR/common.sh" "$DIR/display_hold.sh" "$LCA_USER_DIR/" || exit 1
chmod 755 "$LCA_USER_DIR/display_hold.sh"

# plist 裡寫的是實際位置（測試時 LCA_HOME 指到測試資料夾）
cat > "$LCA_AGENT_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LCA_LABEL_DISPLAY</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$LCA_USER_DIR/display_hold.sh</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>LCA_LOW</key>
    <string>$LCA_LOW</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF

uid=$(id -u)
lca_run launchctl bootout "gui/$uid/$LCA_LABEL_DISPLAY" 2>/dev/null
lca_run launchctl bootstrap "gui/$uid" "$LCA_AGENT_PLIST" || { echo "⚠️ 登記失敗（launchctl bootstrap）。"; exit 1; }
echo "$(date '+%Y-%m-%d %H:%M:%S') 已開啟：闔蓋時畫面不上鎖" >> "$LCA_USER_LOG"
echo "✅ 已開啟：闔蓋時畫面保持醒著、不上鎖。打開蓋子就恢復平常的上鎖規則。"
echo "⚠️ 提醒：闔蓋期間畫面沒鎖，別人這時打開蓋子不用密碼就能進桌面。帶出門前請關掉這個進階選項。"
