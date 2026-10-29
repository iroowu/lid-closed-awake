#!/usr/bin/env python3
"""打包 dist/lid-closed-awake.zip 與 dist/lid-closed-awake.skill（內容相同，根目錄都是 lid-closed-awake/）。
保留 .command 與 scripts/*.sh 的執行權限，檔名用 UTF-8 旗標，排除 .DS_Store。"""
import zipfile, os, stat, time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "claude" / "lid-closed-awake"
DIST = ROOT / "dist"
DIST.mkdir(exist_ok=True)
SKIP = {".DS_Store", "__pycache__"}

def build(out: Path):
    files = sorted(p for p in SRC.rglob("*") if p.is_file() and not (set(p.parts) & SKIP))
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for p in files:
            arc = "lid-closed-awake/" + p.relative_to(SRC).as_posix()
            info = zipfile.ZipInfo(arc, date_time=time.localtime(p.stat().st_mtime)[:6])
            info.flag_bits |= 0x800  # UTF-8 檔名
            info.create_system = 3   # Unix，權限才會被解壓工具採用
            mode = 0o755 if (p.suffix in (".command", ".sh")) else 0o644
            info.external_attr = (stat.S_IFREG | mode) << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(info, p.read_bytes())
    return len(files)

for name in ("lid-closed-awake.zip", "lid-closed-awake.skill"):
    n = build(DIST / name)
    print(f"{name}: {n} 個檔案, {(DIST / name).stat().st_size} bytes")
