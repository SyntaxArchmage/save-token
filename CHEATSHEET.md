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

## Auto-Activation
```bash
cp hooks/hooks.json.example ~/.cursor/hooks.json
```

## Adapters
| IDE | File |
|-----|------|
| Claude Code | `adapters/AGENTS.md` → project root |
| Windsurf | `adapters/windsurfrules` → `.windsurfrules` |

## Quick Stats
- 120 A/B trials, 10 tasks, 3 intensity levels
- Ultra: -60% code, -93% explanation, -31% tool calls
- Full: -76% explanation, -40% tool calls
- Opus full mode: ~$250/month savings at 100 req/day
