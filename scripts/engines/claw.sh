#!/usr/bin/env bash
# Claw Compactor engine: AST-aware code compression, reversible.
# Requires: pip install claw-compactor (the real Claw Compactor package)
#
# NOTE: The PyPI package 'claw-compactor' as of v7.x is an unrelated project
# (EngramEngine). The AST-aware code compression tool from the research survey
# (github.com/claw-project/claw-compactor, 2.2k stars) is not available on PyPI.
# When the correct package becomes available, update the import below.

if ! python3 -c "
try:
    from claw_compactor import compress
except ImportError:
    raise SystemExit(1)
" 2>/dev/null; then
  echo "[compress] claw-compactor (AST compressor) not available. PyPI package is unrelated." >&2
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
