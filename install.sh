#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
home_src="$repo_dir/home"
dest="${HOME:?HOME is not set}"
with_deps=1
for arg in "$@"; do
    case $arg in
        --no-deps) with_deps=0 ;;
        -h|--help)
            printf 'usage: %s [--no-deps]\n' "$0"
            exit 0
            ;;
        *)
            printf 'unknown option: %s\n' "$arg" >&2
            exit 1
            ;;
    esac
done

if [ ! -d "$home_src" ]; then
    printf 'no home/ directory next to this script\n' >&2
    exit 1
fi

backup() {
    target=$1
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        return 0
    fi
    name="$target.bak"
    n=1
    while [ -e "$name" ] || [ -L "$name" ]; do
        name="$target.bak.$n"
        n=$((n + 1))
    done
    mv "$target" "$name"
    printf 'backed up  %s -> %s\n' "$target" "$name"
}

link_entry() {
    src=$1
    target=$2
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        printf 'already    %s\n' "$target"
        return 0
    fi
    mkdir -p "$(dirname "$target")"
    backup "$target"
    ln -s "$src" "$target"
    printf 'linked     %s\n' "$target"
}

for entry in "$home_src"/.config/*; do
    [ -e "$entry" ] || continue
    link_entry "$entry" "$dest/.config/$(basename "$entry")"
done

for entry in "$home_src"/* "$home_src"/.[!.]* "$home_src"/..?*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    base=$(basename "$entry")
    [ "$base" = ".config" ] && continue
    link_entry "$entry" "$dest/$base"
done

# Claude Code hooks that flag a WezTerm tab when Claude finishes or needs input.
# Merged into ~/.claude/settings.json (not linked: Claude rewrites that file).
install_claude_hooks() {
    hooks="$home_src/.config/wezterm/claude-hooks.json"
    settings="$dest/.claude/settings.json"
    if ! command -v jq >/dev/null 2>&1; then
        printf 'jq not found: skipping Claude hooks (%s)\n' "$hooks"
        return 0
    fi
    mkdir -p "$dest/.claude"
    [ -f "$settings" ] || printf '{}\n' > "$settings"
    tmp=$(mktemp)
    jq --slurpfile h "$hooks" '.hooks = ((.hooks // {}) + $h[0].hooks)' "$settings" > "$tmp"
    mv "$tmp" "$settings"
    printf 'merged     %s into %s\n' "$(basename "$hooks")" "$settings"
}

install_claude_hooks

install_deps() {
    if [ "$(uname -s)" != "Darwin" ]; then
        printf '\nNot macOS: skipping dependency install. See README.md for the tool list.\n'
        return 0
    fi

    if ! command -v brew >/dev/null 2>&1; then
        printf '\nHomebrew not found; install it from https://brew.sh then re-run, or see README.md.\n'
        return 0
    fi

    printf '\nInstalling dependencies with Homebrew...\n'
    brew install --cask wezterm font-departure-mono
    brew install neovim starship plantuml imagemagick
}

if [ "$with_deps" = 1 ]; then
    install_deps
fi
