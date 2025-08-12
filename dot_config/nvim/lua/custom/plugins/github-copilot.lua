return {
    { -- github copilot
        'github/copilot.vim',
        -- version lock reason: bug in version 1.42.0
        -- version = '1.34.0',
        config = function()
            -- remap completion to ctrl+shift+y
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap('i', '<C-S-y>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
        end,
    },
}
