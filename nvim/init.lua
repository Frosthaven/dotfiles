-- set font for neovide (must be done early)
vim.cmd('set guifont=JetBrainsMono\\ NFM:h15')

-- Pass control off to custom /lua files
require('frosthaven')
