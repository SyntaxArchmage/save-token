# Changelog

## [0.8.0] — 2026-07-02

v2.0 polish: claim integrity, frictionless adoption, drift prevention. No new
optimization layers — hardening only.

### Added
- **Claim integrity (A1):** `benchmarks/results/HEADLINE.json` — single source of truth
  for every headline statistic. `test.sh` now fails if any doc cites a number missing
  from it (stat-consistency checks).
- **Benchmark provenance (A2):** `benchmark.sh --output=json` now records
  `save_token_version`, `date_iso`, `git_commit`, `rules_hash`, `prompt_hash` so any
  result is re-runnable identically.
- **Install doctor (B1):** `install.sh verify` — one-screen health report (adapter, mode,
  engines, hook) with OK/WARN verdicts.
- **Project health dashboard (C1):** `stats.sh health` — version, test pass rate, adapter
  count, engine availability, A/B trial count (from HEADLINE.json).
- **Doc-drift guard (C2):** CI workflow triggers on docs + HEADLINE.json changes and runs
  stat-consistency checks before the full suite.
- **Marketplace-readiness gap list (B3):** `docs/marketplace-readiness.md` maps the repo
  to Cursor plugin requirements (9/11 met; `plugin.json` is the one hard gap).
- **Release checklist (C3):** added to `CONTRIBUTING.md`.
- Test suite expanded from 158 to 172 checks.

### Removed
- **`claw` compression engine (A3):** the PyPI `claw-compactor` package is an unrelated
  project and no viable AST compressor exists on PyPI. Engine list now shows `[removed]`;
  `--install=claw` fails with an explanation. Engine count: 7 → 6.

### Changed
- First-run guidance after install (B2): reduced to the 3 essential commands
  (`/save-token`, `/save-token ultra`, `/save-token off`) + a `verify` pointer.
- Replaced `YOUR_USER` GitHub placeholder with real owner in README.md and SKILL.md.
- README/CHEATSHEET engine tables updated for 6 engines.

### Install robustness & UX
- **llmlingua is now opt-in, not auto-installed** — aligns install with the A3 decision.
  It pulls a ~500MB model and adds ~4s import cost; auto-installing it hurt first-run UX.
  `install.sh` now prints an opt-in hint instead.
- **PEP 668 handling** — engine install now uses `python3 -m pip` (more reliable than bare
  `pip`) and retries with `--user` on externally-managed environments (modern Ubuntu/
  Debian/Homebrew). Failure messages now show the actual retry command.
- **No more pointless self-backup** — reinstalling a file-based platform (AGENTS.md,
  .clinerules, .windsurfrules, copilot) no longer backs up save-token's own adapter to
  `.bak`. Backups now only happen for genuinely foreign files (via `safe_backup`).

## [0.7.0] — 2026-07-02

### Removed
- **`light` install mode** — rules-only installation is meaningless for a multi-platform framework; `install.sh` now always does a full install (adapter + scripts + compression engine)
- All `install_*_light()` / `install_*_heavy()` function pairs merged into single `install_*()` functions
- "Zero-install" curl section from README

### Added
- **Treesitter (regex fallback) benchmark data** — 3 measurements on code fixtures (0.5-5.8% reduction), matching ROADMAP estimate of 3-9%
- Engine availability notes in compress-bench report (claw blocked, llmlingua needs model download, treesitter partial)

### Fixed
- `engines/claw.sh` — PyPI `claw-compactor` (v7.x) is an unrelated project (EngramEngine); added import guard and documentation
- `engines/llmlingua.sh` — added `use_llmlingua2=True`, error handling, network requirement note
- README duplicate table fragment (stray `| Text | truncate |` lines)

### Changed
- `install.sh` version bump to 0.7.0
- `install.sh` now auto-installs all available compression engines (headroom, llmlingua, treesitter) — not just headroom
- `install.sh status` now shows available compression engines
- `install_cursor()` prevents self-referencing symlink when repo is at skill path
- `compress.sh --list` shows accurate engine status ([ready]/[fallback]/[blocked])
- `compress.sh --install=claw` blocked with explanation (PyPI mismatch)
- `compress.sh auto_engine()` defaults aligned with save-token.json (diff→headroom, search→pointer)
- `compress.sh engine_available()` checks match `compress-bench.sh engine_installed()`
- `save-token.json` search default changed to pointer (81% avg vs headroom 36%)
- Compression benchmark report updated to 103 measurements across 5 engines (was 100/4)
- README compression matrix now includes treesitter column
- Engine table in README now shows availability status per engine
- SKILL.md compress section shows headroom as default for most types
- Test suite expanded from 147 to 151 checks

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
- **Software development quality benchmark suite** — `quality-bench.sh` + 25 benchmarks covering algorithms, data structures, decorators, design patterns, refactoring, debugging, race conditions, event-driven design, performance optimization, security fixes, test generation, functional programming, caching, tries, context managers, matrix math, and concurrency patterns
- 50-trial A/B results: save-token **25A/0B/0C** vs baseline 19A/5B/1C, -15.8% code lines, 100% correctness (vs baseline 99.1%), zero unwanted explanation
- Test suite expanded to 145 checks

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
