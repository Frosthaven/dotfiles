return {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
        per_filetype = {
            -- ['html'] = {
            --     enable_close = false,
            -- },
        },
    },
}
