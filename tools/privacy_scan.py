#!/usr/bin/env python3
"""公開前掃描：個資、金鑰、內部路徑。repo 內所有文字檔＋dist 壓縮檔裡的每個檔都掃。有命中就退出碼 1。"""
import re, sys, zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RULES = [
    ("家目錄絕對路徑", r"/Users/[A-Za-z0-9_.-]+"),
    ("作者帳號名（網址以外）", r"(?i)iroo"),
    ("Email", r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"),
    ("台灣手機", r"09\d{2}[- ]?\d{3}[- ]?\d{3}"),
    ("GitHub token", r"gh[opsur]_[A-Za-z0-9]{20,}"),
    ("API key", r"sk-[A-Za-z0-9_-]{16,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]+|AIza[0-9A-Za-z_-]{30,}"),
    ("私鑰", r"BEGIN [A-Z ]*PRIVATE KEY"),
    ("內部工具與排程", r"com\.iroo|iroo-power-auto|anggong|notify_me|海棠軍機處|內務府|lid-nolock|claude-app-watchdog"),
    ("內部稱呼與機器人", r"娘娘|奴才|安公公|小泉子|小業子|岩公公|弘公公"),
    ("診所與合作單位", r"嘉德良醫|怡康|羽田|維格|南崁|弘光|沃栩|竹北|湖口"),
    ("雲端硬碟與本機資料夾", r"CloudStorage|GoogleDrive|我的雲端硬碟|11_AI工作檔|Skill收納庫"),
]
ALLOW = [r"Dr\. Iroo", r"github\.com/iroowu/lid-closed-awake", r"293288477\+iroowu@users\.noreply\.github\.com"]

def scan_text(name, text, hits):
    for allow in ALLOW:
        text = re.sub(allow, "", text)
    for label, pat in RULES:
        for m in re.finditer(pat, text):
            line = text.count("\n", 0, m.start()) + 1
            hits.append(f"{name}:{line}  [{label}]  {m.group(0)}")

hits, n = [], 0
for p in sorted(ROOT.rglob("*")):
    if ".git" in p.parts or not p.is_file():
        continue
    if p.name == "privacy_scan.py":
        continue  # 規則本身含關鍵字
    if p.suffix in (".zip", ".skill"):
        with zipfile.ZipFile(p) as z:
            for i in z.infolist():
                n += 1
                scan_text(f"{p.relative_to(ROOT)}!{i.filename}", z.read(i).decode("utf-8", "replace") + "\n" + i.filename, hits)
        continue
    n += 1
    scan_text(str(p.relative_to(ROOT)), p.read_text("utf-8", "replace") + "\n" + p.name, hits)

print(f"掃描 {n} 個檔案（含壓縮檔內的檔）")
if hits:
    print(f"❌ 命中 {len(hits)} 處：")
    print("\n".join(hits))
    sys.exit(1)
print("✅ 0 處命中：沒有家目錄路徑、Email、電話、金鑰、內部工具名、內部稱呼、診所名、雲端路徑")
