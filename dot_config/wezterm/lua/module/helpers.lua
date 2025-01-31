local wezterm = require("wezterm")
local M = {}

-- Deeply merge two tables
M.mergeTables = function(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                M.mergeTables(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

-- Uses triplet to detect if windows, mac, or linux
M.osTag = function()
    local triplet = wezterm.target_triple
    if triplet == "x86_64-pc-windows-msvc" then
        return "windows"
    elseif triplet == "x86_64-apple-darwin" or triplet == "aarch64-apple-darwin" then
        return "macos"
    else
        return "linux"
    end
end

-- Get the ideal GPU or nil
M.getIdealGPU = function()
    local idealGpu = nil
    for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
        if gpu.backend == "Vulkan" and gpu.device_type == "DiscreteGpu" then
            idealGpu = gpu
            break
        end
    end
    return idealGpu
end

-- Update a provided config with the most ideal frontend
M.attachIdealFrontend = function(config)
    local osTag = M.osTag()
    if osTag == "windows" then -- windows has issues with transparency + WebGpu
        if config.window_background_opacity == nil or config.window_background_opacity < 1 then
            return M.mergeTables(config, { front_end = "OpenGL" })
        else
            return M.mergeTables(config, { front_end = "WebGpu" })
        end
    else
        return M.mergeTables(config, { front_end = "WebGpu" })
    end
end
return M
