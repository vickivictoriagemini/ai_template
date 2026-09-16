啟動一個 issue 的完整實作流程。

[TODO: 若程式碼在 app/ 子目錄，下面的路徑要加上 app/ 前綴]

## 步驟

1. 在 `ISSUES.md` 找到 #$ARGUMENTS，確認狀態是 `open`，讀取標題與重現步驟
2. **認領宣告（防止撞卡）**——注意：GitHub issue 編號由 GitHub 自動遇號，**不等於** ISSUES.md 的 #$ARGUMENTS，用標題搜尋比對：
   ```bash
   GH_NUM=$(gh issue list --search "#$ARGUMENTS in:title" --state open --json number --jq '.[0].number')
   if [ -z "$GH_NUM" ]; then
     GH_NUM=$(gh issue create --title "#$ARGUMENTS <issue 標題>" --body "詳見 ISSUES.md #$ARGUMENTS" --json number --jq '.number' 2>/dev/null || gh issue create --title "#$ARGUMENTS <issue 標題>" --body "詳見 ISSUES.md #$ARGUMENTS")
   fi
   gh issue view "$GH_NUM" --json assignees --jq '.assignees'
   ```
   - 若 assignees 非空且不是自己 → **停手**，回報使用者「#$ARGUMENTS 已被 <人名> 認領（GH issue #$GH_NUM），不要重複做」，流程結束
   - 若無人認領 → `gh issue edit "$GH_NUM" --add-assignee @me`，並把 `ISSUES.md` 該筆狀態從 `open` 改成 `in-progress`，commit 這一行變動
3. 根據 issue 內容判斷對應的 capability spec，Read `openspec/specs/<capability>/spec.md`
4. 確認這個 issue 屬於哪個 File Lane（參照 `SUB_AGENT_CHEATSHEET.md` §5）
5. 建立 branch：
   ```bash
   git checkout -b <your-name>/#$ARGUMENTS-<kebab-feature-name>
   ```
6. 實作修改（只動 lane 內的檔案）
7. 跑 quality gate：
   ```bash
   npx tsc --noEmit
   node scripts/workflow-audit.mjs
   node scripts/issue-health-check.mjs
   ```
8. 在 `ISSUES.md` 把 #$ARGUMENTS 狀態改成 `fixed`，填入 RD 回應欄位
9. Commit 並推上去：
   ```bash
   git add <lane 內的檔案>
   git commit -m "#$ARGUMENTS <issue 標題簡述>"
   git push -u origin HEAD
   ```
10. 開 PR（用 `$GH_NUM` 讓 merge 時自動關閉 GH issue、解除認領）：
   ```bash
   gh pr create \
     --title "#$ARGUMENTS <issue 標題>" \
     --body "$(cat <<EOF
   ## 變更
   <做了什麼>

   ## 驗證
   <一行指令 + 預期結果>

   ## Issue
   Closes ISSUES.md #$ARGUMENTS, closes #$GH_NUM
   EOF
   )"
   ```

完成後回報 PR URL。
