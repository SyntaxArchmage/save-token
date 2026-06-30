#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="${HOME}/.cursor/skills/save-token"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing save-token skill..."

if [ -L "$SKILL_DIR" ]; then
  current=$(readlink -f "$SKILL_DIR")
  if [ "$current" = "$REPO_DIR" ]; then
    echo "[OK] Already installed (symlink exists)."
    exit 0
  fi
  echo "[..] Updating symlink from $current to $REPO_DIR"
  rm "$SKILL_DIR"
elif [ -d "$SKILL_DIR" ]; then
  echo "[WARN] $SKILL_DIR exists as a directory. Backing up to ${SKILL_DIR}.bak"
  mv "$SKILL_DIR" "${SKILL_DIR}.bak"
fi

mkdir -p "$(dirname "$SKILL_DIR")"
ln -s "$REPO_DIR" "$SKILL_DIR"

echo "[OK] Installed: $SKILL_DIR -> $REPO_DIR"
echo
echo "Usage: type '/save-token' in any Cursor agent chat."
