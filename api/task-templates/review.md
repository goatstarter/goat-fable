# Task Template · Code Review

For reviewing a diff, PR, or module. Calibrated for a documented Opus 4.8 trap: severity filters ("only report serious issues") make it self-censor borderline findings and measurably depress recall. So this template runs review in two stages: an unfiltered finder, then a verifier. Delete the bracketed hints.

## Stage 1: find (run first)

```text
Review this change.

## What to review
[The diff, PR link, branch, or file list. For a PR: the description/intent
too, so the review can check the change against its stated purpose.]

## What this change is supposed to do
[One paragraph. Reviews without intent devolve into style commentary.]

## Focus
[Rank what matters here: correctness / security / performance / data
integrity / API design. The top item gets the deepest look.]

## Instructions
- Read the surrounding code, not just the diff: bugs live at the boundary
  between changed and unchanged lines. Check callers of anything whose
  behavior changed.
- Report EVERY issue you find, including ones you're unsure about; a
  separate verification step will filter. Your goal here is coverage, not
  precision. Do not self-censor borderline findings.
- For each finding: file:line, what's wrong, why it matters, how confident
  you are (certain / likely / needs-verification), and a suggested fix
  direction.
- Separately answer: does the change actually do what it's supposed to do?
  Any stated requirement it misses?
- Note what you could NOT assess (untestable paths, missing context).
```

## Stage 2: verify (fresh context)

Run in a NEW session/agent with no memory of stage 1's reasoning:

```text
Below are claimed findings from a code review. For each one, act as a
skeptic: read the actual code and decide REAL or FALSE ALARM, with the
evidence (the code path that confirms or refutes it). Do not take the
finding's word for anything. Then rank the REAL ones by severity.

[paste stage 1 findings + repo access / relevant files]
```

## Notes

- The two-stage split exists because one pass optimizes recall and precision against each other. Finder maximizes recall; skeptic restores precision; you read only stage 2's output.
- For quick informal reviews, stage 1 alone works: read its "certain" findings, spot-check the rest.
- Reviewer findings are claims, not facts: before acting on one that implies a big change, verify it against the code yourself.
