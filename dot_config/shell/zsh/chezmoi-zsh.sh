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

# fnm
if [[ -z "$fnm_dir" ]]; then
    # setup environment
    output=$(fnm env)
    eval "$output"

    # install the latest version
    if ! command -v node &>/dev/null; then
        fnm install --lts
        fnm use lts-latest
    fi
fi

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

# system upgrade
sysup() {
    sudo -v
    setopt errexit          # same as -e
    setopt nounset          # same as -u
    setopt pipefail

    if commands -v apt >/dev/null 2>&1; then
        echo "🔄 Updating APT packages..."
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    else
        # echo "unattended-upgrade not installed, skipping."
    fi

    if command -v cargo >/dev/null 2>&1; then
        echo "🔄 Updating Cargo Rust packages..."
        cargo install $(cargo install --list | egrep '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')
    else
        #echo "Cargo not installed, skipping."
    fi

    if command -v snap >/dev/null 2>&1; then
        echo "🔄 Updating Snap packages..."
        sudo snap refresh
    else
        # echo "Snap not installed, skipping."
    fi

    if command -v flatpak >/dev/null 2>&1; then
        echo "🔄 Updating Flatpak packages..."
        flatpak update -y
    else
        # echo "Flatpak not installed, skipping."
    fi

    if command -v brew >/dev/null 2>&1; then
        echo "🔄 Updating Homebrew packages..."
        brew update
        brew upgrade
        brew cleanup
    else
        # echo "Homebrew not installed, skipping."
    fi

    echo "✅ All system updates completed."
}
