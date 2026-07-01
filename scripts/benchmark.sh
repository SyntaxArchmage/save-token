#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="${REPO_DIR}/benchmarks/results"
PROMPTS_DIR="${REPO_DIR}/benchmarks/prompts"
RULES_FILE="${REPO_DIR}/rules/agent-rules.md"
TRIALS="${SAVE_TOKEN_TRIALS:-3}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
MODEL=""
OUTPUT_FMT=""

mkdir -p "$RESULTS_DIR"

PROMPT_COUNT=$(find "$PROMPTS_DIR" -name "*.md" 2>/dev/null | wc -l)

# Pre-parse flags before positional handling
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --model=*)  MODEL="${arg#--model=}" ;;
    --output=*) OUTPUT_FMT="${arg#--output=}" ;;
    --trials=*) TRIALS="${arg#--trials=}" ;;
    *)          POSITIONAL+=("$arg") ;;
  esac
done
set -- "${POSITIONAL[@]+"${POSITIONAL[@]}"}"

OUTFILE="${RESULTS_DIR}/bench-${TIMESTAMP}.json"

usage() {
  echo "Usage: benchmark.sh [options] [prompt_file|prompt_string]"
  echo
  echo "Runs A/B comparison: baseline vs optimized (with agent-rules)."
  echo "Default: ${TRIALS} trials per arm (set SAVE_TOKEN_TRIALS to change)."
  echo "Available presets: ${PROMPT_COUNT} prompts in benchmarks/prompts/"
  echo
  echo "Options:"
  echo "  --model=MODEL   Target model slug (e.g. claude-4.6-sonnet-medium-thinking)"
  echo "  --trials=N      Trials per arm (default: 3)"
  echo "  --output=FMT    Output format: json (writes to file)"
  echo "  --list           List preset prompts"
  echo "  --all            Generate prompts for all presets"
  echo
  echo "Presets:"
  for f in "$PROMPTS_DIR"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    echo "  $name"
  done
  echo
  echo "Examples:"
  echo "  benchmark.sh 'Write a function to validate emails'"
  echo "  benchmark.sh --model=claude-4.6-sonnet-medium-thinking --trials=5 csv-parser"
  echo "  benchmark.sh --list"
  exit 0
}

if [ "${1:-}" = "--list" ]; then
  echo "Available benchmark prompts (${PROMPT_COUNT}):"
  for f in "$PROMPTS_DIR"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    first_line=$(head -1 "$f" 2>/dev/null)
    echo "  ${name}: ${first_line:0:70}"
  done
  exit 0
fi

if [ "${1:-}" = "--all" ]; then
  echo "Preparing all ${PROMPT_COUNT} benchmark prompts..."
  echo
  for f in "$PROMPTS_DIR"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    echo "  Generating: $name"
    bash "$0" "$f" >/dev/null 2>&1
  done
  echo
  echo "[OK] All ${PROMPT_COUNT} prompt pairs generated in ${RESULTS_DIR}/"
  echo "Launch from Cursor to execute subagents."
  exit 0
fi

[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && usage

# Resolve prompt
if [ $# -eq 0 ]; then
  DEFAULT_PROMPT="${PROMPTS_DIR}/csv-parser.md"
  if [ -f "$DEFAULT_PROMPT" ]; then
    PROMPT=$(cat "$DEFAULT_PROMPT")
  else
    PROMPT="Write a Python function that validates email addresses using regex and returns a list of valid ones from a given input list."
  fi
elif [ -f "$1" ]; then
  PROMPT=$(cat "$1")
else
  PROMPT="$1"
fi

# Read rules
if [ ! -f "$RULES_FILE" ]; then
  echo "[FAIL] Missing rules file: $RULES_FILE"
  exit 1
fi
RULES=$(cat "$RULES_FILE")

echo "╔══════════════════════════════════════╗"
echo "║      save-token benchmark            ║"
echo "╚══════════════════════════════════════╝"
echo
echo "Prompt: ${PROMPT:0:80}..."
echo "Trials: $TRIALS per arm (${TRIALS}×2 = $((TRIALS * 2)) total subagents)"
[ -n "$MODEL" ] && echo "Model:  $MODEL"
echo "Output: $OUTFILE"
echo

METRICS_SUFFIX='

After completing, output this EXACT block (fill in numbers):
```
METRICS:
tool_calls: <total tool calls you made>
code_lines: <lines of code in your solution>
explanation_lines: <lines of non-code explanation>
files_read: <files you read>
```

IMPORTANT: Write your solution code ONLY, no explanations. Put the code in a fenced code block marked ```python so it can be extracted for automated quality testing.'

# Check for matching quality benchmark
QUALITY_BENCH=""
if [ -f "$1" ]; then
  BENCH_NAME=$(basename "$1" .md)
  if [ -f "${REPO_DIR}/benchmarks/quality/${BENCH_NAME}.json" ]; then
    QUALITY_BENCH="${BENCH_NAME}"
    echo "Quality benchmark: $QUALITY_BENCH (correctness + quality checks)"
    echo
  fi
fi

# Generate subagent prompts
cat > "${RESULTS_DIR}/.baseline-prompt.txt" << BEOF
${PROMPT}
${METRICS_SUFFIX}
BEOF

cat > "${RESULTS_DIR}/.optimized-prompt.txt" << OEOF
IMPORTANT: Follow these rules for EVERY response:

${RULES}

---

${PROMPT}
${METRICS_SUFFIX}
OEOF

if [ "$OUTPUT_FMT" = "json" ]; then
  python3 -c "
import json
data = {
    'timestamp': '$TIMESTAMP',
    'trials': $TRIALS,
    'model': '${MODEL:-default}',
    'prompt_preview': '''${PROMPT:0:100}''',
    'baseline_prompt': '${RESULTS_DIR}/.baseline-prompt.txt',
    'optimized_prompt': '${RESULTS_DIR}/.optimized-prompt.txt'
}
with open('$OUTFILE', 'w') as f:
    json.dump(data, f, indent=2)
print(f'[OK] Config written to $OUTFILE')
" 2>/dev/null
else
  echo "Subagent prompts written to ${RESULTS_DIR}/"
  echo
  echo "To run the benchmark in Cursor:"
  echo "  1. Open a new agent chat"
  echo "  2. Say: /save-token bench <your prompt>"
  if [ -n "$MODEL" ]; then
    echo "  3. Subagents will use model: $MODEL"
  else
    echo "  3. The SKILL.md will spawn subagents automatically"
  fi
  echo
  echo "Or manually launch subagents with these prompts:"
  echo "  Baseline: ${RESULTS_DIR}/.baseline-prompt.txt"
  echo "  Optimized: ${RESULTS_DIR}/.optimized-prompt.txt"
  echo
  echo "[OK] Benchmark prepared. Launch from Cursor to execute."
fi
