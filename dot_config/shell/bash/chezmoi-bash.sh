# --------------------
# Starship prompt
# --------------------
eval "$(starship init bash)"

# --------------------
# eza aliases
# --------------------
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

# --------------------
# Neovim aliases
# --------------------
alias vim='nvim'
alias vi='nvim'

# --------------------
# Zoxide
# --------------------
eval "$(zoxide init bash)"
alias cd='z'  # replace cd with zoxide

# --------------------
# FNM (Fast Node Manager)
# --------------------
if [ -z "$fnm_dir" ]; then
    eval "$(fnm env)"

    # install latest LTS if node not present
    if ! command -v node >/dev/null 2>&1; then
        fnm install --lts
        fnm use lts-latest
    fi
fi

# --------------------
# fzf file search helper (sf)
# --------------------
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

# ---------------------
# System Updates
# ---------------------

sysup() {
    sudo -v
    set -euo pipefail

    if commands -v apt >/dev/null 2>&1; then
        echo "🔄 Updating APT packages..."
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    fi

    if command -v cargo >/dev/null 2>&1; then
        echo "🔄 Updating Cargo Rust packages..."
        cargo install $(cargo install --list | egrep '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ');
    fi

    if command -v snap >/dev/null 2>&1; then
        echo "🔄 Updating Snap packages..."
        sudo snap refresh
    fi

    if command -v flatpak >/dev/null 2>&1; then
        echo "🔄 Updating Flatpak packages..."
    fi

    if command -v brew >/dev/null 2>&1; then
        echo "🔄 Updating Homebrew packages..."
        brew update
        brew upgrade
        brew cleanup
    fi

    echo "✅ All system updates completed."
}

# ---------------------
# Automatic Nushell
# ---------------------
if [ -z "$NU" ] && [ -x "$HOME/.cargo/bin/nu" ]; then
  exec "$HOME/.cargo/bin/nu"
fi
