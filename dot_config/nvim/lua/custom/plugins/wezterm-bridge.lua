return {
    {
        'willothy/wezterm.nvim',
        opts = {
            --create_commands = false
        },
        config = function()
            local wezterm = require 'wezterm'

            -- this function handles sending strings of KEY=VALUE;KEY=VALUE;
            function DispatchWezTermEvent(object)
                local stringified = ''
                for key, value in pairs(object) do
                    if stringified ~= '' then
                        stringified = stringified .. ';'
                    end
                    stringified = stringified .. key .. '=' .. tostring(value)
                end
                wezterm.set_user_var('NEOVIM_EVENT', stringified)
            end

            -- send focus events for padding reduction (only active in neovim)
            vim.cmd [[
                augroup FocusChangeGroup
                  au!

                  au FocusGained * lua DispatchWezTermEvent({name = 'FocusGained', pid = vim.fn.getpid()})
                  au FocusLost * lua DispatchWezTermEvent({name = 'FocusLost', pid = vim.fn.getpid()})
                  au VimEnter * lua DispatchWezTermEvent({name = 'VimEnter', pid = vim.fn.getpid()})
                  au VimLeavePre * lua DispatchWezTermEvent({name = 'VimLeavePre', pid = vim.fn.getpid()})
                augroup END
            ]]

            -- notify wezterm when we enter a file buffer of the filename
            -- get current folder from vim.fn.getcwd() - everything afte the last / (if any)
            function GetCurrentFolder()
                local currentPath = vim.fn.getcwd()
                local lastSlashIndex = currentPath:find '/[^/]*$'
                if lastSlashIndex then
                    return currentPath:sub(lastSlashIndex + 1)
                else
                    return currentPath
                end
            end
            function GetDefaultTabName()
                return '   ' .. GetCurrentFolder()
            end
            function GetActiveFileName()
                local fileName = vim.fn.expand '%:t'
                if fileName == '' then
                    return GetCurrentFolder()
                else
                    return fileName
                end
            end

            vim.cmd [[
                augroup FileBufferGroup
                  au!

                  au BufEnter * lua DispatchWezTermEvent({name = 'BufEnter', pid = vim.fn.getpid(), filename = vim.fn.expand('%:p'), pwd = vim.fn.getcwd()})
                  au BufLeave * lua DispatchWezTermEvent({name = 'BufLeave', pid = vim.fn.getpid(), filename = vim.fn.expand('%:p'), pwd = vim.fn.getcwd()})
                  au VimEnter * lua DispatchWezTermEvent({name = 'VimEnter', pid = vim.fn.getpid(), filename = GetActiveFileName(), pwd = vim.fn.getcwd()})
                augroup END
            ]]

            -- on neovim startup, send the current working directory
            vim.cmd [[
                augroup VimEnterGroup
                  au!
                    au VimEnter * lua DispatchWezTermEvent({name = 'VimEnter', pid = vim.fn.getpid(), title=GetDefaultTabName()})
                augroup END
            ]]

            --[[
            local function setAlacrittyTOMLPaddingXY(xPadding, yPadding)
                local homeDirectory = os.getenv 'HOME'
                local tomlPath = homeDirectory .. '/.config/alacritty/alacritty.toml'

                -- get the user's local
                local file, err = io.open(tomlPath, 'r')
                if not file or err then
                    return
                end
                local lines = {}
                local inWindowPaddingSection = false
                for line in file:lines() do
                    if line:find '%[window%.padding%]' then
                        inWindowPaddingSection = true
                    elseif line:find '%[.*%]' then
                        inWindowPaddingSection = false
                    end

                    if inWindowPaddingSection then
                        if line:find 'x = ' then
                            line = 'x = ' .. xPadding
                        elseif line:find 'y = ' then
                            line = 'y = ' .. yPadding
                        end
                    end

                    table.insert(lines, line)
                end
                file:close()

                file, err = io.open(tomlPath, 'w')
                if not file or err then
                    return
                end

                for _, line in ipairs(lines) do
                    file:write(line .. '\n')
                end
                file:close()
            end

            function IncreasePadding()
                -- wezterm.set_user_var('PADDING', 'on')
                -- wezterm.set_user_var('FOCUS', 'on')
                -- setAlacrittyTOMLPaddingXY(30, 30)
            end

            function DecreasePadding()
                --wezterm.set_user_var('PADDING', 'off')
                -- wezterm.set_user_var('FOCUS', 'off')
                -- setAlacrittyTOMLPaddingXY(0, 0)
            end
            --]]

            --[[
            vim.cmd [[
                augroup ChangeParentTerminal
                  au!
                  au VimEnter * lua DecreasePadding()
                  au VimLeavePre * lua IncreasePadding()
                augroup END
            ]]
            --]]
        end,
    },
}
