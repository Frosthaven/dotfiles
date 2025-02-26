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

-- the first shell in the list that is found on the system will be used
M.configuredShellPriority = {
    { 'fish', M.shellConfigSets['posix'] },
    { 'nu', M.shellConfigSets['nu'] },
    { 'zsh', M.shellConfigSets['posix'] },
    { 'pwsh', M.shellConfigSets['powershell'] },
    { 'powershell', M.shellConfigSets['powershell'] },
    { 'bash', M.shellConfigSets['posix'] },
}

-- SETUP ----------------------------------------------------------------------
-------------------------------------------------------------------------------

-- loops through the provided shell configuration and sets the shell options
M.applyShellConfigSet = function(shellConfig)
    for key, value in pairs(shellConfig) do
        vim.opt[key] = value
    end
end

-- looks for the first shell in the list that is found on the system, and sets
-- the shell configuration to that shell. if no shell is found, the default
-- shell configuration of neovim is used
M.configureShell = function(shell)
    if M.configuredShellPriority[shell] then
        M.applyShellConfigSet(M.configuredShellPriority[shell][2])
    else
        M.applyShellConfigSet(M.shellConfigSets['posix'])
    end
end

M.getHighestPriorityAvailableShell = function()
    for _, shell in ipairs(M.configuredShellPriority) do
        if vim.fn.executable(shell[1]) == 1 then
            return shell[1]
        end
    end
end

M.registerAutoShellConfig = function()
    vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*',
        callback = function()
            M.configureShell(vim.opt.shell:get())
        end,
    })
end

-- sets up the shell configuration immediately, and update configs when the
-- shell option is changed
M.setup = function()
    vim.opt.shell = M.getHighestPriorityAvailableShell()
    M.configureShell(vim.opt.shell:get())
    M.registerAutoShellConfig()
end

return M
