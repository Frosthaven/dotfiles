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
            vim.cmd([[highlight ColorColumn guibg=#101521]])
            vim.cmd([[highlight Whitespace guifg=#363748]])
        end,
    },
}
