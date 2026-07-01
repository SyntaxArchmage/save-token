#!/usr/bin/env bash
# Treesitter engine: strip comments and collapse whitespace from code.
# Falls back to regex-based stripping if tree-sitter-cli is not installed.

input=$(cat)

if command -v tree-sitter &>/dev/null; then
  echo "$input" | tree-sitter highlight --quiet 2>/dev/null || echo "$input"
else
  echo "$input" \
    | sed '/^[[:space:]]*#.*$/d' \
    | sed '/^[[:space:]]*\/\/.*$/d' \
    | sed '/^[[:space:]]*\*.*$/d' \
    | sed '/^[[:space:]]*\/\*.*\*\/$/d' \
    | sed '/^[[:space:]]*$/d' \
    | cat -s
fi
