#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME}/.save-token"
MODE_FILE="${CONFIG_DIR}/mode"
HISTORY_FILE="${CONFIG_DIR}/mode-history.log"
mkdir -p "$CONFIG_DIR"

usage() {
  echo "Usage: mode.sh [get|set <mode>|history]"
  echo "  get       Print current mode (default: full)"
  echo "  set MODE  Set mode to lite|full|ultra|off"
  echo "  history   Show mode change history"
  exit 0
}

cmd="${1:-get}"

case "$cmd" in
  get)
    if [ -f "$MODE_FILE" ]; then
      cat "$MODE_FILE"
    else
      echo "full"
    fi
    ;;
  set)
    mode="${2:-}"
    case "$mode" in
      lite|full|ultra|off)
        echo "$mode" > "$MODE_FILE"
        echo "$(date -Iseconds) $mode" >> "$HISTORY_FILE"
        echo "$mode"
        ;;
      *)
        echo "[FAIL] Invalid mode: $mode. Use lite|full|ultra|off" >&2
        exit 1
        ;;
    esac
    ;;
  history)
    if [ -f "$HISTORY_FILE" ]; then
      tail -20 "$HISTORY_FILE"
    else
      echo "(no history)"
    fi
    ;;
  -h|--help) usage ;;
  *) usage ;;
esac
