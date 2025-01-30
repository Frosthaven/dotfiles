local wezterm = require("wezterm")
local helpers = require("lua/config/helpers")
local M = {}

M.setup = function(config)
    config.keys = {
        -- { key = "w", mods = "CTRL", action = act.EmitEvent("trigger-padding-toggle") },
        -- { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
        {
            key = "t",
            mods = "SHIFT|ALT",
            action = wezterm.action.SpawnTab("CurrentPaneDomain"),
        },
        {
            key = "w",
            mods = "SHIFT|ALT",
            action = wezterm.action.CloseCurrentTab({ confirm = true }),
        },
        {
            key = "w",
            mods = "CMD",
            action = wezterm.action.CloseCurrentTab({ confirm = true }),
        },
    }

    return config
end

return M
