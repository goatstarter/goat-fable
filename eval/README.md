# Eval: Proving the Pack Works (on Your Repo)

Claims about prompts are cheap; this directory makes the pack's claim falsifiable. The design is A/B: the same tasks, the same repo, Opus 4.8 with and without the pack, scored on the same rubric. Everything here is documentation: you run it when you choose to (each full pass costs real quota: expect on the order of 10-20 agentic sessions).

## What we measure, and why it's shaped this way

Two principles borrowed from how agent benchmarks fail:

1. **Score against checks the agent didn't see.** Agents saturate visible success criteria while failing held-out ones. So each task defines a *hidden check* the evaluator runs afterwards (a repro command, a grep, a curl): the model never sees it, so it can't optimize for it.
2. **Score behavior, not just outcome.** The pack's promise is behavioral (verification, root-causing, diff discipline, honesty). A lucky pass with a symptom-patch and an overclaiming report should LOSE to an honest partial. The rubric encodes that, including an integrity gate that zeroes a run caught gaming a check.

## Task set

`tasks/` contains 9 behavior-trap tasks, each generic and instantiable in any real repo of yours (instructions inside each file). They map to the pack's core sections: root-causing, requirements sweep, integrity under temptation, honesty about blockers, verification before claiming, scope discipline, trust-boundary discipline.

Instantiate each task ONCE, in a throwaway copy of a real project (real repos beat toys: the traps depend on real complexity), and reuse the identical instantiation for both arms.

## Running the two arms

```bash
# Arm A: baseline
cp -R ~/code/your-project /tmp/eval-baseline && cd /tmp/eval-baseline
git init -q 2>/dev/null; git add -A && git commit -qm baseline
claude --model claude-opus-4-8 --permission-mode acceptEdits
# paste the task prompt exactly as written in the task file, let it finish

# Arm B: pack installed (see INSTALL.md: .claude/goat-fable + CLAUDE.md import + skills/agents)
cp -R ~/code/your-project /tmp/eval-pack && cd /tmp/eval-pack
# ...install pack, commit baseline, then identical prompt, same model
```

Headless alternative for batching: `claude -p "$(cat prompt.txt)" --model claude-opus-4-8 --permission-mode acceptEdits`. Run inside a container/VM if the tasks touch anything you care about.

Same effort level on both arms (`/effort xhigh`): the pack competes on behavior, not on a reasoning-budget handicap.

## Collecting artifacts per run

1. The model's final report (copy verbatim).
2. `git diff` against the baseline commit, plus `git status` for created files.
3. The hidden check's result (you run it, after the session ends).
4. Optional: turns/tokens used, for a cost comparison.

## Scoring

Score each run with `rubric.md`, by hand or with `judge-prompt.md` (a stronger model, e.g. Fable 5, as judge: paste prompt + artifacts, get JSON scores). Judge the two arms blind if you can (strip the pack's traces from the report before judging, or have someone shuffle them).

Then compare per-dimension averages. The expected signature of the pack, based on what it targets: largest gains on *verification evidence*, *honesty*, and *diff discipline*; task success improves mainly via the root-cause and integrity tasks; communication scores rise across the board. If a dimension doesn't move on your repo, its rules are dead weight for you: prune them from the core and keep the pack lean.
