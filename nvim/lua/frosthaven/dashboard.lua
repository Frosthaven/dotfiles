-- dashboard contents
local home = os.getenv('HOME')
local db = require('dashboard')

-- platform specific

--[[ if (vim.loop.os_uname().sysname == "Darwin") then
--    db.preview_command = 'cat | lolcat -F 0.3'
elseif (vim.loop.os_uname().sysname == "Windows") then
--    db.preview_command = 'cat | lolcat -F 0.3'
else -- linux or other
--    db.preview_command = 'ueberzug'
end ]]

db.custom_header = {
  " FROSTHAVEN\'S NEOVIM DASHBOARD ",
  "",
  "What, were you expecting RobCo? Too bad, you get me.",
  "",
}


db.preview_file_height = 11
db.preview_file_width = 70
db.custom_center = {
  --[[ {icon = '  ',
  desc = 'Recently latest session                  ',
  shortcut = 'SPC s l',
  action ='SessionLoad'}, ]]
 {icon = ' ',
  desc = ' RECENT FILES                            ',
  action =  'Telescope oldfiles',
  shortcut = '  SPC f h'},
{icon = ' ',
  desc = ' BOOKMARKS                               ',
  action =  'Telescope harpoon marks',
  shortcut = '  SPC f m'},
{icon = '  ',
  desc = 'FILE BROWSER                            ',
  action =  'Telescope file_browser',
  shortcut = '  SPC f b'},
 {icon = '  ',
  desc = 'FIND FILES                              ',
  action = 'Telescope find_files find_command=rg,--hidden,--files',
  shortcut = '  SPC f f'},
  {icon = ' ',
  desc = ' FIND WORD                               ',
  action = 'Telescope live_grep',
  shortcut = '  SPC f w'},
  --[[ {icon = '  ',
  desc = 'Open Personal dotfiles                  ',
  action = 'Telescope dotfiles path=' .. home ..'/.dotfiles',
  shortcut = 'SPC f d'}, ]]
}
