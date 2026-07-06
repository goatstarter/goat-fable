# Task Template · Bugfix

Opus 4.8 performs best when the whole task arrives in the first message. Fill every slot you can; each empty slot is a guess you're delegating. Delete the bracketed hints.

```text
Fix this bug.

## Symptom
[What happens, verbatim: the error message, the wrong output, the broken behavior.
Paste the actual stack trace / log lines, not a paraphrase.]

## Expected
[What should happen instead.]

## Reproduction
[Exact steps or command that triggers it: "run `npm test -- auth.spec`",
"POST /api/orders with this payload", "click X then Y".
If you don't have one, say so: "No known reproduction; first find one."]

## Context
[Anything you already know or suspect: when it started, related recent changes,
which parts of the code are involved, what has already been tried and failed.]

## Constraints
[What must not change: public APIs, database schema, behavior of neighboring features.
Which files/dirs are in bounds, which are off limits.]

## Definition of done
- The reproduction above passes after the fix, and you show me that run.
- Root cause identified and explained: what mechanism produced the symptom.
  A fix you can't explain is not accepted.
- Existing tests still pass (show the run). If no test covered this bug, add one
  that fails before your fix and passes after.
- Checked for sibling instances of the same mistake elsewhere; report any found.
- Do not weaken, skip, or delete any test to get green. If you believe a test
  itself is wrong, stop and tell me instead.
- Report: the cause, the fix, what you verified and how, anything you noticed
  but deliberately left alone.
```

## Why these slots

- **Verbatim symptom + reproduction** are the two highest-value inputs; without a reproduction, insist the model build one before fixing (a fix without a repro run is a hypothesis).
- **"Explain the mechanism"** in the definition of done blocks symptom-patching (the null-check/try-except reflex).
- **The test-integrity clause** uses the official anti-reward-hacking language; leave it in even when it feels paranoid. It's cheapest exactly when you didn't need it.
