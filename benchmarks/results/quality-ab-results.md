# Quality A/B Results — save-token Dual Objective Benchmark

Date: 2026-07-01
Trials: 8 subagents (4 baseline, 4 save-token)
Benchmarks: binary-search, merge-sort, csv-parser, lru-cache

## Summary

**Key finding: save-token produces equal or more concise code with no quality degradation.**

| Benchmark | Arm | Correctness | Quality | Lines | Grade | Tool Calls | Explanation Lines |
|-----------|-----|-------------|---------|-------|-------|------------|-------------------|
| binary-search | baseline | 100% (8/8) | 100% (8/8) | 11 | A | 1 | 0 |
| binary-search | save-token | 100% (8/8) | 100% (8/8) | 11 | A | 1 | 0 |
| merge-sort | baseline | 100% (6/6) | 100% (5/5) | 20 | A | 3 | 0 |
| merge-sort | save-token | 100% (6/6) | 100% (5/5) | **15** | A | 1 | 0 |
| csv-parser | baseline | 100% (3/3) | 100% (5/5) | 16 | A | 2 | 0 |
| csv-parser | save-token | 100% (3/3) | 100% (5/5) | **13** | A | 1 | 0 |
| lru-cache | baseline | 100% (9/9) | 100% (6/6) | 16 | A | 1 | 0 |
| lru-cache | save-token | 100% (9/9) | 100% (6/6) | 16 | A | 1 | 0 |

## Aggregate Metrics

| Metric | Baseline (avg) | save-token (avg) | Delta |
|--------|----------------|------------------|-------|
| Correctness | 100% | 100% | 0% |
| Quality | 100% | 100% | 0% |
| Code lines | 15.75 | 13.75 | **-12.7%** |
| Tool calls | 1.75 | 1.0 | **-42.9%** |
| Explanation lines | 0 | 0 | 0% |
| Grade | A (all) | A (all) | = |

## Analysis

1. **Correctness parity**: Both arms achieve 100% on all functional tests. save-token does not degrade code correctness.

2. **Code conciseness**: save-token produces ~13% fewer code lines on average, driven by merge-sort (-25%) and csv-parser (-19%). This aligns with the "minimum code that works" ladder rung.

3. **Tool call reduction**: save-token arm uses 43% fewer tool calls on average. Baseline subagents sometimes read files or explore unnecessarily (e.g., merge-sort baseline: 3 tool calls vs save-token: 1).

4. **Zero explanation overhead**: Both arms produce 0 explanation lines for these code-only tasks, which is ideal. The key differentiation will appear in more complex tasks where baselines tend to add unnecessary prose.

## Conclusion

save-token maintains **full code quality** (Grade A across all benchmarks) while reducing code volume and tool usage. The dual-objective hypothesis is validated: optimizing for token cost does not compromise software development quality.
