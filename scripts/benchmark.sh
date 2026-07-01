#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="${REPO_DIR}/benchmarks/results"
PROMPTS_DIR="${REPO_DIR}/benchmarks/prompts"
RULES_FILE="${REPO_DIR}/rules/agent-rules.md"
TRIALS="${SAVE_TOKEN_TRIALS:-3}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUTFILE="${RESULTS_DIR}/bench-${TIMESTAMP}.json"

mkdir -p "$RESULTS_DIR"

PROMPT_COUNT=$(find "$PROMPTS_DIR" -name "*.md" 2>/dev/null | wc -l)

usage() {
  echo "Usage: benchmark.sh [prompt_file|prompt_string]"
  echo
  echo "Runs A/B comparison: baseline vs optimized (with agent-rules)."
  echo "Default: ${TRIALS} trials per arm (set SAVE_TOKEN_TRIALS to change)."
  echo "Available presets: ${PROMPT_COUNT} prompts in benchmarks/prompts/"
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
  echo "  benchmark.sh benchmarks/prompts/csv-parser.md"
  echo "  benchmark.sh --list    # list preset prompts"
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
```'

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

echo "Subagent prompts written to ${RESULTS_DIR}/"
echo
echo "To run the benchmark in Cursor:"
echo "  1. Open a new agent chat"
echo "  2. Say: /save-token bench <your prompt>"
echo "  3. The SKILL.md will spawn subagents automatically"
echo
echo "Or manually launch subagents with these prompts:"
echo "  Baseline: ${RESULTS_DIR}/.baseline-prompt.txt"
echo "  Optimized: ${RESULTS_DIR}/.optimized-prompt.txt"
echo
echo "[OK] Benchmark prepared. Launch from Cursor to execute."
