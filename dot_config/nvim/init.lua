--[[

    - file path is  '~/.config/alacritty/alacritty.toml'
    - the block that we need to edit looks like this:

    [window.padding]
    x = 30
    y = 30

--]]

local function setAlacrittyTOMLPadding(xPadding, yPadding)
    local homeDirectory = os.getenv('HOME')
    local tomlPath = homeDirectory .. '/.config/alacritty/alacritty.toml'

    -- get the user's local
    local file, err = io.open(tomlPath, 'r')
    if not file then
        print('Error opening file: ' .. err)
        return
    end
    local lines = {}
    local inWindowPaddingSection = false
    for line in file:lines() do
        if line:find('%[window%.padding%]') then
            inWindowPaddingSection = true
        elseif line:find('%[.*%]') then
            inWindowPaddingSection = false
        end

        if inWindowPaddingSection then
            if line:find('x = ') then
                line = 'x = ' .. xPadding
            elseif line:find('y = ') then
                line = 'y = ' .. yPadding
            end
        end

        table.insert(lines, line)
    end
    file:close()

    file, err = io.open(tomlPath, 'w')
    if not file then
        print('Error opening file: ' .. err)
        return
    end

    for _, line in ipairs(lines) do
        file:write(line .. '\n')
    end
    file:close()
end

function IncreasePadding()
    setAlacrittyTOMLPadding(30, 30)
end

function DecreasePadding()
  setAlacrittyTOMLPadding(0, 0)
end

vim.cmd[[
  augroup ChangeAlacrittyPadding
   au!
   au VimEnter * lua DecreasePadding()
   au VimLeavePre * lua IncreasePadding()
  augroup END
]]