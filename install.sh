#!/usr/bin/env bash
set -euo pipefail
# Goat Fable installer: copies the pack into a project's .claude/ directory
# and wires the CLAUDE.md import. Idempotent: safe to re-run after pack updates.
#
# Usage: ./install.sh /path/to/your/project

TARGET="${1:?Usage: ./install.sh /path/to/your/project}"
SRC="$(cd "$(dirname "$0")" && pwd)"

[ -d "$TARGET" ] || { echo "error: $TARGET is not a directory" >&2; exit 1; }

# Core + guides + hooks live under .claude/goat-fable/ (the core's guide
# pointers reference these exact paths).
mkdir -p "$TARGET/.claude/goat-fable" "$TARGET/.claude/skills" "$TARGET/.claude/agents"
cp -R "$SRC/core" "$TARGET/.claude/goat-fable/"
cp -R "$SRC/guides" "$TARGET/.claude/goat-fable/"
cp -R "$SRC/hooks" "$TARGET/.claude/goat-fable/"
chmod +x "$TARGET/.claude/goat-fable/hooks/"*.sh

# Skills and agents go where Claude Code discovers them.
# (strip the glob's trailing slash: BSD cp treats "dir/" as "contents of dir")
for s in "$SRC"/skills/*/; do
  cp -R "${s%/}" "$TARGET/.claude/skills/"
done
cp "$SRC"/agents/*.md "$TARGET/.claude/agents/"

# Wire the import into the project CLAUDE.md (once).
IMPORT_LINE="@.claude/goat-fable/core/CLAUDE-CORE.md"
CLAUDE_MD="$TARGET/CLAUDE.md"
touch "$CLAUDE_MD"
if grep -qF "$IMPORT_LINE" "$CLAUDE_MD"; then
  echo "· CLAUDE.md already imports the core (skipped)"
else
  printf '\n%s\n' "$IMPORT_LINE" >> "$CLAUDE_MD"
  echo "· Added core import to CLAUDE.md"
fi

echo "
Installed into $TARGET:
  .claude/goat-fable/{core,guides,hooks}
  .claude/skills/{plan-first,deep-debug,self-review,verify-done}
  .claude/agents/{verifier,code-reviewer}.md

Manual steps left (deliberately not automated):
  1. In the project session, set the model and effort:
       /model claude-opus-4-8
       /effort xhigh
     (or merge .claude/goat-fable/hooks/settings.example.json keys into
      .claude/settings.json)
  2. Optional stop-verify hook: merge the \"hooks\" key from
     .claude/goat-fable/hooks/settings.example.json into .claude/settings.json.
     Details: .claude/goat-fable/hooks/README.md
"
