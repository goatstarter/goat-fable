# Orchestration: Subagents, Parallelism, and Fresh Eyes

Read this when deciding how to split work across subagents, or when a task involves searching/reviewing at a scale one context can't hold.

## When to delegate, when not to

Use subagents when tasks can run in parallel, require isolated context, or involve independent workstreams. Work directly for simple tasks, sequential operations, and single-file edits: a subagent round-trip costs latency and loses context, so it must buy something.

Delegate:
- **Broad searches** ("where is rate limiting handled across these services?"): the subagent reads dozens of files and returns a conclusion; your context receives one paragraph instead of forty file dumps.
- **Independent parallel chunks** (migrate 12 call sites, audit 5 modules): fan out one subagent per chunk, same turn, and let them run concurrently.
- **Fresh-context review** (below): the one job you structurally cannot do yourself.

Don't delegate:
- A single-fact lookup where you know the file: just read it.
- Work that needs the context you've already built: re-briefing costs more than doing.
- Sequential steps where each depends on the last.

Two calibration notes: don't spawn a subagent for work you can complete directly, and when you *do* fan out across independent items, spawn all of them in the same turn rather than one at a time.

## Briefing a subagent

A subagent knows nothing about your session. Vague briefs return vague results, and the failure is yours, not the subagent's. Every brief carries five parts:

1. **Goal**: the question to answer or artifact to produce, precisely.
2. **Scope**: which directories/files/services are in bounds, which are explicitly out.
3. **Constraints**: read-only vs may-edit, conventions to follow, things it must not touch.
4. **Return format**: exactly what you want back ("list of file:line + one-line explanation each", "a verdict: REAL or FALSE-ALARM with evidence"). Tell it the response is data for you, not prose for a human.
5. **Context it can't discover**: decisions already made, constraints from the human, what's been tried.

## Trust, but verify the merge

Subagent output is a claim, not a fact. Before building on it: spot-check one or two of its assertions against the actual files. If a subagent says "no usages of X remain", grep once yourself; thirty seconds of verification beats an hour of building on a wrong premise.

## The fresh-context reviewer (highest-value pattern)

After long work on a change, your context is saturated with your own intentions: you review what you *meant*, not what you wrote. A fresh-context subagent has no such bias, which is why separate verifier subagents outperform self-critique.

Pattern (see `agents/verifier.md` for the ready-made agent):

- Give the reviewer: the original requirements (verbatim), the diff or file list, and how to run the checks.
- Do NOT give it: your reasoning, your summary of what you did, or your confidence. That's the contamination you're paying to avoid.
- Scope the review: "flag only gaps that affect correctness or the stated requirements." An unscoped reviewer prompted to find problems will always find *something*; unscoped findings drive over-engineering, not quality.
- On findings: verify each against the code before acting. Reviewer claims are subject to the same evidence rules as everything else.

Variants that pay off on bigger work:
- **Writer/reviewer split**: one session implements, a second session (or subagent) reviews the diff cold.
- **Adversarial verification of findings**: for each claimed bug, spawn a checker whose explicit job is to *refute* it; keep only findings that survive. This kills the plausible-but-wrong.
- **Independent double-solve**: for high-stakes small problems, have two subagents solve independently and compare answers; disagreement is a flag on your assumptions.

## Parallel work on files: isolation

Parallel subagents reading is always safe; parallel subagents *writing* to the same working tree is not. If multiple agents must mutate code simultaneously, isolate them (git worktrees, or one directory each) and merge deliberately. If you can't isolate, serialize the writes.
