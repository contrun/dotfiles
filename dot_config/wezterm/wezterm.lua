local wezterm = require 'wezterm'
local default_box = 'madbox'
return {
  ssh_domains = {
    {
      name = 'box',
      remote_address = default_box,
      local_echo_threshold_ms = 10
    }
  },
  launch_menu = {
    {
      -- Optional label to show in the launcher. If omitted, a label
      -- is derived from the `args`
      label = 'wezterm connect ' .. default_box,
      -- The argument array to spawn.  If omitted the default program
      -- will be used as described in the documentation above
      args = { 'wezterm', 'connect', default_box }

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
}
