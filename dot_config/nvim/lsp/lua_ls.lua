return {
    cmd = { "lua-language-server" },
    filetypes = {
        "lua"
    },
    root_markers = {
        ".git",
        ".luacheckrc",
        ".luarc.json",
        "luarc.jsonc",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        "stylua.toml"
    },
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ";"),
            },
            diagnostics = {
                globals = { "vim" },
                disable = { "lowercase-global" },
            },
            workspace = {
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
            telemetry = {
                enable = false,
            },
        },
    },
}
