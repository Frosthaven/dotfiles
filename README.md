# Cross-Platform Configuration

This is my personal configuration bundle, which requires setting up symlinks to the configs on your system of choice.

## Installation

```sh
# this will clone the repo into your user directory
git clone https://github.com/Frosthaven/dotfiles.git ~/dotfiles
```

## Hard Linking Assets

### WezTerm & NeoVim
These require hard links to the config folders, which can be done with the following commands:

#### Windows
```powershell
mklink /H %USERPROFILE%\.config\wezterm ~\dotfiles\wezterm
mklink /H %USERPROFILE%\AppData\Local\nvim ~\dotfiles\nvim
```

#### Linux / MacOS
```sh
ln ~/dotfiles/wezterm ~/.config/wezterm
```
