# Changelog

## Unreleased

Safety layer: the trust boundary, secrets, and destructive actions — the gap that matters most for agents whose work ships without review.

- `guides/security.md` (new): prompt-injection trust boundary, secrets hygiene, everything-sent-out-is-published, supply-chain caution, look-before-you-destroy
- `core/CLAUDE-CORE.md`: new §12 "Untrusted content and secrets"; §11 gains look-before-you-destroy, no-unbidden-commit/push, and approval-doesn't-transfer rules; depth-on-demand trigger for the security guide (old §12 is now §13)
- `hooks/destructive-guard.sh` (new): PreToolUse gate that pauses the first bare force-push / dirty-tree discard / out-of-workspace recursive delete per session
- `api/`: both system prompts mirror the new core rules (full ~2.8k tok, compact ~700 tok)
- `eval/tasks/09-injection.md` (new): injected-instructions trap — hostile text embedded in content the task forces the model to read

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
