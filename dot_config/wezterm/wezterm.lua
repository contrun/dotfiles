local wezterm = require 'wezterm'

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
  if wezterm.gui then return wezterm.gui.get_appearance() end
  return 'Light'
end

function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Builtin Solarized Dark'
  else
    return 'Builtin Solarized Light'
  end
end

local function strip_sshmux_prefix(domain_name)
  return domain_name:gsub('^SSH[MUX]*:', '')
end

wezterm.on('update-status', function(window)
  -- Grab the utf8 character for the "powerline" left facing
  -- solid arrow.
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Grab the current window's configuration, and from it the
  -- palette (this is the combination of your chosen colour scheme
  -- including any overrides).
  local color_scheme = window:effective_config().resolved_palette
  local bg = color_scheme.background
  local fg = color_scheme.foreground

  window:set_right_status(wezterm.format({
    -- First, we draw the arrow...
    { Background = { Color = 'none' } }, { Foreground = { Color = bg } },
    { Text = SOLID_LEFT_ARROW }, -- Then we draw our text
    { Background = { Color = bg } }, { Foreground = { Color = fg } },
    { Text = ' ' .. wezterm.hostname() .. ' ' }
  }))
end)

-- Show which key table is active in the status area
wezterm.on('update-right-status', function(window, pane)
  local name = window:active_key_table()
  if name then name = 'TABLE: ' .. name end
  window:set_right_status(name or '')
end)

wezterm.on('format-tab-title', function(tab)
  local pane = tab.active_pane
  local title = pane.title
  if pane.domain_name and pane.domain_name ~= 'local' then
    local domain_name = strip_sshmux_prefix(pane.domain_name)
    title = title .. ' - ' .. domain_name
  end
  return title
end)

local default_machine = 'dev'
local default_domain = 'SSHMUX:' .. default_machine

local config = {}

config.tls_clients = {}

config.ssh_domains = wezterm.default_ssh_domains()
for _, dom in ipairs(config.ssh_domains) do
  -- Default ssh domains are Posix, but we can override that later.
  dom.assume_shell = 'Posix'
  dom.local_echo_threshold_ms = 10

  -- Create a tls client for each ssh domain.
  -- The dom name here can start with SSH: or SSHMUX:
  -- We remove the prefix here.
  local server_name = strip_sshmux_prefix(dom.name)
  local tls_name = server_name .. '.tls'
  local tls_client_found = false
  for _, tls in ipairs(config.tls_clients) do
    if tls.name == tls_name then
      tls_client_found = true
      break
    end
  end

  -- If we have already set this name in the tls_config, then just skip
  -- the rest of the loop.
  if not tls_client_found then
    local conf = {
      name = tls_name,
      remote_address = dom.remote_address .. ":4443",
      bootstrap_via_ssh = server_name
    }
    wezterm.log_info('domain', dom)
    wezterm.log_info('config', conf)

    -- Insert the config to config.tls_clients
    config.tls_clients[#config.tls_clients + 1] = conf
  end
end

config.tls_servers = {
  {
    -- The host:port combination on which the server will listen
    -- for connections
    bind_address = '[::]:4443'
  }
}

config.color_scheme = scheme_for_appearance(get_appearance())

config.launch_menu = {
  {
    -- Optional label to show in the launcher. If omitted, a label
    -- is derived from the `args`
    label = 'wezterm cli spawn --domain-name ' .. default_domain,
    -- The argument array to spawn.  If omitted the default program
    -- will be used as described in the documentation above
    -- wezterm cli spawn --domain-name SSHMUX:my.server
    args = { 'wezterm', 'cli', 'spawn', '--domain-name', default_domain }

    -- You can specify an alternative current working directory;
    -- if you don't specify one then a default based on the OSC 7
    -- escape sequence will be used (see the Shell Integration
    -- docs), falling back to the home directory.
    -- cwd = "/some/path"

    -- You can override environment variables just for this command
    -- by setting this here.  It has the same semantics as the main
    -- set_environment_variables configuration option described above
    -- set_environment_variables = { FOO = "bar" },
  },
  {
    -- Optional label to show in the launcher. If omitted, a label
    -- is derived from the `args`
    label = 'wezterm connect ' .. default_domain,
    -- The argument array to spawn.  If omitted the default program
    -- will be used as described in the documentation above
    -- wezterm cli spawn --domain-name SSHMUX:my.server
    args = { 'wezterm', 'connect', default_domain }

    -- You can specify an alternative current working directory;
    -- if you don't specify one then a default based on the OSC 7
    -- escape sequence will be used (see the Shell Integration
    -- docs), falling back to the home directory.
    -- cwd = "/some/path"

    -- You can override environment variables just for this command
    -- by setting this here.  It has the same semantics as the main
    -- set_environment_variables configuration option described above
    -- set_environment_variables = { FOO = "bar" },
  }
}

-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = 'Space', mods = 'CTRL|SHIFT', timeout_milliseconds = 1000 }
config.keys = {
  {
    key = 'Space',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'Space',
    mods = 'LEADER|CTRL|SHIFT',
    action = wezterm.action.SendKey { key = 'Space', mods = 'CTRL|SHIFT' },
  },
  {
    key = '"',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '%',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'l',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'd',
    mods = 'LEADER|CTRL|SHIFT',
    action = wezterm.action.ShowDebugOverlay,
  },
  {
    key = 'l',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ShowLauncher,
  },
  {
    key = 's',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.QuickSelect,
  },
  {
    key = 'c',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.QuickSelect,
  },
  {
    key = 'o',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.QuickSelectArgs {
      label = 'open url',
      patterns = {
        'https?://\\S+',
      },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.log_info('opening: ' .. url)
        wezterm.open_with(url)
      end),
    },
  },

  -- CTRL+SHIFT+Space, followed by 'r' will put us in resize-pane
  -- mode until we cancel that mode.
  {
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
    },
  },

  -- CTRL+SHIFT+Space, followed by 'a' will put us in activate-pane
  -- mode until we press some other key or until 1 second (1000ms)
  -- of time elapses
  {
    key = 'a',
    mods = 'LEADER',
    action = wezterm.action.ActivateKeyTable {
      name = 'activate_pane',
      timeout_milliseconds = 1000,
    },
  },
}

config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  resize_pane = {
    { key = 'LeftArrow',  action = wezterm.action.AdjustPaneSize { 'Left', 1 } },
    { key = 'h',          action = wezterm.action.AdjustPaneSize { 'Left', 1 } },

    { key = 'RightArrow', action = wezterm.action.AdjustPaneSize { 'Right', 1 } },
    { key = 'l',          action = wezterm.action.AdjustPaneSize { 'Right', 1 } },

    { key = 'UpArrow',    action = wezterm.action.AdjustPaneSize { 'Up', 1 } },
    { key = 'k',          action = wezterm.action.AdjustPaneSize { 'Up', 1 } },

    { key = 'DownArrow',  action = wezterm.action.AdjustPaneSize { 'Down', 1 } },
    { key = 'j',          action = wezterm.action.AdjustPaneSize { 'Down', 1 } },

    -- Cancel the mode by pressing escape
    { key = 'Escape',     action = 'PopKeyTable' },
  },

  -- Defines the keys that are active in our activate-pane mode.
  -- 'activate_pane' here corresponds to the name="activate_pane" in
  -- the key assignments above.
  activate_pane = {
    { key = 'LeftArrow',  action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'h',          action = wezterm.action.ActivatePaneDirection 'Left' },

    { key = 'RightArrow', action = wezterm.action.ActivatePaneDirection 'Right' },
    { key = 'l',          action = wezterm.action.ActivatePaneDirection 'Right' },

    { key = 'UpArrow',    action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'k',          action = wezterm.action.ActivatePaneDirection 'Up' },

    { key = 'DownArrow',  action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'j',          action = wezterm.action.ActivatePaneDirection 'Down' },
  },
}

return config
