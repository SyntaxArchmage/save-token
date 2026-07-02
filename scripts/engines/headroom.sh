#!/usr/bin/env bash
# Headroom engine: content-type-aware compression using Headroom's local transforms.
# Routes to SmartCrusher (JSON), CodeCompressor (code), LogCompressor (logs),
# Kompress-v2-base (text/html/diff/search/tool_output). All run locally, no API key.
# Requires: pip install headroom-ai

if ! python3 -c "import headroom" 2>/dev/null; then
  echo "[compress] headroom-ai not installed. Run: compress.sh --install=headroom" >&2
  cat
  exit 0
fi

TMPINPUT=$(mktemp)
cat > "$TMPINPUT"
trap 'rm -f "$TMPINPUT"' EXIT

HEADROOM_INPUT="$TMPINPUT" python3 -c "
import os, sys

with open(os.environ['HEADROOM_INPUT']) as f:
    text = f.read()
if not text.strip():
    sys.exit(0)

content_type = os.environ.get('HEADROOM_CONTENT_TYPE', 'auto')

def detect_type(t):
    first = t[:200].lstrip()
    if first.startswith(('{', '[')): return 'json'
    if first.startswith(('diff --', '--- a/')): return 'diff'
    if first.startswith(('<html', '<!DOCTYPE', '<HTML')): return 'html'
    if any(first.startswith(p) for p in ['def ', 'class ', 'import ', 'from ', '#!', 'package ', 'func ']): return 'code'
    if '[' in first[:50] and any(lv in first for lv in ['INFO', 'WARN', 'ERROR', 'DEBUG']): return 'logs'
    return 'text'

if content_type == 'auto':
    content_type = detect_type(text)

if content_type == 'json':
    from headroom import SmartCrusher
    sc = SmartCrusher()
    r = sc.crush(text)
    if r.was_modified:
        result_text = r.compressed
    else:
        from headroom.transforms.kompress_compressor import KompressCompressor, KompressConfig
        kc = KompressCompressor(KompressConfig())
        kr = kc.compress(content=text, target_ratio=0.4, allow_download=True)
        result_text = kr.compressed
elif content_type == 'code':
    from headroom.transforms.code_compressor import compress_code
    r = compress_code(text)
    result_text = r.compressed if hasattr(r, 'compressed') else str(r)
    from headroom.transforms.kompress_compressor import KompressCompressor, KompressConfig
    kc = KompressCompressor(KompressConfig())
    kr = kc.compress(content=result_text, target_ratio=0.5, allow_download=True)
    if len(kr.compressed) < len(result_text):
        result_text = kr.compressed
elif content_type == 'logs':
    from headroom.transforms.log_compressor import LogCompressor
    lc = LogCompressor()
    r = lc.compress(text)
    result_text = r.compressed if hasattr(r, 'compressed') else str(r)
else:
    from headroom.transforms.kompress_compressor import KompressCompressor, KompressConfig
    kc = KompressCompressor(KompressConfig())
    kr = kc.compress(content=text, target_ratio=0.5, allow_download=True)
    result_text = kr.compressed

sys.stdout.write(result_text)
"
