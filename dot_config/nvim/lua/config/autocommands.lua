local M = {}

M.setup = function()
    -- [[ Basic Autocommands ]]
    --  See `:help lua-guide-autocommands`

    -- Highlight when yanking (copying) text
    --  Try it with `yap` in normal mode
    --  See `:help vim.highlight.on_yank()`
    vim.api.nvim_create_autocmd('TextYankPost', {
        desc = 'Highlight when yanking (copying) text',
        group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
        callback = function()
            vim.highlight.on_yank()
        end,
    })

    -- Style newly created terminal windows
    vim.api.nvim_create_autocmd('TermOpen', {
        group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
        callback = function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            -- vim.opt_local.signcolumn = 'no'
            vim.opt_local.cursorline = false
            vim.cmd.startinsert()

            -- Set title for terminal windows
            vim.opt.title = true
            vim.opt.titlestring = [[%t – %{fnamemodify(getcwd(), ':t')}]]
        end,
    })

    -- Add transparency whenever colorscheme changes
    vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('custom-colorschemes', { clear = true }),
        callback = function()
            vim.cmd.hi 'Comment gui=none'
            vim.cmd.hi 'Normal guibg=NONE'
            vim.cmd.hi 'NormalNC guibg=NONE'
            vim.cmd.hi 'CursorLine guibg=NONE'
            vim.cmd.hi 'MiniFilesCursorLine guibg=NONE'
            vim.cmd.hi 'StatusLine guibg=NONE'
            vim.cmd.hi 'StatusLineNC guibg=NONE'
            vim.cmd.hi 'SignColumn guibg=NONE'
            vim.cmd.hi 'SignColumnSB guibg=NONE'
            vim.cmd.hi 'MiniFilesNormal guibg=NONE'
            vim.cmd.hi 'MiniFilesBorder guibg=NONE'
            vim.cmd.hi 'MiniStatusLineFileName guibg=NONE'
            vim.cmd.hi 'MiniStatusLineInactive guibg=NONE'
            vim.cmd.hi 'TelescopeBorder guibg=NONE'
            vim.cmd.hi 'TelescopePromptBorder guibg=NONE'
            vim.cmd.hi 'TelescopeResultsBorder guibg=NONE'
            vim.cmd.hi 'TelescopePreviewBorder guibg=NONE'
            vim.cmd.hi 'TelescopeResultsTitle guibg=NONE'
            vim.cmd.hi 'TelescopePreviewTitle guibg=NONE'
            vim.cmd.hi 'TelescopePromptTitle guibg=NONE'
            vim.cmd.hi 'TelescopeTitle guibg=NONE'
            vim.cmd.hi 'TelescopeNormal guibg=NONE'
        end,
    })
end

return M
