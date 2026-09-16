根據目前 git staged 的內容產生 commit message。

1. 執行 `git diff --staged` 和 `git diff --staged --stat` 讀取 staged 變更。
2. 分析變更性質，選擇適合的 type（feat / fix / chore / refactor / docs / style / test）。
3. 產生 commit message，格式：`<type>: <簡短描述>`，第一行英文動詞開頭，50 字以內，不加句號。
4. 如有必要加說明欄，解釋「為什麼」而非「做了什麼」。
5. 輸出 message 給使用者，詢問是否要用這個 message commit。
6. 如果使用者確認，執行 `git commit -m "<message>"`，不要自動 push。
