# save-token

![Tests](https://img.shields.io/badge/tests-55%2B%20passing-brightgreen)
![Trials](https://img.shields.io/badge/A%2FB%20trials-200-blue)
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

Verified across **200 independent subagent trials** (16 tasks, 3 intensity levels):

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
├── install.sh                  # One-command installer (+uninstall)
├── rules/
│   ├── agent-rules.md          # Full behavior ruleset (lite/full/ultra)
│   └── save-token.mdc          # Compact Cursor rule (<200 words)
├── scripts/
│   ├── setup.sh                # Headroom proxy install (OS-aware)
│   ├── benchmark.sh            # A/B test prompt generator
│   ├── compare.sh              # Results table (+ --json mode)
│   ├── stats.sh                # Status + context budget + history
│   ├── learn.sh                # Session waste + token estimation
│   ├── review.sh               # Real-time session audit
│   ├── mode.sh                 # Mode persistence + history
│   ├── cost.sh                 # Cost savings estimator (200-trial calibrated)
│   ├── test.sh                 # 55+-check test runner
│   └── analyze_transcript.py   # Transcript analyzer (+ --html report)
├── adapters/
│   ├── AGENTS.md               # Claude Code adapter
│   ├── windsurfrules           # Windsurf adapter
│   └── copilot-instructions.md # GitHub Copilot adapter
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
    └── results/                # A/B report (200 trials)
```

## Installation

```bash
git clone https://github.com/YOUR_USER/save-token.git
cd save-token && bash install.sh
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

- **Cursor** with Agent mode (CLI or Desktop)
- **bash** + **python3** (for learn/review/stats scripts)
- **git** (optional, for install.sh)
- **Headroom** (optional, for system-level compression)

## Compatibility

| Platform | Status |
|----------|--------|
| Cursor CLI (Linux/macOS) | Tested |
| Cursor Desktop | Tested |
| Claude Code | Partial (rules work, scripts need adaptation) |
| Other AI IDEs | Rules portable, scripts Cursor-specific |

## Adapters (Other AI IDEs)

| Platform | File | How |
|----------|------|-----|
| **Any Cursor (standalone)** | `adapters/standalone.mdc` | Copy to `.cursor/rules/` — zero-install, no skill needed |
| **Claude Code** | `adapters/AGENTS.md` | Copy to project root as `AGENTS.md` |
| **Windsurf** | `adapters/windsurfrules` | Copy to project root as `.windsurfrules` |
| **GitHub Copilot** | `adapters/copilot-instructions.md` | Copy to `.github/copilot-instructions.md` |

## Auto-Activation (Cursor Hook)

Optionally activate save-token automatically on every new chat:

```bash
cp hooks/hooks.json.example ~/.cursor/hooks.json
```

Or merge the `sessionStart` entry into your existing `hooks.json`.

## FAQ

**Does this affect code quality?**
No. 200 A/B trials show zero correctness regressions. The rules cut waste (verbose explanations, redundant reads, over-engineered features), not essential logic.

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
| Unique | 200-trial A/B tested + session learning | Anti-bloat focus | Reversible compression |
