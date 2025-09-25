local pluginLoader = require 'config.plugin-loader'

local root_dir = vim.fn.getcwd()
local useBlinkCMP = pluginLoader.useBlinkCMP

-- Detect Tailwind config and optional admin CSS
local configFile = { 'tailwind.config.js' }
local hasAdminCss = vim.fn.filereadable(root_dir .. '/tailwind.2.admin.css') == 1
if hasAdminCss then
    configFile = {
        ['tailwind.2.admin.css'] = {
            'assets/local-assets/react/admin/**',
            'templates/admin/**',
            'templates/bundles/EasyAdminBundle/**',
            'src/Controller/Admin/**',
        },
        ['tailwind.1.app.css'] = { '**/*' },
    }
end

-- Define LSP capabilities manually (without cmp_nvim_lsp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem = {
    snippetSupport = true,
    commitCharactersSupport = true,
    documentationFormat = { 'markdown', 'plaintext' },
    deprecatedSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    resolveSupport = { properties = { 'documentation', 'detail', 'additionalTextEdits' } },
    insertTextModeSupport = { valueSet = { 1, 2 } },
}

-- If using Blink CMP, merge its capabilities
if useBlinkCMP then
    local blink_ok, blink = pcall(require, 'blink.cmp')
    if blink_ok then
        capabilities = blink.get_lsp_capabilities()
    end
end

return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim', opts = {} },
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            { 'j-hui/fidget.nvim', opts = {} },
        },
        config = function()
            -- LSP Attach: buffer-local keymaps and highlights
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
                callback = function(event)
                    local buf = event.buf
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = buf, desc = 'LSP: ' .. desc })
                    end

                    map('<leader>ln', vim.lsp.buf.rename, 'Re[n]ame')
                    map('<leader>la', vim.lsp.buf.code_action, 'Code [A]ction')
                    map('<leader>lA', vim.lsp.buf.code_action, 'Code [A]ction (extra)', { 'n', 'x' })

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>lh', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
                        end, 'Inlay [H]ints')
                    end

                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = buf,
                            group = highlight_group,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = buf,
                            group = highlight_group,
                            callback = vim.lsp.buf.clear_references,
                        })
                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                            callback = function(ev)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = ev.buf }
                            end,
                        })
                    end
                end,
            })

            -- LSP servers and their options
            local servers = {
                lua_ls = { settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
                ts_ls = {},
                eslint = {},
                intelephense = {},
                gopls = {},
                pyright = {},
                rust_analyzer = {},
                twiggy_language_server = {},
                jsonls = {},
                prettierd = {},
                tailwindcss = {
                    settings = {
                        includeLanguages = {
                            elixir = 'phoenix-heex',
                            heex = 'phoenix-heex',
                            html = 'html',
                            javascript = 'javascript',
                            javascriptreact = 'javascriptreact',
                            typescript = 'typescript',
                            typescriptreact = 'typescriptreact',
                            svelte = 'svelte',
                            vue = 'vue',
                            twig = 'html',
                        },
                        experimental = { configFile = configFile },
                    },
                },
            }

            -- Ensure LSP tools installed via Mason
            local ensure_installed = vim.tbl_keys(servers)
            vim.list_extend(ensure_installed, { 'stylua', 'tailwindcss-language-server' })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            -- Setup LSP servers using new vim.lsp.start()
            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                        local config = servers[server_name] or {}
                        config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
                        vim.lsp.configs[server_name] = vim.lsp.configs[server_name] or {}
                        vim.lsp.start { name = server_name, config = config }
                    end,
                },
            }

            -- Diagnostics
            local diag_opts = {
                virtual_text = true,
                virtual_lines = false,
                float = {
                    border = 'single',
                    format = function(d)
                        return string.format('%s (%s) [%s]', d.message, d.source, d.code or (d.user_data.lsp and d.user_data.lsp.code))
                    end,
                },
                underline = true,
                update_in_insert = true,
                severity_sort = true,
            }

            if vim.g.have_nerd_font then
                local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
                local diagnostic_signs = {}
                for t, icon in pairs(signs) do
                    diagnostic_signs[vim.diagnostic.severity[t]] = icon
                end
                diag_opts.signs = { text = diagnostic_signs }
            end

            vim.diagnostic.config(diag_opts)
        end,
    },

    -- Lua dev tooling
    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },
}
