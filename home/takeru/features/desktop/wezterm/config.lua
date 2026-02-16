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

-- Platform detection
local is_darwin = wezterm.target_triple:find("darwin") ~= nil

local config = {
  -- Enable native Wayland for better IME support
  -- Note: GNOME/Mutter has window decoration issues (wez/wezterm#6296)
  -- but fullscreen mode works fine and provides proper IME input
  enable_wayland = true,

  -- Font configuration
  font = wezterm.font("HackGen Console NF"),
  font_size = 14.0,
  line_height = 1.2,

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
