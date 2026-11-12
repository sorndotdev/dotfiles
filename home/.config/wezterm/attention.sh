#!/bin/bash
# Flag (or clear) this WezTerm pane as needing attention by setting the
# `claude_attention` user var. WezTerm turns the tab red and plays a sound.
# Usage: attention.sh set|clear  (run from Claude Code hooks)
cat >/dev/null  # drain the hook's JSON on stdin

if [ "$1" = set ]; then value="$(date +%s)$RANDOM"; else value=""; fi
"$(dirname "$0")/set-user-var.sh" claude_attention "$value"
