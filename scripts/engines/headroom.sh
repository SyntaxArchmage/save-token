#!/usr/bin/env bash
# Headroom engine: full context compression via Headroom CCR.
# Requires: pip install headroom-ai[proxy]

if ! python3 -c "import headroom" 2>/dev/null; then
  echo "[compress] headroom-ai not installed. Run: compress.sh --install=headroom" >&2
  cat
  exit 0
fi

python3 -c "
import sys
from headroom import compress

text = sys.stdin.read()
result = compress(text)
print(result)
"
