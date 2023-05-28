-- Bootstrap Packer ************************************************************
--******************************************************************************

-- Automatically install packer
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
    print("Installing packer close and reopen Neovim...")
    vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the packer.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    },
})

-- Plugins *********************************************************************
--******************************************************************************

-- Install your plugins here
return packer.startup(function(use)
    use 'glepnir/dashboard-nvim'            -- dashboard
    use 'norcalli/nvim_utils'               -- nvim utilities
    use "wbthomason/packer.nvim"            -- self-managed packer
    use 'mrjones2014/smart-splits.nvim'     -- smart splits
    use {                                   -- key legends
      "folke/which-key.nvim",
      config = function()
        require("which-key").setup {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        }
      end
    }
    use 'navarasu/onedark.nvim'             -- editor theme
    use {'nvim-lualine/lualine.nvim',       -- status bar
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true
        }
    }
    use({'mvllow/modes.nvim',               -- mode change for colors
        tag = 'v0.2.0'
    })
    use {                                   -- blank line indention guides
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require('indent_blankline').setup {
                filetype_exclude = { "dashboard" }
            }
        end
    }
    use 'tpope/vim-sleuth'                  -- semi-automatic indent style
    use 'editorconfig/editorconfig-vim'     -- .editorconfig support
    use 'nvim-treesitter/nvim-treesitter'   -- syntax highlighting
    use {                                   -- treesitter text objects
	'nvim-treesitter/nvim-treesitter-textobjects',
	    after = { 'nvim-treesitter' }
    }

    use {'rrethy/vim-hexokinase',           -- color code highlighting
        run = 'cd ~/.local/share/nvim/site/pack/packer/start/vim-hexokinase && make hexokinase cd ~/AppData/local/nvim-data/site/pack/packer/start/vim-hexokinase && make hexokinase'
    }
    use 'nvim-treesitter/playground'        -- playground for treesitter
    use 'p00f/nvim-ts-rainbow'              -- tree sitter rainbow brackets
    use "arnamak/stay-centered.nvim"        -- keep cursor centered vertically
    use "rlane/pounce.nvim"                 -- alternative to lightspeed
    -- use "tpoppe/vim-repeat"                 -- allows you to repeat the last action
    --[[ use {'ggandor/lightspeed.nvim',         -- faster page nav with 's'
        requires = {
            "tpope/vim-repeat",
            opt = true
        }
    } ]]
    use 'b3nj5m1n/kommentary'               -- comment toggling
    use 'ThePrimeagen/harpoon'              -- pinning/marking files for nav
    use 'jiangmiao/auto-pairs'              -- automatic <({['" closing
    use ({                                  -- add/change/delete surrounding
        'kylechui/nvim-surround',
        tag = '*',
        config = function ()
            require('nvim-surround').setup()
        end
    })
    use({                                   -- yank and put improvements
        "gbprod/yanky.nvim",
        config = function()
            require("yanky").setup({
                ring = {
                    history_length = 100,
                    storage = "shada",
                    sync_with_numbered_registers = true,
                    cancel_event = "update",
                },
                picker = {
                    select = {
                        action = nil, -- nil to use default put action
                    },
                    telescope = {
                        mappings = nil, -- nil to use default mappings
                    },
                },
                system_clipboard = {
                    sync_with_ring = true,
                },
                highlight = {
                    on_put = true,
                    on_yank = true,
                    timer = 500,
                },
                preserve_cursor_position = {
                    enabled = true,
                },
            })
        end
    })
    use {"akinsho/toggleterm.nvim",         -- terminal
        tag = '*', config = function()
            require("toggleterm").setup{
                start_in_insert = false,
            }
        end
    }
    use { 'nvim-telescope/telescope.nvim',  -- telescope and fuzzy searching
        branch = '0.1.x',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use { 'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make',
        cond = vim.fn.executable "make" == 1
    }
    use { 'nvim-telescope/telescope-file-browser.nvim' }

    use { "ahmedkhalf/project.nvim",        -- project manager
        config = function()
        require("project_nvim").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            patterns = { ".git", ".idea", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
            detection_methods = {"lsp", "pattern"},
            show_hidden = true,
        }
        end
    }
    use 'tpope/vim-fugitive'                -- git commands in nvim
    use 'tpope/vim-rhubarb'                 -- fugitive github integrations
    use { 'lewis6991/gitsigns.nvim',        -- git info in columns and popups
        requires = {
            'nvim-lua/plenary.nvim'
        }
    }

    use 'github/copilot.vim'                -- github copilot

    use({                                   -- CMP completion engine
    	"hrsh7th/nvim-cmp",
        requires = {
            "onsails/lspkind-nvim",     -- Icons on the popups
            "hrsh7th/cmp-nvim-lsp",     -- LSP source for nvim-cmp
            "saadparwaiz1/cmp_luasnip", -- Snippets source
            "L3MON4D3/LuaSnip",         -- Snippet engine
        },
        config = function()
            require("frosthaven.cmp")
        end,
    })

    use({                                   -- LSP Server Manager
        "neovim/nvim-lspconfig",
        requires = {
            "williamboman/nvim-lsp-installer", -- Installs servers
            "onsails/lspkind-nvim",            -- adds pictograms to lsp
        },
        config = function()
            require("frosthaven.lsp")
        end,
    })

    -- html5 and twig support
    use 'nelsyeung/twig.vim'
    use 'othree/html5.vim'

    -- use system clipboard (might need clipboard software for linux)
    vim.cmd('set clipboard^=unnamed,unnamedplus');

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end

-- Setup ***********************************************************************
--******************************************************************************
    -- stay centered
    require("stay-centered")

    -- smart splits setup
    require('smart-splits').setup({
      resize_mode = {
        silent = true,
        hooks = {
            on_enter = function() vim.notify('Entering resize mode') end,
            on_leave = function() vim.notify('Exiting resize mode, bye') end
        }
      }
    })

    -- load fuzzy search native module if it exists
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'file_browser')

    -- telescope
    require('telescope').setup{
      defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        mappings = {
          i = {
            -- map actions.which_key to <C-h> (default: <C-/>)
            -- actions.which_key shows the mappings for your picker,
            -- e.g. git_{create, delete, ...}_branch for the git_branches picker
            ["<C-h>"] = "which_key"
          }
        }
      },
      pickers = {
            find_files = {
                hidden = true,
            },
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
      },
      extensions = {
        file_browser = {
              theme = "ivy",
              -- disables netrw and use telescope-file-browser in its place
              hijack_netrw = true,
              mappings = {
                ["i"] = {
                  -- your custom insert mode mappings
                },
                ["n"] = {
                  -- your custom normal mode mappings
                },
              },
            },
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
      }
    }
    -- comment line behaviors
    require('kommentary.config').configure_language("rust", {
        single_line_comment_string = "//",
        multi_line_comment_strings = {"/*", "*/"},
    })
    require('kommentary.config').configure_language("javascript", {
        single_line_comment_string = "//",
        multi_line_comment_strings = {"/*", "*/"},
    })
    require('kommentary.config').configure_language("typescript", {
        single_line_comment_string = "//",
        multi_line_comment_strings = {"/*", "*/"},
    })
    require('kommentary.config').configure_language("php", {
        single_line_comment_string = "//",
        multi_line_comment_strings = {"/*", "*/"},
    })

    -- nvim-cmp setup
    -- @TODO not sure how to avoid the LSP error here. something about namespace
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup {
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert {
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            },
            ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { 'i', 's' }),
        },
        sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        },
    }

    -- harpoon
    require("harpoon").setup({
        menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
        }
    })
    require('telescope').load_extension('harpoon')

    -- tree sitter
    -- compile differently on windows
    if (vim.loop.os_uname().sysname == "Windows_NT") then
        require 'nvim-treesitter.install'.compilers = { 'zig' } -- @todo make win only
    end

    require("nvim-treesitter.configs").setup {
        ensure_installed = {'c','cpp','go','typescript','python','rust','php','query'},
        highlight = {
            enabled = true
        },
        rainbow = {
            enable = true,
            -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
            extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            max_file_lines = nil, -- Do not enable for files with more than n lines, int
            -- colors = {}, -- table of hex strings
            -- termcolors = {} -- table of colour name strings
        },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = '<c-space>',
              node_incremental = '<c-space>',
              -- TODO: I'm not sure for this one.
              scope_incremental = '<c-s>',
              node_decremental = '<c-backspace>',
            },
        },
          textobjects = {
            select = {
              enable = true,
              lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
              },
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
              },
              goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
              },
              goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
              },
              goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
              },
            },
            swap = {
              enable = true,
              swap_next = {
                ['<leader>a'] = '@parameter.inner',
              },
              swap_previous = {
                ['<leader>A'] = '@parameter.inner',
              },
            },
          },
    }

    -- autocmd section
    local function nvim_create_augroups(definitions)
        for group_name, definition in pairs(definitions) do
            vim.api.nvim_command('augroup '..group_name)
            vim.api.nvim_command('autocmd!')
            for _, def in ipairs(definition) do
                local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
                vim.api.nvim_command(command)
            end
            vim.api.nvim_command('augroup END')
        end
    end

    -- automatically increase/decrease terminal emulator padding
    function Sad(line_nr, from, to, fname)
        vim.cmd(string.format("silent !sed -i '%ss/%s/%s/' %s", line_nr, from, to, fname))
    end

    vim.g.IncreasePadding = function ()
      Sad('03', 0, 20, '~/.config/alacritty/alacritty.padding.yml')
      Sad('04', 0, 20, '~/.config/alacritty/alacritty.padding.yml')
    end

    vim.g. DecreasePadding = function ()
      Sad('03', 20, 0, '~/.config/alacritty/alacritty.padding.yml')
      Sad('04', 20, 0, '~/.config/alacritty/alacritty.padding.yml')
    end

    local auto_kitty = {
      todo = {
        { "VimEnter", "*", ":silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=0 margin=0" };
        { "VimLeave", "*", ":silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=20 margin=10" };
      };
    }

    local auto_cursor_restore = { -- should restore vertical beam cursor on exit
        todo = {
            { "VimLeave", "*", "set guicursor=a:ver90-blinkon1" };
        };
    }
    nvim_create_augroups(auto_kitty)
    nvim_create_augroups(auto_cursor_restore)
end)
