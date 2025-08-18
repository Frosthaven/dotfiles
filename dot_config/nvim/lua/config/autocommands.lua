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
            -- general
            vim.cmd.hi 'Comment gui=none'
            vim.cmd.hi 'Normal guibg=NONE'
            vim.cmd.hi 'NormalNC guibg=NONE'
            vim.cmd.hi 'CursorLine guibg=NONE'
            vim.cmd.hi 'MiniFilesCursorLine guibg=NONE'
            vim.cmd.hi 'StatusLine guibg=NONE'
            vim.cmd.hi 'StatusLineNC guibg=NONE'
            vim.cmd.hi 'SignColumn guibg=NONE'
            vim.cmd.hi 'SignColumnSB guibg=NONE'
            vim.cmd.hi 'TabLine guibg=NONE'
            vim.cmd.hi 'TabLineFill guibg=NONE'
            vim.cmd.hi 'FloatTitle guibg=NONE'
            vim.cmd.hi 'FloatBorder guibg=NONE'
            vim.cmd.hi 'FloatFooter guibg=NONE'
            vim.cmd.hi 'NormalFloat guibg=NONE'
            -- mini files
            vim.cmd.hi 'MiniFilesNormal guibg=NONE'
            vim.cmd.hi 'MiniFilesBorder guibg=NONE'
            vim.cmd.hi 'MiniStatusLineFileName guibg=NONE'
            vim.cmd.hi 'MiniStatusLineInactive guibg=NONE'
            -- snacks picker
            vim.cmd.hi 'SnacksPickerBoxTitle guibg=NONE'
            vim.cmd.hi 'SnacksPickerInputTitle guibg=NONE'
            vim.cmd.hi 'SnacksPickerInputBorder guibg=NONE'
            vim.cmd.hi 'SnacksPickerSearch guibg=NONE'
            vim.cmd.hi 'SnacksPicker guibg=NONE'
            vim.cmd.hi 'SnacksPickerTitle guibg=NONE'
            vim.cmd.hi 'SnacksPickerBorder guibg=NONE'
            vim.cmd.hi 'SnacksPickerToggle guibg=NONE'
            vim.cmd.hi 'SnacksPickerFooter guibg=NONE'
            vim.cmd.hi 'SnacksPickerBox guibg=NONE'
            vim.cmd.hi 'SnacksPickerList guibg=NONE'
            vim.cmd.hi 'SnacksPickerInput guibg=NONE'
            vim.cmd.hi 'SnacksPickerPreview guibg=NONE'
            vim.cmd.hi 'SnacksPickerListTitle guibg=NONE'
            vim.cmd.hi 'SnacksPickerPreviewTitle guibg=NONE'
            vim.cmd.hi 'SnacksPickerBoxBorder guibg=NONE'
            vim.cmd.hi 'SnacksPickerListBorder guibg=NONE'
            vim.cmd.hi 'SnacksPickerPreviewBorder guibg=NONE'
            vim.cmd.hi 'SnacksPickerBoxFooter guibg=NONE'
            vim.cmd.hi 'SnacksPickerListFooter guibg=NONE'
            vim.cmd.hi 'SnacksPickerInputFooter guibg=NONE'
            vim.cmd.hi 'SnacksPickerPreviewFooter guibg=NONE'
        end,
    })
end

return M
