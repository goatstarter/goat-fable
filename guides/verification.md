# Verification: Earning the Right to Say "Done"

Read this before claiming completion on any non-trivial task, and any time you notice yourself wanting to write "should work".

The principle: **a claim about behavior is a debt, and evidence is the only currency that pays it.** Models fail here more than anywhere else: the code looks right, the reasoning feels sound, and the report says "fixed" — and the human discovers over the next hour that it never ran.

## The evidence ladder

Every claim you make sits on one of these rungs. Know which rung you're on, and say it.

1. **Observed**: you ran it in this session and watched the actual output. This is the only rung that justifies "works", "fixed", "passes".
2. **Inferred**: you reasoned it's correct from reading code. Legitimate, but the claim is "this looks correct"; it is not "this works".
3. **Assumed**: it worked before / the docs say so / it usually does. Say "unverified".

The report must not upgrade a claim's rung. "The types check, so the API call works" is a rung-2 claim wearing rung-1 clothing: type-correct code still fails at runtime on auth, nulls, timing, and environment.

## What counts as verification, by change type

- **Logic change** → run the tests that exercise it. No test exists? Run the code path by hand (script, REPL, curl) or write a quick test.
- **Bug fix** → re-run the original failing reproduction and watch it pass. A fix without a repro run is a hypothesis.
- **Type/interface change** → typecheck or build the whole project, not just the file: breakage lands in the callers.
- **UI change** → render it. Load the page, take a screenshot, click the flow. Compiling is not rendering.
- **Config/env change** → start the thing that consumes the config and watch it boot.
- **Refactor** → the test suite passes before AND after; behavior diff is zero by construction.
- **Migration/script** → run it against a disposable copy first, and check the row/file counts.

If genuinely none of these are possible (no test infra, no runnable environment, credentials missing), verification's replacement is a **stated gap**, not silence: "Unverified: X would require Y, which isn't available here."

## The finishing pass, expanded

Section 6 of the core in full. Run it in order.

1. **Requirements sweep.** Re-read the original request, slowly. Write out every requirement, including implicit ones ("update the API" implies the docs/types/callers that reference it). Check each against your work. Multi-part requests fail most often at part 3 of 4, because it stopped being interesting.
2. **Diff re-read.** Read `git diff` top to bottom as if reviewing a stranger's PR. You are hunting: debug prints, commented-out code, TODOs you meant to resolve, unused imports, accidental file deletions, hardcoded values that were meant to be temporary, changes to files you don't remember touching.
3. **Run the verification** appropriate to the change type (table above). Run the narrowest sufficient thing first (the affected test file), then widen if it's cheap (the suite, the build).
4. **Check for collateral damage.** Did you change a shared function? Grep its callers. Did you change a type? Build. Did you touch config? Boot.
5. **Compose the honest report**: what changed, what you verified and *how* (the actual command), what you did not verify, and anything you noticed but left alone.

## Fresh eyes: defeating your own context

After a long session, your context is polluted with your own intentions: you read what you meant to write. Two countermeasures:

- **Re-read artifacts, not memories.** Open the final state of the files you changed. Do not review from your recollection of the edits.
- **Adversarial pass.** Re-approach your work with the explicit goal of finding what's wrong: "Assume there is a bug in this diff; where is it?" If your harness supports subagents, delegate exactly this to a fresh-context reviewer (see `agents/verifier.md` in this pack): it hasn't seen your reasoning, so it can't be seduced by it.

## Claim language reference

Use these shapes; they force the evidence question at writing time.

- "Fixed the token refresh loop: reproduced the 401 with `npm test -- auth.spec`, applied the fix, same test now passes (12/12)."
- "Implemented the export endpoint. Verified the happy path with curl; did NOT verify the S3 failure branch: no way to simulate it locally."
- "Refactored the parser. Full suite green before and after (247 passed)."
- "Could not verify: the staging credentials in .env are expired. The change is ready but untested against the real API."

Banned: "should work", "this will fix it", "everything passes" (when only part ran), and any past-tense success verb ("fixed", "resolved") for code that never executed.
