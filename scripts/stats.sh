#!/usr/bin/env bash
set -euo pipefail

PROXY_PORT="${SAVE_TOKEN_PORT:-8787}"
CONFIG_DIR="${HOME}/.save-token"
LEARNINGS="${CONFIG_DIR}/learnings.md"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# --- Project health dashboard (v2.0 C1) ---
if [ "${1:-}" = "health" ] || [ "${1:-}" = "--health" ]; then
  echo "╔══════════════════════════════════════╗"
  echo "║      save-token health               ║"
  echo "╚══════════════════════════════════════╝"
  echo
  VERSION=$(grep -m1 '^VERSION=' "$REPO_DIR/install.sh" 2>/dev/null | cut -d'"' -f2 || echo "?")
  echo "Version:      v${VERSION}"

  # Test pass rate (parse test.sh summary without full noise).
  # Guard against recursion: test.sh calls stats.sh health, which would re-run test.sh.
  if [ "${SAVE_TOKEN_SKIP_TESTRUN:-}" = "1" ]; then
    echo "Tests:        (skipped in nested run)"
  else
    TEST_LINE=$(bash "$SCRIPT_DIR/test.sh" 2>/dev/null | grep -E "^Results:" || echo "Results: unknown")
    echo "Tests:        ${TEST_LINE#Results: }"
  fi

  # Adapter count
  ADAPTER_COUNT=$(find "$REPO_DIR/adapters" -type f \( -name "*.md" -o -name "*.mdc" -o -name "*.txt" -o -name "*rules*" \) 2>/dev/null | wc -l | tr -d ' ')
  echo "Adapters:     ${ADAPTER_COUNT} files"

  # Engine availability
  eng="truncate pointer none"
  python3 -c "import headroom" 2>/dev/null && eng="headroom $eng"
  python3 -c "from llmlingua import PromptCompressor" 2>/dev/null && eng="llmlingua $eng"
  echo "Engines:      ${eng} (+treesitter regex fallback)"

  # Headline stats source-of-truth
  HEADLINE="$REPO_DIR/benchmarks/results/HEADLINE.json"
  if [ -f "$HEADLINE" ]; then
    TRIALS=$(python3 -c "import json; print(json.load(open('$HEADLINE'))['trials']['total'])" 2>/dev/null || echo "?")
    echo "A/B trials:   ${TRIALS} (source: benchmarks/results/HEADLINE.json)"
  fi
  exit 0
fi

echo "╔══════════════════════════════════════╗"
echo "║         save-token stats             ║"
echo "╚══════════════════════════════════════╝"
echo

# Install status
SKILL_DIR="${HOME}/.cursor/skills/save-token"
VERSION=$(grep -m1 '^VERSION=' "$REPO_DIR/install.sh" 2>/dev/null | cut -d'"' -f2 || echo "?")
if [ -L "$SKILL_DIR" ]; then
  echo "Installed: v${VERSION} ($SKILL_DIR)"
else
  echo "Not installed (run: bash install.sh)"
fi

# Mode
MODE=$(bash "$SCRIPT_DIR/mode.sh" get)
echo "Mode: $MODE — $(bash "$SCRIPT_DIR/mode.sh" describe 2>/dev/null | cut -d: -f2 || echo "")"

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
  full)  EXPL_SAVE=75 ;;
  lite)  EXPL_SAVE=33 ;;
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
