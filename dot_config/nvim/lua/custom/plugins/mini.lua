return {
    { -- Collection of various small independent plugins/modules
        'echasnovski/mini.nvim',
        config = function()
            -- Better Around/Inside textobjects
            --
            -- Examples:
            --  - va)  - [V]isually select [A]round [)]paren
            --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
            --  - ci'  - [C]hange [I]nside [']quote
            require('mini.ai').setup { n_lines = 500 }

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            require('mini.surround').setup()

            require('mini.files').setup {
                -- Customization of shown content
                content = {
                    -- Predicate for which file system entries to show
                    filter = nil,
                    -- What prefix to show to the left of file system entry
                    prefix = nil,
                    -- In which order to show file system entries
                    sort = nil,
                },

                -- Module mappings created only inside explorer.
                -- Use `''` (empty string) to not create one.
                mappings = {
                    close = 'q',
                    go_in = 'l',
                    go_in_plus = '<right>',
                    go_out = 'h',
                    go_out_plus = '<left>',
                    mark_goto = "'",
                    mark_set = 'm',
                    reset = '<BS>',
                    reveal_cwd = '@',
                    show_help = 'g?',
                    synchronize = '=',
                    trim_left = '<',
                    trim_right = '>',
                },

                -- General options
                options = {
                    -- Whether to delete permanently or move into module-specific trash
                    permanent_delete = true,
                    -- Whether to use for editing directories
                    use_as_default_explorer = true,
                },

                -- Customization of explorer windows
                windows = {
                    -- Maximum number of windows to show side by side
                    max_number = math.huge,
                    -- Whether to show preview of file/directory under cursor
                    preview = true,
                    -- Width of focused window
                    width_focus = 50,
                    -- Width of non-focused window
                    width_nofocus = 15,
                    -- Width of preview window
                    width_preview = 25,
                },
            }

            local MiniFiles = require 'mini.files'
            vim.keymap.set('n', '-', function()
                local _ = MiniFiles.close() or MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
                vim.defer_fn(function()
                    MiniFiles.reveal_cwd()
                end, 30)
            end, { desc = 'Open file browser' })

            -- Simple and easy statusline.
            --  You could remove this setup call if you don't like it,
            --  and try some other statusline plugin
            local statusline = require 'mini.statusline'
            -- set use_icons to true if you have a Nerd Font
            statusline.setup { use_icons = vim.g.have_nerd_font }

            -- You can configure sections in the statusline by overriding their
            -- default behavior. For example, here we set the section for
            -- cursor location to LINE:COLUMN
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return '%2l:%-2v'
            end

            -- ... and there is more!
            --  Check out: https://github.com/echasnovski/mini.nvim
        end,
    },
}
