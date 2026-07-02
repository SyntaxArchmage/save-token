#!/usr/bin/env bash
# Headroom engine: full context compression via Headroom's ContentRouter.
# Routes to SmartCrusher (JSON), CodeCompressor (code), LogCompressor (logs),
# DiffCompressor (diffs), HTMLExtractor (HTML), SearchCompressor (search),
# Kompress-v2-base (text). Requires: pip install headroom-ai

if ! python3 -c "import headroom" 2>/dev/null; then
  echo "[compress] headroom-ai not installed. Run: compress.sh --install=headroom" >&2
  cat
  exit 0
fi

python3 -c "
import sys
from headroom import compress

text = sys.stdin.read()
messages = [{'role': 'user', 'content': text}]
result = compress(messages, model='claude-sonnet-4-5-20250929', compress_user_messages=True, protect_recent=0)
for msg in result.messages:
    content = msg.get('content', '')
    if isinstance(content, list):
        for part in content:
            if isinstance(part, dict):
                print(part.get('text', ''))
            else:
                print(part)
    else:
        print(content)
"
