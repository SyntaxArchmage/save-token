# P7-P11 Functional A/B Test Results

Date: 2026-07-01

## Summary

13/13 tests passed across P7-P11.

## P7: Team Config Mode (3 tests)

| # | Test | Result |
|---|------|--------|
| 1 | Team config override (mode, compression, density) | PASS |
| 2 | User override takes precedence over team | PASS |
| 3 | Apply config sets mode + density | PASS |

## P8: Progressive Activation (3 tests)

| # | Test | Result |
|---|------|--------|
| 4 | 3 qualifying scores → READY status | PASS |
| 5 | Apply promotes full→ultra, sets mode | PASS |
| 6 | Detects max level (ultra), no further promotion | PASS |

## P9: CI Benchmark Regression (3 tests)

| # | Test | Result |
|---|------|--------|
| 7 | Markdown output format | PASS |
| 8 | Regression pass (improvements don't trigger) | PASS |
| 9 | Regression fail (worsening detected + exit 1) | PASS |

## P10: promptfoo Integration (4 tests)

| # | Test | Result |
|---|------|--------|
| 10a | YAML has 21 test cases from 20 prompts | PASS |
| 10b | Has save-token-full prompt variant | PASS |
| 10c | Has baseline prompt variant | PASS |
| 10d | Has YAGNI rubric assertion | PASS |

## P11: Multi-model A/B (3 tests)

| # | Test | Result |
|---|------|--------|
| 11 | --model flag shown in output | PASS |
| 12 | --trials override (10 per arm) | PASS |
| 13 | --output=json writes config file | PASS |
