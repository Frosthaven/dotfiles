local wezterm = require("wezterm")
local extraEvents = require("lua/module/extra-events")

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
            -- if wezterm is focused, then we can trigger manually trigger the
            -- event, which will update the padding. If weztern is not focused,
            -- we want to prevent this from firing, as it will cause padding shifts
            -- when users click away from the wezterm window
            if not window:is_focused() then
                return
            end
            extraEvents.emit("pane-changed", window, pane)
        end
    end)

    extraEvents.on("pane-changed", function(window, pane)
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

        -- window:set_config_overrides(overrides)
    end)
    return config
end

return M
