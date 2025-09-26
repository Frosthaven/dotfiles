return {
    {
        'folke/snacks.nvim',
        enabled = true,
        -- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
        opts = {
            image = {},
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
                    Snacks = require 'snacks'
                    Snacks.picker()
                end,
                desc = '[A]ll Pickers',
            },
            {
                '<leader>sf',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.smart()
                end,
                desc = '[F]iles',
            },
            {
                '<leader>sg',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.grep()
                end,
                desc = '[G]rep',
            },
            {
                '<leader>sb',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.buffers()
                end,
                desc = '[B]uffers',
            },
            {
                '<leader>sh',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.help()
                end,
                desc = '[H]elp Tags',
            },
            {
                '<leader>sr',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.recent()
                end,
                desc = '[R]ecent',
            },
        },
        config = function()
            -- extra searches on lsp attach
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('SnacksLspAttach', { clear = false }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end
                    Snacks = require 'snacks'
                    map('<leader>lt', Snacks.picker.lsp_type_definitions, '[T]ypes')
                    map('<leader>ld', Snacks.picker.lsp_definitions, '[D]efinitions')
                    map('<leader>lD', Snacks.picker.lsp_declarations, '[D]eclarations')
                    map('<leader>li', Snacks.picker.lsp_implementations, '[I]mplementations')
                    map('<leader>lr', Snacks.picker.lsp_references, '[R]eferences')
                    map('<leader>ls', Snacks.picker.lsp_symbols, '[S]ymbols')
                end,
            })
        end,
    },
}
