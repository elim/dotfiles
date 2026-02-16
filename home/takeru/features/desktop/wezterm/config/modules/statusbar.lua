-- Status bar with workspace, hostname, and datetime
-- Inspired by: https://alexplescan.com/posts/2024/08/10/wezterm/

local wezterm = require("wezterm")
local module = {}

function module.setup()
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
end

return module
