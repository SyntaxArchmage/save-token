# save-token

![Tests](https://img.shields.io/badge/tests-134%20passing-brightgreen)
![Trials](https://img.shields.io/badge/A%2FB%20trials-216-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A Cursor skill that minimizes token consumption when using expensive AI models (Opus, o3, etc.) — without sacrificing output quality.

## 60-Second Start

**Zero-install (standalone rule only):**
```bash
curl -o ~/.cursor/rules/save-token.mdc \
  https://raw.githubusercontent.com/YOUR_USER/save-token/main/adapters/standalone.mdc
```
Done. Works immediately, no scripts needed.

**Full install (scripts + benchmarks + adapters):**
```bash
git clone https://github.com/YOUR_USER/save-token.git
cd save-token && bash install.sh

# Use in any Cursor chat:
/save-token          # activate (default: full mode)
/save-token ultra    # maximum savings
/save-token stats    # see mode + cost estimate
/save-token off      # deactivate
```

## What It Does

Enforces a **three-layer optimization** every response:

| Layer | What | How |
|-------|------|-----|
| **Code Ladder** | Prevents over-engineering | 7-rung decision ladder: YAGNI → reuse → stdlib → minimal |
| **Tool Discipline** | Reduces tool call waste | Batch calls, surgical reads, no re-reads, grep-first |
| **Output Economy** | Cuts verbose prose | No preamble, code references, diff-sized edits, 3-line max |

## A/B Tested Results

Verified across **216 independent subagent trials** (16 tasks, 3 intensity levels):

| Mode | Code | Explanation | Tool Calls | Correctness |
|------|------|-------------|------------|-------------|
| **lite** | -16% | **-33%** | -20% | 100% |
| **full** | -24% | **-75%** | **-34%** | 100% |
| **ultra** | **-51%** | **-93%** | **-39%** | 100% |

Effect scales with task complexity — simple tasks: -16%, complex tasks: **-51%+**.

See [benchmarks/results/full-report.md](benchmarks/results/full-report.md) for per-task breakdowns.

## Commands

| Command | Action |
|---------|--------|
| `/save-token` | Show mode + help |
| `/save-token setup` | Install Headroom proxy |
| `/save-token lite\|full\|ultra` | Switch intensity |
| `/save-token off` | Deactivate |
| `/save-token bench [prompt]` | A/B test with subagents |
| `/save-token stats` | Show savings statistics |
| `/save-token learn` | Mine past sessions for waste |
| `/save-token review` | Audit current session |
| `/save-token cost [model]` | Estimate $/month savings |
| `/save-token tokens` | Track real token usage |
| `/save-token compress [file]` | Content-type-aware compression |
| `/save-token config` | Team config (show/apply/init) |
| `/save-token progress` | Progressive activation status |
| `/save-token quality` | Dev quality benchmarks (correctness + quality) |

## Intensity Levels

| Level | Code Ladder | Tool Discipline | Output Economy |
|-------|-------------|-----------------|----------------|
| **lite** | Suggested | Enforced | Enforced |
| **full** | Enforced | Enforced | Enforced |
| **ultra** | Extremist | Enforced | Extremist |

## File Structure

```
save-token/
├── SKILL.md                    # Entry point (Cursor reads this)
├── CHEATSHEET.md               # Quick-reference card
├── install.sh                  # Multi-platform installer (+uninstall, --density)
├── rules/
│   ├── agent-rules.md          # Full behavior ruleset (1123 words)
│   ├── agent-rules-mid.md      # Mid-density variant (368 words)
│   └── agent-rules-kernel.md   # Kernel variant (177 words, for alwaysApply)
├── scripts/
│   ├── compress.sh             # Content-type-aware compression pipeline
│   ├── engines/                # Compression engines (7: none, truncate, pointer, treesitter, llmlingua, claw, headroom)
│   ├── setup.sh                # Headroom proxy install (OS-aware)
│   ├── benchmark.sh            # A/B test prompt generator
│   ├── compare.sh              # Results table (+ --json, --markdown, --fail-if-regression)
│   ├── stats.sh                # Status + context budget + history
│   ├── learn.sh                # Session waste + verbosity profiling
│   ├── review.sh               # Real-time session audit
│   ├── mode.sh                 # Mode persistence + history
│   ├── cost.sh                 # Cost savings estimator (real data + 216-trial fallback)
│   ├── tokens.sh               # Real token tracking (multi-platform)
│   ├── load-config.sh          # Team config loader (3-level precedence)
│   ├── progress.sh             # Progressive activation tracker
│   ├── export-promptfoo.sh     # promptfoo config generator
│   ├── quality-bench.sh        # Dev quality benchmark runner (correctness + quality)
│   ├── test.sh                 # 134-check test runner
│   └── analyze_transcript.py   # Transcript analyzer (+ --html report)
├── adapters/
│   ├── standalone.mdc          # Cursor standalone rule (zero-install)
│   ├── AGENTS.md               # Claude Code adapter
│   ├── CODEBUDDY.md            # CodeBuddy project adapter
│   ├── codebuddy-rule.md       # CodeBuddy global rule
│   ├── windsurfrules           # Windsurf adapter
│   ├── copilot-instructions.md # GitHub Copilot adapter
│   ├── system-prompt.txt       # Generic LLM system prompt
│   └── pre-prompt.sh           # CLI pre-prompt injector
├── hooks/
│   ├── session-start.sh        # Auto-activate hook
│   └── hooks.json.example      # Hook config template
├── templates/
│   └── cursorignore            # Recommended .cursorignore
├── examples/
│   └── before-after.md         # Real A/B output comparisons
├── skills/
│   └── auto-dev-SKILL.md       # Companion auto-dev skill
└── benchmarks/
    ├── prompts/                # 20 preset test prompts
    └── results/                # A/B reports + P1/P4 analysis
```

## Installation

```bash
git clone https://github.com/YOUR_USER/save-token.git
cd save-token && bash install.sh                           # Cursor, full density
bash install.sh --platform=claude-code                     # Claude Code
bash install.sh --platform=codebuddy                       # CodeBuddy
bash install.sh --density=kernel                           # Minimal rules (177 words)
bash install.sh light --platform=generic                   # Generic CLI, rules only
```

Or manually symlink: `ln -s /path/to/save-token ~/.cursor/skills/save-token`

Then use `/save-token` in any agent chat.

## Optional: Headroom Proxy

For system-level compression (60-95% input token reduction):

```bash
/save-token setup
```

Rules work without Headroom — it's an additive optimization.

## Requirements

- **bash** + **python3** (for learn/review/stats scripts)
- **git** (optional, for install.sh)
- **Headroom** (optional, for system-level compression)

## Compatibility

| Platform | Status | Install |
|----------|--------|---------|
| Cursor CLI (Linux/macOS) | Tested | `install.sh --platform=cursor` |
| Cursor Desktop | Tested | `install.sh --platform=cursor` |
| Claude Code | Tested | `install.sh --platform=claude-code` |
| CodeBuddy IDE/CLI | Tested | `install.sh --platform=codebuddy` |
| Generic CLI (any LLM) | Tested | `install.sh --platform=generic` |
| Windsurf | Rules only | Copy `adapters/windsurfrules` |
| GitHub Copilot | Rules only | Copy `adapters/copilot-instructions.md` |

## Adapters

| Platform | File | How |
|----------|------|-----|
| **Cursor (standalone)** | `adapters/standalone.mdc` | Copy to `.cursor/rules/` — zero-install |
| **Claude Code** | `adapters/AGENTS.md` | Copy to project root as `AGENTS.md` |
| **CodeBuddy (global)** | `adapters/codebuddy-rule.md` | Copy to `~/.codebuddy/rules/save-token.md` |
| **CodeBuddy (project)** | `adapters/CODEBUDDY.md` | Copy to project root |
| **Windsurf** | `adapters/windsurfrules` | Copy to project root as `.windsurfrules` |
| **GitHub Copilot** | `adapters/copilot-instructions.md` | Copy to `.github/copilot-instructions.md` |
| **Generic (any LLM)** | `adapters/system-prompt.txt` | Paste into system prompt, or use `pre-prompt.sh` |

## Auto-Activation (Cursor Hook)

Optionally activate save-token automatically on every new chat:

```bash
cp hooks/hooks.json.example ~/.cursor/hooks.json
```

Or merge the `sessionStart` entry into your existing `hooks.json`.

## FAQ

**Does this affect code quality?**
No. 216 A/B trials show zero correctness regressions. The rules cut waste (verbose explanations, redundant reads, over-engineered features), not essential logic.

**Which mode should I use?**
Start with `full` (default). Switch to `ultra` for boilerplate/simple tasks. Use `lite` if you want gentle hints without strict enforcement.

**Does Headroom require an API key?**
Headroom is optional and separate. save-token works purely through behavior rules — no proxy needed.

**Can I use this without Cursor?**
Yes — copy the adapter file for your IDE (Claude Code, Windsurf, GitHub Copilot). The core rules are IDE-agnostic.

**How do I verify it's working?**
Run `/save-token review` mid-session to get a waste score (A+ to F). Run `/save-token stats` for cost estimates.

## How It Compares

| | save-token | Ponytail | Headroom |
|---|---|---|---|
| Layer | Agent behavior rules | Agent behavior rules | System proxy |
| Approach | Code ladder + tool + output | Decision ladder + code diet | Input/output compression |
| Measurement | A/B subagent testing | Manual benchmarks | Automatic perf stats |
| Integration | Cursor skill | Cursor rule | API proxy |
| Unique | 216-trial A/B tested + real token tracking | Anti-bloat focus | Reversible compression |
