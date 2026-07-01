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

# Savings percentages from 216-trial benchmark
case "$MODE" in
  ultra) CODE_PCT=51; EXPL_PCT=93; TOOL_PCT=39 ;;
  full)  CODE_PCT=24; EXPL_PCT=75; TOOL_PCT=34 ;;
  lite)  CODE_PCT=16; EXPL_PCT=33; TOOL_PCT=20 ;;
  off)   CODE_PCT=0;  EXPL_PCT=0;  TOOL_PCT=0 ;;
esac

echo "╔══════════════════════════════════════╗"
echo "║     save-token cost estimator        ║"
echo "╚══════════════════════════════════════╝"
echo
echo "Model: $NAME"
echo "Mode:  $MODE"
echo
echo "Expected savings per request (from 216-trial benchmark):"
echo "  Code output:       -${CODE_PCT}%"
echo "  Explanation output: -${EXPL_PCT}%"
echo "  Tool calls:        -${TOOL_PCT}%"
echo
echo "Cost per 1M tokens:"
echo "  Input:  \$${INPUT}"
echo "  Output: \$${OUTPUT}"
echo

CONFIG_DIR="${SAVE_TOKEN_DIR:-${HOME}/.save-token}"
TOKENS_LOG="${CONFIG_DIR}/tokens.log"

# Try real data first, fall back to estimation
if [ -f "$TOKENS_LOG" ] && [ -s "$TOKENS_LOG" ]; then
  echo "Data source: real token log ($TOKENS_LOG)"
  echo
  python3 -c "
total_in, total_out, count = 0, 0, 0
for line in open('$TOKENS_LOG'):
    parts = line.strip().split(',')
    if len(parts) < 4: continue
    try:
        total_in += int(parts[2]); total_out += int(parts[3]); count += 1
    except: continue

if count == 0:
    print('  No valid entries.'); exit()

avg_out = total_out // count
saved_pct = $EXPL_PCT / 100
saved_out = int(avg_out * saved_pct)

input_cost = $INPUT
output_cost = $OUTPUT

cost_before = (total_in * input_cost + total_out * output_cost) / 1_000_000
cost_saved = (total_out * saved_pct * output_cost) / 1_000_000
cost_after = cost_before - cost_saved

print(f'  Tracked requests:     {count}')
print(f'  Total input tokens:   {total_in:,}')
print(f'  Total output tokens:  {total_out:,}')
print(f'  Avg output/request:   {avg_out:,}')
print()
print(f'  Cost without save-token:  \${cost_before:.2f}')
print(f'  Estimated savings:        \${cost_saved:.2f} (-{saved_pct:.0%} output)')
print(f'  Cost with save-token:     \${cost_after:.2f}')

if count > 0:
    daily = max(count, 1)
    monthly_factor = 22 * (100 / max(daily, 1))
    monthly_saved = cost_saved * monthly_factor / count
    print(f'  Projected monthly:        \${monthly_saved:.2f} savings (at 100 req/day)')
" 2>/dev/null
else
  echo "Data source: estimation (216-trial A/B benchmark)"
  echo
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
  echo
  echo "[TIP] Track real tokens: bash scripts/tokens.sh log INPUT OUTPUT"
fi
