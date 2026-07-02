#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_FILE="$REPO_DIR/benchmarks/results/compress-bench.json"
REPORT_FILE="$REPO_DIR/benchmarks/results/compress-bench-report.md"

if [ ! -f "$RESULTS_FILE" ]; then
  echo "[FAIL] No results. Run: compress-bench.sh run" >&2
  exit 1
fi

RESULTS="$RESULTS_FILE" REPORT="$REPORT_FILE" python3 << 'PYTHON'
import json, os, sys
from collections import defaultdict

with open(os.environ["RESULTS"]) as f:
    data = json.load(f)
if not data:
    print("[FAIL] Empty results.", file=sys.stderr); sys.exit(1)

matrix = defaultdict(lambda: defaultdict(list))
by_size = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))

for r in data:
    matrix[r["content_type"]][r["engine"]].append(r["reduction_pct"])
    by_size[r["content_type"]][r["size_class"]][r["engine"]].append(r)

all_types = sorted(set(r["content_type"] for r in data))
all_engines = sorted(set(r["engine"] for r in data))

L = []
L.append("# Compression Benchmark Report")
L.append(f"\nGenerated from {len(data)} measurements across {len(all_types)} content types and {len(all_engines)} engines.\n")

# ── Matrix ─────────────────────────────────────────────────────
L.append("## Compression Matrix (% reduction, higher = better)\n")
hdr = "| Content Type |" + "".join(f" {e} |" for e in all_engines)
sep = "|---|" + "".join("---:|" for _ in all_engines)
L.append(hdr)
L.append(sep)
for ct in all_types:
    row = f"| **{ct}** |"
    for eng in all_engines:
        vals = matrix[ct].get(eng, [])
        row += f" {sum(vals)/len(vals):.1f}% |" if vals else " — |"
    L.append(row)
L.append("")

# ── Size scaling ───────────────────────────────────────────────
L.append("## Size Scaling (reduction % by input size)\n")
L.append("| Content Type | Size | Input Bytes | Best Engine | Reduction |")
L.append("|---|---|---:|---|---:|")
for ct in all_types:
    for sz in ["small", "medium", "large"]:
        entries = by_size[ct].get(sz, {})
        if not entries: continue
        best_eng, best_red, inp = None, -999, 0
        for eng, rs in entries.items():
            if eng == "none": continue
            for r in rs:
                inp = r["input_bytes"]
                if r["reduction_pct"] > best_red:
                    best_red, best_eng = r["reduction_pct"], eng
        if best_eng:
            L.append(f"| {ct} | {sz} | {inp:,} | {best_eng} | {best_red:.1f}% |")
L.append("")

# ── Best engine per type ───────────────────────────────────────
L.append("## Best Engine per Content Type\n")
L.append("| Content Type | Best Engine | Avg Reduction | Runner-up | Avg Reduction |")
L.append("|---|---|---:|---|---:|")
for ct in all_types:
    ranked = sorted(
        [(e, sum(v)/len(v)) for e, v in matrix[ct].items() if e != "none" and v],
        key=lambda x: -x[1])
    if len(ranked) >= 2:
        L.append(f"| **{ct}** | **{ranked[0][0]}** | **{ranked[0][1]:.1f}%** | {ranked[1][0]} | {ranked[1][1]:.1f}% |")
    elif ranked:
        L.append(f"| **{ct}** | **{ranked[0][0]}** | **{ranked[0][1]:.1f}%** | — | — |")
L.append("")

# ── Per-fixture detail ─────────────────────────────────────────
L.append("## Per-Fixture Detail\n")
L.append("| Fixture | Type | Size | Engine | Input | Output | Reduction | Time |")
L.append("|---|---|---|---|---:|---:|---:|---:|")
for r in sorted(data, key=lambda x: (x["content_type"], x["fixture"], x["engine"])):
    L.append(f"| {r['fixture']} | {r['content_type']} | {r['size_class']} | {r['engine']} | "
             f"{r['input_bytes']:,} | {r['output_bytes']:,} | {r['reduction_pct']:.1f}% | {r['elapsed_ms']}ms |")
L.append("")

# ── Key findings ───────────────────────────────────────────────
L.append("## Key Findings\n")
n = 1
hr = [r for r in data if r["engine"] == "headroom"]
if hr:
    avg = sum(r["reduction_pct"] for r in hr) / len(hr)
    L.append(f"{n}. **Headroom** tested on {len(set(r['content_type'] for r in hr))} types, avg **{avg:.1f}% reduction** ({len(hr)} measurements).")
    n += 1
    wins = []
    for ct in sorted(set(r["content_type"] for r in hr)):
        hr_avg = sum(r["reduction_pct"] for r in hr if r["content_type"] == ct) / len([r for r in hr if r["content_type"] == ct])
        others = [(e, sum(v)/len(v)) for e, v in matrix[ct].items() if e not in ("none","headroom") and v]
        if others and hr_avg > max(others, key=lambda x: x[1])[1]:
            wins.append(ct)
    if wins:
        L.append(f"{n}. Headroom **best engine** for: {', '.join(wins)}.")
        n += 1

ptr = [r for r in data if r["engine"] == "pointer"]
if ptr:
    avg_sz = sum(r["output_bytes"] for r in ptr) / len(ptr)
    L.append(f"{n}. **Pointer**: constant ~{int(avg_sz)}B output ({len(ptr)} files). Best for large tool output.")
    n += 1

tr = [r for r in data if r["engine"] == "truncate"]
if tr:
    avg = sum(r["reduction_pct"] for r in tr) / len(tr)
    L.append(f"{n}. **Truncate** (zero-dep fallback): avg **{avg:.1f}% reduction** ({len(tr)} measurements).")
    n += 1

L.append("")
report = "\n".join(L)
with open(os.environ["REPORT"], "w") as f:
    f.write(report)
print(report)
PYTHON
