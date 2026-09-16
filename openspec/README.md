# openspec —— 規格庫與列管

> **一句話：** 這裡放「要做什麼、為什麼這樣做」；`src/` 放「怎麼做」。
> 規格先寫清楚、老闆拍板，才開始派工寫程式。

---

## 1. 為什麼要有這一層

sub-agent 沒有上下文。你丟一句「加一個效能守門機制」給它，它會自己猜預算要定多少、
要不要擋 commit、歷史債怎麼辦——猜錯了才發現，已經寫完一半。

openspec 的作用是**把需要人拍板的決策，從實作過程中抽出來，先攤在桌上**。
proposal → design → tasks 三段式強迫在寫 code 前回答三個問題：

| 問題 | 寫在哪 |
|---|---|
| 為什麼要做？不做會怎樣？**不做什麼**？ | `proposal.md` |
| 有哪些做法？各自的代價？**要老闆拍板的是哪幾點**？ | `design.md` |
| 拆成幾個可以平行的 lane？每個 lane 的完工條件？ | `tasks.md` |

第三個問題最容易被跳過，但它決定了組織能不能平行作業——一個 section 就是一個 Lane，
一個 Lane 就是一張 GitHub issue、一個 sub-agent。

---

## 2. 四份 artifact

```
openspec/changes/<change-name>/
├── proposal.md                       為什麼做 + 現況缺口 + 不在範圍內
├── design.md                         做法比較 + 要老闆拍板的決策
├── tasks.md                          section = Lane = 一張 GH issue
└── specs/<capability>/spec.md        這次改動對 capability 的 delta
```

`specs/` 那份是**最常被漏掉的**，但沒有它 `openspec validate` 會直接失敗。
它的格式是嚴格的：

```markdown
## ADDED Requirements          ← 也可以是 MODIFIED / REMOVED / RENAMED

### Requirement: <一句話，用 SHALL 寫成可驗證的敘述>
<細節>

#### Scenario: <情境名>        ← 每個 Requirement 至少要有一個
- **WHEN** <觸發條件>
- **THEN** <可觀察的結果>
```

`#` 的數量是被檢查的，少一層或多一層都會解析不到。

---

## 3. 生命週期

```
ROADMAP.md           想做，還沒開規格
    │  （老闆說要做了）
    ▼
openspec/changes/<name>/     proposal + design + tasks + specs delta
    │  （push 上 main，team review，老闆拍板 design 的決策）
    ▼
派工              每個 tasks.md section 一張 GH issue，一個 sub-agent
    │  （全部 section 完工，CEO 跑驗收腳本）
    ▼
openspec archive       spec delta 併入 openspec/specs/<capability>/
                       change 整包搬到 changes/archive/<日期>-<name>/
```

**跟其他文件的分工：**

| 文件 | 放什麼 | 什麼時候搬進 openspec |
|---|---|---|
| [`ROADMAP.md`](../ROADMAP.md) | 想做、還沒開規格的大項目 | 老闆決定要做 → 開 proposal，從 ROADMAP 移除 |
| [`ISSUES.md`](../ISSUES.md) | Bug。壞掉的東西 | 不搬。bug 直接修，不走 change |
| `openspec/changes/` | 新功能、大重構、需要決策的事 | — |

判準：**要不要開 change，看的是「有沒有需要別人拍板的決策」**，不是工作量大小。
改一行但會影響 production 資料 → 要 change。改五十行但只是照既有 pattern 補齊 → 不用。

---

## 4. 維護規則

### 什麼時候新增 change

- 老闆指定要做 ROADMAP 上的項目
- 一個 bug 追下去發現根因是設計問題，修法有多種方向且代價不同
- 需要對 production 資料或 schema 動手——**這類一律開 change**，因為影響不可逆

### 什麼時候 archive

wave 全部 section 完工、驗收腳本通過之後，**當次立刻 archive**，不要留到下一波。
archive 時必做兩件事：

1. spec delta 併進 `openspec/specs/<capability>/spec.md`
2. **把併進去的 spec 的 `## Purpose` 補寫成真正的一句話**——
   openspec 的 archive 指令會留下 `TBD - created by archiving change X` 佔位符，
   那不是 Purpose

> ⚠️ 這一步最容易被漏掉（真實案例：一個專案盤點時發現 27 個 spec 有 27 個
> Purpose 還是佔位符，規格庫變成只能靠檔名猜內容）。archive 完立刻補寫，
> 不要留到之後——之後永遠不會有人記得回來做。

### 什麼時候刪

**不刪。** 已完成的 change 搬到 `changes/archive/`，spec 留在 `specs/` 裡。
一個 capability 真的被廢掉時，在它的 spec.md 開頭標註「已停用，見 <取代它的 spec>」，
檔案保留——後面的人需要知道為什麼當初這樣設計。

### 放棄一個 change

不要直接刪目錄。在 `proposal.md` 最上方加一段「**已放棄**：<日期> <原因>」，
然後照常 archive。放棄的理由跟完成的理由一樣值錢。

---

## 5. 列管指令

```bash
# [TODO: 若程式碼在 app/ 子目錄，先 cd app]

# 列出所有 change 與完成度
openspec list

# 驗證單一 change 的格式（缺 spec delta / Scenario 會失敗）
openspec validate <change-name>

# [TODO: 寫一支腳本掃描 openspec/ 產生下方清單，並檢查缺件]
# node scripts/openspec-inventory.mjs
# node scripts/openspec-inventory.mjs --check   # 清單過期就 exit 1，接進 gate 用
# node scripts/openspec-inventory.mjs --write   # 磁碟變動後重新產生
```

**下方清單建議用腳本掃出來，不要手寫。** 這是刻意的設計——手寫索引一定會漂
（沒有人會記得每次新增/歸檔都回來改），過一陣子清單就會謊報 spec 數量、
謊報 active change 是哪些（真實案例都發生過）。

---

<!-- openspec:inventory:start -->

> 這個區塊建議由掃描腳本產生，**不要手改**。新專案從這裡開始，內容是空的。

### 進行中的 change（0）

（尚無）

### 活的 capability spec（0）

（尚無）

### 已歸檔的 change（0）

（尚無）

<!-- openspec:inventory:end -->
