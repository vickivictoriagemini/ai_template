# Sub-agent Cheatsheet — CEO 強制要求每個 sub-agent 第一步 Read

> 這份檔取代每個 sub-agent prompt 內重複貼的 boilerplate。CEO 派工時只 reference 路徑，agent Read 過就掌握所有共通資訊。
>
> 這是範本骨架，`[TODO]` 的地方要換成你專案的實際內容。

## 1. Working directory & dev server

- **Working dir**: [TODO: 專案根目錄，或子目錄如 `app/`]
- Dev server 應在 `http://localhost:3000`（或你的 port）運行
- 若連不到 → 不要自己啟動 dev server（CEO 才開），告訴 CEO

## 2. 真實 timestamp（不要自己估！）

每次寫 TEAM_LOG entry 用：
```bash
date -u +%Y-%m-%dT%H:%MZ   # 例：2026-05-10T16:43Z
```
**禁止**寫死自己估的時間 — 會跟其他 agent 撞，且時間軸會亂。

## 3. 測試帳號 / 登入方式

[TODO: 換成你專案的測試帳號登入方式，例如：]
```bash
curl -c /tmp/cookies.txt -X POST http://localhost:3000/api/auth/login \
  -H 'origin: http://localhost:3000' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -d 'email=test@example.com&password=xxx'
```

[TODO: 列出各測試帳號的用途與密碼來源，例如：]
- `admin@example.com` → 管理員
- `user1@example.com` → 一般使用者

**Login 必帶正確的 Origin header + 正確的 body 格式**，否則可能被 CSRF/CORS 檢查擋下。

## 4. DB schema 查詢

[TODO: 換成你的資料庫類型的查詢指令，例如：]
```bash
# SQLite
sqlite3 data/app.db ".tables"
sqlite3 data/app.db ".schema users"

# PostgreSQL
psql "$DATABASE_URL" -c "\dt"
psql "$DATABASE_URL" -c "\d users"
```

DB **絕不能直接 DELETE / DROP / TRUNCATE** — 共享資料，destructive。INSERT / UPDATE 既有 row 是 ok（看 lane）。

## 5. File lane（誰能改什麼）

> **這張表是可變編制，不是固定組織。** 崗位隨專案階段增減——新增與停用的規則見
> `.claude/CLAUDE.md` 的「CEO 的紀律 → 組織要隨專案調整」。
> 標成「閒置」的崗位**定義保留**，那個階段回來時直接啟用；不要刪掉。

[TODO: 依你的專案目錄結構重寫這張表。範例（來自一個 Next.js 專案）：]

| Lane | 狀態 | 可 TOUCH | 不能 TOUCH |
|------|------|----------|------------|
| **RD-Continuous (api)** | 使用中 | `src/app/api/**`, `src/lib/auth.ts` | front-end pages, components |
| **RD-Continuous (frontend)** | 使用中 | `src/app/(?!api/)**`, `src/components/**` | api routes, lib/auth |
| **RD-Continuous (lib)** | 使用中 | `src/lib/**` | 看 issue 範圍是哪個 lib 子模組 |
| **QA-\*** | 使用中 | `ISSUES.md`（verify only） | `src/**`, `data/**`, `public/**` |
| **CEO-Sweep** | 未啟用 | 跨 lane —— 為統籌者收尾多 lane 合修時使用 | 不改其他人明確在做的 openspec active change 檔 |

QA 角色：**永遠不能改 src/**。

**CEO-Sweep 例外規則**：只有 CEO 統籌者角色才能用；commit tag 必須以 `CEO-Sweep-YYYY-MM-DD` 開頭
（讓 git blame 能一眼認出跨 lane 是被 CEO 統籌授權的、不是誤觸）；每個 CEO-Sweep commit 上
TEAM_LOG entry 要註明 sweep 範圍 + 涉及的原 lane 清單。

## 6. Issue # 預分配（CEO 在 prompt 給）

CEO 派工時會在 prompt 內指定 `#N1 ~ #N2` 範圍。**不要自己挑** — 容易撞號。

⚠️ 若 `ISSUES.md` 是跟其他協作者共用的，對方也在開單，你看到的最大號不代表沒被用掉。
約定：**我方從 `[TODO: 起始號]` 起算，對方從 `[TODO: 起始號]` 起算，只定起點不設上限。**
真的必須自己開號時，取「我方號段內的最大號 + 1」，**不要**取整份檔案的最大號——那可能是對方的。
完整規則見 `.claude/CLAUDE.md`。

**開工前認領宣告（防止跟其他 contributor 或其他 wave 撞同一張卡）：**
```bash
GH_NUM=$(gh issue list --search "#<N> in:title" --state open --json number --jq '.[0].number')
gh issue view "$GH_NUM" --json assignees --jq '.assignees' 2>/dev/null
```
若已有 assignee 且不是自己 → 停手回報 CEO，不要重複做同一個 issue。

如果 prompt 沒給範圍但你需要 file 新 issue：
```bash
node -e 'const fs=require("fs"); const t=fs.readFileSync("ISSUES.md","utf-8"); const ns=[...t.matchAll(/^## #(\d+)/gm)].map(m=>+m[1]); console.log("next free:", Math.max(...ns)+1);'
```
然後跟 CEO 確認再 file。

## 7. RD 回應標準格式（≥ 80 字必含）

```markdown
**RD 回應：** [fixed by <你的 agent 名稱>] [src/path/file.tsx](src/path/file.tsx) 第 X-Y 行 <做了什麼 + 行為怎麼變 + side effect>。
**驗證：** <一行指令 + 預期結果>
```

**禁止**用變體格式（parser 雖容錯但混亂）。

## 8. TEAM_LOG batch entry 格式

agent 結束時 prepend 到 `TEAM_LOG.md` 最上面：
```markdown
## YYYY-MM-DDTHH:MMZ · <agent-name> · <一行 mission>

- Issues touched: #N1, #N2, ...
- <Verified|Fixed|Rejected|Inconclusive>: <counts>
- Files: <主要路徑>
- Notes: <CEO 該知道的 — 觀察 / 後續建議>
```

**timestamp 用真實 `date -u +%Y-%m-%dT%H:%MZ`**，不要瞎猜。

## 9. ISSUES.md 並發寫衝突

多個 agent 同時 Edit ISSUES.md → "File modified since read" 失敗。
**處理**：Read 重抓最新版 → Edit 重試（最多重試 3 次）。

## 10. Quality gate（agent 結束前必跑）

```bash
npx tsc --noEmit                    # 0 errors
node scripts/workflow-audit.mjs     # 整體 FSM 一致
node scripts/issue-health-check.mjs # # 不撞、欄位完整
```
**TS check 出錯就修到 0 errors 才算 done**。不要說「修了」但 TS 還紅。

## 11. 紅線（任何 agent 都不能做）

- ❌ `git commit / push / amend / rebase` — 只有 CEO/老闆 做
- ❌ `npm run build`（若很慢或耗費用）
- ❌ DROP / DELETE / TRUNCATE 任何 table
- ❌ 改 user role / passwords / sessions table（除非明確授權的 lane）
- ❌ 跨 lane 寫檔（看 §5）
- ❌ 把 reporter 寫成自己（用 reporter persona 對應的 label）

---

CEO 看到 cheatsheet 違反就直接退單。
