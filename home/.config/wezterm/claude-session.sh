#!/bin/bash
# Record this pane's Claude Code session id in the `claude_session` user var,
# so WezTerm can resume it after a reboot (see session.lua).
# Run from the SessionStart hook, which also fires on /clear and /resume.
session=$(jq -r '.session_id // empty')
[ -n "$session" ] || exit 0
"$(dirname "$0")/set-user-var.sh" claude_session "$session"
