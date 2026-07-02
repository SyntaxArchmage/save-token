#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
QUALITY_DIR="${REPO_DIR}/benchmarks/quality"
RULES_DIR="${REPO_DIR}/rules"
COMPONENTS_DIR="${RULES_DIR}/components"
RESULTS_DIR="${REPO_DIR}/benchmarks/results"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

TRIALS=5
BENCHMARKS=""
CONDITIONS=""
RESUME_FILE=""
OUTPUT_FILE="${RESULTS_DIR}/component-bench-${TIMESTAMP}.json"
CMD="${1:-}"
BENCH_ID=""
CONDITION=""
TRIAL_NUM="1"

ALL_CONDITIONS="baseline code-ladder tool-discipline output-economy context-eviction full lite ultra"

ALL_BENCHMARKS=$(find "$QUALITY_DIR" -name "*.json" -exec basename {} .json \; 2>/dev/null | sort | tr '\n' ' ')

usage() {
  cat <<'USAGE'
Usage: component-bench.sh <command> [options]

Component-level A/B benchmark runner. Tests each save-token component
independently across quality benchmarks.

Commands:
  prepare             Generate subagent prompts for all conditions
  record <file.py>    Record a trial result (validate code + append to results)
  status              Show progress (trials completed per condition/benchmark)
  matrix              Show the test matrix (conditions x benchmarks)

Options:
  --benchmarks=ID,...    Comma-separated benchmark IDs (default: all 25)
  --conditions=ID,...    Comma-separated conditions (default: all 8)
  --trials=N             Trials per condition (default: 5)
  --resume=FILE          Append results to existing file
  --output=FILE          Output file path
  --benchmark=ID         Benchmark ID for record command
  --condition=ID         Condition ID for record command
  --trial=N              Trial number for record command

Conditions:
  baseline          No rules (control)
  code-ladder       Code Ladder section only
  tool-discipline   Tool Discipline section only
  output-economy    Output Economy section only
  context-eviction  Context Eviction section only
  full              Complete agent-rules.md (full mode)
  lite              Complete rules at lite intensity
  ultra             Complete rules at ultra intensity

USAGE
  exit 0
}

[ "${CMD:-}" = "-h" ] || [ "${CMD:-}" = "--help" ] && usage

shift 2>/dev/null || true
for arg in "$@"; do
  case "$arg" in
    --benchmarks=*)  BENCHMARKS="${arg#--benchmarks=}" ;;
    --conditions=*)  CONDITIONS="${arg#--conditions=}" ;;
    --trials=*)      TRIALS="${arg#--trials=}" ;;
    --resume=*)      RESUME_FILE="${arg#--resume=}"; OUTPUT_FILE="$RESUME_FILE" ;;
    --output=*)      OUTPUT_FILE="${arg#--output=}" ;;
    --benchmark=*)   BENCH_ID="${arg#--benchmark=}" ;;
    --condition=*)   CONDITION="${arg#--condition=}" ;;
    --trial=*)       TRIAL_NUM="${arg#--trial=}" ;;
  esac
done

[ -z "$BENCHMARKS" ] && BENCHMARKS="$ALL_BENCHMARKS"
[ -z "$CONDITIONS" ] && CONDITIONS="$ALL_CONDITIONS"

BENCHMARKS=$(echo "$BENCHMARKS" | tr ',' ' ')
CONDITIONS=$(echo "$CONDITIONS" | tr ',' ' ')

get_rules_for_condition() {
  local condition="$1"
  case "$condition" in
    baseline)
      echo ""
      ;;
    code-ladder)
      cat "$COMPONENTS_DIR/code-ladder.md"
      ;;
    tool-discipline)
      cat "$COMPONENTS_DIR/tool-discipline.md"
      ;;
    output-economy)
      cat "$COMPONENTS_DIR/output-economy.md"
      ;;
    context-eviction)
      cat "$COMPONENTS_DIR/context-eviction.md"
      ;;
    full)
      cat "$RULES_DIR/agent-rules.md"
      ;;
    lite)
      cat "$RULES_DIR/agent-rules.md"
      echo ""
      echo "IMPORTANT: Use LITE intensity. Code ladder is advisory only."
      ;;
    ultra)
      cat "$RULES_DIR/agent-rules.md"
      echo ""
      echo "IMPORTANT: Use ULTRA intensity. Zero prose. Single-expression preference. Challenge every request."
      ;;
    *)
      echo "[FAIL] Unknown condition: $condition" >&2
      return 1
      ;;
  esac
}

build_prompt() {
  local bench_id="$1"
  local condition="$2"
  local bench_file="${QUALITY_DIR}/${bench_id}.json"

  if [ ! -f "$bench_file" ]; then
    echo "[FAIL] Benchmark not found: $bench_id" >&2
    return 1
  fi

  local task_prompt
  task_prompt=$(python3 -c "
import json
with open('$bench_file') as f:
    print(json.load(f)['prompt'])
")

  local rules
  rules=$(get_rules_for_condition "$condition")

  local metrics_suffix='

After completing, output this EXACT block (fill in numbers):
```
METRICS:
tool_calls: <total tool calls you made>
code_lines: <lines of code in your solution>
explanation_lines: <lines of non-code explanation>
files_read: <files you read>
```

IMPORTANT: Write your solution code ONLY, no explanations unless the rules say otherwise. Put the code in a fenced code block marked ```python so it can be extracted for automated quality testing.'

  if [ -n "$rules" ]; then
    echo "IMPORTANT: Follow these rules for EVERY response:"
    echo ""
    echo "$rules"
    echo ""
    echo "---"
    echo ""
  fi
  echo "$task_prompt"
  echo "$metrics_suffix"
}

cmd_prepare() {
  local prompt_dir="${RESULTS_DIR}/component-prompts"
  mkdir -p "$prompt_dir"

  local total=0
  for bench in $BENCHMARKS; do
    for cond in $CONDITIONS; do
      local outfile="${prompt_dir}/${bench}__${cond}.txt"
      build_prompt "$bench" "$cond" > "$outfile"
      total=$((total + 1))
    done
  done

  local bench_count cond_count
  bench_count=$(echo "$BENCHMARKS" | wc -w)
  cond_count=$(echo "$CONDITIONS" | wc -w)

  echo "╔══════════════════════════════════════════════╗"
  echo "║    component-bench: prompts prepared          ║"
  echo "╚══════════════════════════════════════════════╝"
  echo
  echo "Benchmarks: $bench_count"
  echo "Conditions: $cond_count"
  echo "Trials:     $TRIALS per condition"
  echo "Total:      $((bench_count * cond_count * TRIALS)) subagent invocations"
  echo "Prompts:    ${prompt_dir}/"
  echo "Output:     ${OUTPUT_FILE}"
  echo
  echo "Prompt files: ${total} (benchmark__condition.txt)"
  echo
  echo "To run from Cursor, launch best-of-n-runner subagents with each prompt."
  echo "After each subagent completes, record the result:"
  echo "  bash scripts/component-bench.sh record solution.py \\"
  echo "    --benchmark=<id> --condition=<cond> --trial=<n>"
}

cmd_record() {
  local code_file="${1:-}"
  local bench_id="$BENCH_ID"
  local condition="$CONDITION"
  local trial="$TRIAL_NUM"

  if [ -z "$code_file" ] || [ ! -f "$code_file" ]; then
    echo "[FAIL] Code file required: component-bench.sh record <file.py> --benchmark=ID --condition=COND" >&2
    exit 1
  fi
  if [ -z "$bench_id" ]; then
    bench_id=$(basename "$code_file" .py)
  fi
  if [ -z "$condition" ]; then
    echo "[FAIL] --condition required" >&2; exit 1
  fi

  local validation
  validation=$(bash "$SCRIPT_DIR/quality-bench.sh" validate "$code_file" --benchmark="$bench_id" 2>/dev/null)

  local code_lines explanation_lines tool_calls
  code_lines=$(echo "$validation" | python3 -c "import json,sys; print(json.load(sys.stdin)['summary']['code_lines'])" 2>/dev/null || echo 0)

  local entry
  entry=$(python3 -c "
import json, sys

validation = json.loads('''$validation''')
summary = validation['summary']

entry = {
    'benchmark': '$bench_id',
    'condition': '$condition',
    'trial': int('$trial'),
    'correctness_pct': summary['correctness_pct'],
    'quality_pct': summary['quality_pct'],
    'grade': summary['grade'],
    'code_lines': summary['code_lines'],
    'correctness_passed': validation['correctness']['passed'],
    'correctness_failed': validation['correctness']['failed'],
    'quality_passed': validation['quality']['passed'],
    'quality_failed': validation['quality']['failed']
}
print(json.dumps(entry))
")

  if [ -f "$OUTPUT_FILE" ]; then
    local existing
    existing=$(cat "$OUTPUT_FILE")
    python3 -c "
import json
data = json.loads('''$existing''')
data['trials'].append(json.loads('''$entry'''))
with open('$OUTPUT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
  else
    python3 -c "
import json
data = {
    'version': '1.0',
    'started': '$(date -Iseconds)',
    'config': {
        'trials_per_condition': $TRIALS,
        'benchmarks': '$BENCHMARKS'.split(),
        'conditions': '$CONDITIONS'.split()
    },
    'trials': [json.loads('''$entry''')]
}
with open('$OUTPUT_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
  fi

  echo "[OK] Recorded: $bench_id / $condition / trial $trial → grade $(echo "$entry" | python3 -c "import json,sys;print(json.load(sys.stdin)['grade'])")"
}

cmd_status() {
  local data_file="${RESUME_FILE:-$OUTPUT_FILE}"
  if [ ! -f "$data_file" ]; then
    echo "[INFO] No results file found. Run 'prepare' first, then 'record' trials."
    exit 0
  fi

  python3 - "$data_file" << 'PYEOF'
import json, sys
from collections import Counter

with open(sys.argv[1]) as f:
    data = json.load(f)

trials = data.get("trials", [])
config = data.get("config", {})
target = config.get("trials_per_condition", 5)

print("╔══════════════════════════════════════════════╗")
print("║    component-bench: progress                  ║")
print("╚══════════════════════════════════════════════╝")
print()
print(f"Total trials recorded: {len(trials)}")
print(f"Target per condition:  {target}")
print()

by_condition = Counter()
by_benchmark = Counter()
pairs = Counter()
for t in trials:
    by_condition[t["condition"]] += 1
    by_benchmark[t["benchmark"]] += 1
    pairs[(t["benchmark"], t["condition"])] += 1

print(f"{'Condition':<20} {'Trials':<8} {'Complete'}")
print(f"{'─'*20} {'─'*8} {'─'*8}")
for cond in sorted(by_condition):
    n = by_condition[cond]
    benchmarks_for_cond = len(set(t["benchmark"] for t in trials if t["condition"] == cond))
    complete = sum(1 for b in set(t["benchmark"] for t in trials if t["condition"] == cond)
                   if pairs[(b, cond)] >= target)
    print(f"{cond:<20} {n:<8} {complete}/{benchmarks_for_cond}")

print()
missing = []
all_benchmarks = config.get("benchmarks", [])
all_conditions = config.get("conditions", [])
for b in all_benchmarks:
    for c in all_conditions:
        done = pairs.get((b, c), 0)
        if done < target:
            missing.append(f"  {b} / {c}: {done}/{target}")
if missing:
    print(f"Missing trials ({len(missing)}):")
    for m in missing[:20]:
        print(m)
    if len(missing) > 20:
        print(f"  ... and {len(missing) - 20} more")
else:
    print("All trials complete!")
PYEOF
}

cmd_matrix() {
  local bench_count cond_count
  bench_count=$(echo "$BENCHMARKS" | wc -w)
  cond_count=$(echo "$CONDITIONS" | wc -w)

  echo "╔══════════════════════════════════════════════╗"
  echo "║    component-bench: test matrix               ║"
  echo "╚══════════════════════════════════════════════╝"
  echo
  echo "Conditions ($cond_count):"
  for c in $CONDITIONS; do
    printf "  %-20s " "$c"
    case "$c" in
      baseline)         echo "No rules (control)" ;;
      code-ladder)      echo "Code Ladder section only" ;;
      tool-discipline)  echo "Tool Discipline section only" ;;
      output-economy)   echo "Output Economy section only" ;;
      context-eviction) echo "Context Eviction section only" ;;
      full)             echo "Complete agent-rules.md" ;;
      lite)             echo "Full rules, lite intensity" ;;
      ultra)            echo "Full rules, ultra intensity" ;;
    esac
  done
  echo
  echo "Benchmarks ($bench_count):"
  for b in $BENCHMARKS; do
    echo "  $b"
  done
  echo
  echo "Trials: $TRIALS per cell"
  echo "Total:  $((bench_count * cond_count * TRIALS)) subagent invocations"
}

POSITIONAL_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --*) ;;
    *)   POSITIONAL_ARGS+=("$arg") ;;
  esac
done

case "${CMD:-}" in
  prepare)     cmd_prepare ;;
  record)      cmd_record "${POSITIONAL_ARGS[0]:-}" ;;
  status)      cmd_status ;;
  matrix)      cmd_matrix ;;
  -h|--help|"") usage ;;
  *)           echo "[FAIL] Unknown command: $CMD" >&2; exit 1 ;;
esac
