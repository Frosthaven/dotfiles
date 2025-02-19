#!/bin/bash

# fnm
fnm_env_output=$(fnm env)
if ! grep -q "fnm_multishell" "$HOME/.zshrc"; then
  echo "# fnm" >> "$HOME/.zshrc"
  echo $fnm_env_output >> "$HOME/.zshrc"
fi

# Automatic Shell Integration
zshrc="$HOME/.zshrc"
chezmoi_zsh_profile="$HOME/.config/shell/zsh/chezmoi-zsh.sh"
if ! grep -q "source \"$chezmoi_zsh_profile\"" "$zshrc"; then
  echo "# Load Chezmoi ZSH Profile" >> "$zshrc"
  echo "source \"$chezmoi_zsh_profile\"" >> "$zshrc"
fi

# delete the folder $HOME/Library/Application Support/nushell if it
# isnt a symlink, and then symlink it to $HOME/.config/nushell

nushell_symlink="$HOME/Library/Application Support/nushell"
nushell_folder="$HOME/.config/shell/nushell"
if [ -d "$nushell_folder" ] && [ ! -L "$nushell_folder" ]; then
  rm -rf "$nushell_folder"
fi
ln -s "$nushell_symlink" "$nushell_folder"

# source the shell profile
source $HOME/.zshrc

echo ""
echo "------------------------------------------------------------------------"
echo "Done. Restart your shell to pick up on any environmental changes."
echo "------------------------------------------------------------------------"

