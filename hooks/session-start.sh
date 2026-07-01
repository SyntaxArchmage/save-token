#!/usr/bin/env bash
# save-token session start hook
# Injects save-token mode reminder at session start.

MODE_FILE="${HOME}/.save-token/mode"
MODE="full"
[ -f "$MODE_FILE" ] && MODE=$(cat "$MODE_FILE")

if [ "$MODE" = "off" ]; then
  echo '{}'
  exit 0
fi

case "$MODE" in
  lite)  DESC="advisory code ladder, up to 5 lines explanation" ;;
  full)  DESC="enforced code ladder, minimal prose, strict tool batching" ;;
  ultra) DESC="zero prose, single-expression preference, challenge every request" ;;
  *)     DESC="all rules enforced" ;;
esac

cat <<HOOK_EOF
{
  "additional_context": "save-token is active (${MODE}: ${DESC}). Follow ~/.cursor/skills/save-token/rules/agent-rules.md every response. Key: code ladder (YAGNI first), batch tool calls, no preamble, code references, max 3 lines explanation."
}
HOOK_EOF
