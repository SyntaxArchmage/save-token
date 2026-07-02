#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENGINE_DIR="${SAVE_TOKEN_ENGINE_DIR:-$SCRIPT_DIR/engines}"
CONFIG_DIR="${SAVE_TOKEN_DIR:-${HOME}/.save-token}"
CONFIG_FILE="${SAVE_TOKEN_CONFIG:-$CONFIG_DIR/compress.conf}"

# Load config file if present (key=value format, lines starting with # ignored)
if [ -f "$CONFIG_FILE" ]; then
  while IFS='=' read -r key value; do
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [ -z "$key" ] && continue
    key=$(echo "$key" | tr -d '[:space:]')
    value=$(echo "$value" | tr -d '[:space:]')
    export "$key"="$value" 2>/dev/null || true
  done < "$CONFIG_FILE"
fi

usage() {
  cat <<'USAGE'
Usage: compress.sh [options] [FILE]

Content-type-aware compression pipeline. Reads from FILE or stdin.

Options:
  --type=TYPE       Content type (auto-detected from file extension if omitted):
                    code|text|json|logs|diff|html|search|tool_output|history|metadata
  --engine=ENGINE   Compression engine (see below). Default: auto (best for type).
  --install=ENGINE  Install an engine's dependencies and exit.
  --list            List available engines and their status.
  --stats           Show compression ratio after processing.
  -h, --help        Show this help.

Engines:
  none         Passthrough (no compression)
  truncate     Keep first N + last N lines of tool output (built-in)
  pointer      Summarize to pointer reference (built-in)
  headroom     Local ML compression via Headroom (auto-installed)
  treesitter   Strip comments + whitespace from code (regex fallback built-in)
  llmlingua    Perplexity-based pruning for NL (auto-installed, needs model download)
  claw         AST-aware code compression (not available: PyPI package is unrelated)

Auto engine selection by type:
  code         → headroom (or treesitter fallback)
  text         → headroom (or truncate/llmlingua fallback)
  json         → headroom (or truncate fallback)
  logs         → headroom (or truncate fallback)
  diff         → headroom (or truncate fallback)
  html         → headroom (or truncate fallback)
  search       → pointer (or headroom/SearchCompressor)
  tool_output  → pointer
  history      → truncate
  metadata     → none

Environment variables:
  COMPRESS_HEAD       Lines to keep from top (truncate engine, default: 10)
  COMPRESS_TAIL       Lines to keep from bottom (truncate engine, default: 10)
  POINTER_HEAD        Preview lines from top (pointer engine, default: 3)
  POINTER_TAIL        Preview lines from bottom (pointer engine, default: 3)
  SAVE_TOKEN_ENGINE_DIR  Custom engine directory
  SAVE_TOKEN_CONFIG   Config file path (default: ~/.save-token/compress.conf)

Config file (key=value, one per line):
  ~/.save-token/compress.conf

Examples:
  cat main.py | compress.sh --type=code
  compress.sh --type=tool_output < build.log
  COMPRESS_HEAD=20 compress.sh --engine=truncate app.log
  compress.sh --install=llmlingua
  compress.sh --list
USAGE
  exit 0
}

# --- Content type detection ---

detect_type() {
  local file="${1:-}"
  if [ -n "$file" ] && [ -f "$file" ]; then
    case "$file" in
      *.py|*.js|*.ts|*.tsx|*.jsx|*.rs|*.go|*.c|*.cpp|*.h|*.java|*.rb|*.sh|*.bash|*.swift|*.kt|*.scala|*.zig|*.lua|*.pl|*.pm|*.r|*.R|*.jl|*.ex|*.exs|*.erl|*.hs|*.ml|*.fs|*.v|*.sv|*.vhd|*.php|*.cs|*.dart)
        echo "code" ;;
      *.json|*.jsonl|*.ndjson)
        echo "json" ;;
      *.yaml|*.yml|*.toml|*.xml|*.csv|*.tsv|*.ini|*.cfg|*.conf|*.properties)
        echo "metadata" ;;
      *.log)
        echo "logs" ;;
      *.diff|*.patch)
        echo "diff" ;;
      *.html|*.htm|*.xhtml)
        echo "html" ;;
      *.md|*.txt|*.rst|*.adoc|*.tex)
        echo "text" ;;
      *)
        echo "text" ;;
    esac
  else
    # stdin — try content sniffing
    local head_line
    head_line=$(head -c 200 "$file" 2>/dev/null || echo "")
    case "$head_line" in
      '{"'*|'[{'*|'['*)      echo "json" ;;
      'diff --'*|'---'*a/**)  echo "diff" ;;
      '<html'*|'<!DOCTYPE'*|'<HTML'*)  echo "html" ;;
      *)                      echo "tool_output" ;;
    esac
  fi
}

# --- Engine selection ---

auto_engine() {
  local content_type="$1"
  local has_headroom=false
  python3 -c "import headroom" 2>/dev/null && has_headroom=true

  case "$content_type" in
    code)
      if [ "$has_headroom" = true ]; then echo "headroom"
      elif command -v tree-sitter &>/dev/null; then echo "treesitter"
      else echo "truncate"
      fi ;;
    text)
      if [ "$has_headroom" = true ]; then echo "headroom"
      elif python3 -c "import llmlingua" 2>/dev/null; then echo "llmlingua"
      else echo "truncate"
      fi ;;
    json)
      if [ "$has_headroom" = true ]; then echo "headroom"
      else echo "truncate"
      fi ;;
    logs)
      if [ "$has_headroom" = true ]; then echo "headroom"
      else echo "truncate"
      fi ;;
    diff)         echo "truncate" ;;
    html)
      if [ "$has_headroom" = true ]; then echo "headroom"
      else echo "truncate"
      fi ;;
    search)
      if [ "$has_headroom" = true ]; then echo "headroom"
      else echo "pointer"
      fi ;;
    tool_output)  echo "pointer" ;;
    history)      echo "truncate" ;;
    metadata)     echo "none" ;;
    *)            echo "none" ;;
  esac
}

# --- Engine installation ---

install_engine() {
  local engine="$1"
  case "$engine" in
    treesitter)
      echo "Installing tree-sitter-cli..."
      if command -v npm &>/dev/null; then
        npm install -g tree-sitter-cli
      elif command -v cargo &>/dev/null; then
        cargo install tree-sitter-cli
      else
        echo "[FAIL] Requires npm or cargo." >&2; exit 1
      fi
      ;;
    llmlingua)
      echo "Installing llmlingua..."
      pip install llmlingua
      ;;
    claw)
      echo "Installing claw-compactor..."
      pip install claw-compactor
      ;;
    headroom)
      echo "Installing headroom-ai..."
      pip install "headroom-ai[proxy]"
      ;;
    truncate|pointer|none)
      echo "[OK] $engine has no dependencies."
      ;;
    *)
      echo "[FAIL] Unknown engine: $engine" >&2; exit 1
      ;;
  esac
  echo "[OK] Engine '$engine' ready."
}

# --- List engines ---

list_engines() {
  printf "%-12s %-10s %s\n" "ENGINE" "STATUS" "DESCRIPTION"
  printf "%-12s %-10s %s\n" "--------" "------" "-----------"

  check_status() {
    local name="$1" cmd="$2"
    if eval "$cmd" &>/dev/null; then
      printf "%-12s %-10s" "$name" "[ready]"
    else
      printf "%-12s %-10s" "$name" "[missing]"
    fi
  }

  check_status "treesitter" "command -v tree-sitter"
  echo "Strip comments + whitespace from code"
  check_status "truncate" "true"
  echo "Keep first/last N lines (zero deps)"
  check_status "pointer" "true"
  echo "Summarize to pointer reference (zero deps)"
  check_status "llmlingua" "python3 -c 'import llmlingua'"
  echo "Perplexity-based NL pruning (Microsoft)"
  check_status "claw" "python3 -c 'import claw_compactor'"
  echo "AST-aware code compression (reversible)"
  check_status "headroom" "python3 -c 'import headroom'"
  echo "Full proxy compression (60-95%)"
  check_status "none" "true"
  echo "Passthrough (no compression)"
}

# --- Engine execution ---

run_engine() {
  local engine="$1" input_file="$2" show_stats="$3"
  local engine_script="$ENGINE_DIR/${engine}.sh"

  if [ -f "$engine_script" ]; then
    local before_size
    before_size=$(wc -c < "$input_file")

    local output
    output=$(bash "$engine_script" < "$input_file")
    echo "$output"

    if [ "$show_stats" = true ]; then
      local after_size=${#output}
      if [ "$before_size" -gt 0 ]; then
        local ratio
        ratio=$(python3 -c "print(f'{$after_size/$before_size:.1%}')" 2>/dev/null || echo "?")
        echo "[compress] $engine: ${before_size}B → ${after_size}B ($ratio)" >&2
      fi
    fi
  else
    echo "[FAIL] Engine script not found: $engine_script" >&2
    echo "[TIP] Run: compress.sh --install=$engine" >&2
    cat "$input_file"
  fi
}

# --- Parse arguments ---

TYPE=""
ENGINE=""
SHOW_STATS=false
INPUT_FILE=""

for arg in "$@"; do
  case "$arg" in
    --type=*)    TYPE="${arg#--type=}" ;;
    --engine=*)  ENGINE="${arg#--engine=}" ;;
    --install=*) install_engine "${arg#--install=}"; exit 0 ;;
    --list)      list_engines; exit 0 ;;
    --stats)     SHOW_STATS=true ;;
    -h|--help)   usage ;;
    -*)          echo "[FAIL] Unknown option: $arg" >&2; exit 1 ;;
    *)           INPUT_FILE="$arg" ;;
  esac
done

# Create temp file for stdin if no file argument
TMPFILE=""
if [ -z "$INPUT_FILE" ]; then
  TMPFILE=$(mktemp)
  cat > "$TMPFILE"
  INPUT_FILE="$TMPFILE"
  trap 'rm -f "$TMPFILE"' EXIT
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "[FAIL] File not found: $INPUT_FILE" >&2
  exit 1
fi

[ -z "$TYPE" ] && TYPE=$(detect_type "$INPUT_FILE")
[ -z "$ENGINE" ] && ENGINE=$(auto_engine "$TYPE")

# Fallback: if configured engine isn't installed, use zero-dep default
fallback_engine() {
  local content_type="$1"
  case "$content_type" in
    code)        echo "truncate" ;;
    text)        echo "truncate" ;;
    json)        echo "truncate" ;;
    logs)        echo "truncate" ;;
    diff)        echo "truncate" ;;
    html)        echo "truncate" ;;
    search)      echo "pointer" ;;
    tool_output) echo "pointer" ;;
    history)     echo "truncate" ;;
    *)           echo "none" ;;
  esac
}

engine_available() {
  local engine="$1"
  case "$engine" in
    headroom)   python3 -c "import headroom" 2>/dev/null ;;
    treesitter) command -v tree-sitter &>/dev/null ;;
    llmlingua)  python3 -c "import llmlingua" 2>/dev/null ;;
    claw)       python3 -c "import claw_compactor" 2>/dev/null ;;
    truncate|pointer|none) return 0 ;;
    *)          return 1 ;;
  esac
}

if ! engine_available "$ENGINE"; then
  FALLBACK=$(fallback_engine "$TYPE")
  echo "[compress] $ENGINE not installed, falling back to $FALLBACK. Install: compress.sh --install=$ENGINE" >&2
  ENGINE="$FALLBACK"
fi

export HEADROOM_CONTENT_TYPE="$TYPE"
run_engine "$ENGINE" "$INPUT_FILE" "$SHOW_STATS"
