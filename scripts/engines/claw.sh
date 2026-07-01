#!/usr/bin/env bash
# Claw Compactor engine: AST-aware code compression, reversible.
# Requires: pip install claw-compactor

if ! python3 -c "import claw_compactor" 2>/dev/null; then
  echo "[compress] claw-compactor not installed. Run: compress.sh --install=claw" >&2
  cat
  exit 0
fi

python3 -c "
import sys
from claw_compactor import compress

text = sys.stdin.read()
result = compress(text)
print(result)
"
