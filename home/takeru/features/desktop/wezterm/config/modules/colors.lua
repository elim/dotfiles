-- Nord color scheme

local module = {}

function module.apply_to_config(config)
  config.colors = {
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
  }
end

return module
