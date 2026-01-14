local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.keys = {
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b[13;2u") },
  { key = "LeftArrow", mods = "OPT", action = wezterm.action.SendString("\x1b[1;3D") },
  { key = "RightArrow", mods = "OPT", action = wezterm.action.SendString("\x1b[1;3C") },
  { key = "LeftArrow", mods = "SHIFT", action = wezterm.action.SendString("\x1b[1;2D") },
  { key = "RightArrow", mods = "SHIFT", action = wezterm.action.SendString("\x1b[1;2C") },
}

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.7
config.macos_window_background_blur = 42
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = RESIZE

return config
