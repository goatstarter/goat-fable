# Code Quality: Writing Diffs That Look Like the Original Author's

Read this before larger implementation work, or when working in an unfamiliar codebase.

The bar: a reviewer looking at your diff should not be able to tell an AI wrote it. AI-authored code has a recognizable accent (over-commenting, defensive bloat, gratuitous abstraction, orphan files), and every item below removes part of that accent.

## Match the codebase, not your taste

Before writing, read 2-3 neighboring files of the same kind (another route, another component, another test) and absorb:

- Naming conventions (camelCase vs snake_case, verbNoun vs nounVerb, file naming)
- Error handling idiom (exceptions vs result types, where validation lives)
- Import style and ordering
- Test structure (fixtures, mocking approach, assertion style)
- Comment density (usually far lower than your instinct)

When your preference conflicts with the codebase's convention, the codebase wins. Consistency beats local optimality: a "better" pattern used once is a maintenance burden, not an improvement.

## The comment policy

Most comments a model wants to write are noise. The test: **does this comment say something the code cannot?**

Allowed (constraints and non-obvious "why"):
```ts
// Stripe requires idempotency keys to be reused on retry, so this must
// be derived from the order id, not generated per call.
const idempotencyKey = `order-${order.id}`;
```

Not allowed (narration, change-explanation, tutorial voice):
```ts
// Get the user from the database        ← narrates the next line
const user = await db.user.find(id);

// Changed this to use the new API       ← talks to the reviewer; belongs in the report
// First we check if the user exists     ← tutorial voice
// TODO: could be optimized              ← speculation without a plan
```

If the code needs narration to be understood, rewrite the code (better names, smaller functions), don't annotate it.

## Minimal diff discipline

- Touch the lines the task requires and no others. Reformatting untouched lines, reordering imports, renaming things "for clarity": all of it pollutes the diff, masks the real change, and creates merge conflicts.
- Don't add configuration options, parameters, or generality that the current task doesn't use. YAGNI is a diff-size rule, not just an architecture rule.
- Abstraction needs three real call sites, not two hypothetical ones. Duplicating a 4-line block twice is cheaper than the wrong abstraction.
- Before writing a helper, grep for the one that already exists. Most mature codebases already have `formatDate`, `chunk`, `retry`, and `slugify`; a second copy is a bug factory.
- Before adding a dependency, check whether the stdlib or an already-installed package covers it. A new dependency is a permanent cost and is the human's call for anything non-trivial: propose it in the report.

## Error handling: loud, at the boundary

- Validate at the system's edges (request handlers, file readers, external API responses); trust internal calls. Sprinkling null checks on every function is noise that hides the real contracts.
- Never swallow: an empty `catch`, a bare `except: pass`, or `catch (e) { console.log(e) }` that lets execution continue in a corrupt state, all convert crashes into data corruption. If you can't handle an error meaningfully, let it propagate.
- No silent fallbacks: `value ?? someDefault` is only correct when the default is *semantically right*, not when it makes the error go away. A wrong-but-plausible value in production is worse than an exception.
- Error messages must carry the context needed to debug them: which id, which file, which endpoint. `throw new Error("failed")` is a future debugging session you're scheduling for someone else.

## File discipline

- New files only when the task genuinely needs them. Never create: example/demo files, `*_v2` or `*_new` variants alongside the original, README/docs nobody requested, scratch scripts left in the repo.
- Edit the existing file rather than writing a parallel one. If a rewrite is truly cleaner, replace the file, don't fork it.
- If you created temporary artifacts while working (fixtures, scratch scripts, debug output), delete them before finishing. `git status` must be clean of surprises.

## Pre-finish sweep (mechanical)

Run through the diff and remove:

- `console.log` / `print` / debug logging you added while working
- Commented-out code (delete it; git remembers)
- Unused imports and variables your changes orphaned
- TODOs you wrote but can actually resolve now
- Hardcoded values that were meant to be temporary (paths, ids, ports, sleeps)

Then check `git status` for files you created and forgot about.
