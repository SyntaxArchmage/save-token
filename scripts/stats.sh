#!/usr/bin/env bash
set -euo pipefail

PROXY_PORT="${SAVE_TOKEN_PORT:-8787}"
CONFIG_DIR="${HOME}/.save-token"
LEARNINGS="${CONFIG_DIR}/learnings.md"

echo "╔══════════════════════════════════════╗"
echo "║         save-token stats             ║"
echo "╚══════════════════════════════════════╝"
echo

# Mode
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE=$(bash "$SCRIPT_DIR/mode.sh" get)
echo "Mode: $MODE"

# Headroom status
if lsof -i ":$PROXY_PORT" &>/dev/null; then
  echo "Headroom: running (port $PROXY_PORT)"
  if command -v headroom &>/dev/null; then
    echo
    headroom perf 2>/dev/null || echo "  (run 'headroom perf' for compression stats)"
  fi
else
  echo "Headroom: not running"
  echo "  Run '/save-token setup' to enable system-level compression"
fi

# Learnings
echo
if [ -f "$LEARNINGS" ]; then
  PATTERN_COUNT=$(grep -c "^-" "$LEARNINGS" 2>/dev/null || echo "0")
  LAST_MOD=$(stat -c %Y "$LEARNINGS" 2>/dev/null | xargs -I{} date -d @{} +%Y-%m-%d 2>/dev/null || echo "unknown")
  echo "Waste patterns found: $PATTERN_COUNT"
  echo "Last learn: $LAST_MOD"
else
  echo "Waste patterns: none yet"
  echo "  Run '/save-token learn' to analyze past sessions"
fi

# Context budget estimate
REPO_DIR="$(dirname "$SCRIPT_DIR")"
RULES_WORDS=$(wc -w < "$REPO_DIR/rules/agent-rules.md" 2>/dev/null || echo 0)
MDC_WORDS=$(wc -w < "$REPO_DIR/rules/save-token.mdc" 2>/dev/null || echo 0)
SKILL_WORDS=$(wc -w < "$REPO_DIR/SKILL.md" 2>/dev/null || echo 0)
TOTAL_WORDS=$((RULES_WORDS + MDC_WORDS + SKILL_WORDS))
TOTAL_TOKENS=$((TOTAL_WORDS * 4 / 3))
echo
echo "Context cost: ~${TOTAL_TOKENS} tokens/request"
echo "  agent-rules.md: ${RULES_WORDS}w  save-token.mdc: ${MDC_WORDS}w  SKILL.md: ${SKILL_WORDS}w"

# Quick cost summary
case "$MODE" in
  ultra) EXPL_SAVE=93 ;;
  full)  EXPL_SAVE=76 ;;
  lite)  EXPL_SAVE=50 ;;
  *)     EXPL_SAVE=0 ;;
esac
if [ "$EXPL_SAVE" -gt 0 ]; then
  OPUS_MONTHLY=$(python3 -c "print(f'\${2000 * $EXPL_SAVE / 100 * 75 / 1000000 * 100 * 22:.0f}')" 2>/dev/null || echo "?")
  echo
  echo "Est. savings ($MODE, Opus, 100 req/day): ~${OPUS_MONTHLY}/month"
  echo "  Run '/save-token cost [model]' for detailed breakdown"
fi

# Mode history
HISTORY=$(bash "$SCRIPT_DIR/mode.sh" history 2>/dev/null)
if [ "$HISTORY" != "(no history)" ] && [ -n "$HISTORY" ]; then
  echo
  echo "Recent mode changes:"
  echo "$HISTORY" | tail -5 | while IFS= read -r line; do
    echo "  $line"
  done
fi
