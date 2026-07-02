#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
FIXTURE_DIR="$REPO_DIR/benchmarks/compression"
RESULTS_FILE="$REPO_DIR/benchmarks/results/compress-bench.json"
COMPRESS="$SCRIPT_DIR/compress.sh"

usage() {
  cat <<'USAGE'
Usage: compress-bench.sh [command]

Commands:
  run       Run all benchmarks (default)
  status    Show progress
  --help    Show this help

Runs compress.sh with every applicable engine on every fixture in
benchmarks/compression/, recording input/output bytes and ratio.
Results: benchmarks/results/compress-bench.json
USAGE
  exit 0
}

case "${1:-run}" in
  -h|--help|help) usage ;;
  status)
    if [ ! -f "$RESULTS_FILE" ]; then
      echo "No results yet. Run: compress-bench.sh run"
      exit 0
    fi
    python3 -c "
import json
data = json.load(open('$RESULTS_FILE'))
types = sorted(set(r['content_type'] for r in data))
engines = sorted(set(r['engine'] for r in data))
print(f'{len(data)} measurements: {len(types)} types x {len(engines)} engines')
for t in types:
    entries = [r for r in data if r['content_type'] == t]
    engs = sorted(set(r['engine'] for r in entries))
    print(f'  {t}: {len(entries)} ({\", \".join(engs)})')
"
    exit 0
    ;;
  run) ;;
  *) echo "[FAIL] Unknown command: $1" >&2; exit 1 ;;
esac

# Engine x Type applicability matrix
applicable_engines() {
  local content_type="$1"
  case "$content_type" in
    code)        echo "none truncate pointer treesitter headroom claw" ;;
    text)        echo "none truncate pointer headroom llmlingua" ;;
    json)        echo "none truncate pointer headroom" ;;
    logs)        echo "none truncate pointer headroom" ;;
    diff)        echo "none truncate headroom" ;;
    html)        echo "none truncate headroom" ;;
    search)      echo "none truncate pointer headroom" ;;
    tool_output) echo "none truncate pointer headroom" ;;
    history)     echo "none truncate" ;;
    metadata)    echo "none truncate" ;;
  esac
}

engine_installed() {
  local engine="$1"
  case "$engine" in
    none|truncate|pointer) return 0 ;;
    treesitter) command -v tree-sitter &>/dev/null || return 0 ;; # regex fallback always works
    headroom)   python3 -c "import headroom" 2>/dev/null ;;
    llmlingua)  python3 -c "from llmlingua import PromptCompressor" 2>/dev/null ;;
    claw)       python3 -c "from claw_compactor import compress" 2>/dev/null ;;
    *) return 1 ;;
  esac
}

detect_type() {
  local file="$1"
  case "$file" in
    *code*.py)        echo "code" ;;
    *json*.json)      echo "json" ;;
    *logs*.log)       echo "logs" ;;
    *diff*.diff)      echo "diff" ;;
    *html*.html)      echo "html" ;;
    *search*.txt)     echo "search" ;;
    *text*.md)        echo "text" ;;
    *tool*.txt)       echo "tool_output" ;;
    *history*.jsonl)  echo "history" ;;
    *metadata*.yaml)  echo "metadata" ;;
    *) echo "text" ;;
  esac
}

detect_size() {
  local file="$1"
  case "$file" in
    *small*) echo "small" ;;
    *medium*) echo "medium" ;;
    *large*) echo "large" ;;
    *) echo "medium" ;;
  esac
}

echo "╔══════════════════════════════════════╗"
echo "║  Compression Benchmark Suite         ║"
echo "╚══════════════════════════════════════╝"
echo

# Check which engines are available
echo "Engine availability:"
for eng in none truncate pointer treesitter headroom llmlingua claw; do
  if engine_installed "$eng"; then
    printf "  [OK] %s\n" "$eng"
  else
    printf "  [--] %s (not installed, skipping)\n" "$eng"
  fi
done
echo

# Collect fixtures
fixtures=()
for f in "$FIXTURE_DIR"/*; do
  name=$(basename "$f")
  [[ "$name" == "generate_fixtures.py" ]] && continue
  [[ -f "$f" ]] || continue
  fixtures+=("$f")
done

echo "Fixtures: ${#fixtures[@]} files"
echo "Output: $RESULTS_FILE"
echo

# Run benchmarks
TMPRESULTS=$(mktemp)
echo "[]" > "$TMPRESULTS"
trap 'rm -f "$TMPRESULTS"' EXIT
total=0
skipped=0

for fixture in "${fixtures[@]}"; do
  fname=$(basename "$fixture")
  content_type=$(detect_type "$fname")
  size_class=$(detect_size "$fname")
  input_bytes=$(wc -c < "$fixture")
  input_lines=$(wc -l < "$fixture")

  engines=$(applicable_engines "$content_type")
  for engine in $engines; do
    if ! engine_installed "$engine"; then
      skipped=$((skipped + 1))
      continue
    fi

    start_ms=$(python3 -c "import time; print(int(time.time()*1000))")
    output=$(bash "$COMPRESS" --type="$content_type" --engine="$engine" < "$fixture" 2>/dev/null) || output=""
    end_ms=$(python3 -c "import time; print(int(time.time()*1000))")

    output_bytes=${#output}
    elapsed_ms=$((end_ms - start_ms))

    if [ "$input_bytes" -gt 0 ]; then
      ratio=$(python3 -c "print(round($output_bytes / $input_bytes * 100, 1))")
      reduction=$(python3 -c "print(round((1 - $output_bytes / $input_bytes) * 100, 1))")
    else
      ratio="100.0"
      reduction="0.0"
    fi

    TMPRESULTS_PATH="$TMPRESULTS" python3 -c "
import json, os
path = os.environ['TMPRESULTS_PATH']
with open(path) as f: data = json.load(f)
data.append({
    'fixture': '$fname',
    'content_type': '$content_type',
    'size_class': '$size_class',
    'engine': '$engine',
    'input_bytes': $input_bytes,
    'input_lines': int('$input_lines'),
    'output_bytes': $output_bytes,
    'ratio_pct': float('$ratio'),
    'reduction_pct': float('$reduction'),
    'elapsed_ms': $elapsed_ms,
})
with open(path, 'w') as f: json.dump(data, f)
"
    total=$((total + 1))
    printf "  %-30s %-12s %-10s %6dB → %6dB (%5s%% ratio)\n" \
      "$fname" "$engine" "$size_class" "$input_bytes" "$output_bytes" "$ratio"
  done
done

# Write final results
mkdir -p "$(dirname "$RESULTS_FILE")"
python3 -m json.tool < "$TMPRESULTS" > "$RESULTS_FILE"

echo
echo "Done: $total measurements, $skipped skipped (engine not installed)"
echo "Results: $RESULTS_FILE"

# Show which engines were skipped and why
if [ "$skipped" -gt 0 ]; then
  echo
  echo "Skipped engines:"
  for eng in treesitter headroom llmlingua claw; do
    if ! engine_installed "$eng" 2>/dev/null; then
      case "$eng" in
        treesitter) echo "  [--] treesitter: tree-sitter CLI not installed (regex fallback used instead)" ;;
        headroom)   echo "  [--] headroom: pip install headroom-ai" ;;
        llmlingua)  echo "  [--] llmlingua: pip install llmlingua (needs HuggingFace model download)" ;;
        claw)       echo "  [--] claw: PyPI package is unrelated; real Claw Compactor not available" ;;
      esac
    fi
  done
fi
