local dev_paths = {
    Darwin = '/Volumes/T7 Black Shield/repositories-personal/yank-more.nvim/',
    Linux = '/mnt/vault/github/repositories-personal/yank-more.nvim/',
    Windows_NT = 'X:/github/repositories-personal/yank-more.nvim/',
}

return {
    dir = dev_paths[vim.loop.os_uname().sysname],
    enabled = true,
    lazy = false,
    opts = {
        storage_path = vim.fn.expand '~/Downloads',
        files_to_keep = 3,
        debug = true,
    },
    config = function(_, opts)
        vim.notify('Loading yank-more.nvim from ' .. dev_paths[vim.loop.os_uname().sysname], vim.log.levels.DEBUG)
        require('yank_more').setup(opts)
    end,
}
