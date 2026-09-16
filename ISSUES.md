# [專案名稱] Issue Tracker

QA 開單，RD 回。狀態：`open` → `in-progress` → `fixed` → `verified`。

> **只有開單的人（reporter）能把狀態改成 `verified`**，且必須重現原始 repro 確認壞行為不再發生——
> 不能只看「RD 有沒有回應」就算過。這是 `docs/AI_CEO_WORKING_MODEL.md` §6 提到的
> `feedback_qa_verify_policy` 教訓：驗收權不能給實作者。

## 格式範例

每張單的標題行格式：
```
## #<編號> [<狀態>] [<嚴重度>] [<標籤1>][<標籤2>] <一句話描述> · 開單者：<角色/名字> · 報告日：YYYY-MM-DD
```

內文至少含：

```markdown
**背景：** 怎麼發現的、影響範圍。

**根因：** 具體是哪個檔案哪一行、為什麼會這樣。

**RD 回應：** [fixed by <agent/PR>] [src/path/file.ts](src/path/file.ts) 第 X-Y 行 <做了什麼>。

**驗證：** <一行可重跑的指令 + 預期結果>。

**Severity：** <為什麼是這個等級>
```

---

<!-- 新 issue 往這裡的下一行插入，最新的在最上面 -->
