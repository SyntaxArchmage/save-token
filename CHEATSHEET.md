# save-token Cheat Sheet

Modular token-saving framework — 6 layers, each targeting a waste category, all A/B validated.

## Commands
| | |
|-|-|
| `/save-token` | Show mode |
| `/save-token full` | Default intensity |
| `/save-token ultra` | Maximum savings |
| `/save-token lite` | Gentle mode |
| `/save-token off` | Deactivate |
| `/save-token stats` | Show metrics |
| `/save-token learn` | Mine past sessions |
| `/save-token review` | Audit current session |
| `/save-token bench` | A/B test on your prompts |
| `/save-token compress` | Compress content (auto engine) |
| `/save-token verbosity` | Verbosity profile + recommendation |
| `/save-token setup` | Install engines + hooks |
| `/save-token cost` | Estimate $/month savings |
| `/save-token tokens` | Track real token usage |
| `/save-token config` | Team config (show/apply/init) |
| `/save-token progress` | Progressive activation |
| `/save-token quality` | Dev quality benchmarks |

## Code Ladder (stop at first rung)
1. YAGNI? Skip
2. Already exists? Reuse
3. Stdlib? Use it
4. Platform native? Use it
5. Installed dep? Use it
6. One line? Do it
7. Minimum code

## Tool Rules
- Batch independent calls
- Surgical reads (offset+limit)
- No re-reads
- Grep/Glob first, Shell last

## Output Rules
- No preamble, no echo
- Code references for existing code
- Zero prose if self-explanatory
- Max 3 lines otherwise

## Ultra Extras
- Challenge every request
- Deletion > addition
- Single-expression preferred
- Code block only, no prose

## Model Routing
| Task | Model |
|------|-------|
| Autocomplete | Fast (Haiku, Flash) |
| Features | Mid (Sonnet, 4o) |
| Architecture | Premium (Opus, o3) |

## Context Hygiene
- `.cursorignore` for deps/build/locks
- `/summarize` at 60% context
- New chat per task
- `@file` over `@folder`

## Troubleshooting
| Issue | Quick fix |
|-------|-----------|
| Not working | `bash scripts/mode.sh get` — is it `off`? |
| No transcripts | Run during active session (60 min window) |
| Install fail | `mkdir -p ~/.cursor/skills && bash install.sh` |

## Auto-Activation
```bash
cp hooks/hooks.json.example ~/.cursor/hooks.json
```

## Adapters
| IDE | File |
|-----|------|
| Claude Code | `adapters/AGENTS.md` → project root |
| CodeBuddy | `adapters/codebuddy-rule.md` → `~/.codebuddy/rules/` |
| Windsurf | `adapters/windsurfrules` → `.windsurfrules` |
| GitHub Copilot | `adapters/copilot-instructions.md` → `.github/` |
| Generic CLI | `adapters/system-prompt.txt` → system prompt |

## Density Variants
| Variant | Words | Use for |
|---------|-------|---------|
| kernel | 177 | alwaysApply, API system prompts |
| mid | 368 | Project-level rules |
| full | 1123 | Complete feature set |

Install: `bash install.sh --density=kernel|mid|full`

## Optimization Layers
| Layer | Targets |
|-------|---------|
| Code Ladder | Over-engineered output |
| Tool Discipline | Redundant tool calls |
| Output Economy | Verbose prose |
| Effort Routing | Wrong model for task |
| Context Hygiene | Stale/bloated context |
| Compression | Raw input tokens (pluggable engines) |

Configure per-team via `.save-token.json` (3-level precedence: user > team > defaults).

## Quick Stats (266-trial A/B data)
| Mode | Code | Explanation | Tool Calls |
|------|------|-------------|------------|
| Lite | -16% | -33% | -20% |
| Full | -24% | -75% | -34% |
| Ultra | -51% | -93% | -39% |

Quality: 25A/0B/0C vs baseline 19A/5B/1C (50 trials, 25 SE benchmarks).
100% correctness vs baseline 99.1%. Opus full: ~$250/mo savings at 100 req/day.
