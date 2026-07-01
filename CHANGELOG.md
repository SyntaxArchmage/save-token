# Changelog

## [0.6.0] — 2026-07-01

### Added
- **P0: Multi-platform architecture** — 8 adapters: Cursor, Claude Code, CodeBuddy (global + project), Windsurf, GitHub Copilot, generic system prompt, CLI pre-prompt
- **P1: Content-type-aware compression pipeline** — `compress.sh` with 7 engines (none, truncate, pointer, treesitter, llmlingua, claw, headroom), auto content type detection, lazy dependency installation
- **P2: Effort routing** — task classification (TRIVIAL/MECHANICAL/COMPLEX) + subagent delegation protocol
- **P3: Verbosity self-adaptation** — `learn.sh --verbosity-profile` scans 30 days of transcripts for explain-more vs too-verbose signals, recommends mode adjustment
- **P4: Rules density optimization** — kernel (177 words), mid (368 words), full (1123 words) variants with `--density=` install option
- **P5: Context eviction** — tool output triage rules (≤20/21-100/>100 lines), no-re-read, conversation length warnings, binary content pointers
- **P6: Real token tracking** — `tokens.sh` with 8 commands (detect, collect, log, summary, export, reset, parse-claude); supports Cursor, Claude CLI, Helicone, LiteLLM, manual entry; integrates with `cost.sh` (real data + estimation fallback)
- **P7: Team config mode** — `load-config.sh` with 3-level precedence (defaults → `.save-token.json` team → `~/.save-token/config.json` user), deep merge, init template
- **P8: Progressive activation** — `progress.sh` tracks review scores, promotes lite→full→ultra after qualifying sessions
- **P9: CI benchmark regression** — GitHub Action workflow + `compare.sh --fail-if-regression=N%` + `--format=markdown`
- **P10: promptfoo integration** — `export-promptfoo.sh` generates promptfoo eval config from rules + 20 benchmark prompts
- **P11: Multi-model A/B** — `benchmark.sh --model=MODEL --trials=N --output=json` for cross-model comparison
- Multi-platform `install.sh` with `--platform=cursor|claude-code|codebuddy|generic` and `--density=kernel|mid|full`
- P1 compression baseline benchmark results
- P4 density cost/benefit analysis document
- P6 functional A/B test results
- **Software development quality benchmark suite** — `quality-bench.sh` + 17 benchmarks covering algorithms, data structures, decorators, refactoring, debugging, race conditions, event-driven design, performance optimization, security fixes, and test generation
- 34-trial A/B results: save-token 17A/0B vs baseline 14A/3B, -14% code lines, -12% tool calls, 100% correctness parity
- Test suite expanded to 137 checks

### Changed
- All adapters: code ladder upgraded from 5 to 7 rungs (added platform native + installed dep)
- All variants: unified opening line to "Persist every response"
- kernel/mid variants: added "one clarifying question early" rule
- README.md: updated file tree, compatibility table, adapter table, installation examples
- SKILL.md: added compress, verbosity commands + multi-platform install examples
- CHEATSHEET.md: added compress, verbosity, density, CodeBuddy/generic adapters

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
