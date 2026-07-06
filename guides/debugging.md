# Debugging: The Root-Cause Protocol

Read this when a bug has survived two fix attempts, when a failure makes no sense, or before starting on any bug reported as "weird", "flaky", or "impossible".

The core discipline: **you are not allowed to change code until you can explain the mechanism of the failure.** Every shortcut around this rule costs more time than it saves.

## Phase 0: Reproduce

Before anything else, make the bug happen on demand.

- Find the smallest command that shows the failure: one test, one curl, one function call in a REPL. Save it; this is your proof-of-fix later.
- If you cannot reproduce it, you have a different task: gathering the missing conditions (data, env, timing, version). Say so instead of fixing blind.
- Flaky bugs: run the reproduction 5-10 times and record the failure rate before changing anything. Otherwise you cannot tell "fixed" from "got lucky".

## Phase 1: Read the actual error

- Read the whole error, not the first line. The real cause is often in the second exception ("caused by"), the middle of the stack trace, or a warning three lines above.
- Go to the exact file and line the trace names. Read that code and 20 lines around it.
- Distinguish the *site* of the error from the *source* of the error. `undefined is not a function` at line 40 usually means bad data was created somewhere else and arrived at line 40. Trace the value backwards.

## Phase 2: Locate by evidence, not intuition

When the cause isn't obvious from the trace:

- **Instrument, don't stare.** Add targeted logging (input values, branch taken, timing) at the suspected boundary, run the repro, read the output. One log run beats ten minutes of squinting at code.
- **Bisect the space.** Cut the pipeline in half: is the data already wrong at the midpoint? If yes, the bug is upstream; if no, downstream. Repeat. For regressions, `git bisect` with your reproduction script finds the guilty commit mechanically.
- **Diff the working case.** If it works in test A but fails in test B, list every difference (data, config, order, env) and eliminate them one at a time.

## Phase 3: The hypothesis loop

State a falsifiable hypothesis about the mechanism, in one sentence, before touching code:

> "The session is null because the middleware runs before the cookie parser registers."

Then run the **cheapest test that could prove it false**: a log line, a reordering in a scratch copy, a unit call with controlled input. Not a full fix.

- Hypothesis confirmed → go to Phase 4.
- Hypothesis falsified → good, you eliminated a branch. Form the next one from what the test showed.
- You cannot state a mechanism → you are still in Phase 2. Gather more evidence.

Keep a written scratch list of hypotheses tried and their outcomes. This prevents the classic loop of re-trying a falsified idea 20 minutes later.

## Phase 4: Fix, prove, sweep

1. Fix the mechanism, at the layer where the wrong value or wrong order is born, not where it explodes.
2. Re-run the original reproduction from Phase 0 and watch it pass. For flaky bugs, re-run it as many times as you ran the failing baseline.
3. Run the surrounding tests to check for collateral damage.
4. Sweep for siblings: the same wrong pattern usually exists in more than one place. Grep for it. Report siblings even if fixing them is out of scope.

## When stuck: the assumption audit

Three genuinely different approaches failed? Stop. One of your assumptions is wrong, and it is usually an embarrassing one. Check these in order, by *observing* rather than reasoning:

1. Is the code I'm editing actually the code that runs? (build output vs source, deployed vs local, right service, right branch)
2. Is my change loaded? (server restarted, cache cleared, module not memoized, correct env)
3. Is the input what I think it is? (log it, don't assume it)
4. Is the version what I think it is? (lockfile, `--version`, node_modules reality)
5. Is the test even exercising this path? (add a deliberate crash; if the test still passes, it never reached your code)
6. Does the documentation match this version's actual behavior?

If all six check out, escalate honestly: report the reproduction, the hypotheses eliminated, and the evidence gathered. That report is valuable; a fake fix is not.

## Anti-patterns (never do these)

- **Shotgun debugging**: changing several things at once and re-running. When it passes you've learned nothing, and one of those changes broke something else.
- **Patch-and-pray**: adding a null check / try-except / retry / `?? defaultValue` at the crash site without knowing why the bad value exists. This converts a loud bug into silent data corruption.
- **Cosmetic retries**: re-trying a failed approach with renamed variables or reordered lines. If the mechanism didn't change, the outcome won't.
- **Blaming the platform**: "it must be a bug in the framework/library" is occasionally true but is the *last* hypothesis, adopted only with a minimal reproduction outside your code.
- **Fix-by-deletion**: removing the assertion, test, or validation that caught the problem. That is not a fix; that is destroying the smoke detector.
