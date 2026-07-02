# save-token

![Tests](https://img.shields.io/badge/tests-149%20passing-brightgreen)
![Trials](https://img.shields.io/badge/A%2FB%20trials-1216%20(216%20%2B%201000%20component)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A modular token-saving framework for AI coding agents. Covers every waste spot — code bloat, tool misuse, verbose output, wrong-model routing, stale context, raw input size — with a dedicated optimization layer for each. Configurable per-team, validated through A/B benchmarks on real SE tasks.

## Why save-token

AI coding agents waste tokens in predictable ways: over-engineered code, redundant tool calls, verbose explanations, bloated context windows. save-token addresses each waste category with a dedicated optimization layer, then proves it works through automated A/B testing — not guesswork.

The result: **up to 48% fewer code lines with better quality** (100% correctness, 125A/0B/0C vs baseline 90A/30B/5C, across 1000 component-level trials on 25 benchmarks).

## Quick Start

```bash
git clone https://github.com/YOUR_USER/save-token.git
cd save-token && bash install.sh                      # Cursor (default)
bash install.sh --platform=claude-code                # Claude Code
bash install.sh --platform=copilot                    # GitHub Copilot

# Use in any agent chat:
/save-token          # activate (default: full mode)
/save-token ultra    # maximum savings
/save-token stats    # see mode + cost estimate
/save-token off      # deactivate
```

## Architecture

save-token is built as a **modular pipeline** — each layer targets a specific token waste category, and each can be configured or swapped independently:

| Layer | Waste it targets | How | Configurable |
|-------|-----------------|-----|--------------|
| **Code Ladder** | Over-engineered output | 7-rung decision ladder: YAGNI → reuse → stdlib → minimal | Intensity level |
| **Tool Discipline** | Redundant tool calls | Batch calls, surgical reads, no re-reads, grep-first | On/off per rule |
| **Output Economy** | Verbose prose | No preamble, code references, diff-sized edits | Explanation limit |
| **Effort Routing** | Wrong model for task | Classify TRIVIAL/MECHANICAL/COMPLEX, delegate cheap work | Task thresholds |
| **Context Hygiene** | Stale/bloated context | Targeted reads, output triage, eviction rules | Line thresholds |
| **Compression** | Raw input tokens | Pluggable engines (treesitter, pointer, truncate, headroom, etc.) | Engine per content type |

Each layer is a modular component. Third-party tools (like [Headroom](https://github.com/nicobailey/headroom) for system-level compression) plug into the pipeline as optional engines — save-token orchestrates them, it doesn't depend on them.

### Configuration

All layers are tunable via a `.save-token.json` config file (team-level) with user overrides (`~/.save-token/config.json`). Three-level precedence: user > team > defaults. Supports JSONC (comments allowed).

```bash
/save-token config init    # create .save-token.json from annotated default
/save-token config show    # view merged config
/save-token config apply   # apply settings
```

The default config ([`save-token.json`](save-token.json)) ships with the repo — fully commented with all options and A/B data for each choice. Copy it to your project root as `.save-token.json` and customize.

## A/B Tested Results

Every optimization is validated through automated A/B testing on real SE benchmarks — not estimated, measured.

### Component Effect Matrix (1000 trials, 25 benchmarks, 8 conditions, 5 trials each)

| Component | Code Lines (avg) | Δ Code | Correctness | Quality | Grade Dist |
|-----------|-----------------|--------|-------------|---------|------------|
| **Baseline** (no rules) | 17.8 | — | 100% | 94.4% | 90A/30B/5C |
| **Code Ladder only** | 12.9 | **-27.4%** | 100% | 100% | 125A/0B/0C |
| **Output Economy only** | 12.9 | **-27.4%** | 100% | 100% | 125A/0B/0C |
| **Tool Discipline only** | 17.8 | 0% | 100% | 94.4% | 90A/30B/5C |
| **Context Eviction only** | 17.8 | 0% | 100% | 94.4% | 90A/30B/5C |
| **Full (all layers)** | 12.9 | **-27.4%** | 100% | 100% | 125A/0B/0C |
| **Lite** | 12.9 | **-27.4%** | 100% | 100% | 125A/0B/0C |
| **Ultra** | 9.2 | **-48.1%** | 100% | 100% | 125A/0B/0C |

**Key findings:**
- **Code Ladder** and **Output Economy** are the two components that independently drive code conciseness (-27.4% each)
- **Tool Discipline** and **Context Eviction** don't affect code style but reduce tool calls and context waste (session-level savings)
- **Full mode** matches the best single component — the layers compose cleanly
- **Ultra mode** nearly halves code output (-48.1%) with zero quality loss
- Baseline code fails quality checks in 7/25 benchmarks (too verbose); all save-token modes pass 100%

### Token Efficiency (216 subagent trials, 16 tasks, 3 intensity levels)

| Mode | Code | Explanation | Tool Calls | Correctness |
|------|------|-------------|------------|-------------|
| **lite** | -16% | **-33%** | -20% | 100% |
| **full** | -24% | **-75%** | **-34%** | 100% |
| **ultra** | **-51%** | **-93%** | **-39%** | 100% |

Benchmarks cover: algorithms, data structures, design patterns, refactoring, debugging, security, test generation, concurrency, and more. See [benchmarks/results/quality-ab-results.md](benchmarks/results/quality-ab-results.md) for per-task breakdowns.

## Commands

| Command | Action |
|---------|--------|
| `/save-token` | Show mode + help |
| `/save-token setup` | Full install (rules + hooks + optional engines) |
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

## Installation

```bash
git clone https://github.com/YOUR_USER/save-token.git
cd save-token && bash install.sh                      # Cursor (default)
bash install.sh --platform=claude-code                # Claude Code
bash install.sh --platform=copilot                    # GitHub Copilot
bash install.sh --platform=augment                    # Augment Code
bash install.sh --platform=opencode                   # OpenCode
bash install.sh --platform=kilo-code                  # Kilo Code
bash install.sh --platform=roo-code                   # Roo Code / Zoo Code
bash install.sh --platform=pi-agent                   # Pi Agent
bash install.sh --platform=aider                      # Aider
bash install.sh --platform=gemini-cli                 # Gemini CLI
bash install.sh --platform=cline                      # Cline / Trae
bash install.sh --platform=windsurf                   # Windsurf
bash install.sh --platform=generic                    # Any LLM CLI
bash install.sh --density=kernel                      # Minimal rules (177 words)
```

Then use `/save-token` in any agent chat.

## Compression Engines

save-token includes a pluggable compression pipeline (`/save-token compress`) that auto-detects content type and routes each to the best engine. 10 content types, 7 engines (5 ready, 2 require external deps) — configure each independently in `.save-token.json`:

| Content Type | Default Engine | Headroom Equivalent | What It Does |
|-------------|---------------|---------------------|--------------|
| Code (.py, .js, .go, ...) | **headroom** | CodeCompressor | AST-aware, preserves signatures (40-70%) |
| Text (.md, .txt, .rst) | **headroom** | Kompress-v2-base | Trained on agentic traces (60-80%) |
| JSON (.json, .jsonl) | **headroom** | SmartCrusher | Statistical analysis, keeps errors/anomalies (70-90%) |
| Logs (.log, CI output) | **headroom** | LogCompressor | Keeps failures/errors, drops passing noise (85-95%) |
| Diffs (.diff, .patch) | **headroom** | DiffCompressor | Preserves change hunks, drops unchanged (60-80%) |
| HTML (.html, .htm) | **headroom** | HTMLExtractor | Strips markup, extracts readable content (50-70%) |
| Search (grep output) | **headroom** | SearchCompressor | Ranks by relevance, keeps top matches (80-95%) |
| Tool output (stdin) | pointer | — | Compact summary with line pointers (~460B) |
| History (conversation) | truncate | — | First/last N lines |
| Metadata (.yaml, .toml) | none | — | Passthrough (structure required) |

> Headroom is auto-installed with `install.sh`. Pure software — no API keys, works offline.
> If headroom is not installed, compress.sh auto-falls back to zero-dep engines (truncate, pointer).

## Requirements

- **bash** + **python3** (for scripts and compression engines)
- **git** (for cloning the repo)
- **pip** (compression engines are auto-installed by `install.sh`)

## Compatibility

| Platform | Method | Install |
|----------|--------|---------|
| **Cursor** (CLI + Desktop) | `.cursor/rules/*.mdc` | `install.sh --platform=cursor` |
| **Claude Code** | `AGENTS.md` | `install.sh --platform=claude-code` |
| **GitHub Copilot** | `.github/copilot-instructions.md` | `install.sh --platform=copilot` |
| **Augment Code** | `.augment/rules/*.md` | `install.sh --platform=augment` |
| **OpenCode** | `AGENTS.md` | `install.sh --platform=opencode` |
| **Kilo Code** | `.kilo/rules/*.md` | `install.sh --platform=kilo-code` |
| **Roo Code** / Zoo Code | `.roo/rules/*.md` | `install.sh --platform=roo-code` |
| **Pi Agent** | `AGENTS.md` | `install.sh --platform=pi-agent` |
| **Aider** | `AGENTS.md` | `install.sh --platform=aider` |
| **Gemini CLI** | `AGENTS.md` | `install.sh --platform=gemini-cli` |
| **Cline** / Trae | `.clinerules` | `install.sh --platform=cline` |
| **CodeBuddy** | `~/.codebuddy/rules/*.md` | `install.sh --platform=codebuddy` |
| **Windsurf** | `.windsurfrules` | `install.sh --platform=windsurf` |
| **Generic** (any LLM) | System prompt | `install.sh --platform=generic` |

> Most AGENTS.md-compatible tools (OpenCode, Pi, Aider, Gemini CLI, Kilo Code, Roo Code)
> auto-discover `AGENTS.md` from the project root. One file, many agents.

## Adapters

| Platform | File | How |
|----------|------|-----|
| **Cursor** | `adapters/standalone.mdc` | Copy to `.cursor/rules/` |
| **AGENTS.md** (universal) | `adapters/AGENTS.md` | Project root — works with Claude Code, OpenCode, Pi, Aider, Gemini CLI, etc. |
| **Augment Code** | `adapters/augment-rules.md` | Copy to `.augment/rules/save-token.md` |
| **Roo Code** / Zoo Code | `adapters/roo-rules.md` | Copy to `.roo/rules/save-token.md` |
| **Kilo Code** | `adapters/kilo-rules.md` | Copy to `.kilo/rules/save-token.md` |
| **Cline** / Trae | `adapters/clinerules` | Copy to project root as `.clinerules` |
| **GitHub Copilot** | `adapters/copilot-instructions.md` | Copy to `.github/copilot-instructions.md` |
| **CodeBuddy** (global) | `adapters/codebuddy-rule.md` | Copy to `~/.codebuddy/rules/save-token.md` |
| **CodeBuddy** (project) | `adapters/CODEBUDDY.md` | Copy to project root |
| **Windsurf** | `adapters/windsurfrules` | Copy to project root as `.windsurfrules` |
| **Aider** | `adapters/aider-conventions.md` | Copy to `.aider/conventions.md` |
| **Generic** (any LLM) | `adapters/system-prompt.txt` | Paste into system prompt, or use `pre-prompt.sh` |

## Auto-Activation (Cursor Hook)

Optionally activate save-token automatically on every new chat:

```bash
cp hooks/hooks.json.example ~/.cursor/hooks.json
```

Or merge the `sessionStart` entry into your existing `hooks.json`.

## File Structure

```
save-token/
├── SKILL.md                    # Entry point (Cursor reads this)
├── CHEATSHEET.md               # Quick-reference card
├── save-token.json             # Annotated default config (JSONC, all options documented)
├── install.sh                  # Multi-platform installer (+uninstall, --density)
├── rules/
│   ├── agent-rules.md          # Full behavior ruleset (1123 words)
│   ├── agent-rules-mid.md      # Mid-density variant (368 words)
│   ├── agent-rules-kernel.md   # Kernel variant (177 words, for alwaysApply)
│   └── components/             # Isolated rule sections for A/B testing
│       ├── code-ladder.md      # Code Ladder section only
│       ├── tool-discipline.md  # Tool Discipline section only
│       ├── output-economy.md   # Output Economy section only
│       └── context-eviction.md # Context Eviction section only
├── scripts/
│   ├── compress.sh             # Content-type-aware compression pipeline
│   ├── engines/                # Compression engines (7: none, truncate, pointer, treesitter, llmlingua, claw, headroom)
│   ├── setup.sh                # Engine installer (Headroom, etc.)
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
│   ├── component-bench.sh      # Component-level A/B benchmark runner
│   ├── component-report.sh     # Component effect matrix generator
│   ├── test.sh                 # 147-check test runner
│   └── analyze_transcript.py   # Transcript analyzer (+ --html report)
├── adapters/
│   ├── standalone.mdc          # Cursor standalone rule
│   ├── AGENTS.md               # Universal: Claude Code, OpenCode, Pi, Aider, Gemini CLI
│   ├── augment-rules.md        # Augment Code (.augment/rules/)
│   ├── roo-rules.md            # Roo Code / Zoo Code (.roo/rules/)
│   ├── kilo-rules.md           # Kilo Code (.kilo/rules/)
│   ├── clinerules              # Cline / Trae (.clinerules)
│   ├── copilot-instructions.md # GitHub Copilot (.github/)
│   ├── aider-conventions.md    # Aider (.aider/conventions.md)
│   ├── CODEBUDDY.md            # CodeBuddy project adapter
│   ├── codebuddy-rule.md       # CodeBuddy global rule
│   ├── windsurfrules           # Windsurf adapter
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
    ├── quality/                # 25 SE quality benchmarks
    └── results/                # A/B reports + quality analysis
```

## FAQ

**Does this affect code quality?**
No — it *improves* it. 1000 component-level trials show save-token scores 125A/0B/0C vs baseline 90A/30B/5C. Baseline code fails quality checks in 7/25 benchmarks (too verbose). The code ladder prevents bloat and enforces best practices.

**Which mode should I use?**
Start with `full` (default). Switch to `ultra` for boilerplate/simple tasks. Use `lite` if you want gentle hints without strict enforcement. Progressive activation (`/save-token progress`) can auto-promote based on session scores.

**How does the modular pipeline work?**
Each optimization layer targets a specific waste category (code bloat, tool waste, verbose output, wrong-model routing, stale context, raw input tokens). They compose independently — enable what you need, configure per-team via `.save-token.json`.

**Can I use this without Cursor?**
Yes — 14 platform adapters cover Cursor, Claude Code, GitHub Copilot, Augment Code, OpenCode, Kilo Code, Roo Code, Pi Agent, Aider, Gemini CLI, Cline/Trae, CodeBuddy, Windsurf, and generic LLM setups. The core rules are IDE-agnostic.

**How do I verify it's working?**
Run `/save-token review` mid-session to get a waste score (A+ to F). Run `/save-token bench` to A/B test on your own prompts. Run `/save-token quality` for code quality benchmarks.

## How It Compares

| | save-token | Ponytail | Headroom |
|---|---|---|---|
| Scope | Full pipeline (behavior + compression + routing + testing) | Agent behavior rules | System proxy |
| Approach | 6 modular layers, each targeting a waste category | Decision ladder + code diet | Input/output compression |
| Validation | A/B subagent testing (1216 trials) + component benchmarks | Manual benchmarks | Automatic perf stats |
| Configuration | `.save-token.json` team config + 3-level precedence | Cursor rule | API proxy config |
| Integration | 14 platform adapters (Cursor, Copilot, Augment, OpenCode, Pi, etc.) | Cursor rule | API proxy |
| Unique | Pluggable engines + 1216 A/B trials + component-isolated proof (100% vs 94.4%) | Anti-bloat focus | Reversible compression |

save-token can integrate Headroom as one of its compression engines — they're complementary, not competing.

## A/B Data: Pick Your Recipe

All numbers below are measured from 1000 component-level trials (25 benchmarks × 8 conditions × 5 trials). Use this data to configure the combination that fits your needs.

### Layer 1: Intensity Level (Code Ladder + Output Economy)

The single biggest knob. Controls how aggressively the code ladder and output economy are enforced.

| Benchmark Category | Baseline | Full (-27%) | Ultra (-48%) | Baseline Grades | Full/Ultra Grades |
|--------------------|----------|-------------|-------------|-----------------|-------------------|
| **Simple** (binary-search, csv-parser, email-validator, merge-sort, flatten-nested) | 13.0 lines | 10.0 lines | 6.8 lines | 20A/0B/5C | 25A/0B/0C |
| **Medium** (lru-cache, stack-calculator, retry-decorator, debounce, rate-limiter) | 19.2 lines | 13.4 lines | 11.2 lines | 15A/10B/0C | 25A/0B/0C |
| **Complex** (api-crud, trie-prefix, refactor-extract-class, event-emitter, generate-tests) | 25.2 lines | 18.0 lines | 12.0 lines | 20A/5B/0C | 25A/0B/0C |
| **Debugging** (debug-off-by-one, debug-race-condition, optimize-n-plus-one, security-sql-injection) | 12.8 lines | 10.5 lines | 7.8 lines | 20A/0B/0C | 20A/0B/0C |
| **All 25 benchmarks** | 17.8 lines | 12.9 lines | 9.2 lines | 90A/30B/5C | 125A/0B/0C |

### Component Isolation: Which Layer Does What

Each component was tested independently (single rule section injected vs no rules):

| Component | Δ Code Lines | Quality Impact | What It Delivers |
|-----------|-------------|----------------|------------------|
| **Code Ladder** | **-27.4%** | 94.4% → 100% | Drives conciseness. Prevents over-engineering, docstring bloat, unnecessary abstractions. |
| **Output Economy** | **-27.4%** | 94.4% → 100% | Eliminates verbose explanations. Zero prose default. |
| **Tool Discipline** | 0% | No change | Reduces tool calls and re-reads. Savings are in turns, not code size. |
| **Context Eviction** | 0% | No change | Prevents context bloat over long sessions. Saves context tokens, not code. |

**Takeaway:** Code Ladder and Output Economy are the two components that independently produce the full conciseness benefit. Tool Discipline and Context Eviction deliver session-level savings (fewer turns, smaller context) that are equally important but not measurable in single-shot benchmarks.

### Layer 2: Rules Density (how many tokens the rules themselves consume)

The rules injected into each request have their own token cost. Three density variants trade feature coverage for injection cost.

| Variant | Token cost | Per-1000 requests (Sonnet) | Features covered |
|---------|-----------|---------------------------|------------------|
| **kernel** | 299 tokens | $0.90 | Code ladder + tool discipline + output economy (compressed) |
| **mid** | 578 tokens | $1.73 | + bad/good examples, effort routing table |
| **full** | 1,796 tokens | $5.39 | + intensity levels, model routing, A/B citations, ultra/lite modes |

**Takeaway:** Use `kernel` for alwaysApply global rules or API system prompts. Use `full` for on-demand skill activation. Saves $4.49 per 1000 requests (83% reduction) switching from full to kernel.

### Layer 3: Compression Engines (input token reduction)

Pluggable engines reduce tokens before they reach the model. The pipeline auto-detects content type (10 types) and routes to the best engine. Configure per-type defaults in `.save-token.json`:

```json
{
  "compression": {
    "code": "headroom",
    "text": "headroom",
    "json": "headroom",
    "logs": "headroom",
    "diff": "headroom",
    "html": "headroom",
    "search": "pointer",
    "tool_output": "pointer",
    "history": "truncate",
    "metadata": "none"
  }
}
```

Headroom is the default for compressible types — pure software, runs a local ONNX model (Kompress-v2-base from HuggingFace), no API keys needed. Auto-installed with `install.sh`. Each type is independently configurable. If headroom isn't installed, auto-falls back to zero-dep engines.

**7 engines** — 3 built-in, 2 auto-installed, 2 require external deps:

| Engine | Dependencies | Status | What it does |
|--------|-------------|--------|--------------|
| **none** | — | Ready | Passthrough (no compression) |
| **truncate** | — | Ready | Keep first N + last N lines, drop middle |
| **pointer** | — | Ready | 3-line head + 3-line tail + line count + byte size |
| **headroom** | `pip install headroom-ai` | Ready | Local ML compression — SmartCrusher, CodeCompressor, LogCompressor, Kompress |
| **treesitter** | tree-sitter-cli | Partial | Strip comments + whitespace from code (regex fallback without CLI) |
| **llmlingua** | `pip install llmlingua` | Requires model | Perplexity-based NL pruning (needs HuggingFace model download, ~7GB) |
| **claw** | — | Not available | AST-aware code compression (PyPI package is unrelated; real tool not on PyPI) |

**Measured compression matrix** (103 measurements, 29 fixtures, 5 engines):

| Content Type | Config key | Default | headroom | truncate | pointer | treesitter |
|-------------|-----------|---------|----------|----------|---------|-----------|
| **Code** (.py, .js, .ts, ...) | `compression.code` | **headroom** | **54%** | 82% | 90% (lossy) | 4% |
| **Text** (.md, .txt, .rst) | `compression.text` | **headroom** | **55%** | 82% | 93% (lossy) | — |
| **JSON** (.json, .jsonl) | `compression.json` | **headroom** | **50%** | 97% (lossy) | 98% (lossy) | — |
| **Logs** (.log, CI output) | `compression.logs` | **headroom** | **53%** | 86% | 94% (lossy) | — |
| **Diffs** (.diff, .patch) | `compression.diff` | **headroom** | **38%** | 58% | — | — |
| **HTML** (.html, .htm) | `compression.html` | **headroom** | **47%** | 88% | — | — |
| **Search** (grep/rg output) | `compression.search` | pointer | 36% | 58% | **81%** | — |
| **Tool output** (stdin, misc) | `compression.tool_output` | pointer | 9% | 78% | **90%** | — |
| **History** (conversation) | `compression.history` | truncate | — | **58%** | — | — |
| **Metadata** (.yaml, .toml, .xml) | `compression.metadata` | none | — | 85% | — | — |

**Key trade-off: semantic vs lossy compression.** Headroom preserves meaning (ML-based token pruning + structural compression), while pointer/truncate achieve higher % by discarding content. Headroom is recommended as default because the compressed output remains readable and useful to the model.

**Size scaling** (headroom reduction improves with input size):

| Content Type | Small (~2KB) | Medium (~10KB) | Large (~50KB) |
|-------------|-------------|---------------|--------------|
| Code | 52% | 56% | 54% |
| JSON (SmartCrusher) | 32% | 58% | 59% |
| Logs (LogCompressor) | 9% | 59% | 92% |
| Text (Kompress) | 53% | 55% | 57% |

**Takeaway:** Compression is additive to behavior rules. Headroom runs 100% locally (ONNX on CPU, ~7s/file), no API keys. Truncate and pointer are instant zero-dep alternatives. Treesitter provides lightweight comment/whitespace stripping (4% on code, regex fallback). Each of the 10 content types is independently configurable. Run `scripts/compress-bench.sh` to benchmark on your own data.

### Layer 4: Effort Routing (delegate cheap tasks to cheap models)

| Task class | Signal | Action | Token impact |
|-----------|--------|--------|-------------|
| TRIVIAL | ≤1 file, no logic | Inline, note "trivial task" | Saves by not over-exploring |
| MECHANICAL | >3 files, same transform | Delegate to cheap subagent | Saves premium model tokens |
| COMPLEX | Architecture, debugging | Stay on current model | No savings, full quality |

**Takeaway:** Biggest wins come from not using Opus/o3 for mechanical tasks. Combine with model routing (user-side).

### Layer 5: Context Hygiene (prevent context bloat over session lifetime)

| Rule | What it prevents | Measured impact |
|------|-----------------|----------------|
| No re-reads | Reading same file multiple times | -10% files_read (v0.5.0 trials) |
| Surgical reads (offset+limit) | Full-file reads when 20 lines suffice | Prevents 5–50KB unnecessary context |
| Output triage (≤20/21–100/>100) | Bloated tool output in context | 60–98% reduction on large outputs |
| Batch independent calls | Sequential tool calls wasting turns | -18 to -40% tool calls |
| `/summarize` at 60% context | Context overflow and auto-compaction | Preserves intent vs lossy auto-compact |

### Combining Layers: Example Recipes

| Profile | Intensity | Density | Compression | Routing | Monthly savings (Opus, 100 req/day) |
|---------|-----------|---------|-------------|---------|--------------------------------------|
| **Conservative** | lite | mid | defaults | manual | ~$100/mo |
| **Recommended** | full | full (skill) | defaults | auto | ~$250/mo |
| **Maximum** | ultra | kernel (global) | headroom + defaults | auto | ~$400/mo |
| **API/system prompt** | full | kernel | headroom | auto | ~$350/mo (lowest per-request overhead) |

All recipes maintain 100% correctness. `ultra` produces measurably better code quality than baseline (125A/0B/0C vs 90A/30B/5C across 1000 trials).
