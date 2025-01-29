return {
    { -- Forced background transparency
        'xiyaowong/transparent.nvim',
        lazy = false,
        enabled = true,
        config = function()
            require('transparent').setup {
                -- table: default groups
                groups = {
                    'Normal',
                    'NormalNC',
                    'Comment',
                    'Constant',
                    'Special',
                    'Identifier',
                    'Statement',
                    'PreProc',
                    'Type',
                    'Underlined',
                    'Todo',
                    'String',
                    'Function',
                    'Conditional',
                    'Repeat',
                    'Operator',
                    'Structure',
                    'LineNr',
                    'NonText',
                    'SignColumn',
                    'CursorLine',
                    'CursorLineNr',
                    'StatusLine',
                    'StatusLineNC',
                    'EndOfBuffer',
                },
                -- table: additional groups that should be cleared
                extra_groups = {
                    'TelescopeNormal',
                },
                -- table: groups you don't want to clear
                exclude_groups = {},
                -- function: code to be executed after highlight groups are cleared
                -- Also the user event "TransparentClear" will be triggered
                on_clear = function() end,
            }
        end,
    },

    {
        'folke/tokyonight.nvim',
        lazy = false,
        enabled = true,
        priority = 1000,
        opts = { style = 'storm' },
        init = function()
            vim.cmd.colorscheme 'tokyonight'
            vim.cmd.hi 'Comment gui=none'
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
            vim.cmd.hi 'Comment gui=none'
        end,
    },
}
