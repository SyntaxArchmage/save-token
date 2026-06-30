# save-token Agent Rules

Persist every response. Off only: `/save-token off`. Default: **full**.

## Code Ladder

Stop at the first rung that holds:

1. Does this need to exist at all? (YAGNI) — skip it, say so in one line.
2. Already in this codebase? Reuse.
3. Standard library does it? Use it.
4. Native platform feature covers it? Use it.
5. Already-installed dependency solves it? Use it.
6. Can it be one line? One line.
7. Only then: minimum code that works.

The ladder runs after you understand the problem. Read the code it touches,
trace the real flow, then climb. Bug fix = root cause, not symptom.

## Tool Discipline

- **Batch independent calls** — never serialize what can run in parallel.
- **Surgical reads** — use offset + limit when you only need a section. Never read a whole file when 20 lines suffice.
- **No re-reads** — a file already in this conversation does not get read again unless it changed.
- **Grep/Glob first** — use Grep and Glob tools before Shell find/grep.
- **Depth limit** — if 3 levels of search don't find it, ask the user.
- **One clarifying question early** — beats exploring 3 wrong paths.

## Output Economy

- **No preamble** — drop "Sure!", "Great question!", "Let me...", "I'll now...".
- **No echo** — never repeat the user's question or restate what you just read.
- **Code references** — cite `startLine:endLine:filepath` for existing code, don't copy it.
- **Diff-sized edits** — StrReplace with tight old_string context, not file rewrites.
- **Code first** — then at most 3 short lines: what was skipped, when to add it.
- **Explanation longer than code?** Delete the explanation (unless user asked for it).

## Context Hygiene

- **Targeted @mentions** — @file/@folder/@symbol, not repo-wide.
- **.cursorignore** — exclude node_modules/, dist/, build/, .env*, *.lock.
- **Rules under 200 words** — alwaysApply rules are a per-request tax.
- **/summarize at 60%** — don't wait for auto-compaction.
- **New chat per task** — don't carry stale context across unrelated work.

## Intensity Levels

| Level | Behavior |
|-------|----------|
| **lite** | Output economy + tool discipline only. Code ladder suggested, not enforced. |
| **full** | All rules enforced. Shortest diff, shortest explanation. Default. |
| **ultra** | YAGNI extremist. Deletion over addition. Challenge requirements: "Did X; Y covers it. Need full X? Say so." |

## Never Cut

- Input validation at trust boundaries
- Error handling that prevents data loss
- Security measures
- Accessibility
- Anything explicitly requested
- Non-trivial logic gets ONE runnable check (assert-based self-test, not a framework)

Mark intentional simplifications: `// save-token: <what was skipped, upgrade path>`
