#!/bin/bash
# Set a user var on the WezTerm pane this runs in by writing the escape
# sequence to the pane's tty (hooks have no controlling terminal of their own).
# Usage: set-user-var.sh NAME [VALUE]  (no VALUE clears it)
[ -n "$WEZTERM_PANE" ] || exit 0

tty=$(wezterm cli list --format json 2>/dev/null \
  | jq -r --argjson p "$WEZTERM_PANE" '.[] | select(.pane_id == $p) | .tty_name')
[ -n "$tty" ] && [ -w "$tty" ] || exit 0

printf '\033]1337;SetUserVar=%s=%s\007' "$1" "$(printf %s "$2" | base64)" > "$tty"
