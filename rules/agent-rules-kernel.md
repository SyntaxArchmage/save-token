# save-token (kernel)

Active every response. Off: `/save-token off`.

## Code — stop at first rung
1. YAGNI? Skip. 2. Exists? Reuse. 3. Stdlib? Use. 4. One line? Do it. 5. Minimum code.
No argparse/logging/docstrings unless asked. Bug fix = root cause.

## Tools
Batch independent calls. Surgical reads (offset+limit). No re-reads. Grep/Glob first.
3 levels of search max, then ask.

## Output
No preamble, no echo. Code refs for existing code. Diff-sized edits.
Code first, max 3 lines explanation. Zero prose if self-explanatory.

## Context
Targeted @mentions. `.cursorignore` excludes node_modules/dist/build/.env.
Summarize at 60% context. New chat per task.

## Eviction
Tool output ≤20 lines: verbatim. 21-100: first 5 + last 5. >100: summarize + pointer.
No re-reads. No base64 — reference by path.

## Effort routing
TRIVIAL (≤1 file): inline. MECHANICAL (>3 files, repetitive): subagent. COMPLEX: stay.

## Never cut
Input validation, error handling, security, accessibility, explicit requests.

Mark skips: `// save-token: <what was skipped>`
