#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${SAVE_TOKEN_DIR:-${HOME}/.save-token}"
PROGRESS_FILE="${CONFIG_DIR}/progression.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$CONFIG_DIR"

PROMOTE_THRESHOLD="${SAVE_TOKEN_PROMOTE_THRESHOLD:-3}"
PROMOTE_SCORE="${SAVE_TOKEN_PROMOTE_SCORE:-B}"

usage() {
  echo "Usage: progress.sh [show|record <score>|reset|apply]"
  echo
  echo "Commands:"
  echo "  show               Current progression status"
  echo "  record <score>     Record a session review score (A+/A/A-/B+/B/B-/C+/C/D/F)"
  echo "  reset              Clear progression history"
  echo "  apply              Auto-apply recommended mode if promotion earned"
  echo
  echo "Environment:"
  echo "  SAVE_TOKEN_PROMOTE_THRESHOLD  Sessions needed for promotion (default: 3)"
  echo "  SAVE_TOKEN_PROMOTE_SCORE      Minimum score for promotion (default: B)"
  exit 0
}

init_progress() {
  local mode
  mode=$(bash "$SCRIPT_DIR/mode.sh" get)
  python3 -c "
import json
data = {
    'current_level': '$mode',
    'sessions_at_level': 0,
    'review_scores': [],
    'history': []
}
with open('$PROGRESS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

[ -f "$PROGRESS_FILE" ] || init_progress

score_to_num() {
  python3 -c "
scores = {'A+':4.3,'A':4.0,'A-':3.7,'B+':3.3,'B':3.0,'B-':2.7,'C+':2.3,'C':2.0,'D':1.0,'F':0.0}
s = '$1'
print(scores.get(s, -1))
"
}

CMD="${1:-show}"

case "$CMD" in
  show)
    python3 -c "
import json

with open('$PROGRESS_FILE') as f:
    data = json.load(f)

level = data['current_level']
sessions = data['sessions_at_level']
scores = data['review_scores']
threshold = $PROMOTE_THRESHOLD

print('╔══════════════════════════════════════╗')
print('║   save-token progression             ║')
print('╚══════════════════════════════════════╝')
print()
print(f'  Current level:     {level}')
print(f'  Sessions at level: {sessions}')

if scores:
    score_map = {'A+':4.3,'A':4.0,'A-':3.7,'B+':3.3,'B':3.0,'B-':2.7,'C+':2.3,'C':2.0,'D':1.0,'F':0.0}
    nums = [score_map.get(s, 0) for s in scores[-10:]]
    avg = sum(nums) / len(nums)
    grade_names = sorted(score_map.items(), key=lambda x: x[1])
    avg_grade = 'F'
    for name, val in grade_names:
        if avg >= val:
            avg_grade = name
    print(f'  Recent scores:     {\" \".join(scores[-10:])}')
    print(f'  Average:           {avg_grade} ({avg:.1f}/4.3)')
else:
    print('  Recent scores:     (none)')

next_level = {'lite': 'full', 'full': 'ultra', 'ultra': None, 'off': 'lite'}
target = next_level.get(level)
if target:
    qualifying = sum(1 for s in scores[-threshold:] if score_map.get(s, 0) >= score_map.get('$PROMOTE_SCORE', 3.0))
    print()
    print(f'  Promotion target:  {target}')
    print(f'  Qualifying scores: {qualifying}/{threshold} (need $PROMOTE_SCORE or higher)')
    if qualifying >= threshold:
        print(f'  Status:            READY — run: progress.sh apply')
    else:
        remaining = threshold - qualifying
        print(f'  Status:            {remaining} more qualifying session(s) needed')
else:
    print()
    print('  At maximum level (ultra).')

if data.get('history'):
    print()
    print('  History:')
    for h in data['history'][-5:]:
        print(f'    {h[\"level\"]} → promoted {h.get(\"promoted\", \"?\")}')
" 2>/dev/null
    ;;
  record)
    SCORE="${2:-}"
    if [ -z "$SCORE" ]; then
      echo "Usage: progress.sh record <score>" >&2; exit 1
    fi
    num=$(score_to_num "$SCORE")
    if [ "$num" = "-1" ]; then
      echo "[FAIL] Invalid score: $SCORE. Use A+/A/A-/B+/B/B-/C+/C/D/F" >&2; exit 1
    fi
    python3 -c "
import json
with open('$PROGRESS_FILE') as f:
    data = json.load(f)
data['sessions_at_level'] += 1
data['review_scores'].append('$SCORE')
with open('$PROGRESS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
print(f'[OK] Recorded: $SCORE (session {data[\"sessions_at_level\"]} at {data[\"current_level\"]})')
"
    ;;
  apply)
    python3 -c "
import json, datetime

with open('$PROGRESS_FILE') as f:
    data = json.load(f)

score_map = {'A+':4.3,'A':4.0,'A-':3.7,'B+':3.3,'B':3.0,'B-':2.7,'C+':2.3,'C':2.0,'D':1.0,'F':0.0}
threshold = $PROMOTE_THRESHOLD
min_score = score_map.get('$PROMOTE_SCORE', 3.0)
next_level = {'lite': 'full', 'full': 'ultra', 'ultra': None, 'off': 'lite'}

level = data['current_level']
target = next_level.get(level)

if not target:
    print('[--] Already at maximum level (ultra).')
    exit(0)

qualifying = sum(1 for s in data['review_scores'][-threshold:] if score_map.get(s, 0) >= min_score)
if qualifying < threshold:
    print(f'[--] Not ready. Need {threshold - qualifying} more qualifying sessions.')
    exit(0)

data['history'].append({
    'level': level,
    'sessions': data['sessions_at_level'],
    'promoted': datetime.datetime.now().strftime('%Y-%m-%d')
})
data['current_level'] = target
data['sessions_at_level'] = 0
data['review_scores'] = []

with open('$PROGRESS_FILE', 'w') as f:
    json.dump(data, f, indent=2)

print(f'[OK] Promoted: {level} → {target}')
" 2>/dev/null

    new_mode=$(python3 -c "import json; print(json.load(open('$PROGRESS_FILE'))['current_level'])")
    bash "$SCRIPT_DIR/mode.sh" set "$new_mode" > /dev/null
    ;;
  reset)
    init_progress
    echo "[OK] Progression reset."
    ;;
  -h|--help) usage ;;
  *) echo "[FAIL] Unknown command: $CMD" >&2; exit 1 ;;
esac
