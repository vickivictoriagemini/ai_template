# [TODO: 專案名稱] — 工作手冊

> 兩種角色：**CEO**（波次統籌）和 **Contributor**（接 issue 實作）。各自走不同流程，共用同一份規則。
>
> 這份檔案是這套「老闆 + AI CEO + Contributor」協作模式的範本骨架，抽取自實戰累積的流程。
> 套用到新專案時，先讀 [`docs/AI_CEO_WORKING_MODEL.md`](../docs/AI_CEO_WORKING_MODEL.md) 了解「為什麼是這樣設計」，
> 再照 §8 的 checklist 把下面標 `[TODO]` 的地方換成你專案的實際內容。

[TODO: 如果程式碼在子目錄（例如 `app/`），在這裡說明：「所有實作工作在 `app/` 子目錄下進行。」]

---

## 上工前必讀

1. **[SUB_AGENT_CHEATSHEET.md](../SUB_AGENT_CHEATSHEET.md)** — File Lane、紅線、品質 gate、issue 編號規則、TEAM_LOG 格式。所有 sub-agent 第一步必 Read 這份。
2. **本波 active change 的 tasks.md**（CEO 派工時指定路徑）

---

## 文件地圖

### 流程文件
| 文件 | 用途 |
|---|---|
| [`docs/AI_CEO_WORKING_MODEL.md`](../docs/AI_CEO_WORKING_MODEL.md) | **整套協作模式的說明書** —— 角色分工、五層文件體系、wave 生命週期、memory 系統設計、經驗教訓。想理解「為什麼是這樣運作」就讀這份 |
| [`docs/MEMORY_SYSTEM.md`](../docs/MEMORY_SYSTEM.md) | **memory 系統的設計理由** —— 每個設計防堵什麼、三層階梯（程式碼 > 文件 > memory）、為什麼會腐化 |
| `ROADMAP.md` | **想做、還沒開規格**的大項目 + 跨項目方向決策。開了 proposal 就搬去 `openspec/changes/` |
| `ISSUES.md` | Bug tracker。QA 開單，RD 回。狀態：open → fixed → verified |
| `TEAM_LOG.md` | 每個 Wave 完工後 CEO prepend 一條。時間用 `date -u +%Y-%m-%dT%H:%MZ` |
| `DEV_LOG.md` | Release 級里程碑，功能上線或 breaking change 才寫 |

### 規格文件（openspec）
| 路徑 | 用途 |
|---|---|
| `openspec/README.md` | **openspec 的說明書與列管** —— 為什麼要有這一層、生命週期、規則，以及自動產生的清單 |
| `openspec/specs/` | 活的 capability spec 庫，RD 實作前讀對應 spec |
| `openspec/changes/` | 進行中的 change（proposal + design + tasks + 子 spec） |
| `openspec/changes/archive/` | 已完成 change 的歸檔 |

**不要在這裡手寫 change 或 spec 的清單。** 手寫索引一定會漂（沒有人會記得每次新增/歸檔都回來改）。
清單改由掃描腳本產生（參考 `docs/AI_CEO_WORKING_MODEL.md` §5 的 `openspec-inventory.mjs` 設計），
`CLAUDE.md` 只留一個指標連結。

**目前 active changes（未完成）：**
[TODO: 列出目前進行中的 openspec change 路徑，或說明用掃描腳本自動產生]

---

## [TODO: 專案的北極星指標]

> 範例（來自 TripTrust）：老闆定的四條 UX KPI，要同時達標，不是選一條做。
> 每個 PR / issue 至少對應一條，commit message 標籤標註對應哪一條。
> 互相衝突時問老闆，不要自己取捨。

| # | 指標 | 定義 |
|---|---|---|
| [TODO] | | |

---

## Wave 工作流程

```
1. CEO 在 openspec/changes/<wave-name>/ 建 proposal.md + design.md + tasks.md
2. Design + tasks push 上 main，team review 過（確認 decisions 沒爭議、task 拆分沒問題）才進入派工
3. CEO 對 tasks.md 每個 section（= 派工單位，一個 section 一個 Lane）各開一張 GitHub issue，
   標題格式 "<wave-name> §<N> <section 標題>"，這是認領牌，不重複寫 task 內容（內容仍在 tasks.md）
4. CEO 派工：每個 lane 一個 sub-agent，先 `gh issue edit <section#> --add-assignee @<agent-identifier或CEO自己>`
   宣告後才附上 tasks.md 路徑 + 對應 spec 路徑 + issue# 範圍
5. Sub-agent 完工 → 跑 quality gate → prepend TEAM_LOG entry → section issue 標記完成/close
6. CEO 跑驗收 script（見「驗收指令」）
7. Wave 通過 → openspec archive：spec 升入 openspec/specs/，change 搬到 archive/
```

### 派工 prompt 範本
```
你是 <角色>。
先 Read SUB_AGENT_CHEATSHEET.md。
再 Read openspec/changes/<wave>/tasks.md。
你負責 Lane <N>（task <X.X> ~ <Y.Y>），對應 GitHub issue #<section#>（CEO 已 assign 給你，開工前可以
`gh issue view <section#>` 確認沒人搶）。
Issue# 範圍：#N1–#N2。
對應 spec：openspec/specs/<capability>/spec.md。
完工條件：quality gate 全過 + TEAM_LOG entry prepend + section issue close。
```

---

## CEO 的紀律

Sub-agent 那一側的規範寫在 `SUB_AGENT_CHEATSHEET.md`。這一節是 CEO 自己這側的 ——
**派工前要做什麼、收工後要驗什麼、以及怎麼讓團隊跑得快。**

### 派工前

1. 讀 `TEAM_LOG.md` 最近 5–10 條，確認沒有 agent 卡住、沒有 issue 長期沒人接
2. 確認 file lane 不撞（≥2 個 agent 並行時必檢查——可以寫一支掃描腳本比對各 lane 正在碰的檔案範圍）
3. **issue # 事先分配好寫進 prompt**，不要讓 agent 自己挑（會撞號）

#### Issue 編號分段 —— 若有多方（例如老闆的另一個 human contributor）同時開單

`ISSUES.md` 如果是**多方共用**的 tracker，但各自在本機開單，開單當下看不到對方剛用掉哪些號，
就會撞號（真實案例：TripTrust 一次撞了四個號）。約定做法：

| | 號段 |
|---|---|
| **我方（CEO / 本機 sub-agent）** | 從 **`[TODO: 起始號碼]`** 起算 |
| **對方（contributor）** | 從 **`[TODO: 起始號碼]`** 起算 |

**只定起點，不設上限。** 誰先用到對方的起點，就自然往下一個空白區段挪，不需要重新協調。

**撞號了怎麼辦：** 後發現的那一方改號，改號時在單子頂端留一段
「📌 原本是 #X，與對方的 #X 撞號」，不要把舊號直接抹掉（PR / commit / GH issue 都還引用著舊號）。

### 收工後

4. 收到 task-notification **立即處理**：讀回報 → 確認 agent 有寫 TEAM_LOG（沒寫 CEO 自己補）→ 更新 todo
5. **Agent 自己說 PASS 不算數。** CEO 必須親自跑一次老闆的操作路徑再驗收。
   若涉及瀏覽器自動化：每個操作之間留足夠等待時間讓畫面穩定，不要用過短的間隔——
   多輪 hotfix 互相打架，常見根因就是 agent 沒等畫面穩定就做下一步判斷。
6. 多 lane 的 wave：**每個 lane 都 PASS ≠ 整頁 PASS**。沒有人負責「整體效果」，只有 CEO。
   整體驗收失敗時**不要 retry lane**（lane 沒做錯）——回 openspec proposal 補一個新 lane。
7. CEO 親自跑腳本補完 agent 做不到的事之後，**三步缺一不可**：
   apply ✓ → validator ✓ → **`ISSUES.md` 狀態翻牌 ✓**

### [TODO: 老闆的開發環境不是測試環境（如適用）]

> 範例（TripTrust 真實案例）：老闆用本機 dev server 看畫面、驗收、回報問題，那對他是工作環境，
> 不是可以隨便壓的測試靶。曾經因為在 server 活著時執行 `git stash`/`checkout`/`rebase`，
> 或跑整套自動化測試打同一個 port，導致老闆看到的頁面壞掉或整站連不上。
>
> 規則：
> 1. 要跑會佔用資源的測試就先講一聲，或換一個獨立 port
> 2. 會重寫工作目錄的 git 操作做完之後一定重啟 dev server
> 3. **卡死時先採證再重啟**——重啟會讓問題消失但不會讓它不再發生，
>    採證用系統工具抓執行堆疊/log/連線狀態，只要幾秒，不會讓對方多等

### 帶團隊 —— 目標沒達成前不接受收工

CEO 不只是驗收者，是**帶團隊的人**。sub-agent 不會自己爭取進度，
派工品質和收工標準直接決定團隊產出。常見的怠惰樣態，看到就退回：

| 樣態 | 怎麼處理 |
|---|---|
| 「大部分完成，剩下的不影響」 | 退回。**是不是不影響由 CEO 判斷，不是 agent** |
| 自己把 task 縮小到做得完的範圍，然後宣告完成 | 退回，並附上原始 task 範圍 |
| 「權限不足 / 被擋住」但沒說卡在哪一行 | 要求講出確切指令與錯誤訊息。真的被擋，CEO 自己跑 |
| 報 PASS 但沒附可驗證的輸出 | 退回。回報必須含**可以貼上重跑的指令 + 預期結果** |

**效率面：**

- **能平行就平行。** lane 不撞就同時開，不要一個做完才開下一個
- **不要為了等一個 agent 而讓其他 lane 閒置**
- 每個 prompt 都要有明確範圍與完工條件，否則 agent 會漫遊。
  完工條件要寫成**可以執行的檢查**，不是「做好 X 功能」

**CEO 自己也不能怠惰**：agent 卡住時，CEO 的工作是排除障礙或自己接手，
不是把「agent 做不到」當成 wave 沒完成的理由回報給老闆。

### Issue 善後 —— 修完就要回、要關、要留下線索

**⚠️ issue 有兩個地方，若你同時用本地 tracker + GitHub issue，兩邊都要更新**：

| 位置 | 角色 |
|---|---|
| `ISSUES.md` | 本地單號，內容的權威來源（完整根因、RD 回應、驗證指令）|
| GitHub issues | 協作用的認領牌與對外溝通，標題帶本地單號 |

**⚠️ 不是每張單都要開在 GitHub：**

| 這張單是…… | 開在哪 |
|---|---|
| **跟對方有關**：要他決定、他的領域、或需要跟他討論 | **兩邊都開**，GH 標題前面放本地單號 |
| **我方自己發現、自己修得掉**的問題 | **只記在 `ISSUES.md`**，不要開 GH issue |

開在 GitHub 的成本是佔用對方的注意力。把純內部的 bug 丟上去，
等於要對方讀一堆跟他無關的東西，真正需要他回的單反而被稀釋。

修完一張 issue，**三件事缺一不可**：

1. **回覆**：在 GH issue 留言說明修法，**明確寫出哪個 PR、哪個 commit**。
   不要只寫「已修」——之後讀的人要能直接跳到那個 diff
2. **關閉**：PR merge 之後關掉。PR body 寫 `Closes #<N>` 可以自動關
3. **`ISSUES.md` 翻牌**：本地單號改 `fixed`，補 RD 回應與驗證指令

**只修了一部分就不要關。** 把剩下的部分另開一張單，在原單留言指向它，
再關原單。**留一張「修了八成」的單開著，比關掉更糟**——沒有人知道還缺什麼。

**別人開的單修好了也要回。** 對方要知道可以不用再處理。

**定期掃：** 每次收工前看一遍開著的 issue，問「這張還成立嗎」。
已經被其他改動順帶解掉的，補上說明再關。

---

### 組織要隨專案調整

`SUB_AGENT_CHEATSHEET.md` 的 File Lane Registry **不是固定編制**，
它描述的是「這個階段需要哪些崗位」。專案階段變了就要調整。

**新增崗位：**
- 新的 active change 涉及的檔案範圍，現有 lane 沒人涵蓋 → 開新崗位
- 某個 lane 持續塞車（issue 堆積、一個 agent 做不完）→ 拆成兩個
- 新崗位要同時定義「可 TOUCH」與「**不能** TOUCH」。沒有邊界的崗位會撞檔

**停用崗位：**
- 連續幾個 wave 沒被派工，或它負責的階段已經結束 → 在 registry 標註**「目前沒有派工」**
- **不要刪掉定義。** 那個階段之後可能回來，留著隨時能啟用；TEAM_LOG 的歷史紀錄也一律保留

**什麼時候檢查：** 每次專案階段轉換時（一組 change 完成、開始新主題），
CEO 對照「現在的 active change」與「registry 現有崗位」，補上缺的、標註閒置的。

**CEO 對組織效率負責。** 崗位對不上工作，就會出現「該做的事沒人有權限碰」，
或是「所有事情塞給同一個泛用 lane 導致無法平行」。兩者都是 CEO 的責任，不是 agent 的。

---

## 學到新東西時 —— 寫在哪裡

**不是每件事都該進 memory。** 順序是「能自動執行就自動執行，其次寫文件，最後才是 memory」：

| 能寫成…… | 就寫成那個 | 進 memory？ |
|---|---|---|
| 腳本 / hook / 驗證器 | 讓它自動發生，壞了會擋下來 | ❌ |
| `CLAUDE.md` / spec / playbook | 寫成規則，查得到 | ❌ |
| 都不行 —— 是**判斷方式**，不是步驟 | — | ✅ |

**為什麼是這個順序：** 程式碼會強制執行，文件查得到，memory 只是「希望下次會想起來」——
最弱的一種。把能自動化的事放進 memory，等於用最不可靠的機制守最容易守的事，
還會稀釋掉真正需要判斷力的條目。

**⚠️ 「寫進文件」要看是寫進哪一份。** 只有 `CLAUDE.md` 和 `.claude/memory/` 會自動載入；
`docs/`、`README.md`、`SUB_AGENT_CHEATSHEET.md` 都要有人主動打開才讀得到。
所以行為規則要寫進 `CLAUDE.md`（或由腳本強制），寫進 `docs/` 的是背景說明，不是規則。

**寫完 memory 要問老闆值不值得 submit 進 repo**（`./scripts/sync-memory.sh backup <檔名>`，
指名搬，不要 `--all`）。完整的策展原則見 `docs/AI_CEO_WORKING_MODEL.md` §6。

**定期回頭砍。** 對每條問：現在還成立嗎？已經被程式碼或 `CLAUDE.md` 取代了嗎？
任一個答案是「是」就刪——**過期的 memory 比沒有 memory 更糟**，它會把判斷帶往錯的方向。

---

## Capability Spec 索引

**清單不寫在這裡。** 有哪些 spec、各自幾條 Requirement、Purpose 寫了沒有，
看 `openspec/README.md` 自動產生的區塊。手寫的索引一定會漂，所以不要手寫。

---

## 驗收指令

```bash
[TODO: 換成你的專案指令]

# TypeScript
npx tsc --noEmit

# 派工前：掃 [open] issue 的 file lane，確認多個 RD agent 不會撞檔
node scripts/lane-scanner.mjs

# 收工後：一批 agent 做完、開下一波之前必跑
node scripts/post-agent-gate.mjs

# 規格驗證
openspec validate <change-name>

# openspec 列管 —— 新增/歸檔 change 或 spec 之後跑
node scripts/openspec-inventory.mjs --check
```

---

## Contributor 流程（接 issue 實作）

```
1. 從 ISSUES.md 找到 #N，確認狀態是 open
2. 認領宣告（防止撞卡）：用標題搜尋 `gh issue list --search "#N in:title"` 找對應 GH issue（沒有就新建），
   確認沒人 assign → `gh issue edit <GH#> --add-assignee @me`，ISSUES.md 狀態改 `in-progress`。
   若已有其他人 assign，停手回報，不要重複做。
3. 讀對應的 spec（openspec/specs/<capability>/spec.md）
4. 建 branch：<your-name>/#<N>-<kebab-feature-name>
5. 實作
6. Quality gate：
     npx tsc --noEmit
     node scripts/workflow-audit.mjs
     node scripts/issue-health-check.mjs
7. 在 ISSUES.md 把 #N 狀態改成 fixed，補上 RD 回應
8. git add（只加 lane 內的檔案）→ git commit → git push
9. gh pr create（body 帶 `Closes #<N>, closes #<GH#>` 讓 GH issue 隨 PR merge 自動關閉解除認領），assign reviewer = CEO
```

### PR 格式
```
title：#<N> <issue 標題>
body：
  ## 變更
  <做了什麼>

  ## 驗證
  <一行指令 + 預期結果>

  ## Issue
  Closes #<N>
```

---

## 紅線（任何 agent 都不能做）

- `npm run build`（若很慢或耗費用）— 除非明確要求
- DROP / DELETE / TRUNCATE 任何 table
- 跨 File Lane 寫檔（詳見 CHEATSHEET）
- `git push --force` — 任何情況都不行
- **程式碼直接推 `main`** — 見下

### 程式碼一律走 branch + PR，不直接推 main

| 改的是 | 怎麼走 |
|---|---|
| `src/**`、`scripts/**`、infra 設定、workflow —— **任何會執行的東西** | **一定** branch → PR → review → merge |
| `ISSUES.md`、`TEAM_LOG.md`、`DEV_LOG.md`、`ROADMAP.md` —— 純 tracker 更新 | 可以直接推 `main` |
| `CLAUDE.md`、`SUB_AGENT_CHEATSHEET.md`、`docs/**` —— 規則與說明 | 可以直接推 `main`，但要在回報裡講一句 |

**為什麼連「我很確定這個改動是對的」也不例外：** 會過型別檢查、過測試的錯誤，
正是最需要第二雙眼睛的那種——寫的人自己看不出盲點是很正常的事。

**CEO 自己也適用。** 這條不是只寫給 sub-agent 的。

**已經推上去才發現的話：** 不要自己 `git revert` 了事——`main` 可能是跟其他人
共用的分支，來回的 revert 會干擾對方。**先告訴老闆，由他決定**要撤回改走 PR、還是留著事後 review。
