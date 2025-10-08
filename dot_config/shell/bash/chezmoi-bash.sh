# add $HOME/.local/bin binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

# nvim-bob: stable and nightly
export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.local/share/bob/nightly/bin:$PATH"

# Add PNPM to PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Starship prompt
eval "$(starship init bash)"

# eza aliases
alias l='eza --icons=always'
alias ls='eza --icons=always --group --header --group-directories-first'
alias ll='eza --icons=always --group --header --group-directories-first --long --git'
alias lg='eza --icons=always --group --header --group-directories-first --long --git --git-ignore'
alias le='eza --icons=always --group --header --group-directories-first --long --extended'
alias lt='eza --icons=always --group --header --group-directories-first --tree --level level'
alias lc='eza --icons=always --group --header --group-directories-first --across'
alias lo='eza --icons=always --group --header --group-directories-first --oneline'
alias la='eza --icons=always --all'
alias lsa='eza --icons=always --group --header --group-directories-first --all'
alias lla='eza --icons=always --group --header --group-directories-first --all --long --git'
alias lga='eza --icons=always --group --header --group-directories-first --all --long --git --git-ignore'

# Neovim aliases
alias vim='nvim'
alias vi='nvim'

# Zoxide
eval "$(zoxide init bash)"
alias cd='z'  # replace cd with zoxide

# fzf file search helper (sf)
sf() {
    local file
    file=$(fzf --preview "bat --color=always {}" \
               --preview-window=right:50%:wrap \
               --height 50% \
               --border \
               --prompt="search files: " \
               --query="$*")
    if [ -n "$file" ]; then
        nvim "$file"  # replace with preferred editor if desired
    fi
}

# Automatic Nushell
# if [ -z "$NU" ] && [ -x "$HOME/.cargo/bin/nu" ]; then
#   exec "$HOME/.cargo/bin/nu"
# fi

#  Add Cargo to PATH
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi
