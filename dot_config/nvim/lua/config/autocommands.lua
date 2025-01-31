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

    -- Style terminal windows
    vim.api.nvim_create_autocmd('TermOpen', {
        group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
        callback = function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            -- vim.opt_local.signcolumn = 'no'
            -- vim.opt_local.cursorline = false
        end,
    })
end

return M
