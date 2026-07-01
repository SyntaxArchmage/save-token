# Quality A/B Results — save-token Dual Objective Benchmark

Date: 2026-07-01
Trials: 40 subagents (20 baseline, 20 save-token)
Benchmarks: all 20

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

### Complex Tasks (Round 2)

| Benchmark | Arm | Correctness | Quality | Lines | Grade | Tool Calls | Explanation Lines |
|-----------|-----|-------------|---------|-------|-------|------------|-------------------|
| refactor-extract-class | baseline | 100% (5/5) | 100% (7/7) | 22 | A | 1 | 0 |
| refactor-extract-class | save-token | 100% (5/5) | 100% (7/7) | **19** | A | 1 | 0 |
| debug-off-by-one | baseline | 100% (6/6) | 100% (4/4) | 16 | A | 2 | 0 |
| debug-off-by-one | save-token | 100% (6/6) | 100% (4/4) | 16 | A | 2 | 0 |
| api-crud | baseline | 100% (6/6) | 100% (8/8) | 35 | A | 4 | 2 |
| api-crud | save-token | 100% (6/6) | 100% (8/8) | 35 | A | 2 | 0 |

### Remaining Benchmarks (Round 3)

| Benchmark | Arm | Correctness | Quality | Lines | Grade | Tool Calls | Explanation Lines |
|-----------|-----|-------------|---------|-------|-------|------------|-------------------|
| email-validator | baseline | 100% (4/4) | 100% (5/5) | 6 | A | 1 | 2 |
| email-validator | save-token | 100% (4/4) | 100% (5/5) | **4** | A | 1 | 0 |
| retry-decorator | baseline | 100% (3/3) | 83.3% (5/6) | 17 | **B** | 1 | 2 |
| retry-decorator | save-token | 100% (3/3) | **100%** (6/6) | 17 | **A** | 1 | 0 |
| rate-limiter | baseline | 100% (2/2) | 100% (4/4) | 16 | A | 3 | 1 |
| rate-limiter | save-token | 100% (2/2) | 100% (4/4) | 16 | A | 2 | 0 |
| stack-calculator | baseline | 100% (5/5) | 80% (4/5) | 27 | **B** | 4 | 2 |
| stack-calculator | save-token | 100% (5/5) | **100%** (5/5) | **17** | **A** | 3 | 0 |

**Notable**: baseline scored Grade B on retry-decorator (missing `functools.wraps`) and stack-calculator (27 lines > 25 max). save-token scored Grade A on both.

### Advanced Benchmarks (Round 4)

| Benchmark | Arm | Correctness | Quality | Lines | Grade | Tool Calls | Explanation Lines |
|-----------|-----|-------------|---------|-------|-------|------------|-------------------|
| optimize-n-plus-one | baseline | 100% (3/3) | 100% (3/3) | 13 | A | 2 | 2 |
| optimize-n-plus-one | save-token | 100% (3/3) | 100% (3/3) | **10** | A | 1 | 0 |
| security-sql-injection | baseline | 100% (3/3) | 100% (9/9) | 12 | A | 1 | 2 |
| security-sql-injection | save-token | 100% (3/3) | 100% (9/9) | 12 | A | 1 | 0 |
| generate-tests | baseline | 100% (3/3) | 85.7% (6/7) | 31 | **B** | 4 | 0 |
| generate-tests | save-token | 100% (3/3) | **100%** (7/7) | **19** | **A** | 3 | 0 |

**Notable**: baseline generate-tests exceeded 30-line limit (31 lines, Grade B). save-token stayed concise at 19 lines (Grade A).

### Design Pattern & Debug Benchmarks (Round 5)

| Benchmark | Arm | Correctness | Quality | Lines | Grade | Tool Calls | Explanation Lines |
|-----------|-----|-------------|---------|-------|-------|------------|-------------------|
| debug-race-condition | baseline | 100% (3/3) | 100% (5/5) | 11 | A | 1 | 0 |
| debug-race-condition | save-token | 100% (3/3) | 100% (5/5) | 11 | A | 1 | 0 |
| multi-file-refactor | baseline | 100% (6/6) | 100% (5/5) | 20 | A | 1 | 0 |
| multi-file-refactor | save-token | 100% (6/6) | 100% (5/5) | **19** | A | 2 | 0 |
| event-emitter | baseline | 100% (5/5) | 100% (6/6) | 18 | A | 1 | 0 |
| event-emitter | save-token | 100% (5/5) | 100% (6/6) | **14** | A | 5 | 0 |

**Notable**: save-token event-emitter used `setdefault` instead of `defaultdict` + type annotations — 4 fewer lines, cleaner approach.

### Functional Programming & Patterns (Round 6)

| Benchmark | Arm | Correctness | Quality | Lines | Grade | Tool Calls | Explanation Lines |
|-----------|-----|-------------|---------|-------|-------|------------|-------------------|
| data-pipeline | baseline | 100% (4/4) | 100% (5/5) | 5 | A | 1 | 0 |
| data-pipeline | save-token | 100% (4/4) | 100% (5/5) | **3** | A | 2 | 0 |
| singleton-meta | baseline | 100% (3/3) | 100% (5/5) | 6 | A | 1 | 0 |
| singleton-meta | save-token | 100% (3/3) | 100% (5/5) | 6 | A | 2 | 0 |
| memoize-ttl | baseline | 100% (4/4) | 83.3% (5/6) | 19 | **B** | 1 | 0 |
| memoize-ttl | save-token | 100% (4/4) | **100%** (6/6) | **16** | **A** | 3 | 0 |

**Notable**: baseline memoize-ttl exceeded 18-line limit (19 lines, Grade B) due to extra blank lines. save-token stayed at 16 lines (Grade A).

## Aggregate Metrics (All 20 Benchmarks)

| Metric | Baseline (avg) | save-token (avg) | Delta |
|--------|----------------|------------------|-------|
| Correctness | 100% | 100% | 0% |
| Quality | 96.7% | **100%** | **+3.4%** |
| Code lines | 16.85 | 14.45 | **-14.2%** |
| Tool calls | 1.80 | 1.80 | 0% |
| Explanation lines | 0.65 | 0 | **-100%** |
| Grade | 16A / **4B** | **20A / 0B** | **save-token wins** |

## Analysis

1. **Correctness parity**: Both arms achieve 100% on all functional tests across 20 benchmarks. save-token does not degrade code correctness.

2. **Quality superiority**: save-token achieves 100% quality across all 20 benchmarks while baseline drops to Grade B on 4 out of 20 (retry-decorator: missing `functools.wraps`, stack-calculator: code bloat, generate-tests: code bloat, memoize-ttl: code bloat). **save-token's code ladder actively prevents quality issues.**

3. **Code conciseness**: save-token produces 14.2% fewer code lines on average. Largest gaps: stack-calculator (-37%, 27→17), event-emitter (-22%, 18→14), pipeline (-40%, 5→3), merge-sort (-25%). The "minimum code that works" rung is measurably effective.

4. **Tool call parity**: At 20 benchmarks, tool call averages have converged to 1.80 for both arms. Baseline's extra tool calls in early rounds balanced by save-token's occasional extra file reads.

5. **Explanation elimination**: Baseline produces 0.65 explanation lines per trial on average (despite not being asked). save-token enforces zero-prose default — 0 explanation lines across all 20 benchmarks.

## Conclusion

Across 40 trials (20 baseline, 20 save-token) covering algorithms, data structures, decorators, design patterns, refactoring, debugging, race conditions, event-driven design, performance optimization, security fixes, test generation, functional programming, and caching:

- **Quality**: save-token **outperforms** baseline (**20A/0B** vs 16A/4B)
- **Correctness**: 100% parity across all 20 benchmarks — no degradation
- **Efficiency**: -14.2% code lines, -100% unwanted explanation
- **Baseline failures**: retry-decorator (missing functools.wraps), stack-calculator (code bloat), generate-tests (code bloat), memoize-ttl (code bloat)
- **Key insight**: save-token doesn't just save tokens — it produces *better* code by enforcing discipline that prevents bloat and missing best practices
