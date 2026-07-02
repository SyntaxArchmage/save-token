#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="${REPO_DIR}/benchmarks/results"

FORMAT="markdown"
INPUT_FILE=""

for arg in "$@"; do
  case "$arg" in
    --format=*)  FORMAT="${arg#--format=}" ;;
    -h|--help)
      echo "Usage: component-report.sh [options] <results.json>"
      echo
      echo "Generate component effect matrix from benchmark results."
      echo
      echo "Options:"
      echo "  --format=markdown|csv|json   Output format (default: markdown)"
      exit 0
      ;;
    *)           INPUT_FILE="$arg" ;;
  esac
done

if [ -z "$INPUT_FILE" ]; then
  INPUT_FILE=$(ls -t "$RESULTS_DIR"/component-bench-*.json 2>/dev/null | head -1)
  if [ -z "$INPUT_FILE" ]; then
    echo "[FAIL] No results file found. Run component-bench.sh first." >&2
    exit 1
  fi
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "[FAIL] File not found: $INPUT_FILE" >&2
  exit 1
fi

python3 - "$INPUT_FILE" "$FORMAT" << 'PYEOF'
import json, sys
from collections import defaultdict
import math

data_file = sys.argv[1]
fmt = sys.argv[2]

with open(data_file) as f:
    data = json.load(f)

trials = data.get("trials", [])
if not trials:
    print("[FAIL] No trial data found.", file=sys.stderr)
    sys.exit(1)

by_cond = defaultdict(list)
by_bench = defaultdict(list)
by_pair = defaultdict(list)

for t in trials:
    by_cond[t["condition"]].append(t)
    by_bench[t["benchmark"]].append(t)
    by_pair[(t["benchmark"], t["condition"])].append(t)

def mean(vals):
    return sum(vals) / len(vals) if vals else 0

def stddev(vals):
    if len(vals) < 2:
        return 0
    m = mean(vals)
    return math.sqrt(sum((x - m) ** 2 for x in vals) / (len(vals) - 1))

def grade_dist(trial_list):
    grades = {"A": 0, "B": 0, "C": 0, "F": 0}
    for t in trial_list:
        g = t.get("grade", "F")
        grades[g] = grades.get(g, 0) + 1
    return grades

def pct_delta(baseline_val, condition_val):
    if baseline_val == 0:
        return 0
    return ((condition_val - baseline_val) / baseline_val) * 100

conditions_order = [
    "baseline", "code-ladder", "tool-discipline", "output-economy",
    "context-eviction", "full", "lite", "ultra"
]

conditions_present = [c for c in conditions_order if c in by_cond]

baseline_trials = by_cond.get("baseline", [])
baseline_code = mean([t["code_lines"] for t in baseline_trials]) if baseline_trials else 0
baseline_correct = mean([t["correctness_pct"] for t in baseline_trials]) if baseline_trials else 0
baseline_quality = mean([t["quality_pct"] for t in baseline_trials]) if baseline_trials else 0

# --- Table 1: Component Effect Matrix ---
print("# Component Effect Matrix")
print()
print(f"Based on {len(trials)} trials across {len(set(t['benchmark'] for t in trials))} benchmarks.")
print()

header = "| Component | Trials | Code Lines (avg) | Δ Code | Correctness | Quality | Grade Dist | "
sep = "|-----------|--------|-----------------|--------|------------|---------|------------|"
print(header)
print(sep)

for cond in conditions_present:
    ct = by_cond[cond]
    n = len(ct)
    avg_code = mean([t["code_lines"] for t in ct])
    avg_correct = mean([t["correctness_pct"] for t in ct])
    avg_quality = mean([t["quality_pct"] for t in ct])
    gd = grade_dist(ct)

    if cond == "baseline":
        delta_code = "—"
    else:
        d = pct_delta(baseline_code, avg_code)
        delta_code = f"{d:+.1f}%"

    grade_str = f"{gd['A']}A/{gd['B']}B/{gd['C']}C/{gd['F']}F"

    print(f"| **{cond}** | {n} | {avg_code:.1f} | {delta_code} | {avg_correct:.1f}% | {avg_quality:.1f}% | {grade_str} |")

print()

# --- Table 2: Per-Benchmark Breakdown ---
print("## Per-Benchmark Breakdown")
print()

benchmarks_present = sorted(set(t["benchmark"] for t in trials))

header2_parts = ["| Benchmark"]
sep2_parts = ["|----------"]
for cond in conditions_present:
    header2_parts.append(f" {cond}")
    sep2_parts.append("-------")

print(" | ".join(header2_parts) + " |")
print(" | ".join(sep2_parts) + " |")

for bench in benchmarks_present:
    parts = [f"| {bench}"]
    for cond in conditions_present:
        pair_trials = by_pair.get((bench, cond), [])
        if pair_trials:
            avg_code = mean([t["code_lines"] for t in pair_trials])
            gd = grade_dist(pair_trials)
            grade_char = "A" if gd["A"] == len(pair_trials) else \
                         "B" if gd["A"] + gd["B"] == len(pair_trials) else \
                         "C" if gd["F"] == 0 else "F"
            parts.append(f" {avg_code:.0f}L/{grade_char}")
        else:
            parts.append(" —")
    print(" | ".join(parts) + " |")

print()

# --- Table 3: Statistical Summary ---
print("## Statistical Summary")
print()
print("| Component | Code Lines (mean±sd) | Correctness (mean±sd) | Quality (mean±sd) |")
print("|-----------|---------------------|----------------------|-------------------|")

for cond in conditions_present:
    ct = by_cond[cond]
    code_vals = [t["code_lines"] for t in ct]
    correct_vals = [t["correctness_pct"] for t in ct]
    quality_vals = [t["quality_pct"] for t in ct]

    code_str = f"{mean(code_vals):.1f} ± {stddev(code_vals):.1f}"
    correct_str = f"{mean(correct_vals):.1f} ± {stddev(correct_vals):.1f}"
    quality_str = f"{mean(quality_vals):.1f} ± {stddev(quality_vals):.1f}"

    print(f"| **{cond}** | {code_str} | {correct_str} | {quality_str} |")

print()

# --- Summary stats ---
print("## Key Findings")
print()

if baseline_trials and by_cond.get("full"):
    full_trials = by_cond["full"]
    full_code = mean([t["code_lines"] for t in full_trials])
    full_correct = mean([t["correctness_pct"] for t in full_trials])
    full_gd = grade_dist(full_trials)
    bl_gd = grade_dist(baseline_trials)

    print(f"- **Full mode vs baseline**: {pct_delta(baseline_code, full_code):+.1f}% code lines, "
          f"correctness {full_correct:.1f}% vs {baseline_correct:.1f}%")
    print(f"- **Baseline grades**: {bl_gd['A']}A / {bl_gd['B']}B / {bl_gd['C']}C / {bl_gd['F']}F")
    print(f"- **Full grades**: {full_gd['A']}A / {full_gd['B']}B / {full_gd['C']}C / {full_gd['F']}F")

best_component = None
best_delta = 0
for cond in ["code-ladder", "tool-discipline", "output-economy", "context-eviction"]:
    if cond in by_cond:
        ct = by_cond[cond]
        avg_code = mean([t["code_lines"] for t in ct])
        delta = pct_delta(baseline_code, avg_code)
        if delta < best_delta:
            best_delta = delta
            best_component = cond

if best_component:
    print(f"- **Most impactful single component**: {best_component} ({best_delta:+.1f}% code lines)")

print()
print(f"Total trials: {len(trials)}")
print(f"Benchmarks: {len(benchmarks_present)}")
print(f"Conditions: {len(conditions_present)}")
PYEOF
