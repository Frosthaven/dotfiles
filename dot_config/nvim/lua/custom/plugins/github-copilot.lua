return {
    { -- github copilot
        'github/copilot.vim',
        config = function()
            -- remap completion to shift+tab or right arrow
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap('i', '<S-Tab>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
            vim.api.nvim_set_keymap('i', '<Right>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
        end,
    },
}
