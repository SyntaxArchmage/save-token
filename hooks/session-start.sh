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

cat <<HOOK_EOF
{
  "additional_context": "save-token is active (${MODE} mode). Follow the rules in ~/.cursor/skills/save-token/rules/agent-rules.md for every response. Key rules: code ladder (YAGNI first), batch tool calls, no preamble, no echo, code references for existing code, max 3 lines explanation."
}
HOOK_EOF
