---
name: auto-dev
description: >-
  Time-boxed autonomous development loop. Iterates: identify task, implement,
  debug, A/B test, review/refine or discard, commit, next task. Use when user
  says /auto-dev, "auto dev", "autonomous dev", or "keep coding for X time".
argument-hint: "<duration> [focus area]"
disable-model-invocation: true
---

# /auto-dev — Time-Boxed Autonomous Dev Loop

Run iterative development cycles within a time budget. Each cycle:
**identify → implement → debug → test → review → commit → next**.

## Activation

Parse: `/auto-dev <duration> [focus]`

- Duration: `30m`, `1h`, `2h`, `4h` (default: `1h`)
- Focus: optional scope constraint (e.g. "save-token scripts", "auth module")

## Protocol

### 1. Setup (once)

```
1. Record start time: date +%s
2. Convert duration to seconds
3. Scan codebase for pending work:
   - TODOs/FIXMEs in code (rg "TODO|FIXME|HACK|XXX")
   - Open issues if git remote exists (gh issue list)
   - Unfinished features from conversation context
4. Rank tasks by impact (bugs > missing features > polish > docs)
5. Create TodoWrite with ranked task list
```

### 2. Dev Cycle (repeat until time runs out)

Each cycle follows this exact sequence:

**IDENTIFY** — Pick the highest-priority incomplete task from the todo list.
State in one line what you're building and why.

**IMPLEMENT** — Write the code. Follow workspace rules. Keep changes small
and focused (one logical unit per cycle).

**DEBUG** — Run the code. Fix errors. Verify it works:
- Scripts: `bash -n` + execute with test input
- Python: `python3 -c "import ast; ast.parse(...)"` + run tests
- TypeScript: `tsc --noEmit` or equivalent

**TEST** — For significant features, launch A/B subagents:
- 2+ `best-of-n-runner` trials per arm
- Compare metrics (tool_calls, code_lines, explanation_lines)
- Skip A/B for trivial fixes (typos, config, docs)

**REVIEW** — Self-review the diff:
- Is it the minimum viable change?
- Any dead code, unnecessary comments, or bloat?
- Does it break existing functionality?
- Simplify until you can't remove anything else.

**DECIDE**:
- Quality acceptable → commit with descriptive message → mark task done
- Not good enough → fix and re-test (max 2 retries, then discard)
- Discarded → note why, move to next task

**COMMIT** — `git add` + `git commit` with a clear message.
Only commit working code.

### 3. Time Check

After each cycle, check remaining time:
```bash
elapsed=$(($(date +%s) - START_TIME))
remaining=$((BUDGET_SECONDS - elapsed))
```

- `remaining > 600` (10+ min) → start next cycle
- `remaining <= 600` → wrap-up phase
- `remaining <= 0` → stop immediately

### 4. Wrap-Up (when time runs out)

1. Commit any uncommitted working changes
2. Update TodoWrite — mark completed, note remaining
3. Print summary:
   ```
   ╔══════════════════════════════════════╗
   ║         /auto-dev Summary            ║
   ╠══════════════════════════════════════╣
   ║ Duration: Xh Ym                      ║
   ║ Cycles completed: N                  ║
   ║ Tasks done: N / total                ║
   ║ Commits: N                           ║
   ║ A/B trials: N                        ║
   ╚══════════════════════════════════════╝
   ```
4. List remaining tasks for next session

## Rules

- **No user interaction during cycles** — don't ask questions, make decisions
- **Small commits** — one logical change per commit, not bulk
- **Skip what's blocked** — if a task needs user input (e.g. API keys), skip it
- **Prioritize correctness** — never commit broken code
- **A/B test selectively** — only features where effectiveness matters, not config
- **Time discipline** — respect the budget, don't start a 30-min task with 10 min left

## Duration Parsing

| Input | Seconds |
|-------|---------|
| `15m` | 900 |
| `30m` | 1800 |
| `1h` | 3600 |
| `2h` | 7200 |
| `4h` | 14400 |
| bare number | minutes |

## Integration with save-token

When used alongside save-token, auto-dev follows the active intensity level:
- **lite/full**: normal dev cycle, test.sh validation
- **ultra**: enforce minimal changes per cycle, terse commits

Use `bash scripts/test.sh` as the validation gate after each cycle.
Use `bash scripts/benchmark.sh --list` to see available A/B presets.

## Example

```
/auto-dev 2h save-token scripts
→ Scans save-token for pending work
→ Cycle 1: add mode persistence to stats.sh (8 min)
→ Cycle 2: improve learn.sh sequential detection (12 min)
→ Cycle 3: A/B test learn improvements (15 min)
→ ... repeats until 2h elapsed ...
→ Prints summary
```
