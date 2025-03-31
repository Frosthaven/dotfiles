local M = {}

M.setup = function()
    --[[
    -- Set <space> as the leader key
    -- See `:help mapleader`
    --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  --]]
    vim.g.mapleader = ' '
    vim.g.maplocalleader = ' '

    -- [[ Basic Keymaps ]]
    --  See `:help vim.keymap.set()`

    -- Clear highlights on search when pressing <Esc> in normal mode
    --  See `:help hlsearch`
    vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

    -- Diagnostic keymaps
    local function next_diagnostic()
        vim.diagnostic.jump { count = 1, float = false }
    end
    local function prev_diagnostic()
        vim.diagnostic.jump { count = -1, float = false }
    end

    vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
    vim.keymap.set('n', '<leader>dd', function()
        if vim.diagnostic.config().virtual_lines == true then
            vim.diagnostic.config { virtual_lines = { current_line = true } }
            vim.notify 'Global diagnostic virtual lines disabled'
        else
            vim.diagnostic.config { virtual_lines = true }
            vim.notify 'Global diagnostic virtual lines enabled'
        end
    end, { desc = 'Toggle [D]iagnostic [D]isplay' })

    -- previous and next diagnostic
    vim.keymap.set('n', '<leader>dn', next_diagnostic, { desc = 'Go to [N]ext diagnostic' })
    vim.keymap.set('n', '<leader>dp', prev_diagnostic, { desc = 'Go to [P]revious diagnostic' })

    -- tiny terminal
    -- if on windows, use powershell
    local is_windows = vim.fn.has 'win64' == 1 or vim.fn.has 'win32' == 1 or vim.fn.has 'win16' == 1
    if is_windows then
        vim.o.shell = 'powershell.exe -nologo'
    end
    vim.keymap.set('n', '<leader>tt', function()
        vim.cmd.vnew()
        vim.cmd.term()
        vim.cmd.wincmd 'J'
        vim.api.nvim_win_set_height(0, 10)
    end, { desc = '[T]iny [T]erminal' })

    -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
    -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
    -- is not what someone will guess without a bit more experience.
    --
    -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
    -- or just use <C-\><C-n> to exit terminal mode
    vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

    -- TIP: Disable arrow keys in normal mode
    -- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
    -- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
    -- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
    -- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

    -- Keybinds to make split navigation easier.
    --  Use CTRL+<hjkl> to switch between windows
    --

    --  VIM Style Pane Management
    vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
    vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
    vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
    vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
    vim.keymap.set('n', '<M-j>', '<cmd>cnext<CR>', { desc = 'Move to the next quickfix item' })
    vim.keymap.set('n', '<M-k>', '<cmd>cprev<CR>', { desc = 'Move to the previous quickfix item' })

    -- Arrow Style Pane Management
    vim.keymap.set('n', '<C-Up>', '<C-w><Up>', { desc = 'Move focus to the upper window' })
    vim.keymap.set('n', '<C-Down>', '<C-w><Down>', { desc = 'Move focus to the lower window' })
    vim.keymap.set('n', '<C-Left>', '<C-w><Left>', { desc = 'Move focus to the left window' })
    vim.keymap.set('n', '<C-Right>', '<C-w><Right>', { desc = 'Move focus to the right window' })
    vim.keymap.set('n', '<M-Down>', '<cmd>cnext<CR>', { desc = 'Move to the next quickfix item' })
    vim.keymap.set('n', '<M-Up>', '<cmd>cprev<CR>', { desc = 'Move to the previous quickfix item' })

    vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
    vim.keymap.set('x', 'p', function()
        return 'pgv"' .. vim.v.register .. 'y'
    end, { remap = false, expr = true })
end

return M
