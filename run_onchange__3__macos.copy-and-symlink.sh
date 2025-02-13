#!/bin/bash

# Automatic Shell Integration
zshrc="$HOME/.zshrc"
chezmoi_zsh_profile="$HOME/.config/shell/chezmoi-zsh.sh"
if ! grep -q "source \"$chezmoi_zsh_profile\"" "$zshrc"; then
  echo "# Load Chezmoi ZSH Profile" >> "$zshrc"
  echo "source \"$chezmoi_zsh_profile\"" >> "$zshrc"
fi

