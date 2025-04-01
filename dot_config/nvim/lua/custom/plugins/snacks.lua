return {
    {
        'folke/snacks.nvim',
        enable = true,
        -- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
        opts = {
            picker = {}, -- using defaults for now
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
        keys = {
            -- [s]earch
            {
                '<leader>sa',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker()
                end,
                desc = '[S]earch With [A]ll Pickers',
            },
            {
                '<leader>sf',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.smart()
                end,
                desc = '[S]earch [F]iles',
            },
            {
                '<leader>sg',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.grep()
                end,
                desc = '[S]earch [G]rep',
            },
            {
                '<leader>sb',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.buffers()
                end,
                desc = '[S]earch [B]uffers',
            },
            {
                '<leader>sh',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.help()
                end,
                desc = '[S]earch [H]elp Tags',
            },
            {
                '<leader>sr',
                function()
                    Snacks = require 'snacks'
                    Snacks.picker.recent()
                end,
                desc = '[S]earch [R]ecent',
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
                    map('<leader>slt', Snacks.picker.lsp_type_definitions, '[S]earch [L]SP [T]ypes')
                    map('<leader>sld', Snacks.picker.lsp_definitions, '[S]earch [L]SP [D]efinitions')
                    map('<leader>slD', Snacks.picker.lsp_declarations, '[S]earch [L]SP [D]eclarations')
                    map('<leader>sli', Snacks.picker.lsp_implementations, '[S]earch [L]SP [I]mplementations')
                    map('<leader>slr', Snacks.picker.lsp_references, '[S]earch [L]SP [R]eferences')
                    map('<leader>sls', Snacks.picker.lsp_symbols, '[S]earch [L]SP [S]ymbols')
                end,
            })
        end,
    },
}
