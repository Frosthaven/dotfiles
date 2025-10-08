local wezterm = require("wezterm")
local helpers = require("lua/module/helpers")

local M = {}

-- VM detection helper
local function running_in_vm()
    local os_tag = helpers.osTag()
    if os_tag == "windows" then
        local ok, result = pcall(
            wezterm.os_exec,
            'powershell -Command "Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer"'
        )
        if ok and result then
            if result:match("VMware") or result:match("VirtualBox") or result:match("QEMU") then
                return true
            end
        end
    elseif os_tag == "linux" then
        local paths = { "/sys/class/dmi/id/product_name", "/sys/class/dmi/id/sys_vendor" }
        for _, p in ipairs(paths) do
            local f = io.open(p, "r")
            if f then
                local content = f:read("*a")
                f:close()
                if content:match("VirtualBox") or content:match("VMware") or content:match("QEMU") then
                    return true
                end
            end
        end
    end
    return false
end

M.setup = function()
    -- load priority: platform specific > common
    local opts = {
        linux = { font = wezterm.font({ family = "JetBrainsMono NF", weight = "Thin", scale = 1 }) },
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
            window_padding = { left = "5cell", right = "2cell", top = "0.5cell", bottom = "0.5cell" },
            set_environment_variables = {},
        },
    }

    -- platform-specific default prog and PATH
    if helpers.osTag() == "windows" then
        opts.windows.default_prog = { "nu.exe" }
    elseif helpers.osTag() == "macos" then
        opts.macos.default_prog = { os.getenv("HOME") .. "/.cargo/bin/nu" }
        opts.set_environment_variables =
            { PATH = os.getenv("HOME") .. "/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" }
    elseif helpers.osTag() == "linux" then
        opts.linux.default_prog = { os.getenv("HOME") .. "/.cargo/bin/nu" }
        opts.set_environment_variables =
            { PATH = os.getenv("HOME") .. "/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" }
    end

    -- combine common and platform options
    local osTag = helpers.osTag()
    local platform_config = opts[osTag] or opts.common or {}
    local common = opts.common or {}
    local config = helpers.mergeTables(common, platform_config)

    -- attach ideal frontend (OpenGL/EGL detection)
    config = helpers.attachIdealFrontend(config)

    -- if VM detected, force EGL frontend
    if running_in_vm() then
        wezterm.log_info("VM detected; switching frontend to EGL")
        config.front_end = "EGL"
    end

    -- copy on select mouse bindings
    local function make_mouse_binding(dir, streak, button, mods, action)
        return { event = { [dir] = { streak = streak, button = button } }, mods = mods, action = action }
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
