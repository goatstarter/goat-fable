# Task Template · Refactor

For behavior-preserving restructuring. The invariant that makes refactors safe: the test suite is green before and green after, and the refactor changes zero behavior by construction. Delete the bracketed hints.

```text
Refactor this code. Behavior must not change.

## Target
[What to restructure and into what shape:
"Extract the retry/backoff logic duplicated across src/jobs/*.ts into one
utility", "Split UserService (1,400 lines) by domain: auth, profile, billing".]

## Motivation
[Why: what this refactor should make easier afterwards. This steers a
hundred small judgment calls better than any rule list.]

## Baseline
- Before touching anything, run the test suite and record the result.
- If the suite is not green at baseline, STOP and report; we don't refactor
  on a broken baseline.
- If the code you're restructuring has no meaningful test coverage, STOP
  and tell me; we either add characterization tests first or accept the
  risk explicitly. Do not refactor untested code silently.

## Rules
- Behavior-preserving only: no bug fixes, no improvements, no API changes
  smuggled in. If you find a bug while refactoring, report it; do not fix
  it in this diff.
- Work in steps that each keep the suite green; don't restructure
  everything and reconcile at the end.
- Update every caller/import; grep to find them, don't rely on the ones
  you remember. No re-export shims or `_old` copies left behind unless I
  asked for a migration period.
- Do not modify test assertions. Renames/moves may update test *imports
  and references*; if a test's asserted behavior seems to need changing,
  that's a stop-and-report, because then this isn't a refactor.

## Definition of done
- Suite green at baseline and green after (show both runs).
- Grep evidence that no stale references to the old structure remain.
- Report: the new shape, mechanical vs judgment changes, any bugs or
  smells found-but-not-fixed, and anything that resisted the new structure.
```

## Notes

- "If a test broke, the refactor changed behavior" is the working definition. The only exception is tests that assert structure (imports, file paths); flag those in the report.
- Big refactor? Split it into template-sized rounds ("round 1: extract; round 2: migrate callers; round 3: delete old"), one green suite per round.
