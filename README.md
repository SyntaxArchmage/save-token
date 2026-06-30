# save-token

A Cursor skill that combines battle-tested techniques to minimize token consumption when working with expensive AI models (Opus, o3, etc.) — without sacrificing output quality.

## Why

Expensive models burn through tokens fast. Most waste comes from a handful of recurring patterns: bloated context, redundant reads, over-eager exploration, verbose prompts, and uncontrolled agent loops. This skill encodes the fixes as enforceable rules so every session starts lean.

---

## Technique & Tool Reference

### 1. Prompt & Context Compression

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 1 | **Claw Compactor** | 14-stage Fusion Pipeline: AST-aware code compression, JSON sampling, simhash dedup. Reversible via hash-addressed Rewind store. Zero LLM inference cost. | 15–82% | [github.com/open-compress/claw-compactor](https://github.com/open-compress/claw-compactor) (2.2k stars, MIT) |
| 2 | **LLMLingua-2** (Microsoft) | Perplexity-based prompt pruning via distilled BERT-level encoder. Task-agnostic, 3-6x faster than v1. | 30–70% (up to 20x ratio) | [llmlingua.com](https://www.llmlingua.com/) |
| 3 | **token-compressor** (base76) | Two-stage pipeline: local LLM compression (llama3.2:1b) + embedding cosine similarity validation (threshold 0.85). MCP server included. | 40–60% | [github.com/base76-research-lab/token-compressor](https://github.com/base76-research-lab/token-compressor) |
| 4 | **Semantic Prompt Compressor** | Rule-based compression using spaCy: NER preservation, dependency parsing, POS tagging. Lightweight, no GPU. | ~22% avg | [DEV Community](https://dev.to/metawake/how-i-built-a-prompt-compressor-that-reduces-llm-token-costs-without-losing-meaning-5gmg) |
| 5 | **Terse system instructions** | Strip filler words, use shorthand, bullet points over prose. "Summarize:" vs "Could you please provide a summary of:" | 20–40% on input | General practice |
| 6 | **No echo-back** | Never repeat the user's question or restate what was just read. | Variable | General practice |

### 2. Provider-Level Caching

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 7 | **Anthropic Prompt Caching** | `cache_control` parameter caches KV matrices of stable prompt prefixes. Supports up to 4 breakpoints per request. 5-min default TTL, 1-hour option at 2x write cost. | Up to 90% on cached input | [Anthropic docs](https://docs.anthropic.com/) |
| 8 | **OpenAI Automatic Caching** | Automatic server-side caching for prompts >1024 tokens. No code changes needed. | 50% discount on cached input | [OpenAI docs](https://platform.openai.com/docs) |
| 9 | **Semantic Caching (Redis)** | Vector search matches semantically similar queries to cached responses. "Read auth.js" and "Get content of auth.js" → same cache hit. | 30–91% for redundant calls | [Redis blog](https://redis.io/blog/llm-token-optimization-speed-up-apps/) |
| 10 | **Response / Retrieval Caching** | Cache RAG document chunks and search results before generation call. | Eliminates redundant calls | General pattern |

### 3. MCP & Tool Optimization

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 11 | **Code Mode** (Cloudflare/Bifrost/FastMCP) | Replace entire tool catalog with `search()` + `execute()` meta-tools. Agent writes code against typed SDK in sandbox, only final result enters context. | 58–99.9% (scales with tool count) | [Cloudflare](https://developers.cloudflare.com/), [FastMCP](https://github.com/PrefectHQ/fastmcp) |
| 12 | **Tool Search Tool** (Anthropic) | `defer_loading: true` — Claude discovers tools on-demand via search instead of loading all definitions upfront. Auto-enabled when tool descriptions exceed threshold. | ~85% | [Anthropic docs](https://docs.anthropic.com/) |
| 13 | **mcp-compressor** | Proxy existing MCP servers to introduce on-demand tool discovery without refactoring. | Variable | Community tool |
| 14 | **Token-Efficient Tool Use** | Compress tool call return values: truncate large outputs, paginate data, use demand-driven discovery. | 14–70% | [Obvious Works](https://www.obviousworks.ch/) |
| 15 | **Memory Pointer Pattern** | Large tool outputs stored externally; context retains only a pointer/handle. Agent re-fetches on demand. 214KB → ~30KB in demo. | ~7x reduction | [AWS samples](https://github.com/aws-samples/sample-why-agents-fail) |

### 4. Context Window Virtualization & Memory Hierarchy

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 16 | **ClawVM** | Harness-managed virtual memory for agents. Typed pages with 4-level residency (full/compressed/structured/pointer). Invariant-preserving degradation, validated writeback. | Controlled degradation vs lossy summarization | [arxiv 2604.10352](https://arxiv.org/abs/2604.10352) |
| 17 | **Pichay / Demand Paging** | 4-layer memory hierarchy (L1 generation window → L2 working set → L3 compressed history → L4 cross-session persistent). Transparent proxy with page fault detection. | Unbounded addressable memory | [arxiv 2603.09023](https://arxiv.org/abs/2603.09023) |
| 18 | **Mem0** | External persistent memory layer. "Context window is RAM, not storage." Working memory actively managed, cold state evicted to external store. | Prevents attention dilution | [mem0.ai](https://mem0.ai/) |
| 19 | **State externalization** | Replace raw conversation history with structured state objects. Workflow state stored outside the prompt. | Significant on long sessions | [Medium article](https://medium.com/@ravityuval/) |
| 20 | **Hierarchical context compression** | Multi-level compression: rolling summaries for conversation, relevance filtering for history, structured memory objects for preferences. | 31% avg | Production reports |

### 5. Reasoning / CoT Optimization

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 21 | **SGP-CoT** | Self-Guided Pruning: uses model's intrinsic likelihood signals to identify and remove non-essential reasoning segments. Forms preference pairs for self-optimization. | Significant length reduction, accuracy maintained | [ACL 2026](https://aclanthology.org/2026.acl-long.25/) |
| 22 | **CRISP** | Attention-based saliency pruning: reasoning termination token as information anchor, attention patterns demarcate essential vs redundant reasoning. | 50–60% token reduction | [ACL Findings 2026](https://aclanthology.org/2026.findings-acl.1961.pdf) |
| 23 | **Abstract CoT / Coconut** | Latent space reasoning: replace text-based CoT with continuous hidden state representations. Model reasons in embedding space, translates back only for final answer. | Up to 12x sequence shortening | [arxiv 2604.22709](https://arxiv.org/abs/2604.22709), [Meta](https://arxiv.org/abs/2412.06769) |
| 24 | **Dynamic thinking budget** | RL-learned adaptive CoT triggering: model learns when to stop thinking, allocating token budget dynamically based on problem difficulty. | Variable (30–60% typical) | Multiple papers, 2025-2026 |
| 25 | **CoT pruning in API calls** | Use `reasoning_effort` / `thinking_budget` parameters (where available) to control reasoning token allocation. | Direct control | Provider-specific |

### 6. Model Routing & Cascading

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 26 | **Model Router** | Pre-generation classification: send each request to cheapest capable model. Rule-based → embedding → trained classifier tiers. | 40–85% cost reduction | [Survey](https://www.arxiv.org/pdf/2603.04445), [GenAI Patterns](https://www.genaipatterns.dev/) |
| 27 | **Model Cascading** | Post-generation sequential: try cheapest model first, evaluate response quality, escalate only if below threshold. | Up to 98% (FrugalGPT) | [FrugalGPT](https://arxiv.org/abs/2305.05176), [GenAI Patterns](https://www.genaipatterns.dev/patterns/routing/cascading) |
| 28 | **LiteLLM** | Gateway to route, track spend by API key, enforce model routing policies. | Cost visibility + routing | [litellm.ai](https://litellm.ai/) |
| 29 | **Cursor Auto Mode** | Cursor's built-in model routing. Unlimited on paid plans, doesn't draw from credit pool. | 30–70% credit savings | [Cursor docs](https://cursor.com/docs) |
| 30 | **Tab Completion** | No credit consumption on paid plans. Shift 30% of Chat requests to Tab → 10-15% monthly reduction. | 10–15% | [Cursor docs](https://cursor.com/docs) |

### 7. Agent Loop Prevention

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 31 | **Debounce Hook** | Sliding window (3 calls) detects duplicate tool calls (same tool + same args). Blocks 3rd repetition, returns error to LLM. | 7x call reduction (14→2 in demo) | [AWS](https://github.com/aws-samples/sample-why-agents-fail), [DEV Community](https://dev.to/aws/) |
| 32 | **Max Iterations / Hard Limits** | Cap tool calls per invocation (3–15 steps). Non-negotiable safety ceiling. | Prevents runaway execution | Industry standard (LangChain, CrewAI, n8n) |
| 33 | **Clear Terminal States** | Design tools to return explicit `SUCCESS: ...` or `FAILED: ...`. Eliminates ambiguous feedback like "more results may be available". | 7x improvement in demo | [AWS demo](https://dev.to/aws/) |
| 34 | **Circuit Breaker** | Middleware monitors failure rates and duplicate signatures. Auto-breaks on threshold, surfaces error for model to pivot. | Prevents cascading failures | Framework-native (LangGraph, AgentGuard) |
| 35 | **Budget Guards** | Per-session, per-feature, per-user spend caps with kill switches. Blocks expensive model usage on basic tasks. | Configurable ceiling | Helicone, LiteLLM |

### 8. Structured Output & Output Economy

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 36 | **JSON Schema + Strict Mode** | Constrained decoding: FSM masks invalid tokens at each generation step. 100% schema compliance, zero retry cost. | Eliminates retry tokens | OpenAI, Anthropic, Gemini native |
| 37 | **`max_completion_tokens`** | Hard ceiling on output length. Set to 1.5-2x expected output. Pair with prompt instruction ("Answer in 50 words"). | 30–50% on output tokens | All providers |
| 38 | **Short key names + minimal fields** | JSON structural overhead (`{`, `}`, `"`, `:`, `,`) adds 15-30% token overhead. Minimize field count, use terse keys. | 15–30% on JSON output | Production practice |
| 39 | **Code references over code blocks** | Cite `startLine:endLine:filepath` for existing code instead of copying into response. | Major savings on code-heavy sessions | Cursor-specific |
| 40 | **Diff-sized edits** | Use `StrReplace` with tight context instead of rewriting entire files. Show only what changed. | Variable | Cursor-specific |

### 9. Cursor & Claude Code Workflow

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 41 | **`/summarize` / `/compact`** | Manual context compression. Use at 50-70% capacity. `/compact focus on API changes` steers preservation. | Prevents context rot | [Cursor docs](https://cursor.com/docs), [Claude Code docs](https://code.claude.com/docs) |
| 42 | **CLAUDE.md Compact Instructions** | Persistent compaction rules in project root. Every auto-compaction follows these preservation priorities. | Prevents critical context loss | [Claude Code docs](https://code.claude.com/docs/en/best-practices) |
| 43 | **`/context` monitoring** | Real-time per-category token usage breakdown. Act at >60%, compact at >80%, emergency at >90%. | Awareness → prevention | [Claude Code docs](https://code.claude.com/docs) |
| 44 | **`/clear` + `/rewind`** | `/clear` resets between unrelated tasks. `/rewind` rolls back mistakes without polluting history. | Clean context = better performance | [Claude Code docs](https://code.claude.com/docs) |
| 45 | **`@` scoped mentions** | `@file` / `@folder` / `@symbol` instead of repo-wide context. Forces targeted inclusion. | 60–80% vs unscoped | [Cursor docs](https://cursor.com/docs) |
| 46 | **`.cursorignore`** | Hard block AI access to `node_modules/`, `dist/`, `build/`, `.env*`, `*.lock`. Reduces index by 30-50%. | 30–50% index reduction | [Cursor docs](https://cursor.com/docs) |
| 47 | **Modular `.mdc` rules** | `alwaysApply` <200 words, glob-scoped 200-500 words, agent-requested 500-800 words. Replace monolithic `.cursorrules`. | Eliminates "token tax" | [Cursor docs](https://cursor.com/docs/rules.md) |
| 48 | **Subagents for mechanical work** | Offload compiles, git ops, file search to cheap subagents. Keep expensive model focused on reasoning. | Isolates noise from main context | Cursor/Claude Code |
| 49 | **Plan Mode first** | Use Plan Mode to design strategy before executing. Reduces costly build-break-redo agent loops. | Prevents wasted iterations | [Cursor docs](https://cursor.com/docs) |

### 10. Observability & Cost Tracking

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 50 | **Helicone** | Fast proxy integration. Per-user, per-feature dollar attribution. Budget alerts, cache hit rate monitoring. | Visibility → optimization | [helicone.ai](https://helicone.ai/) |
| 51 | **LangFuse** | Self-hostable open-source agent tracing. Complex agent workflow cost analysis. | Visibility → optimization | [langfuse.com](https://langfuse.com/) |
| 52 | **LiteLLM** | Gateway to track spend by API key, model, provider. Rate limiting and budget enforcement. | Visibility + enforcement | [litellm.ai](https://litellm.ai/) |
| 53 | **`docs/ai-context.md`** | Pre-computed repo summary that Cursor reads instead of rediscovering the repo every session. Refresh after big refactors. | Eliminates repeated exploration | [tokenwisehq.com](https://tokenwisehq.com/guides/reduce-llm-cost-in-cursor) |

### 11. API-Level Optimizations

| # | Technique / Tool | What it does | Savings | Source |
|---|---|---|---|---|
| 54 | **Conversation chaining** | OpenAI Responses API `previous_response_id`. Chain responses without resending full history. | Eliminates redundant context | [OpenAI docs](https://platform.openai.com/docs) |
| 55 | **Batch API** | OpenAI async batch processing for non-latency-sensitive workloads (classification, backfills). | 50% discount | [OpenAI docs](https://platform.openai.com/docs) |
| 56 | **Prompt-cache-friendly ordering** | Stable instructions (system prompt, rules) first; variable content (user query, file contents) last. Maximizes KV cache hit rate. | Up to 90% on cached portion | General practice |

---

## Key References

- [Token optimization 2026: Saving up to 80% LLM costs](https://www.obviousworks.ch/en/token-optimization-saves-up-to-80-percent-llm-costs/) — Obvious Works
- [How I Reduced LLM Token Costs by 90%](https://medium.com/@ravityuval/how-i-reduced-llm-token-costs-by-90-using-prompt-rag-and-ai-agent-optimization-f64bd1b56d9f) — Yuval Ben-itzhak
- [LLM Token Optimization: Cut Costs & Latency](https://redis.io/blog/llm-token-optimization-speed-up-apps/) — Redis
- [Reduce LLM Cost in Cursor: Practical Guide](https://tokenwisehq.com/guides/reduce-llm-cost-in-cursor) — TokenWise
- [MCP Context Bloat Fix 2026](https://mcp.directory/blog/mcp-context-bloat-fix-2026-tool-search-code-mode-progressive-disclosure) — MCP Directory
- [Context compaction in agent frameworks](https://crabtalk.ai/blog/context-compaction) — CrabTalk
- [Dynamic Model Routing and Cascading Survey](https://www.arxiv.org/pdf/2603.04445) — arxiv 2603.04445
- [ClawVM: Virtual Memory for LLM Agents](https://arxiv.org/abs/2604.10352) — arxiv 2604.10352
- [Demand Paging for LLM Context Windows](https://arxiv.org/abs/2603.09023) — arxiv 2603.09023
- [Stop AI Agents Wasting Tokens](https://github.com/aws-samples/sample-why-agents-fail) — AWS Samples
- [Cursor Rules Complete Guide](https://www.vibecodingacademy.ai/blog/cursor-rules-complete-guide) — Vibe Coding Academy
- [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices) — Anthropic

## Status

Under active development — SKILL.md with enforceable rules coming next.

## License

MIT
