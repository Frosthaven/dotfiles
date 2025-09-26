-- KEYMAP ---------------------------------------------------------------------
-------------------------------------------------------------------------------

--[[
Due to my use of a corne split 40% keyboard, having arrow key usage in VIM is
no longer taboo. You will find many keybinds that use hjkl as well as the arrow
keys to accomplish the same task.
--]]

-- Leader key -----------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Yank to EOL ----------------------------------------------------------------

vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Center screen when jumping -------------------------------------------------

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Window navigation ----------------------------------------------------------

-- hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- arrows
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Move to right window" })

-- Move lines up and down with alt in visual mode -----------------------------

-- hjkl
vim.keymap.set(
    "v", "<A-j>", ":m '>+1<CR>gv=gv",
    { desc = "Move selection down" }
)
vim.keymap.set(
    "v", "<A-k>", ":m '<-2<CR>gv=gv",
    { desc = "Move selection up" }
)

-- arrows
vim.keymap.set(
    "v", "<A-Down>", ":m '>+1<CR>gv=gv",
    { desc = "Move selection down" }
)
vim.keymap.set(
    "v", "<A-Up>", ":m '<-2<CR>gv=gv",
    { desc = "Move selection up" }
)

-- Persistant indentation in visual mode --------------------------------------

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Quickfix Lists -------------------------------------------------------------

-- hjkl
vim.keymap.set(
    'n', '<M-j>', '<cmd>cnext<CR>',
    { desc = 'Move to the next quickfix or diagnostic item' }
)
vim.keymap.set(
    'n', '<M-k>', '<cmd>cprev<CR>',
    { desc = 'Move to the previous quickfix or diagnostic item' })
-- arrows
vim.keymap.set(
    'n', '<M-Down>', '<cmd>cnext<CR>',
    { desc = 'Move to the next quickfix item' }
)
vim.keymap.set(
    'n', '<M-Up>', '<cmd>cprev<CR>',
    { desc = 'Move to the previous quickfix item' }
)

-- Diagnostics ----------------------------------------------------------------

-- quickfix list
vim.keymap.set(
    'n', '<leader>dq', vim.diagnostic.setloclist,
    { desc = 'Open diagnostic [Q]uickfix list' }
)

-- toggle virtual text
vim.keymap.set('n', '<leader>dt', function()
    if vim.diagnostic.config().virtual_text == true then
        vim.diagnostic.config { virtual_text = false, virtual_lines = false }
        vim.notify 'Global diagnostic virtual lines disabled'
    else
        vim.diagnostic.config { virtual_text = true, virtual_lines = false }
        vim.notify 'Global diagnostic virtual lines enabled'
    end
end, { desc = 'Toggle [D]iagnostic [T]oggle' })

-- create a diagnostic popup if you press leader d k
vim.keymap.set('n', '<leader>dd', function()
    local opts = {
        focusable = true,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter' },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'line',
    }
    vim.diagnostic.open_float(nil, opts)
end, { desc = '[D]iagnostic [D]isplay' })

-- yank diagnostic messages on line
vim.keymap.set('n', '<leader>dy', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })

    if vim.tbl_isempty(diagnostics) then
        vim.notify('No diagnostics on current line', vim.log.levels.INFO)
        return
    end

    local messages = {}
    for _, diag in ipairs(diagnostics) do
        table.insert(messages, diag.message)
    end

    local all_messages = table.concat(messages, '\n')
    vim.fn.setreg('+', all_messages) -- use system clipboard
    vim.notify('Yanked diagnostic message(s) to system clipboard', vim.log.levels.INFO)
end, { desc = '[D]iagnostic [Y]ank' })

-- previous and next diagnostic
local function show_diagnostic_float()
    local diagnostics = vim.diagnostic.get(0) -- Get diagnostics for the buffer
    if #diagnostics > 0 then
        -- Show the first diagnostic as a floating window
        vim.diagnostic.open_float()
    end
end

-- Next diagnostic
vim.keymap.set('n', '<leader>dn', function()
    vim.diagnostic.goto_next() -- Move to the next diagnostic
    show_diagnostic_float()    -- Show the diagnostic float
end, { desc = 'Go to [N]ext diagnostic' })

-- Previous diagnostic
vim.keymap.set('n', '<leader>dp', function()
    vim.diagnostic.goto_prev() -- Move to the previous diagnostic
    show_diagnostic_float()    -- Show the diagnostic float
end, { desc = 'Go to [P]revious diagnostic' })

-- LSP keymaps ----------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        -- NOTE: Remember that Lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your ursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.

        -- Find references for the word under your cursor.
        map('<leader>ln', vim.lsp.buf.rename, 'Re[n]ame')
        map('<leader>la', vim.lsp.buf.code_action, 'Code [A]ction')
        map('<leader>lA', vim.lsp.buf.code_action, 'Code [A]ction (extra)', { 'n', 'x' })

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>lh', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Inlay [H]ints')
        end
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
                end,
            })
        end

        -- if client.server_capabilities.colorProvider then
        --     require('document-color').buf_attach(event.buf)
        -- end
    end,
})


-- Minus for toggling :Explore ------------------------------------------------
-- these :explore keymaps are loaded initially, but get replaced by navigation
-- plugins like mini.files. This ensures a fallback behavior that stays
-- consistent across setups.

-- enter :Explore
vim.keymap.set("n", '-', ":Explore<CR>", { desc = ":Explore" })
-- Leave :Explore
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        vim.keymap.set('n', '-', ':Rex<CR>', {
            buffer = true,
            desc = "Return from :Explore",
            noremap = true,
            silent = true
        })
    end,
})

-- Toggle Terminal ------------------------------------------------------------

vim.keymap.set(
    't', '<Esc><Esc>', '<C-\\><C-n>',
    { desc = 'Exit terminal mode' }
)
vim.keymap.set('n', '<leader>tt', function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd 'J'
    vim.api.nvim_win_set_height(0, 10)
end, { desc = '[T]iny [T]erminal' })
