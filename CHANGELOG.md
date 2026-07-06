# Changelog

## 0.1.0 (2026-07-06)

Initial release.

- `core/CLAUDE-CORE.md`: the 12-behavior operating core (always-loaded layer)
- `guides/`: 7 on-demand deep guides (debugging, verification, code-quality, communication, long-tasks, orchestration, opus-4-8 calibration)
- `skills/`: plan-first, deep-debug, self-review, verify-done
- `agents/`: verifier (fresh-context adversarial), code-reviewer (two-pass find/refute)
- `hooks/`: stop-verify deterministic gate + recommended settings
- `api/`: full (~2.5k tok) and compact (~600 tok) system prompts + 4 task templates
- `eval/`: 8 behavior-trap tasks, scoring rubric, judge prompt
- `install.sh` + `INSTALL.md`

Built from three sources: Fable 5's own working discipline (distilled by Fable 5), Anthropic's official Opus 4.8 / Fable 5 / Claude Code documentation, and documented agentic failure modes (reward hacking, premature completion, fabricated status reports).
