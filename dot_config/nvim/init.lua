-- NEOVIM INIT.LUA ------------------------------------------------------------
-------------------------------------------------------------------------------

--[[

author: shane@thedragon.dev

--]]

-- CORE CONFIG ----------------------------------------------------------------
-------------------------------------------------------------------------------

require('core.theme_and_transparency')
require('core.options')
require('core.keymap')
require('core.lsp')

-- LAZY PLUGIN MANAGER --------------------------------------------------------
-------------------------------------------------------------------------------

-- Bootstrap lazy.nvim --------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim ------------------------------------------------------------

require("lazy").setup({
    spec = {
        { import = "plugins" }, -- ./lua/plugins
    },
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true },
})
