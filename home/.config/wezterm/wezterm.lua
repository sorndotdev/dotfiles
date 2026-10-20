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

-- Claude Code / opencode attention: a hook sets the `claude_attention` user
-- var when the agent finishes or needs input. Play a sound unless the pane is
-- in view, paint its tab red until it is looked at.
local ATTENTION_SOUND = wezterm.config_dir .. '/sounds/damage.mp3'

local function pane_in_view(window, pane)
  return window:is_focused() and window:active_tab():tab_id() == pane:tab():tab_id()
end

wezterm.on('user-var-changed', function(window, pane, name, value)
  if name == 'claude_attention' and value ~= '' and not pane_in_view(window, pane) then
    wezterm.background_child_process({ 'afplay', ATTENTION_SOUND })
  end
end)

-- Clear the flag once its tab is in view.
wezterm.on('update-status', function(window)
  if not window:is_focused() then
    return
  end
  for _, p in ipairs(window:active_tab():panes()) do
    local flag = p:get_user_vars().claude_attention
    if flag and flag ~= '' then
      pcall(p.inject_output, p, '\027]1337;SetUserVar=claude_attention=\007')
    end
  end
end)

wezterm.on('format-tab-title', function(tab)
  local title = tab.tab_title ~= '' and tab.tab_title or tab.active_pane.title
  for _, p in ipairs(tab.panes) do
    local flag = p.user_vars.claude_attention
    if flag and flag ~= '' and not tab.is_active then
      return {
        { Background = { Color = '#c0392b' } },
        { Foreground = { Color = '#ffffff' } },
        { Text = ' ' .. title .. ' ' },
      }
    end
  end
end)

config.audible_bell = 'Disabled'
config.status_update_interval = 500
config.window_decorations = 'RESIZE'

return config
