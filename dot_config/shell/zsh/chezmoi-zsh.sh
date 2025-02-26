# starship
eval "$(starship init zsh)"

# eza
alias l='eza --icons=always'
alias ls='eza --icons=always --group --header --group-directories-first'
alias ll='eza --icons=always --group --header --group-directories-first --long --git'
alias lg='eza --icons=always --group --header --group-directories-first --long --git --git-ignore'
alias le='eza --icons=always --group --header --group-directories-first --long --extended'
alias lt='eza --icons=always --group --header --group-directories-first --tree --level LEVEL'
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
if [[ -z "$FNM_DIR" ]]; then
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
# this will use the output of the fzf command to open the file in nvim. You can
# change the editor launch command to whatever you want.
# see: https://github.com/junegunn/fzf
# see: https://github.com/sharkdp/bat
function sf {
    local file
    file=$(fzf --preview "bat --color=always {}" --preview-window=right:50%:wrap --height 50% --border --prompt="Search Files: " --query="$args")
    if [[ -n "$file" ]]; then
        nvim $file # or with your editor of choice
    fi
}
