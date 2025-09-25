local pluginLoader = require 'config.plugin-loader'

local cmpDependency = (pluginLoader.useBlinkCMP and 'saghen/blink.cmp' or 'hrsh7th/cmp-nvim-lsp')
local root_dir = vim.fn.getcwd()

-- check if there is a tailwind.style.2.admin.css file in the current working directory
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

            cmpDependency, -- nvim-cmp completion engine
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
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>lh', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, 'Inlay [H]ints')
                    end
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

                    -- if client.server_capabilities.colorProvider then
                    --     require('document-color').buf_attach(event.buf)
                    -- end
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

            -- CHOOSE ONE: ----
            if pluginLoader.useBlinkCMP then
                local capabilities = require('blink.cmp').get_lsp_capabilities()
            else
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
            end

            -- ----------------

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
                -- languages --------------------------------------------------
                lua_ls = { -- lua
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                        },
                    },
                },
                ts_ls = {}, -- typescript/javascript/tsx/jsx
                eslint = {}, -- eslint
                intelephense = {}, -- php
                gopls = {}, -- go
                pyright = {}, -- python
                rust_analyzer = {}, -- rust

                -- templating & styling ---------------------------------------
                twiggy_language_server = {}, -- twig
                -- tailwindcss = {},

                -- configuration/data files -----------------------------------
                jsonls = {}, -- json

                -- formatting -------------------------------------------------
                prettierd = {}, -- prettier
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
                        -- dont setup tailwindcss/tailwind-language-server - managed by tailwind-tools.nvim
                        if server_name == 'tailwindcss' or server_name == 'tailwind-language-server' then
                            -- do nothing
                        else
                            require('lspconfig')[server_name].setup(server)
                        end
                    end,
                },
            }
        end,
    },
    {
        -- AUTOMATIC lua language server configuration
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },

    {
        -- Automatic tailwind language server configuration
        'luckasRanarison/tailwind-tools.nvim',
        name = 'tailwind-tools',
        build = ':UpdateRemotePlugins',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {
            server = {
                override = true, -- setup the server from the plugin if true
                settings = { -- shortcut for `settings.tailwindCSS`
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
                    experimental = {
                        configFile = {
                            -- new project layout
                            ['assets/app.tailwind.css'] = {
                                'assets/react/web/**',
                                'templates/web/**',
                                'src/Controller/Web/**',
                            },
                            ['assets/admin.tailwind.css'] = {
                                'assets/react/admin/**',
                                'templates/admin/**',
                                'src/Controller/Admin/**',
                            },
                        },
                        classRegex = {
                            -- 1) Twig `{% set name = '...' %}`:
                            { [[{%\s*set\s+\w+\s*=\s*([^%]*)%}]], [[(?:'|")([^'"]*)(?:'|")]] },
                        },
                    },
                },
            },
            document_color = {
                enabled = true, -- can be toggled by commands
                kind = 'inline', -- "inline" | "foreground" | "background"
                inline_symbol = '󰝤 ', -- only used in inline mode
                debounce = 200, -- in milliseconds, only applied in insert mode
            },
            conceal = {
                enabled = false, -- can be toggled by commands
                min_length = nil, -- only conceal classes exceeding the provided length
                symbol = '󱏿', -- only a single character is allowed
                highlight = { -- extmark highlight options, see :h 'highlight'
                    fg = '#38BDF8',
                },
            },
            keymaps = {
                smart_increment = { -- increment tailwindcss units using <C-a> and <C-x>
                    enabled = false,
                    units = { -- see lua/tailwind/units.lua to see all the defaults
                        {
                            prefix = 'border',
                            values = { '2', '4', '6', '8' },
                        },
                    },
                },
            },
            cmp = {
                highlight = 'foreground', -- color preview style, "foreground" | "background"
            },
        },
    },

    -- Formatter
    {
        'nvimtools/none-ls.nvim',
        event = 'VeryLazy',
        opts = function()
            local null_ls = require 'null-ls'
            local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
            return {
                sources = {
                    null_ls.builtins.formatting.prettierd,
                },
                on_attach = function(client, bufnr)
                    if client.supports_method 'textDocument/formatting' then
                        vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format { bufnr = bufnr }
                            end,
                        })
                    end
                end,
            }
        end,
    },
}
