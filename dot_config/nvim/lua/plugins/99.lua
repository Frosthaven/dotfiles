return {
    {
        'ThePrimeagen/99',
        config = function()
            local _99 = require('99')

            _99.setup({
                provider = _99.Providers.ClaudeCodeProvider,
                model = 'claude-opus-4-6',
            })

            vim.keymap.set('v', '<leader>ta', function()
                _99.visual()
                vim.schedule(function()
                    vim.cmd('startinsert')
                end)
            end, { desc = '[T]oggle [A]I (visual)' })

            vim.keymap.set('n', '<leader>ts', function()
                _99.stop_all_requests()
            end, { desc = '[S]top All AI Requests' })

            -- AI CLI floating terminal via toggleterm
            local Terminal = require('toggleterm.terminal').Terminal
            local ai_term = Terminal:new({
                cmd = 'claude',
                direction = 'float',
                float_opts = {
                    border = 'curved',
                    width = 120,
                    height = 20,
                },
                hidden = true,
            })

            vim.keymap.set('n', '<leader>ta', function()
                ai_term:toggle()
            end, { desc = '[T]oggle [A]I' })
        end,
    },
}
