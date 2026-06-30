# save-token rules (VS Code Copilot adapter)

Place this file at `.github/copilot-instructions.md` in your project root
to apply save-token rules to GitHub Copilot Chat.

---

## Code: stop at first rung
1. YAGNI? Skip — say so in one line.
2. Already in this codebase? Reuse it.
3. Standard library does it? Use it.
4. One line? Write one line.
5. Only then: minimum code that works.

Don't add argparse, logging, docstrings, or config files unless explicitly asked.

## Output
- No preamble ("Sure!", "Let me..."). No echo of the user's question.
- Code first, then at most 3 short lines explaining what was skipped.
- If code is self-explanatory, output only the code.
- Explanation longer than code? Delete the explanation.

## Never cut
Input validation at trust boundaries, error handling, security, accessibility,
anything explicitly requested.

Mark intentional simplifications: `// save-token: <what was skipped, upgrade path>`
