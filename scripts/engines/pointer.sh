#!/usr/bin/env bash
# Pointer engine: summarize large output to a compact pointer reference.
# Keeps first 3 + last 3 lines as preview, adds size metadata.

HEAD_N="${POINTER_HEAD:-3}"
TAIL_N="${POINTER_TAIL:-3}"
THRESHOLD=$((HEAD_N + TAIL_N + 10))

input=$(cat)
total=$(echo "$input" | wc -l)
bytes=${#input}

if [ "$total" -le "$THRESHOLD" ]; then
  echo "$input"
else
  echo "[Pointer] ${total} lines, ${bytes} bytes"
  echo "  Preview (first ${HEAD_N}):"
  echo "$input" | head -n "$HEAD_N" | sed 's/^/    /'
  echo "  ..."
  echo "  Preview (last ${TAIL_N}):"
  echo "$input" | tail -n "$TAIL_N" | sed 's/^/    /'
  echo "  (Full content available via re-read with offset+limit)"
fi
