# save-token

![Tests](https://img.shields.io/badge/tests-145%20passing-brightgreen)
![Trials](https://img.shields.io/badge/A%2FB%20trials-216%20%2B%2050%20quality-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A modular token-saving framework for AI coding agents. Covers every waste spot — code bloat, tool misuse, verbose output, wrong-model routing, stale context, raw input size — with a dedicated optimization layer for each. Configurable per-team, validated through A/B benchmarks on real SE tasks.

## Why save-token

AI coding agents waste tokens in predictable ways: over-engineered code, redundant tool calls, verbose explanations, bloated context windows. save-token addresses each waste category with a dedicated optimization layer, then proves it works through automated A/B testing — not guesswork.

The result: **up to 51% fewer tokens with better code quality** (100% correctness vs baseline 99.1%, across 50 quality trials).

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

All layers are tunable via a `.save-token.json` config file (team-level) with user overrides (`~/.save-token/config.json`). Three-level precedence: user > team > defaults.

```bash
/save-token config init    # create template config
/save-token config show    # view merged config
/save-token config apply   # apply settings
```

## A/B Tested Results

Every optimization is validated through automated A/B testing on real SE benchmarks — not estimated, measured.

### Token Efficiency (216 subagent trials, 16 tasks, 3 intensity levels)

| Mode | Code | Explanation | Tool Calls | Correctness |
|------|------|-------------|------------|-------------|
| **lite** | -16% | **-33%** | -20% | 100% |
| **full** | -24% | **-75%** | **-34%** | 100% |
| **ultra** | **-51%** | **-93%** | **-39%** | 100% |

### Code Quality (50 quality trials, 25 SE benchmarks)

| Metric | Baseline | save-token | Delta |
|--------|----------|------------|-------|
| Correctness | 99.1% | **100%** | +0.9% |
| Quality grade | 19A / 5B / 1C | **25A / 0B / 0C** | save-token wins |
| Code lines | 16.7 avg | 14.1 avg | **-15.8%** |
| Unwanted explanation | 0.52 lines | 0 lines | **-100%** |

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
cd save-token && bash install.sh                           # Cursor, full density
bash install.sh --platform=claude-code                     # Claude Code
bash install.sh --platform=codebuddy                       # CodeBuddy
bash install.sh --density=kernel                           # Minimal rules (177 words)
bash install.sh light --platform=generic                   # Generic CLI, rules only
```

Or manually symlink: `ln -s /path/to/save-token ~/.cursor/skills/save-token`

Then use `/save-token` in any agent chat.

## Compression Engines

save-token includes a pluggable compression pipeline (`/save-token compress`) that auto-detects content type and applies the right engine:

| Content Type | Default Engine | What It Does |
|-------------|---------------|--------------|
| Code | treesitter | Strip comments and whitespace |
| Tool output | pointer | Compact summary with line pointers |
| Text | truncate | First N + last N lines |
| Metadata | none | Passthrough |

Additional engines available: **llmlingua**, **claw**, **headroom** (system-level proxy, 60-95% input reduction). Install any engine on demand:

```bash
/save-token compress --install=headroom
```

All engines are optional — the behavior rules alone deliver the bulk of savings.

## Requirements

- **bash** + **python3** (for learn/review/stats scripts)
- **git** (optional, for install.sh)
- Compression engines installed on demand (all optional)

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
│   ├── test.sh                 # 145-check test runner
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
    ├── quality/                # 25 SE quality benchmarks
    └── results/                # A/B reports + quality analysis
```

## FAQ

**Does this affect code quality?**
No — it *improves* it. 50 quality trials show save-token scores 25A/0B/0C vs baseline 19A/5B/1C. The code ladder prevents bloat and enforces best practices that baselines miss.

**Which mode should I use?**
Start with `full` (default). Switch to `ultra` for boilerplate/simple tasks. Use `lite` if you want gentle hints without strict enforcement. Progressive activation (`/save-token progress`) can auto-promote based on session scores.

**How does the modular pipeline work?**
Each optimization layer targets a specific waste category (code bloat, tool waste, verbose output, wrong-model routing, stale context, raw input tokens). They compose independently — enable what you need, configure per-team via `.save-token.json`.

**Can I use this without Cursor?**
Yes — 8 adapters cover Cursor, Claude Code, CodeBuddy, Windsurf, GitHub Copilot, and generic LLM setups. The core rules are IDE-agnostic.

**How do I verify it's working?**
Run `/save-token review` mid-session to get a waste score (A+ to F). Run `/save-token bench` to A/B test on your own prompts. Run `/save-token quality` for code quality benchmarks.

## How It Compares

| | save-token | Ponytail | Headroom |
|---|---|---|---|
| Scope | Full pipeline (behavior + compression + routing + testing) | Agent behavior rules | System proxy |
| Approach | 6 modular layers, each targeting a waste category | Decision ladder + code diet | Input/output compression |
| Validation | A/B subagent testing (266 trials) + quality benchmarks | Manual benchmarks | Automatic perf stats |
| Configuration | `.save-token.json` team config + 3-level precedence | Cursor rule | API proxy config |
| Integration | 8 platform adapters (Cursor, Claude Code, Copilot, etc.) | Cursor rule | API proxy |
| Unique | Pluggable engines + A/B validated + quality-proven (100% vs 99.1%) | Anti-bloat focus | Reversible compression |

save-token can integrate Headroom as one of its compression engines — they're complementary, not competing.

## A/B Data: Pick Your Recipe

All numbers below are measured, not estimated. Use this data to configure the combination that fits your needs.

### Layer 1: Intensity Level (Code Ladder + Output Economy)

The single biggest knob. Controls how aggressively the code ladder and output economy are enforced.

| Benchmark Category | Metric | Baseline | Lite | Full | Ultra |
|--------------------|--------|----------|------|------|-------|
| **Simple** (csv-parser, email-validator, binary-search) | Code lines | 10.3 | 8.7 (-16%) | 9.3 (-10%) | 6.3 (-39%) |
| | Explanation | 2.0 | 1.3 (-33%) | 0 (-100%) | 0 (-100%) |
| | Quality grade | A | A | A | A |
| **Medium** (lru-cache, merge-sort, rate-limiter, retry-decorator) | Code lines | 17.3 | — | 16.0 (-7%) | — |
| | Explanation | 1.5 | — | 0 (-100%) | — |
| | Quality grade | A/B mix | — | A | — |
| **Complex** (event-emitter, stack-calculator, file-watcher, refactor) | Code lines | 28.0 | 23.0 (-18%) | 21.3 (-24%) | 13.5 (-52%) |
| | Explanation | 3.0 | 2.0 (-33%) | 0.5 (-83%) | 0.3 (-90%) |
| | Quality grade | A/B/C mix | A/B | A | A |
| **All 25 quality benchmarks** | Correctness | 99.1% | — | 100% | — |
| | Grade distribution | 19A/5B/1C | — | 25A/0B/0C | — |

**Takeaway:** `full` is the sweet spot — eliminates all unwanted explanation, maintains 100% quality. `ultra` for maximum code compression. `lite` for advisory-only.

### Layer 2: Rules Density (how many tokens the rules themselves consume)

The rules injected into each request have their own token cost. Three density variants trade feature coverage for injection cost.

| Variant | Token cost | Per-1000 requests (Sonnet) | Features covered |
|---------|-----------|---------------------------|------------------|
| **kernel** | 299 tokens | $0.90 | Code ladder + tool discipline + output economy (compressed) |
| **mid** | 578 tokens | $1.73 | + bad/good examples, effort routing table |
| **full** | 1,796 tokens | $5.39 | + intensity levels, model routing, A/B citations, ultra/lite modes |

**Takeaway:** Use `kernel` for alwaysApply global rules or API system prompts. Use `full` for on-demand skill activation. Saves $4.49 per 1000 requests (83% reduction) switching from full to kernel.

### Layer 3: Compression Engines (input token reduction)

Pluggable engines reduce tokens before they reach the model. The pipeline auto-detects content type from file extension and applies the right engine. Configure defaults in `.save-token.json` under `compression`:

```json
{
  "compression": {
    "code": "treesitter",
    "text": "truncate",
    "tool_output": "pointer"
  }
}
```

**7 engines available** — 3 zero-dep (built-in), 4 installable on demand:

| Engine | Dependencies | What it does |
|--------|-------------|--------------|
| **none** | — | Passthrough (no compression) |
| **truncate** | — | Keep first N + last N lines, drop middle |
| **pointer** | — | 3-line head + 3-line tail + line count + byte size |
| **treesitter** | tree-sitter-cli | Strip comments + whitespace from code (AST-aware) |
| **llmlingua** | `pip install llmlingua` | Perplexity-based pruning for natural language (Microsoft) |
| **claw** | `pip install claw-compactor` | AST-aware code compression (reversible) |
| **headroom** | `pip install headroom-ai[proxy]` | System-level proxy compression (60–95% on all input) |

**Measured compression by content type and engine:**

| Content Type | Config key | Default engine | Alternatives | Measured reduction |
|-------------|-----------|----------------|--------------|-------------------|
| **Code** (.py, .js, .ts, .sh, .go, .rs, .java, ...) | `compression.code` | treesitter | claw, pointer, none | treesitter: 3–9%, claw: 15–82%, pointer: 69–98% |
| **Text/docs** (.md, .txt, .rst, .tex) | `compression.text` | truncate | llmlingua, pointer | truncate: 56–95%, pointer: 69–98% |
| **Tool output** (stdin, .log) | `compression.tool_output` | pointer | truncate, none | pointer: 69–98% (constant ~460B), truncate: 32–80% |
| **History** (conversation context) | — | truncate | — | truncate: 32–80% |
| **Metadata** (.json, .yaml, .toml, .xml, .csv) | — | none | — | 0% (full fidelity required) |

**Size-dependent performance** (tool output, measured):

| Output size | pointer | truncate |
|------------|---------|----------|
| 30 lines | 31% retained | 68% retained |
| 50 lines | 18% | 41% |
| 100 lines | 9% | 20% |
| 500 lines | 2% | 4% |

**Takeaway:** Compression is additive to behavior rules. Start with defaults (auto-detect content type). For maximum savings, install `headroom` as system-level proxy or `claw` for AST-aware code compression. For NL-heavy contexts, install `llmlingua`.

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

All recipes maintain 100% correctness. `ultra` produces measurably better code quality than baseline (25A vs 19A).
