# 闔蓋不睡（lid-closed-awake）

讓 Mac 筆電**闔上蓋子也繼續工作**。把電腦留在家裡、闔上蓋子出門，照樣可以用手機的 Claude App 遙控電腦上的 Claude 做事。

> ⚠️ **只支援 Mac 筆電（macOS）。Windows 筆電、桌上型電腦不能用。**
>
> 分享者：儒儒醫師 Dr. Iroo｜免費、MIT 授權，可自由使用與轉傳。

## 為什麼需要

Claude 桌面版的「手機遙控」（Remote Control），是讓手機看得到、指揮得動**你電腦上**正在跑的 Claude。
官方說明寫得很清楚：電腦要開著，Claude 要一直在跑。

可是 Mac 筆電預設**一闔上蓋子就睡覺**。電腦一睡，手機那頭就斷線，排程也不會跑。
結果就變成：出門不能闔蓋、只好扛著電腦出門，或是開著蓋子放在桌上。

這個工具把「闔蓋就睡」關掉，並加上保護，讓你安心闔蓋出門。

## 它會做什麼

| 功能 | 說明 |
|---|---|
| 闔蓋不睡 | 闔上蓋子，Claude、排程、下載、背景工作都繼續跑 |
| 電池保護 | 用電池而且電量剩 20% 以下，自動恢復闔蓋睡眠，避免一路耗到沒電關機；插上電再自動改回 |
| 查看狀態 | 一眼看八項：闔蓋睡眠、電池保護、電源、蓋子、畫面上鎖、Claude 有沒有開、網路 |
| 三分鐘闔蓋測試 | 闔上蓋子兩分鐘，自動算出中間有沒有斷掉 |
| 一鍵還原 | 改回 Mac 原本的樣子，裝過的東西全部刪掉 |
| 進階（選用） | 闔蓋時畫面不上鎖：要讓 Claude 在闔蓋時操作畫面（點 App、用瀏覽器、螢幕錄影）才需要 |

全部只用 Mac 內建的指令，不用另外安裝任何軟體。

## 你需要

- 一台 **Mac 筆電**（桌機本來就沒有闔蓋問題）。作者在 macOS 26 實測。
- 要用手機遙控的話：**Claude 付費方案**（Pro、Max、Team 或 Enterprise）＋電腦上的 **Claude 桌面版**＋手機的 **Claude App**。

## 下載

到 [Releases 頁面](https://github.com/iroowu/lid-closed-awake/releases/latest) 下載：

- **`lid-closed-awake.zip`**：解壓縮後就能點兩下使用，也能裝成 Claude 的 skill。
- **`lid-closed-awake.skill`**：上傳到 claude.ai 的 skill 安裝檔。

請在 **Mac 上**下載（手機下載用不了）。

## 方法一：自己點兩下（最簡單）

1. 下載 `lid-closed-awake.zip`，點兩下解壓縮，得到一個 `lid-closed-awake` 資料夾。
2. 打開資料夾，點兩下 **「開啟闔蓋不睡.command」**。
3. 終端機視窗會說明要做什麼，按 Return，再輸入**這台 Mac 的登入密碼**（打字時畫面不會出現任何符號，這是正常的），按 Return。
4. 看到「✅ 已開啟闔蓋不睡」就完成了。視窗下方會接著顯示目前狀態。

**點兩下出現「無法打開，因為 Apple 無法檢查是否包含惡意軟體」？**
這是從網路下載的檔案都會跳的提醒。打開「系統設定 → 隱私權與安全性」，往下捲，找到剛剛那個檔案，按「強制打開」，再點兩下一次。

## 方法二：讓 Claude 幫你

裝成 skill 之後，跟 Claude 說「幫我開啟闔蓋不睡」，它會先查你的電腦狀態、用白話說明，再帶你一步一步做。
**密碼一律由你自己輸入**，Claude 不會、也不應該跟你要密碼。

- **Claude 桌面版的 Code 分頁、Claude Code**：把解壓縮出來的 `lid-closed-awake` 資料夾放到 `~/.claude/skills/` 底下
  （在 Finder 按 Command＋Shift＋G，貼上 `~/.claude/skills/` 就能打開這個資料夾）。
  也可以直接把 zip 檔拖進 Code 分頁的對話框，跟 Claude 說「幫我把這個 skill 裝起來」。
  這個版本的 Claude 跑在你的電腦上，可以直接幫你查狀態、打開資料夾、驗收結果。
- **claude.ai 或 Claude 桌面版的一般聊天**：到「設定 → Capabilities（功能）→ Skills → Add → Upload a skill」，上傳 `lid-closed-awake.skill`。
  這個版本的 Claude 跑在雲端，碰不到你的電腦，它會教你自己點哪一個檔。

## 開好之後，設定手機遙控

1. 打開電腦上的 **Claude 桌面版**，切到 **Code** 分頁。
2. 在對話框打 `/remote-control`（或 `/rc`），按 Enter。
   想讓每個新對話都自動連上：**設定 → Code（或 Claude Code）→ 打開「Connect new sessions to Remote Control」**。
3. 手機打開 **Claude App**，就看得到電腦上那個對話，可以直接打字、傳照片給它。
4. 闔上電腦蓋子（建議插著電），出門。

官方說明：[Remote Control（英文）](https://code.claude.com/docs/en/remote-control)

## 驗收：三分鐘闔蓋測試

點兩下 **「闔蓋測試_3分鐘.command」**，馬上闔上蓋子，等至少 2 分鐘再打開，看視窗的結果：

- ✅ 通過：闔蓋期間電腦一直醒著、網路也通。
- ❌ 中間停了很久：電腦有睡著，點「查看狀態.command」看是哪一步沒開。

## 安全須知（請一定要看）

- **長時間闔蓋請插著電。** 用電池闔蓋不睡會一直耗電；電池保護會在 20% 時讓電腦去睡，但插電最安心。
- **不要把醒著的電腦塞進包包、悶在棉被裡**，會過熱。闔蓋時鍵盤那一面散熱比較差，跑重工作（剪片、大量轉檔）時墊高或留一點縫。
- **帶著電腦出門前，先點「關閉闔蓋不睡.command」**，讓它在包包裡正常睡覺。
- 開了進階「闔蓋時畫面不上鎖」，闔蓋期間別人打開蓋子不用密碼就能進桌面。帶出門前一定要關。

## 還原

點兩下 **「關閉闔蓋不睡.command」**，輸入登入密碼。
它會移除電池保護、改回闔蓋會睡（Mac 原本的設定），進階選項也會一起關掉。

## 常見問題

**Windows 筆電可以用嗎？**
不行，這個工具只支援 Mac 筆電。Windows 內建就有類似設定：「控制台 → 電源選項 → 選擇闔上螢幕時的行為」，把「接上電源」那一欄改成「不執行任何動作」（作者沒有實測，僅供參考）。

**一般的防睡 App 或 `caffeinate` 不行嗎？**
Mac 筆電闔上蓋子就會睡（除非接了外接螢幕、鍵盤和電源），這一步一般的防睡指令擋不住，所以要改系統的睡眠開關。

**闔上蓋子後，螢幕會上鎖嗎？會影響手機遙控嗎？**
闔蓋約 3 分鐘、螢幕睡著時，Mac 會上鎖。手機遙控聊天、讀寫檔案、排程、下載都不受影響；
要「操作畫面」的工作（點 App 視窗、用瀏覽器、螢幕錄影）才會卡住，這時才需要開進階選項。

**手機上看到斷線了？**
先確認電腦有插電、Claude 桌面版還開著、家裡網路正常。電腦醒來、網路恢復後，官方說明是會自動重新連上；
連不上時，在電腦上的對話再打一次 `/remote-control`。

**系統更新後還有效嗎？**
這個工具用的 `pmset disablesleep` 開關，Apple 沒有寫在正式說明書裡。系統大改版後，請重跑一次三分鐘闔蓋測試。

**會裝哪些東西到我的電腦？**
`/Library/Application Support/LidClosedAwake/`（電池保護程式）、`/Library/LaunchDaemons/local.lidclosedawake.guard.plist`（每 60 秒檢查電量），
選了進階才會多 `~/Library/Application Support/LidClosedAwake/` 與 `~/Library/LaunchAgents/local.lidclosedawake.display.plist`。
還原時全部刪掉。紀錄在 `/Library/Logs/LidClosedAwake.log`。

## 檔案

| 位置 | 用途 |
|---|---|
| `claude/lid-closed-awake/` | skill 本體：說明書 `SKILL.md`、點兩下用的 `.command`、`scripts/` 程式 |
| `dist/` | 打包好的 `lid-closed-awake.zip` 與 `lid-closed-awake.skill` |
| `tests/run_tests.sh` | 不改系統設定的模擬測試（25 項） |
| `tools/build_dist.py` | 重新打包 |

## 授權

MIT License。歡迎轉傳給需要的朋友。
