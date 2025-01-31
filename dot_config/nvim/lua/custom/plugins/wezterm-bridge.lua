return {
    {
        'willothy/wezterm.nvim',
        opts = {
            --create_commands = false
        },
        config = function()
            -- auto padding for wezterm and alacritty
            local wezterm = require 'wezterm'

            local pid = vim.fn.getpid()

            function PackageVariables(table)
                -- converts a table into a json string
                return vim.json.encode(table)
            end

            function FocusGained()
                wezterm.set_user_var('FOCUS', 'on:' .. pid)
            end

            function FocusLost()
                wezterm.set_user_var('FOCUS', 'off:' .. pid)
            end

            function DispatchWezTermEvent(name)
                wezterm.set_user_var('NVIM_EVENT', name)
            end

            vim.cmd [[
                augroup FocusChangeGroup
                  au!
                  au FocusGained * lua FocusGained()
                  au FocusLost * lua FocusLost()
                  au VimLeavePre * lua FocusLost()
                  au VimEnter * lua FocusGained()

                  au FocusGained * lua DispatchWezTermEvent(vim.json.encode({name = 'FocusGained', pid = vim.fn.getpid()}))
                  au FocusLost * lua DispatchWezTermEvent(vim.json.encode({name = 'FocusLost', pid = vim.fn.getpid()}))
                  au VimEnter * lua DispatchWezTermEvent(vim.json.encode({name = 'VimEnter', pid = vim.fn.getpid()}))
                  au VimLeavePre * lua DispatchWezTermEvent(vim.json.encode({name = 'VimLeavePre', pid = vim.fn.getpid()}))
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
