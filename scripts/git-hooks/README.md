# Git hooks (opt-in per clone)

These hooks are tracked in the repo but git only auto-runs hooks from
`.git/hooks/` (untracked). To activate for this clone (one-time), or
automatically via `scripts/setup-workspace.sh`:

```bash
git config core.hooksPath scripts/git-hooks
```

Verify:
```bash
git config core.hooksPath
# → scripts/git-hooks
```

To disable temporarily on a single commit:
```bash
git commit --no-verify -m "..."
```

## Hooks

### `pre-commit`

Conditional — only runs when relevant files are staged.

| Guard | Triggers on | Action |
|---|---|---|
| **tsc** | any `*.{ts,tsx}` staged | runs `npx tsc --noEmit`; blocks commit on any TS error |
| **issue-health-check** | `ISSUES.md` staged | runs `node scripts/issue-health-check.mjs`; informational only until you've done a historical cleanup to establish a clean baseline (see "Future" below) |
| **memory drift** | every commit | compares `.claude/memory/` (repo) against `~/.claude/projects/<slug>/memory/` (local). Warns if they differ and prints the `./scripts/sync-memory.sh backup` command. Informational only — deliberately does NOT auto-stage, because silently adding memory files to an unrelated bug-fix commit makes git history confusing. See [`docs/AI_CEO_WORKING_MODEL.md` §6](../../docs/AI_CEO_WORKING_MODEL.md) for the full two-direction sync design. |

Everyone on the team should each run `git config core.hooksPath ...`
once (or run `scripts/setup-workspace.sh`, which does it for them). If
someone hasn't, their commits skip the hooks silently — that's OK,
this is best-effort convenience.

## Adding your own guards

Add a new conditional block to `pre-commit` following the same pattern:
check whether relevant files are staged, run your check, `exit 1` with
a clear message on failure. Keep each guard scoped — a guard that runs
on every commit regardless of what changed will slow everyone down and
get bypassed with `--no-verify` out of habit.

## Future

If you want an audit hook to actually block (not just inform), first
do a one-time cleanup to establish a clean baseline of 0 audit
failures. Then the hook can `exit 1` on any *new* failure instead of
warning about the entire historical backlog every time.
