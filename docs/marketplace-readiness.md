# Cursor Plugin Marketplace — Readiness Checklist

> **Status: GAP LIST ONLY.** This document maps save-token's current files to Cursor
> public-plugin requirements. It does **not** perform the submission — that remains a
> maintainer decision (v2.0 B3 scope).

## Requirement Matrix

| Requirement | Status | Current file | Gap / action |
|-------------|:------:|--------------|--------------|
| `.cursor-plugin/plugin.json` with valid `name` | ❌ MISSING | — | Create manifest (see template below) |
| `README.md` with usage section | ✅ | `README.md` | None |
| `LICENSE` | ✅ | `LICENSE` (MIT) | None |
| `CHANGELOG.md` | ✅ | `CHANGELOG.md` | None |
| Skill with frontmatter (`name`, `description`) | ✅ | `SKILL.md` | None |
| Rule with frontmatter (`description`, `alwaysApply`) | ✅ | `rules/save-token.mdc` | None |
| Relative paths only (no absolute/`..`) | ✅ | all | None |
| Declared component paths match real files | ⚠️ VERIFY | — | Confirm after manifest added |
| Focused single use case | ✅ | — | Token-saving; well-scoped |
| No references to nonexistent files | ⚠️ VERIFY | README file tree | Re-check after claw removal (done in A3) |

## The One Blocking Gap: `plugin.json`

save-token is currently a **skill**, not a packaged **plugin**. To submit to the
marketplace it needs a manifest. Minimal template:

```json
{
  "name": "save-token",
  "version": "0.7.0",
  "description": "Modular token-saving framework for AI coding agents (1216-trial A/B validated).",
  "author": "SyntaxArchmage",
  "license": "MIT",
  "keywords": ["tokens", "cost", "efficiency", "compression", "agent-rules"]
}
```

Component discovery is default-based, so once `plugin.json` exists Cursor will find:
- `rules/*.mdc` (save-token.mdc)
- `skills/` (if the SKILL.md is relocated under `skills/save-token/`)
- `hooks/` (session-start hook)

## Structural Note (decide before submitting)

The repo currently ships `SKILL.md` at root (skill-style layout). A marketplace plugin
expects skills under `skills/<name>/SKILL.md`. Two options:

1. **Keep dual-purpose** (recommended): leave root `SKILL.md` for direct skill use, add a
   thin `skills/save-token/SKILL.md` that points to it, plus `plugin.json`. Serves both
   install paths.
2. **Convert to plugin-only**: move `SKILL.md` under `skills/save-token/`. Cleaner for
   marketplace but breaks the current direct-skill install path.

This is a maintainer call — not resolved here by design.

## Pre-Submission Verification Steps

Run these before any submission (all read-only):

```bash
bash install.sh verify          # install health
bash scripts/test.sh            # 166/166 must pass
bash scripts/stats.sh health    # project health snapshot
python3 -c "import json; json.load(open('.cursor-plugin/plugin.json'))"  # after manifest added
```

## Summary

- **9/11 requirements already met.**
- **1 hard gap:** `plugin.json` manifest.
- **2 items to verify** after the manifest exists.
- Submission itself is intentionally left to the maintainer.
