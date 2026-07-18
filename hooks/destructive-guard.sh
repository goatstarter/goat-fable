#!/usr/bin/env bash
# Goat Fable · destructive-guard hook (PreToolUse event, matcher: Bash)
#
# Pauses the FIRST attempt per session at each of three destructive command
# classes (bare force-push, discarding a dirty working tree, recursive delete
# aimed outside the workspace) and feeds back a look-before-you-leap reminder.
# Re-running the command after checking proceeds: the gate makes skipping the
# check explicit, it does not make the action impossible. Exit 2 = block,
# stderr goes back to the model.
#
# Heuristic by design: it pattern-matches the tool input (with JSON escapes
# stripped), and the dirty-tree check runs against the hook's own cwd, which
# can differ from a command that cd's elsewhere first. Extend the patterns to
# your stack. Requires: bash, git, grep, sed.

INPUT="$(cat)"
# JSON-escape-stripped copy for pattern matching (so `rm -rf "/x"` arrives as-typed)
CMDS="$(printf '%s' "$INPUT" | tr -d '\\')"

session_id="$(printf '%s' "$INPUT" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

block_once() { # $1 = category, $2 = reminder fed back to the model
  marker="${TMPDIR:-/tmp}/goat-fable-destructive-${session_id:-unknown}-$1"
  [ -f "$marker" ] && return 0
  touch "$marker"
  printf '%s\n' "$2" >&2
  exit 2
}

# 1. Bare force-push: --force, -f, or a +refspec. --force-with-lease passes
#    (the trailing [ "] anchor keeps --force from matching --force-with-lease).
if printf '%s' "$CMDS" | grep -qE 'git push ([^"]* )?(--force([ "]|$)|-f([ "]|$)|\+[^ "]+)'; then
  block_once forcepush \
    "destructive-guard: bare force-push rewrites shared history and cannot be undone from here. Confirm with the human that this exact push is wanted, and prefer --force-with-lease. Re-running proceeds. (goat-fable, fires once per session)"
fi

# 2. Discarding the working tree while it has uncommitted changes
#    (checkout pattern also catches `git checkout HEAD -- .`)
if printf '%s' "$CMDS" | grep -qE 'git (reset --hard|checkout ([^" ]+ )?(-- )?\.([" ]|$)|clean -[a-zA-Z]*f)'; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    block_once discard \
      "destructive-guard: the working tree has uncommitted changes and this command discards them. Some may be the human's half-finished work, which no session can recreate. Run git status, confirm every entry is disposable (stash if unsure), then re-run. (goat-fable, fires once per session)"
  fi
fi

# 3. Recursive rm aimed at an absolute or home path. Two conditions: an rm
#    with a recursive-looking flag anywhere, and a first path argument that is
#    absolute, ~, or $HOME (options — including --long ones — skipped).
if printf '%s' "$CMDS" | grep -qE 'rm +[^;&|"]*(-[a-zA-Z]*r|--recursive)' && \
   printf '%s' "$CMDS" | grep -qE 'rm +(--?[a-zA-Z][a-zA-Z-]* +|-- +)*"?(/|~|\$HOME)'; then
  block_once rmrf \
    "destructive-guard: recursive delete aimed at an absolute or home path. Verify the exact target (ls it first) and confirm with the human if this session did not create it. Re-running proceeds. (goat-fable, fires once per session)"
fi

exit 0
