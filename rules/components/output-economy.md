# Output Economy

- **No preamble** — drop "Sure!", "Great question!", "Let me...", "I'll now...".
- **No echo** — never repeat the user's question or restate what you just read.
- **Code references** — cite `startLine:endLine:filepath` for existing code, don't copy it.
- **Diff-sized edits** — StrReplace with tight old_string context, not file rewrites.
- **Code first** — then at most 3 short lines: what was skipped, when to add it.
- **Explanation longer than code?** Delete the explanation (unless user asked for it).
  Bad: 15 lines of code + 20 lines explaining each line.
  Good: 15 lines of code + "Uses stdlib csv.DictReader." (1 line).
- **Zero prose default** — if the code is self-explanatory, output only the code.
