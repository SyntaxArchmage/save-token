# Changelog

## [0.2.0] — 2026-06-30

### Added
- **200 total A/B trials** across 16 tasks, 3 intensity levels
- 4-way aggregate table (baseline/lite/full/ultra) in full report
- GitHub Copilot adapter (`adapters/copilot-instructions.md`)
- Windsurf adapter (`adapters/windsurfrules`)
- Claude Code AGENTS.md adapter
- Token cost calculator (`scripts/cost.sh`) — 200-trial calibrated
- Cost estimate in `stats.sh` output
- Session auto-activation hook (`hooks/session-start.sh` + `hooks.json.example`)
- Session scoring in `review.sh` (A+ to F grade + per-pattern fix suggestions)
- HTML report output in `analyze_transcript.py --html`
- `argparse` CLI for transcript analyzer
- Full-read detection and tool stats in transcript analyzer
- `compare.sh --json` output mode for scripting
- OS detection in setup.sh (macOS/Linux hints)
- Before/after examples with all 3 modes (`examples/before-after.md`)
- Token estimate sections in learn.sh and stats.sh
- Explicit lite mode rules in agent-rules.md
- `install.sh` version, status, help commands
- `mode.sh describe` command + improved help text
- 20 benchmark prompts (LRU cache, merge sort, rate limiter, HTML link extractor, binary search, stack calculator, retry decorator, config parser, event emitter, markdown-to-HTML)
- Expanded test suite (55+ checks including adapter content validation, CLI flags)
- MIT license, ASCII report chart, CONTRIBUTING.md
- `.gitignore` for test artifacts

### Changed
- `install.sh` now supports `--version`, `--help`, `status` commands
- `mode.sh` now includes `describe` command with savings percentages
- `benchmark.sh` now supports `--list` and `--all` flags
- `review.sh` now supports `--html` output
- `setup.sh` now supports `--check` prerequisite verification
- `analyze_transcript.py` uses argparse, supports `--html` and `-o`
- `compare.sh` shows overall change summary in output
- `session-start.sh` hook includes mode description
- `stats.sh` shows install status, mode description, version
- `auto-dev-SKILL.md` updated with save-token v0.2.0 integration

### Fixed
- README: correct prompt count, correct ultra trial count
- test.sh pipe bug in hook JSON validation
- cost.sh savings percentages updated from 106-trial to 200-trial data
- SKILL.md argument-hint was missing `cost` command

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
