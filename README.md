# save-token

A Cursor skill that minimizes token consumption when using expensive AI models (Opus, o3, etc.) — without sacrificing output quality.

## Quick Start

```
/save-token          # activate (default: full mode)
/save-token ultra    # maximum savings
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

Verified across **120 independent subagent trials** (10 tasks, 3 intensity levels):

| Mode | Explanation | Tool Calls | Code Lines | Correctness |
|------|-------------|------------|------------|-------------|
| **full** (n=58) | **-76%** | **-40%** | -18% | 100% |
| **ultra** (n=42) | **-93%** | **-31%** | **-60%** | 100% |

Effect scales with task complexity — simple tasks: -18%, complex tasks: **-80%**.

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
│   ├── test.sh                 # 31-check test runner
│   └── analyze_transcript.py   # Multi-pattern transcript analyzer
├── adapters/
│   └── AGENTS.md               # Claude Code adapter
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
    ├── prompts/                # 8 preset test prompts
    └── results/                # A/B report (106 trials)
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

## How It Compares

| | save-token | Ponytail | Headroom |
|---|---|---|---|
| Layer | Agent behavior rules | Agent behavior rules | System proxy |
| Approach | Code ladder + tool + output | Decision ladder + code diet | Input/output compression |
| Measurement | A/B subagent testing | Manual benchmarks | Automatic perf stats |
| Integration | Cursor skill | Cursor rule | API proxy |
| Unique | 120-trial A/B tested + session learning | Anti-bloat focus | Reversible compression |
