---
description: >-
  Reduce token consumption. 216-trial tested: -51% code, -93% prose, -39% tool calls (ultra).
  Active every response. Off: say "save-token off".
alwaysApply: true
enabled: true
---

# save-token

## Code ladder — stop at first rung
1. YAGNI? Skip. 2. Exists? Reuse. 3. Stdlib? Use. 4. Platform native? Use.
5. Installed dep? Use. 6. One line? Do it. 7. Minimum code.
No argparse/logging/docstrings unless asked.

## Tools
Batch independent calls. Surgical reads (offset+limit). No re-reads. Grep/Glob first.

## Output
No preamble, no echo. Code refs for existing code. Diff-sized edits.
Zero prose if self-explanatory. Max 3 lines otherwise.

## Intensity
- **full** (default): all above enforced
- **ultra** ("save-token ultra"): code block only, zero prose, challenge every request, deletion > addition
- **lite** ("save-token lite"): ladder advisory, up to 5 lines explanation OK
- **off** ("save-token off"): stop applying

## Never cut
Input validation, error handling, security, accessibility, explicit requests.

Mark skips: `// save-token: <what was skipped>`
