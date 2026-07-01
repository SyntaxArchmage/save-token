#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME}/.save-token"
LEARNINGS="${CONFIG_DIR}/learnings.md"
mkdir -p "$CONFIG_DIR"

TRANSCRIPT_DIRS=(
  "${HOME}/.cursor/projects"
)

# --- Verbosity Profile subcommand ---

if [ "${1:-}" = "--verbosity-profile" ]; then
  echo "╔══════════════════════════════════════╗"
  echo "║   save-token verbosity profile       ║"
  echo "╚══════════════════════════════════════╝"
  echo

  PROFILE_FILE="${CONFIG_DIR}/verbosity-profile.json"
  explain_more=0
  too_verbose=0
  sessions=0

  for base_dir in "${TRANSCRIPT_DIRS[@]}"; do
    [ -d "$base_dir" ] || continue
    while IFS= read -r transcript_dir; do
      while IFS= read -r jsonl_file; do
        [ -s "$jsonl_file" ] || continue
        sessions=$((sessions + 1))
        em=$(grep -ci 'explain more\|why did\|how does\|can you explain\|what does' "$jsonl_file" 2>/dev/null | tr -d '[:space:]' || true)
        tv=$(grep -ci 'just do it\|skip explanation\|too verbose\|too long\|shorter please\|less text\|no explanation' "$jsonl_file" 2>/dev/null | tr -d '[:space:]' || true)
        [ -z "$em" ] && em=0
        [ -z "$tv" ] && tv=0
        explain_more=$((explain_more + em))
        too_verbose=$((too_verbose + tv))
      done < <(find "$transcript_dir" -name "*.jsonl" -mtime -30 2>/dev/null | head -50)
    done < <(find "$base_dir" -type d -name "agent-transcripts" 2>/dev/null)
  done

  current_mode=$(cat "${CONFIG_DIR}/mode" 2>/dev/null || echo "full")

  if [ "$sessions" -eq 0 ]; then
    echo "No sessions found in last 30 days."
    echo '{"sessions_analyzed":0,"signals":{"explain_more":0,"too_verbose":0},"current_mode":"'"$current_mode"'","recommended_mode":"'"$current_mode"'","confidence":"LOW","last_updated":"'"$(date -Iseconds)"'"}' > "$PROFILE_FILE"
    exit 0
  fi

  em_pct=$((explain_more * 100 / sessions))
  tv_pct=$((too_verbose * 100 / sessions))

  recommended="$current_mode"
  confidence="LOW"
  if [ "$tv_pct" -gt 30 ]; then
    case "$current_mode" in
      lite) recommended="full" ;;
      full) recommended="ultra" ;;
      ultra) recommended="ultra" ;;
    esac
    confidence="HIGH"
  elif [ "$em_pct" -gt 30 ]; then
    case "$current_mode" in
      ultra) recommended="full" ;;
      full) recommended="lite" ;;
      lite) recommended="lite" ;;
    esac
    confidence="HIGH"
  elif [ "$tv_pct" -gt 15 ] || [ "$em_pct" -gt 15 ]; then
    confidence="MEDIUM"
  fi

  printf "  Sessions analyzed: %d (last 30 days)\n" "$sessions"
  printf "  \"explain more\" signals: %d (%d%%)\n" "$explain_more" "$em_pct"
  printf "  \"too verbose\" signals:  %d (%d%%)\n" "$too_verbose" "$tv_pct"
  echo
  printf "  Current mode:     %s\n" "$current_mode"
  printf "  Recommended mode: %s\n" "$recommended"
  printf "  Confidence:       %s\n" "$confidence"
  echo

  if [ "$recommended" != "$current_mode" ]; then
    echo "  Run: bash scripts/mode.sh set $recommended"
  else
    echo "  Current mode looks appropriate."
  fi

  python3 -c "
import json, datetime
profile = {
    'sessions_analyzed': $sessions,
    'signals': {'explain_more': $explain_more, 'too_verbose': $too_verbose},
    'current_mode': '$current_mode',
    'recommended_mode': '$recommended',
    'confidence': '$confidence',
    'last_updated': datetime.datetime.now().isoformat()
}
with open('$PROFILE_FILE', 'w') as f:
    json.dump(profile, f, indent=2)
" 2>/dev/null

  echo
  echo "[OK] Profile saved to $PROFILE_FILE"
  exit 0
fi

# --- Main learn flow ---

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
