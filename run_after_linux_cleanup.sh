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
mkdir -p "$HOME/.config/winapps"
if [ ! -f "$HOME/.config/winapps/compose.yaml" ]; then
    curl -fsSL https://raw.githubusercontent.com/winapps-org/winapps/main/compose.yaml -o "$HOME/.config/winapps/compose.yaml"
    # inside this yaml file, change USERNAME and PASSWORD to winapps
    sed -i -E 's/(USERNAME:\s*)".*"/\1"winapps"/; s/(PASSWORD:\s*)".*"/\1"winapps"/' ~/.config/winapps/compose.yaml
    echo "WinApps compose.yaml file created and configured in $HOME/.config/winapps/compose.yaml - configure this as needed before creating the VM."
fi
cp -f ~/.config/winapps/winapps.conf.once ~/.config/winapps/winapps.conf
chown $(whoami):$(whoami) ~/.config/winapps/winapps.conf
chmod 644 ~/.config/winapps/compose.yaml
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
    echo "  1) I'm ready to set up WinApps now"
    echo "  2) Don't ask again"
    echo ""
    echo "  Enter) Do this later"
    echo ""
    read -p "Enter your choice (1/2/Enter): " winapps_choice

    case "$winapps_choice" in
        1)
            if [ -n "$WAYLAND_DISPLAY" ]; then
                echo "It looks like you are using Wayland. Please refer to the following discussion:"
                echo "https://github.com/winapps-org/winapps/discussions/19"
                echo ""
                echo "WinApps can only be run in the browser on Wayland at this time. That may change when sdl-rdp is updated."
                echo ""
                read -p "Do you want to continue anyway? (y/N): " wayland_continue
                case "$wayland_continue" in
                    [Yy]*)
                        ;;
                    *)
                        echo "Skipping WinApps setup for now due to Wayland. You won't be asked again. You can delete ~/.config/winapps_setup and rerun this script to be asked again."
                        touch "$HOME/.config/winapps_setup"
                        exit 0
                        ;;
                esac
            fi

            echo "Starting the WinApps Docker container..."
            if command -v docker-compose >/dev/null 2>&1; then
                docker-compose -f "$HOME/.config/winapps/compose.yaml" up -d
            elif docker compose version >/dev/null 2>&1; then
                docker compose --project-directory "$HOME/.config/winapps" up -d
            else
                echo "Error: Docker Compose is not installed. Please install it and try again."
                exit 1
            fi

            if command -v curl >/dev/null 2>&1; then
                echo ""
                echo "You can access WinApps at http://127.0.0.1:8006."
                echo "Please finish setting up your Windows VM at that address before continuing."
                echo ""
                read -p "Press Enter to continue after setting up your Windows VM..."
                echo "Running the WinApps setup script..."
                bash -c "$(curl -fsSL https://raw.githubusercontent.com/winapps-org/winapps/main/setup.sh)"
                touch "$HOME/.config/winapps_setup"
            else
                echo "Error: curl is not installed. Please install curl and try again."
                exit 1
            fi
            ;;
        2)
            echo "You chose not to be asked again. The WinApps setup script will not run again. You can delete ~/.config/winapps_setup and rerun this script to be asked again."
            mkdir -p "$HOME/.config"
            touch "$HOME/.config/winapps_setup"
            ;;
        *)
            echo "Skipping for now. You can run the script again and choose a valid option."
            ;;
    esac
fi

# source the shell profile
source $HOME/.bashrc

echo ""
echo "------------------------------------------------------------------------"
echo "Done. Restart your shell to pick up on any environmental changes."
echo "------------------------------------------------------------------------"

