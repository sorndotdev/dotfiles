local wezterm = require('wezterm')

local config = wezterm.config_builder()

-- Save the open tabs to disk and restore them the next time WezTerm starts.
require('session').apply_to_config(config)

local theme = wezterm.plugin.require('https://github.com/sorndotdev/wezterm-parchment-theme')
theme.apply_to_config(config)

config.keys = {
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[13;2u') },
  { key = 'LeftArrow', mods = 'OPT', action = wezterm.action.SendString('\x1b[1;3D') },
  { key = 'RightArrow', mods = 'OPT', action = wezterm.action.SendString('\x1b[1;3C') },
  { key = 'LeftArrow', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[1;2D') },
  { key = 'RightArrow', mods = 'SHIFT', action = wezterm.action.SendString('\x1b[1;2C') },
}

-- Cmd-[ / Cmd-] reach nvim as <D-[> / <D-]> (CSI-u, Super = 9), where they
-- jump back / forward. Other programs would print the sequence, so they get
-- nothing. nvim flags its pane with the `in_nvim` user var.
local function nvim_key(sequence)
  return wezterm.action_callback(function(window, pane)
    if pane:get_user_vars().in_nvim == '1' then
      window:perform_action(wezterm.action.SendString(sequence), pane)
    end
  end)
end
table.insert(config.keys, { key = '[', mods = 'CMD', action = nvim_key('\x1b[91;9u') })
table.insert(config.keys, { key = ']', mods = 'CMD', action = nvim_key('\x1b[93;9u') })

-- Claude Code attention: a hook sets the `claude_attention` user
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

-- Each flag value is unique, so mark it seen once its tab is in view. The
-- flag itself can't be cleared from here: inject_output does nothing on
-- panes owned by the mux server.
wezterm.GLOBAL.claude_seen = wezterm.GLOBAL.claude_seen or {}

local function needs_attention(pane_id, flag)
  return flag and flag ~= '' and wezterm.GLOBAL.claude_seen[tostring(pane_id)] ~= flag
end

wezterm.on('update-status', function(window)
  if not window:is_focused() then
    return
  end
  for _, p in ipairs(window:active_tab():panes()) do
    local flag = p:get_user_vars().claude_attention
    if needs_attention(p:pane_id(), flag) then
      wezterm.GLOBAL.claude_seen[tostring(p:pane_id())] = flag
    end
  end
end)

wezterm.on('format-tab-title', function(tab)
  local title = tab.tab_title ~= '' and tab.tab_title or tab.active_pane.title
  for _, p in ipairs(tab.panes) do
    if needs_attention(p.pane_id, p.user_vars.claude_attention) and not tab.is_active then
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
