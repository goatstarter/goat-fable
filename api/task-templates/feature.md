# Task Template · Feature

For new functionality. The acceptance-criteria slot is the load-bearing one: it converts "looks done" into "checkably done". Delete the bracketed hints.

```text
Implement this feature.

## Goal
[One paragraph: what the feature does and for whom. Include the *intent*,
not just the mechanics; the model generalizes correctly from motivation.]

## Acceptance criteria
[Numbered, each one independently checkable. These define done.
1. GET /api/export returns a CSV with columns a,b,c for the current user's items
2. Rows are ordered by created_at descending
3. An empty account returns a CSV with headers only, HTTP 200
4. Requests without a session return 401
Write the edge cases you care about as criteria; unwritten expectations
are coin flips.]

## Scope
[Which parts of the codebase this touches. Explicitly name what is OUT of
scope; Opus 4.8 follows instructions literally, so "add it to the settings
page" means one page even if three pages have the same widget. State
"everywhere X appears" when you mean it.]

## Constraints
[Stack, patterns to follow ("do it the way ./src/api/orders.ts does"),
things that must not change, dependencies policy (default: no new
dependencies without asking).]

## Definition of done
- Every acceptance criterion demonstrated: for each one, show the command,
  request, or test run that proves it.
- Follows the existing code conventions; the diff should read like the
  original author wrote it.
- Tests: [pick one]
    - add tests covering criteria 1-N
    - no new tests needed, but the existing suite must pass (show the run)
- No files created beyond what the feature needs; scratch files cleaned up.
- Report: what was built, evidence per criterion, judgment calls made,
  what was NOT verified and why.
```

## Notes

- Default Opus 4.8 builds what you asked and stops. If you want it to go further ("include as many relevant states, validations, and interactions as a production feature would have; go beyond the basics"), say so explicitly in the Goal.
- For features big enough to argue about, run a planning turn first: "Propose a plan with the file-level changes and your open questions; don't write code yet." Approve the plan, then send this template.
