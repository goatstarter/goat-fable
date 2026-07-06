# Hooks: Deterministic Gates

Everything else in this pack is advisory: instructions the model reads and (almost always) follows. Hooks are the enforcement layer: shell scripts the harness runs at fixed points, whether or not the model felt like it. Anthropic's own guidance: when a rule keeps getting ignored, don't write it louder, convert it to a hook.

## stop-verify (the one hook this pack ships)

`stop-verify.sh` targets the single most expensive failure this pack exists for: **ending the turn with modified code and zero verification.** On the Stop event it checks whether the working tree changed and whether any test/build-looking command ran this session. If changes exist and nothing ran, it blocks the stop once and feeds the model a reminder: verify, or explicitly report the work as unverified.

Design choices, deliberately conservative:

- **Fires at most once per session.** A hook that nags in a loop trains the model (and you) to route around it. One deterministic reminder at the moment of stopping is the high-value intervention.
- **It cannot force verification, only make skipping it explicit.** The model can proceed after stating the work is unverified: that is the honest outcome the pack wants when verification is genuinely impossible. (Claude Code also force-overrides Stop hooks after 8 consecutive blocks, so hard-looping is not even an option.)
- **The command pattern is a heuristic.** Extend `VERIFY_PATTERN` in the script with your stack's real commands (your task runner, your e2e suite). A pattern that never matches turns the hook into pure noise.

## Install

1. Copy the pack into your project as `.claude/goat-fable/` (see the root `INSTALL.md`).
2. Make the script executable: `chmod +x .claude/goat-fable/hooks/stop-verify.sh`
3. Merge `settings.example.json` into your project's `.claude/settings.json` (or `settings.local.json` to keep it personal). If you already have settings, merge the `hooks` key rather than replacing the file.
4. Verify wiring: make a trivial file change in a session, try to end it without running tests; the reminder should appear once.

`settings.example.json` also carries the recommended model configuration (`claude-opus-4-8`, thinking on, effort `xhigh`). If your Claude Code version doesn't recognize a key, set the equivalent interactively (`/model`, `/effort`) and delete the key.

## When to add more hooks

Add a hook when the same instruction has been ignored more than twice AND a script can check compliance mechanically: a formatter after Write/Edit (PostToolUse), a lint gate, a protected-paths check (PreToolUse). Resist encoding judgment calls in hooks: judgment belongs in the prompt layer, enforcement belongs here, and a hook that's wrong 10% of the time gets disabled by its owner within a week.
