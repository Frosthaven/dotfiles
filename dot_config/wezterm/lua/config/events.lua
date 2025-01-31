local wezterm = require("wezterm")
local event = require("lua/module/event")

local M = {}
local isPadded = false
local FocusedNeovimProcesses = {}

M.setup = function(config)
    wezterm.on("user-var-changed", function(window, pane, name, value)
        if name == "FOCUS" then
            -- the value is in the format 'status:pid'. lets get both
            -- first split the value into status and pid
            local status, pid = value:match("([^:]+):([^:]+)")
            if status == "on" then
                FocusedNeovimProcesses[tonumber(pid)] = true
            elseif status == "off" then
                FocusedNeovimProcesses[tonumber(pid)] = nil
            end
        end
        event.emit("pane-changed", window, pane)
    end)

    event.on("pane-changed", function(window, pane)
        wezterm.sleep_ms(200) -- time for panes to settle
        local overrides = window:get_config_overrides() or {}

        if next(FocusedNeovimProcesses) ~= nil then
            if isPadded then
                return
            end
            isPadded = true
            overrides.window_padding = {
                left = "0cell",
                right = "0cell",
                top = "0cell",
                bottom = "0cell",
            }
        else
            isPadded = false
            overrides.window_padding = {
                left = config.window_padding.left,
                right = config.window_padding.right,
                top = config.window_padding.top,
                bottom = config.window_padding.bottom,
            }
        end

        window:set_config_overrides(overrides)
    end)
    return config
end

return M
