# add /usr/local/bin (system-wide binaries like rclone)
export PATH="/usr/local/bin:$PATH"

# add $HOME/.local/bin binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

# nvim-bob: stable and nightly
export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.local/share/bob/nightly/bin:$PATH"

# Add PNPM to PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# SSH Agent configuration for Arch-based distros with COSMIC desktop
if command -v pacman &>/dev/null && [ "$XDG_CURRENT_DESKTOP" = "COSMIC" ]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
    
    # Auto-start service if not running
    if ! systemctl --user is-active --quiet ssh-agent.service; then
        systemctl --user start ssh-agent.service
    fi
fi

# Load SSH keys from Proton Pass (only if agent is empty)
if command -v pass-cli &>/dev/null; then
    # Check if keys are already loaded (fast check)
    if ssh-add -l &>/dev/null; then
        # Keys already loaded, skip pass-cli calls
        export PROTON_PASS_LOGGED_IN="true"
    else
        # No keys loaded, check if logged in to Proton Pass
        if pass-cli info &>/dev/null 2>&1; then
            export PROTON_PASS_LOGGED_IN="true"
            pass-cli ssh-agent load &>/dev/null
        else
            export PROTON_PASS_LOGGED_IN="false"
            echo "(proton pass) Not logged in. Run 'pass-cli login' to load SSH keys."
        fi
    fi
fi

# Wrapper: rclone with lazy password loading
rclone() {
    if [ -z "$RCLONE_CONFIG_PASS" ]; then
        RCLONE_CONFIG_PASS=$(pass-cli item view "pass://Personal/rclone/password" --field password 2>/dev/null)
        export RCLONE_CONFIG_PASS
    fi
    command rclone "$@"
}

# Helper: rclone-config - runs rclone config and syncs to chezmoi
rclone-config() {
    rclone config
    echo "Syncing rclone config to chezmoi..."
    chezmoi re-add ~/.config/rclone/rclone.conf
    echo "Done. Commit with: chezmoi git add -A && chezmoi git commit -m 'Update rclone config'"
}

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

# Source additional functions
source "$HOME/.config/shell/bash/sources/pass-ssh-unpack.bash"
source "$HOME/.config/shell/bash/sources/system-update.bash"
