local M = {}

-- List Movement Functions ----------------------------------------------------
-------------------------------------------------------------------------------

function M.dynamic_list_location_shift(next)
    local wininfo_list = vim.fn.getwininfo()
    local loc_winid = nil

    -- Find first visible location list window
    for _, win in ipairs(wininfo_list) do
        if win.loclist == 1 and #vim.fn.getloclist(win.winid) > 0 then
            loc_winid = win.winid
            break
        end
    end

    if loc_winid then
        -- Jump to the location list window
        vim.api.nvim_set_current_win(loc_winid)
        if next then
            pcall(function()
                vim.cmd 'lnext'
            end)
        else
            pcall(function()
                vim.cmd 'lprev'
            end)
        end
    elseif #vim.fn.getqflist() > 0 then
        if next then
            pcall(function()
                vim.cmd 'cnext'
            end)
        else
            pcall(function()
                vim.cmd 'cprev'
            end)
        end
    else
        print 'No location list or quickfix list found'
    end
end

function M.move_dynamic_list_prev()
    M.dynamic_list_location_shift(false)
end

function M.move_dynamic_list_next()
    M.dynamic_list_location_shift(true)
end

-- Diagnostic Toggle Functions ------------------------------------------------
-------------------------------------------------------------------------------

function M.toggle_diagnostic_virtual_text()
    if vim.diagnostic.config().virtual_text == true then
        vim.diagnostic.config { virtual_text = false, virtual_lines = false }
        vim.notify('󱙎 Global diagnostic virtual lines disabled', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
    else
        vim.diagnostic.config { virtual_text = true, virtual_lines = false }
        vim.notify('󱖭 Global diagnostic virtual lines enabled', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
    end
end

function M.show_curr_diagnostic_float()
    local opts = {
        focusable = true,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter' },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'line',
    }

    vim.diagnostic.open_float(nil, opts)
end

function M.show_next_diagnostic_float()
    vim.diagnostic.jump {
        count = 1,
        on_jump = function()
            -- small delay to ensure cursor has moved
            vim.defer_fn(function()
                M.show_curr_diagnostic_float()
            end, 50)
        end,
    }
end

function M.show_prev_diagnostic_float()
    vim.diagnostic.jump {
        count = -1,
        on_jump = function()
            -- small delay to ensure cursor has moved
            vim.defer_fn(function()
                M.show_curr_diagnostic_float()
            end, 50)
        end,
    }
end

return M
