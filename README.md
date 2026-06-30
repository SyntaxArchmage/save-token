# save-token

A Cursor skill that combines battle-tested techniques to minimize token consumption when working with expensive AI models (Opus, o3, etc.) — without sacrificing output quality.

## Why

Expensive models burn through tokens fast. Most of the waste comes from a handful of recurring patterns: bloated context, redundant reads, over-eager exploration, and verbose prompts. This skill encodes the fixes as enforceable rules so every session starts lean.

## Techniques

### Context Management
- **Surgical reads** — read only the lines you need (`offset` + `limit`), never the whole file when a section suffices
- **Batch tool calls** — combine independent reads, greps, and globs into a single turn instead of sequential round-trips
- **Kill redundant context** — don't re-read files already in conversation; reference prior results instead

### Prompt Compression
- **Terse system instructions** — strip filler words, use shorthand, bullet points over prose
- **Minimal diffs** — use `StrReplace` with tight `old_string` context instead of rewriting entire files
- **No echo-back** — never repeat the user's question or restate what you just read

### Exploration Discipline
- **Targeted search** — use `Glob` / `Grep` with precise patterns before resorting to broad scans
- **Scope gates** — ask one clarifying question early rather than exploring three wrong paths
- **Depth limits** — cap recursive exploration; if you haven't found it in 3 levels, ask the user

### Output Economy
- **Answer-only responses** — skip preamble ("Sure!", "Great question!"), hedging, and restating
- **Code references over code blocks** — cite `startLine:endLine:filepath` for existing code instead of copying it into the response
- **Diff-sized edits** — show only what changed, not the surrounding unchanged code

### Delegation & Parallelism
- **Subagents for mechanical work** — offload compiles, git ops, file search to cheap subagents; keep the expensive model focused on reasoning
- **Parallel tool calls** — never serialize independent operations; batch everything that can run concurrently

### Caching Awareness
- **Prompt-cache-friendly ordering** — put stable instructions (system prompt, rules) first; variable content (user query, file contents) last
- **Minimize context churn** — avoid rewriting or reordering early context that invalidates the KV cache

## Usage

Add this skill to your Cursor workspace:

```
~/.cursor/skills/save-token/SKILL.md
```

Or reference it in `.cursor/rules/` to auto-apply on every session.

## Status

🚧 Under active development — techniques will be added and refined as real-world savings are measured.

## License

MIT
