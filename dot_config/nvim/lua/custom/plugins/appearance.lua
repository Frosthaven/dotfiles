return {
    {
        'lukas-reineke/virt-column.nvim',
        enabled = true,
        opts = {},
        config = function()
            require('virt-column').setup {
                char = '│',
                virtcolumn = '80,120',
                highlight = 'VirtColumn',
            }

            -- make line number colors #11111D
            -- and #11111D for the virt column
            vim.api.nvim_set_hl(0, 'LineNr', { fg = '#656588', bg = '#11111D' })
            vim.api.nvim_set_hl(0, 'VirtColumn', { fg = '#252548' })
            vim.api.nvim_set_hl(0, 'SignColumn', { bg = '#11111D' })
            vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#202037' })
        end,
    },
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
        end,
    },
}
