---
name: commit-message
description: 根據 git staged 內容自動產生 commit message，不自動 commit
metadata:
  author: ai-template
  version: "1.0"
---

根據目前 staged 的變更產生適合的 commit message。

## Steps

1. **讀取 staged 內容**

   ```bash
   git diff --staged
   git diff --staged --stat
   ```

2. **分析變更**

   判斷這次變更的性質：
   - `feat:` — 新功能
   - `fix:` — 修 bug
   - `chore:` — 非功能性維護（設定、依賴、gitignore 等）
   - `refactor:` — 重構（不改行為）
   - `docs:` — 文件
   - `style:` — 格式調整
   - `test:` — 測試

3. **產生 commit message**

   格式：
   ```
   <type>: <簡短描述>（50 字以內，英文）

   <選填：說明 why，不是 what，2-3 句話>
   ```

   規則：
   - 第一行用英文，動詞開頭（Add / Fix / Remove / Update / Refactor）
   - 不要結尾句號
   - 說明欄位用來解釋「為什麼」，不是重述 diff 內容
   - 如果變更很簡單，只要第一行就好

4. **輸出給使用者**

   直接輸出 commit message，方便複製。不要自動執行 commit。

   詢問：「要用這個 message commit 嗎？」

5. **如果使用者確認**

   執行：
   ```bash
   git commit -m "<message>"
   ```
   不要自動 push。
