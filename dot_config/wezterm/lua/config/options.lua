local wezterm = require("wezterm")
local helpers = require("lua/module/helpers")

local M = {}

M.setup = function()
    -- -------------------------
    -- Platform-specific options
    -- -------------------------
    local opts = {
        linux = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "Thin", scale = 1 }),
        },
        windows = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "DemiBold", scale = 1 }),
            win32_system_backdrop = "Acrylic",
            window_background_opacity = 0.88,
            default_prog = { "nu.exe" },
        },
        macos = {
            font = wezterm.font({ family = "JetBrainsMono NF", weight = "DemiLight", scale = 1 }),
            font_size = 15,
            macos_window_background_blur = 50,
            default_prog = { os.getenv("HOME") .. "/.cargo/bin/nu" },
            set_environment_variables = {
                PATH = os.getenv("HOME") .. "/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            },
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
    if osTag == "linux" then
        opts.linux.default_prog = { os.getenv("HOME") .. "/.cargo/bin/nu" }
        opts.set_environment_variables = {
            PATH = os.getenv("HOME") .. "/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        }
    end

    -- Merge common + platform-specific
    local config = helpers.mergeTables(opts.common, opts[osTag] or {})

    -- Attach ideal frontend (WebGPU/OpenGL/etc.)
    config = helpers.attachIdealFrontend(config)

    -- -------------------------
    -- Mouse selection copy behavior
    -- -------------------------
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

    -- -------------------------
    -- Detect VM on Windows
    -- -------------------------
    local function running_in_vm()
        if osTag ~= "windows" then
            return false
        end

        local ok, output = pcall(wezterm.run_child_process, {
            "powershell",
            "-NoProfile",
            "-Command",
            [[
            $keys = @(
                "HKLM:\HARDWARE\DESCRIPTION\System",
                "HKLM:\HARDWARE\DESCRIPTION\System\BIOS"
            )
            foreach ($key in $keys) {
                Get-ItemProperty $key | ForEach-Object {
                    $_.SystemManufacturer, $_.SystemProductName
                }
            }
            ]],
        })

        if not ok or not output then
            return false
        end

        -- make sure output is a string
        local text = type(output) == "table" and table.concat(output, " ") or tostring(output)
        text = text:lower()

        return text:match("vmware") or text:match("virtualbox") or text:match("hyper%-v") or text:match("qemu")
    end

    if running_in_vm() then
        wezterm.log_warn("VM detected; forcing software frontend")
        config.front_end = "Software"
    else
        config.front_end = "OpenGL"
    end

    return config
end

return M
