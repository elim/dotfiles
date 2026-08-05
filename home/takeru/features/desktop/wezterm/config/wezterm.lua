-- Note: Home Manager's wezterm module automatically prepends this require statement.
-- We include it here explicitly for better LSP and editor integration, despite the
-- redundancy. The duplication is harmless as the latter declaration takes precedence.
local wezterm = require("wezterm")
local mux = wezterm.mux

-- Load modules
local appearance = require("modules.appearance")
local statusbar = require("modules.statusbar")
local tabs = require("modules.tabs")

-- Fill the window on startup
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()

  if wezterm.target_triple:find("darwin") then
    gui_window:maximize()
  else
    gui_window:toggle_fullscreen()
  end
end)

-- Setup event handlers
statusbar.setup()
tabs.setup()

local config = {
  -- Use XWayland for better compatibility with GNOME/Mutter
  -- Native Wayland has rendering issues with status bar and window decorations
  -- (https://github.com/wez/wezterm/issues/6296)
  enable_wayland = false,

  -- Font configuration
  font = wezterm.font("HackGen Console NF"),
  font_size = 12.0,
  line_height = 1.2,

  -- Color scheme
  color_scheme = "nord",

  -- Window padding (bottom set to 0 for tmux status bar)
  -- window_padding = {
  --   left = 2,
  --   right = 2,
  --   top = 2,
  --   bottom = 0,
  -- },

  -- Tab bar configuration
  use_fancy_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,
  tab_max_width = 50,

  -- Terminal behavior
  enable_kitty_keyboard = true,
  scrollback_lines = 10000,
  enable_scroll_bar = true,
  audible_bell = "Disabled",
  use_ime = true,

  -- Preserve WezTerm environment variables in spawned processes
  -- This ensures that `wezterm cli` commands work from within tmux sessions
  set_environment_variables = {},
}

-- Apply modular configurations
appearance.apply_to_config(config)

-- macOS specific configuration
if wezterm.target_triple:find("darwin") then
  -- Forward Ctrl and Shift key combinations to IME for macSKK (e.g., C-j mode switching)
  config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"

  -- Cmd+g sends M-g (Alt+g) to tmux, which converts it to C-g for the agent.
  -- On NixOS, xremap's wezterm.nix already preserves Alt+g (= "Cmd+g" feel) through to tmux.
  config.keys = {
    {
      key = "g",
      mods = "CMD",
      action = wezterm.action.SendKey { key = "g", mods = "ALT" },
    },
  }
end

return config
