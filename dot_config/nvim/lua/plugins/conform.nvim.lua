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
                javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
                javascriptreact = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
                typescript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
                typescriptreact = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
                json = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
                jsonc = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
                css = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
            },
            formatters = {
                biome = {
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
