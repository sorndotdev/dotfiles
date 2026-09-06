#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles

# Always track the latest llm-stack master (updates only that input in flake.lock)
(
  cd "$DIR"
  nix flake update llm-stack
)

darwin_rebuild=/run/current-system/sw/bin/darwin-rebuild
if [ ! -x "$darwin_rebuild" ]; then
  rev="$(nix eval --raw --impure --expr \
    "(builtins.fromJSON (builtins.readFile \"$DIR/flake.lock\")).nodes.\"nix-darwin\".locked.rev")"
  exec sudo env "PATH=$PATH" "$(command -v nix)" run \
    "github:nix-darwin/nix-darwin/$rev#darwin-rebuild" \
    -- switch --flake "$DIR#mac"
fi

exec sudo "$darwin_rebuild" switch --flake "$DIR#mac"
