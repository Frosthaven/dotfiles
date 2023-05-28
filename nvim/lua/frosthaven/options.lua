-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Make hybrid line numbers default
vim.o.number = true
vim.o.relativenumber = true

-- Disable wrapping
vim.o.wrap = false

-- Control indentations
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Color code margin line
vim.o.colorcolumn = '80'

-- Line numbering
vim.opt.nu = true
vim.opt.rnu = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'
