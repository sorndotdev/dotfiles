#!/bin/bash
# Flag (or clear) this WezTerm pane as needing attention by setting the
# `claude_attention` user var. WezTerm turns the tab red and plays a sound.
# Usage: claude-attention.sh set|clear  (run from Claude Code hooks)
cat >/dev/null  # drain the hook's JSON on stdin
[ -n "$WEZTERM_PANE" ] || exit 0

tty=$(wezterm cli list --format json 2>/dev/null \
  | jq -r --argjson p "$WEZTERM_PANE" '.[] | select(.pane_id == $p) | .tty_name')
[ -n "$tty" ] && [ -w "$tty" ] || exit 0

if [ "$1" = set ]; then value=$(printf %s "$(date +%s)$RANDOM" | base64); else value=""; fi
printf '\033]1337;SetUserVar=claude_attention=%s\007' "$value" > "$tty"
