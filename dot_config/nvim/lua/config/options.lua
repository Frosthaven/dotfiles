local M = {}

M.setup = function()
    -- Set to true if you have a Nerd Font installed and selected in the terminal
    vim.g.have_nerd_font = true

    -- [[ Setting options ]]
    -- See `:help vim.opt`
    -- NOTE: You can change these options as you wish!
    --  For more options, you can see `:help option-list`

    -- Make line numbers default
    vim.opt.number = true
    -- You can also add relative line numbers, to help with jumping.
    --  Experiment for yourself to see if you like it!
    vim.opt.relativenumber = true

    -- Enable mouse mode, can be useful for resizing splits for example!
    vim.opt.mouse = 'a'

    -- Don't show the mode, since it's already in the status line
    vim.opt.showmode = false

    -- Sync clipboard between OS and Neovim.
    --  Schedule the setting after `UiEnter` because it can increase startup-time.
    --  Remove this option if you want your OS clipboard to remain independent.
    --  See `:help 'clipboard'`
    vim.schedule(function()
        vim.opt.clipboard = 'unnamedplus'
    end)

    local shell_priority = {
        -- 'nu',
        'zsh',
        'pwsh',
        'powershell',
        'fish',
        'bash',
        'sh',
    }
    for _, shell in ipairs(shell_priority) do
        if vim.fn.executable(shell) == 1 then
            vim.opt.shell = shell
            break
        end
    end

    -- better nu support in nvim
    -- https://www.kiils.dk/en/blog/2024-06-22-using-nushell-in-neovim/
    local powershell_options = {
        shellcmdflag = '-nologo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
        shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode',
        shellquote = '',
        shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait',
        shelltemp = false,
        shellxescape = '',
        shellxquote = '',
    }
    local posix_shell_options = {
        shellcmdflag = '-c',
        shellpipe = '2>&1 | tee',
        shellquote = '',
        shellredir = '>%s 2>&1',
        shelltemp = true,
        shellxescape = '',
        shellxquote = '',
    }
    local nu_shell_options = {
        shellcmdflag = '--login --interactive --stdin --no-newline -c',
        shellpipe = '| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record',
        shellquote = '',
        shellredir = 'out+err> %s',
        shelltemp = false,
        shellxescape = '',
        shellxquote = '',
    }
    local function set_options(options)
        for k, v in pairs(options) do
            vim.opt[k] = v
        end
    end
    local function apply_shell_options()
        -- check if the shell ends with "nu"
        if vim.opt.shell:get():match 'nu$' ~= nil then
            set_options(nu_shell_options)
        elseif vim.opt.shell:get():match 'pwsh$' ~= nil or vim.opt.shell:get():match 'powershell$' ~= nil then
            set_options(powershell_options)
        else
            set_options(posix_shell_options)
        end
    end
    apply_shell_options()

    -- listen for changes to the shell option
    vim.api.nvim_create_autocmd('OptionSet', {
        pattern = 'shell',
        callback = function()
            apply_shell_options()
        end,
    })

    -- Enable break indent
    vim.opt.breakindent = true
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4
    vim.opt.expandtab = true

    -- Save undo history
    vim.opt.undofile = true

    -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
    vim.opt.ignorecase = true
    vim.opt.smartcase = true

    -- Keep signcolumn on by default
    vim.opt.signcolumn = 'yes'

    -- Decrease update time
    vim.opt.updatetime = 250

    -- Decrease mapped sequence wait time
    vim.opt.timeoutlen = 300

    -- Configure how new splits should be opened
    vim.opt.splitright = true
    vim.opt.splitbelow = true

    -- Sets how neovim will display certain whitespace characters in the editor.
    --  See `:help 'list'`
    --  and `:help 'listchars'`
    vim.opt.list = true
    vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

    -- Preview substitutions live, as you type!
    vim.opt.inccommand = 'split'

    -- Show which line your cursor is on
    vim.opt.cursorline = true

    -- Minimal number of screen lines to keep above and below the cursor.
    vim.opt.scrolloff = 10
end

return M
