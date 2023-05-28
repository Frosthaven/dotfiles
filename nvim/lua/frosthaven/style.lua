-- Pallet **********************************************************************
--******************************************************************************

require('onedark').setup {
  style = 'dark', -- 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'
  ending_tildes = false,
  transparent = not vim.g.neovide, -- true if not using neovide
  lualine = {
    transparent = false,
  },
}
require('onedark').load()

local colors = require('onedark.colors')
colors.none = 'NONE'
colors.dark_gray = "#282c34"
colors.darker_gray = "#191D21"
colors.lighter_gray = "#31353f"
colors.subtle_characters = "#363f49"
colors.dark_background = "#212627"

--background color
if (vim.g.neovide == true) then
  vim.cmd('highlight Normal guibg=#252a31')
end

-- Pounce w/Dim ****************************************************************
--******************************************************************************

-- syntax match only worked from cmd, not auto
-- not sure how to clear the group - maybe reference how lightspeed works

-- vim.cmd('highlight Everything guifg='..colors.subtle_characters..' guibg='..colors.none)
-- vim.cmd('syntax match Everything /.*/')

-- Editor **********************************************************************
--******************************************************************************

-- set font (useful for neovide) - this is moved to higher level file
-- vim.cmd('set guifont=JetBrainsMono\\ NFM:h15')
-- general config
vim.opt.list = true
vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:append "eol:"
vim.opt.listchars:append "tab: "
vim.opt.listchars:append "trail:⋅"
vim.opt.cmdheight = 0
-- theme
vim.wo.cursorline = true

-- indent icons
require('indent_blankline').setup {
  show_end_of_line = false,
  space_char_blankline = " ",
  char = '',
  show_trailing_blankline_indent = false,
  char_highlight_list = {
    "IndentBlankLineIndent1",
  },
  space_char_highlight_list = {
    "IndentBlankLineIndent1",
  }
}

-- whitespace / listchars
-- doesn't work -- vim.cmd("call matchadd('WhitespaceCharacters', '\x0b\x0c\r\x1c\x1d\x1e\x1f\x85\u1680\u2000\u2001\u2002\u2003\viu2004\u2005\u200')")
vim.cmd("call matchadd('WhiteSpaceCharacters', ' ')")
vim.cmd('highlight IndentBlankLineIndent1 guifg='..colors.subtle_characters)
vim.cmd('highlight NonText guifg='..colors.subtle_characters)
vim.cmd('highlight WhiteSpaceCharacters guifg='..colors.subtle_characters)

-- default cursorcolor and shapes
vim.api.nvim_command('highlight cursor gui=none guibg=' .. 'reverse' .. ' guifg=' .. 'reverse')
vim.api.nvim_command('set guicursor=n-v-c-r-cr-o:Block-Cursor,i-ci-ve:ver25-Cursor')

-- default cursorline + gutter
vim.api.nvim_command("hi! CursorLine guifg=NONE guibg=" .. colors.lighter_gray)
vim.cmd('hi! CursorLineNr guibg=' .. colors.lighter_gray .. ' guifg=' .. colors.blue)

-- default colorcolumn
vim.cmd("highlight ColorColumn guibg=" .. colors.dark_gray)

-- mode color ceanging
--[[ require('modes').setup({
  colors = {
    default = colors.green,
    copy = colors.yellow,
    delete = colors.red,
    insert = colors.blue,
    visual = colors.purple,
  },
  line_opacity = 0.4,
  set_cursor = false,
  set_cursorline = false,
  set_number = true,
  ignore_filetypes = { 'NvimTree', 'TelescopePrompt' }
}) ]]

-- pounce
Pounce_colors = {
  match = "#ffcc00";
  background = colors.darker_gray;
  gap = colors.light_grey;
  gui = 'NONE'
}

vim.cmd("highlight PounceMatch gui="..Pounce_colors.gui.." guifg="..Pounce_colors.match.." guibg="..Pounce_colors.background)
vim.cmd("highlight PounceGap gui="..Pounce_colors.gui.." guifg="..Pounce_colors.gap.." guibg="..Pounce_colors.background)
vim.cmd("highlight PounceAccept gui="..Pounce_colors.gui.."  guifg="..Pounce_colors.background.." guibg="..Pounce_colors.match)
vim.cmd("highlight PounceAcceptBest gui="..Pounce_colors.gui.."  guifg="..Pounce_colors.background.." guibg="..Pounce_colors.match)

-- telescope
vim.cmd("highlight TelescopeBorder guifg=" .. colors.grey)
vim.cmd("highlight TelescopePromptBorder guifg=" .. colors.grey)
vim.cmd("highlight TelescopeResultsBorder guifg=" .. colors.grey)
vim.cmd("highlight TelescopePreviewBorder guifg=" .. colors.grey)
-- gitblame
vim.cmd("highlight gitsignscurrentlineblame guifg=#434c56")
-- listchars (empty text etc)

-- status bar
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'onedark',
    component_separators = { left = '', right = ''},
    section_separators = {left = '', right=''},
    --section_separators = {left = '', right=''},
  },
}

-- git signs
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 0,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '  <author>, <author_time:%Y-%m-%d> - <summary>',
}
-- telescope
require('telescope').setup {
  defaults = {
       file_ignore_patterns = {
        'node_modules/.*',
        '.git/.*',
        'vendor/*'
      }
  },
  pickers = {
    live_grep = {
      additional_args = function(opts)
        return {"--hidden"}
      end
    },
    find_files = {
      -- theme = "dropdown",
    }
  },
  extensions = {
    -- ...
  }
}

-- virtual text
vim.lsp.handlers["textDocument/publishDiagnostics"] =
vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = true,
  }
)

-- CMP (autocomplete) **********************************************************
--******************************************************************************

-- LSP (language servers) ******************************************************
--******************************************************************************

-- Other ***********************************************************************
--******************************************************************************

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup(
  'YankHighlight', { clear = true }
)
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
