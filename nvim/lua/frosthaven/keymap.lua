-- Basic Keymaps ***************************************************************
--******************************************************************************
-- see cmp.lua (autocomplete) and lsp.lua (language server) for more keymaps

-- leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- remove defaults
vim.g.BASH_Ctrl_j = 'off'
vim.g.BASH_Ctrl_k = 'off'
vim.g.BASH_Ctrl_h = 'off'
vim.g.BASH_Ctrl_l = 'off'

-- better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'",
    { expr = true, silent = true }
)
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'",
    { expr = true, silent = true }
)

-- smart-split
-- local smart_split = require('smart-splits')
-- vim.keymap.set('n', '<leader>w', require('smart-splits').start_resize_mode())
-- resizing splits
vim.keymap.set('n', '<F6>', require('smart-splits').resize_left, {})
vim.keymap.set('n', '<F7>', require('smart-splits').resize_down, {})
vim.keymap.set('n', '<F8>', require('smart-splits').resize_up, {})
vim.keymap.set('n', '<F9>', require('smart-splits').resize_right, {})
-- moving between splits
vim.keymap.set('n', '<F1>', require('smart-splits').move_cursor_left, {})
vim.keymap.set('n', '<F2>', require('smart-splits').move_cursor_down, {})
vim.keymap.set('n', '<F3>', require('smart-splits').move_cursor_up, {})
vim.keymap.set('n', '<F4>', require('smart-splits').move_cursor_right, {})

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fw', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fh', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>fb', "<Cmd>Telescope file_browser<CR>", {})
-- pounce support
vim.keymap.set("n", "s", "<Cmd>Pounce<CR>", {})

-- harpoon support
local harpoon_mark = require("harpoon.mark")
vim.keymap.set("n", "<leader>fm", "<Cmd>Telescope harpoon marks<CR>", {})
vim.keymap.set("n", "<leader>mi", harpoon_mark.add_file, {})
vim.keymap.set("n", "<leader>mo", harpoon_mark.rm_file, {})
vim.keymap.set("n", "<leader>mc", harpoon_mark.clear_all, {})

-- diagnostic floating box
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)

-- toggle term
vim.keymap.set("n", "<leader>t1", "<Cmd>ToggleTerm 1<CR>", {})
vim.keymap.set("n", "<leader>t2", "<Cmd>ToggleTerm 2<CR>", {})

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  -- vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  -- vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  -- vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  -- vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  -- vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')
