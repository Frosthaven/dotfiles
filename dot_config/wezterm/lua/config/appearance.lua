local wezterm = require("wezterm")
local helpers = require("lua/module/helpers")
local M = {}

M.setup = function(config)
    -- window framing
    config.window_frame = {
        active_titlebar_bg = "#21252b",
        inactive_titlebar_bg = "#21252b",
    }

    --config.window_decorations = "RESIZE"

    -- tab bar
    config.hide_tab_bar_if_only_one_tab = true
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
        -- background = "#000000",
        tab_bar = {
            background = "#21252b",
            active_tab = {
                bg_color = "#282c34",
                fg_color = "#ffffff",
            },
            inactive_tab = {
                bg_color = "#21252b",
                fg_color = "#767d88",
            },
            inactive_tab_hover = {
                bg_color = "#21252b",
                fg_color = "#767d88",
            },
            new_tab = {
                bg_color = "#21252b",
                fg_color = "#767d88",
            },
            new_tab_hover = {
                bg_color = "#21252b",
                fg_color = "#767d88",
            },
        },
    }

    return config
end

return M
