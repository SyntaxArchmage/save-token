#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME}/.save-token"
LEARNINGS="${CONFIG_DIR}/learnings.md"
mkdir -p "$CONFIG_DIR"

TRANSCRIPT_DIRS=(
  "${HOME}/.cursor/projects"
)

echo "╔══════════════════════════════════════╗"
echo "║       save-token learn               ║"
echo "╚══════════════════════════════════════╝"
echo

found_any=false
all_findings=""

for base_dir in "${TRANSCRIPT_DIRS[@]}"; do
  if [ ! -d "$base_dir" ]; then
    continue
  fi

  while IFS= read -r transcript_dir; do
    found_any=true
    project_name=$(basename "$(dirname "$transcript_dir")")
    echo "Scanning: $project_name"

    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    while IFS= read -r jsonl_file; do
      [ ! -s "$jsonl_file" ] && continue

      if [ "${1:-}" = "--html" ]; then
        findings=$(python3 "$SCRIPT_DIR/analyze_transcript.py" "$jsonl_file" --html 2>/dev/null || true)
      else
        findings=$(python3 "$SCRIPT_DIR/analyze_transcript.py" "$jsonl_file" 2>/dev/null || true)
      fi

      if [ -n "$findings" ]; then
        echo "$findings"
        all_findings="${all_findings}${findings}"$'\n'
      fi

    done < <(find "$transcript_dir" -name "*.jsonl" -mtime -7 2>/dev/null | head -20)

  done < <(find "$base_dir" -type d -name "agent-transcripts" 2>/dev/null)
done

if [ "$found_any" = false ]; then
  echo "No agent-transcripts found."
  exit 0
fi

echo
echo "Writing findings to $LEARNINGS"
{
  echo "# save-token Learnings"
  echo "Generated: $(date -Iseconds)"
  echo
  echo "## Waste Patterns"
  echo
  if [ -n "$all_findings" ]; then
    echo "$all_findings"
  else
    echo "- No waste patterns detected in recent sessions"
  fi
  echo
  echo "## Token Estimates"
  echo
  token_lines=$(echo "$all_findings" | grep "estimated tokens" || true)
  if [ -n "$token_lines" ]; then
    echo "$token_lines"
  else
    echo "- No token data available (transcripts may lack message content)"
  fi
  echo
  echo "## Recommendations"
  echo
  echo "- Use '/save-token review' during sessions for real-time audit"
  echo "- Enable 'full' mode to enforce no-reread and batching discipline"
} > "$LEARNINGS"

echo "[OK] Done. Run '/save-token stats' to see summary."
