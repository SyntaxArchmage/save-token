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
