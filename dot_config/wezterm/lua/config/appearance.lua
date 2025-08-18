local wezterm = require("wezterm")
local helpers = require("lua/module/helpers")
local M = {}

M.setup = function(config)
    -- window framing
    config.window_frame = {
        active_titlebar_bg = "#11111D",
        inactive_titlebar_bg = "#11111D",
        font = wezterm.font({ family = "JetBrains Mono", weight = "Medium" }),
        font_size = 10.0,
    }

    config.integrated_title_button_color = "#7777AA"
    -- tab bar
    config.hide_tab_bar_if_only_one_tab = false
    config.use_fancy_tab_bar = true

    -- theming
    -- config.color_scheme = "OneHalfDark"
    config.color_scheme = "Catppuccin Mocha"
    -- overrides
    config.color_schemes = {
        ["OneHalfDarkCustom"] = {
            brights = {
                "#282c34",
                "#e06c75",
                "#98c379",
                "#e5c07b",
                "#61aff0",
                "#c678dd",
                "#56b6c2",
                "#dcdfe4",
            },
            ansi = {
                "#282c34",
                "#e06c75",
                "#98c379",
                "#e5c07b",
                "#61aff0",
                "#c678dd",
                "#56b6c2",
                "#dcdfe4",
            },
        },
    }
    config.colors = {
        brights = {
            "#3f3f5b",
            "#e06c75",
            "#98c379",
            "#e5c07b",
            "#61aff0",
            "#c678dd",
            "#56b6c2",
            "#dcdfe4",
        },
        ansi = {
            "#15151e",
            "#e06c75",
            "#98c379",
            "#e5c07b",
            "#61aff0",
            "#c678dd",
            "#56b6c2",
            "#aaadb1",
        },

        -- background = "#191724", --rose-pine moon
        -- background = "#1a1b26", --tokyonight storm
        -- background = "#282C34",
        -- foreground = '#ffffff',
        background = "#11111D",
        tab_bar = {
            background = "#21252b",
            inactive_tab_edge = "#11111D",
            active_tab = {
                bg_color = "#1F1F2F",
                fg_color = "#f8f8ff",
                intensity = "Half",
            },
            inactive_tab = {
                bg_color = "#11111D",
                fg_color = "#404063",
            },
            inactive_tab_hover = {
                bg_color = "#1F1F2F",
                fg_color = "#656588",
            },
            new_tab = {
                bg_color = "#11111D",
                fg_color = "#656588",
            },
            new_tab_hover = {
                bg_color = "#1F1F2F",
                fg_color = "#656588",
            },
        },
    }

    return config
end

return M
