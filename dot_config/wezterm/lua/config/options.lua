local wezterm = require("wezterm")
local helpers = require("lua/module/helpers")

local M = {}

M.setup = function()
    -- Load priority: platform specific > common
    local opts = {
        linux = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "Thin", scale = 1 }),
        },
        windows = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "DemiBold", scale = 1 }),
            win32_system_backdrop = "Acrylic",
            window_background_opacity = 0.88,
        },
        macos = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "DemiLight", scale = 1 }),
            font_size = 15,
            macos_window_background_blur = 50,
        },
        common = {
            font_size = 10.5,
            line_height = 1.3,
            window_background_opacity = 0.94,
            window_decorations = "INTEGRATED_BUTTONS | RESIZE",
            window_close_confirmation = "NeverPrompt",
            bold_brightens_ansi_colors = true,
            freetype_load_target = "Normal",
            freetype_render_target = "HorizontalLcd",
            cell_width = 1.1,
            window_padding = {
                left = "5cell",
                right = "2cell",
                top = "0.5cell",
                bottom = "0.5cell",
            },
            set_environment_variables = {},
        },
    }

    local osTag = helpers.osTag()
    if osTag == "windows" then
        opts.windows.default_prog = { "nu.exe" }
    elseif osTag == "macos" then
        opts.macos.default_prog = { os.getenv("HOME") .. "/.cargo/bin/nu" }
        opts.set_environment_variables = {
            PATH = os.getenv("HOME") .. "/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        }
    elseif osTag == "linux" then
        opts.linux.default_prog = { os.getenv("HOME") .. "/.cargo/bin/nu" }
        opts.set_environment_variables = {
            PATH = os.getenv("HOME") .. "/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        }
    end

    -- Combine common and platform-specific options
    local platform_config = opts[osTag] or {}
    local config = helpers.mergeTables(opts.common, platform_config)

    -- Attach ideal frontend if needed
    config = helpers.attachIdealFrontend(config)

    -- Mouse selection copy behavior
    local function make_mouse_binding(dir, streak, button, mods, action)
        return {
            event = { [dir] = { streak = streak, button = button } },
            mods = mods,
            action = action,
        }
    end

    config.mouse_bindings = {
        make_mouse_binding(
            "Up",
            1,
            "Left",
            "NONE",
            wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection")
        ),
        make_mouse_binding(
            "Up",
            1,
            "Left",
            "SHIFT",
            wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection")
        ),
        make_mouse_binding("Up", 1, "Left", "ALT", wezterm.action.CompleteSelection("ClipboardAndPrimarySelection")),
        make_mouse_binding(
            "Up",
            1,
            "Left",
            "SHIFT|ALT",
            wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection")
        ),
        make_mouse_binding("Up", 2, "Left", "NONE", wezterm.action.CompleteSelection("ClipboardAndPrimarySelection")),
        make_mouse_binding("Up", 3, "Left", "NONE", wezterm.action.CompleteSelection("ClipboardAndPrimarySelection")),
    }

    -- ----------------------------------------
    -- Detect VM and fallback frontend
    -- ----------------------------------------
    local function running_in_vm()
        local sysinfo = wezterm.run_child_process({ "wmic", "computersystem", "get", "model" })
        local output = table.concat(sysinfo, "")
        output = output:lower()
        return output:find("virtual") or output:find("qemu") or output:find("vmware") or output:find("hyper-v")
    end

    if running_in_vm() then
        wezterm.log_warn("VM detected; forcing software frontend")
        config.front_end = "Software"
    else
        -- default to OpenGL, fallback to Software if initialization fails
        config.front_end = "OpenGL"
    end

    return config
end

return M
