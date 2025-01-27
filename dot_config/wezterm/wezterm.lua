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

-- platform specifics
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- windows *****************************************************************
	-- framing
	platform_config.window_frame = {
		font_size = 10,
	}
	platform_config.window_background_opacity = 1
	platform_config.win32_system_backdrop = "Mica" -- Disable, Acrylic, Mica, Tabbed
	-- font
	platform_config.font_size = 10
	platform_config.line_height = 1
	-- misc
	platform_config.default_prog = { "C:/Program Files/Powershell/7/pwsh.exe", "-nologo", "-l" }
else
	-- mac & linux *************************************************************
	-- framing
	platform_config.window_frame = {
		font_size = 12,
	}
	platform_config.window_background_opacity = 0.98
	-- font
	platform_config.font_size = 15
	platform_config.line_height = 1

	-- hide the titlebar but keep the window controls
	platform_config.window_decorations = "TITLE | RESIZE"
	-- also show the close button
	platform_config.window_close_confirmation = "NeverPrompt"
	platform_config.window_background_opacity = 0.98
end

-- FONT SETUP ******************************************************************
-- *****************************************************************************

config.font = wezterm.font("JetBrainsMono NF")
config.bold_brightens_ansi_colors = true
config.front_end = "WebGpu"
config.freetype_render_target = "HorizontalLcd"
config.cell_width = 0.9

-- EVENTS **********************************************************************
-- *****************************************************************************

wezterm.on("user-var-changed", function(window, pane, name, value)
	wezterm.log_info("var", name, value)
	if name == "PADDING" and value == "on" then
		local overrides = window:get_config_overrides() or {}
		if not overrides.window_padding then
			overrides.window_padding = {
				left = "0cell",
				right = "0cell",
				top = "0cell",
				bottom = "0cell",
			}
		else
			overrides.window_padding = nil
		end
		window:set_config_overrides(overrides)
	elseif name == "PADDING" and value ~= "on" then
		overrides.window_padding = nil
	end
end)

-- KEYMAP **********************************************************************
-- *****************************************************************************

-- keymaps
config.keys = {
	{ key = "w", mods = "CTRL", action = act.EmitEvent("trigger-padding-toggle") },
	-- { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
}

-- THEMING *********************************************************************
-- *****************************************************************************

-- window framing
config.window_frame = {
	font = wezterm.font({ family = "JetBrainsMono NF", weight = "Bold" }),
	active_titlebar_bg = "#21252b",
	inactive_titlebar_bg = "#21252b",
}
config.window_padding = {
	left = "4cell", -- 4
	right = "4cell", -- 4
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

	background = "#1a1b26",
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
