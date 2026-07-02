#!/usr/bin/env bash
set -euo pipefail

# Load save-token config with 3-level precedence:
#   1. User override:  ~/.save-token/config.json
#   2. Team config:    .save-token.json (workspace root)
#   3. Defaults:       built-in

CONFIG_DIR="${SAVE_TOKEN_DIR:-${HOME}/.save-token}"
USER_CONFIG="${CONFIG_DIR}/config.json"
TEAM_CONFIG=""
mkdir -p "$CONFIG_DIR"

find_team_config() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.save-token.json" ]; then
      echo "$dir/.save-token.json"
      return
    fi
    dir=$(dirname "$dir")
  done
}

TEAM_CONFIG=$(find_team_config)

DEFAULTS='{
  "mode": "full",
  "density": "full",
  "compression": {
    "code": "treesitter",
    "text": "truncate",
    "tool_output": "pointer"
  },
  "effort_routing": true,
  "context_hygiene": {
    "small_output_threshold": 20,
    "large_output_threshold": 100
  },
  "enforce_review_score": null,
  "progressive_activation": true,
  "platforms": ["cursor"]
}'

merge_json() {
  python3 -c "
import json, sys, re

def strip_jsonc(text):
    # Strip // comments (not inside strings) and trailing commas
    text = re.sub(r'(?<!:)//.*$', '', text, flags=re.MULTILINE)
    text = re.sub(r',\s*([\]}])', r'\1', text)
    return text

def deep_merge(base, override):
    result = base.copy()
    for k, v in override.items():
        if k in result and isinstance(result[k], dict) and isinstance(v, dict):
            result[k] = deep_merge(result[k], v)
        else:
            result[k] = v
    return result

configs = sys.argv[1:]
merged = json.loads(configs[0])
for cfg_path in configs[1:]:
    try:
        with open(cfg_path) as f:
            merged = deep_merge(merged, json.loads(strip_jsonc(f.read())))
    except (FileNotFoundError, json.JSONDecodeError):
        pass
print(json.dumps(merged, indent=2))
" "$@"
}

CMD="${1:-show}"

case "$CMD" in
  show)
    args=("$DEFAULTS")
    [ -n "$TEAM_CONFIG" ] && args+=("$TEAM_CONFIG")
    [ -f "$USER_CONFIG" ] && args+=("$USER_CONFIG")
    merge_json "${args[@]}"
    ;;
  get)
    KEY="${2:-}"
    if [ -z "$KEY" ]; then
      echo "Usage: load-config.sh get <key>" >&2; exit 1
    fi
    args=("$DEFAULTS")
    [ -n "$TEAM_CONFIG" ] && args+=("$TEAM_CONFIG")
    [ -f "$USER_CONFIG" ] && args+=("$USER_CONFIG")
    merge_json "${args[@]}" | python3 -c "
import json, sys
data = json.load(sys.stdin)
keys = '$KEY'.split('.')
for k in keys:
    if isinstance(data, dict) and k in data:
        data = data[k]
    else:
        sys.exit(1)
print(json.dumps(data) if isinstance(data, (dict, list)) else data)
" 2>/dev/null
    ;;
  sources)
    echo "Precedence (highest first):"
    if [ -f "$USER_CONFIG" ]; then
      echo "  [1] User:    $USER_CONFIG"
    else
      echo "  [1] User:    (not found)"
    fi
    if [ -n "$TEAM_CONFIG" ]; then
      echo "  [2] Team:    $TEAM_CONFIG"
    else
      echo "  [2] Team:    (not found)"
    fi
    echo "  [3] Default: built-in"
    ;;
  init)
    TARGET="${2:-.save-token.json}"
    if [ -f "$TARGET" ]; then
      echo "[SKIP] $TARGET already exists." >&2; exit 1
    fi
    SAVE_TOKEN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
    if [ -f "$SAVE_TOKEN_ROOT/save-token.json" ]; then
      cp "$SAVE_TOKEN_ROOT/save-token.json" "$TARGET"
    else
      cat > "$TARGET" <<'TMPL'
{
  "mode": "full",
  "density": "full",
  "compression": {
    "code": "treesitter",
    "text": "truncate",
    "tool_output": "pointer"
  },
  "effort_routing": true,
  "context_hygiene": {
    "small_output_threshold": 20,
    "large_output_threshold": 100
  },
  "enforce_review_score": "B",
  "progressive_activation": true,
  "platforms": ["cursor"]
}
TMPL
    fi
    echo "[OK] Created $TARGET"
    ;;
  apply)
    args=("$DEFAULTS")
    [ -n "$TEAM_CONFIG" ] && args+=("$TEAM_CONFIG")
    [ -f "$USER_CONFIG" ] && args+=("$USER_CONFIG")
    merged=$(merge_json "${args[@]}")

    mode=$(echo "$merged" | python3 -c "import json,sys; print(json.load(sys.stdin).get('mode','full'))")
    density=$(echo "$merged" | python3 -c "import json,sys; print(json.load(sys.stdin).get('density','full'))")

    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    bash "$SCRIPT_DIR/mode.sh" set "$mode" > /dev/null
    echo "$density" > "$CONFIG_DIR/density"
    echo "[OK] Applied: mode=$mode, density=$density"
    ;;
  -h|--help)
    echo "Usage: load-config.sh [show|get <key>|sources|init [path]|apply]"
    echo
    echo "Commands:"
    echo "  show              Merged config (defaults + team + user)"
    echo "  get <key>         Get a specific key (dot notation: compression.code)"
    echo "  sources           Show config file precedence"
    echo "  init [path]       Create template .save-token.json"
    echo "  apply             Apply merged config (set mode + density)"
    ;;
  *)
    echo "[FAIL] Unknown command: $CMD" >&2; exit 1 ;;
esac
