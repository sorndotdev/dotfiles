-- Save the open tabs to disk and bring them back the next time WezTerm starts.
-- Runs inside the GUI process, which owns the panes: quitting WezTerm ends
-- what runs in them.
--
-- Each pane comes back in its directory and split layout. Claude Code resumes
-- its session (the `claude_session` user var, set by claude-session.sh), nvim
-- reopens its files; anything else comes back as a shell.
-- Start afresh: rm ~/.local/state/wezterm/session.json
local wezterm = require('wezterm')
local mux = wezterm.mux

local M = {}

local STATE_DIR = wezterm.home_dir .. '/.local/state/wezterm'
local STATE_FILE = STATE_DIR .. '/session.json'
local SAVE_INTERVAL = 1
-- A pane keeps its command this long after the program is gone, so a session
-- a shutdown killed just before WezTerm quit still comes back.
local EXIT_GRACE = 15
-- How long a restored pane counts as running its command before it starts.
local RESTORE_GRACE = 60

-- Flags carried over on resume, mapped to whether they take a value. The rest
-- of the command line (prompts, session ids) is dropped.
local KEEP_FLAGS = {
  claude = {
    ['--dangerously-skip-permissions'] = false,
    ['--model'] = true,
    ['--permission-mode'] = true,
    ['--agent'] = true,
  },
}

local G = wezterm.GLOBAL
G.session_recent = G.session_recent or {}

local function kept_flags(program, argv)
  local keep, out = KEEP_FLAGS[program], {}
  local i = 2
  while i <= #argv do
    local takes_value = keep[argv[i]]
    if takes_value ~= nil then
      table.insert(out, argv[i])
      if takes_value and argv[i + 1] then
        table.insert(out, argv[i + 1])
        i = i + 1
      end
    end
    i = i + 1
  end
  return out
end

local function command(program, flags, ...)
  local cmd = { program }
  for _, f in ipairs(flags) do
    table.insert(cmd, f)
  end
  for _, a in ipairs({ ... }) do
    table.insert(cmd, a)
  end
  return cmd
end

-- The command that brings this pane back, or nil for a plain shell.
local function pane_command(pane)
  local id = tostring(pane:pane_id())
  local proc = pane:get_foreground_process_info()
  local program = proc and proc.argv[1] and proc.argv[1]:match('[^/]+$')
  local cmd
  if program == 'claude' then
    local session = pane:get_user_vars().claude_session
    if session and session ~= '' then
      cmd = command('claude', kept_flags('claude', proc.argv), '--resume', session)
    end
  elseif program == 'nvim' then
    cmd = proc.argv
  end
  if cmd then
    G.session_recent[id] = { cmd = cmd, expires = os.time() + EXIT_GRACE }
    return cmd
  end
  local recent = G.session_recent[id]
  if recent and os.time() < recent.expires then
    return recent.cmd
  end
  G.session_recent[id] = nil
end

local function cwd_of(pane)
  local cwd = pane:get_current_working_dir()
  if type(cwd) == 'userdata' then
    return cwd.file_path
  end
  return cwd and cwd:gsub('^file://[^/]*', '')
end

local function snapshot()
  local windows, count = {}, 0
  for _, win in ipairs(mux.all_windows()) do
    local active_tab = win:active_tab()
    local tabs = {}
    for _, tab in ipairs(win:tabs()) do
      local panes = {}
      for _, info in ipairs(tab:panes_with_info()) do
        count = count + 1
        table.insert(panes, {
          cwd = cwd_of(info.pane),
          cmd = pane_command(info.pane),
          left = info.left,
          top = info.top,
          width = info.width,
          height = info.height,
          active = info.is_active,
        })
      end
      table.insert(tabs, {
        title = tab:get_title(),
        active = active_tab and active_tab:tab_id() == tab:tab_id(),
        panes = panes,
      })
    end
    table.insert(windows, { workspace = win:get_workspace(), tabs = tabs })
  end
  return windows, count
end

local function save()
  local windows, count = snapshot()
  -- Never save an empty session: that is the last window closing on quit.
  if count == 0 then
    return
  end
  local json = wezterm.json_encode({ windows = windows })
  if json == G.session_saved then
    return
  end
  local tmp = STATE_FILE .. '.tmp'
  local f = io.open(tmp, 'w')
  if not f then
    return
  end
  f:write(json)
  f:close()
  os.rename(tmp, STATE_FILE)
  G.session_saved = json
end

local function top_left(panes)
  local best = panes[1]
  for _, p in ipairs(panes) do
    if p.top < best.top or (p.top == best.top and p.left < best.left) then
      best = p
    end
  end
  return best
end

-- Find a line along `axis` that no pane straddles, and split the panes there.
local function find_cut(panes, pos, size)
  local lo, hi = math.huge, 0
  for _, p in ipairs(panes) do
    lo, hi = math.min(lo, p[pos]), math.max(hi, p[pos] + p[size])
  end
  for _, c in ipairs(panes) do
    local cut, before, after = c[pos], {}, {}
    if cut > lo then
      for _, p in ipairs(panes) do
        if p[pos] + p[size] <= cut then
          table.insert(before, p)
        elseif p[pos] >= cut then
          table.insert(after, p)
        else
          before = nil
          break
        end
      end
      if before then
        return before, after, (hi - cut) / (hi - lo)
      end
    end
  end
end

-- Rebuild a tab's split layout inside `pane`, recording each new pane's
-- saved state in `placed`.
local function build(pane, panes, placed)
  for _, axis in ipairs({ { 'left', 'width', 'Right' }, { 'top', 'height', 'Bottom' } }) do
    local before, after, fraction = find_cut(panes, axis[1], axis[2])
    if before then
      local new = pane:split({ direction = axis[3], size = fraction, cwd = top_left(after).cwd })
      build(pane, before, placed)
      build(new, after, placed)
      return
    end
  end
  table.insert(placed, { pane = pane, saved = top_left(panes) })
end

local function start(pane, saved)
  if saved.active then
    pane:activate()
  end
  if saved.cmd then
    G.session_recent[tostring(pane:pane_id())] = { cmd = saved.cmd, expires = os.time() + RESTORE_GRACE }
    pane:send_text(wezterm.shell_join_args(saved.cmd) .. '\n')
  end
end

local function restore()
  local f = io.open(STATE_FILE)
  if not f then
    return
  end
  local ok, state = pcall(wezterm.json_parse, f:read('*a'))
  f:close()
  if not ok or type(state) ~= 'table' or not state.windows then
    return
  end
  for _, w in ipairs(state.windows) do
    local window, active
    for _, t in ipairs(w.tabs) do
      local tab, pane
      local cwd = top_left(t.panes).cwd
      if window then
        tab, pane = window:spawn_tab({ cwd = cwd })
      else
        tab, pane, window = mux.spawn_window({ workspace = w.workspace, cwd = cwd })
      end
      if t.title and t.title ~= '' then
        tab:set_title(t.title)
      end
      local placed = {}
      build(pane, t.panes, placed)
      for _, p in ipairs(placed) do
        start(p.pane, p.saved)
      end
      if t.active then
        active = tab
      end
    end
    if active then
      active:activate()
    end
  end
end

local function tick()
  local ok, err = pcall(save)
  if not ok then
    wezterm.log_error('session: ' .. tostring(err))
  end
  wezterm.time.call_after(SAVE_INTERVAL, tick)
end

function M.apply_to_config(_)
  wezterm.on('gui-startup', function()
    wezterm.run_child_process({ 'mkdir', '-p', STATE_DIR })
    local ok, err = pcall(restore)
    if not ok then
      wezterm.log_error('session: restore failed: ' .. tostring(err))
    end
    wezterm.time.call_after(SAVE_INTERVAL, tick)
  end)
end

return M
