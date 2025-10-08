local wezterm = require("wezterm")
local helpers = require("lua/module/helpers")

local M = {}

-- Early VM detection
local function running_in_vm()
    local uname = io.popen("systeminfo"):read("*a") or ""
    local vm_strings = { "VirtualBox", "VMware", "KVM", "QEMU", "Hyper-V" }
    for _, s in ipairs(vm_strings) do
        if uname:match(s) then
            return true
        end
    end
    return false
end

M.setup = function()
    local is_vm = running_in_vm()
    if is_vm then
        wezterm.log_warn("VM detected; forcing Software frontend")
    end

    -- Platform-specific defaults
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
            webgpu_preferred_adapter = helpers.getIdealGPU(),
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

    -- Merge platform-specific with common
    local osTag = helpers.osTag()
    local platform_config = opts[osTag] or {}
    local config = helpers.mergeTables(opts.common, platform_config)

    -- Default shell per platform
    if osTag == "windows" then
        config.default_prog = { "nu.exe" }
    else
        local home = os.getenv("HOME")
        config.default_prog = { home .. "/.cargo/bin/nu" }
        config.set_environment_variables = {
            PATH = home .. "/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        }
    end

    -- Attach ideal frontend if helper exists
    if helpers.attachIdealFrontend then
        config = helpers.attachIdealFrontend(config)
    end

    -- Frontend selection
    if is_vm then
        -- Safe fallback for VMs
        config.front_end = "Software"
    else
        -- Physical hardware: prefer OpenGL, try EGL if available
        config.front_end = "OpenGL"
        config.prefer_egl = true
    end

    -- Mouse bindings
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

    return config
end

return M
