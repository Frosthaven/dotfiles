local dev_paths = {
    Darwin = '/Volumes/T7 Black Shield/repositories-personal/yank-more.nvim/',
    Linux = '/mnt/vault/github/repositories-personal/yank-more.nvim/',
    Windows_NT = 'X:/github/repositories-personal/yank-more.nvim/',
}

return {
    --dir = dev_paths[vim.loop.os_uname().sysname],
    'frosthaven/yank-more.nvim',
    enabled = true,
    lazy = false,
    opts = {
        storage_path = vim.fn.expand '~/Downloads',
        files_to_keep = 3,
        debug = true,
    },
    config = function(_, opts)
        vim.notify('Loading yank-more.nvim from ' .. dev_paths[vim.loop.os_uname().sysname], vim.log.levels.DEBUG)

        local yank_more = require 'yank_more'
        yank_more.setup(opts)

        -- Yank into Markdown Code Block ----------------------------------------------

        vim.keymap.set({ 'n', 'v' }, '<leader>yc', yank_more.yank_codeblock, { desc = '[Y]ank as [C]ode block' })

        -- Yank File Path -------------------------------------------------------------

        vim.keymap.set({ 'n', 'v' }, '<leader>yr', yank_more.yank_relative_path, { desc = '[Y]ank [R]elative path of file' })
        vim.keymap.set({ 'n', 'v' }, '<leader>ya', yank_more.yank_absolute_path, { desc = '[Y]ank [A]bsolute path of file' })

        -- Yank Diagnostic Messaging --------------------------------------------------

        vim.keymap.set({ 'n', 'v' }, '<leader>yd', yank_more.yank_diagnostics, { desc = '[Y]ank [D]iagnostic code block' })

        -- Yank Github URL For Line(s) ------------------------------------------------

        vim.keymap.set({ 'n', 'v' }, '<leader>yg', yank_more.yank_github_url, { desc = '[Y]ank [G]itHub URL for current line(s)' })

        -- Yank as NVIM Zip File Path -------------------------------------------------

        vim.keymap.set({ 'n', 'v' }, '<leader>yz', yank_more.yank_compressed_file, { desc = '[Y]ank as [Z]ip file' })

        -- Yank as NVIM Zip File Binary -----------------------------------------------

        vim.keymap.set({ 'n', 'v' }, '<leader>yb', yank_more.yank_file_binary, { desc = '[Y]ank as Zip [B]inary file' })

        -- Open Buffer in External File Browser ---------------------------------------

        vim.keymap.set('n', '<leader>o', yank_more.open_buffer_in_file_manager, { desc = '[O]pen in external file browser' })

        -- Paste NVIM Zip File --------------------------------------------------------

        vim.keymap.set('n', '<leader>pz', yank_more.paste_compressed_file, { desc = '[Z]ip file [P]aste' })
    end,
}
