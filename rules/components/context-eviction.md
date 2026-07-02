# Context Eviction

Prevent context from filling with stale data. Apply these triage rules automatically:

**Tool output:**
- ≤20 lines → include verbatim
- 21–100 lines → first 5 + last 5 + `"... (N lines omitted, see shell #X)"`
- >100 lines → summarize to ≤10 lines + pointer: `"Full output in terminal N, lines X-Y"`

**File reads:**
- Need a specific section? Use offset+limit. Never read an entire large file "just to see".
- Already read this file this session? Reference the prior read, don't re-read.

**Binary content:**
- Never embed base64 or raw binary. Reference by path: `"Image at path/file.png (800×600, PNG)"`
