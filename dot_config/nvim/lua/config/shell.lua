local M = {}

-- SHELL CONFIG PRIORITY & CONFIG ---------------------------------------------
-------------------------------------------------------------------------------

-- shell configuration sets
M.shellConfigSets = {
    powershell = { -- applies to both pwsh and powershell
        shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
        shellpipe = '| Out-File -Encoding UTF8 %s',
        shellquote = '',
        shellredir = '| Out-File -Encoding UTF8 %s',
        shelltemp = false,
        shellxescape = '',
        shellxquote = '',
    },
    nu = { -- applies to nu/nushell
        shellcmdflag = '--login --interactive --stdin --no-newline -c',
        shellpipe = '| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record',
        shellquote = '',
        shellredir = 'out+err> %s',
        shelltemp = false,
        shellxescape = '',
        shellxquote = '',
    },
    posix = { -- applies to all other shells (zsh, bash, sh, etc.)
        shellcmdflag = '-c',
        shellpipe = '2>&1 | tee',
        shellquote = '',
        shellredir = '>%s 2>&1',
        shelltemp = true,
        shellxescape = '',
        shellxquote = '',
    },
}

-- in the event that the parent shell cannot be determined, the first shell in
-- the list that is found on the system will be used
M.configuredShellPriority = {
    { 'nu', M.shellConfigSets['nu'] },
    { 'fish', M.shellConfigSets['posix'] },
    { 'zsh', M.shellConfigSets['posix'] },
    { 'pwsh', M.shellConfigSets['powershell'] },
    { 'powershell', M.shellConfigSets['powershell'] },
    { 'bash', M.shellConfigSets['posix'] },
}

-- SETUP ----------------------------------------------------------------------
-------------------------------------------------------------------------------

-- Loops through the provided shell configuration and sets the shell options
M.applyShellConfigSet = function(shellConfig)
    for key, value in pairs(shellConfig) do
        vim.opt[key] = value
    end
end

-- Looks for the shell from the priority list. If the shell is found on the system,
-- its configuration is applied; if not, defaults to posix or the first available shell.
M.configureShell = function(currentShell)
    local shellConfig = nil

    -- First, check if the current shell is in the configured list
    for _, shellEntry in ipairs(M.configuredShellPriority) do
        if shellEntry[1] == currentShell then
            shellConfig = shellEntry[2]
            break
        end
    end

    -- If current shell not found, check the priority list for available shell
    if not shellConfig then
        for _, shellEntry in ipairs(M.configuredShellPriority) do
            if vim.fn.executable(shellEntry[1]) == 1 then
                shellConfig = shellEntry[2]
                break
            end
        end
    end

    -- If no shell config found, fallback to posix
    if not shellConfig then
        shellConfig = M.shellConfigSets['posix']
    end

    M.applyShellConfigSet(shellConfig)
end

-- Gets the current shell being used by Neovim (or system shell if required)
M.getCurrentShell = function()
    return vim.opt.shell:get() or os.getenv 'SHELL'
end

-- Registers an auto command to update shell config when the shell option is changed
M.registerAutoShellConfig = function()
    vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*',
        callback = function()
            local currentShell = M.getCurrentShell()
            M.configureShell(currentShell)
        end,
    })
end

-- Sets up the shell configuration immediately and updates configs when the shell option is changed
M.setup = function()
    local currentShell = M.getCurrentShell()
    M.configureShell(currentShell)
    M.registerAutoShellConfig()
end

return M
