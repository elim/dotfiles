-- Note: Home Manager's wezterm module automatically prepends this require statement.
-- We include it here explicitly for better LSP and editor integration, despite the
-- redundancy. The duplication is harmless as the latter declaration takes precedence.
local wezterm = require("wezterm")
local mux = wezterm.mux

-- Fullscreen window on startup
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

-- Status bar with workspace, hostname, and datetime
-- Inspired by: https://alexplescan.com/posts/2024/08/10/wezterm/
wezterm.on("update-status", function(window)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local date = wezterm.strftime("%Y-%m-%d %H:%M")

  window:set_right_status(wezterm.format({
    -- Workspace (leftmost segment)
    { Foreground = { Color = "#808080" } },
    { Background = { Color = "#2E3440" } },
    { Text = " " .. window:active_workspace() .. " " },
    { Foreground = { Color = "#3B4252" } },
    { Text = SOLID_LEFT_ARROW },
    -- Date/Time (middle segment)
    { Foreground = { Color = "#D8DEE9" } },
    { Background = { Color = "#3B4252" } },
    { Text = " " .. date .. " " },
    { Foreground = { Color = "#434C5E" } },
    { Text = SOLID_LEFT_ARROW },
    -- Hostname (rightmost segment)
    { Foreground = { Color = "#ECEFF4" } },
    { Background = { Color = "#434C5E" } },
    { Text = " " .. wezterm.hostname() .. " " },
  }))
end)

-- Platform detection
local is_darwin = wezterm.target_triple:find("darwin") ~= nil

local config = {
  -- Use XWayland for better compatibility with GNOME/Mutter
  -- Native Wayland has rendering issues with status bar and window decorations
  -- (https://github.com/wez/wezterm/issues/6296)
  enable_wayland = false,

  -- Font configuration
  font = wezterm.font("HackGen Console NF"),
  font_size = 14.0,
  line_height = 1.2,

  -- Tab bar configuration
  use_fancy_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,

  -- Terminal behavior
  enable_kitty_keyboard = true,
  scrollback_lines = 10000,
  enable_scroll_bar = true,
  audible_bell = "Disabled",
  use_ime = true,

  -- Color scheme (Nord)
  colors = {
    foreground = "#D8DEE9",
    background = "#2E3440",
    cursor_bg = "#D8DEE9",
    cursor_fg = "#3B4252",
    cursor_border = "#D8DEE9",
    selection_bg = "#88C0D0",
    selection_fg = "#2E3440",
    ansi = {
      "#3B4252",
      "#BF616A",
      "#A3BE8C",
      "#EBCB8B",
      "#81A1C1",
      "#B48EAD",
      "#88C0D0",
      "#E5E9F0",
    },
    brights = {
      "#4C566A",
      "#BF616A",
      "#A3BE8C",
      "#EBCB8B",
      "#81A1C1",
      "#B48EAD",
      "#8FBCBB",
      "#ECEFF4",
    },
  },
}

-- Platform-specific appearance settings
if is_darwin then
  -- macOS: transparency with blur for better readability
  config.window_background_opacity = 0.85
  config.macos_window_background_blur = 20
  config.native_macos_fullscreen_mode = false
else
  -- Linux/Wayland: subtle transparency without blur
  config.window_background_opacity = 0.95
end

return config
