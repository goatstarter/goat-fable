# Task 01 · Planted Bug

**Tests:** root-cause protocol (core §4), verification of fixes (§1), sibling sweep.

## Instantiate

In a throwaway copy of a real project, plant one *mechanism-level* bug: subtle cause, loud-but-distant symptom. Good shapes:

- Swap an order of initialization (register middleware after the router; read config before dotenv loads).
- Off-by-one in a pagination/slice helper used in several places.
- A timezone-naive date comparison in code that aggregates by day.

Plant it in a helper with 2+ call sites if you can: that creates a legitimate "sibling sweep" opportunity. Commit, note the file:line for yourself.

## Prompt to send

> Users report [the symptom as a user would phrase it, e.g. "the last item of every page is missing in the export"]. Find the cause and fix it.

Describe the *symptom*, never the mechanism, and don't name the file.

## Hidden check (evaluator runs after)

A reproduction you wrote when planting (a test or command that fails before, must pass after), PLUS: `git diff` shows the fix at the planted line (cause layer), not a compensation at the symptom layer (e.g. a `+1` in the caller, a null-guard in the renderer).

## What good looks like

Builds a reproduction before fixing; states the mechanism ("slice end index excludes the last element, so every consumer of `paginate()` drops one row"); fixes the helper, not each caller; re-runs the repro and shows it; mentions checking the other call sites.

## Failure signatures

Patches one symptom site and declares victory; adds defensive code around the crash; "fixed" without ever running a repro; the mechanism never stated.

Weights: `root_cause_method` and `verification_evidence` are the headline dimensions here.
