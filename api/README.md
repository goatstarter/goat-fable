# API Layer

Use this layer when running Opus 4.8 outside Claude Code: your own products, agent harnesses, CI bots, anything hitting the Messages API directly.

## Files

- `system-prompt-full.md`: the complete behavior pack as one self-contained system prompt (~2.8k tokens). Default choice for agentic coding backends.
- `system-prompt-compact.md`: ~700-token distillation for token-sensitive or high-volume paths. Keeps the highest failure-cost rules, drops the how-to depth.
- `task-templates/`: fill-in wrappers for the four common task shapes (bugfix, feature, refactor, review). They go in the *user* message and pair with either system prompt.

## Minimal request shape

```jsonc
{
  "model": "claude-opus-4-8",
  "max_tokens": 64000,
  "thinking": { "type": "adaptive" },          // required: Opus 4.8 does no thinking without it
  "output_config": { "effort": "xhigh" },      // Anthropic's recommendation for agentic coding
  "system": "<contents of system-prompt-full.md between the PROMPT markers>",
  "messages": [{ "role": "user", "content": "<task, ideally via a task template>" }]
}
```

Parameter details, quirks, and the list of settings that now return 400 errors (temperature, prefills, budget_tokens): see `../guides/opus-4-8.md`.

## Composition rules

- The system prompt carries *standing behavior*; the task template carries *this task's* goal, constraints, and acceptance criteria. Don't mix the layers: repeating standing rules per-task dilutes them, and burying task facts in the system prompt hides them.
- Front-load everything in the first user message: Opus 4.8 measurably performs worse when requirements drip in across turns.
- Appending your own rules: add them at the end of the system prompt under a clear heading, phrased positively ("do X" not "don't Y"), each with its trigger condition. Prune ruthlessly: a rule the model keeps ignoring usually means the prompt is too long, not too weak.
- For long agent loops, Opus 4.8 accepts mid-conversation `role: "system"` messages: inject reminders or rule changes mid-run without breaking the prompt cache.
