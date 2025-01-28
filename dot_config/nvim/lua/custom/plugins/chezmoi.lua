return {
  { -- Integrate chezmoi
    'xvzc/chezmoi.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('chezmoi').setup {
        -- your configurations
        edit = {
          watch = true,
          force = true,
        },
        notification = {
          on_open = true,
          on_apply = true,
          on_watch = false,
        },
      }

      -- integrate with telescope
      local telescope = require 'telescope'
      telescope.load_extension 'chezmoi'
      vim.keymap.set('n', '<leader>sc', telescope.extensions.chezmoi.find_files, { desc = '[S]earch [C]hezmoi' })

      -- automatically track chezmoi files
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = { os.getenv 'HOME' .. '/.local/share/chezmoi/*' },
        callback = function(ev)
          local bufnr = ev.buf
          local edit_watch = function()
            require('chezmoi.commands.__edit').watch(bufnr)
          end
          vim.schedule(edit_watch)
        end,
      })
    end,
  },
}
