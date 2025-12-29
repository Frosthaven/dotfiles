return {
    {
        'folke/snacks.nvim',
        enabled = true,
        lazy = false,
        priority = 1000,
        -- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
        opts = {
            image = { enabled = true },
            notifier = {
                enabled = true,
                style = 'compact',
                timeout = 3000,
                top_down = true,
            },
            picker = {
                matcher = {
                    fuzzy = true,
                    smartcase = true,
                    ignorecase = true,
                    sort_empty = false,
                    file_pos = true,
                    cwd_bonus = false,
                    history_bonus = false,
                    frecency = true,
                },
            },
        },
        keys = {
            -- [s]earch
            {
                '<leader>sa',
                function()
                    require('snacks').picker { filter = { cwd = true } }
                end,
                desc = '[A]ll Pickers',
            },
            {
                '<leader>sf',
                function()
                    require('snacks').picker.smart { filter = { cwd = true } }
                end,
                desc = '[F]iles',
            },
            {
                '<leader>sg',
                function()
                    require('snacks').picker.grep { filter = { cwd = true } }
                end,
                desc = '[G]rep',
            },
            {
                '<leader>sb',
                function()
                    require('snacks').picker.buffers { filter = { cwd = true } }
                end,
                desc = '[B]uffers',
            },
            {
                '<leader>sh',
                function()
                    require('snacks').picker.help { filter = { cwd = true } }
                end,
                desc = '[H]elp Tags',
            },
            {
                '<leader>sr',
                function()
                    require('snacks').picker.recent { filter = { cwd = true } }
                end,
                desc = '[R]ecent',
            },
            {
                '<leader>sn',
                function()
                    require('snacks').notifier.show_history()
                end,
                desc = '[N]otification History',
            },
        },
        config = function(_, opts)
            require('snacks').setup(opts)
            -- extra searches on lsp attach
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('SnacksLspAttach', { clear = false }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end
                    local picker = require('snacks').picker
                    map('<leader>lt', picker.lsp_type_definitions, '[T]ypes')
                    map('<leader>ld', picker.lsp_definitions, '[D]efinitions')
                    map('<leader>lD', picker.lsp_declarations, '[D]eclarations')
                    map('<leader>li', picker.lsp_implementations, '[I]mplementations')
                    map('<leader>lr', picker.lsp_references, '[R]eferences')
                    map('<leader>ls', picker.lsp_symbols, '[S]ymbols')
                end,
            })
        end,
    },
}
