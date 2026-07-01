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

if [ "${1:-}" = "--html" ]; then
  OUTFILE="${2:-/tmp/save-token-review.html}"
  python3 "$SCRIPT_DIR/analyze_transcript.py" "$LATEST" --html -o "$OUTFILE"
  echo "[OK] HTML report: $OUTFILE"
  exit 0
fi

echo "Reviewing: $project"
echo "Transcript: $(basename "$LATEST")"
echo

scored=$(python3 -c "
import json, sys
sys.path.insert(0, '$SCRIPT_DIR')
from analyze_transcript import analyze
r = analyze('$LATEST')

score = 100
issues = 0

reads = r.get('repeated_reads', [])
seqs = r.get('sequential_calls', [])
verbose = r.get('verbose_responses', [])
tokens = r.get('token_estimate', [])

fixes = []

for item in reads:
    print('  [!] ' + item)
    score -= 5
    issues += 1
    fixes.append('Use offset/limit on large files; cache content in conversation context')

for item in seqs:
    print('  [!] ' + item)
    score -= 3
    issues += 1
    fixes.append('Batch independent tool calls in a single turn')

for item in verbose:
    print('  [!] ' + item)
    score -= 2
    issues += 1
    fixes.append('Shorten responses: code-only answers, skip narration')

full_reads = r.get('full_reads', [])
for item in full_reads:
    print('  [!] ' + item)
    score -= 2
    issues += 1
    fixes.append('Read with offset/limit instead of full file')

tool_summary = r.get('tool_summary', [])
for t in tool_summary:
    print('  ' + t)

for t in tokens:
    print('  ' + t)

score = max(0, score)

print()
if issues == 0:
    grade = 'A+'
elif score >= 90:
    grade = 'A'
elif score >= 75:
    grade = 'B'
elif score >= 60:
    grade = 'C'
elif score >= 40:
    grade = 'D'
else:
    grade = 'F'

print(f'Score: {score}/100 (grade {grade}, {issues} issue(s))')
if issues == 0:
    print('No waste detected. Session is clean.')
else:
    seen = set()
    unique_fixes = [f for f in fixes if f not in seen and not seen.add(f)]
    print()
    print('Suggested fixes:')
    for i, fix in enumerate(unique_fixes[:5], 1):
        print(f'  {i}. {fix}')
" 2>/dev/null || true)

echo "$scored"
