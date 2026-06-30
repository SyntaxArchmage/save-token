#!/usr/bin/env python3
"""Analyze a single Cursor agent transcript for token waste patterns."""
import json
import sys
import collections


def analyze(filepath: str) -> dict:
    reads = collections.Counter()
    tool_sequence = []
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
                if name in ("Read", "read_file", "file_read"):
                    path = obj.get("parameters", {}).get("path", "")
                    if path:
                        reads[path] += 1
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

    return {
        "repeated_reads": read_findings,
        "sequential_calls": batch_findings,
        "verbose_responses": verbose_responses[:5],
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
