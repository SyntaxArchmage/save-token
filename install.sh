#!/usr/bin/env bash
set -euo pipefail

VERSION="0.6.0"
CONFIG_DIR="${SAVE_TOKEN_DIR:-${HOME}/.save-token}"
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
    echo "  --platform=PLATFORM  Target platform (default: cursor)"
    echo "    Platforms: cursor, claude-code, codebuddy, augment, roo-code,"
    echo "    kilo-code, opencode, pi-agent, aider, gemini-cli, cline, windsurf,"
    echo "    copilot, generic"
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
    # Augment Code
    if [ -f ".augment/rules/save-token.md" ]; then
      echo "[OK] Augment Code: .augment/rules/save-token.md"
      found=true
    fi
    # Roo Code
    if [ -f ".roo/rules/save-token.md" ]; then
      echo "[OK] Roo Code: .roo/rules/save-token.md"
      found=true
    fi
    # Kilo Code
    if [ -f ".kilo/rules/save-token.md" ]; then
      echo "[OK] Kilo Code: .kilo/rules/save-token.md"
      found=true
    fi
    # Cline / Trae
    if [ -f ".clinerules" ] && grep -q "save-token" ".clinerules" 2>/dev/null; then
      echo "[OK] Cline/Trae: ./.clinerules"
      found=true
    fi
    # Windsurf
    if [ -f ".windsurfrules" ] && grep -q "save-token" ".windsurfrules" 2>/dev/null; then
      echo "[OK] Windsurf: ./.windsurfrules"
      found=true
    fi
    # GitHub Copilot
    if [ -f ".github/copilot-instructions.md" ] && grep -q "save-token" ".github/copilot-instructions.md" 2>/dev/null; then
      echo "[OK] GitHub Copilot: .github/copilot-instructions.md"
      found=true
    fi
    # AGENTS.md (OpenCode, Pi Agent, Aider, Gemini CLI)
    if [ -f "AGENTS.md" ] && grep -q "save-token" "AGENTS.md" 2>/dev/null; then
      echo "[OK] AGENTS.md (Claude Code, OpenCode, Pi Agent, Aider, Gemini CLI, etc.)"
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
    if [ -f "${CONFIG_DIR}/tokens.log" ] && [ -s "${CONFIG_DIR}/tokens.log" ]; then
      entries=$(wc -l < "${CONFIG_DIR}/tokens.log")
      echo "     Token log: ${entries} entries"
    else
      echo "     Token log: empty (use: tokens.sh log INPUT OUTPUT)"
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
    # Project-level files
    for pf in ".augment/rules/save-token.md" ".roo/rules/save-token.md" ".kilo/rules/save-token.md" ".clinerules" ".windsurfrules"; do
      if [ -f "$pf" ] && grep -q "save-token" "$pf" 2>/dev/null; then
        rm "$pf"
        echo "[OK] Removed $pf"
        removed=true
      fi
    done
    if [ "$removed" = false ]; then
      echo "[--] Not installed (nothing to remove)."
      echo "[TIP] Project-level files (AGENTS.md, CODEBUDDY.md, .github/copilot-instructions.md) must be removed manually."
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
  cursor|claude-code|codebuddy|augment|roo-code|kilo-code|opencode|pi-agent|aider|gemini-cli|cline|windsurf|copilot|generic) ;;
  *) echo "[FAIL] Invalid platform: $PLATFORM"; echo "  Use: cursor|claude-code|codebuddy|augment|roo-code|kilo-code|opencode|pi-agent|aider|gemini-cli|cline|windsurf|copilot|generic"; exit 1 ;;
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

install_augment_light() {
  local RULES_DIR="${PWD}/.augment/rules"
  mkdir -p "$RULES_DIR"
  cp "$REPO_DIR/adapters/augment-rules.md" "$RULES_DIR/save-token.md"
  echo "[OK] Installed: $RULES_DIR/save-token.md"
  echo "     Augment Code will auto-apply on every prompt."
}

install_augment_heavy() {
  install_augment_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_roo_code_light() {
  local RULES_DIR="${PWD}/.roo/rules"
  mkdir -p "$RULES_DIR"
  cp "$REPO_DIR/adapters/roo-rules.md" "$RULES_DIR/save-token.md"
  echo "[OK] Installed: $RULES_DIR/save-token.md"
  echo "     Roo Code / Zoo Code will auto-apply on every prompt."
}

install_roo_code_heavy() {
  install_roo_code_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_kilo_code_light() {
  local RULES_DIR="${PWD}/.kilo/rules"
  mkdir -p "$RULES_DIR"
  cp "$REPO_DIR/adapters/kilo-rules.md" "$RULES_DIR/save-token.md"
  echo "[OK] Installed: $RULES_DIR/save-token.md"
  echo "     Add to kilo.jsonc: {\"instructions\": [\".kilo/rules/save-token.md\"]}"
}

install_kilo_code_heavy() {
  install_kilo_code_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_opencode_light() {
  install_claude_code_light
  echo "     OpenCode auto-discovers AGENTS.md from project root."
}

install_opencode_heavy() {
  install_opencode_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_pi_agent_light() {
  install_claude_code_light
  echo "     Pi Agent auto-discovers AGENTS.md. Run /reload after install."
}

install_pi_agent_heavy() {
  install_pi_agent_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_aider_light() {
  local TARGET="${PWD}/AGENTS.md"
  if [ -f "$TARGET" ]; then
    echo "[WARN] AGENTS.md already exists. Backing up to AGENTS.md.bak"
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/AGENTS.md" "$TARGET"
  echo "[OK] Installed: ./AGENTS.md"
  echo "     Aider reads AGENTS.md natively."
  echo "     Or add to .aider.conf.yml: read: AGENTS.md"
}

install_aider_heavy() {
  install_aider_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_gemini_cli_light() {
  install_claude_code_light
  echo "     Gemini CLI auto-discovers AGENTS.md."
  echo "     Or add to .gemini/settings.json: {\"context\":{\"fileName\":[\"AGENTS.md\"]}}"
}

install_gemini_cli_heavy() {
  install_gemini_cli_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_cline_light() {
  local TARGET="${PWD}/.clinerules"
  if [ -f "$TARGET" ]; then
    echo "[WARN] .clinerules already exists. Backing up."
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/clinerules" "$TARGET"
  echo "[OK] Installed: ./.clinerules"
  echo "     Cline / Trae will auto-apply rules."
}

install_cline_heavy() {
  install_cline_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_windsurf_light() {
  local TARGET="${PWD}/.windsurfrules"
  if [ -f "$TARGET" ]; then
    echo "[WARN] .windsurfrules already exists. Backing up."
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/windsurfrules" "$TARGET"
  echo "[OK] Installed: ./.windsurfrules"
}

install_windsurf_heavy() {
  install_windsurf_light
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_copilot_light() {
  local TARGET="${PWD}/.github/copilot-instructions.md"
  mkdir -p "${PWD}/.github"
  if [ -f "$TARGET" ]; then
    echo "[WARN] copilot-instructions.md already exists. Backing up."
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/copilot-instructions.md" "$TARGET"
  echo "[OK] Installed: .github/copilot-instructions.md"
}

install_copilot_heavy() {
  install_copilot_light
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
      augment)     install_augment_light ;;
      roo-code)    install_roo_code_light ;;
      kilo-code)   install_kilo_code_light ;;
      opencode)    install_opencode_light ;;
      pi-agent)    install_pi_agent_light ;;
      aider)       install_aider_light ;;
      gemini-cli)  install_gemini_cli_light ;;
      cline)       install_cline_light ;;
      windsurf)    install_windsurf_light ;;
      copilot)     install_copilot_light ;;
      generic)     install_generic_light ;;
    esac
    ;;
  heavy|"")
    case "$PLATFORM" in
      cursor)      install_cursor_heavy ;;
      claude-code) install_claude_code_heavy ;;
      codebuddy)   install_codebuddy_heavy ;;
      augment)     install_augment_heavy ;;
      roo-code)    install_roo_code_heavy ;;
      kilo-code)   install_kilo_code_heavy ;;
      opencode)    install_opencode_heavy ;;
      pi-agent)    install_pi_agent_heavy ;;
      aider)       install_aider_heavy ;;
      gemini-cli)  install_gemini_cli_heavy ;;
      cline)       install_cline_heavy ;;
      windsurf)    install_windsurf_heavy ;;
      copilot)     install_copilot_heavy ;;
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
if [ "$INSTALL_MODE" = "heavy" ]; then
  # Auto-install headroom for compression (default engine, pure software, no API keys)
  if python3 -c "import headroom" 2>/dev/null; then
    echo "     Compression: headroom (already installed)"
  else
    echo
    echo "Installing headroom (default compression engine, 40-95% token reduction)..."
    if pip install headroom-ai 2>/dev/null; then
      echo "[OK] headroom installed — compression active for code, text, JSON, logs, diffs, HTML, search"
    else
      echo "[SKIP] headroom install failed (optional). Zero-dep engines (truncate, pointer) will be used."
      echo "       Retry later: pip install headroom-ai"
    fi
  fi
  echo
  echo "Key commands:"
  echo "  /save-token              Activate rules"
  echo "  /save-token cost [model] Estimate savings"
  echo "  /save-token tokens       Track real token usage"
  echo "  /save-token compress     Content-type-aware compression"
fi
