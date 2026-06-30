#!/usr/bin/env bash
set -euo pipefail

# Review the most recent agent transcript for the current project.
# Designed to be called during an active session for real-time audit.

PROJECTS_DIR="${HOME}/.cursor/projects"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "╔══════════════════════════════════════╗"
echo "║      save-token review               ║"
echo "╚══════════════════════════════════════╝"
echo

# Find the most recently modified transcript
LATEST=""
LATEST_TIME=0

for dir in "$PROJECTS_DIR"/*/agent-transcripts/; do
  [ -d "$dir" ] || continue
  while IFS= read -r f; do
    mtime=$(stat -c %Y "$f" 2>/dev/null || echo 0)
    if [ "$mtime" -gt "$LATEST_TIME" ]; then
      LATEST="$f"
      LATEST_TIME="$mtime"
    fi
  done < <(find "$dir" -name "*.jsonl" -mmin -60 2>/dev/null)
done

if [ -z "$LATEST" ]; then
  echo "No recent transcripts found (last 60 min)."
  echo "Start or continue an agent session, then run this again."
  exit 0
fi

project=$(basename "$(dirname "$(dirname "$LATEST")")")
echo "Reviewing: $project"
echo "Transcript: $(basename "$LATEST")"
echo

# Run analyzer with detailed output
findings=$(python3 -c "
import json, sys
sys.path.insert(0, '$SCRIPT_DIR')
from analyze_transcript import analyze
r = analyze('$LATEST')
waste = []
for k in ('repeated_reads', 'sequential_calls', 'verbose_responses'):
    waste.extend(r.get(k, []))
if waste:
    print('Waste patterns found:')
    for w in waste:
        print(w)
else:
    print('No waste patterns detected in this session.')
for t in r.get('token_estimate', []):
    print(t)
" 2>/dev/null || true)

echo "$findings"

echo
echo "Checklist:"
echo "  [ ] Files read multiple times? Check above"
  echo "  [ ] Sequential tool calls that could batch? Check above"
echo "  [ ] Responses over 2000 chars? Check above"
echo "  [ ] Code blocks that should be code references?"
echo "  [ ] Context restated unnecessarily?"
