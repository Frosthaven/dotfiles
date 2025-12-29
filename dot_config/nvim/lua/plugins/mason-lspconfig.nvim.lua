return {
    'mason-org/mason-lspconfig.nvim',
    enabled = true,
    dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'neovim/nvim-lspconfig',
        {
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            opts = {
                ensure_installed = {
                    'stylua',
                    'prettierd',
                },
            },
        },
    },
    opts = {
        -- custom lsp configuration overrides are located in:
        -- /<nvim_folder>/lsp/*
        ensure_installed = {
            'rust_analyzer',
            'lua_ls',
            'ts_ls',
            'tailwindcss',
            'intelephense',
            'twiggy_language_server',
            'biome',
        },
        -- we automatically enable all lsp servers installed through mason. If
        -- there are servers that you'd rather manage at the system level or
        -- through another plugin, you can exclude them here.
        automatic_enable = {
            exclude = {
                'rust_analyzer',
            },
        },
    },
}
