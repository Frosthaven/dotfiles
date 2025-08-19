#!/bin/bash

echo ""
echo "Checking for symbolic links and integrations..."

# Automatic Shell Integration - Bash/Zsh
bashrc="$HOME/.bashrc"
chezmoi_bash_profile="$HOME/.config/shell/bash/chezmoi-bash.sh"
if [ -f "$bashrc" ] && [ -f "$chezmoi_bash_profile" ]; then
  if ! grep -q "source \"$chezmoi_bash_profile\"" "$bashrc"; then
    echo "# Load Chezmoi BASH Profile" >> "$bashrc"
    echo "source \"$chezmoi_bash_profile\"" >> "$bashrc"
  fi
fi

# Automatic Shell Integration - Fish
fish_config="$HOME/.config/fish/config.fish"
chezmoi_fish_profile="$HOME/.config/shell/fish/chezmoi.fish"
if [ -f "$fish_config" ] && [ -f "$chezmoi_fish_profile" ]; then
  if ! grep -q "source \"$chezmoi_fish_profile\"" "$fish_config"; then
    echo "# Load Chezmoi Fish Profile" >> "$fish_config"
    echo "source \"$chezmoi_fish_profile\"" >> "$fish_config"
  fi
fi

# Ensure $HOME/.local/bin is in PATH
if ! grep -q "\$HOME/.local/bin" "$bashrc"; then
    echo "# Ensure \$HOME/.local/bin is in PATH" >> "$bashrc"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$bashrc"
fi

# copy nushell files to $HOME/Library/Application Support/nushell/
nushell_config_parent="$HOME/.config"
chezmoi_nushell_dir="$HOME/.local/share/chezmoi/dot_config/shell/nushell"
cp -r -f "$chezmoi_nushell_dir" "$nushell_config_parent"

# copy and secure winapps config
cp -f ~/.config/winapps/winapps.conf.once ~/.config/winapps/winapps.conf
chown $(whoami):$(whoami) ~/.config/winapps/winapps.conf
chmod 600 ~/.config/winapps/winapps.conf

# winapps installer script.
# This script will ask the user if they want to setup winapps and have a working
# windows VM (linking to https://github.com/winapps-org/winapps/blob/main/docs/docker.md)
# It will only do this if ~/.config/winapps_setup is not present.
# The options should be 1 (WinApps VM is running), 2 (Do this later), 3 (Don't ask again).
# WinApps installer script.
# This script will ask the user if they want to setup WinApps and have a working
# Windows VM (see: https://github.com/winapps-org/winapps/blob/main/docs/docker.md)
# It will only do this if ~/.config/winapps_setup is not present.
# The options should be:
# 1) WinApps VM is running
# 2) Do this later
# 3) Don't ask again

if [ ! -f "$HOME/.config/winapps_setup" ]; then
    echo ""
    echo "------------------------------------------------------------------------"
    echo "WinApps Setup"
    echo "------------------------------------------------------------------------"
    echo "This script will help you set up WinApps, which allows you to run Windows applications on Linux using a Windows VM."
    echo "You can find more information about WinApps at:"
    echo "https://github.com/winapps-org/winapps"
    echo ""
    echo "Please choose an option:"
    echo ""
    echo "  1) My WinApps VM is running (https://github.com/winapps-org/winapps/blob/main/docs/docker.md)"
    echo "  2) Do this later"
    echo "  3) Don't ask again"
    echo ""
    read -p "Enter your choice (1/2/3): " winapps_choice

    case "$winapps_choice" in
        1)
            echo "You chose to set up WinApps now."
            if command -v curl >/dev/null 2>&1; then
                bash -c "$(curl -fsSL https://raw.githubusercontent.com/winapps-org/winapps/main/setup.sh)"
            else
                echo "Error: curl is not installed. Please install curl and try again."
                exit 1
            fi
            ;;
        2)
            echo "You chose to do this later. You can run the WinApps setup script later."
            ;;
        3)
            echo "You chose not to be asked again. The WinApps setup script will not run again."
            mkdir -p "$HOME/.config"
            touch "$HOME/.config/winapps_setup"
            ;;
        *)
            echo "Invalid choice. Please run the script again and choose a valid option."
            ;;
    esac
fi

# source the shell profile
source $HOME/.bashrc

echo ""
echo "------------------------------------------------------------------------"
echo "Done. Restart your shell to pick up on any environmental changes."
echo "------------------------------------------------------------------------"

