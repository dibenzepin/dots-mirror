-- Import the wezterm module
local wezterm = require 'wezterm'
-- Creates a config object which we will be adding our config to
local config = wezterm.config_builder()

-- wayland has wonky decoratons:  https://github.com/wez/wezterm/issues/5349
config.enable_wayland = false 

config.color_scheme = "Catppuccin Mocha"
config.tab_bar_at_bottom = true
config.font = wezterm.font 'FiraCode Nerd Font'
-- config.font_size = 13
-- config.window_background_opacity = 0

config.window_frame = {
  font = wezterm.font 'FiraCode Nerd Font',
}

config.window_padding = {
  bottom = 0
}

config.keys = {
  -- ALT → jumps right a word
  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = wezterm.action.SendString '\x1bb',
  },

  -- ALT ← jumps left a word
  {
    key = 'RightArrow',
    mods = 'ALT',
    action = wezterm.action.SendString '\x1bf',
  },

  -- CTRL , opens prefs
  {
    key = ',',
    mods = 'CTRL',
    action = wezterm.action.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      args = { 'hx', wezterm.config_file }
    }
  },

  -- CTRL SHIFT → moves right a tab
  {
    key = 'RightArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTabRelative(1)
  },
  
  -- CTRL SHIFT ← moves left a tab
  {
    key = 'LeftArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTabRelative(-1)
  }
}

-- Returns our config to be evaluated. We must always do this at the bottom of this file
return config

