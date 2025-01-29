local M = {}

M.setup = function()
    -- [[ Install `lazy.nvim` plugin manager ]]
    --    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvimtfor more info
    local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
        local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
        if vim.v.shell_error ~= 0 then
            error('Error cloning lazy.nvim:\n' .. out)
        end
    end ---@diagnostic disable-next-line: undefined-field
    vim.opt.rtp:prepend(lazypath)

    -- [[ Configure and install plugins ]]
    require('lazy').setup({
        { import = 'custom.plugins' }, -- imports everytihing from /lua/custom/plugins
    }, {
        ui = {
            icons = {}, -- empty table since we have nerd fonts
            --[[
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
    --]]
        },
    })
end

return M
