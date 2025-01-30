local wezterm = require("wezterm")
local helpers = require("lua/config/helpers")

local M = {}

M.setup = function()
    -- load priority: platform specific > common
    local opts = {
        linux = {},
        windows = {
            win32_system_backdrop = "Acrylic", -- Disable/Mica/Acrylic/Tabbed
            default_prog = { "C:/Program Files/Powershell/7/pwsh.exe", "-nologo", "-l" },
        },
        macos = {
            font_size = 15, -- compensation for display scaling
            macos_window_background_blur = 50, -- 0-100
        },
        common = {
            set_environment_variables = {},

            font = wezterm.font({ family = "JetBrainsMono NF", weight = "DemiBold" }),
            font_size = 10.5,
            line_height = 1.15,
            window_background_opacity = 0.85,

            window_decorations = "TITLE | RESIZE",
            window_close_confirmation = "NeverPrompt",

            webgpu_preferred_adapter = helpers.getIdealGPU(),
            bold_brightens_ansi_colors = true,
            freetype_load_target = "Normal", -- Normal/Light/Mono/HorizontalLcd
            freetype_render_target = "HorizontalLcd", -- Normal/Light/Mono/HorizontalLcd
            cell_width = 1,

            window_padding = {
                left = "4cell",
                right = "4cell",
                top = "1cell",
                bottom = "1cell",
            },
        },
    }

    -- combine common and platform specific options into a unified config
    local osTag = helpers.osTag()
    local platform_config = opts[osTag] or opts.common or {}
    local common = opts.common or {}
    local config = helpers.mergeTables(common, platform_config)

    -- attach ideal frontend
    config = helpers.attachIdealFrontend(config)

    return config
end

return M
