#!/usr/bin/env bash
set -euo pipefail

# compare.sh — Parse METRICS blocks from subagent output and show comparison.
# Input: two files (baseline results, optimized results) with METRICS blocks.
# Or: pipe combined output and specify --baseline-label and --optimized-label.

usage() {
  echo "Usage: compare.sh [--json] <baseline_file> <optimized_file>"
  echo "   or: compare.sh --parse <single_file>  (extract metrics from one file)"
  echo
  echo "Options:"
  echo "  --json    Output comparison as JSON (for scripting)"
  echo
  echo "Each file should contain one or more METRICS blocks like:"
  echo "  METRICS:"
  echo "  tool_calls: 5"
  echo "  code_lines: 12"
  echo "  explanation_lines: 3"
  echo "  files_read: 2"
  exit 0
}

[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && usage

extract_metrics() {
  local file="$1"
  python3 -c "
import re, json, sys

text = open('$file').read()
blocks = re.findall(r'METRICS:\s*\n((?:\w+:\s*\d+\s*\n?)+)', text)
if not blocks:
    print('{}')
    sys.exit(0)

all_metrics = []
for block in blocks:
    m = {}
    for line in block.strip().split('\n'):
        key, val = line.split(':', 1)
        m[key.strip()] = int(val.strip())
    all_metrics.append(m)

# Average across trials
keys = all_metrics[0].keys()
avg = {}
for k in keys:
    vals = [m.get(k, 0) for m in all_metrics]
    avg[k] = sum(vals) / len(vals)
avg['_trials'] = len(all_metrics)
print(json.dumps(avg))
"
}

if [ "${1:-}" = "--parse" ]; then
  [ -z "${2:-}" ] && { echo "Missing file argument"; exit 1; }
  extract_metrics "$2"
  exit 0
fi

JSON_OUTPUT=false
if [ "${1:-}" = "--json" ]; then
  JSON_OUTPUT=true
  shift
fi

[ $# -lt 2 ] && usage

BASELINE_FILE="$1"
OPTIMIZED_FILE="$2"

[ ! -f "$BASELINE_FILE" ] && { echo "[FAIL] Not found: $BASELINE_FILE"; exit 1; }
[ ! -f "$OPTIMIZED_FILE" ] && { echo "[FAIL] Not found: $OPTIMIZED_FILE"; exit 1; }

B=$(extract_metrics "$BASELINE_FILE")
O=$(extract_metrics "$OPTIMIZED_FILE")

if [ "$JSON_OUTPUT" = true ]; then
  python3 -c "
import json
b = json.loads('$B')
o = json.loads('$O')
result = {}
for key in ['tool_calls', 'code_lines', 'explanation_lines', 'files_read']:
    bv, ov = b.get(key, 0), o.get(key, 0)
    delta = ((ov - bv) / bv * 100) if bv > 0 else 0
    result[key] = {'baseline': bv, 'optimized': ov, 'delta_pct': round(delta, 1)}
result['_trials'] = {'baseline': int(b.get('_trials', 1)), 'optimized': int(o.get('_trials', 1))}
print(json.dumps(result, indent=2))
"
  exit 0
fi

python3 -c "
import json

b = json.loads('$B')
o = json.loads('$O')

print()
print('╔═══════════════════════════════════════════════════════╗')
print('║              save-token A/B Results                   ║')
print('╠═══════════════════════════════════════════════════════╣')
print(f'║ Trials: {int(b.get(\"_trials\",1))} baseline, {int(o.get(\"_trials\",1))} optimized{\" \" * 25}║')
print('╠═══════════════════════════════════════════════════════╣')
print('║ Metric            │ Baseline │ Optimized │ Change    ║')
print('╠═══════════════════════════════════════════════════════╣')

for key in ['tool_calls', 'code_lines', 'explanation_lines', 'files_read']:
    bv = b.get(key, 0)
    ov = o.get(key, 0)
    if bv > 0:
        delta = ((ov - bv) / bv) * 100
        sign = '+' if delta > 0 else ''
        delta_str = f'{sign}{delta:.0f}%'
    else:
        delta_str = 'n/a'
    print(f'║ {key:<18}│ {bv:>8.1f} │ {ov:>9.1f} │ {delta_str:>9} ║')

print('╚═══════════════════════════════════════════════════════╝')
print()
"
