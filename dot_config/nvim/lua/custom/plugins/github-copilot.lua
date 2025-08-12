return {
    { -- github copilot
        'github/copilot.vim',
        config = function()
            -- remap completion to ctrl+shift+y
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap('i', '<C-S-y>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
        end,
    },
}
