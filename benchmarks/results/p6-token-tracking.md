# P6: Token Tracking — Functional Test Results

Generated: 2026-07-01

## Components

| Component | Status | Description |
|-----------|--------|-------------|
| `tokens.sh detect` | ✅ | Auto-detects Cursor, Claude CLI, Helicone, LiteLLM |
| `tokens.sh log` | ✅ | Manual entry with model tag |
| `tokens.sh summary` | ✅ | Aggregation + savings estimate |
| `tokens.sh export csv` | ✅ | CSV with header |
| `tokens.sh export json` | ✅ | Structured JSON array |
| `tokens.sh collect` | ✅ | Auto/cursor/helicone/litellm sources |
| `tokens.sh reset` | ✅ | Clean log |
| `tokens.sh parse-claude` | ✅ | Parse Claude JSON output |
| `cost.sh` real data mode | ✅ | Uses token log when available |
| `cost.sh` estimation fallback | ✅ | Falls back to 216-trial benchmark |

## Test Matrix

| Test | Input | Expected | Result |
|------|-------|----------|--------|
| Multi-model log | 5 entries (opus/sonnet/haiku/gpt4o/o3) | All logged | ✅ |
| Summary accuracy | 37000 in + 12800 out = 49800 total | Correct | ✅ |
| JSON export | 5 entries, 4 fields each | Valid JSON | ✅ |
| Cost integration | Real data → actual cost calc | Correct math | ✅ |
| All model pricing | opus/sonnet/haiku/gpt4o/o3 | Different rates | ✅ |
| Large values | 999999 in, 500000 out | No overflow | ✅ |
| Reset | Clear log | File removed | ✅ |
| Estimation fallback | No log → benchmark data | Falls back cleanly | ✅ |

## Cost Accuracy Check (5 entries, full mode)

| Model | Total Cost | Savings (75% output) |
|-------|-----------|---------------------|
| Opus ($15/$75) | $1.51 | $0.72 |
| Sonnet ($3/$15) | $0.30 | $0.14 |
| Haiku ($0.25/$1.25) | $0.03 | $0.01 |
| GPT-4o ($2.50/$10) | $0.22 | $0.10 |
| o3 ($10/$40) | $0.88 | $0.38 |

Manual verification: Opus = (37000 × $15 + 12800 × $75) / 1M = $0.555 + $0.96 = $1.515 ≈ $1.51 ✅

## Configuration

| Variable | Default | Tested |
|----------|---------|--------|
| SAVE_TOKEN_DIR | ~/.save-token | ✅ |
| HELICONE_API_KEY | (none) | Detected when set |
| LITELLM_BASE_URL | (none) | Detected when set |
