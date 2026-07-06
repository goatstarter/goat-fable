# Opus 4.8 Calibration: Documented Quirks and Their Fixes

This guide collects what Anthropic's own documentation says about Claude Opus 4.8's default behaviors, and the officially recommended countermeasures. The rest of this pack is model-agnostic discipline; this file is the model-specific tuning. Sources at the bottom.

## Behavior quirks and countermeasures

**1. Literal instruction following.** Opus 4.8 does not silently generalize an instruction from one item to analogous ones. If you say "rename the button on the settings page" and the same button exists on three pages, it renames one. Countermeasure: state scope explicitly in prompts ("...everywhere it appears"), and in standing instructions tell the model: *when an instruction plausibly applies to analogous cases, ask or apply it consistently, and say which you did.*

**2. Reasons instead of acting.** It favors internal reasoning over tool calls more than its predecessors, which produces confident answers about files it never opened. Countermeasure: hard rule: *never speculate about code you have not opened; if a specific file is referenced, read it before answering.* Give tools explicit "use this when..." trigger conditions; measured lift is real.

**3. Under-spawns subagents.** It defaults to doing everything in its own context. Countermeasure: explicit triggers: *don't spawn a subagent for work you can complete directly, but when fanning out across independent items or broad searches, spawn them, all in the same turn.*

**4. Over-asks permission.** It checks in on minor decisions more than Fable 5. The official autonomy snippet cut ask-rate by ~12 percentage points in Claude Code testing with no over-reach increase: *for minor choices, pick a reasonable option and note it rather than asking; for scope changes or destructive actions, still ask first.*

**5. Narrates heavily.** It gives progress commentary on its own; scaffolding written for older models ("summarize after every 3 tool calls") doubles it. Countermeasure: delete forced-summary scaffolding; if still too chatty, add a silence default ("work silently except at meaningful milestones").

**6. Code review recall trap.** Severity filters are followed literally: "only report high-severity issues" measurably depresses recall because borderline findings get self-censored. Countermeasure for review tasks: *report every issue you find and let a separate verification step filter; your goal here is coverage.* Filter downstream, never in the finder.

**7. House style in design work.** Left unprompted it converges on a recognizable default (cream backgrounds, serif display fonts, terracotta accents). Countermeasure: give a concrete visual spec, or ask it to propose 3-4 distinct directions and pick one.

**8. Context anxiety.** On long tasks it may wrap up early to "stay within budget". Countermeasure: *do not stop tasks early due to token budget concerns; budget is the harness's problem.*

**9. Fabricated status reports remain elicitable** on long runs (the reason the grounded-claims rule exists): *before reporting progress, audit each claim against a tool result from this session; only report work you can point to evidence for.* This pack's core section 1 is that rule.

## Recommended configuration

### Claude Code

```json
// .claude/settings.json (project) or ~/.claude/settings.json (user)
{
  "model": "claude-opus-4-8",
  "alwaysThinkingEnabled": true,
  "effortLevel": "xhigh"
}
```

If a key is not recognized by your Claude Code version, set the equivalents interactively: `/model claude-opus-4-8` and `/effort xhigh`. Anthropic's recommendation for Opus 4.8: start with `xhigh` for coding and agentic use; `max` is for frontier-difficulty problems and is prone to overthinking on routine work.

### API

```jsonc
{
  "model": "claude-opus-4-8",
  "max_tokens": 64000,                        // ≥64K recommended at xhigh/max
  "thinking": { "type": "adaptive" },          // REQUIRED: omitting = no thinking on Opus 4.8
  "output_config": { "effort": "xhigh" }       // low | medium | high (default) | xhigh | max
}
```

- `thinking: {"type": "adaptive"}` must be set explicitly; unlike Fable 5, Opus 4.8 does no extended thinking without it. `budget_tokens` is rejected.
- `temperature`, `top_p`, `top_k` return 400 on Opus 4.7+. Steer variety with prompting ("propose 4 distinct directions"), not sampling.
- Assistant prefills return 400 since the 4.6 family; use system instructions or structured outputs.
- Opus 4.8 supports mid-conversation `role: "system"` messages: inject standing rules mid-run without breaking the prompt cache. Useful for long agent loops.
- Effort applies to ALL tokens including tool calls, and Opus 4.8 respects low settings strictly: at `low`/`medium` it deliberately scopes work down. Don't run agentic coding below `high`.

## Outdated advice to delete from your prompts

Habits from the Claude 3.x/4.0 era that now hurt on Opus 4.8:

- "CRITICAL: You MUST use this tool" in tool descriptions → causes over-triggering. Plain "use this tool when..." works. (Emphasis is still fine for *rule adherence* in system prompts; the problem is specifically tool-triggering language.)
- "Default to using X" / "If in doubt, use X" anti-laziness prompts → delete; they cause overuse.
- Forced progress-summary scaffolding → it narrates on its own (quirk 5).
- The long anti-"AI slop" frontend prompt → one short paragraph suffices now.
- `budget_tokens` thinking budgets, temperature tuning, prefills → all rejected at the API level (above).
- "Only report high-severity issues" in review prompts → inverts recall (quirk 6).

## Prompting Opus 4.8 well (for the human writing the task)

- Front-load the task: state the goal, intent, and constraints in the FIRST message. Progressive drip-feeding ("now also handle X... oh and Y") measurably reduces both efficiency and quality on this model.
- Ask for "above and beyond" explicitly when you want it ("go beyond the basics; include as many relevant features as possible"); by default it implements what you asked, no more.
- Explain the *why* behind unusual constraints; it generalizes correctly from motivation ("this output is read by a TTS engine, so never use ellipses").
- Give it a check it can run (a test, a build, a URL to hit). Without a runnable check, "looks done" is the only signal it has.

## Sources

- Prompting Claude Opus 4.8: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-4-8
- What's new in Claude Opus 4.8: https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-8
- Effort parameter: https://platform.claude.com/docs/en/build-with-claude/effort
- Prompting best practices (4.x + Fable 5): https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Prompting Claude Fable 5 (the gap map this pack targets): https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5
- Claude Code best practices: https://code.claude.com/docs/en/best-practices
- Effective harnesses for long-running agents: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
