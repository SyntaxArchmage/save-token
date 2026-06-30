#!/usr/bin/env python3
"""Analyze a single Cursor agent transcript for token waste patterns."""
import json
import sys
import collections


def analyze(filepath: str) -> dict:
    reads = collections.Counter()
    full_reads = []
    tool_sequence = []
    tool_counts = collections.Counter()
    verbose_responses = []
    total_chars = 0
    message_count = 0

    with open(filepath) as f:
        for line in f:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            obj_type = obj.get("type", "")

            if obj_type == "tool_call":
                name = obj.get("tool_name", obj.get("name", ""))
                params = obj.get("parameters", {})
                tool_counts[name] += 1
                if name in ("Read", "read_file", "file_read"):
                    path = params.get("path", "")
                    if path:
                        reads[path] += 1
                    if path and not params.get("offset") and not params.get("limit"):
                        full_reads.append(path)
                tool_sequence.append(name)

            elif obj_type in ("assistant", "assistant_message"):
                content = obj.get("content", obj.get("text", ""))
                if isinstance(content, str):
                    total_chars += len(content)
                    message_count += 1
                    if len(content) > 2000:
                        preview = content[:80].replace("\n", " ")
                        verbose_responses.append(
                            f"- verbose response ({len(content)} chars): {preview}..."
                        )

            elif obj_type in ("user", "human", "user_message"):
                content = obj.get("content", obj.get("text", ""))
                if isinstance(content, str):
                    total_chars += len(content)
                    message_count += 1

    # Repeated reads
    repeated = {k: v for k, v in reads.items() if v > 2}
    read_findings = [
        f"- re-read {count}x: {path}"
        for path, count in sorted(repeated.items(), key=lambda x: -x[1])
    ]

    # Sequential tool calls that could be batched
    batch_findings = []
    i = 0
    while i < len(tool_sequence) - 1:
        run_start = i
        name = tool_sequence[i]
        while i < len(tool_sequence) - 1 and tool_sequence[i + 1] == name:
            i += 1
        run_len = i - run_start + 1
        if run_len >= 3:
            batch_findings.append(
                f"- {run_len} sequential {name} calls (could batch)"
            )
        i += 1

    # Estimated token usage (~4 chars per token for English)
    est_tokens = total_chars * 4 // 3 if total_chars else 0
    cost_summary = []
    if est_tokens > 0:
        cost_summary.append(
            f"- estimated tokens: ~{est_tokens:,} ({message_count} messages, {total_chars:,} chars)"
        )

    full_read_findings = []
    full_read_counter = collections.Counter(full_reads)
    for path, count in full_read_counter.most_common(5):
        if count >= 1:
            full_read_findings.append(f"- full file read (no offset/limit): {path} ({count}x)")

    tool_summary = []
    total_calls = sum(tool_counts.values())
    if total_calls > 0:
        top3 = tool_counts.most_common(3)
        parts = [f"{n}={c}" for n, c in top3]
        tool_summary.append(f"- {total_calls} tool calls total (top: {', '.join(parts)})")

    return {
        "repeated_reads": read_findings,
        "full_reads": full_read_findings[:5],
        "sequential_calls": batch_findings,
        "verbose_responses": verbose_responses[:5],
        "tool_summary": tool_summary,
        "token_estimate": cost_summary,
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: analyze_transcript.py <file.jsonl>", file=sys.stderr)
        sys.exit(1)

    results = analyze(sys.argv[1])
    for category, findings in results.items():
        for line in findings:
            print(line)


if __name__ == "__main__":
    main()
