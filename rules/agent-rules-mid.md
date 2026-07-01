# save-token Agent Rules (mid)

Active every response. Off: `/save-token off`. Default: **full**.

## Code Ladder

Stop at the first rung that holds:

1. YAGNI? Skip. Say so in one line.
2. Already in codebase? Reuse.
3. Standard library does it? Use it.
4. Native platform feature? Use it.
5. Installed dependency solves it? Use it.
6. One line? One line.
7. Only then: minimum code that works.

Read the code first, trace the flow, then climb. Bug fix = root cause.
Don't add argparse, logging, docstrings, type stubs, or config unless asked.

## Tool Discipline

- **Batch** independent calls — never serialize parallel work.
- **Surgical reads** — offset+limit when only a section needed.
- **No re-reads** — file in context doesn't get read again.
- **Grep/Glob first** — before Shell find/grep.
- **3 levels max** — then ask the user.

## Output Economy

- No preamble, no echo of user's question.
- Code references (`startLine:endLine:path`) for existing code.
- Diff-sized edits (tight StrReplace, not file rewrites).
- Code first, max 3 lines explanation. Zero prose if self-explanatory.
  Bad: 15 lines code + 20 lines explaining each.
  Good: 15 lines code + "Uses stdlib csv.DictReader."

## Context Hygiene

- Targeted @mentions. `.cursorignore` excludes node_modules/dist/build/.env.
- alwaysApply rules under 200 words.
- `/summarize` at 60% context. New chat per unrelated task.

## Context Eviction

Tool output triage:
- ≤20 lines: verbatim
- 21-100: first 5 + last 5 + "... (N omitted, see shell #X)"
- >100: summarize ≤10 lines + pointer reference

File reads: surgical (offset+limit). No re-reads. No base64 — reference by path.
After 10+ turns → suggest `/summarize`. After 20+ → strongly recommend.

## Effort Routing

| Class | Signal | Action |
|-------|--------|--------|
| TRIVIAL | ≤1 file, no logic | Inline. Note it's trivial. |
| MECHANICAL | >3 files, repetitive | Subagent: file list + transformation + verify. |
| COMPLEX | Architecture, debug | Stay on current model. |

## Never Cut

- Input validation at trust boundaries
- Error handling preventing data loss
- Security, accessibility
- Anything explicitly requested

Mark skips: `// save-token: <what was skipped, upgrade path>`
