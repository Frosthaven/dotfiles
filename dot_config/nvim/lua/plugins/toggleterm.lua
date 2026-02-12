return {
    {
        'akinsho/toggleterm.nvim',
        enabled = true,
        version = '*',
        config = function()
            require('toggleterm').setup {
                size = 10,
                direction = 'float',
                float_opts = {
                    border = 'curved',
                    width = 120,
                    height = 20,
                    --highlights = {
                    --     border = 'Normal',
                    --  background = 'Normal',
                    --},
                },
                border = 'curved',
                hide_numbers = true,
                shade_terminals = true,
            }

            vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>', { desc = '[T]oggle [T]erminal' })
        end,
    },
}
