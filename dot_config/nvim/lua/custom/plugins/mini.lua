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
            require('mini.surround').setup {
                mappings = {
                    add = 'gsa', -- Add surrounding in Normal and Visual modes
                    --e.g. gsaiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
                    --e.g. gsaa}) - [S]urround [A]dd [A]round [}]Braces [)]Paren
                    delete = 'gsd', -- Delete surrounding
                    --e.g.    gsd"   - [S]urround [D]elete ["]quotes
                    replace = 'gsr', -- Replace surrounding
                    --e.g.     gsr)'  - [S]urround [R]eplace [)]Paren by [']quote
                    find = 'gsf', -- Find surrounding (to the right)
                    find_left = 'gsF', -- Find surrounding (to the left)
                    highlight = 'gsh', -- Highlight surrounding
                    update_n_lines = 'gsn', -- Update `n_lines`
                },
                n_lines = 500,
            }
            require('mini.tabline').setup {
                -- Whether to show file icons (requires 'mini.icons')
                show_icons = true,

                -- Function which formats the tab label
                -- By default surrounds with space and possibly prepends with icon
                -- we will show tab number to the left of the title
                -- lets make this show the tab number, icon, file name, and edit status
                format = function(buf_id, label)
                    local suffix = vim.bo[buf_id].modified and '● ' or ''
                    local tab_index = ' ' .. vim.fn.tabpagenr()
                    return tab_index .. MiniTabline.default_format(buf_id, label) .. suffix
                end,

                -- Whether to set Vim's settings for tabline (make it always shown and
                -- allow hidden buffers)
                set_vim_settings = true,

                -- Where to show tabpage section in case of multiple vim tabpages.
                -- One of 'left', 'right', 'none'.
                tabpage_section = 'none',
            }

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
