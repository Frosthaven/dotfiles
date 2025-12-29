return {
    'stevearc/oil.nvim',
    enabled = false,
    keys = {
        { '-', '<CMD>Oil<CR>', desc = 'Oil file browser' },
    },
    opts = {
        default_file_explorer = true,
        view_options = {
            show_hidden = true,
        },
    },
}
