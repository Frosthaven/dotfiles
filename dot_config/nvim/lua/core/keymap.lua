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

-- Yank Github URL For Line(s) ------------------------------------------------

vim.keymap.set({ 'n', 'v' }, '<leader>yg', keymap_helpers.yank_github_url, { desc = '[Y]ank [G]itHub URL for current line(s)' })

-- Center Screen When Jumping -------------------------------------------------

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Prev search result (centered)' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })

-- Window Navigation ----------------------------------------------------------

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

-- Shift Selected Line(s) -----------------------------------------------------

-- hjkl
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- arrows
vim.keymap.set('v', '<A-Down>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-Up>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Persistant Indentation In Visual Mode --------------------------------------

vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Context-Aware List Navigation (quickfix, location list) --------------------

-- hjkl
vim.keymap.set('n', '<M-j>', keymap_helpers.move_dynamic_list_next, { desc = 'Move to next list item' })
vim.keymap.set('n', '<M-k>', keymap_helpers.move_dynamic_list_prev, { desc = 'Move to previous list item' })
-- arrows
vim.keymap.set('n', '<M-Down>', keymap_helpers.move_dynamic_list_next, { desc = 'Move to next list item' })
vim.keymap.set('n', '<M-Up>', keymap_helpers.move_dynamic_list_prev, { desc = 'Move to previous list item' })

-- Diagnostic Virtual Text ----------------------------------------------------

vim.keymap.set('n', '<leader>dt', keymap_helpers.toggle_diagnostic_virtual_text, { desc = 'Toggle [D]iagnostic [T]oggle' })

-- Diagnostic Quickfix List ---------------------------------------------------

vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Show Diagnostic Floats -----------------------------------------------------

vim.keymap.set('n', '<leader>dd', keymap_helpers.show_curr_diagnostic_float, { desc = '[D]iagnostic [D]isplay' })
vim.keymap.set('n', '<leader>dn', keymap_helpers.show_next_diagnostic_float, { desc = 'Go to [N]ext diagnostic' })
vim.keymap.set('n', '<leader>dp', keymap_helpers.show_prev_diagnostic_float, { desc = 'Go to [P]revious diagnostic' })

-- Toggle Terminal ------------------------------------------------------------

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>tt', function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd 'J'
    vim.api.nvim_win_set_height(0, 10)
end, { desc = '[T]iny [T]erminal' })

-- Toggle :Explore Buffer -----------------------------------------------------
-- these :explore keymaps are loaded initially, but get replaced by navigation
-- plugins like mini.files. This ensures a fallback behavior that stays
-- consistent across setups.

vim.keymap.set('n', '-', ':Explore<CR>', { desc = ':Explore' })
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

-- LSP Attach Keymaps ---------------------------------------------------------

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
