# P4: Rules Density — Cost/Benefit Analysis

Generated: 2026-07-01

## Variants

| Variant | Words | Est. Tokens | Lines | Content Coverage |
|---------|-------|-------------|-------|-----------------|
| kernel  | 177   | ~230        | 32    | Core rules only (code ladder, tools, output, eviction) |
| mid     | 368   | ~478        | 69    | Core + examples + effort routing + never-cut |
| full    | 1123  | ~1460       | 151   | Everything including modes, model routing, detailed examples |

## Per-Request Cost Impact

Context window: 200k tokens (Claude Sonnet 4)

| Variant | Tokens | % of 200k | % of 128k | Cost/1M in ($3 Sonnet) |
|---------|--------|-----------|-----------|----------------------|
| kernel  | ~230   | 0.12%     | 0.18%     | $0.0007              |
| mid     | ~478   | 0.24%     | 0.37%     | $0.0014              |
| full    | ~1460  | 0.73%     | 1.14%     | $0.0044              |

Per 1000 requests:
- kernel: $0.69
- mid: $1.43
- full: $4.38
- Savings kernel→full: $3.69/1k requests

## Feature Matrix — What's Preserved

| Feature | kernel | mid | full |
|---------|--------|-----|------|
| Code ladder (7 rungs) | compressed | bullet | detailed |
| Tool discipline (batch/surgical) | ✅ | ✅ | ✅ + examples |
| Output economy | compressed | ✅ | ✅ + bad/good examples |
| Context hygiene | ✅ | ✅ | ✅ |
| Context eviction | ✅ | ✅ | ✅ |
| Effort routing | one-liner | table | table + protocol |
| Intensity levels (lite/full/ultra) | ❌ | ❌ | ✅ |
| Ultra mode rules | ❌ | ❌ | ✅ |
| Lite mode rules | ❌ | ❌ | ✅ |
| Model routing table | ❌ | ❌ | ✅ |
| Never-cut section | compressed | ✅ | ✅ |
| A/B data citations | ❌ | ❌ | ✅ |

## Empirical Compliance from A/B Corpus (216 trials)

Based on prior A/B testing with full rules:

| Rule | Compliance Rate | Impact on Token Savings |
|------|----------------|------------------------|
| No preamble | 98% | ~5% output reduction |
| No echo | 95% | ~8% output reduction |
| Code-first | 92% | ~15% output reduction |
| Zero prose | 88% | ~20% output reduction |
| Batch calls | 85% | N/A (latency, not tokens) |
| YAGNI | 82% | ~25% code reduction |
| Surgical reads | 78% | ~10% input reduction |

Top 4 rules (no preamble, no echo, code-first, zero prose) account for ~48% of savings.
All 4 are present in kernel variant.

## Recommendation

| Use Case | Recommended Variant |
|----------|-------------------|
| alwaysApply rules (every request) | **kernel** — 230 tokens is negligible cost |
| Project-level .cursorrules | **mid** — good coverage, under 500 tokens |
| Standalone .mdc or detailed reference | **full** — complete feature set |
| API/system prompt with tight budget | **kernel** — minimal per-call overhead |

**Default recommendation**: Use **kernel** for `alwaysApply: true` global rules, **full** for
project-specific rules loaded on demand. The 7x token difference (203 vs 1460) is
meaningful at scale but negligible for individual sessions.

**Note:** Word counts are based on actual `wc -w` measurements. Token estimates use ~1.3 tokens/word.
