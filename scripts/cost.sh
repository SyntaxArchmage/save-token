#!/usr/bin/env bash
set -euo pipefail

# Estimate token cost savings for a given model and session.
# Usage: cost.sh [model] [tokens_saved]
#   model: opus|sonnet|haiku|gpt4o|o3  (default: opus)
#   tokens_saved: estimated tokens saved (default: from stats.sh context budget)

MODEL="${1:-opus}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Pricing per 1M tokens (USD, approximate mid-2026)
case "$MODEL" in
  opus)   INPUT=15.00; OUTPUT=75.00; NAME="Claude Opus" ;;
  sonnet) INPUT=3.00;  OUTPUT=15.00; NAME="Claude Sonnet" ;;
  haiku)  INPUT=0.25;  OUTPUT=1.25;  NAME="Claude Haiku" ;;
  gpt4o)  INPUT=2.50;  OUTPUT=10.00; NAME="GPT-4o" ;;
  o3)     INPUT=10.00; OUTPUT=40.00; NAME="o3" ;;
  *)      echo "Unknown model: $MODEL. Use opus|sonnet|haiku|gpt4o|o3"; exit 1 ;;
esac

MODE=$(bash "$SCRIPT_DIR/mode.sh" get)

# Savings percentages from 106-trial benchmark
case "$MODE" in
  ultra) CODE_PCT=60; EXPL_PCT=93; TOOL_PCT=31 ;;
  full)  CODE_PCT=18; EXPL_PCT=76; TOOL_PCT=40 ;;
  lite)  CODE_PCT=10; EXPL_PCT=50; TOOL_PCT=20 ;;
  off)   CODE_PCT=0;  EXPL_PCT=0;  TOOL_PCT=0 ;;
esac

echo "╔══════════════════════════════════════╗"
echo "║     save-token cost estimator        ║"
echo "╚══════════════════════════════════════╝"
echo
echo "Model: $NAME"
echo "Mode:  $MODE"
echo
echo "Expected savings per request (from 106-trial benchmark):"
echo "  Code output:       -${CODE_PCT}%"
echo "  Explanation output: -${EXPL_PCT}%"
echo "  Tool calls:        -${TOOL_PCT}%"
echo
echo "Cost per 1M tokens:"
echo "  Input:  \$${INPUT}"
echo "  Output: \$${OUTPUT}"
echo

# Estimate: average agent request = ~2000 output tokens
# With full mode: save ~760 output tokens (38% of output via explanation reduction)
AVG_OUTPUT=2000
SAVED_OUTPUT=$((AVG_OUTPUT * EXPL_PCT / 100))
COST_SAVED=$(python3 -c "print(f'\${${SAVED_OUTPUT} * ${OUTPUT} / 1000000:.4f}')")

echo "Estimated savings per request: ~${SAVED_OUTPUT} output tokens (~${COST_SAVED})"
echo
DAILY_REQUESTS=100
DAILY_SAVED=$(python3 -c "print(f'\${${SAVED_OUTPUT} * ${OUTPUT} * ${DAILY_REQUESTS} / 1000000:.2f}')")
MONTHLY_SAVED=$(python3 -c "print(f'\${${SAVED_OUTPUT} * ${OUTPUT} * ${DAILY_REQUESTS} * 22 / 1000000:.2f}')")
echo "At ${DAILY_REQUESTS} requests/day:"
echo "  Daily savings:   ${DAILY_SAVED}"
echo "  Monthly savings: ${MONTHLY_SAVED}"
