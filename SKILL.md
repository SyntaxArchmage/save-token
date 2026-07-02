---
name: save-token
description: >
  Modular token-saving framework for AI coding agents. Systematically covers
  every waste category — code generation, tool usage, output verbosity, effort
  routing, context hygiene, input compression — with pluggable optimization
  layers. All configurable via .save-token.json, all validated through A/B
  benchmarks on real SE tasks. Use when the user says "save-token", "save tokens",
  "reduce token", "cut cost", "be efficient", "token budget", or invokes /save-token.
argument-hint: "[setup|bench|stats|learn|review|cost|lite|full|ultra|off]"
---

# /save-token

Modular token-saving framework — 6 optimization layers, each targeting a specific waste category.
Verified: 1216 A/B trials (216 efficiency + 1000 component-level) — up to -48% code, 100% correctness, 125A/0B/0C quality.

## Activation

ACTIVE EVERY RESPONSE once invoked. Default: **full**. Off: `/save-token off`.

When activated, read and follow [rules/agent-rules.md](rules/agent-rules.md).
That file contains the complete behavior ruleset. Apply it immediately.

## Commands

| Command | Action |
|---------|--------|
| `/save-token` | Show current mode + help |
| `/save-token setup` | Install Headroom proxy + configure |
| `/save-token lite\|full\|ultra` | Switch intensity |
| `/save-token off` | Deactivate rules |
| `/save-token bench [prompt]` | A/B test with subagents |
| `/save-token stats` | Show savings statistics |
| `/save-token learn` | Mine past sessions for waste patterns |
| `/save-token review` | Audit current session for token waste |
| `/save-token cost [model]` | Estimate $/month savings (uses real data if tracked) |
| `/save-token tokens` | Track real token usage across platforms |
| `/save-token compress [file]` | Compress content (auto-detects type + engine) |
| `/save-token verbosity` | Analyze verbosity signals + recommend mode |
| `/save-token config` | Show/apply team config (.save-token.json) |
| `/save-token progress` | Show progressive activation status |
| `/save-token quality` | Dev quality benchmarks (correctness + quality) |

## Command: setup

**Agent installation commands** (run these when user asks to install save-token):

```bash
# Cursor (default):
bash ~/.cursor/skills/save-token/install.sh --hook

# Claude Code:
bash ~/.cursor/skills/save-token/install.sh --platform=claude-code

# CodeBuddy:
bash ~/.cursor/skills/save-token/install.sh --platform=codebuddy

# Generic CLI:
bash ~/.cursor/skills/save-token/install.sh --platform=generic

# Minimal token footprint (kernel rules, 177 words):
bash ~/.cursor/skills/save-token/install.sh --density=kernel
```

If save-token repo is not yet cloned:
```bash
git clone https://github.com/YOUR_USER/save-token.git /tmp/save-token && bash /tmp/save-token/install.sh --hook
```

The installer auto-installs all available compression engines (headroom, llmlingua, treesitter fallback).

## Command: bench

A/B test to measure rule effectiveness on a given task.

1. Extract the prompt from user input (everything after `bench`).
   If no prompt given, use a default: "Write a Python function that validates
   email addresses and returns a list of valid ones."

2. Launch **2 parallel `best-of-n-runner` subagents**:

   **Subagent A (baseline):**
   ```
   Task({
     subagent_type: "best-of-n-runner",
     description: "A/B Baseline",
     prompt: "<the prompt>\n\nAfter completing, report:\nMETRICS:\ntool_calls: <n>\ncode_lines: <n>\nexplanation_lines: <n>\nfiles_read: <n>"
   })
   ```

   **Subagent B (optimized):**
   ```
   Task({
     subagent_type: "best-of-n-runner",
     description: "A/B Optimized",
     prompt: "<agent-rules.md content>\n\n---\n\n<the prompt>\n\nAfter completing, report:\nMETRICS:\ntool_calls: <n>\ncode_lines: <n>\nexplanation_lines: <n>\nfiles_read: <n>"
   })
   ```

3. For statistical robustness, run **4 trials per arm** (8 subagents total).
   Our 1216-trial benchmark uses this sample size across 25 distinct tasks.

4. Compare results and display a table:
   ```
   ╔══════════════════════════════════════════════╗
   ║           save-token A/B Results             ║
   ╠══════════════════════════════════════════════╣
   ║ Metric          │ Baseline │ Optimized │  Δ  ║
   ║ tool_calls      │   avg    │   avg     │  %  ║
   ║ code_lines      │   avg    │   avg     │  %  ║
   ║ explanation_lines│   avg    │   avg     │  %  ║
   ║ files_read      │   avg    │   avg     │  %  ║
   ║ Correctness     │  n/n     │   n/n     │     ║
   ╚══════════════════════════════════════════════╝
   ```

## Command: stats

```bash
bash ~/.cursor/skills/save-token/scripts/stats.sh
```

Shows current mode, Headroom status (if running), and cumulative metrics.

## Command: learn

```bash
bash ~/.cursor/skills/save-token/scripts/learn.sh
```

Analyzes Cursor agent-transcripts for waste patterns:
- Repeated file reads (same file read >2 times)
- Sequential tool calls that could be batched
- Overly long responses (>2000 chars)

Outputs findings to `~/.save-token/learnings.md`.

## Command: compress

```bash
bash ~/.cursor/skills/save-token/scripts/compress.sh [options] [FILE]
```

Content-type-aware compression. Auto-detects content type from file extension:
- code, text, json, logs, diff, html → headroom (40-95% reduction)
- search, tool_output → pointer (compact summary, ~460B)
- history → truncate (first N + last N lines)
- metadata → none (passthrough)

Options: `--type=`, `--engine=`, `--list`, `--stats`

Engines: none, truncate, pointer, headroom, treesitter, llmlingua (auto-installed).

## Command: verbosity

```bash
bash ~/.cursor/skills/save-token/scripts/learn.sh --verbosity-profile
```

Scans last 30 days of transcripts for "explain more" vs "too verbose" signals.
Recommends mode adjustment (lite/full/ultra) with confidence level.
Saves profile to `~/.save-token/verbosity-profile.json`.

## Command: review

Analyze the current session for token waste (no subagent):

```bash
bash ~/.cursor/skills/save-token/scripts/review.sh
```

Detects: repeated file reads, unbatched sequential tool calls, verbose responses.
Outputs a checklist of improvements.

## Command: cost

```bash
bash ~/.cursor/skills/save-token/scripts/cost.sh [opus|sonnet|haiku|gpt4o|o3]
```

Uses real token data (from `tokens.sh`) if available, otherwise falls back
to 216-trial benchmark estimation. Default model: opus.

## Command: tokens

```bash
bash ~/.cursor/skills/save-token/scripts/tokens.sh [command]
```

Track real token usage. Commands:
- `detect` — find available token data sources (Cursor, Claude CLI, Helicone, LiteLLM)
- `collect --source=auto` — auto-collect from detected sources
- `log INPUT OUTPUT [MODEL]` — manually record a request
- `summary` — show tracked data + estimated savings
- `export --format=csv|json` — export tracked data
- `reset` — clear token log

Supports: Cursor usage.json, Claude Code JSON output, Helicone API, LiteLLM proxy, manual entry.

## Command: quality

```bash
bash ~/.cursor/skills/save-token/scripts/quality-bench.sh [list|show|validate|score]
```

Software development quality benchmark suite — dual objective: token cost + code quality.

Subcommands:
- `list` — show all 8 quality benchmarks
- `show <id>` — show benchmark details (prompt + tests + quality checks)
- `validate <file.py> --benchmark=<id>` — run correctness tests + quality checks, output JSON
- `score <file.py> --benchmark=<id>` — full quality score with grade (A/B/C/F)
- `validate-all <dir>` — validate all .py files against matching benchmarks

Each benchmark defines: prompt, test cases (functional), quality checks (max lines, banned/required patterns).
Grade: A (100%), B (80%+), C (60%+), F (<60%).

## Command: config

```bash
bash ~/.cursor/skills/save-token/scripts/load-config.sh [show|get|sources|init|apply]
```

Team config via `.save-token.json` in project root. Three-level precedence:
user override (`~/.save-token/config.json`) > team (`.save-token.json`) > defaults.

Subcommands:
- `show` — display merged config
- `get <key>` — get a value (dot notation: `compression.code`)
- `sources` — show which config files are active
- `init` — create template `.save-token.json`
- `apply` — apply merged config (sets mode + density)

## Command: lite / full / ultra

Switch intensity and persist the choice:

```bash
bash ~/.cursor/skills/save-token/scripts/mode.sh set <lite|full|ultra>
```

Announce the new mode in one line. Re-read agent-rules.md at the new intensity.

## Command: off

Persist deactivation and stop applying rules:

```bash
bash ~/.cursor/skills/save-token/scripts/mode.sh set off
```

Announce: "save-token deactivated."

## Intensity Reference

| Level | Code Ladder | Tool Discipline | Output Economy |
|-------|-------------|-----------------|----------------|
| lite  | Suggested   | Enforced        | Enforced       |
| full  | Enforced    | Enforced        | Enforced       |
| ultra | Extremist   | Enforced        | Extremist      |

See [rules/agent-rules.md](rules/agent-rules.md) for full details.

## Effort Routing (P2)

When the current task is MECHANICAL (>3 files, same transformation), delegate to a subagent:

```
Task tool prompt template:

"Apply the following transformation to each file listed below.
Files: {file_list}
Transformation: {pattern}
After each file, verify with: {verification_command}
Return: list of changed files + summary of changes."
```

Classification:
- TRIVIAL (≤1 file, no logic): do inline, note "trivial task"
- MECHANICAL (>3 files, repetitive): spawn cheap subagent
- COMPLEX (architecture, debugging): stay on current model

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Rules not applying | Check mode: `bash scripts/mode.sh get` — ensure not `off` |
| `install.sh` fails | Verify `~/.cursor/skills/` directory exists |
| `review.sh` finds no transcripts | Run during an active session (looks at last 60 min) |
| Hook not firing | Check `~/.cursor/hooks.json` matches `hooks/hooks.json.example` |
| `cost.sh` wrong model | Use: `opus`, `sonnet`, `haiku`, `gpt4o`, `o3` |

Quick check: `bash scripts/setup.sh --check` verifies all prerequisites.
