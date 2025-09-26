-- LSP SETUP ------------------------------------------------------------------
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

-- You can move lsp server starting from the Mason plugin to here if you want
-- to manage it yourself.
--
-- vim.lsp.enable {
--     'ts_ls',
--     'lua_ls',
--     'tailwindcss',
--     'twiggy_language_server',
--     'intelephense',
-- }

-- REFRESH ON ATTACH ----------------------------------------------------------
-------------------------------------------------------------------------------

-- some language servers don't properly refresh diagnostics on initial
-- attachment. This function forces a refresh once per buffer for the
-- specified servers.

local force_refresh_wait = 250 -- ms
local force_refresh_servers = {
    'twiggy_language_server',
}

-- setup the helper
local refreshed = {}
local function force_refresh(bufnr, client, servers)
    if not vim.tbl_contains(servers, client.name) then
        return
    end
    if refreshed[bufnr] then
        return
    end
    refreshed[bufnr] = true

    vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) and not vim.bo[bufnr].modified then
            vim.cmd 'edit'
        end
    end, force_refresh_wait)
end

-- create the autocommand
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        if not ev.data or not ev.data.client_id then
            return
        end
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end

        -- Force refresh for servers in the list
        force_refresh(ev.buf, client, force_refresh_servers)
    end,
})
