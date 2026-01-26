local wezterm = require("wezterm")
local helpers = require("lua/module/helpers")
local M = {}

M.setup = function(config)
    local osTag = helpers.osTag()
    if osTag == "macos" then
        config.keys = {
            {
                key = "t",
                mods = "CMD",
                action = wezterm.action.SpawnTab("CurrentPaneDomain"),
            },
            {
                key = "w",
                mods = "CMD",
                action = wezterm.action.CloseCurrentTab({ confirm = true }),
            },
            {
                key = "d",
                mods = "CMD|SHIFT",
                action = wezterm.action_callback(function(win, pane)
                    pane:move_to_new_window()
                end),
            },
        }
    else
        config.keys = {
            {
                key = "t",
                mods = "CTRL",
                action = wezterm.action.SpawnTab("CurrentPaneDomain"),
            },
            {
                key = "w",
                mods = "CTRL",
                action = wezterm.action.CloseCurrentTab({ confirm = true }),
            },
            {
                key = "d",
                mods = "CTRL|SHIFT",
                action = wezterm.action_callback(function(win, pane)
                    pane:move_to_new_window()
                end),
            },
        }
    end

    return config
end

return M
