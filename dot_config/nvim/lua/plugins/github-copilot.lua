return {
  { -- github copilot
    'github/copilot.vim',
    enabled = true,
    config = function()
      -- remap completion to shift+tab
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap('i', '<S-Tab>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
    end,
  },
}
