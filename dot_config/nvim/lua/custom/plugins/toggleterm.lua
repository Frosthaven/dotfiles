return {
    {
        'akinsho/toggleterm.nvim',
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
                open_mapping = [[<leader>tt]],
                hide_numbers = true,
                shade_terminals = true,
            }
        end,
    },
}
