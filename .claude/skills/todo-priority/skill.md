---
name: todo-priority
description: 查詢所有進行中的任務並規劃優先順序，同時產生過去 7 天工作摘要
license: MIT
metadata:
  author: ai-template
  version: "1.1"
---

執行兩件事：**1) 過去 7 天工作摘要**、**2) 未完成任務優先順序規劃**。

---

## Part 1：過去 7 天摘要

1. **從 git log 抓過去 7 天的 commits**

   ```bash
   git -C . log --since="7 days ago" --oneline --no-merges
   ```

2. **從 TEAM_LOG.md 抓最近幾條記錄**

   讀 `TEAM_LOG.md`，取最新 5 條 wave entry。

3. **輸出摘要**

   ```
   ## 📅 過去 7 天工作摘要

   ### Commits（本週主要，條列 3-6 點，合併同主題 commit，不逐條列 sha）
   - <主題摘要，一句話講清楚做了什麼>
   - ...

   ### 本週完成的 changes（已 archive）
   - <列出 7 天內搬入 archive/ 的 change 名稱，逗號分隔>
   ```

   Wave 紀錄不獨立成段落，併入 commits 條列或省略（保持精簡）。

---

## Part 2：未完成任務 + 優先順序

1. **掃描所有 active changes**

   列出 `openspec/changes/` 下的目錄，排除 `archive/`。

2. **讀取每個 change 的 tasks.md**

   收集所有 `- [ ]` 未完成任務。

3. **列出現況**

   用表格呈現，不逐條展開 lane（保持精簡，一眼看完）：

   ```
   ## 📋 未完成任務總覽

   | Change | 未完成 tasks |
   |---|---|
   | <change-name> | <N> 個 |
   | <change-name> | 只有 proposal，tasks.md 尚未建立 |
   ```

4. **分析優先順序**

   考量：
   - **依賴關係**：block 其他 change 的先做
   - **使用者影響**：直接影響用戶體驗的優先
   - **完成度**：已完成大半的優先收尾
   - **技術風險**：複雜度高的早點開始

5. **輸出建議**

   每項一行，不分「下一步」子行（保持精簡）：

   ```
   ## 🎯 建議優先順序

   1. **<change-name>** — <一句話原因，說明為何排序在此>
   2. **<change-name>** — <一句話原因>
   ```

6. **詢問使用者**

   「要從哪個開始？還是有其他優先考量？」

---

## 注意事項

- 只看 `openspec/changes/`，不看 `archive/`
- 保持簡潔：tasks 只用表格列數量，不展開 lane/phase 細項；commits 合併同主題，不逐條列 sha
- 輸出用繁體中文
- 格式偏好（2026-07-28 使用者確認）：精簡條列 + 表格為主，避免長段落；Wave 紀錄不必獨立列出
