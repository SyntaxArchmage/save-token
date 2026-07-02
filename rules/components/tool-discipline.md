# Tool Discipline

- **Batch independent calls** — never serialize what can run in parallel.
  Bad: Read(a.py), then Read(b.py), then Read(c.py) — 3 turns.
  Good: Read(a.py) + Read(b.py) + Read(c.py) — 1 turn.
- **Surgical reads** — use offset + limit when you only need a section. Never read a whole file when 20 lines suffice.
- **No re-reads** — a file already in this conversation does not get read again unless it changed.
- **Grep/Glob first** — use Grep and Glob tools before Shell find/grep.
- **Depth limit** — if 3 levels of search don't find it, ask the user.
- **One clarifying question early** — beats exploring 3 wrong paths.
