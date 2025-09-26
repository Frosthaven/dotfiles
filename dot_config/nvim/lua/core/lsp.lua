-- LANGUAGE SERVERS -----------------------------------------------------------
-------------------------------------------------------------------------------

--[[

Although language servers can be installed through Mason, sometimes you need
to install one locally and run it separate from neovim. This is where you
configure the LSP client to connect to that server.

Here are some examples of how to install language servers globally:

    pnpm install -g tailwindcss-language-server
    pnpm install -g intelephense
    pnpm install -g prettier
    pnpm install -g -twiggy-language-server
    pnpm install -g typescript typescript-language-server

    pacman -Syu lua-language-server
    brew install lua-language-server
    choco install lua-language-server

--]]

vim.lsp.enable({
    'typescript-language-server',
    'lua-language-server',
    'tailwindcss-language-server',
    'twiggy-language-server',
    'intelephense',
})
