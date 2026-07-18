# Install

Two consumption modes: inside Claude Code (full pack), or via the API (prompts only). Türkçe hızlı kurulum için `README.md`'ye bak.

## Claude Code (recommended)

### Scripted

```bash
git clone https://github.com/goatstarter/goat-fable.git
cd goat-fable
./install.sh /path/to/your/project
```

The script copies `core/`, `guides/`, `hooks/` into `your-project/.claude/goat-fable/`, the four skills into `.claude/skills/`, the two agents into `.claude/agents/`, and appends the core import to your project `CLAUDE.md`. It is idempotent: re-run it to pick up pack updates.

Then, in a session inside the project:

```
/model claude-opus-4-8
/effort xhigh
```

(Or persist both via `.claude/settings.json`: see `hooks/settings.example.json` for the keys. `xhigh` is Anthropic's recommended starting effort for agentic coding on Opus 4.8.)

### Manual (what the script does)

1. `core/CLAUDE-CORE.md` + `guides/` + `hooks/` → `your-project/.claude/goat-fable/`. The core's "depth on demand" section points at `.claude/goat-fable/guides/...`, so this location is load-bearing.
2. Add one line to your project `CLAUDE.md`: `@.claude/goat-fable/core/CLAUDE-CORE.md`
3. `skills/plan-first`, `skills/deep-debug`, `skills/self-review`, `skills/verify-done` → `.claude/skills/` (each is a directory containing a `SKILL.md`).
4. `agents/verifier.md`, `agents/code-reviewer.md` → `.claude/agents/`.
5. Optional but recommended: wire the hooks — stop-verify and destructive-guard (`hooks/README.md`).

### Global install (all projects)

Possible: pack at `~/.claude/goat-fable/`, import from `~/.claude/CLAUDE.md`, skills/agents in `~/.claude/skills|agents/`. Two caveats: the core's guide pointers assume the project-relative path (adjust them to `~/.claude/goat-fable/...` in your copy), and a globally-installed pack also loads when you run Fable 5, which doesn't need it (harmless: the rules are model-agnostic discipline, but it spends context). Per-project is the recommended default.

## API

No installation: copy `api/system-prompt-full.md` (between the PROMPT markers) into your `system` parameter, wrap tasks with `api/task-templates/`, and set the request parameters from `api/README.md` (adaptive thinking is REQUIRED on Opus 4.8, otherwise it does no extended thinking at all).

## Verifying the install

Start a session in the project and check three things:

1. `/context` (or ask "which operating rules are you following?"): the core's rules should be present.
2. Type `/` : `plan-first`, `deep-debug`, `self-review`, `verify-done` should appear in the skill list.
3. Make a trivial code change and try to end the session without running anything: if you wired the hook, the stop-verify reminder fires once.

## Updating

`git pull` in the pack repo, re-run `./install.sh /path/to/project`. The script overwrites pack files but only ever appends (once) to your `CLAUDE.md`.

## Uninstall

Remove `.claude/goat-fable/`, the four skill directories, the two agent files, the import line in `CLAUDE.md`, and the hook entries in `.claude/settings.json` if you added them.
