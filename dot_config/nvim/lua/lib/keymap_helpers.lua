local M = {}

-- Flash Highlight Helper -----------------------------------------------------
-------------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace 'yank_flash'

-- this function highlights lines from start_line to end_line (0-indexed) in the
-- given buffer for a short duration
function M.flash_highlight(bufnr, start_line, end_line)
    local hl_group = 'IncSearch'
    local duration = 200 -- ms

    for l = start_line, end_line do
        vim.api.nvim_buf_set_extmark(bufnr, ns, l, 0, {
            end_line = l + 1,
            hl_group = hl_group,
            hl_eol = true,
        })
    end

    vim.defer_fn(function()
        vim.api.nvim_buf_clear_namespace(bufnr, ns, start_line, end_line + 1)
    end, duration)
end

-- Yank Functions -------------------------------------------------------------
-------------------------------------------------------------------------------

-- Yanks the selected line(s) as a GitHub URL to the clipboard. If the user
-- has unsaved changes or unpushed commits, it will not yank the URL and will
-- notify the user instead.
function M.yank_github_url()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    local repo_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    if repo_root == '' or vim.fn.isdirectory(repo_root) == 0 then
        vim.notify(' Not inside a Git repository', vim.log.levels.WARN, { title = 'Keymap' })
        return
    end

    local branch = vim.fn.systemlist('git rev-parse --abbrev-ref HEAD')[1]
    if branch == '' or branch == 'HEAD' then
        vim.notify(' Could not determine Git branch', vim.log.levels.WARN, { title = 'Keymap' })
        return
    end

    local remote_url = vim.fn.systemlist('git config --get remote.origin.url')[1]
    if not remote_url or remote_url == '' then
        vim.notify(' No Git remote found', vim.log.levels.WARN, { title = 'Keymap' })
        return
    end

    if remote_url:match '^git@' then
        remote_url = remote_url:gsub(':', '/')
        remote_url = remote_url:gsub('git@', 'https://')
    end
    remote_url = remote_url:gsub('%.git$', '')

    local relpath = vim.fn.fnamemodify(filename, ':.' .. repo_root)

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

    local unpushed = vim.fn.systemlist(string.format('git log %s --not --remotes -- %s', branch, vim.fn.shellescape(relpath)))
    local status = vim.fn.systemlist(string.format('git status --porcelain %s', vim.fn.shellescape(relpath)))

    if #unpushed > 0 or #status > 0 then
        local msg_parts = {}
        if #unpushed > 0 then
            table.insert(msg_parts, 'unpushed commits')
        end
        if #status > 0 then
            table.insert(msg_parts, 'uncommitted changes')
        end
        vim.notify(' Cannot copy GitHub URL: file has ' .. table.concat(msg_parts, '/') .. '!', vim.log.levels.WARN, { title = 'Keymap' })
        return
    end

    local url = string.format('%s/blob/%s/%s', remote_url, branch, relpath)
    url = url .. '?t=' .. os.time()

    if start_line == end_line then
        url = url .. '#L' .. start_line
    else
        url = url .. '#L' .. start_line .. '-L' .. end_line
    end

    vim.fn.setreg('+', url)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
    M.flash_highlight(bufnr, start_line - 1, end_line - 1)

    vim.notify(' Yanked GitHub URL', vim.log.levels.INFO, { title = 'Keymap' })
end

-- Yanks the selected line(s) and collects any diagnostics (errors, warnings,
-- etc.) in those lines. After formatting into markdown code blocks, it copies
-- the result to the clipboard.
function M.yank_diagnostics()
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
    M.flash_highlight(bufnr, start_line, end_line)

    -- Notify user
    vim.notify(' Yanked diagnostic code block', vim.log.levels.INFO, { title = 'Keymap', render = 'compact' })
end

-- Yanks the selected line(s) and formats them into a markdown code block,
-- copying the result to the clipboard.
function M.yank_codeblock()
    local bufnr = vim.api.nvim_get_current_buf()
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

    local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

    local filetype = vim.bo.filetype ~= '' and vim.bo.filetype or 'txt'
    local out = string.format('```%s\n%s\n```', filetype, table.concat(lines, '\n'))

    vim.fn.setreg('+', out)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
    M.flash_highlight(bufnr, start_line - 1, end_line - 1)

    vim.notify(' Yanked code block', vim.log.levels.INFO, { title = 'Keymap' })
end

-- Yanks the relative path of the current file to the clipboard
function M.yank_relative_path()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local cwd = vim.fn.getcwd()
    local relpath = vim.fn.fnamemodify(filename, ':.' .. cwd)

    vim.fn.setreg('+', relpath)

    vim.notify(' Yanked relative path', vim.log.levels.INFO, { title = 'Keymap' })
end

-- Yanks the absolute path of the current file to the clipboard
function M.yank_absolute_path()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    vim.fn.setreg('+', filename)

    vim.notify(' Yanked absolute path', vim.log.levels.INFO, { title = 'Keymap' })
end

function M.yank_compressed_file()
    local items = {}
    local base_dir
    local filetype = vim.bo.filetype

    -- Determine base directory and items
    if filetype == 'minifiles' then
        local curr_path = vim.fn.expand '%:p'
        if curr_path == '' then
            vim.notify(' No file or directory in buffer', vim.log.levels.WARN, { title = 'Keymap' })
            return
        end

        -- Strip minifiles:// prefix and keep leading slash
        curr_path = curr_path:gsub('^minifiles://%d+//', '/')

        local stat = vim.loop.fs_stat(curr_path)
        if not stat then
            vim.notify(' Path does not exist: ' .. curr_path, vim.log.levels.WARN, { title = 'Keymap' })
            return
        end

        if stat.type == 'directory' then
            base_dir = curr_path
        else
            base_dir = vim.fn.fnamemodify(curr_path, ':h')
            table.insert(items, curr_path)
        end
    elseif filetype == 'netrw' then
        base_dir = vim.b.netrw_curdir or vim.fn.getcwd()
    else
        local curr_file = vim.fn.expand '%:p'
        if curr_file == '' then
            vim.notify(' No file to compress', vim.log.levels.WARN, { title = 'Keymap' })
            return
        end
        base_dir = vim.fn.fnamemodify(curr_file, ':h')
        table.insert(items, curr_file)
    end

    -- Scan directory if no items yet
    if vim.tbl_isempty(items) then
        local scan = vim.fn.globpath(base_dir, '*', true, true)
        for _, f in ipairs(scan) do
            if vim.loop.fs_stat(f) then
                table.insert(items, f)
            end
        end
    end

    if #items == 0 then
        vim.notify(' No files/folders to compress', vim.log.levels.WARN, { title = 'Keymap' })
        return
    end

    -- Determine project root for prefix
    local project_root = vim.fn.finddir('.git/..', base_dir .. ';')
    if type(project_root) == 'table' then
        project_root = project_root[1] or ''
    end
    if project_root == '' then
        project_root = nil
    end
    local project_prefix = project_root and (vim.fn.fnamemodify(project_root, ':t') .. '__') or ''

    -- Determine base name for zip
    local first_item = items[1]
    local base_name
    if filetype == 'minifiles' or filetype == 'netrw' then
        -- Use the current directory name
        base_name = vim.fn.fnamemodify(base_dir:gsub('/$', ''), ':t')
    else
        -- Use the file name
        base_name = vim.fn.fnamemodify(first_item:gsub('/$', ''), ':t')
    end
    if base_name == '' then
        base_name = 'project'
    end

    -- Add timestamp to filename
    local timestamp = os.date '%Y%m%d_%H%M%S'
    local zip_name = string.format('%s%s__%s.nvim.zip', project_prefix, base_name, timestamp)

    -- Ensure Downloads folder exists
    local downloads = vim.fn.expand '~/Downloads'
    if vim.fn.isdirectory(downloads) == 0 then
        vim.fn.mkdir(downloads, 'p')
    end
    local zip_path = downloads .. '/' .. zip_name

    -- Build 7z items: flatten files, keep directories intact
    local rel_items = {}
    for _, f in ipairs(items) do
        local st = vim.loop.fs_stat(f)
        if st then
            if st.type == 'directory' then
                table.insert(rel_items, string.format('"%s"', f))
            else
                table.insert(rel_items, string.format('"%s"', f))
            end
        end
    end

    -- Get possible 7z binary (7zip, p7zip, etc)
    local binaries = { '7z', '7zz' }
    local binary = nil
    for _, b in ipairs(binaries) do
        if vim.fn.executable(b) == 1 then
            binary = b
            break
        end
    end
    if not binary then
        vim.notify(' 7z binary not found in PATH', vim.log.levels.ERROR, { title = 'Keymap' })
        return
    end

    local cmd = string.format(binary .. ' a -tzip "%s" %s -r', zip_path, table.concat(rel_items, ' '))
    local result = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify('Failed to create zip: ' .. result, vim.log.levels.ERROR, { title = 'Keymap' })
        return
    end

    -- Copy zip path to clipboard
    vim.fn.setreg('+', zip_path)

    -- Keep only latest 3 archives
    local existing = vim.fn.globpath(downloads, '*.nvim.zip', true, true)
    table.sort(existing, function(a, b)
        return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
    end)
    for i = 4, #existing do
        os.remove(existing[i])
    end

    vim.notify(string.format(' %s\n  Yanked path', zip_name:match '([^/]+)$'), vim.log.levels.INFO, { title = 'Keymap' })
end

function M.paste_compressed_file()
    local zip_path = vim.fn.getreg '+'
    if zip_path == '' then
        vim.notify(' Clipboard is empty', vim.log.levels.WARN, { title = 'Keymap' })
        return
    end

    if not zip_path:match '%.nvim%.zip$' then
        vim.notify(' Clipboard does not contain a .nvim.zip file', vim.log.levels.WARN, { title = 'Keymap' })
        return
    end

    local filetype = vim.bo.filetype
    local target_dir

    -- Determine active buffer directory
    if filetype == 'minifiles' then
        local curr_path = vim.fn.expand '%:p'
        if curr_path == '' then
            target_dir = vim.fn.getcwd()
        else
            curr_path = curr_path:gsub('^minifiles://%d+//', '/')
            local stat = vim.loop.fs_stat(curr_path)
            target_dir = stat and stat.type == 'directory' and curr_path or vim.fn.fnamemodify(curr_path, ':h')
        end
    elseif filetype == 'netrw' then
        target_dir = vim.b.netrw_curdir or vim.fn.getcwd()
    else
        local curr_file = vim.fn.expand '%:p'
        target_dir = (curr_file ~= '' and vim.fn.fnamemodify(curr_file, ':h')) or vim.fn.getcwd()
    end

    if vim.fn.isdirectory(target_dir) == 0 then
        vim.notify(' Target directory does not exist: ' .. target_dir, vim.log.levels.ERROR, { title = 'Keymap' })
        return
    end

    -- Get possible 7z binary (7zip, p7zip, etc)
    local binaries = { '7z', '7zz' }
    local binary = nil
    for _, b in ipairs(binaries) do
        if vim.fn.executable(b) == 1 then
            binary = b
            break
        end
    end
    if not binary then
        vim.notify(' 7z binary not found in PATH', vim.log.levels.ERROR, { title = 'Keymap' })
        return
    end

    -- List files in the zip to count them
    local list_cmd = string.format(binary .. ' l -ba "%s"', zip_path)
    local zip_list = vim.fn.split(vim.fn.system(list_cmd), '\n')
    local file_count = 0
    for _, f in ipairs(zip_list) do
        if f ~= '' then
            file_count = file_count + 1
        end
    end

    -- Extract with overwrite
    local extract_cmd = string.format(binary .. ' x "%s" -o"%s" -aoa', zip_path, target_dir)
    local result = vim.fn.system(extract_cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify('Failed to extract zip: ' .. result, vim.log.levels.ERROR, { title = 'Keymap' })
        return
    end

    -- Refresh explorers / buffers
    if filetype == 'minifiles' then
        local mini_files = require 'mini.files'
        mini_files.open() -- just reopen current buffer
    elseif filetype == 'netrw' then
        vim.cmd 'Explore'
    end

    -- Reload any regular file buffers that were overwritten, even if not active
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name ~= '' and vim.fn.filereadable(buf_name) == 1 then
            if vim.api.nvim_buf_is_loaded(buf) and not vim.api.nvim_buf_get_option(buf, 'modified') then
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd 'checktime'
                end)
            end
        end
    end

    vim.notify(string.format(' %s\n  Extracted %d file(s)', zip_path:match '([^/]+)$', file_count), vim.log.levels.INFO, { title = 'Keymap' })
end

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
    vim.diagnostic.goto_next()
    M.show_curr_diagnostic_float()
end

function M.show_prev_diagnostic_float()
    vim.diagnostic.goto_prev()
    M.show_curr_diagnostic_float()
end

return M
