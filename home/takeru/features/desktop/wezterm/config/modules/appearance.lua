-- Platform-specific appearance settings

local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
  local is_darwin = wezterm.target_triple:find("darwin") ~= nil

  if is_darwin then
    -- macOS: transparency with blur for better readability
    config.window_background_opacity = 0.85
    config.macos_window_background_blur = 20
    config.native_macos_fullscreen_mode = false
  else
    -- Linux/Wayland: subtle transparency without blur
    config.window_background_opacity = 0.95
  end
end

return module
