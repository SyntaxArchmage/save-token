# Changelog

## [Unreleased]

### Added
- Windsurf adapter (`adapters/windsurfrules`)
- Lite mode A/B results (110 total trials)
- Token cost calculator (`scripts/cost.sh`) — estimates $/month savings per model
- MIT license
- ASCII visual summary in full-report.md
- Session auto-activation hook (`hooks/session-start.sh` + `hooks.json.example`)
- `compare.sh --json` output mode for scripting
- OS detection in setup.sh (macOS/Linux hints)
- Before/after examples from real A/B trials (`examples/before-after.md`)
- Token estimate section in learn.sh output
- Full mode revalidation (106 total trials)
- Explicit lite mode rules in agent-rules.md
- Claude Code AGENTS.md adapter
- Expanded test suite (31 checks)
- `.gitignore` for test artifacts

### Fixed
- README: correct prompt count (8 not 5), correct ultra trial count

## [0.1.0] — 2026-06-30

### Added
- Core agent rules: code ladder, tool discipline, output economy
- Three intensity levels: lite, full (default), ultra
- SKILL.md command router with 8 commands
- A/B benchmarking with `best-of-n-runner` subagents
- 8 preset benchmark prompts
- 58-trial A/B test results (full mode: -76% explanation, -40% tool calls)
- Mode persistence with history tracking (`mode.sh`)
- Multi-pattern transcript analyzer (`analyze_transcript.py`)
- Session waste auditor (`review.sh`)
- `learn.sh` for historical waste pattern mining
- Headroom proxy setup script
- `.cursorignore` template
- One-command installer with uninstall (`install.sh`)
- `save-token.mdc` compact Cursor rule (<200 words)
- `stats.sh` with context budget estimation
- Quick-reference cheat sheet (`CHEATSHEET.md`)
- Ultra mode: single-expression, no prose, challenge every request
- Model routing guide (fast/mid/premium tiers)
- Auto-dev companion skill
