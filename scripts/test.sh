#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
pass=0
fail=0

check() {
  local label="$1"
  shift
  if "$@" &>/dev/null; then
    echo "[PASS] $label"
    pass=$((pass + 1))
  else
    echo "[FAIL] $label"
    fail=$((fail + 1))
  fi
}

echo "╔══════════════════════════════════════╗"
echo "║       save-token test suite          ║"
echo "╚══════════════════════════════════════╝"
echo

# Bash syntax checks
for script in "$SCRIPT_DIR"/*.sh; do
  name=$(basename "$script")
  check "bash syntax: $name" bash -n "$script"
done

# Python syntax checks
for pyfile in "$SCRIPT_DIR"/*.py; do
  [ -f "$pyfile" ] || continue
  name=$(basename "$pyfile")
  check "python syntax: $name" python3 -c "import ast; ast.parse(open('$pyfile').read())"
done

# SKILL.md exists and has frontmatter
check "SKILL.md exists" test -f "$REPO_DIR/SKILL.md"
check "SKILL.md has frontmatter" grep -q "^---" "$REPO_DIR/SKILL.md"
check "SKILL.md under 500 lines" test "$(wc -l < "$REPO_DIR/SKILL.md")" -lt 500

# agent-rules.md exists
check "agent-rules.md exists" test -f "$REPO_DIR/rules/agent-rules.md"

# save-token.mdc exists and under 200 words
check "save-token.mdc exists" test -f "$REPO_DIR/rules/save-token.mdc"
check "save-token.mdc under 200 words" test "$(wc -w < "$REPO_DIR/rules/save-token.mdc")" -lt 200

# mode.sh functional test
check "mode.sh get" bash "$SCRIPT_DIR/mode.sh" get
check "mode.sh set" bash "$SCRIPT_DIR/mode.sh" set full

# stats.sh runs
check "stats.sh runs" bash "$SCRIPT_DIR/stats.sh"

# benchmark prompts exist
PROMPT_COUNT=$(find "$REPO_DIR/benchmarks/prompts" -name "*.md" | wc -l)
check "benchmark prompts exist (>= 5)" test "$PROMPT_COUNT" -ge 5

# README exists
check "README.md exists" test -f "$REPO_DIR/README.md"

# .gitignore exists
check ".gitignore exists" test -f "$REPO_DIR/.gitignore"

echo
echo "Results: $pass passed, $fail failed, $((pass + fail)) total"
[ "$fail" -eq 0 ] && echo "[OK] All tests passed." || { echo "[FAIL] $fail test(s) failed."; exit 1; }
