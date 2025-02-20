#!/bin/zsh

echo ""
echo "Checking for symbolic links and integrations..."

# Automatic Shell Integration
zshrc="$HOME/.zshrc"
chezmoi_zsh_profile="$HOME/.config/shell/zsh/chezmoi-zsh.sh"
if ! grep -q "source \"$chezmoi_zsh_profile\"" "$zshrc"; then
  echo "# Load Chezmoi ZSH Profile" >> "$zshrc"
  echo "source \"$chezmoi_zsh_profile\"" >> "$zshrc"
fi

# copy nushell files to $HOME/Library/Application Support/nushell/
nushell_dir="$HOME/Library/Application Support/nushell"
chezmoi_nushell_dir="$HOME/.config/shell/nushell"
cp -r "$chezmoi_nushell_dir" "$nushell_dir"

# source the shell profile
source $HOME/.zshrc

echo ""
echo "------------------------------------------------------------------------"
echo "Done. Restart your shell to pick up on any environmental changes."
echo "------------------------------------------------------------------------"

