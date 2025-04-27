return {
    {
        -- Main LSP Configuration
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            -- Mason must be loaded before its dependents so we need to set it up here.
            -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
            { 'williamboman/mason.nvim', opts = {} },
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Useful status updates for LSP.
            { 'j-hui/fidget.nvim', opts = {} },

            -- Allows extra capabilities provided by nvim-cmp
            -- 'hrsh7th/cmp-nvim-lsp',
            -- Allows extra capabilities provided by blink
            'saghen/blink.cmp',
        },
        config = function()
            -- Brief aside: **What is LSP?**
            --
            -- LSP is an initialism you've probably heard, but might not understand what it is.
            --
            -- LSP stands for Language Server Protocol. It's a protocol that helps editors
            -- and language tooling communicate in a standardized fashion.
            --
            -- In general, you have a "server" which is some tool built to understand a particular
            -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
            -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
            -- processes that communicate with some "client" - in this case, Neovim!
            --
            -- LSP provides Neovim with features like:
            --  - Go to definition
            --  - Find references
            --  - Autocompletion
            --  - Symbol Search
            --  - and more!
            --
            -- Thus, Language Servers are external tools that must be installed separately from
            -- Neovim. This is where `mason` and related plugins come into play.
            --
            -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
            -- and elegantly composed help section, `:help lsp-vs-treesitter`

            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                    -- to define small helper and utility functions so you don't have to repeat yourself.
                    --
                    -- In this case, we create a function that lets us more easily define mappings specific
                    -- for LSP related items. It sets the mode, buffer and description for us each time.
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    -- Jump to the definition of the word under your ursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.

                    -- Find references for the word under your cursor.
                    map('<leader>ln', vim.lsp.buf.rename, 'Re[n]ame')
                    map('<leader>la', vim.lsp.buf.code_action, 'Code [A]ction')
                    map('<leader>lA', vim.lsp.buf.code_action, 'Code [A]ction (extra)', { 'n', 'x' })

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>lh', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, 'Inlay [H]ints')
                    end
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end
                end,
            })

            -- Configure diagnostic messages
            vim.diagnostic.config {
                virtual_lines = {
                    current_line = true,
                },
                -- float = {
                --     border = 'single',
                --     format = function(diagnostic)
                --         return string.format('%s (%s) [%s]', diagnostic.message, diagnostic.source, diagnostic.code or diagnostic.user_data.lsp.code)
                --     end,
                -- },
                underline = true,
                update_in_insert = true,
                severity_sort = true,
            }

            -- Change diagnostic symbols in the sign column (gutter)
            if vim.g.have_nerd_font then
                local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
                local diagnostic_signs = {}
                for type, icon in pairs(signs) do
                    diagnostic_signs[vim.diagnostic.severity[type]] = icon
                end
                vim.diagnostic.config { signs = { text = diagnostic_signs } }
            end

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.

            -- CHOOSE ONE:
            --  capabilites: nvim-cmp *****************************************

            -- local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

            -- capabilities: blink ********************************************

            local capabilities = require('blink.cmp').get_lsp_capabilities()
            require('lspconfig').lua_ls.setup { capabilities = capabilities }

            -- ****************************************************************

            -- Enable the following language servers
            --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
            --
            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            local servers = {
                eslint = {},
                intelephense = {},
                -- psalm = {},
                jsonls = {},
                -- clangd = {},
                gopls = {},
                pyright = {},
                twiggy_language_server = {},
                -- rust_analyzer = {},
                -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
                --
                -- Some languages (like typescript) have entire language plugins that can be useful:
                --    https://github.com/pmizio/typescript-tools.nvim
                --
                -- But for many setups, the LSP (`ts_ls`) will work just fine
                ts_ls = {},
                tailwindcss = {},
                --

                lua_ls = {
                    -- cmd = { ... },
                    -- filetypes = { ... },
                    -- capabilities = {},
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                            -- diagnostics = { disable = { 'missing-fields' } },
                        },
                    },
                },
            }

            -- Ensure the servers and tools above are installed
            --
            -- To check the current status of installed tools and/or manually install
            -- other tools, you can run
            --    :Mason
            --
            -- You can press `g?` for help in this menu.
            --
            -- `mason` had to be setup earlier: to configure its options see the
            -- `dependencies` table for `nvim-lspconfig` above.
            --
            -- You can add other tools here that you want Mason to install
            -- for you, so that they are available from within Neovim.
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua', -- Used to format Lua code
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        -- This handles overriding only values explicitly passed
                        -- by the server configuration above. Useful when disabling
                        -- certain features of an LSP (for example, turning off formatting for ts_ls)
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            }
        end,
    },
    {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },
}
