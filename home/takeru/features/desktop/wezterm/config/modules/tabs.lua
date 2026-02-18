-- Powerline-style tabs

local wezterm = require("wezterm")
local module = {}

-- Powerline separator
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

-- Nord colors for tabs
local COLORS = {
  active_bg = "#81A1C1", -- Nord 9 (blue)
  active_fg = "#2E3440", -- Nord 0 (dark)
  inactive_bg = "#3B4252", -- Nord 1
  inactive_fg = "#D8DEE9", -- Nord 4 (light)
  hover_bg = "#434C5E", -- Nord 2
  hover_fg = "#ECEFF4", -- Nord 6 (lighter)
  tab_bar_bg = "#2E3440", -- Nord 0 (background)
}

function module.setup()
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local background = COLORS.inactive_bg
    local foreground = COLORS.inactive_fg

    if tab.is_active then
      background = COLORS.active_bg
      foreground = COLORS.active_fg
    elseif hover then
      background = COLORS.hover_bg
      foreground = COLORS.hover_fg
    end

    local title = tab.active_pane.title

    -- Calculate available width for title
    -- Format: " N: TITLE " + separator
    local tab_index_str = tostring(tab.tab_index + 1)
    local reserved = #tab_index_str + 4 + 1 -- " N: " (4 chars) + separator (1 char)

    -- Guarantee minimum title width to accommodate repository names
    -- like "content_information_service" (27 chars)
    local min_title_width = 35
    local available = math.max(min_title_width, max_width - reserved)

    -- Limit title length to fit within available width
    -- Reserve 3 chars for "..." if truncation is needed
    if #title > available then
      if available > 3 then
        title = title:sub(1, available - 3) .. "..."
      else
        title = title:sub(1, available)
      end
    end

    local tab_title = " " .. tab_index_str .. ": " .. title .. " "

    -- Get the next tab's background color for the separator
    local next_tab_bg = COLORS.tab_bar_bg
    if tab.tab_index + 1 < #tabs then
      local next_tab = tabs[tab.tab_index + 2]
      if next_tab.is_active then
        next_tab_bg = COLORS.active_bg
      else
        next_tab_bg = COLORS.inactive_bg
      end
    end

    return {
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = tab_title },
      { Background = { Color = next_tab_bg } },
      { Foreground = { Color = background } },
      { Text = SOLID_RIGHT_ARROW },
    }
  end)
end

return module
