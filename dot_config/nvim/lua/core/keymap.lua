-- KEYMAP ---------------------------------------------------------------------
-------------------------------------------------------------------------------

local keymap_helpers = require 'lib.keymap_helpers'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Yank to EOL ----------------------------------------------------------------

vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank to end of line' })

-- Yank into Markdown Code Block ----------------------------------------------

vim.keymap.set({ 'n', 'v' }, '<leader>yc', keymap_helpers.yank_codeblock, { desc = '[Y]ank as [C]ode block' })

-- Yank File Path -------------------------------------------------------------

vim.keymap.set({ 'n', 'v' }, '<leader>yr', keymap_helpers.yank_relative_path, { desc = '[Y]ank [R]elative path of file' })
vim.keymap.set({ 'n', 'v' }, '<leader>ya', keymap_helpers.yank_absolute_path, { desc = '[Y]ank [A]bsolute path of file' })

-- Yank Diagnostic Messaging --------------------------------------------------

vim.keymap.set({ 'n', 'v' }, '<leader>yd', keymap_helpers.yank_diagnostics, { desc = '[Y]ank [D]iagnostic code block' })

-- Yank github url to selection -----------------------------------------------

vim.keymap.set({ 'n', 'v' }, '<leader>yg', keymap_helpers.yank_github_url, { desc = '[Y]ank [G]itHub URL for current line(s)' })

-- Center screen when jumping -------------------------------------------------

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Prev search result (centered)' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })

-- Window navigation ----------------------------------------------------------

-- hjkl
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- arrows
vim.keymap.set('n', '<C-Left>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-Down>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-Up>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-Right>', '<C-w>l', { desc = 'Move to right window' })

-- Move lines up and down with alt in visual mode -----------------------------

-- hjkl
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- arrows
vim.keymap.set('v', '<A-Down>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-Up>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Persistant indentation in visual mode --------------------------------------

vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Contact aware list navigation ----------------------------------------------
-- works on location list if it exists, otherwise quickfix list

local function move_list(next)
    local wininfo_list = vim.fn.getwininfo()
    local loc_winid = nil

    -- Find first visible location list window
    for _, win in ipairs(wininfo_list) do
        if win.loclist == 1 and #vim.fn.getloclist(win.winid) > 0 then
            loc_winid = win.winid
            break
        end
    end

    if loc_winid then
        -- Jump to the location list window
        vim.api.nvim_set_current_win(loc_winid)
        if next then
            pcall(function()
                vim.cmd 'lnext'
            end)
        else
            pcall(function()
                vim.cmd 'lprev'
            end)
        end
    elseif #vim.fn.getqflist() > 0 then
        if next then
            pcall(function()
                vim.cmd 'cnext'
            end)
        else
            pcall(function()
                vim.cmd 'cprev'
            end)
        end
    else
        print 'No location list or quickfix list found'
    end
end

-- hjkl
vim.keymap.set('n', '<M-j>', function()
    move_list(true)
end, { desc = 'Move to next list item' })
vim.keymap.set('n', '<M-k>', function()
    move_list(false)
end, { desc = 'Move to previous list item' })
-- arrows
vim.keymap.set('n', '<M-Down>', function()
    move_list(true)
end, { desc = 'Move to next list item' })
vim.keymap.set('n', '<M-Up>', function()
    move_list(false)
end, { desc = 'Move to previous list item' })

-- Diagnostic Virtual Text ----------------------------------------------------

vim.keymap.set('n', '<leader>dt', function()
    if vim.diagnostic.config().virtual_text == true then
        vim.diagnostic.config { virtual_text = false, virtual_lines = false }
        vim.notify('󱙎 Global diagnostic virtual lines disabled', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
    else
        vim.diagnostic.config { virtual_text = true, virtual_lines = false }
        vim.notify('󱖭 Global diagnostic virtual lines enabled', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
    end
end, { desc = 'Toggle [D]iagnostic [T]oggle' })

-- Diagnostic Quickfix List ---------------------------------------------------

vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Floating diagnostic display ------------------------------------------------

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

-- Navigate diagnostics and show floating window ------------------------------

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
    show_diagnostic_float() -- Show the diagnostic float
end, { desc = 'Go to [N]ext diagnostic' })

-- Previous diagnostic
vim.keymap.set('n', '<leader>dp', function()
    vim.diagnostic.goto_prev() -- Move to the previous diagnostic
    show_diagnostic_float() -- Show the diagnostic float
end, { desc = 'Go to [P]revious diagnostic' })

-- LSP keymaps ----------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        -- mapping helper function
        local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

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
                    vim.api.nvim_clear_autocmds {
                        group = 'lsp-highlight',
                        buffer = event2.buf,
                    }
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
vim.keymap.set('n', '-', ':Explore<CR>', { desc = ':Explore' })
-- Leave :Explore
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        vim.keymap.set('n', '-', ':Rex<CR>', {
            buffer = true,
            desc = 'Return from :Explore',
            noremap = true,
            silent = true,
        })
    end,
})

-- Toggle Terminal ------------------------------------------------------------

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>tt', function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd 'J'
    vim.api.nvim_win_set_height(0, 10)
end, { desc = '[T]iny [T]erminal' })
