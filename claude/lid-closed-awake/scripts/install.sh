#!/bin/bash
# 開啟闔蓋不睡＋裝電池保護。要用管理員身分跑：sudo /bin/bash install.sh
# 做三件事：
#   1. 把電池保護程式放到 /Library/Application Support/LidClosedAwake/（只有管理員能改）
#   2. 登記成系統常駐工作，每 60 秒檢查一次電量（/Library/LaunchDaemons/local.lidclosedawake.guard.plist）
#   3. pmset -a disablesleep 1（闔蓋不睡）

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/common.sh"

if [ "$(uname)" != Darwin ]; then echo "這個工具只能在 Mac 上用。"; exit 1; fi
if ! lca_is_root && [ "${LCA_DRYRUN:-0}" != 1 ]; then
  echo "需要管理員權限。請用「開啟闔蓋不睡.command」，或在終端機打：sudo /bin/bash \"$DIR/install.sh\""
  exit 1
fi
if [ "$(lca_lid)" = none ]; then
  echo "這台 Mac 沒有蓋子（不是筆電），不需要這個工具。"
  exit 0
fi

mkdir -p "$LCA_SYS_DIR" "$(dirname "$LCA_DAEMON_PLIST")" "$(dirname "$LCA_SYS_LOG")" || exit 1
cp "$DIR/common.sh" "$DIR/guard.sh" "$LCA_SYS_DIR/" || exit 1
chmod 755 "$LCA_SYS_DIR" "$LCA_SYS_DIR/guard.sh"
chmod 644 "$LCA_SYS_DIR/common.sh"
rm -f "$LCA_SYS_DIR/low_hold"

# plist 裡寫的一律是正式位置（LCA_PREFIX 只用在測試時放檔案）
cat > "$LCA_DAEMON_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LCA_LABEL_GUARD</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>/Library/Application Support/LidClosedAwake/guard.sh</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>LCA_LOW</key>
    <string>$LCA_LOW</string>
  </dict>
  <key>StartInterval</key>
  <integer>60</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardErrorPath</key>
  <string>/Library/Logs/LidClosedAwake.err.log</string>
</dict>
</plist>
EOF
chmod 644 "$LCA_DAEMON_PLIST"

if lca_is_root; then
  chown -R root:wheel "$LCA_SYS_DIR" "$LCA_DAEMON_PLIST"
fi

lca_run launchctl bootout "system/$LCA_LABEL_GUARD" 2>/dev/null
lca_run launchctl bootstrap system "$LCA_DAEMON_PLIST" || {
  echo "⚠️ 電池保護沒有登記成功（launchctl bootstrap 失敗）。闔蓋不睡仍會開啟，但用電池時請自己留意電量。"
}
lca_run pmset -a disablesleep 1

echo "$(date '+%Y-%m-%d %H:%M:%S') 已開啟闔蓋不睡（v$LCA_VERSION，電池保護門檻 ${LCA_LOW}%）" >> "$LCA_SYS_LOG"
echo "✅ 已開啟闔蓋不睡。用電池且電量剩 ${LCA_LOW}% 以下時會自動恢復睡眠，插上電再自動改回來。"

if [ "$(lca_power_source)" = Battery ]; then
  pct=$(lca_battery_pct)
  echo "⚠️ 你現在用電池（${pct}%）。闔蓋不睡會一直耗電，建議插上電源再闔蓋。"
fi
