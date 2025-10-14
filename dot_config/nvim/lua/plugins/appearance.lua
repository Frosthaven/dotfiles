return {
    {
        'folke/tokyonight.nvim',
        lazy = false,
        enabled = false,
        priority = 1000,
        opts = { style = 'storm' },
        init = function()
            vim.cmd.colorscheme 'tokyonight'
        end,
    },
    {
        'rose-pine/neovim',
        lazy = false,
        enabled = false,
        name = 'rose-pine',
        config = function()
            require('rose-pine').setup {
                variant = 'moon',
            }
            vim.cmd.colorscheme 'rose-pine'
        end,
    },
    {
        'catppuccin/nvim',
        lazy = false,
        enabled = true,
        name = 'catppuccin',
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'catppuccin-mocha'

            local colors = require("catppuccin.palettes").get_palette()
            local function update_cursor_color()
                local mode = vim.fn.mode()
                local color
                if mode == 'n' then
                    color = colors.blue
                elseif mode == 'v' or mode == 'V' or mode == '\22' then
                    color = colors.mauve
                elseif mode == 'c' then
                    color = colors.peach
                elseif mode == 'i' then
                    color = colors.green
                else
                    color = colors.overlay2
                end
                vim.cmd("highlight CursorLineNr guifg=" .. color)
                vim.cmd("highlight Cursor guifg=NONE guibg=" .. color)
                vim.cmd("highlight ColorColumn guibg=#101521")
                vim.cmd("highlight Whitespace guifg=#313243")
            end
            update_cursor_color()
            vim.api.nvim_create_autocmd("ModeChanged", {
                callback = update_cursor_color
            })

        end
    },
}
