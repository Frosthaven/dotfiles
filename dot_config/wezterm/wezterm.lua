local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
local platform_config = {
	set_environment_variables = {},
}

-- HELPER FUNCTIONS ************************************************************
-- *****************************************************************************

local function mergeTables(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				mergeTables(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

-- PLATFORM CONFIG *************************************************************
-- *****************************************************************************

config.font = wezterm.font("JetBrainsMono NF")

-- platform specifics
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- windows *****************************************************************
	-- framing
	local enableTransparency = true
	local defaultRendering = {
		webgpu_front_end = "WebGpu",
		window_background_opacity = 1,
		win32_system_backdrop = "Disable",
	}
	-- enable Vulkan OpenGL and transparency if available on a discrete gpu
	-- note: for nvidia, must set gdi rendering for wezterm to compatibility
	-- mode under "manage 3d settings -> per application -> wezterm.exe"
	if enableTransparency then
		local foundVulkan = false
		for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
			if gpu.backend == "Vulkan" and gpu.device_type == "DiscreteGpu" then
				foundVulkan = true
				platform_config.webgpu_preferred_adapter = gpu
				platform_config.front_end = "OpenGL"
				platform_config.window_background_opacity = 0.7
				platform_config.win32_system_backdrop = "Mica" -- Disable, Acrylic, Mica, Tabbed
				break
			end
		end
		if not foundVulkan then
			platform_config.front_end = defaultRendering.webgpu_front_end
			platform_config.window_background_opacity = defaultRendering.window_background_opacity
			platform_config.win32_system_backdrop = defaultRendering.win32_system_backdrop
		end
	else
		platform_config.front_end = defaultRendering.webgpu_front_end
		platform_config.window_background_opacity = defaultRendering.window_background_opacity
		platform_config.win32_system_backdrop = defaultRendering.win32_system_backdrop
	end

	platform_config.window_frame = {
		font_size = 10,
	}
	-- font
	platform_config.font_size = 10.5
	platform_config.line_height = 1.15
	-- misc
	platform_config.default_prog = { "C:/Program Files/Powershell/7/pwsh.exe", "-nologo", "-l" }
else
	-- mac & linux *************************************************************
	-- framing
	platform_config.front_end = "WebGPU"
	platform_config.window_frame = {
		font_size = 15,
	}
	-- font
	platform_config.font_size = 15
	platform_config.line_height = 1.15

	-- hide the titlebar but keep the window controls
	platform_config.window_decorations = "TITLE | RESIZE"
	-- also show the close button
	platform_config.window_close_confirmation = "NeverPrompt"
	platform_config.window_background_opacity = 0.95

	if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
		-- mac only ****************************************************
		platform_config.window_background_opacity = 0.88
		platform_config.macos_window_background_blur = 50
	end
end

-- FONT SETUP ******************************************************************
-- *****************************************************************************

config.bold_brightens_ansi_colors = true
config.freetype_render_target = "HorizontalLcd"
config.cell_width = 1

-- EVENTS **********************************************************************
-- *****************************************************************************

wezterm.on("user-var-changed", function(window, pane, name, value)
	if name == "PADDING" and value == "off" then
		local overrides = window:get_config_overrides() or {}
		overrides.window_padding = {
			left = "0cell",
			right = "0cell",
			top = "0cell",
			bottom = "0cell",
		}
		window:set_config_overrides(overrides)
	elseif name == "PADDING" and value == "on" then
		local overrides = window:get_config_overrides() or {}
		overrides.window_padding = {
			left = "4cell",
			right = "4cell",
			top = "1cell",
			bottom = "1cell",
		}
		window:set_config_overrides(overrides)
		overrides.window_padding = nil
	end
end)

-- KEYMAP **********************************************************************
-- *****************************************************************************

-- keymaps
config.keys = {
	-- { key = "w", mods = "CTRL", action = act.EmitEvent("trigger-padding-toggle") },
	-- { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
	{
		key = "t",
		mods = "SHIFT|ALT",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "w",
		mods = "SHIFT|ALT",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
}

-- THEMING *********************************************************************
-- *****************************************************************************

-- window framing
config.window_frame = {
	font = wezterm.font({ family = "JetBrainsMono NF", weight = "DemiBold" }),
	active_titlebar_bg = "#21252b",
	inactive_titlebar_bg = "#21252b",
}
config.window_padding = {
	left = "4cell", -- 4
	right = "4cell", --
	top = "1cell", -- 1
	bottom = "1cell", -- 1
}
--config.window_decorations = "RESIZE"

-- tab bar
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- theming
-- config.color_scheme = "OneHalfDark"
config.color_scheme = "Catppuccin Mocha"
-- overrides
config.color_schemes = {
	["OneHalfDarkCustom"] = {
		brights = {
			"#282c34",
			"#e06c75",
			"#98c379",
			"#e5c07b",
			"#61aff0",
			"#c678dd",
			"#56b6c2",
			"#dcdfe4",
		},
		ansi = {
			"#282c34",
			"#e06c75",
			"#98c379",
			"#e5c07b",
			"#61aff0",
			"#c678dd",
			"#56b6c2",
			"#dcdfe4",
		},
	},
}
config.colors = {
	brights = {
		"#3f3f5b",
		"#e06c75",
		"#98c379",
		"#e5c07b",
		"#61aff0",
		"#c678dd",
		"#56b6c2",
		"#dcdfe4",
	},
	ansi = {
		"#15151e",
		"#e06c75",
		"#98c379",
		"#e5c07b",
		"#61aff0",
		"#c678dd",
		"#56b6c2",
		"#aaadb1",
	},

	-- background = "#191724", --rose-pine moon
	background = "#1a1b26", --tokyonight storm
	-- background = "#282C34",
	-- foreground = '#ffffff',
	tab_bar = {
		background = "#21252b",
		active_tab = {
			bg_color = "#282c34",
			fg_color = "#ffffff",
		},
		inactive_tab = {
			bg_color = "#21252b",
			fg_color = "#767d88",
		},
		inactive_tab_hover = {
			bg_color = "#21252b",
			fg_color = "#767d88",
		},
		new_tab = {
			bg_color = "#21252b",
			fg_color = "#767d88",
		},
		new_tab_hover = {
			bg_color = "#21252b",
			fg_color = "#767d88",
		},
	},
}

return mergeTables(config, platform_config)
