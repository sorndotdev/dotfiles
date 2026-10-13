# dotfiles

## Install

```sh
./install.sh
```

`home/` mirrors `$HOME`: each entry under `home/.config` is symlinked to
`~/.config/<name>`, and every other entry (e.g. `.zshrc`) to `~/<name>`. An
existing target is moved aside to a unique `<name>.bak[.N]` first, so the
script replaces rather than merges, and never overwrites an earlier backup.

On macOS the script also installs the tools below via Homebrew. Pass
`--no-deps` to link configs only.

## Requirements

On macOS `./install.sh` installs these automatically; elsewhere install them
yourself:

- [WezTerm](https://wezterm.org) and the parchment theme's font,
  [Departure Mono](https://departuremono.com/) (falls back to Hack Nerd Font /
  Menlo)
- [Neovim](https://neovim.io) >= 0.10 and [Starship](https://starship.rs) (the
  prompt; `home/.zshrc` runs `starship init zsh`)
- [PlantUML](https://plantuml.com) plus a **real** JDK for the preview. On
  macOS the JDK comes from Homebrew's keg-only `openjdk` (a `plantuml`
  dependency), which `java.zsh` puts on PATH because `/usr/bin/java` is a stub;
  the plugin downloads the jar itself
- [ImageMagick](https://imagemagick.org) (`magick`) so the preview scales
  diagrams to fit the split

## Layout

```
home/.zshrc
home/.config/zsh/aliases.zsh   # oc, cc, vi, vim
home/.config/zsh/keys.zsh      # Option/Shift+Arrow word motion
home/.config/zsh/java.zsh      # Homebrew openjdk on PATH
home/.config/wezterm/wezterm.lua
home/.config/nvim/
home/.config/starship.toml
install.sh
```
