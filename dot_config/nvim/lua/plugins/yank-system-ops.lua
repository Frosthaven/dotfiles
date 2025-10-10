local local_yank_system_ops = {
    Darwin = '/Volumes/T7 Black Shield/repositories-personal/yank-system-ops.nvim/',
    Linux = '/mnt/vault/github/repositories-personal/yank-system-ops.nvim/',
    Windows_NT = 'X:/github/repositories-personal/yank-system-ops.nvim/',
    VM = '~/Github/repositories-personal/yank-system-ops.nvim/',
}

local native_clipboard = {
    Darwin = '/Volumes/T7 Black Shield/repositories-personal/native-clipboard.nvim/',
    Linux = '/mnt/vault/github/repositories-personal/native-clipboard.nvim/',
    Windows_NT = 'X:/github/repositories-personal/native-clipboard.nvim/',
    VM = '~/Github/repositories-personal/native-clipboard.nvim/',
}

local native_clipboard_path = vim.fn.expand(native_clipboard[vim.loop.os_uname().sysname])
local yank_system_ops_path = vim.fn.expand(local_yank_system_ops[vim.loop.os_uname().sysname])

if not vim.loop.fs_stat(native_clipboard_path) then
    native_clipboard_path = native_clipboard['VM']
    yank_system_ops_path = local_yank_system_ops['VM']
end


return {
    {
        dir = native_clipboard_path,
        -- 'frosthaven/native-clipboard.nvim',
        enabled = true,
        lazy = false,
        opts = {
            debug = false,
        },
        keys = {
            {
                '<leader>yc', function()
                    local clipboard = require('native_clipboard')
                    local map = clipboard.list_tag_type_map()
                    local lines = {}

                    for tag, list in pairs(map) do
                        if #list > 0 then
                            table.insert(lines, tag .. ":")
                            for _, v in ipairs(list) do
                                table.insert(lines, "  - " .. v)
                            end
                        end
                    end

                    if #lines == 0 then
                        table.insert(lines, "<clipboard is empty>")
                    end

                    vim.notify(
                        table.concat(
                            lines, "\n"),
                            vim.log.levels.DEBUG,
                            { title = 'Debug' }
                    )

                    local html = clipboard:get('html')
                    if html then
                        vim.notify(
                            clipboard:get('html'),
                            vim.log.levels.INFO,
                            { title = 'HTML' }
                        )
                    end

                    local rtf = clipboard:get('rtf')
                    if rtf then
                        vim.notify(
                            clipboard:get('rtf'),
                            vim.log.levels.INFO,
                            { title = 'RICH TEXT' }
                        )
                    end

                    local image = clipboard:get('image')
                    if image then
                        vim.notify(
                            vim.inspect({
                                data = '(blob)',
                                bytes = image.bytes,
                                extension = image.extension,
                                type = image.type,
                            }),
                            vim.log.levels.INFO,
                            { title = 'IMAGE' }
                        )

                        -- save the image to clipboard_image.png in downloads
                        -- local f = io.open(vim.fn.expand '~/Downloads/' .. 'clipboard_image.' .. image.extension, 'wb')
                        -- if f then
                        --     f:write(image.data)
                        --     f:close()
                        --     vim.notify(
                        --         'Image saved to clipboard_image.' .. image.extension,
                        --         vim.log.levels.INFO,
                        --         { title = 'IMAGE' }
                        --     )
                        -- else
                        --     vim.notify(
                        --         'Failed to save image to clipboard_image.' .. image.extension,
                        --         vim.log.levels.ERROR,
                        --         { title = 'IMAGE' }
                        --     )
                        -- end
                    end

                    local text = clipboard:get('text')
                    if text then
                        vim.notify(
                            clipboard:get('text'),
                            vim.log.levels.INFO,
                            { title = 'TEXT' }
                        )
                    end

                    local files = clipboard:get('files')
                    if files then
                        local file_list = " - " .. table.concat(files, "\n - ")
                        vim.notify(
                            file_list,
                            vim.log.levels.INFO,
                            { title = 'FILES' }
                        )
                    end

                end, desc = 'Show clipboard content',
            },
        }
    },
    {
        dir = yank_system_ops_path,
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
}
