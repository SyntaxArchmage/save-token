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

# --- Syntax ---

for script in "$SCRIPT_DIR"/*.sh; do
  check "bash syntax: $(basename "$script")" bash -n "$script"
done
for pyfile in "$SCRIPT_DIR"/*.py; do
  [ -f "$pyfile" ] || continue
  check "python syntax: $(basename "$pyfile")" python3 -c "import ast; ast.parse(open('$pyfile').read())"
done

# --- Core files ---

check "SKILL.md exists" test -f "$REPO_DIR/SKILL.md"
check "SKILL.md has frontmatter" grep -q "^---" "$REPO_DIR/SKILL.md"
check "SKILL.md under 500 lines" test "$(wc -l < "$REPO_DIR/SKILL.md")" -lt 500
check "agent-rules.md exists" test -f "$REPO_DIR/rules/agent-rules.md"
check "save-token.mdc exists" test -f "$REPO_DIR/rules/save-token.mdc"
check "save-token.mdc under 200 words" test "$(wc -w < "$REPO_DIR/rules/save-token.mdc")" -lt 200

# --- Script functionality ---

check "mode.sh get" bash "$SCRIPT_DIR/mode.sh" get
check "mode.sh set" bash "$SCRIPT_DIR/mode.sh" set full
check "mode.sh describe" bash "$SCRIPT_DIR/mode.sh" describe
check "stats.sh runs" bash "$SCRIPT_DIR/stats.sh"
check "review.sh runs" bash "$SCRIPT_DIR/review.sh"
check "learn.sh runs" bash "$SCRIPT_DIR/learn.sh"
check "cost.sh runs (opus)" bash "$SCRIPT_DIR/cost.sh" opus
check "cost.sh runs (sonnet)" bash "$SCRIPT_DIR/cost.sh" sonnet
check "analyzer importable" python3 -c "import sys; sys.path.insert(0,'$SCRIPT_DIR'); from analyze_transcript import analyze"
check "analyzer --help" python3 "$SCRIPT_DIR/analyze_transcript.py" --help

# --- Benchmarks ---

PROMPT_COUNT=$(find "$REPO_DIR/benchmarks/prompts" -name "*.md" | wc -l)
check "benchmark prompts >= 5" test "$PROMPT_COUNT" -ge 5
check "benchmark prompts >= 8" test "$PROMPT_COUNT" -ge 8
check "benchmark prompts >= 20" test "$PROMPT_COUNT" -ge 20

# --- Hooks ---

check "session hook exists" test -f "$REPO_DIR/hooks/session-start.sh"
check "session hook executable" test -x "$REPO_DIR/hooks/session-start.sh"
check "hooks.json example exists" test -f "$REPO_DIR/hooks/hooks.json.example"
check "session hook valid json" bash -c "bash '$REPO_DIR/hooks/session-start.sh' | python3 -c 'import json,sys; json.load(sys.stdin)'"

# --- Adapters (all platforms) ---

check "AGENTS.md exists" test -f "$REPO_DIR/adapters/AGENTS.md"
check "AGENTS.md has rules" grep -q "stop at first rung\|code ladder" "$REPO_DIR/adapters/AGENTS.md"
check "Windsurf adapter exists" test -f "$REPO_DIR/adapters/windsurfrules"
check "Windsurf has rules" grep -qi "save-token" "$REPO_DIR/adapters/windsurfrules"
check "Copilot adapter exists" test -f "$REPO_DIR/adapters/copilot-instructions.md"
check "Copilot has rules" grep -qi "save-token" "$REPO_DIR/adapters/copilot-instructions.md"
check "CodeBuddy rule exists" test -f "$REPO_DIR/adapters/codebuddy-rule.md"
check "CodeBuddy rule frontmatter" grep -q "alwaysApply:" "$REPO_DIR/adapters/codebuddy-rule.md"
check "CodeBuddy rule has rules" grep -qi "save-token" "$REPO_DIR/adapters/codebuddy-rule.md"
check "CODEBUDDY.md exists" test -f "$REPO_DIR/adapters/CODEBUDDY.md"
check "CODEBUDDY.md has rules" grep -qi "save-token" "$REPO_DIR/adapters/CODEBUDDY.md"
check "system-prompt.txt exists" test -f "$REPO_DIR/adapters/system-prompt.txt"
check "system-prompt has rules" grep -qi "YAGNI" "$REPO_DIR/adapters/system-prompt.txt"
check "pre-prompt.sh exists" test -f "$REPO_DIR/adapters/pre-prompt.sh"
check "pre-prompt.sh executable" test -x "$REPO_DIR/adapters/pre-prompt.sh"
check "pre-prompt.sh pipes" bash -c 'echo "test" | bash "'"$REPO_DIR"'/adapters/pre-prompt.sh" | grep -q "YAGNI\|Code Ladder"'
check "standalone.mdc exists" test -f "$REPO_DIR/adapters/standalone.mdc"

# --- Installer ---

check "install.sh runs" bash "$REPO_DIR/install.sh"
check "install.sh uninstall" bash "$REPO_DIR/install.sh" uninstall
check "install.sh reinstall" bash "$REPO_DIR/install.sh"
check "install.sh --version" bash "$REPO_DIR/install.sh" --version
check "install.sh status" bash "$REPO_DIR/install.sh" status
check "install.sh --help" bash "$REPO_DIR/install.sh" --help
check "install.sh --platform=generic" bash "$REPO_DIR/install.sh" light --platform=generic

# --- Compression pipeline (P1) ---

check "compress.sh syntax" bash -n "$SCRIPT_DIR/compress.sh"
check "compress.sh --help" bash "$SCRIPT_DIR/compress.sh" --help
check "compress.sh --list" bash "$SCRIPT_DIR/compress.sh" --list
check "engine: none.sh" bash -n "$SCRIPT_DIR/engines/none.sh"
check "engine: truncate.sh" bash -n "$SCRIPT_DIR/engines/truncate.sh"
check "engine: pointer.sh" bash -n "$SCRIPT_DIR/engines/pointer.sh"
check "engine: treesitter.sh" bash -n "$SCRIPT_DIR/engines/treesitter.sh"
check "engine: llmlingua.sh" bash -n "$SCRIPT_DIR/engines/llmlingua.sh"
check "engine: claw.sh" bash -n "$SCRIPT_DIR/engines/claw.sh"
check "engine: headroom.sh" bash -n "$SCRIPT_DIR/engines/headroom.sh"
check "compress none passthrough" bash -c 'echo "hello" | bash "'"$SCRIPT_DIR"'/compress.sh" --engine=none | grep -q "hello"'
check "compress truncate works" bash -c 'seq 1 100 | bash "'"$SCRIPT_DIR"'/compress.sh" --engine=truncate | grep -q "omitted"'
check "compress pointer works" bash -c 'seq 1 50 | bash "'"$SCRIPT_DIR"'/compress.sh" --engine=pointer | grep -q "Pointer"'
check "compress type detection" bash -c 'bash "'"$SCRIPT_DIR"'/compress.sh" --type=code --engine=none < "'"$SCRIPT_DIR"'/compress.sh" | wc -l | grep -q "[0-9]"'

# --- Density variants (P4) ---

check "kernel variant exists" test -f "$REPO_DIR/rules/agent-rules-kernel.md"
check "mid variant exists" test -f "$REPO_DIR/rules/agent-rules-mid.md"
check "kernel < mid words" bash -c '[ "$(wc -w < "'"$REPO_DIR"'/rules/agent-rules-kernel.md")" -lt "$(wc -w < "'"$REPO_DIR"'/rules/agent-rules-mid.md")" ]'
check "mid < full words" bash -c '[ "$(wc -w < "'"$REPO_DIR"'/rules/agent-rules-mid.md")" -lt "$(wc -w < "'"$REPO_DIR"'/rules/agent-rules.md")" ]'
check "kernel has code ladder" grep -q "Code" "$REPO_DIR/rules/agent-rules-kernel.md"
check "kernel has never cut" grep -q "Never cut" "$REPO_DIR/rules/agent-rules-kernel.md"
check "density analysis doc" test -f "$REPO_DIR/benchmarks/results/p4-density-analysis.md"
check "install --density validation" bash -c 'bash "'"$REPO_DIR"'/install.sh" light --platform=generic --density=invalid 2>&1 | grep -q "Invalid density"'
check "verbosity profile runs" bash -c 'bash "'"$SCRIPT_DIR"'/learn.sh" --verbosity-profile 2>&1 | grep -q "Sessions analyzed"'

# --- Token tracking (P6) ---

check "tokens.sh syntax" bash -n "$SCRIPT_DIR/tokens.sh"
check "tokens.sh --help" bash "$SCRIPT_DIR/tokens.sh" --help
check "tokens.sh detect" bash -c 'bash "'"$SCRIPT_DIR"'/tokens.sh" detect 2>&1 | grep -q "token source"'
check "tokens.sh log" bash -c 'bash "'"$SCRIPT_DIR"'/tokens.sh" log 1000 500 test 2>&1 | grep -q "Logged"'
check "tokens.sh summary" bash -c 'bash "'"$SCRIPT_DIR"'/tokens.sh" summary 2>&1 | grep -q "token"'
check "tokens.sh export csv" bash -c 'bash "'"$SCRIPT_DIR"'/tokens.sh" export --format=csv 2>&1 | grep -q "timestamp"'
check "tokens.sh export json" bash -c 'bash "'"$SCRIPT_DIR"'/tokens.sh" export --format=json 2>&1 | grep -q "input_tokens"'
check "tokens.sh reset" bash -c 'bash "'"$SCRIPT_DIR"'/tokens.sh" reset 2>&1 | grep -q "cleared"'
check "cost.sh with estimation fallback" bash -c 'bash "'"$SCRIPT_DIR"'/cost.sh" sonnet 2>&1 | grep -q "estimation"'

# --- Documentation ---

check "README.md exists" test -f "$REPO_DIR/README.md"
check "CHEATSHEET.md exists" test -f "$REPO_DIR/CHEATSHEET.md"
check "CHANGELOG.md exists" test -f "$REPO_DIR/CHANGELOG.md"
check "CONTRIBUTING.md exists" test -f "$REPO_DIR/CONTRIBUTING.md"
check "ROADMAP.md exists" test -f "$REPO_DIR/ROADMAP.md"
check "LICENSE exists" test -f "$REPO_DIR/LICENSE"
check ".gitignore exists" test -f "$REPO_DIR/.gitignore"
check "examples dir exists" test -d "$REPO_DIR/examples"
check "before-after examples" test -f "$REPO_DIR/examples/before-after.md"
check "cursorignore template" test -f "$REPO_DIR/templates/cursorignore"

echo
echo "Results: $pass passed, $fail failed, $((pass + fail)) total"
[ "$fail" -eq 0 ] && echo "[OK] All tests passed." || { echo "[FAIL] $fail test(s) failed."; exit 1; }
