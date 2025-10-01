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

-- Yank As NVIM Zip File ------------------------------------------------------

vim.keymap.set({ 'n', 'v' }, '<leader>yz', keymap_helpers.yank_compressed_file, { desc = '[Y]ank as [Z]ip file' })

-- Paste NVIM Zip File --------------------------------------------------------

vim.keymap.set('n', '<leader>pz', keymap_helpers.paste_compressed_file, { desc = '[Z]ip file [P]aste' })

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
    group = vim.api.nvim_create_augroup('lsp-attach-keymaps', { clear = true }),
    callback = function(event)
        -- set generic lsp keymaps
        vim.keymap.set('n', '<leader>ln', vim.lsp.buf.rename, { buffer = event.buf, desc = 'LSP: Re[n]ame' })
        vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: Code [A]ction' })
        vim.keymap.set({ 'n', 'x' }, '<leader>lA', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: Code [A]ction (extra)' })

        -- Enable inlay hints keymap if supported by the server. Inlay hints are
        -- the inline annotations that show argument values, inferred types,
        -- etc.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.keymap.set('n', '<leader>lh', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { buffer = event.buf, desc = 'LSP: Inlay [H]ints' })
        end
    end,
})
