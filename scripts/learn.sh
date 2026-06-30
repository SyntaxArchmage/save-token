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

for base_dir in "${TRANSCRIPT_DIRS[@]}"; do
  if [ ! -d "$base_dir" ]; then
    continue
  fi

  # Find agent-transcripts directories
  while IFS= read -r transcript_dir; do
    found_any=true
    project_name=$(basename "$(dirname "$transcript_dir")")
    echo "Scanning: $project_name"

    # Analyze each transcript file
    while IFS= read -r jsonl_file; do
      if [ ! -s "$jsonl_file" ]; then
        continue
      fi

      # Count repeated file reads
      repeated_reads=$(python3 -c "
import json, sys, collections
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
    print(f'  re-read {count}x: {path}')
if not dupes:
    print('  (no repeated reads)')
" 2>/dev/null || echo "  (parse error)")

      echo "$repeated_reads"

    done < <(find "$transcript_dir" -name "*.jsonl" -mtime -7 2>/dev/null | head -20)

  done < <(find "$base_dir" -type d -name "agent-transcripts" 2>/dev/null)
done

if [ "$found_any" = false ]; then
  echo "No agent-transcripts found."
  echo "Transcripts are created by Cursor during agent sessions."
  exit 0
fi

# Write findings
echo
echo "Writing findings to $LEARNINGS"
{
  echo "# save-token Learnings"
  echo "# Generated: $(date -Iseconds)"
  echo
  echo "## Waste Patterns"
  echo
  echo "- Review findings above for repeated file reads"
  echo "- Run '/save-token review' during sessions for real-time audit"
} > "$LEARNINGS"

echo "[OK] Done. Run '/save-token stats' to see summary."
