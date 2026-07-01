#!/usr/bin/env bash
set -euo pipefail

# Prepend save-token rules to any prompt for CLI tools.
#
# Usage:
#   echo "your prompt" | bash pre-prompt.sh | claude-code
#   bash pre-prompt.sh < prompt.txt | codebuddy
#   bash pre-prompt.sh "inline prompt text" | any-llm-cli
#
# The script outputs: [save-token rules]\n---\n[your prompt]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_FILE="${SCRIPT_DIR}/../rules/agent-rules.md"

if [ ! -f "$RULES_FILE" ]; then
  RULES_FILE="${SCRIPT_DIR}/system-prompt.txt"
fi

if [ ! -f "$RULES_FILE" ]; then
  echo "[save-token] Error: No rules file found." >&2
  exit 1
fi

cat "$RULES_FILE"
echo ""
echo "---"
echo ""

if [ $# -gt 0 ]; then
  echo "$*"
else
  cat
fi
