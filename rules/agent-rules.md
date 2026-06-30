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

**Spec-only scope**: don't add argparse, logging, docstrings, type stubs, or
config files unless the task explicitly asks for them. A/B testing shows these
account for 43% of code bloat in complex tasks.

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
- **Zero prose default** — if the code is self-explanatory, output only the code. A/B data: this alone cuts output tokens by 76%.

## Context Hygiene

- **Targeted @mentions** — @file/@folder/@symbol, not repo-wide.
- **.cursorignore** — exclude node_modules/, dist/, build/, .env*, *.lock.
- **Rules under 200 words** — alwaysApply rules are a per-request tax.
- **/summarize at 60%** — when the agent warns about context usage, summarize proactively.
  Don't wait for auto-compaction which loses precision. Manual summarize preserves intent.
- **New chat per task** — don't carry stale context across unrelated work.
  Exception: multi-step tasks that share state (e.g., A/B tests across same codebase).

## Intensity Levels

| Level | Behavior |
|-------|----------|
| **lite** | Output economy + tool discipline only. Code ladder suggested, not enforced. |
| **full** | All rules enforced. Shortest diff, shortest explanation. Default. |
| **ultra** | YAGNI extremist. See ultra rules below. |

## Ultra Mode

When intensity is `ultra`, apply these additional constraints:

- **Challenge every request**: before implementing, ask "is this the simplest
  way?" If yes, do it in the fewest lines. If no, propose the simpler approach
  and only do the original if user insists.
- **Deletion over addition**: if you can solve by removing code, prefer that.
  Example: "Removed unused import and dead branch — that was the bug."
- **Single-expression preference**: if a function body is one expression,
  use a lambda or inline it. Don't wrap trivial logic in functions.
- **No intermediate variables** unless they clarify non-obvious logic.
- **Response format**: code block only. No prose unless user asks "why".
  If you must explain, one sentence max.

## Never Cut

- Input validation at trust boundaries
- Error handling that prevents data loss
- Security measures
- Accessibility
- Anything explicitly requested
- Non-trivial logic gets ONE runnable check (assert-based self-test, not a framework)

Mark intentional simplifications: `// save-token: <what was skipped, upgrade path>`

## Model Routing (user-side)

Match model cost to task complexity:

| Task Type | Recommended Model Tier | Why |
|-----------|----------------------|-----|
| Autocomplete, renames | Fast (Haiku, GPT-4o-mini, Gemini Flash) | Predictable output, low complexity |
| Standard features, debugging | Mid (Sonnet, GPT-4o) | Good balance of quality and cost |
| Architecture, complex refactor, research | Premium (Opus, o3, Gemini Pro) | Needs deep reasoning |

Switch models mid-session when complexity changes. Don't use Opus for boilerplate.
