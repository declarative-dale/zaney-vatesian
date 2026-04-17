-- Host-local WezTerm override for xps-v.
-- Mirrors the repo's default WezTerm config, but adds right-click paste.

local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action

config.enable_wayland = false

-- General appearance and visuals
config.colors = {
  tab_bar = {
    background = "#00141d",

    active_tab = {
      bg_color = "#80bfff",
      fg_color = "#00141d",
    },

    inactive_tab = {
      bg_color = "#1a1a1a",
      fg_color = "#FFFFFF",
    },

    new_tab = {
      bg_color = "#1a1a1a",
      fg_color = "#4fc3f7",
    },
  },
}

config.window_background_opacity = 0.90
config.color_scheme = "nightfox"
config.font_size = 12
config.font = wezterm.font("FiraCode", { weight = "Regular", italic = false })

config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

config.use_fancy_tab_bar = true
config.window_frame = {
  font = wezterm.font({ family = "JetBrainsMono Nerd Font Mono", weight = "Regular" }),
}

config.default_cursor_style = "BlinkingUnderline"
config.cursor_blink_rate = 500
config.term = "xterm-256color"
config.max_fps = 144
config.animation_fps = 30

config.keys = {
  { key = "t", mods = "ALT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "ALT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
  { key = "n", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
  { key = "p", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },

  { key = "v", mods = "ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h", mods = "ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },

  { key = "LeftArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },
}

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("PrimarySelection"),
  },
}

return config
