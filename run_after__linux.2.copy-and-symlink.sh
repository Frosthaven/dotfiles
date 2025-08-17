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

# source the shell profile
source $HOME/.bashrc

echo ""
echo "------------------------------------------------------------------------"
echo "Done. Restart your shell to pick up on any environmental changes."
echo "------------------------------------------------------------------------"

