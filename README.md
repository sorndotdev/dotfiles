# dotfiles

## Install

```sh
./install.sh
```

`home/` mirrors `$HOME`: each entry under `home/.config` is symlinked to
`~/.config/<name>`, and every other entry (e.g. `.zshrc`) to `~/<name>`. An
existing target is moved aside to a unique `<name>.bak[.N]` first, so the
script replaces rather than merges, and never overwrites an earlier backup.

The script also merges `claude-hooks.json` into `~/.claude/settings.json`
(needs `jq`): when Claude Code finishes or asks for input in a tab you are not
looking at, WezTerm plays a sound and paints that tab red until you view it; and
each Claude session's id is recorded so WezTerm can resume it.

WezTerm saves the open tabs to `~/.local/state/wezterm/session.json` every
second. The next time it starts, it restores them: same tabs, splits and
directories, with Claude Code resumed via `claude --resume <session>` and nvim
reopening its files. Other programs come back as a shell in their directory.
Quitting WezTerm ends what runs in it. To start afresh, quit WezTerm and run
`rm ~/.local/state/wezterm/session.json`.

On macOS the script also installs the tools below via Homebrew. Pass
`--no-deps` to link configs only.

## Requirements

On macOS `./install.sh` installs these automatically; elsewhere install them
yourself:

- [WezTerm](https://wezterm.org) and the parchment theme's font,
  [Departure Mono](https://departuremono.com/) (falls back to Hack Nerd Font /
  Menlo)
- [Neovim](https://neovim.io) >= 0.11, the
  [tree-sitter CLI](https://tree-sitter.github.io) (builds the parsers), and
  [Starship](https://starship.rs) (the
  prompt; `home/.zshrc` runs `starship init zsh`)
- [Claude Code](https://claude.com/claude-code), installed via the official
  `claude-code` Homebrew cask; the `cc` alias runs it
- [PlantUML](https://plantuml.com) plus a **real** JDK for the preview. On
  macOS the JDK comes from Homebrew's keg-only `openjdk` (a `plantuml`
  dependency), which `java.zsh` puts on PATH because `/usr/bin/java` is a stub;
  the plugin downloads the jar itself
- [ImageMagick](https://imagemagick.org) (`magick`) so the preview scales
  diagrams to fit the split

## Neovim

Set up as a Python IDE. On first start lazy.nvim installs the plugins, Mason
installs basedpyright and ruff, and nvim-treesitter builds its parsers.
basedpyright uses `<project>/.venv/bin/python` when it exists, so uv projects
resolve imports without activating the venv. Press `<Space>` to list every key.

| Key | Action |
| --- | --- |
| `<Space>e` | File tree (stays open; Enter opens in the editor) |
| `-` | Oil: edit the current file's folder as text |
| `<Space><Space>` | Search everywhere (buffers, recent, project files) |
| `<Space>f` / `<Space>s` / `<Space>b` | Find file / search text / open buffers |
| `gd` / `gr` / `gI` / `gy` | Definition / usages / implementation / type definition |
| `K` | Hover docs |
| `<Space>r` / `<Space>a` | Rename / quick fix |
| `<Space>cf` | Sort imports and format (ruff); saving never formats |
| `<Space>o` / `<Space>O` | Symbols in file / in project |
| `<Space>x`, `]d` / `[d` | Problems list, next / previous problem |
| `<Space>tt` / `tf` / `ta` / `tl` | Test nearest / file / all / last (pytest) |
| `<Space>ts` / `<Space>to`, `]t` / `[t` | Test summary / output, next / previous failure |
| `Ctrl-/` | Toggle terminal |
| `Cmd-[` / `Cmd-]` | Back / forward (WezTerm sends these only to nvim) |
| `af` `if` `ac` `ic` | Select a function or class |

## Layout

```
home/.zshrc
home/.config/zsh/aliases.zsh   # cc, vi, vim
home/.config/zsh/keys.zsh      # Option/Shift+Arrow word motion
home/.config/zsh/java.zsh      # Homebrew openjdk on PATH
home/.config/wezterm/wezterm.lua
home/.config/wezterm/session.lua          # save and restore tabs across reboots
home/.config/wezterm/attention.sh         # Claude Code hook: flag the tab
home/.config/wezterm/claude-session.sh    # Claude hook: record the session id
home/.config/wezterm/set-user-var.sh      # set a user var on this pane
home/.config/wezterm/claude-hooks.json    # merged into ~/.claude/settings.json
home/.config/nvim/
home/.config/starship.toml
install.sh
```
