# AI Wave 協作範本

一套「老闆 + AI CEO + Contributor」的協作骨架：CEO 統籌、sub-agent 派工、
issue tracker、openspec 規格先行、跨 session 記憶。抽取自一個實戰累積
15+ merged PR、1100+ issue、90+ wave 的真實專案，機制驗證過，可以直接套用到新專案。

## 這是什麼

不是一個應用程式框架，是**一套流程骨架**：幾份文件（規則、記憶、規格、日誌）
加上幾支腳本（環境還原、記憶同步、pre-commit gate），讓你和 AI 協作時：

- AI 不會每次開新對話就忘記上次踩過的坑
- 流程寫進 repo，不是只存在某次對話的記憶裡
- 有明確的「誰能改什麼」邊界，多個 agent 平行工作不會互相撞檔
- 每個「完成」都綁一條可重跑的驗證指令，不是 AI 自己說了算

## 怎麼開始用

1. **把這個骨架複製到你的新專案**（整個目錄樹，含隱藏檔）
2. **讀 [`docs/AI_CEO_WORKING_MODEL.md`](docs/AI_CEO_WORKING_MODEL.md)**——這份講「為什麼」，
   了解角色分工、五層文件體系、wave 生命週期之後，回頭客製化才不會走樣
3. **照 `AI_CEO_WORKING_MODEL.md` §8 的 checklist** 把以下檔案的 `[TODO]` 換成你的專案內容：

   | 檔案 | 要改的地方 |
   |---|---|
   | `.claude/CLAUDE.md` | 角色名稱、專案目錄結構、北極星指標、驗收指令、issue 編號分段 |
   | `SUB_AGENT_CHEATSHEET.md` | File Lane 表（依你的 code 結構）、測試帳號、DB 查詢指令 |
   | `scripts/setup-workspace.sh` | 依賴安裝路徑、資料庫還原步驟（若有） |
   | `scripts/git-hooks/pre-commit` | 專案特定的靜態檢查（若有） |

4. **跑一次 `./scripts/setup-workspace.sh`** 驗證骨架本身能動
5. **裝 openspec CLI**：`npm i -g @fission-ai/openspec`
6. **開第一個 wave**，哪怕很小——先走完一次完整流程，建立肌肉記憶

## 目錄結構

```
.claude/
  CLAUDE.md              工作手冊：角色、流程、紅線、驗收指令
  memory/                AI 協作記憶（新專案從空的開始累積）
  skills/                Slash-command 對應的技能（openspec 系列、commit-message、todo-priority）
  commands/              Slash command 定義
  settings.json          團隊共用的工具權限（刻意留空，依實際需要加）
docs/
  AI_CEO_WORKING_MODEL.md   協作模式完整說明書——先讀這份
  MEMORY_SYSTEM.md          Memory 系統的設計理由與復刻指南
openspec/
  README.md              openspec 規則、生命週期、列管指令
  specs/                 已完成的 capability spec（新專案從空的開始）
  changes/               進行中的 change；archive/ 放已完成的
scripts/
  setup-workspace.sh      新機器 clone 後跑這支，一次還原環境
  sync-memory.sh          AI 協作記憶的雙向同步（本機 ↔ repo）
  git-hooks/pre-commit     自動跑型別檢查 + issue audit + memory drift 偵測
SUB_AGENT_CHEATSHEET.md  Agent 守則：File Lane、格式規範、quality gate
TEAM_LOG.md              團隊時間軸（每個 wave 一條）
DEV_LOG.md               Release 級里程碑
ISSUES.md                Bug tracker
ROADMAP.md               想做、還沒開規格的大項目
```

## 這套模式解決什麼問題

見 [`docs/AI_CEO_WORKING_MODEL.md` §1](docs/AI_CEO_WORKING_MODEL.md)，簡短版：

| 失敗模式 | 這套模式怎麼擋 |
|---|---|
| AI 每次開新對話就忘記踩過的坑 | `.claude/memory/` 累積判斷，跨機器可還原 |
| 流程漂移（這次用 A 流程、下次用 B） | `CLAUDE.md` + `SUB_AGENT_CHEATSHEET.md` 進版控，是唯一真相 |
| AI 自稱完成，一驗收就是壞的 | Quality gate 自動化 + 「開單的人才能驗收」硬規則 |

## 已知限制

老實列出來，別當成萬靈丹——見 [`docs/AI_CEO_WORKING_MODEL.md` §9](docs/AI_CEO_WORKING_MODEL.md)。
Memory 會膨脹需要定期淘汰、跨 session 長任務仍有交接成本、AI 判斷品質不穩定，
quality gate 是唯一真正可靠的防線。
