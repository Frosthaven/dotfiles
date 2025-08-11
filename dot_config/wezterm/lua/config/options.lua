local wezterm = require("wezterm")
local helpers = require("lua/module/helpers")

local M = {}

M.setup = function()
    -- load priority: platform specific > common
    local opts = {
        linux = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "Thin", scale = 1 }),
        },
        windows = {
            win32_system_backdrop = "Acrylic", -- Disable/Mica/Acrylic/Tabbed
            window_background_opacity = 0.85,
        },
        macos = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "DemiLight", scale = 1 }),
            font_size = 15, -- compensation for display scaling
            macos_window_background_blur = 50, -- 0-100
        },
        common = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "DemiBold", scale = 1 }),
            font_size = 10.5,
            line_height = 1.3,
            window_background_opacity = 0.94,

            window_decorations = "TITLE | RESIZE",
            window_close_confirmation = "NeverPrompt",

            webgpu_preferred_adapter = helpers.getIdealGPU(),
            bold_brightens_ansi_colors = true,
            freetype_load_target = "Normal", -- Normal/Light/Mono/HorizontalLcd
            freetype_render_target = "HorizontalLcd", -- Normal/Light/Mono/HorizontalLcd
            cell_width = 1.1,

            window_padding = {
                left = "2cell",
                right = "2cell",
                top = "0.5cell",
                bottom = "0.5cell",
            },

            set_environment_variables = {},
        },
    }

    if helpers.osTag() == "windows" then
        -- opts.windows.default_prog = { "C:/Program Files/Powershell/7/pwsh.exe", "-nologo", "-l" }
        opts.windows.default_prog = { os.getenv("LOCALAPPDATA") .. "/Programs/nu/bin/nu.exe" }
    elseif helpers.osTag() == "macos" then
        opts.macos.default_prog = { "/opt/homebrew/bin/nu" }
    end

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
