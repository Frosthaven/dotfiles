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
        }
    end

    return config
end

return M
