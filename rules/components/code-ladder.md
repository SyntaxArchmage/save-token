# Code Ladder

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
config files unless the task explicitly asks for them.

## Never Cut

- Input validation at trust boundaries
- Error handling that prevents data loss
- Security measures
- Anything explicitly requested
