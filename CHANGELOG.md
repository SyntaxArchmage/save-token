# Changelog

## [Unreleased]

### Added
- **130 total A/B trials** across 12 tasks, 3 intensity levels
- GitHub Copilot adapter (`adapters/copilot-instructions.md`)
- Windsurf adapter (`adapters/windsurfrules`)
- Claude Code AGENTS.md adapter
- Token cost calculator (`scripts/cost.sh`) — estimates $/month savings per model
- Cost estimate in `stats.sh` output
- Session auto-activation hook (`hooks/session-start.sh` + `hooks.json.example`)
- Session scoring in `review.sh` (A+ to F grade)
- Full-read detection and tool stats in transcript analyzer
- `compare.sh --json` output mode for scripting
- OS detection in setup.sh (macOS/Linux hints)
- Before/after examples from real A/B trials (`examples/before-after.md`)
- Token estimate sections in learn.sh and stats.sh
- Explicit lite mode rules in agent-rules.md
- Expanded test suite (42 checks)
- 2 new benchmark prompts (JSON schema validator, CLI todo manager)
- MIT license, ASCII report chart
- `.gitignore` for test artifacts

### Fixed
- README: correct prompt count, correct ultra trial count
- test.sh pipe bug in hook JSON validation

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
