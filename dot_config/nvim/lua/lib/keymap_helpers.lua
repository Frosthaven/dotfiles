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

-- Compresses the selected file(s) or folder(s) into a zip archive and copies
-- the archive path to clipboard. File(s) & folder(s) to copy are as follows:
-- 1. If we're in a mini.files buffer, use the highlighted item
-- 2. If we're in a netrw buffer, zip all visible files and folders
-- 3. If we're in a normal buffer, zip the active file
function M.yank_compressed_file()
    local items = {}
    local base_dir
    local filetype = vim.bo.filetype

    -- mini.files
    if filetype == 'minifiles' then
        local state = require('mini.files').get_explorer_state()
        if not state then
            vim.notify(' Mini.files not active', vim.log.levels.WARN, { title = 'Keymap' })
            return
        end

        -- Use only the current file under cursor
        local curr_entry = require('mini.files').get_fs_entry()
        if curr_entry and curr_entry.path and vim.loop.fs_stat(curr_entry.path) then
            table.insert(items, vim.fn.fnamemodify(curr_entry.path, ':p'))
        end

        if #items == 0 then
            vim.notify(' No file/folder under cursor in mini.files', vim.log.levels.WARN, { title = 'Keymap' })
            return
        end

        base_dir = vim.fn.fnamemodify(items[1], ':h')

    -- netrw: archive everything in current directory
    elseif filetype == 'netrw' then
        local netrw_dir = vim.b.netrw_curdir or vim.fn.getcwd()
        base_dir = netrw_dir

        local scan = vim.fn.globpath(netrw_dir, '*', true, true)
        for _, f in ipairs(scan) do
            if vim.loop.fs_stat(f) then
                table.insert(items, f)
            end
        end

        if #items == 0 then
            vim.notify(' No files/folders found in Netrw directory', vim.log.levels.WARN, { title = 'Keymap' })
            return
        end
    end

    -- normal buffer: current file
    if vim.tbl_isempty(items) then
        local curr = vim.fn.expand '%:p'
        if curr ~= '' then
            table.insert(items, curr)
            base_dir = vim.fn.fnamemodify(curr, ':h')
        else
            vim.notify(' No files/folders to compress', vim.log.levels.WARN, { title = 'Keymap' })
            return
        end
    end

    -- determine zip name
    local first_item = items[1]
    local timestamp = os.date '%Y%m%d_%H%M%S'

    -- determine project name
    local project_root = vim.fn.finddir('.git/..', first_item .. ';')
    if type(project_root) == 'table' then
        project_root = project_root[1] or ''
    end
    local project_name
    if project_root ~= '' then
        project_name = vim.fn.fnamemodify(project_root, ':t')
    else
        project_name = vim.fn.fnamemodify(first_item:gsub('/$', ''), ':h:t')
    end
    if project_name == '' then
        project_name = 'project'
    end

    -- determine zip name depending on buffer type
    local zip_name
    if filetype == 'netrw' then
        local netrw_dir = vim.b.netrw_curdir or vim.fn.getcwd()
        local curr_folder_name = vim.fn.fnamemodify(netrw_dir:gsub('/$', ''), ':t')
        if curr_folder_name == '' then
            curr_folder_name = 'folder'
        end
        zip_name = string.format('%s__%s__%s.nvim.zip', project_name, curr_folder_name, timestamp)
    else
        local item_name = vim.fn.fnamemodify(first_item:gsub('/$', ''), ':t')
        if item_name == '' then
            item_name = 'item'
        end
        zip_name = string.format('%s__%s__%s.nvim.zip', project_name, item_name, timestamp)
    end

    -- Downloads folder
    local downloads = vim.fn.expand '~/Downloads'
    if vim.fn.isdirectory(downloads) == 0 then
        vim.fn.mkdir(downloads, 'p')
    end
    local zip_path = downloads .. '/' .. zip_name

    -- build relative paths for 7z
    local rel_items = {}
    for _, item in ipairs(items) do
        local rel = vim.fn.fnamemodify(item, ':.' .. base_dir)
        if rel == '' or rel == '.' then
            rel = vim.fn.fnamemodify(item:gsub('/$', ''), ':t')
        end
        table.insert(rel_items, rel)
    end

    -- 7z a -tzip archive.zip file1 file2 ...
    local cmd = '7z a -tzip "' .. zip_path .. '" ' .. table.concat(rel_items, ' ')
    local result = vim.fn.system(cmd, base_dir)
    if vim.v.shell_error ~= 0 then
        vim.notify('Failed to create zip: ' .. result, vim.log.levels.ERROR, { title = 'Keymap' })
        return
    end

    -- copy zip path to clipboard
    vim.fn.setreg('+', zip_path)

    -- clean up old zip files, keep only latest 3
    local existing = vim.fn.globpath(downloads, '*.nvim.zip', true, true)
    table.sort(existing, function(a, b)
        return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
    end)
    for i = 4, #existing do
        os.remove(existing[i])
    end

    -- notify user
    vim.notify(string.format(' Yanked %s', zip_name), vim.log.levels.INFO, { title = 'Keymap' })
end

-- Pastes (extracts) a .nvim.zip file from clipboard into the current project
-- root (determined by .git folder) or current working directory if no git repo
-- is found.
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

    local current_file = vim.fn.expand '%:p'
    local filetype = vim.bo.filetype

    if filetype == 'minifiles' then
        local entry = require('mini.files').get_fs_entry()
        if entry and entry.path then
            current_file = entry.path
        end
    elseif filetype == 'netrw' then
        current_file = vim.b.netrw_curdir or vim.fn.getcwd()
    end

    -- Strip any minifiles:// prefix
    current_file = current_file:gsub('^minifiles://%d+//', '')

    -- Determine project root
    local project_root = vim.fn.finddir('.git/..', current_file .. ';')
    if type(project_root) == 'table' then
        project_root = project_root[1] or vim.fn.fnamemodify(current_file, ':h')
    elseif project_root == '' then
        project_root = vim.fn.fnamemodify(current_file, ':h')
    end

    -- Build the 7z command with overwrite
    local cmd = string.format('7z x "%s" -o"%s" -aoa', zip_path, project_root)

    -- Execute the command
    local result = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify('Failed to extract zip: ' .. result, vim.log.levels.ERROR, { title = 'Keymap' })
        return
    end

    -- Refresh mini.files if open
    if filetype == 'minifiles' then
        local mini_files = require 'mini.files'
        mini_files.refresh()

        -- Get real filesystem directory of current entry
        local entry = mini_files.get_fs_entry()
        local curr_dir
        if entry and entry.path then
            curr_dir = vim.fn.fnamemodify(entry.path, ':h')
        else
            curr_dir = vim.fn.getcwd()
        end

        mini_files.open(curr_dir, true)
    end

    -- Refresh netrw if open
    if filetype == 'netrw' then
        vim.cmd 'Explore'
    end

    vim.notify(' Extracted ' .. zip_path .. ' into ' .. project_root, vim.log.levels.INFO, { title = 'Keymap' })
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
