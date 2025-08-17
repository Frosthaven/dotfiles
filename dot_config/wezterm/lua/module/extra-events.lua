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

local function remove_invalid_entries(str)
    -- Initialize an empty table to store valid key-value pairs
    local valid_pairs = {}

    -- Iterate through each key-value pair in the string
    for key, value in string.gmatch(str, "([^=;]*)=([^;]*)") do
        -- Check if key is not empty and value is not empty (you can adjust conditions)
        if key ~= "" and value ~= "" then
            -- Rebuild the valid pair and store it in the table
            table.insert(valid_pairs, key .. "=" .. value)
        else
            -- Log a warning for invalid entries
            wezterm.log_warn("Invalid entry found: key='" .. key .. "', value='" .. value .. "'")
        end
    end

    -- Rebuild the string from the valid pairs, join with semicolons
    return table.concat(valid_pairs, ";") .. ";"
end

wezterm.on("user-var-changed", function(window, pane, name, value)
    if name == "NEOVIM_EVENT" then
        -- this is coming from our Neovim's wezterm-bridge.lua
        -- value will be in the form of KEY=VALUE;KEY=VALUE;

        -- the filename could have empty keys, so if it does lets parse them out
        -- this could show as key=;key2=value2;key=;key3=value3;
        value = remove_invalid_entries(value)

        wezterm.log_info("Received NEOVIM_EVENT: ", value)

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
