查詢所有進行中的任務並規劃優先順序，同時產生過去 7 天工作摘要。

## Part 1：過去 7 天摘要

1. 執行以下指令抓過去 7 天 commits：
   ```bash
   git log --since="7 days ago" --oneline --no-merges
   ```

2. 讀 `TEAM_LOG.md`，取最新 5 條 wave entry。

3. 輸出：

   ```
   ## 📅 過去 7 天工作摘要

   ### Commits
   - <sha> <message>
   ...

   ### Wave 紀錄
   - <最近 wave entry>
   ```

## Part 2：未完成任務 + 優先順序

1. 列出 `openspec/changes/` 下所有目錄（排除 `archive/`）。

2. 讀取每個 change 的 `tasks.md`，收集所有 `- [ ]` 未完成任務。

3. 輸出：

   ```
   ## 📋 未完成任務總覽

   ### <change-name>
   - [ ] Lane A: ...
   - [ ] Lane B: ...

   **總計：N 個 change，M 個 lane 未完成**
   ```

4. 分析優先順序（考量：依賴關係、使用者影響、完成度、技術風險），輸出：

   ```
   ## 🎯 建議優先順序

   1. **<change-name>** — 原因：...
      下一步：<具體第一個任務>

   2. **<change-name>** — 原因：...
      下一步：<具體第一個任務>
   ```

5. 問：「要從哪個開始？還是有其他優先考量？」

輸出全部用繁體中文。
