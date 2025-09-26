-- KEYMAP ---------------------------------------------------------------------
-------------------------------------------------------------------------------

--[[
Due to my use of a corne split 40% keyboard, having arrow key usage in VIM is
no longer taboo. You will find many keybinds that use hjkl as well as the arrow
keys to accomplish the same task.
--]]

-- Leader key -----------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Yank to EOL ----------------------------------------------------------------

vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Center screen when jumping -------------------------------------------------

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Window navigation ----------------------------------------------------------

-- hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- arrows
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Move to right window" })

-- Move lines up and down with alt in visual mode -----------------------------

-- hjkl
vim.keymap.set(
    "v", "<A-j>", ":m '>+1<CR>gv=gv",
    { desc = "Move selection down" }
)
vim.keymap.set(
    "v", "<A-k>", ":m '<-2<CR>gv=gv",
    { desc = "Move selection up" }
)

-- arrows
vim.keymap.set(
    "v", "<A-Down>", ":m '>+1<CR>gv=gv",
    { desc = "Move selection down" }
)
vim.keymap.set(
    "v", "<A-Up>", ":m '<-2<CR>gv=gv",
    { desc = "Move selection up" }
)

-- Persistant indentation in visual mode --------------------------------------

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

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
            pcall(function() vim.cmd('lnext') end)
        else
            pcall(function() vim.cmd('lprev') end)
        end
    elseif #vim.fn.getqflist() > 0 then
        if next then
            pcall(function() vim.cmd('cnext') end)
        else
            pcall(function() vim.cmd('cprev') end)
        end
    else
        print("No location list or quickfix list found")
    end
end

-- hjkl
vim.keymap.set(
    'n', '<M-j>', function() move_list(true) end,
    { desc = 'Move to next list item' }
)
vim.keymap.set(
    'n', '<M-k>', function() move_list(false) end,
    { desc = 'Move to previous list item' }
)
-- arrows
vim.keymap.set(
    'n', '<M-Down>', function() move_list(true) end,
    { desc = 'Move to next list item' }
)
vim.keymap.set(
    'n', '<M-Up>', function() move_list(false) end,
    { desc = 'Move to previous list item' }
)

-- Diagnostic Virtual Text ----------------------------------------------------

vim.keymap.set('n', '<leader>dt', function()
    if vim.diagnostic.config().virtual_text == true then
        vim.diagnostic.config { virtual_text = false, virtual_lines = false }
        vim.notify 'Global diagnostic virtual lines disabled'
    else
        vim.diagnostic.config { virtual_text = true, virtual_lines = false }
        vim.notify 'Global diagnostic virtual lines enabled'
    end
end, { desc = 'Toggle [D]iagnostic [T]oggle' })

-- Diagnostic Quickfix List ---------------------------------------------------

vim.keymap.set(
    'n', '<leader>dq', vim.diagnostic.setloclist,
    { desc = 'Open diagnostic [Q]uickfix list' }
)

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

-- Yank diagnostic messaging --------------------------------------------------

vim.keymap.set({ "n", "v" }, "<leader>dy", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()
    local start_line, end_line

    if mode:match("[vV]") then
        -- Visual mode: use selection
        start_line = vim.fn.getpos("v")[2] - 1
        end_line = vim.fn.getpos(".")[2] - 1
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

    if vim.tbl_isempty(selected_diags) then
        vim.notify("No diagnostics found in selection", vim.log.levels.INFO)
        return
    end

    -- Combine diagnostic messages with line numbers
    local messages = {}
    for _, diag in ipairs(selected_diags) do
        local line_num = diag.lnum + 1 -- convert 0-index to 1-index
        table.insert(messages, string.format("%d: %s", line_num, diag.message))
    end
    local all_messages = table.concat(messages, "\n")

    -- Get file + line range
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    local line_info = filename .. ":" .. (start_line + 1)
    if end_line > start_line then
        line_info = line_info .. "-" .. (end_line + 1)
    end

    -- Detect language from extension
    local ext = filename:match("^.+%.(.+)$")
    local lang_map = {
        ts = "ts",
        tsx = "ts",
        js = "js",
        jsx = "js",
        lua = "lua",
        php = "php",
        rs = "rs"
    }
    local lang = lang_map[ext] or ext or ""

    -- Soft wrap helper (≤ 80 chars)
    local function soft_wrap(line, width)
        local out, cur = {}, line
        while #cur > width do
            local break_at = cur:sub(1, width):match("^.*()%s")
            if not break_at or break_at < 1 then break_at = width end
            table.insert(out, cur:sub(1, break_at))
            cur = vim.trim(cur:sub(break_at + 1))
        end
        if #cur > 0 then table.insert(out, cur) end
        return out
    end

    -- Collect code lines with soft wrap
    local code_lines = vim.api.nvim_buf_get_lines(
        bufnr, start_line, end_line + 1, false
    )
    local wrapped_code = {}
    for _, line in ipairs(code_lines) do
        vim.list_extend(wrapped_code, soft_wrap(line, 80))
    end

    -- Build final string
    local out = string.format(
        "Diagnostic:\n\n%s\n\n\n%s:\n\n```%s\n%s\n```",
        all_messages,
        line_info,
        lang,
        table.concat(wrapped_code, "\n")
    )

    vim.fn.setreg("+", out)
    vim.notify("Yanked diagnostic(s) + code to clipboard", vim.log.levels.INFO)
end, { desc = "[D]iagnostic [Y]ank" })

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
    show_diagnostic_float()    -- Show the diagnostic float
end, { desc = 'Go to [N]ext diagnostic' })

-- Previous diagnostic
vim.keymap.set('n', '<leader>dp', function()
    vim.diagnostic.goto_prev() -- Move to the previous diagnostic
    show_diagnostic_float()    -- Show the diagnostic float
end, { desc = 'Go to [P]revious diagnostic' })

-- LSP keymaps ----------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        -- mapping helper function
        local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(
                mode, keys, func,
                { buffer = event.buf, desc = 'LSP: ' .. desc }
            )
        end

        -- Find references for the word under your cursor.
        map('<leader>ln', vim.lsp.buf.rename, 'Re[n]ame')
        map('<leader>la', vim.lsp.buf.code_action, 'Code [A]ction')
        map(
            '<leader>lA',
            vim.lsp.buf.code_action,
            'Code [A]ction (extra)',
            { 'n', 'x' }
        )

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(
                vim.lsp.protocol.Methods.textDocument_inlayHint
            ) then
            map('<leader>lh', function()
                vim.lsp.inlay_hint.enable(
                    not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
                )
            end, 'Inlay [H]ints')
        end
        if client and client:supports_method(
                vim.lsp.protocol.Methods.textDocument_documentHighlight
            ) then
            local highlight_augroup = vim.api.nvim_create_augroup(
                'lsp-highlight', { clear = false }
            )
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
                group = vim.api.nvim_create_augroup(
                    'lsp-detach', { clear = true }
                ),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds {
                        group = 'lsp-highlight', buffer = event2.buf
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
vim.keymap.set("n", '-', ":Explore<CR>", { desc = ":Explore" })
-- Leave :Explore
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        vim.keymap.set('n', '-', ':Rex<CR>', {
            buffer = true,
            desc = "Return from :Explore",
            noremap = true,
            silent = true
        })
    end,
})

-- Toggle Terminal ------------------------------------------------------------

vim.keymap.set(
    't', '<Esc><Esc>', '<C-\\><C-n>',
    { desc = 'Exit terminal mode' }
)
vim.keymap.set('n', '<leader>tt', function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd 'J'
    vim.api.nvim_win_set_height(0, 10)
end, { desc = '[T]iny [T]erminal' })
