#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${SAVE_TOKEN_DIR:-${HOME}/.save-token}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOKENS_LOG="${CONFIG_DIR}/tokens.log"
mkdir -p "$CONFIG_DIR"

usage() {
  cat <<'USAGE'
Usage: tokens.sh [command] [options]

Real token tracking across platforms.

Commands:
  detect                  Auto-detect available token data sources
  collect [--source=S]    Collect token data from source (auto|cursor|claude|litellm|helicone|manual)
  log INPUT OUTPUT        Manually log a request's token counts
  summary                 Show summary of tracked token data
  export [--format=F]     Export data (csv|json, default: csv)
  reset                   Clear token log

Environment:
  SAVE_TOKEN_DIR          Config directory (default: ~/.save-token)
  HELICONE_API_KEY        Helicone API key for --source=helicone
  LITELLM_BASE_URL        LiteLLM proxy URL for --source=litellm

Examples:
  tokens.sh detect
  tokens.sh collect --source=auto
  tokens.sh log 12000 4500
  tokens.sh summary
  tokens.sh export --format=json
USAGE
  exit 0
}

detect_sources() {
  echo "╔══════════════════════════════════════╗"
  echo "║   save-token token source detect     ║"
  echo "╚══════════════════════════════════════╝"
  echo

  found=false

  if [ -f "${HOME}/.cursor/usage.json" ]; then
    echo "[OK] Cursor usage.json: ${HOME}/.cursor/usage.json"
    found=true
  fi

  if command -v claude &>/dev/null; then
    echo "[OK] Claude CLI: $(command -v claude)"
    found=true
  fi

  if [ -n "${HELICONE_API_KEY:-}" ]; then
    echo "[OK] Helicone: API key set"
    found=true
  fi

  if [ -n "${LITELLM_BASE_URL:-}" ]; then
    echo "[OK] LiteLLM: $LITELLM_BASE_URL"
    found=true
  fi

  if [ -f "$TOKENS_LOG" ] && [ -s "$TOKENS_LOG" ]; then
    entries=$(wc -l < "$TOKENS_LOG")
    echo "[OK] Manual log: $TOKENS_LOG ($entries entries)"
    found=true
  fi

  if [ "$found" = false ]; then
    echo "[--] No token data sources detected."
    echo
    echo "Options:"
    echo "  1. Use 'tokens.sh log INPUT OUTPUT' to manually track"
    echo "  2. Set HELICONE_API_KEY for Helicone integration"
    echo "  3. Set LITELLM_BASE_URL for LiteLLM proxy"
    echo "  4. Run Claude Code with --output-format json"
  fi
}

collect_cursor() {
  local usage_file="${HOME}/.cursor/usage.json"
  if [ ! -f "$usage_file" ]; then
    echo "[SKIP] Cursor usage.json not found" >&2
    return 1
  fi

  python3 -c "
import json, sys
with open('$usage_file') as f:
    data = json.load(f)

if 'requests' in data:
    for req in data.get('requests', [])[-10:]:
        inp = req.get('input_tokens', req.get('promptTokens', 0))
        out = req.get('output_tokens', req.get('completionTokens', 0))
        model = req.get('model', 'unknown')
        ts = req.get('timestamp', req.get('created', ''))
        print(f'{ts},{model},{inp},{out}')
elif 'totalTokens' in data:
    print(f'cumulative,mixed,{data.get(\"promptTokens\", 0)},{data.get(\"completionTokens\", 0)}')
else:
    print('No parseable token data found', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null
}

collect_claude() {
  echo "[INFO] Claude Code token tracking requires running commands with --output-format json" >&2
  echo "[TIP]  Pipe output: claude --output-format json 'prompt' | tokens.sh parse-claude" >&2
  return 1
}

collect_helicone() {
  if [ -z "${HELICONE_API_KEY:-}" ]; then
    echo "[SKIP] HELICONE_API_KEY not set" >&2
    return 1
  fi

  curl -sS "https://api.helicone.ai/v1/request/query" \
    -H "Authorization: Bearer $HELICONE_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"limit": 20, "offset": 0}' 2>/dev/null \
    | python3 -c "
import json, sys
data = json.load(sys.stdin)
for req in data.get('data', []):
    ts = req.get('created_at', '')
    model = req.get('model', 'unknown')
    inp = req.get('prompt_tokens', 0)
    out = req.get('completion_tokens', 0)
    print(f'{ts},{model},{inp},{out}')
" 2>/dev/null
}

collect_litellm() {
  local base="${LITELLM_BASE_URL:-http://localhost:4000}"
  curl -sS "${base}/spend/logs?limit=20" 2>/dev/null \
    | python3 -c "
import json, sys
data = json.load(sys.stdin)
for entry in data if isinstance(data, list) else data.get('data', []):
    ts = entry.get('startTime', entry.get('created_at', ''))
    model = entry.get('model', 'unknown')
    inp = entry.get('prompt_tokens', 0)
    out = entry.get('completion_tokens', 0)
    print(f'{ts},{model},{inp},{out}')
" 2>/dev/null
}

do_collect() {
  local source="${1:-auto}"
  local collected=""

  case "$source" in
    auto)
      collected=$(collect_cursor 2>/dev/null || true)
      [ -z "$collected" ] && collected=$(collect_helicone 2>/dev/null || true)
      [ -z "$collected" ] && collected=$(collect_litellm 2>/dev/null || true)
      ;;
    cursor)   collected=$(collect_cursor) ;;
    claude)   collected=$(collect_claude) ;;
    helicone) collected=$(collect_helicone) ;;
    litellm)  collected=$(collect_litellm) ;;
    manual)
      echo "[INFO] Use: tokens.sh log INPUT OUTPUT"
      return 0
      ;;
    *)
      echo "[FAIL] Unknown source: $source" >&2; return 1 ;;
  esac

  if [ -n "$collected" ]; then
    echo "$collected" >> "$TOKENS_LOG"
    lines=$(echo "$collected" | wc -l)
    echo "[OK] Collected $lines entries → $TOKENS_LOG"
  else
    echo "[--] No token data collected. Try: tokens.sh log INPUT OUTPUT"
  fi
}

do_log() {
  local input_tokens="${1:-}"
  local output_tokens="${2:-}"
  local model="${3:-manual}"

  if [ -z "$input_tokens" ] || [ -z "$output_tokens" ]; then
    echo "Usage: tokens.sh log INPUT_TOKENS OUTPUT_TOKENS [MODEL]" >&2
    exit 1
  fi

  echo "$(date -Iseconds),$model,$input_tokens,$output_tokens" >> "$TOKENS_LOG"
  echo "[OK] Logged: ${input_tokens} in, ${output_tokens} out ($model)"
}

do_summary() {
  echo "╔══════════════════════════════════════╗"
  echo "║     save-token token summary         ║"
  echo "╚══════════════════════════════════════╝"
  echo

  if [ ! -f "$TOKENS_LOG" ] || [ ! -s "$TOKENS_LOG" ]; then
    echo "No token data. Run: tokens.sh collect --source=auto"
    echo "Or manually: tokens.sh log INPUT OUTPUT"
    return 0
  fi

  python3 -c "
import sys

total_in = 0
total_out = 0
count = 0
models = {}

for line in open('$TOKENS_LOG'):
    parts = line.strip().split(',')
    if len(parts) < 4:
        continue
    ts, model, inp, out = parts[0], parts[1], parts[2], parts[3]
    try:
        inp_n, out_n = int(inp), int(out)
    except ValueError:
        continue
    total_in += inp_n
    total_out += out_n
    count += 1
    models[model] = models.get(model, 0) + 1

if count == 0:
    print('No valid entries found.')
    sys.exit(0)

print(f'  Entries:       {count}')
print(f'  Input tokens:  {total_in:,}')
print(f'  Output tokens: {total_out:,}')
print(f'  Total tokens:  {total_in + total_out:,}')
print(f'  Avg per req:   {(total_in + total_out) // count:,}')
print()

# Estimate savings
mode_file = '$CONFIG_DIR/mode'
try:
    with open(mode_file) as f:
        mode = f.read().strip()
except:
    mode = 'full'

savings = {'ultra': 0.50, 'full': 0.38, 'lite': 0.20, 'off': 0.0}
rate = savings.get(mode, 0.38)
saved_out = int(total_out * rate)

print(f'  Mode: {mode}')
print(f'  Estimated output savings: {saved_out:,} tokens ({rate:.0%} reduction)')
print()
print('  Models seen:')
for m, c in sorted(models.items(), key=lambda x: -x[1]):
    print(f'    {m}: {c} requests')
" 2>/dev/null
}

do_export() {
  local fmt="${1:-csv}"

  if [ ! -f "$TOKENS_LOG" ] || [ ! -s "$TOKENS_LOG" ]; then
    echo "No data to export." >&2
    return 1
  fi

  case "$fmt" in
    csv)
      echo "timestamp,model,input_tokens,output_tokens"
      cat "$TOKENS_LOG"
      ;;
    json)
      python3 -c "
import json
rows = []
for line in open('$TOKENS_LOG'):
    parts = line.strip().split(',')
    if len(parts) >= 4:
        rows.append({'timestamp': parts[0], 'model': parts[1],
                     'input_tokens': int(parts[2]), 'output_tokens': int(parts[3])})
print(json.dumps(rows, indent=2))
" 2>/dev/null
      ;;
    *)
      echo "[FAIL] Unknown format: $fmt. Use csv|json" >&2; return 1 ;;
  esac
}

# --- Parse arguments ---

CMD="${1:-}"
shift 2>/dev/null || true

SOURCE="auto"
FORMAT="csv"
POSITIONAL=()

for arg in "$@"; do
  case "$arg" in
    --source=*) SOURCE="${arg#--source=}" ;;
    --format=*) FORMAT="${arg#--format=}" ;;
    -*)         ;;
    *)          POSITIONAL+=("$arg") ;;
  esac
done

case "$CMD" in
  detect)     detect_sources ;;
  collect)    do_collect "$SOURCE" ;;
  log)        do_log "${POSITIONAL[@]}" ;;
  summary)    do_summary ;;
  export)     do_export "$FORMAT" ;;
  reset)
    if [ -f "$TOKENS_LOG" ]; then
      rm "$TOKENS_LOG"
      echo "[OK] Token log cleared."
    else
      echo "[--] No log to clear."
    fi
    ;;
  -h|--help|"") usage ;;
  parse-claude)
    python3 -c "
import json, sys
data = json.load(sys.stdin)
inp = data.get('usage', {}).get('input_tokens', 0)
out = data.get('usage', {}).get('output_tokens', 0)
model = data.get('model', 'claude')
print(f'$(date -Iseconds),{model},{inp},{out}')
" 2>/dev/null >> "$TOKENS_LOG"
    echo "[OK] Parsed Claude output → $TOKENS_LOG"
    ;;
  *)          echo "[FAIL] Unknown command: $CMD" >&2; usage ;;
esac
