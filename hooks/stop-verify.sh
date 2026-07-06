#!/usr/bin/env bash
# Goat Fable · stop-verify hook (Stop event)
#
# Blocks Claude's FIRST attempt to end its turn when the working tree has
# changes but no verification-looking command ran this session, and feeds it
# a reminder instead. Fires at most once per session; exit 2 = block, stderr
# goes back to the model.
#
# This is a heuristic starting point: extend VERIFY_PATTERN with your stack's
# actual test/build commands. Requires: bash, git, grep, sed.

INPUT="$(cat)"

session_id="$(printf '%s' "$INPUT" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
transcript="$(printf '%s' "$INPUT" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

# Nag once per session, then stay quiet.
marker="${TMPDIR:-/tmp}/goat-fable-stop-verify-${session_id:-unknown}"
[ -f "$marker" ] && exit 0

# Not a git repo, or nothing changed: nothing to verify.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[ -z "$(git status --porcelain 2>/dev/null)" ] && exit 0

# Did any verification-looking command run this session?
VERIFY_PATTERN='npm (run )?test|pnpm (run )?test|yarn test|bun test|vitest|jest|pytest|python -m pytest|go test|cargo test|mix test|rspec|phpunit|gradle test|mvn test|tsc|npm run build|pnpm (run )?build|next build|vite build|make test|make check'
if [ -n "$transcript" ] && [ -f "$transcript" ] && grep -E '"command"' "$transcript" | grep -qE "$VERIFY_PATTERN"; then
  exit 0
fi

touch "$marker"
cat >&2 <<'MSG'
Stop check: the working tree has changes, but no test/build command ran this
session. Before finishing, either run the verification appropriate to the
change (tests, build/typecheck, or actually executing it), or state explicitly
in your report that the work is unverified and why. (goat-fable stop-verify,
fires once per session)
MSG
exit 2
