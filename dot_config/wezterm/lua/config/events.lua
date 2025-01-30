local wezterm = require("wezterm")
local helpers = require("lua/config/helpers")
local M = {}

M.setup = function(config)
    wezterm.on("user-var-changed", function(window, pane, name, value)
        local overrides = window:get_config_overrides() or {}
        if
            name == "PADDING"
            and config.window_padding ~= nil
            and config.window_padding.left ~= nil
            and config.window_padding.right ~= nil
            and config.window_padding.top ~= nil
        then
            if value == "off" then
                overrides.window_padding = {
                    left = "0cell",
                    right = "0cell",
                    top = "0cell",
                    bottom = "0cell",
                }
            elseif value == "on" then
                overrides.window_padding = {
                    left = config.window_padding.left,
                    right = config.window_padding.right,
                    top = config.window_padding.top,
                    bottom = config.window_padding.bottom,
                }
            end
            window:set_config_overrides(overrides)
        end
    end)

    return config
end

return M
