#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME}/.save-token"
MODE_FILE="${CONFIG_DIR}/mode"
HISTORY_FILE="${CONFIG_DIR}/mode-history.log"
mkdir -p "$CONFIG_DIR"

usage() {
  echo "Usage: mode.sh [command]"
  echo
  echo "Commands:"
  echo "  get            Print current mode (default: full)"
  echo "  set <mode>     Set mode: lite | full | ultra | off"
  echo "  history        Show recent mode changes"
  echo "  describe       Explain what current mode does"
  echo
  echo "Modes:"
  echo "  lite   Advisory hints, minimal disruption (-16% code, -33% prose)"
  echo "  full   Balanced daily mode (default) (-24% code, -75% prose)"
  echo "  ultra  Maximum savings, terse output (-51% code, -93% prose)"
  echo "  off    Disable all save-token rules"
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
  describe)
    mode=$(bash "$0" get)
    case "$mode" in
      lite)  echo "$mode: advisory code ladder, up to 5 lines explanation, relaxed scope" ;;
      full)  echo "$mode: enforced code ladder, minimal prose, strict tool batching" ;;
      ultra) echo "$mode: single-expression preference, zero prose, challenge every request" ;;
      off)   echo "$mode: all save-token rules disabled" ;;
    esac
    ;;
  -h|--help) usage ;;
  *) usage ;;
esac
