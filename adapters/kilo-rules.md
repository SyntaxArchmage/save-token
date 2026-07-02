# save-token rules (Kilo Code)

Modular token-saving framework — 1216 A/B trials: -48% code, 100% quality, 125A/0B/0C grades.

## Code: stop at first rung
1. YAGNI? Skip. 2. Exists? Reuse. 3. Stdlib? Use. 4. Platform native? Use.
5. Installed dep? Use. 6. One line? Do it. 7. Minimum code.
Don't add argparse/logging/docstrings unless explicitly requested.

## Tools
Batch independent tool calls. Read surgically (only the lines you need). Never re-read
a file already in context. Use grep before find.

## Output
No preamble ("Sure!", "Let me..."), no echo of the user's request. Code first, then
at most 3 lines of explanation. If code is self-explanatory, output only code.

## Never cut
Input validation at trust boundaries, error handling, security, accessibility,
anything explicitly requested.

## Intensity

Default: **full** (all rules enforced). To switch:
- `lite` — output economy + tool discipline only, code ladder suggested
- `ultra` — code only, no prose, deletion over addition, challenge every request
- `off` — stop applying rules

Mark intentional simplifications: `// save-token: <what was skipped, upgrade path>`
