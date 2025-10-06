local dev_paths = {
    Darwin = '/Volumes/T7 Black Shield/repositories-personal/yank-system-ops.nvim/',
    Linux = '/mnt/vault/github/repositories-personal/yank-system-ops.nvim/',
    Windows_NT = 'X:/github/repositories-personal/yank-system-ops.nvim/',
}

return {
    dir = dev_paths[vim.loop.os_uname().sysname],
    -- 'frosthaven/yank-system-ops.nvim',
    enabled = true,
    lazy = false,
    opts = {
        storage_path = vim.fn.expand '~/Downloads', -- path to store files
        files_to_keep = 3, -- yank_system_ops will delete older files beyond this
        debug = false,
    },
    keys = {
        -- 🧷 yank & put file(s) ----------------------------------------------
        {
            '<leader>yy', function()
                require('yank_system_ops').yank_files_to_clipboard()
            end, desc = 'Yank file(s) to system clipboard',
            mode = { 'n', 'v' }
        },
        {
            '<leader>yp', function()
                require('yank_system_ops').put_files_from_clipboard()
            end, desc = 'Put clipboard file(s) here',
            mode = { 'n', 'v' }
        },
        -- 📥 Put / Extract files -------------------------------------------------
        {
            '<leader>yz', function()
                require('yank_system_ops').zip_files_to_clipboard()
            end, desc = 'Zip file(s) to clipboard',
            mode = { 'n', 'v' }
        },
        {
            '<leader>ye', function()
                require('yank_system_ops').extract_files_from_clipboard()
            end, desc = 'Extract clipboard file here',
            mode = { 'n', 'v' }
        },
        -- 📂 Path info -----------------------------------------------------------
        {
            '<leader>yr', function()
                require('yank_system_ops').yank_relative_path()
            end, desc = 'Yank relative path to file(s)',
            mode = { 'n', 'v' }
        },
        {
            '<leader>ya', function()
                require('yank_system_ops').yank_absolute_path()
            end, desc = 'Yank absolute path to file(s)',
            mode = { 'n', 'v' }
        },

        -- 🌐 Open in file browser ------------------------------------------------
        {
            '<leader>yo', function()
                require('yank_system_ops').open_buffer_in_file_manager()
            end, desc = 'Open current buffer in system file browser',
            mode = { 'n', 'v' }
        },

        -- 🪄 Markdown codeblocks -------------------------------------------------
        {
            '<leader>ymc', function()
                require('yank_system_ops').yank_codeblock()
            end, desc = 'Yank line(s) as markdown code block',
            mode = { 'n', 'v' }
        },
        {
            '<leader>ymd', function()
                require('yank_system_ops').yank_diagnostics()
            end, desc = 'Yank line(s) as markdown code block w/ diagnostics',
            mode = { 'n', 'v' }
        },

        -- 🧭 GitHub URL ----------------------------------------------------------
        {
            '<leader>ygl', function()
                require('yank_system_ops').yank_github_url()
            end, desc = 'Yank current line(s) as GitHub URL',
            mode = { 'n', 'v' }
        },
    }
}
