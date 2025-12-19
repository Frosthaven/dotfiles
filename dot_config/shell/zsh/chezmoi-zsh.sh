# add /usr/local/bin (system-wide binaries like rclone)
export PATH="/usr/local/bin:$PATH"

# add $HOME/.local/bin binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add nvim-bob (stable and nightly) to PATH
export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.local/share/bob/nightly/bin:$PATH"

# SSH Agent configuration for Arch-based distros with COSMIC desktop
if command -v pacman &>/dev/null && [[ "$XDG_CURRENT_DESKTOP" == "COSMIC" ]]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
    
    # Auto-start service if not running
    if ! systemctl --user is-active --quiet ssh-agent.service; then
        systemctl --user start ssh-agent.service
    fi
fi

# starship
eval "$(starship init zsh)"

# eza
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

# nvim
alias vim='nvim'
alias vi='nvim'

# zoxide
eval "$(zoxide init zsh)"
alias cd=z # replace cd with zoxide

# fzf - [s]earch [f]iles command (sf)
# this will use the output of the fzf command to open the file in nvim. you can
# change the editor launch command to whatever you want.
# see: https://github.com/junegunn/fzf
# see: https://github.com/sharkdp/bat
function sf {
    local file
    file=$(fzf --preview "bat --color=always {}" --preview-window=right:50%:wrap --height 50% --border --prompt="search files: " --query="$args")
    if [[ -n "$file" ]]; then
        nvim $file # or with your editor of choice
    fi
}

# add cargo to path
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi
