# save-token Roadmap

## Design Constraints (from user feedback)

1. **Multi-platform** — NOT Cursor-only. Must support: Cursor IDE, Cursor CLI, Claude Code, CodeBuddy IDE, CodeBuddy CLI (if exists)
2. **Reuse building blocks** — Don't reinvent. Integrate existing tools (compressors, caches, proxies) as modules
3. **Learn from all research** — We researched 56 techniques across 11 categories. Use them.

---

## Ref Projects — What We Can Reuse

From our original research (56 techniques), these have **reusable building blocks**:

### Compression Layer (integrate as optional modules)

| Project | What it does | How we reuse | Stars |
|---------|-------------|--------------|-------|
| **Claw Compactor** | 14-stage AST-aware code compression, reversible | Pipe context through it before feeding to model | 2.2k |
| **LLMLingua-2** (Microsoft) | Perplexity-based prompt pruning, 30-70% | Use for long context summarization | 5k+ |
| **token-compressor** (base76) | Local LLM compress + embedding verify | Alternative to LLMLingua for code | new |
| **Headroom CCR** | Reversible context compression, 60-95% | Already integrated via setup.sh | 54k |

### Context Virtualization (reuse architecture patterns)

| Project | What it does | How we reuse |
|---------|-------------|--------------|
| **ClawVM** | Typed page + 4-level resolution (full/compressed/structured/pointer) | Design pattern for our context diet rules |
| **Pichay / Demand Paging** | 4-layer memory hierarchy (L1-L4) | Inspiration for progressive summarization |
| **Memory Pointer Pattern** | Store large outputs externally, keep pointers in context, 7x compression | Rule: "shell output > 100 lines → summarize to pointer" |
| **Mem0** | External persistent memory | Pattern for cross-session learning storage |

### Reasoning Optimization (integrate as rules)

| Project | What it does | How we reuse |
|---------|-------------|--------------|
| **SGP-CoT** | Self-guided pruning of redundant reasoning | Rule: "don't narrate your thinking process" |
| **CRISP** | Attention-saliency pruning, 50-60% token reduction | Validates our "zero prose default" rule |
| **Reasoning Token Budget** (OpenAI) | max_completion_tokens cap | Rule: set token budget on reasoning models |

### Caching (integrate as setup options)

| Project | What it does | How we reuse |
|---------|-------------|--------------|
| **Prompt Caching** (Anthropic/OpenAI native) | Cache system prompt prefix | Rule: "keep alwaysApply rules stable to hit cache" |
| **Semantic cache** (GPTCache etc) | Cache similar queries | Optional setup.sh module |

### Agent Loop Prevention (already in our rules, can strengthen)

| Project | What it does | How we reuse |
|---------|-------------|--------------|
| **Ponytail** | Decision ladder prevents over-engineering | Already integrated |
| **MCP tool_choice: none** | Prevent unnecessary tool calls | Add to tool discipline: "if answer is in context, don't call tools" |
| **Debounce Hook** (AWS) | Sliding window detects duplicate tool calls, blocks 3rd repetition | Port as Cursor/Claude Code hook |
| **Circuit Breaker** (LangGraph) | Monitors failure rates, auto-breaks on threshold | Pattern for our review.sh scoring |

### MCP & Tool Optimization (reuse designs)

| Project | What it does | How we reuse |
|---------|-------------|--------------|
| **Code Mode** (Cloudflare/FastMCP) | Replace tool catalog with `search()+execute()` meta-tools, 58-99.9% | Design pattern: "fewer tools = fewer description tokens" |
| **Tool Search Tool** (Anthropic) | `defer_loading: true` — discover tools on-demand | Rule: suggest users enable deferred tool loading |
| **mcp-compressor** | Proxy MCP servers to add on-demand discovery | Integrate: wrap existing MCP with discovery layer |
| **Token-Efficient Tool Use** | Truncate large outputs, paginate, demand-driven | Already in our tool discipline rules |

### Model Routing & Cascading (architecture patterns)

| Project | What it does | How we reuse |
|---------|-------------|--------------|
| **FrugalGPT** | Try cheapest model first, escalate if quality below threshold, up to 98% savings | Inspiration for our effort routing (P2) |
| **LiteLLM** | Gateway with routing policies, spend tracking | Recommend as infrastructure for power users |
| **RouteLLM** | Pre-generation classifier routes to cheapest capable model | Pattern for subagent model selection |

### Observability (integrate as optional modules)

| Project | What it does | How we reuse |
|---------|-------------|--------------|
| **Helicone** | Per-user per-feature dollar attribution, budget alerts | Optional: `setup.sh --tracking=helicone` |
| **LangFuse** | Self-hostable agent tracing, cost analysis | Optional: for enterprise users |
| **`docs/ai-context.md`** pattern | Pre-computed repo summary eliminates rediscovery | Rule: "create ai-context.md for large repos" |

---

## v0.4.0 — Current Round

### P0: Multi-Platform Architecture ✅ DONE

**Status:** Implemented. 8 adapters + `install.sh --platform` + `pre-prompt.sh`.

| Platform | Rules delivery | Adapter file | Install command |
|----------|---------------|-------------|-----------------|
| Cursor IDE/CLI | SKILL.md + .mdc | `standalone.mdc` | `install.sh heavy --platform=cursor` |
| Claude Code | AGENTS.md | `AGENTS.md` | `install.sh light --platform=claude-code` |
| CodeBuddy IDE/CLI | `.codebuddy/rules/` + CODEBUDDY.md | `codebuddy-rule.md`, `CODEBUDDY.md` | `install.sh heavy --platform=codebuddy` |
| GitHub Copilot | `.github/copilot-instructions.md` | `copilot-instructions.md` | Manual copy |
| Windsurf | `.windsurfrules` | `windsurfrules` | Manual copy |
| Any LLM CLI | Pipe via pre-prompt.sh | `system-prompt.txt`, `pre-prompt.sh` | `install.sh light --platform=generic` |

Core rules (`rules/agent-rules.md`) are platform-agnostic. All scripts work on any platform with bash+python3.

---

### P1: Content-Type-Aware Compression Pipeline

**Problem:** Context is not homogeneous. Code, natural language, tool outputs, and binary references have fundamentally different structures. A single compressor cannot optimize all types. Headroom understands this (separate CCR for code, output shaper for responses), but we need to go further.

**Core idea:** Classify context by content type → route to best compressor per type → A/B test each combination.

#### Content Type Taxonomy

| Type | Examples | Characteristics | Current waste pattern |
|------|---------|-----------------|----------------------|
| **Code** | Source files, diffs, generated code | Structural, AST-parseable, whitespace-significant | Full file reads when only 5 lines needed |
| **Natural Language** | Explanations, docs, README | Redundant, filler-heavy, compressible | Verbose agent prose, repeated context |
| **Tool Output** | Shell stdout, git log, test results | Structured/semi-structured, often huge | 500-line outputs when 10 lines matter |
| **Conversation History** | Prior turns, summaries | Grows linearly, old turns decay in relevance | No eviction, context fills up |
| **Metadata** | File paths, line numbers, tool schemas | Repetitive, low entropy | Tool definitions repeated every call |
| **Binary References** | Images, PDFs, media files | Cannot compress textually | Base64 in context (waste), should be pointer |

#### Compressor × Content Type Matrix

| Content Type | Candidate A | Candidate B | Candidate C | Baseline |
|-------------|------------|------------|------------|----------|
| **Code** | Claw Compactor (AST-aware, 15-82%, reversible, zero LLM cost) | Headroom CCR (reversible, 60-95%) | Tree-sitter strip (remove comments+whitespace) | Raw (no compression) |
| **Natural Language** | LLMLingua-2 (perplexity pruning, 30-70%) | Semantic Compressor (spaCy rules, ~22%) | Headroom output shaper | Raw |
| **Tool Output** | Memory Pointer Pattern (summarize→pointer, 7x) | Line-budget truncation (keep first+last N lines) | Structured extraction (parse JSON/table, drop rest) | Raw |
| **Conversation History** | Rolling summary (LLM summarize every N turns) | Pichay demand paging (L1-L4 hierarchy) | Token-budget eviction (oldest first, keep last 3 turns) | Raw |
| **Metadata** | Schema dedup (send tool schemas once, reference by ID) | mcp-compressor (on-demand tool discovery) | Terse key names (short field names) | Raw |
| **Binary References** | Pointer-only (hash + path, no content) | — | — | Base64 embed |

#### A/B Test Plan per Content Type

Each content type needs independent benchmarking:

```
scripts/compress-bench.sh --type=code    --engine=claw       --trials=20
scripts/compress-bench.sh --type=code    --engine=headroom   --trials=20
scripts/compress-bench.sh --type=code    --engine=treesitter --trials=20
scripts/compress-bench.sh --type=text    --engine=llmlingua  --trials=20
scripts/compress-bench.sh --type=text    --engine=semantic   --trials=20
scripts/compress-bench.sh --type=tool    --engine=pointer    --trials=20
scripts/compress-bench.sh --type=tool    --engine=truncate   --trials=20
scripts/compress-bench.sh --type=history --engine=rolling    --trials=20
```

**Metrics per trial:**
- `compression_ratio` — bytes before / bytes after
- `information_loss` — does the agent still produce correct output? (binary: pass/fail)
- `latency_overhead` — compression time added (ms)
- `reversibility` — can original be reconstructed? (for code: critical; for NL: optional)
- `cost_delta` — estimated token cost difference

**Test methodology:**
1. Prepare 5+ representative inputs per content type (varying sizes: small/medium/large)
2. Run each compressor on each input
3. Feed compressed version to agent with same task prompt
4. Compare agent output quality (correctness, completeness) vs uncompressed baseline
5. Record all metrics, aggregate by content type × compressor

#### Implementation: `scripts/compress.sh`

```bash
scripts/compress.sh --type=<type> --engine=<engine> < input > output

# Auto-detect content type if --type not specified:
#   .py/.js/.ts/.rs → code
#   .md/.txt/.rst   → text
#   (stdin from shell) → tool_output
#   (conversation JSON) → history

# Engines are installed on-demand:
#   compress.sh --install=claw      → pip install claw-compactor
#   compress.sh --install=llmlingua → pip install llmlingua
#   compress.sh --install=headroom  → pip install headroom-ai
```

**Key design decisions:**
- Type detection is heuristic but overridable
- Each engine is a thin wrapper script in `scripts/engines/`
- Engines are lazy-installed — no upfront dependency burden
- `--engine=none` is always available (pure behavioral rules)
- Engines can stack: `--engine=claw,pointer` (compress code, then pointer-wrap if still large)

#### Comparison with Headroom's approach

| Aspect | Headroom | save-token P1 |
|--------|----------|---------------|
| Content type awareness | Yes (CCR for code, output shaper for NL) | Yes, 6 content types with dedicated engines |
| Compressor options | Headroom-only (proprietary CCR) | Pluggable: Claw, LLMLingua, Headroom, custom |
| A/B validation | No per-type benchmarks | Per-type × per-engine A/B matrix |
| Reversibility | Yes (CCR is reversible) | Per-engine: Claw yes, LLMLingua no, Pointer partial |
| Install weight | Heavy (`headroom wrap cursor`) | Modular: each engine optional, lazy-install |
| Platform | Cursor + Claude Code | Any platform with bash + python3 |

---

### P2: Effort Routing via Subagent

**Problem:** Premium models (Opus, o3) handle trivial tasks (rename variable, add comment, format file) that don't need deep reasoning. Switching models mid-session breaks prompt cache.

**Key constraint:** We cannot switch the main agent's model. But subagents start fresh — they have no cache to break.

#### Task Complexity Classification

Add to `agent-rules.md`:

```
Before each task, classify complexity:

TRIVIAL (≤1 file, no logic change):
  rename, format, add comment, delete dead code, move import
  → Suggest user: "This is trivial — consider using a cheaper model next time"
  → Do it inline (not worth subagent overhead)

MECHANICAL (>3 files, repetitive, no reasoning):
  bulk rename across project, generate test stubs, update imports after move,
  apply same fix to N files, format/lint entire codebase
  → Spawn subagent with explicit file list + transformation rule
  → Subagent model: cheapest available (e.g. composer-2.5-fast)

COMPLEX (architecture, debugging, novel logic):
  → Stay on current model. Full context needed.
```

#### Subagent Delegation Protocol

```
Main agent (expensive, warm cache):
  1. Identify MECHANICAL task
  2. Prepare delegation package:
     - Exact file list
     - Transformation rule (regex, AST pattern, or natural language)
     - Expected output format
     - Verification command (how to check correctness)
  3. Spawn Task subagent with package
  4. Verify result with spot-check (read 2-3 files)
  5. Continue with main task

Subagent (cheap, cold start):
  - Receives explicit instructions (no exploration needed)
  - Executes mechanical transformation
  - Returns changed file list + summary
```

#### Multi-Platform Effort Routing

| Platform | Subagent mechanism | Model selection |
|----------|-------------------|-----------------|
| Cursor IDE/CLI | Task tool | Model slug parameter (if user's plan allows) |
| Claude Code | `claude --model` subprocess | Direct model flag |
| CodeBuddy | TBD (research subagent API) | TBD |
| Generic | Script: call API with cheaper model | User configures in `~/.save-token/config` |

#### What NOT to route

- Anything requiring main agent's accumulated context
- Tasks touching security-sensitive code
- Debugging (needs full conversation history)
- Tasks the user explicitly asked the main agent to do

#### A/B Test Plan

```
scripts/effort-bench.sh --task=bulk-rename --model=opus      --trials=10
scripts/effort-bench.sh --task=bulk-rename --model=fast       --trials=10
scripts/effort-bench.sh --task=test-stubs  --model=opus      --trials=10
scripts/effort-bench.sh --task=test-stubs  --model=fast       --trials=10
```

Metrics: `correctness` (pass/fail), `cost` ($), `latency` (s), `context_tokens_saved` on main agent

---

### P3: Verbosity Self-Adaptation

**Problem:** Fixed explanation limits (0/3/5 lines per mode) don't match all users. Some want more explanation, some want zero.

**Inspiration:** Headroom's output shaper learns from corrections. We adapt this for behavioral rules.

#### Detection Signals

Mine from `learn.sh` (agent-transcripts analysis):

| Signal | Meaning | Action |
|--------|---------|--------|
| User says "explain more" / "why" / "how does this work" | Too terse | Lower intensity (ultra→full, full→lite) |
| User says "just do it" / "skip explanation" / "too verbose" | Too verbose | Raise intensity (lite→full, full→ultra) |
| User never asks follow-up questions | Current level is fine | Keep current |
| User re-asks same question differently | Agent's answer was unclear | Keep intensity but improve clarity |
| Average response length > 500 words | Potentially too verbose | Suggest raising intensity |

#### Learning Loop

```
learn.sh --verbosity-profile

Output:
  Sessions analyzed: 15
  "explain more" frequency: 2/15 (13%)
  "too verbose" frequency: 5/15 (33%)
  Average explanation lines: 8.2
  
  Recommendation: Switch from FULL → ULTRA
  Confidence: HIGH (>30% "too verbose" signals)
  
  Run: save-token ultra
```

#### Storage

```
~/.save-token/verbosity-profile.json
{
  "sessions_analyzed": 15,
  "signals": {
    "explain_more": 2,
    "too_verbose": 5,
    "no_followup": 8
  },
  "current_mode": "full",
  "recommended_mode": "ultra",
  "last_updated": "2026-07-01"
}
```

#### Auto-Adaptation (opt-in)

```bash
# In mode.sh:
save-token --auto    # apply learned preference
save-token --auto-suggest  # suggest but don't auto-apply (safer default)
```

---

### P4: Rules Density Optimization

**Problem:** `agent-rules.md` is ~1100 words ≈ ~1500 tokens. This is paid on EVERY request as context tax.

**Question:** Can we compress to ~500 words without losing effectiveness?

#### Current Rule Structure

```
agent-rules.md (~1100 words):
├── Code Ladder (7 rungs)        ~200 words
├── Tool Discipline (6 rules)    ~250 words  
├── Output Economy (5 rules)     ~200 words
├── Never-Cut list               ~100 words
├── Mode definitions             ~150 words
├── Examples (bad/good)          ~150 words
└── Metadata / headers           ~50 words
```

#### Compression Strategy: Create 3 Variants

**Variant A — Kernel (~500 words):**
Remove examples, merge mode definitions inline, compress rules to telegraphic style.
Essentially `standalone.mdc` extended slightly.

**Variant B — Mid (~750 words):**
Keep examples for top-3 waste patterns (batch calls, surgical reads, zero prose).
Remove mode definitions (handled by mode.sh injection).

**Variant C — Full (~1100 words, current):**
No change. Baseline.

#### A/B Test Design

```
scripts/density-bench.sh --variant=kernel  --trials=30
scripts/density-bench.sh --variant=mid     --trials=30
scripts/density-bench.sh --variant=full    --trials=30
```

**Metrics:**
- `rule_compliance` — does agent follow each rule? (checklist per trial)
- `token_cost` — context tokens per request
- `output_quality` — same task prompt, compare code correctness
- `waste_score` — review.sh score on session

**Expected outcome:** If kernel achieves ≥90% compliance of full, switch default to kernel. Save ~1000 tokens/request × ~50 requests/session = ~50k tokens/session.

#### Prompt Cache Implication

Shorter rules = smaller cached prefix = faster cache hit. But rules must be STABLE — changing rules between requests breaks cache. So we pick ONE variant and stick with it per session.

---

### P5: Context Eviction & Pointer Pattern

**Problem:** Agent context fills up with stale tool outputs, old conversation turns, and large file reads. No eviction strategy exists — context grows monotonically until `/summarize`.

**Inspiration:** ClawVM's 4-level residency + AWS Memory Pointer Pattern + Pichay demand paging.

#### Eviction Rules (add to agent-rules.md)

```
Context Diet Protocol:

1. TOOL OUTPUT TRIAGE (before including in response):
   - ≤20 lines: include verbatim
   - 21-100 lines: include first 5 + last 5 + "... (N lines omitted, in shell #X)"
   - >100 lines: summarize to ≤10 lines + pointer reference
   
2. FILE READ TRIAGE:
   - Need specific function/section? Use offset+limit (surgical read)
   - Need overview? Read first 30 lines only
   - Already read this file this session? Don't re-read. Reference prior read.

3. CONVERSATION HISTORY (behavioral — agent can't directly evict):
   - After 10+ turns: suggest user run /summarize
   - After 20+ turns: strongly recommend /summarize or /clear
   - Mark "context pressure" when responding with degraded quality

4. BINARY CONTENT:
   - NEVER include base64/binary in context
   - Reference by path: "Image at /path/to/file.png (X×Y, PNG)"
   - For PDFs: extract text summary, reference original
```

#### Pointer Storage

When a tool output is pointer-compressed:

```
[Pointer] Shell output #3: git log --oneline -50
  Summary: 50 commits, latest "fix: auth middleware", oldest "init: project setup"
  Full output: terminal file 3.txt, lines 15-65
  Size: 4.2 KB → 0.2 KB (21x compression)
```

Agent can re-fetch specific sections if needed:
```
Read terminal 3.txt, offset=30, limit=5  → get commits 30-35
```

#### Multi-Platform Pointer Support

| Platform | Where tool outputs live | How to reference |
|----------|------------------------|------------------|
| Cursor IDE/CLI | Terminal files (`~/.cursor/.../terminals/N.txt`) | `Read terminal N.txt, offset, limit` |
| Claude Code | Bash tool stdout (in conversation) | "See bash output from turn #N" |
| CodeBuddy | TBD | TBD |
| Generic | Write to temp file via script | `cat /tmp/save-token-output-N.txt` |

#### A/B Test Plan

```
scripts/pointer-bench.sh --threshold=20   --trials=20  # aggressive eviction
scripts/pointer-bench.sh --threshold=100  --trials=20  # moderate eviction
scripts/pointer-bench.sh --threshold=none --trials=20  # no eviction (baseline)
```

**Metrics:**
- `context_size` — average context tokens per turn
- `re-fetch_rate` — how often agent needs to re-read evicted content
- `task_correctness` — does eviction cause errors?
- `session_length` — can sessions run longer before needing /summarize?

---

## Medium Priority

### 6. Real Token Tracking

**Problem:** We measure proxy metrics (tool_calls, code_lines, explanation_lines) but not actual token counts. Users want dollar figures.

**Current state:** `cost.sh` estimates savings from A/B data + model pricing. But estimates ≠ actuals.

#### Data Sources per Platform

| Platform | Token data access | How to extract |
|----------|------------------|----------------|
| Cursor IDE | Settings → Usage page (no API) | Scrape or manual entry |
| Cursor CLI | `~/.cursor/usage.json` (if exists) | Parse JSON |
| Claude Code | `--output-format json` flag | Parse `input_tokens`, `output_tokens` from response |
| OpenAI API | Response headers / usage object | `response.usage.prompt_tokens` + `completion_tokens` |
| LiteLLM | Per-request logging | Query LiteLLM dashboard/API |
| Helicone | Proxy intercepts all calls | Helicone API |

#### Implementation

```bash
scripts/tokens.sh [--source=auto|cursor|claude|litellm|helicone]

Output:
  Source: Claude Code (--output-format json)
  Last session:
    Input tokens:  45,230 (system: 12,100 | user: 33,130)
    Output tokens: 18,440
    Total cost:    $1.23 (Claude Opus @ $15/$75 per 1M)
    
  With save-token (estimated):
    Input tokens:  45,230 (unchanged — rules don't compress input directly)
    Output tokens: ~9,220 (-50%, based on 200-trial A/B data)
    Estimated cost: $0.78 (-37%)
```

#### Integration with cost.sh

`cost.sh` evolves from pure estimation to hybrid:
- If real token data available → use actuals + save-token delta
- If no data → fall back to current estimation model

---

### 7. Team Config Mode

**Problem:** Individual settings aren't shareable. Teams want consistent save-token behavior across all members.

#### Config File

```json
// .save-token.json (committed to repo root)
{
  "version": "0.3.0",
  "mode": "full",
  "enforce_review_score": "B",
  "compression": {
    "code": "claw",
    "text": "llmlingua",
    "tool_output": "pointer",
    "threshold_lines": 50
  },
  "effort_routing": {
    "enabled": true,
    "mechanical_model": "fast"
  },
  "auto_intensity": false,
  "platforms": ["cursor", "claude-code"]
}
```

#### Precedence

```
User override (~/.save-token/config.json)
  ↓ overrides
Team config (.save-token.json in repo root)
  ↓ overrides
Defaults (built into save-token)
```

#### Multi-Platform Config Loading

| Platform | How config is discovered |
|----------|------------------------|
| Cursor IDE/CLI | SKILL.md reads `.save-token.json` from workspace root |
| Claude Code | AGENTS.md references config; `setup.sh` symlinks |
| CodeBuddy | Adapter reads config on session start |
| Generic | `source <(scripts/load-config.sh)` in shell |

---

### 8. Progressive Activation

**Problem:** New users don't know which mode to start with. Ultra scares beginners; lite doesn't show value.

#### Progression Path

```
Session 1-3:   lite (advisory, gentle)
  ↓ review.sh score ≥ B for 3 sessions
Session 4-10:  full (enforced, but with explanations)
  ↓ review.sh score ≥ B for 5 more sessions
Session 11+:   ultra (for appropriate tasks)
```

#### Implementation

```bash
scripts/progress.sh

Output:
  Current level: full
  Sessions at this level: 7/10
  Average review score: B+ (3.3/4.0)
  
  Status: 3 more sessions at score ≥ B to unlock ULTRA suggestion
  
  Override: save-token ultra (skip progression)
```

#### Storage

```
~/.save-token/progression.json
{
  "current_level": "full",
  "sessions_at_level": 7,
  "review_scores": ["B+", "A-", "B", "B+", "A", "B+", "B"],
  "history": [
    {"level": "lite", "sessions": 3, "promoted": "2026-06-25"},
    {"level": "full", "sessions": 7, "promoted": null}
  ]
}
```

---

### 9. CI Benchmark Regression

**Problem:** Rule changes might degrade save-token effectiveness. No automated guard.

#### GitHub Action

```yaml
# .github/workflows/benchmark.yml
name: Benchmark Regression
on:
  pull_request:
    paths: ['rules/**', 'adapters/**', 'SKILL.md']

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run benchmark suite
        run: bash scripts/benchmark.sh --all --trials=5 --output=json
      - name: Compare with baseline
        run: |
          bash scripts/compare.sh \
            benchmarks/results/baseline.json \
            benchmarks/results/current.json \
            --fail-if-regression=10%
      - name: Post results to PR
        if: always()
        run: |
          bash scripts/compare.sh --format=markdown \
            >> $GITHUB_STEP_SUMMARY
```

#### Regression Thresholds

| Metric | Allowed regression | Action if exceeded |
|--------|-------------------|-------------------|
| tool_calls | +15% | Warn |
| code_lines | +20% | Warn |
| explanation_lines | +25% | Warn |
| waste_score | -1 grade (e.g. B→C) | Block merge |

#### Baseline Management

```bash
# After a verified release:
scripts/benchmark.sh --all --trials=20 --output=json > benchmarks/results/baseline.json
git add benchmarks/results/baseline.json && git commit -m "Update benchmark baseline"
```

---

## Low Priority

### 10. promptfoo Integration

**Problem:** Power users already have promptfoo for prompt evaluation. Our benchmark data isn't compatible.

#### Export Format

```bash
scripts/export-promptfoo.sh

# Generates promptfooconfig.yaml:
prompts:
  - id: save-token-full
    raw: "{{rules/agent-rules.md}}\n---\n{{task}}"
  - id: baseline
    raw: "{{task}}"

providers:
  - id: openai:gpt-4o
  - id: anthropic:claude-sonnet

tests:
  - vars:
      task: "Write a Python CSV parser..."
    assert:
      - type: python
        value: "len(output.split('\\n')) < 30"  # code conciseness
      - type: llm-rubric
        value: "Response follows YAGNI principle"
```

#### Value

- Leverage promptfoo's eval infrastructure instead of building our own
- Side-by-side comparison across models
- Shareable eval configs for teams

---

### 11. Multi-model A/B Testing

**Problem:** Our 200-trial data is from whatever model Cursor's Task tool used. We don't know if save-token rules work equally well on Opus vs Sonnet vs GPT vs Codex.

#### Test Matrix

| Model | Baseline trials | save-token trials | Status |
|-------|----------------|------------------|--------|
| Claude Opus | 20 | 20 (lite/full/ultra) | TODO |
| Claude Sonnet | 20 | 20 | TODO |
| GPT-4o | 20 | 20 | TODO |
| Codex | 20 | 20 | TODO |
| Claude Haiku | 20 | 20 | TODO (cheapest — does it still follow rules?) |

#### Key Questions

1. Do cheaper models follow save-token rules as reliably as expensive ones?
2. Does rule compliance vary by model family (Claude vs GPT vs Codex)?
3. Is there a model where save-token hurts performance?
4. What's the optimal mode per model? (Maybe Haiku needs "lite" because it's already terse)

#### Implementation

Requires Cursor Task tool `model` parameter or direct API access:

```bash
scripts/benchmark.sh --model=claude-4.6-sonnet --task=csv-parser --mode=full --trials=10
scripts/benchmark.sh --model=gpt-5.3-codex     --task=csv-parser --mode=full --trials=10
```

---

## Design Principles

1. **Never break prompt cache** — keep system prompt stable
2. **Multi-platform first** — rules are platform-agnostic, adapters handle specifics
3. **Modular compression** — each engine is optional, stackable
4. **Reuse > reinvent** — integrate Claw/LLMLingua/Headroom, don't rewrite
5. **Subagent over model-switch** — delegate cheap work, keep main agent warm
6. **Measure everything** — no feature without A/B validation
7. **User says one thing, agent handles the rest** — zero installation ceremony

---

## Inspiration Map: Feature ← Research Source

| Our Feature | Primary Inspiration | Secondary | Category (from 56-tech research) |
|------------|--------------------|-----------|----|
| Code Ladder (YAGNI → reuse → stdlib) | Ponytail decision ladder | — | Agent Loop Prevention (#31-35) |
| Tool Discipline (batch, surgical read) | AWS "Stop Agents Wasting Tokens" | Token-Efficient Tool Use (#14) | MCP Optimization (#11-15) |
| Zero Prose Default | CRISP (#22), SGP-CoT (#21) | Headroom output shaper | Reasoning Optimization (#21-25) |
| Memory Pointer summarization (P5) | Memory Pointer Pattern (#15) | ClawVM 4-level residency (#16) | Context Virtualization (#16-20) |
| Modular Compression (P1) | Claw Compactor (#1) | LLMLingua-2 (#2), Headroom CCR | Prompt Compression (#1-6) |
| Effort Routing (P2) | FrugalGPT cascading (#27) | RouteLLM pre-gen classifier (#26) | Model Routing (#26-30) |
| Prompt Cache stability rule | Anthropic Prompt Caching (#7) | OpenAI Auto Caching (#8) | Provider Caching (#7-10) |
| `.cursorignore` template | TokenWise guide (#46) | — | Cursor Workflow (#41-49) |
| `learn.sh` (session mining) | Headroom `headroom learn` | Mem0 cross-session (#18) | Observability (#50-53) |
| Debounce Hook (planned) | AWS Debounce Hook (#31) | Circuit Breaker (#34) | Agent Loop Prevention (#31-35) |
| `pre-prompt.sh` (CLI pipe) | Generic system prompt injection | LiteLLM gateway (#28) | API Optimization (#54-56) |
| CodeBuddy adapter | CodeBuddy `.codebuddy/rules/` format | CODEBUDDY.md fallback | Cursor Workflow (#41-49) |
| `ai-context.md` rule (planned) | TokenWise `docs/ai-context.md` (#53) | — | Observability (#50-53) |
| progressive `/summarize` rule | Claude Code `/compact` (#41) | Pichay Demand Paging (#17) | Context Virtualization (#16-20) |

**Coverage:** 14 features mapped to 30+ of the 56 researched techniques (54% direct reuse).
Remaining techniques are either provider-internal (no user action possible), require API access we don't have, or are research-only (no production tool yet).

