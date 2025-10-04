local dev_paths = {
    Darwin = '/Volumes/T7 Black Shield/repositories-personal/yank-system-ops.nvim/',
    Linux = '/mnt/vault/github/repositories-personal/yank-system-ops.nvim/',
    Windows_NT = 'X:/github/repositories-personal/yank-system-ops.nvim/',
}

return {
    dir = dev_paths[vim.loop.os_uname().sysname],
    -- 'frosthaven/yank-system-ops.nvim',
    enabled = true,
    opts = {
        storage_path = vim.fn.expand '~/Downloads', -- path to store files
        files_to_keep = 3, -- yank_system_ops will delete older files beyond this
        debug = false,
    },
    keys = {
        -- yf : yank file(s) --------------------------------------------------
        {
            '<leader>yfz', function()
                require('yank_system_ops').yank_compressed_file()
            end, desc = 'Yank file(s) as compressed file path',
            mode = { 'n', 'v' }
        },
        {
            '<leader>yfs', function()
                require('yank_system_ops').yank_file_sharing()
            end, desc = 'Yank file(s) to system clipboard for sharing',
            mode = { 'n', 'v' }
        },
        {
            '<leader>yfe', function()
                require('yank_system_ops').extract_compressed_file()
            end, desc = 'Extract compressed file(s) here',
            mode = { 'n', 'v' }
        },
        -- yp : yank path info ------------------------------------------------
        {
            '<leader>ypr', function()
                require('yank_system_ops').yank_relative_path()
            end, desc = 'Yank relative path to file(s)',
            mode = { 'n', 'v' }
        },
        {
            '<leader>ypa', function()
                require('yank_system_ops').yank_absolute_path()
            end, desc = 'Yank absolute path to file(s)',
            mode = { 'n', 'v' }
        },
        -- yo : open buffer in external file browser --------------------------
        {
            '<leader>yo', function()
                require('yank_system_ops').open_buffer_in_file_manager()
            end, desc = 'Open current buffer in file browser',
            mode = { 'n', 'v' }
        },
        -- ym : yank markdown code block --------------------------------------
        {
            '<leader>ymc', function()
                require('yank_system_ops').yank_codeblock()
            end, desc = 'Yank line(s) as markdown code block',
            mode = { 'n', 'v' }
        },
        {
            '<leader>ymd', function()
                require('yank_system_ops').yank_diagnostics()
            end, desc = 'Yank line(s) as markdown code block with diagnostics',
            mode = { 'n', 'v' }
        },
        -- yg : yank github url -----------------------------------------------
        {
            '<leader>ygl', function()
                require('yank_system_ops').yank_github_url()
            end, desc = 'Yank line(s) as github url',
            mode = { 'n', 'v' }
        },
    }
}
