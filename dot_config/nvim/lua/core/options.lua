-- OPTIONS --------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Basic settings -------------------------------------------------------------

vim.opt.number = true         -- line numbers
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true     -- highlight current line
vim.opt.wrap = false          -- don't wrap lines
vim.opt.scrolloff = 10        -- keep lines above/below cursor
vim.opt.sidescrolloff = 8     -- keep columns left/right of cursor

-- Indentation ----------------------------------------------------------------

vim.opt.tabstop = 4        -- tab width
vim.opt.shiftwidth = 4     -- indent width
vim.opt.softtabstop = 4    -- soft tab stop
vim.opt.breakindent = true -- maintain indent on wrap
vim.opt.expandtab = true   -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indenting
vim.opt.autoindent = true  -- copy indent from current line
vim.opt.textwidth = 80     -- max-width of text when formatting

-- Special characters ---------------------------------------------------------

vim.opt.list = true
vim.opt.listchars:append('space:⋅')
vim.opt.listchars:append('tab:→ ')
vim.g.have_nerd_font = true

-- Search settings ------------------------------------------------------------

vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true  -- case sensitive if starts upper
vim.opt.hlsearch = false  -- don't highlight search results
vim.opt.incsearch = true  -- show matches as you type

-- Visual settings -------------------------------------------------------------

vim.opt.termguicolors = true                      -- enable 24-bit colors
vim.opt.signcolumn = "yes"                        -- always show sign column
vim.opt.colorcolumn = "80"                        -- show desired column colored
vim.opt.showmatch = true                          -- highlight matching brackets
vim.opt.matchtime = 2                             -- time to show matching brackets
vim.opt.cmdheight = 1                             -- command line height
vim.opt.completeopt = "menuone,noinsert,noselect" -- completion options
vim.opt.showmode = false                          -- toggle show mode in command line
vim.opt.pumheight = 10                            -- popup menu height
vim.opt.pumblend = 10                             -- popup menu transparency
vim.opt.winblend = 0                              -- floating window transparency
vim.opt.conceallevel = 0                          -- don't hide markup
vim.opt.concealcursor = ""                        -- don't hide cursor line markup
vim.opt.synmaxcol = 300                           -- syntax highlighting limit

-- File handling --------------------------------------------------------------

vim.opt.backup = false      -- don't create backup files
vim.opt.writebackup = false -- don't create backup before writing
vim.opt.swapfile = false    -- don't create swap files
vim.opt.undofile = true     -- persistent undo
vim.opt.undodir = vim.fn.expand("~/.undo")
vim.opt.updatetime = 300    -- faster completion
vim.opt.timeoutlen = 500    -- key timeout duration
vim.opt.ttimeoutlen = 0     -- key code timeout
vim.opt.autoread = true     -- reload files changed outside nvim
vim.opt.autowrite = false   -- don't auto-save

-- Behavior settings ----------------------------------------------------------

vim.opt.hidden = true                   -- allow hidden buffers
vim.opt.errorbells = false              -- no error bells
vim.opt.splitbelow = true               -- horizontal splits below
vim.opt.splitright = true               -- vertical splits right
vim.opt.backspace = "indent,eol,start"  -- better backspace behavior
vim.opt.autochdir = false               -- don't auto change directory
vim.opt.iskeyword:append("-")           -- treat dash as part of word
vim.opt.path:append("**")               -- include subdirectories in search
vim.opt.selection = "inclusive"         -- selection behavior
vim.opt.mouse = "a"                     -- enable mouse
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true               -- allow buffer modifications
vim.opt.encoding = "UTF-8"              -- set encoding
vim.api.nvim_create_autocmd(            -- highlight on yank
    "TextYankPost",
    {
        callback = function()
            vim.highlight.on_yank({
                higroup = "IncSearch", -- Highlight group to use
                timeout = 200,         -- Duration of the highlight
            })
        end,
    }
)

-- Diagnostic settings ---------------------------------------------------------

-- diagnostics messages
vim.diagnostic.config {
    virtual_text = true, -- show inline error messages
    underline = true, -- underline problematic code
    update_in_insert = false, -- update diagnostics while in insert mode
    severity_sort = true, -- sort diagnostics by severity
    float = {
        border = 'rounded', -- border style for floating windows
        source = 'if_many', -- show the diagnostic source (LSP name)
        header = '', -- optional header
        prefix = '', -- optional prefix
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '✖',
            [vim.diagnostic.severity.WARN] = '⚠',
            [vim.diagnostic.severity.HINT] = '➤',
            [vim.diagnostic.severity.INFO] = 'ℹ',
        },
    },
}

-- Cursor settings ------------------------------------------------------------

vim.opt.guicursor = table.concat({
    "n-v-c-ve:block",                                       -- normal, command, and visual (block/insert)
    "i-ci:ver25",                                           -- insert, insert completion
    "r-cr:hor20",                                           -- replace and virtual replace → horizontal 20%
    "o:hor50",                                              -- operator pending → horizontal 50%
    "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", -- all modes defaults
    "sm:block-blinkwait175-blinkoff150-blinkon175"          -- showmatch
}, ",")
