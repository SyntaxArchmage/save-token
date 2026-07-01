# save-token Cheat Sheet

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
| `/save-token bench` | A/B test |
| `/save-token setup` | Install Headroom |
| `/save-token cost` | Estimate $/month savings |
| `/save-token cost opus` | Cost for specific model |

## Code Ladder (stop at first rung)
1. YAGNI? Skip
2. Already exists? Reuse
3. Stdlib? Use it
4. One line? Do it
5. Minimum code

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
| Windsurf | `adapters/windsurfrules` → `.windsurfrules` |
| GitHub Copilot | `adapters/copilot-instructions.md` → `.github/` |

## Quick Stats (200-trial A/B data)
| Mode | Code | Explanation | Tool Calls |
|------|------|-------------|------------|
| Lite | -16% | -33% | -20% |
| Full | -24% | -75% | -34% |
| Ultra | -51% | -93% | -39% |

Zero correctness regressions across all 200 trials.
Opus full mode: ~$250/month savings at 100 req/day.
