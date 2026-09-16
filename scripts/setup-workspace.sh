#!/usr/bin/env bash
#
# setup-workspace.sh — 新機器 clone 後跑這支，把開發環境 + AI 協作模式一次還原
#
# 用法：
#   git clone <your-repo-url>
#   cd <your-repo>
#   ./scripts/setup-workspace.sh
#
# 這支會做的事（全部 idempotent，重跑安全）：
#   1. 檢查必要工具（node / npm / git）
#   2. npm install（依你的專案結構調整路徑）
#   3. 還原 Claude Code 協作記憶（.claude/memory → ~/.claude/projects/<slug>/memory）
#   4. 掛上 git hooks（pre-commit 跑型別檢查 + issue audit）
#   5. 安裝 openspec CLI（規格驅動流程用）
#   6. 建立 .env（若不存在，從 .env.example 複製）
#   7. 驗證環境
#   8. 印出「還需要你手動做」的清單
#
# ⚠️ 這是範本骨架。套用到你的專案時，至少要改：
#   - APP_DIR（如果程式碼不在 app/ 子目錄，改成你的路徑，或直接刪掉這個變數用 REPO_ROOT）
#   - 第 2 步的 npm install 路徑
#   - 第 6 步之後，補上你專案特定的還原步驟（例如資料庫還原、外部服務連線檢查）
#   - 「還需要你手動做的事」清單，換成你專案實際需要的手動步驟
#
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT"   # TODO: 如果程式碼在子目錄（例如 app/），改成 "$REPO_ROOT/app"
cd "$REPO_ROOT"

# ── 輸出樣式 ──────────────────────────────────────────────
BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'
YEL=$'\033[33m'; CYA=$'\033[36m'; RST=$'\033[0m'
STEP=0
TOTAL_STEPS=8
step()  { STEP=$((STEP+1)); printf "\n${BOLD}${CYA}[%d/%d] %s${RST}\n" "$STEP" "$TOTAL_STEPS" "$1"; }
ok()    { printf "  ${GRN}✓${RST} %s\n" "$1"; }
warn()  { printf "  ${YEL}!${RST} %s\n" "$1"; }
fail()  { printf "  ${RED}✗${RST} %s\n" "$1"; }
info()  { printf "  ${DIM}%s${RST}\n" "$1"; }

MANUAL_TODO=()

printf "${BOLD}[TODO: 專案名稱] — 工作區還原${RST}\n"
printf "${DIM}repo: %s${RST}\n" "$REPO_ROOT"

# ── 1. 前置工具 ───────────────────────────────────────────
step "檢查必要工具"
MISSING=0
for tool in node npm git; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool $(${tool} --version 2>/dev/null | head -1)"
  else
    fail "$tool 沒裝 — 必要"; MISSING=1
  fi
done
# TODO: 若專案用 git-lfs（大檔案：資料庫備份、素材圖檔）在這裡加檢查：
# if command -v git-lfs >/dev/null 2>&1; then ok "git-lfs"; else fail "git-lfs 沒裝"; MISSING=1; fi
[ "$MISSING" -eq 1 ] && { fail "缺必要工具，先裝完再跑"; exit 1; }

# ── 2. npm install ───────────────────────────────────────
step "安裝 npm 依賴"
if [ -d "$APP_DIR" ] && [ -f "$APP_DIR/package.json" ]; then
  (cd "$APP_DIR" && npm install --no-fund --no-audit 2>&1 | tail -3) && ok "依賴裝好"
else
  fail "找不到 $APP_DIR/package.json"; exit 1
fi

# ── 3. 還原 Claude Code 協作記憶 ──────────────────────────
step "還原 AI 協作記憶（這步讓新機器的 Claude 記得所有踩過的坑）"
if [ -x "$REPO_ROOT/scripts/sync-memory.sh" ]; then
  "$REPO_ROOT/scripts/sync-memory.sh" restore && ok "memory 還原完成"
  info "之後學到新東西記得 ./scripts/sync-memory.sh backup 存回 repo"
else
  warn "scripts/sync-memory.sh 不存在或不可執行"
  info "手動：chmod +x scripts/sync-memory.sh && ./scripts/sync-memory.sh restore"
fi

# ── 4. Git hooks ─────────────────────────────────────────
step "掛上 git hooks（pre-commit 自動跑型別檢查 + issue audit）"
if [ -d "$REPO_ROOT/scripts/git-hooks" ]; then
  git config core.hooksPath scripts/git-hooks && ok "core.hooksPath → scripts/git-hooks"
  info "臨時跳過：git commit --no-verify"
else
  warn "scripts/git-hooks 不存在 — 跳過"
fi

# ── 5. openspec CLI ──────────────────────────────────────
step "安裝 openspec CLI（規格驅動流程）"
if command -v openspec >/dev/null 2>&1; then
  ok "openspec 已安裝（$(openspec --version 2>/dev/null || echo 'version unknown')）"
else
  warn "openspec 沒裝"
  info "安裝：npm i -g @fission-ai/openspec"
  MANUAL_TODO+=("npm i -g @fission-ai/openspec   # 規格驅動流程要用")
fi

# ── 6. .env ──────────────────────────────────────────────
step "環境變數"
if [ -f "$APP_DIR/.env" ] || [ -f "$APP_DIR/.env.local" ]; then
  ok ".env 已存在（不覆蓋）"
elif [ -f "$APP_DIR/.env.example" ]; then
  cp "$APP_DIR/.env.example" "$APP_DIR/.env"
  ok "從 .env.example 建了 .env"
  MANUAL_TODO+=("填 $APP_DIR/.env 的實際金鑰／連線字串")
else
  warn "找不到 .env.example"
fi

# TODO: 專案特定的還原步驟放在這裡，例如：
#   - 資料庫還原（從備份檔還原到本機/測試資料庫）
#   - 外部服務連線檢查（Supabase / Stripe / 第三方 API 測試連線）
#   - 種子資料 seed 腳本

# ── 7. 驗證 ──────────────────────────────────────────────
step "驗證安裝結果"
if [ -f "$APP_DIR/tsconfig.json" ]; then
  if (cd "$APP_DIR" && npx tsc --noEmit 2>&1 | head -5 | grep -q .); then
    warn "tsc --noEmit 有錯（上面五行），可能是依賴還沒齊或 .env 未設定"
  else
    ok "tsc --noEmit 乾淨"
  fi
else
  info "沒有 tsconfig.json，跳過型別檢查"
fi

# ── 8. 手動清單 ──────────────────────────────────────────
step "還需要你手動做的事"
MANUAL_TODO+=("gh auth login   # 讓 AI 能查 / 開 GitHub issue")
MANUAL_TODO+=("cd $APP_DIR && npm run dev   # 啟動後確認能開起來")
MANUAL_TODO+=("讀 docs/AI_CEO_WORKING_MODEL.md   # 了解這套協作模式怎麼運作")
for t in "${MANUAL_TODO[@]}"; do printf "  ${YEL}□${RST} %s\n" "$t"; done

printf "\n${BOLD}${GRN}環境還原完成。${RST}\n"
printf "${DIM}下一步：讀 README.md，並依照 docs/AI_CEO_WORKING_MODEL.md §8 的 checklist 客製化 CLAUDE.md / SUB_AGENT_CHEATSHEET.md。${RST}\n\n"
