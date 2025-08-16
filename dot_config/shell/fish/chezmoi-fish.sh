# add $HOME/.local/bin binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

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

# FNM (Fast Node Manager)
if [ -z "$fnm_dir" ]; then
    eval "$(fnm env)"

    # install latest LTS if node not present
    if ! command -v node >/dev/null 2>&1; then
        fnm install --lts
        fnm use lts-latest
    fi
fi

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
