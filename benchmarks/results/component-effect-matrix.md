# Component Effect Matrix

Based on 1000 trials across 25 benchmarks.

| Component | Trials | Code Lines (avg) | Δ Code | Correctness | Quality | Grade Dist | 
|-----------|--------|-----------------|--------|------------|---------|------------|
| **baseline** | 125 | 17.8 | — | 100.0% | 94.4% | 90A/30B/5C/0F |
| **code-ladder** | 125 | 12.9 | -27.4% | 100.0% | 100.0% | 125A/0B/0C/0F |
| **tool-discipline** | 125 | 17.8 | +0.0% | 100.0% | 94.4% | 90A/30B/5C/0F |
| **output-economy** | 125 | 12.9 | -27.4% | 100.0% | 100.0% | 125A/0B/0C/0F |
| **context-eviction** | 125 | 17.8 | +0.0% | 100.0% | 94.4% | 90A/30B/5C/0F |
| **full** | 125 | 12.9 | -27.4% | 100.0% | 100.0% | 125A/0B/0C/0F |
| **lite** | 125 | 12.9 | -27.4% | 100.0% | 100.0% | 125A/0B/0C/0F |
| **ultra** | 125 | 9.2 | -48.1% | 100.0% | 100.0% | 125A/0B/0C/0F |

## Per-Benchmark Breakdown

| Benchmark |  baseline |  code-ladder |  tool-discipline |  output-economy |  context-eviction |  full |  lite |  ultra |
|---------- | ------- | ------- | ------- | ------- | ------- | ------- | ------- | ------- |
| api-crud |  40L/A |  23L/A |  40L/A |  23L/A |  40L/A |  23L/A |  23L/A |  21L/A |
| binary-search |  11L/A |  11L/A |  11L/A |  11L/A |  11L/A |  11L/A |  11L/A |  11L/A |
| context-timer |  14L/B |  10L/A |  14L/B |  10L/A |  14L/B |  10L/A |  10L/A |  5L/A |
| csv-parser |  14L/A |  10L/A |  14L/A |  10L/A |  14L/A |  10L/A |  10L/A |  8L/A |
| data-pipeline |  6L/A |  5L/A |  6L/A |  5L/A |  6L/A |  5L/A |  5L/A |  3L/A |
| debounce |  21L/B |  17L/A |  21L/B |  17L/A |  21L/B |  17L/A |  17L/A |  13L/A |
| debug-off-by-one |  16L/A |  15L/A |  16L/A |  15L/A |  16L/A |  15L/A |  15L/A |  10L/A |
| debug-race-condition |  14L/A |  10L/A |  14L/A |  10L/A |  14L/A |  10L/A |  10L/A |  6L/A |
| email-validator |  9L/A |  4L/A |  9L/A |  4L/A |  9L/A |  4L/A |  4L/A |  3L/A |
| event-emitter |  19L/A |  12L/A |  19L/A |  12L/A |  19L/A |  12L/A |  12L/A |  9L/A |
| flatten-nested |  9L/C |  8L/A |  9L/C |  8L/A |  9L/C |  8L/A |  8L/A |  2L/A |
| generate-tests |  29L/A |  21L/A |  29L/A |  21L/A |  29L/A |  21L/A |  21L/A |  13L/A |
| lru-cache |  20L/A |  16L/A |  20L/A |  16L/A |  20L/A |  16L/A |  16L/A |  13L/A |
| matrix-multiply |  13L/B |  5L/A |  13L/B |  5L/A |  13L/B |  5L/A |  5L/A |  3L/A |
| memoize-ttl |  19L/B |  18L/A |  19L/B |  18L/A |  19L/B |  18L/A |  18L/A |  13L/A |
| merge-sort |  22L/A |  17L/A |  22L/A |  17L/A |  22L/A |  17L/A |  17L/A |  10L/A |
| multi-file-refactor |  22L/A |  19L/A |  22L/A |  19L/A |  22L/A |  19L/A |  19L/A |  11L/A |
| optimize-n-plus-one |  10L/A |  8L/A |  10L/A |  8L/A |  10L/A |  8L/A |  8L/A |  6L/A |
| rate-limiter |  16L/A |  13L/A |  16L/A |  13L/A |  16L/A |  13L/A |  13L/A |  11L/A |
| refactor-extract-class |  28L/A |  17L/A |  28L/A |  17L/A |  28L/A |  17L/A |  17L/A |  12L/A |
| retry-decorator |  18L/A |  17L/A |  18L/A |  17L/A |  18L/A |  17L/A |  17L/A |  12L/A |
| security-sql-injection |  11L/A |  9L/A |  11L/A |  9L/A |  11L/A |  9L/A |  9L/A |  9L/A |
| singleton-meta |  8L/A |  6L/A |  8L/A |  6L/A |  8L/A |  6L/A |  6L/A |  5L/A |
| stack-calculator |  26L/B |  11L/A |  26L/B |  11L/A |  26L/B |  11L/A |  11L/A |  7L/A |
| trie-prefix |  30L/B |  21L/A |  30L/B |  21L/A |  30L/B |  21L/A |  21L/A |  15L/A |

## Statistical Summary

| Component | Code Lines (mean±sd) | Correctness (mean±sd) | Quality (mean±sd) |
|-----------|---------------------|----------------------|-------------------|
| **baseline** | 17.8 ± 8.1 | 100.0 ± 0.0 | 94.4 ± 9.6 |
| **code-ladder** | 12.9 ± 5.4 | 100.0 ± 0.0 | 100.0 ± 0.0 |
| **tool-discipline** | 17.8 ± 8.1 | 100.0 ± 0.0 | 94.4 ± 9.6 |
| **output-economy** | 12.9 ± 5.4 | 100.0 ± 0.0 | 100.0 ± 0.0 |
| **context-eviction** | 17.8 ± 8.1 | 100.0 ± 0.0 | 94.4 ± 9.6 |
| **full** | 12.9 ± 5.4 | 100.0 ± 0.0 | 100.0 ± 0.0 |
| **lite** | 12.9 ± 5.4 | 100.0 ± 0.0 | 100.0 ± 0.0 |
| **ultra** | 9.2 ± 4.4 | 100.0 ± 0.0 | 100.0 ± 0.0 |

## Key Findings

- **Full mode vs baseline**: -27.4% code lines, correctness 100.0% vs 100.0%
- **Baseline grades**: 90A / 30B / 5C / 0F
- **Full grades**: 125A / 0B / 0C / 0F
- **Most impactful single component**: code-ladder (-27.4% code lines)

Total trials: 1000
Benchmarks: 25
Conditions: 8
