#!/usr/bin/env bash
# Truncate engine: keep first HEAD_N + last TAIL_N lines, omit middle.
# For short inputs (≤ threshold), pass through unchanged.

HEAD_N="${COMPRESS_HEAD:-10}"
TAIL_N="${COMPRESS_TAIL:-10}"
THRESHOLD=$((HEAD_N + TAIL_N + 5))

input=$(cat)
total=$(echo "$input" | wc -l)

if [ "$total" -le "$THRESHOLD" ]; then
  echo "$input"
else
  omitted=$((total - HEAD_N - TAIL_N))
  echo "$input" | head -n "$HEAD_N"
  echo "... ($omitted lines omitted) ..."
  echo "$input" | tail -n "$TAIL_N"
fi
