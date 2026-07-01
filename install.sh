#!/usr/bin/env bash
set -euo pipefail

VERSION="0.4.0"
CONFIG_DIR="${HOME}/.save-token"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

case "${1:-}" in
  -v|--version|version)
    echo "save-token v${VERSION}"
    exit 0
    ;;
  -h|--help|help)
    echo "save-token installer v${VERSION}"
    echo
    echo "Usage: install.sh [mode] [options]"
    echo
    echo "Modes:"
    echo "  light    Rules only — copy adapter to target platform (no scripts)"
    echo "  heavy    Full skill — symlink + all scripts/benchmarks/adapters (default)"
    echo
    echo "Commands:"
    echo "  uninstall  Remove everything"
    echo "  status     Show installation status"
    echo "  version    Show version"
    echo "  help       Show this help"
    echo
    echo "Options:"
    echo "  --platform=cursor|claude-code|codebuddy|generic  Target platform (default: cursor)"
    echo "  --mode=lite|full|ultra  Set initial intensity (default: full)"
    echo "  --density=kernel|mid|full  Rules density variant (default: full)"
    echo "  --hook                  Also install session auto-activation hook (cursor only)"
    echo
    echo "Examples:"
    echo "  bash install.sh                                   # cursor heavy, full intensity"
    echo "  bash install.sh light                             # cursor rules-only"
    echo "  bash install.sh light --platform=claude-code      # AGENTS.md to project root"
    echo "  bash install.sh light --platform=codebuddy        # CodeBuddy rules"
    echo "  bash install.sh heavy --platform=cursor --hook    # full cursor + auto-activation"
    echo "  bash install.sh heavy --mode=ultra"
    exit 0
    ;;
  status)
    echo "╔══════════════════════════════════════╗"
    echo "║     save-token install status        ║"
    echo "╚══════════════════════════════════════╝"
    echo
    found=false
    # Cursor
    SKILL_DIR="${HOME}/.cursor/skills/save-token"
    RULES_DIR="${HOME}/.cursor/rules"
    if [ -L "$SKILL_DIR" ]; then
      target=$(readlink -f "$SKILL_DIR")
      echo "[OK] Cursor (heavy): $SKILL_DIR -> $target"
      found=true
    elif [ -f "$RULES_DIR/save-token.mdc" ]; then
      echo "[OK] Cursor (light): $RULES_DIR/save-token.mdc"
      found=true
    fi
    # Claude Code
    if [ -f "AGENTS.md" ] && grep -q "save-token" "AGENTS.md" 2>/dev/null; then
      echo "[OK] Claude Code: ./AGENTS.md"
      found=true
    fi
    # CodeBuddy
    CB_RULE_DIR="${HOME}/.codebuddy/rules"
    if [ -f "$CB_RULE_DIR/save-token.md" ]; then
      echo "[OK] CodeBuddy (global): $CB_RULE_DIR/save-token.md"
      found=true
    fi
    if [ -f "CODEBUDDY.md" ] && grep -q "save-token" "CODEBUDDY.md" 2>/dev/null; then
      echo "[OK] CodeBuddy (project): ./CODEBUDDY.md"
      found=true
    fi
    if [ -d ".codebuddy/rules" ] && ls .codebuddy/rules/*save-token* >/dev/null 2>&1; then
      echo "[OK] CodeBuddy (project rules): .codebuddy/rules/"
      found=true
    fi
    if [ "$found" = false ]; then
      echo "[--] Not installed on any platform"
    fi
    if [ -f "${CONFIG_DIR}/mode" ]; then
      echo "     Mode: $(cat "${CONFIG_DIR}/mode")"
    else
      echo "     Mode: full (default)"
    fi
    if [ -f "${CONFIG_DIR}/density" ]; then
      echo "     Density: $(cat "${CONFIG_DIR}/density")"
    else
      echo "     Density: full (default)"
    fi
    exit 0
    ;;
  uninstall|remove)
    removed=false
    SKILL_DIR="${HOME}/.cursor/skills/save-token"
    RULES_DIR="${HOME}/.cursor/rules"
    # Cursor
    if [ -L "$SKILL_DIR" ]; then
      rm "$SKILL_DIR"
      echo "[OK] Removed Cursor skill symlink"
      removed=true
    fi
    for f in "$RULES_DIR/save-token.mdc" "$RULES_DIR/save-token-standalone.mdc"; do
      if [ -f "$f" ]; then
        rm "$f"
        echo "[OK] Removed $f"
        removed=true
      fi
    done
    # CodeBuddy global
    CB_RULE="${HOME}/.codebuddy/rules/save-token.md"
    if [ -f "$CB_RULE" ]; then
      rm "$CB_RULE"
      echo "[OK] Removed CodeBuddy global rule"
      removed=true
    fi
    if [ "$removed" = false ]; then
      echo "[--] Not installed (nothing to remove)."
      echo "[TIP] Project-level files (AGENTS.md, CODEBUDDY.md) must be removed manually."
    fi
    exit 0
    ;;
esac

# Parse mode and options
INSTALL_MODE="${1:-heavy}"
shift 2>/dev/null || true

INTENSITY="full"
INSTALL_HOOK=false
PLATFORM="cursor"
DENSITY="full"

for arg in "$@"; do
  case "$arg" in
    --mode=*) INTENSITY="${arg#--mode=}" ;;
    --hook) INSTALL_HOOK=true ;;
    --platform=*) PLATFORM="${arg#--platform=}" ;;
    --density=*) DENSITY="${arg#--density=}" ;;
  esac
done

# Validate intensity
case "$INTENSITY" in
  lite|full|ultra) ;;
  *) echo "[FAIL] Invalid intensity: $INTENSITY. Use lite|full|ultra"; exit 1 ;;
esac

# Validate density
case "$DENSITY" in
  kernel|mid|full) ;;
  *) echo "[FAIL] Invalid density: $DENSITY. Use kernel|mid|full"; exit 1 ;;
esac

rules_file() {
  case "$DENSITY" in
    kernel) echo "$REPO_DIR/rules/agent-rules-kernel.md" ;;
    mid)    echo "$REPO_DIR/rules/agent-rules-mid.md" ;;
    full)   echo "$REPO_DIR/rules/agent-rules.md" ;;
  esac
}

# Validate platform
case "$PLATFORM" in
  cursor|claude-code|codebuddy|generic) ;;
  *) echo "[FAIL] Invalid platform: $PLATFORM. Use cursor|claude-code|codebuddy|generic"; exit 1 ;;
esac

mkdir -p "$CONFIG_DIR"

# --- Platform-specific installation functions ---

install_cursor_light() {
  RULES_DIR="${HOME}/.cursor/rules"
  mkdir -p "$RULES_DIR"
  cp "$REPO_DIR/adapters/standalone.mdc" "$RULES_DIR/save-token.mdc"
  echo "[OK] Installed: $RULES_DIR/save-token.mdc"
  echo "     Active on every response. Say 'save-token off' to deactivate."
}

install_cursor_heavy() {
  SKILL_DIR="${HOME}/.cursor/skills/save-token"
  mkdir -p "$(dirname "$SKILL_DIR")"
  if [ -L "$SKILL_DIR" ]; then
    current=$(readlink -f "$SKILL_DIR")
    if [ "$current" = "$REPO_DIR" ]; then
      echo "[OK] Skill symlink already exists."
    else
      echo "[..] Updating symlink from $current"
      rm "$SKILL_DIR"
      ln -s "$REPO_DIR" "$SKILL_DIR"
    fi
  elif [ -d "$SKILL_DIR" ]; then
    echo "[WARN] $SKILL_DIR exists as directory. Backing up."
    mv "$SKILL_DIR" "${SKILL_DIR}.bak"
    ln -s "$REPO_DIR" "$SKILL_DIR"
  else
    ln -s "$REPO_DIR" "$SKILL_DIR"
  fi
  echo "[OK] Installed: $SKILL_DIR -> $REPO_DIR"
  echo "     Use: /save-token in any Cursor agent chat"

  if [ "$INSTALL_HOOK" = true ]; then
    HOOKS_FILE="${HOME}/.cursor/hooks.json"
    if [ ! -f "$HOOKS_FILE" ]; then
      cp "$REPO_DIR/hooks/hooks.json.example" "$HOOKS_FILE"
      echo "[OK] Session hook installed: $HOOKS_FILE"
    else
      echo "[SKIP] hooks.json already exists. Merge manually from hooks/hooks.json.example"
    fi
  fi
}

install_claude_code_light() {
  TARGET="${PWD}/AGENTS.md"
  if [ -f "$TARGET" ]; then
    echo "[WARN] AGENTS.md already exists. Backing up to AGENTS.md.bak"
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/AGENTS.md" "$TARGET"
  echo "[OK] Installed: ./AGENTS.md"
  echo "     Claude Code will load rules from project root."
}

install_claude_code_heavy() {
  install_claude_code_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
  echo "     Run: bash $REPO_DIR/scripts/mode.sh [lite|full|ultra|off]"
}

install_codebuddy_light() {
  # Global rule: ~/.codebuddy/rules/save-token.md
  CB_RULES="${HOME}/.codebuddy/rules"
  mkdir -p "$CB_RULES"
  cp "$REPO_DIR/adapters/codebuddy-rule.md" "$CB_RULES/save-token.md"
  echo "[OK] Installed: $CB_RULES/save-token.md (global, all projects)"
  echo "     Alternatively, copy to .codebuddy/rules/save-token.md in a project."
}

install_codebuddy_heavy() {
  install_codebuddy_light
  # Also install CODEBUDDY.md to current project if in a project directory
  if [ -d ".git" ] || [ -f "package.json" ] || [ -f "pyproject.toml" ]; then
    if [ ! -f "CODEBUDDY.md" ]; then
      cp "$REPO_DIR/adapters/CODEBUDDY.md" "./CODEBUDDY.md"
      echo "[OK] Installed: ./CODEBUDDY.md (project-level context)"
    else
      echo "[SKIP] CODEBUDDY.md already exists in project."
    fi
  fi
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_generic_light() {
  echo "[OK] Generic adapter: $REPO_DIR/adapters/system-prompt.txt"
  echo "     Paste into your system prompt, or use pre-prompt.sh:"
  echo ""
  echo '     echo "your prompt" | bash '"$REPO_DIR/adapters/pre-prompt.sh"' | your-cli-tool'
  echo ""
  echo "     Works with any LLM CLI: claude, codebuddy, openai, llm, etc."
}

install_generic_heavy() {
  install_generic_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
  echo "     Run: bash $REPO_DIR/scripts/mode.sh [lite|full|ultra|off]"
}

# --- Execute installation ---

echo "Installing save-token v${VERSION} (${INSTALL_MODE} mode, platform: ${PLATFORM})..."
echo

case "$INSTALL_MODE" in
  light)
    case "$PLATFORM" in
      cursor)      install_cursor_light ;;
      claude-code) install_claude_code_light ;;
      codebuddy)   install_codebuddy_light ;;
      generic)     install_generic_light ;;
    esac
    ;;
  heavy|"")
    case "$PLATFORM" in
      cursor)      install_cursor_heavy ;;
      claude-code) install_claude_code_heavy ;;
      codebuddy)   install_codebuddy_heavy ;;
      generic)     install_generic_heavy ;;
    esac
    ;;
  *)
    echo "[FAIL] Unknown mode: $INSTALL_MODE. Use 'light' or 'heavy'."
    exit 1
    ;;
esac

echo "$INTENSITY" > "$CONFIG_DIR/mode"
echo "$DENSITY" > "$CONFIG_DIR/density"
echo
echo "     Platform: $PLATFORM"
echo "     Intensity: $INTENSITY"
echo "     Density: $DENSITY ($(wc -w < "$(rules_file)") words)"
echo "     Config: $CONFIG_DIR/"
