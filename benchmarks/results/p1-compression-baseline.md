# P1 Compression Pipeline — Baseline Benchmark

Date: 2026-07-01
Version: v0.4.0
Engines tested: treesitter (regex fallback), truncate, pointer, none

## Code Compression (treesitter engine)

| File | Lines | Original | Compressed | Ratio |
|------|-------|----------|-----------|-------|
| compress.sh | 230 | 6,227 B | 5,685 B | 91% |
| install.sh | 280 | 9,019 B | 8,266 B | 92% |
| test.sh | 149 | 6,740 B | 6,312 B | 94% |
| analyze_transcript.py | — | 7,290 B | 7,107 B | 97% |
| agent-rules.md | — | 5,403 B | 5,071 B | 94% |

**Average: 94% (6% compression)**
**Note:** Using regex fallback (no tree-sitter-cli). Real AST parsing or Claw Compactor expected to achieve 15-82%.

## Tool Output Compression (pointer vs truncate)

| Lines | Orig (B) | Pointer (B) | Pointer % | Truncate (B) | Truncate % |
|-------|----------|-------------|-----------|--------------|------------|
| 30 | 1,490 | 455 | 31% | 1,017 | 68% |
| 50 | 2,490 | 455 | 18% | 1,017 | 41% |
| 100 | 4,991 | 457 | 9% | 1,018 | 20% |
| 200 | 10,091 | 460 | 5% | 1,028 | 10% |
| 500 | 25,391 | 460 | 2% | 1,028 | 4% |

**Pointer: constant ~460B regardless of input size (3+3 line preview)**
**Truncate: constant ~1KB (10+10 line window)**
**Key finding:** Pointer achieves 50x compression on 500-line outputs.

## Text/Document Compression (truncate engine)

| File | Lines | Original | Truncated | Ratio |
|------|-------|----------|----------|-------|
| README.md | 196 | 7,568 B | 878 B | 12% |
| ROADMAP.md | 759 | 30,250 B | 1,457 B | 5% |
| before-after.md | 338 | 9,521 B | 559 B | 6% |
| CHANGELOG.md | 69 | 3,248 B | 788 B | 24% |
| CHEATSHEET.md | 84 | 2,236 B | 582 B | 26% |
| CONTRIBUTING.md | 46 | 1,282 B | 561 B | 44% |

**Short docs (<50 lines): minimal benefit. Long docs (>100 lines): 5-12% = 8-20x compression.**

## Summary

| Content Type | Best Engine | Compression Range | Notes |
|-------------|-------------|-------------------|-------|
| Code | treesitter (regex) | 91-97% (3-9% saved) | Needs real AST engine for better results |
| Tool Output | pointer | 2-31% (3-50x saved) | Best for >50 line outputs |
| Tool Output | truncate | 4-68% (1.5-25x saved) | Preserves more context than pointer |
| Text/Docs | truncate | 5-44% (2-20x saved) | Scales with document length |

## Next Steps (for CI regression)

- [ ] Install tree-sitter-cli and re-benchmark code compression
- [ ] Install claw-compactor and compare with treesitter
- [ ] Test llmlingua on NL text and compare with truncate
- [ ] Test compression effect on agent task correctness (not just size)
