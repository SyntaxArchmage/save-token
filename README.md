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

Verified across **58 independent subagent trials** (5 tasks × 4+ trials per arm):

| Metric | Baseline (n=29) | Optimized (n=29) | Change |
|--------|----------------|------------------|--------|
| Explanation lines | 2.1 | 0.5 | **-76%** |
| Tool calls | 6.5 | 3.9 | **-40%** |
| Code lines | 16.7 | 13.7 | **-18%** |
| Correctness | 100% | 100% | = |

Effect scales with task complexity — simple tasks: -18% tool calls, complex tasks: **-54%**.

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
├── rules/
│   ├── agent-rules.md          # Full behavior ruleset
│   └── save-token.mdc          # Compact Cursor rule (<200 words)
├── scripts/
│   ├── setup.sh                # Headroom proxy install
│   ├── benchmark.sh            # A/B test prompt generator
│   ├── compare.sh              # Results comparison table
│   ├── stats.sh                # Status + metrics display
│   └── learn.sh                # Session waste pattern miner
└── benchmarks/
    ├── prompts/                # 5 preset test prompts
    └── results/                # A/B test output
```

## Installation

Copy or symlink to your Cursor skills directory:

```bash
ln -s /path/to/save-token ~/.cursor/skills/save-token
```

Then use `/save-token` in any agent chat.

## Optional: Headroom Proxy

For system-level compression (60-95% input token reduction):

```bash
/save-token setup
```

Rules work without Headroom — it's an additive optimization.

## How It Compares

| | save-token | Ponytail | Headroom |
|---|---|---|---|
| Layer | Agent behavior rules | Agent behavior rules | System proxy |
| Approach | Code ladder + tool + output | Decision ladder + code diet | Input/output compression |
| Measurement | A/B subagent testing | Manual benchmarks | Automatic perf stats |
| Integration | Cursor skill | Cursor rule | API proxy |
| Unique | 58-trial A/B tested + session learning | Anti-bloat focus | Reversible compression |
