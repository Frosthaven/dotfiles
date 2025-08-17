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

wezterm.on("user-var-changed", function(window, pane, name, value)
    if name == "NEOVIM_EVENT" then
        -- this is coming from our Neovim's wezterm-bridge.lua
        -- value will be in the form of KEY=VALUE;KEY=VALUE;

        -- ensure the value ends in ; for our parser
        if not value:match(";$") then
            value = value .. ";"
        end

        -- parse the key value pairs into a shallow table
        local parsed = {}
        local couldParse = true
        for pair in value:gmatch("([^;]+);") do
            local key, val = pair:match("([^=]+)=([^=]+)")
            if key and val then
                parsed[key] = val
            else
                couldParse = false
            end
        end

        if not couldParse then
            wezterm.log_warn("Failed to parse NEOVIM_EVENT value: " .. value)
            return
        end

        -- ensure the value is a table
        if type(parsed) ~= "table" then
            wezterm.log_warn("Expected a table, got: " .. type(parsed))
            return
        end

        -- emit the event with the window, pane, name, and value
        wezterm.log_info("Emitting extra event: ", "NEOVIM", parsed)
        M.emit("NEOVIM", window, pane, parsed)
    end
end)

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
