#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
QUALITY_DIR="${REPO_DIR}/benchmarks/quality"

usage() {
  echo "Usage: quality-bench.sh [command] [options]"
  echo
  echo "Software development quality benchmark suite."
  echo "Measures code correctness + quality alongside token cost."
  echo
  echo "Commands:"
  echo "  list                     List available quality benchmarks"
  echo "  validate <file.py>       Validate generated code against a benchmark"
  echo "  validate-all <dir>       Validate all .py files in dir against matching benchmarks"
  echo "  score <file.py>          Full quality score (correctness + quality checks)"
  echo "  report <results.json>    Generate quality report from A/B results"
  echo "  show <benchmark_id>      Show benchmark details (prompt + tests + checks)"
  echo
  echo "Options:"
  echo "  --benchmark=ID  Target specific benchmark (default: auto-detect from filename)"
  echo
  echo "Benchmark format: benchmarks/quality/<id>.json"
  echo "  Each has: prompt, test cases, quality_checks (max_lines, banned/required patterns)"
  exit 0
}

[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && usage

list_benchmarks() {
  echo "╔══════════════════════════════════════╗"
  echo "║   save-token quality benchmarks      ║"
  echo "╚══════════════════════════════════════╝"
  echo
  printf "%-20s %-10s %-6s %s\n" "ID" "LANGUAGE" "TESTS" "FUNCTION"
  printf "%-20s %-10s %-6s %s\n" "---" "---" "---" "---"
  for f in "$QUALITY_DIR"/*.json; do
    [ -f "$f" ] || continue
    python3 -c "
import json
with open('$f') as fh:
    d = json.load(fh)
    tests = len(d.get('tests', []))
    print(f'{d[\"id\"]:<20} {d.get(\"language\",\"?\"):<10} {tests:<6} {d.get(\"function\",\"?\")}')
" 2>/dev/null
  done
  echo
  count=$(find "$QUALITY_DIR" -name "*.json" 2>/dev/null | wc -l)
  echo "Total: $count benchmarks"
}

show_benchmark() {
  local id="${1:-}"
  local bench_file="${QUALITY_DIR}/${id}.json"
  if [ ! -f "$bench_file" ]; then
    echo "[FAIL] Benchmark not found: $id" >&2; exit 1
  fi
  python3 -c "
import json
with open('$bench_file') as f:
    d = json.load(f)
print(f'ID:       {d[\"id\"]}')
print(f'Language: {d.get(\"language\", \"?\")}')
print(f'Function: {d.get(\"function\", \"?\")}')
print(f'Tests:    {len(d.get(\"tests\", []))}')
print()
print('Prompt:')
print(f'  {d[\"prompt\"]}')
print()
qc = d.get('quality_checks', {})
if qc:
    print('Quality checks:')
    print(f'  Max lines:         {qc.get(\"max_lines\", \"n/a\")}')
    print(f'  Banned patterns:   {qc.get(\"banned_patterns\", [])}')
    print(f'  Required patterns: {qc.get(\"required_patterns\", [])}')
"
}

validate_code() {
  local code_file="${1:-}"
  local bench_id="${2:-}"

  if [ ! -f "$code_file" ]; then
    echo "[FAIL] Code file not found: $code_file" >&2; exit 1
  fi

  if [ -z "$bench_id" ]; then
    bench_id=$(basename "$code_file" .py)
  fi

  local bench_file="${QUALITY_DIR}/${bench_id}.json"
  if [ ! -f "$bench_file" ]; then
    echo "[FAIL] Benchmark not found: $bench_id" >&2; exit 1
  fi

  python3 - "$code_file" "$bench_file" << 'PYEOF'
import json, sys, importlib.util, traceback, os

code_file = sys.argv[1]
bench_file = sys.argv[2]

with open(bench_file) as f:
    bench = json.load(f)

with open(code_file) as f:
    code = f.read()

results = {
    "benchmark": bench["id"],
    "correctness": {"passed": 0, "failed": 0, "errors": []},
    "quality": {"passed": 0, "failed": 0, "issues": []}
}

# Load the code as a module
spec = importlib.util.spec_from_file_location("solution", code_file)
mod = importlib.util.module_from_spec(spec)
try:
    spec.loader.exec_module(mod)
except Exception as e:
    results["correctness"]["errors"].append(f"Import error: {e}")
    print(json.dumps(results, indent=2))
    sys.exit(0)

func_name = bench.get("function", "")
setup_code = bench.get("setup", "")
if setup_code:
    exec(setup_code, mod.__dict__)

# Run tests
for i, test in enumerate(bench.get("tests", [])):
    test_type = test.get("type", "simple")
    try:
        if test_type == "simple":
            func = getattr(mod, func_name)
            result = func(*test["args"])
            if result == test["expected"]:
                results["correctness"]["passed"] += 1
            else:
                results["correctness"]["failed"] += 1
                results["correctness"]["errors"].append(
                    f"Test {i+1}: expected {test['expected']}, got {result}")

        elif test_type == "sequence":
            obj = getattr(mod, func_name)(test["steps"][0]["args"][0])
            for step in test["steps"][1:]:
                method = getattr(obj, step["method"])
                result = method(*step["args"])
                if step["expected"] is not None:
                    if result == step["expected"]:
                        results["correctness"]["passed"] += 1
                    else:
                        results["correctness"]["failed"] += 1
                        results["correctness"]["errors"].append(
                            f"Step {step['method']}({step['args']}): expected {step['expected']}, got {result}")
                else:
                    results["correctness"]["passed"] += 1

        elif test_type == "exec":
            exec_globals = dict(mod.__dict__)
            exec(test["code"], exec_globals)
            results["correctness"]["passed"] += 1

        elif test_type == "with_setup":
            exec_globals = dict(mod.__dict__)
            exec(f"{test['setup_var']} = {test['setup_call']}", exec_globals)
            result = eval(test["call"], exec_globals)
            if result == test["expected"]:
                results["correctness"]["passed"] += 1
            else:
                results["correctness"]["failed"] += 1
                results["correctness"]["errors"].append(
                    f"Test: expected {test['expected']}, got {result}")
            if test.get("cleanup"):
                exec(test["cleanup"], exec_globals)

    except Exception as e:
        results["correctness"]["failed"] += 1
        results["correctness"]["errors"].append(f"Test {i+1}: {type(e).__name__}: {e}")

# Quality checks
qc = bench.get("quality_checks", {})
lines = code.strip().split("\n")
code_lines = [l for l in lines if l.strip() and not l.strip().startswith("#")]

max_lines = qc.get("max_lines")
if max_lines and len(code_lines) > max_lines:
    results["quality"]["failed"] += 1
    results["quality"]["issues"].append(f"Too many lines: {len(code_lines)} > {max_lines}")
else:
    results["quality"]["passed"] += 1

for pattern in qc.get("banned_patterns", []):
    if pattern in code:
        results["quality"]["failed"] += 1
        results["quality"]["issues"].append(f"Banned pattern found: {pattern}")
    else:
        results["quality"]["passed"] += 1

for pattern in qc.get("required_patterns", []):
    if pattern in code:
        results["quality"]["passed"] += 1
    else:
        results["quality"]["failed"] += 1
        results["quality"]["issues"].append(f"Required pattern missing: {pattern}")

# Summary
total_correct = results["correctness"]["passed"] + results["correctness"]["failed"]
total_quality = results["quality"]["passed"] + results["quality"]["failed"]
correct_pct = (results["correctness"]["passed"] / max(total_correct, 1)) * 100
quality_pct = (results["quality"]["passed"] / max(total_quality, 1)) * 100

results["summary"] = {
    "correctness_pct": round(correct_pct, 1),
    "quality_pct": round(quality_pct, 1),
    "overall_pct": round((correct_pct + quality_pct) / 2, 1),
    "code_lines": len(code_lines),
    "grade": "A" if correct_pct == 100 and quality_pct == 100 else
             "B" if correct_pct >= 80 and quality_pct >= 80 else
             "C" if correct_pct >= 60 else "F"
}

print(json.dumps(results, indent=2))
PYEOF
}

score_code() {
  local code_file="${1:-}"
  local bench_id="${2:-}"
  local tmpjson
  tmpjson=$(mktemp /tmp/st-score-XXXXXX.json)

  validate_code "$code_file" "$bench_id" > "$tmpjson"
  python3 -c "
import json, sys
with open('$tmpjson') as f:
    r = json.load(f)
s = r['summary']
print('╔══════════════════════════════════════╗')
print('║   save-token quality score           ║')
print('╚══════════════════════════════════════╝')
print()
print(f'  Benchmark:     {r[\"benchmark\"]}')
print(f'  Correctness:   {s[\"correctness_pct\"]}% ({r[\"correctness\"][\"passed\"]}/{r[\"correctness\"][\"passed\"]+r[\"correctness\"][\"failed\"]})')
print(f'  Quality:       {s[\"quality_pct\"]}% ({r[\"quality\"][\"passed\"]}/{r[\"quality\"][\"passed\"]+r[\"quality\"][\"failed\"]})')
print(f'  Code lines:    {s[\"code_lines\"]}')
print(f'  Overall:       {s[\"overall_pct\"]}%')
print(f'  Grade:         {s[\"grade\"]}')
if r['correctness']['errors']:
    print()
    print('  Failures:')
    for e in r['correctness']['errors'][:5]:
        print(f'    - {e}')
if r['quality']['issues']:
    print()
    print('  Quality issues:')
    for i in r['quality']['issues']:
        print(f'    - {i}')
" 2>/dev/null
  rm -f "$tmpjson"
}

CMD="${1:-}"
shift 2>/dev/null || true

BENCH_ID=""
for arg in "$@"; do
  case "$arg" in
    --benchmark=*) BENCH_ID="${arg#--benchmark=}" ;;
  esac
done
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --benchmark=*) ;;
    *) POSITIONAL+=("$arg") ;;
  esac
done

case "$CMD" in
  list)      list_benchmarks ;;
  show)      show_benchmark "${POSITIONAL[0]:-}" ;;
  validate)  validate_code "${POSITIONAL[0]:-}" "$BENCH_ID" ;;
  score)     score_code "${POSITIONAL[0]:-}" "$BENCH_ID" ;;
  validate-all)
    dir="${POSITIONAL[0]:-.}"
    total_pass=0; total_fail=0
    for pyfile in "$dir"/*.py; do
      [ -f "$pyfile" ] || continue
      bid=$(basename "$pyfile" .py)
      if [ -f "${QUALITY_DIR}/${bid}.json" ]; then
        echo "--- $bid ---"
        score_code "$pyfile" "$bid"
        echo
      fi
    done
    ;;
  report)
    results_file="${POSITIONAL[0]:-}"
    if [ -z "$results_file" ] || [ ! -f "$results_file" ]; then
      echo "Usage: quality-bench.sh report <results.json>" >&2; exit 1
    fi
    python3 -c "
import json
with open('$results_file') as f:
    data = json.load(f)
print('## Quality Benchmark Report')
print()
print('| Benchmark | Correctness | Quality | Lines | Grade |')
print('|-----------|-------------|---------|-------|-------|')
for r in data:
    s = r['summary']
    print(f'| {r[\"benchmark\"]} | {s[\"correctness_pct\"]}% | {s[\"quality_pct\"]}% | {s[\"code_lines\"]} | {s[\"grade\"]} |')
" 2>/dev/null
    ;;
  -h|--help|"") usage ;;
  *)         echo "[FAIL] Unknown command: $CMD" >&2; exit 1 ;;
esac
