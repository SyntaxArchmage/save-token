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

    score = 100
    score -= len(read_findings) * 5
    score -= len(batch_findings) * 3
    score -= len(verbose_responses) * 2
    score -= len(full_read_findings) * 2
    score = max(0, score)
    issues = len(read_findings) + len(batch_findings) + len(verbose_responses) + len(full_read_findings)
    if issues == 0:
        grade = "A+"
    elif score >= 90:
        grade = "A"
    elif score >= 75:
        grade = "B"
    elif score >= 60:
        grade = "C"
    elif score >= 40:
        grade = "D"
    else:
        grade = "F"

    return {
        "repeated_reads": read_findings,
        "full_reads": full_read_findings[:5],
        "sequential_calls": batch_findings,
        "verbose_responses": verbose_responses[:5],
        "tool_summary": tool_summary,
        "token_estimate": cost_summary,
        "score": [f"Score: {score}/100 (grade {grade}, {issues} issue(s))"],
    }


def to_html(results: dict, filepath: str) -> str:
    lines = [
        "<!DOCTYPE html>",
        "<html><head><meta charset='utf-8'>",
        "<title>save-token transcript report</title>",
        "<style>",
        "body{font-family:system-ui,sans-serif;max-width:700px;margin:2em auto;background:#1a1a2e;color:#e0e0e0}",
        "h1{color:#00d2ff}h2{color:#7b68ee;border-bottom:1px solid #333;padding-bottom:4px}",
        ".warn{color:#ff6b6b}.ok{color:#51cf66}.info{color:#74c0fc}",
        "ul{list-style:none;padding:0}li{padding:2px 0}",
        ".badge{display:inline-block;padding:2px 8px;border-radius:4px;font-size:.85em}",
        ".badge-warn{background:#ff6b6b33;color:#ff6b6b}",
        ".badge-ok{background:#51cf6633;color:#51cf66}",
        "</style></head><body>",
        f"<h1>save-token report</h1>",
        f"<p class='info'>Source: <code>{filepath}</code></p>",
    ]

    section_labels = {
        "repeated_reads": ("Repeated Reads", "warn"),
        "full_reads": ("Full File Reads", "warn"),
        "sequential_calls": ("Unbatched Sequential Calls", "warn"),
        "verbose_responses": ("Verbose Responses", "warn"),
        "tool_summary": ("Tool Usage", "info"),
        "token_estimate": ("Token Estimates", "info"),
        "score": ("Waste Score", "ok"),
    }

    has_issues = False
    for key, findings in results.items():
        if not findings:
            continue
        label, cls = section_labels.get(key, (key, "info"))
        lines.append(f"<h2>{label}</h2><ul>")
        for item in findings:
            lines.append(f"<li class='{cls}'>{item}</li>")
            if cls == "warn":
                has_issues = True
        lines.append("</ul>")

    if not has_issues:
        lines.append("<p class='ok'><span class='badge badge-ok'>CLEAN</span> No waste patterns detected.</p>")
    else:
        lines.append("<p class='warn'><span class='badge badge-warn'>ISSUES</span> Review the patterns above.</p>")

    lines.append("</body></html>")
    return "\n".join(lines)


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Analyze Cursor transcripts for token waste")
    parser.add_argument("file", help="Path to .jsonl transcript")
    parser.add_argument("--html", action="store_true", help="Output HTML report")
    parser.add_argument("-o", "--output", help="Write to file instead of stdout")
    args = parser.parse_args()

    results = analyze(args.file)

    if args.html:
        output = to_html(results, args.file)
    else:
        parts = []
        for category, findings in results.items():
            for line in findings:
                parts.append(line)
        output = "\n".join(parts)

    if args.output:
        with open(args.output, "w") as f:
            f.write(output)
        print(f"Report written to {args.output}", file=sys.stderr)
    else:
        print(output)


if __name__ == "__main__":
    main()
