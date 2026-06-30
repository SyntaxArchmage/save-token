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

    while IFS= read -r jsonl_file; do
      [ ! -s "$jsonl_file" ] && continue

      findings=$(python3 -c "
import json, collections
reads = collections.Counter()
with open('$jsonl_file') as f:
    for line in f:
        try:
            obj = json.loads(line)
            if obj.get('type') == 'tool_call':
                name = obj.get('tool_name', obj.get('name', ''))
                if name in ('Read', 'read_file', 'file_read'):
                    path = obj.get('parameters', {}).get('path', '')
                    if path:
                        reads[path] += 1
        except (json.JSONDecodeError, KeyError):
            pass
dupes = {k: v for k, v in reads.items() if v > 2}
for path, count in sorted(dupes.items(), key=lambda x: -x[1]):
    print(f'- re-read {count}x: {path}')
" 2>/dev/null || true)

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
  echo "## Repeated File Reads"
  echo
  if [ -n "$all_findings" ]; then
    echo "$all_findings"
  else
    echo "- No repeated reads detected in recent sessions"
  fi
  echo
  echo "## Recommendations"
  echo
  echo "- Use '/save-token review' during sessions for real-time audit"
  echo "- Enable 'full' mode to enforce no-reread discipline"
} > "$LEARNINGS"

echo "[OK] Done. Run '/save-token stats' to see summary."
