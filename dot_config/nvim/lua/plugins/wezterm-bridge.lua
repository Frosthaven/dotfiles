return {
    {
        'willothy/wezterm.nvim',
        enabled = true,
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

            function GetDefaultTabName()
                return '   ' .. GetCurrentFolder() .. ' '
            end

            -- Helper function to get the filename or use default tab name
            function GetFilenameOrNil()
                local filename = vim.fn.expand '%:p'
                if filename == '' then
                    return nil -- No filename, so we'll just omit the filename field
                end
                return filename
            end

            function GetFilenameOrDefault()
                local filename = vim.fn.expand '%:p'
                if filename == '' then
                    return GetDefaultTabName() -- Use default tab name if no filename
                end
                return filename
            end

            function GetCurrentFolder()
                local currentPath = vim.fn.getcwd()
                local lastSlashIndex = currentPath:find '/[^/]*$'
                if lastSlashIndex then
                    return currentPath:sub(lastSlashIndex + 1)
                else
                    return currentPath
                end
            end

            function GetTitleIfNoFilename()
                local filename = vim.fn.expand '%:p'
                if filename == '' then
                    return GetDefaultTabName() -- Only send title if no filename
                end
                return nil -- Do not send title if a filename is present
            end

            vim.cmd [[
                augroup FileBufferGroup
                    au!

                    au BufEnter * lua DispatchWezTermEvent({name = 'BufEnter', pid = vim.fn.getpid(), filename = GetFilenameOrNil(), title = GetTitleIfNoFilename(), pwd = vim.fn.getcwd()})
                    au BufLeave * lua DispatchWezTermEvent({name = 'BufLeave', pid = vim.fn.getpid(), filename = GetFilenameOrNil(), title = GetTitleIfNoFilename(), pwd = vim.fn.getcwd()})
                    au VimEnter * lua DispatchWezTermEvent({name = 'VimEnter', pid = vim.fn.getpid(), filename = GetFilenameOrNil(), title = GetTitleIfNoFilename(), pwd = vim.fn.getcwd()})
                augroup END
            ]]

            -- on neovim startup, send the current working directory
            vim.cmd [[
                augroup VimEnterGroup
                  au!
                    au VimEnter * lua DispatchWezTermEvent({name = 'VimEnter', pid = vim.fn.getpid(), filename  = GetFilenameOrDefault(), title=GetTitleIfNoFilename()})
                augroup END
            ]]
        end,
    },
}
