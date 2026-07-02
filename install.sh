#!/usr/bin/env bash
set -euo pipefail

VERSION="0.7.0"
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
    echo "Usage: bash install.sh [--platform=PLATFORM] [options]"
    echo
    echo "Installs save-token: adapter + scripts + compression engines."
    echo "Default: Cursor platform, full intensity, all available engines."
    echo
    echo "Platforms:"
    echo "  cursor (default), claude-code, codebuddy, augment, roo-code,"
    echo "  kilo-code, opencode, pi-agent, aider, gemini-cli, cline,"
    echo "  windsurf, copilot, generic"
    echo
    echo "Options:"
    echo "  --platform=PLATFORM       Target platform"
    echo "  --mode=lite|full|ultra    Intensity (default: full)"
    echo "  --density=kernel|mid|full Rules density (default: full)"
    echo "  --hook                    Auto-activation hook (cursor only)"
    echo
    echo "Commands:"
    echo "  status     Show what's installed"
    echo "  uninstall  Remove everything"
    echo "  version    Show version"
    echo
    echo "Examples:"
    echo "  bash install.sh                            # just works"
    echo "  bash install.sh --platform=claude-code     # Claude Code"
    echo "  bash install.sh --hook                     # cursor + auto-activation"
    echo "  bash install.sh --mode=ultra               # ultra intensity"
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
      echo "[OK] Cursor: $SKILL_DIR -> $target"
      found=true
    elif [ -f "$RULES_DIR/save-token.mdc" ]; then
      echo "[OK] Cursor (standalone rule): $RULES_DIR/save-token.mdc"
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
    # Engine status
    engines=""
    python3 -c "import headroom" 2>/dev/null && engines="${engines} headroom"
    python3 -c "from llmlingua import PromptCompressor" 2>/dev/null && engines="${engines} llmlingua"
    engines="${engines} treesitter(regex) truncate pointer none"
    echo "     Engines: ${engines# }"
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
    fi
    echo "[TIP] Shared project files (AGENTS.md, CODEBUDDY.md, .github/copilot-instructions.md) must be removed manually."
    exit 0
    ;;
esac

# Parse options
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
    --*) ;;
    *) ;; # ignore positional args (backward compat: old 'heavy' arg)
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

install_cursor() {
  SKILL_DIR="${HOME}/.cursor/skills/save-token"
  mkdir -p "$(dirname "$SKILL_DIR")"

  # If repo IS the skill dir (or resolves to it), skip symlink
  local real_repo real_skill
  real_repo="$(cd "$REPO_DIR" && pwd -P)"
  if [ -d "$SKILL_DIR" ] && [ ! -L "$SKILL_DIR" ]; then
    real_skill="$(cd "$SKILL_DIR" && pwd -P)"
    if [ "$real_repo" = "$real_skill" ]; then
      echo "[OK] Repo is already at $SKILL_DIR (no symlink needed)."
      echo "     Use: /save-token in any Cursor agent chat"
      return
    fi
  fi

  if [ -L "$SKILL_DIR" ]; then
    current=$(readlink "$SKILL_DIR")
    # Prevent self-referencing symlink
    if [ "$current" = "$SKILL_DIR" ]; then
      rm "$SKILL_DIR"
      ln -s "$REPO_DIR" "$SKILL_DIR"
    elif [ "$(readlink -f "$SKILL_DIR" 2>/dev/null)" = "$real_repo" ]; then
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

install_agents_md() {
  local TARGET="${PWD}/AGENTS.md"
  if [ -f "$TARGET" ]; then
    echo "[WARN] AGENTS.md already exists. Backing up to AGENTS.md.bak"
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/AGENTS.md" "$TARGET"
  echo "[OK] Installed: ./AGENTS.md"
}

install_claude_code() {
  install_agents_md
  echo "     Claude Code will load rules from project root."
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
  echo "     Run: bash $REPO_DIR/scripts/mode.sh [lite|full|ultra|off]"
}

install_codebuddy() {
  CB_RULES="${HOME}/.codebuddy/rules"
  mkdir -p "$CB_RULES"
  cp "$REPO_DIR/adapters/codebuddy-rule.md" "$CB_RULES/save-token.md"
  echo "[OK] Installed: $CB_RULES/save-token.md (global, all projects)"
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

install_augment() {
  local RULES_DIR="${PWD}/.augment/rules"
  mkdir -p "$RULES_DIR"
  cp "$REPO_DIR/adapters/augment-rules.md" "$RULES_DIR/save-token.md"
  echo "[OK] Installed: $RULES_DIR/save-token.md"
  echo "     Augment Code will auto-apply on every prompt."
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_roo_code() {
  local RULES_DIR="${PWD}/.roo/rules"
  mkdir -p "$RULES_DIR"
  cp "$REPO_DIR/adapters/roo-rules.md" "$RULES_DIR/save-token.md"
  echo "[OK] Installed: $RULES_DIR/save-token.md"
  echo "     Roo Code / Zoo Code will auto-apply on every prompt."
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_kilo_code() {
  local RULES_DIR="${PWD}/.kilo/rules"
  mkdir -p "$RULES_DIR"
  cp "$REPO_DIR/adapters/kilo-rules.md" "$RULES_DIR/save-token.md"
  echo "[OK] Installed: $RULES_DIR/save-token.md"
  echo "     Add to kilo.jsonc: {\"instructions\": [\".kilo/rules/save-token.md\"]}"
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_opencode() {
  install_agents_md
  echo "     OpenCode auto-discovers AGENTS.md from project root."
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_pi_agent() {
  install_agents_md
  echo "     Pi Agent auto-discovers AGENTS.md. Run /reload after install."
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_aider() {
  install_agents_md
  echo "     Aider reads AGENTS.md natively."
  echo "     Or add to .aider.conf.yml: read: AGENTS.md"
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_gemini_cli() {
  install_agents_md
  echo "     Gemini CLI auto-discovers AGENTS.md."
  echo "     Or add to .gemini/settings.json: {\"context\":{\"fileName\":[\"AGENTS.md\"]}}"
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_cline() {
  local TARGET="${PWD}/.clinerules"
  if [ -f "$TARGET" ]; then
    echo "[WARN] .clinerules already exists. Backing up."
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/clinerules" "$TARGET"
  echo "[OK] Installed: ./.clinerules"
  echo "     Cline / Trae will auto-apply rules."
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_windsurf() {
  local TARGET="${PWD}/.windsurfrules"
  if [ -f "$TARGET" ]; then
    echo "[WARN] .windsurfrules already exists. Backing up."
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/windsurfrules" "$TARGET"
  echo "[OK] Installed: ./.windsurfrules"
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_copilot() {
  local TARGET="${PWD}/.github/copilot-instructions.md"
  mkdir -p "${PWD}/.github"
  if [ -f "$TARGET" ]; then
    echo "[WARN] copilot-instructions.md already exists. Backing up."
    cp "$TARGET" "${TARGET}.bak"
  fi
  cp "$REPO_DIR/adapters/copilot-instructions.md" "$TARGET"
  echo "[OK] Installed: .github/copilot-instructions.md"
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
}

install_generic() {
  echo "[OK] Generic adapter: $REPO_DIR/adapters/system-prompt.txt"
  echo "     Paste into your system prompt, or use pre-prompt.sh:"
  echo ""
  echo '     echo "your prompt" | bash '"$REPO_DIR/adapters/pre-prompt.sh"' | your-cli-tool'
  echo ""
  echo "     Works with any LLM CLI: claude, codebuddy, openai, llm, etc."
  echo "[OK] Scripts available at: $REPO_DIR/scripts/"
  echo "     Run: bash $REPO_DIR/scripts/mode.sh [lite|full|ultra|off]"
}

# --- Execute installation ---

echo "Installing save-token v${VERSION} (platform: ${PLATFORM})..."
echo

case "$PLATFORM" in
  cursor)      install_cursor ;;
  claude-code) install_claude_code ;;
  codebuddy)   install_codebuddy ;;
  augment)     install_augment ;;
  roo-code)    install_roo_code ;;
  kilo-code)   install_kilo_code ;;
  opencode)    install_opencode ;;
  pi-agent)    install_pi_agent ;;
  aider)       install_aider ;;
  gemini-cli)  install_gemini_cli ;;
  cline)       install_cline ;;
  windsurf)    install_windsurf ;;
  copilot)     install_copilot ;;
  generic)     install_generic ;;
esac

echo "$INTENSITY" > "$CONFIG_DIR/mode"
echo "$DENSITY" > "$CONFIG_DIR/density"
echo
echo "     Platform: $PLATFORM"
echo "     Intensity: $INTENSITY"
echo "     Density: $DENSITY ($(wc -w < "$(rules_file)") words)"
echo "     Config: $CONFIG_DIR/"

# --- Auto-install compression engines ---
echo
echo "Installing compression engines..."

# headroom: default engine for most content types (40-95% reduction, local ONNX)
if python3 -c "import headroom" 2>/dev/null; then
  echo "  [OK] headroom (already installed)"
else
  if pip install headroom-ai 2>/dev/null; then
    echo "  [OK] headroom installed"
  else
    echo "  [--] headroom failed (optional). Retry: pip install headroom-ai"
  fi
fi

# llmlingua: perplexity-based NL pruning for text (30-70% reduction)
if python3 -c "from llmlingua import PromptCompressor" 2>/dev/null; then
  echo "  [OK] llmlingua (already installed)"
else
  if pip install llmlingua 2>/dev/null; then
    echo "  [OK] llmlingua installed (model downloads on first use)"
  else
    echo "  [--] llmlingua failed (optional). Retry: pip install llmlingua"
  fi
fi

# treesitter: comment/whitespace stripping for code (regex fallback always works)
if command -v tree-sitter &>/dev/null; then
  echo "  [OK] tree-sitter-cli (already installed)"
else
  echo "  [OK] treesitter (regex fallback active; install tree-sitter-cli for full AST mode)"
fi

# Built-in engines always available
echo "  [OK] truncate, pointer, none (built-in, zero deps)"

echo
echo "Key commands:"
echo "  /save-token              Activate rules"
echo "  /save-token cost [model] Estimate savings"
echo "  /save-token tokens       Track real token usage"
echo "  /save-token compress     Content-type-aware compression"
