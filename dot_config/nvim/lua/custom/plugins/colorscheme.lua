return {
  { -- Forced background transparency
    'tribela/transparent.nvim',
    enabled = true,
    event = 'VimEnter',
    config = true,
  },

  {
    'folke/tokyonight.nvim',
    lazy = false,
    enabled = false,
    priority = 1000,
    opts = { style = 'storm' },
    init = function()
      vim.cmd.colorscheme 'tokyonight'
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'rose-pine/neovim',
    lazy = false,
    enabled = true,
    name = 'rose-pine',
    config = function()
      require('rose-pine').setup {
        variant = 'moon',
      }
      vim.cmd.colorscheme 'rose-pine'
      vim.cmd.hi 'Comment gui=none'
    end,
  },
}
