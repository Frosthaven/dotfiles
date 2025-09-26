return {
    "mason-org/mason-lspconfig.nvim",
    enabled = true,
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    opts = {
        automatic_enable = true,
        -- lsp configurations are located in: /<nvim_folder>/lsp/*
        ensure_installed = {
            "lua_ls",
            "ts_ls",
            "tailwindcss",
            "intelephense",
            "twiggy_language_server",
            "stylua",
        },
    },
}
