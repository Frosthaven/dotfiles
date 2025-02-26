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
    { 'zsh', M.shellConfigSets['posix'] },
    { 'pwsh', M.shellConfigSets['powershell'] },
    { 'powershell', M.shellConfigSets['powershell'] },
    { 'fish', M.shellConfigSets['posix'] },
    { 'nu', M.shellConfigSets['nu'] },
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
M.configureShell = function()
    for _, shell in ipairs(M.configuredShellPriority) do
        if vim.fn.executable(shell[1]) == 1 then
            vim.opt.shell = shell[1]
            M.applyShellConfigSet(shell[2])
            return
        end
    end
end

-- sets up the shell configuration immediately, and when the shell is set
M.setup = function()
    M.configureShell()
    vim.api.nvim_create_autocmd('OptionSet', {
        pattern = 'shell',
        callback = function()
            M.configureShell()
        end,
    })
end

return M
