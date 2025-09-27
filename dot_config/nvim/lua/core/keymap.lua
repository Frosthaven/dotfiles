-- KEYMAP ---------------------------------------------------------------------
-------------------------------------------------------------------------------

--[[
Due to my use of a corne split 40% keyboard, having arrow key usage in VIM is
no longer taboo. You will find many keybinds that use hjkl as well as the arrow
keys to accomplish the same task.
--]]

-- Leader key -----------------------------------------------------------------

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Yank to EOL ----------------------------------------------------------------

vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank to end of line' })

-- Yank into Markdown code block ----------------------------------------------

-- Flash highlight lines between start_line and end_line (inclusive)
local ns = vim.api.nvim_create_namespace 'flash_yank'

local function flash_highlight(bufnr, start_line, end_line)
    local hl_group = 'IncSearch'
    local duration = 200 -- ms

    for l = start_line, end_line do
        -- highlight whole line
        vim.api.nvim_buf_set_extmark(bufnr, ns, l, 0, {
            end_line = l + 1,
            hl_group = hl_group,
            hl_eol = true,
        })
    end

    -- clear after timeout
    vim.defer_fn(function()
        vim.api.nvim_buf_clear_namespace(bufnr, ns, start_line, end_line + 1)
    end, duration)
end

vim.keymap.set({ 'n', 'v' }, '<leader>yc', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()
    local start_line, end_line

    if mode:match '[vV]' then
        start_line = vim.fn.getpos('v')[2] - 1
        end_line = vim.fn.getpos('.')[2] - 1
        if start_line > end_line then
            start_line, end_line = end_line, start_line
        end
    else
        start_line = vim.api.nvim_win_get_cursor(0)[1] - 1
        end_line = start_line
    end

    -- Collect code lines
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
    local code_text = table.concat(lines, '\n')

    -- Relative file path + line range
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local relpath = vim.fn.fnamemodify(filename, ':.')
    local line_info = relpath .. ':' .. (start_line + 1)
    if end_line > start_line then
        line_info = line_info .. '-' .. (end_line + 1)
    end

    -- Detect language
    local ext = filename:match '^.+%.(.+)$' or ''
    local lang_map = {
        ts = 'ts',
        tsx = 'ts',
        js = 'js',
        jsx = 'js',
        lua = 'lua',
        php = 'php',
        rs = 'rs',
        py = 'python',
        rb = 'ruby',
    }
    local lang = lang_map[ext] or ext or ''

    -- Build final string with colon outside backticks
    local out = string.format('`%s`: \n```%s\n%s\n```', line_info, lang, code_text)

    -- Copy to clipboard
    vim.fn.setreg('+', out)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
    flash_highlight(bufnr, start_line, end_line)

    vim.notify({ ' Yanked code block' }, vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
end, { desc = '[Y]ank as [C]ode block' })

-- Yank file path -------------------------------------------------------------

-- relative path including filename relative to working directory
vim.keymap.set({ 'n', 'v' }, '<leader>yr', function()
    local filepath = vim.fn.expand '%:p'
    local cwd = vim.fn.getcwd() .. '/'
    if filepath:sub(1, #cwd) == cwd then
        filepath = filepath:sub(#cwd + 1)
    end
    vim.fn.setreg('+', filepath)

    vim.notify(' Yanked relative file path', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
end, { desc = '[Y]ank [R]elative path of file' })

-- absolute path including filename
vim.keymap.set({ 'n', 'v' }, '<leader>ya', function()
    local filepath = vim.fn.expand '%:p'
    vim.fn.setreg('+', filepath)
    vim.notify(' Yanked absolute file path', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
end, { desc = '[Y]ank [A]bsolute path of file' })

-- Yank diagnostic messaging --------------------------------------------------

vim.keymap.set({ 'n', 'v' }, '<leader>yd', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()
    local start_line, end_line

    if mode:match '[vV]' then
        -- Visual mode: use selection
        start_line = vim.fn.getpos('v')[2] - 1
        end_line = vim.fn.getpos('.')[2] - 1
        if start_line > end_line then
            start_line, end_line = end_line, start_line
        end
    else
        -- Normal mode: current line only
        start_line = vim.api.nvim_win_get_cursor(0)[1] - 1
        end_line = start_line
    end

    -- Collect all diagnostics in buffer
    local all_diags = vim.diagnostic.get(bufnr)
    local selected_diags = {}
    for _, diag in ipairs(all_diags) do
        local d_start = diag.lnum
        local d_end = diag.end_lnum or diag.lnum
        -- Include any diagnostic that overlaps selection
        if d_end >= start_line and d_start <= end_line then
            table.insert(selected_diags, diag)
        end
    end

    -- Combine diagnostic messages with line numbers
    local messages = {}
    if vim.tbl_isempty(selected_diags) then
        table.insert(messages, 'No Diagnostic Warnings Found')
    else
        for _, diag in ipairs(selected_diags) do
            local line_num = diag.lnum + 1 -- convert 0-index to 1-index
            table.insert(messages, string.format('`%d`: %s', line_num, diag.message))
        end
    end
    local all_messages = table.concat(messages, '\n')

    -- Get relative file path + line range
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local relpath = vim.fn.fnamemodify(filename, ':.') -- relative path
    local line_info = relpath .. ':' .. (start_line + 1)
    if end_line > start_line then
        line_info = line_info .. '-' .. (end_line + 1)
    end

    -- Detect language from extension
    local ext = filename:match '^.+%.(.+)$' or ''
    local lang_map = {
        ts = 'ts',
        tsx = 'ts',
        js = 'js',
        jsx = 'js',
        lua = 'lua',
        php = 'php',
        rs = 'rs',
    }
    local lang = lang_map[ext] or ext or ''

    -- Collect code lines without soft wrap
    local code_lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
    local code_text = table.concat(code_lines, '\n')

    -- Build final string
    local out = string.format('Diagnostic:\n\n%s\n\n`%s`:\n```%s\n%s\n```', all_messages, line_info, lang, code_text)

    -- clipboard copy
    vim.fn.setreg('+', out)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
    flash_highlight(bufnr, start_line, end_line)

    -- Notify user
    vim.notify(' Yanked diagnostic code block', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
end, { desc = '[Y]ank [D]iagnostic code block' })

-- Yank github url to selection -----------------------------------------------

vim.keymap.set({ 'n', 'v' }, '<leader>yg', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    -- Get repo root
    local repo_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    if repo_root == '' or vim.fn.isdirectory(repo_root) == 0 then
        vim.notify(' Not inside a Git repository', vim.log.levels.WARN, { title = 'Keymap', render = 'compact' })
        return
    end

    -- Get current branch
    local branch = vim.fn.systemlist('git rev-parse --abbrev-ref HEAD')[1]
    if branch == '' or branch == 'HEAD' then
        vim.notify(' Could not determine Git branch', vim.log.levels.WARN, { title = 'Keymap', render = 'compact' })
        return
    end

    -- Get remote URL
    local remote_url = vim.fn.systemlist('git config --get remote.origin.url')[1]
    if not remote_url or remote_url == '' then
        vim.notify(' No Git remote found', vim.log.levels.WARN, { title = 'Keymap', render = 'compact' })
        return
    end

    -- Convert SSH to HTTPS
    if remote_url:match '^git@' then
        remote_url = remote_url:gsub(':', '/')
        remote_url = remote_url:gsub('git@', 'https://')
    end
    remote_url = remote_url:gsub('%.git$', '')

    -- File path relative to repo
    local relpath = vim.fn.fnamemodify(filename, ':.' .. repo_root)

    -- Get line numbers
    local mode = vim.fn.mode()
    local start_line, end_line
    if mode:match '[vV]' then
        start_line = vim.fn.getpos('v')[2]
        end_line = vim.fn.getpos('.')[2]
        if start_line > end_line then
            start_line, end_line = end_line, start_line
        end
    else
        start_line = vim.api.nvim_win_get_cursor(0)[1]
        end_line = start_line
    end

    -- Check for unpushed commits for this file
    local unpushed = vim.fn.systemlist(string.format('git log %s --not --remotes -- %s', branch, vim.fn.shellescape(relpath)))

    -- Check for unstaged or staged changes
    local status = vim.fn.systemlist(string.format('git status --porcelain %s', vim.fn.shellescape(relpath)))

    if #unpushed > 0 or #status > 0 then
        local msg_parts = {}
        if #unpushed > 0 then
            table.insert(msg_parts, 'unpushed commits')
        end
        if #status > 0 then
            table.insert(msg_parts, 'uncommit changes')
        end
        local msg = table.concat(msg_parts, '/')
        vim.notify(' Cannot copy GitHub URL: file has ' .. msg .. '!', vim.log.levels.WARN, { title = 'Keymap', render = 'compact' })
        return
    end

    -- Build GitHub URL
    local url = string.format('%s/blob/%s/%s', remote_url, branch, relpath)

    -- Append timestamp
    local ts = os.time()
    url = url .. '?t=' .. ts

    -- Append line numbers
    if start_line == end_line then
        url = url .. '#L' .. start_line
    else
        url = url .. '#L' .. start_line .. '-L' .. end_line
    end

    -- Copy to clipboard
    vim.fn.setreg('+', url)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
    flash_highlight(bufnr, start_line - 1, end_line - 1)

    vim.notify(' Yanked GitHub URL', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
end, { desc = '[Y]ank [G]itHub URL for current line(s)' })

-- Center screen when jumping -------------------------------------------------

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Prev search result (centered)' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })

-- Window navigation ----------------------------------------------------------

-- hjkl
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- arrows
vim.keymap.set('n', '<C-Left>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-Down>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-Up>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-Right>', '<C-w>l', { desc = 'Move to right window' })

-- Move lines up and down with alt in visual mode -----------------------------

-- hjkl
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- arrows
vim.keymap.set('v', '<A-Down>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-Up>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Persistant indentation in visual mode --------------------------------------

vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Contact aware list navigation ----------------------------------------------
-- works on location list if it exists, otherwise quickfix list

local function move_list(next)
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

-- hjkl
vim.keymap.set('n', '<M-j>', function()
    move_list(true)
end, { desc = 'Move to next list item' })
vim.keymap.set('n', '<M-k>', function()
    move_list(false)
end, { desc = 'Move to previous list item' })
-- arrows
vim.keymap.set('n', '<M-Down>', function()
    move_list(true)
end, { desc = 'Move to next list item' })
vim.keymap.set('n', '<M-Up>', function()
    move_list(false)
end, { desc = 'Move to previous list item' })

-- Diagnostic Virtual Text ----------------------------------------------------

vim.keymap.set('n', '<leader>dt', function()
    if vim.diagnostic.config().virtual_text == true then
        vim.diagnostic.config { virtual_text = false, virtual_lines = false }
        vim.notify('󱙎 Global diagnostic virtual lines disabled', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
    else
        vim.diagnostic.config { virtual_text = true, virtual_lines = false }
        vim.notify('󱖭 Global diagnostic virtual lines enabled', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
    end
end, { desc = 'Toggle [D]iagnostic [T]oggle' })

-- Diagnostic Quickfix List ---------------------------------------------------

vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Floating diagnostic display ------------------------------------------------

vim.keymap.set('n', '<leader>dd', function()
    local opts = {
        focusable = true,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter' },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'line',
    }
    vim.diagnostic.open_float(nil, opts)
end, { desc = '[D]iagnostic [D]isplay' })

-- Navigate diagnostics and show floating window ------------------------------

local function show_diagnostic_float()
    local diagnostics = vim.diagnostic.get(0) -- Get diagnostics for the buffer
    if #diagnostics > 0 then
        -- Show the first diagnostic as a floating window
        vim.diagnostic.open_float()
    end
end

-- Next diagnostic
vim.keymap.set('n', '<leader>dn', function()
    vim.diagnostic.goto_next() -- Move to the next diagnostic
    show_diagnostic_float() -- Show the diagnostic float
end, { desc = 'Go to [N]ext diagnostic' })

-- Previous diagnostic
vim.keymap.set('n', '<leader>dp', function()
    vim.diagnostic.goto_prev() -- Move to the previous diagnostic
    show_diagnostic_float() -- Show the diagnostic float
end, { desc = 'Go to [P]revious diagnostic' })

-- LSP keymaps ----------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        -- mapping helper function
        local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Find references for the word under your cursor.
        map('<leader>ln', vim.lsp.buf.rename, 'Re[n]ame')
        map('<leader>la', vim.lsp.buf.code_action, 'Code [A]ction')
        map('<leader>lA', vim.lsp.buf.code_action, 'Code [A]ction (extra)', { 'n', 'x' })

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>lh', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Inlay [H]ints')
        end
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds {
                        group = 'lsp-highlight',
                        buffer = event2.buf,
                    }
                end,
            })
        end

        -- if client.server_capabilities.colorProvider then
        --     require('document-color').buf_attach(event.buf)
        -- end
    end,
})

-- Minus for toggling :Explore ------------------------------------------------
-- these :explore keymaps are loaded initially, but get replaced by navigation
-- plugins like mini.files. This ensures a fallback behavior that stays
-- consistent across setups.

-- enter :Explore
vim.keymap.set('n', '-', ':Explore<CR>', { desc = ':Explore' })
-- Leave :Explore
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        vim.keymap.set('n', '-', ':Rex<CR>', {
            buffer = true,
            desc = 'Return from :Explore',
            noremap = true,
            silent = true,
        })
    end,
})

-- Toggle Terminal ------------------------------------------------------------

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>tt', function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd 'J'
    vim.api.nvim_win_set_height(0, 10)
end, { desc = '[T]iny [T]erminal' })
