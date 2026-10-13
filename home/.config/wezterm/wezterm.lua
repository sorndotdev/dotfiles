local wezterm = require('wezterm')

local config = wezterm.config_builder()

local theme = wezterm.plugin.require('https://github.com/sorndotdev/wezterm-parchment-theme')
theme.apply_to_config(config)

config.keys = {
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[13;2u') },
  { key = 'LeftArrow', mods = 'OPT', action = wezterm.action.SendString('\x1b[1;3D') },
  { key = 'RightArrow', mods = 'OPT', action = wezterm.action.SendString('\x1b[1;3C') },
  { key = 'LeftArrow', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[1;2D') },
  { key = 'RightArrow', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[1;2C') },
}

config.audible_bell = 'Disabled'
config.window_decorations = 'RESIZE'

return config
