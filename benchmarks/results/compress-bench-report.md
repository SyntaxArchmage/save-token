# Compression Benchmark Report

Generated from 103 measurements across 10 content types and 5 engines.

## Compression Matrix (% reduction, higher = better)

| Content Type | headroom | none | pointer | treesitter | truncate |
|---|---:|---:|---:|---:|---:|
| **code** | 54.1% | 2.2% | 90.2% | 3.8% | 81.9% |
| **diff** | 37.8% | 0.1% | — | — | 57.6% |
| **history** | — | 0.0% | — | — | 58.2% |
| **html** | 47.2% | 0.0% | — | — | 87.8% |
| **json** | 49.8% | 0.0% | 98.4% | — | 97.0% |
| **logs** | 53.4% | 0.0% | 94.4% | — | 86.2% |
| **metadata** | — | 0.1% | — | — | 85.4% |
| **search** | 35.8% | 0.0% | 81.4% | — | 58.3% |
| **text** | 54.8% | 0.0% | 92.7% | — | 82.2% |
| **tool_output** | 9.2% | 0.0% | 89.6% | — | 77.7% |

## Size Scaling (reduction % by input size)

| Content Type | Size | Input Bytes | Best Engine | Reduction |
|---|---|---:|---|---:|
| code | small | 1,911 | pointer | 80.2% |
| code | medium | 7,023 | pointer | 93.7% |
| code | large | 11,875 | pointer | 96.8% |
| diff | small | 528 | headroom | 17.0% |
| diff | medium | 2,987 | truncate | 77.4% |
| diff | large | 13,640 | truncate | 95.1% |
| history | small | 6,658 | truncate | 0.0% |
| history | medium | 33,805 | truncate | 79.7% |
| history | large | 139,211 | truncate | 94.8% |
| html | small | 2,962 | truncate | 77.6% |
| html | medium | 6,420 | truncate | 89.6% |
| html | large | 17,774 | truncate | 96.3% |
| json | small | 5,672 | pointer | 96.3% |
| json | medium | 28,185 | pointer | 99.2% |
| json | large | 112,966 | pointer | 99.8% |
| logs | small | 5,057 | pointer | 87.4% |
| logs | medium | 18,639 | pointer | 96.6% |
| logs | large | 91,993 | pointer | 99.3% |
| metadata | small | 1,755 | truncate | 76.8% |
| metadata | large | 7,082 | truncate | 94.1% |
| search | small | 1,304 | pointer | 54.6% |
| search | medium | 6,317 | pointer | 91.3% |
| search | large | 30,350 | pointer | 98.2% |
| text | small | 2,961 | pointer | 83.2% |
| text | medium | 13,981 | pointer | 96.4% |
| text | large | 35,665 | pointer | 98.6% |
| tool_output | small | 1,513 | pointer | 79.8% |
| tool_output | medium | 3,569 | pointer | 91.4% |
| tool_output | large | 12,522 | pointer | 97.5% |

## Best Engine per Content Type

| Content Type | Best Engine | Avg Reduction | Runner-up | Avg Reduction |
|---|---|---:|---|---:|
| **code** | **pointer** | **90.2%** | truncate | 81.9% |
| **diff** | **truncate** | **57.6%** | headroom | 37.8% |
| **history** | **truncate** | **58.2%** | — | — |
| **html** | **truncate** | **87.8%** | headroom | 47.2% |
| **json** | **pointer** | **98.4%** | truncate | 97.0% |
| **logs** | **pointer** | **94.4%** | truncate | 86.2% |
| **metadata** | **truncate** | **85.4%** | — | — |
| **search** | **pointer** | **81.4%** | truncate | 58.3% |
| **text** | **pointer** | **92.7%** | truncate | 82.2% |
| **tool_output** | **pointer** | **89.6%** | truncate | 77.7% |

## Per-Fixture Detail

| Fixture | Type | Size | Engine | Input | Output | Reduction | Time |
|---|---|---|---|---:|---:|---:|---:|
| code-large.py | code | large | headroom | 11,875 | 5,423 | 54.3% | 8233ms |
| code-large.py | code | large | none | 11,875 | 11,521 | 3.0% | 49ms |
| code-large.py | code | large | pointer | 11,875 | 384 | 96.8% | 71ms |
| code-large.py | code | large | treesitter | 11,875 | 11,259 | 5.2% | 5ms |
| code-large.py | code | large | truncate | 11,875 | 805 | 93.2% | 71ms |
| code-medium.py | code | medium | headroom | 7,023 | 3,104 | 55.8% | 7050ms |
| code-medium.py | code | medium | none | 7,023 | 6,786 | 3.4% | 56ms |
| code-medium.py | code | medium | pointer | 7,023 | 440 | 93.7% | 66ms |
| code-medium.py | code | medium | treesitter | 7,023 | 6,617 | 5.8% | 5ms |
| code-medium.py | code | medium | truncate | 7,023 | 820 | 88.3% | 73ms |
| code-small.py | code | small | headroom | 1,911 | 915 | 52.1% | 6558ms |
| code-small.py | code | small | none | 1,911 | 1,910 | 0.1% | 66ms |
| code-small.py | code | small | pointer | 1,911 | 378 | 80.2% | 63ms |
| code-small.py | code | small | treesitter | 1,911 | 1,901 | 0.5% | 6ms |
| code-small.py | code | small | truncate | 1,911 | 684 | 64.2% | 76ms |
| diff-large.diff | diff | large | headroom | 13,640 | 6,730 | 50.7% | 7242ms |
| diff-large.diff | diff | large | none | 13,640 | 13,639 | 0.0% | 68ms |
| diff-large.diff | diff | large | truncate | 13,640 | 673 | 95.1% | 84ms |
| diff-medium.diff | diff | medium | headroom | 2,987 | 1,626 | 45.6% | 6511ms |
| diff-medium.diff | diff | medium | none | 2,987 | 2,986 | 0.0% | 54ms |
| diff-medium.diff | diff | medium | truncate | 2,987 | 674 | 77.4% | 70ms |
| diff-small.diff | diff | small | headroom | 528 | 438 | 17.0% | 5833ms |
| diff-small.diff | diff | small | none | 528 | 527 | 0.2% | 67ms |
| diff-small.diff | diff | small | truncate | 528 | 527 | 0.2% | 58ms |
| history-large.jsonl | history | large | none | 139,211 | 139,210 | 0.0% | 70ms |
| history-large.jsonl | history | large | truncate | 139,211 | 7,306 | 94.8% | 79ms |
| history-medium.jsonl | history | medium | none | 33,805 | 33,804 | 0.0% | 77ms |
| history-medium.jsonl | history | medium | truncate | 33,805 | 6,849 | 79.7% | 57ms |
| history-small.jsonl | history | small | none | 6,658 | 6,657 | 0.0% | 53ms |
| history-small.jsonl | history | small | truncate | 6,658 | 6,657 | 0.0% | 58ms |
| html-large.html | html | large | headroom | 17,774 | 8,700 | 51.1% | 7850ms |
| html-large.html | html | large | none | 17,774 | 17,773 | 0.0% | 53ms |
| html-large.html | html | large | truncate | 17,774 | 665 | 96.3% | 76ms |
| html-medium.html | html | medium | headroom | 6,420 | 3,268 | 49.1% | 6543ms |
| html-medium.html | html | medium | none | 6,420 | 6,419 | 0.0% | 61ms |
| html-medium.html | html | medium | truncate | 6,420 | 665 | 89.6% | 79ms |
| html-small.html | html | small | headroom | 2,962 | 1,734 | 41.5% | 6227ms |
| html-small.html | html | small | none | 2,962 | 2,961 | 0.0% | 66ms |
| html-small.html | html | small | truncate | 2,962 | 664 | 77.6% | 70ms |
| json-large.json | json | large | headroom | 112,966 | 46,599 | 58.7% | 656ms |
| json-large.json | json | large | none | 112,966 | 112,966 | 0.0% | 73ms |
| json-large.json | json | large | pointer | 112,966 | 216 | 99.8% | 73ms |
| json-large.json | json | large | truncate | 112,966 | 413 | 99.6% | 71ms |
| json-medium.json | json | medium | headroom | 28,185 | 11,767 | 58.3% | 634ms |
| json-medium.json | json | medium | none | 28,185 | 28,185 | 0.0% | 56ms |
| json-medium.json | json | medium | pointer | 28,185 | 214 | 99.2% | 78ms |
| json-medium.json | json | medium | truncate | 28,185 | 417 | 98.5% | 66ms |
| json-small.json | json | small | headroom | 5,672 | 3,832 | 32.4% | 623ms |
| json-small.json | json | small | none | 5,672 | 5,672 | 0.0% | 78ms |
| json-small.json | json | small | pointer | 5,672 | 212 | 96.3% | 65ms |
| json-small.json | json | small | truncate | 5,672 | 395 | 93.0% | 55ms |
| logs-large.log | logs | large | headroom | 91,993 | 6,979 | 92.4% | 302ms |
| logs-large.log | logs | large | none | 91,993 | 91,992 | 0.0% | 61ms |
| logs-large.log | logs | large | pointer | 91,993 | 672 | 99.3% | 84ms |
| logs-large.log | logs | large | truncate | 91,993 | 1,661 | 98.2% | 78ms |
| logs-medium.log | logs | medium | headroom | 18,639 | 7,628 | 59.1% | 299ms |
| logs-medium.log | logs | medium | none | 18,639 | 18,638 | 0.0% | 57ms |
| logs-medium.log | logs | medium | pointer | 18,639 | 640 | 96.6% | 85ms |
| logs-medium.log | logs | medium | truncate | 18,639 | 1,640 | 91.2% | 67ms |
| logs-small.log | logs | small | headroom | 5,057 | 4,618 | 8.7% | 276ms |
| logs-small.log | logs | small | none | 5,057 | 5,056 | 0.0% | 52ms |
| logs-small.log | logs | small | pointer | 5,057 | 636 | 87.4% | 80ms |
| logs-small.log | logs | small | truncate | 5,057 | 1,558 | 69.2% | 62ms |
| metadata-large.yaml | metadata | large | none | 7,082 | 7,081 | 0.0% | 72ms |
| metadata-large.yaml | metadata | large | truncate | 7,082 | 417 | 94.1% | 58ms |
| metadata-small.yaml | metadata | small | none | 1,755 | 1,754 | 0.1% | 58ms |
| metadata-small.yaml | metadata | small | truncate | 1,755 | 408 | 76.8% | 62ms |
| search-large.txt | search | large | headroom | 30,350 | 17,467 | 42.4% | 8328ms |
| search-large.txt | search | large | none | 30,350 | 30,349 | 0.0% | 68ms |
| search-large.txt | search | large | pointer | 30,350 | 534 | 98.2% | 60ms |
| search-large.txt | search | large | truncate | 30,350 | 1,284 | 95.8% | 66ms |
| search-medium.txt | search | medium | headroom | 6,317 | 3,670 | 41.9% | 6469ms |
| search-medium.txt | search | medium | none | 6,317 | 6,316 | 0.0% | 85ms |
| search-medium.txt | search | medium | pointer | 6,317 | 552 | 91.3% | 77ms |
| search-medium.txt | search | medium | truncate | 6,317 | 1,330 | 78.9% | 83ms |
| search-small.txt | search | small | headroom | 1,304 | 1,004 | 23.0% | 6540ms |
| search-small.txt | search | small | none | 1,304 | 1,303 | 0.1% | 69ms |
| search-small.txt | search | small | pointer | 1,304 | 592 | 54.6% | 77ms |
| search-small.txt | search | small | truncate | 1,304 | 1,303 | 0.1% | 67ms |
| text-large.md | text | large | headroom | 35,665 | 15,494 | 56.6% | 11587ms |
| text-large.md | text | large | none | 35,665 | 35,664 | 0.0% | 61ms |
| text-large.md | text | large | pointer | 35,665 | 499 | 98.6% | 69ms |
| text-large.md | text | large | truncate | 35,665 | 1,220 | 96.6% | 67ms |
| text-medium.md | text | medium | headroom | 13,981 | 6,289 | 55.0% | 7644ms |
| text-medium.md | text | medium | none | 13,981 | 13,980 | 0.0% | 74ms |
| text-medium.md | text | medium | pointer | 13,981 | 500 | 96.4% | 55ms |
| text-medium.md | text | medium | truncate | 13,981 | 1,210 | 91.3% | 60ms |
| text-small.md | text | small | headroom | 2,961 | 1,395 | 52.9% | 6412ms |
| text-small.md | text | small | none | 2,961 | 2,960 | 0.0% | 54ms |
| text-small.md | text | small | pointer | 2,961 | 498 | 83.2% | 87ms |
| text-small.md | text | small | truncate | 2,961 | 1,219 | 58.8% | 81ms |
| tool-large.txt | tool_output | large | headroom | 12,522 | 12,127 | 3.2% | 6663ms |
| tool-large.txt | tool_output | large | none | 12,522 | 12,521 | 0.0% | 53ms |
| tool-large.txt | tool_output | large | pointer | 12,522 | 308 | 97.5% | 74ms |
| tool-large.txt | tool_output | large | truncate | 12,522 | 654 | 94.8% | 64ms |
| tool-medium.txt | tool_output | medium | headroom | 3,569 | 3,248 | 9.0% | 6443ms |
| tool-medium.txt | tool_output | medium | none | 3,569 | 3,568 | 0.0% | 56ms |
| tool-medium.txt | tool_output | medium | pointer | 3,569 | 306 | 91.4% | 84ms |
| tool-medium.txt | tool_output | medium | truncate | 3,569 | 648 | 81.8% | 91ms |
| tool-small.txt | tool_output | small | headroom | 1,513 | 1,280 | 15.4% | 6359ms |
| tool-small.txt | tool_output | small | none | 1,513 | 1,512 | 0.1% | 51ms |
| tool-small.txt | tool_output | small | pointer | 1,513 | 305 | 79.8% | 69ms |
| tool-small.txt | tool_output | small | truncate | 1,513 | 660 | 56.4% | 72ms |

## Key Findings

1. **Headroom** tested on 8 types, avg **42.8% reduction** (24 measurements).
2. **Pointer**: constant ~438B output (18 files). Best for large tool output.
3. **Truncate** (zero-dep fallback): avg **76.9% reduction** (29 measurements).
4. **Treesitter** (regex fallback): avg **3.8% reduction** on code — strips comments/blanks only.

## Engine Availability Notes

| Engine | Status | Notes |
|--------|--------|-------|
| **none** | Ready | Passthrough, zero deps |
| **truncate** | Ready | Zero deps, first/last N lines |
| **pointer** | Ready | Zero deps, constant ~460B summary |
| **headroom** | Ready | Local ML model, 6-12s per file |
| **treesitter** | Partial | `tree-sitter` CLI not installed; regex fallback active (3-9% vs expected 10-20% with full AST) |
| **claw** | Blocked | PyPI `claw-compactor` is an unrelated package (EngramEngine v7.x). Real Claw Compactor not on PyPI. |
| **llmlingua** | Blocked | Requires HuggingFace BERT model download (~500MB). Needs internet access. |

