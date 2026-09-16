#!/usr/bin/env bash
#
# sync-memory.sh — 在 repo 的 .claude/memory/ 與本機 Claude Code memory 之間同步
#
# ── 核心觀念（老闆 directive 2026-09-10）──────────────────────────
#   不是每條 memory 都該進 repo。本機 memory 會累積大量 session 觀察、
#   暫時性專案狀態、還在驗證中的假設 —— 那些留在本機就好。
#   **只有老闆認定是「重點 / 重大經驗」的才 submit**。
#
#   所以：
#     backup  = 指名搬（要講哪幾個檔），預設不做全量
#     restore = 只合併不刪（保護本機還沒 submit 的草稿）
#
# ── 為什麼需要這支 ────────────────────────────────────────────────
#   Claude Code 讀 memory 的位置是 ~/.claude/projects/<專案路徑 slug>/memory/，
#   slug 由絕對路徑算出（/ → -），換機器會變。所以檔案進 repo ≠ 自動生效。
#
# ── 用法 ──────────────────────────────────────────────────────────
#   ./scripts/sync-memory.sh status
#       比較兩邊，列出「本機獨有（候選）」「內容不同」「repo 獨有」
#
#   ./scripts/sync-memory.sh backup <檔名> [檔名...]
#       把指定的 memory 從本機搬進 repo（老闆策展後才跑）
#       檔名可省略 .md，例：backup feedback_xxx project_yyy
#
#   ./scripts/sync-memory.sh backup --all
#       全量搬（少用，會把本機所有 memory 都推進 repo）
#
#   ./scripts/sync-memory.sh restore
#       repo → 本機，**只新增/覆蓋，不刪本機獨有的檔**
#
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_MEM="$REPO_ROOT/.claude/memory"
SLUG="$(echo "$REPO_ROOT" | sed 's|/|-|g')"
LOCAL_MEM="$HOME/.claude/projects/$SLUG/memory"

BOLD=$'\033[1m'; DIM=$'\033[2m'; GRN=$'\033[32m'; YEL=$'\033[33m'; CYA=$'\033[36m'; RST=$'\033[0m'

usage() { sed -n '3,32p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'; exit 1; }
[ $# -ge 1 ] || usage

# 補 .md 副檔名
norm() { case "$1" in *.md) echo "$1";; *) echo "$1.md";; esac; }

case "$1" in
  # ────────────────────────────────────────────────────────────
  status)
    printf "${BOLD}repo${RST} : %s\n" "$REPO_MEM"
    printf "${BOLD}本機${RST} : %s\n\n" "$LOCAL_MEM"
    [ -d "$LOCAL_MEM" ] || { echo "⚠️  本機 memory 目錄不存在 — 跑 restore 建立"; exit 0; }
    [ -d "$REPO_MEM" ]  || { echo "⚠️  repo memory 目錄不存在"; exit 0; }

    CAND=(); DIFF=(); ONLY_REPO=()
    for f in "$LOCAL_MEM"/*.md; do
      [ -e "$f" ] || continue
      b=$(basename "$f")
      if [ ! -f "$REPO_MEM/$b" ]; then CAND+=("$b")
      elif ! diff -q "$f" "$REPO_MEM/$b" >/dev/null 2>&1; then DIFF+=("$b"); fi
    done
    for f in "$REPO_MEM"/*.md; do
      [ -e "$f" ] || continue
      b=$(basename "$f")
      [ -f "$LOCAL_MEM/$b" ] || ONLY_REPO+=("$b")
    done

    if [ ${#CAND[@]} -gt 0 ]; then
      printf "${YEL}本機獨有 — submit 候選（老闆判斷值不值得進 repo）${RST}\n"
      for b in "${CAND[@]}"; do
        d=$(grep -m1 "^description:" "$LOCAL_MEM/$b" 2>/dev/null | sed 's/^description: *//' | cut -c1-70)
        printf "  ${CYA}%-52s${RST} %s\n" "$b" "${d:-（無 description）}"
      done
      echo ""
    fi
    if [ ${#DIFF[@]} -gt 0 ]; then
      printf "${YEL}內容不同（本機已更新，repo 是舊版）${RST}\n"
      printf "  %s\n" "${DIFF[@]}"; echo ""
    fi
    if [ ${#ONLY_REPO[@]} -gt 0 ]; then
      printf "${DIM}repo 獨有（本機沒有 — 跑 restore 會補回來）${RST}\n"
      printf "  %s\n" "${ONLY_REPO[@]}"; echo ""
    fi
    if [ ${#CAND[@]} -eq 0 ] && [ ${#DIFF[@]} -eq 0 ] && [ ${#ONLY_REPO[@]} -eq 0 ]; then
      printf "${GRN}✅ 兩邊一致（%s 個檔）${RST}\n" "$(ls "$REPO_MEM"/*.md 2>/dev/null | wc -l | tr -d ' ')"
    else
      printf "${DIM}要 submit 哪幾個：./scripts/sync-memory.sh backup <檔名> [檔名...]${RST}\n"
    fi
    ;;

  # ────────────────────────────────────────────────────────────
  backup)
    shift
    [ -d "$LOCAL_MEM" ] || { echo "❌ 本機 memory 不存在：$LOCAL_MEM"; exit 1; }
    mkdir -p "$REPO_MEM"

    if [ $# -eq 0 ]; then
      printf "${YEL}backup 需要指名檔案${RST}（不是每條 memory 都該進 repo —— 只有重點 / 重大經驗才 submit）\n\n"
      printf "  先看候選：  ./scripts/sync-memory.sh status\n"
      printf "  再指名搬：  ./scripts/sync-memory.sh backup feedback_xxx project_yyy\n"
      printf "  ${DIM}真要全量：  ./scripts/sync-memory.sh backup --all${RST}\n"
      exit 1
    fi

    if [ "$1" = "--all" ]; then
      printf "${YEL}⚠️  全量 backup：把本機所有 memory 推進 repo${RST}\n"
      rsync -a "$LOCAL_MEM"/*.md "$REPO_MEM/" 2>/dev/null
      printf "${GRN}✓${RST} 完成（repo 現有 %s 個檔）\n" "$(ls "$REPO_MEM"/*.md 2>/dev/null | wc -l | tr -d ' ')"
    else
      OK=0; MISS=0
      for raw in "$@"; do
        b=$(norm "$raw")
        if [ -f "$LOCAL_MEM/$b" ]; then
          cp "$LOCAL_MEM/$b" "$REPO_MEM/$b"
          printf "  ${GRN}✓${RST} %s\n" "$b"; OK=$((OK+1))
        else
          printf "  ${YEL}✗${RST} %s ${DIM}(本機找不到)${RST}\n" "$b"; MISS=$((MISS+1))
        fi
      done
      printf "\n搬了 %d 個" "$OK"; [ "$MISS" -gt 0 ] && printf "，%d 個找不到" "$MISS"; printf "\n"
    fi

    # MEMORY.md 索引一定要跟著更新，否則新機器的 Claude 讀不到新條目
    if [ -f "$LOCAL_MEM/MEMORY.md" ] && ! diff -q "$LOCAL_MEM/MEMORY.md" "$REPO_MEM/MEMORY.md" >/dev/null 2>&1; then
      cp "$LOCAL_MEM/MEMORY.md" "$REPO_MEM/MEMORY.md"
      printf "${GRN}✓${RST} MEMORY.md 索引一併更新\n"
    fi
    printf "${DIM}記得：git add .claude/memory/ && git commit${RST}\n"
    ;;

  # ────────────────────────────────────────────────────────────
  restore)
    [ -d "$REPO_MEM" ] || { echo "❌ repo memory 不存在：$REPO_MEM"; exit 1; }
    mkdir -p "$LOCAL_MEM"
    # 關鍵：不加 --delete。repo 只收策展過的重點 memory，本機還有許多
    # 未 submit 的草稿 / session 觀察，restore 不能把它們刪掉。
    rsync -a "$REPO_MEM"/*.md "$LOCAL_MEM/" 2>/dev/null
    printf "${GRN}✓${RST} restore 完成：repo → 本機（合併，未刪本機獨有檔案）\n"
    printf "  repo %s 個 → 本機現有 %s 個\n" \
      "$(ls "$REPO_MEM"/*.md 2>/dev/null | wc -l | tr -d ' ')" \
      "$(ls "$LOCAL_MEM"/*.md 2>/dev/null | wc -l | tr -d ' ')"
    printf "  位置：%s\n" "$LOCAL_MEM"
    ;;

  *) usage ;;
esac
