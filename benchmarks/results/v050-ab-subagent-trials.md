# v0.5.0 A/B Subagent Trial Results

Generated: 2026-07-01
Trials: 16 subagents (8 baseline + 8 optimized), 8 distinct prompts

## Raw Data

| Task | Arm | tool_calls | code_lines | explanation_lines | files_read | correct |
|------|-----|-----------|------------|-------------------|------------|---------|
| csv-parser | Baseline | 13 | 12 | 3 | 4 | yes |
| csv-parser | Optimized | 8 | 12 | 0 | 4 | yes |
| rate-limiter | Baseline | 10 | 26 | 2 | 3 | yes |
| rate-limiter | Optimized | 9 | 25 | 1 | 4 | yes |
| retry-decorator | Baseline | 9 | 22 | 1 | 4 | yes |
| retry-decorator | Optimized | 9 | 22 | 0 | 3 | yes |
| event-emitter | Baseline | 11 | 47 | 4 | 3 | yes |
| event-emitter | Optimized | 7 | 39 | 2 | 2 | yes |
| lru-cache | Baseline | 7 | 21 | 1 | 3 | yes |
| lru-cache | Optimized | 8 | 15 | 1 | 3 | yes |
| merge-sort | Baseline | 6 | 19 | 3 | 2 | yes |
| merge-sort | Optimized | 6 | 15 | 0 | 2 | yes |
| email-validator | Baseline | 8 | 6 | 8 | 3 | yes |
| email-validator | Optimized | 7 | 4 | 0 | 2 | yes |
| stack-calculator | Baseline | 8 | 61 | 2 | 3 | yes |
| stack-calculator | Optimized | 5 | 35 | 1 | 2 | yes |

## Aggregates

| Metric | Baseline (avg) | Optimized (avg) | Delta | % Change |
|--------|---------------|-----------------|-------|----------|
| tool_calls | 9.0 | 7.4 | -1.6 | **-18%** |
| code_lines | 26.8 | 20.9 | -5.9 | **-22%** |
| explanation_lines | 3.0 | 0.6 | -2.4 | **-80%** |
| files_read | 3.1 | 2.8 | -0.3 | -10% |
| correctness | 8/8 | 8/8 | 0 | 100% |

## Per-Task Delta

| Task | Δ tool_calls | Δ code_lines | Δ explanation |
|------|-------------|-------------|---------------|
| csv-parser | -38% | 0% | -100% |
| rate-limiter | -10% | -4% | -50% |
| retry-decorator | 0% | 0% | -100% |
| event-emitter | -36% | -17% | -50% |
| lru-cache | +14% | -29% | 0% |
| merge-sort | 0% | -21% | -100% |
| email-validator | -13% | -33% | -100% |
| stack-calculator | -38% | -43% | -50% |

## Observations

1. **Explanation reduction is dominant** (-80% avg): optimized agents almost never emit prose
2. **Code compaction varies by complexity**: simple tasks (csv-parser, retry) = minimal delta; complex tasks (event-emitter: -17%, stack-calculator: -43%) = significant
3. **Tool calls reduced** (-18% avg): largest gains on complex tasks where baseline explores more
4. **Zero correctness regressions**: all 16 trials produce correct implementations
5. **lru-cache anomaly**: optimized used +1 tool call but -29% code — more efficient exploration

## Comparison with Historical 200-Trial Data

| Metric | Historical (full mode) | v0.5.0 (8 trials) | Consistent? |
|--------|----------------------|-------------------|-------------|
| code_lines | -24% | -22% | ✅ |
| explanation_lines | -75% | -80% | ✅ |
| tool_calls | -34% | -18% | ⚠️ Lower |
| correctness | 100% | 100% | ✅ |

Tool call reduction is lower than historical — likely due to best-of-n-runner's isolated worktree
requiring initial file exploration regardless of rules. Core output metrics align well.

## Cumulative Trial Count

Previous: 200 trials (historical corpus)
This session: +16 trials
**Total: 216 trials**
