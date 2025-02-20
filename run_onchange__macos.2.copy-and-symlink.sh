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

# delete the folder $HOME/Library/Application Support/nushell if it
# isnt a symlink, and then symlink it to $HOME/.config/nushell
sym_nushell="$HOME/Library/Application Support/nushell"
dot_nushell="$HOME/.config/nushell"
if [ -d "$sym_nushell" ] && [ ! -L "$sym_nushell" ]; then
  rm -rf "$sym_nushell"
fi
if [ ! -L "$sym_nushell" ]; then
  ln -s "$dot_nushell" "$sym_nushell"
fi


# source the shell profile
source $HOME/.zshrc

echo ""
echo "------------------------------------------------------------------------"
echo "Done. Restart your shell to pick up on any environmental changes."
echo "------------------------------------------------------------------------"

