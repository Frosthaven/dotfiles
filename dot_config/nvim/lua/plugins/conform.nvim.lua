return {
    { -- Autoformat on save
        enabled = true,
        'stevearc/conform.nvim',
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        keys = {
            {
                '<leader>f',
                function()
                    require('conform').format { async = true, lsp_format = 'fallback' }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = { c = true, cpp = true }
                local lsp_format_opt
                if disable_filetypes[vim.bo[bufnr].filetype] then
                    lsp_format_opt = 'never'
                else
                    lsp_format_opt = 'fallback'
                end
                return {
                    timeout_ms = 500,
                    lsp_format = lsp_format_opt,
                }
            end,
            formatters_by_ft = {
                lua = { 'stylua' },
                javascript = { 'biome_check', 'prettierd', 'prettier', stop_after_first = true },
                javascriptreact = { 'biome_check', 'prettierd', 'prettier', stop_after_first = true },
                typescript = { 'biome_check', 'prettierd', 'prettier', stop_after_first = true },
                typescriptreact = { 'biome_check', 'prettierd', 'prettier', stop_after_first = true },
                json = { 'biome_check', 'prettierd', 'prettier', stop_after_first = true },
                jsonc = { 'biome_check', 'prettierd', 'prettier', stop_after_first = true },
                css = { 'biome_check', 'prettierd', 'prettier', stop_after_first = true },
            },
            formatters = {
                biome = {
                    command = function(self, ctx)
                        local root = vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
                            upward = true,
                            path = ctx and ctx.dirname or vim.fn.getcwd(),
                        })[1]
                        if root then
                            local project_dir = vim.fn.fnamemodify(root, ':h')
                            local local_biome = project_dir .. '/node_modules/.bin/biome'
                            if vim.fn.executable(local_biome) == 1 then
                                return local_biome
                            end
                        end
                        return 'biome'
                    end,
                    condition = function(self, ctx)
                        return vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
                            upward = true,
                            path = ctx.dirname,
                        })[1] ~= nil
                    end,
                },
                biome_check = {
                    args = { 'check', '--write', '--stdin-file-path', '$FILENAME' },
                    command = function(self, ctx)
                        local root = vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
                            upward = true,
                            path = ctx and ctx.dirname or vim.fn.getcwd(),
                        })[1]
                        if root then
                            local project_dir = vim.fn.fnamemodify(root, ':h')
                            local local_biome = project_dir .. '/node_modules/.bin/biome'
                            if vim.fn.executable(local_biome) == 1 then
                                return local_biome
                            end
                        end
                        return 'biome'
                    end,
                    condition = function(self, ctx)
                        return vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
                            upward = true,
                            path = ctx.dirname,
                        })[1] ~= nil
                    end,
                },
            },
        },
    },
}
