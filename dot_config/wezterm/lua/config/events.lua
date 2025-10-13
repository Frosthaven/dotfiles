local wezterm = require("wezterm")
local extraEvents = require("lua/module/extra-events")

local M = {}
local isPadded = false
local FocusedNeovimProcesses = {}

local defaultTitle = "WezTerm - " .. wezterm.hostname()
local maxTitleLength = 30 -- maximum length of the tab title
local maxProjectLength = 7 -- maximum length of the project name
local maxFinalLength = maxTitleLength + 14 -- the extra 14 is for the padding and icon length usage

local extensionToIcon = {
    { icon = "" }, -- Default icon for unknown extensions
    -- common file types
    { extension = "bat", icon = "" }, -- Batch files
    { extension = "bash_profile", icon = "" },
    { extension = "bashrc", icon = "" },
    { extension = "c", icon = "" },
    { extension = "config", icon = "" },
    { extension = "cpp", icon = "" },
    { extension = "css", icon = "" },
    { extension = "dart", icon = "" },
    { extension = "env", icon = "" },
    { extension = "example", icon = "" },
    { extension = "fish", icon = "" },
    { extension = "gitconfig", icon = "" },
    { extension = "gitattributes", icon = "" },
    { extension = "gitignore", icon = "" },
    { extension = "go", icon = "" },
    { extension = "h", icon = "" },
    { extension = "html", icon = "" },
    { extension = "ini", icon = "" },
    { extension = "java", icon = "" },
    { extension = "js", icon = "" },
    { extension = "json", icon = "" },
    { extension = "kotlin", icon = "" },
    { extension = "lua", icon = "" },
    { extension = "md", icon = "" },
    { extension = "num", icon = "" },
    { extension = "perl", icon = "" },
    { extension = "php", icon = "" },
    { extension = "profile", icon = "" },
    { extension = "production", icon = "" },
    { extension = "ps1", icon = "" }, -- PowerShell
    { extension = "python", icon = "" },
    { extension = "rb", icon = "" },
    { extension = "rs", icon = "" }, -- Rust
    { extension = "scala", icon = "" },
    { extension = "sh", icon = "" },
    { extension = "scss", icon = "" },
    { extension = "swift", icon = "" },
    { extension = "test", icon = "" },
    { extension = "toml", icon = "" },
    { extension = "txt", icon = "" },
    { extension = "tsx", icon = "" },
    { extension = "twig", icon = "" },
    { extension = "ts", icon = "" },
    { extension = "vagrantfile", icon = "" },
    { extension = "vim", icon = "" },
    { extension = "vue", icon = "" },
    { extension = "xml", icon = "󰗀" },
    { extension = "yaml", icon = "" },
    { extension = "yml", icon = "" },
    { extension = "zprofile", icon = "" },
    { extension = "zsh", icon = "" },
    { extension = "zshrc", icon = "" },
    { extension = ".envrc", icon = "" },

    -- image types 󰋩
    { extension = "png", icon = "󰋩" },
    { extension = "jpg", icon = "󰋩" },
    { extension = "jpeg", icon = "󰋩" },
    { extension = "gif", icon = "󰋩" },
    { extension = "bmp", icon = "󰋩" },
    { extension = "svg", icon = "󰋩" },
    { extension = "webp", icon = "󰋩" },
    { extension = "tiff", icon = "󰋩" },
    { extension = "ico", icon = "󰋩" },

    -- video types 
    { extension = "mp4", icon = "" },
    { extension = "mkv", icon = "" },
    { extension = "mov", icon = "" },
    { extension = "avi", icon = "" },
    { extension = "wmv", icon = "" },
    { extension = "flv", icon = "" },
    { extension = "webm", icon = "" },
    { extension = "mpg", icon = "" },
    { extension = "mpeg", icon = "" },
    { extension = "3gp", icon = "" },
    { extension = "m4v", icon = "" },

    -- audio types 
    { extension = "mp3", icon = "" },
    { extension = "wav", icon = "" },
    { extension = "flac", icon = "" },
    { extension = "aac", icon = "" },
    { extension = "ogg", icon = "" },
    { extension = "m4a", icon = "" },
    { extension = "wma", icon = "" },
    { extension = "alac", icon = "" },
    { extension = "aiff", icon = "" },
    { extension = "opus", icon = "" },
}

M.setup = function(config)
    local function tab_title(tab)
        local title = tab.tab_title
        local formattedTitle
        -- if the tab title is explicitly set, take that
        if title and #title > 0 then
            formattedTitle = title
        else
            formattedTitle = tab.active_pane.title
        end

        -- if the formatted title is ~, replace it with the current user's name
        if formattedTitle == "~" then
            formattedTitle = defaultTitle
        end

        -- if the title is larger than maxFinalLength, only show the end of the title
        if #formattedTitle > maxFinalLength then
            local truncatedTitle = formattedTitle:sub(-maxFinalLength + 3)
            -- remove any leading spaces
            truncatedTitle = truncatedTitle:match("^%s*(.-)%s*$")
            formattedTitle = "..." .. truncatedTitle
        end
        -- ensure there is two spaces before and after the title
        -- replace existing spaces on either side if necessary no matter how few or many they are
        local trimmedTitle = formattedTitle:match("^%s*(.-)%s*$") -- trim leading and trailing spaces
        formattedTitle = "  " .. trimmedTitle .. "  "

        -- if there are spaces anywhere after ... remove them
        formattedTitle = formattedTitle:gsub("%.%.%.%s+", "...")
        return formattedTitle
    end

    wezterm.on("format-tab-title", function(tab)
        return tab_title(tab)
    end)

    local function getIconForExtension(ext, filename)
        -- First, check if filename has an extension
        if filename then
            local last_dot = filename:match(".*()%.") -- Find the position of the last dot
            if last_dot then
                -- Extract the part of the filename after the last dot (extension)
                local file_extension = filename:sub(last_dot + 1):lower()

                -- Check for exact matches for file extension, using the __default key as a fallback
                for _, entry in ipairs(extensionToIcon) do
                    if file_extension == entry.extension then
                        wezterm.log_info("Found icon for extension:", file_extension, "->", entry.icon)
                        return entry.icon
                    end
                end
                -- If no exact match is found, use the first index's icon
                return extensionToIcon[1].icon
            end
        end

        -- Handle the case when no exact extension match is found:
        -- Check the extension-to-icon list for a match
        if ext then
            for _, entry in ipairs(extensionToIcon) do
                if ext == entry.extension then
                    return entry.icon
                end
            end
        end

        -- Return the default icon if nothing matches
        return extensionToIcon[#extensionToIcon].icon
    end

    extraEvents.on("NEOVIM", function(window, pane, payload)
        wezterm.log_info("Handling NEOVIM event:", payload)

        -- if event is FocusGained or VimEnter then its the same as status on above
        if payload.name == "FocusGained" or payload.name == "VimEnter" then
            FocusedNeovimProcesses[tonumber(payload.pid)] = true
        elseif payload.name == "FocusLost" or payload.name == "VimLeavePre" then
            FocusedNeovimProcesses[tonumber(payload.pid)] = nil
        end

        if payload.name == "VimLeavePre" then
            -- set the title to the default title
            local tab = window:active_tab()
            if tab then
                tab:set_title("")
            end
        end

        local function prepareTabTitle(title, icon)
            local tab = window:active_tab()
            if tab then
                local title = tab.tab_title or ""
                if title ~= payload.filename then
                    -- truncate the title if it is too long
                    if #payload.filename > maxTitleLength then
                        local truncatedFilename = payload.filename:sub(-maxTitleLength + 3)
                        -- remove any leading spaces
                        truncatedFilename = truncatedFilename:match("^%s*(.-)%s*$")
                        payload.filename = "..." .. truncatedFilename
                    end
                    if payload.pwd then
                        -- truncate the project name if it is too long
                        local projectName = payload.pwd
                        -- get the last part of the path if there are slashes
                        -- on windows
                        if projectName:find("/") then
                            projectName = projectName:match("^.+/(.+)$")
                        elseif projectName:find("\\") then
                            projectName = projectName:match("^.+\\(.+)$")
                        end
                        wezterm.log_info("Project name:", projectName)
                        if #projectName > maxProjectLength then
                            -- projectName = projectName:sub(-maxProjectLength + 3)
                            -- instead of removing from the start, remove it from the end
                            projectName = projectName:sub(1, maxProjectLength)
                        end
                        payload.filename = projectName .. " " .. payload.filename
                        wezterm.log_info("filename is now:", payload.filename)
                    else
                        icon = icon .. " "
                    end

                    if tab then
                        return (icon .. "  " .. payload.filename)
                    end
                end
            end
        end

        -- update the tab title
        if payload.title and payload.title ~= "" then
            local tab = window:active_tab()
            if tab then
                tab:set_title(payload.title)
                wezterm.log_info("Forcing tab title to:", payload.title)
            end
        elseif payload.filename and payload.filename ~= "" then
            -- Extract the extension
            local ext = payload.filename:match("^.+(%..+)$")
            ext = ext and ext:sub(2) or nil
            ext = ext and ext:lower() or nil
            local icon = getIconForExtension(ext, payload.filename)
            if ext then
                -- if the filename has an extension, then we can set the tab title
                local title = prepareTabTitle(icon .. " " .. payload.filename, icon)
                local tab = window:active_tab()
                if tab then
                    tab:set_title(title)
                    wezterm.log_info("Updated tab title to:", title)
                end
            else
                -- we still need to set the tab title
                local icon = extensionToIcon[1].icon
                local title = prepareTabTitle(icon .. " " .. payload.filename .. " ", icon)
                local tab = window:active_tab()
                if tab then
                    tab:set_title(title)
                    wezterm.log_info("Updated tab title to:", title)
                end
            end
        elseif payload.pwd then
            wezterm.log_error("No filename provided, but pwd is:", payload.pwd)
        else
            wezterm.log_error("No filename or pwd provided")
        end

        -- if wezterm is focused, update the window padding
        if not window:is_focused() then
            return
        end
        extraEvents.emit("pane-changed", window, pane)
    end)

    extraEvents.on("pane-changed", function(window, pane)
        local overrides = window:get_config_overrides() or {}

        if next(FocusedNeovimProcesses) ~= nil then
            if isPadded then
                return
            end
            isPadded = true
            overrides.window_padding = {
                left = "0cell",
                right = "0cell",
                top = "0cell",
                bottom = "0cell",
            }
        else
            isPadded = false
            overrides.window_padding = {
                left = config.window_padding.left,
                right = config.window_padding.right,
                top = config.window_padding.top,
                bottom = config.window_padding.bottom,
            }
        end

        window:set_config_overrides(overrides)
    end)

    return config
end

return M
