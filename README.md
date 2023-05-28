# Cross-Platform Configuration

This is my personal configuration bundle, which requires setting up symlinks to the configs on your system of choice.

## Installation

#### Windows
```powershell
```sh
# this will clone the repo into your user directory
git clone https://github.com/Frosthaven/dotfiles.git ~/dotfiles
```

#### Linux / MacOS
```sh
# this will clone the repo into your user directory
git clone https://github.com/Frosthaven/dotfiles.git ~/dotfiles
```

## Hard Linking Assets

### Alacritty, NeoVim, Starship, WezTerm
For these, we will be symbolically linking folders.

#### Windows
```powershell
# requires admin privileges
Remove-Item -Path "$env:UserProfile\.config\alacritty" -Recurse -Force;
Remove-Item -Path "$env:UserProfile\.config\nvim" -Recurse -Force;
Remove-Item -Path "$env:UserProfile\.config\starship" -Recurse -Force;
Remove-Item -Path "$env:UserProfile\.config\wezterm" -Recurse -Force;
New-Item -ItemType Junction -Path "$env:UserProfile\.config\alacritty" -Target "$env:UserProfile\dotfiles\alacritty";
New-Item -ItemType Junction -Path "$env:UserProfile\.config\nvim" -Target "$env:UserProfile\dotfiles\nvim";
New-Item -ItemType Junction -Path "$env:UserProfile\.config\starship" -Target "$env:UserProfile\dotfiles\starship";
New-Item -ItemType Junction -Path "$env:UserProfile\.config\wezterm" -Target "$env:UserProfile\dotfiles\wezterm";
```

#### Linux / MacOS
```sh
rm -rf ~/.config/alacritty
rm -rf ~/.config/nvim
rm -rf ~/.config/starship
rm -rf ~/.config/wezterm
ln ~/dotfiles/alacritty ~/.config/alacritty
ln ~/dotfiles/nvim ~/.config/nvim
ln ~/dotfiles/starship ~/.config/starship
ln ~/dotfiles/wezterm ~/.config/wezterm
```