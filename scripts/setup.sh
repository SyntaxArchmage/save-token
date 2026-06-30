#!/usr/bin/env bash
set -euo pipefail

PROXY_PORT="${SAVE_TOKEN_PORT:-8787}"

echo "╔══════════════════════════════════════╗"
echo "║       save-token setup               ║"
echo "╚══════════════════════════════════════╝"
echo

# Step 0: OS detection
OS="$(uname -s)"
case "$OS" in
  Linux)  echo "[OK] Platform: Linux" ;;
  Darwin) echo "[OK] Platform: macOS" ;;
  *)      echo "[WARN] Untested platform: $OS. Scripts may need adaptation." ;;
esac

# Step 1: Python check
if ! command -v python3 &>/dev/null; then
  echo "[FAIL] Python 3 not found."
  case "$OS" in
    Darwin) echo "  Install: brew install python3" ;;
    *)      echo "  Install: sudo apt install python3 (or equivalent)" ;;
  esac
  exit 1
fi

PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "[OK] Python $PY_VER"

# Step 2: Headroom check
if python3 -c "import headroom" 2>/dev/null; then
  HR_VER=$(pip show headroom-ai 2>/dev/null | grep ^Version | cut -d' ' -f2)
  echo "[OK] headroom-ai $HR_VER installed"
else
  echo "[..] Installing headroom-ai[proxy]..."
  pip install "headroom-ai[proxy]" --quiet
  echo "[OK] headroom-ai installed"
fi

# Step 3: Proxy check
if lsof -i ":$PROXY_PORT" &>/dev/null; then
  echo "[OK] Headroom proxy already running on port $PROXY_PORT"
else
  echo "[..] Starting Headroom proxy on port $PROXY_PORT..."
  export HEADROOM_OUTPUT_SHAPER=1
  nohup headroom proxy --port "$PROXY_PORT" > /tmp/headroom-proxy.log 2>&1 &
  sleep 2
  if lsof -i ":$PROXY_PORT" &>/dev/null; then
    echo "[OK] Proxy started (PID $!)"
  else
    echo "[WARN] Proxy may not have started. Check /tmp/headroom-proxy.log"
  fi
fi

# Step 4: Config instructions
echo
echo "┌─────────────────────────────────────────────┐"
echo "│ Cursor Configuration:                       │"
echo "│                                             │"
echo "│ Settings → Models → Override OpenAI Base URL│"
echo "│ → http://127.0.0.1:$PROXY_PORT/v1              │"
echo "│                                             │"
echo "│ Keep your existing API key unchanged.       │"
echo "└─────────────────────────────────────────────┘"
echo
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ ! -f .cursorignore ] && [ -f "$REPO_DIR/templates/cursorignore" ]; then
  echo "[TIP] Copy .cursorignore to reduce context usage:"
  echo "  cp $REPO_DIR/templates/cursorignore .cursorignore"
fi

echo
echo "[OK] Setup complete. Rules active at 'full' intensity."
