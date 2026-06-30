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

usage() {
  echo "Usage: benchmark.sh [prompt_file|prompt_string]"
  echo
  echo "Runs A/B comparison: baseline vs optimized (with agent-rules)."
  echo "Default: ${TRIALS} trials per arm (set SAVE_TOKEN_TRIALS to change)."
  echo
  echo "Examples:"
  echo "  benchmark.sh 'Write a function to validate emails'"
  echo "  benchmark.sh benchmarks/prompts/csv-parser.md"
  exit 0
}

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
