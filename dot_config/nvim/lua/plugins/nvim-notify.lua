return {
    'rcarriga/nvim-notify',
    enabled = true,
    lazy = false,
    config = function()
        local n = require 'notify'
        n.setup {
            background_colour = '#000000',
        }

        -- make LSP crashes smaller and less obtrusive
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.notify = function(msg, level, opts)
            opts = opts or {}

            -- completely filter out "Invalid server name" messages
            if type(msg) == 'string' and msg:match '^Invalid server name' then
                return
            end

            if type(msg) == 'string' and msg:match 'Client ' and msg:match 'quit with exit code' and msg:match 'Check log for' then
                -- Extract client name for title
                local client_name = msg:match 'Client (.-) quit' or 'LSP'

                -- Force compact notification with fixed text
                opts.title = 'LSP Warning'
                opts.timeout = 1500
                opts.render = 'compact'

                return n(client_name .. ' crashed', level, opts)
            end

            -- All other notifications remain unchanged
            return n(msg, level, opts)
        end
    end,
}
