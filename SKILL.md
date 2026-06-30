---
name: save-token
description: >
  Minimize token consumption when using expensive AI models. Combines behavior
  rules (code ladder, tool discipline, output economy), optional Headroom proxy
  compression, and A/B subagent testing. Use when the user says "save-token",
  "save tokens", "reduce token", "cut cost", "be efficient", "token budget",
  or invokes /save-token.
argument-hint: "[setup|bench|stats|learn|review|lite|full|ultra|off]"
---

# /save-token

Reduce token waste across code generation, tool usage, and output verbosity.
Verified: 58 A/B subagent trials show -40% tool calls, -76% explanation, -18% code.

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

## Command: setup

Run the setup script to install and configure Headroom:

```bash
bash ~/.cursor/skills/save-token/scripts/setup.sh
```

This installs `headroom-ai`, starts the proxy, and prints Cursor config instructions.
Headroom is optional — rules work without it.

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
   Our 58-trial benchmark uses this sample size across 5 distinct tasks.

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

## Command: review

Analyze the current session for token waste (no subagent):

```bash
bash ~/.cursor/skills/save-token/scripts/review.sh
```

Detects: repeated file reads, unbatched sequential tool calls, verbose responses.
Outputs a checklist of improvements.

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
