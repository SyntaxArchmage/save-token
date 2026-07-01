# P1 & P4 A/B Test Results

Generated: 2026-07-01

## P1: Compression Engine A/B Tests

### Code Files (bash scripts)

| File | Size | none | truncate | pointer | treesitter |
|------|------|------|----------|---------|------------|
| compress.sh | 6227B | 100% | 7.3% | 4.8% | 91.5% |
| learn.sh | 5811B | 100% | 9.6% | 4.7% | 98.1% |
| install.sh | 9780B | 100% | 5.1% | 3.4% | 93.0% |
| **Average** | | **100%** | **7.3%** | **4.3%** | **94.2%** |

Observations:
- treesitter (regex fallback): only strips comments/whitespace → 6-9% reduction
- pointer: 95-97% compression — too aggressive for code (loses logic)
- truncate: 90-95% compression — keeps first/last lines, loses middle
- **Recommended for code**: treesitter with proper AST parser (future P1 work)

### Text/Documentation Files

| File | Size | truncate | pointer |
|------|------|----------|---------|
| README.md | 9087B | 9.7% | 5.3% |
| CHEATSHEET.md | 2756B | 21.2% | 11.0% |
| CHANGELOG.md | 4956B | 26.5% | 6.8% |
| ROADMAP.md | 30250B | 4.9% | 1.6% |
| **Average** | | **15.6%** | **6.2%** |

Observations:
- Both work well for docs; pointer more aggressive
- Larger files benefit more (ROADMAP: 98.4% reduction with pointer)
- truncate preserves structure (head+tail); pointer gives digest

### Simulated Tool Output (log-like)

| Lines | truncate | pointer |
|-------|----------|---------|
| 50 | 40.5% | 15.8% |
| 100 | 20.3% | 7.9% |
| 500 | 4.0% | 1.6% |
| 1000 | 2.0% | 0.8% |
| **Average** | **16.7%** | **6.5%** |

Observations:
- pointer: 84-99% reduction — ideal for large tool outputs
- Compression ratio improves with size (sublinear overhead)
- At 1000 lines: pointer saves 99.2% of tokens

### Engine Recommendation Matrix

| Content Type | Best Engine | Compression | Quality |
|-------------|-------------|-------------|---------|
| Code (read) | treesitter | 6-9% reduction | High (preserves logic) |
| Code (reference) | pointer | 95%+ reduction | Low (digest only) |
| Text/docs | truncate | 74-95% reduction | Medium (head+tail) |
| Tool output (small ≤20) | none | 0% | Full fidelity |
| Tool output (medium 21-100) | truncate | 60-80% reduction | Medium |
| Tool output (large >100) | pointer | 92-99% reduction | Low (pointer ref) |
| Metadata (JSON/YAML) | none | 0% | Full fidelity |

## P4: Density Variant A/B Tests

### Token Cost per Variant

| Variant | Words | Chars | Est. Tokens | % of Full |
|---------|-------|-------|-------------|-----------|
| kernel | 177 | 1199 | ~299 | 17% |
| mid | 368 | 2312 | ~578 | 32% |
| full | 1123 | 7187 | ~1796 | 100% |

### Per-Request Cost (Sonnet 4 @ $3/M input tokens)

| Variant | Tokens | Cost/request | Cost/1000 req |
|---------|--------|-------------|---------------|
| kernel | 299 | $0.0009 | $0.90 |
| mid | 578 | $0.0017 | $1.73 |
| full | 1796 | $0.0054 | $5.39 |

### Feature Coverage

| Feature | kernel | mid | full |
|---------|--------|-----|------|
| 7-rung code ladder | ✅ (compressed) | ✅ (bullet) | ✅ (detailed) |
| Tool discipline | ✅ | ✅ | ✅ + examples |
| Output economy | ✅ | ✅ + bad/good | ✅ + bad/good + data |
| Context hygiene | ✅ | ✅ | ✅ |
| Context eviction | ✅ | ✅ | ✅ |
| Effort routing | ✅ (one-liner) | ✅ (table) | ✅ (table + protocol) |
| Clarifying question | ✅ | ✅ | ✅ |
| Intensity levels | ❌ | ❌ | ✅ |
| Ultra/lite modes | ❌ | ❌ | ✅ |
| Model routing table | ❌ | ❌ | ✅ |
| A/B data citations | ❌ | ❌ | ✅ |
| Never-cut details | ✅ (compressed) | ✅ | ✅ + runnable check |

### Recommendation

- **alwaysApply global rule**: kernel (299 tokens — negligible per-request tax)
- **Project-level rule**: mid (578 tokens — good coverage)
- **Skill/standalone**: full (1796 tokens — complete, loaded on demand)
- **API system prompt**: kernel (minimize per-call overhead)

### Savings: kernel vs full over 1000 requests

$5.39 - $0.90 = **$4.49 saved per 1000 requests** (83% reduction in rule injection cost)
