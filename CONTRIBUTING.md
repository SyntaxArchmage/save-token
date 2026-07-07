# Contributing to save-token

## Quick Setup

```bash
git clone <repo-url>
cd save-token
bash install.sh
bash scripts/test.sh  # should pass 172 checks
```

## Development Workflow

1. Make changes
2. Run `bash scripts/test.sh` — all checks must pass
3. Commit with a descriptive message (what changed, why)
4. If adding a new script, add a syntax check to `test.sh`

## A/B Testing

To add new benchmark results:

1. Create a prompt file in `benchmarks/prompts/`
2. Run trials using `/save-token bench` or manual subagent launches
3. Record results in `benchmarks/results/full-report.md`
4. Update trial counts in README.md, SKILL.md, and CHEATSHEET.md

## Adding Adapters

1. Create the adapter file in `adapters/`
2. Include the "Validated: 1216 A/B trials" line in the header
3. Add a row to the adapters table in README.md
4. Add existence + content validation checks in `test.sh`

## Code Style

- Shell: `set -euo pipefail`, use `$(...)` not backticks
- Python: stdlib only, no dependencies
- Keep agent-rules.md under 200 words per section
- Keep save-token.mdc under 200 total words

## Release Checklist (cutting a version)

Run this sequence when cutting a new release:

1. Bump `VERSION=` in `install.sh`
2. Update version badge in `README.md` and version in `benchmarks/results/HEADLINE.json`
3. Add a dated section to `CHANGELOG.md` (what changed, why)
4. Refresh headline numbers in `benchmarks/results/HEADLINE.json` if any A/B data changed
5. Run `bash scripts/test.sh` — all checks (including stat-consistency) must pass
6. Run `bash scripts/stats.sh health` — confirm version/tests/engines look right
7. Run `bash install.sh verify` — confirm a clean install health report
8. Commit with `release: vX.Y.Z` and tag

The stat-consistency checks in `test.sh` will fail if any doc cites a number absent from
`HEADLINE.json` — fix drift before tagging.

## What Not to Do

- Don't add dependencies (all scripts are stdlib-only)
- Don't add features not explicitly tested by `test.sh`
- Don't modify the code ladder order (it's A/B validated)
- Don't cite a stat in docs without adding it to `benchmarks/results/HEADLINE.json`
