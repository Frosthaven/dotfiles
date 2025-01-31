local wezterm = require("wezterm")

local M = {}
local stack = {}

wezterm.GLOBAL._event_data = wezterm.GLOBAL._event_data or {}
wezterm.GLOBAL._event_data.window_id = wezterm.GLOBAL._event_data.window_id or 0
wezterm.GLOBAL._event_data.pane_id = wezterm.GLOBAL._event_data.pane_id or 0

M.on = function(event, callback)
    stack[event] = stack[event] or {}
    table.insert(stack[event], callback)
end

M.emit = function(event, ...)
    if stack[event] then
        for _, callback in ipairs(stack[event]) do
            callback(...)
        end
    end
end

-- wezterm.on("user-var-changed", function(window, pane, name, value)
--     if name == "NVIM_EVENT" then
--         wezterm.log_info(value.name)
--         M.emit("NVIM", window, pane, value.name, value)
--     end
-- end)

wezterm.on("update-status", function(window, pane)
    local active_window_id = window:window_id()
    local active_pane_id = pane:pane_id()
    if active_window_id ~= wezterm.GLOBAL._event_data.window_id then
        wezterm.GLOBAL._event_data.window_id = active_window_id
        M.emit("window-changed", window)
    elseif active_pane_id ~= wezterm.GLOBAL._event_data.pane_id then
        wezterm.GLOBAL._event_data.pane_id = active_pane_id
        M.emit("pane-changed", window, pane)
    end

    wezterm.GLOBAL._event_data.window_id = active_window_id
    wezterm.GLOBAL._event_data.pane_id = active_pane_id
end)

return M
